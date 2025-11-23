module data_array 
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
    input  setWidth_t                   r_set                      ,
    input  wayIndexWidth_t              r_way                      ,
    input  logic            [  1: 0]    r_mask                     ,
    output logic            [255: 0]    r_data                     ,


    input  logic                        w_en                       ,
    input  setWidth_t                   w_set                      ,
    input  wayIndexWidth_t              w_way                      ,
    input  logic            [  1: 0]    w_mask                     ,
    input  logic            [255: 0]    w_data                      

);


logic [255: 0]  r_way_data [Cfg.u.ways-1:0];
logic           r_en_q;
wayIndexWidth_t r_way_q;

ns_gnrl_dfflr # (1) r_en_dfflr (1'b1, r_en, r_en_q, clk, rst_n);
ns_gnrl_dfflr # (Cfg.wayIndexWidth) r_way_dfflr (r_en, r_way, r_way_q, clk, rst_n);

assign r_data = r_way_data[r_way_q];

// logic                w_en_way_0, w_en_way_1, w_en_way_2, w_en_way_3;
// setWidth_t           w_set_way_0, w_set_way_1, w_set_way_2, w_set_way_3;
// logic       [  1: 0] w_mask_way_0, w_mask_way_1, w_mask_way_2, w_mask_way_3;
// logic       [255: 0] w_data_way_0, w_data_way_1, w_data_way_2, w_data_way_3;

// assign w_en_way_0 = (w_en[0] & (w_way[0] == 'd0)) | (w_en[1] & (w_way[1] == 'd0));
// assign w_en_way_1 = (w_en[0] & (w_way[0] == 'd1)) | (w_en[1] & (w_way[1] == 'd1));
// assign w_en_way_2 = (w_en[0] & (w_way[0] == 'd2)) | (w_en[1] & (w_way[1] == 'd2));
// assign w_en_way_3 = (w_en[0] & (w_way[0] == 'd3)) | (w_en[1] & (w_way[1] == 'd3));

// assign w_set_way_0 = (w_en[0] & (w_way[0] == 'd0)) ? w_set[0] : w_set[1];
// assign w_set_way_1 = (w_en[0] & (w_way[0] == 'd1)) ? w_set[0] : w_set[1];
// assign w_set_way_2 = (w_en[0] & (w_way[0] == 'd2)) ? w_set[0] : w_set[1];
// assign w_set_way_3 = (w_en[0] & (w_way[0] == 'd3)) ? w_set[0] : w_set[1];

// assign w_mask_way_0 = (w_en[0] & (w_way[0] == 'd0)) ? w_mask[0] : w_mask[1];
// assign w_mask_way_1 = (w_en[0] & (w_way[0] == 'd1)) ? w_mask[0] : w_mask[1];
// assign w_mask_way_2 = (w_en[0] & (w_way[0] == 'd2)) ? w_mask[0] : w_mask[1];
// assign w_mask_way_3 = (w_en[0] & (w_way[0] == 'd3)) ? w_mask[0] : w_mask[1];

// assign w_data_way_0 = (w_en[0] & (w_way[0] == 'd0)) ? w_data[0] : w_data[1];
// assign w_data_way_1 = (w_en[0] & (w_way[0] == 'd1)) ? w_data[0] : w_data[1];
// assign w_data_way_2 = (w_en[0] & (w_way[0] == 'd2)) ? w_data[0] : w_data[1];
// assign w_data_way_3 = (w_en[0] & (w_way[0] == 'd3)) ? w_data[0] : w_data[1];

// generate
//     for (genvar i = 0; i < int'(Cfg.u.ways); i++) 
//     begin: data_array_sram_gen
//         data_array_sram # (
//             .Cfg                               (Cfg                                ),
//             .setWidth_t                        (setWidth_t                         ),
//             .tagWidth_t                        (tagWidth_t                         ),
//             .wayIndexWidth_t                   (wayIndexWidth_t                    ),
//             .wbufWidth_t                       (wbufWidth_t                        ),
//             .wayNum_t                          (wayNum_t                           ),
//             .nlineWidth_t                      (nlineWidth_t                       ),
//             .offsetWidth_t                     (offsetWidth_t                      ),
//             .metaWidth_t                       (metaWidth_t                        ),
//             .robWidth_t                        (robWidth_t                         ),
//             .lsqWidth_t                        (lsqWidth_t                         ),
//             .kobWidth_t                        (kobWidth_t                         )
//         ) u_data_array_sram (
//             .clk                               (clk                                ),
//             .rst_n                             (rst_n                              ),
//             .r_en                              (r_way == i && r_en                 ),
//             .r_addr                            (r_set                              ),
//             .r_mask                            (r_mask                             ),
//             .r_data                            (r_way_data[i]                      ),
//             .w_en                              (w_way == i && w_en                 ),
//             .w_addr                            (w_set                              ),
//             .w_mask                            (w_mask                             ),
//             .w_data                            (w_data                             )
//         );
//     end
// endgenerate

data_array_sram # (
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
        ) u_data_array_sram_0 (
            .clk                               (clk                                ),
            .rst_n                             (rst_n                              ),
            .r_en                              (r_way == 0 && r_en                 ),
            .r_addr                            (r_set                              ),
            .r_mask                            (r_mask                             ),
            .r_data                            (r_way_data[0]                      ),
            .w_en                              (w_way == 0 && w_en                 ),
            .w_addr                            (w_set                              ),
            .w_mask                            (w_mask                             ),
            .w_data                            (w_data                             )
        );

data_array_sram # (
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
        ) u_data_array_sram_1 (
            .clk                               (clk                                ),
            .rst_n                             (rst_n                              ),
            .r_en                              (r_way == 1 && r_en                 ),
            .r_addr                            (r_set                              ),
            .r_mask                            (r_mask                             ),
            .r_data                            (r_way_data[1]                      ),
            .w_en                              (w_way == 1 && w_en                 ),
            .w_addr                            (w_set                              ),
            .w_mask                            (w_mask                             ),
            .w_data                            (w_data                             )
        );


        data_array_sram # (
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
        ) u_data_array_sram_2 (
            .clk                               (clk                                ),
            .rst_n                             (rst_n                              ),
            .r_en                              (r_way == 2 && r_en                 ),
            .r_addr                            (r_set                              ),
            .r_mask                            (r_mask                             ),
            .r_data                            (r_way_data[2]                      ),
            .w_en                              (w_way == 2 && w_en                 ),
            .w_addr                            (w_set                              ),
            .w_mask                            (w_mask                             ),
            .w_data                            (w_data                             )
        );


        data_array_sram # (
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
        ) u_data_array_sram_3 (
            .clk                               (clk                                ),
            .rst_n                             (rst_n                              ),
            .r_en                              (r_way == 3 && r_en                 ),
            .r_addr                            (r_set                              ),
            .r_mask                            (r_mask                             ),
            .r_data                            (r_way_data[3]                      ),
            .w_en                              (w_way == 3 && w_en                 ),
            .w_addr                            (w_set                              ),
            .w_mask                            (w_mask                             ),
            .w_data                            (w_data                             )
        );


endmodule