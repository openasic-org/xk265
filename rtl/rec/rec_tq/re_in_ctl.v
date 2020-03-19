//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.17
//file name     : re_in_ctl.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module re_in_ctl(
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
//------------------------	
	o_dt_vld_32  ,
	o_dt_vld_16  ,
	o_dt_vld_8   ,
	o_dt_vld_4   ,
	o_dt_vld_dst,
//--------level0
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
//-------level1
	o_16        ,	
	o_17        ,	
	o_18        ,	
	o_19        ,	
	o_20        ,	
	o_21        ,	
	o_22        ,	
	o_23        ,	
//-------level2
	o_24        ,	
	o_25        ,	
	o_26        ,	
	o_27        ,
	o_28        ,	
	o_29        ,	
	o_30        ,	
	o_31        	
);

input   	i_valid     ;
input [1:0]  	i_transize  ;
input [1:0]  	tq_sel_i    ;
input [18:0]	i_0         ;	
input [18:0]	i_1         ;	
input [18:0]	i_2         ;	
input [18:0]	i_3         ;	
input [18:0]	i_4         ;	
input [18:0]	i_5         ;	
input [18:0]	i_6         ;	
input [18:0]	i_7         ;	
input [18:0]	i_8         ;	
input [18:0]	i_9         ;	
input [18:0]	i_10        ;	
input [18:0]	i_11        ;	
input [18:0]	i_12        ;	
input [18:0]	i_13        ;	
input [18:0]	i_14        ;	
input [18:0]	i_15        ;	
input [18:0]	i_16        ;	
input [18:0]	i_17        ;	
input [18:0]	i_18        ;	
input [18:0]	i_19        ;	
input [18:0]	i_20        ;	
input [18:0]	i_21        ;	
input [18:0]	i_22        ;	
input [18:0]	i_23        ;	
input [18:0]	i_24        ;	
input [18:0]	i_25        ;	
input [18:0]	i_26        ;	
input [18:0]	i_27        ;	
input [18:0]	i_28        ;	
input [18:0]	i_29        ;	
input [18:0]	i_30        ;	
input [18:0]	i_31        ;	
output   	o_dt_vld_32  ;
output   	o_dt_vld_16  ;
output   	o_dt_vld_8   ;
output   	o_dt_vld_4   ;
output   	o_dt_vld_dst;
//--------level0
output [16:0]	o_0         ;	
output [16:0]	o_1         ;	
output [16:0]	o_2         ;	
output [16:0]	o_3         ;	
output [16:0]	o_4         ;	
output [16:0]	o_5         ;	
output [16:0]	o_6         ;	
output [16:0]	o_7         ;	
output [16:0]	o_8         ;	
output [16:0]	o_9         ;	
output [16:0]	o_10        ;	
output [16:0]	o_11        ;	
output [16:0]	o_12        ;	
output [16:0]	o_13        ;	
output [16:0]	o_14        ;	
output [16:0]	o_15        ;	
//-------level1
output [17:0]	o_16        ;	
output [17:0]	o_17        ;	
output [17:0]	o_18        ;	
output [17:0]	o_19        ;	
output [17:0]	o_20        ;	
output [17:0]	o_21        ;	
output [17:0]	o_22        ;	
output [17:0]	o_23        ;	
//-------level2
output [18:0]	o_24        ;	
output [18:0]	o_25        ;	
output [18:0]	o_26        ;	
output [18:0]	o_27        ;
//------level3
output [18:0]	o_28        ;	
output [18:0]	o_29        ;	
output [18:0]	o_30        ;	
output [18:0]	o_31        ;	
//------------------------reg-----------------//
reg       	o_dt_vld_32  ;
reg       	o_dt_vld_16  ;
reg       	o_dt_vld_8   ;
reg       	o_dt_vld_4   ;
reg       	o_dt_vld_dst;
//--------level0
reg     [16:0]	o_0         ;	
reg     [16:0]	o_1         ;	
reg     [16:0]	o_2         ;	
reg     [16:0]	o_3         ;	
reg     [16:0]	o_4         ;	
reg     [16:0]	o_5         ;	
reg     [16:0]	o_6         ;	
reg     [16:0]	o_7         ;	
reg     [16:0]	o_8         ;	
reg     [16:0]	o_9         ;	
reg     [16:0]	o_10        ;	
reg     [16:0]	o_11        ;	
reg     [16:0]	o_12        ;	
reg     [16:0]	o_13        ;	
reg     [16:0]	o_14        ;	
reg     [16:0]	o_15        ;	
//-------level1
reg     [17:0]	o_16        ;	
reg     [17:0]	o_17        ;	
reg     [17:0]	o_18        ;	
reg     [17:0]	o_19        ;	
reg     [17:0]	o_20        ;	
reg     [17:0]	o_21        ;	
reg     [17:0]	o_22        ;	
reg     [17:0]	o_23        ;	
//-------level2
reg     [18:0]	o_24        ;	
reg     [18:0]	o_25        ;	
reg     [18:0]	o_26        ;	
reg     [18:0]	o_27        ;
//------level3
reg     [18:0]	o_28        ;	
reg     [18:0]	o_29        ;	
reg     [18:0]	o_30        ;	
reg     [18:0]	o_31        ;	
//level0
always @(*)
begin
	if(i_transize == 2'd0)//dct4x4 or dst4x4
	begin
		 o_0  = i_0[16:0]  ;
                 o_1  = i_1[16:0]  ;
                 o_2  = i_2[16:0]  ;
                 o_3  = i_3[16:0]  ;
                 o_4  = i_8[16:0]  ;
                 o_5  = i_9[16:0]  ;
                 o_6  = i_10[16:0] ;
                 o_7  = i_11[16:0] ;
                 o_8  = i_16[16:0] ;
                 o_9  = i_17[16:0] ;
                 o_10 = i_18[16:0] ;
                 o_11 = i_19[16:0] ;
                 o_12 = i_24[16:0] ;
                 o_13 = i_25[16:0] ;
                 o_14 = i_26[16:0] ;
                 o_15 = i_27[16:0] ;
	end
	else if(i_transize == 2'd1) //r4 r4 r4 r4
	begin
		 o_0  = i_4[16:0]  ;
                 o_1  = i_5[16:0]  ;
                 o_2  = i_6[16:0]  ;
                 o_3  = i_7[16:0]  ;
                 o_4  = i_12[16:0] ;
                 o_5  = i_13[16:0] ;
                 o_6  = i_14[16:0] ;
                 o_7  = i_15[16:0] ;
                 o_8  = i_20[16:0] ;
                 o_9  = i_21[16:0] ;
                 o_10 = i_22[16:0] ;
                 o_11 = i_23[16:0] ;
                 o_12 = i_28[16:0] ;
                 o_13 = i_29[16:0] ;
                 o_14 = i_30[16:0] ;
                 o_15 = i_31[16:0] ;
	end
	else if(i_transize == 2'd2)//r8 r8
	begin
		 o_0  = i_8[16:0]  ;
                 o_1  = i_9[16:0]  ;
                 o_2  = i_10[16:0] ;
                 o_3  = i_11[16:0] ;
                 o_4  = i_12[16:0] ;
                 o_5  = i_13[16:0] ;
                 o_6  = i_14[16:0] ;
                 o_7  = i_15[16:0] ;
                 o_8  = i_24[16:0] ;
                 o_9  = i_25[16:0] ;
                 o_10 = i_26[16:0] ;
                 o_11 = i_27[16:0] ;
                 o_12 = i_28[16:0] ;
                 o_13 = i_29[16:0] ;
                 o_14 = i_30[16:0] ;
                 o_15 = i_31[16:0] ;
	end
	else//r16
	begin
		 o_0  = i_16[16:0] ;
                 o_1  = i_17[16:0] ;
                 o_2  = i_18[16:0] ;
                 o_3  = i_19[16:0] ;
                 o_4  = i_20[16:0] ;
                 o_5  = i_21[16:0] ;
                 o_6  = i_22[16:0] ;
                 o_7  = i_23[16:0] ;
                 o_8  = i_24[16:0] ;
                 o_9  = i_25[16:0] ;
                 o_10 = i_26[16:0] ;
                 o_11 = i_27[16:0] ;
                 o_12 = i_28[16:0] ;
                 o_13 = i_29[16:0] ;
                 o_14 = i_30[16:0] ;
                 o_15 = i_31[16:0] ;
	end
end
//level1
always @(*)
begin
	if(i_transize == 2'd1)//a4 a4  
	begin
		 o_16  = i_0[17:0]  ;
                 o_17  = i_1[17:0]  ;
                 o_18  = i_2[17:0]  ;
                 o_19  = i_3[17:0]  ;
                 o_20  = i_8[17:0]  ;
                 o_21  = i_9[17:0]  ;
                 o_22  = i_10[17:0] ;
                 o_23  = i_11[17:0] ;
	end
	else if(i_transize == 2'd2)//r4  r4 
	begin
		 o_16  = i_4[17:0]  ;
                 o_17  = i_5[17:0]  ;
                 o_18  = i_6[17:0]  ;
                 o_19  = i_7[17:0]  ;
                 o_20  = i_20[17:0] ;
                 o_21  = i_21[17:0] ;
                 o_22  = i_22[17:0] ;
                 o_23  = i_23[17:0] ;
	end
	else
	begin
		 o_16  = i_8[17:0]  ;//r8
                 o_17  = i_9[17:0]  ;
                 o_18  = i_10[17:0] ;
                 o_19  = i_11[17:0] ;
                 o_20  = i_12[17:0] ;
                 o_21  = i_13[17:0] ;
                 o_22  = i_14[17:0] ;
                 o_23  = i_15[17:0] ;
	end
end

//level2
always @(*)
begin
	if(i_transize == 2'd1) //a4
	begin
		 o_24  = i_16  ;
                 o_25  = i_17  ;
                 o_26  = i_18  ;
                 o_27  = i_19  ;
	end
	else if(i_transize == 2'd2)
	begin
		 o_24  = i_0  ;//a4
                 o_25  = i_1  ;
                 o_26  = i_2  ;
                 o_27  = i_3  ;
	end
	else
	begin
		 o_24  = i_4  ;//r4
                 o_25  = i_5  ;
                 o_26  = i_6  ;
                 o_27  = i_7  ;
	end
end

//level3
always @(*)
begin
	if(i_transize == 2'd1) //a4
	begin
		 o_28  = i_24  ;
                 o_29  = i_25  ;
                 o_30  = i_26  ;
                 o_31  = i_27  ;
	end
	else if(i_transize == 2'd2)
	begin
		 o_28  = i_16  ;//a4
                 o_29  = i_17  ;
                 o_30  = i_18  ;
                 o_31  = i_19  ;
	end
	else
	begin
		 o_28  = i_0  ;//a4
                 o_29  = i_1  ;
                 o_30  = i_2  ;
                 o_31  = i_3  ;
	end
end
//--------------------------------------------------------//
always @(*)
begin
	if((i_transize == 2'd0) && (~tq_sel_i[1]))
		o_dt_vld_dst = i_valid;
	else
		o_dt_vld_dst = 1'b0;
end 

always @(*)
begin
	if((i_transize == 2'd0) && (tq_sel_i[1]))
		o_dt_vld_4 = i_valid;
	else
		o_dt_vld_4 = 1'b0;
end 

always @(*)
begin
	if(i_transize == 2'd1)
		o_dt_vld_8 = i_valid;
	else
		o_dt_vld_8 = 1'b0;
end 

always @(*)
begin
	if(i_transize == 2'd2)
		o_dt_vld_16 = i_valid;
	else
		o_dt_vld_16 = 1'b0;
end 

always @(*)
begin
	if(i_transize == 2'd3)
		o_dt_vld_32 = i_valid;
	else
		o_dt_vld_32 = 1'b0;
end 

endmodule 
