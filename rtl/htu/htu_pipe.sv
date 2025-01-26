module htu_pipe
    import mpc_types::*;

    localparam mpc_user_cfg_t UserCfg = '{
        clWidth:256,
        clWordWidth:128,
        sets:8,
        banks:4,
        ways:8,
        kobSize:16,
        wbufSize:128
    },

    localparam mpc_cfg_t Cfg = mpcBuildConfig(UserCfg),
   
    localparam type setWidth_t      = logic [Cfg.setWidth-1:0],
    localparam type tagWidth_t      = logic [Cfg.tagWidth-1:0],
    localparam type wayIndexWidth_t = logic [Cfg.wayIndexWidth-1:0],
    localparam type wbufWidth_t     = logic [Cfg.wbufWidth-1:0],
    localparam type wayNum_t        = logic [Cfg.wayNum-1:0],
    localparam type nlineWidth_t    = logic [Cfg.nlineWidth-1:0],
    localparam type offsetWidth_t   = logic [Cfg.offsetWidth-1:0],
    localparam type metaWidth_t     = logic [Cfg.metaWidth-1:0],

(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    // 1. from upstream req
    input  logic                        u_bank_req_valid           ,
    output logic                        u_bank_req_ready           ,
    input  bank_req_t                   u_bank_req                 ,
    
    // 2. to downstream isu refill info
    output logic                        d_isu_refill_valid         ,
    output setWidth_t                   d_isu_refill_set           ,
    output wayIndexWidth_t              d_isu_refill_way           ,

    // 3. to downstream isu req 
    output logic                        d_isu_valid                ,
    input  logic                        d_isu_ready                ,
    output logic           [  2: 0]     d_isu_channel_1hot_id      ,
    output logic           [  2: 0]     d_isu_op                   ,
    output nlineWidth_t                 d_isu_id                   ,
    output offsetWidth_t                d_isu_offset               ,
    output wbufWidth_t                  d_isu_wbuf_id              ,
    
    // 4. to down stream memory interface
    output logic                        d_memctl_valid             ,
    input  logic                        d_memctl_ready             ,
    output logic           [  2: 0]     d_memctl_op                ,
    output nlineWidth_t                 d_memctl_id                ,
    output logic           [ 31: 0]     d_memctl_addr              ,

    // 5. tag_array interface
    output logic                        d_tag_read_valid           ,
    input  logic                        d_tag_read_ready           ,
    output setWidth_t                   d_tag_read_set             ,
    input  wayNum_t                     d_tag_read_rsp   [Cfg.tagWidth-1:0], 
    
    output logic                        d_tag_write_valid          ,
    input  logic                        d_tag_write_ready          ,
    output setWidth_t                   d_tag_write_set            ,
    output wayNum_t                     d_tag_write_way_en         ,
    output tagWidth_t                   d_tag_write_data           ,

    // 6. meta_array interface
    output logic                        d_meta_read_valid          ,
    input  logic                        d_meta_read_ready          ,
    output setWidth_t                   d_meta_read_set            ,
    input  wayNum_t                     d_meta_read_rsp  [Cfg.metaWidth-1:0],

    output logic                        d_meta_write_valid         ,
    input  logic                        d_meta_write_ready         ,
    output setWidth_t                   d_meta_write_set           ,
    output wayNum_t                     d_meta_write_way_en        ,
    output metaWidth_t                  d_meta_write_data          ,

    // 7. reference counter
    output setWidth_t                   d_ref_cnt_set              ,
    input  wayNum_t                     d_ref_cnt_rsp    [  2: 0]  ,

    output logic                        d_ref_cnt_access_valid     ,
    output setWidth_t                   d_ref_cnt_access_set       ,

    // 8. replacer interface
    output setWidth_t                   d_replace_set              ,
    input  wayIndexWidth_t              d_replace_way              ,

    output logic                        d_replace_access_valid     ,
    output setWidth_t                   d_replace_access_set       ,
    output wayIndexWidth_t              d_replace_access_way       

);

localparam setMSB       = 31 - Cfg.tagWidth - Cfg.bankWidth;
localparam setLSB       = Cfg.offsetWidth + Cfg.byteWidth;
localparam tagMSB       = 31;
localparam tagLSB       = Cfg.bankWidth + Cfg.setWidth + Cfg.offsetWidth + Cfg.byteWidth;
localparam offsetMSB    = 31 - Cfg.tagWidth - Cfg.bankWidth - Cfg.setWidth;
localparam offsetLSB    = Cfg.byteWidth;
localparam bankReqWidth = $bits(u_bank_req);

logic                                   s0_valid;
logic                                   s0_ready;
setWidth_t                              s0_set;
tagWidth_t                              s0_tag;
bank_req_t                              s0_bank_req;
logic                                   s0_hsked;
logic                                   s0_hsked_r;

logic                                   s1_valid;
logic                                   s1_valid_nxt;
logic                                   s1_ready;
setWidth_t                              s1_set;
tagWidth_t                              s1_tag;
bank_req_t                              s1_bank_req;
wayNum_t                                s1_tag_rsp_r [Cfg.tagWidth-1:0];
wayNum_t                                s1_tag_rsp [Cfg.tagWidth-1:0];
wayNum_t                                s1_meta_rsp_r [Cfg.metaWidth-1:0];
wayNum_t                                s1_meta_rsp [Cfg.metaWidth-1:0];
wayNum_t                                s1_tag_match;
wayNum_t                                s1_hit_way_en;
logic                                   s1_hit;
logic                                   s1_hsked;
logic                                   s1_hsked_r;

logic                                   s2_valid;
logic                                   s2_valid_nxt;
logic                                   s2_ready;
bank_req_t                              s2_bank_req;
wayNum_t                                s2_ref_cnt_r [2:0];
wayNum_t                                s2_ref_cnt [2:0];
logic            [  2: 0]               s2_ref_cnt_sel;
logic                                   s2_ref_cnt_max;
logic                                   s2_ref_cnt_not_zero;
logic                                   s2_ref_cnt_not_ready;
wayNum_t                                s2_hit_way_en;
wayIndexWidth_t                         s2_hit_way;
wayNum_t                                s2_replace_way_en;
wayIndexWidth_t                         s2_replace_way;
wayIndexWidth_t                         s2_way;
logic                                   s2_hit;
setWidth_t                              s2_set;
tagWidth_t                              s2_tag;
metaWidth_t                             s2_meta;
metaWidth_t                             s2_new_meta;                                   
logic                                   s2_hsked;

logic                                   s0_s1_set_conflict, s0_s2_set_conflict;
logic                                   set_conflict;

/* stage 0: read tag/meta array */

assign s0_valid          = u_bank_req_valid & u_bank_req_ready;
assign s0_ready          = s1_ready & d_tag_read_ready & d_meta_read_ready & !set_conflict;
assign u_bank_req_ready  = s0_ready;

assign s0_bank_req       = u_bank_req;
assign s0_set            = u_bank_req.addr[setMSB:setLSB];
assign s0_tag            = u_bank_req.addr[tagMSB:tagLSB];

/* stage 0 <==> stage 1 pipeline connect */

assign s0_hsked          = s0_valid & s1_ready;
assign s1_hsked          = s1_valid & s2_ready;
assign s1_valid_nxt      = s0_hsked | ~(s1_hsked);
ns_gnrl_dfflr # (1) s1_valid_dfflr (s0_hsked | s1_hsked, s1_valid_nxt, s1_valid, clk, rst_n);
ns_gnrl_dfflr # (bankReqWidth) s1_bank_req_dfflr (s0_hsked, s0_bank_req, s1_bank_req, clk, rst_n);
ns_gnrl_dfflr # (Cfg.setWidth) s1_set_dfflr (s0_hsked, s0_set, s1_set, clk, rst_n);
ns_gnrl_dfflr # (Cfg.tagWidth) s1_tag_dfflr (s0_hsked, s0_tag, s1_tag, clk, rst_n);
ns_gnrl_dfflr # (1) s0_hsked_r_dfflr (1'b1, s0_hsked, s0_hsked_r, clk, rst_n);

/* stage 1: 
    1. get response from tag/meta array
    2. compare with tag and know whether hit 
    3. read replace way
    4. read reference counter
*/
generate
    for (genvar i = 0; i < Cfg.wayNum; i++) 
    begin
        ns_gnrl_dfflr # (Cfg.tagWidth) s1_tag_rsp_dfflr (1'b1, s1_tag_rsp[i], s1_tag_rsp_r[i], clk, rst_n);
        ns_gnrl_dfflr # (Cfg.tagWidth) s1_meta_rsp_dfflr (1'b1, s1_meta_rsp[i], s1_meta_rsp_r[i], clk, rst_n);
    end
endgenerate
assign s1_tag_rsp  = s0_hsked_r ? d_tag_read_rsp  : s1_tag_rsp_r;
assign s1_meta_rsp = s0_hsked_r ? d_meta_read_rsp : s1_meta_rsp_r;

generate
    for (genvar i = 0; i < Cfg.wayNum; i++) 
    begin
        assign s1_tag_match[i] = s1_tag_rsp == s1_tag;
        assign s1_hit_way_en[i]   = s1_tag_match[i] & |s1_meta_rsp; // tag match & meta not invalid
    end
endgenerate
assign s1_hit = |s1_hit_way_en;

assign s1_ready        = !s1_valid || s2_ready;

/* stage 1 <==> stage 2 pipeline connect */

assign s2_hsked          = s2_valid & (!s2_ref_cnt_not_ready & d_isu_ready & d_tag_write_ready & d_meta_write_ready);
assign s2_valid_nxt      = s1_hsked | ~(s2_hsked);
ns_gnrl_dfflr # (1) s2_valid_dfflr (s1_hsked | s2_hsked, s2_valid_nxt, s2_valid, clk, rst_n);
ns_gnrl_dfflr # (bankReqWidth) s2_bank_req_dfflr (s1_hsked, s1_bank_req, s2_bank_req, clk, rst_n);
ns_gnrl_dfflr # (Cfg.wayNum) s2_hit_way_en_dfflr (s1_hsked, s1_hit_way_en, s2_hit_way_en, clk, rst_n);
ns_gnrl_dfflr # (1) s2_hit_dfflr (s1_hsked, s1_hit, s2_hit, clk, rst_n);
ns_gnrl_dfflr # (Cfg.setWidth) s2_set_dfflr (s1_hsked, s1_set, s2_set, clk, rst_n);
ns_gnrl_dfflr # (Cfg.tagWidth) s2_tag_dfflr (s1_hsked, s1_tag_rsp, s2_tag, clk, rst_n);
ns_gnrl_dfflr # (Cfg.metaWidth) s2_meta_dfflr (s1_hsked, s1_meta_rsp, s2_meta, clk, rst_n);
ns_gnrl_dfflr # (1) s1_hsked_r_dfflr (1'b1, s1_hsked, s1_hsked_r, clk, rst_n);


/* stage 2: 
    1. get response from replacer
    2. get response from reference counter
        1> if reference counter reach maximum, need to back-press
        2> if reference counter is not zero, can't send refill req and need to back-press
    3. update tag array and meta array
    4. update reference counter
    5. update replacer plru state
    6. send linefill req to memctl
    7. send hit/miss info to isu
*/

generate
    for (genvar i = 0; i < Cfg.wayNum; i++) 
    begin
        ns_gnrl_dfflr # (3) s2_ref_cnt_r_dfflr (1'b1, s2_ref_cnt[i], s2_ref_cnt_r[i], clk, rst_n);
    end
endgenerate
ns_gnrl_dfflr # (3) s2_replace_way_en_r_dfflr (1'b1, s2_replace_way_en[i], s2_replace_way_en_r[i], clk, rst_n);
assign s2_ref_cnt  = s1_hsked_r ? d_ref_cnt_rsp : s2_ref_cnt_r;
assign s2_replace_way_en = s1_hsked_r ? d_replace_way : s2_replace_way_en_r;
ns_1hot2bin # (Cfg.wayNum) s2_hit_way_1hot2bin (s2_hit_way_en, s2_hit_way);
ns_1hot2bin # (Cfg.wayNum) s2_replace_way_1hot2bin (s2_replace_way_en, s2_replace_way);
assign s2_way = s2_hit ? s2_hit_way : s2_replace_way;
assign s2_ref_cnt_sel = s2_ref_cnt[s2_way];
assign s2_ref_cnt_max = &s2_ref_cnt_sel;
assign s2_ref_cnt_not_zero = |s2_ref_cnt_sel;
assign s2_new_meta =           is_store(s2_bank_req.op) ? MPC_META_UNIQUE :
                     !s2_hit &  is_load(s2_bank_req.op) ? MPC_META_SHARE  : s2_meta;

assign s2_ref_cnt_not_ready = s2_ref_cnt_max | (!s2_hit & s2_ref_cnt_not_zero);
assign s2_ready = !s2_valid || (!s2_ref_cnt_not_ready & d_isu_ready & d_tag_write_ready & d_meta_write_ready);

/* downstream connect */
assign d_isu_valid            = s2_hsked;
assign d_isu_channel_1hot_id  = s2_bank_req.channel_1hot_id;
assign d_isu_op               =  s2_hit &  is_load(s2_bank_req.op)                       ? CACHE_OP_LOAD  :
                                 s2_hit & is_store(s2_bank_req.op)                       ? CACHE_OP_STORE :
                                !s2_hit &  is_load(s2_bank_req.op) &  is_unique(s2_meta) ? CACHE_OP_RAE   :
                                !s2_hit &  is_load(s2_bank_req.op) & !is_unique(s2_meta) ? CACHE_OP_LOAD  :
                                !s2_hit & is_store(s2_bank_req.op) &  is_unique(s2_meta) ? CACHE_OP_WAE   :
                                !s2_hit & is_store(s2_bank_req.op) & !is_unique(s2_meta) ? CACHE_OP_STORE : CACHE_OP_LOAD;
assign d_isu_id               = {s2_way, s2_set};
assign d_isu_offset           = s2_bank_req.addr[offsetMSB:offsetLSB];
assign d_isu_wbuf_id          = s2_bank_req.wbuffer_id;

assign d_isu_refill_valid     = s2_hsked & !s2_hit;
assign d_isu_refill_set       = s2_set;
assign d_isu_refill_way       = s2_way;

assign d_memctl_valid         = s2_hsked & !s2_hit;
assign d_memctl_addr          = s2_bank_req.addr;
assign d_memctl_id            = {s2_way, s2_set};
assign d_memctl_op            = MEM_OP_LOAD;

assign d_tag_read_valid  = s0_valid;
assign d_tag_read_set    = s0_set;

assign d_tag_write_valid      = s2_hsked & !s2_hit;
assign d_tag_write_set        = s2_set;
assign d_tag_write_way_en     = s2_replace_way_en;
assign d_tag_write_data       = s2_tag;

assign d_meta_read_valid = s0_valid;
assign d_meta_read_set   = s0_set;

assign d_meta_write_valid     = s2_hsked & !(s2_hit & is_load(s2_bank_req.op));
assign d_meta_write_set       = s2_set;
assign d_meta_write_way_en    = s2_replace_way_en;
assign d_meta_write_data      = s2_new_meta;

assign d_ref_cnt_set          = s1_set;
assign d_ref_cnt_access_valid = s2_hsked;
assign d_ref_cnt_access_set   = s2_set;

assign d_replace_set          = s1_set;
assign d_replace_access_valid = s2_hsked;
assign d_replace_access_set   = s2_set;
assign d_replace_access_way   = s2_way;


endmodule