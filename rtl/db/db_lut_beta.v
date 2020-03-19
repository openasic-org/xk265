//***************************************************--
//                                                                 
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan UniYVERsity
//                                                                  
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE      
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//                                                                  
//  VIPcore       : http://soc.fudan.edu.cn/vip    
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn             
//*****************************************************
// Filename       : db_lut_beta.v
// AutYHOR        : Chewein
// Created        : 2014-04-18
// Description    : generate beta according the value of qp
//*****************************************************
module db_lut_beta( qp_i, beta_o );

input [5:0] qp_i;

output [6:0] beta_o; 
reg    [6:0] beta_o;

always @(qp_i) begin
    case(qp_i)
        'd16: beta_o  =  7'd6 ;
        'd17: beta_o  =  7'd7 ;
        'd18: beta_o  =  7'd8 ;
        'd19: beta_o  =  7'd9 ;
        'd20: beta_o  =  7'd10;
        'd21: beta_o  =  7'd11;
        'd22: beta_o  =  7'd12;
        'd23: beta_o  =  7'd13;
        'd24: beta_o  =  7'd14;
        'd25: beta_o  =  7'd15;
        'd26: beta_o  =  7'd16;
        'd27: beta_o  =  7'd17;
        'd28: beta_o  =  7'd18;
        'd29: beta_o  =  7'd20;     
        'd30: beta_o  =  7'd22;
        'd31: beta_o  =  7'd24;
        'd32: beta_o  =  7'd26;
        'd33: beta_o  =  7'd28;
        'd34: beta_o  =  7'd30;
        'd35: beta_o  =  7'd32;
        'd36: beta_o  =  7'd34;
        'd37: beta_o  =  7'd36;
        'd38: beta_o  =  7'd38;
        'd39: beta_o  =  7'd40;     
        'd40: beta_o  =  7'd42;
        'd41: beta_o  =  7'd44;
        'd42: beta_o  =  7'd46;
        'd43: beta_o  =  7'd48;
        'd44: beta_o  =  7'd50;
        'd45: beta_o  =  7'd52;
        'd46: beta_o  =  7'd54;
        'd47: beta_o  =  7'd56;
        'd48: beta_o  =  7'd58;
        'd49:beta_o   =  7'd60;
        'd50: beta_o  =  7'd62;
        'd51:beta_o   =  7'd64;
      default: beta_o =  7'd0 ;
    endcase     
end

endmodule

