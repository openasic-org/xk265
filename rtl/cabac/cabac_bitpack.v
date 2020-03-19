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
// Filename       : cabac_bitpack.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : pack bit stream and output
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------

module cabac_bitpack(
           clk,
           r_enable,
           en,
           rst_n,

           in_end_slice,

           left_space,

           length,
           flag_flow,
           string_to_update,
           zero_position,

           out_ready,
           output_byte
       );

parameter   BUFFER_BIT                    =     32;

//input and output signals //{
input                   clk;
input                   r_enable;         //1 to enable
input                   en;         //0 to reset
input               rst_n;

input                   in_end_slice;

output      wire[6:0]   left_space;


input       [5:0] length;
input                   flag_flow;
input       [34:0]      string_to_update;
input       [5:0] zero_position;

output      wire        out_ready;
output      wire[7:0]   output_byte;
//}


// synposys translate_off

//memory //{
reg               [127:0]     mem;
wire        [127:0]     wire_mem_1;             //wire_mem_1 = in_flag_flow ? {mem[127:index], ~[index-1:0]} : mem;
reg               [127:0]     wire_mem_2;
wire        [127:0]     wire_mem_3;

reg               [6:0] index_0;
reg               [6:0] index;
reg               [6:0] wire_index;
reg               [6:0] wire_index_0;
//}

//signals //{
wire        [5:0] in_length;        //0-35
wire                    in_flag_flow;

wire        [127:0]     signal_6;
wire        [127:0]     signal_5;
wire        [127:0]     signal_4;
wire        [127:0]     signal_3;
wire        [127:0]     signal_2;
wire        [127:0]     signal_1;
wire        [127:0]     signal_0;

wire                    wire_out_ready;
//}

//reg logics //{
always @(posedge clk or negedge rst_n)    //index_0
begin
    if(!rst_n)
        index_0 <= 127;
    else if(!en)
        index_0         <=    127;
    else
        index_0         <=    wire_index_0;
end
always @(*)                   //wire_index_0
begin
    if((zero_position!=0 || in_flag_flow)&&r_enable)
        wire_index_0    =     wire_out_ready ? index-zero_position+8+1 : index-zero_position+1;
    else
        wire_index_0    =     wire_out_ready ? index_0+8 : index_0;
end

always @(posedge clk or negedge rst_n)          //index
begin
    if(!rst_n)
        index <= 127;
    else if(!en)
        index           <=    127;
    else
        index           <=    wire_index;
end
always @(*)                   //wire_index
begin
    wire_index =  wire_out_ready ? index-in_length+8 : index-in_length;
end

assign      wire_mem_1  =     in_flag_flow&&r_enable ? mem^signal_0 : mem;

always @(*) //wire_mem_2
begin
    wire_mem_2 = wire_mem_1;
    if(r_enable)
    begin
        case (index)
            7'd127 :
            begin
                wire_mem_2[127:93] = {string_to_update};
            end
            7'd126 :
            begin
                wire_mem_2[126:92] = {string_to_update};
            end
            7'd125 :
            begin
                wire_mem_2[125:91] = {string_to_update};
            end
            7'd124 :
            begin
                wire_mem_2[124:90] = {string_to_update};
            end
            7'd123 :
            begin
                wire_mem_2[123:89] = {string_to_update};
            end
            7'd122 :
            begin
                wire_mem_2[122:88] = {string_to_update};
            end
            7'd121 :
            begin
                wire_mem_2[121:87] = {string_to_update};
            end
            7'd120 :
            begin
                wire_mem_2[120:86] = {string_to_update};
            end
            7'd119 :
            begin
                wire_mem_2[119:85] = {string_to_update};
            end
            7'd118 :
            begin
                wire_mem_2[118:84] = {string_to_update};
            end
            7'd117 :
            begin
                wire_mem_2[117:83] = {string_to_update};
            end
            7'd116 :
            begin
                wire_mem_2[116:82] = {string_to_update};
            end
            7'd115 :
            begin
                wire_mem_2[115:81] = {string_to_update};
            end
            7'd114 :
            begin
                wire_mem_2[114:80] = {string_to_update};
            end
            7'd113 :
            begin
                wire_mem_2[113:79] = {string_to_update};
            end
            7'd112 :
            begin
                wire_mem_2[112:78] = {string_to_update};
            end
            7'd111 :
            begin
                wire_mem_2[111:77] = {string_to_update};
            end
            7'd110 :
            begin
                wire_mem_2[110:76] = {string_to_update};
            end
            7'd109 :
            begin
                wire_mem_2[109:75] = {string_to_update};
            end
            7'd108 :
            begin
                wire_mem_2[108:74] = {string_to_update};
            end
            7'd107 :
            begin
                wire_mem_2[107:73] = {string_to_update};
            end
            7'd106 :
            begin
                wire_mem_2[106:72] = {string_to_update};
            end
            7'd105 :
            begin
                wire_mem_2[105:71] = {string_to_update};
            end
            7'd104 :
            begin
                wire_mem_2[104:70] = {string_to_update};
            end
            7'd103 :
            begin
                wire_mem_2[103:69] = {string_to_update};
            end
            7'd102 :
            begin
                wire_mem_2[102:68] = {string_to_update};
            end
            7'd101 :
            begin
                wire_mem_2[101:67] = {string_to_update};
            end
            7'd100 :
            begin
                wire_mem_2[100:66] = {string_to_update};
            end
            7'd99 :
            begin
                wire_mem_2[99:65] = {string_to_update};
            end
            7'd98 :
            begin
                wire_mem_2[98:64] = {string_to_update};
            end
            7'd97 :
            begin
                wire_mem_2[97:63] = {string_to_update};
            end
            7'd96 :
            begin
                wire_mem_2[96:62] = {string_to_update};
            end
            7'd95 :
            begin
                wire_mem_2[95:61] = {string_to_update};
            end
            7'd94 :
            begin
                wire_mem_2[94:60] = {string_to_update};
            end
            7'd93 :
            begin
                wire_mem_2[93:59] = {string_to_update};
            end
            7'd92 :
            begin
                wire_mem_2[92:58] = {string_to_update};
            end
            7'd91 :
            begin
                wire_mem_2[91:57] = {string_to_update};
            end
            7'd90 :
            begin
                wire_mem_2[90:56] = {string_to_update};
            end
            7'd89 :
            begin
                wire_mem_2[89:55] = {string_to_update};
            end
            7'd88 :
            begin
                wire_mem_2[88:54] = {string_to_update};
            end
            7'd87 :
            begin
                wire_mem_2[87:53] = {string_to_update};
            end
            7'd86 :
            begin
                wire_mem_2[86:52] = {string_to_update};
            end
            7'd85 :
            begin
                wire_mem_2[85:51] = {string_to_update};
            end
            7'd84 :
            begin
                wire_mem_2[84:50] = {string_to_update};
            end
            7'd83 :
            begin
                wire_mem_2[83:49] = {string_to_update};
            end
            7'd82 :
            begin
                wire_mem_2[82:48] = {string_to_update};
            end
            7'd81 :
            begin
                wire_mem_2[81:47] = {string_to_update};
            end
            7'd80 :
            begin
                wire_mem_2[80:46] = {string_to_update};
            end
            7'd79 :
            begin
                wire_mem_2[79:45] = {string_to_update};
            end
            7'd78 :
            begin
                wire_mem_2[78:44] = {string_to_update};
            end
            7'd77 :
            begin
                wire_mem_2[77:43] = {string_to_update};
            end
            7'd76 :
            begin
                wire_mem_2[76:42] = {string_to_update};
            end
            7'd75 :
            begin
                wire_mem_2[75:41] = {string_to_update};
            end
            7'd74 :
            begin
                wire_mem_2[74:40] = {string_to_update};
            end
            7'd73 :
            begin
                wire_mem_2[73:39] = {string_to_update};
            end
            7'd72 :
            begin
                wire_mem_2[72:38] = {string_to_update};
            end
            7'd71 :
            begin
                wire_mem_2[71:37] = {string_to_update};
            end
            7'd70 :
            begin
                wire_mem_2[70:36] = {string_to_update};
            end
            7'd69 :
            begin
                wire_mem_2[69:35] = {string_to_update};
            end
            7'd68 :
            begin
                wire_mem_2[68:34] = {string_to_update};
            end
            7'd67 :
            begin
                wire_mem_2[67:33] = {string_to_update};
            end
            7'd66 :
            begin
                wire_mem_2[66:32] = {string_to_update};
            end
            7'd65 :
            begin
                wire_mem_2[65:31] = {string_to_update};
            end
            7'd64 :
            begin
                wire_mem_2[64:30] = {string_to_update};
            end
            7'd63 :
            begin
                wire_mem_2[63:29] = {string_to_update};
            end
            7'd62 :
            begin
                wire_mem_2[62:28] = {string_to_update};
            end
            7'd61 :
            begin
                wire_mem_2[61:27] = {string_to_update};
            end
            7'd60 :
            begin
                wire_mem_2[60:26] = {string_to_update};
            end
            7'd59 :
            begin
                wire_mem_2[59:25] = {string_to_update};
            end
            7'd58 :
            begin
                wire_mem_2[58:24] = {string_to_update};
            end
            7'd57 :
            begin
                wire_mem_2[57:23] = {string_to_update};
            end
            7'd56 :
            begin
                wire_mem_2[56:22] = {string_to_update};
            end
            7'd55 :
            begin
                wire_mem_2[55:21] = {string_to_update};
            end
            7'd54 :
            begin
                wire_mem_2[54:20] = {string_to_update};
            end
            7'd53 :
            begin
                wire_mem_2[53:19] = {string_to_update};
            end
            7'd52 :
            begin
                wire_mem_2[52:18] = {string_to_update};
            end
            7'd51 :
            begin
                wire_mem_2[51:17] = {string_to_update};
            end
            7'd50 :
            begin
                wire_mem_2[50:16] = {string_to_update};
            end
            7'd49 :
            begin
                wire_mem_2[49:15] = {string_to_update};
            end
            7'd48 :
            begin
                wire_mem_2[48:14] = {string_to_update};
            end
            7'd47 :
            begin
                wire_mem_2[47:13] = {string_to_update};
            end
            7'd46 :
            begin
                wire_mem_2[46:12] = {string_to_update};
            end
            7'd45 :
            begin
                wire_mem_2[45:11] = {string_to_update};
            end
            7'd44 :
            begin
                wire_mem_2[44:10] = {string_to_update};
            end
            7'd43 :
            begin
                wire_mem_2[43:9] = {string_to_update};
            end
            7'd42 :
            begin
                wire_mem_2[42:8] = {string_to_update};
            end
            7'd41 :
            begin
                wire_mem_2[41:7] = {string_to_update};
            end
            7'd40 :
            begin
                wire_mem_2[40:6] = {string_to_update};
            end
            7'd39 :
            begin
                wire_mem_2[39:5] = {string_to_update};
            end
            7'd38 :
            begin
                wire_mem_2[38:4] = {string_to_update};
            end
            7'd37 :
            begin
                wire_mem_2[37:3] = {string_to_update};
            end
            7'd36 :
            begin
                wire_mem_2[36:2] = {string_to_update};
            end
            7'd35 :
            begin
                wire_mem_2[35:1] = {string_to_update};
            end
            7'd34 :
            begin
                wire_mem_2[34:0] = {string_to_update};
            end
            default:
            begin
                wire_mem_2 = wire_mem_1;
            end
        endcase
    end
end

assign      wire_mem_3 = wire_out_ready ? {wire_mem_2[119:0], 8'b11111111} : wire_mem_2;

always @(posedge clk) //mem
begin
    mem <= wire_mem_3;
end
//}

//wire logics //{
assign      in_length         =     r_enable ? length       :     0;
assign      in_flag_flow      =     r_enable ? flag_flow    :     0;

assign      signal_6          =     index_0[6] ? 128'hffffffffffffffffffffffffffffffff : 128'h0000000000000000ffffffffffffffff;
assign      signal_5          =     index_0[5] ? signal_6 : {32'b0, signal_6[127:32]};
assign      signal_4          =     index_0[4] ? signal_5 : {16'b0, signal_5[127:16]};
assign      signal_3          =     index_0[3] ? signal_4 : {8'b0, signal_4[127:8]};
assign      signal_2          =     index_0[2] ? signal_3 : {4'b0, signal_3[127:4]};
assign      signal_1          =     index_0[1] ? signal_2 : {2'b0, signal_2[127:2]};
assign      signal_0          =     index_0[0] ? signal_1 : {1'b0, signal_1[127:1]};

assign      left_space              =     index;
assign      wire_out_ready          =     (!in_end_slice && index_0<=119) || (in_end_slice && index<=119);
assign      out_ready               =     wire_out_ready;
assign      output_byte             =     mem[127:120];
//}

// synposys translate_on
endmodule
