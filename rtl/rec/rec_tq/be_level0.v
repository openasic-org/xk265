//company       : xm tech
//project name  : H265i
//top module    : dct_top_2d.v
//data          : 2018.01.17
//file name     : be_level0.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module be_level0(
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
reg     [27:0]  data8_add0  ;
reg     [27:0]  data9_add0  ;
reg     [27:0]  data10_add0 ;
reg     [27:0]  data11_add0 ;
reg     [27:0]  data12_add0 ;
reg     [27:0]  data13_add0 ;
reg     [27:0]  data14_add0 ;
reg     [27:0]  data15_add0 ;

reg     [27:0]  data0_sub1  ;   
reg     [27:0]  data1_sub1  ;
reg     [27:0]  data2_sub1  ;
reg     [27:0]  data3_sub1  ;
reg     [27:0]  data4_sub1  ;
reg     [27:0]  data5_sub1  ;
reg     [27:0]  data6_sub1  ;
reg     [27:0]  data7_sub1  ;
reg     [27:0]  data8_sub1  ;
reg     [27:0]  data9_sub1  ;
reg     [27:0]  data10_sub1 ;
reg     [27:0]  data11_sub1 ;
reg     [27:0]  data12_sub1 ;
reg     [27:0]  data13_sub1 ;
reg     [27:0]  data14_sub1 ;
reg     [27:0]  data15_sub1 ;

reg     [27:0]  data0_add1  ;   
reg     [27:0]  data1_add1  ;
reg     [27:0]  data2_add1  ;
reg     [27:0]  data3_add1  ;
reg     [27:0]  data4_add1  ;
reg     [27:0]  data5_add1  ;
reg     [27:0]  data6_add1  ;
reg     [27:0]  data7_add1  ;
reg     [27:0]  data8_add1  ;
reg     [27:0]  data9_add1  ;
reg     [27:0]  data10_add1 ;
reg     [27:0]  data11_add1 ;
reg     [27:0]  data12_add1 ;
reg     [27:0]  data13_add1 ;
reg     [27:0]  data14_add1 ;
reg     [27:0]  data15_add1 ;

reg     [27:0]  data0_sub0  ;   
reg     [27:0]  data1_sub0  ;
reg     [27:0]  data2_sub0  ;
reg     [27:0]  data3_sub0  ;
reg     [27:0]  data4_sub0  ;
reg     [27:0]  data5_sub0  ;
reg     [27:0]  data6_sub0  ;
reg     [27:0]  data7_sub0  ;
reg     [27:0]  data8_sub0  ;
reg     [27:0]  data9_sub0  ;
reg     [27:0]  data10_sub0 ;
reg     [27:0]  data11_sub0 ;
reg     [27:0]  data12_sub0 ;
reg     [27:0]  data13_sub0 ;
reg     [27:0]  data14_sub0 ;
reg     [27:0]  data15_sub0 ;
//------------------------------------//
wire    [27:0]  sum0        ;       
wire    [27:0]  sum1        ;
wire    [27:0]  sum2        ;
wire    [27:0]  sum3        ;
wire    [27:0]  sum4        ;
wire    [27:0]  sum5        ;
wire    [27:0]  sum6        ;
wire    [27:0]  sum7        ;
wire    [27:0]  sum8        ;
wire    [27:0]  sum9        ;
wire    [27:0]  sum10       ;
wire    [27:0]  sum11       ;
wire    [27:0]  sum12       ;
wire    [27:0]  sum13       ;
wire    [27:0]  sum14       ;
wire    [27:0]  sum15       ;

wire    [27:0]  sub0        ;
wire    [27:0]  sub1        ;
wire    [27:0]  sub2        ;
wire    [27:0]  sub3        ;
wire    [27:0]  sub4        ;
wire    [27:0]  sub5        ;
wire    [27:0]  sub6        ;
wire    [27:0]  sub7        ;
wire    [27:0]  sub8        ;
wire    [27:0]  sub9        ;
wire    [27:0]  sub10       ;
wire    [27:0]  sub11       ;
wire    [27:0]  sub12       ;
wire    [27:0]  sub13       ;
wire    [27:0]  sub14       ;
wire    [27:0]  sub15       ;

//------------------------------add---------------------//
always @(*)
begin
	if(~i_inverse)
	begin
		if(i_transize == 2'd3)
		begin
			data0_add0  = i_0;
			data1_add0  = i_1;
			data2_add0  = i_2;
			data3_add0  = i_3;
			data4_add0  = i_4;
			data5_add0  = i_5;
			data6_add0  = i_6;
			data7_add0  = i_7;
			data8_add0  = i_8;
			data9_add0  = i_9;
			data10_add0 = i_10;
			data11_add0 = i_11;
			data12_add0 = i_12;
			data13_add0 = i_13;
			data14_add0 = i_14;
			data15_add0 = i_15;
		end 
		else if(i_transize == 2'd2)
		begin
			data0_add0  = i_0;
			data1_add0  = i_1;
			data2_add0  = i_2;
			data3_add0  = i_3;
			data4_add0  = i_4;
			data5_add0  = i_5;
			data6_add0  = i_6;
			data7_add0  = i_7;
			data8_add0  = i_16;
			data9_add0  = i_17;
			data10_add0 = i_18;
			data11_add0 = i_19;
			data12_add0 = i_20;
			data13_add0 = i_21;
			data14_add0 = i_22;
			data15_add0 = i_23;
		end
		else 
		begin
			data0_add0  = i_0;
			data1_add0  = i_1;
			data2_add0  = i_2;
			data3_add0  = i_3;
			data4_add0  = i_8;
			data5_add0  = i_9;
			data6_add0  = i_10;
			data7_add0  = i_11;
			data8_add0  = i_16;
			data9_add0  = i_17;
			data10_add0 = i_18;
			data11_add0 = i_19;
			data12_add0 = i_24;
			data13_add0 = i_25;
			data14_add0 = i_26;
			data15_add0 = i_27;
		end 	
	end
	else
	begin
			data0_add0  = i_0;
			data1_add0  = i_1;
			data2_add0  = i_2;
			data3_add0  = i_3;
			data4_add0  = 28'd0;
			data5_add0  = 28'd0;
			data6_add0  = 28'd0;
			data7_add0  = 28'd0;
			data8_add0  = 28'd0;
			data9_add0  = 28'd0;
			data10_add0 = 28'd0;
			data11_add0 = 28'd0;
			data12_add0 = 28'd0;
			data13_add0 = 28'd0;
			data14_add0 = 28'd0;
			data15_add0 = 28'd0;
	end
end 

always @(*)
begin
	if(~i_inverse)
	begin
		if(i_transize == 2'd3)
		begin
			data0_add1  = i_31;
			data1_add1  = i_30;
			data2_add1  = i_29;
			data3_add1  = i_28;
			data4_add1  = i_27;
			data5_add1  = i_26;
			data6_add1  = i_25;
			data7_add1  = i_24;
			data8_add1  = i_23;
			data9_add1  = i_22;
			data10_add1 = i_21;
			data11_add1 = i_20;
			data12_add1 = i_19;
			data13_add1 = i_18;
			data14_add1 = i_17;
			data15_add1 = i_16;
		end 
		else if(i_transize == 2'd2)
		begin
			data0_add1  = i_15;
			data1_add1  = i_14;
			data2_add1  = i_13;
			data3_add1  = i_12;
			data4_add1  = i_11;
			data5_add1  = i_10;
			data6_add1  = i_9 ;
			data7_add1  = i_8 ;
			data8_add1  = i_31;
			data9_add1  = i_30;
			data10_add1 = i_29;
			data11_add1 = i_28;
			data12_add1 = i_27;
			data13_add1 = i_26;
			data14_add1 = i_25;
			data15_add1 = i_24;
		end
		else
		begin
			data0_add1  = i_7;
			data1_add1  = i_6;
			data2_add1  = i_5;
			data3_add1  = i_4;
			data4_add1  = i_15;
			data5_add1  = i_14;
			data6_add1  = i_13;
			data7_add1  = i_12;
			data8_add1  = i_23;
			data9_add1  = i_22;
			data10_add1 = i_21;
			data11_add1 = i_20;
			data12_add1 = i_31;
			data13_add1 = i_30;
			data14_add1 = i_29;
			data15_add1 = i_28;
		end
	end
	else
	begin
			data0_add1  = i_7;
			data1_add1  = i_6;
			data2_add1  = i_5;
			data3_add1  = i_4;
			data4_add1  = 28'd0;
			data5_add1  = 28'd0;
			data6_add1  = 28'd0;
			data7_add1  = 28'd0;
			data8_add1  = 28'd0;
			data9_add1  = 28'd0;
			data10_add1 = 28'd0;
			data11_add1 = 28'd0;
			data12_add1 = 28'd0;
			data13_add1 = 28'd0;
			data14_add1 = 28'd0;
			data15_add1 = 28'd0;
	end
end 
//--------------------------------sub----------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
		if(i_transize == 2'd3)
		begin
			data0_sub0  = i_15;
			data1_sub0  = i_14;
			data2_sub0  = i_13;
			data3_sub0  = i_12;
			data4_sub0  = i_11;
			data5_sub0  = i_10;
			data6_sub0  = i_9;
			data7_sub0  = i_8;
			data8_sub0  = i_7;
			data9_sub0  = i_6;
			data10_sub0 = i_5;
			data11_sub0 = i_4;
			data12_sub0 = i_3;
			data13_sub0 = i_2;
			data14_sub0 = i_1;
			data15_sub0 = i_0;
		end 
		else if(i_transize == 2'd2)
		begin
			data0_sub0  = i_7;
			data1_sub0  = i_6;
			data2_sub0  = i_5;
			data3_sub0  = i_4;
			data4_sub0  = i_3;
			data5_sub0  = i_2;
			data6_sub0  = i_1;
			data7_sub0  = i_0;
			data8_sub0  = i_23;
			data9_sub0  = i_22;
			data10_sub0 = i_21;
			data11_sub0 = i_20;
			data12_sub0 = i_19;
			data13_sub0 = i_18;
			data14_sub0 = i_17;
			data15_sub0 = i_16;
		end
		else 
		begin
			data0_sub0  = i_3;
			data1_sub0  = i_2;
			data2_sub0  = i_1;
			data3_sub0  = i_0;
			data4_sub0  = i_11;
			data5_sub0  = i_10;
			data6_sub0  = i_9;
			data7_sub0  = i_8;
			data8_sub0  = i_19;
			data9_sub0  = i_18;
			data10_sub0 = i_17;
			data11_sub0 = i_16;
			data12_sub0 = i_27;
			data13_sub0 = i_26;
			data14_sub0 = i_25;
			data15_sub0 = i_24;
		end 	
	end
	else
	begin
			data0_sub0  = i_3;
			data1_sub0  = i_2;
			data2_sub0  = i_1;
			data3_sub0  = i_0;
			data4_sub0  = 28'd0;
			data5_sub0  = 28'd0;
			data6_sub0  = 28'd0;
			data7_sub0  = 28'd0;
			data8_sub0  = 28'd0;
			data9_sub0  = 28'd0;
			data10_sub0 = 28'd0;
			data11_sub0 = 28'd0;
			data12_sub0 = 28'd0;
			data13_sub0 = 28'd0;
			data14_sub0 = 28'd0;
			data15_sub0 = 28'd0;
	end
end 

always @(*)
begin
	if(~i_inverse)
	begin
		if(i_transize == 2'd3)
		begin
			data0_sub1  = i_16;
			data1_sub1  = i_17;
			data2_sub1  = i_18;
			data3_sub1  = i_19;
			data4_sub1  = i_20;
			data5_sub1  = i_21;
			data6_sub1  = i_22;
			data7_sub1  = i_23;
			data8_sub1  = i_24;
			data9_sub1  = i_25;
			data10_sub1 = i_26;
			data11_sub1 = i_27;
			data12_sub1 = i_28;
			data13_sub1 = i_29;
			data14_sub1 = i_30;
			data15_sub1 = i_31;
		end 
		else if(i_transize == 2'd2)
		begin
			data0_sub1  = i_8;
			data1_sub1  = i_9;
			data2_sub1  = i_10;
			data3_sub1  = i_11;
			data4_sub1  = i_12;
			data5_sub1  = i_13;
			data6_sub1  = i_14;
			data7_sub1  = i_15;
			data8_sub1  = i_24;
			data9_sub1  = i_25;
			data10_sub1 = i_26;
			data11_sub1 = i_27;
			data12_sub1 = i_28;
			data13_sub1 = i_29;
			data14_sub1 = i_30;
			data15_sub1 = i_31;
		end
		else
		begin
			data0_sub1  = i_4;
			data1_sub1  = i_5;
			data2_sub1  = i_6;
			data3_sub1  = i_7;
			data4_sub1  = i_12;
			data5_sub1  = i_13;
			data6_sub1  = i_14;
			data7_sub1  = i_15;
			data8_sub1  = i_20;
			data9_sub1  = i_21;
			data10_sub1 = i_22;
			data11_sub1 = i_23;
			data12_sub1 = i_28;
			data13_sub1 = i_29;
			data14_sub1 = i_30;
			data15_sub1 = i_31;
		end
	end
	else
	begin
			data0_sub1  = i_4;
			data1_sub1  = i_5;
			data2_sub1  = i_6;
			data3_sub1  = i_7;
			data4_sub1  = 28'd0;
			data5_sub1  = 28'd0;
			data6_sub1  = 28'd0;
			data7_sub1  = 28'd0;
			data8_sub1  = 28'd0;
			data9_sub1  = 28'd0;
			data10_sub1 = 28'd0;
			data11_sub1 = 28'd0;
			data12_sub1 = 28'd0;
			data13_sub1 = 28'd0;
			data14_sub1 = 28'd0;
			data15_sub1 = 28'd0;
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
assign sum8 = data8_add0  + data8_add1 ; 
assign sum9 = data9_add0  + data9_add1 ; 
assign sum10 = data10_add0 + data10_add1 ; 
assign sum11 = data11_add0 + data11_add1 ; 
assign sum12 = data12_add0 + data12_add1 ; 
assign sum13 = data13_add0 + data13_add1 ; 
assign sum14 = data14_add0 + data14_add1 ; 
assign sum15 = data15_add0 + data15_add1 ; 

assign sub0 = data0_sub0  - data0_sub1 ; 
assign sub1 = data1_sub0  - data1_sub1 ; 
assign sub2 = data2_sub0  - data2_sub1 ; 
assign sub3 = data3_sub0  - data3_sub1 ; 
assign sub4 = data4_sub0  - data4_sub1 ; 
assign sub5 = data5_sub0  - data5_sub1 ; 
assign sub6 = data6_sub0  - data6_sub1 ; 
assign sub7 = data7_sub0  - data7_sub1 ; 
assign sub8 = data8_sub0  - data8_sub1 ; 
assign sub9 = data9_sub0  - data9_sub1 ; 
assign sub10 = data10_sub0 - data10_sub1 ;
assign sub11 = data11_sub0 - data11_sub1 ;
assign sub12 = data12_sub0 - data12_sub1 ;
assign sub13 = data13_sub0 - data13_sub1 ;
assign sub14 = data14_sub0 - data14_sub1 ;
assign sub15 = data15_sub0 - data15_sub1 ;

always @(*)
begin
	if(~i_inverse)
	begin
		if(i_transize == 2'd3)
		begin
			o_0  =  sum0 ;
		        o_1  =  sum1 ;       
                        o_2  =  sum2 ;
                        o_3  =  sum3 ;
                        o_4  =  sum4 ;
                        o_5  =  sum5 ;
                        o_6  =  sum6 ;
                        o_7  =  sum7 ;
                        o_8  =  sum8 ;
                        o_9  =  sum9 ;
                        o_10 =  sum10;
                        o_11 =  sum11;
                        o_12 =  sum12;
                        o_13 =  sum13;
                        o_14 =  sum14;
                        o_15 =  sum15;
                        o_16 =  sub0 ;
                        o_17 =  sub1 ;
                        o_18 =  sub2 ;
                        o_19 =  sub3 ;
                        o_20 =  sub4 ;
                        o_21 =  sub5 ;
                        o_22 =  sub6 ;
                        o_23 =  sub7 ;
                        o_24 =  sub8 ;
                        o_25 =  sub9 ;
                        o_26 =  sub10;
                        o_27 =  sub11;
                        o_28 =  sub12;
                        o_29 =  sub13;
                        o_30 =  sub14;
                        o_31 =  sub15;
		end
		else if(i_transize == 2'd2)
		begin
			o_0  =  sum0 ;
		        o_1  =  sum1 ;       
                        o_2  =  sum2 ;
                        o_3  =  sum3 ;
                        o_4  =  sum4 ;
                        o_5  =  sum5 ;
                        o_6  =  sum6 ;
                        o_7  =  sum7 ;
                        o_8  =  sub0 ;
                        o_9  =  sub1 ;
                        o_10 =  sub2 ;
                        o_11 =  sub3 ;
                        o_12 =  sub4 ;
                        o_13 =  sub5 ;
                        o_14 =  sub6 ;
                        o_15 =  sub7 ;
                        o_16 =  sum8 ;
                        o_17 =  sum9 ;
                        o_18 =  sum10;
                        o_19 =  sum11;
                        o_20 =  sum12;
                        o_21 =  sum13;
                        o_22 =  sum14;
                        o_23 =  sum15;
                        o_24 =  sub8 ;
                        o_25 =  sub9 ;
                        o_26 =  sub10;
                        o_27 =  sub11;
                        o_28 =  sub12;
                        o_29 =  sub13;
                        o_30 =  sub14;
                        o_31 =  sub15;
		end
		else if(i_transize == 2'd1)
		begin
			o_0  =  sum0 ;
		        o_1  =  sum1 ;       
                        o_2  =  sum2 ;
                        o_3  =  sum3 ;
                        o_4  =  sub0 ;
                        o_5  =  sub1 ;
                        o_6  =  sub2 ;
                        o_7  =  sub3 ;
                        o_8  =  sum4 ;
                        o_9  =  sum5 ;
                        o_10 =  sum6 ;
                        o_11 =  sum7 ;
                        o_12 =  sub4 ;
                        o_13 =  sub5 ;
                        o_14 =  sub6 ;
                        o_15 =  sub7 ;
                        o_16 =  sum8 ;
                        o_17 =  sum9 ;
                        o_18 =  sum10;
                        o_19 =  sum11;
                        o_20 =  sub8 ;
                        o_21 =  sub9 ;
                        o_22 =  sub10;
                        o_23 =  sub11;
                        o_24 =  sum12;
                        o_25 =  sum13;
                        o_26 =  sum14;
                        o_27 =  sum15;
                        o_28 =  sub12;
                        o_29 =  sub13;
                        o_30 =  sub14;
                        o_31 =  sub15;
		end
		else
		begin
			o_0  =  i_0 ;
		        o_1  =  i_1 ;       
                        o_2  =  i_2 ;
                        o_3  =  i_3 ;
                        o_4  =  i_4 ;
                        o_5  =  i_5 ;
                        o_6  =  i_6 ;
                        o_7  =  i_7 ;
                        o_8  =  i_8 ;
                        o_9  =  i_9 ;
                        o_10 =  i_10;
                        o_11 =  i_11;
                        o_12 =  i_12;
                        o_13 =  i_13;
                        o_14 =  i_14;
                        o_15 =  i_15;
                        o_16 =  i_16;
                        o_17 =  i_17;
                        o_18 =  i_18;
                        o_19 =  i_19;
                        o_20 =  i_20;
                        o_21 =  i_21;
                        o_22 =  i_22;
                        o_23 =  i_23;
                        o_24 =  i_24;
                        o_25 =  i_25;
                        o_26 =  i_26;
                        o_27 =  i_27;
                        o_28 =  i_28;
                        o_29 =  i_29;
                        o_30 =  i_30;
                        o_31 =  i_31;
		end
	end
	else
	begin 
		if(i_transize == 2'd3)
		begin
			o_0  =  sum0 ;
		        o_1  =  sum1 ;       
                        o_2  =  sum2 ;
                        o_3  =  sum3 ;
                        o_4  =  sub0 ;
                        o_5  =  sub1 ;
                        o_6  =  sub2 ;
                        o_7  =  sub3 ;
                        o_8  =  i_8 ;
                        o_9  =  i_9 ;
                        o_10 =  i_10;
                        o_11 =  i_11;
                        o_12 =  i_12;
                        o_13 =  i_13;
                        o_14 =  i_14;
                        o_15 =  i_15;
                        o_16 =  i_16;
                        o_17 =  i_17;
                        o_18 =  i_18;
                        o_19 =  i_19;
                        o_20 =  i_20;
                        o_21 =  i_21;
                        o_22 =  i_22;
                        o_23 =  i_23;
                        o_24 =  i_24;
                        o_25 =  i_25;
                        o_26 =  i_26;
                        o_27 =  i_27;
                        o_28 =  i_28;
                        o_29 =  i_29;
                        o_30 =  i_30;
                        o_31 =  i_31;
		end
	else
		begin
			o_0  =  i_0 ;
		        o_1  =  i_1 ;       
                        o_2  =  i_2 ;
                        o_3  =  i_3 ;
                        o_4  =  i_4 ;
                        o_5  =  i_5 ;
                        o_6  =  i_6 ;
                        o_7  =  i_7 ;
                        o_8  =  i_8 ;
                        o_9  =  i_9 ;
                        o_10 =  i_10;
                        o_11 =  i_11;
                        o_12 =  i_12;
                        o_13 =  i_13;
                        o_14 =  i_14;
                        o_15 =  i_15;
                        o_16 =  i_16;
                        o_17 =  i_17;
                        o_18 =  i_18;
                        o_19 =  i_19;
                        o_20 =  i_20;
                        o_21 =  i_21;
                        o_22 =  i_22;
                        o_23 =  i_23;
                        o_24 =  i_24;
                        o_25 =  i_25;
                        o_26 =  i_26;
                        o_27 =  i_27;
                        o_28 =  i_28;
                        o_29 =  i_29;
                        o_30 =  i_30;
                        o_31 =  i_31;
		end
	end
end 


endmodule 
