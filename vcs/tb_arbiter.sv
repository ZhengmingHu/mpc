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

module tb_arbiter();

localparam  CHANNUM     = 8;

reg                             clk      = 0;
reg                             rst_n    = 0;
reg  [        CHANNUM-1:0]      req         ;
reg  [$clog2(CHANNUM)-1:0]      req_mask_idx;
reg                             en          ;
wire [        CHANNUM-1:0]      gnt         ;


always# 10  clk = ~clk;

initial begin
    #453
    rst_n   = 1;
end

initial begin
    #25000;
    $finish;
end

`ifdef iverilog
initial
begin            
    $dumpfile("tb_arbiter.vcd");      
    $dumpvars(0, tb_arbiter);
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

// set arbt_en ////////////////////

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        en = 1'b0;
    else
        en = $random;
end

// set req ////////////////////////

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        req <= 'h0;
        req_mask_idx <= 'h0;
    end else if (en) begin
        req <= $random;
        req_mask_idx <= $random;
    end
end

`ifdef MASK
ns_gnrl_rrobin_mask#(
    .ARBT_NUM(CHANNUM)
)round_robin_arbiter_inst(
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    
    .req_vec                            (req                       ),
    .req_mask_idx                       (req_mask_idx              ),
    .arbt_ena                           (en                        ),
    .grt_vec                            (gnt                       ) 
);
`else
ns_gnrl_rrobin#(
    .ARBT_NUM(CHANNUM)
)round_robin_arbiter_inst(
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    
    .req_vec                            (req                       ),
    .arbt_ena                           (en                        ),
    .grt_vec                            (gnt                       ) 
);
`endif

endmodule
