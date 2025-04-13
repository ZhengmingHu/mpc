module wbuf_id_gen_entry
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    output logic                        ready                      ,

    input  logic                        alloc                      ,
    input  logic                        free
);

logic   entry_vld;
logic   entry_nxt;
logic   entry_en;

assign ready     = !entry_vld;
assign entry_en  = alloc | free;
assign entry_nxt = alloc;

ns_gnrl_dfflr # (1) entry_vld_dfflr (entry_en, entry_nxt, entry_vld, clk, rst_n);

endmodule

module wbuf_id_gen 
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
    parameter type metaWidth_t     = logic
)
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        alloc_valid                ,
    output logic                        alloc_ready                ,
    output wbufWidth_t                  alloc_id                   ,

    input  logic                        free_valid                 ,            
    input  wbufWidth_t                  free_id                                            

);

logic [Cfg.u.wbufSize-1:0] wbuf_ready;
logic [Cfg.u.wbufSize-1:0] wbuf_alloc;
logic [Cfg.u.wbufSize-1:0] wbuf_free;

priority_encoder # (Cfg.u.wbufSize) u_priority_encoder (wbuf_ready, alloc_id);

generate
    for (genvar i = 0; i < Cfg.u.wbufSize; i++)
    begin : wbuf_id_entry_gen
        assign wbuf_alloc[i] = alloc_id == i & alloc_valid & alloc_ready;
        assign wbuf_free [i] = free_id  == i & free_valid;
        wbuf_id_gen_entry u_wbuf_id_gen_entry (clk, rst_n, wbuf_ready[i], wbuf_alloc[i], wbuf_free[i]);
    end
endgenerate

assign alloc_ready = |wbuf_ready;


endmodule