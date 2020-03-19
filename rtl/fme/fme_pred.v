//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2014, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//
//-------------------------------------------------------------------
//
//  Filename      : fme_pred.v
//  Author        : Yufeng Bai
//  Email         : byfchina@gmail.com	
//  Created On    : 2014-12-24 
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fme_pred (
	clk		        ,
	rstn		        ,
	ip_start_i	        ,
        end_ip_i                ,
	imv_x_i		        ,
	imv_y_i		        ,
	fmv_x_i		        ,
	fmv_y_i		        ,
	block_idx_i	        ,
	candi0_valid_i	        ,
	candi1_valid_i	        ,
	candi2_valid_i	        ,
	candi3_valid_i	        ,
	candi4_valid_i	        ,
	candi5_valid_i	        ,
	candi6_valid_i	        ,
	candi7_valid_i	        ,
	candi8_valid_i	        ,
	candi0_pixles_i	        ,
	candi1_pixles_i	        ,
	candi2_pixles_i	        ,
	candi3_pixles_i	        ,
	candi4_pixles_i	        ,
	candi5_pixles_i	        ,
	candi6_pixles_i	        ,
	candi7_pixles_i	        ,
	candi8_pixles_i	        ,
	pred_pixel_o	        ,
	pred_wren_o	        ,
	pred_addr_o 	       
);


// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input 	 [1-1:0] 	         clk 	                 ; // clk signal 
input 	 [1-1:0] 	         rstn 	                 ; // asynchronous reset 
input 	 [1-1:0] 	         ip_start_i 	         ; // 8x8 block ip start signal 
input 	 [1-1:0] 	         end_ip_i                ; // 8x8 block ip done 
input 	 [`FMV_WIDTH-1:0] 	 imv_x_i 	         ; // imv x  
input 	 [`FMV_WIDTH-1:0] 	 imv_y_i 	         ; // imv y 
input 	 [`FMV_WIDTH-1:0] 	 fmv_x_i 	         ; // fmv x 
input 	 [`FMV_WIDTH-1:0] 	 fmv_y_i 	         ; // fmv y 
input 	 [6-1:0] 	         block_idx_i 	         ; // processing block index 
input 	 [1-1:0] 	         candi0_valid_i 	 ; // candidate 0 row pixels valid 
input 	 [1-1:0] 	         candi1_valid_i 	 ; // candidate 1 row pixels valid 
input 	 [1-1:0] 	         candi2_valid_i 	 ; // candidate 2 row pixels valid 
input 	 [1-1:0] 	         candi3_valid_i 	 ; // candidate 3 row pixels valid 
input 	 [1-1:0] 	         candi4_valid_i 	 ; // candidate 4 row pixels valid 
input 	 [1-1:0] 	         candi5_valid_i 	 ; // candidate 5 row pixels valid 
input 	 [1-1:0] 	         candi6_valid_i 	 ; // candidate 6 row pixels valid 
input 	 [1-1:0] 	         candi7_valid_i 	 ; // candidate 7 row pixels valid 
input 	 [1-1:0] 	         candi8_valid_i 	 ; // candidate 8 row pixels valid 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi0_pixles_i 	 ; // candidate 0 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi1_pixles_i 	 ; // candidate 1 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi2_pixles_i 	 ; // candidate 2 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi3_pixles_i 	 ; // candidate 3 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi4_pixles_i 	 ; // candidate 4 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi5_pixles_i 	 ; // candidate 5 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi6_pixles_i 	 ; // candidate 6 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi7_pixles_i 	 ; // candidate 7 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi8_pixles_i 	 ; // candidate 8 row pixels 

output 	 [`PIXEL_WIDTH*32-1:0] 	 pred_pixel_o 	         ; // fme predicted pixels data 
output 	 [4-1:0] 	         pred_wren_o 	         ; // predicted pixels valid 
output 	 [7-1:0] 	         pred_addr_o 	         ; // 8x8 block y position in lcu 

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

wire signed [3-1 :0] dmv_x, dmv_y;
wire signed [3-1 :0] frac_x, frac_y;
wire        [4-1 :0] best_candi;

reg         [4-1 :0] best_r0, best_r1;
reg         [6-1 :0] idx_r0, idx_r1;
wire        [4-1 :0] best;
reg                  flag,flag_out;

wire        [2-1 :0] cnt32, cnt16, cnt08;

reg         [8*`PIXEL_WIDTH-1:0] predicted_pixel_o;
reg         [1-1             :0] predicted_valid_o;
reg 	    [3-1:0] 	         predicted_cnt_o 	 ; // predicted pixels counter 

reg 	    [4-1:0] 	          pred_wren_o 	         ; // predicted pixels valid 
reg 	    [`PIXEL_WIDTH*32-1:0] pred_pixel_o 	         ; // fme predicted pixels data 
// ********************************************
//
//    Combinational Logic
//
// ********************************************

assign dmv_x      = fmv_x_i - imv_x_i; 
assign dmv_y      = fmv_y_i - imv_y_i; 

assign frac_x     = (dmv_x == 0) ? 3'b000 : ((dmv_x < 0 ) ? 3'b110 : 3'b010); // frac < 0: -2 ; frac > 0 : +2 ; frac == 0: 0
assign frac_y     = (dmv_y == 0) ? 3'b000 : ((dmv_y < 0 ) ? 3'b110 : 3'b010); // frac < 0: -2 ; frac > 0 : +2 ; frac == 0: 0

assign best_candi = (dmv_y - frac_y + 1) * 3 + (dmv_x - frac_x) + 1;
assign best       = (flag_out) ? best_r1 : best_r0;

assign {cnt32,cnt16,cnt08} = (flag_out) ? idx_r1: idx_r0;

always @ (*) begin
    case(best)
	4'd0 :   begin predicted_pixel_o = candi0_pixles_i; predicted_valid_o = candi0_valid_i; end 
	4'd1 :   begin predicted_pixel_o = candi1_pixles_i; predicted_valid_o = candi1_valid_i; end 
	4'd2 :   begin predicted_pixel_o = candi2_pixles_i; predicted_valid_o = candi2_valid_i; end 
	4'd3 :   begin predicted_pixel_o = candi3_pixles_i; predicted_valid_o = candi3_valid_i; end 
	4'd4 :   begin predicted_pixel_o = candi4_pixles_i; predicted_valid_o = candi4_valid_i; end 
	4'd5 :   begin predicted_pixel_o = candi5_pixles_i; predicted_valid_o = candi5_valid_i; end 
	4'd6 :   begin predicted_pixel_o = candi6_pixles_i; predicted_valid_o = candi6_valid_i; end 
	4'd7 :   begin predicted_pixel_o = candi7_pixles_i; predicted_valid_o = candi7_valid_i; end 
	4'd8 :   begin predicted_pixel_o = candi8_pixles_i; predicted_valid_o = candi8_valid_i; end 
	default: begin predicted_pixel_o = candi4_pixles_i; predicted_valid_o = candi4_valid_i; end 
    endcase
end

//assign pre_lcu_x_o = {cnt32[0], cnt16[0], cnt08[0]};
//assign pre_lcu_y_o = {cnt32[1], cnt16[1], cnt08[1]};

// ********************************************
//
//    Sequential Logic
//
// ********************************************

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	best_r0 <= 'd0;
	best_r1 <= 'd0;
	idx_r0 <= 'd0;
	idx_r1 <= 'd0;
	flag <= 'd0;
    end
    else if(ip_start_i) begin
	flag <= ~flag;
	if(~flag) begin
	    best_r0 <= best_candi;
	    idx_r0 <= block_idx_i;
	end
	else begin
	    best_r1 <= best_candi;
	    idx_r1 <= block_idx_i;
	end
    end
end

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	flag_out <= 1'b0;
    end
    else if (end_ip_i) begin
	flag_out <= ~flag_out;
    end
end

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
	predicted_cnt_o <= 'd0;
    end
    else if (predicted_valid_o) begin
	predicted_cnt_o <= predicted_cnt_o + 'd1;
    end
end

assign pred_addr_o = {cnt32[1], cnt32[0], cnt16[1], cnt08[1], predicted_cnt_o};

always @ (*) begin
    case({cnt16[0],cnt08[0]})
	2'b00: begin pred_pixel_o = { predicted_pixel_o , 64'b0, 64'b0, 64'b0 }; pred_wren_o = 4'b1000 & {4{predicted_valid_o}}; end 
	2'b01: begin pred_pixel_o = { 64'b0, predicted_pixel_o , 64'b0, 64'b0 }; pred_wren_o = 4'b0100 & {4{predicted_valid_o}}; end
	2'b10: begin pred_pixel_o = { 64'b0, 64'b0, predicted_pixel_o , 64'b0 }; pred_wren_o = 4'b0010 & {4{predicted_valid_o}}; end
	2'b11: begin pred_pixel_o = { 64'b0, 64'b0, 64'b0, predicted_pixel_o  }; pred_wren_o = 4'b0001 & {4{predicted_valid_o}}; end
    endcase
end

endmodule

