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
// Filename       : cabac_binsort.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : split bypass and regular mode bins
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------

module cabac_binsort(
           clk,
           w_enable,
           en,
           rst_n,

           data_valid,
           in_binsidx_0,
           in_binsidx_1,
           in_binsidx_2,
           in_binsidx_3,
           in_binsidx_4,
           in_binsidx_5,
           in_binsidx_6,
           in_binsidx_7,
           in_binsidx_8,
           in_binsidx_9,
           in_binsidx_10,
           in_binsidx_11,
           in_binsidx_12,
           in_binsidx_13,
           in_binsidx_14,
           in_binsidx_15,
           in_binsidx_16,
           in_binsidx_17,
           in_number,

           free_space,
           out_number_all,
           out_number_range,
           out_index_bypass,
           out_symbol_bypass,
           out_binsidx_0,
           out_binsidx_1,
           out_binsidx_2,
           out_binsidx_3
       );

//input and output signals //{
input               clk;
input               w_enable;
input               en;     //0 to reset
input               rst_n;

input               data_valid;
input       [9:0]   in_binsidx_0;
input       [9:0]   in_binsidx_1;
input       [9:0]   in_binsidx_2;
input       [9:0]   in_binsidx_3;
input       [9:0]   in_binsidx_4;
input       [9:0]   in_binsidx_5;
input       [9:0]   in_binsidx_6;
input       [9:0]   in_binsidx_7;
input       [9:0]   in_binsidx_8;
input       [9:0]   in_binsidx_9;
input       [9:0]   in_binsidx_10;
input       [9:0]   in_binsidx_11;
input       [9:0]   in_binsidx_12;
input       [9:0]   in_binsidx_13;
input       [9:0]   in_binsidx_14;
input       [9:0]   in_binsidx_15;
input       [9:0]   in_binsidx_16;
input       [9:0]   in_binsidx_17;
input       [4:0]   in_number;              //0~16

output      [5:0]   free_space;
output      [3:0]   out_number_all;         //0~8
output      [2:0]   out_number_range;       //0~4
output      [7:0]   out_index_bypass;
output      [7:0]   out_symbol_bypass;
output      [9:0]   out_binsidx_0;
output      [9:0]   out_binsidx_1;
output      [9:0]   out_binsidx_2;
output      [9:0]   out_binsidx_3;

//}

//signals //{
wire        [5:0]   free_space;
reg         [3:0]   out_number_all;         //0~8
reg         [2:0]   out_number_range;       //0~4
reg         [7:0]   out_index_bypass;
reg         [7:0]   out_symbol_bypass;
reg         [9:0]   out_binsidx_0;
reg         [9:0]   out_binsidx_1;
reg         [9:0]   out_binsidx_2;
reg         [9:0]   out_binsidx_3;

reg         [9:0]   wire_binsidx[0:49];
reg         [9:0]   binsidx[0:49];          //total space defined as 50
wire        [5:0]   wire_used_space;
reg         [5:0]   used_space;
wire        [5:0]   used_space_new;

wire        [7:0]   regular_flag;
wire        [3:0]   regular_num[0:7];

wire        [3:0]   wire_out_number_all;
reg         [3:0]   wire_out_number_all_1;
reg         [2:0]   wire_out_number_range;  //how many regular modes are output
reg         [9:0]   wire_out_binsidx_0;     //the first bin of regular mode
reg         [9:0]   wire_out_binsidx_1;
reg         [9:0]   wire_out_binsidx_2;
reg         [9:0]   wire_out_binsidx_3;
//}

/**************************************************************************
                                   _ _ _                  _ _ _ 
                                  |     |                |     |
in_binsidx_x -->wire_binsidx[x]-->| DFF |-->binsidx[x]-->| DFF |--> output
                        ^         |_ _ _|     |          |_ _ _|
                        |_ _ _ _ _ _ _ _ _ _ _| 
 
**************************************************************************/

//-------------get 4 regular modes binsidx-----------//
assign regular_flag[7] = binsidx[0][8:0]==9'd187 ? 1'b0 : 1'b1;
assign regular_flag[6] = binsidx[1][8:0]==9'd187 ? 1'b0 : 1'b1;
assign regular_flag[5] = binsidx[2][8:0]==9'd187 ? 1'b0 : 1'b1;
assign regular_flag[4] = binsidx[3][8:0]==9'd187 ? 1'b0 : 1'b1;
assign regular_flag[3] = binsidx[4][8:0]==9'd187 ? 1'b0 : 1'b1;
assign regular_flag[2] = binsidx[5][8:0]==9'd187 ? 1'b0 : 1'b1;
assign regular_flag[1] = binsidx[6][8:0]==9'd187 ? 1'b0 : 1'b1;
assign regular_flag[0] = binsidx[7][8:0]==9'd187 ? 1'b0 : 1'b1;

assign regular_num[0] = regular_flag[7];
assign regular_num[1] = regular_flag[7] + regular_flag[6];
assign regular_num[2] = regular_flag[7] + regular_flag[6] + regular_flag[5];
assign regular_num[3] = regular_flag[7] + regular_flag[6] + regular_flag[5] + regular_flag[4];
assign regular_num[4] = regular_flag[7] + regular_flag[6] + regular_flag[5] + regular_flag[4] + regular_flag[3];
assign regular_num[5] = regular_flag[7] + regular_flag[6] + regular_flag[5] + regular_flag[4] + regular_flag[3] + regular_flag[2];
assign regular_num[6] = regular_flag[7] + regular_flag[6] + regular_flag[5] + regular_flag[4] + regular_flag[3] + regular_flag[2] + regular_flag[1];
assign regular_num[7] = regular_flag[7] + regular_flag[6] + regular_flag[5] + regular_flag[4] + regular_flag[3] + regular_flag[2] + regular_flag[1] + regular_flag[0];

always @(*)
begin
    wire_out_number_all_1 = 8;
    if(!w_enable || !en)
        wire_out_number_all_1 = 0;
    else if(used_space < 5)
        wire_out_number_all_1 = used_space;
    else if(regular_num[4] > 4)
        wire_out_number_all_1 = 4;
    else if(regular_num[5] > 4)
        wire_out_number_all_1 = 5;
    else if(regular_num[6] > 4)
        wire_out_number_all_1 = 6;
    else if(regular_num[7] > 4)
        wire_out_number_all_1 = 7;
end
assign wire_out_number_all = wire_out_number_all_1<=used_space ? wire_out_number_all_1 : used_space[3:0];

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        used_space <= 0;
    else if(!en)
        used_space <= 6'b0;
    else
        used_space <= wire_used_space;
end

assign used_space_new = used_space - wire_out_number_all;
assign wire_used_space = data_valid ? (used_space_new + in_number) : used_space_new;

always @(*) //according to the number of output bins, get number of regular modes
begin
    wire_out_number_range = regular_num[7][2:0];
    case (wire_out_number_all)
        4'd0 :
        begin
            wire_out_number_range = 0;
        end
        4'd1 :
        begin
            wire_out_number_range = regular_num[0][2:0];
        end
        4'd2 :
        begin
            wire_out_number_range = regular_num[1][2:0];
        end
        4'd3 :
        begin
            wire_out_number_range = regular_num[2][2:0];
        end
        4'd4 :
        begin
            wire_out_number_range = regular_num[3][2:0];
        end
        4'd5 :
        begin
            wire_out_number_range = regular_num[4][2:0];
        end
        4'd6 :
        begin
            wire_out_number_range = regular_num[5][2:0];
        end
        4'd7 :
        begin
            wire_out_number_range = regular_num[6][2:0];
        end
        default:
            wire_out_number_range = regular_num[7][2:0];
    endcase
end


always @(*) //wire_out_binsidx_0
begin
    wire_out_binsidx_0 = binsidx[7];
    casex(regular_flag)
        8'b1xxxxxxx :
        begin
            wire_out_binsidx_0 = binsidx[0];
        end
        8'b01xxxxxx :
        begin
            wire_out_binsidx_0 = binsidx[1];
        end
        8'b001xxxxx :
        begin
            wire_out_binsidx_0 = binsidx[2];
        end
        8'b0001xxxx :
        begin
            wire_out_binsidx_0 = binsidx[3];
        end
        8'b00001xxx :
        begin
            wire_out_binsidx_0 = binsidx[4];
        end
        8'b000001xx :
        begin
            wire_out_binsidx_0 = binsidx[5];
        end
        8'b0000001x :
        begin
            wire_out_binsidx_0 = binsidx[6];
        end
        default:
            wire_out_binsidx_0 = binsidx[7];
    endcase
end

always @(*) //wire_out_binsidx_1
begin
    wire_out_binsidx_1 = binsidx[7];
    if(regular_num[1] == 2)
        wire_out_binsidx_1 = binsidx[1];
    else if(regular_num[2] == 2)
        wire_out_binsidx_1 = binsidx[2];
    else if(regular_num[3] == 2)
        wire_out_binsidx_1 = binsidx[3];
    else if(regular_num[4] == 2)
        wire_out_binsidx_1 = binsidx[4];
    else if(regular_num[5] == 2)
        wire_out_binsidx_1 = binsidx[5];
    else if(regular_num[6] == 2)
        wire_out_binsidx_1 = binsidx[6];
end

always @(*) //wire_out_binsidx_2
begin
    wire_out_binsidx_2 = binsidx[7];
    if(regular_num[2] == 3)
        wire_out_binsidx_2 = binsidx[2];
    else if(regular_num[3] == 3)
        wire_out_binsidx_2 = binsidx[3];
    else if(regular_num[4] == 3)
        wire_out_binsidx_2 = binsidx[4];
    else if(regular_num[5] == 3)
        wire_out_binsidx_2 = binsidx[5];
    else if(regular_num[6] == 3)
        wire_out_binsidx_2 = binsidx[6];
end

always @(*) //wire_out_binsidx_3
begin
    wire_out_binsidx_3 = binsidx[7];
    if(regular_num[3] == 4)
        wire_out_binsidx_3 = binsidx[3];
    else if(regular_num[4] == 4)
        wire_out_binsidx_3 = binsidx[4];
    else if(regular_num[5] == 4)
        wire_out_binsidx_3 = binsidx[5];
    else if(regular_num[6] == 4)
        wire_out_binsidx_3 = binsidx[6];
end
//---------------------------------------------------//


//-------- combine the input data and left data------//
always @(posedge clk) //binsidx
begin
    binsidx[0] <= wire_binsidx[0];
    binsidx[1] <= wire_binsidx[1];
    binsidx[2] <= wire_binsidx[2];
    binsidx[3] <= wire_binsidx[3];
    binsidx[4] <= wire_binsidx[4];
    binsidx[5] <= wire_binsidx[5];
    binsidx[6] <= wire_binsidx[6];
    binsidx[7] <= wire_binsidx[7];
    binsidx[8] <= wire_binsidx[8];
    binsidx[9] <= wire_binsidx[9];
    binsidx[10] <= wire_binsidx[10];
    binsidx[11] <= wire_binsidx[11];
    binsidx[12] <= wire_binsidx[12];
    binsidx[13] <= wire_binsidx[13];
    binsidx[14] <= wire_binsidx[14];
    binsidx[15] <= wire_binsidx[15];
    binsidx[16] <= wire_binsidx[16];
    binsidx[17] <= wire_binsidx[17];
    binsidx[18] <= wire_binsidx[18];
    binsidx[19] <= wire_binsidx[19];
    binsidx[20] <= wire_binsidx[20];
    binsidx[21] <= wire_binsidx[21];
    binsidx[22] <= wire_binsidx[22];
    binsidx[23] <= wire_binsidx[23];
    binsidx[24] <= wire_binsidx[24];
    binsidx[25] <= wire_binsidx[25];
    binsidx[26] <= wire_binsidx[26];
    binsidx[27] <= wire_binsidx[27];
    binsidx[28] <= wire_binsidx[28];
    binsidx[29] <= wire_binsidx[29];
    binsidx[30] <= wire_binsidx[30];
    binsidx[31] <= wire_binsidx[31];
    binsidx[32] <= wire_binsidx[32];
    binsidx[33] <= wire_binsidx[33];
    binsidx[34] <= wire_binsidx[34];
    binsidx[35] <= wire_binsidx[35];
    binsidx[36] <= wire_binsidx[36];
    binsidx[37] <= wire_binsidx[37];
    binsidx[38] <= wire_binsidx[38];
    binsidx[39] <= wire_binsidx[39];
    binsidx[40] <= wire_binsidx[40];
    binsidx[41] <= wire_binsidx[41];
    binsidx[42] <= wire_binsidx[42];
    binsidx[43] <= wire_binsidx[43];
    binsidx[44] <= wire_binsidx[44];
    binsidx[45] <= wire_binsidx[45];
    binsidx[46] <= wire_binsidx[46];
    binsidx[47] <= wire_binsidx[47];
    binsidx[48] <= wire_binsidx[48];
    binsidx[49] <= wire_binsidx[49];
end

always @(*) //wire_binsidx
begin
    wire_binsidx[0] = binsidx[0];
    wire_binsidx[1] = binsidx[1];
    wire_binsidx[2] = binsidx[2];
    wire_binsidx[3] = binsidx[3];
    wire_binsidx[4] = binsidx[4];
    wire_binsidx[5] = binsidx[5];
    wire_binsidx[6] = binsidx[6];
    wire_binsidx[7] = binsidx[7];
    wire_binsidx[8] = binsidx[8];
    wire_binsidx[9] = binsidx[9];
    wire_binsidx[10] = binsidx[10];
    wire_binsidx[11] = binsidx[11];
    wire_binsidx[12] = binsidx[12];
    wire_binsidx[13] = binsidx[13];
    wire_binsidx[14] = binsidx[14];
    wire_binsidx[15] = binsidx[15];
    wire_binsidx[16] = binsidx[16];
    wire_binsidx[17] = binsidx[17];
    wire_binsidx[18] = binsidx[18];
    wire_binsidx[19] = binsidx[19];
    wire_binsidx[20] = binsidx[20];
    wire_binsidx[21] = binsidx[21];
    wire_binsidx[22] = binsidx[22];
    wire_binsidx[23] = binsidx[23];
    wire_binsidx[24] = binsidx[24];
    wire_binsidx[25] = binsidx[25];
    wire_binsidx[26] = binsidx[26];
    wire_binsidx[27] = binsidx[27];
    wire_binsidx[28] = binsidx[28];
    wire_binsidx[29] = binsidx[29];
    wire_binsidx[30] = binsidx[30];
    wire_binsidx[31] = binsidx[31];
    wire_binsidx[32] = binsidx[32];
    wire_binsidx[33] = binsidx[33];
    wire_binsidx[34] = binsidx[34];
    wire_binsidx[35] = binsidx[35];
    wire_binsidx[36] = binsidx[36];
    wire_binsidx[37] = binsidx[37];
    wire_binsidx[38] = binsidx[38];
    wire_binsidx[39] = binsidx[39];
    wire_binsidx[40] = binsidx[40];
    wire_binsidx[41] = binsidx[41];
    wire_binsidx[42] = binsidx[42];
    wire_binsidx[43] = binsidx[43];
    wire_binsidx[44] = binsidx[44];
    wire_binsidx[45] = binsidx[45];
    wire_binsidx[46] = binsidx[46];
    wire_binsidx[47] = binsidx[47];
    wire_binsidx[48] = binsidx[48];
    wire_binsidx[49] = binsidx[49];
    if(w_enable)
    begin
        case (wire_out_number_all) // left move the binsidx to remove the output bins.
            4'd0 :
            begin
                wire_binsidx[0] = binsidx[0];
                wire_binsidx[1] = binsidx[1];
                wire_binsidx[2] = binsidx[2];
                wire_binsidx[3] = binsidx[3];
                wire_binsidx[4] = binsidx[4];
                wire_binsidx[5] = binsidx[5];
                wire_binsidx[6] = binsidx[6];
                wire_binsidx[7] = binsidx[7];
                wire_binsidx[8] = binsidx[8];
                wire_binsidx[9] = binsidx[9];
                wire_binsidx[10] = binsidx[10];
                wire_binsidx[11] = binsidx[11];
                wire_binsidx[12] = binsidx[12];
                wire_binsidx[13] = binsidx[13];
                wire_binsidx[14] = binsidx[14];
                wire_binsidx[15] = binsidx[15];
                wire_binsidx[16] = binsidx[16];
                wire_binsidx[17] = binsidx[17];
                wire_binsidx[18] = binsidx[18];
                wire_binsidx[19] = binsidx[19];
                wire_binsidx[20] = binsidx[20];
                wire_binsidx[21] = binsidx[21];
                wire_binsidx[22] = binsidx[22];
                wire_binsidx[23] = binsidx[23];
                wire_binsidx[24] = binsidx[24];
                wire_binsidx[25] = binsidx[25];
                wire_binsidx[26] = binsidx[26];
                wire_binsidx[27] = binsidx[27];
                wire_binsidx[28] = binsidx[28];
                wire_binsidx[29] = binsidx[29];
                wire_binsidx[30] = binsidx[30];
                wire_binsidx[31] = binsidx[31];
                wire_binsidx[32] = binsidx[32];
                wire_binsidx[33] = binsidx[33];
                wire_binsidx[34] = binsidx[34];
                wire_binsidx[35] = binsidx[35];
                wire_binsidx[36] = binsidx[36];
                wire_binsidx[37] = binsidx[37];
                wire_binsidx[38] = binsidx[38];
                wire_binsidx[39] = binsidx[39];
                wire_binsidx[40] = binsidx[40];
                wire_binsidx[41] = binsidx[41];
                wire_binsidx[42] = binsidx[42];
                wire_binsidx[43] = binsidx[43];
                wire_binsidx[44] = binsidx[44];
                wire_binsidx[45] = binsidx[45];
                wire_binsidx[46] = binsidx[46];
                wire_binsidx[47] = binsidx[47];
                wire_binsidx[48] = binsidx[48];
                wire_binsidx[49] = binsidx[49];
            end
            4'd1 :
            begin
                wire_binsidx[0] = binsidx[1];
                wire_binsidx[1] = binsidx[2];
                wire_binsidx[2] = binsidx[3];
                wire_binsidx[3] = binsidx[4];
                wire_binsidx[4] = binsidx[5];
                wire_binsidx[5] = binsidx[6];
                wire_binsidx[6] = binsidx[7];
                wire_binsidx[7] = binsidx[8];
                wire_binsidx[8] = binsidx[9];
                wire_binsidx[9] = binsidx[10];
                wire_binsidx[10] = binsidx[11];
                wire_binsidx[11] = binsidx[12];
                wire_binsidx[12] = binsidx[13];
                wire_binsidx[13] = binsidx[14];
                wire_binsidx[14] = binsidx[15];
                wire_binsidx[15] = binsidx[16];
                wire_binsidx[16] = binsidx[17];
                wire_binsidx[17] = binsidx[18];
                wire_binsidx[18] = binsidx[19];
                wire_binsidx[19] = binsidx[20];
                wire_binsidx[20] = binsidx[21];
                wire_binsidx[21] = binsidx[22];
                wire_binsidx[22] = binsidx[23];
                wire_binsidx[23] = binsidx[24];
                wire_binsidx[24] = binsidx[25];
                wire_binsidx[25] = binsidx[26];
                wire_binsidx[26] = binsidx[27];
                wire_binsidx[27] = binsidx[28];
                wire_binsidx[28] = binsidx[29];
                wire_binsidx[29] = binsidx[30];
                wire_binsidx[30] = binsidx[31];
                wire_binsidx[31] = binsidx[32];
                wire_binsidx[32] = binsidx[33];
                wire_binsidx[33] = binsidx[34];
                wire_binsidx[34] = binsidx[35];
                wire_binsidx[35] = binsidx[36];
                wire_binsidx[36] = binsidx[37];
                wire_binsidx[37] = binsidx[38];
                wire_binsidx[38] = binsidx[39];
                wire_binsidx[39] = binsidx[40];
                wire_binsidx[40] = binsidx[41];
                wire_binsidx[41] = binsidx[42];
                wire_binsidx[42] = binsidx[43];
                wire_binsidx[43] = binsidx[44];
                wire_binsidx[44] = binsidx[45];
                wire_binsidx[45] = binsidx[46];
                wire_binsidx[46] = binsidx[47];
                wire_binsidx[47] = binsidx[48];
                wire_binsidx[48] = binsidx[49];
            end
            4'd2 :
            begin
                wire_binsidx[0] = binsidx[2];
                wire_binsidx[1] = binsidx[3];
                wire_binsidx[2] = binsidx[4];
                wire_binsidx[3] = binsidx[5];
                wire_binsidx[4] = binsidx[6];
                wire_binsidx[5] = binsidx[7];
                wire_binsidx[6] = binsidx[8];
                wire_binsidx[7] = binsidx[9];
                wire_binsidx[8] = binsidx[10];
                wire_binsidx[9] = binsidx[11];
                wire_binsidx[10] = binsidx[12];
                wire_binsidx[11] = binsidx[13];
                wire_binsidx[12] = binsidx[14];
                wire_binsidx[13] = binsidx[15];
                wire_binsidx[14] = binsidx[16];
                wire_binsidx[15] = binsidx[17];
                wire_binsidx[16] = binsidx[18];
                wire_binsidx[17] = binsidx[19];
                wire_binsidx[18] = binsidx[20];
                wire_binsidx[19] = binsidx[21];
                wire_binsidx[20] = binsidx[22];
                wire_binsidx[21] = binsidx[23];
                wire_binsidx[22] = binsidx[24];
                wire_binsidx[23] = binsidx[25];
                wire_binsidx[24] = binsidx[26];
                wire_binsidx[25] = binsidx[27];
                wire_binsidx[26] = binsidx[28];
                wire_binsidx[27] = binsidx[29];
                wire_binsidx[28] = binsidx[30];
                wire_binsidx[29] = binsidx[31];
                wire_binsidx[30] = binsidx[32];
                wire_binsidx[31] = binsidx[33];
                wire_binsidx[32] = binsidx[34];
                wire_binsidx[33] = binsidx[35];
                wire_binsidx[34] = binsidx[36];
                wire_binsidx[35] = binsidx[37];
                wire_binsidx[36] = binsidx[38];
                wire_binsidx[37] = binsidx[39];
                wire_binsidx[38] = binsidx[40];
                wire_binsidx[39] = binsidx[41];
                wire_binsidx[40] = binsidx[42];
                wire_binsidx[41] = binsidx[43];
                wire_binsidx[42] = binsidx[44];
                wire_binsidx[43] = binsidx[45];
                wire_binsidx[44] = binsidx[46];
                wire_binsidx[45] = binsidx[47];
                wire_binsidx[46] = binsidx[48];
                wire_binsidx[47] = binsidx[49];
            end
            4'd3 :
            begin
                wire_binsidx[0] = binsidx[3];
                wire_binsidx[1] = binsidx[4];
                wire_binsidx[2] = binsidx[5];
                wire_binsidx[3] = binsidx[6];
                wire_binsidx[4] = binsidx[7];
                wire_binsidx[5] = binsidx[8];
                wire_binsidx[6] = binsidx[9];
                wire_binsidx[7] = binsidx[10];
                wire_binsidx[8] = binsidx[11];
                wire_binsidx[9] = binsidx[12];
                wire_binsidx[10] = binsidx[13];
                wire_binsidx[11] = binsidx[14];
                wire_binsidx[12] = binsidx[15];
                wire_binsidx[13] = binsidx[16];
                wire_binsidx[14] = binsidx[17];
                wire_binsidx[15] = binsidx[18];
                wire_binsidx[16] = binsidx[19];
                wire_binsidx[17] = binsidx[20];
                wire_binsidx[18] = binsidx[21];
                wire_binsidx[19] = binsidx[22];
                wire_binsidx[20] = binsidx[23];
                wire_binsidx[21] = binsidx[24];
                wire_binsidx[22] = binsidx[25];
                wire_binsidx[23] = binsidx[26];
                wire_binsidx[24] = binsidx[27];
                wire_binsidx[25] = binsidx[28];
                wire_binsidx[26] = binsidx[29];
                wire_binsidx[27] = binsidx[30];
                wire_binsidx[28] = binsidx[31];
                wire_binsidx[29] = binsidx[32];
                wire_binsidx[30] = binsidx[33];
                wire_binsidx[31] = binsidx[34];
                wire_binsidx[32] = binsidx[35];
                wire_binsidx[33] = binsidx[36];
                wire_binsidx[34] = binsidx[37];
                wire_binsidx[35] = binsidx[38];
                wire_binsidx[36] = binsidx[39];
                wire_binsidx[37] = binsidx[40];
                wire_binsidx[38] = binsidx[41];
                wire_binsidx[39] = binsidx[42];
                wire_binsidx[40] = binsidx[43];
                wire_binsidx[41] = binsidx[44];
                wire_binsidx[42] = binsidx[45];
                wire_binsidx[43] = binsidx[46];
                wire_binsidx[44] = binsidx[47];
                wire_binsidx[45] = binsidx[48];
                wire_binsidx[46] = binsidx[49];
            end
            4'd4 :
            begin
                wire_binsidx[0] = binsidx[4];
                wire_binsidx[1] = binsidx[5];
                wire_binsidx[2] = binsidx[6];
                wire_binsidx[3] = binsidx[7];
                wire_binsidx[4] = binsidx[8];
                wire_binsidx[5] = binsidx[9];
                wire_binsidx[6] = binsidx[10];
                wire_binsidx[7] = binsidx[11];
                wire_binsidx[8] = binsidx[12];
                wire_binsidx[9] = binsidx[13];
                wire_binsidx[10] = binsidx[14];
                wire_binsidx[11] = binsidx[15];
                wire_binsidx[12] = binsidx[16];
                wire_binsidx[13] = binsidx[17];
                wire_binsidx[14] = binsidx[18];
                wire_binsidx[15] = binsidx[19];
                wire_binsidx[16] = binsidx[20];
                wire_binsidx[17] = binsidx[21];
                wire_binsidx[18] = binsidx[22];
                wire_binsidx[19] = binsidx[23];
                wire_binsidx[20] = binsidx[24];
                wire_binsidx[21] = binsidx[25];
                wire_binsidx[22] = binsidx[26];
                wire_binsidx[23] = binsidx[27];
                wire_binsidx[24] = binsidx[28];
                wire_binsidx[25] = binsidx[29];
                wire_binsidx[26] = binsidx[30];
                wire_binsidx[27] = binsidx[31];
                wire_binsidx[28] = binsidx[32];
                wire_binsidx[29] = binsidx[33];
                wire_binsidx[30] = binsidx[34];
                wire_binsidx[31] = binsidx[35];
                wire_binsidx[32] = binsidx[36];
                wire_binsidx[33] = binsidx[37];
                wire_binsidx[34] = binsidx[38];
                wire_binsidx[35] = binsidx[39];
                wire_binsidx[36] = binsidx[40];
                wire_binsidx[37] = binsidx[41];
                wire_binsidx[38] = binsidx[42];
                wire_binsidx[39] = binsidx[43];
                wire_binsidx[40] = binsidx[44];
                wire_binsidx[41] = binsidx[45];
                wire_binsidx[42] = binsidx[46];
                wire_binsidx[43] = binsidx[47];
                wire_binsidx[44] = binsidx[48];
                wire_binsidx[45] = binsidx[49];
            end
            4'd5 :
            begin
                wire_binsidx[0] = binsidx[5];
                wire_binsidx[1] = binsidx[6];
                wire_binsidx[2] = binsidx[7];
                wire_binsidx[3] = binsidx[8];
                wire_binsidx[4] = binsidx[9];
                wire_binsidx[5] = binsidx[10];
                wire_binsidx[6] = binsidx[11];
                wire_binsidx[7] = binsidx[12];
                wire_binsidx[8] = binsidx[13];
                wire_binsidx[9] = binsidx[14];
                wire_binsidx[10] = binsidx[15];
                wire_binsidx[11] = binsidx[16];
                wire_binsidx[12] = binsidx[17];
                wire_binsidx[13] = binsidx[18];
                wire_binsidx[14] = binsidx[19];
                wire_binsidx[15] = binsidx[20];
                wire_binsidx[16] = binsidx[21];
                wire_binsidx[17] = binsidx[22];
                wire_binsidx[18] = binsidx[23];
                wire_binsidx[19] = binsidx[24];
                wire_binsidx[20] = binsidx[25];
                wire_binsidx[21] = binsidx[26];
                wire_binsidx[22] = binsidx[27];
                wire_binsidx[23] = binsidx[28];
                wire_binsidx[24] = binsidx[29];
                wire_binsidx[25] = binsidx[30];
                wire_binsidx[26] = binsidx[31];
                wire_binsidx[27] = binsidx[32];
                wire_binsidx[28] = binsidx[33];
                wire_binsidx[29] = binsidx[34];
                wire_binsidx[30] = binsidx[35];
                wire_binsidx[31] = binsidx[36];
                wire_binsidx[32] = binsidx[37];
                wire_binsidx[33] = binsidx[38];
                wire_binsidx[34] = binsidx[39];
                wire_binsidx[35] = binsidx[40];
                wire_binsidx[36] = binsidx[41];
                wire_binsidx[37] = binsidx[42];
                wire_binsidx[38] = binsidx[43];
                wire_binsidx[39] = binsidx[44];
                wire_binsidx[40] = binsidx[45];
                wire_binsidx[41] = binsidx[46];
                wire_binsidx[42] = binsidx[47];
                wire_binsidx[43] = binsidx[48];
                wire_binsidx[44] = binsidx[49];
            end
            4'd6 :
            begin
                wire_binsidx[0] = binsidx[6];
                wire_binsidx[1] = binsidx[7];
                wire_binsidx[2] = binsidx[8];
                wire_binsidx[3] = binsidx[9];
                wire_binsidx[4] = binsidx[10];
                wire_binsidx[5] = binsidx[11];
                wire_binsidx[6] = binsidx[12];
                wire_binsidx[7] = binsidx[13];
                wire_binsidx[8] = binsidx[14];
                wire_binsidx[9] = binsidx[15];
                wire_binsidx[10] = binsidx[16];
                wire_binsidx[11] = binsidx[17];
                wire_binsidx[12] = binsidx[18];
                wire_binsidx[13] = binsidx[19];
                wire_binsidx[14] = binsidx[20];
                wire_binsidx[15] = binsidx[21];
                wire_binsidx[16] = binsidx[22];
                wire_binsidx[17] = binsidx[23];
                wire_binsidx[18] = binsidx[24];
                wire_binsidx[19] = binsidx[25];
                wire_binsidx[20] = binsidx[26];
                wire_binsidx[21] = binsidx[27];
                wire_binsidx[22] = binsidx[28];
                wire_binsidx[23] = binsidx[29];
                wire_binsidx[24] = binsidx[30];
                wire_binsidx[25] = binsidx[31];
                wire_binsidx[26] = binsidx[32];
                wire_binsidx[27] = binsidx[33];
                wire_binsidx[28] = binsidx[34];
                wire_binsidx[29] = binsidx[35];
                wire_binsidx[30] = binsidx[36];
                wire_binsidx[31] = binsidx[37];
                wire_binsidx[32] = binsidx[38];
                wire_binsidx[33] = binsidx[39];
                wire_binsidx[34] = binsidx[40];
                wire_binsidx[35] = binsidx[41];
                wire_binsidx[36] = binsidx[42];
                wire_binsidx[37] = binsidx[43];
                wire_binsidx[38] = binsidx[44];
                wire_binsidx[39] = binsidx[45];
                wire_binsidx[40] = binsidx[46];
                wire_binsidx[41] = binsidx[47];
                wire_binsidx[42] = binsidx[48];
                wire_binsidx[43] = binsidx[49];
            end
            4'd7 :
            begin
                wire_binsidx[0] = binsidx[7];
                wire_binsidx[1] = binsidx[8];
                wire_binsidx[2] = binsidx[9];
                wire_binsidx[3] = binsidx[10];
                wire_binsidx[4] = binsidx[11];
                wire_binsidx[5] = binsidx[12];
                wire_binsidx[6] = binsidx[13];
                wire_binsidx[7] = binsidx[14];
                wire_binsidx[8] = binsidx[15];
                wire_binsidx[9] = binsidx[16];
                wire_binsidx[10] = binsidx[17];
                wire_binsidx[11] = binsidx[18];
                wire_binsidx[12] = binsidx[19];
                wire_binsidx[13] = binsidx[20];
                wire_binsidx[14] = binsidx[21];
                wire_binsidx[15] = binsidx[22];
                wire_binsidx[16] = binsidx[23];
                wire_binsidx[17] = binsidx[24];
                wire_binsidx[18] = binsidx[25];
                wire_binsidx[19] = binsidx[26];
                wire_binsidx[20] = binsidx[27];
                wire_binsidx[21] = binsidx[28];
                wire_binsidx[22] = binsidx[29];
                wire_binsidx[23] = binsidx[30];
                wire_binsidx[24] = binsidx[31];
                wire_binsidx[25] = binsidx[32];
                wire_binsidx[26] = binsidx[33];
                wire_binsidx[27] = binsidx[34];
                wire_binsidx[28] = binsidx[35];
                wire_binsidx[29] = binsidx[36];
                wire_binsidx[30] = binsidx[37];
                wire_binsidx[31] = binsidx[38];
                wire_binsidx[32] = binsidx[39];
                wire_binsidx[33] = binsidx[40];
                wire_binsidx[34] = binsidx[41];
                wire_binsidx[35] = binsidx[42];
                wire_binsidx[36] = binsidx[43];
                wire_binsidx[37] = binsidx[44];
                wire_binsidx[38] = binsidx[45];
                wire_binsidx[39] = binsidx[46];
                wire_binsidx[40] = binsidx[47];
                wire_binsidx[41] = binsidx[48];
                wire_binsidx[42] = binsidx[49];
            end
            4'd8 :
            begin
                wire_binsidx[0] = binsidx[8];
                wire_binsidx[1] = binsidx[9];
                wire_binsidx[2] = binsidx[10];
                wire_binsidx[3] = binsidx[11];
                wire_binsidx[4] = binsidx[12];
                wire_binsidx[5] = binsidx[13];
                wire_binsidx[6] = binsidx[14];
                wire_binsidx[7] = binsidx[15];
                wire_binsidx[8] = binsidx[16];
                wire_binsidx[9] = binsidx[17];
                wire_binsidx[10] = binsidx[18];
                wire_binsidx[11] = binsidx[19];
                wire_binsidx[12] = binsidx[20];
                wire_binsidx[13] = binsidx[21];
                wire_binsidx[14] = binsidx[22];
                wire_binsidx[15] = binsidx[23];
                wire_binsidx[16] = binsidx[24];
                wire_binsidx[17] = binsidx[25];
                wire_binsidx[18] = binsidx[26];
                wire_binsidx[19] = binsidx[27];
                wire_binsidx[20] = binsidx[28];
                wire_binsidx[21] = binsidx[29];
                wire_binsidx[22] = binsidx[30];
                wire_binsidx[23] = binsidx[31];
                wire_binsidx[24] = binsidx[32];
                wire_binsidx[25] = binsidx[33];
                wire_binsidx[26] = binsidx[34];
                wire_binsidx[27] = binsidx[35];
                wire_binsidx[28] = binsidx[36];
                wire_binsidx[29] = binsidx[37];
                wire_binsidx[30] = binsidx[38];
                wire_binsidx[31] = binsidx[39];
                wire_binsidx[32] = binsidx[40];
                wire_binsidx[33] = binsidx[41];
                wire_binsidx[34] = binsidx[42];
                wire_binsidx[35] = binsidx[43];
                wire_binsidx[36] = binsidx[44];
                wire_binsidx[37] = binsidx[45];
                wire_binsidx[38] = binsidx[46];
                wire_binsidx[39] = binsidx[47];
                wire_binsidx[40] = binsidx[48];
                wire_binsidx[41] = binsidx[49];
            end
            default:
            begin
                wire_binsidx[0] = binsidx[0];
                wire_binsidx[1] = binsidx[1];
                wire_binsidx[2] = binsidx[2];
                wire_binsidx[3] = binsidx[3];
                wire_binsidx[4] = binsidx[4];
                wire_binsidx[5] = binsidx[5];
                wire_binsidx[6] = binsidx[6];
                wire_binsidx[7] = binsidx[7];
                wire_binsidx[8] = binsidx[8];
                wire_binsidx[9] = binsidx[9];
                wire_binsidx[10] = binsidx[10];
                wire_binsidx[11] = binsidx[11];
                wire_binsidx[12] = binsidx[12];
                wire_binsidx[13] = binsidx[13];
                wire_binsidx[14] = binsidx[14];
                wire_binsidx[15] = binsidx[15];
                wire_binsidx[16] = binsidx[16];
                wire_binsidx[17] = binsidx[17];
                wire_binsidx[18] = binsidx[18];
                wire_binsidx[19] = binsidx[19];
                wire_binsidx[20] = binsidx[20];
                wire_binsidx[21] = binsidx[21];
                wire_binsidx[22] = binsidx[22];
                wire_binsidx[23] = binsidx[23];
                wire_binsidx[24] = binsidx[24];
                wire_binsidx[25] = binsidx[25];
                wire_binsidx[26] = binsidx[26];
                wire_binsidx[27] = binsidx[27];
                wire_binsidx[28] = binsidx[28];
                wire_binsidx[29] = binsidx[29];
                wire_binsidx[30] = binsidx[30];
                wire_binsidx[31] = binsidx[31];
                wire_binsidx[32] = binsidx[32];
                wire_binsidx[33] = binsidx[33];
                wire_binsidx[34] = binsidx[34];
                wire_binsidx[35] = binsidx[35];
                wire_binsidx[36] = binsidx[36];
                wire_binsidx[37] = binsidx[37];
                wire_binsidx[38] = binsidx[38];
                wire_binsidx[39] = binsidx[39];
                wire_binsidx[40] = binsidx[40];
                wire_binsidx[41] = binsidx[41];
                wire_binsidx[42] = binsidx[42];
                wire_binsidx[43] = binsidx[43];
                wire_binsidx[44] = binsidx[44];
                wire_binsidx[45] = binsidx[45];
                wire_binsidx[46] = binsidx[46];
                wire_binsidx[47] = binsidx[47];
                wire_binsidx[48] = binsidx[48];
                wire_binsidx[49] = binsidx[49];
            end
        endcase
    end
    case (used_space_new) // if the used_space > 32, some input data is left, will it be OK ? FIXME
        6'd0 :
        begin
            wire_binsidx[0] = in_binsidx_0;
            wire_binsidx[1] = in_binsidx_1;
            wire_binsidx[2] = in_binsidx_2;
            wire_binsidx[3] = in_binsidx_3;
            wire_binsidx[4] = in_binsidx_4;
            wire_binsidx[5] = in_binsidx_5;
            wire_binsidx[6] = in_binsidx_6;
            wire_binsidx[7] = in_binsidx_7;
            wire_binsidx[8] = in_binsidx_8;
            wire_binsidx[9] = in_binsidx_9;
            wire_binsidx[10] = in_binsidx_10;
            wire_binsidx[11] = in_binsidx_11;
            wire_binsidx[12] = in_binsidx_12;
            wire_binsidx[13] = in_binsidx_13;
            wire_binsidx[14] = in_binsidx_14;
            wire_binsidx[15] = in_binsidx_15;
            wire_binsidx[16] = in_binsidx_16;
            wire_binsidx[17] = in_binsidx_17;
        end
        6'd1 :
        begin
            wire_binsidx[1] = in_binsidx_0;
            wire_binsidx[2] = in_binsidx_1;
            wire_binsidx[3] = in_binsidx_2;
            wire_binsidx[4] = in_binsidx_3;
            wire_binsidx[5] = in_binsidx_4;
            wire_binsidx[6] = in_binsidx_5;
            wire_binsidx[7] = in_binsidx_6;
            wire_binsidx[8] = in_binsidx_7;
            wire_binsidx[9] = in_binsidx_8;
            wire_binsidx[10] = in_binsidx_9;
            wire_binsidx[11] = in_binsidx_10;
            wire_binsidx[12] = in_binsidx_11;
            wire_binsidx[13] = in_binsidx_12;
            wire_binsidx[14] = in_binsidx_13;
            wire_binsidx[15] = in_binsidx_14;
            wire_binsidx[16] = in_binsidx_15;
            wire_binsidx[17] = in_binsidx_16;
            wire_binsidx[18] = in_binsidx_17;
        end
        6'd2 :
        begin
            wire_binsidx[2] = in_binsidx_0;
            wire_binsidx[3] = in_binsidx_1;
            wire_binsidx[4] = in_binsidx_2;
            wire_binsidx[5] = in_binsidx_3;
            wire_binsidx[6] = in_binsidx_4;
            wire_binsidx[7] = in_binsidx_5;
            wire_binsidx[8] = in_binsidx_6;
            wire_binsidx[9] = in_binsidx_7;
            wire_binsidx[10] = in_binsidx_8;
            wire_binsidx[11] = in_binsidx_9;
            wire_binsidx[12] = in_binsidx_10;
            wire_binsidx[13] = in_binsidx_11;
            wire_binsidx[14] = in_binsidx_12;
            wire_binsidx[15] = in_binsidx_13;
            wire_binsidx[16] = in_binsidx_14;
            wire_binsidx[17] = in_binsidx_15;
            wire_binsidx[18] = in_binsidx_16;
            wire_binsidx[19] = in_binsidx_17;
        end
        6'd3 :
        begin
            wire_binsidx[3] = in_binsidx_0;
            wire_binsidx[4] = in_binsidx_1;
            wire_binsidx[5] = in_binsidx_2;
            wire_binsidx[6] = in_binsidx_3;
            wire_binsidx[7] = in_binsidx_4;
            wire_binsidx[8] = in_binsidx_5;
            wire_binsidx[9] = in_binsidx_6;
            wire_binsidx[10] = in_binsidx_7;
            wire_binsidx[11] = in_binsidx_8;
            wire_binsidx[12] = in_binsidx_9;
            wire_binsidx[13] = in_binsidx_10;
            wire_binsidx[14] = in_binsidx_11;
            wire_binsidx[15] = in_binsidx_12;
            wire_binsidx[16] = in_binsidx_13;
            wire_binsidx[17] = in_binsidx_14;
            wire_binsidx[18] = in_binsidx_15;
            wire_binsidx[19] = in_binsidx_16;
            wire_binsidx[20] = in_binsidx_17;
        end
        6'd4 :
        begin
            wire_binsidx[4] = in_binsidx_0;
            wire_binsidx[5] = in_binsidx_1;
            wire_binsidx[6] = in_binsidx_2;
            wire_binsidx[7] = in_binsidx_3;
            wire_binsidx[8] = in_binsidx_4;
            wire_binsidx[9] = in_binsidx_5;
            wire_binsidx[10] = in_binsidx_6;
            wire_binsidx[11] = in_binsidx_7;
            wire_binsidx[12] = in_binsidx_8;
            wire_binsidx[13] = in_binsidx_9;
            wire_binsidx[14] = in_binsidx_10;
            wire_binsidx[15] = in_binsidx_11;
            wire_binsidx[16] = in_binsidx_12;
            wire_binsidx[17] = in_binsidx_13;
            wire_binsidx[18] = in_binsidx_14;
            wire_binsidx[19] = in_binsidx_15;
            wire_binsidx[20] = in_binsidx_16;
            wire_binsidx[21] = in_binsidx_17;
        end
        6'd5 :
        begin
            wire_binsidx[5] = in_binsidx_0;
            wire_binsidx[6] = in_binsidx_1;
            wire_binsidx[7] = in_binsidx_2;
            wire_binsidx[8] = in_binsidx_3;
            wire_binsidx[9] = in_binsidx_4;
            wire_binsidx[10] = in_binsidx_5;
            wire_binsidx[11] = in_binsidx_6;
            wire_binsidx[12] = in_binsidx_7;
            wire_binsidx[13] = in_binsidx_8;
            wire_binsidx[14] = in_binsidx_9;
            wire_binsidx[15] = in_binsidx_10;
            wire_binsidx[16] = in_binsidx_11;
            wire_binsidx[17] = in_binsidx_12;
            wire_binsidx[18] = in_binsidx_13;
            wire_binsidx[19] = in_binsidx_14;
            wire_binsidx[20] = in_binsidx_15;
            wire_binsidx[21] = in_binsidx_16;
            wire_binsidx[22] = in_binsidx_17;
        end
        6'd6 :
        begin
            wire_binsidx[6] = in_binsidx_0;
            wire_binsidx[7] = in_binsidx_1;
            wire_binsidx[8] = in_binsidx_2;
            wire_binsidx[9] = in_binsidx_3;
            wire_binsidx[10] = in_binsidx_4;
            wire_binsidx[11] = in_binsidx_5;
            wire_binsidx[12] = in_binsidx_6;
            wire_binsidx[13] = in_binsidx_7;
            wire_binsidx[14] = in_binsidx_8;
            wire_binsidx[15] = in_binsidx_9;
            wire_binsidx[16] = in_binsidx_10;
            wire_binsidx[17] = in_binsidx_11;
            wire_binsidx[18] = in_binsidx_12;
            wire_binsidx[19] = in_binsidx_13;
            wire_binsidx[20] = in_binsidx_14;
            wire_binsidx[21] = in_binsidx_15;
            wire_binsidx[22] = in_binsidx_16;
            wire_binsidx[23] = in_binsidx_17;
        end
        6'd7 :
        begin
            wire_binsidx[7] = in_binsidx_0;
            wire_binsidx[8] = in_binsidx_1;
            wire_binsidx[9] = in_binsidx_2;
            wire_binsidx[10] = in_binsidx_3;
            wire_binsidx[11] = in_binsidx_4;
            wire_binsidx[12] = in_binsidx_5;
            wire_binsidx[13] = in_binsidx_6;
            wire_binsidx[14] = in_binsidx_7;
            wire_binsidx[15] = in_binsidx_8;
            wire_binsidx[16] = in_binsidx_9;
            wire_binsidx[17] = in_binsidx_10;
            wire_binsidx[18] = in_binsidx_11;
            wire_binsidx[19] = in_binsidx_12;
            wire_binsidx[20] = in_binsidx_13;
            wire_binsidx[21] = in_binsidx_14;
            wire_binsidx[22] = in_binsidx_15;
            wire_binsidx[23] = in_binsidx_16;
            wire_binsidx[24] = in_binsidx_17;
        end
        6'd8 :
        begin
            wire_binsidx[8] = in_binsidx_0;
            wire_binsidx[9] = in_binsidx_1;
            wire_binsidx[10] = in_binsidx_2;
            wire_binsidx[11] = in_binsidx_3;
            wire_binsidx[12] = in_binsidx_4;
            wire_binsidx[13] = in_binsidx_5;
            wire_binsidx[14] = in_binsidx_6;
            wire_binsidx[15] = in_binsidx_7;
            wire_binsidx[16] = in_binsidx_8;
            wire_binsidx[17] = in_binsidx_9;
            wire_binsidx[18] = in_binsidx_10;
            wire_binsidx[19] = in_binsidx_11;
            wire_binsidx[20] = in_binsidx_12;
            wire_binsidx[21] = in_binsidx_13;
            wire_binsidx[22] = in_binsidx_14;
            wire_binsidx[23] = in_binsidx_15;
            wire_binsidx[24] = in_binsidx_16;
            wire_binsidx[25] = in_binsidx_17;
        end
        6'd9 :
        begin
            wire_binsidx[9] = in_binsidx_0;
            wire_binsidx[10] = in_binsidx_1;
            wire_binsidx[11] = in_binsidx_2;
            wire_binsidx[12] = in_binsidx_3;
            wire_binsidx[13] = in_binsidx_4;
            wire_binsidx[14] = in_binsidx_5;
            wire_binsidx[15] = in_binsidx_6;
            wire_binsidx[16] = in_binsidx_7;
            wire_binsidx[17] = in_binsidx_8;
            wire_binsidx[18] = in_binsidx_9;
            wire_binsidx[19] = in_binsidx_10;
            wire_binsidx[20] = in_binsidx_11;
            wire_binsidx[21] = in_binsidx_12;
            wire_binsidx[22] = in_binsidx_13;
            wire_binsidx[23] = in_binsidx_14;
            wire_binsidx[24] = in_binsidx_15;
            wire_binsidx[25] = in_binsidx_16;
            wire_binsidx[26] = in_binsidx_17;
        end
        6'd10 :
        begin
            wire_binsidx[10] = in_binsidx_0;
            wire_binsidx[11] = in_binsidx_1;
            wire_binsidx[12] = in_binsidx_2;
            wire_binsidx[13] = in_binsidx_3;
            wire_binsidx[14] = in_binsidx_4;
            wire_binsidx[15] = in_binsidx_5;
            wire_binsidx[16] = in_binsidx_6;
            wire_binsidx[17] = in_binsidx_7;
            wire_binsidx[18] = in_binsidx_8;
            wire_binsidx[19] = in_binsidx_9;
            wire_binsidx[20] = in_binsidx_10;
            wire_binsidx[21] = in_binsidx_11;
            wire_binsidx[22] = in_binsidx_12;
            wire_binsidx[23] = in_binsidx_13;
            wire_binsidx[24] = in_binsidx_14;
            wire_binsidx[25] = in_binsidx_15;
            wire_binsidx[26] = in_binsidx_16;
            wire_binsidx[27] = in_binsidx_17;
        end
        6'd11 :
        begin
            wire_binsidx[11] = in_binsidx_0;
            wire_binsidx[12] = in_binsidx_1;
            wire_binsidx[13] = in_binsidx_2;
            wire_binsidx[14] = in_binsidx_3;
            wire_binsidx[15] = in_binsidx_4;
            wire_binsidx[16] = in_binsidx_5;
            wire_binsidx[17] = in_binsidx_6;
            wire_binsidx[18] = in_binsidx_7;
            wire_binsidx[19] = in_binsidx_8;
            wire_binsidx[20] = in_binsidx_9;
            wire_binsidx[21] = in_binsidx_10;
            wire_binsidx[22] = in_binsidx_11;
            wire_binsidx[23] = in_binsidx_12;
            wire_binsidx[24] = in_binsidx_13;
            wire_binsidx[25] = in_binsidx_14;
            wire_binsidx[26] = in_binsidx_15;
            wire_binsidx[27] = in_binsidx_16;
            wire_binsidx[28] = in_binsidx_17;
        end
        6'd12 :
        begin
            wire_binsidx[12] = in_binsidx_0;
            wire_binsidx[13] = in_binsidx_1;
            wire_binsidx[14] = in_binsidx_2;
            wire_binsidx[15] = in_binsidx_3;
            wire_binsidx[16] = in_binsidx_4;
            wire_binsidx[17] = in_binsidx_5;
            wire_binsidx[18] = in_binsidx_6;
            wire_binsidx[19] = in_binsidx_7;
            wire_binsidx[20] = in_binsidx_8;
            wire_binsidx[21] = in_binsidx_9;
            wire_binsidx[22] = in_binsidx_10;
            wire_binsidx[23] = in_binsidx_11;
            wire_binsidx[24] = in_binsidx_12;
            wire_binsidx[25] = in_binsidx_13;
            wire_binsidx[26] = in_binsidx_14;
            wire_binsidx[27] = in_binsidx_15;
            wire_binsidx[28] = in_binsidx_16;
            wire_binsidx[29] = in_binsidx_17;
        end
        6'd13 :
        begin
            wire_binsidx[13] = in_binsidx_0;
            wire_binsidx[14] = in_binsidx_1;
            wire_binsidx[15] = in_binsidx_2;
            wire_binsidx[16] = in_binsidx_3;
            wire_binsidx[17] = in_binsidx_4;
            wire_binsidx[18] = in_binsidx_5;
            wire_binsidx[19] = in_binsidx_6;
            wire_binsidx[20] = in_binsidx_7;
            wire_binsidx[21] = in_binsidx_8;
            wire_binsidx[22] = in_binsidx_9;
            wire_binsidx[23] = in_binsidx_10;
            wire_binsidx[24] = in_binsidx_11;
            wire_binsidx[25] = in_binsidx_12;
            wire_binsidx[26] = in_binsidx_13;
            wire_binsidx[27] = in_binsidx_14;
            wire_binsidx[28] = in_binsidx_15;
            wire_binsidx[29] = in_binsidx_16;
            wire_binsidx[30] = in_binsidx_17;
        end
        6'd14 :
        begin
            wire_binsidx[14] = in_binsidx_0;
            wire_binsidx[15] = in_binsidx_1;
            wire_binsidx[16] = in_binsidx_2;
            wire_binsidx[17] = in_binsidx_3;
            wire_binsidx[18] = in_binsidx_4;
            wire_binsidx[19] = in_binsidx_5;
            wire_binsidx[20] = in_binsidx_6;
            wire_binsidx[21] = in_binsidx_7;
            wire_binsidx[22] = in_binsidx_8;
            wire_binsidx[23] = in_binsidx_9;
            wire_binsidx[24] = in_binsidx_10;
            wire_binsidx[25] = in_binsidx_11;
            wire_binsidx[26] = in_binsidx_12;
            wire_binsidx[27] = in_binsidx_13;
            wire_binsidx[28] = in_binsidx_14;
            wire_binsidx[29] = in_binsidx_15;
            wire_binsidx[30] = in_binsidx_16;
            wire_binsidx[31] = in_binsidx_17;
        end
        6'd15 :
        begin
            wire_binsidx[15] = in_binsidx_0;
            wire_binsidx[16] = in_binsidx_1;
            wire_binsidx[17] = in_binsidx_2;
            wire_binsidx[18] = in_binsidx_3;
            wire_binsidx[19] = in_binsidx_4;
            wire_binsidx[20] = in_binsidx_5;
            wire_binsidx[21] = in_binsidx_6;
            wire_binsidx[22] = in_binsidx_7;
            wire_binsidx[23] = in_binsidx_8;
            wire_binsidx[24] = in_binsidx_9;
            wire_binsidx[25] = in_binsidx_10;
            wire_binsidx[26] = in_binsidx_11;
            wire_binsidx[27] = in_binsidx_12;
            wire_binsidx[28] = in_binsidx_13;
            wire_binsidx[29] = in_binsidx_14;
            wire_binsidx[30] = in_binsidx_15;
            wire_binsidx[31] = in_binsidx_16;
            wire_binsidx[32] = in_binsidx_17;
        end
        6'd16 :
        begin
            wire_binsidx[16] = in_binsidx_0;
            wire_binsidx[17] = in_binsidx_1;
            wire_binsidx[18] = in_binsidx_2;
            wire_binsidx[19] = in_binsidx_3;
            wire_binsidx[20] = in_binsidx_4;
            wire_binsidx[21] = in_binsidx_5;
            wire_binsidx[22] = in_binsidx_6;
            wire_binsidx[23] = in_binsidx_7;
            wire_binsidx[24] = in_binsidx_8;
            wire_binsidx[25] = in_binsidx_9;
            wire_binsidx[26] = in_binsidx_10;
            wire_binsidx[27] = in_binsidx_11;
            wire_binsidx[28] = in_binsidx_12;
            wire_binsidx[29] = in_binsidx_13;
            wire_binsidx[30] = in_binsidx_14;
            wire_binsidx[31] = in_binsidx_15;
            wire_binsidx[32] = in_binsidx_16;
            wire_binsidx[33] = in_binsidx_17;
        end
        6'd17 :
        begin
            wire_binsidx[17] = in_binsidx_0;
            wire_binsidx[18] = in_binsidx_1;
            wire_binsidx[19] = in_binsidx_2;
            wire_binsidx[20] = in_binsidx_3;
            wire_binsidx[21] = in_binsidx_4;
            wire_binsidx[22] = in_binsidx_5;
            wire_binsidx[23] = in_binsidx_6;
            wire_binsidx[24] = in_binsidx_7;
            wire_binsidx[25] = in_binsidx_8;
            wire_binsidx[26] = in_binsidx_9;
            wire_binsidx[27] = in_binsidx_10;
            wire_binsidx[28] = in_binsidx_11;
            wire_binsidx[29] = in_binsidx_12;
            wire_binsidx[30] = in_binsidx_13;
            wire_binsidx[31] = in_binsidx_14;
            wire_binsidx[32] = in_binsidx_15;
            wire_binsidx[33] = in_binsidx_16;
            wire_binsidx[34] = in_binsidx_17;
        end
        6'd18 :
        begin
            wire_binsidx[18] = in_binsidx_0;
            wire_binsidx[19] = in_binsidx_1;
            wire_binsidx[20] = in_binsidx_2;
            wire_binsidx[21] = in_binsidx_3;
            wire_binsidx[22] = in_binsidx_4;
            wire_binsidx[23] = in_binsidx_5;
            wire_binsidx[24] = in_binsidx_6;
            wire_binsidx[25] = in_binsidx_7;
            wire_binsidx[26] = in_binsidx_8;
            wire_binsidx[27] = in_binsidx_9;
            wire_binsidx[28] = in_binsidx_10;
            wire_binsidx[29] = in_binsidx_11;
            wire_binsidx[30] = in_binsidx_12;
            wire_binsidx[31] = in_binsidx_13;
            wire_binsidx[32] = in_binsidx_14;
            wire_binsidx[33] = in_binsidx_15;
            wire_binsidx[34] = in_binsidx_16;
            wire_binsidx[35] = in_binsidx_17;
        end
        6'd19 :
        begin
            wire_binsidx[19] = in_binsidx_0;
            wire_binsidx[20] = in_binsidx_1;
            wire_binsidx[21] = in_binsidx_2;
            wire_binsidx[22] = in_binsidx_3;
            wire_binsidx[23] = in_binsidx_4;
            wire_binsidx[24] = in_binsidx_5;
            wire_binsidx[25] = in_binsidx_6;
            wire_binsidx[26] = in_binsidx_7;
            wire_binsidx[27] = in_binsidx_8;
            wire_binsidx[28] = in_binsidx_9;
            wire_binsidx[29] = in_binsidx_10;
            wire_binsidx[30] = in_binsidx_11;
            wire_binsidx[31] = in_binsidx_12;
            wire_binsidx[32] = in_binsidx_13;
            wire_binsidx[33] = in_binsidx_14;
            wire_binsidx[34] = in_binsidx_15;
            wire_binsidx[35] = in_binsidx_16;
            wire_binsidx[36] = in_binsidx_17;
        end
        6'd20 :
        begin
            wire_binsidx[20] = in_binsidx_0;
            wire_binsidx[21] = in_binsidx_1;
            wire_binsidx[22] = in_binsidx_2;
            wire_binsidx[23] = in_binsidx_3;
            wire_binsidx[24] = in_binsidx_4;
            wire_binsidx[25] = in_binsidx_5;
            wire_binsidx[26] = in_binsidx_6;
            wire_binsidx[27] = in_binsidx_7;
            wire_binsidx[28] = in_binsidx_8;
            wire_binsidx[29] = in_binsidx_9;
            wire_binsidx[30] = in_binsidx_10;
            wire_binsidx[31] = in_binsidx_11;
            wire_binsidx[32] = in_binsidx_12;
            wire_binsidx[33] = in_binsidx_13;
            wire_binsidx[34] = in_binsidx_14;
            wire_binsidx[35] = in_binsidx_15;
            wire_binsidx[36] = in_binsidx_16;
            wire_binsidx[37] = in_binsidx_17;
        end
        6'd21 :
        begin
            wire_binsidx[21] = in_binsidx_0;
            wire_binsidx[22] = in_binsidx_1;
            wire_binsidx[23] = in_binsidx_2;
            wire_binsidx[24] = in_binsidx_3;
            wire_binsidx[25] = in_binsidx_4;
            wire_binsidx[26] = in_binsidx_5;
            wire_binsidx[27] = in_binsidx_6;
            wire_binsidx[28] = in_binsidx_7;
            wire_binsidx[29] = in_binsidx_8;
            wire_binsidx[30] = in_binsidx_9;
            wire_binsidx[31] = in_binsidx_10;
            wire_binsidx[32] = in_binsidx_11;
            wire_binsidx[33] = in_binsidx_12;
            wire_binsidx[34] = in_binsidx_13;
            wire_binsidx[35] = in_binsidx_14;
            wire_binsidx[36] = in_binsidx_15;
            wire_binsidx[37] = in_binsidx_16;
            wire_binsidx[38] = in_binsidx_17;
        end
        6'd22 :
        begin
            wire_binsidx[22] = in_binsidx_0;
            wire_binsidx[23] = in_binsidx_1;
            wire_binsidx[24] = in_binsidx_2;
            wire_binsidx[25] = in_binsidx_3;
            wire_binsidx[26] = in_binsidx_4;
            wire_binsidx[27] = in_binsidx_5;
            wire_binsidx[28] = in_binsidx_6;
            wire_binsidx[29] = in_binsidx_7;
            wire_binsidx[30] = in_binsidx_8;
            wire_binsidx[31] = in_binsidx_9;
            wire_binsidx[32] = in_binsidx_10;
            wire_binsidx[33] = in_binsidx_11;
            wire_binsidx[34] = in_binsidx_12;
            wire_binsidx[35] = in_binsidx_13;
            wire_binsidx[36] = in_binsidx_14;
            wire_binsidx[37] = in_binsidx_15;
            wire_binsidx[38] = in_binsidx_16;
            wire_binsidx[39] = in_binsidx_17;
        end
        6'd23 :
        begin
            wire_binsidx[23] = in_binsidx_0;
            wire_binsidx[24] = in_binsidx_1;
            wire_binsidx[25] = in_binsidx_2;
            wire_binsidx[26] = in_binsidx_3;
            wire_binsidx[27] = in_binsidx_4;
            wire_binsidx[28] = in_binsidx_5;
            wire_binsidx[29] = in_binsidx_6;
            wire_binsidx[30] = in_binsidx_7;
            wire_binsidx[31] = in_binsidx_8;
            wire_binsidx[32] = in_binsidx_9;
            wire_binsidx[33] = in_binsidx_10;
            wire_binsidx[34] = in_binsidx_11;
            wire_binsidx[35] = in_binsidx_12;
            wire_binsidx[36] = in_binsidx_13;
            wire_binsidx[37] = in_binsidx_14;
            wire_binsidx[38] = in_binsidx_15;
            wire_binsidx[39] = in_binsidx_16;
            wire_binsidx[40] = in_binsidx_17;
        end
        6'd24 :
        begin
            wire_binsidx[24] = in_binsidx_0;
            wire_binsidx[25] = in_binsidx_1;
            wire_binsidx[26] = in_binsidx_2;
            wire_binsidx[27] = in_binsidx_3;
            wire_binsidx[28] = in_binsidx_4;
            wire_binsidx[29] = in_binsidx_5;
            wire_binsidx[30] = in_binsidx_6;
            wire_binsidx[31] = in_binsidx_7;
            wire_binsidx[32] = in_binsidx_8;
            wire_binsidx[33] = in_binsidx_9;
            wire_binsidx[34] = in_binsidx_10;
            wire_binsidx[35] = in_binsidx_11;
            wire_binsidx[36] = in_binsidx_12;
            wire_binsidx[37] = in_binsidx_13;
            wire_binsidx[38] = in_binsidx_14;
            wire_binsidx[39] = in_binsidx_15;
            wire_binsidx[40] = in_binsidx_16;
            wire_binsidx[41] = in_binsidx_17;
        end
        6'd25 :
        begin
            wire_binsidx[25] = in_binsidx_0;
            wire_binsidx[26] = in_binsidx_1;
            wire_binsidx[27] = in_binsidx_2;
            wire_binsidx[28] = in_binsidx_3;
            wire_binsidx[29] = in_binsidx_4;
            wire_binsidx[30] = in_binsidx_5;
            wire_binsidx[31] = in_binsidx_6;
            wire_binsidx[32] = in_binsidx_7;
            wire_binsidx[33] = in_binsidx_8;
            wire_binsidx[34] = in_binsidx_9;
            wire_binsidx[35] = in_binsidx_10;
            wire_binsidx[36] = in_binsidx_11;
            wire_binsidx[37] = in_binsidx_12;
            wire_binsidx[38] = in_binsidx_13;
            wire_binsidx[39] = in_binsidx_14;
            wire_binsidx[40] = in_binsidx_15;
            wire_binsidx[41] = in_binsidx_16;
            wire_binsidx[42] = in_binsidx_17;
        end
        6'd26 :
        begin
            wire_binsidx[26] = in_binsidx_0;
            wire_binsidx[27] = in_binsidx_1;
            wire_binsidx[28] = in_binsidx_2;
            wire_binsidx[29] = in_binsidx_3;
            wire_binsidx[30] = in_binsidx_4;
            wire_binsidx[31] = in_binsidx_5;
            wire_binsidx[32] = in_binsidx_6;
            wire_binsidx[33] = in_binsidx_7;
            wire_binsidx[34] = in_binsidx_8;
            wire_binsidx[35] = in_binsidx_9;
            wire_binsidx[36] = in_binsidx_10;
            wire_binsidx[37] = in_binsidx_11;
            wire_binsidx[38] = in_binsidx_12;
            wire_binsidx[39] = in_binsidx_13;
            wire_binsidx[40] = in_binsidx_14;
            wire_binsidx[41] = in_binsidx_15;
            wire_binsidx[42] = in_binsidx_16;
            wire_binsidx[43] = in_binsidx_17;
        end
        6'd27 :
        begin
            wire_binsidx[27] = in_binsidx_0;
            wire_binsidx[28] = in_binsidx_1;
            wire_binsidx[29] = in_binsidx_2;
            wire_binsidx[30] = in_binsidx_3;
            wire_binsidx[31] = in_binsidx_4;
            wire_binsidx[32] = in_binsidx_5;
            wire_binsidx[33] = in_binsidx_6;
            wire_binsidx[34] = in_binsidx_7;
            wire_binsidx[35] = in_binsidx_8;
            wire_binsidx[36] = in_binsidx_9;
            wire_binsidx[37] = in_binsidx_10;
            wire_binsidx[38] = in_binsidx_11;
            wire_binsidx[39] = in_binsidx_12;
            wire_binsidx[40] = in_binsidx_13;
            wire_binsidx[41] = in_binsidx_14;
            wire_binsidx[42] = in_binsidx_15;
            wire_binsidx[43] = in_binsidx_16;
            wire_binsidx[44] = in_binsidx_17;
        end
        6'd28 :
        begin
            wire_binsidx[28] = in_binsidx_0;
            wire_binsidx[29] = in_binsidx_1;
            wire_binsidx[30] = in_binsidx_2;
            wire_binsidx[31] = in_binsidx_3;
            wire_binsidx[32] = in_binsidx_4;
            wire_binsidx[33] = in_binsidx_5;
            wire_binsidx[34] = in_binsidx_6;
            wire_binsidx[35] = in_binsidx_7;
            wire_binsidx[36] = in_binsidx_8;
            wire_binsidx[37] = in_binsidx_9;
            wire_binsidx[38] = in_binsidx_10;
            wire_binsidx[39] = in_binsidx_11;
            wire_binsidx[40] = in_binsidx_12;
            wire_binsidx[41] = in_binsidx_13;
            wire_binsidx[42] = in_binsidx_14;
            wire_binsidx[43] = in_binsidx_15;
            wire_binsidx[44] = in_binsidx_16;
            wire_binsidx[45] = in_binsidx_17;
        end
        6'd29 :
        begin
            wire_binsidx[29] = in_binsidx_0;
            wire_binsidx[30] = in_binsidx_1;
            wire_binsidx[31] = in_binsidx_2;
            wire_binsidx[32] = in_binsidx_3;
            wire_binsidx[33] = in_binsidx_4;
            wire_binsidx[34] = in_binsidx_5;
            wire_binsidx[35] = in_binsidx_6;
            wire_binsidx[36] = in_binsidx_7;
            wire_binsidx[37] = in_binsidx_8;
            wire_binsidx[38] = in_binsidx_9;
            wire_binsidx[39] = in_binsidx_10;
            wire_binsidx[40] = in_binsidx_11;
            wire_binsidx[41] = in_binsidx_12;
            wire_binsidx[42] = in_binsidx_13;
            wire_binsidx[43] = in_binsidx_14;
            wire_binsidx[44] = in_binsidx_15;
            wire_binsidx[45] = in_binsidx_16;
            wire_binsidx[46] = in_binsidx_17;
        end
        6'd30 :
        begin
            wire_binsidx[30] = in_binsidx_0;
            wire_binsidx[31] = in_binsidx_1;
            wire_binsidx[32] = in_binsidx_2;
            wire_binsidx[33] = in_binsidx_3;
            wire_binsidx[34] = in_binsidx_4;
            wire_binsidx[35] = in_binsidx_5;
            wire_binsidx[36] = in_binsidx_6;
            wire_binsidx[37] = in_binsidx_7;
            wire_binsidx[38] = in_binsidx_8;
            wire_binsidx[39] = in_binsidx_9;
            wire_binsidx[40] = in_binsidx_10;
            wire_binsidx[41] = in_binsidx_11;
            wire_binsidx[42] = in_binsidx_12;
            wire_binsidx[43] = in_binsidx_13;
            wire_binsidx[44] = in_binsidx_14;
            wire_binsidx[45] = in_binsidx_15;
            wire_binsidx[46] = in_binsidx_16;
            wire_binsidx[47] = in_binsidx_17;
        end
        6'd31 :
        begin
            wire_binsidx[31] = in_binsidx_0;
            wire_binsidx[32] = in_binsidx_1;
            wire_binsidx[33] = in_binsidx_2;
            wire_binsidx[34] = in_binsidx_3;
            wire_binsidx[35] = in_binsidx_4;
            wire_binsidx[36] = in_binsidx_5;
            wire_binsidx[37] = in_binsidx_6;
            wire_binsidx[38] = in_binsidx_7;
            wire_binsidx[39] = in_binsidx_8;
            wire_binsidx[40] = in_binsidx_9;
            wire_binsidx[41] = in_binsidx_10;
            wire_binsidx[42] = in_binsidx_11;
            wire_binsidx[43] = in_binsidx_12;
            wire_binsidx[44] = in_binsidx_13;
            wire_binsidx[45] = in_binsidx_14;
            wire_binsidx[46] = in_binsidx_15;
            wire_binsidx[47] = in_binsidx_16;
            wire_binsidx[48] = in_binsidx_17;
        end
        6'd32 :
        begin
            wire_binsidx[32] = in_binsidx_0;
            wire_binsidx[33] = in_binsidx_1;
            wire_binsidx[34] = in_binsidx_2;
            wire_binsidx[35] = in_binsidx_3;
            wire_binsidx[36] = in_binsidx_4;
            wire_binsidx[37] = in_binsidx_5;
            wire_binsidx[38] = in_binsidx_6;
            wire_binsidx[39] = in_binsidx_7;
            wire_binsidx[40] = in_binsidx_8;
            wire_binsidx[41] = in_binsidx_9;
            wire_binsidx[42] = in_binsidx_10;
            wire_binsidx[43] = in_binsidx_11;
            wire_binsidx[44] = in_binsidx_12;
            wire_binsidx[45] = in_binsidx_13;
            wire_binsidx[46] = in_binsidx_14;
            wire_binsidx[47] = in_binsidx_15;
            wire_binsidx[48] = in_binsidx_16;
            wire_binsidx[49] = in_binsidx_17;
        end
        6'd33 :
        begin
            wire_binsidx[33] = in_binsidx_0;
            wire_binsidx[34] = in_binsidx_1;
            wire_binsidx[35] = in_binsidx_2;
            wire_binsidx[36] = in_binsidx_3;
            wire_binsidx[37] = in_binsidx_4;
            wire_binsidx[38] = in_binsidx_5;
            wire_binsidx[39] = in_binsidx_6;
            wire_binsidx[40] = in_binsidx_7;
            wire_binsidx[41] = in_binsidx_8;
            wire_binsidx[42] = in_binsidx_9;
            wire_binsidx[43] = in_binsidx_10;
            wire_binsidx[44] = in_binsidx_11;
            wire_binsidx[45] = in_binsidx_12;
            wire_binsidx[46] = in_binsidx_13;
            wire_binsidx[47] = in_binsidx_14;
            wire_binsidx[48] = in_binsidx_15;
            wire_binsidx[49] = in_binsidx_16;
        end
        6'd34 :
        begin
            wire_binsidx[34] = in_binsidx_0;
            wire_binsidx[35] = in_binsidx_1;
            wire_binsidx[36] = in_binsidx_2;
            wire_binsidx[37] = in_binsidx_3;
            wire_binsidx[38] = in_binsidx_4;
            wire_binsidx[39] = in_binsidx_5;
            wire_binsidx[40] = in_binsidx_6;
            wire_binsidx[41] = in_binsidx_7;
            wire_binsidx[42] = in_binsidx_8;
            wire_binsidx[43] = in_binsidx_9;
            wire_binsidx[44] = in_binsidx_10;
            wire_binsidx[45] = in_binsidx_11;
            wire_binsidx[46] = in_binsidx_12;
            wire_binsidx[47] = in_binsidx_13;
            wire_binsidx[48] = in_binsidx_14;
            wire_binsidx[49] = in_binsidx_15;
        end
        6'd35 :
        begin
            wire_binsidx[35] = in_binsidx_0;
            wire_binsidx[36] = in_binsidx_1;
            wire_binsidx[37] = in_binsidx_2;
            wire_binsidx[38] = in_binsidx_3;
            wire_binsidx[39] = in_binsidx_4;
            wire_binsidx[40] = in_binsidx_5;
            wire_binsidx[41] = in_binsidx_6;
            wire_binsidx[42] = in_binsidx_7;
            wire_binsidx[43] = in_binsidx_8;
            wire_binsidx[44] = in_binsidx_9;
            wire_binsidx[45] = in_binsidx_10;
            wire_binsidx[46] = in_binsidx_11;
            wire_binsidx[47] = in_binsidx_12;
            wire_binsidx[48] = in_binsidx_13;
            wire_binsidx[49] = in_binsidx_14;
        end
        6'd36 :
        begin
            wire_binsidx[36] = in_binsidx_0;
            wire_binsidx[37] = in_binsidx_1;
            wire_binsidx[38] = in_binsidx_2;
            wire_binsidx[39] = in_binsidx_3;
            wire_binsidx[40] = in_binsidx_4;
            wire_binsidx[41] = in_binsidx_5;
            wire_binsidx[42] = in_binsidx_6;
            wire_binsidx[43] = in_binsidx_7;
            wire_binsidx[44] = in_binsidx_8;
            wire_binsidx[45] = in_binsidx_9;
            wire_binsidx[46] = in_binsidx_10;
            wire_binsidx[47] = in_binsidx_11;
            wire_binsidx[48] = in_binsidx_12;
            wire_binsidx[49] = in_binsidx_13;
        end
        6'd37 :
        begin
            wire_binsidx[37] = in_binsidx_0;
            wire_binsidx[38] = in_binsidx_1;
            wire_binsidx[39] = in_binsidx_2;
            wire_binsidx[40] = in_binsidx_3;
            wire_binsidx[41] = in_binsidx_4;
            wire_binsidx[42] = in_binsidx_5;
            wire_binsidx[43] = in_binsidx_6;
            wire_binsidx[44] = in_binsidx_7;
            wire_binsidx[45] = in_binsidx_8;
            wire_binsidx[46] = in_binsidx_9;
            wire_binsidx[47] = in_binsidx_10;
            wire_binsidx[48] = in_binsidx_11;
            wire_binsidx[49] = in_binsidx_12;
        end
        6'd38 :
        begin
            wire_binsidx[38] = in_binsidx_0;
            wire_binsidx[39] = in_binsidx_1;
            wire_binsidx[40] = in_binsidx_2;
            wire_binsidx[41] = in_binsidx_3;
            wire_binsidx[42] = in_binsidx_4;
            wire_binsidx[43] = in_binsidx_5;
            wire_binsidx[44] = in_binsidx_6;
            wire_binsidx[45] = in_binsidx_7;
            wire_binsidx[46] = in_binsidx_8;
            wire_binsidx[47] = in_binsidx_9;
            wire_binsidx[48] = in_binsidx_10;
            wire_binsidx[49] = in_binsidx_11;
        end
        6'd39 :
        begin
            wire_binsidx[39] = in_binsidx_0;
            wire_binsidx[40] = in_binsidx_1;
            wire_binsidx[41] = in_binsidx_2;
            wire_binsidx[42] = in_binsidx_3;
            wire_binsidx[43] = in_binsidx_4;
            wire_binsidx[44] = in_binsidx_5;
            wire_binsidx[45] = in_binsidx_6;
            wire_binsidx[46] = in_binsidx_7;
            wire_binsidx[47] = in_binsidx_8;
            wire_binsidx[48] = in_binsidx_9;
            wire_binsidx[49] = in_binsidx_10;
        end
        6'd40 :
        begin
            wire_binsidx[40] = in_binsidx_0;
            wire_binsidx[41] = in_binsidx_1;
            wire_binsidx[42] = in_binsidx_2;
            wire_binsidx[43] = in_binsidx_3;
            wire_binsidx[44] = in_binsidx_4;
            wire_binsidx[45] = in_binsidx_5;
            wire_binsidx[46] = in_binsidx_6;
            wire_binsidx[47] = in_binsidx_7;
            wire_binsidx[48] = in_binsidx_8;
            wire_binsidx[49] = in_binsidx_9;
        end
        6'd41 :
        begin
            wire_binsidx[41] = in_binsidx_0;
            wire_binsidx[42] = in_binsidx_1;
            wire_binsidx[43] = in_binsidx_2;
            wire_binsidx[44] = in_binsidx_3;
            wire_binsidx[45] = in_binsidx_4;
            wire_binsidx[46] = in_binsidx_5;
            wire_binsidx[47] = in_binsidx_6;
            wire_binsidx[48] = in_binsidx_7;
            wire_binsidx[49] = in_binsidx_8;
        end
        6'd42 :
        begin
            wire_binsidx[42] = in_binsidx_0;
            wire_binsidx[43] = in_binsidx_1;
            wire_binsidx[44] = in_binsidx_2;
            wire_binsidx[45] = in_binsidx_3;
            wire_binsidx[46] = in_binsidx_4;
            wire_binsidx[47] = in_binsidx_5;
            wire_binsidx[48] = in_binsidx_6;
            wire_binsidx[49] = in_binsidx_7;
        end
        6'd43 :
        begin
            wire_binsidx[43] = in_binsidx_0;
            wire_binsidx[44] = in_binsidx_1;
            wire_binsidx[45] = in_binsidx_2;
            wire_binsidx[46] = in_binsidx_3;
            wire_binsidx[47] = in_binsidx_4;
            wire_binsidx[48] = in_binsidx_5;
            wire_binsidx[49] = in_binsidx_6;
        end
        6'd44 :
        begin
            wire_binsidx[44] = in_binsidx_0;
            wire_binsidx[45] = in_binsidx_1;
            wire_binsidx[46] = in_binsidx_2;
            wire_binsidx[47] = in_binsidx_3;
            wire_binsidx[48] = in_binsidx_4;
            wire_binsidx[49] = in_binsidx_5;
        end
        6'd45 :
        begin
            wire_binsidx[45] = in_binsidx_0;
            wire_binsidx[46] = in_binsidx_1;
            wire_binsidx[47] = in_binsidx_2;
            wire_binsidx[48] = in_binsidx_3;
            wire_binsidx[49] = in_binsidx_4;
        end
        6'd46 :
        begin
            wire_binsidx[46] = in_binsidx_0;
            wire_binsidx[47] = in_binsidx_1;
            wire_binsidx[48] = in_binsidx_2;
            wire_binsidx[49] = in_binsidx_3;
        end
        6'd47 :
        begin
            wire_binsidx[47] = in_binsidx_0;
            wire_binsidx[48] = in_binsidx_1;
            wire_binsidx[49] = in_binsidx_2;
        end
        6'd48 :
        begin
            wire_binsidx[48] = in_binsidx_0;
            wire_binsidx[49] = in_binsidx_1;
        end
        6'd49 :
        begin
            wire_binsidx[49] = in_binsidx_0;
        end
        default:
        begin
            wire_binsidx[0] = in_binsidx_0;
            wire_binsidx[1] = in_binsidx_1;
            wire_binsidx[2] = in_binsidx_2;
            wire_binsidx[3] = in_binsidx_3;
            wire_binsidx[4] = in_binsidx_4;
            wire_binsidx[5] = in_binsidx_5;
            wire_binsidx[6] = in_binsidx_6;
            wire_binsidx[7] = in_binsidx_7;
            wire_binsidx[8] = in_binsidx_8;
            wire_binsidx[9] = in_binsidx_9;
            wire_binsidx[10] = in_binsidx_10;
            wire_binsidx[11] = in_binsidx_11;
            wire_binsidx[12] = in_binsidx_12;
            wire_binsidx[13] = in_binsidx_13;
            wire_binsidx[14] = in_binsidx_14;
            wire_binsidx[15] = in_binsidx_15;
            wire_binsidx[16] = in_binsidx_16;
            wire_binsidx[17] = in_binsidx_17;
        end
    endcase
end
//---------------------------------------------------//


//-------------------- output -----------------------//
assign free_space = 6'd50 - wire_used_space;
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        out_number_all <= 0;
        out_number_range <= 0;
        out_index_bypass <= 0;
        out_symbol_bypass <= 0;
    end
    else if(!en)
    begin
        //free_space <= 50;
        out_number_all <= 0;
        out_number_range <= 0;
        out_index_bypass <= 0;
        out_symbol_bypass <= 0;
    end
    else
    begin
        if(w_enable)
        begin
            out_number_all <= wire_out_number_all;
            out_number_range <= wire_out_number_range;
            out_index_bypass <= ~regular_flag;
            out_symbol_bypass <= {binsidx[0][9],binsidx[1][9],binsidx[2][9],binsidx[3][9],binsidx[4][9],binsidx[5][9],binsidx[6][9],binsidx[7][9]};
            out_binsidx_0 <= wire_out_number_range > 0 ? wire_out_binsidx_0 : 187;
            out_binsidx_1 <= wire_out_number_range > 1 ? wire_out_binsidx_1 : 187;
            out_binsidx_2 <= wire_out_number_range > 2 ? wire_out_binsidx_2 : 187;
            out_binsidx_3 <= wire_out_number_range > 3 ? wire_out_binsidx_3 : 187;
        end
    end
end
//---------------------------------------------------//

endmodule