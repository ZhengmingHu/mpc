module slice_0_memory_interface 
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

    // 1. Slave AXI AW Channel
    output logic                        s_axi_awready              ,
    input  logic                        s_axi_awvalid              ,
    input  nlineWidth_t                 s_axi_awid                 ,
    input  logic           [ 31: 0]     s_axi_awaddr               ,
    input  logic           [  7: 0]     s_axi_awlen                ,
    input  logic           [  2: 0]     s_axi_awsize               ,
    input  logic           [  1: 0]     s_axi_awburst              ,

    // 2. Slave AXI W Channel
    output  logic                       s_axi_wready               ,
    input   logic                       s_axi_wvalid               ,
    input   logic           [255: 0]    s_axi_wdata                ,
    input   logic           [ 31: 0]    s_axi_wstrb                ,
    input   logic                       s_axi_wlast                ,
    input   logic                       s_axi_bready               ,
    output  logic                       s_axi_bvalid               ,
    output  nlineWidth_t                s_axi_bid                  ,
    output  logic           [  1: 0]    s_axi_bresp                ,
    
    // 3. Slave AXI AR Channel
    output  logic                       s_axi_arready              ,
    input   logic                       s_axi_arvalid              ,
    input   nlineWidth_t                s_axi_arid                 ,
    input   logic           [ 31: 0]    s_axi_araddr               ,
    input   logic           [  7: 0]    s_axi_arlen                ,
    input   logic           [  2: 0]    s_axi_arsize               ,
    input   logic           [  1: 0]    s_axi_arburst              ,
    
    // 4. Slave AXI R Channel
    input   logic                       s_axi_rready               ,
    output  logic                       s_axi_rvalid               ,
    output  nlineWidth_t                s_axi_rid                  ,
    output  logic           [255: 0]    s_axi_rdata                ,
    output  logic           [  1: 0]    s_axi_rresp                ,
    output  logic                       s_axi_rlast  
);
    // Import DPI-C functions - modified to use output parameter instead of return
    // import "DPI-C" function void init_slice_memory();
    import "DPI-C" function void write_slice_0_memory(input int address, input bit [254:0] data, input bit write_en);
    import "DPI-C" function void read_slice_0_memory(input int address, output bit [254:0] data, input bit read_en);
    
    
    

    logic         awaddr_en;
    logic [ 24:0] awaddr_nxt;
    logic [ 24:0] awaddr;

    logic         wdata_en;
    logic         write_en;
    logic [255:0] wdata;

    logic         read_en;
    logic [ 24:0] araddr;
    logic [255:0] rdata_nxt;

    assign awaddr_en  = s_axi_awvalid && s_axi_awready;
    assign awaddr_nxt = {s_axi_awaddr[31:10], s_axi_awaddr[7:5]};
    ns_gnrl_dfflr # (25) awaddr_dfflr (awaddr_en, awaddr_nxt, awaddr, clk, rst_n);
    assign wdata_en = s_axi_wvalid && s_axi_wready;
    ns_gnrl_dfflr # (256) wdata_dfflr (wdata_en, s_axi_wdata, wdata, clk, rst_n);
    ns_gnrl_dfflr # (1) write_en_dfflr (1'b1, wdata_en, write_en, clk, rst_n);
    
    assign read_en = s_axi_arvalid && s_axi_arready; 
    assign araddr = {s_axi_araddr[31:10], s_axi_araddr[7:5]};
    ns_gnrl_dfflr # (1) rvalid_dfflr (1'b1, read_en, s_axi_rvalid, clk, rst_n);
    ns_gnrl_dfflr # (1) rlast_dfflr (1'b1, read_en, s_axi_rlast, clk, rst_n);
    ns_gnrl_dfflr # (256) rdata_dfflr (read_en, rdata_nxt, s_axi_rdata, clk, rst_n);
    ns_gnrl_dfflr # (Cfg.nlineWidth) rid_dfflr (read_en, s_axi_arid, s_axi_rid, clk, rst_n);
    assign s_axi_rresp = 'd0;

    ns_gnrl_dfflr # (1) bvalid_dfflr (1'b1, wdata_en, s_axi_bvalid, clk, rst_n);
    ns_gnrl_dfflr # (Cfg.nlineWidth) bid_dfflr (wdata_en, s_axi_awid, s_axi_bid, clk, rst_n);
    assign s_axi_bresp = 'd0;

    always @ (*) begin
        write_slice_0_memory(awaddr, wdata, write_en);
    end
    
    always @ (*) begin
        read_slice_0_memory(araddr, rdata_nxt, read_en);
    end
    
    assign s_axi_awready = 1'b1;
    assign s_axi_arready = !s_axi_awvalid & !s_axi_wvalid;
    assign s_axi_wready = 1'b1;


    // Initialize memory
    // initial begin
    //    init_slice_memory();
    // end
    
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

module slice_1_memory_interface 
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

    // 1. Slave AXI AW Channel
    output logic                        s_axi_awready              ,
    input  logic                        s_axi_awvalid              ,
    input  nlineWidth_t                 s_axi_awid                 ,
    input  logic           [ 31: 0]     s_axi_awaddr               ,
    input  logic           [  7: 0]     s_axi_awlen                ,
    input  logic           [  2: 0]     s_axi_awsize               ,
    input  logic           [  1: 0]     s_axi_awburst              ,

    // 2. Slave AXI W Channel
    output  logic                       s_axi_wready               ,
    input   logic                       s_axi_wvalid               ,
    input   logic           [255: 0]    s_axi_wdata                ,
    input   logic           [ 31: 0]    s_axi_wstrb                ,
    input   logic                       s_axi_wlast                ,
    input   logic                       s_axi_bready               ,
    output  logic                       s_axi_bvalid               ,
    output  nlineWidth_t                s_axi_bid                  ,
    output  logic           [  1: 0]    s_axi_bresp                ,
    
    // 3. Slave AXI AR Channel
    output  logic                       s_axi_arready              ,
    input   logic                       s_axi_arvalid              ,
    input   nlineWidth_t                s_axi_arid                 ,
    input   logic           [ 31: 0]    s_axi_araddr               ,
    input   logic           [  7: 0]    s_axi_arlen                ,
    input   logic           [  2: 0]    s_axi_arsize               ,
    input   logic           [  1: 0]    s_axi_arburst              ,
    
    // 4. Slave AXI R Channel
    input   logic                       s_axi_rready               ,
    output  logic                       s_axi_rvalid               ,
    output  nlineWidth_t                s_axi_rid                  ,
    output  logic           [255: 0]    s_axi_rdata                ,
    output  logic           [  1: 0]    s_axi_rresp                ,
    output  logic                       s_axi_rlast  
);
    // Import DPI-C functions - modified to use output parameter instead of return
    import "DPI-C" function void write_slice_1_memory(input int address, input bit [254:0] data, input bit write_en);
    import "DPI-C" function void read_slice_1_memory(input int address, output bit [254:0] data, input bit read_en);
    
    
    

    logic         awaddr_en;
    logic [ 24:0] awaddr_nxt;
    logic [ 24:0] awaddr;

    logic         wdata_en;
    logic         write_en;
    logic [255:0] wdata;

    logic         read_en;
    logic [ 24:0] araddr;
    logic [255:0] rdata_nxt;

    assign awaddr_en  = s_axi_awvalid && s_axi_awready;
    assign awaddr_nxt = {s_axi_awaddr[31:10], s_axi_awaddr[7:5]};
    ns_gnrl_dfflr # (25) awaddr_dfflr (awaddr_en, awaddr_nxt, awaddr, clk, rst_n);
    assign wdata_en = s_axi_wvalid && s_axi_wready;
    ns_gnrl_dfflr # (256) wdata_dfflr (wdata_en, s_axi_wdata, wdata, clk, rst_n);
    ns_gnrl_dfflr # (1) write_en_dfflr (1'b1, wdata_en, write_en, clk, rst_n);
    
    assign read_en = s_axi_arvalid && s_axi_arready; 
    assign araddr = {s_axi_araddr[31:10], s_axi_araddr[7:5]};
    ns_gnrl_dfflr # (1) rvalid_dfflr (1'b1, read_en, s_axi_rvalid, clk, rst_n);
    ns_gnrl_dfflr # (1) rlast_dfflr (1'b1, read_en, s_axi_rlast, clk, rst_n);
    ns_gnrl_dfflr # (256) rdata_dfflr (read_en, rdata_nxt, s_axi_rdata, clk, rst_n);
    ns_gnrl_dfflr # (Cfg.nlineWidth) rid_dfflr (read_en, s_axi_arid, s_axi_rid, clk, rst_n);
    assign s_axi_rresp = 'd0;

    ns_gnrl_dfflr # (1) bvalid_dfflr (1'b1, wdata_en, s_axi_bvalid, clk, rst_n);
    ns_gnrl_dfflr # (Cfg.nlineWidth) bid_dfflr (wdata_en, s_axi_awid, s_axi_bid, clk, rst_n);
    assign s_axi_bresp = 'd0;

    always @ (*) begin
        write_slice_1_memory(awaddr, wdata, write_en);
    end
    
    always @ (*) begin
        read_slice_1_memory(araddr, rdata_nxt, read_en);
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


module slice_2_memory_interface 
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

    // 1. Slave AXI AW Channel
    output logic                        s_axi_awready              ,
    input  logic                        s_axi_awvalid              ,
    input  nlineWidth_t                 s_axi_awid                 ,
    input  logic           [ 31: 0]     s_axi_awaddr               ,
    input  logic           [  7: 0]     s_axi_awlen                ,
    input  logic           [  2: 0]     s_axi_awsize               ,
    input  logic           [  1: 0]     s_axi_awburst              ,

    // 2. Slave AXI W Channel
    output  logic                       s_axi_wready               ,
    input   logic                       s_axi_wvalid               ,
    input   logic           [255: 0]    s_axi_wdata                ,
    input   logic           [ 31: 0]    s_axi_wstrb                ,
    input   logic                       s_axi_wlast                ,
    input   logic                       s_axi_bready               ,
    output  logic                       s_axi_bvalid               ,
    output  nlineWidth_t                s_axi_bid                  ,
    output  logic           [  1: 0]    s_axi_bresp                ,
    
    // 3. Slave AXI AR Channel
    output  logic                       s_axi_arready              ,
    input   logic                       s_axi_arvalid              ,
    input   nlineWidth_t                s_axi_arid                 ,
    input   logic           [ 31: 0]    s_axi_araddr               ,
    input   logic           [  7: 0]    s_axi_arlen                ,
    input   logic           [  2: 0]    s_axi_arsize               ,
    input   logic           [  1: 0]    s_axi_arburst              ,
    
    // 4. Slave AXI R Channel
    input   logic                       s_axi_rready               ,
    output  logic                       s_axi_rvalid               ,
    output  nlineWidth_t                s_axi_rid                  ,
    output  logic           [255: 0]    s_axi_rdata                ,
    output  logic           [  1: 0]    s_axi_rresp                ,
    output  logic                       s_axi_rlast  
);
    // Import DPI-C functions - modified to use output parameter instead of return
    import "DPI-C" function void write_slice_2_memory(input int address, input bit [254:0] data, input bit write_en);
    import "DPI-C" function void read_slice_2_memory(input int address, output bit [254:0] data, input bit read_en);
    
    
    

    logic         awaddr_en;
    logic [ 24:0] awaddr_nxt;
    logic [ 24:0] awaddr;

    logic         wdata_en;
    logic         write_en;
    logic [255:0] wdata;

    logic         read_en;
    logic [ 24:0] araddr;
    logic [255:0] rdata_nxt;

    assign awaddr_en  = s_axi_awvalid && s_axi_awready;
    assign awaddr_nxt = {s_axi_awaddr[31:10], s_axi_awaddr[7:5]};
    ns_gnrl_dfflr # (25) awaddr_dfflr (awaddr_en, awaddr_nxt, awaddr, clk, rst_n);
    assign wdata_en = s_axi_wvalid && s_axi_wready;
    ns_gnrl_dfflr # (256) wdata_dfflr (wdata_en, s_axi_wdata, wdata, clk, rst_n);
    ns_gnrl_dfflr # (1) write_en_dfflr (1'b1, wdata_en, write_en, clk, rst_n);
    
    assign read_en = s_axi_arvalid && s_axi_arready; 
    assign araddr = {s_axi_araddr[31:10], s_axi_araddr[7:5]};
    ns_gnrl_dfflr # (1) rvalid_dfflr (1'b1, read_en, s_axi_rvalid, clk, rst_n);
    ns_gnrl_dfflr # (1) rlast_dfflr (1'b1, read_en, s_axi_rlast, clk, rst_n);
    ns_gnrl_dfflr # (256) rdata_dfflr (read_en, rdata_nxt, s_axi_rdata, clk, rst_n);
    ns_gnrl_dfflr # (Cfg.nlineWidth) rid_dfflr (read_en, s_axi_arid, s_axi_rid, clk, rst_n);
    assign s_axi_rresp = 'd0;

    ns_gnrl_dfflr # (1) bvalid_dfflr (1'b1, wdata_en, s_axi_bvalid, clk, rst_n);
    ns_gnrl_dfflr # (Cfg.nlineWidth) bid_dfflr (wdata_en, s_axi_awid, s_axi_bid, clk, rst_n);
    assign s_axi_bresp = 'd0;

    always @ (*) begin
        write_slice_2_memory(awaddr, wdata, write_en);
    end
    
    always @ (*) begin
        read_slice_2_memory(araddr, rdata_nxt, read_en);
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


module slice_3_memory_interface 
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

    // 1. Slave AXI AW Channel
    output logic                        s_axi_awready              ,
    input  logic                        s_axi_awvalid              ,
    input  nlineWidth_t                 s_axi_awid                 ,
    input  logic           [ 31: 0]     s_axi_awaddr               ,
    input  logic           [  7: 0]     s_axi_awlen                ,
    input  logic           [  2: 0]     s_axi_awsize               ,
    input  logic           [  1: 0]     s_axi_awburst              ,

    // 2. Slave AXI W Channel
    output  logic                       s_axi_wready               ,
    input   logic                       s_axi_wvalid               ,
    input   logic           [255: 0]    s_axi_wdata                ,
    input   logic           [ 31: 0]    s_axi_wstrb                ,
    input   logic                       s_axi_wlast                ,
    input   logic                       s_axi_bready               ,
    output  logic                       s_axi_bvalid               ,
    output  nlineWidth_t                s_axi_bid                  ,
    output  logic           [  1: 0]    s_axi_bresp                ,
    
    // 3. Slave AXI AR Channel
    output  logic                       s_axi_arready              ,
    input   logic                       s_axi_arvalid              ,
    input   nlineWidth_t                s_axi_arid                 ,
    input   logic           [ 31: 0]    s_axi_araddr               ,
    input   logic           [  7: 0]    s_axi_arlen                ,
    input   logic           [  2: 0]    s_axi_arsize               ,
    input   logic           [  1: 0]    s_axi_arburst              ,
    
    // 4. Slave AXI R Channel
    input   logic                       s_axi_rready               ,
    output  logic                       s_axi_rvalid               ,
    output  nlineWidth_t                s_axi_rid                  ,
    output  logic           [255: 0]    s_axi_rdata                ,
    output  logic           [  1: 0]    s_axi_rresp                ,
    output  logic                       s_axi_rlast  
);
    // Import DPI-C functions - modified to use output parameter instead of return
    import "DPI-C" function void write_slice_3_memory(input int address, input bit [254:0] data, input bit write_en);
    import "DPI-C" function void read_slice_3_memory(input int address, output bit [254:0] data, input bit read_en);
    
    
    

    logic         awaddr_en;
    logic [ 24:0] awaddr_nxt;
    logic [ 24:0] awaddr;

    logic         wdata_en;
    logic         write_en;
    logic [255:0] wdata;

    logic         read_en;
    logic [ 24:0] araddr;
    logic [255:0] rdata_nxt;

    assign awaddr_en  = s_axi_awvalid && s_axi_awready;
    assign awaddr_nxt = {s_axi_awaddr[31:10], s_axi_awaddr[7:5]};
    ns_gnrl_dfflr # (25) awaddr_dfflr (awaddr_en, awaddr_nxt, awaddr, clk, rst_n);
    assign wdata_en = s_axi_wvalid && s_axi_wready;
    ns_gnrl_dfflr # (256) wdata_dfflr (wdata_en, s_axi_wdata, wdata, clk, rst_n);
    ns_gnrl_dfflr # (1) write_en_dfflr (1'b1, wdata_en, write_en, clk, rst_n);
    
    assign read_en = s_axi_arvalid && s_axi_arready; 
    assign araddr = {s_axi_araddr[31:10], s_axi_araddr[7:5]};
    ns_gnrl_dfflr # (1) rvalid_dfflr (1'b1, read_en, s_axi_rvalid, clk, rst_n);
    ns_gnrl_dfflr # (1) rlast_dfflr (1'b1, read_en, s_axi_rlast, clk, rst_n);
    ns_gnrl_dfflr # (256) rdata_dfflr (read_en, rdata_nxt, s_axi_rdata, clk, rst_n);
    ns_gnrl_dfflr # (Cfg.nlineWidth) rid_dfflr (read_en, s_axi_arid, s_axi_rid, clk, rst_n);
    assign s_axi_rresp = 'd0;

    ns_gnrl_dfflr # (1) bvalid_dfflr (1'b1, wdata_en, s_axi_bvalid, clk, rst_n);
    ns_gnrl_dfflr # (Cfg.nlineWidth) bid_dfflr (wdata_en, s_axi_awid, s_axi_bid, clk, rst_n);
    assign s_axi_bresp = 'd0;

    always @ (*) begin
        write_slice_3_memory(awaddr, wdata, write_en);
    end
    
    always @ (*) begin
        read_slice_3_memory(araddr, rdata_nxt, read_en);
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
