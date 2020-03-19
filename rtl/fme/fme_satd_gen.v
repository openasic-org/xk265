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
//  Filename      : fme_satd_gen.v
//  Author        : Yufeng Bai
//  Email 	  : byfchina@gmail.com	
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fme_satd_gen (
	clk		        ,
	rstn		        ,
	satd_start_i		,
	blk_idx_i		,
	half_ip_flag_i          ,
	mv_x_i		        ,
	mv_y_i		        ,
	mv_x_o		        ,
	mv_y_o		        ,
	blk_idx_o		,
	half_ip_flag_o          ,
	ip_ready_i              ,
	end_ip_i		,
	cost_start_o		,
	cur_rden_o		,
	//cur_sel_o		,
	//cur_idx_o		,
	cur_4x4_idx_o           ,
	cur_4x4_x_o             ,
	cur_4x4_y_o             ,
	cur_pel_i		,
	candi0_valid_i		,
	candi1_valid_i		,
	candi2_valid_i		,
	candi3_valid_i		,
	candi4_valid_i		,
	candi5_valid_i		,
	candi6_valid_i		,
	candi7_valid_i		,
	candi8_valid_i		,
	candi0_pixles_i		,
	candi1_pixles_i		,
	candi2_pixles_i		,
	candi3_pixles_i		,
	candi4_pixles_i		,
	candi5_pixles_i		,
	candi6_pixles_i		,
	candi7_pixles_i		,
	candi8_pixles_i		,
	satd0_o		        ,
	satd1_o		        ,
	satd2_o		        ,
	satd3_o		        ,
	satd4_o		        ,
	satd5_o		        ,
	satd6_o		        ,
	satd7_o		        ,
	satd8_o		        ,
	satd_valid_o		
);

parameter SATD_WIDTH = `PIXEL_WIDTH + 10;

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input 	 [1-1:0] 	         clk 	         ; // clk signal 
input 	 [1-1:0] 	         rstn 	         ; // asynchronous reset 
input 	 [1-1:0] 	         satd_start_i 	 ; // 8x8 block satd start signal 
input 	 [6-1:0] 	         blk_idx_i 	 ; // specify current block index 
input 	 [1-1:0] 	         half_ip_flag_i  ; // half/ quarter interpolation 
input 	 [`FMV_WIDTH-1:0] 	 mv_x_i 	 ; //  
input 	 [`FMV_WIDTH-1:0] 	 mv_y_i 	 ; //  
output 	 [`FMV_WIDTH-1:0] 	 mv_x_o 	 ; // mv pass to cost cal. & cmp 
output 	 [`FMV_WIDTH-1:0] 	 mv_y_o 	 ; //  
output 	 [1-1:0] 	         half_ip_flag_o  ; // half/ quarter interpolation : pass to cost cal & cmp
output 	 [6-1:0] 	         blk_idx_o 	 ; // specify current block index 
input 	 [1-1:0] 	         ip_ready_i 	 ; // ip ready  
input 	 [1-1:0] 	         end_ip_i 	 ; // end of interpolation 

output 	 [1-1:0] 	         cost_start_o 	 ; // mv ready, cost start 
output 	 [1-1:0] 	         cur_rden_o 	 ; // current lcu read enable 
//output 	 [1-1:0] 	         cur_sel_o 	 ; // use block read mode 
//output 	 [6-1:0] 	         cur_idx_o 	 ; // current block read index 
output   [4-1:0]                 cur_4x4_x_o     ; // current 8x8 block x position
output   [4-1:0]                 cur_4x4_y_o     ; // current 8x8 block y position
output   [5-1:0]                 cur_4x4_idx_o   ; // current 8x8 block idx
input 	 [32*`PIXEL_WIDTH-1:0] 	 cur_pel_i 	 ; // current block pixel  

input 	 [1-1:0] 	         candi0_valid_i  ; // candidate 0 row pixels valid 
input 	 [1-1:0] 	         candi1_valid_i  ; // candidate 1 row pixels valid 
input 	 [1-1:0] 	         candi2_valid_i  ; // candidate 2 row pixels valid 
input 	 [1-1:0] 	         candi3_valid_i  ; // candidate 3 row pixels valid 
input 	 [1-1:0] 	         candi4_valid_i  ; // candidate 4 row pixels valid 
input 	 [1-1:0] 	         candi5_valid_i  ; // candidate 5 row pixels valid 
input 	 [1-1:0] 	         candi6_valid_i  ; // candidate 6 row pixels valid 
input 	 [1-1:0] 	         candi7_valid_i  ; // candidate 7 row pixels valid 
input 	 [1-1:0] 	         candi8_valid_i  ; // candidate 8 row pixels valid 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi0_pixles_i ; // candidate 0 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi1_pixles_i ; // candidate 1 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi2_pixles_i ; // candidate 2 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi3_pixles_i ; // candidate 3 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi4_pixles_i ; // candidate 4 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi5_pixles_i ; // candidate 5 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi6_pixles_i ; // candidate 6 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi7_pixles_i ; // candidate 7 row pixels 
input 	 [`PIXEL_WIDTH*8-1:0] 	 candi8_pixles_i ; // candidate 8 row pixels 

output 	 [SATD_WIDTH-1    :0] 	 satd0_o 	 ; // candidate 0 SATD 
output 	 [SATD_WIDTH-1    :0] 	 satd1_o 	 ; // candidate 1 SATD 
output 	 [SATD_WIDTH-1    :0] 	 satd2_o 	 ; // candidate 2 SATD 
output 	 [SATD_WIDTH-1    :0] 	 satd3_o 	 ; // candidate 3 SATD 
output 	 [SATD_WIDTH-1    :0] 	 satd4_o 	 ; // candidate 4 SATD 
output 	 [SATD_WIDTH-1    :0] 	 satd5_o 	 ; // candidate 5 SATD 
output 	 [SATD_WIDTH-1    :0] 	 satd6_o 	 ; // candidate 6 SATD 
output 	 [SATD_WIDTH-1    :0] 	 satd7_o 	 ; // candidate 7 SATD 
output 	 [SATD_WIDTH-1    :0] 	 satd8_o 	 ; // candidate 8 SATD 
output 	 [1-1:0] 	         satd_valid_o 	 ; // satd valid 

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************
reg      [`FMV_WIDTH-1:    0]    mv_x_o; // buffer0 to store mv information
reg      [`FMV_WIDTH-1:    0]    mv_y_o;
reg      [1-1:             0]    half_ip_flag_o;
reg      [1-1:             0]    cost_start_o;
reg      [1-1:             0]    cur_4x4_idx;

reg      [6-1:             0]    blk_idx_r0;
reg      [6-1:             0]    blk_idx_r1;
wire     [6-1:             0]    blk_idx   ;
reg                              idx_in_flag;
reg                              idx_out_flag;

wire     [8*`PIXEL_WIDTH-1:0]    cur_pixel0;
wire     [8*`PIXEL_WIDTH-1:0]    cur_pixel1;
wire     [8*`PIXEL_WIDTH-1:0]    cur_pixel2;
wire     [8*`PIXEL_WIDTH-1:0]    cur_pixel3;
wire     [8*`PIXEL_WIDTH-1:0]    cur_pixel4;
wire     [8*`PIXEL_WIDTH-1:0]    cur_pixel5;
wire     [8*`PIXEL_WIDTH-1:0]    cur_pixel6;
wire     [8*`PIXEL_WIDTH-1:0]    cur_pixel7;
reg      [32*`PIXEL_WIDTH-1:0]   cur_pel_reg0;
reg      [32*`PIXEL_WIDTH-1:0]   cur_pel_reg1;
reg                              cur_valid;


reg      [8*`PIXEL_WIDTH-1  :0]  sp0_cur;
reg      [8*`PIXEL_WIDTH-1  :0]  sp1_cur;
reg      [8*`PIXEL_WIDTH-1  :0]  sp2_cur;
reg      [8*`PIXEL_WIDTH-1  :0]  sp3_cur;
reg      [8*`PIXEL_WIDTH-1  :0]  sp4_cur;
reg      [8*`PIXEL_WIDTH-1  :0]  sp5_cur;
reg      [8*`PIXEL_WIDTH-1  :0]  sp6_cur;
reg      [8*`PIXEL_WIDTH-1  :0]  sp7_cur;
reg      [8*`PIXEL_WIDTH-1  :0]  sp8_cur;

reg      [3-1             :0]    sp0_cnt;
reg      [3-1             :0]    sp1_cnt;
reg      [3-1             :0]    sp2_cnt;
reg      [3-1             :0]    sp3_cnt;
reg      [3-1             :0]    sp4_cnt;
reg      [3-1             :0]    sp5_cnt;
reg      [3-1             :0]    sp6_cnt;
reg      [3-1             :0]    sp7_cnt;
reg      [3-1             :0]    sp8_cnt;

//reg      [4-1             :0]    satd_cnt;

wire     [SATD_WIDTH-1    :0]    sp0_satd;
wire     [SATD_WIDTH-1    :0]    sp1_satd;
wire     [SATD_WIDTH-1    :0]    sp2_satd;
wire     [SATD_WIDTH-1    :0]    sp3_satd;
wire     [SATD_WIDTH-1    :0]    sp4_satd;
wire     [SATD_WIDTH-1    :0]    sp5_satd;
wire     [SATD_WIDTH-1    :0]    sp6_satd;
wire     [SATD_WIDTH-1    :0]    sp7_satd;
wire     [SATD_WIDTH-1    :0]    sp8_satd;

wire     [2-1             :0]    cur_idx32, cur_idx16, cur_idx08;
wire     [3-1             :0]    cur_idx_x, cur_idx_y;
wire     [6-1             :0]    cur_idx;
// ********************************************
//
//    Combinational Logic
//
// ********************************************

assign   cur_pixel7 =  cur_pel_reg1[1*8*`PIXEL_WIDTH-1:0*8*`PIXEL_WIDTH];
assign   cur_pixel6 =  cur_pel_reg1[2*8*`PIXEL_WIDTH-1:1*8*`PIXEL_WIDTH];
assign   cur_pixel5 =  cur_pel_reg1[3*8*`PIXEL_WIDTH-1:2*8*`PIXEL_WIDTH];
assign   cur_pixel4 =  cur_pel_reg1[4*8*`PIXEL_WIDTH-1:3*8*`PIXEL_WIDTH];

assign   cur_pixel3 =  cur_pel_reg0[1*8*`PIXEL_WIDTH-1:0*8*`PIXEL_WIDTH];
assign   cur_pixel2 =  cur_pel_reg0[2*8*`PIXEL_WIDTH-1:1*8*`PIXEL_WIDTH];
assign   cur_pixel1 =  cur_pel_reg0[3*8*`PIXEL_WIDTH-1:2*8*`PIXEL_WIDTH];
assign   cur_pixel0 =  cur_pel_reg0[4*8*`PIXEL_WIDTH-1:3*8*`PIXEL_WIDTH];

assign	 cur_rden_o =  ip_ready_i; 
//assign	 cur_sel_o  =  1'b1; 
//assign	 cur_idx_o  =  {cur_idx_y, cur_idx_x};
assign   cur_4x4_x_o     = {cur_idx_x,1'b0};
assign   cur_4x4_y_o     = {cur_idx_y,1'b0};
assign   cur_4x4_idx_o   = {2'b0,cur_4x4_idx,2'b0};

assign   satd0_o = sp0_satd;
assign   satd1_o = sp1_satd;
assign   satd2_o = sp2_satd;
assign   satd3_o = sp3_satd;
assign   satd4_o = sp4_satd;
assign   satd5_o = sp5_satd;
assign   satd6_o = sp6_satd;
assign   satd7_o = sp7_satd;
assign   satd8_o = sp8_satd;

//assign   satd_valid_o = (satd_cnt == 'd9);

assign   blk_idx   = (idx_out_flag) ? blk_idx_r1 : blk_idx_r0;
assign	 cur_idx   = (idx_in_flag ) ? blk_idx_r0 : blk_idx_r1;

// zig-zag to raster

assign	 cur_idx32 = cur_idx[5:4];
assign	 cur_idx16 = cur_idx[3:2];
assign	 cur_idx08 = cur_idx[1:0];

assign	 cur_idx_x = {cur_idx32[0],cur_idx16[0],cur_idx08[0]};
assign	 cur_idx_y = {cur_idx32[1],cur_idx16[1],cur_idx08[1]};

assign   blk_idx_o = blk_idx; 

// ********************************************
//
//    Sequential Logic
//
// ********************************************

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	mv_x_o <= 'd0;
	mv_y_o <= 'd0;
	half_ip_flag_o <= 1'b0;
    end
    else if (end_ip_i) begin
	mv_x_o <= mv_x_i;
	mv_y_o <= mv_y_i;
	half_ip_flag_o <= half_ip_flag_i;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	cost_start_o <= 1'b0;
    end
    else begin
	cost_start_o <= end_ip_i;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	idx_in_flag <= 1'b0;
	blk_idx_r0  <= 'd0;
	blk_idx_r1  <= 'd0;
    end
    else if (satd_start_i) begin
	idx_in_flag <= ~idx_in_flag;
	if(~idx_in_flag) 
	    blk_idx_r0 <= blk_idx_i;
	else
	    blk_idx_r1 <= blk_idx_i;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	idx_out_flag  <= 1'd0;
    end
    else if (satd_valid_o) begin
	idx_out_flag  <= ~idx_out_flag;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	cur_4x4_idx <= 1'b0;
	cur_valid  <= 1'b0;
    end
    else if(cur_rden_o) begin
	cur_4x4_idx <= ~cur_4x4_idx;
	cur_valid  <= 1'b1;
    end
    else begin
	cur_4x4_idx <= cur_4x4_idx;
	cur_valid  <= 1'b0;
    end
end    

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	cur_pel_reg0 <= 'b0;
	cur_pel_reg1 <= 'b0;
    end
    else if(cur_valid) begin
	if(cur_4x4_idx) 
	    cur_pel_reg0 <= cur_pel_i;
	else
	    cur_pel_reg1 <= cur_pel_i;
    end
end
	
/*
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	satd_cnt <= 'd0;
    end
    else if ( end_ip_i) begin
	satd_cnt <= 'd0;
    end
    else begin
	satd_cnt <= satd_cnt + 'd1;
    end
end
*/

// ********************************************
//
//  SATD for Search Points  
//
// ********************************************

// sp 0
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	sp0_cnt <= 'd0;
    end
    else if (satd_start_i) begin
	sp0_cnt <= 'd0;
    end
    else if (candi0_valid_i) begin
	sp0_cnt <= sp0_cnt + 'd1;
    end
end

always @(*) begin
    case(sp0_cnt)
	3'd0: sp0_cur = cur_pixel0;
	3'd1: sp0_cur = cur_pixel1;
	3'd2: sp0_cur = cur_pixel2;
	3'd3: sp0_cur = cur_pixel3;
	3'd4: sp0_cur = cur_pixel4;
	3'd5: sp0_cur = cur_pixel5;
	3'd6: sp0_cur = cur_pixel6;
	3'd7: sp0_cur = cur_pixel7;
    endcase
end

fme_satd_8x8 sp0(
    .clk (clk),
    .rstn (rstn),

    .cur_p0_i(sp0_cur[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),
    .cur_p1_i(sp0_cur[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]), 
    .cur_p2_i(sp0_cur[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]), 
    .cur_p3_i(sp0_cur[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .cur_p4_i(sp0_cur[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),
    .cur_p5_i(sp0_cur[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]), 
    .cur_p6_i(sp0_cur[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]), 
    .cur_p7_i(sp0_cur[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .sp_valid_i(candi0_valid_i),

    .sp0_i(candi0_pixles_i[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),        
    .sp1_i(candi0_pixles_i[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]),        
    .sp2_i(candi0_pixles_i[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]),        
    .sp3_i(candi0_pixles_i[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .sp4_i(candi0_pixles_i[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),        
    .sp5_i(candi0_pixles_i[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]),        
    .sp6_i(candi0_pixles_i[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]),        
    .sp7_i(candi0_pixles_i[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .satd_8x8_o(sp0_satd),
    .satd_8x8_valid_o(sp0_valid)
);
/*
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	satd0_o <= 'd0;
    end
    else if (sp0_valid) begin
	satd0_o <= sp0_satd;
    end
end
*/

// sp 1
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	sp1_cnt <= 'd0;
    end
    else if (satd_start_i) begin
	sp1_cnt <= 'd0;
    end
    else if (candi1_valid_i) begin
	sp1_cnt <= sp1_cnt + 'd1;
    end
end

always @(*) begin
    case(sp1_cnt)
	3'd0: sp1_cur = cur_pixel0;
	3'd1: sp1_cur = cur_pixel1;
	3'd2: sp1_cur = cur_pixel2;
	3'd3: sp1_cur = cur_pixel3;
	3'd4: sp1_cur = cur_pixel4;
	3'd5: sp1_cur = cur_pixel5;
	3'd6: sp1_cur = cur_pixel6;
	3'd7: sp1_cur = cur_pixel7;
    endcase
end

fme_satd_8x8 sp1(
    .clk (clk),
    .rstn (rstn),

    .cur_p0_i(sp1_cur[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),
    .cur_p1_i(sp1_cur[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]), 
    .cur_p2_i(sp1_cur[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]), 
    .cur_p3_i(sp1_cur[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .cur_p4_i(sp1_cur[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),
    .cur_p5_i(sp1_cur[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]), 
    .cur_p6_i(sp1_cur[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]), 
    .cur_p7_i(sp1_cur[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .sp_valid_i(candi1_valid_i),

    .sp0_i(candi1_pixles_i[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),        
    .sp1_i(candi1_pixles_i[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]),        
    .sp2_i(candi1_pixles_i[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]),        
    .sp3_i(candi1_pixles_i[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .sp4_i(candi1_pixles_i[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),        
    .sp5_i(candi1_pixles_i[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]),        
    .sp6_i(candi1_pixles_i[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]),        
    .sp7_i(candi1_pixles_i[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .satd_8x8_o(sp1_satd),
    .satd_8x8_valid_o(sp1_valid)
);
/*
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	satd1_o <= 'd0;
    end
    else if (sp1_valid) begin
	satd1_o <= sp1_satd;
    end
end
*/

// sp 2
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	sp2_cnt <= 'd0;
    end
    else if (satd_start_i) begin
	sp2_cnt <= 'd0;
    end
    else if (candi2_valid_i) begin
	sp2_cnt <= sp2_cnt + 'd1;
    end
end

always @(*) begin
    case(sp2_cnt)
	3'd0: sp2_cur = cur_pixel0;
	3'd1: sp2_cur = cur_pixel1;
	3'd2: sp2_cur = cur_pixel2;
	3'd3: sp2_cur = cur_pixel3;
	3'd4: sp2_cur = cur_pixel4;
	3'd5: sp2_cur = cur_pixel5;
	3'd6: sp2_cur = cur_pixel6;
	3'd7: sp2_cur = cur_pixel7;
    endcase
end

fme_satd_8x8 sp2(
    .clk (clk),
    .rstn (rstn),

    .cur_p0_i(sp2_cur[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),
    .cur_p1_i(sp2_cur[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]), 
    .cur_p2_i(sp2_cur[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]), 
    .cur_p3_i(sp2_cur[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .cur_p4_i(sp2_cur[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),
    .cur_p5_i(sp2_cur[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]), 
    .cur_p6_i(sp2_cur[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]), 
    .cur_p7_i(sp2_cur[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .sp_valid_i(candi2_valid_i),

    .sp0_i(candi2_pixles_i[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),        
    .sp1_i(candi2_pixles_i[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]),        
    .sp2_i(candi2_pixles_i[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]),        
    .sp3_i(candi2_pixles_i[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .sp4_i(candi2_pixles_i[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),        
    .sp5_i(candi2_pixles_i[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]),        
    .sp6_i(candi2_pixles_i[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]),        
    .sp7_i(candi2_pixles_i[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .satd_8x8_o(sp2_satd),
    .satd_8x8_valid_o(sp2_valid)
);
/*
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	satd2_o <= 'd0;
    end
    else if (sp2_valid) begin
	satd2_o <= sp2_satd;
    end
end
*/

// sp 3
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	sp3_cnt <= 'd0;
    end
    else if (satd_start_i) begin
	sp3_cnt <= 'd0;
    end
    else if (candi3_valid_i) begin
	sp3_cnt <= sp3_cnt + 'd1;
    end
end

always @(*) begin
    case(sp3_cnt)
	3'd0: sp3_cur = cur_pixel0;
	3'd1: sp3_cur = cur_pixel1;
	3'd2: sp3_cur = cur_pixel2;
	3'd3: sp3_cur = cur_pixel3;
	3'd4: sp3_cur = cur_pixel4;
	3'd5: sp3_cur = cur_pixel5;
	3'd6: sp3_cur = cur_pixel6;
	3'd7: sp3_cur = cur_pixel7;
    endcase
end

fme_satd_8x8 sp3(
    .clk (clk),
    .rstn (rstn),

    .cur_p0_i(sp3_cur[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),
    .cur_p1_i(sp3_cur[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]), 
    .cur_p2_i(sp3_cur[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]), 
    .cur_p3_i(sp3_cur[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .cur_p4_i(sp3_cur[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),
    .cur_p5_i(sp3_cur[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]), 
    .cur_p6_i(sp3_cur[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]), 
    .cur_p7_i(sp3_cur[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .sp_valid_i(candi3_valid_i),

    .sp0_i(candi3_pixles_i[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),        
    .sp1_i(candi3_pixles_i[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]),        
    .sp2_i(candi3_pixles_i[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]),        
    .sp3_i(candi3_pixles_i[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .sp4_i(candi3_pixles_i[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),        
    .sp5_i(candi3_pixles_i[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]),        
    .sp6_i(candi3_pixles_i[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]),        
    .sp7_i(candi3_pixles_i[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .satd_8x8_o(sp3_satd),
    .satd_8x8_valid_o(sp3_valid)
);
/*
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	satd3_o <= 'd0;
    end
    else if (sp3_valid) begin
	satd3_o <= sp3_satd;
    end
end
*/

// sp 4
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	sp4_cnt <= 'd0;
    end
    else if (satd_start_i) begin
	sp4_cnt <= 'd0;
    end
    else if (candi4_valid_i) begin
	sp4_cnt <= sp4_cnt + 'd1;
    end
end

always @(*) begin
    case(sp4_cnt)
	3'd0: sp4_cur = cur_pixel0;
	3'd1: sp4_cur = cur_pixel1;
	3'd2: sp4_cur = cur_pixel2;
	3'd3: sp4_cur = cur_pixel3;
	3'd4: sp4_cur = cur_pixel4;
	3'd5: sp4_cur = cur_pixel5;
	3'd6: sp4_cur = cur_pixel6;
	3'd7: sp4_cur = cur_pixel7;
    endcase
end

fme_satd_8x8 sp4(
    .clk (clk),
    .rstn (rstn),

    .cur_p0_i(sp4_cur[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),
    .cur_p1_i(sp4_cur[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]), 
    .cur_p2_i(sp4_cur[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]), 
    .cur_p3_i(sp4_cur[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .cur_p4_i(sp4_cur[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),
    .cur_p5_i(sp4_cur[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]), 
    .cur_p6_i(sp4_cur[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]), 
    .cur_p7_i(sp4_cur[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .sp_valid_i(candi4_valid_i),

    .sp0_i(candi4_pixles_i[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),        
    .sp1_i(candi4_pixles_i[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]),        
    .sp2_i(candi4_pixles_i[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]),        
    .sp3_i(candi4_pixles_i[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .sp4_i(candi4_pixles_i[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),        
    .sp5_i(candi4_pixles_i[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]),        
    .sp6_i(candi4_pixles_i[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]),        
    .sp7_i(candi4_pixles_i[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .satd_8x8_o(sp4_satd),
    .satd_8x8_valid_o(sp4_valid)
);
/*
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	satd4_o <= 'd0;
    end
    else if (sp4_valid) begin
	satd4_o <= sp4_satd;
    end
end
*/

// sp 5
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	sp5_cnt <= 'd0;
    end
    else if (satd_start_i) begin
	sp5_cnt <= 'd0;
    end
    else if (candi5_valid_i) begin
	sp5_cnt <= sp5_cnt + 'd1;
    end
end

always @(*) begin
    case(sp5_cnt)
	3'd0: sp5_cur = cur_pixel0;
	3'd1: sp5_cur = cur_pixel1;
	3'd2: sp5_cur = cur_pixel2;
	3'd3: sp5_cur = cur_pixel3;
	3'd4: sp5_cur = cur_pixel4;
	3'd5: sp5_cur = cur_pixel5;
	3'd6: sp5_cur = cur_pixel6;
	3'd7: sp5_cur = cur_pixel7;
    endcase
end

fme_satd_8x8 sp5(
    .clk (clk),
    .rstn (rstn),

    .cur_p0_i(sp5_cur[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),
    .cur_p1_i(sp5_cur[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]), 
    .cur_p2_i(sp5_cur[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]), 
    .cur_p3_i(sp5_cur[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .cur_p4_i(sp5_cur[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),
    .cur_p5_i(sp5_cur[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]), 
    .cur_p6_i(sp5_cur[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]), 
    .cur_p7_i(sp5_cur[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .sp_valid_i(candi5_valid_i),

    .sp0_i(candi5_pixles_i[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),        
    .sp1_i(candi5_pixles_i[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]),        
    .sp2_i(candi5_pixles_i[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]),        
    .sp3_i(candi5_pixles_i[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .sp4_i(candi5_pixles_i[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),        
    .sp5_i(candi5_pixles_i[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]),        
    .sp6_i(candi5_pixles_i[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]),        
    .sp7_i(candi5_pixles_i[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .satd_8x8_o(sp5_satd),
    .satd_8x8_valid_o(sp5_valid)
);
/*
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	satd5_o <= 'd0;
    end
    else if (sp5_valid) begin
	satd5_o <= sp5_satd;
    end
end
*/

// sp 6
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	sp6_cnt <= 'd0;
    end
    else if (satd_start_i) begin
	sp6_cnt <= 'd0;
    end
    else if (candi6_valid_i) begin
	sp6_cnt <= sp6_cnt + 'd1;
    end
end

always @(*) begin
    case(sp6_cnt)
	3'd0: sp6_cur = cur_pixel0;
	3'd1: sp6_cur = cur_pixel1;
	3'd2: sp6_cur = cur_pixel2;
	3'd3: sp6_cur = cur_pixel3;
	3'd4: sp6_cur = cur_pixel4;
	3'd5: sp6_cur = cur_pixel5;
	3'd6: sp6_cur = cur_pixel6;
	3'd7: sp6_cur = cur_pixel7;
    endcase
end

fme_satd_8x8 sp6(
    .clk (clk),
    .rstn (rstn),

    .cur_p0_i(sp6_cur[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),
    .cur_p1_i(sp6_cur[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]), 
    .cur_p2_i(sp6_cur[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]), 
    .cur_p3_i(sp6_cur[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .cur_p4_i(sp6_cur[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),
    .cur_p5_i(sp6_cur[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]), 
    .cur_p6_i(sp6_cur[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]), 
    .cur_p7_i(sp6_cur[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .sp_valid_i(candi6_valid_i),

    .sp0_i(candi6_pixles_i[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),        
    .sp1_i(candi6_pixles_i[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]),        
    .sp2_i(candi6_pixles_i[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]),        
    .sp3_i(candi6_pixles_i[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .sp4_i(candi6_pixles_i[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),        
    .sp5_i(candi6_pixles_i[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]),        
    .sp6_i(candi6_pixles_i[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]),        
    .sp7_i(candi6_pixles_i[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .satd_8x8_o(sp6_satd),
    .satd_8x8_valid_o(sp6_valid)
);
/*
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	satd6_o <= 'd0;
    end
    else if (sp6_valid) begin
	satd6_o <= sp6_satd;
    end
end
*/

// sp 7
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	sp7_cnt <= 'd0;
    end
    else if (satd_start_i) begin
	sp7_cnt <= 'd0;
    end
    else if (candi7_valid_i) begin
	sp7_cnt <= sp7_cnt + 'd1;
    end
end

always @(*) begin
    case(sp7_cnt)
	3'd0: sp7_cur = cur_pixel0;
	3'd1: sp7_cur = cur_pixel1;
	3'd2: sp7_cur = cur_pixel2;
	3'd3: sp7_cur = cur_pixel3;
	3'd4: sp7_cur = cur_pixel4;
	3'd5: sp7_cur = cur_pixel5;
	3'd6: sp7_cur = cur_pixel6;
	3'd7: sp7_cur = cur_pixel7;
    endcase
end

fme_satd_8x8 sp7(
    .clk (clk),
    .rstn (rstn),

    .cur_p0_i(sp7_cur[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),
    .cur_p1_i(sp7_cur[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]), 
    .cur_p2_i(sp7_cur[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]), 
    .cur_p3_i(sp7_cur[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .cur_p4_i(sp7_cur[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),
    .cur_p5_i(sp7_cur[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]), 
    .cur_p6_i(sp7_cur[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]), 
    .cur_p7_i(sp7_cur[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .sp_valid_i(candi7_valid_i),

    .sp0_i(candi7_pixles_i[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),        
    .sp1_i(candi7_pixles_i[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]),        
    .sp2_i(candi7_pixles_i[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]),        
    .sp3_i(candi7_pixles_i[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .sp4_i(candi7_pixles_i[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),        
    .sp5_i(candi7_pixles_i[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]),        
    .sp6_i(candi7_pixles_i[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]),        
    .sp7_i(candi7_pixles_i[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .satd_8x8_o(sp7_satd),
    .satd_8x8_valid_o(sp7_valid)
);
/*
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	satd7_o <= 'd0;
    end
    else if (sp7_valid) begin
	satd7_o <= sp7_satd;
    end
end
*/

// sp 8
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	sp8_cnt <= 'd0;
    end
    else if (satd_start_i) begin
	sp8_cnt <= 'd0;
    end
    else if (candi8_valid_i) begin
	sp8_cnt <= sp8_cnt + 'd1;
    end
end

always @(*) begin
    case(sp8_cnt)
	3'd0: sp8_cur = cur_pixel0;
	3'd1: sp8_cur = cur_pixel1;
	3'd2: sp8_cur = cur_pixel2;
	3'd3: sp8_cur = cur_pixel3;
	3'd4: sp8_cur = cur_pixel4;
	3'd5: sp8_cur = cur_pixel5;
	3'd6: sp8_cur = cur_pixel6;
	3'd7: sp8_cur = cur_pixel7;
    endcase
end

fme_satd_8x8 sp8(
    .clk (clk),
    .rstn (rstn),

    .cur_p0_i(sp8_cur[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),
    .cur_p1_i(sp8_cur[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]), 
    .cur_p2_i(sp8_cur[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]), 
    .cur_p3_i(sp8_cur[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .cur_p4_i(sp8_cur[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),
    .cur_p5_i(sp8_cur[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]), 
    .cur_p6_i(sp8_cur[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]), 
    .cur_p7_i(sp8_cur[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .sp_valid_i(candi8_valid_i),

    .sp0_i(candi8_pixles_i[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),        
    .sp1_i(candi8_pixles_i[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]),        
    .sp2_i(candi8_pixles_i[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]),        
    .sp3_i(candi8_pixles_i[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
    .sp4_i(candi8_pixles_i[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),        
    .sp5_i(candi8_pixles_i[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]),        
    .sp6_i(candi8_pixles_i[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]),        
    .sp7_i(candi8_pixles_i[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),

    .satd_8x8_o(sp8_satd),
    .satd_8x8_valid_o(satd_valid_o)
);
/*
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	satd8_o <= 'd0;
    end
    else if (sp8_valid) begin
	satd8_o <= sp8_satd;
    end
end
*/



endmodule

