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
// Filename       : db_chroma_filter.v
// Author         : 
// Created        : 
// Description    : 
//                                
//----------------------------------------------------------------------------

module db_chroma_filter(
                    tc_i,
                            
                    p0_0_i  ,  p0_1_i  ,
                    p1_0_i  ,  p1_1_i  ,
                    p2_0_i  ,  p2_1_i  ,
                    p3_0_i  ,  p3_1_i  ,
                                       
                    q0_0_i  ,  q0_1_i  ,
                    q1_0_i  ,  q1_1_i  ,
                    q2_0_i  ,  q2_1_i  ,
                    q3_0_i  ,  q3_1_i  ,

                    p0_0_o  ,
                    p1_0_o  ,
                    p2_0_o  ,
                    p3_0_o  ,
                    q0_0_o  ,
                    q1_0_o  ,
                    q2_0_o  ,
                    q3_0_o   

    );

input [4:0] tc_i;

input       [7:0] p0_0_i  ,  p0_1_i  , 
                  p1_0_i  ,  p1_1_i  , 
                  p2_0_i  ,  p2_1_i  , 
                  p3_0_i  ,  p3_1_i  ; 
                                       
input       [7:0] q0_0_i  ,  q0_1_i  , 
                  q1_0_i  ,  q1_1_i  , 
                  q2_0_i  ,  q2_1_i  , 
                  q3_0_i  ,  q3_1_i  ; 

output[7:0] p0_0_o  ,  p1_0_o  ,  p2_0_o   , p3_0_o ;                   
output[7:0] q0_0_o  ,  q1_0_o  ,  q2_0_o   , q3_0_o ;

wire signed [8:0]  p0_0_s_w  =  {1'b0 , p0_0_i } ;
wire signed [8:0]  p0_1_s_w  =  {1'b0 , p0_1_i } ;
wire signed [8:0]  p1_0_s_w  =  {1'b0 , p1_0_i } ;
wire signed [8:0]  p1_1_s_w  =  {1'b0 , p1_1_i } ;
wire signed [8:0]  p2_0_s_w  =  {1'b0 , p2_0_i } ;
wire signed [8:0]  p2_1_s_w  =  {1'b0 , p2_1_i } ;
wire signed [8:0]  p3_0_s_w  =  {1'b0 , p3_0_i } ;
wire signed [8:0]  p3_1_s_w  =  {1'b0 , p3_1_i } ;
                                                
wire signed [8:0]  q0_0_s_w  =  {1'b0 , q0_0_i } ;
wire signed [8:0]  q0_1_s_w  =  {1'b0 , q0_1_i } ;
wire signed [8:0]  q1_0_s_w  =  {1'b0 , q1_0_i } ;
wire signed [8:0]  q1_1_s_w  =  {1'b0 , q1_1_i } ;
wire signed [8:0]  q2_0_s_w  =  {1'b0 , q2_0_i } ;
wire signed [8:0]  q2_1_s_w  =  {1'b0 , q2_1_i } ;
wire signed [8:0]  q3_0_s_w  =  {1'b0 , q3_0_i } ;
wire signed [8:0]  q3_1_s_w  =  {1'b0 , q3_1_i } ;

wire  signed [8:0]  delta0_w  ;//chroma delta
wire  signed [8:0]  delta1_w  ;//chroma delta
wire  signed [8:0]  delta2_w  ;//chroma delta
wire  signed [8:0]  delta3_w  ;//chroma delta

wire  signed [5:0]  tc_x        ;
wire  signed [5:0]  tc_y        ;

assign delta0_w = ((((q0_0_s_w-p0_0_s_w)<<2)+p0_1_s_w-q0_1_s_w+4)>>3);
assign delta1_w = ((((q1_0_s_w-p1_0_s_w)<<2)+p1_1_s_w-q1_1_s_w+4)>>3);
assign delta2_w = ((((q2_0_s_w-p2_0_s_w)<<2)+p2_1_s_w-q2_1_s_w+4)>>3);
assign delta3_w = ((((q3_0_s_w-p3_0_s_w)<<2)+p3_1_s_w-q3_1_s_w+4)>>3);

assign tc_x       = ~tc_i + 1'b1 ;
assign tc_y       = {1'b0,tc_i}  ;

wire  signed [8:0]  delta0_tc_w  ;//chroma delta
wire  signed [8:0]  delta1_tc_w  ;//chroma delta
wire  signed [8:0]  delta2_tc_w  ;//chroma delta
wire  signed [8:0]  delta3_tc_w  ;//chroma delta

assign delta0_tc_w = delta0_w < tc_x ? tc_x : (delta0_w > tc_y ? tc_y :delta0_w ) ;
assign delta1_tc_w = delta1_w < tc_x ? tc_x : (delta1_w > tc_y ? tc_y :delta1_w ) ;
assign delta2_tc_w = delta2_w < tc_x ? tc_x : (delta2_w > tc_y ? tc_y :delta2_w ) ;
assign delta3_tc_w = delta3_w < tc_x ? tc_x : (delta3_w > tc_y ? tc_y :delta3_w ) ;

wire signed [9:0] p0_0_m_w,q0_0_m_w ;
wire signed [9:0] p1_0_m_w,q1_0_m_w ;
wire signed [9:0] p2_0_m_w,q2_0_m_w ;
wire signed [9:0] p3_0_m_w,q3_0_m_w ;

assign p0_0_m_w  = p0_0_s_w  + delta0_tc_w  ;
assign p1_0_m_w  = p1_0_s_w  + delta1_tc_w  ;
assign p2_0_m_w  = p2_0_s_w  + delta2_tc_w  ;
assign p3_0_m_w  = p3_0_s_w  + delta3_tc_w  ;
assign q0_0_m_w  = q0_0_s_w  - delta0_tc_w  ;
assign q1_0_m_w  = q1_0_s_w  - delta1_tc_w  ;
assign q2_0_m_w  = q2_0_s_w  - delta2_tc_w  ;
assign q3_0_m_w  = q3_0_s_w  - delta3_tc_w  ;

assign p0_0_o  =  p0_0_m_w[9] ? 8'd0 :(p0_0_m_w[8] ? 8'd255 :p0_0_m_w[7:0]);
assign p1_0_o  =  p1_0_m_w[9] ? 8'd0 :(p1_0_m_w[8] ? 8'd255 :p1_0_m_w[7:0]);
assign p2_0_o  =  p2_0_m_w[9] ? 8'd0 :(p2_0_m_w[8] ? 8'd255 :p2_0_m_w[7:0]);
assign p3_0_o  =  p3_0_m_w[9] ? 8'd0 :(p3_0_m_w[8] ? 8'd255 :p3_0_m_w[7:0]);

assign q0_0_o  =  q0_0_m_w[9] ? 8'd0 :(q0_0_m_w[8] ? 8'd255 :q0_0_m_w[7:0]);
assign q1_0_o  =  q1_0_m_w[9] ? 8'd0 :(q1_0_m_w[8] ? 8'd255 :q1_0_m_w[7:0]);
assign q2_0_o  =  q2_0_m_w[9] ? 8'd0 :(q2_0_m_w[8] ? 8'd255 :q2_0_m_w[7:0]);
assign q3_0_o  =  q3_0_m_w[9] ? 8'd0 :(q3_0_m_w[8] ? 8'd255 :q3_0_m_w[7:0]);

endmodule 