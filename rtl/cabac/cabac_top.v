//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner    : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//-------------------------------------------------------------------
// Filename       : cabac_top.v
// Author         : liwei
// Created        : 2018-3-12
// Description    : CABAC TOP
// DATA & EDITION:  2018/3/12 1.0   liwei
// $Id$
//-------------------------------------------------------------------
//  Modified      : 2018-5-20 by liwei
//  Description   : boundary check logic
//  Modified      : 2018-6-13 by liwei
//  Description   : input and output match with the h265
//  Modified      : 2018-9-18 by liwei
//  Description   : add pipo to improve the performance
//  Modified      : 2018-9-20 by liwei
//  Description   : skip supported
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module cabac_top(
           clk             ,
           rst_n           ,

           sys_slice_type_i,
           sys_total_x_i   ,
           sys_total_y_i   ,
           sys_mb_x_i      ,
           sys_mb_y_i      ,

           frame_width_remain_i,
           frame_height_remain_i,   //6 bits,used for the boundary

           sys_start_i     ,   //enable for every 64x64

           rc_qp_i         ,
           rc_param_qp_i   ,

           sao_i           ,   //sao IF

           mb_partition_i  ,   //CU partition
           mb_p_pu_mode_i  ,   //PU partition

           mb_skip_flag_i  ,   //skip and merge info
           mb_merge_flag_i ,
           mb_merge_idx_i  ,

           mb_cbf_y_i      ,
           mb_cbf_u_i      ,
           mb_cbf_v_i      ,

           mb_i_luma_mode_data_i,

           mb_i_luma_mode_ren_o,
           mb_i_luma_mode_addr_o,
           mb_mvd_data_i   ,
           mb_cef_data_i   ,   //coefficient residual

           mb_mvd_ren_o    ,
           mb_mvd_addr_o   ,

           ec_coe_rd_ena_o    ,
           ec_coe_rd_sel_o    ,
           ec_coe_rd_siz_o    ,
           ec_coe_rd_4x4_x_o  ,
           ec_coe_rd_4x4_y_o  ,
           ec_coe_rd_idx_o    ,

           cabac_done_o ,

           bs_data_o       ,
           bs_val_o        ,
           slice_done_o       //info for every slice
       );

// -------------------------------------------------------------------
//
//    INPUT / OUTPUT DECLARATION
//
// -------------------------------------------------------------------
input clk;
input rst_n;

input sys_start_i;
input sys_slice_type_i;
input [(`PIC_X_WIDTH)-1:0] sys_total_x_i;
input [(`PIC_Y_WIDTH)-1:0] sys_total_y_i;
input [(`PIC_X_WIDTH)-1:0] sys_mb_x_i;
input [(`PIC_Y_WIDTH)-1:0] sys_mb_y_i;

input [5:0] frame_width_remain_i;
input [5:0] frame_height_remain_i;

input [5:0] rc_qp_i;        //qp for every lcu
input [5:0] rc_param_qp_i;  //qp for every slice

input [61:0] sao_i;

input [84:0] mb_partition_i;
input [84:0] mb_skip_flag_i;

input [5:0] mb_i_luma_mode_data_i;

input [ 41:0] mb_p_pu_mode_i;
input [ 84:0] mb_merge_flag_i;
input [339:0] mb_merge_idx_i;

input [`LCU_SIZE*`LCU_SIZE/16-1:0] mb_cbf_y_i;
input [`LCU_SIZE*`LCU_SIZE/16-1:0] mb_cbf_u_i;
input [`LCU_SIZE*`LCU_SIZE/16-1:0] mb_cbf_v_i;

input [(2*`MVD_WIDTH) :0] mb_mvd_data_i;
input [`COEFF_WIDTH*32-1:0] mb_cef_data_i;

//data store in mem
output mb_i_luma_mode_ren_o;
output [5:0] mb_i_luma_mode_addr_o;

output mb_mvd_ren_o;
output [5:0] mb_mvd_addr_o;

output  ec_coe_rd_ena_o;
output  [1 :0] ec_coe_rd_sel_o;
output  [1 :0] ec_coe_rd_siz_o;
output  [3 :0] ec_coe_rd_4x4_y_o;
output  [3 :0] ec_coe_rd_4x4_x_o;
output  [4 :0] ec_coe_rd_idx_o;

output cabac_done_o;

//output data
output bs_val_o;
output [7:0] bs_data_o;
output slice_done_o;

reg slice_done_o;

//-----------------------------------------------------------------------------------------------------------------------------
//
//    Wire and reg declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
//se prepare {
wire [5:0] mb_mvd_addr_w;

wire context_init_done_w;
wire rdy_w;//data valid signal
wire [ 1:0] coeff_type_w;

wire cabac_done_w;

wire [22:0] syntax_element_0_w;
wire [22:0] syntax_element_1_w;
wire [14:0] syntax_element_2_w;
wire [14:0] syntax_element_3_w;
wire syntax_element_valid_w;

wire [1:0] gp_slice_type_w; // I-2; P-1; B-0
wire  gp_cabac_init_flag_w;
wire [2:0] gp_five_minus_max_num_merge_cand_w;
wire [5:0] gp_qp_w;
wire en;
//}

//coeff_addr_tran {
wire [1:0] cu_depth_w;
wire ec_coe_rd_ena_w;
wire [8:0] ec_coe_rd_addr_w;
wire [1:0] ec_coe_rd_sel_w;
wire [16*`COEFF_WIDTH-1 :0] ec_coe_rd_dat_w ;
//}

//PIPO buffer{
wire [75:0] data_input_w;
wire [75:0] data_output_w;
wire write_w;
wire data_valid_w;
//}

//binarization //{
wire  [15:0]    syntaxElement_0_w, syntaxElement_1_w;
wire  [1:0]     syntaxElement_2_w, syntaxElement_3_w;

wire  [3:0]     cMax_0_w, cMax_1_w, cMax_2_w, cMax_3_w;
wire  [8:0]     ctxIdx_0_w, ctxIdx_1_w, ctxIdx_2_w, ctxIdx_3_w;

wire            wack;
wire   [5:0]  free_space;
wire      flag_end_slice;
wire      write_valid;
wire   [9:0]  out_binsidx_0;
wire   [9:0]  out_binsidx_1;
wire   [9:0]  out_binsidx_2;
wire   [9:0]  out_binsidx_3;
wire   [9:0]  out_binsidx_4;
wire   [9:0]  out_binsidx_5;
wire   [9:0]  out_binsidx_6;
wire   [9:0]  out_binsidx_7;
wire   [9:0]  out_binsidx_8;
wire   [9:0]  out_binsidx_9;
wire   [9:0]  out_binsidx_10;
wire   [9:0]  out_binsidx_11;
wire   [9:0]  out_binsidx_12;
wire   [9:0]  out_binsidx_13;
wire   [9:0]  out_binsidx_14;
wire   [9:0]  out_binsidx_15;
wire   [9:0]  out_binsidx_16;
wire   [9:0]  out_binsidx_17;
wire   [4:0]  out_number;
//}

//bin_sort //{
wire        out_to_bin_mix_enable;
wire   [3:0]  out_number_all;     //0~8
wire   [2:0]  out_number_range;   //0~4
wire   [7:0]  out_index_bypass;
wire   [7:0]  out_symbol_bypass;
wire   [9:0]  out_sort_binsidx_0;
wire   [9:0]  out_sort_binsidx_1;
wire   [9:0]  out_sort_binsidx_2;
wire   [9:0]  out_sort_binsidx_3;
//}

//context table //{
wire   [3:0]  out_number_all_1;   //0~8
wire   [2:0]  out_number_range_1;   //0~4
wire   [7:0]  out_index_bypass_1;
wire   [7:0]  out_symbol_bypass_1;

wire   [6:0]  out_context_0;  //[6]=lpsmps, [5:0]=pStateIdx
wire   [6:0]  out_context_1;
wire   [6:0]  out_context_2;
wire   [6:0]  out_context_3;
//}

//rlps_4 //{
wire   [3:0]  out_number_all_2;   //0~8
wire   [2:0]  out_number_range_2;   //0~4
wire   [7:0]  out_index_bypass_2;
wire   [7:0]  out_symbol_bypass_2;

wire        out_lpsmps_0;
wire   [31:0] out_four_lps_0;
wire   [43:0] out_four_lps_shift_0;
wire        out_lpsmps_1;
wire   [31:0] out_four_lps_1;
wire   [43:0] out_four_lps_shift_1;
wire        out_lpsmps_2;
wire   [31:0] out_four_lps_2;
wire   [43:0] out_four_lps_shift_2;
wire        out_lpsmps_3;
wire   [31:0] out_four_lps_3;
wire   [43:0] out_four_lps_shift_3;
//}

//range //{
wire   [3:0]  out_number_all_3;     //0~8
wire   [7:0]  out_index_bypass_3;
wire   [7:0]  out_symbol_bypass_3;

wire        out_ur_lpsmps_0;
wire   [7:0]  out_ur_range_0;
wire   [7:0]  out_ur_rlps_0;
wire   [2:0]  out_ur_shift_0;
wire        out_ur_lpsmps_1;
wire   [7:0]  out_ur_range_1;
wire   [7:0]  out_ur_rlps_1;
wire   [2:0]  out_ur_shift_1;
wire        out_ur_lpsmps_2;
wire   [7:0]  out_ur_range_2;
wire   [7:0]  out_ur_rlps_2;
wire   [2:0]  out_ur_shift_2;
wire        out_ur_lpsmps_3;
wire   [7:0]  out_ur_range_3;
wire   [7:0]  out_ur_rlps_3;
wire   [2:0]  out_ur_shift_3;
wire   [7:0]  out_ur_range_4;
//}

//bin mix //{
wire        out_to_bit_pack_enable;
wire   [2:0]  out_number_4;     //0~5
wire   [4:0]  free_space_mix;
wire        out_mix_bypass_0;
wire        out_mix_bypass_1;
wire        out_mix_bypass_2;
wire        out_mix_bypass_3;
wire        out_mix_bypass_4;
wire        out_mix_lpsmps_0;
wire        out_mix_lpsmps_1;
wire        out_mix_lpsmps_2;
wire        out_mix_lpsmps_3;
wire        out_mix_lpsmps_4;
wire   [2:0]  out_mix_shift_0;
wire   [2:0]  out_mix_shift_1;
wire   [2:0]  out_mix_shift_2;
wire   [2:0]  out_mix_shift_3;
wire   [2:0]  out_mix_shift_4;
wire   [8:0]  out_mix_r_rmps_0;
wire   [8:0]  out_mix_r_rmps_1;
wire   [8:0]  out_mix_r_rmps_2;
wire   [8:0]  out_mix_r_rmps_3;
wire   [8:0]  out_mix_r_rmps_4;
//}

//low //{
wire        out_end_slice_low;
wire    [2:0] out_number_5;     //0~35

wire    [2:0] out_low_shift_0;
wire    [2:0] out_low_shift_1;
wire    [2:0] out_low_shift_2;
wire    [2:0] out_low_shift_3;
wire    [2:0] out_low_shift_4;

wire        out_low_overflow_0;
wire        out_low_overflow_1;
wire        out_low_overflow_2;
wire        out_low_overflow_3;
wire        out_low_overflow_4;

wire    [6:0] out_low_buffer_0;
wire    [6:0] out_low_buffer_1;
wire    [6:0] out_low_buffer_2;
wire    [6:0] out_low_buffer_3;
wire    [6:0] out_low_buffer_4;

//low_refine //{
wire    [5:0] out_low_length;
wire        out_low_flag_flow;
wire    [34:0]  out_low_string_to_update;
wire    [5:0] out_low_zero_position;
//}

//bit pack //{
wire      out_end_slice_bit_pack;
wire  [6:0] left_space_bit_pack;


//}

//-----------------------------------------------------------------------------------------------------------------------------
//
//   wire logic for data transmit
//
//-----------------------------------------------------------------------------------------------------------------------------
//top to prepare
assign mb_mvd_addr_o = {mb_mvd_addr_w[5],mb_mvd_addr_w[3],mb_mvd_addr_w[1] ,
                        mb_mvd_addr_w[4],mb_mvd_addr_w[2],mb_mvd_addr_w[0]};

//pipo buffer
assign data_input_w = {syntax_element_0_w,syntax_element_1_w,syntax_element_2_w,syntax_element_3_w};

//prepare to binarization
assign rdy_w = data_valid_w;
assign syntaxElement_0_w = {6'd0,data_output_w[75:66]};
assign syntaxElement_1_w = {6'd0,data_output_w[52:43]};
assign syntaxElement_2_w = data_output_w[29:28];
assign syntaxElement_3_w = data_output_w[14:13];

assign cMax_0_w = data_output_w[65:62];
assign cMax_1_w = data_output_w[42:39];
assign cMax_2_w = data_output_w[27:24];
assign cMax_3_w = data_output_w[12:9];

assign ctxIdx_0_w = data_output_w[61:53];
assign ctxIdx_1_w = data_output_w[38:30];
assign ctxIdx_2_w = data_output_w[23:15];
assign ctxIdx_3_w = data_output_w[8:0];
// assign rdy_w = syntax_element_valid_w;
// assign syntaxElement_0_w = {6'd0,syntax_element_0_w[22:13]};
// assign syntaxElement_1_w = {6'd0,syntax_element_1_w[22:13]};
// assign syntaxElement_2_w = syntax_element_2_w[14:13];
// assign syntaxElement_3_w = syntax_element_3_w[14:13];

// assign cMax_0_w = syntax_element_0_w[12:9];
// assign cMax_1_w = syntax_element_1_w[12:9];
// assign cMax_2_w = syntax_element_2_w[12:9];
// assign cMax_3_w = syntax_element_3_w[12:9];

// assign ctxIdx_0_w = syntax_element_0_w[8:0];
// assign ctxIdx_1_w = syntax_element_1_w[8:0];
// assign ctxIdx_2_w = syntax_element_2_w[8:0];
// assign ctxIdx_3_w = syntax_element_3_w[8:0];

//coeff_addr_trans
// assign mb_cef_addr_o = ec_coe_rd_addr_w;
// assign mb_cef_ren_o  = ec_coe_rd_ena_w;
// assign cef_type_o    = ec_coe_rd_sel_w;
//-----------------------------------------------------------------------------------------------------------------------------
//
//   module instances
//
//-----------------------------------------------------------------------------------------------------------------------------
cabac_se_prepare cabac_prepare_se(
                     .clk(clk),
                     .rst_n(rst_n),

                     .sys_start_i(sys_start_i),
                     .sys_slice_type_i(sys_slice_type_i),
                     .sys_total_x_i(sys_total_x_i),
                     .sys_total_y_i(sys_total_y_i),
                     .sys_mb_x_i(sys_mb_x_i),
                     .sys_mb_y_i(sys_mb_y_i),

                     .frame_width_remain_i(frame_width_remain_i),
                     .frame_height_remain_i(frame_height_remain_i),

                     .context_init_done_i(!context_init_done_w),

                     .rc_param_qp_i(rc_param_qp_i),
                     .rc_qp_i(rc_qp_i),

                     .sao_i(sao_i),

                     .mb_partition_i(mb_partition_i),
                     .mb_p_pu_mode_i(mb_p_pu_mode_i),

                     .mb_skip_flag_i(mb_skip_flag_i),
                     .mb_merge_flag_i(mb_merge_flag_i),
                     .mb_merge_idx_i(mb_merge_idx_i),

                     .mb_cbf_y_i(mb_cbf_y_i),
                     .mb_cbf_v_i(mb_cbf_v_i),
                     .mb_cbf_u_i(mb_cbf_u_i),

                     .mb_i_luma_mode_data_i(mb_i_luma_mode_data_i),

                     .mb_i_luma_mode_ren_o(mb_i_luma_mode_ren_o),
                     .mb_i_luma_mode_addr_o(mb_i_luma_mode_addr_o),

                     .mb_mvd_data_i(mb_mvd_data_i),
                     .mb_cef_data_i(ec_coe_rd_dat_w),

                     .mb_mvd_ren_o(mb_mvd_ren_o),
                     .mb_mvd_addr_o(mb_mvd_addr_w),
                     .mb_cef_addr_o(ec_coe_rd_addr_w),
                     .mb_cef_ren_o(ec_coe_rd_ena_w),

                     .gp_qp_o(gp_qp_w),
                     .gp_slice_type_o(gp_slice_type_w),
                     .gp_cabac_init_flag_o(gp_cabac_init_flag_w),
                     .gp_five_minus_max_num_merge_cand_o(gp_five_minus_max_num_merge_cand_w),

                     .coeff_type_o(ec_coe_rd_sel_w),
                     .en_o(en),

                     .lcu_done_o(cabac_done_w),

                     .syntax_element_0_o(syntax_element_0_w),
                     .syntax_element_1_o(syntax_element_1_w),
                     .syntax_element_2_o(syntax_element_2_w),
                     .syntax_element_3_o(syntax_element_3_w),
                     .syntax_element_valid_o(syntax_element_valid_w)
                 );

//---------------------coe_addr_trans---------------------//
coe_addr_trans coe_addr_trans_u0(
                   .clk(clk),
                   .rst_n(rst_n),
                   .ec_coe_rd_ena_i(ec_coe_rd_ena_w),
                   .ec_coe_rd_addr_i(ec_coe_rd_addr_w),
                   .ec_coe_rd_sel_i(ec_coe_rd_sel_w),
                   .ec_coe_rd_dat_i(mb_cef_data_i),

                   .ec_coe_rd_dat_o(ec_coe_rd_dat_w),
                   .ec_coe_rd_ena_o(ec_coe_rd_ena_o),
                   .ec_coe_rd_sel_o(ec_coe_rd_sel_o),
                   .ec_coe_rd_siz_o(ec_coe_rd_siz_o),
                   .ec_coe_rd_4x4_x_o(ec_coe_rd_4x4_x_o),
                   .ec_coe_rd_4x4_y_o(ec_coe_rd_4x4_y_o),
                   .ec_coe_rd_idx_o(ec_coe_rd_idx_o)
               );
	       
cabac_pipo pipo(
                .clk(clk),
                .rst_n(rst_n),
                .data_i(data_input_w),
                .wr_i(syntax_element_valid_w),
                .wack_i(wack),
                .data_o(data_output_w),
                .data_valid_o(data_valid_w)
                );
		
cabac_bina binarization(
               .clk(clk),
               .en(en),
               .rst_n(rst_n),

               .rdy(rdy_w),
               .wack_o(wack),

               .syntaxElement_0(syntaxElement_0_w),
               .syntaxElement_1(syntaxElement_1_w),
               .syntaxElement_2(syntaxElement_2_w),
               .syntaxElement_3(syntaxElement_3_w),

               .in_cMax_0(cMax_0_w),
               .in_cMax_1(cMax_1_w),
               .in_cMax_2(cMax_2_w),
               .in_cMax_3(cMax_3_w),

               .ctxIdx_0(ctxIdx_0_w),
               .ctxIdx_1(ctxIdx_1_w),
               .ctxIdx_2(ctxIdx_2_w),
               .ctxIdx_3(ctxIdx_3_w),

               .gp_five_minus_max_num_merge_cand(gp_five_minus_max_num_merge_cand_w),
               .free_space(free_space),
               .flag_end_slice(flag_end_slice),
               .init_done(context_init_done_w),

               .valid(write_valid),
               .ob_0(out_binsidx_0),
               .ob_1(out_binsidx_1),
               .ob_2(out_binsidx_2),
               .ob_3(out_binsidx_3),
               .ob_4(out_binsidx_4),
               .ob_5(out_binsidx_5),
               .ob_6(out_binsidx_6),
               .ob_7(out_binsidx_7),
               .ob_8(out_binsidx_8),
               .ob_9(out_binsidx_9),
               .ob_10(out_binsidx_10),
               .ob_11(out_binsidx_11),
               .ob_12(out_binsidx_12),
               .ob_13(out_binsidx_13),
               .ob_14(out_binsidx_14),
               .ob_15(out_binsidx_15),
               .ob_16(out_binsidx_16),
               .ob_17(out_binsidx_17),
               .out_number(out_number)
           );

cabac_binsort binsort(
                  .clk(clk),
                  .w_enable(out_to_bin_mix_enable),
                  .en(en),
                  .rst_n(rst_n),
                  .data_valid(write_valid),
                  .in_binsidx_0(out_binsidx_0),
                  .in_binsidx_1(out_binsidx_1),
                  .in_binsidx_2(out_binsidx_2),
                  .in_binsidx_3(out_binsidx_3),
                  .in_binsidx_4(out_binsidx_4),
                  .in_binsidx_5(out_binsidx_5),
                  .in_binsidx_6(out_binsidx_6),
                  .in_binsidx_7(out_binsidx_7),
                  .in_binsidx_8(out_binsidx_8),
                  .in_binsidx_9(out_binsidx_9),
                  .in_binsidx_10(out_binsidx_10),
                  .in_binsidx_11(out_binsidx_11),
                  .in_binsidx_12(out_binsidx_12),
                  .in_binsidx_13(out_binsidx_13),
                  .in_binsidx_14(out_binsidx_14),
                  .in_binsidx_15(out_binsidx_15),
                  .in_binsidx_16(out_binsidx_16),
                  .in_binsidx_17(out_binsidx_17),
                  .in_number(out_number),
                  .free_space(free_space),
                  .out_number_all(out_number_all),
                  .out_number_range(out_number_range),
                  .out_index_bypass(out_index_bypass),
                  .out_symbol_bypass(out_symbol_bypass),
                  .out_binsidx_0(out_sort_binsidx_0),
                  .out_binsidx_1(out_sort_binsidx_1),
                  .out_binsidx_2(out_sort_binsidx_2),
                  .out_binsidx_3(out_sort_binsidx_3)
              );

cabac_ucontext ucontext(
                   .clk(clk),
                   .enable(out_to_bin_mix_enable),
                   .en(en),
                   .rst_n(rst_n),
                   .gp_qp(gp_qp_w),
                   .gp_slice_type(gp_slice_type_w),
                   .gp_cabac_init_flag(gp_cabac_init_flag_w),
                   .init_done(context_init_done_w),

                   .number_range(out_number_range),
                   .number_all(out_number_all),
                   .index_bypass(out_index_bypass),
                   .symbol_bypass(out_symbol_bypass),

                   .binsidx_0(out_sort_binsidx_0),
                   .binsidx_1(out_sort_binsidx_1),
                   .binsidx_2(out_sort_binsidx_2),
                   .binsidx_3(out_sort_binsidx_3),

                   .out_number_range(out_number_range_1),
                   .out_number_all(out_number_all_1),
                   .out_index_bypass(out_index_bypass_1),
                   .out_symbol_bypass(out_symbol_bypass_1),

                   .out_context_0(out_context_0),
                   .out_context_1(out_context_1),
                   .out_context_2(out_context_2),
                   .out_context_3(out_context_3)
               );

cabac_rlps4 rlps4(
                .clk(clk),
                .enable(out_to_bin_mix_enable),
                .en(en),
                .rst_n(rst_n),

                .number_range(out_number_range_1),
                .number_all(out_number_all_1),
                .index_bypass(out_index_bypass_1),
                .symbol_bypass(out_symbol_bypass_1),

                .out_number_range(out_number_range_2),
                .out_number_all(out_number_all_2),
                .out_index_bypass(out_index_bypass_2),
                .out_symbol_bypass(out_symbol_bypass_2),

                .in_lpsmps_0(out_context_0[6]),
                .in_pstateidx_0(out_context_0[5:0]),
                .in_lpsmps_1(out_context_1[6]),
                .in_pstateidx_1(out_context_1[5:0]),
                .in_lpsmps_2(out_context_2[6]),
                .in_pstateidx_2(out_context_2[5:0]),
                .in_lpsmps_3(out_context_3[6]),
                .in_pstateidx_3(out_context_3[5:0]),

                .out_lpsmps_0(out_lpsmps_0),
                .out_four_rlps_0(out_four_lps_0),
                .out_four_rlps_shift_0(out_four_lps_shift_0),
                .out_lpsmps_1(out_lpsmps_1),
                .out_four_rlps_1(out_four_lps_1),
                .out_four_rlps_shift_1(out_four_lps_shift_1),
                .out_lpsmps_2(out_lpsmps_2),
                .out_four_rlps_2(out_four_lps_2),
                .out_four_rlps_shift_2(out_four_lps_shift_2),
                .out_lpsmps_3(out_lpsmps_3),
                .out_four_rlps_shift_3(out_four_lps_shift_3),
                .out_four_rlps_3(out_four_lps_3)
            );

cabac_urange4 urange4(
                  .clk(clk),
                  .en(en),
                  .rst_n(rst_n),
                  .enable(out_to_bin_mix_enable),

                  .number_range(out_number_range_2),
                  .number_all(out_number_all_2),
                  .index_bypass(out_index_bypass_2),
                  .symbol_bypass(out_symbol_bypass_2),

                  .out_number_all(out_number_all_3),
                  .out_index_bypass(out_index_bypass_3),
                  .out_symbol_bypass(out_symbol_bypass_3),

                  .in_lpsmps_0(out_lpsmps_0),
                  .in_four_lps_0(out_four_lps_0),
                  .in_four_lps_shift_0(out_four_lps_shift_0),
                  .in_lpsmps_1(out_lpsmps_1),
                  .in_four_lps_1(out_four_lps_1),
                  .in_four_lps_shift_1(out_four_lps_shift_1),
                  .in_lpsmps_2(out_lpsmps_2),
                  .in_four_lps_2(out_four_lps_2),
                  .in_four_lps_shift_2(out_four_lps_shift_2),
                  .in_lpsmps_3(out_lpsmps_3),
                  .in_four_lps_shift_3(out_four_lps_shift_3),
                  .in_four_lps_3(out_four_lps_3),

                  .out_lpsmps_0(out_ur_lpsmps_0),
                  .out_range_0(out_ur_range_0),
                  .out_rlps_0(out_ur_rlps_0),
                  .out_shift_0(out_ur_shift_0),
                  .out_lpsmps_1(out_ur_lpsmps_1),
                  .out_range_1(out_ur_range_1),
                  .out_rlps_1(out_ur_rlps_1),
                  .out_shift_1(out_ur_shift_1),
                  .out_lpsmps_2(out_ur_lpsmps_2),
                  .out_range_2(out_ur_range_2),
                  .out_rlps_2(out_ur_rlps_2),
                  .out_shift_2(out_ur_shift_2),
                  .out_lpsmps_3(out_ur_lpsmps_3),
                  .out_range_3(out_ur_range_3),
                  .out_rlps_3(out_ur_rlps_3),
                  .out_shift_3(out_ur_shift_3),
                  .out_range_4(out_ur_range_4)
              );

cabac_binmix binmix(
                 .clk(clk),
                 .w_enable(out_to_bit_pack_enable),
                 .r_enable(out_to_bin_mix_enable),
                 .en(en),
                 .rst_n(rst_n),

                 .free_space(free_space_mix),

                 .in_number_all(out_number_all_3),
                 .out_number(out_number_4),

                 .index_bypass(out_index_bypass_3),
                 .symbol_bypass(out_symbol_bypass_3),

                 .in_lpsmps_0(out_ur_lpsmps_0),
                 .in_range_0(out_ur_range_0),
                 .in_rlps_0(out_ur_rlps_0),
                 .in_shift_0(out_ur_shift_0),
                 .in_lpsmps_1(out_ur_lpsmps_1),
                 .in_range_1(out_ur_range_1),
                 .in_rlps_1(out_ur_rlps_1),
                 .in_shift_1(out_ur_shift_1),
                 .in_lpsmps_2(out_ur_lpsmps_2),
                 .in_range_2(out_ur_range_2),
                 .in_rlps_2(out_ur_rlps_2),
                 .in_shift_2(out_ur_shift_2),
                 .in_lpsmps_3(out_ur_lpsmps_3),
                 .in_range_3(out_ur_range_3),
                 .in_rlps_3(out_ur_rlps_3),
                 .in_shift_3(out_ur_shift_3),
                 .in_range_4(out_ur_range_4),

                 .out_bypass_0(out_mix_bypass_0),
                 .out_bypass_1(out_mix_bypass_1),
                 .out_bypass_2(out_mix_bypass_2),
                 .out_bypass_3(out_mix_bypass_3),
                 .out_bypass_4(out_mix_bypass_4),

                 .out_lpsmps_0(out_mix_lpsmps_0),
                 .out_lpsmps_1(out_mix_lpsmps_1),
                 .out_lpsmps_2(out_mix_lpsmps_2),
                 .out_lpsmps_3(out_mix_lpsmps_3),
                 .out_lpsmps_4(out_mix_lpsmps_4),

                 .out_shift_0(out_mix_shift_0),
                 .out_shift_1(out_mix_shift_1),
                 .out_shift_2(out_mix_shift_2),
                 .out_shift_3(out_mix_shift_3),
                 .out_shift_4(out_mix_shift_4),

                 .out_r_rmps_0(out_mix_r_rmps_0),
                 .out_r_rmps_1(out_mix_r_rmps_1),
                 .out_r_rmps_2(out_mix_r_rmps_2),
                 .out_r_rmps_3(out_mix_r_rmps_3),
                 .out_r_rmps_4(out_mix_r_rmps_4)
             );

cabac_ulow cabac_update_low(
               .clk(clk),
               .enable(out_to_bit_pack_enable),
               .en(en),
               .rst_n(rst_n),

               .end_slice(out_end_slice_low),

               .in_number(out_number_4),
               .out_number(out_number_5),

               .bypass_0(out_mix_bypass_0),
               .bypass_1(out_mix_bypass_1),
               .bypass_2(out_mix_bypass_2),
               .bypass_3(out_mix_bypass_3),
               .bypass_4(out_mix_bypass_4),

               .lpsmps_0(out_mix_lpsmps_0),
               .lpsmps_1(out_mix_lpsmps_1),
               .lpsmps_2(out_mix_lpsmps_2),
               .lpsmps_3(out_mix_lpsmps_3),
               .lpsmps_4(out_mix_lpsmps_4),

               .shift_0(out_mix_shift_0),
               .shift_1(out_mix_shift_1),
               .shift_2(out_mix_shift_2),
               .shift_3(out_mix_shift_3),
               .shift_4(out_mix_shift_4),

               .r_rmps_0(out_mix_r_rmps_0),
               .r_rmps_1(out_mix_r_rmps_1),
               .r_rmps_2(out_mix_r_rmps_2),
               .r_rmps_3(out_mix_r_rmps_3),
               .r_rmps_4(out_mix_r_rmps_4),

               .out_shift_0(out_low_shift_0),
               .out_shift_1(out_low_shift_1),
               .out_shift_2(out_low_shift_2),
               .out_shift_3(out_low_shift_3),
               .out_shift_4(out_low_shift_4),

               .out_overflow_0(out_low_overflow_0),
               .out_overflow_1(out_low_overflow_1),
               .out_overflow_2(out_low_overflow_2),
               .out_overflow_3(out_low_overflow_3),
               .out_overflow_4(out_low_overflow_4),

               .out_buffer_0(out_low_buffer_0),
               .out_buffer_1(out_low_buffer_1),
               .out_buffer_2(out_low_buffer_2),
               .out_buffer_3(out_low_buffer_3),
               .out_buffer_4(out_low_buffer_4)
           );

cabac_ulow_refine cabac_update_low_refine(
                      .clk(clk),
                      .enable(out_to_bit_pack_enable),
                      .en(en),
                      .rst_n(rst_n),
                      .in_number(out_number_5),

                      .shift_0(out_low_shift_0),
                      .shift_1(out_low_shift_1),
                      .shift_2(out_low_shift_2),
                      .shift_3(out_low_shift_3),
                      .shift_4(out_low_shift_4),

                      .overflow_0(out_low_overflow_0),
                      .overflow_1(out_low_overflow_1),
                      .overflow_2(out_low_overflow_2),
                      .overflow_3(out_low_overflow_3),
                      .overflow_4(out_low_overflow_4),

                      .buffer_0(out_low_buffer_0),
                      .buffer_1(out_low_buffer_1),
                      .buffer_2(out_low_buffer_2),
                      .buffer_3(out_low_buffer_3),
                      .buffer_4(out_low_buffer_4),

                      .length(out_low_length),
                      .flag_flow(out_low_flag_flow),
                      .string_to_update(out_low_string_to_update),
                      .zero_position(out_low_zero_position)
                  );

cabac_bitpack cabac_bit_pack(
                  .clk(clk),
                  .r_enable(out_to_bit_pack_enable),
                  .en(en),
                  .rst_n(rst_n),

                  .in_end_slice(out_end_slice_bit_pack),

                  .left_space(left_space_bit_pack),

                  .length(out_low_length),
                  .flag_flow(out_low_flag_flow),
                  .string_to_update(out_low_string_to_update),
                  .zero_position(out_low_zero_position),

                  .out_ready(bs_val_o),
                  .output_byte(bs_data_o)
              );
assign out_to_bit_pack_enable = left_space_bit_pack<35 ? 0 : 1;
assign out_to_bin_mix_enable  = free_space_mix<9 ? 0 : 1;



reg [15:0]  bins_bina2low, bins_bina2bitpack;

always @ (posedge clk or negedge rst_n)
    if(~rst_n)
    begin
        bins_bina2low <= 0;
        bins_bina2bitpack <= 0;
    end
    else if(~en)
    begin
        bins_bina2low <= 0;
        bins_bina2bitpack <= 0;
    end
    else
    begin
        bins_bina2low <= bins_bina2low + (write_valid ? out_number : 0) - out_number_4;
        bins_bina2bitpack <= bins_bina2bitpack + (write_valid ? out_number : 0) - out_number_5;
    end

//assign out_end_slice_low    = flag_end_slice && (out_number==0) && (free_space==50) && (out_number_all==0) && (out_number_all_1==0) && (out_number_all_2==0) && (out_number_all_3==0) && (out_number_4==0) && (free_space_mix==31);
assign out_end_slice_low = flag_end_slice && (bins_bina2low==0) && (out_number==0);
assign out_end_slice_bit_pack = out_end_slice_low && (out_number_5==0) && (out_low_length==0);
//assign out_end_slice_bit_pack = flag_end_slice && !bins_bina2bitpack;

assign cabac_done_o = cabac_done_w;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        slice_done_o <= 0;
    end
    else if(~en)
    begin
        slice_done_o <= 0;
    end
    else
    begin
        slice_done_o <= out_end_slice_bit_pack && (left_space_bit_pack>=120) ;
    end
end

endmodule












