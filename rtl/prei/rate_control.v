//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2016, VIPcore Group, Fudan University
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
//  Filename      : rate_control.v
//  Author        : Yanheng Lu
//  Created       : 20180330
//  Description   : LCU level rate control logic
//
//-------------------------------------------------------------------
`include "enc_defines.v"

module rate_control(
        clk                  ,
        rstn                 ,
        // SYS_IF
        rc_start_i           ,
        rc_done_o            ,
        rc_ctu_x_i			 ,
        rc_ctu_y_i           ,

		actual_bitnum_i	     , // actual bit number form cabac
		modebest64_i	     , // from pre_i

        reg_k                , // register k
        reg_bitnum_i         , // register target bit number
		reg_ROI_height       , // Y+height <= Y CTU total
		reg_ROI_width        , // X+width <= X CTU total
		reg_ROI_x            , // ROI horizontal coordinate
		reg_ROI_y            , // ROI vertical coordinate
		reg_ROI_enable       , // ROI enable
		reg_L1_frame_byte	 , // level one
		reg_L2_frame_byte	 , // level two
		reg_lcu_rc_en        ,
		reg_initial_qp       , //frame QP
		reg_max_qp           ,
		reg_min_qp           ,
		reg_delta_qp         , // ROI qp

        // rate control qp output
        rc_qp_o	    ,
        mod64_sum_o	
);
    // global if
    input                                   clk             ;
    input                                   rstn            ;
    // sys if 
    input                                   rc_start_i      ;
    output                                  rc_done_o       ;
    // cfg if
    input  [`PIC_X_WIDTH       -1 :0]       rc_ctu_x_i     ;
    input  [`PIC_Y_WIDTH       -1 :0]       rc_ctu_y_i     ;
   
    input		[15:0]	actual_bitnum_i	;
    input		[27:0]	modebest64_i	;
    
    input		[15:0]	reg_k			;
    input	    [31:0]	reg_bitnum_i	;

	input		[5:0]	reg_ROI_height	;
	input		[6:0]	reg_ROI_width	;
	input		[6:0]	reg_ROI_x		;
	input		[6:0]	reg_ROI_y		;
	input				reg_ROI_enable	;
	input		[9:0]	reg_L1_frame_byte;
	input		[9:0]	reg_L2_frame_byte;
	input				reg_lcu_rc_en	;
	input		[5:0]	reg_initial_qp	;
	input		[5:0]	reg_max_qp		;
	input		[5:0]	reg_min_qp		;	
	input		[5:0]	reg_delta_qp	;
    // rc qp if
    output		[5:0]	rc_qp_o         ;
    output		[31:0]	mod64_sum_o		;
	
	reg					rc_done_o		;
	reg			[5:0]	rc_qp_o			;

//================ control ========================

	reg			[3:0]	cnt;
	reg					rc_run;
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			rc_run <= 1'b0;
		else if(rc_start_i)
			rc_run <= 1'b1;
		else if(cnt == 'd10)
			rc_run <= 1'b0;

	always@(posedge clk or negedge rstn)
		if(!rstn)
			cnt <= 4'b0;
		else if(rc_run)
			cnt <= cnt + 1'b1;
		else
			cnt <= 4'b0;

	always@(posedge clk or negedge rstn)
		if(!rstn)
			rc_done_o <= 1'b0;
		else if(cnt == 'd10)
			rc_done_o <= 1'b1;
		else
			rc_done_o <= 1'b0;

//================ accumulate =======================

	reg		[27:0]	frame_bit;
	reg		[38:0]	modebest_1; //60*34=2040<2048, 27+11=38
	reg		[38:0]	modebest_2;
	reg		[38:0]	modebest_3;
	reg		[38:0]	modebest_4;
	reg		[38:0]	modebest_5;
	reg		[38:0]	modebest_6;
	reg		[38:0]	modebest_7;
	wire    [31:0]  mod64_sum_o;

	assign mod64_sum_o = modebest_1[31:0]; //high risk!!!! overflow case.

	always@(posedge clk or negedge rstn)
		if(!rstn) begin
			modebest_1 <= 'd0;
			modebest_2 <= 'd0;
			modebest_3 <= 'd0;
			modebest_4 <= 'd0;
			modebest_5 <= 'd0;
			modebest_6 <= 'd0;
			modebest_7 <= 'd0;
		end
		else if(cnt == 'd1) begin
			modebest_1 <= modebest64_i+modebest_1;
			modebest_2 <= modebest_1;
			modebest_3 <= modebest_2;
			modebest_4 <= modebest_3;
			modebest_5 <= modebest_4;
			modebest_6 <= modebest_5;
			modebest_7 <= modebest_6;
		end

	always@(posedge clk or negedge rstn)
		if(!rstn)
			frame_bit <= 'd0;
		else if(cnt == 'd1)
			frame_bit <= frame_bit + actual_bitnum_i;

//================= calculate ======================

	reg 	[27:0]	predict_bit;
	wire	[54:0]	multiply_tmp;
	reg		[27:0]	diff_abs;
	reg				actual_big; //1: actual > predict 0: actual < predict

	assign	multiply_tmp = modebest_7 * reg_k;

	always@(posedge clk or negedge rstn)
		if(!rstn)
			predict_bit <= 'd0;
		else if(cnt == 'd2)
			predict_bit <= {1'b0,multiply_tmp[54:28]}; //need careful test to decide which bit should be taken.

	always@(posedge clk or negedge rstn)
		if(!rstn)
			actual_big <= 1'b0;
		else if((cnt == 'd3) && (frame_bit > predict_bit))
			actual_big <= 1'b1;
		else if(cnt == 'd3)
			actual_big <= 1'b0;

	always@(posedge clk or negedge rstn)
		if(!rstn)
			diff_abs <= 'd0;
		else if((cnt == 'd4) && actual_big)
			diff_abs <= frame_bit - predict_bit;
		else if(cnt == 'd4)
			diff_abs <= predict_bit - frame_bit;

//================== QP modify ==================

	reg		[5:0]	qp_tmp;
	reg		[1:0]	diff_level;

	always@(posedge clk or negedge rstn)
		if(!rstn)
			diff_level <= 'd0;
		else if((diff_abs > reg_L2_frame_byte) && (cnt == 'd5))
			diff_level <= 'd2;
		else if((diff_abs > reg_L1_frame_byte) && (cnt == 'd5))
			diff_level <= 'd1;
		else if(cnt == 'd5)
			diff_level <= 'd0;

	always@(posedge clk or negedge rstn)
		if(!rstn)
			qp_tmp <= 'd0;
		else if((reg_lcu_rc_en == 1'b0) || (rc_ctu_y_i == 'd0))
			qp_tmp <= reg_initial_qp;
		else if((cnt == 'd6) && actual_big)
			qp_tmp <= reg_initial_qp + diff_level;
		else if(cnt == 'd6)
			qp_tmp <= reg_initial_qp - diff_level;

//=================== ROI ======================

	reg		[5:0]	qp_ROI;
	reg				ROI_hit;

	always@(posedge clk or negedge rstn)
		if(!rstn)
			ROI_hit <= 1'b0;
		else if((cnt =='d7) && (rc_ctu_x_i + 1 > reg_ROI_x) && (rc_ctu_x_i < reg_ROI_x + reg_ROI_width) && (rc_ctu_y_i + 1 > reg_ROI_y) && (rc_ctu_y_i < reg_ROI_y + reg_ROI_height))
			ROI_hit <= 1'b1;
		else if(cnt == 'd7)
			ROI_hit <= 1'b0;

	always@(posedge clk or negedge rstn)
		if(!rstn)
			qp_ROI <= 'd0;
		else if((cnt == 'd8) && ROI_hit && reg_ROI_enable)
			qp_ROI <= qp_tmp - reg_delta_qp;
		else if(cnt == 'd8)
			qp_ROI <= qp_tmp;

//================== chop ========================			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			rc_qp_o <= 'd0;
		else if((cnt == 'd9) && (qp_ROI < reg_min_qp))
			rc_qp_o <= reg_min_qp;
		else if((cnt == 'd9) && (qp_ROI > reg_max_qp))
			rc_qp_o <= reg_max_qp;
		else if(cnt == 'd9)
			rc_qp_o <= qp_ROI;

endmodule 



