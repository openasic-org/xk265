//company       : xm tech
//project name  : H265i
//top module    : dct_top_2d.v
//data          : 2018.01.25
//file name     : ctl0.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module ctl0(
          i_inverse   ,
	  i_valid     ,
         
	  o_valid0    ,//to mux2
	  o_valid1     //to mux0 
);

// ********************************************
//                                             
//    INPUT / OUTPUT DECLARATION                                               
//                                                                             
// ********************************************  
input                       i_inverse;
input                       i_valid;
output			  o_valid0    ;//to mux2
output			  o_valid1    ;//to mux0 
wire			  o_valid0    ;//to mux2
wire			  o_valid1    ;//to mux0 

assign o_valid0 = i_inverse ? i_valid : 1'b0; 
assign o_valid1 = i_inverse ? 1'b0    : i_valid;  

endmodule 
