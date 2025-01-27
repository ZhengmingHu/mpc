module replacer 
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

    input  setWidth_t                   replace_set                ,
    input  metaWidth_t                  replace_meta [Cfg.wayNum-1:0],
    output wayNum_t                     replace_way_en             ,

    input  logic                        replace_access_valid       ,
    input  setWidth_t                   replace_access_set         ,
    input  wayIndexWidth_t              replace_access_way    

);

localparam setNum = 2 ** Cfg.setWidth;
localparam rightWayNum = 1 << (log2Ceil(Cfg.wayNum) - 1);
localparam leftWayNum  = Cfg.wayNum - rightWayNum;

logic [Cfg.wayNum-2:0] plru_tree     [setNum-1:0];
logic [Cfg.wayNum-2:0] plru_tree_nxt [setNum-1:0];

// Pseudo-LRU tree algorithm: https://en.wikipedia.org/wiki/Pseudo-LRU#Tree-PLRU
//
//
// - bits storage example for 4-way PLRU binary tree:
//                  bit[2]: ways 3+2 older than ways 1+0
//                  /                                  \
//     bit[1]: way 3 older than way 2    bit[0]: way 1 older than way 0
//
//
// - bits storage example for 3-way PLRU binary tree:
//                  bit[1]: way 2 older than ways 1+0
//                                                  \
//                                       bit[0]: way 1 older than way 0
//
//
// - bits storage example for 8-way PLRU binary tree:
//                      bit[6]: ways 7-4 older than ways 3-0
//                      /                                  \
//            bit[5]: ways 7+6 > 5+4                bit[2]: ways 3+2 > 1+0
//            /                    \                /                    \
//     bit[4]: way 7>6    bit[3]: way 5>4    bit[1]: way 3>2    bit[0]: way 1>0


generate
    if (Cfg.wayNum == 8) begin
        for (genvar i = 0; i < setNum; i++)
        begin : plru_tree_touch_set
            plru_tree_nxt[i] = replace_access_valid & replace_access_set == i ? 
                               replace_access_way[0] ? {1'b1, plru_tree[i][5], plru_tree[i][4], plru_tree[i][3], 1'b1, plru_tree[i][1], 1'b1} :
                               replace_access_way[1] ? {1'b1, plru_tree[i][5], plru_tree[i][4], plru_tree[i][3], 1'b1, plru_tree[i][1], 1'b0} :
                               replace_access_way[2] ? {1'b1, plru_tree[i][5], plru_tree[i][4], plru_tree[i][3], 1'b0, 1'b1, plru_tree[i][0]} :
                               replace_access_way[3] ? {1'b1, plru_tree[i][5], plru_tree[i][4], plru_tree[i][3], 1'b0, 1'b0, plru_tree[i][0]} :
                               replace_access_way[4] ?
                               replace_access_way[5] ?
                               replace_access_way[6] ?
                               replace_access_way[7] ? 
        end
    end
    else if (Cfg.wayNum == 4) begin
    end 
    else

endgenerate


endmodule