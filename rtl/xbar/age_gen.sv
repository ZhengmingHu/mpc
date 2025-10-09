module age_gen
    import mpc_types::*;
#(
    parameter mpc_cfg_t Cfg = '0
)
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        u_channel_0_req_valid      ,
    input  logic                        u_channel_0_req_ready      ,

    input  logic                        u_channel_1_req_valid      ,
    input  logic                        u_channel_1_req_ready      ,

    input  logic                        u_channel_2_req_valid      ,
    input  logic                        u_channel_2_req_ready      ,

    input  logic                        d_bank_0_retire_valid      ,
    input  logic [  5: 0]               d_bank_0_retire_age_info   ,
    input  logic [  2: 0]               d_bank_0_channel_1hot_id   ,

    input  logic                        d_bank_1_retire_valid      ,
    input  logic [  5: 0]               d_bank_1_retire_age_info   ,
    input  logic [  2: 0]               d_bank_1_channel_1hot_id   ,

    input  logic                        d_bank_2_retire_valid      ,
    input  logic [  5: 0]               d_bank_2_retire_age_info   ,
    input  logic [  2: 0]               d_bank_2_channel_1hot_id   ,

    input  logic                        d_bank_3_retire_valid      ,
    input  logic [  5: 0]               d_bank_3_retire_age_info   ,
    input  logic [  2: 0]               d_bank_3_channel_1hot_id   ,

    output logic [  5: 0]               age_info                   ,
    output logic                        age_full
);


logic          u_channel_0_req_hsked;
logic          u_channel_1_req_hsked;
logic          u_channel_2_req_hsked;

logic          age_empty;

logic [ 31: 0] age_multi_mapping_en            ;
logic [  2: 0] age_multi_mapping       [ 31: 0];
logic [  2: 0] age_multi_mapping_nxt   [ 31: 0];

logic          age_value_en;
logic [  4: 0] age_value_nxt;
logic [  4: 0] age_value;

logic          age_flag_en;
logic          age_flag_nxt;
logic          age_flag;

logic          oldest_age_value_en;
logic [  4: 0] oldest_age_value;
logic [  4: 0] oldest_age_value_nxt;

logic          oldest_age_flag_en;
logic          oldest_age_flag;
logic          oldest_age_flag_nxt;

assign u_channel_0_req_hsked = u_channel_0_req_valid & u_channel_0_req_ready;
assign u_channel_1_req_hsked = u_channel_1_req_valid & u_channel_1_req_ready;
assign u_channel_2_req_hsked = u_channel_2_req_valid & u_channel_2_req_ready;

assign age_value_en = u_channel_0_req_hsked | u_channel_1_req_hsked | u_channel_2_req_hsked;
assign age_value_nxt = age_value + 'd1;
assign age_flag_en = age_value_en & age_value == '1;
assign age_flag_nxt = ~age_flag;

assign oldest_age_value_en =  ~age_empty & ~|age_multi_mapping_nxt[oldest_age_value];
assign oldest_age_value_nxt = oldest_age_value + 'd1;
assign oldest_age_flag_en  = oldest_age_value_en & oldest_age_value == '1;
assign oldest_age_flag_nxt = ~oldest_age_flag;

genvar i;
generate
    for (i=0; i<32; i=i+1) begin: age_multi_map_gen
        assign age_multi_mapping_en[i]     = u_channel_0_req_hsked & age_value == i | 
                                             u_channel_1_req_hsked & age_value == i |
                                             u_channel_2_req_hsked & age_value == i |
                                             d_bank_0_retire_valid & d_bank_0_retire_age_info[4:0] == i|
                                             d_bank_1_retire_valid & d_bank_1_retire_age_info[4:0] == i|
                                             d_bank_2_retire_valid & d_bank_2_retire_age_info[4:0] == i|
                                             d_bank_3_retire_valid & d_bank_3_retire_age_info[4:0] == i;
        assign age_multi_mapping_nxt[i][0] = u_channel_0_req_hsked & age_value == i |
                                             ~( d_bank_0_retire_valid & d_bank_0_channel_1hot_id[0] & d_bank_0_retire_age_info[4:0]  == i|
                                                d_bank_1_retire_valid & d_bank_1_channel_1hot_id[0] & d_bank_1_retire_age_info[4:0]  == i|
                                                d_bank_2_retire_valid & d_bank_2_channel_1hot_id[0] & d_bank_2_retire_age_info[4:0]  == i|
                                                d_bank_3_retire_valid & d_bank_3_channel_1hot_id[0] & d_bank_3_retire_age_info[4:0]  == i) &
                                                age_multi_mapping[i][0];
        assign age_multi_mapping_nxt[i][1] = u_channel_1_req_hsked & age_value == i |
                                             ~( d_bank_0_retire_valid & d_bank_0_channel_1hot_id[1] & d_bank_0_retire_age_info[4:0]  == i|
                                                d_bank_1_retire_valid & d_bank_1_channel_1hot_id[1] & d_bank_1_retire_age_info[4:0]  == i|
                                                d_bank_2_retire_valid & d_bank_2_channel_1hot_id[1] & d_bank_2_retire_age_info[4:0]  == i|
                                                d_bank_3_retire_valid & d_bank_3_channel_1hot_id[1] & d_bank_3_retire_age_info[4:0]  == i) &
                                                age_multi_mapping[i][1];
        assign age_multi_mapping_nxt[i][2] = u_channel_2_req_hsked & age_value == i |
                                             ~( d_bank_0_retire_valid & d_bank_0_channel_1hot_id[2] & d_bank_0_retire_age_info[4:0]  == i|
                                                d_bank_1_retire_valid & d_bank_1_channel_1hot_id[2] & d_bank_1_retire_age_info[4:0]  == i|
                                                d_bank_2_retire_valid & d_bank_2_channel_1hot_id[2] & d_bank_2_retire_age_info[4:0]  == i|
                                                d_bank_3_retire_valid & d_bank_3_channel_1hot_id[2] & d_bank_3_retire_age_info[4:0]  == i) &
                                                age_multi_mapping[i][2];
        ns_gnrl_dfflr # (3) age_multi_mapping_dfflr (age_multi_mapping_en[i], age_multi_mapping_nxt[i], age_multi_mapping[i], clk, rst_n);
    end
endgenerate

ns_gnrl_dfflr # (5) age_value_dfflr (age_value_en, age_value_nxt, age_value, clk, rst_n);
ns_gnrl_dfflr # (1) age_flag_dfflr (age_flag_en, age_flag_nxt, age_flag, clk, rst_n);

ns_gnrl_dfflr # (5) oldest_age_value_dfflr (oldest_age_value_en, oldest_age_value_nxt, oldest_age_value, clk, rst_n);
ns_gnrl_dfflr # (1) oldest_age_flag_dfflr (oldest_age_flag_en, oldest_age_flag_nxt, oldest_age_flag, clk, rst_n);

assign age_info = {age_flag, age_value};
assign age_empty = oldest_age_value == age_value & ~(oldest_age_flag ^ age_flag);
assign age_full = oldest_age_value == age_value & (oldest_age_flag ^ age_flag);

endmodule

