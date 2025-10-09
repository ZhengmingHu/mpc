module tb_wbuf_id_gen;
import mpc_types::*;

parameter mpc_user_cfg_t UserCfg = '{
    clWidth:256,
    clWordWidth:128,
    sets:8,
    banks:4,
    ways:4,
    kobSize:16,
    wbufSize:128
};

parameter mpc_cfg_t Cfg = mpcBuildConfig(UserCfg);

parameter type setWidth_t      = logic [Cfg.setWidth-1:0];
parameter type tagWidth_t      = logic [Cfg.tagWidth-1:0];
parameter type wayIndexWidth_t = logic [Cfg.wayIndexWidth-1:0];
parameter type wbufWidth_t     = logic [Cfg.wbufWidth-1:0];
parameter type wayNum_t        = logic [Cfg.wayNum-1:0];
parameter type nlineWidth_t    = logic [Cfg.nlineWidth-1:0];
parameter type offsetWidth_t   = logic [Cfg.offsetWidth-1:0];
parameter type metaWidth_t     = logic [Cfg.metaWidth-1:0];

 logic                        clk                        ;
 logic                        rst_n                      ;
 logic                        alloc_valid                ;
 logic                        alloc_ready                ;
 wbufWidth_t                  alloc_id                   ;
 logic                        free_valid                 ;
 wbufWidth_t                  free_id                    ;

reg [1024:0] FSDB_FILE;
initial begin
    if ($value$plusargs("FSDB_FILE=%s", FSDB_FILE)) begin
        $fsdbDumpfile(FSDB_FILE);
        $fsdbDumpvars("+all");
    end
end

always# 10  clk = ~clk;

initial begin
    clk     = 1'b0;
    rst_n   = 1'b0;
    #453
    rst_n   = 1'b1;
end

initial begin
    #20000;
    $finish;
end

initial begin
    alloc_valid = 'd0;
    free_valid  = 'd0;
    free_id     = 'd0;
    #500;
    @(posedge clk)
    alloc_valid = 1'd1;
    @(posedge clk)
    alloc_valid = 1'd1;
    @(posedge clk)
    alloc_valid = 1'd1;
    @(posedge clk)
    alloc_valid = 1'd1;
    @(posedge clk)
    alloc_valid = 1'd1;
    @(posedge clk)
    free_valid = 1'd1;
    free_id = 'd2;
    alloc_valid = 1'd1;
    @(posedge clk)
    free_valid = 1'd1;
    free_id = 'd3;
    @(posedge clk)
    alloc_valid = 1'd0;
    free_valid = 1'd0;
    free_id = 'd0;
end

wbuf_id_gen
#(
    .Cfg                               (Cfg                       ),
    .setWidth_t                        (setWidth_t                ),
    .tagWidth_t                        (tagWidth_t                ),
    .wayIndexWidth_t                   (wayIndexWidth_t           ),
    .wbufWidth_t                       (wbufWidth_t               ),
    .wayNum_t                          (wayNum_t                  ),
    .nlineWidth_t                      (nlineWidth_t              ),
    .offsetWidth_t                     (offsetWidth_t             ),
    .metaWidth_t                       (metaWidth_t               )
) u_wbuf_id_gen (
    .*
);

endmodule