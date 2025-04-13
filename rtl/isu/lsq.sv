module lsq_entry 
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
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        enq_valid                  ,
    output logic                        enq_ready                  ,
    input  logic                        enq_inflight_flg           ,
    input  logic            [  2: 0]    enq_channel_1hot_id        ,
    input  robWidth_t                   enq_rob_id                 ,            
    input  logic            [  2: 0]    enq_op                     ,
    input  setWidth_t                   enq_set                    ,
    input  wayIndexWidth_t              enq_way                    ,
    input  offsetWidth_t                enq_offset                 ,
    input  wbufWidth_t                  enq_wbuf_id                ,

    input  logic                        memctl_refill_valid        ,
    input  setWidth_t                   memctl_refill_set          ,
    input  wayIndexWidth_t              memctl_refill_way          ,

    output logic                        status_valid               ,
    output logic            [  1: 0]    status_channel_id          ,

    input  logic                        entry_can_execute          ,

    output logic                        deq_valid                  ,
    input  logic                        deq_ready                  ,
    output logic                        deq_real_valid             ,
    output logic            [  2: 0]    deq_channel_1hot_id        ,
    output robWidth_t                   deq_rob_id                 ,
    output logic            [  2: 0]    deq_op                     ,
    output setWidth_t                   deq_set                    ,
    output wayIndexWidth_t              deq_way                    ,
    output offsetWidth_t                deq_offset                 ,
    output wbufWidth_t                  deq_wbuf_id

);

logic                                   entry_vld_en               ;
logic                                   entry_vld_nxt              ;
logic                                   entry_vld                  ;

logic                                   entry_inflight_en          ;
logic                                   entry_inflight_nxt         ;
logic                                   entry_inflight             ;

logic            [  2: 0]               entry_channel_1hot_id      ;
logic            [  1: 0]               entry_channel_id           ;
robWidth_t                              entry_rob_id               ;
logic                                   entry_op_en                ;
logic            [  2: 0]               entry_op_nxt               ;
logic            [  2: 0]               entry_op                   ;
setWidth_t                              entry_set                  ;
wayIndexWidth_t                         entry_way                  ;
offsetWidth_t                           entry_offset               ;
wbufWidth_t                             entry_wbuf_id              ;

logic                                   deq_hsked                  ;

assign deq_hsked = deq_valid & deq_ready;

assign entry_vld_en  = enq_valid | deq_hsked;
assign entry_vld_nxt = enq_valid | (deq_hsked & (is_rae(entry_op) | is_wae(entry_op)));

assign entry_inflight_en =  (enq_valid & enq_inflight_flg & !(memctl_refill_valid & memctl_refill_set == enq_set & memctl_refill_way == enq_way)) | 
                            (memctl_refill_valid & memctl_refill_set == entry_set & memctl_refill_way == entry_way);
assign entry_inflight_nxt =  enq_valid & enq_inflight_flg;

assign entry_op_en  = enq_valid | (deq_hsked & (is_rae(entry_op) | is_wae(entry_op)));
assign entry_op_nxt = enq_valid                    ? enq_op                : 
                      deq_hsked & is_rae(entry_op) ? CACHE_OP_LOAD_REFILL  :  
                      deq_hsked & is_wae(entry_op) ? CACHE_OP_STORE_REFILL : entry_op;
ns_gnrl_dfflr # (                1)               entry_vld_dfflr (entry_vld_en, entry_vld_nxt, entry_vld, clk, rst_n);
ns_gnrl_dfflr # (                1)          entry_inflight_dfflr (entry_inflight_en, entry_inflight_nxt, entry_inflight, clk, rst_n);
ns_gnrl_dfflr # (                3)   entry_channel_1hot_id_dfflr (enq_valid, enq_channel_1hot_id, entry_channel_1hot_id, clk, rst_n);
ns_gnrl_dfflr # (     Cfg.robWidth)            entry_rob_id_dfflr (enq_valid, enq_rob_id, entry_rob_id, clk, rst_n);
ns_gnrl_dfflr # (                3)                entry_op_dfflr (entry_op_en, entry_op_nxt, entry_op, clk, rst_n);
ns_gnrl_dfflr # (     Cfg.setWidth)               entry_set_dfflr (enq_valid, enq_set, entry_set, clk, rst_n);
ns_gnrl_dfflr # (Cfg.wayIndexWidth)               entry_way_dfflr (enq_valid, enq_way, entry_way, clk, rst_n);
ns_gnrl_dfflr # (  Cfg.offsetWidth)            entry_offset_dfflr (enq_valid, enq_offset, entry_offset, clk, rst_n);
ns_gnrl_dfflr # (    Cfg.wbufWidth)           entry_wbuf_id_dfflr (enq_valid, enq_wbuf_id, entry_wbuf_id, clk, rst_n);

ns_1hot2bin # (3) entry_channel_1hot2bin (entry_channel_1hot_id, entry_channel_id);

assign enq_ready                = !entry_vld;

assign status_valid             = entry_vld;
assign status_channel_id        = entry_channel_id;

assign deq_valid                = entry_vld & !entry_inflight & entry_can_execute;
assign deq_real_valid           = entry_vld & !entry_inflight & entry_can_execute & !(is_rae(entry_op) | is_wae(entry_op));
assign deq_channel_1hot_id      = entry_channel_1hot_id;
assign deq_rob_id               = entry_rob_id;
assign deq_op                   = is_rae(entry_op) | is_wae(entry_op) ? CACHE_OP_WB : entry_op;
assign deq_set                  = entry_set;
assign deq_way                  = entry_way;
assign deq_offset               = entry_offset;
assign deq_wbuf_id              = entry_wbuf_id;


endmodule

module lsq
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
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    // 1. from upstream htu inflight info, refill valid | hit under miss
    input  logic                        u_inflight_flg             ,
    // 2. from upstream htu req 
    input  logic                        u_htu_valid                ,
    output logic                        u_htu_ready                ,
    input  logic           [  2: 0]     u_htu_channel_1hot_id      ,
    input  logic           [  2: 0]     u_htu_op                   ,
    input  nlineWidth_t                 u_htu_id                   ,
    input  offsetWidth_t                u_htu_offset               ,
    input  wbufWidth_t                  u_htu_wbuf_id              ,
    // 3. to htu credit
    output logic                        u_htu_crdt_valid           ,
    output nlineWidth_t                 u_htu_crdt_id              ,
    // 4. from rob credit
    input  logic            [  2: 0]    u_xbar_crdt_rtn            ,
    // 5. from memory interface
    input  logic                        memctl_refill_valid        ,
    input  nlineWidth_t                 memctl_refill_id           ,
    // 6. to refill buffer
    output logic                        refill_buf_confirm         ,
    // 6. to sram controller interface
    output logic                        d_rc_valid                 ,
    input  logic                        d_rc_ready                 ,
    output logic            [  2: 0]    d_rc_channel_1hot_id       ,
    output robWidth_t                   d_rc_rob_id                ,
    output logic            [  2: 0]    d_rc_op                    ,
    output setWidth_t                   d_rc_set                   ,
    output offsetWidth_t                d_rc_offset                ,
    output wayIndexWidth_t              d_rc_way                   ,
    output wbufWidth_t                  d_rc_wbuf_id         
      
);

localparam wayMSB       = Cfg.nlineWidth - 1;
localparam wayLSB       = Cfg.setWidth;
localparam setMSB       = Cfg.setWidth-1;
localparam setLSB       = 0;

wayIndexWidth_t                         u_htu_way                  ;
setWidth_t                              u_htu_set                  ;

wayIndexWidth_t                         memctl_refill_way          ;
setWidth_t                              memctl_refill_set          ;

logic                                   rob_id_gen_valid           ;
logic                                   u_htu_hsked                ;
robWidth_t                              rob_id                     ;

lsqWidth_t                              lsq_w_ptr                  ;
lsqWidth_t                              lsq_r_ptr                  ;
lsqWidth_t                              lsq_btm_ptr                ;

logic            [Cfg.u.lsqSize-1:0]    lsq_entry_vld              ;
logic            [Cfg.u.lsqSize-1:0]    lsq_entry_rdy              ;
logic            [              1:0]    lsq_entry_channel_id [Cfg.u.lsqSize-1:0];

logic            [Cfg.u.lsqSize-1:0]    lsq_deq_vld                ;
logic            [Cfg.u.lsqSize-1:0]    lsq_deq_real_valid         ;
logic            [Cfg.u.lsqSize-1:0]    lsq_deq_real_sel           ;
logic            [  2: 0]               lsq_deq_channel_1hot_id [Cfg.u.lsqSize-1:0];
robWidth_t                              lsq_deq_rob_id          [Cfg.u.lsqSize-1:0];
logic            [  2: 0]               lsq_deq_op              [Cfg.u.lsqSize-1:0];
setWidth_t                              lsq_deq_set             [Cfg.u.lsqSize-1:0];
wayIndexWidth_t                         lsq_deq_way             [Cfg.u.lsqSize-1:0];
offsetWidth_t                           lsq_deq_offset          [Cfg.u.lsqSize-1:0];
wbufWidth_t                             lsq_deq_wbuf_id         [Cfg.u.lsqSize-1:0];

logic            [Cfg.u.lsqSize-1:0]    entry_can_execute          ;

logic                                   lsq_deq_confirm            ;

assign u_htu_ready = |lsq_entry_rdy;
assign u_htu_hsked = u_htu_valid & u_htu_ready;
assign u_htu_way   = u_htu_id [wayMSB:wayLSB];
assign u_htu_set   = u_htu_id [setMSB:setLSB];

assign memctl_refill_way = memctl_refill_id [wayMSB:wayLSB];
assign memctl_refill_set = memctl_refill_id [setMSB:setLSB];

assign rob_id_gen_valid = u_htu_valid & u_htu_ready & (is_load(u_htu_op) | is_rae(u_htu_op));

assign lsq_deq_confirm = |lsq_deq_real_sel & d_rc_ready;
assign refill_buf_confirm = |lsq_deq_real_sel;

assign d_rc_valid = |lsq_deq_vld;
assign d_rc_channel_1hot_id = lsq_deq_channel_1hot_id[lsq_r_ptr];
assign d_rc_rob_id = lsq_deq_rob_id[lsq_r_ptr];
assign d_rc_op = lsq_deq_op[lsq_r_ptr];
assign d_rc_set = lsq_deq_set[lsq_r_ptr];
assign d_rc_way = lsq_deq_way[lsq_r_ptr];
assign d_rc_offset = lsq_deq_offset[lsq_r_ptr];
assign d_rc_wbuf_id = lsq_deq_wbuf_id[lsq_r_ptr];

assign u_htu_crdt_valid = lsq_deq_confirm;
assign u_htu_crdt_id = {d_rc_way, d_rc_set};

generate
    for (genvar i = 0; i < int'(Cfg.u.lsqSize);i++)
    begin: lsq_deq_real_sel_gen
        assign lsq_deq_real_sel[i] = lsq_deq_real_valid[i] & lsq_r_ptr == i;
    end
endgenerate


rob_id_gen # (
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
) u_rob_id_gen (
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .u_valid                           (rob_id_gen_valid          ),
    .u_channel_1hot_id                 (u_htu_channel_1hot_id     ),
    .d_isu_rob_id                      (rob_id                    )
);

credit_manager # (
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
) u_credit_manager (
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .u_htu_valid                       (u_htu_hsked               ),
    .u_htu_channel_1hot_id             (u_htu_channel_1hot_id     ),
    .u_htu_op                          (u_htu_op                  ),
    .lsq_w_ptr                         (lsq_w_ptr                 ),
    .lsq_btm_ptr                       (lsq_btm_ptr               ),
    .lsq_entry_vld                     (lsq_entry_vld             ),
    .lsq_entry_channel_id              (lsq_entry_channel_id      ),
    .entry_can_execute                 (entry_can_execute         ),
    .u_xbar_crdt_rtn                   (u_xbar_crdt_rtn           )
);

lsq_ptr_gen # (
    .SRB_DEPTH                         (Cfg.u.lsqSize             )
) u_lsq_ptr_gen (
    .clk                               (clk                       ),    
    .rst_n                             (rst_n                     ),
    .w_req_valid                       (u_htu_hsked               ),
    .r_req_valid                       (lsq_deq_confirm           ),
    .r_req_ptr                         (lsq_r_ptr                 ),
    .entry_valid                       (lsq_entry_vld             ),
    .bottom_ptr                        (lsq_btm_ptr               ),
    .w_ptr                             (lsq_w_ptr                 )

);

ns_gnrl_weight_with_ref # (
    Cfg.u.lsqSize
) u_oldest_deq_lsq_entry (
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .grt_id                            (lsq_r_ptr                 ),
    .req_vec                           (lsq_deq_vld               ),
    .ref_weight                        (lsq_btm_ptr               )
);

generate
    for (genvar i = 0; i < int'(Cfg.u.lsqSize); i++) 
    begin: lsq_entry_gen
        lsq_entry # (
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
        ) u_lsq_entry (
            .clk                               (clk                       ),
            .rst_n                             (rst_n                     ),
            .enq_valid                         (u_htu_hsked & lsq_w_ptr == i),
            .enq_ready                         (lsq_entry_rdy[i]          ),
            .enq_inflight_flg                  (u_inflight_flg            ),
            .enq_channel_1hot_id               (u_htu_channel_1hot_id     ),
            .enq_rob_id                        (rob_id                    ),
            .enq_op                            (u_htu_op                  ),
            .enq_set                           (u_htu_set                 ),
            .enq_way                           (u_htu_way                 ),
            .enq_offset                        (u_htu_offset              ),
            .enq_wbuf_id                       (u_htu_wbuf_id             ),
            .memctl_refill_valid               (memctl_refill_valid       ),
            .memctl_refill_way                 (memctl_refill_way         ),
            .memctl_refill_set                 (memctl_refill_set         ),
            .status_valid                      (lsq_entry_vld[i]          ),
            .status_channel_id                 (lsq_entry_channel_id[i]   ),
            .entry_can_execute                 (entry_can_execute[i]      ),
            .deq_valid                         (lsq_deq_vld[i]            ),
            .deq_ready                         (d_rc_ready & lsq_r_ptr == i),
            .deq_real_valid                    (lsq_deq_real_valid[i]     ),
            .deq_channel_1hot_id               (lsq_deq_channel_1hot_id[i]),
            .deq_rob_id                        (lsq_deq_rob_id[i]         ),
            .deq_op                            (lsq_deq_op[i]             ),
            .deq_set                           (lsq_deq_set[i]            ),
            .deq_way                           (lsq_deq_way[i]            ),
            .deq_offset                        (lsq_deq_offset[i]         ),
            .deq_wbuf_id                       (lsq_deq_wbuf_id[i]        )
        );
    end
endgenerate

endmodule