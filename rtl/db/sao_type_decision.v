//------------------------------------------------------------------- 
//                                                                    
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University               
//                                                                    
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE        
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group                        
//                                                                    
//  VIPcore       : http://soc.fudan.edu.cn/vip                       
//  IP Owner      : Yibo FAN                                          
//  Contact       : fanyibo@fudan.edu.cn                              
//------------------------------------------------------------------- 
// Filename       : dsao_type_dicision.v                            
// Author         :                                       
// Created        :                                       
// Description    : calculation the final offset                      
//------------------------------------------------------------------- 
module sao_type_decision(
                                clk                      ,
                                rst_n                    ,
                                data_valid_i             ,
                                bo_predecision           ,
                                mode_cnt_i               ,
                                offset_0_i               ,
                                offset_1_i               ,
                                offset_2_i               ,
                                offset_3_i               ,
                                distortion_0_i           ,
                                distortion_1_i           ,
                                distortion_2_i           ,
                                distortion_3_i           ,
                                type_o                   ,
                                sub_type_o               ,
                                offset_o                                                                 
                            );
//---------------------------------------------------------------------------
//                                                                           
//                        INPUT/OUTPUT DECLARATION                           
//                                                                           
//---------------------------------------------------------------------------

parameter SAO_DIS_WIDTH = 20 ;

input                           clk                ;
input                           rst_n              ;
input                           data_valid_i       ;
input          [          4:0 ] bo_predecision     ;
input          [          4:0 ] mode_cnt_i         ;
input  signed  [          2:0 ] offset_0_i       ;
input  signed  [          2:0 ] offset_1_i       ;
input  signed  [          2:0 ] offset_2_i       ;
input  signed  [          2:0 ] offset_3_i       ;
input  signed  [SAO_DIS_WIDTH-1:0 ] distortion_0_i   ;
input  signed  [SAO_DIS_WIDTH-1:0 ] distortion_1_i   ;
input  signed  [SAO_DIS_WIDTH-1:0 ] distortion_2_i   ;
input  signed  [SAO_DIS_WIDTH-1:0 ] distortion_3_i   ;
output         [          2:0 ] type_o           ;
output         [          4:0 ] sub_type_o       ;
output signed  [         11:0 ] offset_o         ;
//---------------------------------------------------------------------------
//                                                                           
//               declare reg signals                                         
//                                                                           
//---------------------------------------------------------------------------
/*
reg  signed   [          2:0 ] offset_0_r       ;
reg  signed   [          2:0 ] offset_1_r       ;
reg  signed   [          2:0 ] offset_2_r       ;
reg  signed   [          2:0 ] offset_3_r       ;

reg   signed  [SAO_DIS_WIDTH-1:0 ] distortion_0_r   ;
reg   signed  [SAO_DIS_WIDTH-1:0 ] distortion_1_r   ;
reg   signed  [SAO_DIS_WIDTH-1:0 ] distortion_2_r   ;
reg   signed  [SAO_DIS_WIDTH-1:0 ] distortion_3_r   ;
*/
reg           [          2:0 ] offset_abs_0_r   ;
reg           [          2:0 ] offset_abs_1_r   ;
reg           [          2:0 ] offset_abs_2_r   ;
reg           [          2:0 ] offset_abs_3_r   ;

wire          [          4:0 ] offset_abs_0t3_w  ;
wire  signed  [          5:0 ] offset_0t3_w      ;
wire  signed  [SAO_DIS_WIDTH+1:0 ] distortion_0t3_w ;
wire  signed  [SAO_DIS_WIDTH+2:0 ] cost_0t3_w       ;

reg           [          2:0 ] type_o           ;
reg           [          4:0 ] sub_type_o       ;
reg           [         11:0 ] offset_o         ;

reg           [          2:0 ] type_r           ;
reg           [          4:0 ] sub_type_r       ;

/*
// reg signals  offset_r 
always @(posedge clk or negedge rst_n) begin       
    if(!rst_n)  begin                              
        offset_0_r <= 3'd0 ;offset_1_r <= 3'd0 ;offset_2_r <= 3'd0 ;offset_3_r <= 3'd0 ;
    end
    else if(data_valid_i)  begin                    
        offset_0_r <= offset_0_i ;offset_1_r <= offset_1_i ;
        offset_2_r <= offset_2_i ;offset_3_r <= offset_3_i ;
    end
    else begin                   
        offset_0_r <= 3'd0 ;offset_1_r <= 3'd0 ;offset_2_r <= 3'd0 ;offset_3_r <= 3'd0 ;
    end
end

//reg signals  distortion__r 
always @(posedge clk or negedge rst_n) begin       
    if(!rst_n)  begin                              
        distortion_0_r <= 'd0 ;distortion_1_r <= 'd0 ;distortion_2_r <= 'd0 ;distortion_3_r <= 'd0 ;
    end
    else if(data_valid_i)  begin                    
        distortion_0_r <= distortion_0_i ;distortion_1_r <= distortion_1_i ;
        distortion_2_r <= distortion_2_i ;distortion_3_r <= distortion_3_i ;
    end
    else begin                   
        distortion_0_r <= 'd0 ;distortion_1_r <= 'd0 ;distortion_2_r <= 'd0 ;distortion_3_r <= 'd0 ;
    end
end
*/
// calculation offset_abs__r  
always @* begin                                               
    case(offset_0_i[2])                                     
        1'b1 : offset_abs_0_r   =   {~offset_0_i} + 1'b1 ;
        1'b0 : offset_abs_0_r   =    offset_0_i          ;
    endcase                                                     
end                                                           

always @* begin                                               
    case(offset_1_i[2])                                     
        1'b1 : offset_abs_1_r   =   {~offset_1_i} + 1'b1 ;
        1'b0 : offset_abs_1_r   =    offset_1_i          ;
    endcase                                                     
end                                                           

always @* begin                                               
    case(offset_2_i[2])                                     
        1'b1 : offset_abs_2_r   =   {~offset_2_i} + 1'b1 ;
        1'b0 : offset_abs_2_r   =    offset_2_i          ;
    endcase                                                     
end                                                           

always @* begin                                               
    case(offset_3_i[2])                                     
        1'b1 : offset_abs_3_r   =   {~offset_3_i} + 1'b1 ;
        1'b0 : offset_abs_3_r   =    offset_3_i          ;
    endcase                                                     
end                                                           
                                                                                   


// calculation offset_abs_t_r  
assign  offset_abs_0t3_w  =   offset_abs_0_r  +  offset_abs_1_r + offset_abs_2_r  +  offset_abs_3_r ;

// calculation offset_abs_t_r  
assign  offset_0t3_w  =   {1'b0,offset_abs_0t3_w};

// calculation distortion_t_r  
assign  distortion_0t3_w  =   distortion_0_i  +  distortion_1_i + distortion_2_i  +  distortion_3_i;

// calculation cost_t_r  
assign  cost_0t3_w  =   distortion_0t3_w + (offset_0t3_w<<4) - offset_0t3_w;

//---------------------------------------------------------------------------
//                                                                           
//               compare cost_t_r                                          
//                                                                           
//---------------------------------------------------------------------------
always @ ( * ) begin 
    type_r      =3'd0; 
    sub_type_r  = 5'd0; 
    case ( mode_cnt_i )
        5'd3 : begin type_r = 3'd0; sub_type_r = 5'd0; end // EO_0   : 0
        5'd7 : begin type_r = 3'd3; sub_type_r = 5'd3; end // EO_45  : 3
        5'd11: begin type_r = 3'd1; sub_type_r = 5'd1; end // EO_90  : 1
        5'd15: begin type_r = 3'd2; sub_type_r = 5'd2; end // EO_135 : 2
        5'd19: begin type_r = 3'd4; sub_type_r = bo_predecision+1'b0; end 
        5'd20: begin type_r = 3'd4; sub_type_r = bo_predecision+2'd1; end 
        5'd21: begin type_r = 3'd4; sub_type_r = bo_predecision+3'd2; end 
        5'd22: begin type_r = 3'd4; sub_type_r = bo_predecision+3'd3; end 
        5'd23: begin type_r = 3'd4; sub_type_r = bo_predecision+3'd4; end 
      default: begin type_r = 0   ; sub_type_r = 0                  ; end 
    endcase 
end

reg  signed   [SAO_DIS_WIDTH+2:0 ]      min_cost;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin 
        min_cost        <= 0             ;
        offset_o        <= 12'd0         ;
        type_o          <= 0             ;
        sub_type_o      <= 0             ;
    end else if ( mode_cnt_i == 0 ) begin 
        min_cost        <= 0             ;
        offset_o        <= 12'd0         ;
        type_o          <= 0             ;
        sub_type_o      <= 0             ;
    end 
    else if ( data_valid_i && ( min_cost > cost_0t3_w ) ) begin 
        min_cost        <= cost_0t3_w           ;
        offset_o        <= {offset_3_i,offset_2_i,offset_1_i,offset_0_i};
        type_o          <= type_r               ;
        sub_type_o      <= sub_type_r           ;
    end 
end  

endmodule