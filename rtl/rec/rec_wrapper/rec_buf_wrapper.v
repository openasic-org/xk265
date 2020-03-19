//-------------------------------------------------------------------
//
//  Filename      : rec_buf_wrapper.v
//  Author        : Huang Lei Lei
//  Created       : 2017-11-25
//  Description   : memory wrapper in rec loop
//
//-------------------------------------------------------------------
//
//  Modified      : 2017-12-24 by HLL
//  Description   : chroma supported
//  Modified      : 2018-05-19 by HLL
//  Description   : cbf added
//  Modified      : 2018-05-21 by HLL
//  Description   : I block in P frame supported
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module rec_buf_wrapper (
  // global
  clk                   ,
  rstn                  ,
  // ctrl_i
  rotate_i              ,
  rec_skip_flag_i       ,
  // pre_i
  pre_wr_ena_i          ,
  pre_wr_sel_i          ,
  pre_wr_siz_i          ,
  pre_wr_4x4_x_i        ,
  pre_wr_4x4_y_i        ,
  pre_wr_dat_i          ,
  // cur_i
  cur_rd_ena_o          ,
  cur_rd_sel_o          ,
  cur_rd_siz_o          ,
  cur_rd_4x4_x_o        ,
  cur_rd_4x4_y_o        ,
  cur_rd_idx_o          ,
  cur_rd_dat_i          ,
  // res_o
  res_wr_ena_o          ,
  res_wr_sel_o          ,
  res_wr_siz_o          ,
  res_wr_idx_o          ,
  res_wr_dat_o          ,
  // cef_i
  cef_wr_ena_i          ,
  cef_wr_idx_i          ,
  cef_wr_dat_i          ,
  // cef_o
  cef_rd_ena_i          ,
  cef_rd_idx_i          ,
  cef_rd_dat_o          ,
  // rsp_i
  rsp_wr_ena_i          ,
  rsp_wr_idx_i          ,
  rsp_wr_dat_i          ,
  // rec_o
  rec_wr_sel_o          ,
  rec_wr_pos_o          ,
  rec_wr_siz_o          ,
  rec_wr_ena_o          ,
  rec_wr_idx_o          ,
  rec_wr_dat_o          ,
  // mvd_i
  mvd_wr_ena_i          ,
  mvd_wr_adr_i          ,
  mvd_wr_dat_i          ,
  // rec_pip_o
  rec_pip_rd_ena_i      ,
  rec_pip_rd_sel_i      ,
  rec_pip_rd_siz_i      ,
  rec_pip_rd_4x4_x_i    ,
  rec_pip_rd_4x4_y_i    ,
  rec_pip_rd_idx_i      ,
  rec_pip_rd_dat_o      ,
  // rec_pip_i
  rec_pip_wr_ena_i      ,
  rec_pip_wr_sel_i      ,
  rec_pip_wr_siz_i      ,
  rec_pip_wr_4x4_x_i    ,
  rec_pip_wr_4x4_y_i    ,
  rec_pip_wr_idx_i      ,
  rec_pip_wr_dat_i      ,
  // cef_pip_o
  cef_pip_rd_ena_i      ,
  cef_pip_rd_sel_i      ,
  cef_pip_rd_siz_i      ,
  cef_pip_rd_4x4_x_i    ,
  cef_pip_rd_4x4_y_i    ,
  cef_pip_rd_idx_i      ,
  cef_pip_rd_dat_o      ,
  // mvd_pip_o
  mvd_pip_rd_ena_i      ,
  mvd_pip_rd_adr_i      ,
  mvd_pip_rd_dat_o      ,
  // cbf_pip_o
  cbf_y_r               ,
  cbf_u_r               ,
  cbf_v_r    
  );


//*** PARAMETER ****************************************************************


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                     clk                   ;
  input                                     rstn                  ;
  // rotate_i
  input                                     rotate_i              ;
  input       [85                 -1 :0]    rec_skip_flag_i       ;
  // pre_i
  input                                     pre_wr_ena_i          ;
  input       [2                  -1 :0]    pre_wr_sel_i          ;
  input       [2                  -1 :0]    pre_wr_siz_i          ;
  input       [4                  -1 :0]    pre_wr_4x4_x_i        ;
  input       [4                  -1 :0]    pre_wr_4x4_y_i        ;
  input       [`PIXEL_WIDTH*32    -1 :0]    pre_wr_dat_i          ;
  // cur_i
  output                                    cur_rd_ena_o          ;
  output      [2                  -1 :0]    cur_rd_sel_o          ;
  output      [2                  -1 :0]    cur_rd_siz_o          ;
  output      [4                  -1 :0]    cur_rd_4x4_x_o        ;
  output      [4                  -1 :0]    cur_rd_4x4_y_o        ;
  output      [5                  -1 :0]    cur_rd_idx_o          ;
  input       [`PIXEL_WIDTH*32    -1 :0]    cur_rd_dat_i          ;
  // res_o
  output reg                                res_wr_ena_o          ;
  output      [2                  -1 :0]    res_wr_sel_o          ;
  output      [2                  -1 :0]    res_wr_siz_o          ;
  output reg  [5                  -1 :0]    res_wr_idx_o          ;
  output reg  [(`PIXEL_WIDTH+1)*32-1 :0]    res_wr_dat_o          ;
  // cef_i
  input                                     cef_wr_ena_i          ;
  input       [5                  -1 :0]    cef_wr_idx_i          ;
  input       [`COEFF_WIDTH*32    -1 :0]    cef_wr_dat_i          ;
  // cef_o
  input                                     cef_rd_ena_i          ;
  input       [5                  -1 :0]    cef_rd_idx_i          ;
  output      [`COEFF_WIDTH*32    -1 :0]    cef_rd_dat_o          ;
  // rsp_i
  input                                     rsp_wr_ena_i          ;
  input       [5                  -1 :0]    rsp_wr_idx_i          ;
  input       [(`PIXEL_WIDTH+2)*32-1 :0]    rsp_wr_dat_i          ;
  // rec_o
  output      [2                  -1 :0]    rec_wr_sel_o          ;
  output      [8                  -1 :0]    rec_wr_pos_o          ;
  output      [2                  -1 :0]    rec_wr_siz_o          ;
  output                                    rec_wr_ena_o          ;
  output      [5                  -1 :0]    rec_wr_idx_o          ;
  output      [`PIXEL_WIDTH*32    -1 :0]    rec_wr_dat_o          ;
  // mvd_i
  input                                     mvd_wr_ena_i          ;
  input       [6                  -1 :0]    mvd_wr_adr_i          ;
  input       [2*`MVD_WIDTH          :0]    mvd_wr_dat_i          ;
  // rec_pip_o
  input                                     rec_pip_rd_ena_i      ;
  input      [2                  -1 :0]     rec_pip_rd_sel_i      ;
  input      [2                  -1 :0]     rec_pip_rd_siz_i      ;
  input      [4                  -1 :0]     rec_pip_rd_4x4_x_i    ;
  input      [4                  -1 :0]     rec_pip_rd_4x4_y_i    ;
  input      [5                  -1 :0]     rec_pip_rd_idx_i      ;
  output     [`PIXEL_WIDTH*32    -1 :0]     rec_pip_rd_dat_o      ;
  // rec_pip_i
  input       [1                  -1 :0]    rec_pip_wr_ena_i      ;
  input       [2                  -1 :0]    rec_pip_wr_sel_i      ;
  input       [2                  -1 :0]    rec_pip_wr_siz_i      ;
  input       [4                  -1 :0]    rec_pip_wr_4x4_x_i    ;
  input       [4                  -1 :0]    rec_pip_wr_4x4_y_i    ;
  input       [5                  -1 :0]    rec_pip_wr_idx_i      ;
  input       [`PIXEL_WIDTH*32    -1 :0]    rec_pip_wr_dat_i      ;
  // cef_pip_o
  input                                     cef_pip_rd_ena_i      ;
  input       [2                  -1 :0]    cef_pip_rd_sel_i      ;
  input       [2                  -1 :0]    cef_pip_rd_siz_i      ;
  input       [4                  -1 :0]    cef_pip_rd_4x4_x_i    ;
  input       [4                  -1 :0]    cef_pip_rd_4x4_y_i    ;
  input       [5                  -1 :0]    cef_pip_rd_idx_i      ;
  output      [`COEFF_WIDTH*32    -1 :0]    cef_pip_rd_dat_o      ;
  // mvd_pip_o
  input                                     mvd_pip_rd_ena_i      ;
  input       [6                  -1 :0]    mvd_pip_rd_adr_i      ;
  output      [2*`MVD_WIDTH          :0]    mvd_pip_rd_dat_o      ;
  // cbf_pip_o
  output      [256                -1 :0]    cbf_y_r               ;
  output      [256                -1 :0]    cbf_u_r               ;
  output      [256                -1 :0]    cbf_v_r               ;


//*** WIRE/REG *****************************************************************

  // global
  wire        [2                  -1 :0]    global_sel_w         ;
  wire        [2                  -1 :0]    global_siz_w         ;
  reg         [4                  -1 :0]    global_4x4_x_r       ;
  reg         [4                  -1 :0]    global_4x4_y_r       ;

  // buf_pre
  wire                                      pre_rd_ena_w         ;
  wire        [2                  -1 :0]    pre_rd_siz_w         ;
  wire        [4                  -1 :0]    pre_rd_4x4_x_w       ;
  wire        [4                  -1 :0]    pre_rd_4x4_y_w       ;
  wire        [5                  -1 :0]    pre_rd_idx_w         ;
  wire        [`PIXEL_WIDTH*32    -1 :0]    pre_rd_dat_w         ;

  reg                                       pre_rd_bt_ena_r      ;    // before tq
  reg                                       pre_rd_bt_ena_done_w ;
  reg         [5                  -1 :0]    pre_rd_bt_cnt_r      ;
  wire        [5                  -1 :0]    pre_rd_bt_idx_w      ;
  wire                                      pre_rd_at_ena_w      ;    // after  tq
  wire        [5                  -1 :0]    pre_rd_at_idx_w      ;

  // tq_res
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_00_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_01_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_02_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_03_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_04_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_05_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_06_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_07_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_08_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_09_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_10_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_11_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_12_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_13_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_14_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_15_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_16_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_17_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_18_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_19_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_20_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_21_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_22_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_23_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_24_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_25_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_26_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_27_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_28_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_29_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_30_w      ;
  wire signed [`PIXEL_WIDTH          :0]    res_wr_dat_31_w      ;

  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_00_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_01_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_02_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_03_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_04_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_05_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_06_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_07_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_08_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_09_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_10_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_11_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_12_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_13_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_14_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_15_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_16_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_17_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_18_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_19_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_20_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_21_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_22_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_23_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_24_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_25_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_26_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_27_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_28_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_29_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_30_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    pre_rd_dat_31_w      ;

  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_00_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_01_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_02_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_03_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_04_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_05_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_06_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_07_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_08_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_09_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_10_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_11_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_12_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_13_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_14_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_15_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_16_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_17_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_18_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_19_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_20_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_21_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_22_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_23_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_24_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_25_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_26_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_27_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_28_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_29_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_30_w      ;
  wire        [`PIXEL_WIDTH       -1 :0]    cur_rd_dat_31_w      ;

  wire        [`COEFF_WIDTH*32    -1 :0]    cef_wr_dat_w         ;

  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_00_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_01_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_02_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_03_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_04_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_05_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_06_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_07_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_08_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_09_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_10_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_11_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_12_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_13_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_14_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_15_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_16_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_17_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_18_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_19_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_20_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_21_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_22_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_23_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_24_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_25_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_26_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_27_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_28_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_29_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_30_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_wr_dat_31_w      ;

  wire        [`COEFF_WIDTH*32    -1 :0]    cef_rd_dat_w         ;

  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_00_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_01_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_02_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_03_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_04_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_05_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_06_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_07_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_08_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_09_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_10_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_11_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_12_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_13_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_14_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_15_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_16_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_17_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_18_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_19_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_20_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_21_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_22_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_23_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_24_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_25_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_26_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_27_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_28_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_29_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_30_w      ;
  wire        [`COEFF_WIDTH       -1 :0]    cef_rd_dat_31_w      ;

  // rec
  reg                                       rec_wr_ena_r         ;
  reg         [5                  -1 :0]    rec_wr_idx_r         ;

  wire        [`PIXEL_WIDTH*32    -1 :0]    rec_wr_dat_w         ;

  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_00_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_01_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_02_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_03_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_04_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_05_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_06_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_07_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_08_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_09_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_10_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_11_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_12_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_13_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_14_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_15_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_16_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_17_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_18_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_19_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_20_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_21_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_22_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_23_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_24_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_25_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_26_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_27_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_28_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_29_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_30_trun_w ;
  wire        [`PIXEL_WIDTH       -1 :0]    rec_wr_dat_31_trun_w ;

  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_00_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_01_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_02_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_03_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_04_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_05_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_06_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_07_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_08_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_09_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_10_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_11_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_12_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_13_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_14_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_15_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_16_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_17_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_18_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_19_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_20_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_21_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_22_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_23_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_24_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_25_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_26_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_27_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_28_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_29_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_30_w      ;
  wire signed [`PIXEL_WIDTH+1        :0]    rec_wr_dat_31_w      ;

  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_00_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_01_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_02_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_03_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_04_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_05_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_06_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_07_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_08_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_09_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_10_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_11_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_12_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_13_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_14_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_15_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_16_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_17_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_18_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_19_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_20_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_21_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_22_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_23_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_24_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_25_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_26_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_27_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_28_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_29_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_30_r      ;
  reg         [`PIXEL_WIDTH+1        :0]    rsp_wr_dat_31_r      ;

  // cbf
  reg         [256                -1 :0]    cbf_y_r              ;
  reg         [256                -1 :0]    cbf_u_r              ;
  reg         [256                -1 :0]    cbf_v_r              ;
  reg                                       cbf_done_r           ;
  reg                                       cbf_zero_r           ;
  wire        [256                -1 :0]    cbf_1_mask_w         ;
  wire        [256                -1 :0]    cbf_0_mask_w         ;
  reg         [64                 -1 :0]    cbf_cur_w            ;
  wire        [8                  -1 :0]    cbf_addr_w           ;

  wire        [2                  -1 :0]    blk_siz_w            ;
  wire        [2                  -1 :0]    blk_32_pos_w         ;
  wire        [4                  -1 :0]    blk_16_pos_w         ;
  wire        [6                  -1 :0]    blk_08_pos_w         ;

  reg                                       mc_skip_flg_r        ;

  wire                                      skip_flg_64_r    
                                           ,skip_flg_32_00_r, skip_flg_32_01_r, skip_flg_32_02_r, skip_flg_32_03_r 
                                           ,skip_flg_16_00_r, skip_flg_16_01_r, skip_flg_16_02_r, skip_flg_16_03_r
                                           ,skip_flg_16_04_r, skip_flg_16_05_r, skip_flg_16_06_r, skip_flg_16_07_r
                                           ,skip_flg_16_08_r, skip_flg_16_09_r, skip_flg_16_10_r, skip_flg_16_11_r
                                           ,skip_flg_16_12_r, skip_flg_16_13_r, skip_flg_16_14_r, skip_flg_16_15_r 
                                           ,skip_flg_08_00_r, skip_flg_08_01_r, skip_flg_08_02_r, skip_flg_08_03_r 
                                           ,skip_flg_08_04_r, skip_flg_08_05_r, skip_flg_08_06_r, skip_flg_08_07_r 
                                           ,skip_flg_08_08_r, skip_flg_08_09_r, skip_flg_08_10_r, skip_flg_08_11_r 
                                           ,skip_flg_08_12_r, skip_flg_08_13_r, skip_flg_08_14_r, skip_flg_08_15_r 
                                           ,skip_flg_08_16_r, skip_flg_08_17_r, skip_flg_08_18_r, skip_flg_08_19_r 
                                           ,skip_flg_08_20_r, skip_flg_08_21_r, skip_flg_08_22_r, skip_flg_08_23_r 
                                           ,skip_flg_08_24_r, skip_flg_08_25_r, skip_flg_08_26_r, skip_flg_08_27_r 
                                           ,skip_flg_08_28_r, skip_flg_08_29_r, skip_flg_08_30_r, skip_flg_08_31_r 
                                           ,skip_flg_08_32_r, skip_flg_08_33_r, skip_flg_08_34_r, skip_flg_08_35_r 
                                           ,skip_flg_08_36_r, skip_flg_08_37_r, skip_flg_08_38_r, skip_flg_08_39_r 
                                           ,skip_flg_08_40_r, skip_flg_08_41_r, skip_flg_08_42_r, skip_flg_08_43_r 
                                           ,skip_flg_08_44_r, skip_flg_08_45_r, skip_flg_08_46_r, skip_flg_08_47_r 
                                           ,skip_flg_08_48_r, skip_flg_08_49_r, skip_flg_08_50_r, skip_flg_08_51_r 
                                           ,skip_flg_08_52_r, skip_flg_08_53_r, skip_flg_08_54_r, skip_flg_08_55_r 
                                           ,skip_flg_08_56_r, skip_flg_08_57_r, skip_flg_08_58_r, skip_flg_08_59_r 
                                           ,skip_flg_08_60_r, skip_flg_08_61_r, skip_flg_08_62_r, skip_flg_08_63_r ;

//*** MAIN BODY ****************************************************************

//--- GLOBAL ---------------------------
  // global_sel_w & global_siz_w
  assign global_sel_w = pre_wr_sel_i ;
  assign global_siz_w = pre_wr_siz_i ;

  // global_4x4_x/y_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      global_4x4_x_r <= 0 ;
      global_4x4_y_r <= 0 ;
    end
    else begin
      case( pre_wr_siz_i )
        `SIZE_04 : begin    global_4x4_x_r <=   pre_wr_4x4_x_i ;
                            global_4x4_y_r <=   pre_wr_4x4_y_i ;
        end
        `SIZE_08 : begin    global_4x4_x_r <= { pre_wr_4x4_x_i[3:1] ,1'b0 };
                            global_4x4_y_r <= { pre_wr_4x4_y_i[3:1] ,1'b0 };
        end
        `SIZE_16 : begin    global_4x4_x_r <= { pre_wr_4x4_x_i[3:2] ,2'b0 };
                            global_4x4_y_r <= { pre_wr_4x4_y_i[3:2] ,2'b0 };
        end
        `SIZE_32 : begin    global_4x4_x_r <= { pre_wr_4x4_x_i[3]   ,3'b0 };
                            global_4x4_y_r <= { pre_wr_4x4_y_i[3]   ,3'b0 };
        end
      endcase
    end
  end


//--- BUF_PRE --------------------------
  // memory
  rec_buf_pre u_buf_pre(
    // global
    .clk           ( clk               ),
    .rstn          ( rstn              ),
    // wr
    .wr_ena_i      ( pre_wr_ena_i      ),
    .wr_siz_i      ( pre_wr_siz_i      ),
    .wr_4x4_x_i    ( pre_wr_4x4_x_i    ),
    .wr_4x4_y_i    ( pre_wr_4x4_y_i    ),
    .wr_dat_i      ( pre_wr_dat_i      ),
    // rd
    .rd_ena_i      ( pre_rd_ena_w      ),
    .rd_siz_i      ( pre_rd_siz_w      ),
    .rd_4x4_x_i    ( pre_rd_4x4_x_w    ),
    .rd_4x4_y_i    ( pre_rd_4x4_y_w    ),
    .rd_idx_i      ( pre_rd_idx_w      ),
    .rd_dat_o      ( pre_rd_dat_w      )
    );

  // pre_rd_ena_w
  assign pre_rd_ena_w = pre_rd_bt_ena_r | pre_rd_at_ena_w ;
  // pre_rd_bt_ena_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      pre_rd_bt_ena_r <= 0 ;
    end
    else begin
      case( pre_wr_siz_i )
        `SIZE_04 :                                                pre_rd_bt_ena_r <= pre_wr_ena_i ;
        `SIZE_08 :                                                pre_rd_bt_ena_r <= pre_wr_ena_i ;
        `SIZE_16 : begin if( pre_wr_ena_i
                          &&(pre_wr_4x4_x_i[1]==1)
                          &&(pre_wr_4x4_y_i[1:0]==0) ) begin      pre_rd_bt_ena_r <= 1 ;
                         end
                         else if( pre_rd_bt_ena_done_w ) begin    pre_rd_bt_ena_r <= 0 ;
                         end
        end
        `SIZE_32 : begin if( pre_wr_ena_i
                          &&(pre_wr_4x4_x_i[2:1]==3)
                          &&(pre_wr_4x4_y_i[2:0]==0) ) begin      pre_rd_bt_ena_r <= 1 ;
                         end
                         else if( pre_rd_bt_ena_done_w ) begin    pre_rd_bt_ena_r <= 0 ;
                         end
        end
      endcase
    end
  end
  // pre_rd_bt_ena_done_w
  always @(*) begin
                 pre_rd_bt_ena_done_w = 1 ;
    case( pre_wr_siz_i )
      `SIZE_08 : pre_rd_bt_ena_done_w = pre_rd_bt_cnt_r==04 ;
      `SIZE_16 : pre_rd_bt_ena_done_w = pre_rd_bt_cnt_r==14 ;
      `SIZE_32 : pre_rd_bt_ena_done_w = pre_rd_bt_cnt_r==31 ;
    endcase
  end
  // pre_rd_bt_cnt_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      pre_rd_bt_cnt_r <= 0 ;
    end
    else begin
      if( pre_rd_bt_ena_r ) begin
        case( pre_wr_siz_i )
          `SIZE_08 : begin    if( pre_rd_bt_ena_done_w ) begin
                                pre_rd_bt_cnt_r <= 0 ;
                              end
                              else begin
                                pre_rd_bt_cnt_r <= pre_rd_bt_cnt_r + 4 ;
                              end
          end
          `SIZE_16 : begin    if( pre_rd_bt_ena_done_w ) begin
                                pre_rd_bt_cnt_r <= 0 ;
                              end
                              else begin
                                pre_rd_bt_cnt_r <= pre_rd_bt_cnt_r + 2 ;
                              end
          end
          `SIZE_32 : begin    if( pre_rd_bt_ena_done_w ) begin
                                pre_rd_bt_cnt_r <= 0 ;
                              end
                              else begin
                                pre_rd_bt_cnt_r <= pre_rd_bt_cnt_r + 1 ;
                              end
          end
        endcase
      end
      else begin
        pre_rd_bt_cnt_r <= 0 ;
      end
    end
  end
  // pre_rd_at_ena_w
  assign pre_rd_at_ena_w = rsp_wr_ena_i ;

  // pre_rd_siz_w
  assign pre_rd_siz_w = global_siz_w ;

  // pre_rd_4x4_x/y_w
  assign pre_rd_4x4_x_w = global_4x4_x_r ;
  assign pre_rd_4x4_y_w = global_4x4_y_r ;

  // pre_rd_idx_w
  assign pre_rd_idx_w = pre_rd_bt_ena_r ? pre_rd_bt_idx_w : pre_rd_at_idx_w ;
  // pre_rd_bt_idx_w
  assign pre_rd_bt_idx_w = pre_rd_bt_cnt_r ;
  // pre_rd_at_idx_w
  assign pre_rd_at_idx_w = rsp_wr_idx_i ;


//--- CUR_IF ---------------------------
  // assigments
  assign cur_rd_ena_o   = pre_rd_bt_ena_r ;
  assign cur_rd_sel_o   = global_sel_w    ;
  assign cur_rd_siz_o   = global_siz_w    ;
  assign cur_rd_4x4_x_o = global_4x4_x_r  ;
  assign cur_rd_4x4_y_o = global_4x4_y_r  ;
  assign cur_rd_idx_o   = pre_rd_idx_w    ;


//--- RES_IF ---------------------------
  // res_wr_sel_o & res_wr_siz_o
  assign res_wr_sel_o = global_sel_w ;
  assign res_wr_siz_o = global_siz_w ;

  // res_wr_ena_o & res_wr_idx_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      res_wr_ena_o <= 0 ;
      res_wr_idx_o <= 0 ;
    end
    else begin
      res_wr_ena_o <= cur_rd_ena_o ;
      res_wr_idx_o <= cur_rd_idx_o ;
    end
  end

  // res_wr_dat_o
  always @(*) begin
    res_wr_dat_o = { res_wr_dat_31_w
                    ,res_wr_dat_30_w
                    ,res_wr_dat_29_w
                    ,res_wr_dat_28_w
                    ,res_wr_dat_27_w
                    ,res_wr_dat_26_w
                    ,res_wr_dat_25_w
                    ,res_wr_dat_24_w
                    ,res_wr_dat_23_w
                    ,res_wr_dat_22_w
                    ,res_wr_dat_21_w
                    ,res_wr_dat_20_w
                    ,res_wr_dat_19_w
                    ,res_wr_dat_18_w
                    ,res_wr_dat_17_w
                    ,res_wr_dat_16_w
                    ,res_wr_dat_15_w
                    ,res_wr_dat_14_w
                    ,res_wr_dat_13_w
                    ,res_wr_dat_12_w
                    ,res_wr_dat_11_w
                    ,res_wr_dat_10_w
                    ,res_wr_dat_09_w
                    ,res_wr_dat_08_w
                    ,res_wr_dat_07_w
                    ,res_wr_dat_06_w
                    ,res_wr_dat_05_w
                    ,res_wr_dat_04_w
                    ,res_wr_dat_03_w
                    ,res_wr_dat_02_w
                    ,res_wr_dat_01_w
                    ,res_wr_dat_00_w };
  end
  // res_wr_dat_00-31_w
  assign res_wr_dat_00_w = {1'b0,cur_rd_dat_00_w} - {1'b0,pre_rd_dat_00_w} ;
  assign res_wr_dat_01_w = {1'b0,cur_rd_dat_01_w} - {1'b0,pre_rd_dat_01_w} ;
  assign res_wr_dat_02_w = {1'b0,cur_rd_dat_02_w} - {1'b0,pre_rd_dat_02_w} ;
  assign res_wr_dat_03_w = {1'b0,cur_rd_dat_03_w} - {1'b0,pre_rd_dat_03_w} ;
  assign res_wr_dat_04_w = {1'b0,cur_rd_dat_04_w} - {1'b0,pre_rd_dat_04_w} ;
  assign res_wr_dat_05_w = {1'b0,cur_rd_dat_05_w} - {1'b0,pre_rd_dat_05_w} ;
  assign res_wr_dat_06_w = {1'b0,cur_rd_dat_06_w} - {1'b0,pre_rd_dat_06_w} ;
  assign res_wr_dat_07_w = {1'b0,cur_rd_dat_07_w} - {1'b0,pre_rd_dat_07_w} ;
  assign res_wr_dat_08_w = {1'b0,cur_rd_dat_08_w} - {1'b0,pre_rd_dat_08_w} ;
  assign res_wr_dat_09_w = {1'b0,cur_rd_dat_09_w} - {1'b0,pre_rd_dat_09_w} ;
  assign res_wr_dat_10_w = {1'b0,cur_rd_dat_10_w} - {1'b0,pre_rd_dat_10_w} ;
  assign res_wr_dat_11_w = {1'b0,cur_rd_dat_11_w} - {1'b0,pre_rd_dat_11_w} ;
  assign res_wr_dat_12_w = {1'b0,cur_rd_dat_12_w} - {1'b0,pre_rd_dat_12_w} ;
  assign res_wr_dat_13_w = {1'b0,cur_rd_dat_13_w} - {1'b0,pre_rd_dat_13_w} ;
  assign res_wr_dat_14_w = {1'b0,cur_rd_dat_14_w} - {1'b0,pre_rd_dat_14_w} ;
  assign res_wr_dat_15_w = {1'b0,cur_rd_dat_15_w} - {1'b0,pre_rd_dat_15_w} ;
  assign res_wr_dat_16_w = {1'b0,cur_rd_dat_16_w} - {1'b0,pre_rd_dat_16_w} ;
  assign res_wr_dat_17_w = {1'b0,cur_rd_dat_17_w} - {1'b0,pre_rd_dat_17_w} ;
  assign res_wr_dat_18_w = {1'b0,cur_rd_dat_18_w} - {1'b0,pre_rd_dat_18_w} ;
  assign res_wr_dat_19_w = {1'b0,cur_rd_dat_19_w} - {1'b0,pre_rd_dat_19_w} ;
  assign res_wr_dat_20_w = {1'b0,cur_rd_dat_20_w} - {1'b0,pre_rd_dat_20_w} ;
  assign res_wr_dat_21_w = {1'b0,cur_rd_dat_21_w} - {1'b0,pre_rd_dat_21_w} ;
  assign res_wr_dat_22_w = {1'b0,cur_rd_dat_22_w} - {1'b0,pre_rd_dat_22_w} ;
  assign res_wr_dat_23_w = {1'b0,cur_rd_dat_23_w} - {1'b0,pre_rd_dat_23_w} ;
  assign res_wr_dat_24_w = {1'b0,cur_rd_dat_24_w} - {1'b0,pre_rd_dat_24_w} ;
  assign res_wr_dat_25_w = {1'b0,cur_rd_dat_25_w} - {1'b0,pre_rd_dat_25_w} ;
  assign res_wr_dat_26_w = {1'b0,cur_rd_dat_26_w} - {1'b0,pre_rd_dat_26_w} ;
  assign res_wr_dat_27_w = {1'b0,cur_rd_dat_27_w} - {1'b0,pre_rd_dat_27_w} ;
  assign res_wr_dat_28_w = {1'b0,cur_rd_dat_28_w} - {1'b0,pre_rd_dat_28_w} ;
  assign res_wr_dat_29_w = {1'b0,cur_rd_dat_29_w} - {1'b0,pre_rd_dat_29_w} ;
  assign res_wr_dat_30_w = {1'b0,cur_rd_dat_30_w} - {1'b0,pre_rd_dat_30_w} ;
  assign res_wr_dat_31_w = {1'b0,cur_rd_dat_31_w} - {1'b0,pre_rd_dat_31_w} ;
  // cur_rd_dat_00-31_w
  assign { cur_rd_dat_00_w
          ,cur_rd_dat_01_w
          ,cur_rd_dat_02_w
          ,cur_rd_dat_03_w
          ,cur_rd_dat_04_w
          ,cur_rd_dat_05_w
          ,cur_rd_dat_06_w
          ,cur_rd_dat_07_w
          ,cur_rd_dat_08_w
          ,cur_rd_dat_09_w
          ,cur_rd_dat_10_w
          ,cur_rd_dat_11_w
          ,cur_rd_dat_12_w
          ,cur_rd_dat_13_w
          ,cur_rd_dat_14_w
          ,cur_rd_dat_15_w
          ,cur_rd_dat_16_w
          ,cur_rd_dat_17_w
          ,cur_rd_dat_18_w
          ,cur_rd_dat_19_w
          ,cur_rd_dat_20_w
          ,cur_rd_dat_21_w
          ,cur_rd_dat_22_w
          ,cur_rd_dat_23_w
          ,cur_rd_dat_24_w
          ,cur_rd_dat_25_w
          ,cur_rd_dat_26_w
          ,cur_rd_dat_27_w
          ,cur_rd_dat_28_w
          ,cur_rd_dat_29_w
          ,cur_rd_dat_30_w
          ,cur_rd_dat_31_w } = cur_rd_dat_i ;
  // pre_rd_dat_00-31_w
  assign { pre_rd_dat_00_w
          ,pre_rd_dat_01_w
          ,pre_rd_dat_02_w
          ,pre_rd_dat_03_w
          ,pre_rd_dat_04_w
          ,pre_rd_dat_05_w
          ,pre_rd_dat_06_w
          ,pre_rd_dat_07_w
          ,pre_rd_dat_08_w
          ,pre_rd_dat_09_w
          ,pre_rd_dat_10_w
          ,pre_rd_dat_11_w
          ,pre_rd_dat_12_w
          ,pre_rd_dat_13_w
          ,pre_rd_dat_14_w
          ,pre_rd_dat_15_w
          ,pre_rd_dat_16_w
          ,pre_rd_dat_17_w
          ,pre_rd_dat_18_w
          ,pre_rd_dat_19_w
          ,pre_rd_dat_20_w
          ,pre_rd_dat_21_w
          ,pre_rd_dat_22_w
          ,pre_rd_dat_23_w
          ,pre_rd_dat_24_w
          ,pre_rd_dat_25_w
          ,pre_rd_dat_26_w
          ,pre_rd_dat_27_w
          ,pre_rd_dat_28_w
          ,pre_rd_dat_29_w
          ,pre_rd_dat_30_w
          ,pre_rd_dat_31_w } = pre_rd_dat_w ;


//--- BUF_CEF --------------------------
  // buf_cef
  rec_buf_cef_rot u_buf_cef_rot (
    // global
    .clk             ( clk                   ),
    .rstn            ( rstn                  ),
    // ctrl
    .rotate_i        ( rotate_i              ),
    // wr_0
    .wr_0_ena_i      ( cef_wr_ena_i          ),
    .wr_0_sel_i      ( global_sel_w          ),
    .wr_0_siz_i      ( global_siz_w          ),
    .wr_0_4x4_x_i    ( global_4x4_y_r        ),
    .wr_0_4x4_y_i    ( global_4x4_x_r        ),
    .wr_0_idx_i      ( cef_wr_idx_i          ),
    .wr_0_dat_i      ( cef_wr_dat_w          ),
    // rd_0
    .rd_0_ena_i      ( cef_rd_ena_i          ),
    .rd_0_sel_i      ( global_sel_w          ),
    .rd_0_siz_i      ( global_siz_w          ),
    .rd_0_4x4_x_i    ( global_4x4_y_r        ),
    .rd_0_4x4_y_i    ( global_4x4_x_r        ),
    .rd_0_idx_i      ( cef_rd_idx_i          ),
    .rd_0_dat_o      ( cef_rd_dat_w          ),
    // rd_2
    .rd_2_ena_i      ( cef_pip_rd_ena_i      ),
    .rd_2_sel_i      ( cef_pip_rd_sel_i      ),
    .rd_2_siz_i      ( cef_pip_rd_siz_i      ),
    .rd_2_4x4_x_i    ( cef_pip_rd_4x4_y_i    ),
    .rd_2_4x4_y_i    ( cef_pip_rd_4x4_x_i    ),
    .rd_2_idx_i      ( cef_pip_rd_idx_i      ),
    .rd_2_dat_o      ( cef_pip_rd_dat_o      )
    );

  // cef_wr_dat_w
  assign cef_wr_dat_w = { cef_wr_dat_31_w
                         ,cef_wr_dat_30_w
                         ,cef_wr_dat_29_w
                         ,cef_wr_dat_28_w
                         ,cef_wr_dat_27_w
                         ,cef_wr_dat_26_w
                         ,cef_wr_dat_25_w
                         ,cef_wr_dat_24_w
                         ,cef_wr_dat_23_w
                         ,cef_wr_dat_22_w
                         ,cef_wr_dat_21_w
                         ,cef_wr_dat_20_w
                         ,cef_wr_dat_19_w
                         ,cef_wr_dat_18_w
                         ,cef_wr_dat_17_w
                         ,cef_wr_dat_16_w
                         ,cef_wr_dat_15_w
                         ,cef_wr_dat_14_w
                         ,cef_wr_dat_13_w
                         ,cef_wr_dat_12_w
                         ,cef_wr_dat_11_w
                         ,cef_wr_dat_10_w
                         ,cef_wr_dat_09_w
                         ,cef_wr_dat_08_w
                         ,cef_wr_dat_07_w
                         ,cef_wr_dat_06_w
                         ,cef_wr_dat_05_w
                         ,cef_wr_dat_04_w
                         ,cef_wr_dat_03_w
                         ,cef_wr_dat_02_w
                         ,cef_wr_dat_01_w
                         ,cef_wr_dat_00_w };
  // cef_wr_dat_00-31_w
  assign { cef_wr_dat_00_w
          ,cef_wr_dat_01_w
          ,cef_wr_dat_02_w
          ,cef_wr_dat_03_w
          ,cef_wr_dat_04_w
          ,cef_wr_dat_05_w
          ,cef_wr_dat_06_w
          ,cef_wr_dat_07_w
          ,cef_wr_dat_08_w
          ,cef_wr_dat_09_w
          ,cef_wr_dat_10_w
          ,cef_wr_dat_11_w
          ,cef_wr_dat_12_w
          ,cef_wr_dat_13_w
          ,cef_wr_dat_14_w
          ,cef_wr_dat_15_w
          ,cef_wr_dat_16_w
          ,cef_wr_dat_17_w
          ,cef_wr_dat_18_w
          ,cef_wr_dat_19_w
          ,cef_wr_dat_20_w
          ,cef_wr_dat_21_w
          ,cef_wr_dat_22_w
          ,cef_wr_dat_23_w
          ,cef_wr_dat_24_w
          ,cef_wr_dat_25_w
          ,cef_wr_dat_26_w
          ,cef_wr_dat_27_w
          ,cef_wr_dat_28_w
          ,cef_wr_dat_29_w
          ,cef_wr_dat_30_w
          ,cef_wr_dat_31_w } = cef_wr_dat_i ;

  // cef_rd_dat_o
  assign cef_rd_dat_o = { cef_rd_dat_00_w
                         ,cef_rd_dat_01_w
                         ,cef_rd_dat_02_w
                         ,cef_rd_dat_03_w
                         ,cef_rd_dat_04_w
                         ,cef_rd_dat_05_w
                         ,cef_rd_dat_06_w
                         ,cef_rd_dat_07_w
                         ,cef_rd_dat_08_w
                         ,cef_rd_dat_09_w
                         ,cef_rd_dat_10_w
                         ,cef_rd_dat_11_w
                         ,cef_rd_dat_12_w
                         ,cef_rd_dat_13_w
                         ,cef_rd_dat_14_w
                         ,cef_rd_dat_15_w
                         ,cef_rd_dat_16_w
                         ,cef_rd_dat_17_w
                         ,cef_rd_dat_18_w
                         ,cef_rd_dat_19_w
                         ,cef_rd_dat_20_w
                         ,cef_rd_dat_21_w
                         ,cef_rd_dat_22_w
                         ,cef_rd_dat_23_w
                         ,cef_rd_dat_24_w
                         ,cef_rd_dat_25_w
                         ,cef_rd_dat_26_w
                         ,cef_rd_dat_27_w
                         ,cef_rd_dat_28_w
                         ,cef_rd_dat_29_w
                         ,cef_rd_dat_30_w
                         ,cef_rd_dat_31_w };
  // cef_rd_dat_31-00_w
  assign { cef_rd_dat_31_w
          ,cef_rd_dat_30_w
          ,cef_rd_dat_29_w
          ,cef_rd_dat_28_w
          ,cef_rd_dat_27_w
          ,cef_rd_dat_26_w
          ,cef_rd_dat_25_w
          ,cef_rd_dat_24_w
          ,cef_rd_dat_23_w
          ,cef_rd_dat_22_w
          ,cef_rd_dat_21_w
          ,cef_rd_dat_20_w
          ,cef_rd_dat_19_w
          ,cef_rd_dat_18_w
          ,cef_rd_dat_17_w
          ,cef_rd_dat_16_w
          ,cef_rd_dat_15_w
          ,cef_rd_dat_14_w
          ,cef_rd_dat_13_w
          ,cef_rd_dat_12_w
          ,cef_rd_dat_11_w
          ,cef_rd_dat_10_w
          ,cef_rd_dat_09_w
          ,cef_rd_dat_08_w
          ,cef_rd_dat_07_w
          ,cef_rd_dat_06_w
          ,cef_rd_dat_05_w
          ,cef_rd_dat_04_w
          ,cef_rd_dat_03_w
          ,cef_rd_dat_02_w
          ,cef_rd_dat_01_w
          ,cef_rd_dat_00_w } = cef_rd_dat_w ;



//--- REC IF ---------------------------
  assign rec_wr_sel_o = global_sel_w ;
  assign rec_wr_pos_o = {global_4x4_y_r[3],global_4x4_x_r[3]
                        ,global_4x4_y_r[2],global_4x4_x_r[2]
                        ,global_4x4_y_r[1],global_4x4_x_r[1]
                        ,global_4x4_y_r[0],global_4x4_x_r[0]
                        };
  assign rec_wr_siz_o = global_siz_w ;
  assign rec_wr_ena_o = rec_wr_ena_r ;
  assign rec_wr_idx_o = rec_wr_idx_r ;
  assign rec_wr_dat_o = rec_wr_dat_w ;

//--- skip flag generate ----------------------- 

  assign { skip_flg_64_r    
          ,skip_flg_32_00_r, skip_flg_32_01_r, skip_flg_32_02_r, skip_flg_32_03_r 
          ,skip_flg_16_00_r, skip_flg_16_01_r, skip_flg_16_02_r, skip_flg_16_03_r
          ,skip_flg_16_04_r, skip_flg_16_05_r, skip_flg_16_06_r, skip_flg_16_07_r
          ,skip_flg_16_08_r, skip_flg_16_09_r, skip_flg_16_10_r, skip_flg_16_11_r
          ,skip_flg_16_12_r, skip_flg_16_13_r, skip_flg_16_14_r, skip_flg_16_15_r 
          ,skip_flg_08_00_r, skip_flg_08_01_r, skip_flg_08_02_r, skip_flg_08_03_r 
          ,skip_flg_08_04_r, skip_flg_08_05_r, skip_flg_08_06_r, skip_flg_08_07_r 
          ,skip_flg_08_08_r, skip_flg_08_09_r, skip_flg_08_10_r, skip_flg_08_11_r 
          ,skip_flg_08_12_r, skip_flg_08_13_r, skip_flg_08_14_r, skip_flg_08_15_r 
          ,skip_flg_08_16_r, skip_flg_08_17_r, skip_flg_08_18_r, skip_flg_08_19_r 
          ,skip_flg_08_20_r, skip_flg_08_21_r, skip_flg_08_22_r, skip_flg_08_23_r 
          ,skip_flg_08_24_r, skip_flg_08_25_r, skip_flg_08_26_r, skip_flg_08_27_r 
          ,skip_flg_08_28_r, skip_flg_08_29_r, skip_flg_08_30_r, skip_flg_08_31_r 
          ,skip_flg_08_32_r, skip_flg_08_33_r, skip_flg_08_34_r, skip_flg_08_35_r 
          ,skip_flg_08_36_r, skip_flg_08_37_r, skip_flg_08_38_r, skip_flg_08_39_r 
          ,skip_flg_08_40_r, skip_flg_08_41_r, skip_flg_08_42_r, skip_flg_08_43_r 
          ,skip_flg_08_44_r, skip_flg_08_45_r, skip_flg_08_46_r, skip_flg_08_47_r 
          ,skip_flg_08_48_r, skip_flg_08_49_r, skip_flg_08_50_r, skip_flg_08_51_r 
          ,skip_flg_08_52_r, skip_flg_08_53_r, skip_flg_08_54_r, skip_flg_08_55_r 
          ,skip_flg_08_56_r, skip_flg_08_57_r, skip_flg_08_58_r, skip_flg_08_59_r 
          ,skip_flg_08_60_r, skip_flg_08_61_r, skip_flg_08_62_r, skip_flg_08_63_r } = rec_skip_flag_i ;

  assign blk_32_pos_w = rec_wr_sel_o == `TYPE_Y ? {global_4x4_y_r[3], global_4x4_x_r[3]} : {global_4x4_y_r[2], global_4x4_x_r[2]} ;
  assign blk_16_pos_w = rec_wr_sel_o == `TYPE_Y ? {global_4x4_y_r[3], global_4x4_x_r[3], global_4x4_y_r[2], global_4x4_x_r[2]} 
                                                : {global_4x4_y_r[2], global_4x4_x_r[2], global_4x4_y_r[1], global_4x4_x_r[1]} ;
  assign blk_08_pos_w = rec_wr_sel_o == `TYPE_Y ? {global_4x4_y_r[3], global_4x4_x_r[3], global_4x4_y_r[2], global_4x4_x_r[2], global_4x4_y_r[1], global_4x4_x_r[1]}
                                                : {global_4x4_y_r[2], global_4x4_x_r[2], global_4x4_y_r[1], global_4x4_x_r[1], global_4x4_y_r[0], global_4x4_x_r[0]} ; 
  assign blk_siz_w    = rec_wr_sel_o == `TYPE_Y ? rec_wr_siz_o : (rec_wr_siz_o + 1) ;

  always @* begin 
    mc_skip_flg_r = 0 ; 
    case ( blk_siz_w )
      `SIZE_32 : begin 
        case ( blk_32_pos_w )
          2'b00 : mc_skip_flg_r = skip_flg_32_00_r ;
          2'b01 : mc_skip_flg_r = skip_flg_32_01_r ;
          2'b10 : mc_skip_flg_r = skip_flg_32_02_r ;
          2'b11 : mc_skip_flg_r = skip_flg_32_03_r ;
          default : mc_skip_flg_r = 0 ;
        endcase 
      end 
      `SIZE_16 : begin 
        case ( blk_16_pos_w )
          4'd0  : mc_skip_flg_r = skip_flg_16_00_r ;
          4'd1  : mc_skip_flg_r = skip_flg_16_01_r ;
          4'd2  : mc_skip_flg_r = skip_flg_16_02_r ;
          4'd3  : mc_skip_flg_r = skip_flg_16_03_r ;
          4'd4  : mc_skip_flg_r = skip_flg_16_04_r ;
          4'd5  : mc_skip_flg_r = skip_flg_16_05_r ;
          4'd6  : mc_skip_flg_r = skip_flg_16_06_r ;
          4'd7  : mc_skip_flg_r = skip_flg_16_07_r ;
          4'd8  : mc_skip_flg_r = skip_flg_16_08_r ;
          4'd9  : mc_skip_flg_r = skip_flg_16_09_r ;
          4'd10 : mc_skip_flg_r = skip_flg_16_10_r ; 
          4'd11 : mc_skip_flg_r = skip_flg_16_11_r ;
          4'd12 : mc_skip_flg_r = skip_flg_16_12_r ;
          4'd13 : mc_skip_flg_r = skip_flg_16_13_r ;
          4'd14 : mc_skip_flg_r = skip_flg_16_14_r ;
          4'd15 : mc_skip_flg_r = skip_flg_16_15_r ;
          default : mc_skip_flg_r = 0 ;
        endcase 
      end 
      `SIZE_08 : begin 
        case ( blk_08_pos_w )
          0  : mc_skip_flg_r = skip_flg_08_00_r ; 
          1  : mc_skip_flg_r = skip_flg_08_01_r ; 
          2  : mc_skip_flg_r = skip_flg_08_02_r ; 
          3  : mc_skip_flg_r = skip_flg_08_03_r ; 
          4  : mc_skip_flg_r = skip_flg_08_04_r ; 
          5  : mc_skip_flg_r = skip_flg_08_05_r ; 
          6  : mc_skip_flg_r = skip_flg_08_06_r ; 
          7  : mc_skip_flg_r = skip_flg_08_07_r ; 
          8  : mc_skip_flg_r = skip_flg_08_08_r ; 
          9  : mc_skip_flg_r = skip_flg_08_09_r ; 
          10 : mc_skip_flg_r = skip_flg_08_10_r ; 
          11 : mc_skip_flg_r = skip_flg_08_11_r ; 
          12 : mc_skip_flg_r = skip_flg_08_12_r ; 
          13 : mc_skip_flg_r = skip_flg_08_13_r ; 
          14 : mc_skip_flg_r = skip_flg_08_14_r ; 
          15 : mc_skip_flg_r = skip_flg_08_15_r ; 
          16 : mc_skip_flg_r = skip_flg_08_16_r ; 
          17 : mc_skip_flg_r = skip_flg_08_17_r ; 
          18 : mc_skip_flg_r = skip_flg_08_18_r ; 
          19 : mc_skip_flg_r = skip_flg_08_19_r ; 
          20 : mc_skip_flg_r = skip_flg_08_20_r ; 
          21 : mc_skip_flg_r = skip_flg_08_21_r ; 
          22 : mc_skip_flg_r = skip_flg_08_22_r ; 
          23 : mc_skip_flg_r = skip_flg_08_23_r ; 
          24 : mc_skip_flg_r = skip_flg_08_24_r ; 
          25 : mc_skip_flg_r = skip_flg_08_25_r ; 
          26 : mc_skip_flg_r = skip_flg_08_26_r ; 
          27 : mc_skip_flg_r = skip_flg_08_27_r ; 
          28 : mc_skip_flg_r = skip_flg_08_28_r ; 
          29 : mc_skip_flg_r = skip_flg_08_29_r ; 
          30 : mc_skip_flg_r = skip_flg_08_30_r ; 
          31 : mc_skip_flg_r = skip_flg_08_31_r ; 
          32 : mc_skip_flg_r = skip_flg_08_32_r ; 
          33 : mc_skip_flg_r = skip_flg_08_33_r ; 
          34 : mc_skip_flg_r = skip_flg_08_34_r ; 
          35 : mc_skip_flg_r = skip_flg_08_35_r ; 
          36 : mc_skip_flg_r = skip_flg_08_36_r ; 
          37 : mc_skip_flg_r = skip_flg_08_37_r ; 
          38 : mc_skip_flg_r = skip_flg_08_38_r ; 
          39 : mc_skip_flg_r = skip_flg_08_39_r ; 
          40 : mc_skip_flg_r = skip_flg_08_40_r ; 
          41 : mc_skip_flg_r = skip_flg_08_41_r ; 
          42 : mc_skip_flg_r = skip_flg_08_42_r ; 
          43 : mc_skip_flg_r = skip_flg_08_43_r ; 
          44 : mc_skip_flg_r = skip_flg_08_44_r ; 
          45 : mc_skip_flg_r = skip_flg_08_45_r ; 
          46 : mc_skip_flg_r = skip_flg_08_46_r ; 
          47 : mc_skip_flg_r = skip_flg_08_47_r ; 
          48 : mc_skip_flg_r = skip_flg_08_48_r ; 
          49 : mc_skip_flg_r = skip_flg_08_49_r ; 
          50 : mc_skip_flg_r = skip_flg_08_50_r ; 
          51 : mc_skip_flg_r = skip_flg_08_51_r ; 
          52 : mc_skip_flg_r = skip_flg_08_52_r ; 
          53 : mc_skip_flg_r = skip_flg_08_53_r ; 
          54 : mc_skip_flg_r = skip_flg_08_54_r ; 
          55 : mc_skip_flg_r = skip_flg_08_55_r ; 
          56 : mc_skip_flg_r = skip_flg_08_56_r ; 
          57 : mc_skip_flg_r = skip_flg_08_57_r ; 
          58 : mc_skip_flg_r = skip_flg_08_58_r ; 
          59 : mc_skip_flg_r = skip_flg_08_59_r ; 
          60 : mc_skip_flg_r = skip_flg_08_60_r ; 
          61 : mc_skip_flg_r = skip_flg_08_61_r ; 
          62 : mc_skip_flg_r = skip_flg_08_62_r ; 
          63 : mc_skip_flg_r = skip_flg_08_63_r ; 
          default : mc_skip_flg_r = 0 ;
        endcase 
      end 
      default : mc_skip_flg_r = 0 ;
    endcase 
  end 

//--- BUF_REC -------------------------- 

  // buf_rec
  rec_buf_rec_rot u_buf_rec (
    // global
    .clk             ( clk                   ),
    .rstn            ( rstn                  ),
    // ctrl_i
    .rotate_i        ( rotate_i              ),
    // wr_0
    .wr_0_ena_i      ( rec_wr_ena_r          ),
    .wr_0_sel_i      ( global_sel_w          ),
    .wr_0_siz_i      ( global_siz_w          ),
    .wr_0_4x4_x_i    ( global_4x4_x_r        ),
    .wr_0_4x4_y_i    ( global_4x4_y_r        ),
    .wr_0_idx_i      ( rec_wr_idx_r          ),
    .wr_0_dat_i      ( rec_wr_dat_w          ),
    // rd_1
    .rd_1_ena_i      ( rec_pip_rd_ena_i      ),
    .rd_1_sel_i      ( rec_pip_rd_sel_i      ),
    .rd_1_siz_i      ( rec_pip_rd_siz_i      ),
    .rd_1_4x4_x_i    ( rec_pip_rd_4x4_x_i    ),
    .rd_1_4x4_y_i    ( rec_pip_rd_4x4_y_i    ),
    .rd_1_idx_i      ( rec_pip_rd_idx_i      ),
    .rd_1_dat_o      ( rec_pip_rd_dat_o      ),
    // wr_1
    .wr_1_ena_i      ( rec_pip_wr_ena_i      ),
    .wr_1_sel_i      ( rec_pip_wr_sel_i      ),
    .wr_1_siz_i      ( rec_pip_wr_siz_i      ),
    .wr_1_4x4_x_i    ( rec_pip_wr_4x4_x_i    ),
    .wr_1_4x4_y_i    ( rec_pip_wr_4x4_y_i    ),
    .wr_1_idx_i      ( rec_pip_wr_idx_i      ),
    .wr_1_dat_i      ( rec_pip_wr_dat_i      )
    );

  // rec_wr_ena_r & rec_wr_idx_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rec_wr_ena_r <= 0 ;
      rec_wr_idx_r <= 0 ;
    end
    else begin
      rec_wr_ena_r <= rsp_wr_ena_i ;
      rec_wr_idx_r <= rsp_wr_idx_i ;
    end
  end

  // rec_wr_dat_w
  assign rec_wr_dat_w = { rec_wr_dat_00_trun_w
                         ,rec_wr_dat_01_trun_w
                         ,rec_wr_dat_02_trun_w
                         ,rec_wr_dat_03_trun_w
                         ,rec_wr_dat_04_trun_w
                         ,rec_wr_dat_05_trun_w
                         ,rec_wr_dat_06_trun_w
                         ,rec_wr_dat_07_trun_w
                         ,rec_wr_dat_08_trun_w
                         ,rec_wr_dat_09_trun_w
                         ,rec_wr_dat_10_trun_w
                         ,rec_wr_dat_11_trun_w
                         ,rec_wr_dat_12_trun_w
                         ,rec_wr_dat_13_trun_w
                         ,rec_wr_dat_14_trun_w
                         ,rec_wr_dat_15_trun_w
                         ,rec_wr_dat_16_trun_w
                         ,rec_wr_dat_17_trun_w
                         ,rec_wr_dat_18_trun_w
                         ,rec_wr_dat_19_trun_w
                         ,rec_wr_dat_20_trun_w
                         ,rec_wr_dat_21_trun_w
                         ,rec_wr_dat_22_trun_w
                         ,rec_wr_dat_23_trun_w
                         ,rec_wr_dat_24_trun_w
                         ,rec_wr_dat_25_trun_w
                         ,rec_wr_dat_26_trun_w
                         ,rec_wr_dat_27_trun_w
                         ,rec_wr_dat_28_trun_w
                         ,rec_wr_dat_29_trun_w
                         ,rec_wr_dat_30_trun_w
                         ,rec_wr_dat_31_trun_w };
  // rec_wr_dat_00-31_trun_w
  assign rec_wr_dat_00_trun_w = rec_wr_dat_00_w < 0 ? 0 : ( rec_wr_dat_00_w > 255 ? 8'd255 : rec_wr_dat_00_w ); // BIT_DEPTH
  assign rec_wr_dat_01_trun_w = rec_wr_dat_01_w < 0 ? 0 : ( rec_wr_dat_01_w > 255 ? 8'd255 : rec_wr_dat_01_w );
  assign rec_wr_dat_02_trun_w = rec_wr_dat_02_w < 0 ? 0 : ( rec_wr_dat_02_w > 255 ? 8'd255 : rec_wr_dat_02_w );
  assign rec_wr_dat_03_trun_w = rec_wr_dat_03_w < 0 ? 0 : ( rec_wr_dat_03_w > 255 ? 8'd255 : rec_wr_dat_03_w );
  assign rec_wr_dat_04_trun_w = rec_wr_dat_04_w < 0 ? 0 : ( rec_wr_dat_04_w > 255 ? 8'd255 : rec_wr_dat_04_w );
  assign rec_wr_dat_05_trun_w = rec_wr_dat_05_w < 0 ? 0 : ( rec_wr_dat_05_w > 255 ? 8'd255 : rec_wr_dat_05_w );
  assign rec_wr_dat_06_trun_w = rec_wr_dat_06_w < 0 ? 0 : ( rec_wr_dat_06_w > 255 ? 8'd255 : rec_wr_dat_06_w );
  assign rec_wr_dat_07_trun_w = rec_wr_dat_07_w < 0 ? 0 : ( rec_wr_dat_07_w > 255 ? 8'd255 : rec_wr_dat_07_w );
  assign rec_wr_dat_08_trun_w = rec_wr_dat_08_w < 0 ? 0 : ( rec_wr_dat_08_w > 255 ? 8'd255 : rec_wr_dat_08_w );
  assign rec_wr_dat_09_trun_w = rec_wr_dat_09_w < 0 ? 0 : ( rec_wr_dat_09_w > 255 ? 8'd255 : rec_wr_dat_09_w );
  assign rec_wr_dat_10_trun_w = rec_wr_dat_10_w < 0 ? 0 : ( rec_wr_dat_10_w > 255 ? 8'd255 : rec_wr_dat_10_w );
  assign rec_wr_dat_11_trun_w = rec_wr_dat_11_w < 0 ? 0 : ( rec_wr_dat_11_w > 255 ? 8'd255 : rec_wr_dat_11_w );
  assign rec_wr_dat_12_trun_w = rec_wr_dat_12_w < 0 ? 0 : ( rec_wr_dat_12_w > 255 ? 8'd255 : rec_wr_dat_12_w );
  assign rec_wr_dat_13_trun_w = rec_wr_dat_13_w < 0 ? 0 : ( rec_wr_dat_13_w > 255 ? 8'd255 : rec_wr_dat_13_w );
  assign rec_wr_dat_14_trun_w = rec_wr_dat_14_w < 0 ? 0 : ( rec_wr_dat_14_w > 255 ? 8'd255 : rec_wr_dat_14_w );
  assign rec_wr_dat_15_trun_w = rec_wr_dat_15_w < 0 ? 0 : ( rec_wr_dat_15_w > 255 ? 8'd255 : rec_wr_dat_15_w );
  assign rec_wr_dat_16_trun_w = rec_wr_dat_16_w < 0 ? 0 : ( rec_wr_dat_16_w > 255 ? 8'd255 : rec_wr_dat_16_w );
  assign rec_wr_dat_17_trun_w = rec_wr_dat_17_w < 0 ? 0 : ( rec_wr_dat_17_w > 255 ? 8'd255 : rec_wr_dat_17_w );
  assign rec_wr_dat_18_trun_w = rec_wr_dat_18_w < 0 ? 0 : ( rec_wr_dat_18_w > 255 ? 8'd255 : rec_wr_dat_18_w );
  assign rec_wr_dat_19_trun_w = rec_wr_dat_19_w < 0 ? 0 : ( rec_wr_dat_19_w > 255 ? 8'd255 : rec_wr_dat_19_w );
  assign rec_wr_dat_20_trun_w = rec_wr_dat_20_w < 0 ? 0 : ( rec_wr_dat_20_w > 255 ? 8'd255 : rec_wr_dat_20_w );
  assign rec_wr_dat_21_trun_w = rec_wr_dat_21_w < 0 ? 0 : ( rec_wr_dat_21_w > 255 ? 8'd255 : rec_wr_dat_21_w );
  assign rec_wr_dat_22_trun_w = rec_wr_dat_22_w < 0 ? 0 : ( rec_wr_dat_22_w > 255 ? 8'd255 : rec_wr_dat_22_w );
  assign rec_wr_dat_23_trun_w = rec_wr_dat_23_w < 0 ? 0 : ( rec_wr_dat_23_w > 255 ? 8'd255 : rec_wr_dat_23_w );
  assign rec_wr_dat_24_trun_w = rec_wr_dat_24_w < 0 ? 0 : ( rec_wr_dat_24_w > 255 ? 8'd255 : rec_wr_dat_24_w );
  assign rec_wr_dat_25_trun_w = rec_wr_dat_25_w < 0 ? 0 : ( rec_wr_dat_25_w > 255 ? 8'd255 : rec_wr_dat_25_w );
  assign rec_wr_dat_26_trun_w = rec_wr_dat_26_w < 0 ? 0 : ( rec_wr_dat_26_w > 255 ? 8'd255 : rec_wr_dat_26_w );
  assign rec_wr_dat_27_trun_w = rec_wr_dat_27_w < 0 ? 0 : ( rec_wr_dat_27_w > 255 ? 8'd255 : rec_wr_dat_27_w );
  assign rec_wr_dat_28_trun_w = rec_wr_dat_28_w < 0 ? 0 : ( rec_wr_dat_28_w > 255 ? 8'd255 : rec_wr_dat_28_w );
  assign rec_wr_dat_29_trun_w = rec_wr_dat_29_w < 0 ? 0 : ( rec_wr_dat_29_w > 255 ? 8'd255 : rec_wr_dat_29_w );
  assign rec_wr_dat_30_trun_w = rec_wr_dat_30_w < 0 ? 0 : ( rec_wr_dat_30_w > 255 ? 8'd255 : rec_wr_dat_30_w );
  assign rec_wr_dat_31_trun_w = rec_wr_dat_31_w < 0 ? 0 : ( rec_wr_dat_31_w > 255 ? 8'd255 : rec_wr_dat_31_w );
  // rec_wr_dat_00-31_r
  assign rec_wr_dat_00_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_00_w} : { rsp_wr_dat_00_r} + {2'b0,pre_rd_dat_00_w} ; // rsp_wr_dat_00_r[`PIXEL_WIDTH],
  assign rec_wr_dat_01_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_01_w} : { rsp_wr_dat_01_r} + {2'b0,pre_rd_dat_01_w} ; // rsp_wr_dat_01_r[`PIXEL_WIDTH],
  assign rec_wr_dat_02_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_02_w} : { rsp_wr_dat_02_r} + {2'b0,pre_rd_dat_02_w} ; // rsp_wr_dat_02_r[`PIXEL_WIDTH],
  assign rec_wr_dat_03_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_03_w} : { rsp_wr_dat_03_r} + {2'b0,pre_rd_dat_03_w} ; // rsp_wr_dat_03_r[`PIXEL_WIDTH],
  assign rec_wr_dat_04_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_04_w} : { rsp_wr_dat_04_r} + {2'b0,pre_rd_dat_04_w} ; // rsp_wr_dat_04_r[`PIXEL_WIDTH],
  assign rec_wr_dat_05_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_05_w} : { rsp_wr_dat_05_r} + {2'b0,pre_rd_dat_05_w} ; // rsp_wr_dat_05_r[`PIXEL_WIDTH],
  assign rec_wr_dat_06_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_06_w} : { rsp_wr_dat_06_r} + {2'b0,pre_rd_dat_06_w} ; // rsp_wr_dat_06_r[`PIXEL_WIDTH],
  assign rec_wr_dat_07_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_07_w} : { rsp_wr_dat_07_r} + {2'b0,pre_rd_dat_07_w} ; // rsp_wr_dat_07_r[`PIXEL_WIDTH],
  assign rec_wr_dat_08_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_08_w} : { rsp_wr_dat_08_r} + {2'b0,pre_rd_dat_08_w} ; // rsp_wr_dat_08_r[`PIXEL_WIDTH],
  assign rec_wr_dat_09_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_09_w} : { rsp_wr_dat_09_r} + {2'b0,pre_rd_dat_09_w} ; // rsp_wr_dat_09_r[`PIXEL_WIDTH],
  assign rec_wr_dat_10_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_10_w} : { rsp_wr_dat_10_r} + {2'b0,pre_rd_dat_10_w} ; // rsp_wr_dat_10_r[`PIXEL_WIDTH],
  assign rec_wr_dat_11_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_11_w} : { rsp_wr_dat_11_r} + {2'b0,pre_rd_dat_11_w} ; // rsp_wr_dat_11_r[`PIXEL_WIDTH],
  assign rec_wr_dat_12_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_12_w} : { rsp_wr_dat_12_r} + {2'b0,pre_rd_dat_12_w} ; // rsp_wr_dat_12_r[`PIXEL_WIDTH],
  assign rec_wr_dat_13_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_13_w} : { rsp_wr_dat_13_r} + {2'b0,pre_rd_dat_13_w} ; // rsp_wr_dat_13_r[`PIXEL_WIDTH],
  assign rec_wr_dat_14_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_14_w} : { rsp_wr_dat_14_r} + {2'b0,pre_rd_dat_14_w} ; // rsp_wr_dat_14_r[`PIXEL_WIDTH],
  assign rec_wr_dat_15_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_15_w} : { rsp_wr_dat_15_r} + {2'b0,pre_rd_dat_15_w} ; // rsp_wr_dat_15_r[`PIXEL_WIDTH],
  assign rec_wr_dat_16_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_16_w} : { rsp_wr_dat_16_r} + {2'b0,pre_rd_dat_16_w} ; // rsp_wr_dat_16_r[`PIXEL_WIDTH],
  assign rec_wr_dat_17_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_17_w} : { rsp_wr_dat_17_r} + {2'b0,pre_rd_dat_17_w} ; // rsp_wr_dat_17_r[`PIXEL_WIDTH],
  assign rec_wr_dat_18_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_18_w} : { rsp_wr_dat_18_r} + {2'b0,pre_rd_dat_18_w} ; // rsp_wr_dat_18_r[`PIXEL_WIDTH],
  assign rec_wr_dat_19_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_19_w} : { rsp_wr_dat_19_r} + {2'b0,pre_rd_dat_19_w} ; // rsp_wr_dat_19_r[`PIXEL_WIDTH],
  assign rec_wr_dat_20_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_20_w} : { rsp_wr_dat_20_r} + {2'b0,pre_rd_dat_20_w} ; // rsp_wr_dat_20_r[`PIXEL_WIDTH],
  assign rec_wr_dat_21_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_21_w} : { rsp_wr_dat_21_r} + {2'b0,pre_rd_dat_21_w} ; // rsp_wr_dat_21_r[`PIXEL_WIDTH],
  assign rec_wr_dat_22_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_22_w} : { rsp_wr_dat_22_r} + {2'b0,pre_rd_dat_22_w} ; // rsp_wr_dat_22_r[`PIXEL_WIDTH],
  assign rec_wr_dat_23_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_23_w} : { rsp_wr_dat_23_r} + {2'b0,pre_rd_dat_23_w} ; // rsp_wr_dat_23_r[`PIXEL_WIDTH],
  assign rec_wr_dat_24_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_24_w} : { rsp_wr_dat_24_r} + {2'b0,pre_rd_dat_24_w} ; // rsp_wr_dat_24_r[`PIXEL_WIDTH],
  assign rec_wr_dat_25_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_25_w} : { rsp_wr_dat_25_r} + {2'b0,pre_rd_dat_25_w} ; // rsp_wr_dat_25_r[`PIXEL_WIDTH],
  assign rec_wr_dat_26_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_26_w} : { rsp_wr_dat_26_r} + {2'b0,pre_rd_dat_26_w} ; // rsp_wr_dat_26_r[`PIXEL_WIDTH],
  assign rec_wr_dat_27_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_27_w} : { rsp_wr_dat_27_r} + {2'b0,pre_rd_dat_27_w} ; // rsp_wr_dat_27_r[`PIXEL_WIDTH],
  assign rec_wr_dat_28_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_28_w} : { rsp_wr_dat_28_r} + {2'b0,pre_rd_dat_28_w} ; // rsp_wr_dat_28_r[`PIXEL_WIDTH],
  assign rec_wr_dat_29_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_29_w} : { rsp_wr_dat_29_r} + {2'b0,pre_rd_dat_29_w} ; // rsp_wr_dat_29_r[`PIXEL_WIDTH],
  assign rec_wr_dat_30_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_30_w} : { rsp_wr_dat_30_r} + {2'b0,pre_rd_dat_30_w} ; // rsp_wr_dat_30_r[`PIXEL_WIDTH],
  assign rec_wr_dat_31_w = mc_skip_flg_r ? {2'b0,pre_rd_dat_31_w} : { rsp_wr_dat_31_r} + {2'b0,pre_rd_dat_31_w} ; // rsp_wr_dat_31_r[`PIXEL_WIDTH],
  // rsp_wr_dat_31-00_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rsp_wr_dat_31_r <= 0 ;
      rsp_wr_dat_30_r <= 0 ;
      rsp_wr_dat_29_r <= 0 ;
      rsp_wr_dat_28_r <= 0 ;
      rsp_wr_dat_27_r <= 0 ;
      rsp_wr_dat_26_r <= 0 ;
      rsp_wr_dat_25_r <= 0 ;
      rsp_wr_dat_24_r <= 0 ;
      rsp_wr_dat_23_r <= 0 ;
      rsp_wr_dat_22_r <= 0 ;
      rsp_wr_dat_21_r <= 0 ;
      rsp_wr_dat_20_r <= 0 ;
      rsp_wr_dat_19_r <= 0 ;
      rsp_wr_dat_18_r <= 0 ;
      rsp_wr_dat_17_r <= 0 ;
      rsp_wr_dat_16_r <= 0 ;
      rsp_wr_dat_15_r <= 0 ;
      rsp_wr_dat_14_r <= 0 ;
      rsp_wr_dat_13_r <= 0 ;
      rsp_wr_dat_12_r <= 0 ;
      rsp_wr_dat_11_r <= 0 ;
      rsp_wr_dat_10_r <= 0 ;
      rsp_wr_dat_09_r <= 0 ;
      rsp_wr_dat_08_r <= 0 ;
      rsp_wr_dat_07_r <= 0 ;
      rsp_wr_dat_06_r <= 0 ;
      rsp_wr_dat_05_r <= 0 ;
      rsp_wr_dat_04_r <= 0 ;
      rsp_wr_dat_03_r <= 0 ;
      rsp_wr_dat_02_r <= 0 ;
      rsp_wr_dat_01_r <= 0 ;
      rsp_wr_dat_00_r <= 0 ;
    end
    else begin
      { rsp_wr_dat_31_r
       ,rsp_wr_dat_30_r
       ,rsp_wr_dat_29_r
       ,rsp_wr_dat_28_r
       ,rsp_wr_dat_27_r
       ,rsp_wr_dat_26_r
       ,rsp_wr_dat_25_r
       ,rsp_wr_dat_24_r
       ,rsp_wr_dat_23_r
       ,rsp_wr_dat_22_r
       ,rsp_wr_dat_21_r
       ,rsp_wr_dat_20_r
       ,rsp_wr_dat_19_r
       ,rsp_wr_dat_18_r
       ,rsp_wr_dat_17_r
       ,rsp_wr_dat_16_r
       ,rsp_wr_dat_15_r
       ,rsp_wr_dat_14_r
       ,rsp_wr_dat_13_r
       ,rsp_wr_dat_12_r
       ,rsp_wr_dat_11_r
       ,rsp_wr_dat_10_r
       ,rsp_wr_dat_09_r
       ,rsp_wr_dat_08_r
       ,rsp_wr_dat_07_r
       ,rsp_wr_dat_06_r
       ,rsp_wr_dat_05_r
       ,rsp_wr_dat_04_r
       ,rsp_wr_dat_03_r
       ,rsp_wr_dat_02_r
       ,rsp_wr_dat_01_r
       ,rsp_wr_dat_00_r } <= rsp_wr_dat_i ;
    end
  end

//--- MVD IF ---------------------------
  // buf_mvd
  rec_buf_mvd_rot u_buf_mvd (
    // global
    .clk             ( clk                 ),
    .rstn            ( rstn                ),
    // ctrl_i
    .rotate_i        ( rotate_i            ),
    // wr_0
    .wr_0_ena_i      ( mvd_wr_ena_i        ),
    .wr_0_adr_i      ( mvd_wr_adr_i        ),
    .wr_0_dat_i      ( mvd_wr_dat_i        ),
    // rd_1
    .rd_2_ena_i      ( mvd_pip_rd_ena_i    ),
    .rd_2_adr_i      ( mvd_pip_rd_adr_i    ),
    .rd_2_dat_o      ( mvd_pip_rd_dat_o    )
    );


//--- CBF_IF ---------------------------

  // cbf_x_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cbf_y_r <= 0 ;
      cbf_u_r <= 0 ;
      cbf_v_r <= 0 ;
    end
    else begin
      if( cbf_done_r ) begin
        if( cbf_zero_r )
          case( global_sel_w )
            `TYPE_Y : cbf_y_r <= cbf_0_mask_w & cbf_y_r ;
            `TYPE_U : cbf_u_r <= cbf_0_mask_w & cbf_u_r ;
            `TYPE_V : cbf_v_r <= cbf_0_mask_w & cbf_v_r ;
          endcase
        else begin
          case( global_sel_w )
            `TYPE_Y : cbf_y_r <= cbf_1_mask_w | cbf_y_r ;
            `TYPE_U : cbf_u_r <= cbf_1_mask_w | cbf_u_r ;
            `TYPE_V : cbf_v_r <= cbf_1_mask_w | cbf_v_r ;
          endcase
        end
      end
    end
  end

  // cbf_done_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      cbf_done_r <= 0 ;
    else if( cef_wr_ena_i )
      case( global_siz_w )
        `SIZE_04 : cbf_done_r <= ( cef_wr_idx_i=='h00 );
        `SIZE_08 : cbf_done_r <= ( cef_wr_idx_i=='h04 );
        `SIZE_16 : cbf_done_r <= ( cef_wr_idx_i=='h0e );
        `SIZE_32 : cbf_done_r <= ( cef_wr_idx_i=='h1f );
      endcase
    else begin
      cbf_done_r <= 0 ;
    end
  end

  // cbf_zero_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cbf_zero_r <= 1 ;
    end
    else if( cbf_done_r ) begin
      cbf_zero_r <= 1 ;
    end
    else if( cef_wr_ena_i && (cef_wr_dat_i!=0) ) begin
      cbf_zero_r <= 0 ;
    end
  end

  // cbf_mask_w
  assign cbf_1_mask_w = (global_sel_w==`TYPE_Y) ? (cbf_cur_w<<cbf_addr_w) : (cbf_cur_w<<(cbf_addr_w<<2)) ;    // TODO: merge cbf_addr_w & cbf_addr_w<<2
  assign cbf_0_mask_w = ~cbf_1_mask_w ;

  // cbf_cur_w
  always @(*) begin
                   cbf_cur_w = 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 ;
    if( global_sel_w==`TYPE_Y )
      case( global_siz_w )
        `SIZE_04 : cbf_cur_w = 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001 ;
        `SIZE_08 : cbf_cur_w = 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111 ;
        `SIZE_16 : cbf_cur_w = 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111 ;
        `SIZE_32 : cbf_cur_w = 64'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 ;
      endcase
    else begin
      case( global_siz_w )
        `SIZE_04 : cbf_cur_w = 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111 ;
        `SIZE_08 : cbf_cur_w = 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111 ;
        `SIZE_16 : cbf_cur_w = 64'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 ;
      endcase
    end
  end

  assign cbf_addr_w = { global_4x4_y_r[3] ,global_4x4_x_r[3] ,
                        global_4x4_y_r[2] ,global_4x4_x_r[2] ,
                        global_4x4_y_r[1] ,global_4x4_x_r[1] ,
                        global_4x4_y_r[0] ,global_4x4_x_r[0] };

endmodule
