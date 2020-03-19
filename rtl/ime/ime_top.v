//--------------------------------------------------------------------
//
//  Filename    : ime_top.v
//  Author      : Huang Leilei
//  Created     : 2018-03-25
//  Description : top ime module
//
//--------------------------------------------------------------------
//
//  Modified    : 2018-03-27 by HLL
//  Description : ctrl added
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module ime_top (
  // global
  clk                ,
  rstn               ,
  // cfg
  cmd_num_i          ,
  cmd_dat_i          ,
  // status
  downsample_o       ,
  // ctrl_if
  start_i            ,
  qp_i               ,
  ctu_x_all_i        ,
  ctu_y_all_i        ,
  ctu_x_res_i        ,
  ctu_y_res_i        ,
  ctu_x_cur_i        ,
  ctu_y_cur_i        ,
  done_o             ,
  // ori_if
  ori_ena_o          ,
  ori_adr_x_o        ,
  ori_adr_y_o        ,
  ori_dat_i          ,
  // ref_if
  ref_hor_ena_o      ,
  ref_hor_adr_x_o    ,
  ref_hor_adr_y_o    ,
  ref_hor_dat_i      ,
`ifndef IME_HAS_VER_MEM
  ref_ver_ena_o      ,
  ref_ver_adr_x_o    ,
  ref_ver_adr_y_o    ,
  ref_ver_dat_i      ,
`endif
  // parition
  partition_o        ,
  // mv
  mv_wr_ena_o        ,
  mv_wr_adr_o        ,
  mv_wr_dat_o
  );


//*** PARAMETER DECLARATION ****************************************************

  // global
  parameter     CMD_NUM_WIDTH                   = 3                         ;

  // local
  localparam    DLY_MEM                         = 2                         ;

  // derived
  localparam    CMD_DAT_WIDTH_ONE               =(`IME_MV_WIDTH_X  )             // center_x_o
                                                +(`IME_MV_WIDTH_Y  )             // center_y_o
                                                +(`IME_MV_WIDTH_X-1)             // length_x_o
                                                +(`IME_MV_WIDTH_Y-1)             // length_y_o
                                                +(2                )             // slope_o
                                                +(1                )             // downsample_o
                                                +(1                )             // partition_r
                                                +(1                )        ;    // use_feedback_o
  localparam    CMD_DAT_WIDTH                   = CMD_DAT_WIDTH_ONE
                                                *(1<<CMD_NUM_WIDTH )        ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  // global
  input                                            clk                         ;
  input                                            rstn                        ;
  // cfg
  input  [CMD_NUM_WIDTH                  -1 :0]    cmd_num_i                   ;
  input  [CMD_DAT_WIDTH                  -1 :0]    cmd_dat_i                   ;
  // status
  output                                           downsample_o                ;
  // ctr_if
  input                                            start_i                     ;
  input  [6                              -1 :0]    qp_i                        ;
  input  [`PIC_X_WIDTH                   -1 :0]    ctu_x_all_i                 ;
  input  [`PIC_Y_WIDTH                   -1 :0]    ctu_y_all_i                 ;
  input  [6                              -1 :0]    ctu_x_res_i                 ;
  input  [6                              -1 :0]    ctu_y_res_i                 ;
  input  [`PIC_X_WIDTH                   -1 :0]    ctu_x_cur_i                 ;
  input  [`PIC_Y_WIDTH                   -1 :0]    ctu_y_cur_i                 ;
  output                                           done_o                      ;
  // ori_if
  output                                           ori_ena_o                   ;
  output [6                              -1 :0]    ori_adr_x_o                 ;
  output [6                              -1 :0]    ori_adr_y_o                 ;
  input  [`IME_PIXEL_WIDTH*32            -1 :0]    ori_dat_i                   ;    // TODO : finialize IME_PIXEL_WIDTH
  // ref_if
  output                                           ref_hor_ena_o               ;
  output [`IME_MV_WIDTH_X                   :0]    ref_hor_adr_x_o             ;
  output [`IME_MV_WIDTH_Y                   :0]    ref_hor_adr_y_o             ;
  input  [`IME_PIXEL_WIDTH*32            -1 :0]    ref_hor_dat_i               ;
`ifndef IME_HAS_VER_MEM
  output                                           ref_ver_ena_o               ;
  output [`IME_MV_WIDTH_Y                   :0]    ref_ver_adr_x_o             ;
  output [`IME_MV_WIDTH_X                   :0]    ref_ver_adr_y_o             ;
  input  [`IME_PIXEL_WIDTH*32            -1 :0]    ref_ver_dat_i               ;
`endif
  // partition
  output [42                             -1 :0]    partition_o                 ;
  // mv
  output                                           mv_wr_ena_o                 ;
  output [6                              -1 :0]    mv_wr_adr_o                 ;
  output [`IME_MV_WIDTH                  -1 :0]    mv_wr_dat_o                 ;


//*** WIRE & REG DECLARATION ***************************************************

  wire   [2                              -1 :0]    ref_hor_dir_w               ;

  wire                                             ref_ver_ena_o               ;
  wire   [`IME_MV_WIDTH_Y                   :0]    ref_ver_adr_x_o             ;
  wire   [`IME_MV_WIDTH_X                   :0]    ref_ver_adr_y_o             ;
  wire   [`IME_PIXEL_WIDTH*32            -1 :0]    ref_ver_dat_i               ;

`ifdef IME_HAS_VER_MEM
  // ime_transfer
  wire                                             tra_done_o_w                ;
  wire                                             tra_busy_o_w                ;

  wire   [2                              -1 :0]    tra_ref_rd_dir_o_w          ;
  wire                                             tra_ref_rd_ena_o_w          ;
  wire   [`IME_MV_WIDTH_X                   :0]    tra_ref_rd_adr_x_o_w        ;
  wire   [`IME_MV_WIDTH_Y                   :0]    tra_ref_rd_adr_y_o_w        ;

  wire   [2                              -1 :0]    tra_ref_wr_dir_o_w          ;
  wire                                             tra_ref_wr_ena_o_w          ;
  wire   [`IME_MV_WIDTH_Y                   :0]    tra_ref_wr_adr_x_o_w        ;
  wire   [`IME_MV_WIDTH_X                   :0]    tra_ref_wr_adr_y_o_w        ;

  // ime_ver_mem
  reg    [2                  *(DLY_MEM+0)-1 :0]    mem_wr_dir_i_r              ;
  reg    [1                  *(DLY_MEM+0)-1 :0]    mem_wr_ena_i_r              ;
  reg    [(`IME_MV_WIDTH_Y+1)*(DLY_MEM+0)-1 :0]    mem_wr_adr_x_i_r            ;
  reg    [(`IME_MV_WIDTH_X+1)*(DLY_MEM+0)-1 :0]    mem_wr_adr_y_i_r            ;

  wire   [2                              -1 :0]    mem_wr_dir_i_w              ;
  wire   [1                              -1 :0]    mem_wr_ena_i_w              ;
  wire   [`IME_MV_WIDTH_Y                   :0]    mem_wr_adr_x_i_w            ;
  wire   [`IME_MV_WIDTH_X                   :0]    mem_wr_adr_y_i_w            ;
  wire   [`IME_PIXEL_WIDTH*1024          -1 :0]    mem_wr_dat_i_w              ;

  wire   [`IME_PIXEL_WIDTH*32            -1 :0]    mem_rd_dat_o_w              ;
`endif

  // ime_ctrl
  wire   [`IME_MV_WIDTH_X                -1 :0]    ctr_center_x_o_w            ;
  wire   [`IME_MV_WIDTH_Y                -1 :0]    ctr_center_y_o_w            ;
  wire   [`IME_MV_WIDTH_X                -2 :0]    ctr_length_x_o_w            ;
  wire   [`IME_MV_WIDTH_Y                -2 :0]    ctr_length_y_o_w            ;
  wire   [2                              -1 :0]    ctr_slope_o_w               ;
  wire                                             ctr_downsample_o_w          ;
  wire                                             ctr_use_feedback_o_w        ;

  wire                                             ctr_start_adr_o_w           ;
  wire                                             ctr_start_dec_o_w           ;
  wire                                             ctr_start_dmp_o_w           ;

  reg    [1               *(DLY_MEM+6)   -1 :0]    ctr_done_adr_i_r            ;
  wire   [1                              -1 :0]    ctr_done_adr_i_w            ;

  // ime_addressing
  wire                                             adr_done_o_w                ;
  wire   [2                              -1 :0]    adr_ref_dir_o_w             ;
  wire                                             adr_ref_hor_ena_o_w         ;
  wire   [`IME_MV_WIDTH_X                   :0]    adr_ref_hor_adr_x_o_w       ;
  wire   [`IME_MV_WIDTH_Y                   :0]    adr_ref_hor_adr_y_o_w       ;

  wire                                             adr_val_o_w                 ;
  wire   [2                              -1 :0]    adr_dat_qd_o_w              ;
  wire   [`IME_MV_WIDTH                  -1 :0]    adr_dat_mv_o_w              ;
  wire   [`IME_C_MV_WIDTH                -1 :0]    adr_dat_cst_mvd_o_w         ;

  // ime_ori_dat_array
  reg    [1               *DLY_MEM       -1 :0]    ori_val_i_r                 ;
  wire   [1                              -1 :0]    ori_val_i_w                 ;

  wire   [`IME_PIXEL_WIDTH*1024          -1 :0]    ori_dat_o_w                 ;

  // ime_ref_dat_array
  reg    [1               *DLY_MEM       -1 :0]    ref_val_i_r                 ;
  reg    [2               *DLY_MEM       -1 :0]    ref_dir_i_r                 ;
  wire   [1                              -1 :0]    ref_val_i_w                 ;
  wire   [2                              -1 :0]    ref_dir_i_w                 ;
  wire   [`IME_PIXEL_WIDTH*32            -1 :0]    ref_ver_dat_i_w             ;

  wire   [`IME_PIXEL_WIDTH*1024          -1 :0]    ref_dat_o_w                 ;

  // ime_sad_array
  reg    [1               *DLY_MEM       -1 :0]    sad_val_i_r                 ;
  reg    [2               *DLY_MEM       -1 :0]    sad_dat_qd_i_r              ;
  reg    [`IME_MV_WIDTH   *DLY_MEM       -1 :0]    sad_dat_mv_i_r              ;
  reg    [`IME_C_MV_WIDTH *DLY_MEM       -1 :0]    sad_dat_cst_mvd_i_r         ;
  wire   [1                              -1 :0]    sad_val_i_w                 ;
  wire   [2                              -1 :0]    sad_dat_qd_i_w              ;
  wire   [`IME_MV_WIDTH                  -1 :0]    sad_dat_mv_i_w              ;
  wire   [`IME_C_MV_WIDTH                -1 :0]    sad_dat_cst_mvd_i_w         ;

  wire                                             sad_val_04_o_w              ;
  wire   [2                              -1 :0]    sad_dat_04_qd_o_w           ;
  wire   [`IME_MV_WIDTH                  -1 :0]    sad_dat_04_mv_o_w           ;
  wire   [`IME_C_MV_WIDTH                -1 :0]    sad_dat_04_cst_mvd_o_w      ;
  wire   [`IME_COST_WIDTH *64            -1 :0]    sad_dat_04_cst_sad_0_o_w    ;    // TODO : finialize IME_COST_WIDTH
  wire                                             sad_val_08_o_w              ;
  wire   [2                              -1 :0]    sad_dat_08_qd_o_w           ;
  wire   [`IME_MV_WIDTH                  -1 :0]    sad_dat_08_mv_o_w           ;
  wire   [`IME_C_MV_WIDTH                -1 :0]    sad_dat_08_cst_mvd_o_w      ;
  wire   [`IME_COST_WIDTH *16            -1 :0]    sad_dat_08_cst_sad_0_o_w    ;
  wire   [`IME_COST_WIDTH *32            -1 :0]    sad_dat_08_cst_sad_1_o_w    ;
  wire   [`IME_COST_WIDTH *32            -1 :0]    sad_dat_08_cst_sad_2_o_w    ;
  wire                                             sad_val_16_o_w              ;
  wire   [2                              -1 :0]    sad_dat_16_qd_o_w           ;
  wire   [`IME_MV_WIDTH                  -1 :0]    sad_dat_16_mv_o_w           ;
  wire   [`IME_C_MV_WIDTH                -1 :0]    sad_dat_16_cst_mvd_o_w      ;
  wire   [`IME_COST_WIDTH *4             -1 :0]    sad_dat_16_cst_sad_0_o_w    ;
  wire   [`IME_COST_WIDTH *8             -1 :0]    sad_dat_16_cst_sad_1_o_w    ;
  wire   [`IME_COST_WIDTH *8             -1 :0]    sad_dat_16_cst_sad_2_o_w    ;
  wire                                             sad_val_32_o_w              ;
  wire   [2                              -1 :0]    sad_dat_32_qd_o_w           ;
  wire   [`IME_MV_WIDTH                  -1 :0]    sad_dat_32_mv_o_w           ;
  wire   [`IME_C_MV_WIDTH                -1 :0]    sad_dat_32_cst_mvd_o_w      ;
  wire   [`IME_COST_WIDTH *1             -1 :0]    sad_dat_32_cst_sad_0_o_w    ;
  wire   [`IME_COST_WIDTH *2             -1 :0]    sad_dat_32_cst_sad_1_o_w    ;
  wire   [`IME_COST_WIDTH *2             -1 :0]    sad_dat_32_cst_sad_2_o_w    ;

  // ime_cost_store
  wire   [`IME_MV_WIDTH   *64            -1 :0]    str_dat_08_mv_0_o_w         ;
  wire   [`IME_MV_WIDTH   *16            -1 :0]    str_dat_16_mv_0_o_w         ;
  wire   [`IME_MV_WIDTH   *32            -1 :0]    str_dat_16_mv_1_o_w         ;
  wire   [`IME_MV_WIDTH   *32            -1 :0]    str_dat_16_mv_2_o_w         ;
  wire   [`IME_MV_WIDTH   *4             -1 :0]    str_dat_32_mv_0_o_w         ;
  wire   [`IME_MV_WIDTH   *8             -1 :0]    str_dat_32_mv_1_o_w         ;
  wire   [`IME_MV_WIDTH   *8             -1 :0]    str_dat_32_mv_2_o_w         ;
  wire   [`IME_MV_WIDTH   *1             -1 :0]    str_dat_64_mv_0_o_w         ;
  wire   [`IME_MV_WIDTH   *2             -1 :0]    str_dat_64_mv_1_o_w         ;
  wire   [`IME_MV_WIDTH   *2             -1 :0]    str_dat_64_mv_2_o_w         ;
  wire   [`IME_COST_WIDTH *64            -1 :0]    str_dat_08_cst_0_o_w        ;
  wire   [`IME_COST_WIDTH *16            -1 :0]    str_dat_16_cst_0_o_w        ;
  wire   [`IME_COST_WIDTH *32            -1 :0]    str_dat_16_cst_1_o_w        ;
  wire   [`IME_COST_WIDTH *32            -1 :0]    str_dat_16_cst_2_o_w        ;
  wire   [`IME_COST_WIDTH *4             -1 :0]    str_dat_32_cst_0_o_w        ;
  wire   [`IME_COST_WIDTH *8             -1 :0]    str_dat_32_cst_1_o_w        ;
  wire   [`IME_COST_WIDTH *8             -1 :0]    str_dat_32_cst_2_o_w        ;
  wire   [`IME_COST_WIDTH *1             -1 :0]    str_dat_64_cst_0_o_w        ;
  wire   [`IME_COST_WIDTH *2             -1 :0]    str_dat_64_cst_1_o_w        ;
  wire   [`IME_COST_WIDTH *2             -1 :0]    str_dat_64_cst_2_o_w        ;

  // ime_partition_decision
  wire                                             dec_done_o_w                ;
  wire   [42                             -1 :0]    dec_partition_o_w           ;

  // ime_mv_dmp
  wire                                             dmp_done_o_w                ;


//*** MAIN BODY ****************************************************************

  // assignment
  `ifdef IME_HAS_VER_MEM
    assign downsample_o = tra_busy_o_w ? 0 : ctr_downsample_o_w ;
  `else
    assign downsample_o = ctr_downsample_o_w ;
  `endif


`ifdef IME_HAS_VER_MEM
  // ime_transfer
  ime_transfer ime_transfer(
    // global
    .clk                   ( clk                         ),
    .rstn                  ( rstn                        ),
    // ctrl_if
    .start_i               (     start_i                 ),
    .ctu_x_cur_i           (     ctu_x_cur_i             ),
    .done_o                ( tra_done_o_w                ),
    .busy_o                ( tra_busy_o_w                ),
    // ref_rd
    .ref_rd_dir_o          ( tra_ref_rd_dir_o_w          ),
    .ref_rd_ena_o          ( tra_ref_rd_ena_o_w          ),
    .ref_rd_adr_x_o        ( tra_ref_rd_adr_x_o_w        ),
    .ref_rd_adr_y_o        ( tra_ref_rd_adr_y_o_w        ),
    // ref_wr
    .ref_wr_dir_o          ( tra_ref_wr_dir_o_w          ),
    .ref_wr_ena_o          ( tra_ref_wr_ena_o_w          ),
    .ref_wr_adr_x_o        ( tra_ref_wr_adr_x_o_w        ),
    .ref_wr_adr_y_o        ( tra_ref_wr_adr_y_o_w        )
    );

  // assignment
  assign ref_hor_dir_w   = tra_busy_o_w ? tra_ref_rd_dir_o_w   : adr_ref_dir_o_w       ;
  assign ref_hor_ena_o   = tra_busy_o_w ? tra_ref_rd_ena_o_w   : adr_ref_hor_ena_o_w   ;
  assign ref_hor_adr_x_o = tra_busy_o_w ? tra_ref_rd_adr_x_o_w : adr_ref_hor_adr_x_o_w ;
  assign ref_hor_adr_y_o = tra_busy_o_w ? tra_ref_rd_adr_y_o_w : adr_ref_hor_adr_y_o_w ;

  // delay
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      mem_wr_dir_i_r   <= {{(2                  *(DLY_MEM+0)){1'b0}}} ;
      mem_wr_ena_i_r   <= {{(1                  *(DLY_MEM+0)){1'b0}}} ;
      mem_wr_adr_x_i_r <= {{((`IME_MV_WIDTH_X+1)*(DLY_MEM+0)){1'b0}}} ;
      mem_wr_adr_y_i_r <= {{((`IME_MV_WIDTH_Y+1)*(DLY_MEM+0)){1'b0}}} ;
    end
    else begin
      mem_wr_dir_i_r   <= { mem_wr_dir_i_r   ,tra_ref_wr_dir_o_w   };
      mem_wr_ena_i_r   <= { mem_wr_ena_i_r   ,tra_ref_wr_ena_o_w   };
      mem_wr_adr_x_i_r <= { mem_wr_adr_x_i_r ,tra_ref_wr_adr_x_o_w };
      mem_wr_adr_y_i_r <= { mem_wr_adr_y_i_r ,tra_ref_wr_adr_y_o_w };
    end
  end

  assign mem_wr_dir_i_w   = mem_wr_dir_i_r   [2                  *(DLY_MEM+0)-1:2                  *(DLY_MEM-1)] ;
  assign mem_wr_ena_i_w   = mem_wr_ena_i_r   [1                  *(DLY_MEM+0)-1:1                  *(DLY_MEM-1)] ;
  assign mem_wr_adr_x_i_w = mem_wr_adr_x_i_r [(`IME_MV_WIDTH_Y+1)*(DLY_MEM+0)-1:(`IME_MV_WIDTH_Y+1)*(DLY_MEM-1)] ;
  assign mem_wr_adr_y_i_w = mem_wr_adr_y_i_r [(`IME_MV_WIDTH_X+1)*(DLY_MEM+0)-1:(`IME_MV_WIDTH_X+1)*(DLY_MEM-1)] ;
  assign mem_wr_dat_i_w   = ref_dat_o_w ;

  // ime_ver_mem
  ime_ver_mem ime_ver_mem(
    // global
    .clk                   ( clk                         ),
    .rstn                  ( rstn                        ),
    // cfg_i
    .rotate_i              (     start_i                 ),
    .downsample_i          ( ctr_downsample_o_w          ),
    // wr_if
    .wr_dir_i              ( mem_wr_dir_i_w              ),
    .wr_ena_i              ( mem_wr_ena_i_w              ),
    .wr_adr_x_i            ( mem_wr_adr_x_i_w            ),
    .wr_adr_y_i            ( mem_wr_adr_y_i_w            ),
    .wr_dat_i              ( mem_wr_dat_i_w              ),
    // rd_if
    .rd_ena_i              (     ref_ver_ena_o           ),
    .rd_adr_x_i            (     ref_ver_adr_x_o         ),
    .rd_adr_y_i            (     ref_ver_adr_y_o         ),
    .rd_dat_o              ( mem_rd_dat_o_w              )
    );

  // assignment
  assign ref_ver_dat_i_w = tra_busy_o_w ? ref_hor_dat_i : mem_rd_dat_o_w ;
`else
  // assignment
  assign ref_hor_dir_w   = adr_ref_dir_o_w       ;
  assign ref_hor_ena_o   = adr_ref_hor_ena_o_w   ;
  assign ref_hor_adr_x_o = adr_ref_hor_adr_x_o_w ;
  assign ref_hor_adr_y_o = adr_ref_hor_adr_y_o_w ;

  // assignment
  assign ref_ver_dat_i_w = ref_ver_dat_i         ;
`endif

  // ime_ctrl
  ime_ctrl #(
    .CMD_NUM_WIDTH         ( CMD_NUM_WIDTH               )
  ) ime_ctrl(
    // global
    .clk                   ( clk                         ),
    .rstn                  ( rstn                        ),
    // cfg_i
    .cmd_num_i             (     cmd_num_i               ),
    .cmd_dat_i             (     cmd_dat_i               ),
    // ctrl_if
`ifdef IME_HAS_VER_MEM
    .start_i               ( tra_done_o_w                ),
`else
    .start_i               (     start_i                 ),
`endif
    .done_o                (     done_o                  ),
    // cfg_o
    .center_x_o            ( ctr_center_x_o_w            ),
    .center_y_o            ( ctr_center_y_o_w            ),
    .length_x_o            ( ctr_length_x_o_w            ),
    .length_y_o            ( ctr_length_y_o_w            ),
    .slope_o               ( ctr_slope_o_w               ),
    .downsample_o          ( ctr_downsample_o_w          ),
    .use_feedback_o        ( ctr_use_feedback_o_w        ),
    // ctrl_if (inner)
    .start_adr_o           ( ctr_start_adr_o_w           ),
    .start_dec_o           ( ctr_start_dec_o_w           ),
    .start_dmp_o           ( ctr_start_dmp_o_w           ),
    .done_adr_i            ( ctr_done_adr_i_w            ),
    .done_dec_i            ( dec_done_o_w                ),
    .done_dmp_i            ( dmp_done_o_w                )
    );

  // ime_addressing
  ime_addressing ime_addressing(
    // global
    .clk                   ( clk                         ),
    .rstn                  ( rstn                        ),
    // ctrl_if
    .start_i               ( ctr_start_adr_o_w           ),
    .qp_i                  (     qp_i                    ),
    .done_o                ( adr_done_o_w                ),
    // cfg_i
    .center_x_i            ( ctr_center_x_o_w            ),
    .center_y_i            ( ctr_center_y_o_w            ),
    .length_x_i            ( ctr_length_x_o_w            ),
    .length_y_i            ( ctr_length_y_o_w            ),
    .slope_i               ( ctr_slope_o_w               ),
    .downsample_i          ( ctr_downsample_o_w          ),
    .use_feedback_i        ( ctr_use_feedback_o_w        ),
    // feedback_i
    .dat_32_mv_i           ( str_dat_32_mv_0_o_w         ),
    // ori
    .ori_ena_o             (     ori_ena_o               ),
    .ori_adr_x_o           (     ori_adr_x_o             ),
    .ori_adr_y_o           (     ori_adr_y_o             ),
    // ref
    .ref_dir_o             ( adr_ref_dir_o_w             ),
    .ref_hor_ena_o         ( adr_ref_hor_ena_o_w         ),
    .ref_hor_adr_x_o       ( adr_ref_hor_adr_x_o_w       ),
    .ref_hor_adr_y_o       ( adr_ref_hor_adr_y_o_w       ),
    .ref_ver_ena_o         (     ref_ver_ena_o           ),
    .ref_ver_adr_x_o       (     ref_ver_adr_x_o         ),
    .ref_ver_adr_y_o       (     ref_ver_adr_y_o         ),
    // status
    .val_o                 ( adr_val_o_w                 ),
    .dat_qd_o              ( adr_dat_qd_o_w              ),
    .dat_mv_o              ( adr_dat_mv_o_w              ),
    .dat_cst_mvd_o         ( adr_dat_cst_mvd_o_w         )
    );

  // delay
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ctr_done_adr_i_r    <= {{(1              *(DLY_MEM+6)){1'b0}}} ;
      ori_val_i_r         <= {{(1              *(DLY_MEM+0)){1'b0}}} ;
      ref_val_i_r         <= {{(1              *(DLY_MEM+0)){1'b0}}} ;
      ref_dir_i_r         <= {{(2              *(DLY_MEM+0)){1'b0}}} ;
      sad_val_i_r         <= {{(1              *(DLY_MEM+0)){1'b0}}} ;
      sad_dat_qd_i_r      <= {{(`IME_MV_WIDTH  *(DLY_MEM+0)){1'b0}}} ;
      sad_dat_mv_i_r      <= {{(`IME_MV_WIDTH  *(DLY_MEM+0)){1'b0}}} ;
      sad_dat_cst_mvd_i_r <= {{(`IME_C_MV_WIDTH*(DLY_MEM+0)){1'b0}}} ;
    end
    else begin
      ctr_done_adr_i_r    <= { ctr_done_adr_i_r   ,adr_done_o_w                 };
      ori_val_i_r         <= { ori_val_i_r        ,ori_ena_o                    };
      ref_val_i_r         <= { ref_val_i_r        ,ref_hor_ena_o||ref_ver_ena_o };
      ref_dir_i_r         <= { ref_dir_i_r        ,ref_hor_dir_w                };
      sad_val_i_r         <= { sad_val_i_r        ,adr_val_o_w                  };
      sad_dat_qd_i_r      <= { sad_dat_qd_i_r     ,adr_dat_qd_o_w               };
      sad_dat_mv_i_r      <= { sad_dat_mv_i_r     ,adr_dat_mv_o_w               };
      sad_dat_cst_mvd_i_r <= { sad_dat_cst_mvd_i_r,adr_dat_cst_mvd_o_w          };
    end
  end

  assign ctr_done_adr_i_w    = ctr_done_adr_i_r   [1              *(DLY_MEM+6)-1:1              *(DLY_MEM+5)] ;
  assign ori_val_i_w         = ori_val_i_r        [1              *(DLY_MEM+0)-1:1              *(DLY_MEM-1)] ;
  assign ref_val_i_w         = ref_val_i_r        [1              *(DLY_MEM+0)-1:1              *(DLY_MEM-1)] ;
  assign ref_dir_i_w         = ref_dir_i_r        [2              *(DLY_MEM+0)-1:2              *(DLY_MEM-1)] ;
  assign sad_val_i_w         = sad_val_i_r        [1              *(DLY_MEM+0)-1:1              *(DLY_MEM-1)] ;
  assign sad_dat_qd_i_w      = sad_dat_qd_i_r     [2              *(DLY_MEM+0)-1:2              *(DLY_MEM-1)] ;
  assign sad_dat_mv_i_w      = sad_dat_mv_i_r     [`IME_MV_WIDTH  *(DLY_MEM+0)-1:`IME_MV_WIDTH  *(DLY_MEM-1)] ;
  assign sad_dat_cst_mvd_i_w = sad_dat_cst_mvd_i_r[`IME_C_MV_WIDTH*(DLY_MEM+0)-1:`IME_C_MV_WIDTH*(DLY_MEM-1)] ;

  // ime_ori_dat_array
  ime_dat_array ime_ori_dat_array(
    // global
    .clk                   ( clk                         ),
    .rstn                  ( rstn                        ),
    // input
    .val_i                 ( ori_val_i_w                 ),
    .dir_i                 (`IME_DIR_DOWN                ),
    .dat_hor_i             ( ori_dat_i                   ),
    .dat_ver_i             ({{(`IME_PIXEL_WIDTH*32){1'b0}}}
                                                         ),
    // output
    .dat_o                 ( ori_dat_o_w                 )
    );

  // ime_ref_dat_array
  ime_dat_array ime_ref_dat_array(
    // global
    .clk                   ( clk                         ),
    .rstn                  ( rstn                        ),
    // input
    .val_i                 ( ref_val_i_w                 ),
    .dir_i                 ( ref_dir_i_w                 ),
    .dat_hor_i             ( ref_hor_dat_i               ),
    .dat_ver_i             ( ref_ver_dat_i_w             ),
    // output
    .dat_o                 ( ref_dat_o_w                 )
    );

  // ime_sad_array
  ime_sad_array ime_sad_array(
    // global
    .clk                   ( clk                         ),
    .rstn                  ( rstn                        ),
    // input
    .val_i                 ( sad_val_i_w                 ),
    .dat_mv_i              ( sad_dat_mv_i_w              ),
    .dat_cst_mvd_i         ( sad_dat_cst_mvd_i_w         ),
    .dat_qd_i              ( sad_dat_qd_i_w              ),
    .dat_ori_i             ( ori_dat_o_w                 ),
    .dat_ref_i             ( ref_dat_o_w                 ),
    // output
    .val_04_o              ( sad_val_04_o_w              ),
    .dat_04_qd_o           ( sad_dat_04_qd_o_w           ),
    .dat_04_mv_o           ( sad_dat_04_mv_o_w           ),
    .dat_04_cst_mvd_o      ( sad_dat_04_cst_mvd_o_w      ),
    .dat_04_cst_sad_0_o    ( sad_dat_04_cst_sad_0_o_w    ),
    .val_08_o              ( sad_val_08_o_w              ),
    .dat_08_qd_o           ( sad_dat_08_qd_o_w           ),
    .dat_08_mv_o           ( sad_dat_08_mv_o_w           ),
    .dat_08_cst_mvd_o      ( sad_dat_08_cst_mvd_o_w      ),
    .dat_08_cst_sad_0_o    ( sad_dat_08_cst_sad_0_o_w    ),
    .dat_08_cst_sad_1_o    ( sad_dat_08_cst_sad_1_o_w    ),
    .dat_08_cst_sad_2_o    ( sad_dat_08_cst_sad_2_o_w    ),
    .val_16_o              ( sad_val_16_o_w              ),
    .dat_16_qd_o           ( sad_dat_16_qd_o_w           ),
    .dat_16_mv_o           ( sad_dat_16_mv_o_w           ),
    .dat_16_cst_mvd_o      ( sad_dat_16_cst_mvd_o_w      ),
    .dat_16_cst_sad_0_o    ( sad_dat_16_cst_sad_0_o_w    ),
    .dat_16_cst_sad_1_o    ( sad_dat_16_cst_sad_1_o_w    ),
    .dat_16_cst_sad_2_o    ( sad_dat_16_cst_sad_2_o_w    ),
    .val_32_o              ( sad_val_32_o_w              ),
    .dat_32_qd_o           ( sad_dat_32_qd_o_w           ),
    .dat_32_mv_o           ( sad_dat_32_mv_o_w           ),
    .dat_32_cst_mvd_o      ( sad_dat_32_cst_mvd_o_w      ),
    .dat_32_cst_sad_0_o    ( sad_dat_32_cst_sad_0_o_w    ),
    .dat_32_cst_sad_1_o    ( sad_dat_32_cst_sad_1_o_w    ),
    .dat_32_cst_sad_2_o    ( sad_dat_32_cst_sad_2_o_w    )
    );

  // ime_cost_store
  ime_cost_store ime_cost_store(
    // global
    .clk                   ( clk                         ),
    .rstn                  ( rstn                        ),
    // config
    .clear_i               ( start_i                     ),
    .downsample_i          ( ctr_downsample_o_w          ),
    // input
    .val_04_i              ( sad_val_04_o_w              ),
    .dat_04_qd_i           ( sad_dat_04_qd_o_w           ),
    .dat_04_mv_i           ( sad_dat_04_mv_o_w           ),
    .dat_04_cst_mvd_i      ( sad_dat_04_cst_mvd_o_w      ),
    .dat_04_cst_sad_0_i    ( sad_dat_04_cst_sad_0_o_w    ),
    .val_08_i              ( sad_val_08_o_w              ),
    .dat_08_qd_i           ( sad_dat_08_qd_o_w           ),
    .dat_08_mv_i           ( sad_dat_08_mv_o_w           ),
    .dat_08_cst_mvd_i      ( sad_dat_08_cst_mvd_o_w      ),
    .dat_08_cst_sad_0_i    ( sad_dat_08_cst_sad_0_o_w    ),
    .dat_08_cst_sad_1_i    ( sad_dat_08_cst_sad_1_o_w    ),
    .dat_08_cst_sad_2_i    ( sad_dat_08_cst_sad_2_o_w    ),
    .val_16_i              ( sad_val_16_o_w              ),
    .dat_16_qd_i           ( sad_dat_16_qd_o_w           ),
    .dat_16_mv_i           ( sad_dat_16_mv_o_w           ),
    .dat_16_cst_mvd_i      ( sad_dat_16_cst_mvd_o_w      ),
    .dat_16_cst_sad_0_i    ( sad_dat_16_cst_sad_0_o_w    ),
    .dat_16_cst_sad_1_i    ( sad_dat_16_cst_sad_1_o_w    ),
    .dat_16_cst_sad_2_i    ( sad_dat_16_cst_sad_2_o_w    ),
    .val_32_i              ( sad_val_32_o_w              ),
    .dat_32_qd_i           ( sad_dat_32_qd_o_w           ),
    .dat_32_mv_i           ( sad_dat_32_mv_o_w           ),
    .dat_32_cst_mvd_i      ( sad_dat_32_cst_mvd_o_w      ),
    .dat_32_cst_sad_0_i    ( sad_dat_32_cst_sad_0_o_w    ),
    .dat_32_cst_sad_1_i    ( sad_dat_32_cst_sad_1_o_w    ),
    .dat_32_cst_sad_2_i    ( sad_dat_32_cst_sad_2_o_w    ),
    // output
    .dat_08_mv_0_o         ( str_dat_08_mv_0_o_w         ),
    .dat_16_mv_0_o         ( str_dat_16_mv_0_o_w         ),
    .dat_16_mv_1_o         ( str_dat_16_mv_1_o_w         ),
    .dat_16_mv_2_o         ( str_dat_16_mv_2_o_w         ),
    .dat_32_mv_0_o         ( str_dat_32_mv_0_o_w         ),
    .dat_32_mv_1_o         ( str_dat_32_mv_1_o_w         ),
    .dat_32_mv_2_o         ( str_dat_32_mv_2_o_w         ),
    .dat_64_mv_0_o         ( str_dat_64_mv_0_o_w         ),
    .dat_64_mv_1_o         ( str_dat_64_mv_1_o_w         ),
    .dat_64_mv_2_o         ( str_dat_64_mv_2_o_w         ),
    .dat_08_cst_0_o        ( str_dat_08_cst_0_o_w        ),
    .dat_16_cst_0_o        ( str_dat_16_cst_0_o_w        ),
    .dat_16_cst_1_o        ( str_dat_16_cst_1_o_w        ),
    .dat_16_cst_2_o        ( str_dat_16_cst_2_o_w        ),
    .dat_32_cst_0_o        ( str_dat_32_cst_0_o_w        ),
    .dat_32_cst_1_o        ( str_dat_32_cst_1_o_w        ),
    .dat_32_cst_2_o        ( str_dat_32_cst_2_o_w        ),
    .dat_64_cst_0_o        ( str_dat_64_cst_0_o_w        ),
    .dat_64_cst_1_o        ( str_dat_64_cst_1_o_w        ),
    .dat_64_cst_2_o        ( str_dat_64_cst_2_o_w        )
    );

  // ime_partition_decision
  ime_partition_decision ime_partition_decision(
    // global
    .clk                   ( clk                         ),
    .rstn                  ( rstn                        ),
    // ctrl
    .start_i               ( ctr_start_dec_o_w           ),
    .done_o                ( dec_done_o_w                ),
    .ctu_x_all_i           ( ctu_x_all_i                 ),
    .ctu_y_all_i           ( ctu_y_all_i                 ),
    .ctu_x_res_i           ( ctu_x_res_i                 ),
    .ctu_y_res_i           ( ctu_y_res_i                 ),
    .ctu_x_cur_i           ( ctu_x_cur_i                 ),
    .ctu_y_cur_i           ( ctu_y_cur_i                 ),
    // input
    .dat_08_cst_0_i        ( str_dat_08_cst_0_o_w        ),
    .dat_16_cst_0_i        ( str_dat_16_cst_0_o_w        ),
    .dat_16_cst_1_i        ( str_dat_16_cst_1_o_w        ),
    .dat_16_cst_2_i        ( str_dat_16_cst_2_o_w        ),
    .dat_32_cst_0_i        ( str_dat_32_cst_0_o_w        ),
    .dat_32_cst_1_i        ( str_dat_32_cst_1_o_w        ),
    .dat_32_cst_2_i        ( str_dat_32_cst_2_o_w        ),
    .dat_64_cst_0_i        ( str_dat_64_cst_0_o_w        ),
    .dat_64_cst_1_i        ( str_dat_64_cst_1_o_w        ),
    .dat_64_cst_2_i        ( str_dat_64_cst_2_o_w        ),
    // output
    .dat_partition_o       ( dec_partition_o_w           )
    );

  // ime_mv_dump
  ime_mv_dump ime_mv_dump(
    // global
    .clk                   ( clk                         ),
    .rstn                  ( rstn                        ),
    // ctrl
    .start_i               ( ctr_start_dmp_o_w           ),
    .done_o                ( dmp_done_o_w                ),
    // input
    .dat_partition_i       ( dec_partition_o_w           ),
    .dat_08_mv_0_i         ( str_dat_08_mv_0_o_w         ),
    .dat_16_mv_0_i         ( str_dat_16_mv_0_o_w         ),
    .dat_16_mv_1_i         ( str_dat_16_mv_1_o_w         ),
    .dat_16_mv_2_i         ( str_dat_16_mv_2_o_w         ),
    .dat_32_mv_0_i         ( str_dat_32_mv_0_o_w         ),
    .dat_32_mv_1_i         ( str_dat_32_mv_1_o_w         ),
    .dat_32_mv_2_i         ( str_dat_32_mv_2_o_w         ),
    .dat_64_mv_0_i         ( str_dat_64_mv_0_o_w         ),
    .dat_64_mv_1_i         ( str_dat_64_mv_1_o_w         ),
    .dat_64_mv_2_i         ( str_dat_64_mv_2_o_w         ),
    // output
    .mv_wr_ena_o           (     mv_wr_ena_o             ),
    .mv_wr_adr_o           (     mv_wr_adr_o             ),
    .mv_wr_dat_o           (     mv_wr_dat_o             )
    );

  // ime_glue_logic
  ime_glue_logic ime_glue_logic(
    // global
    .clk                   ( clk                         ),
    .rstn                  ( rstn                        ),
    // input
    .val_i                 ( dmp_done_o_w                ),
    .prt_i                 ( dec_partition_o_w           ),
    // output
    .prt_o                 (     partition_o             )
    );


//*** DEBUG ********************************************************************

  `ifdef DEBUG


  `endif

endmodule










//*** SUB-MODULE ***************************************************************

module ime_glue_logic (
  input           clk   ,
  input           rstn  ,
  input           val_i ,
  input  [42-1:0] prt_i ,
  output [42-1:0] prt_o
  );

  // reorder & mask
  wire [2-1:0] partition_64_0_0_w ; reg [2-1:0] partition_64_0_0_r ;
  wire [2-1:0] partition_32_1_1_w ; reg [2-1:0] partition_32_1_1_r ;
  wire [2-1:0] partition_32_1_0_w ; reg [2-1:0] partition_32_1_0_r ;
  wire [2-1:0] partition_32_0_1_w ; reg [2-1:0] partition_32_0_1_r ;
  wire [2-1:0] partition_32_0_0_w ; reg [2-1:0] partition_32_0_0_r ;
  wire [2-1:0] partition_16_3_3_w ; reg [2-1:0] partition_16_3_3_r ;
  wire [2-1:0] partition_16_3_2_w ; reg [2-1:0] partition_16_3_2_r ;
  wire [2-1:0] partition_16_3_1_w ; reg [2-1:0] partition_16_3_1_r ;
  wire [2-1:0] partition_16_3_0_w ; reg [2-1:0] partition_16_3_0_r ;
  wire [2-1:0] partition_16_2_3_w ; reg [2-1:0] partition_16_2_3_r ;
  wire [2-1:0] partition_16_2_2_w ; reg [2-1:0] partition_16_2_2_r ;
  wire [2-1:0] partition_16_2_1_w ; reg [2-1:0] partition_16_2_1_r ;
  wire [2-1:0] partition_16_2_0_w ; reg [2-1:0] partition_16_2_0_r ;
  wire [2-1:0] partition_16_1_3_w ; reg [2-1:0] partition_16_1_3_r ;
  wire [2-1:0] partition_16_1_2_w ; reg [2-1:0] partition_16_1_2_r ;
  wire [2-1:0] partition_16_1_1_w ; reg [2-1:0] partition_16_1_1_r ;
  wire [2-1:0] partition_16_1_0_w ; reg [2-1:0] partition_16_1_0_r ;
  wire [2-1:0] partition_16_0_3_w ; reg [2-1:0] partition_16_0_3_r ;
  wire [2-1:0] partition_16_0_2_w ; reg [2-1:0] partition_16_0_2_r ;
  wire [2-1:0] partition_16_0_1_w ; reg [2-1:0] partition_16_0_1_r ;
  wire [2-1:0] partition_16_0_0_w ; reg [2-1:0] partition_16_0_0_r ;

  assign { partition_64_0_0_w
          ,partition_32_1_1_w
          ,partition_32_1_0_w
          ,partition_32_0_1_w
          ,partition_32_0_0_w
          ,partition_16_3_3_w
          ,partition_16_3_2_w
          ,partition_16_3_1_w
          ,partition_16_3_0_w
          ,partition_16_2_3_w
          ,partition_16_2_2_w
          ,partition_16_2_1_w
          ,partition_16_2_0_w
          ,partition_16_1_3_w
          ,partition_16_1_2_w
          ,partition_16_1_1_w
          ,partition_16_1_0_w
          ,partition_16_0_3_w
          ,partition_16_0_2_w
          ,partition_16_0_1_w
          ,partition_16_0_0_w } = prt_i ;

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      partition_64_0_0_r <= 0 ;
      partition_32_1_1_r <= 0 ;
      partition_32_1_0_r <= 0 ;
      partition_32_0_1_r <= 0 ;
      partition_32_0_0_r <= 0 ;
      partition_16_3_3_r <= 0 ;
      partition_16_3_2_r <= 0 ;
      partition_16_3_1_r <= 0 ;
      partition_16_3_0_r <= 0 ;
      partition_16_2_3_r <= 0 ;
      partition_16_2_2_r <= 0 ;
      partition_16_2_1_r <= 0 ;
      partition_16_2_0_r <= 0 ;
      partition_16_1_3_r <= 0 ;
      partition_16_1_2_r <= 0 ;
      partition_16_1_1_r <= 0 ;
      partition_16_1_0_r <= 0 ;
      partition_16_0_3_r <= 0 ;
      partition_16_0_2_r <= 0 ;
      partition_16_0_1_r <= 0 ;
      partition_16_0_0_r <= 0 ;
    end
    else begin
      if( val_i ) begin
        // default
        partition_32_1_1_r <= `IME_PART_2NX2N ;
        partition_32_1_0_r <= `IME_PART_2NX2N ;
        partition_32_0_1_r <= `IME_PART_2NX2N ;
        partition_32_0_0_r <= `IME_PART_2NX2N ;
        partition_16_3_3_r <= `IME_PART_2NX2N ;
        partition_16_3_2_r <= `IME_PART_2NX2N ;
        partition_16_3_1_r <= `IME_PART_2NX2N ;
        partition_16_3_0_r <= `IME_PART_2NX2N ;
        partition_16_2_3_r <= `IME_PART_2NX2N ;
        partition_16_2_2_r <= `IME_PART_2NX2N ;
        partition_16_2_1_r <= `IME_PART_2NX2N ;
        partition_16_2_0_r <= `IME_PART_2NX2N ;
        partition_16_1_3_r <= `IME_PART_2NX2N ;
        partition_16_1_2_r <= `IME_PART_2NX2N ;
        partition_16_1_1_r <= `IME_PART_2NX2N ;
        partition_16_1_0_r <= `IME_PART_2NX2N ;
        partition_16_0_3_r <= `IME_PART_2NX2N ;
        partition_16_0_2_r <= `IME_PART_2NX2N ;
        partition_16_0_1_r <= `IME_PART_2NX2N ;
        partition_16_0_0_r <= `IME_PART_2NX2N ;
        // 64x64
        partition_64_0_0_r <= partition_64_0_0_w ;
        // 32x32
        if( partition_64_0_0_w==`IME_PART_1NX1N ) begin
          partition_32_1_1_r <= partition_32_1_1_w ;
          partition_32_1_0_r <= partition_32_1_0_w ;
          partition_32_0_1_r <= partition_32_0_1_w ;
          partition_32_0_0_r <= partition_32_0_0_w ;
        end
        // 16x16
        if( (partition_64_0_0_w==`IME_PART_1NX1N) && (partition_32_0_0_w==`IME_PART_1NX1N) ) begin
          partition_16_0_0_r <= partition_16_0_0_w ;
          partition_16_0_1_r <= partition_16_0_1_w ;
          partition_16_1_0_r <= partition_16_1_0_w ;
          partition_16_1_1_r <= partition_16_1_1_w ;
        end
        if( (partition_64_0_0_w==`IME_PART_1NX1N) && (partition_32_0_1_w==`IME_PART_1NX1N) ) begin
          partition_16_0_2_r <= partition_16_0_2_w ;
          partition_16_0_3_r <= partition_16_0_3_w ;
          partition_16_1_2_r <= partition_16_1_2_w ;
          partition_16_1_3_r <= partition_16_1_3_w ;
        end
        if( (partition_64_0_0_w==`IME_PART_1NX1N) && (partition_32_1_0_w==`IME_PART_1NX1N) ) begin
          partition_16_2_0_r <= partition_16_2_0_w ;
          partition_16_2_1_r <= partition_16_2_1_w ;
          partition_16_3_0_r <= partition_16_3_0_w ;
          partition_16_3_1_r <= partition_16_3_1_w ;
        end
        if( (partition_64_0_0_w==`IME_PART_1NX1N) && (partition_32_1_1_w==`IME_PART_1NX1N) ) begin
          partition_16_2_2_r <= partition_16_2_2_w ;
          partition_16_2_3_r <= partition_16_2_3_w ;
          partition_16_3_2_r <= partition_16_3_2_w ;
          partition_16_3_3_r <= partition_16_3_3_w ;
        end
      end
    end
  end

  // reorder according to fme
  assign prt_o = { partition_16_3_3_r
                  ,partition_16_3_2_r
                  ,partition_16_2_3_r
                  ,partition_16_2_2_r
                  ,partition_16_3_1_r
                  ,partition_16_3_0_r
                  ,partition_16_2_1_r
                  ,partition_16_2_0_r
                  ,partition_16_1_3_r
                  ,partition_16_1_2_r
                  ,partition_16_0_3_r
                  ,partition_16_0_2_r
                  ,partition_16_1_1_r
                  ,partition_16_1_0_r
                  ,partition_16_0_1_r
                  ,partition_16_0_0_r
                  ,partition_32_1_1_r
                  ,partition_32_1_0_r
                  ,partition_32_0_1_r
                  ,partition_32_0_0_r
                  ,partition_64_0_0_r
                 };

endmodule
