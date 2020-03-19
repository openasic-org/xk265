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
//  Filename      : intra_pred.v
//  Author        : Liu Cong
//  Created       : 2014-4
//  Description   : do the reference pixel PADDING and FILTER
//
//-------------------------------------------------------------------
//
//  Modified      : 2014-08-25 by HLL
//  Description   : prediction to chroma supported
//
//  $Id$
//
//-------------------------------------------------------------------

`include "./enc_defines.v"

module intra_pred(
	clk,rst_n,

	start_i,
	done_o,

	mode_i,
	pre_sel_i,
	size_i,

	i4x4_x_i,
	i4x4_y_i,

	ref_tl_i,

	ref_t00_i,ref_t01_i,ref_t02_i,ref_t03_i,ref_t04_i,ref_t05_i,ref_t06_i,ref_t07_i,
	ref_t08_i,ref_t09_i,ref_t10_i,ref_t11_i,ref_t12_i,ref_t13_i,ref_t14_i,ref_t15_i,
	ref_t16_i,ref_t17_i,ref_t18_i,ref_t19_i,ref_t20_i,ref_t21_i,ref_t22_i,ref_t23_i,
	ref_t24_i,ref_t25_i,ref_t26_i,ref_t27_i,ref_t28_i,ref_t29_i,ref_t30_i,ref_t31_i,

	ref_r00_i,ref_r01_i,ref_r02_i,ref_r03_i,ref_r04_i,ref_r05_i,ref_r06_i,ref_r07_i,
	ref_r08_i,ref_r09_i,ref_r10_i,ref_r11_i,ref_r12_i,ref_r13_i,ref_r14_i,ref_r15_i,
	ref_r16_i,ref_r17_i,ref_r18_i,ref_r19_i,ref_r20_i,ref_r21_i,ref_r22_i,ref_r23_i,
	ref_r24_i,ref_r25_i,ref_r26_i,ref_r27_i,ref_r28_i,ref_r29_i,ref_r30_i,ref_r31_i,

	ref_l00_i,ref_l01_i,ref_l02_i,ref_l03_i,ref_l04_i,ref_l05_i,ref_l06_i,ref_l07_i,
	ref_l08_i,ref_l09_i,ref_l10_i,ref_l11_i,ref_l12_i,ref_l13_i,ref_l14_i,ref_l15_i,
	ref_l16_i,ref_l17_i,ref_l18_i,ref_l19_i,ref_l20_i,ref_l21_i,ref_l22_i,ref_l23_i,
	ref_l24_i,ref_l25_i,ref_l26_i,ref_l27_i,ref_l28_i,ref_l29_i,ref_l30_i,ref_l31_i,

	ref_d00_i,ref_d01_i,ref_d02_i,ref_d03_i,ref_d04_i,ref_d05_i,ref_d06_i,ref_d07_i,
	ref_d08_i,ref_d09_i,ref_d10_i,ref_d11_i,ref_d12_i,ref_d13_i,ref_d14_i,ref_d15_i,
	ref_d16_i,ref_d17_i,ref_d18_i,ref_d19_i,ref_d20_i,ref_d21_i,ref_d22_i,ref_d23_i,
	ref_d24_i,ref_d25_i,ref_d26_i,ref_d27_i,ref_d28_i,ref_d29_i,ref_d30_i,ref_d31_i,

	pred_00_o,pred_01_o,pred_02_o,pred_03_o,
	pred_10_o,pred_11_o,pred_12_o,pred_13_o,
	pred_20_o,pred_21_o,pred_22_o,pred_23_o,
	pred_30_o,pred_31_o,pred_32_o,pred_33_o,

	//pre_sel_o
	size_o,
	i4x4_x_o,
	i4x4_y_o
);

//********************************* INPUT/OUTPUT DECLARATION *****************************************
input clk,rst_n;

input		start_i;
output 	done_o;

input [5:0] mode_i;	//total 35 modes
input [1:0] pre_sel_i;
input [1:0] size_i;//00:4x4  01:8x8  10:16x16   11:32x32

input [3:0] i4x4_x_i,i4x4_y_i;//(x,y) of 4x4 block

input [`PIXEL_WIDTH-1:0] ref_tl_i;

input [`PIXEL_WIDTH-1:0] ref_t00_i,ref_t01_i,ref_t02_i,ref_t03_i,ref_t04_i,ref_t05_i,ref_t06_i,ref_t07_i;
input [`PIXEL_WIDTH-1:0] ref_t08_i,ref_t09_i,ref_t10_i,ref_t11_i,ref_t12_i,ref_t13_i,ref_t14_i,ref_t15_i;
input [`PIXEL_WIDTH-1:0] ref_t16_i,ref_t17_i,ref_t18_i,ref_t19_i,ref_t20_i,ref_t21_i,ref_t22_i,ref_t23_i;
input [`PIXEL_WIDTH-1:0] ref_t24_i,ref_t25_i,ref_t26_i,ref_t27_i,ref_t28_i,ref_t29_i,ref_t30_i,ref_t31_i;

input [`PIXEL_WIDTH-1:0] ref_r00_i,ref_r01_i,ref_r02_i,ref_r03_i,ref_r04_i,ref_r05_i,ref_r06_i,ref_r07_i;
input [`PIXEL_WIDTH-1:0] ref_r08_i,ref_r09_i,ref_r10_i,ref_r11_i,ref_r12_i,ref_r13_i,ref_r14_i,ref_r15_i;
input [`PIXEL_WIDTH-1:0] ref_r16_i,ref_r17_i,ref_r18_i,ref_r19_i,ref_r20_i,ref_r21_i,ref_r22_i,ref_r23_i;
input [`PIXEL_WIDTH-1:0] ref_r24_i,ref_r25_i,ref_r26_i,ref_r27_i,ref_r28_i,ref_r29_i,ref_r30_i,ref_r31_i;

input [`PIXEL_WIDTH-1:0] ref_l00_i,ref_l01_i,ref_l02_i,ref_l03_i,ref_l04_i,ref_l05_i,ref_l06_i,ref_l07_i;
input [`PIXEL_WIDTH-1:0] ref_l08_i,ref_l09_i,ref_l10_i,ref_l11_i,ref_l12_i,ref_l13_i,ref_l14_i,ref_l15_i;
input [`PIXEL_WIDTH-1:0] ref_l16_i,ref_l17_i,ref_l18_i,ref_l19_i,ref_l20_i,ref_l21_i,ref_l22_i,ref_l23_i;
input [`PIXEL_WIDTH-1:0] ref_l24_i,ref_l25_i,ref_l26_i,ref_l27_i,ref_l28_i,ref_l29_i,ref_l30_i,ref_l31_i;

input [`PIXEL_WIDTH-1:0] ref_d00_i,ref_d01_i,ref_d02_i,ref_d03_i,ref_d04_i,ref_d05_i,ref_d06_i,ref_d07_i;
input [`PIXEL_WIDTH-1:0] ref_d08_i,ref_d09_i,ref_d10_i,ref_d11_i,ref_d12_i,ref_d13_i,ref_d14_i,ref_d15_i;
input [`PIXEL_WIDTH-1:0] ref_d16_i,ref_d17_i,ref_d18_i,ref_d19_i,ref_d20_i,ref_d21_i,ref_d22_i,ref_d23_i;
input [`PIXEL_WIDTH-1:0] ref_d24_i,ref_d25_i,ref_d26_i,ref_d27_i,ref_d28_i,ref_d29_i,ref_d30_i,ref_d31_i;

output [`PIXEL_WIDTH-1:0] pred_00_o,pred_01_o,pred_02_o,pred_03_o;
output [`PIXEL_WIDTH-1:0] pred_10_o,pred_11_o,pred_12_o,pred_13_o;
output [`PIXEL_WIDTH-1:0] pred_20_o,pred_21_o,pred_22_o,pred_23_o;
output [`PIXEL_WIDTH-1:0] pred_30_o,pred_31_o,pred_32_o,pred_33_o;

//pre_sel_o
output [1:0] size_o;
output [3:0] i4x4_x_o, i4x4_y_o;
//*******************************************************************************************************



//*************************************** REG/WIRE DELARATION ********************************************
reg [1:0] size_o;
reg [3:0] i4x4_x_o, i4x4_y_o;

reg start_r0,start_r1,done_o;

reg signed [6:0] pred_angle;
reg signed [6:0] idx0, idx1, idx2, idx3;
reg signed [10:0] fact0,fact1,fact2,fact3;

reg [4:0] ifact0,ifact1,ifact2,ifact3;

reg [5:0] mode_r0,mode_r1;
reg [1:0] size_r0,size_r1;

reg signed [5:0] delta_idx_r;

reg [4:0] y0,y1,y2,y3,x0,x1,x2,x3;

wire signed [5:0] y0_sign_w,y1_sign_w,y2_sign_w,y3_sign_w;
wire signed [5:0] x0_sign_w,x1_sign_w,x2_sign_w,x3_sign_w;

reg [4:0] y0_r0,y1_r0,y2_r0,y3_r0,x0_r0,x1_r0,x2_r0,x3_r0;
reg [4:0] y0_r1,y1_r1,y2_r1,y3_r1,x0_r1,x1_r1,x2_r1,x3_r1;

reg [3:0] i4x4_x_r,i4x4_y_r;
reg [3:0] i4x4_x_r1,i4x4_y_r1;

reg [`PIXEL_WIDTH-1:0]	dc_value_r;

reg [`PIXEL_WIDTH-1:0]	top0_r, top1_r, top2_r, top3_r;
reg [`PIXEL_WIDTH-1:0]	left0_r,left1_r,left2_r,left3_r;

reg [`PIXEL_WIDTH-1:0]	ref_l00_w,ref_l04_w,ref_l08_w,ref_l12_w,ref_l16_w,ref_l20_w,ref_l24_w,ref_l28_w;
reg [`PIXEL_WIDTH-1:0]	ref_l01_w,ref_l05_w,ref_l09_w,ref_l13_w,ref_l17_w,ref_l21_w,ref_l25_w,ref_l29_w;
reg [`PIXEL_WIDTH-1:0]	ref_l02_w,ref_l06_w,ref_l10_w,ref_l14_w,ref_l18_w,ref_l22_w,ref_l26_w,ref_l30_w;
reg [`PIXEL_WIDTH-1:0]	ref_l03_w,ref_l07_w,ref_l11_w,ref_l15_w,ref_l19_w,ref_l23_w,ref_l27_w,ref_l31_w;

reg [`PIXEL_WIDTH-1:0]	ref_l32_w,ref_l36_w,ref_l40_w,ref_l44_w,ref_l48_w,ref_l52_w,ref_l56_w,ref_l60_w;
reg [`PIXEL_WIDTH-1:0]	ref_l33_w,ref_l37_w,ref_l41_w,ref_l45_w,ref_l49_w,ref_l53_w,ref_l57_w,ref_l61_w;
reg [`PIXEL_WIDTH-1:0]	ref_l34_w,ref_l38_w,ref_l42_w,ref_l46_w,ref_l50_w,ref_l54_w,ref_l58_w,ref_l62_w;
reg [`PIXEL_WIDTH-1:0]	ref_l35_w,ref_l39_w,ref_l43_w,ref_l47_w,ref_l51_w,ref_l55_w,ref_l59_w,ref_l63_w;

reg [`PIXEL_WIDTH-1:0]	ref_t00_w,ref_t04_w,ref_t08_w,ref_t12_w,ref_t16_w,ref_t20_w,ref_t24_w,ref_t28_w;
reg [`PIXEL_WIDTH-1:0]	ref_t01_w,ref_t05_w,ref_t09_w,ref_t13_w,ref_t17_w,ref_t21_w,ref_t25_w,ref_t29_w;
reg [`PIXEL_WIDTH-1:0]	ref_t02_w,ref_t06_w,ref_t10_w,ref_t14_w,ref_t18_w,ref_t22_w,ref_t26_w,ref_t30_w;
reg [`PIXEL_WIDTH-1:0]	ref_t03_w,ref_t07_w,ref_t11_w,ref_t15_w,ref_t19_w,ref_t23_w,ref_t27_w,ref_t31_w;

reg [`PIXEL_WIDTH-1:0]	ref_t32_w,ref_t36_w,ref_t40_w,ref_t44_w,ref_t48_w,ref_t52_w,ref_t56_w,ref_t60_w;
reg [`PIXEL_WIDTH-1:0]	ref_t33_w,ref_t37_w,ref_t41_w,ref_t45_w,ref_t49_w,ref_t53_w,ref_t57_w,ref_t61_w;
reg [`PIXEL_WIDTH-1:0]	ref_t34_w,ref_t38_w,ref_t42_w,ref_t46_w,ref_t50_w,ref_t54_w,ref_t58_w,ref_t62_w;
reg [`PIXEL_WIDTH-1:0]	ref_t35_w,ref_t39_w,ref_t43_w,ref_t47_w,ref_t51_w,ref_t55_w,ref_t59_w,ref_t63_w;

reg [`PIXEL_WIDTH-1:0]	ref_00_r;

reg [`PIXEL_WIDTH-1:0]	ref_01_r,ref_05_r,ref_09_r,ref_13_r,ref_17_r,ref_21_r,ref_25_r,ref_29_r;
reg [`PIXEL_WIDTH-1:0]	ref_02_r,ref_06_r,ref_10_r,ref_14_r,ref_18_r,ref_22_r,ref_26_r,ref_30_r;
reg [`PIXEL_WIDTH-1:0]	ref_03_r,ref_07_r,ref_11_r,ref_15_r,ref_19_r,ref_23_r,ref_27_r,ref_31_r;
reg [`PIXEL_WIDTH-1:0]	ref_04_r,ref_08_r,ref_12_r,ref_16_r,ref_20_r,ref_24_r,ref_28_r,ref_32_r;

reg [`PIXEL_WIDTH-1:0]	ref_33_r,ref_37_r,ref_41_r,ref_45_r,ref_49_r,ref_53_r,ref_57_r,ref_61_r;
reg [`PIXEL_WIDTH-1:0]	ref_34_r,ref_38_r,ref_42_r,ref_46_r,ref_50_r,ref_54_r,ref_58_r,ref_62_r;
reg [`PIXEL_WIDTH-1:0]	ref_35_r,ref_39_r,ref_43_r,ref_47_r,ref_51_r,ref_55_r,ref_59_r,ref_63_r;
reg [`PIXEL_WIDTH-1:0]	ref_36_r,ref_40_r,ref_44_r,ref_48_r,ref_52_r,ref_56_r,ref_60_r,ref_64_r;

reg [`PIXEL_WIDTH-1:0]	ref_x01_r,ref_x05_r,ref_x09_r,ref_x13_r,ref_x17_r,ref_x21_r,ref_x25_r,ref_x29_r;
reg [`PIXEL_WIDTH-1:0]	ref_x02_r,ref_x06_r,ref_x10_r,ref_x14_r,ref_x18_r,ref_x22_r,ref_x26_r,ref_x30_r;
reg [`PIXEL_WIDTH-1:0]	ref_x03_r,ref_x07_r,ref_x11_r,ref_x15_r,ref_x19_r,ref_x23_r,ref_x27_r,ref_x31_r;
reg [`PIXEL_WIDTH-1:0]	ref_x04_r,ref_x08_r,ref_x12_r,ref_x16_r,ref_x20_r,ref_x24_r,ref_x28_r,ref_x32_r;

reg [`PIXEL_WIDTH-1:0] ref_0_0,ref_0_1,ref_0_2,ref_0_3,ref_0_4;
reg [`PIXEL_WIDTH-1:0] ref_1_0,ref_1_1,ref_1_2,ref_1_3,ref_1_4;
reg [`PIXEL_WIDTH-1:0] ref_2_0,ref_2_1,ref_2_2,ref_2_3,ref_2_4;
reg [`PIXEL_WIDTH-1:0] ref_3_0,ref_3_1,ref_3_2,ref_3_3,ref_3_4;

reg [`PIXEL_WIDTH-1:0] pred_00_o,pred_01_o,pred_02_o,pred_03_o;
reg [`PIXEL_WIDTH-1:0] pred_10_o,pred_11_o,pred_12_o,pred_13_o;
reg [`PIXEL_WIDTH-1:0] pred_20_o,pred_21_o,pred_22_o,pred_23_o;
reg [`PIXEL_WIDTH-1:0] pred_30_o,pred_31_o,pred_32_o,pred_33_o;

reg [`PIXEL_WIDTH-1:0] pre_0_0_w,pre_0_1_w,pre_0_2_w,pre_0_3_w;
reg [`PIXEL_WIDTH-1:0] pre_1_0_w,pre_1_1_w,pre_1_2_w,pre_1_3_w;
reg [`PIXEL_WIDTH-1:0] pre_2_0_w,pre_2_1_w,pre_2_2_w,pre_2_3_w;
reg [`PIXEL_WIDTH-1:0] pre_3_0_w,pre_3_1_w,pre_3_2_w,pre_3_3_w;

reg [`PIXEL_WIDTH+1:0]	mid_t0_r,mid_l0_r;
reg [`PIXEL_WIDTH+2:0]	mid_t2_r,mid_t3_r,mid_t4_r,mid_t5_r;
reg [`PIXEL_WIDTH+2:0]	mid_l2_r,mid_l3_r,mid_l4_r,mid_l5_r;
//*********************************************************************************************************


//stage0
//********************************************************************************
//lookup table to get pred_angle
always @( * ) begin
	case (mode_i)
		2 ,34:pred_angle=7'd32;	11,25:pred_angle=-7'd2;
		3 ,33:pred_angle=7'd26;	12,24:pred_angle=-7'd5;
		4 ,32:pred_angle=7'd21;	13,23:pred_angle=-7'd9;
		5 ,31:pred_angle=7'd17;	14,22:pred_angle=-7'd13;
		6 ,30:pred_angle=7'd13;	15,21:pred_angle=-7'd17;
		7 ,29:pred_angle=7'd9;		16,20:pred_angle=-7'd21;
		8 ,28:pred_angle=7'd5;		17,19:pred_angle=-7'd26;
		9 ,27:pred_angle=7'd2;		18:   pred_angle=-7'd32;
		10,26:pred_angle=7'd0;
		default:pred_angle=7'd0;
	endcase
end

//********************************************************************************
//get the location information of current 4x4 block
always @( * ) begin//x
	case(size_i)
		2'b00:begin//4x4
			x0='d0; x1='d1; x2='d2; x3='d3;
		end

		2'b01:begin//8x8
			if(!i4x4_x_i[0]) begin
				x0='d0; x1='d1; x2='d2; x3='d3;
			end
			else begin
				x0='d4; x1='d5; x2='d6; x3='d7;
			end
		end

		2'b10:begin//16x16
			case(i4x4_x_i[1:0])
				2'b00:begin
					x0='d0; x1='d1; x2='d2; x3='d3;
				end
				2'b01:begin
					x0='d4; x1='d5; x2='d6; x3='d7;
				end
				2'b10:begin
					x0='d8; x1='d9; x2='d10; x3='d11;
				end
				2'b11:begin
					x0='d12; x1='d13; x2='d14; x3='d15;
				end
			endcase
		end

		2'b11:begin//32x32
			case(i4x4_x_i[2:0])
				3'b000:begin
					x0='d0; x1='d1; x2='d2; x3='d3;
				end
				3'b001:begin
					x0='d4; x1='d5; x2='d6; x3='d7;
				end
				3'b010:begin
					x0='d8; x1='d9; x2='d10; x3='d11;
				end
				3'b011:begin
					x0='d12; x1='d13; x2='d14; x3='d15;
				end
				3'b100:begin
					x0='d16; x1='d17; x2='d18; x3='d19;
				end
				3'b101:begin
					x0='d20; x1='d21; x2='d22; x3='d23;
				end
				3'b110:begin
					x0='d24; x1='d25; x2='d26; x3='d27;
				end
				3'b111:begin
					x0='d28; x1='d29; x2='d30; x3='d31;
				end
			endcase
		end
	endcase
end

always @( * ) begin//y
	case(size_i)
		2'b00:begin//4x4
			y0='d0; y1='d1; y2='d2; y3='d3;
		end

		2'b01:begin//8x8
			if(!i4x4_y_i[0]) begin
				y0='d0; y1='d1; y2='d2; y3='d3;
			end
			else begin
				y0='d4; y1='d5; y2='d6; y3='d7;
			end
		end

		2'b10:begin//16x16
			case(i4x4_y_i[1:0])
				2'b00:begin
					y0='d0; y1='d1; y2='d2; y3='d3;
				end
				2'b01:begin
					y0='d4; y1='d5; y2='d6; y3='d7;
				end
				2'b10:begin
					y0='d8; y1='d9; y2='d10; y3='d11;
				end
				2'b11:begin
					y0='d12; y1='d13; y2='d14; y3='d15;
				end
			endcase
		end

		2'b11:begin//32x32
			case(i4x4_y_i[2:0])
				3'b000:begin
					y0='d0; y1='d1; y2='d2; y3='d3;
				end
				3'b001:begin
					y0='d4; y1='d5; y2='d6; y3='d7;
				end
				3'b010:begin
					y0='d8; y1='d9; y2='d10; y3='d11;
				end
				3'b011:begin
					y0='d12; y1='d13; y2='d14; y3='d15;
				end
				3'b100:begin
					y0='d16; y1='d17; y2='d18; y3='d19;
				end
				3'b101:begin
					y0='d20; y1='d21; y2='d22; y3='d23;
				end
				3'b110:begin
					y0='d24; y1='d25; y2='d26; y3='d27;
				end
				3'b111:begin
					y0='d28; y1='d29; y2='d30; y3='d31;
				end
			endcase
		end
	endcase
end

always @(posedge clk or negedge rst_n) begin//help to choose the reference pixel
	if(!rst_n) begin
		delta_idx_r <= 'd0;
	end
	else begin
		if(mode_i>=18)
			delta_idx_r <= {1'b0,x0};
		else
			delta_idx_r <= {1'b0,y0};
	end
end
//*********************************************************************************
//calculate idx and ifact for intra prediction
assign x0_sign_w={1'b0,x0};
assign x1_sign_w={1'b0,x1};
assign x2_sign_w={1'b0,x2};
assign x3_sign_w={1'b0,x3};

assign y0_sign_w={1'b0,y0};
assign y1_sign_w={1'b0,y1};
assign y2_sign_w={1'b0,y2};
assign y3_sign_w={1'b0,y3};

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fact0<='d0;  idx0<='d0;
		fact1<='d0;  idx1<='d0;
		fact2<='d0;  idx2<='d0;
		fact3<='d0;  idx3<='d0;
	end
	else begin
		if (mode_i >= 18) begin
			fact0<=((y0+1)*pred_angle);
			fact1<=((y1+1)*pred_angle);
			fact2<=((y2+1)*pred_angle);
			fact3<=((y3+1)*pred_angle);

			idx0<=((y0_sign_w+1)*pred_angle)>>>5;
			idx1<=((y1_sign_w+1)*pred_angle)>>>5;
			idx2<=((y2_sign_w+1)*pred_angle)>>>5;
			idx3<=((y3_sign_w+1)*pred_angle)>>>5;
		end
		else begin
			fact0<=((x0+1)*pred_angle);
			fact1<=((x1+1)*pred_angle);
			fact2<=((x2+1)*pred_angle);
			fact3<=((x3+1)*pred_angle);

			idx0<=((x0_sign_w+1)*pred_angle)>>>5;
			idx1<=((x1_sign_w+1)*pred_angle)>>>5;
			idx2<=((x2_sign_w+1)*pred_angle)>>>5;
			idx3<=((x3_sign_w+1)*pred_angle)>>>5;
		end
	end
end

//**********************************************************************************
//get the real reference pixel
always @( * ) begin
	ref_l00_w = 'd0;  ref_l04_w = 'd0;  ref_l08_w = 'd0;  ref_l12_w = 'd0;	ref_l16_w = 'd0;  ref_l20_w = 'd0;  ref_l24_w = 'd0;  ref_l28_w = 'd0;
	ref_l01_w = 'd0;  ref_l05_w = 'd0;  ref_l09_w = 'd0;  ref_l13_w = 'd0;	ref_l17_w = 'd0;  ref_l21_w = 'd0;  ref_l25_w = 'd0;  ref_l29_w = 'd0;
	ref_l02_w = 'd0;  ref_l06_w = 'd0;  ref_l10_w = 'd0;  ref_l14_w = 'd0;	ref_l18_w = 'd0;  ref_l22_w = 'd0;  ref_l26_w = 'd0;  ref_l30_w = 'd0;
	ref_l03_w = 'd0;  ref_l07_w = 'd0;  ref_l11_w = 'd0;  ref_l15_w = 'd0;	ref_l19_w = 'd0;  ref_l23_w = 'd0;  ref_l27_w = 'd0;  ref_l31_w = 'd0;

	ref_l32_w = 'd0;  ref_l36_w = 'd0;  ref_l40_w = 'd0;  ref_l44_w = 'd0;	ref_l48_w = 'd0;  ref_l52_w = 'd0;  ref_l56_w = 'd0;  ref_l60_w = 'd0;
	ref_l33_w = 'd0;  ref_l37_w = 'd0;  ref_l41_w = 'd0;  ref_l45_w = 'd0;	ref_l49_w = 'd0;  ref_l53_w = 'd0;  ref_l57_w = 'd0;  ref_l61_w = 'd0;
	ref_l34_w = 'd0;  ref_l38_w = 'd0;  ref_l42_w = 'd0;  ref_l46_w = 'd0;	ref_l50_w = 'd0;  ref_l54_w = 'd0;  ref_l58_w = 'd0;  ref_l62_w = 'd0;
	ref_l35_w = 'd0;  ref_l39_w = 'd0;  ref_l43_w = 'd0;  ref_l47_w = 'd0;	ref_l51_w = 'd0;  ref_l55_w = 'd0;  ref_l59_w = 'd0;  ref_l63_w = 'd0;

	ref_t00_w = 'd0;  ref_t04_w = 'd0;  ref_t08_w = 'd0;  ref_t12_w = 'd0;	ref_t16_w = 'd0;  ref_t20_w = 'd0;  ref_t24_w = 'd0;  ref_t28_w = 'd0;
	ref_t01_w = 'd0;  ref_t05_w = 'd0;  ref_t09_w = 'd0;  ref_t13_w = 'd0;	ref_t17_w = 'd0;  ref_t21_w = 'd0;  ref_t25_w = 'd0;  ref_t29_w = 'd0;
	ref_t02_w = 'd0;  ref_t06_w = 'd0;  ref_t10_w = 'd0;  ref_t14_w = 'd0;	ref_t18_w = 'd0;  ref_t22_w = 'd0;  ref_t26_w = 'd0;  ref_t30_w = 'd0;
	ref_t03_w = 'd0;  ref_t07_w = 'd0;  ref_t11_w = 'd0;  ref_t15_w = 'd0;	ref_t19_w = 'd0;  ref_t23_w = 'd0;  ref_t27_w = 'd0;  ref_t31_w = 'd0;

	ref_t32_w = 'd0;  ref_t36_w = 'd0;  ref_t40_w = 'd0;  ref_t44_w = 'd0;	ref_t48_w = 'd0;  ref_t52_w = 'd0;  ref_t56_w = 'd0;  ref_t60_w = 'd0;
	ref_t33_w = 'd0;  ref_t37_w = 'd0;  ref_t41_w = 'd0;  ref_t45_w = 'd0;	ref_t49_w = 'd0;  ref_t53_w = 'd0;  ref_t57_w = 'd0;  ref_t61_w = 'd0;
	ref_t34_w = 'd0;  ref_t38_w = 'd0;  ref_t42_w = 'd0;  ref_t46_w = 'd0;	ref_t50_w = 'd0;  ref_t54_w = 'd0;  ref_t58_w = 'd0;  ref_t62_w = 'd0;
	ref_t35_w = 'd0;  ref_t39_w = 'd0;  ref_t43_w = 'd0;  ref_t47_w = 'd0;	ref_t51_w = 'd0;  ref_t55_w = 'd0;  ref_t59_w = 'd0;  ref_t63_w = 'd0;

	case(size_i)
		2'b00:begin
			ref_l00_w = ref_l00_i;  ref_l04_w = ref_d00_i;  ref_t00_w = ref_t00_i;  ref_t04_w = ref_r00_i;
			ref_l01_w = ref_l01_i;  ref_l05_w = ref_d01_i;  ref_t01_w = ref_t01_i;  ref_t05_w = ref_r01_i;
			ref_l02_w = ref_l02_i;  ref_l06_w = ref_d02_i;  ref_t02_w = ref_t02_i;  ref_t06_w = ref_r02_i;
			ref_l03_w = ref_l03_i;  ref_l07_w = ref_d03_i;  ref_t03_w = ref_t03_i;  ref_t07_w = ref_r03_i;
		end
		2'b01:begin
			ref_l00_w = ref_l00_i;  ref_l04_w = ref_l04_i;  ref_l08_w = ref_d00_i;  ref_l12_w = ref_d04_i;
			ref_l01_w = ref_l01_i;  ref_l05_w = ref_l05_i;  ref_l09_w = ref_d01_i;  ref_l13_w = ref_d05_i;
			ref_l02_w = ref_l02_i;  ref_l06_w = ref_l06_i;  ref_l10_w = ref_d02_i;  ref_l14_w = ref_d06_i;
			ref_l03_w = ref_l03_i;  ref_l07_w = ref_l07_i;  ref_l11_w = ref_d03_i;  ref_l15_w = ref_d07_i;

			ref_t00_w = ref_t00_i;  ref_t04_w = ref_t04_i;  ref_t08_w = ref_r00_i;  ref_t12_w = ref_r04_i;
			ref_t01_w = ref_t01_i;  ref_t05_w = ref_t05_i;  ref_t09_w = ref_r01_i;  ref_t13_w = ref_r05_i;
			ref_t02_w = ref_t02_i;  ref_t06_w = ref_t06_i;  ref_t10_w = ref_r02_i;  ref_t14_w = ref_r06_i;
			ref_t03_w = ref_t03_i;  ref_t07_w = ref_t07_i;  ref_t11_w = ref_r03_i;  ref_t15_w = ref_r07_i;
		end
		2'b10:begin
			ref_l00_w = ref_l00_i;  ref_l04_w = ref_l04_i;  ref_l08_w = ref_l08_i;  ref_l12_w = ref_l12_i;
			ref_l01_w = ref_l01_i;  ref_l05_w = ref_l05_i;  ref_l09_w = ref_l09_i;  ref_l13_w = ref_l13_i;
			ref_l02_w = ref_l02_i;  ref_l06_w = ref_l06_i;  ref_l10_w = ref_l10_i;  ref_l14_w = ref_l14_i;
			ref_l03_w = ref_l03_i;  ref_l07_w = ref_l07_i;  ref_l11_w = ref_l11_i;  ref_l15_w = ref_l15_i;

			ref_l16_w = ref_d00_i;  ref_l20_w = ref_d04_i;  ref_l24_w = ref_d08_i;  ref_l28_w = ref_d12_i;
			ref_l17_w = ref_d01_i;  ref_l21_w = ref_d05_i;  ref_l25_w = ref_d09_i;  ref_l29_w = ref_d13_i;
			ref_l18_w = ref_d02_i;  ref_l22_w = ref_d06_i;  ref_l26_w = ref_d10_i;  ref_l30_w = ref_d14_i;
			ref_l19_w = ref_d03_i;  ref_l23_w = ref_d07_i;  ref_l27_w = ref_d11_i;  ref_l31_w = ref_d15_i;

			ref_t00_w = ref_t00_i;  ref_t04_w = ref_t04_i;  ref_t08_w = ref_t08_i;  ref_t12_w = ref_t12_i;
			ref_t01_w = ref_t01_i;  ref_t05_w = ref_t05_i;  ref_t09_w = ref_t09_i;  ref_t13_w = ref_t13_i;
			ref_t02_w = ref_t02_i;  ref_t06_w = ref_t06_i;  ref_t10_w = ref_t10_i;  ref_t14_w = ref_t14_i;
			ref_t03_w = ref_t03_i;  ref_t07_w = ref_t07_i;  ref_t11_w = ref_t11_i;  ref_t15_w = ref_t15_i;

			ref_t16_w = ref_r00_i;  ref_t20_w = ref_r04_i;  ref_t24_w = ref_r08_i;  ref_t28_w = ref_r12_i;
			ref_t17_w = ref_r01_i;  ref_t21_w = ref_r05_i;  ref_t25_w = ref_r09_i;  ref_t29_w = ref_r13_i;
			ref_t18_w = ref_r02_i;  ref_t22_w = ref_r06_i;  ref_t26_w = ref_r10_i;  ref_t30_w = ref_r14_i;
			ref_t19_w = ref_r03_i;  ref_t23_w = ref_r07_i;  ref_t27_w = ref_r11_i;  ref_t31_w = ref_r15_i;
		end
		2'b11:begin
			ref_l00_w = ref_l00_i;  ref_l04_w = ref_l04_i;  ref_l08_w = ref_l08_i;  ref_l12_w = ref_l12_i;
			ref_l01_w = ref_l01_i;  ref_l05_w = ref_l05_i;  ref_l09_w = ref_l09_i;  ref_l13_w = ref_l13_i;
			ref_l02_w = ref_l02_i;  ref_l06_w = ref_l06_i;  ref_l10_w = ref_l10_i;  ref_l14_w = ref_l14_i;
			ref_l03_w = ref_l03_i;  ref_l07_w = ref_l07_i;  ref_l11_w = ref_l11_i;  ref_l15_w = ref_l15_i;

			ref_l16_w = ref_l16_i;  ref_l20_w = ref_l20_i;  ref_l24_w = ref_l24_i;  ref_l28_w = ref_l28_i;
			ref_l17_w = ref_l17_i;  ref_l21_w = ref_l21_i;  ref_l25_w = ref_l25_i;  ref_l29_w = ref_l29_i;
			ref_l18_w = ref_l18_i;  ref_l22_w = ref_l22_i;  ref_l26_w = ref_l26_i;  ref_l30_w = ref_l30_i;
			ref_l19_w = ref_l19_i;  ref_l23_w = ref_l23_i;  ref_l27_w = ref_l27_i;  ref_l31_w = ref_l31_i;

			ref_l32_w = ref_d00_i;  ref_l36_w = ref_d04_i;  ref_l40_w = ref_d08_i;  ref_l44_w = ref_d12_i;
			ref_l33_w = ref_d01_i;  ref_l37_w = ref_d05_i;  ref_l41_w = ref_d09_i;  ref_l45_w = ref_d13_i;
			ref_l34_w = ref_d02_i;  ref_l38_w = ref_d06_i;  ref_l42_w = ref_d10_i;  ref_l46_w = ref_d14_i;
			ref_l35_w = ref_d03_i;  ref_l39_w = ref_d07_i;  ref_l43_w = ref_d11_i;  ref_l47_w = ref_d15_i;

			ref_l48_w = ref_d16_i;  ref_l52_w = ref_d20_i;  ref_l56_w = ref_d24_i;  ref_l60_w = ref_d28_i;
			ref_l49_w = ref_d17_i;  ref_l53_w = ref_d21_i;  ref_l57_w = ref_d25_i;  ref_l61_w = ref_d29_i;
			ref_l50_w = ref_d18_i;  ref_l54_w = ref_d22_i;  ref_l58_w = ref_d26_i;  ref_l62_w = ref_d30_i;
			ref_l51_w = ref_d19_i;  ref_l55_w = ref_d23_i;  ref_l59_w = ref_d27_i;  ref_l63_w = ref_d31_i;

			ref_t00_w = ref_t00_i;  ref_t04_w = ref_t04_i;  ref_t08_w = ref_t08_i;  ref_t12_w = ref_t12_i;
			ref_t01_w = ref_t01_i;  ref_t05_w = ref_t05_i;  ref_t09_w = ref_t09_i;  ref_t13_w = ref_t13_i;
			ref_t02_w = ref_t02_i;  ref_t06_w = ref_t06_i;  ref_t10_w = ref_t10_i;  ref_t14_w = ref_t14_i;
			ref_t03_w = ref_t03_i;  ref_t07_w = ref_t07_i;  ref_t11_w = ref_t11_i;  ref_t15_w = ref_t15_i;

			ref_t16_w = ref_t16_i;  ref_t20_w = ref_t20_i;  ref_t24_w = ref_t24_i;  ref_t28_w = ref_t28_i;
			ref_t17_w = ref_t17_i;  ref_t21_w = ref_t21_i;  ref_t25_w = ref_t25_i;  ref_t29_w = ref_t29_i;
			ref_t18_w = ref_t18_i;  ref_t22_w = ref_t22_i;  ref_t26_w = ref_t26_i;  ref_t30_w = ref_t30_i;
			ref_t19_w = ref_t19_i;  ref_t23_w = ref_t23_i;  ref_t27_w = ref_t27_i;  ref_t31_w = ref_t31_i;

			ref_t32_w = ref_r00_i;  ref_t36_w = ref_r04_i;  ref_t40_w = ref_r08_i;  ref_t44_w = ref_r12_i;
			ref_t33_w = ref_r01_i;  ref_t37_w = ref_r05_i;  ref_t41_w = ref_r09_i;  ref_t45_w = ref_r13_i;
			ref_t34_w = ref_r02_i;  ref_t38_w = ref_r06_i;  ref_t42_w = ref_r10_i;  ref_t46_w = ref_r14_i;
			ref_t35_w = ref_r03_i;  ref_t39_w = ref_r07_i;  ref_t43_w = ref_r11_i;  ref_t47_w = ref_r15_i;

			ref_t48_w = ref_r16_i;  ref_t52_w = ref_r20_i;  ref_t56_w = ref_r24_i;  ref_t60_w = ref_r28_i;
			ref_t49_w = ref_r17_i;  ref_t53_w = ref_r21_i;  ref_t57_w = ref_r25_i;  ref_t61_w = ref_r29_i;
			ref_t50_w = ref_r18_i;  ref_t54_w = ref_r22_i;  ref_t58_w = ref_r26_i;  ref_t62_w = ref_r30_i;
			ref_t51_w = ref_r19_i;  ref_t55_w = ref_r23_i;  ref_t59_w = ref_r27_i;  ref_t63_w = ref_r31_i;
		end
	endcase
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		ref_00_r <= 'd0;

		ref_01_r <= 'd0;  ref_05_r <= 'd0;  ref_09_r <= 'd0;  ref_13_r <= 'd0;  ref_17_r <= 'd0;  ref_21_r <= 'd0;  ref_25_r <= 'd0;  ref_29_r <= 'd0;
		ref_02_r <= 'd0;  ref_06_r <= 'd0;  ref_10_r <= 'd0;  ref_14_r <= 'd0;  ref_18_r <= 'd0;  ref_22_r <= 'd0;  ref_26_r <= 'd0;  ref_30_r <= 'd0;
		ref_03_r <= 'd0;  ref_07_r <= 'd0;  ref_11_r <= 'd0;  ref_15_r <= 'd0;  ref_19_r <= 'd0;  ref_23_r <= 'd0;  ref_27_r <= 'd0;  ref_31_r <= 'd0;
		ref_04_r <= 'd0;  ref_08_r <= 'd0;  ref_12_r <= 'd0;  ref_16_r <= 'd0;  ref_20_r <= 'd0;  ref_24_r <= 'd0;  ref_28_r <= 'd0;  ref_32_r <= 'd0;

		ref_33_r <= 'd0;  ref_37_r <= 'd0;  ref_41_r <= 'd0;  ref_45_r <= 'd0;  ref_49_r <= 'd0;  ref_53_r <= 'd0;  ref_57_r <= 'd0;  ref_61_r <= 'd0;
		ref_34_r <= 'd0;  ref_38_r <= 'd0;  ref_42_r <= 'd0;  ref_46_r <= 'd0;  ref_50_r <= 'd0;  ref_54_r <= 'd0;  ref_58_r <= 'd0;  ref_62_r <= 'd0;
		ref_35_r <= 'd0;  ref_39_r <= 'd0;  ref_43_r <= 'd0;  ref_47_r <= 'd0;  ref_51_r <= 'd0;  ref_55_r <= 'd0;  ref_59_r <= 'd0;  ref_63_r <= 'd0;
		ref_36_r <= 'd0;  ref_40_r <= 'd0;  ref_44_r <= 'd0;  ref_48_r <= 'd0;  ref_52_r <= 'd0;  ref_56_r <= 'd0;  ref_60_r <= 'd0;  ref_64_r <= 'd0;

		ref_x01_r <= 'd0;  ref_x05_r <= 'd0;  ref_x09_r <= 'd0;  ref_x13_r <= 'd0;  ref_x17_r <= 'd0;  ref_x21_r <= 'd0;  ref_x25_r <= 'd0;  ref_x29_r <= 'd0;
		ref_x02_r <= 'd0;  ref_x06_r <= 'd0;  ref_x10_r <= 'd0;  ref_x14_r <= 'd0;  ref_x18_r <= 'd0;  ref_x22_r <= 'd0;  ref_x26_r <= 'd0;  ref_x30_r <= 'd0;
		ref_x03_r <= 'd0;  ref_x07_r <= 'd0;  ref_x11_r <= 'd0;  ref_x15_r <= 'd0;  ref_x19_r <= 'd0;  ref_x23_r <= 'd0;  ref_x27_r <= 'd0;  ref_x31_r <= 'd0;
		ref_x04_r <= 'd0;  ref_x08_r <= 'd0;  ref_x12_r <= 'd0;  ref_x16_r <= 'd0;  ref_x20_r <= 'd0;  ref_x24_r <= 'd0;  ref_x28_r <= 'd0;  ref_x32_r <= 'd0;
	end
	else begin
		ref_00_r <= ref_tl_i;
		if(mode_i >= 18) begin
			ref_01_r <= ref_t00_w;  ref_05_r <= ref_t04_w;  ref_09_r <= ref_t08_w;  ref_13_r <= ref_t12_w;
			ref_02_r <= ref_t01_w;  ref_06_r <= ref_t05_w;  ref_10_r <= ref_t09_w;  ref_14_r <= ref_t13_w;
			ref_03_r <= ref_t02_w;  ref_07_r <= ref_t06_w;  ref_11_r <= ref_t10_w;  ref_15_r <= ref_t14_w;
			ref_04_r <= ref_t03_w;  ref_08_r <= ref_t07_w;  ref_12_r <= ref_t11_w;  ref_16_r <= ref_t15_w;

			ref_17_r <= ref_t16_w;  ref_21_r <= ref_t20_w;  ref_25_r <= ref_t24_w;  ref_29_r <= ref_t28_w;
			ref_18_r <= ref_t17_w;  ref_22_r <= ref_t21_w;  ref_26_r <= ref_t25_w;  ref_30_r <= ref_t29_w;
			ref_19_r <= ref_t18_w;  ref_23_r <= ref_t22_w;  ref_27_r <= ref_t26_w;  ref_31_r <= ref_t30_w;
			ref_20_r <= ref_t19_w;  ref_24_r <= ref_t23_w;  ref_28_r <= ref_t27_w;  ref_32_r <= ref_t31_w;

			ref_33_r <= ref_t32_w;  ref_37_r <= ref_t36_w;  ref_41_r <= ref_t40_w;  ref_45_r <= ref_t44_w;
			ref_34_r <= ref_t33_w;  ref_38_r <= ref_t37_w;  ref_42_r <= ref_t41_w;  ref_46_r <= ref_t45_w;
			ref_35_r <= ref_t34_w;  ref_39_r <= ref_t38_w;  ref_43_r <= ref_t42_w;  ref_47_r <= ref_t46_w;
			ref_36_r <= ref_t35_w;  ref_40_r <= ref_t39_w;  ref_44_r <= ref_t43_w;  ref_48_r <= ref_t47_w;

			ref_49_r <= ref_t48_w;  ref_53_r <= ref_t52_w;  ref_57_r <= ref_t56_w;  ref_61_r <= ref_t60_w;
			ref_50_r <= ref_t49_w;  ref_54_r <= ref_t53_w;  ref_58_r <= ref_t57_w;  ref_62_r <= ref_t61_w;
			ref_51_r <= ref_t50_w;  ref_55_r <= ref_t54_w;  ref_59_r <= ref_t58_w;  ref_63_r <= ref_t62_w;
			ref_52_r <= ref_t51_w;  ref_56_r <= ref_t55_w;  ref_60_r <= ref_t59_w;  ref_64_r <= ref_t63_w;

			case (mode_i)
				'd19:begin
					ref_x01_r <= ref_l00_w;  ref_x05_r <= ref_l05_w;  ref_x09_r <= ref_l10_w;  ref_x13_r <= ref_l15_w;
					ref_x02_r <= ref_l01_w;  ref_x06_r <= ref_l06_w;  ref_x10_r <= ref_l11_w;  ref_x14_r <= ref_l16_w;
					ref_x03_r <= ref_l03_w;  ref_x07_r <= ref_l08_w;  ref_x11_r <= ref_l13_w;  ref_x15_r <= ref_l17_w;
					ref_x04_r <= ref_l04_w;  ref_x08_r <= ref_l09_w;  ref_x12_r <= ref_l14_w;  ref_x16_r <= ref_l19_w;

					ref_x17_r <= ref_l20_w;  ref_x21_r <= ref_l25_w;  ref_x25_r <= ref_l30_w;
					ref_x18_r <= ref_l21_w;  ref_x22_r <= ref_l26_w;  ref_x26_r <= ref_l31_w;
					ref_x19_r <= ref_l22_w;  ref_x23_r <= ref_l27_w;
					ref_x20_r <= ref_l24_w;  ref_x24_r <= ref_l29_w;
				end
				'd20:begin
					ref_x01_r <= ref_l01_w;  ref_x05_r <= ref_l07_w;  ref_x09_r <= ref_l13_w;  ref_x13_r <= ref_l19_w;
					ref_x02_r <= ref_l02_w;  ref_x06_r <= ref_l08_w;  ref_x10_r <= ref_l14_w;  ref_x14_r <= ref_l20_w;
					ref_x03_r <= ref_l04_w;  ref_x07_r <= ref_l10_w;  ref_x11_r <= ref_l16_w;  ref_x15_r <= ref_l22_w;
					ref_x04_r <= ref_l05_w;  ref_x08_r <= ref_l11_w;  ref_x12_r <= ref_l17_w;  ref_x16_r <= ref_l23_w;

					ref_x17_r <= ref_l25_w;  ref_x21_r <= ref_l31_w;
					ref_x18_r <= ref_l26_w;
					ref_x19_r <= ref_l28_w;
					ref_x20_r <= ref_l29_w;
				end
				'd21:begin
					ref_x01_r <= ref_l01_w;  ref_x05_r <= ref_l08_w;  ref_x09_r <= ref_l16_w;  ref_x13_r <= ref_l23_w;
					ref_x02_r <= ref_l03_w;  ref_x06_r <= ref_l10_w;  ref_x10_r <= ref_l18_w;  ref_x14_r <= ref_l25_w;
					ref_x03_r <= ref_l05_w;  ref_x07_r <= ref_l12_w;  ref_x11_r <= ref_l20_w;  ref_x15_r <= ref_l27_w;
					ref_x04_r <= ref_l07_w;  ref_x08_r <= ref_l14_w;  ref_x12_r <= ref_l22_w;  ref_x16_r <= ref_l29_w;

					ref_x17_r <= ref_l31_w;
				end
				'd22:begin
					ref_x01_r <= ref_l01_w;  ref_x05_r <= ref_l11_w;  ref_x09_r <= ref_l21_w;  ref_x13_r <= ref_l31_w;
					ref_x02_r <= ref_l04_w;  ref_x06_r <= ref_l14_w;  ref_x10_r <= ref_l24_w;
					ref_x03_r <= ref_l06_w;  ref_x07_r <= ref_l16_w;  ref_x11_r <= ref_l26_w;
					ref_x04_r <= ref_l09_w;  ref_x08_r <= ref_l19_w;  ref_x12_r <= ref_l29_w;
				end
				'd23:begin
					ref_x01_r <= ref_l03_w;  ref_x05_r <= ref_l17_w;  ref_x09_r <= ref_l31_w;
					ref_x02_r <= ref_l06_w;  ref_x06_r <= ref_l20_w;
					ref_x03_r <= ref_l10_w;  ref_x07_r <= ref_l24_w;
					ref_x04_r <= ref_l13_w;  ref_x08_r <= ref_l27_w;
				end
				'd24:begin
					ref_x01_r <= ref_l05_w;  ref_x05_r <= ref_l31_w;
					ref_x02_r <= ref_l12_w;
					ref_x03_r <= ref_l18_w;
					ref_x04_r <= ref_l25_w;
				end
				'd25:begin
					ref_x01_r <= ref_l15_w;
					ref_x02_r <= ref_l31_w;
				end
				default begin
					ref_x01_r <= ref_l00_w;  ref_x05_r <= ref_l04_w;  ref_x09_r <= ref_l08_w;  ref_x13_r <= ref_l12_w;
					ref_x02_r <= ref_l01_w;  ref_x06_r <= ref_l05_w;  ref_x10_r <= ref_l09_w;  ref_x14_r <= ref_l13_w;
					ref_x03_r <= ref_l02_w;  ref_x07_r <= ref_l06_w;  ref_x11_r <= ref_l10_w;  ref_x15_r <= ref_l14_w;
					ref_x04_r <= ref_l03_w;  ref_x08_r <= ref_l07_w;  ref_x12_r <= ref_l11_w;  ref_x16_r <= ref_l15_w;

					ref_x17_r <= ref_l16_w;  ref_x21_r <= ref_l20_w;  ref_x25_r <= ref_l24_w;  ref_x29_r <= ref_l28_w;
					ref_x18_r <= ref_l17_w;  ref_x22_r <= ref_l21_w;  ref_x26_r <= ref_l25_w;  ref_x30_r <= ref_l29_w;
					ref_x19_r <= ref_l18_w;  ref_x23_r <= ref_l22_w;  ref_x27_r <= ref_l26_w;  ref_x31_r <= ref_l30_w;
					ref_x20_r <= ref_l19_w;  ref_x24_r <= ref_l23_w;  ref_x28_r <= ref_l27_w;  ref_x32_r <= ref_l31_w;
				end
			endcase
		end
		else begin
			ref_01_r <= ref_l00_w;  ref_05_r <= ref_l04_w;  ref_09_r <= ref_l08_w;  ref_13_r <= ref_l12_w;
			ref_02_r <= ref_l01_w;  ref_06_r <= ref_l05_w;  ref_10_r <= ref_l09_w;  ref_14_r <= ref_l13_w;
			ref_03_r <= ref_l02_w;  ref_07_r <= ref_l06_w;  ref_11_r <= ref_l10_w;  ref_15_r <= ref_l14_w;
			ref_04_r <= ref_l03_w;  ref_08_r <= ref_l07_w;  ref_12_r <= ref_l11_w;  ref_16_r <= ref_l15_w;

			ref_17_r <= ref_l16_w;  ref_21_r <= ref_l20_w;  ref_25_r <= ref_l24_w;  ref_29_r <= ref_l28_w;
			ref_18_r <= ref_l17_w;  ref_22_r <= ref_l21_w;  ref_26_r <= ref_l25_w;  ref_30_r <= ref_l29_w;
			ref_19_r <= ref_l18_w;  ref_23_r <= ref_l22_w;  ref_27_r <= ref_l26_w;  ref_31_r <= ref_l30_w;
			ref_20_r <= ref_l19_w;  ref_24_r <= ref_l23_w;  ref_28_r <= ref_l27_w;  ref_32_r <= ref_l31_w;

			ref_33_r <= ref_l32_w;  ref_37_r <= ref_l36_w;  ref_41_r <= ref_l40_w;  ref_45_r <= ref_l44_w;
			ref_34_r <= ref_l33_w;  ref_38_r <= ref_l37_w;  ref_42_r <= ref_l41_w;  ref_46_r <= ref_l45_w;
			ref_35_r <= ref_l34_w;  ref_39_r <= ref_l38_w;  ref_43_r <= ref_l42_w;  ref_47_r <= ref_l46_w;
			ref_36_r <= ref_l35_w;  ref_40_r <= ref_l39_w;  ref_44_r <= ref_l43_w;  ref_48_r <= ref_l47_w;

			ref_49_r <= ref_l48_w;  ref_53_r <= ref_l52_w;  ref_57_r <= ref_l56_w;  ref_61_r <= ref_l60_w;
			ref_50_r <= ref_l49_w;  ref_54_r <= ref_l53_w;  ref_58_r <= ref_l57_w;  ref_62_r <= ref_l61_w;
			ref_51_r <= ref_l50_w;  ref_55_r <= ref_l54_w;  ref_59_r <= ref_l58_w;  ref_63_r <= ref_l62_w;
			ref_52_r <= ref_l51_w;  ref_56_r <= ref_l55_w;  ref_60_r <= ref_l59_w;  ref_64_r <= ref_l63_w;

			case (mode_i)
				'd17:begin
					ref_x01_r <= ref_t00_w;  ref_x05_r <= ref_t05_w;  ref_x09_r <= ref_t10_w;  ref_x13_r <= ref_t15_w;
					ref_x02_r <= ref_t01_w;  ref_x06_r <= ref_t06_w;  ref_x10_r <= ref_t11_w;  ref_x14_r <= ref_t16_w;
					ref_x03_r <= ref_t03_w;  ref_x07_r <= ref_t08_w;  ref_x11_r <= ref_t13_w;  ref_x15_r <= ref_t17_w;
					ref_x04_r <= ref_t04_w;  ref_x08_r <= ref_t09_w;  ref_x12_r <= ref_t14_w;  ref_x16_r <= ref_t19_w;

					ref_x17_r <= ref_t20_w;  ref_x21_r <= ref_t25_w;  ref_x25_r <= ref_t30_w;
					ref_x18_r <= ref_t21_w;  ref_x22_r <= ref_t26_w;  ref_x26_r <= ref_t31_w;
					ref_x19_r <= ref_t22_w;  ref_x23_r <= ref_t27_w;
					ref_x20_r <= ref_t24_w;  ref_x24_r <= ref_t29_w;
				end
				'd16:begin
					ref_x01_r <= ref_t01_w;  ref_x05_r <= ref_t07_w;  ref_x09_r <= ref_t13_w;  ref_x13_r <= ref_t19_w;
					ref_x02_r <= ref_t02_w;  ref_x06_r <= ref_t08_w;  ref_x10_r <= ref_t14_w;  ref_x14_r <= ref_t20_w;
					ref_x03_r <= ref_t04_w;  ref_x07_r <= ref_t10_w;  ref_x11_r <= ref_t16_w;  ref_x15_r <= ref_t22_w;
					ref_x04_r <= ref_t05_w;  ref_x08_r <= ref_t11_w;  ref_x12_r <= ref_t17_w;  ref_x16_r <= ref_t23_w;

					ref_x17_r <= ref_t25_w;  ref_x21_r <= ref_t31_w;
					ref_x18_r <= ref_t26_w;
					ref_x19_r <= ref_t28_w;
					ref_x20_r <= ref_t29_w;
				end
				'd15:begin
					ref_x01_r <= ref_t01_w;  ref_x05_r <= ref_t08_w;  ref_x09_r <= ref_t16_w;  ref_x13_r <= ref_t23_w;
					ref_x02_r <= ref_t03_w;  ref_x06_r <= ref_t10_w;  ref_x10_r <= ref_t18_w;  ref_x14_r <= ref_t25_w;
					ref_x03_r <= ref_t05_w;  ref_x07_r <= ref_t12_w;  ref_x11_r <= ref_t20_w;  ref_x15_r <= ref_t27_w;
					ref_x04_r <= ref_t07_w;  ref_x08_r <= ref_t14_w;  ref_x12_r <= ref_t22_w;  ref_x16_r <= ref_t29_w;

					ref_x17_r <= ref_t31_w;
				end
				'd14:begin
					ref_x01_r <= ref_t01_w;  ref_x05_r <= ref_t11_w;  ref_x09_r <= ref_t21_w;  ref_x13_r <= ref_t31_w;
					ref_x02_r <= ref_t04_w;  ref_x06_r <= ref_t14_w;  ref_x10_r <= ref_t24_w;
					ref_x03_r <= ref_t06_w;  ref_x07_r <= ref_t16_w;  ref_x11_r <= ref_t26_w;
					ref_x04_r <= ref_t09_w;  ref_x08_r <= ref_t19_w;  ref_x12_r <= ref_t29_w;
				end
				'd13:begin
					ref_x01_r <= ref_t03_w;  ref_x05_r <= ref_t17_w;  ref_x09_r <= ref_t31_w;
					ref_x02_r <= ref_t06_w;  ref_x06_r <= ref_t20_w;
					ref_x03_r <= ref_t10_w;  ref_x07_r <= ref_t24_w;
					ref_x04_r <= ref_t13_w;  ref_x08_r <= ref_t27_w;
				end
				'd12:begin
					ref_x01_r <= ref_t05_w;  ref_x05_r <= ref_t31_w;
					ref_x02_r <= ref_t12_w;
					ref_x03_r <= ref_t18_w;
					ref_x04_r <= ref_t25_w;
				end
				'd11:begin
					ref_x01_r <= ref_t15_w;
					ref_x02_r <= ref_t31_w;
				end
				default begin
					ref_x01_r <= ref_t00_w;  ref_x05_r <= ref_t04_w;  ref_x09_r <= ref_t08_w;  ref_x13_r <= ref_t12_w;
					ref_x02_r <= ref_t01_w;  ref_x06_r <= ref_t05_w;  ref_x10_r <= ref_t09_w;  ref_x14_r <= ref_t13_w;
					ref_x03_r <= ref_t02_w;  ref_x07_r <= ref_t06_w;  ref_x11_r <= ref_t10_w;  ref_x15_r <= ref_t14_w;
					ref_x04_r <= ref_t03_w;  ref_x08_r <= ref_t07_w;  ref_x12_r <= ref_t11_w;  ref_x16_r <= ref_t15_w;

					ref_x17_r <= ref_t16_w;  ref_x21_r <= ref_t20_w;  ref_x25_r <= ref_t24_w;  ref_x29_r <= ref_t28_w;
					ref_x18_r <= ref_t17_w;  ref_x22_r <= ref_t21_w;  ref_x26_r <= ref_t25_w;  ref_x30_r <= ref_t29_w;
					ref_x19_r <= ref_t18_w;  ref_x23_r <= ref_t22_w;  ref_x27_r <= ref_t26_w;  ref_x31_r <= ref_t30_w;
					ref_x20_r <= ref_t19_w;  ref_x24_r <= ref_t23_w;  ref_x28_r <= ref_t27_w;  ref_x32_r <= ref_t31_w;
				end
			endcase
		end
	end

end


//**********************************************************************************
//calculate the middle value for DC
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		mid_t0_r <= 'd0;	mid_l0_r <= 'd0;
		mid_t2_r <= 'd0;	mid_l2_r <= 'd0;
		mid_t3_r <= 'd0;	mid_l3_r <= 'd0;
		mid_t4_r <= 'd0;	mid_l4_r <= 'd0;
		mid_t5_r <= 'd0;	mid_l5_r <= 'd0;
	end
	else begin
		mid_t0_r <= ref_t00_i+ref_t01_i+ref_t02_i+ref_t03_i;

		mid_t2_r <= ref_t00_i+ref_t01_i+ref_t02_i+ref_t03_i+ref_t04_i+ref_t05_i+ref_t06_i+ref_t07_i;
		mid_t3_r <= ref_t08_i+ref_t09_i+ref_t10_i+ref_t11_i+ref_t12_i+ref_t13_i+ref_t14_i+ref_t15_i;
		mid_t4_r <= ref_t16_i+ref_t17_i+ref_t18_i+ref_t19_i+ref_t20_i+ref_t21_i+ref_t22_i+ref_t23_i;
		mid_t5_r <= ref_t24_i+ref_t25_i+ref_t26_i+ref_t27_i+ref_t28_i+ref_t29_i+ref_t30_i+ref_t31_i;

		mid_l0_r <= ref_l00_i+ref_l01_i+ref_l02_i+ref_l03_i;

		mid_l2_r <= ref_l00_i+ref_l01_i+ref_l02_i+ref_l03_i+ref_l04_i+ref_l05_i+ref_l06_i+ref_l07_i;
		mid_l3_r <= ref_l08_i+ref_l09_i+ref_l10_i+ref_l11_i+ref_l12_i+ref_l13_i+ref_l14_i+ref_l15_i;
		mid_l4_r <= ref_l16_i+ref_l17_i+ref_l18_i+ref_l19_i+ref_l20_i+ref_l21_i+ref_l22_i+ref_l23_i;
		mid_l5_r <= ref_l24_i+ref_l25_i+ref_l26_i+ref_l27_i+ref_l28_i+ref_l29_i+ref_l30_i+ref_l31_i;
	end
end




//stage1
//**********************************************************************************
//buffer ifact for Angular mode
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		ifact0 <= 'd0;
		ifact1 <= 'd0;
		ifact2 <= 'd0;
		ifact3 <= 'd0;
	end
	else begin
		ifact0 <= fact0[4:0];
		ifact1 <= fact1[4:0];
		ifact2 <= fact2[4:0];
		ifact3 <= fact3[4:0];
	end
end

//**********************************************************************************
//select the reference pixel for Angular mode
wire signed [6:0] ref_idx0_w,ref_idx1_w,ref_idx2_w,ref_idx3_w;

assign ref_idx0_w=delta_idx_r+idx0;
assign ref_idx1_w=delta_idx_r+idx1;
assign ref_idx2_w=delta_idx_r+idx2;
assign ref_idx3_w=delta_idx_r+idx3;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		ref_0_0<='d0;	ref_0_1<='d0;	ref_0_2<='d0;	ref_0_3<='d0;	ref_0_4<='d0;
	end
	else begin
		case (ref_idx0_w)
			-32 :begin ref_0_0<=ref_x31_r;	ref_0_1<=ref_x30_r;	ref_0_2<=ref_x29_r;	ref_0_3<=ref_x28_r;	ref_0_4<=ref_x27_r; end
			-31 :begin ref_0_0<=ref_x30_r;	ref_0_1<=ref_x29_r;	ref_0_2<=ref_x28_r;	ref_0_3<=ref_x27_r;	ref_0_4<=ref_x26_r; end
			-30 :begin ref_0_0<=ref_x29_r;	ref_0_1<=ref_x28_r;	ref_0_2<=ref_x27_r;	ref_0_3<=ref_x26_r;	ref_0_4<=ref_x25_r; end
			-29 :begin ref_0_0<=ref_x28_r;	ref_0_1<=ref_x27_r;	ref_0_2<=ref_x26_r;	ref_0_3<=ref_x25_r;	ref_0_4<=ref_x24_r; end
			-28 :begin ref_0_0<=ref_x27_r;	ref_0_1<=ref_x26_r;	ref_0_2<=ref_x25_r;	ref_0_3<=ref_x24_r;	ref_0_4<=ref_x23_r; end
			-27 :begin ref_0_0<=ref_x26_r;	ref_0_1<=ref_x25_r;	ref_0_2<=ref_x24_r;	ref_0_3<=ref_x23_r;	ref_0_4<=ref_x22_r; end
			-26 :begin ref_0_0<=ref_x25_r;	ref_0_1<=ref_x24_r;	ref_0_2<=ref_x23_r;	ref_0_3<=ref_x22_r;	ref_0_4<=ref_x21_r; end
			-25 :begin ref_0_0<=ref_x24_r;	ref_0_1<=ref_x23_r;	ref_0_2<=ref_x22_r;	ref_0_3<=ref_x21_r;	ref_0_4<=ref_x20_r; end
			-24 :begin ref_0_0<=ref_x23_r;	ref_0_1<=ref_x22_r;	ref_0_2<=ref_x21_r;	ref_0_3<=ref_x20_r;	ref_0_4<=ref_x19_r; end
			-23 :begin ref_0_0<=ref_x22_r;	ref_0_1<=ref_x21_r;	ref_0_2<=ref_x20_r;	ref_0_3<=ref_x19_r;	ref_0_4<=ref_x18_r; end
			-22 :begin ref_0_0<=ref_x21_r;	ref_0_1<=ref_x20_r;	ref_0_2<=ref_x19_r;	ref_0_3<=ref_x18_r;	ref_0_4<=ref_x17_r; end
			-21 :begin ref_0_0<=ref_x20_r;	ref_0_1<=ref_x19_r;	ref_0_2<=ref_x18_r;	ref_0_3<=ref_x17_r;	ref_0_4<=ref_x16_r; end
			-20 :begin ref_0_0<=ref_x19_r;	ref_0_1<=ref_x18_r;	ref_0_2<=ref_x17_r;	ref_0_3<=ref_x16_r;	ref_0_4<=ref_x15_r; end
			-19 :begin ref_0_0<=ref_x18_r;	ref_0_1<=ref_x17_r;	ref_0_2<=ref_x16_r;	ref_0_3<=ref_x15_r;	ref_0_4<=ref_x14_r; end
			-18 :begin ref_0_0<=ref_x17_r;	ref_0_1<=ref_x16_r;	ref_0_2<=ref_x15_r;	ref_0_3<=ref_x14_r;	ref_0_4<=ref_x13_r; end
			-17 :begin ref_0_0<=ref_x16_r;	ref_0_1<=ref_x15_r;	ref_0_2<=ref_x14_r;	ref_0_3<=ref_x13_r;	ref_0_4<=ref_x12_r; end
			-16 :begin ref_0_0<=ref_x15_r;	ref_0_1<=ref_x14_r;	ref_0_2<=ref_x13_r;	ref_0_3<=ref_x12_r;	ref_0_4<=ref_x11_r; end
			-15 :begin ref_0_0<=ref_x14_r;	ref_0_1<=ref_x13_r;	ref_0_2<=ref_x12_r;	ref_0_3<=ref_x11_r;	ref_0_4<=ref_x10_r; end
			-14 :begin ref_0_0<=ref_x13_r;	ref_0_1<=ref_x12_r;	ref_0_2<=ref_x11_r;	ref_0_3<=ref_x10_r;	ref_0_4<=ref_x09_r; end
			-13 :begin ref_0_0<=ref_x12_r;	ref_0_1<=ref_x11_r;	ref_0_2<=ref_x10_r;	ref_0_3<=ref_x09_r;	ref_0_4<=ref_x08_r; end
			-12 :begin ref_0_0<=ref_x11_r;	ref_0_1<=ref_x10_r;	ref_0_2<=ref_x09_r;	ref_0_3<=ref_x08_r;	ref_0_4<=ref_x07_r; end
			-11 :begin ref_0_0<=ref_x10_r;	ref_0_1<=ref_x09_r;	ref_0_2<=ref_x08_r;	ref_0_3<=ref_x07_r;	ref_0_4<=ref_x06_r; end
			-10 :begin ref_0_0<=ref_x09_r;	ref_0_1<=ref_x08_r;	ref_0_2<=ref_x07_r;	ref_0_3<=ref_x06_r;	ref_0_4<=ref_x05_r; end
			- 9 :begin ref_0_0<=ref_x08_r;	ref_0_1<=ref_x07_r;	ref_0_2<=ref_x06_r;	ref_0_3<=ref_x05_r;	ref_0_4<=ref_x04_r; end
			- 8 :begin ref_0_0<=ref_x07_r;	ref_0_1<=ref_x06_r;	ref_0_2<=ref_x05_r;	ref_0_3<=ref_x04_r;	ref_0_4<=ref_x03_r; end
			- 7 :begin ref_0_0<=ref_x06_r;	ref_0_1<=ref_x05_r;	ref_0_2<=ref_x04_r;	ref_0_3<=ref_x03_r;	ref_0_4<=ref_x02_r; end
			- 6 :begin ref_0_0<=ref_x05_r;	ref_0_1<=ref_x04_r;	ref_0_2<=ref_x03_r;	ref_0_3<=ref_x02_r;	ref_0_4<=ref_x01_r; end
			- 5 :begin ref_0_0<=ref_x04_r;	ref_0_1<=ref_x03_r;	ref_0_2<=ref_x02_r;	ref_0_3<=ref_x01_r;	ref_0_4<=ref_00_r; end
			- 4 :begin ref_0_0<=ref_x03_r;	ref_0_1<=ref_x02_r;	ref_0_2<=ref_x01_r;	ref_0_3<=ref_00_r;	ref_0_4<=ref_01_r; end
			- 3 :begin ref_0_0<=ref_x02_r;	ref_0_1<=ref_x01_r;	ref_0_2<=ref_00_r;	ref_0_3<=ref_01_r;	ref_0_4<=ref_02_r; end
			- 2 :begin ref_0_0<=ref_x01_r;	ref_0_1<=ref_00_r;	ref_0_2<=ref_01_r;	ref_0_3<=ref_02_r;	ref_0_4<=ref_03_r; end
			- 1 :begin ref_0_0<=ref_00_r;	ref_0_1<=ref_01_r;	ref_0_2<=ref_02_r;	ref_0_3<=ref_03_r;	ref_0_4<=ref_04_r; end
			  0 :begin ref_0_0<=ref_01_r;	ref_0_1<=ref_02_r;	ref_0_2<=ref_03_r;	ref_0_3<=ref_04_r;	ref_0_4<=ref_05_r; end
			  1 :begin ref_0_0<=ref_02_r;	ref_0_1<=ref_03_r;	ref_0_2<=ref_04_r;	ref_0_3<=ref_05_r;	ref_0_4<=ref_06_r; end
			  2 :begin ref_0_0<=ref_03_r;	ref_0_1<=ref_04_r;	ref_0_2<=ref_05_r;	ref_0_3<=ref_06_r;	ref_0_4<=ref_07_r; end
			  3 :begin ref_0_0<=ref_04_r;	ref_0_1<=ref_05_r;	ref_0_2<=ref_06_r;	ref_0_3<=ref_07_r;	ref_0_4<=ref_08_r; end
			  4 :begin ref_0_0<=ref_05_r;	ref_0_1<=ref_06_r;	ref_0_2<=ref_07_r;	ref_0_3<=ref_08_r;	ref_0_4<=ref_09_r; end
			  5 :begin ref_0_0<=ref_06_r;	ref_0_1<=ref_07_r;	ref_0_2<=ref_08_r;	ref_0_3<=ref_09_r;	ref_0_4<=ref_10_r; end
			  6 :begin ref_0_0<=ref_07_r;	ref_0_1<=ref_08_r;	ref_0_2<=ref_09_r;	ref_0_3<=ref_10_r;	ref_0_4<=ref_11_r; end
			  7 :begin ref_0_0<=ref_08_r;	ref_0_1<=ref_09_r;	ref_0_2<=ref_10_r;	ref_0_3<=ref_11_r;	ref_0_4<=ref_12_r; end
			  8 :begin ref_0_0<=ref_09_r;	ref_0_1<=ref_10_r;	ref_0_2<=ref_11_r;	ref_0_3<=ref_12_r;	ref_0_4<=ref_13_r; end
			  9 :begin ref_0_0<=ref_10_r;	ref_0_1<=ref_11_r;	ref_0_2<=ref_12_r;	ref_0_3<=ref_13_r;	ref_0_4<=ref_14_r; end
			 10 :begin ref_0_0<=ref_11_r;	ref_0_1<=ref_12_r;	ref_0_2<=ref_13_r;	ref_0_3<=ref_14_r;	ref_0_4<=ref_15_r; end
			 11 :begin ref_0_0<=ref_12_r;	ref_0_1<=ref_13_r;	ref_0_2<=ref_14_r;	ref_0_3<=ref_15_r;	ref_0_4<=ref_16_r; end
			 12 :begin ref_0_0<=ref_13_r;	ref_0_1<=ref_14_r;	ref_0_2<=ref_15_r;	ref_0_3<=ref_16_r;	ref_0_4<=ref_17_r; end
			 13 :begin ref_0_0<=ref_14_r;	ref_0_1<=ref_15_r;	ref_0_2<=ref_16_r;	ref_0_3<=ref_17_r;	ref_0_4<=ref_18_r; end
			 14 :begin ref_0_0<=ref_15_r;	ref_0_1<=ref_16_r;	ref_0_2<=ref_17_r;	ref_0_3<=ref_18_r;	ref_0_4<=ref_19_r; end
			 15 :begin ref_0_0<=ref_16_r;	ref_0_1<=ref_17_r;	ref_0_2<=ref_18_r;	ref_0_3<=ref_19_r;	ref_0_4<=ref_20_r; end
			 16 :begin ref_0_0<=ref_17_r;	ref_0_1<=ref_18_r;	ref_0_2<=ref_19_r;	ref_0_3<=ref_20_r;	ref_0_4<=ref_21_r; end
			 17 :begin ref_0_0<=ref_18_r;	ref_0_1<=ref_19_r;	ref_0_2<=ref_20_r;	ref_0_3<=ref_21_r;	ref_0_4<=ref_22_r; end
			 18 :begin ref_0_0<=ref_19_r;	ref_0_1<=ref_20_r;	ref_0_2<=ref_21_r;	ref_0_3<=ref_22_r;	ref_0_4<=ref_23_r; end
			 19 :begin ref_0_0<=ref_20_r;	ref_0_1<=ref_21_r;	ref_0_2<=ref_22_r;	ref_0_3<=ref_23_r;	ref_0_4<=ref_24_r; end
			 20 :begin ref_0_0<=ref_21_r;	ref_0_1<=ref_22_r;	ref_0_2<=ref_23_r;	ref_0_3<=ref_24_r;	ref_0_4<=ref_25_r; end
			 21 :begin ref_0_0<=ref_22_r;	ref_0_1<=ref_23_r;	ref_0_2<=ref_24_r;	ref_0_3<=ref_25_r;	ref_0_4<=ref_26_r; end
			 22 :begin ref_0_0<=ref_23_r;	ref_0_1<=ref_24_r;	ref_0_2<=ref_25_r;	ref_0_3<=ref_26_r;	ref_0_4<=ref_27_r; end
			 23 :begin ref_0_0<=ref_24_r;	ref_0_1<=ref_25_r;	ref_0_2<=ref_26_r;	ref_0_3<=ref_27_r;	ref_0_4<=ref_28_r; end
			 24 :begin ref_0_0<=ref_25_r;	ref_0_1<=ref_26_r;	ref_0_2<=ref_27_r;	ref_0_3<=ref_28_r;	ref_0_4<=ref_29_r; end
			 25 :begin ref_0_0<=ref_26_r;	ref_0_1<=ref_27_r;	ref_0_2<=ref_28_r;	ref_0_3<=ref_29_r;	ref_0_4<=ref_30_r; end
			 26 :begin ref_0_0<=ref_27_r;	ref_0_1<=ref_28_r;	ref_0_2<=ref_29_r;	ref_0_3<=ref_30_r;	ref_0_4<=ref_31_r; end
			 27 :begin ref_0_0<=ref_28_r;	ref_0_1<=ref_29_r;	ref_0_2<=ref_30_r;	ref_0_3<=ref_31_r;	ref_0_4<=ref_32_r; end
			 28 :begin ref_0_0<=ref_29_r;	ref_0_1<=ref_30_r;	ref_0_2<=ref_31_r;	ref_0_3<=ref_32_r;	ref_0_4<=ref_33_r; end
			 29 :begin ref_0_0<=ref_30_r;	ref_0_1<=ref_31_r;	ref_0_2<=ref_32_r;	ref_0_3<=ref_33_r;	ref_0_4<=ref_34_r; end
			 30 :begin ref_0_0<=ref_31_r;	ref_0_1<=ref_32_r;	ref_0_2<=ref_33_r;	ref_0_3<=ref_34_r;	ref_0_4<=ref_35_r; end
			 31 :begin ref_0_0<=ref_32_r;	ref_0_1<=ref_33_r;	ref_0_2<=ref_34_r;	ref_0_3<=ref_35_r;	ref_0_4<=ref_36_r; end
			 32 :begin ref_0_0<=ref_33_r;	ref_0_1<=ref_34_r;	ref_0_2<=ref_35_r;	ref_0_3<=ref_36_r;	ref_0_4<=ref_37_r; end
			 33 :begin ref_0_0<=ref_34_r;	ref_0_1<=ref_35_r;	ref_0_2<=ref_36_r;	ref_0_3<=ref_37_r;	ref_0_4<=ref_38_r; end
			 34 :begin ref_0_0<=ref_35_r;	ref_0_1<=ref_36_r;	ref_0_2<=ref_37_r;	ref_0_3<=ref_38_r;	ref_0_4<=ref_39_r; end
			 35 :begin ref_0_0<=ref_36_r;	ref_0_1<=ref_37_r;	ref_0_2<=ref_38_r;	ref_0_3<=ref_39_r;	ref_0_4<=ref_40_r; end
			 36 :begin ref_0_0<=ref_37_r;	ref_0_1<=ref_38_r;	ref_0_2<=ref_39_r;	ref_0_3<=ref_40_r;	ref_0_4<=ref_41_r; end
			 37 :begin ref_0_0<=ref_38_r;	ref_0_1<=ref_39_r;	ref_0_2<=ref_40_r;	ref_0_3<=ref_41_r;	ref_0_4<=ref_42_r; end
			 38 :begin ref_0_0<=ref_39_r;	ref_0_1<=ref_40_r;	ref_0_2<=ref_41_r;	ref_0_3<=ref_42_r;	ref_0_4<=ref_43_r; end
			 39 :begin ref_0_0<=ref_40_r;	ref_0_1<=ref_41_r;	ref_0_2<=ref_42_r;	ref_0_3<=ref_43_r;	ref_0_4<=ref_44_r; end
			 40 :begin ref_0_0<=ref_41_r;	ref_0_1<=ref_42_r;	ref_0_2<=ref_43_r;	ref_0_3<=ref_44_r;	ref_0_4<=ref_45_r; end
			 41 :begin ref_0_0<=ref_42_r;	ref_0_1<=ref_43_r;	ref_0_2<=ref_44_r;	ref_0_3<=ref_45_r;	ref_0_4<=ref_46_r; end
			 42 :begin ref_0_0<=ref_43_r;	ref_0_1<=ref_44_r;	ref_0_2<=ref_45_r;	ref_0_3<=ref_46_r;	ref_0_4<=ref_47_r; end
			 43 :begin ref_0_0<=ref_44_r;	ref_0_1<=ref_45_r;	ref_0_2<=ref_46_r;	ref_0_3<=ref_47_r;	ref_0_4<=ref_48_r; end
			 44 :begin ref_0_0<=ref_45_r;	ref_0_1<=ref_46_r;	ref_0_2<=ref_47_r;	ref_0_3<=ref_48_r;	ref_0_4<=ref_49_r; end
			 45 :begin ref_0_0<=ref_46_r;	ref_0_1<=ref_47_r;	ref_0_2<=ref_48_r;	ref_0_3<=ref_49_r;	ref_0_4<=ref_50_r; end
			 46 :begin ref_0_0<=ref_47_r;	ref_0_1<=ref_48_r;	ref_0_2<=ref_49_r;	ref_0_3<=ref_50_r;	ref_0_4<=ref_51_r; end
			 47 :begin ref_0_0<=ref_48_r;	ref_0_1<=ref_49_r;	ref_0_2<=ref_50_r;	ref_0_3<=ref_51_r;	ref_0_4<=ref_52_r; end
			 48 :begin ref_0_0<=ref_49_r;	ref_0_1<=ref_50_r;	ref_0_2<=ref_51_r;	ref_0_3<=ref_52_r;	ref_0_4<=ref_53_r; end
			 49 :begin ref_0_0<=ref_50_r;	ref_0_1<=ref_51_r;	ref_0_2<=ref_52_r;	ref_0_3<=ref_53_r;	ref_0_4<=ref_54_r; end
			 50 :begin ref_0_0<=ref_51_r;	ref_0_1<=ref_52_r;	ref_0_2<=ref_53_r;	ref_0_3<=ref_54_r;	ref_0_4<=ref_55_r; end
			 51 :begin ref_0_0<=ref_52_r;	ref_0_1<=ref_53_r;	ref_0_2<=ref_54_r;	ref_0_3<=ref_55_r;	ref_0_4<=ref_56_r; end
			 52 :begin ref_0_0<=ref_53_r;	ref_0_1<=ref_54_r;	ref_0_2<=ref_55_r;	ref_0_3<=ref_56_r;	ref_0_4<=ref_57_r; end
			 53 :begin ref_0_0<=ref_54_r;	ref_0_1<=ref_55_r;	ref_0_2<=ref_56_r;	ref_0_3<=ref_57_r;	ref_0_4<=ref_58_r; end
			 54 :begin ref_0_0<=ref_55_r;	ref_0_1<=ref_56_r;	ref_0_2<=ref_57_r;	ref_0_3<=ref_58_r;	ref_0_4<=ref_59_r; end
			 55 :begin ref_0_0<=ref_56_r;	ref_0_1<=ref_57_r;	ref_0_2<=ref_58_r;	ref_0_3<=ref_59_r;	ref_0_4<=ref_60_r; end
			 56 :begin ref_0_0<=ref_57_r;	ref_0_1<=ref_58_r;	ref_0_2<=ref_59_r;	ref_0_3<=ref_60_r;	ref_0_4<=ref_61_r; end
			 57 :begin ref_0_0<=ref_58_r;	ref_0_1<=ref_59_r;	ref_0_2<=ref_60_r;	ref_0_3<=ref_61_r;	ref_0_4<=ref_62_r; end
			 58 :begin ref_0_0<=ref_59_r;	ref_0_1<=ref_60_r;	ref_0_2<=ref_61_r;	ref_0_3<=ref_62_r;	ref_0_4<=ref_63_r; end
			 59 :begin ref_0_0<=ref_60_r;	ref_0_1<=ref_61_r;	ref_0_2<=ref_62_r;	ref_0_3<=ref_63_r;	ref_0_4<=ref_64_r; end
			 60 :begin ref_0_0<=ref_61_r;	ref_0_1<=ref_62_r;	ref_0_2<=ref_63_r;	ref_0_3<=ref_64_r;	ref_0_4<=ref_64_r; end
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		ref_1_0<='d0;	ref_1_1<='d0;	ref_1_2<='d0;	ref_1_3<='d0;	ref_1_4<='d0;
	end
	else begin
		case (ref_idx1_w)
			-32 :begin ref_1_0<=ref_x31_r;	ref_1_1<=ref_x30_r;	ref_1_2<=ref_x29_r;	ref_1_3<=ref_x28_r;	ref_1_4<=ref_x27_r; end
			-31 :begin ref_1_0<=ref_x30_r;	ref_1_1<=ref_x29_r;	ref_1_2<=ref_x28_r;	ref_1_3<=ref_x27_r;	ref_1_4<=ref_x26_r; end
			-30 :begin ref_1_0<=ref_x29_r;	ref_1_1<=ref_x28_r;	ref_1_2<=ref_x27_r;	ref_1_3<=ref_x26_r;	ref_1_4<=ref_x25_r; end
			-29 :begin ref_1_0<=ref_x28_r;	ref_1_1<=ref_x27_r;	ref_1_2<=ref_x26_r;	ref_1_3<=ref_x25_r;	ref_1_4<=ref_x24_r; end
			-28 :begin ref_1_0<=ref_x27_r;	ref_1_1<=ref_x26_r;	ref_1_2<=ref_x25_r;	ref_1_3<=ref_x24_r;	ref_1_4<=ref_x23_r; end
			-27 :begin ref_1_0<=ref_x26_r;	ref_1_1<=ref_x25_r;	ref_1_2<=ref_x24_r;	ref_1_3<=ref_x23_r;	ref_1_4<=ref_x22_r; end
			-26 :begin ref_1_0<=ref_x25_r;	ref_1_1<=ref_x24_r;	ref_1_2<=ref_x23_r;	ref_1_3<=ref_x22_r;	ref_1_4<=ref_x21_r; end
			-25 :begin ref_1_0<=ref_x24_r;	ref_1_1<=ref_x23_r;	ref_1_2<=ref_x22_r;	ref_1_3<=ref_x21_r;	ref_1_4<=ref_x20_r; end
			-24 :begin ref_1_0<=ref_x23_r;	ref_1_1<=ref_x22_r;	ref_1_2<=ref_x21_r;	ref_1_3<=ref_x20_r;	ref_1_4<=ref_x19_r; end
			-23 :begin ref_1_0<=ref_x22_r;	ref_1_1<=ref_x21_r;	ref_1_2<=ref_x20_r;	ref_1_3<=ref_x19_r;	ref_1_4<=ref_x18_r; end
			-22 :begin ref_1_0<=ref_x21_r;	ref_1_1<=ref_x20_r;	ref_1_2<=ref_x19_r;	ref_1_3<=ref_x18_r;	ref_1_4<=ref_x17_r; end
			-21 :begin ref_1_0<=ref_x20_r;	ref_1_1<=ref_x19_r;	ref_1_2<=ref_x18_r;	ref_1_3<=ref_x17_r;	ref_1_4<=ref_x16_r; end
			-20 :begin ref_1_0<=ref_x19_r;	ref_1_1<=ref_x18_r;	ref_1_2<=ref_x17_r;	ref_1_3<=ref_x16_r;	ref_1_4<=ref_x15_r; end
			-19 :begin ref_1_0<=ref_x18_r;	ref_1_1<=ref_x17_r;	ref_1_2<=ref_x16_r;	ref_1_3<=ref_x15_r;	ref_1_4<=ref_x14_r; end
			-18 :begin ref_1_0<=ref_x17_r;	ref_1_1<=ref_x16_r;	ref_1_2<=ref_x15_r;	ref_1_3<=ref_x14_r;	ref_1_4<=ref_x13_r; end
			-17 :begin ref_1_0<=ref_x16_r;	ref_1_1<=ref_x15_r;	ref_1_2<=ref_x14_r;	ref_1_3<=ref_x13_r;	ref_1_4<=ref_x12_r; end
			-16 :begin ref_1_0<=ref_x15_r;	ref_1_1<=ref_x14_r;	ref_1_2<=ref_x13_r;	ref_1_3<=ref_x12_r;	ref_1_4<=ref_x11_r; end
			-15 :begin ref_1_0<=ref_x14_r;	ref_1_1<=ref_x13_r;	ref_1_2<=ref_x12_r;	ref_1_3<=ref_x11_r;	ref_1_4<=ref_x10_r; end
			-14 :begin ref_1_0<=ref_x13_r;	ref_1_1<=ref_x12_r;	ref_1_2<=ref_x11_r;	ref_1_3<=ref_x10_r;	ref_1_4<=ref_x09_r; end
			-13 :begin ref_1_0<=ref_x12_r;	ref_1_1<=ref_x11_r;	ref_1_2<=ref_x10_r;	ref_1_3<=ref_x09_r;	ref_1_4<=ref_x08_r; end
			-12 :begin ref_1_0<=ref_x11_r;	ref_1_1<=ref_x10_r;	ref_1_2<=ref_x09_r;	ref_1_3<=ref_x08_r;	ref_1_4<=ref_x07_r; end
			-11 :begin ref_1_0<=ref_x10_r;	ref_1_1<=ref_x09_r;	ref_1_2<=ref_x08_r;	ref_1_3<=ref_x07_r;	ref_1_4<=ref_x06_r; end
			-10 :begin ref_1_0<=ref_x09_r;	ref_1_1<=ref_x08_r;	ref_1_2<=ref_x07_r;	ref_1_3<=ref_x06_r;	ref_1_4<=ref_x05_r; end
			- 9 :begin ref_1_0<=ref_x08_r;	ref_1_1<=ref_x07_r;	ref_1_2<=ref_x06_r;	ref_1_3<=ref_x05_r;	ref_1_4<=ref_x04_r; end
			- 8 :begin ref_1_0<=ref_x07_r;	ref_1_1<=ref_x06_r;	ref_1_2<=ref_x05_r;	ref_1_3<=ref_x04_r;	ref_1_4<=ref_x03_r; end
			- 7 :begin ref_1_0<=ref_x06_r;	ref_1_1<=ref_x05_r;	ref_1_2<=ref_x04_r;	ref_1_3<=ref_x03_r;	ref_1_4<=ref_x02_r; end
			- 6 :begin ref_1_0<=ref_x05_r;	ref_1_1<=ref_x04_r;	ref_1_2<=ref_x03_r;	ref_1_3<=ref_x02_r;	ref_1_4<=ref_x01_r; end
			- 5 :begin ref_1_0<=ref_x04_r;	ref_1_1<=ref_x03_r;	ref_1_2<=ref_x02_r;	ref_1_3<=ref_x01_r;	ref_1_4<=ref_00_r; end
			- 4 :begin ref_1_0<=ref_x03_r;	ref_1_1<=ref_x02_r;	ref_1_2<=ref_x01_r;	ref_1_3<=ref_00_r;	ref_1_4<=ref_01_r; end
			- 3 :begin ref_1_0<=ref_x02_r;	ref_1_1<=ref_x01_r;	ref_1_2<=ref_00_r;	ref_1_3<=ref_01_r;	ref_1_4<=ref_02_r; end
			- 2 :begin ref_1_0<=ref_x01_r;	ref_1_1<=ref_00_r;	ref_1_2<=ref_01_r;	ref_1_3<=ref_02_r;	ref_1_4<=ref_03_r; end
			- 1 :begin ref_1_0<=ref_00_r;	ref_1_1<=ref_01_r;	ref_1_2<=ref_02_r;	ref_1_3<=ref_03_r;	ref_1_4<=ref_04_r; end
			  0 :begin ref_1_0<=ref_01_r;	ref_1_1<=ref_02_r;	ref_1_2<=ref_03_r;	ref_1_3<=ref_04_r;	ref_1_4<=ref_05_r; end
			  1 :begin ref_1_0<=ref_02_r;	ref_1_1<=ref_03_r;	ref_1_2<=ref_04_r;	ref_1_3<=ref_05_r;	ref_1_4<=ref_06_r; end
			  2 :begin ref_1_0<=ref_03_r;	ref_1_1<=ref_04_r;	ref_1_2<=ref_05_r;	ref_1_3<=ref_06_r;	ref_1_4<=ref_07_r; end
			  3 :begin ref_1_0<=ref_04_r;	ref_1_1<=ref_05_r;	ref_1_2<=ref_06_r;	ref_1_3<=ref_07_r;	ref_1_4<=ref_08_r; end
			  4 :begin ref_1_0<=ref_05_r;	ref_1_1<=ref_06_r;	ref_1_2<=ref_07_r;	ref_1_3<=ref_08_r;	ref_1_4<=ref_09_r; end
			  5 :begin ref_1_0<=ref_06_r;	ref_1_1<=ref_07_r;	ref_1_2<=ref_08_r;	ref_1_3<=ref_09_r;	ref_1_4<=ref_10_r; end
			  6 :begin ref_1_0<=ref_07_r;	ref_1_1<=ref_08_r;	ref_1_2<=ref_09_r;	ref_1_3<=ref_10_r;	ref_1_4<=ref_11_r; end
			  7 :begin ref_1_0<=ref_08_r;	ref_1_1<=ref_09_r;	ref_1_2<=ref_10_r;	ref_1_3<=ref_11_r;	ref_1_4<=ref_12_r; end
			  8 :begin ref_1_0<=ref_09_r;	ref_1_1<=ref_10_r;	ref_1_2<=ref_11_r;	ref_1_3<=ref_12_r;	ref_1_4<=ref_13_r; end
			  9 :begin ref_1_0<=ref_10_r;	ref_1_1<=ref_11_r;	ref_1_2<=ref_12_r;	ref_1_3<=ref_13_r;	ref_1_4<=ref_14_r; end
			 10 :begin ref_1_0<=ref_11_r;	ref_1_1<=ref_12_r;	ref_1_2<=ref_13_r;	ref_1_3<=ref_14_r;	ref_1_4<=ref_15_r; end
			 11 :begin ref_1_0<=ref_12_r;	ref_1_1<=ref_13_r;	ref_1_2<=ref_14_r;	ref_1_3<=ref_15_r;	ref_1_4<=ref_16_r; end
			 12 :begin ref_1_0<=ref_13_r;	ref_1_1<=ref_14_r;	ref_1_2<=ref_15_r;	ref_1_3<=ref_16_r;	ref_1_4<=ref_17_r; end
			 13 :begin ref_1_0<=ref_14_r;	ref_1_1<=ref_15_r;	ref_1_2<=ref_16_r;	ref_1_3<=ref_17_r;	ref_1_4<=ref_18_r; end
			 14 :begin ref_1_0<=ref_15_r;	ref_1_1<=ref_16_r;	ref_1_2<=ref_17_r;	ref_1_3<=ref_18_r;	ref_1_4<=ref_19_r; end
			 15 :begin ref_1_0<=ref_16_r;	ref_1_1<=ref_17_r;	ref_1_2<=ref_18_r;	ref_1_3<=ref_19_r;	ref_1_4<=ref_20_r; end
			 16 :begin ref_1_0<=ref_17_r;	ref_1_1<=ref_18_r;	ref_1_2<=ref_19_r;	ref_1_3<=ref_20_r;	ref_1_4<=ref_21_r; end
			 17 :begin ref_1_0<=ref_18_r;	ref_1_1<=ref_19_r;	ref_1_2<=ref_20_r;	ref_1_3<=ref_21_r;	ref_1_4<=ref_22_r; end
			 18 :begin ref_1_0<=ref_19_r;	ref_1_1<=ref_20_r;	ref_1_2<=ref_21_r;	ref_1_3<=ref_22_r;	ref_1_4<=ref_23_r; end
			 19 :begin ref_1_0<=ref_20_r;	ref_1_1<=ref_21_r;	ref_1_2<=ref_22_r;	ref_1_3<=ref_23_r;	ref_1_4<=ref_24_r; end
			 20 :begin ref_1_0<=ref_21_r;	ref_1_1<=ref_22_r;	ref_1_2<=ref_23_r;	ref_1_3<=ref_24_r;	ref_1_4<=ref_25_r; end
			 21 :begin ref_1_0<=ref_22_r;	ref_1_1<=ref_23_r;	ref_1_2<=ref_24_r;	ref_1_3<=ref_25_r;	ref_1_4<=ref_26_r; end
			 22 :begin ref_1_0<=ref_23_r;	ref_1_1<=ref_24_r;	ref_1_2<=ref_25_r;	ref_1_3<=ref_26_r;	ref_1_4<=ref_27_r; end
			 23 :begin ref_1_0<=ref_24_r;	ref_1_1<=ref_25_r;	ref_1_2<=ref_26_r;	ref_1_3<=ref_27_r;	ref_1_4<=ref_28_r; end
			 24 :begin ref_1_0<=ref_25_r;	ref_1_1<=ref_26_r;	ref_1_2<=ref_27_r;	ref_1_3<=ref_28_r;	ref_1_4<=ref_29_r; end
			 25 :begin ref_1_0<=ref_26_r;	ref_1_1<=ref_27_r;	ref_1_2<=ref_28_r;	ref_1_3<=ref_29_r;	ref_1_4<=ref_30_r; end
			 26 :begin ref_1_0<=ref_27_r;	ref_1_1<=ref_28_r;	ref_1_2<=ref_29_r;	ref_1_3<=ref_30_r;	ref_1_4<=ref_31_r; end
			 27 :begin ref_1_0<=ref_28_r;	ref_1_1<=ref_29_r;	ref_1_2<=ref_30_r;	ref_1_3<=ref_31_r;	ref_1_4<=ref_32_r; end
			 28 :begin ref_1_0<=ref_29_r;	ref_1_1<=ref_30_r;	ref_1_2<=ref_31_r;	ref_1_3<=ref_32_r;	ref_1_4<=ref_33_r; end
			 29 :begin ref_1_0<=ref_30_r;	ref_1_1<=ref_31_r;	ref_1_2<=ref_32_r;	ref_1_3<=ref_33_r;	ref_1_4<=ref_34_r; end
			 30 :begin ref_1_0<=ref_31_r;	ref_1_1<=ref_32_r;	ref_1_2<=ref_33_r;	ref_1_3<=ref_34_r;	ref_1_4<=ref_35_r; end
			 31 :begin ref_1_0<=ref_32_r;	ref_1_1<=ref_33_r;	ref_1_2<=ref_34_r;	ref_1_3<=ref_35_r;	ref_1_4<=ref_36_r; end
			 32 :begin ref_1_0<=ref_33_r;	ref_1_1<=ref_34_r;	ref_1_2<=ref_35_r;	ref_1_3<=ref_36_r;	ref_1_4<=ref_37_r; end
			 33 :begin ref_1_0<=ref_34_r;	ref_1_1<=ref_35_r;	ref_1_2<=ref_36_r;	ref_1_3<=ref_37_r;	ref_1_4<=ref_38_r; end
			 34 :begin ref_1_0<=ref_35_r;	ref_1_1<=ref_36_r;	ref_1_2<=ref_37_r;	ref_1_3<=ref_38_r;	ref_1_4<=ref_39_r; end
			 35 :begin ref_1_0<=ref_36_r;	ref_1_1<=ref_37_r;	ref_1_2<=ref_38_r;	ref_1_3<=ref_39_r;	ref_1_4<=ref_40_r; end
			 36 :begin ref_1_0<=ref_37_r;	ref_1_1<=ref_38_r;	ref_1_2<=ref_39_r;	ref_1_3<=ref_40_r;	ref_1_4<=ref_41_r; end
			 37 :begin ref_1_0<=ref_38_r;	ref_1_1<=ref_39_r;	ref_1_2<=ref_40_r;	ref_1_3<=ref_41_r;	ref_1_4<=ref_42_r; end
			 38 :begin ref_1_0<=ref_39_r;	ref_1_1<=ref_40_r;	ref_1_2<=ref_41_r;	ref_1_3<=ref_42_r;	ref_1_4<=ref_43_r; end
			 39 :begin ref_1_0<=ref_40_r;	ref_1_1<=ref_41_r;	ref_1_2<=ref_42_r;	ref_1_3<=ref_43_r;	ref_1_4<=ref_44_r; end
			 40 :begin ref_1_0<=ref_41_r;	ref_1_1<=ref_42_r;	ref_1_2<=ref_43_r;	ref_1_3<=ref_44_r;	ref_1_4<=ref_45_r; end
			 41 :begin ref_1_0<=ref_42_r;	ref_1_1<=ref_43_r;	ref_1_2<=ref_44_r;	ref_1_3<=ref_45_r;	ref_1_4<=ref_46_r; end
			 42 :begin ref_1_0<=ref_43_r;	ref_1_1<=ref_44_r;	ref_1_2<=ref_45_r;	ref_1_3<=ref_46_r;	ref_1_4<=ref_47_r; end
			 43 :begin ref_1_0<=ref_44_r;	ref_1_1<=ref_45_r;	ref_1_2<=ref_46_r;	ref_1_3<=ref_47_r;	ref_1_4<=ref_48_r; end
			 44 :begin ref_1_0<=ref_45_r;	ref_1_1<=ref_46_r;	ref_1_2<=ref_47_r;	ref_1_3<=ref_48_r;	ref_1_4<=ref_49_r; end
			 45 :begin ref_1_0<=ref_46_r;	ref_1_1<=ref_47_r;	ref_1_2<=ref_48_r;	ref_1_3<=ref_49_r;	ref_1_4<=ref_50_r; end
			 46 :begin ref_1_0<=ref_47_r;	ref_1_1<=ref_48_r;	ref_1_2<=ref_49_r;	ref_1_3<=ref_50_r;	ref_1_4<=ref_51_r; end
			 47 :begin ref_1_0<=ref_48_r;	ref_1_1<=ref_49_r;	ref_1_2<=ref_50_r;	ref_1_3<=ref_51_r;	ref_1_4<=ref_52_r; end
			 48 :begin ref_1_0<=ref_49_r;	ref_1_1<=ref_50_r;	ref_1_2<=ref_51_r;	ref_1_3<=ref_52_r;	ref_1_4<=ref_53_r; end
			 49 :begin ref_1_0<=ref_50_r;	ref_1_1<=ref_51_r;	ref_1_2<=ref_52_r;	ref_1_3<=ref_53_r;	ref_1_4<=ref_54_r; end
			 50 :begin ref_1_0<=ref_51_r;	ref_1_1<=ref_52_r;	ref_1_2<=ref_53_r;	ref_1_3<=ref_54_r;	ref_1_4<=ref_55_r; end
			 51 :begin ref_1_0<=ref_52_r;	ref_1_1<=ref_53_r;	ref_1_2<=ref_54_r;	ref_1_3<=ref_55_r;	ref_1_4<=ref_56_r; end
			 52 :begin ref_1_0<=ref_53_r;	ref_1_1<=ref_54_r;	ref_1_2<=ref_55_r;	ref_1_3<=ref_56_r;	ref_1_4<=ref_57_r; end
			 53 :begin ref_1_0<=ref_54_r;	ref_1_1<=ref_55_r;	ref_1_2<=ref_56_r;	ref_1_3<=ref_57_r;	ref_1_4<=ref_58_r; end
			 54 :begin ref_1_0<=ref_55_r;	ref_1_1<=ref_56_r;	ref_1_2<=ref_57_r;	ref_1_3<=ref_58_r;	ref_1_4<=ref_59_r; end
			 55 :begin ref_1_0<=ref_56_r;	ref_1_1<=ref_57_r;	ref_1_2<=ref_58_r;	ref_1_3<=ref_59_r;	ref_1_4<=ref_60_r; end
			 56 :begin ref_1_0<=ref_57_r;	ref_1_1<=ref_58_r;	ref_1_2<=ref_59_r;	ref_1_3<=ref_60_r;	ref_1_4<=ref_61_r; end
			 57 :begin ref_1_0<=ref_58_r;	ref_1_1<=ref_59_r;	ref_1_2<=ref_60_r;	ref_1_3<=ref_61_r;	ref_1_4<=ref_62_r; end
			 58 :begin ref_1_0<=ref_59_r;	ref_1_1<=ref_60_r;	ref_1_2<=ref_61_r;	ref_1_3<=ref_62_r;	ref_1_4<=ref_63_r; end
			 59 :begin ref_1_0<=ref_60_r;	ref_1_1<=ref_61_r;	ref_1_2<=ref_62_r;	ref_1_3<=ref_63_r;	ref_1_4<=ref_64_r; end
			 60 :begin ref_1_0<=ref_61_r;	ref_1_1<=ref_62_r;	ref_1_2<=ref_63_r;	ref_1_3<=ref_64_r;	ref_1_4<=ref_64_r; end
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		ref_2_0<='d0;	ref_2_1<='d0;	ref_2_2<='d0;	ref_2_3<='d0;	ref_2_4<='d0;
	end
	else begin
		case (ref_idx2_w)
			-32 :begin ref_2_0<=ref_x31_r;	ref_2_1<=ref_x30_r;	ref_2_2<=ref_x29_r;	ref_2_3<=ref_x28_r;	ref_2_4<=ref_x27_r; end
			-31 :begin ref_2_0<=ref_x30_r;	ref_2_1<=ref_x29_r;	ref_2_2<=ref_x28_r;	ref_2_3<=ref_x27_r;	ref_2_4<=ref_x26_r; end
			-30 :begin ref_2_0<=ref_x29_r;	ref_2_1<=ref_x28_r;	ref_2_2<=ref_x27_r;	ref_2_3<=ref_x26_r;	ref_2_4<=ref_x25_r; end
			-29 :begin ref_2_0<=ref_x28_r;	ref_2_1<=ref_x27_r;	ref_2_2<=ref_x26_r;	ref_2_3<=ref_x25_r;	ref_2_4<=ref_x24_r; end
			-28 :begin ref_2_0<=ref_x27_r;	ref_2_1<=ref_x26_r;	ref_2_2<=ref_x25_r;	ref_2_3<=ref_x24_r;	ref_2_4<=ref_x23_r; end
			-27 :begin ref_2_0<=ref_x26_r;	ref_2_1<=ref_x25_r;	ref_2_2<=ref_x24_r;	ref_2_3<=ref_x23_r;	ref_2_4<=ref_x22_r; end
			-26 :begin ref_2_0<=ref_x25_r;	ref_2_1<=ref_x24_r;	ref_2_2<=ref_x23_r;	ref_2_3<=ref_x22_r;	ref_2_4<=ref_x21_r; end
			-25 :begin ref_2_0<=ref_x24_r;	ref_2_1<=ref_x23_r;	ref_2_2<=ref_x22_r;	ref_2_3<=ref_x21_r;	ref_2_4<=ref_x20_r; end
			-24 :begin ref_2_0<=ref_x23_r;	ref_2_1<=ref_x22_r;	ref_2_2<=ref_x21_r;	ref_2_3<=ref_x20_r;	ref_2_4<=ref_x19_r; end
			-23 :begin ref_2_0<=ref_x22_r;	ref_2_1<=ref_x21_r;	ref_2_2<=ref_x20_r;	ref_2_3<=ref_x19_r;	ref_2_4<=ref_x18_r; end
			-22 :begin ref_2_0<=ref_x21_r;	ref_2_1<=ref_x20_r;	ref_2_2<=ref_x19_r;	ref_2_3<=ref_x18_r;	ref_2_4<=ref_x17_r; end
			-21 :begin ref_2_0<=ref_x20_r;	ref_2_1<=ref_x19_r;	ref_2_2<=ref_x18_r;	ref_2_3<=ref_x17_r;	ref_2_4<=ref_x16_r; end
			-20 :begin ref_2_0<=ref_x19_r;	ref_2_1<=ref_x18_r;	ref_2_2<=ref_x17_r;	ref_2_3<=ref_x16_r;	ref_2_4<=ref_x15_r; end
			-19 :begin ref_2_0<=ref_x18_r;	ref_2_1<=ref_x17_r;	ref_2_2<=ref_x16_r;	ref_2_3<=ref_x15_r;	ref_2_4<=ref_x14_r; end
			-18 :begin ref_2_0<=ref_x17_r;	ref_2_1<=ref_x16_r;	ref_2_2<=ref_x15_r;	ref_2_3<=ref_x14_r;	ref_2_4<=ref_x13_r; end
			-17 :begin ref_2_0<=ref_x16_r;	ref_2_1<=ref_x15_r;	ref_2_2<=ref_x14_r;	ref_2_3<=ref_x13_r;	ref_2_4<=ref_x12_r; end
			-16 :begin ref_2_0<=ref_x15_r;	ref_2_1<=ref_x14_r;	ref_2_2<=ref_x13_r;	ref_2_3<=ref_x12_r;	ref_2_4<=ref_x11_r; end
			-15 :begin ref_2_0<=ref_x14_r;	ref_2_1<=ref_x13_r;	ref_2_2<=ref_x12_r;	ref_2_3<=ref_x11_r;	ref_2_4<=ref_x10_r; end
			-14 :begin ref_2_0<=ref_x13_r;	ref_2_1<=ref_x12_r;	ref_2_2<=ref_x11_r;	ref_2_3<=ref_x10_r;	ref_2_4<=ref_x09_r; end
			-13 :begin ref_2_0<=ref_x12_r;	ref_2_1<=ref_x11_r;	ref_2_2<=ref_x10_r;	ref_2_3<=ref_x09_r;	ref_2_4<=ref_x08_r; end
			-12 :begin ref_2_0<=ref_x11_r;	ref_2_1<=ref_x10_r;	ref_2_2<=ref_x09_r;	ref_2_3<=ref_x08_r;	ref_2_4<=ref_x07_r; end
			-11 :begin ref_2_0<=ref_x10_r;	ref_2_1<=ref_x09_r;	ref_2_2<=ref_x08_r;	ref_2_3<=ref_x07_r;	ref_2_4<=ref_x06_r; end
			-10 :begin ref_2_0<=ref_x09_r;	ref_2_1<=ref_x08_r;	ref_2_2<=ref_x07_r;	ref_2_3<=ref_x06_r;	ref_2_4<=ref_x05_r; end
			- 9 :begin ref_2_0<=ref_x08_r;	ref_2_1<=ref_x07_r;	ref_2_2<=ref_x06_r;	ref_2_3<=ref_x05_r;	ref_2_4<=ref_x04_r; end
			- 8 :begin ref_2_0<=ref_x07_r;	ref_2_1<=ref_x06_r;	ref_2_2<=ref_x05_r;	ref_2_3<=ref_x04_r;	ref_2_4<=ref_x03_r; end
			- 7 :begin ref_2_0<=ref_x06_r;	ref_2_1<=ref_x05_r;	ref_2_2<=ref_x04_r;	ref_2_3<=ref_x03_r;	ref_2_4<=ref_x02_r; end
			- 6 :begin ref_2_0<=ref_x05_r;	ref_2_1<=ref_x04_r;	ref_2_2<=ref_x03_r;	ref_2_3<=ref_x02_r;	ref_2_4<=ref_x01_r; end
			- 5 :begin ref_2_0<=ref_x04_r;	ref_2_1<=ref_x03_r;	ref_2_2<=ref_x02_r;	ref_2_3<=ref_x01_r;	ref_2_4<=ref_00_r; end
			- 4 :begin ref_2_0<=ref_x03_r;	ref_2_1<=ref_x02_r;	ref_2_2<=ref_x01_r;	ref_2_3<=ref_00_r;	ref_2_4<=ref_01_r; end
			- 3 :begin ref_2_0<=ref_x02_r;	ref_2_1<=ref_x01_r;	ref_2_2<=ref_00_r;	ref_2_3<=ref_01_r;	ref_2_4<=ref_02_r; end
			- 2 :begin ref_2_0<=ref_x01_r;	ref_2_1<=ref_00_r;	ref_2_2<=ref_01_r;	ref_2_3<=ref_02_r;	ref_2_4<=ref_03_r; end
			- 1 :begin ref_2_0<=ref_00_r;	ref_2_1<=ref_01_r;	ref_2_2<=ref_02_r;	ref_2_3<=ref_03_r;	ref_2_4<=ref_04_r; end
			  0 :begin ref_2_0<=ref_01_r;	ref_2_1<=ref_02_r;	ref_2_2<=ref_03_r;	ref_2_3<=ref_04_r;	ref_2_4<=ref_05_r; end
			  1 :begin ref_2_0<=ref_02_r;	ref_2_1<=ref_03_r;	ref_2_2<=ref_04_r;	ref_2_3<=ref_05_r;	ref_2_4<=ref_06_r; end
			  2 :begin ref_2_0<=ref_03_r;	ref_2_1<=ref_04_r;	ref_2_2<=ref_05_r;	ref_2_3<=ref_06_r;	ref_2_4<=ref_07_r; end
			  3 :begin ref_2_0<=ref_04_r;	ref_2_1<=ref_05_r;	ref_2_2<=ref_06_r;	ref_2_3<=ref_07_r;	ref_2_4<=ref_08_r; end
			  4 :begin ref_2_0<=ref_05_r;	ref_2_1<=ref_06_r;	ref_2_2<=ref_07_r;	ref_2_3<=ref_08_r;	ref_2_4<=ref_09_r; end
			  5 :begin ref_2_0<=ref_06_r;	ref_2_1<=ref_07_r;	ref_2_2<=ref_08_r;	ref_2_3<=ref_09_r;	ref_2_4<=ref_10_r; end
			  6 :begin ref_2_0<=ref_07_r;	ref_2_1<=ref_08_r;	ref_2_2<=ref_09_r;	ref_2_3<=ref_10_r;	ref_2_4<=ref_11_r; end
			  7 :begin ref_2_0<=ref_08_r;	ref_2_1<=ref_09_r;	ref_2_2<=ref_10_r;	ref_2_3<=ref_11_r;	ref_2_4<=ref_12_r; end
			  8 :begin ref_2_0<=ref_09_r;	ref_2_1<=ref_10_r;	ref_2_2<=ref_11_r;	ref_2_3<=ref_12_r;	ref_2_4<=ref_13_r; end
			  9 :begin ref_2_0<=ref_10_r;	ref_2_1<=ref_11_r;	ref_2_2<=ref_12_r;	ref_2_3<=ref_13_r;	ref_2_4<=ref_14_r; end
			 10 :begin ref_2_0<=ref_11_r;	ref_2_1<=ref_12_r;	ref_2_2<=ref_13_r;	ref_2_3<=ref_14_r;	ref_2_4<=ref_15_r; end
			 11 :begin ref_2_0<=ref_12_r;	ref_2_1<=ref_13_r;	ref_2_2<=ref_14_r;	ref_2_3<=ref_15_r;	ref_2_4<=ref_16_r; end
			 12 :begin ref_2_0<=ref_13_r;	ref_2_1<=ref_14_r;	ref_2_2<=ref_15_r;	ref_2_3<=ref_16_r;	ref_2_4<=ref_17_r; end
			 13 :begin ref_2_0<=ref_14_r;	ref_2_1<=ref_15_r;	ref_2_2<=ref_16_r;	ref_2_3<=ref_17_r;	ref_2_4<=ref_18_r; end
			 14 :begin ref_2_0<=ref_15_r;	ref_2_1<=ref_16_r;	ref_2_2<=ref_17_r;	ref_2_3<=ref_18_r;	ref_2_4<=ref_19_r; end
			 15 :begin ref_2_0<=ref_16_r;	ref_2_1<=ref_17_r;	ref_2_2<=ref_18_r;	ref_2_3<=ref_19_r;	ref_2_4<=ref_20_r; end
			 16 :begin ref_2_0<=ref_17_r;	ref_2_1<=ref_18_r;	ref_2_2<=ref_19_r;	ref_2_3<=ref_20_r;	ref_2_4<=ref_21_r; end
			 17 :begin ref_2_0<=ref_18_r;	ref_2_1<=ref_19_r;	ref_2_2<=ref_20_r;	ref_2_3<=ref_21_r;	ref_2_4<=ref_22_r; end
			 18 :begin ref_2_0<=ref_19_r;	ref_2_1<=ref_20_r;	ref_2_2<=ref_21_r;	ref_2_3<=ref_22_r;	ref_2_4<=ref_23_r; end
			 19 :begin ref_2_0<=ref_20_r;	ref_2_1<=ref_21_r;	ref_2_2<=ref_22_r;	ref_2_3<=ref_23_r;	ref_2_4<=ref_24_r; end
			 20 :begin ref_2_0<=ref_21_r;	ref_2_1<=ref_22_r;	ref_2_2<=ref_23_r;	ref_2_3<=ref_24_r;	ref_2_4<=ref_25_r; end
			 21 :begin ref_2_0<=ref_22_r;	ref_2_1<=ref_23_r;	ref_2_2<=ref_24_r;	ref_2_3<=ref_25_r;	ref_2_4<=ref_26_r; end
			 22 :begin ref_2_0<=ref_23_r;	ref_2_1<=ref_24_r;	ref_2_2<=ref_25_r;	ref_2_3<=ref_26_r;	ref_2_4<=ref_27_r; end
			 23 :begin ref_2_0<=ref_24_r;	ref_2_1<=ref_25_r;	ref_2_2<=ref_26_r;	ref_2_3<=ref_27_r;	ref_2_4<=ref_28_r; end
			 24 :begin ref_2_0<=ref_25_r;	ref_2_1<=ref_26_r;	ref_2_2<=ref_27_r;	ref_2_3<=ref_28_r;	ref_2_4<=ref_29_r; end
			 25 :begin ref_2_0<=ref_26_r;	ref_2_1<=ref_27_r;	ref_2_2<=ref_28_r;	ref_2_3<=ref_29_r;	ref_2_4<=ref_30_r; end
			 26 :begin ref_2_0<=ref_27_r;	ref_2_1<=ref_28_r;	ref_2_2<=ref_29_r;	ref_2_3<=ref_30_r;	ref_2_4<=ref_31_r; end
			 27 :begin ref_2_0<=ref_28_r;	ref_2_1<=ref_29_r;	ref_2_2<=ref_30_r;	ref_2_3<=ref_31_r;	ref_2_4<=ref_32_r; end
			 28 :begin ref_2_0<=ref_29_r;	ref_2_1<=ref_30_r;	ref_2_2<=ref_31_r;	ref_2_3<=ref_32_r;	ref_2_4<=ref_33_r; end
			 29 :begin ref_2_0<=ref_30_r;	ref_2_1<=ref_31_r;	ref_2_2<=ref_32_r;	ref_2_3<=ref_33_r;	ref_2_4<=ref_34_r; end
			 30 :begin ref_2_0<=ref_31_r;	ref_2_1<=ref_32_r;	ref_2_2<=ref_33_r;	ref_2_3<=ref_34_r;	ref_2_4<=ref_35_r; end
			 31 :begin ref_2_0<=ref_32_r;	ref_2_1<=ref_33_r;	ref_2_2<=ref_34_r;	ref_2_3<=ref_35_r;	ref_2_4<=ref_36_r; end
			 32 :begin ref_2_0<=ref_33_r;	ref_2_1<=ref_34_r;	ref_2_2<=ref_35_r;	ref_2_3<=ref_36_r;	ref_2_4<=ref_37_r; end
			 33 :begin ref_2_0<=ref_34_r;	ref_2_1<=ref_35_r;	ref_2_2<=ref_36_r;	ref_2_3<=ref_37_r;	ref_2_4<=ref_38_r; end
			 34 :begin ref_2_0<=ref_35_r;	ref_2_1<=ref_36_r;	ref_2_2<=ref_37_r;	ref_2_3<=ref_38_r;	ref_2_4<=ref_39_r; end
			 35 :begin ref_2_0<=ref_36_r;	ref_2_1<=ref_37_r;	ref_2_2<=ref_38_r;	ref_2_3<=ref_39_r;	ref_2_4<=ref_40_r; end
			 36 :begin ref_2_0<=ref_37_r;	ref_2_1<=ref_38_r;	ref_2_2<=ref_39_r;	ref_2_3<=ref_40_r;	ref_2_4<=ref_41_r; end
			 37 :begin ref_2_0<=ref_38_r;	ref_2_1<=ref_39_r;	ref_2_2<=ref_40_r;	ref_2_3<=ref_41_r;	ref_2_4<=ref_42_r; end
			 38 :begin ref_2_0<=ref_39_r;	ref_2_1<=ref_40_r;	ref_2_2<=ref_41_r;	ref_2_3<=ref_42_r;	ref_2_4<=ref_43_r; end
			 39 :begin ref_2_0<=ref_40_r;	ref_2_1<=ref_41_r;	ref_2_2<=ref_42_r;	ref_2_3<=ref_43_r;	ref_2_4<=ref_44_r; end
			 40 :begin ref_2_0<=ref_41_r;	ref_2_1<=ref_42_r;	ref_2_2<=ref_43_r;	ref_2_3<=ref_44_r;	ref_2_4<=ref_45_r; end
			 41 :begin ref_2_0<=ref_42_r;	ref_2_1<=ref_43_r;	ref_2_2<=ref_44_r;	ref_2_3<=ref_45_r;	ref_2_4<=ref_46_r; end
			 42 :begin ref_2_0<=ref_43_r;	ref_2_1<=ref_44_r;	ref_2_2<=ref_45_r;	ref_2_3<=ref_46_r;	ref_2_4<=ref_47_r; end
			 43 :begin ref_2_0<=ref_44_r;	ref_2_1<=ref_45_r;	ref_2_2<=ref_46_r;	ref_2_3<=ref_47_r;	ref_2_4<=ref_48_r; end
			 44 :begin ref_2_0<=ref_45_r;	ref_2_1<=ref_46_r;	ref_2_2<=ref_47_r;	ref_2_3<=ref_48_r;	ref_2_4<=ref_49_r; end
			 45 :begin ref_2_0<=ref_46_r;	ref_2_1<=ref_47_r;	ref_2_2<=ref_48_r;	ref_2_3<=ref_49_r;	ref_2_4<=ref_50_r; end
			 46 :begin ref_2_0<=ref_47_r;	ref_2_1<=ref_48_r;	ref_2_2<=ref_49_r;	ref_2_3<=ref_50_r;	ref_2_4<=ref_51_r; end
			 47 :begin ref_2_0<=ref_48_r;	ref_2_1<=ref_49_r;	ref_2_2<=ref_50_r;	ref_2_3<=ref_51_r;	ref_2_4<=ref_52_r; end
			 48 :begin ref_2_0<=ref_49_r;	ref_2_1<=ref_50_r;	ref_2_2<=ref_51_r;	ref_2_3<=ref_52_r;	ref_2_4<=ref_53_r; end
			 49 :begin ref_2_0<=ref_50_r;	ref_2_1<=ref_51_r;	ref_2_2<=ref_52_r;	ref_2_3<=ref_53_r;	ref_2_4<=ref_54_r; end
			 50 :begin ref_2_0<=ref_51_r;	ref_2_1<=ref_52_r;	ref_2_2<=ref_53_r;	ref_2_3<=ref_54_r;	ref_2_4<=ref_55_r; end
			 51 :begin ref_2_0<=ref_52_r;	ref_2_1<=ref_53_r;	ref_2_2<=ref_54_r;	ref_2_3<=ref_55_r;	ref_2_4<=ref_56_r; end
			 52 :begin ref_2_0<=ref_53_r;	ref_2_1<=ref_54_r;	ref_2_2<=ref_55_r;	ref_2_3<=ref_56_r;	ref_2_4<=ref_57_r; end
			 53 :begin ref_2_0<=ref_54_r;	ref_2_1<=ref_55_r;	ref_2_2<=ref_56_r;	ref_2_3<=ref_57_r;	ref_2_4<=ref_58_r; end
			 54 :begin ref_2_0<=ref_55_r;	ref_2_1<=ref_56_r;	ref_2_2<=ref_57_r;	ref_2_3<=ref_58_r;	ref_2_4<=ref_59_r; end
			 55 :begin ref_2_0<=ref_56_r;	ref_2_1<=ref_57_r;	ref_2_2<=ref_58_r;	ref_2_3<=ref_59_r;	ref_2_4<=ref_60_r; end
			 56 :begin ref_2_0<=ref_57_r;	ref_2_1<=ref_58_r;	ref_2_2<=ref_59_r;	ref_2_3<=ref_60_r;	ref_2_4<=ref_61_r; end
			 57 :begin ref_2_0<=ref_58_r;	ref_2_1<=ref_59_r;	ref_2_2<=ref_60_r;	ref_2_3<=ref_61_r;	ref_2_4<=ref_62_r; end
			 58 :begin ref_2_0<=ref_59_r;	ref_2_1<=ref_60_r;	ref_2_2<=ref_61_r;	ref_2_3<=ref_62_r;	ref_2_4<=ref_63_r; end
			 59 :begin ref_2_0<=ref_60_r;	ref_2_1<=ref_61_r;	ref_2_2<=ref_62_r;	ref_2_3<=ref_63_r;	ref_2_4<=ref_64_r; end
			 60 :begin ref_2_0<=ref_61_r;	ref_2_1<=ref_62_r;	ref_2_2<=ref_63_r;	ref_2_3<=ref_64_r;	ref_2_4<=ref_64_r; end
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		ref_3_0<='d0;	ref_3_1<='d0;	ref_3_2<='d0;	ref_3_3<='d0;	ref_3_4<='d0;
	end
	else begin
		case (ref_idx3_w)
			-32 :begin ref_3_0<=ref_x31_r;	ref_3_1<=ref_x30_r;	ref_3_2<=ref_x29_r;	ref_3_3<=ref_x28_r;	ref_3_4<=ref_x27_r; end
			-31 :begin ref_3_0<=ref_x30_r;	ref_3_1<=ref_x29_r;	ref_3_2<=ref_x28_r;	ref_3_3<=ref_x27_r;	ref_3_4<=ref_x26_r; end
			-30 :begin ref_3_0<=ref_x29_r;	ref_3_1<=ref_x28_r;	ref_3_2<=ref_x27_r;	ref_3_3<=ref_x26_r;	ref_3_4<=ref_x25_r; end
			-29 :begin ref_3_0<=ref_x28_r;	ref_3_1<=ref_x27_r;	ref_3_2<=ref_x26_r;	ref_3_3<=ref_x25_r;	ref_3_4<=ref_x24_r; end
			-28 :begin ref_3_0<=ref_x27_r;	ref_3_1<=ref_x26_r;	ref_3_2<=ref_x25_r;	ref_3_3<=ref_x24_r;	ref_3_4<=ref_x23_r; end
			-27 :begin ref_3_0<=ref_x26_r;	ref_3_1<=ref_x25_r;	ref_3_2<=ref_x24_r;	ref_3_3<=ref_x23_r;	ref_3_4<=ref_x22_r; end
			-26 :begin ref_3_0<=ref_x25_r;	ref_3_1<=ref_x24_r;	ref_3_2<=ref_x23_r;	ref_3_3<=ref_x22_r;	ref_3_4<=ref_x21_r; end
			-25 :begin ref_3_0<=ref_x24_r;	ref_3_1<=ref_x23_r;	ref_3_2<=ref_x22_r;	ref_3_3<=ref_x21_r;	ref_3_4<=ref_x20_r; end
			-24 :begin ref_3_0<=ref_x23_r;	ref_3_1<=ref_x22_r;	ref_3_2<=ref_x21_r;	ref_3_3<=ref_x20_r;	ref_3_4<=ref_x19_r; end
			-23 :begin ref_3_0<=ref_x22_r;	ref_3_1<=ref_x21_r;	ref_3_2<=ref_x20_r;	ref_3_3<=ref_x19_r;	ref_3_4<=ref_x18_r; end
			-22 :begin ref_3_0<=ref_x21_r;	ref_3_1<=ref_x20_r;	ref_3_2<=ref_x19_r;	ref_3_3<=ref_x18_r;	ref_3_4<=ref_x17_r; end
			-21 :begin ref_3_0<=ref_x20_r;	ref_3_1<=ref_x19_r;	ref_3_2<=ref_x18_r;	ref_3_3<=ref_x17_r;	ref_3_4<=ref_x16_r; end
			-20 :begin ref_3_0<=ref_x19_r;	ref_3_1<=ref_x18_r;	ref_3_2<=ref_x17_r;	ref_3_3<=ref_x16_r;	ref_3_4<=ref_x15_r; end
			-19 :begin ref_3_0<=ref_x18_r;	ref_3_1<=ref_x17_r;	ref_3_2<=ref_x16_r;	ref_3_3<=ref_x15_r;	ref_3_4<=ref_x14_r; end
			-18 :begin ref_3_0<=ref_x17_r;	ref_3_1<=ref_x16_r;	ref_3_2<=ref_x15_r;	ref_3_3<=ref_x14_r;	ref_3_4<=ref_x13_r; end
			-17 :begin ref_3_0<=ref_x16_r;	ref_3_1<=ref_x15_r;	ref_3_2<=ref_x14_r;	ref_3_3<=ref_x13_r;	ref_3_4<=ref_x12_r; end
			-16 :begin ref_3_0<=ref_x15_r;	ref_3_1<=ref_x14_r;	ref_3_2<=ref_x13_r;	ref_3_3<=ref_x12_r;	ref_3_4<=ref_x11_r; end
			-15 :begin ref_3_0<=ref_x14_r;	ref_3_1<=ref_x13_r;	ref_3_2<=ref_x12_r;	ref_3_3<=ref_x11_r;	ref_3_4<=ref_x10_r; end
			-14 :begin ref_3_0<=ref_x13_r;	ref_3_1<=ref_x12_r;	ref_3_2<=ref_x11_r;	ref_3_3<=ref_x10_r;	ref_3_4<=ref_x09_r; end
			-13 :begin ref_3_0<=ref_x12_r;	ref_3_1<=ref_x11_r;	ref_3_2<=ref_x10_r;	ref_3_3<=ref_x09_r;	ref_3_4<=ref_x08_r; end
			-12 :begin ref_3_0<=ref_x11_r;	ref_3_1<=ref_x10_r;	ref_3_2<=ref_x09_r;	ref_3_3<=ref_x08_r;	ref_3_4<=ref_x07_r; end
			-11 :begin ref_3_0<=ref_x10_r;	ref_3_1<=ref_x09_r;	ref_3_2<=ref_x08_r;	ref_3_3<=ref_x07_r;	ref_3_4<=ref_x06_r; end
			-10 :begin ref_3_0<=ref_x09_r;	ref_3_1<=ref_x08_r;	ref_3_2<=ref_x07_r;	ref_3_3<=ref_x06_r;	ref_3_4<=ref_x05_r; end
			- 9 :begin ref_3_0<=ref_x08_r;	ref_3_1<=ref_x07_r;	ref_3_2<=ref_x06_r;	ref_3_3<=ref_x05_r;	ref_3_4<=ref_x04_r; end
			- 8 :begin ref_3_0<=ref_x07_r;	ref_3_1<=ref_x06_r;	ref_3_2<=ref_x05_r;	ref_3_3<=ref_x04_r;	ref_3_4<=ref_x03_r; end
			- 7 :begin ref_3_0<=ref_x06_r;	ref_3_1<=ref_x05_r;	ref_3_2<=ref_x04_r;	ref_3_3<=ref_x03_r;	ref_3_4<=ref_x02_r; end
			- 6 :begin ref_3_0<=ref_x05_r;	ref_3_1<=ref_x04_r;	ref_3_2<=ref_x03_r;	ref_3_3<=ref_x02_r;	ref_3_4<=ref_x01_r; end
			- 5 :begin ref_3_0<=ref_x04_r;	ref_3_1<=ref_x03_r;	ref_3_2<=ref_x02_r;	ref_3_3<=ref_x01_r;	ref_3_4<=ref_00_r; end
			- 4 :begin ref_3_0<=ref_x03_r;	ref_3_1<=ref_x02_r;	ref_3_2<=ref_x01_r;	ref_3_3<=ref_00_r;	ref_3_4<=ref_01_r; end
			- 3 :begin ref_3_0<=ref_x02_r;	ref_3_1<=ref_x01_r;	ref_3_2<=ref_00_r;	ref_3_3<=ref_01_r;	ref_3_4<=ref_02_r; end
			- 2 :begin ref_3_0<=ref_x01_r;	ref_3_1<=ref_00_r;	ref_3_2<=ref_01_r;	ref_3_3<=ref_02_r;	ref_3_4<=ref_03_r; end
			- 1 :begin ref_3_0<=ref_00_r;	ref_3_1<=ref_01_r;	ref_3_2<=ref_02_r;	ref_3_3<=ref_03_r;	ref_3_4<=ref_04_r; end
			  0 :begin ref_3_0<=ref_01_r;	ref_3_1<=ref_02_r;	ref_3_2<=ref_03_r;	ref_3_3<=ref_04_r;	ref_3_4<=ref_05_r; end
			  1 :begin ref_3_0<=ref_02_r;	ref_3_1<=ref_03_r;	ref_3_2<=ref_04_r;	ref_3_3<=ref_05_r;	ref_3_4<=ref_06_r; end
			  2 :begin ref_3_0<=ref_03_r;	ref_3_1<=ref_04_r;	ref_3_2<=ref_05_r;	ref_3_3<=ref_06_r;	ref_3_4<=ref_07_r; end
			  3 :begin ref_3_0<=ref_04_r;	ref_3_1<=ref_05_r;	ref_3_2<=ref_06_r;	ref_3_3<=ref_07_r;	ref_3_4<=ref_08_r; end
			  4 :begin ref_3_0<=ref_05_r;	ref_3_1<=ref_06_r;	ref_3_2<=ref_07_r;	ref_3_3<=ref_08_r;	ref_3_4<=ref_09_r; end
			  5 :begin ref_3_0<=ref_06_r;	ref_3_1<=ref_07_r;	ref_3_2<=ref_08_r;	ref_3_3<=ref_09_r;	ref_3_4<=ref_10_r; end
			  6 :begin ref_3_0<=ref_07_r;	ref_3_1<=ref_08_r;	ref_3_2<=ref_09_r;	ref_3_3<=ref_10_r;	ref_3_4<=ref_11_r; end
			  7 :begin ref_3_0<=ref_08_r;	ref_3_1<=ref_09_r;	ref_3_2<=ref_10_r;	ref_3_3<=ref_11_r;	ref_3_4<=ref_12_r; end
			  8 :begin ref_3_0<=ref_09_r;	ref_3_1<=ref_10_r;	ref_3_2<=ref_11_r;	ref_3_3<=ref_12_r;	ref_3_4<=ref_13_r; end
			  9 :begin ref_3_0<=ref_10_r;	ref_3_1<=ref_11_r;	ref_3_2<=ref_12_r;	ref_3_3<=ref_13_r;	ref_3_4<=ref_14_r; end
			 10 :begin ref_3_0<=ref_11_r;	ref_3_1<=ref_12_r;	ref_3_2<=ref_13_r;	ref_3_3<=ref_14_r;	ref_3_4<=ref_15_r; end
			 11 :begin ref_3_0<=ref_12_r;	ref_3_1<=ref_13_r;	ref_3_2<=ref_14_r;	ref_3_3<=ref_15_r;	ref_3_4<=ref_16_r; end
			 12 :begin ref_3_0<=ref_13_r;	ref_3_1<=ref_14_r;	ref_3_2<=ref_15_r;	ref_3_3<=ref_16_r;	ref_3_4<=ref_17_r; end
			 13 :begin ref_3_0<=ref_14_r;	ref_3_1<=ref_15_r;	ref_3_2<=ref_16_r;	ref_3_3<=ref_17_r;	ref_3_4<=ref_18_r; end
			 14 :begin ref_3_0<=ref_15_r;	ref_3_1<=ref_16_r;	ref_3_2<=ref_17_r;	ref_3_3<=ref_18_r;	ref_3_4<=ref_19_r; end
			 15 :begin ref_3_0<=ref_16_r;	ref_3_1<=ref_17_r;	ref_3_2<=ref_18_r;	ref_3_3<=ref_19_r;	ref_3_4<=ref_20_r; end
			 16 :begin ref_3_0<=ref_17_r;	ref_3_1<=ref_18_r;	ref_3_2<=ref_19_r;	ref_3_3<=ref_20_r;	ref_3_4<=ref_21_r; end
			 17 :begin ref_3_0<=ref_18_r;	ref_3_1<=ref_19_r;	ref_3_2<=ref_20_r;	ref_3_3<=ref_21_r;	ref_3_4<=ref_22_r; end
			 18 :begin ref_3_0<=ref_19_r;	ref_3_1<=ref_20_r;	ref_3_2<=ref_21_r;	ref_3_3<=ref_22_r;	ref_3_4<=ref_23_r; end
			 19 :begin ref_3_0<=ref_20_r;	ref_3_1<=ref_21_r;	ref_3_2<=ref_22_r;	ref_3_3<=ref_23_r;	ref_3_4<=ref_24_r; end
			 20 :begin ref_3_0<=ref_21_r;	ref_3_1<=ref_22_r;	ref_3_2<=ref_23_r;	ref_3_3<=ref_24_r;	ref_3_4<=ref_25_r; end
			 21 :begin ref_3_0<=ref_22_r;	ref_3_1<=ref_23_r;	ref_3_2<=ref_24_r;	ref_3_3<=ref_25_r;	ref_3_4<=ref_26_r; end
			 22 :begin ref_3_0<=ref_23_r;	ref_3_1<=ref_24_r;	ref_3_2<=ref_25_r;	ref_3_3<=ref_26_r;	ref_3_4<=ref_27_r; end
			 23 :begin ref_3_0<=ref_24_r;	ref_3_1<=ref_25_r;	ref_3_2<=ref_26_r;	ref_3_3<=ref_27_r;	ref_3_4<=ref_28_r; end
			 24 :begin ref_3_0<=ref_25_r;	ref_3_1<=ref_26_r;	ref_3_2<=ref_27_r;	ref_3_3<=ref_28_r;	ref_3_4<=ref_29_r; end
			 25 :begin ref_3_0<=ref_26_r;	ref_3_1<=ref_27_r;	ref_3_2<=ref_28_r;	ref_3_3<=ref_29_r;	ref_3_4<=ref_30_r; end
			 26 :begin ref_3_0<=ref_27_r;	ref_3_1<=ref_28_r;	ref_3_2<=ref_29_r;	ref_3_3<=ref_30_r;	ref_3_4<=ref_31_r; end
			 27 :begin ref_3_0<=ref_28_r;	ref_3_1<=ref_29_r;	ref_3_2<=ref_30_r;	ref_3_3<=ref_31_r;	ref_3_4<=ref_32_r; end
			 28 :begin ref_3_0<=ref_29_r;	ref_3_1<=ref_30_r;	ref_3_2<=ref_31_r;	ref_3_3<=ref_32_r;	ref_3_4<=ref_33_r; end
			 29 :begin ref_3_0<=ref_30_r;	ref_3_1<=ref_31_r;	ref_3_2<=ref_32_r;	ref_3_3<=ref_33_r;	ref_3_4<=ref_34_r; end
			 30 :begin ref_3_0<=ref_31_r;	ref_3_1<=ref_32_r;	ref_3_2<=ref_33_r;	ref_3_3<=ref_34_r;	ref_3_4<=ref_35_r; end
			 31 :begin ref_3_0<=ref_32_r;	ref_3_1<=ref_33_r;	ref_3_2<=ref_34_r;	ref_3_3<=ref_35_r;	ref_3_4<=ref_36_r; end
			 32 :begin ref_3_0<=ref_33_r;	ref_3_1<=ref_34_r;	ref_3_2<=ref_35_r;	ref_3_3<=ref_36_r;	ref_3_4<=ref_37_r; end
			 33 :begin ref_3_0<=ref_34_r;	ref_3_1<=ref_35_r;	ref_3_2<=ref_36_r;	ref_3_3<=ref_37_r;	ref_3_4<=ref_38_r; end
			 34 :begin ref_3_0<=ref_35_r;	ref_3_1<=ref_36_r;	ref_3_2<=ref_37_r;	ref_3_3<=ref_38_r;	ref_3_4<=ref_39_r; end
			 35 :begin ref_3_0<=ref_36_r;	ref_3_1<=ref_37_r;	ref_3_2<=ref_38_r;	ref_3_3<=ref_39_r;	ref_3_4<=ref_40_r; end
			 36 :begin ref_3_0<=ref_37_r;	ref_3_1<=ref_38_r;	ref_3_2<=ref_39_r;	ref_3_3<=ref_40_r;	ref_3_4<=ref_41_r; end
			 37 :begin ref_3_0<=ref_38_r;	ref_3_1<=ref_39_r;	ref_3_2<=ref_40_r;	ref_3_3<=ref_41_r;	ref_3_4<=ref_42_r; end
			 38 :begin ref_3_0<=ref_39_r;	ref_3_1<=ref_40_r;	ref_3_2<=ref_41_r;	ref_3_3<=ref_42_r;	ref_3_4<=ref_43_r; end
			 39 :begin ref_3_0<=ref_40_r;	ref_3_1<=ref_41_r;	ref_3_2<=ref_42_r;	ref_3_3<=ref_43_r;	ref_3_4<=ref_44_r; end
			 40 :begin ref_3_0<=ref_41_r;	ref_3_1<=ref_42_r;	ref_3_2<=ref_43_r;	ref_3_3<=ref_44_r;	ref_3_4<=ref_45_r; end
			 41 :begin ref_3_0<=ref_42_r;	ref_3_1<=ref_43_r;	ref_3_2<=ref_44_r;	ref_3_3<=ref_45_r;	ref_3_4<=ref_46_r; end
			 42 :begin ref_3_0<=ref_43_r;	ref_3_1<=ref_44_r;	ref_3_2<=ref_45_r;	ref_3_3<=ref_46_r;	ref_3_4<=ref_47_r; end
			 43 :begin ref_3_0<=ref_44_r;	ref_3_1<=ref_45_r;	ref_3_2<=ref_46_r;	ref_3_3<=ref_47_r;	ref_3_4<=ref_48_r; end
			 44 :begin ref_3_0<=ref_45_r;	ref_3_1<=ref_46_r;	ref_3_2<=ref_47_r;	ref_3_3<=ref_48_r;	ref_3_4<=ref_49_r; end
			 45 :begin ref_3_0<=ref_46_r;	ref_3_1<=ref_47_r;	ref_3_2<=ref_48_r;	ref_3_3<=ref_49_r;	ref_3_4<=ref_50_r; end
			 46 :begin ref_3_0<=ref_47_r;	ref_3_1<=ref_48_r;	ref_3_2<=ref_49_r;	ref_3_3<=ref_50_r;	ref_3_4<=ref_51_r; end
			 47 :begin ref_3_0<=ref_48_r;	ref_3_1<=ref_49_r;	ref_3_2<=ref_50_r;	ref_3_3<=ref_51_r;	ref_3_4<=ref_52_r; end
			 48 :begin ref_3_0<=ref_49_r;	ref_3_1<=ref_50_r;	ref_3_2<=ref_51_r;	ref_3_3<=ref_52_r;	ref_3_4<=ref_53_r; end
			 49 :begin ref_3_0<=ref_50_r;	ref_3_1<=ref_51_r;	ref_3_2<=ref_52_r;	ref_3_3<=ref_53_r;	ref_3_4<=ref_54_r; end
			 50 :begin ref_3_0<=ref_51_r;	ref_3_1<=ref_52_r;	ref_3_2<=ref_53_r;	ref_3_3<=ref_54_r;	ref_3_4<=ref_55_r; end
			 51 :begin ref_3_0<=ref_52_r;	ref_3_1<=ref_53_r;	ref_3_2<=ref_54_r;	ref_3_3<=ref_55_r;	ref_3_4<=ref_56_r; end
			 52 :begin ref_3_0<=ref_53_r;	ref_3_1<=ref_54_r;	ref_3_2<=ref_55_r;	ref_3_3<=ref_56_r;	ref_3_4<=ref_57_r; end
			 53 :begin ref_3_0<=ref_54_r;	ref_3_1<=ref_55_r;	ref_3_2<=ref_56_r;	ref_3_3<=ref_57_r;	ref_3_4<=ref_58_r; end
			 54 :begin ref_3_0<=ref_55_r;	ref_3_1<=ref_56_r;	ref_3_2<=ref_57_r;	ref_3_3<=ref_58_r;	ref_3_4<=ref_59_r; end
			 55 :begin ref_3_0<=ref_56_r;	ref_3_1<=ref_57_r;	ref_3_2<=ref_58_r;	ref_3_3<=ref_59_r;	ref_3_4<=ref_60_r; end
			 56 :begin ref_3_0<=ref_57_r;	ref_3_1<=ref_58_r;	ref_3_2<=ref_59_r;	ref_3_3<=ref_60_r;	ref_3_4<=ref_61_r; end
			 57 :begin ref_3_0<=ref_58_r;	ref_3_1<=ref_59_r;	ref_3_2<=ref_60_r;	ref_3_3<=ref_61_r;	ref_3_4<=ref_62_r; end
			 58 :begin ref_3_0<=ref_59_r;	ref_3_1<=ref_60_r;	ref_3_2<=ref_61_r;	ref_3_3<=ref_62_r;	ref_3_4<=ref_63_r; end
			 59 :begin ref_3_0<=ref_60_r;	ref_3_1<=ref_61_r;	ref_3_2<=ref_62_r;	ref_3_3<=ref_63_r;	ref_3_4<=ref_64_r; end
			 60 :begin ref_3_0<=ref_61_r;	ref_3_1<=ref_62_r;	ref_3_2<=ref_63_r;	ref_3_3<=ref_64_r;	ref_3_4<=ref_64_r; end
		endcase
	end
end

//***********************************************************************************
//select # around the 4x4 block for Angular(filter), DC(filter) and Planar mode
//		#	#	#	#
//	#	*	*	*	*
//	#	*	*	*	*
//	#	*	*	*	*
//	#	*	*	*	*

//top
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		top0_r<='d0; top1_r<='d0;
		top2_r<='d0; top3_r<='d0;
	end
	else begin
		case(size_r0)
			2'b00:begin//4x4
				top0_r<=ref_t00_i; top1_r<=ref_t01_i;
				top2_r<=ref_t02_i; top3_r<=ref_t03_i;
			end

			2'b01:begin//8x8
				if(!i4x4_x_r[0]) begin
					top0_r<=ref_t00_i; top1_r<=ref_t01_i;
					top2_r<=ref_t02_i; top3_r<=ref_t03_i;
				end
				else begin
					top0_r<=ref_t04_i; top1_r<=ref_t05_i;
					top2_r<=ref_t06_i; top3_r<=ref_t07_i;
				end
			end

			2'b10:begin//16x16
				case(i4x4_x_r[1:0])
					2'b00:begin
						top0_r<=ref_t00_i; top1_r<=ref_t01_i;
						top2_r<=ref_t02_i; top3_r<=ref_t03_i;
					end
					2'b01:begin
						top0_r<=ref_t04_i; top1_r<=ref_t05_i;
						top2_r<=ref_t06_i; top3_r<=ref_t07_i;
					end
					2'b10:begin
						top0_r<=ref_t08_i; top1_r<=ref_t09_i;
						top2_r<=ref_t10_i; top3_r<=ref_t11_i;
					end
					2'b11:begin
						top0_r<=ref_t12_i; top1_r<=ref_t13_i;
						top2_r<=ref_t14_i; top3_r<=ref_t15_i;
					end
				endcase
			end

			2'b11:begin//32x32
				case(i4x4_x_r[2:0])
					3'b000:begin
						top0_r<=ref_t00_i; top1_r<=ref_t01_i;
						top2_r<=ref_t02_i; top3_r<=ref_t03_i;
					end
					3'b001:begin
						top0_r<=ref_t04_i; top1_r<=ref_t05_i;
						top2_r<=ref_t06_i; top3_r<=ref_t07_i;
					end
					3'b010:begin
						top0_r<=ref_t08_i; top1_r<=ref_t09_i;
						top2_r<=ref_t10_i; top3_r<=ref_t11_i;
					end
					3'b011:begin
						top0_r<=ref_t12_i; top1_r<=ref_t13_i;
						top2_r<=ref_t14_i; top3_r<=ref_t15_i;
					end
					3'b100:begin
						top0_r<=ref_t16_i; top1_r<=ref_t17_i;
						top2_r<=ref_t18_i; top3_r<=ref_t19_i;
					end
					3'b101:begin
						top0_r<=ref_t20_i; top1_r<=ref_t21_i;
						top2_r<=ref_t22_i; top3_r<=ref_t23_i;
					end
					3'b110:begin
						top0_r<=ref_t24_i; top1_r<=ref_t25_i;
						top2_r<=ref_t26_i; top3_r<=ref_t27_i;
					end
					3'b111:begin
						top0_r<=ref_t28_i; top1_r<=ref_t29_i;
						top2_r<=ref_t30_i; top3_r<=ref_t31_i;
					end
				endcase
			end
		endcase
	end
end
//left
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		left0_r<='d0; left1_r<='d0;
		left2_r<='d0; left3_r<='d0;
	end
	else begin
		case(size_r0)
			2'b00:begin//4x4
				left0_r<=ref_l00_i; left1_r<=ref_l01_i;
				left2_r<=ref_l02_i; left3_r<=ref_l03_i;
			end

			2'b01:begin//8x8
				if(!i4x4_y_r[0]) begin
					left0_r<=ref_l00_i; left1_r<=ref_l01_i;
					left2_r<=ref_l02_i; left3_r<=ref_l03_i;
				end
				else begin
					left0_r<=ref_l04_i; left1_r<=ref_l05_i;
					left2_r<=ref_l06_i; left3_r<=ref_l07_i;
				end
			end

			2'b10:begin//16x16
				case(i4x4_y_r[1:0])
					2'b00:begin
						left0_r<=ref_l00_i; left1_r<=ref_l01_i;
						left2_r<=ref_l02_i; left3_r<=ref_l03_i;
					end
					2'b01:begin
						left0_r<=ref_l04_i; left1_r<=ref_l05_i;
						left2_r<=ref_l06_i; left3_r<=ref_l07_i;
					end
					2'b10:begin
						left0_r<=ref_l08_i; left1_r<=ref_l09_i;
						left2_r<=ref_l10_i; left3_r<=ref_l11_i;
					end
					2'b11:begin
						left0_r<=ref_l12_i; left1_r<=ref_l13_i;
						left2_r<=ref_l14_i; left3_r<=ref_l15_i;
					end
				endcase
			end

			2'b11:begin//32x32
				case(i4x4_y_r[2:0])
					3'b000:begin
						left0_r<=ref_l00_i; left1_r<=ref_l01_i;
						left2_r<=ref_l02_i; left3_r<=ref_l03_i;
					end
					3'b001:begin
						left0_r<=ref_l04_i; left1_r<=ref_l05_i;
						left2_r<=ref_l06_i; left3_r<=ref_l07_i;
					end
					3'b010:begin
						left0_r<=ref_l08_i; left1_r<=ref_l09_i;
						left2_r<=ref_l10_i; left3_r<=ref_l11_i;
					end
					3'b011:begin
						left0_r<=ref_l12_i; left1_r<=ref_l13_i;
						left2_r<=ref_l14_i; left3_r<=ref_l15_i;
					end
					3'b100:begin
						left0_r<=ref_l16_i; left1_r<=ref_l17_i;
						left2_r<=ref_l18_i; left3_r<=ref_l19_i;
					end
					3'b101:begin
						left0_r<=ref_l20_i; left1_r<=ref_l21_i;
						left2_r<=ref_l22_i; left3_r<=ref_l23_i;
					end
					3'b110:begin
						left0_r<=ref_l24_i; left1_r<=ref_l25_i;
						left2_r<=ref_l26_i; left3_r<=ref_l27_i;
					end
					3'b111:begin
						left0_r<=ref_l28_i; left1_r<=ref_l29_i;
						left2_r<=ref_l30_i; left3_r<=ref_l31_i;
					end
				endcase
			end
		endcase
	end
end

//************************************************************************************
//calculate (x+1)*p[nT][-1] and (y+1)*p[-1][nT] for Planar mode
reg [`PIXEL_WIDTH+4:0] planar_x0_r,planar_x1_r,planar_x2_r,planar_x3_r;
reg [`PIXEL_WIDTH+4:0] planar_y0_r,planar_y1_r,planar_y2_r,planar_y3_r;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		planar_x0_r<='d0;planar_x1_r<='d0;planar_x2_r<='d0;planar_x3_r<='d0;
		planar_y0_r<='d0;planar_y1_r<='d0;planar_y2_r<='d0;planar_y3_r<='d0;
	end
	else begin
		planar_x0_r<=(x0_r0+1)*ref_r00_i;	planar_x1_r<=(x1_r0+1)*ref_r00_i;
		planar_x2_r<=(x2_r0+1)*ref_r00_i;	planar_x3_r<=(x3_r0+1)*ref_r00_i;

		planar_y0_r<=(y0_r0+1)*ref_d00_i;	planar_y1_r<=(y1_r0+1)*ref_d00_i;
		planar_y2_r<=(y2_r0+1)*ref_d00_i;	planar_y3_r<=(y3_r0+1)*ref_d00_i;
	end
end

//**********************************************************************************
//calculate DC value for DC mode
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		dc_value_r <= 'd0;
	else begin
		case(size_r0)
			2'b00:dc_value_r<=(mid_t0_r+mid_l0_r+4)>>3;
			2'b01:dc_value_r<=(mid_t2_r+mid_l2_r+8)>>4;
			2'b10:dc_value_r<=(mid_t2_r+mid_t3_r+mid_l2_r+mid_l3_r+16)>>5;
			2'b11:dc_value_r<=(mid_t2_r+mid_t3_r+mid_t4_r+mid_t5_r+
												 mid_l2_r+mid_l3_r+mid_l4_r+mid_l5_r+32)>>6;
		endcase
	end
end



//stage2
//***********************************************************************************
//predict process

//Angular
always @( * ) begin
	if(ifact0) begin
		 pre_0_0_w = ( (32-ifact0)*ref_0_0 + ifact0*ref_0_1 + 16 ) >>5;
		 pre_0_1_w = ( (32-ifact0)*ref_0_1 + ifact0*ref_0_2 + 16 ) >>5;
		 pre_0_2_w = ( (32-ifact0)*ref_0_2 + ifact0*ref_0_3 + 16 ) >>5;
		 pre_0_3_w = ( (32-ifact0)*ref_0_3 + ifact0*ref_0_4 + 16 ) >>5;
	end
	else begin
		 pre_0_0_w = ref_0_0 ;
		 pre_0_1_w = ref_0_1 ;
		 pre_0_2_w = ref_0_2 ;
		 pre_0_3_w = ref_0_3 ;
	end
end

always @( * ) begin
	if(ifact0) begin
		 pre_1_0_w = ( (32-ifact1)*ref_1_0 + ifact1*ref_1_1 + 16 ) >>5;
		 pre_1_1_w = ( (32-ifact1)*ref_1_1 + ifact1*ref_1_2 + 16 ) >>5;
		 pre_1_2_w = ( (32-ifact1)*ref_1_2 + ifact1*ref_1_3 + 16 ) >>5;
		 pre_1_3_w = ( (32-ifact1)*ref_1_3 + ifact1*ref_1_4 + 16 ) >>5;
	end
	else begin
		 pre_1_0_w = ref_1_0 ;
		 pre_1_1_w = ref_1_1 ;
		 pre_1_2_w = ref_1_2 ;
		 pre_1_3_w = ref_1_3 ;
	end
end

always @( * ) begin
	if(ifact0) begin
		 pre_2_0_w = ( (32-ifact2)*ref_2_0 + ifact2*ref_2_1 + 16 ) >>5;
		 pre_2_1_w = ( (32-ifact2)*ref_2_1 + ifact2*ref_2_2 + 16 ) >>5;
		 pre_2_2_w = ( (32-ifact2)*ref_2_2 + ifact2*ref_2_3 + 16 ) >>5;
		 pre_2_3_w = ( (32-ifact2)*ref_2_3 + ifact2*ref_2_4 + 16 ) >>5;
	end
	else begin
		 pre_2_0_w = ref_2_0 ;
		 pre_2_1_w = ref_2_1 ;
		 pre_2_2_w = ref_2_2 ;
		 pre_2_3_w = ref_2_3 ;
	end
end

always @( * ) begin
	if(ifact0) begin
		 pre_3_0_w = ( (32-ifact3)*ref_3_0 + ifact3*ref_3_1 + 16 ) >>5;
		 pre_3_1_w = ( (32-ifact3)*ref_3_1 + ifact3*ref_3_2 + 16 ) >>5;
		 pre_3_2_w = ( (32-ifact3)*ref_3_2 + ifact3*ref_3_3 + 16 ) >>5;
		 pre_3_3_w = ( (32-ifact3)*ref_3_3 + ifact3*ref_3_4 + 16 ) >>5;
	end
	else begin
		 pre_3_0_w = ref_3_0 ;
		 pre_3_1_w = ref_3_1 ;
		 pre_3_2_w = ref_3_2 ;
		 pre_3_3_w = ref_3_3 ;
	end
end


//Planar
reg [`PIXEL_WIDTH-1:0] planar_00_w,planar_01_w,planar_02_w,planar_03_w;
reg [`PIXEL_WIDTH-1:0] planar_10_w,planar_11_w,planar_12_w,planar_13_w;
reg [`PIXEL_WIDTH-1:0] planar_20_w,planar_21_w,planar_22_w,planar_23_w;
reg [`PIXEL_WIDTH-1:0] planar_30_w,planar_31_w,planar_32_w,planar_33_w;

always @( * ) begin
	case(size_r1)
		2'b00:begin
			planar_00_w=(3*left0_r+3*top0_r+planar_x0_r+planar_y0_r+4)>>3;
			planar_01_w=(2*left0_r+3*top1_r+planar_x1_r+planar_y0_r+4)>>3;
			planar_02_w=(1*left0_r+3*top2_r+planar_x2_r+planar_y0_r+4)>>3;
			planar_03_w=(0*left0_r+3*top3_r+planar_x3_r+planar_y0_r+4)>>3;

			planar_10_w=(3*left1_r+2*top0_r+planar_x0_r+planar_y1_r+4)>>3;
			planar_11_w=(2*left1_r+2*top1_r+planar_x1_r+planar_y1_r+4)>>3;
			planar_12_w=(1*left1_r+2*top2_r+planar_x2_r+planar_y1_r+4)>>3;
			planar_13_w=(0*left1_r+2*top3_r+planar_x3_r+planar_y1_r+4)>>3;

			planar_20_w=(3*left2_r+1*top0_r+planar_x0_r+planar_y2_r+4)>>3;
			planar_21_w=(2*left2_r+1*top1_r+planar_x1_r+planar_y2_r+4)>>3;
			planar_22_w=(1*left2_r+1*top2_r+planar_x2_r+planar_y2_r+4)>>3;
			planar_23_w=(0*left2_r+1*top3_r+planar_x3_r+planar_y2_r+4)>>3;

			planar_30_w=(3*left3_r+0*top0_r+planar_x0_r+planar_y3_r+4)>>3;
			planar_31_w=(2*left3_r+0*top1_r+planar_x1_r+planar_y3_r+4)>>3;
			planar_32_w=(1*left3_r+0*top2_r+planar_x2_r+planar_y3_r+4)>>3;
			planar_33_w=(0*left3_r+0*top3_r+planar_x3_r+planar_y3_r+4)>>3;
		end
		2'b01:begin
			planar_00_w=((7-x0_r1)*left0_r+(7-y0_r1)*top0_r+planar_x0_r+planar_y0_r+8)>>4;
			planar_01_w=((7-x1_r1)*left0_r+(7-y0_r1)*top1_r+planar_x1_r+planar_y0_r+8)>>4;
			planar_02_w=((7-x2_r1)*left0_r+(7-y0_r1)*top2_r+planar_x2_r+planar_y0_r+8)>>4;
			planar_03_w=((7-x3_r1)*left0_r+(7-y0_r1)*top3_r+planar_x3_r+planar_y0_r+8)>>4;

			planar_10_w=((7-x0_r1)*left1_r+(7-y1_r1)*top0_r+planar_x0_r+planar_y1_r+8)>>4;
			planar_11_w=((7-x1_r1)*left1_r+(7-y1_r1)*top1_r+planar_x1_r+planar_y1_r+8)>>4;
			planar_12_w=((7-x2_r1)*left1_r+(7-y1_r1)*top2_r+planar_x2_r+planar_y1_r+8)>>4;
			planar_13_w=((7-x3_r1)*left1_r+(7-y1_r1)*top3_r+planar_x3_r+planar_y1_r+8)>>4;

			planar_20_w=((7-x0_r1)*left2_r+(7-y2_r1)*top0_r+planar_x0_r+planar_y2_r+8)>>4;
			planar_21_w=((7-x1_r1)*left2_r+(7-y2_r1)*top1_r+planar_x1_r+planar_y2_r+8)>>4;
			planar_22_w=((7-x2_r1)*left2_r+(7-y2_r1)*top2_r+planar_x2_r+planar_y2_r+8)>>4;
			planar_23_w=((7-x3_r1)*left2_r+(7-y2_r1)*top3_r+planar_x3_r+planar_y2_r+8)>>4;

			planar_30_w=((7-x0_r1)*left3_r+(7-y3_r1)*top0_r+planar_x0_r+planar_y3_r+8)>>4;
			planar_31_w=((7-x1_r1)*left3_r+(7-y3_r1)*top1_r+planar_x1_r+planar_y3_r+8)>>4;
			planar_32_w=((7-x2_r1)*left3_r+(7-y3_r1)*top2_r+planar_x2_r+planar_y3_r+8)>>4;
			planar_33_w=((7-x3_r1)*left3_r+(7-y3_r1)*top3_r+planar_x3_r+planar_y3_r+8)>>4;
		end
		2'b10:begin
			planar_00_w=((15-x0_r1)*left0_r+(15-y0_r1)*top0_r+planar_x0_r+planar_y0_r+16)>>5;
			planar_01_w=((15-x1_r1)*left0_r+(15-y0_r1)*top1_r+planar_x1_r+planar_y0_r+16)>>5;
			planar_02_w=((15-x2_r1)*left0_r+(15-y0_r1)*top2_r+planar_x2_r+planar_y0_r+16)>>5;
			planar_03_w=((15-x3_r1)*left0_r+(15-y0_r1)*top3_r+planar_x3_r+planar_y0_r+16)>>5;

			planar_10_w=((15-x0_r1)*left1_r+(15-y1_r1)*top0_r+planar_x0_r+planar_y1_r+16)>>5;
			planar_11_w=((15-x1_r1)*left1_r+(15-y1_r1)*top1_r+planar_x1_r+planar_y1_r+16)>>5;
			planar_12_w=((15-x2_r1)*left1_r+(15-y1_r1)*top2_r+planar_x2_r+planar_y1_r+16)>>5;
			planar_13_w=((15-x3_r1)*left1_r+(15-y1_r1)*top3_r+planar_x3_r+planar_y1_r+16)>>5;

			planar_20_w=((15-x0_r1)*left2_r+(15-y2_r1)*top0_r+planar_x0_r+planar_y2_r+16)>>5;
			planar_21_w=((15-x1_r1)*left2_r+(15-y2_r1)*top1_r+planar_x1_r+planar_y2_r+16)>>5;
			planar_22_w=((15-x2_r1)*left2_r+(15-y2_r1)*top2_r+planar_x2_r+planar_y2_r+16)>>5;
			planar_23_w=((15-x3_r1)*left2_r+(15-y2_r1)*top3_r+planar_x3_r+planar_y2_r+16)>>5;

			planar_30_w=((15-x0_r1)*left3_r+(15-y3_r1)*top0_r+planar_x0_r+planar_y3_r+16)>>5;
			planar_31_w=((15-x1_r1)*left3_r+(15-y3_r1)*top1_r+planar_x1_r+planar_y3_r+16)>>5;
			planar_32_w=((15-x2_r1)*left3_r+(15-y3_r1)*top2_r+planar_x2_r+planar_y3_r+16)>>5;
			planar_33_w=((15-x3_r1)*left3_r+(15-y3_r1)*top3_r+planar_x3_r+planar_y3_r+16)>>5;
		end
		2'b11:begin
			planar_00_w=((31-x0_r1)*left0_r+(31-y0_r1)*top0_r+planar_x0_r+planar_y0_r+32)>>6;
			planar_01_w=((31-x1_r1)*left0_r+(31-y0_r1)*top1_r+planar_x1_r+planar_y0_r+32)>>6;
			planar_02_w=((31-x2_r1)*left0_r+(31-y0_r1)*top2_r+planar_x2_r+planar_y0_r+32)>>6;
			planar_03_w=((31-x3_r1)*left0_r+(31-y0_r1)*top3_r+planar_x3_r+planar_y0_r+32)>>6;

			planar_10_w=((31-x0_r1)*left1_r+(31-y1_r1)*top0_r+planar_x0_r+planar_y1_r+32)>>6;
			planar_11_w=((31-x1_r1)*left1_r+(31-y1_r1)*top1_r+planar_x1_r+planar_y1_r+32)>>6;
			planar_12_w=((31-x2_r1)*left1_r+(31-y1_r1)*top2_r+planar_x2_r+planar_y1_r+32)>>6;
			planar_13_w=((31-x3_r1)*left1_r+(31-y1_r1)*top3_r+planar_x3_r+planar_y1_r+32)>>6;

			planar_20_w=((31-x0_r1)*left2_r+(31-y2_r1)*top0_r+planar_x0_r+planar_y2_r+32)>>6;
			planar_21_w=((31-x1_r1)*left2_r+(31-y2_r1)*top1_r+planar_x1_r+planar_y2_r+32)>>6;
			planar_22_w=((31-x2_r1)*left2_r+(31-y2_r1)*top2_r+planar_x2_r+planar_y2_r+32)>>6;
			planar_23_w=((31-x3_r1)*left2_r+(31-y2_r1)*top3_r+planar_x3_r+planar_y2_r+32)>>6;

			planar_30_w=((31-x0_r1)*left3_r+(31-y3_r1)*top0_r+planar_x0_r+planar_y3_r+32)>>6;
			planar_31_w=((31-x1_r1)*left3_r+(31-y3_r1)*top1_r+planar_x1_r+planar_y3_r+32)>>6;
			planar_32_w=((31-x2_r1)*left3_r+(31-y3_r1)*top2_r+planar_x2_r+planar_y3_r+32)>>6;
			planar_33_w=((31-x3_r1)*left3_r+(31-y3_r1)*top3_r+planar_x3_r+planar_y3_r+32)>>6;
		end
	endcase
end

//DC
reg [`PIXEL_WIDTH-1:0] DC_00_w,DC_01_w,DC_02_w,DC_03_w;
reg [`PIXEL_WIDTH-1:0] DC_10_w;
reg [`PIXEL_WIDTH-1:0] DC_20_w;
reg [`PIXEL_WIDTH-1:0] DC_30_w;

always @( * ) begin
  if(pre_sel_i==2'b00) begin
    if((x0_r1==0) && (y0_r1==0) && size_r1!=2'b11)
      DC_00_w = (top0_r+left0_r+(dc_value_r<<1)+2)>>2;
    else if((x0_r1==0)  && size_r1!=2'b11)
      DC_00_w = (left0_r+(dc_value_r*3)+2)>>2;
    else if((y0_r1==0)  && size_r1!=2'b11)
      DC_00_w = (top0_r +(dc_value_r*3)+2)>>2;
    else begin
      DC_00_w = dc_value_r;
    end
  end
  else begin
    DC_00_w = dc_value_r;
  end
end

always @( * ) begin
	if((x0_r1==0)  && size_r1!=2'b11 && (pre_sel_i==2'b00) ) begin
		DC_10_w = (left1_r+(dc_value_r*3)+2)>>2;
		DC_20_w = (left2_r+(dc_value_r*3)+2)>>2;
		DC_30_w = (left3_r+(dc_value_r*3)+2)>>2;
	end
	else begin
		DC_10_w = dc_value_r;
		DC_20_w = dc_value_r;
		DC_30_w = dc_value_r;
	end
end

always @( * ) begin
	if((y0_r1==0)  && size_r1!=2'b11 && (pre_sel_i==2'b00) ) begin
		DC_01_w = (top1_r+(dc_value_r*3)+2)>>2;
		DC_02_w = (top2_r+(dc_value_r*3)+2)>>2;
		DC_03_w = (top3_r+(dc_value_r*3)+2)>>2;
	end
	else begin
		DC_01_w = dc_value_r;
		DC_02_w = dc_value_r;
		DC_03_w = dc_value_r;
	end
end


//Angular26 and Angular10 filter
wire signed [`PIXEL_WIDTH:0] top0_w, top1_w, top2_w, top3_w;
wire signed [`PIXEL_WIDTH:0] left0_w,left1_w,left2_w,left3_w;
wire signed [`PIXEL_WIDTH:0] ref_tl;

assign top0_w={1'b0,top0_r};		assign left0_w={1'b0,left0_r};
assign top1_w={1'b0,top1_r};		assign left1_w={1'b0,left1_r};
assign top2_w={1'b0,top2_r};		assign left2_w={1'b0,left2_r};
assign top3_w={1'b0,top3_r};		assign left3_w={1'b0,left3_r};

assign ref_tl={1'b0,ref_tl_i};

wire signed [`PIXEL_WIDTH+1:0] ver_0_w, ver_1_w, ver_2_w, ver_3_w;
wire signed [`PIXEL_WIDTH+1:0] hor_0_w, hor_1_w, hor_2_w, hor_3_w;

reg [`PIXEL_WIDTH-1:0] ver_00_w,ver_10_w,ver_20_w,ver_30_w;
reg [`PIXEL_WIDTH-1:0] hor_00_w,hor_01_w,hor_02_w,hor_03_w;

assign	ver_0_w=top0_w+((left0_w-ref_tl)>>>1);
assign	ver_1_w=top0_w+((left1_w-ref_tl)>>>1);
assign	ver_2_w=top0_w+((left2_w-ref_tl)>>>1);
assign	ver_3_w=top0_w+((left3_w-ref_tl)>>>1);

assign	hor_0_w=left0_w+((top0_w-ref_tl)>>>1);
assign	hor_1_w=left0_w+((top1_w-ref_tl)>>>1);
assign	hor_2_w=left0_w+((top2_w-ref_tl)>>>1);
assign	hor_3_w=left0_w+((top3_w-ref_tl)>>>1);

//Angular26
always @( * ) begin
	if((x0_r1==0) && size_r1!=2'b11 && (pre_sel_i==2'b00) ) begin
		ver_00_w=(ver_0_w[9] ? 'd0 : ( ver_0_w[8] ? 'd255 : ver_0_w[7:0] ));
		ver_10_w=(ver_1_w[9] ? 'd0 : ( ver_1_w[8] ? 'd255 : ver_1_w[7:0] ));
		ver_20_w=(ver_2_w[9] ? 'd0 : ( ver_2_w[8] ? 'd255 : ver_2_w[7:0] ));
		ver_30_w=(ver_3_w[9] ? 'd0 : ( ver_3_w[8] ? 'd255 : ver_3_w[7:0] ));
	end
	else begin
		ver_00_w=top0_r;
		ver_10_w=top0_r;
		ver_20_w=top0_r;
		ver_30_w=top0_r;
	end
end

//Angular10
always @( * ) begin
	if((y0_r1==0) && size_r1!=2'b11 && (pre_sel_i==2'b00) ) begin
		hor_00_w=(hor_0_w[9] ? 'd0 : ( hor_0_w[8] ? 'd255 : hor_0_w[7:0] ));
		hor_01_w=(hor_1_w[9] ? 'd0 : ( hor_1_w[8] ? 'd255 : hor_1_w[7:0] ));
		hor_02_w=(hor_2_w[9] ? 'd0 : ( hor_2_w[8] ? 'd255 : hor_2_w[7:0] ));
		hor_03_w=(hor_3_w[9] ? 'd0 : ( hor_3_w[8] ? 'd255 : hor_3_w[7:0] ));
	end
	else begin
		hor_00_w=left0_r;
		hor_01_w=left0_r;
		hor_02_w=left0_r;
		hor_03_w=left0_r;
	end
end



//***************************************************************************
//output
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		pred_00_o<='d0;	pred_01_o<='d0;	pred_02_o<='d0;	pred_03_o<='d0;
		pred_10_o<='d0;	pred_11_o<='d0;	pred_12_o<='d0;	pred_13_o<='d0;
		pred_20_o<='d0;	pred_21_o<='d0;	pred_22_o<='d0;	pred_23_o<='d0;
		pred_30_o<='d0;	pred_31_o<='d0;	pred_32_o<='d0;	pred_33_o<='d0;
	end
	else begin
		case(mode_r1)
			'd0:begin
				pred_00_o<=planar_00_w;	pred_01_o<=planar_01_w;	pred_02_o<=planar_02_w;	pred_03_o<=planar_03_w;
				pred_10_o<=planar_10_w;	pred_11_o<=planar_11_w;	pred_12_o<=planar_12_w;	pred_13_o<=planar_13_w;
				pred_20_o<=planar_20_w;	pred_21_o<=planar_21_w;	pred_22_o<=planar_22_w;	pred_23_o<=planar_23_w;
				pred_30_o<=planar_30_w;	pred_31_o<=planar_31_w;	pred_32_o<=planar_32_w;	pred_33_o<=planar_33_w;
			end
			'd1:begin
				pred_00_o<=DC_00_w;	pred_01_o<=DC_01_w;			pred_02_o<=DC_02_w;			pred_03_o<=DC_03_w;
				pred_10_o<=DC_10_w;	pred_11_o<=dc_value_r;	pred_12_o<=dc_value_r;	pred_13_o<=dc_value_r;
				pred_20_o<=DC_20_w;	pred_21_o<=dc_value_r;	pred_22_o<=dc_value_r;	pred_23_o<=dc_value_r;
				pred_30_o<=DC_30_w;	pred_31_o<=dc_value_r;	pred_32_o<=dc_value_r;	pred_33_o<=dc_value_r;
			end
			'd10:begin
				 pred_00_o<=hor_00_w;	pred_01_o<=hor_01_w;	pred_02_o<=hor_02_w;	pred_03_o<=hor_03_w;
				 pred_10_o<=left1_r;	pred_11_o<=left1_r;		pred_12_o<=left1_r;		pred_13_o<=left1_r;
				 pred_20_o<=left2_r;	pred_21_o<=left2_r;		pred_22_o<=left2_r;		pred_23_o<=left2_r;
				 pred_30_o<=left3_r;	pred_31_o<=left3_r;		pred_32_o<=left3_r;		pred_33_o<=left3_r;
			end
			'd26:begin
				pred_00_o<=ver_00_w;	pred_01_o<=top1_r;	pred_02_o<=top2_r;	pred_03_o<=top3_r;
				pred_10_o<=ver_10_w;	pred_11_o<=top1_r;	pred_12_o<=top2_r;	pred_13_o<=top3_r;
				pred_20_o<=ver_20_w;	pred_21_o<=top1_r;	pred_22_o<=top2_r;	pred_23_o<=top3_r;
				pred_30_o<=ver_30_w;	pred_31_o<=top1_r;	pred_32_o<=top2_r;	pred_33_o<=top3_r;
			end
			default:begin
				if(mode_r1>=18)begin
					pred_00_o<=pre_0_0_w;	pred_01_o<=pre_0_1_w;	pred_02_o<=pre_0_2_w;	pred_03_o<=pre_0_3_w;
					pred_10_o<=pre_1_0_w;	pred_11_o<=pre_1_1_w;	pred_12_o<=pre_1_2_w;	pred_13_o<=pre_1_3_w;
					pred_20_o<=pre_2_0_w;	pred_21_o<=pre_2_1_w;	pred_22_o<=pre_2_2_w;	pred_23_o<=pre_2_3_w;
					pred_30_o<=pre_3_0_w;	pred_31_o<=pre_3_1_w;	pred_32_o<=pre_3_2_w;	pred_33_o<=pre_3_3_w;
				end
				else begin
					pred_00_o<=pre_0_0_w;	pred_01_o<=pre_1_0_w;	pred_02_o<=pre_2_0_w;	pred_03_o<=pre_3_0_w;
					pred_10_o<=pre_0_1_w;	pred_11_o<=pre_1_1_w;	pred_12_o<=pre_2_1_w;	pred_13_o<=pre_3_1_w;
					pred_20_o<=pre_0_2_w;	pred_21_o<=pre_1_2_w;	pred_22_o<=pre_2_2_w;	pred_23_o<=pre_3_2_w;
					pred_30_o<=pre_0_3_w;	pred_31_o<=pre_1_3_w;	pred_32_o<=pre_2_3_w;	pred_33_o<=pre_3_3_w;
				end
			end
		endcase
	end
end


//***********************************************************************************
//buffering mode/size/x0/y0
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		mode_r0<='d0;	size_r0<='d0; start_r0<='d0;
		mode_r1<='d0;	size_r1<='d0; start_r1<='d0;

		x0_r0<='d0;	x0_r1<='d0;
		y0_r0<='d0;	y0_r1<='d0;

		x1_r0<='d0;	x1_r1<='d0;
		y1_r0<='d0;	y1_r1<='d0;

		x2_r0<='d0;	x2_r1<='d0;
		y2_r0<='d0;	y2_r1<='d0;

		x3_r0<='d0;	x3_r1<='d0;
		y3_r0<='d0;	y3_r1<='d0;

		i4x4_x_r<='d0;i4x4_y_r<='d0;
		i4x4_x_r1<='d0;i4x4_y_r1<='d0;

		i4x4_x_o<='d0;i4x4_y_o<='d0;
		size_o <= 'd0;
		done_o <= 'd0;
	end
	else begin
 		mode_r0 <= mode_i; 	size_r0 <= size_i; start_r0 <= start_i;
		mode_r1 <= mode_r0;	size_r1 <= size_r0;start_r1 <= start_r0;

		x0_r0<=x0;	x0_r1<=x0_r0;
		y0_r0<=y0;	y0_r1<=y0_r0;

		x1_r0<=x1;	x1_r1<=x1_r0;
		y1_r0<=y1;	y1_r1<=y1_r0;

		x2_r0<=x2;	x2_r1<=x2_r0;
		y2_r0<=y2;	y2_r1<=y2_r0;

		x3_r0<=x3;	x3_r1<=x3_r0;
		y3_r0<=y3;	y3_r1<=y3_r0;

		i4x4_x_r<=i4x4_x_i;
		i4x4_y_r<=i4x4_y_i;

		i4x4_x_r1<=i4x4_x_r;
		i4x4_y_r1<=i4x4_y_r;

		i4x4_x_o<=i4x4_x_r1;
		i4x4_y_o<=i4x4_y_r1;
		size_o  <= size_r1;

		done_o <= start_r1;
	end
end

endmodule