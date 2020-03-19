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
// Filename       : cabac_ucontext_tt.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : update context table
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------


module cabac_ucontext_tt(
           in_context,
           symbol_0,
           symbol_1,
           out_context
       );


//input and output signals //{
input       [6:0]   in_context;
input               symbol_0;
input               symbol_1;
output  wire[6:0]   out_context;
//}


//signals //{
wire                mps;
wire        [5:0]   pstateidx;
wire                mps_lps_0;
wire                mps_lps_1;
wire                next_mps;
reg         [5:0]   next_state_l_1;
reg         [5:0]   next_state_l_m;
reg         [5:0]   next_state_m_1;
wire        [5:0]   next_state_m_m;
wire        [5:0]   next_state;
//}


//logic //{
assign mps              =   in_context[6];
assign pstateidx        =   in_context[5:0];
assign mps_lps_0        =   mps ^ symbol_0;
assign mps_lps_1        =   mps ^ symbol_1;
assign next_mps         =   mps_lps_0 && mps_lps_1 && ((pstateidx==0)||(pstateidx==1)) ? ~mps : mps;
assign next_state       =   mps_lps_1 ? (mps_lps_0 ? next_state_l_1 : next_state_m_1) : (mps_lps_0 ? next_state_l_m : next_state_m_m);

always @(*) //next_state_l_1, next_state_l_m, next_state_m_1
begin
    next_state_l_1 = 6'b111111;
    next_state_l_m = 6'b111111;
    next_state_m_1 = 6'b111111;
    case (pstateidx)
        6'd0 :
        begin
            next_state_l_1 = 6'd1;
            next_state_l_m = 6'd0;
            next_state_m_1 = 6'd0;
        end
        6'd1 :
        begin
            next_state_l_1 = 6'd0;
            next_state_l_m = 6'd1;
            next_state_m_1 = 6'd1;
        end
        6'd2 :
        begin
            next_state_l_1 = 6'd0;
            next_state_l_m = 6'd2;
            next_state_m_1 = 6'd2;
        end
        6'd3 :
        begin
            next_state_l_1 = 6'd1;
            next_state_l_m = 6'd3;
            next_state_m_1 = 6'd2;
        end
        6'd4 :
        begin
            next_state_l_1 = 6'd1;
            next_state_l_m = 6'd3;
            next_state_m_1 = 6'd4;
        end
        6'd5 :
        begin
            next_state_l_1 = 6'd2;
            next_state_l_m = 6'd5;
            next_state_m_1 = 6'd4;
        end
        6'd6 :
        begin
            next_state_l_1 = 6'd2;
            next_state_l_m = 6'd5;
            next_state_m_1 = 6'd5;
        end
        6'd7 :
        begin
            next_state_l_1 = 6'd4;
            next_state_l_m = 6'd6;
            next_state_m_1 = 6'd6;
        end
        6'd8 :
        begin
            next_state_l_1 = 6'd4;
            next_state_l_m = 6'd7;
            next_state_m_1 = 6'd7;
        end
        6'd9 :
        begin
            next_state_l_1 = 6'd5;
            next_state_l_m = 6'd8;
            next_state_m_1 = 6'd8;
        end
        6'd10 :
        begin
            next_state_l_1 = 6'd6;
            next_state_l_m = 6'd9;
            next_state_m_1 = 6'd9;
        end
        6'd11 :
        begin
            next_state_l_1 = 6'd7;
            next_state_l_m = 6'd10;
            next_state_m_1 = 6'd9;
        end
        6'd12 :
        begin
            next_state_l_1 = 6'd7;
            next_state_l_m = 6'd10;
            next_state_m_1 = 6'd11;
        end
        6'd13 :
        begin
            next_state_l_1 = 6'd9;
            next_state_l_m = 6'd12;
            next_state_m_1 = 6'd11;
        end
        6'd14 :
        begin
            next_state_l_1 = 6'd9;
            next_state_l_m = 6'd12;
            next_state_m_1 = 6'd12;
        end
        6'd15 :
        begin
            next_state_l_1 = 6'd9;
            next_state_l_m = 6'd13;
            next_state_m_1 = 6'd13;
        end
        6'd16 :
        begin
            next_state_l_1 = 6'd11;
            next_state_l_m = 6'd14;
            next_state_m_1 = 6'd13;
        end
        6'd17 :
        begin
            next_state_l_1 = 6'd11;
            next_state_l_m = 6'd14;
            next_state_m_1 = 6'd15;
        end
        6'd18 :
        begin
            next_state_l_1 = 6'd12;
            next_state_l_m = 6'd16;
            next_state_m_1 = 6'd15;
        end
        6'd19 :
        begin
            next_state_l_1 = 6'd12;
            next_state_l_m = 6'd16;
            next_state_m_1 = 6'd16;
        end
        6'd20 :
        begin
            next_state_l_1 = 6'd13;
            next_state_l_m = 6'd17;
            next_state_m_1 = 6'd16;
        end
        6'd21 :
        begin
            next_state_l_1 = 6'd13;
            next_state_l_m = 6'd17;
            next_state_m_1 = 6'd18;
        end
        6'd22 :
        begin
            next_state_l_1 = 6'd15;
            next_state_l_m = 6'd19;
            next_state_m_1 = 6'd18;
        end
        6'd23 :
        begin
            next_state_l_1 = 6'd15;
            next_state_l_m = 6'd19;
            next_state_m_1 = 6'd19;
        end
        6'd24 :
        begin
            next_state_l_1 = 6'd15;
            next_state_l_m = 6'd20;
            next_state_m_1 = 6'd19;
        end
        6'd25 :
        begin
            next_state_l_1 = 6'd15;
            next_state_l_m = 6'd20;
            next_state_m_1 = 6'd21;
        end
        6'd26 :
        begin
            next_state_l_1 = 6'd16;
            next_state_l_m = 6'd22;
            next_state_m_1 = 6'd21;
        end
        6'd27 :
        begin
            next_state_l_1 = 6'd16;
            next_state_l_m = 6'd22;
            next_state_m_1 = 6'd22;
        end
        6'd28 :
        begin
            next_state_l_1 = 6'd18;
            next_state_l_m = 6'd23;
            next_state_m_1 = 6'd22;
        end
        6'd29 :
        begin
            next_state_l_1 = 6'd18;
            next_state_l_m = 6'd23;
            next_state_m_1 = 6'd23;
        end
        6'd30 :
        begin
            next_state_l_1 = 6'd18;
            next_state_l_m = 6'd24;
            next_state_m_1 = 6'd24;
        end
        6'd31 :
        begin
            next_state_l_1 = 6'd19;
            next_state_l_m = 6'd25;
            next_state_m_1 = 6'd24;
        end
        6'd32 :
        begin
            next_state_l_1 = 6'd19;
            next_state_l_m = 6'd25;
            next_state_m_1 = 6'd25;
        end
        6'd33 :
        begin
            next_state_l_1 = 6'd19;
            next_state_l_m = 6'd26;
            next_state_m_1 = 6'd26;
        end
        6'd34 :
        begin
            next_state_l_1 = 6'd21;
            next_state_l_m = 6'd27;
            next_state_m_1 = 6'd26;
        end
        6'd35 :
        begin
            next_state_l_1 = 6'd21;
            next_state_l_m = 6'd27;
            next_state_m_1 = 6'd27;
        end
        6'd36 :
        begin
            next_state_l_1 = 6'd21;
            next_state_l_m = 6'd28;
            next_state_m_1 = 6'd27;
        end
        6'd37 :
        begin
            next_state_l_1 = 6'd21;
            next_state_l_m = 6'd28;
            next_state_m_1 = 6'd28;
        end
        6'd38 :
        begin
            next_state_l_1 = 6'd22;
            next_state_l_m = 6'd29;
            next_state_m_1 = 6'd29;
        end
        6'd39 :
        begin
            next_state_l_1 = 6'd22;
            next_state_l_m = 6'd30;
            next_state_m_1 = 6'd29;
        end
        6'd40 :
        begin
            next_state_l_1 = 6'd22;
            next_state_l_m = 6'd30;
            next_state_m_1 = 6'd30;
        end
        6'd41 :
        begin
            next_state_l_1 = 6'd23;
            next_state_l_m = 6'd31;
            next_state_m_1 = 6'd30;
        end
        6'd42 :
        begin
            next_state_l_1 = 6'd23;
            next_state_l_m = 6'd31;
            next_state_m_1 = 6'd30;
        end
        6'd43 :
        begin
            next_state_l_1 = 6'd23;
            next_state_l_m = 6'd31;
            next_state_m_1 = 6'd31;
        end
        6'd44 :
        begin
            next_state_l_1 = 6'd24;
            next_state_l_m = 6'd32;
            next_state_m_1 = 6'd32;
        end
        6'd45 :
        begin
            next_state_l_1 = 6'd24;
            next_state_l_m = 6'd33;
            next_state_m_1 = 6'd32;
        end
        6'd46 :
        begin
            next_state_l_1 = 6'd24;
            next_state_l_m = 6'd33;
            next_state_m_1 = 6'd33;
        end
        6'd47 :
        begin
            next_state_l_1 = 6'd25;
            next_state_l_m = 6'd34;
            next_state_m_1 = 6'd33;
        end
        6'd48 :
        begin
            next_state_l_1 = 6'd25;
            next_state_l_m = 6'd34;
            next_state_m_1 = 6'd33;
        end
        6'd49 :
        begin
            next_state_l_1 = 6'd25;
            next_state_l_m = 6'd34;
            next_state_m_1 = 6'd34;
        end
        6'd50 :
        begin
            next_state_l_1 = 6'd26;
            next_state_l_m = 6'd35;
            next_state_m_1 = 6'd34;
        end
        6'd51 :
        begin
            next_state_l_1 = 6'd26;
            next_state_l_m = 6'd35;
            next_state_m_1 = 6'd35;
        end
        6'd52 :
        begin
            next_state_l_1 = 6'd26;
            next_state_l_m = 6'd36;
            next_state_m_1 = 6'd35;
        end
        6'd53 :
        begin
            next_state_l_1 = 6'd26;
            next_state_l_m = 6'd36;
            next_state_m_1 = 6'd35;
        end
        6'd54 :
        begin
            next_state_l_1 = 6'd26;
            next_state_l_m = 6'd36;
            next_state_m_1 = 6'd36;
        end
        6'd55 :
        begin
            next_state_l_1 = 6'd27;
            next_state_l_m = 6'd37;
            next_state_m_1 = 6'd36;
        end
        6'd56 :
        begin
            next_state_l_1 = 6'd27;
            next_state_l_m = 6'd37;
            next_state_m_1 = 6'd36;
        end
        6'd57 :
        begin
            next_state_l_1 = 6'd27;
            next_state_l_m = 6'd37;
            next_state_m_1 = 6'd37;
        end
        6'd58 :
        begin
            next_state_l_1 = 6'd27;
            next_state_l_m = 6'd38;
            next_state_m_1 = 6'd37;
        end
        6'd59 :
        begin
            next_state_l_1 = 6'd27;
            next_state_l_m = 6'd38;
            next_state_m_1 = 6'd37;
        end
        6'd60 :
        begin
            next_state_l_1 = 6'd27;
            next_state_l_m = 6'd38;
            next_state_m_1 = 6'd38;
        end
        6'd61 :
        begin
            next_state_l_1 = 6'd28;
            next_state_l_m = 6'd39;
            next_state_m_1 = 6'd38;
        end
        6'd62 :
        begin
            next_state_l_1 = 6'd28;
            next_state_l_m = 6'd39;
            next_state_m_1 = 6'd38;
        end
        default:
        begin
            next_state_l_1 = 6'b111111;
            next_state_l_m = 6'b111111;
            next_state_m_1 = 6'b111111;
        end
    endcase
end

assign next_state_m_m   =   (pstateidx==63) ? 63 : ((pstateidx>60) ? 62 : pstateidx + 2);

assign out_context      =   {next_mps, next_state};
//}

endmodule
