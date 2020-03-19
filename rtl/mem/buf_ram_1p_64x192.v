//-------------------------------------------------------------------
//                                                                 
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//                                                                  
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE      
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//                                                                  
//  VIPcore       : http://soc.fudan.edu.cn/vip    
//  IP Owner 	  : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn             
//-------------------------------------------------------------------

`include "enc_defines.v"

module buf_ram_1p_64x192 (
    				clk  		,
    				ce	        ,  
    				we			,
    				addr		,
    				data_i    	, 
    				data_o	
);

//--- input/output declaration -----------------------
input               		clk      	;           		      
input  						ce			; // high active	
input						we			; // high active  
input  [7:0]				addr		;	
input  [`PIXEL_WIDTH*8-1:0]	data_i		; 
output [`PIXEL_WIDTH*8-1:0]	data_o    	;

//--- wire/reg declaration -----------------------------

wire ce_w = !ce ;
wire we_w = !we ;


`ifdef RTL_MODEL 
ram_1p #(.Addr_Width(8), .Word_Width(`PIXEL_WIDTH*8))	
 	u_ram_1p_64x192 (
 				.clk  		( clk		), 
 				.cen_i      ( ce_w		),
 				.oen_i      ( 1'b0		),
 	            .wen_i      ( we_w		),
 	            .addr_i     ( addr		),
 	            .data_i     ( data_i	),
 	            .data_o     ( data_o	)
);

`endif




`ifdef SMIC13_MODEL

`endif
endmodule
