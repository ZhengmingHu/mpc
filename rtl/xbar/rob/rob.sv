module rob_entry
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
    parameter type lsqWidth_t      = logic
)
(
    input  logic                               clk                        ,
    input  logic                               rst_n                      ,

    input  logic                               enq_valid                  ,
    output logic                               enq_ready                  ,
    input  logic           [127: 0]            enq_data                   ,

    output logic                               deq_valid                  ,
    input  logic                               deq_ready                  ,
    output logic           [127:0]             deq_data
);

logic                                   entry_vld_en               ;
logic                                   entry_vld_nxt              ;
logic                                   entry_vld                  ;

logic            [127: 0]               entry_data                 ;

logic                                   deq_hsked                  ;

assign deq_hsked = deq_valid & deq_ready;

assign entry_vld_en  = enq_valid | deq_hsked;
assign entry_vld_nxt = enq_valid;

assign enq_ready = !entry_vld;

ns_gnrl_dfflr # (                1)               entry_vld_dfflr (entry_vld_en, entry_vld_nxt, entry_vld, clk, rst_n);
ns_gnrl_dfflr # (              128)              entry_data_dfflr (enq_valid, enq_data, entry_data, clk, rst_n);

assign deq_valid = entry_vld;
assign deq_data = entry_data;

endmodule


module rob 
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
    parameter type lsqWidth_t      = logic
)
(
    input  logic                               clk                        ,
    input  logic                               rst_n                      ,

    input  logic                               u_kob_rob_req              ,
    output logic                               u_kob_rob_ack              ,

    input  logic                               d_rc_valid                 ,
    input  robWidth_t                          d_rc_rob_id                ,
    input  logic           [127: 0]            d_rc_data                  ,

    output logic                               u_ch_valid                 ,
    input  logic                               u_ch_ready                 ,
    output logic           [127: 0]            u_ch_data                  ,

    output logic                               d_isu_crdt_rtn              
);

logic            [Cfg.u.robSize-1:0]    rob_entry_rdy              ;
robWidth_t                              rob_r_ptr                  ;

logic            [Cfg.u.robSize-1:0]    rob_deq_vld                ;
logic            [            127:0]    rob_deq_data    [Cfg.u.robSize-1:0];

rob_id_gen_lite # (
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
    .lsqWidth_t                        (lsqWidth_t                )
) u_rob_id_gen_lite (
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .u_valid                           (u_kob_rob_ack             ),
    .d_rob_id                          (rob_r_ptr                 )
);

generate
    for (genvar i = 0; i < int'(Cfg.u.robSize); i++) 
    begin: rob_entry_gen
        rob_entry # (
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
            .lsqWidth_t                        (lsqWidth_t                )
        ) u_rob_entry (
            .clk                               (clk                       ),
            .rst_n                             (rst_n                     ),
            .enq_valid                         (d_rc_valid & d_rc_rob_id == i),
            .enq_ready                         (rob_entry_rdy[i]          ),
            .enq_data                          (d_rc_data                 ),
            .deq_valid                         (rob_deq_vld[i]            ),
            .deq_ready                         (u_kob_rob_req & u_ch_ready & rob_r_ptr == i),
            .deq_data                          (rob_deq_data[i]           )
        );
    end
endgenerate

assign u_ch_data = rob_deq_data[rob_r_ptr];
assign u_ch_valid = u_kob_rob_req & rob_deq_vld[rob_r_ptr];
assign u_kob_rob_ack =  u_kob_rob_req & rob_deq_vld[rob_r_ptr] & u_ch_ready;
assign d_isu_crdt_rtn = u_kob_rob_ack;

endmodule