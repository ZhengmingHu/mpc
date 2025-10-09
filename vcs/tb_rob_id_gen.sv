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

logic                        clk                          ;
logic                        rst_n                        ;
logic                        u_valid                      ;
logic    [  2: 0]            u_channel_1hot_id            ;
robWidth_t                   d_isu_rob_id                 ;  

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
    u_valid            = 'd0;
    u_channel_1hot_id  = 'd0;
    #500;
    @(posedge clk)
    u_valid            = 'd1;
    u_channel_1hot_id  = 'd1;
    @(posedge clk)
    u_valid            = 'd1;
    u_channel_1hot_id  = 'd2;
    @(posedge clk)
    u_valid            = 'd1;
    u_channel_1hot_id  = 'd4;
    @(posedge clk)
    u_valid            = 'd1;
    u_channel_1hot_id  = 'd2;
    @(posedge clk)
    u_valid            = 'd1;
    u_channel_1hot_id  = 'd4;
    @(posedge clk)
    u_valid            = 'd1;
    u_channel_1hot_id  = 'd4;
    @(posedge clk)
    u_valid            = 'd1;
    u_channel_1hot_id  = 'd1;
    @(posedge clk)
    u_valid            = 'd1;
    u_channel_1hot_id  = 'd4;
end

rob_id_gen
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
) u_rob_id_gen (
    .*
);

endmodule