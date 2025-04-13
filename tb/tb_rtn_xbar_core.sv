module tb_rtn_xbar_core;
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

logic                        d_bank_0_rsp_valid         ;
logic                        d_bank_0_rsp_ready         ;
logic          [127: 0]      d_bank_0_rsp_data          ;
logic          [  1: 0]      d_bank_0_rsp_channel_id    ;
robWidth_t                   d_bank_0_rsp_rob_id        ;

logic                        d_bank_1_rsp_valid         ;
logic                        d_bank_1_rsp_ready         ;
logic          [127: 0]      d_bank_1_rsp_data          ;
logic          [  1: 0]      d_bank_1_rsp_channel_id    ;
robWidth_t                   d_bank_1_rsp_rob_id        ;

logic                        d_bank_2_rsp_valid         ;
logic                        d_bank_2_rsp_ready         ;
logic          [127: 0]      d_bank_2_rsp_data          ;
logic          [  1: 0]      d_bank_2_rsp_channel_id    ;
robWidth_t                   d_bank_2_rsp_rob_id        ;

logic                        d_bank_3_rsp_valid         ;
logic                        d_bank_3_rsp_ready         ;
logic          [127: 0]      d_bank_3_rsp_data          ;
logic          [  1: 0]      d_bank_3_rsp_channel_id    ;
robWidth_t                   d_bank_3_rsp_rob_id        ;

logic                        u_channel_0_rsp_valid      ;
logic                        u_channel_0_rsp_ready      ;
logic          [127: 0]      u_channel_0_rsp_data       ;
logic          [  1: 0]      u_channel_0_rsp_bank_id    ;
robWidth_t                   u_channel_0_rsp_rob_id     ;

logic                        u_channel_1_rsp_valid      ;
logic                        u_channel_1_rsp_ready      ;
logic          [127: 0]      u_channel_1_rsp_data       ;
logic          [  1: 0]      u_channel_1_rsp_bank_id    ;
robWidth_t                   u_channel_1_rsp_rob_id     ;

logic                        u_channel_2_rsp_valid      ;
logic                        u_channel_2_rsp_ready      ;
logic          [127: 0]      u_channel_2_rsp_data       ;
logic          [  1: 0]      u_channel_2_rsp_bank_id    ;
robWidth_t                   u_channel_2_rsp_rob_id     ;

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
    u_channel_0_rsp_ready = 1'b1;
    u_channel_1_rsp_ready = 1'b1;
    u_channel_2_rsp_ready = 1'b1;
    #453
    rst_n   = 1'b1;
    u_channel_0_rsp_ready = 1'b1;
    u_channel_1_rsp_ready = 1'b1;
    u_channel_2_rsp_ready = 1'b1;
end

initial begin
    #25000;
    $finish;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_bank_0_rsp_valid <= '0;
        d_bank_1_rsp_valid <= '0;
        d_bank_2_rsp_valid <= '0;
        d_bank_3_rsp_valid <= '0;
    end else begin
        d_bank_0_rsp_valid <=  $random;
        d_bank_1_rsp_valid <=  $random;
        d_bank_2_rsp_valid <=  $random;
        d_bank_3_rsp_valid <=  $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_bank_0_rsp_data <= '0;
        d_bank_0_rsp_channel_id <= '0;
        d_bank_0_rsp_rob_id <= '0;
    end else if (d_bank_0_rsp_valid & d_bank_0_rsp_ready) begin
        d_bank_0_rsp_data <= $random;
        d_bank_0_rsp_channel_id <= $urandom_range(2, 0);
        d_bank_0_rsp_rob_id <= $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_bank_1_rsp_data <= '0;
        d_bank_1_rsp_channel_id <= '0;
        d_bank_1_rsp_rob_id <= '0;
    end else if (d_bank_1_rsp_valid & d_bank_1_rsp_ready) begin
        d_bank_1_rsp_data <= $random;
        d_bank_1_rsp_channel_id <=  $urandom_range(2, 0);
        d_bank_1_rsp_rob_id <= $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_bank_2_rsp_data <= '0;
        d_bank_2_rsp_channel_id <= '0;
        d_bank_2_rsp_rob_id <= '0;
    end else if (d_bank_2_rsp_valid & d_bank_2_rsp_ready) begin
        d_bank_2_rsp_data <= $random;
        d_bank_2_rsp_channel_id <= $urandom_range(2, 0);
        d_bank_2_rsp_rob_id <= $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_bank_3_rsp_data <= '0;
        d_bank_3_rsp_channel_id <= '0;
        d_bank_3_rsp_rob_id <= '0;
    end else if (d_bank_3_rsp_valid & d_bank_3_rsp_ready) begin
        d_bank_3_rsp_data <= $random;
        d_bank_3_rsp_channel_id <=  $urandom_range(2, 0);
        d_bank_3_rsp_rob_id <= $random;
    end
end

rtn_xbar_core # (
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
            .lsqWidth_t                        (lsqWidth_t                         )
) u_rtn_xbar_core (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

endmodule