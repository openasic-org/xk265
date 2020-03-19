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
// Filename       : cabac_se_prepare_mv.v
// Author         : liwei
// Created        : 2018/1/20
// Description    : syntax elements related mvd
// DATA & EDITION:  2018/1/20 1.0   liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module cabac_se_prepare_mv(
           cu_mv_data_i        ,

           se_pair_mv_0_0_o    ,
           se_pair_mv_0_1_o    ,
           se_pair_mv_0_2_o    ,
           se_pair_mv_0_3_o    ,
           se_pair_mv_0_4_o    ,
           se_pair_mv_0_5_o    ,
           se_pair_mv_0_6_o    ,
           se_pair_mv_0_7_o    ,
           se_pair_mv_0_8_o    ,

           se_pair_mv_1_0_o    ,
           se_pair_mv_1_1_o    ,
           se_pair_mv_1_2_o    ,
           se_pair_mv_1_3_o    ,
           se_pair_mv_1_4_o    ,
           se_pair_mv_1_5_o    ,
           se_pair_mv_1_6_o    ,
           se_pair_mv_1_7_o    ,
           se_pair_mv_1_8_o
       );
//-----------------------------------------------------------------------------------------------------------------------------
//
//              inputs and outputs declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
input         [(4*`MVD_WIDTH+5):0]     cu_mv_data_i                  ;

output        [22:0]                   se_pair_mv_0_0_o             ;
output        [22:0]                   se_pair_mv_0_1_o             ;
output        [22:0]                   se_pair_mv_0_2_o             ;
output        [22:0]                   se_pair_mv_0_3_o             ;
output        [22:0]                   se_pair_mv_0_4_o             ;
output        [22:0]                   se_pair_mv_0_5_o             ;
output        [22:0]                   se_pair_mv_0_6_o             ;
output        [22:0]                   se_pair_mv_0_7_o             ;
output        [14:0]                   se_pair_mv_0_8_o             ;

output        [22:0]                   se_pair_mv_1_0_o             ;
output        [22:0]                   se_pair_mv_1_1_o             ;
output        [22:0]                   se_pair_mv_1_2_o             ;
output        [22:0]                   se_pair_mv_1_3_o             ;
output        [22:0]                   se_pair_mv_1_4_o             ;
output        [22:0]                   se_pair_mv_1_5_o             ;
output        [22:0]                   se_pair_mv_1_6_o             ;
output        [22:0]                   se_pair_mv_1_7_o             ;
output        [14:0]                   se_pair_mv_1_8_o             ;

//-----------------------------------------------------------------------------------------------------------------------------
//
//              wire signals declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
wire          [2:0]                    mvp_idx_0_w                   ;
wire          [2*`MVD_WIDTH-1:0]       mv_curr_0_w                   ;
wire          [2:0]                    mvp_idx_1_w                   ;
wire          [2*`MVD_WIDTH-1:0]       mv_curr_1_w                   ;

assign   mvp_idx_0_w        =      cu_mv_data_i[ 5:3 ]               ;
assign   mv_curr_0_w        =      cu_mv_data_i[49:28]               ;
assign   mvp_idx_1_w        =      cu_mv_data_i[ 2:0 ]               ;
assign   mv_curr_1_w        =      cu_mv_data_i[ 27:6]               ;

//-----------------------------------------------------------------------------------------------------------------------------
//
//             mv binarization
//
//-----------------------------------------------------------------------------------------------------------------------------

wire          [22:0]         se_pair_mv_0_0_w                       ;
wire          [22:0]         se_pair_mv_0_1_w                       ;
wire          [22:0]         se_pair_mv_0_2_w                       ;
wire          [22:0]         se_pair_mv_0_3_w                       ;
wire          [22:0]         se_pair_mv_0_4_w                       ;
wire          [22:0]         se_pair_mv_0_5_w                       ;
wire          [22:0]         se_pair_mv_0_6_w                       ;
wire          [22:0]         se_pair_mv_0_7_w                       ;
wire          [14:0]         se_pair_mv_0_8_w                       ;

wire          [22:0]         se_pair_mv_1_0_w                       ;
wire          [22:0]         se_pair_mv_1_1_w                       ;
wire          [22:0]         se_pair_mv_1_2_w                       ;
wire          [22:0]         se_pair_mv_1_3_w                       ;
wire          [22:0]         se_pair_mv_1_4_w                       ;
wire          [22:0]         se_pair_mv_1_5_w                       ;
wire          [22:0]         se_pair_mv_1_6_w                       ;
wire          [22:0]         se_pair_mv_1_7_w                       ;
wire          [14:0]         se_pair_mv_1_8_w                       ;


cabac_se_prepare_mvd  cabac_se_prepare_mvd_u0 (
                          .mvp_idx_i         ( mvp_idx_0_w             ),
                          .mv_i              ( mv_curr_0_w             ),

                          .se_pair_mv_0_o   ( se_pair_mv_0_0_w       ),
                          .se_pair_mv_1_o   ( se_pair_mv_0_1_w       ),
                          .se_pair_mv_2_o   ( se_pair_mv_0_2_w       ),
                          .se_pair_mv_3_o   ( se_pair_mv_0_3_w       ),
                          .se_pair_mv_4_o   ( se_pair_mv_0_4_w       ),
                          .se_pair_mv_5_o   ( se_pair_mv_0_5_w       ),
                          .se_pair_mv_6_o   ( se_pair_mv_0_6_w       ),
                          .se_pair_mv_7_o   ( se_pair_mv_0_7_w       ),
                          .se_pair_mv_8_o   ( se_pair_mv_0_8_w       )
                      );

cabac_se_prepare_mvd  cabac_se_prepare_mvd_u1(
                          .mvp_idx_i         ( mvp_idx_1_w             ),
                          .mv_i              ( mv_curr_1_w             ),

                          .se_pair_mv_0_o   ( se_pair_mv_1_0_w       ),
                          .se_pair_mv_1_o   ( se_pair_mv_1_1_w       ),
                          .se_pair_mv_2_o   ( se_pair_mv_1_2_w       ),
                          .se_pair_mv_3_o   ( se_pair_mv_1_3_w       ),
                          .se_pair_mv_4_o   ( se_pair_mv_1_4_w       ),
                          .se_pair_mv_5_o   ( se_pair_mv_1_5_w       ),
                          .se_pair_mv_6_o   ( se_pair_mv_1_6_w       ),
                          .se_pair_mv_7_o   ( se_pair_mv_1_7_w       ),
                          .se_pair_mv_8_o   ( se_pair_mv_1_8_w       )
                      );

assign    se_pair_mv_0_0_o  =  se_pair_mv_0_0_w                     ;
assign    se_pair_mv_0_1_o  =  se_pair_mv_0_1_w               ;
assign    se_pair_mv_0_2_o  =  se_pair_mv_0_2_w               ;
assign    se_pair_mv_0_3_o  =  se_pair_mv_0_3_w               ;
assign    se_pair_mv_0_4_o  =  se_pair_mv_0_4_w               ;
assign    se_pair_mv_0_5_o  =  se_pair_mv_0_5_w               ;
assign    se_pair_mv_0_6_o  =  se_pair_mv_0_6_w               ;
assign    se_pair_mv_0_7_o  =  se_pair_mv_0_7_w               ;
assign    se_pair_mv_0_8_o  =  se_pair_mv_0_8_w               ;

assign    se_pair_mv_1_0_o  =  se_pair_mv_1_0_w                     ;
assign    se_pair_mv_1_1_o  =  se_pair_mv_1_1_w               ;
assign    se_pair_mv_1_2_o  =  se_pair_mv_1_2_w               ;
assign    se_pair_mv_1_3_o  =  se_pair_mv_1_3_w               ;
assign    se_pair_mv_1_4_o  =  se_pair_mv_1_4_w               ;
assign    se_pair_mv_1_5_o  =  se_pair_mv_1_5_w               ;
assign    se_pair_mv_1_6_o  =  se_pair_mv_1_6_w               ;
assign    se_pair_mv_1_7_o  =  se_pair_mv_1_7_w               ;
assign    se_pair_mv_1_8_o  =  se_pair_mv_1_8_w               ;


endmodule
