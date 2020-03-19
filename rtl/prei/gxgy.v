//========================
//
//     luyanheng
//     2014-03-27
//
//========================
module gxgy(
	clk,
	rstn,
	gxgyrun,
	x1,
	x2,
	x3,
	gx,
	gy
);

	input					clk;
	input					rstn;
	input					gxgyrun;
	input	[23:0]			x1;
	input	[23:0]			x2;
	input	[23:0]			x3;
	output	signed	[10:0]			gx;
	output	signed	[10:0]			gy;
	
	reg				[10:0]			gx;
	reg				[10:0]			gy;
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			begin
				gx<='d0;
				gy<='d0;
			end
		else if(gxgyrun)
			begin
				gy<=x1[7:0]+x1[15:8]*2+x1[23:16]-x3[7:0]-x3[15:8]*2-x3[23:16];
				gx<=x1[7:0]+x2[7:0]*2+x3[7:0]-x3[23:16]-x2[23:16]*2-x1[23:16];
			end
		
endmodule
