`include "mpc_defs.svh"

module tag_array
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

    input  logic                        tag_read_valid             ,
    output logic                        tag_read_ready             ,
    input  setWidth_t                   tag_read_set               ,
    output tagWidth_t                   tag_read_rsp   [Cfg.wayNum-1:0], 
    
    input  logic                        tag_write_valid            ,
    output logic                        tag_write_ready            ,
    input  setWidth_t                   tag_write_set              ,
    input  wayNum_t                     tag_write_way_en           ,
    input  tagWidth_t                   tag_write_data           
);

wayNum_t                                tag_cs;
wayNum_t                                tag_we;
setWidth_t                              tag_addr;
tagWidth_t                              tag_wentry;
tagWidth_t                              tag_rentry [Cfg.wayNum-1:0];

assign tag_read_ready = !tag_write_valid;
assign tag_write_ready = 1'b1;

generate 
    for (genvar tag_w = 0; tag_w < int'(Cfg.wayNum); tag_w++)
    begin : tag_sel_gen
        assign tag_cs[tag_w] = (tag_read_valid  & tag_read_ready) | 
                               (tag_write_valid & tag_write_ready & tag_write_way_en[tag_w]);
        assign tag_we[tag_w] = (tag_write_valid & tag_write_ready & tag_write_way_en[tag_w]);
    end
endgenerate
assign tag_addr     = |tag_we ? tag_write_set : tag_read_set;
assign tag_wentry   = tag_write_data;
assign tag_read_rsp = tag_rentry; 

`ifdef FPGA_7100
wayNum_t                               regcea_nxt, regcea        ; 

assign regcea_nxt = tag_cs & ~tag_we;

ns_gnrl_dfflr #(Cfg.wayNum) u_ren (1'b1, regcea_nxt, regcea, clk, rst_n);

generate 
    for (genvar tag_w = 0; tag_w < int'(Cfg.wayNum); tag_w++)
    begin : tag_sram_gen
        xpm_memory_spram #(
            .ADDR_WIDTH_A(6),              // DECIMAL
            .AUTO_SLEEP_TIME(0),           // DECIMAL
            .BYTE_WRITE_WIDTH_A(Cfg.tagWidth),       // DECIMAL
            .CASCADE_HEIGHT(0),            // DECIMAL
            .ECC_MODE("no_ecc"),           // String
            .MEMORY_INIT_FILE("none"),     // String
            .MEMORY_INIT_PARAM("0"),       // String
            .MEMORY_OPTIMIZATION("true"),  // String
            .MEMORY_PRIMITIVE("auto"),     // String
            .MEMORY_SIZE(Cfg.tagWidth * 64),            // DECIMAL
            .MESSAGE_CONTROL(0),           // DECIMAL
            .READ_DATA_WIDTH_A(Cfg.tagWidth),        // DECIMAL
            .READ_LATENCY_A(2),            // DECIMAL
            .READ_RESET_VALUE_A("0"),      // String
            .RST_MODE_A("SYNC"),           // String
            .SIM_ASSERT_CHK(0),            // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
            .USE_MEM_INIT(1),              // DECIMAL
            .USE_MEM_INIT_MMI(0),          // DECIMAL
            .WAKEUP_TIME("disable_sleep"), // String
            .WRITE_DATA_WIDTH_A(Cfg.tagWidth),       // DECIMAL
            .WRITE_MODE_A("read_first"),   // String
            .WRITE_PROTECT(1)              // DECIMAL
        )
        xpm_memory_spram_inst (
            .dbiterra(),             // 1-bit output: Status signal to indicate double bit error occurrence on the data output of port A.
            .douta(tag_rentry[tag_w]),                   // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
            .sbiterra(),             // 1-bit output: Status signal to indicate single bit error occurrence on the data output of port A.
            .addra(tag_addr),                   // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
            .clka(clk),                     // 1-bit input: Clock signal for port A.
            .dina(tag_wentry),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
            .ena(tag_cs[tag_w]),                       // 1-bit input: Memory enable signal for port A. Must be high on clock cycles when read or write operations
                                    // are initiated. Pipelined internally.

            .injectdbiterra('d0), // 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability
                                    // is not available in "decode_only" mode).

            .injectsbiterra('d0), // 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability
                                    // is not available in "decode_only" mode).

            .regcea(regcea[tag_w]),                 // 1-bit input: Clock Enable for the last register stage on the output data path.
            .rsta(rst_n),                     // 1-bit input: Reset signal for the final port A output register stage. Synchronously resets output port
                                    // douta to the value specified by parameter READ_RESET_VALUE_A.

            .sleep('d0),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
            .wea(tag_we[tag_w])                        // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit
                                    // wide when word-wide writes are used. In byte-wide write configurations, each bit controls the writing one
                                    // byte of dina to address addra. For example, to synchronously write only bits [15-8] of dina when
                                    // WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
        );

    end
endgenerate

`else

generate 
    for (genvar tag_w = 0; tag_w < int'(Cfg.wayNum); tag_w++)
    begin : tag_sram_gen
        mpc_sram #(
            .DATA_SIZE (Cfg.tagWidth),
            .ADDR_SIZE (Cfg.setWidth)
        ) tag_sram (
            .clk       (clk              ),
            .rst_n     (rst_n            ),
            .cs        (tag_cs[tag_w]    ),
            .we        (tag_we[tag_w]    ),
            .addr      (tag_addr         ),
            .wdata     (tag_wentry       ),
            .rdata     (tag_rentry[tag_w])
        );
    end
endgenerate

`endif

endmodule