module tb_extmem;
    import mpc_types::*;

 parameter mpc_user_cfg_t UserCfg = '{
     clWidth:256,
     clWordWidth:128,
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

logic                        clk                        ;
logic                        rst_n                      ;

logic                        awvalid                    ;
logic                        awready                    ;
nlineWidth_t                 awid                       ;
logic           [ 31: 0]     awaddr                     ;

logic                        wvalid                     ;
logic                        wready                     ;
nlineWidth_t                 wid                        ;
logic           [255: 0]     wdata                      ;

logic                        arvalid                    ;
logic                        arready                    ;
nlineWidth_t                 arid                       ;
logic           [ 31: 0]     araddr                     ;

logic                        rvalid                     ;
logic                        rready                     ;
nlineWidth_t                 rid                        ;
logic           [255: 0]     rdata                      ;

logic                        axi_awready                ;
logic                        axi_awvalid                ;
nlineWidth_t                 axi_awid                   ;
logic           [ 31: 0]     axi_awaddr                 ;
logic           [  7: 0]     axi_awlen                  ;
logic           [  2: 0]     axi_awsize                 ;
logic           [  1: 0]     axi_awburst                ;

logic                        axi_wready                 ;
logic                        axi_wvalid                 ;
logic           [255: 0]     axi_wdata                  ;
logic           [ 31: 0]     axi_wstrb                  ;
logic                        axi_wlast                  ;
logic                        axi_bready                 ;
logic                        axi_bvalid                 ;
nlineWidth_t                 axi_bid                    ;
logic           [  1: 0]     axi_bresp                  ;

logic                        axi_arready                ;
logic                        axi_arvalid                ;
nlineWidth_t                 axi_arid                   ;
logic           [ 31: 0]     axi_araddr                 ;
logic           [  7: 0]     axi_arlen                  ;
logic           [  2: 0]     axi_arsize                 ;
logic           [  1: 0]     axi_arburst                ;

logic                        axi_rready                 ;
logic                        axi_rvalid                 ;
nlineWidth_t                 axi_rid                    ;
logic           [255: 0]     axi_rdata                  ;
logic           [  1: 0]     axi_rresp                  ;
logic                        axi_rlast                  ;

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
    awvalid        = 'd0;
    awid           = 'd0;
    awaddr         = 'd0;

    wvalid         = 'd0;         
    wid            = 'd0;     
    wdata          = 'd0;         

    arvalid        = 'd0;
    arid           = 'd0; 
    araddr         = 'd0; 

    rready         = 'd1;
    
    #500;
    @(posedge clk)
    awvalid        <= 'd1;
    awid           <= 'd7;
    awaddr         <= 'h8000;
    
    @(posedge clk)
    awvalid        <= 'd1;
    awid           <= 'd5;
    awaddr         <= 'h8020;

    wvalid         <= 'd1;
    wid            <= 'd7;
    wdata          <= 'haaaa_bbbb_cccc_dddd;

    @(posedge clk)
    awvalid        <= 'd0;
    awid           <= 'd0;
    awaddr         <= 'd0;

    arvalid        <= 'd1;
    arid           <= 'd3;
    araddr         <= 'h8000;
    
    wvalid         <= 'd1;
    wid            <= 'd5;
    wdata          <= 'heeee_ffff_cccc_dddd;

    @(posedge clk)  
    arvalid        <= 'd1;
    arid           <= 'd6;
    araddr         <= 'h8020;

    wvalid         <= 'd0;
    wid            <= 'd0;
    wdata          <= 'h0;

    @(posedge clk)
    arvalid        <= 'd0;
    arid           <= 'd0;
    araddr         <= 'h0;
end

mc_wrapper # (
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
) u_mc_wrapper (
    .clk                (clk        ),
    .rst_n              (rst_n      ),
    
    .awvalid            (awvalid    ),    
    .awready            (awready    ),
    .awid               (awid       ),    
    .awaddr             (awaddr     ),
    .wvalid             (wvalid     ),
    .wready             (wready     ),
    .wid                (wid        ),                       
    .wdata              (wdata      ),    
    .arvalid            (arvalid    ),
    .arready            (arready    ),
    .arid               (arid       ),              
    .araddr             (araddr     ),            
    .rvalid             (rvalid     ),           
    .rready             (rready     ),        
    .rid                (rid        ),         
    .rdata              (rdata      ),              
    .m_axi_awready      (axi_awready),
    .m_axi_awvalid      (axi_awvalid),
    .m_axi_awid         (axi_awid   ),
    .m_axi_awaddr       (axi_awaddr ),
    .m_axi_awlen        (axi_awlen  ),
    .m_axi_awsize       (axi_awsize ),
    .m_axi_awburst      (axi_awburst),
    .m_axi_wready       (axi_wready ),
    .m_axi_wvalid       (axi_wvalid ),
    .m_axi_wdata        (axi_wdata  ),
    .m_axi_wstrb        (axi_wstrb  ),
    .m_axi_wlast        (axi_wlast  ),
    .m_axi_bready       (axi_bready ),
    .m_axi_bvalid       (axi_bvalid ),
    .m_axi_bid          (axi_bid    ),
    .m_axi_bresp        (axi_bresp  ),
    .m_axi_arready      (axi_arready),
    .m_axi_arvalid      (axi_arvalid),
    .m_axi_arid         (axi_arid   ),
    .m_axi_araddr       (axi_araddr ),
    .m_axi_arlen        (axi_arlen  ),
    .m_axi_arsize       (axi_arsize ),
    .m_axi_arburst      (axi_arburst),
    .m_axi_rready       (axi_rready ),
    .m_axi_rvalid       (axi_rvalid ),
    .m_axi_rid          (axi_rid    ),
    .m_axi_rdata        (axi_rdata  ),
    .m_axi_rresp        (axi_rresp  ),
    .m_axi_rlast        (axi_rlast  )

);

memory_interface # (
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
) u_mem_intf (
    .clk                (clk        ),
    .rst_n              (rst_n      ),

    .s_axi_awready      (axi_awready),
    .s_axi_awvalid      (axi_awvalid),
    .s_axi_awid         (axi_awid   ),
    .s_axi_awaddr       (axi_awaddr ),
    .s_axi_awlen        (axi_awlen  ),
    .s_axi_awsize       (axi_awsize ),
    .s_axi_awburst      (axi_awburst),
    .s_axi_wready       (axi_wready ),
    .s_axi_wvalid       (axi_wvalid ),
    .s_axi_wdata        (axi_wdata  ),
    .s_axi_wstrb        (axi_wstrb  ),
    .s_axi_wlast        (axi_wlast  ),
    .s_axi_bready       (axi_bready ),
    .s_axi_bvalid       (axi_bvalid ),
    .s_axi_bid          (axi_bid    ),
    .s_axi_bresp        (axi_bresp  ),
    .s_axi_arready      (axi_arready),
    .s_axi_arvalid      (axi_arvalid),
    .s_axi_arid         (axi_arid   ),
    .s_axi_araddr       (axi_araddr ),
    .s_axi_arlen        (axi_arlen  ),
    .s_axi_arsize       (axi_arsize ),
    .s_axi_arburst      (axi_arburst),
    .s_axi_rready       (axi_rready ),
    .s_axi_rvalid       (axi_rvalid ),
    .s_axi_rid          (axi_rid    ),
    .s_axi_rdata        (axi_rdata  ),
    .s_axi_rresp        (axi_rresp  ),
    .s_axi_rlast        (axi_rlast  )
);


endmodule