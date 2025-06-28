module xbar_wrapper
    import mpc_types::*;
#(
    parameter mpc_cfg_t Cfg = '0,
    parameter type opWidth_t       = logic,
    parameter type dataWidth_t     = logic,
    parameter type addrWidth_t     = logic,   
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
    parameter type kobWidth_t      = logic,
    parameter type channel_req_t   = logic,
    parameter type bank_req_t      = logic
)
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        u_channel_0_req_bus_valid  ,
    output logic                        u_channel_0_req_bus_ready  ,
    input  channel_req_t                u_channel_0_req_bus        ,

    input  logic                        u_channel_1_req_bus_valid  ,
    output logic                        u_channel_1_req_bus_ready  ,
    input  channel_req_t                u_channel_1_req_bus        ,

    input  logic                        u_channel_2_req_bus_valid  ,
    output logic                        u_channel_2_req_bus_ready  ,
    input  channel_req_t                u_channel_2_req_bus        ,

    output logic                        u_channel_0_rsp_bus_valid  ,
    input  logic                        u_channel_0_rsp_bus_ready  ,
    output logic          [127: 0]      u_channel_0_rsp_bus_rdata  ,

    output logic                        u_channel_1_rsp_bus_valid  ,
    input  logic                        u_channel_1_rsp_bus_ready  ,
    output logic          [127: 0]      u_channel_1_rsp_bus_rdata  , 

    output logic                        u_channel_2_rsp_bus_valid  ,
    input  logic                        u_channel_2_rsp_bus_ready  ,
    output logic          [127: 0]      u_channel_2_rsp_bus_rdata  ,

    output logic                        d_bank_0_htu_valid         ,
    input  logic                        d_bank_0_htu_ready         ,
    output bank_req_t                   d_bank_0_htu_req           ,
    output wbufWidth_t                  d_bank_0_htu_req_wbuf_id   ,

    output logic                        d_bank_1_htu_valid         ,
    input  logic                        d_bank_1_htu_ready         ,
    output bank_req_t                   d_bank_1_htu_req           ,
    output wbufWidth_t                  d_bank_1_htu_req_wbuf_id   ,

    output logic                        d_bank_2_htu_valid         ,
    input  logic                        d_bank_2_htu_ready         ,
    output bank_req_t                   d_bank_2_htu_req           ,
    output wbufWidth_t                  d_bank_2_htu_req_wbuf_id   ,

    output logic                        d_bank_3_htu_valid         ,
    input  logic                        d_bank_3_htu_ready         ,
    output bank_req_t                   d_bank_3_htu_req           ,
    output wbufWidth_t                  d_bank_3_htu_req_wbuf_id   ,

    output logic                        d_bank_0_wbuf_req_valid    ,
    output wbuf_req_t                   d_bank_0_wbuf_req          ,
    input  logic                        d_bank_0_wbuf_rsp_free_valid,
    input  wbufWidth_t                  d_bank_0_wbuf_rsp_free_id  ,

    output logic                        d_bank_1_wbuf_req_valid    ,
    output wbuf_req_t                   d_bank_1_wbuf_req          ,
    input  logic                        d_bank_1_wbuf_rsp_free_valid,
    input  wbufWidth_t                  d_bank_1_wbuf_rsp_free_id  ,

    output logic                        d_bank_2_wbuf_req_valid    ,
    output wbuf_req_t                   d_bank_2_wbuf_req          ,
    input  logic                        d_bank_2_wbuf_rsp_free_valid,
    input  wbufWidth_t                  d_bank_2_wbuf_rsp_free_id  ,

    output logic                        d_bank_3_wbuf_req_valid    ,
    output wbuf_req_t                   d_bank_3_wbuf_req          ,
    input  logic                        d_bank_3_wbuf_rsp_free_valid,
    input  wbufWidth_t                  d_bank_3_wbuf_rsp_free_id  ,

    input  logic                        d_bank_0_rsp_valid         ,
    output logic                        d_bank_0_rsp_ready         ,
    input  logic         [127: 0]       d_bank_0_rsp_data          ,
    input  robWidth_t                   d_bank_0_rsp_rob_id        ,
    input  logic         [  1: 0]       d_bank_0_rsp_channel_id    ,
    
    input  logic                        d_bank_1_rsp_valid         ,
    output logic                        d_bank_1_rsp_ready         ,
    input  logic         [127: 0]       d_bank_1_rsp_data          ,
    input  robWidth_t                   d_bank_1_rsp_rob_id        ,
    input  logic         [  1: 0]       d_bank_1_rsp_channel_id    ,

    input  logic                        d_bank_2_rsp_valid          ,
    output logic                        d_bank_2_rsp_ready          ,
    input  logic         [127: 0]       d_bank_2_rsp_data           ,
    input  robWidth_t                   d_bank_2_rsp_rob_id         ,
    input  logic         [  1: 0]       d_bank_2_rsp_channel_id     ,

    input  logic                        d_bank_3_rsp_valid          ,
    output logic                        d_bank_3_rsp_ready          ,
    input  logic         [127: 0]       d_bank_3_rsp_data           ,
    input  robWidth_t                   d_bank_3_rsp_rob_id         ,
    input  logic         [  1: 0]       d_bank_3_rsp_channel_id     ,

    output logic         [  2: 0]       d_bank_0_crdt_rtn           ,
    output logic         [  2: 0]       d_bank_1_crdt_rtn           ,
    output logic         [  2: 0]       d_bank_2_crdt_rtn           ,
    output logic         [  2: 0]       d_bank_3_crdt_rtn                              

);

/** 1. req xbar core */

logic                        u_channel_0_req_valid                 ;
logic                        u_channel_0_req_ready                 ;
channel_req_t                u_channel_0_req                       ;
logic                        u_channel_1_req_valid                 ;
logic                        u_channel_1_req_ready                 ;
channel_req_t                u_channel_1_req                       ;
logic                        u_channel_2_req_valid                 ;
logic                        u_channel_2_req_ready                 ;
channel_req_t                u_channel_2_req                       ;

logic       d_bank_0_req_valid                                     ;
logic       d_bank_0_req_ready                                     ;
bank_req_t  d_bank_0_req                                           ;
wbufWidth_t d_bank_0_req_wbuf_id                                   ;
logic       d_bank_1_req_valid                                     ;
logic       d_bank_1_req_ready                                     ;
bank_req_t  d_bank_1_req                                           ;
wbufWidth_t d_bank_1_req_wbuf_id                                   ;
logic       d_bank_2_req_valid                                     ;
logic       d_bank_2_req_ready                                     ;
bank_req_t  d_bank_2_req                                           ;
wbufWidth_t d_bank_2_req_wbuf_id                                   ;
logic       d_bank_3_req_valid                                     ;
logic       d_bank_3_req_ready                                     ;
bank_req_t  d_bank_3_req                                           ;
wbufWidth_t d_bank_3_req_wbuf_id                                   ;

logic       d_bank_0_wbuf_req_ready                                ;
logic       d_bank_1_wbuf_req_ready                                ;
logic       d_bank_2_wbuf_req_ready                                ;
logic       d_bank_3_wbuf_req_ready                                ;

logic       ch_0_kob_full                                          ;
logic       ch_1_kob_full                                          ;
logic       ch_2_kob_full                                          ;

assign u_channel_0_req_valid     = u_channel_0_req_bus_valid;
assign u_channel_0_req_bus_ready = u_channel_0_req_ready & !ch_0_kob_full; 
assign u_channel_0_req           = u_channel_0_req_bus;

assign u_channel_1_req_valid     = u_channel_1_req_bus_valid;
assign u_channel_1_req_bus_ready = u_channel_1_req_ready & !ch_1_kob_full; 
assign u_channel_1_req           = u_channel_1_req_bus;

assign u_channel_2_req_valid     = u_channel_2_req_bus_valid;
assign u_channel_2_req_bus_ready = u_channel_2_req_ready & !ch_2_kob_full; 
assign u_channel_2_req           = u_channel_2_req_bus;

xbar_core # (
    .Cfg                               (Cfg                                ),
    .setWidth_t                        (setWidth_t                         ),
    .tagWidth_t                        (tagWidth_t                         ),
    .wayIndexWidth_t                   (wayIndexWidth_t                    ),
    .wbufWidth_t                       (wbufWidth_t                        ),
    .wayNum_t                          (wayNum_t                           ),
    .nlineWidth_t                      (nlineWidth_t                       ),
    .offsetWidth_t                     (offsetWidth_t                      ),
    .metaWidth_t                       (metaWidth_t                        ),
    .channel_req_t                     (channel_req_t                      ),
    .bank_req_t                        (bank_req_t                         )
) u_xbar_core (
    .*
);

wbuf_id_gen # (
    .Cfg                               (Cfg                                ),
    .setWidth_t                        (setWidth_t                         ),
    .tagWidth_t                        (tagWidth_t                         ),
    .wayIndexWidth_t                   (wayIndexWidth_t                    ),
    .wbufWidth_t                       (wbufWidth_t                        ),
    .wayNum_t                          (wayNum_t                           ),
    .nlineWidth_t                      (nlineWidth_t                       ),
    .offsetWidth_t                     (offsetWidth_t                      ),
    .metaWidth_t                       (metaWidth_t                        )
) u_wbuf_id_gen_bank_0 (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .alloc_valid                       (d_bank_0_req_valid & d_bank_0_htu_ready),
    .alloc_ready                       (d_bank_0_wbuf_req_ready            ),
    .alloc_id                          (d_bank_0_req_wbuf_id               ),
    .free_valid                        (d_bank_0_wbuf_rsp_free_valid       ),
    .free_id                           (d_bank_0_wbuf_rsp_free_id          )
);

wbuf_id_gen # (
    .Cfg                               (Cfg                                ),
    .setWidth_t                        (setWidth_t                         ),
    .tagWidth_t                        (tagWidth_t                         ),
    .wayIndexWidth_t                   (wayIndexWidth_t                    ),
    .wbufWidth_t                       (wbufWidth_t                        ),
    .wayNum_t                          (wayNum_t                           ),
    .nlineWidth_t                      (nlineWidth_t                       ),
    .offsetWidth_t                     (offsetWidth_t                      ),
    .metaWidth_t                       (metaWidth_t                        )
) u_wbuf_id_gen_bank_1 (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .alloc_valid                       (d_bank_1_req_valid & d_bank_1_htu_ready),
    .alloc_ready                       (d_bank_1_wbuf_req_ready            ),
    .alloc_id                          (d_bank_1_req_wbuf_id               ),
    .free_valid                        (d_bank_1_wbuf_rsp_free_valid       ),
    .free_id                           (d_bank_1_wbuf_rsp_free_id          )
);

wbuf_id_gen # (
    .Cfg                               (Cfg                                ),
    .setWidth_t                        (setWidth_t                         ),
    .tagWidth_t                        (tagWidth_t                         ),
    .wayIndexWidth_t                   (wayIndexWidth_t                    ),
    .wbufWidth_t                       (wbufWidth_t                        ),
    .wayNum_t                          (wayNum_t                           ),
    .nlineWidth_t                      (nlineWidth_t                       ),
    .offsetWidth_t                     (offsetWidth_t                      ),
    .metaWidth_t                       (metaWidth_t                        )
) u_wbuf_id_gen_bank_2 (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .alloc_valid                       (d_bank_2_req_valid & d_bank_2_htu_ready),
    .alloc_ready                       (d_bank_2_wbuf_req_ready            ),
    .alloc_id                          (d_bank_2_req_wbuf_id               ),
    .free_valid                        (d_bank_2_wbuf_rsp_free_valid       ),
    .free_id                           (d_bank_2_wbuf_rsp_free_id          )
);

wbuf_id_gen # (
    .Cfg                               (Cfg                                ),
    .setWidth_t                        (setWidth_t                         ),
    .tagWidth_t                        (tagWidth_t                         ),
    .wayIndexWidth_t                   (wayIndexWidth_t                    ),
    .wbufWidth_t                       (wbufWidth_t                        ),
    .wayNum_t                          (wayNum_t                           ),
    .nlineWidth_t                      (nlineWidth_t                       ),
    .offsetWidth_t                     (offsetWidth_t                      ),
    .metaWidth_t                       (metaWidth_t                        )
) u_wbuf_id_gen_bank_3 (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .alloc_valid                       (d_bank_3_req_valid & d_bank_3_htu_ready),
    .alloc_ready                       (d_bank_3_wbuf_req_ready            ),
    .alloc_id                          (d_bank_3_req_wbuf_id               ),
    .free_valid                        (d_bank_3_wbuf_rsp_free_valid       ),
    .free_id                           (d_bank_3_wbuf_rsp_free_id          )
);

assign d_bank_0_req_ready = d_bank_0_htu_ready & d_bank_0_wbuf_req_ready;
assign d_bank_0_htu_valid = d_bank_0_req_valid & d_bank_0_wbuf_req_ready;

assign d_bank_1_req_ready = d_bank_1_htu_ready & d_bank_1_wbuf_req_ready;
assign d_bank_1_htu_valid = d_bank_1_req_valid & d_bank_1_wbuf_req_ready;

assign d_bank_2_req_ready = d_bank_2_htu_ready & d_bank_2_wbuf_req_ready;
assign d_bank_2_htu_valid = d_bank_2_req_valid & d_bank_2_wbuf_req_ready;

assign d_bank_3_req_ready = d_bank_3_htu_ready & d_bank_3_wbuf_req_ready;
assign d_bank_3_htu_valid = d_bank_3_req_valid & d_bank_3_wbuf_req_ready;

assign d_bank_0_htu_req = d_bank_0_req;
assign d_bank_1_htu_req = d_bank_1_req;
assign d_bank_2_htu_req = d_bank_2_req;
assign d_bank_3_htu_req = d_bank_3_req;

assign d_bank_0_htu_req_wbuf_id = d_bank_0_req_wbuf_id;
assign d_bank_1_htu_req_wbuf_id = d_bank_1_req_wbuf_id;
assign d_bank_2_htu_req_wbuf_id = d_bank_2_req_wbuf_id;
assign d_bank_3_htu_req_wbuf_id = d_bank_3_req_wbuf_id;

assign d_bank_0_wbuf_req_valid = d_bank_0_req_valid & d_bank_0_req_ready;
assign d_bank_1_wbuf_req_valid = d_bank_1_req_valid & d_bank_1_req_ready;
assign d_bank_2_wbuf_req_valid = d_bank_2_req_valid & d_bank_2_req_ready;
assign d_bank_3_wbuf_req_valid = d_bank_3_req_valid & d_bank_3_req_ready;

assign d_bank_0_wbuf_req.wbuf_id = d_bank_0_req_wbuf_id;
assign d_bank_1_wbuf_req.wbuf_id = d_bank_1_req_wbuf_id;
assign d_bank_2_wbuf_req.wbuf_id = d_bank_2_req_wbuf_id;
assign d_bank_3_wbuf_req.wbuf_id = d_bank_3_req_wbuf_id;

assign d_bank_0_wbuf_req.wdata = d_bank_0_req.wdata;
assign d_bank_1_wbuf_req.wdata = d_bank_1_req.wdata;
assign d_bank_2_wbuf_req.wdata = d_bank_2_req.wdata;
assign d_bank_3_wbuf_req.wdata = d_bank_3_req.wdata;


/** 2. rsp xbar core */

logic                        u_channel_0_rsp_valid                          ; 
logic                        u_channel_0_rsp_ready                          ; 
logic          [127: 0]      u_channel_0_rsp_data                           ; 
logic          [  1: 0]      u_channel_0_rsp_bank_id                        ; 
robWidth_t                   u_channel_0_rsp_rob_id                         ; 

logic                        u_channel_1_rsp_valid                          ;
logic                        u_channel_1_rsp_ready                          ;
logic          [127: 0]      u_channel_1_rsp_data                           ;
logic          [  1: 0]      u_channel_1_rsp_bank_id                        ;
robWidth_t                   u_channel_1_rsp_rob_id                         ;

logic                        u_channel_2_rsp_valid                          ;
logic                        u_channel_2_rsp_ready                          ;
logic          [127: 0]      u_channel_2_rsp_data                           ;
logic          [  1: 0]      u_channel_2_rsp_bank_id                        ;
robWidth_t                   u_channel_2_rsp_rob_id                         ;



rtn_xbar_core # (
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
) u_rtn_xbar_core (
    .*
);

assign u_channel_0_rsp_ready = 'd1;
assign u_channel_1_rsp_ready = 'd1;
assign u_channel_2_rsp_ready = 'd1;

/** 3. rob **/

logic        [  2: 0]        kob_rob_req                                    ;    
logic        [  2: 0]        kob_rob_ack                                    ;  
logic        [  1: 0]        kob_rob_bank_id   [  2: 0]                     ;

logic        [  2: 0]        u_ch_valid                                     ;
logic        [127: 0]        u_ch_data         [  2: 0]                     ;

logic        [  2: 0]        d_bank_0_crdt_rtn_oh                           ;
logic        [  2: 0]        d_bank_1_crdt_rtn_oh                           ;
logic        [  2: 0]        d_bank_2_crdt_rtn_oh                           ;
logic        [  2: 0]        d_bank_3_crdt_rtn_oh                           ;

kob # (
    .Cfg                               (Cfg                                ),
    .setWidth_t                        (setWidth_t                         ),
    .tagWidth_t                        (tagWidth_t                         ),
    .wayIndexWidth_t                   (wayIndexWidth_t                    ),
    .wbufWidth_t                       (wbufWidth_t                        ),
    .wayNum_t                          (wayNum_t                           ),
    .nlineWidth_t                      (nlineWidth_t                       ),
    .offsetWidth_t                     (offsetWidth_t                      ),
    .metaWidth_t                       (metaWidth_t                        ),
    .kobWidth_t                        (kobWidth_t                         ),
    .channel_req_t                     (channel_req_t                      )
) u_kob (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    
    .u_channel_0_req_valid             (u_channel_0_req_valid              ),
    .u_channel_0_req_ready             (u_channel_0_req_ready              ),
    .u_channel_0_req                   (u_channel_0_req                    ),
    .u_channel_1_req_valid             (u_channel_1_req_valid              ),
    .u_channel_1_req_ready             (u_channel_1_req_ready              ),
    .u_channel_1_req                   (u_channel_1_req                    ),
    .u_channel_2_req_valid             (u_channel_2_req_valid              ),
    .u_channel_2_req_ready             (u_channel_2_req_ready              ),
    .u_channel_2_req                   (u_channel_2_req                    ),
    
    .d_ch_0_rob_req                    (kob_rob_req[0]                     ),
    .d_ch_0_rob_ack                    (kob_rob_ack[0]                     ),
    .d_ch_0_rob_bank_id                (kob_rob_bank_id[0]                 ),
    .d_ch_1_rob_req                    (kob_rob_req[1]                     ),
    .d_ch_1_rob_ack                    (kob_rob_ack[1]                     ),
    .d_ch_1_rob_bank_id                (kob_rob_bank_id[1]                 ),
    .d_ch_2_rob_req                    (kob_rob_req[2]                     ),
    .d_ch_2_rob_ack                    (kob_rob_ack[2]                     ),
    .d_ch_2_rob_bank_id                (kob_rob_bank_id[2]                 ),
    .ch_0_kob_full                     (ch_0_kob_full                      ),
    .ch_1_kob_full                     (ch_1_kob_full                      ),
    .ch_2_kob_full                     (ch_2_kob_full                      )
);

rob_wrapper # (
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
) u_rob_wrapper_ch_0 (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .u_kob_rob_req                     (kob_rob_req[0]                     ),
    .u_kob_rob_ack                     (kob_rob_ack[0]                     ),
    .u_kob_rob_bank_id                 (kob_rob_bank_id[0]                 ),
    .d_rc_valid                        (u_channel_0_rsp_valid              ),
    .d_rc_rob_id                       (u_channel_0_rsp_rob_id             ),
    .d_rc_data                         (u_channel_0_rsp_data               ),
    .d_rc_bank_id                      (u_channel_0_rsp_bank_id            ),
    .u_ch_valid                        (u_ch_valid[0]                      ),
    .u_ch_ready                        (u_channel_0_rsp_bus_ready          ),
    .u_ch_data                         (u_ch_data[0]                       ),
    .d_bank_0_crdt_rtn                 (d_bank_0_crdt_rtn_oh[0]            ),                 
    .d_bank_1_crdt_rtn                 (d_bank_1_crdt_rtn_oh[0]            ),
    .d_bank_2_crdt_rtn                 (d_bank_2_crdt_rtn_oh[0]            ),
    .d_bank_3_crdt_rtn                 (d_bank_3_crdt_rtn_oh[0]            )
);  

rob_wrapper # (
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
) u_rob_wrapper_ch_1 (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .u_kob_rob_req                     (kob_rob_req[1]                     ),
    .u_kob_rob_ack                     (kob_rob_ack[1]                     ),
    .u_kob_rob_bank_id                 (kob_rob_bank_id[1]                 ),
    .d_rc_valid                        (u_channel_1_rsp_valid              ),
    .d_rc_rob_id                       (u_channel_1_rsp_rob_id             ),
    .d_rc_data                         (u_channel_1_rsp_data               ),
    .d_rc_bank_id                      (u_channel_1_rsp_bank_id            ),
    .u_ch_valid                        (u_ch_valid[1]                      ),
    .u_ch_ready                        (u_channel_1_rsp_bus_ready          ),
    .u_ch_data                         (u_ch_data[1]                       ),
    .d_bank_0_crdt_rtn                 (d_bank_0_crdt_rtn_oh[1]            ),
    .d_bank_1_crdt_rtn                 (d_bank_1_crdt_rtn_oh[1]            ),
    .d_bank_2_crdt_rtn                 (d_bank_2_crdt_rtn_oh[1]            ),
    .d_bank_3_crdt_rtn                 (d_bank_3_crdt_rtn_oh[1]            )
);  

rob_wrapper # (
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
) u_rob_wrapper_ch_2 (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .u_kob_rob_req                     (kob_rob_req[2]                     ),
    .u_kob_rob_ack                     (kob_rob_ack[2]                     ),
    .u_kob_rob_bank_id                 (kob_rob_bank_id[2]                 ),
    .d_rc_valid                        (u_channel_2_rsp_valid              ),
    .d_rc_rob_id                       (u_channel_2_rsp_rob_id             ),
    .d_rc_data                         (u_channel_2_rsp_data               ),
    .d_rc_bank_id                      (u_channel_2_rsp_bank_id            ),
    .u_ch_valid                        (u_ch_valid[2]                      ),
    .u_ch_ready                        (u_channel_2_rsp_bus_ready          ),
    .u_ch_data                         (u_ch_data[2]                       ),
    .d_bank_0_crdt_rtn                 (d_bank_0_crdt_rtn_oh[2]            ),
    .d_bank_1_crdt_rtn                 (d_bank_1_crdt_rtn_oh[2]            ),
    .d_bank_2_crdt_rtn                 (d_bank_2_crdt_rtn_oh[2]            ),
    .d_bank_3_crdt_rtn                 (d_bank_3_crdt_rtn_oh[2]            )
);

assign d_bank_0_crdt_rtn = d_bank_0_crdt_rtn_oh;
assign d_bank_1_crdt_rtn = d_bank_1_crdt_rtn_oh;
assign d_bank_2_crdt_rtn = d_bank_2_crdt_rtn_oh;
assign d_bank_3_crdt_rtn = d_bank_3_crdt_rtn_oh;

assign u_channel_0_rsp_bus_valid = u_ch_valid[0];
assign u_channel_0_rsp_bus_rdata = u_ch_data[0];
assign u_channel_1_rsp_bus_valid = u_ch_valid[1];
assign u_channel_1_rsp_bus_rdata = u_ch_data[1];
assign u_channel_2_rsp_bus_valid = u_ch_valid[2];
assign u_channel_2_rsp_bus_rdata = u_ch_data[2];


endmodule