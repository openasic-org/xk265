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
// Filename       : cabac_ulow_refine.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : update low value
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------

module cabac_ulow_refine(
           clk,
           enable,
           en,
           rst_n,

           in_number,

           shift_0,
           shift_1,
           shift_2,
           shift_3,
           shift_4,

           overflow_0,
           overflow_1,
           overflow_2,
           overflow_3,
           overflow_4,

           buffer_0,
           buffer_1,
           buffer_2,
           buffer_3,
           buffer_4,

           length,
           flag_flow,
           string_to_update,
           zero_position
       );

//input and output signals //{
input               clk;
input               enable;         //1 to enable
input               en;     //0 to reset
input               rst_n;
input       [2:0]   in_number;      //0~5

input       [2:0]   shift_0;
input       [2:0]   shift_1;
input       [2:0]   shift_2;
input       [2:0]   shift_3;
input       [2:0]   shift_4;

input               overflow_0;
input               overflow_1;
input               overflow_2;
input               overflow_3;
input               overflow_4;

input       [6:0]   buffer_0;
input       [6:0]   buffer_1;
input       [6:0]   buffer_2;
input       [6:0]   buffer_3;
input       [6:0]   buffer_4;

output  reg [5:0]   length;
output  reg         flag_flow;
output  reg [34:0]  string_to_update;
output  reg [5:0]   zero_position;  //0:none    1-35:position
//}

//signals   //{
reg         flag_one_3;     //propagate of overflow
reg         flag_one_2;
reg         flag_one_1;
reg         flag_one_0;

wire        wire_overflow_4;
wire        wire_overflow_3;
wire        wire_overflow_2;
wire        wire_overflow_1;
wire        wire_overflow_0;

wire        wire_flag_flow;
wire[2:0]   length_0;
wire[3:0]   length_01;
wire[4:0]   length_012;
wire[4:0]   length_0123;
wire[5:0]   length_01234;
reg [5:0]   wire_length;


reg [6:0]   buffer_refine_0;
reg [6:0]   buffer_refine_1;
reg [6:0]   buffer_refine_2;
reg [6:0]   buffer_refine_3;
reg [6:0]   buffer_refine_4;

reg [34:0]  wire_string_to_update;
reg [5:0]   wire_zero_position;
//}

//logic //{
always @(*)     //flag_one_3
begin
    flag_one_3  =   1;
    case (shift_3)
        3'd0 :
        begin
            flag_one_3  =   1;
        end
        3'd1 :
        begin
            flag_one_3  =   buffer_3[6];
        end
        3'd2 :
        begin
            flag_one_3  =   &buffer_3[6:5];
        end
        3'd3 :
        begin
            flag_one_3  =   &buffer_3[6:4];
        end
        3'd4 :
        begin
            flag_one_3  =   &buffer_3[6:3];
        end
        3'd5 :
        begin
            flag_one_3  =   &buffer_3[6:2];
        end
        3'd6 :
        begin
            flag_one_3  =   &buffer_3[6:1];
        end
        3'd7 :
        begin
            flag_one_3  =   &buffer_3[6:0];
        end
    endcase
end

always @(*)     //flag_one_2
begin
    flag_one_2  =   1;
    case (shift_2)
        3'd0 :
        begin
            flag_one_2  =   1;
        end
        3'd1 :
        begin
            flag_one_2  =   buffer_2[6];
        end
        3'd2 :
        begin
            flag_one_2  =   &buffer_2[6:5];
        end
        3'd3 :
        begin
            flag_one_2  =   &buffer_2[6:4];
        end
        3'd4 :
        begin
            flag_one_2  =   &buffer_2[6:3];
        end
        3'd5 :
        begin
            flag_one_2  =   &buffer_2[6:2];
        end
        3'd6 :
        begin
            flag_one_2  =   &buffer_2[6:1];
        end
        3'd7 :
        begin
            flag_one_2  =   &buffer_2[6:0];
        end
    endcase
end

always @(*)     //flag_one_1
begin
    flag_one_1  =   1;
    case (shift_1)
        3'd0 :
        begin
            flag_one_1  =   1;
        end
        3'd1 :
        begin
            flag_one_1  =   buffer_1[6];
        end
        3'd2 :
        begin
            flag_one_1  =   &buffer_1[6:5];
        end
        3'd3 :
        begin
            flag_one_1  =   &buffer_1[6:4];
        end
        3'd4 :
        begin
            flag_one_1  =   &buffer_1[6:3];
        end
        3'd5 :
        begin
            flag_one_1  =   &buffer_1[6:2];
        end
        3'd6 :
        begin
            flag_one_1  =   &buffer_1[6:1];
        end
        3'd7 :
        begin
            flag_one_1  =   &buffer_1[6:0];
        end
    endcase
end

always @(*)     //flag_one_0
begin
    flag_one_0  =   1;
    case (shift_0)
        3'd0 :
        begin
            flag_one_0  =   1;
        end
        3'd1 :
        begin
            flag_one_0  =   buffer_0[6];
        end
        3'd2 :
        begin
            flag_one_0  =   &buffer_0[6:5];
        end
        3'd3 :
        begin
            flag_one_0  =   &buffer_0[6:4];
        end
        3'd4 :
        begin
            flag_one_0  =   &buffer_0[6:3];
        end
        3'd5 :
        begin
            flag_one_0  =   &buffer_0[6:2];
        end
        3'd6 :
        begin
            flag_one_0  =   &buffer_0[6:1];
        end
        3'd7 :
        begin
            flag_one_0  =   &buffer_0[6:0];
        end
    endcase
end

assign  wire_overflow_4 =   in_number>=5 ? overflow_4 : 0;
assign  wire_overflow_3 =   in_number>=4 ? (in_number>=5 ? (flag_one_3&&overflow_4)||overflow_3 : overflow_3) : 0;
assign  wire_overflow_2 =   in_number>=3 ? (in_number>=4 ? (flag_one_2&&wire_overflow_3)||overflow_2 : overflow_2) : 0;
assign  wire_overflow_1 =   in_number>=2 ? (in_number>=3 ? (flag_one_1&&wire_overflow_2)||overflow_1 : overflow_1) : 0;
assign  wire_overflow_0 =   in_number>=1 ? (in_number>=2 ? (flag_one_0&&wire_overflow_1)||overflow_0 : overflow_0) : 0;
assign  wire_flag_flow  =   in_number>=1 ? wire_overflow_0 : 0;

assign  length_0        =   shift_0;
assign  length_01       =   shift_0+shift_1;
assign  length_012      =   shift_0+shift_1+shift_2;
assign  length_0123     =   shift_0+shift_1+shift_2+shift_3;
assign  length_01234    =   shift_0+shift_1+shift_2+shift_3+shift_4;

always @(*)     //wire_length
begin
    wire_length =   0;
    case(in_number)
        3'd0 :
        begin
            wire_length =   0;
        end
        3'd1 :
        begin
            wire_length =   length_0;
        end
        3'd2 :
        begin
            wire_length =   length_01;
        end
        3'd3 :
        begin
            wire_length =   length_012;
        end
        3'd4 :
        begin
            wire_length =   length_0123;
        end
        3'd5 :
        begin
            wire_length =   length_01234;
        end
        default:
        begin
            wire_length =   0;
        end
    endcase
end

always @(*)     //buffer_refine_0
begin
    buffer_refine_0 =   buffer_0;
    case (shift_0)
        3'd0 :
        begin
            buffer_refine_0[6:0]    =   7'b1111111;
        end
        3'd1 :
        begin
            buffer_refine_0[5:0]    =   6'b111111;
        end
        3'd2 :
        begin
            buffer_refine_0[4:0]    =   5'b11111;
        end
        3'd3 :
        begin
            buffer_refine_0[3:0]    =   4'b1111;
        end
        3'd4 :
        begin
            buffer_refine_0[2:0]    =   3'b111;
        end
        3'd5 :
        begin
            buffer_refine_0[1:0]    =   2'b11;
        end
        3'd6 :
        begin
            buffer_refine_0[0]      =   1'b1;
        end
        default:
        begin
            buffer_refine_0 =   buffer_0;
        end
    endcase
    if(wire_overflow_1)
    begin
        case (shift_0)
            3'd1 :
            begin
                buffer_refine_0[6]      =   buffer_0[6] + 1;
            end
            3'd2 :
            begin
                buffer_refine_0[6:5]    =   buffer_0[6:5] + 1;
            end
            3'd3 :
            begin
                buffer_refine_0[6:4]    =   buffer_0[6:4] + 1;
            end
            3'd4 :
            begin
                buffer_refine_0[6:3]    =   buffer_0[6:3] + 1;
            end
            3'd5 :
            begin
                buffer_refine_0[6:2]    =   buffer_0[6:2] + 1;
            end
            3'd6 :
            begin
                buffer_refine_0[6:1]    =   buffer_0[6:1] + 1;
            end
            3'd7 :
            begin
                buffer_refine_0[6:0]    =   buffer_0[6:0] + 1;
            end
            default:
            begin
                buffer_refine_0 =   buffer_0;
            end
        endcase
    end
end

always @(*)     //buffer_refine_1
begin
    buffer_refine_1 =   buffer_1;
    case (shift_1)
        3'd0 :
        begin
            buffer_refine_1[6:0]    =   7'b1111111;
        end
        3'd1 :
        begin
            buffer_refine_1[5:0]    =   6'b111111;
        end
        3'd2 :
        begin
            buffer_refine_1[4:0]    =   5'b11111;
        end
        3'd3 :
        begin
            buffer_refine_1[3:0]    =   4'b1111;
        end
        3'd4 :
        begin
            buffer_refine_1[2:0]    =   3'b111;
        end
        3'd5 :
        begin
            buffer_refine_1[1:0]    =   2'b11;
        end
        3'd6 :
        begin
            buffer_refine_1[0]      =   1'b1;
        end
        default:
        begin
            buffer_refine_1 =   buffer_1;
        end
    endcase
    if(wire_overflow_2)
    begin
        case (shift_1)
            3'd1 :
            begin
                buffer_refine_1[6]      =   buffer_1[6] + 1;
            end
            3'd2 :
            begin
                buffer_refine_1[6:5]    =   buffer_1[6:5] + 1;
            end
            3'd3 :
            begin
                buffer_refine_1[6:4]    =   buffer_1[6:4] + 1;
            end
            3'd4 :
            begin
                buffer_refine_1[6:3]    =   buffer_1[6:3] + 1;
            end
            3'd5 :
            begin
                buffer_refine_1[6:2]    =   buffer_1[6:2] + 1;
            end
            3'd6 :
            begin
                buffer_refine_1[6:1]    =   buffer_1[6:1] + 1;
            end
            3'd7 :
            begin
                buffer_refine_1[6:0]    =   buffer_1[6:0] + 1;
            end
            default:
            begin
                buffer_refine_1 =   buffer_1;
            end
        endcase
    end
end

always @(*)     //buffer_refine_2
begin
    buffer_refine_2 =   buffer_2;
    case (shift_2)
        3'd0 :
        begin
            buffer_refine_2[6:0]    =   7'b1111111;
        end
        3'd1 :
        begin
            buffer_refine_2[5:0]    =   6'b111111;
        end
        3'd2 :
        begin
            buffer_refine_2[4:0]    =   5'b11111;
        end
        3'd3 :
        begin
            buffer_refine_2[3:0]    =   4'b1111;
        end
        3'd4 :
        begin
            buffer_refine_2[2:0]    =   3'b111;
        end
        3'd5 :
        begin
            buffer_refine_2[1:0]    =   2'b11;
        end
        3'd6 :
        begin
            buffer_refine_2[0]      =   1'b1;
        end
        default:
        begin
            buffer_refine_2 =   buffer_2;
        end
    endcase
    if(wire_overflow_3)
    begin
        case (shift_2)
            3'd1 :
            begin
                buffer_refine_2[6]      =   buffer_2[6] + 1;
            end
            3'd2 :
            begin
                buffer_refine_2[6:5]    =   buffer_2[6:5] + 1;
            end
            3'd3 :
            begin
                buffer_refine_2[6:4]    =   buffer_2[6:4] + 1;
            end
            3'd4 :
            begin
                buffer_refine_2[6:3]    =   buffer_2[6:3] + 1;
            end
            3'd5 :
            begin
                buffer_refine_2[6:2]    =   buffer_2[6:2] + 1;
            end
            3'd6 :
            begin
                buffer_refine_2[6:1]    =   buffer_2[6:1] + 1;
            end
            3'd7 :
            begin
                buffer_refine_2[6:0]    =   buffer_2[6:0] + 1;
            end
            default:
            begin
                buffer_refine_2 =   buffer_2;
            end
        endcase
    end
end

always @(*)     //buffer_refine_3
begin
    buffer_refine_3 =   buffer_3;
    case (shift_3)
        3'd0 :
        begin
            buffer_refine_3[6:0]    =   7'b1111111;
        end
        3'd1 :
        begin
            buffer_refine_3[5:0]    =   6'b111111;
        end
        3'd2 :
        begin
            buffer_refine_3[4:0]    =   5'b11111;
        end
        3'd3 :
        begin
            buffer_refine_3[3:0]    =   4'b1111;
        end
        3'd4 :
        begin
            buffer_refine_3[2:0]    =   3'b111;
        end
        3'd5 :
        begin
            buffer_refine_3[1:0]    =   2'b11;
        end
        3'd6 :
        begin
            buffer_refine_3[0]      =   1'b1;
        end
        default:
        begin
            buffer_refine_3 =   buffer_3;
        end
    endcase
    if(wire_overflow_4)
    begin
        case (shift_3)
            3'd1 :
            begin
                buffer_refine_3[6]      =   buffer_3[6] + 1;
            end
            3'd2 :
            begin
                buffer_refine_3[6:5]    =   buffer_3[6:5] + 1;
            end
            3'd3 :
            begin
                buffer_refine_3[6:4]    =   buffer_3[6:4] + 1;
            end
            3'd4 :
            begin
                buffer_refine_3[6:3]    =   buffer_3[6:3] + 1;
            end
            3'd5 :
            begin
                buffer_refine_3[6:2]    =   buffer_3[6:2] + 1;
            end
            3'd6 :
            begin
                buffer_refine_3[6:1]    =   buffer_3[6:1] + 1;
            end
            3'd7 :
            begin
                buffer_refine_3[6:0]    =   buffer_3[6:0] + 1;
            end
            default:
            begin
                buffer_refine_3 =   buffer_3;
            end
        endcase
    end
end

always @(*)     //buffer_refine_4
begin
    buffer_refine_4 =   buffer_4;
    case (shift_4)
        3'd0 :
        begin
            buffer_refine_4[6:0]    =   7'b1111111;
        end
        3'd1 :
        begin
            buffer_refine_4[5:0]    =   6'b111111;
        end
        3'd2 :
        begin
            buffer_refine_4[4:0]    =   5'b11111;
        end
        3'd3 :
        begin
            buffer_refine_4[3:0]    =   4'b1111;
        end
        3'd4 :
        begin
            buffer_refine_4[2:0]    =   3'b111;
        end
        3'd5 :
        begin
            buffer_refine_4[1:0]    =   2'b11;
        end
        3'd6 :
        begin
            buffer_refine_4[0]      =   1'b1;
        end
        default:
        begin
            buffer_refine_4 =   buffer_4;
        end
    endcase
end

always @(*)     //wire_string_to_update
begin
    wire_string_to_update           =   35'b11111111111111111111111111111111111;
    if(in_number>=1)
        wire_string_to_update[34:28]    =   buffer_refine_0;
    if(in_number>=2)
    begin
        case(length_0)
            3'd0 :
            begin
                wire_string_to_update[34:28]    =   buffer_refine_1;
            end
            3'd1 :
            begin
                wire_string_to_update[33:27]    =   buffer_refine_1;
            end
            3'd2 :
            begin
                wire_string_to_update[32:26]    =   buffer_refine_1;
            end
            3'd3 :
            begin
                wire_string_to_update[31:25]    =   buffer_refine_1;
            end
            3'd4 :
            begin
                wire_string_to_update[30:24]    =   buffer_refine_1;
            end
            3'd5 :
            begin
                wire_string_to_update[29:23]    =   buffer_refine_1;
            end
            3'd6 :
            begin
                wire_string_to_update[28:22]    =   buffer_refine_1;
            end
            3'd7 :
            begin
                wire_string_to_update[27:21]    =   buffer_refine_1;
            end
            default:
            begin
                wire_string_to_update           =   35'b11111111111111111111111111111111111;
            end
        endcase
    end
    if(in_number>=3)
    begin
        case(length_01)
            4'd0 :
            begin
                wire_string_to_update[34:28]    =   buffer_refine_2;
            end
            4'd1 :
            begin
                wire_string_to_update[33:27]    =   buffer_refine_2;
            end
            4'd2 :
            begin
                wire_string_to_update[32:26]    =   buffer_refine_2;
            end
            4'd3 :
            begin
                wire_string_to_update[31:25]    =   buffer_refine_2;
            end
            4'd4 :
            begin
                wire_string_to_update[30:24]    =   buffer_refine_2;
            end
            4'd5 :
            begin
                wire_string_to_update[29:23]    =   buffer_refine_2;
            end
            4'd6 :
            begin
                wire_string_to_update[28:22]    =   buffer_refine_2;
            end
            4'd7 :
            begin
                wire_string_to_update[27:21]    =   buffer_refine_2;
            end
            4'd8 :
            begin
                wire_string_to_update[26:20]    =   buffer_refine_2;
            end
            4'd9 :
            begin
                wire_string_to_update[25:19]    =   buffer_refine_2;
            end
            4'd10 :
            begin
                wire_string_to_update[24:18]    =   buffer_refine_2;
            end
            4'd11 :
            begin
                wire_string_to_update[23:17]    =   buffer_refine_2;
            end
            4'd12 :
            begin
                wire_string_to_update[22:16]    =   buffer_refine_2;
            end
            4'd13 :
            begin
                wire_string_to_update[21:15]    =   buffer_refine_2;
            end
            4'd14 :
            begin
                wire_string_to_update[20:14]    =   buffer_refine_2;
            end
            default:
            begin
                wire_string_to_update           =   35'b11111111111111111111111111111111111;
            end
        endcase
    end
    if(in_number>=4)
    begin
        case(length_012)
            5'd0 :
            begin
                wire_string_to_update[34:28]    =   buffer_refine_3;
            end
            5'd1 :
            begin
                wire_string_to_update[33:27]    =   buffer_refine_3;
            end
            5'd2 :
            begin
                wire_string_to_update[32:26]    =   buffer_refine_3;
            end
            5'd3 :
            begin
                wire_string_to_update[31:25]    =   buffer_refine_3;
            end
            5'd4 :
            begin
                wire_string_to_update[30:24]    =   buffer_refine_3;
            end
            5'd5 :
            begin
                wire_string_to_update[29:23]    =   buffer_refine_3;
            end
            5'd6 :
            begin
                wire_string_to_update[28:22]    =   buffer_refine_3;
            end
            5'd7 :
            begin
                wire_string_to_update[27:21]    =   buffer_refine_3;
            end
            5'd8 :
            begin
                wire_string_to_update[26:20]    =   buffer_refine_3;
            end
            5'd9 :
            begin
                wire_string_to_update[25:19]    =   buffer_refine_3;
            end
            5'd10 :
            begin
                wire_string_to_update[24:18]    =   buffer_refine_3;
            end
            5'd11 :
            begin
                wire_string_to_update[23:17]    =   buffer_refine_3;
            end
            5'd12 :
            begin
                wire_string_to_update[22:16]    =   buffer_refine_3;
            end
            5'd13 :
            begin
                wire_string_to_update[21:15]    =   buffer_refine_3;
            end
            5'd14 :
            begin
                wire_string_to_update[20:14]    =   buffer_refine_3;
            end
            5'd15 :
            begin
                wire_string_to_update[19:13]    =   buffer_refine_3;
            end
            5'd16 :
            begin
                wire_string_to_update[18:12]    =   buffer_refine_3;
            end
            5'd17 :
            begin
                wire_string_to_update[17:11]    =   buffer_refine_3;
            end
            5'd18 :
            begin
                wire_string_to_update[16:10]    =   buffer_refine_3;
            end
            5'd19 :
            begin
                wire_string_to_update[15:9]     =   buffer_refine_3;
            end
            5'd20 :
            begin
                wire_string_to_update[14:8]     =   buffer_refine_3;
            end
            5'd21 :
            begin
                wire_string_to_update[13:7]     =   buffer_refine_3;
            end
            default:
            begin
                wire_string_to_update           =   35'b11111111111111111111111111111111111;
            end
        endcase
    end
    if(in_number>=5)
    begin
        case(length_0123)
            5'd0 :
            begin
                wire_string_to_update[34:28]    =   buffer_refine_4;
            end
            5'd1 :
            begin
                wire_string_to_update[33:27]    =   buffer_refine_4;
            end
            5'd2 :
            begin
                wire_string_to_update[32:26]    =   buffer_refine_4;
            end
            5'd3 :
            begin
                wire_string_to_update[31:25]    =   buffer_refine_4;
            end
            5'd4 :
            begin
                wire_string_to_update[30:24]    =   buffer_refine_4;
            end
            5'd5 :
            begin
                wire_string_to_update[29:23]    =   buffer_refine_4;
            end
            5'd6 :
            begin
                wire_string_to_update[28:22]    =   buffer_refine_4;
            end
            5'd7 :
            begin
                wire_string_to_update[27:21]    =   buffer_refine_4;
            end
            5'd8 :
            begin
                wire_string_to_update[26:20]    =   buffer_refine_4;
            end
            5'd9 :
            begin
                wire_string_to_update[25:19]    =   buffer_refine_4;
            end
            5'd10 :
            begin
                wire_string_to_update[24:18]    =   buffer_refine_4;
            end
            5'd11 :
            begin
                wire_string_to_update[23:17]    =   buffer_refine_4;
            end
            5'd12 :
            begin
                wire_string_to_update[22:16]    =   buffer_refine_4;
            end
            5'd13 :
            begin
                wire_string_to_update[21:15]    =   buffer_refine_4;
            end
            5'd14 :
            begin
                wire_string_to_update[20:14]    =   buffer_refine_4;
            end
            5'd15 :
            begin
                wire_string_to_update[19:13]    =   buffer_refine_4;
            end
            5'd16 :
            begin
                wire_string_to_update[18:12]    =   buffer_refine_4;
            end
            5'd17 :
            begin
                wire_string_to_update[17:11]    =   buffer_refine_4;
            end
            5'd18 :
            begin
                wire_string_to_update[16:10]    =   buffer_refine_4;
            end
            5'd19 :
            begin
                wire_string_to_update[15:9]     =   buffer_refine_4;
            end
            5'd20 :
            begin
                wire_string_to_update[14:8]     =   buffer_refine_4;
            end
            5'd21 :
            begin
                wire_string_to_update[13:7]     =   buffer_refine_4;
            end
            5'd22 :
            begin
                wire_string_to_update[12:6]     =   buffer_refine_4;
            end
            5'd23 :
            begin
                wire_string_to_update[11:5]     =   buffer_refine_4;
            end
            5'd24 :
            begin
                wire_string_to_update[10:4]     =   buffer_refine_4;
            end
            5'd25 :
            begin
                wire_string_to_update[9:3]      =   buffer_refine_4;
            end
            5'd26 :
            begin
                wire_string_to_update[8:2]      =   buffer_refine_4;
            end
            5'd27 :
            begin
                wire_string_to_update[7:1]      =   buffer_refine_4;
            end
            5'd28 :
            begin
                wire_string_to_update[6:0]      =   buffer_refine_4;
            end
            default:
            begin
                wire_string_to_update           =   35'b11111111111111111111111111111111111;
            end
        endcase
    end
end

always @(*)         //wire_zero_position
begin
    wire_zero_position = 0;
    casex(wire_string_to_update)
        35'b01111111111111111111111111111111111 :
        begin
            wire_zero_position = 6'd1;
        end
        35'bx0111111111111111111111111111111111 :
        begin
            wire_zero_position = 6'd2;
        end
        35'bxx011111111111111111111111111111111 :
        begin
            wire_zero_position = 6'd3;
        end
        35'bxxx01111111111111111111111111111111 :
        begin
            wire_zero_position = 6'd4;
        end
        35'bxxxx0111111111111111111111111111111 :
        begin
            wire_zero_position = 6'd5;
        end
        35'bxxxxx011111111111111111111111111111 :
        begin
            wire_zero_position = 6'd6;
        end
        35'bxxxxxx01111111111111111111111111111 :
        begin
            wire_zero_position = 6'd7;
        end
        35'bxxxxxxx0111111111111111111111111111 :
        begin
            wire_zero_position = 6'd8;
        end
        35'bxxxxxxxx011111111111111111111111111 :
        begin
            wire_zero_position = 6'd9;
        end
        35'bxxxxxxxxx01111111111111111111111111 :
        begin
            wire_zero_position = 6'd10;
        end
        35'bxxxxxxxxxx0111111111111111111111111 :
        begin
            wire_zero_position = 6'd11;
        end
        35'bxxxxxxxxxxx011111111111111111111111 :
        begin
            wire_zero_position = 6'd12;
        end
        35'bxxxxxxxxxxxx01111111111111111111111 :
        begin
            wire_zero_position = 6'd13;
        end
        35'bxxxxxxxxxxxxx0111111111111111111111 :
        begin
            wire_zero_position = 6'd14;
        end
        35'bxxxxxxxxxxxxxx011111111111111111111 :
        begin
            wire_zero_position = 6'd15;
        end
        35'bxxxxxxxxxxxxxxx01111111111111111111 :
        begin
            wire_zero_position = 6'd16;
        end
        35'bxxxxxxxxxxxxxxxx0111111111111111111 :
        begin
            wire_zero_position = 6'd17;
        end
        35'bxxxxxxxxxxxxxxxxx011111111111111111 :
        begin
            wire_zero_position = 6'd18;
        end
        35'bxxxxxxxxxxxxxxxxxx01111111111111111 :
        begin
            wire_zero_position = 6'd19;
        end
        35'bxxxxxxxxxxxxxxxxxxx0111111111111111 :
        begin
            wire_zero_position = 6'd20;
        end
        35'bxxxxxxxxxxxxxxxxxxxx011111111111111 :
        begin
            wire_zero_position = 6'd21;
        end
        35'bxxxxxxxxxxxxxxxxxxxxx01111111111111 :
        begin
            wire_zero_position = 6'd22;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxx0111111111111 :
        begin
            wire_zero_position = 6'd23;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxxx011111111111 :
        begin
            wire_zero_position = 6'd24;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxxxx01111111111 :
        begin
            wire_zero_position = 6'd25;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxxxxx0111111111 :
        begin
            wire_zero_position = 6'd26;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxxxxxx011111111 :
        begin
            wire_zero_position = 6'd27;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxxxxxxx01111111 :
        begin
            wire_zero_position = 6'd28;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxxxxxxxx0111111 :
        begin
            wire_zero_position = 6'd29;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxx011111 :
        begin
            wire_zero_position = 6'd30;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx01111 :
        begin
            wire_zero_position = 6'd31;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0111 :
        begin
            wire_zero_position = 6'd32;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx011 :
        begin
            wire_zero_position = 6'd33;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx01 :
        begin
            wire_zero_position = 6'd34;
        end
        35'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0 :
        begin
            wire_zero_position = 6'd35;
        end
        default:
        begin
            wire_zero_position = 0;
        end
    endcase
end

always @(posedge clk or negedge rst_n)      //output
begin
    if(!rst_n)
    begin
        length              <=  0;
        flag_flow           <=  0;
        string_to_update    <=  0;
        zero_position       <=  0;

    end
    else if(!en)
    begin
        length              <=  0;
        flag_flow           <=  0;
        string_to_update    <=  0;
        zero_position       <=  0;
    end
    else if(enable)
    begin
        length              <=  wire_length;
        flag_flow           <=  wire_flag_flow;
        string_to_update    <=  wire_string_to_update;
        zero_position       <=  wire_zero_position;
    end
    else
    begin
        length              <=  length;
        flag_flow           <=  flag_flow;
        string_to_update    <=  string_to_update;
        zero_position       <=  zero_position;
    end
end
//}

endmodule
