module tb_xbar_wrapper;
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

logic                        d_bank_0_htu_valid         ;
logic                        d_bank_0_htu_ready         ;
bank_req_t                   d_bank_0_htu_req           ;
wbufWidth_t                  d_bank_0_htu_req_wbuf_id   ;

logic                        d_bank_1_htu_valid         ;
logic                        d_bank_1_htu_ready         ;
bank_req_t                   d_bank_1_htu_req           ;
wbufWidth_t                  d_bank_1_htu_req_wbuf_id   ;

logic                        d_bank_2_htu_valid         ;
logic                        d_bank_2_htu_ready         ;
bank_req_t                   d_bank_2_htu_req           ;
wbufWidth_t                  d_bank_2_htu_req_wbuf_id   ;

logic                        d_bank_3_htu_valid         ; 
logic                        d_bank_3_htu_ready         ; 
bank_req_t                   d_bank_3_htu_req           ; 
wbufWidth_t                  d_bank_3_htu_req_wbuf_id   ;

logic                        d_bank_0_wbuf_req_valid    ;
wbuf_req_t                   d_bank_0_wbuf_req          ;
logic                        d_bank_0_wbuf_rsp_free_valid;
wbufWidth_t                  d_bank_0_wbuf_rsp_free_id  ;

logic                        d_bank_1_wbuf_req_valid    ;
wbuf_req_t                   d_bank_1_wbuf_req          ;
logic                        d_bank_1_wbuf_rsp_free_valid;
wbufWidth_t                  d_bank_1_wbuf_rsp_free_id  ;

logic                        d_bank_2_wbuf_req_valid    ;
wbuf_req_t                   d_bank_2_wbuf_req          ;
logic                        d_bank_2_wbuf_rsp_free_valid;
wbufWidth_t                  d_bank_2_wbuf_rsp_free_id  ;

logic                        d_bank_3_wbuf_req_valid    ;
wbuf_req_t                   d_bank_3_wbuf_req          ;
logic                        d_bank_3_wbuf_rsp_free_valid;
wbufWidth_t                  d_bank_3_wbuf_rsp_free_id  ;

logic                        d_bank_0_rsp_valid         ;
logic                        d_bank_0_rsp_ready         ;
logic         [127: 0]       d_bank_0_rsp_data          ;
robWidth_t                   d_bank_0_rsp_rob_id        ;
logic         [  1: 0]       d_bank_0_rsp_channel_id    ;

logic                        d_bank_1_rsp_valid         ;  
logic                        d_bank_1_rsp_ready         ;  
logic         [127: 0]       d_bank_1_rsp_data          ;  
robWidth_t                   d_bank_1_rsp_rob_id        ;  
logic         [  1: 0]       d_bank_1_rsp_channel_id    ;

logic                        d_bank_2_rsp_valid         ; 
logic                        d_bank_2_rsp_ready         ; 
logic         [127: 0]       d_bank_2_rsp_data          ; 
robWidth_t                   d_bank_2_rsp_rob_id        ; 
logic         [  1: 0]       d_bank_2_rsp_channel_id    ; 

logic                        d_bank_3_rsp_valid         ;   
logic                        d_bank_3_rsp_ready         ;   
logic         [127: 0]       d_bank_3_rsp_data          ;   
robWidth_t                   d_bank_3_rsp_rob_id        ;   
logic         [  1: 0]       d_bank_3_rsp_channel_id    ;

logic         [  2: 0]       d_bank_0_crdt_rtn          ;
logic         [  2: 0]       d_bank_1_crdt_rtn          ;
logic         [  2: 0]       d_bank_2_crdt_rtn          ;
logic         [  2: 0]       d_bank_3_crdt_rtn          ;

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
    #25000;
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

    d_bank_0_htu_ready = 'd0;
    d_bank_1_htu_ready = 'd0;
    d_bank_2_htu_ready = 'd0;
    d_bank_3_htu_ready = 'd0;

    d_bank_0_wbuf_rsp_free_valid = 'd0;
    d_bank_0_wbuf_rsp_free_id = 'd0;

    d_bank_1_wbuf_rsp_free_valid = 'd0;
    d_bank_1_wbuf_rsp_free_id = 'd0;

    d_bank_2_wbuf_rsp_free_valid = 'd0;
    d_bank_2_wbuf_rsp_free_id = 'd0;

    d_bank_3_wbuf_rsp_free_valid = 'd0;
    d_bank_3_wbuf_rsp_free_id = 'd0;


    d_bank_0_rsp_valid     = 'd0;
    d_bank_0_rsp_data      = 'd0;
    d_bank_0_rsp_rob_id    = 'd0;
    d_bank_0_rsp_channel_id= 'd0;

    d_bank_1_rsp_valid     = 'd0;
    d_bank_1_rsp_data      = 'd0;
    d_bank_1_rsp_rob_id    = 'd0;
    d_bank_1_rsp_channel_id= 'd0;

    d_bank_2_rsp_valid     = 'd0; 
    d_bank_2_rsp_data      = 'd0; 
    d_bank_2_rsp_rob_id    = 'd0; 
    d_bank_2_rsp_channel_id= 'd0;

    d_bank_3_rsp_valid     = 'd0; 
    d_bank_3_rsp_data      = 'd0; 
    d_bank_3_rsp_rob_id    = 'd0; 
    d_bank_3_rsp_channel_id= 'd0;

    #500
    @(posedge clk)
    u_channel_0_req_bus_valid <= 'd1;
    u_channel_1_req_bus_valid <= 'd1;
    u_channel_2_req_bus_valid <= 'd0;

    u_channel_0_req_bus.op <= MPC_OP_LOAD;
    u_channel_0_req_bus.addr <= 32'b0000_0000_1010_1010;
    u_channel_0_req_bus.wdata <= 128'h0;

    u_channel_1_req_bus.op <= MPC_OP_LOAD;
    u_channel_1_req_bus.addr <= 32'b0000_0000_0101_0101;
    u_channel_1_req_bus.wdata <= 'd0;

    @(posedge clk)
    u_channel_0_req_bus_valid <= 'd1;
    u_channel_1_req_bus_valid <= 'd1;
    u_channel_2_req_bus_valid <= 'd1;

    u_channel_0_req_bus.op <= MPC_OP_LOAD;
    u_channel_0_req_bus.addr <= 32'b0000_0001_1001_1001;
    u_channel_0_req_bus.wdata <= 'd0;

    u_channel_1_req_bus.op <= MPC_OP_LOAD;
    u_channel_1_req_bus.addr <= 32'b0000_0011_1100_1100;
    u_channel_1_req_bus.wdata <= 128'h0;

    u_channel_2_req_bus.op <= MPC_OP_STORE;
    u_channel_2_req_bus.addr <= 32'b0000_0010_0011_0011;
    u_channel_2_req_bus.wdata <= 'd0;

    @ (posedge clk)
    u_channel_0_req_bus_valid <= 'd1;
    u_channel_1_req_bus_valid <= 'd0;
    u_channel_2_req_bus_valid <= 'd0;

    u_channel_0_req_bus.op <= MPC_OP_LOAD;
    u_channel_0_req_bus.addr <= 32'b0000_0000_0110_0110;
    u_channel_0_req_bus.wdata <= 'd0;

    u_channel_1_req_bus = 'd0;
    u_channel_2_req_bus = 'd0;

    @ (posedge clk)
    u_channel_0_req_bus_valid <= 'd0;
    u_channel_1_req_bus_valid <= 'd0;
    u_channel_2_req_bus_valid <= 'd0;

    u_channel_0_req_bus = 'd0;
    u_channel_1_req_bus = 'd0;
    u_channel_2_req_bus = 'd0;

    @ (posedge clk)
    
    @ (posedge clk)
    d_bank_0_htu_ready = 'd1;
    d_bank_1_htu_ready = 'd1;
    d_bank_2_htu_ready = 'd1;
    d_bank_3_htu_ready = 'd1;
    
    @(posedge clk)
    @(posedge clk)
    @(posedge clk)
    @(posedge clk)
    d_bank_2_wbuf_rsp_free_valid <= 'd1;
    d_bank_2_wbuf_rsp_free_id <= 'd0;

    @(posedge clk)
    d_bank_2_wbuf_rsp_free_valid <= 'd0;
    @(posedge clk)
    @(posedge clk)
    d_bank_1_rsp_valid <= 'd1;
    d_bank_1_rsp_data <= 'hbbbb_bbbb_bbbb_bbbb;
    d_bank_1_rsp_rob_id <= 'd0;
    d_bank_1_rsp_channel_id <= 'd0;

    d_bank_0_rsp_valid <= 'd1;
    d_bank_0_rsp_data <= 'hdddd_dddd_dddd_dddd;
    d_bank_0_rsp_rob_id <= 'd0;
    d_bank_0_rsp_channel_id <= 'd1;

    @(posedge clk)
    d_bank_1_rsp_valid <= 'd0;
    d_bank_1_rsp_data <= 'h0;
    d_bank_1_rsp_rob_id <= 'd0;
    d_bank_1_rsp_channel_id <= 'd0;

    d_bank_0_rsp_valid <= 'd1;
    d_bank_0_rsp_data <= 'hcccc_cccc_cccc_cccc;
    d_bank_0_rsp_rob_id <= 'd1;
    d_bank_0_rsp_channel_id <= 'd0;

    @(posedge clk)
    d_bank_0_rsp_valid <= 'd1;
    d_bank_0_rsp_data <= 'haaaa_aaaa_aaaa_aaaa;
    d_bank_0_rsp_rob_id <= 'd0;
    d_bank_0_rsp_channel_id <= 'd0;
    
    d_bank_3_rsp_valid <= 'd1;
    d_bank_3_rsp_data <= 'hbbbb_bbbb_bbbb_bbbb;
    d_bank_3_rsp_rob_id <= 'd0;
    d_bank_3_rsp_channel_id <= 'd1;

    @(posedge clk)
    d_bank_0_rsp_valid <= 'd0;
    d_bank_0_rsp_data <= 'h0;
    d_bank_0_rsp_rob_id <= 'd0;
    d_bank_0_rsp_channel_id <= 'd0;

    d_bank_3_rsp_valid <= 'd0;
    d_bank_3_rsp_data <= 'h0;
    d_bank_3_rsp_rob_id <= 'd0;
    d_bank_3_rsp_channel_id <= 'd0;


end


xbar_wrapper # (
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
            .kobWidth_t                        (kobWidth_t                         )
) u_rtn_xbar_core (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .*
);

endmodule