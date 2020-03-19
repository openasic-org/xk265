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
// Filename       : cabac_rlps4_1bin.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : update range
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------

module cabac_rlps4_1bin(
           pstateidx,
           four_rlps,
           four_rlps_shift
       );

//input and output signals //{
input       [5:0]   pstateidx;
output  wire[31:0]  four_rlps;
//[31:24]   rlps_0
//[23:16]   rlps_1
//[15:8]    rlps_2
//[7:0]     rlps_3
output  wire[43:0]  four_rlps_shift;
//[43:41]   shift_rlps_0 // shift left
//[40:33]   rlps_shift_0 // number of shift bits.
//[32:30]   shift_rlps_1
//[29:22]   rlps_shift_1
//[21:19]   shift_rlps_2
//[18:11]   rlps_shift_2
//[10:8]    shift_rlps_3
//[7:0]     rlps_shift_3
//}

//wire signal //{
reg     [31:0]  reg_four_rlps; // according to pstate_idx, get four rlps
wire    [7:0]   rlps_0;
wire    [7:0]   rlps_1;
wire    [7:0]   rlps_2;
wire    [7:0]   rlps_3;

reg     [2:0]   shift_rlps_0;
reg     [2:0]   shift_rlps_1;
reg     [2:0]   shift_rlps_2;
reg     [2:0]   shift_rlps_3;

reg     [7:0]   rlps_shift_0;
reg     [7:0]   rlps_shift_1;
reg     [7:0]   rlps_shift_2;
reg     [7:0]   rlps_shift_3;
//}

//wire logic //{
always @(*) //reg_four_rlps
begin
    reg_four_rlps = 32'h02020202; // get four rlps
    case (pstateidx)
        6'h0 :
        begin
            reg_four_rlps = 32'h80B0D0F0; //128, 176, 208, 240
        end
        6'h1 :
        begin
            reg_four_rlps = 32'h80A7C5E3;
        end
        6'h2 :
        begin
            reg_four_rlps = 32'h809EBBD8;
        end
        6'h3 :
        begin
            reg_four_rlps = 32'h7B96B2CD;
        end
        6'h4 :
        begin
            reg_four_rlps = 32'h748EA9C3;
        end
        6'h5 :
        begin
            reg_four_rlps = 32'h6F87A0B9;
        end
        6'h6 :
        begin
            reg_four_rlps = 32'h698098AF;
        end
        6'h7 :
        begin
            reg_four_rlps = 32'h647A90A6;
        end
        6'h8 :
        begin
            reg_four_rlps = 32'h5F74899E;
        end
        6'h9 :
        begin
            reg_four_rlps = 32'h5A6E8296;
        end
        6'hA :
        begin
            reg_four_rlps = 32'h55687B8E;
        end
        6'hB :
        begin
            reg_four_rlps = 32'h51637587;
        end
        6'hC :
        begin
            reg_four_rlps = 32'h4D5E6F80;
        end
        6'hD :
        begin
            reg_four_rlps = 32'h4959697A;
        end
        6'hE :
        begin
            reg_four_rlps = 32'h45556474;
        end
        6'hF :
        begin
            reg_four_rlps = 32'h42505F6E;
        end
        6'h10 :
        begin
            reg_four_rlps = 32'h3E4C5A68;
        end
        6'h11 :
        begin
            reg_four_rlps = 32'h3B485663;
        end
        6'h12 :
        begin
            reg_four_rlps = 32'h3845515E;
        end
        6'h13 :
        begin
            reg_four_rlps = 32'h35414D59;
        end
        6'h14 :
        begin
            reg_four_rlps = 32'h333E4955;
        end
        6'h15 :
        begin
            reg_four_rlps = 32'h303B4550;
        end
        6'h16 :
        begin
            reg_four_rlps = 32'h2E38424C;
        end
        6'h17 :
        begin
            reg_four_rlps = 32'h2B353F48;
        end
        6'h18 :
        begin
            reg_four_rlps = 32'h29323B45;
        end
        6'h19 :
        begin
            reg_four_rlps = 32'h27303841;
        end
        6'h1A :
        begin
            reg_four_rlps = 32'h252D363E;
        end
        6'h1B :
        begin
            reg_four_rlps = 32'h232B333B;
        end
        6'h1C :
        begin
            reg_four_rlps = 32'h21293038;
        end
        6'h1D :
        begin
            reg_four_rlps = 32'h20272E35;
        end
        6'h1E :
        begin
            reg_four_rlps = 32'h1E252B32;
        end
        6'h1F :
        begin
            reg_four_rlps = 32'h1D232930;
        end
        6'h20 :
        begin
            reg_four_rlps = 32'h1B21272D;
        end
        6'h21 :
        begin
            reg_four_rlps = 32'h1A1F252B;
        end
        6'h22 :
        begin
            reg_four_rlps = 32'h181E2329;
        end
        6'h23 :
        begin
            reg_four_rlps = 32'h171C2127;
        end
        6'h24 :
        begin
            reg_four_rlps = 32'h161B2025;
        end
        6'h25 :
        begin
            reg_four_rlps = 32'h151A1E23;
        end
        6'h26 :
        begin
            reg_four_rlps = 32'h14181D21;
        end
        6'h27 :
        begin
            reg_four_rlps = 32'h13171B1F;
        end
        6'h28 :
        begin
            reg_four_rlps = 32'h12161A1E;
        end
        6'h29 :
        begin
            reg_four_rlps = 32'h1115191C;
        end
        6'h2A :
        begin
            reg_four_rlps = 32'h1014171B;
        end
        6'h2B :
        begin
            reg_four_rlps = 32'h0F131619;
        end
        6'h2C :
        begin
            reg_four_rlps = 32'h0E121518;
        end
        6'h2D :
        begin
            reg_four_rlps = 32'h0E111417;
        end
        6'h2E :
        begin
            reg_four_rlps = 32'h0D101316;
        end
        6'h2F :
        begin
            reg_four_rlps = 32'h0C0F1215;
        end
        6'h30 :
        begin
            reg_four_rlps = 32'h0C0E1114;
        end
        6'h31 :
        begin
            reg_four_rlps = 32'h0B0E1013;
        end
        6'h32 :
        begin
            reg_four_rlps = 32'h0B0D0F12;
        end
        6'h33 :
        begin
            reg_four_rlps = 32'h0A0C0F11;
        end
        6'h34 :
        begin
            reg_four_rlps = 32'h0A0C0E10;
        end
        6'h35 :
        begin
            reg_four_rlps = 32'h090B0D0F;
        end
        6'h36 :
        begin
            reg_four_rlps = 32'h090B0C0E;
        end
        6'h37 :
        begin
            reg_four_rlps = 32'h080A0C0E;
        end
        6'h38 :
        begin
            reg_four_rlps = 32'h08090B0D;
        end
        6'h39 :
        begin
            reg_four_rlps = 32'h07090B0C;
        end
        6'h3A :
        begin
            reg_four_rlps = 32'h07090A0C;
        end
        6'h3B :
        begin
            reg_four_rlps = 32'h07080A0B;
        end
        6'h3C :
        begin
            reg_four_rlps = 32'h0608090B;
        end
        6'h3D :
        begin
            reg_four_rlps = 32'h0607090A;
        end
        6'h3E :
        begin
            reg_four_rlps = 32'h06070809;
        end
        default:
            reg_four_rlps = 32'h02020202;
    endcase
end

assign rlps_0       =   reg_four_rlps[31:24];
assign rlps_1       =   reg_four_rlps[23:16];
assign rlps_2       =   reg_four_rlps[15:8];
assign rlps_3       =   reg_four_rlps[7:0];

always @(*) //shift_rlps_0, rlps_shift_0
begin
    rlps_shift_0 = {rlps_0[0],7'b0};
    shift_rlps_0 = 3'd7;
    casex (rlps_0)
        8'b1xxxxxxx :
        begin
            rlps_shift_0 = {rlps_0[6:0],1'b0};
            shift_rlps_0 = 3'd1;
        end
        8'b01xxxxxx :
        begin
            rlps_shift_0 = {rlps_0[5:0],2'b0};
            shift_rlps_0 = 3'd2;
        end
        8'b001xxxxx :
        begin
            rlps_shift_0 = {rlps_0[4:0],3'b0};
            shift_rlps_0 = 3'd3;
        end
        8'b0001xxxx :
        begin
            rlps_shift_0 = {rlps_0[3:0],4'b0};
            shift_rlps_0 = 3'd4;
        end
        8'b00001xxx :
        begin
            rlps_shift_0 = {rlps_0[2:0],5'b0};
            shift_rlps_0 = 3'd5;
        end
        8'b000001xx :
        begin
            rlps_shift_0 = {rlps_0[1:0],6'b0};
            shift_rlps_0 = 3'd6;
        end
        default:
        begin
            rlps_shift_0 = {rlps_0[0],7'b0};
            shift_rlps_0 = 3'd7;
        end
    endcase
end

always @(*) //shift_rlps_1, rlps_shift_1
begin
    rlps_shift_1 = {rlps_1[0],7'b0};
    shift_rlps_1 = 3'd7;
    casex (rlps_1)
        8'b1xxxxxxx :
        begin
            rlps_shift_1 = {rlps_1[6:0],1'b0};
            shift_rlps_1 = 3'd1;
        end
        8'b01xxxxxx :
        begin
            rlps_shift_1 = {rlps_1[5:0],2'b0};
            shift_rlps_1 = 3'd2;
        end
        8'b001xxxxx :
        begin
            rlps_shift_1 = {rlps_1[4:0],3'b0};
            shift_rlps_1 = 3'd3;
        end
        8'b0001xxxx :
        begin
            rlps_shift_1 = {rlps_1[3:0],4'b0};
            shift_rlps_1 = 3'd4;
        end
        8'b00001xxx :
        begin
            rlps_shift_1 = {rlps_1[2:0],5'b0};
            shift_rlps_1 = 3'd5;
        end
        8'b000001xx :
        begin
            rlps_shift_1 = {rlps_1[1:0],6'b0};
            shift_rlps_1 = 3'd6;
        end
        default:
        begin
            rlps_shift_1 = {rlps_1[0],7'b0};
            shift_rlps_1 = 3'd7;
        end
    endcase
end

always @(*) //shift_rlps_2, rlps_shift_2
begin
    rlps_shift_2 = {rlps_2[0],7'b0};
    shift_rlps_2 = 3'd7;
    casex (rlps_2)
        8'b1xxxxxxx :
        begin
            rlps_shift_2 = {rlps_2[6:0],1'b0};
            shift_rlps_2 = 3'd1;
        end
        8'b01xxxxxx :
        begin
            rlps_shift_2 = {rlps_2[5:0],2'b0};
            shift_rlps_2 = 3'd2;
        end
        8'b001xxxxx :
        begin
            rlps_shift_2 = {rlps_2[4:0],3'b0};
            shift_rlps_2 = 3'd3;
        end
        8'b0001xxxx :
        begin
            rlps_shift_2 = {rlps_2[3:0],4'b0};
            shift_rlps_2 = 3'd4;
        end
        8'b00001xxx :
        begin
            rlps_shift_2 = {rlps_2[2:0],5'b0};
            shift_rlps_2 = 3'd5;
        end
        8'b000001xx :
        begin
            rlps_shift_2 = {rlps_2[1:0],6'b0};
            shift_rlps_2 = 3'd6;
        end
        default:
        begin
            rlps_shift_2 = {rlps_2[0],7'b0};
            shift_rlps_2 = 3'd7;
        end
    endcase
end

always @(*) //shift_rlps_3, rlps_shift_3
begin
    rlps_shift_3 = {rlps_3[0],7'b0};
    shift_rlps_3 = 3'd7;
    casex (rlps_3)
        8'b1xxxxxxx :
        begin
            rlps_shift_3 = {rlps_3[6:0],1'b0};
            shift_rlps_3 = 3'd1;
        end
        8'b01xxxxxx :
        begin
            rlps_shift_3 = {rlps_3[5:0],2'b0};
            shift_rlps_3 = 3'd2;
        end
        8'b001xxxxx :
        begin
            rlps_shift_3 = {rlps_3[4:0],3'b0};
            shift_rlps_3 = 3'd3;
        end
        8'b0001xxxx :
        begin
            rlps_shift_3 = {rlps_3[3:0],4'b0};
            shift_rlps_3 = 3'd4;
        end
        8'b00001xxx :
        begin
            rlps_shift_3 = {rlps_3[2:0],5'b0};
            shift_rlps_3 = 3'd5;
        end
        8'b000001xx :
        begin
            rlps_shift_3 = {rlps_3[1:0],6'b0};
            shift_rlps_3 = 3'd6;
        end
        default:
        begin
            rlps_shift_3 = {rlps_3[0],7'b0};
            shift_rlps_3 = 3'd7;
        end
    endcase
end

assign four_rlps        =   reg_four_rlps;
assign four_rlps_shift  =   {shift_rlps_0, rlps_shift_0, shift_rlps_1, rlps_shift_1, shift_rlps_2, rlps_shift_2, shift_rlps_3, rlps_shift_3};
//}

endmodule
