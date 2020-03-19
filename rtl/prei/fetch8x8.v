//======================================
//
//  Filename      : fetch8x8.v
//  Created On    : 2015-01-03
//  Author        : Yanheng Lu
//  Description   : original 8x8 block pixels fetch
//
//======================================
module fetch8x8(
	clk,
	rstn,
	
	enable,
	cnt,
	blockcnt,
	finish,
	rf_512bit,
	
	md_ren_o,	
	md_sel_o,	
	md_size_o,	
	md_4x4_x_o,	
	md_4x4_y_o,
	md_idx_o,	
	md_data_i	
);

	input						clk;
	input						rstn;
	input						enable;

	output		[5:0]			cnt;
	output		[6:0]			blockcnt;
	output      [511:0]         rf_512bit;
	input						finish;
	output						md_ren_o	;
	output						md_sel_o	;
	output		[1:0]			md_size_o	;
	output		[3:0]			md_4x4_x_o	;
	output		[3:0]			md_4x4_y_o	;
	output		[4:0]			md_idx_o	;
	input		[255:0]			md_data_i	;
	
	reg							md_ren_o	;
	wire						md_sel_o	;
	wire		[1:0]			md_size_o	;
	wire		[3:0]			md_4x4_x_o	;
	wire		[3:0]			md_4x4_y_o	;
	wire		[4:0]			md_idx_o	;
	reg         [511:0]         rf_512bit;
			
	reg			[5:0]			cnt;
	reg			[6:0]			blockcnt;
	wire		[255:0]			rdata;
	reg							flag;
	
//=====================================================================================
	
	assign		md_sel_o	=	1'b0;
	assign		md_size_o	=	2'b01;
	assign		md_idx_o	=	{2'b00,flag,2'b00};
	assign		md_4x4_x_o	=	{blockcnt[4],blockcnt[2],blockcnt[0],1'b0};
	assign		md_4x4_y_o	=	{blockcnt[5],blockcnt[3],blockcnt[1],1'b0};
	
	assign		rdata		=	md_data_i;
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			flag	<=	1'b0;
		else
			flag	<=	cnt[3];
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			cnt <= 'd0;
		else if((cnt == 'd40)||finish)
			cnt <= 'd0;
		else if(enable)
			cnt <= cnt + 1'b1;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			blockcnt <= 'd0;
		else if(enable && (cnt == 'd32))
			blockcnt <= blockcnt + 1'b1;
		else if(finish)
			blockcnt <=	'd0;
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			md_ren_o	<=	1'b0;
		else if((cnt == 'd0)&&enable)
			md_ren_o	<=	1'b1;
		else if(cnt == 'd17)
			md_ren_o	<=	1'b0;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			rf_512bit <= 512'b0;
		else if(cnt == 'd2)
			rf_512bit <= {rdata,rf_512bit[255:0]};
		else if(cnt == 'd10)
			rf_512bit <= {rf_512bit[511:256],rdata};
			
endmodule
