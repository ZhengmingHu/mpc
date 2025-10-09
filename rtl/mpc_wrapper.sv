`include "mpc_defs.svh"

module mpc_wrapper 
    import mpc_types::*;
#(
    parameter mpc_user_cfg_t UserCfg = '{
        opWidth:3,
        clWidth:256,
        clWordWidth:128,
        addrWidth:32,
        sets:8,
        banks:4,
        ways:4,
        kobSize:16,
        wbufSize:16,
        robSize:16,
        lsqSize:32,
        rfbufSize:16,
        mcSize:4
    },
    parameter mpc_cfg_t Cfg = mpcBuildConfig(UserCfg),
    parameter type clWidth_t       = logic [Cfg.u.clWidth-1:0],
    parameter type opWidth_t       = logic [Cfg.u.opWidth-1:0],
    parameter type dataWidth_t     = logic [Cfg.u.clWordWidth-1:0],
    parameter type addrWidth_t     = logic [Cfg.u.addrWidth-1:0],
    parameter type setWidth_t      = logic [Cfg.setWidth-1:0],
    parameter type tagWidth_t      = logic [Cfg.tagWidth-1:0],
    parameter type wayIndexWidth_t = logic [Cfg.wayIndexWidth-1:0],
    parameter type wbufWidth_t     = logic [Cfg.wbufWidth-1:0],
    parameter type wayNum_t        = logic [Cfg.wayNum-1:0],
    parameter type nlineWidth_t    = logic [Cfg.nlineWidth-1:0],
    parameter type offsetWidth_t   = logic [Cfg.offsetWidth-1:0],
    parameter type byteWidth_t     = logic [Cfg.byteWidth-1:0],
    parameter type metaWidth_t     = logic [Cfg.metaWidth-1:0],
    parameter type robWidth_t      = logic [Cfg.robWidth-1:0],
    parameter type lsqWidth_t      = logic [Cfg.lsqWidth-1:0],
    parameter type rfbufWidth_t    = logic [Cfg.rfbufWidth-1:0],
    parameter type kobWidth_t      = logic [Cfg.kobWidth-1:0],
    parameter type mcWidth_t       = logic [Cfg.mcWidth-1:0],

    parameter type channel_req_t = 
        `MPC_DECL_REQ_T(
            opWidth_t,
            opWidth_t,
            dataWidth_t,
            addrWidth_t),

    parameter type bank_req_t =
        `MPC_DECL_BANK_REQ_T(
            opWidth_t,
            opWidth_t,
            dataWidth_t,
            addrWidth_t),

    parameter type wbuf_req_t = 
        `MPC_DECL_WBUF_REQ_T(
            wbufWidth_t,
            dataWidth_t)
)(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,
    // upstream req from 3 channels
    input  logic                        u_channel_0_req_bus_valid  ,
    output logic                        u_channel_0_req_bus_ready  ,
    input  opWidth_t                    u_channel_0_req_bus_op     ,
    input  opWidth_t                    u_channel_0_req_bus_size   ,
    input  dataWidth_t                  u_channel_0_req_bus_wdata  ,
    input  addrWidth_t                  u_channel_0_req_bus_addr   ,

    input  logic                        u_channel_1_req_bus_valid  ,
    output logic                        u_channel_1_req_bus_ready  ,
    input  opWidth_t                    u_channel_1_req_bus_op     ,
    input  opWidth_t                    u_channel_1_req_bus_size   ,
    input  dataWidth_t                  u_channel_1_req_bus_wdata  ,
    input  addrWidth_t                  u_channel_1_req_bus_addr   ,

    input  logic                        u_channel_2_req_bus_valid  ,
    output logic                        u_channel_2_req_bus_ready  ,
    input  opWidth_t                    u_channel_2_req_bus_op     ,
    input  opWidth_t                    u_channel_2_req_bus_size   ,
    input  dataWidth_t                  u_channel_2_req_bus_wdata  ,
    input  addrWidth_t                  u_channel_2_req_bus_addr   ,

    // upstream rsp to 3 channels
    output logic                        u_channel_0_rsp_bus_valid  ,
    input  logic                        u_channel_0_rsp_bus_ready  ,
    output dataWidth_t                  u_channel_0_rsp_bus_rdata  ,

    output logic                        u_channel_1_rsp_bus_valid  ,
    input  logic                        u_channel_1_rsp_bus_ready  ,
    output dataWidth_t                  u_channel_1_rsp_bus_rdata  ,

    output logic                        u_channel_2_rsp_bus_valid  ,
    input  logic                        u_channel_2_rsp_bus_ready  ,
    output dataWidth_t                  u_channel_2_rsp_bus_rdata  
);

channel_req_t                u_channel_0_req_bus ;
channel_req_t                u_channel_1_req_bus ;
channel_req_t                u_channel_2_req_bus ;

logic                        slice_0_axi_awready ;
logic                        slice_0_axi_awvalid ;
logic           [  1: 0]     slice_0_axi_awid    ;              
logic           [ 31: 0]     slice_0_axi_awaddr  ;
logic           [  7: 0]     slice_0_axi_awlen   ;
logic           [  2: 0]     slice_0_axi_awsize  ;
logic           [  1: 0]     slice_0_axi_awburst ;
logic                        slice_0_axi_wready  ;
logic                        slice_0_axi_wvalid  ;
clWidth_t                    slice_0_axi_wdata   ;
logic           [ 31: 0]     slice_0_axi_wstrb   ;
logic                        slice_0_axi_wlast   ;
logic                        slice_0_axi_bready  ;
logic                        slice_0_axi_bvalid  ;
logic           [  1: 0]     slice_0_axi_bid     ;
logic           [  1: 0]     slice_0_axi_bresp   ;
logic                        slice_0_axi_arready ;
logic                        slice_0_axi_arvalid ;
logic           [  1: 0]     slice_0_axi_arid    ;
logic           [ 31: 0]     slice_0_axi_araddr  ;
logic           [  7: 0]     slice_0_axi_arlen   ;
logic           [  2: 0]     slice_0_axi_arsize  ;
logic           [  1: 0]     slice_0_axi_arburst ;
logic                        slice_0_axi_rready  ;
logic                        slice_0_axi_rvalid  ;
logic           [  1: 0]     slice_0_axi_rid     ;
clWidth_t                    slice_0_axi_rdata   ;
logic           [  1: 0]     slice_0_axi_rresp   ;
logic                        slice_0_axi_rlast   ;
logic                        slice_1_axi_awready ;
logic                        slice_1_axi_awvalid ;
logic           [  1: 0]     slice_1_axi_awid    ;
logic           [ 31: 0]     slice_1_axi_awaddr  ;
logic           [  7: 0]     slice_1_axi_awlen   ;
logic           [  2: 0]     slice_1_axi_awsize  ;
logic           [  1: 0]     slice_1_axi_awburst ;
logic                        slice_1_axi_wready  ;
logic                        slice_1_axi_wvalid  ;
clWidth_t                    slice_1_axi_wdata   ;
logic           [ 31: 0]     slice_1_axi_wstrb   ;
logic                        slice_1_axi_wlast   ;
logic                        slice_1_axi_bready  ;
logic                        slice_1_axi_bvalid  ;
logic           [  1: 0]     slice_1_axi_bid     ;
logic           [  1: 0]     slice_1_axi_bresp   ;
logic                        slice_1_axi_arready ;
logic                        slice_1_axi_arvalid ;
logic           [  1: 0]     slice_1_axi_arid    ;
logic           [ 31: 0]     slice_1_axi_araddr  ;
logic           [  7: 0]     slice_1_axi_arlen   ;
logic           [  2: 0]     slice_1_axi_arsize  ;
logic           [  1: 0]     slice_1_axi_arburst ;
logic                        slice_1_axi_rready  ;
logic                        slice_1_axi_rvalid  ;
logic           [  1: 0]     slice_1_axi_rid     ;
clWidth_t                    slice_1_axi_rdata   ;
logic           [  1: 0]     slice_1_axi_rresp   ;
logic                        slice_1_axi_rlast   ;
logic                        slice_2_axi_awready ;
logic                        slice_2_axi_awvalid ;
logic           [  1: 0]     slice_2_axi_awid    ;
logic           [ 31: 0]     slice_2_axi_awaddr  ;
logic           [  7: 0]     slice_2_axi_awlen   ;
logic           [  2: 0]     slice_2_axi_awsize  ;
logic           [  1: 0]     slice_2_axi_awburst ;
logic                        slice_2_axi_wready  ;
logic                        slice_2_axi_wvalid  ;
clWidth_t                    slice_2_axi_wdata   ;
logic           [ 31: 0]     slice_2_axi_wstrb   ;
logic                        slice_2_axi_wlast   ;
logic                        slice_2_axi_bready  ;
logic                        slice_2_axi_bvalid  ;
logic           [  1: 0]     slice_2_axi_bid     ;
logic           [  1: 0]     slice_2_axi_bresp   ;
logic                        slice_2_axi_arready ;
logic                        slice_2_axi_arvalid ;
logic           [  1: 0]     slice_2_axi_arid    ;
logic           [ 31: 0]     slice_2_axi_araddr  ;
logic           [  7: 0]     slice_2_axi_arlen   ;
logic           [  2: 0]     slice_2_axi_arsize  ;
logic           [  1: 0]     slice_2_axi_arburst ;
logic                        slice_2_axi_rready  ;
logic                        slice_2_axi_rvalid  ;
logic           [  1: 0]     slice_2_axi_rid     ;
clWidth_t                    slice_2_axi_rdata   ;
logic           [  1: 0]     slice_2_axi_rresp   ;
logic                        slice_2_axi_rlast   ;
logic                        slice_3_axi_awready ;
logic                        slice_3_axi_awvalid ;
logic           [  1: 0]     slice_3_axi_awid    ;
logic           [ 31: 0]     slice_3_axi_awaddr  ;
logic           [  7: 0]     slice_3_axi_awlen   ;
logic           [  2: 0]     slice_3_axi_awsize  ;
logic           [  1: 0]     slice_3_axi_awburst ;
logic                        slice_3_axi_wready  ;
logic                        slice_3_axi_wvalid  ;
clWidth_t                    slice_3_axi_wdata   ;
logic           [ 31: 0]     slice_3_axi_wstrb   ;
logic                        slice_3_axi_wlast   ;
logic                        slice_3_axi_bready  ;
logic                        slice_3_axi_bvalid  ;
logic           [  1: 0]     slice_3_axi_bid     ;
logic           [  1: 0]     slice_3_axi_bresp   ;
logic                        slice_3_axi_arready ;
logic                        slice_3_axi_arvalid ;
logic           [  1: 0]     slice_3_axi_arid    ;
logic           [ 31: 0]     slice_3_axi_araddr  ;
logic           [  7: 0]     slice_3_axi_arlen   ;
logic           [  2: 0]     slice_3_axi_arsize  ;
logic           [  1: 0]     slice_3_axi_arburst ;
logic                        slice_3_axi_rready  ;
logic                        slice_3_axi_rvalid  ;
logic           [  1: 0]     slice_3_axi_rid     ;
clWidth_t                    slice_3_axi_rdata   ;
logic           [  1: 0]     slice_3_axi_rresp   ;
logic                        slice_3_axi_rlast   ;


logic                        axi_awready         ;              
logic                        axi_awvalid         ;              
logic           [  1: 0]     axi_awid            ;              
logic           [ 31: 0]     axi_awaddr          ;              
logic           [  7: 0]     axi_awlen           ;              
logic           [  2: 0]     axi_awsize          ;              
logic           [  1: 0]     axi_awburst         ;              

logic                        axi_wready          ;              
logic                        axi_wvalid          ;              
logic           [255: 0]     axi_wdata           ;              
logic           [ 31: 0]     axi_wstrb           ;              
logic                        axi_wlast           ;              
logic                        axi_bready          ;              
logic                        axi_bvalid          ;              
logic           [  1: 0]     axi_bid             ;              
logic           [  1: 0]     axi_bresp           ;              

logic                        axi_arready         ;              
logic                        axi_arvalid         ;              
logic           [  1: 0]     axi_arid            ;              
logic           [ 31: 0]     axi_araddr          ;              
logic           [  7: 0]     axi_arlen           ;              
logic           [  2: 0]     axi_arsize          ;              
logic           [  1: 0]     axi_arburst         ;              

logic                        axi_rready          ;              
logic                        axi_rvalid          ;              
logic           [  1: 0]     axi_rid             ;              
logic           [255: 0]     axi_rdata           ;              
logic           [  1: 0]     axi_rresp           ;              
logic                        axi_rlast           ;              

assign u_channel_0_req_bus.op    = u_channel_0_req_bus_op   ;
assign u_channel_0_req_bus.size  = u_channel_0_req_bus_size ;
assign u_channel_0_req_bus.wdata = u_channel_0_req_bus_wdata;
assign u_channel_0_req_bus.addr  = u_channel_0_req_bus_addr ;

assign u_channel_1_req_bus.op    = u_channel_1_req_bus_op   ;
assign u_channel_1_req_bus.size  = u_channel_1_req_bus_size ;
assign u_channel_1_req_bus.wdata = u_channel_1_req_bus_wdata;
assign u_channel_1_req_bus.addr  = u_channel_1_req_bus_addr ;

assign u_channel_2_req_bus.op    = u_channel_2_req_bus_op   ;
assign u_channel_2_req_bus.size  = u_channel_2_req_bus_size ;
assign u_channel_2_req_bus.wdata = u_channel_2_req_bus_wdata;
assign u_channel_2_req_bus.addr  = u_channel_2_req_bus_addr ;


mpc # (
    .Cfg                       (Cfg                      ),
    .opWidth_t                 (opWidth_t                ),
    .clWidth_t                 (clWidth_t                ),
    .dataWidth_t               (dataWidth_t              ),
    .addrWidth_t               (addrWidth_t              ),
    .setWidth_t                (setWidth_t               ),
    .tagWidth_t                (tagWidth_t               ),
    .wayIndexWidth_t           (wayIndexWidth_t          ),
    .wbufWidth_t               (wbufWidth_t              ),
    .wayNum_t                  (wayNum_t                 ),
    .nlineWidth_t              (nlineWidth_t             ),
    .offsetWidth_t             (offsetWidth_t            ),
    .byteWidth_t               (byteWidth_t              ),
    .metaWidth_t               (metaWidth_t              ),
    .robWidth_t                (robWidth_t               ),
    .lsqWidth_t                (lsqWidth_t               ),
    .rfbufWidth_t              (rfbufWidth_t             ),
    .kobWidth_t                (kobWidth_t               ),
    .mcWidth_t                 (mcWidth_t                ),
    .channel_req_t             (channel_req_t            ),
    .bank_req_t                (bank_req_t               ),
    .wbuf_req_t                (wbuf_req_t               )
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

mem_intf_arbiter # (
    .Cfg                               (Cfg                ),     
    .clWidth_t                         (clWidth_t          ), 
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
) u_mem_intf_arb (
    .clk                               (clk                  ),
    .rst_n                             (rst_n                ),

    .slice_0_s_axi_awready             (slice_0_axi_awready  ), 
    .slice_0_s_axi_awvalid             (slice_0_axi_awvalid  ), 
    .slice_0_s_axi_awid                (slice_0_axi_awid     ), 
    .slice_0_s_axi_awaddr              (slice_0_axi_awaddr   ), 
    .slice_0_s_axi_awlen               (slice_0_axi_awlen    ), 
    .slice_0_s_axi_awsize              (slice_0_axi_awsize   ), 
    .slice_0_s_axi_awburst             (slice_0_axi_awburst  ), 
    .slice_0_s_axi_wready              (slice_0_axi_wready   ), 
    .slice_0_s_axi_wvalid              (slice_0_axi_wvalid   ), 
    .slice_0_s_axi_wdata               (slice_0_axi_wdata    ), 
    .slice_0_s_axi_wstrb               (slice_0_axi_wstrb    ), 
    .slice_0_s_axi_wlast               (slice_0_axi_wlast    ), 
    .slice_0_s_axi_bready              (slice_0_axi_bready   ), 
    .slice_0_s_axi_bvalid              (slice_0_axi_bvalid   ), 
    .slice_0_s_axi_bid                 (slice_0_axi_bid      ), 
    .slice_0_s_axi_bresp               (slice_0_axi_bresp    ), 
    .slice_0_s_axi_arready             (slice_0_axi_arready  ), 
    .slice_0_s_axi_arvalid             (slice_0_axi_arvalid  ), 
    .slice_0_s_axi_arid                (slice_0_axi_arid     ), 
    .slice_0_s_axi_araddr              (slice_0_axi_araddr   ), 
    .slice_0_s_axi_arlen               (slice_0_axi_arlen    ), 
    .slice_0_s_axi_arsize              (slice_0_axi_arsize   ), 
    .slice_0_s_axi_arburst             (slice_0_axi_arburst  ), 
    .slice_0_s_axi_rready              (slice_0_axi_rready   ), 
    .slice_0_s_axi_rvalid              (slice_0_axi_rvalid   ), 
    .slice_0_s_axi_rid                 (slice_0_axi_rid      ), 
    .slice_0_s_axi_rdata               (slice_0_axi_rdata    ), 
    .slice_0_s_axi_rresp               (slice_0_axi_rresp    ), 
    .slice_0_s_axi_rlast               (slice_0_axi_rlast    ), 
    .slice_1_s_axi_awready             (slice_1_axi_awready  ), 
    .slice_1_s_axi_awvalid             (slice_1_axi_awvalid  ), 
    .slice_1_s_axi_awid                (slice_1_axi_awid     ), 
    .slice_1_s_axi_awaddr              (slice_1_axi_awaddr   ), 
    .slice_1_s_axi_awlen               (slice_1_axi_awlen    ), 
    .slice_1_s_axi_awsize              (slice_1_axi_awsize   ), 
    .slice_1_s_axi_awburst             (slice_1_axi_awburst  ), 
    .slice_1_s_axi_wready              (slice_1_axi_wready   ), 
    .slice_1_s_axi_wvalid              (slice_1_axi_wvalid   ), 
    .slice_1_s_axi_wdata               (slice_1_axi_wdata    ), 
    .slice_1_s_axi_wstrb               (slice_1_axi_wstrb    ), 
    .slice_1_s_axi_wlast               (slice_1_axi_wlast    ), 
    .slice_1_s_axi_bready              (slice_1_axi_bready   ), 
    .slice_1_s_axi_bvalid              (slice_1_axi_bvalid   ), 
    .slice_1_s_axi_bid                 (slice_1_axi_bid      ), 
    .slice_1_s_axi_bresp               (slice_1_axi_bresp    ), 
    .slice_1_s_axi_arready             (slice_1_axi_arready  ), 
    .slice_1_s_axi_arvalid             (slice_1_axi_arvalid  ), 
    .slice_1_s_axi_arid                (slice_1_axi_arid     ), 
    .slice_1_s_axi_araddr              (slice_1_axi_araddr   ), 
    .slice_1_s_axi_arlen               (slice_1_axi_arlen    ), 
    .slice_1_s_axi_arsize              (slice_1_axi_arsize   ), 
    .slice_1_s_axi_arburst             (slice_1_axi_arburst  ), 
    .slice_1_s_axi_rready              (slice_1_axi_rready   ), 
    .slice_1_s_axi_rvalid              (slice_1_axi_rvalid   ), 
    .slice_1_s_axi_rid                 (slice_1_axi_rid      ), 
    .slice_1_s_axi_rdata               (slice_1_axi_rdata    ), 
    .slice_1_s_axi_rresp               (slice_1_axi_rresp    ), 
    .slice_1_s_axi_rlast               (slice_1_axi_rlast    ), 
    .slice_2_s_axi_awready             (slice_2_axi_awready  ), 
    .slice_2_s_axi_awvalid             (slice_2_axi_awvalid  ), 
    .slice_2_s_axi_awid                (slice_2_axi_awid     ), 
    .slice_2_s_axi_awaddr              (slice_2_axi_awaddr   ), 
    .slice_2_s_axi_awlen               (slice_2_axi_awlen    ), 
    .slice_2_s_axi_awsize              (slice_2_axi_awsize   ), 
    .slice_2_s_axi_awburst             (slice_2_axi_awburst  ), 
    .slice_2_s_axi_wready              (slice_2_axi_wready   ), 
    .slice_2_s_axi_wvalid              (slice_2_axi_wvalid   ), 
    .slice_2_s_axi_wdata               (slice_2_axi_wdata    ), 
    .slice_2_s_axi_wstrb               (slice_2_axi_wstrb    ), 
    .slice_2_s_axi_wlast               (slice_2_axi_wlast    ), 
    .slice_2_s_axi_bready              (slice_2_axi_bready   ), 
    .slice_2_s_axi_bvalid              (slice_2_axi_bvalid   ), 
    .slice_2_s_axi_bid                 (slice_2_axi_bid      ), 
    .slice_2_s_axi_bresp               (slice_2_axi_bresp    ), 
    .slice_2_s_axi_arready             (slice_2_axi_arready  ), 
    .slice_2_s_axi_arvalid             (slice_2_axi_arvalid  ), 
    .slice_2_s_axi_arid                (slice_2_axi_arid     ), 
    .slice_2_s_axi_araddr              (slice_2_axi_araddr   ), 
    .slice_2_s_axi_arlen               (slice_2_axi_arlen    ), 
    .slice_2_s_axi_arsize              (slice_2_axi_arsize   ), 
    .slice_2_s_axi_arburst             (slice_2_axi_arburst  ), 
    .slice_2_s_axi_rready              (slice_2_axi_rready   ), 
    .slice_2_s_axi_rvalid              (slice_2_axi_rvalid   ), 
    .slice_2_s_axi_rid                 (slice_2_axi_rid      ), 
    .slice_2_s_axi_rdata               (slice_2_axi_rdata    ), 
    .slice_2_s_axi_rresp               (slice_2_axi_rresp    ), 
    .slice_2_s_axi_rlast               (slice_2_axi_rlast    ), 
    .slice_3_s_axi_awready             (slice_3_axi_awready  ), 
    .slice_3_s_axi_awvalid             (slice_3_axi_awvalid  ), 
    .slice_3_s_axi_awid                (slice_3_axi_awid     ), 
    .slice_3_s_axi_awaddr              (slice_3_axi_awaddr   ), 
    .slice_3_s_axi_awlen               (slice_3_axi_awlen    ), 
    .slice_3_s_axi_awsize              (slice_3_axi_awsize   ), 
    .slice_3_s_axi_awburst             (slice_3_axi_awburst  ), 
    .slice_3_s_axi_wready              (slice_3_axi_wready   ), 
    .slice_3_s_axi_wvalid              (slice_3_axi_wvalid   ), 
    .slice_3_s_axi_wdata               (slice_3_axi_wdata    ), 
    .slice_3_s_axi_wstrb               (slice_3_axi_wstrb    ), 
    .slice_3_s_axi_wlast               (slice_3_axi_wlast    ), 
    .slice_3_s_axi_bready              (slice_3_axi_bready   ), 
    .slice_3_s_axi_bvalid              (slice_3_axi_bvalid   ), 
    .slice_3_s_axi_bid                 (slice_3_axi_bid      ), 
    .slice_3_s_axi_bresp               (slice_3_axi_bresp    ), 
    .slice_3_s_axi_arready             (slice_3_axi_arready  ), 
    .slice_3_s_axi_arvalid             (slice_3_axi_arvalid  ), 
    .slice_3_s_axi_arid                (slice_3_axi_arid     ), 
    .slice_3_s_axi_araddr              (slice_3_axi_araddr   ), 
    .slice_3_s_axi_arlen               (slice_3_axi_arlen    ), 
    .slice_3_s_axi_arsize              (slice_3_axi_arsize   ), 
    .slice_3_s_axi_arburst             (slice_3_axi_arburst  ), 
    .slice_3_s_axi_rready              (slice_3_axi_rready   ), 
    .slice_3_s_axi_rvalid              (slice_3_axi_rvalid   ), 
    .slice_3_s_axi_rid                 (slice_3_axi_rid      ), 
    .slice_3_s_axi_rdata               (slice_3_axi_rdata    ), 
    .slice_3_s_axi_rresp               (slice_3_axi_rresp    ), 
    .slice_3_s_axi_rlast               (slice_3_axi_rlast    ), 
    .m_axi_awready                     (axi_awready          ), 
    .m_axi_awvalid                     (axi_awvalid          ), 
    .m_axi_awid                        (axi_awid             ), 
    .m_axi_awaddr                      (axi_awaddr           ), 
    .m_axi_awlen                       (axi_awlen            ), 
    .m_axi_awsize                      (axi_awsize           ), 
    .m_axi_awburst                     (axi_awburst          ), 
    .m_axi_wready                      (axi_wready           ), 
    .m_axi_wvalid                      (axi_wvalid           ), 
    .m_axi_wdata                       (axi_wdata            ), 
    .m_axi_wstrb                       (axi_wstrb            ), 
    .m_axi_wlast                       (axi_wlast            ), 
    .m_axi_bready                      (axi_bready           ), 
    .m_axi_bvalid                      (axi_bvalid           ), 
    .m_axi_bid                         (axi_bid              ), 
    .m_axi_bresp                       (axi_bresp            ), 
    .m_axi_arready                     (axi_arready          ), 
    .m_axi_arvalid                     (axi_arvalid          ), 
    .m_axi_arid                        (axi_arid             ), 
    .m_axi_araddr                      (axi_araddr           ), 
    .m_axi_arlen                       (axi_arlen            ), 
    .m_axi_arsize                      (axi_arsize           ), 
    .m_axi_arburst                     (axi_arburst          ), 
    .m_axi_rready                      (axi_rready           ), 
    .m_axi_rvalid                      (axi_rvalid           ), 
    .m_axi_rid                         (axi_rid              ), 
    .m_axi_rdata                       (axi_rdata            ), 
    .m_axi_rresp                       (axi_rresp            ), 
    .m_axi_rlast                       (axi_rlast            )
);

memory_interface # (
    .Cfg                               (Cfg                  ),     
    .clWidth_t                         (clWidth_t            ), 
    .setWidth_t                        (setWidth_t           ),      
    .tagWidth_t                        (tagWidth_t           ),      
    .wayIndexWidth_t                   (wayIndexWidth_t      ),      
    .wbufWidth_t                       (wbufWidth_t          ),      
    .wayNum_t                          (wayNum_t             ),      
    .nlineWidth_t                      (nlineWidth_t         ),      
    .offsetWidth_t                     (offsetWidth_t        ),      
    .metaWidth_t                       (metaWidth_t          ),      
    .robWidth_t                        (robWidth_t           ),      
    .lsqWidth_t                        (lsqWidth_t           ),      
    .kobWidth_t                        (kobWidth_t           ), 
    .mcWidth_t                         (mcWidth_t            )
) u_mem_intf (
    .clk                               (clk                  ),
    .rst_n                             (rst_n                ),
         
    .s_axi_awready                     (axi_awready          ),
    .s_axi_awvalid                     (axi_awvalid          ),
    .s_axi_awid                        (axi_awid             ),
    .s_axi_awaddr                      (axi_awaddr           ),
    .s_axi_awlen                       (axi_awlen            ),
    .s_axi_awsize                      (axi_awsize           ),
    .s_axi_awburst                     (axi_awburst          ),
    .s_axi_wready                      (axi_wready           ),
    .s_axi_wvalid                      (axi_wvalid           ),
    .s_axi_wdata                       (axi_wdata            ),
    .s_axi_wstrb                       (axi_wstrb            ),
    .s_axi_wlast                       (axi_wlast            ),
    .s_axi_bready                      (axi_bready           ),
    .s_axi_bvalid                      (axi_bvalid           ),
    .s_axi_bid                         (axi_bid              ),
    .s_axi_bresp                       (axi_bresp            ),
    .s_axi_arready                     (axi_arready          ),
    .s_axi_arvalid                     (axi_arvalid          ),
    .s_axi_arid                        (axi_arid             ),
    .s_axi_araddr                      (axi_araddr           ),
    .s_axi_arlen                       (axi_arlen            ),
    .s_axi_arsize                      (axi_arsize           ),
    .s_axi_arburst                     (axi_arburst          ),
    .s_axi_rready                      (axi_rready           ),
    .s_axi_rvalid                      (axi_rvalid           ),
    .s_axi_rid                         (axi_rid              ),
    .s_axi_rdata                       (axi_rdata            ),
    .s_axi_rresp                       (axi_rresp            ),
    .s_axi_rlast                       (axi_rlast            )
);

endmodule