module reference_counter 
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
    parameter type metaWidth_t     = logic
)
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  setWidth_t                   ref_cnt_set                ,
    output logic        [  2: 0]        ref_cnt_rsp  [Cfg.wayNum-1:0],

    input  logic                        ref_cnt_access_valid       ,
    input  setWidth_t                   ref_cnt_access_set         ,
    input  wayIndexWidth_t              ref_cnt_access_way         ,        

    input  logic                        d_isu_crdt_valid           ,
    input  nlineWidth_t                 d_isu_crdt_way_set           

);

localparam wayMSB       = Cfg.nlineWidth - 1;
localparam wayLSB       = Cfg.setWidth;
localparam setMSB       = Cfg.setWidth-1;
localparam setLSB       = 0;
localparam setNum       = 2 ** Cfg.setWidth;

logic [3-1:0]      ref_cnt      [Cfg.wayNum-1:0][setNum-1:0];
logic [3-1:0]      ref_cnt_nxt  [Cfg.wayNum-1:0][setNum-1:0];
logic              ref_cnt_incr [Cfg.wayNum-1:0][setNum-1:0];
logic              ref_cnt_decr [Cfg.wayNum-1:0][setNum-1:0];
logic              ref_cnt_en   [Cfg.wayNum-1:0][setNum-1:0];

wayIndexWidth_t    isu_crdt_way                                   ;
setWidth_t         isu_crdt_set                                   ;


assign isu_crdt_way = d_isu_crdt_way_set[wayMSB:wayLSB];
assign isu_crdt_set = d_isu_crdt_way_set[setMSB:setLSB];

generate
    for (genvar way_w = 0; way_w < int'(Cfg.wayNum); way_w++)
    begin : ref_cnt_way_gen
        for (genvar set_w = 0; set_w < setNum; set_w++)
        begin : ref_cnt_set_gen
            assign ref_cnt_incr[way_w][set_w] = ref_cnt_access_valid & ref_cnt_access_set == set_w & ref_cnt_access_way == way_w;
            assign ref_cnt_decr[way_w][set_w] = d_isu_crdt_valid & isu_crdt_set == set_w & isu_crdt_way == way_w;
            assign ref_cnt_en  [way_w][set_w] = ref_cnt_incr[way_w][set_w] | ref_cnt_decr[way_w][set_w];
            assign ref_cnt_nxt [way_w][set_w] = ref_cnt[way_w][set_w] + ref_cnt_incr[way_w][set_w] - ref_cnt_decr[way_w][set_w]; 
            ns_gnrl_dfflr # (3) ref_cnt_dfflr (ref_cnt_en[way_w][set_w], ref_cnt_nxt[way_w][set_w], ref_cnt[way_w][set_w], clk, rst_n);
        end    
    end
endgenerate

generate
    for (genvar way_w = 0; way_w < int'(Cfg.wayNum); way_w++)
    begin : ref_cnt_rsp_way_gen
        ns_gnrl_dfflr # (3) ref_cnt_rsp_dfflr (1'b1, ref_cnt[way_w][ref_cnt_set], ref_cnt_rsp[way_w], clk, rst_n);    
    end
endgenerate


endmodule