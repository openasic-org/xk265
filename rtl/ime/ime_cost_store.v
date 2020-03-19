//--------------------------------------------------------------------
//
//  Filename    : ime_cost_store.v
//  Author      : Huang Leilei
//  Created     : 2018-04-12
//  Description : cost storage in ime module (auto generated)
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module ime_cost_store(
  // global
  clk                   ,
  rstn                  ,
  // config
  clear_i               ,
  downsample_i          ,
  // input
  val_04_i              ,
  dat_04_qd_i           ,
  dat_04_mv_i           ,
  dat_04_cst_mvd_i      ,
  dat_04_cst_sad_0_i    ,    // 04x04
  val_08_i              ,
  dat_08_qd_i           ,
  dat_08_mv_i           ,
  dat_08_cst_mvd_i      ,
  dat_08_cst_sad_0_i    ,    // 08x08
  dat_08_cst_sad_1_i    ,    // 04x08
  dat_08_cst_sad_2_i    ,    // 08x04
  val_16_i              ,
  dat_16_qd_i           ,
  dat_16_mv_i           ,
  dat_16_cst_mvd_i      ,
  dat_16_cst_sad_0_i    ,    // 16x16
  dat_16_cst_sad_1_i    ,    // 08x16
  dat_16_cst_sad_2_i    ,    // 16x08
  val_32_i              ,
  dat_32_qd_i           ,
  dat_32_mv_i           ,
  dat_32_cst_mvd_i      ,
  dat_32_cst_sad_0_i    ,    // 32x32
  dat_32_cst_sad_1_i    ,    // 16x32
  dat_32_cst_sad_2_i    ,    // 32x16
  // output
  dat_08_mv_0_o         ,    // 08x08
  dat_16_mv_0_o         ,    // 16x16
  dat_16_mv_1_o         ,    // 08x16
  dat_16_mv_2_o         ,    // 16x08
  dat_32_mv_0_o         ,    // 32x32
  dat_32_mv_1_o         ,    // 16x32
  dat_32_mv_2_o         ,    // 32x32
  dat_64_mv_0_o         ,    // 64x64
  dat_64_mv_1_o         ,    // 32x64
  dat_64_mv_2_o         ,    // 64x32
  dat_08_cst_0_o        ,
  dat_16_cst_0_o        ,
  dat_16_cst_1_o        ,
  dat_16_cst_2_o        ,
  dat_32_cst_0_o        ,
  dat_32_cst_1_o        ,
  dat_32_cst_2_o        ,
  dat_64_cst_0_o        ,
  dat_64_cst_1_o        ,
  dat_64_cst_2_o
  );


//*** PARAMETER ****************************************************************


//*** INPUT/OUTPUT *************************************************************

  // global
  input                               clk                           ;
  input                               rstn                          ;
  // config
  input                               clear_i                       ;
  input                               downsample_i                  ;
  // input
  input                               val_04_i                      ;
  input  [2                 -1 :0]    dat_04_qd_i                   ;
  input  [`IME_MV_WIDTH     -1 :0]    dat_04_mv_i                   ;
  input  [`IME_C_MV_WIDTH   -1 :0]    dat_04_cst_mvd_i              ;
  input  [`IME_COST_WIDTH*64-1 :0]    dat_04_cst_sad_0_i            ;    // 04x04
  input                               val_08_i                      ;
  input  [2                 -1 :0]    dat_08_qd_i                   ;
  input  [`IME_MV_WIDTH     -1 :0]    dat_08_mv_i                   ;
  input  [`IME_C_MV_WIDTH   -1 :0]    dat_08_cst_mvd_i              ;
  input  [`IME_COST_WIDTH*16-1 :0]    dat_08_cst_sad_0_i            ;    // 08x08
  input  [`IME_COST_WIDTH*32-1 :0]    dat_08_cst_sad_1_i            ;    // 04x08
  input  [`IME_COST_WIDTH*32-1 :0]    dat_08_cst_sad_2_i            ;    // 08x04
  input                               val_16_i                      ;
  input  [2                 -1 :0]    dat_16_qd_i                   ;
  input  [`IME_MV_WIDTH     -1 :0]    dat_16_mv_i                   ;
  input  [`IME_C_MV_WIDTH   -1 :0]    dat_16_cst_mvd_i              ;
  input  [`IME_COST_WIDTH*4 -1 :0]    dat_16_cst_sad_0_i            ;    // 16x16
  input  [`IME_COST_WIDTH*8 -1 :0]    dat_16_cst_sad_1_i            ;    // 08x16
  input  [`IME_COST_WIDTH*8 -1 :0]    dat_16_cst_sad_2_i            ;    // 16x08
  input                               val_32_i                      ;
  input  [2                 -1 :0]    dat_32_qd_i                   ;
  input  [`IME_MV_WIDTH     -1 :0]    dat_32_mv_i                   ;
  input  [`IME_C_MV_WIDTH   -1 :0]    dat_32_cst_mvd_i              ;
  input  [`IME_COST_WIDTH*1 -1 :0]    dat_32_cst_sad_0_i            ;    // 32x32
  input  [`IME_COST_WIDTH*2 -1 :0]    dat_32_cst_sad_1_i            ;    // 16x32
  input  [`IME_COST_WIDTH*2 -1 :0]    dat_32_cst_sad_2_i            ;    // 32x16
  // output
  output [`IME_MV_WIDTH  *64-1 :0]    dat_08_mv_0_o                 ;    // 08x08
  output [`IME_MV_WIDTH  *16-1 :0]    dat_16_mv_0_o                 ;    // 16x16
  output [`IME_MV_WIDTH  *32-1 :0]    dat_16_mv_1_o                 ;    // 08x16
  output [`IME_MV_WIDTH  *32-1 :0]    dat_16_mv_2_o                 ;    // 16x08
  output [`IME_MV_WIDTH  *4 -1 :0]    dat_32_mv_0_o                 ;    // 32x32
  output [`IME_MV_WIDTH  *8 -1 :0]    dat_32_mv_1_o                 ;    // 16x32
  output [`IME_MV_WIDTH  *8 -1 :0]    dat_32_mv_2_o                 ;    // 32x32
  output [`IME_MV_WIDTH  *1 -1 :0]    dat_64_mv_0_o                 ;    // 64x64
  output [`IME_MV_WIDTH  *2 -1 :0]    dat_64_mv_1_o                 ;    // 32x64
  output [`IME_MV_WIDTH  *2 -1 :0]    dat_64_mv_2_o                 ;    // 64x32
  output [`IME_COST_WIDTH*64-1 :0]    dat_08_cst_0_o                ;
  output [`IME_COST_WIDTH*16-1 :0]    dat_16_cst_0_o                ;
  output [`IME_COST_WIDTH*32-1 :0]    dat_16_cst_1_o                ;
  output [`IME_COST_WIDTH*32-1 :0]    dat_16_cst_2_o                ;
  output [`IME_COST_WIDTH*4 -1 :0]    dat_32_cst_0_o                ;
  output [`IME_COST_WIDTH*8 -1 :0]    dat_32_cst_1_o                ;
  output [`IME_COST_WIDTH*8 -1 :0]    dat_32_cst_2_o                ;
  output [`IME_COST_WIDTH*1 -1 :0]    dat_64_cst_0_o                ;
  output [`IME_COST_WIDTH*2 -1 :0]    dat_64_cst_1_o                ;
  output [`IME_COST_WIDTH*2 -1 :0]    dat_64_cst_2_o                ;


//*** REG/WIRE *****************************************************************

  // input cst layer 2
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_00_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_00_04_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_00_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_00_12_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_00_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_00_20_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_00_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_00_28_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_04_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_04_04_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_04_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_04_12_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_04_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_04_20_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_04_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_04_28_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_08_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_08_04_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_08_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_08_12_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_08_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_08_20_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_08_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_08_28_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_12_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_12_04_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_12_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_12_12_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_12_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_12_20_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_12_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_12_28_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_16_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_16_04_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_16_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_16_12_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_16_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_16_20_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_16_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_16_28_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_20_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_20_04_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_20_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_20_12_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_20_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_20_20_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_20_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_20_28_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_24_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_24_04_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_24_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_24_12_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_24_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_24_20_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_24_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_24_28_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_28_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_28_04_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_28_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_28_12_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_28_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_28_20_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_28_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_sad_0_i_28_28_w    ;
  // input cst layer 3
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_00_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_00_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_04_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_00_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_00_04_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_00_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_00_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_04_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_00_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_00_12_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_00_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_00_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_04_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_00_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_00_20_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_00_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_00_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_04_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_00_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_00_28_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_08_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_08_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_12_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_08_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_08_04_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_08_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_08_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_12_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_08_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_08_12_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_08_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_08_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_12_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_08_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_08_20_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_08_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_08_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_12_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_08_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_08_28_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_16_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_16_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_20_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_16_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_16_04_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_16_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_16_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_20_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_16_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_16_12_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_16_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_16_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_20_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_16_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_16_20_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_16_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_16_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_20_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_16_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_16_28_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_24_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_24_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_28_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_24_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_24_04_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_24_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_24_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_28_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_24_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_24_12_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_24_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_24_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_28_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_24_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_24_20_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_0_i_24_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_24_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_1_i_28_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_24_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_sad_2_i_24_28_w    ;
  // input cst layer 4
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_0_i_00_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_1_i_00_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_1_i_08_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_2_i_00_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_2_i_00_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_0_i_00_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_1_i_00_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_1_i_08_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_2_i_00_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_2_i_00_24_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_0_i_16_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_1_i_16_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_1_i_24_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_2_i_16_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_2_i_16_08_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_0_i_16_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_1_i_16_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_1_i_24_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_2_i_16_16_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_sad_2_i_16_24_w    ;
  // input cst layer 5
  wire   [`IME_COST_WIDTH   -1 :0]    dat_32_cst_sad_0_i_00_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_32_cst_sad_1_i_00_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_32_cst_sad_1_i_16_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_32_cst_sad_2_i_00_00_w    ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_32_cst_sad_2_i_00_16_w    ;
  // input cst layer 2
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_00_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_00_04_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_00_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_00_12_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_00_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_00_20_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_00_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_00_28_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_04_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_04_04_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_04_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_04_12_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_04_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_04_20_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_04_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_04_28_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_08_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_08_04_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_08_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_08_12_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_08_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_08_20_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_08_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_08_28_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_12_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_12_04_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_12_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_12_12_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_12_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_12_20_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_12_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_12_28_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_16_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_16_04_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_16_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_16_12_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_16_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_16_20_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_16_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_16_28_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_20_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_20_04_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_20_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_20_12_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_20_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_20_20_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_20_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_20_28_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_24_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_24_04_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_24_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_24_12_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_24_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_24_20_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_24_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_24_28_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_28_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_28_04_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_28_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_28_12_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_28_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_28_20_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_28_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_04_cst_0_i_28_28_f_w      ;
  // input cst layer 3
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_00_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_00_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_04_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_00_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_00_04_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_00_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_00_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_04_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_00_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_00_12_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_00_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_00_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_04_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_00_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_00_20_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_00_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_00_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_04_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_00_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_00_28_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_08_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_08_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_12_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_08_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_08_04_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_08_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_08_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_12_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_08_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_08_12_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_08_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_08_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_12_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_08_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_08_20_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_08_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_08_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_12_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_08_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_08_28_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_16_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_16_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_20_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_16_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_16_04_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_16_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_16_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_20_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_16_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_16_12_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_16_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_16_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_20_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_16_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_16_20_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_16_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_16_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_20_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_16_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_16_28_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_24_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_24_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_28_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_24_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_24_04_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_24_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_24_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_28_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_24_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_24_12_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_24_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_24_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_28_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_24_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_24_20_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_0_i_24_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_24_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_1_i_28_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_24_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_08_cst_2_i_24_28_f_w      ;
  // input cst layer 4
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_0_i_00_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_1_i_00_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_1_i_08_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_2_i_00_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_2_i_00_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_0_i_00_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_1_i_00_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_1_i_08_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_2_i_00_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_2_i_00_24_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_0_i_16_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_1_i_16_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_1_i_24_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_2_i_16_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_2_i_16_08_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_0_i_16_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_1_i_16_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_1_i_24_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_2_i_16_16_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_16_cst_2_i_16_24_f_w      ;
  // input cst layer 5
  wire   [`IME_COST_WIDTH   +2 :0]    dat_32_cst_0_i_00_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_32_cst_1_i_00_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_32_cst_1_i_16_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_32_cst_2_i_00_00_f_w      ;
  wire   [`IME_COST_WIDTH   +2 :0]    dat_32_cst_2_i_00_16_f_w      ;
  // input cst layer 2
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_00_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_00_04_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_00_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_00_12_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_00_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_00_20_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_00_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_00_28_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_04_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_04_04_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_04_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_04_12_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_04_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_04_20_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_04_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_04_28_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_08_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_08_04_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_08_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_08_12_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_08_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_08_20_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_08_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_08_28_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_12_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_12_04_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_12_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_12_12_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_12_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_12_20_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_12_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_12_28_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_16_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_16_04_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_16_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_16_12_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_16_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_16_20_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_16_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_16_28_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_20_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_20_04_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_20_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_20_12_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_20_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_20_20_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_20_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_20_28_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_24_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_24_04_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_24_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_24_12_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_24_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_24_20_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_24_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_24_28_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_28_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_28_04_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_28_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_28_12_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_28_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_28_20_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_28_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_04_cst_0_i_28_28_w        ;
  // input cst layer 3
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_00_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_00_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_04_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_00_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_00_04_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_00_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_00_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_04_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_00_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_00_12_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_00_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_00_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_04_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_00_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_00_20_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_00_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_00_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_04_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_00_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_00_28_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_08_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_08_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_12_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_08_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_08_04_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_08_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_08_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_12_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_08_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_08_12_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_08_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_08_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_12_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_08_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_08_20_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_08_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_08_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_12_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_08_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_08_28_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_16_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_16_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_20_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_16_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_16_04_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_16_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_16_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_20_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_16_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_16_12_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_16_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_16_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_20_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_16_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_16_20_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_16_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_16_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_20_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_16_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_16_28_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_24_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_24_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_28_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_24_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_24_04_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_24_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_24_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_28_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_24_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_24_12_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_24_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_24_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_28_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_24_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_24_20_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_24_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_24_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_1_i_28_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_24_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_08_cst_2_i_24_28_w        ;
  // input cst layer 4
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_00_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_00_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_08_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_00_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_00_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_00_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_00_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_08_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_00_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_00_24_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_16_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_16_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_24_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_16_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_16_08_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_16_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_16_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_24_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_16_16_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_16_24_w        ;
  // input cst layer 5
  wire   [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_i_00_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_i_00_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_i_16_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_i_00_00_w        ;
  wire   [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_i_00_16_w        ;
  // output mv layer 3
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_00_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_00_08_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_00_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_00_24_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_00_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_00_40_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_00_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_00_56_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_08_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_08_08_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_08_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_08_24_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_08_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_08_40_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_08_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_08_56_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_16_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_16_08_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_16_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_16_24_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_16_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_16_40_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_16_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_16_56_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_24_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_24_08_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_24_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_24_24_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_24_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_24_40_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_24_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_24_56_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_32_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_32_08_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_32_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_32_24_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_32_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_32_40_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_32_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_32_56_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_40_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_40_08_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_40_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_40_24_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_40_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_40_40_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_40_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_40_56_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_48_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_48_08_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_48_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_48_24_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_48_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_48_40_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_48_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_48_56_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_56_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_56_08_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_56_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_56_24_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_56_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_56_40_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_56_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_08_mv_0_o_56_56_r         ;
  // output mv layer 4
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_00_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_00_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_08_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_00_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_00_08_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_00_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_00_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_08_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_00_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_00_24_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_00_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_00_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_08_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_00_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_00_40_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_00_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_00_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_08_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_00_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_00_56_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_16_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_16_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_24_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_16_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_16_08_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_16_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_16_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_24_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_16_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_16_24_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_16_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_16_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_24_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_16_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_16_40_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_16_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_16_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_24_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_16_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_16_56_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_32_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_32_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_40_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_32_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_32_08_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_32_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_32_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_40_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_32_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_32_24_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_32_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_32_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_40_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_32_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_32_40_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_32_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_32_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_40_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_32_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_32_56_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_48_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_48_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_56_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_48_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_48_08_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_48_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_48_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_56_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_48_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_48_24_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_48_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_48_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_56_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_48_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_48_40_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_0_o_48_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_48_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_1_o_56_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_48_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_16_mv_2_o_48_56_r         ;
  // output mv layer 5
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_0_o_00_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_1_o_00_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_1_o_16_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_2_o_00_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_2_o_00_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_0_o_00_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_1_o_00_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_1_o_16_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_2_o_00_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_2_o_00_48_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_0_o_32_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_1_o_32_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_1_o_48_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_2_o_32_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_2_o_32_16_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_0_o_32_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_1_o_32_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_1_o_48_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_2_o_32_32_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_32_mv_2_o_32_48_r         ;
  // output mv layer 6
  reg    [`IME_MV_WIDTH     -1 :0]    dat_64_mv_0_o_00_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_64_mv_1_o_00_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_64_mv_1_o_32_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_64_mv_2_o_00_00_r         ;
  reg    [`IME_MV_WIDTH     -1 :0]    dat_64_mv_2_o_00_32_r         ;
  // output cst layer 3
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_00_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_00_08_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_00_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_00_24_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_00_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_00_40_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_00_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_00_56_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_08_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_08_08_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_08_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_08_24_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_08_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_08_40_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_08_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_08_56_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_16_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_16_08_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_16_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_16_24_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_16_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_16_40_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_16_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_16_56_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_24_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_24_08_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_24_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_24_24_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_24_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_24_40_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_24_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_24_56_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_32_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_32_08_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_32_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_32_24_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_32_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_32_40_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_32_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_32_56_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_40_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_40_08_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_40_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_40_24_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_40_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_40_40_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_40_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_40_56_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_48_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_48_08_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_48_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_48_24_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_48_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_48_40_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_48_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_48_56_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_56_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_56_08_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_56_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_56_24_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_56_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_56_40_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_56_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_o_56_56_r        ;
  // output cst layer 4
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_00_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_00_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_08_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_00_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_00_08_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_00_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_00_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_08_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_00_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_00_24_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_00_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_00_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_08_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_00_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_00_40_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_00_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_00_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_08_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_00_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_00_56_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_16_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_16_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_24_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_16_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_16_08_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_16_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_16_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_24_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_16_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_16_24_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_16_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_16_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_24_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_16_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_16_40_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_16_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_16_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_24_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_16_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_16_56_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_32_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_32_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_40_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_32_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_32_08_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_32_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_32_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_40_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_32_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_32_24_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_32_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_32_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_40_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_32_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_32_40_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_32_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_32_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_40_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_32_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_32_56_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_48_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_48_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_56_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_48_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_48_08_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_48_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_48_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_56_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_48_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_48_24_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_48_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_48_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_56_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_48_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_48_40_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_o_48_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_48_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_o_56_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_48_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_o_48_56_r        ;
  // output cst layer 5
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_o_00_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_o_00_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_o_16_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_o_00_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_o_00_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_o_00_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_o_00_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_o_16_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_o_00_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_o_00_48_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_o_32_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_o_32_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_o_48_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_o_32_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_o_32_16_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_o_32_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_o_32_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_o_48_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_o_32_32_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_o_32_48_r        ;
  // output cst layer 6
  reg    [`IME_COST_WIDTH   -1 :0]    dat_64_cst_0_o_00_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_64_cst_1_o_00_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_64_cst_1_o_32_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_64_cst_2_o_00_00_r        ;
  reg    [`IME_COST_WIDTH   -1 :0]    dat_64_cst_2_o_00_32_r        ;


//*** MAIN BODY ****************************************************************

//--- WIRE ASSIGNMENT ------------------

  // input cst layer 2
  assign { dat_04_cst_sad_0_i_00_00_w
          ,dat_04_cst_sad_0_i_00_04_w
          ,dat_04_cst_sad_0_i_00_08_w
          ,dat_04_cst_sad_0_i_00_12_w
          ,dat_04_cst_sad_0_i_00_16_w
          ,dat_04_cst_sad_0_i_00_20_w
          ,dat_04_cst_sad_0_i_00_24_w
          ,dat_04_cst_sad_0_i_00_28_w
          ,dat_04_cst_sad_0_i_04_00_w
          ,dat_04_cst_sad_0_i_04_04_w
          ,dat_04_cst_sad_0_i_04_08_w
          ,dat_04_cst_sad_0_i_04_12_w
          ,dat_04_cst_sad_0_i_04_16_w
          ,dat_04_cst_sad_0_i_04_20_w
          ,dat_04_cst_sad_0_i_04_24_w
          ,dat_04_cst_sad_0_i_04_28_w
          ,dat_04_cst_sad_0_i_08_00_w
          ,dat_04_cst_sad_0_i_08_04_w
          ,dat_04_cst_sad_0_i_08_08_w
          ,dat_04_cst_sad_0_i_08_12_w
          ,dat_04_cst_sad_0_i_08_16_w
          ,dat_04_cst_sad_0_i_08_20_w
          ,dat_04_cst_sad_0_i_08_24_w
          ,dat_04_cst_sad_0_i_08_28_w
          ,dat_04_cst_sad_0_i_12_00_w
          ,dat_04_cst_sad_0_i_12_04_w
          ,dat_04_cst_sad_0_i_12_08_w
          ,dat_04_cst_sad_0_i_12_12_w
          ,dat_04_cst_sad_0_i_12_16_w
          ,dat_04_cst_sad_0_i_12_20_w
          ,dat_04_cst_sad_0_i_12_24_w
          ,dat_04_cst_sad_0_i_12_28_w
          ,dat_04_cst_sad_0_i_16_00_w
          ,dat_04_cst_sad_0_i_16_04_w
          ,dat_04_cst_sad_0_i_16_08_w
          ,dat_04_cst_sad_0_i_16_12_w
          ,dat_04_cst_sad_0_i_16_16_w
          ,dat_04_cst_sad_0_i_16_20_w
          ,dat_04_cst_sad_0_i_16_24_w
          ,dat_04_cst_sad_0_i_16_28_w
          ,dat_04_cst_sad_0_i_20_00_w
          ,dat_04_cst_sad_0_i_20_04_w
          ,dat_04_cst_sad_0_i_20_08_w
          ,dat_04_cst_sad_0_i_20_12_w
          ,dat_04_cst_sad_0_i_20_16_w
          ,dat_04_cst_sad_0_i_20_20_w
          ,dat_04_cst_sad_0_i_20_24_w
          ,dat_04_cst_sad_0_i_20_28_w
          ,dat_04_cst_sad_0_i_24_00_w
          ,dat_04_cst_sad_0_i_24_04_w
          ,dat_04_cst_sad_0_i_24_08_w
          ,dat_04_cst_sad_0_i_24_12_w
          ,dat_04_cst_sad_0_i_24_16_w
          ,dat_04_cst_sad_0_i_24_20_w
          ,dat_04_cst_sad_0_i_24_24_w
          ,dat_04_cst_sad_0_i_24_28_w
          ,dat_04_cst_sad_0_i_28_00_w
          ,dat_04_cst_sad_0_i_28_04_w
          ,dat_04_cst_sad_0_i_28_08_w
          ,dat_04_cst_sad_0_i_28_12_w
          ,dat_04_cst_sad_0_i_28_16_w
          ,dat_04_cst_sad_0_i_28_20_w
          ,dat_04_cst_sad_0_i_28_24_w
          ,dat_04_cst_sad_0_i_28_28_w
         } = dat_04_cst_sad_0_i ;

  // input cst layer 3
  assign { dat_08_cst_sad_0_i_00_00_w
          ,dat_08_cst_sad_0_i_00_08_w
          ,dat_08_cst_sad_0_i_00_16_w
          ,dat_08_cst_sad_0_i_00_24_w
          ,dat_08_cst_sad_0_i_08_00_w
          ,dat_08_cst_sad_0_i_08_08_w
          ,dat_08_cst_sad_0_i_08_16_w
          ,dat_08_cst_sad_0_i_08_24_w
          ,dat_08_cst_sad_0_i_16_00_w
          ,dat_08_cst_sad_0_i_16_08_w
          ,dat_08_cst_sad_0_i_16_16_w
          ,dat_08_cst_sad_0_i_16_24_w
          ,dat_08_cst_sad_0_i_24_00_w
          ,dat_08_cst_sad_0_i_24_08_w
          ,dat_08_cst_sad_0_i_24_16_w
          ,dat_08_cst_sad_0_i_24_24_w
         } = dat_08_cst_sad_0_i ;
  assign { dat_08_cst_sad_1_i_00_00_w
          ,dat_08_cst_sad_1_i_04_00_w
          ,dat_08_cst_sad_1_i_00_08_w
          ,dat_08_cst_sad_1_i_04_08_w
          ,dat_08_cst_sad_1_i_00_16_w
          ,dat_08_cst_sad_1_i_04_16_w
          ,dat_08_cst_sad_1_i_00_24_w
          ,dat_08_cst_sad_1_i_04_24_w
          ,dat_08_cst_sad_1_i_08_00_w
          ,dat_08_cst_sad_1_i_12_00_w
          ,dat_08_cst_sad_1_i_08_08_w
          ,dat_08_cst_sad_1_i_12_08_w
          ,dat_08_cst_sad_1_i_08_16_w
          ,dat_08_cst_sad_1_i_12_16_w
          ,dat_08_cst_sad_1_i_08_24_w
          ,dat_08_cst_sad_1_i_12_24_w
          ,dat_08_cst_sad_1_i_16_00_w
          ,dat_08_cst_sad_1_i_20_00_w
          ,dat_08_cst_sad_1_i_16_08_w
          ,dat_08_cst_sad_1_i_20_08_w
          ,dat_08_cst_sad_1_i_16_16_w
          ,dat_08_cst_sad_1_i_20_16_w
          ,dat_08_cst_sad_1_i_16_24_w
          ,dat_08_cst_sad_1_i_20_24_w
          ,dat_08_cst_sad_1_i_24_00_w
          ,dat_08_cst_sad_1_i_28_00_w
          ,dat_08_cst_sad_1_i_24_08_w
          ,dat_08_cst_sad_1_i_28_08_w
          ,dat_08_cst_sad_1_i_24_16_w
          ,dat_08_cst_sad_1_i_28_16_w
          ,dat_08_cst_sad_1_i_24_24_w
          ,dat_08_cst_sad_1_i_28_24_w
         } = dat_08_cst_sad_1_i ;
  assign { dat_08_cst_sad_2_i_00_00_w
          ,dat_08_cst_sad_2_i_00_04_w
          ,dat_08_cst_sad_2_i_00_08_w
          ,dat_08_cst_sad_2_i_00_12_w
          ,dat_08_cst_sad_2_i_00_16_w
          ,dat_08_cst_sad_2_i_00_20_w
          ,dat_08_cst_sad_2_i_00_24_w
          ,dat_08_cst_sad_2_i_00_28_w
          ,dat_08_cst_sad_2_i_08_00_w
          ,dat_08_cst_sad_2_i_08_04_w
          ,dat_08_cst_sad_2_i_08_08_w
          ,dat_08_cst_sad_2_i_08_12_w
          ,dat_08_cst_sad_2_i_08_16_w
          ,dat_08_cst_sad_2_i_08_20_w
          ,dat_08_cst_sad_2_i_08_24_w
          ,dat_08_cst_sad_2_i_08_28_w
          ,dat_08_cst_sad_2_i_16_00_w
          ,dat_08_cst_sad_2_i_16_04_w
          ,dat_08_cst_sad_2_i_16_08_w
          ,dat_08_cst_sad_2_i_16_12_w
          ,dat_08_cst_sad_2_i_16_16_w
          ,dat_08_cst_sad_2_i_16_20_w
          ,dat_08_cst_sad_2_i_16_24_w
          ,dat_08_cst_sad_2_i_16_28_w
          ,dat_08_cst_sad_2_i_24_00_w
          ,dat_08_cst_sad_2_i_24_04_w
          ,dat_08_cst_sad_2_i_24_08_w
          ,dat_08_cst_sad_2_i_24_12_w
          ,dat_08_cst_sad_2_i_24_16_w
          ,dat_08_cst_sad_2_i_24_20_w
          ,dat_08_cst_sad_2_i_24_24_w
          ,dat_08_cst_sad_2_i_24_28_w
         } = dat_08_cst_sad_2_i ;

  // input cst layer 4
  assign { dat_16_cst_sad_0_i_00_00_w
          ,dat_16_cst_sad_0_i_00_16_w
          ,dat_16_cst_sad_0_i_16_00_w
          ,dat_16_cst_sad_0_i_16_16_w
         } = dat_16_cst_sad_0_i ;
  assign { dat_16_cst_sad_1_i_00_00_w
          ,dat_16_cst_sad_1_i_08_00_w
          ,dat_16_cst_sad_1_i_00_16_w
          ,dat_16_cst_sad_1_i_08_16_w
          ,dat_16_cst_sad_1_i_16_00_w
          ,dat_16_cst_sad_1_i_24_00_w
          ,dat_16_cst_sad_1_i_16_16_w
          ,dat_16_cst_sad_1_i_24_16_w
         } = dat_16_cst_sad_1_i ;
  assign { dat_16_cst_sad_2_i_00_00_w
          ,dat_16_cst_sad_2_i_00_08_w
          ,dat_16_cst_sad_2_i_00_16_w
          ,dat_16_cst_sad_2_i_00_24_w
          ,dat_16_cst_sad_2_i_16_00_w
          ,dat_16_cst_sad_2_i_16_08_w
          ,dat_16_cst_sad_2_i_16_16_w
          ,dat_16_cst_sad_2_i_16_24_w
         } = dat_16_cst_sad_2_i ;

  // input cst layer 5
  assign { dat_32_cst_sad_0_i_00_00_w
         } = dat_32_cst_sad_0_i ;
  assign { dat_32_cst_sad_1_i_00_00_w
          ,dat_32_cst_sad_1_i_16_00_w
         } = dat_32_cst_sad_1_i ;
  assign { dat_32_cst_sad_2_i_00_00_w
          ,dat_32_cst_sad_2_i_00_16_w
         } = dat_32_cst_sad_2_i ;

  // output mv layer 3
  assign dat_08_mv_0_o = { dat_08_mv_0_o_00_00_r
                          ,dat_08_mv_0_o_00_08_r
                          ,dat_08_mv_0_o_00_16_r
                          ,dat_08_mv_0_o_00_24_r
                          ,dat_08_mv_0_o_00_32_r
                          ,dat_08_mv_0_o_00_40_r
                          ,dat_08_mv_0_o_00_48_r
                          ,dat_08_mv_0_o_00_56_r
                          ,dat_08_mv_0_o_08_00_r
                          ,dat_08_mv_0_o_08_08_r
                          ,dat_08_mv_0_o_08_16_r
                          ,dat_08_mv_0_o_08_24_r
                          ,dat_08_mv_0_o_08_32_r
                          ,dat_08_mv_0_o_08_40_r
                          ,dat_08_mv_0_o_08_48_r
                          ,dat_08_mv_0_o_08_56_r
                          ,dat_08_mv_0_o_16_00_r
                          ,dat_08_mv_0_o_16_08_r
                          ,dat_08_mv_0_o_16_16_r
                          ,dat_08_mv_0_o_16_24_r
                          ,dat_08_mv_0_o_16_32_r
                          ,dat_08_mv_0_o_16_40_r
                          ,dat_08_mv_0_o_16_48_r
                          ,dat_08_mv_0_o_16_56_r
                          ,dat_08_mv_0_o_24_00_r
                          ,dat_08_mv_0_o_24_08_r
                          ,dat_08_mv_0_o_24_16_r
                          ,dat_08_mv_0_o_24_24_r
                          ,dat_08_mv_0_o_24_32_r
                          ,dat_08_mv_0_o_24_40_r
                          ,dat_08_mv_0_o_24_48_r
                          ,dat_08_mv_0_o_24_56_r
                          ,dat_08_mv_0_o_32_00_r
                          ,dat_08_mv_0_o_32_08_r
                          ,dat_08_mv_0_o_32_16_r
                          ,dat_08_mv_0_o_32_24_r
                          ,dat_08_mv_0_o_32_32_r
                          ,dat_08_mv_0_o_32_40_r
                          ,dat_08_mv_0_o_32_48_r
                          ,dat_08_mv_0_o_32_56_r
                          ,dat_08_mv_0_o_40_00_r
                          ,dat_08_mv_0_o_40_08_r
                          ,dat_08_mv_0_o_40_16_r
                          ,dat_08_mv_0_o_40_24_r
                          ,dat_08_mv_0_o_40_32_r
                          ,dat_08_mv_0_o_40_40_r
                          ,dat_08_mv_0_o_40_48_r
                          ,dat_08_mv_0_o_40_56_r
                          ,dat_08_mv_0_o_48_00_r
                          ,dat_08_mv_0_o_48_08_r
                          ,dat_08_mv_0_o_48_16_r
                          ,dat_08_mv_0_o_48_24_r
                          ,dat_08_mv_0_o_48_32_r
                          ,dat_08_mv_0_o_48_40_r
                          ,dat_08_mv_0_o_48_48_r
                          ,dat_08_mv_0_o_48_56_r
                          ,dat_08_mv_0_o_56_00_r
                          ,dat_08_mv_0_o_56_08_r
                          ,dat_08_mv_0_o_56_16_r
                          ,dat_08_mv_0_o_56_24_r
                          ,dat_08_mv_0_o_56_32_r
                          ,dat_08_mv_0_o_56_40_r
                          ,dat_08_mv_0_o_56_48_r
                          ,dat_08_mv_0_o_56_56_r
                         };

  // output mv layer 4
  assign dat_16_mv_0_o = { dat_16_mv_0_o_00_00_r
                          ,dat_16_mv_0_o_00_16_r
                          ,dat_16_mv_0_o_00_32_r
                          ,dat_16_mv_0_o_00_48_r
                          ,dat_16_mv_0_o_16_00_r
                          ,dat_16_mv_0_o_16_16_r
                          ,dat_16_mv_0_o_16_32_r
                          ,dat_16_mv_0_o_16_48_r
                          ,dat_16_mv_0_o_32_00_r
                          ,dat_16_mv_0_o_32_16_r
                          ,dat_16_mv_0_o_32_32_r
                          ,dat_16_mv_0_o_32_48_r
                          ,dat_16_mv_0_o_48_00_r
                          ,dat_16_mv_0_o_48_16_r
                          ,dat_16_mv_0_o_48_32_r
                          ,dat_16_mv_0_o_48_48_r
                         };
  assign dat_16_mv_1_o = { dat_16_mv_1_o_00_00_r
                          ,dat_16_mv_1_o_08_00_r
                          ,dat_16_mv_1_o_00_16_r
                          ,dat_16_mv_1_o_08_16_r
                          ,dat_16_mv_1_o_00_32_r
                          ,dat_16_mv_1_o_08_32_r
                          ,dat_16_mv_1_o_00_48_r
                          ,dat_16_mv_1_o_08_48_r
                          ,dat_16_mv_1_o_16_00_r
                          ,dat_16_mv_1_o_24_00_r
                          ,dat_16_mv_1_o_16_16_r
                          ,dat_16_mv_1_o_24_16_r
                          ,dat_16_mv_1_o_16_32_r
                          ,dat_16_mv_1_o_24_32_r
                          ,dat_16_mv_1_o_16_48_r
                          ,dat_16_mv_1_o_24_48_r
                          ,dat_16_mv_1_o_32_00_r
                          ,dat_16_mv_1_o_40_00_r
                          ,dat_16_mv_1_o_32_16_r
                          ,dat_16_mv_1_o_40_16_r
                          ,dat_16_mv_1_o_32_32_r
                          ,dat_16_mv_1_o_40_32_r
                          ,dat_16_mv_1_o_32_48_r
                          ,dat_16_mv_1_o_40_48_r
                          ,dat_16_mv_1_o_48_00_r
                          ,dat_16_mv_1_o_56_00_r
                          ,dat_16_mv_1_o_48_16_r
                          ,dat_16_mv_1_o_56_16_r
                          ,dat_16_mv_1_o_48_32_r
                          ,dat_16_mv_1_o_56_32_r
                          ,dat_16_mv_1_o_48_48_r
                          ,dat_16_mv_1_o_56_48_r
                         };
  assign dat_16_mv_2_o = { dat_16_mv_2_o_00_00_r
                          ,dat_16_mv_2_o_00_08_r
                          ,dat_16_mv_2_o_00_16_r
                          ,dat_16_mv_2_o_00_24_r
                          ,dat_16_mv_2_o_00_32_r
                          ,dat_16_mv_2_o_00_40_r
                          ,dat_16_mv_2_o_00_48_r
                          ,dat_16_mv_2_o_00_56_r
                          ,dat_16_mv_2_o_16_00_r
                          ,dat_16_mv_2_o_16_08_r
                          ,dat_16_mv_2_o_16_16_r
                          ,dat_16_mv_2_o_16_24_r
                          ,dat_16_mv_2_o_16_32_r
                          ,dat_16_mv_2_o_16_40_r
                          ,dat_16_mv_2_o_16_48_r
                          ,dat_16_mv_2_o_16_56_r
                          ,dat_16_mv_2_o_32_00_r
                          ,dat_16_mv_2_o_32_08_r
                          ,dat_16_mv_2_o_32_16_r
                          ,dat_16_mv_2_o_32_24_r
                          ,dat_16_mv_2_o_32_32_r
                          ,dat_16_mv_2_o_32_40_r
                          ,dat_16_mv_2_o_32_48_r
                          ,dat_16_mv_2_o_32_56_r
                          ,dat_16_mv_2_o_48_00_r
                          ,dat_16_mv_2_o_48_08_r
                          ,dat_16_mv_2_o_48_16_r
                          ,dat_16_mv_2_o_48_24_r
                          ,dat_16_mv_2_o_48_32_r
                          ,dat_16_mv_2_o_48_40_r
                          ,dat_16_mv_2_o_48_48_r
                          ,dat_16_mv_2_o_48_56_r
                         };

  // output mv layer 5
  assign dat_32_mv_0_o = { dat_32_mv_0_o_00_00_r
                          ,dat_32_mv_0_o_00_32_r
                          ,dat_32_mv_0_o_32_00_r
                          ,dat_32_mv_0_o_32_32_r
                         };
  assign dat_32_mv_1_o = { dat_32_mv_1_o_00_00_r
                          ,dat_32_mv_1_o_16_00_r
                          ,dat_32_mv_1_o_00_32_r
                          ,dat_32_mv_1_o_16_32_r
                          ,dat_32_mv_1_o_32_00_r
                          ,dat_32_mv_1_o_48_00_r
                          ,dat_32_mv_1_o_32_32_r
                          ,dat_32_mv_1_o_48_32_r
                         };
  assign dat_32_mv_2_o = { dat_32_mv_2_o_00_00_r
                          ,dat_32_mv_2_o_00_16_r
                          ,dat_32_mv_2_o_00_32_r
                          ,dat_32_mv_2_o_00_48_r
                          ,dat_32_mv_2_o_32_00_r
                          ,dat_32_mv_2_o_32_16_r
                          ,dat_32_mv_2_o_32_32_r
                          ,dat_32_mv_2_o_32_48_r
                         };

  // output mv layer 6
  assign dat_64_mv_0_o = { dat_64_mv_0_o_00_00_r
                         };
  assign dat_64_mv_1_o = { dat_64_mv_1_o_00_00_r
                          ,dat_64_mv_1_o_32_00_r
                         };
  assign dat_64_mv_2_o = { dat_64_mv_2_o_00_00_r
                          ,dat_64_mv_2_o_00_32_r
                         };

  // output cst layer 3
  assign dat_08_cst_0_o = { dat_08_cst_0_o_00_00_r
                           ,dat_08_cst_0_o_00_08_r
                           ,dat_08_cst_0_o_00_16_r
                           ,dat_08_cst_0_o_00_24_r
                           ,dat_08_cst_0_o_00_32_r
                           ,dat_08_cst_0_o_00_40_r
                           ,dat_08_cst_0_o_00_48_r
                           ,dat_08_cst_0_o_00_56_r
                           ,dat_08_cst_0_o_08_00_r
                           ,dat_08_cst_0_o_08_08_r
                           ,dat_08_cst_0_o_08_16_r
                           ,dat_08_cst_0_o_08_24_r
                           ,dat_08_cst_0_o_08_32_r
                           ,dat_08_cst_0_o_08_40_r
                           ,dat_08_cst_0_o_08_48_r
                           ,dat_08_cst_0_o_08_56_r
                           ,dat_08_cst_0_o_16_00_r
                           ,dat_08_cst_0_o_16_08_r
                           ,dat_08_cst_0_o_16_16_r
                           ,dat_08_cst_0_o_16_24_r
                           ,dat_08_cst_0_o_16_32_r
                           ,dat_08_cst_0_o_16_40_r
                           ,dat_08_cst_0_o_16_48_r
                           ,dat_08_cst_0_o_16_56_r
                           ,dat_08_cst_0_o_24_00_r
                           ,dat_08_cst_0_o_24_08_r
                           ,dat_08_cst_0_o_24_16_r
                           ,dat_08_cst_0_o_24_24_r
                           ,dat_08_cst_0_o_24_32_r
                           ,dat_08_cst_0_o_24_40_r
                           ,dat_08_cst_0_o_24_48_r
                           ,dat_08_cst_0_o_24_56_r
                           ,dat_08_cst_0_o_32_00_r
                           ,dat_08_cst_0_o_32_08_r
                           ,dat_08_cst_0_o_32_16_r
                           ,dat_08_cst_0_o_32_24_r
                           ,dat_08_cst_0_o_32_32_r
                           ,dat_08_cst_0_o_32_40_r
                           ,dat_08_cst_0_o_32_48_r
                           ,dat_08_cst_0_o_32_56_r
                           ,dat_08_cst_0_o_40_00_r
                           ,dat_08_cst_0_o_40_08_r
                           ,dat_08_cst_0_o_40_16_r
                           ,dat_08_cst_0_o_40_24_r
                           ,dat_08_cst_0_o_40_32_r
                           ,dat_08_cst_0_o_40_40_r
                           ,dat_08_cst_0_o_40_48_r
                           ,dat_08_cst_0_o_40_56_r
                           ,dat_08_cst_0_o_48_00_r
                           ,dat_08_cst_0_o_48_08_r
                           ,dat_08_cst_0_o_48_16_r
                           ,dat_08_cst_0_o_48_24_r
                           ,dat_08_cst_0_o_48_32_r
                           ,dat_08_cst_0_o_48_40_r
                           ,dat_08_cst_0_o_48_48_r
                           ,dat_08_cst_0_o_48_56_r
                           ,dat_08_cst_0_o_56_00_r
                           ,dat_08_cst_0_o_56_08_r
                           ,dat_08_cst_0_o_56_16_r
                           ,dat_08_cst_0_o_56_24_r
                           ,dat_08_cst_0_o_56_32_r
                           ,dat_08_cst_0_o_56_40_r
                           ,dat_08_cst_0_o_56_48_r
                           ,dat_08_cst_0_o_56_56_r
                          };

  // output cst layer 4
  assign dat_16_cst_0_o = { dat_16_cst_0_o_00_00_r
                           ,dat_16_cst_0_o_00_16_r
                           ,dat_16_cst_0_o_00_32_r
                           ,dat_16_cst_0_o_00_48_r
                           ,dat_16_cst_0_o_16_00_r
                           ,dat_16_cst_0_o_16_16_r
                           ,dat_16_cst_0_o_16_32_r
                           ,dat_16_cst_0_o_16_48_r
                           ,dat_16_cst_0_o_32_00_r
                           ,dat_16_cst_0_o_32_16_r
                           ,dat_16_cst_0_o_32_32_r
                           ,dat_16_cst_0_o_32_48_r
                           ,dat_16_cst_0_o_48_00_r
                           ,dat_16_cst_0_o_48_16_r
                           ,dat_16_cst_0_o_48_32_r
                           ,dat_16_cst_0_o_48_48_r
                          };
  assign dat_16_cst_1_o = { dat_16_cst_1_o_00_00_r
                           ,dat_16_cst_1_o_08_00_r
                           ,dat_16_cst_1_o_00_16_r
                           ,dat_16_cst_1_o_08_16_r
                           ,dat_16_cst_1_o_00_32_r
                           ,dat_16_cst_1_o_08_32_r
                           ,dat_16_cst_1_o_00_48_r
                           ,dat_16_cst_1_o_08_48_r
                           ,dat_16_cst_1_o_16_00_r
                           ,dat_16_cst_1_o_24_00_r
                           ,dat_16_cst_1_o_16_16_r
                           ,dat_16_cst_1_o_24_16_r
                           ,dat_16_cst_1_o_16_32_r
                           ,dat_16_cst_1_o_24_32_r
                           ,dat_16_cst_1_o_16_48_r
                           ,dat_16_cst_1_o_24_48_r
                           ,dat_16_cst_1_o_32_00_r
                           ,dat_16_cst_1_o_40_00_r
                           ,dat_16_cst_1_o_32_16_r
                           ,dat_16_cst_1_o_40_16_r
                           ,dat_16_cst_1_o_32_32_r
                           ,dat_16_cst_1_o_40_32_r
                           ,dat_16_cst_1_o_32_48_r
                           ,dat_16_cst_1_o_40_48_r
                           ,dat_16_cst_1_o_48_00_r
                           ,dat_16_cst_1_o_56_00_r
                           ,dat_16_cst_1_o_48_16_r
                           ,dat_16_cst_1_o_56_16_r
                           ,dat_16_cst_1_o_48_32_r
                           ,dat_16_cst_1_o_56_32_r
                           ,dat_16_cst_1_o_48_48_r
                           ,dat_16_cst_1_o_56_48_r
                          };
  assign dat_16_cst_2_o = { dat_16_cst_2_o_00_00_r
                           ,dat_16_cst_2_o_00_08_r
                           ,dat_16_cst_2_o_00_16_r
                           ,dat_16_cst_2_o_00_24_r
                           ,dat_16_cst_2_o_00_32_r
                           ,dat_16_cst_2_o_00_40_r
                           ,dat_16_cst_2_o_00_48_r
                           ,dat_16_cst_2_o_00_56_r
                           ,dat_16_cst_2_o_16_00_r
                           ,dat_16_cst_2_o_16_08_r
                           ,dat_16_cst_2_o_16_16_r
                           ,dat_16_cst_2_o_16_24_r
                           ,dat_16_cst_2_o_16_32_r
                           ,dat_16_cst_2_o_16_40_r
                           ,dat_16_cst_2_o_16_48_r
                           ,dat_16_cst_2_o_16_56_r
                           ,dat_16_cst_2_o_32_00_r
                           ,dat_16_cst_2_o_32_08_r
                           ,dat_16_cst_2_o_32_16_r
                           ,dat_16_cst_2_o_32_24_r
                           ,dat_16_cst_2_o_32_32_r
                           ,dat_16_cst_2_o_32_40_r
                           ,dat_16_cst_2_o_32_48_r
                           ,dat_16_cst_2_o_32_56_r
                           ,dat_16_cst_2_o_48_00_r
                           ,dat_16_cst_2_o_48_08_r
                           ,dat_16_cst_2_o_48_16_r
                           ,dat_16_cst_2_o_48_24_r
                           ,dat_16_cst_2_o_48_32_r
                           ,dat_16_cst_2_o_48_40_r
                           ,dat_16_cst_2_o_48_48_r
                           ,dat_16_cst_2_o_48_56_r
                          };

  // output cst layer 5
  assign dat_32_cst_0_o = { dat_32_cst_0_o_00_00_r
                           ,dat_32_cst_0_o_00_32_r
                           ,dat_32_cst_0_o_32_00_r
                           ,dat_32_cst_0_o_32_32_r
                          };
  assign dat_32_cst_1_o = { dat_32_cst_1_o_00_00_r
                           ,dat_32_cst_1_o_16_00_r
                           ,dat_32_cst_1_o_00_32_r
                           ,dat_32_cst_1_o_16_32_r
                           ,dat_32_cst_1_o_32_00_r
                           ,dat_32_cst_1_o_48_00_r
                           ,dat_32_cst_1_o_32_32_r
                           ,dat_32_cst_1_o_48_32_r
                          };
  assign dat_32_cst_2_o = { dat_32_cst_2_o_00_00_r
                           ,dat_32_cst_2_o_00_16_r
                           ,dat_32_cst_2_o_00_32_r
                           ,dat_32_cst_2_o_00_48_r
                           ,dat_32_cst_2_o_32_00_r
                           ,dat_32_cst_2_o_32_16_r
                           ,dat_32_cst_2_o_32_32_r
                           ,dat_32_cst_2_o_32_48_r
                          };

  // output cst layer 6
  assign dat_64_cst_0_o = { dat_64_cst_0_o_00_00_r
                          };
  assign dat_64_cst_1_o = { dat_64_cst_1_o_00_00_r
                           ,dat_64_cst_1_o_32_00_r
                          };
  assign dat_64_cst_2_o = { dat_64_cst_2_o_00_00_r
                           ,dat_64_cst_2_o_00_32_r
                          };


//--- MERGE ----------------------------
  // output cst layer 2
  assign dat_04_cst_0_i_00_00_f_w = ( downsample_i ? dat_04_cst_sad_0_i_00_00_w<<2 : dat_04_cst_sad_0_i_00_00_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_00_04_f_w = ( downsample_i ? dat_04_cst_sad_0_i_00_04_w<<2 : dat_04_cst_sad_0_i_00_04_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_00_08_f_w = ( downsample_i ? dat_04_cst_sad_0_i_00_08_w<<2 : dat_04_cst_sad_0_i_00_08_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_00_12_f_w = ( downsample_i ? dat_04_cst_sad_0_i_00_12_w<<2 : dat_04_cst_sad_0_i_00_12_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_00_16_f_w = ( downsample_i ? dat_04_cst_sad_0_i_00_16_w<<2 : dat_04_cst_sad_0_i_00_16_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_00_20_f_w = ( downsample_i ? dat_04_cst_sad_0_i_00_20_w<<2 : dat_04_cst_sad_0_i_00_20_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_00_24_f_w = ( downsample_i ? dat_04_cst_sad_0_i_00_24_w<<2 : dat_04_cst_sad_0_i_00_24_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_00_28_f_w = ( downsample_i ? dat_04_cst_sad_0_i_00_28_w<<2 : dat_04_cst_sad_0_i_00_28_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_04_00_f_w = ( downsample_i ? dat_04_cst_sad_0_i_04_00_w<<2 : dat_04_cst_sad_0_i_04_00_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_04_04_f_w = ( downsample_i ? dat_04_cst_sad_0_i_04_04_w<<2 : dat_04_cst_sad_0_i_04_04_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_04_08_f_w = ( downsample_i ? dat_04_cst_sad_0_i_04_08_w<<2 : dat_04_cst_sad_0_i_04_08_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_04_12_f_w = ( downsample_i ? dat_04_cst_sad_0_i_04_12_w<<2 : dat_04_cst_sad_0_i_04_12_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_04_16_f_w = ( downsample_i ? dat_04_cst_sad_0_i_04_16_w<<2 : dat_04_cst_sad_0_i_04_16_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_04_20_f_w = ( downsample_i ? dat_04_cst_sad_0_i_04_20_w<<2 : dat_04_cst_sad_0_i_04_20_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_04_24_f_w = ( downsample_i ? dat_04_cst_sad_0_i_04_24_w<<2 : dat_04_cst_sad_0_i_04_24_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_04_28_f_w = ( downsample_i ? dat_04_cst_sad_0_i_04_28_w<<2 : dat_04_cst_sad_0_i_04_28_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_08_00_f_w = ( downsample_i ? dat_04_cst_sad_0_i_08_00_w<<2 : dat_04_cst_sad_0_i_08_00_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_08_04_f_w = ( downsample_i ? dat_04_cst_sad_0_i_08_04_w<<2 : dat_04_cst_sad_0_i_08_04_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_08_08_f_w = ( downsample_i ? dat_04_cst_sad_0_i_08_08_w<<2 : dat_04_cst_sad_0_i_08_08_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_08_12_f_w = ( downsample_i ? dat_04_cst_sad_0_i_08_12_w<<2 : dat_04_cst_sad_0_i_08_12_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_08_16_f_w = ( downsample_i ? dat_04_cst_sad_0_i_08_16_w<<2 : dat_04_cst_sad_0_i_08_16_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_08_20_f_w = ( downsample_i ? dat_04_cst_sad_0_i_08_20_w<<2 : dat_04_cst_sad_0_i_08_20_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_08_24_f_w = ( downsample_i ? dat_04_cst_sad_0_i_08_24_w<<2 : dat_04_cst_sad_0_i_08_24_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_08_28_f_w = ( downsample_i ? dat_04_cst_sad_0_i_08_28_w<<2 : dat_04_cst_sad_0_i_08_28_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_12_00_f_w = ( downsample_i ? dat_04_cst_sad_0_i_12_00_w<<2 : dat_04_cst_sad_0_i_12_00_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_12_04_f_w = ( downsample_i ? dat_04_cst_sad_0_i_12_04_w<<2 : dat_04_cst_sad_0_i_12_04_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_12_08_f_w = ( downsample_i ? dat_04_cst_sad_0_i_12_08_w<<2 : dat_04_cst_sad_0_i_12_08_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_12_12_f_w = ( downsample_i ? dat_04_cst_sad_0_i_12_12_w<<2 : dat_04_cst_sad_0_i_12_12_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_12_16_f_w = ( downsample_i ? dat_04_cst_sad_0_i_12_16_w<<2 : dat_04_cst_sad_0_i_12_16_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_12_20_f_w = ( downsample_i ? dat_04_cst_sad_0_i_12_20_w<<2 : dat_04_cst_sad_0_i_12_20_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_12_24_f_w = ( downsample_i ? dat_04_cst_sad_0_i_12_24_w<<2 : dat_04_cst_sad_0_i_12_24_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_12_28_f_w = ( downsample_i ? dat_04_cst_sad_0_i_12_28_w<<2 : dat_04_cst_sad_0_i_12_28_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_16_00_f_w = ( downsample_i ? dat_04_cst_sad_0_i_16_00_w<<2 : dat_04_cst_sad_0_i_16_00_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_16_04_f_w = ( downsample_i ? dat_04_cst_sad_0_i_16_04_w<<2 : dat_04_cst_sad_0_i_16_04_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_16_08_f_w = ( downsample_i ? dat_04_cst_sad_0_i_16_08_w<<2 : dat_04_cst_sad_0_i_16_08_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_16_12_f_w = ( downsample_i ? dat_04_cst_sad_0_i_16_12_w<<2 : dat_04_cst_sad_0_i_16_12_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_16_16_f_w = ( downsample_i ? dat_04_cst_sad_0_i_16_16_w<<2 : dat_04_cst_sad_0_i_16_16_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_16_20_f_w = ( downsample_i ? dat_04_cst_sad_0_i_16_20_w<<2 : dat_04_cst_sad_0_i_16_20_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_16_24_f_w = ( downsample_i ? dat_04_cst_sad_0_i_16_24_w<<2 : dat_04_cst_sad_0_i_16_24_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_16_28_f_w = ( downsample_i ? dat_04_cst_sad_0_i_16_28_w<<2 : dat_04_cst_sad_0_i_16_28_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_20_00_f_w = ( downsample_i ? dat_04_cst_sad_0_i_20_00_w<<2 : dat_04_cst_sad_0_i_20_00_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_20_04_f_w = ( downsample_i ? dat_04_cst_sad_0_i_20_04_w<<2 : dat_04_cst_sad_0_i_20_04_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_20_08_f_w = ( downsample_i ? dat_04_cst_sad_0_i_20_08_w<<2 : dat_04_cst_sad_0_i_20_08_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_20_12_f_w = ( downsample_i ? dat_04_cst_sad_0_i_20_12_w<<2 : dat_04_cst_sad_0_i_20_12_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_20_16_f_w = ( downsample_i ? dat_04_cst_sad_0_i_20_16_w<<2 : dat_04_cst_sad_0_i_20_16_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_20_20_f_w = ( downsample_i ? dat_04_cst_sad_0_i_20_20_w<<2 : dat_04_cst_sad_0_i_20_20_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_20_24_f_w = ( downsample_i ? dat_04_cst_sad_0_i_20_24_w<<2 : dat_04_cst_sad_0_i_20_24_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_20_28_f_w = ( downsample_i ? dat_04_cst_sad_0_i_20_28_w<<2 : dat_04_cst_sad_0_i_20_28_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_24_00_f_w = ( downsample_i ? dat_04_cst_sad_0_i_24_00_w<<2 : dat_04_cst_sad_0_i_24_00_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_24_04_f_w = ( downsample_i ? dat_04_cst_sad_0_i_24_04_w<<2 : dat_04_cst_sad_0_i_24_04_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_24_08_f_w = ( downsample_i ? dat_04_cst_sad_0_i_24_08_w<<2 : dat_04_cst_sad_0_i_24_08_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_24_12_f_w = ( downsample_i ? dat_04_cst_sad_0_i_24_12_w<<2 : dat_04_cst_sad_0_i_24_12_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_24_16_f_w = ( downsample_i ? dat_04_cst_sad_0_i_24_16_w<<2 : dat_04_cst_sad_0_i_24_16_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_24_20_f_w = ( downsample_i ? dat_04_cst_sad_0_i_24_20_w<<2 : dat_04_cst_sad_0_i_24_20_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_24_24_f_w = ( downsample_i ? dat_04_cst_sad_0_i_24_24_w<<2 : dat_04_cst_sad_0_i_24_24_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_24_28_f_w = ( downsample_i ? dat_04_cst_sad_0_i_24_28_w<<2 : dat_04_cst_sad_0_i_24_28_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_28_00_f_w = ( downsample_i ? dat_04_cst_sad_0_i_28_00_w<<2 : dat_04_cst_sad_0_i_28_00_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_28_04_f_w = ( downsample_i ? dat_04_cst_sad_0_i_28_04_w<<2 : dat_04_cst_sad_0_i_28_04_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_28_08_f_w = ( downsample_i ? dat_04_cst_sad_0_i_28_08_w<<2 : dat_04_cst_sad_0_i_28_08_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_28_12_f_w = ( downsample_i ? dat_04_cst_sad_0_i_28_12_w<<2 : dat_04_cst_sad_0_i_28_12_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_28_16_f_w = ( downsample_i ? dat_04_cst_sad_0_i_28_16_w<<2 : dat_04_cst_sad_0_i_28_16_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_28_20_f_w = ( downsample_i ? dat_04_cst_sad_0_i_28_20_w<<2 : dat_04_cst_sad_0_i_28_20_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_28_24_f_w = ( downsample_i ? dat_04_cst_sad_0_i_28_24_w<<2 : dat_04_cst_sad_0_i_28_24_w )+ dat_04_cst_mvd_i ;
  assign dat_04_cst_0_i_28_28_f_w = ( downsample_i ? dat_04_cst_sad_0_i_28_28_w<<2 : dat_04_cst_sad_0_i_28_28_w )+ dat_04_cst_mvd_i ;

  // output cst layer 3
  assign dat_08_cst_0_i_00_00_f_w = ( downsample_i ? dat_08_cst_sad_0_i_00_00_w<<2 : dat_08_cst_sad_0_i_00_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_00_00_f_w = ( downsample_i ? dat_08_cst_sad_1_i_00_00_w<<2 : dat_08_cst_sad_1_i_00_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_04_00_f_w = ( downsample_i ? dat_08_cst_sad_1_i_04_00_w<<2 : dat_08_cst_sad_1_i_04_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_00_00_f_w = ( downsample_i ? dat_08_cst_sad_2_i_00_00_w<<2 : dat_08_cst_sad_2_i_00_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_00_04_f_w = ( downsample_i ? dat_08_cst_sad_2_i_00_04_w<<2 : dat_08_cst_sad_2_i_00_04_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_00_08_f_w = ( downsample_i ? dat_08_cst_sad_0_i_00_08_w<<2 : dat_08_cst_sad_0_i_00_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_00_08_f_w = ( downsample_i ? dat_08_cst_sad_1_i_00_08_w<<2 : dat_08_cst_sad_1_i_00_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_04_08_f_w = ( downsample_i ? dat_08_cst_sad_1_i_04_08_w<<2 : dat_08_cst_sad_1_i_04_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_00_08_f_w = ( downsample_i ? dat_08_cst_sad_2_i_00_08_w<<2 : dat_08_cst_sad_2_i_00_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_00_12_f_w = ( downsample_i ? dat_08_cst_sad_2_i_00_12_w<<2 : dat_08_cst_sad_2_i_00_12_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_00_16_f_w = ( downsample_i ? dat_08_cst_sad_0_i_00_16_w<<2 : dat_08_cst_sad_0_i_00_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_00_16_f_w = ( downsample_i ? dat_08_cst_sad_1_i_00_16_w<<2 : dat_08_cst_sad_1_i_00_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_04_16_f_w = ( downsample_i ? dat_08_cst_sad_1_i_04_16_w<<2 : dat_08_cst_sad_1_i_04_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_00_16_f_w = ( downsample_i ? dat_08_cst_sad_2_i_00_16_w<<2 : dat_08_cst_sad_2_i_00_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_00_20_f_w = ( downsample_i ? dat_08_cst_sad_2_i_00_20_w<<2 : dat_08_cst_sad_2_i_00_20_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_00_24_f_w = ( downsample_i ? dat_08_cst_sad_0_i_00_24_w<<2 : dat_08_cst_sad_0_i_00_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_00_24_f_w = ( downsample_i ? dat_08_cst_sad_1_i_00_24_w<<2 : dat_08_cst_sad_1_i_00_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_04_24_f_w = ( downsample_i ? dat_08_cst_sad_1_i_04_24_w<<2 : dat_08_cst_sad_1_i_04_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_00_24_f_w = ( downsample_i ? dat_08_cst_sad_2_i_00_24_w<<2 : dat_08_cst_sad_2_i_00_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_00_28_f_w = ( downsample_i ? dat_08_cst_sad_2_i_00_28_w<<2 : dat_08_cst_sad_2_i_00_28_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_08_00_f_w = ( downsample_i ? dat_08_cst_sad_0_i_08_00_w<<2 : dat_08_cst_sad_0_i_08_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_08_00_f_w = ( downsample_i ? dat_08_cst_sad_1_i_08_00_w<<2 : dat_08_cst_sad_1_i_08_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_12_00_f_w = ( downsample_i ? dat_08_cst_sad_1_i_12_00_w<<2 : dat_08_cst_sad_1_i_12_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_08_00_f_w = ( downsample_i ? dat_08_cst_sad_2_i_08_00_w<<2 : dat_08_cst_sad_2_i_08_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_08_04_f_w = ( downsample_i ? dat_08_cst_sad_2_i_08_04_w<<2 : dat_08_cst_sad_2_i_08_04_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_08_08_f_w = ( downsample_i ? dat_08_cst_sad_0_i_08_08_w<<2 : dat_08_cst_sad_0_i_08_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_08_08_f_w = ( downsample_i ? dat_08_cst_sad_1_i_08_08_w<<2 : dat_08_cst_sad_1_i_08_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_12_08_f_w = ( downsample_i ? dat_08_cst_sad_1_i_12_08_w<<2 : dat_08_cst_sad_1_i_12_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_08_08_f_w = ( downsample_i ? dat_08_cst_sad_2_i_08_08_w<<2 : dat_08_cst_sad_2_i_08_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_08_12_f_w = ( downsample_i ? dat_08_cst_sad_2_i_08_12_w<<2 : dat_08_cst_sad_2_i_08_12_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_08_16_f_w = ( downsample_i ? dat_08_cst_sad_0_i_08_16_w<<2 : dat_08_cst_sad_0_i_08_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_08_16_f_w = ( downsample_i ? dat_08_cst_sad_1_i_08_16_w<<2 : dat_08_cst_sad_1_i_08_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_12_16_f_w = ( downsample_i ? dat_08_cst_sad_1_i_12_16_w<<2 : dat_08_cst_sad_1_i_12_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_08_16_f_w = ( downsample_i ? dat_08_cst_sad_2_i_08_16_w<<2 : dat_08_cst_sad_2_i_08_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_08_20_f_w = ( downsample_i ? dat_08_cst_sad_2_i_08_20_w<<2 : dat_08_cst_sad_2_i_08_20_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_08_24_f_w = ( downsample_i ? dat_08_cst_sad_0_i_08_24_w<<2 : dat_08_cst_sad_0_i_08_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_08_24_f_w = ( downsample_i ? dat_08_cst_sad_1_i_08_24_w<<2 : dat_08_cst_sad_1_i_08_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_12_24_f_w = ( downsample_i ? dat_08_cst_sad_1_i_12_24_w<<2 : dat_08_cst_sad_1_i_12_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_08_24_f_w = ( downsample_i ? dat_08_cst_sad_2_i_08_24_w<<2 : dat_08_cst_sad_2_i_08_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_08_28_f_w = ( downsample_i ? dat_08_cst_sad_2_i_08_28_w<<2 : dat_08_cst_sad_2_i_08_28_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_16_00_f_w = ( downsample_i ? dat_08_cst_sad_0_i_16_00_w<<2 : dat_08_cst_sad_0_i_16_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_16_00_f_w = ( downsample_i ? dat_08_cst_sad_1_i_16_00_w<<2 : dat_08_cst_sad_1_i_16_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_20_00_f_w = ( downsample_i ? dat_08_cst_sad_1_i_20_00_w<<2 : dat_08_cst_sad_1_i_20_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_16_00_f_w = ( downsample_i ? dat_08_cst_sad_2_i_16_00_w<<2 : dat_08_cst_sad_2_i_16_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_16_04_f_w = ( downsample_i ? dat_08_cst_sad_2_i_16_04_w<<2 : dat_08_cst_sad_2_i_16_04_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_16_08_f_w = ( downsample_i ? dat_08_cst_sad_0_i_16_08_w<<2 : dat_08_cst_sad_0_i_16_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_16_08_f_w = ( downsample_i ? dat_08_cst_sad_1_i_16_08_w<<2 : dat_08_cst_sad_1_i_16_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_20_08_f_w = ( downsample_i ? dat_08_cst_sad_1_i_20_08_w<<2 : dat_08_cst_sad_1_i_20_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_16_08_f_w = ( downsample_i ? dat_08_cst_sad_2_i_16_08_w<<2 : dat_08_cst_sad_2_i_16_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_16_12_f_w = ( downsample_i ? dat_08_cst_sad_2_i_16_12_w<<2 : dat_08_cst_sad_2_i_16_12_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_16_16_f_w = ( downsample_i ? dat_08_cst_sad_0_i_16_16_w<<2 : dat_08_cst_sad_0_i_16_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_16_16_f_w = ( downsample_i ? dat_08_cst_sad_1_i_16_16_w<<2 : dat_08_cst_sad_1_i_16_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_20_16_f_w = ( downsample_i ? dat_08_cst_sad_1_i_20_16_w<<2 : dat_08_cst_sad_1_i_20_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_16_16_f_w = ( downsample_i ? dat_08_cst_sad_2_i_16_16_w<<2 : dat_08_cst_sad_2_i_16_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_16_20_f_w = ( downsample_i ? dat_08_cst_sad_2_i_16_20_w<<2 : dat_08_cst_sad_2_i_16_20_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_16_24_f_w = ( downsample_i ? dat_08_cst_sad_0_i_16_24_w<<2 : dat_08_cst_sad_0_i_16_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_16_24_f_w = ( downsample_i ? dat_08_cst_sad_1_i_16_24_w<<2 : dat_08_cst_sad_1_i_16_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_20_24_f_w = ( downsample_i ? dat_08_cst_sad_1_i_20_24_w<<2 : dat_08_cst_sad_1_i_20_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_16_24_f_w = ( downsample_i ? dat_08_cst_sad_2_i_16_24_w<<2 : dat_08_cst_sad_2_i_16_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_16_28_f_w = ( downsample_i ? dat_08_cst_sad_2_i_16_28_w<<2 : dat_08_cst_sad_2_i_16_28_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_24_00_f_w = ( downsample_i ? dat_08_cst_sad_0_i_24_00_w<<2 : dat_08_cst_sad_0_i_24_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_24_00_f_w = ( downsample_i ? dat_08_cst_sad_1_i_24_00_w<<2 : dat_08_cst_sad_1_i_24_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_28_00_f_w = ( downsample_i ? dat_08_cst_sad_1_i_28_00_w<<2 : dat_08_cst_sad_1_i_28_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_24_00_f_w = ( downsample_i ? dat_08_cst_sad_2_i_24_00_w<<2 : dat_08_cst_sad_2_i_24_00_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_24_04_f_w = ( downsample_i ? dat_08_cst_sad_2_i_24_04_w<<2 : dat_08_cst_sad_2_i_24_04_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_24_08_f_w = ( downsample_i ? dat_08_cst_sad_0_i_24_08_w<<2 : dat_08_cst_sad_0_i_24_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_24_08_f_w = ( downsample_i ? dat_08_cst_sad_1_i_24_08_w<<2 : dat_08_cst_sad_1_i_24_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_28_08_f_w = ( downsample_i ? dat_08_cst_sad_1_i_28_08_w<<2 : dat_08_cst_sad_1_i_28_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_24_08_f_w = ( downsample_i ? dat_08_cst_sad_2_i_24_08_w<<2 : dat_08_cst_sad_2_i_24_08_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_24_12_f_w = ( downsample_i ? dat_08_cst_sad_2_i_24_12_w<<2 : dat_08_cst_sad_2_i_24_12_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_24_16_f_w = ( downsample_i ? dat_08_cst_sad_0_i_24_16_w<<2 : dat_08_cst_sad_0_i_24_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_24_16_f_w = ( downsample_i ? dat_08_cst_sad_1_i_24_16_w<<2 : dat_08_cst_sad_1_i_24_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_28_16_f_w = ( downsample_i ? dat_08_cst_sad_1_i_28_16_w<<2 : dat_08_cst_sad_1_i_28_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_24_16_f_w = ( downsample_i ? dat_08_cst_sad_2_i_24_16_w<<2 : dat_08_cst_sad_2_i_24_16_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_24_20_f_w = ( downsample_i ? dat_08_cst_sad_2_i_24_20_w<<2 : dat_08_cst_sad_2_i_24_20_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_0_i_24_24_f_w = ( downsample_i ? dat_08_cst_sad_0_i_24_24_w<<2 : dat_08_cst_sad_0_i_24_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_24_24_f_w = ( downsample_i ? dat_08_cst_sad_1_i_24_24_w<<2 : dat_08_cst_sad_1_i_24_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_1_i_28_24_f_w = ( downsample_i ? dat_08_cst_sad_1_i_28_24_w<<2 : dat_08_cst_sad_1_i_28_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_24_24_f_w = ( downsample_i ? dat_08_cst_sad_2_i_24_24_w<<2 : dat_08_cst_sad_2_i_24_24_w )+ dat_08_cst_mvd_i ;
  assign dat_08_cst_2_i_24_28_f_w = ( downsample_i ? dat_08_cst_sad_2_i_24_28_w<<2 : dat_08_cst_sad_2_i_24_28_w )+ dat_08_cst_mvd_i ;

  // output cst layer 4
  assign dat_16_cst_0_i_00_00_f_w = ( downsample_i ? dat_16_cst_sad_0_i_00_00_w<<2 : dat_16_cst_sad_0_i_00_00_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_1_i_00_00_f_w = ( downsample_i ? dat_16_cst_sad_1_i_00_00_w<<2 : dat_16_cst_sad_1_i_00_00_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_1_i_08_00_f_w = ( downsample_i ? dat_16_cst_sad_1_i_08_00_w<<2 : dat_16_cst_sad_1_i_08_00_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_2_i_00_00_f_w = ( downsample_i ? dat_16_cst_sad_2_i_00_00_w<<2 : dat_16_cst_sad_2_i_00_00_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_2_i_00_08_f_w = ( downsample_i ? dat_16_cst_sad_2_i_00_08_w<<2 : dat_16_cst_sad_2_i_00_08_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_0_i_00_16_f_w = ( downsample_i ? dat_16_cst_sad_0_i_00_16_w<<2 : dat_16_cst_sad_0_i_00_16_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_1_i_00_16_f_w = ( downsample_i ? dat_16_cst_sad_1_i_00_16_w<<2 : dat_16_cst_sad_1_i_00_16_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_1_i_08_16_f_w = ( downsample_i ? dat_16_cst_sad_1_i_08_16_w<<2 : dat_16_cst_sad_1_i_08_16_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_2_i_00_16_f_w = ( downsample_i ? dat_16_cst_sad_2_i_00_16_w<<2 : dat_16_cst_sad_2_i_00_16_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_2_i_00_24_f_w = ( downsample_i ? dat_16_cst_sad_2_i_00_24_w<<2 : dat_16_cst_sad_2_i_00_24_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_0_i_16_00_f_w = ( downsample_i ? dat_16_cst_sad_0_i_16_00_w<<2 : dat_16_cst_sad_0_i_16_00_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_1_i_16_00_f_w = ( downsample_i ? dat_16_cst_sad_1_i_16_00_w<<2 : dat_16_cst_sad_1_i_16_00_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_1_i_24_00_f_w = ( downsample_i ? dat_16_cst_sad_1_i_24_00_w<<2 : dat_16_cst_sad_1_i_24_00_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_2_i_16_00_f_w = ( downsample_i ? dat_16_cst_sad_2_i_16_00_w<<2 : dat_16_cst_sad_2_i_16_00_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_2_i_16_08_f_w = ( downsample_i ? dat_16_cst_sad_2_i_16_08_w<<2 : dat_16_cst_sad_2_i_16_08_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_0_i_16_16_f_w = ( downsample_i ? dat_16_cst_sad_0_i_16_16_w<<2 : dat_16_cst_sad_0_i_16_16_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_1_i_16_16_f_w = ( downsample_i ? dat_16_cst_sad_1_i_16_16_w<<2 : dat_16_cst_sad_1_i_16_16_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_1_i_24_16_f_w = ( downsample_i ? dat_16_cst_sad_1_i_24_16_w<<2 : dat_16_cst_sad_1_i_24_16_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_2_i_16_16_f_w = ( downsample_i ? dat_16_cst_sad_2_i_16_16_w<<2 : dat_16_cst_sad_2_i_16_16_w )+ dat_16_cst_mvd_i ;
  assign dat_16_cst_2_i_16_24_f_w = ( downsample_i ? dat_16_cst_sad_2_i_16_24_w<<2 : dat_16_cst_sad_2_i_16_24_w )+ dat_16_cst_mvd_i ;

  // output cst layer 5
  assign dat_32_cst_0_i_00_00_f_w = ( downsample_i ? dat_32_cst_sad_0_i_00_00_w<<2 : dat_32_cst_sad_0_i_00_00_w )+ dat_32_cst_mvd_i ;
  assign dat_32_cst_1_i_00_00_f_w = ( downsample_i ? dat_32_cst_sad_1_i_00_00_w<<2 : dat_32_cst_sad_1_i_00_00_w )+ dat_32_cst_mvd_i ;
  assign dat_32_cst_1_i_16_00_f_w = ( downsample_i ? dat_32_cst_sad_1_i_16_00_w<<2 : dat_32_cst_sad_1_i_16_00_w )+ dat_32_cst_mvd_i ;
  assign dat_32_cst_2_i_00_00_f_w = ( downsample_i ? dat_32_cst_sad_2_i_00_00_w<<2 : dat_32_cst_sad_2_i_00_00_w )+ dat_32_cst_mvd_i ;
  assign dat_32_cst_2_i_00_16_f_w = ( downsample_i ? dat_32_cst_sad_2_i_00_16_w<<2 : dat_32_cst_sad_2_i_00_16_w )+ dat_32_cst_mvd_i ;

  // input cst layer 2
  assign dat_04_cst_0_i_00_00_w = (dat_04_cst_0_i_00_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_00_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_00_04_w = (dat_04_cst_0_i_00_04_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_00_04_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_00_08_w = (dat_04_cst_0_i_00_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_00_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_00_12_w = (dat_04_cst_0_i_00_12_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_00_12_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_00_16_w = (dat_04_cst_0_i_00_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_00_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_00_20_w = (dat_04_cst_0_i_00_20_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_00_20_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_00_24_w = (dat_04_cst_0_i_00_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_00_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_00_28_w = (dat_04_cst_0_i_00_28_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_00_28_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_04_00_w = (dat_04_cst_0_i_04_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_04_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_04_04_w = (dat_04_cst_0_i_04_04_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_04_04_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_04_08_w = (dat_04_cst_0_i_04_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_04_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_04_12_w = (dat_04_cst_0_i_04_12_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_04_12_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_04_16_w = (dat_04_cst_0_i_04_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_04_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_04_20_w = (dat_04_cst_0_i_04_20_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_04_20_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_04_24_w = (dat_04_cst_0_i_04_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_04_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_04_28_w = (dat_04_cst_0_i_04_28_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_04_28_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_08_00_w = (dat_04_cst_0_i_08_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_08_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_08_04_w = (dat_04_cst_0_i_08_04_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_08_04_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_08_08_w = (dat_04_cst_0_i_08_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_08_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_08_12_w = (dat_04_cst_0_i_08_12_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_08_12_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_08_16_w = (dat_04_cst_0_i_08_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_08_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_08_20_w = (dat_04_cst_0_i_08_20_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_08_20_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_08_24_w = (dat_04_cst_0_i_08_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_08_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_08_28_w = (dat_04_cst_0_i_08_28_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_08_28_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_12_00_w = (dat_04_cst_0_i_12_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_12_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_12_04_w = (dat_04_cst_0_i_12_04_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_12_04_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_12_08_w = (dat_04_cst_0_i_12_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_12_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_12_12_w = (dat_04_cst_0_i_12_12_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_12_12_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_12_16_w = (dat_04_cst_0_i_12_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_12_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_12_20_w = (dat_04_cst_0_i_12_20_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_12_20_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_12_24_w = (dat_04_cst_0_i_12_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_12_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_12_28_w = (dat_04_cst_0_i_12_28_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_12_28_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_16_00_w = (dat_04_cst_0_i_16_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_16_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_16_04_w = (dat_04_cst_0_i_16_04_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_16_04_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_16_08_w = (dat_04_cst_0_i_16_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_16_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_16_12_w = (dat_04_cst_0_i_16_12_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_16_12_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_16_16_w = (dat_04_cst_0_i_16_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_16_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_16_20_w = (dat_04_cst_0_i_16_20_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_16_20_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_16_24_w = (dat_04_cst_0_i_16_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_16_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_16_28_w = (dat_04_cst_0_i_16_28_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_16_28_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_20_00_w = (dat_04_cst_0_i_20_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_20_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_20_04_w = (dat_04_cst_0_i_20_04_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_20_04_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_20_08_w = (dat_04_cst_0_i_20_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_20_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_20_12_w = (dat_04_cst_0_i_20_12_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_20_12_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_20_16_w = (dat_04_cst_0_i_20_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_20_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_20_20_w = (dat_04_cst_0_i_20_20_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_20_20_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_20_24_w = (dat_04_cst_0_i_20_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_20_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_20_28_w = (dat_04_cst_0_i_20_28_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_20_28_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_24_00_w = (dat_04_cst_0_i_24_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_24_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_24_04_w = (dat_04_cst_0_i_24_04_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_24_04_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_24_08_w = (dat_04_cst_0_i_24_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_24_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_24_12_w = (dat_04_cst_0_i_24_12_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_24_12_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_24_16_w = (dat_04_cst_0_i_24_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_24_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_24_20_w = (dat_04_cst_0_i_24_20_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_24_20_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_24_24_w = (dat_04_cst_0_i_24_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_24_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_24_28_w = (dat_04_cst_0_i_24_28_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_24_28_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_28_00_w = (dat_04_cst_0_i_28_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_28_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_28_04_w = (dat_04_cst_0_i_28_04_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_28_04_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_28_08_w = (dat_04_cst_0_i_28_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_28_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_28_12_w = (dat_04_cst_0_i_28_12_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_28_12_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_28_16_w = (dat_04_cst_0_i_28_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_28_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_28_20_w = (dat_04_cst_0_i_28_20_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_28_20_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_28_24_w = (dat_04_cst_0_i_28_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_28_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_04_cst_0_i_28_28_w = (dat_04_cst_0_i_28_28_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_04_cst_0_i_28_28_f_w : {{`IME_COST_WIDTH{1'b1}}} ;

  // input cst layer 3
  assign dat_08_cst_0_i_00_00_w = (dat_08_cst_0_i_00_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_00_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_00_00_w = (dat_08_cst_1_i_00_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_00_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_04_00_w = (dat_08_cst_1_i_04_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_04_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_00_00_w = (dat_08_cst_2_i_00_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_00_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_00_04_w = (dat_08_cst_2_i_00_04_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_00_04_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_00_08_w = (dat_08_cst_0_i_00_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_00_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_00_08_w = (dat_08_cst_1_i_00_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_00_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_04_08_w = (dat_08_cst_1_i_04_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_04_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_00_08_w = (dat_08_cst_2_i_00_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_00_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_00_12_w = (dat_08_cst_2_i_00_12_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_00_12_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_00_16_w = (dat_08_cst_0_i_00_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_00_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_00_16_w = (dat_08_cst_1_i_00_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_00_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_04_16_w = (dat_08_cst_1_i_04_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_04_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_00_16_w = (dat_08_cst_2_i_00_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_00_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_00_20_w = (dat_08_cst_2_i_00_20_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_00_20_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_00_24_w = (dat_08_cst_0_i_00_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_00_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_00_24_w = (dat_08_cst_1_i_00_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_00_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_04_24_w = (dat_08_cst_1_i_04_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_04_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_00_24_w = (dat_08_cst_2_i_00_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_00_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_00_28_w = (dat_08_cst_2_i_00_28_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_00_28_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_08_00_w = (dat_08_cst_0_i_08_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_08_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_08_00_w = (dat_08_cst_1_i_08_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_08_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_12_00_w = (dat_08_cst_1_i_12_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_12_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_08_00_w = (dat_08_cst_2_i_08_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_08_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_08_04_w = (dat_08_cst_2_i_08_04_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_08_04_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_08_08_w = (dat_08_cst_0_i_08_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_08_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_08_08_w = (dat_08_cst_1_i_08_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_08_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_12_08_w = (dat_08_cst_1_i_12_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_12_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_08_08_w = (dat_08_cst_2_i_08_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_08_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_08_12_w = (dat_08_cst_2_i_08_12_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_08_12_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_08_16_w = (dat_08_cst_0_i_08_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_08_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_08_16_w = (dat_08_cst_1_i_08_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_08_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_12_16_w = (dat_08_cst_1_i_12_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_12_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_08_16_w = (dat_08_cst_2_i_08_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_08_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_08_20_w = (dat_08_cst_2_i_08_20_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_08_20_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_08_24_w = (dat_08_cst_0_i_08_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_08_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_08_24_w = (dat_08_cst_1_i_08_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_08_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_12_24_w = (dat_08_cst_1_i_12_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_12_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_08_24_w = (dat_08_cst_2_i_08_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_08_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_08_28_w = (dat_08_cst_2_i_08_28_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_08_28_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_16_00_w = (dat_08_cst_0_i_16_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_16_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_16_00_w = (dat_08_cst_1_i_16_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_16_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_20_00_w = (dat_08_cst_1_i_20_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_20_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_16_00_w = (dat_08_cst_2_i_16_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_16_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_16_04_w = (dat_08_cst_2_i_16_04_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_16_04_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_16_08_w = (dat_08_cst_0_i_16_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_16_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_16_08_w = (dat_08_cst_1_i_16_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_16_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_20_08_w = (dat_08_cst_1_i_20_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_20_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_16_08_w = (dat_08_cst_2_i_16_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_16_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_16_12_w = (dat_08_cst_2_i_16_12_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_16_12_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_16_16_w = (dat_08_cst_0_i_16_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_16_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_16_16_w = (dat_08_cst_1_i_16_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_16_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_20_16_w = (dat_08_cst_1_i_20_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_20_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_16_16_w = (dat_08_cst_2_i_16_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_16_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_16_20_w = (dat_08_cst_2_i_16_20_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_16_20_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_16_24_w = (dat_08_cst_0_i_16_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_16_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_16_24_w = (dat_08_cst_1_i_16_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_16_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_20_24_w = (dat_08_cst_1_i_20_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_20_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_16_24_w = (dat_08_cst_2_i_16_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_16_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_16_28_w = (dat_08_cst_2_i_16_28_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_16_28_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_24_00_w = (dat_08_cst_0_i_24_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_24_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_24_00_w = (dat_08_cst_1_i_24_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_24_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_28_00_w = (dat_08_cst_1_i_28_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_28_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_24_00_w = (dat_08_cst_2_i_24_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_24_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_24_04_w = (dat_08_cst_2_i_24_04_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_24_04_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_24_08_w = (dat_08_cst_0_i_24_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_24_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_24_08_w = (dat_08_cst_1_i_24_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_24_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_28_08_w = (dat_08_cst_1_i_28_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_28_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_24_08_w = (dat_08_cst_2_i_24_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_24_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_24_12_w = (dat_08_cst_2_i_24_12_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_24_12_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_24_16_w = (dat_08_cst_0_i_24_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_24_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_24_16_w = (dat_08_cst_1_i_24_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_24_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_28_16_w = (dat_08_cst_1_i_28_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_28_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_24_16_w = (dat_08_cst_2_i_24_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_24_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_24_20_w = (dat_08_cst_2_i_24_20_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_24_20_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_0_i_24_24_w = (dat_08_cst_0_i_24_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_0_i_24_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_24_24_w = (dat_08_cst_1_i_24_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_24_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_1_i_28_24_w = (dat_08_cst_1_i_28_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_1_i_28_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_24_24_w = (dat_08_cst_2_i_24_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_24_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_08_cst_2_i_24_28_w = (dat_08_cst_2_i_24_28_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_08_cst_2_i_24_28_f_w : {{`IME_COST_WIDTH{1'b1}}} ;

  // input cst layer 4
  assign dat_16_cst_0_i_00_00_w = (dat_16_cst_0_i_00_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_0_i_00_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_1_i_00_00_w = (dat_16_cst_1_i_00_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_1_i_00_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_1_i_08_00_w = (dat_16_cst_1_i_08_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_1_i_08_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_2_i_00_00_w = (dat_16_cst_2_i_00_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_2_i_00_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_2_i_00_08_w = (dat_16_cst_2_i_00_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_2_i_00_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_0_i_00_16_w = (dat_16_cst_0_i_00_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_0_i_00_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_1_i_00_16_w = (dat_16_cst_1_i_00_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_1_i_00_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_1_i_08_16_w = (dat_16_cst_1_i_08_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_1_i_08_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_2_i_00_16_w = (dat_16_cst_2_i_00_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_2_i_00_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_2_i_00_24_w = (dat_16_cst_2_i_00_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_2_i_00_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_0_i_16_00_w = (dat_16_cst_0_i_16_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_0_i_16_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_1_i_16_00_w = (dat_16_cst_1_i_16_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_1_i_16_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_1_i_24_00_w = (dat_16_cst_1_i_24_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_1_i_24_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_2_i_16_00_w = (dat_16_cst_2_i_16_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_2_i_16_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_2_i_16_08_w = (dat_16_cst_2_i_16_08_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_2_i_16_08_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_0_i_16_16_w = (dat_16_cst_0_i_16_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_0_i_16_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_1_i_16_16_w = (dat_16_cst_1_i_16_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_1_i_16_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_1_i_24_16_w = (dat_16_cst_1_i_24_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_1_i_24_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_2_i_16_16_w = (dat_16_cst_2_i_16_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_2_i_16_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_16_cst_2_i_16_24_w = (dat_16_cst_2_i_16_24_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_16_cst_2_i_16_24_f_w : {{`IME_COST_WIDTH{1'b1}}} ;

  // input cst layer 5
  assign dat_32_cst_0_i_00_00_w = (dat_32_cst_0_i_00_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_32_cst_0_i_00_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_32_cst_1_i_00_00_w = (dat_32_cst_1_i_00_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_32_cst_1_i_00_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_32_cst_1_i_16_00_w = (dat_32_cst_1_i_16_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_32_cst_1_i_16_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_32_cst_2_i_00_00_w = (dat_32_cst_2_i_00_00_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_32_cst_2_i_00_00_f_w : {{`IME_COST_WIDTH{1'b1}}} ;
  assign dat_32_cst_2_i_00_16_w = (dat_32_cst_2_i_00_16_f_w<{{`IME_COST_WIDTH{1'b1}}}) ? dat_32_cst_2_i_00_16_f_w : {{`IME_COST_WIDTH{1'b1}}} ;


//--- UPDATE ---------------------------
  // mv & cst
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      // mv layer 3
      dat_08_mv_0_o_00_00_r <= 0 ;
      dat_08_mv_0_o_00_08_r <= 0 ;
      dat_08_mv_0_o_00_16_r <= 0 ;
      dat_08_mv_0_o_00_24_r <= 0 ;
      dat_08_mv_0_o_00_32_r <= 0 ;
      dat_08_mv_0_o_00_40_r <= 0 ;
      dat_08_mv_0_o_00_48_r <= 0 ;
      dat_08_mv_0_o_00_56_r <= 0 ;
      dat_08_mv_0_o_08_00_r <= 0 ;
      dat_08_mv_0_o_08_08_r <= 0 ;
      dat_08_mv_0_o_08_16_r <= 0 ;
      dat_08_mv_0_o_08_24_r <= 0 ;
      dat_08_mv_0_o_08_32_r <= 0 ;
      dat_08_mv_0_o_08_40_r <= 0 ;
      dat_08_mv_0_o_08_48_r <= 0 ;
      dat_08_mv_0_o_08_56_r <= 0 ;
      dat_08_mv_0_o_16_00_r <= 0 ;
      dat_08_mv_0_o_16_08_r <= 0 ;
      dat_08_mv_0_o_16_16_r <= 0 ;
      dat_08_mv_0_o_16_24_r <= 0 ;
      dat_08_mv_0_o_16_32_r <= 0 ;
      dat_08_mv_0_o_16_40_r <= 0 ;
      dat_08_mv_0_o_16_48_r <= 0 ;
      dat_08_mv_0_o_16_56_r <= 0 ;
      dat_08_mv_0_o_24_00_r <= 0 ;
      dat_08_mv_0_o_24_08_r <= 0 ;
      dat_08_mv_0_o_24_16_r <= 0 ;
      dat_08_mv_0_o_24_24_r <= 0 ;
      dat_08_mv_0_o_24_32_r <= 0 ;
      dat_08_mv_0_o_24_40_r <= 0 ;
      dat_08_mv_0_o_24_48_r <= 0 ;
      dat_08_mv_0_o_24_56_r <= 0 ;
      dat_08_mv_0_o_32_00_r <= 0 ;
      dat_08_mv_0_o_32_08_r <= 0 ;
      dat_08_mv_0_o_32_16_r <= 0 ;
      dat_08_mv_0_o_32_24_r <= 0 ;
      dat_08_mv_0_o_32_32_r <= 0 ;
      dat_08_mv_0_o_32_40_r <= 0 ;
      dat_08_mv_0_o_32_48_r <= 0 ;
      dat_08_mv_0_o_32_56_r <= 0 ;
      dat_08_mv_0_o_40_00_r <= 0 ;
      dat_08_mv_0_o_40_08_r <= 0 ;
      dat_08_mv_0_o_40_16_r <= 0 ;
      dat_08_mv_0_o_40_24_r <= 0 ;
      dat_08_mv_0_o_40_32_r <= 0 ;
      dat_08_mv_0_o_40_40_r <= 0 ;
      dat_08_mv_0_o_40_48_r <= 0 ;
      dat_08_mv_0_o_40_56_r <= 0 ;
      dat_08_mv_0_o_48_00_r <= 0 ;
      dat_08_mv_0_o_48_08_r <= 0 ;
      dat_08_mv_0_o_48_16_r <= 0 ;
      dat_08_mv_0_o_48_24_r <= 0 ;
      dat_08_mv_0_o_48_32_r <= 0 ;
      dat_08_mv_0_o_48_40_r <= 0 ;
      dat_08_mv_0_o_48_48_r <= 0 ;
      dat_08_mv_0_o_48_56_r <= 0 ;
      dat_08_mv_0_o_56_00_r <= 0 ;
      dat_08_mv_0_o_56_08_r <= 0 ;
      dat_08_mv_0_o_56_16_r <= 0 ;
      dat_08_mv_0_o_56_24_r <= 0 ;
      dat_08_mv_0_o_56_32_r <= 0 ;
      dat_08_mv_0_o_56_40_r <= 0 ;
      dat_08_mv_0_o_56_48_r <= 0 ;
      dat_08_mv_0_o_56_56_r <= 0 ;
      // mv layer 4
      dat_16_mv_0_o_00_00_r <= 0 ;
      dat_16_mv_0_o_00_16_r <= 0 ;
      dat_16_mv_0_o_00_32_r <= 0 ;
      dat_16_mv_0_o_00_48_r <= 0 ;
      dat_16_mv_0_o_16_00_r <= 0 ;
      dat_16_mv_0_o_16_16_r <= 0 ;
      dat_16_mv_0_o_16_32_r <= 0 ;
      dat_16_mv_0_o_16_48_r <= 0 ;
      dat_16_mv_0_o_32_00_r <= 0 ;
      dat_16_mv_0_o_32_16_r <= 0 ;
      dat_16_mv_0_o_32_32_r <= 0 ;
      dat_16_mv_0_o_32_48_r <= 0 ;
      dat_16_mv_0_o_48_00_r <= 0 ;
      dat_16_mv_0_o_48_16_r <= 0 ;
      dat_16_mv_0_o_48_32_r <= 0 ;
      dat_16_mv_0_o_48_48_r <= 0 ;
      dat_16_mv_1_o_00_00_r <= 0 ;
      dat_16_mv_1_o_08_00_r <= 0 ;
      dat_16_mv_1_o_00_16_r <= 0 ;
      dat_16_mv_1_o_08_16_r <= 0 ;
      dat_16_mv_1_o_00_32_r <= 0 ;
      dat_16_mv_1_o_08_32_r <= 0 ;
      dat_16_mv_1_o_00_48_r <= 0 ;
      dat_16_mv_1_o_08_48_r <= 0 ;
      dat_16_mv_1_o_16_00_r <= 0 ;
      dat_16_mv_1_o_24_00_r <= 0 ;
      dat_16_mv_1_o_16_16_r <= 0 ;
      dat_16_mv_1_o_24_16_r <= 0 ;
      dat_16_mv_1_o_16_32_r <= 0 ;
      dat_16_mv_1_o_24_32_r <= 0 ;
      dat_16_mv_1_o_16_48_r <= 0 ;
      dat_16_mv_1_o_24_48_r <= 0 ;
      dat_16_mv_1_o_32_00_r <= 0 ;
      dat_16_mv_1_o_40_00_r <= 0 ;
      dat_16_mv_1_o_32_16_r <= 0 ;
      dat_16_mv_1_o_40_16_r <= 0 ;
      dat_16_mv_1_o_32_32_r <= 0 ;
      dat_16_mv_1_o_40_32_r <= 0 ;
      dat_16_mv_1_o_32_48_r <= 0 ;
      dat_16_mv_1_o_40_48_r <= 0 ;
      dat_16_mv_1_o_48_00_r <= 0 ;
      dat_16_mv_1_o_56_00_r <= 0 ;
      dat_16_mv_1_o_48_16_r <= 0 ;
      dat_16_mv_1_o_56_16_r <= 0 ;
      dat_16_mv_1_o_48_32_r <= 0 ;
      dat_16_mv_1_o_56_32_r <= 0 ;
      dat_16_mv_1_o_48_48_r <= 0 ;
      dat_16_mv_1_o_56_48_r <= 0 ;
      dat_16_mv_2_o_00_00_r <= 0 ;
      dat_16_mv_2_o_00_08_r <= 0 ;
      dat_16_mv_2_o_00_16_r <= 0 ;
      dat_16_mv_2_o_00_24_r <= 0 ;
      dat_16_mv_2_o_00_32_r <= 0 ;
      dat_16_mv_2_o_00_40_r <= 0 ;
      dat_16_mv_2_o_00_48_r <= 0 ;
      dat_16_mv_2_o_00_56_r <= 0 ;
      dat_16_mv_2_o_16_00_r <= 0 ;
      dat_16_mv_2_o_16_08_r <= 0 ;
      dat_16_mv_2_o_16_16_r <= 0 ;
      dat_16_mv_2_o_16_24_r <= 0 ;
      dat_16_mv_2_o_16_32_r <= 0 ;
      dat_16_mv_2_o_16_40_r <= 0 ;
      dat_16_mv_2_o_16_48_r <= 0 ;
      dat_16_mv_2_o_16_56_r <= 0 ;
      dat_16_mv_2_o_32_00_r <= 0 ;
      dat_16_mv_2_o_32_08_r <= 0 ;
      dat_16_mv_2_o_32_16_r <= 0 ;
      dat_16_mv_2_o_32_24_r <= 0 ;
      dat_16_mv_2_o_32_32_r <= 0 ;
      dat_16_mv_2_o_32_40_r <= 0 ;
      dat_16_mv_2_o_32_48_r <= 0 ;
      dat_16_mv_2_o_32_56_r <= 0 ;
      dat_16_mv_2_o_48_00_r <= 0 ;
      dat_16_mv_2_o_48_08_r <= 0 ;
      dat_16_mv_2_o_48_16_r <= 0 ;
      dat_16_mv_2_o_48_24_r <= 0 ;
      dat_16_mv_2_o_48_32_r <= 0 ;
      dat_16_mv_2_o_48_40_r <= 0 ;
      dat_16_mv_2_o_48_48_r <= 0 ;
      dat_16_mv_2_o_48_56_r <= 0 ;
      // mv layer 5
      dat_32_mv_0_o_00_00_r <= 0 ;
      dat_32_mv_0_o_00_32_r <= 0 ;
      dat_32_mv_0_o_32_00_r <= 0 ;
      dat_32_mv_0_o_32_32_r <= 0 ;
      dat_32_mv_1_o_00_00_r <= 0 ;
      dat_32_mv_1_o_16_00_r <= 0 ;
      dat_32_mv_1_o_00_32_r <= 0 ;
      dat_32_mv_1_o_16_32_r <= 0 ;
      dat_32_mv_1_o_32_00_r <= 0 ;
      dat_32_mv_1_o_48_00_r <= 0 ;
      dat_32_mv_1_o_32_32_r <= 0 ;
      dat_32_mv_1_o_48_32_r <= 0 ;
      dat_32_mv_2_o_00_00_r <= 0 ;
      dat_32_mv_2_o_00_16_r <= 0 ;
      dat_32_mv_2_o_00_32_r <= 0 ;
      dat_32_mv_2_o_00_48_r <= 0 ;
      dat_32_mv_2_o_32_00_r <= 0 ;
      dat_32_mv_2_o_32_16_r <= 0 ;
      dat_32_mv_2_o_32_32_r <= 0 ;
      dat_32_mv_2_o_32_48_r <= 0 ;
      // mv layer 6
      dat_64_mv_0_o_00_00_r <= 0 ;
      dat_64_mv_1_o_00_00_r <= 0 ;
      dat_64_mv_1_o_32_00_r <= 0 ;
      dat_64_mv_2_o_00_00_r <= 0 ;
      dat_64_mv_2_o_00_32_r <= 0 ;
      // cst layer 3
      dat_08_cst_0_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_00_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_00_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_00_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_00_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_00_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_00_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_08_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_08_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_08_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_08_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_08_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_08_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_08_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_08_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_16_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_16_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_16_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_16_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_16_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_16_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_16_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_16_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_24_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_24_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_24_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_24_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_24_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_24_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_24_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_24_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_32_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_32_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_32_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_32_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_32_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_32_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_40_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_40_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_40_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_40_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_40_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_40_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_40_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_40_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_48_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_48_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_48_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_48_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_48_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_48_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_48_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_48_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_56_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_56_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_56_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_56_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_56_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_56_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_56_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_08_cst_0_o_56_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      // cst layer 4
      dat_16_cst_0_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_00_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_00_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_16_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_16_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_16_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_16_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_32_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_32_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_48_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_48_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_48_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_0_o_48_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_08_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_00_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_08_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_08_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_00_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_08_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_16_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_24_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_16_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_24_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_16_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_24_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_16_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_24_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_40_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_32_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_40_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_40_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_32_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_40_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_48_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_56_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_48_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_56_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_48_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_56_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_48_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_1_o_56_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_00_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_00_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_00_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_00_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_00_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_00_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_16_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_16_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_16_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_16_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_16_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_16_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_16_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_16_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_32_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_32_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_32_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_32_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_32_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_32_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_48_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_48_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_48_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_48_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_48_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_48_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_48_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_16_cst_2_o_48_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      // cst layer 5
      dat_32_cst_0_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_0_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_0_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_0_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_1_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_1_o_16_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_1_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_1_o_16_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_1_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_1_o_48_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_1_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_1_o_48_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_2_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_2_o_00_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_2_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_2_o_00_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_2_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_2_o_32_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_2_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_32_cst_2_o_32_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      // cst layer 6
      dat_64_cst_0_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_64_cst_1_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_64_cst_1_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_64_cst_2_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      dat_64_cst_2_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
    end
    else begin
      if( clear_i ) begin
        // mv layer 3
        dat_08_mv_0_o_00_00_r <= 0 ;
        dat_08_mv_0_o_00_08_r <= 0 ;
        dat_08_mv_0_o_00_16_r <= 0 ;
        dat_08_mv_0_o_00_24_r <= 0 ;
        dat_08_mv_0_o_00_32_r <= 0 ;
        dat_08_mv_0_o_00_40_r <= 0 ;
        dat_08_mv_0_o_00_48_r <= 0 ;
        dat_08_mv_0_o_00_56_r <= 0 ;
        dat_08_mv_0_o_08_00_r <= 0 ;
        dat_08_mv_0_o_08_08_r <= 0 ;
        dat_08_mv_0_o_08_16_r <= 0 ;
        dat_08_mv_0_o_08_24_r <= 0 ;
        dat_08_mv_0_o_08_32_r <= 0 ;
        dat_08_mv_0_o_08_40_r <= 0 ;
        dat_08_mv_0_o_08_48_r <= 0 ;
        dat_08_mv_0_o_08_56_r <= 0 ;
        dat_08_mv_0_o_16_00_r <= 0 ;
        dat_08_mv_0_o_16_08_r <= 0 ;
        dat_08_mv_0_o_16_16_r <= 0 ;
        dat_08_mv_0_o_16_24_r <= 0 ;
        dat_08_mv_0_o_16_32_r <= 0 ;
        dat_08_mv_0_o_16_40_r <= 0 ;
        dat_08_mv_0_o_16_48_r <= 0 ;
        dat_08_mv_0_o_16_56_r <= 0 ;
        dat_08_mv_0_o_24_00_r <= 0 ;
        dat_08_mv_0_o_24_08_r <= 0 ;
        dat_08_mv_0_o_24_16_r <= 0 ;
        dat_08_mv_0_o_24_24_r <= 0 ;
        dat_08_mv_0_o_24_32_r <= 0 ;
        dat_08_mv_0_o_24_40_r <= 0 ;
        dat_08_mv_0_o_24_48_r <= 0 ;
        dat_08_mv_0_o_24_56_r <= 0 ;
        dat_08_mv_0_o_32_00_r <= 0 ;
        dat_08_mv_0_o_32_08_r <= 0 ;
        dat_08_mv_0_o_32_16_r <= 0 ;
        dat_08_mv_0_o_32_24_r <= 0 ;
        dat_08_mv_0_o_32_32_r <= 0 ;
        dat_08_mv_0_o_32_40_r <= 0 ;
        dat_08_mv_0_o_32_48_r <= 0 ;
        dat_08_mv_0_o_32_56_r <= 0 ;
        dat_08_mv_0_o_40_00_r <= 0 ;
        dat_08_mv_0_o_40_08_r <= 0 ;
        dat_08_mv_0_o_40_16_r <= 0 ;
        dat_08_mv_0_o_40_24_r <= 0 ;
        dat_08_mv_0_o_40_32_r <= 0 ;
        dat_08_mv_0_o_40_40_r <= 0 ;
        dat_08_mv_0_o_40_48_r <= 0 ;
        dat_08_mv_0_o_40_56_r <= 0 ;
        dat_08_mv_0_o_48_00_r <= 0 ;
        dat_08_mv_0_o_48_08_r <= 0 ;
        dat_08_mv_0_o_48_16_r <= 0 ;
        dat_08_mv_0_o_48_24_r <= 0 ;
        dat_08_mv_0_o_48_32_r <= 0 ;
        dat_08_mv_0_o_48_40_r <= 0 ;
        dat_08_mv_0_o_48_48_r <= 0 ;
        dat_08_mv_0_o_48_56_r <= 0 ;
        dat_08_mv_0_o_56_00_r <= 0 ;
        dat_08_mv_0_o_56_08_r <= 0 ;
        dat_08_mv_0_o_56_16_r <= 0 ;
        dat_08_mv_0_o_56_24_r <= 0 ;
        dat_08_mv_0_o_56_32_r <= 0 ;
        dat_08_mv_0_o_56_40_r <= 0 ;
        dat_08_mv_0_o_56_48_r <= 0 ;
        dat_08_mv_0_o_56_56_r <= 0 ;
        // mv layer 4
        dat_16_mv_0_o_00_00_r <= 0 ;
        dat_16_mv_0_o_00_16_r <= 0 ;
        dat_16_mv_0_o_00_32_r <= 0 ;
        dat_16_mv_0_o_00_48_r <= 0 ;
        dat_16_mv_0_o_16_00_r <= 0 ;
        dat_16_mv_0_o_16_16_r <= 0 ;
        dat_16_mv_0_o_16_32_r <= 0 ;
        dat_16_mv_0_o_16_48_r <= 0 ;
        dat_16_mv_0_o_32_00_r <= 0 ;
        dat_16_mv_0_o_32_16_r <= 0 ;
        dat_16_mv_0_o_32_32_r <= 0 ;
        dat_16_mv_0_o_32_48_r <= 0 ;
        dat_16_mv_0_o_48_00_r <= 0 ;
        dat_16_mv_0_o_48_16_r <= 0 ;
        dat_16_mv_0_o_48_32_r <= 0 ;
        dat_16_mv_0_o_48_48_r <= 0 ;
        dat_16_mv_1_o_00_00_r <= 0 ;
        dat_16_mv_1_o_08_00_r <= 0 ;
        dat_16_mv_1_o_00_16_r <= 0 ;
        dat_16_mv_1_o_08_16_r <= 0 ;
        dat_16_mv_1_o_00_32_r <= 0 ;
        dat_16_mv_1_o_08_32_r <= 0 ;
        dat_16_mv_1_o_00_48_r <= 0 ;
        dat_16_mv_1_o_08_48_r <= 0 ;
        dat_16_mv_1_o_16_00_r <= 0 ;
        dat_16_mv_1_o_24_00_r <= 0 ;
        dat_16_mv_1_o_16_16_r <= 0 ;
        dat_16_mv_1_o_24_16_r <= 0 ;
        dat_16_mv_1_o_16_32_r <= 0 ;
        dat_16_mv_1_o_24_32_r <= 0 ;
        dat_16_mv_1_o_16_48_r <= 0 ;
        dat_16_mv_1_o_24_48_r <= 0 ;
        dat_16_mv_1_o_32_00_r <= 0 ;
        dat_16_mv_1_o_40_00_r <= 0 ;
        dat_16_mv_1_o_32_16_r <= 0 ;
        dat_16_mv_1_o_40_16_r <= 0 ;
        dat_16_mv_1_o_32_32_r <= 0 ;
        dat_16_mv_1_o_40_32_r <= 0 ;
        dat_16_mv_1_o_32_48_r <= 0 ;
        dat_16_mv_1_o_40_48_r <= 0 ;
        dat_16_mv_1_o_48_00_r <= 0 ;
        dat_16_mv_1_o_56_00_r <= 0 ;
        dat_16_mv_1_o_48_16_r <= 0 ;
        dat_16_mv_1_o_56_16_r <= 0 ;
        dat_16_mv_1_o_48_32_r <= 0 ;
        dat_16_mv_1_o_56_32_r <= 0 ;
        dat_16_mv_1_o_48_48_r <= 0 ;
        dat_16_mv_1_o_56_48_r <= 0 ;
        dat_16_mv_2_o_00_00_r <= 0 ;
        dat_16_mv_2_o_00_08_r <= 0 ;
        dat_16_mv_2_o_00_16_r <= 0 ;
        dat_16_mv_2_o_00_24_r <= 0 ;
        dat_16_mv_2_o_00_32_r <= 0 ;
        dat_16_mv_2_o_00_40_r <= 0 ;
        dat_16_mv_2_o_00_48_r <= 0 ;
        dat_16_mv_2_o_00_56_r <= 0 ;
        dat_16_mv_2_o_16_00_r <= 0 ;
        dat_16_mv_2_o_16_08_r <= 0 ;
        dat_16_mv_2_o_16_16_r <= 0 ;
        dat_16_mv_2_o_16_24_r <= 0 ;
        dat_16_mv_2_o_16_32_r <= 0 ;
        dat_16_mv_2_o_16_40_r <= 0 ;
        dat_16_mv_2_o_16_48_r <= 0 ;
        dat_16_mv_2_o_16_56_r <= 0 ;
        dat_16_mv_2_o_32_00_r <= 0 ;
        dat_16_mv_2_o_32_08_r <= 0 ;
        dat_16_mv_2_o_32_16_r <= 0 ;
        dat_16_mv_2_o_32_24_r <= 0 ;
        dat_16_mv_2_o_32_32_r <= 0 ;
        dat_16_mv_2_o_32_40_r <= 0 ;
        dat_16_mv_2_o_32_48_r <= 0 ;
        dat_16_mv_2_o_32_56_r <= 0 ;
        dat_16_mv_2_o_48_00_r <= 0 ;
        dat_16_mv_2_o_48_08_r <= 0 ;
        dat_16_mv_2_o_48_16_r <= 0 ;
        dat_16_mv_2_o_48_24_r <= 0 ;
        dat_16_mv_2_o_48_32_r <= 0 ;
        dat_16_mv_2_o_48_40_r <= 0 ;
        dat_16_mv_2_o_48_48_r <= 0 ;
        dat_16_mv_2_o_48_56_r <= 0 ;
        // mv layer 5
        dat_32_mv_0_o_00_00_r <= 0 ;
        dat_32_mv_0_o_00_32_r <= 0 ;
        dat_32_mv_0_o_32_00_r <= 0 ;
        dat_32_mv_0_o_32_32_r <= 0 ;
        dat_32_mv_1_o_00_00_r <= 0 ;
        dat_32_mv_1_o_16_00_r <= 0 ;
        dat_32_mv_1_o_00_32_r <= 0 ;
        dat_32_mv_1_o_16_32_r <= 0 ;
        dat_32_mv_1_o_32_00_r <= 0 ;
        dat_32_mv_1_o_48_00_r <= 0 ;
        dat_32_mv_1_o_32_32_r <= 0 ;
        dat_32_mv_1_o_48_32_r <= 0 ;
        dat_32_mv_2_o_00_00_r <= 0 ;
        dat_32_mv_2_o_00_16_r <= 0 ;
        dat_32_mv_2_o_00_32_r <= 0 ;
        dat_32_mv_2_o_00_48_r <= 0 ;
        dat_32_mv_2_o_32_00_r <= 0 ;
        dat_32_mv_2_o_32_16_r <= 0 ;
        dat_32_mv_2_o_32_32_r <= 0 ;
        dat_32_mv_2_o_32_48_r <= 0 ;
        // mv layer 6
        dat_64_mv_0_o_00_00_r <= 0 ;
        dat_64_mv_1_o_00_00_r <= 0 ;
        dat_64_mv_1_o_32_00_r <= 0 ;
        dat_64_mv_2_o_00_00_r <= 0 ;
        dat_64_mv_2_o_00_32_r <= 0 ;
        // cst layer 3
        dat_08_cst_0_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_00_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_00_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_00_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_00_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_00_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_00_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_08_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_08_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_08_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_08_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_08_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_08_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_08_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_08_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_16_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_16_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_16_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_16_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_16_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_16_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_16_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_16_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_24_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_24_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_24_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_24_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_24_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_24_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_24_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_24_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_32_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_32_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_32_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_32_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_32_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_32_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_40_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_40_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_40_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_40_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_40_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_40_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_40_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_40_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_48_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_48_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_48_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_48_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_48_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_48_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_48_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_48_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_56_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_56_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_56_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_56_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_56_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_56_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_56_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_08_cst_0_o_56_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        // cst layer 4
        dat_16_cst_0_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_00_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_00_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_16_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_16_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_16_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_16_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_32_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_32_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_48_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_48_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_48_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_0_o_48_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_08_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_00_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_08_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_08_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_00_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_08_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_16_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_24_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_16_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_24_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_16_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_24_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_16_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_24_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_40_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_32_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_40_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_40_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_32_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_40_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_48_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_56_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_48_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_56_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_48_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_56_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_48_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_1_o_56_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_00_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_00_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_00_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_00_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_00_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_00_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_16_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_16_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_16_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_16_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_16_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_16_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_16_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_16_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_32_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_32_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_32_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_32_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_32_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_32_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_48_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_48_08_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_48_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_48_24_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_48_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_48_40_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_48_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_16_cst_2_o_48_56_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        // cst layer 5
        dat_32_cst_0_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_0_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_0_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_0_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_1_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_1_o_16_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_1_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_1_o_16_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_1_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_1_o_48_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_1_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_1_o_48_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_2_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_2_o_00_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_2_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_2_o_00_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_2_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_2_o_32_16_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_2_o_32_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_32_cst_2_o_32_48_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        // cst layer 6
        dat_64_cst_0_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_64_cst_1_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_64_cst_1_o_32_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_64_cst_2_o_00_00_r <= {{`IME_COST_WIDTH{1'b1}}} ;
        dat_64_cst_2_o_00_32_r <= {{`IME_COST_WIDTH{1'b1}}} ;
      end
      else if( downsample_i ) begin
        // cst layer 3
        if( val_04_i ) begin
          if( dat_04_cst_0_i_00_00_w < dat_08_cst_0_o_00_00_r ) begin
            dat_08_mv_0_o_00_00_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_00_00_r <= dat_04_cst_0_i_00_00_w ;
          end
          if( dat_04_cst_0_i_00_04_w < dat_08_cst_0_o_00_08_r ) begin
            dat_08_mv_0_o_00_08_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_00_08_r <= dat_04_cst_0_i_00_04_w ;
          end
          if( dat_04_cst_0_i_00_08_w < dat_08_cst_0_o_00_16_r ) begin
            dat_08_mv_0_o_00_16_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_00_16_r <= dat_04_cst_0_i_00_08_w ;
          end
          if( dat_04_cst_0_i_00_12_w < dat_08_cst_0_o_00_24_r ) begin
            dat_08_mv_0_o_00_24_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_00_24_r <= dat_04_cst_0_i_00_12_w ;
          end
          if( dat_04_cst_0_i_00_16_w < dat_08_cst_0_o_00_32_r ) begin
            dat_08_mv_0_o_00_32_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_00_32_r <= dat_04_cst_0_i_00_16_w ;
          end
          if( dat_04_cst_0_i_00_20_w < dat_08_cst_0_o_00_40_r ) begin
            dat_08_mv_0_o_00_40_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_00_40_r <= dat_04_cst_0_i_00_20_w ;
          end
          if( dat_04_cst_0_i_00_24_w < dat_08_cst_0_o_00_48_r ) begin
            dat_08_mv_0_o_00_48_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_00_48_r <= dat_04_cst_0_i_00_24_w ;
          end
          if( dat_04_cst_0_i_00_28_w < dat_08_cst_0_o_00_56_r ) begin
            dat_08_mv_0_o_00_56_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_00_56_r <= dat_04_cst_0_i_00_28_w ;
          end
          if( dat_04_cst_0_i_04_00_w < dat_08_cst_0_o_08_00_r ) begin
            dat_08_mv_0_o_08_00_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_08_00_r <= dat_04_cst_0_i_04_00_w ;
          end
          if( dat_04_cst_0_i_04_04_w < dat_08_cst_0_o_08_08_r ) begin
            dat_08_mv_0_o_08_08_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_08_08_r <= dat_04_cst_0_i_04_04_w ;
          end
          if( dat_04_cst_0_i_04_08_w < dat_08_cst_0_o_08_16_r ) begin
            dat_08_mv_0_o_08_16_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_08_16_r <= dat_04_cst_0_i_04_08_w ;
          end
          if( dat_04_cst_0_i_04_12_w < dat_08_cst_0_o_08_24_r ) begin
            dat_08_mv_0_o_08_24_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_08_24_r <= dat_04_cst_0_i_04_12_w ;
          end
          if( dat_04_cst_0_i_04_16_w < dat_08_cst_0_o_08_32_r ) begin
            dat_08_mv_0_o_08_32_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_08_32_r <= dat_04_cst_0_i_04_16_w ;
          end
          if( dat_04_cst_0_i_04_20_w < dat_08_cst_0_o_08_40_r ) begin
            dat_08_mv_0_o_08_40_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_08_40_r <= dat_04_cst_0_i_04_20_w ;
          end
          if( dat_04_cst_0_i_04_24_w < dat_08_cst_0_o_08_48_r ) begin
            dat_08_mv_0_o_08_48_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_08_48_r <= dat_04_cst_0_i_04_24_w ;
          end
          if( dat_04_cst_0_i_04_28_w < dat_08_cst_0_o_08_56_r ) begin
            dat_08_mv_0_o_08_56_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_08_56_r <= dat_04_cst_0_i_04_28_w ;
          end
          if( dat_04_cst_0_i_08_00_w < dat_08_cst_0_o_16_00_r ) begin
            dat_08_mv_0_o_16_00_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_16_00_r <= dat_04_cst_0_i_08_00_w ;
          end
          if( dat_04_cst_0_i_08_04_w < dat_08_cst_0_o_16_08_r ) begin
            dat_08_mv_0_o_16_08_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_16_08_r <= dat_04_cst_0_i_08_04_w ;
          end
          if( dat_04_cst_0_i_08_08_w < dat_08_cst_0_o_16_16_r ) begin
            dat_08_mv_0_o_16_16_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_16_16_r <= dat_04_cst_0_i_08_08_w ;
          end
          if( dat_04_cst_0_i_08_12_w < dat_08_cst_0_o_16_24_r ) begin
            dat_08_mv_0_o_16_24_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_16_24_r <= dat_04_cst_0_i_08_12_w ;
          end
          if( dat_04_cst_0_i_08_16_w < dat_08_cst_0_o_16_32_r ) begin
            dat_08_mv_0_o_16_32_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_16_32_r <= dat_04_cst_0_i_08_16_w ;
          end
          if( dat_04_cst_0_i_08_20_w < dat_08_cst_0_o_16_40_r ) begin
            dat_08_mv_0_o_16_40_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_16_40_r <= dat_04_cst_0_i_08_20_w ;
          end
          if( dat_04_cst_0_i_08_24_w < dat_08_cst_0_o_16_48_r ) begin
            dat_08_mv_0_o_16_48_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_16_48_r <= dat_04_cst_0_i_08_24_w ;
          end
          if( dat_04_cst_0_i_08_28_w < dat_08_cst_0_o_16_56_r ) begin
            dat_08_mv_0_o_16_56_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_16_56_r <= dat_04_cst_0_i_08_28_w ;
          end
          if( dat_04_cst_0_i_12_00_w < dat_08_cst_0_o_24_00_r ) begin
            dat_08_mv_0_o_24_00_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_24_00_r <= dat_04_cst_0_i_12_00_w ;
          end
          if( dat_04_cst_0_i_12_04_w < dat_08_cst_0_o_24_08_r ) begin
            dat_08_mv_0_o_24_08_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_24_08_r <= dat_04_cst_0_i_12_04_w ;
          end
          if( dat_04_cst_0_i_12_08_w < dat_08_cst_0_o_24_16_r ) begin
            dat_08_mv_0_o_24_16_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_24_16_r <= dat_04_cst_0_i_12_08_w ;
          end
          if( dat_04_cst_0_i_12_12_w < dat_08_cst_0_o_24_24_r ) begin
            dat_08_mv_0_o_24_24_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_24_24_r <= dat_04_cst_0_i_12_12_w ;
          end
          if( dat_04_cst_0_i_12_16_w < dat_08_cst_0_o_24_32_r ) begin
            dat_08_mv_0_o_24_32_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_24_32_r <= dat_04_cst_0_i_12_16_w ;
          end
          if( dat_04_cst_0_i_12_20_w < dat_08_cst_0_o_24_40_r ) begin
            dat_08_mv_0_o_24_40_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_24_40_r <= dat_04_cst_0_i_12_20_w ;
          end
          if( dat_04_cst_0_i_12_24_w < dat_08_cst_0_o_24_48_r ) begin
            dat_08_mv_0_o_24_48_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_24_48_r <= dat_04_cst_0_i_12_24_w ;
          end
          if( dat_04_cst_0_i_12_28_w < dat_08_cst_0_o_24_56_r ) begin
            dat_08_mv_0_o_24_56_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_24_56_r <= dat_04_cst_0_i_12_28_w ;
          end
          if( dat_04_cst_0_i_16_00_w < dat_08_cst_0_o_32_00_r ) begin
            dat_08_mv_0_o_32_00_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_32_00_r <= dat_04_cst_0_i_16_00_w ;
          end
          if( dat_04_cst_0_i_16_04_w < dat_08_cst_0_o_32_08_r ) begin
            dat_08_mv_0_o_32_08_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_32_08_r <= dat_04_cst_0_i_16_04_w ;
          end
          if( dat_04_cst_0_i_16_08_w < dat_08_cst_0_o_32_16_r ) begin
            dat_08_mv_0_o_32_16_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_32_16_r <= dat_04_cst_0_i_16_08_w ;
          end
          if( dat_04_cst_0_i_16_12_w < dat_08_cst_0_o_32_24_r ) begin
            dat_08_mv_0_o_32_24_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_32_24_r <= dat_04_cst_0_i_16_12_w ;
          end
          if( dat_04_cst_0_i_16_16_w < dat_08_cst_0_o_32_32_r ) begin
            dat_08_mv_0_o_32_32_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_32_32_r <= dat_04_cst_0_i_16_16_w ;
          end
          if( dat_04_cst_0_i_16_20_w < dat_08_cst_0_o_32_40_r ) begin
            dat_08_mv_0_o_32_40_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_32_40_r <= dat_04_cst_0_i_16_20_w ;
          end
          if( dat_04_cst_0_i_16_24_w < dat_08_cst_0_o_32_48_r ) begin
            dat_08_mv_0_o_32_48_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_32_48_r <= dat_04_cst_0_i_16_24_w ;
          end
          if( dat_04_cst_0_i_16_28_w < dat_08_cst_0_o_32_56_r ) begin
            dat_08_mv_0_o_32_56_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_32_56_r <= dat_04_cst_0_i_16_28_w ;
          end
          if( dat_04_cst_0_i_20_00_w < dat_08_cst_0_o_40_00_r ) begin
            dat_08_mv_0_o_40_00_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_40_00_r <= dat_04_cst_0_i_20_00_w ;
          end
          if( dat_04_cst_0_i_20_04_w < dat_08_cst_0_o_40_08_r ) begin
            dat_08_mv_0_o_40_08_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_40_08_r <= dat_04_cst_0_i_20_04_w ;
          end
          if( dat_04_cst_0_i_20_08_w < dat_08_cst_0_o_40_16_r ) begin
            dat_08_mv_0_o_40_16_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_40_16_r <= dat_04_cst_0_i_20_08_w ;
          end
          if( dat_04_cst_0_i_20_12_w < dat_08_cst_0_o_40_24_r ) begin
            dat_08_mv_0_o_40_24_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_40_24_r <= dat_04_cst_0_i_20_12_w ;
          end
          if( dat_04_cst_0_i_20_16_w < dat_08_cst_0_o_40_32_r ) begin
            dat_08_mv_0_o_40_32_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_40_32_r <= dat_04_cst_0_i_20_16_w ;
          end
          if( dat_04_cst_0_i_20_20_w < dat_08_cst_0_o_40_40_r ) begin
            dat_08_mv_0_o_40_40_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_40_40_r <= dat_04_cst_0_i_20_20_w ;
          end
          if( dat_04_cst_0_i_20_24_w < dat_08_cst_0_o_40_48_r ) begin
            dat_08_mv_0_o_40_48_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_40_48_r <= dat_04_cst_0_i_20_24_w ;
          end
          if( dat_04_cst_0_i_20_28_w < dat_08_cst_0_o_40_56_r ) begin
            dat_08_mv_0_o_40_56_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_40_56_r <= dat_04_cst_0_i_20_28_w ;
          end
          if( dat_04_cst_0_i_24_00_w < dat_08_cst_0_o_48_00_r ) begin
            dat_08_mv_0_o_48_00_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_48_00_r <= dat_04_cst_0_i_24_00_w ;
          end
          if( dat_04_cst_0_i_24_04_w < dat_08_cst_0_o_48_08_r ) begin
            dat_08_mv_0_o_48_08_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_48_08_r <= dat_04_cst_0_i_24_04_w ;
          end
          if( dat_04_cst_0_i_24_08_w < dat_08_cst_0_o_48_16_r ) begin
            dat_08_mv_0_o_48_16_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_48_16_r <= dat_04_cst_0_i_24_08_w ;
          end
          if( dat_04_cst_0_i_24_12_w < dat_08_cst_0_o_48_24_r ) begin
            dat_08_mv_0_o_48_24_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_48_24_r <= dat_04_cst_0_i_24_12_w ;
          end
          if( dat_04_cst_0_i_24_16_w < dat_08_cst_0_o_48_32_r ) begin
            dat_08_mv_0_o_48_32_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_48_32_r <= dat_04_cst_0_i_24_16_w ;
          end
          if( dat_04_cst_0_i_24_20_w < dat_08_cst_0_o_48_40_r ) begin
            dat_08_mv_0_o_48_40_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_48_40_r <= dat_04_cst_0_i_24_20_w ;
          end
          if( dat_04_cst_0_i_24_24_w < dat_08_cst_0_o_48_48_r ) begin
            dat_08_mv_0_o_48_48_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_48_48_r <= dat_04_cst_0_i_24_24_w ;
          end
          if( dat_04_cst_0_i_24_28_w < dat_08_cst_0_o_48_56_r ) begin
            dat_08_mv_0_o_48_56_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_48_56_r <= dat_04_cst_0_i_24_28_w ;
          end
          if( dat_04_cst_0_i_28_00_w < dat_08_cst_0_o_56_00_r ) begin
            dat_08_mv_0_o_56_00_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_56_00_r <= dat_04_cst_0_i_28_00_w ;
          end
          if( dat_04_cst_0_i_28_04_w < dat_08_cst_0_o_56_08_r ) begin
            dat_08_mv_0_o_56_08_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_56_08_r <= dat_04_cst_0_i_28_04_w ;
          end
          if( dat_04_cst_0_i_28_08_w < dat_08_cst_0_o_56_16_r ) begin
            dat_08_mv_0_o_56_16_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_56_16_r <= dat_04_cst_0_i_28_08_w ;
          end
          if( dat_04_cst_0_i_28_12_w < dat_08_cst_0_o_56_24_r ) begin
            dat_08_mv_0_o_56_24_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_56_24_r <= dat_04_cst_0_i_28_12_w ;
          end
          if( dat_04_cst_0_i_28_16_w < dat_08_cst_0_o_56_32_r ) begin
            dat_08_mv_0_o_56_32_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_56_32_r <= dat_04_cst_0_i_28_16_w ;
          end
          if( dat_04_cst_0_i_28_20_w < dat_08_cst_0_o_56_40_r ) begin
            dat_08_mv_0_o_56_40_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_56_40_r <= dat_04_cst_0_i_28_20_w ;
          end
          if( dat_04_cst_0_i_28_24_w < dat_08_cst_0_o_56_48_r ) begin
            dat_08_mv_0_o_56_48_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_56_48_r <= dat_04_cst_0_i_28_24_w ;
          end
          if( dat_04_cst_0_i_28_28_w < dat_08_cst_0_o_56_56_r ) begin
            dat_08_mv_0_o_56_56_r  <= dat_04_mv_i            ;
            dat_08_cst_0_o_56_56_r <= dat_04_cst_0_i_28_28_w ;
          end
        end
        // cst layer 4
        if( val_08_i ) begin
          if( dat_08_cst_0_i_00_00_w < dat_16_cst_0_o_00_00_r ) begin
            dat_16_mv_0_o_00_00_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_00_00_r <= dat_08_cst_0_i_00_00_w ;
          end
          if( dat_08_cst_0_i_00_08_w < dat_16_cst_0_o_00_16_r ) begin
            dat_16_mv_0_o_00_16_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_00_16_r <= dat_08_cst_0_i_00_08_w ;
          end
          if( dat_08_cst_0_i_00_16_w < dat_16_cst_0_o_00_32_r ) begin
            dat_16_mv_0_o_00_32_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_00_32_r <= dat_08_cst_0_i_00_16_w ;
          end
          if( dat_08_cst_0_i_00_24_w < dat_16_cst_0_o_00_48_r ) begin
            dat_16_mv_0_o_00_48_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_00_48_r <= dat_08_cst_0_i_00_24_w ;
          end
          if( dat_08_cst_0_i_08_00_w < dat_16_cst_0_o_16_00_r ) begin
            dat_16_mv_0_o_16_00_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_16_00_r <= dat_08_cst_0_i_08_00_w ;
          end
          if( dat_08_cst_0_i_08_08_w < dat_16_cst_0_o_16_16_r ) begin
            dat_16_mv_0_o_16_16_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_16_16_r <= dat_08_cst_0_i_08_08_w ;
          end
          if( dat_08_cst_0_i_08_16_w < dat_16_cst_0_o_16_32_r ) begin
            dat_16_mv_0_o_16_32_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_16_32_r <= dat_08_cst_0_i_08_16_w ;
          end
          if( dat_08_cst_0_i_08_24_w < dat_16_cst_0_o_16_48_r ) begin
            dat_16_mv_0_o_16_48_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_16_48_r <= dat_08_cst_0_i_08_24_w ;
          end
          if( dat_08_cst_0_i_16_00_w < dat_16_cst_0_o_32_00_r ) begin
            dat_16_mv_0_o_32_00_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_32_00_r <= dat_08_cst_0_i_16_00_w ;
          end
          if( dat_08_cst_0_i_16_08_w < dat_16_cst_0_o_32_16_r ) begin
            dat_16_mv_0_o_32_16_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_32_16_r <= dat_08_cst_0_i_16_08_w ;
          end
          if( dat_08_cst_0_i_16_16_w < dat_16_cst_0_o_32_32_r ) begin
            dat_16_mv_0_o_32_32_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_32_32_r <= dat_08_cst_0_i_16_16_w ;
          end
          if( dat_08_cst_0_i_16_24_w < dat_16_cst_0_o_32_48_r ) begin
            dat_16_mv_0_o_32_48_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_32_48_r <= dat_08_cst_0_i_16_24_w ;
          end
          if( dat_08_cst_0_i_24_00_w < dat_16_cst_0_o_48_00_r ) begin
            dat_16_mv_0_o_48_00_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_48_00_r <= dat_08_cst_0_i_24_00_w ;
          end
          if( dat_08_cst_0_i_24_08_w < dat_16_cst_0_o_48_16_r ) begin
            dat_16_mv_0_o_48_16_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_48_16_r <= dat_08_cst_0_i_24_08_w ;
          end
          if( dat_08_cst_0_i_24_16_w < dat_16_cst_0_o_48_32_r ) begin
            dat_16_mv_0_o_48_32_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_48_32_r <= dat_08_cst_0_i_24_16_w ;
          end
          if( dat_08_cst_0_i_24_24_w < dat_16_cst_0_o_48_48_r ) begin
            dat_16_mv_0_o_48_48_r  <= dat_08_mv_i            ;
            dat_16_cst_0_o_48_48_r <= dat_08_cst_0_i_24_24_w ;
          end
          if( dat_08_cst_1_i_00_00_w < dat_16_cst_1_o_00_00_r ) begin
            dat_16_mv_1_o_00_00_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_00_00_r <= dat_08_cst_1_i_00_00_w ;
          end
          if( dat_08_cst_1_i_04_00_w < dat_16_cst_1_o_08_00_r ) begin
            dat_16_mv_1_o_08_00_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_08_00_r <= dat_08_cst_1_i_04_00_w ;
          end
          if( dat_08_cst_1_i_00_08_w < dat_16_cst_1_o_00_16_r ) begin
            dat_16_mv_1_o_00_16_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_00_16_r <= dat_08_cst_1_i_00_08_w ;
          end
          if( dat_08_cst_1_i_04_08_w < dat_16_cst_1_o_08_16_r ) begin
            dat_16_mv_1_o_08_16_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_08_16_r <= dat_08_cst_1_i_04_08_w ;
          end
          if( dat_08_cst_1_i_00_16_w < dat_16_cst_1_o_00_32_r ) begin
            dat_16_mv_1_o_00_32_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_00_32_r <= dat_08_cst_1_i_00_16_w ;
          end
          if( dat_08_cst_1_i_04_16_w < dat_16_cst_1_o_08_32_r ) begin
            dat_16_mv_1_o_08_32_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_08_32_r <= dat_08_cst_1_i_04_16_w ;
          end
          if( dat_08_cst_1_i_00_24_w < dat_16_cst_1_o_00_48_r ) begin
            dat_16_mv_1_o_00_48_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_00_48_r <= dat_08_cst_1_i_00_24_w ;
          end
          if( dat_08_cst_1_i_04_24_w < dat_16_cst_1_o_08_48_r ) begin
            dat_16_mv_1_o_08_48_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_08_48_r <= dat_08_cst_1_i_04_24_w ;
          end
          if( dat_08_cst_1_i_08_00_w < dat_16_cst_1_o_16_00_r ) begin
            dat_16_mv_1_o_16_00_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_16_00_r <= dat_08_cst_1_i_08_00_w ;
          end
          if( dat_08_cst_1_i_12_00_w < dat_16_cst_1_o_24_00_r ) begin
            dat_16_mv_1_o_24_00_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_24_00_r <= dat_08_cst_1_i_12_00_w ;
          end
          if( dat_08_cst_1_i_08_08_w < dat_16_cst_1_o_16_16_r ) begin
            dat_16_mv_1_o_16_16_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_16_16_r <= dat_08_cst_1_i_08_08_w ;
          end
          if( dat_08_cst_1_i_12_08_w < dat_16_cst_1_o_24_16_r ) begin
            dat_16_mv_1_o_24_16_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_24_16_r <= dat_08_cst_1_i_12_08_w ;
          end
          if( dat_08_cst_1_i_08_16_w < dat_16_cst_1_o_16_32_r ) begin
            dat_16_mv_1_o_16_32_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_16_32_r <= dat_08_cst_1_i_08_16_w ;
          end
          if( dat_08_cst_1_i_12_16_w < dat_16_cst_1_o_24_32_r ) begin
            dat_16_mv_1_o_24_32_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_24_32_r <= dat_08_cst_1_i_12_16_w ;
          end
          if( dat_08_cst_1_i_08_24_w < dat_16_cst_1_o_16_48_r ) begin
            dat_16_mv_1_o_16_48_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_16_48_r <= dat_08_cst_1_i_08_24_w ;
          end
          if( dat_08_cst_1_i_12_24_w < dat_16_cst_1_o_24_48_r ) begin
            dat_16_mv_1_o_24_48_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_24_48_r <= dat_08_cst_1_i_12_24_w ;
          end
          if( dat_08_cst_1_i_16_00_w < dat_16_cst_1_o_32_00_r ) begin
            dat_16_mv_1_o_32_00_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_32_00_r <= dat_08_cst_1_i_16_00_w ;
          end
          if( dat_08_cst_1_i_20_00_w < dat_16_cst_1_o_40_00_r ) begin
            dat_16_mv_1_o_40_00_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_40_00_r <= dat_08_cst_1_i_20_00_w ;
          end
          if( dat_08_cst_1_i_16_08_w < dat_16_cst_1_o_32_16_r ) begin
            dat_16_mv_1_o_32_16_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_32_16_r <= dat_08_cst_1_i_16_08_w ;
          end
          if( dat_08_cst_1_i_20_08_w < dat_16_cst_1_o_40_16_r ) begin
            dat_16_mv_1_o_40_16_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_40_16_r <= dat_08_cst_1_i_20_08_w ;
          end
          if( dat_08_cst_1_i_16_16_w < dat_16_cst_1_o_32_32_r ) begin
            dat_16_mv_1_o_32_32_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_32_32_r <= dat_08_cst_1_i_16_16_w ;
          end
          if( dat_08_cst_1_i_20_16_w < dat_16_cst_1_o_40_32_r ) begin
            dat_16_mv_1_o_40_32_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_40_32_r <= dat_08_cst_1_i_20_16_w ;
          end
          if( dat_08_cst_1_i_16_24_w < dat_16_cst_1_o_32_48_r ) begin
            dat_16_mv_1_o_32_48_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_32_48_r <= dat_08_cst_1_i_16_24_w ;
          end
          if( dat_08_cst_1_i_20_24_w < dat_16_cst_1_o_40_48_r ) begin
            dat_16_mv_1_o_40_48_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_40_48_r <= dat_08_cst_1_i_20_24_w ;
          end
          if( dat_08_cst_1_i_24_00_w < dat_16_cst_1_o_48_00_r ) begin
            dat_16_mv_1_o_48_00_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_48_00_r <= dat_08_cst_1_i_24_00_w ;
          end
          if( dat_08_cst_1_i_28_00_w < dat_16_cst_1_o_56_00_r ) begin
            dat_16_mv_1_o_56_00_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_56_00_r <= dat_08_cst_1_i_28_00_w ;
          end
          if( dat_08_cst_1_i_24_08_w < dat_16_cst_1_o_48_16_r ) begin
            dat_16_mv_1_o_48_16_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_48_16_r <= dat_08_cst_1_i_24_08_w ;
          end
          if( dat_08_cst_1_i_28_08_w < dat_16_cst_1_o_56_16_r ) begin
            dat_16_mv_1_o_56_16_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_56_16_r <= dat_08_cst_1_i_28_08_w ;
          end
          if( dat_08_cst_1_i_24_16_w < dat_16_cst_1_o_48_32_r ) begin
            dat_16_mv_1_o_48_32_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_48_32_r <= dat_08_cst_1_i_24_16_w ;
          end
          if( dat_08_cst_1_i_28_16_w < dat_16_cst_1_o_56_32_r ) begin
            dat_16_mv_1_o_56_32_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_56_32_r <= dat_08_cst_1_i_28_16_w ;
          end
          if( dat_08_cst_1_i_24_24_w < dat_16_cst_1_o_48_48_r ) begin
            dat_16_mv_1_o_48_48_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_48_48_r <= dat_08_cst_1_i_24_24_w ;
          end
          if( dat_08_cst_1_i_28_24_w < dat_16_cst_1_o_56_48_r ) begin
            dat_16_mv_1_o_56_48_r  <= dat_08_mv_i            ;
            dat_16_cst_1_o_56_48_r <= dat_08_cst_1_i_28_24_w ;
          end
          if( dat_08_cst_2_i_00_00_w < dat_16_cst_2_o_00_00_r ) begin
            dat_16_mv_2_o_00_00_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_00_00_r <= dat_08_cst_2_i_00_00_w ;
          end
          if( dat_08_cst_2_i_00_04_w < dat_16_cst_2_o_00_08_r ) begin
            dat_16_mv_2_o_00_08_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_00_08_r <= dat_08_cst_2_i_00_04_w ;
          end
          if( dat_08_cst_2_i_00_08_w < dat_16_cst_2_o_00_16_r ) begin
            dat_16_mv_2_o_00_16_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_00_16_r <= dat_08_cst_2_i_00_08_w ;
          end
          if( dat_08_cst_2_i_00_12_w < dat_16_cst_2_o_00_24_r ) begin
            dat_16_mv_2_o_00_24_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_00_24_r <= dat_08_cst_2_i_00_12_w ;
          end
          if( dat_08_cst_2_i_00_16_w < dat_16_cst_2_o_00_32_r ) begin
            dat_16_mv_2_o_00_32_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_00_32_r <= dat_08_cst_2_i_00_16_w ;
          end
          if( dat_08_cst_2_i_00_20_w < dat_16_cst_2_o_00_40_r ) begin
            dat_16_mv_2_o_00_40_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_00_40_r <= dat_08_cst_2_i_00_20_w ;
          end
          if( dat_08_cst_2_i_00_24_w < dat_16_cst_2_o_00_48_r ) begin
            dat_16_mv_2_o_00_48_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_00_48_r <= dat_08_cst_2_i_00_24_w ;
          end
          if( dat_08_cst_2_i_00_28_w < dat_16_cst_2_o_00_56_r ) begin
            dat_16_mv_2_o_00_56_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_00_56_r <= dat_08_cst_2_i_00_28_w ;
          end
          if( dat_08_cst_2_i_08_00_w < dat_16_cst_2_o_16_00_r ) begin
            dat_16_mv_2_o_16_00_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_16_00_r <= dat_08_cst_2_i_08_00_w ;
          end
          if( dat_08_cst_2_i_08_04_w < dat_16_cst_2_o_16_08_r ) begin
            dat_16_mv_2_o_16_08_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_16_08_r <= dat_08_cst_2_i_08_04_w ;
          end
          if( dat_08_cst_2_i_08_08_w < dat_16_cst_2_o_16_16_r ) begin
            dat_16_mv_2_o_16_16_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_16_16_r <= dat_08_cst_2_i_08_08_w ;
          end
          if( dat_08_cst_2_i_08_12_w < dat_16_cst_2_o_16_24_r ) begin
            dat_16_mv_2_o_16_24_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_16_24_r <= dat_08_cst_2_i_08_12_w ;
          end
          if( dat_08_cst_2_i_08_16_w < dat_16_cst_2_o_16_32_r ) begin
            dat_16_mv_2_o_16_32_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_16_32_r <= dat_08_cst_2_i_08_16_w ;
          end
          if( dat_08_cst_2_i_08_20_w < dat_16_cst_2_o_16_40_r ) begin
            dat_16_mv_2_o_16_40_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_16_40_r <= dat_08_cst_2_i_08_20_w ;
          end
          if( dat_08_cst_2_i_08_24_w < dat_16_cst_2_o_16_48_r ) begin
            dat_16_mv_2_o_16_48_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_16_48_r <= dat_08_cst_2_i_08_24_w ;
          end
          if( dat_08_cst_2_i_08_28_w < dat_16_cst_2_o_16_56_r ) begin
            dat_16_mv_2_o_16_56_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_16_56_r <= dat_08_cst_2_i_08_28_w ;
          end
          if( dat_08_cst_2_i_16_00_w < dat_16_cst_2_o_32_00_r ) begin
            dat_16_mv_2_o_32_00_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_32_00_r <= dat_08_cst_2_i_16_00_w ;
          end
          if( dat_08_cst_2_i_16_04_w < dat_16_cst_2_o_32_08_r ) begin
            dat_16_mv_2_o_32_08_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_32_08_r <= dat_08_cst_2_i_16_04_w ;
          end
          if( dat_08_cst_2_i_16_08_w < dat_16_cst_2_o_32_16_r ) begin
            dat_16_mv_2_o_32_16_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_32_16_r <= dat_08_cst_2_i_16_08_w ;
          end
          if( dat_08_cst_2_i_16_12_w < dat_16_cst_2_o_32_24_r ) begin
            dat_16_mv_2_o_32_24_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_32_24_r <= dat_08_cst_2_i_16_12_w ;
          end
          if( dat_08_cst_2_i_16_16_w < dat_16_cst_2_o_32_32_r ) begin
            dat_16_mv_2_o_32_32_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_32_32_r <= dat_08_cst_2_i_16_16_w ;
          end
          if( dat_08_cst_2_i_16_20_w < dat_16_cst_2_o_32_40_r ) begin
            dat_16_mv_2_o_32_40_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_32_40_r <= dat_08_cst_2_i_16_20_w ;
          end
          if( dat_08_cst_2_i_16_24_w < dat_16_cst_2_o_32_48_r ) begin
            dat_16_mv_2_o_32_48_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_32_48_r <= dat_08_cst_2_i_16_24_w ;
          end
          if( dat_08_cst_2_i_16_28_w < dat_16_cst_2_o_32_56_r ) begin
            dat_16_mv_2_o_32_56_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_32_56_r <= dat_08_cst_2_i_16_28_w ;
          end
          if( dat_08_cst_2_i_24_00_w < dat_16_cst_2_o_48_00_r ) begin
            dat_16_mv_2_o_48_00_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_48_00_r <= dat_08_cst_2_i_24_00_w ;
          end
          if( dat_08_cst_2_i_24_04_w < dat_16_cst_2_o_48_08_r ) begin
            dat_16_mv_2_o_48_08_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_48_08_r <= dat_08_cst_2_i_24_04_w ;
          end
          if( dat_08_cst_2_i_24_08_w < dat_16_cst_2_o_48_16_r ) begin
            dat_16_mv_2_o_48_16_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_48_16_r <= dat_08_cst_2_i_24_08_w ;
          end
          if( dat_08_cst_2_i_24_12_w < dat_16_cst_2_o_48_24_r ) begin
            dat_16_mv_2_o_48_24_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_48_24_r <= dat_08_cst_2_i_24_12_w ;
          end
          if( dat_08_cst_2_i_24_16_w < dat_16_cst_2_o_48_32_r ) begin
            dat_16_mv_2_o_48_32_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_48_32_r <= dat_08_cst_2_i_24_16_w ;
          end
          if( dat_08_cst_2_i_24_20_w < dat_16_cst_2_o_48_40_r ) begin
            dat_16_mv_2_o_48_40_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_48_40_r <= dat_08_cst_2_i_24_20_w ;
          end
          if( dat_08_cst_2_i_24_24_w < dat_16_cst_2_o_48_48_r ) begin
            dat_16_mv_2_o_48_48_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_48_48_r <= dat_08_cst_2_i_24_24_w ;
          end
          if( dat_08_cst_2_i_24_28_w < dat_16_cst_2_o_48_56_r ) begin
            dat_16_mv_2_o_48_56_r  <= dat_08_mv_i            ;
            dat_16_cst_2_o_48_56_r <= dat_08_cst_2_i_24_28_w ;
          end
        end
        // cst layer 5
        if( val_16_i ) begin
          if( dat_16_cst_0_i_00_00_w < dat_32_cst_0_o_00_00_r ) begin
            dat_32_mv_0_o_00_00_r  <= dat_16_mv_i            ;
            dat_32_cst_0_o_00_00_r <= dat_16_cst_0_i_00_00_w ;
          end
          if( dat_16_cst_0_i_00_16_w < dat_32_cst_0_o_00_32_r ) begin
            dat_32_mv_0_o_00_32_r  <= dat_16_mv_i            ;
            dat_32_cst_0_o_00_32_r <= dat_16_cst_0_i_00_16_w ;
          end
          if( dat_16_cst_0_i_16_00_w < dat_32_cst_0_o_32_00_r ) begin
            dat_32_mv_0_o_32_00_r  <= dat_16_mv_i            ;
            dat_32_cst_0_o_32_00_r <= dat_16_cst_0_i_16_00_w ;
          end
          if( dat_16_cst_0_i_16_16_w < dat_32_cst_0_o_32_32_r ) begin
            dat_32_mv_0_o_32_32_r  <= dat_16_mv_i            ;
            dat_32_cst_0_o_32_32_r <= dat_16_cst_0_i_16_16_w ;
          end
          if( dat_16_cst_1_i_00_00_w < dat_32_cst_1_o_00_00_r ) begin
            dat_32_mv_1_o_00_00_r  <= dat_16_mv_i            ;
            dat_32_cst_1_o_00_00_r <= dat_16_cst_1_i_00_00_w ;
          end
          if( dat_16_cst_1_i_08_00_w < dat_32_cst_1_o_16_00_r ) begin
            dat_32_mv_1_o_16_00_r  <= dat_16_mv_i            ;
            dat_32_cst_1_o_16_00_r <= dat_16_cst_1_i_08_00_w ;
          end
          if( dat_16_cst_1_i_00_16_w < dat_32_cst_1_o_00_32_r ) begin
            dat_32_mv_1_o_00_32_r  <= dat_16_mv_i            ;
            dat_32_cst_1_o_00_32_r <= dat_16_cst_1_i_00_16_w ;
          end
          if( dat_16_cst_1_i_08_16_w < dat_32_cst_1_o_16_32_r ) begin
            dat_32_mv_1_o_16_32_r  <= dat_16_mv_i            ;
            dat_32_cst_1_o_16_32_r <= dat_16_cst_1_i_08_16_w ;
          end
          if( dat_16_cst_1_i_16_00_w < dat_32_cst_1_o_32_00_r ) begin
            dat_32_mv_1_o_32_00_r  <= dat_16_mv_i            ;
            dat_32_cst_1_o_32_00_r <= dat_16_cst_1_i_16_00_w ;
          end
          if( dat_16_cst_1_i_24_00_w < dat_32_cst_1_o_48_00_r ) begin
            dat_32_mv_1_o_48_00_r  <= dat_16_mv_i            ;
            dat_32_cst_1_o_48_00_r <= dat_16_cst_1_i_24_00_w ;
          end
          if( dat_16_cst_1_i_16_16_w < dat_32_cst_1_o_32_32_r ) begin
            dat_32_mv_1_o_32_32_r  <= dat_16_mv_i            ;
            dat_32_cst_1_o_32_32_r <= dat_16_cst_1_i_16_16_w ;
          end
          if( dat_16_cst_1_i_24_16_w < dat_32_cst_1_o_48_32_r ) begin
            dat_32_mv_1_o_48_32_r  <= dat_16_mv_i            ;
            dat_32_cst_1_o_48_32_r <= dat_16_cst_1_i_24_16_w ;
          end
          if( dat_16_cst_2_i_00_00_w < dat_32_cst_2_o_00_00_r ) begin
            dat_32_mv_2_o_00_00_r  <= dat_16_mv_i            ;
            dat_32_cst_2_o_00_00_r <= dat_16_cst_2_i_00_00_w ;
          end
          if( dat_16_cst_2_i_00_08_w < dat_32_cst_2_o_00_16_r ) begin
            dat_32_mv_2_o_00_16_r  <= dat_16_mv_i            ;
            dat_32_cst_2_o_00_16_r <= dat_16_cst_2_i_00_08_w ;
          end
          if( dat_16_cst_2_i_00_16_w < dat_32_cst_2_o_00_32_r ) begin
            dat_32_mv_2_o_00_32_r  <= dat_16_mv_i            ;
            dat_32_cst_2_o_00_32_r <= dat_16_cst_2_i_00_16_w ;
          end
          if( dat_16_cst_2_i_00_24_w < dat_32_cst_2_o_00_48_r ) begin
            dat_32_mv_2_o_00_48_r  <= dat_16_mv_i            ;
            dat_32_cst_2_o_00_48_r <= dat_16_cst_2_i_00_24_w ;
          end
          if( dat_16_cst_2_i_16_00_w < dat_32_cst_2_o_32_00_r ) begin
            dat_32_mv_2_o_32_00_r  <= dat_16_mv_i            ;
            dat_32_cst_2_o_32_00_r <= dat_16_cst_2_i_16_00_w ;
          end
          if( dat_16_cst_2_i_16_08_w < dat_32_cst_2_o_32_16_r ) begin
            dat_32_mv_2_o_32_16_r  <= dat_16_mv_i            ;
            dat_32_cst_2_o_32_16_r <= dat_16_cst_2_i_16_08_w ;
          end
          if( dat_16_cst_2_i_16_16_w < dat_32_cst_2_o_32_32_r ) begin
            dat_32_mv_2_o_32_32_r  <= dat_16_mv_i            ;
            dat_32_cst_2_o_32_32_r <= dat_16_cst_2_i_16_16_w ;
          end
          if( dat_16_cst_2_i_16_24_w < dat_32_cst_2_o_32_48_r ) begin
            dat_32_mv_2_o_32_48_r  <= dat_16_mv_i            ;
            dat_32_cst_2_o_32_48_r <= dat_16_cst_2_i_16_24_w ;
          end
        end
        // cst layer 6
        if( val_32_i ) begin
          if( dat_32_cst_0_i_00_00_w < dat_64_cst_0_o_00_00_r ) begin
            dat_64_mv_0_o_00_00_r  <= dat_32_mv_i            ;
            dat_64_cst_0_o_00_00_r <= dat_32_cst_0_i_00_00_w ;
          end
          if( dat_32_cst_1_i_00_00_w < dat_64_cst_1_o_00_00_r ) begin
            dat_64_mv_1_o_00_00_r  <= dat_32_mv_i            ;
            dat_64_cst_1_o_00_00_r <= dat_32_cst_1_i_00_00_w ;
          end
          if( dat_32_cst_1_i_16_00_w < dat_64_cst_1_o_32_00_r ) begin
            dat_64_mv_1_o_32_00_r  <= dat_32_mv_i            ;
            dat_64_cst_1_o_32_00_r <= dat_32_cst_1_i_16_00_w ;
          end
          if( dat_32_cst_2_i_00_00_w < dat_64_cst_2_o_00_00_r ) begin
            dat_64_mv_2_o_00_00_r  <= dat_32_mv_i            ;
            dat_64_cst_2_o_00_00_r <= dat_32_cst_2_i_00_00_w ;
          end
          if( dat_32_cst_2_i_00_16_w < dat_64_cst_2_o_00_32_r ) begin
            dat_64_mv_2_o_00_32_r  <= dat_32_mv_i            ;
            dat_64_cst_2_o_00_32_r <= dat_32_cst_2_i_00_16_w ;
          end
        end
      end
      else begin
        // mv layer 3
        if( val_08_i ) begin
          case( dat_08_qd_i )
            0 : begin
              if( dat_08_cst_0_i_00_00_w < dat_08_cst_0_o_00_00_r ) begin
                dat_08_mv_0_o_00_00_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_00_00_r <= dat_08_cst_0_i_00_00_w ;
              end
              if( dat_08_cst_0_i_00_08_w < dat_08_cst_0_o_00_08_r ) begin
                dat_08_mv_0_o_00_08_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_00_08_r <= dat_08_cst_0_i_00_08_w ;
              end
              if( dat_08_cst_0_i_00_16_w < dat_08_cst_0_o_00_16_r ) begin
                dat_08_mv_0_o_00_16_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_00_16_r <= dat_08_cst_0_i_00_16_w ;
              end
              if( dat_08_cst_0_i_00_24_w < dat_08_cst_0_o_00_24_r ) begin
                dat_08_mv_0_o_00_24_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_00_24_r <= dat_08_cst_0_i_00_24_w ;
              end
              if( dat_08_cst_0_i_08_00_w < dat_08_cst_0_o_08_00_r ) begin
                dat_08_mv_0_o_08_00_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_08_00_r <= dat_08_cst_0_i_08_00_w ;
              end
              if( dat_08_cst_0_i_08_08_w < dat_08_cst_0_o_08_08_r ) begin
                dat_08_mv_0_o_08_08_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_08_08_r <= dat_08_cst_0_i_08_08_w ;
              end
              if( dat_08_cst_0_i_08_16_w < dat_08_cst_0_o_08_16_r ) begin
                dat_08_mv_0_o_08_16_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_08_16_r <= dat_08_cst_0_i_08_16_w ;
              end
              if( dat_08_cst_0_i_08_24_w < dat_08_cst_0_o_08_24_r ) begin
                dat_08_mv_0_o_08_24_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_08_24_r <= dat_08_cst_0_i_08_24_w ;
              end
              if( dat_08_cst_0_i_16_00_w < dat_08_cst_0_o_16_00_r ) begin
                dat_08_mv_0_o_16_00_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_16_00_r <= dat_08_cst_0_i_16_00_w ;
              end
              if( dat_08_cst_0_i_16_08_w < dat_08_cst_0_o_16_08_r ) begin
                dat_08_mv_0_o_16_08_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_16_08_r <= dat_08_cst_0_i_16_08_w ;
              end
              if( dat_08_cst_0_i_16_16_w < dat_08_cst_0_o_16_16_r ) begin
                dat_08_mv_0_o_16_16_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_16_16_r <= dat_08_cst_0_i_16_16_w ;
              end
              if( dat_08_cst_0_i_16_24_w < dat_08_cst_0_o_16_24_r ) begin
                dat_08_mv_0_o_16_24_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_16_24_r <= dat_08_cst_0_i_16_24_w ;
              end
              if( dat_08_cst_0_i_24_00_w < dat_08_cst_0_o_24_00_r ) begin
                dat_08_mv_0_o_24_00_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_24_00_r <= dat_08_cst_0_i_24_00_w ;
              end
              if( dat_08_cst_0_i_24_08_w < dat_08_cst_0_o_24_08_r ) begin
                dat_08_mv_0_o_24_08_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_24_08_r <= dat_08_cst_0_i_24_08_w ;
              end
              if( dat_08_cst_0_i_24_16_w < dat_08_cst_0_o_24_16_r ) begin
                dat_08_mv_0_o_24_16_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_24_16_r <= dat_08_cst_0_i_24_16_w ;
              end
              if( dat_08_cst_0_i_24_24_w < dat_08_cst_0_o_24_24_r ) begin
                dat_08_mv_0_o_24_24_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_24_24_r <= dat_08_cst_0_i_24_24_w ;
              end
            end
            1 : begin
              if( dat_08_cst_0_i_00_00_w < dat_08_cst_0_o_00_32_r ) begin
                dat_08_mv_0_o_00_32_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_00_32_r <= dat_08_cst_0_i_00_00_w ;
              end
              if( dat_08_cst_0_i_00_08_w < dat_08_cst_0_o_00_40_r ) begin
                dat_08_mv_0_o_00_40_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_00_40_r <= dat_08_cst_0_i_00_08_w ;
              end
              if( dat_08_cst_0_i_00_16_w < dat_08_cst_0_o_00_48_r ) begin
                dat_08_mv_0_o_00_48_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_00_48_r <= dat_08_cst_0_i_00_16_w ;
              end
              if( dat_08_cst_0_i_00_24_w < dat_08_cst_0_o_00_56_r ) begin
                dat_08_mv_0_o_00_56_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_00_56_r <= dat_08_cst_0_i_00_24_w ;
              end
              if( dat_08_cst_0_i_08_00_w < dat_08_cst_0_o_08_32_r ) begin
                dat_08_mv_0_o_08_32_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_08_32_r <= dat_08_cst_0_i_08_00_w ;
              end
              if( dat_08_cst_0_i_08_08_w < dat_08_cst_0_o_08_40_r ) begin
                dat_08_mv_0_o_08_40_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_08_40_r <= dat_08_cst_0_i_08_08_w ;
              end
              if( dat_08_cst_0_i_08_16_w < dat_08_cst_0_o_08_48_r ) begin
                dat_08_mv_0_o_08_48_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_08_48_r <= dat_08_cst_0_i_08_16_w ;
              end
              if( dat_08_cst_0_i_08_24_w < dat_08_cst_0_o_08_56_r ) begin
                dat_08_mv_0_o_08_56_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_08_56_r <= dat_08_cst_0_i_08_24_w ;
              end
              if( dat_08_cst_0_i_16_00_w < dat_08_cst_0_o_16_32_r ) begin
                dat_08_mv_0_o_16_32_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_16_32_r <= dat_08_cst_0_i_16_00_w ;
              end
              if( dat_08_cst_0_i_16_08_w < dat_08_cst_0_o_16_40_r ) begin
                dat_08_mv_0_o_16_40_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_16_40_r <= dat_08_cst_0_i_16_08_w ;
              end
              if( dat_08_cst_0_i_16_16_w < dat_08_cst_0_o_16_48_r ) begin
                dat_08_mv_0_o_16_48_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_16_48_r <= dat_08_cst_0_i_16_16_w ;
              end
              if( dat_08_cst_0_i_16_24_w < dat_08_cst_0_o_16_56_r ) begin
                dat_08_mv_0_o_16_56_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_16_56_r <= dat_08_cst_0_i_16_24_w ;
              end
              if( dat_08_cst_0_i_24_00_w < dat_08_cst_0_o_24_32_r ) begin
                dat_08_mv_0_o_24_32_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_24_32_r <= dat_08_cst_0_i_24_00_w ;
              end
              if( dat_08_cst_0_i_24_08_w < dat_08_cst_0_o_24_40_r ) begin
                dat_08_mv_0_o_24_40_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_24_40_r <= dat_08_cst_0_i_24_08_w ;
              end
              if( dat_08_cst_0_i_24_16_w < dat_08_cst_0_o_24_48_r ) begin
                dat_08_mv_0_o_24_48_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_24_48_r <= dat_08_cst_0_i_24_16_w ;
              end
              if( dat_08_cst_0_i_24_24_w < dat_08_cst_0_o_24_56_r ) begin
                dat_08_mv_0_o_24_56_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_24_56_r <= dat_08_cst_0_i_24_24_w ;
              end
            end
            2 : begin
              if( dat_08_cst_0_i_00_00_w < dat_08_cst_0_o_32_00_r ) begin
                dat_08_mv_0_o_32_00_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_32_00_r <= dat_08_cst_0_i_00_00_w ;
              end
              if( dat_08_cst_0_i_00_08_w < dat_08_cst_0_o_32_08_r ) begin
                dat_08_mv_0_o_32_08_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_32_08_r <= dat_08_cst_0_i_00_08_w ;
              end
              if( dat_08_cst_0_i_00_16_w < dat_08_cst_0_o_32_16_r ) begin
                dat_08_mv_0_o_32_16_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_32_16_r <= dat_08_cst_0_i_00_16_w ;
              end
              if( dat_08_cst_0_i_00_24_w < dat_08_cst_0_o_32_24_r ) begin
                dat_08_mv_0_o_32_24_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_32_24_r <= dat_08_cst_0_i_00_24_w ;
              end
              if( dat_08_cst_0_i_08_00_w < dat_08_cst_0_o_40_00_r ) begin
                dat_08_mv_0_o_40_00_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_40_00_r <= dat_08_cst_0_i_08_00_w ;
              end
              if( dat_08_cst_0_i_08_08_w < dat_08_cst_0_o_40_08_r ) begin
                dat_08_mv_0_o_40_08_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_40_08_r <= dat_08_cst_0_i_08_08_w ;
              end
              if( dat_08_cst_0_i_08_16_w < dat_08_cst_0_o_40_16_r ) begin
                dat_08_mv_0_o_40_16_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_40_16_r <= dat_08_cst_0_i_08_16_w ;
              end
              if( dat_08_cst_0_i_08_24_w < dat_08_cst_0_o_40_24_r ) begin
                dat_08_mv_0_o_40_24_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_40_24_r <= dat_08_cst_0_i_08_24_w ;
              end
              if( dat_08_cst_0_i_16_00_w < dat_08_cst_0_o_48_00_r ) begin
                dat_08_mv_0_o_48_00_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_48_00_r <= dat_08_cst_0_i_16_00_w ;
              end
              if( dat_08_cst_0_i_16_08_w < dat_08_cst_0_o_48_08_r ) begin
                dat_08_mv_0_o_48_08_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_48_08_r <= dat_08_cst_0_i_16_08_w ;
              end
              if( dat_08_cst_0_i_16_16_w < dat_08_cst_0_o_48_16_r ) begin
                dat_08_mv_0_o_48_16_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_48_16_r <= dat_08_cst_0_i_16_16_w ;
              end
              if( dat_08_cst_0_i_16_24_w < dat_08_cst_0_o_48_24_r ) begin
                dat_08_mv_0_o_48_24_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_48_24_r <= dat_08_cst_0_i_16_24_w ;
              end
              if( dat_08_cst_0_i_24_00_w < dat_08_cst_0_o_56_00_r ) begin
                dat_08_mv_0_o_56_00_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_56_00_r <= dat_08_cst_0_i_24_00_w ;
              end
              if( dat_08_cst_0_i_24_08_w < dat_08_cst_0_o_56_08_r ) begin
                dat_08_mv_0_o_56_08_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_56_08_r <= dat_08_cst_0_i_24_08_w ;
              end
              if( dat_08_cst_0_i_24_16_w < dat_08_cst_0_o_56_16_r ) begin
                dat_08_mv_0_o_56_16_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_56_16_r <= dat_08_cst_0_i_24_16_w ;
              end
              if( dat_08_cst_0_i_24_24_w < dat_08_cst_0_o_56_24_r ) begin
                dat_08_mv_0_o_56_24_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_56_24_r <= dat_08_cst_0_i_24_24_w ;
              end
            end
            3 : begin
              if( dat_08_cst_0_i_00_00_w < dat_08_cst_0_o_32_32_r ) begin
                dat_08_mv_0_o_32_32_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_32_32_r <= dat_08_cst_0_i_00_00_w ;
              end
              if( dat_08_cst_0_i_00_08_w < dat_08_cst_0_o_32_40_r ) begin
                dat_08_mv_0_o_32_40_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_32_40_r <= dat_08_cst_0_i_00_08_w ;
              end
              if( dat_08_cst_0_i_00_16_w < dat_08_cst_0_o_32_48_r ) begin
                dat_08_mv_0_o_32_48_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_32_48_r <= dat_08_cst_0_i_00_16_w ;
              end
              if( dat_08_cst_0_i_00_24_w < dat_08_cst_0_o_32_56_r ) begin
                dat_08_mv_0_o_32_56_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_32_56_r <= dat_08_cst_0_i_00_24_w ;
              end
              if( dat_08_cst_0_i_08_00_w < dat_08_cst_0_o_40_32_r ) begin
                dat_08_mv_0_o_40_32_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_40_32_r <= dat_08_cst_0_i_08_00_w ;
              end
              if( dat_08_cst_0_i_08_08_w < dat_08_cst_0_o_40_40_r ) begin
                dat_08_mv_0_o_40_40_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_40_40_r <= dat_08_cst_0_i_08_08_w ;
              end
              if( dat_08_cst_0_i_08_16_w < dat_08_cst_0_o_40_48_r ) begin
                dat_08_mv_0_o_40_48_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_40_48_r <= dat_08_cst_0_i_08_16_w ;
              end
              if( dat_08_cst_0_i_08_24_w < dat_08_cst_0_o_40_56_r ) begin
                dat_08_mv_0_o_40_56_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_40_56_r <= dat_08_cst_0_i_08_24_w ;
              end
              if( dat_08_cst_0_i_16_00_w < dat_08_cst_0_o_48_32_r ) begin
                dat_08_mv_0_o_48_32_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_48_32_r <= dat_08_cst_0_i_16_00_w ;
              end
              if( dat_08_cst_0_i_16_08_w < dat_08_cst_0_o_48_40_r ) begin
                dat_08_mv_0_o_48_40_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_48_40_r <= dat_08_cst_0_i_16_08_w ;
              end
              if( dat_08_cst_0_i_16_16_w < dat_08_cst_0_o_48_48_r ) begin
                dat_08_mv_0_o_48_48_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_48_48_r <= dat_08_cst_0_i_16_16_w ;
              end
              if( dat_08_cst_0_i_16_24_w < dat_08_cst_0_o_48_56_r ) begin
                dat_08_mv_0_o_48_56_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_48_56_r <= dat_08_cst_0_i_16_24_w ;
              end
              if( dat_08_cst_0_i_24_00_w < dat_08_cst_0_o_56_32_r ) begin
                dat_08_mv_0_o_56_32_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_56_32_r <= dat_08_cst_0_i_24_00_w ;
              end
              if( dat_08_cst_0_i_24_08_w < dat_08_cst_0_o_56_40_r ) begin
                dat_08_mv_0_o_56_40_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_56_40_r <= dat_08_cst_0_i_24_08_w ;
              end
              if( dat_08_cst_0_i_24_16_w < dat_08_cst_0_o_56_48_r ) begin
                dat_08_mv_0_o_56_48_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_56_48_r <= dat_08_cst_0_i_24_16_w ;
              end
              if( dat_08_cst_0_i_24_24_w < dat_08_cst_0_o_56_56_r ) begin
                dat_08_mv_0_o_56_56_r  <= dat_08_mv_i            ;
                dat_08_cst_0_o_56_56_r <= dat_08_cst_0_i_24_24_w ;
              end
            end
          endcase
        end
        // mv layer 4
        if( val_16_i ) begin
          case( dat_16_qd_i )
            0 : begin
              if( dat_16_cst_0_i_00_00_w < dat_16_cst_0_o_00_00_r ) begin
                dat_16_mv_0_o_00_00_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_00_00_r <= dat_16_cst_0_i_00_00_w ;
              end
              if( dat_16_cst_0_i_00_16_w < dat_16_cst_0_o_00_16_r ) begin
                dat_16_mv_0_o_00_16_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_00_16_r <= dat_16_cst_0_i_00_16_w ;
              end
              if( dat_16_cst_0_i_16_00_w < dat_16_cst_0_o_16_00_r ) begin
                dat_16_mv_0_o_16_00_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_16_00_r <= dat_16_cst_0_i_16_00_w ;
              end
              if( dat_16_cst_0_i_16_16_w < dat_16_cst_0_o_16_16_r ) begin
                dat_16_mv_0_o_16_16_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_16_16_r <= dat_16_cst_0_i_16_16_w ;
              end
              if( dat_16_cst_1_i_00_00_w < dat_16_cst_1_o_00_00_r ) begin
                dat_16_mv_1_o_00_00_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_00_00_r <= dat_16_cst_1_i_00_00_w ;
              end
              if( dat_16_cst_1_i_08_00_w < dat_16_cst_1_o_08_00_r ) begin
                dat_16_mv_1_o_08_00_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_08_00_r <= dat_16_cst_1_i_08_00_w ;
              end
              if( dat_16_cst_1_i_00_16_w < dat_16_cst_1_o_00_16_r ) begin
                dat_16_mv_1_o_00_16_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_00_16_r <= dat_16_cst_1_i_00_16_w ;
              end
              if( dat_16_cst_1_i_08_16_w < dat_16_cst_1_o_08_16_r ) begin
                dat_16_mv_1_o_08_16_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_08_16_r <= dat_16_cst_1_i_08_16_w ;
              end
              if( dat_16_cst_1_i_16_00_w < dat_16_cst_1_o_16_00_r ) begin
                dat_16_mv_1_o_16_00_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_16_00_r <= dat_16_cst_1_i_16_00_w ;
              end
              if( dat_16_cst_1_i_24_00_w < dat_16_cst_1_o_24_00_r ) begin
                dat_16_mv_1_o_24_00_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_24_00_r <= dat_16_cst_1_i_24_00_w ;
              end
              if( dat_16_cst_1_i_16_16_w < dat_16_cst_1_o_16_16_r ) begin
                dat_16_mv_1_o_16_16_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_16_16_r <= dat_16_cst_1_i_16_16_w ;
              end
              if( dat_16_cst_1_i_24_16_w < dat_16_cst_1_o_24_16_r ) begin
                dat_16_mv_1_o_24_16_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_24_16_r <= dat_16_cst_1_i_24_16_w ;
              end
              if( dat_16_cst_2_i_00_00_w < dat_16_cst_2_o_00_00_r ) begin
                dat_16_mv_2_o_00_00_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_00_00_r <= dat_16_cst_2_i_00_00_w ;
              end
              if( dat_16_cst_2_i_00_08_w < dat_16_cst_2_o_00_08_r ) begin
                dat_16_mv_2_o_00_08_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_00_08_r <= dat_16_cst_2_i_00_08_w ;
              end
              if( dat_16_cst_2_i_00_16_w < dat_16_cst_2_o_00_16_r ) begin
                dat_16_mv_2_o_00_16_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_00_16_r <= dat_16_cst_2_i_00_16_w ;
              end
              if( dat_16_cst_2_i_00_24_w < dat_16_cst_2_o_00_24_r ) begin
                dat_16_mv_2_o_00_24_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_00_24_r <= dat_16_cst_2_i_00_24_w ;
              end
              if( dat_16_cst_2_i_16_00_w < dat_16_cst_2_o_16_00_r ) begin
                dat_16_mv_2_o_16_00_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_16_00_r <= dat_16_cst_2_i_16_00_w ;
              end
              if( dat_16_cst_2_i_16_08_w < dat_16_cst_2_o_16_08_r ) begin
                dat_16_mv_2_o_16_08_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_16_08_r <= dat_16_cst_2_i_16_08_w ;
              end
              if( dat_16_cst_2_i_16_16_w < dat_16_cst_2_o_16_16_r ) begin
                dat_16_mv_2_o_16_16_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_16_16_r <= dat_16_cst_2_i_16_16_w ;
              end
              if( dat_16_cst_2_i_16_24_w < dat_16_cst_2_o_16_24_r ) begin
                dat_16_mv_2_o_16_24_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_16_24_r <= dat_16_cst_2_i_16_24_w ;
              end
            end
            1 : begin
              if( dat_16_cst_0_i_00_00_w < dat_16_cst_0_o_00_32_r ) begin
                dat_16_mv_0_o_00_32_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_00_32_r <= dat_16_cst_0_i_00_00_w ;
              end
              if( dat_16_cst_0_i_00_16_w < dat_16_cst_0_o_00_48_r ) begin
                dat_16_mv_0_o_00_48_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_00_48_r <= dat_16_cst_0_i_00_16_w ;
              end
              if( dat_16_cst_0_i_16_00_w < dat_16_cst_0_o_16_32_r ) begin
                dat_16_mv_0_o_16_32_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_16_32_r <= dat_16_cst_0_i_16_00_w ;
              end
              if( dat_16_cst_0_i_16_16_w < dat_16_cst_0_o_16_48_r ) begin
                dat_16_mv_0_o_16_48_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_16_48_r <= dat_16_cst_0_i_16_16_w ;
              end
              if( dat_16_cst_1_i_00_00_w < dat_16_cst_1_o_00_32_r ) begin
                dat_16_mv_1_o_00_32_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_00_32_r <= dat_16_cst_1_i_00_00_w ;
              end
              if( dat_16_cst_1_i_08_00_w < dat_16_cst_1_o_08_32_r ) begin
                dat_16_mv_1_o_08_32_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_08_32_r <= dat_16_cst_1_i_08_00_w ;
              end
              if( dat_16_cst_1_i_00_16_w < dat_16_cst_1_o_00_48_r ) begin
                dat_16_mv_1_o_00_48_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_00_48_r <= dat_16_cst_1_i_00_16_w ;
              end
              if( dat_16_cst_1_i_08_16_w < dat_16_cst_1_o_08_48_r ) begin
                dat_16_mv_1_o_08_48_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_08_48_r <= dat_16_cst_1_i_08_16_w ;
              end
              if( dat_16_cst_1_i_16_00_w < dat_16_cst_1_o_16_32_r ) begin
                dat_16_mv_1_o_16_32_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_16_32_r <= dat_16_cst_1_i_16_00_w ;
              end
              if( dat_16_cst_1_i_24_00_w < dat_16_cst_1_o_24_32_r ) begin
                dat_16_mv_1_o_24_32_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_24_32_r <= dat_16_cst_1_i_24_00_w ;
              end
              if( dat_16_cst_1_i_16_16_w < dat_16_cst_1_o_16_48_r ) begin
                dat_16_mv_1_o_16_48_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_16_48_r <= dat_16_cst_1_i_16_16_w ;
              end
              if( dat_16_cst_1_i_24_16_w < dat_16_cst_1_o_24_48_r ) begin
                dat_16_mv_1_o_24_48_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_24_48_r <= dat_16_cst_1_i_24_16_w ;
              end
              if( dat_16_cst_2_i_00_00_w < dat_16_cst_2_o_00_32_r ) begin
                dat_16_mv_2_o_00_32_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_00_32_r <= dat_16_cst_2_i_00_00_w ;
              end
              if( dat_16_cst_2_i_00_08_w < dat_16_cst_2_o_00_40_r ) begin
                dat_16_mv_2_o_00_40_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_00_40_r <= dat_16_cst_2_i_00_08_w ;
              end
              if( dat_16_cst_2_i_00_16_w < dat_16_cst_2_o_00_48_r ) begin
                dat_16_mv_2_o_00_48_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_00_48_r <= dat_16_cst_2_i_00_16_w ;
              end
              if( dat_16_cst_2_i_00_24_w < dat_16_cst_2_o_00_56_r ) begin
                dat_16_mv_2_o_00_56_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_00_56_r <= dat_16_cst_2_i_00_24_w ;
              end
              if( dat_16_cst_2_i_16_00_w < dat_16_cst_2_o_16_32_r ) begin
                dat_16_mv_2_o_16_32_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_16_32_r <= dat_16_cst_2_i_16_00_w ;
              end
              if( dat_16_cst_2_i_16_08_w < dat_16_cst_2_o_16_40_r ) begin
                dat_16_mv_2_o_16_40_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_16_40_r <= dat_16_cst_2_i_16_08_w ;
              end
              if( dat_16_cst_2_i_16_16_w < dat_16_cst_2_o_16_48_r ) begin
                dat_16_mv_2_o_16_48_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_16_48_r <= dat_16_cst_2_i_16_16_w ;
              end
              if( dat_16_cst_2_i_16_24_w < dat_16_cst_2_o_16_56_r ) begin
                dat_16_mv_2_o_16_56_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_16_56_r <= dat_16_cst_2_i_16_24_w ;
              end
            end
            2 : begin
              if( dat_16_cst_0_i_00_00_w < dat_16_cst_0_o_32_00_r ) begin
                dat_16_mv_0_o_32_00_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_32_00_r <= dat_16_cst_0_i_00_00_w ;
              end
              if( dat_16_cst_0_i_00_16_w < dat_16_cst_0_o_32_16_r ) begin
                dat_16_mv_0_o_32_16_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_32_16_r <= dat_16_cst_0_i_00_16_w ;
              end
              if( dat_16_cst_0_i_16_00_w < dat_16_cst_0_o_48_00_r ) begin
                dat_16_mv_0_o_48_00_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_48_00_r <= dat_16_cst_0_i_16_00_w ;
              end
              if( dat_16_cst_0_i_16_16_w < dat_16_cst_0_o_48_16_r ) begin
                dat_16_mv_0_o_48_16_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_48_16_r <= dat_16_cst_0_i_16_16_w ;
              end
              if( dat_16_cst_1_i_00_00_w < dat_16_cst_1_o_32_00_r ) begin
                dat_16_mv_1_o_32_00_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_32_00_r <= dat_16_cst_1_i_00_00_w ;
              end
              if( dat_16_cst_1_i_08_00_w < dat_16_cst_1_o_40_00_r ) begin
                dat_16_mv_1_o_40_00_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_40_00_r <= dat_16_cst_1_i_08_00_w ;
              end
              if( dat_16_cst_1_i_00_16_w < dat_16_cst_1_o_32_16_r ) begin
                dat_16_mv_1_o_32_16_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_32_16_r <= dat_16_cst_1_i_00_16_w ;
              end
              if( dat_16_cst_1_i_08_16_w < dat_16_cst_1_o_40_16_r ) begin
                dat_16_mv_1_o_40_16_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_40_16_r <= dat_16_cst_1_i_08_16_w ;
              end
              if( dat_16_cst_1_i_16_00_w < dat_16_cst_1_o_48_00_r ) begin
                dat_16_mv_1_o_48_00_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_48_00_r <= dat_16_cst_1_i_16_00_w ;
              end
              if( dat_16_cst_1_i_24_00_w < dat_16_cst_1_o_56_00_r ) begin
                dat_16_mv_1_o_56_00_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_56_00_r <= dat_16_cst_1_i_24_00_w ;
              end
              if( dat_16_cst_1_i_16_16_w < dat_16_cst_1_o_48_16_r ) begin
                dat_16_mv_1_o_48_16_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_48_16_r <= dat_16_cst_1_i_16_16_w ;
              end
              if( dat_16_cst_1_i_24_16_w < dat_16_cst_1_o_56_16_r ) begin
                dat_16_mv_1_o_56_16_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_56_16_r <= dat_16_cst_1_i_24_16_w ;
              end
              if( dat_16_cst_2_i_00_00_w < dat_16_cst_2_o_32_00_r ) begin
                dat_16_mv_2_o_32_00_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_32_00_r <= dat_16_cst_2_i_00_00_w ;
              end
              if( dat_16_cst_2_i_00_08_w < dat_16_cst_2_o_32_08_r ) begin
                dat_16_mv_2_o_32_08_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_32_08_r <= dat_16_cst_2_i_00_08_w ;
              end
              if( dat_16_cst_2_i_00_16_w < dat_16_cst_2_o_32_16_r ) begin
                dat_16_mv_2_o_32_16_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_32_16_r <= dat_16_cst_2_i_00_16_w ;
              end
              if( dat_16_cst_2_i_00_24_w < dat_16_cst_2_o_32_24_r ) begin
                dat_16_mv_2_o_32_24_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_32_24_r <= dat_16_cst_2_i_00_24_w ;
              end
              if( dat_16_cst_2_i_16_00_w < dat_16_cst_2_o_48_00_r ) begin
                dat_16_mv_2_o_48_00_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_48_00_r <= dat_16_cst_2_i_16_00_w ;
              end
              if( dat_16_cst_2_i_16_08_w < dat_16_cst_2_o_48_08_r ) begin
                dat_16_mv_2_o_48_08_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_48_08_r <= dat_16_cst_2_i_16_08_w ;
              end
              if( dat_16_cst_2_i_16_16_w < dat_16_cst_2_o_48_16_r ) begin
                dat_16_mv_2_o_48_16_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_48_16_r <= dat_16_cst_2_i_16_16_w ;
              end
              if( dat_16_cst_2_i_16_24_w < dat_16_cst_2_o_48_24_r ) begin
                dat_16_mv_2_o_48_24_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_48_24_r <= dat_16_cst_2_i_16_24_w ;
              end
            end
            3 : begin
              if( dat_16_cst_0_i_00_00_w < dat_16_cst_0_o_32_32_r ) begin
                dat_16_mv_0_o_32_32_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_32_32_r <= dat_16_cst_0_i_00_00_w ;
              end
              if( dat_16_cst_0_i_00_16_w < dat_16_cst_0_o_32_48_r ) begin
                dat_16_mv_0_o_32_48_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_32_48_r <= dat_16_cst_0_i_00_16_w ;
              end
              if( dat_16_cst_0_i_16_00_w < dat_16_cst_0_o_48_32_r ) begin
                dat_16_mv_0_o_48_32_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_48_32_r <= dat_16_cst_0_i_16_00_w ;
              end
              if( dat_16_cst_0_i_16_16_w < dat_16_cst_0_o_48_48_r ) begin
                dat_16_mv_0_o_48_48_r  <= dat_16_mv_i            ;
                dat_16_cst_0_o_48_48_r <= dat_16_cst_0_i_16_16_w ;
              end
              if( dat_16_cst_1_i_00_00_w < dat_16_cst_1_o_32_32_r ) begin
                dat_16_mv_1_o_32_32_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_32_32_r <= dat_16_cst_1_i_00_00_w ;
              end
              if( dat_16_cst_1_i_08_00_w < dat_16_cst_1_o_40_32_r ) begin
                dat_16_mv_1_o_40_32_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_40_32_r <= dat_16_cst_1_i_08_00_w ;
              end
              if( dat_16_cst_1_i_00_16_w < dat_16_cst_1_o_32_48_r ) begin
                dat_16_mv_1_o_32_48_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_32_48_r <= dat_16_cst_1_i_00_16_w ;
              end
              if( dat_16_cst_1_i_08_16_w < dat_16_cst_1_o_40_48_r ) begin
                dat_16_mv_1_o_40_48_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_40_48_r <= dat_16_cst_1_i_08_16_w ;
              end
              if( dat_16_cst_1_i_16_00_w < dat_16_cst_1_o_48_32_r ) begin
                dat_16_mv_1_o_48_32_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_48_32_r <= dat_16_cst_1_i_16_00_w ;
              end
              if( dat_16_cst_1_i_24_00_w < dat_16_cst_1_o_56_32_r ) begin
                dat_16_mv_1_o_56_32_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_56_32_r <= dat_16_cst_1_i_24_00_w ;
              end
              if( dat_16_cst_1_i_16_16_w < dat_16_cst_1_o_48_48_r ) begin
                dat_16_mv_1_o_48_48_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_48_48_r <= dat_16_cst_1_i_16_16_w ;
              end
              if( dat_16_cst_1_i_24_16_w < dat_16_cst_1_o_56_48_r ) begin
                dat_16_mv_1_o_56_48_r  <= dat_16_mv_i            ;
                dat_16_cst_1_o_56_48_r <= dat_16_cst_1_i_24_16_w ;
              end
              if( dat_16_cst_2_i_00_00_w < dat_16_cst_2_o_32_32_r ) begin
                dat_16_mv_2_o_32_32_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_32_32_r <= dat_16_cst_2_i_00_00_w ;
              end
              if( dat_16_cst_2_i_00_08_w < dat_16_cst_2_o_32_40_r ) begin
                dat_16_mv_2_o_32_40_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_32_40_r <= dat_16_cst_2_i_00_08_w ;
              end
              if( dat_16_cst_2_i_00_16_w < dat_16_cst_2_o_32_48_r ) begin
                dat_16_mv_2_o_32_48_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_32_48_r <= dat_16_cst_2_i_00_16_w ;
              end
              if( dat_16_cst_2_i_00_24_w < dat_16_cst_2_o_32_56_r ) begin
                dat_16_mv_2_o_32_56_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_32_56_r <= dat_16_cst_2_i_00_24_w ;
              end
              if( dat_16_cst_2_i_16_00_w < dat_16_cst_2_o_48_32_r ) begin
                dat_16_mv_2_o_48_32_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_48_32_r <= dat_16_cst_2_i_16_00_w ;
              end
              if( dat_16_cst_2_i_16_08_w < dat_16_cst_2_o_48_40_r ) begin
                dat_16_mv_2_o_48_40_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_48_40_r <= dat_16_cst_2_i_16_08_w ;
              end
              if( dat_16_cst_2_i_16_16_w < dat_16_cst_2_o_48_48_r ) begin
                dat_16_mv_2_o_48_48_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_48_48_r <= dat_16_cst_2_i_16_16_w ;
              end
              if( dat_16_cst_2_i_16_24_w < dat_16_cst_2_o_48_56_r ) begin
                dat_16_mv_2_o_48_56_r  <= dat_16_mv_i            ;
                dat_16_cst_2_o_48_56_r <= dat_16_cst_2_i_16_24_w ;
              end
            end
          endcase
        end
        // mv layer 5
        if( val_32_i ) begin
          case( dat_32_qd_i )
            0 : begin
              if( dat_32_cst_0_i_00_00_w < dat_32_cst_0_o_00_00_r ) begin
                dat_32_mv_0_o_00_00_r  <= dat_32_mv_i            ;
                dat_32_cst_0_o_00_00_r <= dat_32_cst_0_i_00_00_w ;
              end
              if( dat_32_cst_1_i_00_00_w < dat_32_cst_1_o_00_00_r ) begin
                dat_32_mv_1_o_00_00_r  <= dat_32_mv_i            ;
                dat_32_cst_1_o_00_00_r <= dat_32_cst_1_i_00_00_w ;
              end
              if( dat_32_cst_1_i_16_00_w < dat_32_cst_1_o_16_00_r ) begin
                dat_32_mv_1_o_16_00_r  <= dat_32_mv_i            ;
                dat_32_cst_1_o_16_00_r <= dat_32_cst_1_i_16_00_w ;
              end
              if( dat_32_cst_2_i_00_00_w < dat_32_cst_2_o_00_00_r ) begin
                dat_32_mv_2_o_00_00_r  <= dat_32_mv_i            ;
                dat_32_cst_2_o_00_00_r <= dat_32_cst_2_i_00_00_w ;
              end
              if( dat_32_cst_2_i_00_16_w < dat_32_cst_2_o_00_16_r ) begin
                dat_32_mv_2_o_00_16_r  <= dat_32_mv_i            ;
                dat_32_cst_2_o_00_16_r <= dat_32_cst_2_i_00_16_w ;
              end
            end
            1 : begin
              if( dat_32_cst_0_i_00_00_w < dat_32_cst_0_o_00_32_r ) begin
                dat_32_mv_0_o_00_32_r  <= dat_32_mv_i            ;
                dat_32_cst_0_o_00_32_r <= dat_32_cst_0_i_00_00_w ;
              end
              if( dat_32_cst_1_i_00_00_w < dat_32_cst_1_o_00_32_r ) begin
                dat_32_mv_1_o_00_32_r  <= dat_32_mv_i            ;
                dat_32_cst_1_o_00_32_r <= dat_32_cst_1_i_00_00_w ;
              end
              if( dat_32_cst_1_i_16_00_w < dat_32_cst_1_o_16_32_r ) begin
                dat_32_mv_1_o_16_32_r  <= dat_32_mv_i            ;
                dat_32_cst_1_o_16_32_r <= dat_32_cst_1_i_16_00_w ;
              end
              if( dat_32_cst_2_i_00_00_w < dat_32_cst_2_o_00_32_r ) begin
                dat_32_mv_2_o_00_32_r  <= dat_32_mv_i            ;
                dat_32_cst_2_o_00_32_r <= dat_32_cst_2_i_00_00_w ;
              end
              if( dat_32_cst_2_i_00_16_w < dat_32_cst_2_o_00_48_r ) begin
                dat_32_mv_2_o_00_48_r  <= dat_32_mv_i            ;
                dat_32_cst_2_o_00_48_r <= dat_32_cst_2_i_00_16_w ;
              end
            end
            2 : begin
              if( dat_32_cst_0_i_00_00_w < dat_32_cst_0_o_32_00_r ) begin
                dat_32_mv_0_o_32_00_r  <= dat_32_mv_i            ;
                dat_32_cst_0_o_32_00_r <= dat_32_cst_0_i_00_00_w ;
              end
              if( dat_32_cst_1_i_00_00_w < dat_32_cst_1_o_32_00_r ) begin
                dat_32_mv_1_o_32_00_r  <= dat_32_mv_i            ;
                dat_32_cst_1_o_32_00_r <= dat_32_cst_1_i_00_00_w ;
              end
              if( dat_32_cst_1_i_16_00_w < dat_32_cst_1_o_48_00_r ) begin
                dat_32_mv_1_o_48_00_r  <= dat_32_mv_i            ;
                dat_32_cst_1_o_48_00_r <= dat_32_cst_1_i_16_00_w ;
              end
              if( dat_32_cst_2_i_00_00_w < dat_32_cst_2_o_32_00_r ) begin
                dat_32_mv_2_o_32_00_r  <= dat_32_mv_i            ;
                dat_32_cst_2_o_32_00_r <= dat_32_cst_2_i_00_00_w ;
              end
              if( dat_32_cst_2_i_00_16_w < dat_32_cst_2_o_32_16_r ) begin
                dat_32_mv_2_o_32_16_r  <= dat_32_mv_i            ;
                dat_32_cst_2_o_32_16_r <= dat_32_cst_2_i_00_16_w ;
              end
            end
            3 : begin
              if( dat_32_cst_0_i_00_00_w < dat_32_cst_0_o_32_32_r ) begin
                dat_32_mv_0_o_32_32_r  <= dat_32_mv_i            ;
                dat_32_cst_0_o_32_32_r <= dat_32_cst_0_i_00_00_w ;
              end
              if( dat_32_cst_1_i_00_00_w < dat_32_cst_1_o_32_32_r ) begin
                dat_32_mv_1_o_32_32_r  <= dat_32_mv_i            ;
                dat_32_cst_1_o_32_32_r <= dat_32_cst_1_i_00_00_w ;
              end
              if( dat_32_cst_1_i_16_00_w < dat_32_cst_1_o_48_32_r ) begin
                dat_32_mv_1_o_48_32_r  <= dat_32_mv_i            ;
                dat_32_cst_1_o_48_32_r <= dat_32_cst_1_i_16_00_w ;
              end
              if( dat_32_cst_2_i_00_00_w < dat_32_cst_2_o_32_32_r ) begin
                dat_32_mv_2_o_32_32_r  <= dat_32_mv_i            ;
                dat_32_cst_2_o_32_32_r <= dat_32_cst_2_i_00_00_w ;
              end
              if( dat_32_cst_2_i_00_16_w < dat_32_cst_2_o_32_48_r ) begin
                dat_32_mv_2_o_32_48_r  <= dat_32_mv_i            ;
                dat_32_cst_2_o_32_48_r <= dat_32_cst_2_i_00_16_w ;
              end
            end
          endcase
        end
      end
    end
  end


//*** DEBUG *******************************************************************

  `ifdef DEBUG


  `endif

endmodule
