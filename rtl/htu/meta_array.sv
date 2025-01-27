module meta_array
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

wayNum_t                                meta_cs;
wayNum_t                                meta_we;
setWidth_t                              meta_addr;
metaWidth_t                             meta_wentry;
metaWidth_t                             meta_rentry [Cfg.wayNum-1:0];

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
        mpc_sram #(
            .DATA_SIZE (Cfg.metaWidth),
            .ADDR_SIZE (Cfg.setWidth)
        ) meta_sram (
            .clk       (clk                ),
            .rst_n     (rst_n              ),
            .cs        (meta_cs[meta_w]    ),
            .we        (meta_we[meta_w]    ),
            .addr      (meta_addr          ),
            .wdata     (meta_wentry        ),
            .rdata     (meta_rentry[meta_w])
        );
    end
endgenerate


endmodule