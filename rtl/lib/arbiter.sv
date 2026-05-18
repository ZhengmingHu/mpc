module ns_gnrl_rrobin # (
    parameter ARBT_NUM = 4
)(
    output             [ARBT_NUM-1: 0]  grt_vec                    ,
    input              [ARBT_NUM-1: 0]  req_vec                    ,
    input                               arbt_ena                   ,
    input                               clk                        ,
    input                               rst_n                       
);

logic [ARBT_NUM-1:0] req_ored_vec;
logic [ARBT_NUM-1:0] req_ored_vec_sft;
logic [ARBT_NUM-1:0] req_msked_ored_vec_sft;

logic                req_not_zero;
logic                req_is_one_hot;
logic                req_cflt;

logic [ARBT_NUM-1:0] indic_r;
logic [ARBT_NUM-1:0] indic_next;
logic                indic_ena;

logic [ARBT_NUM-1:0] mask_r;
logic [ARBT_NUM-1:0] mask_next;
logic                mask_ena;
logic                mask_set;
logic                mask_clr;

logic [ARBT_NUM-1:0] req_vec_real;

logic [ARBT_NUM-1:0] req_msked_vec1_real;
logic [ARBT_NUM-1:0] req_msked_vec2_real;

logic [ARBT_NUM-1:0] ored_msked_vec1;
logic [ARBT_NUM-1:0] ored_msked_vec2;

logic [ARBT_NUM-1:0] vec_1hot_1;
logic [ARBT_NUM-1:0] vec_1hot_2;

logic                grt_sel;

generate
  for (genvar i = 0; i < ARBT_NUM; i = i+1)
  begin
    assign req_ored_vec[i] = |req_vec[i:0];
  end
endgenerate
assign req_ored_vec_sft = {req_ored_vec[ARBT_NUM-2:0], 1'b0};
assign req_msked_ored_vec_sft = req_ored_vec_sft & req_vec;

assign req_not_zero     = |req_vec;
assign req_is_one_hot   = ~(|req_msked_ored_vec_sft);
assign req_cflt         = req_not_zero & !req_is_one_hot;

assign indic_ena        = req_cflt & arbt_ena;

ns_gnrl_dfflrs # (ARBT_NUM) indic_dfflrs (indic_ena, indic_next, indic_r, clk, rst_n);

assign mask_set            = !arbt_ena & (|grt_vec);
assign mask_clr            = (arbt_ena | (~(|req_vec_real))) & (|mask_r);
assign mask_ena            = mask_set | mask_clr;
assign mask_next           = ({ARBT_NUM{~mask_clr}} & ~grt_vec) |
                             ({ARBT_NUM{mask_clr}} & {ARBT_NUM{1'b0}});
ns_gnrl_dfflr  # (ARBT_NUM) mask_dfflr (mask_ena, mask_next, mask_r, clk, rst_n);


assign req_vec_real        = req_vec & ~mask_r;
assign req_msked_vec1_real = req_vec_real & indic_r;
assign req_msked_vec2_real = req_vec_real & ~indic_r;

generate
  assign ored_msked_vec1[0] = req_msked_vec1_real[0];
  assign ored_msked_vec2[0] = req_msked_vec2_real[0];
  for (genvar i = 1; i < ARBT_NUM; i = i+1)
  begin
    assign ored_msked_vec1[i] = |req_msked_vec1_real[i:0];
    assign ored_msked_vec2[i] = |req_msked_vec2_real[i:0];
  end
endgenerate

generate
  assign vec_1hot_1[0] = req_msked_vec1_real[0];
  assign vec_1hot_2[0] = req_msked_vec2_real[0];
  for (genvar i = 1; i < ARBT_NUM; i = i+1)
  begin
    assign vec_1hot_1[i] = ored_msked_vec1[i] & ~ored_msked_vec1[i-1];
    assign vec_1hot_2[i] = ored_msked_vec2[i] & ~ored_msked_vec2[i-1];
  end
endgenerate

assign grt_sel = |(indic_r & req_vec_real);
assign grt_vec = grt_sel ? vec_1hot_1 : vec_1hot_2; 
assign indic_next = grt_sel ? {ored_msked_vec1[ARBT_NUM-2:0], 1'b0} : {ored_msked_vec2[ARBT_NUM-2:0], 1'b0};


endmodule

module ns_gnrl_fixed # (
    parameter ARBT_NUM = 4
)(
    output             [ARBT_NUM-1: 0]  grt_vec                    ,
    input              [ARBT_NUM-1: 0]  req_vec                    
);
assign grt_vec[0] = req_vec[0];
generate
for (genvar i=1;i<ARBT_NUM;i=i+1)
	assign grt_vec[i] = (~|req_vec[i-1:0]) & req_vec[i];
endgenerate

endmodule

module ns_gnrl_weight_with_ref # (
  parameter ARBT_NUM = 4
)
(
  input                               clk                        ,
  input                               rst_n                      ,

  output     [$clog2(ARBT_NUM)-1: 0]  grt_id                     ,
  input              [ARBT_NUM-1: 0]  req_vec                    ,

  input      [$clog2(ARBT_NUM)-1: 0]  ref_weight        
);

logic [        ARBT_NUM-1:0] req_vec_circular_sft;
logic [$clog2(ARBT_NUM)-1:0] grt_id_sft; 

assign req_vec_circular_sft = (req_vec >> ref_weight) | (req_vec << ($bits(ref_weight)'(ARBT_NUM) - ref_weight));

priority_encoder # (ARBT_NUM) req_vec_priority_encoder (req_vec_circular_sft, grt_id_sft);

assign grt_id = grt_id_sft + ref_weight;

endmodule

module ns_gnrl_weight_with_ref_pipe # (
  parameter ARBT_NUM = 4
)
(
  input                               clk                        ,
  input                               rst_n                      ,

  output     [$clog2(ARBT_NUM)-1: 0]  grt_id                     ,
  input              [ARBT_NUM-1: 0]  req_vec                    ,

  input      [$clog2(ARBT_NUM)-1: 0]  ref_weight        
);

logic [        ARBT_NUM-1:0] req_vec_circular_sft;
logic [$clog2(ARBT_NUM)-1:0] grt_id_sft; 
logic [$clog2(ARBT_NUM)-1:0] grt_id_nxt;

assign req_vec_circular_sft = (req_vec >> ref_weight) | (req_vec << ($bits(ref_weight)'(ARBT_NUM) - ref_weight));

priority_encoder # (ARBT_NUM) req_vec_priority_encoder (req_vec_circular_sft, grt_id_sft);

assign grt_id_nxt = grt_id_sft + ref_weight;

ns_gnrl_dfflr # ($clog2(ARBT_NUM)) grt_id_dfflr (1'b1, grt_id_nxt, grt_id, clk, rst_n);

endmodule

module ns_gnrl_weight_with_ref_one_hot # (
  parameter ARBT_NUM = 4
)
(
  input                               clk                        ,
  input                               rst_n                      ,

  output     [ ARBT_NUM-1: 0]         grt_vec                    ,
  input      [ ARBT_NUM-1: 0]         req_vec                    ,

  input      [$clog2(ARBT_NUM)-1: 0]  ref_weight        
);

logic [        ARBT_NUM-1:0] req_vec_circular_sft;
logic [        ARBT_NUM-1:0] grt_vec_circular_sft; 

assign req_vec_circular_sft = (req_vec >> ref_weight) | (req_vec << ($bits(ref_weight)'(ARBT_NUM) - ref_weight));

ns_gnrl_fixed # (ARBT_NUM) req_vec_priority_arbiter(grt_vec_circular_sft, req_vec_circular_sft);

assign grt_vec = (grt_vec_circular_sft << ref_weight) | (grt_vec_circular_sft >> ($bits(ref_weight)'(ARBT_NUM) - ref_weight));

endmodule

module ns_gnrl_priority_weight_3_channel (
  input                               clk                        ,
  input                               rst_n                      ,

  output   [  2: 0]                   grt_vec                    ,
  input    [  2: 0]                   req_vec                    ,

  input    [  5: 0]                   weight          [  2: 0]   

);

wire  weight_0_greater_than_weight_1;
wire  weight_0_greater_than_weight_2;
wire  weight_1_greater_than_weight_2;

assign weight_0_greater_than_weight_1 =  ((weight[0][5] ^ weight[1][5]) & (weight[0] >= weight[1]) |
                                         ~(weight[0][5] ^ weight[1][5]) & (weight[0] <= weight[1]) |
                                          ~req_vec[1]) & req_vec[0];

assign weight_0_greater_than_weight_2 =  ((weight[0][5] ^ weight[2][5]) & (weight[0] >= weight[2]) |
                                         ~(weight[0][5] ^ weight[2][5]) & (weight[0] <= weight[2]) |
                                          ~req_vec[2]) & req_vec[0];

assign weight_1_greater_than_weight_2 =  ((weight[1][5] ^ weight[2][5]) & (weight[1] >= weight[2]) |
                                         ~(weight[1][5] ^ weight[2][5]) & (weight[1] <= weight[2]) |
                                          ~req_vec[2]) & req_vec[1];                                         

assign grt_vec[0] = req_vec[0] &  weight_0_greater_than_weight_1 &  weight_0_greater_than_weight_2;
assign grt_vec[1] = req_vec[1] & ~weight_0_greater_than_weight_1 &  weight_1_greater_than_weight_2;
assign grt_vec[2] = req_vec[2] & ~weight_0_greater_than_weight_2 & ~weight_1_greater_than_weight_2;
 
endmodule