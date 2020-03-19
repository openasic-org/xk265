//-------------------------------------------------------------------
//
//  Filename      : control.v
//  Created On    : 2014-03-28
//  Updated On    : 2015-03-09
//  Author        : Yanheng Lu
//  Description   : controller for pre_intra(mode decision)
//
//-------------------------------------------------------------------

module control(
	rstn,
	clk,
	enable,
	cyclecnt,
	blockcnt,
	newblock,
	gxgyrun,
	counterrun1,
	counterrun2,
	finish
);

	input				rstn;
	input				clk;
	
	input				enable;
	output	[5:0]		cyclecnt;
	output	[6:0]		blockcnt;
	output				gxgyrun;
	output				counterrun1;
	output				counterrun2;
	output				finish;
	output				newblock;
	
	reg					gxgyrun;
	reg					counterrun1;
	reg					counterrun2;
	reg					finish;
	reg					newblock;
	
	reg		[5:0]		cyclecnt;
	reg		[6:0]		blockcnt;
	
	reg		[2:0]		tid_o;		
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			newblock	<=	1'b0;
		else	if(cyclecnt	==	'd40)
			newblock	<=	1'b1;
		else
			newblock	<=	1'b0;
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			cyclecnt <= 'd0;
		else if((cyclecnt == 'd40) || finish)
			cyclecnt <= 'd0;
		else if(enable)
			cyclecnt <= cyclecnt + 1'b1;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			blockcnt <= 'd0;
		else if(enable && (cyclecnt == 'd40))
			blockcnt <= blockcnt + 1'b1;
		else if(finish)
			blockcnt <= 'd0;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			gxgyrun <= 'd0;
		else if((cyclecnt == 'd5)  && (blockcnt != 'd64))
			gxgyrun <= 1'b1;
		else if(cyclecnt == 'd1) 
			gxgyrun <= 1'b0;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			counterrun1 <= 'd0;
		else
			counterrun1 <= gxgyrun;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			counterrun2 <= 'd0;
		else
			counterrun2 <= counterrun1;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			finish <= 1'b0;
		else if((blockcnt == 'd65) && (cyclecnt == 'd15))
			finish <= 1'b1;
		else if(enable)
			finish <= 1'b0;
	
endmodule
	