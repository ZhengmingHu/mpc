module credit_manager
    import mpc_types::*;
#(
    parameter mpc_cfg_t Cfg = '0,   
    parameter type setWidth_t      = logic,
    parameter type tagWidth_t      = logic,
    parameter type wayIndexWidth_t = logic,
    parameter type wbufWidth_t     = logic,
    parameter type wayNum_t        = logic,
    parameter type nlineWidth_t    = logic,
    parameter type offsetWidth_t   = logic,
    parameter type metaWidth_t     = logic,
    parameter type robWidth_t      = logic,
    parameter type lsqWidth_t      = logic
)   
(
    input  logic                                   clk                        ,
    input  logic                                   rst_n                      ,

    // 1. from upstream htu req
    input  logic                                   u_htu_valid                ,
    input  logic        [             2: 0]        u_htu_channel_1hot_id      ,
    input  logic        [             2: 0]        u_htu_op                   ,

    // 2. lsq interface
    input  lsqWidth_t                              lsq_w_ptr                  ,
    input  lsqWidth_t                              lsq_btm_ptr                ,
    input  logic        [Cfg.u.lsqSize-1:0]        lsq_entry_vld              ,
    input  logic        [             1: 0]        lsq_entry_channel_id [Cfg.u.lsqSize-1:0],

    // 3. lsq entry credit grant
    output logic        [Cfg.u.lsqSize-1:0]        entry_can_execute          ,

    // 4. xbar credit return interface
    input  logic        [              2:0]        u_xbar_crdt_rtn   

);

logic [  1: 0]                                     u_htu_channel_id;

logic [Cfg.u.lsqSize-1:0]                          n_entry_can_execute;

logic [Cfg.u.lsqSize-1:0]                          pending_entry              ;
logic [Cfg.u.lsqSize-1:0]                          pending_entry_decouple [  2: 0];

lsqWidth_t                                         pending_entry_cnt_decouple [  2: 0];
lsqWidth_t                                         n_pending_entry_cnt_decouple [  2: 0];
robWidth_t                                         remain_crdt_cnt_decouple [  2: 0];
robWidth_t                                         n_remain_crdt_cnt_decouple [  2: 0];

logic                                              no_pending_entry_in_access_channel;
logic                                              remain_crdt_in_access_channel;

logic [  2: 0]                                     have_pending_entry_decouple;
logic [  2: 0]                                     remain_crdt_decouple;

// pending entry with credits remaining, in this case, the oldest entry can be granted with credit
logic [  2: 0]                                     have_pending_entry_can_grt_crdt_decouple;

lsqWidth_t                                         oldest_pending_entry_decouple [  2: 0];

ns_1hot2bin # (3) u_htu_channel_1hot2bin (u_htu_channel_1hot_id, u_htu_channel_id);

assign pending_entry = ~entry_can_execute & lsq_entry_vld;

assign no_pending_entry_in_access_channel = u_htu_valid &  ~|pending_entry_cnt_decouple[u_htu_channel_id];
assign remain_crdt_in_access_channel = u_htu_valid & |remain_crdt_cnt_decouple[u_htu_channel_id];

generate
    for (genvar i = 0; i < 3; i++) 
    begin: credit_manager_decouple
        // calculate in each channel, whether there is pending instr can be granted credits
        // 1> pending instr exists
        // 2> remain several credits
        assign have_pending_entry_decouple[i] = |pending_entry_cnt_decouple[i];
        assign remain_crdt_decouple[i] = |remain_crdt_cnt_decouple[i];
        assign have_pending_entry_can_grt_crdt_decouple[i] = have_pending_entry_decouple[i] &&
                                                         (remain_crdt_decouple[i] || |u_xbar_crdt_rtn[i]);
        // iterate through all pending instructions in each channel
        always_comb begin
            pending_entry_decouple[i] = pending_entry;
            for (int j = 0; j < int'(Cfg.u.lsqSize); j++)
            begin: pending_instruction_gen
                if (lsq_entry_channel_id[j] != i)
                    pending_entry_decouple[i][j] = 1'b0;
            end
        end
        // pick out the oldest pending entry
        ns_gnrl_weight_with_ref # (Cfg.u.lsqSize) oldest_pending_entry_arbiter (clk, rst_n, oldest_pending_entry_decouple[i], pending_entry_decouple[i], lsq_btm_ptr);
        
    end
endgenerate

always_comb begin
    n_entry_can_execute = entry_can_execute;
    n_remain_crdt_cnt_decouple = remain_crdt_cnt_decouple;
    n_pending_entry_cnt_decouple = pending_entry_cnt_decouple;
    if (u_htu_valid) begin
        if (is_load(u_htu_op) | is_rae(u_htu_op)) begin
            // when there is an instruction comming to isu in a certain channel, check whether there is credits remaining
            // 1> no other pending entries && remain credits
            if (no_pending_entry_in_access_channel && remain_crdt_in_access_channel) begin
                n_entry_can_execute[lsq_w_ptr] = 1'b1;
                n_remain_crdt_cnt_decouple[u_htu_channel_id] = remain_crdt_cnt_decouple[u_htu_channel_id] - 'b1;
                n_pending_entry_cnt_decouple[u_htu_channel_id] = pending_entry_cnt_decouple[u_htu_channel_id];
            end
            // 2> have pending entries || no credit in selected channel
            else begin
                // when a new instr enter lsq, there is a pending entry can be granted new released credit 
                if (have_pending_entry_can_grt_crdt_decouple[u_htu_channel_id]) begin
                    n_entry_can_execute[lsq_w_ptr] = 1'b0;
                    n_entry_can_execute[oldest_pending_entry_decouple[u_htu_channel_id]] = 1'b1;
                    n_remain_crdt_cnt_decouple[u_htu_channel_id] = remain_crdt_cnt_decouple[u_htu_channel_id] - 1'b1;
                    n_pending_entry_cnt_decouple[u_htu_channel_id] = pending_entry_cnt_decouple[u_htu_channel_id];
                end
                // when a new instr enter lsq, no pending entry can be granted new released credit
                else begin
                    n_entry_can_execute[lsq_w_ptr] = 1'b0;
                    n_remain_crdt_cnt_decouple[u_htu_channel_id] = remain_crdt_cnt_decouple[u_htu_channel_id];
                    n_pending_entry_cnt_decouple[u_htu_channel_id] = pending_entry_cnt_decouple[u_htu_channel_id] + 'b1;
                end
            end
        end
        else if (is_store(u_htu_op) | is_wae(u_htu_op)) begin
            n_entry_can_execute[lsq_w_ptr] = 1'b1;
            // the channel related to new instr has pending entry that can be granted credit
            if (have_pending_entry_can_grt_crdt_decouple[u_htu_channel_id]) begin
                n_entry_can_execute[oldest_pending_entry_decouple[u_htu_channel_id]] = 1'b1;
                n_remain_crdt_cnt_decouple[u_htu_channel_id] = remain_crdt_cnt_decouple[u_htu_channel_id] - 'b1;
                n_pending_entry_cnt_decouple[u_htu_channel_id] = pending_entry_cnt_decouple[u_htu_channel_id] - 'b1;
            end
            // the channel related to new instr doesn't have pending entry that can be granted credit
            else begin
                n_remain_crdt_cnt_decouple[u_htu_channel_id] = remain_crdt_cnt_decouple[u_htu_channel_id];
                n_pending_entry_cnt_decouple[u_htu_channel_id] = pending_entry_cnt_decouple[u_htu_channel_id];
            end
        end
    end 
    // if there is new instructions in a certain channel, we also need to check 
    // whether other pending entries in other channel can be granted credit
    if (u_htu_valid) begin
        if (u_htu_channel_id == 'd0) begin
            if (have_pending_entry_can_grt_crdt_decouple[1]) begin
                n_entry_can_execute[oldest_pending_entry_decouple[1]] = 1'b1;
                n_remain_crdt_cnt_decouple[1] = remain_crdt_cnt_decouple[1] - 'b1;
                n_pending_entry_cnt_decouple[1] = pending_entry_cnt_decouple[1] - 'b1;
            end
            if (have_pending_entry_can_grt_crdt_decouple[2]) begin
                n_entry_can_execute[oldest_pending_entry_decouple[2]] = 1'b1;
                n_remain_crdt_cnt_decouple[2] = remain_crdt_cnt_decouple[2] - 'b1;
                n_pending_entry_cnt_decouple[2] = pending_entry_cnt_decouple[2] - 'b1;
            end
        end
        if (u_htu_channel_id == 'd1) begin
            if (have_pending_entry_can_grt_crdt_decouple[0]) begin
                n_entry_can_execute[oldest_pending_entry_decouple[0]] = 1'b1;
                n_remain_crdt_cnt_decouple[0] = remain_crdt_cnt_decouple[0] - 'b1;
                n_pending_entry_cnt_decouple[0] = pending_entry_cnt_decouple[0] - 'b1;
            end
            if (have_pending_entry_can_grt_crdt_decouple[2]) begin
                n_entry_can_execute[oldest_pending_entry_decouple[2]] = 1'b1;
                n_remain_crdt_cnt_decouple[2] = remain_crdt_cnt_decouple[2] - 'b1;
                n_pending_entry_cnt_decouple[2] = pending_entry_cnt_decouple[2] - 'b1;
            end
        end
        if (u_htu_channel_id == 'd2) begin
            if (have_pending_entry_can_grt_crdt_decouple[1]) begin
                n_entry_can_execute[oldest_pending_entry_decouple[1]] = 1'b1;
                n_remain_crdt_cnt_decouple[1] = remain_crdt_cnt_decouple[1] - 'b1;
                n_pending_entry_cnt_decouple[1] = pending_entry_cnt_decouple[1] - 'b1;
            end
            if (have_pending_entry_can_grt_crdt_decouple[0]) begin
                n_entry_can_execute[oldest_pending_entry_decouple[0]] = 1'b1;
                n_remain_crdt_cnt_decouple[0] = remain_crdt_cnt_decouple[0] - 'b1;
                n_pending_entry_cnt_decouple[0] = pending_entry_cnt_decouple[0] - 'b1;
            end
        end
    end
    else begin
        if (have_pending_entry_can_grt_crdt_decouple[0]) begin
            n_entry_can_execute[oldest_pending_entry_decouple[0]] = 1'b1;
            n_remain_crdt_cnt_decouple[0] = remain_crdt_cnt_decouple[0] - 'b1;
            n_pending_entry_cnt_decouple[0] = pending_entry_cnt_decouple[0] - 'b1;
        end
        if (have_pending_entry_can_grt_crdt_decouple[1]) begin
            n_entry_can_execute[oldest_pending_entry_decouple[1]] = 1'b1;
            n_remain_crdt_cnt_decouple[1] = remain_crdt_cnt_decouple[1] - 'b1;
            n_pending_entry_cnt_decouple[1] = pending_entry_cnt_decouple[1] - 'b1;
        end
        if (have_pending_entry_can_grt_crdt_decouple[2]) begin
            n_entry_can_execute[oldest_pending_entry_decouple[2]] = 1'b1;
            n_remain_crdt_cnt_decouple[2] = remain_crdt_cnt_decouple[2] - 'b1;
            n_pending_entry_cnt_decouple[2] = pending_entry_cnt_decouple[2] - 'b1;
        end
    end
end


always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        entry_can_execute <= 'd0;
    end
    else begin
        entry_can_execute <= n_entry_can_execute;
    end
end

generate 
    for (genvar i = 0; i < 3; i++)
    begin
        always @ (posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                pending_entry_cnt_decouple[i] <= 'd0;
                remain_crdt_cnt_decouple[i] <= {{Cfg.robWidth{1'b1}}};
            end
            else begin
                pending_entry_cnt_decouple[i] <= n_pending_entry_cnt_decouple[i] + u_xbar_crdt_rtn[i];
                remain_crdt_cnt_decouple[i] <= n_remain_crdt_cnt_decouple[i];
            end
        end
    end
endgenerate

endmodule