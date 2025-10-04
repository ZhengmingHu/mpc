module tb_kob;
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
    parameter type kobWidth_t      = logic [Cfg.kobWidth-1:0];

initial begin
    $display("kobSize:", Cfg.u.kobSize);
end

logic                        clk                        ;
logic                        rst_n                      ;

logic                        u_channel_0_req_valid      ;
logic                        u_channel_0_req_ready      ;
channel_req_t                u_channel_0_req            ;

logic                        u_channel_1_req_valid      ;
logic                        u_channel_1_req_ready      ;
channel_req_t                u_channel_1_req            ;

logic                        u_channel_2_req_valid      ;
logic                        u_channel_2_req_ready      ;
channel_req_t                u_channel_2_req            ;

logic                        d_ch_0_rob_req             ;
logic                        d_ch_0_rob_ack             ;
logic           [  1: 0]     d_ch_0_rob_bank_id         ;

logic                        d_ch_1_rob_req             ;
logic                        d_ch_1_rob_ack             ;
logic           [  1: 0]     d_ch_1_rob_bank_id         ;

logic                        d_ch_2_rob_req             ;
logic                        d_ch_2_rob_ack             ;
logic           [  1: 0]     d_ch_2_rob_bank_id         ;

logic                        ch_0_kob_full              ;
logic                        ch_1_kob_full              ;
logic                        ch_2_kob_full              ;


always# 10  clk = ~clk;

assign u_channel_0_req_ready = ~ch_0_kob_full;
assign u_channel_1_req_ready = ~ch_1_kob_full;
assign u_channel_2_req_ready = ~ch_2_kob_full;

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
    #25000;
    $finish;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        u_channel_0_req_valid <= '0;
        u_channel_1_req_valid <= '0;
        u_channel_2_req_valid <= '0;
        d_ch_0_rob_ack        <= '0;
        d_ch_1_rob_ack        <= '0;
        d_ch_2_rob_ack        <= '0;
    end else begin
        u_channel_0_req_valid <=  $random;
        u_channel_1_req_valid <=  $random;
        u_channel_2_req_valid <=  $random;
        d_ch_0_rob_ack        <=  $random;
        d_ch_1_rob_ack        <=  $random;
        d_ch_2_rob_ack        <=  $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        u_channel_0_req.op    <= '0;
        u_channel_0_req.addr  <= '0;
        u_channel_0_req.wdata <= '0;
    end else if (u_channel_0_req_valid & u_channel_0_req_ready) begin
        u_channel_0_req.addr  <= $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        u_channel_1_req.op    <= '0;
        u_channel_1_req.addr  <= '0;
        u_channel_1_req.wdata <= '0;
    end else if (u_channel_1_req_valid & u_channel_1_req_ready) begin
        u_channel_1_req.addr    <= $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        u_channel_2_req.op    <= '0;
        u_channel_2_req.addr  <= '0;
        u_channel_2_req.wdata <= '0;
    end else if (u_channel_2_req_valid & u_channel_2_req_ready) begin
        u_channel_2_req.addr  <= $random;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_ch_0_rob_ack <= '0;
        d_ch_1_rob_ack <= '0;
        d_ch_2_rob_ack <= '0;
    end else begin
        d_ch_0_rob_ack <= $random;
        d_ch_1_rob_ack <= $random;
        d_ch_2_rob_ack <= $random;
    end
end

kob # ( 
    .Cfg            (Cfg            ),
    .setWidth_t     (setWidth_t     ), 
    .tagWidth_t     (tagWidth_t     ),
    .wayIndexWidth_t(wayIndexWidth_t),
    .wbufWidth_t    (wbufWidth_t    ),
    .wayNum_t       (wayNum_t       ),
    .nlineWidth_t   (nlineWidth_t   ),
    .offsetWidth_t  (offsetWidth_t  ),
    .metaWidth_t    (metaWidth_t    ),
    .kobWidth_t     (kobWidth_t     )
) u_kob (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

endmodule