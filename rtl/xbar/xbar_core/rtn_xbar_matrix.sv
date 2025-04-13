module rtn_xbar_matrix
    import mpc_types::*;
(
    input  logic                        clk                                 ,
    input  logic                        rst_n                               ,

    input  logic                        d_bank_0_rsp_valid                  ,
    input  logic                        d_bank_0_rsp_ready                  ,
    input  logic            [  1: 0]    d_bank_0_rsp_channel_id             ,
    
    input  logic                        d_bank_1_rsp_valid                  ,
    input  logic                        d_bank_1_rsp_ready                  ,
    input  logic            [  1: 0]    d_bank_1_rsp_channel_id             ,

    input  logic                        d_bank_2_rsp_valid                  ,
    input  logic                        d_bank_2_rsp_ready                  ,
    input  logic            [  1: 0]    d_bank_2_rsp_channel_id             ,

    input  logic                        d_bank_3_rsp_valid                  ,
    input  logic                        d_bank_3_rsp_ready                  ,
    input  logic            [  1: 0]    d_bank_3_rsp_channel_id             ,

    input  logic            [  2: 0]    bank_0_w_ptr                        ,
    input  logic            [  2: 0]    bank_0_r_ptr                        ,

    input  logic            [  2: 0]    bank_1_w_ptr                        ,
    input  logic            [  2: 0]    bank_1_r_ptr                        ,

    input  logic            [  2: 0]    bank_2_w_ptr                        ,
    input  logic            [  2: 0]    bank_2_r_ptr                        ,

    input  logic            [  2: 0]    bank_3_w_ptr                        ,
    input  logic            [  2: 0]    bank_3_r_ptr                        ,

    output logic            [  7: 0]    bank_0_ch_0_r_entry_1hot_id         ,
    output logic            [  7: 0]    bank_0_ch_1_r_entry_1hot_id         ,
    output logic            [  7: 0]    bank_0_ch_2_r_entry_1hot_id         ,

    output logic            [  7: 0]    bank_1_ch_0_r_entry_1hot_id         ,
    output logic            [  7: 0]    bank_1_ch_1_r_entry_1hot_id         ,
    output logic            [  7: 0]    bank_1_ch_2_r_entry_1hot_id         ,

    output logic            [  7: 0]    bank_2_ch_0_r_entry_1hot_id         ,
    output logic            [  7: 0]    bank_2_ch_1_r_entry_1hot_id         ,
    output logic            [  7: 0]    bank_2_ch_2_r_entry_1hot_id         ,

    output logic            [  7: 0]    bank_3_ch_0_r_entry_1hot_id         ,
    output logic            [  7: 0]    bank_3_ch_1_r_entry_1hot_id         ,
    output logic            [  7: 0]    bank_3_ch_2_r_entry_1hot_id         ,

    output logic            [  3: 0]    ch_0_bank_1hot_id                   ,
    output logic            [  3: 0]    ch_1_bank_1hot_id                   ,
    output logic            [  3: 0]    ch_2_bank_1hot_id                   ,

    output logic                        bank_0_ch_0_last_entry_already_pop  ,
    output logic                        bank_0_ch_1_last_entry_already_pop  ,
    output logic                        bank_0_ch_2_last_entry_already_pop  ,

    output logic                        bank_1_ch_0_last_entry_already_pop  ,
    output logic                        bank_1_ch_1_last_entry_already_pop  ,
    output logic                        bank_1_ch_2_last_entry_already_pop  ,

    output logic                        bank_2_ch_0_last_entry_already_pop  ,
    output logic                        bank_2_ch_1_last_entry_already_pop  ,
    output logic                        bank_2_ch_2_last_entry_already_pop  ,

    output logic                        bank_3_ch_0_last_entry_already_pop  ,
    output logic                        bank_3_ch_1_last_entry_already_pop  ,
    output logic                        bank_3_ch_2_last_entry_already_pop  ,

    output logic                        u_channel_0_rsp_valid               ,
    input  logic                        u_channel_0_rsp_ready               ,

    output logic                        u_channel_1_rsp_valid               ,
    input  logic                        u_channel_1_rsp_ready               ,

    output logic                        u_channel_2_rsp_valid               ,
    input  logic                        u_channel_2_rsp_ready                               

);

logic            u_ch_0_rsp_hsked, u_ch_1_rsp_hsked, u_ch_2_rsp_hsked;
logic            d_bank_0_rsp_hsked, d_bank_1_rsp_hsked, d_bank_2_rsp_hsked, d_bank_3_rsp_hsked;

logic   [  1: 0] bank_0_rsp_ch_id                                ;
logic   [  1: 0] bank_1_rsp_ch_id                                ;
logic   [  1: 0] bank_2_rsp_ch_id                                ;
logic   [  1: 0] bank_3_rsp_ch_id                                ;

logic   [  7: 0] xbar_valid_matrix               [  3: 0][  2: 0]; // entry, bank, channel
logic   [  7: 0] xbar_valid_matrix_nxt           [  3: 0][  2: 0];
logic   [  7: 0] xbar_valid_matrix_ival          [  3: 0][  2: 0];

logic   [  7: 0] xbar_r_entry_id_1hot            [  3: 0][  2: 0];

logic   [  2: 0] xbar_bank_ch_valid_matrix       [  3: 0]        ;
logic   [  3: 0] xbar_bank_ch_valid_matrix_t     [  2: 0]        ;

logic   [  2: 0] xbar_bank_ch_hsked_matrix       [  3: 0]        ;
logic   [  2: 0] xbar_ch_ready                                   ;



assign u_ch_0_rsp_hsked = u_channel_0_rsp_valid & u_channel_0_rsp_ready;
assign u_ch_1_rsp_hsked = u_channel_1_rsp_valid & u_channel_1_rsp_ready;
assign u_ch_2_rsp_hsked = u_channel_2_rsp_valid & u_channel_2_rsp_ready;

assign d_bank_0_rsp_hsked = d_bank_0_rsp_valid & d_bank_0_rsp_ready;
assign d_bank_1_rsp_hsked = d_bank_1_rsp_valid & d_bank_1_rsp_ready;
assign d_bank_2_rsp_hsked = d_bank_2_rsp_valid & d_bank_2_rsp_ready;
assign d_bank_3_rsp_hsked = d_bank_3_rsp_valid & d_bank_3_rsp_ready;

assign xbar_ch_ready = {u_channel_2_rsp_ready, u_channel_1_rsp_ready, u_channel_0_rsp_ready};


assign u_channel_0_rsp_valid = |xbar_bank_ch_valid_matrix_t[0];
assign u_channel_1_rsp_valid = |xbar_bank_ch_valid_matrix_t[1];
assign u_channel_2_rsp_valid = |xbar_bank_ch_valid_matrix_t[2];


generate
    for (genvar i = 0; i < 4; i++)
    begin
        for (genvar j = 0; j < 3; j++)
        begin
            assign xbar_bank_ch_valid_matrix[i][j]     = |xbar_valid_matrix[i][j];
        end
    end
endgenerate

generate
    for (genvar i = 0; i < 3; i++)
    begin
        for (genvar j = 0; j < 4; j++)
        begin
            assign xbar_bank_ch_valid_matrix_t[i][j]     = xbar_bank_ch_valid_matrix[j][i];
        end
    end
endgenerate

generate
    for (genvar i = 0; i < 4; i++)
    begin
        assign xbar_bank_ch_hsked_matrix[i][0] = xbar_bank_ch_valid_matrix[i][0] & xbar_ch_ready[0] & ch_0_bank_1hot_id[i];
        assign xbar_bank_ch_hsked_matrix[i][1] = xbar_bank_ch_valid_matrix[i][1] & xbar_ch_ready[1] & ch_1_bank_1hot_id[i];
        assign xbar_bank_ch_hsked_matrix[i][2] = xbar_bank_ch_valid_matrix[i][2] & xbar_ch_ready[2] & ch_2_bank_1hot_id[i];
    end
endgenerate

//******************//
//                  //
//  channel split   //
//                  //
//******************//

assign bank_0_rsp_ch_id = d_bank_0_rsp_channel_id;
assign bank_1_rsp_ch_id = d_bank_1_rsp_channel_id;
assign bank_2_rsp_ch_id = d_bank_2_rsp_channel_id;
assign bank_3_rsp_ch_id = d_bank_3_rsp_channel_id;

//******************//
//                  //
//   update matrix  //
//                  //
//******************//

generate
    for (genvar i = 0; i < 3; i++)
    begin : next_valid_matrix_channel_gen
        for (genvar j = 0; j < 8; j++)
        begin : next_valid_matrix_entry_gen
            assign xbar_valid_matrix_nxt[0][i][j] =   ((bank_0_rsp_ch_id == i) & (bank_0_w_ptr == j) & d_bank_0_rsp_hsked) 
                                                    | (xbar_valid_matrix[0][i][j] & !xbar_valid_matrix_ival[0][i][j]);
            assign xbar_valid_matrix_nxt[1][i][j] =   ((bank_1_rsp_ch_id == i) & (bank_1_w_ptr == j) & d_bank_1_rsp_hsked) 
                                                    | (xbar_valid_matrix[1][i][j] & !xbar_valid_matrix_ival[1][i][j]);
            assign xbar_valid_matrix_nxt[2][i][j] =   ((bank_2_rsp_ch_id == i) & (bank_2_w_ptr == j) & d_bank_2_rsp_hsked) 
                                                    | (xbar_valid_matrix[2][i][j] & !xbar_valid_matrix_ival[2][i][j]);
            assign xbar_valid_matrix_nxt[3][i][j] =   ((bank_3_rsp_ch_id == i) & (bank_3_w_ptr == j) & d_bank_3_rsp_hsked) 
                                                    | (xbar_valid_matrix[3][i][j] & !xbar_valid_matrix_ival[3][i][j]);
        end
    end
endgenerate

generate
    for (genvar i = 0; i < 3; i++)
    begin : valid_matrix_channel_gen
        for (genvar j = 0; j < 8; j++)
        begin : valid_matrix_entry_gen
            ns_gnrl_dfflr # (1) bank_0_valid_matrix_entry_dfflr (1'b1, xbar_valid_matrix_nxt[0][i][j], xbar_valid_matrix[0][i][j], clk, rst_n);
            ns_gnrl_dfflr # (1) bank_1_valid_matrix_entry_dfflr (1'b1, xbar_valid_matrix_nxt[1][i][j], xbar_valid_matrix[1][i][j], clk, rst_n);
            ns_gnrl_dfflr # (1) bank_2_valid_matrix_entry_dfflr (1'b1, xbar_valid_matrix_nxt[2][i][j], xbar_valid_matrix[2][i][j], clk, rst_n);
            ns_gnrl_dfflr # (1) bank_3_valid_matrix_entry_dfflr (1'b1, xbar_valid_matrix_nxt[3][i][j], xbar_valid_matrix[3][i][j], clk, rst_n);
            
        end
    end
endgenerate

//******************//
//                  //
//   entry arbiter  //
//                  //
//******************//

ns_gnrl_rrobin_mask # (8) bank_0_ch_0_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[0][0]), .req_vec(xbar_valid_matrix[0][0]), .req_mask_idx(bank_0_r_ptr), .arbt_ena(xbar_bank_ch_hsked_matrix[0][0]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) bank_0_ch_1_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[0][1]), .req_vec(xbar_valid_matrix[0][1]), .req_mask_idx(bank_0_r_ptr), .arbt_ena(xbar_bank_ch_hsked_matrix[0][1]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) bank_0_ch_2_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[0][2]), .req_vec(xbar_valid_matrix[0][2]), .req_mask_idx(bank_0_r_ptr), .arbt_ena(xbar_bank_ch_hsked_matrix[0][2]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) bank_1_ch_0_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[1][0]), .req_vec(xbar_valid_matrix[1][0]), .req_mask_idx(bank_1_r_ptr), .arbt_ena(xbar_bank_ch_hsked_matrix[1][0]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) bank_1_ch_1_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[1][1]), .req_vec(xbar_valid_matrix[1][1]), .req_mask_idx(bank_1_r_ptr), .arbt_ena(xbar_bank_ch_hsked_matrix[1][1]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) bank_1_ch_2_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[1][2]), .req_vec(xbar_valid_matrix[1][2]), .req_mask_idx(bank_1_r_ptr), .arbt_ena(xbar_bank_ch_hsked_matrix[1][2]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) bank_2_ch_0_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[2][0]), .req_vec(xbar_valid_matrix[2][0]), .req_mask_idx(bank_2_r_ptr), .arbt_ena(xbar_bank_ch_hsked_matrix[2][0]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) bank_2_ch_1_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[2][1]), .req_vec(xbar_valid_matrix[2][1]), .req_mask_idx(bank_2_r_ptr), .arbt_ena(xbar_bank_ch_hsked_matrix[2][1]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) bank_2_ch_2_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[2][2]), .req_vec(xbar_valid_matrix[2][2]), .req_mask_idx(bank_2_r_ptr), .arbt_ena(xbar_bank_ch_hsked_matrix[2][2]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) bank_3_ch_0_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[3][0]), .req_vec(xbar_valid_matrix[3][0]), .req_mask_idx(bank_3_r_ptr), .arbt_ena(xbar_bank_ch_hsked_matrix[3][0]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) bank_3_ch_1_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[3][1]), .req_vec(xbar_valid_matrix[3][1]), .req_mask_idx(bank_3_r_ptr), .arbt_ena(xbar_bank_ch_hsked_matrix[3][1]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) bank_3_ch_2_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[3][2]), .req_vec(xbar_valid_matrix[3][2]), .req_mask_idx(bank_3_r_ptr), .arbt_ena(xbar_bank_ch_hsked_matrix[3][2]), .clk(clk), .rst_n(rst_n));


assign bank_0_ch_0_r_entry_1hot_id = xbar_r_entry_id_1hot[0][0];
assign bank_0_ch_1_r_entry_1hot_id = xbar_r_entry_id_1hot[0][1];
assign bank_0_ch_2_r_entry_1hot_id = xbar_r_entry_id_1hot[0][2];
assign bank_1_ch_0_r_entry_1hot_id = xbar_r_entry_id_1hot[1][0];
assign bank_1_ch_1_r_entry_1hot_id = xbar_r_entry_id_1hot[1][1];
assign bank_1_ch_2_r_entry_1hot_id = xbar_r_entry_id_1hot[1][2];
assign bank_2_ch_0_r_entry_1hot_id = xbar_r_entry_id_1hot[2][0];
assign bank_2_ch_1_r_entry_1hot_id = xbar_r_entry_id_1hot[2][1];
assign bank_2_ch_2_r_entry_1hot_id = xbar_r_entry_id_1hot[2][2];
assign bank_3_ch_0_r_entry_1hot_id = xbar_r_entry_id_1hot[3][0];
assign bank_3_ch_1_r_entry_1hot_id = xbar_r_entry_id_1hot[3][1];
assign bank_3_ch_2_r_entry_1hot_id = xbar_r_entry_id_1hot[3][2];

//******************//
//                  //
// channel arbiter  //
//                  //
//******************//

ns_gnrl_rrobin      # (4) ch_0_sel_bank_gnrl_rrobin       (.grt_vec(ch_0_bank_1hot_id), .req_vec(xbar_bank_ch_valid_matrix_t[0]), .arbt_ena(u_ch_0_rsp_hsked), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin      # (4) ch_1_sel_bank_gnrl_rrobin       (.grt_vec(ch_1_bank_1hot_id), .req_vec(xbar_bank_ch_valid_matrix_t[1]), .arbt_ena(u_ch_1_rsp_hsked), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin      # (4) ch_2_sel_bank_gnrl_rrobin       (.grt_vec(ch_2_bank_1hot_id), .req_vec(xbar_bank_ch_valid_matrix_t[2]), .arbt_ena(u_ch_2_rsp_hsked), .clk(clk), .rst_n(rst_n));


//********************//
//                    //
// matrix invalidate  //
//                    //
//********************//

generate 
    for (genvar i = 0; i < 4; i++)
    begin
        for (genvar j = 0; j < 8; j++)
        begin
            assign xbar_valid_matrix_ival[i][0][j] = xbar_r_entry_id_1hot[i][0][j] & ch_0_bank_1hot_id[i] & u_ch_0_rsp_hsked;
            assign xbar_valid_matrix_ival[i][1][j] = xbar_r_entry_id_1hot[i][1][j] & ch_1_bank_1hot_id[i] & u_ch_1_rsp_hsked;
            assign xbar_valid_matrix_ival[i][2][j] = xbar_r_entry_id_1hot[i][2][j] & ch_2_bank_1hot_id[i] & u_ch_2_rsp_hsked;
        end
    end
endgenerate

//*************************//
//                         //
// last entry already pop  //
//                         //
//*************************//

assign bank_0_ch_0_last_entry_already_pop = ~xbar_valid_matrix[0][0][bank_0_r_ptr];
assign bank_0_ch_1_last_entry_already_pop = ~xbar_valid_matrix[0][1][bank_0_r_ptr];
assign bank_0_ch_2_last_entry_already_pop = ~xbar_valid_matrix[0][2][bank_0_r_ptr];

assign bank_1_ch_0_last_entry_already_pop = ~xbar_valid_matrix[1][0][bank_1_r_ptr];
assign bank_1_ch_1_last_entry_already_pop = ~xbar_valid_matrix[1][1][bank_1_r_ptr];
assign bank_1_ch_2_last_entry_already_pop = ~xbar_valid_matrix[1][2][bank_1_r_ptr];

assign bank_2_ch_0_last_entry_already_pop = ~xbar_valid_matrix[2][0][bank_2_r_ptr];
assign bank_2_ch_1_last_entry_already_pop = ~xbar_valid_matrix[2][1][bank_2_r_ptr];
assign bank_2_ch_2_last_entry_already_pop = ~xbar_valid_matrix[2][2][bank_2_r_ptr];

assign bank_3_ch_0_last_entry_already_pop = ~xbar_valid_matrix[3][0][bank_3_r_ptr];
assign bank_3_ch_1_last_entry_already_pop = ~xbar_valid_matrix[3][1][bank_3_r_ptr];
assign bank_3_ch_2_last_entry_already_pop = ~xbar_valid_matrix[3][2][bank_3_r_ptr]; 

endmodule