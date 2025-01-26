module tb_srb;

parameter DATA_WIDTH = 32;
parameter SRB_DEPTH  = 8;

logic                               clk                        ;
logic                               rst_n                      ;

logic                               w_req_valid                ;
logic                               w_req_ready                ;
logic    [       DATA_WIDTH-1:0]    w_req_data                 ;

logic                               r_req_valid                ;
logic    [$clog2(SRB_DEPTH)-1:0]    r_req_idx                  ;
logic                               r_req_ready                ;

logic                               r_rsp_valid                ;
logic    [       DATA_WIDTH-1:0]    r_rsp_data                 ;                           
logic                               r_rsp_ready                ;

logic    [        SRB_DEPTH-1:0]    entry_valid                ;
logic    [$clog2(SRB_DEPTH)-1:0]    bottom_id                  ;

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
end

initial begin
    #25000;
    $finish;
end


always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        w_req_valid <= '0;
        w_req_data  <= '0;
        r_req_valid <= '0;
        r_req_idx   <= '0;
        r_rsp_ready <= '0; 
    end else begin
        w_req_valid <= $random;
        w_req_data  <= $random;
        r_req_valid <= $random;
        r_req_idx   <= $random;
        r_rsp_ready <= $random; 
    end
end

srb#(32, 8)
u_srb(
    .*
);

endmodule