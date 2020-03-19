//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2014, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//
//-------------------------------------------------------------------
//
//  Filename      : fme_interpolator.v
//  Author        : Yufeng Bai
//  Email 	  : byfchina@gmail.com	
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module clip (
	val_in,
	val_out
);

parameter CLIP_WIDTH = 16;

input signed [CLIP_WIDTH-1  :0] val_in;
output [`PIXEL_WIDTH-1:0] val_out;

assign val_out = ( val_in  < 0  ) ? 'd0   :
	         ( val_in  > 255) ? 'd255 :
		 val_in[`PIXEL_WIDTH-1:0];
endmodule


module clip2 (
	val_in,
	val_out
);

parameter CLIP_WIDTH = 16;

input  signed [CLIP_WIDTH-1  :0] val_in;
output        [`PIXEL_WIDTH-1:0] val_out;

wire   signed [10-1          :0] val_tmp;

assign val_tmp = (val_in + 'd8224) >> 6;

assign val_out = ( val_tmp  < 0  ) ? 'd0   :
	         ( val_tmp  > 255) ? 'd255 :
		 val_tmp[`PIXEL_WIDTH-1:0];
endmodule

module fme_interpolator (
	tap_0_i		,
	tap_1_i		,
	tap_2_i		,
	tap_3_i		,
	tap_4_i		,
	tap_5_i		,
	tap_6_i		,
	tap_7_i		,
	val_o		
);

parameter TYPE       = 0; // 0: half interpolator, 1: 1/4 interpolator , 2: 3/4 interpolator 
parameter HOR        = 0; // isHor
parameter LAST       = 0; // isLast
parameter IN_EXPAND  = 0; // input TAP data WIDTH , 0: 8bits, 1: 16 bits
parameter OUT_EXPAND = 1; // output val data WIDTH, 0: 8bits(cliped), 1: 16 bits(not cliped)


// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input 	signed [(IN_EXPAND+1)*`PIXEL_WIDTH-1:0] 	 tap_0_i 	 ; // tap 0 input 
input 	signed [(IN_EXPAND+1)*`PIXEL_WIDTH-1:0] 	 tap_1_i 	 ; // tap 1 input 
input 	signed [(IN_EXPAND+1)*`PIXEL_WIDTH-1:0] 	 tap_2_i 	 ; // tap 2 input 
input 	signed [(IN_EXPAND+1)*`PIXEL_WIDTH-1:0] 	 tap_3_i 	 ; // tap 3 input 
input 	signed [(IN_EXPAND+1)*`PIXEL_WIDTH-1:0] 	 tap_4_i 	 ; // tap 4 input 
input 	signed [(IN_EXPAND+1)*`PIXEL_WIDTH-1:0] 	 tap_5_i 	 ; // tap 5 input 
input 	signed [(IN_EXPAND+1)*`PIXEL_WIDTH-1:0] 	 tap_6_i 	 ; // tap 6 input 
input 	signed [(IN_EXPAND+1)*`PIXEL_WIDTH-1:0] 	 tap_7_i 	 ; // tap 7 input 
output 	signed [(OUT_EXPAND+1)*`PIXEL_WIDTH-1:0]         val_o 	         ; // interpolator output 

// ********************************************
//
//    WIRE DECLARATION
//
// ********************************************
wire   signed  [15                       :0]     val             ; // internal value
wire   signed  [31                       :0]     val_tmp             ; // internal value


wire   signed  [15                       :0]            tap_0            ;
wire   signed  [15                       :0]            tap_1            ;
wire   signed  [15                       :0]            tap_2            ;
wire   signed  [15                       :0]            tap_3            ;
wire   signed  [15                       :0]            tap_4            ;
wire   signed  [15                       :0]            tap_5            ;
wire   signed  [15                       :0]            tap_6            ;
wire   signed  [15                       :0]            tap_7            ;

generate 
    if(IN_EXPAND == 0) begin : expand_input
	assign tap_0 = {8'b0,tap_0_i};
	assign tap_1 = {8'b0,tap_1_i};
	assign tap_2 = {8'b0,tap_2_i};
	assign tap_3 = {8'b0,tap_3_i};
	assign tap_4 = {8'b0,tap_4_i};
	assign tap_5 = {8'b0,tap_5_i};
	assign tap_6 = {8'b0,tap_6_i};
	assign tap_7 = {8'b0,tap_7_i};
    end
    else begin :not_expand_input
	assign tap_0 = tap_0_i;
	assign tap_1 = tap_1_i;
	assign tap_2 = tap_2_i;
	assign tap_3 = tap_3_i;
	assign tap_4 = tap_4_i;
	assign tap_5 = tap_5_i;
	assign tap_6 = tap_6_i;
	assign tap_7 = tap_7_i;
    end
endgenerate
generate
if ( TYPE == 0 ) begin : half_ip
	if( LAST ) begin
			assign val = (((-1)*(tap_0 + tap_7)+4*(tap_1 + tap_6)+(-11)*(tap_2 + tap_5)+40*(tap_3 + tap_4)) + 32 ) >> 6;
	end
	else begin
		if ( HOR ) begin
			assign val = (((-1)*(tap_0 + tap_7)+4*(tap_1 + tap_6)+(-11)*(tap_2 + tap_5)+40*(tap_3 + tap_4))-8192);
		end
		else begin
			assign val = (((-1)*(tap_0 + tap_7)+4*(tap_1 + tap_6)+(-11)*(tap_2 + tap_5)+40*(tap_3 + tap_4))+526336)>>12;
		end
	end
end
else if ( TYPE == 1) begin : q1_ip
	if ( LAST ) begin
			assign val = (((-1)*tap_0+4*tap_1+(-10)*tap_2+58*tap_3+ 17*tap_4+(-5)*tap_5+tap_6) + 32 ) >> 6;
	end
	else begin
		if ( HOR ) begin
			assign val = (((-1)*tap_0+4*tap_1+(-10)*tap_2+58*tap_3+ 17*tap_4+(-5)*tap_5+tap_6) -8192 );
		end
		else begin
			assign val = (((-1)*tap_0+4*tap_1+(-10)*tap_2+58*tap_3+ 17*tap_4+(-5)*tap_5+tap_6)+526336)>>12;
		end
	end
end
else begin : q3_ip
	if ( LAST ) begin
			assign val = ((tap_1 + (-5)*tap_2 + 17*tap_3 + 58*tap_4 + (-10)*tap_5 + 4*tap_6 + (-1)*tap_7) + 32 ) >> 6;
	end
	else begin
		if ( HOR ) begin
			assign val = ((tap_1 + (-5)*tap_2 + 17*tap_3 + 58*tap_4 + (-10)*tap_5 + 4*tap_6 + (-1)*tap_7) -8192);
		end
		else begin
			assign val = ((tap_1 + (-5)*tap_2 + 17*tap_3 + 58*tap_4 + (-10)*tap_5 + 4*tap_6 + (-1)*tap_7) +526336)>>12;
			assign val_tmp = (tap_1 + (-5)*tap_2 + 17*tap_3 + 58*tap_4 + (-10)*tap_5 + 4*tap_6 + (-1)*tap_7) +526336;
		end
	end
end


endgenerate

generate

if(OUT_EXPAND == 0) begin
	clip u_clip (.val_in(val),.val_out(val_o));	
end
else begin
	assign val_o = val;
end

endgenerate

endmodule








