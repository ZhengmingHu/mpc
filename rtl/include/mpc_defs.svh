`define MPC_DECL_REQ_T(__op_t, __data_t, __addr_t) \
    struct packed { \
        __op_t                            op; \
        __data_t                          wdata; \
        __addr_t                          addr; \
    }

`define MPC_DECL_BANK_REQ_T(__op_t, __data_t, __addr_t) \
    struct packed { \
        logic    [  2: 0]                 channel_1hot_id; \
        __op_t                            op; \
        __data_t                          wdata; \
        __addr_t                          addr; \
    }
