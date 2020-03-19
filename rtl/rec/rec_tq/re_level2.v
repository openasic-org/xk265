//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.08
//file name     : re_level2.v
//delay         :
//describe      :
//modification  :
//v1.0          :
module re_level2(
	clk         ,
	rst_n       ,
	i_dt_vld_32  ,
	i_dt_vld_16  ,
	i_dt_vld_8   ,
	i_inverse   ,
	i_data0     ,
	i_data1     ,
	i_data2     ,
	i_data3     ,

	o_data0     ,
	o_data1     ,
	o_data2     ,
	o_data3     
);

input	        clk            ; 
input	        rst_n          ; 
input	        i_dt_vld_32     ; 
input	        i_dt_vld_16     ; 
input	        i_dt_vld_8      ;
input	        i_inverse      ; 
input [18:0]	i_data0        ; 
input [18:0]	i_data1        ; 
input [18:0]	i_data2        ; 
input [18:0]	i_data3        ; 

output [27:0]	o_data0    ; 
output [27:0]	o_data1    ; 
output [27:0]	o_data2    ; 
output [27:0]	o_data3    ; 
//--------------delay----------------//
reg             dt_vld32_d ;
reg    [1:0]    dt_vld8_d  ;

//--------------------------------------------------------------------------------------------//
wire [26:0]        data0_r4_18     ;
wire [26:0]        data0_r4_50     ;
wire [26:0]        data0_r4_75     ;
wire [26:0]        data0_r4_89     ;
//
wire [26:0]        data0_a4_64     ;
wire [26:0]        data0_a4_36     ;
wire [26:0]        data0_a4_83     ;
//-----------------------col1--------------------//
wire [26:0]        data1_r4_18     ;
wire [26:0]        data1_r4_50     ;
wire [26:0]        data1_r4_75     ;
wire [26:0]        data1_r4_89     ;
//
wire [26:0]        data1_a4_64     ;
wire [26:0]        data1_a4_36     ;
wire [26:0]        data1_a4_83     ;

//-----------------------col2--------------------//
wire [26:0]        data2_r4_18     ;
wire [26:0]        data2_r4_50     ;
wire [26:0]        data2_r4_75     ;
wire [26:0]        data2_r4_89     ;
//
wire [26:0]        data2_a4_64     ;
wire [26:0]        data2_a4_36     ;
wire [26:0]        data2_a4_83     ;

//-----------------------col3--------------------//
wire [26:0]        data3_r4_18     ;
wire [26:0]        data3_r4_50     ;
wire [26:0]        data3_r4_75     ;
wire [26:0]        data3_r4_89     ;
//
wire [26:0]        data3_a4_64     ;
wire [26:0]        data3_a4_36     ;
wire [26:0]        data3_a4_83     ;

//----------o_data0----------------//
reg [26:0]        data00;
reg [26:0]        data01;
reg [26:0]        data02;
reg [26:0]        data03;

wire [27:0]       data0_01     ;
wire [27:0]       data0_23     ;
reg  [27:0]       data00_stp0  ;
reg  [27:0]       data00_stp1  ;
reg  [27:0]       o_data0      ;

//----------o_data1----------------//
reg [26:0]        data10;
reg [26:0]        data11;
reg [26:0]        data12;
reg [26:0]        data13;

wire [27:0]       data1_01     ;
wire [27:0]       data1_23     ;
reg  [27:0]       data10_stp0  ;
reg  [27:0]       data10_stp1  ;
reg  [27:0]       o_data1      ;
//----------o_data2----------------//
reg [26:0]        data20;
reg [26:0]        data21;
reg [26:0]        data22;
reg [26:0]        data23;

wire [27:0]       data2_01     ;
wire [27:0]       data2_23     ;
reg  [27:0]       data20_stp0  ;
reg  [27:0]       data20_stp1  ;
reg  [27:0]       o_data2      ;
//----------o_data3----------------//
reg [26:0]        data30;
reg [26:0]        data31;
reg [26:0]        data32;
reg [26:0]        data33;

wire [27:0]       data3_01     ;
wire [27:0]       data3_23     ;
reg  [27:0]       data30_stp0  ;
reg  [27:0]       data30_stp1  ;
reg  [27:0]       o_data3      ;
//-------------------------------------------------------------delay
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		dt_vld32_d <= 1'd0;
	else	
		dt_vld32_d <= i_dt_vld_32;	
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		dt_vld8_d <= 2'd0;
	else	
		dt_vld8_d <= {dt_vld8_d[0],i_dt_vld_8};	
end 

//----------o_data0----------------//
always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld32_d)
		begin
			data00 =  data0_r4_18;
			data01 =  data1_r4_50;
			data02 =  data2_r4_75;
			data03 =  data3_r4_89;
		end
	else
		begin
			data00 =  data0_a4_64;
			data01 =  data1_a4_64;
			data02 =  data2_a4_64;
			data03 =  data3_a4_64;
		end
	end
	else
	begin
	if(dt_vld32_d)
		begin
			data00 =   data0_r4_18;
			data01 =  ~data1_r4_50 + 1'b1;
			data02 =   data2_r4_75;
			data03 =  ~data3_r4_89 + 1'b1;
		end
	else
		begin
			data00 =  data0_a4_64;
			data01 =  data1_a4_83;
			data02 =  data2_a4_64;
			data03 =  data3_a4_36;
		end	
	end
end

assign data0_01 = {data00[26],data00} + {data01[26],data01};  
assign data0_23 = {data02[26],data02} + {data03[26],data03};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data00_stp0 <= 28'd0;
	else
		data00_stp0 <= data0_01 + data0_23;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data00_stp1 <= 28'd0;
	else
		data00_stp1 <= data00_stp0;
end

always @(*)
begin
	if(dt_vld8_d[1])
		o_data0 = data00_stp0;
	else 
		o_data0 = data00_stp1;
end 

//------------------------------------------o_data1--------------------------------------------------------//
always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld32_d)
		begin
			data10 =  ~data0_r4_50 + 1'b1;
			data11 =  ~data1_r4_89 + 1'b1;
			data12 =  ~data2_r4_18 + 1'b1;
			data13 =   data3_r4_75;
		end
	else
		begin
			data10 =   data0_a4_83;
			data11 =   data1_a4_36;
			data12 =  ~data2_a4_36 + 1'b1;
			data13 =  ~data3_a4_83 + 1'b1;
		end
	end
	else
	begin
	if(dt_vld32_d)
		begin
			data10 =   data0_r4_50;
			data11 =  ~data1_r4_89 + 1'b1;
			data12 =   data2_r4_18;
			data13 =   data3_r4_75;
		end
	else 
		begin
			data10 =   data0_a4_64;
			data11 =   data1_a4_36;
			data12 =  ~data2_a4_64 + 1'b1;
			data13 =  ~data3_a4_83 + 1'b1;
		end	
	end
end 

assign data1_01 = {data10[26],data10} + {data11[26],data11};  
assign data1_23 = {data12[26],data12} + {data13[26],data13};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data10_stp0 <= 28'd0;
	else
		data10_stp0 <= data1_01 + data1_23;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data10_stp1 <= 28'd0;
	else
		data10_stp1 <= data10_stp0;
end

always @(*)
begin
	if(dt_vld8_d[1])
		o_data1 = data10_stp0;
	else 
		o_data1 = data10_stp1;
end 

//------------------------------------------o_data2--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld32_d)
		begin
			data20 =   data0_r4_75;
			data21 =   data1_r4_18;
			data22 =  ~data2_r4_89 + 1'b1;
			data23 =   data3_r4_50;
		end
	else
		begin
			data20 =   data0_a4_64;
			data21 =  ~data1_a4_64 + 1'b1;
			data22 =  ~data2_a4_64 + 1'b1;
			data23 =   data3_a4_64;
		end
	end
	else
	begin
	if(dt_vld32_d)
		begin
			data20 =   data0_r4_75;
			data21 =  ~data1_r4_18 + 1'b1;
			data22 =  ~data2_r4_89 + 1'b1;
			data23 =  ~data3_r4_50 + 1'b1;
		end
	else
		begin
			data20 =   data0_a4_64;
			data21 =  ~data1_a4_36 + 1'b1;
			data22 =  ~data2_a4_64 + 1'b1;
			data23 =   data3_a4_83;
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
		data20_stp0 <= data2_01 + data2_23;
end 
 
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data20_stp1 <= 28'd0;
	else
		data20_stp1 <= data20_stp0;
end

always @(*)
begin
	if(dt_vld8_d[1])
		o_data2 = data20_stp0;
	else 
		o_data2 = data20_stp1;
end 

//------------------------------------------o_data3--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld32_d)
		begin
			data30 =  ~data0_r4_89 + 1'b1;
			data31 =   data1_r4_75;
			data32 =  ~data2_r4_50 + 1'b1;
			data33 =   data3_r4_18;
		end
	else
		begin
			data30 =   data0_a4_36;
			data31 =  ~data1_a4_83 + 1'b1;
			data32 =   data2_a4_83;
			data33 =  ~data3_a4_36 + 1'b1;
		end
	end
	else
	begin
	if(dt_vld32_d)
		begin
			data30 =  data0_r4_89;
			data31 =  data1_r4_75;
			data32 =  data2_r4_50;
			data33 =  data3_r4_18;
		end
	else
		begin
			data30 =   data0_a4_64;
			data31 =  ~data1_a4_83 + 1'b1;
			data32 =   data2_a4_64;
			data33 =  ~data3_a4_36 + 1'b1;
		end	
	end
end 

assign data3_01 = {data30[26],data30} + {data31[26],data31};  
assign data3_23 = {data32[26],data32} + {data33[26],data33};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data30_stp0 <= 28'd0;
	else
		data30_stp0 <= data3_01 + data3_23;
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data30_stp1 <= 28'd0;
	else
		data30_stp1 <= data30_stp0;
end

always @(*)
begin
	if(dt_vld8_d[1])
		o_data3 = data30_stp0;
	else 
		o_data3 = data30_stp1;
end 

//--------------------------------------------------------------------------------------------//
re_level2_cal     u0_re_level2_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld_32     (i_dt_vld_32 ),//data valid
	.i_dt_vld_16     (i_dt_vld_16 ),//data valid
	.i_dt_vld_8      (i_dt_vld_8  ),//data valid
	.i_data	        (i_data0    ),
//-------------r4----------//0
	.o_data_r4_89   (data0_r4_89 ),  
        .o_data_r4_75   (data0_r4_75 ),
        .o_data_r4_50   (data0_r4_50 ),
        .o_data_r4_18   (data0_r4_18 ),
//-------------a4----------//0
        .o_data_a4_64   (data0_a4_64 ),
        .o_data_a4_36   (data0_a4_36 ),
        .o_data_a4_83   (data0_a4_83 )
);

re_level2_cal     u1_re_level2_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld_32     (i_dt_vld_32  ),//data valid
	.i_dt_vld_16     (i_dt_vld_16  ),//data valid
	.i_dt_vld_8      (i_dt_vld_8   ),//data valid
	.i_data	        (i_data1    ),
//-------------r4----------//1
	.o_data_r4_89   (data1_r4_89 ),  
        .o_data_r4_75   (data1_r4_75 ),
        .o_data_r4_50   (data1_r4_50 ),
        .o_data_r4_18   (data1_r4_18 ),
//-------------a4----------//0
        .o_data_a4_64   (data1_a4_64 ),
        .o_data_a4_36   (data1_a4_36 ),
        .o_data_a4_83   (data1_a4_83 )
);

re_level2_cal     u2_re_level2_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld_32     (i_dt_vld_32  ),//data valid
	.i_dt_vld_16     (i_dt_vld_16  ),//data valid
	.i_dt_vld_8      (i_dt_vld_8   ),//data valid
	.i_data	        (i_data2    ),
//-------------r4----------//2
	.o_data_r4_89   (data2_r4_89 ),  
        .o_data_r4_75   (data2_r4_75 ),
        .o_data_r4_50   (data2_r4_50 ),
        .o_data_r4_18   (data2_r4_18 ),
//-------------a4----------//0
        .o_data_a4_64   (data2_a4_64 ),
        .o_data_a4_36   (data2_a4_36 ),
        .o_data_a4_83   (data2_a4_83 )
);

re_level2_cal     u3_re_level2_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld_32     (i_dt_vld_32  ),//data valid
	.i_dt_vld_16     (i_dt_vld_16  ),//data valid
	.i_dt_vld_8      (i_dt_vld_8   ),//data valid
	.i_data	        (i_data3    ),
//-------------r4----------//3
	.o_data_r4_89   (data3_r4_89 ),  
        .o_data_r4_75   (data3_r4_75 ),
        .o_data_r4_50   (data3_r4_50 ),
        .o_data_r4_18   (data3_r4_18 ),
//-------------a4----------//0
        .o_data_a4_64   (data3_a4_64 ),
        .o_data_a4_36   (data3_a4_36 ),
        .o_data_a4_83   (data3_a4_83 )
);

endmodule


