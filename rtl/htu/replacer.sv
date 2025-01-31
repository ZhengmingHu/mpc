module replacer 
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

    input  setWidth_t                   replace_set                ,
    input  metaWidth_t                  replace_meta [Cfg.wayNum-1:0],
    output wayIndexWidth_t              replace_way                ,

    input  logic                        replace_access_valid       ,
    input  setWidth_t                   replace_access_set         ,
    input  wayIndexWidth_t              replace_access_way    

);

localparam setNum = 1 << Cfg.setWidth;
localparam wayIdx = Cfg.wayIndexWidth;

logic [Cfg.wayNum-2:0] plru_tree     [setNum-1:0];
logic [Cfg.wayNum-2:0] plru_tree_nxt [setNum-1:0];
logic [    setNum-1:0] plru_tree_en              ;
wayIndexWidth_t        replace_way_nxt           ;
wayNum_t               way_is_valid              ;
logic                  all_way_valid             ;

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
    if (int'(Cfg.wayNum) == 8) begin
        for (genvar i = 0; i < setNum; i++)
        begin : plru_tree_touch_set_8_way
            assign plru_tree_nxt[i] = replace_access_valid & replace_access_set == i ? 
                                      replace_access_way == 'd0 ? {1'b1, plru_tree[i][5], plru_tree[i][4], plru_tree[i][3], 1'b1, plru_tree[i][1], 1'b1} :
                                      replace_access_way == 'd1 ? {1'b1, plru_tree[i][5], plru_tree[i][4], plru_tree[i][3], 1'b1, plru_tree[i][1], 1'b0} :
                                      replace_access_way == 'd2 ? {1'b1, plru_tree[i][5], plru_tree[i][4], plru_tree[i][3], 1'b0, 1'b1, plru_tree[i][0]} :
                                      replace_access_way == 'd3 ? {1'b1, plru_tree[i][5], plru_tree[i][4], plru_tree[i][3], 1'b0, 1'b0, plru_tree[i][0]} :
                                      replace_access_way == 'd4 ? {1'b0, 1'b1, plru_tree[i][4], 1'b1, plru_tree[i][2], plru_tree[i][1], plru_tree[i][0]} :
                                      replace_access_way == 'd5 ? {1'b0, 1'b1, plru_tree[i][4], 1'b0, plru_tree[i][2], plru_tree[i][1], plru_tree[i][0]} :
                                      replace_access_way == 'd6 ? {1'b0, 1'b0, 1'b1, plru_tree[i][3], plru_tree[i][2], plru_tree[i][1], plru_tree[i][0]} :
                                      replace_access_way == 'd7 ? {1'b0, 1'b0, 1'b0, plru_tree[i][3], plru_tree[i][2], plru_tree[i][1], plru_tree[i][0]} : plru_tree[i] : plru_tree[i];
            assign plru_tree_en[i]  = replace_access_valid & replace_access_set == i;
            ns_gnrl_dfflr # (Cfg.wayNum-1) plru_tree_dfflr (plru_tree_en[i], plru_tree_nxt[i], plru_tree[i], clk, rst_n);
        end
    end
    else if (int'(Cfg.wayNum) == 4) begin
        for (genvar i = 0; i < setNum; i++)
        begin : plru_tree_touch_set_4_way
            assign plru_tree_nxt[i] = replace_access_valid & replace_access_set == i ? 
                                      replace_access_way == 'd0 ? {1'b1, plru_tree[i][1], 1'b1} :
                                      replace_access_way == 'd1 ? {1'b1, plru_tree[i][1], 1'b0} :
                                      replace_access_way == 'd2 ? {1'b0, 1'b1, plru_tree[i][0]} :
                                      replace_access_way == 'd3 ? {1'b0, 1'b0, plru_tree[i][0]} :
                                      plru_tree[i] : plru_tree[i];
            assign plru_tree_en[i]  = replace_access_valid & replace_access_set == i;
            ns_gnrl_dfflr # (Cfg.wayNum-1) plru_tree_dfflr (plru_tree_en[i], plru_tree_nxt[i], plru_tree[i], clk, rst_n);
        end
    end 
    else begin
        for (genvar i = 0; i < setNum; i++)
        begin : plru_tree_touch_set_2_way
            assign plru_tree_nxt[i] = (plru_tree[i] + 1) << plru_tree[i];
            assign plru_tree_en[i]  = replace_access_valid & replace_access_set == i;
            ns_gnrl_dfflr # (Cfg.wayNum-1) plru_tree_dfflr (plru_tree_en[i], plru_tree_nxt[i], plru_tree[i], clk, rst_n);
        end
    end
endgenerate


generate
    for (genvar i = 0; i < int'(Cfg.wayNum); i++)
    begin
        assign way_is_valid[i] = !is_invalid(replace_meta[i]);
    end
endgenerate
assign all_way_valid = &way_is_valid;

generate
    if (int'(Cfg.wayNum)==8) begin
        always_comb begin
            replace_way_nxt = 'd0;
            if (!all_way_valid) begin
                for (int i = 0; i < int'(Cfg.wayNum); i++)
                begin
                    if (!way_is_valid[i]) begin
                        replace_way_nxt = i;
                        break;
                    end
                end
            end
            else begin
                if ({plru_tree[replace_set][6], plru_tree[replace_set][2], plru_tree[replace_set][0]} == 3'b000)
                    replace_way_nxt = 'd0;
                else if ({plru_tree[replace_set][6], plru_tree[replace_set][2], plru_tree[replace_set][0]} == 3'b001)
                    replace_way_nxt = 'd1;
                else if ({plru_tree[replace_set][6], plru_tree[replace_set][2], plru_tree[replace_set][1]} == 3'b010)
                    replace_way_nxt = 'd2;
                else if ({plru_tree[replace_set][6], plru_tree[replace_set][2], plru_tree[replace_set][1]} == 3'b011)
                    replace_way_nxt = 'd3;
                else if ({plru_tree[replace_set][6], plru_tree[replace_set][5], plru_tree[replace_set][3]} == 3'b100)
                    replace_way_nxt = 'd4;
                else if ({plru_tree[replace_set][6], plru_tree[replace_set][5], plru_tree[replace_set][3]} == 3'b101)
                    replace_way_nxt = 'd5;
                else if ({plru_tree[replace_set][6], plru_tree[replace_set][5], plru_tree[replace_set][4]} == 3'b110)
                    replace_way_nxt = 'd6;
                else if ({plru_tree[replace_set][6], plru_tree[replace_set][5], plru_tree[replace_set][4]} == 3'b111)
                    replace_way_nxt = 'd7;
            end 
        end
    end
    else if (int'(Cfg.wayNum) == 4) begin
        always_comb begin
            replace_way_nxt = 'd0;
            if (!all_way_valid) begin
                for (int i = 0; i < int'(Cfg.wayNum); i++)
                begin
                    if (!way_is_valid[i]) begin
                        replace_way_nxt = i;
                        break;
                    end
                end
            end
            else begin
                if ({plru_tree[replace_set][2], plru_tree[replace_set][0]} == 2'b00)
                    replace_way_nxt = 'd0;
                else if ({plru_tree[replace_set][2], plru_tree[replace_set][0]} == 2'b01)
                    replace_way_nxt = 'd1;
                else if ({plru_tree[replace_set][2], plru_tree[replace_set][1]} == 2'b10)
                    replace_way_nxt = 'd2;
                else if ({plru_tree[replace_set][2], plru_tree[replace_set][1]} == 2'b11)
                    replace_way_nxt = 'd3;
            end
        end
    end 
    else begin
        assign replace_way_nxt = plru_tree[replace_set][2:0];
    end
endgenerate

ns_gnrl_dfflr # (Cfg.wayIndexWidth) plru_tree_dfflr (1'b1, replace_way_nxt, replace_way, clk, rst_n);

endmodule