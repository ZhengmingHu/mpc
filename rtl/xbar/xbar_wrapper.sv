module xbar_wrapper
    import mpc_types::*;
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
    input  rc_rsp_t                     d_bank_0_rc_rsp            ,
    
    input  logic                        d_bank_1_rc_rsp_valid      ,
    output logic                        d_bank_1_rc_rsp_ready      ,
    input  rc_rsp_t                     d_bank_1_rc_rsp            ,

    input  logic                        d_bank_2_rc_rsp_valid      ,
    output logic                        d_bank_2_rc_rsp_ready      ,
    input  rc_rsp_t                     d_bank_2_rc_rsp            ,

    input  logic                        d_bank_3_rc_rsp_valid      ,
    output logic                        d_bank_3_rc_rsp_ready      ,
    input  rc_rsp_t                     d_bank_3_rc_rsp            

);



endmodule