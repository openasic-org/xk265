//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner 	  : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//-----------------------------------------------------------------------------------------------------------------------------
// Filename       : cabac_pipo.v
// Author         : liwei
// Created        : 2018/9/13
// Description    : buffer
// DATA & EDITION:	2018/9/13	1.0		liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module cabac_pipo(
	clk,
	rst_n,
	data_i,
	wr_i,
	wack_i,
	data_o,
	data_valid_o
	);

//---------------input and output declaration---------------//
input clk;
input rst_n;
input [75:0] data_i;

input wr_i;
input wack_i;//from binarization

output [75:0] data_o;
output data_valid_o;

//-----------------reg and wire declaration-----------------//
wire [75:0] data_o;
wire rd_r;
reg full_r,empty_r;
reg [75:0] mem [7:0];
reg [2:0] rdpoint_r,wrpoint_r;

//--------------------------logic-------------------------//
//write in
integer i;
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
	begin
		for(i=0; i<8; i=i+1)
			mem[i] <= 0;	
	end
	else if(wr_i && ~full_r)
		mem[wrpoint_r] <= data_i;
	else 
		mem[wrpoint_r] <= mem[wrpoint_r];
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		wrpoint_r <= 3'b0;	
	else if (wr_i && ~full_r)
		wrpoint_r <= wrpoint_r + 1'b1; 
	else begin
		wrpoint_r <= wrpoint_r;
	end
end

//read out
assign rd_r = wack_i ? (!empty_r) : 1'b0;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		rdpoint_r <= 3'b0;
	else if(rd_r && ~empty_r)
		rdpoint_r <= rdpoint_r + 1'b1;
	else 
		rdpoint_r <= rdpoint_r;
end

//full signal generate
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		full_r <= 1'b0;
	else if((~rd_r && wr_i) && ((wrpoint_r == rdpoint_r - 1'b1)||(rdpoint_r == 3'b0 && wrpoint_r == 3'b111)))
		full_r <= 1'b1;
	else if(full_r && rd_r)
		full_r <= 1'b0;
	else 
		full_r <= 1'b0;
end

//empty signal generate
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		empty_r <= 1'b1;
	else if((rd_r && ~wr_i) && ((rdpoint_r == wrpoint_r - 1'b1)||(rdpoint_r == 3'b111 && wrpoint_r == 3'b0)))
		empty_r <= 1'b1;
	else if(empty_r && wr_i)
		empty_r <= 1'b0;
	else 
		empty_r <= empty_r;
end

//output
assign data_o = rd_r? mem[rdpoint_r] : 0;
assign data_valid_o = rd_r;

endmodule

