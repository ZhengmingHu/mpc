module ns_gnrl_dfflrs # (
  parameter DW   = 32
, parameter [DW-1:0]  RST  = {DW{1'b1}}
) (
  input               lden,
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,

  input               clk,
  input               rst_n
);
reg [DW-1:0] qout_r;

always @(posedge clk or negedge rst_n)
begin : DFF_PROC
  if (rst_n == 1'b0)
    qout_r <= RST;
  else if (lden == 1'b1)
    qout_r <= dnxt;
end

assign qout = qout_r[DW-1:0];

endmodule