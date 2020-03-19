//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.02.07
//file name     : row_ctl.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module row_ctl(
	clk	 ,
	rst_n	 ,
	i_valid0 ,//org valid
	i_valid1 ,//transform out valid 
	o_row	 //1:2d_dct 0 : 1d_dct
);

input    clk	 ; 
input    rst_n	 ; 
input    i_valid0; 
input    i_valid1; 
output    o_row	 ;
reg      o_row	 ;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		o_row <= 1'b0;
	else if(i_valid1)
		o_row <= 1'b1;
	else if(i_valid0)
		o_row <= 1'b0;
end 

endmodule
