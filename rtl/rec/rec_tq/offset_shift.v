//company       : xm tech
//project name  : H265i
//top module    : dct_top_2d.v
//data          : 2018.01.22
//file name     : offset_shift.v
//delay         : 1 clk 
//describe      :
//modification  :
//v1.0          :

module offset_shift(
                 clk           ,
                 rst_n         , 
                 i_row         ,
                 i_dt_vld      ,
	         i_inverse     ,
                 i_transize    ,
                 i_0           ,
                 i_1           ,
                 i_2           ,
                 i_3           ,
                 i_4           ,
                 i_5           ,
                 i_6           ,
                 i_7           ,
                 i_8           ,
                 i_9           ,
                 i_10          ,
                 i_11          ,
                 i_12          ,
                 i_13          ,
                 i_14          ,
                 i_15          ,
                 i_16          ,
                 i_17          ,
                 i_18          ,
                 i_19          ,
                 i_20          ,
                 i_21          ,
                 i_22          ,
                 i_23          ,
                 i_24          ,
                 i_25          ,
                 i_26          ,
                 i_27          ,
                 i_28          ,
                 i_29          ,
                 i_30          ,
                 i_31          ,
               
                o_2d_dt_vld    ,
		o_t_dt_vld     ,
                o_0            ,
                o_1            ,
                o_2            ,
                o_3            ,
                o_4            ,
                o_5            ,
                o_6            ,
                o_7            ,
                o_8            ,
                o_9            ,
                o_10           ,
                o_11           ,
                o_12           ,
                o_13           ,
                o_14           ,
                o_15           ,
                o_16           ,
                o_17           ,
                o_18           ,
                o_19           ,
                o_20           ,
                o_21           ,
                o_22           ,
                o_23           ,
                o_24           ,
                o_25           ,
                o_26           ,
                o_27           ,
                o_28           ,
                o_29           ,
                o_30           ,
                o_31           
);

// ********************************************
//                                             
//    INPUT / OUTPUT DECLARATION                                               
//                                                                             
// ********************************************

input                   clk       ;
input                   rst_n     ;
input                   i_row     ;
input                   i_inverse ;
input                   i_dt_vld  ;
input          [1:0]    i_transize;
input          [27:0]   i_0       ;//signed
input          [27:0]   i_1       ;//signed
input          [27:0]   i_2       ;//signed
input          [27:0]   i_3       ;//signed
input          [27:0]   i_4       ;//signed
input          [27:0]   i_5       ;//signed
input          [27:0]   i_6       ;//signed
input          [27:0]   i_7       ;//signed
input          [27:0]   i_8       ;//signed
input          [27:0]   i_9       ;//signed
input          [27:0]   i_10      ;//signed
input          [27:0]   i_11      ;//signed
input          [27:0]   i_12      ;//signed
input          [27:0]   i_13      ;//signed
input          [27:0]   i_14      ;//signed
input          [27:0]   i_15      ;//signed
input          [27:0]   i_16      ;//signed
input          [27:0]   i_17      ;//signed
input          [27:0]   i_18      ;//signed
input          [27:0]   i_19      ;//signed
input          [27:0]   i_20      ;//signed
input          [27:0]   i_21      ;//signed
input          [27:0]   i_22      ;//signed
input          [27:0]   i_23      ;//signed
input          [27:0]   i_24      ;//signed
input          [27:0]   i_25      ;//signed
input          [27:0]   i_26      ;//signed
input          [27:0]   i_27      ;//signed
input          [27:0]   i_28      ;//signed
input          [27:0]   i_29      ;//signed
input          [27:0]   i_30      ;//signed
input          [27:0]   i_31      ;//signed


output reg           o_2d_dt_vld  ;
output reg           o_t_dt_vld   ;
output reg  [15:0]   o_0; // signed
output reg  [15:0]   o_1; // signed
output reg  [15:0]   o_2; // signed
output reg  [15:0]   o_3; // signed
output reg  [15:0]   o_4; // signed
output reg  [15:0]   o_5; // signed
output reg  [15:0]   o_6; // signed
output reg  [15:0]   o_7; // signed
output reg  [15:0]   o_8; // signed
output reg  [15:0]   o_9; // signed
output reg  [15:0]   o_10;// signed
output reg  [15:0]   o_11;// signed
output reg  [15:0]   o_12;// signed
output reg  [15:0]   o_13;// signed
output reg  [15:0]   o_14;// signed
output reg  [15:0]   o_15;// signed
output reg  [15:0]   o_16;// signed
output reg  [15:0]   o_17;// signed
output reg  [15:0]   o_18;// signed
output reg  [15:0]   o_19;// signed
output reg  [15:0]   o_20;// signed
output reg  [15:0]   o_21;// signed
output reg  [15:0]   o_22;// signed
output reg  [15:0]   o_23;// signed
output reg  [15:0]   o_24;// signed
output reg  [15:0]   o_25;// signed
output reg  [15:0]   o_26;// signed
output reg  [15:0]   o_27;// signed
output reg  [15:0]   o_28;// signed
output reg  [15:0]   o_29;// signed
output reg  [15:0]   o_30;// signed
output reg  [15:0]   o_31;// signed

//-------------------------------------------//
parameter  DCT_4 =2'b00 ;
parameter  DCT_8 =2'b01 ;
parameter  DCT_16=2'b10 ;
parameter  DCT_32=2'b11 ;
//-------------------------------------------//
reg  [16:0]   data_0  ;
reg  [16:0]   data_1  ;
reg  [16:0]   data_2  ;
reg  [16:0]   data_3  ;
reg  [16:0]   data_4  ;
reg  [16:0]   data_5  ;
reg  [16:0]   data_6  ;
reg  [16:0]   data_7  ;
reg  [16:0]   data_8  ;
reg  [16:0]   data_9  ;

reg  [16:0]   data_10  ;
reg  [16:0]   data_11  ;
reg  [16:0]   data_12  ;
reg  [16:0]   data_13  ;
reg  [16:0]   data_14  ;
reg  [16:0]   data_15  ;
reg  [16:0]   data_16  ;
reg  [16:0]   data_17  ;
reg  [16:0]   data_18  ;
reg  [16:0]   data_19  ;

reg  [16:0]   data_20  ;
reg  [16:0]   data_21  ;
reg  [16:0]   data_22  ;
reg  [16:0]   data_23  ;
reg  [16:0]   data_24  ;
reg  [16:0]   data_25  ;
reg  [16:0]   data_26  ;
reg  [16:0]   data_27  ;
reg  [16:0]   data_28  ;
reg  [16:0]   data_29  ;

reg  [16:0]   data_30  ;
reg  [16:0]   data_31  ;

wire [16:0]   data0_add    ;       
wire [16:0]   data1_add    ;
wire [16:0]   data2_add    ;
wire [16:0]   data3_add    ;
wire [16:0]   data4_add    ;
wire [16:0]   data5_add    ;
wire [16:0]   data6_add    ;
wire [16:0]   data7_add    ;
wire [16:0]   data8_add    ;
wire [16:0]   data9_add    ;
wire [16:0]   data10_add   ;
wire [16:0]   data11_add   ;
wire [16:0]   data12_add   ;
wire [16:0]   data13_add   ;
wire [16:0]   data14_add   ;
wire [16:0]   data15_add   ;
wire [16:0]   data16_add   ;
wire [16:0]   data17_add   ;
wire [16:0]   data18_add   ;
wire [16:0]   data19_add   ;
wire [16:0]   data20_add   ;
wire [16:0]   data21_add   ;
wire [16:0]   data22_add   ;
wire [16:0]   data23_add   ;
wire [16:0]   data24_add   ;
wire [16:0]   data25_add   ;
wire [16:0]   data26_add   ;
wire [16:0]   data27_add   ;
wire [16:0]   data28_add   ;
wire [16:0]   data29_add   ;
wire [16:0]   data30_add   ;
wire [16:0]   data31_add   ;

//------------------------data sel------------------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_0 = i_0[16:0];
		else
			data_0 = i_0[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_0 = i_0[17:1];
		else
			data_0 = i_0[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_0 = i_0[18:2];
		else
			data_0 = i_0[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_0 = i_0[19:3];
		else

			data_0 = i_0[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_0 = i_0[22:6];
	else
		data_0 = i_0[27:11];
end
end
//------------data1-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_1 = i_1[16:0];
		else
			data_1 = i_1[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_1 = i_1[17:1];
		else
			data_1 = i_1[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_1 = i_1[18:2];
		else
			data_1 = i_1[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_1 = i_1[19:3];
		else

			data_1 = i_1[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_1 = i_1[22:6];
	else
		data_1 = i_1[27:11];
end
end

//------------data2-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_2 = i_2[16:0];
		else
			data_2 = i_2[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_2 = i_2[17:1];
		else
			data_2 = i_2[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_2 = i_2[18:2];
		else
			data_2 = i_2[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_2 = i_2[19:3];
		else

			data_2 = i_2[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_2 = i_2[22:6];
	else
		data_2 = i_2[27:11];
end
end

//------------data3-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_3 = i_3[16:0];
		else
			data_3 = i_3[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_3 = i_3[17:1];
		else
			data_3 = i_3[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_3 = i_3[18:2];
		else
			data_3 = i_3[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_3 = i_3[19:3];
		else

			data_3 = i_3[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_3 = i_3[22:6];
	else
		data_3 = i_3[27:11];
end
end

//------------data4-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_4 = i_4[16:0];
		else
			data_4 = i_4[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_4 = i_4[17:1];
		else
			data_4 = i_4[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_4 = i_4[18:2];
		else
			data_4 = i_4[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_4 = i_4[19:3];
		else

			data_4 = i_4[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_4 = i_4[22:6];
	else
		data_4 = i_4[27:11];
end
end

//------------data5-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_5 = i_5[16:0];
		else
			data_5 = i_5[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_5 = i_5[17:1];
		else
			data_5 = i_5[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_5 = i_5[18:2];
		else
			data_5 = i_5[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_5 = i_5[19:3];
		else

			data_5 = i_5[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_5 = i_5[22:6];
	else
		data_5 = i_5[27:11];
end
end

//------------data6-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_6 = i_6[16:0];
		else
			data_6 = i_6[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_6 = i_6[17:1];
		else
			data_6 = i_6[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_6 = i_6[18:2];
		else
			data_6 = i_6[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_6 = i_6[19:3];
		else

			data_6 = i_6[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_6 = i_6[22:6];
	else
		data_6 = i_6[27:11];
end
end

//------------data7-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_7 = i_7[16:0];
		else
			data_7 = i_7[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_7 = i_7[17:1];
		else
			data_7 = i_7[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_7 = i_7[18:2];
		else
			data_7 = i_7[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_7 = i_7[19:3];
		else

			data_7 = i_7[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_7 = i_7[22:6];
	else
		data_7 = i_7[27:11];
end
end

//------------data8-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_8 = i_8[16:0];
		else
			data_8 = i_8[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_8 = i_8[17:1];
		else
			data_8 = i_8[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_8 = i_8[18:2];
		else
			data_8 = i_8[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_8 = i_8[19:3];
		else

			data_8 = i_8[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_8 = i_8[22:6];
	else
		data_8 = i_8[27:11];
end
end

//------------data9-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_9 = i_9[16:0];
		else
			data_9 = i_9[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_9 = i_9[17:1];
		else
			data_9 = i_9[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_9 = i_9[18:2];
		else
			data_9 = i_9[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_9 = i_9[19:3];
		else

			data_9 = i_9[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_9 = i_9[22:6];
	else
		data_9 = i_9[27:11];
end
end

//------------data10-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_10 = i_10[16:0];
		else
			data_10 = i_10[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_10 = i_10[17:1];
		else
			data_10 = i_10[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_10 = i_10[18:2];
		else
			data_10 = i_10[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_10 = i_10[19:3];
		else

			data_10 = i_10[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_10 = i_10[22:6];
	else
		data_10 = i_10[27:11];
end
end

//------------data11-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_11 = i_11[16:0];
		else
			data_11 = i_11[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_11 = i_11[17:1];
		else
			data_11 = i_11[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_11 = i_11[18:2];
		else
			data_11 = i_11[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_11 = i_11[19:3];
		else

			data_11 = i_11[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_11 = i_11[22:6];
	else
		data_11 = i_11[27:11];
end
end

//------------data12-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_12 = i_12[16:0];
		else
			data_12 = i_12[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_12 = i_12[17:1];
		else
			data_12 = i_12[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_12 = i_12[18:2];
		else
			data_12 = i_12[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_12 = i_12[19:3];
		else

			data_12 = i_12[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_12 = i_12[22:6];
	else
		data_12 = i_12[27:11];
end
end

//------------data13-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_13 = i_13[16:0];
		else
			data_13 = i_13[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_13 = i_13[17:1];
		else
			data_13 = i_13[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_13 = i_13[18:2];
		else
			data_13 = i_13[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_13 = i_13[19:3];
		else

			data_13 = i_13[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_13 = i_13[22:6];
	else
		data_13 = i_13[27:11];
end
end

//------------data14-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_14 = i_14[16:0];
		else
			data_14 = i_14[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_14 = i_14[17:1];
		else
			data_14 = i_14[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_14 = i_14[18:2];
		else
			data_14 = i_14[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_14 = i_14[19:3];
		else

			data_14 = i_14[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_14 = i_14[22:6];
	else
		data_14 = i_14[27:11];
end
end

//------------data15-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_15 = i_15[16:0];
		else
			data_15 = i_15[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_15 = i_15[17:1];
		else
			data_15 = i_15[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_15 = i_15[18:2];
		else
			data_15 = i_15[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_15 = i_15[19:3];
		else

			data_15 = i_15[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_15 = i_15[22:6];
	else
		data_15 = i_15[27:11];
end
end

//------------data16-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_16 = i_16[16:0];
		else
			data_16 = i_16[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_16 = i_16[17:1];
		else
			data_16 = i_16[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_16 = i_16[18:2];
		else
			data_16 = i_16[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_16 = i_16[19:3];
		else

			data_16 = i_16[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_16 = i_16[22:6];
	else
		data_16 = i_16[27:11];
end
end

//------------data17-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_17 = i_17[16:0];
		else
			data_17 = i_17[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_17 = i_17[17:1];
		else
			data_17 = i_17[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_17 = i_17[18:2];
		else
			data_17 = i_17[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_17 = i_17[19:3];
		else

			data_17 = i_17[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_17 = i_17[22:6];
	else
		data_17 = i_17[27:11];
end
end

//------------data18-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_18 = i_18[16:0];
		else
			data_18 = i_18[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_18 = i_18[17:1];
		else
			data_18 = i_18[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_18 = i_18[18:2];
		else
			data_18 = i_18[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_18 = i_18[19:3];
		else

			data_18 = i_18[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_18 = i_18[22:6];
	else
		data_18 = i_18[27:11];
end
end

//------------data19-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_19 = i_19[16:0];
		else
			data_19 = i_19[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_19 = i_19[17:1];
		else
			data_19 = i_19[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_19 = i_19[18:2];
		else
			data_19 = i_19[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_19 = i_19[19:3];
		else

			data_19 = i_19[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_19 = i_19[22:6];
	else
		data_19 = i_19[27:11];
end
end

//------------data20-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_20 = i_20[16:0];
		else
			data_20 = i_20[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_20 = i_20[17:1];
		else
			data_20 = i_20[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_20 = i_20[18:2];
		else
			data_20 = i_20[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_20 = i_20[19:3];
		else

			data_20 = i_20[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_20 = i_20[22:6];
	else
		data_20 = i_20[27:11];
end
end

//------------data21-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_21 = i_21[16:0];
		else
			data_21 = i_21[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_21 = i_21[17:1];
		else
			data_21 = i_21[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_21 = i_21[18:2];
		else
			data_21 = i_21[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_21 = i_21[19:3];
		else

			data_21 = i_21[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_21 = i_21[22:6];
	else
		data_21 = i_21[27:11];
end
end

//------------data22-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_22 = i_22[16:0];
		else
			data_22 = i_22[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_22 = i_22[17:1];
		else
			data_22 = i_22[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_22 = i_22[18:2];
		else
			data_22 = i_22[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_22 = i_22[19:3];
		else

			data_22 = i_22[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_22 = i_22[22:6];
	else
		data_22 = i_22[27:11];
end
end

//------------data23-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_23 = i_23[16:0];
		else
			data_23 = i_23[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_23 = i_23[17:1];
		else
			data_23 = i_23[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_23 = i_23[18:2];
		else
			data_23 = i_23[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_23 = i_23[19:3];
		else

			data_23 = i_23[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_23 = i_23[22:6];
	else
		data_23 = i_23[27:11];
end
end

//------------data24-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_24 = i_24[16:0];
		else
			data_24 = i_24[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_24 = i_24[17:1];
		else
			data_24 = i_24[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_24 = i_24[18:2];
		else
			data_24 = i_24[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_24 = i_24[19:3];
		else

			data_24 = i_24[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_24 = i_24[22:6];
	else
		data_24 = i_24[27:11];
end
end

//------------data25-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_25 = i_25[16:0];
		else
			data_25 = i_25[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_25 = i_25[17:1];
		else
			data_25 = i_25[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_25 = i_25[18:2];
		else
			data_25 = i_25[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_25 = i_25[19:3];
		else

			data_25 = i_25[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_25 = i_25[22:6];
	else
		data_25 = i_25[27:11];
end
end

//------------data26-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_26 = i_26[16:0];
		else
			data_26 = i_26[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_26 = i_26[17:1];
		else
			data_26 = i_26[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_26 = i_26[18:2];
		else
			data_26 = i_26[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_26 = i_26[19:3];
		else

			data_26 = i_26[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_26 = i_26[22:6];
	else
		data_26 = i_26[27:11];
end
end

//------------data27-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_27 = i_27[16:0];
		else
			data_27 = i_27[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_27 = i_27[17:1];
		else
			data_27 = i_27[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_27 = i_27[18:2];
		else
			data_27 = i_27[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_27 = i_27[19:3];
		else

			data_27 = i_27[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_27 = i_27[22:6];
	else
		data_27 = i_27[27:11];
end
end

//------------data28-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_28 = i_28[16:0];
		else
			data_28 = i_28[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_28 = i_28[17:1];
		else
			data_28 = i_28[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_28 = i_28[18:2];
		else
			data_28 = i_28[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_28 = i_28[19:3];
		else

			data_28 = i_28[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_28 = i_28[22:6];
	else
		data_28 = i_28[27:11];
end
end

//------------data29-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_29 = i_29[16:0];
		else
			data_29 = i_29[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_29 = i_29[17:1];
		else
			data_29 = i_29[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_29 = i_29[18:2];
		else
			data_29 = i_29[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_29 = i_29[19:3];
		else

			data_29 = i_29[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_29 = i_29[22:6];
	else
		data_29 = i_29[27:11];
end
end

//------------data30-----------//
always @(*) 
begin
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_30 = i_30[16:0];
		else
			data_30 = i_30[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_30 = i_30[17:1];
		else
			data_30 = i_30[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_30 = i_30[18:2];
		else
			data_30 = i_30[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_30 = i_30[19:3];
		else

			data_30 = i_30[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_30 = i_30[22:6];
	else
		data_30 = i_30[27:11];
end
end

//------------data31-----------//
always @(*)
begin 
if(~i_inverse)
begin 
	case(i_transize)
    	DCT_4:
    	begin
		if(~i_row)
			data_31 = i_31[16:0];
		else
			data_31 = i_31[23:7];
	end
     	DCT_8:
    	begin
		if(~i_row)
			data_31 = i_31[17:1];
		else
			data_31 = i_31[24:8];
	end
     	DCT_16:
    	begin
		if(~i_row)
			data_31 = i_31[18:2];
		else
			data_31 = i_31[25:9];
	end
    	DCT_32:
    	begin
		if(~i_row)
			data_31 = i_31[19:3];
		else

			data_31 = i_31[26:10];
	end
  	endcase
end
else
begin
	if(~i_row)
		data_31 = i_31[22:6];
	else
		data_31 = i_31[27:11];
end
end

//-------------------round logic----------------//
assign data0_add  = data_0 + 1'b1;
assign data1_add  = data_1 + 1'b1;
assign data2_add  = data_2 + 1'b1;
assign data3_add  = data_3 + 1'b1;
assign data4_add  = data_4 + 1'b1;
assign data5_add  = data_5 + 1'b1;
assign data6_add  = data_6 + 1'b1;
assign data7_add  = data_7 + 1'b1;
assign data8_add  = data_8 + 1'b1;
assign data9_add  = data_9 + 1'b1;

assign data10_add = data_10 + 1'b1;
assign data11_add = data_11 + 1'b1;
assign data12_add = data_12 + 1'b1;
assign data13_add = data_13 + 1'b1;
assign data14_add = data_14 + 1'b1;
assign data15_add = data_15 + 1'b1;
assign data16_add = data_16 + 1'b1;
assign data17_add = data_17 + 1'b1;
assign data18_add = data_18 + 1'b1;
assign data19_add = data_19 + 1'b1;

assign data20_add = data_20 + 1'b1;
assign data21_add = data_21 + 1'b1;
assign data22_add = data_22 + 1'b1;
assign data23_add = data_23 + 1'b1;
assign data24_add = data_24 + 1'b1;
assign data25_add = data_25 + 1'b1;
assign data26_add = data_26 + 1'b1;
assign data27_add = data_27 + 1'b1;
assign data28_add = data_28 + 1'b1;
assign data29_add = data_29 + 1'b1;

assign data30_add = data_30 + 1'b1;
assign data31_add = data_31 + 1'b1;

//------------------------------------------------//

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_0 <= 16'd0;
	else
		o_0 <= data0_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_1 <= 16'd0;
	else
		o_1 <= data1_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_2 <= 16'd0;
	else
		o_2 <= data2_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_3 <= 16'd0;
	else
		o_3 <= data3_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_4 <= 16'd0;
	else
		o_4 <= data4_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_5 <= 16'd0;
	else
		o_5 <= data5_add[16:1];
end 
 
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_6 <= 16'd0;
	else
		o_6 <= data6_add[16:1];
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_7 <= 16'd0;
	else
		o_7 <= data7_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_8 <= 16'd0;
	else
		o_8 <= data8_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_9 <= 16'd0;
	else
		o_9 <= data9_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_10 <= 16'd0;
	else
		o_10 <= data10_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_11 <= 16'd0;
	else
		o_11 <= data11_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_12 <= 16'd0;
	else
		o_12 <= data12_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_13 <= 16'd0;
	else
		o_13 <= data13_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_14 <= 16'd0;
	else
		o_14 <= data14_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_15 <= 16'd0;
	else
		o_15 <= data15_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_16 <= 16'd0;
	else
		o_16 <= data16_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_17 <= 16'd0;
	else
		o_17 <= data17_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_18 <= 16'd0;
	else
		o_18 <= data18_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_19 <= 16'd0;
	else
		o_19 <= data19_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_20 <= 16'd0;
	else
		o_20 <= data20_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_21 <= 16'd0;
	else
		o_21 <= data21_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_22 <= 16'd0;
	else
		o_22 <= data22_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_23 <= 16'd0;
	else
		o_23 <= data23_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_24 <= 16'd0;
	else
		o_24 <= data24_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_25 <= 16'd0;
	else
		o_25 <= data25_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_26 <= 16'd0;
	else
		o_26 <= data26_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_27 <= 16'd0;
	else
		o_27 <= data27_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_28 <= 16'd0;
	else
		o_28 <= data28_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_29 <= 16'd0;
	else
		o_29 <= data29_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_30 <= 16'd0;
	else
		o_30 <= data30_add[16:1];
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_31 <= 16'd0;
	else
		o_31 <= data31_add[16:1];
end 
//--------------------2d dct out-------------------//

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_2d_dt_vld <= 1'b0;
	else if(i_row)
		o_2d_dt_vld <= i_dt_vld;
	else
		o_2d_dt_vld <= 1'b0;
end 		

 
//--------------------to transosition-------------------//
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_t_dt_vld <= 1'b0;
	else if(~i_row)
		o_t_dt_vld <= i_dt_vld;
	else
		o_t_dt_vld <= 1'b0;
end 		



endmodule
