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
// Filename       : db_normal_filter.v
// Author         : 
// Created        : 
// Description    : 
//                                
//----------------------------------------------------------------------------

module db_normal_filter(
                tc_i,
                p0_0_i  ,  p0_1_i  ,  p0_2_i ,
                p1_0_i  ,  p1_1_i  ,  p1_2_i ,
                p2_0_i  ,  p2_1_i  ,  p2_2_i ,
                p3_0_i  ,  p3_1_i  ,  p3_2_i ,
                                             
                q0_0_i  ,  q0_1_i  ,  q0_2_i ,
                q1_0_i  ,  q1_1_i  ,  q1_2_i ,
                q2_0_i  ,  q2_1_i  ,  q2_2_i ,
                q3_0_i  ,  q3_1_i  ,  q3_2_i ,
                
                p0_0_o  ,
                p1_0_o  ,
                p2_0_o  ,
                p3_0_o  ,

                q0_0_o  ,
                q1_0_o  ,
                q2_0_o  ,
                q3_0_o  , 

                p0_1_o  ,
                p1_1_o  ,
                p2_1_o  ,
                p3_1_o  ,
                       
                q0_1_o  ,
                q1_1_o  ,
                q2_1_o  ,
                q3_1_o  , 
                 
                not_nature_edge_o   

    );
input [4:0] tc_i;

input        [7:0] p0_0_i  ,  p0_1_i  ,  p0_2_i  ,
                   p1_0_i  ,  p1_1_i  ,  p1_2_i  ,
                   p2_0_i  ,  p2_1_i  ,  p2_2_i  ,
                   p3_0_i  ,  p3_1_i  ,  p3_2_i  ;
                                                    
input        [7:0] q0_0_i  ,  q0_1_i  ,  q0_2_i  ,
                   q1_0_i  ,  q1_1_i  ,  q1_2_i  ,
                   q2_0_i  ,  q2_1_i  ,  q2_2_i  ,
                   q3_0_i  ,  q3_1_i  ,  q3_2_i  ;

output[7:0] p0_0_o  ,  p1_0_o  ,  p2_0_o   , p3_0_o ;                   
output[7:0] q0_0_o  ,  q1_0_o  ,  q2_0_o   , q3_0_o ;

output[7:0] p0_1_o  ,  p1_1_o  ,  p2_1_o   , p3_1_o  ;
output[7:0] q0_1_o  ,  q1_1_o  ,  q2_1_o   , q3_1_o  ;

output [3:0] not_nature_edge_o  ;

wire signed [8:0]  p0_0_s_w  =  {1'b0 , p0_0_i } ;
wire signed [8:0]  p0_1_s_w  =  {1'b0 , p0_1_i } ;
wire signed [8:0]  p0_2_s_w  =  {1'b0 , p0_2_i } ;
wire signed [8:0]  p1_0_s_w  =  {1'b0 , p1_0_i } ;
wire signed [8:0]  p1_1_s_w  =  {1'b0 , p1_1_i } ;
wire signed [8:0]  p1_2_s_w  =  {1'b0 , p1_2_i } ;
wire signed [8:0]  p2_0_s_w  =  {1'b0 , p2_0_i } ;
wire signed [8:0]  p2_1_s_w  =  {1'b0 , p2_1_i } ;
wire signed [8:0]  p2_2_s_w  =  {1'b0 , p2_2_i } ;
wire signed [8:0]  p3_0_s_w  =  {1'b0 , p3_0_i } ;
wire signed [8:0]  p3_1_s_w  =  {1'b0 , p3_1_i } ;
wire signed [8:0]  p3_2_s_w  =  {1'b0 , p3_2_i } ;
                                                
wire signed [8:0]  q0_0_s_w  =  {1'b0 , q0_0_i } ;
wire signed [8:0]  q0_1_s_w  =  {1'b0 , q0_1_i } ;
wire signed [8:0]  q0_2_s_w  =  {1'b0 , q0_2_i } ;
wire signed [8:0]  q1_0_s_w  =  {1'b0 , q1_0_i } ;
wire signed [8:0]  q1_1_s_w  =  {1'b0 , q1_1_i } ;
wire signed [8:0]  q1_2_s_w  =  {1'b0 , q1_2_i } ;
wire signed [8:0]  q2_0_s_w  =  {1'b0 , q2_0_i } ;
wire signed [8:0]  q2_1_s_w  =  {1'b0 , q2_1_i } ;
wire signed [8:0]  q2_2_s_w  =  {1'b0 , q2_2_i } ;
wire signed [8:0]  q3_0_s_w  =  {1'b0 , q3_0_i } ;
wire signed [8:0]  q3_1_s_w  =  {1'b0 , q3_1_i } ;
wire signed [8:0]  q3_2_s_w  =  {1'b0 , q3_2_i } ;


wire signed [8:0]  delta0_o  ;
wire signed [8:0]  delta1_o  ;
wire signed [8:0]  delta2_o  ;
wire signed [8:0]  delta3_o  ;
//---------------------------------------------------------------------------
//
//              COMBINATION  CIRCUIT:cacl amplitude
//
//----------------------------------------------------------------------------

wire [8:0] tc_mux_10 = (tc_i<<3) + (tc_i<<1) ;

wire signed  [5:0] tc_x = ~tc_i + 1'b1 ;
wire signed  [5:0] tc_y = {1'b0,tc_i};

//1 pixel filtered  
wire  signed [8:0]  qm_p00      =  q0_0_s_w - p0_0_s_w   ; 
wire  signed [8:0]  qm_p10      =  q1_0_s_w - p1_0_s_w   ; 
wire  signed [8:0]  qm_p20      =  q2_0_s_w - p2_0_s_w   ; 
wire  signed [8:0]  qm_p30      =  q3_0_s_w - p3_0_s_w   ; 

wire  signed [8:0]  qm_p01      =  q0_1_s_w - p0_1_s_w   ;
wire  signed [8:0]  qm_p11      =  q1_1_s_w - p1_1_s_w   ;
wire  signed [8:0]  qm_p21      =  q2_1_s_w - p2_1_s_w   ;
wire  signed [8:0]  qm_p31      =  q3_1_s_w - p3_1_s_w   ;

wire  signed [11:0] qm_p0_m_8_w = {qm_p00,3'b0}      ;
wire  signed [11:0] qm_p1_m_8_w = {qm_p10,3'b0}      ;
wire  signed [11:0] qm_p2_m_8_w = {qm_p20,3'b0}      ;
wire  signed [11:0] qm_p3_m_8_w = {qm_p30,3'b0}      ;

wire  signed [11:0] qm_p0_m_1_w = {{2{qm_p01[8]}},qm_p01,1'b0} ;
wire  signed [11:0] qm_p1_m_1_w = {{2{qm_p11[8]}},qm_p11,1'b0} ;
wire  signed [11:0] qm_p2_m_1_w = {{2{qm_p21[8]}},qm_p21,1'b0} ;
wire  signed [11:0] qm_p3_m_1_w = {{2{qm_p31[8]}},qm_p31,1'b0} ;

wire signed  [11:0] qm_p0_w     = qm_p0_m_8_w - qm_p0_m_1_w; 
wire signed  [11:0] qm_p1_w     = qm_p1_m_8_w - qm_p1_m_1_w;
wire signed  [11:0] qm_p2_w     = qm_p2_m_8_w - qm_p2_m_1_w;
wire signed  [11:0] qm_p3_w     = qm_p3_m_8_w - qm_p3_m_1_w;
  
wire signed  [8:0]  qm_q0_w     = qm_p00  -   qm_p01   ;
wire signed  [8:0]  qm_q1_w     = qm_p10  -   qm_p11   ;
wire signed  [8:0]  qm_q2_w     = qm_p20  -   qm_p21   ;
wire signed  [8:0]  qm_q3_w     = qm_p30  -   qm_p31   ;
   
wire signed  [11:0] qm_q0_e3_w  = {{3{qm_q0_w[8]}},qm_q0_w};
wire signed  [11:0] qm_q1_e3_w  = {{3{qm_q1_w[8]}},qm_q1_w};
wire signed  [11:0] qm_q2_e3_w  = {{3{qm_q2_w[8]}},qm_q2_w};
wire signed  [11:0] qm_q3_e3_w  = {{3{qm_q3_w[8]}},qm_q3_w};

wire signed  [12:0] delta0_w     = qm_p0_w + qm_q0_e3_w+8;
wire signed  [12:0] delta1_w     = qm_p1_w + qm_q1_e3_w+8;
wire signed  [12:0] delta2_w     = qm_p2_w + qm_q2_e3_w+8;
wire signed  [12:0] delta3_w     = qm_p3_w + qm_q3_e3_w+8;

wire  signed [8:0] delta0       =  delta0_w[12:4];
wire  signed [8:0] delta1       =  delta1_w[12:4];
wire  signed [8:0] delta2       =  delta2_w[12:4];
wire  signed [8:0] delta3       =  delta3_w[12:4];

//wire  signed [8:0] delta0   =  delta0_m[12:4] ;
//wire  signed [8:0] delta1   =  delta1_m[12:4] ;
//wire  signed [8:0] delta2   =  delta2_m[12:4] ;
//wire  signed [8:0] delta3   =  delta3_m[12:4] ;

wire [8:0]  delta0_abs  =  delta0[8]  ?  ( ~delta0 + 1'b1 ) : delta0 ;
wire [8:0]  delta1_abs  =  delta1[8]  ?  ( ~delta1 + 1'b1 ) : delta1 ;
wire [8:0]  delta2_abs  =  delta2[8]  ?  ( ~delta2 + 1'b1 ) : delta2 ;
wire [8:0]  delta3_abs  =  delta3[8]  ?  ( ~delta3 + 1'b1 ) : delta3 ;

assign not_nature_edge_o[0] = ( delta0_abs < tc_mux_10) ? 1'b1 : 1'b0 ;
assign not_nature_edge_o[1] = ( delta1_abs < tc_mux_10) ? 1'b1 : 1'b0 ;
assign not_nature_edge_o[2] = ( delta2_abs < tc_mux_10) ? 1'b1 : 1'b0 ;
assign not_nature_edge_o[3] = ( delta3_abs < tc_mux_10) ? 1'b1 : 1'b0 ;
   
assign delta0_o  = (delta0 <  tc_x ) ? tc_x : (delta0 > tc_y ? tc_y : delta0) ;
assign delta1_o  = (delta1 <  tc_x ) ? tc_x : (delta1 > tc_y ? tc_y : delta1) ;
assign delta2_o  = (delta2 <  tc_x ) ? tc_x : (delta2 > tc_y ? tc_y : delta2) ;
assign delta3_o  = (delta3 <  tc_x ) ? tc_x : (delta3 > tc_y ? tc_y : delta3) ;


//-----------------------------------------------------------------------------
//normal filter:1
wire  signed [9:0] pplus_delta00_w  =   p0_0_s_w + delta0_o    ;
wire  signed [9:0] pplus_delta10_w  =   p1_0_s_w + delta1_o    ;
wire  signed [9:0] pplus_delta20_w  =   p2_0_s_w + delta2_o    ;
wire  signed [9:0] pplus_delta30_w  =   p3_0_s_w + delta3_o    ;

wire  signed [9:0] qplus_delta00_w  =   q0_0_s_w - delta0_o    ;
wire  signed [9:0] qplus_delta10_w  =   q1_0_s_w - delta1_o    ;
wire  signed [9:0] qplus_delta20_w  =   q2_0_s_w - delta2_o    ;
wire  signed [9:0] qplus_delta30_w  =   q3_0_s_w - delta3_o    ;
                   
assign  p0_0_o  =   pplus_delta00_w[9] ? 8'b0 : ( (pplus_delta00_w  >  10'd255 )? 8'd255 : pplus_delta00_w[7:0] );
assign  p1_0_o  =   pplus_delta10_w[9] ? 8'b0 : ( (pplus_delta10_w  >  10'd255 )? 8'd255 : pplus_delta10_w[7:0] );
assign  p2_0_o  =   pplus_delta20_w[9] ? 8'b0 : ( (pplus_delta20_w  >  10'd255 )? 8'd255 : pplus_delta20_w[7:0] );
assign  p3_0_o  =   pplus_delta30_w[9] ? 8'b0 : ( (pplus_delta30_w  >  10'd255 )? 8'd255 : pplus_delta30_w[7:0] );
           
assign  q0_0_o  =   qplus_delta00_w[9] ? 8'b0 : ( (qplus_delta00_w  >  10'd255 )? 8'd255 : qplus_delta00_w[7:0] );
assign  q1_0_o  =   qplus_delta10_w[9] ? 8'b0 : ( (qplus_delta10_w  >  10'd255 )? 8'd255 : qplus_delta10_w[7:0] );
assign  q2_0_o  =   qplus_delta20_w[9] ? 8'b0 : ( (qplus_delta20_w  >  10'd255 )? 8'd255 : qplus_delta20_w[7:0] );
assign  q3_0_o  =   qplus_delta30_w[9] ? 8'b0 : ( (qplus_delta30_w  >  10'd255 )? 8'd255 : qplus_delta30_w[7:0] );
//-----------------------------------------------------------------------------
//normal filter:2

wire signed [4:0] tc_div_x =~(tc_i[4:1]) + 1'b1;
wire signed [4:0] tc_div_y ={1'b0,tc_i[4:1]} ;

wire  signed [8:0] deltap2_0_w  =  ( ( (p0_2_s_w + p0_0_s_w + 1) >>1) - p0_1_s_w + delta0_o) >>1 ;
wire  signed [8:0] deltap2_1_w  =  ( ( (p1_2_s_w + p1_0_s_w + 1) >>1) - p1_1_s_w + delta1_o) >>1 ;
wire  signed [8:0] deltap2_2_w  =  ( ( (p2_2_s_w + p2_0_s_w + 1) >>1) - p2_1_s_w + delta2_o) >>1 ;
wire  signed [8:0] deltap2_3_w  =  ( ( (p3_2_s_w + p3_0_s_w + 1) >>1) - p3_1_s_w + delta3_o) >>1 ;

wire  signed [8:0] deltaq2_0_w  =  ( ( (q0_2_s_w + q0_0_s_w + 1) >>1) - q0_1_s_w - delta0_o) >>1 ;
wire  signed [8:0] deltaq2_1_w  =  ( ( (q1_2_s_w + q1_0_s_w + 1) >>1) - q1_1_s_w - delta1_o) >>1 ;
wire  signed [8:0] deltaq2_2_w  =  ( ( (q2_2_s_w + q2_0_s_w + 1) >>1) - q2_1_s_w - delta2_o) >>1 ;
wire  signed [8:0] deltaq2_3_w  =  ( ( (q3_2_s_w + q3_0_s_w + 1) >>1) - q3_1_s_w - delta3_o) >>1 ;

wire  signed [8:0] delta2_p0_w  = deltap2_0_w < tc_div_x ?  tc_div_x : (deltap2_0_w > tc_div_y  ? tc_div_y  : deltap2_0_w);
wire  signed [8:0] delta2_p1_w  = deltap2_1_w < tc_div_x ?  tc_div_x : (deltap2_1_w > tc_div_y  ? tc_div_y  : deltap2_1_w); 
wire  signed [8:0] delta2_p2_w  = deltap2_2_w < tc_div_x ?  tc_div_x : (deltap2_2_w > tc_div_y  ? tc_div_y  : deltap2_2_w); 
wire  signed [8:0] delta2_p3_w  = deltap2_3_w < tc_div_x ?  tc_div_x : (deltap2_3_w > tc_div_y  ? tc_div_y  : deltap2_3_w);  
                                  
wire  signed [8:0] delta2_q0_w  = deltaq2_0_w < tc_div_x ?  tc_div_x : (deltaq2_0_w > tc_div_y  ? tc_div_y  : deltaq2_0_w);
wire  signed [8:0] delta2_q1_w  = deltaq2_1_w < tc_div_x ?  tc_div_x : (deltaq2_1_w > tc_div_y  ? tc_div_y  : deltaq2_1_w); 
wire  signed [8:0] delta2_q2_w  = deltaq2_2_w < tc_div_x ?  tc_div_x : (deltaq2_2_w > tc_div_y  ? tc_div_y  : deltaq2_2_w); 
wire  signed [8:0] delta2_q3_w  = deltaq2_3_w < tc_div_x ?  tc_div_x : (deltaq2_3_w > tc_div_y  ? tc_div_y  : deltaq2_3_w);  

wire  signed [9:0] pplus_delta01_w  =   p0_1_s_w + delta2_p0_w  ;
wire  signed [9:0] pplus_delta11_w  =   p1_1_s_w + delta2_p1_w  ;
wire  signed [9:0] pplus_delta21_w  =   p2_1_s_w + delta2_p2_w  ;
wire  signed [9:0] pplus_delta31_w  =   p3_1_s_w + delta2_p3_w  ;
                                             
wire  signed [9:0] qplus_delta01_w  =   q0_1_s_w + delta2_q0_w  ;
wire  signed [9:0] qplus_delta11_w  =   q1_1_s_w + delta2_q1_w  ;
wire  signed [9:0] qplus_delta21_w  =   q2_1_s_w + delta2_q2_w  ;
wire  signed [9:0] qplus_delta31_w  =   q3_1_s_w + delta2_q3_w  ;

assign p0_1_o   =   pplus_delta01_w[9] ? 8'd0 : ( pplus_delta01_w[8]? 8'd255 : pplus_delta01_w[7:0]);
assign p1_1_o   =   pplus_delta11_w[9] ? 8'd0 : ( pplus_delta11_w[8]? 8'd255 : pplus_delta11_w[7:0]);
assign p2_1_o   =   pplus_delta21_w[9] ? 8'd0 : ( pplus_delta21_w[8]? 8'd255 : pplus_delta21_w[7:0]);
assign p3_1_o   =   pplus_delta31_w[9] ? 8'd0 : ( pplus_delta31_w[8]? 8'd255 : pplus_delta31_w[7:0]);
  
assign q0_1_o   =   qplus_delta01_w[9] ? 8'd0 : ( qplus_delta01_w[8]? 8'd255 : qplus_delta01_w[7:0]);
assign q1_1_o   =   qplus_delta11_w[9] ? 8'd0 : ( qplus_delta11_w[8]? 8'd255 : qplus_delta11_w[7:0]);
assign q2_1_o   =   qplus_delta21_w[9] ? 8'd0 : ( qplus_delta21_w[8]? 8'd255 : qplus_delta21_w[7:0]);
assign q3_1_o   =   qplus_delta31_w[9] ? 8'd0 : ( qplus_delta31_w[8]? 8'd255 : qplus_delta31_w[7:0]);




endmodule 