module tb_prio_enc;

logic       [   7: 0]            x            ;
logic       [   2: 0]            msb          ;

always# 10  x = $random;

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


ns_prio_enc#(
    .WIDTH(8)
)u_ns_prio_enc(
    .*
);

endmodule