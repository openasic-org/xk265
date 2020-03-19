//company       : xm tech
//project name  : H265i
//top module    : dct_top_2d.v
//data          : 2018.01.22
//file name     : pe_t.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module pe_i(
	i_transize  ,
	i_valid     ,
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

input [1:0]  	i_transize  ;
input           i_valid     ;
input [15:0]	i_0         ;	
input [15:0]	i_1         ;	
input [15:0]	i_2         ;	
input [15:0]	i_3         ;	
input [15:0]	i_4         ;	
input [15:0]	i_5         ;	
input [15:0]	i_6         ;	
input [15:0]	i_7         ;	
input [15:0]	i_8         ;	
input [15:0]	i_9         ;	
input [15:0]	i_10        ;	
input [15:0]	i_11        ;	
input [15:0]	i_12        ;	
input [15:0]	i_13        ;	
input [15:0]	i_14        ;	
input [15:0]	i_15        ;	
input [15:0]	i_16        ;	
input [15:0]	i_17        ;	
input [15:0]	i_18        ;	
input [15:0]	i_19        ;	
input [15:0]	i_20        ;	
input [15:0]	i_21        ;	
input [15:0]	i_22        ;	
input [15:0]	i_23        ;	
input [15:0]	i_24        ;	
input [15:0]	i_25        ;	
input [15:0]	i_26        ;	
input [15:0]	i_27        ;	
input [15:0]	i_28        ;	
input [15:0]	i_29        ;	
input [15:0]	i_30        ;	
input [15:0]	i_31        ;
	
//--------
output          o_valid     ;
output [15:0]	o_0         ;	
output [15:0]	o_1         ;	
output [15:0]	o_2         ;	
output [15:0]	o_3         ;	
output [15:0]	o_4         ;	
output [15:0]	o_5         ;	
output [15:0]	o_6         ;	
output [15:0]	o_7         ;	
output [15:0]	o_8         ;	
output [15:0]	o_9         ;	
output [15:0]	o_10        ;	
output [15:0]	o_11        ;	
output [15:0]	o_12        ;	
output [15:0]	o_13        ;	
output [15:0]	o_14        ;	
output [15:0]	o_15        ;	
output [15:0]	o_16        ;	
output [15:0]	o_17        ;	
output [15:0]	o_18        ;	
output [15:0]	o_19        ;	
output [15:0]	o_20        ;	
output [15:0]	o_21        ;	
output [15:0]	o_22        ;	
output [15:0]	o_23        ;	
output [15:0]	o_24        ;	
output [15:0]	o_25        ;	
output [15:0]	o_26        ;	
output [15:0]	o_27        ;
output [15:0]	o_28        ;	
output [15:0]	o_29        ;	
output [15:0]	o_30        ;	
output [15:0]	o_31        ;	
//------------------------wire-----------------//
wire            o_valid     ;
reg    [15:0]	o_0         ;	
reg    [15:0]	o_1         ;	
reg    [15:0]	o_2         ;	
reg    [15:0]	o_3         ;	
reg    [15:0]	o_4         ;	
reg    [15:0]	o_5         ;	
reg    [15:0]	o_6         ;	
reg    [15:0]	o_7         ;	
reg    [15:0]	o_8         ;	
reg    [15:0]	o_9         ;	
reg    [15:0]	o_10        ;	
reg    [15:0]	o_11        ;	
reg    [15:0]	o_12        ;	
reg    [15:0]	o_13        ;	
reg    [15:0]	o_14        ;	
reg    [15:0]	o_15        ;	
reg    [15:0]	o_16        ;	
reg    [15:0]	o_17        ;	
reg    [15:0]	o_18        ;	
reg    [15:0]	o_19        ;	
reg    [15:0]	o_20        ;	
reg    [15:0]	o_21        ;	
reg    [15:0]	o_22        ;	
reg    [15:0]	o_23        ;	
reg    [15:0]	o_24        ;	
reg    [15:0]	o_25        ;	
reg    [15:0]	o_26        ;	
reg    [15:0]	o_27        ;
reg    [15:0]	o_28        ;	
reg    [15:0]	o_29        ;	
reg    [15:0]	o_30        ;	
reg    [15:0]	o_31        ;
	
//--------------------------------------//
assign o_valid = i_valid;

always @(*)
begin
	if(i_transize == 2'd3)
	begin
		o_0 =  i_0 ;	
                o_1 =  i_8 ;
                o_2 =  i_16;
                o_3 =  i_24;
                o_4 =  i_4 ;
                o_5 =  i_12;
                o_6 =  i_20;
                o_7 =  i_28;
                o_8 =  i_2 ;
                o_9 =  i_6 ;
                o_10=  i_10;
                o_11=  i_14;
                o_12=  i_18;
                o_13=  i_22;
                o_14=  i_26;
                o_15=  i_30; 
                o_16=  i_1 ;
                o_17=  i_3 ;
                o_18=  i_5 ;
                o_19=  i_7 ;
                o_20=  i_9 ;
                o_21=  i_11;
                o_22=  i_13;
                o_23=  i_15;
                o_24=  i_17;
                o_25=  i_19;
                o_26=  i_21;
                o_27=  i_23;
                o_28=  i_25;
                o_29=  i_27;
                o_30=  i_29;
                o_31=  i_31;
	end 
	else if(i_transize == 2'd2)
	begin
		o_0 =  i_0 ;	
                o_1 =  i_4 ;
                o_2 =  i_8 ;
                o_3 =  i_12;
                o_4 =  i_2 ;
                o_5 =  i_6 ;
                o_6 =  i_10;
                o_7 =  i_14;
                o_8 =  i_1 ;
                o_9 =  i_3 ;
                o_10=  i_5 ;
                o_11=  i_7 ;
                o_12=  i_9 ;
                o_13=  i_11;
                o_14=  i_13;
                o_15=  i_15;
                o_16=  i_16;
                o_17=  i_20;
                o_18=  i_24;
                o_19=  i_28;
                o_20=  i_18;
                o_21=  i_22;
                o_22=  i_26;
                o_23=  i_30;
                o_24=  i_17;
                o_25=  i_19;
                o_26=  i_21;
                o_27=  i_23;
                o_28=  i_25;
                o_29=  i_27;
                o_30=  i_29;
                o_31=  i_31;
	end
	else if(i_transize == 2'd1)
	begin
		o_0 = i_0 ; 	
                o_1 = i_2 ; 
                o_2 = i_4 ; 
                o_3 = i_6 ; 
                o_4 = i_1 ; 
                o_5 = i_3 ; 
                o_6 = i_5 ; 
                o_7 = i_7 ; 
                o_8 = i_8 ; 
                o_9 = i_10; 
                o_10= i_12; 
                o_11= i_14; 
                o_12= i_9 ; 
                o_13= i_11; 
                o_14= i_13; 
                o_15= i_15; 
                o_16= i_16; 
                o_17= i_18; 
                o_18= i_20; 
                o_19= i_22; 
                o_20= i_17; 
                o_21= i_19; 
                o_22= i_21; 
                o_23= i_23; 
                o_24= i_24; 
                o_25= i_26; 
                o_26= i_28; 
                o_27= i_30; 
                o_28= i_25; 
                o_29= i_27; 
                o_30= i_29; 
                o_31= i_31; 
	end 
	else 
	begin	
		o_0 =  i_0;	
                o_1 =  i_1;
                o_2 =  i_2;
                o_3 =  i_3;
                o_4 =  i_4;
                o_5 =  i_5;
                o_6 =  i_6;
                o_7 =  i_7;
                o_8 =  i_8;
                o_9 =  i_9;
                o_10=  i_10;
                o_11=  i_11;
                o_12=  i_12;
                o_13=  i_13;
                o_14=  i_14;
                o_15=  i_15;
                o_16=  i_16;
                o_17=  i_17;
                o_18=  i_18;
                o_19=  i_19;
                o_20=  i_20;
                o_21=  i_21;
                o_22=  i_22;
                o_23=  i_23;
                o_24=  i_24;
                o_25=  i_25;
                o_26=  i_26;
                o_27=  i_27;
                o_28=  i_28;
                o_29=  i_29;
                o_30=  i_30;
                o_31=  i_31;
	end 
end 



endmodule

