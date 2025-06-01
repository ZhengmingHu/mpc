module ns_mux1h#
(
    parameter DATA_WIDTH = 3,
    parameter SEL_WIDTH  = 8
)
(
    input  logic [DATA_WIDTH-1:0] data_grp [SEL_WIDTH-1:0] ,
    input  logic [ SEL_WIDTH-1:0] one_hot_flg              ,
    output logic [DATA_WIDTH-1:0] data_sel
);

always_comb begin
     data_sel = 0;
     for (int i = 0; i < SEL_WIDTH; i++) begin
        if (one_hot_flg[i]) begin
          data_sel = data_grp[i];
          break;
        end
     end
   end


endmodule