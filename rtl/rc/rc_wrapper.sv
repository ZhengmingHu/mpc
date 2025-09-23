module rc_wrapper 
    import mpc_types::*;
#(
    parameter mpc_cfg_t Cfg = '0,
    parameter type clWidth_t       = logic,
    parameter type dataWidth_t     = logic,   
    parameter type setWidth_t      = logic,
    parameter type tagWidth_t      = logic,
    parameter type wayIndexWidth_t = logic,
    parameter type wbufWidth_t     = logic,
    parameter type wayNum_t        = logic,
    parameter type nlineWidth_t    = logic,
    parameter type offsetWidth_t   = logic,
    parameter type byteWidth_t     = logic,
    parameter type metaWidth_t     = logic,
    parameter type robWidth_t      = logic,
    parameter type lsqWidth_t      = logic,
    parameter type kobWidth_t      = logic
)
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    // 1. from upstream isu req
    input  logic                        u_isu_valid                ,
    output logic                        u_isu_ready                ,
    input  logic            [  2: 0]    u_isu_channel_1hot_id      ,
    input  robWidth_t                   u_isu_rob_id               ,
    input  logic            [  2: 0]    u_isu_op                   ,
    input  logic            [  2: 0]    u_isu_size                 ,
    input  setWidth_t                   u_isu_set                  ,
    input  wayIndexWidth_t              u_isu_way                  ,
    input  offsetWidth_t                u_isu_offset               ,
    input  byteWidth_t                  u_isu_byte                 ,
    input  wbufWidth_t                  u_isu_wbuf_id              ,
    input  logic            [255: 0]    u_isu_refill_data          ,

    // 2. interact with wbuf
    output logic                        wbuf_req_valid             ,   
    output wbufWidth_t                  wbuf_req_id                ,                        
    input  dataWidth_t                  wbuf_rsp_data              ,

    // 3. to upstream xbar
    output logic                        u_bank_rsp_valid           ,
    input  logic                        u_bank_rsp_ready           ,
    output robWidth_t                   u_bank_rsp_rob_id          ,
    output logic            [  1: 0]    u_bank_rsp_channel_id      ,
    output dataWidth_t                  u_bank_rsp_data            ,

    // 4. memory controller intf
    output logic                        memctl_wvalid              ,
    input  logic                        memctl_wready              ,
    output nlineWidth_t                 memctl_wid                 ,
    output logic            [255: 0]    memctl_wdata
);

//   | stage 0 | stage 1 | 
// 1. linefill  
//    rdata
//    byte_sel
// 2. linefill   merge
//    read wbuf  write
//    read
// 3. read wbuf  merge
//    read       write   
// 4. read       rdata
//               byte_sel
// 5. read       rdata + WB 

localparam BYTE_MASK = 255'hff;
localparam HALF_MASK = 255'hffff;
localparam WORD_MASK = 255'hffff_ffff;
localparam DOUBLE_MASK = 255'hffff_ffff_ffff_ffff;
localparam QUAD_MASK = 255'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;

logic                                   s0_valid;
logic                                   s0_ready;
logic             [  1: 0]              s0_channel_id;
robWidth_t                              s0_rob_id;
logic             [  2: 0]              s0_op;
logic             [  2: 0]              s0_size;
logic                                   s0_read_with_linefill;
logic                                   s0_read_wbuf;
logic                                   s0_read;
logic                                   s0_write_ptl;
logic                                   s0_wb;
setWidth_t                              s0_set;
wayIndexWidth_t                         s0_way;                                             
offsetWidth_t                           s0_offset;
byteWidth_t                             s0_byte;
logic             [  1: 0]              s0_rmask;
wbufWidth_t                             s0_wbuf_id;
logic             [255: 0]              s0_refill_data;
logic             [127: 0]              s0_rsp_data;
logic                                   s0_s1_hsked;
logic                                   s0_drop;
logic                                   s0_can_go;
logic             [  1: 0]              s0_wmask;

logic                                   s1_valid;
logic                                   s1_valid_nxt;
logic                                   s1_ready;
logic             [  1: 0]              s1_channel_id;
robWidth_t                              s1_rob_id;
logic             [  2: 0]              s1_op;
logic             [  2: 0]              s1_size;
logic                                   s1_read_with_linefill;
logic                                   s1_write_with_linefill;
logic                                   s1_read;
logic                                   s1_write;
logic                                   s1_wb;
logic                                   s1_drop;
setWidth_t                              s1_set;
wayIndexWidth_t                         s1_way;
offsetWidth_t                           s1_offset;
byteWidth_t                             s1_byte;
logic             [255: 0]              s1_refill_data;
dataWidth_t                             s1_refill_data_hi;
dataWidth_t                             s1_refill_data_lo;
logic             [255: 0]              s1_data_array_rsp_data;
logic             [127: 0]              s1_wbuf_rsp_data_aligned;
logic             [255: 0]              s1_wbuf_rsp_data_ext;
logic             [255: 0]              s1_wstrb;
dataWidth_t                             s1_rdata;
logic             [255: 0]              s1_wdata;
logic             [  1: 0]              s1_wmask;

logic s0_s1_conflict;
logic s0_s1_write_conflcit;
assign s0_s1_conflict = s0_way == s1_way && s1_valid && s1_wmask[s0_offset];
assign s0_s1_write_conflict = s0_way == s1_way && s1_valid && |s1_wmask;

assign s0_valid              = u_isu_valid;
assign s0_ready              =  s0_read_with_linefill && u_bank_rsp_ready || 
                                // Maybe we need byte mask so reading data_array is needed when store
                                (s0_read || s0_read_wbuf || s0_write_ptl) && s1_ready && !s0_s1_conflict || 
                                s0_wb && s1_ready && !s0_s1_write_conflict ||
                                !s0_valid;
assign s0_can_go             = s0_valid & s0_ready;
ns_1hot2bin # (3) s0_channel_id_1hot2bin (u_isu_channel_1hot_id, s0_channel_id);
assign s0_rob_id             = u_isu_rob_id;
assign s0_set                = u_isu_set;
assign s0_way                = u_isu_way;
assign s0_offset             = u_isu_offset;
assign s0_byte               = u_isu_byte;
assign s0_wbuf_id            = u_isu_wbuf_id;
assign s0_refill_data        = u_isu_refill_data;
assign s0_op                 = u_isu_op;
assign s0_size               = u_isu_size;
assign s0_read_with_linefill = s0_valid && (s0_op == CACHE_OP_LOAD_REFILL);
assign s0_rsp_data           =  s0_size == BYTE ? (s0_refill_data >> {s0_offset, s0_byte, 3'b0}) & BYTE_MASK :
                                s0_size == HALF ? (s0_refill_data >> {s0_offset, s0_byte, 3'b0}) & HALF_MASK :
                                s0_size == WORD ? (s0_refill_data >> {s0_offset, s0_byte, 3'b0}) & WORD_MASK :
                                s0_size == DOUBLE ? (s0_refill_data >> {s0_offset, s0_byte, 3'b0}) & DOUBLE_MASK :
                                s0_size == QUAD ? (s0_refill_data >> {s0_offset, s0_byte, 3'b0}) & QUAD_MASK : 'd0;

assign s0_read_wbuf          = s0_valid && (s0_op == CACHE_OP_STORE_REFILL || s0_op == CACHE_OP_STORE);
assign s0_read               = s0_valid && (s0_op == CACHE_OP_LOAD);
assign s0_write_ptl          = s0_valid && (s0_op == CACHE_OP_STORE) && (s0_size != QUAD);
assign s0_wb                 = s0_valid && (s0_op == CACHE_OP_WB);
assign s0_rmask              = s0_wb ? 2'b11 : s0_read || s0_write_ptl ? 1 << s0_offset : 2'b00;
assign s0_s1_hsked           = s0_can_go && !s0_drop && s1_ready;
assign s0_drop               = s0_read_with_linefill && u_bank_rsp_ready && !s0_s1_write_conflict && 
                               !(s1_read || s1_read_with_linefill);
assign s0_wmask              = s0_drop ? 2'b11 : 2'b00;

ns_gnrl_dfflr # (                1)       s1_valid_dfflr (s1_ready, s1_valid_nxt, s1_valid, clk, rst_n);
ns_gnrl_dfflr # (                2)  s1_channel_id_dfflr (s0_s1_hsked, s0_channel_id, s1_channel_id, clk, rst_n);
ns_gnrl_dfflr # (     Cfg.robWidth)      s1_rob_id_dfflr (s0_s1_hsked, s0_rob_id, s1_rob_id, clk, rst_n);
ns_gnrl_dfflr # (                3)          s1_op_dfflr (s0_s1_hsked, s0_op, s1_op, clk, rst_n);
ns_gnrl_dfflr # (                3)        s1_size_dfflr (s0_s1_hsked, s0_size, s1_size, clk, rst_n);
ns_gnrl_dfflr # (     Cfg.setWidth)         s1_set_dfflr (s0_s1_hsked, s0_set, s1_set, clk, rst_n);
ns_gnrl_dfflr # (Cfg.wayIndexWidth)         s1_way_dfflr (s0_s1_hsked, s0_way, s1_way, clk, rst_n);
ns_gnrl_dfflr # (  Cfg.offsetWidth)      s1_offset_dfflr (s0_s1_hsked, s0_offset, s1_offset, clk, rst_n);
ns_gnrl_dfflr # (    Cfg.byteWidth)        s1_byte_dfflr (s0_s1_hsked, s0_byte, s1_byte, clk, rst_n);
ns_gnrl_dfflr # (              256) s1_refill_data_dfflr (s0_s1_hsked, s0_refill_data, s1_refill_data, clk, rst_n);

data_array #(
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
) u_data_array (
    .clk                               (clk                                ),
    .rst_n                             (rst_n                              ),
    .r_en                              ((s0_read | s0_wb | s0_write_ptl) && s0_s1_hsked   ),
    .r_set                             (s0_set                             ),
    .r_way                             (s0_way                             ),
    .r_mask                            (s0_rmask                           ),
    .r_data                            (s1_data_array_rsp_data             ),
    .w_en                              (s0_drop | s1_write_with_linefill | s1_write | s1_read_with_linefill),
    .w_way                             (s0_drop ? s0_way : s1_way          ), 
    .w_set                             (s0_drop ? s0_set : s1_set          ),
    .w_mask                            (s0_drop ? s0_wmask : s1_wmask      ),
    .w_data                            (s0_drop ? s0_refill_data : s1_wdata)

);

assign s1_valid_nxt           = s0_can_go && !s0_drop || !s0_valid && s1_valid && !s1_drop;
assign s1_read                = s1_valid && (s1_op == CACHE_OP_LOAD);
assign s1_read_with_linefill  = s1_valid && (s1_op == CACHE_OP_LOAD_REFILL);
assign s1_write_with_linefill = s1_valid && (s1_op == CACHE_OP_STORE_REFILL);
assign s1_write               = s1_valid && (s1_op == CACHE_OP_STORE);
assign s1_wb                  = s1_valid && (s1_op == CACHE_OP_WB);
assign {s1_refill_data_hi, s1_refill_data_lo} = s1_refill_data;
assign s1_rdata               = s1_read_with_linefill ? (
                                    s1_size == BYTE ? (s1_refill_data >> {s1_offset, s1_byte, 3'b0}) & BYTE_MASK :
                                    s1_size == HALF ? (s1_refill_data >> {s1_offset, s1_byte, 3'b0}) & HALF_MASK :
                                    s1_size == WORD ? (s1_refill_data >> {s1_offset, s1_byte, 3'b0}) & WORD_MASK :
                                    s1_size == DOUBLE ? (s1_refill_data >> {s1_offset, s1_byte, 3'b0}) & DOUBLE_MASK :
                                    s1_size == QUAD ? (s1_refill_data >> {s1_offset, s1_byte, 3'b0}) & QUAD_MASK : 'd0
                                ) : 
                                s1_read ? (
                                    s1_size == BYTE ? (s1_data_array_rsp_data >> {s1_offset, s1_byte, 3'b0}) & BYTE_MASK :
                                    s1_size == HALF ? (s1_data_array_rsp_data >> {s1_offset, s1_byte, 3'b0}) & HALF_MASK :
                                    s1_size == WORD ? (s1_data_array_rsp_data >> {s1_offset, s1_byte, 3'b0}) & WORD_MASK :
                                    s1_size == DOUBLE ? (s1_data_array_rsp_data >> {s1_offset, s1_byte, 3'b0}) & DOUBLE_MASK :
                                    s1_size == QUAD ? (s1_data_array_rsp_data >> {s1_offset, s1_byte, 3'b0}) & QUAD_MASK : 'd0
                                ) : 'd0;
assign s1_wbuf_rsp_data_aligned = wbuf_rsp_data << {s1_byte, 3'b0};
assign s1_wbuf_rsp_data_ext   = s1_offset ? {s1_wbuf_rsp_data_aligned, {128{1'b0}}} : {{128{1'b0}}, s1_wbuf_rsp_data_aligned};
assign s1_wstrb               = s1_size == BYTE ? BYTE_MASK << {s1_offset, s1_byte, 3'b0} :
                                s1_size == HALF ? HALF_MASK << {s1_offset, s1_byte, 3'b0} :
                                s1_size == WORD ? WORD_MASK <<  {s1_offset, s1_byte, 3'b0} :
                                s1_size == DOUBLE ? DOUBLE_MASK << {s1_offset, s1_byte, 3'b0} :
                                s1_size == QUAD ? QUAD_MASK << {s1_offset, s1_byte, 3'b0} : 'd0;
assign s1_wdata               = {256{s1_write_with_linefill}} & (s1_wbuf_rsp_data_ext & s1_wstrb | s1_refill_data & ~s1_wstrb) |
                                {256{s1_write}} & (s1_wbuf_rsp_data_ext & s1_wstrb | s1_data_array_rsp_data & ~s1_wstrb) |
                                {256{s1_read_with_linefill}} & s1_refill_data;
assign s1_wmask               = s1_write_with_linefill || s1_read_with_linefill ? 2'b11 : s1_write ? 1 << s1_offset : 2'b00; 
assign s1_ready               = !s1_valid ||
                                 s1_read && u_bank_rsp_ready ||
                                 s1_read_with_linefill && u_bank_rsp_ready ||
                                 s1_wb && memctl_wready ||
                                 s1_write ||
                                 s1_write_with_linefill;
assign s1_drop                = s1_wb && memctl_wready ||
                                (s1_read || s1_read_with_linefill) && u_bank_rsp_ready ||
                                s1_write_with_linefill || s1_write;

assign u_isu_ready            = s0_ready;

assign wbuf_req_valid         = s0_read_wbuf && s0_s1_hsked;
assign wbuf_req_id            = s0_wbuf_id;


assign u_bank_rsp_valid       = s1_read || s1_read_with_linefill || 
                                s0_read_with_linefill && !s0_s1_write_conflict;
assign u_bank_rsp_channel_id  = s0_drop ? s0_channel_id : s1_channel_id;
assign u_bank_rsp_rob_id      = s0_drop ? s0_rob_id : s1_rob_id;
assign u_bank_rsp_data        = s0_drop ? s0_rsp_data : !s1_wb ? s1_rdata : 'd0;



assign memctl_wvalid          = s1_wb;
assign memctl_wid             = {s1_way, s1_set};
assign memctl_wdata           = s1_wb ? s1_data_array_rsp_data : 'd0;

endmodule