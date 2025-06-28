`include "mpc_defs.svh"

module tb_mpc_wrapper;
    import mpc_types::*;

 parameter mpc_user_cfg_t UserCfg = '{
     opWidth:3,
     clWidth:256,
     clWordWidth:128,
     addrWidth:32,
     sets:8,
     banks:4,
     ways:4,
     kobSize:16,
     wbufSize:16,
     robSize:16,
     lsqSize:32,
     rfbufSize:16,
     mcSize:4
 };
parameter mpc_cfg_t Cfg = mpcBuildConfig(UserCfg);
parameter type opWidth_t       = logic [Cfg.u.opWidth-1:0];
parameter type dataWidth_t     = logic [Cfg.u.clWordWidth-1:0];
parameter type addrWidth_t     = logic [Cfg.u.addrWidth-1:0];
parameter type setWidth_t      = logic [Cfg.setWidth-1:0];
parameter type tagWidth_t      = logic [Cfg.tagWidth-1:0];
parameter type wayIndexWidth_t = logic [Cfg.wayIndexWidth-1:0];
parameter type wbufWidth_t     = logic [Cfg.wbufWidth-1:0];
parameter type wayNum_t        = logic [Cfg.wayNum-1:0];
parameter type nlineWidth_t    = logic [Cfg.nlineWidth-1:0];
parameter type offsetWidth_t   = logic [Cfg.offsetWidth-1:0];
parameter type metaWidth_t     = logic [Cfg.metaWidth-1:0];
parameter type robWidth_t      = logic [Cfg.robWidth-1:0];
parameter type lsqWidth_t      = logic [Cfg.lsqWidth-1:0];
parameter type rfbufWidth_t    = logic [Cfg.rfbufWidth-1:0];
parameter type kobWidth_t      = logic [Cfg.kobWidth-1:0];
parameter type mcWidth_t       = logic [Cfg.mcWidth-1:0];

localparam type channel_req_t = 
    `MPC_DECL_REQ_T(
        opWidth_t,
        dataWidth_t,
        addrWidth_t);
    
localparam type bank_req_t =
    `MPC_DECL_BANK_REQ_T(
        opWidth_t,
        dataWidth_t,
        addrWidth_t);

logic                        clk                        ;
logic                        rst_n                      ;

logic                        u_channel_0_req_bus_valid  ;
logic                        u_channel_0_req_bus_ready  ;
channel_req_t                u_channel_0_req_bus        ;
logic                        u_channel_1_req_bus_valid  ;
logic                        u_channel_1_req_bus_ready  ;
channel_req_t                u_channel_1_req_bus        ;
logic                        u_channel_2_req_bus_valid  ;
logic                        u_channel_2_req_bus_ready  ;
channel_req_t                u_channel_2_req_bus        ;

logic                        u_channel_0_rsp_bus_valid  ;
logic                        u_channel_0_rsp_bus_ready  ;
logic          [127: 0]      u_channel_0_rsp_bus_rdata  ;
logic                        u_channel_1_rsp_bus_valid  ;
logic                        u_channel_1_rsp_bus_ready  ;
logic          [127: 0]      u_channel_1_rsp_bus_rdata  ;
logic                        u_channel_2_rsp_bus_valid  ;
logic                        u_channel_2_rsp_bus_ready  ;
logic          [127: 0]      u_channel_2_rsp_bus_rdata  ;

always# 10  clk = ~clk;

reg [1024:0] FSDB_FILE;
initial begin
    if ($value$plusargs("FSDB_FILE=%s", FSDB_FILE)) begin
        $fsdbDumpfile(FSDB_FILE);
        $fsdbDumpvars("+all");
    end
end

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
    u_channel_0_req_bus_valid = 'd0;
    u_channel_0_req_bus = 'd0;
    u_channel_1_req_bus_valid = 'd0;
    u_channel_1_req_bus = 'd0;
    u_channel_2_req_bus_valid = 'd0;
    u_channel_2_req_bus = 'd0;

    u_channel_0_rsp_bus_ready = 'd1;
    u_channel_1_rsp_bus_ready = 'd1;
    u_channel_2_rsp_bus_ready = 'd1;

    #500
    @(posedge clk)
    u_channel_0_req_bus_valid <= 'd1;
    u_channel_0_req_bus.op <= MPC_OP_STORE;
    u_channel_0_req_bus.addr <= 32'b0000_0000_1010_0000;
    u_channel_0_req_bus.wdata <= 128'haaaa_bbbb_cccc_dddd;
    
    @(posedge clk)
    u_channel_0_req_bus_valid = 'd0;
    u_channel_0_req_bus = 'd0;

    u_channel_1_req_bus_valid = 'd1;
    u_channel_1_req_bus.op <= MPC_OP_LOAD;
    u_channel_1_req_bus.addr <= 32'b0000_0000_1010_0000;

    @(posedge clk)
    u_channel_1_req_bus_valid = 'd0;
    u_channel_1_req_bus <= 'd0;

end

mpc_wrapper # (
    .Cfg                       (Cfg                      ),
    .opWidth_t                 (opWidth_t                ),
    .dataWidth_t               (dataWidth_t              ),
    .addrWidth_t               (addrWidth_t              ),
    .setWidth_t                (setWidth_t               ), 
    .tagWidth_t                (tagWidth_t               ), 
    .wayIndexWidth_t           (wayIndexWidth_t          ), 
    .wbufWidth_t               (wbufWidth_t              ), 
    .wayNum_t                  (wayNum_t                 ), 
    .nlineWidth_t              (nlineWidth_t             ), 
    .offsetWidth_t             (offsetWidth_t            ), 
    .metaWidth_t               (metaWidth_t              ), 
    .robWidth_t                (robWidth_t               ), 
    .lsqWidth_t                (lsqWidth_t               ), 
    .rfbufWidth_t              (rfbufWidth_t             ), 
    .kobWidth_t                (kobWidth_t               ), 
    .mcWidth_t                 (mcWidth_t                ),
    .channel_req_t             (channel_req_t            ),
    .bank_req_t                (bank_req_t               )
) u_mpc_wrapper (
    .*
);



endmodule