module tb_htu;

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

logic                        clk                  ;
logic                        rst_n                ;

logic                        u_bank_req_valid     ;
logic                        u_bank_req_ready     ;
bank_req_t                   u_bank_req           ;

logic                        d_isu_refill_valid   ;
setWidth_t                   d_isu_refill_set     ;
wayIndexWidth_t              d_isu_refill_way     ;

logic                        d_isu_valid          ;
logic                        d_isu_ready          ;
logic           [  2: 0]     d_isu_channel_1hot_id;
logic           [  2: 0]     d_isu_op             ;
nlineWidth_t                 d_isu_id             ;
offsetWidth_t                d_isu_offset         ;
wbufWidth_t                  d_isu_wbuf_id        ;

logic                        d_memctl_valid       ;
logic                        d_memctl_ready       ;
logic           [  2: 0]     d_memctl_op          ;
nlineWidth_t                 d_memctl_id          ;
logic           [ 31: 0]     d_memctl_addr        ;
logic                        d_isu_crdt_valid     ;
nlineWidth_t                 d_isu_crdt_way_set   ;

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
    u_bank_req_valid = 1'b0;
    u_bank_req.channel_1hot_id = 'd0;
    u_bank_req.wbuffer_id = 'd0;
    u_bank_req.op = 'd0;
    u_bank_req.addr = 'd0;
    u_bank_req.wdata = 'd0;
    d_isu_ready = 'd1;
    d_memctl_ready = 'd1;
    d_isu_crdt_valid = 'd0;
    d_isu_crdt_way_set = 'd0;
    #500;
    @(posedge clk)
    u_bank_req_valid <= 'd1;
    u_bank_req.op <= 'd1;
    u_bank_req.addr <= 32'hff00_0020;
    @(posedge clk)
    u_bank_req_valid <= 'd1;
    u_bank_req.addr <= 32'hfe00_0020;
    @(posedge clk)
    @(posedge clk)
    @(posedge clk)
    u_bank_req_valid <= 'd1;
    u_bank_req.addr <= 32'hfd00_0020;
    @(posedge clk)
    @(posedge clk)
    @(posedge clk)
    u_bank_req_valid <= 'd1;
    u_bank_req.addr <= 32'hfc00_0020;
    @(posedge clk)
    d_isu_crdt_valid <= 'd1;
    d_isu_crdt_way_set <= {2'd0, 3'd1};
    @(posedge clk)
    d_isu_crdt_valid <= 'd0;
    d_isu_crdt_way_set <= 'd0;
    @(posedge clk)
    u_bank_req_valid <= 'd1;
    u_bank_req.addr <= 32'hfb00_0020;
end

htu_wrapper
u_htu_wrapper(
    .*
);

endmodule