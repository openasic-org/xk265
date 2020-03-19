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
//-----------------------------------------------------------------------------------------------------------------------------
// Filename       : cabac_se_prepare_mvd.v
// Author         : liwei
// Created        : 2018/1/20
// Description    : syntax elements related mvd
// DATA & EDITION:  2018/1/20   1.0     liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module cabac_se_prepare_mvd(
           mvp_idx_i         ,
           mv_i              ,

           se_pair_mv_0_o    ,
           se_pair_mv_1_o    ,
           se_pair_mv_2_o    ,
           se_pair_mv_3_o    ,
           se_pair_mv_4_o    ,
           se_pair_mv_5_o    ,
           se_pair_mv_6_o    ,
           se_pair_mv_7_o    ,
           se_pair_mv_8_o

       );

//-----------------------------------------------------------------------------------------------------------------------------
//
//              inputs and outputs declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
input         [2:0]                    mvp_idx_i                     ;
input         [2*`MVD_WIDTH-1:0]       mv_i                          ;

output        [22:0]                   se_pair_mv_0_o               ;
output        [22:0]                   se_pair_mv_1_o               ;
output        [22:0]                   se_pair_mv_2_o               ;
output        [22:0]                   se_pair_mv_3_o               ;
output        [22:0]                   se_pair_mv_4_o               ;
output        [22:0]                   se_pair_mv_5_o               ;
output        [22:0]                   se_pair_mv_6_o               ;
output        [22:0]                   se_pair_mv_7_o               ;

output        [14:0]                   se_pair_mv_8_o              ;
//-----------------------------------------------------------------------------------------------------------------------------
//
//                 wire and reg declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
wire  [10:0]                   mv_x_s_w                      ;
wire  [10:0]                   mv_y_s_w                      ;

wire          [10:0]                   mv_x_abs_w                    ;
wire          [10:0]                   mv_y_abs_w                    ;

wire                                   abs_mvd_greater0_flag_x_w     ;
wire                                   abs_mvd_greater0_flag_y_w     ;

wire                                   abs_mvd_greater1_flag_x_w     ;
wire                                   abs_mvd_greater1_flag_y_w     ;

wire          [9:0]                    abs_mvd_minus2_x_w            ;
wire          [9:0]                    abs_mvd_minus2_y_w            ;

wire                                   mvd_sign_flag_x_w             ;
wire                                   mvd_sign_flag_y_w             ;

// mvp idx
wire                                   mvp_lx_flag       ;

wire          [22:0]                   se_pair_mv_0_w               ; // mv
wire          [22:0]                   se_pair_mv_1_w               ; // mv
reg           [22:0]                   se_pair_mv_2_r               ; // mv
reg           [22:0]                   se_pair_mv_3_r               ; // mv
reg           [22:0]                   se_pair_mv_4_r               ; // mv
reg           [22:0]                   se_pair_mv_5_r               ; // mv
reg           [22:0]                   se_pair_mv_6_r               ; // mv
reg           [22:0]                   se_pair_mv_7_r               ; // mv

wire          [14:0]                   se_pair_mv_8_w              ; // mvp idx


//-----------------------------------------------------------------------------------------------------------------------------
//
//                 mv ses
//
//-----------------------------------------------------------------------------------------------------------------------------
assign   mv_x_s_w            =  mv_i[21:11]                                    ;
assign   mv_y_s_w            =  mv_i[10:0 ]                                    ;

assign   mv_x_abs_w          =  mv_x_s_w[10] ? (~mv_x_s_w + 1'b1) : mv_x_s_w   ;
assign   mv_y_abs_w          =  mv_y_s_w[10] ? (~mv_y_s_w + 1'b1) : mv_y_s_w   ;

assign   abs_mvd_greater0_flag_x_w=  !(mv_x_s_w==0)                              ;
assign   abs_mvd_greater0_flag_y_w=  !(mv_y_s_w==0)                              ;

assign   abs_mvd_greater1_flag_x_w     =  !(mv_x_abs_w[10:1]==0)                 ;
assign   abs_mvd_greater1_flag_y_w     =  !(mv_y_abs_w[10:1]==0)                 ;

assign   mvd_sign_flag_x_w    =  mv_x_s_w[10]                                  ;
assign   mvd_sign_flag_y_w    =  mv_y_s_w[10]                                  ;

assign   abs_mvd_minus2_x_w   =   mv_x_abs_w[9:0] - 10'd2                         ;
assign   abs_mvd_minus2_y_w   =   mv_y_abs_w[9:0] - 10'd2                         ;


//transfer the ses of mvd
assign   se_pair_mv_0_w     =  {9'h0,abs_mvd_greater0_flag_x_w,4'h1,9'h16}        ;
assign   se_pair_mv_1_w     =  {9'h0,abs_mvd_greater0_flag_y_w,4'h1,9'h16}        ;

// se_pair_mv_2_r
always @*
begin
    if(abs_mvd_greater0_flag_x_w)
        se_pair_mv_2_r      =  {9'h0,abs_mvd_greater1_flag_x_w,4'h1,9'h17}        ;
    else
        se_pair_mv_2_r      =  0             ;
end

// se_pair_mv_3_r
always @*
begin
    if(abs_mvd_greater0_flag_y_w)
        se_pair_mv_3_r      =  {9'h0,abs_mvd_greater1_flag_y_w,4'h1,9'h17}         ;
    else
        se_pair_mv_3_r      =  0             ;
end


//abs_mvd_minus2 and mvd_sign_flag

always @*
begin
    if(abs_mvd_greater1_flag_x_w)
        se_pair_mv_4_r        =  {abs_mvd_minus2_x_w,4'h1,9'h0be};
    else
        se_pair_mv_4_r        =  0;
end

always @*
begin
    if(abs_mvd_greater1_flag_y_w)
        se_pair_mv_5_r        =  {abs_mvd_minus2_y_w,4'h1,9'h0be};
    else
        se_pair_mv_5_r        =  0;
end

always @*
begin
    if(abs_mvd_greater0_flag_x_w)
        se_pair_mv_6_r        =  {9'h0,mvd_sign_flag_x_w,4'h1,9'h0bb};
    else
        se_pair_mv_6_r        =  0;
end

always @*
begin
    if(abs_mvd_greater0_flag_y_w)
        se_pair_mv_7_r        =  {9'h0,mvd_sign_flag_y_w,4'h1,9'h0bb};
    else
        se_pair_mv_7_r        =  0;

end


//-----------------------------------------------------------------------------------------------------------------------------
//
//                 mvp_idx binarization
//
//-----------------------------------------------------------------------------------------------------------------------------

assign   mvp_lx_flag=   !(mvp_idx_i==0)                              ;
// se_pair_mv_8_w
assign   se_pair_mv_8_w       =   {1'b0,mvp_lx_flag,4'h1,9'h0b0} ;


//-----------------------------------------------------------------------------------------------------------------------------
//
//                 output
//
//-----------------------------------------------------------------------------------------------------------------------------
assign   se_pair_mv_0_o     =   se_pair_mv_0_w                               ;
assign   se_pair_mv_1_o     =   se_pair_mv_1_w                               ;
assign   se_pair_mv_2_o     =   se_pair_mv_2_r                               ;
assign   se_pair_mv_3_o     =   se_pair_mv_3_r                               ;
assign   se_pair_mv_4_o     =   se_pair_mv_4_r                               ;
assign   se_pair_mv_5_o     =   se_pair_mv_5_r                               ;
assign   se_pair_mv_6_o     =   se_pair_mv_6_r                               ;
assign   se_pair_mv_7_o     =   se_pair_mv_7_r                               ;
assign   se_pair_mv_8_o     =   se_pair_mv_8_w                               ;


endmodule
