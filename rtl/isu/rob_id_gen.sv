module rob_id_gen
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

    input  logic                        u_valid                    ,              
    input  logic    [  2: 0]            u_channel_1hot_id          ,         
    output robWidth_t                   d_isu_rob_id    
);

robWidth_t          isu_rob_id_nxt [  2: 0];
logic      [  2: 0] isu_rob_id_en          ;
robWidth_t          isu_rob_id     [  2: 0];
logic      [  1: 0] channel_id             ;

ns_1hot2bin # (3) chnnel_id_1hot2bin (u_channel_1hot_id, channel_id);

generate
    for (genvar i = 0; i < 3; i++)
    begin : rob_id_gen
        assign isu_rob_id_nxt[i] = isu_rob_id[i] + 'd1;
        assign isu_rob_id_en [i] = u_valid & u_channel_1hot_id[i];
        ns_gnrl_dfflr # (Cfg.robWidth) isu_rob_id_dfflr (isu_rob_id_en[i], isu_rob_id_nxt[i], isu_rob_id[i], clk, rst_n);
    end
endgenerate

assign d_isu_rob_id = isu_rob_id[channel_id];

endmodule