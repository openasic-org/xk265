//----------------------------------------------------------------------------
//                                                                 
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//                                                                  
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE      
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//                                                                  
//  VIPcore       : http://soc.fudan.edu.cn/vip    
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn             
//----------------------------------------------------------------------------
// Filename       : dbf_lut_tc.v
// Author         : Chewein
// Created        : 2014-04-018
// Description    : look up table of tc         
//----------------------------------------------------------------------------
`include "enc_defines.v"

module db_lut_tc( qp_i,mb_type_i,tc_o );

input  [5:0] qp_i       ;
input        mb_type_i  ;

output [4:0] tc_o       ; 
reg    [4:0] tc_o       ;

wire [5:0] qp_w = qp_i + {(mb_type_i==`INTRA),1'b0};

always @(qp_w) begin
    case(qp_w)
        'd18: tc_o  =  5'd1 ;
        'd19: tc_o  =  5'd1 ;
        'd20: tc_o  =  5'd1;
        'd21: tc_o  =  5'd1;
        'd22: tc_o  =  5'd1;
        'd23: tc_o  =  5'd1;
        'd24: tc_o  =  5'd1;
        'd25: tc_o  =  5'd1;
        'd26: tc_o  =  5'd1;
        'd27: tc_o  =  5'd2;
        'd28: tc_o  =  5'd2;
        'd29: tc_o  =  5'd2;        
        'd30: tc_o  =  5'd2;
        'd31: tc_o  =  5'd3;
        'd32: tc_o  =  5'd3;
        'd33: tc_o  =  5'd3;
        'd34: tc_o  =  5'd3;
        'd35: tc_o  =  5'd4;
        'd36: tc_o  =  5'd4;
        'd37: tc_o  =  5'd4;
        'd38: tc_o  =  5'd5;
        'd39: tc_o  =  5'd5;        
        'd40: tc_o  =  5'd6;
        'd41: tc_o  =  5'd6;
        'd42: tc_o  =  5'd7;
        'd43: tc_o  =  5'd8;
        'd44: tc_o  =  5'd9;
        'd45: tc_o  =  5'd10;
        'd46: tc_o  =  5'd11;
        'd47: tc_o  =  5'd13;
        'd48: tc_o  =  5'd14;
        'd49: tc_o  =  5'd16;
        'd50: tc_o  =  5'd18;
        'd51: tc_o  =  5'd20;
        'd52: tc_o  =  5'd22;
        'd53: tc_o  =  5'd24;
      default: tc_o =  5'd0 ;
    endcase     
end

endmodule
