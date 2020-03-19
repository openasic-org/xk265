//----------------------------------------------------------------------------
//                                                                 
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//                                                                  
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE      
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//                                                                  
//  VIPcore       : http://soc.fudan.edu.cn/vip    
//  IP Owner 	  : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn             
//----------------------------------------------------------------------------
// Filename       : dbf_clip3.v
// Author         : Chewein
// Created        : 2014-04-18
// Description    : return [x  i  y]      
//----------------------------------------------------------------------------
module db_clip3_str(o,x,y,i);
//---------------------------------------------------------------------------
//
//                        INPUT/OUTPUT DECLARATION 
//
//----------------------------------------------------------------------------
input  [7:0] x,y;
input  [8:0] i  ;
output wire [7:0] o;

assign o = (i<x) ? x : ((i>y) ? y : i[7:0]);

endmodule 
