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
// Filename       : cabac_se_prepare_coeff_last_sig_xy.v
// Author         : liwei
// Created        : 2018/1/23
// Description    : syntax elements related coeff
// DATA & EDITION:  2018/1/23   1.0     liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module cabac_se_prepare_coeff_last_sig_xy(
           last_sig_x_i                           ,
           last_sig_y_i                           ,
           tu_depth_i                             ,
           scan_idx_i                             ,
           etype_i                                 ,
           se_pair_last_x_prefix_0_o              ,
           se_pair_last_x_suffix_o                ,
           se_pair_last_y_prefix_0_o              ,
           se_pair_last_y_suffix_o
       );
//-----------------------------------------------------------------------------------------------------------------------------
//
//            input and output signals declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
input         [ 4:0 ]                  last_sig_x_i                            ;
input         [ 4:0 ]                  last_sig_y_i                            ;

input         [ 1:0 ]                  tu_depth_i                              ; // 0:32x32 , 1:16x16 , 2:8x8 , 3:4x4
input         [ 1:0 ]                  scan_idx_i                              ;
input         [ 1:0 ]                  etype_i                                 ; // 2:luma , 1 :chroma u ,0 : chroma v

output        [20:0]                   se_pair_last_x_prefix_0_o              ;
output        [20:0]                   se_pair_last_x_suffix_o                ;
output        [20:0]                   se_pair_last_y_prefix_0_o              ;
output        [20:0]                   se_pair_last_y_suffix_o                ;

//-----------------------------------------------------------------------------------------------------------------------------
//
//            reg and wire signals declaration
//
//-----------------------------------------------------------------------------------------------------------------------------

reg           [ 4:0 ]                  pos_x_r                                 ;
reg           [ 4:0 ]                  pos_y_r                                 ;

reg           [ 3:0 ]                 last_sig_coeff_x_prefix_r                ; // 0..9
reg           [ 3:0 ]                 last_sig_coeff_y_prefix_r                ; // 0..9
reg           [ 8:0 ]                 ctxIdx_last_sig_coeff_x_prefix_r         ;
reg           [ 8:0 ]                 ctxIdx_last_sig_coeff_y_prefix_r         ;
reg           [ 3:0 ]                 cmax_of_last_sig_coeff_info_r            ;
reg           [ 20:0]                 se_pair_last_x_suffix_r                  ;
reg           [ 20:0]                 se_pair_last_y_suffix_r                  ;

// pos_x_r
always @*
begin
    if(scan_idx_i == 2'd2 )
        pos_x_r              =         last_sig_y_i                            ;
    else
        pos_x_r              =         last_sig_x_i                            ;
end

// pos_y_r
always @*
begin
    if(scan_idx_i == 2'd2 )
        pos_y_r              =         last_sig_x_i                            ;
    else
        pos_y_r              =         last_sig_y_i                            ;
end

// last_sig_coeff_x_prefix_r ,the paper 146 of book <HEVC>
always @*
begin
    case(pos_x_r)
        5'd0                        :
            last_sig_coeff_x_prefix_r   =   4'd0               ;
        5'd1                        :
            last_sig_coeff_x_prefix_r   =   4'd1               ;
        5'd2                        :
            last_sig_coeff_x_prefix_r   =   4'd2               ;
        5'd3                        :
            last_sig_coeff_x_prefix_r   =   4'd3               ;
        5'd4 , 5'd5                 :
            last_sig_coeff_x_prefix_r   =   4'd4               ;
        5'd6 , 5'd7                 :
            last_sig_coeff_x_prefix_r   =   4'd5               ;
        5'd8 , 5'd9 , 5'd10, 5'd11  :
            last_sig_coeff_x_prefix_r   =   4'd6               ;
        5'd12, 5'd13, 5'd14, 5'd15  :
            last_sig_coeff_x_prefix_r   =   4'd7               ;
        5'd16, 5'd17, 5'd18, 5'd19  ,
        5'd20, 5'd21, 5'd22, 5'd23  :
            last_sig_coeff_x_prefix_r   =   4'd8               ;
        default                     :
            last_sig_coeff_x_prefix_r   =   4'd9               ;
    endcase
end

// last_sig_coeff_y_prefix_r
always @*
begin
    case(pos_y_r)
        5'd0                        :
            last_sig_coeff_y_prefix_r   =   4'd0               ;
        5'd1                        :
            last_sig_coeff_y_prefix_r   =   4'd1               ;
        5'd2                        :
            last_sig_coeff_y_prefix_r   =   4'd2               ;
        5'd3                        :
            last_sig_coeff_y_prefix_r   =   4'd3               ;
        5'd4 , 5'd5                 :
            last_sig_coeff_y_prefix_r   =   4'd4               ;
        5'd6 , 5'd7                 :
            last_sig_coeff_y_prefix_r   =   4'd5               ;
        5'd8 , 5'd9 , 5'd10, 5'd11  :
            last_sig_coeff_y_prefix_r   =   4'd6               ;
        5'd12, 5'd13, 5'd14, 5'd15  :
            last_sig_coeff_y_prefix_r   =   4'd7               ;
        5'd16, 5'd17, 5'd18, 5'd19  ,
        5'd20, 5'd21, 5'd22, 5'd23  :
            last_sig_coeff_y_prefix_r   =   4'd8               ;
        default                     :
            last_sig_coeff_y_prefix_r   =   4'd9               ;
    endcase
end

// ctxIdx_last_sig_coeff_y_prefix_r
always @*
begin
    case({etype_i[1],tu_depth_i})
        3'd7 :
        begin
            ctxIdx_last_sig_coeff_x_prefix_r = 9'h056 ;
            ctxIdx_last_sig_coeff_y_prefix_r =  9'h074 ;
            cmax_of_last_sig_coeff_info_r = 4'h3;
        end//luma 4x4
        3'd6 :
        begin
            ctxIdx_last_sig_coeff_x_prefix_r = 9'h059 ;
            ctxIdx_last_sig_coeff_y_prefix_r =  9'h077 ;
            cmax_of_last_sig_coeff_info_r = 4'h5;
        end//luma 8x8
        3'd5 :
        begin
            ctxIdx_last_sig_coeff_x_prefix_r = 9'h05c ;
            ctxIdx_last_sig_coeff_y_prefix_r =  9'h07a ;
            cmax_of_last_sig_coeff_info_r = 4'h7;
        end//luma 16x16
        3'd4 :
        begin
            ctxIdx_last_sig_coeff_x_prefix_r = 9'h060 ;
            ctxIdx_last_sig_coeff_y_prefix_r =  9'h07e ;
            cmax_of_last_sig_coeff_info_r = 4'h9;
        end//luma 32x32
        3'd3 :
        begin
            ctxIdx_last_sig_coeff_x_prefix_r = 9'h065 ;
            ctxIdx_last_sig_coeff_y_prefix_r =  9'h083 ;
            cmax_of_last_sig_coeff_info_r = 4'h3;
        end//chroma 4x4
        3'd2 :
        begin
            ctxIdx_last_sig_coeff_x_prefix_r = 9'h065 ;
            ctxIdx_last_sig_coeff_y_prefix_r =  9'h083 ;
            cmax_of_last_sig_coeff_info_r = 4'h5;
        end//chroma 8x8
        3'd1 :
        begin
            ctxIdx_last_sig_coeff_x_prefix_r = 9'h065 ;
            ctxIdx_last_sig_coeff_y_prefix_r =  9'h083 ;
            cmax_of_last_sig_coeff_info_r = 4'h7;
        end//chroma 16x16
        default:
        begin
            ctxIdx_last_sig_coeff_x_prefix_r = 9'b0 ;
            ctxIdx_last_sig_coeff_y_prefix_r =  9'b0 ;
            cmax_of_last_sig_coeff_info_r = 4'b0;
        end
    endcase
end

//-----------------------------------------------------------------------------------------------------------------------------
//
//            binarization for last_sig_x
//
//-----------------------------------------------------------------------------------------------------------------------------
wire    [20:0]  se_pair_last_x_prefix_0_w;

assign se_pair_last_x_prefix_0_w = {4'h0,last_sig_coeff_x_prefix_r,cmax_of_last_sig_coeff_info_r,ctxIdx_last_sig_coeff_x_prefix_r};

always @*
begin
    case(pos_x_r)
        5'd0  :
            se_pair_last_x_suffix_r   =   21'b0 ; //  i_count=  0
        5'd1  :
            se_pair_last_x_suffix_r   =   21'b0 ; //  i_count=  0
        5'd2  :
            se_pair_last_x_suffix_r   =   21'b0 ; //  i_count=  0
        5'd3  :
            se_pair_last_x_suffix_r   =   21'b0 ; //  i_count=  0
        5'd4  :
            se_pair_last_x_suffix_r   =   {8'h00,4'h1,9'h0bb } ; //  i_count=  1        0
        5'd5  :
            se_pair_last_x_suffix_r   =   {8'h01,4'h1,9'h0bb } ; //  i_count=  1        1
        5'd6  :
            se_pair_last_x_suffix_r   =   {8'h00,4'h1,9'h0bb } ; //  i_count=  1        0
        5'd7  :
            se_pair_last_x_suffix_r   =   {8'h01,4'h1,9'h0bb } ; //  i_count=  1        1
        5'd8  :
            se_pair_last_x_suffix_r   =   {6'h00,2'b00,4'h2,9'h0bb } ; //  i_count=  2      00
        5'd9  :
            se_pair_last_x_suffix_r   =   {6'h00,2'b01,4'h2,9'h0bb } ; //  i_count=  2      01
        5'd10 :
            se_pair_last_x_suffix_r   =   {6'h00,2'b10,4'h2,9'h0bb } ; //  i_count=  2      10
        5'd11 :
            se_pair_last_x_suffix_r   =   {6'h00,2'b11,4'h2,9'h0bb }  ; //  i_count=  2     11
        5'd12 :
            se_pair_last_x_suffix_r   =   {6'h00,2'b00,4'h2,9'h0bb } ; //  i_count=  2      00
        5'd13 :
            se_pair_last_x_suffix_r   =   {6'h00,2'b01,4'h2,9'h0bb } ; //  i_count=  2      01
        5'd14 :
            se_pair_last_x_suffix_r   =   {6'h00,2'b10,4'h2,9'h0bb } ; //  i_count=  2      10
        5'd15 :
            se_pair_last_x_suffix_r   =   {6'h00,2'b11,4'h2,9'h0bb } ; //  i_count=  2      11
        5'd16 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b000,4'h3,9'h0bb } ; //  i_count=  3     000
        5'd17 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b001,4'h3,9'h0bb } ; //  i_count=  3     001
        5'd18 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b010,4'h3,9'h0bb } ; //  i_count=  3     010
        5'd19 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b011,4'h3,9'h0bb } ; //  i_count=  3     011
        5'd20 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b100,4'h3,9'h0bb } ; //  i_count=  3     100
        5'd21 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b101,4'h3,9'h0bb } ; //  i_count=  3     101
        5'd22 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b110,4'h3,9'h0bb } ; //  i_count=  3     110
        5'd23 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b111,4'h3,9'h0bb } ; //  i_count=  3     111
        5'd24 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b000,4'h3,9'h0bb } ; //  i_count=  3     000
        5'd25 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b001,4'h3,9'h0bb } ; //  i_count=  3     001
        5'd26 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b010,4'h3,9'h0bb } ; //  i_count=  3     010
        5'd27 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b011,4'h3,9'h0bb } ; //  i_count=  3     011
        5'd28 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b100,4'h3,9'h0bb } ; //  i_count=  3     100
        5'd29 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b101,4'h3,9'h0bb } ; //  i_count=  3     101
        5'd30 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b110,4'h3,9'h0bb } ; //  i_count=  3     110
        5'd31 :
            se_pair_last_x_suffix_r   =   {5'h00,3'b111,4'h3,9'h0bb } ; //  i_count=  3     111
    endcase
end

//-----------------------------------------------------------------------------------------------------------------------------
//
//            binarization for last_sig_y
//
//-----------------------------------------------------------------------------------------------------------------------------
wire    [20:0]  se_pair_last_y_prefix_0_w;

assign se_pair_last_y_prefix_0_w = {4'h0,last_sig_coeff_y_prefix_r,cmax_of_last_sig_coeff_info_r,ctxIdx_last_sig_coeff_y_prefix_r};

always @*
begin
    case(pos_y_r)
        5'd0  :
            se_pair_last_y_suffix_r   =   21'b0 ; //  i_count=  0
        5'd1  :
            se_pair_last_y_suffix_r   =   21'b0 ; //  i_count=  0
        5'd2  :
            se_pair_last_y_suffix_r   =   21'b0 ; //  i_count=  0
        5'd3  :
            se_pair_last_y_suffix_r   =   21'b0 ; //  i_count=  0
        5'd4  :
            se_pair_last_y_suffix_r   =   {8'h00,4'h1,9'h0bb } ; //  i_count=  1        0
        5'd5  :
            se_pair_last_y_suffix_r   =   {8'h01,4'h1,9'h0bb } ; //  i_count=  1        1
        5'd6  :
            se_pair_last_y_suffix_r   =   {8'h00,4'h1,9'h0bb } ; //  i_count=  1        0
        5'd7  :
            se_pair_last_y_suffix_r   =   {8'h01,4'h1,9'h0bb } ; //  i_count=  1        1
        5'd8  :
            se_pair_last_y_suffix_r   =   {6'h00,2'b00,4'h2,9'h0bb } ; //  i_count=  2      00
        5'd9  :
            se_pair_last_y_suffix_r   =   {6'h00,2'b01,4'h2,9'h0bb } ; //  i_count=  2      01
        5'd10 :
            se_pair_last_y_suffix_r   =   {6'h00,2'b10,4'h2,9'h0bb } ; //  i_count=  2      10
        5'd11 :
            se_pair_last_y_suffix_r   =   {6'h00,2'b11,4'h2,9'h0bb }  ; //  i_count=  2     11
        5'd12 :
            se_pair_last_y_suffix_r   =   {6'h00,2'b00,4'h2,9'h0bb } ; //  i_count=  2      00
        5'd13 :
            se_pair_last_y_suffix_r   =   {6'h00,2'b01,4'h2,9'h0bb } ; //  i_count=  2      01
        5'd14 :
            se_pair_last_y_suffix_r   =   {6'h00,2'b10,4'h2,9'h0bb } ; //  i_count=  2      10
        5'd15 :
            se_pair_last_y_suffix_r   =   {6'h00,2'b11,4'h2,9'h0bb } ; //  i_count=  2      11
        5'd16 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b000,4'h3,9'h0bb } ; //  i_count=  3     000
        5'd17 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b001,4'h3,9'h0bb } ; //  i_count=  3     001
        5'd18 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b010,4'h3,9'h0bb } ; //  i_count=  3     010
        5'd19 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b011,4'h3,9'h0bb } ; //  i_count=  3     011
        5'd20 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b100,4'h3,9'h0bb } ; //  i_count=  3     100
        5'd21 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b101,4'h3,9'h0bb } ; //  i_count=  3     101
        5'd22 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b110,4'h3,9'h0bb } ; //  i_count=  3     110
        5'd23 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b111,4'h3,9'h0bb } ; //  i_count=  3     111
        5'd24 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b000,4'h3,9'h0bb } ; //  i_count=  3     000
        5'd25 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b001,4'h3,9'h0bb } ; //  i_count=  3     001
        5'd26 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b010,4'h3,9'h0bb } ; //  i_count=  3     010
        5'd27 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b011,4'h3,9'h0bb } ; //  i_count=  3     011
        5'd28 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b100,4'h3,9'h0bb } ; //  i_count=  3     100
        5'd29 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b101,4'h3,9'h0bb } ; //  i_count=  3     101
        5'd30 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b110,4'h3,9'h0bb } ; //  i_count=  3     110
        5'd31 :
            se_pair_last_y_suffix_r   =   {5'h00,3'b111,4'h3,9'h0bb } ; //  i_count=  3     111
    endcase
end

//-----------------------------------------------------------------------------------------------------------------------------
//
//            output signals
//
//-----------------------------------------------------------------------------------------------------------------------------

assign   se_pair_last_x_prefix_0_o    =   se_pair_last_x_prefix_0_w          ;
assign   se_pair_last_x_suffix_o      =   se_pair_last_x_suffix_r            ;
assign   se_pair_last_y_prefix_0_o    =   se_pair_last_y_prefix_0_w          ;
assign   se_pair_last_y_suffix_o      =   se_pair_last_y_suffix_r            ;


endmodule


