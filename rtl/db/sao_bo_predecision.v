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
// Filename       : sao_bo_estimation.v
// Author         : TANG
// Creatu_ved     : 
// Description    :         
//------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module sao_bo_predecision(
            clk                 ,
            rst_n               ,
            cnt_i               ,
            state_i             ,
            block_i             ,
            bo_predecision_o    
);

parameter IDLE = 3'b000, LOAD = 3'b001, DBY = 3'b011, DBU = 3'b010, DBV = 3'b110, SAO = 3'b100, OUT = 3'b101;

input                           clk, rst_n              ;
input       [255:0]             block_i                 ;
input       [  8:0]             cnt_i                   ;
input       [  2:0]             state_i                 ;

output      [ 14:0]             bo_predecision_o        ; // y:[4:0], u:[9:5], v[14:10]
reg         [ 14:0]             bo_predecision_o        ;
reg         [ 15:0]             y_sum                   ;
reg         [ 13:0]             u_sum, v_sum            ;
wire        [  4:0]             y_ave, u_ave, v_ave     ;
reg         [  4:0]             y_first_bo, u_first_bo, v_first_bo     ;
wire        [  9:0]             sum                     ;

assign  sum =  block_i[255:251] + block_i[247:243] + block_i[239:235] + block_i[231:227] + 
               block_i[223:219] + block_i[215:211] + block_i[207:203] + block_i[199:195] + 
               block_i[191:187] + block_i[183:179] + block_i[175:171] + block_i[167:163] + 
               block_i[159:155] + block_i[151:147] + block_i[143:139] + block_i[135:131] + 
               block_i[127:123] + block_i[119:115] + block_i[111:107] + block_i[103: 99] + 
               block_i[ 95: 91] + block_i[ 87: 83] + block_i[ 79: 75] + block_i[ 71: 67] + 
               block_i[ 63: 59] + block_i[ 55: 51] + block_i[ 47: 43] + block_i[ 39: 35] + 
               block_i[ 31: 27] + block_i[ 23: 19] + block_i[ 15: 11] + block_i[  7:  3];

always @(posedge clk or negedge rst_n) begin
    if ( !rst_n )
        y_sum <= 'd0            ;
    else if ( state_i == IDLE )
        y_sum <= 'd0            ;
    else if ( state_i == DBY )
        y_sum <= y_sum + sum ;
end

always @(posedge clk or negedge rst_n) begin
    if ( !rst_n )
        u_sum <= 'd0            ;
    else if ( state_i == IDLE )
        u_sum <= 'd0            ;
    else if ( state_i == DBU )
        u_sum <= u_sum + sum  ;
end

always @(posedge clk or negedge rst_n) begin
    if ( !rst_n )
        v_sum <= 'd0                ;
    else if ( state_i == IDLE )
        v_sum <= 'd0            ;
    else if ( state_i == DBV )
        v_sum <= v_sum + sum  ;

end

assign y_ave = y_sum[15:11] ;
assign u_ave = u_sum[13: 9] ;
assign v_ave = v_sum[13: 9] ;

always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n ) 
        y_first_bo <= 0;
    else if (y_ave < 4) 
        y_first_bo <= 0;
    else if (y_ave > 5'd27)
        y_first_bo <= 5'd24 ;
    else 
        y_first_bo <= y_ave-5'd4 ;
end 

always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n ) 
        u_first_bo <= 0;
    else if (u_ave < 4) 
        u_first_bo <= 0;
    else if (u_ave > 5'd27)
        u_first_bo <= 5'd24 ;
    else 
        u_first_bo <= u_ave-5'd4 ;
end

always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n ) 
        v_first_bo <= 0;
    else if (v_ave < 4) 
        v_first_bo <= 0;
    else if (v_ave > 5'd27)
        v_first_bo <= 5'd24 ;
    else 
        v_first_bo <= v_ave-5'd4 ;
end

always @ ( posedge clk or negedge rst_n ) begin
    if (!rst_n)
        bo_predecision_o <= 'd0 ;
    else 
        bo_predecision_o <= {v_first_bo, u_first_bo, y_first_bo};
end 



endmodule 