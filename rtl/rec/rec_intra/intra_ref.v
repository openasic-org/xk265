//-------------------------------------------------------------------
//
//  Filename      : intra_ref.v
//  Author        : Huang Leilei
//  Created       : 2017-12-08
//  Description   : reference control for intra prediction
//
//-------------------------------------------------------------------
//
//  Modified      : 2017-12-24 by HLL
//  Description   : chroma supported
//  Modified      : 2018-05-19 by HLL
//  Description   : non-lcu-aligned frame size supported
//  Modified      : 2018-05-21 by HLL
//  Description   : I block in P frame supported
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module intra_ref(
  // global
  clk                ,
  rstn               ,
  // ctrl_if
  start_i            ,
  pre_ready_o        ,
  done_o             ,
  // cfg_i
  type_i             ,
  sel_i              ,
  position_i         ,
  size_i             ,
  mode_i             ,
  // pos_i
  ctu_x_cur_i        ,
  ctu_y_cur_i        ,
  ctu_x_all_i        ,
  ctu_y_all_i        ,
  ctu_x_res_i        ,
  ctu_y_res_i        ,
  // tq_i
  rec_bgn_i          ,
  rec_sel_i          ,
  rec_pos_i          ,
  rec_siz_i          ,
  rec_val_i          ,
  rec_idx_i          ,
  rec_dat_i          ,
  // row sram wr if
  wr_ena_row_o       ,
  wr_adr_row_o       ,
  wr_dat_row_o       ,
  // col sram wr if
  wr_ena_col_o       ,
  wr_adr_col_o       ,
  wr_dat_col_o       ,
  // fra sram wr if
  wr_ena_fra_o       ,
  wr_adr_fra_o       ,
  wr_dat_fra_o       ,
  // row sram rd if
  rd_ena_row_o       ,
  rd_adr_row_o       ,
  rd_dat_row_i       ,
  // col sram rd if
  rd_ena_col_o       ,
  rd_adr_col_o       ,
  rd_dat_col_i       ,
  // fra sram rd if
  rd_ena_fra_o       ,
  rd_adr_fra_o       ,
  rd_dat_fra_i       ,
  // ref_tl_o
  ref_tl_o           ,
  // ref_t_o
  ref_t00_o          ,ref_t01_o,ref_t02_o,ref_t03_o,
  ref_t04_o          ,ref_t05_o,ref_t06_o,ref_t07_o,
  ref_t08_o          ,ref_t09_o,ref_t10_o,ref_t11_o,
  ref_t12_o          ,ref_t13_o,ref_t14_o,ref_t15_o,
  ref_t16_o          ,ref_t17_o,ref_t18_o,ref_t19_o,
  ref_t20_o          ,ref_t21_o,ref_t22_o,ref_t23_o,
  ref_t24_o          ,ref_t25_o,ref_t26_o,ref_t27_o,
  ref_t28_o          ,ref_t29_o,ref_t30_o,ref_t31_o,
  // ref_r_o
  ref_r00_o          ,ref_r01_o,ref_r02_o,ref_r03_o,
  ref_r04_o          ,ref_r05_o,ref_r06_o,ref_r07_o,
  ref_r08_o          ,ref_r09_o,ref_r10_o,ref_r11_o,
  ref_r12_o          ,ref_r13_o,ref_r14_o,ref_r15_o,
  ref_r16_o          ,ref_r17_o,ref_r18_o,ref_r19_o,
  ref_r20_o          ,ref_r21_o,ref_r22_o,ref_r23_o,
  ref_r24_o          ,ref_r25_o,ref_r26_o,ref_r27_o,
  ref_r28_o          ,ref_r29_o,ref_r30_o,ref_r31_o,
  // ref_l_o
  ref_l00_o          ,ref_l01_o,ref_l02_o,ref_l03_o,
  ref_l04_o          ,ref_l05_o,ref_l06_o,ref_l07_o,
  ref_l08_o          ,ref_l09_o,ref_l10_o,ref_l11_o,
  ref_l12_o          ,ref_l13_o,ref_l14_o,ref_l15_o,
  ref_l16_o          ,ref_l17_o,ref_l18_o,ref_l19_o,
  ref_l20_o          ,ref_l21_o,ref_l22_o,ref_l23_o,
  ref_l24_o          ,ref_l25_o,ref_l26_o,ref_l27_o,
  ref_l28_o          ,ref_l29_o,ref_l30_o,ref_l31_o,
  // ref_d_o
  ref_d00_o          ,ref_d01_o,ref_d02_o,ref_d03_o,
  ref_d04_o          ,ref_d05_o,ref_d06_o,ref_d07_o,
  ref_d08_o          ,ref_d09_o,ref_d10_o,ref_d11_o,
  ref_d12_o          ,ref_d13_o,ref_d14_o,ref_d15_o,
  ref_d16_o          ,ref_d17_o,ref_d18_o,ref_d19_o,
  ref_d20_o          ,ref_d21_o,ref_d22_o,ref_d23_o,
  ref_d24_o          ,ref_d25_o,ref_d26_o,ref_d27_o,
  ref_d28_o          ,ref_d29_o,ref_d30_o,ref_d31_o
  );


//*** PARAMETER ****************************************************************

  // local
  localparam FSM_WD                   = 3                      ;
  localparam   IDLE                   = 3'd0                   ;
  localparam   READ                   = 3'd1                   ;
  localparam   PADDING                = 3'd2                   ;
  localparam   FILTER                 = 3'd3                   ;
  localparam   WRITE                  = 3'd4                   ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                clk                     ;
  input                                rstn                    ;
  // ctrl_if
  input                                start_i                 ;
  output reg                           pre_ready_o             ;
  output reg                           done_o                  ;
  // cfg_i
  input                                type_i                  ;
  input      [2              -1 :0]    sel_i                   ;
  input      [8              -1 :0]    position_i              ;
  input      [2              -1 :0]    size_i                  ;
  input      [6              -1 :0]    mode_i                  ;
  // pos_i
  input      [`PIC_X_WIDTH   -1 :0]    ctu_x_all_i             ;
  input      [`PIC_Y_WIDTH   -1 :0]    ctu_y_all_i             ;
  input      [4              -1 :0]    ctu_x_res_i             ;
  input      [4              -1 :0]    ctu_y_res_i             ;
  input      [`PIC_X_WIDTH   -1 :0]    ctu_x_cur_i             ;
  input      [`PIC_Y_WIDTH   -1 :0]    ctu_y_cur_i             ;
  // tq if
  input                                rec_bgn_i               ;
  input      [2              -1 :0]    rec_sel_i               ;
  input      [8              -1 :0]    rec_pos_i               ;
  input      [2              -1 :0]    rec_siz_i               ;
  input                                rec_val_i               ;
  input      [5              -1 :0]    rec_idx_i               ;
  input      [`PIXEL_WIDTH*32-1 :0]    rec_dat_i               ;
  // row sram wr if
  output                               wr_ena_row_o            ;
  output reg [4+4            -1 :0]    wr_adr_row_o            ;
  output reg [`PIXEL_WIDTH*4 -1 :0]    wr_dat_row_o            ;
  // col sram wr if
  output                               wr_ena_col_o            ;
  output reg [4+4            -1 :0]    wr_adr_col_o            ;
  output reg [`PIXEL_WIDTH*4 -1 :0]    wr_dat_col_o            ;
  // fra sram wr if
  output                               wr_ena_fra_o            ;
  output reg [`PIC_X_WIDTH+4 -1 :0]    wr_adr_fra_o            ;
  output     [`PIXEL_WIDTH*4 -1 :0]    wr_dat_fra_o            ;
  // row sram rd if
  output reg                           rd_ena_row_o            ;
  output reg [4+4            -1 :0]    rd_adr_row_o            ;
  input      [`PIXEL_WIDTH*4 -1 :0]    rd_dat_row_i            ;
  // col sram rd if
  output reg                           rd_ena_col_o            ;
  output reg [4+4            -1 :0]    rd_adr_col_o            ;
  input      [`PIXEL_WIDTH*4 -1 :0]    rd_dat_col_i            ;
  // fra sram rd if
  output reg                           rd_ena_fra_o            ;
  output reg [`PIC_X_WIDTH+4 -1 :0]    rd_adr_fra_o            ;
  input      [`PIXEL_WIDTH*4 -1 :0]    rd_dat_fra_i            ;
  // ref_tl_o
  output reg [`PIXEL_WIDTH   -1 :0]    ref_tl_o                ;
  // ref_t_o
  output reg [`PIXEL_WIDTH   -1 :0]    ref_t00_o               ,ref_t01_o,ref_t02_o,ref_t03_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_t04_o               ,ref_t05_o,ref_t06_o,ref_t07_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_t08_o               ,ref_t09_o,ref_t10_o,ref_t11_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_t12_o               ,ref_t13_o,ref_t14_o,ref_t15_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_t16_o               ,ref_t17_o,ref_t18_o,ref_t19_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_t20_o               ,ref_t21_o,ref_t22_o,ref_t23_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_t24_o               ,ref_t25_o,ref_t26_o,ref_t27_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_t28_o               ,ref_t29_o,ref_t30_o,ref_t31_o;
  // ref_r_o
  output reg [`PIXEL_WIDTH   -1 :0]    ref_r00_o               ,ref_r01_o,ref_r02_o,ref_r03_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_r04_o               ,ref_r05_o,ref_r06_o,ref_r07_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_r08_o               ,ref_r09_o,ref_r10_o,ref_r11_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_r12_o               ,ref_r13_o,ref_r14_o,ref_r15_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_r16_o               ,ref_r17_o,ref_r18_o,ref_r19_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_r20_o               ,ref_r21_o,ref_r22_o,ref_r23_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_r24_o               ,ref_r25_o,ref_r26_o,ref_r27_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_r28_o               ,ref_r29_o,ref_r30_o,ref_r31_o;
  // ref_l_o
  output reg [`PIXEL_WIDTH   -1 :0]    ref_l00_o               ,ref_l01_o,ref_l02_o,ref_l03_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_l04_o               ,ref_l05_o,ref_l06_o,ref_l07_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_l08_o               ,ref_l09_o,ref_l10_o,ref_l11_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_l12_o               ,ref_l13_o,ref_l14_o,ref_l15_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_l16_o               ,ref_l17_o,ref_l18_o,ref_l19_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_l20_o               ,ref_l21_o,ref_l22_o,ref_l23_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_l24_o               ,ref_l25_o,ref_l26_o,ref_l27_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_l28_o               ,ref_l29_o,ref_l30_o,ref_l31_o;
  // ref_d_o
  output reg [`PIXEL_WIDTH   -1 :0]    ref_d00_o               ,ref_d01_o,ref_d02_o,ref_d03_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_d04_o               ,ref_d05_o,ref_d06_o,ref_d07_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_d08_o               ,ref_d09_o,ref_d10_o,ref_d11_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_d12_o               ,ref_d13_o,ref_d14_o,ref_d15_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_d16_o               ,ref_d17_o,ref_d18_o,ref_d19_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_d20_o               ,ref_d21_o,ref_d22_o,ref_d23_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_d24_o               ,ref_d25_o,ref_d26_o,ref_d27_o;
  output reg [`PIXEL_WIDTH   -1 :0]    ref_d28_o               ,ref_d29_o,ref_d30_o,ref_d31_o;


//*** REG/WIRE *****************************************************************

  // global
  wire       [4              -1 :0]    pu_4x4_x_w              ;
  wire       [4              -1 :0]    pu_4x4_y_w              ;
  wire       [4              -1 :0]    pu_4x4_m_w              ;

  wire       [3              -1 :0]    offset_w                ;    // 4 ; 3

  reg        [2              -1 :0]    size_of_luma_w          ;
  wire       [8              -1 :0]    position_of_luma_w      ;

  wire       [4              -1 :0]    pu_4x4_x_of_luma_w      ;
  wire       [4              -1 :0]    pu_4x4_y_of_luma_w      ;

  wire       [`PIXEL_WIDTH   -1 :0]    rd_dat_fra_3_w          ;
  wire       [`PIXEL_WIDTH   -1 :0]    rd_dat_fra_2_w          ;
  wire       [`PIXEL_WIDTH   -1 :0]    rd_dat_fra_1_w          ;
  wire       [`PIXEL_WIDTH   -1 :0]    rd_dat_fra_0_w          ;

  wire       [`PIXEL_WIDTH   -1 :0]    rd_dat_row_3_w          ;
  wire       [`PIXEL_WIDTH   -1 :0]    rd_dat_row_2_w          ;
  wire       [`PIXEL_WIDTH   -1 :0]    rd_dat_row_1_w          ;
  wire       [`PIXEL_WIDTH   -1 :0]    rd_dat_row_0_w          ;

  wire       [`PIXEL_WIDTH   -1 :0]    rd_dat_col_3_w          ;
  wire       [`PIXEL_WIDTH   -1 :0]    rd_dat_col_2_w          ;
  wire       [`PIXEL_WIDTH   -1 :0]    rd_dat_col_1_w          ;
  wire       [`PIXEL_WIDTH   -1 :0]    rd_dat_col_0_w          ;

  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_31_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_30_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_29_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_28_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_27_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_26_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_25_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_24_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_23_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_22_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_21_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_20_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_19_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_18_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_17_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_16_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_15_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_14_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_13_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_12_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_11_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_10_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_09_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_08_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_07_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_06_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_05_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_04_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_03_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_02_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_01_w            ;
  wire       [`PIXEL_WIDTH   -1 :0]    rec_dat_00_w            ;

  // fsm
  reg        [FSM_WD         -1 :0]    cur_state_r             ;
  reg        [FSM_WD         -1 :0]    nxt_state_w             ;

  // read
  reg                                  rd_done_r               ;
  reg                                  rd_done_d0_r            ;
  reg                                  rd_done_d1_r            ;

  reg        [5              -1 :0]    rd_cnt_r                ;

  reg                                  frame_flag_r            ;

  // reg
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_00_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_01_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_02_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_03_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_04_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_05_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_06_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_07_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_08_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_09_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_10_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_11_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_12_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_13_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_t_14_r              ;

  reg        [4+4            -1 :0]    rd_adr_row_r            ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_00_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_01_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_02_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_03_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_04_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_05_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_06_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_07_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_08_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_09_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_10_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_11_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_12_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_13_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_l_14_r              ;

  reg        [4+4            -1 :0]    rd_adr_col_r            ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_tl_y_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_tl_u_r              ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_tl_v_r              ;

  reg                                  rd_ena_fra_r            ;

  // pad
  reg        [8              -1 :0]    pu_order_of_luma_w      ;
  wire       [4              -1 :0]    pu_order_x_of_luma_w    ;
  wire       [4              -1 :0]    pu_order_y_of_luma_w    ;
  wire       [4              -1 :0]    pu_order_tl_x_of_luma_w ;
  wire       [4              -1 :0]    pu_order_tl_y_of_luma_w ;
  wire       [4              -1 :0]    pu_order_tp_x_of_luma_w ;
  wire       [4              -1 :0]    pu_order_tp_y_of_luma_w ;
  wire       [4              -1 :0]    pu_order_rt_x_of_luma_w ;
  wire       [4              -1 :0]    pu_order_rt_y_of_luma_w ;
  wire       [4              -1 :0]    pu_order_lf_x_of_luma_w ;
  wire       [4              -1 :0]    pu_order_lf_y_of_luma_w ;
  wire       [4              -1 :0]    pu_order_dn_x_of_luma_w ;
  wire       [4              -1 :0]    pu_order_dn_y_of_luma_w ;
  wire       [8              -1 :0]    pu_order_tp_of_luma_w   ;
  wire       [8              -1 :0]    pu_order_lf_of_luma_w   ;
  wire       [8              -1 :0]    pu_order_tl_of_luma_w   ;
  wire       [8              -1 :0]    pu_order_rt_of_luma_w   ;
  wire       [8              -1 :0]    pu_order_dn_of_luma_w   ;

  reg        [4              -1 :0]    pu_delta_w              ;

  reg                                  pu_tl_exist_r           ;
  reg                                  pu_tp_exist_r           ;
  reg        [8              -1 :0]    pu_rt_exist_r           ;
  reg                                  pu_lf_exist_r           ;
  reg        [8              -1 :0]    pu_dn_exist_r           ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_tl_w            ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t00_w           ,ref_pad_t01_w ,ref_pad_t02_w ,ref_pad_t03_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t04_w           ,ref_pad_t05_w ,ref_pad_t06_w ,ref_pad_t07_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t08_w           ,ref_pad_t09_w ,ref_pad_t10_w ,ref_pad_t11_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t12_w           ,ref_pad_t13_w ,ref_pad_t14_w ,ref_pad_t15_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t16_w           ,ref_pad_t17_w ,ref_pad_t18_w ,ref_pad_t19_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t20_w           ,ref_pad_t21_w ,ref_pad_t22_w ,ref_pad_t23_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t24_w           ,ref_pad_t25_w ,ref_pad_t26_w ,ref_pad_t27_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t28_w           ,ref_pad_t29_w ,ref_pad_t30_w ,ref_pad_t31_w ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r00_w           ,ref_pad_r01_w ,ref_pad_r02_w ,ref_pad_r03_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r04_w           ,ref_pad_r05_w ,ref_pad_r06_w ,ref_pad_r07_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r08_w           ,ref_pad_r09_w ,ref_pad_r10_w ,ref_pad_r11_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r12_w           ,ref_pad_r13_w ,ref_pad_r14_w ,ref_pad_r15_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r16_w           ,ref_pad_r17_w ,ref_pad_r18_w ,ref_pad_r19_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r20_w           ,ref_pad_r21_w ,ref_pad_r22_w ,ref_pad_r23_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r24_w           ,ref_pad_r25_w ,ref_pad_r26_w ,ref_pad_r27_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r28_w           ,ref_pad_r29_w ,ref_pad_r30_w ,ref_pad_r31_w ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l00_w           ,ref_pad_l01_w ,ref_pad_l02_w ,ref_pad_l03_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l04_w           ,ref_pad_l05_w ,ref_pad_l06_w ,ref_pad_l07_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l08_w           ,ref_pad_l09_w ,ref_pad_l10_w ,ref_pad_l11_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l12_w           ,ref_pad_l13_w ,ref_pad_l14_w ,ref_pad_l15_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l16_w           ,ref_pad_l17_w ,ref_pad_l18_w ,ref_pad_l19_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l20_w           ,ref_pad_l21_w ,ref_pad_l22_w ,ref_pad_l23_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l24_w           ,ref_pad_l25_w ,ref_pad_l26_w ,ref_pad_l27_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l28_w           ,ref_pad_l29_w ,ref_pad_l30_w ,ref_pad_l31_w ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d00_w           ,ref_pad_d01_w ,ref_pad_d02_w ,ref_pad_d03_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d04_w           ,ref_pad_d05_w ,ref_pad_d06_w ,ref_pad_d07_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d08_w           ,ref_pad_d09_w ,ref_pad_d10_w ,ref_pad_d11_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d12_w           ,ref_pad_d13_w ,ref_pad_d14_w ,ref_pad_d15_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d16_w           ,ref_pad_d17_w ,ref_pad_d18_w ,ref_pad_d19_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d20_w           ,ref_pad_d21_w ,ref_pad_d22_w ,ref_pad_d23_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d24_w           ,ref_pad_d25_w ,ref_pad_d26_w ,ref_pad_d27_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d28_w           ,ref_pad_d29_w ,ref_pad_d30_w ,ref_pad_d31_w ;

  // filter_flag
  reg                                  filter_flag_r           ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_tl_w            ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t00_w           ,ref_flt_t01_w ,ref_flt_t02_w ,ref_flt_t03_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t04_w           ,ref_flt_t05_w ,ref_flt_t06_w ,ref_flt_t07_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t08_w           ,ref_flt_t09_w ,ref_flt_t10_w ,ref_flt_t11_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t12_w           ,ref_flt_t13_w ,ref_flt_t14_w ,ref_flt_t15_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t16_w           ,ref_flt_t17_w ,ref_flt_t18_w ,ref_flt_t19_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t20_w           ,ref_flt_t21_w ,ref_flt_t22_w ,ref_flt_t23_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t24_w           ,ref_flt_t25_w ,ref_flt_t26_w ,ref_flt_t27_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t28_w           ,ref_flt_t29_w ,ref_flt_t30_w ,ref_flt_t31_w ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r00_w           ,ref_flt_r01_w ,ref_flt_r02_w ,ref_flt_r03_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r04_w           ,ref_flt_r05_w ,ref_flt_r06_w ,ref_flt_r07_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r08_w           ,ref_flt_r09_w ,ref_flt_r10_w ,ref_flt_r11_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r12_w           ,ref_flt_r13_w ,ref_flt_r14_w ,ref_flt_r15_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r16_w           ,ref_flt_r17_w ,ref_flt_r18_w ,ref_flt_r19_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r20_w           ,ref_flt_r21_w ,ref_flt_r22_w ,ref_flt_r23_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r24_w           ,ref_flt_r25_w ,ref_flt_r26_w ,ref_flt_r27_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r28_w           ,ref_flt_r29_w ,ref_flt_r30_w ,ref_flt_r31_w ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l00_w           ,ref_flt_l01_w ,ref_flt_l02_w ,ref_flt_l03_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l04_w           ,ref_flt_l05_w ,ref_flt_l06_w ,ref_flt_l07_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l08_w           ,ref_flt_l09_w ,ref_flt_l10_w ,ref_flt_l11_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l12_w           ,ref_flt_l13_w ,ref_flt_l14_w ,ref_flt_l15_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l16_w           ,ref_flt_l17_w ,ref_flt_l18_w ,ref_flt_l19_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l20_w           ,ref_flt_l21_w ,ref_flt_l22_w ,ref_flt_l23_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l24_w           ,ref_flt_l25_w ,ref_flt_l26_w ,ref_flt_l27_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l28_w           ,ref_flt_l29_w ,ref_flt_l30_w ,ref_flt_l31_w ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d00_w           ,ref_flt_d01_w ,ref_flt_d02_w ,ref_flt_d03_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d04_w           ,ref_flt_d05_w ,ref_flt_d06_w ,ref_flt_d07_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d08_w           ,ref_flt_d09_w ,ref_flt_d10_w ,ref_flt_d11_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d12_w           ,ref_flt_d13_w ,ref_flt_d14_w ,ref_flt_d15_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d16_w           ,ref_flt_d17_w ,ref_flt_d18_w ,ref_flt_d19_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d20_w           ,ref_flt_d21_w ,ref_flt_d22_w ,ref_flt_d23_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d24_w           ,ref_flt_d25_w ,ref_flt_d26_w ,ref_flt_d27_w ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d28_w           ,ref_flt_d29_w ,ref_flt_d30_w ,ref_flt_d31_w ;

  // write
  wire       [4              -1 :0]    rec_4x4_x_w             ;
  wire       [4              -1 :0]    rec_4x4_y_w             ;
  wire       [3              -1 :0]    rec_offset_w            ;

  reg                                  wr_ena_r                ;

  reg        [3              -1 :0]    wr_cnt_r                ;

  reg                                  wr_done_w               ;
  reg                                  wr_done_r               ;

  reg                                  wr_frame_flag           ;


//*** MAIN BODY ****************************************************************

//--- GLOBAL ---------------------------
  assign pu_4x4_x_w = {position_i[6],position_i[4],position_i[2],position_i[0]} ;
  assign pu_4x4_y_w = {position_i[7],position_i[5],position_i[3],position_i[1]} ;
  assign pu_4x4_m_w = (sel_i==`TYPE_Y) ? 16 : 8 ;
  assign offset_w   = (sel_i==`TYPE_Y) ?  4 : 3 ;

  always @(*) begin
                   size_of_luma_w = size_i ;
    if( sel_i!=`TYPE_Y ) begin
      case( size_i )
        `SIZE_04 : size_of_luma_w = `SIZE_08 ;
        `SIZE_08 : size_of_luma_w = `SIZE_16 ;
        `SIZE_16 : size_of_luma_w = `SIZE_32 ;
      endcase
    end
  end
  assign position_of_luma_w = (sel_i==`TYPE_Y) ? position_i : (position_i<<2) ;
  assign pu_4x4_x_of_luma_w = {position_of_luma_w[6],position_of_luma_w[4],position_of_luma_w[2],position_of_luma_w[0]} ;
  assign pu_4x4_y_of_luma_w = {position_of_luma_w[7],position_of_luma_w[5],position_of_luma_w[3],position_of_luma_w[1]} ;

  assign { rd_dat_fra_3_w ,rd_dat_fra_2_w ,rd_dat_fra_1_w ,rd_dat_fra_0_w } = rd_dat_fra_i ;
  assign { rd_dat_row_3_w ,rd_dat_row_2_w ,rd_dat_row_1_w ,rd_dat_row_0_w } = rd_dat_row_i ;
  assign { rd_dat_col_3_w ,rd_dat_col_2_w ,rd_dat_col_1_w ,rd_dat_col_0_w } = rd_dat_col_i ;

  assign { rec_dat_31_w
          ,rec_dat_30_w
          ,rec_dat_29_w
          ,rec_dat_28_w
          ,rec_dat_27_w
          ,rec_dat_26_w
          ,rec_dat_25_w
          ,rec_dat_24_w
          ,rec_dat_23_w
          ,rec_dat_22_w
          ,rec_dat_21_w
          ,rec_dat_20_w
          ,rec_dat_19_w
          ,rec_dat_18_w
          ,rec_dat_17_w
          ,rec_dat_16_w
          ,rec_dat_15_w
          ,rec_dat_14_w
          ,rec_dat_13_w
          ,rec_dat_12_w
          ,rec_dat_11_w
          ,rec_dat_10_w
          ,rec_dat_09_w
          ,rec_dat_08_w
          ,rec_dat_07_w
          ,rec_dat_06_w
          ,rec_dat_05_w
          ,rec_dat_04_w
          ,rec_dat_03_w
          ,rec_dat_02_w
          ,rec_dat_01_w
          ,rec_dat_00_w } = rec_dat_i ;


//--- FSM ------------------------------
  // cur_state
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_state_r <= IDLE ;
    end
    else begin
      cur_state_r <= nxt_state_w ;
    end
  end

  // nxt_state
  always @(*) begin
                                                   nxt_state_w = IDLE    ;
    if( type_i==`INTRA ) begin
      case( cur_state_r )
        IDLE    : begin    if( start_i )           nxt_state_w = READ    ;
                           else                    nxt_state_w = IDLE    ;
        end
        READ    : begin    if( rd_done_d1_r )      nxt_state_w = PADDING ;
                           else                    nxt_state_w = READ    ;
        end
        PADDING : begin                            nxt_state_w = FILTER  ;
        end
        FILTER  : begin                            nxt_state_w = WRITE   ;
        end
        WRITE   : begin    if( start_i )           nxt_state_w = READ    ;
                           else if( wr_done_r )    nxt_state_w = IDLE    ;
                           else                    nxt_state_w = WRITE   ;
        end
      endcase
    end
    else begin
                                                   nxt_state_w = WRITE   ;
    end
  end


//--- READ -----------------------------
  // read done flag
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_done_r <= 0 ;
    end
    else begin
      case( size_i )
        `SIZE_04 :    if( rd_cnt_r==01 )    rd_done_r <= 1 ;
                      else                  rd_done_r <= 0 ;
        `SIZE_08 :    if( rd_cnt_r==03 )    rd_done_r <= 1 ;
                      else                  rd_done_r <= 0 ;
        `SIZE_16 :    if( rd_cnt_r==07 )    rd_done_r <= 1 ;
                      else                  rd_done_r <= 0 ;
        `SIZE_32 :    if( rd_cnt_r==15 )    rd_done_r <= 1 ;
                      else                  rd_done_r <= 0 ;
      endcase
    end
  end

  // delay
  always @(posedge clk or negedge rstn ) begin
    if(!rstn) begin
      rd_done_d0_r <= 0 ;
      rd_done_d1_r <= 0 ;
    end
    else begin
      rd_done_d0_r <= rd_done_r    ;
      rd_done_d1_r <= rd_done_d0_r ;
    end
  end

  // counter for read
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_cnt_r <= 0 ;
    end
    else begin
      if( cur_state_r==READ ) begin
        if( rd_done_d1_r ) begin
          rd_cnt_r <= 0 ;
        end
        else begin
          rd_cnt_r <= rd_cnt_r + 1 ;
        end
      end
    end
  end

  // flag for frame read
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      frame_flag_r <= 0 ;
    end
    else begin
      if( start_i ) begin
        if( (ctu_y_cur_i>0) && (pu_4x4_y_w==0) ) begin
          frame_flag_r <= 1 ;
        end
        else begin
          frame_flag_r <= 0 ;
        end
      end
    end
  end

  // read enable
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_ena_fra_o <= 0 ;
      rd_ena_row_o <= 0 ;
      rd_ena_col_o <= 0 ;
    end
    else begin
      case( cur_state_r )
        IDLE    : begin    if( start_i ) begin
                             rd_ena_fra_o <= 1 ;
                             rd_ena_row_o <= 1 ;
                             rd_ena_col_o <= 1 ;
                           end
        end
        READ    : begin    rd_ena_fra_o <= 1 ;
                           rd_ena_row_o <= 1 ;
                           rd_ena_col_o <= 1 ;
        end
        WRITE   : begin    if( rec_bgn_i && (rec_4x4_x_w==0) && (rec_4x4_y_w==0) ) begin
                             rd_ena_fra_o <= 1 ;
                           end
                           else begin
                             rd_ena_fra_o <= 0 ;
                           end
        end
        default : begin    rd_ena_fra_o <= 0 ;
                           rd_ena_row_o <= 0 ;
                           rd_ena_col_o <= 0 ;
        end
      endcase
    end
  end

  // read address
  always @(posedge clk or negedge rstn ) begin
    if(!rstn) begin
      rd_adr_fra_o <= 0 ;
      rd_adr_row_o <= 0 ;
      rd_adr_col_o <= 0 ;
    end
    else begin
      case( cur_state_r )
        IDLE ,
        WRITE: begin    if( start_i ) begin
                          // frame
                            rd_adr_fra_o <= ( ctu_x_cur_i  <<offset_w)+pu_4x4_x_w-1 ;
                          // row & column
                          if( (pu_4x4_x_w==0) && (pu_4x4_y_w==0) ) begin
                            rd_adr_row_o <= ((pu_4x4_m_w-1)<<offset_w)+pu_4x4_m_w-1 ;
                            rd_adr_col_o <= ((pu_4x4_m_w-1)<<offset_w)+pu_4x4_m_w-1 ;
                          end
                          else if( pu_4x4_x_w==0 ) begin
                            rd_adr_row_o <= ((pu_4x4_y_w-1)<<offset_w)+pu_4x4_m_w-1 ;
                            rd_adr_col_o <= ((pu_4x4_m_w-1)<<offset_w)+pu_4x4_y_w-1 ;
                          end
                          else if( pu_4x4_y_w==0 ) begin
                            rd_adr_row_o <= ((pu_4x4_m_w-1)<<offset_w)+pu_4x4_x_w-1 ;
                            rd_adr_col_o <= ((pu_4x4_x_w-1)<<offset_w)+pu_4x4_m_w-1 ;
                          end
                          else begin
                            rd_adr_row_o <= ((pu_4x4_y_w-1)<<offset_w)+pu_4x4_x_w-1 ;
                            rd_adr_col_o <= ((pu_4x4_x_w-1)<<offset_w)+pu_4x4_y_w-1 ;
                          end
                        end
                        else if( rec_bgn_i ) begin
                          if( (rec_4x4_x_w==0) && (rec_4x4_y_w==0) ) begin
                            rd_adr_fra_o <= ((ctu_x_cur_i+1)<<rec_offset_w)-1 ;
                          end
                        end
        end
        READ : begin    // frame
                        rd_adr_fra_o <= rd_adr_fra_o + 1 ;
                        // row
                        if( rd_cnt_r==0 ) begin
                          if( pu_4x4_y_w==0 ) begin
                            rd_adr_row_o <= ((pu_4x4_m_w-1)<<offset_w)+pu_4x4_x_w ;
                          end
                          else begin
                            rd_adr_row_o <= ((pu_4x4_y_w-1)<<offset_w)+pu_4x4_x_w ;
                          end
                        end
                        else begin
                          rd_adr_row_o <= rd_adr_row_o + 1 ;
                        end
                        // column
                        if( rd_cnt_r==0 ) begin
                          if( pu_4x4_x_w==0 ) begin
                            rd_adr_col_o <= ((pu_4x4_m_w-1)<<offset_w)+pu_4x4_y_w ;
                          end
                          else begin
                            rd_adr_col_o <= ((pu_4x4_x_w-1)<<offset_w)+pu_4x4_y_w ;
                          end
                        end
                        else begin
                          rd_adr_col_o <= rd_adr_col_o + 1 ;
                        end
        end
      endcase
    end
  end

  // store rd_dat_fra_0_w
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_t_00_r <= 0 ;
      ref_t_01_r <= 0 ;
      ref_t_02_r <= 0 ;
      ref_t_03_r <= 0 ;
      ref_t_04_r <= 0 ;
      ref_t_05_r <= 0 ;
      ref_t_06_r <= 0 ;
      ref_t_07_r <= 0 ;
      ref_t_08_r <= 0 ;
      ref_t_09_r <= 0 ;
      ref_t_10_r <= 0 ;
      ref_t_11_r <= 0 ;
      ref_t_12_r <= 0 ;
      ref_t_13_r <= 0 ;
      ref_t_14_r <= 0 ;
    end
    else begin
      if( rd_cnt_r>=2 ) begin
        if( sel_i==`TYPE_Y ) begin
          case( rd_adr_row_r )
            240 : ref_t_00_r <= rd_dat_fra_0_w ;
            241 : ref_t_01_r <= rd_dat_fra_0_w ;
            242 : ref_t_02_r <= rd_dat_fra_0_w ;
            243 : ref_t_03_r <= rd_dat_fra_0_w ;
            244 : ref_t_04_r <= rd_dat_fra_0_w ;
            245 : ref_t_05_r <= rd_dat_fra_0_w ;
            246 : ref_t_06_r <= rd_dat_fra_0_w ;
            247 : ref_t_07_r <= rd_dat_fra_0_w ;
            248 : ref_t_08_r <= rd_dat_fra_0_w ;
            249 : ref_t_09_r <= rd_dat_fra_0_w ;
            250 : ref_t_10_r <= rd_dat_fra_0_w ;
            251 : ref_t_11_r <= rd_dat_fra_0_w ;
            252 : ref_t_12_r <= rd_dat_fra_0_w ;
            253 : ref_t_13_r <= rd_dat_fra_0_w ;
            254 : ref_t_14_r <= rd_dat_fra_0_w ;
          endcase
        end
        else begin
          case( rd_adr_row_r )
            56 : ref_t_00_r <= rd_dat_fra_0_w ;
            57 : ref_t_01_r <= rd_dat_fra_0_w ;
            58 : ref_t_02_r <= rd_dat_fra_0_w ;
            59 : ref_t_03_r <= rd_dat_fra_0_w ;
            60 : ref_t_04_r <= rd_dat_fra_0_w ;
            61 : ref_t_05_r <= rd_dat_fra_0_w ;
            62 : ref_t_06_r <= rd_dat_fra_0_w ;
            63 : ref_t_07_r <= rd_dat_fra_0_w ;
          endcase
        end
      end
    end
  end

  // store rd_adr_row_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_adr_row_r <= 0 ;
    end
    else begin
      rd_adr_row_r <= rd_adr_row_o ;
    end
  end

  // store rd_dat_col_0_w
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_l_00_r <= 0 ;
      ref_l_01_r <= 0 ;
      ref_l_02_r <= 0 ;
      ref_l_03_r <= 0 ;
      ref_l_04_r <= 0 ;
      ref_l_05_r <= 0 ;
      ref_l_06_r <= 0 ;
      ref_l_07_r <= 0 ;
      ref_l_08_r <= 0 ;
      ref_l_09_r <= 0 ;
      ref_l_10_r <= 0 ;
      ref_l_11_r <= 0 ;
      ref_l_12_r <= 0 ;
      ref_l_13_r <= 0 ;
      ref_l_14_r <= 0 ;
    end
    else begin
      if( rd_cnt_r>=2 ) begin
        if( sel_i==`TYPE_Y ) begin
          case( rd_adr_col_r )
            240 : ref_l_00_r <= rd_dat_col_0_w ;
            241 : ref_l_01_r <= rd_dat_col_0_w ;
            242 : ref_l_02_r <= rd_dat_col_0_w ;
            243 : ref_l_03_r <= rd_dat_col_0_w ;
            244 : ref_l_04_r <= rd_dat_col_0_w ;
            245 : ref_l_05_r <= rd_dat_col_0_w ;
            246 : ref_l_06_r <= rd_dat_col_0_w ;
            247 : ref_l_07_r <= rd_dat_col_0_w ;
            248 : ref_l_08_r <= rd_dat_col_0_w ;
            249 : ref_l_09_r <= rd_dat_col_0_w ;
            250 : ref_l_10_r <= rd_dat_col_0_w ;
            251 : ref_l_11_r <= rd_dat_col_0_w ;
            252 : ref_l_12_r <= rd_dat_col_0_w ;
            253 : ref_l_13_r <= rd_dat_col_0_w ;
            254 : ref_l_14_r <= rd_dat_col_0_w ;
          endcase
        end
        else begin
          case( rd_adr_col_r )
            56 : ref_l_00_r <= rd_dat_col_0_w ;
            57 : ref_l_01_r <= rd_dat_col_0_w ;
            58 : ref_l_02_r <= rd_dat_col_0_w ;
            59 : ref_l_03_r <= rd_dat_col_0_w ;
            60 : ref_l_04_r <= rd_dat_col_0_w ;
            61 : ref_l_05_r <= rd_dat_col_0_w ;
            62 : ref_l_06_r <= rd_dat_col_0_w ;
          endcase
        end
      end
    end
  end

  // store rd_adr_col_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_adr_col_r <= 0 ;
    end
    else begin
      rd_adr_col_r <= rd_adr_col_o ;
    end
  end

  // store rd_dat_fra_0_w
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_tl_y_r <= 0 ;
      ref_tl_u_r <= 0 ;
      ref_tl_v_r <= 0 ;
    end
    else begin
      if( cur_state_r==WRITE ) begin
        if( rd_ena_fra_r ) begin
          case( rec_sel_i )
            `TYPE_Y : ref_tl_y_r <= rd_dat_fra_0_w ;
            `TYPE_U : ref_tl_u_r <= rd_dat_fra_0_w ;
            `TYPE_V : ref_tl_v_r <= rd_dat_fra_0_w ;
          endcase
        end
      end
    end
  end

  // store rd_ena_fra_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_ena_fra_r <= 0 ;
    end
    else begin
      rd_ena_fra_r <= rd_ena_fra_o ;
    end
  end


//--- PRE PADDING ----------------------
  // pu order
  always @(*) begin
                 pu_order_of_luma_w =  position_of_luma_w     ;
    case( size_of_luma_w )
      `SIZE_04 : pu_order_of_luma_w =  position_of_luma_w     ;
      `SIZE_08 : pu_order_of_luma_w = (position_of_luma_w>>2) ;
      `SIZE_16 : pu_order_of_luma_w = (position_of_luma_w>>4) ;
      `SIZE_32 : pu_order_of_luma_w = (position_of_luma_w>>6) ;
    endcase
  end

  assign pu_order_x_of_luma_w = { pu_order_of_luma_w[6]
                                 ,pu_order_of_luma_w[4]
                                 ,pu_order_of_luma_w[2]
                                 ,pu_order_of_luma_w[0] };
  assign pu_order_y_of_luma_w = { pu_order_of_luma_w[7]
                                 ,pu_order_of_luma_w[5]
                                 ,pu_order_of_luma_w[3]
                                 ,pu_order_of_luma_w[1] };

  assign pu_order_tl_x_of_luma_w = pu_order_x_of_luma_w -1 ;
  assign pu_order_tl_y_of_luma_w = pu_order_y_of_luma_w -1 ;
  assign pu_order_tp_x_of_luma_w = pu_order_x_of_luma_w    ;
  assign pu_order_tp_y_of_luma_w = pu_order_y_of_luma_w -1 ;
  assign pu_order_rt_x_of_luma_w = pu_order_x_of_luma_w +1 ;
  assign pu_order_rt_y_of_luma_w = pu_order_y_of_luma_w -1 ;
  assign pu_order_lf_x_of_luma_w = pu_order_x_of_luma_w -1 ;
  assign pu_order_lf_y_of_luma_w = pu_order_y_of_luma_w    ;
  assign pu_order_dn_x_of_luma_w = pu_order_x_of_luma_w -1 ;
  assign pu_order_dn_y_of_luma_w = pu_order_y_of_luma_w +1 ;

  assign pu_order_tl_of_luma_w = { pu_order_tl_y_of_luma_w[3] ,pu_order_tl_x_of_luma_w[3]
                                  ,pu_order_tl_y_of_luma_w[2] ,pu_order_tl_x_of_luma_w[2]
                                  ,pu_order_tl_y_of_luma_w[1] ,pu_order_tl_x_of_luma_w[1]
                                  ,pu_order_tl_y_of_luma_w[0] ,pu_order_tl_x_of_luma_w[0] };
  assign pu_order_tp_of_luma_w = { pu_order_tp_y_of_luma_w[3] ,pu_order_tp_x_of_luma_w[3]
                                  ,pu_order_tp_y_of_luma_w[2] ,pu_order_tp_x_of_luma_w[2]
                                  ,pu_order_tp_y_of_luma_w[1] ,pu_order_tp_x_of_luma_w[1]
                                  ,pu_order_tp_y_of_luma_w[0] ,pu_order_tp_x_of_luma_w[0] };
  assign pu_order_rt_of_luma_w = { pu_order_rt_y_of_luma_w[3] ,pu_order_rt_x_of_luma_w[3]
                                  ,pu_order_rt_y_of_luma_w[2] ,pu_order_rt_x_of_luma_w[2]
                                  ,pu_order_rt_y_of_luma_w[1] ,pu_order_rt_x_of_luma_w[1]
                                  ,pu_order_rt_y_of_luma_w[0] ,pu_order_rt_x_of_luma_w[0] };
  assign pu_order_lf_of_luma_w = { pu_order_lf_y_of_luma_w[3] ,pu_order_lf_x_of_luma_w[3]
                                  ,pu_order_lf_y_of_luma_w[2] ,pu_order_lf_x_of_luma_w[2]
                                  ,pu_order_lf_y_of_luma_w[1] ,pu_order_lf_x_of_luma_w[1]
                                  ,pu_order_lf_y_of_luma_w[0] ,pu_order_lf_x_of_luma_w[0] };
  assign pu_order_dn_of_luma_w = { pu_order_dn_y_of_luma_w[3] ,pu_order_dn_x_of_luma_w[3]
                                  ,pu_order_dn_y_of_luma_w[2] ,pu_order_dn_x_of_luma_w[2]
                                  ,pu_order_dn_y_of_luma_w[1] ,pu_order_dn_x_of_luma_w[1]
                                  ,pu_order_dn_y_of_luma_w[0] ,pu_order_dn_x_of_luma_w[0] };

  always @(*) begin
                 pu_delta_w = 0 ;
    case( size_of_luma_w )
      `SIZE_04 : pu_delta_w = 1 ;
      `SIZE_08 : pu_delta_w = 2 ;
      `SIZE_16 : pu_delta_w = 4 ;
      `SIZE_32 : pu_delta_w = 8 ;
    endcase
  end

  // top-left
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      pu_tl_exist_r <= 0 ;
    end
    else begin
      if( ( (ctu_x_cur_i==0          ) && (pu_4x4_x_of_luma_w==0                   ) )
       || ( (ctu_y_cur_i==0          ) && (pu_4x4_y_of_luma_w==0                   ) )
       || ( (ctu_x_cur_i==ctu_x_all_i) && (pu_4x4_x_of_luma_w> {1'b0,ctu_x_res_i}+1) )    // in fact, it's pu_4x4_x_of_luma_w-1>ctu_x_res_i
       || ( (ctu_y_cur_i==ctu_y_all_i) && (pu_4x4_y_of_luma_w> {1'b0,ctu_y_res_i}+1) )    // in fact, it's pu_4x4_y_of_luma_w-1>ctu_y_res_i
      ) begin
        pu_tl_exist_r <= 0 ;
      end
      else begin
        pu_tl_exist_r <= 1 ;
      end
    end
  end

  // top
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      pu_tp_exist_r <= 0 ;
    end
    else begin
      if( ( (ctu_y_cur_i==0          ) && (pu_4x4_y_of_luma_w==      0             ) )
       || ( (ctu_x_cur_i==ctu_x_all_i) && (pu_4x4_x_of_luma_w>       ctu_x_res_i   ) )
       || ( (ctu_y_cur_i==ctu_y_all_i) && (pu_4x4_y_of_luma_w> {1'b0,ctu_y_res_i}+1) )
      ) begin
        pu_tp_exist_r <= 0 ;
      end
      else begin
        pu_tp_exist_r <= 1 ;
      end
    end
  end

  // right
  genvar idx_rt ;

  generate
    for(idx_rt=0 ;idx_rt<8; idx_rt=idx_rt+1) begin: pu_rt_exist_loop
      always @(posedge clk or negedge rstn ) begin
        if( !rstn ) begin
          pu_rt_exist_r[idx_rt] <= 0 ;
        end
        else begin
          if( ( (ctu_y_cur_i==0 )          && (      pu_4x4_y_of_luma_w                   ==      0             ) )
           || ( (ctu_x_cur_i==ctu_x_all_i) && ({1'b0,pu_4x4_x_of_luma_w}+pu_delta_w+idx_rt>       ctu_x_res_i   ) )
           || ( (ctu_y_cur_i==ctu_y_all_i) && (      pu_4x4_y_of_luma_w                   > {1'b0,ctu_y_res_i}+1) )
          ) begin
            pu_rt_exist_r[idx_rt] <= 0 ;
          end
          else begin
            if( pu_4x4_y_of_luma_w==0 ) begin
              pu_rt_exist_r[idx_rt] <= 1 ;
            end
            else begin
              if( {1'b0,pu_4x4_x_of_luma_w}+pu_delta_w+idx_rt>15 ) begin
                pu_rt_exist_r[idx_rt] <= 0 ;
              end
              else if( pu_order_rt_of_luma_w>pu_order_of_luma_w ) begin
                pu_rt_exist_r[idx_rt] <= 0 ;
              end
              else begin
                pu_rt_exist_r[idx_rt] <= 1 ;
              end
            end
          end
        end
      end
    end
  endgenerate

  // left
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      pu_lf_exist_r <= 0 ;
    end
    else begin
      if( ( (ctu_x_cur_i==0 )          && (pu_4x4_x_of_luma_w==      0             ) )
       || ( (ctu_x_cur_i==ctu_x_all_i) && (pu_4x4_x_of_luma_w> {1'b0,ctu_x_res_i}+1) )
       || ( (ctu_y_cur_i==ctu_y_all_i) && (pu_4x4_y_of_luma_w>       ctu_y_res_i   ) )
      ) begin
        pu_lf_exist_r <= 0 ;
      end
      else begin
        pu_lf_exist_r <= 1 ;
      end
    end
  end

  // down
  genvar idx_dn ;

  generate
    for(idx_dn=0 ;idx_dn<8; idx_dn=idx_dn+1) begin: pu_dn_exist_loop
      always @(posedge clk or negedge rstn ) begin
        if( !rstn ) begin
          pu_dn_exist_r[idx_dn] <= 0 ;
        end
        else begin
          if( ( (ctu_x_cur_i==0 )          && (      pu_4x4_x_of_luma_w                    ==      0             ) )
           || ( (ctu_x_cur_i==ctu_x_all_i) && (      pu_4x4_x_of_luma_w                    > {1'b0,ctu_x_res_i}+1) )
           || ( (ctu_y_cur_i==ctu_y_all_i) && ({1'b0,pu_4x4_y_of_luma_w+pu_delta_w}+idx_dn >       ctu_y_res_i   ) )
          ) begin
            pu_dn_exist_r[idx_dn] <= 0 ;
          end
          else begin
            if( pu_4x4_x_of_luma_w==0 ) begin
              if( {1'b0,pu_4x4_y_of_luma_w}+pu_delta_w>15 ) begin
                pu_dn_exist_r[idx_dn] <= 0 ;
              end
              else begin
                pu_dn_exist_r[idx_dn] <= 1 ;
              end
            end
            else begin
              if( {1'b0,pu_4x4_y_of_luma_w}+pu_delta_w>15 ) begin
                pu_dn_exist_r[idx_dn] <= 0 ;
              end
              else if( pu_order_dn_of_luma_w>pu_order_of_luma_w ) begin
                pu_dn_exist_r[idx_dn] <= 0 ;
              end
              else begin
                pu_dn_exist_r[idx_dn] <= 1 ;
              end
            end
          end
        end
      end
    end
  endgenerate


//--- PADDING --------------------------
  // top-left
  always @(*) begin
                 ref_pad_tl_w = 128       ;
    casez( {pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0],pu_tp_exist_r,pu_rt_exist_r[0]} )
      5'b1???? : ref_pad_tl_w = ref_tl_o  ;
      5'b01??? : ref_pad_tl_w = ref_l00_o ;
      5'b001?? : ref_pad_tl_w = ref_d00_o ;
      5'b0001? : ref_pad_tl_w = ref_t00_o ;
      5'b00001 : ref_pad_tl_w = ref_r00_o ;
    endcase
  end

  // top
  always @(*) begin
    ref_pad_t00_w = 128 ; ref_pad_t01_w = 128 ;
    ref_pad_t02_w = 128 ; ref_pad_t03_w = 128 ;
    ref_pad_t04_w = 128 ; ref_pad_t05_w = 128 ;
    ref_pad_t06_w = 128 ; ref_pad_t07_w = 128 ;
    ref_pad_t08_w = 128 ; ref_pad_t09_w = 128 ;
    ref_pad_t10_w = 128 ; ref_pad_t11_w = 128 ;
    ref_pad_t12_w = 128 ; ref_pad_t13_w = 128 ;
    ref_pad_t14_w = 128 ; ref_pad_t15_w = 128 ;
    ref_pad_t16_w = 128 ; ref_pad_t17_w = 128 ;
    ref_pad_t18_w = 128 ; ref_pad_t19_w = 128 ;
    ref_pad_t20_w = 128 ; ref_pad_t21_w = 128 ;
    ref_pad_t22_w = 128 ; ref_pad_t23_w = 128 ;
    ref_pad_t24_w = 128 ; ref_pad_t25_w = 128 ;
    ref_pad_t26_w = 128 ; ref_pad_t27_w = 128 ;
    ref_pad_t28_w = 128 ; ref_pad_t29_w = 128 ;
    ref_pad_t30_w = 128 ; ref_pad_t31_w = 128 ;
    case( size_i )
      `SIZE_04 : begin    casez({pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0],pu_rt_exist_r[0]})
                            5'b1???? : begin    ref_pad_t00_w = ref_t00_o ; ref_pad_t01_w = ref_t01_o ;
                                                ref_pad_t02_w = ref_t02_o ; ref_pad_t03_w = ref_t03_o ;
                            end
                            5'b01??? : begin    ref_pad_t00_w = ref_tl_o  ; ref_pad_t01_w = ref_tl_o  ;
                                                ref_pad_t02_w = ref_tl_o  ; ref_pad_t03_w = ref_tl_o  ;
                            end
                            5'b001?? : begin    ref_pad_t00_w = ref_l00_o ; ref_pad_t01_w = ref_l00_o ;
                                                ref_pad_t02_w = ref_l00_o ; ref_pad_t03_w = ref_l00_o ;
                            end
                            5'b0001? : begin    ref_pad_t00_w = ref_d00_o ; ref_pad_t01_w = ref_d00_o ;
                                                ref_pad_t02_w = ref_d00_o ; ref_pad_t03_w = ref_d00_o ;
                            end
                            5'b00001 : begin    ref_pad_t00_w = ref_r00_o ; ref_pad_t01_w = ref_r00_o ;
                                                ref_pad_t02_w = ref_r00_o ; ref_pad_t03_w = ref_r00_o ;
                            end
                          endcase
      end
      `SIZE_08 : begin    casez({pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0],pu_rt_exist_r[0]})
                            5'b1???? : begin    ref_pad_t00_w = ref_t00_o ; ref_pad_t01_w = ref_t01_o ;
                                                ref_pad_t02_w = ref_t02_o ; ref_pad_t03_w = ref_t03_o ;
                                                ref_pad_t04_w = ref_t04_o ; ref_pad_t05_w = ref_t05_o ;
                                                ref_pad_t06_w = ref_t06_o ; ref_pad_t07_w = ref_t07_o ;
                            end
                            5'b01??? : begin    ref_pad_t00_w = ref_tl_o  ; ref_pad_t01_w = ref_tl_o  ;
                                                ref_pad_t02_w = ref_tl_o  ; ref_pad_t03_w = ref_tl_o  ;
                                                ref_pad_t04_w = ref_tl_o  ; ref_pad_t05_w = ref_tl_o  ;
                                                ref_pad_t06_w = ref_tl_o  ; ref_pad_t07_w = ref_tl_o  ;
                            end
                            5'b001?? : begin    ref_pad_t00_w = ref_l00_o ; ref_pad_t01_w = ref_l00_o ;
                                                ref_pad_t02_w = ref_l00_o ; ref_pad_t03_w = ref_l00_o ;
                                                ref_pad_t04_w = ref_l00_o ; ref_pad_t05_w = ref_l00_o ;
                                                ref_pad_t06_w = ref_l00_o ; ref_pad_t07_w = ref_l00_o ;
                            end
                            5'b0001? : begin    ref_pad_t00_w = ref_d00_o ; ref_pad_t01_w = ref_d00_o ;
                                                ref_pad_t02_w = ref_d00_o ; ref_pad_t03_w = ref_d00_o ;
                                                ref_pad_t04_w = ref_d00_o ; ref_pad_t05_w = ref_d00_o ;
                                                ref_pad_t06_w = ref_d00_o ; ref_pad_t07_w = ref_d00_o ;
                            end
                            5'b00001 : begin    ref_pad_t00_w = ref_r00_o ; ref_pad_t01_w = ref_r00_o ;
                                                ref_pad_t02_w = ref_r00_o ; ref_pad_t03_w = ref_r00_o ;
                                                ref_pad_t04_w = ref_r00_o ; ref_pad_t05_w = ref_r00_o ;
                                                ref_pad_t06_w = ref_r00_o ; ref_pad_t07_w = ref_r00_o ;
                            end
                          endcase
      end
      `SIZE_16 : begin    casez({pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0],pu_rt_exist_r[0]})
                            5'b1???? : begin    ref_pad_t00_w = ref_t00_o ; ref_pad_t01_w = ref_t01_o ;
                                                ref_pad_t02_w = ref_t02_o ; ref_pad_t03_w = ref_t03_o ;
                                                ref_pad_t04_w = ref_t04_o ; ref_pad_t05_w = ref_t05_o ;
                                                ref_pad_t06_w = ref_t06_o ; ref_pad_t07_w = ref_t07_o ;
                                                ref_pad_t08_w = ref_t08_o ; ref_pad_t09_w = ref_t09_o ;
                                                ref_pad_t10_w = ref_t10_o ; ref_pad_t11_w = ref_t11_o ;
                                                ref_pad_t12_w = ref_t12_o ; ref_pad_t13_w = ref_t13_o ;
                                                ref_pad_t14_w = ref_t14_o ; ref_pad_t15_w = ref_t15_o ;
                            end
                            5'b01??? : begin    ref_pad_t00_w = ref_tl_o  ; ref_pad_t01_w = ref_tl_o  ;
                                                ref_pad_t02_w = ref_tl_o  ; ref_pad_t03_w = ref_tl_o  ;
                                                ref_pad_t04_w = ref_tl_o  ; ref_pad_t05_w = ref_tl_o  ;
                                                ref_pad_t06_w = ref_tl_o  ; ref_pad_t07_w = ref_tl_o  ;
                                                ref_pad_t08_w = ref_tl_o  ; ref_pad_t09_w = ref_tl_o  ;
                                                ref_pad_t10_w = ref_tl_o  ; ref_pad_t11_w = ref_tl_o  ;
                                                ref_pad_t12_w = ref_tl_o  ; ref_pad_t13_w = ref_tl_o  ;
                                                ref_pad_t14_w = ref_tl_o  ; ref_pad_t15_w = ref_tl_o  ;
                            end
                            5'b001?? : begin    ref_pad_t00_w = ref_l00_o ; ref_pad_t01_w = ref_l00_o ;
                                                ref_pad_t02_w = ref_l00_o ; ref_pad_t03_w = ref_l00_o ;
                                                ref_pad_t04_w = ref_l00_o ; ref_pad_t05_w = ref_l00_o ;
                                                ref_pad_t06_w = ref_l00_o ; ref_pad_t07_w = ref_l00_o ;
                                                ref_pad_t08_w = ref_l00_o ; ref_pad_t09_w = ref_l00_o ;
                                                ref_pad_t10_w = ref_l00_o ; ref_pad_t11_w = ref_l00_o ;
                                                ref_pad_t12_w = ref_l00_o ; ref_pad_t13_w = ref_l00_o ;
                                                ref_pad_t14_w = ref_l00_o ; ref_pad_t15_w = ref_l00_o ;
                            end
                            5'b0001? : begin    ref_pad_t00_w = ref_d00_o ; ref_pad_t01_w = ref_d00_o ;
                                                ref_pad_t02_w = ref_d00_o ; ref_pad_t03_w = ref_d00_o ;
                                                ref_pad_t04_w = ref_d00_o ; ref_pad_t05_w = ref_d00_o ;
                                                ref_pad_t06_w = ref_d00_o ; ref_pad_t07_w = ref_d00_o ;
                                                ref_pad_t08_w = ref_d00_o ; ref_pad_t09_w = ref_d00_o ;
                                                ref_pad_t10_w = ref_d00_o ; ref_pad_t11_w = ref_d00_o ;
                                                ref_pad_t12_w = ref_d00_o ; ref_pad_t13_w = ref_d00_o ;
                                                ref_pad_t14_w = ref_d00_o ; ref_pad_t15_w = ref_d00_o ;
                            end
                            5'b00001 : begin    ref_pad_t00_w = ref_r00_o ; ref_pad_t01_w = ref_r00_o ;
                                                ref_pad_t02_w = ref_r00_o ; ref_pad_t03_w = ref_r00_o ;
                                                ref_pad_t04_w = ref_r00_o ; ref_pad_t05_w = ref_r00_o ;
                                                ref_pad_t06_w = ref_r00_o ; ref_pad_t07_w = ref_r00_o ;
                                                ref_pad_t08_w = ref_r00_o ; ref_pad_t09_w = ref_r00_o ;
                                                ref_pad_t10_w = ref_r00_o ; ref_pad_t11_w = ref_r00_o ;
                                                ref_pad_t12_w = ref_r00_o ; ref_pad_t13_w = ref_r00_o ;
                                                ref_pad_t14_w = ref_r00_o ; ref_pad_t15_w = ref_r00_o ;
                            end
                          endcase
      end
      `SIZE_32 : begin    casez({pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0],pu_rt_exist_r[0]})
                            5'b1???? : begin    ref_pad_t00_w = ref_t00_o ; ref_pad_t01_w = ref_t01_o ;
                                                ref_pad_t02_w = ref_t02_o ; ref_pad_t03_w = ref_t03_o ;
                                                ref_pad_t04_w = ref_t04_o ; ref_pad_t05_w = ref_t05_o ;
                                                ref_pad_t06_w = ref_t06_o ; ref_pad_t07_w = ref_t07_o ;
                                                ref_pad_t08_w = ref_t08_o ; ref_pad_t09_w = ref_t09_o ;
                                                ref_pad_t10_w = ref_t10_o ; ref_pad_t11_w = ref_t11_o ;
                                                ref_pad_t12_w = ref_t12_o ; ref_pad_t13_w = ref_t13_o ;
                                                ref_pad_t14_w = ref_t14_o ; ref_pad_t15_w = ref_t15_o ;
                                                ref_pad_t16_w = ref_t16_o ; ref_pad_t17_w = ref_t17_o ;
                                                ref_pad_t18_w = ref_t18_o ; ref_pad_t19_w = ref_t19_o ;
                                                ref_pad_t20_w = ref_t20_o ; ref_pad_t21_w = ref_t21_o ;
                                                ref_pad_t22_w = ref_t22_o ; ref_pad_t23_w = ref_t23_o ;
                                                ref_pad_t24_w = ref_t24_o ; ref_pad_t25_w = ref_t25_o ;
                                                ref_pad_t26_w = ref_t26_o ; ref_pad_t27_w = ref_t27_o ;
                                                ref_pad_t28_w = ref_t28_o ; ref_pad_t29_w = ref_t29_o ;
                                                ref_pad_t30_w = ref_t30_o ; ref_pad_t31_w = ref_t31_o ;
                            end
                            5'b01??? : begin    ref_pad_t00_w = ref_tl_o  ; ref_pad_t01_w = ref_tl_o  ;
                                                ref_pad_t02_w = ref_tl_o  ; ref_pad_t03_w = ref_tl_o  ;
                                                ref_pad_t04_w = ref_tl_o  ; ref_pad_t05_w = ref_tl_o  ;
                                                ref_pad_t06_w = ref_tl_o  ; ref_pad_t07_w = ref_tl_o  ;
                                                ref_pad_t08_w = ref_tl_o  ; ref_pad_t09_w = ref_tl_o  ;
                                                ref_pad_t10_w = ref_tl_o  ; ref_pad_t11_w = ref_tl_o  ;
                                                ref_pad_t12_w = ref_tl_o  ; ref_pad_t13_w = ref_tl_o  ;
                                                ref_pad_t14_w = ref_tl_o  ; ref_pad_t15_w = ref_tl_o  ;
                                                ref_pad_t16_w = ref_tl_o  ; ref_pad_t17_w = ref_tl_o  ;
                                                ref_pad_t18_w = ref_tl_o  ; ref_pad_t19_w = ref_tl_o  ;
                                                ref_pad_t20_w = ref_tl_o  ; ref_pad_t21_w = ref_tl_o  ;
                                                ref_pad_t22_w = ref_tl_o  ; ref_pad_t23_w = ref_tl_o  ;
                                                ref_pad_t24_w = ref_tl_o  ; ref_pad_t25_w = ref_tl_o  ;
                                                ref_pad_t26_w = ref_tl_o  ; ref_pad_t27_w = ref_tl_o  ;
                                                ref_pad_t28_w = ref_tl_o  ; ref_pad_t29_w = ref_tl_o  ;
                                                ref_pad_t30_w = ref_tl_o  ; ref_pad_t31_w = ref_tl_o  ;
                            end
                            5'b001?? : begin    ref_pad_t00_w = ref_l00_o ; ref_pad_t01_w = ref_l00_o ;
                                                ref_pad_t02_w = ref_l00_o ; ref_pad_t03_w = ref_l00_o ;
                                                ref_pad_t04_w = ref_l00_o ; ref_pad_t05_w = ref_l00_o ;
                                                ref_pad_t06_w = ref_l00_o ; ref_pad_t07_w = ref_l00_o ;
                                                ref_pad_t08_w = ref_l00_o ; ref_pad_t09_w = ref_l00_o ;
                                                ref_pad_t10_w = ref_l00_o ; ref_pad_t11_w = ref_l00_o ;
                                                ref_pad_t12_w = ref_l00_o ; ref_pad_t13_w = ref_l00_o ;
                                                ref_pad_t14_w = ref_l00_o ; ref_pad_t15_w = ref_l00_o ;
                                                ref_pad_t16_w = ref_l00_o ; ref_pad_t17_w = ref_l00_o ;
                                                ref_pad_t18_w = ref_l00_o ; ref_pad_t19_w = ref_l00_o ;
                                                ref_pad_t20_w = ref_l00_o ; ref_pad_t21_w = ref_l00_o ;
                                                ref_pad_t22_w = ref_l00_o ; ref_pad_t23_w = ref_l00_o ;
                                                ref_pad_t24_w = ref_l00_o ; ref_pad_t25_w = ref_l00_o ;
                                                ref_pad_t26_w = ref_l00_o ; ref_pad_t27_w = ref_l00_o ;
                                                ref_pad_t28_w = ref_l00_o ; ref_pad_t29_w = ref_l00_o ;
                                                ref_pad_t30_w = ref_l00_o ; ref_pad_t31_w = ref_l00_o ;
                            end
                            5'b0001? : begin    ref_pad_t00_w = ref_d00_o ; ref_pad_t01_w = ref_d00_o ;
                                                ref_pad_t02_w = ref_d00_o ; ref_pad_t03_w = ref_d00_o ;
                                                ref_pad_t04_w = ref_d00_o ; ref_pad_t05_w = ref_d00_o ;
                                                ref_pad_t06_w = ref_d00_o ; ref_pad_t07_w = ref_d00_o ;
                                                ref_pad_t08_w = ref_d00_o ; ref_pad_t09_w = ref_d00_o ;
                                                ref_pad_t10_w = ref_d00_o ; ref_pad_t11_w = ref_d00_o ;
                                                ref_pad_t12_w = ref_d00_o ; ref_pad_t13_w = ref_d00_o ;
                                                ref_pad_t14_w = ref_d00_o ; ref_pad_t15_w = ref_d00_o ;
                                                ref_pad_t16_w = ref_d00_o ; ref_pad_t17_w = ref_d00_o ;
                                                ref_pad_t18_w = ref_d00_o ; ref_pad_t19_w = ref_d00_o ;
                                                ref_pad_t20_w = ref_d00_o ; ref_pad_t21_w = ref_d00_o ;
                                                ref_pad_t22_w = ref_d00_o ; ref_pad_t23_w = ref_d00_o ;
                                                ref_pad_t24_w = ref_d00_o ; ref_pad_t25_w = ref_d00_o ;
                                                ref_pad_t26_w = ref_d00_o ; ref_pad_t27_w = ref_d00_o ;
                                                ref_pad_t28_w = ref_d00_o ; ref_pad_t29_w = ref_d00_o ;
                                                ref_pad_t30_w = ref_d00_o ; ref_pad_t31_w = ref_d00_o ;
                            end
                            5'b00001 : begin    ref_pad_t00_w = ref_r00_o ; ref_pad_t01_w = ref_r00_o ;
                                                ref_pad_t02_w = ref_r00_o ; ref_pad_t03_w = ref_r00_o ;
                                                ref_pad_t04_w = ref_r00_o ; ref_pad_t05_w = ref_r00_o ;
                                                ref_pad_t06_w = ref_r00_o ; ref_pad_t07_w = ref_r00_o ;
                                                ref_pad_t08_w = ref_r00_o ; ref_pad_t09_w = ref_r00_o ;
                                                ref_pad_t10_w = ref_r00_o ; ref_pad_t11_w = ref_r00_o ;
                                                ref_pad_t12_w = ref_r00_o ; ref_pad_t13_w = ref_r00_o ;
                                                ref_pad_t14_w = ref_r00_o ; ref_pad_t15_w = ref_r00_o ;
                                                ref_pad_t16_w = ref_r00_o ; ref_pad_t17_w = ref_r00_o ;
                                                ref_pad_t18_w = ref_r00_o ; ref_pad_t19_w = ref_r00_o ;
                                                ref_pad_t20_w = ref_r00_o ; ref_pad_t21_w = ref_r00_o ;
                                                ref_pad_t22_w = ref_r00_o ; ref_pad_t23_w = ref_r00_o ;
                                                ref_pad_t24_w = ref_r00_o ; ref_pad_t25_w = ref_r00_o ;
                                                ref_pad_t26_w = ref_r00_o ; ref_pad_t27_w = ref_r00_o ;
                                                ref_pad_t28_w = ref_r00_o ; ref_pad_t29_w = ref_r00_o ;
                                                ref_pad_t30_w = ref_r00_o ; ref_pad_t31_w = ref_r00_o ;
                            end
                          endcase
      end
    endcase
  end

  // right
  always @(*) begin
    ref_pad_r00_w = 128 ; ref_pad_r01_w = 128 ;
    ref_pad_r02_w = 128 ; ref_pad_r03_w = 128 ;
    ref_pad_r04_w = 128 ; ref_pad_r05_w = 128 ;
    ref_pad_r06_w = 128 ; ref_pad_r07_w = 128 ;
    ref_pad_r08_w = 128 ; ref_pad_r09_w = 128 ;
    ref_pad_r10_w = 128 ; ref_pad_r11_w = 128 ;
    ref_pad_r12_w = 128 ; ref_pad_r13_w = 128 ;
    ref_pad_r14_w = 128 ; ref_pad_r15_w = 128 ;
    ref_pad_r16_w = 128 ; ref_pad_r17_w = 128 ;
    ref_pad_r18_w = 128 ; ref_pad_r19_w = 128 ;
    ref_pad_r20_w = 128 ; ref_pad_r21_w = 128 ;
    ref_pad_r22_w = 128 ; ref_pad_r23_w = 128 ;
    ref_pad_r24_w = 128 ; ref_pad_r25_w = 128 ;
    ref_pad_r26_w = 128 ; ref_pad_r27_w = 128 ;
    ref_pad_r28_w = 128 ; ref_pad_r29_w = 128 ;
    ref_pad_r30_w = 128 ; ref_pad_r31_w = 128 ;
    case( size_i )
      `SIZE_04 : begin    casez( {pu_rt_exist_r[0],pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0]} )
                            5'b1???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                            end
                            5'b01??? : begin    ref_pad_r00_w = ref_t03_o ; ref_pad_r01_w = ref_t03_o ;
                                                ref_pad_r02_w = ref_t03_o ; ref_pad_r03_w = ref_t03_o ;
                            end
                            5'b001?? : begin    ref_pad_r00_w = ref_tl_o  ; ref_pad_r01_w = ref_tl_o  ;
                                                ref_pad_r02_w = ref_tl_o  ; ref_pad_r03_w = ref_tl_o  ;
                            end
                            5'b0001? : begin    ref_pad_r00_w = ref_l00_o ; ref_pad_r01_w = ref_l00_o ;
                                                ref_pad_r02_w = ref_l00_o ; ref_pad_r03_w = ref_l00_o ;
                            end
                            5'b00001 : begin    ref_pad_r00_w = ref_d00_o ; ref_pad_r01_w = ref_d00_o ;
                                                ref_pad_r02_w = ref_d00_o ; ref_pad_r03_w = ref_d00_o ;
                            end
                          endcase
      end
      `SIZE_08 : begin    casez( {pu_rt_exist_r[1:0],pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0]} )
                            6'b1?_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                  ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                  ref_pad_r04_w = ref_r04_o ; ref_pad_r05_w = ref_r05_o ;
                                                  ref_pad_r06_w = ref_r06_o ; ref_pad_r07_w = ref_r07_o ;
                            end
                            6'b01_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                  ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                  ref_pad_r04_w = ref_r03_o ; ref_pad_r05_w = ref_r03_o ;
                                                  ref_pad_r06_w = ref_r03_o ; ref_pad_r07_w = ref_r03_o ;
                            end
                            6'b00_1??? : begin    ref_pad_r00_w = ref_t07_o ; ref_pad_r01_w = ref_t07_o ;
                                                  ref_pad_r02_w = ref_t07_o ; ref_pad_r03_w = ref_t07_o ;
                                                  ref_pad_r04_w = ref_t07_o ; ref_pad_r05_w = ref_t07_o ;
                                                  ref_pad_r06_w = ref_t07_o ; ref_pad_r07_w = ref_t07_o ;
                            end
                            6'b00_01?? : begin    ref_pad_r00_w = ref_tl_o  ; ref_pad_r01_w = ref_tl_o  ;
                                                  ref_pad_r02_w = ref_tl_o  ; ref_pad_r03_w = ref_tl_o  ;
                                                  ref_pad_r04_w = ref_tl_o  ; ref_pad_r05_w = ref_tl_o  ;
                                                  ref_pad_r06_w = ref_tl_o  ; ref_pad_r07_w = ref_tl_o  ;
                            end
                            6'b00_001? : begin    ref_pad_r00_w = ref_l00_o ; ref_pad_r01_w = ref_l00_o ;
                                                  ref_pad_r02_w = ref_l00_o ; ref_pad_r03_w = ref_l00_o ;
                                                  ref_pad_r04_w = ref_l00_o ; ref_pad_r05_w = ref_l00_o ;
                                                  ref_pad_r06_w = ref_l00_o ; ref_pad_r07_w = ref_l00_o ;
                            end
                            6'b00_0001 : begin    ref_pad_r00_w = ref_d00_o ; ref_pad_r01_w = ref_d00_o ;
                                                  ref_pad_r02_w = ref_d00_o ; ref_pad_r03_w = ref_d00_o ;
                                                  ref_pad_r04_w = ref_d00_o ; ref_pad_r05_w = ref_d00_o ;
                                                  ref_pad_r06_w = ref_d00_o ; ref_pad_r07_w = ref_d00_o ;
                            end
                          endcase
      end
      `SIZE_16 : begin    casez( {pu_rt_exist_r[3:0],pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0]} )
                            8'b1???_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                    ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                    ref_pad_r04_w = ref_r04_o ; ref_pad_r05_w = ref_r05_o ;
                                                    ref_pad_r06_w = ref_r06_o ; ref_pad_r07_w = ref_r07_o ;
                                                    ref_pad_r08_w = ref_r08_o ; ref_pad_r09_w = ref_r09_o ;
                                                    ref_pad_r10_w = ref_r10_o ; ref_pad_r11_w = ref_r11_o ;
                                                    ref_pad_r12_w = ref_r12_o ; ref_pad_r13_w = ref_r13_o ;
                                                    ref_pad_r14_w = ref_r14_o ; ref_pad_r15_w = ref_r15_o ;
                            end
                            8'b01??_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                    ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                    ref_pad_r04_w = ref_r04_o ; ref_pad_r05_w = ref_r05_o ;
                                                    ref_pad_r06_w = ref_r06_o ; ref_pad_r07_w = ref_r07_o ;
                                                    ref_pad_r08_w = ref_r08_o ; ref_pad_r09_w = ref_r09_o ;
                                                    ref_pad_r10_w = ref_r10_o ; ref_pad_r11_w = ref_r11_o ;
                                                    ref_pad_r12_w = ref_r11_o ; ref_pad_r13_w = ref_r11_o ;
                                                    ref_pad_r14_w = ref_r11_o ; ref_pad_r15_w = ref_r11_o ;
                            end
                            8'b001?_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                    ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                    ref_pad_r04_w = ref_r04_o ; ref_pad_r05_w = ref_r05_o ;
                                                    ref_pad_r06_w = ref_r06_o ; ref_pad_r07_w = ref_r07_o ;
                                                    ref_pad_r08_w = ref_r07_o ; ref_pad_r09_w = ref_r07_o ;
                                                    ref_pad_r10_w = ref_r07_o ; ref_pad_r11_w = ref_r07_o ;
                                                    ref_pad_r12_w = ref_r07_o ; ref_pad_r13_w = ref_r07_o ;
                                                    ref_pad_r14_w = ref_r07_o ; ref_pad_r15_w = ref_r07_o ;
                            end
                            8'b0001_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                    ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                    ref_pad_r04_w = ref_r03_o ; ref_pad_r05_w = ref_r03_o ;
                                                    ref_pad_r06_w = ref_r03_o ; ref_pad_r07_w = ref_r03_o ;
                                                    ref_pad_r08_w = ref_r03_o ; ref_pad_r09_w = ref_r03_o ;
                                                    ref_pad_r10_w = ref_r03_o ; ref_pad_r11_w = ref_r03_o ;
                                                    ref_pad_r12_w = ref_r03_o ; ref_pad_r13_w = ref_r03_o ;
                                                    ref_pad_r14_w = ref_r03_o ; ref_pad_r15_w = ref_r03_o ;
                            end
                            8'b0000_1??? : begin    ref_pad_r00_w = ref_t15_o ; ref_pad_r01_w = ref_t15_o ;
                                                    ref_pad_r02_w = ref_t15_o ; ref_pad_r03_w = ref_t15_o ;
                                                    ref_pad_r04_w = ref_t15_o ; ref_pad_r05_w = ref_t15_o ;
                                                    ref_pad_r06_w = ref_t15_o ; ref_pad_r07_w = ref_t15_o ;
                                                    ref_pad_r08_w = ref_t15_o ; ref_pad_r09_w = ref_t15_o ;
                                                    ref_pad_r10_w = ref_t15_o ; ref_pad_r11_w = ref_t15_o ;
                                                    ref_pad_r12_w = ref_t15_o ; ref_pad_r13_w = ref_t15_o ;
                                                    ref_pad_r14_w = ref_t15_o ; ref_pad_r15_w = ref_t15_o ;
                            end
                            8'b0000_01?? : begin    ref_pad_r00_w = ref_tl_o  ; ref_pad_r01_w = ref_tl_o  ;
                                                    ref_pad_r02_w = ref_tl_o  ; ref_pad_r03_w = ref_tl_o  ;
                                                    ref_pad_r04_w = ref_tl_o  ; ref_pad_r05_w = ref_tl_o  ;
                                                    ref_pad_r06_w = ref_tl_o  ; ref_pad_r07_w = ref_tl_o  ;
                                                    ref_pad_r08_w = ref_tl_o  ; ref_pad_r09_w = ref_tl_o  ;
                                                    ref_pad_r10_w = ref_tl_o  ; ref_pad_r11_w = ref_tl_o  ;
                                                    ref_pad_r12_w = ref_tl_o  ; ref_pad_r13_w = ref_tl_o  ;
                                                    ref_pad_r14_w = ref_tl_o  ; ref_pad_r15_w = ref_tl_o  ;
                            end
                            8'b0000_001? : begin    ref_pad_r00_w = ref_l00_o ; ref_pad_r01_w = ref_l00_o ;
                                                    ref_pad_r02_w = ref_l00_o ; ref_pad_r03_w = ref_l00_o ;
                                                    ref_pad_r04_w = ref_l00_o ; ref_pad_r05_w = ref_l00_o ;
                                                    ref_pad_r06_w = ref_l00_o ; ref_pad_r07_w = ref_l00_o ;
                                                    ref_pad_r08_w = ref_l00_o ; ref_pad_r09_w = ref_l00_o ;
                                                    ref_pad_r10_w = ref_l00_o ; ref_pad_r11_w = ref_l00_o ;
                                                    ref_pad_r12_w = ref_l00_o ; ref_pad_r13_w = ref_l00_o ;
                                                    ref_pad_r14_w = ref_l00_o ; ref_pad_r15_w = ref_l00_o ;
                            end
                            8'b0000_0001 : begin    ref_pad_r00_w = ref_d00_o ; ref_pad_r01_w = ref_d00_o ;
                                                    ref_pad_r02_w = ref_d00_o ; ref_pad_r03_w = ref_d00_o ;
                                                    ref_pad_r04_w = ref_d00_o ; ref_pad_r05_w = ref_d00_o ;
                                                    ref_pad_r06_w = ref_d00_o ; ref_pad_r07_w = ref_d00_o ;
                                                    ref_pad_r08_w = ref_d00_o ; ref_pad_r09_w = ref_d00_o ;
                                                    ref_pad_r10_w = ref_d00_o ; ref_pad_r11_w = ref_d00_o ;
                                                    ref_pad_r12_w = ref_d00_o ; ref_pad_r13_w = ref_d00_o ;
                                                    ref_pad_r14_w = ref_d00_o ; ref_pad_r15_w = ref_d00_o ;
                            end
                          endcase
      end
      `SIZE_32 : begin    casez( {pu_rt_exist_r,pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0]} )
                            12'b1???????_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                         ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                         ref_pad_r04_w = ref_r04_o ; ref_pad_r05_w = ref_r05_o ;
                                                         ref_pad_r06_w = ref_r06_o ; ref_pad_r07_w = ref_r07_o ;
                                                         ref_pad_r08_w = ref_r08_o ; ref_pad_r09_w = ref_r09_o ;
                                                         ref_pad_r10_w = ref_r10_o ; ref_pad_r11_w = ref_r11_o ;
                                                         ref_pad_r12_w = ref_r12_o ; ref_pad_r13_w = ref_r13_o ;
                                                         ref_pad_r14_w = ref_r14_o ; ref_pad_r15_w = ref_r15_o ;
                                                         ref_pad_r16_w = ref_r16_o ; ref_pad_r17_w = ref_r17_o ;
                                                         ref_pad_r18_w = ref_r18_o ; ref_pad_r19_w = ref_r19_o ;
                                                         ref_pad_r20_w = ref_r20_o ; ref_pad_r21_w = ref_r21_o ;
                                                         ref_pad_r22_w = ref_r22_o ; ref_pad_r23_w = ref_r23_o ;
                                                         ref_pad_r24_w = ref_r24_o ; ref_pad_r25_w = ref_r25_o ;
                                                         ref_pad_r26_w = ref_r26_o ; ref_pad_r27_w = ref_r27_o ;
                                                         ref_pad_r28_w = ref_r28_o ; ref_pad_r29_w = ref_r29_o ;
                                                         ref_pad_r30_w = ref_r30_o ; ref_pad_r31_w = ref_r31_o ;
                            end
                            12'b01??????_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                         ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                         ref_pad_r04_w = ref_r04_o ; ref_pad_r05_w = ref_r05_o ;
                                                         ref_pad_r06_w = ref_r06_o ; ref_pad_r07_w = ref_r07_o ;
                                                         ref_pad_r08_w = ref_r08_o ; ref_pad_r09_w = ref_r09_o ;
                                                         ref_pad_r10_w = ref_r10_o ; ref_pad_r11_w = ref_r11_o ;
                                                         ref_pad_r12_w = ref_r12_o ; ref_pad_r13_w = ref_r13_o ;
                                                         ref_pad_r14_w = ref_r14_o ; ref_pad_r15_w = ref_r15_o ;
                                                         ref_pad_r16_w = ref_r16_o ; ref_pad_r17_w = ref_r17_o ;
                                                         ref_pad_r18_w = ref_r18_o ; ref_pad_r19_w = ref_r19_o ;
                                                         ref_pad_r20_w = ref_r20_o ; ref_pad_r21_w = ref_r21_o ;
                                                         ref_pad_r22_w = ref_r22_o ; ref_pad_r23_w = ref_r23_o ;
                                                         ref_pad_r24_w = ref_r24_o ; ref_pad_r25_w = ref_r25_o ;
                                                         ref_pad_r26_w = ref_r26_o ; ref_pad_r27_w = ref_r27_o ;
                                                         ref_pad_r28_w = ref_r27_o ; ref_pad_r29_w = ref_r27_o ;
                                                         ref_pad_r30_w = ref_r27_o ; ref_pad_r31_w = ref_r27_o ;
                            end
                            12'b001?????_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                         ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                         ref_pad_r04_w = ref_r04_o ; ref_pad_r05_w = ref_r05_o ;
                                                         ref_pad_r06_w = ref_r06_o ; ref_pad_r07_w = ref_r07_o ;
                                                         ref_pad_r08_w = ref_r08_o ; ref_pad_r09_w = ref_r09_o ;
                                                         ref_pad_r10_w = ref_r10_o ; ref_pad_r11_w = ref_r11_o ;
                                                         ref_pad_r12_w = ref_r12_o ; ref_pad_r13_w = ref_r13_o ;
                                                         ref_pad_r14_w = ref_r14_o ; ref_pad_r15_w = ref_r15_o ;
                                                         ref_pad_r16_w = ref_r16_o ; ref_pad_r17_w = ref_r17_o ;
                                                         ref_pad_r18_w = ref_r18_o ; ref_pad_r19_w = ref_r19_o ;
                                                         ref_pad_r20_w = ref_r20_o ; ref_pad_r21_w = ref_r21_o ;
                                                         ref_pad_r22_w = ref_r22_o ; ref_pad_r23_w = ref_r23_o ;
                                                         ref_pad_r24_w = ref_r23_o ; ref_pad_r25_w = ref_r23_o ;
                                                         ref_pad_r26_w = ref_r23_o ; ref_pad_r27_w = ref_r23_o ;
                                                         ref_pad_r28_w = ref_r23_o ; ref_pad_r29_w = ref_r23_o ;
                                                         ref_pad_r30_w = ref_r23_o ; ref_pad_r31_w = ref_r23_o ;
                            end
                            12'b0001????_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                         ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                         ref_pad_r04_w = ref_r04_o ; ref_pad_r05_w = ref_r05_o ;
                                                         ref_pad_r06_w = ref_r06_o ; ref_pad_r07_w = ref_r07_o ;
                                                         ref_pad_r08_w = ref_r08_o ; ref_pad_r09_w = ref_r09_o ;
                                                         ref_pad_r10_w = ref_r10_o ; ref_pad_r11_w = ref_r11_o ;
                                                         ref_pad_r12_w = ref_r12_o ; ref_pad_r13_w = ref_r13_o ;
                                                         ref_pad_r14_w = ref_r14_o ; ref_pad_r15_w = ref_r15_o ;
                                                         ref_pad_r16_w = ref_r16_o ; ref_pad_r17_w = ref_r17_o ;
                                                         ref_pad_r18_w = ref_r18_o ; ref_pad_r19_w = ref_r19_o ;
                                                         ref_pad_r20_w = ref_r19_o ; ref_pad_r21_w = ref_r19_o ;
                                                         ref_pad_r22_w = ref_r19_o ; ref_pad_r23_w = ref_r19_o ;
                                                         ref_pad_r24_w = ref_r19_o ; ref_pad_r25_w = ref_r19_o ;
                                                         ref_pad_r26_w = ref_r19_o ; ref_pad_r27_w = ref_r19_o ;
                                                         ref_pad_r28_w = ref_r19_o ; ref_pad_r29_w = ref_r19_o ;
                                                         ref_pad_r30_w = ref_r19_o ; ref_pad_r31_w = ref_r19_o ;
                            end
                            12'b00001???_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                         ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                         ref_pad_r04_w = ref_r04_o ; ref_pad_r05_w = ref_r05_o ;
                                                         ref_pad_r06_w = ref_r06_o ; ref_pad_r07_w = ref_r07_o ;
                                                         ref_pad_r08_w = ref_r08_o ; ref_pad_r09_w = ref_r09_o ;
                                                         ref_pad_r10_w = ref_r10_o ; ref_pad_r11_w = ref_r11_o ;
                                                         ref_pad_r12_w = ref_r12_o ; ref_pad_r13_w = ref_r13_o ;
                                                         ref_pad_r14_w = ref_r14_o ; ref_pad_r15_w = ref_r15_o ;
                                                         ref_pad_r16_w = ref_r15_o ; ref_pad_r17_w = ref_r15_o ;
                                                         ref_pad_r18_w = ref_r15_o ; ref_pad_r19_w = ref_r15_o ;
                                                         ref_pad_r20_w = ref_r15_o ; ref_pad_r21_w = ref_r15_o ;
                                                         ref_pad_r22_w = ref_r15_o ; ref_pad_r23_w = ref_r15_o ;
                                                         ref_pad_r24_w = ref_r15_o ; ref_pad_r25_w = ref_r15_o ;
                                                         ref_pad_r26_w = ref_r15_o ; ref_pad_r27_w = ref_r15_o ;
                                                         ref_pad_r28_w = ref_r15_o ; ref_pad_r29_w = ref_r15_o ;
                                                         ref_pad_r30_w = ref_r15_o ; ref_pad_r31_w = ref_r15_o ;
                            end
                            12'b000001??_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                         ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                         ref_pad_r04_w = ref_r04_o ; ref_pad_r05_w = ref_r05_o ;
                                                         ref_pad_r06_w = ref_r06_o ; ref_pad_r07_w = ref_r07_o ;
                                                         ref_pad_r08_w = ref_r08_o ; ref_pad_r09_w = ref_r09_o ;
                                                         ref_pad_r10_w = ref_r10_o ; ref_pad_r11_w = ref_r11_o ;
                                                         ref_pad_r12_w = ref_r11_o ; ref_pad_r13_w = ref_r11_o ;
                                                         ref_pad_r14_w = ref_r11_o ; ref_pad_r15_w = ref_r11_o ;
                                                         ref_pad_r16_w = ref_r11_o ; ref_pad_r17_w = ref_r11_o ;
                                                         ref_pad_r18_w = ref_r11_o ; ref_pad_r19_w = ref_r11_o ;
                                                         ref_pad_r20_w = ref_r11_o ; ref_pad_r21_w = ref_r11_o ;
                                                         ref_pad_r22_w = ref_r11_o ; ref_pad_r23_w = ref_r11_o ;
                                                         ref_pad_r24_w = ref_r11_o ; ref_pad_r25_w = ref_r11_o ;
                                                         ref_pad_r26_w = ref_r11_o ; ref_pad_r27_w = ref_r11_o ;
                                                         ref_pad_r28_w = ref_r11_o ; ref_pad_r29_w = ref_r11_o ;
                                                         ref_pad_r30_w = ref_r11_o ; ref_pad_r31_w = ref_r11_o ;
                            end
                            12'b0000001?_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                         ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                         ref_pad_r04_w = ref_r04_o ; ref_pad_r05_w = ref_r05_o ;
                                                         ref_pad_r06_w = ref_r06_o ; ref_pad_r07_w = ref_r07_o ;
                                                         ref_pad_r08_w = ref_r07_o ; ref_pad_r09_w = ref_r07_o ;
                                                         ref_pad_r10_w = ref_r07_o ; ref_pad_r11_w = ref_r07_o ;
                                                         ref_pad_r12_w = ref_r07_o ; ref_pad_r13_w = ref_r07_o ;
                                                         ref_pad_r14_w = ref_r07_o ; ref_pad_r15_w = ref_r07_o ;
                                                         ref_pad_r16_w = ref_r07_o ; ref_pad_r17_w = ref_r07_o ;
                                                         ref_pad_r18_w = ref_r07_o ; ref_pad_r19_w = ref_r07_o ;
                                                         ref_pad_r20_w = ref_r07_o ; ref_pad_r21_w = ref_r07_o ;
                                                         ref_pad_r22_w = ref_r07_o ; ref_pad_r23_w = ref_r07_o ;
                                                         ref_pad_r24_w = ref_r07_o ; ref_pad_r25_w = ref_r07_o ;
                                                         ref_pad_r26_w = ref_r07_o ; ref_pad_r27_w = ref_r07_o ;
                                                         ref_pad_r28_w = ref_r07_o ; ref_pad_r29_w = ref_r07_o ;
                                                         ref_pad_r30_w = ref_r07_o ; ref_pad_r31_w = ref_r07_o ;
                            end
                            12'b00000001_???? : begin    ref_pad_r00_w = ref_r00_o ; ref_pad_r01_w = ref_r01_o ;
                                                         ref_pad_r02_w = ref_r02_o ; ref_pad_r03_w = ref_r03_o ;
                                                         ref_pad_r04_w = ref_r03_o ; ref_pad_r05_w = ref_r03_o ;
                                                         ref_pad_r06_w = ref_r03_o ; ref_pad_r07_w = ref_r03_o ;
                                                         ref_pad_r08_w = ref_r03_o ; ref_pad_r09_w = ref_r03_o ;
                                                         ref_pad_r10_w = ref_r03_o ; ref_pad_r11_w = ref_r03_o ;
                                                         ref_pad_r12_w = ref_r03_o ; ref_pad_r13_w = ref_r03_o ;
                                                         ref_pad_r14_w = ref_r03_o ; ref_pad_r15_w = ref_r03_o ;
                                                         ref_pad_r16_w = ref_r03_o ; ref_pad_r17_w = ref_r03_o ;
                                                         ref_pad_r18_w = ref_r03_o ; ref_pad_r19_w = ref_r03_o ;
                                                         ref_pad_r20_w = ref_r03_o ; ref_pad_r21_w = ref_r03_o ;
                                                         ref_pad_r22_w = ref_r03_o ; ref_pad_r23_w = ref_r03_o ;
                                                         ref_pad_r24_w = ref_r03_o ; ref_pad_r25_w = ref_r03_o ;
                                                         ref_pad_r26_w = ref_r03_o ; ref_pad_r27_w = ref_r03_o ;
                                                         ref_pad_r28_w = ref_r03_o ; ref_pad_r29_w = ref_r03_o ;
                                                         ref_pad_r30_w = ref_r03_o ; ref_pad_r31_w = ref_r03_o ;
                            end
                            12'b00000000_1??? : begin    ref_pad_r00_w = ref_t31_o ; ref_pad_r01_w = ref_t31_o ;
                                                         ref_pad_r02_w = ref_t31_o ; ref_pad_r03_w = ref_t31_o ;
                                                         ref_pad_r04_w = ref_t31_o ; ref_pad_r05_w = ref_t31_o ;
                                                         ref_pad_r06_w = ref_t31_o ; ref_pad_r07_w = ref_t31_o ;
                                                         ref_pad_r08_w = ref_t31_o ; ref_pad_r09_w = ref_t31_o ;
                                                         ref_pad_r10_w = ref_t31_o ; ref_pad_r11_w = ref_t31_o ;
                                                         ref_pad_r12_w = ref_t31_o ; ref_pad_r13_w = ref_t31_o ;
                                                         ref_pad_r14_w = ref_t31_o ; ref_pad_r15_w = ref_t31_o ;
                                                         ref_pad_r16_w = ref_t31_o ; ref_pad_r17_w = ref_t31_o ;
                                                         ref_pad_r18_w = ref_t31_o ; ref_pad_r19_w = ref_t31_o ;
                                                         ref_pad_r20_w = ref_t31_o ; ref_pad_r21_w = ref_t31_o ;
                                                         ref_pad_r22_w = ref_t31_o ; ref_pad_r23_w = ref_t31_o ;
                                                         ref_pad_r24_w = ref_t31_o ; ref_pad_r25_w = ref_t31_o ;
                                                         ref_pad_r26_w = ref_t31_o ; ref_pad_r27_w = ref_t31_o ;
                                                         ref_pad_r28_w = ref_t31_o ; ref_pad_r29_w = ref_t31_o ;
                                                         ref_pad_r30_w = ref_t31_o ; ref_pad_r31_w = ref_t31_o ;
                            end
                            12'b00000000_01?? : begin    ref_pad_r00_w = ref_tl_o  ; ref_pad_r01_w = ref_tl_o  ;
                                                         ref_pad_r02_w = ref_tl_o  ; ref_pad_r03_w = ref_tl_o  ;
                                                         ref_pad_r04_w = ref_tl_o  ; ref_pad_r05_w = ref_tl_o  ;
                                                         ref_pad_r06_w = ref_tl_o  ; ref_pad_r07_w = ref_tl_o  ;
                                                         ref_pad_r08_w = ref_tl_o  ; ref_pad_r09_w = ref_tl_o  ;
                                                         ref_pad_r10_w = ref_tl_o  ; ref_pad_r11_w = ref_tl_o  ;
                                                         ref_pad_r12_w = ref_tl_o  ; ref_pad_r13_w = ref_tl_o  ;
                                                         ref_pad_r14_w = ref_tl_o  ; ref_pad_r15_w = ref_tl_o  ;
                                                         ref_pad_r16_w = ref_tl_o  ; ref_pad_r17_w = ref_tl_o  ;
                                                         ref_pad_r18_w = ref_tl_o  ; ref_pad_r19_w = ref_tl_o  ;
                                                         ref_pad_r20_w = ref_tl_o  ; ref_pad_r21_w = ref_tl_o  ;
                                                         ref_pad_r22_w = ref_tl_o  ; ref_pad_r23_w = ref_tl_o  ;
                                                         ref_pad_r24_w = ref_tl_o  ; ref_pad_r25_w = ref_tl_o  ;
                                                         ref_pad_r26_w = ref_tl_o  ; ref_pad_r27_w = ref_tl_o  ;
                                                         ref_pad_r28_w = ref_tl_o  ; ref_pad_r29_w = ref_tl_o  ;
                                                         ref_pad_r30_w = ref_tl_o  ; ref_pad_r31_w = ref_tl_o  ;
                            end
                            12'b00000000_001? : begin    ref_pad_r00_w = ref_l00_o ; ref_pad_r01_w = ref_l00_o ;
                                                         ref_pad_r02_w = ref_l00_o ; ref_pad_r03_w = ref_l00_o ;
                                                         ref_pad_r04_w = ref_l00_o ; ref_pad_r05_w = ref_l00_o ;
                                                         ref_pad_r06_w = ref_l00_o ; ref_pad_r07_w = ref_l00_o ;
                                                         ref_pad_r08_w = ref_l00_o ; ref_pad_r09_w = ref_l00_o ;
                                                         ref_pad_r10_w = ref_l00_o ; ref_pad_r11_w = ref_l00_o ;
                                                         ref_pad_r12_w = ref_l00_o ; ref_pad_r13_w = ref_l00_o ;
                                                         ref_pad_r14_w = ref_l00_o ; ref_pad_r15_w = ref_l00_o ;
                                                         ref_pad_r16_w = ref_l00_o ; ref_pad_r17_w = ref_l00_o ;
                                                         ref_pad_r18_w = ref_l00_o ; ref_pad_r19_w = ref_l00_o ;
                                                         ref_pad_r20_w = ref_l00_o ; ref_pad_r21_w = ref_l00_o ;
                                                         ref_pad_r22_w = ref_l00_o ; ref_pad_r23_w = ref_l00_o ;
                                                         ref_pad_r24_w = ref_l00_o ; ref_pad_r25_w = ref_l00_o ;
                                                         ref_pad_r26_w = ref_l00_o ; ref_pad_r27_w = ref_l00_o ;
                                                         ref_pad_r28_w = ref_l00_o ; ref_pad_r29_w = ref_l00_o ;
                                                         ref_pad_r30_w = ref_l00_o ; ref_pad_r31_w = ref_l00_o ;
                            end
                            12'b00000000_0001 : begin    ref_pad_r00_w = ref_d00_o ; ref_pad_r01_w = ref_d00_o ;
                                                         ref_pad_r02_w = ref_d00_o ; ref_pad_r03_w = ref_d00_o ;
                                                         ref_pad_r04_w = ref_d00_o ; ref_pad_r05_w = ref_d00_o ;
                                                         ref_pad_r06_w = ref_d00_o ; ref_pad_r07_w = ref_d00_o ;
                                                         ref_pad_r08_w = ref_d00_o ; ref_pad_r09_w = ref_d00_o ;
                                                         ref_pad_r10_w = ref_d00_o ; ref_pad_r11_w = ref_d00_o ;
                                                         ref_pad_r12_w = ref_d00_o ; ref_pad_r13_w = ref_d00_o ;
                                                         ref_pad_r14_w = ref_d00_o ; ref_pad_r15_w = ref_d00_o ;
                                                         ref_pad_r16_w = ref_d00_o ; ref_pad_r17_w = ref_d00_o ;
                                                         ref_pad_r18_w = ref_d00_o ; ref_pad_r19_w = ref_d00_o ;
                                                         ref_pad_r20_w = ref_d00_o ; ref_pad_r21_w = ref_d00_o ;
                                                         ref_pad_r22_w = ref_d00_o ; ref_pad_r23_w = ref_d00_o ;
                                                         ref_pad_r24_w = ref_d00_o ; ref_pad_r25_w = ref_d00_o ;
                                                         ref_pad_r26_w = ref_d00_o ; ref_pad_r27_w = ref_d00_o ;
                                                         ref_pad_r28_w = ref_d00_o ; ref_pad_r29_w = ref_d00_o ;
                                                         ref_pad_r30_w = ref_d00_o ; ref_pad_r31_w = ref_d00_o ;
                            end
                          endcase
      end
    endcase
  end

  // left
  always @(*) begin
    ref_pad_l00_w = 'd128; ref_pad_l01_w = 'd128;
    ref_pad_l02_w = 'd128; ref_pad_l03_w = 'd128;
    ref_pad_l04_w = 'd128; ref_pad_l05_w = 'd128;
    ref_pad_l06_w = 'd128; ref_pad_l07_w = 'd128;
    ref_pad_l08_w = 'd128; ref_pad_l09_w = 'd128;
    ref_pad_l10_w = 'd128; ref_pad_l11_w = 'd128;
    ref_pad_l12_w = 'd128; ref_pad_l13_w = 'd128;
    ref_pad_l14_w = 'd128; ref_pad_l15_w = 'd128;
    ref_pad_l16_w = 'd128; ref_pad_l17_w = 'd128;
    ref_pad_l18_w = 'd128; ref_pad_l19_w = 'd128;
    ref_pad_l20_w = 'd128; ref_pad_l21_w = 'd128;
    ref_pad_l22_w = 'd128; ref_pad_l23_w = 'd128;
    ref_pad_l24_w = 'd128; ref_pad_l25_w = 'd128;
    ref_pad_l26_w = 'd128; ref_pad_l27_w = 'd128;
    ref_pad_l28_w = 'd128; ref_pad_l29_w = 'd128;
    ref_pad_l30_w = 'd128; ref_pad_l31_w = 'd128;
    case( size_i )
      `SIZE_04 : begin    casez( {pu_lf_exist_r,pu_dn_exist_r[0],pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                            5'b1???? : begin    ref_pad_l00_w = ref_l00_o ; ref_pad_l01_w = ref_l01_o ;
                                                ref_pad_l02_w = ref_l02_o ; ref_pad_l03_w = ref_l03_o ;
                            end
                            5'b01??? : begin    ref_pad_l00_w = ref_d00_o ; ref_pad_l01_w = ref_d00_o ;
                                                ref_pad_l02_w = ref_d00_o ; ref_pad_l03_w = ref_d00_o ;
                            end
                            5'b001?? : begin    ref_pad_l00_w = ref_tl_o  ; ref_pad_l01_w = ref_tl_o  ;
                                                ref_pad_l02_w = ref_tl_o  ; ref_pad_l03_w = ref_tl_o  ;
                            end
                            5'b0001? : begin    ref_pad_l00_w = ref_t00_o ; ref_pad_l01_w = ref_t00_o ;
                                                ref_pad_l02_w = ref_t00_o ; ref_pad_l03_w = ref_t00_o ;
                            end
                            5'b00001 : begin    ref_pad_l00_w = ref_r00_o ; ref_pad_l01_w = ref_r00_o ;
                                                ref_pad_l02_w = ref_r00_o ; ref_pad_l03_w = ref_r00_o ;
                            end
                          endcase
      end
      `SIZE_08 : begin    casez( {pu_lf_exist_r,pu_dn_exist_r[0],pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                            5'b1???? : begin    ref_pad_l00_w = ref_l00_o ; ref_pad_l01_w = ref_l01_o ;
                                                ref_pad_l02_w = ref_l02_o ; ref_pad_l03_w = ref_l03_o ;
                                                ref_pad_l04_w = ref_l04_o ; ref_pad_l05_w = ref_l05_o ;
                                                ref_pad_l06_w = ref_l06_o ; ref_pad_l07_w = ref_l07_o ;
                            end
                            5'b01??? : begin    ref_pad_l00_w = ref_d00_o ; ref_pad_l01_w = ref_d00_o ;
                                                ref_pad_l02_w = ref_d00_o ; ref_pad_l03_w = ref_d00_o ;
                                                ref_pad_l04_w = ref_d00_o ; ref_pad_l05_w = ref_d00_o ;
                                                ref_pad_l06_w = ref_d00_o ; ref_pad_l07_w = ref_d00_o ;
                            end
                            5'b001?? : begin    ref_pad_l00_w = ref_tl_o  ; ref_pad_l01_w = ref_tl_o  ;
                                                ref_pad_l02_w = ref_tl_o  ; ref_pad_l03_w = ref_tl_o  ;
                                                ref_pad_l04_w = ref_tl_o  ; ref_pad_l05_w = ref_tl_o  ;
                                                ref_pad_l06_w = ref_tl_o  ; ref_pad_l07_w = ref_tl_o  ;
                            end
                            5'b0001? : begin    ref_pad_l00_w = ref_t00_o ; ref_pad_l01_w = ref_t00_o ;
                                                ref_pad_l02_w = ref_t00_o ; ref_pad_l03_w = ref_t00_o ;
                                                ref_pad_l04_w = ref_t00_o ; ref_pad_l05_w = ref_t00_o ;
                                                ref_pad_l06_w = ref_t00_o ; ref_pad_l07_w = ref_t00_o ;
                            end
                            5'b00001 : begin    ref_pad_l00_w = ref_r00_o ; ref_pad_l01_w = ref_r00_o ;
                                                ref_pad_l02_w = ref_r00_o ; ref_pad_l03_w = ref_r00_o ;
                                                ref_pad_l04_w = ref_r00_o ; ref_pad_l05_w = ref_r00_o ;
                                                ref_pad_l06_w = ref_r00_o ; ref_pad_l07_w = ref_r00_o ;
                            end
                          endcase
      end
      `SIZE_16 : begin    casez( {pu_lf_exist_r,pu_dn_exist_r[0],pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                            5'b1???? : begin    ref_pad_l00_w = ref_l00_o ; ref_pad_l01_w = ref_l01_o ;
                                                ref_pad_l02_w = ref_l02_o ; ref_pad_l03_w = ref_l03_o ;
                                                ref_pad_l04_w = ref_l04_o ; ref_pad_l05_w = ref_l05_o ;
                                                ref_pad_l06_w = ref_l06_o ; ref_pad_l07_w = ref_l07_o ;
                                                ref_pad_l08_w = ref_l08_o ; ref_pad_l09_w = ref_l09_o ;
                                                ref_pad_l10_w = ref_l10_o ; ref_pad_l11_w = ref_l11_o ;
                                                ref_pad_l12_w = ref_l12_o ; ref_pad_l13_w = ref_l13_o ;
                                                ref_pad_l14_w = ref_l14_o ; ref_pad_l15_w = ref_l15_o ;
                            end
                            5'b01??? : begin    ref_pad_l00_w = ref_d00_o ; ref_pad_l01_w = ref_d00_o ;
                                                ref_pad_l02_w = ref_d00_o ; ref_pad_l03_w = ref_d00_o ;
                                                ref_pad_l04_w = ref_d00_o ; ref_pad_l05_w = ref_d00_o ;
                                                ref_pad_l06_w = ref_d00_o ; ref_pad_l07_w = ref_d00_o ;
                                                ref_pad_l08_w = ref_d00_o ; ref_pad_l09_w = ref_d00_o ;
                                                ref_pad_l10_w = ref_d00_o ; ref_pad_l11_w = ref_d00_o ;
                                                ref_pad_l12_w = ref_d00_o ; ref_pad_l13_w = ref_d00_o ;
                                                ref_pad_l14_w = ref_d00_o ; ref_pad_l15_w = ref_d00_o ;
                            end
                            5'b001?? : begin    ref_pad_l00_w = ref_tl_o  ; ref_pad_l01_w = ref_tl_o  ;
                                                ref_pad_l02_w = ref_tl_o  ; ref_pad_l03_w = ref_tl_o  ;
                                                ref_pad_l04_w = ref_tl_o  ; ref_pad_l05_w = ref_tl_o  ;
                                                ref_pad_l06_w = ref_tl_o  ; ref_pad_l07_w = ref_tl_o  ;
                                                ref_pad_l08_w = ref_tl_o  ; ref_pad_l09_w = ref_tl_o  ;
                                                ref_pad_l10_w = ref_tl_o  ; ref_pad_l11_w = ref_tl_o  ;
                                                ref_pad_l12_w = ref_tl_o  ; ref_pad_l13_w = ref_tl_o  ;
                                                ref_pad_l14_w = ref_tl_o  ; ref_pad_l15_w = ref_tl_o  ;
                            end
                            5'b0001? : begin    ref_pad_l00_w = ref_t00_o ; ref_pad_l01_w = ref_t00_o ;
                                                ref_pad_l02_w = ref_t00_o ; ref_pad_l03_w = ref_t00_o ;
                                                ref_pad_l04_w = ref_t00_o ; ref_pad_l05_w = ref_t00_o ;
                                                ref_pad_l06_w = ref_t00_o ; ref_pad_l07_w = ref_t00_o ;
                                                ref_pad_l08_w = ref_t00_o ; ref_pad_l09_w = ref_t00_o ;
                                                ref_pad_l10_w = ref_t00_o ; ref_pad_l11_w = ref_t00_o ;
                                                ref_pad_l12_w = ref_t00_o ; ref_pad_l13_w = ref_t00_o ;
                                                ref_pad_l14_w = ref_t00_o ; ref_pad_l15_w = ref_t00_o ;
                            end
                            5'b00001 : begin    ref_pad_l00_w = ref_r00_o ; ref_pad_l01_w = ref_r00_o ;
                                                ref_pad_l02_w = ref_r00_o ; ref_pad_l03_w = ref_r00_o ;
                                                ref_pad_l04_w = ref_r00_o ; ref_pad_l05_w = ref_r00_o ;
                                                ref_pad_l06_w = ref_r00_o ; ref_pad_l07_w = ref_r00_o ;
                                                ref_pad_l08_w = ref_r00_o ; ref_pad_l09_w = ref_r00_o ;
                                                ref_pad_l10_w = ref_r00_o ; ref_pad_l11_w = ref_r00_o ;
                                                ref_pad_l12_w = ref_r00_o ; ref_pad_l13_w = ref_r00_o ;
                                                ref_pad_l14_w = ref_r00_o ; ref_pad_l15_w = ref_r00_o ;
                            end
                          endcase
      end
      `SIZE_32 : begin    casez( {pu_lf_exist_r,pu_dn_exist_r[0],pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                            5'b1???? : begin    ref_pad_l00_w = ref_l00_o ; ref_pad_l01_w = ref_l01_o ;
                                                ref_pad_l02_w = ref_l02_o ; ref_pad_l03_w = ref_l03_o ;
                                                ref_pad_l04_w = ref_l04_o ; ref_pad_l05_w = ref_l05_o ;
                                                ref_pad_l06_w = ref_l06_o ; ref_pad_l07_w = ref_l07_o ;
                                                ref_pad_l08_w = ref_l08_o ; ref_pad_l09_w = ref_l09_o ;
                                                ref_pad_l10_w = ref_l10_o ; ref_pad_l11_w = ref_l11_o ;
                                                ref_pad_l12_w = ref_l12_o ; ref_pad_l13_w = ref_l13_o ;
                                                ref_pad_l14_w = ref_l14_o ; ref_pad_l15_w = ref_l15_o ;
                                                ref_pad_l16_w = ref_l16_o ; ref_pad_l17_w = ref_l17_o ;
                                                ref_pad_l18_w = ref_l18_o ; ref_pad_l19_w = ref_l19_o ;
                                                ref_pad_l20_w = ref_l20_o ; ref_pad_l21_w = ref_l21_o ;
                                                ref_pad_l22_w = ref_l22_o ; ref_pad_l23_w = ref_l23_o ;
                                                ref_pad_l24_w = ref_l24_o ; ref_pad_l25_w = ref_l25_o ;
                                                ref_pad_l26_w = ref_l26_o ; ref_pad_l27_w = ref_l27_o ;
                                                ref_pad_l28_w = ref_l28_o ; ref_pad_l29_w = ref_l29_o ;
                                                ref_pad_l30_w = ref_l30_o ; ref_pad_l31_w = ref_l31_o ;
                            end
                            5'b01??? : begin    ref_pad_l00_w = ref_d00_o ; ref_pad_l01_w = ref_d00_o ;
                                                ref_pad_l02_w = ref_d00_o ; ref_pad_l03_w = ref_d00_o ;
                                                ref_pad_l04_w = ref_d00_o ; ref_pad_l05_w = ref_d00_o ;
                                                ref_pad_l06_w = ref_d00_o ; ref_pad_l07_w = ref_d00_o ;
                                                ref_pad_l08_w = ref_d00_o ; ref_pad_l09_w = ref_d00_o ;
                                                ref_pad_l10_w = ref_d00_o ; ref_pad_l11_w = ref_d00_o ;
                                                ref_pad_l12_w = ref_d00_o ; ref_pad_l13_w = ref_d00_o ;
                                                ref_pad_l14_w = ref_d00_o ; ref_pad_l15_w = ref_d00_o ;
                                                ref_pad_l16_w = ref_d00_o ; ref_pad_l17_w = ref_d00_o ;
                                                ref_pad_l18_w = ref_d00_o ; ref_pad_l19_w = ref_d00_o ;
                                                ref_pad_l20_w = ref_d00_o ; ref_pad_l21_w = ref_d00_o ;
                                                ref_pad_l22_w = ref_d00_o ; ref_pad_l23_w = ref_d00_o ;
                                                ref_pad_l24_w = ref_d00_o ; ref_pad_l25_w = ref_d00_o ;
                                                ref_pad_l26_w = ref_d00_o ; ref_pad_l27_w = ref_d00_o ;
                                                ref_pad_l28_w = ref_d00_o ; ref_pad_l29_w = ref_d00_o ;
                                                ref_pad_l30_w = ref_d00_o ; ref_pad_l31_w = ref_d00_o ;
                            end
                            5'b001?? : begin    ref_pad_l00_w = ref_tl_o  ; ref_pad_l01_w = ref_tl_o  ;
                                                ref_pad_l02_w = ref_tl_o  ; ref_pad_l03_w = ref_tl_o  ;
                                                ref_pad_l04_w = ref_tl_o  ; ref_pad_l05_w = ref_tl_o  ;
                                                ref_pad_l06_w = ref_tl_o  ; ref_pad_l07_w = ref_tl_o  ;
                                                ref_pad_l08_w = ref_tl_o  ; ref_pad_l09_w = ref_tl_o  ;
                                                ref_pad_l10_w = ref_tl_o  ; ref_pad_l11_w = ref_tl_o  ;
                                                ref_pad_l12_w = ref_tl_o  ; ref_pad_l13_w = ref_tl_o  ;
                                                ref_pad_l14_w = ref_tl_o  ; ref_pad_l15_w = ref_tl_o  ;
                                                ref_pad_l16_w = ref_tl_o  ; ref_pad_l17_w = ref_tl_o  ;
                                                ref_pad_l18_w = ref_tl_o  ; ref_pad_l19_w = ref_tl_o  ;
                                                ref_pad_l20_w = ref_tl_o  ; ref_pad_l21_w = ref_tl_o  ;
                                                ref_pad_l22_w = ref_tl_o  ; ref_pad_l23_w = ref_tl_o  ;
                                                ref_pad_l24_w = ref_tl_o  ; ref_pad_l25_w = ref_tl_o  ;
                                                ref_pad_l26_w = ref_tl_o  ; ref_pad_l27_w = ref_tl_o  ;
                                                ref_pad_l28_w = ref_tl_o  ; ref_pad_l29_w = ref_tl_o  ;
                                                ref_pad_l30_w = ref_tl_o  ; ref_pad_l31_w = ref_tl_o  ;
                            end
                            5'b0001? : begin    ref_pad_l00_w = ref_t00_o ; ref_pad_l01_w = ref_t00_o ;
                                                ref_pad_l02_w = ref_t00_o ; ref_pad_l03_w = ref_t00_o ;
                                                ref_pad_l04_w = ref_t00_o ; ref_pad_l05_w = ref_t00_o ;
                                                ref_pad_l06_w = ref_t00_o ; ref_pad_l07_w = ref_t00_o ;
                                                ref_pad_l08_w = ref_t00_o ; ref_pad_l09_w = ref_t00_o ;
                                                ref_pad_l10_w = ref_t00_o ; ref_pad_l11_w = ref_t00_o ;
                                                ref_pad_l12_w = ref_t00_o ; ref_pad_l13_w = ref_t00_o ;
                                                ref_pad_l14_w = ref_t00_o ; ref_pad_l15_w = ref_t00_o ;
                                                ref_pad_l16_w = ref_t00_o ; ref_pad_l17_w = ref_t00_o ;
                                                ref_pad_l18_w = ref_t00_o ; ref_pad_l19_w = ref_t00_o ;
                                                ref_pad_l20_w = ref_t00_o ; ref_pad_l21_w = ref_t00_o ;
                                                ref_pad_l22_w = ref_t00_o ; ref_pad_l23_w = ref_t00_o ;
                                                ref_pad_l24_w = ref_t00_o ; ref_pad_l25_w = ref_t00_o ;
                                                ref_pad_l26_w = ref_t00_o ; ref_pad_l27_w = ref_t00_o ;
                                                ref_pad_l28_w = ref_t00_o ; ref_pad_l29_w = ref_t00_o ;
                                                ref_pad_l30_w = ref_t00_o ; ref_pad_l31_w = ref_t00_o ;
                            end
                            5'b00001 : begin    ref_pad_l00_w = ref_r00_o ; ref_pad_l01_w = ref_r00_o ;
                                                ref_pad_l02_w = ref_r00_o ; ref_pad_l03_w = ref_r00_o ;
                                                ref_pad_l04_w = ref_r00_o ; ref_pad_l05_w = ref_r00_o ;
                                                ref_pad_l06_w = ref_r00_o ; ref_pad_l07_w = ref_r00_o ;
                                                ref_pad_l08_w = ref_r00_o ; ref_pad_l09_w = ref_r00_o ;
                                                ref_pad_l10_w = ref_r00_o ; ref_pad_l11_w = ref_r00_o ;
                                                ref_pad_l12_w = ref_r00_o ; ref_pad_l13_w = ref_r00_o ;
                                                ref_pad_l14_w = ref_r00_o ; ref_pad_l15_w = ref_r00_o ;
                                                ref_pad_l16_w = ref_r00_o ; ref_pad_l17_w = ref_r00_o ;
                                                ref_pad_l18_w = ref_r00_o ; ref_pad_l19_w = ref_r00_o ;
                                                ref_pad_l20_w = ref_r00_o ; ref_pad_l21_w = ref_r00_o ;
                                                ref_pad_l22_w = ref_r00_o ; ref_pad_l23_w = ref_r00_o ;
                                                ref_pad_l24_w = ref_r00_o ; ref_pad_l25_w = ref_r00_o ;
                                                ref_pad_l26_w = ref_r00_o ; ref_pad_l27_w = ref_r00_o ;
                                                ref_pad_l28_w = ref_r00_o ; ref_pad_l29_w = ref_r00_o ;
                                                ref_pad_l30_w = ref_r00_o ; ref_pad_l31_w = ref_r00_o ;
                            end
                          endcase
      end
    endcase
  end

  // down
  always @(*) begin
    ref_pad_d00_w = 128 ; ref_pad_d01_w = 128 ;
    ref_pad_d02_w = 128 ; ref_pad_d03_w = 128 ;
    ref_pad_d04_w = 128 ; ref_pad_d05_w = 128 ;
    ref_pad_d06_w = 128 ; ref_pad_d07_w = 128 ;
    ref_pad_d08_w = 128 ; ref_pad_d09_w = 128 ;
    ref_pad_d10_w = 128 ; ref_pad_d11_w = 128 ;
    ref_pad_d12_w = 128 ; ref_pad_d13_w = 128 ;
    ref_pad_d14_w = 128 ; ref_pad_d15_w = 128 ;
    ref_pad_d16_w = 128 ; ref_pad_d17_w = 128 ;
    ref_pad_d18_w = 128 ; ref_pad_d19_w = 128 ;
    ref_pad_d20_w = 128 ; ref_pad_d21_w = 128 ;
    ref_pad_d22_w = 128 ; ref_pad_d23_w = 128 ;
    ref_pad_d24_w = 128 ; ref_pad_d25_w = 128 ;
    ref_pad_d26_w = 128 ; ref_pad_d27_w = 128 ;
    ref_pad_d28_w = 128 ; ref_pad_d29_w = 128 ;
    ref_pad_d30_w = 128 ; ref_pad_d31_w = 128 ;
    case( size_i )
      `SIZE_04 : begin    casez( {pu_dn_exist_r[0],pu_lf_exist_r,pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                            5'b1???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                            end
                            5'b01??? : begin    ref_pad_d00_w = ref_l03_o ; ref_pad_d01_w = ref_l03_o ;
                                                ref_pad_d02_w = ref_l03_o ; ref_pad_d03_w = ref_l03_o ;
                            end
                            5'b001?? : begin    ref_pad_d00_w = ref_tl_o  ; ref_pad_d01_w = ref_tl_o  ;
                                                ref_pad_d02_w = ref_tl_o  ; ref_pad_d03_w = ref_tl_o  ;
                            end
                            5'b0001? : begin    ref_pad_d00_w = ref_t00_o ; ref_pad_d01_w = ref_t00_o ;
                                                ref_pad_d02_w = ref_t00_o ; ref_pad_d03_w = ref_t00_o ;
                            end
                            5'b00001 : begin    ref_pad_d00_w = ref_r00_o ; ref_pad_d01_w = ref_r00_o ;
                                                ref_pad_d02_w = ref_r00_o ; ref_pad_d03_w = ref_r00_o ;
                            end
                          endcase
      end
      `SIZE_08 : begin    casez( {pu_dn_exist_r[1:0],pu_lf_exist_r,pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                            6'b1?_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                  ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                  ref_pad_d04_w = ref_d04_o ; ref_pad_d05_w = ref_d05_o ;
                                                  ref_pad_d06_w = ref_d06_o ; ref_pad_d07_w = ref_d07_o ;
                            end
                            6'b01_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                  ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                  ref_pad_d04_w = ref_d03_o ; ref_pad_d05_w = ref_d03_o ;
                                                  ref_pad_d06_w = ref_d03_o ; ref_pad_d07_w = ref_d03_o ;
                            end
                            6'b00_1??? : begin    ref_pad_d00_w = ref_l07_o ; ref_pad_d01_w = ref_l07_o ;
                                                  ref_pad_d02_w = ref_l07_o ; ref_pad_d03_w = ref_l07_o ;
                                                  ref_pad_d04_w = ref_l07_o ; ref_pad_d05_w = ref_l07_o ;
                                                  ref_pad_d06_w = ref_l07_o ; ref_pad_d07_w = ref_l07_o ;
                            end
                            6'b00_01?? : begin    ref_pad_d00_w = ref_tl_o  ; ref_pad_d01_w = ref_tl_o  ;
                                                  ref_pad_d02_w = ref_tl_o  ; ref_pad_d03_w = ref_tl_o  ;
                                                  ref_pad_d04_w = ref_tl_o  ; ref_pad_d05_w = ref_tl_o  ;
                                                  ref_pad_d06_w = ref_tl_o  ; ref_pad_d07_w = ref_tl_o  ;
                            end
                            6'b00_001? : begin    ref_pad_d00_w = ref_t00_o ; ref_pad_d01_w = ref_t00_o ;
                                                  ref_pad_d02_w = ref_t00_o ; ref_pad_d03_w = ref_t00_o ;
                                                  ref_pad_d04_w = ref_t00_o ; ref_pad_d05_w = ref_t00_o ;
                                                  ref_pad_d06_w = ref_t00_o ; ref_pad_d07_w = ref_t00_o ;

                            end
                            6'b00_0001 : begin    ref_pad_d00_w = ref_r00_o ; ref_pad_d01_w = ref_r00_o ;
                                                  ref_pad_d02_w = ref_r00_o ; ref_pad_d03_w = ref_r00_o ;
                                                  ref_pad_d04_w = ref_r00_o ; ref_pad_d05_w = ref_r00_o ;
                                                  ref_pad_d06_w = ref_r00_o ; ref_pad_d07_w = ref_r00_o ;
                            end
                          endcase
      end
      `SIZE_16 : begin    casez( {pu_dn_exist_r[3:0],pu_lf_exist_r,pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                            8'b1???_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                    ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                    ref_pad_d04_w = ref_d04_o ; ref_pad_d05_w = ref_d05_o ;
                                                    ref_pad_d06_w = ref_d06_o ; ref_pad_d07_w = ref_d07_o ;
                                                    ref_pad_d08_w = ref_d08_o ; ref_pad_d09_w = ref_d09_o ;
                                                    ref_pad_d10_w = ref_d10_o ; ref_pad_d11_w = ref_d11_o ;
                                                    ref_pad_d12_w = ref_d12_o ; ref_pad_d13_w = ref_d13_o ;
                                                    ref_pad_d14_w = ref_d14_o ; ref_pad_d15_w = ref_d15_o ;
                            end
                            8'b01??_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                    ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                    ref_pad_d04_w = ref_d04_o ; ref_pad_d05_w = ref_d05_o ;
                                                    ref_pad_d06_w = ref_d06_o ; ref_pad_d07_w = ref_d07_o ;
                                                    ref_pad_d08_w = ref_d08_o ; ref_pad_d09_w = ref_d09_o ;
                                                    ref_pad_d10_w = ref_d10_o ; ref_pad_d11_w = ref_d11_o ;
                                                    ref_pad_d12_w = ref_d11_o ; ref_pad_d13_w = ref_d11_o ;
                                                    ref_pad_d14_w = ref_d11_o ; ref_pad_d15_w = ref_d11_o ;
                            end
                            8'b001?_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                    ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                    ref_pad_d04_w = ref_d04_o ; ref_pad_d05_w = ref_d05_o ;
                                                    ref_pad_d06_w = ref_d06_o ; ref_pad_d07_w = ref_d07_o ;
                                                    ref_pad_d08_w = ref_d07_o ; ref_pad_d09_w = ref_d07_o ;
                                                    ref_pad_d10_w = ref_d07_o ; ref_pad_d11_w = ref_d07_o ;
                                                    ref_pad_d12_w = ref_d07_o ; ref_pad_d13_w = ref_d07_o ;
                                                    ref_pad_d14_w = ref_d07_o ; ref_pad_d15_w = ref_d07_o ;
                            end
                            8'b0001_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                    ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                    ref_pad_d04_w = ref_d03_o ; ref_pad_d05_w = ref_d03_o ;
                                                    ref_pad_d06_w = ref_d03_o ; ref_pad_d07_w = ref_d03_o ;
                                                    ref_pad_d08_w = ref_d03_o ; ref_pad_d09_w = ref_d03_o ;
                                                    ref_pad_d10_w = ref_d03_o ; ref_pad_d11_w = ref_d03_o ;
                                                    ref_pad_d12_w = ref_d03_o ; ref_pad_d13_w = ref_d03_o ;
                                                    ref_pad_d14_w = ref_d03_o ; ref_pad_d15_w = ref_d03_o ;
                            end
                            8'b0000_1??? : begin    ref_pad_d00_w = ref_l15_o ; ref_pad_d01_w = ref_l15_o ;
                                                    ref_pad_d02_w = ref_l15_o ; ref_pad_d03_w = ref_l15_o ;
                                                    ref_pad_d04_w = ref_l15_o ; ref_pad_d05_w = ref_l15_o ;
                                                    ref_pad_d06_w = ref_l15_o ; ref_pad_d07_w = ref_l15_o ;
                                                    ref_pad_d08_w = ref_l15_o ; ref_pad_d09_w = ref_l15_o ;
                                                    ref_pad_d10_w = ref_l15_o ; ref_pad_d11_w = ref_l15_o ;
                                                    ref_pad_d12_w = ref_l15_o ; ref_pad_d13_w = ref_l15_o ;
                                                    ref_pad_d14_w = ref_l15_o ; ref_pad_d15_w = ref_l15_o ;
                            end
                            8'b0000_01?? : begin    ref_pad_d00_w = ref_tl_o  ; ref_pad_d01_w = ref_tl_o  ;
                                                    ref_pad_d02_w = ref_tl_o  ; ref_pad_d03_w = ref_tl_o  ;
                                                    ref_pad_d04_w = ref_tl_o  ; ref_pad_d05_w = ref_tl_o  ;
                                                    ref_pad_d06_w = ref_tl_o  ; ref_pad_d07_w = ref_tl_o  ;
                                                    ref_pad_d08_w = ref_tl_o  ; ref_pad_d09_w = ref_tl_o  ;
                                                    ref_pad_d10_w = ref_tl_o  ; ref_pad_d11_w = ref_tl_o  ;
                                                    ref_pad_d12_w = ref_tl_o  ; ref_pad_d13_w = ref_tl_o  ;
                                                    ref_pad_d14_w = ref_tl_o  ; ref_pad_d15_w = ref_tl_o  ;
                            end
                            8'b0000_001? : begin    ref_pad_d00_w = ref_t00_o ; ref_pad_d01_w = ref_t00_o ;
                                                    ref_pad_d02_w = ref_t00_o ; ref_pad_d03_w = ref_t00_o ;
                                                    ref_pad_d04_w = ref_t00_o ; ref_pad_d05_w = ref_t00_o ;
                                                    ref_pad_d06_w = ref_t00_o ; ref_pad_d07_w = ref_t00_o ;
                                                    ref_pad_d08_w = ref_t00_o ; ref_pad_d09_w = ref_t00_o ;
                                                    ref_pad_d10_w = ref_t00_o ; ref_pad_d11_w = ref_t00_o ;
                                                    ref_pad_d12_w = ref_t00_o ; ref_pad_d13_w = ref_t00_o ;
                                                    ref_pad_d14_w = ref_t00_o ; ref_pad_d15_w = ref_t00_o ;
                            end
                            8'b0000_0001 : begin    ref_pad_d00_w = ref_r00_o ; ref_pad_d01_w = ref_r00_o ;
                                                    ref_pad_d02_w = ref_r00_o ; ref_pad_d03_w = ref_r00_o ;
                                                    ref_pad_d04_w = ref_r00_o ; ref_pad_d05_w = ref_r00_o ;
                                                    ref_pad_d06_w = ref_r00_o ; ref_pad_d07_w = ref_r00_o ;
                                                    ref_pad_d08_w = ref_r00_o ; ref_pad_d09_w = ref_r00_o ;
                                                    ref_pad_d10_w = ref_r00_o ; ref_pad_d11_w = ref_r00_o ;
                                                    ref_pad_d12_w = ref_r00_o ; ref_pad_d13_w = ref_r00_o ;
                                                    ref_pad_d14_w = ref_r00_o ; ref_pad_d15_w = ref_r00_o ;
                            end
                          endcase
      end
      `SIZE_32 : begin    casez( {pu_dn_exist_r,pu_lf_exist_r,pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                            12'b1???????_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                         ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                         ref_pad_d04_w = ref_d04_o ; ref_pad_d05_w = ref_d05_o ;
                                                         ref_pad_d06_w = ref_d06_o ; ref_pad_d07_w = ref_d07_o ;
                                                         ref_pad_d08_w = ref_d08_o ; ref_pad_d09_w = ref_d09_o ;
                                                         ref_pad_d10_w = ref_d10_o ; ref_pad_d11_w = ref_d11_o ;
                                                         ref_pad_d12_w = ref_d12_o ; ref_pad_d13_w = ref_d13_o ;
                                                         ref_pad_d14_w = ref_d14_o ; ref_pad_d15_w = ref_d15_o ;
                                                         ref_pad_d16_w = ref_d16_o ; ref_pad_d17_w = ref_d17_o ;
                                                         ref_pad_d18_w = ref_d18_o ; ref_pad_d19_w = ref_d19_o ;
                                                         ref_pad_d20_w = ref_d20_o ; ref_pad_d21_w = ref_d21_o ;
                                                         ref_pad_d22_w = ref_d22_o ; ref_pad_d23_w = ref_d23_o ;
                                                         ref_pad_d24_w = ref_d24_o ; ref_pad_d25_w = ref_d25_o ;
                                                         ref_pad_d26_w = ref_d26_o ; ref_pad_d27_w = ref_d27_o ;
                                                         ref_pad_d28_w = ref_d28_o ; ref_pad_d29_w = ref_d29_o ;
                                                         ref_pad_d30_w = ref_d30_o ; ref_pad_d31_w = ref_d31_o ;
                            end
                            12'b01??????_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                         ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                         ref_pad_d04_w = ref_d04_o ; ref_pad_d05_w = ref_d05_o ;
                                                         ref_pad_d06_w = ref_d06_o ; ref_pad_d07_w = ref_d07_o ;
                                                         ref_pad_d08_w = ref_d08_o ; ref_pad_d09_w = ref_d09_o ;
                                                         ref_pad_d10_w = ref_d10_o ; ref_pad_d11_w = ref_d11_o ;
                                                         ref_pad_d12_w = ref_d12_o ; ref_pad_d13_w = ref_d13_o ;
                                                         ref_pad_d14_w = ref_d14_o ; ref_pad_d15_w = ref_d15_o ;
                                                         ref_pad_d16_w = ref_d16_o ; ref_pad_d17_w = ref_d17_o ;
                                                         ref_pad_d18_w = ref_d18_o ; ref_pad_d19_w = ref_d19_o ;
                                                         ref_pad_d20_w = ref_d20_o ; ref_pad_d21_w = ref_d21_o ;
                                                         ref_pad_d22_w = ref_d22_o ; ref_pad_d23_w = ref_d23_o ;
                                                         ref_pad_d24_w = ref_d24_o ; ref_pad_d25_w = ref_d25_o ;
                                                         ref_pad_d26_w = ref_d26_o ; ref_pad_d27_w = ref_d27_o ;
                                                         ref_pad_d28_w = ref_d27_o ; ref_pad_d29_w = ref_d27_o ;
                                                         ref_pad_d30_w = ref_d27_o ; ref_pad_d31_w = ref_d27_o ;
                            end
                            12'b001?????_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                         ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                         ref_pad_d04_w = ref_d04_o ; ref_pad_d05_w = ref_d05_o ;
                                                         ref_pad_d06_w = ref_d06_o ; ref_pad_d07_w = ref_d07_o ;
                                                         ref_pad_d08_w = ref_d08_o ; ref_pad_d09_w = ref_d09_o ;
                                                         ref_pad_d10_w = ref_d10_o ; ref_pad_d11_w = ref_d11_o ;
                                                         ref_pad_d12_w = ref_d12_o ; ref_pad_d13_w = ref_d13_o ;
                                                         ref_pad_d14_w = ref_d14_o ; ref_pad_d15_w = ref_d15_o ;
                                                         ref_pad_d16_w = ref_d16_o ; ref_pad_d17_w = ref_d17_o ;
                                                         ref_pad_d18_w = ref_d18_o ; ref_pad_d19_w = ref_d19_o ;
                                                         ref_pad_d20_w = ref_d20_o ; ref_pad_d21_w = ref_d21_o ;
                                                         ref_pad_d22_w = ref_d22_o ; ref_pad_d23_w = ref_d23_o ;
                                                         ref_pad_d24_w = ref_d23_o ; ref_pad_d25_w = ref_d23_o ;
                                                         ref_pad_d26_w = ref_d23_o ; ref_pad_d27_w = ref_d23_o ;
                                                         ref_pad_d28_w = ref_d23_o ; ref_pad_d29_w = ref_d23_o ;
                                                         ref_pad_d30_w = ref_d23_o ; ref_pad_d31_w = ref_d23_o ;
                            end
                            12'b0001????_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                         ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                         ref_pad_d04_w = ref_d04_o ; ref_pad_d05_w = ref_d05_o ;
                                                         ref_pad_d06_w = ref_d06_o ; ref_pad_d07_w = ref_d07_o ;
                                                         ref_pad_d08_w = ref_d08_o ; ref_pad_d09_w = ref_d09_o ;
                                                         ref_pad_d10_w = ref_d10_o ; ref_pad_d11_w = ref_d11_o ;
                                                         ref_pad_d12_w = ref_d12_o ; ref_pad_d13_w = ref_d13_o ;
                                                         ref_pad_d14_w = ref_d14_o ; ref_pad_d15_w = ref_d15_o ;
                                                         ref_pad_d16_w = ref_d16_o ; ref_pad_d17_w = ref_d17_o ;
                                                         ref_pad_d18_w = ref_d18_o ; ref_pad_d19_w = ref_d19_o ;
                                                         ref_pad_d20_w = ref_d19_o ; ref_pad_d21_w = ref_d19_o ;
                                                         ref_pad_d22_w = ref_d19_o ; ref_pad_d23_w = ref_d19_o ;
                                                         ref_pad_d24_w = ref_d19_o ; ref_pad_d25_w = ref_d19_o ;
                                                         ref_pad_d26_w = ref_d19_o ; ref_pad_d27_w = ref_d19_o ;
                                                         ref_pad_d28_w = ref_d19_o ; ref_pad_d29_w = ref_d19_o ;
                                                         ref_pad_d30_w = ref_d19_o ; ref_pad_d31_w = ref_d19_o ;
                            end
                            12'b00001???_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                         ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                         ref_pad_d04_w = ref_d04_o ; ref_pad_d05_w = ref_d05_o ;
                                                         ref_pad_d06_w = ref_d06_o ; ref_pad_d07_w = ref_d07_o ;
                                                         ref_pad_d08_w = ref_d08_o ; ref_pad_d09_w = ref_d09_o ;
                                                         ref_pad_d10_w = ref_d10_o ; ref_pad_d11_w = ref_d11_o ;
                                                         ref_pad_d12_w = ref_d12_o ; ref_pad_d13_w = ref_d13_o ;
                                                         ref_pad_d14_w = ref_d14_o ; ref_pad_d15_w = ref_d15_o ;
                                                         ref_pad_d16_w = ref_d15_o ; ref_pad_d17_w = ref_d15_o ;
                                                         ref_pad_d18_w = ref_d15_o ; ref_pad_d19_w = ref_d15_o ;
                                                         ref_pad_d20_w = ref_d15_o ; ref_pad_d21_w = ref_d15_o ;
                                                         ref_pad_d22_w = ref_d15_o ; ref_pad_d23_w = ref_d15_o ;
                                                         ref_pad_d24_w = ref_d15_o ; ref_pad_d25_w = ref_d15_o ;
                                                         ref_pad_d26_w = ref_d15_o ; ref_pad_d27_w = ref_d15_o ;
                                                         ref_pad_d28_w = ref_d15_o ; ref_pad_d29_w = ref_d15_o ;
                                                         ref_pad_d30_w = ref_d15_o ; ref_pad_d31_w = ref_d15_o ;
                            end
                            12'b000001??_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                         ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                         ref_pad_d04_w = ref_d04_o ; ref_pad_d05_w = ref_d05_o ;
                                                         ref_pad_d06_w = ref_d06_o ; ref_pad_d07_w = ref_d07_o ;
                                                         ref_pad_d08_w = ref_d08_o ; ref_pad_d09_w = ref_d09_o ;
                                                         ref_pad_d10_w = ref_d10_o ; ref_pad_d11_w = ref_d11_o ;
                                                         ref_pad_d12_w = ref_d11_o ; ref_pad_d13_w = ref_d11_o ;
                                                         ref_pad_d14_w = ref_d11_o ; ref_pad_d15_w = ref_d11_o ;
                                                         ref_pad_d16_w = ref_d11_o ; ref_pad_d17_w = ref_d11_o ;
                                                         ref_pad_d18_w = ref_d11_o ; ref_pad_d19_w = ref_d11_o ;
                                                         ref_pad_d20_w = ref_d11_o ; ref_pad_d21_w = ref_d11_o ;
                                                         ref_pad_d22_w = ref_d11_o ; ref_pad_d23_w = ref_d11_o ;
                                                         ref_pad_d24_w = ref_d11_o ; ref_pad_d25_w = ref_d11_o ;
                                                         ref_pad_d26_w = ref_d11_o ; ref_pad_d27_w = ref_d11_o ;
                                                         ref_pad_d28_w = ref_d11_o ; ref_pad_d29_w = ref_d11_o ;
                                                         ref_pad_d30_w = ref_d11_o ; ref_pad_d31_w = ref_d11_o ;
                            end
                            12'b0000001?_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                         ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                         ref_pad_d04_w = ref_d04_o ; ref_pad_d05_w = ref_d05_o ;
                                                         ref_pad_d06_w = ref_d06_o ; ref_pad_d07_w = ref_d07_o ;
                                                         ref_pad_d08_w = ref_d07_o ; ref_pad_d09_w = ref_d07_o ;
                                                         ref_pad_d10_w = ref_d07_o ; ref_pad_d11_w = ref_d07_o ;
                                                         ref_pad_d12_w = ref_d07_o ; ref_pad_d13_w = ref_d07_o ;
                                                         ref_pad_d14_w = ref_d07_o ; ref_pad_d15_w = ref_d07_o ;
                                                         ref_pad_d16_w = ref_d07_o ; ref_pad_d17_w = ref_d07_o ;
                                                         ref_pad_d18_w = ref_d07_o ; ref_pad_d19_w = ref_d07_o ;
                                                         ref_pad_d20_w = ref_d07_o ; ref_pad_d21_w = ref_d07_o ;
                                                         ref_pad_d22_w = ref_d07_o ; ref_pad_d23_w = ref_d07_o ;
                                                         ref_pad_d24_w = ref_d07_o ; ref_pad_d25_w = ref_d07_o ;
                                                         ref_pad_d26_w = ref_d07_o ; ref_pad_d27_w = ref_d07_o ;
                                                         ref_pad_d28_w = ref_d07_o ; ref_pad_d29_w = ref_d07_o ;
                                                         ref_pad_d30_w = ref_d07_o ; ref_pad_d31_w = ref_d07_o ;
                            end
                            12'b00000001_???? : begin    ref_pad_d00_w = ref_d00_o ; ref_pad_d01_w = ref_d01_o ;
                                                         ref_pad_d02_w = ref_d02_o ; ref_pad_d03_w = ref_d03_o ;
                                                         ref_pad_d04_w = ref_d03_o ; ref_pad_d05_w = ref_d03_o ;
                                                         ref_pad_d06_w = ref_d03_o ; ref_pad_d07_w = ref_d03_o ;
                                                         ref_pad_d08_w = ref_d03_o ; ref_pad_d09_w = ref_d03_o ;
                                                         ref_pad_d10_w = ref_d03_o ; ref_pad_d11_w = ref_d03_o ;
                                                         ref_pad_d12_w = ref_d03_o ; ref_pad_d13_w = ref_d03_o ;
                                                         ref_pad_d14_w = ref_d03_o ; ref_pad_d15_w = ref_d03_o ;
                                                         ref_pad_d16_w = ref_d03_o ; ref_pad_d17_w = ref_d03_o ;
                                                         ref_pad_d18_w = ref_d03_o ; ref_pad_d19_w = ref_d03_o ;
                                                         ref_pad_d20_w = ref_d03_o ; ref_pad_d21_w = ref_d03_o ;
                                                         ref_pad_d22_w = ref_d03_o ; ref_pad_d23_w = ref_d03_o ;
                                                         ref_pad_d24_w = ref_d03_o ; ref_pad_d25_w = ref_d03_o ;
                                                         ref_pad_d26_w = ref_d03_o ; ref_pad_d27_w = ref_d03_o ;
                                                         ref_pad_d28_w = ref_d03_o ; ref_pad_d29_w = ref_d03_o ;
                                                         ref_pad_d30_w = ref_d03_o ; ref_pad_d31_w = ref_d03_o ;
                            end
                            12'b00000000_1??? : begin    ref_pad_d00_w = ref_l31_o ; ref_pad_d01_w = ref_l31_o ;
                                                         ref_pad_d02_w = ref_l31_o ; ref_pad_d03_w = ref_l31_o ;
                                                         ref_pad_d04_w = ref_l31_o ; ref_pad_d05_w = ref_l31_o ;
                                                         ref_pad_d06_w = ref_l31_o ; ref_pad_d07_w = ref_l31_o ;
                                                         ref_pad_d08_w = ref_l31_o ; ref_pad_d09_w = ref_l31_o ;
                                                         ref_pad_d10_w = ref_l31_o ; ref_pad_d11_w = ref_l31_o ;
                                                         ref_pad_d12_w = ref_l31_o ; ref_pad_d13_w = ref_l31_o ;
                                                         ref_pad_d14_w = ref_l31_o ; ref_pad_d15_w = ref_l31_o ;
                                                         ref_pad_d16_w = ref_l31_o ; ref_pad_d17_w = ref_l31_o ;
                                                         ref_pad_d18_w = ref_l31_o ; ref_pad_d19_w = ref_l31_o ;
                                                         ref_pad_d20_w = ref_l31_o ; ref_pad_d21_w = ref_l31_o ;
                                                         ref_pad_d22_w = ref_l31_o ; ref_pad_d23_w = ref_l31_o ;
                                                         ref_pad_d24_w = ref_l31_o ; ref_pad_d25_w = ref_l31_o ;
                                                         ref_pad_d26_w = ref_l31_o ; ref_pad_d27_w = ref_l31_o ;
                                                         ref_pad_d28_w = ref_l31_o ; ref_pad_d29_w = ref_l31_o ;
                                                         ref_pad_d30_w = ref_l31_o ; ref_pad_d31_w = ref_l31_o ;
                            end
                            12'b00000000_01?? : begin    ref_pad_d00_w = ref_tl_o  ; ref_pad_d01_w = ref_tl_o  ;
                                                         ref_pad_d02_w = ref_tl_o  ; ref_pad_d03_w = ref_tl_o  ;
                                                         ref_pad_d04_w = ref_tl_o  ; ref_pad_d05_w = ref_tl_o  ;
                                                         ref_pad_d06_w = ref_tl_o  ; ref_pad_d07_w = ref_tl_o  ;
                                                         ref_pad_d08_w = ref_tl_o  ; ref_pad_d09_w = ref_tl_o  ;
                                                         ref_pad_d10_w = ref_tl_o  ; ref_pad_d11_w = ref_tl_o  ;
                                                         ref_pad_d12_w = ref_tl_o  ; ref_pad_d13_w = ref_tl_o  ;
                                                         ref_pad_d14_w = ref_tl_o  ; ref_pad_d15_w = ref_tl_o  ;
                                                         ref_pad_d16_w = ref_tl_o  ; ref_pad_d17_w = ref_tl_o  ;
                                                         ref_pad_d18_w = ref_tl_o  ; ref_pad_d19_w = ref_tl_o  ;
                                                         ref_pad_d20_w = ref_tl_o  ; ref_pad_d21_w = ref_tl_o  ;
                                                         ref_pad_d22_w = ref_tl_o  ; ref_pad_d23_w = ref_tl_o  ;
                                                         ref_pad_d24_w = ref_tl_o  ; ref_pad_d25_w = ref_tl_o  ;
                                                         ref_pad_d26_w = ref_tl_o  ; ref_pad_d27_w = ref_tl_o  ;
                                                         ref_pad_d28_w = ref_tl_o  ; ref_pad_d29_w = ref_tl_o  ;
                                                         ref_pad_d30_w = ref_tl_o  ; ref_pad_d31_w = ref_tl_o  ;
                            end
                            12'b00000000_001? : begin    ref_pad_d00_w = ref_t00_o ; ref_pad_d01_w = ref_t00_o ;
                                                         ref_pad_d02_w = ref_t00_o ; ref_pad_d03_w = ref_t00_o ;
                                                         ref_pad_d04_w = ref_t00_o ; ref_pad_d05_w = ref_t00_o ;
                                                         ref_pad_d06_w = ref_t00_o ; ref_pad_d07_w = ref_t00_o ;
                                                         ref_pad_d08_w = ref_t00_o ; ref_pad_d09_w = ref_t00_o ;
                                                         ref_pad_d10_w = ref_t00_o ; ref_pad_d11_w = ref_t00_o ;
                                                         ref_pad_d12_w = ref_t00_o ; ref_pad_d13_w = ref_t00_o ;
                                                         ref_pad_d14_w = ref_t00_o ; ref_pad_d15_w = ref_t00_o ;
                                                         ref_pad_d16_w = ref_t00_o ; ref_pad_d17_w = ref_t00_o ;
                                                         ref_pad_d18_w = ref_t00_o ; ref_pad_d19_w = ref_t00_o ;
                                                         ref_pad_d20_w = ref_t00_o ; ref_pad_d21_w = ref_t00_o ;
                                                         ref_pad_d22_w = ref_t00_o ; ref_pad_d23_w = ref_t00_o ;
                                                         ref_pad_d24_w = ref_t00_o ; ref_pad_d25_w = ref_t00_o ;
                                                         ref_pad_d26_w = ref_t00_o ; ref_pad_d27_w = ref_t00_o ;
                                                         ref_pad_d28_w = ref_t00_o ; ref_pad_d29_w = ref_t00_o ;
                                                         ref_pad_d30_w = ref_t00_o ; ref_pad_d31_w = ref_t00_o ;
                            end
                            12'b00000000_0001 : begin    ref_pad_d00_w = ref_r00_o ; ref_pad_d01_w = ref_r00_o ;
                                                         ref_pad_d02_w = ref_r00_o ; ref_pad_d03_w = ref_r00_o ;
                                                         ref_pad_d04_w = ref_r00_o ; ref_pad_d05_w = ref_r00_o ;
                                                         ref_pad_d06_w = ref_r00_o ; ref_pad_d07_w = ref_r00_o ;
                                                         ref_pad_d08_w = ref_r00_o ; ref_pad_d09_w = ref_r00_o ;
                                                         ref_pad_d10_w = ref_r00_o ; ref_pad_d11_w = ref_r00_o ;
                                                         ref_pad_d12_w = ref_r00_o ; ref_pad_d13_w = ref_r00_o ;
                                                         ref_pad_d14_w = ref_r00_o ; ref_pad_d15_w = ref_r00_o ;
                                                         ref_pad_d16_w = ref_r00_o ; ref_pad_d17_w = ref_r00_o ;
                                                         ref_pad_d18_w = ref_r00_o ; ref_pad_d19_w = ref_r00_o ;
                                                         ref_pad_d20_w = ref_r00_o ; ref_pad_d21_w = ref_r00_o ;
                                                         ref_pad_d22_w = ref_r00_o ; ref_pad_d23_w = ref_r00_o ;
                                                         ref_pad_d24_w = ref_r00_o ; ref_pad_d25_w = ref_r00_o ;
                                                         ref_pad_d26_w = ref_r00_o ; ref_pad_d27_w = ref_r00_o ;
                                                         ref_pad_d28_w = ref_r00_o ; ref_pad_d29_w = ref_r00_o ;
                                                         ref_pad_d30_w = ref_r00_o ; ref_pad_d31_w = ref_r00_o ;
                            end
                          endcase
      end
    endcase
  end


//--- FILTERING ------------------------
  // flag
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      filter_flag_r <= 0;
    end
    else begin
      if( sel_i==`TYPE_Y ) begin
        case( size_i )
          `SIZE_04 :                                    filter_flag_r <= 0 ;
          `SIZE_08 : begin    case( mode_i )
                                0,2,18,34          :    filter_flag_r <= 1 ;
                                default            :    filter_flag_r <= 0 ;
                              endcase
          end
          `SIZE_16 : begin    case( mode_i )
                                1,9,10,11,25,26,27 :    filter_flag_r <= 0 ;
                                default            :    filter_flag_r <= 1 ;
                              endcase
          end
          `SIZE_32 : begin    case( mode_i )
                                1,10,26            :    filter_flag_r <= 0 ;
                                default            :    filter_flag_r <= 1 ;
                              endcase
          end
        endcase
      end
      else begin
                                                        filter_flag_r <= 0 ;
      end
    end
  end

  // top-left
  always @(*) begin
    if( filter_flag_r ) begin
      ref_flt_tl_w = ( ref_l00_o+(ref_tl_o<<1)+ref_t00_o+2 )>>2 ;
    end
    else begin
      ref_flt_tl_w =              ref_tl_o ;
    end
  end

  // top
  always @(*) begin
    if( filter_flag_r ) begin
      // 00-06
      ref_flt_t00_w = ( ref_t01_o+(ref_t00_o<<1)+ref_tl_o +2 )>>2 ;
      ref_flt_t01_w = ( ref_t02_o+(ref_t01_o<<1)+ref_t00_o+2 )>>2 ;
      ref_flt_t02_w = ( ref_t03_o+(ref_t02_o<<1)+ref_t01_o+2 )>>2 ;
      ref_flt_t03_w = ( ref_t04_o+(ref_t03_o<<1)+ref_t02_o+2 )>>2 ;
      ref_flt_t04_w = ( ref_t05_o+(ref_t04_o<<1)+ref_t03_o+2 )>>2 ;
      ref_flt_t05_w = ( ref_t06_o+(ref_t05_o<<1)+ref_t04_o+2 )>>2 ;
      ref_flt_t06_w = ( ref_t07_o+(ref_t06_o<<1)+ref_t05_o+2 )>>2 ;
      // 07
      if( size_i==`SIZE_08 ) begin
        ref_flt_t07_w = ( ref_r00_o+(ref_t07_o<<1)+ref_t06_o+2 )>>2 ;
      end
      else begin
        ref_flt_t07_w = ( ref_t08_o+(ref_t07_o<<1)+ref_t06_o+2 )>>2 ;
      end
      // 08-14
      ref_flt_t08_w = ( ref_t09_o+(ref_t08_o<<1)+ref_t07_o+2 )>>2 ;
      ref_flt_t09_w = ( ref_t10_o+(ref_t09_o<<1)+ref_t08_o+2 )>>2 ;
      ref_flt_t10_w = ( ref_t11_o+(ref_t10_o<<1)+ref_t09_o+2 )>>2 ;
      ref_flt_t11_w = ( ref_t12_o+(ref_t11_o<<1)+ref_t10_o+2 )>>2 ;
      ref_flt_t12_w = ( ref_t13_o+(ref_t12_o<<1)+ref_t11_o+2 )>>2 ;
      ref_flt_t13_w = ( ref_t14_o+(ref_t13_o<<1)+ref_t12_o+2 )>>2 ;
      ref_flt_t14_w = ( ref_t15_o+(ref_t14_o<<1)+ref_t13_o+2 )>>2 ;
      // 15
      if( size_i==`SIZE_16 ) begin
        ref_flt_t15_w = ( ref_r00_o+(ref_t15_o<<1)+ref_t14_o+2 )>>2 ;
      end
      else begin
        ref_flt_t15_w = ( ref_t16_o+(ref_t15_o<<1)+ref_t14_o+2 )>>2 ;
      end
      // 16-31
      ref_flt_t16_w = ( ref_t17_o+(ref_t16_o<<1)+ref_t15_o+2 )>>2 ;
      ref_flt_t17_w = ( ref_t18_o+(ref_t17_o<<1)+ref_t16_o+2 )>>2 ;
      ref_flt_t18_w = ( ref_t19_o+(ref_t18_o<<1)+ref_t17_o+2 )>>2 ;
      ref_flt_t19_w = ( ref_t20_o+(ref_t19_o<<1)+ref_t18_o+2 )>>2 ;
      ref_flt_t20_w = ( ref_t21_o+(ref_t20_o<<1)+ref_t19_o+2 )>>2 ;
      ref_flt_t21_w = ( ref_t22_o+(ref_t21_o<<1)+ref_t20_o+2 )>>2 ;
      ref_flt_t22_w = ( ref_t23_o+(ref_t22_o<<1)+ref_t21_o+2 )>>2 ;
      ref_flt_t23_w = ( ref_t24_o+(ref_t23_o<<1)+ref_t22_o+2 )>>2 ;
      ref_flt_t24_w = ( ref_t25_o+(ref_t24_o<<1)+ref_t23_o+2 )>>2 ;
      ref_flt_t25_w = ( ref_t26_o+(ref_t25_o<<1)+ref_t24_o+2 )>>2 ;
      ref_flt_t26_w = ( ref_t27_o+(ref_t26_o<<1)+ref_t25_o+2 )>>2 ;
      ref_flt_t27_w = ( ref_t28_o+(ref_t27_o<<1)+ref_t26_o+2 )>>2 ;
      ref_flt_t28_w = ( ref_t29_o+(ref_t28_o<<1)+ref_t27_o+2 )>>2 ;
      ref_flt_t29_w = ( ref_t30_o+(ref_t29_o<<1)+ref_t28_o+2 )>>2 ;
      ref_flt_t30_w = ( ref_t31_o+(ref_t30_o<<1)+ref_t29_o+2 )>>2 ;
      ref_flt_t31_w = ( ref_r00_o+(ref_t31_o<<1)+ref_t30_o+2 )>>2 ;
    end
    else begin
      ref_flt_t00_w = ref_t00_o ; ref_flt_t01_w = ref_t01_o ;
      ref_flt_t02_w = ref_t02_o ; ref_flt_t03_w = ref_t03_o ;
      ref_flt_t04_w = ref_t04_o ; ref_flt_t05_w = ref_t05_o ;
      ref_flt_t06_w = ref_t06_o ; ref_flt_t07_w = ref_t07_o ;
      ref_flt_t08_w = ref_t08_o ; ref_flt_t09_w = ref_t09_o ;
      ref_flt_t10_w = ref_t10_o ; ref_flt_t11_w = ref_t11_o ;
      ref_flt_t12_w = ref_t12_o ; ref_flt_t13_w = ref_t13_o ;
      ref_flt_t14_w = ref_t14_o ; ref_flt_t15_w = ref_t15_o ;
      ref_flt_t16_w = ref_t16_o ; ref_flt_t17_w = ref_t17_o ;
      ref_flt_t18_w = ref_t18_o ; ref_flt_t19_w = ref_t19_o ;
      ref_flt_t20_w = ref_t20_o ; ref_flt_t21_w = ref_t21_o ;
      ref_flt_t22_w = ref_t22_o ; ref_flt_t23_w = ref_t23_o ;
      ref_flt_t24_w = ref_t24_o ; ref_flt_t25_w = ref_t25_o ;
      ref_flt_t26_w = ref_t26_o ; ref_flt_t27_w = ref_t27_o ;
      ref_flt_t28_w = ref_t28_o ; ref_flt_t29_w = ref_t29_o ;
      ref_flt_t30_w = ref_t30_o ; ref_flt_t31_w = ref_t31_o ;
    end
  end

  // right
  always @(*) begin
    if( filter_flag_r ) begin
      case( size_i )
        `SIZE_04 : ref_flt_r00_w =             ref_r00_o                     ;
        `SIZE_08 : ref_flt_r00_w = (ref_r01_o+(ref_r00_o<<1)+ref_t07_o+2)>>2 ;
        `SIZE_16 : ref_flt_r00_w = (ref_r01_o+(ref_r00_o<<1)+ref_t15_o+2)>>2 ;
        `SIZE_32 : ref_flt_r00_w = (ref_r01_o+(ref_r00_o<<1)+ref_t31_o+2)>>2 ;
      endcase
      ref_flt_r01_w = ( ref_r02_o+(ref_r01_o<<1)+ref_r00_o+2 )>>2 ;
      ref_flt_r02_w = ( ref_r03_o+(ref_r02_o<<1)+ref_r01_o+2 )>>2 ;
      ref_flt_r03_w = ( ref_r04_o+(ref_r03_o<<1)+ref_r02_o+2 )>>2 ;
      ref_flt_r04_w = ( ref_r05_o+(ref_r04_o<<1)+ref_r03_o+2 )>>2 ;
      ref_flt_r05_w = ( ref_r06_o+(ref_r05_o<<1)+ref_r04_o+2 )>>2 ;
      ref_flt_r06_w = ( ref_r07_o+(ref_r06_o<<1)+ref_r05_o+2 )>>2 ;
      if( size_i==`SIZE_08 ) begin
        ref_flt_r07_w =              ref_r07_o                      ;
      end
      else begin
        ref_flt_r07_w = ( ref_r08_o+(ref_r07_o<<1)+ref_r06_o+2 )>>2 ;
      end
      ref_flt_r08_w = ( ref_r09_o+(ref_r08_o<<1)+ref_r07_o+2 )>>2 ;
      ref_flt_r09_w = ( ref_r10_o+(ref_r09_o<<1)+ref_r08_o+2 )>>2 ;
      ref_flt_r10_w = ( ref_r11_o+(ref_r10_o<<1)+ref_r09_o+2 )>>2 ;
      ref_flt_r11_w = ( ref_r12_o+(ref_r11_o<<1)+ref_r10_o+2 )>>2 ;
      ref_flt_r12_w = ( ref_r13_o+(ref_r12_o<<1)+ref_r11_o+2 )>>2 ;
      ref_flt_r13_w = ( ref_r14_o+(ref_r13_o<<1)+ref_r12_o+2 )>>2 ;
      ref_flt_r14_w = ( ref_r15_o+(ref_r14_o<<1)+ref_r13_o+2 )>>2 ;
      if( size_i==`SIZE_16 ) begin
        ref_flt_r15_w = ref_r15_o ;
      end
      else begin
        ref_flt_r15_w = ( ref_r16_o+(ref_r15_o<<1)+ref_r14_o+2 )>>2 ;
      end
      ref_flt_r16_w = ( ref_r17_o+(ref_r16_o<<1)+ref_r15_o+2 )>>2 ;
      ref_flt_r17_w = ( ref_r18_o+(ref_r17_o<<1)+ref_r16_o+2 )>>2 ;
      ref_flt_r18_w = ( ref_r19_o+(ref_r18_o<<1)+ref_r17_o+2 )>>2 ;
      ref_flt_r19_w = ( ref_r20_o+(ref_r19_o<<1)+ref_r18_o+2 )>>2 ;
      ref_flt_r20_w = ( ref_r21_o+(ref_r20_o<<1)+ref_r19_o+2 )>>2 ;
      ref_flt_r21_w = ( ref_r22_o+(ref_r21_o<<1)+ref_r20_o+2 )>>2 ;
      ref_flt_r22_w = ( ref_r23_o+(ref_r22_o<<1)+ref_r21_o+2 )>>2 ;
      ref_flt_r23_w = ( ref_r24_o+(ref_r23_o<<1)+ref_r22_o+2 )>>2 ;
      ref_flt_r24_w = ( ref_r25_o+(ref_r24_o<<1)+ref_r23_o+2 )>>2 ;
      ref_flt_r25_w = ( ref_r26_o+(ref_r25_o<<1)+ref_r24_o+2 )>>2 ;
      ref_flt_r26_w = ( ref_r27_o+(ref_r26_o<<1)+ref_r25_o+2 )>>2 ;
      ref_flt_r27_w = ( ref_r28_o+(ref_r27_o<<1)+ref_r26_o+2 )>>2 ;
      ref_flt_r28_w = ( ref_r29_o+(ref_r28_o<<1)+ref_r27_o+2 )>>2 ;
      ref_flt_r29_w = ( ref_r30_o+(ref_r29_o<<1)+ref_r28_o+2 )>>2 ;
      ref_flt_r30_w = ( ref_r31_o+(ref_r30_o<<1)+ref_r29_o+2 )>>2 ;
      ref_flt_r31_w =              ref_r31_o                      ;
    end
    else begin
      ref_flt_r00_w = ref_r00_o ; ref_flt_r01_w = ref_r01_o ;
      ref_flt_r02_w = ref_r02_o ; ref_flt_r03_w = ref_r03_o ;
      ref_flt_r04_w = ref_r04_o ; ref_flt_r05_w = ref_r05_o ;
      ref_flt_r06_w = ref_r06_o ; ref_flt_r07_w = ref_r07_o ;
      ref_flt_r08_w = ref_r08_o ; ref_flt_r09_w = ref_r09_o ;
      ref_flt_r10_w = ref_r10_o ; ref_flt_r11_w = ref_r11_o ;
      ref_flt_r12_w = ref_r12_o ; ref_flt_r13_w = ref_r13_o ;
      ref_flt_r14_w = ref_r14_o ; ref_flt_r15_w = ref_r15_o ;
      ref_flt_r16_w = ref_r16_o ; ref_flt_r17_w = ref_r17_o ;
      ref_flt_r18_w = ref_r18_o ; ref_flt_r19_w = ref_r19_o ;
      ref_flt_r20_w = ref_r20_o ; ref_flt_r21_w = ref_r21_o ;
      ref_flt_r22_w = ref_r22_o ; ref_flt_r23_w = ref_r23_o ;
      ref_flt_r24_w = ref_r24_o ; ref_flt_r25_w = ref_r25_o ;
      ref_flt_r26_w = ref_r26_o ; ref_flt_r27_w = ref_r27_o ;
      ref_flt_r28_w = ref_r28_o ; ref_flt_r29_w = ref_r29_o ;
      ref_flt_r30_w = ref_r30_o ; ref_flt_r31_w = ref_r31_o ;
    end
  end

  // left
  always @(*) begin
    if( filter_flag_r ) begin
      // 00-06
      ref_flt_l00_w = ( ref_l01_o+(ref_l00_o<<1)+ref_tl_o +2 )>>2 ;
      ref_flt_l01_w = ( ref_l02_o+(ref_l01_o<<1)+ref_l00_o+2 )>>2 ;
      ref_flt_l02_w = ( ref_l03_o+(ref_l02_o<<1)+ref_l01_o+2 )>>2 ;
      ref_flt_l03_w = ( ref_l04_o+(ref_l03_o<<1)+ref_l02_o+2 )>>2 ;
      ref_flt_l04_w = ( ref_l05_o+(ref_l04_o<<1)+ref_l03_o+2 )>>2 ;
      ref_flt_l05_w = ( ref_l06_o+(ref_l05_o<<1)+ref_l04_o+2 )>>2 ;
      ref_flt_l06_w = ( ref_l07_o+(ref_l06_o<<1)+ref_l05_o+2 )>>2 ;
      // 07
      if( size_i==`SIZE_08 ) begin
        ref_flt_l07_w = ( ref_d00_o+(ref_l07_o<<1)+ref_l06_o+2 )>>2 ;
      end
      else begin
        ref_flt_l07_w = ( ref_l08_o+(ref_l07_o<<1)+ref_l06_o+2 )>>2 ;
      end
      // 08-14
      ref_flt_l08_w = ( ref_l09_o+(ref_l08_o<<1)+ref_l07_o+2 )>>2 ;
      ref_flt_l09_w = ( ref_l10_o+(ref_l09_o<<1)+ref_l08_o+2 )>>2 ;
      ref_flt_l10_w = ( ref_l11_o+(ref_l10_o<<1)+ref_l09_o+2 )>>2 ;
      ref_flt_l11_w = ( ref_l12_o+(ref_l11_o<<1)+ref_l10_o+2 )>>2 ;
      ref_flt_l12_w = ( ref_l13_o+(ref_l12_o<<1)+ref_l11_o+2 )>>2 ;
      ref_flt_l13_w = ( ref_l14_o+(ref_l13_o<<1)+ref_l12_o+2 )>>2 ;
      ref_flt_l14_w = ( ref_l15_o+(ref_l14_o<<1)+ref_l13_o+2 )>>2 ;
      // 15
      if( size_i==`SIZE_16 ) begin
        ref_flt_l15_w = ( ref_d00_o+(ref_l15_o<<1)+ref_l14_o+2 )>>2 ;
      end
      else begin
        ref_flt_l15_w = ( ref_l16_o+(ref_l15_o<<1)+ref_l14_o+2 )>>2 ;
      end
      // 16-31
      ref_flt_l16_w = ( ref_l17_o+(ref_l16_o<<1)+ref_l15_o+2 )>>2 ;
      ref_flt_l17_w = ( ref_l18_o+(ref_l17_o<<1)+ref_l16_o+2 )>>2 ;
      ref_flt_l18_w = ( ref_l19_o+(ref_l18_o<<1)+ref_l17_o+2 )>>2 ;
      ref_flt_l19_w = ( ref_l20_o+(ref_l19_o<<1)+ref_l18_o+2 )>>2 ;
      ref_flt_l20_w = ( ref_l21_o+(ref_l20_o<<1)+ref_l19_o+2 )>>2 ;
      ref_flt_l21_w = ( ref_l22_o+(ref_l21_o<<1)+ref_l20_o+2 )>>2 ;
      ref_flt_l22_w = ( ref_l23_o+(ref_l22_o<<1)+ref_l21_o+2 )>>2 ;
      ref_flt_l23_w = ( ref_l24_o+(ref_l23_o<<1)+ref_l22_o+2 )>>2 ;
      ref_flt_l24_w = ( ref_l25_o+(ref_l24_o<<1)+ref_l23_o+2 )>>2 ;
      ref_flt_l25_w = ( ref_l26_o+(ref_l25_o<<1)+ref_l24_o+2 )>>2 ;
      ref_flt_l26_w = ( ref_l27_o+(ref_l26_o<<1)+ref_l25_o+2 )>>2 ;
      ref_flt_l27_w = ( ref_l28_o+(ref_l27_o<<1)+ref_l26_o+2 )>>2 ;
      ref_flt_l28_w = ( ref_l29_o+(ref_l28_o<<1)+ref_l27_o+2 )>>2 ;
      ref_flt_l29_w = ( ref_l30_o+(ref_l29_o<<1)+ref_l28_o+2 )>>2 ;
      ref_flt_l30_w = ( ref_l31_o+(ref_l30_o<<1)+ref_l29_o+2 )>>2 ;
      ref_flt_l31_w = ( ref_d00_o+(ref_l31_o<<1)+ref_l30_o+2 )>>2 ;
    end
    else begin
      ref_flt_l00_w = ref_l00_o ; ref_flt_l01_w = ref_l01_o ;
      ref_flt_l02_w = ref_l02_o ; ref_flt_l03_w = ref_l03_o ;
      ref_flt_l04_w = ref_l04_o ; ref_flt_l05_w = ref_l05_o ;
      ref_flt_l06_w = ref_l06_o ; ref_flt_l07_w = ref_l07_o ;
      ref_flt_l08_w = ref_l08_o ; ref_flt_l09_w = ref_l09_o ;
      ref_flt_l10_w = ref_l10_o ; ref_flt_l11_w = ref_l11_o ;
      ref_flt_l12_w = ref_l12_o ; ref_flt_l13_w = ref_l13_o ;
      ref_flt_l14_w = ref_l14_o ; ref_flt_l15_w = ref_l15_o ;
      ref_flt_l16_w = ref_l16_o ; ref_flt_l17_w = ref_l17_o ;
      ref_flt_l18_w = ref_l18_o ; ref_flt_l19_w = ref_l19_o ;
      ref_flt_l20_w = ref_l20_o ; ref_flt_l21_w = ref_l21_o ;
      ref_flt_l22_w = ref_l22_o ; ref_flt_l23_w = ref_l23_o ;
      ref_flt_l24_w = ref_l24_o ; ref_flt_l25_w = ref_l25_o ;
      ref_flt_l26_w = ref_l26_o ; ref_flt_l27_w = ref_l27_o ;
      ref_flt_l28_w = ref_l28_o ; ref_flt_l29_w = ref_l29_o ;
      ref_flt_l30_w = ref_l30_o ; ref_flt_l31_w = ref_l31_o ;
    end
  end

  // down
  always @(*) begin
    if( filter_flag_r ) begin
      // 00
      case (size_i)
        `SIZE_04 : ref_flt_d00_w =              ref_d00_o                      ;
        `SIZE_08 : ref_flt_d00_w = ( ref_d01_o+(ref_d00_o<<1)+ref_l07_o+2 )>>2 ;
        `SIZE_16 : ref_flt_d00_w = ( ref_d01_o+(ref_d00_o<<1)+ref_l15_o+2 )>>2 ;
        `SIZE_32 : ref_flt_d00_w = ( ref_d01_o+(ref_d00_o<<1)+ref_l31_o+2 )>>2 ;
        default  : ref_flt_d00_w =              ref_d00_o                      ;
      endcase
      // 01-06
      ref_flt_d01_w = ( ref_d02_o+(ref_d01_o<<1)+ref_d00_o+2 )>>2 ;
      ref_flt_d02_w = ( ref_d03_o+(ref_d02_o<<1)+ref_d01_o+2 )>>2 ;
      ref_flt_d03_w = ( ref_d04_o+(ref_d03_o<<1)+ref_d02_o+2 )>>2 ;
      ref_flt_d04_w = ( ref_d05_o+(ref_d04_o<<1)+ref_d03_o+2 )>>2 ;
      ref_flt_d05_w = ( ref_d06_o+(ref_d05_o<<1)+ref_d04_o+2 )>>2 ;
      ref_flt_d06_w = ( ref_d07_o+(ref_d06_o<<1)+ref_d05_o+2 )>>2 ;
      // 07
      if( size_i==`SIZE_08 ) begin
        ref_flt_d07_w =              ref_d07_o                      ;
      end
      else begin
        ref_flt_d07_w = ( ref_d08_o+(ref_d07_o<<1)+ref_d06_o+2 )>>2 ;
      end
      // 08-14
      ref_flt_d08_w = ( ref_d09_o+(ref_d08_o<<1)+ref_d07_o+2 )>>2 ;
      ref_flt_d09_w = ( ref_d10_o+(ref_d09_o<<1)+ref_d08_o+2 )>>2 ;
      ref_flt_d10_w = ( ref_d11_o+(ref_d10_o<<1)+ref_d09_o+2 )>>2 ;
      ref_flt_d11_w = ( ref_d12_o+(ref_d11_o<<1)+ref_d10_o+2 )>>2 ;
      ref_flt_d12_w = ( ref_d13_o+(ref_d12_o<<1)+ref_d11_o+2 )>>2 ;
      ref_flt_d13_w = ( ref_d14_o+(ref_d13_o<<1)+ref_d12_o+2 )>>2 ;
      ref_flt_d14_w = ( ref_d15_o+(ref_d14_o<<1)+ref_d13_o+2 )>>2 ;
      // 15
      if( size_i==`SIZE_16 ) begin
        ref_flt_d15_w =              ref_d15_o ;
      end
      else begin
        ref_flt_d15_w = ( ref_d16_o+(ref_d15_o<<1)+ref_d14_o+2 )>>2 ;
      end
      // 16-31
      ref_flt_d16_w = ( ref_d17_o+(ref_d16_o<<1)+ref_d15_o+2 )>>2 ;
      ref_flt_d17_w = ( ref_d18_o+(ref_d17_o<<1)+ref_d16_o+2 )>>2 ;
      ref_flt_d18_w = ( ref_d19_o+(ref_d18_o<<1)+ref_d17_o+2 )>>2 ;
      ref_flt_d19_w = ( ref_d20_o+(ref_d19_o<<1)+ref_d18_o+2 )>>2 ;
      ref_flt_d20_w = ( ref_d21_o+(ref_d20_o<<1)+ref_d19_o+2 )>>2 ;
      ref_flt_d21_w = ( ref_d22_o+(ref_d21_o<<1)+ref_d20_o+2 )>>2 ;
      ref_flt_d22_w = ( ref_d23_o+(ref_d22_o<<1)+ref_d21_o+2 )>>2 ;
      ref_flt_d23_w = ( ref_d24_o+(ref_d23_o<<1)+ref_d22_o+2 )>>2 ;
      ref_flt_d24_w = ( ref_d25_o+(ref_d24_o<<1)+ref_d23_o+2 )>>2 ;
      ref_flt_d25_w = ( ref_d26_o+(ref_d25_o<<1)+ref_d24_o+2 )>>2 ;
      ref_flt_d26_w = ( ref_d27_o+(ref_d26_o<<1)+ref_d25_o+2 )>>2 ;
      ref_flt_d27_w = ( ref_d28_o+(ref_d27_o<<1)+ref_d26_o+2 )>>2 ;
      ref_flt_d28_w = ( ref_d29_o+(ref_d28_o<<1)+ref_d27_o+2 )>>2 ;
      ref_flt_d29_w = ( ref_d30_o+(ref_d29_o<<1)+ref_d28_o+2 )>>2 ;
      ref_flt_d30_w = ( ref_d31_o+(ref_d30_o<<1)+ref_d29_o+2 )>>2 ;
      ref_flt_d31_w =              ref_d31_o                      ;
    end
    else begin
      ref_flt_d00_w = ref_d00_o ; ref_flt_d01_w = ref_d01_o ;
      ref_flt_d02_w = ref_d02_o ; ref_flt_d03_w = ref_d03_o ;
      ref_flt_d04_w = ref_d04_o ; ref_flt_d05_w = ref_d05_o ;
      ref_flt_d06_w = ref_d06_o ; ref_flt_d07_w = ref_d07_o ;
      ref_flt_d08_w = ref_d08_o ; ref_flt_d09_w = ref_d09_o ;
      ref_flt_d10_w = ref_d10_o ; ref_flt_d11_w = ref_d11_o ;
      ref_flt_d12_w = ref_d12_o ; ref_flt_d13_w = ref_d13_o ;
      ref_flt_d14_w = ref_d14_o ; ref_flt_d15_w = ref_d15_o ;
      ref_flt_d16_w = ref_d16_o ; ref_flt_d17_w = ref_d17_o ;
      ref_flt_d18_w = ref_d18_o ; ref_flt_d19_w = ref_d19_o ;
      ref_flt_d20_w = ref_d20_o ; ref_flt_d21_w = ref_d21_o ;
      ref_flt_d22_w = ref_d22_o ; ref_flt_d23_w = ref_d23_o ;
      ref_flt_d24_w = ref_d24_o ; ref_flt_d25_w = ref_d25_o ;
      ref_flt_d26_w = ref_d26_o ; ref_flt_d27_w = ref_d27_o ;
      ref_flt_d28_w = ref_d28_o ; ref_flt_d29_w = ref_d29_o ;
      ref_flt_d30_w = ref_d30_o ; ref_flt_d31_w = ref_d31_o ;
    end
  end


//--- WRITE ----------------------------
  // rec_4x4_x/y_w
  assign rec_4x4_x_w  = {rec_pos_i[6],rec_pos_i[4],rec_pos_i[2],rec_pos_i[0]} ;
  assign rec_4x4_y_w  = {rec_pos_i[7],rec_pos_i[5],rec_pos_i[3],rec_pos_i[1]} ;
  assign rec_offset_w = (rec_sel_i==`TYPE_Y) ? 4 : 3 ;

  // write enable
  always @(posedge clk or negedge rstn )  begin
    if( !rstn ) begin
      wr_ena_r <= 0 ;
    end
    else begin
      if( rec_val_i && ( ((rec_siz_i==`SIZE_04)                 )    // TODO
                       ||((rec_siz_i==`SIZE_08)&&(rec_idx_i==04))    // TODO
                       ||((rec_siz_i==`SIZE_16)&&(rec_idx_i==14))    // TODO
                       ||((rec_siz_i==`SIZE_32)&&(rec_idx_i==31))    // TODO
                       )
      ) begin
        wr_ena_r <= 1 ;
      end
      else if( wr_done_w ) begin
        wr_ena_r <= 0 ;
      end
    end
  end

  assign wr_ena_row_o = wr_ena_r ;
  assign wr_ena_col_o = wr_ena_r ;

  // write counter
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      wr_cnt_r <= 0 ;
    end
    else if( wr_ena_r ) begin
      if( wr_done_w ) begin
        wr_cnt_r <= 0 ;
      end
      else begin
        wr_cnt_r <= wr_cnt_r + 1 ;
      end
    end
  end

  // done flag
  always @(*) begin
    case( rec_siz_i )
      `SIZE_04 : wr_done_w = ( wr_cnt_r==0 );
      `SIZE_08 : wr_done_w = ( wr_cnt_r==1 );
      `SIZE_16 : wr_done_w = ( wr_cnt_r==3 );
      `SIZE_32 : wr_done_w = ( wr_cnt_r==7 );
    endcase
  end

  // delay
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      wr_done_r <= 0 ;
    else begin
      wr_done_r <= wr_ena_r & wr_done_w ;
    end
  end

  // write address for col & row
  always @(posedge clk or negedge rstn ) begin
    if(!rstn) begin
      wr_adr_row_o <= 0 ;
      wr_adr_col_o <= 0 ;
    end
    else begin
      case( rec_siz_i )
        `SIZE_04 : begin    if( rec_val_i ) begin
                              wr_adr_row_o <= (rec_4x4_y_w<<rec_offset_w) + rec_4x4_x_w ;
                              wr_adr_col_o <= (rec_4x4_x_w<<rec_offset_w) + rec_4x4_y_w ;
                            end
        end
        `SIZE_08 : begin    if( rec_val_i && (rec_idx_i==4) ) begin
                              wr_adr_row_o <= ((rec_4x4_y_w+1)<<rec_offset_w) + rec_4x4_x_w ;
                              wr_adr_col_o <= ((rec_4x4_x_w+1)<<rec_offset_w) + rec_4x4_y_w ;
                            end
                            else begin
                              if( wr_ena_r ) begin
                                wr_adr_row_o <= wr_adr_row_o + 1 ;
                                wr_adr_col_o <= wr_adr_col_o + 1 ;
                              end
                            end
        end
        `SIZE_16 : begin    if( rec_val_i && (rec_idx_i==14) ) begin
                              wr_adr_row_o <= ((rec_4x4_y_w+3)<<rec_offset_w) + rec_4x4_x_w ;
                              wr_adr_col_o <= ((rec_4x4_x_w+3)<<rec_offset_w) + rec_4x4_y_w ;
                            end
                            else begin
                              if( wr_ena_r )begin
                                wr_adr_row_o <= wr_adr_row_o + 1 ;
                                wr_adr_col_o <= wr_adr_col_o + 1 ;
                              end
                            end
        end
        `SIZE_32 : begin    if( rec_val_i && (rec_idx_i==31) ) begin
                              wr_adr_row_o <= ((rec_4x4_y_w+7)<<rec_offset_w) + rec_4x4_x_w ;
                              wr_adr_col_o <= ((rec_4x4_x_w+7)<<rec_offset_w) + rec_4x4_y_w ;
                            end
                            else begin
                              if( wr_ena_r )begin
                                wr_adr_row_o <= wr_adr_row_o + 1 ;
                                wr_adr_col_o <= wr_adr_col_o + 1 ;
                              end
                            end
        end
      endcase
    end
  end

  // write data for row & col
  always @(*) begin
                      wr_dat_row_o = 0 ;
                      wr_dat_col_o = 0 ;
    if( wr_ena_r ) begin
      case( wr_cnt_r )
        0  : begin    wr_dat_row_o = {ref_r00_o,ref_r01_o,ref_r02_o,ref_r03_o} ;
                      wr_dat_col_o = {ref_t00_o,ref_t01_o,ref_t02_o,ref_t03_o} ;
        end
        1  : begin    wr_dat_row_o = {ref_r04_o,ref_r05_o,ref_r06_o,ref_r07_o} ;
                      wr_dat_col_o = {ref_t04_o,ref_t05_o,ref_t06_o,ref_t07_o} ;
        end
        2  : begin    wr_dat_row_o = {ref_r08_o,ref_r09_o,ref_r10_o,ref_r11_o} ;
                      wr_dat_col_o = {ref_t08_o,ref_t09_o,ref_t10_o,ref_t11_o} ;
        end
        3  : begin    wr_dat_row_o = {ref_r12_o,ref_r13_o,ref_r14_o,ref_r15_o} ;
                      wr_dat_col_o = {ref_t12_o,ref_t13_o,ref_t14_o,ref_t15_o} ;
        end
        4  : begin    wr_dat_row_o = {ref_r16_o,ref_r17_o,ref_r18_o,ref_r19_o} ;
                      wr_dat_col_o = {ref_t16_o,ref_t17_o,ref_t18_o,ref_t19_o} ;
        end
        5  : begin    wr_dat_row_o = {ref_r20_o,ref_r21_o,ref_r22_o,ref_r23_o} ;
                      wr_dat_col_o = {ref_t20_o,ref_t21_o,ref_t22_o,ref_t23_o} ;
        end
        6  : begin    wr_dat_row_o = {ref_r24_o,ref_r25_o,ref_r26_o,ref_r27_o} ;
                      wr_dat_col_o = {ref_t24_o,ref_t25_o,ref_t26_o,ref_t27_o} ;
        end
        7  : begin    wr_dat_row_o = {ref_r28_o,ref_r29_o,ref_r30_o,ref_r31_o} ;
                      wr_dat_col_o = {ref_t28_o,ref_t29_o,ref_t30_o,ref_t31_o} ;
        end
      endcase
    end
  end

  // wr_ena_fra_o
  assign wr_ena_fra_o = wr_frame_flag && wr_ena_r ;

  // wr_ena_fra_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      wr_frame_flag <= 0 ;
    end
    else if( rec_bgn_i ) begin
      case( rec_siz_i )
        `SIZE_04 : begin if( ((rec_sel_i==`TYPE_Y)&&(rec_4x4_y_w==15))
                           ||((rec_sel_i!=`TYPE_Y)&&(rec_4x4_y_w==7 )) )    wr_frame_flag <= 1 ;
                         else                                               wr_frame_flag <= 0 ;
        end
        `SIZE_08 : begin if( ((rec_sel_i==`TYPE_Y)&&(rec_4x4_y_w==14))
                           ||((rec_sel_i!=`TYPE_Y)&&(rec_4x4_y_w==6 )) )    wr_frame_flag <= 1 ;
                         else                                               wr_frame_flag <= 0 ;
        end
        `SIZE_16 : begin if( ((rec_sel_i==`TYPE_Y)&&(rec_4x4_y_w==12))
                           ||((rec_sel_i!=`TYPE_Y)&&(rec_4x4_y_w==4 )) )    wr_frame_flag <= 1 ;
                         else                                               wr_frame_flag <= 0 ;
        end
        `SIZE_32 : begin if( ((rec_sel_i==`TYPE_Y)&&(rec_4x4_y_w==8 )) )    wr_frame_flag <= 1 ;
                           //((rec_sel_i!=`TYPE_Y)&&(rec_4x4_y_w==4 ))      // size of chroma cannot be 32
                         else                                               wr_frame_flag <= 0 ;
        end
        default  : begin                                                    wr_frame_flag <= 0 ;
        end
      endcase
    end
  end

  // write address for frame
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      wr_adr_fra_o <= 0 ;
    else begin
      if( wr_ena_fra_o ) begin
        wr_adr_fra_o <= wr_adr_fra_o + 1 ;
      end
      else begin
        wr_adr_fra_o <= (ctu_x_cur_i<<rec_offset_w) + rec_4x4_x_w ;
      end
    end
  end

  // write data for frame
  assign wr_dat_fra_o = wr_dat_row_o ;



//--- FEEDBACK -------------------------
  // done_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      done_o <= 0 ;
    end
    else begin
      done_o <= wr_done_r ;
    end
  end

  // pre_ready_o
  always @(posedge clk or negedge rstn) begin
    if( !rstn ) begin
      pre_ready_o <= 0 ;
    end
    else begin
      pre_ready_o <= ( cur_state_r==PADDING );
    end
  end


//--- REFERENCE -----------------------
  // top-left
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_tl_o <= 0 ;
    end
    else begin
      case( cur_state_r )
        READ     : begin    if( rd_cnt_r==1 ) begin
                              if( (pu_4x4_x_w==0) && (pu_4x4_y_w==0) ) begin
                                case( sel_i )
                                  `TYPE_Y : ref_tl_o <= ref_tl_y_r ;
                                  `TYPE_U : ref_tl_o <= ref_tl_u_r ;
                                  `TYPE_V : ref_tl_o <= ref_tl_v_r ;
                                endcase
                              end
                              else if( pu_4x4_x_w==0 ) begin
                                case( pu_4x4_y_w )
                                  1  : ref_tl_o <= ref_l_00_r ;
                                  2  : ref_tl_o <= ref_l_01_r ;
                                  3  : ref_tl_o <= ref_l_02_r ;
                                  4  : ref_tl_o <= ref_l_03_r ;
                                  5  : ref_tl_o <= ref_l_04_r ;
                                  6  : ref_tl_o <= ref_l_05_r ;
                                  7  : ref_tl_o <= ref_l_06_r ;
                                  8  : ref_tl_o <= ref_l_07_r ;
                                  9  : ref_tl_o <= ref_l_08_r ;
                                  10 : ref_tl_o <= ref_l_09_r ;
                                  11 : ref_tl_o <= ref_l_10_r ;
                                  12 : ref_tl_o <= ref_l_11_r ;
                                  13 : ref_tl_o <= ref_l_12_r ;
                                  14 : ref_tl_o <= ref_l_13_r ;
                                  15 : ref_tl_o <= ref_l_14_r ;
                                endcase
                              end
                              else if( pu_4x4_y_w==0 ) begin
                                case( pu_4x4_x_w )
                                  1  : ref_tl_o <= ref_t_00_r ;
                                  2  : ref_tl_o <= ref_t_01_r ;
                                  3  : ref_tl_o <= ref_t_02_r ;
                                  4  : ref_tl_o <= ref_t_03_r ;
                                  5  : ref_tl_o <= ref_t_04_r ;
                                  6  : ref_tl_o <= ref_t_05_r ;
                                  7  : ref_tl_o <= ref_t_06_r ;
                                  8  : ref_tl_o <= ref_t_07_r ;
                                  9  : ref_tl_o <= ref_t_08_r ;
                                  10 : ref_tl_o <= ref_t_09_r ;
                                  11 : ref_tl_o <= ref_t_10_r ;
                                  12 : ref_tl_o <= ref_t_11_r ;
                                  13 : ref_tl_o <= ref_t_12_r ;
                                  14 : ref_tl_o <= ref_t_13_r ;
                                  15 : ref_tl_o <= ref_t_14_r ;
                                endcase
                              end
                              else begin
                                if( (position_of_luma_w[1:0]==2'b10)
                                 || (position_of_luma_w[3:0]==4'b1000)
                                 || (position_of_luma_w[5:0]==6'b100000)
                                 || (position_of_luma_w[7:0]==8'b10000000)
                                ) begin
                                  ref_tl_o <= rd_dat_col_0_w ;
                                end
                                else begin
                                  ref_tl_o <= rd_dat_row_0_w ;
                                end
                              end
                            end
        end
        PADDING  : ref_tl_o <= ref_pad_tl_w ;
        FILTER   : ref_tl_o <= ref_flt_tl_w ;
      endcase
    end
  end

  // top
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_t00_o <= 0 ; ref_t01_o <= 0 ; ref_t02_o <= 0 ; ref_t03_o <= 0 ;
      ref_t04_o <= 0 ; ref_t05_o <= 0 ; ref_t06_o <= 0 ; ref_t07_o <= 0 ;
      ref_t08_o <= 0 ; ref_t09_o <= 0 ; ref_t10_o <= 0 ; ref_t11_o <= 0 ;
      ref_t12_o <= 0 ; ref_t13_o <= 0 ; ref_t14_o <= 0 ; ref_t15_o <= 0 ;
      ref_t16_o <= 0 ; ref_t17_o <= 0 ; ref_t18_o <= 0 ; ref_t19_o <= 0 ;
      ref_t20_o <= 0 ; ref_t21_o <= 0 ; ref_t22_o <= 0 ; ref_t23_o <= 0 ;
      ref_t24_o <= 0 ; ref_t25_o <= 0 ; ref_t26_o <= 0 ; ref_t27_o <= 0 ;
      ref_t28_o <= 0 ; ref_t29_o <= 0 ; ref_t30_o <= 0 ; ref_t31_o <= 0 ;
    end
    else begin
      case( cur_state_r )
        READ     : begin    case( rd_cnt_r )
                              2 : begin     if( pu_4x4_y_w==0 ) begin
                                              ref_t00_o <= rd_dat_fra_3_w ; ref_t01_o <= rd_dat_fra_2_w ;
                                              ref_t02_o <= rd_dat_fra_1_w ; ref_t03_o <= rd_dat_fra_0_w ;
                                            end
                                            else begin
                                              ref_t00_o <= rd_dat_row_3_w ; ref_t01_o <= rd_dat_row_2_w ;
                                              ref_t02_o <= rd_dat_row_1_w ; ref_t03_o <= rd_dat_row_0_w ;
                                            end
                              end
                              3 : begin     if( (size_i==`SIZE_08)||(size_i==`SIZE_16)||(size_i==`SIZE_32) ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_t04_o <= rd_dat_fra_3_w ; ref_t05_o <= rd_dat_fra_2_w ;
                                                ref_t06_o <= rd_dat_fra_1_w ; ref_t07_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_t04_o <= rd_dat_row_3_w ; ref_t05_o <= rd_dat_row_2_w ;
                                                ref_t06_o <= rd_dat_row_1_w ; ref_t07_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              4 : begin     if( (size_i==`SIZE_16)||(size_i==`SIZE_32) ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_t08_o <= rd_dat_fra_3_w ; ref_t09_o <= rd_dat_fra_2_w ;
                                                ref_t10_o <= rd_dat_fra_1_w ; ref_t11_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_t08_o <= rd_dat_row_3_w ; ref_t09_o <= rd_dat_row_2_w ;
                                                ref_t10_o <= rd_dat_row_1_w ; ref_t11_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              5 : begin     if( (size_i==`SIZE_16)||(size_i==`SIZE_32) ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_t12_o <= rd_dat_fra_3_w ; ref_t13_o <= rd_dat_fra_2_w ;
                                                ref_t14_o <= rd_dat_fra_1_w ; ref_t15_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_t12_o <= rd_dat_row_3_w ; ref_t13_o <= rd_dat_row_2_w ;
                                                ref_t14_o <= rd_dat_row_1_w ; ref_t15_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              6 : begin     if( (size_i==`SIZE_32) ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_t16_o <= rd_dat_fra_3_w ; ref_t17_o <= rd_dat_fra_2_w ;
                                                ref_t18_o <= rd_dat_fra_1_w ; ref_t19_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_t16_o <= rd_dat_row_3_w ; ref_t17_o <= rd_dat_row_2_w ;
                                                ref_t18_o <= rd_dat_row_1_w ; ref_t19_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              7 : begin     if( size_i==`SIZE_32 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_t20_o <= rd_dat_fra_3_w ; ref_t21_o <= rd_dat_fra_2_w ;
                                                ref_t22_o <= rd_dat_fra_1_w ; ref_t23_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_t20_o <= rd_dat_row_3_w ; ref_t21_o <= rd_dat_row_2_w ;
                                                ref_t22_o <= rd_dat_row_1_w ; ref_t23_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              8 : begin     if( size_i==`SIZE_32 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_t24_o <= rd_dat_fra_3_w ; ref_t25_o <= rd_dat_fra_2_w ;
                                                ref_t26_o <= rd_dat_fra_1_w ; ref_t27_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_t24_o <= rd_dat_row_3_w ; ref_t25_o <= rd_dat_row_2_w ;
                                                ref_t26_o <= rd_dat_row_1_w ; ref_t27_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              9 : begin     if( size_i==`SIZE_32 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_t28_o <= rd_dat_fra_3_w ; ref_t29_o <= rd_dat_fra_2_w ;
                                                ref_t30_o <= rd_dat_fra_1_w ; ref_t31_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_t28_o <= rd_dat_row_3_w ; ref_t29_o <= rd_dat_row_2_w ;
                                                ref_t30_o <= rd_dat_row_1_w ; ref_t31_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                            endcase
        end
        PADDING  : begin    ref_t00_o <= ref_pad_t00_w ; ref_t01_o <= ref_pad_t01_w ;
                            ref_t02_o <= ref_pad_t02_w ; ref_t03_o <= ref_pad_t03_w ;
                            ref_t04_o <= ref_pad_t04_w ; ref_t05_o <= ref_pad_t05_w ;
                            ref_t06_o <= ref_pad_t06_w ; ref_t07_o <= ref_pad_t07_w ;
                            ref_t08_o <= ref_pad_t08_w ; ref_t09_o <= ref_pad_t09_w ;
                            ref_t10_o <= ref_pad_t10_w ; ref_t11_o <= ref_pad_t11_w ;
                            ref_t12_o <= ref_pad_t12_w ; ref_t13_o <= ref_pad_t13_w ;
                            ref_t14_o <= ref_pad_t14_w ; ref_t15_o <= ref_pad_t15_w ;
                            ref_t16_o <= ref_pad_t16_w ; ref_t17_o <= ref_pad_t17_w ;
                            ref_t18_o <= ref_pad_t18_w ; ref_t19_o <= ref_pad_t19_w ;
                            ref_t20_o <= ref_pad_t20_w ; ref_t21_o <= ref_pad_t21_w ;
                            ref_t22_o <= ref_pad_t22_w ; ref_t23_o <= ref_pad_t23_w ;
                            ref_t24_o <= ref_pad_t24_w ; ref_t25_o <= ref_pad_t25_w ;
                            ref_t26_o <= ref_pad_t26_w ; ref_t27_o <= ref_pad_t27_w ;
                            ref_t28_o <= ref_pad_t28_w ; ref_t29_o <= ref_pad_t29_w ;
                            ref_t30_o <= ref_pad_t30_w ; ref_t31_o <= ref_pad_t31_w ;
        end
        FILTER   : begin    ref_t00_o <= ref_flt_t00_w ; ref_t01_o <= ref_flt_t01_w ;
                            ref_t02_o <= ref_flt_t02_w ; ref_t03_o <= ref_flt_t03_w ;
                            ref_t04_o <= ref_flt_t04_w ; ref_t05_o <= ref_flt_t05_w ;
                            ref_t06_o <= ref_flt_t06_w ; ref_t07_o <= ref_flt_t07_w ;
                            ref_t08_o <= ref_flt_t08_w ; ref_t09_o <= ref_flt_t09_w ;
                            ref_t10_o <= ref_flt_t10_w ; ref_t11_o <= ref_flt_t11_w ;
                            ref_t12_o <= ref_flt_t12_w ; ref_t13_o <= ref_flt_t13_w ;
                            ref_t14_o <= ref_flt_t14_w ; ref_t15_o <= ref_flt_t15_w ;
                            ref_t16_o <= ref_flt_t16_w ; ref_t17_o <= ref_flt_t17_w ;
                            ref_t18_o <= ref_flt_t18_w ; ref_t19_o <= ref_flt_t19_w ;
                            ref_t20_o <= ref_flt_t20_w ; ref_t21_o <= ref_flt_t21_w ;
                            ref_t22_o <= ref_flt_t22_w ; ref_t23_o <= ref_flt_t23_w ;
                            ref_t24_o <= ref_flt_t24_w ; ref_t25_o <= ref_flt_t25_w ;
                            ref_t26_o <= ref_flt_t26_w ; ref_t27_o <= ref_flt_t27_w ;
                            ref_t28_o <= ref_flt_t28_w ; ref_t29_o <= ref_flt_t29_w ;
                            ref_t30_o <= ref_flt_t30_w ; ref_t31_o <= ref_flt_t31_w ;
        end
        WRITE    : begin    if( rec_val_i ) begin
                              case( rec_siz_i )
                                `SIZE_04 : begin                    ref_t00_o <= rec_dat_28_w ; ref_t01_o <= rec_dat_20_w ;
                                                                    ref_t02_o <= rec_dat_12_w ; ref_t03_o <= rec_dat_04_w ;
                                end
                                `SIZE_08 : begin    case( rec_idx_i )
                                                      0  : begin    ref_t00_o <= rec_dat_24_w ; ref_t01_o <= rec_dat_16_w ;
                                                                    ref_t02_o <= rec_dat_08_w ; ref_t03_o <= rec_dat_00_w ;
                                                      end
                                                      4  : begin    ref_t04_o <= rec_dat_24_w ; ref_t05_o <= rec_dat_16_w ;
                                                                    ref_t06_o <= rec_dat_08_w ; ref_t07_o <= rec_dat_00_w ;
                                                      end
                                                    endcase
                                end
                                `SIZE_16 : begin    case( rec_idx_i )
                                                      0  : begin    ref_t00_o <= rec_dat_16_w ; ref_t01_o <= rec_dat_00_w ;
                                                      end
                                                      2  : begin    ref_t02_o <= rec_dat_16_w ; ref_t03_o <= rec_dat_00_w ;
                                                      end
                                                      4  : begin    ref_t04_o <= rec_dat_16_w ; ref_t05_o <= rec_dat_00_w ;
                                                      end
                                                      6  : begin    ref_t06_o <= rec_dat_16_w ; ref_t07_o <= rec_dat_00_w ;
                                                      end
                                                      8  : begin    ref_t08_o <= rec_dat_16_w ; ref_t09_o <= rec_dat_00_w ;
                                                      end
                                                      10 : begin    ref_t10_o <= rec_dat_16_w ; ref_t11_o <= rec_dat_00_w ;
                                                      end
                                                      12 : begin    ref_t12_o <= rec_dat_16_w ; ref_t13_o <= rec_dat_00_w ;
                                                      end
                                                      14 : begin    ref_t14_o <= rec_dat_16_w ; ref_t15_o <= rec_dat_00_w ;
                                                      end
                                                    endcase
                                end
                                `SIZE_32 : begin    case( rec_idx_i )
                                                      0  :          ref_t00_o <= rec_dat_00_w ;
                                                      1  :          ref_t01_o <= rec_dat_00_w ;
                                                      2  :          ref_t02_o <= rec_dat_00_w ;
                                                      3  :          ref_t03_o <= rec_dat_00_w ;
                                                      4  :          ref_t04_o <= rec_dat_00_w ;
                                                      5  :          ref_t05_o <= rec_dat_00_w ;
                                                      6  :          ref_t06_o <= rec_dat_00_w ;
                                                      7  :          ref_t07_o <= rec_dat_00_w ;
                                                      8  :          ref_t08_o <= rec_dat_00_w ;
                                                      9  :          ref_t09_o <= rec_dat_00_w ;
                                                      10 :          ref_t10_o <= rec_dat_00_w ;
                                                      11 :          ref_t11_o <= rec_dat_00_w ;
                                                      12 :          ref_t12_o <= rec_dat_00_w ;
                                                      13 :          ref_t13_o <= rec_dat_00_w ;
                                                      14 :          ref_t14_o <= rec_dat_00_w ;
                                                      15 :          ref_t15_o <= rec_dat_00_w ;
                                                      16 :          ref_t16_o <= rec_dat_00_w ;
                                                      17 :          ref_t17_o <= rec_dat_00_w ;
                                                      18 :          ref_t18_o <= rec_dat_00_w ;
                                                      19 :          ref_t19_o <= rec_dat_00_w ;
                                                      20 :          ref_t20_o <= rec_dat_00_w ;
                                                      21 :          ref_t21_o <= rec_dat_00_w ;
                                                      22 :          ref_t22_o <= rec_dat_00_w ;
                                                      23 :          ref_t23_o <= rec_dat_00_w ;
                                                      24 :          ref_t24_o <= rec_dat_00_w ;
                                                      25 :          ref_t25_o <= rec_dat_00_w ;
                                                      26 :          ref_t26_o <= rec_dat_00_w ;
                                                      27 :          ref_t27_o <= rec_dat_00_w ;
                                                      28 :          ref_t28_o <= rec_dat_00_w ;
                                                      29 :          ref_t29_o <= rec_dat_00_w ;
                                                      30 :          ref_t30_o <= rec_dat_00_w ;
                                                      31 :          ref_t31_o <= rec_dat_00_w ;
                                                    endcase
                                end
                              endcase
                            end
        end
      endcase
    end
  end

  // right
  always @(posedge clk or negedge rstn ) begin
    if(!rstn) begin
      ref_r00_o <= 0 ; ref_r01_o <= 0 ; ref_r02_o <= 0 ; ref_r03_o <= 0 ;
      ref_r04_o <= 0 ; ref_r05_o <= 0 ; ref_r06_o <= 0 ; ref_r07_o <= 0 ;
      ref_r08_o <= 0 ; ref_r09_o <= 0 ; ref_r10_o <= 0 ; ref_r11_o <= 0 ;
      ref_r12_o <= 0 ; ref_r13_o <= 0 ; ref_r14_o <= 0 ; ref_r15_o <= 0 ;
      ref_r16_o <= 0 ; ref_r17_o <= 0 ; ref_r18_o <= 0 ; ref_r19_o <= 0 ;
      ref_r20_o <= 0 ; ref_r21_o <= 0 ; ref_r22_o <= 0 ; ref_r23_o <= 0 ;
      ref_r24_o <= 0 ; ref_r25_o <= 0 ; ref_r26_o <= 0 ; ref_r27_o <= 0 ;
      ref_r28_o <= 0 ; ref_r29_o <= 0 ; ref_r30_o <= 0 ; ref_r31_o <= 0 ;
    end
    else begin
      case( cur_state_r )
        READ     : begin    case( rd_cnt_r )
                              3  : begin    if( size_i==`SIZE_04 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r00_o <= rd_dat_fra_3_w ; ref_r01_o<=rd_dat_fra_2_w ;
                                                ref_r02_o <= rd_dat_fra_1_w ; ref_r03_o<=rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r00_o <= rd_dat_row_3_w ; ref_r01_o<=rd_dat_row_2_w ;
                                                ref_r02_o <= rd_dat_row_1_w ; ref_r03_o<=rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              4  : begin    if( size_i==`SIZE_08 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r00_o <= rd_dat_fra_3_w ; ref_r01_o <= rd_dat_fra_2_w ;
                                                ref_r02_o <= rd_dat_fra_1_w ; ref_r03_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r00_o <= rd_dat_row_3_w ; ref_r01_o <= rd_dat_row_2_w ;
                                                ref_r02_o <= rd_dat_row_1_w ; ref_r03_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              5  : begin    if( size_i==`SIZE_08 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r04_o <= rd_dat_fra_3_w ; ref_r05_o <= rd_dat_fra_2_w ;
                                                ref_r06_o <= rd_dat_fra_1_w ; ref_r07_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r04_o <= rd_dat_row_3_w ; ref_r05_o <= rd_dat_row_2_w ;
                                                ref_r06_o <= rd_dat_row_1_w ; ref_r07_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              6  : begin    if( size_i==`SIZE_16 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r00_o <= rd_dat_fra_3_w ; ref_r01_o <= rd_dat_fra_2_w ;
                                                ref_r02_o <= rd_dat_fra_1_w ; ref_r03_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r00_o <= rd_dat_row_3_w ; ref_r01_o <= rd_dat_row_2_w ;
                                                ref_r02_o <= rd_dat_row_1_w ; ref_r03_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              7  : begin    if( size_i==`SIZE_16 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r04_o <= rd_dat_fra_3_w ; ref_r05_o <= rd_dat_fra_2_w ;
                                                ref_r06_o <= rd_dat_fra_1_w ; ref_r07_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r04_o <= rd_dat_row_3_w ; ref_r05_o <= rd_dat_row_2_w ;
                                                ref_r06_o <= rd_dat_row_1_w ; ref_r07_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              8  : begin    if( size_i==`SIZE_16 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r08_o <= rd_dat_fra_3_w ; ref_r09_o <= rd_dat_fra_2_w ;
                                                ref_r10_o <= rd_dat_fra_1_w ; ref_r11_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r08_o <= rd_dat_row_3_w ; ref_r09_o <= rd_dat_row_2_w ;
                                                ref_r10_o <= rd_dat_row_1_w ; ref_r11_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              9  : begin    if( size_i==`SIZE_16 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r12_o <= rd_dat_fra_3_w ; ref_r13_o <= rd_dat_fra_2_w ;
                                                ref_r14_o <= rd_dat_fra_1_w ; ref_r15_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r12_o <= rd_dat_row_3_w ; ref_r13_o <= rd_dat_row_2_w ;
                                                ref_r14_o <= rd_dat_row_1_w ; ref_r15_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              10 : begin    if( size_i==`SIZE_32 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r00_o <= rd_dat_fra_3_w ; ref_r01_o <= rd_dat_fra_2_w ;
                                                ref_r02_o <= rd_dat_fra_1_w ; ref_r03_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r00_o <= rd_dat_row_3_w ; ref_r01_o <= rd_dat_row_2_w ;
                                                ref_r02_o <= rd_dat_row_1_w ; ref_r03_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              11 : begin    if( size_i==`SIZE_32 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r04_o <= rd_dat_fra_3_w ; ref_r05_o <= rd_dat_fra_2_w ;
                                                ref_r06_o <= rd_dat_fra_1_w ; ref_r07_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r04_o <= rd_dat_row_3_w ; ref_r05_o <= rd_dat_row_2_w ;
                                                ref_r06_o <= rd_dat_row_1_w ; ref_r07_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              12 : begin    if( size_i==`SIZE_32 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r08_o <= rd_dat_fra_3_w ; ref_r09_o <= rd_dat_fra_2_w ;
                                                ref_r10_o <= rd_dat_fra_1_w ; ref_r11_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r08_o <= rd_dat_row_3_w ; ref_r09_o <= rd_dat_row_2_w ;
                                                ref_r10_o <= rd_dat_row_1_w ; ref_r11_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              13 : begin    if( size_i==`SIZE_32 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r12_o <= rd_dat_fra_3_w ; ref_r13_o <= rd_dat_fra_2_w ;
                                                ref_r14_o <= rd_dat_fra_1_w ; ref_r15_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r12_o <= rd_dat_row_3_w ; ref_r13_o <= rd_dat_row_2_w ;
                                                ref_r14_o <= rd_dat_row_1_w ; ref_r15_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              14 : begin    if( size_i==`SIZE_32 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r16_o <= rd_dat_fra_3_w ; ref_r17_o <= rd_dat_fra_2_w ;
                                                ref_r18_o <= rd_dat_fra_1_w ; ref_r19_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r16_o <= rd_dat_row_3_w ; ref_r17_o <= rd_dat_row_2_w ;
                                                ref_r18_o <= rd_dat_row_1_w ; ref_r19_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              15 : begin    if( size_i==`SIZE_32 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r20_o <= rd_dat_fra_3_w ; ref_r21_o <= rd_dat_fra_2_w ;
                                                ref_r22_o <= rd_dat_fra_1_w ; ref_r23_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r20_o <= rd_dat_row_3_w ; ref_r21_o <= rd_dat_row_2_w ;
                                                ref_r22_o <= rd_dat_row_1_w ; ref_r23_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              16 : begin    if( size_i==`SIZE_32 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r24_o <= rd_dat_fra_3_w ; ref_r25_o <= rd_dat_fra_2_w ;
                                                ref_r26_o <= rd_dat_fra_1_w ; ref_r27_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r24_o <= rd_dat_row_3_w ; ref_r25_o <= rd_dat_row_2_w ;
                                                ref_r26_o <= rd_dat_row_1_w ; ref_r27_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                              17 : begin    if( size_i==`SIZE_32 ) begin
                                              if( pu_4x4_y_w==0 ) begin
                                                ref_r28_o <= rd_dat_fra_3_w ; ref_r29_o <= rd_dat_fra_2_w ;
                                                ref_r30_o <= rd_dat_fra_1_w ; ref_r31_o <= rd_dat_fra_0_w ;
                                              end
                                              else begin
                                                ref_r28_o <= rd_dat_row_3_w ; ref_r29_o <= rd_dat_row_2_w ;
                                                ref_r30_o <= rd_dat_row_1_w ; ref_r31_o <= rd_dat_row_0_w ;
                                              end
                                            end
                              end
                            endcase
        end
        PADDING  : begin    ref_r00_o <= ref_pad_r00_w ; ref_r01_o <= ref_pad_r01_w ;
                            ref_r02_o <= ref_pad_r02_w ; ref_r03_o <= ref_pad_r03_w ;
                            ref_r04_o <= ref_pad_r04_w ; ref_r05_o <= ref_pad_r05_w ;
                            ref_r06_o <= ref_pad_r06_w ; ref_r07_o <= ref_pad_r07_w ;
                            ref_r08_o <= ref_pad_r08_w ; ref_r09_o <= ref_pad_r09_w ;
                            ref_r10_o <= ref_pad_r10_w ; ref_r11_o <= ref_pad_r11_w ;
                            ref_r12_o <= ref_pad_r12_w ; ref_r13_o <= ref_pad_r13_w ;
                            ref_r14_o <= ref_pad_r14_w ; ref_r15_o <= ref_pad_r15_w ;
                            ref_r16_o <= ref_pad_r16_w ; ref_r17_o <= ref_pad_r17_w ;
                            ref_r18_o <= ref_pad_r18_w ; ref_r19_o <= ref_pad_r19_w ;
                            ref_r20_o <= ref_pad_r20_w ; ref_r21_o <= ref_pad_r21_w ;
                            ref_r22_o <= ref_pad_r22_w ; ref_r23_o <= ref_pad_r23_w ;
                            ref_r24_o <= ref_pad_r24_w ; ref_r25_o <= ref_pad_r25_w ;
                            ref_r26_o <= ref_pad_r26_w ; ref_r27_o <= ref_pad_r27_w ;
                            ref_r28_o <= ref_pad_r28_w ; ref_r29_o <= ref_pad_r29_w ;
                            ref_r30_o <= ref_pad_r30_w ; ref_r31_o <= ref_pad_r31_w ;
        end
        FILTER   : begin    ref_r00_o <= ref_flt_r00_w ; ref_r01_o <= ref_flt_r01_w ;
                            ref_r02_o <= ref_flt_r02_w ; ref_r03_o <= ref_flt_r03_w ;
                            ref_r04_o <= ref_flt_r04_w ; ref_r05_o <= ref_flt_r05_w ;
                            ref_r06_o <= ref_flt_r06_w ; ref_r07_o <= ref_flt_r07_w ;
                            ref_r08_o <= ref_flt_r08_w ; ref_r09_o <= ref_flt_r09_w ;
                            ref_r10_o <= ref_flt_r10_w ; ref_r11_o <= ref_flt_r11_w ;
                            ref_r12_o <= ref_flt_r12_w ; ref_r13_o <= ref_flt_r13_w ;
                            ref_r14_o <= ref_flt_r14_w ; ref_r15_o <= ref_flt_r15_w ;
                            ref_r16_o <= ref_flt_r16_w ; ref_r17_o <= ref_flt_r17_w ;
                            ref_r18_o <= ref_flt_r18_w ; ref_r19_o <= ref_flt_r19_w ;
                            ref_r20_o <= ref_flt_r20_w ; ref_r21_o <= ref_flt_r21_w ;
                            ref_r22_o <= ref_flt_r22_w ; ref_r23_o <= ref_flt_r23_w ;
                            ref_r24_o <= ref_flt_r24_w ; ref_r25_o <= ref_flt_r25_w ;
                            ref_r26_o <= ref_flt_r26_w ; ref_r27_o <= ref_flt_r27_w ;
                            ref_r28_o <= ref_flt_r28_w ; ref_r29_o <= ref_flt_r29_w ;
                            ref_r30_o <= ref_flt_r30_w ; ref_r31_o <= ref_flt_r31_w ;
        end
        WRITE    : begin    if( rec_val_i ) begin
                              case( rec_siz_i )
                                `SIZE_04  : begin    ref_r00_o <= rec_dat_07_w ; ref_r01_o <= rec_dat_06_w ;
                                                     ref_r02_o <= rec_dat_05_w ; ref_r03_o <= rec_dat_04_w ;
                                end
                                `SIZE_08  : begin    if( rec_idx_i==4 )begin
                                                       ref_r00_o <= rec_dat_07_w ; ref_r01_o <= rec_dat_06_w ;
                                                       ref_r02_o <= rec_dat_05_w ; ref_r03_o <= rec_dat_04_w ;
                                                       ref_r04_o <= rec_dat_03_w ; ref_r05_o <= rec_dat_02_w ;
                                                       ref_r06_o <= rec_dat_01_w ; ref_r07_o <= rec_dat_00_w ;
                                                     end
                                end
                                `SIZE_16  : begin    if( rec_idx_i==14 ) begin
                                                       ref_r00_o <= rec_dat_15_w ; ref_r01_o <= rec_dat_14_w ;
                                                       ref_r02_o <= rec_dat_13_w ; ref_r03_o <= rec_dat_12_w ;
                                                       ref_r04_o <= rec_dat_11_w ; ref_r05_o <= rec_dat_10_w ;
                                                       ref_r06_o <= rec_dat_09_w ; ref_r07_o <= rec_dat_08_w ;
                                                       ref_r08_o <= rec_dat_07_w ; ref_r09_o <= rec_dat_06_w ;
                                                       ref_r10_o <= rec_dat_05_w ; ref_r11_o <= rec_dat_04_w ;
                                                       ref_r12_o <= rec_dat_03_w ; ref_r13_o <= rec_dat_02_w ;
                                                       ref_r14_o <= rec_dat_01_w ; ref_r15_o <= rec_dat_00_w ;
                                                     end
                                end
                                `SIZE_32  : begin    if( rec_idx_i==31 ) begin
                                                       ref_r00_o <= rec_dat_31_w ; ref_r01_o <= rec_dat_30_w ;
                                                       ref_r02_o <= rec_dat_29_w ; ref_r03_o <= rec_dat_28_w ;
                                                       ref_r04_o <= rec_dat_27_w ; ref_r05_o <= rec_dat_26_w ;
                                                       ref_r06_o <= rec_dat_25_w ; ref_r07_o <= rec_dat_24_w ;
                                                       ref_r08_o <= rec_dat_23_w ; ref_r09_o <= rec_dat_22_w ;
                                                       ref_r10_o <= rec_dat_21_w ; ref_r11_o <= rec_dat_20_w ;
                                                       ref_r12_o <= rec_dat_19_w ; ref_r13_o <= rec_dat_18_w ;
                                                       ref_r14_o <= rec_dat_17_w ; ref_r15_o <= rec_dat_16_w ;
                                                       ref_r16_o <= rec_dat_15_w ; ref_r17_o <= rec_dat_14_w ;
                                                       ref_r18_o <= rec_dat_13_w ; ref_r19_o <= rec_dat_12_w ;
                                                       ref_r20_o <= rec_dat_11_w ; ref_r21_o <= rec_dat_10_w ;
                                                       ref_r22_o <= rec_dat_09_w ; ref_r23_o <= rec_dat_08_w ;
                                                       ref_r24_o <= rec_dat_07_w ; ref_r25_o <= rec_dat_06_w ;
                                                       ref_r26_o <= rec_dat_05_w ; ref_r27_o <= rec_dat_04_w ;
                                                       ref_r28_o <= rec_dat_03_w ; ref_r29_o <= rec_dat_02_w ;
                                                       ref_r30_o <= rec_dat_01_w ; ref_r31_o <= rec_dat_00_w ;
                                                     end
                                end
                              endcase
                            end
        end
      endcase
    end
  end

  // left
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_l00_o <= 0 ; ref_l01_o <= 0 ; ref_l02_o <= 0 ; ref_l03_o <= 0 ;
      ref_l04_o <= 0 ; ref_l05_o <= 0 ; ref_l06_o <= 0 ; ref_l07_o <= 0 ;
      ref_l08_o <= 0 ; ref_l09_o <= 0 ; ref_l10_o <= 0 ; ref_l11_o <= 0 ;
      ref_l12_o <= 0 ; ref_l13_o <= 0 ; ref_l14_o <= 0 ; ref_l15_o <= 0 ;
      ref_l16_o <= 0 ; ref_l17_o <= 0 ; ref_l18_o <= 0 ; ref_l19_o <= 0 ;
      ref_l20_o <= 0 ; ref_l21_o <= 0 ; ref_l22_o <= 0 ; ref_l23_o <= 0 ;
      ref_l24_o <= 0 ; ref_l25_o <= 0 ; ref_l26_o <= 0 ; ref_l27_o <= 0 ;
      ref_l28_o <= 0 ; ref_l29_o <= 0 ; ref_l30_o <= 0 ; ref_l31_o <= 0 ;
    end
    else begin
      case( cur_state_r )
        READ     : begin    case( rd_cnt_r )
                              2  : begin    ref_l00_o <= rd_dat_col_3_w ; ref_l01_o <= rd_dat_col_2_w ;
                                            ref_l02_o <= rd_dat_col_1_w ; ref_l03_o <= rd_dat_col_0_w ;
                              end
                              3  : begin    if( (size_i==`SIZE_08)||(size_i==`SIZE_16)||(size_i==`SIZE_32) ) begin
                                              ref_l04_o <= rd_dat_col_3_w ; ref_l05_o <= rd_dat_col_2_w ;
                                              ref_l06_o <= rd_dat_col_1_w ; ref_l07_o <= rd_dat_col_0_w ;
                                            end
                              end
                              4  : begin    if( (size_i==`SIZE_16)||(size_i==`SIZE_32) ) begin
                                              ref_l08_o <= rd_dat_col_3_w ; ref_l09_o <= rd_dat_col_2_w ;
                                              ref_l10_o <= rd_dat_col_1_w ; ref_l11_o <= rd_dat_col_0_w ;
                                            end
                              end
                              5  : begin    if( (size_i==`SIZE_16) || (size_i==`SIZE_32) ) begin
                                              ref_l12_o <= rd_dat_col_3_w ; ref_l13_o <= rd_dat_col_2_w ;
                                              ref_l14_o <= rd_dat_col_1_w ; ref_l15_o <= rd_dat_col_0_w ;
                                            end
                              end
                              6  : begin    if( size_i==`SIZE_32 ) begin
                                              ref_l16_o <= rd_dat_col_3_w ; ref_l17_o <= rd_dat_col_2_w ;
                                              ref_l18_o <= rd_dat_col_1_w ; ref_l19_o <= rd_dat_col_0_w ;
                                            end
                              end
                              7  : begin    if( size_i==`SIZE_32 ) begin
                                              ref_l20_o <= rd_dat_col_3_w ; ref_l21_o <= rd_dat_col_2_w ;
                                              ref_l22_o <= rd_dat_col_1_w ; ref_l23_o <= rd_dat_col_0_w ;
                                            end
                              end
                              8  : begin    if( size_i==`SIZE_32 ) begin
                                              ref_l24_o <= rd_dat_col_3_w ; ref_l25_o <= rd_dat_col_2_w ;
                                              ref_l26_o <= rd_dat_col_1_w ; ref_l27_o <= rd_dat_col_0_w ;
                                            end
                              end
                              9  : begin    if( size_i==`SIZE_32 ) begin
                                              ref_l28_o <= rd_dat_col_3_w ; ref_l29_o <= rd_dat_col_2_w ;
                                              ref_l30_o <= rd_dat_col_1_w ; ref_l31_o <= rd_dat_col_0_w ;
                                            end
                              end
                            endcase
        end
        PADDING  : begin    ref_l00_o <= ref_pad_l00_w ; ref_l01_o <= ref_pad_l01_w ;
                            ref_l02_o <= ref_pad_l02_w ; ref_l03_o <= ref_pad_l03_w ;
                            ref_l04_o <= ref_pad_l04_w ; ref_l05_o <= ref_pad_l05_w ;
                            ref_l06_o <= ref_pad_l06_w ; ref_l07_o <= ref_pad_l07_w ;
                            ref_l08_o <= ref_pad_l08_w ; ref_l09_o <= ref_pad_l09_w ;
                            ref_l10_o <= ref_pad_l10_w ; ref_l11_o <= ref_pad_l11_w ;
                            ref_l12_o <= ref_pad_l12_w ; ref_l13_o <= ref_pad_l13_w ;
                            ref_l14_o <= ref_pad_l14_w ; ref_l15_o <= ref_pad_l15_w ;
                            ref_l16_o <= ref_pad_l16_w ; ref_l17_o <= ref_pad_l17_w ;
                            ref_l18_o <= ref_pad_l18_w ; ref_l19_o <= ref_pad_l19_w ;
                            ref_l20_o <= ref_pad_l20_w ; ref_l21_o <= ref_pad_l21_w ;
                            ref_l22_o <= ref_pad_l22_w ; ref_l23_o <= ref_pad_l23_w ;
                            ref_l24_o <= ref_pad_l24_w ; ref_l25_o <= ref_pad_l25_w ;
                            ref_l26_o <= ref_pad_l26_w ; ref_l27_o <= ref_pad_l27_w ;
                            ref_l28_o <= ref_pad_l28_w ; ref_l29_o <= ref_pad_l29_w ;
                            ref_l30_o <= ref_pad_l30_w ; ref_l31_o <= ref_pad_l31_w ;
        end
        FILTER   : begin    ref_l00_o <= ref_flt_l00_w ; ref_l01_o <= ref_flt_l01_w ;
                            ref_l02_o <= ref_flt_l02_w ; ref_l03_o <= ref_flt_l03_w ;
                            ref_l04_o <= ref_flt_l04_w ; ref_l05_o <= ref_flt_l05_w ;
                            ref_l06_o <= ref_flt_l06_w ; ref_l07_o <= ref_flt_l07_w ;
                            ref_l08_o <= ref_flt_l08_w ; ref_l09_o <= ref_flt_l09_w ;
                            ref_l10_o <= ref_flt_l10_w ; ref_l11_o <= ref_flt_l11_w ;
                            ref_l12_o <= ref_flt_l12_w ; ref_l13_o <= ref_flt_l13_w ;
                            ref_l14_o <= ref_flt_l14_w ; ref_l15_o <= ref_flt_l15_w ;
                            ref_l16_o <= ref_flt_l16_w ; ref_l17_o <= ref_flt_l17_w ;
                            ref_l18_o <= ref_flt_l18_w ; ref_l19_o <= ref_flt_l19_w ;
                            ref_l20_o <= ref_flt_l20_w ; ref_l21_o <= ref_flt_l21_w ;
                            ref_l22_o <= ref_flt_l22_w ; ref_l23_o <= ref_flt_l23_w ;
                            ref_l24_o <= ref_flt_l24_w ; ref_l25_o <= ref_flt_l25_w ;
                            ref_l26_o <= ref_flt_l26_w ; ref_l27_o <= ref_flt_l27_w ;
                            ref_l28_o <= ref_flt_l28_w ; ref_l29_o <= ref_flt_l29_w ;
                            ref_l30_o <= ref_flt_l30_w ; ref_l31_o <= ref_flt_l31_w ;
        end
      endcase
    end
  end

  // down
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_d00_o <= 0 ; ref_d01_o <= 0 ; ref_d02_o <= 0 ; ref_d03_o <= 0 ;
      ref_d04_o <= 0 ; ref_d05_o <= 0 ; ref_d06_o <= 0 ; ref_d07_o <= 0 ;
      ref_d08_o <= 0 ; ref_d09_o <= 0 ; ref_d10_o <= 0 ; ref_d11_o <= 0 ;
      ref_d12_o <= 0 ; ref_d13_o <= 0 ; ref_d14_o <= 0 ; ref_d15_o <= 0 ;
      ref_d16_o <= 0 ; ref_d17_o <= 0 ; ref_d18_o <= 0 ; ref_d19_o <= 0 ;
      ref_d20_o <= 0 ; ref_d21_o <= 0 ; ref_d22_o <= 0 ; ref_d23_o <= 0 ;
      ref_d24_o <= 0 ; ref_d25_o <= 0 ; ref_d26_o <= 0 ; ref_d27_o <= 0 ;
      ref_d28_o <= 0 ; ref_d29_o <= 0 ; ref_d30_o <= 0 ; ref_d31_o <= 0 ;
    end
    else begin
      case( cur_state_r )
        READ     : begin    case( rd_cnt_r )
                              3  : begin    if( size_i==`SIZE_04 ) begin
                                              ref_d00_o <= rd_dat_col_3_w ; ref_d01_o <= rd_dat_col_2_w ;
                                              ref_d02_o <= rd_dat_col_1_w ; ref_d03_o <= rd_dat_col_0_w ;
                                            end
                              end
                              4  : begin    if( size_i==`SIZE_08 ) begin
                                              ref_d00_o <= rd_dat_col_3_w ; ref_d01_o <= rd_dat_col_2_w ;
                                              ref_d02_o <= rd_dat_col_1_w ; ref_d03_o <= rd_dat_col_0_w ;
                                            end
                              end
                              5  : begin    if( size_i==`SIZE_08 ) begin
                                              ref_d04_o <= rd_dat_col_3_w ; ref_d05_o <= rd_dat_col_2_w ;
                                              ref_d06_o <= rd_dat_col_1_w ; ref_d07_o <= rd_dat_col_0_w ;
                                            end
                              end
                              6  : begin    if( size_i==`SIZE_16 ) begin
                                              ref_d00_o <= rd_dat_col_3_w ; ref_d01_o <= rd_dat_col_2_w ;
                                              ref_d02_o <= rd_dat_col_1_w ; ref_d03_o <= rd_dat_col_0_w ;
                                            end
                              end
                              7  : begin    if( size_i==`SIZE_16 ) begin
                                              ref_d04_o <= rd_dat_col_3_w ; ref_d05_o <= rd_dat_col_2_w ;
                                              ref_d06_o <= rd_dat_col_1_w ; ref_d07_o <= rd_dat_col_0_w ;
                                            end
                              end
                              8  : begin    if( size_i==`SIZE_16 ) begin
                                              ref_d08_o <= rd_dat_col_3_w ; ref_d09_o <= rd_dat_col_2_w ;
                                              ref_d10_o <= rd_dat_col_1_w ; ref_d11_o <= rd_dat_col_0_w ;
                                            end
                              end
                              9  : begin    if( size_i==`SIZE_16 ) begin
                                              ref_d12_o <= rd_dat_col_3_w ; ref_d13_o <= rd_dat_col_2_w ;
                                              ref_d14_o <= rd_dat_col_1_w ; ref_d15_o <= rd_dat_col_0_w ;
                                            end
                              end
                              10 : begin    if( size_i==`SIZE_32 ) begin
                                              ref_d00_o <= rd_dat_col_3_w ; ref_d01_o <= rd_dat_col_2_w ;
                                              ref_d02_o <= rd_dat_col_1_w ; ref_d03_o <= rd_dat_col_0_w ;
                                            end
                              end
                              11 : begin    if( size_i==`SIZE_32 ) begin
                                              ref_d04_o <= rd_dat_col_3_w ; ref_d05_o <= rd_dat_col_2_w ;
                                              ref_d06_o <= rd_dat_col_1_w ; ref_d07_o <= rd_dat_col_0_w ;
                                            end
                              end
                              12 : begin    if( size_i==`SIZE_32 ) begin
                                              ref_d08_o <= rd_dat_col_3_w ; ref_d09_o <= rd_dat_col_2_w ;
                                              ref_d10_o <= rd_dat_col_1_w ; ref_d11_o <= rd_dat_col_0_w ;
                                            end
                              end
                              13 : begin    if( size_i==`SIZE_32 ) begin
                                              ref_d12_o <= rd_dat_col_3_w ; ref_d13_o <= rd_dat_col_2_w ;
                                              ref_d14_o <= rd_dat_col_1_w ; ref_d15_o <= rd_dat_col_0_w ;
                                            end
                              end
                              14 : begin    if( size_i==`SIZE_32 ) begin
                                              ref_d16_o <= rd_dat_col_3_w ; ref_d17_o <= rd_dat_col_2_w ;
                                              ref_d18_o <= rd_dat_col_1_w ; ref_d19_o <= rd_dat_col_0_w ;
                                            end
                              end
                              15 : begin    if( size_i==`SIZE_32 ) begin
                                              ref_d20_o <= rd_dat_col_3_w ; ref_d21_o <= rd_dat_col_2_w ;
                                              ref_d22_o <= rd_dat_col_1_w ; ref_d23_o <= rd_dat_col_0_w ;
                                            end
                              end
                              16 : begin    if( size_i==`SIZE_32 ) begin
                                              ref_d24_o <= rd_dat_col_3_w ; ref_d25_o <= rd_dat_col_2_w ;
                                              ref_d26_o <= rd_dat_col_1_w ; ref_d27_o <= rd_dat_col_0_w ;
                                            end
                              end
                              17 : begin    if( size_i==`SIZE_32 ) begin
                                              ref_d28_o <= rd_dat_col_3_w ; ref_d29_o <= rd_dat_col_2_w ;
                                              ref_d30_o <= rd_dat_col_1_w ; ref_d31_o <= rd_dat_col_0_w ;
                                            end
                              end
                            endcase
        end
        PADDING  : begin    ref_d00_o <= ref_pad_d00_w ; ref_d01_o <= ref_pad_d01_w ;
                            ref_d02_o <= ref_pad_d02_w ; ref_d03_o <= ref_pad_d03_w ;
                            ref_d04_o <= ref_pad_d04_w ; ref_d05_o <= ref_pad_d05_w ;
                            ref_d06_o <= ref_pad_d06_w ; ref_d07_o <= ref_pad_d07_w ;
                            ref_d08_o <= ref_pad_d08_w ; ref_d09_o <= ref_pad_d09_w ;
                            ref_d10_o <= ref_pad_d10_w ; ref_d11_o <= ref_pad_d11_w ;
                            ref_d12_o <= ref_pad_d12_w ; ref_d13_o <= ref_pad_d13_w ;
                            ref_d14_o <= ref_pad_d14_w ; ref_d15_o <= ref_pad_d15_w ;
                            ref_d16_o <= ref_pad_d16_w ; ref_d17_o <= ref_pad_d17_w ;
                            ref_d18_o <= ref_pad_d18_w ; ref_d19_o <= ref_pad_d19_w ;
                            ref_d20_o <= ref_pad_d20_w ; ref_d21_o <= ref_pad_d21_w ;
                            ref_d22_o <= ref_pad_d22_w ; ref_d23_o <= ref_pad_d23_w ;
                            ref_d24_o <= ref_pad_d24_w ; ref_d25_o <= ref_pad_d25_w ;
                            ref_d26_o <= ref_pad_d26_w ; ref_d27_o <= ref_pad_d27_w ;
                            ref_d28_o <= ref_pad_d28_w ; ref_d29_o <= ref_pad_d29_w ;
                            ref_d30_o <= ref_pad_d30_w ; ref_d31_o <= ref_pad_d31_w ;
        end
        FILTER   : begin    ref_d00_o <= ref_flt_d00_w ; ref_d01_o <= ref_flt_d01_w ;
                            ref_d02_o <= ref_flt_d02_w ; ref_d03_o <= ref_flt_d03_w ;
                            ref_d04_o <= ref_flt_d04_w ; ref_d05_o <= ref_flt_d05_w ;
                            ref_d06_o <= ref_flt_d06_w ; ref_d07_o <= ref_flt_d07_w ;
                            ref_d08_o <= ref_flt_d08_w ; ref_d09_o <= ref_flt_d09_w ;
                            ref_d10_o <= ref_flt_d10_w ; ref_d11_o <= ref_flt_d11_w ;
                            ref_d12_o <= ref_flt_d12_w ; ref_d13_o <= ref_flt_d13_w ;
                            ref_d14_o <= ref_flt_d14_w ; ref_d15_o <= ref_flt_d15_w ;
                            ref_d16_o <= ref_flt_d16_w ; ref_d17_o <= ref_flt_d17_w ;
                            ref_d18_o <= ref_flt_d18_w ; ref_d19_o <= ref_flt_d19_w ;
                            ref_d20_o <= ref_flt_d20_w ; ref_d21_o <= ref_flt_d21_w ;
                            ref_d22_o <= ref_flt_d22_w ; ref_d23_o <= ref_flt_d23_w ;
                            ref_d24_o <= ref_flt_d24_w ; ref_d25_o <= ref_flt_d25_w ;
                            ref_d26_o <= ref_flt_d26_w ; ref_d27_o <= ref_flt_d27_w ;
                            ref_d28_o <= ref_flt_d28_w ; ref_d29_o <= ref_flt_d29_w ;
                            ref_d30_o <= ref_flt_d30_w ; ref_d31_o <= ref_flt_d31_w ;

        end
      endcase
    end
  end


//*** DEBUG ********************************************************************

  `ifdef DEBUG


  `endif

endmodule
