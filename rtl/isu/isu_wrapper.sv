module isu_wrapper
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
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    // 1. from upstream htu req 
    input  logic                        u_htu_valid                ,
    output logic                        u_htu_ready                ,
    input  logic           [  2: 0]     u_htu_channel_1hot_id      ,
    input  logic           [  2: 0]     u_htu_op                   ,
    input  nlineWidth_t                 u_htu_id                   ,
    input  offsetWidth_t                u_htu_offset               ,
    input  wbufWidth_t                  u_htu_wbuf_id              ,

    // 2. from upstream htu refill info
    input  logic                        u_htu_refill_valid         ,
    input  setWidth_t                   u_htu_refill_set           ,
    input  wayIndexWidth_t              u_htu_refill_way           ,

    // 3. memory controller intf
    input  logic                        memctl_refill_valid        ,
    output logic                        memctl_refill_ready        ,  
    input  nlineWidth_t                 memctl_refill_id           ,
    input  logic            [255: 0]    memctl_refill_data         ,

    // 4. from upstream xbar credit return
    input  logic            [  2: 0]    u_xbar_crdt_rtn            ,

    // 5. to sram controller interface
    output logic                        d_rc_valid                 ,
    input  logic                        d_rc_ready                 ,
    output logic            [  2: 0]    d_rc_channel_1hot_id       ,
    output robWidth_t                   d_rc_rob_id                ,
    output logic            [  2: 0]    d_rc_op                    ,
    output setWidth_t                   d_rc_set                   ,
    output wayIndexWidth_t              d_rc_way                   ,
    output offsetWidth_t                d_rc_offset                ,
    output wbufWidth_t                  d_rc_wbuf_id               ,
    output logic            [255: 0]    d_rc_refill_data           ,

    // 6. return credit for reference counter
    output logic                        u_htu_crdt_valid           ,
    output nlineWidth_t                 u_htu_crdt_way_set          

);

localparam wayMSB       = Cfg.nlineWidth - 1;
localparam wayLSB       = Cfg.setWidth;
localparam setMSB       = Cfg.setWidth-1;
localparam setLSB       = 0;

setWidth_t                              u_htu_set;
wayIndexWidth_t                         u_htu_way;
logic                                   inflight_array_inflight_flg;
logic                                   lsq_inflight_flg;
logic                   [  2: 0]        lsq_deq_op;
logic                                   refill_buf_confirm;
logic                                   hit_refill_buf;

assign u_htu_set = u_htu_id[setMSB:setLSB];
assign u_htu_way = u_htu_id[wayMSB:wayLSB];

assign lsq_inflight_flg = inflight_array_inflight_flg | u_htu_refill_valid;

assign d_rc_op = hit_refill_buf ?  is_load(lsq_deq_op) ? CACHE_OP_LOAD_REFILL  : 
                                  is_store(lsq_deq_op) ? CACHE_OP_STORE_REFILL : lsq_deq_op : lsq_deq_op;


inflight_array # (
    .Cfg                               (Cfg                                ),
    .setWidth_t                        (setWidth_t                         ),
    .tagWidth_t                        (tagWidth_t                         ),
    .wayIndexWidth_t                   (wayIndexWidth_t                    ),
    .wbufWidth_t                       (wbufWidth_t                        ),
    .wayNum_t                          (wayNum_t                           ),
    .nlineWidth_t                      (nlineWidth_t                       ),
    .offsetWidth_t                     (offsetWidth_t                      ),
    .metaWidth_t                       (metaWidth_t                        ),
    .robWidth_t                        (robWidth_t                         )
) u_inflight_array (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .htu_refill_valid                  (u_htu_refill_valid                 ),
    .htu_refill_set                    (u_htu_refill_set                   ),
    .htu_refill_way                    (u_htu_refill_way                   ),
    .htu_set                           (u_htu_set                          ),
    .htu_way                           (u_htu_way                          ),
    .inflight_flg                      (inflight_array_inflight_flg        ),
    .memctl_refill_valid               (memctl_refill_valid                ),
    .memctl_refill_id                  (memctl_refill_id                   )
);

lsq # (
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
    .lsqWidth_t                        (lsqWidth_t                         )
) u_lsq (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .u_inflight_flg                    (lsq_inflight_flg                   ),
    .u_htu_valid                       (u_htu_valid                        ),
    .u_htu_ready                       (u_htu_ready                        ),
    .u_htu_channel_1hot_id             (u_htu_channel_1hot_id              ),
    .u_htu_op                          (u_htu_op                           ),
    .u_htu_id                          (u_htu_id                           ),
    .u_htu_offset                      (u_htu_offset                       ),
    .u_htu_wbuf_id                     (u_htu_wbuf_id                      ),
    .u_htu_crdt_valid                  (u_htu_crdt_valid                   ),
    .u_htu_crdt_id                     (u_htu_crdt_way_set                 ),
    .u_xbar_crdt_rtn                   (u_xbar_crdt_rtn                    ),
    .memctl_refill_valid               (memctl_refill_valid                ),
    .memctl_refill_id                  (memctl_refill_id                   ),
    .refill_buf_confirm                (refill_buf_confirm                 ),
    .d_rc_valid                        (d_rc_valid                         ),
    .d_rc_ready                        (d_rc_ready                         ),
    .d_rc_channel_1hot_id              (d_rc_channel_1hot_id               ),
    .d_rc_rob_id                       (d_rc_rob_id                        ),
    .d_rc_op                           (lsq_deq_op                         ),
    .d_rc_set                          (d_rc_set                           ),
    .d_rc_way                          (d_rc_way                           ),
    .d_rc_offset                       (d_rc_offset                        ),
    .d_rc_wbuf_id                      (d_rc_wbuf_id                       )
);

refill_buffer # (
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
    .rfbufWidth_t                      (rfbufWidth_t                       )
) u_refill_buffer (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .memctl_refill_valid               (memctl_refill_valid                ),
    .memctl_refill_ready               (memctl_refill_ready                ),
    .memctl_refill_id                  (memctl_refill_id                   ),
    .memctl_refill_data                (memctl_refill_data                 ),
    .lsq_deq_confirm                   (refill_buf_confirm                 ),
    .lsq_deq_set                       (d_rc_set                           ),
    .lsq_deq_way                       (d_rc_way                           ),
    .d_rc_hit_refill_buf               (hit_refill_buf                     ),
    .d_rc_ready                        (d_rc_ready                         ),
    .d_rc_refill_data                  (d_rc_refill_data                   )
);

endmodule