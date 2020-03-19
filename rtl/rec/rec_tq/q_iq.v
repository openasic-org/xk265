
`include "enc_defines.v"

module   q_iq(
          clk       ,
          rst       ,
       	  type_i    ,
          qp_i      ,
      	  tq_en_i   ,
	  inverse   ,
      	  i_valid   ,
    	  tq_size_i ,
         
          i_0       ,                     
          i_1       ,
          i_2       ,
          i_3       ,
          i_4       ,
          i_5       ,
          i_6       ,
          i_7       ,
          i_8       ,
          i_9       ,
          i_10      ,
          i_11      ,
          i_12      ,
          i_13      ,
          i_14      ,
          i_15      ,
          i_16      ,
          i_17      ,
          i_18      ,
          i_19      ,
          i_20      ,
          i_21      ,
          i_22      ,
          i_23      ,
          i_24      ,
          i_25      ,
          i_26      ,
          i_27      ,
          i_28      ,
          i_29      ,
          i_30      ,
          i_31      ,
    	  cef_data_i,
          
     	  cef_wen_o , 		     
	  cef_widx_o, 	 
	  cef_data_o,  
	  cef_ren_o ,     
    	  cef_ridx_o, 
          o_valid   ,
          o_0       ,                     
          o_1       ,
          o_2       ,
          o_3       ,
          o_4       ,
          o_5       ,
          o_6       ,
          o_7       ,
          o_8       ,
          o_9       ,
          o_10      ,
          o_11      ,
          o_12      ,
          o_13      ,
          o_14      ,
          o_15      ,
          o_16      ,
          o_17      ,
          o_18      ,
          o_19      ,
          o_20      ,
          o_21      ,
          o_22      ,
          o_23      ,
          o_24      ,
          o_25      ,
          o_26      ,
          o_27      ,
          o_28      ,
          o_29      ,
          o_30      ,
          o_31      
 );    

// ********************************************
//                                             
//    INPUT / OUTPUT DECLARATION               
//                                             
// ********************************************
  
input                    clk      ;
input                    rst      ;
input                    type_i   ;
input                    tq_en_i  ;
input                    inverse  ;
input                    i_valid  ;
input     [5:0]          qp_i     ;
input     [1:0]          tq_size_i;

input  signed   [15:0]   i_0      ;
input  signed   [15:0]   i_1      ;
input  signed   [15:0]   i_2      ;
input  signed   [15:0]   i_3      ;
input  signed   [15:0]   i_4      ;
input  signed   [15:0]   i_5      ;
input  signed   [15:0]   i_6      ;
input  signed   [15:0]   i_7      ;
input  signed   [15:0]   i_8      ;
input  signed   [15:0]   i_9      ;
input  signed   [15:0]   i_10     ;
input  signed   [15:0]   i_11     ;
input  signed   [15:0]   i_12     ;
input  signed   [15:0]   i_13     ;
input  signed   [15:0]   i_14     ;
input  signed   [15:0]   i_15     ;
input  signed   [15:0]   i_16     ;
input  signed   [15:0]   i_17     ;
input  signed   [15:0]   i_18     ;
input  signed   [15:0]   i_19     ;
input  signed   [15:0]   i_20     ;
input  signed   [15:0]   i_21     ;
input  signed   [15:0]   i_22     ;
input  signed   [15:0]   i_23     ;
input  signed   [15:0]   i_24     ;
input  signed   [15:0]   i_25     ;
input  signed   [15:0]   i_26     ;
input  signed   [15:0]   i_27     ;
input  signed   [15:0]   i_28     ;
input  signed   [15:0]   i_29     ;
input  signed   [15:0]   i_30     ;
input  signed   [15:0]   i_31     ;
input  [511:0]	         cef_data_i;  

output 			 cef_wen_o ; 	    
output [4:0]		 cef_widx_o; 	
output [511:0]           cef_data_o;                            
output 			 cef_ren_o ; 	    
output [4:0]		 cef_ridx_o; 
output                   o_valid   ;
output  signed   [15:0]        o_0 ;
output  signed   [15:0]        o_1 ;
output  signed   [15:0]        o_2 ;
output  signed   [15:0]        o_3 ;
output  signed   [15:0]        o_4 ;
output  signed   [15:0]        o_5 ;
output  signed   [15:0]        o_6 ;
output  signed   [15:0]        o_7 ;
output  signed   [15:0]        o_8 ;
output  signed   [15:0]        o_9 ;
output  signed   [15:0]        o_10;
output  signed   [15:0]        o_11;
output  signed   [15:0]        o_12;
output  signed   [15:0]        o_13;
output  signed   [15:0]        o_14;
output  signed   [15:0]        o_15;
output  signed   [15:0]        o_16;
output  signed   [15:0]        o_17;
output  signed   [15:0]        o_18;
output  signed   [15:0]        o_19;
output  signed   [15:0]        o_20;
output  signed   [15:0]        o_21;
output  signed   [15:0]        o_22;
output  signed   [15:0]        o_23;
output  signed   [15:0]        o_24;
output  signed   [15:0]        o_25;
output  signed   [15:0]        o_26;
output  signed   [15:0]        o_27;
output  signed   [15:0]        o_28;
output  signed   [15:0]        o_29;
output  signed   [15:0]        o_30;
output  signed   [15:0]        o_31;


// ********************************************
//                                             
//    WIRE DECLARATION                                               
//                                                                             
// ********************************************

wire                                 i_q_valid  ;
wire                                 i_q_valid_0;
wire                                 i_q_valid_4;
wire          signed   [15:0]        i_q_0      ;
wire          signed   [15:0]        i_q_1      ;
wire          signed   [15:0]        i_q_2      ;
wire          signed   [15:0]        i_q_3      ;
wire          signed   [15:0]        i_q_4      ;
wire          signed   [15:0]        i_q_5      ;
wire          signed   [15:0]        i_q_6      ;
wire          signed   [15:0]        i_q_7      ;
wire          signed   [15:0]        i_q_8      ;
wire          signed   [15:0]        i_q_9      ;
wire          signed   [15:0]        i_q_10     ;
wire          signed   [15:0]        i_q_11     ;
wire          signed   [15:0]        i_q_12     ;
wire          signed   [15:0]        i_q_13     ;
wire          signed   [15:0]        i_q_14     ;
wire          signed   [15:0]        i_q_15     ;
wire          signed   [15:0]        i_q_16     ;
wire          signed   [15:0]        i_q_17     ;
wire          signed   [15:0]        i_q_18     ;
wire          signed   [15:0]        i_q_19     ;
wire          signed   [15:0]        i_q_20     ;
wire          signed   [15:0]        i_q_21     ;
wire          signed   [15:0]        i_q_22     ;
wire          signed   [15:0]        i_q_23     ;
wire          signed   [15:0]        i_q_24     ;
wire          signed   [15:0]        i_q_25     ;
wire          signed   [15:0]        i_q_26     ;
wire          signed   [15:0]        i_q_27     ;
wire          signed   [15:0]        i_q_28     ;
wire          signed   [15:0]        i_q_29     ;
wire          signed   [15:0]        i_q_30     ;
wire          signed   [15:0]        i_q_31     ;

wire          signed   [15:0]         i4_0      ;
wire          signed   [15:0]         i4_1      ;
wire          signed   [15:0]         i4_2      ;
wire          signed   [15:0]         i4_3      ;
wire          signed   [15:0]         i4_4      ;
wire          signed   [15:0]         i4_5      ;
wire          signed   [15:0]         i4_6      ;
wire          signed   [15:0]         i4_7      ;
wire          signed   [15:0]         i4_8      ;
wire          signed   [15:0]         i4_9      ;
wire          signed   [15:0]         i4_10     ;
wire          signed   [15:0]         i4_11     ;
wire          signed   [15:0]         i4_12     ;
wire          signed   [15:0]         i4_13     ;
wire          signed   [15:0]         i4_14     ;
wire          signed   [15:0]         i4_15     ;
wire          signed   [15:0]         i4_16     ;
wire          signed   [15:0]         i4_17     ;
wire          signed   [15:0]         i4_18     ;
wire          signed   [15:0]         i4_19     ;
wire          signed   [15:0]         i4_20     ;
wire          signed   [15:0]         i4_21     ;
wire          signed   [15:0]         i4_22     ;
wire          signed   [15:0]         i4_23     ;
wire          signed   [15:0]         i4_24     ;
wire          signed   [15:0]         i4_25     ;
wire          signed   [15:0]         i4_26     ;
wire          signed   [15:0]         i4_27     ;
wire          signed   [15:0]         i4_28     ;
wire          signed   [15:0]         i4_29     ;
wire          signed   [15:0]         i4_30     ;
wire          signed   [15:0]         i4_31     ;
                                      
wire          signed   [15:0]         in_0      ;
wire          signed   [15:0]         in_1      ;
wire          signed   [15:0]         in_2      ;
wire          signed   [15:0]         in_3      ;
wire          signed   [15:0]         in_4      ;
wire          signed   [15:0]         in_5      ;
wire          signed   [15:0]         in_6      ;
wire          signed   [15:0]         in_7      ;
wire          signed   [15:0]         in_8      ;
wire          signed   [15:0]         in_9      ;
wire          signed   [15:0]         in_10     ;
wire          signed   [15:0]         in_11     ;
wire          signed   [15:0]         in_12     ;
wire          signed   [15:0]         in_13     ;
wire          signed   [15:0]         in_14     ;
wire          signed   [15:0]         in_15     ;
wire          signed   [15:0]         in_16     ;
wire          signed   [15:0]         in_17     ;
wire          signed   [15:0]         in_18     ;
wire          signed   [15:0]         in_19     ;
wire          signed   [15:0]         in_20     ;
wire          signed   [15:0]         in_21     ;
wire          signed   [15:0]         in_22     ;
wire          signed   [15:0]         in_23     ;
wire          signed   [15:0]         in_24     ;
wire          signed   [15:0]         in_25     ;
wire          signed   [15:0]         in_26     ;
wire          signed   [15:0]         in_27     ;
wire          signed   [15:0]         in_28     ;
wire          signed   [15:0]         in_29     ;
wire          signed   [15:0]         in_30     ;
wire          signed   [15:0]         in_31     ;

wire                                 o_q_valid;
wire          signed   [15:0]        o_q_0    ;
wire          signed   [15:0]        o_q_1    ;
wire          signed   [15:0]        o_q_2    ;
wire          signed   [15:0]        o_q_3    ;
wire          signed   [15:0]        o_q_4    ;
wire          signed   [15:0]        o_q_5    ;
wire          signed   [15:0]        o_q_6    ;
wire          signed   [15:0]        o_q_7    ;
wire          signed   [15:0]        o_q_8    ;
wire          signed   [15:0]        o_q_9    ;
wire          signed   [15:0]        o_q_10   ;
wire          signed   [15:0]        o_q_11   ;
wire          signed   [15:0]        o_q_12   ;
wire          signed   [15:0]        o_q_13   ;
wire          signed   [15:0]        o_q_14   ;
wire          signed   [15:0]        o_q_15   ;
wire          signed   [15:0]        o_q_16   ;
wire          signed   [15:0]        o_q_17   ;
wire          signed   [15:0]        o_q_18   ;
wire          signed   [15:0]        o_q_19   ;
wire          signed   [15:0]        o_q_20   ;
wire          signed   [15:0]        o_q_21   ;
wire          signed   [15:0]        o_q_22   ;
wire          signed   [15:0]        o_q_23   ;
wire          signed   [15:0]        o_q_24   ;
wire          signed   [15:0]        o_q_25   ;
wire          signed   [15:0]        o_q_26   ;
wire          signed   [15:0]        o_q_27   ;
wire          signed   [15:0]        o_q_28   ;
wire          signed   [15:0]        o_q_29   ;
wire          signed   [15:0]        o_q_30   ;
wire          signed   [15:0]        o_q_31   ;


wire          signed   [15:0]    i_coeff_0 ;
wire          signed   [15:0]    i_coeff_1 ;
wire          signed   [15:0]    i_coeff_2 ;
wire          signed   [15:0]    i_coeff_3 ;
wire          signed   [15:0]    i_coeff_4 ;
wire          signed   [15:0]    i_coeff_5 ;
wire          signed   [15:0]    i_coeff_6 ;
wire          signed   [15:0]    i_coeff_7 ;
wire          signed   [15:0]    i_coeff_8 ;
wire          signed   [15:0]    i_coeff_9 ;
wire          signed   [15:0]    i_coeff_10;
wire          signed   [15:0]    i_coeff_11;
wire          signed   [15:0]    i_coeff_12;
wire          signed   [15:0]    i_coeff_13;
wire          signed   [15:0]    i_coeff_14;
wire          signed   [15:0]    i_coeff_15;
wire          signed   [15:0]    i_coeff_16;
wire          signed   [15:0]    i_coeff_17;
wire          signed   [15:0]    i_coeff_18;
wire          signed   [15:0]    i_coeff_19;
wire          signed   [15:0]    i_coeff_20;
wire          signed   [15:0]    i_coeff_21;
wire          signed   [15:0]    i_coeff_22;
wire          signed   [15:0]    i_coeff_23;
wire          signed   [15:0]    i_coeff_24;
wire          signed   [15:0]    i_coeff_25;
wire          signed   [15:0]    i_coeff_26;
wire          signed   [15:0]    i_coeff_27;
wire          signed   [15:0]    i_coeff_28;
wire          signed   [15:0]    i_coeff_29;
wire          signed   [15:0]    i_coeff_30;
wire          signed   [15:0]    i_coeff_31;

wire          signed   [15:0]    o_coeff_0 ;
wire          signed   [15:0]    o_coeff_1 ;
wire          signed   [15:0]    o_coeff_2 ;
wire          signed   [15:0]    o_coeff_3 ;
wire          signed   [15:0]    o_coeff_4 ;
wire          signed   [15:0]    o_coeff_5 ;
wire          signed   [15:0]    o_coeff_6 ;
wire          signed   [15:0]    o_coeff_7 ;
wire          signed   [15:0]    o_coeff_8 ;
wire          signed   [15:0]    o_coeff_9 ;
wire          signed   [15:0]    o_coeff_10;
wire          signed   [15:0]    o_coeff_11;
wire          signed   [15:0]    o_coeff_12;
wire          signed   [15:0]    o_coeff_13;
wire          signed   [15:0]    o_coeff_14;
wire          signed   [15:0]    o_coeff_15;
wire          signed   [15:0]    o_coeff_16;
wire          signed   [15:0]    o_coeff_17;
wire          signed   [15:0]    o_coeff_18;
wire          signed   [15:0]    o_coeff_19;
wire          signed   [15:0]    o_coeff_20;
wire          signed   [15:0]    o_coeff_21;
wire          signed   [15:0]    o_coeff_22;
wire          signed   [15:0]    o_coeff_23;
wire          signed   [15:0]    o_coeff_24;
wire          signed   [15:0]    o_coeff_25;
wire          signed   [15:0]    o_coeff_26;
wire          signed   [15:0]    o_coeff_27;
wire          signed   [15:0]    o_coeff_28;
wire          signed   [15:0]    o_coeff_29;
wire          signed   [15:0]    o_coeff_30;
wire          signed   [15:0]    o_coeff_31;

// ********************************************
//                                             
//    WIRE DECLARATION                                               
//                                                                             
// ********************************************

reg                               cef_val_d1 ;
reg                               cef_val_d2 ;
reg                               cef_ren_o ;
reg            [4:0]              cef_ridx_o;
reg            [4:0]              cef_widx_o;
reg            [4:0]              counter_1 ;
reg            [4:0]              counter_2 ;

// **********************************************
//                                             
//    Combinational Logic                      
//                                             
// **********************************************

assign               i_q_valid_0=inverse?cef_val_d2:i_valid;
assign               i_q_valid_4=inverse?1'b0:(i_valid||o_q_valid);
assign               i_q_valid  =(tq_size_i==2'b00)?i_q_valid_4:i_q_valid_0;                
assign               i_q_0      =inverse?o_coeff_0 :in_0 ;
assign               i_q_1      =inverse?o_coeff_1 :in_1 ;
assign               i_q_2      =inverse?o_coeff_2 :in_2 ;
assign               i_q_3      =inverse?o_coeff_3 :in_3 ;
assign               i_q_4      =inverse?o_coeff_4 :in_4 ;
assign               i_q_5      =inverse?o_coeff_5 :in_5 ;
assign               i_q_6      =inverse?o_coeff_6 :in_6 ;
assign               i_q_7      =inverse?o_coeff_7 :in_7 ;
assign               i_q_8      =inverse?o_coeff_8 :in_8 ;
assign               i_q_9      =inverse?o_coeff_9 :in_9 ;
assign               i_q_10     =inverse?o_coeff_10:in_10;
assign               i_q_11     =inverse?o_coeff_11:in_11;
assign               i_q_12     =inverse?o_coeff_12:in_12;
assign               i_q_13     =inverse?o_coeff_13:in_13;
assign               i_q_14     =inverse?o_coeff_14:in_14;
assign               i_q_15     =inverse?o_coeff_15:in_15;
assign               i_q_16     =inverse?o_coeff_16:in_16;
assign               i_q_17     =inverse?o_coeff_17:in_17;
assign               i_q_18     =inverse?o_coeff_18:in_18;
assign               i_q_19     =inverse?o_coeff_19:in_19;
assign               i_q_20     =inverse?o_coeff_20:in_20;
assign               i_q_21     =inverse?o_coeff_21:in_21;
assign               i_q_22     =inverse?o_coeff_22:in_22;
assign               i_q_23     =inverse?o_coeff_23:in_23;
assign               i_q_24     =inverse?o_coeff_24:in_24;
assign               i_q_25     =inverse?o_coeff_25:in_25;
assign               i_q_26     =inverse?o_coeff_26:in_26;
assign               i_q_27     =inverse?o_coeff_27:in_27;
assign               i_q_28     =inverse?o_coeff_28:in_28;
assign               i_q_29     =inverse?o_coeff_29:in_29;
assign               i_q_30     =inverse?o_coeff_30:in_30;
assign               i_q_31     =inverse?o_coeff_31:in_31;

assign               i4_0       =i_valid?i_0 :o_q_0 ;
assign               i4_1       =i_valid?i_1 :o_q_1 ;
assign               i4_2       =i_valid?i_2 :o_q_2 ;
assign               i4_3       =i_valid?i_3 :o_q_3 ;
assign               i4_4       =i_valid?i_4 :o_q_4 ;
assign               i4_5       =i_valid?i_5 :o_q_5 ;
assign               i4_6       =i_valid?i_6 :o_q_6 ;
assign               i4_7       =i_valid?i_7 :o_q_7 ;
assign               i4_8       =i_valid?i_8 :o_q_8 ;
assign               i4_9       =i_valid?i_9 :o_q_9 ;
assign               i4_10      =i_valid?i_10:o_q_10;
assign               i4_11      =i_valid?i_11:o_q_11;
assign               i4_12      =i_valid?i_12:o_q_12;
assign               i4_13      =i_valid?i_13:o_q_13;
assign               i4_14      =i_valid?i_14:o_q_14;
assign               i4_15      =i_valid?i_15:o_q_15;
assign               i4_16      =i_valid?i_16:o_q_16;
assign               i4_17      =i_valid?i_17:o_q_17;
assign               i4_18      =i_valid?i_18:o_q_18;
assign               i4_19      =i_valid?i_19:o_q_19;
assign               i4_20      =i_valid?i_20:o_q_20;
assign               i4_21      =i_valid?i_21:o_q_21;
assign               i4_22      =i_valid?i_22:o_q_22;
assign               i4_23      =i_valid?i_23:o_q_23;
assign               i4_24      =i_valid?i_24:o_q_24;
assign               i4_25      =i_valid?i_25:o_q_25;
assign               i4_26      =i_valid?i_26:o_q_26;
assign               i4_27      =i_valid?i_27:o_q_27;
assign               i4_28      =i_valid?i_28:o_q_28;
assign               i4_29      =i_valid?i_29:o_q_29;
assign               i4_30      =i_valid?i_30:o_q_30;
assign               i4_31      =i_valid?i_31:o_q_31;

assign               in_0 =(tq_size_i==2'b00)?i4_0 :i_0 ;
assign               in_1 =(tq_size_i==2'b00)?i4_1 :i_1 ;
assign               in_2 =(tq_size_i==2'b00)?i4_2 :i_2 ;
assign               in_3 =(tq_size_i==2'b00)?i4_3 :i_3 ;
assign               in_4 =(tq_size_i==2'b00)?i4_4 :i_4 ;
assign               in_5 =(tq_size_i==2'b00)?i4_5 :i_5 ;
assign               in_6 =(tq_size_i==2'b00)?i4_6 :i_6 ;
assign               in_7 =(tq_size_i==2'b00)?i4_7 :i_7 ;
assign               in_8 =(tq_size_i==2'b00)?i4_8 :i_8 ;
assign               in_9 =(tq_size_i==2'b00)?i4_9 :i_9 ;
assign               in_10=(tq_size_i==2'b00)?i4_10:i_10;
assign               in_11=(tq_size_i==2'b00)?i4_11:i_11;
assign               in_12=(tq_size_i==2'b00)?i4_12:i_12;
assign               in_13=(tq_size_i==2'b00)?i4_13:i_13;
assign               in_14=(tq_size_i==2'b00)?i4_14:i_14;
assign               in_15=(tq_size_i==2'b00)?i4_15:i_15;
assign               in_16=(tq_size_i==2'b00)?i4_16:i_16;
assign               in_17=(tq_size_i==2'b00)?i4_17:i_17;
assign               in_18=(tq_size_i==2'b00)?i4_18:i_18;
assign               in_19=(tq_size_i==2'b00)?i4_19:i_19;
assign               in_20=(tq_size_i==2'b00)?i4_20:i_20;
assign               in_21=(tq_size_i==2'b00)?i4_21:i_21;
assign               in_22=(tq_size_i==2'b00)?i4_22:i_22;
assign               in_23=(tq_size_i==2'b00)?i4_23:i_23;
assign               in_24=(tq_size_i==2'b00)?i4_24:i_24;
assign               in_25=(tq_size_i==2'b00)?i4_25:i_25;
assign               in_26=(tq_size_i==2'b00)?i4_26:i_26;
assign               in_27=(tq_size_i==2'b00)?i4_27:i_27;
assign               in_28=(tq_size_i==2'b00)?i4_28:i_28;
assign               in_29=(tq_size_i==2'b00)?i4_29:i_29;
assign               in_30=(tq_size_i==2'b00)?i4_30:i_30;
assign               in_31=(tq_size_i==2'b00)?i4_31:i_31;

assign               cef_wen_o =inverse?1'b0:o_q_valid;
assign               i_coeff_0 =inverse?16'b0:o_q_0 ;
assign               i_coeff_1 =inverse?16'b0:o_q_1 ;
assign               i_coeff_2 =inverse?16'b0:o_q_2 ;
assign               i_coeff_3 =inverse?16'b0:o_q_3 ;
assign               i_coeff_4 =inverse?16'b0:o_q_4 ;
assign               i_coeff_5 =inverse?16'b0:o_q_5 ;
assign               i_coeff_6 =inverse?16'b0:o_q_6 ;
assign               i_coeff_7 =inverse?16'b0:o_q_7 ;
assign               i_coeff_8 =inverse?16'b0:o_q_8 ;
assign               i_coeff_9 =inverse?16'b0:o_q_9 ;
assign               i_coeff_10=inverse?16'b0:o_q_10;
assign               i_coeff_11=inverse?16'b0:o_q_11;
assign               i_coeff_12=inverse?16'b0:o_q_12;
assign               i_coeff_13=inverse?16'b0:o_q_13;
assign               i_coeff_14=inverse?16'b0:o_q_14;
assign               i_coeff_15=inverse?16'b0:o_q_15;
assign               i_coeff_16=inverse?16'b0:o_q_16;
assign               i_coeff_17=inverse?16'b0:o_q_17;
assign               i_coeff_18=inverse?16'b0:o_q_18;
assign               i_coeff_19=inverse?16'b0:o_q_19;
assign               i_coeff_20=inverse?16'b0:o_q_20;
assign               i_coeff_21=inverse?16'b0:o_q_21;
assign               i_coeff_22=inverse?16'b0:o_q_22;
assign               i_coeff_23=inverse?16'b0:o_q_23;
assign               i_coeff_24=inverse?16'b0:o_q_24;
assign               i_coeff_25=inverse?16'b0:o_q_25;
assign               i_coeff_26=inverse?16'b0:o_q_26;
assign               i_coeff_27=inverse?16'b0:o_q_27;
assign               i_coeff_28=inverse?16'b0:o_q_28;
assign               i_coeff_29=inverse?16'b0:o_q_29;
assign               i_coeff_30=inverse?16'b0:o_q_30;
assign               i_coeff_31=inverse?16'b0:o_q_31;

assign               cef_data_o={i_coeff_31,i_coeff_30,i_coeff_29,i_coeff_28,
                                 i_coeff_27,i_coeff_26,i_coeff_25,i_coeff_24,
                                 i_coeff_23,i_coeff_22,i_coeff_21,i_coeff_20,
		                 i_coeff_19,i_coeff_18,i_coeff_17,i_coeff_16,
                                 i_coeff_15,i_coeff_14,i_coeff_13,i_coeff_12,
			         i_coeff_11,i_coeff_10,i_coeff_9 ,i_coeff_8 ,
                                 i_coeff_7 ,i_coeff_6 ,i_coeff_5 ,i_coeff_4 ,
			         i_coeff_3 ,i_coeff_2 ,i_coeff_1 ,i_coeff_0
                                 };
                                   
reg [511 :0] cef_data_reg;
always@(posedge clk or negedge rst)
begin
	if(!rst)
		cef_data_reg <= 512'd0;
	else
		cef_data_reg <= cef_data_i;
end


 
assign                  o_coeff_0 =cef_data_reg[15 :0  ];
assign                  o_coeff_1 =cef_data_reg[31 :16 ];
assign                  o_coeff_2 =cef_data_reg[47 :32 ];
assign                  o_coeff_3 =cef_data_reg[63 :48 ];
assign                  o_coeff_4 =cef_data_reg[79 :64 ];
assign                  o_coeff_5 =cef_data_reg[95 :80 ];
assign                  o_coeff_6 =cef_data_reg[111:96 ];
assign                  o_coeff_7 =cef_data_reg[127:112];
assign                  o_coeff_8 =cef_data_reg[143:128];
assign                  o_coeff_9 =cef_data_reg[159:144];
assign                  o_coeff_10=cef_data_reg[175:160];
assign                  o_coeff_11=cef_data_reg[191:176];
assign                  o_coeff_12=cef_data_reg[207:192];
assign                  o_coeff_13=cef_data_reg[223:208];
assign                  o_coeff_14=cef_data_reg[239:224];
assign                  o_coeff_15=cef_data_reg[255:240];
assign                  o_coeff_16=cef_data_reg[271:256];
assign                  o_coeff_17=cef_data_reg[287:272];
assign                  o_coeff_18=cef_data_reg[303:288];
assign                  o_coeff_19=cef_data_reg[319:304];
assign                  o_coeff_20=cef_data_reg[335:320];
assign                  o_coeff_21=cef_data_reg[351:336];
assign                  o_coeff_22=cef_data_reg[367:352];
assign                  o_coeff_23=cef_data_reg[383:368];
assign                  o_coeff_24=cef_data_reg[399:384];
assign                  o_coeff_25=cef_data_reg[415:400];
assign                  o_coeff_26=cef_data_reg[431:416];
assign                  o_coeff_27=cef_data_reg[447:432];
assign                  o_coeff_28=cef_data_reg[463:448];
assign                  o_coeff_29=cef_data_reg[479:464];
assign                  o_coeff_30=cef_data_reg[495:480];
assign                  o_coeff_31=cef_data_reg[511:496];

assign                  o_valid=inverse?o_q_valid:1'b0;
assign                  o_0 =inverse?o_q_0 :16'd0;
assign                  o_1 =inverse?o_q_1 :16'd0;
assign                  o_2 =inverse?o_q_2 :16'd0;
assign                  o_3 =inverse?o_q_3 :16'd0;
assign                  o_4 =inverse?o_q_4 :16'd0;
assign                  o_5 =inverse?o_q_5 :16'd0;
assign                  o_6 =inverse?o_q_6 :16'd0;
assign                  o_7 =inverse?o_q_7 :16'd0;
assign                  o_8 =inverse?o_q_8 :16'd0;
assign                  o_9 =inverse?o_q_9 :16'd0;
assign                  o_10=inverse?o_q_10:16'd0;
assign                  o_11=inverse?o_q_11:16'd0;
assign                  o_12=inverse?o_q_12:16'd0;
assign                  o_13=inverse?o_q_13:16'd0;
assign                  o_14=inverse?o_q_14:16'd0;
assign                  o_15=inverse?o_q_15:16'd0;
assign                  o_16=inverse?o_q_16:16'd0;
assign                  o_17=inverse?o_q_17:16'd0;
assign                  o_18=inverse?o_q_18:16'd0;
assign                  o_19=inverse?o_q_19:16'd0;
assign                  o_20=inverse?o_q_20:16'd0;
assign                  o_21=inverse?o_q_21:16'd0;
assign                  o_22=inverse?o_q_22:16'd0;
assign                  o_23=inverse?o_q_23:16'd0;
assign                  o_24=inverse?o_q_24:16'd0;
assign                  o_25=inverse?o_q_25:16'd0;
assign                  o_26=inverse?o_q_26:16'd0;
assign                  o_27=inverse?o_q_27:16'd0;
assign                  o_28=inverse?o_q_28:16'd0;
assign                  o_29=inverse?o_q_29:16'd0;
assign                  o_30=inverse?o_q_30:16'd0;
assign                  o_31=inverse?o_q_31:16'd0;

always@(*)
begin
case(tq_size_i)
  	2'b00:
	begin
        	cef_widx_o=5'd0;
        	cef_ridx_o=5'd0;
      	end
  	2'b01:
	begin
        	cef_widx_o=(counter_1<<2);
        	cef_ridx_o=(counter_2<<2);
      	end
  	2'b10:
	begin
        	cef_widx_o=(counter_1<<1);
        	cef_ridx_o=(counter_2<<1);
      	end
  	default:
	begin
        	cef_widx_o=counter_1;
        	cef_ridx_o=counter_2;
      	end
endcase
end
       

// ***************************************************
//                                             
//    Sequential  Logic                        
//                                             
// ***************************************************

always@(posedge clk or negedge rst)
begin
	if(!rst)
		counter_1<=5'd0;
	else if(cef_wen_o)
 		counter_1<=counter_1+1'b1;
	else
 		counter_1<=5'd0;
 end

always@(posedge clk or negedge rst)
begin
	if(!rst)
		counter_2<=5'd0;
	else if(cef_ren_o)
 		counter_2<=counter_2+1'b1;
	else
 		counter_2<=5'd0;
end
 
always@(posedge clk or negedge rst)
begin
	if(!rst)
 		cef_ren_o<=1'b0;
	else if(cef_wen_o)
 	case(tq_size_i)
 		2'b00:	cef_ren_o<=1'b0;
 		2'b01:	if(counter_1==5'd1)
        			cef_ren_o<=1'b1;
			else
				cef_ren_o<=1'b0;
 		2'b10:	if(counter_1==5'd7)
        			cef_ren_o<=1'b1;
			else
				cef_ren_o<=1'b0;		
		default:if(counter_1==5'd31)
        			cef_ren_o<=1'b1;
			else
				cef_ren_o<=1'b0;
 	endcase
	else
	case(tq_size_i)
	 	2'b00:	cef_ren_o<=1'b0;
	 	2'b01:	if(counter_2==5'd1)
	       			cef_ren_o<=1'b0;
	 	2'b10:	if(counter_2==5'd7)
	       			cef_ren_o<=1'b0;
	 	default:if(counter_2==5'd31)
	       			cef_ren_o<=1'b0;
	endcase     
end

always@(posedge clk or negedge rst)
begin
	if(!rst)
 		cef_val_d1<=1'b0;
	else
  		cef_val_d1<=cef_ren_o;
end
always@(posedge clk or negedge rst)
begin
	if(!rst)
 		cef_val_d2<=1'b0;
	else
  		cef_val_d2<=cef_val_d1;
end
//*************************************************
//
//   SUB  MODULE
//
//**************************************************

quan  quan_0(
        .clk       (clk      ),
        .rst       (rst      ),
        .type_i    (type_i   ),
        .qp        (qp_i     ),
        .i_valid   (tq_en_i  ),
        .i_2d_valid(i_q_valid),
        .i_transize(tq_size_i),
           
        .i_0       (i_q_0    ),                     
        .i_1       (i_q_1    ),
        .i_2       (i_q_2    ),
        .i_3       (i_q_3    ),
        .i_4       (i_q_4    ),
        .i_5       (i_q_5    ),
        .i_6       (i_q_6    ),
        .i_7       (i_q_7    ),
        .i_8       (i_q_8    ),
        .i_9       (i_q_9    ),
        .i_10      (i_q_10   ),
        .i_11      (i_q_11   ),
        .i_12      (i_q_12   ),
        .i_13      (i_q_13   ),
        .i_14      (i_q_14   ),
        .i_15      (i_q_15   ),
        .i_16      (i_q_16   ),
        .i_17      (i_q_17   ),
        .i_18      (i_q_18   ),
        .i_19      (i_q_19   ),
        .i_20      (i_q_20   ),
        .i_21      (i_q_21   ),
        .i_22      (i_q_22   ),
        .i_23      (i_q_23   ),
        .i_24      (i_q_24   ),
        .i_25      (i_q_25   ),
        .i_26      (i_q_26   ),
        .i_27      (i_q_27   ),
        .i_28      (i_q_28   ),
        .i_29      (i_q_29   ),
        .i_30      (i_q_30   ),
        .i_31      (i_q_31   ),
            
       .o_valid    (o_q_valid),
       .o_0        (o_q_0    ),                     
       .o_1        (o_q_1    ),
       .o_2        (o_q_2    ),
       .o_3        (o_q_3    ),
       .o_4        (o_q_4    ),
       .o_5        (o_q_5    ),
       .o_6        (o_q_6    ),
       .o_7        (o_q_7    ),
       .o_8        (o_q_8    ),
       .o_9        (o_q_9    ),
       .o_10       (o_q_10   ),
       .o_11       (o_q_11   ),
       .o_12       (o_q_12   ),
       .o_13       (o_q_13   ),
       .o_14       (o_q_14   ),
       .o_15       (o_q_15   ),
       .o_16       (o_q_16   ),
       .o_17       (o_q_17   ),
       .o_18       (o_q_18   ),
       .o_19       (o_q_19   ),
       .o_20       (o_q_20   ),
       .o_21       (o_q_21   ),
       .o_22       (o_q_22   ),
       .o_23       (o_q_23   ),
       .o_24       (o_q_24   ),
       .o_25       (o_q_25   ),
       .o_26       (o_q_26   ),
       .o_27       (o_q_27   ),
       .o_28       (o_q_28   ),
       .o_29       (o_q_29   ),
       .o_30       (o_q_30   ),
       .o_31       (o_q_31   )
);

endmodule
