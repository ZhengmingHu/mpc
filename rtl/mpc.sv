module mpc 
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
    parameter type rfbufWidth_t    = logic,
    parameter type kobWidth_t      = logic,
    parameter type mcWidth_t       = logic,

    parameter type channel_req_t   = logic,
    parameter type bank_req_t      = logic
)(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    // upstream req from 3 channels
    input  logic                        u_channel_0_req_bus_valid  ,
    output logic                        u_channel_0_req_bus_ready  ,
    input  channel_req_t                u_channel_0_req_bus        ,
    
    input  logic                        u_channel_1_req_bus_valid  ,
    output logic                        u_channel_1_req_bus_ready  ,
    input  channel_req_t                u_channel_1_req_bus        ,
    
    input  logic                        u_channel_2_req_bus_valid  ,
    output logic                        u_channel_2_req_bus_ready  ,
    input  channel_req_t                u_channel_2_req_bus        ,

    // upstream rsp to 3 channels
    output logic                        u_channel_0_rsp_bus_valid  ,
    input  logic                        u_channel_0_rsp_bus_ready  ,
    output logic          [127: 0]      u_channel_0_rsp_bus_rdata  ,
    
    output logic                        u_channel_1_rsp_bus_valid  ,
    input  logic                        u_channel_1_rsp_bus_ready  ,
    output logic          [127: 0]      u_channel_1_rsp_bus_rdata  ,
    
    output logic                        u_channel_2_rsp_bus_valid  ,
    input  logic                        u_channel_2_rsp_bus_ready  ,
    output logic          [127: 0]      u_channel_2_rsp_bus_rdata  ,

    // Master AXI AW Channel
    input  logic                        slice_0_m_axi_awready      ,
    output logic                        slice_0_m_axi_awvalid      ,
    output nlineWidth_t                 slice_0_m_axi_awid         ,
    output logic           [ 31: 0]     slice_0_m_axi_awaddr       ,
    output logic           [  7: 0]     slice_0_m_axi_awlen        ,
    output logic           [  2: 0]     slice_0_m_axi_awsize       ,
    output logic           [  1: 0]     slice_0_m_axi_awburst      ,
    
    // Master AXI W Channel
    input  logic                        slice_0_m_axi_wready       ,
    output logic                        slice_0_m_axi_wvalid       ,
    output logic           [255: 0]     slice_0_m_axi_wdata        ,
    output logic           [ 31: 0]     slice_0_m_axi_wstrb        ,
    output logic                        slice_0_m_axi_wlast        ,
    output logic                        slice_0_m_axi_bready       ,
    input  logic                        slice_0_m_axi_bvalid       ,
    input  nlineWidth_t                 slice_0_m_axi_bid          ,
    input  logic           [  1: 0]     slice_0_m_axi_bresp        ,

    // Master AXI AR Channel
    input  logic                        slice_0_m_axi_arready      ,
    output logic                        slice_0_m_axi_arvalid      ,
    output nlineWidth_t                 slice_0_m_axi_arid         ,
    output logic           [ 31: 0]     slice_0_m_axi_araddr       ,
    output logic           [  7: 0]     slice_0_m_axi_arlen        ,
    output logic           [  2: 0]     slice_0_m_axi_arsize       ,
    output logic           [  1: 0]     slice_0_m_axi_arburst      ,

    // Master AXI R Channel
    output logic                        slice_0_m_axi_rready       ,
    input  logic                        slice_0_m_axi_rvalid       ,
    input  nlineWidth_t                 slice_0_m_axi_rid          ,
    input  logic           [255: 0]     slice_0_m_axi_rdata        ,
    input  logic           [  1: 0]     slice_0_m_axi_rresp        ,
    input  logic                        slice_0_m_axi_rlast        ,
    
    input  logic                        slice_1_m_axi_awready      ,
    output logic                        slice_1_m_axi_awvalid      ,
    output nlineWidth_t                 slice_1_m_axi_awid         ,
    output logic           [ 31: 0]     slice_1_m_axi_awaddr       ,
    output logic           [  7: 0]     slice_1_m_axi_awlen        ,
    output logic           [  2: 0]     slice_1_m_axi_awsize       ,
    output logic           [  1: 0]     slice_1_m_axi_awburst      ,

    input  logic                        slice_1_m_axi_wready       ,
    output logic                        slice_1_m_axi_wvalid       ,
    output logic           [255: 0]     slice_1_m_axi_wdata        ,
    output logic           [ 31: 0]     slice_1_m_axi_wstrb        ,
    output logic                        slice_1_m_axi_wlast        ,
    output logic                        slice_1_m_axi_bready       ,
    input  logic                        slice_1_m_axi_bvalid       ,
    input  nlineWidth_t                 slice_1_m_axi_bid          ,
    input  logic           [  1: 0]     slice_1_m_axi_bresp        ,

    input  logic                        slice_1_m_axi_arready      ,
    output logic                        slice_1_m_axi_arvalid      ,
    output nlineWidth_t                 slice_1_m_axi_arid         ,
    output logic           [ 31: 0]     slice_1_m_axi_araddr       ,
    output logic           [  7: 0]     slice_1_m_axi_arlen        ,
    output logic           [  2: 0]     slice_1_m_axi_arsize       ,
    output logic           [  1: 0]     slice_1_m_axi_arburst      ,

    output logic                        slice_1_m_axi_rready       ,
    input  logic                        slice_1_m_axi_rvalid       ,
    input  nlineWidth_t                 slice_1_m_axi_rid          ,
    input  logic           [255: 0]     slice_1_m_axi_rdata        ,
    input  logic           [  1: 0]     slice_1_m_axi_rresp        ,
    input  logic                        slice_1_m_axi_rlast        ,

    input  logic                        slice_2_m_axi_awready      ,
    output logic                        slice_2_m_axi_awvalid      ,
    output nlineWidth_t                 slice_2_m_axi_awid         ,
    output logic           [ 31: 0]     slice_2_m_axi_awaddr       ,
    output logic           [  7: 0]     slice_2_m_axi_awlen        ,
    output logic           [  2: 0]     slice_2_m_axi_awsize       ,
    output logic           [  1: 0]     slice_2_m_axi_awburst      ,

    input  logic                        slice_2_m_axi_wready       ,
    output logic                        slice_2_m_axi_wvalid       ,
    output logic           [255: 0]     slice_2_m_axi_wdata        ,
    output logic           [ 31: 0]     slice_2_m_axi_wstrb        ,
    output logic                        slice_2_m_axi_wlast        ,
    
    output logic                        slice_2_m_axi_bready       ,
    input  logic                        slice_2_m_axi_bvalid       ,
    input  nlineWidth_t                 slice_2_m_axi_bid          ,
    input  logic           [  1: 0]     slice_2_m_axi_bresp        ,
    
    input  logic                        slice_2_m_axi_arready      ,
    output logic                        slice_2_m_axi_arvalid      ,
    output nlineWidth_t                 slice_2_m_axi_arid         ,
    output logic           [ 31: 0]     slice_2_m_axi_araddr       ,
    output logic           [  7: 0]     slice_2_m_axi_arlen        ,
    output logic           [  2: 0]     slice_2_m_axi_arsize       ,
    output logic           [  1: 0]     slice_2_m_axi_arburst      ,
    
    output logic                        slice_2_m_axi_rready       ,
    input  logic                        slice_2_m_axi_rvalid       ,
    input  nlineWidth_t                 slice_2_m_axi_rid          ,
    input  logic           [255: 0]     slice_2_m_axi_rdata        ,
    input  logic           [  1: 0]     slice_2_m_axi_rresp        ,
    input  logic                        slice_2_m_axi_rlast        ,

    input  logic                        slice_3_m_axi_awready      ,
    output logic                        slice_3_m_axi_awvalid      ,
    output nlineWidth_t                 slice_3_m_axi_awid         ,
    output logic           [ 31: 0]     slice_3_m_axi_awaddr       ,
    output logic           [  7: 0]     slice_3_m_axi_awlen        ,
    output logic           [  2: 0]     slice_3_m_axi_awsize       ,
    output logic           [  1: 0]     slice_3_m_axi_awburst      ,

    input  logic                        slice_3_m_axi_wready       ,
    output logic                        slice_3_m_axi_wvalid       ,
    output logic           [255: 0]     slice_3_m_axi_wdata        ,
    output logic           [ 31: 0]     slice_3_m_axi_wstrb        ,
    output logic                        slice_3_m_axi_wlast        ,

    output logic                        slice_3_m_axi_bready       ,
    input  logic                        slice_3_m_axi_bvalid       ,
    input  nlineWidth_t                 slice_3_m_axi_bid          ,
    input  logic           [  1: 0]     slice_3_m_axi_bresp        ,
    
    input  logic                        slice_3_m_axi_arready      ,
    output logic                        slice_3_m_axi_arvalid      ,
    output nlineWidth_t                 slice_3_m_axi_arid         ,
    output logic           [ 31: 0]     slice_3_m_axi_araddr       ,
    output logic           [  7: 0]     slice_3_m_axi_arlen        ,
    output logic           [  2: 0]     slice_3_m_axi_arsize       ,
    output logic           [  1: 0]     slice_3_m_axi_arburst      ,
    
    output logic                        slice_3_m_axi_rready       ,
    input  logic                        slice_3_m_axi_rvalid       ,
    input  nlineWidth_t                 slice_3_m_axi_rid          ,
    input  logic           [255: 0]     slice_3_m_axi_rdata        ,
    input  logic           [  1: 0]     slice_3_m_axi_rresp        ,
    input  logic                        slice_3_m_axi_rlast        

);

logic                        bank_0_htu_valid          ;
logic                        bank_0_htu_ready          ;
bank_req_t                   bank_0_htu_req            ;
wbufWidth_t                  bank_0_htu_req_wbuf_id    ;
logic                        bank_1_htu_valid          ;
logic                        bank_1_htu_ready          ;
bank_req_t                   bank_1_htu_req            ;
wbufWidth_t                  bank_1_htu_req_wbuf_id    ;
logic                        bank_2_htu_valid          ;
logic                        bank_2_htu_ready          ;
bank_req_t                   bank_2_htu_req            ;
wbufWidth_t                  bank_2_htu_req_wbuf_id    ;
logic                        bank_3_htu_valid          ;
logic                        bank_3_htu_ready          ;
bank_req_t                   bank_3_htu_req            ;
wbufWidth_t                  bank_3_htu_req_wbuf_id    ;
logic                        bank_0_wbuf_req_valid     ;
wbuf_req_t                   bank_0_wbuf_req           ;
logic                        bank_0_wbuf_rsp_free_valid;
wbufWidth_t                  bank_0_wbuf_rsp_free_id   ;
logic                        bank_1_wbuf_req_valid     ;
wbuf_req_t                   bank_1_wbuf_req           ;
logic                        bank_1_wbuf_rsp_free_valid;
wbufWidth_t                  bank_1_wbuf_rsp_free_id   ;
logic                        bank_2_wbuf_req_valid     ;
wbuf_req_t                   bank_2_wbuf_req           ;
logic                        bank_2_wbuf_rsp_free_valid;
wbufWidth_t                  bank_2_wbuf_rsp_free_id   ;
logic                        bank_3_wbuf_req_valid     ;
wbuf_req_t                   bank_3_wbuf_req           ;
logic                        bank_3_wbuf_rsp_free_valid;
wbufWidth_t                  bank_3_wbuf_rsp_free_id   ;
logic                        bank_0_rsp_valid          ;
logic                        bank_0_rsp_ready          ;
logic         [127: 0]       bank_0_rsp_data           ;
robWidth_t                   bank_0_rsp_rob_id         ;
logic         [  1: 0]       bank_0_rsp_channel_id     ;
logic                        bank_1_rsp_valid          ;
logic                        bank_1_rsp_ready          ;
logic         [127: 0]       bank_1_rsp_data           ;
robWidth_t                   bank_1_rsp_rob_id         ;
logic         [  1: 0]       bank_1_rsp_channel_id     ;
logic                        bank_2_rsp_valid          ;
logic                        bank_2_rsp_ready          ;
logic         [127: 0]       bank_2_rsp_data           ;
robWidth_t                   bank_2_rsp_rob_id         ;
logic         [  1: 0]       bank_2_rsp_channel_id     ;
logic                        bank_3_rsp_valid          ;
logic                        bank_3_rsp_ready          ;
logic         [127: 0]       bank_3_rsp_data           ;
robWidth_t                   bank_3_rsp_rob_id         ;
logic         [  1: 0]       bank_3_rsp_channel_id     ;
logic         [  2: 0]       bank_0_crdt_rtn           ;
logic         [  2: 0]       bank_1_crdt_rtn           ;
logic         [  2: 0]       bank_2_crdt_rtn           ;
logic         [  2: 0]       bank_3_crdt_rtn           ;

xbar_wrapper # (
    .Cfg                            (Cfg                        ),
    .opWidth_t                      (opWidth_t                  ),
    .dataWidth_t                    (dataWidth_t                ),
    .addrWidth_t                    (addrWidth_t                ),
    .setWidth_t                     (setWidth_t                 ),
    .tagWidth_t                     (tagWidth_t                 ),
    .wayIndexWidth_t                (wayIndexWidth_t            ),
    .wbufWidth_t                    (wbufWidth_t                ),
    .wayNum_t                       (wayNum_t                   ),
    .nlineWidth_t                   (nlineWidth_t               ),
    .offsetWidth_t                  (offsetWidth_t              ),
    .metaWidth_t                    (metaWidth_t                ),
    .robWidth_t                     (robWidth_t                 ),
    .lsqWidth_t                     (lsqWidth_t                 ),
    .kobWidth_t                     (kobWidth_t                 ),
    .channel_req_t                  (channel_req_t              ),
    .bank_req_t                     (bank_req_t                 )
) u_xbar_wrapper (              
    .clk                            (clk                        ),
    .rst_n                          (rst_n                      ),
    .u_channel_0_req_bus_valid      (u_channel_0_req_bus_valid  ),
    .u_channel_0_req_bus_ready      (u_channel_0_req_bus_ready  ),
    .u_channel_0_req_bus            (u_channel_0_req_bus        ),
    .u_channel_1_req_bus_valid      (u_channel_1_req_bus_valid  ),
    .u_channel_1_req_bus_ready      (u_channel_1_req_bus_ready  ),
    .u_channel_1_req_bus            (u_channel_1_req_bus        ),
    .u_channel_2_req_bus_valid      (u_channel_2_req_bus_valid  ),
    .u_channel_2_req_bus_ready      (u_channel_2_req_bus_ready  ),
    .u_channel_2_req_bus            (u_channel_2_req_bus        ),
    .u_channel_0_rsp_bus_valid      (u_channel_0_rsp_bus_valid  ),
    .u_channel_0_rsp_bus_ready      (u_channel_0_rsp_bus_ready  ),
    .u_channel_0_rsp_bus_rdata      (u_channel_0_rsp_bus_rdata  ),
    .u_channel_1_rsp_bus_valid      (u_channel_1_rsp_bus_valid  ),
    .u_channel_1_rsp_bus_ready      (u_channel_1_rsp_bus_ready  ),
    .u_channel_1_rsp_bus_rdata      (u_channel_1_rsp_bus_rdata  ),
    .u_channel_2_rsp_bus_valid      (u_channel_2_rsp_bus_valid  ),
    .u_channel_2_rsp_bus_ready      (u_channel_2_rsp_bus_ready  ),
    .u_channel_2_rsp_bus_rdata      (u_channel_2_rsp_bus_rdata  ),
    .d_bank_0_htu_valid             (bank_0_htu_valid           ),
    .d_bank_0_htu_ready             (bank_0_htu_ready           ),
    .d_bank_0_htu_req               (bank_0_htu_req             ),
    .d_bank_0_htu_req_wbuf_id       (bank_0_htu_req_wbuf_id     ),
    .d_bank_1_htu_valid             (bank_1_htu_valid           ),
    .d_bank_1_htu_ready             (bank_1_htu_ready           ),
    .d_bank_1_htu_req               (bank_1_htu_req             ),
    .d_bank_1_htu_req_wbuf_id       (bank_1_htu_req_wbuf_id     ),
    .d_bank_2_htu_valid             (bank_2_htu_valid           ),
    .d_bank_2_htu_ready             (bank_2_htu_ready           ),
    .d_bank_2_htu_req               (bank_2_htu_req             ),
    .d_bank_2_htu_req_wbuf_id       (bank_2_htu_req_wbuf_id     ),
    .d_bank_3_htu_valid             (bank_3_htu_valid           ),
    .d_bank_3_htu_ready             (bank_3_htu_ready           ),
    .d_bank_3_htu_req               (bank_3_htu_req             ),
    .d_bank_3_htu_req_wbuf_id       (bank_3_htu_req_wbuf_id     ),
    .d_bank_0_wbuf_req_valid        (bank_0_wbuf_req_valid      ),
    .d_bank_0_wbuf_req              (bank_0_wbuf_req            ),
    .d_bank_0_wbuf_rsp_free_valid   (bank_0_wbuf_rsp_free_valid ),
    .d_bank_0_wbuf_rsp_free_id      (bank_0_wbuf_rsp_free_id    ),    
    .d_bank_1_wbuf_req_valid        (bank_1_wbuf_req_valid      ),     
    .d_bank_1_wbuf_req              (bank_1_wbuf_req            ),        
    .d_bank_1_wbuf_rsp_free_valid   (bank_1_wbuf_rsp_free_valid ),
    .d_bank_1_wbuf_rsp_free_id      (bank_1_wbuf_rsp_free_id    ),   
    .d_bank_2_wbuf_req_valid        (bank_2_wbuf_req_valid      ),
    .d_bank_2_wbuf_req              (bank_2_wbuf_req            ),
    .d_bank_2_wbuf_rsp_free_valid   (bank_2_wbuf_rsp_free_valid ),
    .d_bank_2_wbuf_rsp_free_id      (bank_2_wbuf_rsp_free_id    ),   
    .d_bank_3_wbuf_req_valid        (bank_3_wbuf_req_valid      ),    
    .d_bank_3_wbuf_req              (bank_3_wbuf_req            ),    
    .d_bank_3_wbuf_rsp_free_valid   (bank_3_wbuf_rsp_free_valid ),
    .d_bank_3_wbuf_rsp_free_id      (bank_3_wbuf_rsp_free_id    ),   
    .d_bank_0_rsp_valid             (bank_0_rsp_valid           ),
    .d_bank_0_rsp_ready             (bank_0_rsp_ready           ),
    .d_bank_0_rsp_data              (bank_0_rsp_data            ),
    .d_bank_0_rsp_rob_id            (bank_0_rsp_rob_id          ),
    .d_bank_0_rsp_channel_id        (bank_0_rsp_channel_id      ),
    .d_bank_1_rsp_valid             (bank_1_rsp_valid           ),
    .d_bank_1_rsp_ready             (bank_1_rsp_ready           ),
    .d_bank_1_rsp_data              (bank_1_rsp_data            ),
    .d_bank_1_rsp_rob_id            (bank_1_rsp_rob_id          ),
    .d_bank_1_rsp_channel_id        (bank_1_rsp_channel_id      ),
    .d_bank_2_rsp_valid             (bank_2_rsp_valid           ),
    .d_bank_2_rsp_ready             (bank_2_rsp_ready           ),
    .d_bank_2_rsp_data              (bank_2_rsp_data            ),
    .d_bank_2_rsp_rob_id            (bank_2_rsp_rob_id          ),
    .d_bank_2_rsp_channel_id        (bank_2_rsp_channel_id      ),
    .d_bank_3_rsp_valid             (bank_3_rsp_valid           ),
    .d_bank_3_rsp_ready             (bank_3_rsp_ready           ),
    .d_bank_3_rsp_data              (bank_3_rsp_data            ),
    .d_bank_3_rsp_rob_id            (bank_3_rsp_rob_id          ),
    .d_bank_3_rsp_channel_id        (bank_3_rsp_channel_id      ),
    .d_bank_0_crdt_rtn              (bank_0_crdt_rtn            ),
    .d_bank_1_crdt_rtn              (bank_1_crdt_rtn            ),
    .d_bank_2_crdt_rtn              (bank_2_crdt_rtn            ),
    .d_bank_3_crdt_rtn              (bank_3_crdt_rtn            )
);

slice # (
    .Cfg                            (Cfg                        ),
    .opWidth_t                      (opWidth_t                  ),
    .dataWidth_t                    (dataWidth_t                ),
    .addrWidth_t                    (addrWidth_t                ),
    .setWidth_t                     (setWidth_t                 ),
    .tagWidth_t                     (tagWidth_t                 ),
    .wayIndexWidth_t                (wayIndexWidth_t            ),
    .wbufWidth_t                    (wbufWidth_t                ),
    .wayNum_t                       (wayNum_t                   ),
    .nlineWidth_t                   (nlineWidth_t               ),
    .offsetWidth_t                  (offsetWidth_t              ),
    .metaWidth_t                    (metaWidth_t                ),
    .robWidth_t                     (robWidth_t                 ),
    .lsqWidth_t                     (lsqWidth_t                 ),
    .rfbufWidth_t                   (rfbufWidth_t               ),
    .kobWidth_t                     (kobWidth_t                 ),
    .mcWidth_t                      (mcWidth_t                  ),
    .bank_req_t                     (bank_req_t                 )
) u_slice_0 (
    .clk                            (clk                        ),  
    .rst_n                          (rst_n                      ),  
    .u_bank_req_valid               (bank_0_htu_valid           ),  
    .u_bank_req_ready               (bank_0_htu_ready           ),  
    .u_bank_req                     (bank_0_htu_req             ),  
    .u_bank_req_wbuf_id             (bank_0_htu_req_wbuf_id     ),  
    .u_xbar_req_valid               (bank_0_wbuf_req_valid      ),  
    .u_xbar_req                     (bank_0_wbuf_req            ),  
    .u_xbar_rsp_free_valid          (bank_0_wbuf_rsp_free_valid ),  
    .u_xbar_rsp_free_id             (bank_0_wbuf_rsp_free_id    ),  
    .u_bank_rsp_valid               (bank_0_rsp_valid           ),  
    .u_bank_rsp_ready               (bank_0_rsp_ready           ),  
    .u_bank_rsp_rob_id              (bank_0_rsp_rob_id          ),  
    .u_bank_rsp_channel_id          (bank_0_rsp_channel_id      ),  
    .u_bank_rsp_data                (bank_0_rsp_data            ),  
    .u_xbar_crdt_rtn                (bank_0_crdt_rtn            ),  
    .m_axi_awready                  (slice_0_m_axi_awready      ),  
    .m_axi_awvalid                  (slice_0_m_axi_awvalid      ),  
    .m_axi_awid                     (slice_0_m_axi_awid         ),  
    .m_axi_awaddr                   (slice_0_m_axi_awaddr       ),  
    .m_axi_awlen                    (slice_0_m_axi_awlen        ),  
    .m_axi_awsize                   (slice_0_m_axi_awsize       ),  
    .m_axi_awburst                  (slice_0_m_axi_awburst      ),  
    .m_axi_wready                   (slice_0_m_axi_wready       ),  
    .m_axi_wvalid                   (slice_0_m_axi_wvalid       ),  
    .m_axi_wdata                    (slice_0_m_axi_wdata        ),  
    .m_axi_wstrb                    (slice_0_m_axi_wstrb        ),  
    .m_axi_wlast                    (slice_0_m_axi_wlast        ),  
    .m_axi_bready                   (slice_0_m_axi_bready       ),  
    .m_axi_bvalid                   (slice_0_m_axi_bvalid       ),  
    .m_axi_bid                      (slice_0_m_axi_bid          ),  
    .m_axi_bresp                    (slice_0_m_axi_bresp        ),  
    .m_axi_arready                  (slice_0_m_axi_arready      ),  
    .m_axi_arvalid                  (slice_0_m_axi_arvalid      ),  
    .m_axi_arid                     (slice_0_m_axi_arid         ),  
    .m_axi_araddr                   (slice_0_m_axi_araddr       ),  
    .m_axi_arlen                    (slice_0_m_axi_arlen        ),  
    .m_axi_arsize                   (slice_0_m_axi_arsize       ),  
    .m_axi_arburst                  (slice_0_m_axi_arburst      ),  
    .m_axi_rready                   (slice_0_m_axi_rready       ),  
    .m_axi_rvalid                   (slice_0_m_axi_rvalid       ),  
    .m_axi_rid                      (slice_0_m_axi_rid          ),  
    .m_axi_rdata                    (slice_0_m_axi_rdata        ),  
    .m_axi_rresp                    (slice_0_m_axi_rresp        ),  
    .m_axi_rlast                    (slice_0_m_axi_rlast        )  
);

slice # (
    .Cfg                            (Cfg                        ),
    .opWidth_t                      (opWidth_t                  ),
    .dataWidth_t                    (dataWidth_t                ),
    .addrWidth_t                    (addrWidth_t                ),
    .setWidth_t                     (setWidth_t                 ),
    .tagWidth_t                     (tagWidth_t                 ),
    .wayIndexWidth_t                (wayIndexWidth_t            ),
    .wbufWidth_t                    (wbufWidth_t                ),
    .wayNum_t                       (wayNum_t                   ),
    .nlineWidth_t                   (nlineWidth_t               ),
    .offsetWidth_t                  (offsetWidth_t              ),
    .metaWidth_t                    (metaWidth_t                ),
    .robWidth_t                     (robWidth_t                 ),
    .lsqWidth_t                     (lsqWidth_t                 ),
    .rfbufWidth_t                   (rfbufWidth_t               ),
    .kobWidth_t                     (kobWidth_t                 ),
    .mcWidth_t                      (mcWidth_t                  ),
    .bank_req_t                     (bank_req_t                 )
) u_slice_1 (
    .clk                            (clk                        ),
    .rst_n                          (rst_n                      ),
    .u_bank_req_valid               (bank_1_htu_valid           ),
    .u_bank_req_ready               (bank_1_htu_ready           ),
    .u_bank_req                     (bank_1_htu_req             ),
    .u_bank_req_wbuf_id             (bank_1_htu_req_wbuf_id     ),
    .u_xbar_req_valid               (bank_1_wbuf_req_valid      ),
    .u_xbar_req                     (bank_1_wbuf_req            ),
    .u_xbar_rsp_free_valid          (bank_1_wbuf_rsp_free_valid ),
    .u_xbar_rsp_free_id             (bank_1_wbuf_rsp_free_id    ),
    .u_bank_rsp_valid               (bank_1_rsp_valid           ),
    .u_bank_rsp_ready               (bank_1_rsp_ready           ),
    .u_bank_rsp_rob_id              (bank_1_rsp_rob_id          ),
    .u_bank_rsp_channel_id          (bank_1_rsp_channel_id      ),
    .u_bank_rsp_data                (bank_1_rsp_data            ),
    .u_xbar_crdt_rtn                (bank_1_crdt_rtn            ),
    .m_axi_awready                  (slice_1_m_axi_awready      ),
    .m_axi_awvalid                  (slice_1_m_axi_awvalid      ),
    .m_axi_awid                     (slice_1_m_axi_awid         ),
    .m_axi_awaddr                   (slice_1_m_axi_awaddr       ),
    .m_axi_awlen                    (slice_1_m_axi_awlen        ),
    .m_axi_awsize                   (slice_1_m_axi_awsize       ),
    .m_axi_awburst                  (slice_1_m_axi_awburst      ),
    .m_axi_wready                   (slice_1_m_axi_wready       ),
    .m_axi_wvalid                   (slice_1_m_axi_wvalid       ),
    .m_axi_wdata                    (slice_1_m_axi_wdata        ),
    .m_axi_wstrb                    (slice_1_m_axi_wstrb        ),
    .m_axi_wlast                    (slice_1_m_axi_wlast        ),
    .m_axi_bready                   (slice_1_m_axi_bready       ),
    .m_axi_bvalid                   (slice_1_m_axi_bvalid       ),
    .m_axi_bid                      (slice_1_m_axi_bid          ),
    .m_axi_bresp                    (slice_1_m_axi_bresp        ),
    .m_axi_arready                  (slice_1_m_axi_arready      ),
    .m_axi_arvalid                  (slice_1_m_axi_arvalid      ),
    .m_axi_arid                     (slice_1_m_axi_arid         ),
    .m_axi_araddr                   (slice_1_m_axi_araddr       ),
    .m_axi_arlen                    (slice_1_m_axi_arlen        ),
    .m_axi_arsize                   (slice_1_m_axi_arsize       ),
    .m_axi_arburst                  (slice_1_m_axi_arburst      ),
    .m_axi_rready                   (slice_1_m_axi_rready       ),
    .m_axi_rvalid                   (slice_1_m_axi_rvalid       ),
    .m_axi_rid                      (slice_1_m_axi_rid          ),
    .m_axi_rdata                    (slice_1_m_axi_rdata        ),
    .m_axi_rresp                    (slice_1_m_axi_rresp        ),
    .m_axi_rlast                    (slice_1_m_axi_rlast        )
);

slice # (
    .Cfg                            (Cfg                        ),
    .opWidth_t                      (opWidth_t                  ),
    .dataWidth_t                    (dataWidth_t                ),
    .addrWidth_t                    (addrWidth_t                ),
    .setWidth_t                     (setWidth_t                 ),
    .tagWidth_t                     (tagWidth_t                 ),
    .wayIndexWidth_t                (wayIndexWidth_t            ),
    .wbufWidth_t                    (wbufWidth_t                ),
    .wayNum_t                       (wayNum_t                   ),
    .nlineWidth_t                   (nlineWidth_t               ),
    .offsetWidth_t                  (offsetWidth_t              ),
    .metaWidth_t                    (metaWidth_t                ),
    .robWidth_t                     (robWidth_t                 ),
    .lsqWidth_t                     (lsqWidth_t                 ),
    .rfbufWidth_t                   (rfbufWidth_t               ),
    .kobWidth_t                     (kobWidth_t                 ),
    .mcWidth_t                      (mcWidth_t                  ),
    .bank_req_t                     (bank_req_t                 )
) u_slice_2 (
    .clk                            (clk                        ),
    .rst_n                          (rst_n                      ),
    .u_bank_req_valid               (bank_2_htu_valid           ),
    .u_bank_req_ready               (bank_2_htu_ready           ),
    .u_bank_req                     (bank_2_htu_req             ),
    .u_bank_req_wbuf_id             (bank_2_htu_req_wbuf_id     ),
    .u_xbar_req_valid               (bank_2_wbuf_req_valid      ),
    .u_xbar_req                     (bank_2_wbuf_req            ),
    .u_xbar_rsp_free_valid          (bank_2_wbuf_rsp_free_valid ),
    .u_xbar_rsp_free_id             (bank_2_wbuf_rsp_free_id    ),
    .u_bank_rsp_valid               (bank_2_rsp_valid           ),
    .u_bank_rsp_ready               (bank_2_rsp_ready           ),
    .u_bank_rsp_rob_id              (bank_2_rsp_rob_id          ),
    .u_bank_rsp_channel_id          (bank_2_rsp_channel_id      ),
    .u_bank_rsp_data                (bank_2_rsp_data            ),
    .u_xbar_crdt_rtn                (bank_2_crdt_rtn            ),
    .m_axi_awready                  (slice_2_m_axi_awready      ),
    .m_axi_awvalid                  (slice_2_m_axi_awvalid      ),
    .m_axi_awid                     (slice_2_m_axi_awid         ),
    .m_axi_awaddr                   (slice_2_m_axi_awaddr       ),
    .m_axi_awlen                    (slice_2_m_axi_awlen        ),
    .m_axi_awsize                   (slice_2_m_axi_awsize       ),
    .m_axi_awburst                  (slice_2_m_axi_awburst      ),
    .m_axi_wready                   (slice_2_m_axi_wready       ),
    .m_axi_wvalid                   (slice_2_m_axi_wvalid       ),
    .m_axi_wdata                    (slice_2_m_axi_wdata        ),
    .m_axi_wstrb                    (slice_2_m_axi_wstrb        ),
    .m_axi_wlast                    (slice_2_m_axi_wlast        ),
    .m_axi_bready                   (slice_2_m_axi_bready       ),
    .m_axi_bvalid                   (slice_2_m_axi_bvalid       ),
    .m_axi_bid                      (slice_2_m_axi_bid          ),
    .m_axi_bresp                    (slice_2_m_axi_bresp        ),
    .m_axi_arready                  (slice_2_m_axi_arready      ),
    .m_axi_arvalid                  (slice_2_m_axi_arvalid      ),
    .m_axi_arid                     (slice_2_m_axi_arid         ),
    .m_axi_araddr                   (slice_2_m_axi_araddr       ),
    .m_axi_arlen                    (slice_2_m_axi_arlen        ),
    .m_axi_arsize                   (slice_2_m_axi_arsize       ),
    .m_axi_arburst                  (slice_2_m_axi_arburst      ),
    .m_axi_rready                   (slice_2_m_axi_rready       ),
    .m_axi_rvalid                   (slice_2_m_axi_rvalid       ),
    .m_axi_rid                      (slice_2_m_axi_rid          ),
    .m_axi_rdata                    (slice_2_m_axi_rdata        ),
    .m_axi_rresp                    (slice_2_m_axi_rresp        ),
    .m_axi_rlast                    (slice_2_m_axi_rlast        )
);

slice # (
    .Cfg                            (Cfg                        ),
    .opWidth_t                      (opWidth_t                  ),
    .dataWidth_t                    (dataWidth_t                ),
    .addrWidth_t                    (addrWidth_t                ),
    .setWidth_t                     (setWidth_t                 ),
    .tagWidth_t                     (tagWidth_t                 ),
    .wayIndexWidth_t                (wayIndexWidth_t            ),
    .wbufWidth_t                    (wbufWidth_t                ),
    .wayNum_t                       (wayNum_t                   ),
    .nlineWidth_t                   (nlineWidth_t               ),
    .offsetWidth_t                  (offsetWidth_t              ),
    .metaWidth_t                    (metaWidth_t                ),
    .robWidth_t                     (robWidth_t                 ),
    .lsqWidth_t                     (lsqWidth_t                 ),
    .rfbufWidth_t                   (rfbufWidth_t               ),
    .kobWidth_t                     (kobWidth_t                 ),
    .mcWidth_t                      (mcWidth_t                  ),
    .bank_req_t                     (bank_req_t                 )
) u_slice_3 (
    .clk                            (clk                        ),
    .rst_n                          (rst_n                      ),
    .u_bank_req_valid               (bank_3_htu_valid           ),
    .u_bank_req_ready               (bank_3_htu_ready           ),
    .u_bank_req                     (bank_3_htu_req             ),
    .u_bank_req_wbuf_id             (bank_3_htu_req_wbuf_id     ),
    .u_xbar_req_valid               (bank_3_wbuf_req_valid      ),
    .u_xbar_req                     (bank_3_wbuf_req            ),
    .u_xbar_rsp_free_valid          (bank_3_wbuf_rsp_free_valid ),
    .u_xbar_rsp_free_id             (bank_3_wbuf_rsp_free_id    ),
    .u_bank_rsp_valid               (bank_3_rsp_valid           ),
    .u_bank_rsp_ready               (bank_3_rsp_ready           ),
    .u_bank_rsp_rob_id              (bank_3_rsp_rob_id          ),
    .u_bank_rsp_channel_id          (bank_3_rsp_channel_id      ),
    .u_bank_rsp_data                (bank_3_rsp_data            ),
    .u_xbar_crdt_rtn                (bank_3_crdt_rtn            ),
    .m_axi_awready                  (slice_3_m_axi_awready      ),
    .m_axi_awvalid                  (slice_3_m_axi_awvalid      ),
    .m_axi_awid                     (slice_3_m_axi_awid         ),
    .m_axi_awaddr                   (slice_3_m_axi_awaddr       ),
    .m_axi_awlen                    (slice_3_m_axi_awlen        ),
    .m_axi_awsize                   (slice_3_m_axi_awsize       ),
    .m_axi_awburst                  (slice_3_m_axi_awburst      ),
    .m_axi_wready                   (slice_3_m_axi_wready       ),
    .m_axi_wvalid                   (slice_3_m_axi_wvalid       ),
    .m_axi_wdata                    (slice_3_m_axi_wdata        ),
    .m_axi_wstrb                    (slice_3_m_axi_wstrb        ),
    .m_axi_wlast                    (slice_3_m_axi_wlast        ),
    .m_axi_bready                   (slice_3_m_axi_bready       ),
    .m_axi_bvalid                   (slice_3_m_axi_bvalid       ),
    .m_axi_bid                      (slice_3_m_axi_bid          ),
    .m_axi_bresp                    (slice_3_m_axi_bresp        ),
    .m_axi_arready                  (slice_3_m_axi_arready      ),
    .m_axi_arvalid                  (slice_3_m_axi_arvalid      ),
    .m_axi_arid                     (slice_3_m_axi_arid         ),
    .m_axi_araddr                   (slice_3_m_axi_araddr       ),
    .m_axi_arlen                    (slice_3_m_axi_arlen        ),
    .m_axi_arsize                   (slice_3_m_axi_arsize       ),
    .m_axi_arburst                  (slice_3_m_axi_arburst      ),
    .m_axi_rready                   (slice_3_m_axi_rready       ),
    .m_axi_rvalid                   (slice_3_m_axi_rvalid       ),
    .m_axi_rid                      (slice_3_m_axi_rid          ),
    .m_axi_rdata                    (slice_3_m_axi_rdata        ),
    .m_axi_rresp                    (slice_3_m_axi_rresp        ),
    .m_axi_rlast                    (slice_3_m_axi_rlast        )
);

endmodule
