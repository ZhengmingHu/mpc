// Sparse Read Buffer

module lsq_ptr_gen # (
    parameter SRB_DEPTH  = 8
)(
    input  logic                               clk                        ,
    input  logic                               rst_n                      ,

    input  logic                               w_req_valid                ,

    input  logic                               r_req_valid                ,
    input  logic    [$clog2(SRB_DEPTH)-1:0]    r_req_ptr                  ,

    input  logic    [        SRB_DEPTH-1:0]    entry_valid                ,
    output logic    [$clog2(SRB_DEPTH)-1:0]    w_ptr                      ,
    output logic    [$clog2(SRB_DEPTH)-1:0]    bottom_ptr                  

);

logic    [        SRB_DEPTH-1:0]    entry_valid_shifted                ;
logic    [        SRB_DEPTH-1:0]    entry_valid_shifted_ored           ;
logic    [        SRB_DEPTH-1:0]    entry_valid_shifted_first          ;

logic                               w_ptr_ena                          ;
logic    [$clog2(SRB_DEPTH)-1:0]    w_ptr_nxt                          ;

logic                               btm_ptr_ena                        ;
logic    [$clog2(SRB_DEPTH)-1:0]    btm_ptr                            ;
logic    [$clog2(SRB_DEPTH)-1:0]    btm_ptr_nxt                        ;
logic    [$clog2(SRB_DEPTH)-1:0]    btm_ptr_nxt_array   [SRB_DEPTH-1:0];

// write pointer update ////////////////////////////////////////////

assign  w_ptr_ena   = w_req_valid                                      ;
assign  w_ptr_nxt   = w_ptr + 1'b1                                     ;
ns_gnrl_dfflr  # ($clog2(SRB_DEPTH)) w_ptr_dfflr (w_ptr_ena, w_ptr_nxt, w_ptr, clk, rst_n);

// bottom ptr update //////////////////////////////////////////////

assign  entry_valid_shifted = (entry_valid >> btm_ptr) | (entry_valid << (SRB_DEPTH - btm_ptr));

generate
    for (genvar i = 0; i < SRB_DEPTH; i++)
    begin
        assign btm_ptr_nxt_array[i] = btm_ptr + i + 1'b1;
    end
endgenerate

generate
  for (genvar i = 0; i < SRB_DEPTH; i = i+1)
  begin
    assign entry_valid_shifted_ored[i] = |entry_valid_shifted[i:0];
  end
endgenerate

generate
    assign entry_valid_shifted_first[0] = entry_valid_shifted_ored[0];
    for (genvar i = 1; i < SRB_DEPTH; i++)
    begin
        assign entry_valid_shifted_first[i] = entry_valid_shifted_ored[i] & (~entry_valid_shifted_ored[i-1]);
    end
endgenerate

ns_mux1h # ($clog2(SRB_DEPTH), SRB_DEPTH) btm_ptr_mux1h (btm_ptr_nxt_array, entry_valid_shifted_first, btm_ptr_nxt);
assign btm_ptr_ena = r_req_valid & r_req_ptr == btm_ptr;
ns_gnrl_dfflr  # ($clog2(SRB_DEPTH)) btm_ptr_dfflr (btm_ptr_ena, btm_ptr_nxt, btm_ptr, clk, rst_n);
assign bottom_ptr = btm_ptr;


endmodule