`include "enc_defines.v"

module tq_top(
				clk         	        ,   
				rst           	        ,
				type_i                  ,//0:intra ;1:inter
				qp_i		        ,
				
				tq_en_i  		,//valid high
				tq_sel_i 		,//00,01;luma ; 01:cr; 11:cb
				tq_size_i		,//block size  00:4x4;01:8x8;10:16x16;11:32x32
			//	tq_idx_i		,//residual idex
				tq_res_i 		,//residual data
				
				rec_val_o 		,//reconstruction sig
				rec_idx_o		,//reconstruction sig
				rec_data_o 		,//reconstruction sig
				
				cef_wen_o 		,//
				cef_widx_o		,
				cef_data_o 		,
				
				cef_ren_o		,
				cef_ridx_o ,
				cef_data_i
);


//---- parameter declaration --------------------------
parameter      CNT_04 = 7 , 
               CNT_08 = 17,
               CNT_16 = 25,
               CNT_32 = 49;

parameter RSP_WIDTH = 10 ;

// ********************************************
//                                             
//    INPUT / OUTPUT DECLARATION               
//                                             
// ********************************************
input	                clk	        ;	
input			rst	        ;		
input                   type_i          ;
input  [5:0] 		qp_i            ;       	
input 			tq_en_i         ;
input  [1:0]		tq_sel_i        ;
input  [1:0]		tq_size_i	;
//input  [4:0]		tq_idx_i	;
input  [287:0]	        tq_res_i	;
input [511:0]		cef_data_i	;    
		
output 			rec_val_o	;
output [4:0]		rec_idx_o	;
output [32*RSP_WIDTH-1:0]	        rec_data_o	;

output 			cef_wen_o	;
output [4:0]		cef_widx_o	;
output [511:0]		cef_data_o	;

output 			cef_ren_o	;
output [4:0]		cef_ridx_o	;


// ********************************************
//                                             
//    Register DECLARATION                         
//                                             
// ********************************************

reg                                counter_en;
reg                            counter_val_en;
reg              [4:0]            counter_val;
reg              [5:0]                counter;
reg              [4:0]            counter_rec;
reg              [4:0]              rec_idx_o;

 
// ********************************************
//                                             
//    Wire DECLARATION                         
//                                             
// ********************************************

wire                                    i_val;
wire                                  inverse;
wire 			[5:0] 				   qp_yuv;

wire  signed    [8:0]                    i_0 ;
wire  signed    [8:0]                    i_1 ;
wire  signed    [8:0]                    i_2 ;
wire  signed    [8:0]                    i_3 ;
wire  signed    [8:0]                    i_4 ;
wire  signed    [8:0]                    i_5 ;
wire  signed    [8:0]                    i_6 ;
wire  signed    [8:0]                    i_7 ;
wire  signed    [8:0]                    i_8 ;
wire  signed    [8:0]                    i_9 ;
wire  signed    [8:0]                    i_10;
wire  signed    [8:0]                    i_11;
wire  signed    [8:0]                    i_12;
wire  signed    [8:0]                    i_13;
wire  signed    [8:0]                    i_14;
wire  signed    [8:0]                    i_15;
wire  signed    [8:0]                    i_16;
wire  signed    [8:0]                    i_17;
wire  signed    [8:0]                    i_18;
wire  signed    [8:0]                    i_19;
wire  signed    [8:0]                    i_20;
wire  signed    [8:0]                    i_21;
wire  signed    [8:0]                    i_22;
wire  signed    [8:0]                    i_23;
wire  signed    [8:0]                    i_24;
wire  signed    [8:0]                    i_25;
wire  signed    [8:0]                    i_26;
wire  signed    [8:0]                    i_27;
wire  signed    [8:0]                    i_28;
wire  signed    [8:0]                    i_29;
wire  signed    [8:0]                    i_30;
wire  signed    [8:0]                    i_31;

wire                                i_d_valid;
wire  signed    [15:0]                 i_d_0 ;
wire  signed    [15:0]                 i_d_1 ;
wire  signed    [15:0]                 i_d_2 ;
wire  signed    [15:0]                 i_d_3 ;
wire  signed    [15:0]                 i_d_4 ;
wire  signed    [15:0]                 i_d_5 ;
wire  signed    [15:0]                 i_d_6 ;
wire  signed    [15:0]                 i_d_7 ;
wire  signed    [15:0]                 i_d_8 ;
wire  signed    [15:0]                 i_d_9 ;
wire  signed    [15:0]                 i_d_10;
wire  signed    [15:0]                 i_d_11;
wire  signed    [15:0]                 i_d_12;
wire  signed    [15:0]                 i_d_13;
wire  signed    [15:0]                 i_d_14;
wire  signed    [15:0]                 i_d_15;
wire  signed    [15:0]                 i_d_16;
wire  signed    [15:0]                 i_d_17;
wire  signed    [15:0]                 i_d_18;
wire  signed    [15:0]                 i_d_19;
wire  signed    [15:0]                 i_d_20;
wire  signed    [15:0]                 i_d_21;
wire  signed    [15:0]                 i_d_22;
wire  signed    [15:0]                 i_d_23;
wire  signed    [15:0]                 i_d_24;
wire  signed    [15:0]                 i_d_25;
wire  signed    [15:0]                 i_d_26;
wire  signed    [15:0]                 i_d_27;
wire  signed    [15:0]                 i_d_28;
wire  signed    [15:0]                 i_d_29;
wire  signed    [15:0]                 i_d_30;
wire  signed    [15:0]                 i_d_31;

wire                                o_d_valid;
wire  signed    [15:0]                 o_d_0 ;
wire  signed    [15:0]                 o_d_1 ;
wire  signed    [15:0]                 o_d_2 ;
wire  signed    [15:0]                 o_d_3 ;
wire  signed    [15:0]                 o_d_4 ;
wire  signed    [15:0]                 o_d_5 ;
wire  signed    [15:0]                 o_d_6 ;
wire  signed    [15:0]                 o_d_7 ;
wire  signed    [15:0]                 o_d_8 ;
wire  signed    [15:0]                 o_d_9 ;
wire  signed    [15:0]                 o_d_10;
wire  signed    [15:0]                 o_d_11;
wire  signed    [15:0]                 o_d_12;
wire  signed    [15:0]                 o_d_13;
wire  signed    [15:0]                 o_d_14;
wire  signed    [15:0]                 o_d_15;
wire  signed    [15:0]                 o_d_16;
wire  signed    [15:0]                 o_d_17;
wire  signed    [15:0]                 o_d_18;
wire  signed    [15:0]                 o_d_19;
wire  signed    [15:0]                 o_d_20;
wire  signed    [15:0]                 o_d_21;
wire  signed    [15:0]                 o_d_22;
wire  signed    [15:0]                 o_d_23;
wire  signed    [15:0]                 o_d_24;
wire  signed    [15:0]                 o_d_25;
wire  signed    [15:0]                 o_d_26;
wire  signed    [15:0]                 o_d_27;
wire  signed    [15:0]                 o_d_28;
wire  signed    [15:0]                 o_d_29;
wire  signed    [15:0]                 o_d_30;
wire  signed    [15:0]                 o_d_31;

wire                                i_q_valid;
wire  signed    [15:0]                 i_q_0 ;
wire  signed    [15:0]                 i_q_1 ;
wire  signed    [15:0]                 i_q_2 ;
wire  signed    [15:0]                 i_q_3 ;
wire  signed    [15:0]                 i_q_4 ;
wire  signed    [15:0]                 i_q_5 ;
wire  signed    [15:0]                 i_q_6 ;
wire  signed    [15:0]                 i_q_7 ;
wire  signed    [15:0]                 i_q_8 ;
wire  signed    [15:0]                 i_q_9 ;
wire  signed    [15:0]                 i_q_10;
wire  signed    [15:0]                 i_q_11;
wire  signed    [15:0]                 i_q_12;
wire  signed    [15:0]                 i_q_13;
wire  signed    [15:0]                 i_q_14;
wire  signed    [15:0]                 i_q_15;
wire  signed    [15:0]                 i_q_16;
wire  signed    [15:0]                 i_q_17;
wire  signed    [15:0]                 i_q_18;
wire  signed    [15:0]                 i_q_19;
wire  signed    [15:0]                 i_q_20;
wire  signed    [15:0]                 i_q_21;
wire  signed    [15:0]                 i_q_22;
wire  signed    [15:0]                 i_q_23;
wire  signed    [15:0]                 i_q_24;
wire  signed    [15:0]                 i_q_25;
wire  signed    [15:0]                 i_q_26;
wire  signed    [15:0]                 i_q_27;
wire  signed    [15:0]                 i_q_28;
wire  signed    [15:0]                 i_q_29;
wire  signed    [15:0]                 i_q_30;
wire  signed    [15:0]                 i_q_31;

wire                                o_q_valid;
wire  signed    [15:0]                 o_q_0 ;
wire  signed    [15:0]                 o_q_1 ;
wire  signed    [15:0]                 o_q_2 ;
wire  signed    [15:0]                 o_q_3 ;
wire  signed    [15:0]                 o_q_4 ;
wire  signed    [15:0]                 o_q_5 ;
wire  signed    [15:0]                 o_q_6 ;
wire  signed    [15:0]                 o_q_7 ;
wire  signed    [15:0]                 o_q_8 ;
wire  signed    [15:0]                 o_q_9 ;
wire  signed    [15:0]                 o_q_10;
wire  signed    [15:0]                 o_q_11;
wire  signed    [15:0]                 o_q_12;
wire  signed    [15:0]                 o_q_13;
wire  signed    [15:0]                 o_q_14;
wire  signed    [15:0]                 o_q_15;
wire  signed    [15:0]                 o_q_16;
wire  signed    [15:0]                 o_q_17;
wire  signed    [15:0]                 o_q_18;
wire  signed    [15:0]                 o_q_19;
wire  signed    [15:0]                 o_q_20;
wire  signed    [15:0]                 o_q_21;
wire  signed    [15:0]                 o_q_22;
wire  signed    [15:0]                 o_q_23;
wire  signed    [15:0]                 o_q_24;
wire  signed    [15:0]                 o_q_25;
wire  signed    [15:0]                 o_q_26;
wire  signed    [15:0]                 o_q_27;
wire  signed    [15:0]                 o_q_28;
wire  signed    [15:0]                 o_q_29;
wire  signed    [15:0]                 o_q_30;
wire  signed    [15:0]                 o_q_31;

wire  signed    [9:0]                    o_0 ;
wire  signed    [9:0]                    o_1 ;
wire  signed    [9:0]                    o_2 ;
wire  signed    [9:0]                    o_3 ;
wire  signed    [9:0]                    o_4 ;
wire  signed    [9:0]                    o_5 ;
wire  signed    [9:0]                    o_6 ;
wire  signed    [9:0]                    o_7 ;
wire  signed    [9:0]                    o_8 ;
wire  signed    [9:0]                    o_9 ;
wire  signed    [9:0]                    o_10;
wire  signed    [9:0]                    o_11;
wire  signed    [9:0]                    o_12;
wire  signed    [9:0]                    o_13;
wire  signed    [9:0]                    o_14;
wire  signed    [9:0]                    o_15;
wire  signed    [9:0]                    o_16;
wire  signed    [9:0]                    o_17;
wire  signed    [9:0]                    o_18;
wire  signed    [9:0]                    o_19;
wire  signed    [9:0]                    o_20;
wire  signed    [9:0]                    o_21;
wire  signed    [9:0]                    o_22;
wire  signed    [9:0]                    o_23;
wire  signed    [9:0]                    o_24;
wire  signed    [9:0]                    o_25;
wire  signed    [9:0]                    o_26;
wire  signed    [9:0]                    o_27;
wire  signed    [9:0]                    o_28;
wire  signed    [9:0]                    o_29;
wire  signed    [9:0]                    o_30;
wire  signed    [9:0]                    o_31;

// ********************************************
//                                             
//    Combinational Logic                      
//                                             
// ********************************************

assign      i_val=tq_en_i||counter_val_en;
assign      inverse=~(i_val||counter_en);

assign      i_0 =tq_res_i[8  :0  ];
assign      i_1 =tq_res_i[17 :9  ];
assign      i_2 =tq_res_i[26 :18 ];
assign      i_3 =tq_res_i[35 :27 ];
assign      i_4 =tq_res_i[44 :36 ];
assign      i_5 =tq_res_i[53 :45 ];
assign      i_6 =tq_res_i[62 :54 ];
assign      i_7 =tq_res_i[71 :63 ];
assign      i_8 =tq_res_i[80 :72 ];
assign      i_9 =tq_res_i[89 :81 ];
assign      i_10=tq_res_i[98 :90 ];
assign      i_11=tq_res_i[107:99 ];
assign      i_12=tq_res_i[116:108];
assign      i_13=tq_res_i[125:117];
assign      i_14=tq_res_i[134:126];
assign      i_15=tq_res_i[143:135];
assign      i_16=tq_res_i[152:144];
assign      i_17=tq_res_i[161:153];
assign      i_18=tq_res_i[170:162];
assign      i_19=tq_res_i[179:171];
assign      i_20=tq_res_i[188:180];
assign      i_21=tq_res_i[197:189];
assign      i_22=tq_res_i[206:198];
assign      i_23=tq_res_i[215:207];
assign      i_24=tq_res_i[224:216];
assign      i_25=tq_res_i[233:225];
assign      i_26=tq_res_i[242:234];
assign      i_27=tq_res_i[251:243];
assign      i_28=tq_res_i[260:252];
assign      i_29=tq_res_i[269:261];
assign      i_30=tq_res_i[278:270];
assign      i_31=tq_res_i[287:279];

assign      i_d_valid=inverse?o_q_valid:tq_en_i;
assign      i_d_0    =inverse?o_q_0 :{{7{i_0[8] }},i_0} ;
assign      i_d_1    =inverse?o_q_1 :{{7{i_1[8] }},i_1} ;
assign      i_d_2    =inverse?o_q_2 :{{7{i_2[8] }},i_2} ;
assign      i_d_3    =inverse?o_q_3 :{{7{i_3[8] }},i_3} ;
assign      i_d_4    =inverse?o_q_4 :{{7{i_4[8] }},i_4} ;
assign      i_d_5    =inverse?o_q_5 :{{7{i_5[8] }},i_5} ;
assign      i_d_6    =inverse?o_q_6 :{{7{i_6[8] }},i_6} ;
assign      i_d_7    =inverse?o_q_7 :{{7{i_7[8] }},i_7} ;
assign      i_d_8    =inverse?o_q_8 :{{7{i_8[8] }},i_8} ;
assign      i_d_9    =inverse?o_q_9 :{{7{i_9[8] }},i_9} ;
assign      i_d_10   =inverse?o_q_10:{{7{i_10[8]}},i_10};
assign      i_d_11   =inverse?o_q_11:{{7{i_11[8]}},i_11};
assign      i_d_12   =inverse?o_q_12:{{7{i_12[8]}},i_12};
assign      i_d_13   =inverse?o_q_13:{{7{i_13[8]}},i_13};
assign      i_d_14   =inverse?o_q_14:{{7{i_14[8]}},i_14};
assign      i_d_15   =inverse?o_q_15:{{7{i_15[8]}},i_15};
assign      i_d_16   =inverse?o_q_16:{{7{i_16[8]}},i_16};
assign      i_d_17   =inverse?o_q_17:{{7{i_17[8]}},i_17};
assign      i_d_18   =inverse?o_q_18:{{7{i_18[8]}},i_18};
assign      i_d_19   =inverse?o_q_19:{{7{i_19[8]}},i_19};
assign      i_d_20   =inverse?o_q_20:{{7{i_20[8]}},i_20};
assign      i_d_21   =inverse?o_q_21:{{7{i_21[8]}},i_21};
assign      i_d_22   =inverse?o_q_22:{{7{i_22[8]}},i_22};
assign      i_d_23   =inverse?o_q_23:{{7{i_23[8]}},i_23};
assign      i_d_24   =inverse?o_q_24:{{7{i_24[8]}},i_24};
assign      i_d_25   =inverse?o_q_25:{{7{i_25[8]}},i_25};
assign      i_d_26   =inverse?o_q_26:{{7{i_26[8]}},i_26};
assign      i_d_27   =inverse?o_q_27:{{7{i_27[8]}},i_27};
assign      i_d_28   =inverse?o_q_28:{{7{i_28[8]}},i_28};
assign      i_d_29   =inverse?o_q_29:{{7{i_29[8]}},i_29};
assign      i_d_30   =inverse?o_q_30:{{7{i_30[8]}},i_30};
assign      i_d_31   =inverse?o_q_31:{{7{i_31[8]}},i_31};

assign      i_q_valid=inverse?1'b0 :o_d_valid;
assign      i_q_0    =inverse?16'd0:o_d_0 ;
assign      i_q_1    =inverse?16'd0:o_d_1 ;
assign      i_q_2    =inverse?16'd0:o_d_2 ;
assign      i_q_3    =inverse?16'd0:o_d_3 ;
assign      i_q_4    =inverse?16'd0:o_d_4 ;
assign      i_q_5    =inverse?16'd0:o_d_5 ;
assign      i_q_6    =inverse?16'd0:o_d_6 ;
assign      i_q_7    =inverse?16'd0:o_d_7 ;
assign      i_q_8    =inverse?16'd0:o_d_8 ;
assign      i_q_9    =inverse?16'd0:o_d_9 ;
assign      i_q_10   =inverse?16'd0:o_d_10;
assign      i_q_11   =inverse?16'd0:o_d_11;
assign      i_q_12   =inverse?16'd0:o_d_12;
assign      i_q_13   =inverse?16'd0:o_d_13;
assign      i_q_14   =inverse?16'd0:o_d_14;
assign      i_q_15   =inverse?16'd0:o_d_15;
assign      i_q_16   =inverse?16'd0:o_d_16;
assign      i_q_17   =inverse?16'd0:o_d_17;
assign      i_q_18   =inverse?16'd0:o_d_18;
assign      i_q_19   =inverse?16'd0:o_d_19;
assign      i_q_20   =inverse?16'd0:o_d_20;
assign      i_q_21   =inverse?16'd0:o_d_21;
assign      i_q_22   =inverse?16'd0:o_d_22;
assign      i_q_23   =inverse?16'd0:o_d_23;
assign      i_q_24   =inverse?16'd0:o_d_24;
assign      i_q_25   =inverse?16'd0:o_d_25;
assign      i_q_26   =inverse?16'd0:o_d_26;
assign      i_q_27   =inverse?16'd0:o_d_27;
assign      i_q_28   =inverse?16'd0:o_d_28;
assign      i_q_29   =inverse?16'd0:o_d_29;
assign      i_q_30   =inverse?16'd0:o_d_30;
assign      i_q_31   =inverse?16'd0:o_d_31;

assign      rec_val_o=inverse?o_d_valid:1'b0;
assign      o_0      =inverse?{o_d_0[15], o_d_0[8:0] }:10'd0;
assign      o_1      =inverse?{o_d_1[15], o_d_1[8:0] }:10'd0;
assign      o_2      =inverse?{o_d_2[15], o_d_2[8:0] }:10'd0;
assign      o_3      =inverse?{o_d_3[15], o_d_3[8:0] }:10'd0;
assign      o_4      =inverse?{o_d_4[15], o_d_4[8:0] }:10'd0;
assign      o_5      =inverse?{o_d_5[15], o_d_5[8:0] }:10'd0;
assign      o_6      =inverse?{o_d_6[15], o_d_6[8:0] }:10'd0;
assign      o_7      =inverse?{o_d_7[15], o_d_7[8:0] }:10'd0;
assign      o_8      =inverse?{o_d_8[15], o_d_8[8:0] }:10'd0;
assign      o_9      =inverse?{o_d_9[15], o_d_9[8:0] }:10'd0;
assign      o_10     =inverse?{o_d_10[15], o_d_10[8:0]}:10'd0;
assign      o_11     =inverse?{o_d_11[15], o_d_11[8:0]}:10'd0;
assign      o_12     =inverse?{o_d_12[15], o_d_12[8:0]}:10'd0;
assign      o_13     =inverse?{o_d_13[15], o_d_13[8:0]}:10'd0;
assign      o_14     =inverse?{o_d_14[15], o_d_14[8:0]}:10'd0;
assign      o_15     =inverse?{o_d_15[15], o_d_15[8:0]}:10'd0;
assign      o_16     =inverse?{o_d_16[15], o_d_16[8:0]}:10'd0;
assign      o_17     =inverse?{o_d_17[15], o_d_17[8:0]}:10'd0;
assign      o_18     =inverse?{o_d_18[15], o_d_18[8:0]}:10'd0;
assign      o_19     =inverse?{o_d_19[15], o_d_19[8:0]}:10'd0;
assign      o_20     =inverse?{o_d_20[15], o_d_20[8:0]}:10'd0;
assign      o_21     =inverse?{o_d_21[15], o_d_21[8:0]}:10'd0;
assign      o_22     =inverse?{o_d_22[15], o_d_22[8:0]}:10'd0;
assign      o_23     =inverse?{o_d_23[15], o_d_23[8:0]}:10'd0;
assign      o_24     =inverse?{o_d_24[15], o_d_24[8:0]}:10'd0;
assign      o_25     =inverse?{o_d_25[15], o_d_25[8:0]}:10'd0;
assign      o_26     =inverse?{o_d_26[15], o_d_26[8:0]}:10'd0;
assign      o_27     =inverse?{o_d_27[15], o_d_27[8:0]}:10'd0;
assign      o_28     =inverse?{o_d_28[15], o_d_28[8:0]}:10'd0;
assign      o_29     =inverse?{o_d_29[15], o_d_29[8:0]}:10'd0;
assign      o_30     =inverse?{o_d_30[15], o_d_30[8:0]}:10'd0;
assign      o_31     =inverse?{o_d_31[15], o_d_31[8:0]}:10'd0;

assign      rec_data_o[1 *RSP_WIDTH-1:0 *RSP_WIDTH]=o_0 ;
assign      rec_data_o[2 *RSP_WIDTH-1:1 *RSP_WIDTH]=o_1 ;
assign      rec_data_o[3 *RSP_WIDTH-1:2 *RSP_WIDTH]=o_2 ;
assign      rec_data_o[4 *RSP_WIDTH-1:3 *RSP_WIDTH]=o_3 ;
assign      rec_data_o[5 *RSP_WIDTH-1:4 *RSP_WIDTH]=o_4 ;
assign      rec_data_o[6 *RSP_WIDTH-1:5 *RSP_WIDTH]=o_5 ;
assign      rec_data_o[7 *RSP_WIDTH-1:6 *RSP_WIDTH]=o_6 ;
assign      rec_data_o[8 *RSP_WIDTH-1:7 *RSP_WIDTH]=o_7 ;
assign      rec_data_o[9 *RSP_WIDTH-1:8 *RSP_WIDTH]=o_8 ;
assign      rec_data_o[10*RSP_WIDTH-1:9 *RSP_WIDTH]=o_9 ;
assign      rec_data_o[11*RSP_WIDTH-1:10*RSP_WIDTH]=o_10;
assign      rec_data_o[12*RSP_WIDTH-1:11*RSP_WIDTH]=o_11;
assign      rec_data_o[13*RSP_WIDTH-1:12*RSP_WIDTH]=o_12;
assign      rec_data_o[14*RSP_WIDTH-1:13*RSP_WIDTH]=o_13;
assign      rec_data_o[15*RSP_WIDTH-1:14*RSP_WIDTH]=o_14;
assign      rec_data_o[16*RSP_WIDTH-1:15*RSP_WIDTH]=o_15;
assign      rec_data_o[17*RSP_WIDTH-1:16*RSP_WIDTH]=o_16;
assign      rec_data_o[18*RSP_WIDTH-1:17*RSP_WIDTH]=o_17;
assign      rec_data_o[19*RSP_WIDTH-1:18*RSP_WIDTH]=o_18;
assign      rec_data_o[20*RSP_WIDTH-1:19*RSP_WIDTH]=o_19;
assign      rec_data_o[21*RSP_WIDTH-1:20*RSP_WIDTH]=o_20;
assign      rec_data_o[22*RSP_WIDTH-1:21*RSP_WIDTH]=o_21;
assign      rec_data_o[23*RSP_WIDTH-1:22*RSP_WIDTH]=o_22;
assign      rec_data_o[24*RSP_WIDTH-1:23*RSP_WIDTH]=o_23;
assign      rec_data_o[25*RSP_WIDTH-1:24*RSP_WIDTH]=o_24;
assign      rec_data_o[26*RSP_WIDTH-1:25*RSP_WIDTH]=o_25;
assign      rec_data_o[27*RSP_WIDTH-1:26*RSP_WIDTH]=o_26;
assign      rec_data_o[28*RSP_WIDTH-1:27*RSP_WIDTH]=o_27;
assign      rec_data_o[29*RSP_WIDTH-1:28*RSP_WIDTH]=o_28;
assign      rec_data_o[30*RSP_WIDTH-1:29*RSP_WIDTH]=o_29;
assign      rec_data_o[31*RSP_WIDTH-1:30*RSP_WIDTH]=o_30;
assign      rec_data_o[32*RSP_WIDTH-1:31*RSP_WIDTH]=o_31;

always@(*)
case(tq_size_i)
    2'b00  :rec_idx_o=5'd0;
    2'b01  :rec_idx_o=(counter_rec<<2);
    2'b10  :rec_idx_o=(counter_rec<<1);
    default:rec_idx_o=counter_rec;
endcase
  

// ********************************************
//                                             
//    Sequential  Logic                        
//                                             
// ********************************************

always@(posedge clk or negedge rst)
begin
if(!rst)
 	counter_val<=5'd0;
else
  	if(tq_en_i)
    	case(tq_size_i)
     		2'b00:
        		counter_val<=5'd0;
     		2'b01:
        		if(counter_val==5'd1)
           			counter_val<=5'd0;
        		else
           			counter_val<=counter_val+1'b1;
     		2'b10:
        		if(counter_val==5'd7)
           			counter_val<=5'd0;
         		else
           			counter_val<=counter_val+1'b1;
     		default:
        		if(counter_val==5'd31)
           			counter_val<=5'd0;
         		else
           			counter_val<=counter_val+1'b1;      
    	endcase
end

always@(posedge clk or negedge rst)
begin
	if(!rst)
		counter_val_en<=1'b0;
	else
  	case(tq_size_i)
   		2'b00:counter_val_en<=1'b0;
   		2'b01:
		begin
         		if((counter_val==5'd0)&&(tq_en_i))
         			counter_val_en<=1'b1;
         		else if((counter_val==5'd1)&&(tq_en_i))
         			counter_val_en<=1'b0;
          	end
   		2'b10:
		begin
         		if((counter_val==5'd0)&&(tq_en_i))
            			counter_val_en<=1'b1;
        		else if((counter_val==5'd7)&&(tq_en_i))
            			counter_val_en<=1'b0;
          	end
   		2'b11:
		begin
         		if((counter_val==5'd0)&&(tq_en_i))
            			counter_val_en<=1'b1;
        		else if((counter_val==5'd31)&&(tq_en_i))
            			counter_val_en<=1'b0;
          	end
  	endcase
end

always@(posedge clk or negedge rst)
begin
 	if(!rst)
   		counter_en<=1'b0;
 	else
    	case(tq_size_i)
   		2'b00:
		begin
      			if(tq_en_i)
         			counter_en<=1'b1;
      			else if(counter==CNT_04)
         			counter_en<=1'b0;
     		end
   		2'b01:
		begin
      			if(tq_en_i&&(counter_val==5'd1))
        			counter_en<=1'b1;
    			else if(counter==CNT_08)
       				counter_en<=1'b0;
     		end
   		2'b10:
		begin
      			if(tq_en_i&&(counter_val==5'd7))
        			counter_en<=1'b1;
      			else if(counter==CNT_16)
       				counter_en<=1'b0;
     		end 
   		2'b11:
		begin
      			if(tq_en_i&&(counter_val==5'd31))
        			counter_en<=1'b1;
      			else if(counter==CNT_32)
       				counter_en<=1'b0;
     		end 
   	endcase
end
   
always@(posedge clk or negedge rst)
begin
	if(!rst)
      		counter<=6'd0;
    	else if(((tq_size_i=='d0)&&(counter==CNT_04))||
	        ((tq_size_i=='d1)&&(counter==CNT_08))||
		((tq_size_i=='d2)&&(counter==CNT_16))||
		((tq_size_i=='d3)&&(counter==CNT_32)))
		counter <= 6'b0;
    	else if(counter_en)
        	counter<=counter+1'b1;
     	else
        	counter<=6'd0;
end	   
	   
always@(posedge clk or negedge rst)
begin
	if(!rst)
  		counter_rec<=5'd0;
	else
  		if(rec_val_o)
    		case(tq_size_i)
      			2'b00:counter_rec<=5'd0;
      			2'b01:  if(counter_rec==5'd1)
           				counter_rec<=5'd0;
	        		else
	         			counter_rec<=5'd1;
      			2'b10:  if(counter_rec==5'd7)
           				counter_rec<=5'd0;
	        		else
	         			counter_rec<=counter_rec+1'b1;
     			default:if(counter_rec==5'd31)
           				counter_rec<=5'd0;
	        		else
	        	 		counter_rec<=counter_rec+1'b1;
    		endcase
 	else
    		counter_rec<=5'd0; 
end   
// ********************************************
//                                             
//    Sub Modules                              
//                                             
// ********************************************

dct_top_2d      dct_2d(
                  .clk      (clk      ),
                  .rst_n    (rst      ),
		  .i_inverse(inverse  ),
              	  .i_valid  (i_d_valid),
                  .i_transize(tq_size_i),
	          .i_tq_sel (tq_sel_i ),
                                      
                  .i_0    (i_d_0    ),
                  .i_1    (i_d_1    ),
                  .i_2    (i_d_2    ),
                  .i_3    (i_d_3    ),
                  .i_4    (i_d_4    ),
                  .i_5    (i_d_5    ),
                  .i_6    (i_d_6    ),
                  .i_7    (i_d_7    ),
                  .i_8    (i_d_8    ),
                  .i_9    (i_d_9    ),
                  .i_10   (i_d_10   ),
                  .i_11   (i_d_11   ),
                  .i_12   (i_d_12   ),
                  .i_13   (i_d_13   ),
                  .i_14   (i_d_14   ),
                  .i_15   (i_d_15   ),
                  .i_16   (i_d_16   ),
                  .i_17   (i_d_17   ),
                  .i_18   (i_d_18   ),
                  .i_19   (i_d_19   ),
                  .i_20   (i_d_20   ),
                  .i_21   (i_d_21   ),
                  .i_22   (i_d_22   ),
                  .i_23   (i_d_23   ),
                  .i_24   (i_d_24   ),
                  .i_25   (i_d_25   ),
                  .i_26   (i_d_26   ),
                  .i_27   (i_d_27   ),
                  .i_28   (i_d_28   ),
                  .i_29   (i_d_29   ),
                  .i_30   (i_d_30   ),
                  .i_31   (i_d_31   ),
                                      
                  .o_valid(o_d_valid),
                  .o_0    (o_d_0    ),
                  .o_1    (o_d_1    ),
                  .o_2    (o_d_2    ),
                  .o_3    (o_d_3    ),
                  .o_4    (o_d_4    ),
                  .o_5    (o_d_5    ),
                  .o_6    (o_d_6    ),
                  .o_7    (o_d_7    ),
                  .o_8    (o_d_8    ),
                  .o_9    (o_d_9    ),
                  .o_10   (o_d_10   ),
                  .o_11   (o_d_11   ),
                  .o_12   (o_d_12   ),
                  .o_13   (o_d_13   ),
                  .o_14   (o_d_14   ),
                  .o_15   (o_d_15   ),
                  .o_16   (o_d_16   ),
                  .o_17   (o_d_17   ),
                  .o_18   (o_d_18   ),
                  .o_19   (o_d_19   ),
                  .o_20   (o_d_20   ),
                  .o_21   (o_d_21   ),
                  .o_22   (o_d_22   ),
                  .o_23   (o_d_23   ),
                  .o_24   (o_d_24   ),
                  .o_25   (o_d_25   ),
                  .o_26   (o_d_26   ),
                  .o_27   (o_d_27   ),
                  .o_28   (o_d_28   ),
                  .o_29   (o_d_29   ),
                  .o_30   (o_d_30   ),
                  .o_31   (o_d_31   )
);

chroma_qp u_chroma_qp(
		.qp_i 		( qp_i 		),
		.sel_i      ( tq_sel_i  ),
		.qp_o 		( qp_yuv    )
);


  q_iq     q_iq_0(
                  .clk       (clk       ),
                  .rst       (rst       ),
                  .type_i    (type_i    ),
                  .qp_i      (qp_yuv    ),
                  .tq_en_i   (tq_en_i   ),
	          .inverse   (inverse   ),
                  .i_valid (i_q_valid ),
                  .tq_size_i (tq_size_i ),
                               
                  .i_0     (i_q_0     ),                     
                  .i_1     (i_q_1     ),
                  .i_2     (i_q_2     ),
                  .i_3     (i_q_3     ),
                  .i_4     (i_q_4     ),
                  .i_5     (i_q_5     ),
                  .i_6     (i_q_6     ),
                  .i_7     (i_q_7     ),
                  .i_8     (i_q_8     ),
                  .i_9     (i_q_9     ),
                  .i_10    (i_q_10    ),
                  .i_11    (i_q_11    ),
                  .i_12    (i_q_12    ),
                  .i_13    (i_q_13    ),
                  .i_14    (i_q_14    ),
                  .i_15    (i_q_15    ),
                  .i_16    (i_q_16    ),
                  .i_17    (i_q_17    ),
                  .i_18    (i_q_18    ),
                  .i_19    (i_q_19    ),
                  .i_20    (i_q_20    ),
                  .i_21    (i_q_21    ),
                  .i_22    (i_q_22    ),
                  .i_23    (i_q_23    ),
                  .i_24    (i_q_24    ),
                  .i_25    (i_q_25    ),
                  .i_26    (i_q_26    ),
                  .i_27    (i_q_27    ),
                  .i_28    (i_q_28    ),
                  .i_29    (i_q_29    ),
                  .i_30    (i_q_30    ),
                  .i_31    (i_q_31    ),
	          .cef_data_i(cef_data_i),
                                      
                  .cef_wen_o (cef_wen_o ),	     
        	  .cef_widx_o(cef_widx_o), 
        	  .cef_data_o(cef_data_o), 
		  .cef_ren_o (cef_ren_o ),	     
		  .cef_ridx_o(cef_ridx_o),
                  .o_valid   (o_q_valid ),
                  .o_0       (o_q_0     ),                     
                  .o_1       (o_q_1     ),
                  .o_2       (o_q_2     ),
                  .o_3       (o_q_3     ),
                  .o_4       (o_q_4     ),
                  .o_5       (o_q_5     ),
                  .o_6       (o_q_6     ),
                  .o_7       (o_q_7     ),
                  .o_8       (o_q_8     ),
                  .o_9       (o_q_9     ),
                  .o_10      (o_q_10    ),
                  .o_11      (o_q_11    ),
                  .o_12      (o_q_12    ),
                  .o_13      (o_q_13    ),
                  .o_14      (o_q_14    ),
                  .o_15      (o_q_15    ),
                  .o_16      (o_q_16    ),
                  .o_17      (o_q_17    ),
                  .o_18      (o_q_18    ),
                  .o_19      (o_q_19    ),
                  .o_20      (o_q_20    ),
                  .o_21      (o_q_21    ),
                  .o_22      (o_q_22    ),
                  .o_23      (o_q_23    ),
                  .o_24      (o_q_24    ),
                  .o_25      (o_q_25    ),
                  .o_26      (o_q_26    ),
                  .o_27      (o_q_27    ),
                  .o_28      (o_q_28    ),
                  .o_29      (o_q_29    ),
                  .o_30      (o_q_30    ),
                  .o_31      (o_q_31    )
 );    

endmodule
