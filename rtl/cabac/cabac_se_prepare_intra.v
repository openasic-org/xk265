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
//-----------------------------------------------------------------------------------------------------------------------------
// Filename       : cabac_se_prepare_intra.v
// Author         : liwei
// Created        : 2018/1/05
// Description    : syntax elements of intra mode CU
// DATA & EDITION:  2018/1/05 1.0   liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module cabac_se_prepare_intra(
           // input
           cu_depth_i              ,
           cu_sub_div_i            ,
           cu_luma_pred_mode_i     ,
           //cu_chroma_pred_mode_i   ,
           cu_luma_pred_left_mode_i,
           cu_luma_pred_top_mode_i ,

           //  output
           se_pair_intra_0_o      ,
           se_pair_intra_1_o      ,
           se_pair_intra_2_o      ,
           se_pair_intra_3_o      ,
           se_pair_intra_4_o      ,
           se_pair_intra_5_o      ,
           se_pair_intra_6_o      ,
           se_pair_intra_7_o      ,
           se_pair_intra_8_o      ,
           se_pair_intra_9_o
       );
//-----------------------------------------------------------------------------------------------------------------------------
//
//                                input signals and output signals
//
//-----------------------------------------------------------------------------------------------------------------------------
input  [ 1:0] cu_depth_i               ; // cu_depth,0:64x64,1:32x32,2:16x16,3:8x8
input         cu_sub_div_i             ;
input  [5:0] cu_luma_pred_mode_i      ;
//input  [ 5:0] cu_chroma_pred_mode_i    ;
input  [23:0] cu_luma_pred_left_mode_i ;
input  [23:0] cu_luma_pred_top_mode_i  ;

// output
output [20:0] se_pair_intra_0_o       ;
output [20:0] se_pair_intra_1_o       ;
output [20:0] se_pair_intra_2_o       ;
output [20:0] se_pair_intra_3_o       ;
output [20:0] se_pair_intra_4_o       ;
output [20:0] se_pair_intra_5_o       ;
output [20:0] se_pair_intra_6_o       ;
output [20:0] se_pair_intra_7_o       ;
output [20:0] se_pair_intra_8_o       ;
output [20:0] se_pair_intra_9_o       ;

// -----------------------------------------------------------------------------------------------------------------------------
//
//    wire  and  reg declaration
//
// -----------------------------------------------------------------------------------------------------------------------------

/*wire     [5:0]    luma_curr_mode_3_w  =  cu_luma_pred_mode_i[ 5:0 ]     ;
  wire     [5:0]    luma_curr_mode_2_w  =  cu_luma_pred_mode_i[11:6 ]     ;
  wire     [5:0]    luma_curr_mode_1_w  =  cu_luma_pred_mode_i[17:12]     ;
  wire     [5:0]    luma_curr_mode_0_w  =  cu_luma_pred_mode_i[23:18]     ;*/
wire  [5:0] luma_curr_mode_0_w = cu_luma_pred_mode_i;

wire     [5:0]    luma_left_mode_3_w  =  cu_luma_pred_mode_i     ;
wire     [5:0]    luma_left_mode_2_w  =  cu_luma_pred_left_mode_i[5:0 ] ;
wire     [5:0]    luma_left_mode_1_w  =  cu_luma_pred_mode_i     ;
wire     [5:0]    luma_left_mode_0_w  =  cu_luma_pred_left_mode_i[17:12];

wire     [5:0]    luma_top_mode_3_w   =  cu_luma_pred_mode_i     ;
wire     [5:0]    luma_top_mode_2_w   =  cu_luma_pred_mode_i     ;
wire     [5:0]    luma_top_mode_1_w   =  cu_luma_pred_top_mode_i[5:0]   ;
wire     [5:0]    luma_top_mode_0_w   =  cu_luma_pred_top_mode_i[11:6]  ;

wire     num_pu_w_flag  = ( (cu_depth_i==2'b11) ? (cu_sub_div_i ? 1'b1 : 1'b0) : 1'b0 );//1: 4 sub pu , 0 :1 sub pu

// -----------------------------------------------------------------------------------------------------------------------------
//
//    intra luma mode prepare
//
// -----------------------------------------------------------------------------------------------------------------------------
wire    [20:0]  prev_intra_luma_pred_flag_0_w,prev_intra_luma_pred_flag_1_w,prev_intra_luma_pred_flag_2_w,prev_intra_luma_pred_flag_3_w;
wire    [20:0]  mpm_idx_or_rem_luma_mode_0_w;
wire    [20:0]  mpm_idx_or_rem_luma_mode_1_w;
wire    [20:0]  mpm_idx_or_rem_luma_mode_2_w;
wire    [20:0]  mpm_idx_or_rem_luma_mode_3_w;

cabac_se_prepare_intra_luma   cabac_se_prepare_intra_luma_u0(
                                  .luma_curr_mode_i      ( luma_curr_mode_0_w    ),
                                  .luma_left_mode_i      ( luma_left_mode_0_w    ),
                                  .luma_top_mode_i       ( luma_top_mode_0_w     ),

                                  .prev_intra_luma_pred_flag_o( prev_intra_luma_pred_flag_0_w),
                                  .mpm_idx_or_rem_luma_mode_o ( mpm_idx_or_rem_luma_mode_0_w)
                              );

cabac_se_prepare_intra_luma   cabac_se_prepare_intra_luma_u1(
                                  .luma_curr_mode_i      ( luma_curr_mode_0_w    ),
                                  .luma_left_mode_i      ( luma_left_mode_1_w    ),
                                  .luma_top_mode_i       ( luma_top_mode_1_w     ),

                                  .prev_intra_luma_pred_flag_o( prev_intra_luma_pred_flag_1_w),
                                  .mpm_idx_or_rem_luma_mode_o ( mpm_idx_or_rem_luma_mode_1_w)
                              );

cabac_se_prepare_intra_luma   cabac_se_prepare_intra_luma_u2(
                                  .luma_curr_mode_i      ( luma_curr_mode_0_w    ),
                                  .luma_left_mode_i      ( luma_left_mode_2_w    ),
                                  .luma_top_mode_i       ( luma_top_mode_2_w     ),

                                  .prev_intra_luma_pred_flag_o( prev_intra_luma_pred_flag_2_w),
                                  .mpm_idx_or_rem_luma_mode_o ( mpm_idx_or_rem_luma_mode_2_w)
                              );

cabac_se_prepare_intra_luma   cabac_se_prepare_intra_luma_u3(
                                  .luma_curr_mode_i      ( luma_curr_mode_0_w    ),
                                  .luma_left_mode_i      ( luma_left_mode_3_w    ),
                                  .luma_top_mode_i       ( luma_top_mode_3_w     ),

                                  .prev_intra_luma_pred_flag_o( prev_intra_luma_pred_flag_3_w),
                                  .mpm_idx_or_rem_luma_mode_o ( mpm_idx_or_rem_luma_mode_3_w)
                              );

// -----------------------------------------------------------------------------------------------------------------------------
//
//    chroma mode transfer
//
// -----------------------------------------------------------------------------------------------------------------------------
wire  [20:0]  intra_chroma_pred_mode_w;

/*wire    [5:0]   ui_luma_mode_w              ;
reg     [5:0]   chroma_candi_mode_0_w       ;
reg     [5:0]   chroma_candi_mode_1_w       ;
reg     [5:0]   chroma_candi_mode_2_w       ;
reg     [5:0]   chroma_candi_mode_3_w       ;
 
reg     [2:0]   chroma_dir_candi_r          ;
 
assign   ui_luma_mode_w         =      cu_luma_pred_mode_i[5:0]  ;
always @* begin 
    if(ui_luma_mode_w == 6'd0) begin 
        chroma_candi_mode_0_w  =  6'd34 ;
    chroma_candi_mode_1_w  =  6'd26 ;
    chroma_candi_mode_2_w  =  6'd10 ;
        chroma_candi_mode_3_w  =  6'd1  ;
  end 
    else if(ui_luma_mode_w == 6'd26) begin 
        chroma_candi_mode_0_w  =  6'd0  ; 
    chroma_candi_mode_1_w  =  6'd34 ; 
    chroma_candi_mode_2_w  =  6'd10 ; 
        chroma_candi_mode_3_w  =  6'd1  ; 
  end 
    else if(ui_luma_mode_w == 6'd10) begin
        chroma_candi_mode_0_w  =  6'd0  ; 
    chroma_candi_mode_1_w  =  6'd26 ; 
    chroma_candi_mode_2_w  =  6'd34 ; 
        chroma_candi_mode_3_w  =  6'd1  ; 
  end 
  else if(ui_luma_mode_w == 6'd1)begin 
        chroma_candi_mode_0_w  =  6'd0  ; 
    chroma_candi_mode_1_w  =  6'd26 ; 
    chroma_candi_mode_2_w  =  6'd10 ; 
        chroma_candi_mode_3_w  =  6'd34 ; 
  end 
  else begin 
        chroma_candi_mode_0_w  =  6'd0  ;
    chroma_candi_mode_1_w  =  6'd26 ;
    chroma_candi_mode_2_w  =  6'd10 ;
        chroma_candi_mode_3_w  =  6'd1  ;
  end 
end 
 
always @* begin 
    if(cu_chroma_pred_mode_i == chroma_candi_mode_0_w)
      chroma_dir_candi_r  =  3'd0    ;
    else if(cu_chroma_pred_mode_i == chroma_candi_mode_1_w)
      chroma_dir_candi_r  =  3'd1    ;  
    else if(cu_chroma_pred_mode_i == chroma_candi_mode_2_w)
      chroma_dir_candi_r  =  3'd2    ;
    else if(cu_chroma_pred_mode_i == chroma_candi_mode_3_w)
      chroma_dir_candi_r  =  3'd3    ;
  else 
      chroma_dir_candi_r  =  3'd4    ;
end 
*/

assign intra_chroma_pred_mode_w = {5'h0,3'd4,4'h0,9'h00f};

// -----------------------------------------------------------------------------------------------------------------------------
//
//    intra part size transfer
//
// -----------------------------------------------------------------------------------------------------------------------------
wire  [20:0]  part_mode_of_intra_w;
wire    [20:0]  part_mode_of_intra_temp;

assign    part_mode_of_intra_temp   =  {7'h0,!num_pu_w_flag,4'h1,9'h008};
//assign    part_mode_of_intra_w      =  (cu_depth_i==2'b10)?(cu_sub_div_i?part_mode_of_intra_temp:21'b0):part_mode_of_intra_temp;
assign    part_mode_of_intra_w = (cu_depth_i==2'b11)?part_mode_of_intra_temp:21'b0;
// -----------------------------------------------------------------------------------------------------------------------------
//
//    output signals
//
// -----------------------------------------------------------------------------------------------------------------------------


assign  se_pair_intra_0_o   =  part_mode_of_intra_w ;
assign  se_pair_intra_1_o   =  prev_intra_luma_pred_flag_0_w ;
assign  se_pair_intra_2_o   =  num_pu_w_flag ?  prev_intra_luma_pred_flag_1_w : 21'b0;
assign  se_pair_intra_3_o   =  num_pu_w_flag ?  prev_intra_luma_pred_flag_2_w : 21'b0;
assign  se_pair_intra_4_o   =  num_pu_w_flag ?  prev_intra_luma_pred_flag_3_w : mpm_idx_or_rem_luma_mode_0_w;
assign  se_pair_intra_5_o   =  num_pu_w_flag ?  mpm_idx_or_rem_luma_mode_0_w : intra_chroma_pred_mode_w;
assign  se_pair_intra_6_o   =  num_pu_w_flag ?  mpm_idx_or_rem_luma_mode_1_w : 21'b0;
assign  se_pair_intra_7_o   =  num_pu_w_flag ?  mpm_idx_or_rem_luma_mode_2_w : 21'b0;
assign  se_pair_intra_8_o   =  num_pu_w_flag ?  mpm_idx_or_rem_luma_mode_3_w : 21'b0;
assign  se_pair_intra_9_o   =  num_pu_w_flag ?  intra_chroma_pred_mode_w: 21'b0;






endmodule

