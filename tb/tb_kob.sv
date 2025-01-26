module tb_kob;
    import mpc_types::*;

logic                        clk                        ;
logic                        rst_n                      ;

logic                        u_channel_0_req_valid      ;
logic                        u_channel_0_req_ready      ;
channel_req_t                u_channel_0_req            ;

logic                        u_channel_1_req_valid      ;
logic                        u_channel_1_req_ready      ;
channel_req_t                u_channel_1_req            ;

logic                        u_channel_2_req_valid      ;
logic                        u_channel_2_req_ready      ;
channel_req_t                u_channel_2_req            ;

logic                        d_ch_0_swb_req             ;
logic                        d_ch_0_swb_ack             ;
logic           [  1: 0]     d_ch_0_swb_bank_id         ;

logic                        d_ch_1_swb_req             ;
logic                        d_ch_1_swb_ack             ;
logic           [  1: 0]     d_ch_1_swb_bank_id         ;

logic                        d_ch_2_swb_req             ;
logic                        d_ch_2_swb_ack             ;
logic           [  1: 0]     d_ch_2_swb_bank_id         ;

logic                        ch_0_kob_full              ;
logic                        ch_1_kob_full              ;
logic                        ch_2_kob_full              ;


always# 10  clk = ~clk;

assign u_channel_0_req_ready = ~ch_0_kob_full;
assign u_channel_1_req_ready = ~ch_1_kob_full;
assign u_channel_2_req_ready = ~ch_2_kob_full;

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
        d_ch_0_swb_ack        <= '0;
        d_ch_1_swb_ack        <= '0;
        d_ch_2_swb_ack        <= '0;
    end else begin
        u_channel_0_req_valid <=  $random;
        u_channel_1_req_valid <=  $random;
        u_channel_2_req_valid <=  $random;
        d_ch_0_swb_ack        <=  $random;
        d_ch_1_swb_ack        <=  $random;
        d_ch_2_swb_ack        <=  $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        u_channel_0_req.op    <= '0;
        u_channel_0_req.addr  <= '0;
        u_channel_0_req.wdata <= '0;
    end else if (u_channel_0_req_valid & u_channel_0_req_ready) begin
        u_channel_0_req.addr  <= $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        u_channel_1_req.op    <= '0;
        u_channel_1_req.addr  <= '0;
        u_channel_1_req.wdata <= '0;
    end else if (u_channel_1_req_valid & u_channel_1_req_ready) begin
        u_channel_1_req.addr    <= $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        u_channel_2_req.op    <= '0;
        u_channel_2_req.addr  <= '0;
        u_channel_2_req.wdata <= '0;
    end else if (u_channel_2_req_valid & u_channel_2_req_ready) begin
        u_channel_2_req.addr  <= $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_ch_0_swb_ack <= '0;
        d_ch_1_swb_ack <= '0;
        d_ch_2_swb_ack <= '0;
    end else begin
        d_ch_0_swb_ack <= $random;
        d_ch_1_swb_ack <= $random;
        d_ch_2_swb_ack <= $random;
    end
end

kob u_kob(
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

endmodule