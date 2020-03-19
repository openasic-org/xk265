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
// Filename       : cabac_binmix.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : mix bypass and regular bins
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------

module cabac_binmix(
           clk,
           w_enable,
           r_enable,
           en,
           rst_n,

           free_space,

           in_number_all,
           out_number,

           index_bypass,
           symbol_bypass,


           in_lpsmps_0,
           in_range_0,
           in_rlps_0,
           in_shift_0,
           in_lpsmps_1,
           in_range_1,
           in_rlps_1,
           in_shift_1,
           in_lpsmps_2,
           in_range_2,
           in_rlps_2,
           in_shift_2,
           in_lpsmps_3,
           in_range_3,
           in_rlps_3,
           in_shift_3,
           in_range_4,

           out_bypass_0,
           out_bypass_1,
           out_bypass_2,
           out_bypass_3,
           out_bypass_4,

           out_lpsmps_0,
           out_lpsmps_1,
           out_lpsmps_2,
           out_lpsmps_3,
           out_lpsmps_4,

           out_shift_0,
           out_shift_1,
           out_shift_2,
           out_shift_3,
           out_shift_4,

           out_r_rmps_0,
           out_r_rmps_1,
           out_r_rmps_2,
           out_r_rmps_3,
           out_r_rmps_4
       );

//input and output signals //{
input               clk;
input               w_enable;       //1 to enable
input               r_enable;       //1 to enable
input               en;     //0 to reset
input               rst_n;

output  reg [4:0]   free_space;
input       [3:0]   in_number_all;
output  wire[2:0]   out_number;

input       [7:0]   index_bypass;
input       [7:0]   symbol_bypass;


input               in_lpsmps_0;
input       [7:0]   in_range_0;
input       [7:0]   in_rlps_0;
input       [2:0]   in_shift_0;
input               in_lpsmps_1;
input       [7:0]   in_range_1;
input       [7:0]   in_rlps_1;
input       [2:0]   in_shift_1;
input               in_lpsmps_2;
input       [7:0]   in_range_2;
input       [7:0]   in_rlps_2;
input       [2:0]   in_shift_2;
input               in_lpsmps_3;
input       [7:0]   in_range_3;
input       [7:0]   in_rlps_3;
input       [2:0]   in_shift_3;
input       [7:0]   in_range_4;

output  wire        out_bypass_0;
output  wire        out_bypass_1;
output  wire        out_bypass_2;
output  wire        out_bypass_3;
output  wire        out_bypass_4;

output  wire        out_lpsmps_0;
output  wire        out_lpsmps_1;
output  wire        out_lpsmps_2;
output  wire        out_lpsmps_3;
output  wire        out_lpsmps_4;

output  wire[2:0]   out_shift_0;
output  wire[2:0]   out_shift_1;
output  wire[2:0]   out_shift_2;
output  wire[2:0]   out_shift_3;
output  wire[2:0]   out_shift_4;

output  wire[8:0]   out_r_rmps_0;
output  wire[8:0]   out_r_rmps_1;
output  wire[8:0]   out_r_rmps_2;
output  wire[8:0]   out_r_rmps_3;
output  wire[8:0]   out_r_rmps_4;
//}

//signals //{
reg     [13:0]  bypass_lpsmps_shift_r_rmps[0:31];   //[13]=bypss, [12]=lpsmps, [11:9]=shift, [8:0]=r_rmps
reg     [13:0]  wire_bypass_lpsmps_shift_r_rmps[0:31];
reg     [4:0]   used_space;
wire    [4:0]   wire_used_space;

wire    [4:0]   used_space_new;

wire    [8:0]   rmps_0;
wire    [8:0]   rmps_1;
wire    [8:0]   rmps_2;
wire    [8:0]   rmps_3;

reg     [13:0]  bypass_lpsmps_shift_r_rmps_0;
reg     [13:0]  bypass_lpsmps_shift_r_rmps_1;
reg     [13:0]  bypass_lpsmps_shift_r_rmps_2;
reg     [13:0]  bypass_lpsmps_shift_r_rmps_3;
reg     [13:0]  bypass_lpsmps_shift_r_rmps_4;
reg     [13:0]  bypass_lpsmps_shift_r_rmps_5;
reg     [13:0]  bypass_lpsmps_shift_r_rmps_6;
reg     [13:0]  bypass_lpsmps_shift_r_rmps_7;
//}

//logic //{
assign rmps_0       =   {1'b1, in_range_0} - {1'b0, in_rlps_0};
assign rmps_1       =   {1'b1, in_range_1} - {1'b0, in_rlps_1};
assign rmps_2       =   {1'b1, in_range_2} - {1'b0, in_rlps_2};
assign rmps_3       =   {1'b1, in_range_3} - {1'b0, in_rlps_3};

always @(*) //bypass_lpsmps_shift_r_rmps_0
begin
    bypass_lpsmps_shift_r_rmps_0[13]    =   index_bypass[7];
    bypass_lpsmps_shift_r_rmps_0[12:0]  =   {in_lpsmps_0, in_shift_0, rmps_0};
    if(index_bypass[7])
    begin
        bypass_lpsmps_shift_r_rmps_0[12:0]  =   {symbol_bypass[7], 3'd1, {1'b1, in_range_0}};
    end
end

always @(*) //bypass_lpsmps_shift_r_rmps_1
begin
    bypass_lpsmps_shift_r_rmps_1[13]    =   index_bypass[6];
    bypass_lpsmps_shift_r_rmps_1[12:0]  =   {in_lpsmps_1, in_shift_1, rmps_1};

    casex(index_bypass[7:6])
        2'b10 :
        begin
            bypass_lpsmps_shift_r_rmps_1[12:0]  =   {in_lpsmps_0, in_shift_0, rmps_0};
        end
        2'b01 :
        begin
            bypass_lpsmps_shift_r_rmps_1[12:0]  =   {symbol_bypass[6], 3'd1, {1'b1, in_range_1}};
        end
        2'b11 :
        begin
            bypass_lpsmps_shift_r_rmps_1[12:0]  =   {symbol_bypass[6], 3'd1, {1'b1, in_range_0}};
        end
        default:
            bypass_lpsmps_shift_r_rmps_1[12:0]  =   {in_lpsmps_1, in_shift_1, rmps_1};
    endcase
end

always @(*) //bypass_lpsmps_shift_r_rmps_2
begin
    bypass_lpsmps_shift_r_rmps_2[13]    =   index_bypass[5];
    bypass_lpsmps_shift_r_rmps_2[12:0]  =   {in_lpsmps_2, in_shift_2, rmps_2};

    casex(index_bypass[7:5])
        3'b010, 3'b100 :
        begin
            bypass_lpsmps_shift_r_rmps_2[12:0]  =   {in_lpsmps_1, in_shift_1, rmps_1};
        end
        3'b110 :
        begin
            bypass_lpsmps_shift_r_rmps_2[12:0]  =   {in_lpsmps_0, in_shift_0, rmps_0};
        end
        3'b001 :
        begin
            bypass_lpsmps_shift_r_rmps_2[12:0]  =   {symbol_bypass[5], 3'd1, {1'b1, in_range_2}};
        end
        3'b011, 3'b101 :
        begin
            bypass_lpsmps_shift_r_rmps_2[12:0]  =   {symbol_bypass[5], 3'd1, {1'b1, in_range_1}};
        end
        3'b111 :
        begin
            bypass_lpsmps_shift_r_rmps_2[12:0]  =   {symbol_bypass[5], 3'd1, {1'b1, in_range_0}};
        end
        default:
            bypass_lpsmps_shift_r_rmps_2[12:0]  =   {in_lpsmps_2, in_shift_2, rmps_2};
    endcase
end

always @(*) //bypass_lpsmps_shift_r_rmps_3
begin
    bypass_lpsmps_shift_r_rmps_3[13]    =   index_bypass[4];
    bypass_lpsmps_shift_r_rmps_3[12:0]  =   {in_lpsmps_3, in_shift_3, rmps_3};

    casex(index_bypass[7:4])
        4'b0010, 4'b0100, 4'b1000 :
        begin
            bypass_lpsmps_shift_r_rmps_3[12:0]  =   {in_lpsmps_2, in_shift_2, rmps_2};
        end
        4'b0110, 4'b1010, 4'b1100 :
        begin
            bypass_lpsmps_shift_r_rmps_3[12:0]  =   {in_lpsmps_1, in_shift_1, rmps_1};
        end
        4'b1110 :
        begin
            bypass_lpsmps_shift_r_rmps_3[12:0]  =   {in_lpsmps_0, in_shift_0, rmps_0};
        end
        4'b0001 :
        begin
            bypass_lpsmps_shift_r_rmps_3[12:0]  =   {symbol_bypass[4], 3'd1, {1'b1, in_range_3}};
        end
        4'b0011, 4'b0101, 4'b1001 :
        begin
            bypass_lpsmps_shift_r_rmps_3[12:0]  =   {symbol_bypass[4], 3'd1, {1'b1, in_range_2}};
        end
        4'b0111, 4'b1011, 4'b1101 :
        begin
            bypass_lpsmps_shift_r_rmps_3[12:0]  =   {symbol_bypass[4], 3'd1, {1'b1, in_range_1}};
        end
        4'b1111 :
        begin
            bypass_lpsmps_shift_r_rmps_3[12:0]  =   {symbol_bypass[4], 3'd1, {1'b1, in_range_0}};
        end
        default:
            bypass_lpsmps_shift_r_rmps_3[12:0]  =   {in_lpsmps_3, in_shift_3, rmps_3};
    endcase
end

always @(*) //bypass_lpsmps_shift_r_rmps_4
begin
    bypass_lpsmps_shift_r_rmps_4[13]    =   index_bypass[3];
    bypass_lpsmps_shift_r_rmps_4[12:0]  =   {in_lpsmps_3, in_shift_3, rmps_3};

    casex(index_bypass[7:3])
        5'b00110, 5'b01010, 5'b10010, 5'b01100, 5'b10100, 5'b11000 :
        begin
            bypass_lpsmps_shift_r_rmps_4[12:0]  =   {in_lpsmps_2, in_shift_2, rmps_2};
        end
        5'b01110, 5'b10110, 5'b11010, 5'b11100 :
        begin
            bypass_lpsmps_shift_r_rmps_4[12:0]  =   {in_lpsmps_1, in_shift_1, rmps_1};
        end
        5'b11110 :
        begin
            bypass_lpsmps_shift_r_rmps_4[12:0]  =   {in_lpsmps_0, in_shift_0, rmps_0};
        end
        5'b00001 :
        begin
            bypass_lpsmps_shift_r_rmps_4[12:0]  =   {symbol_bypass[3], 3'd1, {1'b1, in_range_4}};
        end
        5'b00011, 5'b00101, 5'b01001, 5'b10001 :
        begin
            bypass_lpsmps_shift_r_rmps_4[12:0]  =   {symbol_bypass[3], 3'd1, {1'b1, in_range_3}};
        end
        5'b00111, 5'b01011, 5'b10011, 5'b01101, 5'b10101, 5'b11001 :
        begin
            bypass_lpsmps_shift_r_rmps_4[12:0]  =   {symbol_bypass[3], 3'd1, {1'b1, in_range_2}};
        end
        5'b01111, 5'b10111, 5'b11011, 5'b11101 :
        begin
            bypass_lpsmps_shift_r_rmps_4[12:0]  =   {symbol_bypass[3], 3'd1, {1'b1, in_range_1}};
        end
        5'b11111 :
        begin
            bypass_lpsmps_shift_r_rmps_4[12:0]  =   {symbol_bypass[3], 3'd1, {1'b1, in_range_0}};
        end
        default:
            bypass_lpsmps_shift_r_rmps_4[12:0]  =   {in_lpsmps_3, in_shift_3, rmps_3};
    endcase
end

always @(*) //bypass_lpsmps_shift_r_rmps_5
begin
    bypass_lpsmps_shift_r_rmps_5[13]    =   index_bypass[2];
    bypass_lpsmps_shift_r_rmps_5[12:0]  =   {in_lpsmps_3, in_shift_3, rmps_3};

    casex(index_bypass[7:2])
        6'b001110, 6'b010110, 6'b100110, 6'b011010, 6'b101010, 6'b110010, 6'b011100, 6'b101100, 6'b110100, 6'b111000 :
        begin
            bypass_lpsmps_shift_r_rmps_5[12:0]  =   {in_lpsmps_2, in_shift_2, rmps_2};
        end
        6'b011110, 6'b101110, 6'b110110, 6'b111010, 6'b111100 :
        begin
            bypass_lpsmps_shift_r_rmps_5[12:0]  =   {in_lpsmps_1, in_shift_1, rmps_1};
        end
        6'b111110 :
        begin
            bypass_lpsmps_shift_r_rmps_5[12:0]  =   {in_lpsmps_0, in_shift_0, rmps_0};
        end
        6'b000011, 6'b000101, 6'b001001, 6'b010001, 6'b100001 :
        begin
            bypass_lpsmps_shift_r_rmps_5[12:0]  =   {symbol_bypass[2], 3'd1, {1'b1, in_range_4}};
        end
        6'b110001, 6'b101001, 6'b011001, 6'b100101, 6'b010101, 6'b001101, 6'b100011, 6'b010011, 6'b001011, 6'b000111 :
        begin
            bypass_lpsmps_shift_r_rmps_5[12:0]  =   {symbol_bypass[2], 3'd1, {1'b1, in_range_3}};
        end
        6'b001111, 6'b010111, 6'b100111, 6'b011011, 6'b101011, 6'b110011, 6'b011101, 6'b101101, 6'b110101, 6'b111001 :
        begin
            bypass_lpsmps_shift_r_rmps_5[12:0]  =   {symbol_bypass[2], 3'd1, {1'b1, in_range_2}};
        end
        6'b011111, 6'b101111, 6'b110111, 6'b111011, 6'b111101 :
        begin
            bypass_lpsmps_shift_r_rmps_5[12:0]  =   {symbol_bypass[2], 3'd1, {1'b1, in_range_1}};
        end
        6'b111111 :
        begin
            bypass_lpsmps_shift_r_rmps_5[12:0]  =   {symbol_bypass[2], 3'd1, {1'b1, in_range_0}};
        end
        default:
            bypass_lpsmps_shift_r_rmps_5[12:0]  =   {in_lpsmps_3, in_shift_3, rmps_3};
    endcase
end

always @(*) //bypass_lpsmps_shift_r_rmps_6
begin
    bypass_lpsmps_shift_r_rmps_6[13]    =   index_bypass[1];
    bypass_lpsmps_shift_r_rmps_6[12:0]  =   {in_lpsmps_3, in_shift_3, rmps_3};

    casex(index_bypass[7:1])
        7'b0011110, 7'b0101110, 7'b1001110, 7'b0110110, 7'b1010110, 7'b1100110, 7'b0111010, 7'b1011010, 7'b1101010, 7'b1110010, 7'b0111100, 7'b1011100, 7'b1101100, 7'b1110100, 7'b1111000 :
        begin
            bypass_lpsmps_shift_r_rmps_6[12:0]  =   {in_lpsmps_2, in_shift_2, rmps_2};
        end
        7'b0111110, 7'b1011110, 7'b1101110, 7'b1110110, 7'b1111010, 7'b1111100 :
        begin
            bypass_lpsmps_shift_r_rmps_6[12:0]  =   {in_lpsmps_1, in_shift_1, rmps_1};
        end
        7'b1111110 :
        begin
            bypass_lpsmps_shift_r_rmps_6[12:0]  =   {in_lpsmps_0, in_shift_0, rmps_0};
        end
        7'b0000111, 7'b0001011, 7'b0010011, 7'b0100011, 7'b1000011, 7'b1100001, 7'b1010001, 7'b0110001, 7'b1001001, 7'b0101001, 7'b0011001, 7'b1000101, 7'b0100101, 7'b0010101, 7'b0001101 :
        begin
            bypass_lpsmps_shift_r_rmps_6[12:0]  =   {symbol_bypass[1], 3'd1, {1'b1, in_range_4}};
        end
        7'b1100011, 7'b1010011, 7'b0110011, 7'b1001011, 7'b0101011, 7'b0011011, 7'b1000111, 7'b0100111, 7'b0010111, 7'b0001111,7'b0011101, 7'b0101101, 7'b1001101, 7'b0110101, 7'b1010101, 7'b1100101, 7'b0111001, 7'b1011001, 7'b1101001, 7'b1110001 :
        begin
            bypass_lpsmps_shift_r_rmps_6[12:0]  =   {symbol_bypass[1], 3'd1, {1'b1, in_range_3}};
        end
        7'b0011111, 7'b0101111, 7'b1001111, 7'b0110111, 7'b1010111, 7'b1100111, 7'b0111011, 7'b1011011, 7'b1101011, 7'b1110011, 7'b0111101, 7'b1011101, 7'b1101101, 7'b1110101, 7'b1111001 :
        begin
            bypass_lpsmps_shift_r_rmps_6[12:0]  =   {symbol_bypass[1], 3'd1, {1'b1, in_range_2}};
        end
        7'b0111111, 7'b1011111, 7'b1101111, 7'b1110111, 7'b1111011, 7'b1111101 :
        begin
            bypass_lpsmps_shift_r_rmps_6[12:0]  =   {symbol_bypass[1], 3'd1, {1'b1, in_range_1}};
        end
        7'b1111111 :
        begin
            bypass_lpsmps_shift_r_rmps_6[12:0]  =   {symbol_bypass[1], 3'd1, {1'b1, in_range_0}};
        end
        default:
            bypass_lpsmps_shift_r_rmps_6[12:0]  =   {in_lpsmps_3, in_shift_3, rmps_3};
    endcase
end

always @(*) //bypass_lpsmps_shift_r_rmps_7
begin
    bypass_lpsmps_shift_r_rmps_7[13]    =   index_bypass[0];
    bypass_lpsmps_shift_r_rmps_7[12:0]  =   {in_lpsmps_3, in_shift_3, rmps_3};

    casex(index_bypass[7:0])
        8'b00111110, 8'b01011110, 8'b10011110, 8'b01101110, 8'b10101110, 8'b11001110, 8'b01110110, 8'b10110110, 8'b11010110, 8'b11100110, 8'b01111010, 8'b10111010, 8'b11011010, 8'b11101010, 8'b11110010, 8'b01111100, 8'b10111100, 8'b11011100, 8'b11101100, 8'b11110100, 8'b11111000 :
        begin
            bypass_lpsmps_shift_r_rmps_7[12:0]  =   {in_lpsmps_2, in_shift_2, rmps_2};
        end
        8'b01111110, 8'b10111110, 8'b11011110, 8'b11101110, 8'b11110110, 8'b11111010, 8'b11111100 :
        begin
            bypass_lpsmps_shift_r_rmps_7[12:0]  =   {in_lpsmps_1, in_shift_1, rmps_1};
        end
        8'b11111110 :
        begin
            bypass_lpsmps_shift_r_rmps_7[12:0]  =   {in_lpsmps_0, in_shift_0, rmps_0};
        end
        8'b00001111, 8'b00010111, 8'b00100111, 8'b01000111, 8'b10000111, 8'b11000011, 8'b10100011, 8'b01100011, 8'b10010011, 8'b01010011, 8'b00110011, 8'b10001011, 8'b01001011, 8'b00101011, 8'b00011011,8'b11000101, 8'b10100101, 8'b01100101, 8'b10010101, 8'b01010101, 8'b00110101, 8'b10001101, 8'b01001101, 8'b00101101, 8'b00011101,8'b00111001, 8'b01011001, 8'b10011001, 8'b01101001, 8'b10101001, 8'b11001001, 8'b01110001, 8'b10110001, 8'b11010001, 8'b11100001 :
        begin
            bypass_lpsmps_shift_r_rmps_7[12:0]  =   {symbol_bypass[0], 3'd1, {1'b1, in_range_4}};
        end
        8'b11110001, 8'b11101001, 8'b11011001, 8'b10111001, 8'b01111001, 8'b00111101, 8'b01011101, 8'b10011101, 8'b01101101, 8'b10101101, 8'b11001101, 8'b01110101, 8'b10110101, 8'b11010101, 8'b11100101,8'b00111011, 8'b01011011, 8'b10011011, 8'b01101011, 8'b10101011, 8'b11001011, 8'b01110011, 8'b10110011, 8'b11010011, 8'b11100011,8'b11000111, 8'b10100111, 8'b01100111, 8'b10010111, 8'b01010111, 8'b00110111, 8'b10001111, 8'b01001111, 8'b00101111, 8'b00011111 :
        begin
            bypass_lpsmps_shift_r_rmps_7[12:0]  =   {symbol_bypass[0], 3'd1, {1'b1, in_range_3}};
        end
        8'b00111111, 8'b01011111, 8'b10011111, 8'b01101111, 8'b10101111, 8'b11001111, 8'b01110111, 8'b10110111, 8'b11010111, 8'b11100111, 8'b01111011, 8'b10111011, 8'b11011011, 8'b11101011, 8'b11110011, 8'b01111101, 8'b10111101, 8'b11011101, 8'b11101101, 8'b11110101, 8'b11111001 :
        begin
            bypass_lpsmps_shift_r_rmps_7[12:0]  =   {symbol_bypass[0], 3'd1, {1'b1, in_range_2}};
        end
        8'b01111111, 8'b10111111, 8'b11011111, 8'b11101111, 8'b11110111, 8'b11111011, 8'b11111101 :
        begin
            bypass_lpsmps_shift_r_rmps_7[12:0]  =   {symbol_bypass[0], 3'd1, {1'b1, in_range_1}};
        end
        8'b11111111 :
        begin
            bypass_lpsmps_shift_r_rmps_7[12:0]  =   {symbol_bypass[0], 3'd1, {1'b1, in_range_0}};
        end
        default:
            bypass_lpsmps_shift_r_rmps_7[12:0]  =   {in_lpsmps_3, in_shift_3, rmps_3};
    endcase
end

always @(*) //wire_bypass_lpsmps_shift_r_rmps
begin
    wire_bypass_lpsmps_shift_r_rmps[0] = bypass_lpsmps_shift_r_rmps[0];
    wire_bypass_lpsmps_shift_r_rmps[1] = bypass_lpsmps_shift_r_rmps[1];
    wire_bypass_lpsmps_shift_r_rmps[2] = bypass_lpsmps_shift_r_rmps[2];
    wire_bypass_lpsmps_shift_r_rmps[3] = bypass_lpsmps_shift_r_rmps[3];
    wire_bypass_lpsmps_shift_r_rmps[4] = bypass_lpsmps_shift_r_rmps[4];
    wire_bypass_lpsmps_shift_r_rmps[5] = bypass_lpsmps_shift_r_rmps[5];
    wire_bypass_lpsmps_shift_r_rmps[6] = bypass_lpsmps_shift_r_rmps[6];
    wire_bypass_lpsmps_shift_r_rmps[7] = bypass_lpsmps_shift_r_rmps[7];
    wire_bypass_lpsmps_shift_r_rmps[8] = bypass_lpsmps_shift_r_rmps[8];
    wire_bypass_lpsmps_shift_r_rmps[9] = bypass_lpsmps_shift_r_rmps[9];
    wire_bypass_lpsmps_shift_r_rmps[10] = bypass_lpsmps_shift_r_rmps[10];
    wire_bypass_lpsmps_shift_r_rmps[11] = bypass_lpsmps_shift_r_rmps[11];
    wire_bypass_lpsmps_shift_r_rmps[12] = bypass_lpsmps_shift_r_rmps[12];
    wire_bypass_lpsmps_shift_r_rmps[13] = bypass_lpsmps_shift_r_rmps[13];
    wire_bypass_lpsmps_shift_r_rmps[14] = bypass_lpsmps_shift_r_rmps[14];
    wire_bypass_lpsmps_shift_r_rmps[15] = bypass_lpsmps_shift_r_rmps[15];
    wire_bypass_lpsmps_shift_r_rmps[16] = bypass_lpsmps_shift_r_rmps[16];
    wire_bypass_lpsmps_shift_r_rmps[17] = bypass_lpsmps_shift_r_rmps[17];
    wire_bypass_lpsmps_shift_r_rmps[18] = bypass_lpsmps_shift_r_rmps[18];
    wire_bypass_lpsmps_shift_r_rmps[19] = bypass_lpsmps_shift_r_rmps[19];
    wire_bypass_lpsmps_shift_r_rmps[20] = bypass_lpsmps_shift_r_rmps[20];
    wire_bypass_lpsmps_shift_r_rmps[21] = bypass_lpsmps_shift_r_rmps[21];
    wire_bypass_lpsmps_shift_r_rmps[22] = bypass_lpsmps_shift_r_rmps[22];
    wire_bypass_lpsmps_shift_r_rmps[23] = bypass_lpsmps_shift_r_rmps[23];
    wire_bypass_lpsmps_shift_r_rmps[24] = bypass_lpsmps_shift_r_rmps[24];
    wire_bypass_lpsmps_shift_r_rmps[25] = bypass_lpsmps_shift_r_rmps[25];
    wire_bypass_lpsmps_shift_r_rmps[26] = bypass_lpsmps_shift_r_rmps[26];
    wire_bypass_lpsmps_shift_r_rmps[27] = bypass_lpsmps_shift_r_rmps[27];
    wire_bypass_lpsmps_shift_r_rmps[28] = bypass_lpsmps_shift_r_rmps[28];
    wire_bypass_lpsmps_shift_r_rmps[29] = bypass_lpsmps_shift_r_rmps[29];
    wire_bypass_lpsmps_shift_r_rmps[30] = bypass_lpsmps_shift_r_rmps[30];
    wire_bypass_lpsmps_shift_r_rmps[31] = bypass_lpsmps_shift_r_rmps[31];
    if(w_enable)
    begin
        wire_bypass_lpsmps_shift_r_rmps[0] = bypass_lpsmps_shift_r_rmps[5];
        wire_bypass_lpsmps_shift_r_rmps[1] = bypass_lpsmps_shift_r_rmps[6];
        wire_bypass_lpsmps_shift_r_rmps[2] = bypass_lpsmps_shift_r_rmps[7];
        wire_bypass_lpsmps_shift_r_rmps[3] = bypass_lpsmps_shift_r_rmps[8];
        wire_bypass_lpsmps_shift_r_rmps[4] = bypass_lpsmps_shift_r_rmps[9];
        wire_bypass_lpsmps_shift_r_rmps[5] = bypass_lpsmps_shift_r_rmps[10];
        wire_bypass_lpsmps_shift_r_rmps[6] = bypass_lpsmps_shift_r_rmps[11];
        wire_bypass_lpsmps_shift_r_rmps[7] = bypass_lpsmps_shift_r_rmps[12];
        wire_bypass_lpsmps_shift_r_rmps[8] = bypass_lpsmps_shift_r_rmps[13];
        wire_bypass_lpsmps_shift_r_rmps[9] = bypass_lpsmps_shift_r_rmps[14];
        wire_bypass_lpsmps_shift_r_rmps[10] = bypass_lpsmps_shift_r_rmps[15];
        wire_bypass_lpsmps_shift_r_rmps[11] = bypass_lpsmps_shift_r_rmps[16];
        wire_bypass_lpsmps_shift_r_rmps[12] = bypass_lpsmps_shift_r_rmps[17];
        wire_bypass_lpsmps_shift_r_rmps[13] = bypass_lpsmps_shift_r_rmps[18];
        wire_bypass_lpsmps_shift_r_rmps[14] = bypass_lpsmps_shift_r_rmps[19];
        wire_bypass_lpsmps_shift_r_rmps[15] = bypass_lpsmps_shift_r_rmps[20];
        wire_bypass_lpsmps_shift_r_rmps[16] = bypass_lpsmps_shift_r_rmps[21];
        wire_bypass_lpsmps_shift_r_rmps[17] = bypass_lpsmps_shift_r_rmps[22];
        wire_bypass_lpsmps_shift_r_rmps[18] = bypass_lpsmps_shift_r_rmps[23];
        wire_bypass_lpsmps_shift_r_rmps[19] = bypass_lpsmps_shift_r_rmps[24];
        wire_bypass_lpsmps_shift_r_rmps[20] = bypass_lpsmps_shift_r_rmps[25];
        wire_bypass_lpsmps_shift_r_rmps[21] = bypass_lpsmps_shift_r_rmps[26];
        wire_bypass_lpsmps_shift_r_rmps[22] = bypass_lpsmps_shift_r_rmps[27];
        wire_bypass_lpsmps_shift_r_rmps[23] = bypass_lpsmps_shift_r_rmps[28];
        wire_bypass_lpsmps_shift_r_rmps[24] = bypass_lpsmps_shift_r_rmps[29];
        wire_bypass_lpsmps_shift_r_rmps[25] = bypass_lpsmps_shift_r_rmps[30];
        wire_bypass_lpsmps_shift_r_rmps[26] = bypass_lpsmps_shift_r_rmps[31];
    end
    case (used_space_new)
        5'd0 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[0] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[1] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[2] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[3] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[4] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[5] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[6] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[7] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd1 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[1] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[2] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[3] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[4] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[5] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[6] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[7] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[8] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd2 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[2] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[3] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[4] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[5] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[6] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[7] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[8] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[9] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd3 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[3] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[4] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[5] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[6] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[7] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[8] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[9] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[10] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd4 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[4] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[5] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[6] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[7] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[8] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[9] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[10] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[11] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd5 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[5] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[6] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[7] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[8] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[9] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[10] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[11] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[12] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd6 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[6] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[7] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[8] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[9] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[10] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[11] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[12] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[13] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd7 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[7] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[8] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[9] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[10] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[11] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[12] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[13] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[14] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd8 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[8] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[9] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[10] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[11] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[12] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[13] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[14] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[15] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd9 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[9] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[10] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[11] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[12] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[13] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[14] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[15] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[16] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd10 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[10] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[11] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[12] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[13] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[14] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[15] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[16] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[17] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd11 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[11] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[12] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[13] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[14] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[15] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[16] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[17] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[18] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd12 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[12] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[13] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[14] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[15] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[16] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[17] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[18] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[19] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd13 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[13] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[14] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[15] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[16] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[17] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[18] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[19] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[20] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd14 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[14] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[15] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[16] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[17] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[18] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[19] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[20] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[21] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd15 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[15] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[16] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[17] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[18] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[19] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[20] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[21] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[22] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd16 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[16] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[17] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[18] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[19] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[20] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[21] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[22] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[23] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd17 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[17] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[18] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[19] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[20] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[21] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[22] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[23] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[24] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd18 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[18] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[19] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[20] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[21] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[22] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[23] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[24] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[25] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd19 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[19] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[20] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[21] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[22] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[23] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[24] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[25] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[26] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd20 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[20] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[21] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[22] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[23] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[24] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[25] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[26] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[27] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd21 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[21] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[22] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[23] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[24] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[25] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[26] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[27] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[28] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd22 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[22] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[23] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[24] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[25] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[26] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[27] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[28] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[29] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd23 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[23] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[24] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[25] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[26] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[27] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[28] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[29] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[30] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd24 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[24] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[25] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[26] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[27] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[28] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[29] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[30] = bypass_lpsmps_shift_r_rmps_6;
            wire_bypass_lpsmps_shift_r_rmps[31] = bypass_lpsmps_shift_r_rmps_7;
        end
        5'd25 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[25] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[26] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[27] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[28] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[29] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[30] = bypass_lpsmps_shift_r_rmps_5;
            wire_bypass_lpsmps_shift_r_rmps[31] = bypass_lpsmps_shift_r_rmps_6;
        end
        5'd26 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[26] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[27] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[28] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[29] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[30] = bypass_lpsmps_shift_r_rmps_4;
            wire_bypass_lpsmps_shift_r_rmps[31] = bypass_lpsmps_shift_r_rmps_5;
        end
        5'd27 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[27] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[28] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[29] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[30] = bypass_lpsmps_shift_r_rmps_3;
            wire_bypass_lpsmps_shift_r_rmps[31] = bypass_lpsmps_shift_r_rmps_4;
        end
        5'd28 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[28] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[29] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[30] = bypass_lpsmps_shift_r_rmps_2;
            wire_bypass_lpsmps_shift_r_rmps[31] = bypass_lpsmps_shift_r_rmps_3;
        end
        5'd29 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[29] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[30] = bypass_lpsmps_shift_r_rmps_1;
            wire_bypass_lpsmps_shift_r_rmps[31] = bypass_lpsmps_shift_r_rmps_2;
        end
        5'd30 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[30] = bypass_lpsmps_shift_r_rmps_0;
            wire_bypass_lpsmps_shift_r_rmps[31] = bypass_lpsmps_shift_r_rmps_1;
        end
        5'd31 :
        begin
            wire_bypass_lpsmps_shift_r_rmps[31] = bypass_lpsmps_shift_r_rmps_0;
        end
    endcase
end

always @(posedge clk) //bypass_lpsmps_shift_r_rmps
begin
    bypass_lpsmps_shift_r_rmps[0] <= wire_bypass_lpsmps_shift_r_rmps[0];
    bypass_lpsmps_shift_r_rmps[1] <= wire_bypass_lpsmps_shift_r_rmps[1];
    bypass_lpsmps_shift_r_rmps[2] <= wire_bypass_lpsmps_shift_r_rmps[2];
    bypass_lpsmps_shift_r_rmps[3] <= wire_bypass_lpsmps_shift_r_rmps[3];
    bypass_lpsmps_shift_r_rmps[4] <= wire_bypass_lpsmps_shift_r_rmps[4];
    bypass_lpsmps_shift_r_rmps[5] <= wire_bypass_lpsmps_shift_r_rmps[5];
    bypass_lpsmps_shift_r_rmps[6] <= wire_bypass_lpsmps_shift_r_rmps[6];
    bypass_lpsmps_shift_r_rmps[7] <= wire_bypass_lpsmps_shift_r_rmps[7];
    bypass_lpsmps_shift_r_rmps[8] <= wire_bypass_lpsmps_shift_r_rmps[8];
    bypass_lpsmps_shift_r_rmps[9] <= wire_bypass_lpsmps_shift_r_rmps[9];
    bypass_lpsmps_shift_r_rmps[10] <= wire_bypass_lpsmps_shift_r_rmps[10];
    bypass_lpsmps_shift_r_rmps[11] <= wire_bypass_lpsmps_shift_r_rmps[11];
    bypass_lpsmps_shift_r_rmps[12] <= wire_bypass_lpsmps_shift_r_rmps[12];
    bypass_lpsmps_shift_r_rmps[13] <= wire_bypass_lpsmps_shift_r_rmps[13];
    bypass_lpsmps_shift_r_rmps[14] <= wire_bypass_lpsmps_shift_r_rmps[14];
    bypass_lpsmps_shift_r_rmps[15] <= wire_bypass_lpsmps_shift_r_rmps[15];
    bypass_lpsmps_shift_r_rmps[16] <= wire_bypass_lpsmps_shift_r_rmps[16];
    bypass_lpsmps_shift_r_rmps[17] <= wire_bypass_lpsmps_shift_r_rmps[17];
    bypass_lpsmps_shift_r_rmps[18] <= wire_bypass_lpsmps_shift_r_rmps[18];
    bypass_lpsmps_shift_r_rmps[19] <= wire_bypass_lpsmps_shift_r_rmps[19];
    bypass_lpsmps_shift_r_rmps[20] <= wire_bypass_lpsmps_shift_r_rmps[20];
    bypass_lpsmps_shift_r_rmps[21] <= wire_bypass_lpsmps_shift_r_rmps[21];
    bypass_lpsmps_shift_r_rmps[22] <= wire_bypass_lpsmps_shift_r_rmps[22];
    bypass_lpsmps_shift_r_rmps[23] <= wire_bypass_lpsmps_shift_r_rmps[23];
    bypass_lpsmps_shift_r_rmps[24] <= wire_bypass_lpsmps_shift_r_rmps[24];
    bypass_lpsmps_shift_r_rmps[25] <= wire_bypass_lpsmps_shift_r_rmps[25];
    bypass_lpsmps_shift_r_rmps[26] <= wire_bypass_lpsmps_shift_r_rmps[26];
    bypass_lpsmps_shift_r_rmps[27] <= wire_bypass_lpsmps_shift_r_rmps[27];
    bypass_lpsmps_shift_r_rmps[28] <= wire_bypass_lpsmps_shift_r_rmps[28];
    bypass_lpsmps_shift_r_rmps[29] <= wire_bypass_lpsmps_shift_r_rmps[29];
    bypass_lpsmps_shift_r_rmps[30] <= wire_bypass_lpsmps_shift_r_rmps[30];
    bypass_lpsmps_shift_r_rmps[31] <= wire_bypass_lpsmps_shift_r_rmps[31];
end

always @(posedge clk or negedge rst_n) //used_space
begin
    if(!rst_n)
        used_space <= 5'b0;
    else if(!en)
        used_space <= 5'b0;
    else
        used_space <= wire_used_space;
end

assign out_number           =   used_space < 5 ? used_space : 5;
assign used_space_new       =   w_enable ? (used_space < 5 ? 0 : used_space - 5) : used_space;
assign wire_used_space      =   r_enable ? used_space_new + in_number_all : used_space_new;

always @(posedge clk or negedge rst_n) // !!! add reset;
begin
    if(!rst_n)
        free_space <= 31;
    else if(!en)
        free_space <= 31;
    else
        free_space <= 31 - wire_used_space;
end

assign out_bypass_0     =   bypass_lpsmps_shift_r_rmps[0][13];
assign out_bypass_1     =   bypass_lpsmps_shift_r_rmps[1][13];
assign out_bypass_2     =   bypass_lpsmps_shift_r_rmps[2][13];
assign out_bypass_3     =   bypass_lpsmps_shift_r_rmps[3][13];
assign out_bypass_4     =   bypass_lpsmps_shift_r_rmps[4][13];

assign out_lpsmps_0     =   bypass_lpsmps_shift_r_rmps[0][12];
assign out_lpsmps_1     =   bypass_lpsmps_shift_r_rmps[1][12];
assign out_lpsmps_2     =   bypass_lpsmps_shift_r_rmps[2][12];
assign out_lpsmps_3     =   bypass_lpsmps_shift_r_rmps[3][12];
assign out_lpsmps_4     =   bypass_lpsmps_shift_r_rmps[4][12];

assign out_shift_0      =   bypass_lpsmps_shift_r_rmps[0][11:9];
assign out_shift_1      =   bypass_lpsmps_shift_r_rmps[1][11:9];
assign out_shift_2      =   bypass_lpsmps_shift_r_rmps[2][11:9];
assign out_shift_3      =   bypass_lpsmps_shift_r_rmps[3][11:9];
assign out_shift_4      =   bypass_lpsmps_shift_r_rmps[4][11:9];

assign out_r_rmps_0     =   bypass_lpsmps_shift_r_rmps[0][8:0];
assign out_r_rmps_1     =   bypass_lpsmps_shift_r_rmps[1][8:0];
assign out_r_rmps_2     =   bypass_lpsmps_shift_r_rmps[2][8:0];
assign out_r_rmps_3     =   bypass_lpsmps_shift_r_rmps[3][8:0];
assign out_r_rmps_4     =   bypass_lpsmps_shift_r_rmps[4][8:0];
//}

endmodule
