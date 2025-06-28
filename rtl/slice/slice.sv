module slice     
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
    parameter type bank_req_t      = logic
)(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    // 1. from upstream req
    input  logic                        u_bank_req_valid           ,
    output logic                        u_bank_req_ready           ,
    input  bank_req_t                   u_bank_req                 ,
    input  wbufWidth_t                  u_bank_req_wbuf_id         ,

    input  logic                        u_xbar_req_valid           ,
    input  wbuf_req_t                   u_xbar_req                 ,
    output logic                        u_xbar_rsp_free_valid      ,
    output wbufWidth_t                  u_xbar_rsp_free_id         ,

    // 2. to upstream rsp
    output logic                        u_bank_rsp_valid           ,
    input  logic                        u_bank_rsp_ready           ,
    output robWidth_t                   u_bank_rsp_rob_id          ,
    output logic            [  1: 0]    u_bank_rsp_channel_id      ,
    output logic            [127: 0]    u_bank_rsp_data            ,

    // 3. from upstream xbar credit return
    input  logic            [  2: 0]    u_xbar_crdt_rtn            ,

    // 4. Master AXI AW Channel
    input  logic                        m_axi_awready              ,    
    output logic                        m_axi_awvalid              ,    
    output nlineWidth_t                 m_axi_awid                 ,    
    output logic           [ 31: 0]     m_axi_awaddr               ,    
    output logic           [  7: 0]     m_axi_awlen                ,    
    output logic           [  2: 0]     m_axi_awsize               ,    
    output logic           [  1: 0]     m_axi_awburst              ,   

    // 5. Master AXI W Channel
    input  logic                        m_axi_wready               ,    
    output logic                        m_axi_wvalid               ,    
    output logic           [255: 0]     m_axi_wdata                ,    
    output logic           [ 31: 0]     m_axi_wstrb                ,    
    output logic                        m_axi_wlast                ,    
    output logic                        m_axi_bready               ,    
    input  logic                        m_axi_bvalid               ,    
    input  nlineWidth_t                 m_axi_bid                  ,    
    input  logic           [  1: 0]     m_axi_bresp                ,

    // 6. Master AXI AR Channel
    input  logic                        m_axi_arready              ,   
    output logic                        m_axi_arvalid              ,   
    output nlineWidth_t                 m_axi_arid                 ,   
    output logic           [ 31: 0]     m_axi_araddr               ,   
    output logic           [  7: 0]     m_axi_arlen                ,   
    output logic           [  2: 0]     m_axi_arsize               ,   
    output logic           [  1: 0]     m_axi_arburst              ,

    // 7. Master AXI R Channel
    output logic                        m_axi_rready               ,           
    input  logic                        m_axi_rvalid               ,           
    input  nlineWidth_t                 m_axi_rid                  ,           
    input  logic           [255: 0]     m_axi_rdata                ,           
    input  logic           [  1: 0]     m_axi_rresp                ,           
    input  logic                        m_axi_rlast                            

);

logic                        isu_refill_valid    ;
setWidth_t                   isu_refill_set      ;
wayIndexWidth_t              isu_refill_way      ;

logic                        isu_valid           ;
logic                        isu_ready           ;
logic           [  2: 0]     isu_channel_1hot_id ;
logic           [  2: 0]     isu_op              ;
nlineWidth_t                 isu_id              ;
offsetWidth_t                isu_offset          ;
wbufWidth_t                  isu_wbuf_id         ;
logic                        isu_crdt_valid      ;
nlineWidth_t                 isu_crdt_way_set    ;


logic                        memctl_awvalid      ;
logic                        memctl_awready      ;
nlineWidth_t                 memctl_awid         ;
logic           [ 31: 0]     memctl_awaddr       ;
logic                        memctl_arvalid      ;
logic                        memctl_arready      ;
nlineWidth_t                 memctl_arid         ;
logic           [ 31: 0]     memctl_araddr       ;
logic                        memctl_rvalid       ;
logic                        memctl_rready       ;
nlineWidth_t                 memctl_rid          ;
logic           [255: 0]     memctl_rdata        ;
logic                        memctl_wvalid       ;       
logic                        memctl_wready       ;       
nlineWidth_t                 memctl_wid          ;       
logic            [255: 0]    memctl_wdata        ;

logic                        wbuf_req_valid      ;
wbufWidth_t                  wbuf_req_id         ;
logic            [127: 0]    wbuf_rsp_data       ;

logic                        rc_valid            ;      
logic                        rc_ready            ;      
logic            [  2: 0]    rc_channel_1hot_id  ;      
robWidth_t                   rc_rob_id           ;      
logic            [  2: 0]    rc_op               ;      
setWidth_t                   rc_set              ;      
wayIndexWidth_t              rc_way              ;      
offsetWidth_t                rc_offset           ;      
wbufWidth_t                  rc_wbuf_id          ;      
logic            [255: 0]    rc_refill_data      ;      




htu_wrapper # (
    .Cfg                     (Cfg                   ),
    .setWidth_t              (setWidth_t            ),  
    .tagWidth_t              (tagWidth_t            ), 
    .wayIndexWidth_t         (wayIndexWidth_t       ),
    .wbufWidth_t             (wbufWidth_t           ),    
    .wayNum_t                (wayNum_t              ),        
    .nlineWidth_t            (nlineWidth_t          ),      
    .offsetWidth_t           (offsetWidth_t         ), 
    .metaWidth_t             (metaWidth_t           ), 
    .robWidth_t              (robWidth_t            ), 
    .lsqWidth_t              (lsqWidth_t            ),   
    .rfbufWidth_t            (rfbufWidth_t          ),
    .bank_req_t              (bank_req_t            )   
) u_htu_wrapper (
    .clk                     (clk                   ),
    .rst_n                   (rst_n                 ),
    .u_bank_req_valid        (u_bank_req_valid      ),
    .u_bank_req_ready        (u_bank_req_ready      ),
    .u_bank_req              (u_bank_req            ),
    .u_bank_req_wbuf_id      (u_bank_req_wbuf_id    ),
    .d_isu_refill_valid      (isu_refill_valid      ),
    .d_isu_refill_set        (isu_refill_set        ),
    .d_isu_refill_way        (isu_refill_way        ),
    .d_isu_valid             (isu_valid             ),
    .d_isu_ready             (isu_ready             ),
    .d_isu_channel_1hot_id   (isu_channel_1hot_id   ),
    .d_isu_op                (isu_op                ),
    .d_isu_id                (isu_id                ),
    .d_isu_offset            (isu_offset            ),
    .d_isu_wbuf_id           (isu_wbuf_id           ),
    .d_memctl_awvalid        (memctl_awvalid        ),
    .d_memctl_awready        (memctl_awready        ),
    .d_memctl_awid           (memctl_awid           ),
    .d_memctl_awaddr         (memctl_awaddr         ),
    .d_memctl_arvalid        (memctl_arvalid        ),
    .d_memctl_arready        (memctl_arready        ),
    .d_memctl_arid           (memctl_arid           ),
    .d_memctl_araddr         (memctl_araddr         ),
    .d_isu_crdt_valid        (isu_crdt_valid        ),
    .d_isu_crdt_way_set      (isu_crdt_way_set      )
);

isu_wrapper # (
    .Cfg                     (Cfg                   ),
    .setWidth_t              (setWidth_t            ),
    .tagWidth_t              (tagWidth_t            ),
    .wayIndexWidth_t         (wayIndexWidth_t       ),
    .wbufWidth_t             (wbufWidth_t           ),
    .wayNum_t                (wayNum_t              ),
    .nlineWidth_t            (nlineWidth_t          ),
    .offsetWidth_t           (offsetWidth_t         ),
    .metaWidth_t             (metaWidth_t           ),
    .robWidth_t              (robWidth_t            ),
    .lsqWidth_t              (lsqWidth_t            ),
    .rfbufWidth_t            (rfbufWidth_t          )
) u_isu_wrapper (
    .clk                     (clk                   ),
    .rst_n                   (rst_n                 ),
    .u_htu_valid             (isu_valid             ),
    .u_htu_ready             (isu_ready             ),
    .u_htu_channel_1hot_id   (isu_channel_1hot_id   ),
    .u_htu_op                (isu_op                ),
    .u_htu_id                (isu_id                ),
    .u_htu_offset            (isu_offset            ),
    .u_htu_wbuf_id           (isu_wbuf_id           ),
    .u_htu_refill_valid      (isu_refill_valid      ),
    .u_htu_refill_set        (isu_refill_set        ),
    .u_htu_refill_way        (isu_refill_way        ),
    .memctl_refill_valid     (memctl_rvalid         ),
    .memctl_refill_ready     (memctl_rready         ),
    .memctl_refill_id        (memctl_rid            ),
    .memctl_refill_data      (memctl_rdata          ),
    .u_xbar_crdt_rtn         (u_xbar_crdt_rtn       ),
    .d_rc_valid              (rc_valid              ),
    .d_rc_ready              (rc_ready              ),
    .d_rc_channel_1hot_id    (rc_channel_1hot_id    ),
    .d_rc_rob_id             (rc_rob_id             ),
    .d_rc_op                 (rc_op                 ),
    .d_rc_set                (rc_set                ),
    .d_rc_way                (rc_way                ),
    .d_rc_offset             (rc_offset             ),
    .d_rc_wbuf_id            (rc_wbuf_id            ),
    .d_rc_refill_data        (rc_refill_data        ),
    .u_htu_crdt_valid        (isu_crdt_valid        ),
    .u_htu_crdt_way_set      (isu_crdt_way_set      )
);

rc_wrapper # (
    .Cfg                     (Cfg                   ),
    .setWidth_t              (setWidth_t            ),
    .tagWidth_t              (tagWidth_t            ),
    .wayIndexWidth_t         (wayIndexWidth_t       ),
    .wbufWidth_t             (wbufWidth_t           ),
    .wayNum_t                (wayNum_t              ),
    .nlineWidth_t            (nlineWidth_t          ),
    .offsetWidth_t           (offsetWidth_t         ),
    .metaWidth_t             (metaWidth_t           ),
    .robWidth_t              (robWidth_t            ),
    .lsqWidth_t              (lsqWidth_t            ),
    .kobWidth_t              (kobWidth_t            )
) u_rc_wrapper (
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .u_isu_valid            (rc_valid               ),
    .u_isu_ready            (rc_ready               ),
    .u_isu_channel_1hot_id  (rc_channel_1hot_id     ),
    .u_isu_rob_id           (rc_rob_id              ),
    .u_isu_op               (rc_op                  ),
    .u_isu_set              (rc_set                 ),
    .u_isu_way              (rc_way                 ),
    .u_isu_offset           (rc_offset              ),
    .u_isu_wbuf_id          (rc_wbuf_id             ),
    .u_isu_refill_data      (rc_refill_data         ),
    .wbuf_req_valid         (wbuf_req_valid         ),
    .wbuf_req_id            (wbuf_req_id            ),
    .wbuf_rsp_data          (wbuf_rsp_data          ), 
    .u_bank_rsp_valid       (u_bank_rsp_valid       ),
    .u_bank_rsp_ready       (u_bank_rsp_ready       ),
    .u_bank_rsp_rob_id      (u_bank_rsp_rob_id      ),
    .u_bank_rsp_channel_id  (u_bank_rsp_channel_id  ),
    .u_bank_rsp_data        (u_bank_rsp_data        ),
    .memctl_wvalid          (memctl_wvalid          ),          
    .memctl_wready          (memctl_wready          ),          
    .memctl_wid             (memctl_wid             ),          
    .memctl_wdata           (memctl_wdata           )
);

write_buffer # (
    .Cfg                     (Cfg                   ),
    .setWidth_t              (setWidth_t            ),
    .tagWidth_t              (tagWidth_t            ),
    .wayIndexWidth_t         (wayIndexWidth_t       ),
    .wbufWidth_t             (wbufWidth_t           ),
    .wayNum_t                (wayNum_t              ),
    .nlineWidth_t            (nlineWidth_t          ),
    .offsetWidth_t           (offsetWidth_t         ),
    .metaWidth_t             (metaWidth_t           ),
    .robWidth_t              (robWidth_t            ),
    .lsqWidth_t              (lsqWidth_t            ),
    .kobWidth_t              (kobWidth_t            )
) u_write_buffer (
    .clk                     (clk                   ),
    .rst_n                   (rst_n                 ),
    .xbar_req_valid          (u_xbar_req_valid      ),
    .xbar_req                (u_xbar_req            ),
    .xbar_rsp_free_valid     (u_xbar_rsp_free_valid ),
    .xbar_rsp_free_id        (u_xbar_rsp_free_id    ),
    .rc_req_valid            (wbuf_req_valid        ),
    .rc_req_id               (wbuf_req_id           ),
    .rc_rsp_data             (wbuf_rsp_data         )
);

mc_wrapper # (
    .Cfg                     (Cfg                   ),
    .setWidth_t              (setWidth_t            ),
    .tagWidth_t              (tagWidth_t            ),
    .wayIndexWidth_t         (wayIndexWidth_t       ),
    .wbufWidth_t             (wbufWidth_t           ),
    .wayNum_t                (wayNum_t              ),
    .nlineWidth_t            (nlineWidth_t          ),
    .offsetWidth_t           (offsetWidth_t         ),
    .metaWidth_t             (metaWidth_t           ),
    .robWidth_t              (robWidth_t            ),
    .lsqWidth_t              (lsqWidth_t            ),
    .kobWidth_t              (kobWidth_t            ),
    .mcWidth_t               (mcWidth_t             )
) u_mc_wrapper (
    .clk                     (clk                   ),
    .rst_n                   (rst_n                 ),
    .awvalid                 (memctl_awvalid        ),
    .awready                 (memctl_awready        ),
    .awid                    (memctl_awid           ),
    .awaddr                  (memctl_awaddr         ),
    .wvalid                  (memctl_wvalid         ),
    .wready                  (memctl_wready         ),
    .wid                     (memctl_wid            ),
    .wdata                   (memctl_wdata          ),
    .arvalid                 (memctl_arvalid        ),
    .arready                 (memctl_arready        ),
    .arid                    (memctl_arid           ),
    .araddr                  (memctl_araddr         ),
    .rvalid                  (memctl_rvalid         ),
    .rready                  (memctl_rready         ),
    .rid                     (memctl_rid            ),
    .rdata                   (memctl_rdata          ),
    .m_axi_awready           (m_axi_awready         ),
    .m_axi_awvalid           (m_axi_awvalid         ),
    .m_axi_awid              (m_axi_awid            ),
    .m_axi_awaddr            (m_axi_awaddr          ),
    .m_axi_awlen             (m_axi_awlen           ),
    .m_axi_awsize            (m_axi_awsize          ),
    .m_axi_awburst           (m_axi_awburst         ),
    .m_axi_wready            (m_axi_wready          ),
    .m_axi_wvalid            (m_axi_wvalid          ),
    .m_axi_wdata             (m_axi_wdata           ),
    .m_axi_wstrb             (m_axi_wstrb           ),
    .m_axi_wlast             (m_axi_wlast           ),
    .m_axi_bready            (m_axi_bready          ),
    .m_axi_bvalid            (m_axi_bvalid          ),
    .m_axi_bid               (m_axi_bid             ),
    .m_axi_bresp             (m_axi_bresp           ),
    .m_axi_arready           (m_axi_arready         ),
    .m_axi_arvalid           (m_axi_arvalid         ),
    .m_axi_arid              (m_axi_arid            ),
    .m_axi_araddr            (m_axi_araddr          ),
    .m_axi_arlen             (m_axi_arlen           ),
    .m_axi_arsize            (m_axi_arsize          ),
    .m_axi_arburst           (m_axi_arburst         ),
    .m_axi_rready            (m_axi_rready          ),
    .m_axi_rvalid            (m_axi_rvalid          ),
    .m_axi_rid               (m_axi_rid             ),
    .m_axi_rdata             (m_axi_rdata           ),
    .m_axi_rresp             (m_axi_rresp           ),
    .m_axi_rlast             (m_axi_rlast           )
);

endmodule