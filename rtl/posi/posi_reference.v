//-------------------------------------------------------------------
//
//  Filename      : h265_posi_reference.v
//  Author        : Huang Leilei
//  Created       : 2018-04-11
//  Description   : reference control in module post intra
//
//-------------------------------------------------------------------
//
//  | i         | d0        | d1        | d2        | d3  | d4     |
//  | raw_pre_1 | raw_pre_0 | raw       |           |     |        |
//  |           |           | pad_pre   | pad       |     |        |
//  |           | flt_pre_2 | flt_pre_1 | flt_pre_0 | flt |        |
//  |           |           |           |           |     | output |
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module posi_reference(
  // global
  clk             ,
  rstn            ,
  // ctrl_if
  start_i         ,
  ready_o         ,
  done_o          ,
  // cfg_i
  num_mode_i      ,
  ctu_x_cur_i     ,
  ctu_y_cur_i     ,
  ctu_x_all_i     ,
  ctu_y_all_i     ,
  ctu_x_res_i     ,
  ctu_y_res_i     ,
  size_i          ,
  position_i      ,
  // ram_row_if
  row_rd_ena_o    ,
  row_rd_adr_o    ,
  row_rd_dat_i    ,
  // ram_col_if
  col_rd_ena_o    ,
  col_rd_adr_o    ,
  col_rd_dat_i    ,
  // ram_fra_if
  fra_rd_ena_o    ,
  fra_rd_adr_o    ,
  fra_rd_dat_i    ,
  // ram_mod_if
  mod_rd_ena_o    ,
  mod_rd_adr_o    ,
  mod_rd_dat_i    ,
  // cfg_r
  mode_o          ,
  size_o          ,
  position_o      ,
  // ref_raw_tl_r
  ref_r_o         ,
  ref_t_o         ,
  ref_tl_o        ,
  ref_l_o         ,
  ref_d_o
  );


//*** PARAMETER ****************************************************************

  // local
  localparam FSM_RAW_WD                = 1                ;
  localparam     RAW_IDLE              = 1'd0             ;
  localparam     RAW_BUSY              = 1'd1             ;

  localparam FSM_FLT_WD                = 1                ;
  localparam     FLT_IDLE              = 1'd0             ;
  localparam     FLT_BUSY              = 1'd1             ;

  localparam   IDX_4x4_SHF             = 4                ;
  localparam   IDX_4x4_DAT             = 16               ;

  localparam   DAT_DEF                 = {1'b1,{(`PIXEL_WIDTH-1){1'b0}}} ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                clk                ;
  input                                rstn               ;
  // ctrl_if
  input                                start_i            ;
  output reg                           ready_o            ;
  output                               done_o             ;
  // cfg_i
  input      [3              -1 :0]    num_mode_i         ;
  input      [`PIC_X_WIDTH   -1 :0]    ctu_x_cur_i        ;
  input      [`PIC_Y_WIDTH   -1 :0]    ctu_y_cur_i        ;
  input      [`PIC_X_WIDTH   -1 :0]    ctu_x_all_i        ;
  input      [`PIC_Y_WIDTH   -1 :0]    ctu_y_all_i        ;
  input      [4              -1 :0]    ctu_x_res_i        ;
  input      [4              -1 :0]    ctu_y_res_i        ;
  input      [2              -1 :0]    size_i             ;
  input      [8              -1 :0]    position_i         ;
  // ram_row_if
  output reg                           row_rd_ena_o       ;
  output reg [4+4            -1 :0]    row_rd_adr_o       ;
  input      [`PIXEL_WIDTH*4 -1 :0]    row_rd_dat_i       ;
  // ram_col_if
  output reg                           col_rd_ena_o       ;
  output reg [4+4            -1 :0]    col_rd_adr_o       ;
  input      [`PIXEL_WIDTH*4 -1 :0]    col_rd_dat_i       ;
  // ram_fra_if
  output reg                           fra_rd_ena_o       ;
  output reg [`PIC_X_WIDTH+4 -1 :0]    fra_rd_adr_o       ;
  input      [`PIXEL_WIDTH*4 -1 :0]    fra_rd_dat_i       ;
  // ram_mode_if
  output reg                           mod_rd_ena_o       ;
  output reg [9              -1 :0]    mod_rd_adr_o       ;
  input      [6              -1 :0]    mod_rd_dat_i       ;
  // cfg_r
  output reg [6              -1 :0]    mode_o             ;
  output reg [2              -1 :0]    size_o             ;
  output reg [8              -1 :0]    position_o         ;
  // ref
  output     [`PIXEL_WIDTH*32-1 :0]    ref_r_o            ;
  output     [`PIXEL_WIDTH*32-1 :0]    ref_t_o            ;
  output     [`PIXEL_WIDTH   -1 :0]    ref_tl_o           ;
  output     [`PIXEL_WIDTH*32-1 :0]    ref_l_o            ;
  output     [`PIXEL_WIDTH*32-1 :0]    ref_d_o            ;


//*** REG/WIRE *****************************************************************

  // global
  wire       [4              -1 :0]    idx_4x4_x_w        ;
  wire       [4              -1 :0]    idx_4x4_y_w        ;

  wire       [`PIXEL_WIDTH   -1 :0]    fra_rd_dat_3_w     ;
  wire       [`PIXEL_WIDTH   -1 :0]    fra_rd_dat_2_w     ;
  wire       [`PIXEL_WIDTH   -1 :0]    fra_rd_dat_1_w     ;
  wire       [`PIXEL_WIDTH   -1 :0]    fra_rd_dat_0_w     ;

  wire       [`PIXEL_WIDTH   -1 :0]    row_rd_dat_3_w     ;
  wire       [`PIXEL_WIDTH   -1 :0]    row_rd_dat_2_w     ;
  wire       [`PIXEL_WIDTH   -1 :0]    row_rd_dat_1_w     ;
  wire       [`PIXEL_WIDTH   -1 :0]    row_rd_dat_0_w     ;

  wire       [`PIXEL_WIDTH   -1 :0]    col_rd_dat_3_w     ;
  wire       [`PIXEL_WIDTH   -1 :0]    col_rd_dat_2_w     ;
  wire       [`PIXEL_WIDTH   -1 :0]    col_rd_dat_1_w     ;
  wire       [`PIXEL_WIDTH   -1 :0]    col_rd_dat_0_w     ;

  // raw_pre_1
  reg        [FSM_RAW_WD     -1 :0]    cur_state_raw_r    ;
  reg        [FSM_RAW_WD     -1 :0]    nxt_state_raw_w    ;

  wire                                 done_raw_busy_w    ;

  reg        [5              -1 :0]    cnt_raw_r          ;
  reg                                  cnt_raw_done_w     ;

  reg        [2              -1 :0]    size_d0_r          ;
  reg        [8              -1 :0]    position_d0_r      ;
  reg        [4              -1 :0]    idx_4x4_x_d0_r     ;
  reg        [4              -1 :0]    idx_4x4_y_d0_r     ;
  reg        [5              -1 :0]    cnt_raw_d0_r       ;
  reg                                  cnt_raw_done_d0_r  ;
  reg        [2              -1 :0]    size_d1_r          ;
  reg        [8              -1 :0]    position_d1_r      ;
  reg        [4              -1 :0]    idx_4x4_x_d1_r     ;
  reg        [4              -1 :0]    idx_4x4_y_d1_r     ;
  reg        [5              -1 :0]    cnt_raw_d1_r       ;
  reg                                  cnt_raw_done_d1_r  ;
  reg        [2              -1 :0]    size_d2_r          ;
  reg        [8              -1 :0]    position_d2_r      ;
  reg        [4              -1 :0]    idx_4x4_x_d2_r     ;
  reg        [4              -1 :0]    idx_4x4_y_d2_r     ;
  reg        [5              -1 :0]    cnt_raw_d2_r       ;
  reg                                  cnt_raw_done_d2_r  ;
  reg        [2              -1 :0]    size_d3_r          ;
  reg        [8              -1 :0]    position_d3_r      ;
  reg        [4              -1 :0]    idx_4x4_x_d3_r     ;
  reg        [4              -1 :0]    idx_4x4_y_d3_r     ;
  reg        [5              -1 :0]    cnt_raw_d3_r       ;
  reg                                  cnt_raw_done_d3_r  ;
  // raw_pre_0

  // raw
  reg                                  raw_valid_r        ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_tl_r       ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_tl_prev_r  ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_t00_r      ,ref_raw_t01_r ,ref_raw_t02_r ,ref_raw_t03_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_t04_r      ,ref_raw_t05_r ,ref_raw_t06_r ,ref_raw_t07_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_t08_r      ,ref_raw_t09_r ,ref_raw_t10_r ,ref_raw_t11_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_t12_r      ,ref_raw_t13_r ,ref_raw_t14_r ,ref_raw_t15_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_t16_r      ,ref_raw_t17_r ,ref_raw_t18_r ,ref_raw_t19_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_t20_r      ,ref_raw_t21_r ,ref_raw_t22_r ,ref_raw_t23_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_t24_r      ,ref_raw_t25_r ,ref_raw_t26_r ,ref_raw_t27_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_t28_r      ,ref_raw_t29_r ,ref_raw_t30_r ,ref_raw_t31_r ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_r00_r      ,ref_raw_r01_r ,ref_raw_r02_r ,ref_raw_r03_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_r04_r      ,ref_raw_r05_r ,ref_raw_r06_r ,ref_raw_r07_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_r08_r      ,ref_raw_r09_r ,ref_raw_r10_r ,ref_raw_r11_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_r12_r      ,ref_raw_r13_r ,ref_raw_r14_r ,ref_raw_r15_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_r16_r      ,ref_raw_r17_r ,ref_raw_r18_r ,ref_raw_r19_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_r20_r      ,ref_raw_r21_r ,ref_raw_r22_r ,ref_raw_r23_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_r24_r      ,ref_raw_r25_r ,ref_raw_r26_r ,ref_raw_r27_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_r28_r      ,ref_raw_r29_r ,ref_raw_r30_r ,ref_raw_r31_r ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_l00_r      ,ref_raw_l01_r ,ref_raw_l02_r ,ref_raw_l03_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_l04_r      ,ref_raw_l05_r ,ref_raw_l06_r ,ref_raw_l07_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_l08_r      ,ref_raw_l09_r ,ref_raw_l10_r ,ref_raw_l11_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_l12_r      ,ref_raw_l13_r ,ref_raw_l14_r ,ref_raw_l15_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_l16_r      ,ref_raw_l17_r ,ref_raw_l18_r ,ref_raw_l19_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_l20_r      ,ref_raw_l21_r ,ref_raw_l22_r ,ref_raw_l23_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_l24_r      ,ref_raw_l25_r ,ref_raw_l26_r ,ref_raw_l27_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_l28_r      ,ref_raw_l29_r ,ref_raw_l30_r ,ref_raw_l31_r ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_d00_r      ,ref_raw_d01_r ,ref_raw_d02_r ,ref_raw_d03_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_d04_r      ,ref_raw_d05_r ,ref_raw_d06_r ,ref_raw_d07_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_d08_r      ,ref_raw_d09_r ,ref_raw_d10_r ,ref_raw_d11_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_d12_r      ,ref_raw_d13_r ,ref_raw_d14_r ,ref_raw_d15_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_d16_r      ,ref_raw_d17_r ,ref_raw_d18_r ,ref_raw_d19_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_d20_r      ,ref_raw_d21_r ,ref_raw_d22_r ,ref_raw_d23_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_d24_r      ,ref_raw_d25_r ,ref_raw_d26_r ,ref_raw_d27_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_raw_d28_r      ,ref_raw_d29_r ,ref_raw_d30_r ,ref_raw_d31_r ;

  // pad_pre
  wire                                 start_pad_pre_w    ;

  reg                                  ctu_tl_exist_w     ;
  reg                                  ctu_tp_exist_w     ;
  reg                                  ctu_rt_exist_w     ;
  reg                                  ctu_lf_exist_w     ;

  wire       [4              -1 :0]    pu_4x4_x_of_luma_w      ;
  wire       [4              -1 :0]    pu_4x4_y_of_luma_w      ;
  
  wire       [4              -1 :0]    pu_order_x_of_luma_w    ;
  wire       [4              -1 :0]    pu_order_y_of_luma_w    ;
  wire       [4              -1 :0]    pu_order_rt_x_of_luma_w ;
  wire       [4              -1 :0]    pu_order_rt_y_of_luma_w ;
  wire       [4              -1 :0]    pu_order_dn_x_of_luma_w ;
  wire       [4              -1 :0]    pu_order_dn_y_of_luma_w ;
  wire       [8              -1 :0]    pu_order_rt_of_luma_w   ;
  wire       [8              -1 :0]    pu_order_dn_of_luma_w   ;

  reg        [8              -1 :0]    cu_order_w         ;
  reg        [4              -1 :0]    pu_delta_w              ;

  reg                                  pu_tp_exist_r      ;
  reg                                  pu_lf_exist_r      ;
  reg                                  pu_tl_exist_r      ;
  reg        [8-1:0]                   pu_rt_exist_r      ;
  reg        [8-1:0]                   pu_dn_exist_r      ;

  // pad
  wire                                 start_pad_w        ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_tl_r       ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t00_r      ,ref_pad_t01_r ,ref_pad_t02_r ,ref_pad_t03_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t04_r      ,ref_pad_t05_r ,ref_pad_t06_r ,ref_pad_t07_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t08_r      ,ref_pad_t09_r ,ref_pad_t10_r ,ref_pad_t11_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t12_r      ,ref_pad_t13_r ,ref_pad_t14_r ,ref_pad_t15_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t16_r      ,ref_pad_t17_r ,ref_pad_t18_r ,ref_pad_t19_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t20_r      ,ref_pad_t21_r ,ref_pad_t22_r ,ref_pad_t23_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t24_r      ,ref_pad_t25_r ,ref_pad_t26_r ,ref_pad_t27_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_t28_r      ,ref_pad_t29_r ,ref_pad_t30_r ,ref_pad_t31_r ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r00_r      ,ref_pad_r01_r ,ref_pad_r02_r ,ref_pad_r03_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r04_r      ,ref_pad_r05_r ,ref_pad_r06_r ,ref_pad_r07_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r08_r      ,ref_pad_r09_r ,ref_pad_r10_r ,ref_pad_r11_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r12_r      ,ref_pad_r13_r ,ref_pad_r14_r ,ref_pad_r15_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r16_r      ,ref_pad_r17_r ,ref_pad_r18_r ,ref_pad_r19_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r20_r      ,ref_pad_r21_r ,ref_pad_r22_r ,ref_pad_r23_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r24_r      ,ref_pad_r25_r ,ref_pad_r26_r ,ref_pad_r27_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_r28_r      ,ref_pad_r29_r ,ref_pad_r30_r ,ref_pad_r31_r ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l00_r      ,ref_pad_l01_r ,ref_pad_l02_r ,ref_pad_l03_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l04_r      ,ref_pad_l05_r ,ref_pad_l06_r ,ref_pad_l07_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l08_r      ,ref_pad_l09_r ,ref_pad_l10_r ,ref_pad_l11_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l12_r      ,ref_pad_l13_r ,ref_pad_l14_r ,ref_pad_l15_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l16_r      ,ref_pad_l17_r ,ref_pad_l18_r ,ref_pad_l19_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l20_r      ,ref_pad_l21_r ,ref_pad_l22_r ,ref_pad_l23_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l24_r      ,ref_pad_l25_r ,ref_pad_l26_r ,ref_pad_l27_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_l28_r      ,ref_pad_l29_r ,ref_pad_l30_r ,ref_pad_l31_r ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d00_r      ,ref_pad_d01_r ,ref_pad_d02_r ,ref_pad_d03_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d04_r      ,ref_pad_d05_r ,ref_pad_d06_r ,ref_pad_d07_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d08_r      ,ref_pad_d09_r ,ref_pad_d10_r ,ref_pad_d11_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d12_r      ,ref_pad_d13_r ,ref_pad_d14_r ,ref_pad_d15_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d16_r      ,ref_pad_d17_r ,ref_pad_d18_r ,ref_pad_d19_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d20_r      ,ref_pad_d21_r ,ref_pad_d22_r ,ref_pad_d23_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d24_r      ,ref_pad_d25_r ,ref_pad_d26_r ,ref_pad_d27_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_pad_d28_r      ,ref_pad_d29_r ,ref_pad_d30_r ,ref_pad_d31_r ;

  // flt_pre_0
  reg        [FSM_FLT_WD     -1 :0]    cur_state_flt_r    ;
  reg        [FSM_FLT_WD     -1 :0]    nxt_state_flt_w    ;

  wire                                 start_flt_pre_w    ;
  wire                                 done_flt_busy_w    ;

  reg        [3              -1 :0]    cnt_mode_r         ;
  wire                                 cnt_mode_done_w    ;

  reg        [7              -1 :0]    cnt_flt_r          ;
  reg                                  cnt_flt_done_w     ;

  reg        [9              -1 :0]    mod_rd_adr_offset_w;

  // flt_pre_1

  // flt_pre_2
  reg                                  mode_valid_r       ;

  reg                                  flt_flag_r         ;

  // flt
  reg        [6              -1 :0]    mod_rd_dat_r       ;

  reg                                  start_flt_r        ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_tl_r       ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t00_r      ,ref_flt_t01_r ,ref_flt_t02_r ,ref_flt_t03_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t04_r      ,ref_flt_t05_r ,ref_flt_t06_r ,ref_flt_t07_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t08_r      ,ref_flt_t09_r ,ref_flt_t10_r ,ref_flt_t11_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t12_r      ,ref_flt_t13_r ,ref_flt_t14_r ,ref_flt_t15_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t16_r      ,ref_flt_t17_r ,ref_flt_t18_r ,ref_flt_t19_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t20_r      ,ref_flt_t21_r ,ref_flt_t22_r ,ref_flt_t23_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t24_r      ,ref_flt_t25_r ,ref_flt_t26_r ,ref_flt_t27_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_t28_r      ,ref_flt_t29_r ,ref_flt_t30_r ,ref_flt_t31_r ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r00_r      ,ref_flt_r01_r ,ref_flt_r02_r ,ref_flt_r03_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r04_r      ,ref_flt_r05_r ,ref_flt_r06_r ,ref_flt_r07_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r08_r      ,ref_flt_r09_r ,ref_flt_r10_r ,ref_flt_r11_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r12_r      ,ref_flt_r13_r ,ref_flt_r14_r ,ref_flt_r15_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r16_r      ,ref_flt_r17_r ,ref_flt_r18_r ,ref_flt_r19_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r20_r      ,ref_flt_r21_r ,ref_flt_r22_r ,ref_flt_r23_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r24_r      ,ref_flt_r25_r ,ref_flt_r26_r ,ref_flt_r27_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_r28_r      ,ref_flt_r29_r ,ref_flt_r30_r ,ref_flt_r31_r ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l00_r      ,ref_flt_l01_r ,ref_flt_l02_r ,ref_flt_l03_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l04_r      ,ref_flt_l05_r ,ref_flt_l06_r ,ref_flt_l07_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l08_r      ,ref_flt_l09_r ,ref_flt_l10_r ,ref_flt_l11_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l12_r      ,ref_flt_l13_r ,ref_flt_l14_r ,ref_flt_l15_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l16_r      ,ref_flt_l17_r ,ref_flt_l18_r ,ref_flt_l19_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l20_r      ,ref_flt_l21_r ,ref_flt_l22_r ,ref_flt_l23_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l24_r      ,ref_flt_l25_r ,ref_flt_l26_r ,ref_flt_l27_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_l28_r      ,ref_flt_l29_r ,ref_flt_l30_r ,ref_flt_l31_r ;

  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d00_r      ,ref_flt_d01_r ,ref_flt_d02_r ,ref_flt_d03_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d04_r      ,ref_flt_d05_r ,ref_flt_d06_r ,ref_flt_d07_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d08_r      ,ref_flt_d09_r ,ref_flt_d10_r ,ref_flt_d11_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d12_r      ,ref_flt_d13_r ,ref_flt_d14_r ,ref_flt_d15_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d16_r      ,ref_flt_d17_r ,ref_flt_d18_r ,ref_flt_d19_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d20_r      ,ref_flt_d21_r ,ref_flt_d22_r ,ref_flt_d23_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d24_r      ,ref_flt_d25_r ,ref_flt_d26_r ,ref_flt_d27_r ;
  reg        [`PIXEL_WIDTH   -1 :0]    ref_flt_d28_r      ,ref_flt_d29_r ,ref_flt_d30_r ,ref_flt_d31_r ;


//*** MAIN BODY ****************************************************************

//--- GLOBAL ---------------------------
  // idx_i
  assign idx_4x4_x_w = {position_i[6],position_i[4],position_i[2],position_i[0]} ;
  assign idx_4x4_y_w = {position_i[7],position_i[5],position_i[3],position_i[1]} ;

  // raw_i
  assign { fra_rd_dat_3_w ,fra_rd_dat_2_w ,fra_rd_dat_1_w ,fra_rd_dat_0_w } = fra_rd_dat_i ;
  assign { row_rd_dat_3_w ,row_rd_dat_2_w ,row_rd_dat_1_w ,row_rd_dat_0_w } = row_rd_dat_i ;
  assign { col_rd_dat_3_w ,col_rd_dat_2_w ,col_rd_dat_1_w ,col_rd_dat_0_w } = col_rd_dat_i ;

  // ref_o
  assign ref_tl_o = ref_flt_tl_r ;

  assign ref_t_o = { ref_flt_t00_r ,ref_flt_t01_r ,ref_flt_t02_r ,ref_flt_t03_r
                    ,ref_flt_t04_r ,ref_flt_t05_r ,ref_flt_t06_r ,ref_flt_t07_r
                    ,ref_flt_t08_r ,ref_flt_t09_r ,ref_flt_t10_r ,ref_flt_t11_r
                    ,ref_flt_t12_r ,ref_flt_t13_r ,ref_flt_t14_r ,ref_flt_t15_r
                    ,ref_flt_t16_r ,ref_flt_t17_r ,ref_flt_t18_r ,ref_flt_t19_r
                    ,ref_flt_t20_r ,ref_flt_t21_r ,ref_flt_t22_r ,ref_flt_t23_r
                    ,ref_flt_t24_r ,ref_flt_t25_r ,ref_flt_t26_r ,ref_flt_t27_r
                    ,ref_flt_t28_r ,ref_flt_t29_r ,ref_flt_t30_r ,ref_flt_t31_r };

  assign ref_r_o = { ref_flt_r00_r ,ref_flt_r01_r ,ref_flt_r02_r ,ref_flt_r03_r
                    ,ref_flt_r04_r ,ref_flt_r05_r ,ref_flt_r06_r ,ref_flt_r07_r
                    ,ref_flt_r08_r ,ref_flt_r09_r ,ref_flt_r10_r ,ref_flt_r11_r
                    ,ref_flt_r12_r ,ref_flt_r13_r ,ref_flt_r14_r ,ref_flt_r15_r
                    ,ref_flt_r16_r ,ref_flt_r17_r ,ref_flt_r18_r ,ref_flt_r19_r
                    ,ref_flt_r20_r ,ref_flt_r21_r ,ref_flt_r22_r ,ref_flt_r23_r
                    ,ref_flt_r24_r ,ref_flt_r25_r ,ref_flt_r26_r ,ref_flt_r27_r
                    ,ref_flt_r28_r ,ref_flt_r29_r ,ref_flt_r30_r ,ref_flt_r31_r };

  assign ref_l_o = { ref_flt_l00_r ,ref_flt_l01_r ,ref_flt_l02_r ,ref_flt_l03_r
                    ,ref_flt_l04_r ,ref_flt_l05_r ,ref_flt_l06_r ,ref_flt_l07_r
                    ,ref_flt_l08_r ,ref_flt_l09_r ,ref_flt_l10_r ,ref_flt_l11_r
                    ,ref_flt_l12_r ,ref_flt_l13_r ,ref_flt_l14_r ,ref_flt_l15_r
                    ,ref_flt_l16_r ,ref_flt_l17_r ,ref_flt_l18_r ,ref_flt_l19_r
                    ,ref_flt_l20_r ,ref_flt_l21_r ,ref_flt_l22_r ,ref_flt_l23_r
                    ,ref_flt_l24_r ,ref_flt_l25_r ,ref_flt_l26_r ,ref_flt_l27_r
                    ,ref_flt_l28_r ,ref_flt_l29_r ,ref_flt_l30_r ,ref_flt_l31_r };

  assign ref_d_o = { ref_flt_d00_r ,ref_flt_d01_r ,ref_flt_d02_r ,ref_flt_d03_r
                    ,ref_flt_d04_r ,ref_flt_d05_r ,ref_flt_d06_r ,ref_flt_d07_r
                    ,ref_flt_d08_r ,ref_flt_d09_r ,ref_flt_d10_r ,ref_flt_d11_r
                    ,ref_flt_d12_r ,ref_flt_d13_r ,ref_flt_d14_r ,ref_flt_d15_r
                    ,ref_flt_d16_r ,ref_flt_d17_r ,ref_flt_d18_r ,ref_flt_d19_r
                    ,ref_flt_d20_r ,ref_flt_d21_r ,ref_flt_d22_r ,ref_flt_d23_r
                    ,ref_flt_d24_r ,ref_flt_d25_r ,ref_flt_d26_r ,ref_flt_d27_r
                    ,ref_flt_d28_r ,ref_flt_d29_r ,ref_flt_d30_r ,ref_flt_d31_r };


//--- RAW_PRE_1 ------------------------
  // cur_state_raw_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_state_raw_r <= RAW_IDLE ;
    end
    else begin
      cur_state_raw_r <= nxt_state_raw_w ;
    end
  end

  // nxt_state_raw_w
  always @(*) begin
                                                           nxt_state_raw_w = RAW_IDLE    ;
    case( cur_state_raw_r )
      RAW_IDLE    : begin    if( start_i )                 nxt_state_raw_w = RAW_BUSY    ;
                             else                          nxt_state_raw_w = RAW_IDLE    ;
      end
      RAW_BUSY    : begin    if( start_i )                 nxt_state_raw_w = RAW_BUSY    ;
                             else if( done_raw_busy_w )    nxt_state_raw_w = RAW_IDLE    ;
                             else                          nxt_state_raw_w = RAW_BUSY    ;
      end
    endcase
  end

  // jump condition
  assign done_raw_busy_w = cnt_raw_done_w ;

  // cnt_raw_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_raw_r <= 0 ;
    end
    else begin
      if( start_i || (cur_state_raw_r==RAW_BUSY) ) begin
        if( cnt_raw_done_w ) begin
          cnt_raw_r <= 0 ;
        end
        else begin
          cnt_raw_r <= cnt_raw_r + 1 ;
        end
      end
      else begin
        cnt_raw_r <= 0 ;
      end
    end
  end

  // cnt_raw_done_w
  always @(*) begin
    case( size_i )
      `SIZE_04 :    cnt_raw_done_w = cnt_raw_r == (1+1*2-1) ;
      `SIZE_08 :    cnt_raw_done_w = cnt_raw_r == (1+2*2-1) ;
      `SIZE_16 :    cnt_raw_done_w = cnt_raw_r == (1+4*2-1) ;
      `SIZE_32 :    cnt_raw_done_w = cnt_raw_r == (1+8*2-1) ;
    endcase
  end

  // dly_0
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      size_d0_r         <= 0 ;
      position_d0_r     <= 0 ;
      idx_4x4_x_d0_r    <= 0 ;
      idx_4x4_y_d0_r    <= 0 ;
      cnt_raw_d0_r      <= 0 ;
      cnt_raw_done_d0_r <= 0 ;
    end
    else begin
      size_d0_r         <= size_i         ;
      position_d0_r     <= position_i     ;
      idx_4x4_x_d0_r    <= idx_4x4_x_w    ;
      idx_4x4_y_d0_r    <= idx_4x4_y_w    ;
      cnt_raw_d0_r      <= cnt_raw_r      ;
      cnt_raw_done_d0_r <= cnt_raw_done_w ;
    end
  end
  // dly_1
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      size_d1_r         <= 0 ;
      position_d1_r     <= 0 ;
      idx_4x4_x_d1_r    <= 0 ;
      idx_4x4_y_d1_r    <= 0 ;
      cnt_raw_d1_r      <= 0 ;
      cnt_raw_done_d1_r <= 0 ;
    end
    else begin
      size_d1_r         <= size_d0_r         ;
      position_d1_r     <= position_d0_r     ;
      idx_4x4_x_d1_r    <= idx_4x4_x_d0_r    ;
      idx_4x4_y_d1_r    <= idx_4x4_y_d0_r    ;
      cnt_raw_d1_r      <= cnt_raw_d0_r      ;
      cnt_raw_done_d1_r <= cnt_raw_done_d0_r ;
    end
  end
  // dly_2
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      size_d2_r         <= 0 ;
      position_d2_r     <= 0 ;
      idx_4x4_x_d2_r    <= 0 ;
      idx_4x4_y_d2_r    <= 0 ;
      cnt_raw_d2_r      <= 0 ;
      cnt_raw_done_d2_r <= 0 ;
    end
    else begin
      size_d2_r         <= size_d1_r         ;
      position_d2_r     <= position_d1_r     ;
      idx_4x4_x_d2_r    <= idx_4x4_x_d1_r    ;
      idx_4x4_y_d2_r    <= idx_4x4_y_d1_r    ;
      cnt_raw_d2_r      <= cnt_raw_d1_r      ;
      cnt_raw_done_d2_r <= cnt_raw_done_d1_r ;
    end
  end
  // dly_3
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      size_d3_r         <= 0 ;
      position_d3_r     <= 0 ;
      idx_4x4_x_d3_r    <= 0 ;
      idx_4x4_y_d3_r    <= 0 ;
      cnt_raw_d3_r      <= 0 ;
      cnt_raw_done_d3_r <= 0 ;
    end
    else begin
      size_d3_r         <= size_d2_r         ;
      position_d3_r     <= position_d2_r     ;
      idx_4x4_x_d3_r    <= idx_4x4_x_d2_r    ;
      idx_4x4_y_d3_r    <= idx_4x4_y_d2_r    ;
      cnt_raw_d3_r      <= cnt_raw_d2_r      ;
      cnt_raw_done_d3_r <= cnt_raw_done_d2_r ;
    end
  end

  // fra_rd_ena/adr_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      fra_rd_ena_o <= 0 ;
      fra_rd_adr_o <= 0 ;
    end
    else begin
      if( start_i || (cur_state_raw_r==RAW_BUSY) ) begin
        if( idx_4x4_y_w==0 ) begin
          fra_rd_ena_o <= 1 ;
          if( cnt_raw_r==0 ) begin
            fra_rd_adr_o <= (ctu_x_cur_i<<IDX_4x4_SHF)+idx_4x4_x_w-1 ;
          end
          else begin
            fra_rd_adr_o <= fra_rd_adr_o + 1 ;
          end
        end
        else begin
          fra_rd_ena_o <= 0 ;
          fra_rd_adr_o <= 0 ;
        end
      end
      else begin
        fra_rd_ena_o <= 0 ;
        fra_rd_adr_o <= 0 ;
      end
    end
  end

  // row_rd_ena/adr_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      row_rd_ena_o <= 0 ;
      row_rd_adr_o <= 0 ;
    end
    else begin
      if( start_i || (cur_state_raw_r==RAW_BUSY) ) begin
        if( idx_4x4_y_w!=0 ) begin
          row_rd_ena_o <= 1 ;
          if( cnt_raw_r==0 ) begin
            if( idx_4x4_x_w==0 ) begin
              row_rd_adr_o <= ((idx_4x4_y_w-1)<<IDX_4x4_SHF)+IDX_4x4_DAT-1 ;
            end
            else begin
              row_rd_adr_o <= ((idx_4x4_y_w-1)<<IDX_4x4_SHF)+idx_4x4_x_w-1 ;
            end
          end
          else if( cnt_raw_r==1 ) begin
            row_rd_adr_o <= ((idx_4x4_y_w-1)<<IDX_4x4_SHF)+idx_4x4_x_w ;
          end
          else begin
            row_rd_adr_o <= row_rd_adr_o + 1 ;
          end
        end
        else begin
          row_rd_ena_o <= 0 ;
          row_rd_adr_o <= 0 ;
        end
      end
      else begin
        row_rd_ena_o <= 0 ;
        row_rd_adr_o <= 0 ;
      end
    end
  end

  // col_rd_ena/adr_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      col_rd_ena_o <= 0 ;
      col_rd_adr_o <= 0 ;
    end
    else begin
      if( start_i || (cur_state_raw_r==RAW_BUSY) ) begin
        if( cnt_raw_r==0 ) begin
          if( idx_4x4_y_w!=0 ) begin
            col_rd_ena_o <= 1 ;
            if( idx_4x4_x_w==0 ) begin
              col_rd_adr_o <= ((IDX_4x4_DAT-1)<<IDX_4x4_SHF)+idx_4x4_y_w-1 ;
            end
            else begin
              col_rd_adr_o <= ((idx_4x4_x_w-1)<<IDX_4x4_SHF)+idx_4x4_y_w-1 ;
            end
          end
          else begin
            col_rd_ena_o <= 0 ;
            col_rd_adr_o <= 0 ;
          end
        end
        else if( cnt_raw_r==1 )begin
          col_rd_ena_o <= 1 ;
          if( idx_4x4_x_w==0 ) begin
            col_rd_adr_o <= ((IDX_4x4_DAT-1)<<IDX_4x4_SHF)+idx_4x4_y_w ;
          end
          else begin
            col_rd_adr_o <= ((idx_4x4_x_w-1)<<IDX_4x4_SHF)+idx_4x4_y_w ;
          end
        end
        else begin
          col_rd_ena_o <= 1 ;
          col_rd_adr_o <= col_rd_adr_o + 1 ;
        end
      end
      else begin
        col_rd_ena_o <= 0 ;
        col_rd_adr_o <= 0 ;
      end
    end
  end


//--- RAW_PRE_0 ------------------------
  // fra/row/col_rd_dat_i


//--- RAW ------------------------------
  // raw_valid_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      raw_valid_r <= 0 ;
    end
    else begin
      raw_valid_r <= fra_rd_ena_o || row_rd_ena_o ;
    end
  end

  // ref_raw_tl_prev_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_raw_tl_prev_r <= 0 ;
    end
    else begin
      if( (size_d1_r==`SIZE_04) && (idx_4x4_x_d1_r==15) && (idx_4x4_y_d1_r==0) && (cnt_raw_d1_r==1) ) begin
        ref_raw_tl_prev_r <= fra_rd_dat_0_w ;
      end
    end
  end

  // top-left
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_raw_tl_r <= 0 ;
    end
    else begin
      if( raw_valid_r ) begin
        if( cnt_raw_d1_r==0 ) begin
          if( idx_4x4_y_d1_r==0 ) begin
            if( idx_4x4_x_d1_r==0 ) begin
              ref_raw_tl_r <= ref_raw_tl_prev_r ;
            end
            else begin
              ref_raw_tl_r <= fra_rd_dat_0_w ;
            end
          end
          else begin
            ref_raw_tl_r <= col_rd_dat_0_w ;
          end
        end
      end
    end
  end

  // top
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_raw_t00_r <= 0 ; ref_raw_t01_r <= 0 ; ref_raw_t02_r <= 0 ; ref_raw_t03_r <= 0 ;
      ref_raw_t04_r <= 0 ; ref_raw_t05_r <= 0 ; ref_raw_t06_r <= 0 ; ref_raw_t07_r <= 0 ;
      ref_raw_t08_r <= 0 ; ref_raw_t09_r <= 0 ; ref_raw_t10_r <= 0 ; ref_raw_t11_r <= 0 ;
      ref_raw_t12_r <= 0 ; ref_raw_t13_r <= 0 ; ref_raw_t14_r <= 0 ; ref_raw_t15_r <= 0 ;
      ref_raw_t16_r <= 0 ; ref_raw_t17_r <= 0 ; ref_raw_t18_r <= 0 ; ref_raw_t19_r <= 0 ;
      ref_raw_t20_r <= 0 ; ref_raw_t21_r <= 0 ; ref_raw_t22_r <= 0 ; ref_raw_t23_r <= 0 ;
      ref_raw_t24_r <= 0 ; ref_raw_t25_r <= 0 ; ref_raw_t26_r <= 0 ; ref_raw_t27_r <= 0 ;
      ref_raw_t28_r <= 0 ; ref_raw_t29_r <= 0 ; ref_raw_t30_r <= 0 ; ref_raw_t31_r <= 0 ;
    end
    else begin
      if( raw_valid_r ) begin
        case( cnt_raw_d1_r )
          1 : begin     if( idx_4x4_y_d1_r==0 ) begin
                          ref_raw_t00_r <= fra_rd_dat_3_w ; ref_raw_t01_r <= fra_rd_dat_2_w ;
                          ref_raw_t02_r <= fra_rd_dat_1_w ; ref_raw_t03_r <= fra_rd_dat_0_w ;
                        end
                        else begin
                          ref_raw_t00_r <= row_rd_dat_3_w ; ref_raw_t01_r <= row_rd_dat_2_w ;
                          ref_raw_t02_r <= row_rd_dat_1_w ; ref_raw_t03_r <= row_rd_dat_0_w ;
                        end
          end
          2 : begin     if( (size_d1_r==`SIZE_08)||(size_d1_r==`SIZE_16)||(size_d1_r==`SIZE_32) ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_t04_r <= fra_rd_dat_3_w ; ref_raw_t05_r <= fra_rd_dat_2_w ;
                            ref_raw_t06_r <= fra_rd_dat_1_w ; ref_raw_t07_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_t04_r <= row_rd_dat_3_w ; ref_raw_t05_r <= row_rd_dat_2_w ;
                            ref_raw_t06_r <= row_rd_dat_1_w ; ref_raw_t07_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          3 : begin     if( (size_d1_r==`SIZE_16)||(size_d1_r==`SIZE_32) ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_t08_r <= fra_rd_dat_3_w ; ref_raw_t09_r <= fra_rd_dat_2_w ;
                            ref_raw_t10_r <= fra_rd_dat_1_w ; ref_raw_t11_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_t08_r <= row_rd_dat_3_w ; ref_raw_t09_r <= row_rd_dat_2_w ;
                            ref_raw_t10_r <= row_rd_dat_1_w ; ref_raw_t11_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          4 : begin     if( (size_d1_r==`SIZE_16)||(size_d1_r==`SIZE_32) ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_t12_r <= fra_rd_dat_3_w ; ref_raw_t13_r <= fra_rd_dat_2_w ;
                            ref_raw_t14_r <= fra_rd_dat_1_w ; ref_raw_t15_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_t12_r <= row_rd_dat_3_w ; ref_raw_t13_r <= row_rd_dat_2_w ;
                            ref_raw_t14_r <= row_rd_dat_1_w ; ref_raw_t15_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          5 : begin     if( (size_d1_r==`SIZE_32) ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_t16_r <= fra_rd_dat_3_w ; ref_raw_t17_r <= fra_rd_dat_2_w ;
                            ref_raw_t18_r <= fra_rd_dat_1_w ; ref_raw_t19_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_t16_r <= row_rd_dat_3_w ; ref_raw_t17_r <= row_rd_dat_2_w ;
                            ref_raw_t18_r <= row_rd_dat_1_w ; ref_raw_t19_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          6 : begin     if( size_d1_r==`SIZE_32 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_t20_r <= fra_rd_dat_3_w ; ref_raw_t21_r <= fra_rd_dat_2_w ;
                            ref_raw_t22_r <= fra_rd_dat_1_w ; ref_raw_t23_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_t20_r <= row_rd_dat_3_w ; ref_raw_t21_r <= row_rd_dat_2_w ;
                            ref_raw_t22_r <= row_rd_dat_1_w ; ref_raw_t23_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          7 : begin     if( size_d1_r==`SIZE_32 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_t24_r <= fra_rd_dat_3_w ; ref_raw_t25_r <= fra_rd_dat_2_w ;
                            ref_raw_t26_r <= fra_rd_dat_1_w ; ref_raw_t27_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_t24_r <= row_rd_dat_3_w ; ref_raw_t25_r <= row_rd_dat_2_w ;
                            ref_raw_t26_r <= row_rd_dat_1_w ; ref_raw_t27_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          8 : begin     if( size_d1_r==`SIZE_32 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_t28_r <= fra_rd_dat_3_w ; ref_raw_t29_r <= fra_rd_dat_2_w ;
                            ref_raw_t30_r <= fra_rd_dat_1_w ; ref_raw_t31_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_t28_r <= row_rd_dat_3_w ; ref_raw_t29_r <= row_rd_dat_2_w ;
                            ref_raw_t30_r <= row_rd_dat_1_w ; ref_raw_t31_r <= row_rd_dat_0_w ;
                          end
                        end
          end
        endcase
      end
    end
  end

  // right
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_raw_r00_r <= 0 ; ref_raw_r01_r <= 0 ; ref_raw_r02_r <= 0 ; ref_raw_r03_r <= 0 ;
      ref_raw_r04_r <= 0 ; ref_raw_r05_r <= 0 ; ref_raw_r06_r <= 0 ; ref_raw_r07_r <= 0 ;
      ref_raw_r08_r <= 0 ; ref_raw_r09_r <= 0 ; ref_raw_r10_r <= 0 ; ref_raw_r11_r <= 0 ;
      ref_raw_r12_r <= 0 ; ref_raw_r13_r <= 0 ; ref_raw_r14_r <= 0 ; ref_raw_r15_r <= 0 ;
      ref_raw_r16_r <= 0 ; ref_raw_r17_r <= 0 ; ref_raw_r18_r <= 0 ; ref_raw_r19_r <= 0 ;
      ref_raw_r20_r <= 0 ; ref_raw_r21_r <= 0 ; ref_raw_r22_r <= 0 ; ref_raw_r23_r <= 0 ;
      ref_raw_r24_r <= 0 ; ref_raw_r25_r <= 0 ; ref_raw_r26_r <= 0 ; ref_raw_r27_r <= 0 ;
      ref_raw_r28_r <= 0 ; ref_raw_r29_r <= 0 ; ref_raw_r30_r <= 0 ; ref_raw_r31_r <= 0 ;
    end
    else begin
      if( raw_valid_r ) begin
        case( cnt_raw_d1_r )
          2  : begin    if( size_d1_r==`SIZE_04 ) begin
                        if( idx_4x4_y_d1_r==0 ) begin
                          ref_raw_r00_r <= fra_rd_dat_3_w ; ref_raw_r01_r<=fra_rd_dat_2_w ;
                          ref_raw_r02_r <= fra_rd_dat_1_w ; ref_raw_r03_r<=fra_rd_dat_0_w ;
                        end
                        else begin
                          ref_raw_r00_r <= row_rd_dat_3_w ; ref_raw_r01_r<=row_rd_dat_2_w ;
                          ref_raw_r02_r <= row_rd_dat_1_w ; ref_raw_r03_r<=row_rd_dat_0_w ;
                        end
                      end
          end
          3  : begin    if( size_d1_r==`SIZE_08 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r00_r <= fra_rd_dat_3_w ; ref_raw_r01_r <= fra_rd_dat_2_w ;
                            ref_raw_r02_r <= fra_rd_dat_1_w ; ref_raw_r03_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r00_r <= row_rd_dat_3_w ; ref_raw_r01_r <= row_rd_dat_2_w ;
                            ref_raw_r02_r <= row_rd_dat_1_w ; ref_raw_r03_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          4  : begin    if( size_d1_r==`SIZE_08 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r04_r <= fra_rd_dat_3_w ; ref_raw_r05_r <= fra_rd_dat_2_w ;
                            ref_raw_r06_r <= fra_rd_dat_1_w ; ref_raw_r07_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r04_r <= row_rd_dat_3_w ; ref_raw_r05_r <= row_rd_dat_2_w ;
                            ref_raw_r06_r <= row_rd_dat_1_w ; ref_raw_r07_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          5  : begin    if( size_d1_r==`SIZE_16 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r00_r <= fra_rd_dat_3_w ; ref_raw_r01_r <= fra_rd_dat_2_w ;
                            ref_raw_r02_r <= fra_rd_dat_1_w ; ref_raw_r03_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r00_r <= row_rd_dat_3_w ; ref_raw_r01_r <= row_rd_dat_2_w ;
                            ref_raw_r02_r <= row_rd_dat_1_w ; ref_raw_r03_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          6  : begin    if( size_d1_r==`SIZE_16 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r04_r <= fra_rd_dat_3_w ; ref_raw_r05_r <= fra_rd_dat_2_w ;
                            ref_raw_r06_r <= fra_rd_dat_1_w ; ref_raw_r07_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r04_r <= row_rd_dat_3_w ; ref_raw_r05_r <= row_rd_dat_2_w ;
                            ref_raw_r06_r <= row_rd_dat_1_w ; ref_raw_r07_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          7  : begin    if( size_d1_r==`SIZE_16 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r08_r <= fra_rd_dat_3_w ; ref_raw_r09_r <= fra_rd_dat_2_w ;
                            ref_raw_r10_r <= fra_rd_dat_1_w ; ref_raw_r11_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r08_r <= row_rd_dat_3_w ; ref_raw_r09_r <= row_rd_dat_2_w ;
                            ref_raw_r10_r <= row_rd_dat_1_w ; ref_raw_r11_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          8  : begin    if( size_d1_r==`SIZE_16 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r12_r <= fra_rd_dat_3_w ; ref_raw_r13_r <= fra_rd_dat_2_w ;
                            ref_raw_r14_r <= fra_rd_dat_1_w ; ref_raw_r15_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r12_r <= row_rd_dat_3_w ; ref_raw_r13_r <= row_rd_dat_2_w ;
                            ref_raw_r14_r <= row_rd_dat_1_w ; ref_raw_r15_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          9  : begin    if( size_d1_r==`SIZE_32 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r00_r <= fra_rd_dat_3_w ; ref_raw_r01_r <= fra_rd_dat_2_w ;
                            ref_raw_r02_r <= fra_rd_dat_1_w ; ref_raw_r03_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r00_r <= row_rd_dat_3_w ; ref_raw_r01_r <= row_rd_dat_2_w ;
                            ref_raw_r02_r <= row_rd_dat_1_w ; ref_raw_r03_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          10 : begin    if( size_d1_r==`SIZE_32 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r04_r <= fra_rd_dat_3_w ; ref_raw_r05_r <= fra_rd_dat_2_w ;
                            ref_raw_r06_r <= fra_rd_dat_1_w ; ref_raw_r07_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r04_r <= row_rd_dat_3_w ; ref_raw_r05_r <= row_rd_dat_2_w ;
                            ref_raw_r06_r <= row_rd_dat_1_w ; ref_raw_r07_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          11 : begin    if( size_d1_r==`SIZE_32 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r08_r <= fra_rd_dat_3_w ; ref_raw_r09_r <= fra_rd_dat_2_w ;
                            ref_raw_r10_r <= fra_rd_dat_1_w ; ref_raw_r11_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r08_r <= row_rd_dat_3_w ; ref_raw_r09_r <= row_rd_dat_2_w ;
                            ref_raw_r10_r <= row_rd_dat_1_w ; ref_raw_r11_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          12 : begin    if( size_d1_r==`SIZE_32 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r12_r <= fra_rd_dat_3_w ; ref_raw_r13_r <= fra_rd_dat_2_w ;
                            ref_raw_r14_r <= fra_rd_dat_1_w ; ref_raw_r15_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r12_r <= row_rd_dat_3_w ; ref_raw_r13_r <= row_rd_dat_2_w ;
                            ref_raw_r14_r <= row_rd_dat_1_w ; ref_raw_r15_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          13 : begin    if( size_d1_r==`SIZE_32 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r16_r <= fra_rd_dat_3_w ; ref_raw_r17_r <= fra_rd_dat_2_w ;
                            ref_raw_r18_r <= fra_rd_dat_1_w ; ref_raw_r19_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r16_r <= row_rd_dat_3_w ; ref_raw_r17_r <= row_rd_dat_2_w ;
                            ref_raw_r18_r <= row_rd_dat_1_w ; ref_raw_r19_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          14 : begin    if( size_d1_r==`SIZE_32 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r20_r <= fra_rd_dat_3_w ; ref_raw_r21_r <= fra_rd_dat_2_w ;
                            ref_raw_r22_r <= fra_rd_dat_1_w ; ref_raw_r23_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r20_r <= row_rd_dat_3_w ; ref_raw_r21_r <= row_rd_dat_2_w ;
                            ref_raw_r22_r <= row_rd_dat_1_w ; ref_raw_r23_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          15 : begin    if( size_d1_r==`SIZE_32 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r24_r <= fra_rd_dat_3_w ; ref_raw_r25_r <= fra_rd_dat_2_w ;
                            ref_raw_r26_r <= fra_rd_dat_1_w ; ref_raw_r27_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r24_r <= row_rd_dat_3_w ; ref_raw_r25_r <= row_rd_dat_2_w ;
                            ref_raw_r26_r <= row_rd_dat_1_w ; ref_raw_r27_r <= row_rd_dat_0_w ;
                          end
                        end
          end
          16 : begin    if( size_d1_r==`SIZE_32 ) begin
                          if( idx_4x4_y_d1_r==0 ) begin
                            ref_raw_r28_r <= fra_rd_dat_3_w ; ref_raw_r29_r <= fra_rd_dat_2_w ;
                            ref_raw_r30_r <= fra_rd_dat_1_w ; ref_raw_r31_r <= fra_rd_dat_0_w ;
                          end
                          else begin
                            ref_raw_r28_r <= row_rd_dat_3_w ; ref_raw_r29_r <= row_rd_dat_2_w ;
                            ref_raw_r30_r <= row_rd_dat_1_w ; ref_raw_r31_r <= row_rd_dat_0_w ;
                          end
                        end
          end
        endcase
      end
    end
  end

  // left
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_raw_l00_r <= 0 ; ref_raw_l01_r <= 0 ; ref_raw_l02_r <= 0 ; ref_raw_l03_r <= 0 ;
      ref_raw_l04_r <= 0 ; ref_raw_l05_r <= 0 ; ref_raw_l06_r <= 0 ; ref_raw_l07_r <= 0 ;
      ref_raw_l08_r <= 0 ; ref_raw_l09_r <= 0 ; ref_raw_l10_r <= 0 ; ref_raw_l11_r <= 0 ;
      ref_raw_l12_r <= 0 ; ref_raw_l13_r <= 0 ; ref_raw_l14_r <= 0 ; ref_raw_l15_r <= 0 ;
      ref_raw_l16_r <= 0 ; ref_raw_l17_r <= 0 ; ref_raw_l18_r <= 0 ; ref_raw_l19_r <= 0 ;
      ref_raw_l20_r <= 0 ; ref_raw_l21_r <= 0 ; ref_raw_l22_r <= 0 ; ref_raw_l23_r <= 0 ;
      ref_raw_l24_r <= 0 ; ref_raw_l25_r <= 0 ; ref_raw_l26_r <= 0 ; ref_raw_l27_r <= 0 ;
      ref_raw_l28_r <= 0 ; ref_raw_l29_r <= 0 ; ref_raw_l30_r <= 0 ; ref_raw_l31_r <= 0 ;
    end
    else begin
      if( raw_valid_r ) begin
        case( cnt_raw_d1_r )
          1  : begin    ref_raw_l00_r <= col_rd_dat_3_w ; ref_raw_l01_r <= col_rd_dat_2_w ;
                        ref_raw_l02_r <= col_rd_dat_1_w ; ref_raw_l03_r <= col_rd_dat_0_w ;
          end
          2  : begin    if( (size_d1_r==`SIZE_08)||(size_d1_r==`SIZE_16)||(size_d1_r==`SIZE_32) ) begin
                          ref_raw_l04_r <= col_rd_dat_3_w ; ref_raw_l05_r <= col_rd_dat_2_w ;
                          ref_raw_l06_r <= col_rd_dat_1_w ; ref_raw_l07_r <= col_rd_dat_0_w ;
                        end
          end
          3  : begin    if( (size_d1_r==`SIZE_16)||(size_d1_r==`SIZE_32) ) begin
                          ref_raw_l08_r <= col_rd_dat_3_w ; ref_raw_l09_r <= col_rd_dat_2_w ;
                          ref_raw_l10_r <= col_rd_dat_1_w ; ref_raw_l11_r <= col_rd_dat_0_w ;
                        end
          end
          4  : begin    if( (size_d1_r==`SIZE_16) || (size_d1_r==`SIZE_32) ) begin
                          ref_raw_l12_r <= col_rd_dat_3_w ; ref_raw_l13_r <= col_rd_dat_2_w ;
                          ref_raw_l14_r <= col_rd_dat_1_w ; ref_raw_l15_r <= col_rd_dat_0_w ;
                        end
          end
          5  : begin    if( size_d1_r==`SIZE_32 ) begin
                          ref_raw_l16_r <= col_rd_dat_3_w ; ref_raw_l17_r <= col_rd_dat_2_w ;
                          ref_raw_l18_r <= col_rd_dat_1_w ; ref_raw_l19_r <= col_rd_dat_0_w ;
                        end
          end
          6  : begin    if( size_d1_r==`SIZE_32 ) begin
                          ref_raw_l20_r <= col_rd_dat_3_w ; ref_raw_l21_r <= col_rd_dat_2_w ;
                          ref_raw_l22_r <= col_rd_dat_1_w ; ref_raw_l23_r <= col_rd_dat_0_w ;
                        end
          end
          7  : begin    if( size_d1_r==`SIZE_32 ) begin
                          ref_raw_l24_r <= col_rd_dat_3_w ; ref_raw_l25_r <= col_rd_dat_2_w ;
                          ref_raw_l26_r <= col_rd_dat_1_w ; ref_raw_l27_r <= col_rd_dat_0_w ;
                        end
          end
          8  : begin    if( size_d1_r==`SIZE_32 ) begin
                          ref_raw_l28_r <= col_rd_dat_3_w ; ref_raw_l29_r <= col_rd_dat_2_w ;
                          ref_raw_l30_r <= col_rd_dat_1_w ; ref_raw_l31_r <= col_rd_dat_0_w ;
                        end
          end
        endcase
      end
    end
  end

  // down
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_raw_d00_r <= 0 ; ref_raw_d01_r <= 0 ; ref_raw_d02_r <= 0 ; ref_raw_d03_r <= 0 ;
      ref_raw_d04_r <= 0 ; ref_raw_d05_r <= 0 ; ref_raw_d06_r <= 0 ; ref_raw_d07_r <= 0 ;
      ref_raw_d08_r <= 0 ; ref_raw_d09_r <= 0 ; ref_raw_d10_r <= 0 ; ref_raw_d11_r <= 0 ;
      ref_raw_d12_r <= 0 ; ref_raw_d13_r <= 0 ; ref_raw_d14_r <= 0 ; ref_raw_d15_r <= 0 ;
      ref_raw_d16_r <= 0 ; ref_raw_d17_r <= 0 ; ref_raw_d18_r <= 0 ; ref_raw_d19_r <= 0 ;
      ref_raw_d20_r <= 0 ; ref_raw_d21_r <= 0 ; ref_raw_d22_r <= 0 ; ref_raw_d23_r <= 0 ;
      ref_raw_d24_r <= 0 ; ref_raw_d25_r <= 0 ; ref_raw_d26_r <= 0 ; ref_raw_d27_r <= 0 ;
      ref_raw_d28_r <= 0 ; ref_raw_d29_r <= 0 ; ref_raw_d30_r <= 0 ; ref_raw_d31_r <= 0 ;
    end
    else begin
      if( raw_valid_r ) begin
        case( cnt_raw_d1_r )
          2  : begin    if( size_d1_r==`SIZE_04 ) begin
                          ref_raw_d00_r <= col_rd_dat_3_w ; ref_raw_d01_r <= col_rd_dat_2_w ;
                          ref_raw_d02_r <= col_rd_dat_1_w ; ref_raw_d03_r <= col_rd_dat_0_w ;
                        end
          end
          3  : begin    if( size_d1_r==`SIZE_08 ) begin
                          ref_raw_d00_r <= col_rd_dat_3_w ; ref_raw_d01_r <= col_rd_dat_2_w ;
                          ref_raw_d02_r <= col_rd_dat_1_w ; ref_raw_d03_r <= col_rd_dat_0_w ;
                        end
          end
          4  : begin    if( size_d1_r==`SIZE_08 ) begin
                          ref_raw_d04_r <= col_rd_dat_3_w ; ref_raw_d05_r <= col_rd_dat_2_w ;
                          ref_raw_d06_r <= col_rd_dat_1_w ; ref_raw_d07_r <= col_rd_dat_0_w ;
                        end
          end
          5  : begin    if( size_d1_r==`SIZE_16 ) begin
                          ref_raw_d00_r <= col_rd_dat_3_w ; ref_raw_d01_r <= col_rd_dat_2_w ;
                          ref_raw_d02_r <= col_rd_dat_1_w ; ref_raw_d03_r <= col_rd_dat_0_w ;
                        end
          end
          6  : begin    if( size_d1_r==`SIZE_16 ) begin
                          ref_raw_d04_r <= col_rd_dat_3_w ; ref_raw_d05_r <= col_rd_dat_2_w ;
                          ref_raw_d06_r <= col_rd_dat_1_w ; ref_raw_d07_r <= col_rd_dat_0_w ;
                        end
          end
          7  : begin    if( size_d1_r==`SIZE_16 ) begin
                          ref_raw_d08_r <= col_rd_dat_3_w ; ref_raw_d09_r <= col_rd_dat_2_w ;
                          ref_raw_d10_r <= col_rd_dat_1_w ; ref_raw_d11_r <= col_rd_dat_0_w ;
                        end
          end
          8  : begin    if( size_d1_r==`SIZE_16 ) begin
                          ref_raw_d12_r <= col_rd_dat_3_w ; ref_raw_d13_r <= col_rd_dat_2_w ;
                          ref_raw_d14_r <= col_rd_dat_1_w ; ref_raw_d15_r <= col_rd_dat_0_w ;
                        end
          end
          9  : begin    if( size_d1_r==`SIZE_32 ) begin
                          ref_raw_d00_r <= col_rd_dat_3_w ; ref_raw_d01_r <= col_rd_dat_2_w ;
                          ref_raw_d02_r <= col_rd_dat_1_w ; ref_raw_d03_r <= col_rd_dat_0_w ;
                        end
          end
          10 : begin    if( size_d1_r==`SIZE_32 ) begin
                          ref_raw_d04_r <= col_rd_dat_3_w ; ref_raw_d05_r <= col_rd_dat_2_w ;
                          ref_raw_d06_r <= col_rd_dat_1_w ; ref_raw_d07_r <= col_rd_dat_0_w ;
                        end
          end
          11 : begin    if( size_d1_r==`SIZE_32 ) begin
                          ref_raw_d08_r <= col_rd_dat_3_w ; ref_raw_d09_r <= col_rd_dat_2_w ;
                          ref_raw_d10_r <= col_rd_dat_1_w ; ref_raw_d11_r <= col_rd_dat_0_w ;
                        end
          end
          12 : begin    if( size_d1_r==`SIZE_32 ) begin
                          ref_raw_d12_r <= col_rd_dat_3_w ; ref_raw_d13_r <= col_rd_dat_2_w ;
                          ref_raw_d14_r <= col_rd_dat_1_w ; ref_raw_d15_r <= col_rd_dat_0_w ;
                        end
          end
          13 : begin    if( size_d1_r==`SIZE_32 ) begin
                          ref_raw_d16_r <= col_rd_dat_3_w ; ref_raw_d17_r <= col_rd_dat_2_w ;
                          ref_raw_d18_r <= col_rd_dat_1_w ; ref_raw_d19_r <= col_rd_dat_0_w ;
                        end
          end
          14 : begin    if( size_d1_r==`SIZE_32 ) begin
                          ref_raw_d20_r <= col_rd_dat_3_w ; ref_raw_d21_r <= col_rd_dat_2_w ;
                          ref_raw_d22_r <= col_rd_dat_1_w ; ref_raw_d23_r <= col_rd_dat_0_w ;
                        end
          end
          15 : begin    if( size_d1_r==`SIZE_32 ) begin
                          ref_raw_d24_r <= col_rd_dat_3_w ; ref_raw_d25_r <= col_rd_dat_2_w ;
                          ref_raw_d26_r <= col_rd_dat_1_w ; ref_raw_d27_r <= col_rd_dat_0_w ;
                        end
          end
          16 : begin    if( size_d1_r==`SIZE_32 ) begin
                          ref_raw_d28_r <= col_rd_dat_3_w ; ref_raw_d29_r <= col_rd_dat_2_w ;
                          ref_raw_d30_r <= col_rd_dat_1_w ; ref_raw_d31_r <= col_rd_dat_0_w ;
                        end
          end
        endcase
      end
    end
  end


//--- PAD_PRE --------------------------
  assign start_pad_pre_w = cnt_raw_done_d1_r ;

  // flag for ctu
  always @(*) begin
    if( (ctu_x_cur_i==0) && (ctu_y_cur_i==0) ) begin
      ctu_tl_exist_w = 0 ;
      ctu_tp_exist_w = 0 ;
      ctu_lf_exist_w = 0 ;
    end
    else if( ctu_x_cur_i==0 ) begin
      ctu_tl_exist_w = 0 ;
      ctu_tp_exist_w = 1 ;
      ctu_lf_exist_w = 0 ;
    end
    else if( ctu_y_cur_i==0 ) begin
      ctu_tl_exist_w = 0 ;
      ctu_tp_exist_w = 0 ;
      ctu_lf_exist_w = 1 ;
    end
    else begin
      ctu_tl_exist_w = 1 ;
      ctu_tp_exist_w = 1 ;
      ctu_lf_exist_w = 1 ;
    end
  end

  always @(*) begin
    if( (ctu_x_cur_i==ctu_x_all_i) || (ctu_y_cur_i==0) ) begin
      ctu_rt_exist_w = 0 ;
    end
    else begin
      ctu_rt_exist_w = 1 ;
    end
  end

  // cu order
  always @(*) begin
    case( size_d1_r )
      `SIZE_04 : cu_order_w =  position_d1_r     ;
      `SIZE_08 : cu_order_w = (position_d1_r>>2) ;
      `SIZE_16 : cu_order_w = (position_d1_r>>4) ;
      `SIZE_32 : cu_order_w = (position_d1_r>>6) ;
    endcase
  end

  always @(*) begin
                 pu_delta_w = 0 ;
    case( size_d1_r )
      `SIZE_04 : pu_delta_w = 1 ;
      `SIZE_08 : pu_delta_w = 2 ;
      `SIZE_16 : pu_delta_w = 4 ;
      `SIZE_32 : pu_delta_w = 8 ;
    endcase
  end

  // pu position 
  assign pu_4x4_x_of_luma_w = {position_d1_r[6],position_d1_r[4],position_d1_r[2],position_d1_r[0]} ;
  assign pu_4x4_y_of_luma_w = {position_d1_r[7],position_d1_r[5],position_d1_r[3],position_d1_r[1]} ;

  assign pu_order_x_of_luma_w = { cu_order_w[6]
                                 ,cu_order_w[4]
                                 ,cu_order_w[2]
                                 ,cu_order_w[0] };
  assign pu_order_y_of_luma_w = { cu_order_w[7]
                                 ,cu_order_w[5]
                                 ,cu_order_w[3]
                                 ,cu_order_w[1] };

  assign pu_order_rt_x_of_luma_w = pu_order_x_of_luma_w +1 ;
  assign pu_order_rt_y_of_luma_w = pu_order_y_of_luma_w -1 ;
  assign pu_order_dn_x_of_luma_w = pu_order_x_of_luma_w -1 ;
  assign pu_order_dn_y_of_luma_w = pu_order_y_of_luma_w +1 ;


  assign pu_order_rt_of_luma_w = { pu_order_rt_y_of_luma_w[3] ,pu_order_rt_x_of_luma_w[3]
                                  ,pu_order_rt_y_of_luma_w[2] ,pu_order_rt_x_of_luma_w[2]
                                  ,pu_order_rt_y_of_luma_w[1] ,pu_order_rt_x_of_luma_w[1]
                                  ,pu_order_rt_y_of_luma_w[0] ,pu_order_rt_x_of_luma_w[0] };
  assign pu_order_dn_of_luma_w = { pu_order_dn_y_of_luma_w[3] ,pu_order_dn_x_of_luma_w[3]
                                  ,pu_order_dn_y_of_luma_w[2] ,pu_order_dn_x_of_luma_w[2]
                                  ,pu_order_dn_y_of_luma_w[1] ,pu_order_dn_x_of_luma_w[1]
                                  ,pu_order_dn_y_of_luma_w[0] ,pu_order_dn_x_of_luma_w[0] };

  // flag for cu 
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
/*
  // right 
  always @ ( posedge clk or negedge rstn ) begin 
    if ( !rstn ) 
      pu_rt_exist_r <= 0 ;
    else begin 
      if ( ( (ctu_y_cur_i==0 )          && (      pu_4x4_y_of_luma_w             ==      0             ) )
        || ( (ctu_x_cur_i==ctu_x_all_i) && ({1'b0,pu_4x4_x_of_luma_w}+pu_delta_w >       ctu_x_res_i   ) )
        || ( (ctu_y_cur_i==ctu_y_all_i) && (      pu_4x4_y_of_luma_w             > {1'b0,ctu_y_res_i}+1) )
          ) 
        pu_rt_exist_r <= 0 ; 
      else begin 
        if ( pu_4x4_y_of_luma_w == 0 ) begin 
          pu_rt_exist_r <= 1 ;
        end 
        else begin 
          if ( {1'b0,pu_4x4_x_of_luma_w}+pu_delta_w >15 ) begin 
            pu_rt_exist_r <= 0 ; 
          end 
          else if ( pu_order_rt_of_luma_w>cu_order_w ) begin 
            pu_rt_exist_r <= 0 ; 
          end 
          else begin 
            pu_rt_exist_r <= 1 ;
          end 
        end 

      end 
    end 
  end 
*/
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
              else if( pu_order_rt_of_luma_w>cu_order_w ) begin
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

/*
  // down 
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      pu_dn_exist_r <= 0 ;
    end
    else begin
      if( ( (ctu_x_cur_i==0 )          && (      pu_4x4_x_of_luma_w            ==      0             ) )
       || ( (ctu_x_cur_i==ctu_x_all_i) && (      pu_4x4_x_of_luma_w            > {1'b0,ctu_x_res_i}+1) )
       || ( (ctu_y_cur_i==ctu_y_all_i) && ({1'b0,pu_4x4_y_of_luma_w+pu_delta_w}>       ctu_y_res_i   ) )
      ) begin
        pu_dn_exist_r <= 0 ;
      end
      else begin
        if( pu_4x4_x_of_luma_w==0 ) begin
          if( {1'b0,pu_4x4_y_of_luma_w}+pu_delta_w>15 ) begin
            pu_dn_exist_r <= 0 ;
          end
          else begin
            pu_dn_exist_r <= 1 ;
          end
        end
        else begin
          if( {1'b0,pu_4x4_y_of_luma_w}+pu_delta_w>15 ) begin
            pu_dn_exist_r <= 0 ;
          end
          else if( pu_order_dn_of_luma_w>cu_order_w ) begin
            pu_dn_exist_r <= 0 ;
          end
          else begin
            pu_dn_exist_r <= 1 ;
          end 
        end
      end
    end
  end
*/
  // down
  genvar idx_dn ;

  generate
    for(idx_dn=0 ;idx_dn<8; idx_dn=idx_dn+1) begin: pu_dn_exist_loop
      always @(posedge clk or negedge rstn ) begin
        if( !rstn ) begin
          pu_dn_exist_r[idx_dn] <= 0 ;
        end
        else begin
          if( ( (ctu_x_cur_i==0 )          && (      pu_4x4_x_of_luma_w            ==      0             ) )
           || ( (ctu_x_cur_i==ctu_x_all_i) && (      pu_4x4_x_of_luma_w            > {1'b0,ctu_x_res_i}+1) )
           || ( (ctu_y_cur_i==ctu_y_all_i) && ({1'b0,pu_4x4_y_of_luma_w}+pu_delta_w+idx_dn> ctu_y_res_i   ) )
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
              else if( pu_order_dn_of_luma_w>cu_order_w ) begin
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


//--- PAD ------------------------------
  // start_pad_w
  assign start_pad_w = cnt_raw_done_d2_r ;

  // top-left
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_pad_tl_r <= DAT_DEF ;
    end
    else begin
      if( start_pad_w ) begin
                     ref_pad_tl_r <= DAT_DEF       ;
        casez( {pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0],pu_tp_exist_r,pu_rt_exist_r[0]} )
          5'b1???? : ref_pad_tl_r <= ref_raw_tl_r  ;
          5'b01??? : ref_pad_tl_r <= ref_raw_l00_r ;
          5'b001?? : ref_pad_tl_r <= ref_raw_d00_r ;
          5'b0001? : ref_pad_tl_r <= ref_raw_t00_r ;
          5'b00001 : ref_pad_tl_r <= ref_raw_r00_r ;
        endcase
      end
    end
  end

  // top
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_pad_t00_r <= DAT_DEF ; ref_pad_t01_r <= DAT_DEF ;
      ref_pad_t02_r <= DAT_DEF ; ref_pad_t03_r <= DAT_DEF ;
      ref_pad_t04_r <= DAT_DEF ; ref_pad_t05_r <= DAT_DEF ;
      ref_pad_t06_r <= DAT_DEF ; ref_pad_t07_r <= DAT_DEF ;
      ref_pad_t08_r <= DAT_DEF ; ref_pad_t09_r <= DAT_DEF ;
      ref_pad_t10_r <= DAT_DEF ; ref_pad_t11_r <= DAT_DEF ;
      ref_pad_t12_r <= DAT_DEF ; ref_pad_t13_r <= DAT_DEF ;
      ref_pad_t14_r <= DAT_DEF ; ref_pad_t15_r <= DAT_DEF ;
      ref_pad_t16_r <= DAT_DEF ; ref_pad_t17_r <= DAT_DEF ;
      ref_pad_t18_r <= DAT_DEF ; ref_pad_t19_r <= DAT_DEF ;
      ref_pad_t20_r <= DAT_DEF ; ref_pad_t21_r <= DAT_DEF ;
      ref_pad_t22_r <= DAT_DEF ; ref_pad_t23_r <= DAT_DEF ;
      ref_pad_t24_r <= DAT_DEF ; ref_pad_t25_r <= DAT_DEF ;
      ref_pad_t26_r <= DAT_DEF ; ref_pad_t27_r <= DAT_DEF ;
      ref_pad_t28_r <= DAT_DEF ; ref_pad_t29_r <= DAT_DEF ;
      ref_pad_t30_r <= DAT_DEF ; ref_pad_t31_r <= DAT_DEF ;
    end
    else begin
      if( start_pad_w ) begin
        ref_pad_t00_r <= DAT_DEF ; ref_pad_t01_r <= DAT_DEF ;
        ref_pad_t02_r <= DAT_DEF ; ref_pad_t03_r <= DAT_DEF ;
        ref_pad_t04_r <= DAT_DEF ; ref_pad_t05_r <= DAT_DEF ;
        ref_pad_t06_r <= DAT_DEF ; ref_pad_t07_r <= DAT_DEF ;
        ref_pad_t08_r <= DAT_DEF ; ref_pad_t09_r <= DAT_DEF ;
        ref_pad_t10_r <= DAT_DEF ; ref_pad_t11_r <= DAT_DEF ;
        ref_pad_t12_r <= DAT_DEF ; ref_pad_t13_r <= DAT_DEF ;
        ref_pad_t14_r <= DAT_DEF ; ref_pad_t15_r <= DAT_DEF ;
        ref_pad_t16_r <= DAT_DEF ; ref_pad_t17_r <= DAT_DEF ;
        ref_pad_t18_r <= DAT_DEF ; ref_pad_t19_r <= DAT_DEF ;
        ref_pad_t20_r <= DAT_DEF ; ref_pad_t21_r <= DAT_DEF ;
        ref_pad_t22_r <= DAT_DEF ; ref_pad_t23_r <= DAT_DEF ;
        ref_pad_t24_r <= DAT_DEF ; ref_pad_t25_r <= DAT_DEF ;
        ref_pad_t26_r <= DAT_DEF ; ref_pad_t27_r <= DAT_DEF ;
        ref_pad_t28_r <= DAT_DEF ; ref_pad_t29_r <= DAT_DEF ;
        ref_pad_t30_r <= DAT_DEF ; ref_pad_t31_r <= DAT_DEF ;
        case( size_d2_r )
          `SIZE_04 : begin    casez({pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0],pu_rt_exist_r[0]})
                                5'b1???? : begin    ref_pad_t00_r <= ref_raw_t00_r ; ref_pad_t01_r <= ref_raw_t01_r ;
                                                    ref_pad_t02_r <= ref_raw_t02_r ; ref_pad_t03_r <= ref_raw_t03_r ;
                                end
                                5'b01??? : begin    ref_pad_t00_r <= ref_raw_tl_r  ; ref_pad_t01_r <= ref_raw_tl_r  ;
                                                    ref_pad_t02_r <= ref_raw_tl_r  ; ref_pad_t03_r <= ref_raw_tl_r  ;
                                end
                                5'b001?? : begin    ref_pad_t00_r <= ref_raw_l00_r ; ref_pad_t01_r <= ref_raw_l00_r ;
                                                    ref_pad_t02_r <= ref_raw_l00_r ; ref_pad_t03_r <= ref_raw_l00_r ;
                                end
                                5'b0001? : begin    ref_pad_t00_r <= ref_raw_d00_r ; ref_pad_t01_r <= ref_raw_d00_r ;
                                                    ref_pad_t02_r <= ref_raw_d00_r ; ref_pad_t03_r <= ref_raw_d00_r ;
                                end
                                5'b00001 : begin    ref_pad_t00_r <= ref_raw_r00_r ; ref_pad_t01_r <= ref_raw_r00_r ;
                                                    ref_pad_t02_r <= ref_raw_r00_r ; ref_pad_t03_r <= ref_raw_r00_r ;
                                end
                                5'b00000 : begin    ref_pad_t00_r <= DAT_DEF       ; ref_pad_t01_r <= DAT_DEF       ;
                                                    ref_pad_t02_r <= DAT_DEF       ; ref_pad_t03_r <= DAT_DEF       ;
                                end
                              endcase
          end
          `SIZE_08 : begin    casez({pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0],pu_rt_exist_r[0]})
                                5'b1???? : begin    ref_pad_t00_r <= ref_raw_t00_r ; ref_pad_t01_r <= ref_raw_t01_r ;
                                                    ref_pad_t02_r <= ref_raw_t02_r ; ref_pad_t03_r <= ref_raw_t03_r ;
                                                    ref_pad_t04_r <= ref_raw_t04_r ; ref_pad_t05_r <= ref_raw_t05_r ;
                                                    ref_pad_t06_r <= ref_raw_t06_r ; ref_pad_t07_r <= ref_raw_t07_r ;
                                end
                                5'b01??? : begin    ref_pad_t00_r <= ref_raw_tl_r  ; ref_pad_t01_r <= ref_raw_tl_r  ;
                                                    ref_pad_t02_r <= ref_raw_tl_r  ; ref_pad_t03_r <= ref_raw_tl_r  ;
                                                    ref_pad_t04_r <= ref_raw_tl_r  ; ref_pad_t05_r <= ref_raw_tl_r  ;
                                                    ref_pad_t06_r <= ref_raw_tl_r  ; ref_pad_t07_r <= ref_raw_tl_r  ;
                                end
                                5'b001?? : begin    ref_pad_t00_r <= ref_raw_l00_r ; ref_pad_t01_r <= ref_raw_l00_r ;
                                                    ref_pad_t02_r <= ref_raw_l00_r ; ref_pad_t03_r <= ref_raw_l00_r ;
                                                    ref_pad_t04_r <= ref_raw_l00_r ; ref_pad_t05_r <= ref_raw_l00_r ;
                                                    ref_pad_t06_r <= ref_raw_l00_r ; ref_pad_t07_r <= ref_raw_l00_r ;
                                end
                                5'b0001? : begin    ref_pad_t00_r <= ref_raw_d00_r ; ref_pad_t01_r <= ref_raw_d00_r ;
                                                    ref_pad_t02_r <= ref_raw_d00_r ; ref_pad_t03_r <= ref_raw_d00_r ;
                                                    ref_pad_t04_r <= ref_raw_d00_r ; ref_pad_t05_r <= ref_raw_d00_r ;
                                                    ref_pad_t06_r <= ref_raw_d00_r ; ref_pad_t07_r <= ref_raw_d00_r ;
                                end
                                5'b00001 : begin    ref_pad_t00_r <= ref_raw_r00_r ; ref_pad_t01_r <= ref_raw_r00_r ;
                                                    ref_pad_t02_r <= ref_raw_r00_r ; ref_pad_t03_r <= ref_raw_r00_r ;
                                                    ref_pad_t04_r <= ref_raw_r00_r ; ref_pad_t05_r <= ref_raw_r00_r ;
                                                    ref_pad_t06_r <= ref_raw_r00_r ; ref_pad_t07_r <= ref_raw_r00_r ;
                                end
                              endcase
          end
          `SIZE_16 : begin    casez({pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0],pu_rt_exist_r[0]})
                                5'b1???? : begin    ref_pad_t00_r <= ref_raw_t00_r ; ref_pad_t01_r <= ref_raw_t01_r ;
                                                    ref_pad_t02_r <= ref_raw_t02_r ; ref_pad_t03_r <= ref_raw_t03_r ;
                                                    ref_pad_t04_r <= ref_raw_t04_r ; ref_pad_t05_r <= ref_raw_t05_r ;
                                                    ref_pad_t06_r <= ref_raw_t06_r ; ref_pad_t07_r <= ref_raw_t07_r ;
                                                    ref_pad_t08_r <= ref_raw_t08_r ; ref_pad_t09_r <= ref_raw_t09_r ;
                                                    ref_pad_t10_r <= ref_raw_t10_r ; ref_pad_t11_r <= ref_raw_t11_r ;
                                                    ref_pad_t12_r <= ref_raw_t12_r ; ref_pad_t13_r <= ref_raw_t13_r ;
                                                    ref_pad_t14_r <= ref_raw_t14_r ; ref_pad_t15_r <= ref_raw_t15_r ;
                                end
                                5'b01??? : begin    ref_pad_t00_r <= ref_raw_tl_r  ; ref_pad_t01_r <= ref_raw_tl_r  ;
                                                    ref_pad_t02_r <= ref_raw_tl_r  ; ref_pad_t03_r <= ref_raw_tl_r  ;
                                                    ref_pad_t04_r <= ref_raw_tl_r  ; ref_pad_t05_r <= ref_raw_tl_r  ;
                                                    ref_pad_t06_r <= ref_raw_tl_r  ; ref_pad_t07_r <= ref_raw_tl_r  ;
                                                    ref_pad_t08_r <= ref_raw_tl_r  ; ref_pad_t09_r <= ref_raw_tl_r  ;
                                                    ref_pad_t10_r <= ref_raw_tl_r  ; ref_pad_t11_r <= ref_raw_tl_r  ;
                                                    ref_pad_t12_r <= ref_raw_tl_r  ; ref_pad_t13_r <= ref_raw_tl_r  ;
                                                    ref_pad_t14_r <= ref_raw_tl_r  ; ref_pad_t15_r <= ref_raw_tl_r  ;
                                end
                                5'b001?? : begin    ref_pad_t00_r <= ref_raw_l00_r ; ref_pad_t01_r <= ref_raw_l00_r ;
                                                    ref_pad_t02_r <= ref_raw_l00_r ; ref_pad_t03_r <= ref_raw_l00_r ;
                                                    ref_pad_t04_r <= ref_raw_l00_r ; ref_pad_t05_r <= ref_raw_l00_r ;
                                                    ref_pad_t06_r <= ref_raw_l00_r ; ref_pad_t07_r <= ref_raw_l00_r ;
                                                    ref_pad_t08_r <= ref_raw_l00_r ; ref_pad_t09_r <= ref_raw_l00_r ;
                                                    ref_pad_t10_r <= ref_raw_l00_r ; ref_pad_t11_r <= ref_raw_l00_r ;
                                                    ref_pad_t12_r <= ref_raw_l00_r ; ref_pad_t13_r <= ref_raw_l00_r ;
                                                    ref_pad_t14_r <= ref_raw_l00_r ; ref_pad_t15_r <= ref_raw_l00_r ;
                                end
                                5'b0001? : begin    ref_pad_t00_r <= ref_raw_d00_r ; ref_pad_t01_r <= ref_raw_d00_r ;
                                                    ref_pad_t02_r <= ref_raw_d00_r ; ref_pad_t03_r <= ref_raw_d00_r ;
                                                    ref_pad_t04_r <= ref_raw_d00_r ; ref_pad_t05_r <= ref_raw_d00_r ;
                                                    ref_pad_t06_r <= ref_raw_d00_r ; ref_pad_t07_r <= ref_raw_d00_r ;
                                                    ref_pad_t08_r <= ref_raw_d00_r ; ref_pad_t09_r <= ref_raw_d00_r ;
                                                    ref_pad_t10_r <= ref_raw_d00_r ; ref_pad_t11_r <= ref_raw_d00_r ;
                                                    ref_pad_t12_r <= ref_raw_d00_r ; ref_pad_t13_r <= ref_raw_d00_r ;
                                                    ref_pad_t14_r <= ref_raw_d00_r ; ref_pad_t15_r <= ref_raw_d00_r ;
                                end
                                5'b00001 : begin    ref_pad_t00_r <= ref_raw_r00_r ; ref_pad_t01_r <= ref_raw_r00_r ;
                                                    ref_pad_t02_r <= ref_raw_r00_r ; ref_pad_t03_r <= ref_raw_r00_r ;
                                                    ref_pad_t04_r <= ref_raw_r00_r ; ref_pad_t05_r <= ref_raw_r00_r ;
                                                    ref_pad_t06_r <= ref_raw_r00_r ; ref_pad_t07_r <= ref_raw_r00_r ;
                                                    ref_pad_t08_r <= ref_raw_r00_r ; ref_pad_t09_r <= ref_raw_r00_r ;
                                                    ref_pad_t10_r <= ref_raw_r00_r ; ref_pad_t11_r <= ref_raw_r00_r ;
                                                    ref_pad_t12_r <= ref_raw_r00_r ; ref_pad_t13_r <= ref_raw_r00_r ;
                                                    ref_pad_t14_r <= ref_raw_r00_r ; ref_pad_t15_r <= ref_raw_r00_r ;
                                end
                              endcase
          end
          `SIZE_32 : begin    casez({pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0],pu_rt_exist_r[0]})
                                5'b1???? : begin    ref_pad_t00_r <= ref_raw_t00_r ; ref_pad_t01_r <= ref_raw_t01_r ;
                                                    ref_pad_t02_r <= ref_raw_t02_r ; ref_pad_t03_r <= ref_raw_t03_r ;
                                                    ref_pad_t04_r <= ref_raw_t04_r ; ref_pad_t05_r <= ref_raw_t05_r ;
                                                    ref_pad_t06_r <= ref_raw_t06_r ; ref_pad_t07_r <= ref_raw_t07_r ;
                                                    ref_pad_t08_r <= ref_raw_t08_r ; ref_pad_t09_r <= ref_raw_t09_r ;
                                                    ref_pad_t10_r <= ref_raw_t10_r ; ref_pad_t11_r <= ref_raw_t11_r ;
                                                    ref_pad_t12_r <= ref_raw_t12_r ; ref_pad_t13_r <= ref_raw_t13_r ;
                                                    ref_pad_t14_r <= ref_raw_t14_r ; ref_pad_t15_r <= ref_raw_t15_r ;
                                                    ref_pad_t16_r <= ref_raw_t16_r ; ref_pad_t17_r <= ref_raw_t17_r ;
                                                    ref_pad_t18_r <= ref_raw_t18_r ; ref_pad_t19_r <= ref_raw_t19_r ;
                                                    ref_pad_t20_r <= ref_raw_t20_r ; ref_pad_t21_r <= ref_raw_t21_r ;
                                                    ref_pad_t22_r <= ref_raw_t22_r ; ref_pad_t23_r <= ref_raw_t23_r ;
                                                    ref_pad_t24_r <= ref_raw_t24_r ; ref_pad_t25_r <= ref_raw_t25_r ;
                                                    ref_pad_t26_r <= ref_raw_t26_r ; ref_pad_t27_r <= ref_raw_t27_r ;
                                                    ref_pad_t28_r <= ref_raw_t28_r ; ref_pad_t29_r <= ref_raw_t29_r ;
                                                    ref_pad_t30_r <= ref_raw_t30_r ; ref_pad_t31_r <= ref_raw_t31_r ;
                                end
                                5'b01??? : begin    ref_pad_t00_r <= ref_raw_tl_r  ; ref_pad_t01_r <= ref_raw_tl_r  ;
                                                    ref_pad_t02_r <= ref_raw_tl_r  ; ref_pad_t03_r <= ref_raw_tl_r  ;
                                                    ref_pad_t04_r <= ref_raw_tl_r  ; ref_pad_t05_r <= ref_raw_tl_r  ;
                                                    ref_pad_t06_r <= ref_raw_tl_r  ; ref_pad_t07_r <= ref_raw_tl_r  ;
                                                    ref_pad_t08_r <= ref_raw_tl_r  ; ref_pad_t09_r <= ref_raw_tl_r  ;
                                                    ref_pad_t10_r <= ref_raw_tl_r  ; ref_pad_t11_r <= ref_raw_tl_r  ;
                                                    ref_pad_t12_r <= ref_raw_tl_r  ; ref_pad_t13_r <= ref_raw_tl_r  ;
                                                    ref_pad_t14_r <= ref_raw_tl_r  ; ref_pad_t15_r <= ref_raw_tl_r  ;
                                                    ref_pad_t16_r <= ref_raw_tl_r  ; ref_pad_t17_r <= ref_raw_tl_r  ;
                                                    ref_pad_t18_r <= ref_raw_tl_r  ; ref_pad_t19_r <= ref_raw_tl_r  ;
                                                    ref_pad_t20_r <= ref_raw_tl_r  ; ref_pad_t21_r <= ref_raw_tl_r  ;
                                                    ref_pad_t22_r <= ref_raw_tl_r  ; ref_pad_t23_r <= ref_raw_tl_r  ;
                                                    ref_pad_t24_r <= ref_raw_tl_r  ; ref_pad_t25_r <= ref_raw_tl_r  ;
                                                    ref_pad_t26_r <= ref_raw_tl_r  ; ref_pad_t27_r <= ref_raw_tl_r  ;
                                                    ref_pad_t28_r <= ref_raw_tl_r  ; ref_pad_t29_r <= ref_raw_tl_r  ;
                                                    ref_pad_t30_r <= ref_raw_tl_r  ; ref_pad_t31_r <= ref_raw_tl_r  ;
                                end
                                5'b001?? : begin    ref_pad_t00_r <= ref_raw_l00_r ; ref_pad_t01_r <= ref_raw_l00_r ;
                                                    ref_pad_t02_r <= ref_raw_l00_r ; ref_pad_t03_r <= ref_raw_l00_r ;
                                                    ref_pad_t04_r <= ref_raw_l00_r ; ref_pad_t05_r <= ref_raw_l00_r ;
                                                    ref_pad_t06_r <= ref_raw_l00_r ; ref_pad_t07_r <= ref_raw_l00_r ;
                                                    ref_pad_t08_r <= ref_raw_l00_r ; ref_pad_t09_r <= ref_raw_l00_r ;
                                                    ref_pad_t10_r <= ref_raw_l00_r ; ref_pad_t11_r <= ref_raw_l00_r ;
                                                    ref_pad_t12_r <= ref_raw_l00_r ; ref_pad_t13_r <= ref_raw_l00_r ;
                                                    ref_pad_t14_r <= ref_raw_l00_r ; ref_pad_t15_r <= ref_raw_l00_r ;
                                                    ref_pad_t16_r <= ref_raw_l00_r ; ref_pad_t17_r <= ref_raw_l00_r ;
                                                    ref_pad_t18_r <= ref_raw_l00_r ; ref_pad_t19_r <= ref_raw_l00_r ;
                                                    ref_pad_t20_r <= ref_raw_l00_r ; ref_pad_t21_r <= ref_raw_l00_r ;
                                                    ref_pad_t22_r <= ref_raw_l00_r ; ref_pad_t23_r <= ref_raw_l00_r ;
                                                    ref_pad_t24_r <= ref_raw_l00_r ; ref_pad_t25_r <= ref_raw_l00_r ;
                                                    ref_pad_t26_r <= ref_raw_l00_r ; ref_pad_t27_r <= ref_raw_l00_r ;
                                                    ref_pad_t28_r <= ref_raw_l00_r ; ref_pad_t29_r <= ref_raw_l00_r ;
                                                    ref_pad_t30_r <= ref_raw_l00_r ; ref_pad_t31_r <= ref_raw_l00_r ;
                                end
                                5'b0001? : begin    ref_pad_t00_r <= ref_raw_d00_r ; ref_pad_t01_r <= ref_raw_d00_r ;
                                                    ref_pad_t02_r <= ref_raw_d00_r ; ref_pad_t03_r <= ref_raw_d00_r ;
                                                    ref_pad_t04_r <= ref_raw_d00_r ; ref_pad_t05_r <= ref_raw_d00_r ;
                                                    ref_pad_t06_r <= ref_raw_d00_r ; ref_pad_t07_r <= ref_raw_d00_r ;
                                                    ref_pad_t08_r <= ref_raw_d00_r ; ref_pad_t09_r <= ref_raw_d00_r ;
                                                    ref_pad_t10_r <= ref_raw_d00_r ; ref_pad_t11_r <= ref_raw_d00_r ;
                                                    ref_pad_t12_r <= ref_raw_d00_r ; ref_pad_t13_r <= ref_raw_d00_r ;
                                                    ref_pad_t14_r <= ref_raw_d00_r ; ref_pad_t15_r <= ref_raw_d00_r ;
                                                    ref_pad_t16_r <= ref_raw_d00_r ; ref_pad_t17_r <= ref_raw_d00_r ;
                                                    ref_pad_t18_r <= ref_raw_d00_r ; ref_pad_t19_r <= ref_raw_d00_r ;
                                                    ref_pad_t20_r <= ref_raw_d00_r ; ref_pad_t21_r <= ref_raw_d00_r ;
                                                    ref_pad_t22_r <= ref_raw_d00_r ; ref_pad_t23_r <= ref_raw_d00_r ;
                                                    ref_pad_t24_r <= ref_raw_d00_r ; ref_pad_t25_r <= ref_raw_d00_r ;
                                                    ref_pad_t26_r <= ref_raw_d00_r ; ref_pad_t27_r <= ref_raw_d00_r ;
                                                    ref_pad_t28_r <= ref_raw_d00_r ; ref_pad_t29_r <= ref_raw_d00_r ;
                                                    ref_pad_t30_r <= ref_raw_d00_r ; ref_pad_t31_r <= ref_raw_d00_r ;
                                end
                                5'b00001 : begin    ref_pad_t00_r <= ref_raw_r00_r ; ref_pad_t01_r <= ref_raw_r00_r ;
                                                    ref_pad_t02_r <= ref_raw_r00_r ; ref_pad_t03_r <= ref_raw_r00_r ;
                                                    ref_pad_t04_r <= ref_raw_r00_r ; ref_pad_t05_r <= ref_raw_r00_r ;
                                                    ref_pad_t06_r <= ref_raw_r00_r ; ref_pad_t07_r <= ref_raw_r00_r ;
                                                    ref_pad_t08_r <= ref_raw_r00_r ; ref_pad_t09_r <= ref_raw_r00_r ;
                                                    ref_pad_t10_r <= ref_raw_r00_r ; ref_pad_t11_r <= ref_raw_r00_r ;
                                                    ref_pad_t12_r <= ref_raw_r00_r ; ref_pad_t13_r <= ref_raw_r00_r ;
                                                    ref_pad_t14_r <= ref_raw_r00_r ; ref_pad_t15_r <= ref_raw_r00_r ;
                                                    ref_pad_t16_r <= ref_raw_r00_r ; ref_pad_t17_r <= ref_raw_r00_r ;
                                                    ref_pad_t18_r <= ref_raw_r00_r ; ref_pad_t19_r <= ref_raw_r00_r ;
                                                    ref_pad_t20_r <= ref_raw_r00_r ; ref_pad_t21_r <= ref_raw_r00_r ;
                                                    ref_pad_t22_r <= ref_raw_r00_r ; ref_pad_t23_r <= ref_raw_r00_r ;
                                                    ref_pad_t24_r <= ref_raw_r00_r ; ref_pad_t25_r <= ref_raw_r00_r ;
                                                    ref_pad_t26_r <= ref_raw_r00_r ; ref_pad_t27_r <= ref_raw_r00_r ;
                                                    ref_pad_t28_r <= ref_raw_r00_r ; ref_pad_t29_r <= ref_raw_r00_r ;
                                                    ref_pad_t30_r <= ref_raw_r00_r ; ref_pad_t31_r <= ref_raw_r00_r ;
                                end
                              endcase
          end
        endcase
      end
    end
  end

  // right
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_pad_r00_r <= DAT_DEF ; ref_pad_r01_r <= DAT_DEF ;
      ref_pad_r02_r <= DAT_DEF ; ref_pad_r03_r <= DAT_DEF ;
      ref_pad_r04_r <= DAT_DEF ; ref_pad_r05_r <= DAT_DEF ;
      ref_pad_r06_r <= DAT_DEF ; ref_pad_r07_r <= DAT_DEF ;
      ref_pad_r08_r <= DAT_DEF ; ref_pad_r09_r <= DAT_DEF ;
      ref_pad_r10_r <= DAT_DEF ; ref_pad_r11_r <= DAT_DEF ;
      ref_pad_r12_r <= DAT_DEF ; ref_pad_r13_r <= DAT_DEF ;
      ref_pad_r14_r <= DAT_DEF ; ref_pad_r15_r <= DAT_DEF ;
      ref_pad_r16_r <= DAT_DEF ; ref_pad_r17_r <= DAT_DEF ;
      ref_pad_r18_r <= DAT_DEF ; ref_pad_r19_r <= DAT_DEF ;
      ref_pad_r20_r <= DAT_DEF ; ref_pad_r21_r <= DAT_DEF ;
      ref_pad_r22_r <= DAT_DEF ; ref_pad_r23_r <= DAT_DEF ;
      ref_pad_r24_r <= DAT_DEF ; ref_pad_r25_r <= DAT_DEF ;
      ref_pad_r26_r <= DAT_DEF ; ref_pad_r27_r <= DAT_DEF ;
      ref_pad_r28_r <= DAT_DEF ; ref_pad_r29_r <= DAT_DEF ;
      ref_pad_r30_r <= DAT_DEF ; ref_pad_r31_r <= DAT_DEF ;
    end
    else begin
      if( start_pad_w ) begin
        ref_pad_r00_r <= DAT_DEF ; ref_pad_r01_r <= DAT_DEF ;
        ref_pad_r02_r <= DAT_DEF ; ref_pad_r03_r <= DAT_DEF ;
        ref_pad_r04_r <= DAT_DEF ; ref_pad_r05_r <= DAT_DEF ;
        ref_pad_r06_r <= DAT_DEF ; ref_pad_r07_r <= DAT_DEF ;
        ref_pad_r08_r <= DAT_DEF ; ref_pad_r09_r <= DAT_DEF ;
        ref_pad_r10_r <= DAT_DEF ; ref_pad_r11_r <= DAT_DEF ;
        ref_pad_r12_r <= DAT_DEF ; ref_pad_r13_r <= DAT_DEF ;
        ref_pad_r14_r <= DAT_DEF ; ref_pad_r15_r <= DAT_DEF ;
        ref_pad_r16_r <= DAT_DEF ; ref_pad_r17_r <= DAT_DEF ;
        ref_pad_r18_r <= DAT_DEF ; ref_pad_r19_r <= DAT_DEF ;
        ref_pad_r20_r <= DAT_DEF ; ref_pad_r21_r <= DAT_DEF ;
        ref_pad_r22_r <= DAT_DEF ; ref_pad_r23_r <= DAT_DEF ;
        ref_pad_r24_r <= DAT_DEF ; ref_pad_r25_r <= DAT_DEF ;
        ref_pad_r26_r <= DAT_DEF ; ref_pad_r27_r <= DAT_DEF ;
        ref_pad_r28_r <= DAT_DEF ; ref_pad_r29_r <= DAT_DEF ;
        ref_pad_r30_r <= DAT_DEF ; ref_pad_r31_r <= DAT_DEF ;
        case( size_d2_r )
          `SIZE_04 : begin    casez( {pu_rt_exist_r[0],pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0]} )
                                5'b1???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                    ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                end
                                5'b01??? : begin    ref_pad_r00_r <= ref_raw_t03_r ; ref_pad_r01_r <= ref_raw_t03_r ;
                                                    ref_pad_r02_r <= ref_raw_t03_r ; ref_pad_r03_r <= ref_raw_t03_r ;
                                end
                                5'b001?? : begin    ref_pad_r00_r <= ref_raw_tl_r  ; ref_pad_r01_r <= ref_raw_tl_r  ;
                                                    ref_pad_r02_r <= ref_raw_tl_r  ; ref_pad_r03_r <= ref_raw_tl_r  ;
                                end
                                5'b0001? : begin    ref_pad_r00_r <= ref_raw_l00_r ; ref_pad_r01_r <= ref_raw_l00_r ;
                                                    ref_pad_r02_r <= ref_raw_l00_r ; ref_pad_r03_r <= ref_raw_l00_r ;
                                end
                                5'b00001 : begin    ref_pad_r00_r <= ref_raw_d00_r ; ref_pad_r01_r <= ref_raw_d00_r ;
                                                    ref_pad_r02_r <= ref_raw_d00_r ; ref_pad_r03_r <= ref_raw_d00_r ;
                                end
                              endcase
          end
          `SIZE_08 : begin    casez( {pu_rt_exist_r[1:0],pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0]} )
                                6'b1?_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                      ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                      ref_pad_r04_r <= ref_raw_r04_r ; ref_pad_r05_r <= ref_raw_r05_r ;
                                                      ref_pad_r06_r <= ref_raw_r06_r ; ref_pad_r07_r <= ref_raw_r07_r ;
                                end
                                6'b01_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                      ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                      ref_pad_r04_r <= ref_raw_r03_r ; ref_pad_r05_r <= ref_raw_r03_r ;
                                                      ref_pad_r06_r <= ref_raw_r03_r ; ref_pad_r07_r <= ref_raw_r03_r ;
                                end
                                6'b00_1??? : begin    ref_pad_r00_r <= ref_raw_t07_r ; ref_pad_r01_r <= ref_raw_t07_r ;
                                                      ref_pad_r02_r <= ref_raw_t07_r ; ref_pad_r03_r <= ref_raw_t07_r ;
                                                      ref_pad_r04_r <= ref_raw_t07_r ; ref_pad_r05_r <= ref_raw_t07_r ;
                                                      ref_pad_r06_r <= ref_raw_t07_r ; ref_pad_r07_r <= ref_raw_t07_r ;
                                end
                                6'b00_01?? : begin    ref_pad_r00_r <= ref_raw_tl_r  ; ref_pad_r01_r <= ref_raw_tl_r  ;
                                                      ref_pad_r02_r <= ref_raw_tl_r  ; ref_pad_r03_r <= ref_raw_tl_r  ;
                                                      ref_pad_r04_r <= ref_raw_tl_r  ; ref_pad_r05_r <= ref_raw_tl_r  ;
                                                      ref_pad_r06_r <= ref_raw_tl_r  ; ref_pad_r07_r <= ref_raw_tl_r  ;
                                end 
                                6'b00_001? : begin    ref_pad_r00_r <= ref_raw_l00_r ; ref_pad_r01_r <= ref_raw_l00_r ;
                                                      ref_pad_r02_r <= ref_raw_l00_r ; ref_pad_r03_r <= ref_raw_l00_r ;
                                                      ref_pad_r04_r <= ref_raw_l00_r ; ref_pad_r05_r <= ref_raw_l00_r ;
                                                      ref_pad_r06_r <= ref_raw_l00_r ; ref_pad_r07_r <= ref_raw_l00_r ;
                                end
                                6'b00_0001 : begin    ref_pad_r00_r <= ref_raw_d00_r ; ref_pad_r01_r <= ref_raw_d00_r ;
                                                      ref_pad_r02_r <= ref_raw_d00_r ; ref_pad_r03_r <= ref_raw_d00_r ;
                                                      ref_pad_r04_r <= ref_raw_d00_r ; ref_pad_r05_r <= ref_raw_d00_r ;
                                                      ref_pad_r06_r <= ref_raw_d00_r ; ref_pad_r07_r <= ref_raw_d00_r ;
                                end
                              endcase
          end
          `SIZE_16 : begin    casez( {pu_rt_exist_r[3:0],pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0]} )
                                8'b1???_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                        ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                        ref_pad_r04_r <= ref_raw_r04_r ; ref_pad_r05_r <= ref_raw_r05_r ;
                                                        ref_pad_r06_r <= ref_raw_r06_r ; ref_pad_r07_r <= ref_raw_r07_r ;
                                                        ref_pad_r08_r <= ref_raw_r08_r ; ref_pad_r09_r <= ref_raw_r09_r ;
                                                        ref_pad_r10_r <= ref_raw_r10_r ; ref_pad_r11_r <= ref_raw_r11_r ;
                                                        ref_pad_r12_r <= ref_raw_r12_r ; ref_pad_r13_r <= ref_raw_r13_r ;
                                                        ref_pad_r14_r <= ref_raw_r14_r ; ref_pad_r15_r <= ref_raw_r15_r ;
                                end
                                8'b01??_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                        ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                        ref_pad_r04_r <= ref_raw_r04_r ; ref_pad_r05_r <= ref_raw_r05_r ;
                                                        ref_pad_r06_r <= ref_raw_r06_r ; ref_pad_r07_r <= ref_raw_r07_r ;
                                                        ref_pad_r08_r <= ref_raw_r08_r ; ref_pad_r09_r <= ref_raw_r09_r ;
                                                        ref_pad_r10_r <= ref_raw_r10_r ; ref_pad_r11_r <= ref_raw_r11_r ;
                                                        ref_pad_r12_r <= ref_raw_r11_r ; ref_pad_r13_r <= ref_raw_r11_r ;
                                                        ref_pad_r14_r <= ref_raw_r11_r ; ref_pad_r15_r <= ref_raw_r11_r ;
                                end
                                8'b001?_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                        ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                        ref_pad_r04_r <= ref_raw_r04_r ; ref_pad_r05_r <= ref_raw_r05_r ;
                                                        ref_pad_r06_r <= ref_raw_r06_r ; ref_pad_r07_r <= ref_raw_r07_r ;
                                                        ref_pad_r08_r <= ref_raw_r07_r ; ref_pad_r09_r <= ref_raw_r07_r ;
                                                        ref_pad_r10_r <= ref_raw_r07_r ; ref_pad_r11_r <= ref_raw_r07_r ;
                                                        ref_pad_r12_r <= ref_raw_r07_r ; ref_pad_r13_r <= ref_raw_r07_r ;
                                                        ref_pad_r14_r <= ref_raw_r07_r ; ref_pad_r15_r <= ref_raw_r07_r ;
                                end
                                8'b0001_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                        ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                        ref_pad_r04_r <= ref_raw_r03_r ; ref_pad_r05_r <= ref_raw_r03_r ;
                                                        ref_pad_r06_r <= ref_raw_r03_r ; ref_pad_r07_r <= ref_raw_r03_r ;
                                                        ref_pad_r08_r <= ref_raw_r03_r ; ref_pad_r09_r <= ref_raw_r03_r ;
                                                        ref_pad_r10_r <= ref_raw_r03_r ; ref_pad_r11_r <= ref_raw_r03_r ;
                                                        ref_pad_r12_r <= ref_raw_r03_r ; ref_pad_r13_r <= ref_raw_r03_r ;
                                                        ref_pad_r14_r <= ref_raw_r03_r ; ref_pad_r15_r <= ref_raw_r03_r ;
                                end
                                8'b0000_1??? : begin    ref_pad_r00_r <= ref_raw_t15_r ; ref_pad_r01_r <= ref_raw_t15_r ;
                                                        ref_pad_r02_r <= ref_raw_t15_r ; ref_pad_r03_r <= ref_raw_t15_r ;
                                                        ref_pad_r04_r <= ref_raw_t15_r ; ref_pad_r05_r <= ref_raw_t15_r ;
                                                        ref_pad_r06_r <= ref_raw_t15_r ; ref_pad_r07_r <= ref_raw_t15_r ;
                                                        ref_pad_r08_r <= ref_raw_t15_r ; ref_pad_r09_r <= ref_raw_t15_r ;
                                                        ref_pad_r10_r <= ref_raw_t15_r ; ref_pad_r11_r <= ref_raw_t15_r ;
                                                        ref_pad_r12_r <= ref_raw_t15_r ; ref_pad_r13_r <= ref_raw_t15_r ;
                                                        ref_pad_r14_r <= ref_raw_t15_r ; ref_pad_r15_r <= ref_raw_t15_r ;
                                end
                                8'b0000_01?? : begin    ref_pad_r00_r <= ref_raw_tl_r  ; ref_pad_r01_r <= ref_raw_tl_r ;
                                                        ref_pad_r02_r <= ref_raw_tl_r  ; ref_pad_r03_r <= ref_raw_tl_r ;
                                                        ref_pad_r04_r <= ref_raw_tl_r  ; ref_pad_r05_r <= ref_raw_tl_r ;
                                                        ref_pad_r06_r <= ref_raw_tl_r  ; ref_pad_r07_r <= ref_raw_tl_r ;
                                                        ref_pad_r08_r <= ref_raw_tl_r  ; ref_pad_r09_r <= ref_raw_tl_r ;
                                                        ref_pad_r10_r <= ref_raw_tl_r  ; ref_pad_r11_r <= ref_raw_tl_r ;
                                                        ref_pad_r12_r <= ref_raw_tl_r  ; ref_pad_r13_r <= ref_raw_tl_r ;
                                                        ref_pad_r14_r <= ref_raw_tl_r  ; ref_pad_r15_r <= ref_raw_tl_r ;
                                end
                                8'b0000_001? : begin    ref_pad_r00_r <= ref_raw_l00_r ; ref_pad_r01_r <= ref_raw_l00_r ;
                                                        ref_pad_r02_r <= ref_raw_l00_r ; ref_pad_r03_r <= ref_raw_l00_r ;
                                                        ref_pad_r04_r <= ref_raw_l00_r ; ref_pad_r05_r <= ref_raw_l00_r ;
                                                        ref_pad_r06_r <= ref_raw_l00_r ; ref_pad_r07_r <= ref_raw_l00_r ;
                                                        ref_pad_r08_r <= ref_raw_l00_r ; ref_pad_r09_r <= ref_raw_l00_r ;
                                                        ref_pad_r10_r <= ref_raw_l00_r ; ref_pad_r11_r <= ref_raw_l00_r ;
                                                        ref_pad_r12_r <= ref_raw_l00_r ; ref_pad_r13_r <= ref_raw_l00_r ;
                                                        ref_pad_r14_r <= ref_raw_l00_r ; ref_pad_r15_r <= ref_raw_l00_r ;
                                end
                                8'b0000_0001 : begin    ref_pad_r00_r <= ref_raw_d00_r ; ref_pad_r01_r <= ref_raw_d00_r ;
                                                        ref_pad_r02_r <= ref_raw_d00_r ; ref_pad_r03_r <= ref_raw_d00_r ;
                                                        ref_pad_r04_r <= ref_raw_d00_r ; ref_pad_r05_r <= ref_raw_d00_r ;
                                                        ref_pad_r06_r <= ref_raw_d00_r ; ref_pad_r07_r <= ref_raw_d00_r ;
                                                        ref_pad_r08_r <= ref_raw_d00_r ; ref_pad_r09_r <= ref_raw_d00_r ;
                                                        ref_pad_r10_r <= ref_raw_d00_r ; ref_pad_r11_r <= ref_raw_d00_r ;
                                                        ref_pad_r12_r <= ref_raw_d00_r ; ref_pad_r13_r <= ref_raw_d00_r ;
                                                        ref_pad_r14_r <= ref_raw_d00_r ; ref_pad_r15_r <= ref_raw_d00_r ;
                                end
                              endcase
          end
          `SIZE_32 : begin    casez( {pu_rt_exist_r,pu_tp_exist_r,pu_tl_exist_r,pu_lf_exist_r,pu_dn_exist_r[0]} )
                                12'b1???????_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                             ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                             ref_pad_r04_r <= ref_raw_r04_r ; ref_pad_r05_r <= ref_raw_r05_r ;
                                                             ref_pad_r06_r <= ref_raw_r06_r ; ref_pad_r07_r <= ref_raw_r07_r ;
                                                             ref_pad_r08_r <= ref_raw_r08_r ; ref_pad_r09_r <= ref_raw_r09_r ;
                                                             ref_pad_r10_r <= ref_raw_r10_r ; ref_pad_r11_r <= ref_raw_r11_r ;
                                                             ref_pad_r12_r <= ref_raw_r12_r ; ref_pad_r13_r <= ref_raw_r13_r ;
                                                             ref_pad_r14_r <= ref_raw_r14_r ; ref_pad_r15_r <= ref_raw_r15_r ;
                                                             ref_pad_r16_r <= ref_raw_r16_r ; ref_pad_r17_r <= ref_raw_r17_r ;
                                                             ref_pad_r18_r <= ref_raw_r18_r ; ref_pad_r19_r <= ref_raw_r19_r ;
                                                             ref_pad_r20_r <= ref_raw_r20_r ; ref_pad_r21_r <= ref_raw_r21_r ;
                                                             ref_pad_r22_r <= ref_raw_r22_r ; ref_pad_r23_r <= ref_raw_r23_r ;
                                                             ref_pad_r24_r <= ref_raw_r24_r ; ref_pad_r25_r <= ref_raw_r25_r ;
                                                             ref_pad_r26_r <= ref_raw_r26_r ; ref_pad_r27_r <= ref_raw_r27_r ;
                                                             ref_pad_r28_r <= ref_raw_r28_r ; ref_pad_r29_r <= ref_raw_r29_r ;
                                                             ref_pad_r30_r <= ref_raw_r30_r ; ref_pad_r31_r <= ref_raw_r31_r ;
                                end
                                12'b01??????_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                             ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                             ref_pad_r04_r <= ref_raw_r04_r ; ref_pad_r05_r <= ref_raw_r05_r ;
                                                             ref_pad_r06_r <= ref_raw_r06_r ; ref_pad_r07_r <= ref_raw_r07_r ;
                                                             ref_pad_r08_r <= ref_raw_r08_r ; ref_pad_r09_r <= ref_raw_r09_r ;
                                                             ref_pad_r10_r <= ref_raw_r10_r ; ref_pad_r11_r <= ref_raw_r11_r ;
                                                             ref_pad_r12_r <= ref_raw_r12_r ; ref_pad_r13_r <= ref_raw_r13_r ;
                                                             ref_pad_r14_r <= ref_raw_r14_r ; ref_pad_r15_r <= ref_raw_r15_r ;
                                                             ref_pad_r16_r <= ref_raw_r16_r ; ref_pad_r17_r <= ref_raw_r17_r ;
                                                             ref_pad_r18_r <= ref_raw_r18_r ; ref_pad_r19_r <= ref_raw_r19_r ;
                                                             ref_pad_r20_r <= ref_raw_r20_r ; ref_pad_r21_r <= ref_raw_r21_r ;
                                                             ref_pad_r22_r <= ref_raw_r22_r ; ref_pad_r23_r <= ref_raw_r23_r ;
                                                             ref_pad_r24_r <= ref_raw_r24_r ; ref_pad_r25_r <= ref_raw_r25_r ;
                                                             ref_pad_r26_r <= ref_raw_r26_r ; ref_pad_r27_r <= ref_raw_r27_r ;
                                                             ref_pad_r28_r <= ref_raw_r27_r ; ref_pad_r29_r <= ref_raw_r27_r ;
                                                             ref_pad_r30_r <= ref_raw_r27_r ; ref_pad_r31_r <= ref_raw_r27_r ;
                                end
                                12'b001?????_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                             ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                             ref_pad_r04_r <= ref_raw_r04_r ; ref_pad_r05_r <= ref_raw_r05_r ;
                                                             ref_pad_r06_r <= ref_raw_r06_r ; ref_pad_r07_r <= ref_raw_r07_r ;
                                                             ref_pad_r08_r <= ref_raw_r08_r ; ref_pad_r09_r <= ref_raw_r09_r ;
                                                             ref_pad_r10_r <= ref_raw_r10_r ; ref_pad_r11_r <= ref_raw_r11_r ;
                                                             ref_pad_r12_r <= ref_raw_r12_r ; ref_pad_r13_r <= ref_raw_r13_r ;
                                                             ref_pad_r14_r <= ref_raw_r14_r ; ref_pad_r15_r <= ref_raw_r15_r ;
                                                             ref_pad_r16_r <= ref_raw_r16_r ; ref_pad_r17_r <= ref_raw_r17_r ;
                                                             ref_pad_r18_r <= ref_raw_r18_r ; ref_pad_r19_r <= ref_raw_r19_r ;
                                                             ref_pad_r20_r <= ref_raw_r20_r ; ref_pad_r21_r <= ref_raw_r21_r ;
                                                             ref_pad_r22_r <= ref_raw_r22_r ; ref_pad_r23_r <= ref_raw_r23_r ;
                                                             ref_pad_r24_r <= ref_raw_r23_r ; ref_pad_r25_r <= ref_raw_r23_r ;
                                                             ref_pad_r26_r <= ref_raw_r23_r ; ref_pad_r27_r <= ref_raw_r23_r ;
                                                             ref_pad_r28_r <= ref_raw_r23_r ; ref_pad_r29_r <= ref_raw_r23_r ;
                                                             ref_pad_r30_r <= ref_raw_r23_r ; ref_pad_r31_r <= ref_raw_r23_r ;
                                end
                                12'b0001????_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                             ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                             ref_pad_r04_r <= ref_raw_r04_r ; ref_pad_r05_r <= ref_raw_r05_r ;
                                                             ref_pad_r06_r <= ref_raw_r06_r ; ref_pad_r07_r <= ref_raw_r07_r ;
                                                             ref_pad_r08_r <= ref_raw_r08_r ; ref_pad_r09_r <= ref_raw_r09_r ;
                                                             ref_pad_r10_r <= ref_raw_r10_r ; ref_pad_r11_r <= ref_raw_r11_r ;
                                                             ref_pad_r12_r <= ref_raw_r12_r ; ref_pad_r13_r <= ref_raw_r13_r ;
                                                             ref_pad_r14_r <= ref_raw_r14_r ; ref_pad_r15_r <= ref_raw_r15_r ;
                                                             ref_pad_r16_r <= ref_raw_r16_r ; ref_pad_r17_r <= ref_raw_r17_r ;
                                                             ref_pad_r18_r <= ref_raw_r18_r ; ref_pad_r19_r <= ref_raw_r19_r ;
                                                             ref_pad_r20_r <= ref_raw_r19_r ; ref_pad_r21_r <= ref_raw_r19_r ;
                                                             ref_pad_r22_r <= ref_raw_r19_r ; ref_pad_r23_r <= ref_raw_r19_r ;
                                                             ref_pad_r24_r <= ref_raw_r19_r ; ref_pad_r25_r <= ref_raw_r19_r ;
                                                             ref_pad_r26_r <= ref_raw_r19_r ; ref_pad_r27_r <= ref_raw_r19_r ;
                                                             ref_pad_r28_r <= ref_raw_r19_r ; ref_pad_r29_r <= ref_raw_r19_r ;
                                                             ref_pad_r30_r <= ref_raw_r19_r ; ref_pad_r31_r <= ref_raw_r19_r ;
                                end
                                12'b00001???_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                             ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                             ref_pad_r04_r <= ref_raw_r04_r ; ref_pad_r05_r <= ref_raw_r05_r ;
                                                             ref_pad_r06_r <= ref_raw_r06_r ; ref_pad_r07_r <= ref_raw_r07_r ;
                                                             ref_pad_r08_r <= ref_raw_r08_r ; ref_pad_r09_r <= ref_raw_r09_r ;
                                                             ref_pad_r10_r <= ref_raw_r10_r ; ref_pad_r11_r <= ref_raw_r11_r ;
                                                             ref_pad_r12_r <= ref_raw_r12_r ; ref_pad_r13_r <= ref_raw_r13_r ;
                                                             ref_pad_r14_r <= ref_raw_r14_r ; ref_pad_r15_r <= ref_raw_r15_r ;
                                                             ref_pad_r16_r <= ref_raw_r15_r ; ref_pad_r17_r <= ref_raw_r15_r ;
                                                             ref_pad_r18_r <= ref_raw_r15_r ; ref_pad_r19_r <= ref_raw_r15_r ;
                                                             ref_pad_r20_r <= ref_raw_r15_r ; ref_pad_r21_r <= ref_raw_r15_r ;
                                                             ref_pad_r22_r <= ref_raw_r15_r ; ref_pad_r23_r <= ref_raw_r15_r ;
                                                             ref_pad_r24_r <= ref_raw_r15_r ; ref_pad_r25_r <= ref_raw_r15_r ;
                                                             ref_pad_r26_r <= ref_raw_r15_r ; ref_pad_r27_r <= ref_raw_r15_r ;
                                                             ref_pad_r28_r <= ref_raw_r15_r ; ref_pad_r29_r <= ref_raw_r15_r ;
                                                             ref_pad_r30_r <= ref_raw_r15_r ; ref_pad_r31_r <= ref_raw_r15_r ;
                                end
                                12'b000001??_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                             ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                             ref_pad_r04_r <= ref_raw_r04_r ; ref_pad_r05_r <= ref_raw_r05_r ;
                                                             ref_pad_r06_r <= ref_raw_r06_r ; ref_pad_r07_r <= ref_raw_r07_r ;
                                                             ref_pad_r08_r <= ref_raw_r08_r ; ref_pad_r09_r <= ref_raw_r09_r ;
                                                             ref_pad_r10_r <= ref_raw_r10_r ; ref_pad_r11_r <= ref_raw_r11_r ;
                                                             ref_pad_r12_r <= ref_raw_r11_r ; ref_pad_r13_r <= ref_raw_r11_r ;
                                                             ref_pad_r14_r <= ref_raw_r11_r ; ref_pad_r15_r <= ref_raw_r11_r ;
                                                             ref_pad_r16_r <= ref_raw_r11_r ; ref_pad_r17_r <= ref_raw_r11_r ;
                                                             ref_pad_r18_r <= ref_raw_r11_r ; ref_pad_r19_r <= ref_raw_r11_r ;
                                                             ref_pad_r20_r <= ref_raw_r11_r ; ref_pad_r21_r <= ref_raw_r11_r ;
                                                             ref_pad_r22_r <= ref_raw_r11_r ; ref_pad_r23_r <= ref_raw_r11_r ;
                                                             ref_pad_r24_r <= ref_raw_r11_r ; ref_pad_r25_r <= ref_raw_r11_r ;
                                                             ref_pad_r26_r <= ref_raw_r11_r ; ref_pad_r27_r <= ref_raw_r11_r ;
                                                             ref_pad_r28_r <= ref_raw_r11_r ; ref_pad_r29_r <= ref_raw_r11_r ;
                                                             ref_pad_r30_r <= ref_raw_r11_r ; ref_pad_r31_r <= ref_raw_r11_r ;
                                end
                                12'b0000001?_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                             ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                             ref_pad_r04_r <= ref_raw_r04_r ; ref_pad_r05_r <= ref_raw_r05_r ;
                                                             ref_pad_r06_r <= ref_raw_r06_r ; ref_pad_r07_r <= ref_raw_r07_r ;
                                                             ref_pad_r08_r <= ref_raw_r07_r ; ref_pad_r09_r <= ref_raw_r07_r ;
                                                             ref_pad_r10_r <= ref_raw_r07_r ; ref_pad_r11_r <= ref_raw_r07_r ;
                                                             ref_pad_r12_r <= ref_raw_r07_r ; ref_pad_r13_r <= ref_raw_r07_r ;
                                                             ref_pad_r14_r <= ref_raw_r07_r ; ref_pad_r15_r <= ref_raw_r07_r ;
                                                             ref_pad_r16_r <= ref_raw_r07_r ; ref_pad_r17_r <= ref_raw_r07_r ;
                                                             ref_pad_r18_r <= ref_raw_r07_r ; ref_pad_r19_r <= ref_raw_r07_r ;
                                                             ref_pad_r20_r <= ref_raw_r07_r ; ref_pad_r21_r <= ref_raw_r07_r ;
                                                             ref_pad_r22_r <= ref_raw_r07_r ; ref_pad_r23_r <= ref_raw_r07_r ;
                                                             ref_pad_r24_r <= ref_raw_r07_r ; ref_pad_r25_r <= ref_raw_r07_r ;
                                                             ref_pad_r26_r <= ref_raw_r07_r ; ref_pad_r27_r <= ref_raw_r07_r ;
                                                             ref_pad_r28_r <= ref_raw_r07_r ; ref_pad_r29_r <= ref_raw_r07_r ;
                                                             ref_pad_r30_r <= ref_raw_r07_r ; ref_pad_r31_r <= ref_raw_r07_r ;
                                end
                                12'b00000001_???? : begin    ref_pad_r00_r <= ref_raw_r00_r ; ref_pad_r01_r <= ref_raw_r01_r ;
                                                             ref_pad_r02_r <= ref_raw_r02_r ; ref_pad_r03_r <= ref_raw_r03_r ;
                                                             ref_pad_r04_r <= ref_raw_r03_r ; ref_pad_r05_r <= ref_raw_r03_r ;
                                                             ref_pad_r06_r <= ref_raw_r03_r ; ref_pad_r07_r <= ref_raw_r03_r ;
                                                             ref_pad_r08_r <= ref_raw_r03_r ; ref_pad_r09_r <= ref_raw_r03_r ;
                                                             ref_pad_r10_r <= ref_raw_r03_r ; ref_pad_r11_r <= ref_raw_r03_r ;
                                                             ref_pad_r12_r <= ref_raw_r03_r ; ref_pad_r13_r <= ref_raw_r03_r ;
                                                             ref_pad_r14_r <= ref_raw_r03_r ; ref_pad_r15_r <= ref_raw_r03_r ;
                                                             ref_pad_r16_r <= ref_raw_r03_r ; ref_pad_r17_r <= ref_raw_r03_r ;
                                                             ref_pad_r18_r <= ref_raw_r03_r ; ref_pad_r19_r <= ref_raw_r03_r ;
                                                             ref_pad_r20_r <= ref_raw_r03_r ; ref_pad_r21_r <= ref_raw_r03_r ;
                                                             ref_pad_r22_r <= ref_raw_r03_r ; ref_pad_r23_r <= ref_raw_r03_r ;
                                                             ref_pad_r24_r <= ref_raw_r03_r ; ref_pad_r25_r <= ref_raw_r03_r ;
                                                             ref_pad_r26_r <= ref_raw_r03_r ; ref_pad_r27_r <= ref_raw_r03_r ;
                                                             ref_pad_r28_r <= ref_raw_r03_r ; ref_pad_r29_r <= ref_raw_r03_r ;
                                                             ref_pad_r30_r <= ref_raw_r03_r ; ref_pad_r31_r <= ref_raw_r03_r ;
                                end
                                12'b00000000_1??? : begin    ref_pad_r00_r <= ref_raw_t31_r ; ref_pad_r01_r <= ref_raw_t31_r ;
                                                             ref_pad_r02_r <= ref_raw_t31_r ; ref_pad_r03_r <= ref_raw_t31_r ;
                                                             ref_pad_r04_r <= ref_raw_t31_r ; ref_pad_r05_r <= ref_raw_t31_r ;
                                                             ref_pad_r06_r <= ref_raw_t31_r ; ref_pad_r07_r <= ref_raw_t31_r ;
                                                             ref_pad_r08_r <= ref_raw_t31_r ; ref_pad_r09_r <= ref_raw_t31_r ;
                                                             ref_pad_r10_r <= ref_raw_t31_r ; ref_pad_r11_r <= ref_raw_t31_r ;
                                                             ref_pad_r12_r <= ref_raw_t31_r ; ref_pad_r13_r <= ref_raw_t31_r ;
                                                             ref_pad_r14_r <= ref_raw_t31_r ; ref_pad_r15_r <= ref_raw_t31_r ;
                                                             ref_pad_r16_r <= ref_raw_t31_r ; ref_pad_r17_r <= ref_raw_t31_r ;
                                                             ref_pad_r18_r <= ref_raw_t31_r ; ref_pad_r19_r <= ref_raw_t31_r ;
                                                             ref_pad_r20_r <= ref_raw_t31_r ; ref_pad_r21_r <= ref_raw_t31_r ;
                                                             ref_pad_r22_r <= ref_raw_t31_r ; ref_pad_r23_r <= ref_raw_t31_r ;
                                                             ref_pad_r24_r <= ref_raw_t31_r ; ref_pad_r25_r <= ref_raw_t31_r ;
                                                             ref_pad_r26_r <= ref_raw_t31_r ; ref_pad_r27_r <= ref_raw_t31_r ;
                                                             ref_pad_r28_r <= ref_raw_t31_r ; ref_pad_r29_r <= ref_raw_t31_r ;
                                                             ref_pad_r30_r <= ref_raw_t31_r ; ref_pad_r31_r <= ref_raw_t31_r ;
                                end
                                12'b00000000_01?? : begin    ref_pad_r00_r <= ref_raw_tl_r ; ref_pad_r01_r <= ref_raw_tl_r ;
                                                             ref_pad_r02_r <= ref_raw_tl_r ; ref_pad_r03_r <= ref_raw_tl_r ;
                                                             ref_pad_r04_r <= ref_raw_tl_r ; ref_pad_r05_r <= ref_raw_tl_r ;
                                                             ref_pad_r06_r <= ref_raw_tl_r ; ref_pad_r07_r <= ref_raw_tl_r ;
                                                             ref_pad_r08_r <= ref_raw_tl_r ; ref_pad_r09_r <= ref_raw_tl_r ;
                                                             ref_pad_r10_r <= ref_raw_tl_r ; ref_pad_r11_r <= ref_raw_tl_r ;
                                                             ref_pad_r12_r <= ref_raw_tl_r ; ref_pad_r13_r <= ref_raw_tl_r ;
                                                             ref_pad_r14_r <= ref_raw_tl_r ; ref_pad_r15_r <= ref_raw_tl_r ;
                                                             ref_pad_r16_r <= ref_raw_tl_r ; ref_pad_r17_r <= ref_raw_tl_r ;
                                                             ref_pad_r18_r <= ref_raw_tl_r ; ref_pad_r19_r <= ref_raw_tl_r ;
                                                             ref_pad_r20_r <= ref_raw_tl_r ; ref_pad_r21_r <= ref_raw_tl_r ;
                                                             ref_pad_r22_r <= ref_raw_tl_r ; ref_pad_r23_r <= ref_raw_tl_r ;
                                                             ref_pad_r24_r <= ref_raw_tl_r ; ref_pad_r25_r <= ref_raw_tl_r ;
                                                             ref_pad_r26_r <= ref_raw_tl_r ; ref_pad_r27_r <= ref_raw_tl_r ;
                                                             ref_pad_r28_r <= ref_raw_tl_r ; ref_pad_r29_r <= ref_raw_tl_r ;
                                                             ref_pad_r30_r <= ref_raw_tl_r ; ref_pad_r31_r <= ref_raw_tl_r ;
                                end
                                12'b00000000_001? : begin    ref_pad_r00_r <= ref_raw_l00_r ; ref_pad_r01_r <= ref_raw_l00_r ;
                                                             ref_pad_r02_r <= ref_raw_l00_r ; ref_pad_r03_r <= ref_raw_l00_r ;
                                                             ref_pad_r04_r <= ref_raw_l00_r ; ref_pad_r05_r <= ref_raw_l00_r ;
                                                             ref_pad_r06_r <= ref_raw_l00_r ; ref_pad_r07_r <= ref_raw_l00_r ;
                                                             ref_pad_r08_r <= ref_raw_l00_r ; ref_pad_r09_r <= ref_raw_l00_r ;
                                                             ref_pad_r10_r <= ref_raw_l00_r ; ref_pad_r11_r <= ref_raw_l00_r ;
                                                             ref_pad_r12_r <= ref_raw_l00_r ; ref_pad_r13_r <= ref_raw_l00_r ;
                                                             ref_pad_r14_r <= ref_raw_l00_r ; ref_pad_r15_r <= ref_raw_l00_r ;
                                                             ref_pad_r16_r <= ref_raw_l00_r ; ref_pad_r17_r <= ref_raw_l00_r ;
                                                             ref_pad_r18_r <= ref_raw_l00_r ; ref_pad_r19_r <= ref_raw_l00_r ;
                                                             ref_pad_r20_r <= ref_raw_l00_r ; ref_pad_r21_r <= ref_raw_l00_r ;
                                                             ref_pad_r22_r <= ref_raw_l00_r ; ref_pad_r23_r <= ref_raw_l00_r ;
                                                             ref_pad_r24_r <= ref_raw_l00_r ; ref_pad_r25_r <= ref_raw_l00_r ;
                                                             ref_pad_r26_r <= ref_raw_l00_r ; ref_pad_r27_r <= ref_raw_l00_r ;
                                                             ref_pad_r28_r <= ref_raw_l00_r ; ref_pad_r29_r <= ref_raw_l00_r ;
                                                             ref_pad_r30_r <= ref_raw_l00_r ; ref_pad_r31_r <= ref_raw_l00_r ;
                                end
                                12'b00000000_0001 : begin    ref_pad_r00_r <= ref_raw_d00_r ; ref_pad_r01_r <= ref_raw_d00_r ;
                                                             ref_pad_r02_r <= ref_raw_d00_r ; ref_pad_r03_r <= ref_raw_d00_r ;
                                                             ref_pad_r04_r <= ref_raw_d00_r ; ref_pad_r05_r <= ref_raw_d00_r ;
                                                             ref_pad_r06_r <= ref_raw_d00_r ; ref_pad_r07_r <= ref_raw_d00_r ;
                                                             ref_pad_r08_r <= ref_raw_d00_r ; ref_pad_r09_r <= ref_raw_d00_r ;
                                                             ref_pad_r10_r <= ref_raw_d00_r ; ref_pad_r11_r <= ref_raw_d00_r ;
                                                             ref_pad_r12_r <= ref_raw_d00_r ; ref_pad_r13_r <= ref_raw_d00_r ;
                                                             ref_pad_r14_r <= ref_raw_d00_r ; ref_pad_r15_r <= ref_raw_d00_r ;
                                                             ref_pad_r16_r <= ref_raw_d00_r ; ref_pad_r17_r <= ref_raw_d00_r ;
                                                             ref_pad_r18_r <= ref_raw_d00_r ; ref_pad_r19_r <= ref_raw_d00_r ;
                                                             ref_pad_r20_r <= ref_raw_d00_r ; ref_pad_r21_r <= ref_raw_d00_r ;
                                                             ref_pad_r22_r <= ref_raw_d00_r ; ref_pad_r23_r <= ref_raw_d00_r ;
                                                             ref_pad_r24_r <= ref_raw_d00_r ; ref_pad_r25_r <= ref_raw_d00_r ;
                                                             ref_pad_r26_r <= ref_raw_d00_r ; ref_pad_r27_r <= ref_raw_d00_r ;
                                                             ref_pad_r28_r <= ref_raw_d00_r ; ref_pad_r29_r <= ref_raw_d00_r ;
                                                             ref_pad_r30_r <= ref_raw_d00_r ; ref_pad_r31_r <= ref_raw_d00_r ;
                                end
                              endcase
          end
        endcase
      end
    end
  end

  // down
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_pad_d00_r <= DAT_DEF ; ref_pad_d01_r <= DAT_DEF ;
      ref_pad_d02_r <= DAT_DEF ; ref_pad_d03_r <= DAT_DEF ;
      ref_pad_d04_r <= DAT_DEF ; ref_pad_d05_r <= DAT_DEF ;
      ref_pad_d06_r <= DAT_DEF ; ref_pad_d07_r <= DAT_DEF ;
      ref_pad_d08_r <= DAT_DEF ; ref_pad_d09_r <= DAT_DEF ;
      ref_pad_d10_r <= DAT_DEF ; ref_pad_d11_r <= DAT_DEF ;
      ref_pad_d12_r <= DAT_DEF ; ref_pad_d13_r <= DAT_DEF ;
      ref_pad_d14_r <= DAT_DEF ; ref_pad_d15_r <= DAT_DEF ;
      ref_pad_d16_r <= DAT_DEF ; ref_pad_d17_r <= DAT_DEF ;
      ref_pad_d18_r <= DAT_DEF ; ref_pad_d19_r <= DAT_DEF ;
      ref_pad_d20_r <= DAT_DEF ; ref_pad_d21_r <= DAT_DEF ;
      ref_pad_d22_r <= DAT_DEF ; ref_pad_d23_r <= DAT_DEF ;
      ref_pad_d24_r <= DAT_DEF ; ref_pad_d25_r <= DAT_DEF ;
      ref_pad_d26_r <= DAT_DEF ; ref_pad_d27_r <= DAT_DEF ;
      ref_pad_d28_r <= DAT_DEF ; ref_pad_d29_r <= DAT_DEF ;
      ref_pad_d30_r <= DAT_DEF ; ref_pad_d31_r <= DAT_DEF ;
    end
    else begin
      if( start_pad_w ) begin
        ref_pad_d00_r <= DAT_DEF ; ref_pad_d01_r <= DAT_DEF ;
        ref_pad_d02_r <= DAT_DEF ; ref_pad_d03_r <= DAT_DEF ;
        ref_pad_d04_r <= DAT_DEF ; ref_pad_d05_r <= DAT_DEF ;
        ref_pad_d06_r <= DAT_DEF ; ref_pad_d07_r <= DAT_DEF ;
        ref_pad_d08_r <= DAT_DEF ; ref_pad_d09_r <= DAT_DEF ;
        ref_pad_d10_r <= DAT_DEF ; ref_pad_d11_r <= DAT_DEF ;
        ref_pad_d12_r <= DAT_DEF ; ref_pad_d13_r <= DAT_DEF ;
        ref_pad_d14_r <= DAT_DEF ; ref_pad_d15_r <= DAT_DEF ;
        ref_pad_d16_r <= DAT_DEF ; ref_pad_d17_r <= DAT_DEF ;
        ref_pad_d18_r <= DAT_DEF ; ref_pad_d19_r <= DAT_DEF ;
        ref_pad_d20_r <= DAT_DEF ; ref_pad_d21_r <= DAT_DEF ;
        ref_pad_d22_r <= DAT_DEF ; ref_pad_d23_r <= DAT_DEF ;
        ref_pad_d24_r <= DAT_DEF ; ref_pad_d25_r <= DAT_DEF ;
        ref_pad_d26_r <= DAT_DEF ; ref_pad_d27_r <= DAT_DEF ;
        ref_pad_d28_r <= DAT_DEF ; ref_pad_d29_r <= DAT_DEF ;
        ref_pad_d30_r <= DAT_DEF ; ref_pad_d31_r <= DAT_DEF ;
        case( size_d2_r )
          `SIZE_04 : begin    casez( {pu_dn_exist_r[0],pu_lf_exist_r,pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                                5'b1???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                    ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                end
                                5'b01??? : begin    ref_pad_d00_r <= ref_raw_l03_r ; ref_pad_d01_r <= ref_raw_l03_r ;
                                                    ref_pad_d02_r <= ref_raw_l03_r ; ref_pad_d03_r <= ref_raw_l03_r ;
                                end
                                5'b001?? : begin    ref_pad_d00_r <= ref_raw_tl_r  ; ref_pad_d01_r <= ref_raw_tl_r  ;
                                                    ref_pad_d02_r <= ref_raw_tl_r  ; ref_pad_d03_r <= ref_raw_tl_r  ;
                                end
                                5'b0001? : begin    ref_pad_d00_r <= ref_raw_t00_r ; ref_pad_d01_r <= ref_raw_t00_r ;
                                                    ref_pad_d02_r <= ref_raw_t00_r ; ref_pad_d03_r <= ref_raw_t00_r ;
                                end
                                5'b00001 : begin    ref_pad_d00_r <= ref_raw_r00_r ; ref_pad_d01_r <= ref_raw_r00_r ;
                                                    ref_pad_d02_r <= ref_raw_r00_r ; ref_pad_d03_r <= ref_raw_r00_r ;
                                end
                              endcase
          end
          `SIZE_08 : begin    casez( {pu_dn_exist_r[1:0],pu_lf_exist_r,pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                                6'b1?_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                      ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                      ref_pad_d04_r <= ref_raw_d04_r ; ref_pad_d05_r <= ref_raw_d05_r ;
                                                      ref_pad_d06_r <= ref_raw_d06_r ; ref_pad_d07_r <= ref_raw_d07_r ;
                                end
                                6'b01_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                      ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                      ref_pad_d04_r <= ref_raw_d03_r ; ref_pad_d05_r <= ref_raw_d03_r ;
                                                      ref_pad_d06_r <= ref_raw_d03_r ; ref_pad_d07_r <= ref_raw_d03_r ;
                                end
                                6'b00_1??? : begin   ref_pad_d00_r <= ref_raw_l07_r ; ref_pad_d01_r <= ref_raw_l07_r ;
                                                     ref_pad_d02_r <= ref_raw_l07_r ; ref_pad_d03_r <= ref_raw_l07_r ;
                                                     ref_pad_d04_r <= ref_raw_l07_r ; ref_pad_d05_r <= ref_raw_l07_r ;
                                                     ref_pad_d06_r <= ref_raw_l07_r ; ref_pad_d07_r <= ref_raw_l07_r ;
                                end
                                6'b00_01?? : begin   ref_pad_d00_r <= ref_raw_tl_r  ; ref_pad_d01_r <= ref_raw_tl_r  ;
                                                     ref_pad_d02_r <= ref_raw_tl_r  ; ref_pad_d03_r <= ref_raw_tl_r  ;
                                                     ref_pad_d04_r <= ref_raw_tl_r  ; ref_pad_d05_r <= ref_raw_tl_r  ;
                                                     ref_pad_d06_r <= ref_raw_tl_r  ; ref_pad_d07_r <= ref_raw_tl_r  ;
                                end 
                                6'b00_001? : begin   ref_pad_d00_r <= ref_raw_t00_r ; ref_pad_d01_r <= ref_raw_t00_r ;
                                                     ref_pad_d02_r <= ref_raw_t00_r ; ref_pad_d03_r <= ref_raw_t00_r ;
                                                     ref_pad_d04_r <= ref_raw_t00_r ; ref_pad_d05_r <= ref_raw_t00_r ;
                                                     ref_pad_d06_r <= ref_raw_t00_r ; ref_pad_d07_r <= ref_raw_t00_r ;

                                end
                                6'b00_0001 : begin   ref_pad_d00_r <= ref_raw_r00_r ; ref_pad_d01_r <= ref_raw_r00_r ;
                                                     ref_pad_d02_r <= ref_raw_r00_r ; ref_pad_d03_r <= ref_raw_r00_r ;
                                                     ref_pad_d04_r <= ref_raw_r00_r ; ref_pad_d05_r <= ref_raw_r00_r ;
                                                     ref_pad_d06_r <= ref_raw_r00_r ; ref_pad_d07_r <= ref_raw_r00_r ;
                                end
                              endcase
          end
          `SIZE_16 : begin    casez( {pu_dn_exist_r[3:0],pu_lf_exist_r,pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                                8'b1???_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                        ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                        ref_pad_d04_r <= ref_raw_d04_r ; ref_pad_d05_r <= ref_raw_d05_r ;
                                                        ref_pad_d06_r <= ref_raw_d06_r ; ref_pad_d07_r <= ref_raw_d07_r ;
                                                        ref_pad_d08_r <= ref_raw_d08_r ; ref_pad_d09_r <= ref_raw_d09_r ;
                                                        ref_pad_d10_r <= ref_raw_d10_r ; ref_pad_d11_r <= ref_raw_d11_r ;
                                                        ref_pad_d12_r <= ref_raw_d12_r ; ref_pad_d13_r <= ref_raw_d13_r ;
                                                        ref_pad_d14_r <= ref_raw_d14_r ; ref_pad_d15_r <= ref_raw_d15_r ;
                                end
                                8'b01??_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                        ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                        ref_pad_d04_r <= ref_raw_d04_r ; ref_pad_d05_r <= ref_raw_d05_r ;
                                                        ref_pad_d06_r <= ref_raw_d06_r ; ref_pad_d07_r <= ref_raw_d07_r ;
                                                        ref_pad_d08_r <= ref_raw_d08_r ; ref_pad_d09_r <= ref_raw_d09_r ;
                                                        ref_pad_d10_r <= ref_raw_d10_r ; ref_pad_d11_r <= ref_raw_d11_r ;
                                                        ref_pad_d12_r <= ref_raw_d11_r ; ref_pad_d13_r <= ref_raw_d11_r ;
                                                        ref_pad_d14_r <= ref_raw_d11_r ; ref_pad_d15_r <= ref_raw_d11_r ;
                                end
                                8'b001?_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                        ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                        ref_pad_d04_r <= ref_raw_d04_r ; ref_pad_d05_r <= ref_raw_d05_r ;
                                                        ref_pad_d06_r <= ref_raw_d06_r ; ref_pad_d07_r <= ref_raw_d07_r ;
                                                        ref_pad_d08_r <= ref_raw_d07_r ; ref_pad_d09_r <= ref_raw_d07_r ;
                                                        ref_pad_d10_r <= ref_raw_d07_r ; ref_pad_d11_r <= ref_raw_d07_r ;
                                                        ref_pad_d12_r <= ref_raw_d07_r ; ref_pad_d13_r <= ref_raw_d07_r ;
                                                        ref_pad_d14_r <= ref_raw_d07_r ; ref_pad_d15_r <= ref_raw_d07_r ;
                                end
                                8'b0001_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                        ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                        ref_pad_d04_r <= ref_raw_d03_r ; ref_pad_d05_r <= ref_raw_d03_r ;
                                                        ref_pad_d06_r <= ref_raw_d03_r ; ref_pad_d07_r <= ref_raw_d03_r ;
                                                        ref_pad_d08_r <= ref_raw_d03_r ; ref_pad_d09_r <= ref_raw_d03_r ;
                                                        ref_pad_d10_r <= ref_raw_d03_r ; ref_pad_d11_r <= ref_raw_d03_r ;
                                                        ref_pad_d12_r <= ref_raw_d03_r ; ref_pad_d13_r <= ref_raw_d03_r ;
                                                        ref_pad_d14_r <= ref_raw_d03_r ; ref_pad_d15_r <= ref_raw_d03_r ;
                                end
                                8'b0000_1??? : begin    ref_pad_d00_r <= ref_raw_l15_r ; ref_pad_d01_r <= ref_raw_l15_r ;
                                                        ref_pad_d02_r <= ref_raw_l15_r ; ref_pad_d03_r <= ref_raw_l15_r ;
                                                        ref_pad_d04_r <= ref_raw_l15_r ; ref_pad_d05_r <= ref_raw_l15_r ;
                                                        ref_pad_d06_r <= ref_raw_l15_r ; ref_pad_d07_r <= ref_raw_l15_r ;
                                                        ref_pad_d08_r <= ref_raw_l15_r ; ref_pad_d09_r <= ref_raw_l15_r ;
                                                        ref_pad_d10_r <= ref_raw_l15_r ; ref_pad_d11_r <= ref_raw_l15_r ;
                                                        ref_pad_d12_r <= ref_raw_l15_r ; ref_pad_d13_r <= ref_raw_l15_r ;
                                                        ref_pad_d14_r <= ref_raw_l15_r ; ref_pad_d15_r <= ref_raw_l15_r ;
                                end
                                8'b0000_01?? : begin    ref_pad_d00_r <= ref_raw_tl_r  ; ref_pad_d01_r <= ref_raw_tl_r  ;
                                                        ref_pad_d02_r <= ref_raw_tl_r  ; ref_pad_d03_r <= ref_raw_tl_r  ;
                                                        ref_pad_d04_r <= ref_raw_tl_r  ; ref_pad_d05_r <= ref_raw_tl_r  ;
                                                        ref_pad_d06_r <= ref_raw_tl_r  ; ref_pad_d07_r <= ref_raw_tl_r  ;
                                                        ref_pad_d08_r <= ref_raw_tl_r  ; ref_pad_d09_r <= ref_raw_tl_r  ;
                                                        ref_pad_d10_r <= ref_raw_tl_r  ; ref_pad_d11_r <= ref_raw_tl_r  ;
                                                        ref_pad_d12_r <= ref_raw_tl_r  ; ref_pad_d13_r <= ref_raw_tl_r  ;
                                                        ref_pad_d14_r <= ref_raw_tl_r  ; ref_pad_d15_r <= ref_raw_tl_r  ;
                                end
                                8'b0000_001? : begin    ref_pad_d00_r <= ref_raw_t00_r ; ref_pad_d01_r <= ref_raw_t00_r ;
                                                        ref_pad_d02_r <= ref_raw_t00_r ; ref_pad_d03_r <= ref_raw_t00_r ;
                                                        ref_pad_d04_r <= ref_raw_t00_r ; ref_pad_d05_r <= ref_raw_t00_r ;
                                                        ref_pad_d06_r <= ref_raw_t00_r ; ref_pad_d07_r <= ref_raw_t00_r ;
                                                        ref_pad_d08_r <= ref_raw_t00_r ; ref_pad_d09_r <= ref_raw_t00_r ;
                                                        ref_pad_d10_r <= ref_raw_t00_r ; ref_pad_d11_r <= ref_raw_t00_r ;
                                                        ref_pad_d12_r <= ref_raw_t00_r ; ref_pad_d13_r <= ref_raw_t00_r ;
                                                        ref_pad_d14_r <= ref_raw_t00_r ; ref_pad_d15_r <= ref_raw_t00_r ;
                                end
                                8'b0000_0001 : begin    ref_pad_d00_r <= ref_raw_r00_r ; ref_pad_d01_r <= ref_raw_r00_r ;
                                                        ref_pad_d02_r <= ref_raw_r00_r ; ref_pad_d03_r <= ref_raw_r00_r ;
                                                        ref_pad_d04_r <= ref_raw_r00_r ; ref_pad_d05_r <= ref_raw_r00_r ;
                                                        ref_pad_d06_r <= ref_raw_r00_r ; ref_pad_d07_r <= ref_raw_r00_r ;
                                                        ref_pad_d08_r <= ref_raw_r00_r ; ref_pad_d09_r <= ref_raw_r00_r ;
                                                        ref_pad_d10_r <= ref_raw_r00_r ; ref_pad_d11_r <= ref_raw_r00_r ;
                                                        ref_pad_d12_r <= ref_raw_r00_r ; ref_pad_d13_r <= ref_raw_r00_r ;
                                                        ref_pad_d14_r <= ref_raw_r00_r ; ref_pad_d15_r <= ref_raw_r00_r ;
                                end
                              endcase
          end
          `SIZE_32 : begin    casez( {pu_dn_exist_r,pu_lf_exist_r,pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                                12'b1???????_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                             ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                             ref_pad_d04_r <= ref_raw_d04_r ; ref_pad_d05_r <= ref_raw_d05_r ;
                                                             ref_pad_d06_r <= ref_raw_d06_r ; ref_pad_d07_r <= ref_raw_d07_r ;
                                                             ref_pad_d08_r <= ref_raw_d08_r ; ref_pad_d09_r <= ref_raw_d09_r ;
                                                             ref_pad_d10_r <= ref_raw_d10_r ; ref_pad_d11_r <= ref_raw_d11_r ;
                                                             ref_pad_d12_r <= ref_raw_d12_r ; ref_pad_d13_r <= ref_raw_d13_r ;
                                                             ref_pad_d14_r <= ref_raw_d14_r ; ref_pad_d15_r <= ref_raw_d15_r ;
                                                             ref_pad_d16_r <= ref_raw_d16_r ; ref_pad_d17_r <= ref_raw_d17_r ;
                                                             ref_pad_d18_r <= ref_raw_d18_r ; ref_pad_d19_r <= ref_raw_d19_r ;
                                                             ref_pad_d20_r <= ref_raw_d20_r ; ref_pad_d21_r <= ref_raw_d21_r ;
                                                             ref_pad_d22_r <= ref_raw_d22_r ; ref_pad_d23_r <= ref_raw_d23_r ;
                                                             ref_pad_d24_r <= ref_raw_d24_r ; ref_pad_d25_r <= ref_raw_d25_r ;
                                                             ref_pad_d26_r <= ref_raw_d26_r ; ref_pad_d27_r <= ref_raw_d27_r ;
                                                             ref_pad_d28_r <= ref_raw_d28_r ; ref_pad_d29_r <= ref_raw_d29_r ;
                                                             ref_pad_d30_r <= ref_raw_d30_r ; ref_pad_d31_r <= ref_raw_d31_r ;
                                end
                                12'b01??????_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                             ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                             ref_pad_d04_r <= ref_raw_d04_r ; ref_pad_d05_r <= ref_raw_d05_r ;
                                                             ref_pad_d06_r <= ref_raw_d06_r ; ref_pad_d07_r <= ref_raw_d07_r ;
                                                             ref_pad_d08_r <= ref_raw_d08_r ; ref_pad_d09_r <= ref_raw_d09_r ;
                                                             ref_pad_d10_r <= ref_raw_d10_r ; ref_pad_d11_r <= ref_raw_d11_r ;
                                                             ref_pad_d12_r <= ref_raw_d12_r ; ref_pad_d13_r <= ref_raw_d13_r ;
                                                             ref_pad_d14_r <= ref_raw_d14_r ; ref_pad_d15_r <= ref_raw_d15_r ;
                                                             ref_pad_d16_r <= ref_raw_d16_r ; ref_pad_d17_r <= ref_raw_d17_r ;
                                                             ref_pad_d18_r <= ref_raw_d18_r ; ref_pad_d19_r <= ref_raw_d19_r ;
                                                             ref_pad_d20_r <= ref_raw_d20_r ; ref_pad_d21_r <= ref_raw_d21_r ;
                                                             ref_pad_d22_r <= ref_raw_d22_r ; ref_pad_d23_r <= ref_raw_d23_r ;
                                                             ref_pad_d24_r <= ref_raw_d24_r ; ref_pad_d25_r <= ref_raw_d25_r ;
                                                             ref_pad_d26_r <= ref_raw_d26_r ; ref_pad_d27_r <= ref_raw_d27_r ;
                                                             ref_pad_d28_r <= ref_raw_d27_r ; ref_pad_d29_r <= ref_raw_d27_r ;
                                                             ref_pad_d30_r <= ref_raw_d27_r ; ref_pad_d31_r <= ref_raw_d27_r ;
                                end
                                12'b001?????_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                             ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                             ref_pad_d04_r <= ref_raw_d04_r ; ref_pad_d05_r <= ref_raw_d05_r ;
                                                             ref_pad_d06_r <= ref_raw_d06_r ; ref_pad_d07_r <= ref_raw_d07_r ;
                                                             ref_pad_d08_r <= ref_raw_d08_r ; ref_pad_d09_r <= ref_raw_d09_r ;
                                                             ref_pad_d10_r <= ref_raw_d10_r ; ref_pad_d11_r <= ref_raw_d11_r ;
                                                             ref_pad_d12_r <= ref_raw_d12_r ; ref_pad_d13_r <= ref_raw_d13_r ;
                                                             ref_pad_d14_r <= ref_raw_d14_r ; ref_pad_d15_r <= ref_raw_d15_r ;
                                                             ref_pad_d16_r <= ref_raw_d16_r ; ref_pad_d17_r <= ref_raw_d17_r ;
                                                             ref_pad_d18_r <= ref_raw_d18_r ; ref_pad_d19_r <= ref_raw_d19_r ;
                                                             ref_pad_d20_r <= ref_raw_d20_r ; ref_pad_d21_r <= ref_raw_d21_r ;
                                                             ref_pad_d22_r <= ref_raw_d22_r ; ref_pad_d23_r <= ref_raw_d23_r ;
                                                             ref_pad_d24_r <= ref_raw_d23_r ; ref_pad_d25_r <= ref_raw_d23_r ;
                                                             ref_pad_d26_r <= ref_raw_d23_r ; ref_pad_d27_r <= ref_raw_d23_r ;
                                                             ref_pad_d28_r <= ref_raw_d23_r ; ref_pad_d29_r <= ref_raw_d23_r ;
                                                             ref_pad_d30_r <= ref_raw_d23_r ; ref_pad_d31_r <= ref_raw_d23_r ;
                                end
                                12'b0001????_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                             ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                             ref_pad_d04_r <= ref_raw_d04_r ; ref_pad_d05_r <= ref_raw_d05_r ;
                                                             ref_pad_d06_r <= ref_raw_d06_r ; ref_pad_d07_r <= ref_raw_d07_r ;
                                                             ref_pad_d08_r <= ref_raw_d08_r ; ref_pad_d09_r <= ref_raw_d09_r ;
                                                             ref_pad_d10_r <= ref_raw_d10_r ; ref_pad_d11_r <= ref_raw_d11_r ;
                                                             ref_pad_d12_r <= ref_raw_d12_r ; ref_pad_d13_r <= ref_raw_d13_r ;
                                                             ref_pad_d14_r <= ref_raw_d14_r ; ref_pad_d15_r <= ref_raw_d15_r ;
                                                             ref_pad_d16_r <= ref_raw_d16_r ; ref_pad_d17_r <= ref_raw_d17_r ;
                                                             ref_pad_d18_r <= ref_raw_d18_r ; ref_pad_d19_r <= ref_raw_d19_r ;
                                                             ref_pad_d20_r <= ref_raw_d19_r ; ref_pad_d21_r <= ref_raw_d19_r ;
                                                             ref_pad_d22_r <= ref_raw_d19_r ; ref_pad_d23_r <= ref_raw_d19_r ;
                                                             ref_pad_d24_r <= ref_raw_d19_r ; ref_pad_d25_r <= ref_raw_d19_r ;
                                                             ref_pad_d26_r <= ref_raw_d19_r ; ref_pad_d27_r <= ref_raw_d19_r ;
                                                             ref_pad_d28_r <= ref_raw_d19_r ; ref_pad_d29_r <= ref_raw_d19_r ;
                                                             ref_pad_d30_r <= ref_raw_d19_r ; ref_pad_d31_r <= ref_raw_d19_r ;
                                end
                                12'b00001???_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                             ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                             ref_pad_d04_r <= ref_raw_d04_r ; ref_pad_d05_r <= ref_raw_d05_r ;
                                                             ref_pad_d06_r <= ref_raw_d06_r ; ref_pad_d07_r <= ref_raw_d07_r ;
                                                             ref_pad_d08_r <= ref_raw_d08_r ; ref_pad_d09_r <= ref_raw_d09_r ;
                                                             ref_pad_d10_r <= ref_raw_d10_r ; ref_pad_d11_r <= ref_raw_d11_r ;
                                                             ref_pad_d12_r <= ref_raw_d12_r ; ref_pad_d13_r <= ref_raw_d13_r ;
                                                             ref_pad_d14_r <= ref_raw_d14_r ; ref_pad_d15_r <= ref_raw_d15_r ;
                                                             ref_pad_d16_r <= ref_raw_d15_r ; ref_pad_d17_r <= ref_raw_d15_r ;
                                                             ref_pad_d18_r <= ref_raw_d15_r ; ref_pad_d19_r <= ref_raw_d15_r ;
                                                             ref_pad_d20_r <= ref_raw_d15_r ; ref_pad_d21_r <= ref_raw_d15_r ;
                                                             ref_pad_d22_r <= ref_raw_d15_r ; ref_pad_d23_r <= ref_raw_d15_r ;
                                                             ref_pad_d24_r <= ref_raw_d15_r ; ref_pad_d25_r <= ref_raw_d15_r ;
                                                             ref_pad_d26_r <= ref_raw_d15_r ; ref_pad_d27_r <= ref_raw_d15_r ;
                                                             ref_pad_d28_r <= ref_raw_d15_r ; ref_pad_d29_r <= ref_raw_d15_r ;
                                                             ref_pad_d30_r <= ref_raw_d15_r ; ref_pad_d31_r <= ref_raw_d15_r ;
                                end
                                12'b000001??_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                             ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                             ref_pad_d04_r <= ref_raw_d04_r ; ref_pad_d05_r <= ref_raw_d05_r ;
                                                             ref_pad_d06_r <= ref_raw_d06_r ; ref_pad_d07_r <= ref_raw_d07_r ;
                                                             ref_pad_d08_r <= ref_raw_d08_r ; ref_pad_d09_r <= ref_raw_d09_r ;
                                                             ref_pad_d10_r <= ref_raw_d10_r ; ref_pad_d11_r <= ref_raw_d11_r ;
                                                             ref_pad_d12_r <= ref_raw_d11_r ; ref_pad_d13_r <= ref_raw_d11_r ;
                                                             ref_pad_d14_r <= ref_raw_d11_r ; ref_pad_d15_r <= ref_raw_d11_r ;
                                                             ref_pad_d16_r <= ref_raw_d11_r ; ref_pad_d17_r <= ref_raw_d11_r ;
                                                             ref_pad_d18_r <= ref_raw_d11_r ; ref_pad_d19_r <= ref_raw_d11_r ;
                                                             ref_pad_d20_r <= ref_raw_d11_r ; ref_pad_d21_r <= ref_raw_d11_r ;
                                                             ref_pad_d22_r <= ref_raw_d11_r ; ref_pad_d23_r <= ref_raw_d11_r ;
                                                             ref_pad_d24_r <= ref_raw_d11_r ; ref_pad_d25_r <= ref_raw_d11_r ;
                                                             ref_pad_d26_r <= ref_raw_d11_r ; ref_pad_d27_r <= ref_raw_d11_r ;
                                                             ref_pad_d28_r <= ref_raw_d11_r ; ref_pad_d29_r <= ref_raw_d11_r ;
                                                             ref_pad_d30_r <= ref_raw_d11_r ; ref_pad_d31_r <= ref_raw_d11_r ;
                                end
                                12'b0000001?_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                             ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                             ref_pad_d04_r <= ref_raw_d04_r ; ref_pad_d05_r <= ref_raw_d05_r ;
                                                             ref_pad_d06_r <= ref_raw_d06_r ; ref_pad_d07_r <= ref_raw_d07_r ;
                                                             ref_pad_d08_r <= ref_raw_d07_r ; ref_pad_d09_r <= ref_raw_d07_r ;
                                                             ref_pad_d10_r <= ref_raw_d07_r ; ref_pad_d11_r <= ref_raw_d07_r ;
                                                             ref_pad_d12_r <= ref_raw_d07_r ; ref_pad_d13_r <= ref_raw_d07_r ;
                                                             ref_pad_d14_r <= ref_raw_d07_r ; ref_pad_d15_r <= ref_raw_d07_r ;
                                                             ref_pad_d16_r <= ref_raw_d07_r ; ref_pad_d17_r <= ref_raw_d07_r ;
                                                             ref_pad_d18_r <= ref_raw_d07_r ; ref_pad_d19_r <= ref_raw_d07_r ;
                                                             ref_pad_d20_r <= ref_raw_d07_r ; ref_pad_d21_r <= ref_raw_d07_r ;
                                                             ref_pad_d22_r <= ref_raw_d07_r ; ref_pad_d23_r <= ref_raw_d07_r ;
                                                             ref_pad_d24_r <= ref_raw_d07_r ; ref_pad_d25_r <= ref_raw_d07_r ;
                                                             ref_pad_d26_r <= ref_raw_d07_r ; ref_pad_d27_r <= ref_raw_d07_r ;
                                                             ref_pad_d28_r <= ref_raw_d07_r ; ref_pad_d29_r <= ref_raw_d07_r ;
                                                             ref_pad_d30_r <= ref_raw_d07_r ; ref_pad_d31_r <= ref_raw_d07_r ;
                                end
                                12'b00000001_???? : begin    ref_pad_d00_r <= ref_raw_d00_r ; ref_pad_d01_r <= ref_raw_d01_r ;
                                                             ref_pad_d02_r <= ref_raw_d02_r ; ref_pad_d03_r <= ref_raw_d03_r ;
                                                             ref_pad_d04_r <= ref_raw_d03_r ; ref_pad_d05_r <= ref_raw_d03_r ;
                                                             ref_pad_d06_r <= ref_raw_d03_r ; ref_pad_d07_r <= ref_raw_d03_r ;
                                                             ref_pad_d08_r <= ref_raw_d03_r ; ref_pad_d09_r <= ref_raw_d03_r ;
                                                             ref_pad_d10_r <= ref_raw_d03_r ; ref_pad_d11_r <= ref_raw_d03_r ;
                                                             ref_pad_d12_r <= ref_raw_d03_r ; ref_pad_d13_r <= ref_raw_d03_r ;
                                                             ref_pad_d14_r <= ref_raw_d03_r ; ref_pad_d15_r <= ref_raw_d03_r ;
                                                             ref_pad_d16_r <= ref_raw_d03_r ; ref_pad_d17_r <= ref_raw_d03_r ;
                                                             ref_pad_d18_r <= ref_raw_d03_r ; ref_pad_d19_r <= ref_raw_d03_r ;
                                                             ref_pad_d20_r <= ref_raw_d03_r ; ref_pad_d21_r <= ref_raw_d03_r ;
                                                             ref_pad_d22_r <= ref_raw_d03_r ; ref_pad_d23_r <= ref_raw_d03_r ;
                                                             ref_pad_d24_r <= ref_raw_d03_r ; ref_pad_d25_r <= ref_raw_d03_r ;
                                                             ref_pad_d26_r <= ref_raw_d03_r ; ref_pad_d27_r <= ref_raw_d03_r ;
                                                             ref_pad_d28_r <= ref_raw_d03_r ; ref_pad_d29_r <= ref_raw_d03_r ;
                                                             ref_pad_d30_r <= ref_raw_d03_r ; ref_pad_d31_r <= ref_raw_d03_r ;
                                end
                                12'b00000000_1??? : begin    ref_pad_d00_r <= ref_raw_l31_r ; ref_pad_d01_r <= ref_raw_l31_r ;
                                                             ref_pad_d02_r <= ref_raw_l31_r ; ref_pad_d03_r <= ref_raw_l31_r ;
                                                             ref_pad_d04_r <= ref_raw_l31_r ; ref_pad_d05_r <= ref_raw_l31_r ;
                                                             ref_pad_d06_r <= ref_raw_l31_r ; ref_pad_d07_r <= ref_raw_l31_r ;
                                                             ref_pad_d08_r <= ref_raw_l31_r ; ref_pad_d09_r <= ref_raw_l31_r ;
                                                             ref_pad_d10_r <= ref_raw_l31_r ; ref_pad_d11_r <= ref_raw_l31_r ;
                                                             ref_pad_d12_r <= ref_raw_l31_r ; ref_pad_d13_r <= ref_raw_l31_r ;
                                                             ref_pad_d14_r <= ref_raw_l31_r ; ref_pad_d15_r <= ref_raw_l31_r ;
                                                             ref_pad_d16_r <= ref_raw_l31_r ; ref_pad_d17_r <= ref_raw_l31_r ;
                                                             ref_pad_d18_r <= ref_raw_l31_r ; ref_pad_d19_r <= ref_raw_l31_r ;
                                                             ref_pad_d20_r <= ref_raw_l31_r ; ref_pad_d21_r <= ref_raw_l31_r ;
                                                             ref_pad_d22_r <= ref_raw_l31_r ; ref_pad_d23_r <= ref_raw_l31_r ;
                                                             ref_pad_d24_r <= ref_raw_l31_r ; ref_pad_d25_r <= ref_raw_l31_r ;
                                                             ref_pad_d26_r <= ref_raw_l31_r ; ref_pad_d27_r <= ref_raw_l31_r ;
                                                             ref_pad_d28_r <= ref_raw_l31_r ; ref_pad_d29_r <= ref_raw_l31_r ;
                                                             ref_pad_d30_r <= ref_raw_l31_r ; ref_pad_d31_r <= ref_raw_l31_r ;
                                end
                                12'b00000000_01?? : begin    ref_pad_d00_r <= ref_raw_tl_r ; ref_pad_d01_r <= ref_raw_tl_r ;
                                                             ref_pad_d02_r <= ref_raw_tl_r ; ref_pad_d03_r <= ref_raw_tl_r ;
                                                             ref_pad_d04_r <= ref_raw_tl_r ; ref_pad_d05_r <= ref_raw_tl_r ;
                                                             ref_pad_d06_r <= ref_raw_tl_r ; ref_pad_d07_r <= ref_raw_tl_r ;
                                                             ref_pad_d08_r <= ref_raw_tl_r ; ref_pad_d09_r <= ref_raw_tl_r ;
                                                             ref_pad_d10_r <= ref_raw_tl_r ; ref_pad_d11_r <= ref_raw_tl_r ;
                                                             ref_pad_d12_r <= ref_raw_tl_r ; ref_pad_d13_r <= ref_raw_tl_r ;
                                                             ref_pad_d14_r <= ref_raw_tl_r ; ref_pad_d15_r <= ref_raw_tl_r ;
                                                             ref_pad_d16_r <= ref_raw_tl_r ; ref_pad_d17_r <= ref_raw_tl_r ;
                                                             ref_pad_d18_r <= ref_raw_tl_r ; ref_pad_d19_r <= ref_raw_tl_r ;
                                                             ref_pad_d20_r <= ref_raw_tl_r ; ref_pad_d21_r <= ref_raw_tl_r ;
                                                             ref_pad_d22_r <= ref_raw_tl_r ; ref_pad_d23_r <= ref_raw_tl_r ;
                                                             ref_pad_d24_r <= ref_raw_tl_r ; ref_pad_d25_r <= ref_raw_tl_r ;
                                                             ref_pad_d26_r <= ref_raw_tl_r ; ref_pad_d27_r <= ref_raw_tl_r ;
                                                             ref_pad_d28_r <= ref_raw_tl_r ; ref_pad_d29_r <= ref_raw_tl_r ;
                                                             ref_pad_d30_r <= ref_raw_tl_r ; ref_pad_d31_r <= ref_raw_tl_r ;
                                end
                                12'b00000000_001? : begin    ref_pad_d00_r <= ref_raw_t00_r ; ref_pad_d01_r <= ref_raw_t00_r ;
                                                             ref_pad_d02_r <= ref_raw_t00_r ; ref_pad_d03_r <= ref_raw_t00_r ;
                                                             ref_pad_d04_r <= ref_raw_t00_r ; ref_pad_d05_r <= ref_raw_t00_r ;
                                                             ref_pad_d06_r <= ref_raw_t00_r ; ref_pad_d07_r <= ref_raw_t00_r ;
                                                             ref_pad_d08_r <= ref_raw_t00_r ; ref_pad_d09_r <= ref_raw_t00_r ;
                                                             ref_pad_d10_r <= ref_raw_t00_r ; ref_pad_d11_r <= ref_raw_t00_r ;
                                                             ref_pad_d12_r <= ref_raw_t00_r ; ref_pad_d13_r <= ref_raw_t00_r ;
                                                             ref_pad_d14_r <= ref_raw_t00_r ; ref_pad_d15_r <= ref_raw_t00_r ;
                                                             ref_pad_d16_r <= ref_raw_t00_r ; ref_pad_d17_r <= ref_raw_t00_r ;
                                                             ref_pad_d18_r <= ref_raw_t00_r ; ref_pad_d19_r <= ref_raw_t00_r ;
                                                             ref_pad_d20_r <= ref_raw_t00_r ; ref_pad_d21_r <= ref_raw_t00_r ;
                                                             ref_pad_d22_r <= ref_raw_t00_r ; ref_pad_d23_r <= ref_raw_t00_r ;
                                                             ref_pad_d24_r <= ref_raw_t00_r ; ref_pad_d25_r <= ref_raw_t00_r ;
                                                             ref_pad_d26_r <= ref_raw_t00_r ; ref_pad_d27_r <= ref_raw_t00_r ;
                                                             ref_pad_d28_r <= ref_raw_t00_r ; ref_pad_d29_r <= ref_raw_t00_r ;
                                                             ref_pad_d30_r <= ref_raw_t00_r ; ref_pad_d31_r <= ref_raw_t00_r ;
                                end
                                12'b00000000_0001 : begin    ref_pad_d00_r <= ref_raw_r00_r ; ref_pad_d01_r <= ref_raw_r00_r ;
                                                             ref_pad_d02_r <= ref_raw_r00_r ; ref_pad_d03_r <= ref_raw_r00_r ;
                                                             ref_pad_d04_r <= ref_raw_r00_r ; ref_pad_d05_r <= ref_raw_r00_r ;
                                                             ref_pad_d06_r <= ref_raw_r00_r ; ref_pad_d07_r <= ref_raw_r00_r ;
                                                             ref_pad_d08_r <= ref_raw_r00_r ; ref_pad_d09_r <= ref_raw_r00_r ;
                                                             ref_pad_d10_r <= ref_raw_r00_r ; ref_pad_d11_r <= ref_raw_r00_r ;
                                                             ref_pad_d12_r <= ref_raw_r00_r ; ref_pad_d13_r <= ref_raw_r00_r ;
                                                             ref_pad_d14_r <= ref_raw_r00_r ; ref_pad_d15_r <= ref_raw_r00_r ;
                                                             ref_pad_d16_r <= ref_raw_r00_r ; ref_pad_d17_r <= ref_raw_r00_r ;
                                                             ref_pad_d18_r <= ref_raw_r00_r ; ref_pad_d19_r <= ref_raw_r00_r ;
                                                             ref_pad_d20_r <= ref_raw_r00_r ; ref_pad_d21_r <= ref_raw_r00_r ;
                                                             ref_pad_d22_r <= ref_raw_r00_r ; ref_pad_d23_r <= ref_raw_r00_r ;
                                                             ref_pad_d24_r <= ref_raw_r00_r ; ref_pad_d25_r <= ref_raw_r00_r ;
                                                             ref_pad_d26_r <= ref_raw_r00_r ; ref_pad_d27_r <= ref_raw_r00_r ;
                                                             ref_pad_d28_r <= ref_raw_r00_r ; ref_pad_d29_r <= ref_raw_r00_r ;
                                                             ref_pad_d30_r <= ref_raw_r00_r ; ref_pad_d31_r <= ref_raw_r00_r ;
                                end
                              endcase
          end
        endcase
      end
    end
  end

  // left
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_pad_l00_r <= DAT_DEF ; ref_pad_l01_r <= DAT_DEF ;
      ref_pad_l02_r <= DAT_DEF ; ref_pad_l03_r <= DAT_DEF ;
      ref_pad_l04_r <= DAT_DEF ; ref_pad_l05_r <= DAT_DEF ;
      ref_pad_l06_r <= DAT_DEF ; ref_pad_l07_r <= DAT_DEF ;
      ref_pad_l08_r <= DAT_DEF ; ref_pad_l09_r <= DAT_DEF ;
      ref_pad_l10_r <= DAT_DEF ; ref_pad_l11_r <= DAT_DEF ;
      ref_pad_l12_r <= DAT_DEF ; ref_pad_l13_r <= DAT_DEF ;
      ref_pad_l14_r <= DAT_DEF ; ref_pad_l15_r <= DAT_DEF ;
      ref_pad_l16_r <= DAT_DEF ; ref_pad_l17_r <= DAT_DEF ;
      ref_pad_l18_r <= DAT_DEF ; ref_pad_l19_r <= DAT_DEF ;
      ref_pad_l20_r <= DAT_DEF ; ref_pad_l21_r <= DAT_DEF ;
      ref_pad_l22_r <= DAT_DEF ; ref_pad_l23_r <= DAT_DEF ;
      ref_pad_l24_r <= DAT_DEF ; ref_pad_l25_r <= DAT_DEF ;
      ref_pad_l26_r <= DAT_DEF ; ref_pad_l27_r <= DAT_DEF ;
      ref_pad_l28_r <= DAT_DEF ; ref_pad_l29_r <= DAT_DEF ;
      ref_pad_l30_r <= DAT_DEF ; ref_pad_l31_r <= DAT_DEF ;
    end
    else begin
      if( start_pad_w ) begin
        ref_pad_l00_r <= DAT_DEF ; ref_pad_l01_r <= DAT_DEF ;
        ref_pad_l02_r <= DAT_DEF ; ref_pad_l03_r <= DAT_DEF ;
        ref_pad_l04_r <= DAT_DEF ; ref_pad_l05_r <= DAT_DEF ;
        ref_pad_l06_r <= DAT_DEF ; ref_pad_l07_r <= DAT_DEF ;
        ref_pad_l08_r <= DAT_DEF ; ref_pad_l09_r <= DAT_DEF ;
        ref_pad_l10_r <= DAT_DEF ; ref_pad_l11_r <= DAT_DEF ;
        ref_pad_l12_r <= DAT_DEF ; ref_pad_l13_r <= DAT_DEF ;
        ref_pad_l14_r <= DAT_DEF ; ref_pad_l15_r <= DAT_DEF ;
        ref_pad_l16_r <= DAT_DEF ; ref_pad_l17_r <= DAT_DEF ;
        ref_pad_l18_r <= DAT_DEF ; ref_pad_l19_r <= DAT_DEF ;
        ref_pad_l20_r <= DAT_DEF ; ref_pad_l21_r <= DAT_DEF ;
        ref_pad_l22_r <= DAT_DEF ; ref_pad_l23_r <= DAT_DEF ;
        ref_pad_l24_r <= DAT_DEF ; ref_pad_l25_r <= DAT_DEF ;
        ref_pad_l26_r <= DAT_DEF ; ref_pad_l27_r <= DAT_DEF ;
        ref_pad_l28_r <= DAT_DEF ; ref_pad_l29_r <= DAT_DEF ;
        ref_pad_l30_r <= DAT_DEF ; ref_pad_l31_r <= DAT_DEF ;
        case( size_d2_r )
          `SIZE_04 : begin    casez( {pu_lf_exist_r,pu_dn_exist_r[0],pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                                5'b1???? : begin    ref_pad_l00_r <= ref_raw_l00_r ; ref_pad_l01_r <= ref_raw_l01_r ;
                                                    ref_pad_l02_r <= ref_raw_l02_r ; ref_pad_l03_r <= ref_raw_l03_r ;
                                end
                                5'b01??? : begin    ref_pad_l00_r <= ref_raw_d00_r ; ref_pad_l01_r <= ref_raw_d00_r ;
                                                    ref_pad_l02_r <= ref_raw_d00_r ; ref_pad_l03_r <= ref_raw_d00_r ;
                                end
                                5'b001?? : begin    ref_pad_l00_r <= ref_raw_tl_r  ; ref_pad_l01_r <= ref_raw_tl_r  ;
                                                    ref_pad_l02_r <= ref_raw_tl_r  ; ref_pad_l03_r <= ref_raw_tl_r  ;
                                end
                                5'b0001? : begin    ref_pad_l00_r <= ref_raw_t00_r ; ref_pad_l01_r <= ref_raw_t00_r ;
                                                    ref_pad_l02_r <= ref_raw_t00_r ; ref_pad_l03_r <= ref_raw_t00_r ;
                                end
                                5'b00001 : begin    ref_pad_l00_r <= ref_raw_r00_r ; ref_pad_l01_r <= ref_raw_r00_r ;
                                                    ref_pad_l02_r <= ref_raw_r00_r ; ref_pad_l03_r <= ref_raw_r00_r ;
                                end
                              endcase
          end
          `SIZE_08 : begin    casez( {pu_lf_exist_r,pu_dn_exist_r[0],pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                                5'b1???? : begin    ref_pad_l00_r <= ref_raw_l00_r ; ref_pad_l01_r <= ref_raw_l01_r ;
                                                    ref_pad_l02_r <= ref_raw_l02_r ; ref_pad_l03_r <= ref_raw_l03_r ;
                                                    ref_pad_l04_r <= ref_raw_l04_r ; ref_pad_l05_r <= ref_raw_l05_r ;
                                                    ref_pad_l06_r <= ref_raw_l06_r ; ref_pad_l07_r <= ref_raw_l07_r ;
                                end
                                5'b01??? : begin    ref_pad_l00_r <= ref_raw_d00_r ; ref_pad_l01_r <= ref_raw_d00_r ;
                                                    ref_pad_l02_r <= ref_raw_d00_r ; ref_pad_l03_r <= ref_raw_d00_r ;
                                                    ref_pad_l04_r <= ref_raw_d00_r ; ref_pad_l05_r <= ref_raw_d00_r ;
                                                    ref_pad_l06_r <= ref_raw_d00_r ; ref_pad_l07_r <= ref_raw_d00_r ;
                                end
                                5'b001?? : begin    ref_pad_l00_r <= ref_raw_tl_r  ; ref_pad_l01_r <= ref_raw_tl_r  ;
                                                    ref_pad_l02_r <= ref_raw_tl_r  ; ref_pad_l03_r <= ref_raw_tl_r  ;
                                                    ref_pad_l04_r <= ref_raw_tl_r  ; ref_pad_l05_r <= ref_raw_tl_r  ;
                                                    ref_pad_l06_r <= ref_raw_tl_r  ; ref_pad_l07_r <= ref_raw_tl_r  ;
                                end
                                5'b0001? : begin    ref_pad_l00_r <= ref_raw_t00_r ; ref_pad_l01_r <= ref_raw_t00_r ;
                                                    ref_pad_l02_r <= ref_raw_t00_r ; ref_pad_l03_r <= ref_raw_t00_r ;
                                                    ref_pad_l04_r <= ref_raw_t00_r ; ref_pad_l05_r <= ref_raw_t00_r ;
                                                    ref_pad_l06_r <= ref_raw_t00_r ; ref_pad_l07_r <= ref_raw_t00_r ;
                                end
                                5'b00001 : begin    ref_pad_l00_r <= ref_raw_r00_r ; ref_pad_l01_r <= ref_raw_r00_r ;
                                                    ref_pad_l02_r <= ref_raw_r00_r ; ref_pad_l03_r <= ref_raw_r00_r ;
                                                    ref_pad_l04_r <= ref_raw_r00_r ; ref_pad_l05_r <= ref_raw_r00_r ;
                                                    ref_pad_l06_r <= ref_raw_r00_r ; ref_pad_l07_r <= ref_raw_r00_r ;
                                end
                              endcase
          end
          `SIZE_16 : begin    casez( {pu_lf_exist_r,pu_dn_exist_r[0],pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                                5'b1???? : begin    ref_pad_l00_r <= ref_raw_l00_r ; ref_pad_l01_r <= ref_raw_l01_r ;
                                                    ref_pad_l02_r <= ref_raw_l02_r ; ref_pad_l03_r <= ref_raw_l03_r ;
                                                    ref_pad_l04_r <= ref_raw_l04_r ; ref_pad_l05_r <= ref_raw_l05_r ;
                                                    ref_pad_l06_r <= ref_raw_l06_r ; ref_pad_l07_r <= ref_raw_l07_r ;
                                                    ref_pad_l08_r <= ref_raw_l08_r ; ref_pad_l09_r <= ref_raw_l09_r ;
                                                    ref_pad_l10_r <= ref_raw_l10_r ; ref_pad_l11_r <= ref_raw_l11_r ;
                                                    ref_pad_l12_r <= ref_raw_l12_r ; ref_pad_l13_r <= ref_raw_l13_r ;
                                                    ref_pad_l14_r <= ref_raw_l14_r ; ref_pad_l15_r <= ref_raw_l15_r ;
                                end
                                5'b01??? : begin    ref_pad_l00_r <= ref_raw_d00_r ; ref_pad_l01_r <= ref_raw_d00_r ;
                                                    ref_pad_l02_r <= ref_raw_d00_r ; ref_pad_l03_r <= ref_raw_d00_r ;
                                                    ref_pad_l04_r <= ref_raw_d00_r ; ref_pad_l05_r <= ref_raw_d00_r ;
                                                    ref_pad_l06_r <= ref_raw_d00_r ; ref_pad_l07_r <= ref_raw_d00_r ;
                                                    ref_pad_l08_r <= ref_raw_d00_r ; ref_pad_l09_r <= ref_raw_d00_r ;
                                                    ref_pad_l10_r <= ref_raw_d00_r ; ref_pad_l11_r <= ref_raw_d00_r ;
                                                    ref_pad_l12_r <= ref_raw_d00_r ; ref_pad_l13_r <= ref_raw_d00_r ;
                                                    ref_pad_l14_r <= ref_raw_d00_r ; ref_pad_l15_r <= ref_raw_d00_r ;
                                end
                                5'b001?? : begin    ref_pad_l00_r <= ref_raw_tl_r  ; ref_pad_l01_r <= ref_raw_tl_r  ;
                                                    ref_pad_l02_r <= ref_raw_tl_r  ; ref_pad_l03_r <= ref_raw_tl_r  ;
                                                    ref_pad_l04_r <= ref_raw_tl_r  ; ref_pad_l05_r <= ref_raw_tl_r  ;
                                                    ref_pad_l06_r <= ref_raw_tl_r  ; ref_pad_l07_r <= ref_raw_tl_r  ;
                                                    ref_pad_l08_r <= ref_raw_tl_r  ; ref_pad_l09_r <= ref_raw_tl_r  ;
                                                    ref_pad_l10_r <= ref_raw_tl_r  ; ref_pad_l11_r <= ref_raw_tl_r  ;
                                                    ref_pad_l12_r <= ref_raw_tl_r  ; ref_pad_l13_r <= ref_raw_tl_r  ;
                                                    ref_pad_l14_r <= ref_raw_tl_r  ; ref_pad_l15_r <= ref_raw_tl_r  ;
                                end
                                5'b0001? : begin    ref_pad_l00_r <= ref_raw_t00_r ; ref_pad_l01_r <= ref_raw_t00_r ;
                                                    ref_pad_l02_r <= ref_raw_t00_r ; ref_pad_l03_r <= ref_raw_t00_r ;
                                                    ref_pad_l04_r <= ref_raw_t00_r ; ref_pad_l05_r <= ref_raw_t00_r ;
                                                    ref_pad_l06_r <= ref_raw_t00_r ; ref_pad_l07_r <= ref_raw_t00_r ;
                                                    ref_pad_l08_r <= ref_raw_t00_r ; ref_pad_l09_r <= ref_raw_t00_r ;
                                                    ref_pad_l10_r <= ref_raw_t00_r ; ref_pad_l11_r <= ref_raw_t00_r ;
                                                    ref_pad_l12_r <= ref_raw_t00_r ; ref_pad_l13_r <= ref_raw_t00_r ;
                                                    ref_pad_l14_r <= ref_raw_t00_r ; ref_pad_l15_r <= ref_raw_t00_r ;
                                end
                                5'b00001 : begin    ref_pad_l00_r <= ref_raw_r00_r ; ref_pad_l01_r <= ref_raw_r00_r ;
                                                    ref_pad_l02_r <= ref_raw_r00_r ; ref_pad_l03_r <= ref_raw_r00_r ;
                                                    ref_pad_l04_r <= ref_raw_r00_r ; ref_pad_l05_r <= ref_raw_r00_r ;
                                                    ref_pad_l06_r <= ref_raw_r00_r ; ref_pad_l07_r <= ref_raw_r00_r ;
                                                    ref_pad_l08_r <= ref_raw_r00_r ; ref_pad_l09_r <= ref_raw_r00_r ;
                                                    ref_pad_l10_r <= ref_raw_r00_r ; ref_pad_l11_r <= ref_raw_r00_r ;
                                                    ref_pad_l12_r <= ref_raw_r00_r ; ref_pad_l13_r <= ref_raw_r00_r ;
                                                    ref_pad_l14_r <= ref_raw_r00_r ; ref_pad_l15_r <= ref_raw_r00_r ;
                                end
                              endcase
          end
          `SIZE_32 : begin    casez( {pu_lf_exist_r,pu_dn_exist_r[0],pu_tl_exist_r,pu_tp_exist_r,pu_rt_exist_r[0]} )
                                5'b1???? : begin    ref_pad_l00_r <= ref_raw_l00_r ; ref_pad_l01_r <= ref_raw_l01_r ;
                                                    ref_pad_l02_r <= ref_raw_l02_r ; ref_pad_l03_r <= ref_raw_l03_r ;
                                                    ref_pad_l04_r <= ref_raw_l04_r ; ref_pad_l05_r <= ref_raw_l05_r ;
                                                    ref_pad_l06_r <= ref_raw_l06_r ; ref_pad_l07_r <= ref_raw_l07_r ;
                                                    ref_pad_l08_r <= ref_raw_l08_r ; ref_pad_l09_r <= ref_raw_l09_r ;
                                                    ref_pad_l10_r <= ref_raw_l10_r ; ref_pad_l11_r <= ref_raw_l11_r ;
                                                    ref_pad_l12_r <= ref_raw_l12_r ; ref_pad_l13_r <= ref_raw_l13_r ;
                                                    ref_pad_l14_r <= ref_raw_l14_r ; ref_pad_l15_r <= ref_raw_l15_r ;
                                                    ref_pad_l16_r <= ref_raw_l16_r ; ref_pad_l17_r <= ref_raw_l17_r ;
                                                    ref_pad_l18_r <= ref_raw_l18_r ; ref_pad_l19_r <= ref_raw_l19_r ;
                                                    ref_pad_l20_r <= ref_raw_l20_r ; ref_pad_l21_r <= ref_raw_l21_r ;
                                                    ref_pad_l22_r <= ref_raw_l22_r ; ref_pad_l23_r <= ref_raw_l23_r ;
                                                    ref_pad_l24_r <= ref_raw_l24_r ; ref_pad_l25_r <= ref_raw_l25_r ;
                                                    ref_pad_l26_r <= ref_raw_l26_r ; ref_pad_l27_r <= ref_raw_l27_r ;
                                                    ref_pad_l28_r <= ref_raw_l28_r ; ref_pad_l29_r <= ref_raw_l29_r ;
                                                    ref_pad_l30_r <= ref_raw_l30_r ; ref_pad_l31_r <= ref_raw_l31_r ;
                                end
                                5'b01??? : begin    ref_pad_l00_r <= ref_raw_d00_r ; ref_pad_l01_r <= ref_raw_d00_r ;
                                                    ref_pad_l02_r <= ref_raw_d00_r ; ref_pad_l03_r <= ref_raw_d00_r ;
                                                    ref_pad_l04_r <= ref_raw_d00_r ; ref_pad_l05_r <= ref_raw_d00_r ;
                                                    ref_pad_l06_r <= ref_raw_d00_r ; ref_pad_l07_r <= ref_raw_d00_r ;
                                                    ref_pad_l08_r <= ref_raw_d00_r ; ref_pad_l09_r <= ref_raw_d00_r ;
                                                    ref_pad_l10_r <= ref_raw_d00_r ; ref_pad_l11_r <= ref_raw_d00_r ;
                                                    ref_pad_l12_r <= ref_raw_d00_r ; ref_pad_l13_r <= ref_raw_d00_r ;
                                                    ref_pad_l14_r <= ref_raw_d00_r ; ref_pad_l15_r <= ref_raw_d00_r ;
                                                    ref_pad_l16_r <= ref_raw_d00_r ; ref_pad_l17_r <= ref_raw_d00_r ;
                                                    ref_pad_l18_r <= ref_raw_d00_r ; ref_pad_l19_r <= ref_raw_d00_r ;
                                                    ref_pad_l20_r <= ref_raw_d00_r ; ref_pad_l21_r <= ref_raw_d00_r ;
                                                    ref_pad_l22_r <= ref_raw_d00_r ; ref_pad_l23_r <= ref_raw_d00_r ;
                                                    ref_pad_l24_r <= ref_raw_d00_r ; ref_pad_l25_r <= ref_raw_d00_r ;
                                                    ref_pad_l26_r <= ref_raw_d00_r ; ref_pad_l27_r <= ref_raw_d00_r ;
                                                    ref_pad_l28_r <= ref_raw_d00_r ; ref_pad_l29_r <= ref_raw_d00_r ;
                                                    ref_pad_l30_r <= ref_raw_d00_r ; ref_pad_l31_r <= ref_raw_d00_r ;
                                end
                                5'b001?? : begin    ref_pad_l00_r <= ref_raw_tl_r  ; ref_pad_l01_r <= ref_raw_tl_r  ;
                                                    ref_pad_l02_r <= ref_raw_tl_r  ; ref_pad_l03_r <= ref_raw_tl_r  ;
                                                    ref_pad_l04_r <= ref_raw_tl_r  ; ref_pad_l05_r <= ref_raw_tl_r  ;
                                                    ref_pad_l06_r <= ref_raw_tl_r  ; ref_pad_l07_r <= ref_raw_tl_r  ;
                                                    ref_pad_l08_r <= ref_raw_tl_r  ; ref_pad_l09_r <= ref_raw_tl_r  ;
                                                    ref_pad_l10_r <= ref_raw_tl_r  ; ref_pad_l11_r <= ref_raw_tl_r  ;
                                                    ref_pad_l12_r <= ref_raw_tl_r  ; ref_pad_l13_r <= ref_raw_tl_r  ;
                                                    ref_pad_l14_r <= ref_raw_tl_r  ; ref_pad_l15_r <= ref_raw_tl_r  ;
                                                    ref_pad_l16_r <= ref_raw_tl_r  ; ref_pad_l17_r <= ref_raw_tl_r  ;
                                                    ref_pad_l18_r <= ref_raw_tl_r  ; ref_pad_l19_r <= ref_raw_tl_r  ;
                                                    ref_pad_l20_r <= ref_raw_tl_r  ; ref_pad_l21_r <= ref_raw_tl_r  ;
                                                    ref_pad_l22_r <= ref_raw_tl_r  ; ref_pad_l23_r <= ref_raw_tl_r  ;
                                                    ref_pad_l24_r <= ref_raw_tl_r  ; ref_pad_l25_r <= ref_raw_tl_r  ;
                                                    ref_pad_l26_r <= ref_raw_tl_r  ; ref_pad_l27_r <= ref_raw_tl_r  ;
                                                    ref_pad_l28_r <= ref_raw_tl_r  ; ref_pad_l29_r <= ref_raw_tl_r  ;
                                                    ref_pad_l30_r <= ref_raw_tl_r  ; ref_pad_l31_r <= ref_raw_tl_r  ;
                                end
                                5'b0001? : begin    ref_pad_l00_r <= ref_raw_t00_r ; ref_pad_l01_r <= ref_raw_t00_r ;
                                                    ref_pad_l02_r <= ref_raw_t00_r ; ref_pad_l03_r <= ref_raw_t00_r ;
                                                    ref_pad_l04_r <= ref_raw_t00_r ; ref_pad_l05_r <= ref_raw_t00_r ;
                                                    ref_pad_l06_r <= ref_raw_t00_r ; ref_pad_l07_r <= ref_raw_t00_r ;
                                                    ref_pad_l08_r <= ref_raw_t00_r ; ref_pad_l09_r <= ref_raw_t00_r ;
                                                    ref_pad_l10_r <= ref_raw_t00_r ; ref_pad_l11_r <= ref_raw_t00_r ;
                                                    ref_pad_l12_r <= ref_raw_t00_r ; ref_pad_l13_r <= ref_raw_t00_r ;
                                                    ref_pad_l14_r <= ref_raw_t00_r ; ref_pad_l15_r <= ref_raw_t00_r ;
                                                    ref_pad_l16_r <= ref_raw_t00_r ; ref_pad_l17_r <= ref_raw_t00_r ;
                                                    ref_pad_l18_r <= ref_raw_t00_r ; ref_pad_l19_r <= ref_raw_t00_r ;
                                                    ref_pad_l20_r <= ref_raw_t00_r ; ref_pad_l21_r <= ref_raw_t00_r ;
                                                    ref_pad_l22_r <= ref_raw_t00_r ; ref_pad_l23_r <= ref_raw_t00_r ;
                                                    ref_pad_l24_r <= ref_raw_t00_r ; ref_pad_l25_r <= ref_raw_t00_r ;
                                                    ref_pad_l26_r <= ref_raw_t00_r ; ref_pad_l27_r <= ref_raw_t00_r ;
                                                    ref_pad_l28_r <= ref_raw_t00_r ; ref_pad_l29_r <= ref_raw_t00_r ;
                                                    ref_pad_l30_r <= ref_raw_t00_r ; ref_pad_l31_r <= ref_raw_t00_r ;
                                end
                                5'b00001 : begin    ref_pad_l00_r <= ref_raw_r00_r ; ref_pad_l01_r <= ref_raw_r00_r ;
                                                    ref_pad_l02_r <= ref_raw_r00_r ; ref_pad_l03_r <= ref_raw_r00_r ;
                                                    ref_pad_l04_r <= ref_raw_r00_r ; ref_pad_l05_r <= ref_raw_r00_r ;
                                                    ref_pad_l06_r <= ref_raw_r00_r ; ref_pad_l07_r <= ref_raw_r00_r ;
                                                    ref_pad_l08_r <= ref_raw_r00_r ; ref_pad_l09_r <= ref_raw_r00_r ;
                                                    ref_pad_l10_r <= ref_raw_r00_r ; ref_pad_l11_r <= ref_raw_r00_r ;
                                                    ref_pad_l12_r <= ref_raw_r00_r ; ref_pad_l13_r <= ref_raw_r00_r ;
                                                    ref_pad_l14_r <= ref_raw_r00_r ; ref_pad_l15_r <= ref_raw_r00_r ;
                                                    ref_pad_l16_r <= ref_raw_r00_r ; ref_pad_l17_r <= ref_raw_r00_r ;
                                                    ref_pad_l18_r <= ref_raw_r00_r ; ref_pad_l19_r <= ref_raw_r00_r ;
                                                    ref_pad_l20_r <= ref_raw_r00_r ; ref_pad_l21_r <= ref_raw_r00_r ;
                                                    ref_pad_l22_r <= ref_raw_r00_r ; ref_pad_l23_r <= ref_raw_r00_r ;
                                                    ref_pad_l24_r <= ref_raw_r00_r ; ref_pad_l25_r <= ref_raw_r00_r ;
                                                    ref_pad_l26_r <= ref_raw_r00_r ; ref_pad_l27_r <= ref_raw_r00_r ;
                                                    ref_pad_l28_r <= ref_raw_r00_r ; ref_pad_l29_r <= ref_raw_r00_r ;
                                                    ref_pad_l30_r <= ref_raw_r00_r ; ref_pad_l31_r <= ref_raw_r00_r ;
                                end
                              endcase
          end
        endcase
      end
    end
  end


//--- FLT_PRE_2 ------------------------
  // cur_state_flt_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_state_flt_r <= FLT_IDLE ;
    end
    else begin
      cur_state_flt_r <= nxt_state_flt_w ;
    end
  end

  // nxt_state_flt_w
  always @(*) begin
                                                        nxt_state_flt_w = FLT_IDLE ;
    case( cur_state_flt_r )
      FLT_IDLE : begin    if( start_flt_pre_w )         nxt_state_flt_w = FLT_BUSY ;
                          else                          nxt_state_flt_w = FLT_IDLE ;
      end
      FLT_BUSY : begin    if( start_flt_pre_w )         nxt_state_flt_w = FLT_BUSY ;
                          else if( done_flt_busy_w )    nxt_state_flt_w = FLT_IDLE ;
                          else                          nxt_state_flt_w = FLT_BUSY ;
      end
    endcase
  end

  // jump condition
  assign start_flt_pre_w = cnt_raw_done_d0_r                 ;
  assign done_flt_busy_w = cnt_flt_done_w && cnt_mode_done_w ;

  // cnt_mode_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_mode_r <= 0 ;
    end
    else begin
      if( start_flt_pre_w || (cur_state_flt_r==FLT_BUSY) ) begin
        if( cnt_flt_done_w ) begin
          if( cnt_mode_done_w ) begin
            cnt_mode_r <= 0 ;
          end
          else begin
            cnt_mode_r <= cnt_mode_r + 1 ;
          end
        end
      end
      else begin
        cnt_mode_r <= 0 ;
      end
    end
  end

  // cnt_mode_done_w
  assign cnt_mode_done_w = cnt_mode_r == num_mode_i ;

  // cnt_flt_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_flt_r <= 0 ;
    end
    else begin
      if( start_flt_pre_w || (cur_state_flt_r==FLT_BUSY) ) begin
        if( cnt_flt_done_w ) begin
          cnt_flt_r <= 0 ;
        end
        else begin
          cnt_flt_r <= cnt_flt_r + 1 ;
        end
      end
    end
  end

  // cnt_flt_done_w
  always @(*) begin
    case( size_i )
      `SIZE_04 :    cnt_flt_done_w = cnt_flt_r == (04*04/16-1) ;
      `SIZE_08 :    cnt_flt_done_w = cnt_flt_r == (08*08/16-1) ;
      `SIZE_16 :    cnt_flt_done_w = cnt_flt_r == (16*16/16-1) ;
      `SIZE_32 :    cnt_flt_done_w = cnt_flt_r == (32*32/16-1) ;
    endcase
  end

  // mod_rd_ena
  always @(posedge clk or negedge rstn ) begin    // TODO: optimize address mapping
    if( !rstn ) begin
      mod_rd_ena_o <= 0 ;
    end
    else begin
      if( start_flt_pre_w || (cur_state_flt_r==FLT_BUSY) ) begin
        if( start_flt_pre_w || (cnt_flt_done_w&&!cnt_mode_done_w) ) begin
          mod_rd_ena_o <= 1 ;
        end
        else begin
          mod_rd_ena_o <= 0 ;
        end
      end
      else begin
        mod_rd_ena_o <= 0 ;
      end
    end
  end

  // mod_rd_adr
  always @(posedge clk or negedge rstn ) begin    // TODO: optimize address mapping
    if( !rstn ) begin
      mod_rd_adr_o <= 0 ;
    end
    else begin
      if( start_flt_pre_w || (cur_state_flt_r==FLT_BUSY) ) begin
        if( start_flt_pre_w ) begin
          mod_rd_adr_o <= mod_rd_adr_offset_w ;
        end
        else if( cnt_flt_done_w && !cnt_mode_done_w ) begin
          mod_rd_adr_o <= 340*(cnt_flt_r+3'd1) + mod_rd_adr_offset_w ;
        end
      end
      else begin
        mod_rd_adr_o <= 0 ;
      end
    end
  end

  // mod_rd_adr_offset_w
  always @(*) begin
    case( size_d0_r )
      `SIZE_32 :    mod_rd_adr_offset_w =               position_d0_r[7:6] ; // { idx_4x4_y_d0_r[3  ] ,idx_4x4_x_d0_r[3  ] };
      `SIZE_16 :    mod_rd_adr_offset_w = 4 +           position_d0_r[7:4] ; // { idx_4x4_y_d0_r[3:2] ,idx_4x4_x_d0_r[3:2] };
      `SIZE_08 :    mod_rd_adr_offset_w = 4 + 16 +      position_d0_r[7:2] ; // { idx_4x4_y_d0_r[3:1] ,idx_4x4_x_d0_r[3:1] };
      `SIZE_04 :    mod_rd_adr_offset_w = 4 + 16 + 64 + position_d0_r[7:0] ; // { idx_4x4_y_d0_r      ,idx_4x4_x_d0_r      };
    endcase
  end


//--- FLT_PRE_1 ------------------------
  // mod_rd_dat_i


//--- FLT_PRE_0 ------------------------
  // mode_valid_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      mode_valid_r <= 0 ;
    end
    else begin
      mode_valid_r <= mod_rd_ena_o ;
    end
  end

  // flag
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      flt_flag_r <= 0;
    end
    else begin
      if( mode_valid_r ) begin
        case( size_d2_r )
          `SIZE_04 :                                    flt_flag_r <= 0 ;
          `SIZE_08 : begin    case( mod_rd_dat_i )
                                0,2,18,34          :    flt_flag_r <= 1 ;
                                default            :    flt_flag_r <= 0 ;
                              endcase
          end
          `SIZE_16 : begin    case( mod_rd_dat_i )
                                1,9,10,11,25,26,27 :    flt_flag_r <= 0 ;
                                default            :    flt_flag_r <= 1 ;
                              endcase
          end
          `SIZE_32 : begin    case( mod_rd_dat_i )
                                1,10,26            :    flt_flag_r <= 0 ;
                                default            :    flt_flag_r <= 1 ;
                              endcase
          end
        endcase
      end
    end
  end

  // mod_rd_dat_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      mod_rd_dat_r <= 0 ;
    end
    else begin
      if( mode_valid_r ) begin
        mod_rd_dat_r <= mod_rd_dat_i ;
      end
    end
  end


//--- FLT ------------------------------
  // start_flt_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      start_flt_r <= 0 ;
    end
    else begin
      start_flt_r <= mode_valid_r ;
    end
  end

  // top-left
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_flt_tl_r <= 0 ;
    end
    else begin
      if( start_flt_r ) begin
        if( flt_flag_r ) begin
          ref_flt_tl_r <= ( ref_pad_l00_r+(ref_pad_tl_r<<1)+ref_pad_t00_r+2 )>>2 ;
        end
        else begin
          ref_flt_tl_r <= ref_pad_tl_r ;
        end
      end
    end
  end

  // top
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_flt_t00_r <= 0 ; ref_flt_t01_r <= 0 ;
      ref_flt_t02_r <= 0 ; ref_flt_t03_r <= 0 ;
      ref_flt_t04_r <= 0 ; ref_flt_t05_r <= 0 ;
      ref_flt_t06_r <= 0 ; ref_flt_t07_r <= 0 ;
      ref_flt_t08_r <= 0 ; ref_flt_t09_r <= 0 ;
      ref_flt_t10_r <= 0 ; ref_flt_t11_r <= 0 ;
      ref_flt_t12_r <= 0 ; ref_flt_t13_r <= 0 ;
      ref_flt_t14_r <= 0 ; ref_flt_t15_r <= 0 ;
      ref_flt_t16_r <= 0 ; ref_flt_t17_r <= 0 ;
      ref_flt_t18_r <= 0 ; ref_flt_t19_r <= 0 ;
      ref_flt_t20_r <= 0 ; ref_flt_t21_r <= 0 ;
      ref_flt_t22_r <= 0 ; ref_flt_t23_r <= 0 ;
      ref_flt_t24_r <= 0 ; ref_flt_t25_r <= 0 ;
      ref_flt_t26_r <= 0 ; ref_flt_t27_r <= 0 ;
      ref_flt_t28_r <= 0 ; ref_flt_t29_r <= 0 ;
      ref_flt_t30_r <= 0 ; ref_flt_t31_r <= 0 ;
    end
    else begin
      if( start_flt_r ) begin
        if( flt_flag_r ) begin
          // 00-06
          ref_flt_t00_r <= ( ref_pad_t01_r+(ref_pad_t00_r<<1)+ref_pad_tl_r +2 )>>2 ;
          ref_flt_t01_r <= ( ref_pad_t02_r+(ref_pad_t01_r<<1)+ref_pad_t00_r+2 )>>2 ;
          ref_flt_t02_r <= ( ref_pad_t03_r+(ref_pad_t02_r<<1)+ref_pad_t01_r+2 )>>2 ;
          ref_flt_t03_r <= ( ref_pad_t04_r+(ref_pad_t03_r<<1)+ref_pad_t02_r+2 )>>2 ;
          ref_flt_t04_r <= ( ref_pad_t05_r+(ref_pad_t04_r<<1)+ref_pad_t03_r+2 )>>2 ;
          ref_flt_t05_r <= ( ref_pad_t06_r+(ref_pad_t05_r<<1)+ref_pad_t04_r+2 )>>2 ;
          ref_flt_t06_r <= ( ref_pad_t07_r+(ref_pad_t06_r<<1)+ref_pad_t05_r+2 )>>2 ;
          // 07
          if( size_d3_r==`SIZE_08 ) begin
            ref_flt_t07_r <= ( ref_pad_r00_r+(ref_pad_t07_r<<1)+ref_pad_t06_r+2 )>>2 ;
          end
          else begin
            ref_flt_t07_r <= ( ref_pad_t08_r+(ref_pad_t07_r<<1)+ref_pad_t06_r+2 )>>2 ;
          end
          // 08-14
          ref_flt_t08_r <= ( ref_pad_t09_r+(ref_pad_t08_r<<1)+ref_pad_t07_r+2 )>>2 ;
          ref_flt_t09_r <= ( ref_pad_t10_r+(ref_pad_t09_r<<1)+ref_pad_t08_r+2 )>>2 ;
          ref_flt_t10_r <= ( ref_pad_t11_r+(ref_pad_t10_r<<1)+ref_pad_t09_r+2 )>>2 ;
          ref_flt_t11_r <= ( ref_pad_t12_r+(ref_pad_t11_r<<1)+ref_pad_t10_r+2 )>>2 ;
          ref_flt_t12_r <= ( ref_pad_t13_r+(ref_pad_t12_r<<1)+ref_pad_t11_r+2 )>>2 ;
          ref_flt_t13_r <= ( ref_pad_t14_r+(ref_pad_t13_r<<1)+ref_pad_t12_r+2 )>>2 ;
          ref_flt_t14_r <= ( ref_pad_t15_r+(ref_pad_t14_r<<1)+ref_pad_t13_r+2 )>>2 ;
          // 15
          if( size_d3_r==`SIZE_16 ) begin
            ref_flt_t15_r <= ( ref_pad_r00_r+(ref_pad_t15_r<<1)+ref_pad_t14_r+2 )>>2 ;
          end
          else begin
            ref_flt_t15_r <= ( ref_pad_t16_r+(ref_pad_t15_r<<1)+ref_pad_t14_r+2 )>>2 ;
          end
          // 16-31
          ref_flt_t16_r <= ( ref_pad_t17_r+(ref_pad_t16_r<<1)+ref_pad_t15_r+2 )>>2 ;
          ref_flt_t17_r <= ( ref_pad_t18_r+(ref_pad_t17_r<<1)+ref_pad_t16_r+2 )>>2 ;
          ref_flt_t18_r <= ( ref_pad_t19_r+(ref_pad_t18_r<<1)+ref_pad_t17_r+2 )>>2 ;
          ref_flt_t19_r <= ( ref_pad_t20_r+(ref_pad_t19_r<<1)+ref_pad_t18_r+2 )>>2 ;
          ref_flt_t20_r <= ( ref_pad_t21_r+(ref_pad_t20_r<<1)+ref_pad_t19_r+2 )>>2 ;
          ref_flt_t21_r <= ( ref_pad_t22_r+(ref_pad_t21_r<<1)+ref_pad_t20_r+2 )>>2 ;
          ref_flt_t22_r <= ( ref_pad_t23_r+(ref_pad_t22_r<<1)+ref_pad_t21_r+2 )>>2 ;
          ref_flt_t23_r <= ( ref_pad_t24_r+(ref_pad_t23_r<<1)+ref_pad_t22_r+2 )>>2 ;
          ref_flt_t24_r <= ( ref_pad_t25_r+(ref_pad_t24_r<<1)+ref_pad_t23_r+2 )>>2 ;
          ref_flt_t25_r <= ( ref_pad_t26_r+(ref_pad_t25_r<<1)+ref_pad_t24_r+2 )>>2 ;
          ref_flt_t26_r <= ( ref_pad_t27_r+(ref_pad_t26_r<<1)+ref_pad_t25_r+2 )>>2 ;
          ref_flt_t27_r <= ( ref_pad_t28_r+(ref_pad_t27_r<<1)+ref_pad_t26_r+2 )>>2 ;
          ref_flt_t28_r <= ( ref_pad_t29_r+(ref_pad_t28_r<<1)+ref_pad_t27_r+2 )>>2 ;
          ref_flt_t29_r <= ( ref_pad_t30_r+(ref_pad_t29_r<<1)+ref_pad_t28_r+2 )>>2 ;
          ref_flt_t30_r <= ( ref_pad_t31_r+(ref_pad_t30_r<<1)+ref_pad_t29_r+2 )>>2 ;
          ref_flt_t31_r <= ( ref_pad_r00_r+(ref_pad_t31_r<<1)+ref_pad_t30_r+2 )>>2 ;
        end
        else begin
          ref_flt_t00_r <= ref_pad_t00_r ; ref_flt_t01_r <= ref_pad_t01_r ;
          ref_flt_t02_r <= ref_pad_t02_r ; ref_flt_t03_r <= ref_pad_t03_r ;
          ref_flt_t04_r <= ref_pad_t04_r ; ref_flt_t05_r <= ref_pad_t05_r ;
          ref_flt_t06_r <= ref_pad_t06_r ; ref_flt_t07_r <= ref_pad_t07_r ;
          ref_flt_t08_r <= ref_pad_t08_r ; ref_flt_t09_r <= ref_pad_t09_r ;
          ref_flt_t10_r <= ref_pad_t10_r ; ref_flt_t11_r <= ref_pad_t11_r ;
          ref_flt_t12_r <= ref_pad_t12_r ; ref_flt_t13_r <= ref_pad_t13_r ;
          ref_flt_t14_r <= ref_pad_t14_r ; ref_flt_t15_r <= ref_pad_t15_r ;
          ref_flt_t16_r <= ref_pad_t16_r ; ref_flt_t17_r <= ref_pad_t17_r ;
          ref_flt_t18_r <= ref_pad_t18_r ; ref_flt_t19_r <= ref_pad_t19_r ;
          ref_flt_t20_r <= ref_pad_t20_r ; ref_flt_t21_r <= ref_pad_t21_r ;
          ref_flt_t22_r <= ref_pad_t22_r ; ref_flt_t23_r <= ref_pad_t23_r ;
          ref_flt_t24_r <= ref_pad_t24_r ; ref_flt_t25_r <= ref_pad_t25_r ;
          ref_flt_t26_r <= ref_pad_t26_r ; ref_flt_t27_r <= ref_pad_t27_r ;
          ref_flt_t28_r <= ref_pad_t28_r ; ref_flt_t29_r <= ref_pad_t29_r ;
          ref_flt_t30_r <= ref_pad_t30_r ; ref_flt_t31_r <= ref_pad_t31_r ;
        end
      end
    end
  end

  // right
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_flt_r00_r <= 0 ; ref_flt_r01_r <= 0 ;
      ref_flt_r02_r <= 0 ; ref_flt_r03_r <= 0 ;
      ref_flt_r04_r <= 0 ; ref_flt_r05_r <= 0 ;
      ref_flt_r06_r <= 0 ; ref_flt_r07_r <= 0 ;
      ref_flt_r08_r <= 0 ; ref_flt_r09_r <= 0 ;
      ref_flt_r10_r <= 0 ; ref_flt_r11_r <= 0 ;
      ref_flt_r12_r <= 0 ; ref_flt_r13_r <= 0 ;
      ref_flt_r14_r <= 0 ; ref_flt_r15_r <= 0 ;
      ref_flt_r16_r <= 0 ; ref_flt_r17_r <= 0 ;
      ref_flt_r18_r <= 0 ; ref_flt_r19_r <= 0 ;
      ref_flt_r20_r <= 0 ; ref_flt_r21_r <= 0 ;
      ref_flt_r22_r <= 0 ; ref_flt_r23_r <= 0 ;
      ref_flt_r24_r <= 0 ; ref_flt_r25_r <= 0 ;
      ref_flt_r26_r <= 0 ; ref_flt_r27_r <= 0 ;
      ref_flt_r28_r <= 0 ; ref_flt_r29_r <= 0 ;
      ref_flt_r30_r <= 0 ; ref_flt_r31_r <= 0 ;
    end
    else begin
      if( start_flt_r ) begin
        if( flt_flag_r ) begin
          case( size_d3_r )
            `SIZE_04 : ref_flt_r00_r <=                 ref_pad_r00_r                         ;
            `SIZE_08 : ref_flt_r00_r <= (ref_pad_r01_r+(ref_pad_r00_r<<1)+ref_pad_t07_r+2)>>2 ;
            `SIZE_16 : ref_flt_r00_r <= (ref_pad_r01_r+(ref_pad_r00_r<<1)+ref_pad_t15_r+2)>>2 ;
            `SIZE_32 : ref_flt_r00_r <= (ref_pad_r01_r+(ref_pad_r00_r<<1)+ref_pad_t31_r+2)>>2 ;
          endcase
          ref_flt_r01_r <= ( ref_pad_r02_r+(ref_pad_r01_r<<1)+ref_pad_r00_r+2 )>>2 ;
          ref_flt_r02_r <= ( ref_pad_r03_r+(ref_pad_r02_r<<1)+ref_pad_r01_r+2 )>>2 ;
          ref_flt_r03_r <= ( ref_pad_r04_r+(ref_pad_r03_r<<1)+ref_pad_r02_r+2 )>>2 ;
          ref_flt_r04_r <= ( ref_pad_r05_r+(ref_pad_r04_r<<1)+ref_pad_r03_r+2 )>>2 ;
          ref_flt_r05_r <= ( ref_pad_r06_r+(ref_pad_r05_r<<1)+ref_pad_r04_r+2 )>>2 ;
          ref_flt_r06_r <= ( ref_pad_r07_r+(ref_pad_r06_r<<1)+ref_pad_r05_r+2 )>>2 ;
          if( size_d3_r==`SIZE_08 ) begin
            ref_flt_r07_r <=                ref_pad_r07_r                          ;
          end
          else begin
            ref_flt_r07_r <= ( ref_pad_r08_r+(ref_pad_r07_r<<1)+ref_pad_r06_r+2 )>>2 ;
          end
          ref_flt_r08_r <= ( ref_pad_r09_r+(ref_pad_r08_r<<1)+ref_pad_r07_r+2 )>>2 ;
          ref_flt_r09_r <= ( ref_pad_r10_r+(ref_pad_r09_r<<1)+ref_pad_r08_r+2 )>>2 ;
          ref_flt_r10_r <= ( ref_pad_r11_r+(ref_pad_r10_r<<1)+ref_pad_r09_r+2 )>>2 ;
          ref_flt_r11_r <= ( ref_pad_r12_r+(ref_pad_r11_r<<1)+ref_pad_r10_r+2 )>>2 ;
          ref_flt_r12_r <= ( ref_pad_r13_r+(ref_pad_r12_r<<1)+ref_pad_r11_r+2 )>>2 ;
          ref_flt_r13_r <= ( ref_pad_r14_r+(ref_pad_r13_r<<1)+ref_pad_r12_r+2 )>>2 ;
          ref_flt_r14_r <= ( ref_pad_r15_r+(ref_pad_r14_r<<1)+ref_pad_r13_r+2 )>>2 ;
          if( size_d3_r==`SIZE_16 ) begin
            ref_flt_r15_r <= ref_pad_r15_r ;
          end
          else begin
            ref_flt_r15_r <= ( ref_pad_r16_r+(ref_pad_r15_r<<1)+ref_pad_r14_r+2 )>>2 ;
          end
          ref_flt_r16_r <= ( ref_pad_r17_r+(ref_pad_r16_r<<1)+ref_pad_r15_r+2 )>>2 ;
          ref_flt_r17_r <= ( ref_pad_r18_r+(ref_pad_r17_r<<1)+ref_pad_r16_r+2 )>>2 ;
          ref_flt_r18_r <= ( ref_pad_r19_r+(ref_pad_r18_r<<1)+ref_pad_r17_r+2 )>>2 ;
          ref_flt_r19_r <= ( ref_pad_r20_r+(ref_pad_r19_r<<1)+ref_pad_r18_r+2 )>>2 ;
          ref_flt_r20_r <= ( ref_pad_r21_r+(ref_pad_r20_r<<1)+ref_pad_r19_r+2 )>>2 ;
          ref_flt_r21_r <= ( ref_pad_r22_r+(ref_pad_r21_r<<1)+ref_pad_r20_r+2 )>>2 ;
          ref_flt_r22_r <= ( ref_pad_r23_r+(ref_pad_r22_r<<1)+ref_pad_r21_r+2 )>>2 ;
          ref_flt_r23_r <= ( ref_pad_r24_r+(ref_pad_r23_r<<1)+ref_pad_r22_r+2 )>>2 ;
          ref_flt_r24_r <= ( ref_pad_r25_r+(ref_pad_r24_r<<1)+ref_pad_r23_r+2 )>>2 ;
          ref_flt_r25_r <= ( ref_pad_r26_r+(ref_pad_r25_r<<1)+ref_pad_r24_r+2 )>>2 ;
          ref_flt_r26_r <= ( ref_pad_r27_r+(ref_pad_r26_r<<1)+ref_pad_r25_r+2 )>>2 ;
          ref_flt_r27_r <= ( ref_pad_r28_r+(ref_pad_r27_r<<1)+ref_pad_r26_r+2 )>>2 ;
          ref_flt_r28_r <= ( ref_pad_r29_r+(ref_pad_r28_r<<1)+ref_pad_r27_r+2 )>>2 ;
          ref_flt_r29_r <= ( ref_pad_r30_r+(ref_pad_r29_r<<1)+ref_pad_r28_r+2 )>>2 ;
          ref_flt_r30_r <= ( ref_pad_r31_r+(ref_pad_r30_r<<1)+ref_pad_r29_r+2 )>>2 ;
          ref_flt_r31_r <=                  ref_pad_r31_r                          ;
        end
        else begin
          ref_flt_r00_r <= ref_pad_r00_r ; ref_flt_r01_r <= ref_pad_r01_r ;
          ref_flt_r02_r <= ref_pad_r02_r ; ref_flt_r03_r <= ref_pad_r03_r ;
          ref_flt_r04_r <= ref_pad_r04_r ; ref_flt_r05_r <= ref_pad_r05_r ;
          ref_flt_r06_r <= ref_pad_r06_r ; ref_flt_r07_r <= ref_pad_r07_r ;
          ref_flt_r08_r <= ref_pad_r08_r ; ref_flt_r09_r <= ref_pad_r09_r ;
          ref_flt_r10_r <= ref_pad_r10_r ; ref_flt_r11_r <= ref_pad_r11_r ;
          ref_flt_r12_r <= ref_pad_r12_r ; ref_flt_r13_r <= ref_pad_r13_r ;
          ref_flt_r14_r <= ref_pad_r14_r ; ref_flt_r15_r <= ref_pad_r15_r ;
          ref_flt_r16_r <= ref_pad_r16_r ; ref_flt_r17_r <= ref_pad_r17_r ;
          ref_flt_r18_r <= ref_pad_r18_r ; ref_flt_r19_r <= ref_pad_r19_r ;
          ref_flt_r20_r <= ref_pad_r20_r ; ref_flt_r21_r <= ref_pad_r21_r ;
          ref_flt_r22_r <= ref_pad_r22_r ; ref_flt_r23_r <= ref_pad_r23_r ;
          ref_flt_r24_r <= ref_pad_r24_r ; ref_flt_r25_r <= ref_pad_r25_r ;
          ref_flt_r26_r <= ref_pad_r26_r ; ref_flt_r27_r <= ref_pad_r27_r ;
          ref_flt_r28_r <= ref_pad_r28_r ; ref_flt_r29_r <= ref_pad_r29_r ;
          ref_flt_r30_r <= ref_pad_r30_r ; ref_flt_r31_r <= ref_pad_r31_r ;
        end
      end
    end
  end

  // left
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_flt_l00_r <= 0 ; ref_flt_l01_r <= 0 ;
      ref_flt_l02_r <= 0 ; ref_flt_l03_r <= 0 ;
      ref_flt_l04_r <= 0 ; ref_flt_l05_r <= 0 ;
      ref_flt_l06_r <= 0 ; ref_flt_l07_r <= 0 ;
      ref_flt_l08_r <= 0 ; ref_flt_l09_r <= 0 ;
      ref_flt_l10_r <= 0 ; ref_flt_l11_r <= 0 ;
      ref_flt_l12_r <= 0 ; ref_flt_l13_r <= 0 ;
      ref_flt_l14_r <= 0 ; ref_flt_l15_r <= 0 ;
      ref_flt_l16_r <= 0 ; ref_flt_l17_r <= 0 ;
      ref_flt_l18_r <= 0 ; ref_flt_l19_r <= 0 ;
      ref_flt_l20_r <= 0 ; ref_flt_l21_r <= 0 ;
      ref_flt_l22_r <= 0 ; ref_flt_l23_r <= 0 ;
      ref_flt_l24_r <= 0 ; ref_flt_l25_r <= 0 ;
      ref_flt_l26_r <= 0 ; ref_flt_l27_r <= 0 ;
      ref_flt_l28_r <= 0 ; ref_flt_l29_r <= 0 ;
      ref_flt_l30_r <= 0 ; ref_flt_l31_r <= 0 ;
    end
    else begin
      if( start_flt_r ) begin
        if( flt_flag_r ) begin
          // 00-06
          ref_flt_l00_r <= ( ref_pad_l01_r+(ref_pad_l00_r<<1)+ref_pad_tl_r +2 )>>2 ;
          ref_flt_l01_r <= ( ref_pad_l02_r+(ref_pad_l01_r<<1)+ref_pad_l00_r+2 )>>2 ;
          ref_flt_l02_r <= ( ref_pad_l03_r+(ref_pad_l02_r<<1)+ref_pad_l01_r+2 )>>2 ;
          ref_flt_l03_r <= ( ref_pad_l04_r+(ref_pad_l03_r<<1)+ref_pad_l02_r+2 )>>2 ;
          ref_flt_l04_r <= ( ref_pad_l05_r+(ref_pad_l04_r<<1)+ref_pad_l03_r+2 )>>2 ;
          ref_flt_l05_r <= ( ref_pad_l06_r+(ref_pad_l05_r<<1)+ref_pad_l04_r+2 )>>2 ;
          ref_flt_l06_r <= ( ref_pad_l07_r+(ref_pad_l06_r<<1)+ref_pad_l05_r+2 )>>2 ;
          // 07
          if( size_d3_r==`SIZE_08 ) begin
            ref_flt_l07_r <= ( ref_pad_d00_r+(ref_pad_l07_r<<1)+ref_pad_l06_r+2 )>>2 ;
          end
          else begin
            ref_flt_l07_r <= ( ref_pad_l08_r+(ref_pad_l07_r<<1)+ref_pad_l06_r+2 )>>2 ;
          end
          // 08-14
          ref_flt_l08_r <= ( ref_pad_l09_r+(ref_pad_l08_r<<1)+ref_pad_l07_r+2 )>>2 ;
          ref_flt_l09_r <= ( ref_pad_l10_r+(ref_pad_l09_r<<1)+ref_pad_l08_r+2 )>>2 ;
          ref_flt_l10_r <= ( ref_pad_l11_r+(ref_pad_l10_r<<1)+ref_pad_l09_r+2 )>>2 ;
          ref_flt_l11_r <= ( ref_pad_l12_r+(ref_pad_l11_r<<1)+ref_pad_l10_r+2 )>>2 ;
          ref_flt_l12_r <= ( ref_pad_l13_r+(ref_pad_l12_r<<1)+ref_pad_l11_r+2 )>>2 ;
          ref_flt_l13_r <= ( ref_pad_l14_r+(ref_pad_l13_r<<1)+ref_pad_l12_r+2 )>>2 ;
          ref_flt_l14_r <= ( ref_pad_l15_r+(ref_pad_l14_r<<1)+ref_pad_l13_r+2 )>>2 ;
          // 15
          if( size_d3_r==`SIZE_16 ) begin
            ref_flt_l15_r <= ( ref_pad_d00_r+(ref_pad_l15_r<<1)+ref_pad_l14_r+2 )>>2 ;
          end
          else begin
            ref_flt_l15_r <= ( ref_pad_l16_r+(ref_pad_l15_r<<1)+ref_pad_l14_r+2 )>>2 ;
          end
          // 16-31
          ref_flt_l16_r <= ( ref_pad_l17_r+(ref_pad_l16_r<<1)+ref_pad_l15_r+2 )>>2 ;
          ref_flt_l17_r <= ( ref_pad_l18_r+(ref_pad_l17_r<<1)+ref_pad_l16_r+2 )>>2 ;
          ref_flt_l18_r <= ( ref_pad_l19_r+(ref_pad_l18_r<<1)+ref_pad_l17_r+2 )>>2 ;
          ref_flt_l19_r <= ( ref_pad_l20_r+(ref_pad_l19_r<<1)+ref_pad_l18_r+2 )>>2 ;
          ref_flt_l20_r <= ( ref_pad_l21_r+(ref_pad_l20_r<<1)+ref_pad_l19_r+2 )>>2 ;
          ref_flt_l21_r <= ( ref_pad_l22_r+(ref_pad_l21_r<<1)+ref_pad_l20_r+2 )>>2 ;
          ref_flt_l22_r <= ( ref_pad_l23_r+(ref_pad_l22_r<<1)+ref_pad_l21_r+2 )>>2 ;
          ref_flt_l23_r <= ( ref_pad_l24_r+(ref_pad_l23_r<<1)+ref_pad_l22_r+2 )>>2 ;
          ref_flt_l24_r <= ( ref_pad_l25_r+(ref_pad_l24_r<<1)+ref_pad_l23_r+2 )>>2 ;
          ref_flt_l25_r <= ( ref_pad_l26_r+(ref_pad_l25_r<<1)+ref_pad_l24_r+2 )>>2 ;
          ref_flt_l26_r <= ( ref_pad_l27_r+(ref_pad_l26_r<<1)+ref_pad_l25_r+2 )>>2 ;
          ref_flt_l27_r <= ( ref_pad_l28_r+(ref_pad_l27_r<<1)+ref_pad_l26_r+2 )>>2 ;
          ref_flt_l28_r <= ( ref_pad_l29_r+(ref_pad_l28_r<<1)+ref_pad_l27_r+2 )>>2 ;
          ref_flt_l29_r <= ( ref_pad_l30_r+(ref_pad_l29_r<<1)+ref_pad_l28_r+2 )>>2 ;
          ref_flt_l30_r <= ( ref_pad_l31_r+(ref_pad_l30_r<<1)+ref_pad_l29_r+2 )>>2 ;
          ref_flt_l31_r <= ( ref_pad_d00_r+(ref_pad_l31_r<<1)+ref_pad_l30_r+2 )>>2 ;
        end
        else begin
          ref_flt_l00_r <= ref_pad_l00_r ; ref_flt_l01_r <= ref_pad_l01_r ;
          ref_flt_l02_r <= ref_pad_l02_r ; ref_flt_l03_r <= ref_pad_l03_r ;
          ref_flt_l04_r <= ref_pad_l04_r ; ref_flt_l05_r <= ref_pad_l05_r ;
          ref_flt_l06_r <= ref_pad_l06_r ; ref_flt_l07_r <= ref_pad_l07_r ;
          ref_flt_l08_r <= ref_pad_l08_r ; ref_flt_l09_r <= ref_pad_l09_r ;
          ref_flt_l10_r <= ref_pad_l10_r ; ref_flt_l11_r <= ref_pad_l11_r ;
          ref_flt_l12_r <= ref_pad_l12_r ; ref_flt_l13_r <= ref_pad_l13_r ;
          ref_flt_l14_r <= ref_pad_l14_r ; ref_flt_l15_r <= ref_pad_l15_r ;
          ref_flt_l16_r <= ref_pad_l16_r ; ref_flt_l17_r <= ref_pad_l17_r ;
          ref_flt_l18_r <= ref_pad_l18_r ; ref_flt_l19_r <= ref_pad_l19_r ;
          ref_flt_l20_r <= ref_pad_l20_r ; ref_flt_l21_r <= ref_pad_l21_r ;
          ref_flt_l22_r <= ref_pad_l22_r ; ref_flt_l23_r <= ref_pad_l23_r ;
          ref_flt_l24_r <= ref_pad_l24_r ; ref_flt_l25_r <= ref_pad_l25_r ;
          ref_flt_l26_r <= ref_pad_l26_r ; ref_flt_l27_r <= ref_pad_l27_r ;
          ref_flt_l28_r <= ref_pad_l28_r ; ref_flt_l29_r <= ref_pad_l29_r ;
          ref_flt_l30_r <= ref_pad_l30_r ; ref_flt_l31_r <= ref_pad_l31_r ;
        end
      end
    end
  end

  // down
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_flt_d00_r <= 0 ; ref_flt_d01_r <= 0 ;
      ref_flt_d02_r <= 0 ; ref_flt_d03_r <= 0 ;
      ref_flt_d04_r <= 0 ; ref_flt_d05_r <= 0 ;
      ref_flt_d06_r <= 0 ; ref_flt_d07_r <= 0 ;
      ref_flt_d08_r <= 0 ; ref_flt_d09_r <= 0 ;
      ref_flt_d10_r <= 0 ; ref_flt_d11_r <= 0 ;
      ref_flt_d12_r <= 0 ; ref_flt_d13_r <= 0 ;
      ref_flt_d14_r <= 0 ; ref_flt_d15_r <= 0 ;
      ref_flt_d16_r <= 0 ; ref_flt_d17_r <= 0 ;
      ref_flt_d18_r <= 0 ; ref_flt_d19_r <= 0 ;
      ref_flt_d20_r <= 0 ; ref_flt_d21_r <= 0 ;
      ref_flt_d22_r <= 0 ; ref_flt_d23_r <= 0 ;
      ref_flt_d24_r <= 0 ; ref_flt_d25_r <= 0 ;
      ref_flt_d26_r <= 0 ; ref_flt_d27_r <= 0 ;
      ref_flt_d28_r <= 0 ; ref_flt_d29_r <= 0 ;
      ref_flt_d30_r <= 0 ; ref_flt_d31_r <= 0 ;
    end
    else begin
      if( start_flt_r ) begin
        if( flt_flag_r ) begin
          // 00
          case (size_d3_r)
            `SIZE_04 : ref_flt_d00_r <=                  ref_pad_d00_r                          ;
            `SIZE_08 : ref_flt_d00_r <= ( ref_pad_d01_r+(ref_pad_d00_r<<1)+ref_pad_l07_r+2 )>>2 ;
            `SIZE_16 : ref_flt_d00_r <= ( ref_pad_d01_r+(ref_pad_d00_r<<1)+ref_pad_l15_r+2 )>>2 ;
            `SIZE_32 : ref_flt_d00_r <= ( ref_pad_d01_r+(ref_pad_d00_r<<1)+ref_pad_l31_r+2 )>>2 ;
            default  : ref_flt_d00_r <=                  ref_pad_d00_r                          ;
          endcase
          // 01-06
          ref_flt_d01_r <= ( ref_pad_d02_r+(ref_pad_d01_r<<1)+ref_pad_d00_r+2 )>>2 ;
          ref_flt_d02_r <= ( ref_pad_d03_r+(ref_pad_d02_r<<1)+ref_pad_d01_r+2 )>>2 ;
          ref_flt_d03_r <= ( ref_pad_d04_r+(ref_pad_d03_r<<1)+ref_pad_d02_r+2 )>>2 ;
          ref_flt_d04_r <= ( ref_pad_d05_r+(ref_pad_d04_r<<1)+ref_pad_d03_r+2 )>>2 ;
          ref_flt_d05_r <= ( ref_pad_d06_r+(ref_pad_d05_r<<1)+ref_pad_d04_r+2 )>>2 ;
          ref_flt_d06_r <= ( ref_pad_d07_r+(ref_pad_d06_r<<1)+ref_pad_d05_r+2 )>>2 ;
          // 07
          if( size_d3_r==`SIZE_08 ) begin
            ref_flt_d07_r <=                  ref_pad_d07_r                          ;
          end
          else begin
            ref_flt_d07_r <= ( ref_pad_d08_r+(ref_pad_d07_r<<1)+ref_pad_d06_r+2 )>>2 ;
          end
          // 08-14
          ref_flt_d08_r <= ( ref_pad_d09_r+(ref_pad_d08_r<<1)+ref_pad_d07_r+2 )>>2 ;
          ref_flt_d09_r <= ( ref_pad_d10_r+(ref_pad_d09_r<<1)+ref_pad_d08_r+2 )>>2 ;
          ref_flt_d10_r <= ( ref_pad_d11_r+(ref_pad_d10_r<<1)+ref_pad_d09_r+2 )>>2 ;
          ref_flt_d11_r <= ( ref_pad_d12_r+(ref_pad_d11_r<<1)+ref_pad_d10_r+2 )>>2 ;
          ref_flt_d12_r <= ( ref_pad_d13_r+(ref_pad_d12_r<<1)+ref_pad_d11_r+2 )>>2 ;
          ref_flt_d13_r <= ( ref_pad_d14_r+(ref_pad_d13_r<<1)+ref_pad_d12_r+2 )>>2 ;
          ref_flt_d14_r <= ( ref_pad_d15_r+(ref_pad_d14_r<<1)+ref_pad_d13_r+2 )>>2 ;
          // 15
          if( size_d3_r==`SIZE_16 ) begin
            ref_flt_d15_r <=                  ref_pad_d15_r                          ;
          end
          else begin
            ref_flt_d15_r <= ( ref_pad_d16_r+(ref_pad_d15_r<<1)+ref_pad_d14_r+2 )>>2 ;
          end
          // 16-31
          ref_flt_d16_r <= ( ref_pad_d17_r+(ref_pad_d16_r<<1)+ref_pad_d15_r+2 )>>2 ;
          ref_flt_d17_r <= ( ref_pad_d18_r+(ref_pad_d17_r<<1)+ref_pad_d16_r+2 )>>2 ;
          ref_flt_d18_r <= ( ref_pad_d19_r+(ref_pad_d18_r<<1)+ref_pad_d17_r+2 )>>2 ;
          ref_flt_d19_r <= ( ref_pad_d20_r+(ref_pad_d19_r<<1)+ref_pad_d18_r+2 )>>2 ;
          ref_flt_d20_r <= ( ref_pad_d21_r+(ref_pad_d20_r<<1)+ref_pad_d19_r+2 )>>2 ;
          ref_flt_d21_r <= ( ref_pad_d22_r+(ref_pad_d21_r<<1)+ref_pad_d20_r+2 )>>2 ;
          ref_flt_d22_r <= ( ref_pad_d23_r+(ref_pad_d22_r<<1)+ref_pad_d21_r+2 )>>2 ;
          ref_flt_d23_r <= ( ref_pad_d24_r+(ref_pad_d23_r<<1)+ref_pad_d22_r+2 )>>2 ;
          ref_flt_d24_r <= ( ref_pad_d25_r+(ref_pad_d24_r<<1)+ref_pad_d23_r+2 )>>2 ;
          ref_flt_d25_r <= ( ref_pad_d26_r+(ref_pad_d25_r<<1)+ref_pad_d24_r+2 )>>2 ;
          ref_flt_d26_r <= ( ref_pad_d27_r+(ref_pad_d26_r<<1)+ref_pad_d25_r+2 )>>2 ;
          ref_flt_d27_r <= ( ref_pad_d28_r+(ref_pad_d27_r<<1)+ref_pad_d26_r+2 )>>2 ;
          ref_flt_d28_r <= ( ref_pad_d29_r+(ref_pad_d28_r<<1)+ref_pad_d27_r+2 )>>2 ;
          ref_flt_d29_r <= ( ref_pad_d30_r+(ref_pad_d29_r<<1)+ref_pad_d28_r+2 )>>2 ;
          ref_flt_d30_r <= ( ref_pad_d31_r+(ref_pad_d30_r<<1)+ref_pad_d29_r+2 )>>2 ;
          ref_flt_d31_r <=                  ref_pad_d31_r                          ;
        end
        else begin
          ref_flt_d00_r <= ref_pad_d00_r ; ref_flt_d01_r <= ref_pad_d01_r ;
          ref_flt_d02_r <= ref_pad_d02_r ; ref_flt_d03_r <= ref_pad_d03_r ;
          ref_flt_d04_r <= ref_pad_d04_r ; ref_flt_d05_r <= ref_pad_d05_r ;
          ref_flt_d06_r <= ref_pad_d06_r ; ref_flt_d07_r <= ref_pad_d07_r ;
          ref_flt_d08_r <= ref_pad_d08_r ; ref_flt_d09_r <= ref_pad_d09_r ;
          ref_flt_d10_r <= ref_pad_d10_r ; ref_flt_d11_r <= ref_pad_d11_r ;
          ref_flt_d12_r <= ref_pad_d12_r ; ref_flt_d13_r <= ref_pad_d13_r ;
          ref_flt_d14_r <= ref_pad_d14_r ; ref_flt_d15_r <= ref_pad_d15_r ;
          ref_flt_d16_r <= ref_pad_d16_r ; ref_flt_d17_r <= ref_pad_d17_r ;
          ref_flt_d18_r <= ref_pad_d18_r ; ref_flt_d19_r <= ref_pad_d19_r ;
          ref_flt_d20_r <= ref_pad_d20_r ; ref_flt_d21_r <= ref_pad_d21_r ;
          ref_flt_d22_r <= ref_pad_d22_r ; ref_flt_d23_r <= ref_pad_d23_r ;
          ref_flt_d24_r <= ref_pad_d24_r ; ref_flt_d25_r <= ref_pad_d25_r ;
          ref_flt_d26_r <= ref_pad_d26_r ; ref_flt_d27_r <= ref_pad_d27_r ;
          ref_flt_d28_r <= ref_pad_d28_r ; ref_flt_d29_r <= ref_pad_d29_r ;
          ref_flt_d30_r <= ref_pad_d30_r ; ref_flt_d31_r <= ref_pad_d31_r ;
        end
      end
    end
  end


//--- OUTPUT ---------------------------
  // ctl & cfg
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ready_o    <= 0 ;
      mode_o     <= 0 ;
      size_o     <= 0 ;
      position_o <= 0 ;
    end
    else begin
      ready_o    <= start_flt_r   ;
      if( start_flt_r ) begin
        mode_o     <= mod_rd_dat_r  ;
        size_o     <= size_d3_r     ;
        position_o <= position_d3_r ;
      end
    end
  end

  assign done_o = cnt_raw_done_w ;


//*** DEBUG ********************************************************************

`ifdef H265_DEBUG

`endif

endmodule
