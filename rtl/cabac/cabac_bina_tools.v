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
// Filename       : cabac_bina_tools.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : shift and first1 check tools
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------


// first 1 checker
module cabac_bina_FC(
           in,
           pos
       );

input  [15:0]    in;
output [4:0]     pos;
reg    [4:0]     pos;
always @ (*)
begin
    casex (in)
        16'b1xxxxxxxxxxxxxxx:
            pos = 15;
        16'b01xxxxxxxxxxxxxx:
            pos = 14;
        16'b001xxxxxxxxxxxxx:
            pos = 13;
        16'b0001xxxxxxxxxxxx:
            pos = 12;
        16'b00001xxxxxxxxxxx:
            pos = 11;
        16'b000001xxxxxxxxxx:
            pos = 10;
        16'b0000001xxxxxxxxx:
            pos = 9;
        16'b00000001xxxxxxxx:
            pos = 8;
        16'b000000001xxxxxxx:
            pos = 7;
        16'b0000000001xxxxxx:
            pos = 6;
        16'b00000000001xxxxx:
            pos = 5;
        16'b000000000001xxxx:
            pos = 4;
        16'b0000000000001xxx:
            pos = 3;
        16'b00000000000001xx:
            pos = 2;
        16'b000000000000001x:
            pos = 1;
        default:
            pos = 0;
    endcase
end
endmodule



    // barrel shift.

    module cabac_bina_BSleft(
        in,
        left,
        out
    );

input  [17:0]    in;
input  [4:0]     left;
output [17:0]    out;

wire   [17:0]    s0, s1, s2, s3;
wire   [17:0]    out;

assign s0 = left[0] ? {in[16:0], 1'b0} : in[17:0];
assign s1 = left[1] ? {s0[15:0], 2'b0} : s0[17:0];
assign s2 = left[2] ? {s1[13:0], 4'b0} : s1[17:0];
assign s3 = left[3] ? {s2[9:0],  8'b0} : s2[17:0];
assign out = left[4] ? {s3[1:0], 16'b0} : s3[17:0];
endmodule


    module cabac_bina_BSright(
        in,
        right,
        out
    );

input  [4:0]     right;
input  [17:0]    in;
output [17:0]    out;

wire   [17:0]    s0, s1, s2, s3;
wire   [17:0]    out;

assign s0 = right[0] ? {1'b0, in[17:1]} : in[17:0];
assign s1 = right[1] ? {2'b0, s0[17:2]} : s0[17:0];
assign s2 = right[2] ? {4'b0, s1[17:4]} : s1[17:0];
assign s3 = right[3] ? {8'b0, s2[17:8]} : s2[17:0];
assign out = right[4] ? {16'b0, s3[17:16]} : s3[17:0];
endmodule


    module cabac_bina_BS1sleft(
        in,
        left,
        out
    );
input  [161:0]   in;
input  [4:0]     left;  //every time left 9 bits.
output [161:0]   out;
wire   [161:0]   out;
wire   [161:0]   s0, s1, s2, s3;
assign s0 = left[0] ? {in[153:0], 9'd0} : in[161:0];
assign s1 = left[1] ? {s0[143:0],  18'd0} : s0[161:0];
assign s2 = left[2] ? {s1[125:0],  36'b0} : s1[161:0];
assign s3 = left[3] ? {s2[89:0],   72'b0} : s2[161:0];
assign out = left[4] ? {s3[17:0],  144'b0} : s3[161:0];
endmodule

    module cabac_bina_BS1sright(
        in,
        right,
        out
    );
input  [161:0]   in;
input  [4:0]     right;  //every time left 9 bits.
output [161:0]   out;
wire   [161:0]   out;

wire   [161:0]   s0, s1, s2, s3;
assign s0 = right[0] ? {9'd0, in[161:9]} : in[161:0];
assign s1 = right[1] ? {18'd0, s0[161:18]} : s0[161:0];
assign s2 = right[2] ? {36'd0, s1[161:36]} : s1[161:0];
assign s3 = right[3] ? {72'd0, s2[161:72]} : s2[161:0];
assign out = right[4] ? {144'd0, s3[161:144]} : s3[161:0];
endmodule





