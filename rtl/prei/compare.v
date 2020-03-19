//======================================
//
//      intra mode desicion compare
//		 luyanheng
//
//======================================
module compare(
	clk,
	rstn,
	
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
	
	mode2,
	mode3,
	mode4,
	mode5,
	mode6,
	mode7,
	mode8,
	mode9,
	mode10,
	mode11,
	mode12,
	mode13,
	mode14,
	mode15,
	mode16,
	mode17,
	mode18,
	mode19,
	mode20,
	mode21,
	mode22,
	mode23,
	mode24,
	mode25,
	mode26,
	mode27,
	mode28,
	mode29,
	mode30,
	mode31,
	mode32,
	mode33
);

	parameter		MODE=21;
	parameter		DIGIT=0;

	input								clk;
	input								rstn;
	input			[5:0]				cnt;
	input			[6:0]				blockcnt;
	output			[5:0]				bestmode;
	output			[5:0]				bestmode16;
	output			[5:0]				bestmode32;
	output			[5:0]				bestmode64;
	output			[MODE-DIGIT:0]		modebest;
	output			[MODE-DIGIT+2:0]	modebest16;
	output			[MODE-DIGIT+4:0]	modebest32;
	output			[MODE-DIGIT+6:0]	modebest64;
	input			[MODE:0]			mode2;
	input			[MODE:0]			mode3;
	input			[MODE:0]			mode4;
	input			[MODE:0]			mode5;
	input			[MODE:0]			mode6;
	input			[MODE:0]			mode7;
	input			[MODE:0]			mode8;
	input			[MODE:0]			mode9;
	input			[MODE:0]			mode10;
	input			[MODE:0]			mode11;
	input			[MODE:0]			mode12;
	input			[MODE:0]			mode13;
	input			[MODE:0]			mode14;
	input			[MODE:0]			mode15;
	input			[MODE:0]			mode16;
	input			[MODE:0]			mode17;
	input			[MODE:0]			mode18;
	input			[MODE:0]			mode19;
	input			[MODE:0]			mode20;
	input			[MODE:0]			mode21;
	input			[MODE:0]			mode22;
	input			[MODE:0]			mode23;
	input			[MODE:0]			mode24;
	input			[MODE:0]			mode25;
	input			[MODE:0]			mode26;
	input			[MODE:0]			mode27;
	input			[MODE:0]			mode28;
	input			[MODE:0]			mode29;
	input			[MODE:0]			mode30;
	input			[MODE:0]			mode31;
	input			[MODE:0]			mode32;
	input			[MODE:0]			mode33;
	
//===================state============================
	reg			comparebegin;
	reg			comparebegin16;
	reg			comparerun16;
	reg         comparerun16_reg;
	reg			comparebegin32;
	reg			comparerun32;
	reg         comparerun32_reg;
	reg			comparebegin64;
	reg			comparerun64;
	reg         comparerun64_reg;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			comparerun16	<=	1'b0;
		else if((cnt == 'd4) && (blockcnt[1:0]==2'b00) && (blockcnt[6:2]!=5'b0))
			comparerun16	<=	1'b1;
		else if(cnt == 'd36)
			comparerun16	<=	1'b0;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			comparerun16_reg <= 1'b0;
		else
			comparerun16_reg <= comparerun16;
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			comparerun32	<=	1'b0;
		else if((blockcnt[3:0]=='d0)&&(cnt == 'd5) && (blockcnt[6:4]!=3'b0))
			comparerun32	<=	1'b1;
		else if(cnt == 'd37)
			comparerun32	<=	1'b0;

	always@(posedge clk or negedge rstn)
		if(!rstn)
			comparerun32_reg <= 1'b0;
		else
			comparerun32_reg <= comparerun32;
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			comparebegin	<=	1'b0;
		else	if((cnt == 'd2) && (blockcnt!=7'b0))
			comparebegin	<= 1'b1;
		else
			comparebegin	<= 1'b0;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			comparebegin16	<=	1'b0;
		else
			comparebegin16	<=	comparebegin;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			comparebegin32	<=	1'b0;
		else if(blockcnt[3:0]=='d0)
			comparebegin32	<=	comparebegin16;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			comparebegin64	<=	1'b0;
		else if((blockcnt =='d64) && (cnt == 'd6))
			comparebegin64	<=	1'b1;
		else
			comparebegin64	<=	1'b0;

	always@(posedge clk or negedge rstn)
		if(!rstn)
			comparerun64	<=	1'b0;
		else if((blockcnt=='d64)&&(cnt == 'd6))
			comparerun64	<=	1'b1;
		else if(cnt == 'd38)
			comparerun64	<=	1'b0;	

	always@(posedge clk or negedge rstn)
		if(!rstn)
			comparerun64_reg <= 1'b0;
		else
			comparerun64_reg <= comparerun64;
			
//=======================8*8=========================		
	reg		[5:0]			bestmode;
	reg		[MODE-DIGIT:0]	modebest;
	reg		[MODE-DIGIT:0]	mode_reg;
	reg		[MODE-DIGIT:0]	mode2_reg;
	reg		[MODE-DIGIT:0]	mode3_reg;
	reg		[MODE-DIGIT:0]	mode4_reg;
	reg		[MODE-DIGIT:0]	mode5_reg;
	reg		[MODE-DIGIT:0]	mode6_reg;
	reg		[MODE-DIGIT:0]	mode7_reg;
	reg		[MODE-DIGIT:0]	mode8_reg;
	reg		[MODE-DIGIT:0]	mode9_reg;
	reg		[MODE-DIGIT:0]	mode10_reg;
	reg		[MODE-DIGIT:0]	mode11_reg;
	reg		[MODE-DIGIT:0]	mode12_reg;
	reg		[MODE-DIGIT:0]	mode13_reg;
	reg		[MODE-DIGIT:0]	mode14_reg;
	reg		[MODE-DIGIT:0]	mode15_reg;
	reg		[MODE-DIGIT:0]	mode16_reg;
	reg		[MODE-DIGIT:0]	mode17_reg;
	reg		[MODE-DIGIT:0]	mode18_reg;
	reg		[MODE-DIGIT:0]	mode19_reg;
	reg		[MODE-DIGIT:0]	mode20_reg;
	reg		[MODE-DIGIT:0]	mode21_reg;
	reg		[MODE-DIGIT:0]	mode22_reg;
	reg		[MODE-DIGIT:0]	mode23_reg;
	reg		[MODE-DIGIT:0]	mode24_reg;
	reg		[MODE-DIGIT:0]	mode25_reg;
	reg		[MODE-DIGIT:0]	mode26_reg;
	reg		[MODE-DIGIT:0]	mode27_reg;
	reg		[MODE-DIGIT:0]	mode28_reg;
	reg		[MODE-DIGIT:0]	mode29_reg;
	reg		[MODE-DIGIT:0]	mode30_reg;
	reg		[MODE-DIGIT:0]	mode31_reg;
	reg		[MODE-DIGIT:0]	mode32_reg;
	reg		[MODE-DIGIT:0]	mode33_reg;
		
	always@(posedge clk or negedge rstn)
		if(!rstn)
			begin
				mode2_reg <= 'd0;
				mode3_reg <= 'd0;
				mode4_reg <= 'd0;
				mode5_reg <= 'd0;
				mode6_reg <= 'd0;
				mode7_reg <= 'd0;
				mode8_reg <= 'd0;
				mode9_reg <= 'd0;
				mode10_reg <= 'd0;
				mode11_reg <= 'd0;
				mode12_reg <= 'd0;
				mode13_reg <= 'd0;
				mode14_reg <= 'd0;
				mode15_reg <= 'd0;
				mode16_reg <= 'd0;
				mode17_reg <= 'd0;
				mode18_reg <= 'd0;
				mode19_reg <= 'd0;
				mode20_reg <= 'd0;
				mode21_reg <= 'd0;
				mode22_reg <= 'd0;
				mode23_reg <= 'd0;
				mode24_reg <= 'd0;
				mode25_reg <= 'd0;
				mode26_reg <= 'd0;
				mode27_reg <= 'd0;
				mode28_reg <= 'd0;
				mode29_reg <= 'd0;
				mode30_reg <= 'd0;
				mode31_reg <= 'd0;
				mode32_reg <= 'd0;
				mode33_reg <= 'd0;
			end
		else if(comparebegin)
			begin
				mode2_reg <= mode2[MODE:DIGIT];
				mode3_reg <= mode3[MODE:DIGIT];
				mode4_reg <= mode4[MODE:DIGIT];
				mode5_reg <= mode5[MODE:DIGIT];
				mode6_reg <= mode6[MODE:DIGIT];
				mode7_reg <= mode7[MODE:DIGIT];
				mode8_reg <= mode8[MODE:DIGIT];
				mode9_reg <= mode9[MODE:DIGIT];
				mode10_reg <= mode10[MODE:DIGIT];
				mode11_reg <= mode11[MODE:DIGIT];
				mode12_reg <= mode12[MODE:DIGIT];
				mode13_reg <= mode13[MODE:DIGIT];
				mode14_reg <= mode14[MODE:DIGIT];
				mode15_reg <= mode15[MODE:DIGIT];
				mode16_reg <= mode16[MODE:DIGIT];
				mode17_reg <= mode17[MODE:DIGIT];
				mode18_reg <= mode18[MODE:DIGIT];
				mode19_reg <= mode19[MODE:DIGIT];
				mode20_reg <= mode20[MODE:DIGIT];
				mode21_reg <= mode21[MODE:DIGIT];
				mode22_reg <= mode22[MODE:DIGIT];
				mode23_reg <= mode23[MODE:DIGIT];
				mode24_reg <= mode24[MODE:DIGIT];
				mode25_reg <= mode25[MODE:DIGIT];
				mode26_reg <= mode26[MODE:DIGIT];
				mode27_reg <= mode27[MODE:DIGIT];
				mode28_reg <= mode28[MODE:DIGIT];
				mode29_reg <= mode29[MODE:DIGIT];
				mode30_reg <= mode30[MODE:DIGIT];
			    mode31_reg <= mode31[MODE:DIGIT];
			    mode32_reg <= mode32[MODE:DIGIT];
			    mode33_reg <= mode33[MODE:DIGIT];
			end
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			mode_reg <= 'd0;
		else 
			case(cnt)
				'd3:mode_reg <= mode3[MODE:DIGIT];
				'd4:mode_reg <= mode4_reg;
				'd5:mode_reg <= mode5_reg;
				'd6:mode_reg <= mode6_reg;
				'd7:mode_reg <= mode7_reg;
				'd8:mode_reg <= mode8_reg;
				'd9:mode_reg <= mode9_reg;
				'd10:mode_reg <= mode10_reg;
				'd11:mode_reg <= mode11_reg;
				'd12:mode_reg <= mode12_reg;
				'd13:mode_reg <= mode13_reg;
				'd14:mode_reg <= mode14_reg;
				'd15:mode_reg <= mode15_reg;
				'd16:mode_reg <= mode16_reg;
				'd17:mode_reg <= mode17_reg;
				'd18:mode_reg <= mode18_reg;
				'd19:mode_reg <= mode19_reg;
				'd20:mode_reg <= mode20_reg;
				'd21:mode_reg <= mode21_reg;
				'd22:mode_reg <= mode22_reg;
				'd23:mode_reg <= mode23_reg;
				'd24:mode_reg <= mode24_reg;
				'd25:mode_reg <= mode25_reg;
				'd26:mode_reg <= mode26_reg;
				'd27:mode_reg <= mode27_reg;
				'd28:mode_reg <= mode28_reg;
				'd29:mode_reg <= mode29_reg;
				'd30:mode_reg <= mode30_reg;
				'd31:mode_reg <= mode31_reg;
				'd32:mode_reg <= mode32_reg;
				'd33:mode_reg <= mode33_reg;
				default:mode_reg <= {(MODE-DIGIT+1){1'b1}};
			endcase
		
	always@(posedge clk or negedge rstn)
		if(!rstn)
			begin
				bestmode <= 'd0;
				modebest <= {(MODE-DIGIT+1){1'b1}};
			end
		else if(comparebegin)
			begin
				bestmode <= 'd2;
				modebest <= mode2[MODE:DIGIT];
			end
		else if (modebest > mode_reg) 
			begin
				bestmode <= cnt-1;
				modebest <= mode_reg;
			end
		else
			begin
				bestmode <= bestmode;
				modebest <= modebest;
			end
			
//=======================16*16=======================
	reg		[5:0]		bestmode16;
	reg		[MODE-DIGIT+2:0]	modebest16;
	reg		[MODE-DIGIT+2:0]	mode_reg16;
	reg		[MODE-DIGIT+2:0]	mode2_reg16;
	reg		[MODE-DIGIT+2:0]	mode3_reg16;
	reg		[MODE-DIGIT+2:0]	mode4_reg16;
	reg		[MODE-DIGIT+2:0]	mode5_reg16;
	reg		[MODE-DIGIT+2:0]	mode6_reg16;
	reg		[MODE-DIGIT+2:0]	mode7_reg16;
	reg		[MODE-DIGIT+2:0]	mode8_reg16;
	reg		[MODE-DIGIT+2:0]	mode9_reg16;
	reg		[MODE-DIGIT+2:0]	mode10_reg16;
	reg		[MODE-DIGIT+2:0]	mode11_reg16;
	reg		[MODE-DIGIT+2:0]	mode12_reg16;
	reg		[MODE-DIGIT+2:0]	mode13_reg16;
	reg		[MODE-DIGIT+2:0]	mode14_reg16;
	reg		[MODE-DIGIT+2:0]	mode15_reg16;
	reg		[MODE-DIGIT+2:0]	mode16_reg16;
	reg		[MODE-DIGIT+2:0]	mode17_reg16;
	reg		[MODE-DIGIT+2:0]	mode18_reg16;
	reg		[MODE-DIGIT+2:0]	mode19_reg16;
	reg		[MODE-DIGIT+2:0]	mode20_reg16;
	reg		[MODE-DIGIT+2:0]	mode21_reg16;
	reg		[MODE-DIGIT+2:0]	mode22_reg16;
	reg		[MODE-DIGIT+2:0]	mode23_reg16;
	reg		[MODE-DIGIT+2:0]	mode24_reg16;
	reg		[MODE-DIGIT+2:0]	mode25_reg16;
	reg		[MODE-DIGIT+2:0]	mode26_reg16;
	reg		[MODE-DIGIT+2:0]	mode27_reg16;
	reg		[MODE-DIGIT+2:0]	mode28_reg16;
	reg		[MODE-DIGIT+2:0]	mode29_reg16;
	reg		[MODE-DIGIT+2:0]	mode30_reg16;
	reg		[MODE-DIGIT+2:0]	mode31_reg16;
	reg		[MODE-DIGIT+2:0]	mode32_reg16;
	reg		[MODE-DIGIT+2:0]	mode33_reg16;
	
	reg		[MODE-DIGIT+2:0]	adda16;
	reg		[MODE-DIGIT:0]		addb16;
	wire	[MODE-DIGIT+2:0]	sum16;
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			adda16		<=		'd0;
		else
			case(cnt)
				'd4           :              adda16		<=	mode2_reg16    ;
				'd5           :              adda16		<=	mode3_reg16    ;
				'd6           :              adda16		<=	mode4_reg16    ;
				'd7           :              adda16		<=	mode5_reg16    ;
				'd8           :              adda16		<=	mode6_reg16    ;
				'd9           :              adda16		<=	mode7_reg16    ;
				'd10          :              adda16		<=	mode8_reg16    ;
				'd11          :              adda16		<=	mode9_reg16    ;
				'd12          :              adda16		<=	mode10_reg16   ;
				'd13          :              adda16		<=	mode11_reg16   ;
				'd14          :              adda16		<=	mode12_reg16   ;
				'd15          :              adda16		<=	mode13_reg16   ;
				'd16          :              adda16		<=	mode14_reg16   ;
				'd17          :              adda16		<=	mode15_reg16   ;
				'd18          :              adda16		<=	mode16_reg16   ;
				'd19          :              adda16		<=	mode17_reg16   ;
				'd20          :              adda16		<=	mode18_reg16   ;
				'd21          :              adda16		<=	mode19_reg16   ;
				'd22          :              adda16		<=	mode20_reg16   ;
				'd23          :              adda16		<=	mode21_reg16   ;
				'd24          :              adda16		<=	mode22_reg16   ;
				'd25          :              adda16		<=	mode23_reg16   ;
				'd26          :              adda16		<=	mode24_reg16   ;
				'd27          :              adda16		<=	mode25_reg16   ;
				'd28          :              adda16		<=	mode26_reg16   ;
				'd29          :              adda16		<=	mode27_reg16   ;
				'd30          :              adda16		<=	mode28_reg16   ;
				'd31          :              adda16		<=	mode29_reg16   ;
				'd32          :              adda16		<=	mode30_reg16   ;
				'd33          :              adda16		<=	mode31_reg16   ;
				'd34          :              adda16		<=	mode32_reg16   ;
				'd35          :              adda16		<=	mode33_reg16   ;
				default:					adda16	<=	'd0;
			endcase
				
always@(posedge clk or negedge rstn)
		if(!rstn)
			addb16		<=		'd0;
		else
			case(cnt)
				'd4       :                  addb16		<=	mode2_reg    ;
				'd5       :                  addb16		<=	mode3_reg    ;
				'd6       :                  addb16		<=	mode4_reg    ;
				'd7       :                  addb16		<=	mode5_reg    ;
				'd8       :                  addb16		<=	mode6_reg    ;
				'd9       :                  addb16		<=	mode7_reg    ;
				'd10      :                  addb16		<=	mode8_reg    ;
				'd11      :                  addb16		<=	mode9_reg    ;
				'd12      :                  addb16		<=	mode10_reg   ;
				'd13      :                  addb16		<=	mode11_reg   ;
				'd14      :                  addb16		<=	mode12_reg   ;
				'd15      :                  addb16		<=	mode13_reg   ;
				'd16      :                  addb16		<=	mode14_reg   ;
				'd17      :                  addb16		<=	mode15_reg   ;
				'd18      :                  addb16		<=	mode16_reg   ;
				'd19      :                  addb16		<=	mode17_reg   ;
				'd20      :                  addb16		<=	mode18_reg   ;
				'd21      :                  addb16		<=	mode19_reg   ;
				'd22      :                  addb16		<=	mode20_reg   ;
				'd23      :                  addb16		<=	mode21_reg   ;
				'd24      :                  addb16		<=	mode22_reg   ;
				'd25      :                  addb16		<=	mode23_reg   ;
				'd26      :                  addb16		<=	mode24_reg   ;
				'd27      :                  addb16		<=	mode25_reg   ;
				'd28      :                  addb16		<=	mode26_reg   ;
				'd29      :                  addb16		<=	mode27_reg   ;
				'd30      :                  addb16		<=	mode28_reg   ;
				'd31      :                  addb16		<=	mode29_reg   ;
				'd32      :                  addb16		<=	mode30_reg   ;
				'd33      :                  addb16		<=	mode31_reg   ;
				'd34      :                  addb16		<=	mode32_reg   ;
				'd35      :                  addb16		<=	mode33_reg   ;
				default:					addb16	<=	'd0;
				endcase
	
	assign		sum16=adda16+addb16;	
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			begin
				mode2_reg16 <= 'd0;
				mode3_reg16 <= 'd0;
				mode4_reg16 <= 'd0;
				mode5_reg16 <= 'd0;
				mode6_reg16 <= 'd0;
				mode7_reg16 <= 'd0;
				mode8_reg16 <= 'd0;
				mode9_reg16 <= 'd0;
				mode10_reg16 <= 'd0;
				mode11_reg16 <= 'd0;
				mode12_reg16 <= 'd0;
				mode13_reg16 <= 'd0;
				mode14_reg16 <= 'd0;
				mode15_reg16 <= 'd0;
				mode16_reg16 <= 'd0;
				mode17_reg16 <= 'd0;
				mode18_reg16 <= 'd0;
				mode19_reg16 <= 'd0;
				mode20_reg16 <= 'd0;
				mode21_reg16 <= 'd0;
				mode22_reg16 <= 'd0;
				mode23_reg16 <= 'd0;
				mode24_reg16 <= 'd0;
				mode25_reg16 <= 'd0;
				mode26_reg16 <= 'd0;
				mode27_reg16 <= 'd0;
				mode28_reg16 <= 'd0;
				mode29_reg16 <= 'd0;
				mode30_reg16 <= 'd0;
				mode31_reg16 <= 'd0;
				mode32_reg16 <= 'd0;
				mode33_reg16 <= 'd0;
			end
		else if(comparebegin && (blockcnt[1:0]==2'b01))
			begin
				mode2_reg16 <= 'd0;
				mode3_reg16 <= 'd0;
				mode4_reg16 <= 'd0;
				mode5_reg16 <= 'd0;
				mode6_reg16 <= 'd0;
				mode7_reg16 <= 'd0;
				mode8_reg16 <= 'd0;
				mode9_reg16 <= 'd0;
				mode10_reg16 <= 'd0;
				mode11_reg16 <= 'd0;
				mode12_reg16 <= 'd0;
				mode13_reg16 <= 'd0;
				mode14_reg16 <= 'd0;
				mode15_reg16 <= 'd0;
				mode16_reg16 <= 'd0;
				mode17_reg16 <= 'd0;
				mode18_reg16 <= 'd0;
				mode19_reg16 <= 'd0;
				mode20_reg16 <= 'd0;
				mode21_reg16 <= 'd0;
				mode22_reg16 <= 'd0;
				mode23_reg16 <= 'd0;
				mode24_reg16 <= 'd0;
				mode25_reg16 <= 'd0;
				mode26_reg16 <= 'd0;
				mode27_reg16 <= 'd0;
				mode28_reg16 <= 'd0;
				mode29_reg16 <= 'd0;
				mode30_reg16 <= 'd0;
			    mode31_reg16 <= 'd0;
			    mode32_reg16 <= 'd0;
			    mode33_reg16 <= 'd0;
			end
		else
			begin
				case(cnt)
						'd5    :mode2_reg16	 	<= 		sum16;
						'd6    :mode3_reg16	 	<= 		sum16;
						'd7    :mode4_reg16	 	<= 		sum16;
						'd8    :mode5_reg16	 	<= 		sum16;
						'd9    :mode6_reg16	 	<= 		sum16;
						'd10   :mode7_reg16	 	<= 		sum16;
						'd11   :mode8_reg16	 	<= 		sum16;
						'd12   :mode9_reg16	 	<= 		sum16;
						'd13   :mode10_reg16 	<= 		sum16;
						'd14   :mode11_reg16 	<= 		sum16;
						'd15   :mode12_reg16 	<= 		sum16;
						'd16   :mode13_reg16 	<= 		sum16;
						'd17   :mode14_reg16 	<= 		sum16;
						'd18   :mode15_reg16 	<= 		sum16;
						'd19   :mode16_reg16 	<= 		sum16;
						'd20   :mode17_reg16 	<= 		sum16;
						'd21   :mode18_reg16 	<= 		sum16;
						'd22   :mode19_reg16 	<= 		sum16;
						'd23   :mode20_reg16 	<= 		sum16;
						'd24   :mode21_reg16 	<= 		sum16;
						'd25   :mode22_reg16 	<= 		sum16;
						'd26   :mode23_reg16 	<= 		sum16;
						'd27   :mode24_reg16 	<= 		sum16;
						'd28   :mode25_reg16 	<= 		sum16;
						'd29   :mode26_reg16 	<= 		sum16;
						'd30   :mode27_reg16 	<= 		sum16;
						'd31   :mode28_reg16 	<= 		sum16;
						'd32   :mode29_reg16 	<= 		sum16;
						'd33   :mode30_reg16 	<= 		sum16;
						'd34   :mode31_reg16 	<= 		sum16;
						'd35   :mode32_reg16 	<= 		sum16;
						'd36   :mode33_reg16 	<= 		sum16;
					default:
					begin
						mode2_reg16 		<=		mode2_reg16 ;
						mode3_reg16 		<=		mode3_reg16 ;
						mode4_reg16 		<=		mode4_reg16 ;
						mode5_reg16 		<=		mode5_reg16 ;
						mode6_reg16 		<=		mode6_reg16 ;
						mode7_reg16 		<=		mode7_reg16 ;
						mode8_reg16 		<=		mode8_reg16 ;
						mode9_reg16 		<=		mode9_reg16 ;
						mode10_reg16		<=		mode10_reg16;
						mode11_reg16		<=		mode11_reg16;
						mode12_reg16		<=		mode12_reg16;
						mode13_reg16		<=		mode13_reg16;
						mode14_reg16		<=		mode14_reg16;
						mode15_reg16		<=		mode15_reg16;
						mode16_reg16		<=		mode16_reg16;
						mode17_reg16		<=		mode17_reg16;
						mode18_reg16		<=		mode18_reg16;
						mode19_reg16		<=		mode19_reg16;
						mode20_reg16		<=		mode20_reg16;
						mode21_reg16		<=		mode21_reg16;
						mode22_reg16		<=		mode22_reg16;
						mode23_reg16		<=		mode23_reg16;
						mode24_reg16		<=		mode24_reg16;
						mode25_reg16		<=		mode25_reg16;
						mode26_reg16		<=		mode26_reg16;
						mode27_reg16		<=		mode27_reg16;
						mode28_reg16		<=		mode28_reg16;
						mode29_reg16		<=		mode29_reg16;
						mode30_reg16		<=		mode30_reg16;
						mode31_reg16		<=		mode31_reg16;
						mode32_reg16		<=		mode32_reg16;
						mode33_reg16		<=		mode33_reg16;
					end
				endcase
			end
				
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			mode_reg16 <= 'd0;
		else 
			mode_reg16 <= sum16	;
		
	always@(posedge clk or negedge rstn)
		if(!rstn)
			begin
				bestmode16 <= 'd0;
				modebest16 <= {(MODE-DIGIT+3){1'b1}};
			end
		else if(comparebegin16)
			begin
				bestmode16 <= 'd2;
				modebest16 <= {(MODE-DIGIT+3){1'b1}};
			end
		else if ((modebest16 > mode_reg16) & comparerun16_reg)
			begin
				bestmode16 <= cnt-4;
				modebest16 <= mode_reg16;
			end
		else
			begin
				bestmode16 <= bestmode16;
				modebest16 <= modebest16;
			end

//=======================32*32=======================
	reg		[5:0]		bestmode32;
	reg		[MODE-DIGIT+4:0]	modebest32;
	reg		[MODE-DIGIT+4:0]	mode_reg32;
	reg		[MODE-DIGIT+4:0]	mode2_reg32;
	reg		[MODE-DIGIT+4:0]	mode3_reg32;
	reg		[MODE-DIGIT+4:0]	mode4_reg32;
	reg		[MODE-DIGIT+4:0]	mode5_reg32;
	reg		[MODE-DIGIT+4:0]	mode6_reg32;
	reg		[MODE-DIGIT+4:0]	mode7_reg32;
	reg		[MODE-DIGIT+4:0]	mode8_reg32;
	reg		[MODE-DIGIT+4:0]	mode9_reg32;
	reg		[MODE-DIGIT+4:0]	mode10_reg32;
	reg		[MODE-DIGIT+4:0]	mode11_reg32;
	reg		[MODE-DIGIT+4:0]	mode12_reg32;
	reg		[MODE-DIGIT+4:0]	mode13_reg32;
	reg		[MODE-DIGIT+4:0]	mode14_reg32;
	reg		[MODE-DIGIT+4:0]	mode15_reg32;
	reg		[MODE-DIGIT+4:0]	mode16_reg32;
	reg		[MODE-DIGIT+4:0]	mode17_reg32;
	reg		[MODE-DIGIT+4:0]	mode18_reg32;
	reg		[MODE-DIGIT+4:0]	mode19_reg32;
	reg		[MODE-DIGIT+4:0]	mode20_reg32;
	reg		[MODE-DIGIT+4:0]	mode21_reg32;
	reg		[MODE-DIGIT+4:0]	mode22_reg32;
	reg		[MODE-DIGIT+4:0]	mode23_reg32;
	reg		[MODE-DIGIT+4:0]	mode24_reg32;
	reg		[MODE-DIGIT+4:0]	mode25_reg32;
	reg		[MODE-DIGIT+4:0]	mode26_reg32;
	reg		[MODE-DIGIT+4:0]	mode27_reg32;
	reg		[MODE-DIGIT+4:0]	mode28_reg32;
	reg		[MODE-DIGIT+4:0]	mode29_reg32;
	reg		[MODE-DIGIT+4:0]	mode30_reg32;
	reg		[MODE-DIGIT+4:0]	mode31_reg32;
	reg		[MODE-DIGIT+4:0]	mode32_reg32;
	reg		[MODE-DIGIT+4:0]	mode33_reg32;
	
	reg		[MODE-DIGIT+4:0]	adda32;
	reg		[MODE-DIGIT+2:0]	addb32;
	wire	[MODE-DIGIT+4:0]	sum32;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			adda32		<=		'd0;
		else
			case(cnt)
				'd5           :              adda32		<=	mode2_reg32    ;
				'd6           :              adda32		<=	mode3_reg32    ;
				'd7           :              adda32		<=	mode4_reg32    ;
				'd8           :              adda32		<=	mode5_reg32    ;
				'd9           :              adda32		<=	mode6_reg32    ;
				'd10          :              adda32		<=	mode7_reg32    ;
				'd11          :              adda32		<=	mode8_reg32    ;
				'd12          :              adda32		<=	mode9_reg32    ;
				'd13          :              adda32		<=	mode10_reg32   ;
				'd14          :              adda32		<=	mode11_reg32   ;
				'd15          :              adda32		<=	mode12_reg32   ;
				'd16          :              adda32		<=	mode13_reg32   ;
				'd17          :              adda32		<=	mode14_reg32   ;
				'd18          :              adda32		<=	mode15_reg32   ;
				'd19          :              adda32		<=	mode16_reg32   ;
				'd20          :              adda32		<=	mode17_reg32   ;
				'd21          :              adda32		<=	mode18_reg32   ;
				'd22          :              adda32		<=	mode19_reg32   ;
				'd23          :              adda32		<=	mode20_reg32   ;
				'd24          :              adda32		<=	mode21_reg32   ;
				'd25          :              adda32		<=	mode22_reg32   ;
				'd26          :              adda32		<=	mode23_reg32   ;
				'd27          :              adda32		<=	mode24_reg32   ;
				'd28          :              adda32		<=	mode25_reg32   ;
				'd29          :              adda32		<=	mode26_reg32   ;
				'd30          :              adda32		<=	mode27_reg32   ;
				'd31          :              adda32		<=	mode28_reg32   ;
				'd32          :              adda32		<=	mode29_reg32   ;
				'd33          :              adda32		<=	mode30_reg32   ;
				'd34          :              adda32		<=	mode31_reg32   ;
				'd35          :              adda32		<=	mode32_reg32   ;
				'd36          :              adda32		<=	mode33_reg32   ;
				default:					adda32	<=	'd0;
			endcase
				
	always@(posedge clk or negedge rstn)
		if(!rstn)
			addb32		<=		'd0;
		else if(comparerun16)
			addb32		<=		sum16;
	
	assign		sum32=adda32+addb32;
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			begin
				mode2_reg32 <= 'd0;
				mode3_reg32 <= 'd0;
				mode4_reg32 <= 'd0;
				mode5_reg32 <= 'd0;
				mode6_reg32 <= 'd0;
				mode7_reg32 <= 'd0;
				mode8_reg32 <= 'd0;
				mode9_reg32 <= 'd0;
				mode10_reg32 <= 'd0;
				mode11_reg32 <= 'd0;
				mode12_reg32 <= 'd0;
				mode13_reg32 <= 'd0;
				mode14_reg32 <= 'd0;
				mode15_reg32 <= 'd0;
				mode16_reg32 <= 'd0;
				mode17_reg32 <= 'd0;
				mode18_reg32 <= 'd0;
				mode19_reg32 <= 'd0;
				mode20_reg32 <= 'd0;
				mode21_reg32 <= 'd0;
				mode22_reg32 <= 'd0;
				mode23_reg32 <= 'd0;
				mode24_reg32 <= 'd0;
				mode25_reg32 <= 'd0;
				mode26_reg32 <= 'd0;
				mode27_reg32 <= 'd0;
				mode28_reg32 <= 'd0;
				mode29_reg32 <= 'd0;
				mode30_reg32 <= 'd0;
				mode31_reg32 <= 'd0;
				mode32_reg32 <= 'd0;
				mode33_reg32 <= 'd0;
			end
		else if(comparebegin && (blockcnt[3:0]=='d3))
			begin
				mode2_reg32 <= 'd0;
				mode3_reg32 <= 'd0;
				mode4_reg32 <= 'd0;
				mode5_reg32 <= 'd0;
				mode6_reg32 <= 'd0;
				mode7_reg32 <= 'd0;
				mode8_reg32 <= 'd0;
				mode9_reg32 <= 'd0;
				mode10_reg32 <= 'd0;
				mode11_reg32 <= 'd0;
				mode12_reg32 <= 'd0;
				mode13_reg32 <= 'd0;
				mode14_reg32 <= 'd0;
				mode15_reg32 <= 'd0;
				mode16_reg32 <= 'd0;
				mode17_reg32 <= 'd0;
				mode18_reg32 <= 'd0;
				mode19_reg32 <= 'd0;
				mode20_reg32 <= 'd0;
				mode21_reg32 <= 'd0;
				mode22_reg32 <= 'd0;
				mode23_reg32 <= 'd0;
				mode24_reg32 <= 'd0;
				mode25_reg32 <= 'd0;
				mode26_reg32 <= 'd0;
				mode27_reg32 <= 'd0;
				mode28_reg32 <= 'd0;
				mode29_reg32 <= 'd0;
				mode30_reg32 <= 'd0;
			    mode31_reg32 <= 'd0;
			    mode32_reg32 <= 'd0;
			    mode33_reg32 <= 'd0;
			end
		else if(blockcnt[1:0]=='d0)
			begin
				case(cnt)
						'd6    :mode2_reg32 	<= 		sum32;
						'd7    :mode3_reg32 	<= 		sum32;
						'd8    :mode4_reg32 	<= 		sum32;
						'd9    :mode5_reg32 	<= 		sum32;
						'd10   :mode6_reg32 	<= 		sum32;
						'd11   :mode7_reg32 	<= 		sum32;
						'd12   :mode8_reg32 	<= 		sum32;
						'd13   :mode9_reg32 	<= 		sum32;
						'd14   :mode10_reg32 	<= 		sum32;
						'd15   :mode11_reg32 	<= 		sum32;
						'd16   :mode12_reg32 	<= 		sum32;
						'd17   :mode13_reg32 	<= 		sum32;
						'd18   :mode14_reg32 	<= 		sum32;
						'd19   :mode15_reg32 	<= 		sum32;
						'd20   :mode16_reg32 	<= 		sum32;
						'd21   :mode17_reg32 	<= 		sum32;
						'd22   :mode18_reg32 	<= 		sum32;
						'd23   :mode19_reg32 	<= 		sum32;
						'd24   :mode20_reg32 	<= 		sum32;
						'd25   :mode21_reg32 	<= 		sum32;
						'd26   :mode22_reg32 	<= 		sum32;
						'd27   :mode23_reg32 	<= 		sum32;
						'd28   :mode24_reg32 	<= 		sum32;
						'd29   :mode25_reg32 	<= 		sum32;
						'd30   :mode26_reg32 	<= 		sum32;
						'd31   :mode27_reg32 	<= 		sum32;
						'd32   :mode28_reg32 	<= 		sum32;
						'd33   :mode29_reg32 	<= 		sum32;
						'd34   :mode30_reg32 	<= 		sum32;
						'd35   :mode31_reg32 	<= 		sum32;
						'd36   :mode32_reg32 	<= 		sum32;
						'd37   :mode33_reg32 	<= 		sum32;
					default:
					begin
						mode2_reg32 		<=		mode2_reg32  ;
						mode3_reg32 		<=		mode3_reg32  ;
						mode4_reg32 		<=		mode4_reg32  ;
						mode5_reg32 		<=		mode5_reg32  ;
						mode6_reg32 		<=		mode6_reg32  ;
						mode7_reg32 		<=		mode7_reg32  ;
						mode8_reg32 		<=		mode8_reg32  ;
						mode9_reg32 		<=		mode9_reg32  ;
						mode10_reg32		<=		mode10_reg32;
						mode11_reg32		<=		mode11_reg32;
						mode12_reg32		<=		mode12_reg32;
						mode13_reg32		<=		mode13_reg32;
						mode14_reg32		<=		mode14_reg32;
						mode15_reg32		<=		mode15_reg32;
						mode16_reg32		<=		mode16_reg32;
						mode17_reg32		<=		mode17_reg32;
						mode18_reg32		<=		mode18_reg32;
						mode19_reg32		<=		mode19_reg32;
						mode20_reg32		<=		mode20_reg32;
						mode21_reg32		<=		mode21_reg32;
						mode22_reg32		<=		mode22_reg32;
						mode23_reg32		<=		mode23_reg32;
						mode24_reg32		<=		mode24_reg32;
						mode25_reg32		<=		mode25_reg32;
						mode26_reg32		<=		mode26_reg32;
						mode27_reg32		<=		mode27_reg32;
						mode28_reg32		<=		mode28_reg32;
						mode29_reg32		<=		mode29_reg32;
						mode30_reg32		<=		mode30_reg32;
						mode31_reg32		<=		mode31_reg32;
						mode32_reg32		<=		mode32_reg32;
						mode33_reg32		<=		mode33_reg32;
					end
				endcase
			end
				
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			mode_reg32 <= 'd0;
		else if(comparerun32)
			mode_reg32 <= sum32;
		
	always@(posedge clk or negedge rstn)
		if(!rstn)
			begin
				bestmode32 <= 'd0;
				modebest32 <= {(MODE-DIGIT+5){1'b1}};
			end
		else if(comparebegin32)
			begin
				bestmode32 <= 'd2;
				modebest32 <= {(MODE-DIGIT+5){1'b1}};
			end
		else if ((modebest32 > mode_reg32) & comparerun32_reg)
			begin
				bestmode32 <= cnt-5;
				modebest32 <= mode_reg32;
			end
		else
			begin
				bestmode32 <= bestmode32;
				modebest32 <= modebest32;
			end
			
//=======================64*64=======================
	reg		[5:0]		bestmode64;
	reg		[MODE-DIGIT+6:0]	modebest64;
	reg		[MODE-DIGIT+6:0]	mode_reg64;
	reg		[MODE-DIGIT+6:0]	mode2_reg64;
	reg		[MODE-DIGIT+6:0]	mode3_reg64;
	reg		[MODE-DIGIT+6:0]	mode4_reg64;
	reg		[MODE-DIGIT+6:0]	mode5_reg64;
	reg		[MODE-DIGIT+6:0]	mode6_reg64;
	reg		[MODE-DIGIT+6:0]	mode7_reg64;
	reg		[MODE-DIGIT+6:0]	mode8_reg64;
	reg		[MODE-DIGIT+6:0]	mode9_reg64;
	reg		[MODE-DIGIT+6:0]	mode10_reg64;
	reg		[MODE-DIGIT+6:0]	mode11_reg64;
	reg		[MODE-DIGIT+6:0]	mode12_reg64;
	reg		[MODE-DIGIT+6:0]	mode13_reg64;
	reg		[MODE-DIGIT+6:0]	mode14_reg64;
	reg		[MODE-DIGIT+6:0]	mode15_reg64;
	reg		[MODE-DIGIT+6:0]	mode16_reg64;
	reg		[MODE-DIGIT+6:0]	mode17_reg64;
	reg		[MODE-DIGIT+6:0]	mode18_reg64;
	reg		[MODE-DIGIT+6:0]	mode19_reg64;
	reg		[MODE-DIGIT+6:0]	mode20_reg64;
	reg		[MODE-DIGIT+6:0]	mode21_reg64;
	reg		[MODE-DIGIT+6:0]	mode22_reg64;
	reg		[MODE-DIGIT+6:0]	mode23_reg64;
	reg		[MODE-DIGIT+6:0]	mode24_reg64;
	reg		[MODE-DIGIT+6:0]	mode25_reg64;
	reg		[MODE-DIGIT+6:0]	mode26_reg64;
	reg		[MODE-DIGIT+6:0]	mode27_reg64;
	reg		[MODE-DIGIT+6:0]	mode28_reg64;
	reg		[MODE-DIGIT+6:0]	mode29_reg64;
	reg		[MODE-DIGIT+6:0]	mode30_reg64;
	reg		[MODE-DIGIT+6:0]	mode31_reg64;
	reg		[MODE-DIGIT+6:0]	mode32_reg64;
	reg		[MODE-DIGIT+6:0]	mode33_reg64;
	
	reg		[MODE-DIGIT+6:0]	adda64;
	reg		[MODE-DIGIT+4:0]	addb64;
	wire	[MODE-DIGIT+6:0]	sum64;
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			adda64		<=		'd0;
		else
			case(cnt)
				'd6           :              adda64		<=	mode2_reg64    ;
				'd7           :              adda64		<=	mode3_reg64    ;
				'd8           :              adda64		<=	mode4_reg64    ;
				'd9           :              adda64		<=	mode5_reg64    ;
				'd10          :              adda64		<=	mode6_reg64    ;
				'd11          :              adda64		<=	mode7_reg64    ;
				'd12          :              adda64		<=	mode8_reg64    ;
				'd13          :              adda64		<=	mode9_reg64    ;
				'd14          :              adda64		<=	mode10_reg64   ;
				'd15          :              adda64		<=	mode11_reg64   ;
				'd16          :              adda64		<=	mode12_reg64   ;
				'd17          :              adda64		<=	mode13_reg64   ;
				'd18          :              adda64		<=	mode14_reg64   ;
				'd19          :              adda64		<=	mode15_reg64   ;
				'd20          :              adda64		<=	mode16_reg64   ;
				'd21          :              adda64		<=	mode17_reg64   ;
				'd22          :              adda64		<=	mode18_reg64   ;
				'd23          :              adda64		<=	mode19_reg64   ;
				'd24          :              adda64		<=	mode20_reg64   ;
				'd25          :              adda64		<=	mode21_reg64   ;
				'd26          :              adda64		<=	mode22_reg64   ;
				'd27          :              adda64		<=	mode23_reg64   ;
				'd28          :              adda64		<=	mode24_reg64   ;
				'd29          :              adda64		<=	mode25_reg64   ;
				'd30          :              adda64		<=	mode26_reg64   ;
				'd31          :              adda64		<=	mode27_reg64   ;
				'd32          :              adda64		<=	mode28_reg64   ;
				'd33          :              adda64		<=	mode29_reg64   ;
				'd34          :              adda64		<=	mode30_reg64   ;
				'd35          :              adda64		<=	mode31_reg64   ;
				'd36          :              adda64		<=	mode32_reg64   ;
				'd37          :              adda64		<=	mode33_reg64   ;
				default:					adda64	<=	'd0;
			endcase
				
	always@(posedge clk or negedge rstn)
		if(!rstn)
			addb64		<=		'd0;
		else if(comparerun32)
			addb64		<=		sum32;
	
	assign		sum64=adda64+addb64;
	
	always@(posedge clk or negedge rstn)
		if(!rstn)
			begin
				mode2_reg64 <= 'd0;
				mode3_reg64 <= 'd0;
				mode4_reg64 <= 'd0;
				mode5_reg64 <= 'd0;
				mode6_reg64 <= 'd0;
				mode7_reg64 <= 'd0;
				mode8_reg64 <= 'd0;
				mode9_reg64 <= 'd0;
				mode10_reg64 <= 'd0;
				mode11_reg64 <= 'd0;
				mode12_reg64 <= 'd0;
				mode13_reg64 <= 'd0;
				mode14_reg64 <= 'd0;
				mode15_reg64 <= 'd0;
				mode16_reg64 <= 'd0;
				mode17_reg64 <= 'd0;
				mode18_reg64 <= 'd0;
				mode19_reg64 <= 'd0;
				mode20_reg64 <= 'd0;
				mode21_reg64 <= 'd0;
				mode22_reg64 <= 'd0;
				mode23_reg64 <= 'd0;
				mode24_reg64 <= 'd0;
				mode25_reg64 <= 'd0;
				mode26_reg64 <= 'd0;
				mode27_reg64 <= 'd0;
				mode28_reg64 <= 'd0;
				mode29_reg64 <= 'd0;
				mode30_reg64 <= 'd0;
				mode31_reg64 <= 'd0;
				mode32_reg64 <= 'd0;
				mode33_reg64 <= 'd0;
			end
		else if(comparebegin && (blockcnt=='d3))
			begin
				mode2_reg64 <= 'd0;
				mode3_reg64 <= 'd0;
				mode4_reg64 <= 'd0;
				mode5_reg64 <= 'd0;
				mode6_reg64 <= 'd0;
				mode7_reg64 <= 'd0;
				mode8_reg64 <= 'd0;
				mode9_reg64 <= 'd0;
				mode10_reg64 <= 'd0;
				mode11_reg64 <= 'd0;
				mode12_reg64 <= 'd0;
				mode13_reg64 <= 'd0;
				mode14_reg64 <= 'd0;
				mode15_reg64 <= 'd0;
				mode16_reg64 <= 'd0;
				mode17_reg64 <= 'd0;
				mode18_reg64 <= 'd0;
				mode19_reg64 <= 'd0;
				mode20_reg64 <= 'd0;
				mode21_reg64 <= 'd0;
				mode22_reg64 <= 'd0;
				mode23_reg64 <= 'd0;
				mode24_reg64 <= 'd0;
				mode25_reg64 <= 'd0;
				mode26_reg64 <= 'd0;
				mode27_reg64 <= 'd0;
				mode28_reg64 <= 'd0;
				mode29_reg64 <= 'd0;
				mode30_reg64 <= 'd0;
			    mode31_reg64 <= 'd0;
			    mode32_reg64 <= 'd0;
			    mode33_reg64 <= 'd0;
			end
		else if((blockcnt[3:0]=='d0) &&( blockcnt[6:4]!=3'b0))
			begin
				case(cnt)
						'd7    :mode2_reg64 	<= 		sum64;
						'd8    :mode3_reg64 	<= 		sum64;
						'd9    :mode4_reg64 	<= 		sum64;
						'd10   :mode5_reg64 	<= 		sum64;
						'd11   :mode6_reg64 	<= 		sum64;
						'd12   :mode7_reg64 	<= 		sum64;
						'd13   :mode8_reg64 	<= 		sum64;
						'd14   :mode9_reg64 	<= 		sum64;
						'd15   :mode10_reg64 	<= 		sum64;
						'd16   :mode11_reg64 	<= 		sum64;
						'd17   :mode12_reg64 	<= 		sum64;
						'd18   :mode13_reg64 	<= 		sum64;
						'd19   :mode14_reg64 	<= 		sum64;
						'd20   :mode15_reg64 	<= 		sum64;
						'd21   :mode16_reg64 	<= 		sum64;
						'd22   :mode17_reg64 	<= 		sum64;
						'd23   :mode18_reg64 	<= 		sum64;
						'd24   :mode19_reg64 	<= 		sum64;
						'd25   :mode20_reg64 	<= 		sum64;
						'd26   :mode21_reg64 	<= 		sum64;
						'd27   :mode22_reg64 	<= 		sum64;
						'd28   :mode23_reg64 	<= 		sum64;
						'd29   :mode24_reg64 	<= 		sum64;
						'd30   :mode25_reg64 	<= 		sum64;
						'd31   :mode26_reg64 	<= 		sum64;
						'd32   :mode27_reg64 	<= 		sum64;
						'd33   :mode28_reg64 	<= 		sum64;
						'd34   :mode29_reg64 	<= 		sum64;
						'd35   :mode30_reg64 	<= 		sum64;
						'd36   :mode31_reg64 	<= 		sum64;
						'd37   :mode32_reg64 	<= 		sum64;
						'd38   :mode33_reg64 	<= 		sum64;
					default:
					begin
						mode2_reg64 		<=		mode2_reg64 ;
						mode3_reg64 		<=		mode3_reg64 ;
						mode4_reg64 		<=		mode4_reg64 ;
						mode5_reg64 		<=		mode5_reg64 ;
						mode6_reg64 		<=		mode6_reg64 ;
						mode7_reg64 		<=		mode7_reg64 ;
						mode8_reg64 		<=		mode8_reg64 ;
						mode9_reg64 		<=		mode9_reg64 ;
						mode10_reg64		<=		mode10_reg64;
						mode11_reg64		<=		mode11_reg64;
						mode12_reg64		<=		mode12_reg64;
						mode13_reg64		<=		mode13_reg64;
						mode14_reg64		<=		mode14_reg64;
						mode15_reg64		<=		mode15_reg64;
						mode16_reg64		<=		mode16_reg64;
						mode17_reg64		<=		mode17_reg64;
						mode18_reg64		<=		mode18_reg64;
						mode19_reg64		<=		mode19_reg64;
						mode20_reg64		<=		mode20_reg64;
						mode21_reg64		<=		mode21_reg64;
						mode22_reg64		<=		mode22_reg64;
						mode23_reg64		<=		mode23_reg64;
						mode24_reg64		<=		mode24_reg64;
						mode25_reg64		<=		mode25_reg64;
						mode26_reg64		<=		mode26_reg64;
						mode27_reg64		<=		mode27_reg64;
						mode28_reg64		<=		mode28_reg64;
						mode29_reg64		<=		mode29_reg64;
						mode30_reg64		<=		mode30_reg64;
						mode31_reg64		<=		mode31_reg64;
						mode32_reg64		<=		mode32_reg64;
						mode33_reg64		<=		mode33_reg64;
					end
				endcase
			end
				
			
	always@(posedge clk or negedge rstn)
		if(!rstn)
			mode_reg64 <= 'd0;
		else if(comparerun64)
			mode_reg64 <= sum64;
		
	always@(posedge clk or negedge rstn)
		if(!rstn)
			begin
				bestmode64 <= 'd0;
				modebest64 <= {(MODE-DIGIT+7){1'b1}};
			end
		else if(comparebegin64)
			begin
				bestmode64 <= 'd2;
				modebest64 <= {(MODE-DIGIT+7){1'b1}};
			end
		else if ((modebest64 > mode_reg64) & comparerun64_reg)
			begin
				bestmode64 <= cnt-6;
				modebest64 <= mode_reg64;
			end
		else
			begin
				bestmode64 <= bestmode64;
				modebest64 <= modebest64;
			end
			
endmodule
