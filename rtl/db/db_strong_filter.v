//----------------------------------------------------------------------------
//                                                                 
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//                                                                  
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE      
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//                                                                  
//  VIPcore       : http://socfudaneducn/vip    
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudaneducn             
//----------------------------------------------------------------------------
// Filename       : db_strong_filter.v
// Author         : chewein
// Created        : 2014-04-018
// Description    : the filter process of strong filter         
//----------------------------------------------------------------------------
module db_strong_filter(
                tc_i,
                p0_0_i  ,  p0_1_i  ,  p0_2_i  ,  p0_3_i,
                p1_0_i  ,  p1_1_i  ,  p1_2_i  ,  p1_3_i,
                p2_0_i  ,  p2_1_i  ,  p2_2_i  ,  p2_3_i,
                p3_0_i  ,  p3_1_i  ,  p3_2_i  ,  p3_3_i,
                                                    
                q0_0_i  ,  q0_1_i  ,  q0_2_i  ,  q0_3_i,
                q1_0_i  ,  q1_1_i  ,  q1_2_i  ,  q1_3_i,
                q2_0_i  ,  q2_1_i  ,  q2_2_i  ,  q2_3_i,
                q3_0_i  ,  q3_1_i  ,  q3_2_i  ,  q3_3_i,
                                        
                p0_0_o  ,  p0_1_o  ,  p0_2_o,
                p1_0_o  ,  p1_1_o  ,  p1_2_o,
                p2_0_o  ,  p2_1_o  ,  p2_2_o,
                p3_0_o  ,  p3_1_o  ,  p3_2_o,
                                               
                q0_0_o  ,  q0_1_o  ,  q0_2_o,
                q1_0_o  ,  q1_1_o  ,  q1_2_o,
                q2_0_o  ,  q2_1_o  ,  q2_2_o,
                q3_0_o  ,  q3_1_o  ,  q3_2_o
                );                          
//---------------------------------------------------------------------------
//
//                        INPUT/OUTPUT DECLARATION 
//
//----------------------------------------------------------------------------
input [4:0] tc_i;

input  [7:0]        p0_0_i  ,  p0_1_i  ,  p0_2_i  ,  p0_3_i  ,
                    p1_0_i  ,  p1_1_i  ,  p1_2_i  ,  p1_3_i  ,
                    p2_0_i  ,  p2_1_i  ,  p2_2_i  ,  p2_3_i  ,
                    p3_0_i  ,  p3_1_i  ,  p3_2_i  ,  p3_3_i  ;
                                                         
input  [7:0]        q0_0_i  ,  q0_1_i  ,  q0_2_i  ,  q0_3_i  ,
                    q1_0_i  ,  q1_1_i  ,  q1_2_i  ,  q1_3_i  ,
                    q2_0_i  ,  q2_1_i  ,  q2_2_i  ,  q2_3_i  ,
                    q3_0_i  ,  q3_1_i  ,  q3_2_i  ,  q3_3_i  ;
                       
output wire [7:0]   p0_0_o  ,  p0_1_o  ,  p0_2_o  ,
                    p1_0_o  ,  p1_1_o  ,  p1_2_o  ,
                    p2_0_o  ,  p2_1_o  ,  p2_2_o  ,
                    p3_0_o  ,  p3_1_o  ,  p3_2_o  ;
                                             
output wire [7:0]   q0_0_o  ,  q0_1_o  ,  q0_2_o  ,
                    q1_0_o  ,  q1_1_o  ,  q1_2_o  ,
                    q2_0_o  ,  q2_1_o  ,  q2_2_o  ,
                    q3_0_o  ,  q3_1_o  ,  q3_2_o  ;

//---------------------------------------------------------------------------
//
//              COMBINATION  CIRCUIT:cacl amplitude
//
//----------------------------------------------------------------------------

wire signed [8:0] tc_i_2_x_w =  {2'b0,tc_i,1'b0} ;                   
wire        [7:0] tc_i_2_y_w =  {1'b0,tc_i,1'b0} ;

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

//p0
wire signed [8:0]  pminus_2t_0_0  =  p0_0_s_w - tc_i_2_x_w ;
wire signed [8:0]  pminus_2t_0_1  =  p0_1_s_w - tc_i_2_x_w ; 
wire signed [8:0]  pminus_2t_0_2  =  p0_2_s_w - tc_i_2_x_w ;    

wire        [8:0]  pplus_2t_0_0   =  p0_0_i   + tc_i_2_y_w ;
wire        [8:0]  pplus_2t_0_1   =  p0_1_i   + tc_i_2_y_w ;
wire        [8:0]  pplus_2t_0_2   =  p0_2_i   + tc_i_2_y_w ;
//p1
wire signed [8:0]  pminus_2t_1_0  =  p1_0_s_w - tc_i_2_x_w ;
wire signed [8:0]  pminus_2t_1_1  =  p1_1_s_w - tc_i_2_x_w ; 
wire signed [8:0]  pminus_2t_1_2  =  p1_2_s_w - tc_i_2_x_w ;
                                           
wire        [8:0]  pplus_2t_1_0   =  p1_0_i   + tc_i_2_y_w ;
wire        [8:0]  pplus_2t_1_1   =  p1_1_i   + tc_i_2_y_w ;
wire        [8:0]  pplus_2t_1_2   =  p1_2_i   + tc_i_2_y_w ;
//p2
wire signed [8:0]  pminus_2t_2_0  =  p2_0_s_w - tc_i_2_x_w ;
wire signed [8:0]  pminus_2t_2_1  =  p2_1_s_w - tc_i_2_x_w ; 
wire signed [8:0]  pminus_2t_2_2  =  p2_2_s_w - tc_i_2_x_w ;    
                                                
wire        [8:0]  pplus_2t_2_0   =  p2_0_i   + tc_i_2_y_w ;
wire        [8:0]  pplus_2t_2_1   =  p2_1_i   + tc_i_2_y_w ;
wire        [8:0]  pplus_2t_2_2   =  p2_2_i   + tc_i_2_y_w ;
//p3
wire signed [8:0]  pminus_2t_3_0  =  p3_0_s_w - tc_i_2_x_w ;
wire signed [8:0]  pminus_2t_3_1  =  p3_1_s_w - tc_i_2_x_w ; 
wire signed [8:0]  pminus_2t_3_2  =  p3_2_s_w - tc_i_2_x_w ;     
                                                
wire        [8:0]  pplus_2t_3_0   =  p3_0_i   + tc_i_2_y_w ;
wire        [8:0]  pplus_2t_3_1   =  p3_1_i   + tc_i_2_y_w ;
wire        [8:0]  pplus_2t_3_2   =  p3_2_i   + tc_i_2_y_w ;
//abs 
wire [7:0]  pminus_2t_0_0_abs = pminus_2t_0_0[8]? 8'd0  : pminus_2t_0_0[7:0];
wire [7:0]  pminus_2t_0_1_abs = pminus_2t_0_1[8]? 8'd0  : pminus_2t_0_1[7:0]; 
wire [7:0]  pminus_2t_0_2_abs = pminus_2t_0_2[8]? 8'd0  : pminus_2t_0_2[7:0];                                       
                               
wire [7:0]  pplus_2t_0_0_abs  = pplus_2t_0_0[8] ? 8'd255: pplus_2t_0_0[7:0] ; 
wire [7:0]  pplus_2t_0_1_abs  = pplus_2t_0_1[8] ? 8'd255: pplus_2t_0_1[7:0] ;
wire [7:0]  pplus_2t_0_2_abs  = pplus_2t_0_2[8] ? 8'd255: pplus_2t_0_2[7:0] ;
    
wire [7:0]  pminus_2t_1_0_abs = pminus_2t_1_0[8]? 8'd0  : pminus_2t_1_0[7:0];
wire [7:0]  pminus_2t_1_1_abs = pminus_2t_1_1[8]? 8'd0  : pminus_2t_1_1[7:0];    
wire [7:0]  pminus_2t_1_2_abs = pminus_2t_1_2[8]? 8'd0  : pminus_2t_1_2[7:0];   
    
wire [7:0]  pplus_2t_1_0_abs  = pplus_2t_1_0[8] ? 8'd255: pplus_2t_1_0[7:0] ; 
wire [7:0]  pplus_2t_1_1_abs  = pplus_2t_1_1[8] ? 8'd255: pplus_2t_1_1[7:0] ; 
wire [7:0]  pplus_2t_1_2_abs  = pplus_2t_1_2[8] ? 8'd255: pplus_2t_1_2[7:0] ; 
    
wire [7:0]  pminus_2t_2_0_abs = pminus_2t_2_0[8]? 8'd0  : pminus_2t_2_0[7:0];
wire [7:0]  pminus_2t_2_1_abs = pminus_2t_2_1[8]? 8'd0  : pminus_2t_2_1[7:0];
wire [7:0]  pminus_2t_2_2_abs = pminus_2t_2_2[8]? 8'd0  : pminus_2t_2_2[7:0]; 

wire [7:0]  pplus_2t_2_0_abs  = pplus_2t_2_0[8] ? 8'd255: pplus_2t_2_0[7:0] ;
wire [7:0]  pplus_2t_2_1_abs  = pplus_2t_2_1[8] ? 8'd255: pplus_2t_2_1[7:0] ;
wire [7:0]  pplus_2t_2_2_abs  = pplus_2t_2_2[8] ? 8'd255: pplus_2t_2_2[7:0] ;

wire [7:0]  pminus_2t_3_0_abs = pminus_2t_3_0[8]? 8'd0  : pminus_2t_3_0[7:0];
wire [7:0]  pminus_2t_3_1_abs = pminus_2t_3_1[8]? 8'd0  : pminus_2t_3_1[7:0];
wire [7:0]  pminus_2t_3_2_abs = pminus_2t_3_2[8]? 8'd0  : pminus_2t_3_2[7:0]; 

wire [7:0]  pplus_2t_3_0_abs  = pplus_2t_3_0[8] ? 8'd255: pplus_2t_3_0[7:0] ;
wire [7:0]  pplus_2t_3_1_abs  = pplus_2t_3_1[8] ? 8'd255: pplus_2t_3_1[7:0] ;
wire [7:0]  pplus_2t_3_2_abs  = pplus_2t_3_2[8] ? 8'd255: pplus_2t_3_2[7:0] ;

//q0
wire signed [8:0]  qminus_2t_0_0  =  q0_0_s_w - tc_i_2_x_w ;
wire signed [8:0]  qminus_2t_0_1  =  q0_1_s_w - tc_i_2_x_w ; 
wire signed [8:0]  qminus_2t_0_2  =  q0_2_s_w - tc_i_2_x_w ;     
                                                
wire        [8:0]  qplus_2t_0_0   =  q0_0_i   + tc_i_2_y_w ;
wire        [8:0]  qplus_2t_0_1   =  q0_1_i   + tc_i_2_y_w ;
wire        [8:0]  qplus_2t_0_2   =  q0_2_i   + tc_i_2_y_w ;

//q1
wire signed [8:0]  qminus_2t_1_0  =  q1_0_s_w - tc_i_2_x_w ;
wire signed [8:0]  qminus_2t_1_1  =  q1_1_s_w - tc_i_2_x_w ; 
wire signed [8:0]  qminus_2t_1_2  =  q1_2_s_w - tc_i_2_x_w ;     
                                                
wire        [8:0]  qplus_2t_1_0   =  q1_0_i   + tc_i_2_y_w ;
wire        [8:0]  qplus_2t_1_1   =  q1_1_i   + tc_i_2_y_w ;
wire        [8:0]  qplus_2t_1_2   =  q1_2_i   + tc_i_2_y_w ;

//q2
wire signed [8:0]  qminus_2t_2_0  =  q2_0_s_w - tc_i_2_x_w ;
wire signed [8:0]  qminus_2t_2_1  =  q2_1_s_w - tc_i_2_x_w ; 
wire signed [8:0]  qminus_2t_2_2  =  q2_2_s_w - tc_i_2_x_w ;     
                                                
wire        [8:0]  qplus_2t_2_0   =  q2_0_i   + tc_i_2_y_w;
wire        [8:0]  qplus_2t_2_1   =  q2_1_i   + tc_i_2_y_w ;
wire        [8:0]  qplus_2t_2_2   =  q2_2_i   + tc_i_2_y_w ;

//q3
wire signed [8:0]  qminus_2t_3_0  =  q3_0_s_w - tc_i_2_x_w ;
wire signed [8:0]  qminus_2t_3_1  =  q3_1_s_w - tc_i_2_x_w ; 
wire signed [8:0]  qminus_2t_3_2  =  q3_2_s_w - tc_i_2_x_w ;     
                                                
wire        [8:0]  qplus_2t_3_0   =  q3_0_i   + tc_i_2_y_w;
wire        [8:0]  qplus_2t_3_1   =  q3_1_i   + tc_i_2_y_w ;
wire        [8:0]  qplus_2t_3_2   =  q3_2_i   + tc_i_2_y_w ;

//abs
wire [7:0]  qminus_2t_0_0_abs =  qminus_2t_0_0[8]? 8'd0  : qminus_2t_0_0[7:0];
wire [7:0]  qminus_2t_0_1_abs =  qminus_2t_0_1[8]? 8'd0  : qminus_2t_0_1[7:0]; 
wire [7:0]  qminus_2t_0_2_abs =  qminus_2t_0_2[8]? 8'd0  : qminus_2t_0_2[7:0];                                      
                                                           
wire [7:0]  qplus_2t_0_0_abs  =  qplus_2t_0_0[8] ? 8'd255: qplus_2t_0_0[7:0] ; 
wire [7:0]  qplus_2t_0_1_abs  =  qplus_2t_0_1[8] ? 8'd255: qplus_2t_0_1[7:0] ;
wire [7:0]  qplus_2t_0_2_abs  =  qplus_2t_0_2[8] ? 8'd255: qplus_2t_0_2[7:0] ;

wire [7:0]  qminus_2t_1_0_abs = qminus_2t_1_0[8] ? 8'd0  : qminus_2t_1_0[7:0];
wire [7:0]  qminus_2t_1_1_abs = qminus_2t_1_1[8] ? 8'd0  : qminus_2t_1_1[7:0];   
wire [7:0]  qminus_2t_1_2_abs = qminus_2t_1_2[8] ? 8'd0  : qminus_2t_1_2[7:0];  
  
wire [7:0]  qplus_2t_1_0_abs  = qplus_2t_1_0[8]  ? 8'd255: qplus_2t_1_0[7:0] ; 
wire [7:0]  qplus_2t_1_1_abs  = qplus_2t_1_1[8]  ? 8'd255: qplus_2t_1_1[7:0] ; 
wire [7:0]  qplus_2t_1_2_abs  = qplus_2t_1_2[8]  ? 8'd255: qplus_2t_1_2[7:0] ; 

wire [7:0]  qminus_2t_2_0_abs = qminus_2t_2_0[8] ? 8'd0  : qminus_2t_2_0[7:0];
wire [7:0]  qminus_2t_2_1_abs = qminus_2t_2_1[8] ? 8'd0  : qminus_2t_2_1[7:0];
wire [7:0]  qminus_2t_2_2_abs = qminus_2t_2_2[8] ? 8'd0  : qminus_2t_2_2[7:0]; 

wire [7:0]  qplus_2t_2_0_abs  = qplus_2t_2_0[8]  ? 8'd255: qplus_2t_2_0[7:0] ;
wire [7:0]  qplus_2t_2_1_abs  = qplus_2t_2_1[8]  ? 8'd255: qplus_2t_2_1[7:0] ;
wire [7:0]  qplus_2t_2_2_abs  = qplus_2t_2_2[8]  ? 8'd255: qplus_2t_2_2[7:0] ;

wire [7:0]  qminus_2t_3_0_abs = qminus_2t_3_0[8] ? 8'd0  : qminus_2t_3_0[7:0];
wire [7:0]  qminus_2t_3_1_abs = qminus_2t_3_1[8] ? 8'd0  : qminus_2t_3_1[7:0];
wire [7:0]  qminus_2t_3_2_abs = qminus_2t_3_2[8] ? 8'd0  : qminus_2t_3_2[7:0]; 

wire [7:0]  qplus_2t_3_0_abs  = qplus_2t_3_0[8]  ? 8'd255: qplus_2t_3_0[7:0] ;
wire [7:0]  qplus_2t_3_1_abs  = qplus_2t_3_1[8]  ? 8'd255: qplus_2t_3_1[7:0] ;
wire [7:0]  qplus_2t_3_2_abs  = qplus_2t_3_2[8]  ? 8'd255: qplus_2t_3_2[7:0] ;
        
//---------------------------------------------------------------------------
//
//              COMBINATION  CIRCUIT:cacl strong filtered result 
//
//----------------------------------------------------------------------------
wire [10:0] pcommon_adder_0 =  p0_2_s_w + p0_1_s_w + p0_0_s_w + q0_0_s_w + 2;
wire [10:0] pcommon_adder_1 =  p1_2_s_w + p1_1_s_w + p1_0_s_w + q1_0_s_w + 2;
wire [10:0] pcommon_adder_2 =  p2_2_s_w + p2_1_s_w + p2_0_s_w + q2_0_s_w + 2;
wire [10:0] pcommon_adder_3 =  p3_2_s_w + p3_1_s_w + p3_0_s_w + q3_0_s_w + 2;
//p0            
wire [8:0] p0_0_w =(pcommon_adder_0 + p0_1_i +p0_0_i +q0_0_i + q0_1_i+ 2 )>>3;
wire [8:0] p0_1_w = pcommon_adder_0 >> 2;
wire [8:0] p0_2_w =(pcommon_adder_0 + (p0_3_i<<1)+ ( p0_2_i<<1) + 2)>>3;
//p1                                                                                    
wire [8:0] p1_0_w =(pcommon_adder_1 + p1_1_i +p1_0_i +q1_0_i + q1_1_i + 2)>>3;
wire [8:0] p1_1_w = pcommon_adder_1>>2;
wire [8:0] p1_2_w =(pcommon_adder_1 + (p1_3_i<<1)+ (p1_2_i<<1) +  2)>>3;
//p2                         
wire [8:0] p2_0_w =(pcommon_adder_2 + p2_1_i +p2_0_i +q2_0_i + q2_1_i + 2 )>>3;
wire [8:0] p2_1_w = pcommon_adder_2>>2;
wire [8:0] p2_2_w =(pcommon_adder_2 + (p2_3_i<<1) +(p2_2_i<<1) + 2 )>>3;
//p3              
wire [8:0] p3_0_w =(pcommon_adder_3 + p3_1_i +p3_0_i +q3_0_i + q3_1_i + 2 )>> 3 ;
wire [8:0] p3_1_w = pcommon_adder_3>>2;
wire [8:0] p3_2_w =(pcommon_adder_3 + (p3_3_i<<1) +(p3_2_i<<1) +  2 ) >> 3 ;

wire [10:0] qcommon_adder_0 =  q0_2_i + q0_1_i + q0_0_i + p0_0_i + 2;
wire [10:0] qcommon_adder_1 =  q1_2_i + q1_1_i + q1_0_i + p1_0_i + 2;
wire [10:0] qcommon_adder_2 =  q2_2_i + q2_1_i + q2_0_i + p2_0_i + 2;
wire [10:0] qcommon_adder_3 =  q3_2_i + q3_1_i + q3_0_i + p3_0_i + 2;
//q0                 
wire [8:0] q0_0_w =(qcommon_adder_0 +q0_1_i +q0_0_i +p0_0_i + p0_1_i + 2)>> 3 ;
wire [8:0] q0_1_w = qcommon_adder_0 >> 2 ;
wire [8:0] q0_2_w =(qcommon_adder_0  +(q0_3_i<<1) +(q0_2_i<<1) + 2)>>3; 
//q1        
wire [8:0] q1_0_w =(qcommon_adder_1 +q1_1_i +q1_0_i +p1_0_i + p1_1_i + 2)>> 3 ;
wire [8:0] q1_1_w = qcommon_adder_1 >> 2 ;
wire [8:0] q1_2_w =(qcommon_adder_1 +(q1_3_i<<1) +(q1_2_i<<1) + 2) >> 3 ;
//q2               
wire [8:0] q2_0_w =(qcommon_adder_2 +q2_1_i +q2_0_i +p2_0_i + p2_1_i + 2)>> 3 ;
wire [8:0] q2_1_w = qcommon_adder_2 >> 2 ;
wire [8:0] q2_2_w =(qcommon_adder_2 +(q2_3_i<<1) +(q2_2_i<<1) +  2)>> 3 ;
//q3              
wire [8:0] q3_0_w =(qcommon_adder_3 +q3_1_i +q3_0_i +p3_0_i + p3_1_i + 2)>> 3 ;
wire [8:0] q3_1_w = qcommon_adder_3 >> 2 ;
wire [8:0] q3_2_w =(qcommon_adder_3 + (q3_3_i<<1) +(q3_2_i<<1) + 2 ) >> 3 ;

//clip                      
//p0        
db_clip3_str u_strong_p00(p0_0_o , pminus_2t_0_0_abs , pplus_2t_0_0_abs , p0_0_w );         
db_clip3_str u_strong_p01(p0_1_o , pminus_2t_0_1_abs , pplus_2t_0_1_abs , p0_1_w );
db_clip3_str u_strong_p02(p0_2_o , pminus_2t_0_2_abs , pplus_2t_0_2_abs , p0_2_w );
//p1                                                                       
db_clip3_str u_strong_p10(p1_0_o , pminus_2t_1_0_abs , pplus_2t_1_0_abs , p1_0_w );         
db_clip3_str u_strong_p11(p1_1_o , pminus_2t_1_1_abs , pplus_2t_1_1_abs , p1_1_w );
db_clip3_str u_strong_p12(p1_2_o , pminus_2t_1_2_abs , pplus_2t_1_2_abs , p1_2_w );
//p2                                                                       
db_clip3_str u_strong_p20(p2_0_o , pminus_2t_2_0_abs , pplus_2t_2_0_abs , p2_0_w );         
db_clip3_str u_strong_p21(p2_1_o , pminus_2t_2_1_abs , pplus_2t_2_1_abs , p2_1_w );
db_clip3_str u_strong_p22(p2_2_o , pminus_2t_2_2_abs , pplus_2t_2_2_abs , p2_2_w );
//p3                                                                       
db_clip3_str u_strong_p30(p3_0_o , pminus_2t_3_0_abs , pplus_2t_3_0_abs , p3_0_w );         
db_clip3_str u_strong_p31(p3_1_o , pminus_2t_3_1_abs , pplus_2t_3_1_abs , p3_1_w );
db_clip3_str u_strong_p32(p3_2_o , pminus_2t_3_2_abs , pplus_2t_3_2_abs , p3_2_w );
//q0                                                                       
db_clip3_str u_strong_q00(q0_0_o , qminus_2t_0_0_abs , qplus_2t_0_0_abs , q0_0_w );         
db_clip3_str u_strong_q01(q0_1_o , qminus_2t_0_1_abs , qplus_2t_0_1_abs , q0_1_w );
db_clip3_str u_strong_q02(q0_2_o , qminus_2t_0_2_abs , qplus_2t_0_2_abs , q0_2_w );
//q1                                                                       
db_clip3_str u_strong_q10(q1_0_o , qminus_2t_1_0_abs , qplus_2t_1_0_abs , q1_0_w );         
db_clip3_str u_strong_q11(q1_1_o , qminus_2t_1_1_abs , qplus_2t_1_1_abs , q1_1_w );
db_clip3_str u_strong_q12(q1_2_o , qminus_2t_1_2_abs , qplus_2t_1_2_abs , q1_2_w );
//q2                                                                       
db_clip3_str u_strong_q20(q2_0_o , qminus_2t_2_0_abs , qplus_2t_2_0_abs , q2_0_w );         
db_clip3_str u_strong_q21(q2_1_o , qminus_2t_2_1_abs , qplus_2t_2_1_abs , q2_1_w );
db_clip3_str u_strong_q22(q2_2_o , qminus_2t_2_2_abs , qplus_2t_2_2_abs , q2_2_w );
//q3                                                                       
db_clip3_str u_strong_q30(q3_0_o , qminus_2t_3_0_abs , qplus_2t_3_0_abs , q3_0_w );         
db_clip3_str u_strong_q31(q3_1_o , qminus_2t_3_1_abs , qplus_2t_3_1_abs , q3_1_w );
db_clip3_str u_strong_q32(q3_2_o , qminus_2t_3_2_abs , qplus_2t_3_2_abs , q3_2_w );


endmodule 


