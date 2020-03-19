//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.08
//file name     : be.v
//delay         : dct4x4 or dst4x4 : 1clk ; dct8x8\dct16x16\dct32x32: 2clk
//describe      :
//modification  :
//v1.0          :

module be(
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
//--------------------dt_mux0_31   ----
	o_dt_vld    ,
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

input	        clk         ;
input	        rst_n       ;
input	        i_dt_vld    ;
input	        i_inverse   ;
input [1 : 0]	i_transize  ;
input [27: 0]	i_0         ;	
input [27: 0]	i_1         ;	
input [27: 0]	i_2         ;	
input [27: 0]	i_3         ;	
input [27: 0]	i_4         ;	
input [27: 0]	i_5         ;	
input [27: 0]	i_6         ;	
input [27: 0]	i_7         ;	
input [27: 0]	i_8         ;	
input [27: 0]	i_9         ;	
input [27: 0]	i_10        ;	
input [27: 0]	i_11        ;	
input [27: 0]	i_12        ;	
input [27: 0]	i_13        ;	
input [27: 0]	i_14        ;	
input [27: 0]	i_15        ;	
input [27: 0]	i_16        ;	
input [27: 0]	i_17        ;	
input [27: 0]	i_18        ;	
input [27: 0]	i_19        ;	
input [27: 0]	i_20        ;	
input [27: 0]	i_21        ;	
input [27: 0]	i_22        ;	
input [27: 0]	i_23        ;	
input [27: 0]	i_24        ;	
input [27: 0]	i_25        ;	
input [27: 0]	i_26        ;	
input [27: 0]	i_27        ;	
input [27: 0]	i_28        ;	
input [27: 0]	i_29        ;	
input [27: 0]	i_30        ;
input [27: 0]	i_31        ;
//--------------------dt_mux0_31   ----
output   	o_dt_vld    ;
output[27: 0]	o_0         ;	
output[27: 0]	o_1         ;	
output[27: 0]	o_2         ;	
output[27: 0]	o_3         ;	
output[27: 0]	o_4         ;	
output[27: 0]	o_5         ;	
output[27: 0]	o_6         ;	
output[27: 0]	o_7         ;	
output[27: 0]	o_8         ;	
output[27: 0]	o_9         ;	
output[27: 0]	o_10        ;	
output[27: 0]	o_11        ;	
output[27: 0]	o_12        ;	
output[27: 0]	o_13        ;	
output[27: 0]	o_14        ;	
output[27: 0]	o_15        ;	
output[27: 0]	o_16        ;	
output[27: 0]	o_17        ;	
output[27: 0]	o_18        ;	
output[27: 0]	o_19        ;	
output[27: 0]	o_20        ;	
output[27: 0]	o_21        ;	
output[27: 0]	o_22        ;	
output[27: 0]	o_23        ;	
output[27: 0]	o_24        ;	
output[27: 0]	o_25        ;	
output[27: 0]	o_26        ;	
output[27: 0]	o_27        ;
output[27: 0]	o_28        ;	
output[27: 0]	o_29        ;	
output[27: 0]	o_30        ;	
output[27: 0]	o_31        ;	

wire  [27: 0]   level0_0    ;  
wire  [27: 0]   level0_1    ;
wire  [27: 0]   level0_2    ;
wire  [27: 0]   level0_3    ;
wire  [27: 0]   level0_4    ;
wire  [27: 0]   level0_5    ;
wire  [27: 0]   level0_6    ;
wire  [27: 0]   level0_7    ;
wire  [27: 0]   level0_8    ;
wire  [27: 0]   level0_9    ;
wire  [27: 0]   level0_10   ;
wire  [27: 0]   level0_11   ;
wire  [27: 0]   level0_12   ;
wire  [27: 0]   level0_13   ;
wire  [27: 0]   level0_14   ;
wire  [27: 0]   level0_15   ;
wire  [27: 0]   level0_16   ;
wire  [27: 0]   level0_17   ;
wire  [27: 0]   level0_18   ;
wire  [27: 0]   level0_19   ;
wire  [27: 0]   level0_20   ;
wire  [27: 0]   level0_21   ;
wire  [27: 0]   level0_22   ;
wire  [27: 0]   level0_23   ;
wire  [27: 0]   level0_24   ;
wire  [27: 0]   level0_25   ;
wire  [27: 0]   level0_26   ;
wire  [27: 0]   level0_27   ;
wire  [27: 0]   level0_28   ;
wire  [27: 0]   level0_29   ;
wire  [27: 0]   level0_30   ;
wire  [27: 0]   level0_31   ;

wire  [27: 0]   level1_0    ;  
wire  [27: 0]   level1_1    ;
wire  [27: 0]   level1_2    ;
wire  [27: 0]   level1_3    ;
wire  [27: 0]   level1_4    ;
wire  [27: 0]   level1_5    ;
wire  [27: 0]   level1_6    ;
wire  [27: 0]   level1_7    ;
wire  [27: 0]   level1_8    ;
wire  [27: 0]   level1_9    ;
wire  [27: 0]   level1_10   ;
wire  [27: 0]   level1_11   ;
wire  [27: 0]   level1_12   ;
wire  [27: 0]   level1_13   ;
wire  [27: 0]   level1_14   ;
wire  [27: 0]   level1_15   ;
wire  [27: 0]   level1_16   ;
wire  [27: 0]   level1_17   ;
wire  [27: 0]   level1_18   ;
wire  [27: 0]   level1_19   ;
wire  [27: 0]   level1_20   ;
wire  [27: 0]   level1_21   ;
wire  [27: 0]   level1_22   ;
wire  [27: 0]   level1_23   ;
wire  [27: 0]   level1_24   ;
wire  [27: 0]   level1_25   ;
wire  [27: 0]   level1_26   ;
wire  [27: 0]   level1_27   ;
wire  [27: 0]   level1_28   ;
wire  [27: 0]   level1_29   ;
wire  [27: 0]   level1_30   ;
wire  [27: 0]   level1_31   ;

wire  [27: 0]   level2_0    ;  
wire  [27: 0]   level2_1    ;
wire  [27: 0]   level2_2    ;
wire  [27: 0]   level2_3    ;
wire  [27: 0]   level2_4    ;
wire  [27: 0]   level2_5    ;
wire  [27: 0]   level2_6    ;
wire  [27: 0]   level2_7    ;
wire  [27: 0]   level2_8    ;
wire  [27: 0]   level2_9    ;
wire  [27: 0]   level2_10   ;
wire  [27: 0]   level2_11   ;
wire  [27: 0]   level2_12   ;
wire  [27: 0]   level2_13   ;
wire  [27: 0]   level2_14   ;
wire  [27: 0]   level2_15   ;
wire  [27: 0]   level2_16   ;
wire  [27: 0]   level2_17   ;
wire  [27: 0]   level2_18   ;
wire  [27: 0]   level2_19   ;
wire  [27: 0]   level2_20   ;
wire  [27: 0]   level2_21   ;
wire  [27: 0]   level2_22   ;
wire  [27: 0]   level2_23   ;
wire  [27: 0]   level2_24   ;
wire  [27: 0]   level2_25   ;
wire  [27: 0]   level2_26   ;
wire  [27: 0]   level2_27   ;
wire  [27: 0]   level2_28   ;
wire  [27: 0]   level2_29   ;
wire  [27: 0]   level2_30   ;
wire  [27: 0]   level2_31   ;

wire   	        o_dt_vld    ;
wire[27: 0]	o_0         ;	
wire[27: 0]	o_1         ;	
wire[27: 0]	o_2         ;	
wire[27: 0]	o_3         ;	
wire[27: 0]	o_4         ;	
wire[27: 0]	o_5         ;	
wire[27: 0]	o_6         ;	
wire[27: 0]	o_7         ;	
wire[27: 0]	o_8         ;	
wire[27: 0]	o_9         ;	
wire[27: 0]	o_10        ;	
wire[27: 0]	o_11        ;	
wire[27: 0]	o_12        ;	
wire[27: 0]	o_13        ;	
wire[27: 0]	o_14        ;	
wire[27: 0]	o_15        ;	
wire[27: 0]	o_16        ;	
wire[27: 0]	o_17        ;	
wire[27: 0]	o_18        ;	
wire[27: 0]	o_19        ;	
wire[27: 0]	o_20        ;	
wire[27: 0]	o_21        ;	
wire[27: 0]	o_22        ;	
wire[27: 0]	o_23        ;	
wire[27: 0]	o_24        ;	
wire[27: 0]	o_25        ;	
wire[27: 0]	o_26        ;	
wire[27: 0]	o_27        ;
wire[27: 0]	o_28        ;	
wire[27: 0]	o_29        ;	
wire[27: 0]	o_30        ;	
wire[27: 0]	o_31        ;	

//---------------------------------------------------------------------------//

be_level0 u0_be_level0(
	.i_inverse   (i_inverse  ),
	.i_transize  (i_transize ),
	.i_0         (i_0        ),	
	.i_1         (i_1        ),	
	.i_2         (i_2        ),	
	.i_3         (i_3        ),	
	.i_4         (i_4        ),	
	.i_5         (i_5        ),	
	.i_6         (i_6        ),	
	.i_7         (i_7        ),	
	.i_8         (i_8        ),	
	.i_9         (i_9        ),	
	.i_10        (i_10       ),	
	.i_11        (i_11       ),	
	.i_12        (i_12       ),	
	.i_13        (i_13       ),	
	.i_14        (i_14       ),	
	.i_15        (i_15       ),	
	.i_16        (i_16       ),	
	.i_17        (i_17       ),	
	.i_18        (i_18       ),	
	.i_19        (i_19       ),	
	.i_20        (i_20       ),	
	.i_21        (i_21       ),	
	.i_22        (i_22       ),	
	.i_23        (i_23       ),	
	.i_24        (i_24       ),	
	.i_25        (i_25       ),	
	.i_26        (i_26       ),	
	.i_27        (i_27       ),	
	.i_28        (i_28       ),	
	.i_29        (i_29       ),	
	.i_30        (i_30       ),	
	.i_31        (i_31       ),
//------------------------	
	.o_0         (level0_0   ),	
	.o_1         (level0_1   ),	
	.o_2         (level0_2   ),	
	.o_3         (level0_3   ),	
	.o_4         (level0_4   ),	
	.o_5         (level0_5   ),	
	.o_6         (level0_6   ),	
	.o_7         (level0_7   ),	
	.o_8         (level0_8   ),	
	.o_9         (level0_9   ),	
	.o_10        (level0_10  ),	
	.o_11        (level0_11  ),	
	.o_12        (level0_12  ),	
	.o_13        (level0_13  ),	
	.o_14        (level0_14  ),	
	.o_15        (level0_15  ),	
	.o_16        (level0_16  ),	
	.o_17        (level0_17  ),	
	.o_18        (level0_18  ),	
	.o_19        (level0_19  ),	
	.o_20        (level0_20  ),	
	.o_21        (level0_21  ),	
	.o_22        (level0_22  ),	
	.o_23        (level0_23  ),	
	.o_24        (level0_24  ),	
	.o_25        (level0_25  ),	
	.o_26        (level0_26  ),	
	.o_27        (level0_27  ),
	.o_28        (level0_28  ),	
	.o_29        (level0_29  ),	
	.o_30        (level0_30  ),	
	.o_31        (level0_31  )	
);

be_level1 u_be_level1(
	.clk         (clk        ),
	.rst_n       (rst_n      ),
	.i_dt_vld    (i_dt_vld   ),
	.i_inverse   (i_inverse  ),
	.i_transize  (i_transize ),
	.i_0         (level0_0   ),	
	.i_1         (level0_1   ),	
	.i_2         (level0_2   ),	
	.i_3         (level0_3   ),	
	.i_4         (level0_4   ),	
	.i_5         (level0_5   ),	
	.i_6         (level0_6   ),	
	.i_7         (level0_7   ),	
	.i_8         (level0_8   ),	
	.i_9         (level0_9   ),	
	.i_10        (level0_10  ),	
	.i_11        (level0_11  ),	
	.i_12        (level0_12  ),	
	.i_13        (level0_13  ),	
	.i_14        (level0_14  ),	
	.i_15        (level0_15  ),	
	.i_16        (level0_16  ),	
	.i_17        (level0_17  ),	
	.i_18        (level0_18  ),	
	.i_19        (level0_19  ),	
	.i_20        (level0_20  ),	
	.i_21        (level0_21  ),	
	.i_22        (level0_22  ),	
	.i_23        (level0_23  ),	
	.i_24        (level0_24  ),	
	.i_25        (level0_25  ),	
	.i_26        (level0_26  ),	
	.i_27        (level0_27  ),	
	.i_28        (level0_28  ),	
	.i_29        (level0_29  ),	
	.i_30        (level0_30  ),	
	.i_31        (level0_31  ),
//------------------------	
	.o_0         (level1_0   ),	
	.o_1         (level1_1   ),	
	.o_2         (level1_2   ),	
	.o_3         (level1_3   ),	
	.o_4         (level1_4   ),	
	.o_5         (level1_5   ),	
	.o_6         (level1_6   ),	
	.o_7         (level1_7   ),	
	.o_8         (level1_8   ),	
	.o_9         (level1_9   ),	
	.o_10        (level1_10  ),	
	.o_11        (level1_11  ),	
	.o_12        (level1_12  ),	
	.o_13        (level1_13  ),	
	.o_14        (level1_14  ),	
	.o_15        (level1_15  ),	
	.o_16        (level1_16  ),	
	.o_17        (level1_17  ),	
	.o_18        (level1_18  ),	
	.o_19        (level1_19  ),	
	.o_20        (level1_20  ),	
	.o_21        (level1_21  ),	
	.o_22        (level1_22  ),	
	.o_23        (level1_23  ),	
	.o_24        (level1_24  ),	
	.o_25        (level1_25  ),	
	.o_26        (level1_26  ),	
	.o_27        (level1_27  ),
	.o_28        (level1_28  ),	
	.o_29        (level1_29  ),	
	.o_30        (level1_30  ),	
	.o_31        (level1_31  )	
);

be_level0 u2_be_level0(
	.i_inverse   (~i_inverse ),
	.i_transize  (i_transize ),
	.i_0         (level1_0   ),	
	.i_1         (level1_1   ),	
	.i_2         (level1_2   ),	
	.i_3         (level1_3   ),	
	.i_4         (level1_4   ),	
	.i_5         (level1_5   ),	
	.i_6         (level1_6   ),	
	.i_7         (level1_7   ),	
	.i_8         (level1_8   ),	
	.i_9         (level1_9   ),	
	.i_10        (level1_10  ),	
	.i_11        (level1_11  ),	
	.i_12        (level1_12  ),	
	.i_13        (level1_13  ),	
	.i_14        (level1_14  ),	
	.i_15        (level1_15  ),	
	.i_16        (level1_16  ),	
	.i_17        (level1_17  ),	
	.i_18        (level1_18  ),	
	.i_19        (level1_19  ),	
	.i_20        (level1_20  ),	
	.i_21        (level1_21  ),	
	.i_22        (level1_22  ),	
	.i_23        (level1_23  ),	
	.i_24        (level1_24  ),	
	.i_25        (level1_25  ),	
	.i_26        (level1_26  ),	
	.i_27        (level1_27  ),	
	.i_28        (level1_28  ),	
	.i_29        (level1_29  ),	
	.i_30        (level1_30  ),	
	.i_31        (level1_31  ),
//------------------------	
	.o_0         (level2_0   ),	
	.o_1         (level2_1   ),	
	.o_2         (level2_2   ),	
	.o_3         (level2_3   ),	
	.o_4         (level2_4   ),	
	.o_5         (level2_5   ),	
	.o_6         (level2_6   ),	
	.o_7         (level2_7   ),	
	.o_8         (level2_8   ),	
	.o_9         (level2_9   ),	
	.o_10        (level2_10  ),	
	.o_11        (level2_11  ),	
	.o_12        (level2_12  ),	
	.o_13        (level2_13  ),	
	.o_14        (level2_14  ),	
	.o_15        (level2_15  ),	
	.o_16        (level2_16  ),	
	.o_17        (level2_17  ),	
	.o_18        (level2_18  ),	
	.o_19        (level2_19  ),	
	.o_20        (level2_20  ),	
	.o_21        (level2_21  ),	
	.o_22        (level2_22  ),	
	.o_23        (level2_23  ),	
	.o_24        (level2_24  ),	
	.o_25        (level2_25  ),	
	.o_26        (level2_26  ),	
	.o_27        (level2_27  ),
	.o_28        (level2_28  ),	
	.o_29        (level2_29  ),	
	.o_30        (level2_30  ),	
	.o_31        (level2_31  )	
);

be_delay    u_be_delay(
	.clk         (clk        ),
	.rst_n       (rst_n      ),
	.i_dt_vld    (i_dt_vld   ),
	.i_transize  (i_transize ),
	.i_0         (level2_0   ),	
	.i_1         (level2_1   ),	
	.i_2         (level2_2   ),	
	.i_3         (level2_3   ),	
	.i_4         (level2_4   ),	
	.i_5         (level2_5   ),	
	.i_6         (level2_6   ),	
	.i_7         (level2_7   ),	
	.i_8         (level2_8   ),	
	.i_9         (level2_9   ),	
	.i_10        (level2_10  ),	
	.i_11        (level2_11  ),	
	.i_12        (level2_12  ),	
	.i_13        (level2_13  ),	
	.i_14        (level2_14  ),	
	.i_15        (level2_15  ),	
	.i_16        (level2_16  ),	
	.i_17        (level2_17  ),	
	.i_18        (level2_18  ),	
	.i_19        (level2_19  ),	
	.i_20        (level2_20  ),	
	.i_21        (level2_21  ),	
	.i_22        (level2_22  ),	
	.i_23        (level2_23  ),	
	.i_24        (level2_24  ),	
	.i_25        (level2_25  ),	
	.i_26        (level2_26  ),	
	.i_27        (level2_27  ),	
	.i_28        (level2_28  ),	
	.i_29        (level2_29  ),	
	.i_30        (level2_30  ),	
	.i_31        (level2_31  ),
	.i_org_0     (i_0        ),	
	.i_org_1     (i_1        ),	
	.i_org_2     (i_2        ),	
	.i_org_3     (i_3        ),	
	.i_org_4     (i_4        ),	
	.i_org_5     (i_5        ),	
	.i_org_6     (i_6        ),	
	.i_org_7     (i_7        ),	
	.i_org_8     (i_8        ),	
	.i_org_9     (i_9        ),	
	.i_org_10    (i_10       ),	
	.i_org_11    (i_11       ),	
	.i_org_12    (i_12       ),	
	.i_org_13    (i_13       ),	
	.i_org_14    (i_14       ),	
	.i_org_15    (i_15       ),	
	.i_org_16    (i_16       ),	
	.i_org_17    (i_17       ),	
	.i_org_18    (i_18       ),	
	.i_org_19    (i_19       ),	
	.i_org_20    (i_20       ),	
	.i_org_21    (i_21       ),	
	.i_org_22    (i_22       ),	
	.i_org_23    (i_23       ),	
	.i_org_24    (i_24       ),	
	.i_org_25    (i_25       ),	
	.i_org_26    (i_26       ),	
	.i_org_27    (i_27       ),
	.i_org_28    (i_28       ),	
	.i_org_29    (i_29       ),	
	.i_org_30    (i_30       ),	
	.i_org_31    (i_31       ),
//--------------------       ----
	.o_dt_vld    (o_dt_vld   ),	
	.o_0         (o_0        ),	
	.o_1         (o_1        ),	
	.o_2         (o_2        ),	
	.o_3         (o_3        ),	
	.o_4         (o_4        ),	
	.o_5         (o_5        ),	
	.o_6         (o_6        ),	
	.o_7         (o_7        ),	
	.o_8         (o_8        ),	
	.o_9         (o_9        ),	
	.o_10        (o_10       ),	
	.o_11        (o_11       ),	
	.o_12        (o_12       ),	
	.o_13        (o_13       ),	
	.o_14        (o_14       ),	
	.o_15        (o_15       ),	
	.o_16        (o_16       ),	
	.o_17        (o_17       ),	
	.o_18        (o_18       ),	
	.o_19        (o_19       ),	
	.o_20        (o_20       ),	
	.o_21        (o_21       ),	
	.o_22        (o_22       ),	
	.o_23        (o_23       ),	
	.o_24        (o_24       ),	
	.o_25        (o_25       ),	
	.o_26        (o_26       ),	
	.o_27        (o_27       ),
	.o_28        (o_28       ),	
	.o_29        (o_29       ),	
	.o_30        (o_30       ),	
	.o_31        (o_31       )	
);



endmodule

 
