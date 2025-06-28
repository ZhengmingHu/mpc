module xbar_matrix
    import mpc_types::*;
# (
    parameter mpc_cfg_t Cfg = '0,   
    parameter type setWidth_t      = logic,
    parameter type tagWidth_t      = logic,
    parameter type wayIndexWidth_t = logic,
    parameter type wbufWidth_t     = logic,
    parameter type wayNum_t        = logic,
    parameter type nlineWidth_t    = logic,
    parameter type offsetWidth_t   = logic,
    parameter type metaWidth_t     = logic,
    parameter type channel_req_t   = logic
)
(
    input  logic                        clk                                 ,
    input  logic                        rst_n                               ,

    input  logic                        u_channel_0_req_valid               ,
    input  logic                        u_channel_0_req_ready               ,
    input  channel_req_t                u_channel_0_req                     ,

    input  logic                        u_channel_1_req_valid               ,
    input  logic                        u_channel_1_req_ready               ,
    input  channel_req_t                u_channel_1_req                     ,

    input  logic                        u_channel_2_req_valid               ,
    input  logic                        u_channel_2_req_ready               ,
    input  channel_req_t                u_channel_2_req                     ,

    input  logic            [  2: 0]    ch_0_w_ptr                          ,
    input  logic            [  2: 0]    ch_0_r_ptr                          ,

    input  logic            [  2: 0]    ch_1_w_ptr                          ,
    input  logic            [  2: 0]    ch_1_r_ptr                          ,
    
    input  logic            [  2: 0]    ch_2_w_ptr                          ,
    input  logic            [  2: 0]    ch_2_r_ptr                          ,

    output logic            [  7: 0]    ch_0_bank_0_r_entry_1hot_id         ,
    output logic            [  7: 0]    ch_0_bank_1_r_entry_1hot_id         ,
    output logic            [  7: 0]    ch_0_bank_2_r_entry_1hot_id         ,
    output logic            [  7: 0]    ch_0_bank_3_r_entry_1hot_id         ,

    output logic            [  7: 0]    ch_1_bank_0_r_entry_1hot_id         ,
    output logic            [  7: 0]    ch_1_bank_1_r_entry_1hot_id         ,
    output logic            [  7: 0]    ch_1_bank_2_r_entry_1hot_id         ,
    output logic            [  7: 0]    ch_1_bank_3_r_entry_1hot_id         ,

    output logic            [  7: 0]    ch_2_bank_0_r_entry_1hot_id         ,
    output logic            [  7: 0]    ch_2_bank_1_r_entry_1hot_id         ,
    output logic            [  7: 0]    ch_2_bank_2_r_entry_1hot_id         ,
    output logic            [  7: 0]    ch_2_bank_3_r_entry_1hot_id         ,

    output logic            [  2: 0]    bank_0_ch_1hot_id                   ,
    output logic            [  2: 0]    bank_1_ch_1hot_id                   ,
    output logic            [  2: 0]    bank_2_ch_1hot_id                   ,
    output logic            [  2: 0]    bank_3_ch_1hot_id                   ,

    output logic                        ch_0_bank_0_last_entry_already_pop  ,
    output logic                        ch_0_bank_1_last_entry_already_pop  ,
    output logic                        ch_0_bank_2_last_entry_already_pop  ,
    output logic                        ch_0_bank_3_last_entry_already_pop  ,

    output logic                        ch_1_bank_0_last_entry_already_pop  ,
    output logic                        ch_1_bank_1_last_entry_already_pop  ,
    output logic                        ch_1_bank_2_last_entry_already_pop  ,
    output logic                        ch_1_bank_3_last_entry_already_pop  ,

    output logic                        ch_2_bank_0_last_entry_already_pop  ,
    output logic                        ch_2_bank_1_last_entry_already_pop  ,
    output logic                        ch_2_bank_2_last_entry_already_pop  ,
    output logic                        ch_2_bank_3_last_entry_already_pop  ,

    output logic                        d_bank_0_req_valid                  ,
    input  logic                        d_bank_0_req_ready                  ,
    
    output logic                        d_bank_1_req_valid                  ,
    input  logic                        d_bank_1_req_ready                  ,

    output logic                        d_bank_2_req_valid                  ,
    input  logic                        d_bank_2_req_ready                  ,

    output logic                        d_bank_3_req_valid                  ,
    input  logic                        d_bank_3_req_ready                  

);

logic            u_ch_0_req_hsked, u_ch_1_req_hsked, u_ch_2_req_hsked;
logic            d_bank_0_req_hsked, d_bank_1_req_hsked, d_bank_2_req_hsked, d_bank_3_req_hsked;

logic   [  1: 0] ch_0_req_bank_id                                ;
logic   [  1: 0] ch_1_req_bank_id                                ;
logic   [  1: 0] ch_2_req_bank_id                                ;

logic   [  7: 0] xbar_valid_matrix               [  2: 0][  3: 0]; // entry, channel, bank
logic   [  7: 0] xbar_valid_matrix_nxt           [  2: 0][  3: 0];
logic   [  7: 0] xbar_valid_matrix_ival          [  2: 0][  3: 0];

logic   [  7: 0] xbar_r_entry_id_1hot            [  2: 0][  3: 0];

logic   [  3: 0] xbar_ch_bank_valid_matrix       [  2: 0]        ;
logic   [  2: 0] xbar_ch_bank_valid_matrix_t     [  3: 0]        ;

logic   [  3: 0] xbar_ch_bank_hsked_matrix       [  2: 0]        ;
logic   [  3: 0] xbar_bank_ready                                 ;



assign u_ch_0_req_hsked = u_channel_0_req_valid & u_channel_0_req_ready;
assign u_ch_1_req_hsked = u_channel_1_req_valid & u_channel_1_req_ready;
assign u_ch_2_req_hsked = u_channel_2_req_valid & u_channel_2_req_ready;

assign d_bank_0_req_hsked = d_bank_0_req_valid & d_bank_0_req_ready;
assign d_bank_1_req_hsked = d_bank_1_req_valid & d_bank_1_req_ready;
assign d_bank_2_req_hsked = d_bank_2_req_valid & d_bank_2_req_ready;
assign d_bank_3_req_hsked = d_bank_3_req_valid & d_bank_3_req_ready;

assign xbar_bank_ready = {d_bank_3_req_ready, d_bank_2_req_ready, d_bank_1_req_ready, d_bank_0_req_ready};

assign d_bank_0_req_valid = |xbar_ch_bank_valid_matrix_t[0];
assign d_bank_1_req_valid = |xbar_ch_bank_valid_matrix_t[1];
assign d_bank_2_req_valid = |xbar_ch_bank_valid_matrix_t[2];
assign d_bank_3_req_valid = |xbar_ch_bank_valid_matrix_t[3];


generate
    for (genvar i = 0; i < 3; i++)
    begin
        for (genvar j = 0; j < 4; j++)
        begin
            assign xbar_ch_bank_valid_matrix[i][j]     = |xbar_valid_matrix[i][j];
        end
    end
endgenerate

generate
    for (genvar i = 0; i < 4; i++)
    begin
        for (genvar j = 0; j < 3; j++)
        begin
            assign xbar_ch_bank_valid_matrix_t[i][j]     = xbar_ch_bank_valid_matrix[j][i];
        end
    end
endgenerate

generate
    for (genvar i = 0; i < 3; i++)
    begin
        assign xbar_ch_bank_hsked_matrix[i][0] = xbar_ch_bank_valid_matrix[i][0] & xbar_bank_ready[0] & bank_0_ch_1hot_id[i];
        assign xbar_ch_bank_hsked_matrix[i][1] = xbar_ch_bank_valid_matrix[i][1] & xbar_bank_ready[1] & bank_1_ch_1hot_id[i];
        assign xbar_ch_bank_hsked_matrix[i][2] = xbar_ch_bank_valid_matrix[i][2] & xbar_bank_ready[2] & bank_2_ch_1hot_id[i];
        assign xbar_ch_bank_hsked_matrix[i][3] = xbar_ch_bank_valid_matrix[i][3] & xbar_bank_ready[3] & bank_3_ch_1hot_id[i];
    end
endgenerate

//******************//
//                  //
//    bank split    //
//                  //
//******************//

assign ch_0_req_bank_id = u_channel_0_req.addr[9:8];
assign ch_1_req_bank_id = u_channel_1_req.addr[9:8];
assign ch_2_req_bank_id = u_channel_2_req.addr[9:8];

//******************//
//                  //
//   update matrix  //
//                  //
//******************//

generate
    for (genvar i = 0; i < 4; i++)
    begin : next_valid_matrix_bank_gen
        for (genvar j = 0; j < 8; j++)
        begin : next_valid_matrix_entry_gen
            assign xbar_valid_matrix_nxt[0][i][j] =   ((ch_0_req_bank_id == i) & (ch_0_w_ptr == j) & u_ch_0_req_hsked) 
                                                    | (xbar_valid_matrix[0][i][j] & !xbar_valid_matrix_ival[0][i][j]);
            assign xbar_valid_matrix_nxt[1][i][j] =   ((ch_1_req_bank_id == i) & (ch_1_w_ptr == j) & u_ch_1_req_hsked) 
                                                    | (xbar_valid_matrix[1][i][j] & !xbar_valid_matrix_ival[1][i][j]);
            assign xbar_valid_matrix_nxt[2][i][j] =   ((ch_2_req_bank_id == i) & (ch_2_w_ptr == j) & u_ch_2_req_hsked) 
                                                    | (xbar_valid_matrix[2][i][j] & !xbar_valid_matrix_ival[2][i][j]);
        end
    end
endgenerate

generate
    for (genvar i = 0; i < 4; i++)
    begin : valid_matrix_bank_gen
        for (genvar j = 0; j < 8; j++)
        begin : valid_matrix_entry_gen
            ns_gnrl_dfflr # (1) ch_0_valid_matrix_entry_dfflr (1'b1, xbar_valid_matrix_nxt[0][i][j], xbar_valid_matrix[0][i][j], clk, rst_n);
            ns_gnrl_dfflr # (1) ch_1_valid_matrix_entry_dfflr (1'b1, xbar_valid_matrix_nxt[1][i][j], xbar_valid_matrix[1][i][j], clk, rst_n);
            ns_gnrl_dfflr # (1) ch_2_valid_matrix_entry_dfflr (1'b1, xbar_valid_matrix_nxt[2][i][j], xbar_valid_matrix[2][i][j], clk, rst_n);
        end
    end
endgenerate

//******************//
//                  //
//   entry arbiter  //
//                  //
//******************//

ns_gnrl_rrobin_mask # (8) ch_0_bank_0_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[0][0]), .req_vec(xbar_valid_matrix[0][0]), .req_mask_idx(ch_0_r_ptr), .arbt_ena(xbar_ch_bank_hsked_matrix[0][0]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) ch_0_bank_1_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[0][1]), .req_vec(xbar_valid_matrix[0][1]), .req_mask_idx(ch_0_r_ptr), .arbt_ena(xbar_ch_bank_hsked_matrix[0][1]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) ch_0_bank_2_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[0][2]), .req_vec(xbar_valid_matrix[0][2]), .req_mask_idx(ch_0_r_ptr), .arbt_ena(xbar_ch_bank_hsked_matrix[0][2]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) ch_0_bank_3_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[0][3]), .req_vec(xbar_valid_matrix[0][3]), .req_mask_idx(ch_0_r_ptr), .arbt_ena(xbar_ch_bank_hsked_matrix[0][3]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) ch_1_bank_0_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[1][0]), .req_vec(xbar_valid_matrix[1][0]), .req_mask_idx(ch_1_r_ptr), .arbt_ena(xbar_ch_bank_hsked_matrix[1][0]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) ch_1_bank_1_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[1][1]), .req_vec(xbar_valid_matrix[1][1]), .req_mask_idx(ch_1_r_ptr), .arbt_ena(xbar_ch_bank_hsked_matrix[1][1]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) ch_1_bank_2_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[1][2]), .req_vec(xbar_valid_matrix[1][2]), .req_mask_idx(ch_1_r_ptr), .arbt_ena(xbar_ch_bank_hsked_matrix[1][2]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) ch_1_bank_3_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[1][3]), .req_vec(xbar_valid_matrix[1][3]), .req_mask_idx(ch_1_r_ptr), .arbt_ena(xbar_ch_bank_hsked_matrix[1][3]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) ch_2_bank_0_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[2][0]), .req_vec(xbar_valid_matrix[2][0]), .req_mask_idx(ch_2_r_ptr), .arbt_ena(xbar_ch_bank_hsked_matrix[2][0]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) ch_2_bank_1_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[2][1]), .req_vec(xbar_valid_matrix[2][1]), .req_mask_idx(ch_2_r_ptr), .arbt_ena(xbar_ch_bank_hsked_matrix[2][1]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) ch_2_bank_2_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[2][2]), .req_vec(xbar_valid_matrix[2][2]), .req_mask_idx(ch_2_r_ptr), .arbt_ena(xbar_ch_bank_hsked_matrix[2][2]), .clk(clk), .rst_n(rst_n));
ns_gnrl_rrobin_mask # (8) ch_2_bank_3_ns_gnrl_rrobin_mask (.grt_vec(xbar_r_entry_id_1hot[2][3]), .req_vec(xbar_valid_matrix[2][3]), .req_mask_idx(ch_2_r_ptr), .arbt_ena(xbar_ch_bank_hsked_matrix[2][3]), .clk(clk), .rst_n(rst_n));


assign ch_0_bank_0_r_entry_1hot_id = xbar_r_entry_id_1hot[0][0];
assign ch_0_bank_1_r_entry_1hot_id = xbar_r_entry_id_1hot[0][1];
assign ch_0_bank_2_r_entry_1hot_id = xbar_r_entry_id_1hot[0][2];
assign ch_0_bank_3_r_entry_1hot_id = xbar_r_entry_id_1hot[0][3];
assign ch_1_bank_0_r_entry_1hot_id = xbar_r_entry_id_1hot[1][0];
assign ch_1_bank_1_r_entry_1hot_id = xbar_r_entry_id_1hot[1][1];
assign ch_1_bank_2_r_entry_1hot_id = xbar_r_entry_id_1hot[1][2];
assign ch_1_bank_3_r_entry_1hot_id = xbar_r_entry_id_1hot[1][3];
assign ch_2_bank_0_r_entry_1hot_id = xbar_r_entry_id_1hot[2][0]; 
assign ch_2_bank_1_r_entry_1hot_id = xbar_r_entry_id_1hot[2][1];
assign ch_2_bank_2_r_entry_1hot_id = xbar_r_entry_id_1hot[2][2];
assign ch_2_bank_3_r_entry_1hot_id = xbar_r_entry_id_1hot[2][3];

//******************//
//                  //
// channel arbiter  //
//                  //
//******************//

ns_gnrl_rrobin      # (3) bank_0_sel_ch_gnrl_rrobin       (.grt_vec(bank_0_ch_1hot_id), .req_vec(xbar_ch_bank_valid_matrix_t[0]), .arbt_ena(d_bank_0_req_hsked), .clk(clk), .rst_n(rst_n)); 
ns_gnrl_rrobin      # (3) bank_1_sel_ch_gnrl_rrobin       (.grt_vec(bank_1_ch_1hot_id), .req_vec(xbar_ch_bank_valid_matrix_t[1]), .arbt_ena(d_bank_1_req_hsked), .clk(clk), .rst_n(rst_n)); 
ns_gnrl_rrobin      # (3) bank_2_sel_ch_gnrl_rrobin       (.grt_vec(bank_2_ch_1hot_id), .req_vec(xbar_ch_bank_valid_matrix_t[2]), .arbt_ena(d_bank_2_req_hsked), .clk(clk), .rst_n(rst_n)); 
ns_gnrl_rrobin      # (3) bank_3_sel_ch_gnrl_rrobin       (.grt_vec(bank_3_ch_1hot_id), .req_vec(xbar_ch_bank_valid_matrix_t[3]), .arbt_ena(d_bank_3_req_hsked), .clk(clk), .rst_n(rst_n)); 


//********************//
//                    //
// matrix invalidate  //
//                    //
//********************//

generate 
    for (genvar i = 0; i < 3; i++)
    begin
        for (genvar j = 0; j < 8; j++)
        begin
            assign xbar_valid_matrix_ival[i][0][j] = xbar_r_entry_id_1hot[i][0][j] & bank_0_ch_1hot_id[i] & d_bank_0_req_hsked;
            assign xbar_valid_matrix_ival[i][1][j] = xbar_r_entry_id_1hot[i][1][j] & bank_1_ch_1hot_id[i] & d_bank_1_req_hsked;
            assign xbar_valid_matrix_ival[i][2][j] = xbar_r_entry_id_1hot[i][2][j] & bank_2_ch_1hot_id[i] & d_bank_2_req_hsked;
            assign xbar_valid_matrix_ival[i][3][j] = xbar_r_entry_id_1hot[i][3][j] & bank_3_ch_1hot_id[i] & d_bank_3_req_hsked;
        end
    end
endgenerate

//*************************//
//                         //
// last entry already pop  //
//                         //
//*************************//

assign ch_0_bank_0_last_entry_already_pop = ~xbar_valid_matrix[0][0][ch_0_r_ptr]; 
assign ch_0_bank_1_last_entry_already_pop = ~xbar_valid_matrix[0][1][ch_0_r_ptr]; 
assign ch_0_bank_2_last_entry_already_pop = ~xbar_valid_matrix[0][2][ch_0_r_ptr]; 
assign ch_0_bank_3_last_entry_already_pop = ~xbar_valid_matrix[0][3][ch_0_r_ptr];

assign ch_1_bank_0_last_entry_already_pop = ~xbar_valid_matrix[1][0][ch_1_r_ptr]; 
assign ch_1_bank_1_last_entry_already_pop = ~xbar_valid_matrix[1][1][ch_1_r_ptr]; 
assign ch_1_bank_2_last_entry_already_pop = ~xbar_valid_matrix[1][2][ch_1_r_ptr]; 
assign ch_1_bank_3_last_entry_already_pop = ~xbar_valid_matrix[1][3][ch_1_r_ptr]; 

assign ch_2_bank_0_last_entry_already_pop = ~xbar_valid_matrix[2][0][ch_2_r_ptr]; 
assign ch_2_bank_1_last_entry_already_pop = ~xbar_valid_matrix[2][1][ch_2_r_ptr]; 
assign ch_2_bank_2_last_entry_already_pop = ~xbar_valid_matrix[2][2][ch_2_r_ptr]; 
assign ch_2_bank_3_last_entry_already_pop = ~xbar_valid_matrix[2][3][ch_2_r_ptr]; 


endmodule