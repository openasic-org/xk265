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
//  Filename      : fme_ip_quarter_ver.v
//  Author        : Yufeng Bai
//  Email 	  : byfchina@gmail.com	
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fme_ip_quarter_ver (
	clk		,
	rstn		,

	blk_start_i		,
	refpel_valid_i		,

	hor_start_i		,
	horbuf_valid_i		,

	frac_x_i                ,
	frac_y_i                ,

	q1_buf0_i		,
	q1_buf1_i		,
	q1_buf2_i		,
	q1_buf3_i		,
	q1_buf4_i		,
	q1_buf5_i		,
	q1_buf6_i		,
	q1_buf7_i		,

	q3_buf0_i		,
	q3_buf1_i		,
	q3_buf2_i		,
	q3_buf3_i		,
	q3_buf4_i		,
	q3_buf5_i		,
	q3_buf6_i		,
	q3_buf7_i		,

	h_buf0_i		,
	h_buf1_i		,
	h_buf2_i		,
	h_buf3_i		,
	h_buf4_i		,
	h_buf5_i		,
	h_buf6_i		,
	h_buf7_i		,

	ref_pel0_i              ,
	ref_pel1_i              ,
	ref_pel2_i              ,
	ref_pel3_i              ,
	ref_pel4_i              ,
	ref_pel5_i              ,
	ref_pel6_i              ,
	ref_pel7_i              ,

	//vquarter_1_valid_o	, // [1][1]. [3][1]
	//vquarter_3_valid_o	, // [1][3], [3][3]
	//vquarter_2_valid_o      , // [1][2], [3][2]
	//vquarter_0_valid_o      , // [1][0], [3][0]
	//vhalf_valid_o           , // [2][1], [2][3]
	//vpel_valid_o            , // [0][1], [0][3]

	vquarter_1_1_pel0_o		,
	vquarter_1_1_pel1_o		,
	vquarter_1_1_pel2_o		,
	vquarter_1_1_pel3_o		,
	vquarter_1_1_pel4_o		,
	vquarter_1_1_pel5_o		,
	vquarter_1_1_pel6_o		,
	vquarter_1_1_pel7_o		,

	vquarter_1_3_pel0_o		,
	vquarter_1_3_pel1_o		,
	vquarter_1_3_pel2_o		,
	vquarter_1_3_pel3_o		,
	vquarter_1_3_pel4_o		,
	vquarter_1_3_pel5_o		,
	vquarter_1_3_pel6_o		,
	vquarter_1_3_pel7_o		,

	vquarter_1_2_pel0_o		,
	vquarter_1_2_pel1_o		,
	vquarter_1_2_pel2_o		,
	vquarter_1_2_pel3_o		,
	vquarter_1_2_pel4_o		,
	vquarter_1_2_pel5_o		,
	vquarter_1_2_pel6_o		,
	vquarter_1_2_pel7_o		,

	vquarter_1_0_pel0_o		,
	vquarter_1_0_pel1_o		,
	vquarter_1_0_pel2_o		,
	vquarter_1_0_pel3_o		,
	vquarter_1_0_pel4_o		,
	vquarter_1_0_pel5_o		,
	vquarter_1_0_pel6_o		,
	vquarter_1_0_pel7_o		,

	vquarter_3_1_pel0_o		,
	vquarter_3_1_pel1_o		,
	vquarter_3_1_pel2_o		,
	vquarter_3_1_pel3_o		,
	vquarter_3_1_pel4_o		,
	vquarter_3_1_pel5_o		,
	vquarter_3_1_pel6_o		,
	vquarter_3_1_pel7_o 		,		

	vquarter_3_3_pel0_o		,
	vquarter_3_3_pel1_o		,
	vquarter_3_3_pel2_o		,
	vquarter_3_3_pel3_o		,
	vquarter_3_3_pel4_o		,
	vquarter_3_3_pel5_o		,
	vquarter_3_3_pel6_o		,
	vquarter_3_3_pel7_o		,

	vquarter_3_2_pel0_o		,
	vquarter_3_2_pel1_o		,
	vquarter_3_2_pel2_o		,
	vquarter_3_2_pel3_o		,
	vquarter_3_2_pel4_o		,
	vquarter_3_2_pel5_o		,
	vquarter_3_2_pel6_o		,
	vquarter_3_2_pel7_o		,

	vquarter_3_0_pel0_o		,
	vquarter_3_0_pel1_o		,
	vquarter_3_0_pel2_o		,
	vquarter_3_0_pel3_o		,
	vquarter_3_0_pel4_o		,
	vquarter_3_0_pel5_o		,
	vquarter_3_0_pel6_o		,
	vquarter_3_0_pel7_o		,

	vpel_0_1_pel0_o                 ,
	vpel_0_1_pel1_o                 ,
	vpel_0_1_pel2_o                 ,
	vpel_0_1_pel3_o                 ,
	vpel_0_1_pel4_o                 ,
	vpel_0_1_pel5_o                 ,
	vpel_0_1_pel6_o                 ,
	vpel_0_1_pel7_o                 ,

	vpel_0_3_pel0_o                 ,
	vpel_0_3_pel1_o                 ,
	vpel_0_3_pel2_o                 ,
	vpel_0_3_pel3_o                 ,
	vpel_0_3_pel4_o                 ,
	vpel_0_3_pel5_o                 ,
	vpel_0_3_pel6_o                 ,
	vpel_0_3_pel7_o                 ,

	vhalf_2_1_pel0_o		,
	vhalf_2_1_pel1_o 		,
	vhalf_2_1_pel2_o 		,
	vhalf_2_1_pel3_o 		,
	vhalf_2_1_pel4_o 		,
	vhalf_2_1_pel5_o 		,
	vhalf_2_1_pel6_o 		,
	vhalf_2_1_pel7_o 		,

	vhalf_2_3_pel0_o 		,
	vhalf_2_3_pel1_o 		,
	vhalf_2_3_pel2_o 		,
	vhalf_2_3_pel3_o 		,
	vhalf_2_3_pel4_o 		,
	vhalf_2_3_pel5_o 		,
	vhalf_2_3_pel6_o 		,
	vhalf_2_3_pel7_o 			
);

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input 	 [1-1:0] 	         clk 	         ; // clk signal 
input 	 [1-1:0] 	         rstn 	         ; // asynchronous reset 
input 	 [1-1:0] 	         blk_start_i 	 ; // 8x8 block interpolation start signal 
input 	 [1-1:0] 	         refpel_valid_i  ; // referenced pixel valid 

input 	 [1-1:0] 	         hor_start_i 	 ; // 8x8 block horizontal interpolation start signal 
input 	 [1-1:0] 	         horbuf_valid_i  ; // horizontal buf pixel valid 

input    [2-1:0]                 frac_x_i        ; // frac_x: 00: ==0, 01: <0, 10:>0
input    [2-1:0]                 frac_y_i        ; // frac_y: 00: ==0, 01: <0, 10:>0

input 	 [2*`PIXEL_WIDTH-1:0] 	 q1_buf0_i 	 ; // horizontal quarter 1 interpolation results 0 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q1_buf1_i 	 ; // horizontal quarter 1 interpolation results 1 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q1_buf2_i 	 ; // horizontal quarter 1 interpolation results 2 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q1_buf3_i 	 ; // horizontal quarter 1 interpolation results 3 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q1_buf4_i 	 ; // horizontal quarter 1 interpolation results 4 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q1_buf5_i 	 ; // horizontal quarter 1 interpolation results 5 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q1_buf6_i 	 ; // horizontal quarter 1 interpolation results 6 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q1_buf7_i 	 ; // horizontal quarter 1 interpolation results 7 

input 	 [2*`PIXEL_WIDTH-1:0] 	 q3_buf0_i 	 ; // horizontal quarter 3 interpolation results 0 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q3_buf1_i 	 ; // horizontal quarter 3 interpolation results 1 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q3_buf2_i 	 ; // horizontal quarter 3 interpolation results 2 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q3_buf3_i 	 ; // horizontal quarter 3 interpolation results 3 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q3_buf4_i 	 ; // horizontal quarter 3 interpolation results 4 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q3_buf5_i 	 ; // horizontal quarter 3 interpolation results 5 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q3_buf6_i 	 ; // horizontal quarter 3 interpolation results 6 
input 	 [2*`PIXEL_WIDTH-1:0] 	 q3_buf7_i 	 ; // horizontal quarter 3 interpolation results 7 

input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf0_i 	 ; // horizontal half interpolation results 0 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf1_i 	 ; // horizontal half interpolation results 1 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf2_i 	 ; // horizontal half interpolation results 2 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf3_i 	 ; // horizontal half interpolation results 3 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf4_i 	 ; // horizontal half interpolation results 4 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf5_i 	 ; // horizontal half interpolation results 5 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf6_i 	 ; // horizontal half interpolation results 6 
input 	 [2*`PIXEL_WIDTH-1:0] 	 h_buf7_i 	 ; // horizontal half interpolation results 7 

input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel0_i 	 ; // referenced pixel 0 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel1_i 	 ; // referenced pixel 1 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel2_i 	 ; // referenced pixel 2 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel3_i 	 ; // referenced pixel 3 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel4_i 	 ; // referenced pixel 4 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel5_i 	 ; // referenced pixel 5 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel6_i 	 ; // referenced pixel 6 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel7_i 	 ; // referenced pixel 7 

//output 	 [1-1:0] 	 	 vquarter_1_valid_o 	 ; // vertical quarter 1 predicted pixels output valid 
//output 	 [1-1:0] 	         vquarter_3_valid_o 	 ; // vertical quarter 3 predicted pixels output valid 
//output 	 [1-1:0] 	         vquarter_2_valid_o 	 ; // vertical quarter 2 predicted pixels output valid 
//output 	 [1-1:0] 	         vquarter_0_valid_o 	 ; // vertical quarter 0 predicted pixels output valid 
//output 	 [1-1:0] 	         vhalf_valid_o   	 ; // vertical half predicted pixels output valid 
//output 	 [1-1:0] 	         vpel_valid_o   	 ; // cliped half predicted pixels output valid 

output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel0_o 	 ; // from q1 vertical quarter 1 pixel 0 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel1_o 	 ; // from q1 vertical quarter 1 pixel 1 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel2_o 	 ; // from q1 vertical quarter 1 pixel 2 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel3_o 	 ; // from q1 vertical quarter 1 pixel 3 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel4_o 	 ; // from q1 vertical quarter 1 pixel 4 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel5_o 	 ; // from q1 vertical quarter 1 pixel 5 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel6_o 	 ; // from q1 vertical quarter 1 pixel 6 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel7_o 	 ; // from q1 vertical quarter 1 pixel 7 

output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel0_o 	 ; // from q3 vertical quarter 1 pixel 0 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel1_o 	 ; // from q3 vertical quarter 1 pixel 1 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel2_o 	 ; // from q3 vertical quarter 1 pixel 2 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel3_o 	 ; // from q3 vertical quarter 1 pixel 3 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel4_o 	 ; // from q3 vertical quarter 1 pixel 4 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel5_o 	 ; // from q3 vertical quarter 1 pixel 5 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel6_o 	 ; // from q3 vertical quarter 1 pixel 6 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel7_o 	 ; // from q3 vertical quarter 1 pixel 7 

output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel0_o 	 ; // from half vertical quarter 1 pixel 0 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel1_o 	 ; // from half vertical quarter 1 pixel 1 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel2_o 	 ; // from half vertical quarter 1 pixel 2 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel3_o 	 ; // from half vertical quarter 1 pixel 3 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel4_o 	 ; // from half vertical quarter 1 pixel 4 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel5_o 	 ; // from half vertical quarter 1 pixel 5 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel6_o 	 ; // from half vertical quarter 1 pixel 6 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel7_o 	 ; // from half vertical quarter 1 pixel 7 

output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel0_o 	 ; // from ref vertical quarter 1 pixel 0 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel1_o 	 ; // from ref vertical quarter 1 pixel 1 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel2_o 	 ; // from ref vertical quarter 1 pixel 2 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel3_o 	 ; // from ref vertical quarter 1 pixel 3 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel4_o 	 ; // from ref vertical quarter 1 pixel 4 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel5_o 	 ; // from ref vertical quarter 1 pixel 5 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel6_o 	 ; // from ref vertical quarter 1 pixel 6 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel7_o 	 ; // from ref vertical quarter 1 pixel 7 

output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel0_o 	 ; // from q1 vertical quarter 3 pixel 0 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel1_o 	 ; // from q1 vertical quarter 3 pixel 1 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel2_o 	 ; // from q1 vertical quarter 3 pixel 2 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel3_o 	 ; // from q1 vertical quarter 3 pixel 3 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel4_o 	 ; // from q1 vertical quarter 3 pixel 4 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel5_o 	 ; // from q1 vertical quarter 3 pixel 5 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel6_o 	 ; // from q1 vertical quarter 3 pixel 6 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel7_o 	 ; // from q1 vertical quarter 3 pixel 7 

output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel0_o 	 ; // from q3 vertical quarter 3 pixel 0 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel1_o 	 ; // from q3 vertical quarter 3 pixel 1 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel2_o 	 ; // from q3 vertical quarter 3 pixel 2 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel3_o 	 ; // from q3 vertical quarter 3 pixel 3 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel4_o 	 ; // from q3 vertical quarter 3 pixel 4 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel5_o 	 ; // from q3 vertical quarter 3 pixel 5 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel6_o 	 ; // from q3 vertical quarter 3 pixel 6 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel7_o 	 ; // from q3 vertical quarter 3 pixel 7 

output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel0_o 	 ; // from ref vertical quarter 3 pixel 0 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel1_o 	 ; // from ref vertical quarter 3 pixel 1 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel2_o 	 ; // from ref vertical quarter 3 pixel 2 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel3_o 	 ; // from ref vertical quarter 3 pixel 3 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel4_o 	 ; // from ref vertical quarter 3 pixel 4 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel5_o 	 ; // from ref vertical quarter 3 pixel 5 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel6_o 	 ; // from ref vertical quarter 3 pixel 6 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel7_o 	 ; // from ref vertical quarter 3 pixel 7 

output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel0_o 	 ; // from half vertical quarter 3 pixel 0 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel1_o 	 ; // from half vertical quarter 3 pixel 1 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel2_o 	 ; // from half vertical quarter 3 pixel 2 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel3_o 	 ; // from half vertical quarter 3 pixel 3 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel4_o 	 ; // from half vertical quarter 3 pixel 4 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel5_o 	 ; // from half vertical quarter 3 pixel 5 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel6_o 	 ; // from half vertical quarter 3 pixel 6 
output 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel7_o 	 ; // from half vertical quarter 3 pixel 7 

output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel0_o          ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel1_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel2_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel3_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel4_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel5_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel6_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel7_o 	 ;
              
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel0_o          ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel1_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel2_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel3_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel4_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel5_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel6_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel7_o 	 ;

output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel0_o         ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel1_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel2_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel3_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel4_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel5_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel6_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel7_o 	 ;

output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel0_o         ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel1_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel2_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel3_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel4_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel5_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel6_o 	 ;
output 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel7_o 	 ;

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

reg      [3               :0]    cnt_ref;
reg      [3               :0]    cnt_hor;

reg      [2*`PIXEL_WIDTH-1:0]    q1_buf0_d1, q1_buf0_d2, q1_buf0_d3, q1_buf0_d4, q1_buf0_d5, q1_buf0_d6, q1_buf0_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q1_buf1_d1, q1_buf1_d2, q1_buf1_d3, q1_buf1_d4, q1_buf1_d5, q1_buf1_d6, q1_buf1_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q1_buf2_d1, q1_buf2_d2, q1_buf2_d3, q1_buf2_d4, q1_buf2_d5, q1_buf2_d6, q1_buf2_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q1_buf3_d1, q1_buf3_d2, q1_buf3_d3, q1_buf3_d4, q1_buf3_d5, q1_buf3_d6, q1_buf3_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q1_buf4_d1, q1_buf4_d2, q1_buf4_d3, q1_buf4_d4, q1_buf4_d5, q1_buf4_d6, q1_buf4_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q1_buf5_d1, q1_buf5_d2, q1_buf5_d3, q1_buf5_d4, q1_buf5_d5, q1_buf5_d6, q1_buf5_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q1_buf6_d1, q1_buf6_d2, q1_buf6_d3, q1_buf6_d4, q1_buf6_d5, q1_buf6_d6, q1_buf6_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q1_buf7_d1, q1_buf7_d2, q1_buf7_d3, q1_buf7_d4, q1_buf7_d5, q1_buf7_d6, q1_buf7_d7;

reg      [2*`PIXEL_WIDTH-1:0]    q3_buf0_d1, q3_buf0_d2, q3_buf0_d3, q3_buf0_d4, q3_buf0_d5, q3_buf0_d6, q3_buf0_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q3_buf1_d1, q3_buf1_d2, q3_buf1_d3, q3_buf1_d4, q3_buf1_d5, q3_buf1_d6, q3_buf1_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q3_buf2_d1, q3_buf2_d2, q3_buf2_d3, q3_buf2_d4, q3_buf2_d5, q3_buf2_d6, q3_buf2_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q3_buf3_d1, q3_buf3_d2, q3_buf3_d3, q3_buf3_d4, q3_buf3_d5, q3_buf3_d6, q3_buf3_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q3_buf4_d1, q3_buf4_d2, q3_buf4_d3, q3_buf4_d4, q3_buf4_d5, q3_buf4_d6, q3_buf4_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q3_buf5_d1, q3_buf5_d2, q3_buf5_d3, q3_buf5_d4, q3_buf5_d5, q3_buf5_d6, q3_buf5_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q3_buf6_d1, q3_buf6_d2, q3_buf6_d3, q3_buf6_d4, q3_buf6_d5, q3_buf6_d6, q3_buf6_d7;
reg      [2*`PIXEL_WIDTH-1:0]    q3_buf7_d1, q3_buf7_d2, q3_buf7_d3, q3_buf7_d4, q3_buf7_d5, q3_buf7_d6, q3_buf7_d7;

reg      [2*`PIXEL_WIDTH-1:0]    h_buf0_d1, h_buf0_d2, h_buf0_d3, h_buf0_d4, h_buf0_d5, h_buf0_d6, h_buf0_d7;
reg      [2*`PIXEL_WIDTH-1:0]    h_buf1_d1, h_buf1_d2, h_buf1_d3, h_buf1_d4, h_buf1_d5, h_buf1_d6, h_buf1_d7;
reg      [2*`PIXEL_WIDTH-1:0]    h_buf2_d1, h_buf2_d2, h_buf2_d3, h_buf2_d4, h_buf2_d5, h_buf2_d6, h_buf2_d7;
reg      [2*`PIXEL_WIDTH-1:0]    h_buf3_d1, h_buf3_d2, h_buf3_d3, h_buf3_d4, h_buf3_d5, h_buf3_d6, h_buf3_d7;
reg      [2*`PIXEL_WIDTH-1:0]    h_buf4_d1, h_buf4_d2, h_buf4_d3, h_buf4_d4, h_buf4_d5, h_buf4_d6, h_buf4_d7;
reg      [2*`PIXEL_WIDTH-1:0]    h_buf5_d1, h_buf5_d2, h_buf5_d3, h_buf5_d4, h_buf5_d5, h_buf5_d6, h_buf5_d7;
reg      [2*`PIXEL_WIDTH-1:0]    h_buf6_d1, h_buf6_d2, h_buf6_d3, h_buf6_d4, h_buf6_d5, h_buf6_d6, h_buf6_d7;
reg      [2*`PIXEL_WIDTH-1:0]    h_buf7_d1, h_buf7_d2, h_buf7_d3, h_buf7_d4, h_buf7_d5, h_buf7_d6, h_buf7_d7;

reg      [`PIXEL_WIDTH-1:0]      ref_pel0_d1, ref_pel0_d2, ref_pel0_d3, ref_pel0_d4, ref_pel0_d5, ref_pel0_d6, ref_pel0_d7;
reg      [`PIXEL_WIDTH-1:0]      ref_pel1_d1, ref_pel1_d2, ref_pel1_d3, ref_pel1_d4, ref_pel1_d5, ref_pel1_d6, ref_pel1_d7;
reg      [`PIXEL_WIDTH-1:0]      ref_pel2_d1, ref_pel2_d2, ref_pel2_d3, ref_pel2_d4, ref_pel2_d5, ref_pel2_d6, ref_pel2_d7;
reg      [`PIXEL_WIDTH-1:0]      ref_pel3_d1, ref_pel3_d2, ref_pel3_d3, ref_pel3_d4, ref_pel3_d5, ref_pel3_d6, ref_pel3_d7;
reg      [`PIXEL_WIDTH-1:0]      ref_pel4_d1, ref_pel4_d2, ref_pel4_d3, ref_pel4_d4, ref_pel4_d5, ref_pel4_d6, ref_pel4_d7;
reg      [`PIXEL_WIDTH-1:0]      ref_pel5_d1, ref_pel5_d2, ref_pel5_d3, ref_pel5_d4, ref_pel5_d5, ref_pel5_d6, ref_pel5_d7;
reg      [`PIXEL_WIDTH-1:0]      ref_pel6_d1, ref_pel6_d2, ref_pel6_d3, ref_pel6_d4, ref_pel6_d5, ref_pel6_d6, ref_pel6_d7;
reg      [`PIXEL_WIDTH-1:0]      ref_pel7_d1, ref_pel7_d2, ref_pel7_d3, ref_pel7_d4, ref_pel7_d5, ref_pel7_d6, ref_pel7_d7;


//wire cnthorLargerThan3; 
//wire cnthorLargerThan4; 
//
//wire cntrefLargerThan7; 
//wire cntrefLargerThan8; 
//
//wire cnthorLargerThan7; 
//wire cnthorLargerThan8; 

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
  if (~rstn) begin
    q1_buf0_d1 <= 'd0; q1_buf0_d2 <= 'd0; q1_buf0_d3 <= 'd0; q1_buf0_d4 <= 'd0; q1_buf0_d5 <= 'd0; q1_buf0_d6 <= 'd0; q1_buf0_d7 <= 'd0;
    q1_buf1_d1 <= 'd0; q1_buf1_d2 <= 'd0; q1_buf1_d3 <= 'd0; q1_buf1_d4 <= 'd0; q1_buf1_d5 <= 'd0; q1_buf1_d6 <= 'd0; q1_buf1_d7 <= 'd0;
    q1_buf2_d1 <= 'd0; q1_buf2_d2 <= 'd0; q1_buf2_d3 <= 'd0; q1_buf2_d4 <= 'd0; q1_buf2_d5 <= 'd0; q1_buf2_d6 <= 'd0; q1_buf2_d7 <= 'd0;
    q1_buf3_d1 <= 'd0; q1_buf3_d2 <= 'd0; q1_buf3_d3 <= 'd0; q1_buf3_d4 <= 'd0; q1_buf3_d5 <= 'd0; q1_buf3_d6 <= 'd0; q1_buf3_d7 <= 'd0;
    q1_buf4_d1 <= 'd0; q1_buf4_d2 <= 'd0; q1_buf4_d3 <= 'd0; q1_buf4_d4 <= 'd0; q1_buf4_d5 <= 'd0; q1_buf4_d6 <= 'd0; q1_buf4_d7 <= 'd0;
    q1_buf5_d1 <= 'd0; q1_buf5_d2 <= 'd0; q1_buf5_d3 <= 'd0; q1_buf5_d4 <= 'd0; q1_buf5_d5 <= 'd0; q1_buf5_d6 <= 'd0; q1_buf5_d7 <= 'd0;
    q1_buf6_d1 <= 'd0; q1_buf6_d2 <= 'd0; q1_buf6_d3 <= 'd0; q1_buf6_d4 <= 'd0; q1_buf6_d5 <= 'd0; q1_buf6_d6 <= 'd0; q1_buf6_d7 <= 'd0;
    q1_buf7_d1 <= 'd0; q1_buf7_d2 <= 'd0; q1_buf7_d3 <= 'd0; q1_buf7_d4 <= 'd0; q1_buf7_d5 <= 'd0; q1_buf7_d6 <= 'd0; q1_buf7_d7 <= 'd0;

    q3_buf0_d1 <= 'd0; q3_buf0_d2 <= 'd0; q3_buf0_d3 <= 'd0; q3_buf0_d4 <= 'd0; q3_buf0_d5 <= 'd0; q3_buf0_d6 <= 'd0; q3_buf0_d7 <= 'd0;
    q3_buf1_d1 <= 'd0; q3_buf1_d2 <= 'd0; q3_buf1_d3 <= 'd0; q3_buf1_d4 <= 'd0; q3_buf1_d5 <= 'd0; q3_buf1_d6 <= 'd0; q3_buf1_d7 <= 'd0;
    q3_buf2_d1 <= 'd0; q3_buf2_d2 <= 'd0; q3_buf2_d3 <= 'd0; q3_buf2_d4 <= 'd0; q3_buf2_d5 <= 'd0; q3_buf2_d6 <= 'd0; q3_buf2_d7 <= 'd0;
    q3_buf3_d1 <= 'd0; q3_buf3_d2 <= 'd0; q3_buf3_d3 <= 'd0; q3_buf3_d4 <= 'd0; q3_buf3_d5 <= 'd0; q3_buf3_d6 <= 'd0; q3_buf3_d7 <= 'd0;
    q3_buf4_d1 <= 'd0; q3_buf4_d2 <= 'd0; q3_buf4_d3 <= 'd0; q3_buf4_d4 <= 'd0; q3_buf4_d5 <= 'd0; q3_buf4_d6 <= 'd0; q3_buf4_d7 <= 'd0;
    q3_buf5_d1 <= 'd0; q3_buf5_d2 <= 'd0; q3_buf5_d3 <= 'd0; q3_buf5_d4 <= 'd0; q3_buf5_d5 <= 'd0; q3_buf5_d6 <= 'd0; q3_buf5_d7 <= 'd0;
    q3_buf6_d1 <= 'd0; q3_buf6_d2 <= 'd0; q3_buf6_d3 <= 'd0; q3_buf6_d4 <= 'd0; q3_buf6_d5 <= 'd0; q3_buf6_d6 <= 'd0; q3_buf6_d7 <= 'd0;
    q3_buf7_d1 <= 'd0; q3_buf7_d2 <= 'd0; q3_buf7_d3 <= 'd0; q3_buf7_d4 <= 'd0; q3_buf7_d5 <= 'd0; q3_buf7_d6 <= 'd0; q3_buf7_d7 <= 'd0;

    h_buf0_d1 <= 'd0; h_buf0_d2 <= 'd0; h_buf0_d3 <= 'd0; h_buf0_d4 <= 'd0; h_buf0_d5 <= 'd0; h_buf0_d6 <= 'd0; h_buf0_d7 <= 'd0;
    h_buf1_d1 <= 'd0; h_buf1_d2 <= 'd0; h_buf1_d3 <= 'd0; h_buf1_d4 <= 'd0; h_buf1_d5 <= 'd0; h_buf1_d6 <= 'd0; h_buf1_d7 <= 'd0;
    h_buf2_d1 <= 'd0; h_buf2_d2 <= 'd0; h_buf2_d3 <= 'd0; h_buf2_d4 <= 'd0; h_buf2_d5 <= 'd0; h_buf2_d6 <= 'd0; h_buf2_d7 <= 'd0;
    h_buf3_d1 <= 'd0; h_buf3_d2 <= 'd0; h_buf3_d3 <= 'd0; h_buf3_d4 <= 'd0; h_buf3_d5 <= 'd0; h_buf3_d6 <= 'd0; h_buf3_d7 <= 'd0;
    h_buf4_d1 <= 'd0; h_buf4_d2 <= 'd0; h_buf4_d3 <= 'd0; h_buf4_d4 <= 'd0; h_buf4_d5 <= 'd0; h_buf4_d6 <= 'd0; h_buf4_d7 <= 'd0;
    h_buf5_d1 <= 'd0; h_buf5_d2 <= 'd0; h_buf5_d3 <= 'd0; h_buf5_d4 <= 'd0; h_buf5_d5 <= 'd0; h_buf5_d6 <= 'd0; h_buf5_d7 <= 'd0;
    h_buf6_d1 <= 'd0; h_buf6_d2 <= 'd0; h_buf6_d3 <= 'd0; h_buf6_d4 <= 'd0; h_buf6_d5 <= 'd0; h_buf6_d6 <= 'd0; h_buf6_d7 <= 'd0;
    h_buf7_d1 <= 'd0; h_buf7_d2 <= 'd0; h_buf7_d3 <= 'd0; h_buf7_d4 <= 'd0; h_buf7_d5 <= 'd0; h_buf7_d6 <= 'd0; h_buf7_d7 <= 'd0;
  end
  else if (horbuf_valid_i) begin
    q1_buf0_d1 <= q1_buf0_i; q1_buf0_d2 <= q1_buf0_d1; q1_buf0_d3 <= q1_buf0_d2; q1_buf0_d4 <= q1_buf0_d3; q1_buf0_d5 <= q1_buf0_d4; q1_buf0_d6 <= q1_buf0_d5; q1_buf0_d7 <= q1_buf0_d6;
    q1_buf1_d1 <= q1_buf1_i; q1_buf1_d2 <= q1_buf1_d1; q1_buf1_d3 <= q1_buf1_d2; q1_buf1_d4 <= q1_buf1_d3; q1_buf1_d5 <= q1_buf1_d4; q1_buf1_d6 <= q1_buf1_d5; q1_buf1_d7 <= q1_buf1_d6;
    q1_buf2_d1 <= q1_buf2_i; q1_buf2_d2 <= q1_buf2_d1; q1_buf2_d3 <= q1_buf2_d2; q1_buf2_d4 <= q1_buf2_d3; q1_buf2_d5 <= q1_buf2_d4; q1_buf2_d6 <= q1_buf2_d5; q1_buf2_d7 <= q1_buf2_d6;
    q1_buf3_d1 <= q1_buf3_i; q1_buf3_d2 <= q1_buf3_d1; q1_buf3_d3 <= q1_buf3_d2; q1_buf3_d4 <= q1_buf3_d3; q1_buf3_d5 <= q1_buf3_d4; q1_buf3_d6 <= q1_buf3_d5; q1_buf3_d7 <= q1_buf3_d6;
    q1_buf4_d1 <= q1_buf4_i; q1_buf4_d2 <= q1_buf4_d1; q1_buf4_d3 <= q1_buf4_d2; q1_buf4_d4 <= q1_buf4_d3; q1_buf4_d5 <= q1_buf4_d4; q1_buf4_d6 <= q1_buf4_d5; q1_buf4_d7 <= q1_buf4_d6;
    q1_buf5_d1 <= q1_buf5_i; q1_buf5_d2 <= q1_buf5_d1; q1_buf5_d3 <= q1_buf5_d2; q1_buf5_d4 <= q1_buf5_d3; q1_buf5_d5 <= q1_buf5_d4; q1_buf5_d6 <= q1_buf5_d5; q1_buf5_d7 <= q1_buf5_d6;
    q1_buf6_d1 <= q1_buf6_i; q1_buf6_d2 <= q1_buf6_d1; q1_buf6_d3 <= q1_buf6_d2; q1_buf6_d4 <= q1_buf6_d3; q1_buf6_d5 <= q1_buf6_d4; q1_buf6_d6 <= q1_buf6_d5; q1_buf6_d7 <= q1_buf6_d6;
    q1_buf7_d1 <= q1_buf7_i; q1_buf7_d2 <= q1_buf7_d1; q1_buf7_d3 <= q1_buf7_d2; q1_buf7_d4 <= q1_buf7_d3; q1_buf7_d5 <= q1_buf7_d4; q1_buf7_d6 <= q1_buf7_d5; q1_buf7_d7 <= q1_buf7_d6;

    q3_buf0_d1 <= q3_buf0_i; q3_buf0_d2 <= q3_buf0_d1; q3_buf0_d3 <= q3_buf0_d2; q3_buf0_d4 <= q3_buf0_d3; q3_buf0_d5 <= q3_buf0_d4; q3_buf0_d6 <= q3_buf0_d5; q3_buf0_d7 <= q3_buf0_d6;
    q3_buf1_d1 <= q3_buf1_i; q3_buf1_d2 <= q3_buf1_d1; q3_buf1_d3 <= q3_buf1_d2; q3_buf1_d4 <= q3_buf1_d3; q3_buf1_d5 <= q3_buf1_d4; q3_buf1_d6 <= q3_buf1_d5; q3_buf1_d7 <= q3_buf1_d6;
    q3_buf2_d1 <= q3_buf2_i; q3_buf2_d2 <= q3_buf2_d1; q3_buf2_d3 <= q3_buf2_d2; q3_buf2_d4 <= q3_buf2_d3; q3_buf2_d5 <= q3_buf2_d4; q3_buf2_d6 <= q3_buf2_d5; q3_buf2_d7 <= q3_buf2_d6;
    q3_buf3_d1 <= q3_buf3_i; q3_buf3_d2 <= q3_buf3_d1; q3_buf3_d3 <= q3_buf3_d2; q3_buf3_d4 <= q3_buf3_d3; q3_buf3_d5 <= q3_buf3_d4; q3_buf3_d6 <= q3_buf3_d5; q3_buf3_d7 <= q3_buf3_d6;
    q3_buf4_d1 <= q3_buf4_i; q3_buf4_d2 <= q3_buf4_d1; q3_buf4_d3 <= q3_buf4_d2; q3_buf4_d4 <= q3_buf4_d3; q3_buf4_d5 <= q3_buf4_d4; q3_buf4_d6 <= q3_buf4_d5; q3_buf4_d7 <= q3_buf4_d6;
    q3_buf5_d1 <= q3_buf5_i; q3_buf5_d2 <= q3_buf5_d1; q3_buf5_d3 <= q3_buf5_d2; q3_buf5_d4 <= q3_buf5_d3; q3_buf5_d5 <= q3_buf5_d4; q3_buf5_d6 <= q3_buf5_d5; q3_buf5_d7 <= q3_buf5_d6;
    q3_buf6_d1 <= q3_buf6_i; q3_buf6_d2 <= q3_buf6_d1; q3_buf6_d3 <= q3_buf6_d2; q3_buf6_d4 <= q3_buf6_d3; q3_buf6_d5 <= q3_buf6_d4; q3_buf6_d6 <= q3_buf6_d5; q3_buf6_d7 <= q3_buf6_d6;
    q3_buf7_d1 <= q3_buf7_i; q3_buf7_d2 <= q3_buf7_d1; q3_buf7_d3 <= q3_buf7_d2; q3_buf7_d4 <= q3_buf7_d3; q3_buf7_d5 <= q3_buf7_d4; q3_buf7_d6 <= q3_buf7_d5; q3_buf7_d7 <= q3_buf7_d6;

    h_buf0_d1 <= h_buf0_i; h_buf0_d2 <= h_buf0_d1; h_buf0_d3 <= h_buf0_d2; h_buf0_d4 <= h_buf0_d3; h_buf0_d5 <= h_buf0_d4; h_buf0_d6 <= h_buf0_d5; h_buf0_d7 <= h_buf0_d6;
    h_buf1_d1 <= h_buf1_i; h_buf1_d2 <= h_buf1_d1; h_buf1_d3 <= h_buf1_d2; h_buf1_d4 <= h_buf1_d3; h_buf1_d5 <= h_buf1_d4; h_buf1_d6 <= h_buf1_d5; h_buf1_d7 <= h_buf1_d6;
    h_buf2_d1 <= h_buf2_i; h_buf2_d2 <= h_buf2_d1; h_buf2_d3 <= h_buf2_d2; h_buf2_d4 <= h_buf2_d3; h_buf2_d5 <= h_buf2_d4; h_buf2_d6 <= h_buf2_d5; h_buf2_d7 <= h_buf2_d6;
    h_buf3_d1 <= h_buf3_i; h_buf3_d2 <= h_buf3_d1; h_buf3_d3 <= h_buf3_d2; h_buf3_d4 <= h_buf3_d3; h_buf3_d5 <= h_buf3_d4; h_buf3_d6 <= h_buf3_d5; h_buf3_d7 <= h_buf3_d6;
    h_buf4_d1 <= h_buf4_i; h_buf4_d2 <= h_buf4_d1; h_buf4_d3 <= h_buf4_d2; h_buf4_d4 <= h_buf4_d3; h_buf4_d5 <= h_buf4_d4; h_buf4_d6 <= h_buf4_d5; h_buf4_d7 <= h_buf4_d6;
    h_buf5_d1 <= h_buf5_i; h_buf5_d2 <= h_buf5_d1; h_buf5_d3 <= h_buf5_d2; h_buf5_d4 <= h_buf5_d3; h_buf5_d5 <= h_buf5_d4; h_buf5_d6 <= h_buf5_d5; h_buf5_d7 <= h_buf5_d6;
    h_buf6_d1 <= h_buf6_i; h_buf6_d2 <= h_buf6_d1; h_buf6_d3 <= h_buf6_d2; h_buf6_d4 <= h_buf6_d3; h_buf6_d5 <= h_buf6_d4; h_buf6_d6 <= h_buf6_d5; h_buf6_d7 <= h_buf6_d6;
    h_buf7_d1 <= h_buf7_i; h_buf7_d2 <= h_buf7_d1; h_buf7_d3 <= h_buf7_d2; h_buf7_d4 <= h_buf7_d3; h_buf7_d5 <= h_buf7_d4; h_buf7_d6 <= h_buf7_d5; h_buf7_d7 <= h_buf7_d6;

  end
end

always @ (posedge clk or negedge rstn) begin
  if(~rstn) begin
    cnt_hor <= 'd0;
  end
  else if(horbuf_valid_i) begin
    cnt_hor <= cnt_hor + 'd1;
  end
end

always @ (posedge clk or negedge rstn ) begin
    if (~rstn) begin
    ref_pel0_d1 <= 'd0; ref_pel0_d2 <= 'd0; ref_pel0_d3 <= 'd0; ref_pel0_d4 <= 'd0; ref_pel0_d5 <= 'd0; ref_pel0_d6 <= 'd0; ref_pel0_d7 <= 'd0;
    ref_pel1_d1 <= 'd0; ref_pel1_d2 <= 'd0; ref_pel1_d3 <= 'd0; ref_pel1_d4 <= 'd0; ref_pel1_d5 <= 'd0; ref_pel1_d6 <= 'd0; ref_pel1_d7 <= 'd0;
    ref_pel2_d1 <= 'd0; ref_pel2_d2 <= 'd0; ref_pel2_d3 <= 'd0; ref_pel2_d4 <= 'd0; ref_pel2_d5 <= 'd0; ref_pel2_d6 <= 'd0; ref_pel2_d7 <= 'd0;
    ref_pel3_d1 <= 'd0; ref_pel3_d2 <= 'd0; ref_pel3_d3 <= 'd0; ref_pel3_d4 <= 'd0; ref_pel3_d5 <= 'd0; ref_pel3_d6 <= 'd0; ref_pel3_d7 <= 'd0;
    ref_pel4_d1 <= 'd0; ref_pel4_d2 <= 'd0; ref_pel4_d3 <= 'd0; ref_pel4_d4 <= 'd0; ref_pel4_d5 <= 'd0; ref_pel4_d6 <= 'd0; ref_pel4_d7 <= 'd0;
    ref_pel5_d1 <= 'd0; ref_pel5_d2 <= 'd0; ref_pel5_d3 <= 'd0; ref_pel5_d4 <= 'd0; ref_pel5_d5 <= 'd0; ref_pel5_d6 <= 'd0; ref_pel5_d7 <= 'd0;
    ref_pel6_d1 <= 'd0; ref_pel6_d2 <= 'd0; ref_pel6_d3 <= 'd0; ref_pel6_d4 <= 'd0; ref_pel6_d5 <= 'd0; ref_pel6_d6 <= 'd0; ref_pel6_d7 <= 'd0;
    ref_pel7_d1 <= 'd0; ref_pel7_d2 <= 'd0; ref_pel7_d3 <= 'd0; ref_pel7_d4 <= 'd0; ref_pel7_d5 <= 'd0; ref_pel7_d6 <= 'd0; ref_pel7_d7 <= 'd0;
    end
    else if (refpel_valid_i) begin
    ref_pel0_d1 <= ref_pel0_i; ref_pel0_d2 <= ref_pel0_d1; ref_pel0_d3 <= ref_pel0_d2; ref_pel0_d4 <= ref_pel0_d3; ref_pel0_d5 <= ref_pel0_d4; ref_pel0_d6 <= ref_pel0_d5; ref_pel0_d7 <= ref_pel0_d6;
    ref_pel1_d1 <= ref_pel1_i; ref_pel1_d2 <= ref_pel1_d1; ref_pel1_d3 <= ref_pel1_d2; ref_pel1_d4 <= ref_pel1_d3; ref_pel1_d5 <= ref_pel1_d4; ref_pel1_d6 <= ref_pel1_d5; ref_pel1_d7 <= ref_pel1_d6;
    ref_pel2_d1 <= ref_pel2_i; ref_pel2_d2 <= ref_pel2_d1; ref_pel2_d3 <= ref_pel2_d2; ref_pel2_d4 <= ref_pel2_d3; ref_pel2_d5 <= ref_pel2_d4; ref_pel2_d6 <= ref_pel2_d5; ref_pel2_d7 <= ref_pel2_d6;
    ref_pel3_d1 <= ref_pel3_i; ref_pel3_d2 <= ref_pel3_d1; ref_pel3_d3 <= ref_pel3_d2; ref_pel3_d4 <= ref_pel3_d3; ref_pel3_d5 <= ref_pel3_d4; ref_pel3_d6 <= ref_pel3_d5; ref_pel3_d7 <= ref_pel3_d6;
    ref_pel4_d1 <= ref_pel4_i; ref_pel4_d2 <= ref_pel4_d1; ref_pel4_d3 <= ref_pel4_d2; ref_pel4_d4 <= ref_pel4_d3; ref_pel4_d5 <= ref_pel4_d4; ref_pel4_d6 <= ref_pel4_d5; ref_pel4_d7 <= ref_pel4_d6;
    ref_pel5_d1 <= ref_pel5_i; ref_pel5_d2 <= ref_pel5_d1; ref_pel5_d3 <= ref_pel5_d2; ref_pel5_d4 <= ref_pel5_d3; ref_pel5_d5 <= ref_pel5_d4; ref_pel5_d6 <= ref_pel5_d5; ref_pel5_d7 <= ref_pel5_d6;
    ref_pel6_d1 <= ref_pel6_i; ref_pel6_d2 <= ref_pel6_d1; ref_pel6_d3 <= ref_pel6_d2; ref_pel6_d4 <= ref_pel6_d3; ref_pel6_d5 <= ref_pel6_d4; ref_pel6_d6 <= ref_pel6_d5; ref_pel6_d7 <= ref_pel6_d6;
    ref_pel7_d1 <= ref_pel7_i; ref_pel7_d2 <= ref_pel7_d1; ref_pel7_d3 <= ref_pel7_d2; ref_pel7_d4 <= ref_pel7_d3; ref_pel7_d5 <= ref_pel7_d4; ref_pel7_d6 <= ref_pel7_d5; ref_pel7_d7 <= ref_pel7_d6;
    end
end

always @ (posedge clk or negedge rstn) begin
  if(~rstn) begin
    cnt_ref <= 'd0;
  end
  else if(refpel_valid_i) begin
    cnt_ref <= cnt_ref + 'd1;
  end
end
// ********************************************
//
//    Sub Module
//
// ********************************************

// vertical quarter 1 interpolator

// from q1
//
//
fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_1_0 (
	.tap_0_i( q1_buf0_d7 )		,
	.tap_1_i( q1_buf0_d6 )		,
	.tap_2_i( q1_buf0_d5 )		,
	.tap_3_i( q1_buf0_d4 )		,
	.tap_4_i( q1_buf0_d3 )		,
	.tap_5_i( q1_buf0_d2 )		,
	.tap_6_i( q1_buf0_d1 )		,
	.tap_7_i( q1_buf0_i  )		,
	.val_o  ( vquarter_1_1_pel0_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_1_1 (
	.tap_0_i( q1_buf1_d7 )		,
	.tap_1_i( q1_buf1_d6 )		,
	.tap_2_i( q1_buf1_d5 )		,
	.tap_3_i( q1_buf1_d4 )		,
	.tap_4_i( q1_buf1_d3 )		,
	.tap_5_i( q1_buf1_d2 )		,
	.tap_6_i( q1_buf1_d1 )		,
	.tap_7_i( q1_buf1_i  )		,
	.val_o  ( vquarter_1_1_pel1_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_1_2 (
	.tap_0_i( q1_buf2_d7 )		,
	.tap_1_i( q1_buf2_d6 )		,
	.tap_2_i( q1_buf2_d5 )		,
	.tap_3_i( q1_buf2_d4 )		,
	.tap_4_i( q1_buf2_d3 )		,
	.tap_5_i( q1_buf2_d2 )		,
	.tap_6_i( q1_buf2_d1 )		,
	.tap_7_i( q1_buf2_i  )		,
	.val_o  ( vquarter_1_1_pel2_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_1_3 (
	.tap_0_i( q1_buf3_d7 )		,
	.tap_1_i( q1_buf3_d6 )		,
	.tap_2_i( q1_buf3_d5 )		,
	.tap_3_i( q1_buf3_d4 )		,
	.tap_4_i( q1_buf3_d3 )		,
	.tap_5_i( q1_buf3_d2 )		,
	.tap_6_i( q1_buf3_d1 )		,
	.tap_7_i( q1_buf3_i  )		,
	.val_o  ( vquarter_1_1_pel3_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_1_4 (
	.tap_0_i( q1_buf4_d7 )		,
	.tap_1_i( q1_buf4_d6 )		,
	.tap_2_i( q1_buf4_d5 )		,
	.tap_3_i( q1_buf4_d4 )		,
	.tap_4_i( q1_buf4_d3 )		,
	.tap_5_i( q1_buf4_d2 )		,
	.tap_6_i( q1_buf4_d1 )		,
	.tap_7_i( q1_buf4_i  )		,
	.val_o  ( vquarter_1_1_pel4_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_1_5 (
	.tap_0_i( q1_buf5_d7 )		,
	.tap_1_i( q1_buf5_d6 )		,
	.tap_2_i( q1_buf5_d5 )		,
	.tap_3_i( q1_buf5_d4 )		,
	.tap_4_i( q1_buf5_d3 )		,
	.tap_5_i( q1_buf5_d2 )		,
	.tap_6_i( q1_buf5_d1 )		,
	.tap_7_i( q1_buf5_i  )		,
	.val_o  ( vquarter_1_1_pel5_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_1_6 (
	.tap_0_i( q1_buf6_d7 )		,
	.tap_1_i( q1_buf6_d6 )		,
	.tap_2_i( q1_buf6_d5 )		,
	.tap_3_i( q1_buf6_d4 )		,
	.tap_4_i( q1_buf6_d3 )		,
	.tap_5_i( q1_buf6_d2 )		,
	.tap_6_i( q1_buf6_d1 )		,
	.tap_7_i( q1_buf6_i  )		,
	.val_o  ( vquarter_1_1_pel6_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_1_7 (
	.tap_0_i( q1_buf7_d7 )		,
	.tap_1_i( q1_buf7_d6 )		,
	.tap_2_i( q1_buf7_d5 )		,
	.tap_3_i( q1_buf7_d4 )		,
	.tap_4_i( q1_buf7_d3 )		,
	.tap_5_i( q1_buf7_d2 )		,
	.tap_6_i( q1_buf7_d1 )		,
	.tap_7_i( q1_buf7_i  )		,
	.val_o  ( vquarter_1_1_pel7_o)		
);

// from q3
// q3_buf0_d7  
// q3_buf0_d6 
// q3_buf0_d5 
// q3_buf0_d4 
// q3_buf0_d3 
// q3_buf0_d2 
// q3_buf0_d1 
// q3_buf0_i  
//
// 
fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_3_0 (
	.tap_0_i( q3_buf0_d7 )		,
	.tap_1_i( q3_buf0_d6 )		,
	.tap_2_i( q3_buf0_d5 )		,
	.tap_3_i( q3_buf0_d4 )		,
	.tap_4_i( q3_buf0_d3 )		,
	.tap_5_i( q3_buf0_d2 )		,
	.tap_6_i( q3_buf0_d1 )		,
	.tap_7_i( q3_buf0_i  )		,
	.val_o  ( vquarter_1_3_pel0_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_3_1 (
	.tap_0_i( q3_buf1_d7 )		,
	.tap_1_i( q3_buf1_d6 )		,
	.tap_2_i( q3_buf1_d5 )		,
	.tap_3_i( q3_buf1_d4 )		,
	.tap_4_i( q3_buf1_d3 )		,
	.tap_5_i( q3_buf1_d2 )		,
	.tap_6_i( q3_buf1_d1 )		,
	.tap_7_i( q3_buf1_i  )		,
	.val_o  ( vquarter_1_3_pel1_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_3_2 (
	.tap_0_i( q3_buf2_d7 )		,
	.tap_1_i( q3_buf2_d6 )		,
	.tap_2_i( q3_buf2_d5 )		,
	.tap_3_i( q3_buf2_d4 )		,
	.tap_4_i( q3_buf2_d3 )		,
	.tap_5_i( q3_buf2_d2 )		,
	.tap_6_i( q3_buf2_d1 )		,
	.tap_7_i( q3_buf2_i  )		,
	.val_o  ( vquarter_1_3_pel2_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_3_3 (
	.tap_0_i( q3_buf3_d7 )		,
	.tap_1_i( q3_buf3_d6 )		,
	.tap_2_i( q3_buf3_d5 )		,
	.tap_3_i( q3_buf3_d4 )		,
	.tap_4_i( q3_buf3_d3 )		,
	.tap_5_i( q3_buf3_d2 )		,
	.tap_6_i( q3_buf3_d1 )		,
	.tap_7_i( q3_buf3_i  )		,
	.val_o  ( vquarter_1_3_pel3_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_3_4 (
	.tap_0_i( q3_buf4_d7 )		,
	.tap_1_i( q3_buf4_d6 )		,
	.tap_2_i( q3_buf4_d5 )		,
	.tap_3_i( q3_buf4_d4 )		,
	.tap_4_i( q3_buf4_d3 )		,
	.tap_5_i( q3_buf4_d2 )		,
	.tap_6_i( q3_buf4_d1 )		,
	.tap_7_i( q3_buf4_i  )		,
	.val_o  ( vquarter_1_3_pel4_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_3_5 (
	.tap_0_i( q3_buf5_d7 )		,
	.tap_1_i( q3_buf5_d6 )		,
	.tap_2_i( q3_buf5_d5 )		,
	.tap_3_i( q3_buf5_d4 )		,
	.tap_4_i( q3_buf5_d3 )		,
	.tap_5_i( q3_buf5_d2 )		,
	.tap_6_i( q3_buf5_d1 )		,
	.tap_7_i( q3_buf5_i  )		,
	.val_o  ( vquarter_1_3_pel5_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_3_6 (
	.tap_0_i( q3_buf6_d7 )		,
	.tap_1_i( q3_buf6_d6 )		,
	.tap_2_i( q3_buf6_d5 )		,
	.tap_3_i( q3_buf6_d4 )		,
	.tap_4_i( q3_buf6_d3 )		,
	.tap_5_i( q3_buf6_d2 )		,
	.tap_6_i( q3_buf6_d1 )		,
	.tap_7_i( q3_buf6_i  )		,
	.val_o  ( vquarter_1_3_pel6_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_3_7 (
	.tap_0_i( q3_buf7_d7 )		,
	.tap_1_i( q3_buf7_d6 )		,
	.tap_2_i( q3_buf7_d5 )		,
	.tap_3_i( q3_buf7_d4 )		,
	.tap_4_i( q3_buf7_d3 )		,
	.tap_5_i( q3_buf7_d2 )		,
	.tap_6_i( q3_buf7_d1 )		,
	.tap_7_i( q3_buf7_i  )		,
	.val_o  ( vquarter_1_3_pel7_o)		
);

//from half buf
// h_buf0_d7  
// h_buf0_d6 
// h_buf0_d5 
// h_buf0_d4 
// h_buf0_d3 
// h_buf0_d2 
// h_buf0_d1 
// h_buf0_i  
//
//
fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_2_0 (
	.tap_0_i( h_buf0_d7 )		,
	.tap_1_i( h_buf0_d6 )		,
	.tap_2_i( h_buf0_d5 )		,
	.tap_3_i( h_buf0_d4 )		,
	.tap_4_i( h_buf0_d3 )		,
	.tap_5_i( h_buf0_d2 )		,
	.tap_6_i( h_buf0_d1 )		,
	.tap_7_i( h_buf0_i  )		,
	.val_o  ( vquarter_1_2_pel0_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_2_1 (
	.tap_0_i( h_buf1_d7 )		,
	.tap_1_i( h_buf1_d6 )		,
	.tap_2_i( h_buf1_d5 )		,
	.tap_3_i( h_buf1_d4 )		,
	.tap_4_i( h_buf1_d3 )		,
	.tap_5_i( h_buf1_d2 )		,
	.tap_6_i( h_buf1_d1 )		,
	.tap_7_i( h_buf1_i  )		,
	.val_o  ( vquarter_1_2_pel1_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_2_2 (
	.tap_0_i( h_buf2_d7  )		,
	.tap_1_i( h_buf2_d6  )		,
	.tap_2_i( h_buf2_d5  )		,
	.tap_3_i( h_buf2_d4  )		,
	.tap_4_i( h_buf2_d3  )		,
	.tap_5_i( h_buf2_d2  )		,
	.tap_6_i( h_buf2_d1  )		,
	.tap_7_i( h_buf2_i   )		,
	.val_o  ( vquarter_1_2_pel2_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_2_3 (
	.tap_0_i( h_buf3_d7  )		,
	.tap_1_i( h_buf3_d6  )		,
	.tap_2_i( h_buf3_d5  )		,
	.tap_3_i( h_buf3_d4  )		,
	.tap_4_i( h_buf3_d3  )		,
	.tap_5_i( h_buf3_d2  )		,
	.tap_6_i( h_buf3_d1  )		,
	.tap_7_i( h_buf3_i   )		,
	.val_o  ( vquarter_1_2_pel3_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_2_4 (
	.tap_0_i( h_buf4_d7 )		,
	.tap_1_i( h_buf4_d6 )		,
	.tap_2_i( h_buf4_d5 )		,
	.tap_3_i( h_buf4_d4 )		,
	.tap_4_i( h_buf4_d3 )		,
	.tap_5_i( h_buf4_d2 )		,
	.tap_6_i( h_buf4_d1 )		,
	.tap_7_i( h_buf4_i  )		,
	.val_o  ( vquarter_1_2_pel4_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_2_5 (
	.tap_0_i( h_buf5_d7 )		,
	.tap_1_i( h_buf5_d6 )		,
	.tap_2_i( h_buf5_d5 )		,
	.tap_3_i( h_buf5_d4 )		,
	.tap_4_i( h_buf5_d3 )		,
	.tap_5_i( h_buf5_d2 )		,
	.tap_6_i( h_buf5_d1 )		,
	.tap_7_i( h_buf5_i  )		,
	.val_o  ( vquarter_1_2_pel5_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_2_6 (
	.tap_0_i( h_buf6_d7 )		,
	.tap_1_i( h_buf6_d6 )		,
	.tap_2_i( h_buf6_d5 )		,
	.tap_3_i( h_buf6_d4 )		,
	.tap_4_i( h_buf6_d3 )		,
	.tap_5_i( h_buf6_d2 )		,
	.tap_6_i( h_buf6_d1 )		,
	.tap_7_i( h_buf6_i  )		,
	.val_o  ( vquarter_1_2_pel6_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_1_2_7 (
	.tap_0_i( h_buf7_d7 )		,
	.tap_1_i( h_buf7_d6 )		,
	.tap_2_i( h_buf7_d5 )		,
	.tap_3_i( h_buf7_d4 )		,
	.tap_4_i( h_buf7_d3 )		,
	.tap_5_i( h_buf7_d2 )		,
	.tap_6_i( h_buf7_d1 )		,
	.tap_7_i( h_buf7_i  )		,
	.val_o  ( vquarter_1_2_pel7_o)		
);

// from ref
// ref_pel0_d7   
// ref_pel0_d6 
// ref_pel0_d5 
// ref_pel0_d4 
// ref_pel0_d3 
// ref_pel0_d2 
// ref_pel0_d1 
// ref_pel0_i   
//
fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_1_0_0 (
	.tap_0_i( ref_pel0_d7 )		,
	.tap_1_i( ref_pel0_d6 )		,
	.tap_2_i( ref_pel0_d5 )		,
	.tap_3_i( ref_pel0_d4 )		,
	.tap_4_i( ref_pel0_d3 )		,
	.tap_5_i( ref_pel0_d2 )		,
	.tap_6_i( ref_pel0_d1 )		,
	.tap_7_i( ref_pel0_i  )		,
	.val_o  ( vquarter_1_0_pel0_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_1_0_1 (
	.tap_0_i( ref_pel1_d7 )		,
	.tap_1_i( ref_pel1_d6 )		,
	.tap_2_i( ref_pel1_d5 )		,
	.tap_3_i( ref_pel1_d4 )		,
	.tap_4_i( ref_pel1_d3 )		,
	.tap_5_i( ref_pel1_d2 )		,
	.tap_6_i( ref_pel1_d1 )		,
	.tap_7_i( ref_pel1_i  )		,
	.val_o  ( vquarter_1_0_pel1_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_1_0_2 (
	.tap_0_i( ref_pel2_d7 )		,
	.tap_1_i( ref_pel2_d6 )		,
	.tap_2_i( ref_pel2_d5 )		,
	.tap_3_i( ref_pel2_d4 )		,
	.tap_4_i( ref_pel2_d3 )		,
	.tap_5_i( ref_pel2_d2 )		,
	.tap_6_i( ref_pel2_d1 )		,
	.tap_7_i( ref_pel2_i  )		,
	.val_o  ( vquarter_1_0_pel2_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_1_0_3 (
	.tap_0_i( ref_pel3_d7 )		,
	.tap_1_i( ref_pel3_d6 )		,
	.tap_2_i( ref_pel3_d5 )		,
	.tap_3_i( ref_pel3_d4 )		,
	.tap_4_i( ref_pel3_d3 )		,
	.tap_5_i( ref_pel3_d2 )		,
	.tap_6_i( ref_pel3_d1 )		,
	.tap_7_i( ref_pel3_i  )		,
	.val_o  ( vquarter_1_0_pel3_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_1_0_4 (
	.tap_0_i( ref_pel4_d7 )		,
	.tap_1_i( ref_pel4_d6 )		,
	.tap_2_i( ref_pel4_d5 )		,
	.tap_3_i( ref_pel4_d4 )		,
	.tap_4_i( ref_pel4_d3 )		,
	.tap_5_i( ref_pel4_d2 )		,
	.tap_6_i( ref_pel4_d1 )		,
	.tap_7_i( ref_pel4_i  )		,
	.val_o  ( vquarter_1_0_pel4_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_1_0_5 (
	.tap_0_i( ref_pel5_d7 )		,
	.tap_1_i( ref_pel5_d6 )		,
	.tap_2_i( ref_pel5_d5 )		,
	.tap_3_i( ref_pel5_d4 )		,
	.tap_4_i( ref_pel5_d3 )		,
	.tap_5_i( ref_pel5_d2 )		,
	.tap_6_i( ref_pel5_d1 )		,
	.tap_7_i( ref_pel5_i  )		,
	.val_o  ( vquarter_1_0_pel5_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_1_0_6 (
	.tap_0_i( ref_pel6_d7 )		,
	.tap_1_i( ref_pel6_d6 )		,
	.tap_2_i( ref_pel6_d5 )		,
	.tap_3_i( ref_pel6_d4 )		,
	.tap_4_i( ref_pel6_d3 )		,
	.tap_5_i( ref_pel6_d2 )		,
	.tap_6_i( ref_pel6_d1 )		,
	.tap_7_i( ref_pel6_i  )		,
	.val_o  ( vquarter_1_0_pel6_o)		
);

fme_interpolator #(
	.TYPE(1),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_1_0_7 (
	.tap_0_i( ref_pel7_d7 )		,
	.tap_1_i( ref_pel7_d6 )		,
	.tap_2_i( ref_pel7_d5 )		,
	.tap_3_i( ref_pel7_d4 )		,
	.tap_4_i( ref_pel7_d3 )		,
	.tap_5_i( ref_pel7_d2 )		,
	.tap_6_i( ref_pel7_d1 )		,
	.tap_7_i( ref_pel7_i  )		,
	.val_o  ( vquarter_1_0_pel7_o)		
);

// vertical quarter 3 interpolator

// from 1


fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_1_0 (
	.tap_0_i( q1_buf0_d7 )		,
	.tap_1_i( q1_buf0_d6 )		,
	.tap_2_i( q1_buf0_d5 )		,
	.tap_3_i( q1_buf0_d4 )		,
	.tap_4_i( q1_buf0_d3 )		,
	.tap_5_i( q1_buf0_d2 )		,
	.tap_6_i( q1_buf0_d1 )		,
	.tap_7_i( q1_buf0_i  )		,
	.val_o  ( vquarter_3_1_pel0_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_1_1 (
	.tap_0_i( q1_buf1_d7 )		,
	.tap_1_i( q1_buf1_d6 )		,
	.tap_2_i( q1_buf1_d5 )		,
	.tap_3_i( q1_buf1_d4 )		,
	.tap_4_i( q1_buf1_d3 )		,
	.tap_5_i( q1_buf1_d2 )		,
	.tap_6_i( q1_buf1_d1 )		,
	.tap_7_i( q1_buf1_i  )		,
	.val_o  ( vquarter_3_1_pel1_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_1_2 (
	.tap_0_i( q1_buf2_d7 )		,
	.tap_1_i( q1_buf2_d6 )		,
	.tap_2_i( q1_buf2_d5 )		,
	.tap_3_i( q1_buf2_d4 )		,
	.tap_4_i( q1_buf2_d3 )		,
	.tap_5_i( q1_buf2_d2 )		,
	.tap_6_i( q1_buf2_d1 )		,
	.tap_7_i( q1_buf2_i  )		,
	.val_o  ( vquarter_3_1_pel2_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_1_3 (
	.tap_0_i( q1_buf3_d7 )		,
	.tap_1_i( q1_buf3_d6 )		,
	.tap_2_i( q1_buf3_d5 )		,
	.tap_3_i( q1_buf3_d4 )		,
	.tap_4_i( q1_buf3_d3 )		,
	.tap_5_i( q1_buf3_d2 )		,
	.tap_6_i( q1_buf3_d1 )		,
	.tap_7_i( q1_buf3_i  )		,
	.val_o  ( vquarter_3_1_pel3_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_1_4 (
	.tap_0_i( q1_buf4_d7 )		,
	.tap_1_i( q1_buf4_d6 )		,
	.tap_2_i( q1_buf4_d5 )		,
	.tap_3_i( q1_buf4_d4 )		,
	.tap_4_i( q1_buf4_d3 )		,
	.tap_5_i( q1_buf4_d2 )		,
	.tap_6_i( q1_buf4_d1 )		,
	.tap_7_i( q1_buf4_i  )		,
	.val_o  ( vquarter_3_1_pel4_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_1_5 (
	.tap_0_i( q1_buf5_d7 )		,
	.tap_1_i( q1_buf5_d6 )		,
	.tap_2_i( q1_buf5_d5 )		,
	.tap_3_i( q1_buf5_d4 )		,
	.tap_4_i( q1_buf5_d3 )		,
	.tap_5_i( q1_buf5_d2 )		,
	.tap_6_i( q1_buf5_d1 )		,
	.tap_7_i( q1_buf5_i  )		,
	.val_o  ( vquarter_3_1_pel5_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_1_6 (
	.tap_0_i( q1_buf6_d7 )		,
	.tap_1_i( q1_buf6_d6 )		,
	.tap_2_i( q1_buf6_d5 )		,
	.tap_3_i( q1_buf6_d4 )		,
	.tap_4_i( q1_buf6_d3 )		,
	.tap_5_i( q1_buf6_d2 )		,
	.tap_6_i( q1_buf6_d1 )		,
	.tap_7_i( q1_buf6_i  )		,
	.val_o  ( vquarter_3_1_pel6_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_1_7 (
	.tap_0_i( q1_buf7_d7 )		,
	.tap_1_i( q1_buf7_d6 )		,
	.tap_2_i( q1_buf7_d5 )		,
	.tap_3_i( q1_buf7_d4 )		,
	.tap_4_i( q1_buf7_d3 )		,
	.tap_5_i( q1_buf7_d2 )		,
	.tap_6_i( q1_buf7_d1 )		,
	.tap_7_i( q1_buf7_i  )		,
	.val_o  ( vquarter_3_1_pel7_o)		
);

// from 3

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_3_0 (
	.tap_0_i( q3_buf0_d7 )		,
	.tap_1_i( q3_buf0_d6 )		,
	.tap_2_i( q3_buf0_d5 )		,
	.tap_3_i( q3_buf0_d4 )		,
	.tap_4_i( q3_buf0_d3 )		,
	.tap_5_i( q3_buf0_d2 )		,
	.tap_6_i( q3_buf0_d1 )		,
	.tap_7_i( q3_buf0_i  )		,
	.val_o  ( vquarter_3_3_pel0_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_3_1 (
	.tap_0_i( q3_buf1_d7 )		,
	.tap_1_i( q3_buf1_d6 )		,
	.tap_2_i( q3_buf1_d5 )		,
	.tap_3_i( q3_buf1_d4 )		,
	.tap_4_i( q3_buf1_d3 )		,
	.tap_5_i( q3_buf1_d2 )		,
	.tap_6_i( q3_buf1_d1 )		,
	.tap_7_i( q3_buf1_i  )		,
	.val_o  ( vquarter_3_3_pel1_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_3_2 (
	.tap_0_i( q3_buf2_d7 )		,
	.tap_1_i( q3_buf2_d6 )		,
	.tap_2_i( q3_buf2_d5 )		,
	.tap_3_i( q3_buf2_d4 )		,
	.tap_4_i( q3_buf2_d3 )		,
	.tap_5_i( q3_buf2_d2 )		,
	.tap_6_i( q3_buf2_d1 )		,
	.tap_7_i( q3_buf2_i  )		,
	.val_o  ( vquarter_3_3_pel2_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_3_3 (
	.tap_0_i( q3_buf3_d7 )		,
	.tap_1_i( q3_buf3_d6 )		,
	.tap_2_i( q3_buf3_d5 )		,
	.tap_3_i( q3_buf3_d4 )		,
	.tap_4_i( q3_buf3_d3 )		,
	.tap_5_i( q3_buf3_d2 )		,
	.tap_6_i( q3_buf3_d1 )		,
	.tap_7_i( q3_buf3_i  )		,
	.val_o  ( vquarter_3_3_pel3_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_3_4 (
	.tap_0_i( q3_buf4_d7 )		,
	.tap_1_i( q3_buf4_d6 )		,
	.tap_2_i( q3_buf4_d5 )		,
	.tap_3_i( q3_buf4_d4 )		,
	.tap_4_i( q3_buf4_d3 )		,
	.tap_5_i( q3_buf4_d2 )		,
	.tap_6_i( q3_buf4_d1 )		,
	.tap_7_i( q3_buf4_i  )		,
	.val_o  ( vquarter_3_3_pel4_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_3_5 (
	.tap_0_i( q3_buf5_d7 )		,
	.tap_1_i( q3_buf5_d6 )		,
	.tap_2_i( q3_buf5_d5 )		,
	.tap_3_i( q3_buf5_d4 )		,
	.tap_4_i( q3_buf5_d3 )		,
	.tap_5_i( q3_buf5_d2 )		,
	.tap_6_i( q3_buf5_d1 )		,
	.tap_7_i( q3_buf5_i  )		,
	.val_o  ( vquarter_3_3_pel5_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_3_6 (
	.tap_0_i( q3_buf6_d7 )		,
	.tap_1_i( q3_buf6_d6 )		,
	.tap_2_i( q3_buf6_d5 )		,
	.tap_3_i( q3_buf6_d4 )		,
	.tap_4_i( q3_buf6_d3 )		,
	.tap_5_i( q3_buf6_d2 )		,
	.tap_6_i( q3_buf6_d1 )		,
	.tap_7_i( q3_buf6_i  )		,
	.val_o  ( vquarter_3_3_pel6_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_3_7 (
	.tap_0_i( q3_buf7_d7 )		,
	.tap_1_i( q3_buf7_d6 )		,
	.tap_2_i( q3_buf7_d5 )		,
	.tap_3_i( q3_buf7_d4 )		,
	.tap_4_i( q3_buf7_d3 )		,
	.tap_5_i( q3_buf7_d2 )		,
	.tap_6_i( q3_buf7_d1 )		,
	.tap_7_i( q3_buf7_i  )		,
	.val_o  ( vquarter_3_3_pel7_o)		
);

// from half
// h_buf0_d7   
// h_buf0_d6 
// h_buf0_d5 
// h_buf0_d4 
// h_buf0_d3 
// h_buf0_d2 
// h_buf0_d1 
// h_buf0_i   

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_2_0 (
	.tap_0_i( h_buf0_d7 )		,
	.tap_1_i( h_buf0_d6 )		,
	.tap_2_i( h_buf0_d5 )		,
	.tap_3_i( h_buf0_d4 )		,
	.tap_4_i( h_buf0_d3 )		,
	.tap_5_i( h_buf0_d2 )		,
	.tap_6_i( h_buf0_d1 )		,
	.tap_7_i( h_buf0_i  )		,
	.val_o  ( vquarter_3_2_pel0_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_2_1 (
	.tap_0_i( h_buf1_d7 )		,
	.tap_1_i( h_buf1_d6 )		,
	.tap_2_i( h_buf1_d5 )		,
	.tap_3_i( h_buf1_d4 )		,
	.tap_4_i( h_buf1_d3 )		,
	.tap_5_i( h_buf1_d2 )		,
	.tap_6_i( h_buf1_d1 )		,
	.tap_7_i( h_buf1_i  )		,
	.val_o  ( vquarter_3_2_pel1_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_2_2 (
	.tap_0_i( h_buf2_d7 )		,
	.tap_1_i( h_buf2_d6 )		,
	.tap_2_i( h_buf2_d5 )		,
	.tap_3_i( h_buf2_d4 )		,
	.tap_4_i( h_buf2_d3 )		,
	.tap_5_i( h_buf2_d2 )		,
	.tap_6_i( h_buf2_d1 )		,
	.tap_7_i( h_buf2_i  )		,
	.val_o  ( vquarter_3_2_pel2_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_2_3 (
	.tap_0_i( h_buf3_d7 )		,
	.tap_1_i( h_buf3_d6 )		,
	.tap_2_i( h_buf3_d5 )		,
	.tap_3_i( h_buf3_d4 )		,
	.tap_4_i( h_buf3_d3 )		,
	.tap_5_i( h_buf3_d2 )		,
	.tap_6_i( h_buf3_d1 )		,
	.tap_7_i( h_buf3_i  )		,
	.val_o  ( vquarter_3_2_pel3_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_2_4 (
	.tap_0_i( h_buf4_d7 )		,
	.tap_1_i( h_buf4_d6 )		,
	.tap_2_i( h_buf4_d5 )		,
	.tap_3_i( h_buf4_d4 )		,
	.tap_4_i( h_buf4_d3 )		,
	.tap_5_i( h_buf4_d2 )		,
	.tap_6_i( h_buf4_d1 )		,
	.tap_7_i( h_buf4_i  )		,
	.val_o  ( vquarter_3_2_pel4_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_2_5 (
	.tap_0_i( h_buf5_d7 )		,
	.tap_1_i( h_buf5_d6 )		,
	.tap_2_i( h_buf5_d5 )		,
	.tap_3_i( h_buf5_d4 )		,
	.tap_4_i( h_buf5_d3 )		,
	.tap_5_i( h_buf5_d2 )		,
	.tap_6_i( h_buf5_d1 )		,
	.tap_7_i( h_buf5_i  )		,
	.val_o  ( vquarter_3_2_pel5_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_2_6 (
	.tap_0_i( h_buf6_d7 )		,
	.tap_1_i( h_buf6_d6 )		,
	.tap_2_i( h_buf6_d5 )		,
	.tap_3_i( h_buf6_d4 )		,
	.tap_4_i( h_buf6_d3 )		,
	.tap_5_i( h_buf6_d2 )		,
	.tap_6_i( h_buf6_d1 )		,
	.tap_7_i( h_buf6_i  )		,
	.val_o  ( vquarter_3_2_pel6_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) vertical_3_2_7 (
	.tap_0_i( h_buf7_d7  )		,
	.tap_1_i( h_buf7_d6  )		,
	.tap_2_i( h_buf7_d5  )		,
	.tap_3_i( h_buf7_d4  )		,
	.tap_4_i( h_buf7_d3  )		,
	.tap_5_i( h_buf7_d2  )		,
	.tap_6_i( h_buf7_d1  )		,
	.tap_7_i( h_buf7_i   )		,
	.val_o  ( vquarter_3_2_pel7_o)		
);

// from ref
// ref_pel0_d7 
// ref_pel0_d6 
// ref_pel0_d5 
// ref_pel0_d4 
// ref_pel0_d3 
// ref_pel0_d2 
// ref_pel0_d1 
// ref_pel0_i   
fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_3_0_0 (
	.tap_0_i( ref_pel0_d7 )		,
	.tap_1_i( ref_pel0_d6 )		,
	.tap_2_i( ref_pel0_d5 )		,
	.tap_3_i( ref_pel0_d4 )		,
	.tap_4_i( ref_pel0_d3 )		,
	.tap_5_i( ref_pel0_d2 )		,
	.tap_6_i( ref_pel0_d1 )		,
	.tap_7_i( ref_pel0_i  )		,
	.val_o  ( vquarter_3_0_pel0_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_3_0_1 (
	.tap_0_i( ref_pel1_d7 )		,
	.tap_1_i( ref_pel1_d6 )		,
	.tap_2_i( ref_pel1_d5 )		,
	.tap_3_i( ref_pel1_d4 )		,
	.tap_4_i( ref_pel1_d3 )		,
	.tap_5_i( ref_pel1_d2 )		,
	.tap_6_i( ref_pel1_d1 )		,
	.tap_7_i( ref_pel1_i  )		,
	.val_o  ( vquarter_3_0_pel1_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_3_0_2 (
	.tap_0_i( ref_pel2_d7 )		,
	.tap_1_i( ref_pel2_d6 )		,
	.tap_2_i( ref_pel2_d5 )		,
	.tap_3_i( ref_pel2_d4 )		,
	.tap_4_i( ref_pel2_d3 )		,
	.tap_5_i( ref_pel2_d2 )		,
	.tap_6_i( ref_pel2_d1 )		,
	.tap_7_i( ref_pel2_i  )		,
	.val_o  ( vquarter_3_0_pel2_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_3_0_3 (
	.tap_0_i( ref_pel3_d7 )		,
	.tap_1_i( ref_pel3_d6 )		,
	.tap_2_i( ref_pel3_d5 )		,
	.tap_3_i( ref_pel3_d4 )		,
	.tap_4_i( ref_pel3_d3 )		,
	.tap_5_i( ref_pel3_d2 )		,
	.tap_6_i( ref_pel3_d1 )		,
	.tap_7_i( ref_pel3_i  )		,
	.val_o  ( vquarter_3_0_pel3_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_3_0_4 (
	.tap_0_i( ref_pel4_d7 )		,
	.tap_1_i( ref_pel4_d6 )		,
	.tap_2_i( ref_pel4_d5 )		,
	.tap_3_i( ref_pel4_d4 )		,
	.tap_4_i( ref_pel4_d3 )		,
	.tap_5_i( ref_pel4_d2 )		,
	.tap_6_i( ref_pel4_d1 )		,
	.tap_7_i( ref_pel4_i  )		,
	.val_o  ( vquarter_3_0_pel4_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_3_0_5 (
	.tap_0_i( ref_pel5_d7 )		,
	.tap_1_i( ref_pel5_d6 )		,
	.tap_2_i( ref_pel5_d5 )		,
	.tap_3_i( ref_pel5_d4 )		,
	.tap_4_i( ref_pel5_d3 )		,
	.tap_5_i( ref_pel5_d2 )		,
	.tap_6_i( ref_pel5_d1 )		,
	.tap_7_i( ref_pel5_i  )		,
	.val_o  ( vquarter_3_0_pel5_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_3_0_6 (
	.tap_0_i( ref_pel6_d7 )		,
	.tap_1_i( ref_pel6_d6 )		,
	.tap_2_i( ref_pel6_d5 )		,
	.tap_3_i( ref_pel6_d4 )		,
	.tap_4_i( ref_pel6_d3 )		,
	.tap_5_i( ref_pel6_d2 )		,
	.tap_6_i( ref_pel6_d1 )		,
	.tap_7_i( ref_pel6_i  )		,
	.val_o  ( vquarter_3_0_pel6_o)		
);

fme_interpolator #(
	.TYPE(2),
	.HOR(0),
	.LAST(1),
	.IN_EXPAND(0), 
	.OUT_EXPAND(0)
) vertical_3_0_7 (
	.tap_0_i( ref_pel7_d7 )		,
	.tap_1_i( ref_pel7_d6 )		,
	.tap_2_i( ref_pel7_d5 )		,
	.tap_3_i( ref_pel7_d4 )		,
	.tap_4_i( ref_pel7_d3 )		,
	.tap_5_i( ref_pel7_d2 )		,
	.tap_6_i( ref_pel7_d1 )		,
	.tap_7_i( ref_pel7_i  )		,
	.val_o  ( vquarter_3_0_pel7_o)		
);

// vertical half interpolator

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_1_0 (
	.tap_0_i( q1_buf0_i  )		,
	.tap_1_i( q1_buf0_d1 )		,
	.tap_2_i( q1_buf0_d2 )		,
	.tap_3_i( q1_buf0_d3 )		,
	.tap_4_i( q1_buf0_d4 )		,
	.tap_5_i( q1_buf0_d5 )		,
	.tap_6_i( q1_buf0_d6 )		,
	.tap_7_i( q1_buf0_d7 )		,
	.val_o  ( vhalf_2_1_pel0_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_1_1 (
	.tap_0_i( q1_buf1_i  )		,
	.tap_1_i( q1_buf1_d1 )		,
	.tap_2_i( q1_buf1_d2 )		,
	.tap_3_i( q1_buf1_d3 )		,
	.tap_4_i( q1_buf1_d4 )		,
	.tap_5_i( q1_buf1_d5 )		,
	.tap_6_i( q1_buf1_d6 )		,
	.tap_7_i( q1_buf1_d7 )		,
	.val_o  ( vhalf_2_1_pel1_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_1_2 (
	.tap_0_i( q1_buf2_i  )		,
	.tap_1_i( q1_buf2_d1 )		,
	.tap_2_i( q1_buf2_d2 )		,
	.tap_3_i( q1_buf2_d3 )		,
	.tap_4_i( q1_buf2_d4 )		,
	.tap_5_i( q1_buf2_d5 )		,
	.tap_6_i( q1_buf2_d6 )		,
	.tap_7_i( q1_buf2_d7 )		,
	.val_o  ( vhalf_2_1_pel2_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_1_3 (
	.tap_0_i( q1_buf3_i  )		,
	.tap_1_i( q1_buf3_d1 )		,
	.tap_2_i( q1_buf3_d2 )		,
	.tap_3_i( q1_buf3_d3 )		,
	.tap_4_i( q1_buf3_d4 )		,
	.tap_5_i( q1_buf3_d5 )		,
	.tap_6_i( q1_buf3_d6 )		,
	.tap_7_i( q1_buf3_d7 )		,
	.val_o  ( vhalf_2_1_pel3_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_1_4 (
	.tap_0_i( q1_buf4_i  )		,
	.tap_1_i( q1_buf4_d1 )		,
	.tap_2_i( q1_buf4_d2 )		,
	.tap_3_i( q1_buf4_d3 )		,
	.tap_4_i( q1_buf4_d4 )		,
	.tap_5_i( q1_buf4_d5 )		,
	.tap_6_i( q1_buf4_d6 )		,
	.tap_7_i( q1_buf4_d7 )		,
	.val_o  ( vhalf_2_1_pel4_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_1_5 (
	.tap_0_i( q1_buf5_i  )		,
	.tap_1_i( q1_buf5_d1 )		,
	.tap_2_i( q1_buf5_d2 )		,
	.tap_3_i( q1_buf5_d3 )		,
	.tap_4_i( q1_buf5_d4 )		,
	.tap_5_i( q1_buf5_d5 )		,
	.tap_6_i( q1_buf5_d6 )		,
	.tap_7_i( q1_buf5_d7 )		,
	.val_o  ( vhalf_2_1_pel5_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_1_6 (
	.tap_0_i( q1_buf6_i  )		,
	.tap_1_i( q1_buf6_d1 )		,
	.tap_2_i( q1_buf6_d2 )		,
	.tap_3_i( q1_buf6_d3 )		,
	.tap_4_i( q1_buf6_d4 )		,
	.tap_5_i( q1_buf6_d5 )		,
	.tap_6_i( q1_buf6_d6 )		,
	.tap_7_i( q1_buf6_d7 )		,
	.val_o  ( vhalf_2_1_pel6_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_1_7 (
	.tap_0_i( q1_buf7_i  )		,
	.tap_1_i( q1_buf7_d1 )		,
	.tap_2_i( q1_buf7_d2 )		,
	.tap_3_i( q1_buf7_d3 )		,
	.tap_4_i( q1_buf7_d4 )		,
	.tap_5_i( q1_buf7_d5 )		,
	.tap_6_i( q1_buf7_d6 )		,
	.tap_7_i( q1_buf7_d7 )		,
	.val_o  ( vhalf_2_1_pel7_o)		
);

//from q3

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_3_0 (
	.tap_0_i( q3_buf0_i  )		,
	.tap_1_i( q3_buf0_d1 )		,
	.tap_2_i( q3_buf0_d2 )		,
	.tap_3_i( q3_buf0_d3 )		,
	.tap_4_i( q3_buf0_d4 )		,
	.tap_5_i( q3_buf0_d5 )		,
	.tap_6_i( q3_buf0_d6 )		,
	.tap_7_i( q3_buf0_d7 )		,
	.val_o  ( vhalf_2_3_pel0_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_3_1 (
	.tap_0_i( q3_buf1_i  )		,
	.tap_1_i( q3_buf1_d1 )		,
	.tap_2_i( q3_buf1_d2 )		,
	.tap_3_i( q3_buf1_d3 )		,
	.tap_4_i( q3_buf1_d4 )		,
	.tap_5_i( q3_buf1_d5 )		,
	.tap_6_i( q3_buf1_d6 )		,
	.tap_7_i( q3_buf1_d7 )		,
	.val_o  ( vhalf_2_3_pel1_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_3_2 (
	.tap_0_i( q3_buf2_i  )		,
	.tap_1_i( q3_buf2_d1 )		,
	.tap_2_i( q3_buf2_d2 )		,
	.tap_3_i( q3_buf2_d3 )		,
	.tap_4_i( q3_buf2_d4 )		,
	.tap_5_i( q3_buf2_d5 )		,
	.tap_6_i( q3_buf2_d6 )		,
	.tap_7_i( q3_buf2_d7 )		,
	.val_o  ( vhalf_2_3_pel2_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_3_3 (
	.tap_0_i( q3_buf3_i  )		,
	.tap_1_i( q3_buf3_d1 )		,
	.tap_2_i( q3_buf3_d2 )		,
	.tap_3_i( q3_buf3_d3 )		,
	.tap_4_i( q3_buf3_d4 )		,
	.tap_5_i( q3_buf3_d5 )		,
	.tap_6_i( q3_buf3_d6 )		,
	.tap_7_i( q3_buf3_d7 )		,
	.val_o  ( vhalf_2_3_pel3_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_3_4 (
	.tap_0_i( q3_buf4_i  )		,
	.tap_1_i( q3_buf4_d1 )		,
	.tap_2_i( q3_buf4_d2 )		,
	.tap_3_i( q3_buf4_d3 )		,
	.tap_4_i( q3_buf4_d4 )		,
	.tap_5_i( q3_buf4_d5 )		,
	.tap_6_i( q3_buf4_d6 )		,
	.tap_7_i( q3_buf4_d7 )		,
	.val_o  ( vhalf_2_3_pel4_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_3_5 (
	.tap_0_i( q3_buf5_i  )		,
	.tap_1_i( q3_buf5_d1 )		,
	.tap_2_i( q3_buf5_d2 )		,
	.tap_3_i( q3_buf5_d3 )		,
	.tap_4_i( q3_buf5_d4 )		,
	.tap_5_i( q3_buf5_d5 )		,
	.tap_6_i( q3_buf5_d6 )		,
	.tap_7_i( q3_buf5_d7 )		,
	.val_o  ( vhalf_2_3_pel5_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_3_6 (
	.tap_0_i( q3_buf6_i  )		,
	.tap_1_i( q3_buf6_d1 )		,
	.tap_2_i( q3_buf6_d2 )		,
	.tap_3_i( q3_buf6_d3 )		,
	.tap_4_i( q3_buf6_d4 )		,
	.tap_5_i( q3_buf6_d5 )		,
	.tap_6_i( q3_buf6_d6 )		,
	.tap_7_i( q3_buf6_d7 )		,
	.val_o  ( vhalf_2_3_pel6_o)		
);

fme_interpolator #(
	.TYPE(0),
	.HOR(0),
	.LAST(0),
	.IN_EXPAND(1), 
	.OUT_EXPAND(0)
) half_2_3_7 (
	.tap_0_i( q3_buf7_i  )		,
	.tap_1_i( q3_buf7_d1 )		,
	.tap_2_i( q3_buf7_d2 )		,
	.tap_3_i( q3_buf7_d3 )		,
	.tap_4_i( q3_buf7_d4 )		,
	.tap_5_i( q3_buf7_d5 )		,
	.tap_6_i( q3_buf7_d6 )		,
	.tap_7_i( q3_buf7_d7 )		,
	.val_o  ( vhalf_2_3_pel7_o)		
);

// clip
clip2 clip_0_1_0 (
	.val_in(q1_buf0_i),
	.val_out(vpel_0_1_pel0_o)
);

clip2 clip_0_1_1 (
	.val_in(q1_buf1_i),
	.val_out(vpel_0_1_pel1_o)
);

clip2 clip_0_1_2 (
	.val_in(q1_buf2_i),
	.val_out(vpel_0_1_pel2_o)
);

clip2 clip_0_1_3 (
	.val_in(q1_buf3_i),
	.val_out(vpel_0_1_pel3_o)
);

clip2 clip_0_1_4 (
	.val_in(q1_buf4_i),
	.val_out(vpel_0_1_pel4_o)
);

clip2 clip_0_1_5 (
	.val_in(q1_buf5_i),
	.val_out(vpel_0_1_pel5_o)
);

clip2 clip_0_1_6 (
	.val_in(q1_buf6_i),
	.val_out(vpel_0_1_pel6_o) 
);

clip2 clip_0_1_7 (
	.val_in(q1_buf7_i),
	.val_out(vpel_0_1_pel7_o)
);

//
clip2 clip_0_3_0 (
	.val_in(q3_buf0_i),
	.val_out(vpel_0_3_pel0_o)
);

clip2 clip_0_3_1 (
	.val_in(q3_buf1_i),
	.val_out(vpel_0_3_pel1_o)
);

clip2 clip_0_3_2 (
	.val_in(q3_buf2_i),
	.val_out(vpel_0_3_pel2_o)
);

clip2 clip_0_3_3 (
	.val_in(q3_buf3_i),
	.val_out(vpel_0_3_pel3_o)
);

clip2 clip_0_3_4 (
	.val_in(q3_buf4_i),
	.val_out(vpel_0_3_pel4_o)
);

clip2 clip_0_3_5 (
	.val_in(q3_buf5_i),
	.val_out(vpel_0_3_pel5_o)
);

clip2 clip_0_3_6 (
	.val_in(q3_buf6_i),
	.val_out(vpel_0_3_pel6_o)
);

clip2 clip_0_3_7 (
	.val_in(q3_buf7_i),
	.val_out(vpel_0_3_pel7_o)
);

/*

assign cnthorLargerThan3 = (cnt_hor >='d3 && cnt_hor <='d10);
assign cnthorLargerThan4 = (cnt_hor >='d4 && cnt_hor <='d11);

assign cntrefLargerThan7 = (cnt_ref >='d7 && cnt_ref <='d14);
assign cntrefLargerThan8 = (cnt_ref [3]);

assign cnthorLargerThan7 = (cnt_hor >='d7 && cnt_hor <='d14);
assign cnthorLargerThan8 = (cnt_hor [3]);

assign vquarter_1_valid_o 	= 	(frac_y_i == 2'b00 || frac_y_i == 2'b01) ? (cnthorLargerThan8) : (cnthorLargerThan7);
assign vquarter_3_valid_o 	= 	(frac_y_i == 2'b00                     ) ? (cnthorLargerThan8) : (cnthorLargerThan7);
assign vquarter_2_valid_o       = 	(frac_y_i == 2'b00 || frac_y_i == 2'b01) ? (cnthorLargerThan8) : (cnthorLargerThan7);
assign vquarter_0_valid_o       = 	(frac_y_i == 2'b00 || frac_y_i == 2'b01) ? (cntrefLargerThan8) : (cntrefLargerThan7);

assign vhalf_valid_o            =       (frac_y_i == 2'b00 || frac_y_i == 2'b01) ? (cnthorLargerThan4) : (cnthorLargerThan3); 
assign vpel_valid_o             =       (frac_y_i == 2'b00 || frac_y_i == 2'b01) ? (cnthorLargerThan4) : (cnthorLargerThan3);   
*/

endmodule

