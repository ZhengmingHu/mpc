module reference_counter 
 import mpc_types::*;

    localparam mpc_user_cfg_t UserCfg = '{
        clWidth:256,
        clWordWidth:128,
        sets:8,
        banks:4,
        ways:4,
        kobSize:16,
        wbufSize:128
    },

    localparam mpc_cfg_t Cfg = mpcBuildConfig(UserCfg),
   
    localparam type setWidth_t      = logic [Cfg.setWidth-1:0],
    localparam type tagWidth_t      = logic [Cfg.tagWidth-1:0],
    localparam type wayIndexWidth_t = logic [Cfg.wayIndexWidth-1:0],
    localparam type wbufWidth_t     = logic [Cfg.wbufWidth-1:0],
    localparam type wayNum_t        = logic [Cfg.wayNum-1:0],
    localparam type nlineWidth_t    = logic [Cfg.nlineWidth-1:0],
    localparam type offsetWidth_t   = logic [Cfg.offsetWidth-1:0],
    localparam type metaWidth_t     = logic [Cfg.metaWidth-1:0],

(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  setWidth_t                   ref_cnt_set                ,
    output logic        [  2: 0]        ref_cnt_rsp  [Cfg.wayNum-1:0],

    input  logic                        ref_cnt_access_valid       ,
    input  setWidth_t                   ref_cnt_access_set         ,
    input  wayIndexWidth_t              ref_cnt_access_way         ,        

    input  logic                        isu_crdt_valid             ,
    input  nlineWidth_t                 isu_crdt_way_set           

);

localparam wayMSB       = Cfg.nlineWidth - 1;
localparam wayLSB       = Cfg.setWidth;
localparam setMSB       = Cfg.setWidth-1;
localparam setLSB       = 0;
localparam setNum       = 2 ** Cfg.setWidth;

logic [3-1:0]      ref_cnt      [Cfg.wayNum-1:0][Cfg.setWidth-1:0];
logic [3-1:0]      ref_cnt_nxt  [Cfg.wayNum-1:0][Cfg.setWidth-1:0];
logic              ref_cnt_incr [Cfg.wayNum-1:0][Cfg.setWidth-1:0];
logic              ref_cnt_decr [Cfg.wayNum-1:0][Cfg.setWidth-1:0];
logic              ref_cnt_en   [Cfg.wayNum-1:0][Cfg.setWidth-1:0];

wayIndexWidth_t    isu_crdt_way                                   ;
setWidth_t         isu_crdt_set                                   ;


assign isu_crdt_way = isu_crdt_way_set[wayMSB:wayLSB];
assign isu_crdt_set = isu_crdt_way_set[setMSB:setLSB];

generate
    for (genvar way_w = 0; way_w < int'(Cfg.wayNum); way_w++)
    begin : ref_cnt_way_gen
        for (genvar set_w = 0; set_w < setNum; set_w++)
        begin : ref_cnt_set_gen
            assign ref_cnt_incr[way_w][set_w] = ref_cnt_access_valid & ref_cnt_access_set == set_w & ref_cnt_access_way == way_w;
            assign ref_cnt_decr[way_w][set_w] = isu_crdt_valid & isu_crdt_set == set_w & isu_crdt_way == way_w;
            assign ref_cnt_en  [way_w][set_w] = ref_cnt_incr[way_w][set_w] | ref_cnt_decr[way_w][set_w];
            assign ref_cnt_nxt [way_w][set_w] = ref_cnt[way_w][set_w] + ref_cnt_incr[way_w][set_w] - ref_cnt_decr[way_w][set_w]; 
            ns_gnrl_dfflr # (3) ref_cnt_dfflr (ref_cnt_en[way_w][set_w], ref_cnt_nxt[way_w][set_w], ref_cnt[way_w][set_w], clk, rst_n);
        end    
    end
endgenerate

generate
    for (genvar way_w = 0; way_w < int'(Cfg.wayNum); way_w++)
    begin : ref_cnt_way_gen
        ns_gnrl_dfflr # (3) ref_cnt_rsp_dfflr (1'b1, ref_cnt[way_w][ref_cnt_set], ref_cnt_rsp[way_w], clk, rst_n);    
    end
endgenerate


endmodule