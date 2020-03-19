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
//  Filename      : fme_interpolator_8x8.v
//  Author        : Yufeng Bai
//  Email 	  : byfchina@gmail.com	
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fme_interpolator_8x8 (
	clk	         	,
	rstn	         	,

	blk_start_i		,
	half_ip_flag_i		,

	mv_x_i	        	,
	mv_y_i	        	,
	frac_x_i	        ,
	frac_y_i	        ,
	blk_idx_i               ,

	mv_x_o	        	,
	mv_y_o	        	,
	blk_idx_o               ,
	half_ip_flag_o          ,

	ip_ready_o		,
        end_ip_o                ,
	mc_end_ip_o             ,
	refpel_valid_i		,

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

	satd_start_o            ,             

	candi0_valid_o		,
	candi1_valid_o		,
	candi2_valid_o		,
	candi3_valid_o		,
	candi4_valid_o		,
	candi5_valid_o		,
	candi6_valid_o		,
	candi7_valid_o		,
	candi8_valid_o		,

	candi0_pixles_o		,
	candi1_pixles_o		,
	candi2_pixles_o		,
	candi3_pixles_o		,
	candi4_pixles_o		,
	candi5_pixles_o		,
	candi6_pixles_o		,
	candi7_pixles_o		,
	candi8_pixles_o		
);

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input 	 [1-1:0] 	 	 clk 	         ; // clk signal 
input 	 [1-1:0] 	 	 rstn 	         ; // asynchronous reset 
input 	 [1-1:0] 	 	 blk_start_i 	 ; // 8x8 block interpolation start signal 
input 	 [1-1:0] 	 	 half_ip_flag_i  ; // specify whtether half/quarter interpolation 
input  signed [`FMV_WIDTH-1:0] 	 mv_x_i 	 ; // mv_x input //  
input  signed [`FMV_WIDTH-1:0] 	 mv_y_i 	 ; // mv_x input //  
input    [2-1:0] 	         frac_x_i 	 ; // frac_y input , used for quarter interpolation 
input    [2-1:0] 	         frac_y_i 	 ; // frac_y input , used for quarter interpolation 
input    [6-1:0]                 blk_idx_i	 ; // index of the 8x8 block which is processed 
output signed [`FMV_WIDTH-1:0] 	 mv_x_o 	 ; // mv_x output for satd module // x: ==0 
output signed [`FMV_WIDTH-1:0] 	 mv_y_o 	 ; // mv_y output for satd module // 0x: ==0 
output   [6-1:0]                 blk_idx_o	 ; // index of the 8x8 block which is processed : pass to satd gen. 
output 	 [1-1:0] 	 	 half_ip_flag_o  ; // half_ip_flag: pass to satd gen 
output 	 [1-1:0] 	 	 ip_ready_o 	 ; // first interpolaton data ready : load data for satd 
output 	 [1-1:0] 	 	 end_ip_o 	 ; // interpolation done
output 	 [1-1:0] 	 	 mc_end_ip_o 	 ; // all block interpolation done
input 	 [1-1:0] 	 	 refpel_valid_i  ; // referrenced pixel valid 
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
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel12_i 	 ; // ref_pel12o
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel13_i 	 ; // ref_pel13o
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel14_i 	 ; // ref_pel14 
input 	 [`PIXEL_WIDTH-1:0] 	 ref_pel15_i 	 ; // ref_pel15 
output   [1-1:0]                 satd_start_o    ; 
output 	 [1-1:0] 		 candi0_valid_o  ; // candidate 0 row pixels valid 
output 	 [1-1:0] 	         candi1_valid_o  ; // candidate 1 row pixels valid 
output 	 [1-1:0] 		 candi2_valid_o  ; // candidate 2 row pixels valid 
output 	 [1-1:0] 	 	 candi3_valid_o  ; // candidate 3 row pixels valid 
output 	 [1-1:0] 	 	 candi4_valid_o  ; // candidate 4 row pixels valid 
output 	 [1-1:0] 	 	 candi5_valid_o  ; // candidate 5 row pixels valid 
output 	 [1-1:0] 	 	 candi6_valid_o  ; // candidate 6 row pixels valid 
output 	 [1-1:0] 	 	 candi7_valid_o  ; // candidate 7 row pixels valid 
output 	 [1-1:0] 	 	 candi8_valid_o  ; // candidate 8 row pixels valid 
output 	 [`PIXEL_WIDTH*8-1:0] 	 candi0_pixles_o ; // candidate 0 row pixels 
output 	 [`PIXEL_WIDTH*8-1:0] 	 candi1_pixles_o ; // candidate 1 row pixels 
output 	 [`PIXEL_WIDTH*8-1:0] 	 candi2_pixles_o ; // candidate 2 row pixels 
output 	 [`PIXEL_WIDTH*8-1:0] 	 candi3_pixles_o ; // candidate 3 row pixels 
output 	 [`PIXEL_WIDTH*8-1:0] 	 candi4_pixles_o ; // candidate 4 row pixels 
output 	 [`PIXEL_WIDTH*8-1:0] 	 candi5_pixles_o ; // candidate 5 row pixels 
output 	 [`PIXEL_WIDTH*8-1:0] 	 candi6_pixles_o ; // candidate 6 row pixels 
output 	 [`PIXEL_WIDTH*8-1:0] 	 candi7_pixles_o ; // candidate 7 row pixels 
output 	 [`PIXEL_WIDTH*8-1:0] 	 candi8_pixles_o ; // candidate 8 row pixels 

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

reg      [3:               0]    cnt_ref; // ref pixel cnt
reg      [3:               0]    cnt_hor; // hor buff cnt, one cycle delay of cnt_ref
reg      [3:               0]    cnt_ver; // ver buff cnt, one cycle delay of cnt_ver

reg signed [`FMV_WIDTH-1:  0]    mv_x_r0; // buffer0 to store mv information
reg signed [`FMV_WIDTH-1:  0]    mv_y_r0;
reg      [2-1           :  0]    frac_x_r0;
reg      [2-1           :  0]    frac_y_r0;
reg      [6-1:             0]    blk_idx_r0;
reg                              half_ip_flag_r0;
reg signed [`FMV_WIDTH-1:  0]    mv_x_r1; // buffer1 to store mv information
reg signed [`FMV_WIDTH-1:  0]    mv_y_r1;
reg      [2-1           :  0]    frac_x_r1;
reg      [2-1           :  0]    frac_y_r1;
reg      [6-1:             0]    blk_idx_r1;
reg                              half_ip_flag_r1;

reg			         mv_in_flag; // ping-pong buffer
reg			         mv_out_flag; 

reg                              hor_start;
reg                              horbuf_valid;
reg                              ver_start;

reg                              refpel_valid_d;
reg                              vhalf_pel_valid_d;
reg				 diagonal_pel_valid_d;

wire     [1:               0]    frac_x;
wire     [1:               0]    frac_y;
wire     [1-1:             0]    half_ip_flag;
wire     [`FMV_WIDTH-1:    0]    mv_x;
wire     [`FMV_WIDTH-1:    0]    mv_y;
wire     [6-1:             0]    blk_idx ; // index of the 8x8 block which is processed : pass to satd gen. 

wire                             fracyEqualZero, fracxEqualZero;
wire     [8*`PIXEL_WIDTH-1:0]    h_00,h_01,h_02,h_10,h_11,h_12;
wire     [8*`PIXEL_WIDTH-1:0]    q_13,q_11,q_31,q_33,q_12,q_32,q_10,q_30;
wire     [8*`PIXEL_WIDTH-1:0]    q_21,q_23,q_01,q_03,q_22,q_20,q_02;

reg 	 [1-1:0] 		 candi0_valid  ; // candidate 0 row pixels valid 
reg 	 [1-1:0] 	         candi1_valid  ; // candidate 1 row pixels valid 
reg 	 [1-1:0] 		 candi2_valid  ; // candidate 2 row pixels valid 
reg 	 [1-1:0] 	 	 candi3_valid  ; // candidate 3 row pixels valid 
reg 	 [1-1:0] 	 	 candi4_valid  ; // candidate 4 row pixels valid 
reg 	 [1-1:0] 	 	 candi5_valid  ; // candidate 5 row pixels valid 
reg 	 [1-1:0] 	 	 candi6_valid  ; // candidate 6 row pixels valid 
reg 	 [1-1:0] 	 	 candi7_valid  ; // candidate 7 row pixels valid 
reg 	 [1-1:0] 	 	 candi8_valid  ; // candidate 8 row pixels valid 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi0_pixles ; // candidate 0 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi1_pixles ; // candidate 1 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi2_pixles ; // candidate 2 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi3_pixles ; // candidate 3 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi4_pixles ; // candidate 4 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi5_pixles ; // candidate 5 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi6_pixles ; // candidate 6 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi7_pixles ; // candidate 7 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi8_pixles ; // candidate 8 row pixels 

reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi0_pixles_o ; // candidate 0 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi1_pixles_o ; // candidate 1 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi2_pixles_o ; // candidate 2 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi3_pixles_o ; // candidate 3 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi4_pixles_o ; // candidate 4 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi5_pixles_o ; // candidate 5 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi6_pixles_o ; // candidate 6 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi7_pixles_o ; // candidate 7 row pixels 
reg 	 [`PIXEL_WIDTH*8-1:0] 	 candi8_pixles_o ; // candidate 8 row pixels 

reg      [2*`PIXEL_WIDTH-1  :0]  half_buf_0, q1_buf_0, q3_buf_0;
reg      [2*`PIXEL_WIDTH-1  :0]  half_buf_1, q1_buf_1, q3_buf_1;
reg      [2*`PIXEL_WIDTH-1  :0]  half_buf_2, q1_buf_2, q3_buf_2;
reg      [2*`PIXEL_WIDTH-1  :0]  half_buf_3, q1_buf_3, q3_buf_3;
reg      [2*`PIXEL_WIDTH-1  :0]  half_buf_4, q1_buf_4, q3_buf_4;
reg      [2*`PIXEL_WIDTH-1  :0]  half_buf_5, q1_buf_5, q3_buf_5;
reg      [2*`PIXEL_WIDTH-1  :0]  half_buf_6, q1_buf_6, q3_buf_6;
reg      [2*`PIXEL_WIDTH-1  :0]  half_buf_7, q1_buf_7, q3_buf_7;
reg      [2*`PIXEL_WIDTH-1  :0]  half_buf_8, q1_buf_8, q3_buf_8;

wire     [2*`PIXEL_WIDTH-1  :0]  half_buf0, q1_buf0, q3_buf0;
wire     [2*`PIXEL_WIDTH-1  :0]  half_buf1, q1_buf1, q3_buf1;
wire     [2*`PIXEL_WIDTH-1  :0]  half_buf2, q1_buf2, q3_buf2;
wire     [2*`PIXEL_WIDTH-1  :0]  half_buf3, q1_buf3, q3_buf3;
wire     [2*`PIXEL_WIDTH-1  :0]  half_buf4, q1_buf4, q3_buf4;
wire     [2*`PIXEL_WIDTH-1  :0]  half_buf5, q1_buf5, q3_buf5;
wire     [2*`PIXEL_WIDTH-1  :0]  half_buf6, q1_buf6, q3_buf6;
wire     [2*`PIXEL_WIDTH-1  :0]  half_buf7, q1_buf7, q3_buf7;
wire     [2*`PIXEL_WIDTH-1  :0]  half_buf8, q1_buf8, q3_buf8;

wire 	 [1-1:0] 	 	 vquarter_1_valid   	 ; // vertical quarter 1 predicted pixels wire valid 
wire 	 [1-1:0] 	         vquarter_3_valid   	 ; // vertical quarter 3 predicted pixels wire valid 
wire 	 [1-1:0] 	         vquarter_1_2_valid   	 ; // vertical quarter 2 predicted pixels wire valid 
wire 	 [1-1:0] 	         vquarter_3_2_valid   	 ; // vertical quarter 2 predicted pixels wire valid 
wire 	 [1-1:0] 	         vquarter_1_0_valid   	 ; // vertical quarter 0 predicted pixels wire valid 
wire 	 [1-1:0] 	         vquarter_3_0_valid   	 ; // vertical quarter 0 predicted pixels wire valid 
wire 	 [1-1:0] 	         vhalf_valid     	 ; // vertical half predicted pixels wire valid 
wire 	 [1-1:0] 	         vpel_valid     	 ; // vertical ref predicted pixels wire valid 

wire     [1-1:0]			 vhalf_pel_valid     ; //undefined note 

wire 	 [1-1:0] 	 diagonal_pel_valid 	 ; // diagonal predicted pixels output valid 
wire 	 [1-1:0] 	 hhalf_pel_valid 	 ; // diagonal predicted pixels output valid 
wire 	 [`PIXEL_WIDTH-1:0] 	 d_pel0 	 ; // diagonal pixel 0 
wire 	 [`PIXEL_WIDTH-1:0] 	 d_pel1 	 ; // diagonal pixel 1 
wire 	 [`PIXEL_WIDTH-1:0] 	 d_pel2 	 ; // diagonal pixel 2 
wire 	 [`PIXEL_WIDTH-1:0] 	 d_pel3 	 ; // diagonal pixel 3 
wire 	 [`PIXEL_WIDTH-1:0] 	 d_pel4 	 ; // diagonal pixel 4 
wire 	 [`PIXEL_WIDTH-1:0] 	 d_pel5 	 ; // diagonal pixel 5 
wire 	 [`PIXEL_WIDTH-1:0] 	 d_pel6 	 ; // diagonal pixel 6 
wire 	 [`PIXEL_WIDTH-1:0] 	 d_pel7 	 ; // diagonal pixel 7 
wire 	 [`PIXEL_WIDTH-1:0] 	 d_pel8 	 ; // diagonal pixel 8

wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel0  ; 
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel1  ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel2  ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel3  ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel4  ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel5  ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel6  ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_pel7  ;

wire 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel0 	 ; // cliped half pixel 0 
wire 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel1 	 ; // cliped half pixel 1 
wire 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel2 	 ; // cliped half pixel 2 
wire 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel3 	 ; // cliped half pixel 3 
wire 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel4 	 ; // cliped half pixel 4 
wire 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel5 	 ; // cliped half pixel 5 
wire 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel6 	 ; // cliped half pixel 6
wire 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel7 	 ; // cliped half pixel 7 
wire 	 [`PIXEL_WIDTH-1:0] 	 hhalf_pel8 	 ; // cliped half pixel 8

wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel0   	 ; // from q1 vertical quarter 1 pixel 0 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel1   	 ; // from q1 vertical quarter 1 pixel 1 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel2   	 ; // from q1 vertical quarter 1 pixel 2 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel3   	 ; // from q1 vertical quarter 1 pixel 3 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel4   	 ; // from q1 vertical quarter 1 pixel 4 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel5   	 ; // from q1 vertical quarter 1 pixel 5 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel6   	 ; // from q1 vertical quarter 1 pixel 6 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_1_pel7   	 ; // from q1 vertical quarter 1 pixel 7 

wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel0   	 ; // from q3 vertical quarter 1 pixel 0 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel1   	 ; // from q3 vertical quarter 1 pixel 1 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel2   	 ; // from q3 vertical quarter 1 pixel 2 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel3   	 ; // from q3 vertical quarter 1 pixel 3 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel4   	 ; // from q3 vertical quarter 1 pixel 4 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel5   	 ; // from q3 vertical quarter 1 pixel 5 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel6   	 ; // from q3 vertical quarter 1 pixel 6 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_3_pel7   	 ; // from q3 vertical quarter 1 pixel 7 

wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel0   	 ; // from half vertical quarter 1 pixel 0 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel1   	 ; // from half vertical quarter 1 pixel 1 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel2   	 ; // from half vertical quarter 1 pixel 2 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel3   	 ; // from half vertical quarter 1 pixel 3 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel4   	 ; // from half vertical quarter 1 pixel 4 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel5   	 ; // from half vertical quarter 1 pixel 5 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel6   	 ; // from half vertical quarter 1 pixel 6 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_2_pel7   	 ; // from half vertical quarter 1 pixel 7 

wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel0   	 ; // from ref vertical quarter 1 pixel 0 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel1   	 ; // from ref vertical quarter 1 pixel 1 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel2   	 ; // from ref vertical quarter 1 pixel 2 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel3   	 ; // from ref vertical quarter 1 pixel 3 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel4   	 ; // from ref vertical quarter 1 pixel 4 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel5   	 ; // from ref vertical quarter 1 pixel 5 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel6   	 ; // from ref vertical quarter 1 pixel 6 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_1_0_pel7   	 ; // from ref vertical quarter 1 pixel 7 

wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel0   	 ; // from q1 vertical quarter 3 pixel 0 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel1   	 ; // from q1 vertical quarter 3 pixel 1 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel2   	 ; // from q1 vertical quarter 3 pixel 2 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel3   	 ; // from q1 vertical quarter 3 pixel 3 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel4   	 ; // from q1 vertical quarter 3 pixel 4 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel5   	 ; // from q1 vertical quarter 3 pixel 5 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel6   	 ; // from q1 vertical quarter 3 pixel 6 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_1_pel7   	 ; // from q1 vertical quarter 3 pixel 7 

wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel0   	 ; // from q3 vertical quarter 3 pixel 0 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel1   	 ; // from q3 vertical quarter 3 pixel 1 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel2   	 ; // from q3 vertical quarter 3 pixel 2 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel3   	 ; // from q3 vertical quarter 3 pixel 3 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel4   	 ; // from q3 vertical quarter 3 pixel 4 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel5   	 ; // from q3 vertical quarter 3 pixel 5 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel6   	 ; // from q3 vertical quarter 3 pixel 6 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_3_pel7   	 ; // from q3 vertical quarter 3 pixel 7 

wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel0   	 ; // from ref vertical quarter 3 pixel 0 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel1   	 ; // from ref vertical quarter 3 pixel 1 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel2   	 ; // from ref vertical quarter 3 pixel 2 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel3   	 ; // from ref vertical quarter 3 pixel 3 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel4   	 ; // from ref vertical quarter 3 pixel 4 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel5   	 ; // from ref vertical quarter 3 pixel 5 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel6   	 ; // from ref vertical quarter 3 pixel 6 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_0_pel7   	 ; // from ref vertical quarter 3 pixel 7 

wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel0   	 ; // from half vertical quarter 3 pixel 0 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel1   	 ; // from half vertical quarter 3 pixel 1 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel2   	 ; // from half vertical quarter 3 pixel 2 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel3   	 ; // from half vertical quarter 3 pixel 3 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel4   	 ; // from half vertical quarter 3 pixel 4 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel5   	 ; // from half vertical quarter 3 pixel 5 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel6   	 ; // from half vertical quarter 3 pixel 6 
wire 	 [`PIXEL_WIDTH-1:0] 	 vquarter_3_2_pel7   	 ; // from half vertical quarter 3 pixel 7 

wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel0            ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel1   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel2   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel3   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel4   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel5   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel6   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_1_pel7   	 ;
              
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel0            ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel1   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel2   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel3   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel4   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel5   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel6   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vhalf_2_3_pel7   	 ;

wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel0           ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel1   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel2   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel3   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel4   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel5   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel6   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_1_pel7   	 ;

wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel0           ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel1   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel2   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel3   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel4   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel5   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel6   	 ;
wire 	 [`PIXEL_WIDTH-1:0] 	 vpel_0_3_pel7   	 ;


//valid signals

wire cnthorLargerThan3; 
wire cnthorLargerThan4; 

wire cntrefLargerThan7; 
wire cntrefLargerThan8; 

wire cnthorLargerThan7; 
wire cnthorLargerThan8;

wire cntverLargerThan7; 
wire cntverLargerThan8;


// ********************************************
//
//    Sequential Logic
//
// ********************************************

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	mv_x_r0 <= 'd0;
	mv_x_r1 <= 'd0;
	mv_y_r0 <= 'd0;
	mv_y_r1 <= 'd0;
	frac_x_r0 <= 'd0;
	frac_x_r1 <= 'd0;
	frac_y_r0 <= 'd0;
	frac_y_r1 <= 'd0;
	half_ip_flag_r0 <= 1'b0;
	half_ip_flag_r1 <= 1'b0;
	blk_idx_r0 <= 'd0;
	blk_idx_r1 <= 'd0;
	mv_in_flag <= 1'b0;
    end
    else if (blk_start_i) begin
	mv_in_flag <= ~mv_in_flag;
	if (~mv_in_flag) begin
	    mv_x_r0 <= mv_x_i;
	    mv_y_r0 <= mv_y_i;
	    frac_x_r0 <= frac_x_i;
	    frac_y_r0 <= frac_y_i;
	    blk_idx_r0 <= blk_idx_i;
	    half_ip_flag_r0 <= half_ip_flag_i;
	end
	else begin
	    mv_x_r1 <= mv_x_i;
	    mv_y_r1 <= mv_y_i;
	    frac_x_r1 <= frac_x_i;
	    frac_y_r1 <= frac_y_i;
	    blk_idx_r1 <= blk_idx_i;
	    half_ip_flag_r1 <= half_ip_flag_i;
	end
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	mv_out_flag <= 'd0;
    end
    else if (end_ip_o) begin
	mv_out_flag <= ~mv_out_flag;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	cnt_ref <= 'd0;
    end
    else if (blk_start_i || cnt_ref == 'd15) begin
	cnt_ref <= 'd0;
    end
    else if (refpel_valid_i) begin
	cnt_ref <= cnt_ref + 'd1;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	cnt_hor <= 'd0;
    end
    else if (hor_start || cnt_hor == 'd15) begin
	cnt_hor <= 'd0;
    end
    else if (horbuf_valid) begin
	cnt_hor <= cnt_hor + 'd1;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	cnt_ver <= 'd0;
    end
    else if (ver_start) begin
	cnt_ver <= 'd0;
    end
    else begin
	cnt_ver <= cnt_hor;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	hor_start <= 'd0;
	horbuf_valid <= 'd0;
	ver_start <= 'd0;
    end
    else begin
	hor_start <= blk_start_i;
	horbuf_valid <= refpel_valid_i;
	ver_start <= hor_start;
    end
end

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	refpel_valid_d <= 'd0;
	vhalf_pel_valid_d <= 'd0;
	diagonal_pel_valid_d <= 'd0;
    end
    else begin
	refpel_valid_d <= refpel_valid_i;
	vhalf_pel_valid_d <= vhalf_pel_valid;
	diagonal_pel_valid_d <= diagonal_pel_valid;
    end
end

always @ (posedge clk or negedge rstn) begin
  if (~rstn) begin
    half_buf_0 <= 'd0; q1_buf_0 <= 'd0; q3_buf_0 <= 'd0;
    half_buf_1 <= 'd0; q1_buf_1 <= 'd0; q3_buf_1 <= 'd0;
    half_buf_2 <= 'd0; q1_buf_2 <= 'd0; q3_buf_2 <= 'd0;
    half_buf_3 <= 'd0; q1_buf_3 <= 'd0; q3_buf_3 <= 'd0;
    half_buf_4 <= 'd0; q1_buf_4 <= 'd0; q3_buf_4 <= 'd0;
    half_buf_5 <= 'd0; q1_buf_5 <= 'd0; q3_buf_5 <= 'd0;
    half_buf_6 <= 'd0; q1_buf_6 <= 'd0; q3_buf_6 <= 'd0;
    half_buf_7 <= 'd0; q1_buf_7 <= 'd0; q3_buf_7 <= 'd0;
    half_buf_8 <= 'd0; q1_buf_8 <= 'd0; q3_buf_8 <= 'd0;
  end
  else begin
    half_buf_0 <= half_buf0;
    q1_buf_0   <= q1_buf0;
    q3_buf_0   <= q3_buf0;

    half_buf_1 <= half_buf1;
    q1_buf_1   <= q1_buf1;
    q3_buf_1   <= q3_buf1;

    half_buf_2 <= half_buf2;
    q1_buf_2   <= q1_buf2;
    q3_buf_2   <= q3_buf2;

    half_buf_3 <= half_buf3;
    q1_buf_3   <= q1_buf3;
    q3_buf_3   <= q3_buf3;

    half_buf_4 <= half_buf4;
    q1_buf_4   <= q1_buf4;
    q3_buf_4   <= q3_buf4;

    half_buf_5 <= half_buf5;
    q1_buf_5   <= q1_buf5;
    q3_buf_5   <= q3_buf5;

    half_buf_6 <= half_buf6;
    q1_buf_6   <= q1_buf6;
    q3_buf_6   <= q3_buf6;

    half_buf_7 <= half_buf7;
    q1_buf_7   <= q1_buf7;
    q3_buf_7   <= q3_buf7;

    half_buf_8 <= half_buf8;
    q1_buf_8   <= q1_buf8;
    q3_buf_8   <= q3_buf8;

  end
end

// ********************************************
//
//    Sub Module 
//
// ********************************************

fme_interpolator_8pel  horizontal_interpolator(
	.ref_pel0_i	(ref_pel0_i )	,
	.ref_pel1_i	(ref_pel1_i )	,
	.ref_pel2_i	(ref_pel2_i )	,
	.ref_pel3_i	(ref_pel3_i )	,
	.ref_pel4_i	(ref_pel4_i )	,
	.ref_pel5_i	(ref_pel5_i )	,
	.ref_pel6_i	(ref_pel6_i )	,
	.ref_pel7_i	(ref_pel7_i )	,
	.ref_pel8_i	(ref_pel8_i )	,
	.ref_pel9_i	(ref_pel9_i )	,
	.ref_pel10_i	(ref_pel10_i)	,
	.ref_pel11_i	(ref_pel11_i)	,
	.ref_pel12_i	(ref_pel12_i)	,
	.ref_pel13_i	(ref_pel13_i)	,
	.ref_pel14_i	(ref_pel14_i)	,
	.ref_pel15_i	(ref_pel15_i)	,

	.hhalf_pel0_o	(hhalf_pel0),
	.hhalf_pel1_o	(hhalf_pel1),
	.hhalf_pel2_o	(hhalf_pel2),
	.hhalf_pel3_o	(hhalf_pel3),
	.hhalf_pel4_o	(hhalf_pel4),
	.hhalf_pel5_o	(hhalf_pel5),
	.hhalf_pel6_o	(hhalf_pel6),
	.hhalf_pel7_o	(hhalf_pel7),
	.hhalf_pel8_o	(hhalf_pel8),

	.half_buf_0     (half_buf0  )	,
	.q1_buf_0       (q1_buf0    ) 	,
	.q3_buf_0	(q3_buf0    )	,
	.half_buf_1     (half_buf1  )	,
	.q1_buf_1       (q1_buf1    ) 	,
	.q3_buf_1	(q3_buf1    )	,
	.half_buf_2     (half_buf2  )	,
	.q1_buf_2       (q1_buf2    ) 	,
	.q3_buf_2	(q3_buf2    )	,
	.half_buf_3     (half_buf3  )	,
	.q1_buf_3       (q1_buf3    ) 	,
	.q3_buf_3	(q3_buf3    )	,
	.half_buf_4     (half_buf4  )	,
	.q1_buf_4       (q1_buf4    ) 	,
	.q3_buf_4	(q3_buf4    )	,
	.half_buf_5     (half_buf5  )	,
	.q1_buf_5       (q1_buf5    ) 	,
	.q3_buf_5	(q3_buf5    )	,
	.half_buf_6     (half_buf6  )	,
	.q1_buf_6       (q1_buf6    ) 	,
	.q3_buf_6	(q3_buf6    )	,
	.half_buf_7     (half_buf7  )	,
	.q1_buf_7       (q1_buf7    ) 	,
	.q3_buf_7	(q3_buf7    )	,
	.half_buf_8     (half_buf8  )	,
	.q1_buf_8       (q1_buf8    ) 	,
	.q3_buf_8	(q3_buf8    )	

);

fme_ip_half_ver  half_vertical_interpolator(
	.clk		        (clk		        ), 
	.rstn		        (rstn		        ),
                                                        
	.blk_start_i		(blk_start_i		),
	.refpel_valid_i		(refpel_valid_i		),
	.ref_pel0_i		(ref_pel4_i		),
	.ref_pel1_i		(ref_pel5_i		),
	.ref_pel2_i		(ref_pel6_i		),
	.ref_pel3_i		(ref_pel7_i		),
	.ref_pel4_i		(ref_pel8_i		),
	.ref_pel5_i		(ref_pel9_i		),
	.ref_pel6_i		(ref_pel10_i		),
	.ref_pel7_i		(ref_pel11_i		),
                                                        
	.vhalf_pel0_o		(vhalf_pel0		),
	.vhalf_pel1_o		(vhalf_pel1		),
	.vhalf_pel2_o		(vhalf_pel2		),
	.vhalf_pel3_o		(vhalf_pel3		),
	.vhalf_pel4_o		(vhalf_pel4		),
	.vhalf_pel5_o		(vhalf_pel5		),
	.vhalf_pel6_o		(vhalf_pel6		),
	.vhalf_pel7_o		(vhalf_pel7		),
                                                    
	.hor_start_i            (hor_start              ),
	.horbuf_valid_i         (horbuf_valid          ),
	.h_buf0_i		(half_buf_0		),
	.h_buf1_i		(half_buf_1		),
	.h_buf2_i		(half_buf_2		),
	.h_buf3_i		(half_buf_3		),
	.h_buf4_i		(half_buf_4		),
	.h_buf5_i		(half_buf_5		),
	.h_buf6_i		(half_buf_6		),
	.h_buf7_i		(half_buf_7		),
	.h_buf8_i		(half_buf_8		),
                                                        
	.d_pel0_o		(d_pel0  		),
	.d_pel1_o		(d_pel1 		),
	.d_pel2_o		(d_pel2 		),
	.d_pel3_o		(d_pel3 		),
	.d_pel4_o		(d_pel4 		),
	.d_pel5_o		(d_pel5 		),
	.d_pel6_o		(d_pel6 		),
	.d_pel7_o		(d_pel7 		),
	.d_pel8_o		(d_pel8 		)	
);

fme_ip_quarter_ver quarter_verical_interpolator (
	.clk		        (clk		        ),
	.rstn		        (rstn		        ),
                                                        
	.blk_start_i		(blk_start_i		),
	.refpel_valid_i		(refpel_valid_i		),
                                                        
	.hor_start_i		(hor_start		),
	.horbuf_valid_i		(horbuf_valid		),
                                                        
	.frac_x_i               (frac_x               ),
	.frac_y_i               (frac_y               ),
                                                        
	.q1_buf0_i		((frac_x == 2'b01 || frac_x == 2'b00) ? q1_buf_1 : q1_buf_0	), // q1_buf_1
	.q1_buf1_i		((frac_x == 2'b01 || frac_x == 2'b00) ? q1_buf_2 : q1_buf_1	), // q1_buf_2
	.q1_buf2_i		((frac_x == 2'b01 || frac_x == 2'b00) ? q1_buf_3 : q1_buf_2	), // q1_buf_3
	.q1_buf3_i		((frac_x == 2'b01 || frac_x == 2'b00) ? q1_buf_4 : q1_buf_3	), // q1_buf_4
	.q1_buf4_i		((frac_x == 2'b01 || frac_x == 2'b00) ? q1_buf_5 : q1_buf_4	), // q1_buf_5
	.q1_buf5_i		((frac_x == 2'b01 || frac_x == 2'b00) ? q1_buf_6 : q1_buf_5	), // q1_buf_6
	.q1_buf6_i		((frac_x == 2'b01 || frac_x == 2'b00) ? q1_buf_7 : q1_buf_6	), // q1_buf_7
	.q1_buf7_i		((frac_x == 2'b01 || frac_x == 2'b00) ? q1_buf_8 : q1_buf_7	), // q1_buf_8
                                                     
	.q3_buf0_i		((frac_x == 2'b01 ) ? q3_buf_1 :	q3_buf_0), // q3_buf_1
	.q3_buf1_i		((frac_x == 2'b01 ) ? q3_buf_2 :	q3_buf_1), // q3_buf_2
	.q3_buf2_i		((frac_x == 2'b01 ) ? q3_buf_3 :	q3_buf_2), // q3_buf_3
	.q3_buf3_i		((frac_x == 2'b01 ) ? q3_buf_4 :	q3_buf_3), // q3_buf_4
	.q3_buf4_i		((frac_x == 2'b01 ) ? q3_buf_5 :	q3_buf_4), // q3_buf_5
	.q3_buf5_i		((frac_x == 2'b01 ) ? q3_buf_6 :	q3_buf_5), // q3_buf_6
	.q3_buf6_i		((frac_x == 2'b01 ) ? q3_buf_7 :	q3_buf_6), // q3_buf_7
	.q3_buf7_i		((frac_x == 2'b01 ) ? q3_buf_8 :	q3_buf_7), // q3_buf_8
                                                        
	.h_buf0_i		((frac_x == 2'b01 /*|| frac_x == 2'b00*/) ? half_buf_1 : half_buf_0), // half_buf_1
	.h_buf1_i		((frac_x == 2'b01 /*|| frac_x == 2'b00*/) ? half_buf_2 : half_buf_1), // half_buf_2
	.h_buf2_i		((frac_x == 2'b01 /*|| frac_x == 2'b00*/) ? half_buf_3 : half_buf_2), // half_buf_3
	.h_buf3_i		((frac_x == 2'b01 /*|| frac_x == 2'b00*/) ? half_buf_4 : half_buf_3), // half_buf_4
	.h_buf4_i		((frac_x == 2'b01 /*|| frac_x == 2'b00*/) ? half_buf_5 : half_buf_4), // half_buf_5
	.h_buf5_i		((frac_x == 2'b01 /*|| frac_x == 2'b00*/) ? half_buf_6 : half_buf_5), // half_buf_6
	.h_buf6_i		((frac_x == 2'b01 /*|| frac_x == 2'b00*/) ? half_buf_7 : half_buf_6), // half_buf_7
	.h_buf7_i		((frac_x == 2'b01 /*|| frac_x == 2'b00*/) ? half_buf_8 : half_buf_7), // half_buf_8
                                                        
	.ref_pel0_i             (ref_pel4_i             ),
	.ref_pel1_i             (ref_pel5_i             ),
	.ref_pel2_i             (ref_pel6_i             ),
	.ref_pel3_i             (ref_pel7_i             ),
	.ref_pel4_i             (ref_pel8_i             ),
	.ref_pel5_i             (ref_pel9_i             ),
	.ref_pel6_i             (ref_pel10_i            ),
	.ref_pel7_i             (ref_pel11_i            ),
                                                        
	//.vquarter_1_valid_o	(vquarter_1_valid	), //1,1 | 3,1
	//.vquarter_3_valid_o	(vquarter_3_valid	), //1,3 | 3,3
	//.vquarter_2_valid_o     (vquarter_2_valid       ), //1,2 | 3,2
	//.vquarter_0_valid_o     (vquarter_0_valid       ), //1,0 | 3,0
	//.vhalf_valid_o          (vhalf_valid            ), //2,1 | 2,3
	//.vpel_valid_o           (vpel_valid             ), //0,1 | 0,3
	                        
	.vquarter_1_1_pel0_o	(vquarter_1_1_pel0	),
	.vquarter_1_1_pel1_o	(vquarter_1_1_pel1	),
	.vquarter_1_1_pel2_o	(vquarter_1_1_pel2	),
	.vquarter_1_1_pel3_o	(vquarter_1_1_pel3	),
	.vquarter_1_1_pel4_o	(vquarter_1_1_pel4	),
	.vquarter_1_1_pel5_o	(vquarter_1_1_pel5	),
	.vquarter_1_1_pel6_o	(vquarter_1_1_pel6	),
	.vquarter_1_1_pel7_o	(vquarter_1_1_pel7	),
                                                        
	.vquarter_1_3_pel0_o	(vquarter_1_3_pel0	),
	.vquarter_1_3_pel1_o	(vquarter_1_3_pel1	),
	.vquarter_1_3_pel2_o	(vquarter_1_3_pel2	),
	.vquarter_1_3_pel3_o	(vquarter_1_3_pel3	),
	.vquarter_1_3_pel4_o	(vquarter_1_3_pel4	),
	.vquarter_1_3_pel5_o	(vquarter_1_3_pel5	),
	.vquarter_1_3_pel6_o	(vquarter_1_3_pel6	),
	.vquarter_1_3_pel7_o	(vquarter_1_3_pel7	),
                                                        
	.vquarter_1_2_pel0_o	(vquarter_1_2_pel0	),
	.vquarter_1_2_pel1_o	(vquarter_1_2_pel1	),
	.vquarter_1_2_pel2_o	(vquarter_1_2_pel2	),
	.vquarter_1_2_pel3_o	(vquarter_1_2_pel3	),
	.vquarter_1_2_pel4_o	(vquarter_1_2_pel4	),
	.vquarter_1_2_pel5_o	(vquarter_1_2_pel5	),
	.vquarter_1_2_pel6_o	(vquarter_1_2_pel6	),
	.vquarter_1_2_pel7_o	(vquarter_1_2_pel7	),
                                                        
	.vquarter_1_0_pel0_o	(vquarter_1_0_pel0	),
	.vquarter_1_0_pel1_o	(vquarter_1_0_pel1	),
	.vquarter_1_0_pel2_o	(vquarter_1_0_pel2	),
	.vquarter_1_0_pel3_o	(vquarter_1_0_pel3	),
	.vquarter_1_0_pel4_o	(vquarter_1_0_pel4	),
	.vquarter_1_0_pel5_o	(vquarter_1_0_pel5	),
	.vquarter_1_0_pel6_o	(vquarter_1_0_pel6	),
	.vquarter_1_0_pel7_o	(vquarter_1_0_pel7	),
                                                        
	.vquarter_3_1_pel0_o	(vquarter_3_1_pel0	),
	.vquarter_3_1_pel1_o	(vquarter_3_1_pel1	),
	.vquarter_3_1_pel2_o	(vquarter_3_1_pel2	),
	.vquarter_3_1_pel3_o	(vquarter_3_1_pel3	),
	.vquarter_3_1_pel4_o	(vquarter_3_1_pel4	),
	.vquarter_3_1_pel5_o	(vquarter_3_1_pel5	),
	.vquarter_3_1_pel6_o	(vquarter_3_1_pel6	),
	.vquarter_3_1_pel7_o 	(vquarter_3_1_pel7 	),		
                                                        
	.vquarter_3_3_pel0_o	(vquarter_3_3_pel0	),
	.vquarter_3_3_pel1_o	(vquarter_3_3_pel1	),
	.vquarter_3_3_pel2_o	(vquarter_3_3_pel2	),
	.vquarter_3_3_pel3_o	(vquarter_3_3_pel3	),
	.vquarter_3_3_pel4_o	(vquarter_3_3_pel4	),
	.vquarter_3_3_pel5_o	(vquarter_3_3_pel5	),
	.vquarter_3_3_pel6_o	(vquarter_3_3_pel6	),
	.vquarter_3_3_pel7_o	(vquarter_3_3_pel7	),
                                                        
	.vquarter_3_2_pel0_o	(vquarter_3_2_pel0	),
	.vquarter_3_2_pel1_o	(vquarter_3_2_pel1	),
	.vquarter_3_2_pel2_o	(vquarter_3_2_pel2	),
	.vquarter_3_2_pel3_o	(vquarter_3_2_pel3	),
	.vquarter_3_2_pel4_o	(vquarter_3_2_pel4	),
	.vquarter_3_2_pel5_o	(vquarter_3_2_pel5	),
	.vquarter_3_2_pel6_o	(vquarter_3_2_pel6	),
	.vquarter_3_2_pel7_o	(vquarter_3_2_pel7	),
                                                       
	.vquarter_3_0_pel0_o	(vquarter_3_0_pel0	),
	.vquarter_3_0_pel1_o	(vquarter_3_0_pel1	),
	.vquarter_3_0_pel2_o	(vquarter_3_0_pel2	),
	.vquarter_3_0_pel3_o	(vquarter_3_0_pel3	),
	.vquarter_3_0_pel4_o	(vquarter_3_0_pel4	),
	.vquarter_3_0_pel5_o	(vquarter_3_0_pel5	),
	.vquarter_3_0_pel6_o	(vquarter_3_0_pel6	),
	.vquarter_3_0_pel7_o	(vquarter_3_0_pel7	),

	.vpel_0_1_pel0_o 	(vpel_0_1_pel0   	),
	.vpel_0_1_pel1_o 	(vpel_0_1_pel1   	),
	.vpel_0_1_pel2_o 	(vpel_0_1_pel2   	),
	.vpel_0_1_pel3_o 	(vpel_0_1_pel3   	),
	.vpel_0_1_pel4_o 	(vpel_0_1_pel4   	),
	.vpel_0_1_pel5_o 	(vpel_0_1_pel5   	),
	.vpel_0_1_pel6_o 	(vpel_0_1_pel6   	),
	.vpel_0_1_pel7_o 	(vpel_0_1_pel7   	),

	.vpel_0_3_pel0_o 	(vpel_0_3_pel0   	),
	.vpel_0_3_pel1_o 	(vpel_0_3_pel1   	),
	.vpel_0_3_pel2_o 	(vpel_0_3_pel2   	),
	.vpel_0_3_pel3_o 	(vpel_0_3_pel3   	),
	.vpel_0_3_pel4_o 	(vpel_0_3_pel4   	),
	.vpel_0_3_pel5_o 	(vpel_0_3_pel5   	),
	.vpel_0_3_pel6_o 	(vpel_0_3_pel6   	),
	.vpel_0_3_pel7_o 	(vpel_0_3_pel7   	),

	.vhalf_2_1_pel0_o 	(vhalf_2_1_pel0   	),
	.vhalf_2_1_pel1_o 	(vhalf_2_1_pel1   	),
	.vhalf_2_1_pel2_o 	(vhalf_2_1_pel2   	),
	.vhalf_2_1_pel3_o 	(vhalf_2_1_pel3   	),
	.vhalf_2_1_pel4_o 	(vhalf_2_1_pel4   	),
	.vhalf_2_1_pel5_o 	(vhalf_2_1_pel5   	),
	.vhalf_2_1_pel6_o 	(vhalf_2_1_pel6   	),
	.vhalf_2_1_pel7_o 	(vhalf_2_1_pel7   	),
                                                        
	.vhalf_2_3_pel0_o 	(vhalf_2_3_pel0   	),
	.vhalf_2_3_pel1_o 	(vhalf_2_3_pel1   	),
	.vhalf_2_3_pel2_o 	(vhalf_2_3_pel2   	),
	.vhalf_2_3_pel3_o 	(vhalf_2_3_pel3   	),
	.vhalf_2_3_pel4_o 	(vhalf_2_3_pel4   	),
	.vhalf_2_3_pel5_o 	(vhalf_2_3_pel5   	),
	.vhalf_2_3_pel6_o 	(vhalf_2_3_pel6   	),
	.vhalf_2_3_pel7_o 	(vhalf_2_3_pel7   	)
);

// ********************************************
//
//    Combinational Logic
//
// ********************************************

// output signals 
assign satd_start_o             =       (cnt_ref == 'd2);
//assign ip_ready_o               =       (cnt_ref >= 'd4 || cnt_hor == 'hf); // use it as cur lcu read enable signal
assign ip_ready_o               =       (cnt_ref == 'd4 || cnt_ref == 'd3); // use it as cur lcu read enable signal
assign end_ip_o                 =       (cnt_ver == 'd15);

assign mv_x_o                   =       (mv_out_flag) ? mv_x_r1: mv_x_r0;
assign mv_y_o                   =       (mv_out_flag) ? mv_y_r1: mv_y_r0;

assign frac_x                   =       (mv_out_flag) ? frac_x_r1: frac_x_r0;
assign frac_y                   =       (mv_out_flag) ? frac_y_r1: frac_y_r0;

assign blk_idx_o                =       (mv_in_flag)  ? blk_idx_r0: blk_idx_r1;
assign blk_idx                  =       (mv_out_flag) ? blk_idx_r1: blk_idx_r0;
assign half_ip_flag             =       (mv_out_flag) ? half_ip_flag_r1 : half_ip_flag_r0;
assign half_ip_flag_o           =       half_ip_flag;
assign mc_end_ip_o              =       (&blk_idx) & end_ip_o;

//valid signal
//
assign diagonal_pel_valid = (cnt_hor[3]);
assign vhalf_pel_valid    = (cnt_ref[3]);
assign hhalf_pel_valid    = (cnt_hor >=4 && cnt_hor <12);

assign cnthorLargerThan3 = (cnt_hor >='d4  && cnt_hor <='d11);
assign cnthorLargerThan4 = (cnt_hor > 'd4  && cnt_hor <='d12);

assign cntrefLargerThan7 = (cnt_ref >='d7 && cnt_ref <='d14);
assign cntrefLargerThan8 = (cnt_ref [3]);

assign cnthorLargerThan7 = (cnt_hor >='d7 && cnt_hor <='d14);
assign cnthorLargerThan8 = (cnt_hor [3]);

assign cntverLargerThan7 = (cnt_ver >='d7 && cnt_ver <='d14);
assign cntverLargerThan8 = (cnt_ver [3]);

assign vquarter_1_valid 	= 	(frac_y == 2'b00 || frac_y == 2'b01) ? (cntverLargerThan8) : (cntverLargerThan7);
assign vquarter_3_valid 	= 	(                   frac_y == 2'b01) ? (cntverLargerThan8) : (cntverLargerThan7);

assign vquarter_1_2_valid         = 	(frac_y == 2'b00 || frac_y == 2'b01) ? (cntverLargerThan8) : (cntverLargerThan7);
assign vquarter_3_2_valid         = 	(                   frac_y == 2'b01) ? (cntverLargerThan8) : (cntverLargerThan7);
assign vquarter_1_0_valid         = 	(frac_y == 2'b00 || frac_y == 2'b01) ? (cnthorLargerThan8) : (cnthorLargerThan7);
assign vquarter_3_0_valid         = 	(                   frac_y == 2'b01) ? (cnthorLargerThan8) : (cnthorLargerThan7);

assign vhalf_valid              =       (                   frac_y == 2'b01) ? (cntverLargerThan8) : (cntverLargerThan7); 
assign vpel_valid               =       (frac_y == 2'b00 || frac_y == 2'b01) ? (cnthorLargerThan4) : (cnthorLargerThan3);

// candidate selection


// combine pixel to one row
//
assign h_00 = {d_pel0, d_pel1, d_pel2, d_pel3, d_pel4, d_pel5, d_pel6, d_pel7};
assign h_01 = {vhalf_pel0, vhalf_pel1, vhalf_pel2, vhalf_pel3, vhalf_pel4, vhalf_pel5, vhalf_pel6, vhalf_pel7};
assign h_02 = {d_pel1, d_pel2, d_pel3, d_pel4, d_pel5, d_pel6, d_pel7, d_pel8};
assign h_10 = {hhalf_pel0, hhalf_pel1, hhalf_pel2, hhalf_pel3, hhalf_pel4, hhalf_pel5, hhalf_pel6, hhalf_pel7};
assign h_11 = {ref_pel4_i, ref_pel5_i, ref_pel6_i, ref_pel7_i, ref_pel8_i, ref_pel9_i, ref_pel10_i, ref_pel11_i};
assign h_12 = {hhalf_pel1, hhalf_pel2, hhalf_pel3, hhalf_pel4, hhalf_pel5, hhalf_pel6, hhalf_pel7, hhalf_pel8};

assign q_13 = {vquarter_1_3_pel0,vquarter_1_3_pel1,vquarter_1_3_pel2,vquarter_1_3_pel3,vquarter_1_3_pel4,vquarter_1_3_pel5,vquarter_1_3_pel6,vquarter_1_3_pel7};
assign q_11 = {vquarter_1_1_pel0,vquarter_1_1_pel1,vquarter_1_1_pel2,vquarter_1_1_pel3,vquarter_1_1_pel4,vquarter_1_1_pel5,vquarter_1_1_pel6,vquarter_1_1_pel7};
assign q_31 = {vquarter_3_1_pel0,vquarter_3_1_pel1,vquarter_3_1_pel2,vquarter_3_1_pel3,vquarter_3_1_pel4,vquarter_3_1_pel5,vquarter_3_1_pel6,vquarter_3_1_pel7};
assign q_33 = {vquarter_3_3_pel0,vquarter_3_3_pel1,vquarter_3_3_pel2,vquarter_3_3_pel3,vquarter_3_3_pel4,vquarter_3_3_pel5,vquarter_3_3_pel6,vquarter_3_3_pel7};

assign q_12 = {vquarter_1_2_pel0,vquarter_1_2_pel1,vquarter_1_2_pel2,vquarter_1_2_pel3,vquarter_1_2_pel4,vquarter_1_2_pel5,vquarter_1_2_pel6,vquarter_1_2_pel7};
assign q_32 = {vquarter_3_2_pel0,vquarter_3_2_pel1,vquarter_3_2_pel2,vquarter_3_2_pel3,vquarter_3_2_pel4,vquarter_3_2_pel5,vquarter_3_2_pel6,vquarter_3_2_pel7};
assign q_10 = {vquarter_1_0_pel0,vquarter_1_0_pel1,vquarter_1_0_pel2,vquarter_1_0_pel3,vquarter_1_0_pel4,vquarter_1_0_pel5,vquarter_1_0_pel6,vquarter_1_0_pel7};
assign q_30 = {vquarter_3_0_pel0,vquarter_3_0_pel1,vquarter_3_0_pel2,vquarter_3_0_pel3,vquarter_3_0_pel4,vquarter_3_0_pel5,vquarter_3_0_pel6,vquarter_3_0_pel7};

assign q_21 = {vhalf_2_1_pel0,vhalf_2_1_pel1,vhalf_2_1_pel2,vhalf_2_1_pel3,vhalf_2_1_pel4,vhalf_2_1_pel5,vhalf_2_1_pel6,vhalf_2_1_pel7};
assign q_23 = {vhalf_2_3_pel0,vhalf_2_3_pel1,vhalf_2_3_pel2,vhalf_2_3_pel3,vhalf_2_3_pel4,vhalf_2_3_pel5,vhalf_2_3_pel6,vhalf_2_3_pel7};
assign q_01 = {vpel_0_1_pel0,vpel_0_1_pel1,vpel_0_1_pel2,vpel_0_1_pel3,vpel_0_1_pel4,vpel_0_1_pel5,vpel_0_1_pel6,vpel_0_1_pel7};
assign q_03 = {vpel_0_3_pel0,vpel_0_3_pel1,vpel_0_3_pel2,vpel_0_3_pel3,vpel_0_3_pel4,vpel_0_3_pel5,vpel_0_3_pel6,vpel_0_3_pel7};

assign q_22 = (frac_x == 2'b01) ? h_02 : h_00;
assign q_02 = (frac_x == 2'b01) ? h_12 : h_10;


// choose candidates accorign to mv
//
assign fracyEqualZero = (frac_y == 2'b00);
assign fracxEqualZero = (frac_x == 2'b00);

// search candidate 0
always @(*) begin
    if(half_ip_flag) begin
	candi0_pixles = h_00;
	candi0_valid =  diagonal_pel_valid;
    end
    else begin
	case({fracyEqualZero, fracxEqualZero})
	    2'b00: begin candi0_pixles = q_11; candi0_valid = vquarter_1_valid; end
	    2'b01: begin candi0_pixles = q_13; candi0_valid = vquarter_1_valid; end
	    2'b10: begin candi0_pixles = q_31; candi0_valid = vquarter_3_valid; end
	    2'b11: begin candi0_pixles = q_33; candi0_valid = vquarter_3_valid; end
	endcase
    end
end

// search candidate 1
always @(*) begin
    if(half_ip_flag) begin
	candi1_pixles = h_01;
	candi1_valid =  vhalf_pel_valid;
    end
    else begin
	case({fracyEqualZero, fracxEqualZero})
	    2'b00: begin candi1_pixles = q_12; candi1_valid = vquarter_1_2_valid; end
	    2'b01: begin candi1_pixles = q_10; candi1_valid = vquarter_1_0_valid; end
	    2'b10: begin candi1_pixles = q_32; candi1_valid = vquarter_3_2_valid; end
	    2'b11: begin candi1_pixles = q_30; candi1_valid = vquarter_3_0_valid; end
	endcase
    end
end

// search candidate 2
always @(*) begin
    if(half_ip_flag) begin
	candi2_pixles = h_02;
	candi2_valid = diagonal_pel_valid;
    end
    else begin
	case({fracyEqualZero, fracxEqualZero})
	    2'b00: begin candi2_pixles = q_13; candi2_valid = vquarter_1_valid; end
	    2'b01: begin candi2_pixles = q_11; candi2_valid = vquarter_1_valid; end
	    2'b10: begin candi2_pixles = q_33; candi2_valid = vquarter_3_valid; end
	    2'b11: begin candi2_pixles = q_31; candi2_valid = vquarter_3_valid; end
	endcase
    end
end
  
// search candidate 3
always @(*) begin
    if(half_ip_flag) begin
	candi3_pixles = h_10;
	candi3_valid =  hhalf_pel_valid;
    end
    else begin
	case({fracyEqualZero, fracxEqualZero})
	    2'b00: begin candi3_pixles = q_21; candi3_valid = vhalf_valid; end
	    2'b01: begin candi3_pixles = q_23; candi3_valid = vhalf_valid; end
	    2'b10: begin candi3_pixles = q_01; candi3_valid = vpel_valid; end
	    2'b11: begin candi3_pixles = q_03; candi3_valid = vpel_valid; end
	endcase
    end
end

// search candidate 4
always @(*) begin
    if(half_ip_flag) begin
	candi4_pixles = h_11;
	candi4_valid =  (cnt_ref > 4 && cnt_ref <=12) ;
    end
    else begin
	case({fracyEqualZero, fracxEqualZero})
	    2'b00: begin candi4_pixles = q_22; candi4_valid = (frac_y == 2'b01) ? diagonal_pel_valid_d : diagonal_pel_valid ; end
	    2'b01: begin candi4_pixles = h_01; candi4_valid = (frac_y == 2'b01) ? vhalf_pel_valid_d    : vhalf_pel_valid    ; end
	    2'b10: begin candi4_pixles = q_02; candi4_valid = hhalf_pel_valid                                               ; end
	    2'b11: begin candi4_pixles = h_11; candi4_valid = (cnt_ref > 4 && cnt_ref <=12); end
	endcase
    end
end

// search candidate 5
always @(*) begin
    if(half_ip_flag) begin
	candi5_pixles = h_12;
	candi5_valid =  hhalf_pel_valid ;
    end
    else begin
	case({fracyEqualZero, fracxEqualZero})
	    2'b00: begin candi5_pixles = q_23; candi5_valid = vhalf_valid ; end
	    2'b01: begin candi5_pixles = q_21; candi5_valid = vhalf_valid ; end
	    2'b10: begin candi5_pixles = q_03; candi5_valid = vpel_valid  ; end
	    2'b11: begin candi5_pixles = q_01; candi5_valid = vpel_valid  ; end
	endcase
    end
end

// search candidate 6
always @(*) begin
    if(half_ip_flag) begin
	candi6_pixles = h_00;
	candi6_valid =  diagonal_pel_valid_d ;
    end
    else begin
	case({fracyEqualZero, fracxEqualZero})
	    2'b00: begin candi6_pixles = q_31; candi6_valid = vquarter_3_valid ; end
	    2'b01: begin candi6_pixles = q_33; candi6_valid = vquarter_3_valid ; end
	    2'b10: begin candi6_pixles = q_11; candi6_valid = vquarter_1_valid ; end
	    2'b11: begin candi6_pixles = q_13; candi6_valid = vquarter_1_valid ; end
	endcase
    end
end

// search candidate 7
always @(*) begin
    if(half_ip_flag) begin
	candi7_pixles = h_01;
	candi7_valid =  vhalf_pel_valid_d ;
    end
    else begin
	case({fracyEqualZero, fracxEqualZero})
	    2'b00: begin candi7_pixles = q_32; candi7_valid = vquarter_3_2_valid ; end
	    2'b01: begin candi7_pixles = q_30; candi7_valid = vquarter_3_0_valid ; end
	    2'b10: begin candi7_pixles = q_12; candi7_valid = vquarter_1_2_valid ; end
	    2'b11: begin candi7_pixles = q_10; candi7_valid = vquarter_1_0_valid ; end
	endcase
    end
end

// search candidate 8
always @(*) begin
    if(half_ip_flag) begin
	candi8_pixles = h_02;
	candi8_valid =  diagonal_pel_valid_d ;
    end
    else begin
	case({fracyEqualZero, fracxEqualZero})
	    2'b00: begin candi8_pixles = q_33; candi8_valid = vquarter_3_valid ; end
	    2'b01: begin candi8_pixles = q_31; candi8_valid = vquarter_3_valid ; end
	    2'b10: begin candi8_pixles = q_13; candi8_valid = vquarter_1_valid ; end
	    2'b11: begin candi8_pixles = q_11; candi8_valid = vquarter_1_valid ; end
	endcase
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
        candi0_pixles_o <= 'd0;
        candi1_pixles_o <= 'd0;
        candi2_pixles_o <= 'd0;
        candi3_pixles_o <= 'd0;
        candi4_pixles_o <= 'd0;
        candi5_pixles_o <= 'd0;
        candi6_pixles_o <= 'd0;
        candi7_pixles_o <= 'd0;
        candi8_pixles_o <= 'd0;
    end
    else begin
        candi0_pixles_o <= candi0_pixles;
        candi1_pixles_o <= candi1_pixles;
        candi2_pixles_o <= candi2_pixles;
        candi3_pixles_o <= candi3_pixles;
        candi4_pixles_o <= candi4_pixles;
        candi5_pixles_o <= candi5_pixles;
        candi6_pixles_o <= candi6_pixles;
        candi7_pixles_o <= candi7_pixles;
        candi8_pixles_o <= candi8_pixles;
    end
end


assign candi0_valid_o = candi0_valid;
assign candi1_valid_o = candi1_valid;
assign candi2_valid_o = candi2_valid;
assign candi3_valid_o = candi3_valid;
assign candi4_valid_o = candi4_valid;
assign candi5_valid_o = candi5_valid;
assign candi6_valid_o = candi6_valid;
assign candi7_valid_o = candi7_valid;
assign candi8_valid_o = candi8_valid;

endmodule

