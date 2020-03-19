//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.08
//file name     : re_level0_cal.v
//delay         : 1 clk 
//describe      :
//modification  :
//v1.0          :

module re_level0_cal(
	clk            ,
	rst_n          ,
	i_dt_vld32     ,//data valid
        i_dt_vld16     ,
        i_dt_vld8      ,
	i_dt_vld4      ,
        i_dt_vld_dst   , 
	i_data	       ,
//--------r16--------//
        o_data_r16_4   ,   
        o_data_r16_13  ,
        o_data_r16_22  ,
        o_data_r16_31  ,
        o_data_r16_38  ,
        o_data_r16_46  ,
        o_data_r16_54  ,
        o_data_r16_61  ,
        o_data_r16_67  ,
        o_data_r16_73  ,
        o_data_r16_78  ,
        o_data_r16_82  ,
        o_data_r16_85  ,
        o_data_r16_88  ,
        o_data_r16_90  ,
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
        o_data_a4_83   ,
//-----------dst4x4--------//
	o_data_s4_29   ,   
        o_data_s4_55   ,
        o_data_s4_74   ,
        o_data_s4_84   
);

input   	clk            ;
input   	rst_n          ;
input [16:0]	i_data	       ;
input  	        i_dt_vld32     ;
input           i_dt_vld16     ;
input           i_dt_vld8      ;
input           i_dt_vld4      ;
input           i_dt_vld_dst   ;

//----------------dct16x16---------------//
output  [24:0]     o_data_r16_4     ;     
output  [24:0]     o_data_r16_13    ;
output  [24:0]     o_data_r16_22    ;
output  [24:0]     o_data_r16_31    ;
output  [24:0]     o_data_r16_38    ;
output  [24:0]     o_data_r16_46    ;
output  [24:0]     o_data_r16_54    ;
output  [24:0]     o_data_r16_61    ;
output  [24:0]     o_data_r16_67    ;
output  [24:0]     o_data_r16_73    ;
output  [24:0]     o_data_r16_78    ;
output  [24:0]     o_data_r16_82    ;
output  [24:0]     o_data_r16_85    ;
output  [24:0]     o_data_r16_88    ;
output  [24:0]     o_data_r16_90    ;
//-------------------dct8x8--------------//
output  [24:0]     o_data_r8_9      ;      
output  [24:0]     o_data_r8_25     ;
output  [24:0]     o_data_r8_43     ;
output  [24:0]     o_data_r8_57     ;
output  [24:0]     o_data_r8_70     ;
output  [24:0]     o_data_r8_80     ;
output  [24:0]     o_data_r8_87     ;
output  [24:0]     o_data_r8_90     ;
//-------------------dct4x4---------------//
output  [24:0]     o_data_r4_89     ;
output  [24:0]     o_data_r4_75     ; 
output  [24:0]     o_data_r4_50     ; 
output  [24:0]     o_data_r4_18     ; 
//-------------a4----------//
output  [24:0]     o_data_a4_64   ;  
output  [24:0]     o_data_a4_36   ;
output  [24:0]     o_data_a4_83   ;
//------------------dst4x4------------------//
output  [24:0]     o_data_s4_29     ;
output  [24:0]     o_data_s4_55     ; 
output  [24:0]     o_data_s4_74     ; 
output  [24:0]     o_data_s4_84     ;
//------------------------------------------------//
wire [24:0]     data           ;
wire [24:0]     data_2         ;
wire [24:0]     data_4         ;
wire [24:0]     data_8         ;
wire [24:0]     data_16        ;
wire [24:0]     data_32        ;
wire [24:0]     data_64        ;
//wire [24:0]     data_3         ;
//wire [24:0]     data_5         ;
//wire [24:0]     data_7         ;
wire [24:0]     data_9         ;
wire [24:0]     data_13        ;
//wire [24:0]     data_6         ;
//wire [24:0]     data_14        ;
wire [24:0]     data_11        ;
//wire [24:0]     data_48        ;
//wire [24:0]     data_80        ;
//wire [24:0]     data_10        ;
//----------------dct16x16---------------//
wire [24:0]     data_r16_4     ;     
wire [24:0]     data_r16_13    ;
wire [24:0]     data_r16_22    ;
wire [24:0]     data_r16_31    ;
wire [24:0]     data_r16_38    ;
wire [24:0]     data_r16_46    ;
wire [24:0]     data_r16_54    ;
wire [24:0]     data_r16_61    ;
wire [24:0]     data_r16_67    ;
wire [24:0]     data_r16_73    ;
wire [24:0]     data_r16_78    ;
wire [24:0]     data_r16_82    ;
wire [24:0]     data_r16_85    ;
wire [24:0]     data_r16_88    ;
wire [24:0]     data_r16_90    ;
//-------------------dct8x8--------------//
wire [24:0]     data_r8_9      ;      
wire [24:0]     data_r8_25     ;
wire [24:0]     data_r8_43     ;
wire [24:0]     data_r8_57     ;
wire [24:0]     data_r8_70     ;
wire [24:0]     data_r8_80     ;
wire [24:0]     data_r8_87     ;
wire [24:0]     data_r8_90     ;
//-------------------dct4x4---------------//
wire [24:0]     data_r4_89     ;
wire [24:0]     data_r4_75     ; 
wire [24:0]     data_r4_50     ; 
wire [24:0]     data_r4_18     ; 
//-------------------a4---------------//
wire [24:0]     data_a4_64     ;
wire [24:0]     data_a4_36     ; 
wire [24:0]     data_a4_83     ; 
//------------------dst4x4------------------//
wire [24:0]     data_s4_29     ;
wire [24:0]     data_s4_55     ; 
wire [24:0]     data_s4_74     ; 
wire [24:0]     data_s4_84     ;

//----------------r16---------------//
reg  [24:0]     o_data_r16_4     ;     
reg  [24:0]     o_data_r16_13    ;
reg  [24:0]     o_data_r16_22    ;
reg  [24:0]     o_data_r16_31    ;
reg  [24:0]     o_data_r16_38    ;
reg  [24:0]     o_data_r16_46    ;
reg  [24:0]     o_data_r16_54    ;
reg  [24:0]     o_data_r16_61    ;
reg  [24:0]     o_data_r16_67    ;
reg  [24:0]     o_data_r16_73    ;
reg  [24:0]     o_data_r16_78    ;
reg  [24:0]     o_data_r16_82    ;
reg  [24:0]     o_data_r16_85    ;
reg  [24:0]     o_data_r16_88    ;
reg  [24:0]     o_data_r16_90    ;
//-------------------r8--------------//
reg  [24:0]     o_data_r8_9      ;      
reg  [24:0]     o_data_r8_25     ;
reg  [24:0]     o_data_r8_43     ;
reg  [24:0]     o_data_r8_57     ;
reg  [24:0]     o_data_r8_70     ;
reg  [24:0]     o_data_r8_80     ;
reg  [24:0]     o_data_r8_87     ;
reg  [24:0]     o_data_r8_90     ;
//-------------------r4---------------//
reg  [24:0]     o_data_r4_89     ;
reg  [24:0]     o_data_r4_75     ; 
reg  [24:0]     o_data_r4_50     ; 
reg  [24:0]     o_data_r4_18     ; 
//-------------------a4---------------//
reg  [24:0]     o_data_r4_64     ;
reg  [24:0]     o_data_r4_83     ; 
reg  [24:0]     o_data_r4_36     ; 
//-------------a4----------//
reg  [24:0]     o_data_a4_64   ;  
reg  [24:0]     o_data_a4_36   ;
reg  [24:0]     o_data_a4_83   ;
//------------------dst4x4------------------//
reg  [24:0]     o_data_s4_29     ;
reg  [24:0]     o_data_s4_55     ; 
reg  [24:0]     o_data_s4_74     ; 
reg  [24:0]     o_data_s4_84     ;
/*
//----------------------------------------------------//
assign data    = {{8{i_data[16]}},i_data};
assign data_2  = {{7{i_data[16]}},i_data,1'b0};
assign data_4  = {{6{i_data[16]}},i_data,2'd0};
assign data_8  = {{5{i_data[16]}},i_data,3'd0};
assign data_16 = {{4{i_data[16]}},i_data,4'd0};
assign data_32 = {{3{i_data[16]}},i_data,5'd0};
assign data_64 = {{2{i_data[16]}},i_data,6'd0};

assign data_3  = data + data_2;
assign data_5  = data + data_4;  
assign data_7  = data_8 - data;
assign data_9  = data_8 + data;
assign data_13 = data_8 + data_5;
assign data_6  = {data_3[23:0],1'b0};
assign data_14 = {data_7[23:0],1'b0};
assign data_11 = data_16 - data_5;
assign data_48 = {data_6[21:0],3'd0};
assign data_80 = {data_10[21:0],3'd0};
assign data_10 = {data_5[23:0],1'b0};

//-----------------r16-------------------//
assign data_r16_4  = data_4;
assign data_r16_13 = data_13;  
assign data_r16_22 = {data_11[23:0],1'b0};
assign data_r16_31 = data_32 - data;
assign data_r16_38 = data_r16_22 + data_16;//data_32 + data_6;
assign data_r16_46 = data_32 + data_14;
assign data_r16_54 = data_32 + {data_11[23:0],1'b0}; 
assign data_r16_61 = data_64 - data_3;     //data_48 + data_13;
assign data_r16_67 = data_64 + data_3;
assign data_r16_73 = data_64 + data_9;
assign data_r16_78 = data_64 + data_14;
assign data_r16_82 = data_80 + data_2;
assign data_r16_85 = data_80 + data_5;
assign data_r16_88 = {data_11[21:0],3'd0};
assign data_r16_90 = data_80 + data_10; 
//-----------------r8-------------------//
assign data_r8_9  = data_9;
assign data_r8_25 = data_16 + data_9;
assign data_r8_43 = data_32 + data_11;
assign data_r8_57 = data_64 - data_7;//data_48 + data_9;
assign data_r8_70 = data_80 - data_10;//data_64 + data_6;
assign data_r8_80 = data_80;
assign data_r8_87 = data_80 + data_7;
assign data_r8_90 = data_r16_90;
//-----------------r4-------------------//
assign data_r4_89 = data_80 + data_9;
assign data_r4_75 = data_64 + data_11;
assign data_r4_50 = {data_r8_25[23:0],1'b0};
assign data_r4_18 = {data_9[23:0],1'b0};

//------------------a4--------------------//
assign data_a4_64 = data_64;
assign data_a4_83 = data_80 + data_3;
assign data_a4_36 = {data_9[22:0],2'd0};

//-----------------dst--------------------//

assign data_s4_29 = data_16 + data_13;
assign data_s4_55 = data_48 + data_7;
assign data_s4_74 = data_64 + data_10;
assign data_s4_84 = data_80 + data_4;
*/
//----------------------------------------------------//
assign data    = {{8{i_data[16]}},i_data};
assign data_2  = {{7{i_data[16]}},i_data,1'b0};
assign data_4  = {{6{i_data[16]}},i_data,2'd0};
assign data_8  = {{5{i_data[16]}},i_data,3'd0};
assign data_16 = {{4{i_data[16]}},i_data,4'd0};
assign data_32 = {{3{i_data[16]}},i_data,5'd0};
assign data_64 = {{2{i_data[16]}},i_data,6'd0};

//assign data_3  = data + data_2;
//assign data_5  = data + data_4;  
//assign data_7  = data_8 - data;
assign data_9  = data_8 + data;
assign data_13 = data_9 + data_4;
//assign data_6  = {data_3[23:0],1'b0};
//assign data_14 = {data_7[23:0],1'b0};
assign data_11 = data_9 + data_2;
//assign data_48 = {data_6[21:0],3'd0};
//assign data_80 = {data_10[21:0],3'd0};
//assign data_10 = {data_5[23:0],1'b0};

//-----------------r16-------------------//
assign data_r16_4  = data_4;
assign data_r16_13 = data_13;  
assign data_r16_22 = {data_11[23:0],1'b0};
assign data_r16_31 = data_32 - data;
assign data_r16_38 = {data_9[22:0],2'd0} + data_2;//data_32 + data_6;
assign data_r16_46 = {data_11[22:0],2'd0} + data_2;
assign data_r16_54 = {data_13[22:0],2'd0} + data_2; 
assign data_r16_61 = {data_13[22:0],2'd0} + data_9;     //data_48 + data_13;
assign data_r16_67 = {data_r16_38[23:0],1'd0} - data_9; 
assign data_r16_73 = {data_9[21:0],3'd0} + data;
assign data_r16_78 = data_r16_67 + data_11;
assign data_r16_82 = data_r16_38 + {data_11[22:0],2'd0};
assign data_r16_85 = data_s4_84 + data;
assign data_r16_88 = {data_11[21:0],3'd0};
assign data_r16_90 = data_r16_88 + data_2; 
//-----------------r8-------------------//
assign data_r8_9  = data_9;
assign data_r8_25 = {data_13[23:0],1'b0} - data;
assign data_r8_43 = {data_11[22:0],2'b0} - data;
assign data_r8_57 = data_r16_61 - data_4;//data_48 + data_9;
assign data_r8_70 = {data_9[21:0],3'd0} - data_2;//data_64 + data_6;
assign data_r8_80 = {data_9[21:0],3'd0} + data_8;
assign data_r8_87 = {data_11[21:0],3'd0} - data;
assign data_r8_90 = {data_11[21:0],3'd0} + data_2;
//-----------------r4-------------------//
assign data_r4_89 = {data_11[21:0],3'd0} + data;
assign data_r4_75 = data_64 + data_11;
assign data_r4_50 = {data_r8_25[23:0],1'b0};
assign data_r4_18 = {data_9[23:0],1'b0};

//------------------a4--------------------//
assign data_a4_64 = data_64;
assign data_a4_83 = {data_9[21:0],3'd0} + data_11;
assign data_a4_36 = {data_9[22:0],2'd0};

//-----------------dst--------------------//

assign data_s4_29 = data_16 + data_13;
assign data_s4_55 = {data_11[22:0],2'd0} + data_11;
assign data_s4_74 = {data_9[21:0],3'd0} + data_2;
assign data_s4_84 = {data_11[21:0],3'd0} - data_4;
//-------------reg out---------------------//
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_4 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_4 <= data_r16_4;
	else
		o_data_r16_4 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_13 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_13 <= data_r16_13;
	else
		o_data_r16_13 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_22 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_22 <= data_r16_22;
	else
		o_data_r16_22 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_31 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_31 <= data_r16_31;
	else
		o_data_r16_31 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_38 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_38 <= data_r16_38;
	else
		o_data_r16_38 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_46 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_46 <= data_r16_46;
	else
		o_data_r16_46 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_54 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_54 <= data_r16_54;
	else
		o_data_r16_54 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_61 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_61 <= data_r16_61;
	else
		o_data_r16_61 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_67 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_67 <= data_r16_67;
	else
		o_data_r16_67 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_73 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_73 <= data_r16_73;
	else
		o_data_r16_73 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_78 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_78 <= data_r16_78;
	else
		o_data_r16_78 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_82 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_82 <= data_r16_82;
	else
		o_data_r16_82 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_85 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_85 <= data_r16_85;
	else
		o_data_r16_85 <= 25'd0;
end


always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_88 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_88 <= data_r16_88;
	else
		o_data_r16_88 <= 25'd0;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r16_90 <= 25'd0;
	else if(i_dt_vld32)
		o_data_r16_90 <= data_r16_90;
	else
		o_data_r16_90 <= 25'd0;
end
//---------------------------r8--------------------//
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_9 <= 25'd0;
	else if(i_dt_vld16)
		o_data_r8_9 <= data_r8_9;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_25 <= 25'd0;
	else if(i_dt_vld16)
		o_data_r8_25 <= data_r8_25;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_43 <= 25'd0;
	else if(i_dt_vld16)
		o_data_r8_43 <= data_r8_43;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_57 <= 25'd0;
	else if(i_dt_vld16)
		o_data_r8_57 <= data_r8_57;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_70 <= 25'd0;
	else if(i_dt_vld16)
		o_data_r8_70 <= data_r8_70;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_80 <= 25'd0;
	else if(i_dt_vld16)
		o_data_r8_80 <= data_r8_80;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_87 <= 25'd0;
	else if(i_dt_vld16)
		o_data_r8_87 <= data_r8_87;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r8_90 <= 25'd0;
	else if(i_dt_vld16)
		o_data_r8_90 <= data_r8_90;
end
//------------------------------------r4-------------------//

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r4_89 <= 25'd0;
	else if(i_dt_vld8)
		o_data_r4_89 <= data_r4_89;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r4_75 <= 25'd0;
	else if(i_dt_vld8)
		o_data_r4_75 <= data_r4_75;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r4_50 <= 25'd0;
	else if(i_dt_vld8)
		o_data_r4_50 <= data_r4_50;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_r4_18 <= 25'd0;
	else if(i_dt_vld8)
		o_data_r4_18 <= data_r4_18;
end
//---------------------------------------a4---------------------------//
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_a4_64 <= 25'd0;
	else if(i_dt_vld4)
		o_data_a4_64 <= data_a4_64;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_a4_83 <= 25'd0;
	else if(i_dt_vld4)
		o_data_a4_83 <= data_a4_83;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_a4_36 <= 25'd0;
	else if(i_dt_vld4)
		o_data_a4_36 <= data_a4_36;
end 

//---------------------------------------dst-----------------//

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_s4_29 <= 25'd0;
	else if(i_dt_vld_dst)
		o_data_s4_29 <= data_s4_29;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_s4_55 <= 25'd0;
	else if(i_dt_vld_dst)
		o_data_s4_55 <= data_s4_55;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_s4_74 <= 25'd0;
	else if(i_dt_vld_dst)
		o_data_s4_74 <= data_s4_74;
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_data_s4_84 <= 25'd0;
	else if(i_dt_vld_dst)
		o_data_s4_84 <= data_s4_84;
end



endmodule  
