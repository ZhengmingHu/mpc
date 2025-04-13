module rtn_xbar_ptr_gen
    import mpc_types::*;
(
    input  logic                        clk                                 ,
    input  logic                        rst_n                               ,

    input  logic                        d_bank_0_rsp_valid                  ,
    output logic                        d_bank_0_rsp_ready                  ,
    input  logic                        d_bank_1_rsp_valid                  ,
    output logic                        d_bank_1_rsp_ready                  ,
    input  logic                        d_bank_2_rsp_valid                  ,
    output logic                        d_bank_2_rsp_ready                  ,
    input  logic                        d_bank_3_rsp_valid                  ,
    output logic                        d_bank_3_rsp_ready                  ,

    input  logic                        bank_0_ch_0_last_entry_already_pop  ,
    input  logic                        bank_0_ch_1_last_entry_already_pop  ,
    input  logic                        bank_0_ch_2_last_entry_already_pop  ,

    input  logic                        bank_1_ch_0_last_entry_already_pop  ,
    input  logic                        bank_1_ch_1_last_entry_already_pop  ,
    input  logic                        bank_1_ch_2_last_entry_already_pop  ,

    input  logic                        bank_2_ch_0_last_entry_already_pop  ,
    input  logic                        bank_2_ch_1_last_entry_already_pop  ,
    input  logic                        bank_2_ch_2_last_entry_already_pop  ,

    input  logic                        bank_3_ch_0_last_entry_already_pop  ,
    input  logic                        bank_3_ch_1_last_entry_already_pop  ,
    input  logic                        bank_3_ch_2_last_entry_already_pop  ,

    output logic    [  2: 0]            bank_0_w_ptr                        ,
    output logic    [  2: 0]            bank_0_r_ptr                        ,
    output logic    [  2: 0]            bank_1_w_ptr                        ,
    output logic    [  2: 0]            bank_1_r_ptr                        ,
    output logic    [  2: 0]            bank_2_w_ptr                        ,
    output logic    [  2: 0]            bank_2_r_ptr                        ,
    output logic    [  2: 0]            bank_3_w_ptr                        ,                        
    output logic    [  2: 0]            bank_3_r_ptr
);

rtn_xbar_sub_ptr_gen u_bank_0_xbar_sub_ptr_gen(
    .clk                                (clk                               ),
    .rst_n                              (rst_n                             ),

    .d_bank_rsp_valid                   (d_bank_0_rsp_valid                ),
    .d_bank_rsp_ready                   (d_bank_0_rsp_ready                ),

    .ch_0_last_entry_already_pop        (bank_0_ch_0_last_entry_already_pop),
    .ch_1_last_entry_already_pop        (bank_0_ch_1_last_entry_already_pop),
    .ch_2_last_entry_already_pop        (bank_0_ch_2_last_entry_already_pop),

    .w_ptr                              (bank_0_w_ptr                      ),    
    .r_ptr                              (bank_0_r_ptr                      )

);

rtn_xbar_sub_ptr_gen u_bank_1_xbar_sub_ptr_gen(
    .clk                                (clk                               ),
    .rst_n                              (rst_n                             ),

    .d_bank_rsp_valid                   (d_bank_1_rsp_valid                ),
    .d_bank_rsp_ready                   (d_bank_1_rsp_ready                ),

    .ch_0_last_entry_already_pop        (bank_1_ch_0_last_entry_already_pop),
    .ch_1_last_entry_already_pop        (bank_1_ch_1_last_entry_already_pop),
    .ch_2_last_entry_already_pop        (bank_1_ch_2_last_entry_already_pop),

    .w_ptr                              (bank_1_w_ptr                      ),
    .r_ptr                              (bank_1_r_ptr                      )
);

rtn_xbar_sub_ptr_gen u_bank_2_xbar_sub_ptr_gen(
    .clk                                (clk                               ),
    .rst_n                              (rst_n                             ),

    .d_bank_rsp_valid                   (d_bank_2_rsp_valid                ),
    .d_bank_rsp_ready                   (d_bank_2_rsp_ready                ),

    .ch_0_last_entry_already_pop        (bank_2_ch_0_last_entry_already_pop),
    .ch_1_last_entry_already_pop        (bank_2_ch_1_last_entry_already_pop),
    .ch_2_last_entry_already_pop        (bank_2_ch_2_last_entry_already_pop),

    .w_ptr                              (bank_2_w_ptr                      ),
    .r_ptr                              (bank_2_r_ptr                      )
);

rtn_xbar_sub_ptr_gen u_bank_3_xbar_sub_ptr_gen(
    .clk                                (clk                               ),
    .rst_n                              (rst_n                             ),

    .d_bank_rsp_valid                   (d_bank_3_rsp_valid                ),
    .d_bank_rsp_ready                   (d_bank_3_rsp_ready                ),

    .ch_0_last_entry_already_pop        (bank_3_ch_0_last_entry_already_pop),
    .ch_1_last_entry_already_pop        (bank_3_ch_1_last_entry_already_pop),
    .ch_2_last_entry_already_pop        (bank_3_ch_2_last_entry_already_pop),

    .w_ptr                              (bank_3_w_ptr                      ),
    .r_ptr                              (bank_3_r_ptr                      )
);

endmodule

module rtn_xbar_sub_ptr_gen
    import mpc_types::*;
(
    input  logic                        clk                            ,
    input  logic                        rst_n                          ,

    input  logic                        d_bank_rsp_valid               ,
    output logic                        d_bank_rsp_ready               ,

    input  logic                        ch_0_last_entry_already_pop    ,
    input  logic                        ch_1_last_entry_already_pop    ,
    input  logic                        ch_2_last_entry_already_pop    ,

    output logic    [  2: 0]            w_ptr                          ,
    output logic    [  2: 0]            r_ptr                          
);

logic            d_bank_rsp_hsked;

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

assign d_bank_rsp_hsked = d_bank_rsp_valid & d_bank_rsp_ready;
assign w_ptr_incr     = d_bank_rsp_hsked & ~(&w_ptr_r);
assign w_ptr_clr      = d_bank_rsp_hsked & (&w_ptr_r);
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

assign last_entry_already_pop = ch_0_last_entry_already_pop &
                                ch_1_last_entry_already_pop &
                                ch_2_last_entry_already_pop ;
                        
assign d_bank_rsp_ready = ~(&used_entry);

assign w_ptr = w_ptr_r;
assign r_ptr = r_ptr_r;

endmodule