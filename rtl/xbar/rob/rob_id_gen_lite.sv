module rob_id_gen_lite
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
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        u_valid                    ,                      
    output robWidth_t                   d_rob_id    
);

robWidth_t          rob_id_nxt             ;
logic               rob_id_en              ;
robWidth_t          rob_id                 ;

assign rob_id_nxt = rob_id + 'd1;
assign rob_id_en  = u_valid     ;
ns_gnrl_dfflr # (Cfg.robWidth) rob_id_dfflr (rob_id_en, rob_id_nxt, rob_id, clk, rst_n);

assign d_rob_id = rob_id;

endmodule