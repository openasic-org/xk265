//-----------------------------------------------------------------------------------------------------------------------------
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
// Filename       : mvd_can_mv_addr.v
// Author         : chewein
// Created        : 2015-08-17
// Description    : 
//               
// $Id$ 
//-----------------------------------------------------------------------------------------------------------------------------      
`include "enc_defines.v"

module mvd_getBits(
                mv_i             ,
                mvp_i            ,
                mv_bits_cnt_o    ,
                mvd_o
            );
// -----------------------------------------------------------------------------------------------------------------------------
//
//        INPUT and OUTPUT DECLARATION
//
// -----------------------------------------------------------------------------------------------------------------------------
input    [  2*`FMV_WIDTH-1:0] mv_i               ; // fmv from fme
input    [  2*`FMV_WIDTH-1:0] mvp_i              ; // fmv from fme
output   [             7-1:0] mv_bits_cnt_o      ; // fmv from fme

output   [  2*`MVD_WIDTH-1:0] mvd_o              ; // fmv from fme 

wire signed  [`FMV_WIDTH  :0] mv_x               ;
wire signed  [`FMV_WIDTH  :0] mv_y               ;
wire signed  [`FMV_WIDTH  :0] mvp_x              ;
wire signed  [`FMV_WIDTH  :0] mvp_y              ;
wire signed  [`MVD_WIDTH-1:0] mv_x_diff_temp     ;
wire signed  [`MVD_WIDTH-1:0] mv_y_diff_temp     ;

wire signed  [`MVD_WIDTH  :0] mv_x_diff          ;
wire signed  [`MVD_WIDTH  :0] mv_y_diff          ;

reg      [             6-1:0] num_x_00           ; // fmv from fme
reg      [             6-1:0] num_x_01           ; // fmv from fme
reg      [             6-1:0] num_x_02           ; // fmv from fme
reg      [             6-1:0] num_x              ; // fmv from fme
reg      [             6-1:0] num_y_00           ; // fmv from fme
reg      [             6-1:0] num_y_01           ; // fmv from fme
reg      [             6-1:0] num_y_02           ; // fmv from fme
reg      [             6-1:0] num_y              ; // fmv from fme

assign   mv_x  = {mv_i [   `FMV_WIDTH-1],mv_i[   `FMV_WIDTH-1:         0]};
assign   mv_y  = {mv_i [ 2*`FMV_WIDTH-1],mv_i[ 2*`FMV_WIDTH-1:`FMV_WIDTH]};
assign   mvp_x = {mvp_i[   `FMV_WIDTH-1],mvp_i[  `FMV_WIDTH-1:         0]};
assign   mvp_y = {mvp_i[ 2*`FMV_WIDTH-1],mvp_i[2*`FMV_WIDTH-1:`FMV_WIDTH]};

assign   mv_x_diff_temp = mv_x - mvp_x ;
assign   mv_y_diff_temp = mv_y - mvp_y ;

assign   mv_x_diff      = {mv_x_diff_temp,1'b0};
assign   mv_y_diff      = {mv_y_diff_temp,1'b0};

always @* begin 
    if(mv_x_diff[3])
        num_x_00    =    6'd7;
    else if(mv_x_diff[2])
        num_x_00    =    6'd5;
    else if(mv_x_diff[1])
        num_x_00    =    6'd3;
    else 
        num_x_00    =    6'd1;
end

always @* begin 
    if(mv_x_diff[7])
        num_x_01    =    6'd15;
    else if(mv_x_diff[6])
        num_x_01    =    6'd13;
    else if(mv_x_diff[5])
        num_x_01    =    6'd11;
    else if(mv_x_diff[4])
        num_x_01    =    6'd9;
    else 
        num_x_01    =    6'd0;
end

always @* begin 
    if(mv_x_diff[11])
        num_x_02    =    6'd63; // 6'd63;
    else if(mv_x_diff[10])
        num_x_02    =    6'd21;
    else if(mv_x_diff[9])
        num_x_02    =    6'd19;
    else if(mv_x_diff[8])
        num_x_02    =    6'd17;
    else 
        num_x_02    =    6'd0;
end

always@*begin
	num_x  = num_x_00;
    if(num_x_02)
        num_x  = num_x_02;
    else if(num_x_01)
        num_x  = num_x_01;
   else if(num_x_00)
        num_x  = num_x_00;
end

always @* begin 
    if(mv_y_diff[3])
        num_y_00    =    6'd7;
    else if(mv_y_diff[2])
        num_y_00    =    6'd5;
    else if(mv_y_diff[1])
        num_y_00    =    6'd3;
    else 
        num_y_00    =    6'd1;
end

always @* begin 
    if(mv_y_diff[7])
        num_y_01    =    6'd15;
    else if(mv_y_diff[6])
        num_y_01    =    6'd13;
    else if(mv_y_diff[5])
        num_y_01    =    6'd11;
    else if(mv_y_diff[4])
        num_y_01    =    6'd9;
    else
        num_y_01    =    6'd0;        
end

always @* begin 
    if(mv_y_diff[11])
        num_y_02    =    6'd63; // 6'd63;
    else if(mv_y_diff[10])
        num_y_02    =    6'd21;
    else if(mv_y_diff[9])
        num_y_02    =    6'd19;
    else if(mv_y_diff[8])
        num_y_02    =    6'd17;
    else
        num_y_02    =    6'd0;
end

always@*begin
	num_y  = num_y_00;
    if(num_y_02)
        num_y  = num_y_02;
    else if(num_y_01)
        num_y  = num_y_01;
    else if(num_y_00)
        num_y  = num_y_00;
end

assign mv_bits_cnt_o= num_x + num_y;
assign mvd_o   =  {mv_x_diff_temp, mv_y_diff_temp};


endmodule

