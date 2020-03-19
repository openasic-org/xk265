//======================================
//
//      intra mode desicion fetch
//		 luyanheng
//
//======================================
module md_fetch(
	clk,
	rstn,
	enable,
	cnt,
	rf_512bit,
	x1,
	x2,
	x3
);

	input					clk;
	input					rstn;
	input					enable;
	input		[5:0]		cnt;
	input       [511:0]     rf_512bit;
	output		[23:0]		x1;
	output		[23:0]		x2;
	output		[23:0]		x3;
	
	reg		[23:0]		x1;
	reg		[23:0]		x2;
	reg		[23:0]		x3;
	
always@(posedge clk or negedge rstn)
	if(!rstn)
		begin
			x1 <= 'd0;
			x2 <= 'd0;
			x3 <= 'd0;
		end
	else
	case(cnt)
		'd5 : begin x1<= rf_512bit[511:488]; x2<= rf_512bit[447:424]; x3<= rf_512bit[383:360]; end
		'd6 : begin x1<= rf_512bit[503:480]; x2<= rf_512bit[439:416]; x3<= rf_512bit[375:352]; end
		'd7 : begin x1<= rf_512bit[495:472]; x2<= rf_512bit[431:408]; x3<= rf_512bit[367:344]; end
		'd8 : begin x1<= rf_512bit[487:464]; x2<= rf_512bit[423:400]; x3<= rf_512bit[359:336]; end
		'd9 : begin x1<= rf_512bit[479:456]; x2<= rf_512bit[415:392]; x3<= rf_512bit[351:328]; end
		'd10: begin x1<= rf_512bit[471:448]; x2<= rf_512bit[407:384]; x3<= rf_512bit[343:320]; end
		'd11: begin x1<= rf_512bit[447:424]; x2<= rf_512bit[383:360]; x3<= rf_512bit[319:296]; end
		'd12: begin x1<= rf_512bit[439:416]; x2<= rf_512bit[375:352]; x3<= rf_512bit[311:288]; end
		'd13: begin x1<= rf_512bit[431:408]; x2<= rf_512bit[367:344]; x3<= rf_512bit[303:280]; end
		'd14: begin x1<= rf_512bit[423:400]; x2<= rf_512bit[359:336]; x3<= rf_512bit[295:272]; end
		'd15: begin x1<= rf_512bit[415:392]; x2<= rf_512bit[351:328]; x3<= rf_512bit[287:264]; end
		'd16: begin x1<= rf_512bit[407:384]; x2<= rf_512bit[343:320]; x3<= rf_512bit[279:256]; end
		'd17: begin x1<= rf_512bit[383:360]; x2<= rf_512bit[319:296]; x3<= rf_512bit[255:232]; end
		'd18: begin x1<= rf_512bit[375:352]; x2<= rf_512bit[311:288]; x3<= rf_512bit[247:224]; end
		'd19: begin x1<= rf_512bit[367:344]; x2<= rf_512bit[303:280]; x3<= rf_512bit[239:216]; end
		'd20: begin x1<= rf_512bit[359:336]; x2<= rf_512bit[295:272]; x3<= rf_512bit[231:208]; end
		'd21: begin x1<= rf_512bit[351:328]; x2<= rf_512bit[287:264]; x3<= rf_512bit[223:200]; end
		'd22: begin x1<= rf_512bit[343:320]; x2<= rf_512bit[279:256]; x3<= rf_512bit[215:192]; end
		'd23: begin x1<= rf_512bit[319:296]; x2<= rf_512bit[255:232]; x3<= rf_512bit[191:168]; end
		'd24: begin x1<= rf_512bit[311:288]; x2<= rf_512bit[247:224]; x3<= rf_512bit[183:160]; end
		'd25: begin x1<= rf_512bit[303:280]; x2<= rf_512bit[239:216]; x3<= rf_512bit[175:152]; end
		'd26: begin x1<= rf_512bit[295:272]; x2<= rf_512bit[231:208]; x3<= rf_512bit[167:144]; end
		'd27: begin x1<= rf_512bit[287:264]; x2<= rf_512bit[223:200]; x3<= rf_512bit[159:136]; end
		'd28: begin x1<= rf_512bit[279:256]; x2<= rf_512bit[215:192]; x3<= rf_512bit[151:128]; end
		'd29: begin x1<= rf_512bit[255:232]; x2<= rf_512bit[191:168]; x3<= rf_512bit[127:104]; end
		'd30: begin x1<= rf_512bit[247:224]; x2<= rf_512bit[183:160]; x3<= rf_512bit[119: 96]; end
		'd31: begin x1<= rf_512bit[239:216]; x2<= rf_512bit[175:152]; x3<= rf_512bit[111: 88]; end
		'd32: begin x1<= rf_512bit[231:208]; x2<= rf_512bit[167:144]; x3<= rf_512bit[103: 80]; end
		'd33: begin x1<= rf_512bit[223:200]; x2<= rf_512bit[159:136]; x3<= rf_512bit[ 95: 72]; end
		'd34: begin x1<= rf_512bit[215:192]; x2<= rf_512bit[151:128]; x3<= rf_512bit[ 87: 64]; end
		'd35: begin x1<= rf_512bit[191:168]; x2<= rf_512bit[127:104]; x3<= rf_512bit[ 63: 40]; end
		'd36: begin x1<= rf_512bit[183:160]; x2<= rf_512bit[119: 96]; x3<= rf_512bit[ 55: 32]; end
		'd37: begin x1<= rf_512bit[175:152]; x2<= rf_512bit[111: 88]; x3<= rf_512bit[ 47: 24]; end
		'd38: begin x1<= rf_512bit[167:144]; x2<= rf_512bit[103: 80]; x3<= rf_512bit[ 39: 16]; end
		'd39: begin x1<= rf_512bit[159:136]; x2<= rf_512bit[ 95: 72]; x3<= rf_512bit[ 31:  8]; end
		'd40: begin x1<= rf_512bit[151:128]; x2<= rf_512bit[ 87: 64]; x3<= rf_512bit[ 23:  0]; end
		default:	begin x1 <= 'd0; x2 <= 'd0; x3 <= 'd0; end
	endcase
			
endmodule
