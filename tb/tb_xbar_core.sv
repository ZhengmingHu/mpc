module tb_xbar_core;
    import mpc_types::*;

logic                        clk                  ;
logic                        rst_n                ;

logic                        u_channel_0_req_valid;
logic                        u_channel_0_req_ready;
channel_req_t                u_channel_0_req      ;
logic                        u_channel_1_req_valid;
logic                        u_channel_1_req_ready;
channel_req_t                u_channel_1_req      ;
logic                        u_channel_2_req_valid;
logic                        u_channel_2_req_ready;
channel_req_t                u_channel_2_req      ;
logic                        d_bank_0_req_valid   ;
logic                        d_bank_0_req_ready   ;
bank_req_t                   d_bank_0_req         ;
logic                        d_bank_1_req_valid   ;
logic                        d_bank_1_req_ready   ;
bank_req_t                   d_bank_1_req         ;
logic                        d_bank_2_req_valid   ;
logic                        d_bank_2_req_ready   ;
bank_req_t                   d_bank_2_req         ;
logic                        d_bank_3_req_valid   ;
logic                        d_bank_3_req_ready   ;
bank_req_t                   d_bank_3_req         ;

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
    d_bank_0_req_ready = 1'b1;
    d_bank_1_req_ready = 1'b1;
    d_bank_2_req_ready = 1'b1;
    d_bank_3_req_ready = 1'b1;
end

initial begin
    #25000;
    $finish;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        u_channel_0_req_valid <= '0;
        u_channel_1_req_valid <= '0;
        u_channel_2_req_valid <= '0;
    end else begin
        u_channel_0_req_valid <=  $random;
        u_channel_1_req_valid <=  $random;
        u_channel_2_req_valid <=  $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        u_channel_0_req.op    <= '0;
        u_channel_0_req.addr  <= '0;
        u_channel_0_req.wdata <= '0;
    end else if (u_channel_0_req_valid & u_channel_0_req_ready) begin
        u_channel_0_req.op    <= $random;
        u_channel_0_req.addr  <= $random;
        u_channel_0_req.wdata <= $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        u_channel_1_req.op    <= '0;
        u_channel_1_req.addr  <= '0;
        u_channel_1_req.wdata <= '0;
    end else if (u_channel_1_req_valid & u_channel_1_req_ready) begin
        u_channel_1_req.op    <= $random;
        u_channel_1_req.addr  <= $random;
        u_channel_1_req.wdata <= $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        u_channel_2_req.op    <= '0;
        u_channel_2_req.addr  <= '0;
        u_channel_2_req.wdata <= '0;
    end else if (u_channel_2_req_valid & u_channel_2_req_ready) begin
        u_channel_2_req.op    <= $random;
        u_channel_2_req.addr  <= $random;
        u_channel_2_req.wdata <= $random;
    end
end

xbar_core u_xbar_core(
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

endmodule