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
//  Filename      : mc_chroma_ip_1p.v
//  Created On    : 2013-11-20 20:08:52
//  Last Modified : 2015-01-09 21:12:26
//  Revision      :
//  Author        : Yufeng Bai
//  Email         : byfchina@gmail.com
//  Description   :
//-------------------------------------------------------------------

`include "enc_defines.v"

module mc_chroma_ip_1p (

    clk,
    rstn,

    blk_start_i,

    fracx_i,
    fracy_i,

    ref_valid_i,
    refuv_p0_i,
    refuv_p1_i,
    refuv_p2_i,
    refuv_p3_i,

    fracuv_valid_o,
    fracuv_p_o
);


// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input                   clk           ;
input                   rstn          ;
input                   blk_start_i   ;

input  [2          :0]  fracx_i       ;
input  [2          :0]  fracy_i       ;

input                   ref_valid_i   ;
input  [`PIXEL_WIDTH-1:0] refuv_p0_i    ;
input  [`PIXEL_WIDTH-1:0] refuv_p1_i    ;
input  [`PIXEL_WIDTH-1:0] refuv_p2_i    ;
input  [`PIXEL_WIDTH-1:0] refuv_p3_i    ;


output                  fracuv_valid_o;
output [`PIXEL_WIDTH-1:0] fracuv_p_o   ;

// ********************************************
//
//    Register DECLARATION
//
// ********************************************

reg  signed [2*`PIXEL_WIDTH-1:0]  ver_p0        ;
reg  signed [2*`PIXEL_WIDTH-1:0]  ver_p1        ;
reg  signed [2*`PIXEL_WIDTH-1:0]  ver_p2        ;
reg  signed [2*`PIXEL_WIDTH-1:0]  ver_p3        ;

reg   [2           :0]  row_cnt       ;

reg                     fracuv_valid  ;
reg   [2           :0]  fracy_pipeline;
reg   [2           :0]  fracx_pipeline;

// ********************************************
//
//    Wire DECLARATION
//
// ********************************************
wire signed [2*`PIXEL_WIDTH-1:0]  hor_p_out     ;
wire  [`PIXEL_WIDTH-1:0]  ver_p_out     ;

wire  [`PIXEL_WIDTH-1:0] ver_p0_w ;
// ********************************************
//
//    Combinational Logic
//
// ********************************************

// ********************************************
//
//    Sequential Logic
//
// ********************************************
always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    ver_p0   <= 'd0    ;
    ver_p1   <= 'd0    ;
    ver_p2   <= 'd0    ;
    ver_p3   <= 'd0    ;
  end
  else if (ref_valid_i) begin
    ver_p0   <= hor_p_out   ;
    ver_p1   <= ver_p0      ;
    ver_p2   <= ver_p1      ;
    ver_p3   <= ver_p2      ;

  end
end


always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    fracy_pipeline  <= 'd0;    
    fracx_pipeline  <= 'd0;    
  end 
  else begin
    fracy_pipeline  <= fracy_i;
    fracx_pipeline  <= fracx_i;
  end
end


always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    row_cnt <= 'd0;
  end
  else if (blk_start_i)begin
    row_cnt <= 'd0;
  end
  else if (ref_valid_i) begin
    //if(fracy_i == 'd0 || row_cnt == 'd7)
    if(fracy_pipeline == 'd0 || row_cnt == 'd7)
        row_cnt <= 'd1;
    else 
        row_cnt <= row_cnt + 'd1;
  end
end



/*
always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    fracuv_valid_o <= 'd0;
    fracuv_p_o     <= 'd0;
  end
  else if (fracy_i ==  'd0) begin
    fracuv_valid_o <= ref_valid_i;
    fracuv_p_o     <= hor_p_out;
  end
  else if (row_cnt[2]) begin  // 4 <= row_cnt <= 7
    fracuv_valid_o <= 1'b1;
    fracuv_p_o     <= ver_p_out;
  end
  else begin
    fracuv_valid_o <= 1'b0;
    fracuv_p_o     <= 'd0;
  end
end
*/
always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
  fracuv_valid <= 'd0; 
  end 
  else if (blk_start_i)
    fracuv_valid <= 'd0;
  else 
    fracuv_valid <= ref_valid_i;
end

assign ver_p0_w = ver_p0 > 'd255 ? 'd255 : (ver_p0 < 0 ? 0 : ver_p0[`PIXEL_WIDTH-1:0]);

assign fracuv_valid_o = ((fracy_pipeline == 'd0) || (row_cnt[2])) && (fracuv_valid);
assign fracuv_p_o     = (fracy_pipeline == 'd0) ? ver_p0_w : ver_p_out;


/*
    p   p   p   p

          p
          p
          p
          p
*/

mc_chroma_filter_hor filter_hor(
  .frac_x (fracx_i),
  .frac_y (fracy_i),
  .A    (refuv_p0_i),
  .B    (refuv_p1_i),
  .C    (refuv_p2_i),
  .D    (refuv_p3_i),
  .out  (hor_p_out)
);

mc_chroma_filter_ver filter_ver(
  .frac_x (fracx_pipeline),
  .frac_y (fracy_pipeline),
  .A    (ver_p3),
  .B    (ver_p2),
  .C    (ver_p1),
  .D    (ver_p0),
  .out  (ver_p_out)
);

endmodule

