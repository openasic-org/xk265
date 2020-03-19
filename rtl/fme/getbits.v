//------------------------------------------------------------
//
//  File Name       : getbits.v
//  Author          : TANG 
//  Date            : 2018-06-11
//  Description     : support skip and merge
//
//-------------------------------------------------------------
`include "enc_defines.v"

module getbits(
		var_i ,
		bit_o 
);

//---- parameter ---------------------------------------
	parameter VAR_WIDTH = 1 ;

//---- input / output -----------------------------------
	input 	[VAR_WIDTH-1:0] 	var_i ;
	output 	[6-1:0] 			bit_o ;

//---- wire / reg ---------------------------------------
	wire 	[VAR_WIDTH:0] 		var_w ;
	reg 	[5-1:0] 			bit_num_0 ;
	reg 	[5-1:0] 			bit_num_1 ;
	reg 	[5-1:0] 			bit_num_2 ;
	reg 	[6-1:0] 			bit_o 	  ;

//---- main body -------------------------------------------
	assign var_w = {var_i, 1'b0} ;

	always @* begin 
		if ( var_w[3] )
			bit_num_0 = 5'd7 ;
		else if ( var_w[2] )
			bit_num_0 = 5'd5 ;
		else if ( var_w[1] )
			bit_num_0 = 5'd3 ;
		else 
			bit_num_0 = 5'd1 ;
	end 
	
	always @* begin 
		if ( var_w[7] )
			bit_num_1 = 5'd15 ;
		else if ( var_w[6] )
			bit_num_1 = 5'd13 ;
		else if ( var_w[5] )
			bit_num_1 = 5'd11 ;
		else if ( var_w[4] )
			bit_num_1 = 5'd9 ;
		else 
			bit_num_1 = 5'd0 ;
	end 

	always @* begin 
		if ( var_w[11] )
			bit_num_2 = 5'd31 ;
		else if ( var_w[10] )
			bit_num_2 = 5'd21 ;
		else if ( var_w[9] )
			bit_num_2 = 5'd19 ;
		else if ( var_w[8] )
			bit_num_2 = 5'd17 ;
		else 
			bit_num_2 = 5'd0 ;
	end 

	always @* begin 
		bit_o = bit_num_0 ;
		if ( bit_num_2 )
			bit_o = bit_num_2 ;
		else if ( bit_num_1 )
			bit_o = bit_num_1 ;
		else  if ( bit_num_0 )
			bit_o = bit_num_0 ;
	end 


endmodule 