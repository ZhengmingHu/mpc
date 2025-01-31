module tag_array
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

    input  logic                        tag_read_valid             ,
    output logic                        tag_read_ready             ,
    input  setWidth_t                   tag_read_set               ,
    output tagWidth_t                   tag_read_rsp   [Cfg.wayNum-1:0], 
    
    input  logic                        tag_write_valid            ,
    output logic                        tag_write_ready            ,
    input  setWidth_t                   tag_write_set              ,
    input  wayNum_t                     tag_write_way_en           ,
    input  tagWidth_t                   tag_write_data           
);

wayNum_t                                tag_cs;
wayNum_t                                tag_we;
setWidth_t                              tag_addr;
tagWidth_t                              tag_wentry;
tagWidth_t                              tag_rentry [Cfg.wayNum-1:0];

assign tag_read_ready = !tag_write_valid;
assign tag_write_ready = 1'b1;

generate 
    for (genvar tag_w = 0; tag_w < int'(Cfg.wayNum); tag_w++)
    begin : tag_sel_gen
        assign tag_cs[tag_w] = (tag_read_valid  & tag_read_ready) | 
                               (tag_write_valid & tag_write_ready & tag_write_way_en[tag_w]);
        assign tag_we[tag_w] = (tag_write_valid & tag_write_ready & tag_write_way_en[tag_w]);
    end
endgenerate
assign tag_addr     = |tag_we ? tag_write_set : tag_read_set;
assign tag_wentry   = tag_write_data;
assign tag_read_rsp = tag_rentry; 

generate 
    for (genvar tag_w = 0; tag_w < int'(Cfg.wayNum); tag_w++)
    begin : tag_sram_gen
        mpc_sram #(
            .DATA_SIZE (Cfg.tagWidth),
            .ADDR_SIZE (Cfg.setWidth)
        ) tag_sram (
            .clk       (clk              ),
            .rst_n     (rst_n            ),
            .cs        (tag_cs[tag_w]    ),
            .we        (tag_we[tag_w]    ),
            .addr      (tag_addr         ),
            .wdata     (tag_wentry       ),
            .rdata     (tag_rentry[tag_w])
        );
    end
endgenerate

endmodule