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
// Filename       : cabac_ucontext_t.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : update context table
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------


module cabac_ucontext_t(
           in_context,
           symbol,
           out_context
       );


//input and output signals //{
input       [6:0]   in_context;
input               symbol;
output  wire[6:0]   out_context;
//}


//signals //{
wire                mps_t;
wire        [5:0]   pstateidx;
wire                mps_lps;
wire                next_mps;
reg         [5:0]   next_state_lps;
reg         [5:0]   next_state_mps;
wire        [5:0]   next_pstateidx;
//}


//logic //{
assign mps_t            =   in_context[6];
assign pstateidx        =   in_context[5:0];
assign mps_lps          =   mps_t ^ symbol;
assign next_mps         =   mps_lps && (pstateidx == 0) ? ~mps_t : mps_t;
assign next_pstateidx   =   mps_lps ? next_state_lps : next_state_mps;
assign out_context      =   {next_mps, next_pstateidx};

always @(*) //next_state_lps, next_state_mps
begin
    next_state_lps = 6'b111111;
    next_state_mps = 6'b111111;
    case (pstateidx)
        6'b0 :
        begin
            next_state_lps = 6'b0;
            next_state_mps = 6'b1;
        end
        6'b1 :
        begin
            next_state_lps = 6'b0;
            next_state_mps = 6'b10;
        end
        6'b10 :
        begin
            next_state_lps = 6'b1;
            next_state_mps = 6'b11;
        end
        6'b11 :
        begin
            next_state_lps = 6'b10;
            next_state_mps = 6'b100;
        end
        6'b100 :
        begin
            next_state_lps = 6'b10;
            next_state_mps = 6'b101;
        end
        6'b101 :
        begin
            next_state_lps = 6'b100;
            next_state_mps = 6'b110;
        end
        6'b110 :
        begin
            next_state_lps = 6'b100;
            next_state_mps = 6'b111;
        end
        6'b111 :
        begin
            next_state_lps = 6'b101;
            next_state_mps = 6'b1000;
        end
        6'b1000 :
        begin
            next_state_lps = 6'b110;
            next_state_mps = 6'b1001;
        end
        6'b1001 :
        begin
            next_state_lps = 6'b111;
            next_state_mps = 6'b1010;
        end
        6'b1010 :
        begin
            next_state_lps = 6'b1000;
            next_state_mps = 6'b1011;
        end
        6'b1011 :
        begin
            next_state_lps = 6'b1001;
            next_state_mps = 6'b1100;
        end
        6'b1100 :
        begin
            next_state_lps = 6'b1001;
            next_state_mps = 6'b1101;
        end
        6'b1101 :
        begin
            next_state_lps = 6'b1011;
            next_state_mps = 6'b1110;
        end
        6'b1110 :
        begin
            next_state_lps = 6'b1011;
            next_state_mps = 6'b1111;
        end
        6'b1111 :
        begin
            next_state_lps = 6'b1100;
            next_state_mps = 6'b10000;
        end
        6'b10000 :
        begin
            next_state_lps = 6'b1101;
            next_state_mps = 6'b10001;
        end
        6'b10001 :
        begin
            next_state_lps = 6'b1101;
            next_state_mps = 6'b10010;
        end
        6'b10010 :
        begin
            next_state_lps = 6'b1111;
            next_state_mps = 6'b10011;
        end
        6'b10011 :
        begin
            next_state_lps = 6'b1111;
            next_state_mps = 6'b10100;
        end
        6'b10100 :
        begin
            next_state_lps = 6'b10000;
            next_state_mps = 6'b10101;
        end
        6'b10101 :
        begin
            next_state_lps = 6'b10000;
            next_state_mps = 6'b10110;
        end
        6'b10110 :
        begin
            next_state_lps = 6'b10010;
            next_state_mps = 6'b10111;
        end
        6'b10111 :
        begin
            next_state_lps = 6'b10010;
            next_state_mps = 6'b11000;
        end
        6'b11000 :
        begin
            next_state_lps = 6'b10011;
            next_state_mps = 6'b11001;
        end
        6'b11001 :
        begin
            next_state_lps = 6'b10011;
            next_state_mps = 6'b11010;
        end
        6'b11010 :
        begin
            next_state_lps = 6'b10101;
            next_state_mps = 6'b11011;
        end
        6'b11011 :
        begin
            next_state_lps = 6'b10101;
            next_state_mps = 6'b11100;
        end
        6'b11100 :
        begin
            next_state_lps = 6'b10110;
            next_state_mps = 6'b11101;
        end
        6'b11101 :
        begin
            next_state_lps = 6'b10110;
            next_state_mps = 6'b11110;
        end
        6'b11110 :
        begin
            next_state_lps = 6'b10111;
            next_state_mps = 6'b11111;
        end
        6'b11111 :
        begin
            next_state_lps = 6'b11000;
            next_state_mps = 6'b100000;
        end
        6'b100000 :
        begin
            next_state_lps = 6'b11000;
            next_state_mps = 6'b100001;
        end
        6'b100001 :
        begin
            next_state_lps = 6'b11001;
            next_state_mps = 6'b100010;
        end
        6'b100010 :
        begin
            next_state_lps = 6'b11010;
            next_state_mps = 6'b100011;
        end
        6'b100011 :
        begin
            next_state_lps = 6'b11010;
            next_state_mps = 6'b100100;
        end
        6'b100100 :
        begin
            next_state_lps = 6'b11011;
            next_state_mps = 6'b100101;
        end
        6'b100101 :
        begin
            next_state_lps = 6'b11011;
            next_state_mps = 6'b100110;
        end
        6'b100110 :
        begin
            next_state_lps = 6'b11100;
            next_state_mps = 6'b100111;
        end
        6'b100111 :
        begin
            next_state_lps = 6'b11101;
            next_state_mps = 6'b101000;
        end
        6'b101000 :
        begin
            next_state_lps = 6'b11101;
            next_state_mps = 6'b101001;
        end
        6'b101001 :
        begin
            next_state_lps = 6'b11110;
            next_state_mps = 6'b101010;
        end
        6'b101010 :
        begin
            next_state_lps = 6'b11110;
            next_state_mps = 6'b101011;
        end
        6'b101011 :
        begin
            next_state_lps = 6'b11110;
            next_state_mps = 6'b101100;
        end
        6'b101100 :
        begin
            next_state_lps = 6'b11111;
            next_state_mps = 6'b101101;
        end
        6'b101101 :
        begin
            next_state_lps = 6'b100000;
            next_state_mps = 6'b101110;
        end
        6'b101110 :
        begin
            next_state_lps = 6'b100000;
            next_state_mps = 6'b101111;
        end
        6'b101111 :
        begin
            next_state_lps = 6'b100001;
            next_state_mps = 6'b110000;
        end
        6'b110000 :
        begin
            next_state_lps = 6'b100001;
            next_state_mps = 6'b110001;
        end
        6'b110001 :
        begin
            next_state_lps = 6'b100001;
            next_state_mps = 6'b110010;
        end
        6'b110010 :
        begin
            next_state_lps = 6'b100010;
            next_state_mps = 6'b110011;
        end
        6'b110011 :
        begin
            next_state_lps = 6'b100010;
            next_state_mps = 6'b110100;
        end
        6'b110100 :
        begin
            next_state_lps = 6'b100011;
            next_state_mps = 6'b110101;
        end
        6'b110101 :
        begin
            next_state_lps = 6'b100011;
            next_state_mps = 6'b110110;
        end
        6'b110110 :
        begin
            next_state_lps = 6'b100011;
            next_state_mps = 6'b110111;
        end
        6'b110111 :
        begin
            next_state_lps = 6'b100100;
            next_state_mps = 6'b111000;
        end
        6'b111000 :
        begin
            next_state_lps = 6'b100100;
            next_state_mps = 6'b111001;
        end
        6'b111001 :
        begin
            next_state_lps = 6'b100100;
            next_state_mps = 6'b111010;
        end
        6'b111010 :
        begin
            next_state_lps = 6'b100101;
            next_state_mps = 6'b111011;
        end
        6'b111011 :
        begin
            next_state_lps = 6'b100101;
            next_state_mps = 6'b111100;
        end
        6'b111100 :
        begin
            next_state_lps = 6'b100101;
            next_state_mps = 6'b111101;
        end
        6'b111101 :
        begin
            next_state_lps = 6'b100110;
            next_state_mps = 6'b111110;
        end
        6'b111110 :
        begin
            next_state_lps = 6'b100110;
            next_state_mps = 6'b111110;
        end
        default:
        begin
            next_state_lps = 6'b111111;
            next_state_mps = 6'b111111;
        end
    endcase
end
//}

endmodule
