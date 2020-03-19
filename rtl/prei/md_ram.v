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
// Filename       : md_ram.v                                               
// Author         : Yanheng Lu                                        
// Created        : 2014-09-01                                      
// Description    : mode decision(pre_intra) 8x8 ram                                             
//------------------------------------------------------------------

module md_ram (
    				clk     ,
    				wdata   ,
    				waddr   ,
    				we      ,
    				rd      ,
    				raddr   ,
    				rdata  
);

// ********************************************
//                                             
//    Input/Output DECLARATION                    
//                                             
// ********************************************
input                clk   ; 
input [31:0]		 wdata ;
input [3:0]          waddr ;
input   	         we    ;
input    	         rd    ;
input [3:0]          raddr ;
output [31:0]   	 rdata ;

// ********************************************
//                                             
//    Logic DECLARATION                 
//                                             
// ********************************************

rf_2p #(.Addr_Width(4), .Word_Width(32))	
	   rf_2p_32x16 (
				.clka    ( clk       ),  
				.cena_i  ( ~rd       ),
		        .addra_i ( raddr		),
		        .dataa_o ( rdata     ),
				.clkb    ( clk       ),     
				.cenb_i  ( ~we       ),  
				.wenb_i  ( ~we       ),   
				.addrb_i ( waddr	),
				.datab_i ( wdata     )
);

endmodule
