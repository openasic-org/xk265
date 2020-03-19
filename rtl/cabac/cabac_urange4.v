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
// Filename       : cabac_urange4.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : update range
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------

module cabac_urange4(
           clk,
           en,
           rst_n,
           enable,

           number_range,
           number_all,
           index_bypass,
           symbol_bypass,

           out_number_all,
           out_index_bypass,
           out_symbol_bypass,

           in_lpsmps_0,
           in_four_lps_0,
           in_four_lps_shift_0,
           in_lpsmps_1,
           in_four_lps_1,
           in_four_lps_shift_1,
           in_lpsmps_2,
           in_four_lps_2,
           in_four_lps_shift_2,
           in_lpsmps_3,
           in_four_lps_shift_3,
           in_four_lps_3,

           out_lpsmps_0,
           out_range_0,
           out_rlps_0,
           out_shift_0,
           out_lpsmps_1,
           out_range_1,
           out_rlps_1,
           out_shift_1,
           out_lpsmps_2,
           out_range_2,
           out_rlps_2,
           out_shift_2,
           out_lpsmps_3,
           out_range_3,
           out_rlps_3,
           out_shift_3,
           out_range_4
       );

//input and output signal //{
input       clk;
input       en;
input               rst_n;
input       enable;

input   [2:0] number_range;
input   [3:0] number_all;
input   [7:0] index_bypass;
input   [7:0] symbol_bypass;

output  reg [3:0] out_number_all;
output  reg [7:0] out_index_bypass;
output  reg [7:0] out_symbol_bypass;

input       in_lpsmps_0;
input   [31:0]  in_four_lps_0;
input   [43:0]  in_four_lps_shift_0;
input       in_lpsmps_1;
input   [31:0]  in_four_lps_1;
input   [43:0]  in_four_lps_shift_1;
input       in_lpsmps_2;
input   [31:0]  in_four_lps_2;
input   [43:0]  in_four_lps_shift_2;
input       in_lpsmps_3;
input   [31:0]  in_four_lps_3;
input   [43:0]  in_four_lps_shift_3;

output  reg     out_lpsmps_0;
output  reg [7:0] out_range_0;
output  reg [7:0] out_rlps_0;
output  reg [2:0] out_shift_0;
output  reg     out_lpsmps_1;
output  reg [7:0] out_range_1;
output  reg [7:0] out_rlps_1;
output  reg [2:0] out_shift_1;
output  reg     out_lpsmps_2;
output  reg [7:0] out_range_2;
output  reg [7:0] out_rlps_2;
output  reg [2:0] out_shift_2;
output  reg     out_lpsmps_3;
output  reg [7:0] out_range_3;
output  reg [7:0] out_rlps_3;
output  reg [2:0] out_shift_3;
output  reg [7:0] out_range_4;
//}

//reg signal //{
reg   [7:0]   range;
reg   [7:0]   next_range;
//}

//wire signal //{
reg   [7:0]   wire_range;

wire  [7:0]   out_range_full_0;
wire  [7:0]   out_range_full_1;
wire  [7:0]   out_range_full_2;
wire  [7:0]   out_range_full_3;

wire  [7:0]   out_rlps_full_0;
wire  [7:0]   out_rlps_full_1;
wire  [7:0]   out_rlps_full_2;
wire  [7:0]   out_rlps_full_3;

wire  [2:0]   out_shift_full_0;
wire  [2:0]   out_shift_full_1;
wire  [2:0]   out_shift_full_2;
wire  [2:0]   out_shift_full_3;
//}

//module logic //{
cabac_urange4_full cabac_update_range_full_0(
                       .in_range(range),
                       .lpsmps(in_lpsmps_0),
                       .four_lps(in_four_lps_0),
                       .four_lps_shift(in_four_lps_shift_0),
                       .out_range(out_range_full_0),
                       .out_rlps(out_rlps_full_0),
                       .out_shift(out_shift_full_0)
                   );
cabac_urange4_full cabac_update_range_full_1(
                       .in_range(out_range_full_0),
                       .lpsmps(in_lpsmps_1),
                       .four_lps(in_four_lps_1),
                       .four_lps_shift(in_four_lps_shift_1),
                       .out_range(out_range_full_1),
                       .out_rlps(out_rlps_full_1),
                       .out_shift(out_shift_full_1)
                   );
cabac_urange4_full cabac_update_range_full_2(
                       .in_range(out_range_full_1),
                       .lpsmps(in_lpsmps_2),
                       .four_lps(in_four_lps_2),
                       .four_lps_shift(in_four_lps_shift_2),
                       .out_range(out_range_full_2),
                       .out_rlps(out_rlps_full_2),
                       .out_shift(out_shift_full_2)
                   );
cabac_urange4_full cabac_update_range_full_3(
                       .in_range(out_range_full_2),
                       .lpsmps(in_lpsmps_3),
                       .four_lps(in_four_lps_3),
                       .four_lps_shift(in_four_lps_shift_3),
                       .out_range(out_range_full_3),
                       .out_rlps(out_rlps_full_3),
                       .out_shift(out_shift_full_3)
                   );
//}

//reg logic //{
always @(posedge clk or negedge rst_n)
    if(!rst_n)
    begin
        range <= 8'hfe;
        next_range <= 0;
    end
    else if(!en)
    begin
        range <= 8'hfe;
        next_range <= 0;
    end
    else if(enable)
    begin
        range <= wire_range;
        next_range <= range;
    end


always @(posedge clk or negedge rst_n)
    if(!rst_n)
    begin
        out_number_all   <= 0;
        out_index_bypass <= 0;
        out_symbol_bypass <= 0;
        out_lpsmps_0 <= 0;
        out_lpsmps_1 <= 0;
        out_lpsmps_2 <= 0;
        out_lpsmps_3 <= 0;

        out_range_0 <= 0;
        out_range_1 <= 0;
        out_range_2 <= 0;
        out_range_3 <= 0;
        out_range_4 <= 0;

        out_rlps_0 <= 0;
        out_rlps_1 <= 0;
        out_rlps_2 <= 0;
        out_rlps_3 <= 0;

        out_shift_0 <= 0;
        out_shift_1 <= 0;
        out_shift_2 <= 0;
        out_shift_3 <= 0;
    end
    else if(!en)
    begin
        out_number_all   <= 0;
        out_index_bypass <= 0;
        out_symbol_bypass <= 0;
        out_lpsmps_0 <= 0;
        out_lpsmps_1 <= 0;
        out_lpsmps_2 <= 0;
        out_lpsmps_3 <= 0;

        out_range_0 <= 0;
        out_range_1 <= 0;
        out_range_2 <= 0;
        out_range_3 <= 0;
        out_range_4 <= 0;

        out_rlps_0 <= 0;
        out_rlps_1 <= 0;
        out_rlps_2 <= 0;
        out_rlps_3 <= 0;

        out_shift_0 <= 0;
        out_shift_1 <= 0;
        out_shift_2 <= 0;
        out_shift_3 <= 0;
    end
    else if (enable)
    begin
        out_number_all <= number_all;
        out_index_bypass <= index_bypass;
        out_symbol_bypass <= symbol_bypass;

        out_lpsmps_0 <= in_lpsmps_0;
        out_lpsmps_1 <= in_lpsmps_1;
        out_lpsmps_2 <= in_lpsmps_2;
        out_lpsmps_3 <= in_lpsmps_3;

        out_range_0 <= range;
        out_range_1 <= out_range_full_0;
        out_range_2 <= out_range_full_1;
        out_range_3 <= out_range_full_2;
        out_range_4 <= out_range_full_3;

        out_rlps_0 <= out_rlps_full_0;
        out_rlps_1 <= out_rlps_full_1;
        out_rlps_2 <= out_rlps_full_2;
        out_rlps_3 <= out_rlps_full_3;

        out_shift_0 <= out_shift_full_0;
        out_shift_1 <= out_shift_full_1;
        out_shift_2 <= out_shift_full_2;
        out_shift_3 <= out_shift_full_3;
    end

//}

//wire logic //{
always @(*) //wire_range
begin
    wire_range = range;
    case (number_range)
        3'd1 :
        begin
            wire_range = out_range_full_0;
        end
        3'd2 :
        begin
            wire_range = out_range_full_1;
        end
        3'd3 :
        begin
            wire_range = out_range_full_2;
        end
        3'd4 :
        begin
            wire_range = out_range_full_3;
        end
        default:
        begin
            wire_range = range;
        end
    endcase
end

//}

endmodule
