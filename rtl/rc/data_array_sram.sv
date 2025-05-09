module data_array_sram 
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
    parameter type lsqWidth_t      = logic,
    parameter type kobWidth_t      = logic
)
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        r_en                       ,
    input  setWidth_t                   r_addr                     ,
    input  logic            [  1: 0]    r_mask                     ,
    output logic            [255: 0]    r_data                     ,


    input  logic                        w_en                       ,
    input  setWidth_t                   w_addr                     ,
    input  logic            [  1: 0]    w_mask                     ,
    input  logic            [255: 0]    w_data                      

);

logic                       [  1: 0]    cs                         ;
logic                       [  1: 0]    we                         ;
setWidth_t                              addr                       ;
logic                       [127: 0]    r_data_hi                  ;
logic                       [127: 0]    r_data_lo                  ;
logic                       [127: 0]    w_data_hi                  ;
logic                       [127: 0]    w_data_lo                  ;

assign addr = we ? w_addr : r_addr;

assign cs = {r_en & r_mask[1] | w_en & w_mask[1], r_en & r_mask[0] | w_en & w_mask[0]};
assign we = { w_en & w_mask[1],  w_en & w_mask[0]}; 
assign {w_data_hi, w_data_lo} = w_data;
assign r_data = {r_data_hi, r_data_lo};

mpc_sram # (
    .ADDR_SIZE                         (Cfg.setWidth                       ),
    .DATA_SIZE                         (128                                )
) u_mpc_sram_0 (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .cs                                (cs[0]                              ),
    .we                                (we[0]                              ),
    .addr                              (addr                               ),
    .wdata                             (w_data_lo                          ),
    .rdata                             (r_data_lo                          )
);

mpc_sram # (
    .ADDR_SIZE                         (Cfg.setWidth                       ),
    .DATA_SIZE                         (128                                )
) u_mpc_sram_1s (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .cs                                (cs[1]                              ),
    .we                                (we[1]                              ),
    .addr                              (addr                               ),
    .wdata                             (w_data_hi                          ),
    .rdata                             (r_data_hi                          )
);


endmodule