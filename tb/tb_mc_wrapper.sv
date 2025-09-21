module tb_mc_wrapper;
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

logic                        clk                        ;
logic                        rst_n                      ;

logic           [  1: 0]     bank_id                    ;

logic                        s_axi_awvalid              ;
logic                        s_axi_awready              ;
nlineWidth_t                 s_axi_awid                 ;
logic           [ 31: 0]     s_axi_awaddr               ;

logic                        s_axi_wvalid               ;
logic                        s_axi_wready               ;
nlineWidth_t                 s_axi_wid                  ;
logic           [255: 0]     s_axi_wdata                ;

logic                        s_axi_arvalid              ;
logic                        s_axi_arready              ;
nlineWidth_t                 s_axi_arid                 ;
logic           [ 31: 0]     s_axi_araddr               ;

logic                        s_axi_rvalid               ;
logic                        s_axi_rready               ;
nlineWidth_t                 s_axi_rid                  ;
logic           [255: 0]     s_axi_rdata                ;

logic                        m_axi_awready              ;
logic                        m_axi_awvalid              ;
logic           [  1: 0]     m_axi_awid                 ;
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
logic           [  1: 0]     m_axi_bid                  ;
logic           [  1: 0]     m_axi_bresp                ;

logic                        m_axi_arready              ;
logic                        m_axi_arvalid              ;
logic           [  1: 0]     m_axi_arid                 ;
logic           [ 31: 0]     m_axi_araddr               ;
logic           [  7: 0]     m_axi_arlen                ;
logic           [  2: 0]     m_axi_arsize               ;
logic           [  1: 0]     m_axi_arburst              ;

logic                        m_axi_rready               ;
logic                        m_axi_rvalid               ;
logic           [  1: 0]     m_axi_rid                  ;
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

    bank_id              = 'd3;

    s_axi_awvalid        = 'd0;
    s_axi_awid           = 'd0;
    s_axi_awaddr         = 'd0;

    s_axi_wvalid         = 'd0;         
    s_axi_wid            = 'd0;     
    s_axi_wdata          = 'd0;         

    s_axi_arvalid        = 'd0;
    s_axi_arid           = 'd0; 
    s_axi_araddr         = 'd0; 

    s_axi_rready         = 'd1;

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
    bank_id              <= 'd3;
    s_axi_awvalid        <= 'd1;
    s_axi_awid           <= 'd7;
    s_axi_awaddr         <= 'h8000;
    
    m_axi_awready  <= 'd0;
    m_axi_wready   <= 'd0;
    m_axi_arready  <= 'd0;
    
    @(posedge clk)
    s_axi_awvalid        <= 'd1;
    s_axi_awid           <= 'd5;
    s_axi_awaddr         <= 'h8020;

    s_axi_wvalid         <= 'd1;
    s_axi_wid            <= 'd7;
    s_axi_wdata          <= 'haaaa_bbbb_cccc_dddd;

    @(posedge clk)
    s_axi_awvalid        <= 'd0;
    s_axi_awid           <= 'd0;
    s_axi_awaddr         <= 'd0;

    s_axi_arvalid        <= 'd1;
    s_axi_arid           <= 'd3;
    s_axi_araddr         <= 'h8010;
    
    s_axi_wvalid         <= 'd1;
    s_axi_wid            <= 'd5;
    s_axi_wdata          <= 'heeee_ffff_cccc_dddd;

    @(posedge clk)  
    s_axi_arvalid        <= 'd1;
    s_axi_arid           <= 'd6;
    s_axi_araddr         <= 'h8030;

    s_axi_wvalid         <= 'd0;
    s_axi_wid            <= 'd0;
    s_axi_wdata          <= 'h0;

    m_axi_awready  <= 'd0;
    m_axi_wready   <= 'd0;
    m_axi_arready  <= 'd0;

    @(posedge clk)
    s_axi_arvalid        <= 'd0;
    s_axi_arid           <= 'd0;
    s_axi_araddr         <= 'h0;

    @(posedge clk)

    @(posedge clk)
    m_axi_awready <= 'd1;
    m_axi_wready <= 'd1;
    m_axi_arready <= 'd0;

    @(posedge clk)
    m_axi_bvalid   <= 'd1;
    m_axi_bid      <= 'd3;
    m_axi_bresp    <= 'd0;

    m_axi_awready <= 'd1;
    m_axi_wready <= 'd1;
    m_axi_arready <= 'd0;

    @(posedge clk)
    m_axi_bvalid   <= 'd0;
    m_axi_bid      <= 'd0;
    m_axi_bresp    <= 'd0;

    m_axi_awready <= 'd0;
    m_axi_wready <= 'd0;
    m_axi_arready <= 'd1;

    @(posedge clk)

    m_axi_awready  <= 'd0;
    m_axi_wready   <= 'd0;
    m_axi_arready  <= 'd1;
    
    @(posedge clk)

    @(posedge clk)
    m_axi_awready  <= 'd1;
    m_axi_wready   <= 'd1;
    m_axi_arready  <= 'd1;

    @(posedge clk)
    m_axi_bvalid   <= 'd1;
    m_axi_bid      <= 'd3;
    m_axi_bresp    <= 'd0;
    
    @(posedge clk)
    m_axi_bvalid   <= 'd0;
    m_axi_bid      <= 'd0;
    m_axi_bresp    <= 'd0;

    @(posedge clk)
    m_axi_rvalid   <= 'd1;
    m_axi_rid      <= 'd3;
    m_axi_rdata    <= 'hcccc_dddd_eeee_ffff;
    m_axi_rlast    <= 'd1;

    @(posedge clk)

    m_axi_rvalid   <= 'd1;
    m_axi_rid      <= 'd3;
    m_axi_rdata    <= 'hbbbb_aaaa_eeee_ffff;
    m_axi_rlast    <= 'd1;

    @(posedge clk)

    @(posedge clk)

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
    .clWidth_t                         (clWidth_t          ),
    .addrWidth_t                       (addrWidth_t        ),      
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