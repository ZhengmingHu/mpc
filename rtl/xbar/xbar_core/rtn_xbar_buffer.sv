module rtn_xbar_buffer
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
    input  logic                        d_bank_0_rsp_ready         ,
    input  logic           [127: 0]     d_bank_0_rsp_data          ,
    input  logic           [  1: 0]     d_bank_0_rsp_channel_id    ,
    input  robWidth_t                   d_bank_0_rsp_rob_id        ,

    input  logic                        d_bank_1_rsp_valid         ,
    input  logic                        d_bank_1_rsp_ready         ,
    input  logic           [127: 0]     d_bank_1_rsp_data          ,
    input  logic           [  1: 0]     d_bank_1_rsp_channel_id    ,
    input  robWidth_t                   d_bank_1_rsp_rob_id        ,

    input  logic                        d_bank_2_rsp_valid         ,
    input  logic                        d_bank_2_rsp_ready         ,
    input  logic           [127: 0]     d_bank_2_rsp_data          ,
    input  logic           [  1: 0]     d_bank_2_rsp_channel_id    ,
    input  robWidth_t                   d_bank_2_rsp_rob_id        ,

    input  logic                        d_bank_3_rsp_valid         ,
    input  logic                        d_bank_3_rsp_ready         ,
    input  logic           [127: 0]     d_bank_3_rsp_data          ,
    input  logic           [  1: 0]     d_bank_3_rsp_channel_id    ,
    input  robWidth_t                   d_bank_3_rsp_rob_id        ,

    input  logic           [  2: 0]     bank_0_w_ptr               ,
    input  logic           [  2: 0]     bank_1_w_ptr               ,
    input  logic           [  2: 0]     bank_2_w_ptr               ,
    input  logic           [  2: 0]     bank_3_w_ptr               ,

    input  logic           [  3: 0]     ch_0_bank_1hot_id          ,
    input  logic           [  3: 0]     ch_1_bank_1hot_id          ,
    input  logic           [  3: 0]     ch_2_bank_1hot_id          ,
 
    input  logic           [  7: 0]     bank_0_ch_0_r_entry_1hot_id,
    input  logic           [  7: 0]     bank_0_ch_1_r_entry_1hot_id,
    input  logic           [  7: 0]     bank_0_ch_2_r_entry_1hot_id,
    
    input  logic           [  7: 0]     bank_1_ch_0_r_entry_1hot_id,
    input  logic           [  7: 0]     bank_1_ch_1_r_entry_1hot_id,
    input  logic           [  7: 0]     bank_1_ch_2_r_entry_1hot_id,

    input  logic           [  7: 0]     bank_2_ch_0_r_entry_1hot_id,
    input  logic           [  7: 0]     bank_2_ch_1_r_entry_1hot_id,
    input  logic           [  7: 0]     bank_2_ch_2_r_entry_1hot_id,

    input  logic           [  7: 0]     bank_3_ch_0_r_entry_1hot_id,
    input  logic           [  7: 0]     bank_3_ch_1_r_entry_1hot_id,
    input  logic           [  7: 0]     bank_3_ch_2_r_entry_1hot_id,

    output logic           [127: 0]     u_ch_0_bank_rsp_data       ,
    output robWidth_t                   u_ch_0_bank_rsp_rob_id     ,
    output logic           [127: 0]     u_ch_1_bank_rsp_data       ,
    output robWidth_t                   u_ch_1_bank_rsp_rob_id     ,
    output logic           [127: 0]     u_ch_2_bank_rsp_data       ,
    output robWidth_t                   u_ch_2_bank_rsp_rob_id
);

logic d_bank_3_rsp_hsked, d_bank_2_rsp_hsked, d_bank_1_rsp_hsked, d_bank_0_rsp_hsked;

logic          [  3: 0] d_bank_rsp_hsked                        ;
logic          [127: 0] d_bank_rsp_data             [  3: 0]    ;
robWidth_t              d_bank_rsp_rob_id           [  3: 0]    ;

logic          [  2: 0] bank_w_entry_id             [  3: 0]    ;

logic          [  7: 0] bank_r_entry_ch_0_1hot_id   [  3: 0]    ;
logic          [  7: 0] bank_r_entry_ch_1_1hot_id   [  3: 0]    ;
logic          [  7: 0] bank_r_entry_ch_2_1hot_id   [  3: 0]    ;

logic          [127: 0] ch_0_rsp_data               [  3: 0]    ;
logic          [127: 0] ch_1_rsp_data               [  3: 0]    ;
logic          [127: 0] ch_2_rsp_data               [  3: 0]    ;

robWidth_t              ch_0_rsp_rob_id             [  3: 0]    ;
robWidth_t              ch_1_rsp_rob_id             [  3: 0]    ;
robWidth_t              ch_2_rsp_rob_id             [  3: 0]    ;

assign d_bank_0_rsp_hsked = d_bank_0_rsp_valid & d_bank_0_rsp_ready;
assign d_bank_1_rsp_hsked = d_bank_1_rsp_valid & d_bank_1_rsp_ready;
assign d_bank_2_rsp_hsked = d_bank_2_rsp_valid & d_bank_2_rsp_ready;
assign d_bank_3_rsp_hsked = d_bank_3_rsp_valid & d_bank_3_rsp_ready;

assign d_bank_rsp_hsked  = {d_bank_3_rsp_hsked, d_bank_2_rsp_hsked, d_bank_1_rsp_hsked, d_bank_0_rsp_hsked};
assign d_bank_rsp_data[0] = d_bank_0_rsp_data;
assign d_bank_rsp_data[1] = d_bank_1_rsp_data;
assign d_bank_rsp_data[2] = d_bank_2_rsp_data;
assign d_bank_rsp_data[3] = d_bank_3_rsp_data;
assign d_bank_rsp_rob_id[0] = d_bank_0_rsp_rob_id;
assign d_bank_rsp_rob_id[1] = d_bank_1_rsp_rob_id;
assign d_bank_rsp_rob_id[2] = d_bank_2_rsp_rob_id;
assign d_bank_rsp_rob_id[3] = d_bank_3_rsp_rob_id;
assign bank_w_entry_id[0]  = bank_0_w_ptr;
assign bank_w_entry_id[1]  = bank_1_w_ptr;
assign bank_w_entry_id[2]  = bank_2_w_ptr;
assign bank_w_entry_id[3]  = bank_3_w_ptr;

assign bank_r_entry_ch_0_1hot_id[0] = bank_0_ch_0_r_entry_1hot_id;
assign bank_r_entry_ch_1_1hot_id[0] = bank_0_ch_1_r_entry_1hot_id;
assign bank_r_entry_ch_2_1hot_id[0] = bank_0_ch_2_r_entry_1hot_id;

assign bank_r_entry_ch_0_1hot_id[1] = bank_1_ch_0_r_entry_1hot_id;
assign bank_r_entry_ch_1_1hot_id[1] = bank_1_ch_1_r_entry_1hot_id;
assign bank_r_entry_ch_2_1hot_id[1] = bank_1_ch_2_r_entry_1hot_id;

assign bank_r_entry_ch_0_1hot_id[2] = bank_2_ch_0_r_entry_1hot_id;
assign bank_r_entry_ch_1_1hot_id[2] = bank_2_ch_1_r_entry_1hot_id;
assign bank_r_entry_ch_2_1hot_id[2] = bank_2_ch_2_r_entry_1hot_id;

assign bank_r_entry_ch_0_1hot_id[3] = bank_3_ch_0_r_entry_1hot_id;
assign bank_r_entry_ch_1_1hot_id[3] = bank_3_ch_1_r_entry_1hot_id;
assign bank_r_entry_ch_2_1hot_id[3] = bank_3_ch_2_r_entry_1hot_id;

generate
    for (genvar i = 0; i < 4; i++)
    begin : xbar_sub_buffer_gen
        rtn_xbar_sub_buffer # (
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
        ) u_xbar_sub_buffer (
            .clk                               (clk                                ),
            .rst_n                             (rst_n                              ),
            .d_bank_rsp_hsked                  (d_bank_rsp_hsked[i]                ),
            .d_bank_rsp_data                   (d_bank_rsp_data[i]                 ),
            .d_bank_rsp_rob_id                 (d_bank_rsp_rob_id[i]               ),
            .w_entry_id                        (bank_w_entry_id[i]                 ),
            .ch_0_r_entry_1hot_id              (bank_r_entry_ch_0_1hot_id[i]       ),
            .ch_1_r_entry_1hot_id              (bank_r_entry_ch_1_1hot_id[i]       ),
            .ch_2_r_entry_1hot_id              (bank_r_entry_ch_2_1hot_id[i]       ),
            .u_ch_0_rsp_data                   (ch_0_rsp_data[i]                   ),
            .u_ch_1_rsp_data                   (ch_1_rsp_data[i]                   ),
            .u_ch_2_rsp_data                   (ch_2_rsp_data[i]                   ),
            .u_ch_0_rsp_rob_id                 (ch_0_rsp_rob_id[i]                 ),
            .u_ch_1_rsp_rob_id                 (ch_1_rsp_rob_id[i]                 ),
            .u_ch_2_rsp_rob_id                 (ch_2_rsp_rob_id[i]                 ),
            .*
        );
    end 
endgenerate

assign u_ch_0_bank_rsp_data = ch_0_bank_1hot_id[0] ? ch_0_rsp_data[0] :
                              ch_0_bank_1hot_id[1] ? ch_0_rsp_data[1] :
                              ch_0_bank_1hot_id[2] ? ch_0_rsp_data[2] :
                              ch_0_bank_1hot_id[3] ? ch_0_rsp_data[3] : '0;

assign u_ch_1_bank_rsp_data = ch_1_bank_1hot_id[0] ? ch_1_rsp_data[0] :
                              ch_1_bank_1hot_id[1] ? ch_1_rsp_data[1] :
                              ch_1_bank_1hot_id[2] ? ch_1_rsp_data[2] :
                              ch_1_bank_1hot_id[3] ? ch_1_rsp_data[3] : '0;

assign u_ch_2_bank_rsp_data = ch_2_bank_1hot_id[0] ? ch_2_rsp_data[0] :
                              ch_2_bank_1hot_id[1] ? ch_2_rsp_data[1] :
                              ch_2_bank_1hot_id[2] ? ch_2_rsp_data[2] :
                              ch_2_bank_1hot_id[3] ? ch_2_rsp_data[3] : '0;

assign u_ch_0_bank_rsp_rob_id = ch_0_bank_1hot_id[0] ? ch_0_rsp_rob_id[0] :
                                ch_0_bank_1hot_id[1] ? ch_0_rsp_rob_id[1] :
                                ch_0_bank_1hot_id[2] ? ch_0_rsp_rob_id[2] :
                                ch_0_bank_1hot_id[3] ? ch_0_rsp_rob_id[3] :'0;

assign u_ch_1_bank_rsp_rob_id = ch_1_bank_1hot_id[0] ? ch_1_rsp_rob_id[0] :
                                ch_1_bank_1hot_id[1] ? ch_1_rsp_rob_id[1] :
                                ch_1_bank_1hot_id[2] ? ch_1_rsp_rob_id[2] :
                                ch_1_bank_1hot_id[3] ? ch_1_rsp_rob_id[3] : '0;

assign u_ch_2_bank_rsp_rob_id = ch_2_bank_1hot_id[0] ? ch_2_rsp_rob_id[0] :
                                ch_2_bank_1hot_id[1] ? ch_2_rsp_rob_id[1] :
                                ch_2_bank_1hot_id[2] ? ch_2_rsp_rob_id[2] :
                                ch_2_bank_1hot_id[3] ? ch_2_rsp_rob_id[3] : '0; 

endmodule

module rtn_xbar_sub_buffer
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

    input  logic                        d_bank_rsp_hsked           ,
    input  logic           [127: 0]     d_bank_rsp_data            ,
    input  robWidth_t                   d_bank_rsp_rob_id          ,

    input  logic           [  2: 0]     w_entry_id                 ,
    
    input  logic           [  7: 0]     ch_0_r_entry_1hot_id       ,
    input  logic           [  7: 0]     ch_1_r_entry_1hot_id       ,
    input  logic           [  7: 0]     ch_2_r_entry_1hot_id       ,

    output logic           [127: 0]     u_ch_0_rsp_data            ,
    output logic           [127: 0]     u_ch_1_rsp_data            ,
    output logic           [127: 0]     u_ch_2_rsp_data            ,

    output robWidth_t                   u_ch_0_rsp_rob_id          ,
    output robWidth_t                   u_ch_1_rsp_rob_id          ,
    output robWidth_t                   u_ch_2_rsp_rob_id         

);

logic          [127: 0]    rsp_data_entry         [  7: 0]  ;
logic          [127: 0]    rsp_data_entry_nxt               ;
logic          [  7: 0]    rsp_entry_wen                    ;

robWidth_t                 rsp_rob_id_entry         [  7: 0];
robWidth_t                 rsp_rob_id_entry_nxt             ;

logic          [  2: 0]    ch_0_r_entry_id             ;
logic          [  2: 0]    ch_1_r_entry_id             ;
logic          [  2: 0]    ch_2_r_entry_id             ;

assign rsp_data_entry_nxt = d_bank_rsp_data;
assign rsp_rob_id_entry_nxt = d_bank_rsp_rob_id;


generate
    for (genvar i = 0; i < 8; i++) 
    begin : entry_wen_gen
        assign rsp_entry_wen[i] = w_entry_id == i & d_bank_rsp_hsked;
    end
endgenerate

generate
    for (genvar i = 0; i < 8; i++) 
    begin : rsp_entry_gen
        ns_gnrl_dfflr # (128) rsp_data_entry_dfflr (rsp_entry_wen[i], rsp_data_entry_nxt, rsp_data_entry[i], clk, rst_n);
        ns_gnrl_dfflr # (Cfg.robWidth) rsp_rob_id_entry_dfflr (rsp_entry_wen[i], rsp_rob_id_entry_nxt, rsp_rob_id_entry[i], clk, rst_n);
    end
endgenerate

ns_1hot2bin #(8) ns_1hot2bin_rsp_0 (ch_0_r_entry_1hot_id, ch_0_r_entry_id);
ns_1hot2bin #(8) ns_1hot2bin_rsp_1 (ch_1_r_entry_1hot_id, ch_1_r_entry_id);
ns_1hot2bin #(8) ns_1hot2bin_rsp_2 (ch_2_r_entry_1hot_id, ch_2_r_entry_id);

assign u_ch_0_rsp_data = rsp_data_entry[ch_0_r_entry_id];
assign u_ch_1_rsp_data = rsp_data_entry[ch_1_r_entry_id];
assign u_ch_2_rsp_data = rsp_data_entry[ch_2_r_entry_id];

assign u_ch_0_rsp_rob_id = rsp_rob_id_entry[ch_0_r_entry_id];
assign u_ch_1_rsp_rob_id = rsp_rob_id_entry[ch_1_r_entry_id];
assign u_ch_2_rsp_rob_id = rsp_rob_id_entry[ch_2_r_entry_id];



endmodule