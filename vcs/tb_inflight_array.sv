module tb_rob_id_gen;
import mpc_types::*;

parameter mpc_user_cfg_t UserCfg = '{
    clWidth:256,
    clWordWidth:128,
    sets:8,
    banks:4,
    ways:4,
    kobSize:16,
    wbufSize:128,
    robSize:8
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
parameter type robWidth_t      = logic [Cfg.robWidth-1:0];


logic                        clk                 ;
logic                        rst_n               ;
logic                        htu_refill_valid    ;
setWidth_t                   htu_refill_set      ;
wayIndexWidth_t              htu_refill_way      ;
setWidth_t                   htu_set             ;
wayIndexWidth_t              htu_way             ;
logic                        inflight_flg        ;
logic                        memctl_refill_valid ;
nlineWidth_t                 memctl_refill_id    ;

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
    htu_refill_valid    = 'd0;
    htu_refill_set      = 'd0;
    htu_refill_way      = 'd0;
    htu_set             = 'd0;
    htu_way             = 'd0;
    memctl_refill_valid = 'd0;
    memctl_refill_id    = 'd0;
    #500;
    @(posedge clk)
    htu_refill_valid    = 'd1;
    htu_refill_set      = 'd1;
    htu_refill_way      = 'd2;
    @(posedge clk)
    htu_refill_valid    = 'd1;
    htu_refill_set      = 'd2;
    htu_refill_way      = 'd3;
    memctl_refill_valid = 'd1;
    memctl_refill_id    = {2'd2, 3'd1};
    @(posedge clk)
    htu_refill_valid    = 'd0;
    htu_refill_set      = 'd0;
    htu_refill_way      = 'd0;
    htu_set             = 'd2;
    htu_way             = 'd3;
    memctl_refill_valid = 'd0;
    memctl_refill_id    = 'd0;
    @(posedge clk)
    htu_refill_valid    = 'd0;
    htu_refill_set      = 'd0;
    htu_refill_way      = 'd0;
    htu_set             = 'd0;
    htu_way             = 'd0;
    memctl_refill_valid = 'd0;
    memctl_refill_id    = 'd0;
end


inflight_array
#(
    .Cfg                               (Cfg                       ),
    .setWidth_t                        (setWidth_t                ),
    .tagWidth_t                        (tagWidth_t                ),
    .wayIndexWidth_t                   (wayIndexWidth_t           ),
    .wbufWidth_t                       (wbufWidth_t               ),
    .wayNum_t                          (wayNum_t                  ),
    .nlineWidth_t                      (nlineWidth_t              ),
    .offsetWidth_t                     (offsetWidth_t             ),
    .metaWidth_t                       (metaWidth_t               ),
    .robWidth_t                        (robWidth_t                )
) u_inflight_array (
    .*
);

endmodule