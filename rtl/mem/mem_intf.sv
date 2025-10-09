module memory_interface 
    import mpc_types::*;
#(
    parameter mpc_cfg_t Cfg = '0,
    parameter type clWidth_t       = logic,   
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

    // 1. Slave AXI AW Channel
    output logic                        s_axi_awready              ,
    input  logic                        s_axi_awvalid              ,
    input  logic           [  1: 0]     s_axi_awid                 ,
    input  logic           [ 31: 0]     s_axi_awaddr               ,
    input  logic           [  7: 0]     s_axi_awlen                ,
    input  logic           [  2: 0]     s_axi_awsize               ,
    input  logic           [  1: 0]     s_axi_awburst              ,

    // 2. Slave AXI W Channel
    output  logic                       s_axi_wready               ,
    input   logic                       s_axi_wvalid               ,
    input   clWidth_t                   s_axi_wdata                ,
    input   logic           [ 31: 0]    s_axi_wstrb                ,
    input   logic                       s_axi_wlast                ,
    input   logic                       s_axi_bready               ,
    output  logic                       s_axi_bvalid               ,
    output  logic           [  1: 0]    s_axi_bid                  ,
    output  logic           [  1: 0]    s_axi_bresp                ,
    
    // 3. Slave AXI AR Channel
    output  logic                       s_axi_arready              ,
    input   logic                       s_axi_arvalid              ,
    input   logic           [  1: 0]    s_axi_arid                 ,
    input   logic           [ 31: 0]    s_axi_araddr               ,
    input   logic           [  7: 0]    s_axi_arlen                ,
    input   logic           [  2: 0]    s_axi_arsize               ,
    input   logic           [  1: 0]    s_axi_arburst              ,
    
    // 4. Slave AXI R Channel
    input   logic                       s_axi_rready               ,
    output  logic                       s_axi_rvalid               ,
    output  logic           [  1: 0]    s_axi_rid                  ,
    output  clWidth_t                   s_axi_rdata                ,
    output  logic           [  1: 0]    s_axi_rresp                ,
    output  logic                       s_axi_rlast  
);
    // Import DPI-C functions - modified to use output parameter instead of return
    import "DPI-C" function void write_memory(input int address, input bit [Cfg.u.clWidth-1:0] data, input bit write_en, input int cacheline_width);
    import "DPI-C" function void read_memory(input int address, output bit [Cfg.u.clWidth-1:0] data, input bit read_en, input int cacheline_width);
    
    
    bit   [255:0] temp_data;

    logic         awaddr_en;
    logic [ 31:0] awaddr_nxt;
    logic [ 31:0] awaddr;

    logic         wdata_en;
    clWidth_t     wdata;

    logic         read_en;
    logic [ 31:0] araddr;

    localparam bankMSB       = Cfg.u.addrWidth - Cfg.tagWidth - 1;
    localparam bankLSB       = Cfg.offsetWidth + Cfg.byteWidth + Cfg.setWidth; 
    assign awaddr_en  = s_axi_awvalid && s_axi_awready;
    assign awaddr = s_axi_awaddr[31:0];
    assign wdata_en = s_axi_wvalid && s_axi_wready;
    assign wdata    = s_axi_wdata;
    
    assign read_en = s_axi_arvalid && s_axi_arready; 
    assign araddr = s_axi_araddr[31:0];
    ns_gnrl_dfflr # (1) rvalid_dfflr (1'b1, read_en, s_axi_rvalid, clk, rst_n);
    ns_gnrl_dfflr # (1) rlast_dfflr (1'b1, read_en, s_axi_rlast, clk, rst_n);
    ns_gnrl_dfflr # (2) rid_dfflr (read_en, s_axi_arid, s_axi_rid, clk, rst_n);
    assign s_axi_rresp = 'd0;

    ns_gnrl_dfflr # (1) bvalid_dfflr (1'b1, wdata_en, s_axi_bvalid, clk, rst_n);
    ns_gnrl_dfflr # (2) bid_dfflr (wdata_en, s_axi_awid, s_axi_bid, clk, rst_n);
    assign s_axi_bresp = 'd0;

    always @ (posedge clk) begin
        write_memory(awaddr, wdata, wdata_en, Cfg.u.clWidth);
    end

    always @ (*)
        read_memory(araddr, temp_data, read_en, Cfg.u.clWidth);
    
    always @ (posedge clk) begin
        if (!rst_n)
            s_axi_rdata <= 'd0;
        else if (read_en)
            s_axi_rdata <= temp_data;
    end
    
    assign s_axi_awready = 1'b1;
    assign s_axi_arready = !s_axi_awvalid & !s_axi_wvalid;
    assign s_axi_wready = 1'b1;

    
    // Example usage
    /* initial begin 
        logic [255:0] test_data;
        logic [255:0] read_back;
        // Test write and read
        test_data = 255'h1A2B3C4D5E6F7A8B9C0D1E2F3A4B5C6D7E8F9A0B1C2D3E4F5A6B7C8D9E0F1;
        write_memory(0, test_data);
        read_memory(0, read_back);  // Now using output parameter
        
        $display("Written: %h", test_data);
        $display("Read back: %h", read_back);
        
        // Verify
        if (test_data !== read_back) begin
            $display("ERROR: Data mismatch!");
        end else begin
            $display("SUCCESS: Data matches!");
        end
        
        // Test another address
        test_data = 255'h5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A;
        write_memory(1023, test_data);
        read_memory(1023, read_back);
        
        $display("Written to address 1023: %h", test_data);
        $display("Read back: %h", read_back);
    end
    */

endmodule
