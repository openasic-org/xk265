//company       : xm tech
//project name  : H265i
//top module    : dct_top_2d.v
//data          : 2018.01.25
//file name     : mux32_1.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module mux32_1(
          i_addr,
          i_0   ,
          i_1   ,
          i_2   ,
          i_3   ,
          i_4   ,
          i_5   ,
          i_6   ,
          i_7   ,
          i_8   ,
          i_9   ,
          i_10  ,
          i_11  ,
          i_12  ,
          i_13  ,
          i_14  ,
          i_15  ,
          i_16  ,
          i_17  ,
          i_18  ,
          i_19  ,
          i_20  ,
          i_21  ,
          i_22  ,
          i_23  ,
          i_24  ,
          i_25  ,
          i_26  ,
          i_27  ,
          i_28  ,
          i_29  ,
          i_30  ,
          i_31  ,
          
          o_dt  
);

// ********************************************
//                                             
//    INPUT / OUTPUT DECLARATION                                               
//                                                                             
// ********************************************  

input   [4:0]               i_addr;
input      [15:0]           i_0 ;//signed
input      [15:0]           i_1 ;//signed
input      [15:0]           i_2 ;//signed
input      [15:0]           i_3 ;//signed
input      [15:0]           i_4 ;//signed
input      [15:0]           i_5 ;//signed
input      [15:0]           i_6 ;//signed
input      [15:0]           i_7 ;//signed
input      [15:0]           i_8 ;//signed
input      [15:0]           i_9 ;//signed
input      [15:0]           i_10;//signed
input      [15:0]           i_11;//signed
input      [15:0]           i_12;//signed
input      [15:0]           i_13;//signed
input      [15:0]           i_14;//signed
input      [15:0]           i_15;//signed
input      [15:0]           i_16;//signed
input      [15:0]           i_17;//signed
input      [15:0]           i_18;//signed
input      [15:0]           i_19;//signed
input      [15:0]           i_20;//signed
input      [15:0]           i_21;//signed
input      [15:0]           i_22;//signed
input      [15:0]           i_23;//signed
input      [15:0]           i_24;//signed
input      [15:0]           i_25;//signed
input      [15:0]           i_26;//signed
input      [15:0]           i_27;//signed
input      [15:0]           i_28;//signed
input      [15:0]           i_29;//signed
input      [15:0]           i_30;//signed
input      [15:0]           i_31;//signed

output reg  [15:0]          o_dt;//signed

// ********************************************
//    Combinational Logic                      
// ********************************************
always@(*)
  case(i_addr)
    5'd0 :o_dt=i_0 ;
    5'd1 :o_dt=i_1 ;
    5'd2 :o_dt=i_2 ;
    5'd3 :o_dt=i_3 ;
    5'd4 :o_dt=i_4 ;
    5'd5 :o_dt=i_5 ;
    5'd6 :o_dt=i_6 ;
    5'd7 :o_dt=i_7 ;
    5'd8 :o_dt=i_8 ;
    5'd9 :o_dt=i_9 ;
    5'd10:o_dt=i_10;
    5'd11:o_dt=i_11;
    5'd12:o_dt=i_12;
    5'd13:o_dt=i_13;
    5'd14:o_dt=i_14;
    5'd15:o_dt=i_15;
    5'd16:o_dt=i_16;
    5'd17:o_dt=i_17;
    5'd18:o_dt=i_18;
    5'd19:o_dt=i_19;
    5'd20:o_dt=i_20;
    5'd21:o_dt=i_21;
    5'd22:o_dt=i_22;
    5'd23:o_dt=i_23;
    5'd24:o_dt=i_24;
    5'd25:o_dt=i_25;
    5'd26:o_dt=i_26;
    5'd27:o_dt=i_27;
    5'd28:o_dt=i_28;
    5'd29:o_dt=i_29;
    5'd30:o_dt=i_30;
    default:o_dt=i_31;
  endcase

endmodule
