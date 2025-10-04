module tb_write_buffer;

import mpc_types::*;

 parameter mpc_user_cfg_t UserCfg = '{
     clWidth:256,
     clWordWidth:128,
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
parameter type setWidth_t      = logic [Cfg.setWidth-1:0];
parameter type tagWidth_t      = logic [Cfg.tagWidth-1:0];
parameter type wayIndexWidth_t = logic [Cfg.wayIndexWidth-1:0];
parameter type wbufWidth_t     = logic [Cfg.wbufWidth-1:0];
parameter type wayNum_t        = logic [Cfg.wayNum-1:0];
parameter type nlineWidth_t    = logic [Cfg.nlineWidth-1];
parameter type offsetWidth_t   = logic [Cfg.offsetWidth-1];
parameter type metaWidth_t     = logic [Cfg.metaWidth-1:0];
parameter type robWidth_t      = logic [Cfg.robWidth-1:0];
parameter type lsqWidth_t      = logic [Cfg.lsqWidth-1:0];
parameter type rfbufWidth_t    = logic [Cfg.rfbufWidth-1:0];
parameter type kobWidth_t      = logic [Cfg.kobWidth-1:0];

logic                        clk                 ;
logic                        rst_n               ;
logic                        xbar_req_valid      ;
wbuf_req_t                   xbar_req            ;
logic                        xbar_rsp_free_valid ;
wbufWidth_t                  xbar_rsp_free_id    ;
logic                        rc_req_valid        ;
wbufWidth_t                  rc_req_id           ;
logic            [127: 0]    rc_rsp_data         ;

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
    xbar_req_valid = 1'b0;
    xbar_req.wbuf_id = 'd0;
    xbar_req.wdata = 'd0;
    rc_req_valid = 1'b0;
    rc_req_id = 'd0;
    
    #500;
    @(posedge clk)
    xbar_req_valid = 1'b1;
    xbar_req.wbuf_id = 'd0;
    xbar_req.wdata = 128'haaaa_bbbb_cccc_dddd;
    @(posedge clk)
    xbar_req_valid = 1'b1;
    xbar_req.wbuf_id = 'd1;
    xbar_req.wdata = 128'hcccc_dddd_eeee_ffff;
    @(posedge clk)
    xbar_req_valid = 1'b1;
    xbar_req.wbuf_id = 'd2;
    xbar_req.wdata = 128'hcccc_dddd_eeee_ffff;
    @(posedge clk)
    xbar_req_valid = 1'b1;
    xbar_req.wbuf_id = 'd3;
    xbar_req.wdata = 128'heeee_dddd_cccc_ffff;
    rc_req_valid = 1'b1;
    rc_req_id = 'd1;
    @(posedge clk)
    xbar_req_valid = 1'b0;
    xbar_req.wbuf_id = 'd0;
    xbar_req.wdata = 'd0;
    rc_req_valid = 1'b1;
    rc_req_id = 'd3;
    @(posedge clk)
    xbar_req_valid = 1'b0;
    xbar_req.wbuf_id = 'd0;
    xbar_req.wdata = 'd0;
    rc_req_valid = 1'b1;
    rc_req_id = 'd2;
    @(posedge clk)
    xbar_req_valid = 1'b0;
    xbar_req.wbuf_id = 'd0;
    xbar_req.wdata = 'd0;
    rc_req_valid = 1'b1;
    rc_req_id = 'd0;
    @(posedge clk)
    xbar_req_valid = 1'b0;
    xbar_req.wbuf_id = 'd0;
    xbar_req.wdata = 'd0;
    rc_req_valid = 1'b0;
    rc_req_id = 'd0;
end

write_buffer # (
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
) u_write_buffer (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

endmodule