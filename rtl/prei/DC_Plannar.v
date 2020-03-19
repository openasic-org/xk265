//==================================
// dc_planar
// luyanheng
// creat:2014-9-16
// modify:2015-1-9
//==================================
module dc_planar(
	rstn,
	clk,
	counterrun1,
	counterrun2,
	gx,
	gy,
	cnt,
	blockcnt,
	bestmode,
	bestmode16,
	bestmode32,
	bestmode64,
	modebest,
	modebest16,
	modebest32,
	modebest64,
	bestmode_o,
	bestmode16_o,
	bestmode32_o,
	bestmode64_o
);

	parameter		MODE=21;
	parameter		DIGIT=0;
	parameter		DC8=288;
	parameter		DC16=1152;
	parameter		DC32=4608;
	parameter		DC64=18432;
	parameter		Plan8=32;
	parameter		Plan16=32;
	parameter		Plan32=32;
	parameter		Plan64=32;
	
	input							rstn;
	input							clk;
	input							counterrun1;
	input							counterrun2;
	input	signed	[10:0]			gx;
	input	signed	[10:0]			gy;
	input			[5:0]			cnt;
	input			[6:0]			blockcnt;
	input			[5:0]			bestmode;
	input			[5:0]			bestmode16;
	input			[5:0]			bestmode32;
	input			[5:0]			bestmode64;
	input		[MODE-DIGIT:0]		modebest;
	input		[MODE-DIGIT+2:0]	modebest16;
	input		[MODE-DIGIT+4:0]	modebest32;
	input		[MODE-DIGIT+6:0]	modebest64;
	output			[5:0]			bestmode_o;
	output			[5:0]			bestmode16_o;
	output			[5:0]			bestmode32_o;
	output			[5:0]			bestmode64_o;
	
	reg			[10:0]				data_tmp;
	reg			[15:0]				modedata;
	reg			[15:0]				modedata8;
	reg			[17:0]				modedata16;
	reg			[19:0]				modedata32;
	reg			[19:0]				modedata64;
	
	reg			[5:0]				bestmode_o;
	reg			[5:0]				bestmode16_o;
	reg			[5:0]				bestmode32_o;
	reg			[5:0]				bestmode64_o;

//==================mode data calculation====================================
	
always@(posedge clk or negedge rstn)
	if(!rstn)
		data_tmp	<=	'd0;
	else if(counterrun1)
		data_tmp	<=	(gx[10]?(-gx):gx) + (gy[10]?(-gy):gy);
		
always@(posedge clk or negedge rstn)
	if(!rstn)
		modedata	<=	'd0;
	else if(counterrun2)
		modedata	<=	modedata+data_tmp;
	else if(counterrun1)
		modedata	<=	'd0;
		
always@(posedge clk or negedge rstn)
	if(!rstn)
		modedata8	<=	'd0;
	else if((blockcnt	!=	'd0)	&&	(cnt	==	'd7))
		modedata8	<=	modedata;
		
always@(posedge clk or negedge rstn)
	if(!rstn)
		modedata16	<=	'd0;
	else if((blockcnt	!=	'd0)	&&	(cnt	==	'd8)	&&	(blockcnt[1:0]	==	2'b01))
		modedata16	<=	modedata8;
	else if((blockcnt	!=	'd0)	&&	(cnt	==	'd8))
		modedata16	<=	modedata16+modedata8;
		
always@(posedge clk or negedge rstn)
	if(!rstn)
		modedata32	<=	'd0;
	else if((blockcnt	!=	'd0)	&&	(cnt	==	'd9)	&&	(blockcnt[3:0]	==	4'b0100))
		modedata32	<=	modedata16;
	else if((blockcnt	!=	'd0)	&&	(cnt	==	'd9)	&&	(blockcnt[1:0]	==	2'b00))
		modedata32	<=	modedata32+modedata16;
		
always@(posedge clk or negedge rstn)
	if(!rstn)
		modedata64	<=	'd0;
	else if((blockcnt	!=	'd0)	&&	(cnt	==	'd10)	&&	(blockcnt[5:0]	==	6'b010000))
		modedata64	<=	modedata32;
	else if((blockcnt	!=	'd0)	&&	(cnt	==	'd10)	&&	(blockcnt[3:0]	==	4'b0000))
		modedata64	<=	modedata64+modedata32;
	
//================best mode decision============================
	
always@(posedge clk or negedge rstn)
	if(!rstn)
		bestmode_o	<=	'd0;
	else if((modedata8	<	DC8)	&&	(blockcnt	!=	'd0)	&&	(cnt	==	'd35))
		bestmode_o	<=	'd1;
	else if((modebest	>	Plan8 * modedata8)	&&	(blockcnt	!=	'd0)	&&	(cnt	==	'd35))
		bestmode_o	<=	'd0;
	else if((blockcnt	!=	'd0)	&&	(cnt	==	'd35))
		bestmode_o	<=	bestmode;
		
always@(posedge clk or negedge rstn)
	if(!rstn)
		bestmode16_o	<=	'd0;
	else if((modedata16	<	DC16)	&&	(blockcnt	!=	'd0)	&&	(cnt	==	'd38)	&&	(blockcnt[1:0]	==	2'b00))
		bestmode16_o	<=	'd1;
	else if((modebest16	>	Plan16 * modedata16)	&&	(blockcnt	!=	'd0)	&&	(cnt	==	'd38)	&&	(blockcnt[1:0]	==	2'b00))
		bestmode16_o	<=	'd0;
	else if((blockcnt	!=	'd0)	&&	(cnt	==	'd38)	&&	(blockcnt[1:0]	==	2'b00))
		bestmode16_o	<=	bestmode16;
		
always@(posedge clk or negedge rstn)
	if(!rstn)
		bestmode32_o	<=	'd0;
	else if((modedata32	<	DC32)	&&	(blockcnt	!=	'd0)	&&	(cnt	==	'd39)	&&	(blockcnt[3:0]	==	4'b0000))
		bestmode32_o	<=	'd1;
	else if((modebest32	>	Plan32 * modedata32)	&&	(blockcnt	!=	'd0)	&&	(cnt	==	'd39)	&&	(blockcnt[3:0]	==	4'b0000))
		bestmode32_o	<=	'd0;
	else if((blockcnt	!=	'd0)	&&	(cnt	==	'd39)	&&	(blockcnt[3:0]	==	4'b0000))
		bestmode32_o	<=	bestmode32;
		
always@(posedge clk or negedge rstn)
	if(!rstn)
		bestmode64_o	<=	'd0;
	else if((modedata64	<	DC64)	&&	(blockcnt	==	'd64)	&&	(cnt	==	'd40))
		bestmode64_o	<=	'd1;
	else if((modebest64	>	Plan64 * modedata64)	&&	(blockcnt	==	'd64)	&&	(cnt	==	'd40))
		bestmode64_o	<=	'd0;
	else if((blockcnt	==	'd64)	&&	(cnt	==	'd40))
		bestmode64_o	<=	bestmode64;
			
endmodule
	