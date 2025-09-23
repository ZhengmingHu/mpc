module tb_mem_intf_arbiter;
    import mpc_types::*;

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
 };

parameter mpc_cfg_t Cfg = mpcBuildConfig(UserCfg);
parameter type clWidth_t       = logic [Cfg.u.clWidth-1:0];
parameter type addrWidth_t     = logic [Cfg.u.addrWidth-1:0];
parameter type setWidth_t      = logic [Cfg.setWidth-1:0];
parameter type tagWidth_t      = logic [Cfg.tagWidth-1:0];
parameter type wayIndexWidth_t = logic [Cfg.wayIndexWidth-1:0];
parameter type wbufWidth_t     = logic [Cfg.wbufWidth-1:0];
parameter type wayNum_t        = logic [Cfg.wayNum-1:0];
parameter type nlineWidth_t    = logic [Cfg.nlineWidth-1:0];
parameter type offsetWidth_t   = logic [Cfg.offsetWidth-1:0];
parameter type metaWidth_t     = logic [Cfg.metaWidth-1:0];
parameter type robWidth_t      = logic [Cfg.robWidth-1:0];
parameter type lsqWidth_t      = logic [Cfg.lsqWidth-1:0];
parameter type rfbufWidth_t    = logic [Cfg.rfbufWidth-1:0];
parameter type kobWidth_t      = logic [Cfg.kobWidth-1:0];
parameter type mcWidth_t       = logic [Cfg.mcWidth-1:0];


logic                        clk                   ;
logic                        rst_n                 ;
logic                        slice_0_s_axi_awready ;
logic                        slice_0_s_axi_awvalid ;
logic           [  1: 0]     slice_0_s_axi_awid    ;
logic           [ 31: 0]     slice_0_s_axi_awaddr  ;
logic           [  7: 0]     slice_0_s_axi_awlen   ;
logic           [  2: 0]     slice_0_s_axi_awsize  ;
logic           [  1: 0]     slice_0_s_axi_awburst ;
logic                        slice_0_s_axi_wready  ;
logic                        slice_0_s_axi_wvalid  ;
logic           [255: 0]     slice_0_s_axi_wdata   ;
logic           [ 31: 0]     slice_0_s_axi_wstrb   ;
logic                        slice_0_s_axi_wlast   ;
logic                        slice_0_s_axi_bready  ;
logic                        slice_0_s_axi_bvalid  ;
logic           [  1: 0]     slice_0_s_axi_bid     ;
logic           [  1: 0]     slice_0_s_axi_bresp   ;
logic                        slice_0_s_axi_arready ;
logic                        slice_0_s_axi_arvalid ;
logic           [  1: 0]     slice_0_s_axi_arid    ;
logic           [ 31: 0]     slice_0_s_axi_araddr  ;
logic           [  7: 0]     slice_0_s_axi_arlen   ;
logic           [  2: 0]     slice_0_s_axi_arsize  ;
logic           [  1: 0]     slice_0_s_axi_arburst ;
logic                        slice_0_s_axi_rready  ;
logic                        slice_0_s_axi_rvalid  ;
logic           [  1: 0]     slice_0_s_axi_rid     ;
logic           [255: 0]     slice_0_s_axi_rdata   ;
logic           [  1: 0]     slice_0_s_axi_rresp   ;
logic                        slice_0_s_axi_rlast   ;
logic                        slice_1_s_axi_awready ;
logic                        slice_1_s_axi_awvalid ;
logic           [  1: 0]     slice_1_s_axi_awid    ;
logic           [ 31: 0]     slice_1_s_axi_awaddr  ;
logic           [  7: 0]     slice_1_s_axi_awlen   ;
logic           [  2: 0]     slice_1_s_axi_awsize  ;
logic           [  1: 0]     slice_1_s_axi_awburst ;
logic                        slice_1_s_axi_wready  ;
logic                        slice_1_s_axi_wvalid  ;
logic           [255: 0]     slice_1_s_axi_wdata   ;
logic           [ 31: 0]     slice_1_s_axi_wstrb   ;
logic                        slice_1_s_axi_wlast   ;
logic                        slice_1_s_axi_bready  ;
logic                        slice_1_s_axi_bvalid  ;
logic           [  1: 0]     slice_1_s_axi_bid     ;
logic           [  1: 0]     slice_1_s_axi_bresp   ;
logic                        slice_1_s_axi_arready ;
logic                        slice_1_s_axi_arvalid ;
logic           [  1: 0]     slice_1_s_axi_arid    ;
logic           [ 31: 0]     slice_1_s_axi_araddr  ;
logic           [  7: 0]     slice_1_s_axi_arlen   ;
logic           [  2: 0]     slice_1_s_axi_arsize  ;
logic           [  1: 0]     slice_1_s_axi_arburst ;
logic                        slice_1_s_axi_rready  ;
logic                        slice_1_s_axi_rvalid  ;
logic           [  1: 0]     slice_1_s_axi_rid     ;
logic           [255: 0]     slice_1_s_axi_rdata   ;
logic           [  1: 0]     slice_1_s_axi_rresp   ;
logic                        slice_1_s_axi_rlast   ;
logic                        slice_2_s_axi_awready ;
logic                        slice_2_s_axi_awvalid ;
logic           [  1: 0]     slice_2_s_axi_awid    ;
logic           [ 31: 0]     slice_2_s_axi_awaddr  ;
logic           [  7: 0]     slice_2_s_axi_awlen   ;
logic           [  2: 0]     slice_2_s_axi_awsize  ;
logic           [  1: 0]     slice_2_s_axi_awburst ;
logic                        slice_2_s_axi_wready  ;
logic                        slice_2_s_axi_wvalid  ;
logic           [255: 0]     slice_2_s_axi_wdata   ;
logic           [ 31: 0]     slice_2_s_axi_wstrb   ;
logic                        slice_2_s_axi_wlast   ;
logic                        slice_2_s_axi_bready  ;
logic                        slice_2_s_axi_bvalid  ;
logic           [  1: 0]     slice_2_s_axi_bid     ;
logic           [  1: 0]     slice_2_s_axi_bresp   ;
logic                        slice_2_s_axi_arready ;
logic                        slice_2_s_axi_arvalid ;
logic           [  1: 0]     slice_2_s_axi_arid    ;
logic           [ 31: 0]     slice_2_s_axi_araddr  ;
logic           [  7: 0]     slice_2_s_axi_arlen   ;
logic           [  2: 0]     slice_2_s_axi_arsize  ;
logic           [  1: 0]     slice_2_s_axi_arburst ;
logic                        slice_2_s_axi_rready  ;
logic                        slice_2_s_axi_rvalid  ;
logic           [  1: 0]     slice_2_s_axi_rid     ;
logic           [255: 0]     slice_2_s_axi_rdata   ;
logic           [  1: 0]     slice_2_s_axi_rresp   ;
logic                        slice_2_s_axi_rlast   ;
logic                        slice_3_s_axi_awready ;
logic                        slice_3_s_axi_awvalid ;
logic           [  1: 0]     slice_3_s_axi_awid    ;
logic           [ 31: 0]     slice_3_s_axi_awaddr  ;
logic           [  7: 0]     slice_3_s_axi_awlen   ;
logic           [  2: 0]     slice_3_s_axi_awsize  ;
logic           [  1: 0]     slice_3_s_axi_awburst ;
logic                        slice_3_s_axi_wready  ;
logic                        slice_3_s_axi_wvalid  ;
logic           [255: 0]     slice_3_s_axi_wdata   ;
logic           [ 31: 0]     slice_3_s_axi_wstrb   ;
logic                        slice_3_s_axi_wlast   ;
logic                        slice_3_s_axi_bready  ;
logic                        slice_3_s_axi_bvalid  ;
logic           [  1: 0]     slice_3_s_axi_bid     ;
logic           [  1: 0]     slice_3_s_axi_bresp   ;
logic                        slice_3_s_axi_arready ;
logic                        slice_3_s_axi_arvalid ;
logic           [  1: 0]     slice_3_s_axi_arid    ;
logic           [ 31: 0]     slice_3_s_axi_araddr  ;
logic           [  7: 0]     slice_3_s_axi_arlen   ;
logic           [  2: 0]     slice_3_s_axi_arsize  ;
logic           [  1: 0]     slice_3_s_axi_arburst ;
logic                        slice_3_s_axi_rready  ;
logic                        slice_3_s_axi_rvalid  ;
logic           [  1: 0]     slice_3_s_axi_rid     ;
logic           [255: 0]     slice_3_s_axi_rdata   ;
logic           [  1: 0]     slice_3_s_axi_rresp   ;
logic                        slice_3_s_axi_rlast   ;

logic                        axi_awready           ;        
logic                        axi_awvalid           ;        
logic           [  1: 0]     axi_awid              ;        
logic           [ 31: 0]     axi_awaddr            ;        
logic           [  7: 0]     axi_awlen             ;        
logic           [  2: 0]     axi_awsize            ;        
logic           [  1: 0]     axi_awburst           ;        
logic                        axi_wready            ;        
logic                        axi_wvalid            ;        
logic           [255: 0]     axi_wdata             ;        
logic           [ 31: 0]     axi_wstrb             ;        
logic                        axi_wlast             ;        
logic                        axi_bready            ;        
logic                        axi_bvalid            ;        
logic           [  1: 0]     axi_bid               ;        
logic           [  1: 0]     axi_bresp             ;        
logic                        axi_arready           ;        
logic                        axi_arvalid           ;        
logic           [  1: 0]     axi_arid              ;        
logic           [ 31: 0]     axi_araddr            ;        
logic           [  7: 0]     axi_arlen             ;        
logic           [  2: 0]     axi_arsize            ;        
logic           [  1: 0]     axi_arburst           ;        
logic                        axi_rready            ;    
logic                        axi_rvalid            ;    
logic           [  1: 0]     axi_rid               ;    
logic           [255: 0]     axi_rdata             ;    
logic           [  1: 0]     axi_rresp             ;    
logic                        axi_rlast             ;    

always# 10  clk = ~clk;

reg [1024:0] FSDB_FILE;
initial begin
    if ($value$plusargs("FSDB_FILE=%s", FSDB_FILE)) begin
        $fsdbDumpfile(FSDB_FILE);
        $fsdbDumpvars("+all");
    end
end

initial begin
    clk     = 1'b0;
    rst_n   = 1'b0;
    #453
    rst_n   = 1'b1;
end

initial begin
    #20000;
    $finish;
end

initial begin

    slice_0_s_axi_awvalid = 'd0;
    slice_0_s_axi_awid    = 'd0;
    slice_0_s_axi_awaddr  = 'd0;
    slice_0_s_axi_awlen   = 'd0;
    slice_0_s_axi_awsize  = 'd0;
    slice_0_s_axi_awburst = 'd0;
    slice_0_s_axi_wvalid  = 'd0;
    slice_0_s_axi_wdata   = 'd0;
    slice_0_s_axi_wstrb   = 'd0;
    slice_0_s_axi_wlast   = 'd0;
    slice_0_s_axi_bready  = 'd1;
    slice_0_s_axi_arvalid = 'd0;
    slice_0_s_axi_arid    = 'd0;
    slice_0_s_axi_araddr  = 'd0;
    slice_0_s_axi_arlen   = 'd0;
    slice_0_s_axi_arsize  = 'd0;
    slice_0_s_axi_arburst = 'd0;
    slice_0_s_axi_rready  = 'd1;

    slice_1_s_axi_awvalid = 'd0;
    slice_1_s_axi_awid    = 'd0;
    slice_1_s_axi_awaddr  = 'd0;
    slice_1_s_axi_awlen   = 'd0;
    slice_1_s_axi_awsize  = 'd0;
    slice_1_s_axi_awburst = 'd0;
    slice_1_s_axi_wvalid  = 'd0;
    slice_1_s_axi_wdata   = 'd0;
    slice_1_s_axi_wstrb   = 'd0;
    slice_1_s_axi_wlast   = 'd0;
    slice_1_s_axi_bready  = 'd1;
    slice_1_s_axi_arvalid = 'd0;
    slice_1_s_axi_arid    = 'd0;
    slice_1_s_axi_araddr  = 'd0;
    slice_1_s_axi_arlen   = 'd0;
    slice_1_s_axi_arsize  = 'd0;
    slice_1_s_axi_arburst = 'd0;
    slice_1_s_axi_rready  = 'd1;

    slice_2_s_axi_awvalid = 'd0;
    slice_2_s_axi_awid    = 'd0;
    slice_2_s_axi_awaddr  = 'd0;
    slice_2_s_axi_awlen   = 'd0;
    slice_2_s_axi_awsize  = 'd0;
    slice_2_s_axi_awburst = 'd0;
    slice_2_s_axi_wvalid  = 'd0;
    slice_2_s_axi_wdata   = 'd0;
    slice_2_s_axi_wstrb   = 'd0;
    slice_2_s_axi_wlast   = 'd0;
    slice_2_s_axi_bready  = 'd1;
    slice_2_s_axi_arvalid = 'd0;
    slice_2_s_axi_arid    = 'd0;
    slice_2_s_axi_araddr  = 'd0;
    slice_2_s_axi_arlen   = 'd0;
    slice_2_s_axi_arsize  = 'd0;
    slice_2_s_axi_arburst = 'd0;
    slice_2_s_axi_rready  = 'd1;

    slice_3_s_axi_awvalid = 'd0;
    slice_3_s_axi_awid    = 'd0;
    slice_3_s_axi_awaddr  = 'd0;
    slice_3_s_axi_awlen   = 'd0;
    slice_3_s_axi_awsize  = 'd0;
    slice_3_s_axi_awburst = 'd0;
    slice_3_s_axi_wvalid  = 'd0;
    slice_3_s_axi_wdata   = 'd0;
    slice_3_s_axi_wstrb   = 'd0;
    slice_3_s_axi_wlast   = 'd0;
    slice_3_s_axi_bready  = 'd1;
    slice_3_s_axi_arvalid = 'd0;
    slice_3_s_axi_arid    = 'd0;
    slice_3_s_axi_araddr  = 'd0;
    slice_3_s_axi_arlen   = 'd0;
    slice_3_s_axi_arsize  = 'd0;
    slice_3_s_axi_arburst = 'd0;
    slice_3_s_axi_rready  = 'd1;

    
    #500;
    @(posedge clk) // IDLE
    slice_0_s_axi_awvalid = 'd1;
    slice_0_s_axi_awid    = 'd0;
    slice_0_s_axi_awaddr  = 'h1000;
    slice_0_s_axi_wvalid  = 'd1;
    slice_0_s_axi_wdata   = 'haaaa_bbbb_cccc_dddd;

    @(posedge clk) // IDLE -> GNT_0
    slice_1_s_axi_arvalid = 'd1;
    slice_1_s_axi_arid    = 'd1;
    slice_1_s_axi_araddr  = 'h1000;

    @(posedge clk) // GNT_0 write
    slice_0_s_axi_awvalid = 'd0;
    slice_0_s_axi_awid    = 'd0;
    slice_0_s_axi_awaddr  = 'd0;
    slice_0_s_axi_wvalid  = 'd0;
    slice_0_s_axi_wdata   = 'd0;

    @(posedge clk) // GNT_0 -> IDLE

    @(posedge clk) // IDLE -> GNT_1

    @(posedge clk) // GNT_1 read
    slice_1_s_axi_arvalid = 'd0;
    slice_1_s_axi_arid    = 'd0;
    slice_1_s_axi_araddr  = 'd0;

    @(posedge clk) // GNT_1 -> IDLE
    slice_0_s_axi_awvalid = 'd1;
    slice_0_s_axi_awid    = 'd0;
    slice_0_s_axi_awaddr  = 'h2000;
    slice_0_s_axi_wvalid  = 'd1;
    slice_0_s_axi_wdata   = 'hcccc_dddd_eeee_ffff;

    slice_2_s_axi_awvalid = 'd1;
    slice_2_s_axi_awid    = 'd0;
    slice_2_s_axi_awaddr  = 'h3000;
    slice_2_s_axi_wvalid  = 'd1;
    slice_2_s_axi_wdata   = 'h1111_2222_3333_4444;
    
    @(posedge clk) // IDLE -> GNT_2

    @(posedge clk) // GNT_2 write
    slice_2_s_axi_awvalid = 'd0;
    slice_2_s_axi_awid    = 'd0;
    slice_2_s_axi_awaddr  = 'd0;
    slice_2_s_axi_wvalid  = 'd0;
    slice_2_s_axi_wdata   = 'd0;

    @(posedge clk) // GNT_2 -> IDLE
    slice_3_s_axi_arvalid = 'd1;
    slice_3_s_axi_arid    = 'd1;
    slice_3_s_axi_araddr  = 'h3000;

    @(posedge clk) // IDLE -> GNT_3

    @(posedge clk) // GNT_3 read
    slice_3_s_axi_arvalid = 'd0;
    slice_3_s_axi_arid    = 'd0;
    slice_3_s_axi_araddr  = 'd0;

    @(posedge clk) // GNT_3 -> IDLE
    
    @(posedge clk) // IDLE -> GNT_0

    @(posedge clk) // GNT_0 write
    slice_0_s_axi_awvalid = 'd0;
    slice_0_s_axi_awid    = 'd0;
    slice_0_s_axi_awaddr  = 'd0;
    slice_0_s_axi_wvalid  = 'd0;
    slice_0_s_axi_wdata   = 'd0;

    
end

mem_intf_arbiter # (
    .Cfg                                (Cfg                       ),
    .clWidth_t                          (clWidth_t                 ),
    .addrWidth_t                        (addrWidth_t               ),      
    .setWidth_t                         (setWidth_t                ),      
    .tagWidth_t                         (tagWidth_t                ),      
    .wayIndexWidth_t                    (wayIndexWidth_t           ),      
    .wbufWidth_t                        (wbufWidth_t               ),      
    .wayNum_t                           (wayNum_t                  ),      
    .nlineWidth_t                       (nlineWidth_t              ),      
    .offsetWidth_t                      (offsetWidth_t             ),      
    .metaWidth_t                        (metaWidth_t               ),      
    .robWidth_t                         (robWidth_t                ),      
    .lsqWidth_t                         (lsqWidth_t                ),      
    .kobWidth_t                         (kobWidth_t                ), 
    .mcWidth_t                          (mcWidth_t                 )
) u_mem_intf_arb (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .m_axi_awready                      (axi_awready               ),
    .m_axi_awvalid                      (axi_awvalid               ),
    .m_axi_awid                         (axi_awid                  ),
    .m_axi_awaddr                       (axi_awaddr                ),
    .m_axi_awlen                        (axi_awlen                 ),
    .m_axi_awsize                       (axi_awsize                ),
    .m_axi_awburst                      (axi_awburst               ),
    .m_axi_wready                       (axi_wready                ),
    .m_axi_wvalid                       (axi_wvalid                ),
    .m_axi_wdata                        (axi_wdata                 ),
    .m_axi_wstrb                        (axi_wstrb                 ),
    .m_axi_wlast                        (axi_wlast                 ),
    .m_axi_bready                       (axi_bready                ),
    .m_axi_bvalid                       (axi_bvalid                ),
    .m_axi_bid                          (axi_bid                   ),
    .m_axi_bresp                        (axi_bresp                 ),
    .m_axi_arready                      (axi_arready               ),
    .m_axi_arvalid                      (axi_arvalid               ),
    .m_axi_arid                         (axi_arid                  ),
    .m_axi_araddr                       (axi_araddr                ),
    .m_axi_arlen                        (axi_arlen                 ),
    .m_axi_arsize                       (axi_arsize                ),
    .m_axi_arburst                      (axi_arburst               ),
    .m_axi_rready                       (axi_rready                ),
    .m_axi_rvalid                       (axi_rvalid                ),
    .m_axi_rid                          (axi_rid                   ),
    .m_axi_rdata                        (axi_rdata                 ),
    .m_axi_rresp                        (axi_rresp                 ),
    .m_axi_rlast                        (axi_rlast                 ),
    .*
);

memory_interface # (
    .Cfg                                (Cfg                       ),
    .clWidth_t                          (clWidth_t                 ),
    .setWidth_t                         (setWidth_t                ),
    .tagWidth_t                         (tagWidth_t                ),
    .wayIndexWidth_t                    (wayIndexWidth_t           ),
    .wbufWidth_t                        (wbufWidth_t               ),
    .wayNum_t                           (wayNum_t                  ),
    .nlineWidth_t                       (nlineWidth_t              ),
    .offsetWidth_t                      (offsetWidth_t             ),
    .metaWidth_t                        (metaWidth_t               ),
    .robWidth_t                         (robWidth_t                ),
    .lsqWidth_t                         (lsqWidth_t                ),
    .kobWidth_t                         (kobWidth_t                ),
    .mcWidth_t                          (mcWidth_t                 )
) u_mem_intf (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .s_axi_awready                      (axi_awready               ),
    .s_axi_awvalid                      (axi_awvalid               ),
    .s_axi_awid                         (axi_awid                  ),
    .s_axi_awaddr                       (axi_awaddr                ),
    .s_axi_awlen                        (axi_awlen                 ),
    .s_axi_awsize                       (axi_awsize                ),
    .s_axi_awburst                      (axi_awburst               ),
    .s_axi_wready                       (axi_wready                ),
    .s_axi_wvalid                       (axi_wvalid                ),
    .s_axi_wdata                        (axi_wdata                 ),
    .s_axi_wstrb                        (axi_wstrb                 ),
    .s_axi_wlast                        (axi_wlast                 ),
    .s_axi_bready                       (axi_bready                ),
    .s_axi_bvalid                       (axi_bvalid                ),
    .s_axi_bid                          (axi_bid                   ),
    .s_axi_bresp                        (axi_bresp                 ),
    .s_axi_arready                      (axi_arready               ),
    .s_axi_arvalid                      (axi_arvalid               ),
    .s_axi_arid                         (axi_arid                  ),
    .s_axi_araddr                       (axi_araddr                ),
    .s_axi_arlen                        (axi_arlen                 ),
    .s_axi_arsize                       (axi_arsize                ),
    .s_axi_arburst                      (axi_arburst               ),
    .s_axi_rready                       (axi_rready                ),
    .s_axi_rvalid                       (axi_rvalid                ),
    .s_axi_rid                          (axi_rid                   ),
    .s_axi_rdata                        (axi_rdata                 ),
    .s_axi_rresp                        (axi_rresp                 ),
    .s_axi_rlast                        (axi_rlast                 )   
);


endmodule