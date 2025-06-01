module mc_queue
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
    parameter type lsqWidth_t      = logic,
    parameter type kobWidth_t      = logic,
    parameter type mcWidth_t       = logic
)(
    input  logic                        clk                         ,
    input  logic                        rst_n                       ,

    // 1. Slave AW Channel
    input  logic                        s_awvalid                   ,
    output logic                        s_awready                   ,
    input  nlineWidth_t                 s_awid                      ,
    input  logic           [ 31: 0]     s_awaddr                    ,
    // 2. Slave W Channel
    input  logic                        s_wvalid                    ,
    output logic                        s_wready                    ,
    input  logic           [255: 0]     s_wdata                     ,
    // 3. Slave AR Channel
    input  logic                        s_arvalid                   ,
    output logic                        s_arready                   ,
    input  nlineWidth_t                 s_arid                      ,
    input  logic           [ 31: 0]     s_araddr                    ,

    // 4. Slave R Channel
    output logic                        s_rvalid                    ,
    input  logic                        s_rready                    ,
    output logic           [255: 0]     s_rdata                     ,

     // 5. Master AW Channel
    output logic                        m_awvalid                   ,
    input  logic                        m_awready                   ,
    output logic           [ 31: 0]     m_awaddr                    ,
    
    // 6. Master W Channel
    output logic                        m_wvalid                    ,
    input  logic                        m_wready                    ,
    output logic           [255: 0]     m_wdata                     ,

    output logic                        m_bready                    ,
    input  logic                        m_bvalid                    ,
    input  logic           [  1: 0]     m_bresp                     ,

    // 7. Master AR Channel
    output logic                        m_arvalid                   ,
    input  logic                        m_arready                   ,
    output logic           [ 31: 0]     m_araddr                    ,
    
    // 8. Master R Channel
    input  logic                        m_rvalid                    ,
    output logic                        m_rready                    ,
    input  logic           [255: 0]     m_rdata                     ,
    input  logic           [  1: 0]     m_rresp                     ,

    // 9. Entry State
    output logic                        entry_valid                 ,
    output nlineWidth_t                 entry_id


);

logic                 entry_valid_en;
logic                 entry_valid_nxt;

logic                 entry_id_en;
nlineWidth_t          entry_id_nxt;

logic                 entry_addr_en;
logic        [ 31: 0] entry_addr;
logic        [ 31: 0] entry_addr_nxt;

logic                 entry_data_en;
logic        [255: 0] entry_data;
logic        [255: 0] entry_data_nxt;

logic        [  2: 0] entry_cmd;


logic                 araddr_rdy;
logic                 awaddr_rdy;
logic                 wdata_rdy;
logic                 rrsp_rdy;

logic                 s_aw_hsked;
logic                 s_w_hsked;  
logic                 s_ar_hsked;
logic                 s_r_hsked;

logic                 m_aw_hsked;
logic                 m_w_hsked;
logic                 m_b_hsked;
logic                 m_ar_hsked;
logic                 m_r_hsked;

assign s_aw_hsked = s_awvalid && s_awready;
assign s_w_hsked = s_wvalid && s_wready;
assign s_ar_hsked = s_arvalid && s_arready;
assign s_r_hsked = s_rvalid && s_rready;

assign m_aw_hsked = m_awvalid && m_awready;
assign m_w_hsked = m_wvalid && m_wready;
assign m_b_hsked = m_bvalid && m_bready;
assign m_ar_hsked = m_arvalid && m_arready;
assign m_r_hsked = m_rvalid && m_rready;

assign entry_valid_en  = s_aw_hsked | s_ar_hsked | m_b_hsked | s_r_hsked;
assign entry_valid_nxt = (s_awvalid | s_arvalid) && !m_bvalid && !s_rvalid; 

assign entry_id_en = s_aw_hsked | s_ar_hsked;
assign entry_id_nxt = s_awvalid ? s_awid : s_arvalid ? s_arid : 'd0;

assign entry_data_en = s_w_hsked | m_r_hsked;
assign entry_data_nxt = s_wvalid ? s_wdata : m_rvalid ? m_rdata : 'd0; 

assign entry_addr_en = s_aw_hsked | s_ar_hsked;
assign entry_addr_nxt = s_awvalid ? s_awaddr : s_arvalid ? s_araddr : 'd0;

ns_gnrl_dfflr # (1) entry_valid_dfflr (entry_valid_en, entry_valid_nxt, entry_valid, clk, rst_n);
ns_gnrl_dfflr # (Cfg.nlineWidth) entry_id_dfflr (entry_id_en, entry_id_nxt, entry_id, clk, rst_n);
ns_gnrl_dfflr # (32) entry_addr_dfflr (entry_addr_en, entry_addr_nxt, entry_addr, clk, rst_n);
ns_gnrl_dfflr # (256) entry_data_dfflr (entry_data_en, entry_data_nxt, entry_data, clk, rst_n);

ns_gnrl_dfflr # (1) araddr_rdy_dfflr (s_ar_hsked | m_ar_hsked, s_ar_hsked & !m_ar_hsked, araddr_rdy, clk, rst_n);
ns_gnrl_dfflr # (1) awaddr_rdy_dfflr (s_w_hsked | m_aw_hsked, s_w_hsked & !m_aw_hsked, awaddr_rdy, clk, rst_n);
ns_gnrl_dfflr # (1) wdata_rdy_dfflr (s_w_hsked | m_w_hsked, s_w_hsked & !m_w_hsked, wdata_rdy, clk, rst_n);
ns_gnrl_dfflr # (1) rrsp_rdy_dfflr (s_r_hsked | m_r_hsked, m_r_hsked & !s_r_hsked, rrsp_rdy, clk, rst_n);

assign s_awready = !entry_valid;
assign m_awvalid = awaddr_rdy;
assign m_awaddr = entry_addr;

assign s_wready  = 1'b1;
assign m_wvalid = wdata_rdy;
assign m_wdata = entry_data;


assign s_arready = !entry_valid;
assign m_arvalid = araddr_rdy;
assign m_araddr = entry_addr;

assign s_rvalid = rrsp_rdy;
assign s_rdata = entry_data;

assign m_rready = 1'b1;
assign m_bready = 1'b1;


endmodule

module mc_wrapper     
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
    parameter type lsqWidth_t      = logic,
    parameter type kobWidth_t      = logic,
    parameter type mcWidth_t       = logic
)(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    // 1. Slave AW Channel
    input  logic                        awvalid                    ,
    output logic                        awready                    ,
    input  nlineWidth_t                 awid                       ,
    input  logic           [ 31: 0]     awaddr                     ,

    // 2. Slave W Channel
    input  logic                        wvalid                     ,
    output logic                        wready                     ,
    input  nlineWidth_t                 wid                        ,
    input  logic           [255: 0]     wdata                      ,

    // 3. Slave AR Channel
    input  logic                        arvalid                    ,
    output logic                        arready                    ,
    input  nlineWidth_t                 arid                       ,
    input  logic           [ 31: 0]     araddr                     ,
    
    // 4. Slave R Channel
    output logic                        rvalid                     ,
    input  logic                        rready                     ,
    output nlineWidth_t                 rid                        ,
    output logic           [255: 0]     rdata                      ,

    // 5. Master AXI AW Channel
    input  logic                        m_axi_awready              ,
    output logic                        m_axi_awvalid              ,
    output nlineWidth_t                 m_axi_awid                 ,
    output logic           [ 31: 0]     m_axi_awaddr               ,
    output logic           [  7: 0]     m_axi_awlen                ,
    output logic           [  2: 0]     m_axi_awsize               ,
    output logic           [  1: 0]     m_axi_awburst              ,

    // 6. Master AXI W Channel
    input  logic                        m_axi_wready               ,
    output logic                        m_axi_wvalid               ,
    output logic           [255: 0]     m_axi_wdata                ,
    output logic           [ 31: 0]     m_axi_wstrb                ,
    output logic                        m_axi_wlast                ,
    output logic                        m_axi_bready               ,
    input  logic                        m_axi_bvalid               ,
    input  nlineWidth_t                 m_axi_bid                  ,
    input  logic           [  1: 0]     m_axi_bresp                ,

    // 7. Master AXI AR Channel
    input  logic                        m_axi_arready              ,
    output logic                        m_axi_arvalid              ,
    output nlineWidth_t                 m_axi_arid                 ,
    output logic           [ 31: 0]     m_axi_araddr               ,
    output logic           [  7: 0]     m_axi_arlen                ,
    output logic           [  2: 0]     m_axi_arsize               ,
    output logic           [  1: 0]     m_axi_arburst              ,

    // 8. Master AXI R Channel

    output logic                        m_axi_rready               ,
    input  logic                        m_axi_rvalid               ,
    input  nlineWidth_t                 m_axi_rid                  ,
    input  logic           [255: 0]     m_axi_rdata                ,
    input  logic           [  1: 0]     m_axi_rresp                ,
    input  logic                        m_axi_rlast  

);

nlineWidth_t             entry_id    [Cfg.u.mcSize-1:0];

logic [Cfg.u.mcSize-1:0] entry_valid;
logic [Cfg.u.mcSize-1:0] entry_awready;
logic [Cfg.u.mcSize-1:0] entry_arready;
logic [Cfg.u.mcSize-1:0] entry_s_awsel;
logic [Cfg.u.mcSize-1:0] entry_s_arsel;

logic [Cfg.u.mcSize-1:0] entry_awvalid;
logic [Cfg.u.mcSize-1:0] entry_arvalid;
logic [Cfg.u.mcSize-1:0] entry_m_sel;
logic [Cfg.u.mcSize-1:0] entry_m_awsel;
logic [Cfg.u.mcSize-1:0] entry_m_arsel;


logic [Cfg.u.mcSize-1:0] entry_rvalid;
logic [Cfg.u.mcSize-1:0] entry_wvalid;  
logic [Cfg.u.mcSize-1:0] entry_rsel;
logic [Cfg.u.mcSize-1:0] entry_wsel;
logic [            31:0] entry_araddr [Cfg.u.mcSize-1:0];
logic [           255:0] entry_rdata [Cfg.u.mcSize-1:0];
logic [            31:0] entry_awaddr [Cfg.u.mcSize-1:0];
logic [           255:0] entry_wdata [Cfg.u.mcSize-1:0];


ns_gnrl_fixed #(Cfg.u.mcSize) u_ns_gnrl_s_awsel_fixed (entry_s_awsel, entry_awready);
ns_gnrl_fixed #(Cfg.u.mcSize) u_ns_gnrl_s_arsel_fixed (entry_s_arsel, entry_arready);
ns_gnrl_fixed #(Cfg.u.mcSize) u_ns_gnrl_m_sel_fixed (entry_m_sel, entry_awvalid | entry_arvalid);
ns_gnrl_fixed #(Cfg.u.mcSize) u_ns_gnrl_m_awsel_fixed (entry_m_awsel, entry_awvalid);
ns_gnrl_fixed #(Cfg.u.mcSize) u_ns_gnrl_m_arsel_fixed (entry_m_arsel, entry_arvalid);
ns_gnrl_fixed #(Cfg.u.mcSize) u_ns_gnrl_wsel_fixed (entry_wsel, entry_wvalid);
ns_gnrl_fixed #(Cfg.u.mcSize) u_ns_gnrl_rsel_fixed (entry_rsel, entry_rvalid);

for (genvar i = 0; i < int'(Cfg.u.mcSize); i = i + 1) begin
    mc_queue # (
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
        .lsqWidth_t                        (lsqWidth_t                         ),
        .kobWidth_t                        (kobWidth_t                         ),
        .mcWidth_t                         (mcWidth_t                          )
    ) u_mc_queue (
        .clk            (clk                                    ),
        .rst_n          (rst_n                                  ),

        .s_awvalid      (entry_s_awsel[i] && awvalid            ),
        .s_awready      (entry_awready[i]                       ),
        .s_awaddr       (awaddr                                 ),
        .s_awid         (awid                                   ),

        .s_wvalid       (wvalid && wid == entry_id[i] && entry_valid[i]),
        .s_wdata        (wdata                                  ),
        .s_wready       (),

        .s_arvalid      (entry_s_arsel[i] && arvalid            ),
        .s_arready      (entry_arready[i]                       ),
        .s_araddr       (araddr                                 ),
        .s_arid         (arid                                   ),

        .s_rvalid       (entry_rvalid[i]                        ),
        .s_rready       (entry_rsel[i] && rready                ),
        .s_rdata        (entry_rdata[i]                         ),

        .m_awvalid      (entry_awvalid[i]                       ),
        .m_awready      (entry_m_sel[i] && m_axi_awready      ),
        .m_awaddr       (entry_awaddr[i]                        ),

        .m_wvalid       (entry_wvalid[i]                        ),
        .m_wready       (entry_m_sel[i] && m_axi_wready          ),
        .m_wdata        (entry_wdata[i]                         ),

        .m_arvalid      (entry_arvalid[i]                       ),
        .m_arready      (entry_m_sel[i] && m_axi_arready        ),
        .m_araddr       (entry_araddr[i]                        ),

        .m_rready       (),
        .m_rvalid       (m_axi_rvalid && m_axi_rid == entry_id[i] && entry_valid[i]),
        .m_rdata        (m_axi_rdata                            ),
        .m_rresp        (m_axi_rresp                            ),
        
        .m_bready       (),
        .m_bvalid       (m_axi_bvalid && m_axi_bid == entry_id[i] && entry_valid[i]),
        .m_bresp        (m_axi_bresp                            ),

        .entry_id       (entry_id[i]                            ),
        .entry_valid    (entry_valid[i]                         )
        
    );
end

assign awready = |entry_awready;
assign m_axi_awvalid = |entry_awvalid;
ns_mux1h# (Cfg.nlineWidth, Cfg.u.mcSize) mc_awid_mux1h (entry_id, entry_m_awsel, m_axi_awid);
ns_mux1h# (32, Cfg.u.mcSize) mc_awaddr_mux1h (entry_awaddr, entry_m_awsel, m_axi_awaddr);
assign m_axi_awlen   = 'd0; //unused
assign m_axi_awsize  = 'd0; //unused
assign m_axi_awburst = 'd0; //unused

assign wready = 1'b1;
assign m_axi_wvalid = |entry_wvalid;
ns_mux1h# (256, Cfg.u.mcSize) mc_wdata_mux1h (entry_wdata, entry_wsel, m_axi_wdata);
assign m_axi_wstrb  = 'd0; //unused
assign m_axi_wlast  = 'd0; //unused
assign m_axi_bready = 1'b1;

assign arready = |entry_arready;
assign m_axi_arvalid = |entry_arvalid;
ns_mux1h# (Cfg.nlineWidth, Cfg.u.mcSize) mc_arid_mux1h (entry_id, entry_m_arsel, m_axi_arid);
ns_mux1h# (32, Cfg.u.mcSize) mc_araddr_mux1h (entry_araddr, entry_m_arsel, m_axi_araddr);
assign m_axi_arlen   = 'd0; //unused
assign m_axi_arsize  = 'd0; //unused
assign m_axi_arburst = 'd0; //unused

assign rvalid = |entry_rvalid;
ns_mux1h# (256, Cfg.u.mcSize) mc_rdata_mux1h (entry_rdata, entry_rsel, rdata);
ns_mux1h# (Cfg.nlineWidth, Cfg.u.mcSize) mc_rid_mux1h (entry_id, entry_rsel, rid);
assign m_axi_rready = 1'b1;

endmodule