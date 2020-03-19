//-----------------------------------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITtu_veN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//------------------------------------------------------------------------------------------------
// Filename       : sao_statistic.v
// Author         : TANG
// Creatu_ved     :
// Description    :
//------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module sao_statistic(
        clk                 ,
        rst_n               ,
        state_i             ,
        // cfg
        sao_4x4_x_i         ,
        sao_4x4_y_i         ,
        sao_sel_i           , // YUV
        sao_4x4_x_o         ,
        sao_4x4_y_o         ,
        sao_sel_o           , // YUV
        // mode
        EO_0_0_i            ,
        EO_0_1_i            ,
        EO_0_2_i            ,
        EO_0_3_i            ,
        EO_45_0_i           ,
        EO_45_1_i           ,
        EO_45_2_i           ,
        EO_45_3_i           ,
        EO_90_0_i           ,
        EO_90_1_i           ,
        EO_90_2_i           ,
        EO_90_3_i           ,
        EO_135_0_i          ,
        EO_135_1_i          ,
        EO_135_2_i          ,
        EO_135_3_i          ,
        BO_0_i              ,
        BO_1_i              ,
        BO_2_i              ,
        BO_3_i              ,
        BO_4_i              ,
        BO_5_i              ,
        BO_6_i              ,
        BO_7_i              ,
        // rec & ori
        rec_line_i_1        ,
        rec_line_i_2        ,
        rec_line_i_3        ,
        rec_line_i_4        ,
        ori_line_i_0        ,
        ori_line_i_1        ,
        ori_line_i_2        ,
        ori_line_i_3        ,
        // output number and sum of diffs
        EO_0_0_num_o        ,
        EO_0_0_diff_o       ,
        EO_0_1_num_o        ,
        EO_0_1_diff_o       ,
        EO_0_2_num_o        ,
        EO_0_2_diff_o       ,
        EO_0_3_num_o        ,
        EO_0_3_diff_o       ,
        EO_45_0_num_o       ,
        EO_45_0_diff_o      ,
        EO_45_1_num_o       ,
        EO_45_1_diff_o      ,
        EO_45_2_num_o       ,
        EO_45_2_diff_o      ,
        EO_45_3_num_o       ,
        EO_45_3_diff_o      ,
        EO_90_0_num_o       ,
        EO_90_0_diff_o      ,
        EO_90_1_num_o       ,
        EO_90_1_diff_o      ,
        EO_90_2_num_o       ,
        EO_90_2_diff_o      ,
        EO_90_3_num_o       ,
        EO_90_3_diff_o      ,
        EO_135_0_num_o      ,
        EO_135_0_diff_o     ,
        EO_135_1_num_o      ,
        EO_135_1_diff_o     ,
        EO_135_2_num_o      ,
        EO_135_2_diff_o     ,
        EO_135_3_num_o      ,
        EO_135_3_diff_o     ,
        BO_0_num_o          ,
        BO_0_diff_o         ,
        BO_1_num_o          ,
        BO_1_diff_o         ,
        BO_2_num_o          ,
        BO_2_diff_o         ,
        BO_3_num_o          ,
        BO_3_diff_o         ,
        BO_4_num_o          ,
        BO_4_diff_o         ,
        BO_5_num_o          ,
        BO_5_diff_o         ,
        BO_6_num_o          ,
        BO_6_diff_o         ,
        BO_7_num_o          ,
        BO_7_diff_o
    );


parameter IDLE = 3'b000, LOAD = 3'b001, DBY = 3'b011, DBU = 3'b010, DBV = 3'b110, SAO = 3'b100, OUT = 3'b101;
parameter SAO_DIF_WIDTH = 18 ;
parameter SAO_NUM_WIDTH = 12 ;

input                               clk ,rst_n              ;
input           [   2 :0]           state_i                 ;

input           [4  -1:0]           sao_4x4_x_i             ;
input           [4  -1:0]           sao_4x4_y_i             ;
input           [2  -1:0]           sao_sel_i               ;

output   reg    [4  -1:0]           sao_4x4_x_o             ;
output   reg    [4  -1:0]           sao_4x4_y_o             ;
output   reg    [2  -1:0]           sao_sel_o               ;

input           [ 6*8-1:0]          rec_line_i_1            ;
input           [ 6*8-1:0]          rec_line_i_2            ;
input           [ 6*8-1:0]          rec_line_i_3            ;
input           [ 6*8-1:0]          rec_line_i_4            ;
input           [ 4*8-1:0]          ori_line_i_0            ;
input           [ 4*8-1:0]          ori_line_i_1            ;
input           [ 4*8-1:0]          ori_line_i_2            ;
input           [ 4*8-1:0]          ori_line_i_3            ;

output          [  SAO_NUM_WIDTH-1  :0]          EO_0_0_num_o            ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_0_0_diff_o           ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_0_1_num_o            ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_0_1_diff_o           ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_0_2_num_o            ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_0_2_diff_o           ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_0_3_num_o            ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_0_3_diff_o           ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_45_0_num_o           ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_45_0_diff_o          ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_45_1_num_o           ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_45_1_diff_o          ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_45_2_num_o           ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_45_2_diff_o          ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_45_3_num_o           ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_45_3_diff_o          ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_90_0_num_o           ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_90_0_diff_o          ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_90_1_num_o           ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_90_1_diff_o          ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_90_2_num_o           ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_90_2_diff_o          ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_90_3_num_o           ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_90_3_diff_o          ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_135_0_num_o          ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_135_0_diff_o         ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_135_1_num_o          ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_135_1_diff_o         ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_135_2_num_o          ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_135_2_diff_o         ;
output          [  SAO_NUM_WIDTH-1  :0]          EO_135_3_num_o          ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          EO_135_3_diff_o         ;
output          [  SAO_NUM_WIDTH-1  :0]          BO_0_num_o              ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          BO_0_diff_o             ;
output          [  SAO_NUM_WIDTH-1  :0]          BO_1_num_o              ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          BO_1_diff_o             ;
output          [  SAO_NUM_WIDTH-1  :0]          BO_2_num_o              ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          BO_2_diff_o             ;
output          [  SAO_NUM_WIDTH-1  :0]          BO_3_num_o              ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          BO_3_diff_o             ;
output          [  SAO_NUM_WIDTH-1  :0]          BO_4_num_o              ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          BO_4_diff_o             ;
output          [  SAO_NUM_WIDTH-1  :0]          BO_5_num_o              ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          BO_5_diff_o             ;
output          [  SAO_NUM_WIDTH-1  :0]          BO_6_num_o              ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          BO_6_diff_o             ;
output          [  SAO_NUM_WIDTH-1  :0]          BO_7_num_o              ;
output  signed  [  SAO_DIF_WIDTH-1  :0]          BO_7_diff_o             ;

reg             [  SAO_NUM_WIDTH-1  :0]          EO_0_0_num_o            ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_0_0_diff_o           ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_0_1_num_o            ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_0_1_diff_o           ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_0_2_num_o            ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_0_2_diff_o           ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_0_3_num_o            ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_0_3_diff_o           ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_45_0_num_o           ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_45_0_diff_o          ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_45_1_num_o           ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_45_1_diff_o          ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_45_2_num_o           ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_45_2_diff_o          ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_45_3_num_o           ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_45_3_diff_o          ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_90_0_num_o           ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_90_0_diff_o          ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_90_1_num_o           ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_90_1_diff_o          ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_90_2_num_o           ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_90_2_diff_o          ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_90_3_num_o           ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_90_3_diff_o          ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_135_0_num_o          ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_135_0_diff_o         ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_135_1_num_o          ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_135_1_diff_o         ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_135_2_num_o          ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_135_2_diff_o         ;
reg             [  SAO_NUM_WIDTH-1  :0]          EO_135_3_num_o          ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          EO_135_3_diff_o         ;
reg             [  SAO_NUM_WIDTH-1  :0]          BO_0_num_o              ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          BO_0_diff_o             ;
reg             [  SAO_NUM_WIDTH-1  :0]          BO_1_num_o              ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          BO_1_diff_o             ;
reg             [  SAO_NUM_WIDTH-1  :0]          BO_2_num_o              ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          BO_2_diff_o             ;
reg             [  SAO_NUM_WIDTH-1  :0]          BO_3_num_o              ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          BO_3_diff_o             ;
reg             [  SAO_NUM_WIDTH-1  :0]          BO_4_num_o              ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          BO_4_diff_o             ;
reg             [  SAO_NUM_WIDTH-1  :0]          BO_5_num_o              ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          BO_5_diff_o             ;
reg             [  SAO_NUM_WIDTH-1  :0]          BO_6_num_o              ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          BO_6_diff_o             ;
reg             [  SAO_NUM_WIDTH-1  :0]          BO_7_num_o              ;
reg     signed  [  SAO_DIF_WIDTH-1  :0]          BO_7_diff_o             ;

input       [16   -1 :0]            EO_0_0_i                ;
input       [16   -1 :0]            EO_0_1_i                ;
input       [16   -1 :0]            EO_0_2_i                ;
input       [16   -1 :0]            EO_0_3_i                ;
input       [16   -1 :0]            EO_45_0_i               ;
input       [16   -1 :0]            EO_45_1_i               ;
input       [16   -1 :0]            EO_45_2_i               ;
input       [16   -1 :0]            EO_45_3_i               ;
input       [16   -1 :0]            EO_90_0_i               ;
input       [16   -1 :0]            EO_90_1_i               ;
input       [16   -1 :0]            EO_90_2_i               ;
input       [16   -1 :0]            EO_90_3_i               ;
input       [16   -1 :0]            EO_135_0_i              ;
input       [16   -1 :0]            EO_135_1_i              ;
input       [16   -1 :0]            EO_135_2_i              ;
input       [16   -1 :0]            EO_135_3_i              ;
input       [16   -1 :0]            BO_0_i                  ;
input       [16   -1 :0]            BO_1_i                  ;
input       [16   -1 :0]            BO_2_i                  ;
input       [16   -1 :0]            BO_3_i                  ;
input       [16   -1 :0]            BO_4_i                  ;
input       [16   -1 :0]            BO_5_i                  ;
input       [16   -1 :0]            BO_6_i                  ;
input       [16   -1 :0]            BO_7_i                  ;

reg         [16   -1 :0]            EO_0_0                  ;
reg         [16   -1 :0]            EO_0_1                  ;
reg         [16   -1 :0]            EO_0_2                  ;
reg         [16   -1 :0]            EO_0_3                  ;
reg         [16   -1 :0]            EO_45_0                 ;
reg         [16   -1 :0]            EO_45_1                 ;
reg         [16   -1 :0]            EO_45_2                 ;
reg         [16   -1 :0]            EO_45_3                 ;
reg         [16   -1 :0]            EO_90_0                 ;
reg         [16   -1 :0]            EO_90_1                 ;
reg         [16   -1 :0]            EO_90_2                 ;
reg         [16   -1 :0]            EO_90_3                 ;
reg         [16   -1 :0]            EO_135_0                ;
reg         [16   -1 :0]            EO_135_1                ;
reg         [16   -1 :0]            EO_135_2                ;
reg         [16   -1 :0]            EO_135_3                ;
reg         [16   -1 :0]            BO_0                    ;
reg         [16   -1 :0]            BO_1                    ;
reg         [16   -1 :0]            BO_2                    ;
reg         [16   -1 :0]            BO_3                    ;
reg         [16   -1 :0]            BO_4                    ;
reg         [16   -1 :0]            BO_5                    ;
reg         [16   -1 :0]            BO_6                    ;
reg         [16   -1 :0]            BO_7                    ;

//calculate diff
wire signed [5       :0]            diff_00_w               ;
wire signed [5       :0]            diff_01_w               ;
wire signed [5       :0]            diff_02_w               ;
wire signed [5       :0]            diff_03_w               ;
wire signed [5       :0]            diff_04_w               ;
wire signed [5       :0]            diff_05_w               ;
wire signed [5       :0]            diff_06_w               ;
wire signed [5       :0]            diff_07_w               ;
wire signed [5       :0]            diff_08_w               ;
wire signed [5       :0]            diff_09_w               ;
wire signed [5       :0]            diff_10_w               ;
wire signed [5       :0]            diff_11_w               ;
wire signed [5       :0]            diff_12_w               ;
wire signed [5       :0]            diff_13_w               ;
wire signed [5       :0]            diff_14_w               ;
wire signed [5       :0]            diff_15_w               ;

reg  signed [5       :0]            diff_00_r               ;
reg  signed [5       :0]            diff_01_r               ;
reg  signed [5       :0]            diff_02_r               ;
reg  signed [5       :0]            diff_03_r               ;
reg  signed [5       :0]            diff_04_r               ;
reg  signed [5       :0]            diff_05_r               ;
reg  signed [5       :0]            diff_06_r               ;
reg  signed [5       :0]            diff_07_r               ;
reg  signed [5       :0]            diff_08_r               ;
reg  signed [5       :0]            diff_09_r               ;
reg  signed [5       :0]            diff_10_r               ;
reg  signed [5       :0]            diff_11_r               ;
reg  signed [5       :0]            diff_12_r               ;
reg  signed [5       :0]            diff_13_r               ;
reg  signed [5       :0]            diff_14_r               ;
reg  signed [5       :0]            diff_15_r               ;

always @ ( posedge  clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        sao_4x4_x_o <= 0 ;
        sao_4x4_y_o <= 0 ;
        sao_sel_o   <= 0 ;
    end else begin 
        sao_4x4_x_o <= sao_4x4_x_i ;
        sao_4x4_y_o <= sao_4x4_y_i ;
        sao_sel_o   <= sao_sel_i   ;
    end 
end 

assign diff_00_w = ori_line_i_3[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH] - rec_line_i_4[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH] ;
assign diff_01_w = ori_line_i_3[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH] - rec_line_i_4[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH] ;
assign diff_02_w = ori_line_i_3[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH] - rec_line_i_4[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH] ;
assign diff_03_w = ori_line_i_3[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH] - rec_line_i_4[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH] ;
assign diff_04_w = ori_line_i_2[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH] - rec_line_i_3[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH] ;
assign diff_05_w = ori_line_i_2[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH] - rec_line_i_3[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH] ;
assign diff_06_w = ori_line_i_2[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH] - rec_line_i_3[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH] ;
assign diff_07_w = ori_line_i_2[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH] - rec_line_i_3[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH] ;
assign diff_08_w = ori_line_i_1[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH] - rec_line_i_2[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH] ;
assign diff_09_w = ori_line_i_1[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH] - rec_line_i_2[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH] ;
assign diff_10_w = ori_line_i_1[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH] - rec_line_i_2[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH] ;
assign diff_11_w = ori_line_i_1[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH] - rec_line_i_2[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH] ;
assign diff_12_w = ori_line_i_0[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH] - rec_line_i_1[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH] ;
assign diff_13_w = ori_line_i_0[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH] - rec_line_i_1[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH] ;
assign diff_14_w = ori_line_i_0[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH] - rec_line_i_1[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH] ;
assign diff_15_w = ori_line_i_0[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH] - rec_line_i_1[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH] ;

always @ (posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        diff_00_r <= 0;
        diff_01_r <= 0;
        diff_02_r <= 0;
        diff_03_r <= 0;
        diff_04_r <= 0;
        diff_05_r <= 0;
        diff_06_r <= 0;
        diff_07_r <= 0;
        diff_08_r <= 0;
        diff_09_r <= 0;
        diff_10_r <= 0;
        diff_11_r <= 0;
        diff_12_r <= 0;
        diff_13_r <= 0;
        diff_14_r <= 0;
        diff_15_r <= 0;
    end 
    else begin 
        diff_00_r <= diff_00_w ;
        diff_01_r <= diff_01_w ;
        diff_02_r <= diff_02_w ;
        diff_03_r <= diff_03_w ;
        diff_04_r <= diff_04_w ;
        diff_05_r <= diff_05_w ;
        diff_06_r <= diff_06_w ;
        diff_07_r <= diff_07_w ;
        diff_08_r <= diff_08_w ;
        diff_09_r <= diff_09_w ;
        diff_10_r <= diff_10_w ;
        diff_11_r <= diff_11_w ;
        diff_12_r <= diff_12_w ;
        diff_13_r <= diff_13_w ;
        diff_14_r <= diff_14_w ;
        diff_15_r <= diff_15_w ;
    end 
end 

// delay mode
always @ ( posedge  clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        EO_0_0      <= 0 ;
        EO_0_1      <= 0 ;
        EO_0_2      <= 0 ;
        EO_0_3      <= 0 ;
        EO_45_0     <= 0 ;
        EO_45_1     <= 0 ;
        EO_45_2     <= 0 ;
        EO_45_3     <= 0 ;
        EO_90_0     <= 0 ;
        EO_90_1     <= 0 ;
        EO_90_2     <= 0 ;
        EO_90_3     <= 0 ;
        EO_135_0    <= 0 ;
        EO_135_1    <= 0 ;
        EO_135_2    <= 0 ;
        EO_135_3    <= 0 ;
        BO_0        <= 0 ;
        BO_1        <= 0 ;
        BO_2        <= 0 ;
        BO_3        <= 0 ;
        BO_4        <= 0 ;
        BO_5        <= 0 ;
        BO_6        <= 0 ;
        BO_7        <= 0 ;
    end 
    else if ( state_i == SAO ) begin 
        EO_0_0      <= EO_0_0_i   ;
        EO_0_1      <= EO_0_1_i   ;
        EO_0_2      <= EO_0_2_i   ;
        EO_0_3      <= EO_0_3_i   ;
        EO_45_0     <= EO_45_0_i  ;
        EO_45_1     <= EO_45_1_i  ;
        EO_45_2     <= EO_45_2_i  ;
        EO_45_3     <= EO_45_3_i  ;
        EO_90_0     <= EO_90_0_i  ;
        EO_90_1     <= EO_90_1_i  ;
        EO_90_2     <= EO_90_2_i  ;
        EO_90_3     <= EO_90_3_i  ;
        EO_135_0    <= EO_135_0_i ;
        EO_135_1    <= EO_135_1_i ;
        EO_135_2    <= EO_135_2_i ;
        EO_135_3    <= EO_135_3_i ;
        BO_0        <= BO_0_i     ;
        BO_1        <= BO_1_i     ;
        BO_2        <= BO_2_i     ;
        BO_3        <= BO_3_i     ;
        BO_4        <= BO_4_i     ;
        BO_5        <= BO_5_i     ;
        BO_6        <= BO_6_i     ;
        BO_7        <= BO_7_i     ;
    end 
    else begin 
        EO_0_0      <= 0 ;
        EO_0_1      <= 0 ;
        EO_0_2      <= 0 ;
        EO_0_3      <= 0 ;
        EO_45_0     <= 0 ;
        EO_45_1     <= 0 ;
        EO_45_2     <= 0 ;
        EO_45_3     <= 0 ;
        EO_90_0     <= 0 ;
        EO_90_1     <= 0 ;
        EO_90_2     <= 0 ;
        EO_90_3     <= 0 ;
        EO_135_0    <= 0 ;
        EO_135_1    <= 0 ;
        EO_135_2    <= 0 ;
        EO_135_3    <= 0 ;
        BO_0        <= 0 ;
        BO_1        <= 0 ;
        BO_2        <= 0 ;
        BO_3        <= 0 ;
        BO_4        <= 0 ;
        BO_5        <= 0 ;
        BO_6        <= 0 ;
        BO_7        <= 0 ;
    end 
end 

reg             [ SAO_NUM_WIDTH-1 :0]            EO_0_0_num          ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_0_0_diff         ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_0_1_num          ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_0_1_diff         ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_0_2_num          ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_0_2_diff         ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_0_3_num          ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_0_3_diff         ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_45_0_num         ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_45_0_diff        ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_45_1_num         ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_45_1_diff        ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_45_2_num         ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_45_2_diff        ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_45_3_num         ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_45_3_diff        ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_90_0_num         ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_90_0_diff        ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_90_1_num         ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_90_1_diff        ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_90_2_num         ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_90_2_diff        ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_90_3_num         ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_90_3_diff        ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_135_0_num        ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_135_0_diff       ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_135_1_num        ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_135_1_diff       ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_135_2_num        ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_135_2_diff       ;
reg             [ SAO_NUM_WIDTH-1 :0]            EO_135_3_num        ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            EO_135_3_diff       ;
reg             [ SAO_NUM_WIDTH-1 :0]            BO_0_num            ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            BO_0_diff           ;
reg             [ SAO_NUM_WIDTH-1 :0]            BO_1_num            ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            BO_1_diff           ;
reg             [ SAO_NUM_WIDTH-1 :0]            BO_2_num            ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            BO_2_diff           ;
reg             [ SAO_NUM_WIDTH-1 :0]            BO_3_num            ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            BO_3_diff           ;
reg             [ SAO_NUM_WIDTH-1 :0]            BO_4_num            ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            BO_4_diff           ;
reg             [ SAO_NUM_WIDTH-1 :0]            BO_5_num            ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            BO_5_diff           ;
reg             [ SAO_NUM_WIDTH-1 :0]            BO_6_num            ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            BO_6_diff           ;
reg             [ SAO_NUM_WIDTH-1 :0]            BO_7_num            ;
reg     signed  [ SAO_DIF_WIDTH-1 :0]            BO_7_diff           ;

wire            [  3:0]            EO_0_0_num_w        ;
wire    signed  [  9:0]            EO_0_0_diff_w       ;
wire            [  3:0]            EO_0_1_num_w        ;
wire    signed  [  9:0]            EO_0_1_diff_w       ;
wire            [  3:0]            EO_0_2_num_w        ;
wire    signed  [  9:0]            EO_0_2_diff_w       ;
wire            [  3:0]            EO_0_3_num_w        ;
wire    signed  [  9:0]            EO_0_3_diff_w       ;
wire            [  3:0]            EO_45_0_num_w       ;
wire    signed  [  9:0]            EO_45_0_diff_w      ;
wire            [  3:0]            EO_45_1_num_w       ;
wire    signed  [  9:0]            EO_45_1_diff_w      ;
wire            [  3:0]            EO_45_2_num_w       ;
wire    signed  [  9:0]            EO_45_2_diff_w      ;
wire            [  3:0]            EO_45_3_num_w       ;
wire    signed  [  9:0]            EO_45_3_diff_w      ;
wire            [  3:0]            EO_90_0_num_w       ;
wire    signed  [  9:0]            EO_90_0_diff_w      ;
wire            [  3:0]            EO_90_1_num_w       ;
wire    signed  [  9:0]            EO_90_1_diff_w      ;
wire            [  3:0]            EO_90_2_num_w       ;
wire    signed  [  9:0]            EO_90_2_diff_w      ;
wire            [  3:0]            EO_90_3_num_w       ;
wire    signed  [  9:0]            EO_90_3_diff_w      ;
wire            [  3:0]            EO_135_0_num_w      ;
wire    signed  [  9:0]            EO_135_0_diff_w     ;
wire            [  3:0]            EO_135_1_num_w      ;
wire    signed  [  9:0]            EO_135_1_diff_w     ;
wire            [  3:0]            EO_135_2_num_w      ;
wire    signed  [  9:0]            EO_135_2_diff_w     ;
wire            [  3:0]            EO_135_3_num_w      ;
wire    signed  [  9:0]            EO_135_3_diff_w     ;
wire            [  3:0]            BO_0_num_w          ;
wire    signed  [  9:0]            BO_0_diff_w         ;
wire            [  3:0]            BO_1_num_w          ;
wire    signed  [  9:0]            BO_1_diff_w         ;
wire            [  3:0]            BO_2_num_w          ;
wire    signed  [  9:0]            BO_2_diff_w         ;
wire            [  3:0]            BO_3_num_w          ;
wire    signed  [  9:0]            BO_3_diff_w         ;
wire            [  3:0]            BO_4_num_w          ;
wire    signed  [  9:0]            BO_4_diff_w         ;
wire            [  3:0]            BO_5_num_w          ;
wire    signed  [  9:0]            BO_5_diff_w         ;
wire            [  3:0]            BO_6_num_w          ;
wire    signed  [  9:0]            BO_6_diff_w         ;
wire            [  3:0]            BO_7_num_w          ;
wire    signed  [  9:0]            BO_7_diff_w         ;


sao_sum_diff u_diff_0(
        .num       (EO_0_0         ) , 
        .num_sum   (EO_0_0_num_w   ) ,
        .diff_sum  (EO_0_0_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)   
        );

sao_sum_diff u_diff_1(
        .num       (EO_0_1         ) , 
        .num_sum   (EO_0_1_num_w   ) ,
        .diff_sum  (EO_0_1_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)    
        );

sao_sum_diff u_diff_2(
        .num       (EO_0_2         ) , 
        .num_sum   (EO_0_2_num_w   ) ,
        .diff_sum  (EO_0_2_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_3(
        .num       (EO_0_3         ) , 
        .num_sum   (EO_0_3_num_w   ) ,
        .diff_sum  (EO_0_3_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_4(
        .num       (EO_45_0         ) , 
        .num_sum   (EO_45_0_num_w   ) ,
        .diff_sum  (EO_45_0_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_5(
        .num       (EO_45_1         ) , 
        .num_sum   (EO_45_1_num_w   ) ,
        .diff_sum  (EO_45_1_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)      
        );

sao_sum_diff u_diff_6(
        .num       (EO_45_2         ) , 
        .num_sum   (EO_45_2_num_w   ) ,
        .diff_sum  (EO_45_2_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_7(
        .num       (EO_45_3         ) , 
        .num_sum   (EO_45_3_num_w   ) ,
        .diff_sum  (EO_45_3_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_8(
        .num       (EO_90_0         ) , 
        .num_sum   (EO_90_0_num_w   ) ,
        .diff_sum  (EO_90_0_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_9(
        .num       (EO_90_1         ) , 
        .num_sum   (EO_90_1_num_w   ) ,
        .diff_sum  (EO_90_1_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_10(
        .num       (EO_90_2         ) , 
        .num_sum   (EO_90_2_num_w   ) ,
        .diff_sum  (EO_90_2_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_11(
        .num       (EO_90_3         ) , 
        .num_sum   (EO_90_3_num_w   ) ,
        .diff_sum  (EO_90_3_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)      
        );

sao_sum_diff u_diff_12(
        .num       (EO_135_0         ) , 
        .num_sum   (EO_135_0_num_w   ) ,
        .diff_sum  (EO_135_0_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)      
        );

sao_sum_diff u_diff_13(
        .num       (EO_135_1         ) , 
        .num_sum   (EO_135_1_num_w   ) ,
        .diff_sum  (EO_135_1_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_14(
        .num       (EO_135_2         ) , 
        .num_sum   (EO_135_2_num_w   ) ,
        .diff_sum  (EO_135_2_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)      
        );

sao_sum_diff u_diff_15(
        .num       (EO_135_3         ) , 
        .num_sum   (EO_135_3_num_w   ) ,
        .diff_sum  (EO_135_3_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)      
        );

sao_sum_diff u_diff_16(
        .num       (BO_0         ) , 
        .num_sum   (BO_0_num_w   ) ,
        .diff_sum  (BO_0_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)    
        );

sao_sum_diff u_diff_17(
        .num       (BO_1         ) , 
        .num_sum   (BO_1_num_w   ) ,
        .diff_sum  (BO_1_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)    
        );

sao_sum_diff u_diff_18(
        .num       (BO_2         ) , 
        .num_sum   (BO_2_num_w   ) ,
        .diff_sum  (BO_2_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_19(
        .num       (BO_3         ) , 
        .num_sum   (BO_3_num_w   ) ,
        .diff_sum  (BO_3_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_20(
        .num       (BO_4         ) , 
        .num_sum   (BO_4_num_w   ) ,
        .diff_sum  (BO_4_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_21(
        .num       (BO_5         ) , 
        .num_sum   (BO_5_num_w   ) ,
        .diff_sum  (BO_5_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)    
        );

sao_sum_diff u_diff_22(
        .num       (BO_6         ) , 
        .num_sum   (BO_6_num_w   ) ,
        .diff_sum  (BO_6_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

sao_sum_diff u_diff_23(
        .num       (BO_7         ) , 
        .num_sum   (BO_7_num_w   ) ,
        .diff_sum  (BO_7_diff_w  ) , 
        .diff_i0   (diff_00_r)   , .diff_i1   (diff_01_r)   , .diff_i2    (diff_02_r)  , .diff_i3   (diff_03_r) , 
        .diff_i4   (diff_04_r)   , .diff_i5   (diff_05_r)   , .diff_i6    (diff_06_r)  , .diff_i7   (diff_07_r) , 
        .diff_i8   (diff_08_r)   , .diff_i9   (diff_09_r)   , .diff_i10   (diff_10_r)  , .diff_i11  (diff_11_r) , 
        .diff_i12  (diff_12_r)   , .diff_i13  (diff_13_r)   , .diff_i14   (diff_14_r)  , .diff_i15  (diff_15_r)     
        );

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        EO_0_0_num    <= 0 ;
        EO_0_0_diff   <= 0 ;
        EO_0_1_num    <= 0 ;
        EO_0_1_diff   <= 0 ;
        EO_0_2_num    <= 0 ;
        EO_0_2_diff   <= 0 ;
        EO_0_3_num    <= 0 ;
        EO_0_3_diff   <= 0 ;
        EO_45_0_num   <= 0 ;
        EO_45_0_diff  <= 0 ;
        EO_45_1_num   <= 0 ;
        EO_45_1_diff  <= 0 ;
        EO_45_2_num   <= 0 ;
        EO_45_2_diff  <= 0 ;
        EO_45_3_num   <= 0 ;
        EO_45_3_diff  <= 0 ;
        EO_90_0_num   <= 0 ;
        EO_90_0_diff  <= 0 ;
        EO_90_1_num   <= 0 ;
        EO_90_1_diff  <= 0 ;
        EO_90_2_num   <= 0 ;
        EO_90_2_diff  <= 0 ;
        EO_90_3_num   <= 0 ;
        EO_90_3_diff  <= 0 ;
        EO_135_0_num  <= 0 ;
        EO_135_0_diff <= 0 ;
        EO_135_1_num  <= 0 ;
        EO_135_1_diff <= 0 ;
        EO_135_2_num  <= 0 ;
        EO_135_2_diff <= 0 ;
        EO_135_3_num  <= 0 ;
        EO_135_3_diff <= 0 ;
        BO_0_num      <= 0 ;
        BO_0_diff     <= 0 ;
        BO_1_num      <= 0 ;
        BO_1_diff     <= 0 ;
        BO_2_num      <= 0 ;
        BO_2_diff     <= 0 ;
        BO_3_num      <= 0 ;
        BO_3_diff     <= 0 ;
        BO_4_num      <= 0 ;
        BO_4_diff     <= 0 ;
        BO_5_num      <= 0 ;
        BO_5_diff     <= 0 ;
        BO_6_num      <= 0 ;
        BO_6_diff     <= 0 ;
        BO_7_num      <= 0 ;
        BO_7_diff     <= 0 ;
    end
    else if( ( state_i != SAO ) || (sao_4x4_y_i == 0 && sao_4x4_x_i == 0) ) begin
        EO_0_0_num    <= 0 ;
        EO_0_0_diff   <= 0 ;
        EO_0_1_num    <= 0 ;
        EO_0_1_diff   <= 0 ;
        EO_0_2_num    <= 0 ;
        EO_0_2_diff   <= 0 ;
        EO_0_3_num    <= 0 ;
        EO_0_3_diff   <= 0 ;
        EO_45_0_num   <= 0 ;
        EO_45_0_diff  <= 0 ;
        EO_45_1_num   <= 0 ;
        EO_45_1_diff  <= 0 ;
        EO_45_2_num   <= 0 ;
        EO_45_2_diff  <= 0 ;
        EO_45_3_num   <= 0 ;
        EO_45_3_diff  <= 0 ;
        EO_90_0_num   <= 0 ;
        EO_90_0_diff  <= 0 ;
        EO_90_1_num   <= 0 ;
        EO_90_1_diff  <= 0 ;
        EO_90_2_num   <= 0 ;
        EO_90_2_diff  <= 0 ;
        EO_90_3_num   <= 0 ;
        EO_90_3_diff  <= 0 ;
        EO_135_0_num  <= 0 ;
        EO_135_0_diff <= 0 ;
        EO_135_1_num  <= 0 ;
        EO_135_1_diff <= 0 ;
        EO_135_2_num  <= 0 ;
        EO_135_2_diff <= 0 ;
        EO_135_3_num  <= 0 ;
        EO_135_3_diff <= 0 ;
        BO_0_num      <= 0 ;
        BO_0_diff     <= 0 ;
        BO_1_num      <= 0 ;
        BO_1_diff     <= 0 ;
        BO_2_num      <= 0 ;
        BO_2_diff     <= 0 ;
        BO_3_num      <= 0 ;
        BO_3_diff     <= 0 ;
        BO_4_num      <= 0 ;
        BO_4_diff     <= 0 ;
        BO_5_num      <= 0 ;
        BO_5_diff     <= 0 ;
        BO_6_num      <= 0 ;
        BO_6_diff     <= 0 ;
        BO_7_num      <= 0 ;
        BO_7_diff     <= 0 ;
    end
    else if ( state_i == SAO ) begin
        EO_0_0_num    <= EO_0_0_num    +  EO_0_0_num_w     ;
        EO_0_0_diff   <= EO_0_0_diff   +  EO_0_0_diff_w    ;
        EO_0_1_num    <= EO_0_1_num    +  EO_0_1_num_w     ;
        EO_0_1_diff   <= EO_0_1_diff   +  EO_0_1_diff_w    ;
        EO_0_2_num    <= EO_0_2_num    +  EO_0_2_num_w     ;
        EO_0_2_diff   <= EO_0_2_diff   +  EO_0_2_diff_w    ;
        EO_0_3_num    <= EO_0_3_num    +  EO_0_3_num_w     ;
        EO_0_3_diff   <= EO_0_3_diff   +  EO_0_3_diff_w    ;
        EO_45_0_num   <= EO_45_0_num   +  EO_45_0_num_w    ;
        EO_45_0_diff  <= EO_45_0_diff  +  EO_45_0_diff_w   ;
        EO_45_1_num   <= EO_45_1_num   +  EO_45_1_num_w    ;
        EO_45_1_diff  <= EO_45_1_diff  +  EO_45_1_diff_w   ;
        EO_45_2_num   <= EO_45_2_num   +  EO_45_2_num_w    ;
        EO_45_2_diff  <= EO_45_2_diff  +  EO_45_2_diff_w   ;
        EO_45_3_num   <= EO_45_3_num   +  EO_45_3_num_w    ;
        EO_45_3_diff  <= EO_45_3_diff  +  EO_45_3_diff_w   ;
        EO_90_0_num   <= EO_90_0_num   +  EO_90_0_num_w    ;
        EO_90_0_diff  <= EO_90_0_diff  +  EO_90_0_diff_w   ;
        EO_90_1_num   <= EO_90_1_num   +  EO_90_1_num_w    ;
        EO_90_1_diff  <= EO_90_1_diff  +  EO_90_1_diff_w   ;
        EO_90_2_num   <= EO_90_2_num   +  EO_90_2_num_w    ;
        EO_90_2_diff  <= EO_90_2_diff  +  EO_90_2_diff_w   ;
        EO_90_3_num   <= EO_90_3_num   +  EO_90_3_num_w    ;
        EO_90_3_diff  <= EO_90_3_diff  +  EO_90_3_diff_w   ;
        EO_135_0_num  <= EO_135_0_num  +  EO_135_0_num_w   ;
        EO_135_0_diff <= EO_135_0_diff +  EO_135_0_diff_w  ;
        EO_135_1_num  <= EO_135_1_num  +  EO_135_1_num_w   ;
        EO_135_1_diff <= EO_135_1_diff +  EO_135_1_diff_w  ;
        EO_135_2_num  <= EO_135_2_num  +  EO_135_2_num_w   ;
        EO_135_2_diff <= EO_135_2_diff +  EO_135_2_diff_w  ;
        EO_135_3_num  <= EO_135_3_num  +  EO_135_3_num_w   ;
        EO_135_3_diff <= EO_135_3_diff +  EO_135_3_diff_w  ;
        BO_0_num      <= BO_0_num      +  BO_0_num_w       ;
        BO_0_diff     <= BO_0_diff     +  BO_0_diff_w      ;
        BO_1_num      <= BO_1_num      +  BO_1_num_w       ;
        BO_1_diff     <= BO_1_diff     +  BO_1_diff_w      ;
        BO_2_num      <= BO_2_num      +  BO_2_num_w       ;
        BO_2_diff     <= BO_2_diff     +  BO_2_diff_w      ;
        BO_3_num      <= BO_3_num      +  BO_3_num_w       ;
        BO_3_diff     <= BO_3_diff     +  BO_3_diff_w      ;
        BO_4_num      <= BO_4_num      +  BO_4_num_w       ;
        BO_4_diff     <= BO_4_diff     +  BO_4_diff_w      ;
        BO_5_num      <= BO_5_num      +  BO_5_num_w       ;
        BO_5_diff     <= BO_5_diff     +  BO_5_diff_w      ;
        BO_6_num      <= BO_6_num      +  BO_6_num_w       ;
        BO_6_diff     <= BO_6_diff     +  BO_6_diff_w      ;
        BO_7_num      <= BO_7_num      +  BO_7_num_w       ;
        BO_7_diff     <= BO_7_diff     +  BO_7_diff_w      ;

    end
end

always @ ( posedge  clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        EO_0_0_num_o        <=  0 ;
        EO_0_0_diff_o       <=  0 ;
        EO_0_1_num_o        <=  0 ;
        EO_0_1_diff_o       <=  0 ;
        EO_0_2_num_o        <=  0 ;
        EO_0_2_diff_o       <=  0 ;
        EO_0_3_num_o        <=  0 ;
        EO_0_3_diff_o       <=  0 ;
        EO_45_0_num_o       <=  0 ;
        EO_45_0_diff_o      <=  0 ;
        EO_45_1_num_o       <=  0 ;
        EO_45_1_diff_o      <=  0 ;
        EO_45_2_num_o       <=  0 ;
        EO_45_2_diff_o      <=  0 ;
        EO_45_3_num_o       <=  0 ;
        EO_45_3_diff_o      <=  0 ;
        EO_90_0_num_o       <=  0 ;
        EO_90_0_diff_o      <=  0 ;
        EO_90_1_num_o       <=  0 ;
        EO_90_1_diff_o      <=  0 ;
        EO_90_2_num_o       <=  0 ;
        EO_90_2_diff_o      <=  0 ;
        EO_90_3_num_o       <=  0 ;
        EO_90_3_diff_o      <=  0 ;
        EO_135_0_num_o      <=  0 ;
        EO_135_0_diff_o     <=  0 ;
        EO_135_1_num_o      <=  0 ;
        EO_135_1_diff_o     <=  0 ;
        EO_135_2_num_o      <=  0 ;
        EO_135_2_diff_o     <=  0 ;
        EO_135_3_num_o      <=  0 ;
        EO_135_3_diff_o     <=  0 ;
        BO_0_num_o          <=  0 ;
        BO_0_diff_o         <=  0 ;
        BO_1_num_o          <=  0 ;
        BO_1_diff_o         <=  0 ;
        BO_2_num_o          <=  0 ;
        BO_2_diff_o         <=  0 ;
        BO_3_num_o          <=  0 ;
        BO_3_diff_o         <=  0 ;
        BO_4_num_o          <=  0 ;
        BO_4_diff_o         <=  0 ;
        BO_5_num_o          <=  0 ;
        BO_5_diff_o         <=  0 ;
        BO_6_num_o          <=  0 ;
        BO_6_diff_o         <=  0 ;
        BO_7_num_o          <=  0 ;
        BO_7_diff_o         <=  0 ;
    end
    else if  ( state_i == SAO 
         && (( sao_sel_o == `TYPE_Y && sao_4x4_y_o == 14 && sao_4x4_x_o == 14 ) 
         ||  ( sao_sel_o == `TYPE_U && sao_4x4_y_o == 6  && sao_4x4_x_o == 6  )
         ||  ( sao_sel_o == `TYPE_V && sao_4x4_y_o == 6  && sao_4x4_x_o == 6  ) ) ) 
        begin
        EO_0_0_num_o        <=  EO_0_0_num           ;
        EO_0_0_diff_o       <=  EO_0_0_diff          ;
        EO_0_1_num_o        <=  EO_0_1_num           ;
        EO_0_1_diff_o       <=  EO_0_1_diff          ;
        EO_0_2_num_o        <=  EO_0_2_num           ;
        EO_0_2_diff_o       <=  EO_0_2_diff          ;
        EO_0_3_num_o        <=  EO_0_3_num           ;
        EO_0_3_diff_o       <=  EO_0_3_diff          ;
        EO_45_0_num_o       <=  EO_45_0_num          ;
        EO_45_0_diff_o      <=  EO_45_0_diff         ;
        EO_45_1_num_o       <=  EO_45_1_num          ;
        EO_45_1_diff_o      <=  EO_45_1_diff         ;
        EO_45_2_num_o       <=  EO_45_2_num          ;
        EO_45_2_diff_o      <=  EO_45_2_diff         ;
        EO_45_3_num_o       <=  EO_45_3_num          ;
        EO_45_3_diff_o      <=  EO_45_3_diff         ;
        EO_90_0_num_o       <=  EO_90_0_num          ;
        EO_90_0_diff_o      <=  EO_90_0_diff         ;
        EO_90_1_num_o       <=  EO_90_1_num          ;
        EO_90_1_diff_o      <=  EO_90_1_diff         ;
        EO_90_2_num_o       <=  EO_90_2_num          ;
        EO_90_2_diff_o      <=  EO_90_2_diff         ;
        EO_90_3_num_o       <=  EO_90_3_num          ;
        EO_90_3_diff_o      <=  EO_90_3_diff         ;
        EO_135_0_num_o      <=  EO_135_0_num         ;
        EO_135_0_diff_o     <=  EO_135_0_diff        ;
        EO_135_1_num_o      <=  EO_135_1_num         ;
        EO_135_1_diff_o     <=  EO_135_1_diff        ;
        EO_135_2_num_o      <=  EO_135_2_num         ;
        EO_135_2_diff_o     <=  EO_135_2_diff        ;
        EO_135_3_num_o      <=  EO_135_3_num         ;
        EO_135_3_diff_o     <=  EO_135_3_diff        ;
        BO_0_num_o          <=  BO_0_num             ;
        BO_0_diff_o         <=  BO_0_diff            ;
        BO_1_num_o          <=  BO_1_num             ;
        BO_1_diff_o         <=  BO_1_diff            ;
        BO_2_num_o          <=  BO_2_num             ;
        BO_2_diff_o         <=  BO_2_diff            ;
        BO_3_num_o          <=  BO_3_num             ;
        BO_3_diff_o         <=  BO_3_diff            ;
        BO_4_num_o          <=  BO_4_num             ;
        BO_4_diff_o         <=  BO_4_diff            ;
        BO_5_num_o          <=  BO_5_num             ;
        BO_5_diff_o         <=  BO_5_diff            ;
        BO_6_num_o          <=  BO_6_num             ;
        BO_6_diff_o         <=  BO_6_diff            ;
        BO_7_num_o          <=  BO_7_num             ;
        BO_7_diff_o         <=  BO_7_diff            ;
    end
end

endmodule
