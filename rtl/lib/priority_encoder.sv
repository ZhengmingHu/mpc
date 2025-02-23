module priority_encoder #(
  parameter WIDTH = 8
) 
(
  input  logic  [        WIDTH-1:0] in  ,
  output logic  [$clog2(WIDTH)-1:0] out
);

always_comb begin
  out = 'd0;
  for (int i = 0; i < WIDTH; i++)
  begin
    if (in[i]) begin
      out = i;
      break;
    end
  end
end

endmodule