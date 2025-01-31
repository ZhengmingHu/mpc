module meta_array
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

    input  logic                        meta_read_valid            ,
    output logic                        meta_read_ready            ,
    input  setWidth_t                   meta_read_set              ,
    output metaWidth_t                  meta_read_rsp  [Cfg.wayNum-1:0],

    input  logic                        meta_write_valid           ,
    output logic                        meta_write_ready           ,
    input  setWidth_t                   meta_write_set             ,
    input  wayNum_t                     meta_write_way_en          ,
    input  metaWidth_t                  meta_write_data            

);

localparam setNum       = 2 ** Cfg.setWidth;

wayNum_t                                meta_cs;
wayNum_t                                meta_we;
setWidth_t                              meta_addr;
metaWidth_t                             meta_wentry;
metaWidth_t                             meta_rentry [Cfg.wayNum-1:0];
metaWidth_t                             meta_sram [Cfg.wayNum-1:0][setNum-1:0];
logic [setNum-1:0]                      meta_en [Cfg.wayNum-1:0];

assign meta_read_ready = !meta_write_valid;
assign meta_write_ready = 1'b1;

generate 
    for (genvar meta_w = 0; meta_w < int'(Cfg.wayNum); meta_w++)
    begin : meta_sel_gen
        assign meta_cs[meta_w] = (meta_read_valid  & meta_read_ready) | 
                               (meta_write_valid & meta_write_ready & meta_write_way_en[meta_w]);
        assign meta_we[meta_w] = (meta_write_valid & meta_write_ready & meta_write_way_en[meta_w]);
    end
endgenerate
assign meta_addr     = |meta_we ? meta_write_set : meta_read_set;
assign meta_wentry   = meta_write_data;
assign meta_read_rsp = meta_rentry; 

generate 
    for (genvar meta_w = 0; meta_w < int'(Cfg.wayNum); meta_w++)
    begin : meta_sram_gen
        for (genvar meta_s = 0; meta_s < setNum; meta_s++)
        begin : meta_sram_gen
            assign meta_en[meta_w][meta_s] = meta_write_set == meta_s & meta_we[meta_w] & meta_cs[meta_w];
            ns_gnrl_dfflr # (Cfg.metaWidth) meta_sram_dfflr (meta_en[meta_w][meta_s], meta_wentry, meta_sram[meta_w][meta_s], clk, rst_n);
        end
    end
endgenerate

generate
    for (genvar meta_w = 0; meta_w < int'(Cfg.wayNum); meta_w++)
    begin : meta_rsp_gen
        ns_gnrl_dfflr # (Cfg.metaWidth) meta_rsp_dfflr (meta_cs[meta_w] & !meta_we[meta_w], meta_sram[meta_w][meta_read_set], meta_rentry[meta_w], clk, rst_n);
    end
endgenerate


endmodule