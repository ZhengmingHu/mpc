module rob_wrapper 
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
    input  logic           [  1: 0]            u_kob_rob_bank_id          ,

    input  logic                               d_rc_valid                 ,
    input  robWidth_t                          d_rc_rob_id                ,
    input  logic           [127: 0]            d_rc_data                  ,
    input  logic           [  1: 0]            d_rc_bank_id               ,

    output logic                               u_ch_valid                 ,
    input  logic                               u_ch_ready                 ,
    output logic           [127: 0]            u_ch_data                  ,

    output logic                               d_bank_0_crdt_rtn          ,
    output logic                               d_bank_1_crdt_rtn          ,
    output logic                               d_bank_2_crdt_rtn          ,
    output logic                               d_bank_3_crdt_rtn            
);

logic                      [  3: 0]            kob_rob_ack;
logic                      [  3: 0]            ch_valid;
logic                      [127: 0]            ch_data        [  3: 0];
  
rob # (
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
) u_rob_bank_0 (
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    
    .u_kob_rob_req                     (u_kob_rob_req & u_kob_rob_bank_id == 0),
    .u_kob_rob_ack                     (kob_rob_ack[0]            ),

    .d_rc_valid                        (d_rc_valid & d_rc_bank_id == 0),
    .d_rc_rob_id                       (d_rc_rob_id               ),
    .d_rc_data                         (d_rc_data                 ),
    
    .u_ch_valid                        (ch_valid[0]               ),
    .u_ch_ready                        (u_ch_ready                ),
    .u_ch_data                         (ch_data[0]                ),
    
    .d_isu_crdt_rtn                    (d_bank_0_crdt_rtn         )
);

rob # (
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
) u_rob_bank_1 (
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    
    .u_kob_rob_req                     (u_kob_rob_req & u_kob_rob_bank_id == 1),
    .u_kob_rob_ack                     (kob_rob_ack[1]            ),
    .d_rc_valid                        (d_rc_valid & d_rc_bank_id == 1),
    .d_rc_rob_id                       (d_rc_rob_id               ),
    .d_rc_data                         (d_rc_data                 ),
    
    .u_ch_valid                        (ch_valid[1]               ),
    .u_ch_ready                        (u_ch_ready                ),
    .u_ch_data                         (ch_data[1]                ),
    
    .d_isu_crdt_rtn                    (d_bank_1_crdt_rtn         )
);

rob # (
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
) u_rob_bank_2 (
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    
    .u_kob_rob_req                     (u_kob_rob_req & u_kob_rob_bank_id == 2),
    .u_kob_rob_ack                     (kob_rob_ack[2]            ),
    .d_rc_valid                        (d_rc_valid & d_rc_bank_id == 2),
    .d_rc_rob_id                       (d_rc_rob_id               ),
    .d_rc_data                         (d_rc_data                 ),
    
    .u_ch_valid                        (ch_valid[2]               ),
    .u_ch_ready                        (u_ch_ready                ),
    .u_ch_data                         (ch_data[2]                ),
    
    .d_isu_crdt_rtn                    (d_bank_2_crdt_rtn         )
);

rob # (
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
) u_rob_bank_3 (
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    
    .u_kob_rob_req                     (u_kob_rob_req & u_kob_rob_bank_id == 3),
    .u_kob_rob_ack                     (kob_rob_ack[3]            ),
    .d_rc_valid                        (d_rc_valid & d_rc_bank_id == 3),
    .d_rc_rob_id                       (d_rc_rob_id               ),
    .d_rc_data                         (d_rc_data                 ),
    
    .u_ch_valid                        (ch_valid[3]               ),
    .u_ch_ready                        (u_ch_ready                ),
    .u_ch_data                         (ch_data[3]                ),
    
    .d_isu_crdt_rtn                    (d_bank_3_crdt_rtn         )
);

assign u_kob_rob_ack = |kob_rob_ack;
assign u_ch_valid    = |ch_valid;
assign u_ch_data     = ch_data[u_kob_rob_bank_id];

endmodule