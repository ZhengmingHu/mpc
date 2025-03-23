module xbar_wrapper
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

    input  logic                        u_channel_0_req_valid      ,
    output logic                        u_channel_0_req_ready      ,
    input  channel_req_t                u_channel_0_req            ,

    input  logic                        u_channel_1_req_valid      ,
    output logic                        u_channel_1_req_ready      ,
    input  channel_req_t                u_channel_1_req            ,

    input  logic                        u_channel_2_req_valid      ,
    output logic                        u_channel_2_req_ready      ,
    input  channel_req_t                u_channel_2_req            ,

    output logic                        u_channel_0_rsp_valid      ,
    input  logic                        u_channel_0_rsp_ready      ,
    output channel_rsp_t                u_channel_0_rsp            ,

    output logic                        u_channel_1_rsp_valid      ,
    input  logic                        u_channel_1_rsp_ready      ,
    output channel_rsp_t                u_channel_1_rsp            ,   

    output logic                        u_channel_2_rsp_valid      ,
    input  logic                        u_channel_2_rsp_ready      ,
    output channel_rsp_t                u_channel_2_rsp            ,

    output logic                        d_bank_0_htu_valid         ,
    input  logic                        d_bank_0_htu_ready         ,
    output htu_req_t                    d_bank_0_htu_req           ,

    output logic                        d_bank_1_htu_valid         ,
    input  logic                        d_bank_1_htu_ready         ,
    output htu_req_t                    d_bank_1_htu_req           ,

    output logic                        d_bank_2_htu_valid         ,
    input  logic                        d_bank_2_htu_ready         ,
    output htu_req_t                    d_bank_2_htu_req           ,

    output logic                        d_bank_3_htu_valid         ,
    input  logic                        d_bank_3_htu_ready         ,
    output htu_req_t                    d_bank_3_htu_req           ,

    output logic                        d_bank_0_wbuf_req_valid    ,
    input  logic                        d_bank_0_wbuf_req_ready    ,
    output wbuf_req_t                   d_bank_0_wbuf_req          ,
    input  logic         [255: 0]       d_bank_0_wbuf_rsp_free_id

    output logic                        d_bank_1_wbuf_req_valid    ,
    input  logic                        d_bank_1_wbuf_req_ready    ,
    output wbuf_req_t                   d_bank_1_wbuf_req          ,
    input  logic         [255: 0]       d_bank_1_wbuf_rsp_free_id

    output logic                        d_bank_2_wbuf_req_valid    ,
    input  logic                        d_bank_2_wbuf_req_ready    ,
    output wbuf_req_t                   d_bank_2_wbuf_req          ,
    input  logic         [255: 0]       d_bank_2_wbuf_rsp_free_id

    output logic                        d_bank_3_wbuf_req_valid    ,
    input  logic                        d_bank_3_wbuf_req_ready    ,
    output wbuf_req_t                   d_bank_3_wbuf_req          ,
    input  logic         [255: 0]       d_bank_3_wbuf_rsp_free_id  ,

    input  logic                        d_bank_0_rc_rsp_valid      ,
    output logic                        d_bank_0_rc_rsp_ready      ,
    input  logic         [127: 0]       d_bank_0_rc_rsp_data       ,
    input  robWidth_t                   d_bank_0_rc_rsp_rob_id     ,
    input  logic         [  1: 0]       d_bank_0_rc_rsp_channel_id ,
    
    input  logic                        d_bank_1_rc_rsp_valid      ,
    output logic                        d_bank_1_rc_rsp_ready      ,
    input  logic         [127: 0]       d_bank_1_rc_rsp_data       ,
    input  robWidth_t                   d_bank_1_rc_rsp_rob_id     ,
    input  logic         [  1: 0]       d_bank_1_rc_rsp_channel_id ,

    input  logic                        d_bank_2_rc_rsp_valid      ,
    output logic                        d_bank_2_rc_rsp_ready      ,
    input  logic         [127: 0]       d_bank_2_rc_rsp_data       ,
    input  robWidth_t                   d_bank_2_rc_rsp_rob_id     ,
    input  logic         [  1: 0]       d_bank_2_rc_rsp_channel_id ,

    input  logic                        d_bank_3_rc_rsp_valid      ,
    output logic                        d_bank_3_rc_rsp_ready      ,
    input  logic         [127: 0]       d_bank_3_rc_rsp_data       ,
    input  robWidth_t                   d_bank_3_rc_rsp_rob_id     ,
    input  logic         [  1: 0]       d_bank_3_rc_rsp_channel_id 

);

logic       d_bank_0_req_valid                                     ;
logic       d_bank_0_req_ready                                     ;
bank_req_t  d_bank_0_req                                           ;
logic       d_bank_1_req_valid                                     ;
logic       d_bank_1_req_ready                                     ;
bank_req_t  d_bank_1_req                                           ;
logic       d_bank_2_req_valid                                     ;
logic       d_bank_2_req_ready                                     ;
bank_req_t  d_bank_2_req                                           ;
logic       d_bank_3_req_valid                                     ;
logic       d_bank_3_req_ready                                     ;
bank_req_t  d_bank_3_req                                           ;


xbar_core u_xbar_core(
    .*
);



endmodule