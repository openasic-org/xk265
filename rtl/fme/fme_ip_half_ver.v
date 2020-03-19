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
//  Filename      : fme_ip_half_ver.v
//  Author        : Yufeng Bai
//  Email 	  : byfchina@gmail.com	
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fme_ip_half_ver (
	clk		,
	rstn		,

	blk_start_i		,
	refpel_valid_i		,
	ref_pel0_i		,
	ref_pel1_i		,
	ref_pel2_i		,
	ref_pel3_i		,
	ref_pel4_i		,
	ref_pel5_i		,
	ref_pel6_i		,
	ref_pel7_i		,

	vhalf_pel0_o		,
	vhalf_pel1_o		,
	vhalf_pel2_o		,
	vhalf_pel3_o		,
	vhalf_pel4_o		,
	vhalf_pel5_o		,
	vhalf_pel6_o		,
	vhalf_pel7_o		,

	hor_start_i             ,
	horbuf_valid_i         ,
	h_buf0_i		,
	h_buf1_i		,
	h_buf2_i		,
	h_buf3_i		,
	h_buf4_i		,
	h_buf5_i		,
	h_buf6_i		,
	h_buf7_i		,
	h_buf8_i		,
	
	d_pel0_o		,
	d_pel1_o		,
	d_pel2_o		,
	d_pel3_o		,
	d_pel4_o		,
	d_pel5_o		,
	d_pel6_o		,
	d_pel7_o		,
	d_pel8_o			
);

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input 	 [1-1:0] 	 clk 	 ; // clk signal 
input 	 [1-1:0] 	 rstn 	 ; // asynchronous reset 
input 	 [1-1:0] 	 blk_start_i 	 ; // 8x8 block interpolation start signal 
input 	 [1-1:0] 	 refpel_valid_i 	 ; // referrenced pixel valid 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel0_i 	 ; // ref pixel 0 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel1_i 	 ; // ref pixel 1 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel2_i 	 ; // ref pixel 2 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel3_i 	 ; // ref pixel 3 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel4_i 	 ; // ref pixel 4 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel5_i 	 ; // ref pixel 5 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel6_i 	 ; // ref pixel 6 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel7_i 	 ; // ref pixel 7 


output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel0_o 	 ; // vertical half pixel 0 
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel1_o 	 ; // vertical half pixel 1 
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel2_o 	 ; // vertical half pixel 2 
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel3_o 	 ; // vertical half pixel 3 
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel4_o 	 ; // vertical half pixel 4 
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel5_o 	 ; // vertical half pixel 5 
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel6_o 	 ; // vertical half pixel 6 
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel7_o 	 ; // vertical half pixel 7 

input 	 [1-1:0]                 hor_start_i     ; // horizontal buf start
input 	 [1-1:0]                 horbuf_valid_i ; // horizontal half buf input valid			     
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf0_i 	 ; // horizontal half interpolation results 0 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf1_i 	 ; // horizontal half interpolation results 1 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf2_i 	 ; // horizontal half interpolation results 2 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf3_i 	 ; // horizontal half interpolation results 3 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf4_i 	 ; // horizontal half interpolation results 4 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf5_i 	 ; // horizontal half interpolation results 5 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf6_i 	 ; // horizontal half interpolation results 6 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf7_i 	 ; // horizontal half interpolation results 7 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf8_i 	 ; // horizontal half interpolation results 8 
output 	 [`PIXEL_WIDTH-1:0] 	 d_pel0_o 	 ; // diagonal pixel 0 
output 	 [`PIXEL_WIDTH-1:0] 	 d_pel1_o 	 ; // diagonal pixel 1 
output 	 [`PIXEL_WIDTH-1:0] 	 d_pel2_o 	 ; // diagonal pixel 2 
output 	 [`PIXEL_WIDTH-1:0] 	 d_pel3_o 	 ; // diagonal pixel 3 
output 	 [`PIXEL_WIDTH-1:0] 	 d_pel4_o 	 ; // diagonal pixel 4 
output 	 [`PIXEL_WIDTH-1:0] 	 d_pel5_o 	 ; // diagonal pixel 5 
output 	 [`PIXEL_WIDTH-1:0] 	 d_pel6_o 	 ; // diagonal pixel 6 
output 	 [`PIXEL_WIDTH-1:0] 	 d_pel7_o 	 ; // diagonal pixel 7 
output 	 [`PIXEL_WIDTH-1:0] 	 d_pel8_o 	 ; // diagonal pixel 8

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

reg      [`PIXEL_WIDTH-1:0]      ref_pel0_d1, ref_pel0_d2, ref_pel0_d3, ref_pel0_d4, ref_pel0_d5, ref_pel0_d6, ref_pel0_d7;   
reg      [`PIXEL_WIDTH-1:0]      ref_pel1_d1, ref_pel1_d2, ref_pel1_d3, ref_pel1_d4, ref_pel1_d5, ref_pel1_d6, ref_pel1_d7;   
reg      [`PIXEL_WIDTH-1:0]      ref_pel2_d1, ref_pel2_d2, ref_pel2_d3, ref_pel2_d4, ref_pel2_d5, ref_pel2_d6, ref_pel2_d7;   
reg      [`PIXEL_WIDTH-1:0]      ref_pel3_d1, ref_pel3_d2, ref_pel3_d3, ref_pel3_d4, ref_pel3_d5, ref_pel3_d6, ref_pel3_d7;   
reg      [`PIXEL_WIDTH-1:0]      ref_pel4_d1, ref_pel4_d2, ref_pel4_d3, ref_pel4_d4, ref_pel4_d5, ref_pel4_d6, ref_pel4_d7;   
reg      [`PIXEL_WIDTH-1:0]      ref_pel5_d1, ref_pel5_d2, ref_pel5_d3, ref_pel5_d4, ref_pel5_d5, ref_pel5_d6, ref_pel5_d7;   
reg      [`PIXEL_WIDTH-1:0]      ref_pel6_d1, ref_pel6_d2, ref_pel6_d3, ref_pel6_d4, ref_pel6_d5, ref_pel6_d6, ref_pel6_d7;   
reg      [`PIXEL_WIDTH-1:0]      ref_pel7_d1, ref_pel7_d2, ref_pel7_d3, ref_pel7_d4, ref_pel7_d5, ref_pel7_d6, ref_pel7_d7;   


reg      [2*`PIXEL_WIDTH-1:0]    h_buf0_d1,h_buf0_d2,h_buf0_d3,h_buf0_d4,h_buf0_d5,h_buf0_d6,h_buf0_d7; 
reg      [2*`PIXEL_WIDTH-1:0]    h_buf1_d1,h_buf1_d2,h_buf1_d3,h_buf1_d4,h_buf1_d5,h_buf1_d6,h_buf1_d7; 
reg      [2*`PIXEL_WIDTH-1:0]    h_buf2_d1,h_buf2_d2,h_buf2_d3,h_buf2_d4,h_buf2_d5,h_buf2_d6,h_buf2_d7; 
reg      [2*`PIXEL_WIDTH-1:0]    h_buf3_d1,h_buf3_d2,h_buf3_d3,h_buf3_d4,h_buf3_d5,h_buf3_d6,h_buf3_d7; 
reg      [2*`PIXEL_WIDTH-1:0]    h_buf4_d1,h_buf4_d2,h_buf4_d3,h_buf4_d4,h_buf4_d5,h_buf4_d6,h_buf4_d7; 
reg      [2*`PIXEL_WIDTH-1:0]    h_buf5_d1,h_buf5_d2,h_buf5_d3,h_buf5_d4,h_buf5_d5,h_buf5_d6,h_buf5_d7; 
reg      [2*`PIXEL_WIDTH-1:0]    h_buf6_d1,h_buf6_d2,h_buf6_d3,h_buf6_d4,h_buf6_d5,h_buf6_d6,h_buf6_d7; 
reg      [2*`PIXEL_WIDTH-1:0]    h_buf7_d1,h_buf7_d2,h_buf7_d3,h_buf7_d4,h_buf7_d5,h_buf7_d6,h_buf7_d7; 
reg      [2*`PIXEL_WIDTH-1:0]    h_buf8_d1,h_buf8_d2,h_buf8_d3,h_buf8_d4,h_buf8_d5,h_buf8_d6,h_buf8_d7;


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
always @ (posedge clk or negedge rstn) begin
if(~rstn) begin
  ref_pel0_d1 <= 'd0; ref_pel0_d2 <= 'd0; ref_pel0_d3 <= 'd0; ref_pel0_d4 <= 'd0; ref_pel0_d5 <= 'd0; ref_pel0_d6 <= 'd0; ref_pel0_d7 <= 'd0;
  ref_pel1_d1 <= 'd0; ref_pel1_d2 <= 'd0; ref_pel1_d3 <= 'd0; ref_pel1_d4 <= 'd0; ref_pel1_d5 <= 'd0; ref_pel1_d6 <= 'd0; ref_pel1_d7 <= 'd0;
  ref_pel2_d1 <= 'd0; ref_pel2_d2 <= 'd0; ref_pel2_d3 <= 'd0; ref_pel2_d4 <= 'd0; ref_pel2_d5 <= 'd0; ref_pel2_d6 <= 'd0; ref_pel2_d7 <= 'd0;
  ref_pel3_d1 <= 'd0; ref_pel3_d2 <= 'd0; ref_pel3_d3 <= 'd0; ref_pel3_d4 <= 'd0; ref_pel3_d5 <= 'd0; ref_pel3_d6 <= 'd0; ref_pel3_d7 <= 'd0;
  ref_pel4_d1 <= 'd0; ref_pel4_d2 <= 'd0; ref_pel4_d3 <= 'd0; ref_pel4_d4 <= 'd0; ref_pel4_d5 <= 'd0; ref_pel4_d6 <= 'd0; ref_pel4_d7 <= 'd0;
  ref_pel5_d1 <= 'd0; ref_pel5_d2 <= 'd0; ref_pel5_d3 <= 'd0; ref_pel5_d4 <= 'd0; ref_pel5_d5 <= 'd0; ref_pel5_d6 <= 'd0; ref_pel5_d7 <= 'd0;
  ref_pel6_d1 <= 'd0; ref_pel6_d2 <= 'd0; ref_pel6_d3 <= 'd0; ref_pel6_d4 <= 'd0; ref_pel6_d5 <= 'd0; ref_pel6_d6 <= 'd0; ref_pel6_d7 <= 'd0;
  ref_pel7_d1 <= 'd0; ref_pel7_d2 <= 'd0; ref_pel7_d3 <= 'd0; ref_pel7_d4 <= 'd0; ref_pel7_d5 <= 'd0; ref_pel7_d6 <= 'd0; ref_pel7_d7 <= 'd0;
  
end
else if(refpel_valid_i) begin
  ref_pel0_d1 <= ref_pel0_i; ref_pel0_d2 <= ref_pel0_d1;  ref_pel0_d3 <= ref_pel0_d2; ref_pel0_d4 <= ref_pel0_d3; ref_pel0_d5 <= ref_pel0_d4; ref_pel0_d6 <= ref_pel0_d5; ref_pel0_d7 <= ref_pel0_d6;
  ref_pel1_d1 <= ref_pel1_i; ref_pel1_d2 <= ref_pel1_d1;  ref_pel1_d3 <= ref_pel1_d2; ref_pel1_d4 <= ref_pel1_d3; ref_pel1_d5 <= ref_pel1_d4; ref_pel1_d6 <= ref_pel1_d5; ref_pel1_d7 <= ref_pel1_d6;
  ref_pel2_d1 <= ref_pel2_i; ref_pel2_d2 <= ref_pel2_d1;  ref_pel2_d3 <= ref_pel2_d2; ref_pel2_d4 <= ref_pel2_d3; ref_pel2_d5 <= ref_pel2_d4; ref_pel2_d6 <= ref_pel2_d5; ref_pel2_d7 <= ref_pel2_d6;
  ref_pel3_d1 <= ref_pel3_i; ref_pel3_d2 <= ref_pel3_d1;  ref_pel3_d3 <= ref_pel3_d2; ref_pel3_d4 <= ref_pel3_d3; ref_pel3_d5 <= ref_pel3_d4; ref_pel3_d6 <= ref_pel3_d5; ref_pel3_d7 <= ref_pel3_d6;
  ref_pel4_d1 <= ref_pel4_i; ref_pel4_d2 <= ref_pel4_d1;  ref_pel4_d3 <= ref_pel4_d2; ref_pel4_d4 <= ref_pel4_d3; ref_pel4_d5 <= ref_pel4_d4; ref_pel4_d6 <= ref_pel4_d5; ref_pel4_d7 <= ref_pel4_d6;
  ref_pel5_d1 <= ref_pel5_i; ref_pel5_d2 <= ref_pel5_d1;  ref_pel5_d3 <= ref_pel5_d2; ref_pel5_d4 <= ref_pel5_d3; ref_pel5_d5 <= ref_pel5_d4; ref_pel5_d6 <= ref_pel5_d5; ref_pel5_d7 <= ref_pel5_d6;
  ref_pel6_d1 <= ref_pel6_i; ref_pel6_d2 <= ref_pel6_d1;  ref_pel6_d3 <= ref_pel6_d2; ref_pel6_d4 <= ref_pel6_d3; ref_pel6_d5 <= ref_pel6_d4; ref_pel6_d6 <= ref_pel6_d5; ref_pel6_d7 <= ref_pel6_d6;
  ref_pel7_d1 <= ref_pel7_i; ref_pel7_d2 <= ref_pel7_d1;  ref_pel7_d3 <= ref_pel7_d2; ref_pel7_d4 <= ref_pel7_d3; ref_pel7_d5 <= ref_pel7_d4; ref_pel7_d6 <= ref_pel7_d5; ref_pel7_d7 <= ref_pel7_d6;
  
end
end

always @ (posedge clk or negedge rstn) begin
if(~rstn) begin
  h_buf0_d1 <= 'd0; h_buf0_d2 <= 'd0; h_buf0_d3 <= 'd0; h_buf0_d4 <= 'd0; h_buf0_d5 <= 'd0; h_buf0_d6 <= 'd0; h_buf0_d7 <= 'd0;
  h_buf1_d1 <= 'd0; h_buf1_d2 <= 'd0; h_buf1_d3 <= 'd0; h_buf1_d4 <= 'd0; h_buf1_d5 <= 'd0; h_buf1_d6 <= 'd0; h_buf1_d7 <= 'd0;
  h_buf2_d1 <= 'd0; h_buf2_d2 <= 'd0; h_buf2_d3 <= 'd0; h_buf2_d4 <= 'd0; h_buf2_d5 <= 'd0; h_buf2_d6 <= 'd0; h_buf2_d7 <= 'd0;
  h_buf3_d1 <= 'd0; h_buf3_d2 <= 'd0; h_buf3_d3 <= 'd0; h_buf3_d4 <= 'd0; h_buf3_d5 <= 'd0; h_buf3_d6 <= 'd0; h_buf3_d7 <= 'd0;
  h_buf4_d1 <= 'd0; h_buf4_d2 <= 'd0; h_buf4_d3 <= 'd0; h_buf4_d4 <= 'd0; h_buf4_d5 <= 'd0; h_buf4_d6 <= 'd0; h_buf4_d7 <= 'd0;
  h_buf5_d1 <= 'd0; h_buf5_d2 <= 'd0; h_buf5_d3 <= 'd0; h_buf5_d4 <= 'd0; h_buf5_d5 <= 'd0; h_buf5_d6 <= 'd0; h_buf5_d7 <= 'd0;
  h_buf6_d1 <= 'd0; h_buf6_d2 <= 'd0; h_buf6_d3 <= 'd0; h_buf6_d4 <= 'd0; h_buf6_d5 <= 'd0; h_buf6_d6 <= 'd0; h_buf6_d7 <= 'd0;
  h_buf7_d1 <= 'd0; h_buf7_d2 <= 'd0; h_buf7_d3 <= 'd0; h_buf7_d4 <= 'd0; h_buf7_d5 <= 'd0; h_buf7_d6 <= 'd0; h_buf7_d7 <= 'd0;
  h_buf8_d1 <= 'd0; h_buf8_d2 <= 'd0; h_buf8_d3 <= 'd0; h_buf8_d4 <= 'd0; h_buf8_d5 <= 'd0; h_buf8_d6 <= 'd0; h_buf8_d7 <= 'd0;
		end
else if(horbuf_valid_i) begin
  h_buf0_d1 <= h_buf0_i; h_buf0_d2 <= h_buf0_d1;  h_buf0_d3 <= h_buf0_d2; h_buf0_d4 <= h_buf0_d3; h_buf0_d5 <= h_buf0_d4; h_buf0_d6 <= h_buf0_d5; h_buf0_d7 <= h_buf0_d6;
  h_buf1_d1 <= h_buf1_i; h_buf1_d2 <= h_buf1_d1;  h_buf1_d3 <= h_buf1_d2; h_buf1_d4 <= h_buf1_d3; h_buf1_d5 <= h_buf1_d4; h_buf1_d6 <= h_buf1_d5; h_buf1_d7 <= h_buf1_d6;
  h_buf2_d1 <= h_buf2_i; h_buf2_d2 <= h_buf2_d1;  h_buf2_d3 <= h_buf2_d2; h_buf2_d4 <= h_buf2_d3; h_buf2_d5 <= h_buf2_d4; h_buf2_d6 <= h_buf2_d5; h_buf2_d7 <= h_buf2_d6;
  h_buf3_d1 <= h_buf3_i; h_buf3_d2 <= h_buf3_d1;  h_buf3_d3 <= h_buf3_d2; h_buf3_d4 <= h_buf3_d3; h_buf3_d5 <= h_buf3_d4; h_buf3_d6 <= h_buf3_d5; h_buf3_d7 <= h_buf3_d6;
  h_buf4_d1 <= h_buf4_i; h_buf4_d2 <= h_buf4_d1;  h_buf4_d3 <= h_buf4_d2; h_buf4_d4 <= h_buf4_d3; h_buf4_d5 <= h_buf4_d4; h_buf4_d6 <= h_buf4_d5; h_buf4_d7 <= h_buf4_d6;
  h_buf5_d1 <= h_buf5_i; h_buf5_d2 <= h_buf5_d1;  h_buf5_d3 <= h_buf5_d2; h_buf5_d4 <= h_buf5_d3; h_buf5_d5 <= h_buf5_d4; h_buf5_d6 <= h_buf5_d5; h_buf5_d7 <= h_buf5_d6;
  h_buf6_d1 <= h_buf6_i; h_buf6_d2 <= h_buf6_d1;  h_buf6_d3 <= h_buf6_d2; h_buf6_d4 <= h_buf6_d3; h_buf6_d5 <= h_buf6_d4; h_buf6_d6 <= h_buf6_d5; h_buf6_d7 <= h_buf6_d6;
  h_buf7_d1 <= h_buf7_i; h_buf7_d2 <= h_buf7_d1;  h_buf7_d3 <= h_buf7_d2; h_buf7_d4 <= h_buf7_d3; h_buf7_d5 <= h_buf7_d4; h_buf7_d6 <= h_buf7_d5; h_buf7_d7 <= h_buf7_d6;
  h_buf8_d1 <= h_buf8_i; h_buf8_d2 <= h_buf8_d1;  h_buf8_d3 <= h_buf8_d2; h_buf8_d4 <= h_buf8_d3; h_buf8_d5 <= h_buf8_d4; h_buf8_d6 <= h_buf8_d5; h_buf8_d7 <= h_buf8_d6;
                         end
end


// ********************************************
//
//    Sub Module
//
// ********************************************
fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_0 (
	.tap_0_i( ref_pel0_i  )		,
	.tap_1_i( ref_pel0_d1 )		,
	.tap_2_i( ref_pel0_d2 )		,
	.tap_3_i( ref_pel0_d3 )		,
	.tap_4_i( ref_pel0_d4 )		,
	.tap_5_i( ref_pel0_d5 )		,
	.tap_6_i( ref_pel0_d6 )		,
	.tap_7_i( ref_pel0_d7 )		,
	.val_o  ( vhalf_pel0_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_1 (
	.tap_0_i( ref_pel1_i  )		,
	.tap_1_i( ref_pel1_d1 )		,
	.tap_2_i( ref_pel1_d2 )		,
	.tap_3_i( ref_pel1_d3 )		,
	.tap_4_i( ref_pel1_d4 )		,
	.tap_5_i( ref_pel1_d5 )		,
	.tap_6_i( ref_pel1_d6 )		,
	.tap_7_i( ref_pel1_d7 )		,
	.val_o  ( vhalf_pel1_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_2 (
	.tap_0_i( ref_pel2_i  )		,
	.tap_1_i( ref_pel2_d1 )		,
	.tap_2_i( ref_pel2_d2 )		,
	.tap_3_i( ref_pel2_d3 )		,
	.tap_4_i( ref_pel2_d4 )		,
	.tap_5_i( ref_pel2_d5 )		,
	.tap_6_i( ref_pel2_d6 )		,
	.tap_7_i( ref_pel2_d7 )		,
	.val_o  ( vhalf_pel2_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_3 (
	.tap_0_i( ref_pel3_i  )		,
	.tap_1_i( ref_pel3_d1 )		,
	.tap_2_i( ref_pel3_d2 )		,
	.tap_3_i( ref_pel3_d3 )		,
	.tap_4_i( ref_pel3_d4 )		,
	.tap_5_i( ref_pel3_d5 )		,
	.tap_6_i( ref_pel3_d6 )		,
	.tap_7_i( ref_pel3_d7 )		,
	.val_o  ( vhalf_pel3_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_4 (
	.tap_0_i( ref_pel4_i  )		,
	.tap_1_i( ref_pel4_d1 )		,
	.tap_2_i( ref_pel4_d2 )		,
	.tap_3_i( ref_pel4_d3 )		,
	.tap_4_i( ref_pel4_d4 )		,
	.tap_5_i( ref_pel4_d5 )		,
	.tap_6_i( ref_pel4_d6 )		,
	.tap_7_i( ref_pel4_d7 )		,
	.val_o  ( vhalf_pel4_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_5 (
	.tap_0_i( ref_pel5_i  )		,
	.tap_1_i( ref_pel5_d1 )		,
	.tap_2_i( ref_pel5_d2 )		,
	.tap_3_i( ref_pel5_d3 )		,
	.tap_4_i( ref_pel5_d4 )		,
	.tap_5_i( ref_pel5_d5 )		,
	.tap_6_i( ref_pel5_d6 )		,
	.tap_7_i( ref_pel5_d7 )		,
	.val_o  ( vhalf_pel5_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_6 (
	.tap_0_i( ref_pel6_i  )		,
	.tap_1_i( ref_pel6_d1 )		,
	.tap_2_i( ref_pel6_d2 )		,
	.tap_3_i( ref_pel6_d3 )		,
	.tap_4_i( ref_pel6_d4 )		,
	.tap_5_i( ref_pel6_d5 )		,
	.tap_6_i( ref_pel6_d6 )		,
	.tap_7_i( ref_pel6_d7 )		,
	.val_o  ( vhalf_pel6_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_7 (
	.tap_0_i( ref_pel7_i  )		,
	.tap_1_i( ref_pel7_d1 )		,
	.tap_2_i( ref_pel7_d2 )		,
	.tap_3_i( ref_pel7_d3 )		,
	.tap_4_i( ref_pel7_d4 )		,
	.tap_5_i( ref_pel7_d5 )		,
	.tap_6_i( ref_pel7_d6 )		,
	.tap_7_i( ref_pel7_d7 )		,
	.val_o  ( vhalf_pel7_o)		
);

//

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) diagonal_0 (
	.tap_0_i( h_buf0_i)		,
	.tap_1_i( h_buf0_d1 )		,
	.tap_2_i( h_buf0_d2 )		,
	.tap_3_i( h_buf0_d3 )		,
	.tap_4_i( h_buf0_d4 )		,
	.tap_5_i( h_buf0_d5 )		,
	.tap_6_i( h_buf0_d6 )		,
	.tap_7_i( h_buf0_d7 )		,
	.val_o  ( d_pel0_o  )		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) diagonal_1 (
	.tap_0_i( h_buf1_i)		,
	.tap_1_i( h_buf1_d1 )		,
	.tap_2_i( h_buf1_d2 )		,
	.tap_3_i( h_buf1_d3 )		,
	.tap_4_i( h_buf1_d4 )		,
	.tap_5_i( h_buf1_d5 )		,
	.tap_6_i( h_buf1_d6 )		,
	.tap_7_i( h_buf1_d7 )		,
	.val_o  ( d_pel1_o  )		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) diagonal_2 (
	.tap_0_i( h_buf2_i )		,
	.tap_1_i( h_buf2_d1 )		,
	.tap_2_i( h_buf2_d2 )		,
	.tap_3_i( h_buf2_d3 )		,
	.tap_4_i( h_buf2_d4 )		,
	.tap_5_i( h_buf2_d5 )		,
	.tap_6_i( h_buf2_d6 )		,
	.tap_7_i( h_buf2_d7 )		,
	.val_o  ( d_pel2_o )		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) diagonal_3 (
	.tap_0_i( h_buf3_i )		,
	.tap_1_i( h_buf3_d1 )		,
	.tap_2_i( h_buf3_d2 )		,
	.tap_3_i( h_buf3_d3 )		,
	.tap_4_i( h_buf3_d4 )		,
	.tap_5_i( h_buf3_d5 )		,
	.tap_6_i( h_buf3_d6 )		,
	.tap_7_i( h_buf3_d7 )		,
	.val_o  ( d_pel3_o  )		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) diagonal_4 (
	.tap_0_i( h_buf4_i  )		,
	.tap_1_i( h_buf4_d1 )		,
	.tap_2_i( h_buf4_d2 )		,
	.tap_3_i( h_buf4_d3 )		,
	.tap_4_i( h_buf4_d4 )		,
	.tap_5_i( h_buf4_d5 )		,
	.tap_6_i( h_buf4_d6 )		,
	.tap_7_i( h_buf4_d7 )		,
	.val_o  ( d_pel4_o  )		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) diagonal_5 (
	.tap_0_i( h_buf5_i  )		,
	.tap_1_i( h_buf5_d1 )		,
	.tap_2_i( h_buf5_d2 )		,
	.tap_3_i( h_buf5_d3 )		,
	.tap_4_i( h_buf5_d4 )		,
	.tap_5_i( h_buf5_d5 )		,
	.tap_6_i( h_buf5_d6 )		,
	.tap_7_i( h_buf5_d7 )		,
	.val_o  ( d_pel5_o  )		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) diagonal_6 (
	.tap_0_i( h_buf6_i )		,
	.tap_1_i( h_buf6_d1 )		,
	.tap_2_i( h_buf6_d2 )		,
	.tap_3_i( h_buf6_d3 )		,
	.tap_4_i( h_buf6_d4 )		,
	.tap_5_i( h_buf6_d5 )		,
	.tap_6_i( h_buf6_d6 )		,
	.tap_7_i( h_buf6_d7 )		,
	.val_o  ( d_pel6_o  )		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) diagonal_7 (
	.tap_0_i( h_buf7_i )		,
	.tap_1_i( h_buf7_d1 )		,
	.tap_2_i( h_buf7_d2 )		,
	.tap_3_i( h_buf7_d3 )		,
	.tap_4_i( h_buf7_d4 )		,
	.tap_5_i( h_buf7_d5 )		,
	.tap_6_i( h_buf7_d6 )		,
	.tap_7_i( h_buf7_d7 )		,
	.val_o  ( d_pel7_o  )		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) diagonal_8 (
	.tap_0_i( h_buf8_i )		,
	.tap_1_i( h_buf8_d1 )		,
	.tap_2_i( h_buf8_d2 )		,
	.tap_3_i( h_buf8_d3 )		,
	.tap_4_i( h_buf8_d4 )		,
	.tap_5_i( h_buf8_d5 )		,
	.tap_6_i( h_buf8_d6 )		,
	.tap_7_i( h_buf8_d7 )		,
	.val_o  ( d_pel8_o  )		
);

endmodule

