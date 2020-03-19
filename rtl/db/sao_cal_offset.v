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
// Filename       : sao_cal_offset.v
// Author         : Chewein
// Created        : 2015-03-19
// Description    : calculation the offset dependent on the band 
//                  number and stat  
//-------------------------------------------------------------------
module sao_cal_offset(
                   stat_i                   ,
                   num_i                    ,
                   mode_cnt_i               ,
				   data_valid_i             ,
				   offset_o                 ,
                   distortion_o          				   
				   
				);
//---------------------------------------------------------------------------
//
//                        INPUT/OUTPUT DECLARATION 
//
//----------------------------------------------------------------------------
                    
parameter SAO_DIF_WIDTH = 18 ;
parameter SAO_NUM_WIDTH = 12 ;
parameter SAO_DIS_WIDTH = 20 ;

input  signed    [SAO_DIF_WIDTH-1:0]    stat_i          ;
input            [SAO_NUM_WIDTH-1:0]    num_i           ;
input            [4:0]                  mode_cnt_i      ;
input                                   data_valid_i    ;
output signed    [      2     :0]       offset_o        ;
output signed    [SAO_DIS_WIDTH-1:0]    distortion_o    ;


reg    signed    [SAO_DIF_WIDTH-1:0]    stat_r          ;
reg              [SAO_NUM_WIDTH-1:0]    num_r           ;

reg              [SAO_DIF_WIDTH-1:0]    stat_unsigned_r ;
wire             [SAO_NUM_WIDTH+1:0]    num_m2_w        ;
wire             [SAO_NUM_WIDTH+1:0]    num_m3_w        ;
reg              [      1     :0]       offset_unsigned_r;
reg    signed    [      2     :0]       offset_r        ;
reg    signed    [      2     :0]       offset_w        ;

always @(*) begin 
    case(data_valid_i)
        1'b0 :begin 
            stat_r = 'd0 ; 
            num_r =  'd0  ;
            end
        1'b1 :begin 
            stat_r = stat_i; 
            num_r = num_i;
            end      
    endcase 
end

always @(*) begin 
    case(stat_r[SAO_DIF_WIDTH-1])
        1'b1 : 
            stat_unsigned_r  = (~stat_r)+1'b1  ; 
        default : 
            stat_unsigned_r  = stat_r ;     
    endcase 
end

assign    num_m2_w  =  {num_r,1'b0}                   ; 
assign    num_m3_w  =  {num_r,1'b0} +  num_r          ; 

always @* begin 
    if(num_r==0)
        offset_unsigned_r   =    2'd0                 ;
	else if(stat_unsigned_r<num_r)	
		offset_unsigned_r   =    2'd0                 ;
	else if(stat_unsigned_r<num_m2_w)	
		offset_unsigned_r   =    2'd1                 ;
	else if(stat_unsigned_r<num_m3_w)	
		offset_unsigned_r   =    2'd2                 ;
	else 	
		offset_unsigned_r   =    2'd3                 ;
end 

always @* begin 
    case(stat_r[SAO_DIF_WIDTH-1])
        1'b0 : offset_r = {1'b0,offset_unsigned_r} ;
        1'b1 : offset_r = (~(offset_unsigned_r)+1'b1) ;
	endcase
end 

always @* begin 
    offset_w = offset_r ;
    if ( mode_cnt_i<16 && (mode_cnt_i[1] == 0) )
        offset_w = offset_r[2]==1 ? 0 : offset_r ;
    else if (mode_cnt_i<16 && (mode_cnt_i[1] == 1))
        offset_w = offset_r[2]==0 ? 0 : offset_r ;
    else 
        offset_w = offset_r ;
end 

wire signed   [ 5:0] temp1= offset_w * offset_w;
wire signed   [12:0] temp2= num_r    * temp1     ;
wire signed   [SAO_DIS_WIDTH-1:0] temp3= stat_r*offset_w   ;


assign   offset_o   =     offset_w                  ;
assign   distortion_o =   temp2  - {temp3,1'b0}       ;


endmodule

 