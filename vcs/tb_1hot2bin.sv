`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/12 16:42:56
// Design Name: 
// Module Name: round_robin_arb_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define MASK

module tb_1hot2bin();

localparam  ONE_HOT_WIDTH     = 8;

reg                             clk      = 0;
reg                             rst_n    = 0;
reg  [        ONE_HOT_WIDTH-1:0]      one_hot_code;
reg  [$clog2(ONE_HOT_WIDTH)-1:0]      bin_code;

always# 10  clk = ~clk;

initial begin
    #453
    rst_n   = 1;
    #50
    one_hot_code = 8'd1;
    #50
    one_hot_code = 8'd2;
    #50
    one_hot_code = 8'd4;
    #50
    one_hot_code = 8'd8;
    #50
    one_hot_code = 8'd16;
    #50
    one_hot_code = 8'd32;
end

initial begin
    #25000;
    $finish;
end

`ifdef iverilog
initial
begin            
    $dumpfile("tb_1hot2bin.vcd");      
    $dumpvars(0, tb_1hot2bin);
end
`endif

`ifdef FSDB
reg [1024:0] FSDB_FILE;
initial begin
    if ($value$plusargs("FSDB_FILE=%s", FSDB_FILE)) begin
        $fsdbDumpfile(FSDB_FILE);
        $fsdbDumpvars("+all");
    end
end
`endif

ns_1hot2bin#(
    .ONE_HOT_WIDTH(ONE_HOT_WIDTH)
)u_ns_1hot2bin(
    .one_hot_code(one_hot_code),
    .bin_code(bin_code)    
);


endmodule
