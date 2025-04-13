// Sparse Write Buffer

module rob_ptr_gen # (
    parameter SWB_DEPTH  = 8
)(
    input  logic                               clk                        ,
    input  logic                               rst_n                      ,

    input  logic                               w_req_valid                ,
    input  logic    [$clog2(SWB_DEPTH)-1:0]    w_req_ptr                  ,

    input  logic                               r_req_valid                ,

    input  logic    [        SWB_DEPTH-1:0]    entry_ready                ,
    output logic    [$clog2(SWB_DEPTH)-1:0]    r_ptr                      ,
    output logic    [$clog2(SWB_DEPTH)-1:0]    bottom_ptr                  

);

logic    [        SWB_DEPTH-1:0]    entry_ready_shifted                ;
logic    [        SWB_DEPTH-1:0]    entry_ready_shifted_ored           ;
logic    [        SWB_DEPTH-1:0]    entry_ready_shifted_first          ;

logic                               r_ptr_ena                          ;
logic    [$clog2(SWB_DEPTH)-1:0]    r_ptr_nxt                          ;

logic                               btm_ptr_ena                        ;
logic    [$clog2(SWB_DEPTH)-1:0]    btm_ptr                            ;
logic    [$clog2(SWB_DEPTH)-1:0]    btm_ptr_nxt                        ;
logic    [$clog2(SWB_DEPTH)-1:0]    btm_ptr_nxt_array   [SWB_DEPTH-1:0];

// read pointer update ////////////////////////////////////////////

assign  r_ptr_ena   = r_req_valid                                      ;
assign  r_ptr_nxt   = r_ptr + 1'b1                                     ;
ns_gnrl_dfflr  # ($clog2(SWB_DEPTH)) r_ptr_dfflr (r_ptr_ena, r_ptr_nxt, r_ptr, clk, rst_n);

// bottom ptr update //////////////////////////////////////////////

assign  entry_ready_shifted = (entry_ready >> btm_ptr) | (entry_ready << (SWB_DEPTH - btm_ptr));

generate
    for (genvar i = 0; i < SWB_DEPTH; i++)
    begin
        assign btm_ptr_nxt_array[i] = btm_ptr + i + 1'b1;
    end
endgenerate

generate
  for (genvar i = 0; i < SWB_DEPTH; i = i+1)
  begin
    assign entry_ready_shifted_ored[i] = |entry_ready_shifted[i:0];
  end
endgenerate

generate
    assign entry_ready_shifted_first[0] = entry_ready_shifted_ored[0];
    for (genvar i = 1; i < SWB_DEPTH; i++)
    begin
        assign entry_ready_shifted_first[i] = entry_ready_shifted_ored[i] & (~entry_ready_shifted_ored[i-1]);
    end
endgenerate

ns_mux1h # ($clog2(SWB_DEPTH), SWB_DEPTH) btm_ptr_mux1h (btm_ptr_nxt_array, entry_ready_shifted_first, btm_ptr_nxt);
assign btm_ptr_ena = w_req_valid & w_req_ptr == btm_ptr;
ns_gnrl_dfflr  # ($clog2(SWB_DEPTH)) btm_ptr_dfflr (btm_ptr_ena, btm_ptr_nxt, btm_ptr, clk, rst_n);
assign bottom_ptr = btm_ptr;


endmodule