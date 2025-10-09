module mem_intf_arbiter
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
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    // Slave AXI AW Channel
    output logic                        slice_0_s_axi_awready      ,
    input  logic                        slice_0_s_axi_awvalid      ,
    input  logic           [  1: 0]     slice_0_s_axi_awid         ,
    input  logic           [ 31: 0]     slice_0_s_axi_awaddr       ,
    input  logic           [  7: 0]     slice_0_s_axi_awlen        ,
    input  logic           [  2: 0]     slice_0_s_axi_awsize       ,
    input  logic           [  1: 0]     slice_0_s_axi_awburst      ,
    
    // Slave AXI W Channel
    output logic                        slice_0_s_axi_wready       ,
    input  logic                        slice_0_s_axi_wvalid       ,
    input  logic           [255: 0]     slice_0_s_axi_wdata        ,
    input  logic           [ 31: 0]     slice_0_s_axi_wstrb        ,
    input  logic                        slice_0_s_axi_wlast        ,
 
    input  logic                        slice_0_s_axi_bready       ,
    output logic                        slice_0_s_axi_bvalid       ,
    output logic           [  1: 0]     slice_0_s_axi_bid          ,
    output logic           [  1: 0]     slice_0_s_axi_bresp        ,
 
    // Slave AXI AR Channel 
    output logic                        slice_0_s_axi_arready      ,
    input  logic                        slice_0_s_axi_arvalid      ,
    input  logic           [  1: 0]     slice_0_s_axi_arid         ,
    input  logic           [ 31: 0]     slice_0_s_axi_araddr       ,
    input  logic           [  7: 0]     slice_0_s_axi_arlen        ,
    input  logic           [  2: 0]     slice_0_s_axi_arsize       ,
    input  logic           [  1: 0]     slice_0_s_axi_arburst      ,

    // Slave AXI R Channel
    input  logic                        slice_0_s_axi_rready       ,
    output logic                        slice_0_s_axi_rvalid       ,
    output logic           [  1: 0]     slice_0_s_axi_rid          ,
    output logic           [255: 0]     slice_0_s_axi_rdata        ,
    output logic           [  1: 0]     slice_0_s_axi_rresp        ,
    output logic                        slice_0_s_axi_rlast        ,
    
    output logic                        slice_1_s_axi_awready      ,
    input  logic                        slice_1_s_axi_awvalid      ,
    input  logic           [  1: 0]     slice_1_s_axi_awid         ,
    input  logic           [ 31: 0]     slice_1_s_axi_awaddr       ,
    input  logic           [  7: 0]     slice_1_s_axi_awlen        ,
    input  logic           [  2: 0]     slice_1_s_axi_awsize       ,
    input  logic           [  1: 0]     slice_1_s_axi_awburst      ,

    output logic                        slice_1_s_axi_wready       ,
    input  logic                        slice_1_s_axi_wvalid       ,
    input  logic           [255: 0]     slice_1_s_axi_wdata        ,
    input  logic           [ 31: 0]     slice_1_s_axi_wstrb        ,
    input  logic                        slice_1_s_axi_wlast        ,
    input  logic                        slice_1_s_axi_bready       ,
    output logic                        slice_1_s_axi_bvalid       ,
    output logic           [  1: 0]     slice_1_s_axi_bid          ,
    output logic           [  1: 0]     slice_1_s_axi_bresp        ,

    output logic                        slice_1_s_axi_arready      ,
    input  logic                        slice_1_s_axi_arvalid      ,
    input  logic           [  1: 0]     slice_1_s_axi_arid         ,
    input  logic           [ 31: 0]     slice_1_s_axi_araddr       ,
    input  logic           [  7: 0]     slice_1_s_axi_arlen        ,
    input  logic           [  2: 0]     slice_1_s_axi_arsize       ,
    input  logic           [  1: 0]     slice_1_s_axi_arburst      ,

    input  logic                        slice_1_s_axi_rready       ,
    output logic                        slice_1_s_axi_rvalid       ,
    output logic           [  1: 0]     slice_1_s_axi_rid          ,
    output logic           [255: 0]     slice_1_s_axi_rdata        ,
    output logic           [  1: 0]     slice_1_s_axi_rresp        ,
    output logic                        slice_1_s_axi_rlast        ,

    output logic                        slice_2_s_axi_awready      ,
    input  logic                        slice_2_s_axi_awvalid      ,
    input  logic           [  1: 0]     slice_2_s_axi_awid         ,
    input  logic           [ 31: 0]     slice_2_s_axi_awaddr       ,
    input  logic           [  7: 0]     slice_2_s_axi_awlen        ,
    input  logic           [  2: 0]     slice_2_s_axi_awsize       ,
    input  logic           [  1: 0]     slice_2_s_axi_awburst      ,

    output logic                        slice_2_s_axi_wready       ,
    input  logic                        slice_2_s_axi_wvalid       ,
    input  logic           [255: 0]     slice_2_s_axi_wdata        ,
    input  logic           [ 31: 0]     slice_2_s_axi_wstrb        ,
    input  logic                        slice_2_s_axi_wlast        ,
    
    input  logic                        slice_2_s_axi_bready       ,
    output logic                        slice_2_s_axi_bvalid       ,
    output logic           [  1: 0]     slice_2_s_axi_bid          ,
    output logic           [  1: 0]     slice_2_s_axi_bresp        ,
    
    output logic                        slice_2_s_axi_arready      ,
    input  logic                        slice_2_s_axi_arvalid      ,
    input  logic           [  1: 0]     slice_2_s_axi_arid         ,
    input  logic           [ 31: 0]     slice_2_s_axi_araddr       ,
    input  logic           [  7: 0]     slice_2_s_axi_arlen        ,
    input  logic           [  2: 0]     slice_2_s_axi_arsize       ,
    input  logic           [  1: 0]     slice_2_s_axi_arburst      ,
    
    input  logic                        slice_2_s_axi_rready       ,
    output logic                        slice_2_s_axi_rvalid       ,
    output logic           [  1: 0]     slice_2_s_axi_rid          ,
    output logic           [255: 0]     slice_2_s_axi_rdata        ,
    output logic           [  1: 0]     slice_2_s_axi_rresp        ,
    output logic                        slice_2_s_axi_rlast        ,

    output logic                        slice_3_s_axi_awready      ,
    input  logic                        slice_3_s_axi_awvalid      ,
    input  logic           [  1: 0]     slice_3_s_axi_awid         ,
    input  logic           [ 31: 0]     slice_3_s_axi_awaddr       ,
    input  logic           [  7: 0]     slice_3_s_axi_awlen        ,
    input  logic           [  2: 0]     slice_3_s_axi_awsize       ,
    input  logic           [  1: 0]     slice_3_s_axi_awburst      ,

    output logic                        slice_3_s_axi_wready       ,
    input  logic                        slice_3_s_axi_wvalid       ,
    input  logic           [255: 0]     slice_3_s_axi_wdata        ,
    input  logic           [ 31: 0]     slice_3_s_axi_wstrb        ,
    input  logic                        slice_3_s_axi_wlast        ,

    input  logic                        slice_3_s_axi_bready       ,
    output logic                        slice_3_s_axi_bvalid       ,
    output logic           [  1: 0]     slice_3_s_axi_bid          ,
    output logic           [  1: 0]     slice_3_s_axi_bresp        ,
    
    output logic                        slice_3_s_axi_arready      ,
    input  logic                        slice_3_s_axi_arvalid      ,
    input  logic           [  1: 0]     slice_3_s_axi_arid         ,
    input  logic           [ 31: 0]     slice_3_s_axi_araddr       ,
    input  logic           [  7: 0]     slice_3_s_axi_arlen        ,
    input  logic           [  2: 0]     slice_3_s_axi_arsize       ,
    input  logic           [  1: 0]     slice_3_s_axi_arburst      ,
    
    input  logic                        slice_3_s_axi_rready       ,
    output logic                        slice_3_s_axi_rvalid       ,
    output logic           [  1: 0]     slice_3_s_axi_rid          ,
    output logic           [255: 0]     slice_3_s_axi_rdata        ,
    output logic           [  1: 0]     slice_3_s_axi_rresp        ,
    output logic                        slice_3_s_axi_rlast        ,

    // Master AXI AW Channel
    input  logic                        m_axi_awready              ,
    output logic                        m_axi_awvalid              ,
    output logic           [  1: 0]     m_axi_awid                 ,
    output logic           [ 31: 0]     m_axi_awaddr               ,
    output logic           [  7: 0]     m_axi_awlen                ,
    output logic           [  2: 0]     m_axi_awsize               ,
    output logic           [  1: 0]     m_axi_awburst              ,

    // Master AXI W Channel
    input  logic                        m_axi_wready               ,
    output logic                        m_axi_wvalid               ,
    output logic           [255: 0]     m_axi_wdata                ,
    output logic           [ 31: 0]     m_axi_wstrb                ,
    output logic                        m_axi_wlast                ,
    output logic                        m_axi_bready               ,
    input  logic                        m_axi_bvalid               ,
    input  logic           [  1: 0]     m_axi_bid                  ,
    input  logic           [  1: 0]     m_axi_bresp                ,

    // Master AXI AR Channel
    input  logic                        m_axi_arready              ,
    output logic                        m_axi_arvalid              ,
    output logic           [  1: 0]     m_axi_arid                 ,
    output logic           [ 31: 0]     m_axi_araddr               ,
    output logic           [  7: 0]     m_axi_arlen                ,
    output logic           [  2: 0]     m_axi_arsize               ,
    output logic           [  1: 0]     m_axi_arburst              ,

    // Master AXI R Channel
    output logic                        m_axi_rready               ,
    input  logic                        m_axi_rvalid               ,
    input  logic           [  1: 0]     m_axi_rid                  ,
    input  logic           [255: 0]     m_axi_rdata                ,
    input  logic           [  1: 0]     m_axi_rresp                ,
    input  logic                        m_axi_rlast                
);

parameter S_IDLE = 'd0, S_GNT_0 = 'd1, S_GNT_1 = 'd2, S_GNT_2 = 'd3, S_GNT_3 = 'd4;

logic           [  2: 0]     state, state_nxt  ;
logic           [  3: 0]     mask, req_mask    ;

logic                        slice_0_axi_req, slice_0_axi_req_mask, slice_0_axi_req_nomask;
logic                        slice_1_axi_req, slice_1_axi_req_mask, slice_1_axi_req_nomask;
logic                        slice_2_axi_req, slice_2_axi_req_mask, slice_2_axi_req_nomask;
logic                        slice_3_axi_req, slice_3_axi_req_mask, slice_3_axi_req_nomask;

logic                        slice_0_axi_done  ;
logic                        slice_1_axi_done  ;
logic                        slice_2_axi_done  ;
logic                        slice_3_axi_done  ;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        mask <= 4'b0000;
    else begin
        case(state)
            S_GNT_0 : mask <= 4'b1110;
            S_GNT_1 : mask <= 4'b1100;
            S_GNT_2 : mask <= 4'b1000;
            S_GNT_3 : mask <= 4'b1111;
        endcase
    end
end

assign slice_0_axi_req_nomask = slice_0_s_axi_arvalid | slice_0_s_axi_awvalid;
assign slice_1_axi_req_nomask = slice_1_s_axi_arvalid | slice_1_s_axi_awvalid;
assign slice_2_axi_req_nomask = slice_2_s_axi_arvalid | slice_2_s_axi_awvalid;
assign slice_3_axi_req_nomask = slice_3_s_axi_arvalid | slice_3_s_axi_awvalid;

assign slice_0_axi_req_mask   = (slice_0_s_axi_arvalid | slice_0_s_axi_awvalid) & mask[0];
assign slice_1_axi_req_mask   = (slice_1_s_axi_arvalid | slice_1_s_axi_awvalid) & mask[1];
assign slice_2_axi_req_mask   = (slice_2_s_axi_arvalid | slice_2_s_axi_awvalid) & mask[2];
assign slice_3_axi_req_mask   = (slice_3_s_axi_arvalid | slice_3_s_axi_awvalid) & mask[3];

assign req_mask               = {slice_3_axi_req_mask, slice_2_axi_req_mask, slice_1_axi_req_mask, slice_0_axi_req_mask};

assign slice_0_axi_req        = |req_mask ? slice_0_axi_req_mask : slice_0_axi_req_nomask;
assign slice_1_axi_req        = |req_mask ? slice_1_axi_req_mask : slice_1_axi_req_nomask;
assign slice_2_axi_req        = |req_mask ? slice_2_axi_req_mask : slice_2_axi_req_nomask;
assign slice_3_axi_req        = |req_mask ? slice_3_axi_req_mask : slice_3_axi_req_nomask;

assign slice_0_axi_done       = (slice_0_s_axi_bvalid & slice_0_s_axi_bready) | (slice_0_s_axi_rvalid & slice_0_s_axi_rready);
assign slice_1_axi_done       = (slice_1_s_axi_bvalid & slice_1_s_axi_bready) | (slice_1_s_axi_rvalid & slice_1_s_axi_rready);
assign slice_2_axi_done       = (slice_2_s_axi_bvalid & slice_2_s_axi_bready) | (slice_2_s_axi_rvalid & slice_2_s_axi_rready);
assign slice_3_axi_done       = (slice_3_s_axi_bvalid & slice_3_s_axi_bready) | (slice_3_s_axi_rvalid & slice_3_s_axi_rready);

always @ (*) begin
    case(state)
        S_IDLE  : state_nxt = slice_0_axi_req ? S_GNT_0 :
                              slice_1_axi_req ? S_GNT_1 :
                              slice_2_axi_req ? S_GNT_2 : 
                              slice_3_axi_req ? S_GNT_3 : S_IDLE;
        
        S_GNT_0 : state_nxt = slice_0_axi_done ? S_IDLE : S_GNT_0;
        S_GNT_1 : state_nxt = slice_1_axi_done ? S_IDLE : S_GNT_1;
        S_GNT_2 : state_nxt = slice_2_axi_done ? S_IDLE : S_GNT_2;
        S_GNT_3 : state_nxt = slice_3_axi_done ? S_IDLE : S_GNT_3;
        default : state_nxt = S_IDLE;
    endcase
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= S_IDLE;
    else
        state <= state_nxt;
end

assign slice_0_s_axi_arready = state == S_GNT_0 & m_axi_arready;
assign slice_0_s_axi_awready = state == S_GNT_0 & m_axi_awready;
assign slice_0_s_axi_wready  = state == S_GNT_0 & m_axi_wready ;

assign slice_0_s_axi_bvalid  = state == S_GNT_0 & m_axi_bvalid ;
assign slice_0_s_axi_bid     = m_axi_bid                       ;
assign slice_0_s_axi_bresp   = m_axi_bresp                     ;

assign slice_0_s_axi_rvalid  = state == S_GNT_0 & m_axi_rvalid ;
assign slice_0_s_axi_rid     = m_axi_rid                       ;
assign slice_0_s_axi_rdata   = m_axi_rdata                     ;
assign slice_0_s_axi_rresp   = m_axi_rresp                     ;
assign slice_0_s_axi_rlast   = m_axi_rlast                     ;

assign slice_1_s_axi_arready = state == S_GNT_1 & m_axi_arready;
assign slice_1_s_axi_awready = state == S_GNT_1 & m_axi_awready;
assign slice_1_s_axi_wready  = state == S_GNT_1 & m_axi_wready ;

assign slice_1_s_axi_bvalid  = state == S_GNT_1 & m_axi_bvalid ;
assign slice_1_s_axi_bid     = m_axi_bid                       ;
assign slice_1_s_axi_bresp   = m_axi_bresp                     ;

assign slice_1_s_axi_rvalid  = state == S_GNT_1 & m_axi_rvalid ;
assign slice_1_s_axi_rid     = m_axi_rid                       ;
assign slice_1_s_axi_rdata   = m_axi_rdata                     ;
assign slice_1_s_axi_rresp   = m_axi_rresp                     ;
assign slice_1_s_axi_rlast   = m_axi_rlast                     ;

assign slice_2_s_axi_arready = state == S_GNT_2 & m_axi_arready;
assign slice_2_s_axi_awready = state == S_GNT_2 & m_axi_awready;
assign slice_2_s_axi_wready  = state == S_GNT_2 & m_axi_wready ;

assign slice_2_s_axi_bvalid  = state == S_GNT_2 & m_axi_bvalid ;
assign slice_2_s_axi_bid     = m_axi_bid                       ;
assign slice_2_s_axi_bresp   = m_axi_bresp                     ;

assign slice_2_s_axi_rvalid  = state == S_GNT_2 & m_axi_rvalid ;
assign slice_2_s_axi_rid     = m_axi_rid                       ;
assign slice_2_s_axi_rdata   = m_axi_rdata                     ;
assign slice_2_s_axi_rresp   = m_axi_rresp                     ;
assign slice_2_s_axi_rlast   = m_axi_rlast                     ;

assign slice_3_s_axi_arready = state == S_GNT_3 & m_axi_arready;
assign slice_3_s_axi_awready = state == S_GNT_3 & m_axi_awready;
assign slice_3_s_axi_wready  = state == S_GNT_3 & m_axi_wready ;

assign slice_3_s_axi_bvalid  = state == S_GNT_3 & m_axi_bvalid ;
assign slice_3_s_axi_bid     = m_axi_bid                       ;
assign slice_3_s_axi_bresp   = m_axi_bresp                     ;

assign slice_3_s_axi_rvalid  = state == S_GNT_3 & m_axi_rvalid ;
assign slice_3_s_axi_rid     = m_axi_rid                       ;
assign slice_3_s_axi_rdata   = m_axi_rdata                     ;
assign slice_3_s_axi_rresp   = m_axi_rresp                     ;
assign slice_3_s_axi_rlast   = m_axi_rlast                     ;

assign m_axi_awvalid         = state == S_GNT_0 & slice_0_s_axi_awvalid |
                               state == S_GNT_1 & slice_1_s_axi_awvalid | 
                               state == S_GNT_2 & slice_2_s_axi_awvalid |
                               state == S_GNT_3 & slice_3_s_axi_awvalid ;
assign m_axi_awid            = state == S_GNT_0 ? slice_0_s_axi_awid    :
                               state == S_GNT_1 ? slice_1_s_axi_awid    :
                               state == S_GNT_2 ? slice_2_s_axi_awid    :
                               state == S_GNT_3 ? slice_3_s_axi_awid    : 'd0;
assign m_axi_awaddr          = state == S_GNT_0 ? slice_0_s_axi_awaddr  :
                               state == S_GNT_1 ? slice_1_s_axi_awaddr  :
                               state == S_GNT_2 ? slice_2_s_axi_awaddr  :
                               state == S_GNT_3 ? slice_3_s_axi_awaddr  : 'd0;
assign m_axi_awlen           = 'd0; //unused
assign m_axi_awsize          = 'd0; //unused
assign m_axi_awburst         = 'd0; //unused

assign m_axi_wvalid          = state == S_GNT_0 & slice_0_s_axi_wvalid |
                               state == S_GNT_1 & slice_1_s_axi_wvalid | 
                               state == S_GNT_2 & slice_2_s_axi_wvalid |
                               state == S_GNT_3 & slice_3_s_axi_wvalid ;
assign m_axi_wdata           = state == S_GNT_0 ? slice_0_s_axi_wdata  :
                               state == S_GNT_1 ? slice_1_s_axi_wdata  :
                               state == S_GNT_2 ? slice_2_s_axi_wdata  :
                               state == S_GNT_3 ? slice_3_s_axi_wdata  : 'd0;
assign m_axi_wstrb           = 'hffff_ffff ; //unused
assign m_axi_wlast           = m_axi_wvalid; // unused
assign m_axi_bready          = state == S_GNT_0 & slice_0_s_axi_bready |
                               state == S_GNT_1 & slice_1_s_axi_bready | 
                               state == S_GNT_2 & slice_2_s_axi_bready |
                               state == S_GNT_3 & slice_3_s_axi_bready ;

assign m_axi_arvalid        = state == S_GNT_0 & slice_0_s_axi_arvalid |
                              state == S_GNT_1 & slice_1_s_axi_arvalid | 
                              state == S_GNT_2 & slice_2_s_axi_arvalid |
                              state == S_GNT_3 & slice_3_s_axi_arvalid ;
assign m_axi_arid           = state == S_GNT_0 ? slice_0_s_axi_arid    :
                              state == S_GNT_1 ? slice_1_s_axi_arid    :
                              state == S_GNT_2 ? slice_2_s_axi_arid    :
                              state == S_GNT_3 ? slice_3_s_axi_arid    : 'd0;
assign m_axi_araddr         = state == S_GNT_0 ? slice_0_s_axi_araddr  :
                              state == S_GNT_1 ? slice_1_s_axi_araddr  :
                              state == S_GNT_2 ? slice_2_s_axi_araddr  :
                              state == S_GNT_3 ? slice_3_s_axi_araddr  : 'd0;
assign m_axi_arlen          = 'd0; //unused
assign m_axi_arsize         = 'd0; //unused
assign m_axi_arburst        = 'd0; //unused

assign m_axi_rready         =  state == S_GNT_0 & slice_0_s_axi_rready |
                               state == S_GNT_1 & slice_1_s_axi_rready |
                               state == S_GNT_2 & slice_2_s_axi_rready |
                               state == S_GNT_3 & slice_3_s_axi_rready ;

endmodule