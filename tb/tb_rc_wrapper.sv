module tb_rc_wrapper;

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
     rfbufSize:16
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
 parameter type kobWidth_t      = logic [Cfg.kobWidth-1:0];

logic                        clk                        ;                 
logic                        rst_n                      ;

logic                        u_isu_valid                ;
logic                        u_isu_ready                ;
logic            [  2: 0]    u_isu_channel_1hot_id      ;
robWidth_t                   u_isu_rob_id               ;
logic            [  2: 0]    u_isu_op                   ;
setWidth_t                   u_isu_set                  ;
wayIndexWidth_t              u_isu_way                  ;
offsetWidth_t                u_isu_offset               ;
wbufWidth_t                  u_isu_wbuf_id              ;
logic            [255: 0]    u_isu_refill_data          ;

logic                        wbuf_req_valid             ;
wbufWidth_t                  wbuf_req_id                ;
logic            [127: 0]    wbuf_rsp_data              ;

logic                        u_bank_rsp_valid           ;
logic                        u_bank_rsp_ready           ;
robWidth_t                   u_bank_rsp_rob_id          ;
logic            [  1: 0]    u_bank_rsp_channel_id      ;
logic            [127: 0]    u_bank_rsp_data            ;

logic                        memctl_wvalid              ;
logic                        memctl_wready              ;
nlineWidth_t                 memctl_wid                 ;
logic            [255: 0]    memctl_wdata               ;

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
    u_isu_valid = 1'b0;
    u_isu_channel_1hot_id = 'd0;
    u_isu_rob_id = 'd0;
    u_isu_op = 'd0;
    u_isu_set = 'd0;
    u_isu_way = 'd0;
    u_isu_offset = 'd0;
    u_isu_wbuf_id = 'd0;
    u_isu_refill_data = 'd0;

    wbuf_rsp_data = 'd0;
    u_bank_rsp_ready = 'd1;
    memctl_wready = 'd1;
    
    #500;
    @(posedge clk)
    u_isu_valid <= 1'b1;
    u_isu_channel_1hot_id <= 'd1;
    u_isu_rob_id <= 'd7;
    u_isu_op <= CACHE_OP_LOAD_REFILL;
    u_isu_set <= 'd1;
    u_isu_way <= 'd1;
    u_isu_offset <= 'd0;
    u_isu_refill_data <= 'haaaa_bbbb_cccc_dddd;
    @(posedge clk)
    u_isu_valid <= 1'b1;
    u_isu_channel_1hot_id <= 'd2;
    u_isu_rob_id <= 'd3;
    u_isu_op <= CACHE_OP_STORE_REFILL;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd1;
    u_isu_refill_data <= 'hffff_eeee_dddd_cccc;
    @(posedge clk)
    u_isu_valid <= 1'b1;
    u_isu_channel_1hot_id <= 'd3;
    u_isu_rob_id <= 'd4;
    u_isu_op <= CACHE_OP_LOAD_REFILL;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd0;
    u_isu_refill_data <= 'haaaa_bbbb_cccc_dddd;
    wbuf_rsp_data <= 'hdddd_cccc_bbbb_aaaa;
    @(posedge clk)
    u_isu_valid <= 1'b1;
    u_isu_channel_1hot_id <= 'd3;
    u_isu_rob_id <= 'd4;
    u_isu_op <= CACHE_OP_LOAD_REFILL;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd0;
    u_isu_refill_data <= 'hbbbb_cccc_dddd_eeee;
    wbuf_rsp_data <= 'd0;
    @(posedge clk)
    u_isu_valid <= 1'b1;
    u_isu_channel_1hot_id <= 'd5;
    u_isu_rob_id <= 'd6;
    u_isu_op <= CACHE_OP_LOAD;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd1;
    u_isu_refill_data <= 'd0;
    @(posedge clk)
    u_isu_valid <= 1'b1;
    u_isu_channel_1hot_id <= 'd5;
    u_isu_rob_id <= 'd6;
    u_isu_op <= CACHE_OP_LOAD;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd0;
    u_isu_refill_data <= 'd0;
    @(posedge clk)
    u_isu_valid <= 1'b1;
    u_isu_channel_1hot_id <= 'd3;
    u_isu_rob_id <= 'd7;
    u_isu_op <= CACHE_OP_STORE;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd1;
    @(posedge clk)
    u_isu_valid <= 1'b1;
    u_isu_channel_1hot_id <= 'd3;
    u_isu_rob_id <= 'd8;
    u_isu_op <= CACHE_OP_WB;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd0;
    wbuf_rsp_data <= 'hdddd_cccc_bbbb_aaaa;
    @(posedge clk)
    u_isu_valid <= 1'b1;
    u_isu_channel_1hot_id <= 'd3;
    u_isu_rob_id <= 'd8;
    u_isu_op <= CACHE_OP_WB;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd0;
    wbuf_rsp_data <= 'd0;
    @(posedge clk)
    u_isu_valid <= 'd1;
    u_isu_channel_1hot_id <= 'd6;
    u_isu_rob_id <= 'd7;
    u_isu_op <= CACHE_OP_STORE_REFILL;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd1;
    u_isu_refill_data <= 'hffff_eeee_dddd_cccc;
    @(posedge clk)
    u_isu_valid <= 'd1;
    u_isu_channel_1hot_id <= 'd6;
    u_isu_rob_id <= 'd7;
    u_isu_op <= CACHE_OP_STORE;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd0;
    wbuf_rsp_data <= 'hcccc_dddd_eeee_ffff;
    u_isu_refill_data <= 'd0;
    @(posedge clk)
    u_isu_valid <= 'd1;
    u_isu_channel_1hot_id <= 'd6;
    u_isu_rob_id <= 'd7;
    u_isu_op <= CACHE_OP_STORE;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd0;
    wbuf_rsp_data <= 'h0;
     @(posedge clk)
    u_isu_valid <= 'd1;
    u_isu_channel_1hot_id <= 'd6;
    u_isu_rob_id <= 'd7;
    u_isu_op <= CACHE_OP_STORE;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd0;
    wbuf_rsp_data <= 'hcccc_dddd_eeee_ffff;
    u_isu_refill_data <= 'd0;
    @(posedge clk)
    u_isu_valid <= 'd1;
    u_isu_channel_1hot_id <= 'd6;
    u_isu_rob_id <= 'd7;
    u_isu_op <= CACHE_OP_STORE;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd0;
    wbuf_rsp_data <= 'h0;
    @(posedge clk)
    u_isu_valid <= 'd1;
    u_isu_channel_1hot_id <= 'd6;
    u_isu_rob_id <= 'd7;
    u_isu_op <= CACHE_OP_LOAD;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd0;
    wbuf_rsp_data <= 'h1111_2222_3333_4444;
    @(posedge clk)
    u_isu_valid <= 'd1;
    u_isu_channel_1hot_id <= 'd6;
    u_isu_rob_id <= 'd7;
    u_isu_op <= CACHE_OP_LOAD;
    u_isu_set <= 'd1;
    u_isu_way <= 'd2;
    u_isu_offset <= 'd1;
    wbuf_rsp_data <= 'h0;
    @(posedge clk)
    u_isu_valid <= 1'b0;
    u_isu_channel_1hot_id <= 'd0;
    u_isu_rob_id <= 'd4;
    u_isu_op <= 'd0;
    u_isu_set <= 'd0;
    u_isu_way <= 'd0;
    u_isu_offset <= 'd0;
    u_isu_refill_data <= 'h0;
end

rc_wrapper # (
    .Cfg                               (Cfg                ),      
    .setWidth_t                        (setWidth_t         ),      
    .tagWidth_t                        (tagWidth_t         ),      
    .wayIndexWidth_t                   (wayIndexWidth_t    ),      
    .wbufWidth_t                       (wbufWidth_t        ),      
    .wayNum_t                          (wayNum_t           ),      
    .nlineWidth_t                      (nlineWidth_t       ),      
    .offsetWidth_t                     (offsetWidth_t      ),      
    .metaWidth_t                       (metaWidth_t        ),      
    .robWidth_t                        (robWidth_t         ),      
    .lsqWidth_t                        (lsqWidth_t         ),      
    .kobWidth_t                        (kobWidth_t         ) 
) u_rc_wrapper (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

endmodule