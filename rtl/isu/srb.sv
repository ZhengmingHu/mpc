// Sparse Read Buffer

module srb # (
    parameter DATA_WIDTH = 32,
    parameter SRB_DEPTH  = 8
)(
    input  logic                               clk                        ,
    input  logic                               rst_n                      ,

    input  logic                               w_req_valid                ,
    output logic                               w_req_ready                ,
    input  logic    [       DATA_WIDTH-1:0]    w_req_data                 ,

    input  logic                               r_req_valid                ,
    input  logic    [$clog2(SRB_DEPTH)-1:0]    r_req_idx                  ,
    output logic                               r_req_ready                ,

    output logic                               r_rsp_valid                ,
    output logic    [       DATA_WIDTH-1:0]    r_rsp_data                 ,                           
    input  logic                               r_rsp_ready                ,

    output logic    [        SRB_DEPTH-1:0]    entry_valid                ,
    output logic    [$clog2(SRB_DEPTH)-1:0]    bottom_id                  

);

logic    w_req_hsked, r_req_hsked, r_rsp_hsked                         ;

logic    [        SRB_DEPTH-1:0]    entry_valid_set                    ;
logic    [        SRB_DEPTH-1:0]    entry_valid_clr                    ;
logic    [        SRB_DEPTH-1:0]    entry_valid_ena                    ;
logic    [        SRB_DEPTH-1:0]    entry_valid_nxt                    ;
logic    [        SRB_DEPTH-1:0]    entry_valid_shifted                ;
logic    [        SRB_DEPTH-1:0]    entry_valid_shifted_ored           ;
logic    [        SRB_DEPTH-1:0]    entry_valid_shifted_first          ;    

logic    [        SRB_DEPTH-1:0]    entry_ena                          ;
logic    [       DATA_WIDTH-1:0]    entry               [SRB_DEPTH-1:0]; 
logic    [       DATA_WIDTH-1:0]    entry_nxt           [SRB_DEPTH-1:0]; 

logic                               w_ptr_ena                          ;
logic    [$clog2(SRB_DEPTH)-1:0]    w_ptr                              ;
logic    [$clog2(SRB_DEPTH)-1:0]    w_ptr_nxt                          ;

logic                               btm_ptr_ena                        ;
logic    [$clog2(SRB_DEPTH)-1:0]    btm_ptr                            ;
logic    [$clog2(SRB_DEPTH)-1:0]    btm_ptr_nxt                        ;
logic    [$clog2(SRB_DEPTH)-1:0]    btm_ptr_nxt_array   [SRB_DEPTH-1:0];

assign  w_req_ready = ~(btm_ptr == w_ptr)                              ;
assign  w_req_hsked = w_req_valid & w_req_ready                        ;

assign  r_req_hsked = r_req_valid & r_req_ready                        ;
assign  r_rsp_hsked = r_rsp_valid & r_req_ready                        ;

// write pointer update ////////////////////////////////////////////

assign  w_ptr_ena   = w_req_hsked                                      ;
assign  w_ptr_nxt   = w_ptr + 1'b1                                     ;
ns_gnrl_dfflr  # ($clog2(SRB_DEPTH)) w_ptr_dfflr (w_ptr_ena, w_ptr_nxt, w_ptr, clk, rst_n);


// read data ///////////////////////////////////////////////////////

assign  r_req_ready = r_rsp_ready                                      ;
assign  r_rsp_valid = r_req_valid & entry_valid[r_req_idx]             ;

assign  r_rsp_data  = entry[r_req_idx]                                 ;

// write data //////////////////////////////////////////////////////

generate
    for (genvar i = 0; i < SRB_DEPTH; i++)
    begin
        assign entry_valid_set[i] = (w_ptr == i) & w_req_hsked;
        assign entry_valid_clr[i] = (r_req_idx == i) & r_rsp_hsked;
        assign entry_valid_ena[i] = entry_valid_set[i] | entry_valid_clr[i];
        assign entry_valid_nxt[i] = entry_valid_set[i] | (~entry_valid_clr[i] & entry_valid[i]);
        ns_gnrl_dfflr  # (1) entry_valid_dfflr (entry_valid_ena[i], entry_valid_nxt[i], entry_valid[i], clk, rst_n);

        assign entry_ena[i] = (w_ptr == i) & w_req_hsked;
        assign entry_nxt[i] = w_req_data;
        ns_gnrl_dfflr  # (DATA_WIDTH) entry_dfflr (entry_ena[i], entry_nxt[i], entry[i], clk, rst_n);
    end
endgenerate

// bottom ptr update //////////////////////////////////////////////

assign  entry_valid_shifted = (entry_valid_nxt >> btm_ptr) | (entry_valid_nxt << (SRB_DEPTH - btm_ptr));

generate
    for (genvar i = 0; i < SRB_DEPTH; i++)
    begin
        assign btm_ptr_nxt_array[i] = btm_ptr + i;
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
assign btm_ptr_ena = r_rsp_hsked;
ns_gnrl_dfflrs  # ($clog2(SRB_DEPTH)) btm_ptr_dfflr (btm_ptr_ena, btm_ptr_nxt, btm_ptr, clk, rst_n);
assign bottom_id = btm_ptr;


endmodule