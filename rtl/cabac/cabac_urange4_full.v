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
// Filename       : cabac_urange4_full.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : update range
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------

module cabac_urange4_full(
           in_range,
           lpsmps,
           four_lps,
           four_lps_shift,
           out_range,
           out_rlps,
           out_shift
       );

//input and output //{
input   [7:0] in_range;
input       lpsmps;
input   [31:0]  four_lps;
input   [43:0]  four_lps_shift;
output  wire[7:0] out_range;
output  wire[7:0] out_rlps;
output  wire[2:0] out_shift;
//}

//signals //{
reg   [7:0]   rlps;
reg   [7:0]   rlps_shift;
reg   [2:0]   shift_lps;
wire  [8:0]   rmps;
wire  [7:0]   rmps_shift;
wire        shift_mps;
//}

//logic //{
always @(*) //rlps_shift, rlps, shift_lps
begin
    rlps = four_lps[7:0];
    shift_lps = four_lps_shift[10:8];
    rlps_shift = four_lps_shift[7:0];
    case (in_range[7:6])
        2'b00 :
        begin
            rlps = four_lps[31:24];
            shift_lps = four_lps_shift[43:41];
            rlps_shift = four_lps_shift[40:33];
        end
        2'b01 :
        begin
            rlps = four_lps[23:16];
            shift_lps = four_lps_shift[32:30];
            rlps_shift = four_lps_shift[29:22];
        end
        2'b10 :
        begin
            rlps = four_lps[15:8];
            shift_lps = four_lps_shift[21:19];
            rlps_shift = four_lps_shift[18:11];
        end
        default:
        begin
            rlps = four_lps[7:0];
            shift_lps = four_lps_shift[10:8];
            rlps_shift = four_lps_shift[7:0];
        end
    endcase
end


assign rmps         = {1'b1, in_range} - rlps; // range
assign rmps_shift     = rmps[8] ? rmps[7:0] : {rmps[6:0], 1'b0}; // check range >=0x100
assign shift_mps      = rmps[8] ? 1'b0 : 1'b1; // when range < 0x100, renorm.
assign out_range      = lpsmps ? rlps_shift : rmps_shift;
assign out_shift      = lpsmps ? shift_lps : {2'b0, shift_mps};

assign out_rlps       = rlps;
//}

endmodule
