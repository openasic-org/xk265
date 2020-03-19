//-------------------------------------------------------------------
//
//  Filename      : hevc_prei_top.v
//  Created On    : 2018-04-02
//  Version1.0    : 2018-04-02
//  Author        : Yanheng Lu
//  Description   : prei top module (mode decision & rate control)
//                  V1.0 basic
//
//-------------------------------------------------------------------
`include "enc_defines.v"

module prei_top(

	clk,
	rstn,
	
	md_ren_o,
	md_sel_o,
	md_size_o,
	md_4x4_x_o,
	md_4x4_y_o,
	md_idx_o,
	md_data_i,

	md_we,
	md_waddr,
	md_wdata,
	
	actual_bitnum_i,
	rc_qp_o,
	mod64_sum_o,
	rc_ctu_x_i,
	rc_ctu_y_i,
	
	reg_k,
	reg_bitnum_i,
	reg_ROI_height,
	reg_ROI_width,
	reg_ROI_x,
	reg_ROI_y,
	reg_ROI_enable,
	reg_L1_frame_byte,
	reg_L2_frame_byte,
	reg_lcu_rc_en,
	reg_initial_qp,
	reg_max_qp,
	reg_min_qp,
	reg_delta_qp,
	
	prei_start,
	prei_done
	
);
	//global
	input							clk			;
	input							rstn		;
	// original pixels data read
	output							md_ren_o	;
	output							md_sel_o	;
	output		[1:0]				md_size_o	;
	output		[3:0]				md_4x4_x_o	;
	output		[3:0]				md_4x4_y_o	;
	output		[4:0]				md_idx_o	;
	input		[255:0]				md_data_i	;
	// mode ram
	output							md_we;
	output		[5:0]				md_wdata;
	output		[6:0]				md_waddr;
	// RC
	input       [15:0]				actual_bitnum_i;
	output		[5:0]				rc_qp_o;
	output		[31:0]				mod64_sum_o;
	input  [`PIC_X_WIDTH       -1 :0]       rc_ctu_x_i     ;
    input  [`PIC_Y_WIDTH       -1 :0]       rc_ctu_y_i     ;
	
	input		[15:0]				reg_k			;
    input	    [31:0]				reg_bitnum_i	;
	input		[5:0]				reg_ROI_height	;
	input		[6:0]				reg_ROI_width	;
	input		[6:0]				reg_ROI_x		;
	input		[6:0]				reg_ROI_y		;
	input							reg_ROI_enable	;
	input		[9:0]				reg_L1_frame_byte;
	input		[9:0]				reg_L2_frame_byte;
	input							reg_lcu_rc_en	;
	input		[5:0]				reg_initial_qp	;
	input		[5:0]				reg_max_qp		;
	input		[5:0]				reg_min_qp		;	
	input		[5:0]				reg_delta_qp	;
	// state
	output							prei_done;
	input							prei_start;

//===============wire declaration====================================================
	
	wire							md_done_w;
	wire        [27:0]				modebest64_w;//for LCU RC
	
//===========================================================================================
	
hevc_md_top hevc_md_top1(
	.clk				(clk),
	.rstn				(rstn),
	.md_ren_o			(md_ren_o),
	.md_sel_o			(md_sel_o),
	.md_size_o			(md_size_o),
	.md_4x4_x_o			(md_4x4_x_o),
	.md_4x4_y_o			(md_4x4_y_o),
	.md_idx_o			(md_idx_o),
	.md_data_i			(md_data_i),
	.md_we				(md_we),
	.md_waddr	        (md_waddr),
	.md_wdata	        (md_wdata),
	.modebest64			(modebest64_w),
	.enable				(prei_start),
	.finish				(md_done_w)
);// mode decision top module

rate_control rate_control1(
	.clk				(clk),
	.rstn				(rstn),
    .rc_start_i         (md_done_w),
    .rc_done_o          (prei_done),
    .rc_ctu_x_i		    (rc_ctu_x_i),
    .rc_ctu_y_i         (rc_ctu_y_i),
        
	.actual_bitnum_i	(actual_bitnum_i), // actual bit number form cabac
	.modebest64_i	    (modebest64_w), // from pre_i

    .reg_k              (reg_k), // register k
    .reg_bitnum_i       (reg_bitnum_i)     , // register target bit number
	.reg_ROI_height     (reg_ROI_height)   , // Y+height <= Y CTU total
	.reg_ROI_width      (reg_ROI_width)    , // X+width <= X CTU total
	.reg_ROI_x          (reg_ROI_x)        , // ROI horizontal coordinate
	.reg_ROI_y          (reg_ROI_y)        , // ROI vertical coordinate
	.reg_ROI_enable     (reg_ROI_enable)   , // ROI enable
	.reg_L1_frame_byte	(reg_L1_frame_byte), // level one
	.reg_L2_frame_byte	(reg_L2_frame_byte), // level two
	.reg_lcu_rc_en      (reg_lcu_rc_en)    ,
	.reg_initial_qp     (reg_initial_qp)   , //frame QP
	.reg_max_qp         (reg_max_qp)       ,
	.reg_min_qp         (reg_min_qp)       ,
	.reg_delta_qp       (reg_delta_qp)     , // ROI qp

        // rate control qp output
    .rc_qp_o	    	(rc_qp_o),
    .mod64_sum_o		(mod64_sum_o)
);//LCU level rate control

		
endmodule
