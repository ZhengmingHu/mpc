module xbar_ptr_gen
    import mpc_types::*;
(
    input  logic                        clk                                 ,
    input  logic                        rst_n                               ,

    input  logic                        u_channel_0_req_valid               ,
    output logic                        u_channel_0_req_ready               ,
    input  logic                        u_channel_1_req_valid               ,
    output logic                        u_channel_1_req_ready               ,
    input  logic                        u_channel_2_req_valid               ,
    output logic                        u_channel_2_req_ready               ,

    input  logic                        ch_0_bank_0_last_entry_already_pop  ,
    input  logic                        ch_0_bank_1_last_entry_already_pop  ,
    input  logic                        ch_0_bank_2_last_entry_already_pop  ,
    input  logic                        ch_0_bank_3_last_entry_already_pop  ,

    input  logic                        ch_1_bank_0_last_entry_already_pop  ,
    input  logic                        ch_1_bank_1_last_entry_already_pop  ,
    input  logic                        ch_1_bank_2_last_entry_already_pop  ,
    input  logic                        ch_1_bank_3_last_entry_already_pop  ,

    input  logic                        ch_2_bank_0_last_entry_already_pop  ,
    input  logic                        ch_2_bank_1_last_entry_already_pop  ,
    input  logic                        ch_2_bank_2_last_entry_already_pop  ,
    input  logic                        ch_2_bank_3_last_entry_already_pop  ,

    output logic    [  2: 0]            ch_0_w_ptr                          ,
    output logic    [  2: 0]            ch_0_r_ptr                          ,
    output logic    [  2: 0]            ch_1_w_ptr                          ,
    output logic    [  2: 0]            ch_1_r_ptr                          ,
    output logic    [  2: 0]            ch_2_w_ptr                          ,
    output logic    [  2: 0]            ch_2_r_ptr
);

xbar_sub_ptr_gen u_ch_0_xbar_sub_ptr_gen (
    .clk                                (clk                               ),
    .rst_n                              (rst_n                             ),

    .u_ch_req_valid                     (u_channel_0_req_valid             ),
    .u_ch_req_ready                     (u_channel_0_req_ready             ),

    .bank_0_last_entry_already_pop      (ch_0_bank_0_last_entry_already_pop),
    .bank_1_last_entry_already_pop      (ch_0_bank_1_last_entry_already_pop),
    .bank_2_last_entry_already_pop      (ch_0_bank_2_last_entry_already_pop),
    .bank_3_last_entry_already_pop      (ch_0_bank_3_last_entry_already_pop),

    .w_ptr                              (ch_0_w_ptr                        ),
    .r_ptr                              (ch_0_r_ptr                        )
);

xbar_sub_ptr_gen u_ch_1_xbar_sub_ptr_gen (
    .clk                                (clk                               ),
    .rst_n                              (rst_n                             ),

    .u_ch_req_valid                     (u_channel_1_req_valid             ),
    .u_ch_req_ready                     (u_channel_1_req_ready             ),

    .bank_0_last_entry_already_pop      (ch_1_bank_0_last_entry_already_pop),
    .bank_1_last_entry_already_pop      (ch_1_bank_1_last_entry_already_pop),
    .bank_2_last_entry_already_pop      (ch_1_bank_2_last_entry_already_pop),
    .bank_3_last_entry_already_pop      (ch_1_bank_3_last_entry_already_pop),

    .w_ptr                              (ch_1_w_ptr                        ),
    .r_ptr                              (ch_1_r_ptr                        )
);

xbar_sub_ptr_gen u_ch_2_xbar_sub_ptr_gen (
    .clk                                (clk                               ),
    .rst_n                              (rst_n                             ),

    .u_ch_req_valid                     (u_channel_2_req_valid             ),
    .u_ch_req_ready                     (u_channel_2_req_ready             ),

    .bank_0_last_entry_already_pop      (ch_2_bank_0_last_entry_already_pop),
    .bank_1_last_entry_already_pop      (ch_2_bank_1_last_entry_already_pop),
    .bank_2_last_entry_already_pop      (ch_2_bank_2_last_entry_already_pop),
    .bank_3_last_entry_already_pop      (ch_2_bank_3_last_entry_already_pop),

    .w_ptr                              (ch_2_w_ptr                        ),
    .r_ptr                              (ch_2_r_ptr                        )
);

endmodule

module xbar_sub_ptr_gen
    import mpc_types::*;
(
    input  logic                        clk                            ,
    input  logic                        rst_n                          ,

    input  logic                        u_ch_req_valid                 ,
    output logic                        u_ch_req_ready                 ,

    input  logic                        bank_0_last_entry_already_pop  ,
    input  logic                        bank_1_last_entry_already_pop  ,
    input  logic                        bank_2_last_entry_already_pop  ,
    input  logic                        bank_3_last_entry_already_pop  ,

    output logic    [  2: 0]            w_ptr                          ,
    output logic    [  2: 0]            r_ptr                          
);

logic            u_ch_req_hsked;

logic   [  2: 0] w_ptr_nxt;
logic   [  2: 0] w_ptr_r;
logic            w_ptr_clr;
logic            w_ptr_incr;
logic            w_ptr_ena;

logic   [  2: 0] r_ptr_nxt;
logic   [  2: 0] r_ptr_r;
logic            r_ptr_clr;
logic            r_ptr_incr;
logic            r_ptr_ena;

logic   [  2: 0] used_entry_nxt;
logic   [  2: 0] used_entry;
logic            used_entry_ena;

logic            last_entry_already_pop;

assign u_ch_req_hsked = u_ch_req_valid & u_ch_req_ready;
assign w_ptr_incr     = u_ch_req_hsked & ~(&w_ptr_r);
assign w_ptr_clr      = u_ch_req_hsked & (&w_ptr_r);
assign w_ptr_ena      = w_ptr_incr | w_ptr_clr;
assign w_ptr_nxt      =   ({3{w_ptr_clr}}  & 3'h0) 
                        | ({3{w_ptr_incr}} & (w_ptr_r + 'h1));
ns_gnrl_dfflr # (3) w_ptr_dfflr (w_ptr_ena, w_ptr_nxt, w_ptr_r, clk, rst_n);

assign r_ptr_incr     = (|used_entry) & last_entry_already_pop & ~(&r_ptr_r);
assign r_ptr_clr      = (|used_entry) & last_entry_already_pop & (&r_ptr_r);
assign r_ptr_ena      = r_ptr_incr | r_ptr_clr;
assign r_ptr_nxt      =   ({3{r_ptr_clr}}  & 3'h0) 
                        | ({3{r_ptr_incr}} & (r_ptr_r + 'h1));
ns_gnrl_dfflr # (3) r_ptr_dfflr (r_ptr_ena, r_ptr_nxt, r_ptr_r, clk, rst_n);

assign used_entry_ena = w_ptr_ena | r_ptr_ena;
assign used_entry_nxt =   ({3{w_ptr_ena}} & (used_entry + 'h1)) 
                        | ({3{r_ptr_ena}} & (used_entry - 'h1));
ns_gnrl_dfflr # (3) used_entry_dfflr (used_entry_ena, used_entry_nxt, used_entry, clk, rst_n);

assign last_entry_already_pop = bank_0_last_entry_already_pop &
                                bank_1_last_entry_already_pop &
                                bank_2_last_entry_already_pop &
                                bank_3_last_entry_already_pop ;
                        
assign u_ch_req_ready = ~(&used_entry);

assign w_ptr = w_ptr_r;
assign r_ptr = r_ptr_r;

endmodule