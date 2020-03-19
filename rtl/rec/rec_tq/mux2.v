//company       : xm tech
//project name  : H265i
//top module    : dct_top_2d.v
//data          : 2018.01.25
//file name     : mux2.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module mux_2(
          i_0_valid ,// org in
          i_0_0     ,
          i_0_1     ,
          i_0_2     ,
          i_0_3     ,
          i_0_4     ,
          i_0_5     ,
          i_0_6     ,
          i_0_7     ,
          i_0_8     ,
          i_0_9     ,
          i_0_10    ,
          i_0_11    ,
          i_0_12    ,
          i_0_13    ,
          i_0_14    ,
          i_0_15    ,
          i_0_16    ,
          i_0_17    ,
          i_0_18    ,
          i_0_19    ,
          i_0_20    ,
          i_0_21    ,
          i_0_22    ,
          i_0_23    ,
          i_0_24    ,
          i_0_25    ,
          i_0_26    ,
          i_0_27    ,
          i_0_28    ,
          i_0_29    ,
          i_0_30    ,
          i_0_31    ,
          
          i_1_valid ,//tr in
          i_1_0     ,
          i_1_1     ,
          i_1_2     ,
          i_1_3     ,
          i_1_4     ,
          i_1_5     ,
          i_1_6     ,
          i_1_7     ,
          i_1_8     ,
          i_1_9     ,
          i_1_10    ,
          i_1_11    ,
          i_1_12    ,
          i_1_13    ,
          i_1_14    ,
          i_1_15    ,
          i_1_16    ,
          i_1_17    ,
          i_1_18    ,
          i_1_19    ,
          i_1_20    ,
          i_1_21    ,
          i_1_22    ,
          i_1_23    ,
          i_1_24    ,
          i_1_25    ,
          i_1_26    ,
          i_1_27    ,
          i_1_28    ,
          i_1_29    ,
          i_1_30    ,
          i_1_31    ,
           
//----------------------------------//
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

input                       i_0_valid   ;//org
input      [15:0]           i_0_0       ;//signed
input      [15:0]           i_0_1       ;//signed
input      [15:0]           i_0_2       ;//signed
input      [15:0]           i_0_3       ;//signed
input      [15:0]           i_0_4       ;//signed
input      [15:0]           i_0_5       ;//signed
input      [15:0]           i_0_6       ;//signed
input      [15:0]           i_0_7       ;//signed
input      [15:0]           i_0_8       ;//signed
input      [15:0]           i_0_9       ;//signed
input      [15:0]           i_0_10      ;//signed
input      [15:0]           i_0_11      ;//signed
input      [15:0]           i_0_12      ;//signed
input      [15:0]           i_0_13      ;//signed
input      [15:0]           i_0_14      ;//signed
input      [15:0]           i_0_15      ;//signed
input      [15:0]           i_0_16      ;//signed
input      [15:0]           i_0_17      ;//signed
input      [15:0]           i_0_18      ;//signed
input      [15:0]           i_0_19      ;//signed
input      [15:0]           i_0_20      ;//signed
input      [15:0]           i_0_21      ;//signed
input      [15:0]           i_0_22      ;//signed
input      [15:0]           i_0_23      ;//signed
input      [15:0]           i_0_24      ;//signed
input      [15:0]           i_0_25      ;//signed
input      [15:0]           i_0_26      ;//signed
input      [15:0]           i_0_27      ;//signed
input      [15:0]           i_0_28      ;//signed
input      [15:0]           i_0_29      ;//signed
input      [15:0]           i_0_30      ;//signed
input      [15:0]           i_0_31      ;//signed

input                       i_1_valid   ;//trs
input      [15:0]           i_1_0       ;//signed
input      [15:0]           i_1_1       ;//signed
input      [15:0]           i_1_2       ;//signed
input      [15:0]           i_1_3       ;//signed
input      [15:0]           i_1_4       ;//signed
input      [15:0]           i_1_5       ;//signed
input      [15:0]           i_1_6       ;//signed
input      [15:0]           i_1_7       ;//signed
input      [15:0]           i_1_8       ;//signed
input      [15:0]           i_1_9       ;//signed
input      [15:0]           i_1_10      ;//signed
input      [15:0]           i_1_11      ;//signed
input      [15:0]           i_1_12      ;//signed
input      [15:0]           i_1_13      ;//signed
input      [15:0]           i_1_14      ;//signed
input      [15:0]           i_1_15      ;//signed
input      [15:0]           i_1_16      ;//signed
input      [15:0]           i_1_17      ;//signed
input      [15:0]           i_1_18      ;//signed
input      [15:0]           i_1_19      ;//signed
input      [15:0]           i_1_20      ;//signed
input      [15:0]           i_1_21      ;//signed
input      [15:0]           i_1_22      ;//signed
input      [15:0]           i_1_23      ;//signed
input      [15:0]           i_1_24      ;//signed
input      [15:0]           i_1_25      ;//signed
input      [15:0]           i_1_26      ;//signed
input      [15:0]           i_1_27      ;//signed
input      [15:0]           i_1_28      ;//signed
input      [15:0]           i_1_29      ;//signed
input      [15:0]           i_1_30      ;//signed
input      [15:0]           i_1_31      ;//signed

output  wire                    o_valid   ;
output  wire   [15:0]           o_0       ;//signed
output  wire   [15:0]           o_1       ;//signed
output  wire   [15:0]           o_2       ;//signed
output  wire   [15:0]           o_3       ;//signed
output  wire   [15:0]           o_4       ;//signed
output  wire   [15:0]           o_5       ;//signed
output  wire   [15:0]           o_6       ;//signed
output  wire   [15:0]           o_7       ;//signed
output  wire   [15:0]           o_8       ;//signed
output  wire   [15:0]           o_9       ;//signed
output  wire   [15:0]           o_10      ;//signed
output  wire   [15:0]           o_11      ;//signed
output  wire   [15:0]           o_12      ;//signed
output  wire   [15:0]           o_13      ;//signed
output  wire   [15:0]           o_14      ;//signed
output  wire   [15:0]           o_15      ;//signed
output  wire   [15:0]           o_16      ;//signed
output  wire   [15:0]           o_17      ;//signed
output  wire   [15:0]           o_18      ;//signed
output  wire   [15:0]           o_19      ;//signed
output  wire   [15:0]           o_20      ;//signed
output  wire   [15:0]           o_21      ;//signed
output  wire   [15:0]           o_22      ;//signed
output  wire   [15:0]           o_23      ;//signed
output  wire   [15:0]           o_24      ;//signed
output  wire   [15:0]           o_25      ;//signed
output  wire   [15:0]           o_26      ;//signed
output  wire   [15:0]           o_27      ;//signed
output  wire   [15:0]           o_28      ;//signed
output  wire   [15:0]           o_29      ;//signed
output  wire   [15:0]           o_30      ;//signed
output  wire   [15:0]           o_31      ;//signed

assign o_valid = i_0_valid || i_1_valid ;
assign o_0  = i_0_valid ? i_0_0   : i_1_0   ;
assign o_1  = i_0_valid ? i_0_1   : i_1_1   ;
assign o_2  = i_0_valid ? i_0_2   : i_1_2   ;
assign o_3  = i_0_valid ? i_0_3   : i_1_3   ;
assign o_4  = i_0_valid ? i_0_4   : i_1_4   ;
assign o_5  = i_0_valid ? i_0_5   : i_1_5   ;
assign o_6  = i_0_valid ? i_0_6   : i_1_6   ;
assign o_7  = i_0_valid ? i_0_7   : i_1_7   ;
assign o_8  = i_0_valid ? i_0_8   : i_1_8   ;
assign o_9  = i_0_valid ? i_0_9   : i_1_9   ;
assign o_10 = i_0_valid ? i_0_10  : i_1_10  ;
assign o_11 = i_0_valid ? i_0_11  : i_1_11  ;
assign o_12 = i_0_valid ? i_0_12  : i_1_12  ;
assign o_13 = i_0_valid ? i_0_13  : i_1_13  ;
assign o_14 = i_0_valid ? i_0_14  : i_1_14  ;
assign o_15 = i_0_valid ? i_0_15  : i_1_15  ;
assign o_16 = i_0_valid ? i_0_16  : i_1_16  ;
assign o_17 = i_0_valid ? i_0_17  : i_1_17  ;
assign o_18 = i_0_valid ? i_0_18  : i_1_18  ;
assign o_19 = i_0_valid ? i_0_19  : i_1_19  ;
assign o_20 = i_0_valid ? i_0_20  : i_1_20  ;
assign o_21 = i_0_valid ? i_0_21  : i_1_21  ;
assign o_22 = i_0_valid ? i_0_22  : i_1_22  ;
assign o_23 = i_0_valid ? i_0_23  : i_1_23  ;
assign o_24 = i_0_valid ? i_0_24  : i_1_24  ;
assign o_25 = i_0_valid ? i_0_25  : i_1_25  ;
assign o_26 = i_0_valid ? i_0_26  : i_1_26  ;
assign o_27 = i_0_valid ? i_0_27  : i_1_27  ;
assign o_28 = i_0_valid ? i_0_28  : i_1_28  ;
assign o_29 = i_0_valid ? i_0_29  : i_1_29  ;
assign o_30 = i_0_valid ? i_0_30  : i_1_30  ;
assign o_31 = i_0_valid ? i_0_31  : i_1_31  ;


endmodule

