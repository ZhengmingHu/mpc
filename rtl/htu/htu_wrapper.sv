module htu_wrapper
    import mpc_types::*;
# (
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
    parameter type rfbufWidth_t    = logic,
    parameter type bank_req_t      = logic
)
(
    input  logic                        clk                        ,
    input  logic                        rst_n                      ,

    // 1. from upstream req
    input  logic                        u_bank_req_valid           ,
    output logic                        u_bank_req_ready           ,
    input  bank_req_t                   u_bank_req                 ,
    input  wbufWidth_t                  u_bank_req_wbuf_id         ,
    
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
    output logic                        d_memctl_awvalid           ,
    input  logic                        d_memctl_awready           ,
    output nlineWidth_t                 d_memctl_awid              ,
    output logic           [ 31: 0]     d_memctl_awaddr            ,
    
    output logic                        d_memctl_arvalid           ,
    input  logic                        d_memctl_arready           ,
    output nlineWidth_t                 d_memctl_arid              ,
    output logic           [ 31: 0]     d_memctl_araddr            ,

    input  logic                        d_isu_crdt_valid           ,
    input  nlineWidth_t                 d_isu_crdt_way_set           
);

logic                        tag_read_valid                        ;
logic                        tag_read_ready                        ;
setWidth_t                   tag_read_set                          ;
tagWidth_t                   tag_read_rsp   [Cfg.wayNum-1:0]       ;
logic                        tag_write_valid                       ;
logic                        tag_write_ready                       ;
setWidth_t                   tag_write_set                         ;
wayNum_t                     tag_write_way_en                      ;
tagWidth_t                   tag_write_data                        ;

logic                        meta_read_valid                       ;
logic                        meta_read_ready                       ;
setWidth_t                   meta_read_set                         ;
metaWidth_t                  meta_read_rsp  [Cfg.wayNum-1:0]       ;
logic                        meta_write_valid                      ;
logic                        meta_write_ready                      ;
setWidth_t                   meta_write_set                        ;
wayNum_t                     meta_write_way_en                     ;
metaWidth_t                  meta_write_data                       ;

setWidth_t                   ref_cnt_set                           ;
logic      [  2: 0]          ref_cnt_rsp    [Cfg.wayNum-1:0]       ;
logic                        ref_cnt_access_valid                  ;
setWidth_t                   ref_cnt_access_set                    ;
wayIndexWidth_t              ref_cnt_access_way                    ;

setWidth_t                   replace_set                           ;
metaWidth_t                  replace_meta   [Cfg.wayNum-1:0]       ;
wayIndexWidth_t              replace_way                           ;
logic                        replace_access_valid                  ;
setWidth_t                   replace_access_set                    ;
wayIndexWidth_t              replace_access_way                    ;



htu_pipe # (
    .Cfg                               (Cfg                       ),
    .setWidth_t                        (setWidth_t                ),
    .tagWidth_t                        (tagWidth_t                ),
    .wayIndexWidth_t                   (wayIndexWidth_t           ),
    .wbufWidth_t                       (wbufWidth_t               ),
    .wayNum_t                          (wayNum_t                  ),
    .nlineWidth_t                      (nlineWidth_t              ),
    .offsetWidth_t                     (offsetWidth_t             ),
    .metaWidth_t                       (metaWidth_t               ),
    .bank_req_t                        (bank_req_t                )
) u_htu_pipe (
    .clk                  ,
    .rst_n                ,
    
    .u_bank_req_valid     ,
    .u_bank_req_ready     ,
    .u_bank_req           ,
    .u_bank_req_wbuf_id   ,

    .d_isu_refill_valid   ,
    .d_isu_refill_set     ,
    .d_isu_refill_way     ,
    .d_isu_valid          ,
    .d_isu_ready          ,
    .d_isu_channel_1hot_id,
    .d_isu_op             ,
    .d_isu_id             ,
    .d_isu_offset         ,
    .d_isu_wbuf_id        ,

    .d_memctl_awvalid     ,
    .d_memctl_awready     ,
    .d_memctl_awid        ,
    .d_memctl_awaddr      ,

    .d_memctl_arvalid     ,
    .d_memctl_arready     ,
    .d_memctl_arid        ,
    .d_memctl_araddr      ,

    .tag_read_valid       ,       
    .tag_read_ready       ,
    .tag_read_set         ,
    .tag_read_rsp         ,
    .tag_write_valid      ,
    .tag_write_ready      ,
    .tag_write_set        ,
    .tag_write_way_en     ,
    .tag_write_data       ,

    .meta_read_valid      , 
    .meta_read_ready      , 
    .meta_read_set        , 
    .meta_read_rsp        ,
    .meta_write_valid     , 
    .meta_write_ready     , 
    .meta_write_set       , 
    .meta_write_way_en    , 
    .meta_write_data      ,

    .ref_cnt_set          ,
    .ref_cnt_rsp          ,   
    .ref_cnt_access_valid ,
    .ref_cnt_access_set   ,
    .ref_cnt_access_way   ,

    .replace_set          ,
    .replace_meta         ,   
    .replace_way          ,
    .replace_access_valid ,
    .replace_access_set   ,
    .replace_access_way   

);

tag_array # (
    .Cfg                               (Cfg                       ),
    .setWidth_t                        (setWidth_t                ),
    .tagWidth_t                        (tagWidth_t                ),
    .wayIndexWidth_t                   (wayIndexWidth_t           ),
    .wbufWidth_t                       (wbufWidth_t               ),
    .wayNum_t                          (wayNum_t                  ),
    .nlineWidth_t                      (nlineWidth_t              ),
    .offsetWidth_t                     (offsetWidth_t             ),
    .metaWidth_t                       (metaWidth_t               )
) u_tag_array (
    .*
);

meta_array # (
    .Cfg                               (Cfg                       ),
    .setWidth_t                        (setWidth_t                ),
    .tagWidth_t                        (tagWidth_t                ),
    .wayIndexWidth_t                   (wayIndexWidth_t           ),
    .wbufWidth_t                       (wbufWidth_t               ),
    .wayNum_t                          (wayNum_t                  ),
    .nlineWidth_t                      (nlineWidth_t              ),
    .offsetWidth_t                     (offsetWidth_t             ),
    .metaWidth_t                       (metaWidth_t               )
) u_meta_array (
    .*
);

replacer # (
    .Cfg                               (Cfg                       ),
    .setWidth_t                        (setWidth_t                ),
    .tagWidth_t                        (tagWidth_t                ),
    .wayIndexWidth_t                   (wayIndexWidth_t           ),
    .wbufWidth_t                       (wbufWidth_t               ),
    .wayNum_t                          (wayNum_t                  ),
    .nlineWidth_t                      (nlineWidth_t              ),
    .offsetWidth_t                     (offsetWidth_t             ),
    .metaWidth_t                       (metaWidth_t               )
) u_replacer (
    .*
);

reference_counter # (
    .Cfg                               (Cfg                       ),
    .setWidth_t                        (setWidth_t                ),
    .tagWidth_t                        (tagWidth_t                ),
    .wayIndexWidth_t                   (wayIndexWidth_t           ),
    .wbufWidth_t                       (wbufWidth_t               ),
    .wayNum_t                          (wayNum_t                  ),
    .nlineWidth_t                      (nlineWidth_t              ),
    .offsetWidth_t                     (offsetWidth_t             ),
    .metaWidth_t                       (metaWidth_t               )
) u_reference_counter (
    .*
);

endmodule