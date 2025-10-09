module mc_queue 
    import mpc_types::*;
#(
    parameter mpc_cfg_t Cfg = '0,   
    parameter type clWidth_t       = logic,
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
    parameter type mcWidth_t       = logic
)(
    input  logic                        clk                         ,
    input  logic                        rst_n                       ,

    input  logic           [  1: 0]     id                          ,

    // 1. Slave AW Channel
    input  logic                        s_awvalid                   ,
    output logic                        s_awready                   ,
    input  nlineWidth_t                 s_awid                      ,
    input  addrWidth_t                  s_awaddr                    ,
    // 2. Slave W Channel
    input  logic                        s_wvalid                    ,
    output logic                        s_wready                    ,
    input  nlineWidth_t                 s_wid                       ,
    input  clWidth_t                    s_wdata                     ,
    // 3. Slave AR Channel
    input  logic                        s_arvalid                   ,
    output logic                        s_arready                   ,
    input  nlineWidth_t                 s_arid                      ,
    input  addrWidth_t                  s_araddr                    ,

    // 4. Slave R Channel
    output logic                        s_rvalid                    ,
    input  logic                        s_rready                    ,
    output clWidth_t                    s_rdata                     ,
    output nlineWidth_t                 s_rid                       ,

     // 5. Master AW Channel
    output logic                        m_awvalid                   ,
    input  logic                        m_awready                   ,
    output addrWidth_t                  m_awaddr                    ,
    
    // 6. Master W Channel
    output logic                        m_wvalid                    ,
    input  logic                        m_wready                    ,
    output clWidth_t                    m_wdata                     ,

    output logic                        m_bready                    ,
    input  logic                        m_bvalid                    ,
    input  logic           [  1: 0]     m_bresp                     ,

    // 7. Master AR Channel
    output logic                        m_arvalid                   ,
    input  logic                        m_arready                   ,
    output addrWidth_t                  m_araddr                    ,
    
    // 8. Master R Channel
    input  logic                        m_rvalid                    ,
    output logic                        m_rready                    ,
    input  clWidth_t                    m_rdata                     ,
    input  logic           [  1: 0]     m_rresp                     ,

    // 9. Entry State
    output logic                        entry_valid                 ,
    output nlineWidth_t                 cacheline_id                ,
    output logic           [  2: 0]     entry_state
);

    parameter S_IDLE = 'd0, S_WAIT_DAT = 'd1, S_SEND_REQ = 'd2, S_WAIT_RESP = 'd3, S_SEND_RESP = 'd4;

    reg                    [  2: 0]     state                       ;
    wire                   [  2: 0]     state_nxt                   ;

    reg                                 entry_cmd                   ;
    wire                                entry_cmd_nxt               ;
    wire                                entry_cmd_en                ;

    nlineWidth_t                        entry_cacheline_id          ;
    nlineWidth_t                        entry_cacheline_id_nxt      ;
    wire                                entry_cacheline_id_en       ;

    reg                    [  1: 0]     entry_bank_id               ;
    wire                   [  1: 0]     entry_bank_id_nxt           ;

    clWidth_t                           entry_data                  ;
    clWidth_t                           entry_data_nxt              ;
    wire                                entry_data_en               ;

    addrWidth_t                         entry_addr                  ;
    addrWidth_t                         entry_addr_nxt              ;
    wire                                entry_addr_en               ;

    logic                               s_aw_hsked;
    logic                               s_w_hsked;  
    logic                               s_ar_hsked;
    logic                               s_r_hsked;

    logic                               m_aw_hsked;
    logic                               m_w_hsked;
    logic                               m_b_hsked;
    logic                               m_ar_hsked;
    logic                               m_r_hsked;

    assign s_aw_hsked = s_awvalid && s_awready;
    assign s_w_hsked = s_wvalid && s_wready;
    assign s_ar_hsked = s_arvalid && s_arready;
    assign s_r_hsked = s_rvalid && s_rready;
    assign m_aw_hsked = m_awvalid && m_awready;
    assign m_w_hsked = m_wvalid && m_wready;
    assign m_b_hsked = m_bvalid && m_bready;
    assign m_ar_hsked = m_arvalid && m_arready;
    assign m_r_hsked = m_rvalid && m_rready;

    assign state_nxt = 
    (state == S_IDLE)      ? (s_ar_hsked ? S_SEND_REQ : (s_aw_hsked ? S_WAIT_DAT : S_IDLE)) :
    (state == S_WAIT_DAT)  ? (s_w_hsked ? S_SEND_REQ : S_WAIT_DAT) :
    (state == S_SEND_REQ)  ? ((m_ar_hsked | m_aw_hsked) ? S_WAIT_RESP : S_SEND_REQ) :
    (state == S_WAIT_RESP) ? (m_b_hsked ? S_IDLE : (m_r_hsked ? S_SEND_RESP : S_WAIT_RESP)) :
    (state == S_SEND_RESP) ? (s_r_hsked ? S_IDLE : S_SEND_RESP) :
                             S_IDLE;

    assign entry_cmd_nxt = s_aw_hsked;
    assign entry_cmd_en  = s_aw_hsked | s_ar_hsked;

    assign entry_cacheline_id_nxt = s_aw_hsked ? s_awid : s_arid;
    assign entry_cacheline_id_en = s_aw_hsked | s_ar_hsked;

    assign entry_data_nxt = s_w_hsked ? s_wdata : m_rdata;
    assign entry_data_en = s_w_hsked | m_r_hsked;

    assign entry_addr_nxt = s_aw_hsked ? s_awaddr : s_araddr;
    assign entry_addr_en = s_aw_hsked | s_ar_hsked;

    ns_gnrl_dfflr # (3) entry_state_dfflr (1'b1, state_nxt, state, clk, rst_n);
    ns_gnrl_dfflr # (1) entry_cmd_dfflr (entry_cmd_en, entry_cmd_nxt, entry_cmd, clk, rst_n);
    ns_gnrl_dfflr # (2) entry_bank_id_dfflr (1'b1, entry_bank_id_nxt, entry_bank_id, clk, rst_n);
    ns_gnrl_dfflr # (Cfg.nlineWidth) entry_cacheline_id_dfflr (entry_cacheline_id_en, entry_cacheline_id_nxt, entry_cacheline_id, clk, rst_n);
    // ns_gnrl_dfflr # (Cfg.u.clWidth) entry_data_dfflr (entry_data_en, entry_data_nxt, entry_data, clk, rst_n);
    ns_gnrl_dfflr # (Cfg.u.addrWidth) entry_addr_dfflr (entry_addr_en, entry_addr_nxt, entry_addr, clk, rst_n);    

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n)
            entry_data <= 'd0;
        else if (entry_data_en)
            entry_data <= #1 entry_data_nxt;
    end


    assign s_awready = state == S_IDLE;
    assign s_wready  = state == S_WAIT_DAT;
    assign s_arready = state == S_IDLE;

    assign s_rvalid  = state == S_SEND_RESP;
    assign s_rid     = entry_cacheline_id;
    assign s_rdata   = entry_data;

    assign m_awvalid = state == S_SEND_REQ & entry_cmd == $bits(entry_cmd)'(MEM_OP_STORE);
    assign m_awaddr  = entry_addr;
    assign m_wvalid  = state == S_SEND_REQ & entry_cmd == $bits(entry_cmd)'(MEM_OP_STORE);
    assign m_wdata   = entry_data;

    assign m_arvalid = state == S_SEND_REQ & entry_cmd == $bits(entry_cmd)'(MEM_OP_LOAD);
    assign m_araddr  = entry_addr;
    assign m_rready  = state == S_WAIT_RESP & entry_cmd == $bits(entry_cmd)'(MEM_OP_LOAD);


    assign m_bready  = state == S_WAIT_RESP & entry_cmd == $bits(entry_cmd)'(MEM_OP_STORE);

    assign entry_valid  = state != S_IDLE;
    assign cacheline_id = entry_cacheline_id;
    assign entry_state  = state;

endmodule

module mc_wrapper 
    import mpc_types::*;
#(
    parameter mpc_cfg_t Cfg = '0,   
    parameter type clWidth_t       = logic,
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
    parameter type mcWidth_t       = logic
)(
    input  logic                        clk                              ,
    input  logic                        rst_n                            ,

    input  logic           [  1: 0]     bank_id                          ,

    // 1. Slave AW Channel
    input  logic                        s_axi_awvalid                    ,
    output logic                        s_axi_awready                    ,
    input  nlineWidth_t                 s_axi_awid                       ,
    input  addrWidth_t                  s_axi_awaddr                     ,

    // 2. Slave W Channel
    input  logic                        s_axi_wvalid                     ,
    output logic                        s_axi_wready                     ,
    input  nlineWidth_t                 s_axi_wid                        ,
    input  clWidth_t                    s_axi_wdata                      ,

    // 3. Slave AR Channel
    input  logic                        s_axi_arvalid                    ,
    output logic                        s_axi_arready                    ,
    input  nlineWidth_t                 s_axi_arid                       ,
    input  addrWidth_t                  s_axi_araddr                     ,
    
    // 4. Slave R Channel
    output logic                        s_axi_rvalid                     ,
    input  logic                        s_axi_rready                     ,
    output nlineWidth_t                 s_axi_rid                        ,
    output clWidth_t                    s_axi_rdata                      ,

    // 5. Master AXI AW Channel
    input  logic                        m_axi_awready                    ,
    output logic                        m_axi_awvalid                    ,
    output logic           [  1: 0]     m_axi_awid                       ,
    output addrWidth_t                  m_axi_awaddr                     ,
    output logic           [  7: 0]     m_axi_awlen                      ,
    output logic           [  2: 0]     m_axi_awsize                     ,
    output logic           [  1: 0]     m_axi_awburst                    ,

    // 6. Master AXI W Channel
    input  logic                        m_axi_wready                     ,
    output logic                        m_axi_wvalid                     ,
    output clWidth_t                    m_axi_wdata                      ,
    output logic           [ 31: 0]     m_axi_wstrb                      , // FIXME
    output logic                        m_axi_wlast                      ,
    output logic                        m_axi_bready                     ,
    input  logic                        m_axi_bvalid                     ,
    input  logic           [  1: 0]     m_axi_bid                        ,
    input  logic           [  1: 0]     m_axi_bresp                      ,

    // 7. Master AXI AR Channel
    input  logic                        m_axi_arready                    ,
    output logic                        m_axi_arvalid                    ,
    output logic           [  1: 0]     m_axi_arid                       ,
    output addrWidth_t                  m_axi_araddr                     ,
    output logic           [  7: 0]     m_axi_arlen                      ,
    output logic           [  2: 0]     m_axi_arsize                     ,
    output logic           [  1: 0]     m_axi_arburst                    ,

    // 8. Master AXI R Channel

    output logic                        m_axi_rready                     ,
    input  logic                        m_axi_rvalid                     ,
    input  logic           [  1: 0]     m_axi_rid                        ,
    input  clWidth_t                    m_axi_rdata                      ,
    input  logic           [  1: 0]     m_axi_rresp                      ,
    input  logic                        m_axi_rlast  

);

// note: slave channel's id has different meaning from master channel's id. 
// slave's id identify cacheline, master's id identify bank.

logic [Cfg.u.mcSize-1:0] entry_valid;
nlineWidth_t             entry_cacheline_id [Cfg.u.mcSize-1:0];

logic [Cfg.u.mcSize-1:0] entry_awready;
logic [Cfg.u.mcSize-1:0] entry_arready;
logic [Cfg.u.mcSize-1:0] entry_wready;

logic [Cfg.u.mcSize-1:0] entry_rvalid;
clWidth_t                entry_rdata [Cfg.u.mcSize-1:0];
nlineWidth_t             entry_rid [Cfg.u.mcSize-1:0];

logic [Cfg.u.mcSize-1:0] entry_awvalid;
addrWidth_t              entry_awaddr [Cfg.u.mcSize-1:0];

logic [Cfg.u.mcSize-1:0] entry_wvalid;
clWidth_t                entry_wdata [Cfg.u.mcSize-1:0];

logic [Cfg.u.mcSize-1:0] entry_arvalid;
addrWidth_t              entry_araddr [Cfg.u.mcSize-1:0]; 

logic [Cfg.u.mcSize-1:0] entry_rready;

logic [Cfg.u.mcSize-1:0] entry_bready;

logic [             2:0] entry_state  [Cfg.u.mcSize-1:0];


logic [   Cfg.mcWidth:0]         w_ptr;
logic [   Cfg.mcWidth:0]         w_ptr_nxt;
mcWidth_t                        w_ptr_v;


logic [   Cfg.mcWidth:0]         r_ptr;
logic [   Cfg.mcWidth:0]         r_ptr_nxt;
mcWidth_t                        r_ptr_v;

assign w_ptr_v = w_ptr[$clog2(Cfg.u.mcSize)-1:0];
assign r_ptr_v = r_ptr[$clog2(Cfg.u.mcSize)-1:0];

assign w_ptr_nxt = w_ptr + {{($bits(w_ptr)-1){1'b0}}, (s_axi_awready & s_axi_awvalid) | (s_axi_arready & s_axi_arvalid)};
assign r_ptr_nxt = r_ptr + {{($bits(r_ptr)-1){1'b0}}, (m_axi_bready & m_axi_bvalid) | (s_axi_rvalid & s_axi_rready)};

ns_gnrl_dfflr # ($bits(w_ptr)) w_ptr_dfflr (1'b1, w_ptr_nxt, w_ptr, clk, rst_n);
ns_gnrl_dfflr # ($bits(r_ptr)) r_ptr_dfflr (1'b1, r_ptr_nxt, r_ptr, clk, rst_n);

for (genvar i = 0; i < int'(Cfg.u.mcSize); i = i + 1) begin: mc_queue_gen
    mc_queue # (
        .Cfg                               (Cfg                                ),
        .clWidth_t                         (clWidth_t                          ),
        .addrWidth_t                       (addrWidth_t                        ),
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

        .id             (bank_id                                ),

        .s_awvalid      (w_ptr_v == i && s_axi_awvalid          ),
        .s_awready      (entry_awready[i]                       ),
        .s_awaddr       (s_axi_awaddr                           ),
        .s_awid         (s_axi_awid                             ),

        .s_wvalid       (s_axi_wid == entry_cacheline_id[i] && entry_valid[i] && s_axi_wvalid),
        .s_wdata        (s_axi_wdata                            ),
        .s_wid          (s_axi_wid                              ),
        .s_wready       (entry_wready[i]                        ),

        .s_arvalid      (w_ptr_v == i && s_axi_arvalid          ),
        .s_arready      (entry_arready[i]                       ),
        .s_araddr       (s_axi_araddr                           ),
        .s_arid         (s_axi_arid                             ),

        .s_rvalid       (entry_rvalid[i]                        ),
        .s_rready       (r_ptr_v == i && s_axi_rready           ),
        .s_rdata        (entry_rdata[i]                         ),
        .s_rid          (entry_rid[i]                           ),

        .m_awvalid      (entry_awvalid[i]                       ),
        .m_awready      (r_ptr_v == i && m_axi_awready          ),
        .m_awaddr       (entry_awaddr[i]                        ),

        .m_wvalid       (entry_wvalid[i]                        ),
        .m_wready       (r_ptr_v == i && m_axi_wready           ),
        .m_wdata        (entry_wdata[i]                         ),

        .m_arvalid      (entry_arvalid[i]                       ),
        .m_arready      (r_ptr_v == i && m_axi_arready          ),
        .m_araddr       (entry_araddr[i]                        ),

        .m_rready       (entry_rready[i]                        ),
        .m_rvalid       (r_ptr_v == i && m_axi_rvalid           ),
        .m_rdata        (m_axi_rdata                            ),
        .m_rresp        (m_axi_rresp                            ),
        
        .m_bready       (entry_bready[i]                        ),
        .m_bvalid       (r_ptr_v == i && m_axi_bvalid           ),
        .m_bresp        (m_axi_bresp                            ),

        .entry_valid    (entry_valid[i]                         ),
        .cacheline_id   (entry_cacheline_id[i]                  ),
        .entry_state    (entry_state[i]                         )   
    );
end

assign s_axi_awready = entry_awready[w_ptr_v];
assign s_axi_wready  = |entry_wready;

assign s_axi_arready = entry_arready[w_ptr_v];

assign s_axi_rvalid  = entry_rvalid[r_ptr_v];
assign s_axi_rdata   = entry_rdata[r_ptr_v];
assign s_axi_rid     = entry_cacheline_id[r_ptr_v];

assign m_axi_awvalid = entry_awvalid[r_ptr_v];
assign m_axi_awaddr  = entry_awaddr[r_ptr_v];
assign m_axi_awid    = bank_id;
assign m_axi_awlen   = 'd0; //unused
assign m_axi_awsize  = 'd0; //unused
assign m_axi_awburst = 'd0; //unused

assign m_axi_wvalid  = entry_wvalid[r_ptr_v];
assign m_axi_wdata   = entry_wdata[r_ptr_v];
assign m_axi_wstrb   = 'hffff_ffff; //unused
assign m_axi_wlast   = entry_wvalid[r_ptr_v]; //unused

assign m_axi_arvalid = entry_arvalid[r_ptr_v];
assign m_axi_araddr  = entry_araddr[r_ptr_v];
assign m_axi_arid    = bank_id;
assign m_axi_arlen   = 'd0; //unused
assign m_axi_arsize  = 'd0; //unused
assign m_axi_arburst = 'd0; //unused

assign m_axi_rready  = entry_rready[r_ptr_v];

assign m_axi_bready  = entry_bready[r_ptr_v];

endmodule