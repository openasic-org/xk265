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
// Filename       : cabac_rlps4.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : update range
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
module cabac_rlps4(
           clk,
           enable,
           en,
           rst_n,

           number_range,
           number_all,
           index_bypass,
           symbol_bypass,

           out_number_range,
           out_number_all,
           out_index_bypass,
           out_symbol_bypass,

           in_lpsmps_0,
           in_pstateidx_0,
           in_lpsmps_1,
           in_pstateidx_1,
           in_lpsmps_2,
           in_pstateidx_2,
           in_lpsmps_3,
           in_pstateidx_3,

           out_lpsmps_0,
           out_four_rlps_0,
           out_four_rlps_shift_0,
           out_lpsmps_1,
           out_four_rlps_1,
           out_four_rlps_shift_1,
           out_lpsmps_2,
           out_four_rlps_2,
           out_four_rlps_shift_2,
           out_lpsmps_3,
           out_four_rlps_shift_3,
           out_four_rlps_3
       );

//input and output signal //{
input       clk;
input       enable;
input       en;   //0 to reset
input               rst_n;

input   [2:0] number_range;
input   [3:0] number_all;
input   [7:0] index_bypass;
input   [7:0] symbol_bypass;

output  reg [2:0] out_number_range;
output  reg [3:0] out_number_all;
output  reg [7:0] out_index_bypass;
output  reg [7:0] out_symbol_bypass;

input       in_lpsmps_0;
input   [5:0] in_pstateidx_0;
input       in_lpsmps_1;
input   [5:0] in_pstateidx_1;
input       in_lpsmps_2;
input   [5:0] in_pstateidx_2;
input       in_lpsmps_3;
input   [5:0] in_pstateidx_3;

output  reg     out_lpsmps_0;
output  reg [31:0]  out_four_rlps_0;
//[31:24] rlps_0
//[23:16] rlps_1
//[15:8]  rlps_2
//[7:0]   rlps_3

output  reg [43:0]  out_four_rlps_shift_0;
//[43:41] shift_rlps_0 // shift left
//[40:33] rlps_shift_0 // number of shift bits.
//[32:30] shift_rlps_1
//[29:22] rlps_shift_1
//[21:19] shift_rlps_2
//[18:11] rlps_shift_2
//[10:8]  shift_rlps_3
//[7:0]   rlps_shift_3
//}

output  reg     out_lpsmps_1;
output  reg [31:0]  out_four_rlps_1;
output  reg [43:0]  out_four_rlps_shift_1;
output  reg     out_lpsmps_2;
output  reg [31:0]  out_four_rlps_2;
output  reg [43:0]  out_four_rlps_shift_2;
output  reg     out_lpsmps_3;
output  reg [31:0]  out_four_rlps_3;
output  reg [43:0]  out_four_rlps_shift_3;
//}

//wire signal //{
wire    [31:0]  wire_out_four_rlps_0;
wire    [31:0]  wire_out_four_rlps_1;
wire    [31:0]  wire_out_four_rlps_2;
wire    [31:0]  wire_out_four_rlps_3;

wire    [43:0]  wire_out_four_rlps_shift_0;
wire    [43:0]  wire_out_four_rlps_shift_1;
wire    [43:0]  wire_out_four_rlps_shift_2;
wire    [43:0]  wire_out_four_rlps_shift_3;
//}

//module logic //{
cabac_rlps4_1bin cabac_rlps_0(.pstateidx(in_pstateidx_0), .four_rlps(wire_out_four_rlps_0), .four_rlps_shift(wire_out_four_rlps_shift_0));
cabac_rlps4_1bin cabac_rlps_1(.pstateidx(in_pstateidx_1), .four_rlps(wire_out_four_rlps_1), .four_rlps_shift(wire_out_four_rlps_shift_1));
cabac_rlps4_1bin cabac_rlps_2(.pstateidx(in_pstateidx_2), .four_rlps(wire_out_four_rlps_2), .four_rlps_shift(wire_out_four_rlps_shift_2));
cabac_rlps4_1bin cabac_rlps_3(.pstateidx(in_pstateidx_3), .four_rlps(wire_out_four_rlps_3), .four_rlps_shift(wire_out_four_rlps_shift_3));
//}

//reg logic //{
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        out_number_all <= 0;
        out_number_range <= 0;
        out_index_bypass <= 0;
        out_symbol_bypass <=0;

        out_lpsmps_0 <= 0;
        out_lpsmps_1 <= 0;
        out_lpsmps_2 <= 0;
        out_lpsmps_3 <= 0;

        out_four_rlps_0 <= 0;
        out_four_rlps_1 <= 0;
        out_four_rlps_2 <= 0;
        out_four_rlps_3 <= 0;

        out_four_rlps_shift_0 <= 0;
        out_four_rlps_shift_1 <= 0;
        out_four_rlps_shift_2 <= 0;
        out_four_rlps_shift_3 <= 0;
    end
    else if(!en)
    begin
        out_number_all <= 0;
        out_number_range <= 0;
        out_index_bypass <= 0;
        out_symbol_bypass <=0;

        out_lpsmps_0 <= 0;
        out_lpsmps_1 <= 0;
        out_lpsmps_2 <= 0;
        out_lpsmps_3 <= 0;

        out_four_rlps_0 <= 0;
        out_four_rlps_1 <= 0;
        out_four_rlps_2 <= 0;
        out_four_rlps_3 <= 0;

        out_four_rlps_shift_0 <= 0;
        out_four_rlps_shift_1 <= 0;
        out_four_rlps_shift_2 <= 0;
        out_four_rlps_shift_3 <= 0;
    end
    else if(enable)
    begin
        out_number_range <= number_range;
        out_number_all <= number_all;
        out_index_bypass <= index_bypass;
        out_symbol_bypass <= symbol_bypass;

        out_lpsmps_0 <= in_lpsmps_0;
        out_lpsmps_1 <= in_lpsmps_1;
        out_lpsmps_2 <= in_lpsmps_2;
        out_lpsmps_3 <= in_lpsmps_3;

        out_four_rlps_0 <= wire_out_four_rlps_0;
        out_four_rlps_1 <= wire_out_four_rlps_1;
        out_four_rlps_2 <= wire_out_four_rlps_2;
        out_four_rlps_3 <= wire_out_four_rlps_3;

        out_four_rlps_shift_0 <= wire_out_four_rlps_shift_0;
        out_four_rlps_shift_1 <= wire_out_four_rlps_shift_1;
        out_four_rlps_shift_2 <= wire_out_four_rlps_shift_2;
        out_four_rlps_shift_3 <= wire_out_four_rlps_shift_3;
    end
end
//}

endmodule
