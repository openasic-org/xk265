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
//  Filename      : fme_satd_8x8.v
//  Author        : Yufeng Bai
//  Created       : 2014-12-03 22:24:58
//  Email 	  : byfchina@gmail.com	
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fme_abs (
    a_i,
    b_o
);

parameter INPUT_BITS = `PIXEL_WIDTH;

input     [INPUT_BITS-1 : 0] a_i;
output    [INPUT_BITS-2 : 0] b_o;

wire      [INPUT_BITS-1 : 0] b_o_w ; 

assign b_o_w = ({(INPUT_BITS-1){a_i[INPUT_BITS-1]}} ^ {a_i[INPUT_BITS-2:0]}) + {{(INPUT_BITS-1){1'b0}},a_i[INPUT_BITS-1]};
assign b_o   = b_o_w[INPUT_BITS-2:0];


endmodule


module hadamard_trans_1d (
    idata_0, 
    idata_1, 
    idata_2, 
    idata_3, 
    idata_4, 
    idata_5, 
    idata_6, 
    idata_7,

    odata_0,
    odata_1,
    odata_2,
    odata_3,
    odata_4,
    odata_5,
    odata_6,
    odata_7
);

parameter DATA_WIDTH = `PIXEL_WIDTH + 1;

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************


input  signed  [DATA_WIDTH-1         :0] idata_0;
input  signed  [DATA_WIDTH-1         :0] idata_1;
input  signed  [DATA_WIDTH-1         :0] idata_2;
input  signed  [DATA_WIDTH-1         :0] idata_3;
input  signed  [DATA_WIDTH-1         :0] idata_4;
input  signed  [DATA_WIDTH-1         :0] idata_5;
input  signed  [DATA_WIDTH-1         :0] idata_6;
input  signed  [DATA_WIDTH-1         :0] idata_7;

output signed  [DATA_WIDTH+2         :0] odata_0;
output signed  [DATA_WIDTH+2         :0] odata_1;
output signed  [DATA_WIDTH+2         :0] odata_2;
output signed  [DATA_WIDTH+2         :0] odata_3;
output signed  [DATA_WIDTH+2         :0] odata_4;
output signed  [DATA_WIDTH+2         :0] odata_5;
output signed  [DATA_WIDTH+2         :0] odata_6;
output signed  [DATA_WIDTH+2         :0] odata_7;

wire   signed  [DATA_WIDTH           :0] m1_0;
wire   signed  [DATA_WIDTH           :0] m1_1;
wire   signed  [DATA_WIDTH           :0] m1_2;
wire   signed  [DATA_WIDTH           :0] m1_3;
wire   signed  [DATA_WIDTH           :0] m1_4;
wire   signed  [DATA_WIDTH           :0] m1_5;
wire   signed  [DATA_WIDTH           :0] m1_6;
wire   signed  [DATA_WIDTH           :0] m1_7;

wire   signed  [DATA_WIDTH+1         :0] m2_0;
wire   signed  [DATA_WIDTH+1         :0] m2_1;
wire   signed  [DATA_WIDTH+1         :0] m2_2;
wire   signed  [DATA_WIDTH+1         :0] m2_3;
wire   signed  [DATA_WIDTH+1         :0] m2_4;
wire   signed  [DATA_WIDTH+1         :0] m2_5;
wire   signed  [DATA_WIDTH+1         :0] m2_6;
wire   signed  [DATA_WIDTH+1         :0] m2_7;


assign m1_0    = {idata_0[DATA_WIDTH-1],idata_0} + {idata_4[DATA_WIDTH-1],idata_4};
assign m1_1    = {idata_1[DATA_WIDTH-1],idata_1} + {idata_5[DATA_WIDTH-1],idata_5};
assign m1_2    = {idata_2[DATA_WIDTH-1],idata_2} + {idata_6[DATA_WIDTH-1],idata_6};
assign m1_3    = {idata_3[DATA_WIDTH-1],idata_3} + {idata_7[DATA_WIDTH-1],idata_7};
assign m1_4    = {idata_0[DATA_WIDTH-1],idata_0} - {idata_4[DATA_WIDTH-1],idata_4};
assign m1_5    = {idata_1[DATA_WIDTH-1],idata_1} - {idata_5[DATA_WIDTH-1],idata_5};
assign m1_6    = {idata_2[DATA_WIDTH-1],idata_2} - {idata_6[DATA_WIDTH-1],idata_6};
assign m1_7    = {idata_3[DATA_WIDTH-1],idata_3} - {idata_7[DATA_WIDTH-1],idata_7};

assign m2_0    = {m1_0[DATA_WIDTH],m1_0}         + {m1_2[DATA_WIDTH],m1_2};
assign m2_1    = {m1_1[DATA_WIDTH],m1_1}         + {m1_3[DATA_WIDTH],m1_3};
assign m2_2    = {m1_0[DATA_WIDTH],m1_0}         - {m1_2[DATA_WIDTH],m1_2};
assign m2_3    = {m1_1[DATA_WIDTH],m1_1}         - {m1_3[DATA_WIDTH],m1_3};
assign m2_4    = {m1_4[DATA_WIDTH],m1_4}         + {m1_6[DATA_WIDTH],m1_6};
assign m2_5    = {m1_5[DATA_WIDTH],m1_5}         + {m1_7[DATA_WIDTH],m1_7};
assign m2_6    = {m1_4[DATA_WIDTH],m1_4}         - {m1_6[DATA_WIDTH],m1_6};
assign m2_7    = {m1_5[DATA_WIDTH],m1_5}         - {m1_7[DATA_WIDTH],m1_7};

assign odata_0 = {m2_0[DATA_WIDTH+1],m2_0}       + {m2_1[DATA_WIDTH+1],m2_1};
assign odata_1 = {m2_0[DATA_WIDTH+1],m2_0}       - {m2_1[DATA_WIDTH+1],m2_1};
assign odata_2 = {m2_2[DATA_WIDTH+1],m2_2}       + {m2_3[DATA_WIDTH+1],m2_3};
assign odata_3 = {m2_2[DATA_WIDTH+1],m2_2}       - {m2_3[DATA_WIDTH+1],m2_3};
assign odata_4 = {m2_4[DATA_WIDTH+1],m2_4}       + {m2_5[DATA_WIDTH+1],m2_5};
assign odata_5 = {m2_4[DATA_WIDTH+1],m2_4}       - {m2_5[DATA_WIDTH+1],m2_5};
assign odata_6 = {m2_6[DATA_WIDTH+1],m2_6}       + {m2_7[DATA_WIDTH+1],m2_7};
assign odata_7 = {m2_6[DATA_WIDTH+1],m2_6}       - {m2_7[DATA_WIDTH+1],m2_7};

endmodule
    
module hadamard_trans_2d (
    clk,
    rstn,

    valid_i,
    diff0_i, diff1_i, diff2_i, diff3_i,
    diff4_i, diff5_i, diff6_i, diff7_i,
    htvalid_o,
    ht0_o,   ht1_o,   ht2_o,   ht3_o,
    ht4_o,   ht5_o,   ht6_o,   ht7_o
);

parameter DATAIN_WIDTH      = `PIXEL_WIDTH + 1;
localparam HAD_1D_IN_WIDTH  = DATAIN_WIDTH;
localparam HAD_1D_OUT_WIDTH = DATAIN_WIDTH + 3;
localparam HAD_2D_IN_WIDTH  = DATAIN_WIDTH + 3;
localparam HAD_2D_OUT_WIDTH = DATAIN_WIDTH + 6;
localparam DATAOUT_WIDTH    = DATAIN_WIDTH + 6;

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input                               clk; 
input				    rstn;

input                               valid_i;
input  signed [DATAIN_WIDTH-1  : 0] diff0_i, diff1_i, diff2_i, diff3_i;
input  signed [DATAIN_WIDTH-1  : 0] diff4_i, diff5_i, diff6_i, diff7_i;

output                              htvalid_o;
output signed [DATAOUT_WIDTH-1 : 0] ht0_o,   ht1_o,   ht2_o,   ht3_o;
output signed [DATAOUT_WIDTH-1 : 0] ht4_o,   ht5_o,   ht6_o,   ht7_o;
    

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

wire   signed [DATAIN_WIDTH+2  : 0] ht_0, ht_1, ht_2, ht_3, ht_4, ht_5, ht_6, ht_7; 

reg           [2               : 0] write_cnt, read_cnt;
reg                                 flag               ; // flag to rotate the buffer . [row in, col out],[col in, row out],...
reg                                 read_available     ; // buffer full
wire   signed [DATAIN_WIDTH+2  : 0] ht_2d_0, ht_2d_1, ht_2d_2, ht_2d_3, ht_2d_4, ht_2d_5, ht_2d_6, ht_2d_7; 
// ********************************************
//
//   Sequential Logic 
//
// ********************************************

// control signals

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	read_available <= 1'b0;
    end
    else if (write_cnt == 3'd7 && valid_i) begin 
	read_available <= 1'b1;
    end
    else if (read_cnt == 3'd7) begin
	read_available <= 1'b0;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	write_cnt <= 'd0;
    end
    else if(valid_i) begin
	write_cnt <= write_cnt + 'd1;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	read_cnt <= 'd0;
    end
    else if(read_available) begin
	read_cnt <= read_cnt + 'd1;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	flag <= 1'b0;
    end
    else if (write_cnt == 3'd7 && valid_i) begin
	flag <= ~flag;
    end
end

// transpose buffer
reg	      [DATAIN_WIDTH+2  : 0] tb00,tb01,tb02,tb03,tb04,tb05,tb06,tb07; 
reg	      [DATAIN_WIDTH+2  : 0] tb10,tb11,tb12,tb13,tb14,tb15,tb16,tb17; 
reg	      [DATAIN_WIDTH+2  : 0] tb20,tb21,tb22,tb23,tb24,tb25,tb26,tb27; 
reg	      [DATAIN_WIDTH+2  : 0] tb30,tb31,tb32,tb33,tb34,tb35,tb36,tb37; 
reg	      [DATAIN_WIDTH+2  : 0] tb40,tb41,tb42,tb43,tb44,tb45,tb46,tb47; 
reg	      [DATAIN_WIDTH+2  : 0] tb50,tb51,tb52,tb53,tb54,tb55,tb56,tb57; 
reg	      [DATAIN_WIDTH+2  : 0] tb60,tb61,tb62,tb63,tb64,tb65,tb66,tb67; 
reg	      [DATAIN_WIDTH+2  : 0] tb70,tb71,tb72,tb73,tb74,tb75,tb76,tb77; 


always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
	tb00 <= 'd0; tb01 <= 'd0; tb02 <= 'd0; tb03 <= 'd0; tb04 <= 'd0; tb05 <= 'd0; tb06 <= 'd0; tb07 <= 'd0;
	tb10 <= 'd0; tb11 <= 'd0; tb12 <= 'd0; tb13 <= 'd0; tb14 <= 'd0; tb15 <= 'd0; tb16 <= 'd0; tb17 <= 'd0;
	tb20 <= 'd0; tb21 <= 'd0; tb22 <= 'd0; tb23 <= 'd0; tb24 <= 'd0; tb25 <= 'd0; tb26 <= 'd0; tb27 <= 'd0;
	tb30 <= 'd0; tb31 <= 'd0; tb32 <= 'd0; tb33 <= 'd0; tb34 <= 'd0; tb35 <= 'd0; tb36 <= 'd0; tb37 <= 'd0;
	tb40 <= 'd0; tb41 <= 'd0; tb42 <= 'd0; tb43 <= 'd0; tb44 <= 'd0; tb45 <= 'd0; tb46 <= 'd0; tb47 <= 'd0;
	tb50 <= 'd0; tb51 <= 'd0; tb52 <= 'd0; tb53 <= 'd0; tb54 <= 'd0; tb55 <= 'd0; tb56 <= 'd0; tb57 <= 'd0;
	tb60 <= 'd0; tb61 <= 'd0; tb62 <= 'd0; tb63 <= 'd0; tb64 <= 'd0; tb65 <= 'd0; tb66 <= 'd0; tb67 <= 'd0;
	tb70 <= 'd0; tb71 <= 'd0; tb72 <= 'd0; tb73 <= 'd0; tb74 <= 'd0; tb75 <= 'd0; tb76 <= 'd0; tb77 <= 'd0;
    end
    else if (flag & (valid_i | read_available)) begin
	tb00 <= ht_0; tb01 <= ht_1; tb02 <= ht_2; tb03 <= ht_3; tb04 <= ht_4; tb05 <= ht_5; tb06 <= ht_6; tb07 <= ht_7; 
	tb10 <= tb00; tb11 <= tb01; tb12 <= tb02; tb13 <= tb03; tb14 <= tb04; tb15 <= tb05; tb16 <= tb06; tb17 <= tb07; 
	tb20 <= tb10; tb21 <= tb11; tb22 <= tb12; tb23 <= tb13; tb24 <= tb14; tb25 <= tb15; tb26 <= tb16; tb27 <= tb17; 
	tb30 <= tb20; tb31 <= tb21; tb32 <= tb22; tb33 <= tb23; tb34 <= tb24; tb35 <= tb25; tb36 <= tb26; tb37 <= tb27; 
	tb40 <= tb30; tb41 <= tb31; tb42 <= tb32; tb43 <= tb33; tb44 <= tb34; tb45 <= tb35; tb46 <= tb36; tb47 <= tb37; 
	tb50 <= tb40; tb51 <= tb41; tb52 <= tb42; tb53 <= tb43; tb54 <= tb44; tb55 <= tb45; tb56 <= tb46; tb57 <= tb47; 
	tb60 <= tb50; tb61 <= tb51; tb62 <= tb52; tb63 <= tb53; tb64 <= tb54; tb65 <= tb55; tb66 <= tb56; tb67 <= tb57; 
	tb70 <= tb60; tb71 <= tb61; tb72 <= tb62; tb73 <= tb63; tb74 <= tb64; tb75 <= tb65; tb76 <= tb66; tb77 <= tb67; 
    end
    else if (~flag & (valid_i | read_available)) begin
	tb00 <= ht_0; tb10 <= ht_1; tb20 <= ht_2; tb30 <= ht_3; tb40 <= ht_4; tb50 <= ht_5; tb60 <= ht_6; tb70 <= ht_7;
	tb01 <= tb00; tb11 <= tb10; tb21 <= tb20; tb31 <= tb30; tb41 <= tb40; tb51 <= tb50; tb61 <= tb60; tb71 <= tb70;
	tb02 <= tb01; tb12 <= tb11; tb22 <= tb21; tb32 <= tb31; tb42 <= tb41; tb52 <= tb51; tb62 <= tb61; tb72 <= tb71;
	tb03 <= tb02; tb13 <= tb12; tb23 <= tb22; tb33 <= tb32; tb43 <= tb42; tb53 <= tb52; tb63 <= tb62; tb73 <= tb72;
	tb04 <= tb03; tb14 <= tb13; tb24 <= tb23; tb34 <= tb33; tb44 <= tb43; tb54 <= tb53; tb64 <= tb63; tb74 <= tb73;
	tb05 <= tb04; tb15 <= tb14; tb25 <= tb24; tb35 <= tb34; tb45 <= tb44; tb55 <= tb54; tb65 <= tb64; tb75 <= tb74;
	tb06 <= tb05; tb16 <= tb15; tb26 <= tb25; tb36 <= tb35; tb46 <= tb45; tb56 <= tb55; tb66 <= tb65; tb76 <= tb75;
	tb07 <= tb06; tb17 <= tb16; tb27 <= tb26; tb37 <= tb36; tb47 <= tb46; tb57 <= tb56; tb67 <= tb66; tb77 <= tb76;
    end
end

hadamard_trans_1d #( .DATA_WIDTH(HAD_1D_IN_WIDTH)
) ht_1d(
    .idata_0(diff0_i), 
    .idata_1(diff1_i), 
    .idata_2(diff2_i), 
    .idata_3(diff3_i), 
    .idata_4(diff4_i), 
    .idata_5(diff5_i), 
    .idata_6(diff6_i), 
    .idata_7(diff7_i),

    .odata_0(ht_0),
    .odata_1(ht_1),
    .odata_2(ht_2),
    .odata_3(ht_3),
    .odata_4(ht_4),
    .odata_5(ht_5),
    .odata_6(ht_6),
    .odata_7(ht_7)
);

assign ht_2d_0 = (flag) ?  tb70 : tb07 ;
assign ht_2d_1 = (flag) ?  tb71 : tb17 ;
assign ht_2d_2 = (flag) ?  tb72 : tb27 ;
assign ht_2d_3 = (flag) ?  tb73 : tb37 ;
assign ht_2d_4 = (flag) ?  tb74 : tb47 ;
assign ht_2d_5 = (flag) ?  tb75 : tb57 ;
assign ht_2d_6 = (flag) ?  tb76 : tb67 ;
assign ht_2d_7 = (flag) ?  tb77 : tb77 ;

hadamard_trans_1d #( .DATA_WIDTH(HAD_2D_IN_WIDTH) 
) ht_2d(
    .idata_0(ht_2d_0), 
    .idata_1(ht_2d_1), 
    .idata_2(ht_2d_2), 
    .idata_3(ht_2d_3), 
    .idata_4(ht_2d_4), 
    .idata_5(ht_2d_5), 
    .idata_6(ht_2d_6), 
    .idata_7(ht_2d_7),

    .odata_0(ht0_o),
    .odata_1(ht1_o),
    .odata_2(ht2_o),
    .odata_3(ht3_o),
    .odata_4(ht4_o),
    .odata_5(ht5_o),
    .odata_6(ht6_o),
    .odata_7(ht7_o)
);

assign htvalid_o = read_available;

endmodule


module fme_satd_8x8 (
    clk,
    rstn,

    cur_p0_i, cur_p1_i, cur_p2_i, cur_p3_i,
    cur_p4_i, cur_p5_i, cur_p6_i, cur_p7_i,

    sp0_i,    sp1_i,    sp2_i,    sp3_i,
    sp4_i,    sp5_i,    sp6_i,    sp7_i,
    sp_valid_i,

    satd_8x8_o,
    satd_8x8_valid_o
);

parameter       DIFF_WIDTH          = `PIXEL_WIDTH + 1               ; // difference operation, output is 1 bit more than input
parameter       HAD_1D_WIDTH        = `PIXEL_WIDTH + 1 + 3           ; // 8x8 hadamard transpose operation, output is 3 bit more than input
parameter       HAD_2D_WIDTH        = `PIXEL_WIDTH + 1 + 3 + 3       ; // 8x8 hadamard transpose operation, output is 3 bit more than input
parameter       ABS_WIDTH           = `PIXEL_WIDTH + 1 + 3 + 3 -1    ; // abs operation, output is 1 bit less than input
parameter       SATD_SUM_WIDTH      = `PIXEL_WIDTH + 1 + 3 + 3 -1 + 6; // 64 SATD values
parameter       SATD_WIDTH          = `PIXEL_WIDTH + 1 + 3 + 3 -1 + 6 - 2; // SATD values

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input                                 clk;
input                                 rstn;

input		[`PIXEL_WIDTH-1  : 0] cur_p0_i, cur_p1_i, cur_p2_i, cur_p3_i;
input		[`PIXEL_WIDTH-1  : 0] cur_p4_i, cur_p5_i, cur_p6_i, cur_p7_i;

input           [`PIXEL_WIDTH-1  : 0] sp0_i,    sp1_i,    sp2_i,    sp3_i;
input           [`PIXEL_WIDTH-1  : 0] sp4_i,    sp5_i,    sp6_i,    sp7_i;
input                                 sp_valid_i;

output          [SATD_WIDTH-1    : 0] satd_8x8_o;
output                                satd_8x8_valid_o;

// ********************************************
//                                             
//    WIRE / REG  DECLARATION                         
//                                             
// ********************************************

wire            [DIFF_WIDTH-1    : 0] diff0,diff1,diff2,diff3,diff4,diff5,diff6,diff7;
wire            [HAD_2D_WIDTH-1  : 0] ht0,ht1,ht2,ht3,ht4,ht5,ht6,ht7;
wire            [ABS_WIDTH-1     : 0] abs_ht0,abs_ht1,abs_ht2,abs_ht3,abs_ht4,abs_ht5,abs_ht6,abs_ht7;
wire                                  htvalid;


reg             [HAD_2D_WIDTH-1  : 0] ht0_r,ht1_r,ht2_r,ht3_r,ht4_r,ht5_r,ht6_r,ht7_r;
reg				      sum_satd_valid;

wire            [ABS_WIDTH       : 0] sum_satd00, sum_satd01, sum_satd02, sum_satd03;
wire            [ABS_WIDTH+1     : 0] sum_satd10, sum_satd11;
wire            [ABS_WIDTH+2     : 0] sum_satd_row;

reg             [SATD_SUM_WIDTH-1: 0] satd_8x8;
wire            [SATD_SUM_WIDTH-1: 0] satd_8x8_tmp;

reg		[2               : 0] cnt;
reg                                   satd_8x8_valid_o;

// ********************************************
//                                             
//    COMBINATIONAL LOGIC
//                                             
// ********************************************

assign          diff0 = {1'b0,cur_p0_i} - {1'b0,sp0_i};
assign          diff1 = {1'b0,cur_p1_i} - {1'b0,sp1_i};
assign          diff2 = {1'b0,cur_p2_i} - {1'b0,sp2_i};
assign          diff3 = {1'b0,cur_p3_i} - {1'b0,sp3_i};
assign          diff4 = {1'b0,cur_p4_i} - {1'b0,sp4_i};
assign          diff5 = {1'b0,cur_p5_i} - {1'b0,sp5_i};
assign          diff6 = {1'b0,cur_p6_i} - {1'b0,sp6_i};
assign          diff7 = {1'b0,cur_p7_i} - {1'b0,sp7_i};


assign          sum_satd00 = abs_ht0 + abs_ht1;
assign          sum_satd01 = abs_ht2 + abs_ht3;
assign          sum_satd02 = abs_ht4 + abs_ht5;
assign          sum_satd03 = abs_ht6 + abs_ht7;

assign          sum_satd10 = sum_satd00 + sum_satd01;
assign          sum_satd11 = sum_satd02 + sum_satd03;

assign          sum_satd_row = sum_satd10 + sum_satd11;  

assign          satd_8x8_tmp = satd_8x8 + 2;
assign          satd_8x8_o   = satd_8x8_tmp[SATD_SUM_WIDTH-1:2];
//assign          satd_8x8_valid_o = (cnt == 3'd7 &&  sum_satd_valid);


// ********************************************
//                                             
//    SEQUENTIAL LOGIC
//                                             
// ********************************************

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
        ht0_r <= 'd0;
	ht1_r <= 'd0;
	ht2_r <= 'd0;
	ht3_r <= 'd0;
	ht4_r <= 'd0;
	ht5_r <= 'd0;
	ht6_r <= 'd0;
	ht7_r <= 'd0;
	sum_satd_valid <= 1'b0;
    end
    else begin
	ht0_r <= ht0;
	ht1_r <= ht1;
	ht2_r <= ht2;
	ht3_r <= ht3;
	ht4_r <= ht4;
	ht5_r <= ht5;
	ht6_r <= ht6;
	ht7_r <= ht7;
	sum_satd_valid <= htvalid;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	cnt <= 'd0;
    end
    else if (sum_satd_valid) begin
	cnt <= cnt + 'd1;
    end
end


always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	satd_8x8 <= 'd0;
	satd_8x8_valid_o <= 1'b0;
    end
    else if (sum_satd_valid) begin
	satd_8x8 <= ((cnt == 'd0) ? ({SATD_SUM_WIDTH{1'b0}}) : (satd_8x8)) + {3'b0,sum_satd_row};
	satd_8x8_valid_o <= (cnt == 'd7);
    end
    else begin
	satd_8x8 <= satd_8x8;
	satd_8x8_valid_o <= 1'b0;
    end
end


// ********************************************
//                                             
//    Sub Module
//                                             
// ********************************************

hadamard_trans_2d #(
    .DATAIN_WIDTH(DIFF_WIDTH)
) hadamard (
    .clk      (clk ),
    .rstn     (rstn),

    .valid_i  (sp_valid_i),
    .diff0_i  (diff0  ),   .diff1_i(diff1),  .diff2_i(diff2),   .diff3_i(diff3),
    .diff4_i  (diff4  ),   .diff5_i(diff5),  .diff6_i(diff6),   .diff7_i(diff7),
    .htvalid_o(htvalid),
    .ht0_o    (ht0    ),   .ht1_o  (ht1  ),  .ht2_o  (ht2  ),   .ht3_o  (ht3  ),
    .ht4_o    (ht4    ),   .ht5_o  (ht5  ),  .ht6_o  (ht6  ),   .ht7_o  (ht7  )
);


fme_abs #(.INPUT_BITS(HAD_2D_WIDTH)) ht_abs0 (.a_i(ht0_r), .b_o(abs_ht0));
fme_abs #(.INPUT_BITS(HAD_2D_WIDTH)) ht_abs1 (.a_i(ht1_r), .b_o(abs_ht1));
fme_abs #(.INPUT_BITS(HAD_2D_WIDTH)) ht_abs2 (.a_i(ht2_r), .b_o(abs_ht2));
fme_abs #(.INPUT_BITS(HAD_2D_WIDTH)) ht_abs3 (.a_i(ht3_r), .b_o(abs_ht3));
fme_abs #(.INPUT_BITS(HAD_2D_WIDTH)) ht_abs4 (.a_i(ht4_r), .b_o(abs_ht4));
fme_abs #(.INPUT_BITS(HAD_2D_WIDTH)) ht_abs5 (.a_i(ht5_r), .b_o(abs_ht5));
fme_abs #(.INPUT_BITS(HAD_2D_WIDTH)) ht_abs6 (.a_i(ht6_r), .b_o(abs_ht6));
fme_abs #(.INPUT_BITS(HAD_2D_WIDTH)) ht_abs7 (.a_i(ht7_r), .b_o(abs_ht7));

endmodule
