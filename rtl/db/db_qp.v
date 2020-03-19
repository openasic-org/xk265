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
// Filename       : db_qp.v
// Author         : chewein
// Creatu_ved     : 2014-04-18
// Description    : modified the 8x8 cu qp  of the current cu  
//					qp_flag_o = 1 means the qp of the current cu should be modified    
//------------------------------------------------------------------------------------------------
module db_qp(
				clk					,
				rst_n				,
				cbf_4x4_i			,
				cbf_u_4x4_i			,
				cbf_v_4x4_i			,
				qp_left_i			,
				
				qp_flag_o		
);
// *************************************************************************************************
//                                             
//    INPUT / OUTPUT DECLARATION               
//                                             
// *************************************************************************************************
input 				clk						;
input				rst_n					;
input				cbf_4x4_i			    ;
input				cbf_u_4x4_i			    ;
input				cbf_v_4x4_i			    ;
input               qp_left_i				;//indicate the left 4x4 cu qp is modified or not

output				qp_flag_o				;

reg   			 	qp_flag_o				; 
//---------------------------------------------------------------------------------------------------
wire  modified_flag   = !(cbf_4x4_i  ||cbf_u_4x4_i  ||cbf_v_4x4_i  );//4x4

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		qp_flag_o		<=	1'b0		;	
	else if(modified_flag)//all coeffs  = 0
		qp_flag_o		<=	qp_left_i	;//qp_flag=1:qp need to be modified 
	else 
		qp_flag_o		<=	1'b0		;
	
end

endmodule


