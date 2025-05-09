module refill_buffer_entry
    import mpc_types::*;
#(
    parameter mpc_cfg_t Cfg = '0,   
    parameter type setWidth_t      = logic,
    parameter type tagWidth_t      = logic,
    parameter type wayIndexWidth_t = logic,
    parameter type wbufWidth_t     = logic,
    parameter type wayNum_t        = logic,
    parameter type nlineWidth_t    = logic,
    parameter type offsetWidth_t   = logic,
    parameter type metaWidth_t     = logic,
    parameter type robWidth_t      = logic,
    parameter type lsqWidth_t      = logic,
    parameter type rfbufWidth_t    = logic
)
(
    input  logic                                   clk                        ,
    input  logic                                   rst_n                      ,

    input  logic                                   memctl_refill_valid        ,
    input  nlineWidth_t                            memctl_refill_id           ,
    input  logic                  [255: 0]         memctl_refill_data         ,

    output logic                                   entry_valid                ,
    output setWidth_t                              entry_set                  ,
    output wayIndexWidth_t                         entry_way                  ,

    output logic                                   deq_valid                  ,
    input  logic                                   deq_ready                  ,
    output logic                 [255: 0]          deq_data    

);

localparam wayMSB       = Cfg.nlineWidth - 1;
localparam wayLSB       = Cfg.setWidth;
localparam setMSB       = Cfg.setWidth-1;
localparam setLSB       = 0;

setWidth_t                                         memctl_refill_set;
wayIndexWidth_t                                    memctl_refill_way;

logic                                              entry_valid_set;
logic                                              entry_valid_nxt;

logic                            [255: 0]          entry_data;

logic                                              deq_hsked;

assign memctl_refill_set = memctl_refill_id[setMSB:setLSB];
assign memctl_refill_way = memctl_refill_id[wayMSB:wayLSB];

assign entry_valid_set   = memctl_refill_valid | deq_hsked;
assign entry_valid_nxt   = memctl_refill_valid;

assign deq_hsked         = deq_valid & deq_ready;

ns_gnrl_dfflr # (                1) entry_valid_dfflr (entry_valid_set, entry_valid_nxt, entry_valid, clk, rst_n);
ns_gnrl_dfflr # (     Cfg.setWidth) entry_set_dfflr (memctl_refill_valid, memctl_refill_set, entry_set, clk, rst_n);
ns_gnrl_dfflr # (Cfg.wayIndexWidth) entry_way_dfflr (memctl_refill_valid, memctl_refill_way, entry_way, clk, rst_n);
ns_gnrl_dfflr # (              256) entry_data_dfflr (memctl_refill_valid, memctl_refill_data, entry_data, clk, rst_n);

assign deq_valid         = entry_valid;
assign deq_data          = entry_data;

endmodule

module refill_buffer
    import mpc_types::*;
#(
    parameter mpc_cfg_t Cfg = '0,   
    parameter type setWidth_t      = logic,
    parameter type tagWidth_t      = logic,
    parameter type wayIndexWidth_t = logic,
    parameter type wbufWidth_t     = logic,
    parameter type wayNum_t        = logic,
    parameter type nlineWidth_t    = logic,
    parameter type offsetWidth_t   = logic,
    parameter type metaWidth_t     = logic,
    parameter type robWidth_t      = logic,
    parameter type lsqWidth_t      = logic,
    parameter type rfbufWidth_t    = logic
)   
(
    input  logic                                   clk                        ,                      
    input  logic                                   rst_n                      ,
    
    // 1. memory controller intf
    input  logic                                   memctl_refill_valid        ,
    output logic                                   memctl_refill_ready        ,  
    input  nlineWidth_t                            memctl_refill_id           ,
    input  logic                   [255: 0]        memctl_refill_data         ,

    // 2. lsq intf
    input  logic                                   lsq_deq_confirm            ,                                   
    input  setWidth_t                              lsq_deq_set                ,
    input  wayIndexWidth_t                         lsq_deq_way                ,

    // 3. downstream rc intf
    output logic                                   d_rc_hit_refill_buf        ,
    input  logic                                   d_rc_ready                 ,
    output logic                  [255: 0]         d_rc_refill_data                     
);

logic [Cfg.u.rfbufSize-1:0]                        entry_vld_vec;
rfbufWidth_t                                       enq_ptr;
logic [Cfg.u.rfbufSize-1:0]                        entry_rdy_vec;

setWidth_t                                         entry_set_vec [Cfg.u.rfbufSize-1:0];
wayIndexWidth_t                                    entry_way_vec [Cfg.u.rfbufSize-1:0];

logic [Cfg.u.rfbufSize-1:0]                        deq_valid_vec;
logic [            256-1:0]                        deq_data_vec [Cfg.u.rfbufSize-1:0];
rfbufWidth_t                                       deq_ptr;

logic [Cfg.u.rfbufSize-1:0]                        hit_refill_buf_vec;

assign entry_rdy_vec = ~entry_vld_vec;
assign memctl_refill_ready = |entry_rdy_vec;

priority_encoder # (Cfg.u.rfbufSize) enq_ptr_prio_enc (entry_rdy_vec, enq_ptr);
priority_encoder # (Cfg.u.rfbufSize) deq_ptr_prio_enc (hit_refill_buf_vec, deq_ptr);

generate
    for (genvar i = 0; i < int'(Cfg.u.rfbufSize); i++)
    begin: hit_refill_buf_gen
        assign hit_refill_buf_vec[i] = entry_set_vec[i] == lsq_deq_set && entry_way_vec[i] == lsq_deq_way && lsq_deq_confirm && entry_vld_vec[i];
    end

    for (genvar i = 0; i < int'(Cfg.u.rfbufSize); i++)
    begin: refill_buffer_entry_gen
        refill_buffer_entry # (
            .Cfg                               (Cfg                       ),
            .setWidth_t                        (setWidth_t                ),
            .tagWidth_t                        (tagWidth_t                ),
            .wayIndexWidth_t                   (wayIndexWidth_t           ),
            .wbufWidth_t                       (wbufWidth_t               ),
            .wayNum_t                          (wayNum_t                  ),
            .nlineWidth_t                      (nlineWidth_t              ),
            .offsetWidth_t                     (offsetWidth_t             ),
            .metaWidth_t                       (metaWidth_t               ),
            .robWidth_t                        (robWidth_t                ),
            .lsqWidth_t                        (lsqWidth_t                ),
            .rfbufWidth_t                      (rfbufWidth_t              )
        ) u_refill_buffer_entry (
            .clk                               (clk                       ),          
            .rst_n                             (rst_n                     ),
            
            .memctl_refill_valid               (memctl_refill_valid && enq_ptr == i),
            .memctl_refill_id                  (memctl_refill_id          ),
            .memctl_refill_data                (memctl_refill_data        ),

            .entry_valid                       (entry_vld_vec[i]          ),
            .entry_set                         (entry_set_vec[i]          ),
            .entry_way                         (entry_way_vec[i]          ),

            .deq_valid                         (deq_valid_vec[i]          ),
            .deq_ready                         (d_rc_ready && deq_ptr == i && lsq_deq_confirm),
            .deq_data                          (deq_data_vec[i]           ) 
        );
    end

endgenerate

assign d_rc_hit_refill_buf = |hit_refill_buf_vec;
assign d_rc_refill_data = deq_data_vec[deq_ptr];

endmodule