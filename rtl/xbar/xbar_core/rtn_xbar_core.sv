module rtn_xbar_core
    import mpc_types::*;
#(
    parameter mpc_cfg_t Cfg = '0,   
    parameter type setWidth_t      = logic,
    parameter type tagWidth_t      = logic,
    parameter type wayIndexWidth_t = logic,
    parameter type wbufWidth_t     = logic,
    parameter type wayNum_t        = logic,
    parameter type nlineWidth_t    = logic,
    parameter type offsetWidth_t   = logic,
    parameter type metaWidth_t     = logic,
    parameter type robWidth_t      = logic,
    parameter type lsqWidth_t      = logic
)
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        d_bank_0_rsp_valid         ,
    output logic                        d_bank_0_rsp_ready         ,
    input  logic          [127: 0]      d_bank_0_rsp_data          ,
    input  logic          [  1: 0]      d_bank_0_rsp_channel_id    ,
    input  robWidth_t                   d_bank_0_rsp_rob_id        ,

    input  logic                        d_bank_1_rsp_valid         ,
    output logic                        d_bank_1_rsp_ready         ,
    input  logic          [127: 0]      d_bank_1_rsp_data          ,
    input  logic          [  1: 0]      d_bank_1_rsp_channel_id    ,
    input  robWidth_t                   d_bank_1_rsp_rob_id        ,

    input  logic                        d_bank_2_rsp_valid         ,
    output logic                        d_bank_2_rsp_ready         ,
    input  logic          [127: 0]      d_bank_2_rsp_data          ,
    input  logic          [  1: 0]      d_bank_2_rsp_channel_id    ,
    input  robWidth_t                   d_bank_2_rsp_rob_id        ,

    input  logic                        d_bank_3_rsp_valid         ,
    output logic                        d_bank_3_rsp_ready         ,
    input  logic          [127: 0]      d_bank_3_rsp_data          ,
    input  logic          [  1: 0]      d_bank_3_rsp_channel_id    ,
    input  robWidth_t                   d_bank_3_rsp_rob_id        ,

    output logic                        u_channel_0_rsp_valid      ,
    input  logic                        u_channel_0_rsp_ready      ,
    output logic          [127: 0]      u_channel_0_rsp_data       ,
    output logic          [  1: 0]      u_channel_0_rsp_bank_id    ,
    output robWidth_t                   u_channel_0_rsp_rob_id     ,

    output logic                        u_channel_1_rsp_valid      ,
    input  logic                        u_channel_1_rsp_ready      ,
    output logic          [127: 0]      u_channel_1_rsp_data       ,
    output logic          [  1: 0]      u_channel_1_rsp_bank_id    ,
    output robWidth_t                   u_channel_1_rsp_rob_id     ,

    output logic                        u_channel_2_rsp_valid      ,
    input  logic                        u_channel_2_rsp_ready      ,
    output logic          [127: 0]      u_channel_2_rsp_data       ,
    output logic          [  1: 0]      u_channel_2_rsp_bank_id    ,
    output robWidth_t                   u_channel_2_rsp_rob_id
);

logic            [  2: 0]    bank_0_w_ptr                         ;
logic            [  2: 0]    bank_0_r_ptr                         ;
logic            [  2: 0]    bank_1_w_ptr                         ;
logic            [  2: 0]    bank_1_r_ptr                         ;
logic            [  2: 0]    bank_2_w_ptr                         ;
logic            [  2: 0]    bank_2_r_ptr                         ;
logic            [  2: 0]    bank_3_w_ptr                         ;
logic            [  2: 0]    bank_3_r_ptr                         ;


logic                        bank_0_ch_0_last_entry_already_pop ;
logic                        bank_0_ch_1_last_entry_already_pop ;
logic                        bank_0_ch_2_last_entry_already_pop ;

logic                        bank_1_ch_0_last_entry_already_pop ;
logic                        bank_1_ch_1_last_entry_already_pop ;
logic                        bank_1_ch_2_last_entry_already_pop ;

logic                        bank_2_ch_0_last_entry_already_pop ;
logic                        bank_2_ch_1_last_entry_already_pop ;
logic                        bank_2_ch_2_last_entry_already_pop ;

logic                        bank_3_ch_0_last_entry_already_pop ;
logic                        bank_3_ch_1_last_entry_already_pop ;
logic                        bank_3_ch_2_last_entry_already_pop ;

logic            [  3: 0]    ch_0_bank_1hot_id                  ;
logic            [  3: 0]    ch_1_bank_1hot_id                  ;
logic            [  3: 0]    ch_2_bank_1hot_id                  ;

logic            [  7: 0]    bank_0_ch_0_r_entry_1hot_id        ;
logic            [  7: 0]    bank_0_ch_1_r_entry_1hot_id        ;
logic            [  7: 0]    bank_0_ch_2_r_entry_1hot_id        ;

logic            [  7: 0]    bank_1_ch_0_r_entry_1hot_id        ;
logic            [  7: 0]    bank_1_ch_1_r_entry_1hot_id        ;
logic            [  7: 0]    bank_1_ch_2_r_entry_1hot_id        ;

logic            [  7: 0]    bank_2_ch_0_r_entry_1hot_id        ;
logic            [  7: 0]    bank_2_ch_1_r_entry_1hot_id        ;
logic            [  7: 0]    bank_2_ch_2_r_entry_1hot_id        ;


logic            [  7: 0]    bank_3_ch_0_r_entry_1hot_id        ;
logic            [  7: 0]    bank_3_ch_1_r_entry_1hot_id        ;
logic            [  7: 0]    bank_3_ch_2_r_entry_1hot_id        ;

logic            [127: 0]    u_ch_0_bank_rsp_data;
logic            [127: 0]    u_ch_1_bank_rsp_data;
logic            [127: 0]    u_ch_2_bank_rsp_data;

robWidth_t                   u_ch_0_bank_rsp_rob_id;
robWidth_t                   u_ch_1_bank_rsp_rob_id;
robWidth_t                   u_ch_2_bank_rsp_rob_id;

rtn_xbar_matrix u_rtn_xbar_matrix (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

rtn_xbar_ptr_gen u_rtn_xbar_ptr_gen (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

rtn_xbar_buffer # (  
        .Cfg                               (Cfg                                ),
        .setWidth_t                        (setWidth_t                         ),
        .tagWidth_t                        (tagWidth_t                         ),
        .wayIndexWidth_t                   (wayIndexWidth_t                    ),
        .wbufWidth_t                       (wbufWidth_t                        ),
        .wayNum_t                          (wayNum_t                           ),
        .nlineWidth_t                      (nlineWidth_t                       ),
        .offsetWidth_t                     (offsetWidth_t                      ),
        .metaWidth_t                       (metaWidth_t                        ),
        .robWidth_t                        (robWidth_t                         ),
        .lsqWidth_t                        (lsqWidth_t                         )
    ) u_rtn_xbar_buffer (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

assign u_channel_0_rsp_data = u_ch_0_bank_rsp_data;
assign u_channel_1_rsp_data = u_ch_1_bank_rsp_data;
assign u_channel_2_rsp_data = u_ch_2_bank_rsp_data;

assign u_channel_0_rsp_rob_id = u_ch_0_bank_rsp_rob_id;
assign u_channel_1_rsp_rob_id = u_ch_1_bank_rsp_rob_id;
assign u_channel_2_rsp_rob_id = u_ch_2_bank_rsp_rob_id;


ns_1hot2bin #(4) ns_1hot2bin_ch_0_rsp_bank_id (ch_0_bank_1hot_id, u_channel_0_rsp_bank_id);
ns_1hot2bin #(4) ns_1hot2bin_ch_1_rsp_bank_id (ch_1_bank_1hot_id, u_channel_1_rsp_bank_id);
ns_1hot2bin #(4) ns_1hot2bin_ch_2_rsp_bank_id (ch_2_bank_1hot_id, u_channel_2_rsp_bank_id);

endmodule


