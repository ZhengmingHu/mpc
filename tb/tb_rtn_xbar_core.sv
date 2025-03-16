module tb_rtn_xbar_core;
    import mpc_types::*;

logic                        clk                  ;
logic                        rst_n                ;

logic                        d_bank_0_rsp_valid         ;
logic                        d_bank_0_rsp_ready         ;
logic          [127: 0]      d_bank_0_rsp_data          ;
logic          [  1: 0]      d_bank_0_rsp_channel_id    ;

logic                        d_bank_1_rsp_valid         ;
logic                        d_bank_1_rsp_ready         ;
logic          [127: 0]      d_bank_1_rsp_data          ;
logic          [  1: 0]      d_bank_1_rsp_channel_id    ;

logic                        d_bank_2_rsp_valid         ;
logic                        d_bank_2_rsp_ready         ;
logic          [127: 0]      d_bank_2_rsp_data          ;
logic          [  1: 0]      d_bank_2_rsp_channel_id    ;

logic                        d_bank_3_rsp_valid         ;
logic                        d_bank_3_rsp_ready         ;
logic          [127: 0]      d_bank_3_rsp_data          ;
logic          [  1: 0]      d_bank_3_rsp_channel_id    ;

logic                        u_channel_0_rsp_valid      ;
logic                        u_channel_0_rsp_ready      ;
logic          [127: 0]      u_channel_0_rsp_data       ;
logic          [  1: 0]      u_channel_0_rsp_bank_id    ;

logic                        u_channel_1_rsp_valid      ;
logic                        u_channel_1_rsp_ready      ;
logic          [127: 0]      u_channel_1_rsp_data       ;
logic          [  1: 0]      u_channel_1_rsp_bank_id    ;

logic                        u_channel_2_rsp_valid      ;
logic                        u_channel_2_rsp_ready      ;
logic          [127: 0]      u_channel_2_rsp_data       ;
logic          [  1: 0]      u_channel_2_rsp_bank_id    ;

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
    u_channel_0_rsp_ready = 1'b1;
    u_channel_1_rsp_ready = 1'b1;
    u_channel_2_rsp_ready = 1'b1;
    #453
    rst_n   = 1'b1;
    u_channel_0_rsp_ready = 1'b1;
    u_channel_1_rsp_ready = 1'b1;
    u_channel_2_rsp_ready = 1'b1;
end

initial begin
    #25000;
    $finish;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_bank_0_rsp_valid <= '0;
        d_bank_1_rsp_valid <= '0;
        d_bank_2_rsp_valid <= '0;
        d_bank_3_rsp_valid <= '0;
    end else begin
        d_bank_0_rsp_valid <=  $random;
        d_bank_1_rsp_valid <=  $random;
        d_bank_2_rsp_valid <=  $random;
        d_bank_3_rsp_valid <=  $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_bank_0_rsp_data <= '0;
        d_bank_0_rsp_channel_id <= '0;
    end else if (d_bank_0_rsp_valid & d_bank_0_rsp_ready) begin
        d_bank_0_rsp_data <= $random;
        d_bank_0_rsp_channel_id <= $urandom_range(2, 0);
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_bank_1_rsp_data <= '0;
        d_bank_1_rsp_channel_id <= '0;
    end else if (d_bank_1_rsp_valid & d_bank_1_rsp_ready) begin
        d_bank_1_rsp_data <= $random;
        d_bank_1_rsp_channel_id <=  $urandom_range(2, 0);
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_bank_2_rsp_data <= '0;
        d_bank_2_rsp_channel_id <= '0;
    end else if (d_bank_2_rsp_valid & d_bank_2_rsp_ready) begin
        d_bank_2_rsp_data <= $random;
        d_bank_2_rsp_channel_id <= $urandom_range(2, 0);
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_bank_3_rsp_data <= '0;
        d_bank_3_rsp_channel_id <= '0;
    end else if (d_bank_3_rsp_valid & d_bank_3_rsp_ready) begin
        d_bank_3_rsp_data <= $random;
        d_bank_3_rsp_channel_id <=  $urandom_range(2, 0);
    end
end

rtn_xbar_core u_rtn_xbar_core(
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

endmodule