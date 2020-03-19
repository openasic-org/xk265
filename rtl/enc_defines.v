//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//-------------------------------------------------------------------
// Filename       : enc_defines.v
// Author         : Yibo FAN
// Created        : 2013-12-24
// Description    : H265 Encoder Defines
//
// $Id$
//-------------------------------------------------------------------
//synopsys translate_off
`timescale 1ns/100ps
//synopsys translate_on

`define RC_OPEN 

`define INTRA              1'd0
`define INTER              1'd1

`define SIZE_04            2'd0
`define SIZE_08            2'd1
`define SIZE_16            2'd2
`define SIZE_32            2'd3

`define TYPE_Y             2'd0
`define TYPE_U             2'd2
`define TYPE_V             2'd3




`define POSI_COST_WIDTH    20
`define FME_COST_WIDTH    20

`define POSI_PART_2NX2N    1'd0
`define POSI_PART_1NX1N    1'd1


`define IME_HAS_VER_MEM

`define IME_MV_WIDTH_X     7
`define IME_MV_WIDTH_Y     6
`define IME_MV_WIDTH       (`IME_MV_WIDTH_X+`IME_MV_WIDTH_Y)

`define IME_DIR_DOWN       2'd0
`define IME_DIR_RIGHT      2'd1
`define IME_DIR_UP         2'd2

`define IME_PIXEL_WIDTH    4
`define IME_COST_WIDTH     28
`define IME_C_MV_WIDTH     13

`define IME_PART_2NX2N     2'd0
`define IME_PART_1NX2N     2'd1
`define IME_PART_2NX1N     2'd2
`define IME_PART_1NX1N     2'd3

`define SW_X_WIDTH         (64+(1<<`IME_MV_WIDTH_X))
`define SW_Y_WIDTH         (64+(1<<`IME_MV_WIDTH_Y))







// Simulation Model
`define RTL_MODEL

`ifndef RTL_MODEL
	`define XM_MODEL
	`define ARM_UD_MODEL
`endif

// LCU Size
`define LCU_SIZE 64

// CU DEPTH. 0: LCU, 1:LCU/2, 2:LCU/4, 3:LCU/8
`define CU_DEPTH 3
//---------------------------------------
//       Data Width Definition
//---------------------------------------
// PIC SIZE Width
`define PIC_X_WIDTH 6
`define PIC_Y_WIDTH 6
`define PIC_WIDTH   6+6+1
`define PIC_HEIGHT  6+6

`define PIC_X_NUM   1<<`PIC_X_WIDTH
`define PIC_Y_NUM   1<<`PIC_Y_WIDTH
`define PIC_LCU_WID (`PIC_Y_WIDTH+`PIC_X_WIDTH)
// Pixel Width
`define PIXEL_WIDTH 8
// DCT Coefficient Width
`define COEFF_WIDTH (`PIXEL_WIDTH+8)
// MV Width
`define IMV_WIDTH 8
`define FMV_WIDTH 10
`define MVD_WIDTH 11

`define INIT_QP 22

//the length of inter_type
`define INTER_TYPE_LEN       2
//MB partition mode
`define PART_2NX2N           0
`define PART_2NXN            1
`define PART_NX2N            2
`define PART_SPLIT           3


`define B8X8_SIZE     64
`define B8X16_SIZE   128
`define B16X8_SIZE   128
`define B16X16_SIZE  256
`define B32X16_SIZE  512
`define B16X32_SIZE  512
`define B32X32_SIZE 1024
`define B64X32_SIZE 2048
`define B32X64_SIZE 2048
`define B64X64_SIZE 4096

//----------------------FME------------------------
`define BLK4X4_NUM      `LCU_SIZE/`B4X4_SIZE
`define BLK8X8_NUM      `LCU_SIZE/`B8X8_SIZE
`define BLK16x16_NUM    `LCU_SIZE/`B16X16_SIZE
`define BLK32X32_NUM    `LCU_SIZE/`B32X32_SIZE
`define BLK64x64_NUM    `LCU_SIZE/`B64X64_SIZE

`define INTER_CU_INFO_LEN   170

`define SLICE_TYPE_I  1
`define SLICE_TYPE_P  0

//scan mode, when encode residual coefficient
`define SCAN_DIAG		0
`define SCAN_HOR		1
`define SCAN_VER		2

`define SAO_OPEN                0


