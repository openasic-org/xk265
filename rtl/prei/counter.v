//just for test
//luyanheng
//2014-03-25
module counter(
	rstn,
	clk,
	counterrun1,
	counterrun2,
	gx,
	gy,
	
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

	input			rstn;
	input			clk;
	input			counterrun1;
	input			counterrun2;
	input	signed		[10:0]	gx;
	input	signed		[10:0]	gy;
	output				[MODE:0]	mode2;
	output				[MODE:0]	mode3;
	output				[MODE:0]	mode4;
	output				[MODE:0]	mode5;
	output				[MODE:0]	mode6;
	output				[MODE:0]	mode7;
	output				[MODE:0]	mode8;
	output				[MODE:0]	mode9;
	output				[MODE:0]	mode10;
	output				[MODE:0]	mode11;
	output				[MODE:0]	mode12;
	output				[MODE:0]	mode13;
	output				[MODE:0]	mode14;
	output				[MODE:0]	mode15;
	output				[MODE:0]	mode16;
	output				[MODE:0]	mode17;
	output				[MODE:0]	mode18;
	output				[MODE:0]	mode19;
	output				[MODE:0]	mode20;
	output				[MODE:0]	mode21;
	output				[MODE:0]	mode22;
	output				[MODE:0]	mode23;
	output				[MODE:0]	mode24;
	output				[MODE:0]	mode25;
	output				[MODE:0]	mode26;
	output				[MODE:0]	mode27;
	output				[MODE:0]	mode28;
	output				[MODE:0]	mode29;
	output				[MODE:0]	mode30;
	output				[MODE:0]	mode31;
	output				[MODE:0]	mode32;
	output				[MODE:0]	mode33;
	
	reg signed			[MODE:0]		mode2_tmp;
	reg signed			[MODE:0]		mode3_tmp;
	reg signed			[MODE:0]		mode4_tmp;
	reg signed			[MODE:0]		mode5_tmp;
	reg signed			[MODE:0]		mode6_tmp;
	reg signed			[MODE:0]		mode7_tmp;
	reg signed			[MODE:0]		mode8_tmp;
	reg signed			[MODE:0]		mode9_tmp;
	reg signed			[MODE:0]		mode10_tmp;
	reg signed			[MODE:0]		mode11_tmp;
	reg signed			[MODE:0]		mode12_tmp;
	reg signed			[MODE:0]		mode13_tmp;
	reg signed			[MODE:0]		mode14_tmp;
	reg signed			[MODE:0]		mode15_tmp;
	reg signed			[MODE:0]		mode16_tmp;
	reg signed			[MODE:0]		mode17_tmp;
	reg signed			[MODE:0]		mode18_tmp;
	reg signed			[MODE:0]		mode19_tmp;
	reg signed			[MODE:0]		mode20_tmp;
	reg signed			[MODE:0]		mode21_tmp;
	reg signed			[MODE:0]		mode22_tmp;
	reg signed			[MODE:0]		mode23_tmp;
	reg signed			[MODE:0]		mode24_tmp;
	reg signed			[MODE:0]		mode25_tmp;
	reg signed			[MODE:0]		mode26_tmp;
	reg signed			[MODE:0]		mode27_tmp;
	reg signed			[MODE:0]		mode28_tmp;
	reg signed			[MODE:0]		mode29_tmp;
	reg signed			[MODE:0]		mode30_tmp;
	reg signed			[MODE:0]		mode31_tmp;
	reg signed			[MODE:0]		mode32_tmp;
	reg signed			[MODE:0]		mode33_tmp;
	
always@(posedge clk or negedge rstn)
	if(!rstn)
		begin
				mode2_tmp<='d0;
				mode3_tmp<='d0;
				mode4_tmp<='d0;
				mode5_tmp<='d0;
				mode6_tmp<='d0;
				mode7_tmp<='d0;
				mode8_tmp<='d0;
				mode9_tmp<='d0;
				mode10_tmp<= 'd0;
				mode11_tmp<= 'd0;
				mode12_tmp<= 'd0;
				mode13_tmp<= 'd0;
				mode14_tmp<= 'd0;
				mode15_tmp<= 'd0;
				mode16_tmp<= 'd0;
				mode17_tmp<= 'd0;
				mode18_tmp<= 'd0;
				mode19_tmp<= 'd0;
				mode20_tmp<= 'd0;
				mode21_tmp<= 'd0;
				mode22_tmp<= 'd0;
				mode23_tmp<= 'd0;
				mode24_tmp<= 'd0;
				mode25_tmp<= 'd0;
				mode26_tmp<= 'd0;
				mode27_tmp<= 'd0;
				mode28_tmp<= 'd0;
				mode29_tmp<= 'd0;
				mode30_tmp<= 'd0;
				mode31_tmp<= 'd0;
				mode32_tmp<= 'd0;
				mode33_tmp<= 'd0;
		end
	else if(counterrun1)
		begin
				mode2_tmp<=90*gx+90*gy;
				mode3_tmp<=99*gx+81*gy;
				mode4_tmp<=107*gx+70*gy;
				mode5_tmp<=113*gx+60*gy;
				mode6_tmp<=118*gx+48*gy;
				mode7_tmp<=123*gx+35*gy;
				mode8_tmp<=126*gx+20*gy;
				mode9_tmp<=127*gx+8*gy;
				mode10_tmp<=128*gx;
				mode11_tmp<=127*gx-8*gy;
				mode12_tmp<=126*gx-20*gy;
				mode13_tmp<=123*gx-35*gy;
				mode14_tmp<=118*gx-48*gy;
				mode15_tmp<=113*gx-60*gy;
				mode16_tmp<=107*gx-70*gy;
				mode17_tmp<=99*gx-81*gy;
				mode18_tmp<=90*gx-90*gy;
				mode19_tmp<=81*gx-99*gy;
				mode20_tmp<=70*gx-107*gy;
				mode21_tmp<=60*gx-113*gy;
				mode22_tmp<=48*gx-118*gy;
				mode23_tmp<=35*gx-123*gy;
				mode24_tmp<=20*gx-126*gy;
				mode25_tmp<=8*gx-127*gy;
				mode26_tmp<=128*gy;
				mode27_tmp<=8*gx+127*gy;
				mode28_tmp<=20*gx+126*gy;
				mode29_tmp<=35*gx+123*gy;
				mode30_tmp<=48*gx+118*gy;
				mode31_tmp<=60*gx+113*gy;
				mode32_tmp<=70*gx+107*gy;
				mode33_tmp<=81*gx+99*gy;
		end
	
	
	reg				[MODE:0]	mode2;
	reg				[MODE:0]	mode3;
	reg				[MODE:0]	mode4;
	reg				[MODE:0]	mode5;
	reg				[MODE:0]	mode6;
	reg				[MODE:0]	mode7;
	reg				[MODE:0]	mode8;
	reg				[MODE:0]	mode9;
	reg				[MODE:0]	mode10;
	reg				[MODE:0]	mode11;
	reg				[MODE:0]	mode12;
	reg				[MODE:0]	mode13;
	reg				[MODE:0]	mode14;
	reg				[MODE:0]	mode15;
	reg				[MODE:0]	mode16;
	reg				[MODE:0]	mode17;
	reg				[MODE:0]	mode18;
	reg				[MODE:0]	mode19;
	reg				[MODE:0]	mode20;
	reg				[MODE:0]	mode21;
	reg				[MODE:0]	mode22;
	reg				[MODE:0]	mode23;
	reg				[MODE:0]	mode24;
	reg				[MODE:0]	mode25;
	reg				[MODE:0]	mode26;
	reg				[MODE:0]	mode27;
	reg				[MODE:0]	mode28;
	reg				[MODE:0]	mode29;
	reg				[MODE:0]	mode30;
	reg				[MODE:0]	mode31;
	reg				[MODE:0]	mode32;
	reg				[MODE:0]	mode33;
	
always@(posedge clk or negedge rstn)
	if(!rstn)
		begin
			mode2	<=	'd0;
			mode3	<=	'd0;
			mode4	<=	'd0;
			mode5	<=	'd0;
			mode6	<=	'd0;
			mode7	<=	'd0;
			mode8	<=	'd0;
			mode9	<=	'd0;
			mode10	<=	'd0;
			mode11	<=	'd0;
			mode12	<=	'd0;
			mode13	<=	'd0;
			mode14	<=	'd0;
			mode15	<=	'd0;
			mode16	<=	'd0;
			mode17	<=	'd0;
			mode18	<=	'd0;
			mode19	<=	'd0;
			mode20	<=	'd0;
			mode21	<=	'd0;
			mode22	<=	'd0;
			mode23	<=	'd0;
			mode24	<=	'd0;
			mode25	<=	'd0;
			mode26	<=	'd0;
			mode27	<=	'd0;
			mode28	<=	'd0;
			mode29	<=	'd0;
			mode30	<=	'd0;
			mode31	<=	'd0;
			mode32	<=	'd0;
			mode33	<=	'd0;
		end
	else if(counterrun2)
		begin
			mode2	<=	mode2+((mode2_tmp[MODE]) ? (-mode2_tmp) : (mode2_tmp));
			mode3	<=	mode3+((mode3_tmp[MODE]) ? (-mode3_tmp) : (mode3_tmp));
			mode4	<=	mode4+((mode4_tmp[MODE]) ? (-mode4_tmp) : (mode4_tmp));
			mode5	<=	mode5+((mode5_tmp[MODE]) ? (-mode5_tmp) : (mode5_tmp));
			mode6	<=	mode6+((mode6_tmp[MODE]) ? (-mode6_tmp) : (mode6_tmp));
			mode7	<=	mode7+((mode7_tmp[MODE]) ? (-mode7_tmp) : (mode7_tmp));
			mode8	<=	mode8+((mode8_tmp[MODE]) ? (-mode8_tmp) : (mode8_tmp));
			mode9	<=	mode9+((mode9_tmp[MODE]) ? (-mode9_tmp) : (mode9_tmp));
			mode10	<=	mode10+((mode10_tmp[MODE]) ? (-mode10_tmp) : (mode10_tmp));
			mode11	<=	mode11+((mode11_tmp[MODE]) ? (-mode11_tmp) : (mode11_tmp));
			mode12	<=	mode12+((mode12_tmp[MODE]) ? (-mode12_tmp) : (mode12_tmp));
			mode13	<=	mode13+((mode13_tmp[MODE]) ? (-mode13_tmp) : (mode13_tmp));
			mode14	<=	mode14+((mode14_tmp[MODE]) ? (-mode14_tmp) : (mode14_tmp));
			mode15	<=	mode15+((mode15_tmp[MODE]) ? (-mode15_tmp) : (mode15_tmp));
			mode16	<=	mode16+((mode16_tmp[MODE]) ? (-mode16_tmp) : (mode16_tmp));
			mode17	<=	mode17+((mode17_tmp[MODE]) ? (-mode17_tmp) : (mode17_tmp));
			mode18	<=	mode18+((mode18_tmp[MODE]) ? (-mode18_tmp) : (mode18_tmp));
			mode19	<=	mode19+((mode19_tmp[MODE]) ? (-mode19_tmp) : (mode19_tmp));
			mode20	<=	mode20+((mode20_tmp[MODE]) ? (-mode20_tmp) : (mode20_tmp));
			mode21	<=	mode21+((mode21_tmp[MODE]) ? (-mode21_tmp) : (mode21_tmp));
			mode22	<=	mode22+((mode22_tmp[MODE]) ? (-mode22_tmp) : (mode22_tmp));
			mode23	<=	mode23+((mode23_tmp[MODE]) ? (-mode23_tmp) : (mode23_tmp));
			mode24	<=	mode24+((mode24_tmp[MODE]) ? (-mode24_tmp) : (mode24_tmp));
			mode25	<=	mode25+((mode25_tmp[MODE]) ? (-mode25_tmp) : (mode25_tmp));
			mode26	<=	mode26+((mode26_tmp[MODE]) ? (-mode26_tmp) : (mode26_tmp));
			mode27	<=	mode27+((mode27_tmp[MODE]) ? (-mode27_tmp) : (mode27_tmp));
			mode28	<=	mode28+((mode28_tmp[MODE]) ? (-mode28_tmp) : (mode28_tmp));
			mode29	<=	mode29+((mode29_tmp[MODE]) ? (-mode29_tmp) : (mode29_tmp));
			mode30	<=	mode30+((mode30_tmp[MODE]) ? (-mode30_tmp) : (mode30_tmp));
			mode31	<=	mode31+((mode31_tmp[MODE]) ? (-mode31_tmp) : (mode31_tmp));
			mode32	<=	mode32+((mode32_tmp[MODE]) ? (-mode32_tmp) : (mode32_tmp));
			mode33	<=	mode33+((mode33_tmp[MODE]) ? (-mode33_tmp) : (mode33_tmp));
		end
	else if(counterrun1)
		begin
			mode2	<=	'd0;
			mode3	<=	'd0;
			mode4	<=	'd0;
			mode5	<=	'd0;
			mode6	<=	'd0;
			mode7	<=	'd0;
			mode8	<=	'd0;
			mode9	<=	'd0;
			mode10	<=	'd0;
			mode11	<=	'd0;
			mode12	<=	'd0;
			mode13	<=	'd0;
			mode14	<=	'd0;
			mode15	<=	'd0;
			mode16	<=	'd0;
			mode17	<=	'd0;
			mode18	<=	'd0;
			mode19	<=	'd0;
			mode20	<=	'd0;
			mode21	<=	'd0;
			mode22	<=	'd0;
			mode23	<=	'd0;
			mode24	<=	'd0;
			mode25	<=	'd0;
			mode26	<=	'd0;
			mode27	<=	'd0;
			mode28	<=	'd0;
			mode29	<=	'd0;
			mode30	<=	'd0;
			mode31	<=	'd0;
			mode32	<=	'd0;
			mode33	<=	'd0;
		end
			
endmodule
	