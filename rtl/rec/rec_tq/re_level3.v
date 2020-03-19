//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.15
//file name     : re_level3.v
//delay         : 1 clk 
//describe      :
//modification  :
//v1.0          :

module re_level3(
	clk            ,
	rst_n          ,
	i_inverse      ,
	i_dt_vld_32    ,//data valid
        i_dt_vld_16    ,
        i_dt_vld_8     ,
	i_data0	       ,
	i_data1	       ,
	i_data2	       ,
	i_data3	       ,
//-------------a4----------//
	o_data0     ,  
        o_data1     ,
        o_data2     , 
        o_data3   
);

input   	clk            ;
input   	rst_n          ;
input           i_inverse      ;
input [18:0]	i_data0	       ;
input [18:0]    i_data1        ;
input [18:0]    i_data2        ;
input [18:0]    i_data3        ;
input  	        i_dt_vld_32     ;
input           i_dt_vld_16     ;
input           i_dt_vld_8      ;

//---------------dct32x32 dct16x16 dct8x8---------------//
output  [27:0]     o_data0     ;
output  [27:0]     o_data1     ; 
output  [27:0]     o_data2     ;
output  [27:0]     o_data3     ; 
//---------------------row0--------------------------//
reg                dt_vld8_d1  ;
wire [26:0]        data0_64    ;               
wire [26:0]        data0_2     ;
wire [26:0]        data0_16    ;
wire [26:0]        data0       ;
wire [26:0]        data0_83    ;
wire [26:0]        data0_4     ;
wire [26:0]        data0_32    ;
wire [26:0]        data0_36    ;
wire [26:0]        data1_64    ;
wire [26:0]        data1_16    ;
wire [26:0]        data1_2     ;
wire [26:0]        data1       ;
wire [26:0]        data1_83    ;
wire [26:0]        data1_32    ;
wire [26:0]        data1_4     ;
wire [26:0]        data1_36    ;
wire [26:0]        data2_64    ;
wire [26:0]        data2_16    ;
wire [26:0]        data2_2     ;
wire [26:0]        data2       ;
wire [26:0]        data2_83    ;
wire [26:0]        data2_32    ;
wire [26:0]        data2_4     ;
wire [26:0]        data2_36    ;
wire [26:0]        data3_64    ;
wire [26:0]        data3_16    ;
wire [26:0]        data3_2     ;
wire [26:0]        data3       ;
wire [26:0]        data3_83    ;
wire [26:0]        data3_32    ;
wire [26:0]        data3_4     ;
wire [26:0]        data3_36    ;
//---------------------------//
reg  [26:0]        data0_64_d1 ;
reg  [26:0]        data0_83_d1 ;
reg  [26:0]        data0_36_d1 ;

reg  [26:0]        data1_64_d1 ;
reg  [26:0]        data1_83_d1 ;
reg  [26:0]        data1_36_d1 ;

reg  [26:0]        data2_64_d1 ;
reg  [26:0]        data2_83_d1 ;
reg  [26:0]        data2_36_d1 ;

reg  [26:0]        data3_64_d1 ;
reg  [26:0]        data3_83_d1 ;
reg  [26:0]        data3_36_d1 ;

//--------------------------row0----------------------//
wire [26:0]     data0_row0      ;
wire [26:0]     data1_row0      ; 
wire [26:0]     data2_row0      ;
wire [26:0]     data3_row0      ;
wire [27:0]     data_row0_stp0  ;
wire [27:0]     data_row0_stp1  ;
wire [27:0]     data_row0       ;
reg  [27:0]     data_row0_d1    ;
reg  [27:0]     o_data0         ;
//--------------------------row1----------------------//

wire [26:0]     data0_row1      ;
wire [26:0]     data1_row1      ; 
wire [26:0]     data2_row1      ;
wire [26:0]     data3_row1      ;
wire [27:0]     data_row1_stp0  ;
wire [27:0]     data_row1_stp1  ;
wire [27:0]     data_row1       ;
reg  [27:0]     data_row1_d1    ;
reg  [27:0]     o_data1         ;
//--------------------------row2----------------------//

wire [26:0]     data0_row2      ;
wire [26:0]     data1_row2      ; 
wire [26:0]     data2_row2      ;
wire [26:0]     data3_row2      ;
wire [27:0]     data_row2_stp0  ;
wire [27:0]     data_row2_stp1  ;
wire [27:0]     data_row2       ;
reg  [27:0]     data_row2_d1    ;
reg  [27:0]     o_data2         ;
//--------------------------row3------------------------//

wire [26:0]     data0_row3      ;
wire [26:0]     data1_row3      ; 
wire [26:0]     data2_row3      ;
wire [26:0]     data3_row3      ;
wire [27:0]     data_row3_stp0  ;
wire [27:0]     data_row3_stp1  ;
wire [27:0]     data_row3       ;
reg  [27:0]     data_row3_d1    ;
reg  [27:0]     o_data3         ;

//---------------------------------------------------//
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		dt_vld8_d1 <= 1'b0;
	else
		dt_vld8_d1 <= i_dt_vld_8;
end 

//data0
assign data0_64 = {{2{i_data0[18]}},i_data0,6'd0};

assign data0_2  = {{7{i_data0[18]}},i_data0,1'd0};
assign data0_16 = {{4{i_data0[18]}},i_data0,4'd0};
assign data0    = {{8{i_data0[18]}},i_data0};
assign data0_83 = data0_64 + data0_16 + data0_2 + data0;

assign data0_4  = {{6{i_data0[18]}},i_data0,2'd0};
assign data0_32 = {{3{i_data0[18]}},i_data0,5'd0};
assign data0_36 = data0_32 + data0_4;

//data1
assign data1_64 = {{2{i_data1[18]}},i_data1,6'd0};

assign data1_16 = {{4{i_data1[18]}},i_data1,4'd0};
assign data1_2  = {{7{i_data1[18]}},i_data1,1'd0};
assign data1    = {{8{i_data1[18]}},i_data1};
assign data1_83 = data1_64 + data1_16 + data1_2 + data1;

assign data1_32 = {{3{i_data1[18]}},i_data1,5'd0};
assign data1_4  = {{6{i_data1[18]}},i_data1,2'd0};
assign data1_36 = data1_32 + data1_4;
//data2
assign data2_64 = {{2{i_data2[18]}},i_data2,6'd0};

assign data2_16 = {{4{i_data2[18]}},i_data2,4'd0};
assign data2_2  = {{7{i_data2[18]}},i_data2,1'd0};
assign data2    = {{8{i_data2[18]}},i_data2};
assign data2_83 = data2_64 + data2_16 + data2_2 + data2;

assign data2_32 = {{3{i_data2[18]}},i_data2,5'd0};
assign data2_4  = {{6{i_data2[18]}},i_data2,2'd0};
assign data2_36 = data2_32 + data2_4;

//data3
assign data3_64 = {{2{i_data3[18]}},i_data3,6'd0};

assign data3_16 = {{4{i_data3[18]}},i_data3,4'd0};
assign data3_2  = {{7{i_data3[18]}},i_data3,1'd0};
assign data3    = {{8{i_data3[18]}},i_data3};
assign data3_83 = data3_64 + data3_16 + data3_2 + data3;

assign data3_32 = {{3{i_data3[18]}},i_data3,5'd0};
assign data3_4  = {{6{i_data3[18]}},i_data3,2'd0};
assign data3_36 = data3_32 + data3_4;

//---------delay---------//
//data0
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data0_64_d1 <= 27'd0;
	else if(i_dt_vld_32 || i_dt_vld_16 || i_dt_vld_8)
		data0_64_d1 <= data0_64;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data0_83_d1 <= 27'd0;
	else if(i_dt_vld_32 || i_dt_vld_16 || i_dt_vld_8)
		data0_83_d1 <= data0_83;

end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data0_36_d1 <= 27'd0;
	else if(i_dt_vld_32 || i_dt_vld_16 || i_dt_vld_8)
		data0_36_d1 <= data0_36;
end
//data1

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data1_64_d1 <= 27'd0;
	else if(i_dt_vld_32 || i_dt_vld_16 || i_dt_vld_8)
		data1_64_d1 <= data1_64;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data1_83_d1 <= 27'd0;
	else if(i_dt_vld_32 || i_dt_vld_16 || i_dt_vld_8)
		data1_83_d1 <= data1_83;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data1_36_d1 <= 27'd0;
	else if(i_dt_vld_32 || i_dt_vld_16 || i_dt_vld_8)
		data1_36_d1 <= data1_36;
end
//data2

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data2_64_d1 <= 27'd0;
	else if(i_dt_vld_32 || i_dt_vld_16 || i_dt_vld_8)
		data2_64_d1 <= data2_64;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data2_36_d1 <= 27'd0;
	else if(i_dt_vld_32 || i_dt_vld_16 || i_dt_vld_8)
		data2_36_d1 <= data2_36;

end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data2_83_d1 <= 27'd0;
	else if(i_dt_vld_32 || i_dt_vld_16 || i_dt_vld_8)
		data2_83_d1 <= data2_83;

end
//data3
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data3_64_d1 <= 27'd0;
	else if(i_dt_vld_32 || i_dt_vld_16 || i_dt_vld_8)
		data3_64_d1 <= data3_64;

end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data3_36_d1 <= 27'd0;
	else if(i_dt_vld_32 || i_dt_vld_16 || i_dt_vld_8)
		data3_36_d1 <= data3_36;

end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data3_83_d1 <= 27'd0;
	else if(i_dt_vld_32 || i_dt_vld_16 || i_dt_vld_8)
		data3_83_d1 <= data3_83;
end
//---------------------------row0---------------------------//

assign data0_row0 = data0_64_d1;
assign data1_row0 = i_inverse? data1_83_d1 : data1_64_d1;
assign data2_row0 = data2_64_d1;
assign data3_row0 = i_inverse? data3_36_d1 : data3_64_d1;

assign data_row0_stp0 = {data0_row0[26],data0_row0} + {data1_row0[26],data1_row0};
assign data_row0_stp1 = {data2_row0[26],data2_row0} + {data3_row0[26],data3_row0};
assign data_row0      = data_row0_stp0 + data_row0_stp1;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_row0_d1 <= 28'd0;
	else
		data_row0_d1 <= data_row0;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data0 <= 28'd0;
	else if(dt_vld8_d1)
		o_data0 <= data_row0;
	else
		o_data0 <= data_row0_d1;	
end 		

//---------------------------row1-----------------------------//
assign data0_row1 = i_inverse? data0_64_d1 : data0_83_d1;
assign data1_row1 = data1_36_d1;
assign data2_row1 = i_inverse? (~data2_64_d1 + 1'b1) :(~data2_36_d1 + 1'b1);
assign data3_row1 = ~data3_83_d1 + 1'b1;

assign data_row1_stp0 = {data0_row1[26],data0_row1} + {data1_row1[26],data1_row1};
assign data_row1_stp1 = {data2_row1[26],data2_row1} + {data3_row1[26],data3_row1};
assign data_row1      = data_row1_stp0 + data_row1_stp1;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_row1_d1 <= 28'd0;
	else
		data_row1_d1 <= data_row1;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data1 <= 28'd0;
	else if(dt_vld8_d1)
		o_data1 <= data_row1;
	else
		o_data1 <= data_row1_d1;	
end 		

//---------------------------row2-----------------------------//

assign data0_row2 = data0_64_d1;
assign data1_row2 = i_inverse? (~data1_36_d1 +1'b1) : (~data1_64_d1 + 1'b1);
assign data2_row2 = ~data2_64_d1 + 1'b1;
assign data3_row2 = i_inverse? data3_83_d1: data3_64_d1;

assign data_row2_stp0 = {data0_row2[26],data0_row2} + {data1_row2[26],data1_row2};
assign data_row2_stp1 = {data2_row2[26],data2_row2} + {data3_row2[26],data3_row2};
assign data_row2      = data_row2_stp0 + data_row2_stp1;
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_row2_d1 <= 28'd0;
	else
		data_row2_d1 <= data_row2;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data2 <= 28'd0;
	else if(dt_vld8_d1)
		o_data2 <= data_row2;
	else
		o_data2 <= data_row2_d1;	
end 		

//---------------------------row3-----------------------------//

assign data0_row3 = i_inverse ? data0_64_d1 : data0_36_d1;
assign data1_row3 = ~data1_83_d1 + 1'b1;
assign data2_row3 = i_inverse ? data2_64_d1 : data2_83_d1;
assign data3_row3 = ~data3_36_d1 + 1'b1;

assign data_row3_stp0 = {data0_row3[26],data0_row3} + {data1_row3[26],data1_row3};
assign data_row3_stp1 = {data2_row3[26],data2_row3} + {data3_row3[26],data3_row3};
assign data_row3      = data_row3_stp0 + data_row3_stp1;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_row3_d1 <= 28'd0;
	else
		data_row3_d1 <= data_row3;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data3 <= 28'd0;
	else if(dt_vld8_d1)
		o_data3 <= data_row3;
	else
		o_data3 <= data_row3_d1;	
end 		


endmodule  

