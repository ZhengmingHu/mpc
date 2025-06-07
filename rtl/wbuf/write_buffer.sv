module write_buffer_entry
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
    parameter type kobWidth_t      = logic
)(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        enq_valid                  ,
    input  logic            [127: 0]    enq_wdata                  ,

    input  logic                        deq_valid                  ,
    output logic                        deq_confirm                ,
    output logic            [127: 0]    deq_wdata           
);

logic          entry_valid_en;
logic          entry_valid_nxt;
logic          entry_valid;
logic [127: 0] entry_wdata;

assign entry_valid_en  = enq_valid | deq_valid;
assign entry_valid_nxt = enq_valid & !deq_valid; 

ns_gnrl_dfflr # (  1) entry_valid_dfflr (entry_valid_en, entry_valid_nxt, entry_valid, clk, rst_n);
ns_gnrl_dfflr # (128) entry_wdata_dfflr (enq_valid, enq_wdata, entry_wdata, clk, rst_n);

assign deq_confirm = deq_valid;
assign deq_wdata = entry_wdata;

endmodule

module write_buffer     
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
    parameter type kobWidth_t      = logic
)(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        xbar_req_valid             ,
    input  wbuf_req_t                   xbar_req                   ,
    output logic                        xbar_rsp_free_valid        ,
    output wbufWidth_t                  xbar_rsp_free_id           ,

    input  logic                        rc_req_valid               ,
    input  wbufWidth_t                  rc_req_id                  ,
    output logic            [127: 0]    rc_rsp_data                
);

logic  [127: 0] entry_rsp_data [Cfg.u.wbufSize-1:0]; 
logic  [Cfg.u.wbufSize-1:0] entry_confirm;
logic  [127: 0] rc_rsp_data_nxt;

generate
    for (genvar i = 0; i < int'(Cfg.u.wbufSize); i = i + 1) begin
        write_buffer_entry # (
            .Cfg                               (Cfg                                ),
            .setWidth_t                        (setWidth_t                         ),
            .tagWidth_t                        (tagWidth_t                         ),
            .wayIndexWidth_t                   (wayIndexWidth_t                    ),
            .wbufWidth_t                       (wbufWidth_t                        ),
            .wayNum_t                          (wayNum_t                           ),
            .nlineWidth_t                      (nlineWidth_t                       ),
            .offsetWidth_t                     (offsetWidth_t                      ),
            .metaWidth_t                       (metaWidth_t                        ),
            .robWidth_t                        (robWidth_t                         ),
            .lsqWidth_t                        (lsqWidth_t                         ),
            .kobWidth_t                        (kobWidth_t                         )
        ) u_write_buffer_entry (
            .clk        (clk                                    ),
            .rst_n      (rst_n                                  ),
            .enq_valid  (xbar_req_valid && xbar_req.wbuf_id == i),
            .enq_wdata  (xbar_req.wdata                         ),
            .deq_valid  (rc_req_valid && rc_req_id == i         ),
            .deq_confirm(entry_confirm[i]                       ),
            .deq_wdata  (entry_rsp_data[i]                      )
        );
    end
endgenerate

ns_mux1h # (128, Cfg.u.wbufSize) rc_rsp_data_mux1h (entry_rsp_data, entry_confirm, rc_rsp_data_nxt);
ns_gnrl_dfflr # (128) rc_rsp_data_dfflr (1'b1, rc_rsp_data_nxt, rc_rsp_data, clk, rst_n);
ns_gnrl_dfflr # (1) xbar_rsp_free_valid_dfflr (1'b1, rc_req_valid, xbar_rsp_free_valid, clk, rst_n);
ns_gnrl_dfflr # (Cfg.wbufWidth) xbar_rsp_free_id_dfflr (1'b1, rc_req_id, xbar_rsp_free_id, clk, rst_n);

endmodule