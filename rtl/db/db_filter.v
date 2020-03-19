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
// Filename       : db_filter.v
// Author         : TANG
// Creatu_ved     : 
// Description    :         
//------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module db_filter(
            clk                 ,
            rst_n               ,
            state_i             ,
            IinP_flag_i         ,
            sys_db_ena_i        ,

            p_i                 , // rec block
            q_i                 , 

            mv_p_i              ,
            mv_q_i              ,
            mb_type_i           ,
            tu_edge_i           ,
            pu_edge_i           ,
            qp_p_i              ,
            qp_q_i              ,
            cbf_p_i             ,
            cbf_q_i             ,
            is_ver_i            ,
            // is_luma_i           ,

            p_o                 ,
            q_o                 
);

parameter DATA_WIDTH    =     128               ;

input                               clk                     ;
input                               rst_n                   ;  
input                               sys_db_ena_i            ;
input       [            2:0]       state_i                 ;
input                               IinP_flag_i             ;
input       [DATA_WIDTH-1 :0]       p_i                     ; 
input       [DATA_WIDTH-1 :0]       q_i                     ; 
input       [`FMV_WIDTH*2-1:0]      mv_p_i                  ;
input       [`FMV_WIDTH*2-1:0]      mv_q_i                  ;
input                               mb_type_i               ;
input                               tu_edge_i               ;
input                               pu_edge_i               ;
input       [           5:0]        qp_p_i                  ;
input       [           5:0]        qp_q_i                  ;
input                               cbf_p_i                 ;
input                               cbf_q_i                 ;
input                               is_ver_i                ;
// input                               is_luma_i               ;

output      [DATA_WIDTH-1:0]        p_o                     ;
output      [DATA_WIDTH-1:0]        q_o                     ;
wire        [DATA_WIDTH-1:0]        p_o                     ;
wire        [DATA_WIDTH-1:0]        q_o                     ;
        
parameter IDLE = 3'b000, LOAD = 3'b001, DBY = 3'b011, DBU = 3'b010, DBV = 3'b110, SAO = 3'b100, OUT = 3'b101;

wire is_luma_i = state_i == DBY; 

wire [4:0]      tc_w        ;
wire [6:0]      beta_w      ;
reg  [1:0]      bs_w          ;
wire            edge_type_w ;

wire  [5:0] qpw     = ( qp_p_i + qp_q_i + 1 ) >> 1;  
wire  [5:0] qpwcc   = qpw - 6'd30                 ;
wire  [5:0] qpw2    = qpw - 6'd6                  ;
reg   [5:0] qpw1                                  ;
reg   [5:0] qpc                                   ;

wire   [5:0] qp_lc_w                              ;

always @* begin
      case(qpwcc)
            6'd0 :qpw1 = 6'd29;
            6'd1 :qpw1 = 6'd30;
            6'd2 :qpw1 = 6'd31;
            6'd3 :qpw1 = 6'd32;
            6'd4 :qpw1 = 6'd33;
            6'd5 :qpw1 = 6'd33;
            6'd6 :qpw1 = 6'd34;
            6'd7 :qpw1 = 6'd34;
            6'd8 :qpw1 = 6'd35;
            6'd9 :qpw1 = 6'd35;
            6'd10:qpw1 = 6'd36;
            6'd11:qpw1 = 6'd36;
            6'd12:qpw1 = 6'd37;
            6'd13:qpw1 = 6'd37;
        default:qpw1 = 6'd0 ;
      endcase
end

always @* begin
      if(qpw>6'd29&&qpw<6'd44)begin
            qpc  = qpw1; 
      end   
      else if(qpw<6'd30)begin
          qpc  = qpw ;   
      end
      else begin
            qpc  = qpw2;
      end   
end                  

assign qp_lc_w  = is_luma_i ? qpw : qpc ;
assign edge_type_w = (mb_type_i == `INTRA || IinP_flag_i == 1) ? `INTRA : `INTER ;

db_lut_beta ubeta1(     
                  .qp_i(qpw),
                  .beta_o(beta_w)     
      );
              
db_lut_tc         utc1(       
                  .qp_i(qp_lc_w),
                  .mb_type_i(edge_type_w ),
                  .tc_o(tc_w)   
      );   

//bs_l1_r calcu
//intra   : tu_edge                             -->2
//inter tu: tu_edge &&    (cbf_p || cbf_q)  -->1
//      pu: pu_edge &  abs_l1_r(mv_p.x-mv_q.x)>3 -->1
//          pu_edge &  abs_l1_r(mv_p.y-mv_q.y)>3 -->1
//other   :                                 -->0
//inter chroma donot filter
wire  signed [9:0]  mv_p_x ,  mv_q_x ;
wire  signed [9:0]  mv_p_y ,  mv_q_y ;
                
wire  [9:0]         mv_m_x ,  mv_m_y ;
wire                mv_x_gt_3_w, mv_y_gt_3_w ;

assign mv_p_y     =  mv_p_i[ 9: 0] ;//? ~mv_p_i[9:0]  + 1'b1 : mv_p_i[9:0]  ;
assign mv_p_x     =  mv_p_i[19:10];//? ~mv_p_i[19:10]+ 1'b1 : mv_p_i[19:10];
assign mv_q_y     =  mv_q_i[ 9: 0] ;//? ~mv_q_i[9:0]  + 1'b1 : mv_q_i[9:0]  ;
assign mv_q_x     =  mv_q_i[19:10];//? ~mv_q_i[19:10]+ 1'b1 : mv_q_i[19:10];

assign mv_m_x     = mv_p_x > mv_q_x ? (mv_p_x - mv_q_x ):(mv_q_x - mv_p_x);
assign mv_m_y     = mv_p_y > mv_q_y ? (mv_p_y - mv_q_y ):(mv_q_y - mv_p_y);

assign mv_x_gt_3_w= mv_m_x > 10'd3 ? 1'b1 : 1'b0 ;     
assign mv_y_gt_3_w= mv_m_y > 10'd3 ? 1'b1 : 1'b0 ;     
                                                       
always @* begin 
    if ( sys_db_ena_i == 0 ) 
        bs_w = 0 ;
    else if(edge_type_w == `INTRA )
        bs_w  =   tu_edge_i     ;
    else  
        bs_w  =   is_luma_i&&((tu_edge_i&&(cbf_p_i||cbf_q_i) )|| (pu_edge_i&&(mv_x_gt_3_w||mv_y_gt_3_w)));
end   

/*
| 127:120 | 119:112 | 111:104 | 103:96 | 
|  95: 88 |  87: 80 |  79: 72 |  71:64 | 
|  63: 56 |  55: 48 |  47: 40 |  39:32 | 
|  31: 24 |  23: 16 |  15:  8 |   7: 0 | 

ver edge
| p0_3 | p0_2 | p0_1 | p0_0 | | q0_0 | q0_1 | q0_2 | q0_3 |
| p1_3 | p1_2 | p1_1 | p1_0 | | q1_0 | q1_1 | q1_2 | q1_3 |
| p2_3 | p2_2 | p2_1 | p2_0 | | q2_0 | q2_1 | q2_2 | q2_3 |
| p3_3 | p3_2 | p3_1 | p3_0 | | q3_0 | q3_1 | q3_2 | q3_3 |

hor edge
| p0_3 | p1_3 | p2_3 | p3_3 |
| p0_2 | p1_2 | p2_2 | p3_2 |
| p0_1 | p1_1 | p2_1 | p3_1 |
| p0_0 | p1_0 | p2_0 | p3_0 |

| q0_0 | q1_0 | q2_0 | q3_0 |
| q0_1 | q1_1 | q2_1 | q3_1 |
| q0_2 | q1_2 | q2_2 | q3_2 |
| q0_3 | q1_3 | q2_3 | q3_3 |
*/

reg  [7:0]      p0_0_i,p0_1_i,p0_2_i,p0_3_i   ,
                p1_0_i,p1_1_i,p1_2_i,p1_3_i   ,
                p2_0_i,p2_1_i,p2_2_i,p2_3_i   ,
                p3_0_i,p3_1_i,p3_2_i,p3_3_i   ;
                               
reg   [7:0]     q0_0_i,q0_1_i,q0_2_i,q0_3_i   ,                 
                q1_0_i,q1_1_i,q1_2_i,q1_3_i   ,
                q2_0_i,q2_1_i,q2_2_i,q2_3_i   ,
                q3_0_i,q3_1_i,q3_2_i,q3_3_i   ;

always @(*) begin
    if ( is_ver_i ) begin
        p3_0_i=p_i[7  :0 ];p3_1_i=p_i[15 : 8 ];p3_2_i=p_i[23 :16 ];p3_3_i=p_i[31 :24 ];   
        p2_0_i=p_i[39 :32];p2_1_i=p_i[47 : 40];p2_2_i=p_i[55 :48 ];p2_3_i=p_i[63 :56 ];   
        p1_0_i=p_i[71 :64];p1_1_i=p_i[79 : 72];p1_2_i=p_i[87 :80 ];p1_3_i=p_i[95 :88 ];   
        p0_0_i=p_i[103:96];p0_1_i=p_i[111:104];p0_2_i=p_i[119:112];p0_3_i=p_i[127:120];   
        q3_3_i=q_i[7  :0 ];q3_2_i=q_i[15 : 8 ];q3_1_i=q_i[23 :16 ];q3_0_i=q_i[31 :24 ];
        q2_3_i=q_i[39 :32];q2_2_i=q_i[47 : 40];q2_1_i=q_i[55 :48 ];q2_0_i=q_i[63 :56 ];
        q1_3_i=q_i[71 :64];q1_2_i=q_i[79 : 72];q1_1_i=q_i[87 :80 ];q1_0_i=q_i[95 :88 ];
        q0_3_i=q_i[103:96];q0_2_i=q_i[111:104];q0_1_i=q_i[119:112];q0_0_i=q_i[127:120];
        end
    else begin 
        p3_0_i=p_i[7  :0 ];p2_0_i=p_i[15 : 8 ];p1_0_i=p_i[23 :16 ];p0_0_i=p_i[31 :24 ]; 
        p3_1_i=p_i[39 :32];p2_1_i=p_i[47 : 40];p1_1_i=p_i[55 :48 ];p0_1_i=p_i[63 :56 ]; 
        p3_2_i=p_i[71 :64];p2_2_i=p_i[79 : 72];p1_2_i=p_i[87 :80 ];p0_2_i=p_i[95 :88 ]; 
        p3_3_i=p_i[103:96];p2_3_i=p_i[111:104];p1_3_i=p_i[119:112];p0_3_i=p_i[127:120]; 
        q3_3_i=q_i[7  :0 ];q2_3_i=q_i[15 : 8 ];q1_3_i=q_i[23 :16 ];q0_3_i=q_i[31 :24 ];
        q3_2_i=q_i[39 :32];q2_2_i=q_i[47 : 40];q1_2_i=q_i[55 :48 ];q0_2_i=q_i[63 :56 ];
        q3_1_i=q_i[71 :64];q2_1_i=q_i[79 : 72];q1_1_i=q_i[87 :80 ];q0_1_i=q_i[95 :88 ];
        q3_0_i=q_i[103:96];q2_0_i=q_i[111:104];q1_0_i=q_i[119:112];q0_0_i=q_i[127:120];
        end
end 
//---------------------------------------------------------------------------
//
//                      stage1_a:calcu middle variabls 
//
//----------------------------------------------------------------------------            
wire signed [8:0]  p0_0_s_w  , p0_1_s_w  ,p0_2_s_w  ;
wire signed [8:0]  p3_0_s_w  , p3_1_s_w  ,p3_2_s_w  ;

wire signed [8:0]  q0_0_s_w  , q0_1_s_w  ,q0_2_s_w  ;
wire signed [8:0]  q3_0_s_w  , q3_1_s_w  ,q3_2_s_w  ;

wire signed [9:0]  dp0_w         ,  dp3_w        ;
wire signed [9:0]  dq0_w         ,  dq3_w        ;
wire        [9:0]  dpw           ,  dqw          ;
wire        [9:0]  dqp0_w        ,  dqp3_w       ;
wire        [10:0] dqp0_m_2_w    ,  dqp3_m_2_w   ;             
wire        [10:0] d_w               ;
wire        [6:0]  tc_mux_3_2_w  ;

wire        [6:0] beta_m_w    ;

wire        [9:0] dp0_abs_l1_r_w,dp3_abs_l1_r_w  ;
wire        [9:0] dq0_abs_l1_r_w,dq3_abs_l1_r_w  ;
            
wire        [7:0] dp0_3_0       ,dq0_3_0,dpq0_0_0;
wire        [7:0] dp3_3_0       ,dq3_3_0,dpq3_0_0;

wire                      dsam0           , dsam3                  ;

assign  p0_0_s_w  =  {1'b0,p0_0_i} ;
assign  p0_1_s_w  =  {1'b0,p0_1_i} ;
assign  p0_2_s_w  =  {1'b0,p0_2_i} ;
assign  p3_0_s_w  =  {1'b0,p3_0_i} ;
assign  p3_1_s_w  =  {1'b0,p3_1_i} ;
assign  p3_2_s_w  =  {1'b0,p3_2_i} ;
assign  q0_0_s_w  =  {1'b0,q0_0_i} ;
assign  q0_1_s_w  =  {1'b0,q0_1_i} ;
assign  q0_2_s_w  =  {1'b0,q0_2_i} ;
assign  q3_0_s_w  =  {1'b0,q3_0_i} ;
assign  q3_1_s_w  =  {1'b0,q3_1_i} ;
assign  q3_2_s_w  =  {1'b0,q3_2_i} ;

assign beta_m_w   =  (beta_w + (beta_w>>1)) >>3 ;

assign dp0_w =  p0_2_s_w + p0_0_s_w - p0_1_s_w - p0_1_s_w ;
assign dp3_w =  p3_2_s_w + p3_0_s_w - p3_1_s_w - p3_1_s_w ;
assign dq0_w =  q0_2_s_w + q0_0_s_w - q0_1_s_w - q0_1_s_w ;
assign dq3_w =  q3_2_s_w + q3_0_s_w - q3_1_s_w - q3_1_s_w ;

assign dp0_abs_l1_r_w = dp0_w[9] ? (~dp0_w + 1'b1) : dp0_w; 
assign dp3_abs_l1_r_w = dp3_w[9] ? (~dp3_w + 1'b1) : dp3_w; 
assign dq0_abs_l1_r_w = dq0_w[9] ? (~dq0_w + 1'b1) : dq0_w; 
assign dq3_abs_l1_r_w = dq3_w[9] ? (~dq3_w + 1'b1) : dq3_w; 

assign dpw        =  dp0_abs_l1_r_w  +  dp3_abs_l1_r_w ;
assign dqw        =  dq0_abs_l1_r_w  +  dq3_abs_l1_r_w ;

assign dqp0_w     =  dp0_abs_l1_r_w  +  dq0_abs_l1_r_w;
assign dqp3_w     =  dp3_abs_l1_r_w  +  dq3_abs_l1_r_w;

assign d_w      =  dpw       +  dqw     ;

assign dp0_3_0  =  p0_0_i >  p0_3_i ? (p0_0_i - p0_3_i) : (p0_3_i - p0_0_i);
assign dq0_3_0  =  q0_0_i >  q0_3_i ? (q0_0_i - q0_3_i) : (q0_3_i - q0_0_i);
                                   
assign dp3_3_0  =  p3_0_i >  p3_3_i ? (p3_0_i - p3_3_i) : (p3_3_i - p3_0_i);
assign dq3_3_0  =  q3_0_i >  q3_3_i ? (q3_0_i - q3_3_i) : (q3_3_i - q3_0_i);
                                     
assign dpq0_0_0 = p0_0_i  > q0_0_i  ? (p0_0_i - q0_0_i) : (q0_0_i - p0_0_i);
assign dpq3_0_0 = p3_0_i  > q3_0_i  ? (p3_0_i - q3_0_i) : (q3_0_i - p3_0_i);

assign tc_mux_3_2_w    =  ({tc_w,2'b0}+tc_w+1)>>1         ;

assign dqp0_m_2_w = {dqp0_w,1'b0} ;
assign dqp3_m_2_w = {dqp3_w,1'b0} ;

assign dsam0 = ((dqp0_m_2_w< beta_w[6:2])&&((dp0_3_0 + dq0_3_0)< beta_w[6:3])&&( dpq0_0_0< tc_mux_3_2_w )) ? 1'b1 : 1'b0 ;
assign dsam3 = ((dqp3_m_2_w< beta_w[6:2])&&((dp3_3_0 + dq3_3_0)< beta_w[6:3])&&( dpq3_0_0< tc_mux_3_2_w )) ? 1'b1 : 1'b0 ;

//---------------------------------------------------------------------------
//
//                      stage1_b:calc conditions and filter dicisons 
//
//----------------------------------------------------------------------------
wire d_less_beta_w  ;           //0:no filter           ,     1:filter
wire norm_str_w     ;           //0:normal filter ,     1:strong filter
wire filter_cout_pw ;           //0:1 pixel filtered,   1:2 pixels filtered
wire filter_cout_qw ;

assign  d_less_beta_w =  (d_w  < beta_w  ) ? 1'b1  : 1'b0   ; 

assign filter_cout_pw =  (dpw < beta_m_w ) ?  1'b1 : 1'b0   ;
assign filter_cout_qw =  (dqw < beta_m_w ) ?  1'b1 : 1'b0   ;

assign norm_str_w     =  (dsam0&&dsam3   ) ?  1'b1 : 1'b0   ;

wire [7:0] p0_0_nml_w, p0_1_nml_w;
wire [7:0] p1_0_nml_w, p1_1_nml_w;
wire [7:0] p2_0_nml_w, p2_1_nml_w;
wire [7:0] p3_0_nml_w, p3_1_nml_w;
wire [7:0] q0_0_nml_w, q0_1_nml_w;
wire [7:0] q1_0_nml_w, q1_1_nml_w;
wire [7:0] q2_0_nml_w, q2_1_nml_w;
wire [7:0] q3_0_nml_w, q3_1_nml_w;

wire [3:0] not_nature_edge_w;

wire [7:0] p0_0_str_w, p0_1_str_w, p0_2_str_w;
wire [7:0] p1_0_str_w, p1_1_str_w, p1_2_str_w;
wire [7:0] p2_0_str_w, p2_1_str_w, p2_2_str_w;
wire [7:0] p3_0_str_w, p3_1_str_w, p3_2_str_w;
wire [7:0] q0_0_str_w, q0_1_str_w, q0_2_str_w;
wire [7:0] q1_0_str_w, q1_1_str_w, q1_2_str_w;
wire [7:0] q2_0_str_w, q2_1_str_w, q2_2_str_w;
wire [7:0] q3_0_str_w, q3_1_str_w, q3_2_str_w;

wire [7:0] p0_0_c_w, q0_0_c_w;
wire [7:0] p1_0_c_w, q1_0_c_w;
wire [7:0] p2_0_c_w, q2_0_c_w;
wire [7:0] p3_0_c_w, q3_0_c_w;

db_normal_filter u_normal_filter(
                .tc_i    (tc_w   ),
                .p0_0_i  (p0_0_i ),.p0_1_i(p0_1_i),.p0_2_i(p0_2_i), 
                .p1_0_i  (p1_0_i ),.p1_1_i(p1_1_i),.p1_2_i(p1_2_i), 
                .p2_0_i  (p2_0_i ),.p2_1_i(p2_1_i),.p2_2_i(p2_2_i), 
                .p3_0_i  (p3_0_i ),.p3_1_i(p3_1_i),.p3_2_i(p3_2_i), 
                .q0_0_i  (q0_0_i ),.q0_1_i(q0_1_i),.q0_2_i(q0_2_i), 
                .q1_0_i  (q1_0_i ),.q1_1_i(q1_1_i),.q1_2_i(q1_2_i), 
                .q2_0_i  (q2_0_i ),.q2_1_i(q2_1_i),.q2_2_i(q2_2_i), 
                .q3_0_i  (q3_0_i ),.q3_1_i(q3_1_i),.q3_2_i(q3_2_i), 
 
                .p0_0_o  (p0_0_nml_w),
                .p1_0_o  (p1_0_nml_w),
                .p2_0_o  (p2_0_nml_w),
                .p3_0_o  (p3_0_nml_w),
                .q0_0_o  (q0_0_nml_w),
                .q1_0_o  (q1_0_nml_w),
                .q2_0_o  (q2_0_nml_w),
                .q3_0_o  (q3_0_nml_w),
                .p0_1_o  (p0_1_nml_w),
                .p1_1_o  (p1_1_nml_w),
                .p2_1_o  (p2_1_nml_w),
                .p3_1_o  (p3_1_nml_w),
                .q0_1_o  (q0_1_nml_w),
                .q1_1_o  (q1_1_nml_w),
                .q2_1_o  (q2_1_nml_w),
                .q3_1_o  (q3_1_nml_w),                    
                .not_nature_edge_o (not_nature_edge_w)  
    );

db_strong_filter u_strong_filter(
                .tc_i(tc_w),
                .p0_0_i(p0_0_i)  , .p0_1_i(p0_1_i)  , .p0_2_i(p0_2_i)  , .p0_3_i(p0_3_i),
                .p1_0_i(p1_0_i)  , .p1_1_i(p1_1_i)  , .p1_2_i(p1_2_i)  , .p1_3_i(p1_3_i),
                .p2_0_i(p2_0_i)  , .p2_1_i(p2_1_i)  , .p2_2_i(p2_2_i)  , .p2_3_i(p2_3_i),
                .p3_0_i(p3_0_i)  , .p3_1_i(p3_1_i)  , .p3_2_i(p3_2_i)  , .p3_3_i(p3_3_i),
                                                                                   
                .q0_0_i(q0_0_i)  , .q0_1_i(q0_1_i)  , .q0_2_i(q0_2_i)  , .q0_3_i(q0_3_i),
                .q1_0_i(q1_0_i)  , .q1_1_i(q1_1_i)  , .q1_2_i(q1_2_i)  , .q1_3_i(q1_3_i),
                .q2_0_i(q2_0_i)  , .q2_1_i(q2_1_i)  , .q2_2_i(q2_2_i)  , .q2_3_i(q2_3_i),
                .q3_0_i(q3_0_i)  , .q3_1_i(q3_1_i)  , .q3_2_i(q3_2_i)  , .q3_3_i(q3_3_i),
                                                                             
                .p0_0_o(p0_0_str_w)  , .p0_1_o(p0_1_str_w)  , .p0_2_o(p0_2_str_w) ,
                .p1_0_o(p1_0_str_w)  , .p1_1_o(p1_1_str_w)  , .p1_2_o(p1_2_str_w) ,
                .p2_0_o(p2_0_str_w)  , .p2_1_o(p2_1_str_w)  , .p2_2_o(p2_2_str_w) ,
                .p3_0_o(p3_0_str_w)  , .p3_1_o(p3_1_str_w)  , .p3_2_o(p3_2_str_w) ,

                .q0_0_o(q0_0_str_w)  , .q0_1_o(q0_1_str_w)  , .q0_2_o(q0_2_str_w) ,
                .q1_0_o(q1_0_str_w)  , .q1_1_o(q1_1_str_w)  , .q1_2_o(q1_2_str_w) ,
                .q2_0_o(q2_0_str_w)  , .q2_1_o(q2_1_str_w)  , .q2_2_o(q2_2_str_w) ,
                .q3_0_o(q3_0_str_w)  , .q3_1_o(q3_1_str_w)  , .q3_2_o(q3_2_str_w) 
                );   


db_chroma_filter u_chroma_filter(
                .tc_i    (tc_w      ),
                .p0_0_i  (p0_0_i    ),.p0_1_i(p0_1_i),
                .p1_0_i  (p1_0_i    ),.p1_1_i(p1_1_i),
                .p2_0_i  (p2_0_i    ),.p2_1_i(p2_1_i),
                .p3_0_i  (p3_0_i    ),.p3_1_i(p3_1_i),
                .q0_0_i  (q0_0_i    ),.q0_1_i(q0_1_i),
                .q1_0_i  (q1_0_i    ),.q1_1_i(q1_1_i),
                .q2_0_i  (q2_0_i    ),.q2_1_i(q2_1_i),
                .q3_0_i  (q3_0_i    ),.q3_1_i(q3_1_i),
                .p0_0_o  (p0_0_c_w  ),
                .p1_0_o  (p1_0_c_w  ),
                .p2_0_o  (p2_0_c_w  ),
                .p3_0_o  (p3_0_c_w  ),
                .q0_0_o  (q0_0_c_w  ),
                .q1_0_o  (q1_0_c_w  ),
                .q2_0_o  (q2_0_c_w  ),
                .q3_0_o  (q3_0_c_w  ) 
    );

reg [7:0]       p0_0_o, p0_1_o, p0_2_o, p0_3_o;
reg [7:0]       p1_0_o, p1_1_o, p1_2_o, p1_3_o;
reg [7:0]       p2_0_o, p2_1_o, p2_2_o, p2_3_o;
reg [7:0]       p3_0_o, p3_1_o, p3_2_o, p3_3_o;

reg [7:0]       q0_0_o, q0_1_o, q0_2_o, q0_3_o;
reg [7:0]       q1_0_o, q1_1_o, q1_2_o, q1_3_o;
reg [7:0]       q2_0_o, q2_1_o, q2_2_o, q2_3_o;
reg [7:0]       q3_0_o, q3_1_o, q3_2_o, q3_3_o;

wire flt_chroma_flag = (!is_luma_i) && (bs_w!=0) && (edge_type_w == `INTRA ) ;
wire no_filter_flag_0= !((bs_w!=0) &&d_less_beta_w&&not_nature_edge_w[0]);
wire no_filter_flag_1= !((bs_w!=0) &&d_less_beta_w&&not_nature_edge_w[1]);
wire no_filter_flag_2= !((bs_w!=0) &&d_less_beta_w&&not_nature_edge_w[2]);
wire no_filter_flag_3= !((bs_w!=0) &&d_less_beta_w&&not_nature_edge_w[3]);

always @* begin 
    if(flt_chroma_flag) begin // chroma filter
        p0_0_o = p0_0_c_w; p0_1_o = p0_1_i; p0_2_o = p0_2_i; p0_3_o = p0_3_i;
        q0_0_o = q0_0_c_w; q0_1_o = q0_1_i; q0_2_o = q0_2_i; q0_3_o = q0_3_i;
    end else if( no_filter_flag_0 )  begin   // no filter  
        p0_0_o = p0_0_i; p0_1_o = p0_1_i; p0_2_o = p0_2_i; p0_3_o = p0_3_i;  
        q0_0_o = q0_0_i; q0_1_o = q0_1_i; q0_2_o = q0_2_i; q0_3_o = q0_3_i;
    end else begin 
        if(norm_str_w)  begin 
            p0_0_o = p0_0_str_w; p0_1_o = p0_1_str_w; p0_2_o = p0_2_str_w; p0_3_o = p0_3_i;
            q0_0_o = q0_0_str_w; q0_1_o = q0_1_str_w; q0_2_o = q0_2_str_w; q0_3_o = q0_3_i;
        end else begin 
            case ({filter_cout_pw, filter_cout_qw})
                2'b11 : begin 
                    p0_0_o = p0_0_nml_w; p0_1_o = p0_1_nml_w; p0_2_o = p0_2_i; p0_3_o = p0_3_i;
                    q0_0_o = q0_0_nml_w; q0_1_o = q0_1_nml_w; q0_2_o = q0_2_i; q0_3_o = q0_3_i;
                end 
                2'b01 : begin 
                    p0_0_o = p0_0_nml_w; p0_1_o = p0_1_i    ; p0_2_o = p0_2_i; p0_3_o = p0_3_i;
                    q0_0_o = q0_0_nml_w; q0_1_o = q0_1_nml_w; q0_2_o = q0_2_i; q0_3_o = q0_3_i;
                end 
                2'b10 : begin 
                    p0_0_o = p0_0_nml_w; p0_1_o = p0_1_nml_w; p0_2_o = p0_2_i; p0_3_o = p0_3_i;
                    q0_0_o = q0_0_nml_w; q0_1_o = q0_1_i    ; q0_2_o = q0_2_i; q0_3_o = q0_3_i;
                end 
                2'b00 : begin 
                    p0_0_o = p0_0_nml_w; p0_1_o = p0_1_i    ; p0_2_o = p0_2_i; p0_3_o = p0_3_i;
                    q0_0_o = q0_0_nml_w; q0_1_o = q0_1_i    ; q0_2_o = q0_2_i; q0_3_o = q0_3_i;
                end 
            default : ;
            endcase 
        end 
    end 
end 

always @(*) begin
    if(flt_chroma_flag) begin // chroma filter
        p1_0_o = p1_0_c_w; p1_1_o = p1_1_i; p1_2_o = p1_2_i; p1_3_o = p1_3_i;
        q1_0_o = q1_0_c_w; q1_1_o = q1_1_i; q1_2_o = q1_2_i; q1_3_o = q1_3_i;
    end
    else if(no_filter_flag_1)  begin   // no filter    
        p1_0_o = p1_0_i; p1_1_o = p1_1_i; p1_2_o = p1_2_i; p1_3_o = p1_3_i;
        q1_0_o = q1_0_i; q1_1_o = q1_1_i; q1_2_o = q1_2_i; q1_3_o = q1_3_i;
    end
    else begin 
        if(norm_str_w)  begin            //strong filter
            p1_0_o = p1_0_str_w; p1_1_o = p1_1_str_w; p1_2_o = p1_2_str_w; p1_3_o = p1_3_i;
            q1_0_o = q1_0_str_w; q1_1_o = q1_1_str_w; q1_2_o = q1_2_str_w; q1_3_o = q1_3_i;
        end
        else begin                          //normal filter
            case ({filter_cout_pw, filter_cout_qw})
                2'b11 : begin 
                    p1_0_o = p1_0_nml_w; p1_1_o = p1_1_nml_w; p1_2_o = p1_2_i; p1_3_o = p1_3_i;
                    q1_0_o = q1_0_nml_w; q1_1_o = q1_1_nml_w; q1_2_o = q1_2_i; q1_3_o = q1_3_i;
                end 
                2'b01 : begin 
                    p1_0_o = p1_0_nml_w; p1_1_o = p1_1_i    ; p1_2_o = p1_2_i; p1_3_o = p1_3_i;
                    q1_0_o = q1_0_nml_w; q1_1_o = q1_1_nml_w; q1_2_o = q1_2_i; q1_3_o = q1_3_i;
                end 
                2'b10 : begin 
                    p1_0_o = p1_0_nml_w; p1_1_o = p1_1_nml_w; p1_2_o = p1_2_i; p1_3_o = p1_3_i;
                    q1_0_o = q1_0_nml_w; q1_1_o = q1_1_i    ; q1_2_o = q1_2_i; q1_3_o = q1_3_i;
                end 
                2'b00 : begin 
                    p1_0_o = p1_0_nml_w; p1_1_o = p1_1_i    ; p1_2_o = p1_2_i; p1_3_o = p1_3_i;
                    q1_0_o = q1_0_nml_w; q1_1_o = q1_1_i    ; q1_2_o = q1_2_i; q1_3_o = q1_3_i; 
                end 
            endcase
        end
    end
end

always @(*) begin
    if(flt_chroma_flag) begin // chroma filter
        p2_0_o = p2_0_c_w; p2_1_o = p2_1_i; p2_2_o = p2_2_i; p2_3_o = p2_3_i;
        q2_0_o = q2_0_c_w; q2_1_o = q2_1_i; q2_2_o = q2_2_i; q2_3_o = q2_3_i;
    end
    else if(no_filter_flag_2)  begin   // no filter    
        p2_0_o = p2_0_i; p2_1_o = p2_1_i; p2_2_o = p2_2_i; p2_3_o = p2_3_i;
        q2_0_o = q2_0_i; q2_1_o = q2_1_i; q2_2_o = q2_2_i; q2_3_o = q2_3_i;
    end
    else begin 
        if(norm_str_w)  begin            //strong filter
            p2_0_o = p2_0_str_w; p2_1_o = p2_1_str_w; p2_2_o = p2_2_str_w; p2_3_o = p2_3_i;
            q2_0_o = q2_0_str_w; q2_1_o = q2_1_str_w; q2_2_o = q2_2_str_w; q2_3_o = q2_3_i;
        end
        else begin                          //normal filter
            case ({filter_cout_pw, filter_cout_qw})
                2'b11 : begin 
                    p2_0_o = p2_0_nml_w; p2_1_o = p2_1_nml_w; p2_2_o = p2_2_i; p2_3_o = p2_3_i;
                    q2_0_o = q2_0_nml_w; q2_1_o = q2_1_nml_w; q2_2_o = q2_2_i; q2_3_o = q2_3_i;
                end 
                2'b01 : begin 
                    p2_0_o = p2_0_nml_w; p2_1_o = p2_1_i    ; p2_2_o = p2_2_i; p2_3_o = p2_3_i;
                    q2_0_o = q2_0_nml_w; q2_1_o = q2_1_nml_w; q2_2_o = q2_2_i; q2_3_o = q2_3_i;
                end 
                2'b10 : begin 
                    p2_0_o = p2_0_nml_w; p2_1_o = p2_1_nml_w; p2_2_o = p2_2_i; p2_3_o = p2_3_i;
                    q2_0_o = q2_0_nml_w; q2_1_o = q2_1_i    ; q2_2_o = q2_2_i; q2_3_o = q2_3_i; 
                end 
                2'b00 : begin 
                    p2_0_o = p2_0_nml_w; p2_1_o = p2_1_i    ; p2_2_o = p2_2_i; p2_3_o = p2_3_i;
                    q2_0_o = q2_0_nml_w; q2_1_o = q2_1_i    ; q2_2_o = q2_2_i; q2_3_o = q2_3_i;
                end 
            endcase
        end
    end
end

always @(*) begin
    if(flt_chroma_flag) begin // chroma filter
        p3_0_o = p3_0_c_w; p3_1_o = p3_1_i; p3_2_o = p3_2_i; p3_3_o = p3_3_i;
        q3_0_o = q3_0_c_w; q3_1_o = q3_1_i; q3_2_o = q3_2_i; q3_3_o = q3_3_i;
    end
    else if(no_filter_flag_3 )  begin   // no filter  
        p3_0_o = p3_0_i; p3_1_o = p3_1_i; p3_2_o = p3_2_i; p3_3_o = p3_3_i;
        q3_0_o = q3_0_i; q3_1_o = q3_1_i; q3_2_o = q3_2_i; q3_3_o = q3_3_i;
    end
    else begin 
        if(norm_str_w)  begin            //strong filter
            p3_0_o = p3_0_str_w; p3_1_o = p3_1_str_w; p3_2_o = p3_2_str_w; p3_3_o = p3_3_i;
            q3_0_o = q3_0_str_w; q3_1_o = q3_1_str_w; q3_2_o = q3_2_str_w; q3_3_o = q3_3_i; 
        end
        else begin                          //normal filter
            case ({filter_cout_pw, filter_cout_qw})
                2'b11 : begin 
                    p3_0_o = p3_0_nml_w; p3_1_o = p3_1_nml_w; p3_2_o = p3_2_i; p3_3_o = p3_3_i;
                    q3_0_o = q3_0_nml_w; q3_1_o = q3_1_nml_w; q3_2_o = q3_2_i; q3_3_o = q3_3_i; 
                end 
                2'b01 : begin 
                    p3_0_o = p3_0_nml_w; p3_1_o = p3_1_i    ; p3_2_o = p3_2_i; p3_3_o = p3_3_i;
                    q3_0_o = q3_0_nml_w; q3_1_o = q3_1_nml_w; q3_2_o = q3_2_i; q3_3_o = q3_3_i; 
                end 
                2'b10 : begin 
                    p3_0_o = p3_0_nml_w; p3_1_o = p3_1_nml_w; p3_2_o = p3_2_i; p3_3_o = p3_3_i;
                    q3_0_o = q3_0_nml_w; q3_1_o = q3_1_i    ; q3_2_o = q3_2_i; q3_3_o = q3_3_i; 
                end 
                2'b00 : begin 
                    p3_0_o = p3_0_nml_w; p3_1_o = p3_1_i    ; p3_2_o = p3_2_i; p3_3_o = p3_3_i;
                    q3_0_o = q3_0_nml_w; q3_1_o = q3_1_i    ; q3_2_o = q3_2_i; q3_3_o = q3_3_i; 
                end 
            endcase
        end
    end
end

assign p_o = is_ver_i ? {p0_3_o, p0_2_o, p0_1_o, p0_0_o,
                         p1_3_o, p1_2_o, p1_1_o, p1_0_o,
                         p2_3_o, p2_2_o, p2_1_o, p2_0_o,
                         p3_3_o, p3_2_o, p3_1_o, p3_0_o}
                      : {p0_3_o, p1_3_o, p2_3_o, p3_3_o,
                         p0_2_o, p1_2_o, p2_2_o, p3_2_o,
                         p0_1_o, p1_1_o, p2_1_o, p3_1_o,
                         p0_0_o, p1_0_o, p2_0_o, p3_0_o}  ;  


assign q_o = is_ver_i ? {q0_0_o, q0_1_o, q0_2_o, q0_3_o,
                         q1_0_o, q1_1_o, q1_2_o, q1_3_o,
                         q2_0_o, q2_1_o, q2_2_o, q2_3_o,
                         q3_0_o, q3_1_o, q3_2_o, q3_3_o}
                      : {q0_0_o, q1_0_o, q2_0_o, q3_0_o,
                         q0_1_o, q1_1_o, q2_1_o, q3_1_o,
                         q0_2_o, q1_2_o, q2_2_o, q3_2_o,
                         q0_3_o, q1_3_o, q2_3_o, q3_3_o}  ;   

endmodule 