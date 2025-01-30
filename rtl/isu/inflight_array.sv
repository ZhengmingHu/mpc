module inflight_array
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
    parameter type robWidth_t      = logic
)
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    input  logic                        htu_refill_valid           ,
    input  setWidth_t                   htu_refill_set             ,
    input  wayIndexWidth_t              htu_refill_way             ,

    input  setWidth_t                   htu_set                    ,
    input  wayIndexWidth_t              htu_way                    ,
    output logic                        inflight_flg               ,

    input  logic                        memctl_refill_valid        ,
    input  nlineWidth_t                 memctl_refill_id           



);

localparam setNum       = 2 ** Cfg.setWidth;
localparam wayMSB       = Cfg.nlineWidth - 1;
localparam wayLSB       = Cfg.setWidth;
localparam setMSB       = Cfg.setWidth-1;
localparam setLSB       = 0;

wayIndexWidth_t memctl_refill_way                                 ;
setWidth_t      memctl_refill_set                                 ;
logic           inflight_cl_en    [Cfg.wayNum-1:0][setNum-1:0]    ;
logic           inflight_cl_nxt   [Cfg.wayNum-1:0][setNum-1:0]    ;
logic           inflight_cl       [Cfg.wayNum-1:0][setNum-1:0]    ;

assign memctl_refill_way = memctl_refill_id[wayMSB:wayLSB];
assign memctl_refill_set = memctl_refill_id[setMSB:setLSB];

generate
    for (genvar i = 0; i < int'(Cfg.wayNum); i++)
    begin : inflight_cl_en_way_gen
        for (genvar j = 0; j < setNum; j++)
        begin : inflight_cl_en_set_gen
            assign inflight_cl_en[i][j] = (htu_refill_valid & htu_refill_way == i & htu_refill_set == j) |
                                          (memctl_refill_valid & memctl_refill_way == i & memctl_refill_set == j);
            assign inflight_cl_nxt[i][j] = htu_refill_valid & htu_refill_way == i & htu_refill_set == j;
        end
    end
endgenerate

generate
    for (genvar i = 0; i < int'(Cfg.wayNum); i++)
    begin : inflight_array_way_gen
        for (genvar j = 0; j < setNum; j++)
        begin : inflight_array_set_gen
            ns_gnrl_dfflr # (1) inflight_array_dfflr (inflight_cl_en[i][j], inflight_cl_nxt[i][j], inflight_cl[i][j], clk, rst_n);
        end
    end
endgenerate

assign inflight_flg = inflight_cl[htu_way][htu_set];

endmodule