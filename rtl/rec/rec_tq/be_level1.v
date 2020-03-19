//company       : xm tech
//project name  : H265i
//top module    : dct_top_2d.v
//data          : 2018.01.17
//file name     : be_level1.v
//delay         : 1 clk 
//describe      :
//modification  :
//v1.0          :
module be_level1(
	clk         ,
	rst_n       ,
	i_dt_vld    ,
	i_inverse   ,
	i_transize  ,
	i_0         ,	
	i_1         ,	
	i_2         ,	
	i_3         ,	
	i_4         ,	
	i_5         ,	
	i_6         ,	
	i_7         ,	
	i_8         ,	
	i_9         ,	
	i_10        ,	
	i_11        ,	
	i_12        ,	
	i_13        ,	
	i_14        ,	
	i_15        ,	
	i_16        ,	
	i_17        ,	
	i_18        ,	
	i_19        ,	
	i_20        ,	
	i_21        ,	
	i_22        ,	
	i_23        ,	
	i_24        ,	
	i_25        ,	
	i_26        ,	
	i_27        ,	
	i_28        ,	
	i_29        ,	
	i_30        ,	
	i_31        ,
//------------------------	
	o_0         ,	
	o_1         ,	
	o_2         ,	
	o_3         ,	
	o_4         ,	
	o_5         ,	
	o_6         ,	
	o_7         ,	
	o_8         ,	
	o_9         ,	
	o_10        ,	
	o_11        ,	
	o_12        ,	
	o_13        ,	
	o_14        ,	
	o_15        ,	
	o_16        ,	
	o_17        ,	
	o_18        ,	
	o_19        ,	
	o_20        ,	
	o_21        ,	
	o_22        ,	
	o_23        ,	
	o_24        ,	
	o_25        ,	
	o_26        ,	
	o_27        ,
	o_28        ,	
	o_29        ,	
	o_30        ,	
	o_31        	
);

input   	clk         ;
input   	rst_n       ;
input           i_dt_vld    ;
input           i_inverse   ;
input [1:0]  	i_transize  ;
input [27:0]	i_0         ;	
input [27:0]	i_1         ;	
input [27:0]	i_2         ;	
input [27:0]	i_3         ;	
input [27:0]	i_4         ;	
input [27:0]	i_5         ;	
input [27:0]	i_6         ;	
input [27:0]	i_7         ;	
input [27:0]	i_8         ;	
input [27:0]	i_9         ;	
input [27:0]	i_10        ;	
input [27:0]	i_11        ;	
input [27:0]	i_12        ;	
input [27:0]	i_13        ;	
input [27:0]	i_14        ;	
input [27:0]	i_15        ;	
input [27:0]	i_16        ;	
input [27:0]	i_17        ;	
input [27:0]	i_18        ;	
input [27:0]	i_19        ;	
input [27:0]	i_20        ;	
input [27:0]	i_21        ;	
input [27:0]	i_22        ;	
input [27:0]	i_23        ;	
input [27:0]	i_24        ;	
input [27:0]	i_25        ;	
input [27:0]	i_26        ;	
input [27:0]	i_27        ;	
input [27:0]	i_28        ;	
input [27:0]	i_29        ;	
input [27:0]	i_30        ;	
input [27:0]	i_31        ;
	
//--------
output [27:0]	o_0         ;	
output [27:0]	o_1         ;	
output [27:0]	o_2         ;	
output [27:0]	o_3         ;	
output [27:0]	o_4         ;	
output [27:0]	o_5         ;	
output [27:0]	o_6         ;	
output [27:0]	o_7         ;	
output [27:0]	o_8         ;	
output [27:0]	o_9         ;	
output [27:0]	o_10        ;	
output [27:0]	o_11        ;	
output [27:0]	o_12        ;	
output [27:0]	o_13        ;	
output [27:0]	o_14        ;	
output [27:0]	o_15        ;	
output [27:0]	o_16        ;	
output [27:0]	o_17        ;	
output [27:0]	o_18        ;	
output [27:0]	o_19        ;	
output [27:0]	o_20        ;	
output [27:0]	o_21        ;	
output [27:0]	o_22        ;	
output [27:0]	o_23        ;	
output [27:0]	o_24        ;	
output [27:0]	o_25        ;	
output [27:0]	o_26        ;	
output [27:0]	o_27        ;
output [27:0]	o_28        ;	
output [27:0]	o_29        ;	
output [27:0]	o_30        ;	
output [27:0]	o_31        ;	
//------------------------reg-----------------//
reg     [27:0]	o_0         ;	
reg     [27:0]	o_1         ;	
reg     [27:0]	o_2         ;	
reg     [27:0]	o_3         ;	
reg     [27:0]	o_4         ;	
reg     [27:0]	o_5         ;	
reg     [27:0]	o_6         ;	
reg     [27:0]	o_7         ;	
reg     [27:0]	o_8         ;	
reg     [27:0]	o_9         ;	
reg     [27:0]	o_10        ;	
reg     [27:0]	o_11        ;	
reg     [27:0]	o_12        ;	
reg     [27:0]	o_13        ;	
reg     [27:0]	o_14        ;	
reg     [27:0]	o_15        ;	
reg     [27:0]	o_16        ;	
reg     [27:0]	o_17        ;	
reg     [27:0]	o_18        ;	
reg     [27:0]	o_19        ;	
reg     [27:0]	o_20        ;	
reg     [27:0]	o_21        ;	
reg     [27:0]	o_22        ;	
reg     [27:0]	o_23        ;	
reg     [27:0]	o_24        ;	
reg     [27:0]	o_25        ;	
reg     [27:0]	o_26        ;	
reg     [27:0]	o_27        ;
reg     [27:0]	o_28        ;	
reg     [27:0]	o_29        ;	
reg     [27:0]	o_30        ;	
reg     [27:0]	o_31        ;	
//--------------------------------------//
reg     [27:0]  data0_add0  ;   
reg     [27:0]  data1_add0  ;
reg     [27:0]  data2_add0  ;
reg     [27:0]  data3_add0  ;
reg     [27:0]  data4_add0  ;
reg     [27:0]  data5_add0  ;
reg     [27:0]  data6_add0  ;
reg     [27:0]  data7_add0  ;

reg     [27:0]  data0_add1  ;   
reg     [27:0]  data1_add1  ;
reg     [27:0]  data2_add1  ;
reg     [27:0]  data3_add1  ;
reg     [27:0]  data4_add1  ;
reg     [27:0]  data5_add1  ;
reg     [27:0]  data6_add1  ;
reg     [27:0]  data7_add1  ;

reg     [27:0]  data0_sub0  ;   
reg     [27:0]  data1_sub0  ;
reg     [27:0]  data2_sub0  ;
reg     [27:0]  data3_sub0  ;
reg     [27:0]  data4_sub0  ;
reg     [27:0]  data5_sub0  ;
reg     [27:0]  data6_sub0  ;
reg     [27:0]  data7_sub0  ;

reg     [27:0]  data0_sub1  ;   
reg     [27:0]  data1_sub1  ;
reg     [27:0]  data2_sub1  ;
reg     [27:0]  data3_sub1  ;
reg     [27:0]  data4_sub1  ;
reg     [27:0]  data5_sub1  ;
reg     [27:0]  data6_sub1  ;
reg     [27:0]  data7_sub1  ;
//------------------------------------//
wire    [27:0]  sum0        ;       
wire    [27:0]  sum1        ;
wire    [27:0]  sum2        ;
wire    [27:0]  sum3        ;
wire    [27:0]  sum4        ;
wire    [27:0]  sum5        ;
wire    [27:0]  sum6        ;
wire    [27:0]  sum7        ;

wire    [27:0]  sub0        ;
wire    [27:0]  sub1        ;
wire    [27:0]  sub2        ;
wire    [27:0]  sub3        ;
wire    [27:0]  sub4        ;
wire    [27:0]  sub5        ;
wire    [27:0]  sub6        ;
wire    [27:0]  sub7        ;
//------------------------------add---------------------//
always @(*)
begin
	   if(i_transize == 2'd3) //dct32x32/idct32x32:b16
	   begin
	   	data0_add0  = i_0;
	   	data1_add0  = i_1;
	   	data2_add0  = i_2;
	   	data3_add0  = i_3;
	   	data4_add0  = i_4;
	   	data5_add0  = i_5;
	   	data6_add0  = i_6;
	   	data7_add0  = i_7;
	   end
	   else if(i_transize == 2'd2)//dct16x16/idct16x16:b8 b8 
	   begin
	   	data0_add0  = i_0;
	   	data1_add0  = i_1;
	   	data2_add0  = i_2;
	   	data3_add0  = i_3;
	   	data4_add0  = i_16;
	   	data5_add0  = i_17;
	   	data6_add0  = i_18;
	   	data7_add0  = i_19;
	   end 	
	  else
	  begin
	  	data0_add0  = 28'd0;
	  	data1_add0  = 28'd0;
		data2_add0  = 28'd0;
  		data3_add0  = 28'd0;
	  	data4_add0  = 28'd0;
	  	data5_add0  = 28'd0;
	  	data6_add0  = 28'd0;
	  	data7_add0  = 28'd0;
	  end
end 

always @(*)
begin
        if(i_transize == 2'd3)//dct32x32/idct32x32:b16
        begin
        	data0_add1  = i_15;
        	data1_add1  = i_14;
        	data2_add1  = i_13;
        	data3_add1  = i_12;
        	data4_add1  = i_11;
        	data5_add1  = i_10;
        	data6_add1  = i_9 ;
        	data7_add1  = i_8 ;
        end
        else if(i_transize == 2'd2)//dct32x32/idct32x32:b8b8
        begin
        	data0_add1  = i_7;
        	data1_add1  = i_6;
        	data2_add1  = i_5;
        	data3_add1  = i_4;
        	data4_add1  = i_23;
        	data5_add1  = i_22;
        	data6_add1  = i_21;
        	data7_add1  = i_20;
        end
	else
	begin
	        data0_add1  = 28'd0;
	        data1_add1  = 28'd0;
	        data2_add1  = 28'd0;
	        data3_add1  = 28'd0;
	        data4_add1  = 28'd0;
	        data5_add1  = 28'd0;
	        data6_add1  = 28'd0;
	        data7_add1  = 28'd0;
	end
end 
//--------------------------------sub----------------------------//
always @(*)
begin
	if(i_transize == 2'd3)
	begin
		data0_sub0  = i_7;
		data1_sub0  = i_6;
		data2_sub0  = i_5;
		data3_sub0  = i_4;
		data4_sub0  = i_3;
		data5_sub0  = i_2;
		data6_sub0  = i_1;
		data7_sub0  = i_0;
	end
	else if(i_transize == 2'd2) 
	begin
		data0_sub0  = i_3;
		data1_sub0  = i_2;
		data2_sub0  = i_1;
		data3_sub0  = i_0;
		data4_sub0  = i_19;
		data5_sub0  = i_18;
		data6_sub0  = i_17;
		data7_sub0  = i_16;
	end 	
	else
	begin
		data0_sub0  =28'd0 ;
		data1_sub0  =28'd0 ;
		data2_sub0  =28'd0 ;
		data3_sub0  =28'd0 ;
		data4_sub0  =28'd0 ;
		data5_sub0  =28'd0 ;
		data6_sub0  =28'd0 ;
		data7_sub0  =28'd0 ;
	end
end 

always @(*)
begin
	if(i_transize == 2'd3)//dct32x32 idct32x32:b16
	begin
		data0_sub1  = i_8;
		data1_sub1  = i_9;
		data2_sub1  = i_10;
		data3_sub1  = i_11;
		data4_sub1  = i_12;
		data5_sub1  = i_13;
		data6_sub1  = i_14;
		data7_sub1  = i_15;
	end
	else if(i_transize == 2'd2)//dct16x16 idct16x16:b8 b8
	begin
		data0_sub1  = i_4;
		data1_sub1  = i_5;
		data2_sub1  = i_6;
		data3_sub1  = i_7;
		data4_sub1  = i_20;
		data5_sub1  = i_21;
		data6_sub1  = i_22;
		data7_sub1  = i_23;
	end
	else
	begin
		data0_sub1  = 28'd0;
	        data1_sub1  = 28'd0;
	        data2_sub1  = 28'd0;
	        data3_sub1  = 28'd0;
	        data4_sub1  = 28'd0;
	        data5_sub1  = 28'd0;
	        data6_sub1  = 28'd0;
	        data7_sub1  = 28'd0;
	end
end 

assign sum0 = data0_add0  + data0_add1 ; 
assign sum1 = data1_add0  + data1_add1 ; 
assign sum2 = data2_add0  + data2_add1 ; 
assign sum3 = data3_add0  + data3_add1 ; 
assign sum4 = data4_add0  + data4_add1 ; 
assign sum5 = data5_add0  + data5_add1 ; 
assign sum6 = data6_add0  + data6_add1 ; 
assign sum7 = data7_add0  + data7_add1 ; 

assign sub0 = data0_sub0  - data0_sub1 ; 
assign sub1 = data1_sub0  - data1_sub1 ; 
assign sub2 = data2_sub0  - data2_sub1 ; 
assign sub3 = data3_sub0  - data3_sub1 ; 
assign sub4 = data4_sub0  - data4_sub1 ; 
assign sub5 = data5_sub0  - data5_sub1 ; 
assign sub6 = data6_sub0  - data6_sub1 ; 
assign sub7 = data7_sub0  - data7_sub1 ; 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		o_0  <= 28'd0 ;
	        o_1  <= 28'd0 ;       
                o_2  <= 28'd0 ;
                o_3  <= 28'd0 ;
                o_4  <= 28'd0 ;
                o_5  <= 28'd0 ;
                o_6  <= 28'd0 ;
                o_7  <= 28'd0 ;
                o_8  <= 28'd0 ;
                o_9  <= 28'd0 ;
                o_10 <= 28'd0 ;
                o_11 <= 28'd0 ;
                o_12 <= 28'd0 ;
                o_13 <= 28'd0 ;
                o_14 <= 28'd0 ;
                o_15 <= 28'd0 ;
                o_16 <= 28'd0 ;
		o_16 <= 28'd0 ;
	        o_17 <= 28'd0 ;       
                o_18 <= 28'd0 ;
                o_19 <= 28'd0 ;
                o_20 <= 28'd0 ;
                o_21 <= 28'd0 ;
                o_22 <= 28'd0 ;
                o_23 <= 28'd0 ;
                o_24 <= 28'd0 ;
                o_25 <= 28'd0 ;
                o_26 <= 28'd0 ;
                o_27 <= 28'd0 ;
                o_28 <= 28'd0 ;
                o_29 <= 28'd0 ;
                o_30 <= 28'd0 ;
                o_31 <= 28'd0 ;
	end
	else if(i_dt_vld)
	begin
		if(i_transize == 2'd3)
		begin
			o_0  <=  sum0 ;
		        o_1  <=  sum1 ;       
        	        o_2  <=  sum2 ;
        	        o_3  <=  sum3 ;
        	        o_4  <=  sum4 ;
        	        o_5  <=  sum5 ;
        	        o_6  <=  sum6 ;
        	        o_7  <=  sum7 ;
        	        o_8  <=  sub0 ;
        	        o_9  <=  sub1 ;
        	        o_10 <=  sub2 ;
        	        o_11 <=  sub3 ;
        	        o_12 <=  sub4 ;
        	        o_13 <=  sub5 ;
        	        o_14 <=  sub6 ;
        	        o_15 <=  sub7 ;
			o_16 <=  i_16;
		        o_17 <=  i_17;       
        	        o_18 <=  i_18;
        	        o_19 <=  i_19;
        	        o_20 <=  i_20;
        	        o_21 <=  i_21;
        	        o_22 <=  i_22;
        	        o_23 <=  i_23;
        	        o_24 <=  i_24;
        	        o_25 <=  i_25;
        	        o_26 <=  i_26;
        	        o_27 <=  i_27;
        	        o_28 <=  i_28;
        	        o_29 <=  i_29;
        	        o_30 <=  i_30;
        	        o_31 <=  i_31;
		end
		else if(i_transize == 2'd2)
		begin
			o_0  <=  sum0 ;
		        o_1  <=  sum1 ;       
        	        o_2  <=  sum2 ;
        	        o_3  <=  sum3 ;
        	        o_4  <=  sub0 ;
        	        o_5  <=  sub1 ;
        	        o_6  <=  sub2 ;
        	        o_7  <=  sub3 ;
        	        o_8  <=  i_8  ;
        	        o_9  <=  i_9  ;
        	        o_10 <=  i_10 ;
        	        o_11 <=  i_11 ;
        	        o_12 <=  i_12 ;
        	        o_13 <=  i_13 ;
        	        o_14 <=  i_14 ;
        	        o_15 <=  i_15 ;
			o_16 <=  sum4;
		        o_17 <=  sum5;       
        	        o_18 <=  sum6;
        	        o_19 <=  sum7;
        	        o_20 <=  sub4;
        	        o_21 <=  sub5;
        	        o_22 <=  sub6;
        	        o_23 <=  sub7;
        	        o_24 <=  i_24;
        	        o_25 <=  i_25;
        	        o_26 <=  i_26;
        	        o_27 <=  i_27;
        	        o_28 <=  i_28;
        	        o_29 <=  i_29;
        	        o_30 <=  i_30;
        	        o_31 <=  i_31;
		end
		else
		begin
			o_0  <=  i_0 ;
		        o_1  <=  i_1 ;       
        	        o_2  <=  i_2 ;
        	        o_3  <=  i_3 ;
        	        o_4  <=  i_4 ;
        	        o_5  <=  i_5 ;
        	        o_6  <=  i_6 ;
        	        o_7  <=  i_7 ;
        	        o_8  <=  i_8 ;
        	        o_9  <=  i_9 ;
        	        o_10 <=  i_10;
        	        o_11 <=  i_11;
        	        o_12 <=  i_12;
        	        o_13 <=  i_13;
        	        o_14 <=  i_14;
        	        o_15 <=  i_15;
			o_16 <=  i_16;
		        o_17 <=  i_17;       
        	        o_18 <=  i_18;
        	        o_19 <=  i_19;
        	        o_20 <=  i_20;
        	        o_21 <=  i_21;
        	        o_22 <=  i_22;
        	        o_23 <=  i_23;
        	        o_24 <=  i_24;
        	        o_25 <=  i_25;
        	        o_26 <=  i_26;
        	        o_27 <=  i_27;
        	        o_28 <=  i_28;
        	        o_29 <=  i_29;
        	        o_30 <=  i_30;
        	        o_31 <=  i_31;
		end
	end
end
 

endmodule 

