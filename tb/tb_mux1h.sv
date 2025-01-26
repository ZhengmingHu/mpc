module tb_mux1h;

logic       [   2: 0]            data_grp   [7:0]            ;
logic       [   7: 0]            one_hot_flg                 ;
logic       [   2: 0]            data_sel;

always # 10  data_grp[0] = $random;
always # 10  data_grp[1] = $random;
always # 10  data_grp[2] = $random;
always # 10  data_grp[3] = $random;
always # 10  data_grp[4] = $random;
always # 10  data_grp[5] = $random;
always # 10  data_grp[6] = $random;
always # 10  data_grp[7] = $random;


always # 10 one_hot_flg[0] = 0;
always # 10 one_hot_flg[1] = 0;
always # 10 one_hot_flg[2] = 0;
always # 10 one_hot_flg[3] = 0;
always # 10 one_hot_flg[4] = 0;
always # 10 one_hot_flg[5] = 0;
always # 10 one_hot_flg[6] = $random;
always # 10 one_hot_flg[7] = 0;

reg [1024:0] FSDB_FILE;
initial begin
    if ($value$plusargs("FSDB_FILE=%s", FSDB_FILE)) begin
        $fsdbDumpfile(FSDB_FILE);
        $fsdbDumpvars("+all");
    end
end

initial begin
    #25000;
    $finish;
end


ns_mux1h#(
    .DATA_WIDTH(3),
    .SEL_WIDTH(8)
)u_ns_mux1h(
    .*
);

endmodule