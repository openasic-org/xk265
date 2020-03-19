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
// Filename       : cabac_ulow_1bin.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : update low value
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------

module cabac_ulow_1bin(
           in_low,
           bypass,
           lpsmps,
           shift,
           r_rmps,

           out_low,
           out_overflow,
           out_buffer
       );

//input and output signals //{
input		[8:0]	in_low;
input				bypass;
input				lpsmps;
input		[2:0]	shift;
input		[8:0]	r_rmps;

output	wire[8:0]	out_low;
output	wire		out_overflow;
output	wire[6:0]	out_buffer;
//}

//signals //{
wire		[9:0]		range_rmps;
wire		[9:0]		wire_low_add;
wire					wire_out_overflow;
wire		[15:0]		wire_low_before_shift;
wire		[11:0]		wire_low_before_shift_1;
wire		[9:0]		wire_low_before_shift_2;
wire		[8:0]		wire_low_before_shift_3;
//}

//logics //{
assign	range_rmps							=	bypass ? {1'b0, r_rmps} : {r_rmps, 1'b0};
assign	{wire_out_overflow, wire_low_add}	=	{1'b0, in_low[8:0], 1'b0} + {1'b0, range_rmps};
assign	wire_low_before_shift				=	lpsmps ? {wire_low_add, 6'b0} : {in_low, 7'b0};
assign	out_overflow					=	lpsmps ? wire_out_overflow : 0;

assign	wire_low_before_shift_1			=	shift[2] ? wire_low_before_shift[11:0] : wire_low_before_shift[15:4];
assign	wire_low_before_shift_2			=	shift[1] ? wire_low_before_shift_1[9:0] : wire_low_before_shift_1[11:2];
assign	wire_low_before_shift_3			=	shift[0] ? wire_low_before_shift_2[8:0] : wire_low_before_shift_2[9:1];

assign	out_buffer						=	wire_low_before_shift[15:9];
assign	out_low							=	wire_low_before_shift_3;
//}

endmodule
