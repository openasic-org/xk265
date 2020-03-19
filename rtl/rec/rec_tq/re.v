//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.18
//file name     : re.v
//describe      :dct32x32/dct16x16:3 clk    other: 2clk
//delay         :dct32x32/dct16x16:3 clk    other: 2clk  
//modification  :
//v1.0          :

module re(
	clk            ,
	rst_n          ,
	i_inverse      ,//0:dct 1:idct
	i_tq_sel       ,//00 01 :LUMA ; 10 :cb 11:cr
	i_transize     ,//00:4x4 01:8x8 10:16x16 11:32x32
	i_dt_vld       ,//data valid
	i_data0	       ,
	i_data1	       ,
	i_data2	       ,
	i_data3	       ,
	i_data4	       ,
	i_data5	       ,
	i_data6	       ,
	i_data7	       ,
	i_data8	       ,
	i_data9	       ,
	i_data10       ,
	i_data11       ,
	i_data12       ,
	i_data13       ,
	i_data14       ,
	i_data15       ,
	i_data16       ,
	i_data17       ,
	i_data18       ,
	i_data19       ,
	i_data20       ,
	i_data21       ,
	i_data22       ,
	i_data23       ,
	i_data24       ,
	i_data25       ,
	i_data26       ,
	i_data27       ,
	i_data28       ,
	i_data29       ,
	i_data30       ,
	i_data31       ,

	o_dt_vld       ,
	o_data0	       ,
	o_data1	       ,
	o_data2	       ,
	o_data3	       ,
	o_data4	       ,
	o_data5	       ,
	o_data6	       ,
	o_data7	       ,
	o_data8	       ,
	o_data9	       ,
	o_data10       ,
	o_data11       ,
	o_data12       ,
	o_data13       ,
	o_data14       ,
	o_data15       ,
	o_data16       ,
	o_data17       ,
	o_data18       ,
	o_data19       ,
	o_data20       ,
	o_data21       ,
	o_data22       ,
	o_data23       ,
	o_data24       ,
	o_data25       ,
	o_data26       ,
	o_data27       ,
	o_data28       ,
	o_data29       ,
	o_data30       ,
	o_data31       
);

input   	clk            ;
input   	rst_n          ;
input   	i_inverse      ;//0:dct 1:idct
input [1:0]	i_tq_sel       ;//00 01 :LUMA ; 10 :cb 11:cr
input [1:0]	i_transize     ;//00:4x4 01:8x8 10:16x16 11:32x32
input   	i_dt_vld       ;//data valid
input [18:0]	i_data0	       ;
input [18:0]	i_data1	       ;
input [18:0]	i_data2	       ;
input [18:0]	i_data3	       ;
input [18:0]	i_data4	       ;
input [18:0]	i_data5	       ;
input [18:0]	i_data6	       ;
input [18:0]	i_data7	       ;
input [18:0]	i_data8	       ;
input [18:0]	i_data9	       ;
input [18:0]	i_data10       ;
input [18:0]	i_data11       ;
input [18:0]	i_data12       ;
input [18:0]	i_data13       ;
input [18:0]	i_data14       ;
input [18:0]	i_data15       ;
input [18:0]	i_data16       ;
input [18:0]	i_data17       ;
input [18:0]	i_data18       ;
input [18:0]	i_data19       ;
input [18:0]	i_data20       ;
input [18:0]	i_data21       ;
input [18:0]	i_data22       ;
input [18:0]	i_data23       ;
input [18:0]	i_data24       ;
input [18:0]	i_data25       ;
input [18:0]	i_data26       ;
input [18:0]	i_data27       ;
input [18:0]	i_data28       ;
input [18:0]	i_data29       ;
input [18:0]	i_data30       ;
input [18:0]	i_data31       ;

output  	o_dt_vld       ;
output [27:0]	o_data0	       ;
output [27:0]	o_data1	       ;
output [27:0]	o_data2	       ;
output [27:0]	o_data3	       ;
output [27:0]	o_data4	       ;
output [27:0]	o_data5	       ;
output [27:0]	o_data6	       ;
output [27:0]	o_data7	       ;
output [27:0]	o_data8	       ;
output [27:0]	o_data9	       ;
output [27:0]	o_data10       ;
output [27:0]	o_data11       ;
output [27:0]	o_data12       ;
output [27:0]	o_data13       ;
output [27:0]	o_data14       ;
output [27:0]	o_data15       ;
output [27:0]	o_data16       ;
output [27:0]	o_data17       ;
output [27:0]	o_data18       ;
output [27:0]	o_data19       ;
output [27:0]	o_data20       ;
output [27:0]	o_data21       ;
output [27:0]	o_data22       ;
output [27:0]	o_data23       ;
output [27:0]	o_data24       ;
output [27:0]	o_data25       ;
output [27:0]	o_data26       ;
output [27:0]	o_data27       ;
output [27:0]	o_data28       ;
output [27:0]	o_data29       ;
output [27:0]	o_data30       ;
output [27:0]	o_data31       ;
//------------------out---------------//
wire  	        o_dt_vld       ;
wire [27:0]	o_data0	       ;
wire [27:0]	o_data1	       ;
wire [27:0]	o_data2	       ;
wire [27:0]	o_data3	       ;
wire [27:0]	o_data4	       ;
wire [27:0]	o_data5	       ;
wire [27:0]	o_data6	       ;
wire [27:0]	o_data7	       ;
wire [27:0]	o_data8	       ;
wire [27:0]	o_data9	       ;
wire [27:0]	o_data10       ;
wire [27:0]	o_data11       ;
wire [27:0]	o_data12       ;
wire [27:0]	o_data13       ;
wire [27:0]	o_data14       ;
wire [27:0]	o_data15       ;
wire [27:0]	o_data16       ;
wire [27:0]	o_data17       ;
wire [27:0]	o_data18       ;
wire [27:0]	o_data19       ;
wire [27:0]	o_data20       ;
wire [27:0]	o_data21       ;
wire [27:0]	o_data22       ;
wire [27:0]	o_data23       ;
wire [27:0]	o_data24       ;
wire [27:0]	o_data25       ;
wire [27:0]	o_data26       ;
wire [27:0]	o_data27       ;
wire [27:0]	o_data28       ;
wire [27:0]	o_data29       ;
wire [27:0]	o_data30       ;
wire [27:0]	o_data31       ;
//-------------------in_ctl--------------------//
wire            dt_vld_32      ;    
wire            dt_vld_16      ;      
wire            dt_vld_8       ; 
wire            dt_vld_4       ;
wire            dt_vld_dst     ;
//level0     
wire[16:0]     level0_data_0   ; 
wire[16:0]     level0_data_1   ; 
wire[16:0]     level0_data_2   ; 
wire[16:0]     level0_data_3   ; 
wire[16:0]     level0_data_4   ; 
wire[16:0]     level0_data_5   ; 
wire[16:0]     level0_data_6   ; 
wire[16:0]     level0_data_7   ; 
wire[16:0]     level0_data_8   ; 
wire[16:0]     level0_data_9   ; 
wire[16:0]     level0_data_10  ; 
wire[16:0]     level0_data_11  ; 
wire[16:0]     level0_data_12  ; 
wire[16:0]     level0_data_13  ; 
wire[16:0]     level0_data_14  ; 
wire[16:0]     level0_data_15  ; 
// level1               
wire[17:0]     level1_data_0   ;
wire[17:0]     level1_data_1   ;
wire[17:0]     level1_data_2   ;
wire[17:0]     level1_data_3   ;
wire[17:0]     level1_data_4   ;
wire[17:0]     level1_data_5   ;
wire[17:0]     level1_data_6   ;
wire[17:0]     level1_data_7   ;
//level2               
wire[18:0]     level2_data_0   ;
wire[18:0]     level2_data_1   ;
wire[18:0]     level2_data_2   ;
wire[18:0]     level2_data_3   ;
//level3               
wire[18:0]     level3_data_0   ;
wire[18:0]     level3_data_1   ;
wire[18:0]     level3_data_2   ;
wire[18:0]     level3_data_3   ;

//level0     
wire[27:0]     level0_data_o0   ; 
wire[27:0]     level0_data_o1   ; 
wire[27:0]     level0_data_o2   ; 
wire[27:0]     level0_data_o3   ; 
wire[27:0]     level0_data_o4   ; 
wire[27:0]     level0_data_o5   ; 
wire[27:0]     level0_data_o6   ; 
wire[27:0]     level0_data_o7   ; 
wire[27:0]     level0_data_o8   ; 
wire[27:0]     level0_data_o9   ; 
wire[27:0]     level0_data_o10  ; 
wire[27:0]     level0_data_o11  ; 
wire[27:0]     level0_data_o12  ; 
wire[27:0]     level0_data_o13  ; 
wire[27:0]     level0_data_o14  ; 
wire[27:0]     level0_data_o15  ; 
// level1               
wire[27:0]     level1_data_o0   ;
wire[27:0]     level1_data_o1   ;
wire[27:0]     level1_data_o2   ;
wire[27:0]     level1_data_o3   ;
wire[27:0]     level1_data_o4   ;
wire[27:0]     level1_data_o5   ;
wire[27:0]     level1_data_o6   ;
wire[27:0]     level1_data_o7   ;
//level2               
wire[27:0]     level2_data_o0   ;
wire[27:0]     level2_data_o1   ;
wire[27:0]     level2_data_o2   ;
wire[27:0]     level2_data_o3   ;
//level3               
wire[27:0]     level3_data_o0   ;
wire[27:0]     level3_data_o1   ;
wire[27:0]     level3_data_o2   ;
wire[27:0]     level3_data_o3   ;

//-------------------------------------------------//
re_in_ctl  re_in_ctl_int(
	.i_valid    (i_dt_vld   ) ,
	.i_transize (i_transize ) ,
	.tq_sel_i   (i_tq_sel   ) ,
	.i_0        (i_data0	) ,	
	.i_1        (i_data1	) ,	
	.i_2        (i_data2	) ,	
	.i_3        (i_data3	) ,	
	.i_4        (i_data4	) ,	
	.i_5        (i_data5	) ,	
	.i_6        (i_data6	) ,	
	.i_7        (i_data7	) ,	
	.i_8        (i_data8	) ,	
	.i_9        (i_data9	) ,	
	.i_10       (i_data10   ) ,	
	.i_11       (i_data11   ) ,	
	.i_12       (i_data12   ) ,	
	.i_13       (i_data13   ) ,	
	.i_14       (i_data14   ) ,	
	.i_15       (i_data15   ) ,	
	.i_16       (i_data16   ) ,	
	.i_17       (i_data17   ) ,	
	.i_18       (i_data18   ) ,	
	.i_19       (i_data19   ) ,	
	.i_20       (i_data20   ) ,	
	.i_21       (i_data21   ) ,	
	.i_22       (i_data22   ) ,	
	.i_23       (i_data23   ) ,	
	.i_24       (i_data24   ) ,	
	.i_25       (i_data25   ) ,	
	.i_26       (i_data26   ) ,	
	.i_27       (i_data27   ) ,	
	.i_28       (i_data28   ) ,	
	.i_29       (i_data29   ) ,	
	.i_30       (i_data30   ) ,	
	.i_31       (i_data31   ) ,
//------.-------------------	
	.o_dt_vld_32 (dt_vld_32) ,
	.o_dt_vld_16 (dt_vld_16) ,
	.o_dt_vld_8  (dt_vld_8 ) ,
	.o_dt_vld_4  (dt_vld_4 ) ,
	.o_dt_vld_dst(dt_vld_dst),
//------.--level0
	.o_0        (level0_data_0 ) ,	
	.o_1        (level0_data_1 ) ,	
	.o_2        (level0_data_2 ) ,	
	.o_3        (level0_data_3 ) ,	
	.o_4        (level0_data_4 ) ,	
	.o_5        (level0_data_5 ) ,	
	.o_6        (level0_data_6 ) ,	
	.o_7        (level0_data_7 ) ,	
	.o_8        (level0_data_8 ) ,	
	.o_9        (level0_data_9 ) ,	
	.o_10       (level0_data_10) ,	
	.o_11       (level0_data_11) ,	
	.o_12       (level0_data_12) ,	
	.o_13       (level0_data_13) ,	
	.o_14       (level0_data_14) ,	
	.o_15       (level0_data_15) ,	
//------.-level1
	.o_16       (level1_data_0) ,	
	.o_17       (level1_data_1) ,	
	.o_18       (level1_data_2) ,	
	.o_19       (level1_data_3) ,	
	.o_20       (level1_data_4) ,	
	.o_21       (level1_data_5) ,	
	.o_22       (level1_data_6) ,	
	.o_23       (level1_data_7) ,	
//------.-level2
	.o_24       (level2_data_0) ,	
	.o_25       (level2_data_1) ,	
	.o_26       (level2_data_2) ,	
	.o_27       (level2_data_3) ,
//-------level3-----
	.o_28       (level3_data_0) ,	
	.o_29       (level3_data_1) ,	
	.o_30       (level3_data_2) ,	
	.o_31       (level3_data_3) 	
);

re_level0   re_level0_int(
	.clk         (clk    ) ,
	.rst_n       (rst_n  ) ,
	.i_dt_vld_32 (dt_vld_32 ) ,
	.i_dt_vld_16 (dt_vld_16 ) ,
	.i_dt_vld_8  (dt_vld_8  ) ,
	.i_dt_vld_4  (dt_vld_4  ) ,//chro
	.i_dt_vld_dst(dt_vld_dst) ,//luma
	.i_inverse   (i_inverse ) ,
	.i_data0     (level0_data_0 ) ,
	.i_data1     (level0_data_1 ) ,
	.i_data2     (level0_data_2 ) ,
	.i_data3     (level0_data_3 ) ,
	.i_data4     (level0_data_4 ) ,
	.i_data5     (level0_data_5 ) ,
	.i_data6     (level0_data_6 ) ,
	.i_data7     (level0_data_7 ) ,
	.i_data8     (level0_data_8 ) ,
	.i_data9     (level0_data_9 ) ,
	.i_data10    (level0_data_10) ,
	.i_data11    (level0_data_11) ,
	.i_data12    (level0_data_12) ,
	.i_data13    (level0_data_13) ,
	.i_data14    (level0_data_14) ,
	.i_data15    (level0_data_15) ,

	.o_data0     (level0_data_o0 ) ,
	.o_data1     (level0_data_o1 ) ,
	.o_data2     (level0_data_o2 ) ,
	.o_data3     (level0_data_o3 ) ,
	.o_data4     (level0_data_o4 ) ,
	.o_data5     (level0_data_o5 ) ,
	.o_data6     (level0_data_o6 ) ,
	.o_data7     (level0_data_o7 ) ,
	.o_data8     (level0_data_o8 ) ,
	.o_data9     (level0_data_o9 ) ,
	.o_data10    (level0_data_o10) ,
	.o_data11    (level0_data_o11) ,
	.o_data12    (level0_data_o12) ,
	.o_data13    (level0_data_o13) ,
	.o_data14    (level0_data_o14) ,
	.o_data15    (level0_data_o15) 
);

re_level1 re_level1_int(
	.clk         (clk        ),
	.rst_n       (rst_n      ),
	.i_dt_vld_32 (dt_vld_32  ),
	.i_dt_vld_16 (dt_vld_16  ),
	.i_dt_vld_8  (dt_vld_8   ),
	.i_inverse   (i_inverse  ),
	.i_data0     (level1_data_0),
	.i_data1     (level1_data_1),
	.i_data2     (level1_data_2),
	.i_data3     (level1_data_3),
	.i_data4     (level1_data_4),
	.i_data5     (level1_data_5),
	.i_data6     (level1_data_6),
	.i_data7     (level1_data_7),

	.o_data0     (level1_data_o0),
	.o_data1     (level1_data_o1),
	.o_data2     (level1_data_o2),
	.o_data3     (level1_data_o3),
	.o_data4     (level1_data_o4),
	.o_data5     (level1_data_o5),
	.o_data6     (level1_data_o6),
	.o_data7     (level1_data_o7)
);

re_level2 re_level2_int(
	.clk         (clk           ) ,
	.rst_n       (rst_n         ) ,
	.i_dt_vld_32 (dt_vld_32     ) ,
	.i_dt_vld_16 (dt_vld_16     ) ,
	.i_dt_vld_8  (dt_vld_8      ) ,
	.i_inverse   (i_inverse     ) ,
	.i_data0     (level2_data_0 ) ,
	.i_data1     (level2_data_1 ) ,
	.i_data2     (level2_data_2 ) ,
	.i_data3     (level2_data_3 ) ,

	.o_data0     (level2_data_o0) ,
	.o_data1     (level2_data_o1) ,
	.o_data2     (level2_data_o2) ,
	.o_data3     (level2_data_o3)
);

re_level3 re_leve3_int(
	.clk          (clk      )  ,
	.rst_n        (rst_n    )  ,
	.i_inverse    (i_inverse)  ,
	.i_dt_vld_32  (dt_vld_32)  ,//data valid
        .i_dt_vld_16  (dt_vld_16)  ,
        .i_dt_vld_8   (dt_vld_8 )  ,
	.i_data0      (level3_data_0)  ,
	.i_data1      (level3_data_1)  ,
	.i_data2      (level3_data_2)  ,
	.i_data3      (level3_data_3)  ,
//------.-------a4----------//
	.o_data0   (level3_data_o0)  ,  
        .o_data1   (level3_data_o1)  ,
        .o_data2   (level3_data_o2)  , 
        .o_data3   (level3_data_o3)
);

re_out_ctl   re_out_ctl_int(
	.clk         (clk         ),
	.rst_n	     (rst_n       ),
	.i_valid     (i_dt_vld    ),
	.i_transize  (i_transize  ),
	.tq_sel_i    (i_tq_sel    ),
//level0
	.i_0         (level0_data_o0 ),	
	.i_1         (level0_data_o1 ),	
	.i_2         (level0_data_o2 ),	
	.i_3         (level0_data_o3 ),	
	.i_4         (level0_data_o4 ),	
	.i_5         (level0_data_o5 ),	
	.i_6         (level0_data_o6 ),	
	.i_7         (level0_data_o7 ),	
	.i_8         (level0_data_o8 ),	
	.i_9         (level0_data_o9 ),	
	.i_10        (level0_data_o10),	
	.i_11        (level0_data_o11),	
	.i_12        (level0_data_o12),	
	.i_13        (level0_data_o13),	
	.i_14        (level0_data_o14),	
	.i_15        (level0_data_o15),	
//level1
	.i_16        (level1_data_o0),	
	.i_17        (level1_data_o1),	
	.i_18        (level1_data_o2),	
	.i_19        (level1_data_o3),	
	.i_20        (level1_data_o4),	
	.i_21        (level1_data_o5),	
	.i_22        (level1_data_o6),	
	.i_23        (level1_data_o7),	
//level2
	.i_24        (level2_data_o0),	
	.i_25        (level2_data_o1),	
	.i_26        (level2_data_o2),	
	.i_27        (level2_data_o3),	
//level3
	.i_28        (level3_data_o0),
	.i_29        (level3_data_o1),	
	.i_30        (level3_data_o2),	
	.i_31        (level3_data_o3),
//------.-------------------------//	
	.o_valid     (o_dt_vld  ),
	.o_0         (o_data0	),	
	.o_1         (o_data1	),	
	.o_2         (o_data2	),	
	.o_3         (o_data3	),	
	.o_4         (o_data4	),	
	.o_5         (o_data5	),	
	.o_6         (o_data6	),	
	.o_7         (o_data7	),	
	.o_8         (o_data8	),	
	.o_9         (o_data9	),	
	.o_10        (o_data10  ),	
	.o_11        (o_data11  ),	
	.o_12        (o_data12  ),	
	.o_13        (o_data13  ),	
	.o_14        (o_data14  ),	
	.o_15        (o_data15  ),	
	.o_16        (o_data16  ),	
	.o_17        (o_data17  ),	
	.o_18        (o_data18  ),	
	.o_19        (o_data19  ),	
	.o_20        (o_data20  ),	
	.o_21        (o_data21  ),	
	.o_22        (o_data22  ),	
	.o_23        (o_data23  ),	
	.o_24        (o_data24  ),	
	.o_25        (o_data25  ),	
	.o_26        (o_data26  ),	
	.o_27        (o_data27  ),
	.o_28        (o_data28  ),	
	.o_29        (o_data29  ),	
	.o_30        (o_data30  ),	
	.o_31        (o_data31  )	
);

endmodule 
