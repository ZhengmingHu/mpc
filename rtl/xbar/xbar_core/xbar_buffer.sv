module xbar_buffer
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
    parameter type channel_req_t   = logic
)
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        u_channel_0_req_valid      ,
    input  logic                        u_channel_0_req_ready      ,
    input  channel_req_t                u_channel_0_req            ,

    input  logic                        u_channel_1_req_valid      ,
    input  logic                        u_channel_1_req_ready      ,
    input  channel_req_t                u_channel_1_req            ,

    input  logic                        u_channel_2_req_valid      ,
    input  logic                        u_channel_2_req_ready      ,
    input  channel_req_t                u_channel_2_req            ,

    input  logic           [  2: 0]     ch_0_w_ptr                 ,
    input  logic           [  2: 0]     ch_1_w_ptr                 ,
    input  logic           [  2: 0]     ch_2_w_ptr                 ,

    input  logic           [  2: 0]     bank_0_ch_1hot_id          ,
    input  logic           [  2: 0]     bank_1_ch_1hot_id          ,
    input  logic           [  2: 0]     bank_2_ch_1hot_id          ,
    input  logic           [  2: 0]     bank_3_ch_1hot_id          ,
 
    input  logic           [  7: 0]     ch_0_bank_0_r_entry_1hot_id,
    input  logic           [  7: 0]     ch_0_bank_1_r_entry_1hot_id,
    input  logic           [  7: 0]     ch_0_bank_2_r_entry_1hot_id,
    input  logic           [  7: 0]     ch_0_bank_3_r_entry_1hot_id,

    input  logic           [  7: 0]     ch_1_bank_0_r_entry_1hot_id,
    input  logic           [  7: 0]     ch_1_bank_1_r_entry_1hot_id,
    input  logic           [  7: 0]     ch_1_bank_2_r_entry_1hot_id,
    input  logic           [  7: 0]     ch_1_bank_3_r_entry_1hot_id,

    input  logic           [  7: 0]     ch_2_bank_0_r_entry_1hot_id,
    input  logic           [  7: 0]     ch_2_bank_1_r_entry_1hot_id,
    input  logic           [  7: 0]     ch_2_bank_2_r_entry_1hot_id,
    input  logic           [  7: 0]     ch_2_bank_3_r_entry_1hot_id,

    output channel_req_t                d_bank_0_ch_req            ,
    output channel_req_t                d_bank_1_ch_req            ,
    output channel_req_t                d_bank_2_ch_req            ,
    output channel_req_t                d_bank_3_ch_req            
);

logic u_ch_2_req_hsked, u_ch_1_req_hsked, u_ch_0_req_hsked;

logic          [  2: 0] u_ch_req_hsked                          ;
channel_req_t           u_ch_req                    [  2: 0]    ;

logic          [  2: 0] ch_w_entry_id               [  2: 0]    ;

logic          [  7: 0] ch_r_entry_bank_0_1hot_id   [  2: 0]    ;
logic          [  7: 0] ch_r_entry_bank_1_1hot_id   [  2: 0]    ;
logic          [  7: 0] ch_r_entry_bank_2_1hot_id   [  2: 0]    ;
logic          [  7: 0] ch_r_entry_bank_3_1hot_id   [  2: 0]    ;

channel_req_t           bank_0_req                  [  2: 0]    ;
channel_req_t           bank_1_req                  [  2: 0]    ;
channel_req_t           bank_2_req                  [  2: 0]    ;
channel_req_t           bank_3_req                  [  2: 0]    ;

assign u_ch_0_req_hsked = u_channel_0_req_valid & u_channel_0_req_ready;
assign u_ch_1_req_hsked = u_channel_1_req_valid & u_channel_1_req_ready;
assign u_ch_2_req_hsked = u_channel_2_req_valid & u_channel_2_req_ready;

assign u_ch_req_hsked    = {u_ch_2_req_hsked, u_ch_1_req_hsked, u_ch_0_req_hsked};
assign u_ch_req[0]       = u_channel_0_req;
assign u_ch_req[1]       = u_channel_1_req;
assign u_ch_req[2]       = u_channel_2_req;

assign ch_w_entry_id[0]  = ch_0_w_ptr;
assign ch_w_entry_id[1]  = ch_1_w_ptr;
assign ch_w_entry_id[2]  = ch_2_w_ptr;

assign ch_r_entry_bank_0_1hot_id[0] = ch_0_bank_0_r_entry_1hot_id;
assign ch_r_entry_bank_1_1hot_id[0] = ch_0_bank_1_r_entry_1hot_id;
assign ch_r_entry_bank_2_1hot_id[0] = ch_0_bank_2_r_entry_1hot_id;
assign ch_r_entry_bank_3_1hot_id[0] = ch_0_bank_3_r_entry_1hot_id;

assign ch_r_entry_bank_0_1hot_id[1] = ch_1_bank_0_r_entry_1hot_id;
assign ch_r_entry_bank_1_1hot_id[1] = ch_1_bank_1_r_entry_1hot_id;
assign ch_r_entry_bank_2_1hot_id[1] = ch_1_bank_2_r_entry_1hot_id;
assign ch_r_entry_bank_3_1hot_id[1] = ch_1_bank_3_r_entry_1hot_id;

assign ch_r_entry_bank_0_1hot_id[2] = ch_2_bank_0_r_entry_1hot_id;
assign ch_r_entry_bank_1_1hot_id[2] = ch_2_bank_1_r_entry_1hot_id;
assign ch_r_entry_bank_2_1hot_id[2] = ch_2_bank_2_r_entry_1hot_id;
assign ch_r_entry_bank_3_1hot_id[2] = ch_2_bank_3_r_entry_1hot_id;

generate
    for (genvar i = 0; i < 3; i++)
    begin : xbar_sub_buffer_gen
        xbar_sub_buffer # (    
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
        u_xbar_sub_buffer (
            .clk                                (clk                            ),
            .rst_n                              (rst_n                          ),
            .u_ch_req_hsked                     (u_ch_req_hsked[i]              ),
            .u_ch_req                           (u_ch_req[i]                    ),
            .w_entry_id                         (ch_w_entry_id[i]               ),
            .bank_0_r_entry_1hot_id             (ch_r_entry_bank_0_1hot_id[i]   ),
            .bank_1_r_entry_1hot_id             (ch_r_entry_bank_1_1hot_id[i]   ),
            .bank_2_r_entry_1hot_id             (ch_r_entry_bank_2_1hot_id[i]   ),
            .bank_3_r_entry_1hot_id             (ch_r_entry_bank_3_1hot_id[i]   ),
            .d_bank_0_req                       (bank_0_req[i]                  ),
            .d_bank_1_req                       (bank_1_req[i]                  ),
            .d_bank_2_req                       (bank_2_req[i]                  ),
            .d_bank_3_req                       (bank_3_req[i]                  ),
            .*
        );
    end 
endgenerate

assign d_bank_0_ch_req = bank_0_ch_1hot_id[0] ? bank_0_req[0] :
                         bank_0_ch_1hot_id[1] ? bank_0_req[1] :
                         bank_0_ch_1hot_id[2] ? bank_0_req[2] : '0;

assign d_bank_1_ch_req = bank_1_ch_1hot_id[0] ? bank_1_req[0] :
                         bank_1_ch_1hot_id[1] ? bank_1_req[1] :
                         bank_1_ch_1hot_id[2] ? bank_1_req[2] : '0;

assign d_bank_2_ch_req = bank_2_ch_1hot_id[0] ? bank_2_req[0] :
                         bank_2_ch_1hot_id[1] ? bank_2_req[1] :
                         bank_2_ch_1hot_id[2] ? bank_2_req[2] : '0;

assign d_bank_3_ch_req = bank_3_ch_1hot_id[0] ? bank_3_req[0] :
                         bank_3_ch_1hot_id[1] ? bank_3_req[1] :
                         bank_3_ch_1hot_id[2] ? bank_3_req[2] : '0;

                

endmodule

module xbar_sub_buffer
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
    parameter type channel_req_t   = logic
) 
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        u_ch_req_hsked             ,
    input  channel_req_t                u_ch_req                   ,

    input  logic           [  2: 0]     w_entry_id                 ,
    
    input  logic           [  7: 0]     bank_0_r_entry_1hot_id     ,
    input  logic           [  7: 0]     bank_1_r_entry_1hot_id     ,
    input  logic           [  7: 0]     bank_2_r_entry_1hot_id     ,
    input  logic           [  7: 0]     bank_3_r_entry_1hot_id     ,

    output channel_req_t                d_bank_0_req               ,
    output channel_req_t                d_bank_1_req               ,
    output channel_req_t                d_bank_2_req               ,
    output channel_req_t                d_bank_3_req               

);

channel_req_t              req_entry         [  7: 0]  ;
channel_req_t              req_entry_nxt               ;
logic          [  7: 0]    req_entry_wen               ;

logic          [  2: 0]    bank_0_r_entry_id           ;
logic          [  2: 0]    bank_1_r_entry_id           ;
logic          [  2: 0]    bank_2_r_entry_id           ;
logic          [  2: 0]    bank_3_r_entry_id           ;

assign req_entry_nxt = u_ch_req;

generate
    for (genvar i = 0; i < 8; i++) 
    begin : entry_wen_gen
        assign req_entry_wen[i] = w_entry_id == i & u_ch_req_hsked;
    end
endgenerate

generate
    for (genvar i = 0; i < 8; i++) 
    begin : req_entry_gen
        ns_gnrl_dfflr # (3+32+128) req_entry_dfflr (req_entry_wen[i], u_ch_req, req_entry[i], clk, rst_n);
    end
endgenerate

ns_1hot2bin #(8) ns_1hot2bin_bank_0 (bank_0_r_entry_1hot_id, bank_0_r_entry_id);
ns_1hot2bin #(8) ns_1hot2bin_bank_1 (bank_1_r_entry_1hot_id, bank_1_r_entry_id);
ns_1hot2bin #(8) ns_1hot2bin_bank_2 (bank_2_r_entry_1hot_id, bank_2_r_entry_id);
ns_1hot2bin #(8) ns_1hot2bin_bank_3 (bank_3_r_entry_1hot_id, bank_3_r_entry_id);

assign d_bank_0_req = req_entry[bank_0_r_entry_id];
assign d_bank_1_req = req_entry[bank_1_r_entry_id];
assign d_bank_2_req = req_entry[bank_2_r_entry_id];
assign d_bank_3_req = req_entry[bank_3_r_entry_id];

endmodule