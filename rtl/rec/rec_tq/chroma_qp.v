//-----------------------------------------------------
// 	
// File Name 	: chroma_qp.v
// Author 		: TANG
// Date 		: 2018-05-19
// Description  : update chroma qp
//
//------------------------------------------------------
`include "enc_defines.v"

module chroma_qp(
	qp_i 	,
	sel_i 	,
	qp_o 	
	);

//---- input/output declaration -----------------------------
	input 	[6		-1 :0]  qp_i 	;
	input 	[2		-1 :0]  sel_i   ; // YUV
	output  [6 		-1 :0]  qp_o    ;
 

//---- wire/reg declaration -------------------------------
	reg  	[6 		-1 :0] 	qpc 	; // chroma qp
	wire 	[6 		-1 :0]  qp_case ;

	assign qp_case = qp_i - 30 ;

	always @ ( * ) begin 
		if ( qp_i >= 30 && qp_i <= 43 )
			case ( qp_case )
				0 	  : qpc = 6'd29 ;
				1 	  : qpc = 6'd30 ;
				2 	  : qpc = 6'd31 ;
				3 	  : qpc = 6'd32 ;
				4,5   : qpc = 6'd33 ;
				6,7   : qpc = 6'd34 ;
				8,9   : qpc = 6'd35 ;
				10,11 : qpc = 6'd36 ;
				12,13 : qpc = 6'd37 ;
				default : qpc = qp_i ;
			endcase 
		else if ( qp_i < 30 )
			qpc = qp_i ;
		else 
			qpc = qp_i - 6'd6 ;
	end 

	assign qp_o = ( sel_i == `TYPE_Y ) ? qp_i : qpc ;


endmodule 