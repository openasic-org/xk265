//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.08
//file name     : re_level1.v
//delay         : dct32x32,dct16x16:3clk  other: 2clk 
//describe      :
//modification  :
//v1.0          :
module re_level1(
	clk         ,
	rst_n       ,
	i_dt_vld_32 ,
	i_dt_vld_16 ,
	i_dt_vld_8  ,
	i_inverse   ,
	i_data0     ,
	i_data1     ,
	i_data2     ,
	i_data3     ,
	i_data4     ,
	i_data5     ,
	i_data6     ,
	i_data7     ,

	o_data0     ,
	o_data1     ,
	o_data2     ,
	o_data3     ,
	o_data4     ,
	o_data5     ,
	o_data6     ,
	o_data7     
);

input	        clk            ; 
input	        rst_n          ; 
input	        i_dt_vld_32    ; 
input	        i_dt_vld_16    ; 
input	        i_dt_vld_8     ;
input	        i_inverse      ; 
input [17:0]	i_data0        ; 
input [17:0]	i_data1        ; 
input [17:0]	i_data2        ; 
input [17:0]	i_data3        ; 
input [17:0]	i_data4        ; 
input [17:0]	i_data5        ; 
input [17:0]	i_data6        ; 
input [17:0]	i_data7        ; 

output [27:0]	o_data0    ; 
output [27:0]	o_data1    ; 
output [27:0]	o_data2    ; 
output [27:0]	o_data3    ; 
output [27:0]	o_data4    ; 
output [27:0]	o_data5    ; 
output [27:0]	o_data6    ; 
output [27:0]	o_data7    ; 
//--------------delay----------------//
reg             dt_vld_32_d ;
reg             dt_vld_16_d ;
reg    [1:0]    dt_vld_8_d  ;

//--------------------------------------------------------------------------------------------//
wire [25:0]        data0_r8_9      ;
wire [25:0]        data0_r8_25     ;
wire [25:0]        data0_r8_43     ;
wire [25:0]        data0_r8_57     ;
wire [25:0]        data0_r8_70     ;
wire [25:0]        data0_r8_80     ;
wire [25:0]        data0_r8_87     ;
wire [25:0]        data0_r8_90     ;
//
wire [25:0]        data0_r4_18     ;
wire [25:0]        data0_r4_50     ;
wire [25:0]        data0_r4_75     ;
wire [25:0]        data0_r4_89     ;
//
wire [25:0]        data0_a4_64     ;
wire [25:0]        data0_a4_36     ;
wire [25:0]        data0_a4_83     ;
//-----------------------col1--------------------//
wire [25:0]        data1_r8_9      ;
wire [25:0]        data1_r8_25     ;
wire [25:0]        data1_r8_43     ;
wire [25:0]        data1_r8_57     ;
wire [25:0]        data1_r8_70     ;
wire [25:0]        data1_r8_80     ;
wire [25:0]        data1_r8_87     ;
wire [25:0]        data1_r8_90     ;
//
wire [25:0]        data1_r4_18     ;
wire [25:0]        data1_r4_50     ;
wire [25:0]        data1_r4_75     ;
wire [25:0]        data1_r4_89     ;
//
wire [25:0]        data1_a4_64     ;
wire [25:0]        data1_a4_36     ;
wire [25:0]        data1_a4_83     ;

//-----------------------col2--------------------//
wire [25:0]        data2_r8_9      ;
wire [25:0]        data2_r8_25     ;
wire [25:0]        data2_r8_43     ;
wire [25:0]        data2_r8_57     ;
wire [25:0]        data2_r8_70     ;
wire [25:0]        data2_r8_80     ;
wire [25:0]        data2_r8_87     ;
wire [25:0]        data2_r8_90     ;
//
wire [25:0]        data2_r4_18     ;
wire [25:0]        data2_r4_50     ;
wire [25:0]        data2_r4_75     ;
wire [25:0]        data2_r4_89     ;
//
wire [25:0]        data2_a4_64     ;
wire [25:0]        data2_a4_36     ;
wire [25:0]        data2_a4_83     ;

//-----------------------col3--------------------//
wire [25:0]        data3_r8_9      ;
wire [25:0]        data3_r8_25     ;
wire [25:0]        data3_r8_43     ;
wire [25:0]        data3_r8_57     ;
wire [25:0]        data3_r8_70     ;
wire [25:0]        data3_r8_80     ;
wire [25:0]        data3_r8_87     ;
wire [25:0]        data3_r8_90     ;
//
wire [25:0]        data3_r4_18     ;
wire [25:0]        data3_r4_50     ;
wire [25:0]        data3_r4_75     ;
wire [25:0]        data3_r4_89     ;
//
wire [25:0]        data3_a4_64     ;
wire [25:0]        data3_a4_36     ;
wire [25:0]        data3_a4_83     ;

//-----------------------col4--------------------//
wire [25:0]        data4_r8_9      ;
wire [25:0]        data4_r8_25     ;
wire [25:0]        data4_r8_43     ;
wire [25:0]        data4_r8_57     ;
wire [25:0]        data4_r8_70     ;
wire [25:0]        data4_r8_80     ;
wire [25:0]        data4_r8_87     ;
wire [25:0]        data4_r8_90     ;
//
wire [25:0]        data4_r4_18     ;
wire [25:0]        data4_r4_50     ;
wire [25:0]        data4_r4_75     ;
wire [25:0]        data4_r4_89     ;
//
wire [25:0]        data4_a4_64     ;
wire [25:0]        data4_a4_36     ;
wire [25:0]        data4_a4_83     ;
//-----------------------col5--------------------//
wire [25:0]        data5_r8_9      ;
wire [25:0]        data5_r8_25     ;
wire [25:0]        data5_r8_43     ;
wire [25:0]        data5_r8_57     ;
wire [25:0]        data5_r8_70     ;
wire [25:0]        data5_r8_80     ;
wire [25:0]        data5_r8_87     ;
wire [25:0]        data5_r8_90     ;
//
wire [25:0]        data5_r4_18     ;
wire [25:0]        data5_r4_50     ;
wire [25:0]        data5_r4_75     ;
wire [25:0]        data5_r4_89     ;
//
wire [25:0]        data5_a4_64     ;
wire [25:0]        data5_a4_36     ;
wire [25:0]        data5_a4_83     ;
//-----------------------col6--------------------//
wire [25:0]        data6_r8_9      ;
wire [25:0]        data6_r8_25     ;
wire [25:0]        data6_r8_43     ;
wire [25:0]        data6_r8_57     ;
wire [25:0]        data6_r8_70     ;
wire [25:0]        data6_r8_80     ;
wire [25:0]        data6_r8_87     ;
wire [25:0]        data6_r8_90     ;
//
wire [25:0]        data6_r4_18     ;
wire [25:0]        data6_r4_50     ;
wire [25:0]        data6_r4_75     ;
wire [25:0]        data6_r4_89     ;
//
wire [25:0]        data6_a4_64     ;
wire [25:0]        data6_a4_36     ;
wire [25:0]        data6_a4_83     ;
//-----------------------col7--------------------//
//
wire [25:0]        data7_r8_9      ;
wire [25:0]        data7_r8_25     ;
wire [25:0]        data7_r8_43     ;
wire [25:0]        data7_r8_57     ;
wire [25:0]        data7_r8_70     ;
wire [25:0]        data7_r8_80     ;
wire [25:0]        data7_r8_87     ;
wire [25:0]        data7_r8_90     ;
//
wire [25:0]        data7_r4_18     ;
wire [25:0]        data7_r4_50     ;
wire [25:0]        data7_r4_75     ;
wire [25:0]        data7_r4_89     ;
//
wire [25:0]        data7_a4_64     ;
wire [25:0]        data7_a4_36     ;
wire [25:0]        data7_a4_83     ;
//
//----------o_data0----------------//
reg [25:0]        data00;
reg [25:0]        data01;
reg [25:0]        data02;
reg [25:0]        data03;
reg [25:0]        data04;
reg [25:0]        data05;
reg [25:0]        data06;
reg [25:0]        data07;

wire [26:0]       data0_01     ;
wire [26:0]       data0_23     ;
reg  [27:0]       data00_stp0  ;
wire [26:0]       data0_45     ;
wire [26:0]       data0_67     ;
reg  [27:0]       data01_stp0  ;
wire [27:0]       data001_stp0 ;
reg  [27:0]       data00_stp1  ;
reg  [27:0]       o_data0      ;

//----------o_data1----------------//
reg [25:0]        data10;
reg [25:0]        data11;
reg [25:0]        data12;
reg [25:0]        data13;
reg [25:0]        data14;
reg [25:0]        data15;
reg [25:0]        data16;
reg [25:0]        data17;

wire [26:0]       data1_01     ;
wire [26:0]       data1_23     ;
reg  [27:0]       data10_stp0  ;
wire [26:0]       data1_45     ;
wire [26:0]       data1_67     ;
reg  [27:0]       data11_stp0  ;
wire [27:0]       data101_stp0 ;
reg  [27:0]       data10_stp1  ;
reg  [27:0]       o_data1      ;

//----------o_data2----------------//
reg [25:0]        data20;
reg [25:0]        data21;
reg [25:0]        data22;
reg [25:0]        data23;
reg [25:0]        data24;
reg [25:0]        data25;
reg [25:0]        data26;
reg [25:0]        data27;

wire [26:0]       data2_01     ;
wire [26:0]       data2_23     ;
reg  [27:0]       data20_stp0  ;
wire [26:0]       data2_45     ;
wire [26:0]       data2_67     ;
reg  [27:0]       data21_stp0  ;
wire [27:0]       data201_stp0 ;
reg  [27:0]       data20_stp1  ;
reg  [27:0]       o_data2      ;
//----------o_data3----------------//
reg [25:0]        data30;
reg [25:0]        data31;
reg [25:0]        data32;
reg [25:0]        data33;
reg [25:0]        data34;
reg [25:0]        data35;
reg [25:0]        data36;
reg [25:0]        data37;

wire [26:0]       data3_01     ;
wire [26:0]       data3_23     ;
reg  [27:0]       data30_stp0  ;
wire [26:0]       data3_45     ;
wire [26:0]       data3_67     ;
reg  [27:0]       data31_stp0  ;
wire [27:0]       data301_stp0 ;
reg  [27:0]       data30_stp1  ;
reg  [27:0]       o_data3      ;
//----------o_data4----------------//
reg [25:0]        data40;
reg [25:0]        data41;
reg [25:0]        data42;
reg [25:0]        data43;
reg [25:0]        data44;
reg [25:0]        data45;
reg [25:0]        data46;
reg [25:0]        data47;

wire [26:0]       data4_01     ;
wire [26:0]       data4_23     ;
reg  [27:0]       data40_stp0  ;
wire [26:0]       data4_45     ;
wire [26:0]       data4_67     ;
reg  [27:0]       data41_stp0  ;
wire [27:0]       data401_stp0 ;
reg  [27:0]       data40_stp1  ;
reg  [27:0]       o_data4      ;
//----------o_data5----------------//
reg [25:0]        data50;
reg [25:0]        data51;
reg [25:0]        data52;
reg [25:0]        data53;
reg [25:0]        data54;
reg [25:0]        data55;
reg [25:0]        data56;
reg [25:0]        data57;

wire [26:0]       data5_01     ;
wire [26:0]       data5_23     ;
reg  [27:0]       data50_stp0  ;
wire [26:0]       data5_45     ;
wire [26:0]       data5_67     ;
reg  [27:0]       data51_stp0  ;
wire [27:0]       data501_stp0 ;
reg  [27:0]       data50_stp1  ;
reg  [27:0]       o_data5      ;
//----------o_data6----------------//
reg [25:0]        data60;
reg [25:0]        data61;
reg [25:0]        data62;
reg [25:0]        data63;
reg [25:0]        data64;
reg [25:0]        data65;
reg [25:0]        data66;
reg [25:0]        data67;

wire [26:0]       data6_01     ;
wire [26:0]       data6_23     ;
reg  [27:0]       data60_stp0  ;
wire [26:0]       data6_45     ;
wire [26:0]       data6_67     ;
reg  [27:0]       data61_stp0  ;
wire [27:0]       data601_stp0 ;
reg  [27:0]       data60_stp1  ;
reg  [27:0]       o_data6      ;
//----------o_data0----------------//
reg [25:0]        data70;
reg [25:0]        data71;
reg [25:0]        data72;
reg [25:0]        data73;
reg [25:0]        data74;
reg [25:0]        data75;
reg [25:0]        data76;
reg [25:0]        data77;

wire [26:0]       data7_01     ;
wire [26:0]       data7_23     ;
reg  [27:0]       data70_stp0  ;
wire [26:0]       data7_45     ;
wire [26:0]       data7_67     ;
reg  [27:0]       data71_stp0  ;
wire [27:0]       data701_stp0 ;
reg  [27:0]       data70_stp1  ;
reg  [27:0]       o_data7      ;
//-------------------------------------------------------------delay
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		dt_vld_32_d <= 1'd0;
	else	
		dt_vld_32_d <= i_dt_vld_32;	
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		dt_vld_16_d <= 1'd0;
	else	
		dt_vld_16_d <= i_dt_vld_16;	
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		dt_vld_8_d <= 2'd0;
	else	
		dt_vld_8_d <= {dt_vld_8_d[0],i_dt_vld_8};	
end 

//----------o_data0----------------//
always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data00 =  data0_r8_9 ;
			data01 =  data1_r8_25;
			data02 =  data2_r8_43;
			data03 =  data3_r8_57;
			data04 =  data4_r8_70;
			data05 =  data5_r8_80;
			data06 =  data6_r8_87;
			data07 =  data7_r8_90;
		end
	else if(dt_vld_16_d)
		begin
			data00 =  data0_r4_18;
			data01 =  data1_r4_50;
			data02 =  data2_r4_75;
			data03 =  data3_r4_89;
                        data04 =  26'd0;         
                        data05 =  26'd0;
                        data06 =  26'd0;
                        data07 =  26'd0;
		end
	else
		begin
			data00 =  data0_a4_64;
			data01 =  data1_a4_64;
			data02 =  data2_a4_64;
			data03 =  data3_a4_64;
                        data04 =  26'd0;         
                        data05 =  26'd0;
                        data06 =  26'd0;
                        data07 =  26'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data00 =   data0_r8_9 ;
			data01 =  ~data1_r8_25 + 1'b1;
			data02 =   data2_r8_43;
			data03 =  ~data3_r8_57 + 1'b1;
			data04 =   data4_r8_70;
			data05 =  ~data5_r8_80 + 1'b1;
			data06 =   data6_r8_87;
			data07 =  ~data7_r8_90 + 1'b1;
		end
	else if(dt_vld_16_d)
		begin
			data00 =   data0_r4_18;
			data01 =  ~data1_r4_50 + 1'b1;
			data02 =   data2_r4_75;
			data03 =  ~data3_r4_89 + 1'b1;
                        data04 =  26'd0;         
                        data05 =  26'd0;
                        data06 =  26'd0;
                        data07 =  26'd0;
		end
	else
		begin
			data00 =  data0_a4_64;
			data01 =  data1_a4_83;
			data02 =  data2_a4_64;
			data03 =  data3_a4_36;
                        data04 =  26'd0;         
                        data05 =  26'd0;
                        data06 =  26'd0;
                        data07 =  26'd0;
		end	
	end
end

assign data0_01 = {data00[25],data00} + {data01[25],data01};  
assign data0_23 = {data02[25],data02} + {data03[25],data03};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data00_stp0 <= 28'd0;
	else
		data00_stp0 <= {data0_01[26],data0_01} + {data0_23[26],data0_23};
end 

assign data0_45 = {data04[25],data04} + {data05[25],data05};
assign data0_67 = {data06[25],data06} + {data07[25],data07};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data01_stp0 <= 28'd0;
	else
		data01_stp0 <= {data0_45[26],data0_45} + {data0_67[26],data0_67};
end 
 
assign data001_stp0 = data00_stp0 + data01_stp0;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data00_stp1 <= 28'd0;
	else
		data00_stp1 <= data001_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1])
		o_data0 = data00_stp0;
	else 
		o_data0 = data00_stp1;
end 

//------------------------------------------o_data1--------------------------------------------------------//
always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data10 =  ~data0_r8_25 + 1'b1 ;
			data11 =  ~data1_r8_70 + 1'b1;
			data12 =  ~data2_r8_90 + 1'b1;
			data13 =  ~data3_r8_80 + 1'b1;
			data14 =  ~data4_r8_43 + 1'b1;
			data15 =   data5_r8_9 ;
			data16 =   data6_r8_57;
			data17 =   data7_r8_87;
		end
	else if(dt_vld_16_d)
		begin
			data10 =  ~data0_r4_50 + 1'b1;
			data11 =  ~data1_r4_89 + 1'b1;
			data12 =  ~data2_r4_18 + 1'b1;
			data13 =   data3_r4_75;
                        data14 =  26'd0;         
                        data15 =  26'd0;
                        data16 =  26'd0;
                        data17 =  26'd0;
		end
	else
		begin
			data10 =   data0_a4_83;
			data11 =   data1_a4_36;
			data12 =  ~data2_a4_36 + 1'b1;
			data13 =  ~data3_a4_83 + 1'b1;
			data14 =  26'd0;
			data15 =  26'd0;
			data16 =  26'd0;
			data17 =  26'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data10 =   data0_r8_25 ;
			data11 =  ~data1_r8_70 + 1'b1;
			data12 =   data2_r8_90;
			data13 =  ~data3_r8_80 + 1'b1;
			data14 =   data4_r8_43;
			data15 =   data5_r8_9;
			data16 =  ~data6_r8_57 + 1'b1;
			data17 =   data7_r8_87;
		end
	else if(dt_vld_16_d)
		begin
			data10 =   data0_r4_50;
			data11 =  ~data1_r4_89 + 1'b1;
			data12 =   data2_r4_18;
			data13 =   data3_r4_75;
                        data14 =  26'd0;         
                        data15 =  26'd0;
                        data16 =  26'd0;
                        data17 =  26'd0;
		end
	else 
		begin
			data10 =   data0_a4_64;
			data11 =   data1_a4_36;
			data12 =  ~data2_a4_64 + 1'b1;
			data13 =  ~data3_a4_83 + 1'b1;
			data14 =  26'd0;
			data15 =  26'd0;
			data16 =  26'd0;
			data17 =  26'd0;
		end	
	end
end 

assign data1_01 = {data10[25],data10} + {data11[25],data11};  
assign data1_23 = {data12[25],data12} + {data13[25],data13};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data10_stp0 <= 28'd0;
	else
		data10_stp0 <= {data1_01[26],data1_01} + {data1_23[26],data1_23};
end 

assign data1_45 = {data14[25],data14} + {data15[25],data15};
assign data1_67 = {data16[25],data16} + {data17[25],data17};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data11_stp0 <= 28'd0;
	else
		data11_stp0 <= {data1_45[26],data1_45} + {data1_67[26],data1_67};
end 
 
assign data101_stp0 = data10_stp0 + data11_stp0;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data10_stp1 <= 28'd0;
	else
		data10_stp1 <= data101_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1])
		o_data1 = data10_stp0;
	else 
		o_data1 = data10_stp1;
end 

//------------------------------------------o_data2--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data20 =   data0_r8_43;
			data21 =   data1_r8_90;
			data22 =   data2_r8_57;
			data23 =  ~data3_r8_25 + 1'b1;
			data24 =  ~data4_r8_87 + 1'b1;
			data25 =  ~data5_r8_70 + 1'b1 ;
			data26 =   data6_r8_9;
			data27 =   data7_r8_80;
		end
	else if(dt_vld_16_d)
		begin
			data20 =   data0_r4_75;
			data21 =   data1_r4_18;
			data22 =  ~data2_r4_89 + 1'b1;
			data23 =   data3_r4_50;
                        data24 =  26'd0;         
                        data25 =  26'd0;
                        data26 =  26'd0;
                        data27 =  26'd0;
		end
	else
		begin
			data20 =   data0_a4_64;
			data21 =  ~data1_a4_64 + 1'b1;
			data22 =  ~data2_a4_64 + 1'b1;
			data23 =   data3_a4_64;
			data24 =  26'd0;
			data25 =  26'd0;
			data26 =  26'd0;
			data27 =  26'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data20 =   data0_r8_43 ;
			data21 =  ~data1_r8_90 + 1'b1;
			data22 =   data2_r8_57;
			data23 =   data3_r8_25;
			data24 =  ~data4_r8_87 + 1'b1;
			data25 =   data5_r8_70;
			data26 =   data6_r8_9;
			data27 =  ~data7_r8_80 + 1'b1;
		end
	else if(dt_vld_16_d)
		begin
			data20 =   data0_r4_75;
			data21 =  ~data1_r4_18 + 1'b1;
			data22 =  ~data2_r4_89 + 1'b1;
			data23 =  ~data3_r4_50 + 1'b1;
                        data24 =  26'd0;         
                        data25 =  26'd0;
                        data26 =  26'd0;
                        data27 =  26'd0;
		end
	else
		begin
			data20 =   data0_a4_64;
			data21 =  ~data1_a4_36 + 1'b1;
			data22 =  ~data2_a4_64 + 1'b1;
			data23 =   data3_a4_83;
			data24 =  26'd0;
			data25 =  26'd0;
			data26 =  26'd0;
			data27 =  26'd0;
		end	
	end
end 

assign data2_01 = {data20[25],data20} + {data21[25],data21};  
assign data2_23 = {data22[25],data22} + {data23[25],data23};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data20_stp0 <= 28'd0;
	else
		data20_stp0 <= {data2_01[26],data2_01} + {data2_23[26],data2_23};
end 

assign data2_45 = {data24[25],data24} + {data25[25],data25};
assign data2_67 = {data26[25],data26} + {data27[25],data27};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data21_stp0 <= 28'd0;
	else
		data21_stp0 <= {data2_45[26],data2_45} + {data2_67[26],data2_67};
end 
 
assign data201_stp0 = data20_stp0 + data21_stp0;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data20_stp1 <= 28'd0;
	else
		data20_stp1 <= data201_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1])
		o_data2 = data20_stp0;
	else 
		o_data2 = data20_stp1;
end 

//------------------------------------------o_data3--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data30 =  ~data0_r8_57 + 1'b1 ;
			data31 =  ~data1_r8_80 + 1'b1;
			data32 =   data2_r8_25;
			data33 =   data3_r8_90;
			data34 =   data4_r8_9;
			data35 =  ~data5_r8_87 + 1'b1;
			data36 =  ~data6_r8_43 + 1'b1;
			data37 =   data7_r8_70;
		end
	else if(dt_vld_16_d)
		begin
			data30 =  ~data0_r4_89 + 1'b1;
			data31 =   data1_r4_75;
			data32 =  ~data2_r4_50 + 1'b1;
			data33 =   data3_r4_18;
                        data34 =  26'd0;         
                        data35 =  26'd0;
                        data36 =  26'd0;
                        data37 =  26'd0;
		end
	else
		begin
			data30 =   data0_a4_36;
			data31 =  ~data1_a4_83 + 1'b1;
			data32 =   data2_a4_83;
			data33 =  ~data3_a4_36 + 1'b1;
			data34 =  26'd0;
			data35 =  26'd0;
			data36 =  26'd0;
			data37 =  26'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data30 =   data0_r8_57 ;
			data31 =  ~data1_r8_80 + 1'b1;
			data32 =  ~data2_r8_25 + 1'b1;
			data33 =   data3_r8_90;
			data34 =  ~data4_r8_9 + 1'b1;
			data35 =  ~data5_r8_87 + 1'b1;
			data36 =   data6_r8_43;
			data37 =   data7_r8_70;
		end
	else if(dt_vld_16_d)
		begin
			data30 =  data0_r4_89;
			data31 =  data1_r4_75;
			data32 =  data2_r4_50;
			data33 =  data3_r4_18;
                        data34 =  26'd0;         
                        data35 =  26'd0;
                        data36 =  26'd0;
                        data37 =  26'd0;
		end
	else
		begin
			data30 =   data0_a4_64;
			data31 =  ~data1_a4_83 + 1'b1;
			data32 =   data2_a4_64;
			data33 =  ~data3_a4_36 + 1'b1;
			data34 =  26'd0;
			data35 =  26'd0;
			data36 =  26'd0;
			data37 =  26'd0;
		end	
	end
end 

assign data3_01 = {data30[25],data30} + {data31[25],data31};  
assign data3_23 = {data32[25],data32} + {data33[25],data33};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data30_stp0 <= 28'd0;
	else
		data30_stp0 <= {data3_01[26],data3_01} + {data3_23[26],data3_23};
end 

assign data3_45 = {data34[25],data34} + {data35[25],data35};
assign data3_67 = {data36[25],data36} + {data37[25],data37};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data31_stp0 <= 28'd0;
	else
		data31_stp0 <= {data3_45[26],data3_45} + {data3_67[26],data3_67};
end 
 
assign data301_stp0 = data30_stp0 + data31_stp0;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data30_stp1 <= 28'd0;
	else
		data30_stp1 <= data301_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1])
		o_data3 = data30_stp0;
	else 
		o_data3 = data30_stp1;
end 
//------------------------------------------o_data4--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data40 =   data0_r8_70;
			data41 =   data1_r8_43;
			data42 =  ~data2_r8_87 + 1'b1;
			data43 =  ~data3_r8_9 + 1'b1;
			data44 =   data4_r8_90;
			data45 =  ~data5_r8_25 + 1'b1;
			data46 =  ~data6_r8_80 + 1'b1;
			data47 =   data7_r8_57;
		end
	else if(dt_vld_16_d)
		begin
			data40 =  data4_r4_18;
			data41 =  data5_r4_50;
			data42 =  data6_r4_75;
			data43 =  data7_r4_89;
                        data44 =  26'd0;         
                        data45 =  26'd0;
                        data46 =  26'd0;
                        data47 =  26'd0;
		end
	else
		begin
			data40 =  data4_a4_64;
			data41 =  data5_a4_64;
			data42 =  data6_a4_64;
			data43 =  data7_a4_64;
			data44 =  26'd0;
			data45 =  26'd0;
			data46 =  26'd0;
			data47 =  26'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data40 =   data0_r8_70 ;
			data41 =  ~data1_r8_43 + 1'b1;
			data42 =  ~data2_r8_87 + 1'b1;
			data43 =   data3_r8_9;
			data44 =   data4_r8_90;
			data45 =   data5_r8_25;
			data46 =  ~data6_r8_80 + 1'b1;
			data47 =  ~data7_r8_57 + 1'b1;
		end
	else if(dt_vld_16_d)
		begin
			data40 =   data4_r4_18;
			data41 =  ~data5_r4_50 + 1'b1;
			data42 =   data6_r4_75;
			data43 =  ~data7_r4_89 + 1'b1;
                        data44 =  26'd0;         
                        data45 =  26'd0;
                        data46 =  26'd0;
                        data47 =  26'd0;
		end
	else
		begin
			data40 =  data4_a4_64;
			data41 =  data5_a4_83;
			data42 =  data6_a4_64;
			data43 =  data7_a4_36;
			data44 =  26'd0;
			data45 =  26'd0;
			data46 =  26'd0;
			data47 =  26'd0;
		end	
	end
end 

assign data4_01 = {data40[25],data40} + {data41[25],data41};  
assign data4_23 = {data42[25],data42} + {data43[25],data43};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data40_stp0 <= 28'd0;
	else
		data40_stp0 <= {data4_01[26],data4_01} + {data4_23[26],data4_23};
end 

assign data4_45 = {data44[25],data44} + {data45[25],data45};
assign data4_67 = {data46[25],data46} + {data47[25],data47};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data41_stp0 <= 28'd0;
	else
		data41_stp0 <= {data4_45[26],data4_45} + {data4_67[26],data4_67};
end 
 
assign data401_stp0 = data40_stp0 + data41_stp0;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data40_stp1 <= 28'd0;
	else
		data40_stp1 <= data401_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1])
		o_data4 = data40_stp0;
	else 
		o_data4 = data40_stp1;
end 

//------------------------------------------o_data5--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data50 =  ~data0_r8_80 + 1'b1;
			data51 =   data1_r8_9;
			data52 =   data2_r8_70;
			data53 =  ~data3_r8_87 + 1'b1;
			data54 =   data4_r8_25;
			data55 =   data5_r8_57;
			data56 =  ~data6_r8_90 + 1'b1;
			data57 =   data7_r8_43;
		end
	else if(dt_vld_16_d)
		begin
			data50 =  ~data4_r4_50 + 1'b1;
			data51 =  ~data5_r4_89 + 1'b1;
			data52 =  ~data6_r4_18 + 1'b1;
			data53 =   data7_r4_75;
                        data54 =  26'd0;         
                        data55 =  26'd0;
                        data56 =  26'd0;
                        data57 =  26'd0;
		end
	else
		begin
			data50 =   data4_a4_83;
			data51 =   data5_a4_36;
			data52 =  ~data6_a4_36 + 1'b1;
			data53 =  ~data7_a4_83 + 1'b1;
			data54 =  26'd0;
			data55 =  26'd0;
			data56 =  26'd0;
			data57 =  26'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data50 =   data0_r8_80 ;
			data51 =   data1_r8_9;
			data52 =  ~data2_r8_70 + 1'b1;
			data53 =  ~data3_r8_87 + 1'b1;
			data54 =  ~data4_r8_25 + 1'b1;
			data55 =   data5_r8_57;
			data56 =   data6_r8_90;
			data57 =   data7_r8_43;
		end
	else if(dt_vld_16_d)
		begin
			data50 =   data4_r4_50;
			data51 =  ~data5_r4_89 + 1'b1;
			data52 =   data6_r4_18;
			data53 =   data7_r4_75;
                        data54 =  26'd0;         
                        data55 =  26'd0;
                        data56 =  26'd0;
                        data57 =  26'd0;
		end
	else
		begin
			data50 =   data4_a4_64;
			data51 =   data5_a4_36;
			data52 =  ~data6_a4_64 + 1'b1;
			data53 =  ~data7_a4_83 + 1'b1;
			data54 =  26'd0;
			data55 =  26'd0;
			data56 =  26'd0;
			data57 =  26'd0;
		end	
	end
end 

assign data5_01 = {data50[25],data50} + {data51[25],data51};  
assign data5_23 = {data52[25],data52} + {data53[25],data53};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data50_stp0 <= 28'd0;
	else
		data50_stp0 <= {data5_01[26],data5_01} + {data5_23[26],data5_23};
end 

assign data5_45 = {data54[25],data54} + {data55[25],data55};
assign data5_67 = {data56[25],data56} + {data57[25],data57};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data51_stp0 <= 28'd0;
	else
		data51_stp0 <= {data5_45[26],data5_45} + {data5_67[26],data5_67};
end 
 
assign data501_stp0 = data50_stp0 + data51_stp0;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data50_stp1 <= 28'd0;
	else
		data50_stp1 <= data501_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1])
		o_data5 = data50_stp0;
	else 
		o_data5 = data50_stp1;
end 
//------------------------------------------o_data6--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data60 =   data0_r8_87;
			data61 =  ~data1_r8_57 + 1'b1;
			data62 =   data2_r8_9;
			data63 =   data3_r8_43;
			data64 =  ~data4_r8_80 + 1'b1;
			data65 =   data5_r8_90;
			data66 =  ~data6_r8_70 + 1'b1;
			data67 =   data7_r8_25;
		end
	else if(dt_vld_16_d)
		begin
			data60 =   data4_r4_75;
			data61 =   data5_r4_18;
			data62 =  ~data6_r4_89 + 1'b1;
			data63 =   data7_r4_50;
                        data64 =  26'd0;         
                        data65 =  26'd0;
                        data66 =  26'd0;
                        data67 =  26'd0;
		end
	else
		begin
			data60 =   data4_a4_64;
			data61 =  ~data5_a4_64 + 1'b1;
			data62 =  ~data6_a4_64 + 1'b1;
			data63 =   data7_a4_64;
			data64 =  26'd0;
			data65 =  26'd0;
			data66 =  26'd0;
			data67 =  26'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data60 =   data0_r8_87 ;
			data61 =   data1_r8_57;
			data62 =   data2_r8_9;
			data63 =  ~data3_r8_43 + 1'b1;
			data64 =  ~data4_r8_80 + 1'b1;
			data65 =  ~data5_r8_90 + 1'b1;
			data66 =  ~data6_r8_70 + 1'b1;
			data67 =  ~data7_r8_25 + 1'b1;
		end
	else if(dt_vld_16_d)
		begin
			data60 =   data4_r4_75;
			data61 =  ~data5_r4_18 + 1'b1;
			data62 =  ~data6_r4_89 + 1'b1;
			data63 =  ~data7_r4_50 + 1'b1;
                        data64 =  26'd0;         
                        data65 =  26'd0;
                        data66 =  26'd0;
                        data67 =  26'd0;
		end
	else
		begin
			data60 =   data4_a4_64;
			data61 =  ~data5_a4_36 + 1'b1;
			data62 =  ~data6_a4_64 + 1'b1;
			data63 =   data7_a4_83;
			data64 =  26'd0;
			data65 =  26'd0;
			data66 =  26'd0;
			data67 =  26'd0;
		end	
	end
end 

assign data6_01 = {data60[25],data60} + {data61[25],data61};  
assign data6_23 = {data62[25],data62} + {data63[25],data63};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data60_stp0 <= 28'd0;
	else
		data60_stp0 <= {data6_01[26],data6_01} + {data6_23[26],data6_23};
end 

assign data6_45 = {data64[25],data64} + {data65[25],data65};
assign data6_67 = {data66[25],data66} + {data67[25],data67};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data61_stp0 <= 28'd0;
	else
		data61_stp0 <= {data6_45[26],data6_45} + {data6_67[26],data6_67};
end 
 
assign data601_stp0 = data60_stp0 + data61_stp0;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data60_stp1 <= 28'd0;
	else
		data60_stp1 <= data601_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1])
		o_data6 = data60_stp0;
	else 
		o_data6 = data60_stp1;
end 

//------------------------------------------o_data7--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data70 =  ~data0_r8_90 + 1'b1;
			data71 =   data1_r8_87;
			data72 =  ~data2_r8_80 + 1'b1;
			data73 =   data3_r8_70;
			data74 =  ~data4_r8_57 + 1'b1;
			data75 =   data5_r8_43;
			data76 =  ~data6_r8_25 + 1'b1;
			data77 =   data7_r8_9;
		end
	else if(dt_vld_16_d)
		begin
			data70 =  ~data4_r4_89 + 1'b1;
			data71 =   data5_r4_75;
			data72 =  ~data6_r4_50 + 1'b1;
			data73 =   data7_r4_18;
                        data74 =  26'd0;         
                        data75 =  26'd0;
                        data76 =  26'd0;
                        data77 =  26'd0;
		end
	else
		begin
			data70 =   data4_a4_36;
			data71 =  ~data5_a4_83 + 1'b1;
			data72 =   data6_a4_83;
			data73 =  ~data7_a4_36 + 1'b1;
			data74 =  26'd0;
			data75 =  26'd0;
			data76 =  26'd0;
			data77 =  26'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data70 =  data0_r8_90;
			data71 =  data1_r8_87;
			data72 =  data2_r8_80;
			data73 =  data3_r8_70;
			data74 =  data4_r8_57;
			data75 =  data5_r8_43;
			data76 =  data6_r8_25;
			data77 =  data7_r8_9;
		end
	else if(dt_vld_16_d)
		begin
			data70 =  data4_r4_89;
			data71 =  data5_r4_75;
			data72 =  data6_r4_50;
			data73 =  data7_r4_18;
                        data74 =  26'd0;         
                        data75 =  26'd0;
                        data76 =  26'd0;
                        data77 =  26'd0;
		end
	else
		begin
			data70 =   data4_a4_64;
			data71 =  ~data5_a4_83 + 1'b1;
			data72 =   data6_a4_64;
			data73 =  ~data7_a4_36 + 1'b1;
			data74 =  26'd0;
			data75 =  26'd0;
			data76 =  26'd0;
			data77 =  26'd0;
		end	
	end
end 

assign data7_01 = {data70[25],data70} + {data71[25],data71};  
assign data7_23 = {data72[25],data72} + {data73[25],data73};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data70_stp0 <= 28'd0;
	else
		data70_stp0 <= {data7_01[26],data7_01} + {data7_23[26],data7_23};
end 

assign data7_45 = {data74[25],data74} + {data75[25],data75};
assign data7_67 = {data76[25],data76} + {data77[25],data77};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data71_stp0 <= 28'd0;
	else
		data71_stp0 <= {data7_45[26],data7_45} + {data7_67[26],data7_67};
end 
 
assign data701_stp0 = data70_stp0 + data71_stp0;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data70_stp1 <= 28'd0;
	else
		data70_stp1 <= data701_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1])
		o_data7 = data70_stp0;
	else 
		o_data7 = data70_stp1;
end 

//--------------------------------------------------------------------------------------------//
re_level1_cal     u0_level1_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld_32    (i_dt_vld_32),//data valid
	.i_dt_vld_16    (i_dt_vld_16),//data valid
	.i_dt_vld_8     (i_dt_vld_8 ),//data valid
	.i_data	        (i_data0    ),
//-------------r8---------//
	.o_data_r8_9    (data0_r8_9  ),    
        .o_data_r8_25   (data0_r8_25 ),
        .o_data_r8_43   (data0_r8_43 ),
        .o_data_r8_57   (data0_r8_57 ),
        .o_data_r8_70   (data0_r8_70 ),
        .o_data_r8_80   (data0_r8_80 ),
        .o_data_r8_87   (data0_r8_87 ),
        .o_data_r8_90   (data0_r8_90 ),
//-------------r4----------//0
	.o_data_r4_18   (data0_r4_18 ),  
        .o_data_r4_50   (data0_r4_50 ),
        .o_data_r4_75   (data0_r4_75 ),
        .o_data_r4_89   (data0_r4_89 ),
//-------------a4----------//0
        .o_data_a4_64   (data0_a4_64 ),
        .o_data_a4_36   (data0_a4_36 ),
        .o_data_a4_83   (data0_a4_83 )
);

re_level1_cal     u1_level1_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld_32    (i_dt_vld_32),//data valid
	.i_dt_vld_16    (i_dt_vld_16),//data valid
	.i_dt_vld_8     (i_dt_vld_8 ),//data valid
	.i_data	        (i_data1    ),
//-------------r8---------//
	.o_data_r8_9    (data1_r8_9  ),    
        .o_data_r8_25   (data1_r8_25 ),
        .o_data_r8_43   (data1_r8_43 ),
        .o_data_r8_57   (data1_r8_57 ),
        .o_data_r8_70   (data1_r8_70 ),
        .o_data_r8_80   (data1_r8_80 ),
        .o_data_r8_87   (data1_r8_87 ),
        .o_data_r8_90   (data1_r8_90 ),
//-------------r4----------//1
	.o_data_r4_18   (data1_r4_18 ),  
        .o_data_r4_50   (data1_r4_50 ),
        .o_data_r4_75   (data1_r4_75 ),
        .o_data_r4_89   (data1_r4_89 ),
//-------------a4----------//0
        .o_data_a4_64   (data1_a4_64 ),
        .o_data_a4_36   (data1_a4_36 ),
        .o_data_a4_83   (data1_a4_83 )
);

re_level1_cal     u2_level1_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld_32    (i_dt_vld_32),//data valid
	.i_dt_vld_16    (i_dt_vld_16),//data valid
	.i_dt_vld_8     (i_dt_vld_8 ),//data valid
	.i_data	        (i_data2    ),
//-------------r8---------//
	.o_data_r8_9    (data2_r8_9  ),    
        .o_data_r8_25   (data2_r8_25 ),
        .o_data_r8_43   (data2_r8_43 ),
        .o_data_r8_57   (data2_r8_57 ),
        .o_data_r8_70   (data2_r8_70 ),
        .o_data_r8_80   (data2_r8_80 ),
        .o_data_r8_87   (data2_r8_87 ),
        .o_data_r8_90   (data2_r8_90 ),
//-------------r4----------//2
	.o_data_r4_18   (data2_r4_18 ),  
        .o_data_r4_50   (data2_r4_50 ),
        .o_data_r4_75   (data2_r4_75 ),
        .o_data_r4_89   (data2_r4_89 ),
//-------------a4----------//0
        .o_data_a4_64   (data2_a4_64 ),
        .o_data_a4_36   (data2_a4_36 ),
        .o_data_a4_83   (data2_a4_83 )
);

re_level1_cal     u3_level1_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld_32    (i_dt_vld_32),//data valid
	.i_dt_vld_16    (i_dt_vld_16),//data valid
	.i_dt_vld_8     (i_dt_vld_8 ),//data valid
	.i_data	        (i_data3    ),
//-------------r8---------//
	.o_data_r8_9    (data3_r8_9  ),    
        .o_data_r8_25   (data3_r8_25 ),
        .o_data_r8_43   (data3_r8_43 ),
        .o_data_r8_57   (data3_r8_57 ),
        .o_data_r8_70   (data3_r8_70 ),
        .o_data_r8_80   (data3_r8_80 ),
        .o_data_r8_87   (data3_r8_87 ),
        .o_data_r8_90   (data3_r8_90 ),
//-------------r4----------//3
	.o_data_r4_18   (data3_r4_18 ),  
        .o_data_r4_50   (data3_r4_50 ),
        .o_data_r4_75   (data3_r4_75 ),
        .o_data_r4_89   (data3_r4_89 ),
//-------------a4----------//0
        .o_data_a4_64   (data3_a4_64 ),
        .o_data_a4_36   (data3_a4_36 ),
        .o_data_a4_83   (data3_a4_83 )
);

re_level1_cal     u4_level1_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld_32    (i_dt_vld_32),//data valid
	.i_dt_vld_16    (i_dt_vld_16),//data valid
	.i_dt_vld_8     (i_dt_vld_8 ),//data valid
	.i_data	        (i_data4    ),
//-------------r8---------//
	.o_data_r8_9    (data4_r8_9  ),    
        .o_data_r8_25   (data4_r8_25 ),
        .o_data_r8_43   (data4_r8_43 ),
        .o_data_r8_57   (data4_r8_57 ),
        .o_data_r8_70   (data4_r8_70 ),
        .o_data_r8_80   (data4_r8_80 ),
        .o_data_r8_87   (data4_r8_87 ),
        .o_data_r8_90   (data4_r8_90 ),
//-------------r4----------//4
	.o_data_r4_18   (data4_r4_18 ),  
        .o_data_r4_50   (data4_r4_50 ),
        .o_data_r4_75   (data4_r4_75 ),
        .o_data_r4_89   (data4_r4_89 ),
//-------------a4----------//0
        .o_data_a4_64   (data4_a4_64 ),
        .o_data_a4_36   (data4_a4_36 ),
        .o_data_a4_83   (data4_a4_83 )
);

re_level1_cal     u5_level1_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld_32    (i_dt_vld_32),//data valid
	.i_dt_vld_16    (i_dt_vld_16),//data valid
	.i_dt_vld_8     (i_dt_vld_8 ),//data valid
	.i_data	        (i_data5    ),
//-------------r8---------//
	.o_data_r8_9    (data5_r8_9  ),    
        .o_data_r8_25   (data5_r8_25 ),
        .o_data_r8_43   (data5_r8_43 ),
        .o_data_r8_57   (data5_r8_57 ),
        .o_data_r8_70   (data5_r8_70 ),
        .o_data_r8_80   (data5_r8_80 ),
        .o_data_r8_87   (data5_r8_87 ),
        .o_data_r8_90   (data5_r8_90 ),
//-------------r4----------//5
	.o_data_r4_18   (data5_r4_18 ),  
        .o_data_r4_50   (data5_r4_50 ),
        .o_data_r4_75   (data5_r4_75 ),
        .o_data_r4_89   (data5_r4_89 ),
//-------------a4----------//0
        .o_data_a4_64   (data5_a4_64 ),
        .o_data_a4_36   (data5_a4_36 ),
        .o_data_a4_83   (data5_a4_83 )
);

re_level1_cal     u6_level1_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld_32    (i_dt_vld_32),//data valid
	.i_dt_vld_16    (i_dt_vld_16),//data valid
	.i_dt_vld_8     (i_dt_vld_8 ),//data valid
	.i_data	        (i_data6    ),
//-------------r8---------//
	.o_data_r8_9    (data6_r8_9  ),    
        .o_data_r8_25   (data6_r8_25 ),
        .o_data_r8_43   (data6_r8_43 ),
        .o_data_r8_57   (data6_r8_57 ),
        .o_data_r8_70   (data6_r8_70 ),
        .o_data_r8_80   (data6_r8_80 ),
        .o_data_r8_87   (data6_r8_87 ),
        .o_data_r8_90   (data6_r8_90 ),
//-------------r4----------//6
	.o_data_r4_18   (data6_r4_18 ),  
        .o_data_r4_50   (data6_r4_50 ),
        .o_data_r4_75   (data6_r4_75 ),
        .o_data_r4_89   (data6_r4_89 ),
//-------------a4----------//0
        .o_data_a4_64   (data6_a4_64 ),
        .o_data_a4_36   (data6_a4_36 ),
        .o_data_a4_83   (data6_a4_83 )
);

re_level1_cal     u7_level1_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld_32    (i_dt_vld_32),//data valid
	.i_dt_vld_16    (i_dt_vld_16),//data valid
	.i_dt_vld_8     (i_dt_vld_8 ),//data valid
	.i_data	        (i_data7    ),
//-------------r8---------//
	.o_data_r8_9    (data7_r8_9  ),    
        .o_data_r8_25   (data7_r8_25 ),
        .o_data_r8_43   (data7_r8_43 ),
        .o_data_r8_57   (data7_r8_57 ),
        .o_data_r8_70   (data7_r8_70 ),
        .o_data_r8_80   (data7_r8_80 ),
        .o_data_r8_87   (data7_r8_87 ),
        .o_data_r8_90   (data7_r8_90 ),
//-------------r4----------//7
	.o_data_r4_18   (data7_r4_18 ),  
        .o_data_r4_50   (data7_r4_50 ),
        .o_data_r4_75   (data7_r4_75 ),
        .o_data_r4_89   (data7_r4_89 ),
//-------------a4----------//0
        .o_data_a4_64   (data7_a4_64 ),
        .o_data_a4_36   (data7_a4_36 ),
        .o_data_a4_83   (data7_a4_83 )
);


endmodule

