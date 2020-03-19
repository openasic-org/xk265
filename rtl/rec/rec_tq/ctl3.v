//company       : xm tech
//project name  : H265i
//top module    : dct_top_2d.v
//data          : 2018.02.07
//file name     : ctl3.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module ctl3(
          i_valid  ,
	  i_inverse,
//----------------------------------//
          o_valid0 ,//to mux1
          o_valid1 //to mux3
);
// ********************************************
//    INPUT / OUTPUT DECLARATION                                               
// ********************************************  

input                       i_valid   ;
input                       i_inverse ;

output wire                     o_valid0  ;
output wire                     o_valid1  ;

assign o_valid0 = i_inverse ? 1'b0 : i_valid ;//mux1
assign o_valid1 = i_inverse ? i_valid : 1'b0 ;//mux3

endmodule

