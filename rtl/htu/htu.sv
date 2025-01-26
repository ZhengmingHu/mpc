module htu
    import mpc_types::*;

    localparam mpc_user_cfg_t UserCfg = '{
        clWidth:256,
        clWordWidth:128,
        sets:8,
        banks:4,
        ways:8,
        kobSize:16,
        wbufSize:128
    },

    localparam mpc_cfg_t Cfg = mpcBuildConfig(UserCfg),
   
    localparam type setWidth_t      = logic [Cfg.setWidth-1:0],
    localparam type tagWidth_t      = logic [Cfg.tagWidth-1:0],
    localparam type wayIndexWidth_t = logic [Cfg.wayIndexWidth-1:0],
    localparam type wbufWidth_t     = logic [Cfg.wbufWidth-1:0],
    localparam type nlineWidth_t    = logic [Cfg.nlineWidth-1:0]

(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        u_bank_req_valid           ,
    input  logic                        u_bank_req_ready           ,
    output logic                        u_bank_htu_req_ready       ,
    input  bank_req_t                   u_bank_req                 ,

    output logic                        d_isu_refill_flg           ,
    output setWidth_t                   d_isu_refill_set           ,
    output wayIndexWidth_t              d_isu_refill_way           ,

    output logic                        d_isu_valid                ,
    input  logic                        d_isu_ready                ,
    output nlineWidth_t                 d_isu_nline                ,
    output wbufWidth_t                  d_isu_wbuf_id              ,
    output logic            [  1:0]     d_isu_

);


endmodule