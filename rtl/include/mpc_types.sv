package mpc_types;
     
    typedef struct packed {
                       logic [  2:0] op;
                       logic [ 31:0] addr;
                       logic [127:0] wdata;
    } channel_req_t;

    typedef struct packed {
                       logic [127:0] rdata;
    } channel_rsp_t;

    typedef struct packed {
                       logic [  2:0] channel_1hot_id;
                       logic [  4:0] wbuffer_id;
                       logic [  2:0] op;
                       logic [ 31:0] addr;
                       logic [127:0] wdata;
    } bank_req_t;

    typedef struct packed {
                       logic [  1:0] channel_id;
                       logic [  2:0] rob_id;
                       logic [127:0] rdata;
    } rc_rsp_t;

    typedef struct packed {
                       logic [  1:0] channel_id;
                       logic [  7:0] wbuf_id;
                       logic [127:0] wdata;
    } wbuf_req_t;

    typedef enum logic [2:0] {
        MPC_OP_LOAD  = 3'd0,
        MPC_OP_STORE = 3'd1
    } mpc_command_e;

    typedef enum logic [2:0] {
        CACHE_OP_LOAD  = 3'd0,
        CACHE_OP_STORE = 3'd1,
        CACHE_OP_RAE   = 3'd2,
        CACHE_OP_WAE   = 3'd3 
    } internal_command_e;

    typedef enum logic [2:0] {
        MEM_OP_LOAD  = 3'd0,
        MEM_OP_STORE = 3'd1
    } external_command_e;

    typedef enum logic [1:0] {
        MPC_META_INVALID = 2'd0,
        MPC_META_SHARE   = 2'd1,
        MPC_META_UNIQUE  = 2'd2
    } mpc_meta_e;

    function automatic logic is_invalid(input [1:0] meta);
        case (meta)
            MPC_META_INVALID: return 1'b1;
            default:          return 1'b0;
        endcase
    endfunction

    function automatic logic is_share(input [1:0] meta);
        case (meta)
            MPC_META_SHARE  : return 1'b1;
            default:          return 1'b0;
        endcase
    endfunction

    function automatic logic is_unique(input [1:0] meta);
        case (meta)
            MPC_META_UNIQUE : return 1'b1;
            default:          return 1'b0;
        endcase
    endfunction

    function automatic logic is_load(input [2:0] op);
        case (op)
            MPC_OP_LOAD: return 1'b1;
            default:           return 1'b0;
        endcase
    endfunction

    function automatic logic is_store(input [2:0] op);
        case (op)
            MPC_OP_STORE: return 1'b1;
            default:           return 1'b0;
        endcase
    endfunction

    function automatic logic is_rae(input [2:0] op);
        case (op)
            CACHE_OP_WAE: return 1'b1;
            default:           return 1'b0;
        endcase
    endfunction

    typedef struct packed {
        //  Cacheline Width
        int unsigned clWidth;
        //  Word Width
        int unsigned clWordWidth;
        //  Number of sets
        int unsigned sets;
        //  Number of banks
        int unsigned banks;
        //  Number of ways
        int unsigned ways;
        //  Size of Keep Order Buffer
        int unsigned kobSize;
        //  Size of Write Buffer
        int unsigned wbufSize;
    } mpc_user_cfg_t;

    typedef struct packed {
        //  User configuration parameters
        mpc_user_cfg_t u;

        //  Internal parameters
        int unsigned byteWidth;
        int unsigned offsetWidth;
        int unsigned setWidth;
        int unsigned bankWidth;
        int unsigned tagWidth;
        int unsigned metaWidth;
        int unsigned nlineWidth;
        int unsigned wayNum;
        int unsigned wayIndexWidth;
        int unsigned wbufWidth;
    } mpc_cfg_t;

    function automatic mpc_cfg_t mpcBuildConfig(input mpc_user_cfg_t p);
        mpc_cfg_t ret;

        ret.u = p;

        ret.byteWidth = $clog2(p.clWordWidth);
        ret.offsetWidth = $clog2(p.clWidth / p.clWordWidth);
        ret.setWidth = $clog2(p.sets);
        ret.bankWidth = $clog2(p.banks);
        ret.tagWidth = 32 - ret.bankWidth - ret.setWidth - ret.offsetWidth - ret.byteWidth;
        ret.metaWidth = 2;
        ret.wayNum = p.ways;
        ret.wayIndexWidth = (p.ways > 1) ? $clog2(p.ways) : 1;
        ret.nlineWidth = ret.setWidth + ret.wayIndexWidth;
        ret.wbufWidth = $clog2(p.wbufSize);       

        return ret;
    endfunction

endpackage