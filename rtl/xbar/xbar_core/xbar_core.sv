module xbar_core
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
    parameter type channel_req_t   = logic,
    parameter type bank_req_t      = logic
)
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        u_channel_0_req_valid      ,
    output logic                        u_channel_0_req_ready      ,
    input  channel_req_t                u_channel_0_req            ,

    input  logic                        u_channel_1_req_valid      ,
    output logic                        u_channel_1_req_ready      ,
    input  channel_req_t                u_channel_1_req            ,

    input  logic                        u_channel_2_req_valid      ,
    output logic                        u_channel_2_req_ready      ,
    input  channel_req_t                u_channel_2_req            ,

    output logic                        d_bank_0_req_valid         ,
    input  logic                        d_bank_0_req_ready         ,
    output bank_req_t                   d_bank_0_req               ,

    output logic                        d_bank_1_req_valid         ,
    input  logic                        d_bank_1_req_ready         ,
    output bank_req_t                   d_bank_1_req               ,

    output logic                        d_bank_2_req_valid         ,
    input  logic                        d_bank_2_req_ready         ,
    output bank_req_t                   d_bank_2_req               ,

    output logic                        d_bank_3_req_valid         ,
    input  logic                        d_bank_3_req_ready         ,
    output bank_req_t                   d_bank_3_req               
);

logic            [  2: 0]    ch_0_w_ptr                         ;
logic            [  2: 0]    ch_0_r_ptr                         ;
logic            [  2: 0]    ch_1_w_ptr                         ;
logic            [  2: 0]    ch_1_r_ptr                         ;
logic            [  2: 0]    ch_2_w_ptr                         ;
logic            [  2: 0]    ch_2_r_ptr                         ;

logic                        ch_0_bank_1_last_entry_already_pop ;
logic                        ch_0_bank_0_last_entry_already_pop ;
logic                        ch_0_bank_2_last_entry_already_pop ;
logic                        ch_0_bank_3_last_entry_already_pop ;

logic                        ch_1_bank_1_last_entry_already_pop ;
logic                        ch_1_bank_0_last_entry_already_pop ;
logic                        ch_1_bank_2_last_entry_already_pop ;
logic                        ch_1_bank_3_last_entry_already_pop ;

logic                        ch_2_bank_0_last_entry_already_pop ;
logic                        ch_2_bank_1_last_entry_already_pop ;
logic                        ch_2_bank_2_last_entry_already_pop ;
logic                        ch_2_bank_3_last_entry_already_pop ;

logic            [  2: 0]    bank_0_ch_1hot_id                  ;
logic            [  2: 0]    bank_1_ch_1hot_id                  ;
logic            [  2: 0]    bank_2_ch_1hot_id                  ;
logic            [  2: 0]    bank_3_ch_1hot_id                  ;

logic            [  7: 0]    ch_0_bank_0_r_entry_1hot_id        ;
logic            [  7: 0]    ch_0_bank_1_r_entry_1hot_id        ;
logic            [  7: 0]    ch_0_bank_2_r_entry_1hot_id        ;
logic            [  7: 0]    ch_0_bank_3_r_entry_1hot_id        ;

logic            [  7: 0]    ch_1_bank_0_r_entry_1hot_id        ;
logic            [  7: 0]    ch_1_bank_1_r_entry_1hot_id        ;
logic            [  7: 0]    ch_1_bank_2_r_entry_1hot_id        ;
logic            [  7: 0]    ch_1_bank_3_r_entry_1hot_id        ;

logic            [  7: 0]    ch_2_bank_0_r_entry_1hot_id        ;
logic            [  7: 0]    ch_2_bank_1_r_entry_1hot_id        ;
logic            [  7: 0]    ch_2_bank_2_r_entry_1hot_id        ;
logic            [  7: 0]    ch_2_bank_3_r_entry_1hot_id        ;

channel_req_t   d_bank_0_ch_req;
channel_req_t   d_bank_1_ch_req;
channel_req_t   d_bank_2_ch_req;
channel_req_t   d_bank_3_ch_req;

xbar_matrix #(
    .Cfg                                (Cfg                       ),
    .setWidth_t                         (setWidth_t                ), 
    .tagWidth_t                         (tagWidth_t                ), 
    .wayIndexWidth_t                    (wayIndexWidth_t           ), 
    .wbufWidth_t                        (wbufWidth_t               ), 
    .wayNum_t                           (wayNum_t                  ), 
    .nlineWidth_t                       (nlineWidth_t              ), 
    .offsetWidth_t                      (offsetWidth_t             ), 
    .metaWidth_t                        (metaWidth_t               ), 
    .channel_req_t                      (channel_req_t             )
) 
u_xbar_matrix (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

xbar_ptr_gen u_xbar_ptr_gen (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

xbar_buffer # (    
    .Cfg                               (Cfg                                ),
    .setWidth_t                        (setWidth_t                         ),
    .tagWidth_t                        (tagWidth_t                         ),
    .wayIndexWidth_t                   (wayIndexWidth_t                    ),
    .wbufWidth_t                       (wbufWidth_t                        ),
    .wayNum_t                          (wayNum_t                           ),
    .nlineWidth_t                      (nlineWidth_t                       ),
    .offsetWidth_t                     (offsetWidth_t                      ),
    .metaWidth_t                       (metaWidth_t                        ),
    .channel_req_t                     (channel_req_t                      )
)
u_xbar_buffer (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

assign d_bank_0_req.channel_1hot_id = bank_0_ch_1hot_id;
assign d_bank_0_req.op              = d_bank_0_ch_req.op;
assign d_bank_0_req.addr            = d_bank_0_ch_req.addr;
assign d_bank_0_req.wdata           = d_bank_0_ch_req.wdata;

assign d_bank_1_req.channel_1hot_id = bank_1_ch_1hot_id;
assign d_bank_1_req.op              = d_bank_1_ch_req.op;
assign d_bank_1_req.addr            = d_bank_1_ch_req.addr;
assign d_bank_1_req.wdata           = d_bank_1_ch_req.wdata;

assign d_bank_2_req.channel_1hot_id = bank_2_ch_1hot_id;
assign d_bank_2_req.op              = d_bank_2_ch_req.op;
assign d_bank_2_req.addr            = d_bank_2_ch_req.addr;
assign d_bank_2_req.wdata           = d_bank_2_ch_req.wdata;

assign d_bank_3_req.channel_1hot_id = bank_3_ch_1hot_id;
assign d_bank_3_req.op              = d_bank_3_ch_req.op;
assign d_bank_3_req.addr            = d_bank_3_ch_req.addr;
assign d_bank_3_req.wdata           = d_bank_3_ch_req.wdata;

endmodule


