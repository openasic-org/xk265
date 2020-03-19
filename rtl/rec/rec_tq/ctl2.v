//company       : xm tech
//project name  : H265i
//top module    : dct_top_2d.v
//data          : 2018.01.25
//file name     : ctl2.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module ctl2(
          i_valid  ,
	  i_inverse,
//----------------------------------//
          o_valid0,//to dct 
          o_valid1//to i_dct
);

// ********************************************
//                                             
//    INPUT / OUTPUT DECLARATION                                               
//                                                                             
// ********************************************  

input                       i_valid   ;
input                       i_inverse ;

output wire                     o_valid0  ;//to dct
output wire                     o_valid1  ;//to idct

assign o_valid0 = i_inverse?  1'b0 : i_valid;//to dct
assign o_valid1 = i_inverse?  i_valid : 1'b0;//to idct 


endmodule

