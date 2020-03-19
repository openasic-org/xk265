//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.13
//file name     : re_level1.v
//delay         : 1 clk 
//describe      :
//modification  :
//v1.0          :

module re_level1_cal(
	clk            ,
	rst_n          ,
	i_dt_vld_32     ,//data valid
        i_dt_vld_16     ,
        i_dt_vld_8      ,
	i_data	       ,
//-------------r8---------//
	o_data_r8_9    ,    
        o_data_r8_25   ,
        o_data_r8_43   ,
        o_data_r8_57   ,
        o_data_r8_70   ,
        o_data_r8_80   ,
        o_data_r8_87   ,
        o_data_r8_90   ,
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
input [17:0]	i_data	       ;
input  	        i_dt_vld_32     ;
input           i_dt_vld_16     ;
input           i_dt_vld_8      ;

//-------------------dct32x32--------------//
output  [25:0]     o_data_r8_9      ;      
output  [25:0]     o_data_r8_25     ;
output  [25:0]     o_data_r8_43     ;
output  [25:0]     o_data_r8_57     ;
output  [25:0]     o_data_r8_70     ;
output  [25:0]     o_data_r8_80     ;
output  [25:0]     o_data_r8_87     ;
output  [25:0]     o_data_r8_90     ;
//-------------------dct16x16---------------//
output  [25:0]     o_data_r4_89     ;
output  [25:0]     o_data_r4_75     ; 
output  [25:0]     o_data_r4_50     ; 
output  [25:0]     o_data_r4_18     ; 
//------------------dst_8x8------------------//
output  [25:0]     o_data_a4_64     ;
output  [25:0]     o_data_a4_36     ; 
output  [25:0]     o_data_a4_83     ; 
//------------------------------------------------//
wire [25:0]     data           ;
wire [25:0]     data_2         ;
wire [25:0]     data_4         ;
wire [25:0]     data_8         ;
wire [25:0]     data_16        ;
wire [25:0]     data_32        ;
wire [25:0]     data_64        ;
wire [25:0]     data_3         ;
wire [25:0]     data_5         ;
wire [25:0]     data_9         ;
wire [25:0]     data_6         ;
wire [25:0]     data_11        ;
wire [25:0]     data_48        ;
wire [25:0]     data_80        ;
wire [25:0]     data_10        ;
//-------------------dct32x32--------------//
wire [25:0]     data_r8_9      ;      
wire [25:0]     data_r8_25     ;
wire [25:0]     data_r8_43     ;
wire [25:0]     data_r8_57     ;
wire [25:0]     data_r8_70     ;
wire [25:0]     data_r8_80     ;
wire [25:0]     data_r8_87     ;
wire [25:0]     data_r8_90     ;
//-------------------dct16x16---------------//
wire [25:0]     data_r4_89     ;
wire [25:0]     data_r4_75     ; 
wire [25:0]     data_r4_50     ; 
wire [25:0]     data_r4_18     ; 
//-------------------dct8x8---------------//
wire [25:0]     data_a4_64     ;
wire [25:0]     data_a4_36     ; 
wire [25:0]     data_a4_83     ; 

//-------------------r8--------------//
reg  [25:0]     o_data_r8_9      ;      
reg  [25:0]     o_data_r8_25     ;
reg  [25:0]     o_data_r8_43     ;
reg  [25:0]     o_data_r8_57     ;
reg  [25:0]     o_data_r8_70     ;
reg  [25:0]     o_data_r8_80     ;
reg  [25:0]     o_data_r8_87     ;
reg  [25:0]     o_data_r8_90     ;
//-------------------r4---------------//
reg  [25:0]     o_data_r4_89     ;
reg  [25:0]     o_data_r4_75     ; 
reg  [25:0]     o_data_r4_50     ; 
reg  [25:0]     o_data_r4_18     ; 
//-------------------a4---------------//
reg  [25:0]     o_data_a4_64     ;
reg  [25:0]     o_data_a4_83     ; 
reg  [25:0]     o_data_a4_36     ; 
//----------------------------------------------------//
assign data    = {{8{i_data[17]}},i_data};
assign data_2  = {{7{i_data[17]}},i_data,1'b0};
assign data_4  = {{6{i_data[17]}},i_data,2'd0};
assign data_8  = {{5{i_data[17]}},i_data,3'd0};
assign data_16 = {{4{i_data[17]}},i_data,4'd0};
assign data_32 = {{3{i_data[17]}},i_data,5'd0};
assign data_64 = {{2{i_data[17]}},i_data,6'd0};

assign data_3  = data + data_2;
assign data_5  = data + data_4;  
assign data_9  = data_8 + data;
assign data_6  = {data_3[24:0],1'b0};
assign data_11 = data_16 - data_5;
assign data_48 = {data_6[22:0],3'd0};
assign data_80 = {data_10[22:0],3'd0};
assign data_10 = {data_5[24:0],1'b0};

//-----------------r8-------------------//
assign data_r8_9  = data_9;
assign data_r8_25 = data_16 + data_9;
assign data_r8_43 = data_32 + data_11;
assign data_r8_57 = data_48 + data_9;
assign data_r8_70 = data_64 + data_6;
assign data_r8_80 = data_80;
assign data_r8_87 = {data_r8_43[24:0],1'b0} + data;
assign data_r8_90 = data_80 + data_10;
//-----------------r4-------------------//
assign data_r4_89 = data_80 + data_9;
assign data_r4_75 = data_64 + data_11;
assign data_r4_50 = {data_r8_25[24:0],1'b0};
assign data_r4_18 = {data_9[24:0],1'b0};

//------------------a4--------------------//
assign data_a4_64 = data_64;
assign data_a4_83 = data_80 + data_3;
assign data_a4_36 = {data_9[23:0],2'd0};

//-------------reg out---------------------//
//---------------------------r8--------------------//
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_9 <= 26'd0;
	else if(i_dt_vld_32)
		o_data_r8_9 <= data_r8_9;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_25 <= 26'd0;
	else if(i_dt_vld_32)
		o_data_r8_25 <= data_r8_25;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_43 <= 26'd0;
	else if(i_dt_vld_32)
		o_data_r8_43 <= data_r8_43;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_57 <= 26'd0;
	else if(i_dt_vld_32)
		o_data_r8_57 <= data_r8_57;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_70 <= 26'd0;
	else if(i_dt_vld_32)
		o_data_r8_70 <= data_r8_70;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_80 <= 26'd0;
	else if(i_dt_vld_32)
		o_data_r8_80 <= data_r8_80;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_87 <= 26'd0;
	else if(i_dt_vld_32)
		o_data_r8_87 <= data_r8_87;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_90 <= 26'd0;
	else if(i_dt_vld_32)
		o_data_r8_90 <= data_r8_90;
end
//------------------------------------r4-------------------//

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r4_89 <= 26'd0;
	else if(i_dt_vld_16)
		o_data_r4_89 <= data_r4_89;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r4_75 <= 26'd0;
	else if(i_dt_vld_16)
		o_data_r4_75 <= data_r4_75;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r4_50 <= 26'd0;
	else if(i_dt_vld_16)
		o_data_r4_50 <= data_r4_50;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r4_18 <= 26'd0;
	else if(i_dt_vld_16)
		o_data_r4_18 <= data_r4_18;
end
//---------------------------------------a4---------------------------//
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_a4_64 <= 26'd0;
	else if(i_dt_vld_8)
		o_data_a4_64 <= data_a4_64;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_a4_83 <= 26'd0;
	else if(i_dt_vld_8)
		o_data_a4_83 <= data_a4_83;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_a4_36 <= 26'd0;
	else if(i_dt_vld_8)
		o_data_a4_36 <= data_a4_36;
end 


endmodule  

