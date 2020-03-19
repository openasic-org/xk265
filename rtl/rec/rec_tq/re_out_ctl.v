//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.17
//file name     : re_out_ctl.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module re_out_ctl(
	clk         ,
	rst_n	    ,
	i_valid     ,
	i_transize  ,
	tq_sel_i    ,
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
//-------------------------------//	
	o_valid     ,
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

input           clk         ;
input           rst_n       ;
input   	i_valid     ;
input [1:0]     i_transize  ;
input [1:0]     tq_sel_i    ;
//level0
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
//level1
input [27:0]	i_16        ;	
input [27:0]	i_17        ;	
input [27:0]	i_18        ;	
input [27:0]	i_19        ;	
input [27:0]	i_20        ;	
input [27:0]	i_21        ;	
input [27:0]	i_22        ;	
input [27:0]	i_23        ;	
//level2
input [27:0]	i_24        ;	
input [27:0]	i_25        ;	
input [27:0]	i_26        ;	
input [27:0]	i_27        ;	
//level3
input [27:0]	i_28        ;	
input [27:0]	i_29        ;	
input [27:0]	i_30        ;	
input [27:0]	i_31        ;
//-------------------------------------------//
output          o_valid     ;	
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
reg [1:0]       valid_d       ;
reg             o_valid     ;
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
//-----------------//
always @(*)
begin
	if(i_transize == 2'd0)//dct4x4 or dst4x4
	begin
		 o_0  = i_0;
                 o_1  = i_1;
                 o_2  = i_2;
                 o_3  = i_3;
                 o_4  = 28'd0;
                 o_5  = 28'd0;
                 o_6  = 28'd0;
                 o_7  = 28'd0;
                 o_8  = i_4;
                 o_9  = i_5;
                 o_10 = i_6;
                 o_11 = i_7;
                 o_12 = 28'd0;
                 o_13 = 28'd0;
                 o_14 = 28'd0;
                 o_15 = 28'd0;
	         o_16 = i_8;	
                 o_17 = i_9;
                 o_18 = i_10;
                 o_19 = i_11;
                 o_20 = 28'd0;
                 o_21 = 28'd0;
                 o_22 = 28'd0;
                 o_23 = 28'd0;
                 o_24 = i_12;
                 o_25 = i_13;
                 o_26 = i_14;
                 o_27 = i_15;
                 o_28 = 28'd0;
                 o_29 = 28'd0;
                 o_30 = 28'd0;
	         o_31 = 28'd0;
	end
	else if(i_transize == 2'd1)//dct8x8
	begin
		 o_0  = i_16;
                 o_1  = i_17;
                 o_2  = i_18;
                 o_3  = i_19;
                 o_4  = i_0;
                 o_5  = i_1;
                 o_6  = i_2;
                 o_7  = i_3;
                 o_8  = i_20;
                 o_9  = i_21;
                 o_10 = i_22;
                 o_11 = i_23;
                 o_12 = i_4;
                 o_13 = i_5;
                 o_14 = i_6;
                 o_15 = i_7;
	         o_16 = i_24;	
                 o_17 = i_25;
                 o_18 = i_26;
                 o_19 = i_27;
                 o_20 = i_8;
                 o_21 = i_9;
                 o_22 = i_10;
                 o_23 = i_11;
                 o_24 = i_28;
                 o_25 = i_29;
                 o_26 = i_30;
                 o_27 = i_31;
                 o_28 = i_12;
                 o_29 = i_13;
                 o_30 = i_14;
	         o_31 = i_15;
	end
	else if(i_transize == 2'd2)//dct16x16
	begin
		 o_0  = i_24;
                 o_1  = i_25;
                 o_2  = i_26;
                 o_3  = i_27;
                 o_4  = i_16;
                 o_5  = i_17;
                 o_6  = i_18;
                 o_7  = i_19;
                 o_8  = i_0;
                 o_9  = i_1;
                 o_10 = i_2;
                 o_11 = i_3;
                 o_12 = i_4;
                 o_13 = i_5;
                 o_14 = i_6;
                 o_15 = i_7;
	         o_16 = i_28;	
                 o_17 = i_29;
                 o_18 = i_30;
                 o_19 = i_31;
                 o_20 = i_20;
                 o_21 = i_21;
                 o_22 = i_22;
                 o_23 = i_23;
                 o_24 = i_8;
                 o_25 = i_9;
                 o_26 = i_10;
                 o_27 = i_11;
                 o_28 = i_12;
                 o_29 = i_13;
                 o_30 = i_14;
	         o_31 = i_15;
	end
	else//dct32x32
	begin
		 o_0  = i_28;
                 o_1  = i_29;
                 o_2  = i_30;
                 o_3  = i_31;
                 o_4  = i_24;
                 o_5  = i_25;
                 o_6  = i_26;
                 o_7  = i_27;
                 o_8  = i_16;
                 o_9  = i_17;
                 o_10 = i_18;
                 o_11 = i_19;
                 o_12 = i_20;
                 o_13 = i_21;
                 o_14 = i_22;
                 o_15 = i_23;
	         o_16 = i_0 ;	
                 o_17 = i_1 ;
                 o_18 = i_2 ;
                 o_19 = i_3 ;
                 o_20 = i_4 ;
                 o_21 = i_5 ;
                 o_22 = i_6 ;
                 o_23 = i_7 ;
                 o_24 = i_8 ;
                 o_25 = i_9 ;
                 o_26 = i_10;
                 o_27 = i_11;
                 o_28 = i_12;
                 o_29 = i_13;
                 o_30 = i_14;
	         o_31 = i_15;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		valid_d <= 2'd0;
	end
	else
	begin
		valid_d <= {valid_d[0],i_valid};
	end
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		o_valid <= 1'b0;
	end
	else if((i_transize == 2'd0) || (i_transize == 2'd1)) //d2
	begin
		o_valid <= valid_d[0];
	end
	else //d3
	begin
		o_valid <= valid_d[1];
	end
end 

endmodule 

