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
//  Filename      : mc_chroma_ip4x4.v
//  Created On    : 2013-11-18 12:42:37
//  Last Modified : 2013-11-24 16:38:17
//  Revision      :
//  Author        : Yufeng Bai
//  Email         : byfchina@gmail.com
//  Description   :
//-------------------------------------------------------------------


`include "enc_defines.v"

module mc_chroma_ip4x4(
          clk,
          rstn,

          frac_i,

          blk_start_i,

          refuv_valid_i,
          refuv_p0_i,
          refuv_p1_i,
          refuv_p2_i,
          refuv_p3_i,
          refuv_p4_i,
          refuv_p5_i,
          refuv_p6_i,

          frac_valid_o   ,
          end_oneblk_ip_o,
          fracuv_o
);


// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************
input                   clk;
input                   rstn;
input  [5          :0]  frac_i;

input                   blk_start_i;

input                   refuv_valid_i;

input  [`PIXEL_WIDTH-1:0] refuv_p0_i;
input  [`PIXEL_WIDTH-1:0] refuv_p1_i;
input  [`PIXEL_WIDTH-1:0] refuv_p2_i;
input  [`PIXEL_WIDTH-1:0] refuv_p3_i;
input  [`PIXEL_WIDTH-1:0] refuv_p4_i;
input  [`PIXEL_WIDTH-1:0] refuv_p5_i;
input  [`PIXEL_WIDTH-1:0] refuv_p6_i;

output                  end_oneblk_ip_o;
output                  frac_valid_o;
output [4*`PIXEL_WIDTH-1:0] fracuv_o;



// ********************************************
//
//    Register DECLARATION
//
// ********************************************

reg [1:0] cnt_ip_row;

//reg end_oneblk_ip_o;

reg                  frac_valid_o;
reg [4*`PIXEL_WIDTH-1:0] fracuv_o;

// ********************************************
//
//    Wire DECLARATION
//
// ********************************************

wire [2:0] fracx;
wire [2:0] fracy;


wire fracuv_valid;

wire [`PIXEL_WIDTH-1:0] fracuv_p0;
wire [`PIXEL_WIDTH-1:0] fracuv_p1;
wire [`PIXEL_WIDTH-1:0] fracuv_p2;
wire [`PIXEL_WIDTH-1:0] fracuv_p3;


assign fracx = frac_i[2:0];
assign fracy = frac_i[5:3];

// ********************************************
//
//    Sequential Logic   Combinational Logic
//
// ********************************************
always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    cnt_ip_row      <= 'd0;
  end
  else if (blk_start_i || (end_oneblk_ip_o)) begin
    cnt_ip_row      <= 'd0;
  end
  else if (frac_valid_o) begin
        cnt_ip_row      <= cnt_ip_row + 'd1;
  end
end

assign end_oneblk_ip_o = (cnt_ip_row == 'd3);

// ********************************************
//
//    Sub Module
//
// ********************************************
always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    fracuv_o    <=   'd0;
    frac_valid_o<=   'd0;
  end
  else if (fracuv_valid) begin
    fracuv_o    <=   {fracuv_p0,fracuv_p1,fracuv_p2,fracuv_p3};
    frac_valid_o<=   'd1;
  end
  else begin
    fracuv_o    <=  fracuv_o;
    frac_valid_o<=  'd0;
  end
end


mc_chroma_ip_1p mc_chroma_ip0(
  .clk        (clk),
  .rstn      (rstn),

  .blk_start_i  (blk_start_i),

  .fracx_i      (fracx),
  .fracy_i      (fracy),

  .ref_valid_i  (refuv_valid_i),
  .refuv_p0_i   (refuv_p0_i),
  .refuv_p1_i   (refuv_p1_i),
  .refuv_p2_i   (refuv_p2_i),
  .refuv_p3_i   (refuv_p3_i),

  .fracuv_valid_o(fracuv_valid),
  .fracuv_p_o  (fracuv_p0)
);

mc_chroma_ip_1p mc_chroma_ip1(
  .clk        (clk),
  .rstn      (rstn),

  .blk_start_i  (blk_start_i),

  .fracx_i      (fracx),
  .fracy_i      (fracy),

  .ref_valid_i  (refuv_valid_i),
  .refuv_p0_i   (refuv_p1_i),
  .refuv_p1_i   (refuv_p2_i),
  .refuv_p2_i   (refuv_p3_i),
  .refuv_p3_i   (refuv_p4_i),

  .fracuv_valid_o(/*fracuv_valid*/),
  .fracuv_p_o  (fracuv_p1)
);

mc_chroma_ip_1p mc_chroma_ip2(
  .clk        (clk),
  .rstn      (rstn),

  .blk_start_i  (blk_start_i),

  .fracx_i      (fracx),
  .fracy_i      (fracy),

  .ref_valid_i  (refuv_valid_i),
  .refuv_p0_i   (refuv_p2_i),
  .refuv_p1_i   (refuv_p3_i),
  .refuv_p2_i   (refuv_p4_i),
  .refuv_p3_i   (refuv_p5_i),

  .fracuv_valid_o(/*fracuv_valid*/),
  .fracuv_p_o  (fracuv_p2)
);

mc_chroma_ip_1p mc_chroma_ip3(
  .clk        (clk),
  .rstn      (rstn),

  .blk_start_i  (blk_start_i),

  .fracx_i      (fracx),
  .fracy_i      (fracy),

  .ref_valid_i  (refuv_valid_i),
  .refuv_p0_i   (refuv_p3_i),
  .refuv_p1_i   (refuv_p4_i),
  .refuv_p2_i   (refuv_p5_i),
  .refuv_p3_i   (refuv_p6_i),

  .fracuv_valid_o(/*fracuv_valid*/),
  .fracuv_p_o  (fracuv_p3)
);

endmodule
