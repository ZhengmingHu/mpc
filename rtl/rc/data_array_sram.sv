`include "mpc_defs.svh"

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
setWidth_t                              addr               [  1: 0];
logic                       [127: 0]    r_data_hi                  ;
logic                       [127: 0]    r_data_lo                  ;
logic                       [127: 0]    w_data_hi                  ;
logic                       [127: 0]    w_data_lo                  ;

assign addr[0] = we[0] ? w_addr : r_addr;
assign addr[1] = we[1] ? w_addr : r_addr;

assign cs = {r_en & r_mask[1] | w_en & w_mask[1], r_en & r_mask[0] | w_en & w_mask[0]};
assign we = { w_en & w_mask[1],  w_en & w_mask[0]}; 
assign {w_data_hi, w_data_lo} = w_data;
assign r_data = {r_data_hi, r_data_lo};


`ifdef FPGA_7100

logic                       [  1: 0]    regcea_nxt, regcea        ; 

assign regcea_nxt = cs & ~we;

ns_gnrl_dfflr #(2) u_ren (1'b1, regcea_nxt, regcea, clk, rst_n);

xpm_memory_spram #(
   .ADDR_WIDTH_A(6),              // DECIMAL
   .AUTO_SLEEP_TIME(0),           // DECIMAL
   .BYTE_WRITE_WIDTH_A(128),       // DECIMAL
   .CASCADE_HEIGHT(0),            // DECIMAL
   .ECC_MODE("no_ecc"),           // String
   .MEMORY_INIT_FILE("none"),     // String
   .MEMORY_INIT_PARAM("0"),       // String
   .MEMORY_OPTIMIZATION("true"),  // String
   .MEMORY_PRIMITIVE("auto"),     // String
   .MEMORY_SIZE(8192),            // DECIMAL
   .MESSAGE_CONTROL(0),           // DECIMAL
   .READ_DATA_WIDTH_A(128),        // DECIMAL
   .READ_LATENCY_A(2),            // DECIMAL
   .READ_RESET_VALUE_A("0"),      // String
   .RST_MODE_A("SYNC"),           // String
   .SIM_ASSERT_CHK(0),            // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .USE_MEM_INIT(1),              // DECIMAL
   .USE_MEM_INIT_MMI(0),          // DECIMAL
   .WAKEUP_TIME("disable_sleep"), // String
   .WRITE_DATA_WIDTH_A(128),       // DECIMAL
   .WRITE_MODE_A("read_first"),   // String
   .WRITE_PROTECT(1)              // DECIMAL
)
xpm_memory_spram_inst_0 (
   .dbiterra(),             // 1-bit output: Status signal to indicate double bit error occurrence on the data output of port A.
   .douta(r_data_lo),                   // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
   .sbiterra(),             // 1-bit output: Status signal to indicate single bit error occurrence on the data output of port A.
   .addra(addr[0]),                   // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
   .clka(clk),                     // 1-bit input: Clock signal for port A.
   .dina(w_data_lo),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
   .ena(cs[0]),                       // 1-bit input: Memory enable signal for port A. Must be high on clock cycles when read or write operations
                                    // are initiated. Pipelined internally.

   .injectdbiterra('d0), // 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability
                                    // is not available in "decode_only" mode).

   .injectsbiterra('d0), // 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability
                                    // is not available in "decode_only" mode).

   .regcea(regcea[0]),                 // 1-bit input: Clock Enable for the last register stage on the output data path.
   .rsta(rst_n),                     // 1-bit input: Reset signal for the final port A output register stage. Synchronously resets output port
                                    // douta to the value specified by parameter READ_RESET_VALUE_A.

   .sleep('d0),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
   .wea(we[0])                        // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit
                                    // wide when word-wide writes are used. In byte-wide write configurations, each bit controls the writing one
                                    // byte of dina to address addra. For example, to synchronously write only bits [15-8] of dina when
                                    // WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);

xpm_memory_spram #(
   .ADDR_WIDTH_A(6),              // DECIMAL
   .AUTO_SLEEP_TIME(0),           // DECIMAL
   .BYTE_WRITE_WIDTH_A(128),       // DECIMAL
   .CASCADE_HEIGHT(0),            // DECIMAL
   .ECC_MODE("no_ecc"),           // String
   .MEMORY_INIT_FILE("none"),     // String
   .MEMORY_INIT_PARAM("0"),       // String
   .MEMORY_OPTIMIZATION("true"),  // String
   .MEMORY_PRIMITIVE("auto"),     // String
   .MEMORY_SIZE(8192),            // DECIMAL
   .MESSAGE_CONTROL(0),           // DECIMAL
   .READ_DATA_WIDTH_A(128),        // DECIMAL
   .READ_LATENCY_A(2),            // DECIMAL
   .READ_RESET_VALUE_A("0"),      // String
   .RST_MODE_A("SYNC"),           // String
   .SIM_ASSERT_CHK(0),            // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .USE_MEM_INIT(1),              // DECIMAL
   .USE_MEM_INIT_MMI(0),          // DECIMAL
   .WAKEUP_TIME("disable_sleep"), // String
   .WRITE_DATA_WIDTH_A(128),       // DECIMAL
   .WRITE_MODE_A("read_first"),   // String
   .WRITE_PROTECT(1)              // DECIMAL
)
xpm_memory_spram_inst_1 (
   .dbiterra(),             // 1-bit output: Status signal to indicate double bit error occurrence on the data output of port A.
   .douta(r_data_hi),                   // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
   .sbiterra(),             // 1-bit output: Status signal to indicate single bit error occurrence on the data output of port A.
   .addra(addr[1]),                   // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
   .clka(clk),                     // 1-bit input: Clock signal for port A.
   .dina(w_data_hi),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
   .ena(cs[1]),                       // 1-bit input: Memory enable signal for port A. Must be high on clock cycles when read or write operations
                                    // are initiated. Pipelined internally.

   .injectdbiterra('d0), // 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability
                                    // is not available in "decode_only" mode).

   .injectsbiterra('d0), // 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability
                                    // is not available in "decode_only" mode).

   .regcea(regcea[1]),                 // 1-bit input: Clock Enable for the last register stage on the output data path.
   .rsta(rst_n),                     // 1-bit input: Reset signal for the final port A output register stage. Synchronously resets output port
                                    // douta to the value specified by parameter READ_RESET_VALUE_A.

   .sleep('d0),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
   .wea(we[1])                        // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit
                                    // wide when word-wide writes are used. In byte-wide write configurations, each bit controls the writing one
                                    // byte of dina to address addra. For example, to synchronously write only bits [15-8] of dina when
                                    // WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
);

`else
mpc_sram # (
    .ADDR_SIZE                         (Cfg.setWidth                       ),
    .DATA_SIZE                         (128                                )
) u_mpc_sram_0 (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .cs                                (cs[0]                              ),
    .we                                (we[0]                              ),
    .addr                              (addr[0]                            ),
    .wdata                             (w_data_lo                          ),
    .rdata                             (r_data_lo                          )
);

mpc_sram # (
    .ADDR_SIZE                         (Cfg.setWidth                       ),
    .DATA_SIZE                         (128                                )
) u_mpc_sram_1 (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .cs                                (cs[1]                              ),
    .we                                (we[1]                              ),
    .addr                              (addr[1]                            ),
    .wdata                             (w_data_hi                          ),
    .rdata                             (r_data_hi                          )
);
`endif

endmodule