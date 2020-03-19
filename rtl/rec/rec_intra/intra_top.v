//--------------------------------------------------------------------
//
//  Filename    : intra_top.v
//  Author      : Huang Leilei
//  Description : top of intra
//  Created     : 2017-11-26
//
//--------------------------------------------------------------------
//
//  Modified      : 2018-05-19 by HLL
//  Description   : non-lcu-aligned frame size supported
//  Modified      : 2018-05-21 by HLL
//  Description   : I block in P frame supported
//
//--------------------------------------------------------------------

`include "./enc_defines.v"

module intra_top(
  // global
  clk               ,
  rstn              ,
  // ctrl_if
  start_i           ,
  done_o            ,
  // cfg_i
  type_i            ,
  // pos_i
  ctu_x_all_i       ,
  ctu_y_all_i       ,
  ctu_x_res_i       ,
  ctu_y_res_i       ,
  ctu_x_cur_i       ,
  ctu_y_cur_i       ,
  // pt_i
  partition_i       ,
  // md_if
  md_rd_ena_o       ,
  md_rd_adr_o       ,
  md_rd_dat_i       ,
  // pre_o
  pre_val_o         ,
  pre_sel_o         ,
  pre_siz_o         ,
  pre_4x4_x_o       ,
  pre_4x4_y_o       ,
  pre_dat_o         ,
  // rec_i
  rec_bgn_i         ,
  rec_sel_i         ,
  rec_pos_i         ,
  rec_siz_i         ,
  rec_val_i         ,
  rec_idx_i         ,
  rec_dat_i         ,
  rec_done_o
  );


//*** PARAMETER ****************************************************************


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                clk             ;
  input                                rstn            ;
  // ctrl_if
  input                                start_i         ;
  output                               done_o          ;
  // cfg_i
  input                                type_i          ;
  // pos_i
  input      [`PIC_X_WIDTH   -1 :0]    ctu_x_all_i     ;
  input      [`PIC_Y_WIDTH   -1 :0]    ctu_y_all_i     ;
  input      [4              -1 :0]    ctu_x_res_i     ;
  input      [4              -1 :0]    ctu_y_res_i     ;
  input      [`PIC_X_WIDTH   -1 :0]    ctu_x_cur_i     ;
  input      [`PIC_Y_WIDTH   -1 :0]    ctu_y_cur_i     ;
  // pt_i
  input      [85             -1 :0]    partition_i     ;
  // md_if
  output                               md_rd_ena_o     ;
  output     [8              -1 :0]    md_rd_adr_o     ;
  input      [6              -1 :0]    md_rd_dat_i     ;
  // pre_if
  output                               pre_val_o       ;
  output     [2              -1 :0]    pre_sel_o       ;
  output     [2              -1 :0]    pre_siz_o       ;
  output     [4              -1 :0]    pre_4x4_x_o     ;
  output     [4              -1 :0]    pre_4x4_y_o     ;
  output     [`PIXEL_WIDTH*32-1 :0]    pre_dat_o       ;
  // rec_i
  input                                rec_bgn_i       ;
  input      [2              -1 :0]    rec_sel_i       ;
  input      [8              -1 :0]    rec_pos_i       ;
  input      [2              -1 :0]    rec_siz_i       ;
  input                                rec_val_i       ;
  input      [4                 :0]    rec_idx_i       ;
  input      [`PIXEL_WIDTH*32-1 :0]    rec_dat_i       ;
  output                               rec_done_o      ;


//*** REG/WIRE ***************************************************************

  // ctrl
  wire       [1                 :0]    loop_sel_w      ;
  wire       [1                 :0]    loop_size_w     ;
  wire       [5                 :0]    loop_mode_w     ;
  wire       [7                 :0]    loop_position_w ;

  wire                                 ref_start_w     ;
  wire                                 ref_ready_w     ;
  wire                                 ref_done_w      ;

  wire                                 pre_start_w     ;
  wire       [3                 :0]    pre_4x4_x_w     ;
  wire       [3                 :0]    pre_4x4_y_w     ;

  // ref
  wire       [`PIXEL_WIDTH   -1 :0]    ref_tl_w        ;

  wire       [`PIXEL_WIDTH   -1 :0]    ref_t00_w       ,ref_t01_w,ref_t02_w,ref_t03_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_t04_w       ,ref_t05_w,ref_t06_w,ref_t07_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_t08_w       ,ref_t09_w,ref_t10_w,ref_t11_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_t12_w       ,ref_t13_w,ref_t14_w,ref_t15_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_t16_w       ,ref_t17_w,ref_t18_w,ref_t19_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_t20_w       ,ref_t21_w,ref_t22_w,ref_t23_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_t24_w       ,ref_t25_w,ref_t26_w,ref_t27_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_t28_w       ,ref_t29_w,ref_t30_w,ref_t31_w;

  wire       [`PIXEL_WIDTH   -1 :0]    ref_r00_w       ,ref_r01_w,ref_r02_w,ref_r03_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_r04_w       ,ref_r05_w,ref_r06_w,ref_r07_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_r08_w       ,ref_r09_w,ref_r10_w,ref_r11_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_r12_w       ,ref_r13_w,ref_r14_w,ref_r15_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_r16_w       ,ref_r17_w,ref_r18_w,ref_r19_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_r20_w       ,ref_r21_w,ref_r22_w,ref_r23_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_r24_w       ,ref_r25_w,ref_r26_w,ref_r27_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_r28_w       ,ref_r29_w,ref_r30_w,ref_r31_w;

  wire       [`PIXEL_WIDTH   -1 :0]    ref_l00_w       ,ref_l01_w,ref_l02_w,ref_l03_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_l04_w       ,ref_l05_w,ref_l06_w,ref_l07_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_l08_w       ,ref_l09_w,ref_l10_w,ref_l11_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_l12_w       ,ref_l13_w,ref_l14_w,ref_l15_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_l16_w       ,ref_l17_w,ref_l18_w,ref_l19_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_l20_w       ,ref_l21_w,ref_l22_w,ref_l23_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_l24_w       ,ref_l25_w,ref_l26_w,ref_l27_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_l28_w       ,ref_l29_w,ref_l30_w,ref_l31_w;

  wire       [`PIXEL_WIDTH   -1 :0]    ref_d00_w       ,ref_d01_w,ref_d02_w,ref_d03_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_d04_w       ,ref_d05_w,ref_d06_w,ref_d07_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_d08_w       ,ref_d09_w,ref_d10_w,ref_d11_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_d12_w       ,ref_d13_w,ref_d14_w,ref_d15_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_d16_w       ,ref_d17_w,ref_d18_w,ref_d19_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_d20_w       ,ref_d21_w,ref_d22_w,ref_d23_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_d24_w       ,ref_d25_w,ref_d26_w,ref_d27_w;
  wire       [`PIXEL_WIDTH   -1 :0]    ref_d28_w       ,ref_d29_w,ref_d30_w,ref_d31_w;

  // pre
  wire       [`PIXEL_WIDTH   -1 :0]    pre_a00_w       ,pre_a01_w,pre_a02_w,pre_a03_w;
  wire       [`PIXEL_WIDTH   -1 :0]    pre_a10_w       ,pre_a11_w,pre_a12_w,pre_a13_w;
  wire       [`PIXEL_WIDTH   -1 :0]    pre_a20_w       ,pre_a21_w,pre_a22_w,pre_a23_w;
  wire       [`PIXEL_WIDTH   -1 :0]    pre_a30_w       ,pre_a31_w,pre_a32_w,pre_a33_w;

  wire       [`PIXEL_WIDTH   -1 :0]    pre_b00_w       ,pre_b01_w,pre_b02_w,pre_b03_w;
  wire       [`PIXEL_WIDTH   -1 :0]    pre_b10_w       ,pre_b11_w,pre_b12_w,pre_b13_w;
  wire       [`PIXEL_WIDTH   -1 :0]    pre_b20_w       ,pre_b21_w,pre_b22_w,pre_b23_w;
  wire       [`PIXEL_WIDTH   -1 :0]    pre_b30_w       ,pre_b31_w,pre_b32_w,pre_b33_w;

  // row sram wr if
  wire                                 wr_ena_row_w     ;
  wire       [4+4            -1 :0]    wr_adr_row_w     ;
  wire       [`PIXEL_WIDTH*4 -1 :0]    wr_dat_row_w     ;
  // col sram wr if
  wire                                 wr_ena_col_w     ;
  wire       [4+4            -1 :0]    wr_adr_col_w     ;
  wire       [`PIXEL_WIDTH*4 -1 :0]    wr_dat_col_w     ;
  // fra sram wr if
  wire                                 wr_ena_fra_w     ;
  wire       [`PIC_X_WIDTH+4 -1 :0]    wr_adr_fra_w     ;
  wire       [`PIXEL_WIDTH*4 -1 :0]    wr_dat_fra_w     ;
  // row sram rd if
  wire                                 rd_ena_row_w     ;
  wire       [4+4            -1 :0]    rd_adr_row_w     ;
  wire       [`PIXEL_WIDTH*4 -1 :0]    rd_dat_row_w     ;
  // col sram rd if
  wire                                 rd_ena_col_w     ;
  wire       [4+4            -1 :0]    rd_adr_col_w     ;
  wire       [`PIXEL_WIDTH*4 -1 :0]    rd_dat_col_w     ;
  // fra sram rd if
  wire                                 rd_ena_fra_w     ;
  wire       [`PIC_X_WIDTH+4 -1 :0]    rd_adr_fra_w     ;
  wire       [`PIXEL_WIDTH*4 -1 :0]    rd_dat_fra_w     ;


//*** MAIN BODY ****************************************************************

//--- ASSIGMENTS -----------------------
  assign pre_siz_o  = loop_size_w ;
  assign pre_sel_o  = loop_sel_w  ;

  assign rec_done_o = ref_done_w  ;


//--- SUB MODULES ----------------------
  // intra_ctrl
  intra_ctrl u_intra_ctrl(
    // global
    .clk                ( clk                ),
    .rstn               ( rstn               ),
    // ctrl_if
    .start_i            ( start_i            ),
    .done_o             ( done_o             ),
    // pt_i
    .partition_i        ( partition_i        ),
    // md_i
    .md_cena_o          ( md_rd_ena_o        ),
    .md_addr_o          ( md_rd_adr_o        ),
    .md_data_i          ( md_rd_dat_i        ),
    // info_o
    .loop_sel_o         ( loop_sel_w         ),
    .loop_size_o        ( loop_size_w        ),
    .loop_mode_o        ( loop_mode_w        ),
    .loop_position_o    ( loop_position_w    ),
    // ref_if
    .ref_start_o        ( ref_start_w        ),
    .ref_ready_i        ( ref_ready_w        ),
    .ref_done_i         ( ref_done_w         ),
    // pre_o
    .pre_start_o        ( pre_start_w        ),
    .pre_4x4_x_o        ( pre_4x4_x_w        ),
    .pre_4x4_y_o        ( pre_4x4_y_w        )
    );

  intra_ref u_intra_ref(
    // global
    .clk                ( clk               ),
    .rstn               ( rstn              ),
    // ctrl_if
    .start_i            ( ref_start_w       ),
    .pre_ready_o        ( ref_ready_w       ),
    .done_o             ( ref_done_w        ),
    // cfg_i
    .type_i             ( type_i            ),
    .sel_i              ( loop_sel_w        ),
    .position_i         ( loop_position_w   ),
    .size_i             ( loop_size_w       ),
    .mode_i             ( loop_mode_w       ),
    // pos_i
    .ctu_x_all_i        ( ctu_x_all_i       ),
    .ctu_y_all_i        ( ctu_y_all_i       ),
    .ctu_x_res_i        ( ctu_x_res_i       ),
    .ctu_y_res_i        ( ctu_y_res_i       ),
    .ctu_x_cur_i        ( ctu_x_cur_i       ),
    .ctu_y_cur_i        ( ctu_y_cur_i       ),
    // tq_i
    .rec_bgn_i          ( rec_bgn_i         ),
    .rec_sel_i          ( rec_sel_i         ),
    .rec_pos_i          ( rec_pos_i         ),
    .rec_siz_i          ( rec_siz_i         ),
    .rec_val_i          ( rec_val_i         ),
    .rec_idx_i          ( rec_idx_i         ),
    .rec_dat_i          ( rec_dat_i         ),
    // row sram wr if
    .wr_ena_row_o       ( wr_ena_row_w      ),
    .wr_adr_row_o       ( wr_adr_row_w      ),
    .wr_dat_row_o       ( wr_dat_row_w      ),
    // col sram wr if
    .wr_ena_col_o       ( wr_ena_col_w      ),
    .wr_adr_col_o       ( wr_adr_col_w      ),
    .wr_dat_col_o       ( wr_dat_col_w      ),
    // fra sram wr if
    .wr_ena_fra_o       ( wr_ena_fra_w      ),
    .wr_adr_fra_o       ( wr_adr_fra_w      ),
    .wr_dat_fra_o       ( wr_dat_fra_w      ),
    // row sram rd if
    .rd_ena_row_o       ( rd_ena_row_w      ),
    .rd_adr_row_o       ( rd_adr_row_w      ),
    .rd_dat_row_i       ( rd_dat_row_w      ),
    // col sram rd if
    .rd_ena_col_o       ( rd_ena_col_w      ),
    .rd_adr_col_o       ( rd_adr_col_w      ),
    .rd_dat_col_i       ( rd_dat_col_w      ),
    // fra sram rd if
    .rd_ena_fra_o       ( rd_ena_fra_w      ),
    .rd_adr_fra_o       ( rd_adr_fra_w      ),
    .rd_dat_fra_i       ( rd_dat_fra_w      ),
    // tl_ref_o
    .ref_tl_o           ( ref_tl_w          ),
    // t_ref_o
    .ref_t00_o          ( ref_t00_w         ),.ref_t01_o(ref_t01_w),.ref_t02_o(ref_t02_w),.ref_t03_o(ref_t03_w),.ref_t04_o(ref_t04_w),.ref_t05_o(ref_t05_w),.ref_t06_o(ref_t06_w),.ref_t07_o(ref_t07_w),
    .ref_t08_o          ( ref_t08_w         ),.ref_t09_o(ref_t09_w),.ref_t10_o(ref_t10_w),.ref_t11_o(ref_t11_w),.ref_t12_o(ref_t12_w),.ref_t13_o(ref_t13_w),.ref_t14_o(ref_t14_w),.ref_t15_o(ref_t15_w),
    .ref_t16_o          ( ref_t16_w         ),.ref_t17_o(ref_t17_w),.ref_t18_o(ref_t18_w),.ref_t19_o(ref_t19_w),.ref_t20_o(ref_t20_w),.ref_t21_o(ref_t21_w),.ref_t22_o(ref_t22_w),.ref_t23_o(ref_t23_w),
    .ref_t24_o          ( ref_t24_w         ),.ref_t25_o(ref_t25_w),.ref_t26_o(ref_t26_w),.ref_t27_o(ref_t27_w),.ref_t28_o(ref_t28_w),.ref_t29_o(ref_t29_w),.ref_t30_o(ref_t30_w),.ref_t31_o(ref_t31_w),
    // r_ref_o
    .ref_r00_o          ( ref_r00_w         ),.ref_r01_o(ref_r01_w),.ref_r02_o(ref_r02_w),.ref_r03_o(ref_r03_w),.ref_r04_o(ref_r04_w),.ref_r05_o(ref_r05_w),.ref_r06_o(ref_r06_w),.ref_r07_o(ref_r07_w),
    .ref_r08_o          ( ref_r08_w         ),.ref_r09_o(ref_r09_w),.ref_r10_o(ref_r10_w),.ref_r11_o(ref_r11_w),.ref_r12_o(ref_r12_w),.ref_r13_o(ref_r13_w),.ref_r14_o(ref_r14_w),.ref_r15_o(ref_r15_w),
    .ref_r16_o          ( ref_r16_w         ),.ref_r17_o(ref_r17_w),.ref_r18_o(ref_r18_w),.ref_r19_o(ref_r19_w),.ref_r20_o(ref_r20_w),.ref_r21_o(ref_r21_w),.ref_r22_o(ref_r22_w),.ref_r23_o(ref_r23_w),
    .ref_r24_o          ( ref_r24_w         ),.ref_r25_o(ref_r25_w),.ref_r26_o(ref_r26_w),.ref_r27_o(ref_r27_w),.ref_r28_o(ref_r28_w),.ref_r29_o(ref_r29_w),.ref_r30_o(ref_r30_w),.ref_r31_o(ref_r31_w),
    // l_ref_o
    .ref_l00_o          ( ref_l00_w         ),.ref_l01_o(ref_l01_w),.ref_l02_o(ref_l02_w),.ref_l03_o(ref_l03_w),.ref_l04_o(ref_l04_w),.ref_l05_o(ref_l05_w),.ref_l06_o(ref_l06_w),.ref_l07_o(ref_l07_w),
    .ref_l08_o          ( ref_l08_w         ),.ref_l09_o(ref_l09_w),.ref_l10_o(ref_l10_w),.ref_l11_o(ref_l11_w),.ref_l12_o(ref_l12_w),.ref_l13_o(ref_l13_w),.ref_l14_o(ref_l14_w),.ref_l15_o(ref_l15_w),
    .ref_l16_o          ( ref_l16_w         ),.ref_l17_o(ref_l17_w),.ref_l18_o(ref_l18_w),.ref_l19_o(ref_l19_w),.ref_l20_o(ref_l20_w),.ref_l21_o(ref_l21_w),.ref_l22_o(ref_l22_w),.ref_l23_o(ref_l23_w),
    .ref_l24_o          ( ref_l24_w         ),.ref_l25_o(ref_l25_w),.ref_l26_o(ref_l26_w),.ref_l27_o(ref_l27_w),.ref_l28_o(ref_l28_w),.ref_l29_o(ref_l29_w),.ref_l30_o(ref_l30_w),.ref_l31_o(ref_l31_w),
    // d_ref_o
    .ref_d00_o          ( ref_d00_w         ),.ref_d01_o(ref_d01_w),.ref_d02_o(ref_d02_w),.ref_d03_o(ref_d03_w),.ref_d04_o(ref_d04_w),.ref_d05_o(ref_d05_w),.ref_d06_o(ref_d06_w),.ref_d07_o(ref_d07_w),
    .ref_d08_o          ( ref_d08_w         ),.ref_d09_o(ref_d09_w),.ref_d10_o(ref_d10_w),.ref_d11_o(ref_d11_w),.ref_d12_o(ref_d12_w),.ref_d13_o(ref_d13_w),.ref_d14_o(ref_d14_w),.ref_d15_o(ref_d15_w),
    .ref_d16_o          ( ref_d16_w         ),.ref_d17_o(ref_d17_w),.ref_d18_o(ref_d18_w),.ref_d19_o(ref_d19_w),.ref_d20_o(ref_d20_w),.ref_d21_o(ref_d21_w),.ref_d22_o(ref_d22_w),.ref_d23_o(ref_d23_w),
    .ref_d24_o          ( ref_d24_w         ),.ref_d25_o(ref_d25_w),.ref_d26_o(ref_d26_w),.ref_d27_o(ref_d27_w),.ref_d28_o(ref_d28_w),.ref_d29_o(ref_d29_w),.ref_d30_o(ref_d30_w),.ref_d31_o(ref_d31_w)
    );

  // prediction engine
  intra_pred u_intra_pred_a(
    // global
    .clk       ( clk             ),
    .rst_n     ( rstn            ),
    // ctrl_i
    .start_i   ( pre_start_w     ),
    .done_o    ( pre_val_o       ),
    // info_i
    .pre_sel_i ( loop_sel_w      ),
    .mode_i    ( loop_mode_w     ),
    .size_i    ( loop_size_w     ),
    // info_o
    .size_o    ( /* UNSED */     ),
    // position_i
    .i4x4_x_i  ( pre_4x4_x_w     ),
    .i4x4_y_i  ( pre_4x4_y_w     ),
    // position_o
    .i4x4_x_o  ( pre_4x4_x_o     ),
    .i4x4_y_o  ( pre_4x4_y_o     ),
    // reference_i
    .ref_tl_i  ( ref_tl_w        ),
    .ref_t00_i ( ref_t00_w       ), .ref_t01_i(ref_t01_w), .ref_t02_i(ref_t02_w), .ref_t03_i(ref_t03_w),
    .ref_t04_i ( ref_t04_w       ), .ref_t05_i(ref_t05_w), .ref_t06_i(ref_t06_w), .ref_t07_i(ref_t07_w),
    .ref_t08_i ( ref_t08_w       ), .ref_t09_i(ref_t09_w), .ref_t10_i(ref_t10_w), .ref_t11_i(ref_t11_w),
    .ref_t12_i ( ref_t12_w       ), .ref_t13_i(ref_t13_w), .ref_t14_i(ref_t14_w), .ref_t15_i(ref_t15_w),
    .ref_t16_i ( ref_t16_w       ), .ref_t17_i(ref_t17_w), .ref_t18_i(ref_t18_w), .ref_t19_i(ref_t19_w),
    .ref_t20_i ( ref_t20_w       ), .ref_t21_i(ref_t21_w), .ref_t22_i(ref_t22_w), .ref_t23_i(ref_t23_w),
    .ref_t24_i ( ref_t24_w       ), .ref_t25_i(ref_t25_w), .ref_t26_i(ref_t26_w), .ref_t27_i(ref_t27_w),
    .ref_t28_i ( ref_t28_w       ), .ref_t29_i(ref_t29_w), .ref_t30_i(ref_t30_w), .ref_t31_i(ref_t31_w),
    .ref_r00_i ( ref_r00_w       ), .ref_r01_i(ref_r01_w), .ref_r02_i(ref_r02_w), .ref_r03_i(ref_r03_w),
    .ref_r04_i ( ref_r04_w       ), .ref_r05_i(ref_r05_w), .ref_r06_i(ref_r06_w), .ref_r07_i(ref_r07_w),
    .ref_r08_i ( ref_r08_w       ), .ref_r09_i(ref_r09_w), .ref_r10_i(ref_r10_w), .ref_r11_i(ref_r11_w),
    .ref_r12_i ( ref_r12_w       ), .ref_r13_i(ref_r13_w), .ref_r14_i(ref_r14_w), .ref_r15_i(ref_r15_w),
    .ref_r16_i ( ref_r16_w       ), .ref_r17_i(ref_r17_w), .ref_r18_i(ref_r18_w), .ref_r19_i(ref_r19_w),
    .ref_r20_i ( ref_r20_w       ), .ref_r21_i(ref_r21_w), .ref_r22_i(ref_r22_w), .ref_r23_i(ref_r23_w),
    .ref_r24_i ( ref_r24_w       ), .ref_r25_i(ref_r25_w), .ref_r26_i(ref_r26_w), .ref_r27_i(ref_r27_w),
    .ref_r28_i ( ref_r28_w       ), .ref_r29_i(ref_r29_w), .ref_r30_i(ref_r30_w), .ref_r31_i(ref_r31_w),
    .ref_l00_i ( ref_l00_w       ), .ref_l01_i(ref_l01_w), .ref_l02_i(ref_l02_w), .ref_l03_i(ref_l03_w),
    .ref_l04_i ( ref_l04_w       ), .ref_l05_i(ref_l05_w), .ref_l06_i(ref_l06_w), .ref_l07_i(ref_l07_w),
    .ref_l08_i ( ref_l08_w       ), .ref_l09_i(ref_l09_w), .ref_l10_i(ref_l10_w), .ref_l11_i(ref_l11_w),
    .ref_l12_i ( ref_l12_w       ), .ref_l13_i(ref_l13_w), .ref_l14_i(ref_l14_w), .ref_l15_i(ref_l15_w),
    .ref_l16_i ( ref_l16_w       ), .ref_l17_i(ref_l17_w), .ref_l18_i(ref_l18_w), .ref_l19_i(ref_l19_w),
    .ref_l20_i ( ref_l20_w       ), .ref_l21_i(ref_l21_w), .ref_l22_i(ref_l22_w), .ref_l23_i(ref_l23_w),
    .ref_l24_i ( ref_l24_w       ), .ref_l25_i(ref_l25_w), .ref_l26_i(ref_l26_w), .ref_l27_i(ref_l27_w),
    .ref_l28_i ( ref_l28_w       ), .ref_l29_i(ref_l29_w), .ref_l30_i(ref_l30_w), .ref_l31_i(ref_l31_w),
    .ref_d00_i ( ref_d00_w       ), .ref_d01_i(ref_d01_w), .ref_d02_i(ref_d02_w), .ref_d03_i(ref_d03_w),
    .ref_d04_i ( ref_d04_w       ), .ref_d05_i(ref_d05_w), .ref_d06_i(ref_d06_w), .ref_d07_i(ref_d07_w),
    .ref_d08_i ( ref_d08_w       ), .ref_d09_i(ref_d09_w), .ref_d10_i(ref_d10_w), .ref_d11_i(ref_d11_w),
    .ref_d12_i ( ref_d12_w       ), .ref_d13_i(ref_d13_w), .ref_d14_i(ref_d14_w), .ref_d15_i(ref_d15_w),
    .ref_d16_i ( ref_d16_w       ), .ref_d17_i(ref_d17_w), .ref_d18_i(ref_d18_w), .ref_d19_i(ref_d19_w),
    .ref_d20_i ( ref_d20_w       ), .ref_d21_i(ref_d21_w), .ref_d22_i(ref_d22_w), .ref_d23_i(ref_d23_w),
    .ref_d24_i ( ref_d24_w       ), .ref_d25_i(ref_d25_w), .ref_d26_i(ref_d26_w), .ref_d27_i(ref_d27_w),
    .ref_d28_i ( ref_d28_w       ), .ref_d29_i(ref_d29_w), .ref_d30_i(ref_d30_w), .ref_d31_i(ref_d31_w),
    // prediction_o
    .pred_00_o ( pre_a00_w       ), .pred_01_o(pre_a01_w), .pred_02_o(pre_a02_w), .pred_03_o(pre_a03_w),
    .pred_10_o ( pre_a10_w       ), .pred_11_o(pre_a11_w), .pred_12_o(pre_a12_w), .pred_13_o(pre_a13_w),
    .pred_20_o ( pre_a20_w       ), .pred_21_o(pre_a21_w), .pred_22_o(pre_a22_w), .pred_23_o(pre_a23_w),
    .pred_30_o ( pre_a30_w       ), .pred_31_o(pre_a31_w), .pred_32_o(pre_a32_w), .pred_33_o(pre_a33_w)
    );

  // prediction engine
  intra_pred u_intra_pred_b(
    // global
    .clk       ( clk             ),
    .rst_n     ( rstn            ),
    // ctrl_i
    .start_i   ( pre_start_w     ),
    .done_o    ( /* UNSED */     ),
    // info_i
    .pre_sel_i ( loop_sel_w      ),
    .mode_i    ( loop_mode_w     ),
    .size_i    ( loop_size_w     ),
    // info_o
    .size_o    ( /* UNSED */     ),
    // position_i
    .i4x4_x_i  ( pre_4x4_x_w+4'b1),
    .i4x4_y_i  ( pre_4x4_y_w     ),
    // position_o
    .i4x4_x_o  ( /* UNSED */     ),
    .i4x4_y_o  ( /* UNSED */     ),
    // reference_i
    .ref_tl_i  ( ref_tl_w        ),
    .ref_t00_i ( ref_t00_w       ), .ref_t01_i(ref_t01_w), .ref_t02_i(ref_t02_w), .ref_t03_i(ref_t03_w),
    .ref_t04_i ( ref_t04_w       ), .ref_t05_i(ref_t05_w), .ref_t06_i(ref_t06_w), .ref_t07_i(ref_t07_w),
    .ref_t08_i ( ref_t08_w       ), .ref_t09_i(ref_t09_w), .ref_t10_i(ref_t10_w), .ref_t11_i(ref_t11_w),
    .ref_t12_i ( ref_t12_w       ), .ref_t13_i(ref_t13_w), .ref_t14_i(ref_t14_w), .ref_t15_i(ref_t15_w),
    .ref_t16_i ( ref_t16_w       ), .ref_t17_i(ref_t17_w), .ref_t18_i(ref_t18_w), .ref_t19_i(ref_t19_w),
    .ref_t20_i ( ref_t20_w       ), .ref_t21_i(ref_t21_w), .ref_t22_i(ref_t22_w), .ref_t23_i(ref_t23_w),
    .ref_t24_i ( ref_t24_w       ), .ref_t25_i(ref_t25_w), .ref_t26_i(ref_t26_w), .ref_t27_i(ref_t27_w),
    .ref_t28_i ( ref_t28_w       ), .ref_t29_i(ref_t29_w), .ref_t30_i(ref_t30_w), .ref_t31_i(ref_t31_w),
    .ref_r00_i ( ref_r00_w       ), .ref_r01_i(ref_r01_w), .ref_r02_i(ref_r02_w), .ref_r03_i(ref_r03_w),
    .ref_r04_i ( ref_r04_w       ), .ref_r05_i(ref_r05_w), .ref_r06_i(ref_r06_w), .ref_r07_i(ref_r07_w),
    .ref_r08_i ( ref_r08_w       ), .ref_r09_i(ref_r09_w), .ref_r10_i(ref_r10_w), .ref_r11_i(ref_r11_w),
    .ref_r12_i ( ref_r12_w       ), .ref_r13_i(ref_r13_w), .ref_r14_i(ref_r14_w), .ref_r15_i(ref_r15_w),
    .ref_r16_i ( ref_r16_w       ), .ref_r17_i(ref_r17_w), .ref_r18_i(ref_r18_w), .ref_r19_i(ref_r19_w),
    .ref_r20_i ( ref_r20_w       ), .ref_r21_i(ref_r21_w), .ref_r22_i(ref_r22_w), .ref_r23_i(ref_r23_w),
    .ref_r24_i ( ref_r24_w       ), .ref_r25_i(ref_r25_w), .ref_r26_i(ref_r26_w), .ref_r27_i(ref_r27_w),
    .ref_r28_i ( ref_r28_w       ), .ref_r29_i(ref_r29_w), .ref_r30_i(ref_r30_w), .ref_r31_i(ref_r31_w),
    .ref_l00_i ( ref_l00_w       ), .ref_l01_i(ref_l01_w), .ref_l02_i(ref_l02_w), .ref_l03_i(ref_l03_w),
    .ref_l04_i ( ref_l04_w       ), .ref_l05_i(ref_l05_w), .ref_l06_i(ref_l06_w), .ref_l07_i(ref_l07_w),
    .ref_l08_i ( ref_l08_w       ), .ref_l09_i(ref_l09_w), .ref_l10_i(ref_l10_w), .ref_l11_i(ref_l11_w),
    .ref_l12_i ( ref_l12_w       ), .ref_l13_i(ref_l13_w), .ref_l14_i(ref_l14_w), .ref_l15_i(ref_l15_w),
    .ref_l16_i ( ref_l16_w       ), .ref_l17_i(ref_l17_w), .ref_l18_i(ref_l18_w), .ref_l19_i(ref_l19_w),
    .ref_l20_i ( ref_l20_w       ), .ref_l21_i(ref_l21_w), .ref_l22_i(ref_l22_w), .ref_l23_i(ref_l23_w),
    .ref_l24_i ( ref_l24_w       ), .ref_l25_i(ref_l25_w), .ref_l26_i(ref_l26_w), .ref_l27_i(ref_l27_w),
    .ref_l28_i ( ref_l28_w       ), .ref_l29_i(ref_l29_w), .ref_l30_i(ref_l30_w), .ref_l31_i(ref_l31_w),
    .ref_d00_i ( ref_d00_w       ), .ref_d01_i(ref_d01_w), .ref_d02_i(ref_d02_w), .ref_d03_i(ref_d03_w),
    .ref_d04_i ( ref_d04_w       ), .ref_d05_i(ref_d05_w), .ref_d06_i(ref_d06_w), .ref_d07_i(ref_d07_w),
    .ref_d08_i ( ref_d08_w       ), .ref_d09_i(ref_d09_w), .ref_d10_i(ref_d10_w), .ref_d11_i(ref_d11_w),
    .ref_d12_i ( ref_d12_w       ), .ref_d13_i(ref_d13_w), .ref_d14_i(ref_d14_w), .ref_d15_i(ref_d15_w),
    .ref_d16_i ( ref_d16_w       ), .ref_d17_i(ref_d17_w), .ref_d18_i(ref_d18_w), .ref_d19_i(ref_d19_w),
    .ref_d20_i ( ref_d20_w       ), .ref_d21_i(ref_d21_w), .ref_d22_i(ref_d22_w), .ref_d23_i(ref_d23_w),
    .ref_d24_i ( ref_d24_w       ), .ref_d25_i(ref_d25_w), .ref_d26_i(ref_d26_w), .ref_d27_i(ref_d27_w),
    .ref_d28_i ( ref_d28_w       ), .ref_d29_i(ref_d29_w), .ref_d30_i(ref_d30_w), .ref_d31_i(ref_d31_w),
    // prediction_o
    .pred_00_o ( pre_b00_w       ), .pred_01_o(pre_b01_w), .pred_02_o(pre_b02_w), .pred_03_o(pre_b03_w),
    .pred_10_o ( pre_b10_w       ), .pred_11_o(pre_b11_w), .pred_12_o(pre_b12_w), .pred_13_o(pre_b13_w),
    .pred_20_o ( pre_b20_w       ), .pred_21_o(pre_b21_w), .pred_22_o(pre_b22_w), .pred_23_o(pre_b23_w),
    .pred_30_o ( pre_b30_w       ), .pred_31_o(pre_b31_w), .pred_32_o(pre_b32_w), .pred_33_o(pre_b33_w)
    );

  assign pre_dat_o = { pre_a00_w ,pre_a01_w ,pre_a02_w ,pre_a03_w ,pre_b00_w ,pre_b01_w ,pre_b02_w ,pre_b03_w
                      ,pre_a10_w ,pre_a11_w ,pre_a12_w ,pre_a13_w ,pre_b10_w ,pre_b11_w ,pre_b12_w ,pre_b13_w
                      ,pre_a20_w ,pre_a21_w ,pre_a22_w ,pre_a23_w ,pre_b20_w ,pre_b21_w ,pre_b22_w ,pre_b23_w
                      ,pre_a30_w ,pre_a31_w ,pre_a32_w ,pre_a33_w ,pre_b30_w ,pre_b31_w ,pre_b32_w ,pre_b33_w };


//--- MEMORY ---------------------------
  intra_buf_wrapper u_intra_buf_wrapper(
    // global
    .clk             ( clk             ),
    .rstn            ( rstn            ),
    // info_i
    .sel_i           ( rec_sel_i       ),
    // row sram wr if
    .wr_ena_row_i    ( wr_ena_row_w    ),
    .wr_adr_row_i    ( wr_adr_row_w    ),
    .wr_dat_row_i    ( wr_dat_row_w    ),
    // col sram wr if
    .wr_ena_col_i    ( wr_ena_col_w    ),
    .wr_adr_col_i    ( wr_adr_col_w    ),
    .wr_dat_col_i    ( wr_dat_col_w    ),
    // fra sram wr if
    .wr_ena_fra_i    ( wr_ena_fra_w    ),
    .wr_adr_fra_i    ( wr_adr_fra_w    ),
    .wr_dat_fra_i    ( wr_dat_fra_w    ),
    // row sram rd if
    .rd_ena_row_i    ( rd_ena_row_w    ),
    .rd_adr_row_i    ( rd_adr_row_w    ),
    .rd_dat_row_o    ( rd_dat_row_w    ),
    // col sram rd if
    .rd_ena_col_i    ( rd_ena_col_w    ),
    .rd_adr_col_i    ( rd_adr_col_w    ),
    .rd_dat_col_o    ( rd_dat_col_w    ),
    // fra sram rd if
    .rd_ena_fra_i    ( rd_ena_fra_w    ),
    .rd_adr_fra_i    ( rd_adr_fra_w    ),
    .rd_dat_fra_o    ( rd_dat_fra_w    )
    );

endmodule
