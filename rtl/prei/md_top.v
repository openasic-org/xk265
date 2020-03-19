//======================================
//
//      intra mode desicion top
//		 luyanheng
//
//======================================
module md_top(
	clk,
	rstn,
	enable,
	rf_512bit,

	bestmode_o,
	bestmode16_o,
	bestmode32_o,
	bestmode64_o,
	modebest64,
	finish
);

	parameter		MODE=21;
	parameter		DIGIT=0;

	input							clk;
	input							rstn;
	input							enable;
	output							finish;
	input       [511:0]             rf_512bit;

	output		[5:0]				bestmode_o;
	output		[5:0]				bestmode16_o;
	output		[5:0]				bestmode32_o;	
	output		[5:0]				bestmode64_o;
	output      [MODE-DIGIT+6:0]	modebest64;
			
	wire							finish;
	wire		[3:0]				sram_raddr;
	wire							sram_read;
	wire							newblock;
	wire		[5:0]				cnt;
	wire		[6:0]				blockcnt;
	wire        [511:0]             rf_512bit;
		
	wire		[5:0]				bestmode;
	wire		[5:0]				bestmode16;
	wire		[5:0]				bestmode32;
	wire		[5:0]				bestmode64;
	wire		[5:0]				bestmode_o;
	wire		[5:0]				bestmode16_o;
	wire		[5:0]				bestmode32_o;
	wire		[5:0]				bestmode64_o;
	wire		[MODE-DIGIT:0]		modebest;
	wire		[MODE-DIGIT+2:0]	modebest16;
	wire		[MODE-DIGIT+4:0]	modebest32;
	wire		[MODE-DIGIT+6:0]	modebest64;
	
	wire		[MODE:0]			mode2;
	wire		[MODE:0]			mode3;
	wire		[MODE:0]			mode4;
	wire		[MODE:0]			mode5;
	wire		[MODE:0]			mode6;
	wire		[MODE:0]			mode7;
	wire		[MODE:0]			mode8;
	wire		[MODE:0]			mode9;
	wire		[MODE:0]			mode10;
	wire		[MODE:0]			mode11;
	wire		[MODE:0]			mode12;
	wire		[MODE:0]			mode13;
	wire		[MODE:0]			mode14;
	wire		[MODE:0]			mode15;
	wire		[MODE:0]			mode16;
	wire		[MODE:0]			mode17;
	wire		[MODE:0]			mode18;
	wire		[MODE:0]			mode19;
	wire		[MODE:0]			mode20;
	wire		[MODE:0]			mode21;
	wire		[MODE:0]			mode22;
	wire		[MODE:0]			mode23;
	wire		[MODE:0]			mode24;
	wire		[MODE:0]			mode25;
	wire		[MODE:0]			mode26;
	wire		[MODE:0]			mode27;
	wire		[MODE:0]			mode28;
	wire		[MODE:0]			mode29;
	wire		[MODE:0]			mode30;
	wire		[MODE:0]			mode31;
	wire		[MODE:0]			mode32;
	wire		[MODE:0]			mode33;
	
	wire							gxgyrun;
	wire							counterrun1;
	wire							counterrun2;
	
	wire		[10:0]				gx;
	wire		[10:0]				gy;
	wire		[23:0]				x1;
	wire		[23:0]				x2;
	wire		[23:0]				x3;
	
//===========================================================================
	
	md_fetch fetch1(
		.clk			( clk			),
		.rstn			( rstn			),
		.enable			( enable		),
		.cnt			( cnt			),
		.rf_512bit      ( rf_512bit     ),
		.x1				( x1			),
		.x2				( x2			),
		.x3				( x3			)
);//data fetch

	control control1(
		.clk			( clk			),
		.rstn			( rstn			),
		
		.enable			( enable		),
		.newblock		( newblock		),
		.gxgyrun		( gxgyrun		),
		.cyclecnt		( cnt			),
		.blockcnt		( blockcnt		),
		.counterrun1	( counterrun1	),
		.counterrun2	( counterrun2	),
		.finish			( finish		)
);// module controller

	gxgy gxgy1(
		.clk			( clk			),
		.rstn			( rstn			),
		
		.gxgyrun		( gxgyrun		),
		.x1				( x1			),
		.x2				( x2			),
		.x3				( x3			),
		.gx				( gx			),
		.gy				( gy			)
);// gxgy calculation
	
	counter counter1(
	.clk				( clk			),
	.rstn				( rstn			),
	
	.counterrun1		( counterrun1	),
	.counterrun2		( counterrun2	),
	.gx					( gx			),
	.gy					( gy			),
	
	.mode2				( mode2			),
	.mode3				( mode3			),
	.mode4				( mode4			),
	.mode5				( mode5			),
	.mode6				( mode6			),
	.mode7				( mode7			),
	.mode8				( mode8			),
	.mode9				( mode9			),
	.mode10				( mode10		),
	.mode11				( mode11		),
	.mode12				( mode12		),
	.mode13				( mode13		),
	.mode14				( mode14		),
	.mode15				( mode15		),
	.mode16				( mode16		),
	.mode17				( mode17		),
	.mode18				( mode18		),
	.mode19				( mode19		),
	.mode20				( mode20		),
	.mode21				( mode21		),
	.mode22				( mode22		),
	.mode23				( mode23		),
	.mode24				( mode24		),
	.mode25				( mode25		),
	.mode26				( mode26		),
	.mode27				( mode27		),
	.mode28				( mode28		),
	.mode29				( mode29		),
	.mode30				( mode30		),
	.mode31				( mode31		),
	.mode32				( mode32		),
	.mode33				( mode33		)	
);//mode gradient value calculation

	compare		compare1(
	.clk				( clk			),
	.rstn				( rstn			),
	
	.cnt				( cnt			),
	.blockcnt			( blockcnt		),
	.bestmode			( bestmode		),
	.bestmode16			( bestmode16	),
	.bestmode32			( bestmode32	),
	.bestmode64			( bestmode64	),
	.modebest			( modebest		),
	.modebest16			( modebest16	),
	.modebest32			( modebest32	),
	.modebest64			( modebest64	),
	
	.mode2				( mode2			),
	.mode3				( mode3			),
	.mode4				( mode4			),
	.mode5				( mode5			),
	.mode6				( mode6			),
	.mode7				( mode7			),
	.mode8				( mode8			),
	.mode9				( mode9			),
	.mode10				( mode10		),
	.mode11				( mode11		),
	.mode12				( mode12		),
	.mode13				( mode13		),
	.mode14				( mode14		),
	.mode15				( mode15		),
	.mode16				( mode16		),
	.mode17				( mode17		),
	.mode18				( mode18		),
	.mode19				( mode19		),
	.mode20				( mode20		),
	.mode21				( mode21		),
	.mode22				( mode22		),
	.mode23				( mode23		),
	.mode24				( mode24		),
	.mode25				( mode25		),
	.mode26				( mode26		),
	.mode27				( mode27		),
	.mode28				( mode28		),
	.mode29				( mode29		),
	.mode30				( mode30		),
	.mode31				( mode31		),
	.mode32				( mode32		),
	.mode33				( mode33		)	
);// best angle mode decision

	dc_planar	dc_planar1(
	.rstn				( rstn			),
	.clk				( clk			),
	
	.counterrun1		( counterrun1	),
	.counterrun2		( counterrun2	),
	.cnt				( cnt			),
	.blockcnt			( blockcnt		),
	.gx					( gx			),
	.gy					( gy			),
	.bestmode			( bestmode		),
	.bestmode16			( bestmode16	),
	.bestmode32			( bestmode32	),
	.bestmode64			( bestmode64	),
	.modebest			( modebest		),
	.modebest16			( modebest16	),
	.modebest32			( modebest32	),
	.modebest64			( modebest64	),
	
	.bestmode_o			( bestmode_o	),
	.bestmode16_o		( bestmode16_o	),
	.bestmode32_o		( bestmode32_o	),
	.bestmode64_o		( bestmode64_o	)
);// mode decision of Plannar/DC/best angle mode
			
endmodule
