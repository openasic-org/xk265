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
// Filename       : cabac_ulow.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : update low value
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------


module cabac_ulow(
           clk,
           enable,
           en,
           rst_n,

           end_slice,

           in_number,
           out_number,

           bypass_0,
           bypass_1,
           bypass_2,
           bypass_3,
           bypass_4,

           lpsmps_0,
           lpsmps_1,
           lpsmps_2,
           lpsmps_3,
           lpsmps_4,

           shift_0,
           shift_1,
           shift_2,
           shift_3,
           shift_4,

           r_rmps_0,
           r_rmps_1,
           r_rmps_2,
           r_rmps_3,
           r_rmps_4,

           out_shift_0,
           out_shift_1,
           out_shift_2,
           out_shift_3,
           out_shift_4,

           out_overflow_0,
           out_overflow_1,
           out_overflow_2,
           out_overflow_3,
           out_overflow_4,

           out_buffer_0,
           out_buffer_1,
           out_buffer_2,
           out_buffer_3,
           out_buffer_4
       );

//input and output signals //{
input               clk;
input               enable;         //1 to enable
input               en;     //0 to reset
input               rst_n;

input               end_slice;

input       [2:0]   in_number;      //0~5
output  reg [2:0]   out_number;     //0~5

input               bypass_0;
input               bypass_1;
input               bypass_2;
input               bypass_3;
input               bypass_4;

input               lpsmps_0;
input               lpsmps_1;
input               lpsmps_2;
input               lpsmps_3;
input               lpsmps_4;

input       [2:0]   shift_0;
input       [2:0]   shift_1;
input       [2:0]   shift_2;
input       [2:0]   shift_3;
input       [2:0]   shift_4;

input       [8:0]   r_rmps_0;
input       [8:0]   r_rmps_1;
input       [8:0]   r_rmps_2;
input       [8:0]   r_rmps_3;
input       [8:0]   r_rmps_4;

output  reg [2:0]   out_shift_0;
output  reg [2:0]   out_shift_1;
output  reg [2:0]   out_shift_2;
output  reg [2:0]   out_shift_3;
output  reg [2:0]   out_shift_4;

output  reg         out_overflow_0;
output  reg         out_overflow_1;
output  reg         out_overflow_2;
output  reg         out_overflow_3;
output  reg         out_overflow_4;

output  reg [6:0]   out_buffer_0;
output  reg [6:0]   out_buffer_1;
output  reg [6:0]   out_buffer_2;
output  reg [6:0]   out_buffer_3;
output  reg [6:0]   out_buffer_4;
//}

//reg signals //{
reg         [8:0]   low;
reg         flag_final_out;
//}

//wire signals //{
reg     [8:0]   wire_low;
wire    [8:0]   out_low_0;
wire    [8:0]   out_low_1;
wire    [8:0]   out_low_2;
wire    [8:0]   out_low_3;
wire    [8:0]   out_low_4;

wire            wire_out_overflow_0;
wire            wire_out_overflow_1;
wire            wire_out_overflow_2;
wire            wire_out_overflow_3;
wire            wire_out_overflow_4;

wire    [6:0]   wire_out_buffer_0;
wire    [6:0]   wire_out_buffer_1;
wire    [6:0]   wire_out_buffer_2;
wire    [6:0]   wire_out_buffer_3;
wire    [6:0]   wire_out_buffer_4;
//}

//module logics //{
cabac_ulow_1bin ulow_0(
                    .in_low(low),
                    .bypass(bypass_0),
                    .lpsmps(lpsmps_0),
                    .shift(shift_0),
                    .r_rmps(r_rmps_0),
                    .out_low(out_low_0),
                    .out_overflow(wire_out_overflow_0),
                    .out_buffer(wire_out_buffer_0)
                );

cabac_ulow_1bin ulow_1(
                    .in_low(out_low_0),
                    .bypass(bypass_1),
                    .lpsmps(lpsmps_1),
                    .shift(shift_1),
                    .r_rmps(r_rmps_1),
                    .out_low(out_low_1),
                    .out_overflow(wire_out_overflow_1),
                    .out_buffer(wire_out_buffer_1)
                );
cabac_ulow_1bin ulow_2(
                    .in_low(out_low_1),
                    .bypass(bypass_2),
                    .lpsmps(lpsmps_2),
                    .shift(shift_2),
                    .r_rmps(r_rmps_2),
                    .out_low(out_low_2),
                    .out_overflow(wire_out_overflow_2),
                    .out_buffer(wire_out_buffer_2)
                );
cabac_ulow_1bin ulow_3(
                    .in_low(out_low_2),
                    .bypass(bypass_3),
                    .lpsmps(lpsmps_3),
                    .shift(shift_3),
                    .r_rmps(r_rmps_3),
                    .out_low(out_low_3),
                    .out_overflow(wire_out_overflow_3),
                    .out_buffer(wire_out_buffer_3)
                );
cabac_ulow_1bin ulow_4(
                    .in_low(out_low_3),
                    .bypass(bypass_4),
                    .lpsmps(lpsmps_4),
                    .shift(shift_4),
                    .r_rmps(r_rmps_4),
                    .out_low(out_low_4),
                    .out_overflow(wire_out_overflow_4),
                    .out_buffer(wire_out_buffer_4)
                );
//}

//logic //{
always @(posedge clk or negedge rst_n) //low
begin
    if(!rst_n)
        low <= 0;
    else if(!en)
        low <= 0;
    else if(enable)
        low <= wire_low;
    else
        low <= low;
end

always @(*) //wire_low
begin
    wire_low    =   out_low_4;
    case (in_number)
        3'd0 :
        begin
            wire_low    =   low;
        end
        3'd1 :
        begin
            wire_low    =   out_low_0;
        end
        3'd2 :
        begin
            wire_low    =   out_low_1;
        end
        3'd3 :
        begin
            wire_low    =   out_low_2;
        end
        3'd4 :
        begin
            wire_low    =   out_low_3;
        end
        default:
        begin
            wire_low    =   out_low_4;
        end
    endcase
end

always @(posedge clk or negedge rst_n) //flag_final_out
begin
    if(!rst_n)
        flag_final_out <= 0;
    else if(!en)
        flag_final_out <= 0;
    else if(end_slice && flag_final_out==0 && enable)
        flag_final_out <= 1;
    else
        flag_final_out <= flag_final_out;
end

always @(posedge clk or negedge rst_n) //output
begin
    if(!rst_n)
    begin
        out_number      <=  0;
        out_shift_0     <=  0;
        out_shift_1     <=  0;
        out_shift_2     <=  0;
        out_shift_3     <=  0;
        out_shift_4     <=  0;
        out_overflow_0  <=  0;
        out_overflow_1  <=  0;
        out_overflow_2  <=  0;
        out_overflow_3  <=  0;
        out_overflow_4  <=  0;
        out_buffer_0    <=  0;
        out_buffer_1    <=  0;
        out_buffer_2    <=  0;
        out_buffer_3    <=  0;
        out_buffer_4    <=  0;
    end
    else if(!en)
    begin
        out_number      <=  0;
        out_shift_0     <=  0;
        out_shift_1     <=  0;
        out_shift_2     <=  0;
        out_shift_3     <=  0;
        out_shift_4     <=  0;
        out_overflow_0  <=  0;
        out_overflow_1  <=  0;
        out_overflow_2  <=  0;
        out_overflow_3  <=  0;
        out_overflow_4  <=  0;
        out_buffer_0    <=  0;
        out_buffer_1    <=  0;
        out_buffer_2    <=  0;
        out_buffer_3    <=  0;
        out_buffer_4    <=  0;
    end
    else if(enable)
    begin
        if(end_slice)
        begin
            out_number      <=  flag_final_out ? 3'b000 : 3'b010;
            out_shift_0     <=  7;
            out_shift_1     <=  2;
            out_shift_2     <=  0;
            out_shift_3     <=  0;
            out_shift_4     <=  0;
            out_overflow_0  <=  0;
            out_overflow_1  <=  0;
            out_overflow_2  <=  0;
            out_overflow_3  <=  0;
            out_overflow_4  <=  0;
            out_buffer_0    <=  {low[8], 6'b100000};
            out_buffer_1    <=  0;
            out_buffer_2    <=  0;
            out_buffer_3    <=  0;
            out_buffer_4    <=  0;
        end
        else
        begin
            out_number      <=  in_number;
            out_shift_0     <=  shift_0;
            out_shift_1     <=  shift_1;
            out_shift_2     <=  shift_2;
            out_shift_3     <=  shift_3;
            out_shift_4     <=  shift_4;
            out_overflow_0  <=  wire_out_overflow_0;
            out_overflow_1  <=  wire_out_overflow_1;
            out_overflow_2  <=  wire_out_overflow_2;
            out_overflow_3  <=  wire_out_overflow_3;
            out_overflow_4  <=  wire_out_overflow_4;
            out_buffer_0    <=  wire_out_buffer_0;
            out_buffer_1    <=  wire_out_buffer_1;
            out_buffer_2    <=  wire_out_buffer_2;
            out_buffer_3    <=  wire_out_buffer_3;
            out_buffer_4    <=  wire_out_buffer_4;
        end
    end
    else
    begin
        out_number      <=  out_number;
        out_shift_0     <=  out_shift_0;
        out_shift_1     <=  out_shift_1;
        out_shift_2     <=  out_shift_2;
        out_shift_3     <=  out_shift_3;
        out_shift_4     <=  out_shift_4;
        out_overflow_0  <=  out_overflow_0;
        out_overflow_1  <=  out_overflow_1;
        out_overflow_2  <=  out_overflow_2;
        out_overflow_3  <=  out_overflow_3;
        out_overflow_4  <=  out_overflow_4;
        out_buffer_0    <=  out_buffer_0;
        out_buffer_1    <=  out_buffer_1;
        out_buffer_2    <=  out_buffer_2;
        out_buffer_3    <=  out_buffer_3;
        out_buffer_4    <=  out_buffer_4;
    end
end
//}

endmodule
