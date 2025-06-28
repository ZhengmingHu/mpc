module mpc_wrapper 
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
    output logic          [127: 0]      u_channel_2_rsp_bus_rdata  
);

logic                        slice_0_axi_awready ;
logic                        slice_0_axi_awvalid ;
nlineWidth_t                 slice_0_axi_awid    ;              
logic           [ 31: 0]     slice_0_axi_awaddr  ;
logic           [  7: 0]     slice_0_axi_awlen   ;
logic           [  2: 0]     slice_0_axi_awsize  ;
logic           [  1: 0]     slice_0_axi_awburst ;
logic                        slice_0_axi_wready  ;
logic                        slice_0_axi_wvalid  ;
logic           [255: 0]     slice_0_axi_wdata   ;
logic           [ 31: 0]     slice_0_axi_wstrb   ;
logic                        slice_0_axi_wlast   ;
logic                        slice_0_axi_bready  ;
logic                        slice_0_axi_bvalid  ;
nlineWidth_t                 slice_0_axi_bid     ;
logic           [  1: 0]     slice_0_axi_bresp   ;
logic                        slice_0_axi_arready ;
logic                        slice_0_axi_arvalid ;
nlineWidth_t                 slice_0_axi_arid    ;
logic           [ 31: 0]     slice_0_axi_araddr  ;
logic           [  7: 0]     slice_0_axi_arlen   ;
logic           [  2: 0]     slice_0_axi_arsize  ;
logic           [  1: 0]     slice_0_axi_arburst ;
logic                        slice_0_axi_rready  ;
logic                        slice_0_axi_rvalid  ;
nlineWidth_t                 slice_0_axi_rid     ;
logic           [255: 0]     slice_0_axi_rdata   ;
logic           [  1: 0]     slice_0_axi_rresp   ;
logic                        slice_0_axi_rlast   ;
logic                        slice_1_axi_awready ;
logic                        slice_1_axi_awvalid ;
nlineWidth_t                 slice_1_axi_awid    ;
logic           [ 31: 0]     slice_1_axi_awaddr  ;
logic           [  7: 0]     slice_1_axi_awlen   ;
logic           [  2: 0]     slice_1_axi_awsize  ;
logic           [  1: 0]     slice_1_axi_awburst ;
logic                        slice_1_axi_wready  ;
logic                        slice_1_axi_wvalid  ;
logic           [255: 0]     slice_1_axi_wdata   ;
logic           [ 31: 0]     slice_1_axi_wstrb   ;
logic                        slice_1_axi_wlast   ;
logic                        slice_1_axi_bready  ;
logic                        slice_1_axi_bvalid  ;
nlineWidth_t                 slice_1_axi_bid     ;
logic           [  1: 0]     slice_1_axi_bresp   ;
logic                        slice_1_axi_arready ;
logic                        slice_1_axi_arvalid ;
nlineWidth_t                 slice_1_axi_arid    ;
logic           [ 31: 0]     slice_1_axi_araddr  ;
logic           [  7: 0]     slice_1_axi_arlen   ;
logic           [  2: 0]     slice_1_axi_arsize  ;
logic           [  1: 0]     slice_1_axi_arburst ;
logic                        slice_1_axi_rready  ;
logic                        slice_1_axi_rvalid  ;
nlineWidth_t                 slice_1_axi_rid     ;
logic           [255: 0]     slice_1_axi_rdata   ;
logic           [  1: 0]     slice_1_axi_rresp   ;
logic                        slice_1_axi_rlast   ;
logic                        slice_2_axi_awready ;
logic                        slice_2_axi_awvalid ;
nlineWidth_t                 slice_2_axi_awid    ;
logic           [ 31: 0]     slice_2_axi_awaddr  ;
logic           [  7: 0]     slice_2_axi_awlen   ;
logic           [  2: 0]     slice_2_axi_awsize  ;
logic           [  1: 0]     slice_2_axi_awburst ;
logic                        slice_2_axi_wready  ;
logic                        slice_2_axi_wvalid  ;
logic           [255: 0]     slice_2_axi_wdata   ;
logic           [ 31: 0]     slice_2_axi_wstrb   ;
logic                        slice_2_axi_wlast   ;
logic                        slice_2_axi_bready  ;
logic                        slice_2_axi_bvalid  ;
nlineWidth_t                 slice_2_axi_bid     ;
logic           [  1: 0]     slice_2_axi_bresp   ;
logic                        slice_2_axi_arready ;
logic                        slice_2_axi_arvalid ;
nlineWidth_t                 slice_2_axi_arid    ;
logic           [ 31: 0]     slice_2_axi_araddr  ;
logic           [  7: 0]     slice_2_axi_arlen   ;
logic           [  2: 0]     slice_2_axi_arsize  ;
logic           [  1: 0]     slice_2_axi_arburst ;
logic                        slice_2_axi_rready  ;
logic                        slice_2_axi_rvalid  ;
nlineWidth_t                 slice_2_axi_rid     ;
logic           [255: 0]     slice_2_axi_rdata   ;
logic           [  1: 0]     slice_2_axi_rresp   ;
logic                        slice_2_axi_rlast   ;
logic                        slice_3_axi_awready ;
logic                        slice_3_axi_awvalid ;
nlineWidth_t                 slice_3_axi_awid    ;
logic           [ 31: 0]     slice_3_axi_awaddr  ;
logic           [  7: 0]     slice_3_axi_awlen   ;
logic           [  2: 0]     slice_3_axi_awsize  ;
logic           [  1: 0]     slice_3_axi_awburst ;
logic                        slice_3_axi_wready  ;
logic                        slice_3_axi_wvalid  ;
logic           [255: 0]     slice_3_axi_wdata   ;
logic           [ 31: 0]     slice_3_axi_wstrb   ;
logic                        slice_3_axi_wlast   ;
logic                        slice_3_axi_bready  ;
logic                        slice_3_axi_bvalid  ;
nlineWidth_t                 slice_3_axi_bid     ;
logic           [  1: 0]     slice_3_axi_bresp   ;
logic                        slice_3_axi_arready ;
logic                        slice_3_axi_arvalid ;
nlineWidth_t                 slice_3_axi_arid    ;
logic           [ 31: 0]     slice_3_axi_araddr  ;
logic           [  7: 0]     slice_3_axi_arlen   ;
logic           [  2: 0]     slice_3_axi_arsize  ;
logic           [  1: 0]     slice_3_axi_arburst ;
logic                        slice_3_axi_rready  ;
logic                        slice_3_axi_rvalid  ;
nlineWidth_t                 slice_3_axi_rid     ;
logic           [255: 0]     slice_3_axi_rdata   ;
logic           [  1: 0]     slice_3_axi_rresp   ;
logic                        slice_3_axi_rlast   ;


mpc # (
    .Cfg                       (Cfg                      ),
    .opWidth_t                 (opWidth_t                ),
    .dataWidth_t               (dataWidth_t              ),
    .addrWidth_t               (addrWidth_t              ),
    .setWidth_t                (setWidth_t               ),
    .tagWidth_t                (tagWidth_t               ),
    .wayIndexWidth_t           (wayIndexWidth_t          ),
    .wbufWidth_t               (wbufWidth_t              ),
    .wayNum_t                  (wayNum_t                 ),
    .nlineWidth_t              (nlineWidth_t             ),
    .offsetWidth_t             (offsetWidth_t            ),
    .metaWidth_t               (metaWidth_t              ),
    .robWidth_t                (robWidth_t               ),
    .lsqWidth_t                (lsqWidth_t               ),
    .rfbufWidth_t              (rfbufWidth_t             ),
    .kobWidth_t                (kobWidth_t               ),
    .mcWidth_t                 (mcWidth_t                ),
    .channel_req_t             (channel_req_t            ),
    .bank_req_t                (bank_req_t               )
) u_mpc (
    .clk                       (clk                      ),
    .rst_n                     (rst_n                    ),
    .u_channel_0_req_bus_valid (u_channel_0_req_bus_valid),
    .u_channel_0_req_bus_ready (u_channel_0_req_bus_ready),
    .u_channel_0_req_bus       (u_channel_0_req_bus      ),
    .u_channel_1_req_bus_valid (u_channel_1_req_bus_valid),
    .u_channel_1_req_bus_ready (u_channel_1_req_bus_ready),
    .u_channel_1_req_bus       (u_channel_1_req_bus      ),
    .u_channel_2_req_bus_valid (u_channel_2_req_bus_valid),
    .u_channel_2_req_bus_ready (u_channel_2_req_bus_ready),
    .u_channel_2_req_bus       (u_channel_2_req_bus      ),
    .u_channel_0_rsp_bus_valid (u_channel_0_rsp_bus_valid),
    .u_channel_0_rsp_bus_ready (u_channel_0_rsp_bus_ready),
    .u_channel_0_rsp_bus_rdata (u_channel_0_rsp_bus_rdata),
    .u_channel_1_rsp_bus_valid (u_channel_1_rsp_bus_valid),
    .u_channel_1_rsp_bus_ready (u_channel_1_rsp_bus_ready),
    .u_channel_1_rsp_bus_rdata (u_channel_1_rsp_bus_rdata),
    .u_channel_2_rsp_bus_valid (u_channel_2_rsp_bus_valid),
    .u_channel_2_rsp_bus_ready (u_channel_2_rsp_bus_ready),
    .u_channel_2_rsp_bus_rdata (u_channel_2_rsp_bus_rdata),
    .slice_0_m_axi_awready     (slice_0_axi_awready      ),
    .slice_0_m_axi_awvalid     (slice_0_axi_awvalid      ),
    .slice_0_m_axi_awid        (slice_0_axi_awid         ),
    .slice_0_m_axi_awaddr      (slice_0_axi_awaddr       ),
    .slice_0_m_axi_awlen       (slice_0_axi_awlen        ),
    .slice_0_m_axi_awsize      (slice_0_axi_awsize       ),
    .slice_0_m_axi_awburst     (slice_0_axi_awburst      ),
    .slice_0_m_axi_wready      (slice_0_axi_wready       ),
    .slice_0_m_axi_wvalid      (slice_0_axi_wvalid       ),
    .slice_0_m_axi_wdata       (slice_0_axi_wdata        ),
    .slice_0_m_axi_wstrb       (slice_0_axi_wstrb        ),
    .slice_0_m_axi_wlast       (slice_0_axi_wlast        ),
    .slice_0_m_axi_bready      (slice_0_axi_bready       ),
    .slice_0_m_axi_bvalid      (slice_0_axi_bvalid       ),
    .slice_0_m_axi_bid         (slice_0_axi_bid          ),
    .slice_0_m_axi_bresp       (slice_0_axi_bresp        ),
    .slice_0_m_axi_arready     (slice_0_axi_arready      ),
    .slice_0_m_axi_arvalid     (slice_0_axi_arvalid      ),
    .slice_0_m_axi_arid        (slice_0_axi_arid         ),
    .slice_0_m_axi_araddr      (slice_0_axi_araddr       ),
    .slice_0_m_axi_arlen       (slice_0_axi_arlen        ),
    .slice_0_m_axi_arsize      (slice_0_axi_arsize       ),
    .slice_0_m_axi_arburst     (slice_0_axi_arburst      ),
    .slice_0_m_axi_rready      (slice_0_axi_rready       ),
    .slice_0_m_axi_rvalid      (slice_0_axi_rvalid       ),
    .slice_0_m_axi_rid         (slice_0_axi_rid          ),
    .slice_0_m_axi_rdata       (slice_0_axi_rdata        ),
    .slice_0_m_axi_rresp       (slice_0_axi_rresp        ),
    .slice_0_m_axi_rlast       (slice_0_axi_rlast        ),
    .slice_1_m_axi_awready     (slice_1_axi_awready      ),
    .slice_1_m_axi_awvalid     (slice_1_axi_awvalid      ),
    .slice_1_m_axi_awid        (slice_1_axi_awid         ),
    .slice_1_m_axi_awaddr      (slice_1_axi_awaddr       ),
    .slice_1_m_axi_awlen       (slice_1_axi_awlen        ),
    .slice_1_m_axi_awsize      (slice_1_axi_awsize       ),
    .slice_1_m_axi_awburst     (slice_1_axi_awburst      ),
    .slice_1_m_axi_wready      (slice_1_axi_wready       ),
    .slice_1_m_axi_wvalid      (slice_1_axi_wvalid       ),
    .slice_1_m_axi_wdata       (slice_1_axi_wdata        ),
    .slice_1_m_axi_wstrb       (slice_1_axi_wstrb        ),
    .slice_1_m_axi_wlast       (slice_1_axi_wlast        ),
    .slice_1_m_axi_bready      (slice_1_axi_bready       ),
    .slice_1_m_axi_bvalid      (slice_1_axi_bvalid       ),
    .slice_1_m_axi_bid         (slice_1_axi_bid          ),
    .slice_1_m_axi_bresp       (slice_1_axi_bresp        ),
    .slice_1_m_axi_arready     (slice_1_axi_arready      ),
    .slice_1_m_axi_arvalid     (slice_1_axi_arvalid      ),
    .slice_1_m_axi_arid        (slice_1_axi_arid         ),
    .slice_1_m_axi_araddr      (slice_1_axi_araddr       ),
    .slice_1_m_axi_arlen       (slice_1_axi_arlen        ),
    .slice_1_m_axi_arsize      (slice_1_axi_arsize       ),
    .slice_1_m_axi_arburst     (slice_1_axi_arburst      ),
    .slice_1_m_axi_rready      (slice_1_axi_rready       ),
    .slice_1_m_axi_rvalid      (slice_1_axi_rvalid       ),
    .slice_1_m_axi_rid         (slice_1_axi_rid          ),
    .slice_1_m_axi_rdata       (slice_1_axi_rdata        ),
    .slice_1_m_axi_rresp       (slice_1_axi_rresp        ),
    .slice_1_m_axi_rlast       (slice_1_axi_rlast        ),
    .slice_2_m_axi_awready     (slice_2_axi_awready      ),
    .slice_2_m_axi_awvalid     (slice_2_axi_awvalid      ),
    .slice_2_m_axi_awid        (slice_2_axi_awid         ),
    .slice_2_m_axi_awaddr      (slice_2_axi_awaddr       ),
    .slice_2_m_axi_awlen       (slice_2_axi_awlen        ),
    .slice_2_m_axi_awsize      (slice_2_axi_awsize       ),
    .slice_2_m_axi_awburst     (slice_2_axi_awburst      ),
    .slice_2_m_axi_wready      (slice_2_axi_wready       ),
    .slice_2_m_axi_wvalid      (slice_2_axi_wvalid       ),
    .slice_2_m_axi_wdata       (slice_2_axi_wdata        ),
    .slice_2_m_axi_wstrb       (slice_2_axi_wstrb        ),
    .slice_2_m_axi_wlast       (slice_2_axi_wlast        ),
    .slice_2_m_axi_bready      (slice_2_axi_bready       ),
    .slice_2_m_axi_bvalid      (slice_2_axi_bvalid       ),
    .slice_2_m_axi_bid         (slice_2_axi_bid          ),
    .slice_2_m_axi_bresp       (slice_2_axi_bresp        ),
    .slice_2_m_axi_arready     (slice_2_axi_arready      ),
    .slice_2_m_axi_arvalid     (slice_2_axi_arvalid      ),
    .slice_2_m_axi_arid        (slice_2_axi_arid         ),
    .slice_2_m_axi_araddr      (slice_2_axi_araddr       ),
    .slice_2_m_axi_arlen       (slice_2_axi_arlen        ),
    .slice_2_m_axi_arsize      (slice_2_axi_arsize       ),
    .slice_2_m_axi_arburst     (slice_2_axi_arburst      ),
    .slice_2_m_axi_rready      (slice_2_axi_rready       ),
    .slice_2_m_axi_rvalid      (slice_2_axi_rvalid       ),
    .slice_2_m_axi_rid         (slice_2_axi_rid          ),
    .slice_2_m_axi_rdata       (slice_2_axi_rdata        ),
    .slice_2_m_axi_rresp       (slice_2_axi_rresp        ),
    .slice_2_m_axi_rlast       (slice_2_axi_rlast        ),
    .slice_3_m_axi_awready     (slice_3_axi_awready      ),
    .slice_3_m_axi_awvalid     (slice_3_axi_awvalid      ),
    .slice_3_m_axi_awid        (slice_3_axi_awid         ),
    .slice_3_m_axi_awaddr      (slice_3_axi_awaddr       ),
    .slice_3_m_axi_awlen       (slice_3_axi_awlen        ),
    .slice_3_m_axi_awsize      (slice_3_axi_awsize       ),
    .slice_3_m_axi_awburst     (slice_3_axi_awburst      ),
    .slice_3_m_axi_wready      (slice_3_axi_wready       ),
    .slice_3_m_axi_wvalid      (slice_3_axi_wvalid       ),
    .slice_3_m_axi_wdata       (slice_3_axi_wdata        ),
    .slice_3_m_axi_wstrb       (slice_3_axi_wstrb        ),
    .slice_3_m_axi_wlast       (slice_3_axi_wlast        ),
    .slice_3_m_axi_bready      (slice_3_axi_bready       ),
    .slice_3_m_axi_bvalid      (slice_3_axi_bvalid       ),
    .slice_3_m_axi_bid         (slice_3_axi_bid          ),
    .slice_3_m_axi_bresp       (slice_3_axi_bresp        ),
    .slice_3_m_axi_arready     (slice_3_axi_arready      ),
    .slice_3_m_axi_arvalid     (slice_3_axi_arvalid      ),
    .slice_3_m_axi_arid        (slice_3_axi_arid         ),
    .slice_3_m_axi_araddr      (slice_3_axi_araddr       ),
    .slice_3_m_axi_arlen       (slice_3_axi_arlen        ),
    .slice_3_m_axi_arsize      (slice_3_axi_arsize       ),
    .slice_3_m_axi_arburst     (slice_3_axi_arburst      ),
    .slice_3_m_axi_rready      (slice_3_axi_rready       ),
    .slice_3_m_axi_rvalid      (slice_3_axi_rvalid       ),
    .slice_3_m_axi_rid         (slice_3_axi_rid          ),
    .slice_3_m_axi_rdata       (slice_3_axi_rdata        ),
    .slice_3_m_axi_rresp       (slice_3_axi_rresp        ),
    .slice_3_m_axi_rlast       (slice_3_axi_rlast        )
);

slice_0_memory_interface # (
    .Cfg                               (Cfg                ),      
    .setWidth_t                        (setWidth_t         ),      
    .tagWidth_t                        (tagWidth_t         ),      
    .wayIndexWidth_t                   (wayIndexWidth_t    ),      
    .wbufWidth_t                       (wbufWidth_t        ),      
    .wayNum_t                          (wayNum_t           ),      
    .nlineWidth_t                      (nlineWidth_t       ),      
    .offsetWidth_t                     (offsetWidth_t      ),      
    .metaWidth_t                       (metaWidth_t        ),      
    .robWidth_t                        (robWidth_t         ),      
    .lsqWidth_t                        (lsqWidth_t         ),      
    .kobWidth_t                        (kobWidth_t         ), 
    .mcWidth_t                         (mcWidth_t          )
) u_slice_0_mem_intf (
    .clk                (clk                      ),
    .rst_n              (rst_n                    ),

    .s_axi_awready      (slice_0_axi_awready      ),
    .s_axi_awvalid      (slice_0_axi_awvalid      ),
    .s_axi_awid         (slice_0_axi_awid         ),
    .s_axi_awaddr       (slice_0_axi_awaddr       ),
    .s_axi_awlen        (slice_0_axi_awlen        ),
    .s_axi_awsize       (slice_0_axi_awsize       ),
    .s_axi_awburst      (slice_0_axi_awburst      ),
    .s_axi_wready       (slice_0_axi_wready       ),
    .s_axi_wvalid       (slice_0_axi_wvalid       ),
    .s_axi_wdata        (slice_0_axi_wdata        ),
    .s_axi_wstrb        (slice_0_axi_wstrb        ),
    .s_axi_wlast        (slice_0_axi_wlast        ),
    .s_axi_bready       (slice_0_axi_bready       ),
    .s_axi_bvalid       (slice_0_axi_bvalid       ),
    .s_axi_bid          (slice_0_axi_bid          ),
    .s_axi_bresp        (slice_0_axi_bresp        ),
    .s_axi_arready      (slice_0_axi_arready      ),
    .s_axi_arvalid      (slice_0_axi_arvalid      ),
    .s_axi_arid         (slice_0_axi_arid         ),
    .s_axi_araddr       (slice_0_axi_araddr       ),
    .s_axi_arlen        (slice_0_axi_arlen        ),
    .s_axi_arsize       (slice_0_axi_arsize       ),
    .s_axi_arburst      (slice_0_axi_arburst      ),
    .s_axi_rready       (slice_0_axi_rready       ),
    .s_axi_rvalid       (slice_0_axi_rvalid       ),
    .s_axi_rid          (slice_0_axi_rid          ),
    .s_axi_rdata        (slice_0_axi_rdata        ),
    .s_axi_rresp        (slice_0_axi_rresp        ),
    .s_axi_rlast        (slice_0_axi_rlast        )
);

slice_1_memory_interface # (
    .Cfg                               (Cfg                ),      
    .setWidth_t                        (setWidth_t         ),      
    .tagWidth_t                        (tagWidth_t         ),      
    .wayIndexWidth_t                   (wayIndexWidth_t    ),      
    .wbufWidth_t                       (wbufWidth_t        ),      
    .wayNum_t                          (wayNum_t           ),      
    .nlineWidth_t                      (nlineWidth_t       ),      
    .offsetWidth_t                     (offsetWidth_t      ),      
    .metaWidth_t                       (metaWidth_t        ),      
    .robWidth_t                        (robWidth_t         ),      
    .lsqWidth_t                        (lsqWidth_t         ),      
    .kobWidth_t                        (kobWidth_t         ), 
    .mcWidth_t                         (mcWidth_t          )
) u_slice_1_mem_intf (
    .clk                (clk        ),
    .rst_n              (rst_n      ),

    .s_axi_awready      (slice_1_axi_awready      ),
    .s_axi_awvalid      (slice_1_axi_awvalid      ),
    .s_axi_awid         (slice_1_axi_awid         ),
    .s_axi_awaddr       (slice_1_axi_awaddr       ),
    .s_axi_awlen        (slice_1_axi_awlen        ),
    .s_axi_awsize       (slice_1_axi_awsize       ),
    .s_axi_awburst      (slice_1_axi_awburst      ),
    .s_axi_wready       (slice_1_axi_wready       ),
    .s_axi_wvalid       (slice_1_axi_wvalid       ),
    .s_axi_wdata        (slice_1_axi_wdata        ),
    .s_axi_wstrb        (slice_1_axi_wstrb        ),
    .s_axi_wlast        (slice_1_axi_wlast        ),
    .s_axi_bready       (slice_1_axi_bready       ),
    .s_axi_bvalid       (slice_1_axi_bvalid       ),
    .s_axi_bid          (slice_1_axi_bid          ),
    .s_axi_bresp        (slice_1_axi_bresp        ),
    .s_axi_arready      (slice_1_axi_arready      ),
    .s_axi_arvalid      (slice_1_axi_arvalid      ),
    .s_axi_arid         (slice_1_axi_arid         ),
    .s_axi_araddr       (slice_1_axi_araddr       ),
    .s_axi_arlen        (slice_1_axi_arlen        ),
    .s_axi_arsize       (slice_1_axi_arsize       ),
    .s_axi_arburst      (slice_1_axi_arburst      ),
    .s_axi_rready       (slice_1_axi_rready       ),
    .s_axi_rvalid       (slice_1_axi_rvalid       ),
    .s_axi_rid          (slice_1_axi_rid          ),
    .s_axi_rdata        (slice_1_axi_rdata        ),
    .s_axi_rresp        (slice_1_axi_rresp        ),
    .s_axi_rlast        (slice_1_axi_rlast        )
);

slice_2_memory_interface # (
    .Cfg                               (Cfg                ),      
    .setWidth_t                        (setWidth_t         ),      
    .tagWidth_t                        (tagWidth_t         ),      
    .wayIndexWidth_t                   (wayIndexWidth_t    ),      
    .wbufWidth_t                       (wbufWidth_t        ),      
    .wayNum_t                          (wayNum_t           ),      
    .nlineWidth_t                      (nlineWidth_t       ),      
    .offsetWidth_t                     (offsetWidth_t      ),      
    .metaWidth_t                       (metaWidth_t        ),      
    .robWidth_t                        (robWidth_t         ),      
    .lsqWidth_t                        (lsqWidth_t         ),      
    .kobWidth_t                        (kobWidth_t         ), 
    .mcWidth_t                         (mcWidth_t          )
) u_slice_2_mem_intf (
    .clk                (clk                      ),
    .rst_n              (rst_n                    ),

    .s_axi_awready      (slice_2_axi_awready      ),
    .s_axi_awvalid      (slice_2_axi_awvalid      ),
    .s_axi_awid         (slice_2_axi_awid         ),
    .s_axi_awaddr       (slice_2_axi_awaddr       ),
    .s_axi_awlen        (slice_2_axi_awlen        ),
    .s_axi_awsize       (slice_2_axi_awsize       ),
    .s_axi_awburst      (slice_2_axi_awburst      ),
    .s_axi_wready       (slice_2_axi_wready       ),
    .s_axi_wvalid       (slice_2_axi_wvalid       ),
    .s_axi_wdata        (slice_2_axi_wdata        ),
    .s_axi_wstrb        (slice_2_axi_wstrb        ),
    .s_axi_wlast        (slice_2_axi_wlast        ),
    .s_axi_bready       (slice_2_axi_bready       ),
    .s_axi_bvalid       (slice_2_axi_bvalid       ),
    .s_axi_bid          (slice_2_axi_bid          ),
    .s_axi_bresp        (slice_2_axi_bresp        ),
    .s_axi_arready      (slice_2_axi_arready      ),
    .s_axi_arvalid      (slice_2_axi_arvalid      ),
    .s_axi_arid         (slice_2_axi_arid         ),
    .s_axi_araddr       (slice_2_axi_araddr       ),
    .s_axi_arlen        (slice_2_axi_arlen        ),
    .s_axi_arsize       (slice_2_axi_arsize       ),
    .s_axi_arburst      (slice_2_axi_arburst      ),
    .s_axi_rready       (slice_2_axi_rready       ),
    .s_axi_rvalid       (slice_2_axi_rvalid       ),
    .s_axi_rid          (slice_2_axi_rid          ),
    .s_axi_rdata        (slice_2_axi_rdata        ),
    .s_axi_rresp        (slice_2_axi_rresp        ),
    .s_axi_rlast        (slice_2_axi_rlast        )
);

slice_3_memory_interface # (
    .Cfg                               (Cfg                ),      
    .setWidth_t                        (setWidth_t         ),      
    .tagWidth_t                        (tagWidth_t         ),      
    .wayIndexWidth_t                   (wayIndexWidth_t    ),      
    .wbufWidth_t                       (wbufWidth_t        ),      
    .wayNum_t                          (wayNum_t           ),      
    .nlineWidth_t                      (nlineWidth_t       ),      
    .offsetWidth_t                     (offsetWidth_t      ),      
    .metaWidth_t                       (metaWidth_t        ),      
    .robWidth_t                        (robWidth_t         ),      
    .lsqWidth_t                        (lsqWidth_t         ),      
    .kobWidth_t                        (kobWidth_t         ), 
    .mcWidth_t                         (mcWidth_t          )
) u_slice_3_mem_intf (
    .clk                (clk                      ),
    .rst_n              (rst_n                    ),

    .s_axi_awready      (slice_3_axi_awready      ),
    .s_axi_awvalid      (slice_3_axi_awvalid      ),
    .s_axi_awid         (slice_3_axi_awid         ),
    .s_axi_awaddr       (slice_3_axi_awaddr       ),
    .s_axi_awlen        (slice_3_axi_awlen        ),
    .s_axi_awsize       (slice_3_axi_awsize       ),
    .s_axi_awburst      (slice_3_axi_awburst      ),
    .s_axi_wready       (slice_3_axi_wready       ),
    .s_axi_wvalid       (slice_3_axi_wvalid       ),
    .s_axi_wdata        (slice_3_axi_wdata        ),
    .s_axi_wstrb        (slice_3_axi_wstrb        ),
    .s_axi_wlast        (slice_3_axi_wlast        ),
    .s_axi_bready       (slice_3_axi_bready       ),
    .s_axi_bvalid       (slice_3_axi_bvalid       ),
    .s_axi_bid          (slice_3_axi_bid          ),
    .s_axi_bresp        (slice_3_axi_bresp        ),
    .s_axi_arready      (slice_3_axi_arready      ),
    .s_axi_arvalid      (slice_3_axi_arvalid      ),
    .s_axi_arid         (slice_3_axi_arid         ),
    .s_axi_araddr       (slice_3_axi_araddr       ),
    .s_axi_arlen        (slice_3_axi_arlen        ),
    .s_axi_arsize       (slice_3_axi_arsize       ),
    .s_axi_arburst      (slice_3_axi_arburst      ),
    .s_axi_rready       (slice_3_axi_rready       ),
    .s_axi_rvalid       (slice_3_axi_rvalid       ),
    .s_axi_rid          (slice_3_axi_rid          ),
    .s_axi_rdata        (slice_3_axi_rdata        ),
    .s_axi_rresp        (slice_3_axi_rresp        ),
    .s_axi_rlast        (slice_3_axi_rlast        )
);

endmodule