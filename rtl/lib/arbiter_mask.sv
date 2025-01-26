module ns_gnrl_rrobin_mask # (
    parameter ARBT_NUM = 8
)(
    output             [        ARBT_NUM-1: 0]  grt_vec                    ,
    input              [        ARBT_NUM-1: 0]  req_vec                    ,
    input              [$clog2(ARBT_NUM)-1: 0]  req_mask_idx               ,
    input                                       arbt_ena                   ,
    input                                       clk                        ,
    input                                       rst_n                       
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
logic                indic_clr;

logic [ARBT_NUM-1:0] indic_mask;
logic [ARBT_NUM-1:0] hist_indic_mask;
logic                indic_mask_diff;

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

assign indic_mask_diff = ~(indic_mask == hist_indic_mask);
ns_gnrl_dfflr # (ARBT_NUM) hist_inic_mask_dfflr (1'b1, indic_mask, hist_indic_mask, clk, rst_n);

generate
    for (genvar i = 0; i < ARBT_NUM; i = i+1)
    begin
      assign req_ored_vec[i] = |req_vec[i:0];
    end
endgenerate

generate
    for (genvar i = 0; i < ARBT_NUM; i = i+1)
    begin
        assign indic_mask[i] = i < req_mask_idx;
    end
endgenerate

assign req_ored_vec_sft = {req_ored_vec[ARBT_NUM-2:0], 1'b0};
assign req_msked_ored_vec_sft = req_ored_vec_sft & req_vec;

assign req_not_zero     = |req_vec;
assign req_is_one_hot   = ~(|req_msked_ored_vec_sft);
assign req_cflt         = req_not_zero & !req_is_one_hot;

assign indic_clr        = indic_mask_diff;
assign indic_ena        = (req_cflt & arbt_ena) | indic_clr;

ns_gnrl_dfflrs # (ARBT_NUM) indic_dfflrs (indic_ena, indic_next, indic_r, clk, rst_n);

assign mask_set            = !arbt_ena & (|grt_vec);
assign mask_clr            = (arbt_ena | (~(|req_vec_real))) & (|mask_r);
assign mask_ena            = mask_set | mask_clr;
assign mask_next           = ({ARBT_NUM{~mask_clr}} & ~grt_vec) |
                             ({ARBT_NUM{mask_clr}} & {ARBT_NUM{1'b0}});
ns_gnrl_dfflr  # (ARBT_NUM) mask_dfflr (mask_ena, mask_next, mask_r, clk, rst_n);


assign req_vec_real        = req_vec & ~mask_r;
assign req_msked_vec1_real = indic_clr ? req_vec_real & ~indic_mask : req_vec_real & indic_r & ~indic_mask;
assign req_msked_vec2_real = indic_clr ? req_vec_real &  indic_mask : req_vec_real & ~indic_r & indic_mask;

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

assign grt_sel = |(req_msked_vec1_real);
assign grt_vec = grt_sel ? vec_1hot_1 : vec_1hot_2; 
assign indic_next = arbt_ena  ? (grt_sel  ? {ored_msked_vec1[ARBT_NUM-2:0], 1'b0} : {ored_msked_vec2[ARBT_NUM-2:0], 1'b0}) :
                    (indic_clr ? {ARBT_NUM{1'b1}} : indic_r);


endmodule

