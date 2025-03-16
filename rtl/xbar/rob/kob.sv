module kob
    import mpc_types::*;
#(
    localparam mpc_user_cfg_t UserCfg = '{
        clWidth:256,
        clWordWidth:128,
        sets:8,
        banks:4,
        ways:8,
        kobSize:16
    },

    localparam mpc_cfg_t Cfg = mpcBuildConfig(UserCfg),

    localparam type kobSize_t = logic [Cfg.u.kobSize-1:0] // TO BE REMOVED
)
(
    input  logic                        clk                            ,
    input  logic                        rst_n                          ,


    input  logic                        u_channel_0_req_valid          ,
    input  logic                        u_channel_0_req_ready          ,
    input  channel_req_t                u_channel_0_req                ,

    input  logic                        u_channel_1_req_valid          ,
    input  logic                        u_channel_1_req_ready          ,
    input  channel_req_t                u_channel_1_req                ,

    input  logic                        u_channel_2_req_valid          ,
    input  logic                        u_channel_2_req_ready          ,
    input  channel_req_t                u_channel_2_req                ,

    output logic                        d_ch_0_rob_req                 ,
    input  logic                        d_ch_0_rob_ack                 ,
    output logic           [  1: 0]     d_ch_0_rob_bank_id             ,

    output logic                        d_ch_1_rob_req                 ,
    input  logic                        d_ch_1_rob_ack                 ,
    output logic           [  1: 0]     d_ch_1_rob_bank_id             ,

    output logic                        d_ch_2_rob_req                 ,
    input  logic                        d_ch_2_rob_ack                 ,
    output logic           [  1: 0]     d_ch_2_rob_bank_id             ,

    output logic                        ch_0_kob_full                  ,
    output logic                        ch_1_kob_full                  ,
    output logic                        ch_2_kob_full                   


);

logic u_ch_0_req_hsked, u_ch_1_req_hsked, u_ch_2_req_hsked;

logic                        ch_0_kob_wen          ;
logic            [  1: 0]    ch_0_kob_wdata        ;

logic                        ch_1_kob_wen          ;
logic            [  1: 0]    ch_1_kob_wdata        ;

logic                        ch_2_kob_wen          ;
logic            [  1: 0]    ch_2_kob_wdata        ;

logic                        ch_0_alc_ptr_flg_ena  ;
logic                        ch_0_alc_ptr_flg_nxt  ;
logic                        ch_0_alc_ptr_flg_r    ;

logic                        ch_1_alc_ptr_flg_ena  ;
logic                        ch_1_alc_ptr_flg_nxt  ;
logic                        ch_1_alc_ptr_flg_r    ;

logic                        ch_2_alc_ptr_flg_ena  ;
logic                        ch_2_alc_ptr_flg_nxt  ;
logic                        ch_2_alc_ptr_flg_r    ;

logic                        ch_0_alc_ptr_ena      ;
logic            [  3: 0]    ch_0_alc_ptr_nxt      ;
logic            [  3: 0]    ch_0_alc_ptr_r        ;

logic                        ch_1_alc_ptr_ena      ;
logic            [  3: 0]    ch_1_alc_ptr_nxt      ;
logic            [  3: 0]    ch_1_alc_ptr_r        ;

logic                        ch_2_alc_ptr_ena      ;
logic            [  3: 0]    ch_2_alc_ptr_nxt      ;
logic            [  3: 0]    ch_2_alc_ptr_r        ;

logic                        ch_0_ret_ptr_flg_ena  ;
logic                        ch_0_ret_ptr_flg_nxt  ;
logic                        ch_0_ret_ptr_flg_r    ;

logic                        ch_1_ret_ptr_flg_ena  ;
logic                        ch_1_ret_ptr_flg_nxt  ;
logic                        ch_1_ret_ptr_flg_r    ;

logic                        ch_2_ret_ptr_flg_ena  ;
logic                        ch_2_ret_ptr_flg_nxt  ;
logic                        ch_2_ret_ptr_flg_r    ;

logic                        ch_0_ret_ptr_ena      ;
logic            [  3: 0]    ch_0_ret_ptr_nxt      ;
logic            [  3: 0]    ch_0_ret_ptr_r        ;

logic                        ch_1_ret_ptr_ena      ;
logic            [  3: 0]    ch_1_ret_ptr_nxt      ;
logic            [  3: 0]    ch_1_ret_ptr_r        ;

logic                        ch_2_ret_ptr_ena      ;
logic            [  3: 0]    ch_2_ret_ptr_nxt      ;
logic            [  3: 0]    ch_2_ret_ptr_r        ;

logic                        ch_0_kob_empty        ;
logic                        ch_1_kob_empty        ;
logic                        ch_2_kob_empty        ;

kobSize_t                    ch_0_vld_set                    ; // TO BE REMOVED
logic            [ 15: 0]    ch_0_vld_clr                    ;
logic            [ 15: 0]    ch_0_vld_ena                    ;
logic            [ 15: 0]    ch_0_vld_nxt                    ;
logic            [ 15: 0]    ch_0_vld_r                      ;
logic            [  1: 0]    ch_0_bank_id_entry [ 15: 0]     ;

logic            [ 15: 0]    ch_1_vld_set                    ;
logic            [ 15: 0]    ch_1_vld_clr                    ;
logic            [ 15: 0]    ch_1_vld_ena                    ;
logic            [ 15: 0]    ch_1_vld_nxt                    ;
logic            [ 15: 0]    ch_1_vld_r                      ;
logic            [  1: 0]    ch_1_bank_id_entry [ 15: 0]     ;

logic            [ 15: 0]    ch_2_vld_set                    ;
logic            [ 15: 0]    ch_2_vld_clr                    ;
logic            [ 15: 0]    ch_2_vld_ena                    ;
logic            [ 15: 0]    ch_2_vld_nxt                    ;
logic            [ 15: 0]    ch_2_vld_r                      ;
logic            [  1: 0]    ch_2_bank_id_entry [ 15: 0]     ;


assign u_ch_0_req_hsked = u_channel_0_req_valid & u_channel_0_req_ready;
assign u_ch_1_req_hsked = u_channel_1_req_valid & u_channel_1_req_ready;
assign u_ch_2_req_hsked = u_channel_2_req_valid & u_channel_2_req_ready;

assign ch_0_kob_wen   = u_ch_0_req_hsked & is_load(u_channel_0_req.op);
assign ch_1_kob_wen   = u_ch_1_req_hsked & is_load(u_channel_1_req.op);
assign ch_2_kob_wen   = u_ch_2_req_hsked & is_load(u_channel_2_req.op);

assign ch_0_kob_wdata = u_channel_0_req.addr[9:8];
assign ch_1_kob_wdata = u_channel_1_req.addr[9:8];
assign ch_2_kob_wdata = u_channel_2_req.addr[9:8];

assign ch_0_alc_ptr_flg_ena = (ch_0_alc_ptr_r == 4'd15) & ch_0_alc_ptr_ena;
assign ch_0_alc_ptr_flg_nxt = ~ch_0_alc_ptr_flg_r;
ns_gnrl_dfflr #(1) ch_0_alc_ptr_flg_dfflr(ch_0_alc_ptr_flg_ena, ch_0_alc_ptr_flg_nxt, ch_0_alc_ptr_flg_r, clk, rst_n);

assign ch_1_alc_ptr_flg_ena = (ch_1_alc_ptr_r == 4'd15) & ch_1_alc_ptr_ena;
assign ch_1_alc_ptr_flg_nxt = ~ch_1_alc_ptr_flg_r;
ns_gnrl_dfflr #(1) ch_1_alc_ptr_flg_dfflr(ch_1_alc_ptr_flg_ena, ch_1_alc_ptr_flg_nxt, ch_1_alc_ptr_flg_r, clk, rst_n);

assign ch_2_alc_ptr_flg_ena = (ch_2_alc_ptr_r == 4'd15) & ch_2_alc_ptr_ena;
assign ch_2_alc_ptr_flg_nxt = ~ch_2_alc_ptr_flg_r;
ns_gnrl_dfflr #(1) ch_2_alc_ptr_flg_dfflr(ch_2_alc_ptr_flg_ena, ch_2_alc_ptr_flg_nxt, ch_2_alc_ptr_flg_r, clk, rst_n);

assign ch_0_alc_ptr_ena    = ch_0_kob_wen;
assign ch_0_alc_ptr_nxt    = ch_0_alc_ptr_flg_ena ? 4'b0 : (ch_0_alc_ptr_r + 1'b1);
ns_gnrl_dfflr #(4) ch_0_alc_ptr_dfflr(ch_0_alc_ptr_ena, ch_0_alc_ptr_nxt, ch_0_alc_ptr_r, clk, rst_n);

assign ch_1_alc_ptr_ena    = ch_1_kob_wen;
assign ch_1_alc_ptr_nxt    = ch_1_alc_ptr_flg_ena ? 4'b0 : (ch_1_alc_ptr_r + 1'b1);
ns_gnrl_dfflr #(4) ch_1_alc_ptr_dfflr(ch_1_alc_ptr_ena, ch_1_alc_ptr_nxt, ch_1_alc_ptr_r, clk, rst_n);

assign ch_2_alc_ptr_ena    = ch_2_kob_wen;
assign ch_2_alc_ptr_nxt    = ch_2_alc_ptr_flg_ena ? 4'b0 : (ch_2_alc_ptr_r + 1'b1);
ns_gnrl_dfflr #(4) ch_2_alc_ptr_dfflr(ch_2_alc_ptr_ena, ch_2_alc_ptr_nxt, ch_2_alc_ptr_r, clk, rst_n);


assign ch_0_ret_ptr_flg_ena = (ch_0_ret_ptr_r == 4'd15) & ch_0_ret_ptr_ena;
assign ch_0_ret_ptr_flg_nxt = ~ch_0_ret_ptr_flg_r;
ns_gnrl_dfflr #(1) ch_0_ret_ptr_flg_dfflr (ch_0_ret_ptr_flg_ena, ch_0_ret_ptr_flg_nxt, ch_0_ret_ptr_flg_r, clk, rst_n);

assign ch_1_ret_ptr_flg_ena = (ch_1_ret_ptr_r == 4'd15) & ch_1_ret_ptr_ena;
assign ch_1_ret_ptr_flg_nxt = ~ch_1_ret_ptr_flg_r;
ns_gnrl_dfflr #(1) ch_1_ret_ptr_flg_dfflr (ch_1_ret_ptr_flg_ena, ch_1_ret_ptr_flg_nxt, ch_1_ret_ptr_flg_r, clk, rst_n);

assign ch_2_ret_ptr_flg_ena = (ch_2_ret_ptr_r == 4'd15) & ch_2_ret_ptr_ena;
assign ch_2_ret_ptr_flg_nxt = ~ch_2_ret_ptr_flg_r;
ns_gnrl_dfflr #(1) ch_2_ret_ptr_flg_dfflr (ch_2_ret_ptr_flg_ena, ch_2_ret_ptr_flg_nxt, ch_2_ret_ptr_flg_r, clk, rst_n);

assign ch_0_ret_ptr_ena     = d_ch_0_rob_req & d_ch_0_rob_ack;
assign ch_0_ret_ptr_nxt     = ch_0_ret_ptr_flg_ena ? 4'b0 : (ch_0_ret_ptr_r + 1'b1);
ns_gnrl_dfflr #(4) ch_0_ret_ptr_dfflr(ch_0_ret_ptr_ena, ch_0_ret_ptr_nxt, ch_0_ret_ptr_r, clk, rst_n);

assign ch_1_ret_ptr_ena     = d_ch_1_rob_req & d_ch_1_rob_ack;
assign ch_1_ret_ptr_nxt     = ch_1_ret_ptr_flg_ena ? 4'b0 : (ch_1_ret_ptr_r + 1'b1);
ns_gnrl_dfflr #(4) ch_1_ret_ptr_dfflr(ch_1_ret_ptr_ena, ch_1_ret_ptr_nxt, ch_1_ret_ptr_r, clk, rst_n);

assign ch_2_ret_ptr_ena     = d_ch_2_rob_req & d_ch_2_rob_ack;
assign ch_2_ret_ptr_nxt     = ch_2_ret_ptr_flg_ena ? 4'b0 : (ch_2_ret_ptr_r + 1'b1);
ns_gnrl_dfflr #(4) ch_2_ret_ptr_dfflr(ch_2_ret_ptr_ena, ch_2_ret_ptr_nxt, ch_2_ret_ptr_r, clk, rst_n);


assign ch_0_kob_empty = (ch_0_ret_ptr_r == ch_0_alc_ptr_r) & (ch_0_ret_ptr_flg_r == ch_0_alc_ptr_flg_r);
assign ch_1_kob_empty = (ch_1_ret_ptr_r == ch_1_alc_ptr_r) & (ch_1_ret_ptr_flg_r == ch_1_alc_ptr_flg_r);
assign ch_2_kob_empty = (ch_2_ret_ptr_r == ch_2_alc_ptr_r) & (ch_2_ret_ptr_flg_r == ch_2_alc_ptr_flg_r);

assign ch_0_kob_full = (ch_0_ret_ptr_r == ch_0_alc_ptr_r) & (~(ch_0_ret_ptr_flg_r == ch_0_alc_ptr_flg_r));
assign ch_1_kob_full = (ch_1_ret_ptr_r == ch_1_alc_ptr_r) & (~(ch_1_ret_ptr_flg_r == ch_1_alc_ptr_flg_r));
assign ch_2_kob_full = (ch_2_ret_ptr_r == ch_2_alc_ptr_r) & (~(ch_2_ret_ptr_flg_r == ch_2_alc_ptr_flg_r));

generate 
    for (genvar i = 0; i < 16; i = i+1) 
    begin: kob_entry
        assign ch_0_vld_set[i] = ch_0_alc_ptr_ena & (ch_0_alc_ptr_r == i);    
        assign ch_0_vld_clr[i] = ch_0_ret_ptr_ena & (ch_0_ret_ptr_r == i);
        assign ch_0_vld_ena[i] = ch_0_vld_set[i] |   ch_0_vld_clr[i];
        assign ch_0_vld_nxt[i] = ch_0_vld_set[i] | (~ch_0_vld_clr[i]);

        assign ch_1_vld_set[i] = ch_1_alc_ptr_ena & (ch_1_alc_ptr_r == i);    
        assign ch_1_vld_clr[i] = ch_1_ret_ptr_ena & (ch_1_ret_ptr_r == i);
        assign ch_1_vld_ena[i] = ch_1_vld_set[i] |   ch_1_vld_clr[i];
        assign ch_1_vld_nxt[i] = ch_1_vld_set[i] | (~ch_1_vld_clr[i]);

        assign ch_2_vld_set[i] = ch_2_alc_ptr_ena & (ch_2_alc_ptr_r == i);    
        assign ch_2_vld_clr[i] = ch_2_ret_ptr_ena & (ch_2_ret_ptr_r == i);
        assign ch_2_vld_ena[i] = ch_2_vld_set[i] |   ch_2_vld_clr[i];
        assign ch_2_vld_nxt[i] = ch_2_vld_set[i] | (~ch_2_vld_clr[i]);

        ns_gnrl_dfflr #(1) ch_0_vld_dfflr (ch_0_vld_ena[i], ch_0_vld_nxt[i], ch_0_vld_r[i], clk, rst_n);
        ns_gnrl_dfflr #(1) ch_1_vld_dfflr (ch_1_vld_ena[i], ch_1_vld_nxt[i], ch_1_vld_r[i], clk, rst_n);
        ns_gnrl_dfflr #(1) ch_2_vld_dfflr (ch_2_vld_ena[i], ch_2_vld_nxt[i], ch_2_vld_r[i], clk, rst_n);

        ns_gnrl_dfflr #(2) ch_0_bank_id_entry_dfflr (ch_0_vld_set[i], ch_0_kob_wdata, ch_0_bank_id_entry[i], clk, rst_n);
        ns_gnrl_dfflr #(2) ch_1_bank_id_entry_dfflr (ch_1_vld_set[i], ch_1_kob_wdata, ch_1_bank_id_entry[i], clk, rst_n);
        ns_gnrl_dfflr #(2) ch_2_bank_id_entry_dfflr (ch_2_vld_set[i], ch_2_kob_wdata, ch_2_bank_id_entry[i], clk, rst_n);    
    end
endgenerate

assign d_ch_0_rob_req = ch_0_vld_r[ch_0_ret_ptr_r];
assign d_ch_1_rob_req = ch_1_vld_r[ch_1_ret_ptr_r];
assign d_ch_2_rob_req = ch_2_vld_r[ch_2_ret_ptr_r];

assign d_ch_0_rob_bank_id = ch_0_bank_id_entry[ch_0_ret_ptr_r];
assign d_ch_1_rob_bank_id = ch_1_bank_id_entry[ch_1_ret_ptr_r];
assign d_ch_2_rob_bank_id = ch_2_bank_id_entry[ch_2_ret_ptr_r];


endmodule