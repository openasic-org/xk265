//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner 	  : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//-------------------------------------------------------------------
// Filename       : sao_mode.v
// Author         : TANG
// Creatu_ved     : 2017-12-07
// Description    :
//------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module sao_mode (
            clk                 ,
            rst_n               ,
            state_i             ,
            bo_predecision      ,
            sao_4x4_x_i         ,
            sao_4x4_y_i         ,
            sao_sel_i           ,
            rec_line_i_0        ,
            rec_line_i_1        ,
            rec_line_i_2        ,
            rec_line_i_3        ,
            rec_line_i_4        ,
            rec_line_i_5        ,
            EO_0_0_o            ,
            EO_0_1_o            ,
            EO_0_2_o            ,
            EO_0_3_o            ,
            EO_45_0_o           ,
            EO_45_1_o           ,
            EO_45_2_o           ,
            EO_45_3_o           ,
            EO_90_0_o           ,
            EO_90_1_o           ,
            EO_90_2_o           ,
            EO_90_3_o           ,
            EO_135_0_o          ,
            EO_135_1_o          ,
            EO_135_2_o          ,
            EO_135_3_o          ,
            BO_0_o              ,
            BO_1_o              ,
            BO_2_o              ,
            BO_3_o              ,
            BO_4_o              ,
            BO_5_o              ,
            BO_6_o              ,
            BO_7_o
);

//--- parameter ----------------------------------------------
parameter SAO = 3'b100 ;

//--- input/output -------------------------------------------
input                           rst_n, clk           ;
input       [3  -1:0]           state_i              ;
input       [5  -1:0]           bo_predecision       ;

input       [4  -1:0]           sao_4x4_x_i          ;
input       [4  -1:0]           sao_4x4_y_i          ;
input       [2  -1:0]           sao_sel_i            ;

input       [6*8-1:0]           rec_line_i_0         ;
input       [6*8-1:0]           rec_line_i_1         ;
input       [6*8-1:0]           rec_line_i_2         ;
input       [6*8-1:0]           rec_line_i_3         ;
input       [6*8-1:0]           rec_line_i_4         ;
input       [6*8-1:0]           rec_line_i_5         ;

output reg  [4*4-1:0]           EO_0_0_o             ;
output reg  [4*4-1:0]           EO_0_1_o             ;
output reg  [4*4-1:0]           EO_0_2_o             ;
output reg  [4*4-1:0]           EO_0_3_o             ;
output reg  [4*4-1:0]           EO_45_0_o            ;
output reg  [4*4-1:0]           EO_45_1_o            ;
output reg  [4*4-1:0]           EO_45_2_o            ;
output reg  [4*4-1:0]           EO_45_3_o            ;
output reg  [4*4-1:0]           EO_90_0_o            ;
output reg  [4*4-1:0]           EO_90_1_o            ;
output reg  [4*4-1:0]           EO_90_2_o            ;
output reg  [4*4-1:0]           EO_90_3_o            ;
output reg  [4*4-1:0]           EO_135_0_o           ;
output reg  [4*4-1:0]           EO_135_1_o           ;
output reg  [4*4-1:0]           EO_135_2_o           ;
output reg  [4*4-1:0]           EO_135_3_o           ;
output reg  [4*4-1:0]           BO_0_o               ;
output reg  [4*4-1:0]           BO_1_o               ;
output reg  [4*4-1:0]           BO_2_o               ;
output reg  [4*4-1:0]           BO_3_o               ;
output reg  [4*4-1:0]           BO_4_o               ;
output reg  [4*4-1:0]           BO_5_o               ;
output reg  [4*4-1:0]           BO_6_o               ;
output reg  [4*4-1:0]           BO_7_o               ;

//--- wire/reg ---------------------------------------------------------
wire        [5*4-1:0]           EO_0_00              ; // right > center
wire        [5*4-1:0]           EO_0_10              ; // right = center
wire        [5*5-1:0]           EO_45_00             ; // top-right > center
wire        [5*5-1:0]           EO_45_10             ; // top-right = center
wire        [4*5-1:0]           EO_90_00             ; // top > center
wire        [4*5-1:0]           EO_90_10             ; // top = center
wire        [5*5-1:0]           EO_135_00            ; // top-left > center
wire        [5*5-1:0]           EO_135_10            ; // top-left = center


/*
wire        [4*4-1:0]           EO_0_00              ; // right > center
wire        [4*4-1:0]           EO_0_10              ; // right = center
wire        [4*4-1:0]           EO_0_01              ; // left  > center
wire        [4*4-1:0]           EO_0_11              ; // left  = center
wire        [4*4-1:0]           EO_45_00             ; // top-right > center
wire        [4*4-1:0]           EO_45_10             ; // top-right = center
wire        [4*4-1:0]           EO_45_01             ; // dwon-left  > center
wire        [4*4-1:0]           EO_45_11             ; // dwon-left  = center
wire        [4*4-1:0]           EO_90_00             ; // top > center
wire        [4*4-1:0]           EO_90_10             ; // top = center
wire        [4*4-1:0]           EO_90_01             ; // dwon > center
wire        [4*4-1:0]           EO_90_11             ; // dwon = center
wire        [4*4-1:0]           EO_135_00            ; // top-left > center
wire        [4*4-1:0]           EO_135_10            ; // top-left = center
wire        [4*4-1:0]           EO_135_01            ; // down-right > center
wire        [4*4-1:0]           EO_135_11            ; // down-right = center
*/

//--- EO_0 ------------------------------------------------------------------
genvar i0;
generate
    for ( i0 = 0; i0 < 5; i0 = i0 + 1 ) begin : u_EO_0
        assign EO_0_00[i0+15] = rec_line_i_1[(i0+1)*8-1:(i0)*8] >  rec_line_i_1[(i0+2)*8-1:(i0+1)*8] ;
        assign EO_0_10[i0+15] = rec_line_i_1[(i0+1)*8-1:(i0)*8] == rec_line_i_1[(i0+2)*8-1:(i0+1)*8] ;
        assign EO_0_00[i0+10] = rec_line_i_2[(i0+1)*8-1:(i0)*8] >  rec_line_i_2[(i0+2)*8-1:(i0+1)*8] ;
        assign EO_0_10[i0+10] = rec_line_i_2[(i0+1)*8-1:(i0)*8] == rec_line_i_2[(i0+2)*8-1:(i0+1)*8] ;
        assign EO_0_00[i0+ 5] = rec_line_i_3[(i0+1)*8-1:(i0)*8] >  rec_line_i_3[(i0+2)*8-1:(i0+1)*8] ;
        assign EO_0_10[i0+ 5] = rec_line_i_3[(i0+1)*8-1:(i0)*8] == rec_line_i_3[(i0+2)*8-1:(i0+1)*8] ;
        assign EO_0_00[i0   ] = rec_line_i_4[(i0+1)*8-1:(i0)*8] >  rec_line_i_4[(i0+2)*8-1:(i0+1)*8] ;
        assign EO_0_10[i0   ] = rec_line_i_4[(i0+1)*8-1:(i0)*8] == rec_line_i_4[(i0+2)*8-1:(i0+1)*8] ;
    end
endgenerate


// --- EO_45 ----------------------------------------------------------
genvar i1;
generate
    for ( i1 = 0; i1 < 5; i1 = i1 + 1 ) begin : u_EO_45
        assign EO_45_00[i1+20] = rec_line_i_0[(i1+1)*8-1:(i1)*8] >  rec_line_i_1[(i1+2)*8-1:(i1+1)*8] ;
        assign EO_45_10[i1+20] = rec_line_i_0[(i1+1)*8-1:(i1)*8] == rec_line_i_1[(i1+2)*8-1:(i1+1)*8] ;
        assign EO_45_00[i1+15] = rec_line_i_1[(i1+1)*8-1:(i1)*8] >  rec_line_i_2[(i1+2)*8-1:(i1+1)*8] ;
        assign EO_45_10[i1+15] = rec_line_i_1[(i1+1)*8-1:(i1)*8] == rec_line_i_2[(i1+2)*8-1:(i1+1)*8] ;
        assign EO_45_00[i1+10] = rec_line_i_2[(i1+1)*8-1:(i1)*8] >  rec_line_i_3[(i1+2)*8-1:(i1+1)*8] ;
        assign EO_45_10[i1+10] = rec_line_i_2[(i1+1)*8-1:(i1)*8] == rec_line_i_3[(i1+2)*8-1:(i1+1)*8] ;
        assign EO_45_00[i1+ 5] = rec_line_i_3[(i1+1)*8-1:(i1)*8] >  rec_line_i_4[(i1+2)*8-1:(i1+1)*8] ;
        assign EO_45_10[i1+ 5] = rec_line_i_3[(i1+1)*8-1:(i1)*8] == rec_line_i_4[(i1+2)*8-1:(i1+1)*8] ;
        assign EO_45_00[i1   ] = rec_line_i_4[(i1+1)*8-1:(i1)*8] >  rec_line_i_5[(i1+2)*8-1:(i1+1)*8] ;
        assign EO_45_10[i1   ] = rec_line_i_4[(i1+1)*8-1:(i1)*8] == rec_line_i_5[(i1+2)*8-1:(i1+1)*8] ;
    end
endgenerate


// --- EO_90 -----------------------------------------------------------
genvar i2;
generate
    for ( i2 = 0; i2 < 4; i2 = i2 + 1 ) begin : u_EO_90
        assign EO_90_00[i2+16] = rec_line_i_0[(i2+2)*8-1:(i2+1)*8] >  rec_line_i_1[(i2+2)*8-1:(i2+1)*8] ;
        assign EO_90_10[i2+16] = rec_line_i_0[(i2+2)*8-1:(i2+1)*8] == rec_line_i_1[(i2+2)*8-1:(i2+1)*8] ;
        assign EO_90_00[i2+12] = rec_line_i_1[(i2+2)*8-1:(i2+1)*8] >  rec_line_i_2[(i2+2)*8-1:(i2+1)*8] ;
        assign EO_90_10[i2+12] = rec_line_i_1[(i2+2)*8-1:(i2+1)*8] == rec_line_i_2[(i2+2)*8-1:(i2+1)*8] ;
        assign EO_90_00[i2+8 ] = rec_line_i_2[(i2+2)*8-1:(i2+1)*8] >  rec_line_i_3[(i2+2)*8-1:(i2+1)*8] ;
        assign EO_90_10[i2+8 ] = rec_line_i_2[(i2+2)*8-1:(i2+1)*8] == rec_line_i_3[(i2+2)*8-1:(i2+1)*8] ;
        assign EO_90_00[i2+4 ] = rec_line_i_3[(i2+2)*8-1:(i2+1)*8] >  rec_line_i_4[(i2+2)*8-1:(i2+1)*8] ;
        assign EO_90_10[i2+4 ] = rec_line_i_3[(i2+2)*8-1:(i2+1)*8] == rec_line_i_4[(i2+2)*8-1:(i2+1)*8] ;
        assign EO_90_00[i2   ] = rec_line_i_4[(i2+2)*8-1:(i2+1)*8] >  rec_line_i_5[(i2+2)*8-1:(i2+1)*8] ;
        assign EO_90_10[i2   ] = rec_line_i_4[(i2+2)*8-1:(i2+1)*8] == rec_line_i_5[(i2+2)*8-1:(i2+1)*8] ;
    end
endgenerate


// EO_135
genvar i3;
generate
    for ( i3 = 0; i3 < 5; i3 = i3 + 1 ) begin : u_EO_135
        assign EO_135_00[i3+20] = rec_line_i_0[(i3+2)*8-1:(i3+1)*8] >  rec_line_i_1[(i3+1)*8-1:(i3)*8] ;
        assign EO_135_10[i3+20] = rec_line_i_0[(i3+2)*8-1:(i3+1)*8] == rec_line_i_1[(i3+1)*8-1:(i3)*8] ;
        assign EO_135_00[i3+15] = rec_line_i_1[(i3+2)*8-1:(i3+1)*8] >  rec_line_i_2[(i3+1)*8-1:(i3)*8] ;
        assign EO_135_10[i3+15] = rec_line_i_1[(i3+2)*8-1:(i3+1)*8] == rec_line_i_2[(i3+1)*8-1:(i3)*8] ;
        assign EO_135_00[i3+10] = rec_line_i_2[(i3+2)*8-1:(i3+1)*8] >  rec_line_i_3[(i3+1)*8-1:(i3)*8] ;
        assign EO_135_10[i3+10] = rec_line_i_2[(i3+2)*8-1:(i3+1)*8] == rec_line_i_3[(i3+1)*8-1:(i3)*8] ;
        assign EO_135_00[i3+ 5] = rec_line_i_3[(i3+2)*8-1:(i3+1)*8] >  rec_line_i_4[(i3+1)*8-1:(i3)*8] ;
        assign EO_135_10[i3+ 5] = rec_line_i_3[(i3+2)*8-1:(i3+1)*8] == rec_line_i_4[(i3+1)*8-1:(i3)*8] ;
        assign EO_135_00[i3   ] = rec_line_i_4[(i3+2)*8-1:(i3+1)*8] >  rec_line_i_5[(i3+1)*8-1:(i3)*8] ;
        assign EO_135_10[i3   ] = rec_line_i_4[(i3+2)*8-1:(i3+1)*8] == rec_line_i_5[(i3+1)*8-1:(i3)*8] ;
    end
endgenerate

/*
---------------------------------
| topleft | top     | topright  |
--------------------- -----------
| left    | center  | right     |
--------------------- -----------
| downleft| down    | downright |
---------------------------------
*/

wire [16-1:0]               EO_0_0_0      ;  //right     > center
wire [16-1:0]               EO_0_0_1      ;  //right     = center
wire [16-1:0]               EO_0_0_2      ;  //right     < center
wire [16-1:0]               EO_0_1_0      ;  //left      > center
wire [16-1:0]               EO_0_1_1      ;  //left      = center
wire [16-1:0]               EO_0_1_2      ;  //left      < center
wire [16-1:0]               EO_45_0_0     ;  //topright  > center
wire [16-1:0]               EO_45_0_1     ;  //topright  = center
wire [16-1:0]               EO_45_0_2     ;  //topright  < center
wire [16-1:0]               EO_45_1_0     ;  //downleft  > center
wire [16-1:0]               EO_45_1_1     ;  //downleft  = center
wire [16-1:0]               EO_45_1_2     ;  //downleft  < center
wire [16-1:0]               EO_90_0_0     ;  //top       > center
wire [16-1:0]               EO_90_0_1     ;  //top       = center
wire [16-1:0]               EO_90_0_2     ;  //top       < center
wire [16-1:0]               EO_90_1_0     ;  //down      > center
wire [16-1:0]               EO_90_1_1     ;  //down      = center
wire [16-1:0]               EO_90_1_2     ;  //down      < center
wire [16-1:0]               EO_135_0_0    ;  //topleft   > center
wire [16-1:0]               EO_135_0_1    ;  //topleft   = center
wire [16-1:0]               EO_135_0_2    ;  //topleft   < center
wire [16-1:0]               EO_135_1_0    ;  //downright > center
wire [16-1:0]               EO_135_1_1    ;  //downright = center
wire [16-1:0]               EO_135_1_2    ;  //downright < center

wire [16-1:0]               EO_0_0     ;
wire [16-1:0]               EO_0_1     ;
wire [16-1:0]               EO_0_2     ;
wire [16-1:0]               EO_0_3     ;
wire [16-1:0]               EO_45_0    ;
wire [16-1:0]               EO_45_1    ;
wire [16-1:0]               EO_45_2    ;
wire [16-1:0]               EO_45_3    ;
wire [16-1:0]               EO_90_0    ;
wire [16-1:0]               EO_90_1    ;
wire [16-1:0]               EO_90_2    ;
wire [16-1:0]               EO_90_3    ;
wire [16-1:0]               EO_135_0   ;
wire [16-1:0]               EO_135_1   ;
wire [16-1:0]               EO_135_2   ;
wire [16-1:0]               EO_135_3   ;
wire [16-1:0]               BO_0       ;
wire [16-1:0]               BO_1       ;
wire [16-1:0]               BO_2       ;
wire [16-1:0]               BO_3       ;
wire [16-1:0]               BO_4       ;
wire [16-1:0]               BO_5       ;
wire [16-1:0]               BO_6       ;
wire [16-1:0]               BO_7       ;

wire [16-1:0]               EO_0_0_w   ;
wire [16-1:0]               EO_0_1_w   ;
wire [16-1:0]               EO_0_2_w   ;
wire [16-1:0]               EO_0_3_w   ;
wire [16-1:0]               EO_45_0_w  ;
wire [16-1:0]               EO_45_1_w  ;
wire [16-1:0]               EO_45_2_w  ;
wire [16-1:0]               EO_45_3_w  ;
wire [16-1:0]               EO_90_0_w  ;
wire [16-1:0]               EO_90_1_w  ;
wire [16-1:0]               EO_90_2_w  ;
wire [16-1:0]               EO_90_3_w  ;
wire [16-1:0]               EO_135_0_w ;
wire [16-1:0]               EO_135_1_w ;
wire [16-1:0]               EO_135_2_w ;
wire [16-1:0]               EO_135_3_w ;
wire [16-1:0]               BO_0_w     ;
wire [16-1:0]               BO_1_w     ;
wire [16-1:0]               BO_2_w     ;
wire [16-1:0]               BO_3_w     ;
wire [16-1:0]               BO_4_w     ;
wire [16-1:0]               BO_5_w     ;
wire [16-1:0]               BO_6_w     ;
wire [16-1:0]               BO_7_w     ;

assign EO_0_0_0 =  {EO_0_00[18:15], EO_0_00[13:10], EO_0_00[8:5], EO_0_00[3:0]}; // right > center
assign EO_0_0_1 =  {EO_0_10[18:15], EO_0_10[13:10], EO_0_10[8:5], EO_0_10[3:0]}; // right == center
assign EO_0_0_2 =  ((~EO_0_0_1) & (~EO_0_0_0)); // right < center

assign EO_0_1_1 =  {EO_0_10[19:16], EO_0_10[14:11], EO_0_10[9:6], EO_0_10[4:1]};
assign EO_0_1_2 =  {EO_0_00[19:16], EO_0_00[14:11], EO_0_00[9:6], EO_0_00[4:1]};
assign EO_0_1_0 =  ((~EO_0_1_1) & (~EO_0_1_2));

assign EO_45_0_0 =  {EO_45_00[23:20], EO_45_00[18:15], EO_45_00[13:10], EO_45_00[8:5]};
assign EO_45_0_1 =  {EO_45_10[23:20], EO_45_10[18:15], EO_45_10[13:10], EO_45_10[8:5]};
assign EO_45_0_2 =  ((~EO_45_0_1) & (~EO_45_0_0));

assign EO_45_1_2 =  {EO_45_00[19:16], EO_45_00[14:11], EO_45_00[9:6], EO_45_00[4:1]};
assign EO_45_1_1 =  {EO_45_10[19:16], EO_45_10[14:11], EO_45_10[9:6], EO_45_10[4:1]};
assign EO_45_1_0 =  ((~EO_45_1_1) & (~EO_45_1_2));

assign EO_90_0_0 =  EO_90_00[19:4];
assign EO_90_0_1 =  EO_90_10[19:4];
assign EO_90_0_2 =  ((~EO_90_0_1) & (~EO_90_0_0));

assign EO_90_1_2 =  EO_90_00[15:0];
assign EO_90_1_1 =  EO_90_10[15:0];
assign EO_90_1_0 =  ((~EO_90_1_1) & (~EO_90_1_2));

assign EO_135_0_0 =  {EO_135_00[24:21], EO_135_00[19:16], EO_135_00[14:11], EO_135_00[9:6]};
assign EO_135_0_1 =  {EO_135_10[24:21], EO_135_10[19:16], EO_135_10[14:11], EO_135_10[9:6]};
assign EO_135_0_2 =  ((~EO_135_0_1) & (~EO_135_0_0));

assign EO_135_1_2 =  {EO_135_00[18:15], EO_135_00[13:10], EO_135_00[8:5], EO_135_00[3:0]};
assign EO_135_1_1 =  {EO_135_10[18:15], EO_135_10[13:10], EO_135_10[8:5], EO_135_10[3:0]};
assign EO_135_1_0 =  ((~EO_135_1_1) & (~EO_135_1_2));


assign EO_0_0     =  ( EO_0_1_0 & EO_0_0_0 )                                 ;// left > center & right > center
assign EO_0_1     = (( EO_0_1_0 & EO_0_0_1 ) | (EO_0_1_1 & EO_0_0_0) )       ;// (left > center & right == center) | (left == center & right > center)
assign EO_0_2     = (( EO_0_1_1 & EO_0_0_2 ) | (EO_0_1_2 & EO_0_0_1) )       ;// (left == center & (right < center ) | ( (left < center & right == center)
assign EO_0_3     =  ( EO_0_1_2 & EO_0_0_2 )                                 ;// ((left < center) & (right < center)
assign EO_45_0    =  ( EO_45_1_0 & EO_45_0_0 )                               ;
assign EO_45_1    = (( EO_45_1_0 & EO_45_0_1 ) | (EO_45_1_1 & EO_45_0_0))    ;
assign EO_45_2    = (( EO_45_1_1 & EO_45_0_2 ) | (EO_45_1_2 & EO_45_0_1))    ;
assign EO_45_3    =  ( EO_45_1_2 & EO_45_0_2 )                               ;
assign EO_90_0    =  ( EO_90_1_0 & EO_90_0_0 )                               ;
assign EO_90_1    = (( EO_90_1_0 & EO_90_0_1 ) | (EO_90_1_1 & EO_90_0_0))    ;
assign EO_90_2    = (( EO_90_1_1 & EO_90_0_2 ) | (EO_90_1_2 & EO_90_0_1))    ;
assign EO_90_3    =  ( EO_90_1_2 & EO_90_0_2 )                               ;
assign EO_135_0   =  ( EO_135_1_0 & EO_135_0_0 )                             ;
assign EO_135_1   = (( EO_135_1_0 & EO_135_0_1 ) | (EO_135_1_1 & EO_135_0_0));
assign EO_135_2   = (( EO_135_1_1 & EO_135_0_2 ) | (EO_135_1_2 & EO_135_0_1));
assign EO_135_3   =  ( EO_135_1_2 & EO_135_0_2 )                             ;

//BO
wire [4:0] band_number [16-1:0];

genvar i4;
generate
    for ( i4 = 1; i4 < 5; i4 = i4 + 1 ) begin : u0_BO
       assign band_number[i4-1+12] = rec_line_i_1[(i4+1)*8-1:i4*8+3] - bo_predecision;
       assign band_number[i4-1+ 8] = rec_line_i_2[(i4+1)*8-1:i4*8+3] - bo_predecision;
       assign band_number[i4-1+ 4] = rec_line_i_3[(i4+1)*8-1:i4*8+3] - bo_predecision;
       assign band_number[i4-1   ] = rec_line_i_4[(i4+1)*8-1:i4*8+3] - bo_predecision;
    end
endgenerate

genvar i5;
generate
    for ( i5 = 0; i5 < 4*4; i5 = i5 + 1 )  begin : u0_BO_0
        assign BO_0[i5] = band_number[i5][2:0] == 3'b000;
        assign BO_1[i5] = band_number[i5][2:0] == 3'b001;
        assign BO_2[i5] = band_number[i5][2:0] == 3'b010;
        assign BO_3[i5] = band_number[i5][2:0] == 3'b011;
        assign BO_4[i5] = band_number[i5][2:0] == 3'b100;
        assign BO_5[i5] = band_number[i5][2:0] == 3'b101;
        assign BO_6[i5] = band_number[i5][2:0] == 3'b110;
        assign BO_7[i5] = band_number[i5][2:0] == 3'b111;
	end
endgenerate

assign EO_0_0_w   = ( sao_4x4_y_i == 0 ) ? { EO_0_0  [15:8], 8'b0 } : EO_0_0   ;
assign EO_0_1_w   = ( sao_4x4_y_i == 0 ) ? { EO_0_1  [15:8], 8'b0 } : EO_0_1   ;
assign EO_0_2_w   = ( sao_4x4_y_i == 0 ) ? { EO_0_2  [15:8], 8'b0 } : EO_0_2   ;
assign EO_0_3_w   = ( sao_4x4_y_i == 0 ) ? { EO_0_3  [15:8], 8'b0 } : EO_0_3   ;
assign EO_45_0_w  = ( sao_4x4_y_i == 0 ) ? { EO_45_0 [15:8], 8'b0 } : EO_45_0  ;
assign EO_45_1_w  = ( sao_4x4_y_i == 0 ) ? { EO_45_1 [15:8], 8'b0 } : EO_45_1  ;
assign EO_45_2_w  = ( sao_4x4_y_i == 0 ) ? { EO_45_2 [15:8], 8'b0 } : EO_45_2  ;
assign EO_45_3_w  = ( sao_4x4_y_i == 0 ) ? { EO_45_3 [15:8], 8'b0 } : EO_45_3  ;
assign EO_90_0_w  = ( sao_4x4_y_i == 0 ) ? { EO_90_0 [15:8], 8'b0 } : EO_90_0  ;
assign EO_90_1_w  = ( sao_4x4_y_i == 0 ) ? { EO_90_1 [15:8], 8'b0 } : EO_90_1  ;
assign EO_90_2_w  = ( sao_4x4_y_i == 0 ) ? { EO_90_2 [15:8], 8'b0 } : EO_90_2  ;
assign EO_90_3_w  = ( sao_4x4_y_i == 0 ) ? { EO_90_3 [15:8], 8'b0 } : EO_90_3  ;
assign EO_135_0_w = ( sao_4x4_y_i == 0 ) ? { EO_135_0[15:8], 8'b0 } : EO_135_0 ;
assign EO_135_1_w = ( sao_4x4_y_i == 0 ) ? { EO_135_1[15:8], 8'b0 } : EO_135_1 ;
assign EO_135_2_w = ( sao_4x4_y_i == 0 ) ? { EO_135_2[15:8], 8'b0 } : EO_135_2 ;
assign EO_135_3_w = ( sao_4x4_y_i == 0 ) ? { EO_135_3[15:8], 8'b0 } : EO_135_3 ;
assign BO_0_w     = ( sao_4x4_y_i == 0 ) ? { BO_0    [15:8], 8'b0 } : BO_0     ;
assign BO_1_w     = ( sao_4x4_y_i == 0 ) ? { BO_1    [15:8], 8'b0 } : BO_1     ;
assign BO_2_w     = ( sao_4x4_y_i == 0 ) ? { BO_2    [15:8], 8'b0 } : BO_2     ;
assign BO_3_w     = ( sao_4x4_y_i == 0 ) ? { BO_3    [15:8], 8'b0 } : BO_3     ;
assign BO_4_w     = ( sao_4x4_y_i == 0 ) ? { BO_4    [15:8], 8'b0 } : BO_4     ;
assign BO_5_w     = ( sao_4x4_y_i == 0 ) ? { BO_5    [15:8], 8'b0 } : BO_5     ;
assign BO_6_w     = ( sao_4x4_y_i == 0 ) ? { BO_6    [15:8], 8'b0 } : BO_6     ;
assign BO_7_w     = ( sao_4x4_y_i == 0 ) ? { BO_7    [15:8], 8'b0 } : BO_7     ;

always @*  begin 
    EO_0_0_o    = 0 ;
    EO_0_1_o    = 0 ;
    EO_0_2_o    = 0 ;
    EO_0_3_o    = 0 ;
    EO_45_0_o   = 0 ;
    EO_45_1_o   = 0 ;
    EO_45_2_o   = 0 ;
    EO_45_3_o   = 0 ;
    EO_90_0_o   = 0 ;
    EO_90_1_o   = 0 ;
    EO_90_2_o   = 0 ;
    EO_90_3_o   = 0 ;
    EO_135_0_o  = 0 ;
    EO_135_1_o  = 0 ;
    EO_135_2_o  = 0 ;
    EO_135_3_o  = 0 ;
    BO_0_o      = 0 ;
    BO_1_o      = 0 ;
    BO_2_o      = 0 ;
    BO_3_o      = 0 ;
    BO_4_o      = 0 ;
    BO_5_o      = 0 ;
    BO_6_o      = 0 ;
    BO_7_o      = 0 ;
    if (  (sao_sel_i == `TYPE_Y && sao_4x4_y_i != 15 && sao_4x4_x_i != 15 )
        ||(sao_sel_i == `TYPE_U && sao_4x4_y_i != 7  && sao_4x4_x_i != 7  )
        ||(sao_sel_i == `TYPE_V && sao_4x4_y_i != 7  && sao_4x4_x_i != 7  ) ) begin 
        EO_0_0_o   = EO_0_0_w   ;
        EO_0_1_o   = EO_0_1_w   ;
        EO_0_2_o   = EO_0_2_w   ;
        EO_0_3_o   = EO_0_3_w   ;
        EO_45_0_o  = EO_45_0_w  ;
        EO_45_1_o  = EO_45_1_w  ;
        EO_45_2_o  = EO_45_2_w  ;
        EO_45_3_o  = EO_45_3_w  ;
        EO_90_0_o  = EO_90_0_w  ;
        EO_90_1_o  = EO_90_1_w  ;
        EO_90_2_o  = EO_90_2_w  ;
        EO_90_3_o  = EO_90_3_w  ;
        EO_135_0_o = EO_135_0_w ;
        EO_135_1_o = EO_135_1_w ;
        EO_135_2_o = EO_135_2_w ;
        EO_135_3_o = EO_135_3_w ;
        BO_0_o     = BO_0_w     ;
        BO_1_o     = BO_1_w     ;
        BO_2_o     = BO_2_w     ;
        BO_3_o     = BO_3_w     ;
        BO_4_o     = BO_4_w     ;
        BO_5_o     = BO_5_w     ;
        BO_6_o     = BO_6_w     ;
        BO_7_o     = BO_7_w     ;
    end 
end 

endmodule
