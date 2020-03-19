//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2014, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//
//-------------------------------------------------------------------
//
//  Filename      : fme_interpolator_8pel.v
//  Author        : Yufeng Bai
//  Email 	  : byfchina@gmail.com	
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fme_interpolator_8pel (
	ref_pel0_i		,
	ref_pel1_i		,
	ref_pel2_i		,
	ref_pel3_i		,
	ref_pel4_i		,
	ref_pel5_i		,
	ref_pel6_i		,
	ref_pel7_i		,
	ref_pel8_i		,
	ref_pel9_i		,
	ref_pel10_i		,
	ref_pel11_i		,
	ref_pel12_i		,
	ref_pel13_i		,
	ref_pel14_i		,
	ref_pel15_i		,

	half_buf_0		,
	half_buf_1		,
	half_buf_2		,
	half_buf_3		,
	half_buf_4		,
	half_buf_5		,
	half_buf_6		,
	half_buf_7		,
	half_buf_8		,

	q1_buf_0	 	,
	q1_buf_1	 	,
	q1_buf_2	 	,
	q1_buf_3	 	,
	q1_buf_4	 	,
	q1_buf_5	 	,
	q1_buf_6	 	,
	q1_buf_7	 	,
	q1_buf_8	 	,

	q3_buf_0	        ,
	q3_buf_1	        ,
	q3_buf_2	        ,
	q3_buf_3	        ,
	q3_buf_4	        ,
	q3_buf_5	        ,
	q3_buf_6	        ,
	q3_buf_7	        ,
	q3_buf_8	        ,

	hhalf_pel0_o		,
	hhalf_pel1_o		,
	hhalf_pel2_o		,
	hhalf_pel3_o		,
	hhalf_pel4_o		,
	hhalf_pel5_o		,
	hhalf_pel6_o		,
	hhalf_pel7_o		,
	hhalf_pel8_o		

);

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel0_i 	 ; // ref_pel0 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel1_i 	 ; // ref_pel1 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel2_i 	 ; // ref_pel2 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel3_i 	 ; // ref_pel3 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel4_i 	 ; // ref_pel4 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel5_i 	 ; // ref_pel5 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel6_i 	 ; // ref_pel6 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel7_i 	 ; // ref_pel7 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel8_i 	 ; // ref_pel8 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel9_i 	 ; // ref_pel9 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel10_i 	 ; // ref_pel10 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel11_i 	 ; // ref_pel11 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel12_i 	 ; // ref_pel12 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel13_i 	 ; // ref_pel13 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel14_i 	 ; // ref_pel14 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel15_i 	 ; // ref_pel15 

output 	 [2*`PIXEL_WIDTH-1:0]  half_buf_0 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  half_buf_1 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  half_buf_2 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  half_buf_3 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  half_buf_4 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  half_buf_5 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  half_buf_6 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  half_buf_7 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  half_buf_8 	 ; // 9 pixels  16 bits/pixel

output 	 [2*`PIXEL_WIDTH-1:0]  q1_buf_0 	 ; // 9 pixels  16 bits/pixel  
output 	 [2*`PIXEL_WIDTH-1:0]  q3_buf_0 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  q1_buf_1 	 ; // 9 pixels  16 bits/pixel  
output 	 [2*`PIXEL_WIDTH-1:0]  q3_buf_1 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  q1_buf_2 	 ; // 9 pixels  16 bits/pixel  
output 	 [2*`PIXEL_WIDTH-1:0]  q3_buf_2 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  q1_buf_3 	 ; // 9 pixels  16 bits/pixel  
output 	 [2*`PIXEL_WIDTH-1:0]  q3_buf_3 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  q1_buf_4 	 ; // 9 pixels  16 bits/pixel  
output 	 [2*`PIXEL_WIDTH-1:0]  q3_buf_4 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  q1_buf_5 	 ; // 9 pixels  16 bits/pixel  
output 	 [2*`PIXEL_WIDTH-1:0]  q3_buf_5 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  q1_buf_6 	 ; // 9 pixels  16 bits/pixel  
output 	 [2*`PIXEL_WIDTH-1:0]  q3_buf_6 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  q1_buf_7 	 ; // 9 pixels  16 bits/pixel  
output 	 [2*`PIXEL_WIDTH-1:0]  q3_buf_7 	 ; // 9 pixels  16 bits/pixel
output 	 [2*`PIXEL_WIDTH-1:0]  q1_buf_8 	 ; // 9 pixels  16 bits/pixel  
output 	 [2*`PIXEL_WIDTH-1:0]  q3_buf_8 	 ; // 9 pixels  16 bits/pixel


output 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel0_o 	 ; // cliped half pixel 0 
output 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel1_o 	 ; // cliped half pixel 1 
output 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel2_o 	 ; // cliped half pixel 2 
output 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel3_o 	 ; // cliped half pixel 3 
output 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel4_o 	 ; // cliped half pixel 4 
output 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel5_o 	 ; // cliped half pixel 5 
output 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel6_o 	 ; // cliped half pixel 6 
output 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel7_o 	 ; // cliped half pixel 7
output 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel8_o 	 ; // cliped half pixel 8

// ********************************************
//
//   Sub Module DECLARATION
//
// ********************************************

// half interpolator

fme_interpolator #(
	.TYPE(0),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_half_0 (
	.tap_0_i( ref_pel0_i )		,
	.tap_1_i( ref_pel1_i )		,
	.tap_2_i( ref_pel2_i )		,
	.tap_3_i( ref_pel3_i )		,
	.tap_4_i( ref_pel4_i )		,
	.tap_5_i( ref_pel5_i )		,
	.tap_6_i( ref_pel6_i )		,
	.tap_7_i( ref_pel7_i )		,
	.val_o  ( half_buf_0 )
);

fme_interpolator #(
	.TYPE(0),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_half_1 (
	.tap_0_i( ref_pel1_i )		,
	.tap_1_i( ref_pel2_i )		,
	.tap_2_i( ref_pel3_i )		,
	.tap_3_i( ref_pel4_i )		,
	.tap_4_i( ref_pel5_i )		,
	.tap_5_i( ref_pel6_i )		,
	.tap_6_i( ref_pel7_i )		,
	.tap_7_i( ref_pel8_i )		,
	.val_o  ( half_buf_1 )
);

fme_interpolator #(
	.TYPE(0),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_half_2 (
	.tap_0_i( ref_pel2_i )		,
	.tap_1_i( ref_pel3_i )		,
	.tap_2_i( ref_pel4_i )		,
	.tap_3_i( ref_pel5_i )		,
	.tap_4_i( ref_pel6_i )		,
	.tap_5_i( ref_pel7_i )		,
	.tap_6_i( ref_pel8_i )		,
	.tap_7_i( ref_pel9_i )		,
	.val_o  ( half_buf_2 )
);

fme_interpolator #(
	.TYPE(0),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_half_3 (
	.tap_0_i( ref_pel3_i )		,
	.tap_1_i( ref_pel4_i )		,
	.tap_2_i( ref_pel5_i )		,
	.tap_3_i( ref_pel6_i )		,
	.tap_4_i( ref_pel7_i )		,
	.tap_5_i( ref_pel8_i )		,
	.tap_6_i( ref_pel9_i )		,
	.tap_7_i( ref_pel10_i )		,
	.val_o  ( half_buf_3 )
);

fme_interpolator #(
	.TYPE(0),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_half_4 (
	.tap_0_i( ref_pel4_i )		,
	.tap_1_i( ref_pel5_i )		,
	.tap_2_i( ref_pel6_i )		,
	.tap_3_i( ref_pel7_i )		,
	.tap_4_i( ref_pel8_i )		,
	.tap_5_i( ref_pel9_i )		,
	.tap_6_i( ref_pel10_i )		,
	.tap_7_i( ref_pel11_i )		,
	.val_o  ( half_buf_4 )
);

fme_interpolator #(
	.TYPE(0),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_half_5 (
	.tap_0_i( ref_pel5_i )		,
	.tap_1_i( ref_pel6_i )		,
	.tap_2_i( ref_pel7_i )		,
	.tap_3_i( ref_pel8_i )		,
	.tap_4_i( ref_pel9_i )		,
	.tap_5_i( ref_pel10_i )		,
	.tap_6_i( ref_pel11_i )		,
	.tap_7_i( ref_pel12_i )		,
	.val_o  ( half_buf_5 )
);

fme_interpolator #(
	.TYPE(0),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_half_6 (
	.tap_0_i( ref_pel6_i )		,
	.tap_1_i( ref_pel7_i )		,
	.tap_2_i( ref_pel8_i )		,
	.tap_3_i( ref_pel9_i )		,
	.tap_4_i( ref_pel10_i )		,
	.tap_5_i( ref_pel11_i )		,
	.tap_6_i( ref_pel12_i )		,
	.tap_7_i( ref_pel13_i )		,
	.val_o  ( half_buf_6 )
);

fme_interpolator #(
	.TYPE(0),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_half_7 (
	.tap_0_i( ref_pel7_i )		,
	.tap_1_i( ref_pel8_i )		,
	.tap_2_i( ref_pel9_i )		,
	.tap_3_i( ref_pel10_i )		,
	.tap_4_i( ref_pel11_i )		,
	.tap_5_i( ref_pel12_i )		,
	.tap_6_i( ref_pel13_i )		,
	.tap_7_i( ref_pel14_i )		,
	.val_o  ( half_buf_7 )
);

fme_interpolator #(
	.TYPE(0),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_half_8 (
	.tap_0_i( ref_pel8_i )		,
	.tap_1_i( ref_pel9_i )		,
	.tap_2_i( ref_pel10_i )		,
	.tap_3_i( ref_pel11_i )		,
	.tap_4_i( ref_pel12_i )		,
	.tap_5_i( ref_pel13_i )		,
	.tap_6_i( ref_pel14_i )		,
	.tap_7_i( ref_pel15_i )		,
	.val_o  ( half_buf_8 )
);

// 1/4 interpolator


fme_interpolator #(
	.TYPE(1),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q1_0 (
	.tap_0_i( ref_pel0_i )		,
	.tap_1_i( ref_pel1_i )		,
	.tap_2_i( ref_pel2_i )		,
	.tap_3_i( ref_pel3_i )		,
	.tap_4_i( ref_pel4_i )		,
	.tap_5_i( ref_pel5_i )		,
	.tap_6_i( ref_pel6_i )		,
	.tap_7_i( ref_pel7_i )		,
	.val_o  ( q1_buf_0 )
);

fme_interpolator #(
	.TYPE(1),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q1_1 (
	.tap_0_i( ref_pel1_i )		,
	.tap_1_i( ref_pel2_i )		,
	.tap_2_i( ref_pel3_i )		,
	.tap_3_i( ref_pel4_i )		,
	.tap_4_i( ref_pel5_i )		,
	.tap_5_i( ref_pel6_i )		,
	.tap_6_i( ref_pel7_i )		,
	.tap_7_i( ref_pel8_i )		,
	.val_o  ( q1_buf_1 )
);

fme_interpolator #(
	.TYPE(1),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q1_2 (
	.tap_0_i( ref_pel2_i )		,
	.tap_1_i( ref_pel3_i )		,
	.tap_2_i( ref_pel4_i )		,
	.tap_3_i( ref_pel5_i )		,
	.tap_4_i( ref_pel6_i )		,
	.tap_5_i( ref_pel7_i )		,
	.tap_6_i( ref_pel8_i )		,
	.tap_7_i( ref_pel9_i )		,
	.val_o  ( q1_buf_2 )
);

fme_interpolator #(
	.TYPE(1),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q1_3 (
	.tap_0_i( ref_pel3_i )		,
	.tap_1_i( ref_pel4_i )		,
	.tap_2_i( ref_pel5_i )		,
	.tap_3_i( ref_pel6_i )		,
	.tap_4_i( ref_pel7_i )		,
	.tap_5_i( ref_pel8_i )		,
	.tap_6_i( ref_pel9_i )		,
	.tap_7_i( ref_pel10_i )		,
	.val_o  ( q1_buf_3 )
);

fme_interpolator #(
	.TYPE(1),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q1_4 (
	.tap_0_i( ref_pel4_i )		,
	.tap_1_i( ref_pel5_i )		,
	.tap_2_i( ref_pel6_i )		,
	.tap_3_i( ref_pel7_i )		,
	.tap_4_i( ref_pel8_i )		,
	.tap_5_i( ref_pel9_i )		,
	.tap_6_i( ref_pel10_i )		,
	.tap_7_i( ref_pel11_i )		,
	.val_o  ( q1_buf_4 )
);

fme_interpolator #(
	.TYPE(1),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q1_5 (
	.tap_0_i( ref_pel5_i )		,
	.tap_1_i( ref_pel6_i )		,
	.tap_2_i( ref_pel7_i )		,
	.tap_3_i( ref_pel8_i )		,
	.tap_4_i( ref_pel9_i )		,
	.tap_5_i( ref_pel10_i )		,
	.tap_6_i( ref_pel11_i )		,
	.tap_7_i( ref_pel12_i )		,
	.val_o  ( q1_buf_5 )
);

fme_interpolator #(
	.TYPE(1),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q1_6 (
	.tap_0_i( ref_pel6_i )		,
	.tap_1_i( ref_pel7_i )		,
	.tap_2_i( ref_pel8_i )		,
	.tap_3_i( ref_pel9_i )		,
	.tap_4_i( ref_pel10_i )		,
	.tap_5_i( ref_pel11_i )		,
	.tap_6_i( ref_pel12_i )		,
	.tap_7_i( ref_pel13_i )		,
	.val_o  ( q1_buf_6 )
);

fme_interpolator #(
	.TYPE(1),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q1_7 (
	.tap_0_i( ref_pel7_i )		,
	.tap_1_i( ref_pel8_i )		,
	.tap_2_i( ref_pel9_i )		,
	.tap_3_i( ref_pel10_i )		,
	.tap_4_i( ref_pel11_i )		,
	.tap_5_i( ref_pel12_i )		,
	.tap_6_i( ref_pel13_i )		,
	.tap_7_i( ref_pel14_i )		,
	.val_o  ( q1_buf_7 )
);

fme_interpolator #(
	.TYPE(1),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q1_8 (
	.tap_0_i( ref_pel8_i )		,
	.tap_1_i( ref_pel9_i )		,
	.tap_2_i( ref_pel10_i )		,
	.tap_3_i( ref_pel11_i )		,
	.tap_4_i( ref_pel12_i )		,
	.tap_5_i( ref_pel13_i )		,
	.tap_6_i( ref_pel14_i )		,
	.tap_7_i( ref_pel15_i )		,
	.val_o  ( q1_buf_8 )
);

// 3/4 interpolator


fme_interpolator #(
	.TYPE(2),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q3_0 (
	.tap_0_i( ref_pel0_i )		,
	.tap_1_i( ref_pel1_i )		,
	.tap_2_i( ref_pel2_i )		,
	.tap_3_i( ref_pel3_i )		,
	.tap_4_i( ref_pel4_i )		,
	.tap_5_i( ref_pel5_i )		,
	.tap_6_i( ref_pel6_i )		,
	.tap_7_i( ref_pel7_i )		,
	.val_o  ( q3_buf_0 )
);

fme_interpolator #(
	.TYPE(2),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q3_1 (
	.tap_0_i( ref_pel1_i )		,
	.tap_1_i( ref_pel2_i )		,
	.tap_2_i( ref_pel3_i )		,
	.tap_3_i( ref_pel4_i )		,
	.tap_4_i( ref_pel5_i )		,
	.tap_5_i( ref_pel6_i )		,
	.tap_6_i( ref_pel7_i )		,
	.tap_7_i( ref_pel8_i )		,
	.val_o  ( q3_buf_1 )
);

fme_interpolator #(
	.TYPE(2),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q3_2 (
	.tap_0_i( ref_pel2_i )		,
	.tap_1_i( ref_pel3_i )		,
	.tap_2_i( ref_pel4_i )		,
	.tap_3_i( ref_pel5_i )		,
	.tap_4_i( ref_pel6_i )		,
	.tap_5_i( ref_pel7_i )		,
	.tap_6_i( ref_pel8_i )		,
	.tap_7_i( ref_pel9_i )		,
	.val_o  ( q3_buf_2 )
);

fme_interpolator #(
	.TYPE(2),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q3_3 (
	.tap_0_i( ref_pel3_i )		,
	.tap_1_i( ref_pel4_i )		,
	.tap_2_i( ref_pel5_i )		,
	.tap_3_i( ref_pel6_i )		,
	.tap_4_i( ref_pel7_i )		,
	.tap_5_i( ref_pel8_i )		,
	.tap_6_i( ref_pel9_i )		,
	.tap_7_i( ref_pel10_i )		,
	.val_o  ( q3_buf_3 )
);

fme_interpolator #(
	.TYPE(2),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q3_4 (
	.tap_0_i( ref_pel4_i )		,
	.tap_1_i( ref_pel5_i )		,
	.tap_2_i( ref_pel6_i )		,
	.tap_3_i( ref_pel7_i )		,
	.tap_4_i( ref_pel8_i )		,
	.tap_5_i( ref_pel9_i )		,
	.tap_6_i( ref_pel10_i )		,
	.tap_7_i( ref_pel11_i )		,
	.val_o  ( q3_buf_4 )
);

fme_interpolator #(
	.TYPE(2),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q3_5 (
	.tap_0_i( ref_pel5_i )		,
	.tap_1_i( ref_pel6_i )		,
	.tap_2_i( ref_pel7_i )		,
	.tap_3_i( ref_pel8_i )		,
	.tap_4_i( ref_pel9_i )		,
	.tap_5_i( ref_pel10_i )		,
	.tap_6_i( ref_pel11_i )		,
	.tap_7_i( ref_pel12_i )		,
	.val_o  ( q3_buf_5 )
);

fme_interpolator #(
	.TYPE(2),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q3_6 (
	.tap_0_i( ref_pel6_i )		,
	.tap_1_i( ref_pel7_i )		,
	.tap_2_i( ref_pel8_i )		,
	.tap_3_i( ref_pel9_i )		,
	.tap_4_i( ref_pel10_i )		,
	.tap_5_i( ref_pel11_i )		,
	.tap_6_i( ref_pel12_i )		,
	.tap_7_i( ref_pel13_i )		,
	.val_o  ( q3_buf_6 )
);

fme_interpolator #(
	.TYPE(2),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q3_7 (
	.tap_0_i( ref_pel7_i )		,
	.tap_1_i( ref_pel8_i )		,
	.tap_2_i( ref_pel9_i )		,
	.tap_3_i( ref_pel10_i )		,
	.tap_4_i( ref_pel11_i )		,
	.tap_5_i( ref_pel12_i )		,
	.tap_6_i( ref_pel13_i )		,
	.tap_7_i( ref_pel14_i )		,
	.val_o  ( q3_buf_7 )
);

fme_interpolator #(
	.TYPE(2),
	.HOR(1),
	.LAST(0),
	.IN_EXPAND(0), // interpolator input :  8 bits
	.OUT_EXPAND(1)
) horizontal_q3_8 (
	.tap_0_i( ref_pel8_i )		,
	.tap_1_i( ref_pel9_i )		,
	.tap_2_i( ref_pel10_i )		,
	.tap_3_i( ref_pel11_i )		,
	.tap_4_i( ref_pel12_i )		,
	.tap_5_i( ref_pel13_i )		,
	.tap_6_i( ref_pel14_i )		,
	.tap_7_i( ref_pel15_i )		,
	.val_o  ( q3_buf_8 )
);



//clip
clip2 clip_half_0 (
	.val_in(half_buf_0),
	.val_out(hhalf_pel0_o)
);

clip2 clip_half_1 (
	.val_in(half_buf_1),
	.val_out(hhalf_pel1_o)
);

clip2 clip_half_2 (
	.val_in(half_buf_2),
	.val_out(hhalf_pel2_o)
);

clip2 clip_half_3 (
	.val_in(half_buf_3),
	.val_out(hhalf_pel3_o)
);

clip2 clip_half_4 (
	.val_in(half_buf_4),
	.val_out(hhalf_pel4_o)
);

clip2 clip_half_5 (
	.val_in(half_buf_5),
	.val_out(hhalf_pel5_o)
);

clip2 clip_half_6 (
	.val_in(half_buf_6),
	.val_out(hhalf_pel6_o)
);

clip2 clip_half_7 (
	.val_in(half_buf_7),
	.val_out(hhalf_pel7_o)
);

clip2 clip_half_8 (
	.val_in(half_buf_8),
	.val_out(hhalf_pel8_o)
);
// ********************************************
//
//    Combinational Logic
//
// ********************************************


// ********************************************
//
//    Sequential Logic
//
// ********************************************


endmodule

