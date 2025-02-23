module mpc_sram
#(
    parameter int unsigned ADDR_SIZE = 2,
    parameter int unsigned DATA_SIZE = 2,
    parameter int unsigned DEPTH = 2**ADDR_SIZE
)
(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  cs,
    input  logic                  we,
    input  logic [ADDR_SIZE-1:0]  addr,
    input  logic [DATA_SIZE-1:0]  wdata,
    output logic [DATA_SIZE-1:0]  rdata
);

    mpc_sram_1rw #(
        .ADDR_SIZE(ADDR_SIZE),
        .DATA_SIZE(DATA_SIZE),
        .DEPTH(DEPTH)
    ) ram_i (
        .clk,
        .rst_n,
        .cs,
        .we,
        .addr,
        .wdata,
        .rdata
    );

endmodule

module mpc_sram_1rw
#(
    parameter int unsigned ADDR_SIZE = 0,
    parameter int unsigned DATA_SIZE = 0,
    parameter int unsigned DEPTH = 2**ADDR_SIZE
)
(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  cs,
    input  logic                  we,
    input  logic [ADDR_SIZE-1:0]  addr,
    input  logic [DATA_SIZE-1:0]  wdata,
    output logic [DATA_SIZE-1:0]  rdata
);

    /*
     *  Internal memory array declaration
     */
    typedef logic [DATA_SIZE-1:0] mem_t [DEPTH];
    mem_t mem;

    /*
     *  Process to update or read the memory array
     */
    always_ff @(posedge clk)
    begin
        if (cs == 1'b1) begin
            if (we == 1'b1) begin
                mem[addr] <= wdata;
            end
            rdata <= mem[addr];
        end
    end
endmodule