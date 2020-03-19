//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
// THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
// EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//-------------------------------------------------------------------
//
//  Filename      : mc_chroma_filter.v
//  Created On    : 2013-11-21 09:53:59
//  Last Modified : 2013-11-21 18:38:15
//  Revision      :
//  Author        : Yufeng Bai
//  Email         : byfchina@gmail.com
//  Description   :
//-------------------------------------------------------------------

`include "enc_defines.v"

module mc_chroma_filter_hor(
  frac_x,
  frac_y,
  A,
  B,
  C,
  D,
  out
);

input [2:0] frac_x,frac_y;
input [`PIXEL_WIDTH-1:0] A;
input [`PIXEL_WIDTH-1:0] B;
input [`PIXEL_WIDTH-1:0] C;
input [`PIXEL_WIDTH-1:0] D;

output signed [2*`PIXEL_WIDTH-1:0] out;


reg signed [2*`PIXEL_WIDTH-1:0] sum;
wire signed [2*`PIXEL_WIDTH-1:0] sum_w;
wire signed [2*`PIXEL_WIDTH-6-1:0] sum_shift_6_w;

reg        [`PIXEL_WIDTH-1:  0] pel_out; // pixel output directly
wire signed [2*`PIXEL_WIDTH-1:0] val_out; // val output


/*NEED TO BE OPTIMIAED*/

always @(*) begin
  case(frac_x)
    'd0:  sum = (B*64);
    'd1:  sum = B*58 + C*10 - ((A + D) *2);
    'd2:  sum = B*54 + C*16 - ((A*2 + D) *2);
    'd3:  sum = B*46 + C*28 - (A*6 + D*4);
    'd4:  sum = 36*(B+C) - ((A+D)*4);
    'd5:  sum = C*46 + 28*B - (D*6 + A*4);
    'd6:  sum = C*54 + B*16 - (D*4 + A*2);
    'd7:  sum = C*58 + B*10 - ((A + D) *2);
  endcase
end

// val out

assign val_out = sum - 'd8192;

// pel out
// always @(*) begin
//   if (((sum+'d32) >> 6) < 0)
//     pel_out = 'd0;
//   else if (((sum+'d32) >> 6) > 255)begin
//     pel_out = 'd255;
//   end
//   else begin
//     pel_out = (sum+'d32) >> 6;
//   end
// end

assign sum_w = sum+'d32 ;

assign sum_shift_6_w = sum_w[2*`PIXEL_WIDTH-1:6];

always @(*) begin
  if ( sum_shift_6_w < 0 )
    pel_out = 'd0;
  else if (sum_shift_6_w > 255)begin
    pel_out = 'd255;
  end
  else begin
    pel_out = sum_shift_6_w;
  end
end

assign out = (frac_x == 0 || frac_y == 0 ) ? {{`PIXEL_WIDTH{1'b0}}, pel_out} : val_out;

endmodule

module mc_chroma_filter_ver(
  frac_x,
  frac_y,
  A,
  B,
  C,
  D,
  out
);

input [2:0] frac_x,frac_y;
input signed [2*`PIXEL_WIDTH-1:0] A;
input signed [2*`PIXEL_WIDTH-1:0] B;
input signed [2*`PIXEL_WIDTH-1:0] C;
input signed [2*`PIXEL_WIDTH-1:0] D;

output reg [`PIXEL_WIDTH-1:0] out;


reg signed [4*`PIXEL_WIDTH-1:0] sum;
wire signed [2*`PIXEL_WIDTH-1:0] clip;
wire signed [2*`PIXEL_WIDTH-1:0] val, pel;


/*NEED TO BE OPTIMIAED*/

always @(*) begin
  case(frac_y)
    'd0:  sum = (B*64);
    'd1:  sum = B*58 + C*10 - ((A + D) *2);
    'd2:  sum = B*54 + C*16 - ((A*2 + D) *2);
    'd3:  sum = B*46 + C*28 - (A*6 + D*4);
    'd4:  sum = 36*(B+C) - ((A+D)*4);
    'd5:  sum = C*46 + 28*B - (D*6 + A*4);
    'd6:  sum = C*54 + B*16 - (D*4 + A*2);
    'd7:  sum = C*58 + B*10 - ((A + D) *2);
  endcase
end

// from val 

assign val = (sum + 'd526336) >> 12;

// from pel 
assign pel = (sum + 'd32) >> 6;

assign clip = (frac_x == 0) ? pel : val;


always @(*) begin
  if (clip < 0)
    out = 'd0;
  else if (clip > 255)begin
    out = 'd255;
  end
  else begin
    out = clip;
  end
end

endmodule
