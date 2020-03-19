//company       : xm tech
//project name  : H265i
//top module    : dct_top_2d.v
//data          : 2018.01.29
//file name     : ctl1.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module ctl1(
          i_inverse   ,
	  i_valid     ,
         
	  o_valid0    ,//mux0
	  o_valid1    //pe 
);

// ********************************************
//                                             
//    INPUT / OUTPUT DECLARATION                                               
//                                                                             
// ********************************************  
input                       i_inverse;
input                       i_valid;

output   wire               o_valid0;
output   wire               o_valid1;

assign o_valid0 = i_inverse ? i_valid : 1'b0; //mux0
assign o_valid1 = i_inverse ? 1'b0    : i_valid;//pe 

endmodule 

