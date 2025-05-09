module tb_isu;

import mpc_types::*;

    parameter mpc_user_cfg_t UserCfg = '{
        clWidth:256,
        clWordWidth:128,
        sets:8,
        banks:4,
        ways:4,
        kobSize:16,
        wbufSize:128,
        robSize:16,
        lsqSize:32,
        rfbufSize:32
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
    parameter type lsqWidth_t      = logic [Cfg.lsqWidth-1:0];
    parameter type rfbufWidth_t    = logic [Cfg.rfbufWidth-1:0];


logic                        clk                  ;
logic                        rst_n                ;

logic                        u_htu_valid           ;
logic                        u_htu_ready           ;
logic           [  2: 0]     u_htu_channel_1hot_id ;
logic           [  2: 0]     u_htu_op              ;
nlineWidth_t                 u_htu_id              ;
offsetWidth_t                u_htu_offset          ;
wbufWidth_t                  u_htu_wbuf_id         ;

logic                        u_htu_refill_valid    ;
setWidth_t                   u_htu_refill_set      ;
wayIndexWidth_t              u_htu_refill_way      ;

logic                        memctl_refill_valid   ;
logic                        memctl_refill_ready   ;
nlineWidth_t                 memctl_refill_id      ;
logic            [255: 0]    memctl_refill_data    ;

logic            [  2: 0]    u_xbar_crdt_rtn       ;

logic                        d_rc_valid            ;
logic                        d_rc_ready            ;
logic            [  2: 0]    d_rc_channel_1hot_id  ;
robWidth_t                   d_rc_rob_id           ;
logic            [  2: 0]    d_rc_op               ;
setWidth_t                   d_rc_set              ;
wayIndexWidth_t              d_rc_way              ;
offsetWidth_t                d_rc_offset           ;
wbufWidth_t                  d_rc_wbuf_id          ;
logic            [255: 0]    d_rc_refill_data      ;

logic                        u_htu_crdt_valid      ;
nlineWidth_t                 u_htu_crdt_way_set    ;

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
    u_htu_valid = 1'b0;
    u_htu_channel_1hot_id = 'd0;
    u_htu_op = 'd0;
    u_htu_id = 'd0;
    u_htu_offset = 'd0;
    u_htu_wbuf_id = 'd0;
    u_htu_refill_valid = 'd0;
    u_htu_refill_set = 'd0;
    u_htu_refill_way = 'd0;
    memctl_refill_valid = 'd0;
    memctl_refill_id = 'd0;
    memctl_refill_data = 'd0;
    u_xbar_crdt_rtn[0] = 'd0;
    u_xbar_crdt_rtn[1] = 'd0;
    u_xbar_crdt_rtn[2] = 'd0;
    d_rc_ready = 'd1;
    #500;
    @(posedge clk)
    u_htu_valid <= 'd1;
    u_htu_channel_1hot_id <= 'd2;
    u_htu_op <= CACHE_OP_WAE;
    u_htu_id <= {2'd3, 3'd5};
    u_htu_offset <= 'd1;
    u_htu_wbuf_id <='d7;
    u_htu_refill_valid <= 'd1;
    u_htu_refill_set <= 3'd5;
    u_htu_refill_way <= 2'd3;
    @(posedge clk)
    u_htu_valid <= 'd1;
    u_htu_channel_1hot_id <= 'd4;
    u_htu_op <= CACHE_OP_STORE;
    u_htu_id <= {2'd2, 3'd6};
    u_htu_offset <= 'd0;
    u_htu_wbuf_id <='d8;
    u_htu_refill_valid <= 'd1;
    u_htu_refill_set <= 3'd6;
    u_htu_refill_way <= 2'd2;
    @(posedge clk)
    u_htu_valid = 1'b1;
    u_htu_channel_1hot_id = 'd1;
    u_htu_op = CACHE_OP_LOAD;
    u_htu_id = {2'd1, 3'd7};
    u_htu_offset = 'd1;
    u_htu_wbuf_id = 'd9;
    u_htu_refill_valid = 'd0;
    u_htu_refill_set = 'd0;
    u_htu_refill_way = 'd0;
    memctl_refill_valid <= 'd1;
    memctl_refill_id <= {2'd2, 3'd6};
    memctl_refill_data <= 'hffff_eeee_ffff_eeee;
    u_xbar_crdt_rtn[0] = 'd0;
    u_xbar_crdt_rtn[1] = 'd0;
    u_xbar_crdt_rtn[2] = 'd0;
    d_rc_ready = 'd1;
    @(posedge clk)
    u_htu_valid = 1'b1;
    u_htu_channel_1hot_id = 'd1;
    u_htu_op = CACHE_OP_LOAD;
    u_htu_id = {2'd1, 3'd3};
    u_htu_offset = 'd0;
    u_htu_wbuf_id = 'd10;
    u_htu_refill_valid = 'd1;
    u_htu_refill_set = 'd3;
    u_htu_refill_way = 'd1;
    memctl_refill_valid <= 'd1;
    memctl_refill_id <= {2'd3, 3'd5};
    memctl_refill_data <= 'hdddd_eeee_dddd_eeee;
    u_xbar_crdt_rtn[0] = 'd0;
    u_xbar_crdt_rtn[1] = 'd0;
    u_xbar_crdt_rtn[2] = 'd0;
    d_rc_ready = 'd0;
    @(posedge clk)
    u_htu_valid = 1'b1;
    u_htu_channel_1hot_id = 'd1;
    u_htu_op = CACHE_OP_LOAD;
    u_htu_id = {2'd1, 3'd3};
    u_htu_offset = 'd1;
    u_htu_wbuf_id = 'd11;
    u_htu_refill_valid = 'd0;
    u_htu_refill_set = 'd0;
    u_htu_refill_way = 'd0;
    memctl_refill_valid <= 'd1;
    memctl_refill_id <= {2'd1, 3'd3};
    memctl_refill_data <= 'haaaa_bbbb_cccc_dddd;
    u_xbar_crdt_rtn[0] = 'd0;
    u_xbar_crdt_rtn[1] = 'd0;
    u_xbar_crdt_rtn[2] = 'd0;
    d_rc_ready = 'd0;
    @(posedge clk)
    u_htu_valid = 1'b0;
    u_htu_channel_1hot_id = 'd0;
    u_htu_op = 'd0;
    u_htu_id = 'd0;
    u_htu_offset = 'd0;
    u_htu_wbuf_id = 'd0;
    u_htu_refill_valid = 'd0;
    u_htu_refill_set = 'd0;
    u_htu_refill_way = 'd0;
    memctl_refill_valid = 'd0;
    memctl_refill_id = 'd0;
    memctl_refill_data = 'd0;
    u_xbar_crdt_rtn[0] = 'd0;
    u_xbar_crdt_rtn[1] = 'd0;
    u_xbar_crdt_rtn[2] = 'd0;
    d_rc_ready = 'd1;
end

isu_wrapper # (
    .Cfg                               (Cfg                                ),
    .setWidth_t                        (setWidth_t                         ),
    .tagWidth_t                        (tagWidth_t                         ),
    .wayIndexWidth_t                   (wayIndexWidth_t                    ),
    .wbufWidth_t                       (wbufWidth_t                        ),
    .wayNum_t                          (wayNum_t                           ),
    .nlineWidth_t                      (nlineWidth_t                       ),
    .offsetWidth_t                     (offsetWidth_t                      ),
    .metaWidth_t                       (metaWidth_t                        ),
    .robWidth_t                        (robWidth_t                         ),
    .lsqWidth_t                        (lsqWidth_t                         ),
    .rfbufWidth_t                      (rfbufWidth_t                       )
)
u_isu_wrapper(
    .*
);

endmodule