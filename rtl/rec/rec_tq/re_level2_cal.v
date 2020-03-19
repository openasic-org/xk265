//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.15
//file name     : re_level2_cal.v
//delay         : 1 clk 
//describe      :
//modification  :
//v1.0          :

module re_level2_cal(
	clk            ,
	rst_n          ,
	i_dt_vld_32     ,//data valid
        i_dt_vld_16     ,
        i_dt_vld_8      ,
	i_data	       ,
//-------------r4----------//
	o_data_r4_89   ,  
        o_data_r4_75   ,
        o_data_r4_50   ,
        o_data_r4_18   ,
//-------------a4----------//
	o_data_a4_64   ,  
        o_data_a4_36   ,
        o_data_a4_83   
);

input   	clk            ;
input   	rst_n          ;
input [18:0]	i_data	       ;
input  	        i_dt_vld_32     ;
input           i_dt_vld_16     ;
input           i_dt_vld_8      ;

//-------------------dct32x32--------------//
output reg [26:0]     o_data_r4_89     ;
output reg [26:0]     o_data_r4_75     ; 
output reg [26:0]     o_data_r4_50     ; 
output reg [26:0]     o_data_r4_18     ; 
//-------------------dct16x16 dct8x8---------------//
output reg [26:0]     o_data_a4_64     ;
output reg [26:0]     o_data_a4_36     ; 
output reg [26:0]     o_data_a4_83     ; 
//------------------------------------------------//
wire [26:0]     data           ;
wire [26:0]     data_2         ;
wire [26:0]     data_4         ;
wire [26:0]     data_8         ;
wire [26:0]     data_64        ;
wire [26:0]     data_3         ;
wire [26:0]     data_5         ;
wire [26:0]     data_9         ;
wire [26:0]     data_48        ;
wire [26:0]     data_80        ;
wire [26:0]     data_10        ;
//-------------------dct32x32---------------//
wire [26:0]     data_r4_89     ;
wire [26:0]     data_r4_75     ; 
wire [26:0]     data_r4_50     ; 
wire [26:0]     data_r4_18     ; 
//-------------------dct16x16 dct8x8---------------//
wire [26:0]     data_a4_64     ;
wire [26:0]     data_a4_36     ; 
wire [26:0]     data_a4_83     ; 

//-------------------r4---------------//
//-------------------a4---------------//
reg  [26:0]     o_data_r4_64     ;
reg  [26:0]     o_data_r4_83     ; 
reg  [26:0]     o_data_r4_36     ; 
//----------------------------------------------------//
assign data    = {{8{i_data[17]}},i_data};
assign data_2  = {{7{i_data[17]}},i_data,1'b0};
assign data_4  = {{6{i_data[17]}},i_data,2'd0};
assign data_8  = {{5{i_data[17]}},i_data,3'd0};
assign data_64 = {{2{i_data[17]}},i_data,6'd0};

assign data_3  = data + data_2;
assign data_5  = data + data_4;  
assign data_9  = data_8 + data;
assign data_48 = {data_3[22:0],4'd0};
assign data_80 = {data_10[23:0],3'd0};
assign data_10 = {data_5[25:0],1'b0};

//-----------------r4-------------------//
assign data_r4_89 = data_80 + data_9;
assign data_r4_75 = {data_9[23:0],3'd0} + data_3;
assign data_r4_50 = data_48 + data_2;
assign data_r4_18 = {data_9[25:0],1'b0};

//------------------a4--------------------//
assign data_a4_64 = data_64;
assign data_a4_83 = data_80 + data_3;
assign data_a4_36 = {data_9[24:0],2'd0};

//-------------reg out---------------------//
//------------------------------------r4-------------------//

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r4_89 <= 27'd0;
	else if(i_dt_vld_32)
		o_data_r4_89 <= data_r4_89;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r4_75 <= 27'd0;
	else if(i_dt_vld_32)
		o_data_r4_75 <= data_r4_75;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r4_50 <= 27'd0;
	else if(i_dt_vld_32)
		o_data_r4_50 <= data_r4_50;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r4_18 <= 27'd0;
	else if(i_dt_vld_32)
		o_data_r4_18 <= data_r4_18;
end
//---------------------------------------a4---------------------------//
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_a4_64 <= 27'd0;
	else if(i_dt_vld_8 || i_dt_vld_16)
		o_data_a4_64 <= data_a4_64;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_a4_83 <= 27'd0;
	else if(i_dt_vld_8 || i_dt_vld_16)
		o_data_a4_83 <= data_a4_83;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_a4_36 <= 27'd0;
	else if(i_dt_vld_8 || i_dt_vld_16)
		o_data_a4_36 <= data_a4_36;
end 

endmodule  


