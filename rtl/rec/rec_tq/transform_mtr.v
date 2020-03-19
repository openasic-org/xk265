//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.26
//file name     : transform_mtr.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module  transform_mtr(
                     clk        ,
                     rst_n      ,
                     i_valid    ,
                     i_transize ,//00:4x4 01:8x8 10:16x16 11:32x32
                     i_0        ,
                     i_1        ,
                     i_2        ,
                     i_3        ,
                     i_4        ,
                     i_5        ,
                     i_6        ,
                     i_7        ,
                     i_8        ,
                     i_9        ,
                     i_10       ,
                     i_11       ,
                     i_12       ,
                     i_13       ,
                     i_14       ,
                     i_15       ,
                     i_16       ,
                     i_17       ,
                     i_18       ,
                     i_19       ,
                     i_20       ,
                     i_21       ,
                     i_22       ,
                     i_23       ,
                     i_24       ,
                     i_25       ,
                     i_26       ,
                     i_27       ,
                     i_28       ,
                     i_29       ,
                     i_30       ,
                     i_31       ,
                     
                     o_valid    ,
                     o_0        , 
                     o_1        ,
                     o_2        ,
                     o_3        ,
		     o_4        , 
		     o_5        ,
		     o_6        ,
		     o_7        ,
		     o_8        , 
		     o_9        ,
		     o_10       ,
		     o_11       ,
		     o_12       ,
		     o_13       ,
		     o_14       ,
		     o_15       ,
		     o_16       ,
		     o_17       ,
		     o_18       ,
		     o_19       ,
		     o_20       ,
		     o_21       ,
		     o_22       ,
		     o_23       ,
		     o_24       ,
		     o_25       ,
		     o_26       ,
		     o_27       ,
		     o_28       ,
		     o_29       ,
		     o_30       ,
		     o_31       
);
                     
// ********************************************
//    INPUT / OUTPUT DECLARATION                                               
// ********************************************
input                  clk       ;
input                  rst_n     ;
input                  i_valid   ;
input [1:0]            i_transize;
input [15:0]           i_0       ;
input [15:0]           i_1       ;
input [15:0]           i_2       ;
input [15:0]           i_3       ;
input [15:0]           i_4       ;
input [15:0]           i_5       ;
input [15:0]           i_6       ;
input [15:0]           i_7       ;
input [15:0]           i_8       ;
input [15:0]           i_9       ;
input [15:0]           i_10      ;
input [15:0]           i_11      ;
input [15:0]           i_12      ;
input [15:0]           i_13      ;
input [15:0]           i_14      ;
input [15:0]           i_15      ;
input [15:0]           i_16      ;
input [15:0]           i_17      ;
input [15:0]           i_18      ;
input [15:0]           i_19      ;
input [15:0]           i_20      ;
input [15:0]           i_21      ;
input [15:0]           i_22      ;
input [15:0]           i_23      ;
input [15:0]           i_24      ;
input [15:0]           i_25      ;
input [15:0]           i_26      ;
input [15:0]           i_27      ;
input [15:0]           i_28      ;
input [15:0]           i_29      ;
input [15:0]           i_30      ;
input [15:0]           i_31      ;

output  reg            o_valid   ;
output  wire [15:0]    o_0       ; 
output  wire [15:0]    o_1       ;
output  wire [15:0]    o_2       ;
output  wire [15:0]    o_3       ;
output  wire [15:0]    o_4       ; 
output  wire [15:0]    o_5       ;
output  wire [15:0]    o_6       ;
output  wire [15:0]    o_7       ;
output  wire [15:0]    o_8       ; 
output  wire [15:0]    o_9       ;
output  wire [15:0]    o_10      ;
output  wire [15:0]    o_11      ;
output  wire [15:0]    o_12      ; 
output  wire [15:0]    o_13      ;
output  wire [15:0]    o_14      ;
output  wire [15:0]    o_15      ;
output  wire [15:0]    o_16      ; 
output  wire [15:0]    o_17      ;
output  wire [15:0]    o_18      ;
output  wire [15:0]    o_19      ;
output  wire [15:0]    o_20      ; 
output  wire [15:0]    o_21      ;
output  wire [15:0]    o_22      ;
output  wire [15:0]    o_23      ;
output  wire [15:0]    o_24      ; 
output  wire [15:0]    o_25      ;
output  wire [15:0]    o_26      ;
output  wire [15:0]    o_27      ;
output  wire [15:0]    o_28      ; 
output  wire [15:0]    o_29      ;
output  wire [15:0]    o_30      ;
output  wire [15:0]    o_31      ;

// ********************************************
//    Wire DECLARATION                         
// ********************************************
wire         [4:0]            badd_0 ;
wire         [4:0]            badd_1 ;
wire         [4:0]            badd_2 ;
wire         [4:0]            badd_3 ;
wire         [4:0]            badd_4 ;
wire         [4:0]            badd_5 ;
wire         [4:0]            badd_6 ;
wire         [4:0]            badd_7 ;
wire         [4:0]            badd_8 ;
wire         [4:0]            badd_9 ;
wire         [4:0]            badd_10;
wire         [4:0]            badd_11;
wire         [4:0]            badd_12;
wire         [4:0]            badd_13;
wire         [4:0]            badd_14;
wire         [4:0]            badd_15;
wire         [4:0]            badd_16;
wire         [4:0]            badd_17;
wire         [4:0]            badd_18;
wire         [4:0]            badd_19;
wire         [4:0]            badd_20;
wire         [4:0]            badd_21;
wire         [4:0]            badd_22;
wire         [4:0]            badd_23;
wire         [4:0]            badd_24;
wire         [4:0]            badd_25;
wire         [4:0]            badd_26;
wire         [4:0]            badd_27;
wire         [4:0]            badd_28;
wire         [4:0]            badd_29;
wire         [4:0]            badd_30;
wire         [4:0]            badd_31;
wire         [4:0]            add_0  ;
wire         [4:0]            add_1  ;
wire         [4:0]            add_2  ;
wire         [4:0]            add_3  ;
wire         [4:0]            add_4  ;
wire         [4:0]            add_5  ;
wire         [4:0]            add_6  ;
wire         [4:0]            add_7  ;
wire         [4:0]            add_8  ;
wire         [4:0]            add_9  ;
wire         [4:0]            add_10 ;
wire         [4:0]            add_11 ;
wire         [4:0]            add_12 ;
wire         [4:0]            add_13 ;
wire         [4:0]            add_14 ;
wire         [4:0]            add_15 ;
wire         [4:0]            add_16 ;
wire         [4:0]            add_17 ;
wire         [4:0]            add_18 ;
wire         [4:0]            add_19 ;
wire         [4:0]            add_20 ;
wire         [4:0]            add_21 ;
wire         [4:0]            add_22 ;
wire         [4:0]            add_23 ;
wire         [4:0]            add_24 ;
wire         [4:0]            add_25 ;
wire         [4:0]            add_26 ;
wire         [4:0]            add_27 ;
wire         [4:0]            add_28 ;
wire         [4:0]            add_29 ;
wire         [4:0]            add_30 ;
wire         [4:0]            add_31 ;
//----------------ram wr logic-------------------//
reg        rd_wr_ctl_d1  ; 
reg        rd_wr_ctl_d2  ; 
wire       rd_wr_ctl     ; 
reg [15:0] data_mux0_reg ;
reg [15:0] data_mux1_reg ;
reg [15:0] data_mux2_reg ;
reg [15:0] data_mux3_reg ;
reg [15:0] data_mux4_reg ;
reg [15:0] data_mux5_reg ;
reg [15:0] data_mux6_reg ;
reg [15:0] data_mux7_reg ;
reg [15:0] data_mux8_reg ;
reg [15:0] data_mux9_reg ;
reg [15:0] data_mux10_reg;
reg [15:0] data_mux11_reg;
reg [15:0] data_mux12_reg;
reg [15:0] data_mux13_reg;
reg [15:0] data_mux14_reg;
reg [15:0] data_mux15_reg;
reg [15:0] data_mux16_reg;
reg [15:0] data_mux17_reg;
reg [15:0] data_mux18_reg;
reg [15:0] data_mux19_reg;
reg [15:0] data_mux20_reg;
reg [15:0] data_mux21_reg;
reg [15:0] data_mux22_reg;
reg [15:0] data_mux23_reg;
reg [15:0] data_mux24_reg;
reg [15:0] data_mux25_reg;
reg [15:0] data_mux26_reg;
reg [15:0] data_mux27_reg;
reg [15:0] data_mux28_reg;
reg [15:0] data_mux29_reg;
reg [15:0] data_mux30_reg;
reg [15:0] data_mux31_reg;
//---ram addr---// wr addr or rd addr 
reg        valid_d1     ;
wire       ram_wr_en    ;
wire       ram_cs_n     ;
//wire       ram_rd_o_n   ;
//----------------data mux out--------------//
wire  [15:0] data_mux0 ;
wire  [15:0] data_mux1 ;
wire  [15:0] data_mux2 ;
wire  [15:0] data_mux3 ;
wire  [15:0] data_mux4 ;
wire  [15:0] data_mux5 ;
wire  [15:0] data_mux6 ;
wire  [15:0] data_mux7 ;
wire  [15:0] data_mux8 ;
wire  [15:0] data_mux9 ;
wire  [15:0] data_mux10;
wire  [15:0] data_mux11;
wire  [15:0] data_mux12;
wire  [15:0] data_mux13;
wire  [15:0] data_mux14;
wire  [15:0] data_mux15;
wire  [15:0] data_mux16;
wire  [15:0] data_mux17;
wire  [15:0] data_mux18;
wire  [15:0] data_mux19;
wire  [15:0] data_mux20;
wire  [15:0] data_mux21;
wire  [15:0] data_mux22;
wire  [15:0] data_mux23;
wire  [15:0] data_mux24;
wire  [15:0] data_mux25;
wire  [15:0] data_mux26;
wire  [15:0] data_mux27;
wire  [15:0] data_mux28;
wire  [15:0] data_mux29;
wire  [15:0] data_mux30;
wire  [15:0] data_mux31;
//---------data mux in-------------//
reg [15:0] data_0 ;
reg [15:0] data_1 ;
reg [15:0] data_2 ;
reg [15:0] data_3 ;
reg [15:0] data_4 ;
reg [15:0] data_5 ;
reg [15:0] data_6 ;
reg [15:0] data_7 ;
reg [15:0] data_8 ;
reg [15:0] data_9 ;
reg [15:0] data_10;
reg [15:0] data_11;
reg [15:0] data_12;
reg [15:0] data_13;
reg [15:0] data_14;
reg [15:0] data_15;
reg [15:0] data_16;
reg [15:0] data_17;
reg [15:0] data_18;
reg [15:0] data_19;
reg [15:0] data_20;
reg [15:0] data_21;
reg [15:0] data_22;
reg [15:0] data_23;
reg [15:0] data_24;
reg [15:0] data_25;
reg [15:0] data_26;
reg [15:0] data_27;
reg [15:0] data_28;
reg [15:0] data_29;
reg [15:0] data_30;
reg [15:0] data_31;
//-----------ram rd data---------------//
wire [15:0] ram_rddata_0;
wire [15:0] ram_rddata_1;
wire [15:0] ram_rddata_2;
wire [15:0] ram_rddata_3;
wire [15:0] ram_rddata_4;
wire [15:0] ram_rddata_5;
wire [15:0] ram_rddata_6;
wire [15:0] ram_rddata_7;
wire [15:0] ram_rddata_8;
wire [15:0] ram_rddata_9;
wire [15:0] ram_rddata_10;
wire [15:0] ram_rddata_11;
wire [15:0] ram_rddata_12;
wire [15:0] ram_rddata_13;
wire [15:0] ram_rddata_14;
wire [15:0] ram_rddata_15;
wire [15:0] ram_rddata_16;
wire [15:0] ram_rddata_17;
wire [15:0] ram_rddata_18;
wire [15:0] ram_rddata_19;
wire [15:0] ram_rddata_20;
wire [15:0] ram_rddata_21;
wire [15:0] ram_rddata_22;
wire [15:0] ram_rddata_23;
wire [15:0] ram_rddata_24;
wire [15:0] ram_rddata_25;
wire [15:0] ram_rddata_26;
wire [15:0] ram_rddata_27;
wire [15:0] ram_rddata_28;
wire [15:0] ram_rddata_29;
wire [15:0] ram_rddata_30;
wire [15:0] ram_rddata_31;
//----------ram wr data or ouput data ------------------//

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		rd_wr_ctl_d1 <= 1'b0;
	else
		rd_wr_ctl_d1 <= rd_wr_ctl;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		rd_wr_ctl_d2 <= 1'b0;
	else
		rd_wr_ctl_d2 <= rd_wr_ctl_d1;
end
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux0_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux0_reg <= data_mux0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux1_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux1_reg <= data_mux1;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux2_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux2_reg <= data_mux2;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux3_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux3_reg <= data_mux3;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux4_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux4_reg <= data_mux4;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux5_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux5_reg <= data_mux5;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux6_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux6_reg <= data_mux6;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux7_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux7_reg <= data_mux7;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux8_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux8_reg <= data_mux8;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux9_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux9_reg <= data_mux9;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux10_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux10_reg <= data_mux10;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux11_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux11_reg <= data_mux11;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux12_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux12_reg <= data_mux12;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux13_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux13_reg <= data_mux13;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux14_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux14_reg <= data_mux14;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux15_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux15_reg <= data_mux15;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux16_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux16_reg <= data_mux16;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux17_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux17_reg <= data_mux17;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux18_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux18_reg <= data_mux18;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux19_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux19_reg <= data_mux19;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux20_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux20_reg <= data_mux20;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux21_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux21_reg <= data_mux21;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux22_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux22_reg <= data_mux22;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux23_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux23_reg <= data_mux23;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux24_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux24_reg <= data_mux24;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux25_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux25_reg <= data_mux25;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux26_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux26_reg <= data_mux26;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux27_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux27_reg <= data_mux27;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux28_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux28_reg <= data_mux28;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux29_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux29_reg <= data_mux29;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux30_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux30_reg <= data_mux30;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_mux31_reg <= 16'd0;
	else if(i_valid || rd_wr_ctl_d1)
		data_mux31_reg <= data_mux31;
end

//---ram addr---// wr addr or rd addr 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		valid_d1 <= 1'b0;
	else
		valid_d1 <= i_valid;
end 

assign ram_wr_en   = ~valid_d1;
assign ram_cs_n   = (~valid_d1) && (~rd_wr_ctl);
//assign ram_rd_o_n = ~rd_wr_ctl_d1;

//---------------------------------------------------------------------//
always @(*)
begin
	if(i_valid)
		data_0 = i_0;
	else if(rd_wr_ctl_d1)
		data_0 = ram_rddata_0;
	else
		data_0 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_1 = i_1;
	else if(rd_wr_ctl_d1)
		data_1 = ram_rddata_1;
	else
		data_1 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_2 = i_2;
	else if(rd_wr_ctl_d1)
		data_2 = ram_rddata_2;
	else
		data_2 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_3 = i_3;
	else if(rd_wr_ctl_d1)
		data_3 = ram_rddata_3;
	else
		data_3 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_4 = i_4;
	else if(rd_wr_ctl_d1)
		data_4 = ram_rddata_4;
	else
		data_4 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_5 = i_5;
	else if(rd_wr_ctl_d1)
		data_5 = ram_rddata_5;
	else
		data_5 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_6 = i_6;
	else if(rd_wr_ctl_d1)
		data_6 = ram_rddata_6;
	else
		data_6 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_7 = i_7;
	else if(rd_wr_ctl_d1)
		data_7 = ram_rddata_7;
	else
		data_7 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_8 = i_8;
	else if(rd_wr_ctl_d1)
		data_8 = ram_rddata_8;
	else
		data_8 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_9 = i_9;
	else if(rd_wr_ctl_d1)
		data_9 = ram_rddata_9;
	else
		data_9 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_10 = i_10;
	else if(rd_wr_ctl_d1)
		data_10 = ram_rddata_10;
	else
		data_10 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_11 = i_11;
	else if(rd_wr_ctl_d1)
		data_11 = ram_rddata_11;
	else
		data_11 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_12 = i_12;
	else if(rd_wr_ctl_d1)
		data_12 = ram_rddata_12;
	else
		data_12 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_13 = i_13;
	else if(rd_wr_ctl_d1)
		data_13 = ram_rddata_13;
	else
		data_13 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_14 = i_14;
	else if(rd_wr_ctl_d1)
		data_14 = ram_rddata_14;
	else
		data_14 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_15 = i_15;
	else if(rd_wr_ctl_d1)
		data_15 = ram_rddata_15;
	else
		data_15 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_16 = i_16;
	else if(rd_wr_ctl_d1)
		data_16 = ram_rddata_16;
	else
		data_16 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_17 = i_17;
	else if(rd_wr_ctl_d1)
		data_17 = ram_rddata_17;
	else
		data_17 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_18 = i_18;
	else if(rd_wr_ctl_d1)
		data_18 = ram_rddata_18;
	else
		data_18 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_19 = i_19;
	else if(rd_wr_ctl_d1)
		data_19 = ram_rddata_19;
	else
		data_19 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_20 = i_20;
	else if(rd_wr_ctl_d1)
		data_20 = ram_rddata_20;
	else
		data_20 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_21 = i_21;
	else if(rd_wr_ctl_d1)
		data_21 = ram_rddata_21;
	else
		data_21 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_22 = i_22;
	else if(rd_wr_ctl_d1)
		data_22 = ram_rddata_22;
	else
		data_22 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_23 = i_23;
	else if(rd_wr_ctl_d1)
		data_23 = ram_rddata_23;
	else
		data_23 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_24 = i_24;
	else if(rd_wr_ctl_d1)
		data_24 = ram_rddata_24;
	else
		data_24 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_25 = i_25;
	else if(rd_wr_ctl_d1)
		data_25 = ram_rddata_25;
	else
		data_25 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_26 = i_26;
	else if(rd_wr_ctl_d1)
		data_26 = ram_rddata_26;
	else
		data_26 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_27 = i_27;
	else if(rd_wr_ctl_d1)
		data_27 = ram_rddata_27;
	else
		data_27 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_28 = i_28;
	else if(rd_wr_ctl_d1)
		data_28 = ram_rddata_28;
	else
		data_28 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_29 = i_29;
	else if(rd_wr_ctl_d1)
		data_29 = ram_rddata_29;
	else
		data_29 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_30 = i_30;
	else if(rd_wr_ctl_d1)
		data_30 = ram_rddata_30;
	else
		data_30 = 16'd0;
end

always @(*)
begin
	if(i_valid)
		data_31 = i_31;
	else if(rd_wr_ctl_d1)
		data_31 = ram_rddata_31;
	else
		data_31 = 16'd0;
end

//--------------addr ctl  data mux ctl logic---------------------//
//delay 0 clk
addr_ctl  u_addr_ctl(
       .clk         (clk       ),
       .rst_n       (rst_n     ),
       .i_valid     (i_valid   ),
       .i_transize  (i_transize),
//----data rd wr sel addr----//
       .o_rd_wr_ctl (rd_wr_ctl ),//0:wr :1 rd
       .o_badd_0    (badd_0    ),
       .o_badd_1    (badd_1    ),
       .o_badd_2    (badd_2    ),
       .o_badd_3    (badd_3    ),
       .o_badd_4    (badd_4    ),
       .o_badd_5    (badd_5    ),
       .o_badd_6    (badd_6    ),
       .o_badd_7    (badd_7    ),
       .o_badd_8    (badd_8    ),
       .o_badd_9    (badd_9    ),
       .o_badd_10   (badd_10   ),
       .o_badd_11   (badd_11   ),
       .o_badd_12   (badd_12   ),
       .o_badd_13   (badd_13   ),
       .o_badd_14   (badd_14   ),
       .o_badd_15   (badd_15   ),
       .o_badd_16   (badd_16   ),
       .o_badd_17   (badd_17   ),
       .o_badd_18   (badd_18   ),
       .o_badd_19   (badd_19   ),
       .o_badd_20   (badd_20   ),
       .o_badd_21   (badd_21   ),
       .o_badd_22   (badd_22   ),
       .o_badd_23   (badd_23   ),
       .o_badd_24   (badd_24   ),
       .o_badd_25   (badd_25   ),
       .o_badd_26   (badd_26   ),
       .o_badd_27   (badd_27   ),
       .o_badd_28   (badd_28   ),
       .o_badd_29   (badd_29   ),
       .o_badd_30   (badd_30   ),
       .o_badd_31   (badd_31   ),
//-----.ram wr rd addr---//
       .o_add_0     (add_0     ),
       .o_add_1     (add_1     ),
       .o_add_2     (add_2     ),
       .o_add_3     (add_3     ),
       .o_add_4     (add_4     ),
       .o_add_5     (add_5     ),
       .o_add_6     (add_6     ),
       .o_add_7     (add_7     ),
       .o_add_8     (add_8     ),
       .o_add_9     (add_9     ),
       .o_add_10    (add_10    ),
       .o_add_11    (add_11    ),
       .o_add_12    (add_12    ),
       .o_add_13    (add_13    ),
       .o_add_14    (add_14    ),
       .o_add_15    (add_15    ),
       .o_add_16    (add_16    ),
       .o_add_17    (add_17    ),
       .o_add_18    (add_18    ),
       .o_add_19    (add_19    ),
       .o_add_20    (add_20    ),
       .o_add_21    (add_21    ),
       .o_add_22    (add_22    ),
       .o_add_23    (add_23    ),
       .o_add_24    (add_24    ),
       .o_add_25    (add_25    ),
       .o_add_26    (add_26    ),
       .o_add_27    (add_27    ),
       .o_add_28    (add_28    ),
       .o_add_29    (add_29    ),
       .o_add_30    (add_30    ),
       .o_add_31    (add_31    )
);

//--------------------------data mux logic----------------------------------------//
mux32_1 u0_mux32_1(
          .i_addr   (badd_0    ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux0)
);

mux32_1 u1_mux32_1(
          .i_addr   (badd_1   ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux1)
);

mux32_1 u2_mux32_1(
          .i_addr   (badd_2   ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux2)
);

mux32_1 u3_mux32_1(
          .i_addr   (badd_3   ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux3)
);


mux32_1 u4_mux32_1(
          .i_addr   (badd_4   ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux4)
);

mux32_1 u5_mux32_1(
          .i_addr   (badd_5   ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux5)
);

mux32_1 u6_mux32_1(
          .i_addr   (badd_6   ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux6)
);

mux32_1 u7_mux32_1(
          .i_addr   (badd_7   ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux7)
);

mux32_1 u8_mux32_1(
          .i_addr   (badd_8   ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux8)
);
mux32_1 u9_mux32_1(
          .i_addr   (badd_9   ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux9)
);

mux32_1 u10_mux32_1(
          .i_addr   (badd_10  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux10)
);

mux32_1 u11_mux32_1(
          .i_addr   (badd_11  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux11)
);

mux32_1 u12_mux32_1(
          .i_addr   (badd_12  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux12)
);

mux32_1 u13_mux32_1(
          .i_addr   (badd_13  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux13)
);

mux32_1 u14_mux32_1(
          .i_addr   (badd_14  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux14)
);

mux32_1 u15_mux32_1(
          .i_addr   (badd_15  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux15)
);

mux32_1 u16_mux32_1(
          .i_addr   (badd_16  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux16)
);

mux32_1 u17_mux32_1(
          .i_addr   (badd_17  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux17)
);

mux32_1 u18_mux32_1(
          .i_addr   (badd_18  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux18)
);

mux32_1 u19_mux32_1(
          .i_addr   (badd_19  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux19)
);

mux32_1 u20_mux32_1(
          .i_addr   (badd_20  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux20)
);

mux32_1 u21_mux32_1(
          .i_addr   (badd_21  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux21)
);

mux32_1 u22_mux32_1(
          .i_addr   (badd_22  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux22)
);

mux32_1 u23_mux32_1(
          .i_addr   (badd_23  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux23)
);

mux32_1 u24_mux32_1(
          .i_addr   (badd_24  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux24)
);

mux32_1 u25_mux32_1(
          .i_addr   (badd_25  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux25)
);

mux32_1 u26_mux32_1(
          .i_addr   (badd_26  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux26)
);

mux32_1 u27_mux32_1(
          .i_addr   (badd_27  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux27)
);

mux32_1 u28_mux32_1(
          .i_addr   (badd_28  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux28)
);

mux32_1 u29_mux32_1(
          .i_addr   (badd_29  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux29)
);

mux32_1 u30_mux32_1(
          .i_addr   (badd_30  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux30)
);

mux32_1 u31_mux32_1(
          .i_addr   (badd_31  ),
          .i_0      (data_0   ),
          .i_1      (data_1   ),
          .i_2      (data_2   ),
          .i_3      (data_3   ),
          .i_4      (data_4   ),
          .i_5      (data_5   ),
          .i_6      (data_6   ),
          .i_7      (data_7   ),
          .i_8      (data_8   ),
          .i_9      (data_9   ),
          .i_10     (data_10  ),
          .i_11     (data_11  ),
          .i_12     (data_12  ),
          .i_13     (data_13  ),
          .i_14     (data_14  ),
          .i_15     (data_15  ),
          .i_16     (data_16  ),
          .i_17     (data_17  ),
          .i_18     (data_18  ),
          .i_19     (data_19  ),
          .i_20     (data_20  ),
          .i_21     (data_21  ),
          .i_22     (data_22  ),
          .i_23     (data_23  ),
          .i_24     (data_24  ),
          .i_25     (data_25  ),
          .i_26     (data_26  ),
          .i_27     (data_27  ),
          .i_28     (data_28  ),
          .i_29     (data_29  ),
          .i_30     (data_30  ),
          .i_31     (data_31  ),
          
          .o_dt     (data_mux31)
);
//-------------------------------------------------------------------------------------------------------------------------------------------------------------//
tq_ram_sp_32x16 u0_tq_ram_sp_32x16(.data_o(ram_rddata_0), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_0), .data_i(data_mux0_reg));
tq_ram_sp_32x16 u1_tq_ram_sp_32x16(.data_o(ram_rddata_1), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_1), .data_i(data_mux1_reg));
tq_ram_sp_32x16 u2_tq_ram_sp_32x16(.data_o(ram_rddata_2), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_2), .data_i(data_mux2_reg));
tq_ram_sp_32x16 u3_tq_ram_sp_32x16(.data_o(ram_rddata_3), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_3), .data_i(data_mux3_reg));
tq_ram_sp_32x16 u4_tq_ram_sp_32x16(.data_o(ram_rddata_4), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_4), .data_i(data_mux4_reg));
tq_ram_sp_32x16 u5_tq_ram_sp_32x16(.data_o(ram_rddata_5), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_5), .data_i(data_mux5_reg));
tq_ram_sp_32x16 u6_tq_ram_sp_32x16(.data_o(ram_rddata_6), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_6), .data_i(data_mux6_reg));
tq_ram_sp_32x16 u7_tq_ram_sp_32x16(.data_o(ram_rddata_7), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_7), .data_i(data_mux7_reg));
tq_ram_sp_32x16 u8_tq_ram_sp_32x16(.data_o(ram_rddata_8), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_8), .data_i(data_mux8_reg));
tq_ram_sp_32x16 u9_tq_ram_sp_32x16(.data_o(ram_rddata_9), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_9), .data_i(data_mux9_reg));

tq_ram_sp_32x16 u10_tq_ram_sp_32x16(.data_o(ram_rddata_10), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_10), .data_i(data_mux10_reg));
tq_ram_sp_32x16 u11_tq_ram_sp_32x16(.data_o(ram_rddata_11), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_11), .data_i(data_mux11_reg));
tq_ram_sp_32x16 u12_tq_ram_sp_32x16(.data_o(ram_rddata_12), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_12), .data_i(data_mux12_reg));
tq_ram_sp_32x16 u13_tq_ram_sp_32x16(.data_o(ram_rddata_13), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_13), .data_i(data_mux13_reg));
tq_ram_sp_32x16 u14_tq_ram_sp_32x16(.data_o(ram_rddata_14), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_14), .data_i(data_mux14_reg));
tq_ram_sp_32x16 u15_tq_ram_sp_32x16(.data_o(ram_rddata_15), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_15), .data_i(data_mux15_reg));
tq_ram_sp_32x16 u16_tq_ram_sp_32x16(.data_o(ram_rddata_16), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_16), .data_i(data_mux16_reg));
tq_ram_sp_32x16 u17_tq_ram_sp_32x16(.data_o(ram_rddata_17), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_17), .data_i(data_mux17_reg));
tq_ram_sp_32x16 u18_tq_ram_sp_32x16(.data_o(ram_rddata_18), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_18), .data_i(data_mux18_reg));
tq_ram_sp_32x16 u19_tq_ram_sp_32x16(.data_o(ram_rddata_19), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_19), .data_i(data_mux19_reg));

tq_ram_sp_32x16 u20_tq_ram_sp_32x16(.data_o(ram_rddata_20), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_20), .data_i(data_mux20_reg));
tq_ram_sp_32x16 u21_tq_ram_sp_32x16(.data_o(ram_rddata_21), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_21), .data_i(data_mux21_reg));
tq_ram_sp_32x16 u22_tq_ram_sp_32x16(.data_o(ram_rddata_22), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_22), .data_i(data_mux22_reg));
tq_ram_sp_32x16 u23_tq_ram_sp_32x16(.data_o(ram_rddata_23), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_23), .data_i(data_mux23_reg));
tq_ram_sp_32x16 u24_tq_ram_sp_32x16(.data_o(ram_rddata_24), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_24), .data_i(data_mux24_reg));
tq_ram_sp_32x16 u25_tq_ram_sp_32x16(.data_o(ram_rddata_25), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_25), .data_i(data_mux25_reg));
tq_ram_sp_32x16 u26_tq_ram_sp_32x16(.data_o(ram_rddata_26), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_26), .data_i(data_mux26_reg));
tq_ram_sp_32x16 u27_tq_ram_sp_32x16(.data_o(ram_rddata_27), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_27), .data_i(data_mux27_reg));
tq_ram_sp_32x16 u28_tq_ram_sp_32x16(.data_o(ram_rddata_28), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_28), .data_i(data_mux28_reg));
tq_ram_sp_32x16 u29_tq_ram_sp_32x16(.data_o(ram_rddata_29), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_29), .data_i(data_mux29_reg));

tq_ram_sp_32x16 u30_tq_ram_sp_32x16(.data_o(ram_rddata_30), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_30), .data_i(data_mux30_reg));
tq_ram_sp_32x16 u31_tq_ram_sp_32x16(.data_o(ram_rddata_31), .clk(clk), .cen_i(ram_cs_n), .wen_i(ram_wr_en), .addr_i(add_31), .data_i(data_mux31_reg));

/*
rfsphd_32x16   u0_rfsphd_32x16(.Q(ram_rddata_0), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_0), .D(data_mux0_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u1_rfsphd_32x16(.Q(ram_rddata_1), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_1), .D(data_mux1_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u2_rfsphd_32x16(.Q(ram_rddata_2), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_2), .D(data_mux2_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u3_rfsphd_32x16(.Q(ram_rddata_3), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_3), .D(data_mux3_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u4_rfsphd_32x16(.Q(ram_rddata_4), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_4), .D(data_mux4_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u5_rfsphd_32x16(.Q(ram_rddata_5), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_5), .D(data_mux5_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u6_rfsphd_32x16(.Q(ram_rddata_6), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_6), .D(data_mux6_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u7_rfsphd_32x16(.Q(ram_rddata_7), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_7), .D(data_mux7_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u8_rfsphd_32x16(.Q(ram_rddata_8), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_8), .D(data_mux8_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u9_rfsphd_32x16(.Q(ram_rddata_9), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_9), .D(data_mux9_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));

rfsphd_32x16   u10_rfsphd_32x16(.Q(ram_rddata_10), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_10), .D(data_mux10_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u11_rfsphd_32x16(.Q(ram_rddata_11), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_11), .D(data_mux11_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u12_rfsphd_32x16(.Q(ram_rddata_12), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_12), .D(data_mux12_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u13_rfsphd_32x16(.Q(ram_rddata_13), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_13), .D(data_mux13_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u14_rfsphd_32x16(.Q(ram_rddata_14), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_14), .D(data_mux14_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u15_rfsphd_32x16(.Q(ram_rddata_15), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_15), .D(data_mux15_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u16_rfsphd_32x16(.Q(ram_rddata_16), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_16), .D(data_mux16_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u17_rfsphd_32x16(.Q(ram_rddata_17), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_17), .D(data_mux17_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u18_rfsphd_32x16(.Q(ram_rddata_18), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_18), .D(data_mux18_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u19_rfsphd_32x16(.Q(ram_rddata_19), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_19), .D(data_mux19_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));

rfsphd_32x16   u20_rfsphd_32x16(.Q(ram_rddata_20), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_20), .D(data_mux20_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u21_rfsphd_32x16(.Q(ram_rddata_21), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_21), .D(data_mux21_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u22_rfsphd_32x16(.Q(ram_rddata_22), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_22), .D(data_mux22_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u23_rfsphd_32x16(.Q(ram_rddata_23), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_23), .D(data_mux23_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u24_rfsphd_32x16(.Q(ram_rddata_24), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_24), .D(data_mux24_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u25_rfsphd_32x16(.Q(ram_rddata_25), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_25), .D(data_mux25_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u26_rfsphd_32x16(.Q(ram_rddata_26), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_26), .D(data_mux26_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u27_rfsphd_32x16(.Q(ram_rddata_27), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_27), .D(data_mux27_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u28_rfsphd_32x16(.Q(ram_rddata_28), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_28), .D(data_mux28_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u29_rfsphd_32x16(.Q(ram_rddata_29), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_29), .D(data_mux29_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));

rfsphd_32x16   u30_rfsphd_32x16(.Q(ram_rddata_30), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_30), .D(data_mux30_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
rfsphd_32x16   u31_rfsphd_32x16(.Q(ram_rddata_31), .CLK(clk), .CEN(ram_cs_n), .WEN(ram_wr_en), .A(add_31), .D(data_mux31_reg), .EMA(3'b1), .EMAW(2'b0),.RET1N(1'b1));
*/
/*
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_0 (.data_o(ram_rddata_0 ),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_0 ),.data_i(data_mux0_reg ),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_1 (.data_o(ram_rddata_1 ),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_1 ),.data_i(data_mux1_reg ),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_2 (.data_o(ram_rddata_2 ),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_2 ),.data_i(data_mux2_reg ),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_3 (.data_o(ram_rddata_3 ),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_3 ),.data_i(data_mux3_reg ),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_4 (.data_o(ram_rddata_4 ),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_4 ),.data_i(data_mux4_reg ),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_5 (.data_o(ram_rddata_5 ),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_5 ),.data_i(data_mux5_reg ),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_6 (.data_o(ram_rddata_6 ),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_6 ),.data_i(data_mux6_reg ),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_7 (.data_o(ram_rddata_7 ),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_7 ),.data_i(data_mux7_reg ),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_8 (.data_o(ram_rddata_8 ),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_8 ),.data_i(data_mux8_reg ),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_9 (.data_o(ram_rddata_9 ),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_9 ),.data_i(data_mux9_reg ),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_10(.data_o(ram_rddata_10),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_10),.data_i(data_mux10_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_11(.data_o(ram_rddata_11),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_11),.data_i(data_mux11_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_12(.data_o(ram_rddata_12),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_12),.data_i(data_mux12_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_13(.data_o(ram_rddata_13),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_13),.data_i(data_mux13_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_14(.data_o(ram_rddata_14),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_14),.data_i(data_mux14_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_15(.data_o(ram_rddata_15),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_15),.data_i(data_mux15_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_16(.data_o(ram_rddata_16),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_16),.data_i(data_mux16_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_17(.data_o(ram_rddata_17),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_17),.data_i(data_mux17_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_18(.data_o(ram_rddata_18),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_18),.data_i(data_mux18_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_19(.data_o(ram_rddata_19),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_19),.data_i(data_mux19_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_20(.data_o(ram_rddata_20),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_20),.data_i(data_mux20_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_21(.data_o(ram_rddata_21),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_21),.data_i(data_mux21_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_22(.data_o(ram_rddata_22),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_22),.data_i(data_mux22_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_23(.data_o(ram_rddata_23),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_23),.data_i(data_mux23_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_24(.data_o(ram_rddata_24),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_24),.data_i(data_mux24_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_25(.data_o(ram_rddata_25),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_25),.data_i(data_mux25_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_26(.data_o(ram_rddata_26),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_26),.data_i(data_mux26_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_27(.data_o(ram_rddata_27),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_27),.data_i(data_mux27_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_28(.data_o(ram_rddata_28),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_28),.data_i(data_mux28_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_29(.data_o(ram_rddata_29),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_29),.data_i(data_mux29_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_30(.data_o(ram_rddata_30),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_30),.data_i(data_mux30_reg),.oen_i(ram_rd_o_n));
ram_1p  #(.Addr_Width(5), .Word_Width(16)) ram_1p_31(.data_o(ram_rddata_31),.clk(clk),.cen_i(ram_cs_n),.wen_i(ram_wr_n),.addr_i(add_31),.data_i(data_mux31_reg),.oen_i(ram_rd_o_n));
*/
//---------------------------output----------------------//


always @(*)
begin
        if(i_transize == 2'd0)
                o_valid = i_valid;
        else
                o_valid = rd_wr_ctl_d2;
end

assign  o_0   = (i_transize == 2'd0)? data_mux0 : data_mux0_reg     ;
assign  o_1   = (i_transize == 2'd0)? data_mux1 : data_mux1_reg     ;
assign  o_2   = (i_transize == 2'd0)? data_mux2 : data_mux2_reg     ;
assign  o_3   = (i_transize == 2'd0)? data_mux3 : data_mux3_reg     ;
assign  o_4   = (i_transize == 2'd0)? data_mux4 : data_mux4_reg     ;
assign  o_5   = (i_transize == 2'd0)? data_mux5 : data_mux5_reg     ;
assign  o_6   = (i_transize == 2'd0)? data_mux6 : data_mux6_reg     ;
assign  o_7   = (i_transize == 2'd0)? data_mux7 : data_mux7_reg     ;
assign  o_8   = (i_transize == 2'd0)? data_mux8 : data_mux8_reg     ;
assign  o_9   = (i_transize == 2'd0)? data_mux9 : data_mux9_reg     ;
assign o_10   = (i_transize == 2'd0)? data_mux10: data_mux10_reg    ;
assign o_11   = (i_transize == 2'd0)? data_mux11: data_mux11_reg    ;
assign o_12   = (i_transize == 2'd0)? data_mux12: data_mux12_reg    ;
assign o_13   = (i_transize == 2'd0)? data_mux13: data_mux13_reg    ;
assign o_14   = (i_transize == 2'd0)? data_mux14: data_mux14_reg    ;
assign o_15   = (i_transize == 2'd0)? data_mux15: data_mux15_reg    ;
assign o_16   = (i_transize == 2'd0)? data_mux16: data_mux16_reg    ;
assign o_17   = (i_transize == 2'd0)? data_mux17: data_mux17_reg    ;
assign o_18   = (i_transize == 2'd0)? data_mux18: data_mux18_reg    ;
assign o_19   = (i_transize == 2'd0)? data_mux19: data_mux19_reg    ;
assign o_20   = (i_transize == 2'd0)? data_mux20: data_mux20_reg    ;
assign o_21   = (i_transize == 2'd0)? data_mux21: data_mux21_reg    ;
assign o_22   = (i_transize == 2'd0)? data_mux22: data_mux22_reg    ;
assign o_23   = (i_transize == 2'd0)? data_mux23: data_mux23_reg    ;
assign o_24   = (i_transize == 2'd0)? data_mux24: data_mux24_reg    ;
assign o_25   = (i_transize == 2'd0)? data_mux25: data_mux25_reg    ;
assign o_26   = (i_transize == 2'd0)? data_mux26: data_mux26_reg    ;
assign o_27   = (i_transize == 2'd0)? data_mux27: data_mux27_reg    ;
assign o_28   = (i_transize == 2'd0)? data_mux28: data_mux28_reg    ;
assign o_29   = (i_transize == 2'd0)? data_mux29: data_mux29_reg    ;
assign o_30   = (i_transize == 2'd0)? data_mux30: data_mux30_reg    ;
assign o_31   = (i_transize == 2'd0)? data_mux31: data_mux31_reg    ;

endmodule
