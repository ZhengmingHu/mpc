module tb_mc_wrapper;
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

logic                        m_axi_awready              ;
logic                        m_axi_awvalid              ;
nlineWidth_t                 m_axi_awid                 ;
logic           [ 31: 0]     m_axi_awaddr               ;
logic           [  7: 0]     m_axi_awlen                ;
logic           [  2: 0]     m_axi_awsize               ;
logic           [  1: 0]     m_axi_awburst              ;

logic                        m_axi_wready               ;
logic                        m_axi_wvalid               ;
logic           [255: 0]     m_axi_wdata                ;
logic           [ 31: 0]     m_axi_wstrb                ;
logic                        m_axi_wlast                ;
logic                        m_axi_bready               ;
logic                        m_axi_bvalid               ;
nlineWidth_t                 m_axi_bid                  ;
logic           [  1: 0]     m_axi_bresp                ;

logic                        m_axi_arready              ;
logic                        m_axi_arvalid              ;
nlineWidth_t                 m_axi_arid                 ;
logic           [ 31: 0]     m_axi_araddr               ;
logic           [  7: 0]     m_axi_arlen                ;
logic           [  2: 0]     m_axi_arsize               ;
logic           [  1: 0]     m_axi_arburst              ;

logic                        m_axi_rready               ;
logic                        m_axi_rvalid               ;
nlineWidth_t                 m_axi_rid                  ;
logic           [255: 0]     m_axi_rdata                ;
logic           [  1: 0]     m_axi_rresp                ;
logic                        m_axi_rlast                ;

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

    m_axi_awready  = 'd0;
    m_axi_wready   = 'd0;   
    m_axi_arready  = 'd0;

    m_axi_rvalid   = 'd0;
    m_axi_rid      = 'd0;
    m_axi_rdata    = 'd0;
    m_axi_rresp    = 'd0;
    m_axi_rlast    = 'd0;

    m_axi_bvalid   = 'd0;
    m_axi_bid      = 'd0;
    m_axi_bresp    = 'd0;
    
    #500;
    @(posedge clk)
    awvalid        <= 'd1;
    awid           <= 'd7;
    awaddr         <= 'h8000;
    
    m_axi_awready  <= 'd0;
    m_axi_wready   <= 'd0;
    m_axi_arready  <= 'd0;
    
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
    araddr         <= 'h8010;
    
    wvalid         <= 'd1;
    wid            <= 'd5;
    wdata          <= 'heeee_ffff_cccc_dddd;

    @(posedge clk)  
    arvalid        <= 'd1;
    arid           <= 'd6;
    araddr         <= 'h8030;

    wvalid         <= 'd0;
    wid            <= 'd0;
    wdata          <= 'h0;

    m_axi_awready  <= 'd0;
    m_axi_wready   <= 'd0;
    m_axi_arready  <= 'd0;

    @(posedge clk)
    arvalid        <= 'd0;
    arid           <= 'd0;
    araddr         <= 'h0;

    @(posedge clk)

    @(posedge clk)
    m_axi_awready <= 'd1;
    m_axi_wready <= 'd1;
    m_axi_arready <= 'd0;

    @(posedge clk)
    m_axi_bvalid   <= 'd1;
    m_axi_bid      <= 'd7;
    m_axi_bresp    <= 'd0;

    m_axi_awready <= 'd1;
    m_axi_wready <= 'd1;
    m_axi_arready <= 'd0;

    @(posedge clk)
    m_axi_bvalid   <= 'd1;
    m_axi_bid      <= 'd5;
    m_axi_bresp    <= 'd0;

    m_axi_awready <= 'd0;
    m_axi_wready <= 'd0;
    m_axi_arready <= 'd1;

    @(posedge clk)
    m_axi_bvalid   <= 'd0;
    m_axi_bid      <= 'd0;
    m_axi_bresp    <= 'd0;

    m_axi_rvalid   <= 'd1;
    m_axi_rid      <= 'd3;
    m_axi_rdata    <= 'hcccc_dddd_eeee_ffff;
    m_axi_rlast    <= 'd1;

    m_axi_awready  <= 'd0;
    m_axi_wready   <= 'd0;
    m_axi_arready  <= 'd1;

    @(posedge clk)
    m_axi_rvalid   <= 'd1;
    m_axi_rid      <= 'd6;
    m_axi_rdata    <= 'hbbbb_aaaa_eeee_ffff;
    m_axi_rlast    <= 'd1;

    m_axi_awready  <= 'd1;
    m_axi_wready   <= 'd1;
    m_axi_arready  <= 'd1;

    @(posedge clk)
    m_axi_rvalid   <= 'd0;
    m_axi_rid      <= 'd0;
    m_axi_rdata    <= 'd0;
    m_axi_rlast    <= 'd0;

    m_axi_awready  <= 'd1;
    m_axi_wready   <= 'd1;
    m_axi_arready  <= 'd1;
    
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
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);


endmodule