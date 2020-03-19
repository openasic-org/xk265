//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2014, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//
//-------------------------------------------------------------------
//
//  Filename      : fetch_ref_chroma.v
//  Author        : Yufeng Bai
//  Email 	  : byfchina@gmail.com
//
//-------------------------------------------------------------------
//
//  Modified      : 2015-09-02 by HLL
//  Description   : rotate by sys_start_i
//  Modified      : 2015-09-17 by HLL
//  Description   : ref_chroma provided in the order of uvuvuv...
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fetch_ref_chroma (
  clk                 ,
  rstn                ,
  sysif_start_i       ,

  sys_all_x_i         ,
  sys_all_y_i         ,
  sys_ctu_all_x_i     ,
  sys_ctu_all_y_i     ,

  extif_width_i       ,
  extif_mode_i        ,

  rec_cur_x_i         ,
  rec_cur_y_i         ,

  rec_ref_x_i         ,
  rec_ref_y_i         , 
  rec_ref_rden_i      ,
  rec_ref_sel_i       ,
  rec_ref_pel_o       ,

  ext_load_done_i     ,
  ext_load_data_i     ,
  ext_load_addr_i     ,
  ext_load_valid_i
);

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input       [1-1:0]                clk                 ; // clk signal 
input       [1-1:0]                rstn                ; // asynchronous reset 
input                              sysif_start_i       ;
    
input       [`PIC_WIDTH  -1   : 0] sys_all_x_i         ;
input       [`PIC_HEIGHT -1   : 0] sys_all_y_i         ;
input       [`PIC_X_WIDTH-1   : 0] sys_ctu_all_x_i     ;
input       [`PIC_Y_WIDTH-1   : 0] sys_ctu_all_y_i     ;

input       [8-1              : 0] extif_width_i       ;
input       [5-1              : 0] extif_mode_i        ;

input       [`PIC_X_WIDTH-1   : 0] rec_cur_x_i         ;
input       [`PIC_Y_WIDTH-1   : 0] rec_cur_y_i         ;

input       [8-1:0]                rec_ref_x_i         ; // rec ref x
input       [8-1:0]                rec_ref_y_i         ; // rec ref y
input       [1-1:0]                rec_ref_rden_i      ; // rec ref read enable
input       [2-1:0]                rec_ref_sel_i       ; // "rec ref read sel: cb
output reg  [8*`PIXEL_WIDTH-1:0]   rec_ref_pel_o       ; // rec ref pixel

input       [1-1:0]                ext_load_done_i     ; // load current lcu done
input       [128*`PIXEL_WIDTH-1:0] ext_load_data_i     ; // load current lcu data
input       [6-1:0]                ext_load_addr_i     ;
input       [1-1:0]                ext_load_valid_i    ; // load current lcu data valid

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

reg         [2-1:0]                rotate_rec         ;
      
wire        [96*`PIXEL_WIDTH-1:0]  rec_ref_pel_w      ;
      
reg         [8-1:0]                rec_ref_x          ; // rec ref x
reg         [8-1:0]                rec_ref_y          ; // rec ref y 
reg         [2-1:0]                rec_ref_sel        ;
  
wire                               rec_ref_rden_u     ;
wire                               rec_ref_rden_v     ; 

wire        [8-1:0]                rec_x_minus_width  ;
wire        [96 *`PIXEL_WIDTH-1:0] rec_ref_pel_lshift ;
reg         [96 *`PIXEL_WIDTH-1:0] rec_ref_pel_rshift ;
wire        [96 *`PIXEL_WIDTH-1:0] rec_ref_pel_w0     ;
wire        [96 *`PIXEL_WIDTH-1:0] rec_ref_pel_w1     ;
wire        [8  *`PIXEL_WIDTH-1:0] rec_ref_pel_w2     ;

reg         [1-1:0]                ref_u_rec00_wen    ;   
reg         [6-1:0]                ref_u_rec00_waddr  ;
reg         [32 *`PIXEL_WIDTH-1:0] ref_u_rec00_wdata  ;
reg         [1-1:0]                ref_u_rec00_rden   ;
reg         [6-1:0]                ref_u_rec00_raddr  ;
wire        [32 *`PIXEL_WIDTH-1:0] ref_u_rec00_rdata  ;
 
reg         [1-1:0]                ref_u_rec01_wen    ;   
reg         [6-1:0]                ref_u_rec01_waddr  ;
reg         [32 *`PIXEL_WIDTH-1:0] ref_u_rec01_wdata  ;
reg         [1-1:0]                ref_u_rec01_rden   ;
reg         [6-1:0]                ref_u_rec01_raddr  ;
wire        [32 *`PIXEL_WIDTH-1:0] ref_u_rec01_rdata  ;
 
reg         [1-1:0]                ref_u_rec02_wen    ;   
reg         [6-1:0]                ref_u_rec02_waddr  ;
reg         [32 *`PIXEL_WIDTH-1:0] ref_u_rec02_wdata  ;
reg         [1-1:0]                ref_u_rec02_rden   ;
reg         [6-1:0]                ref_u_rec02_raddr  ;
wire        [32 *`PIXEL_WIDTH-1:0] ref_u_rec02_rdata  ;
 
reg         [1-1:0]                ref_u_rec03_wen    ;   
reg         [6-1:0]                ref_u_rec03_waddr  ;
reg         [32 *`PIXEL_WIDTH-1:0] ref_u_rec03_wdata  ;
reg         [1-1:0]                ref_u_rec03_rden   ;
reg         [6-1:0]                ref_u_rec03_raddr  ;
wire        [32 *`PIXEL_WIDTH-1:0] ref_u_rec03_rdata  ;
 
reg         [1-1:0]                ref_v_rec00_wen    ;   
reg         [6-1:0]                ref_v_rec00_waddr  ;
reg         [32 *`PIXEL_WIDTH-1:0] ref_v_rec00_wdata  ;
reg         [1-1:0]                ref_v_rec00_rden   ;
reg         [6-1:0]                ref_v_rec00_raddr  ;
wire        [32 *`PIXEL_WIDTH-1:0] ref_v_rec00_rdata  ;
 
reg         [1-1:0]                ref_v_rec01_wen    ;   
reg         [6-1:0]                ref_v_rec01_waddr  ;
reg         [32 *`PIXEL_WIDTH-1:0] ref_v_rec01_wdata  ;
reg         [1-1:0]                ref_v_rec01_rden   ;
reg         [6-1:0]                ref_v_rec01_raddr  ;
wire        [32 *`PIXEL_WIDTH-1:0] ref_v_rec01_rdata  ;
 
reg         [1-1:0]                ref_v_rec02_wen    ;   
reg         [6-1:0]                ref_v_rec02_waddr  ;
reg         [32 *`PIXEL_WIDTH-1:0] ref_v_rec02_wdata  ;
reg         [1-1:0]                ref_v_rec02_rden   ;
reg         [6-1:0]                ref_v_rec02_raddr  ;
wire        [32 *`PIXEL_WIDTH-1:0] ref_v_rec02_rdata  ;
 
reg         [1-1:0]                ref_v_rec03_wen    ;   
reg         [6-1:0]                ref_v_rec03_waddr  ;
reg         [32 *`PIXEL_WIDTH-1:0] ref_v_rec03_wdata  ;
reg         [1-1:0]                ref_v_rec03_rden   ;
reg         [6-1:0]                ref_v_rec03_raddr  ;
wire        [32 *`PIXEL_WIDTH-1:0] ref_v_rec03_rdata  ;

reg         [96 *`PIXEL_WIDTH-1:0] rec_ref_u_pel_w    ;
reg         [96 *`PIXEL_WIDTH-1:0] rec_ref_v_pel_w    ;

// ********************************************
//
//    Output Logic
//
// ********************************************

always @ ( posedge clk or negedge rstn ) begin 
  if ( !rstn )
    rec_ref_pel_o <= 0;
  else 
    rec_ref_pel_o <= rec_ref_pel_w2 ;
end 

// ********************************************
//
//   Addressing Logic
//
// ********************************************
  always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
      rec_ref_x   <= 'd0 ;
      rec_ref_sel <= 'd0 ;
    end
    else begin
      rec_ref_x   <= rec_ref_x_i   ;
      rec_ref_sel <= rec_ref_sel_i ;
    end
  end

  always @ (posedge clk or negedge rstn) begin
    if( !rstn )
      rotate_rec <= 0 ;
    else if( sysif_start_i ) begin
      if( rotate_rec == 3 )
        rotate_rec <= 0 ;
      else
        rotate_rec <= rotate_rec + 1 ;
    end
  end

  assign rec_x_minus_width  = (rec_cur_x_i + 2)*64 - sys_all_x_i ;

  assign rec_ref_pel_w = rec_ref_sel == `TYPE_V ? rec_ref_v_pel_w : rec_ref_u_pel_w ;

  assign rec_ref_pel_lshift = {{32{rec_ref_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*63]}},rec_ref_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*0]} ;

  always @(*) begin
    case (rec_x_minus_width[6:3]) 
        0      : rec_ref_pel_rshift =  rec_ref_pel_w ;
        1      : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*4 ],{4 {rec_ref_pel_w[`PIXEL_WIDTH*5 -1:`PIXEL_WIDTH*4 ]}}} ;
        2      : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*8 ],{8 {rec_ref_pel_w[`PIXEL_WIDTH*9 -1:`PIXEL_WIDTH*8 ]}}} ;
        3      : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*12],{12{rec_ref_pel_w[`PIXEL_WIDTH*13-1:`PIXEL_WIDTH*12]}}} ;
        4      : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*16],{16{rec_ref_pel_w[`PIXEL_WIDTH*17-1:`PIXEL_WIDTH*16]}}} ;
        5      : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*20],{20{rec_ref_pel_w[`PIXEL_WIDTH*21-1:`PIXEL_WIDTH*20]}}} ;
        6      : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*24],{24{rec_ref_pel_w[`PIXEL_WIDTH*25-1:`PIXEL_WIDTH*24]}}} ;
        7      : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*28],{28{rec_ref_pel_w[`PIXEL_WIDTH*29-1:`PIXEL_WIDTH*28]}}} ;
        8      : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*32],{32{rec_ref_pel_w[`PIXEL_WIDTH*33-1:`PIXEL_WIDTH*32]}}} ;
        9      : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*36],{36{rec_ref_pel_w[`PIXEL_WIDTH*37-1:`PIXEL_WIDTH*36]}}} ;
        10     : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*40],{40{rec_ref_pel_w[`PIXEL_WIDTH*41-1:`PIXEL_WIDTH*40]}}} ;
        11     : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*44],{44{rec_ref_pel_w[`PIXEL_WIDTH*45-1:`PIXEL_WIDTH*44]}}} ;
        12     : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*48],{48{rec_ref_pel_w[`PIXEL_WIDTH*49-1:`PIXEL_WIDTH*48]}}} ;
        13     : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*52],{52{rec_ref_pel_w[`PIXEL_WIDTH*53-1:`PIXEL_WIDTH*52]}}} ;
        14     : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*56],{56{rec_ref_pel_w[`PIXEL_WIDTH*57-1:`PIXEL_WIDTH*56]}}} ;
        15     : rec_ref_pel_rshift = {rec_ref_pel_w[`PIXEL_WIDTH*96-1:`PIXEL_WIDTH*60],{60{rec_ref_pel_w[`PIXEL_WIDTH*61-1:`PIXEL_WIDTH*60]}}} ;
        default: rec_ref_pel_rshift =  rec_ref_pel_w ;
    endcase 
  end

  assign rec_ref_pel_w0 = rec_cur_x_i == 0 ? rec_ref_pel_lshift : ((rec_cur_x_i+2)*64<=sys_all_x_i ? rec_ref_pel_w : rec_ref_pel_rshift) ;
  assign rec_ref_pel_w1 = rec_ref_pel_w0 << ({rec_ref_x,3'b0}) ;
  assign rec_ref_pel_w2 = rec_ref_pel_w1[96*`PIXEL_WIDTH-1 :88*`PIXEL_WIDTH] ;

  always @ (*) begin
      if(rec_cur_y_i  == 'd0)
          rec_ref_y = (rec_ref_y_i < 'd16) ? 'd0 : (rec_ref_y_i - 'd16);
      else if(rec_cur_y_i*32 + rec_ref_y_i - 'd16 > (sys_all_y_i-'d1)/2)
          rec_ref_y = (sys_all_y_i - 'd1)/2 - rec_cur_y_i*32 + 'd16 ;
      else
          rec_ref_y = rec_ref_y_i ;
  end

// ********************************************
//
//    Sel Logic
//
// ********************************************

wire    [64*`PIXEL_WIDTH-1:0]  ext_load_data_u     ;   
wire    [32*`PIXEL_WIDTH-1:0]  ext_load_data_u_0   ;   
wire    [32*`PIXEL_WIDTH-1:0]  ext_load_data_u_1   ;   
wire    [64*`PIXEL_WIDTH-1:0]  ext_load_data_v     ;   
wire    [32*`PIXEL_WIDTH-1:0]  ext_load_data_v_0   ;   
wire    [32*`PIXEL_WIDTH-1:0]  ext_load_data_v_1   ;  

assign ext_load_data_u   = ext_load_data_i[128*`PIXEL_WIDTH-1:64 *`PIXEL_WIDTH] ;
assign ext_load_data_u_1 = ext_load_data_u[64 *`PIXEL_WIDTH-1:32 *`PIXEL_WIDTH] ;
assign ext_load_data_u_0 = ext_load_data_u[32 *`PIXEL_WIDTH-1:               0] ;

assign ext_load_data_v   = ext_load_data_i[64 *`PIXEL_WIDTH-1:               0] ;
assign ext_load_data_v_1 = ext_load_data_v[64 *`PIXEL_WIDTH-1:32 *`PIXEL_WIDTH] ;
assign ext_load_data_v_0 = ext_load_data_v[32 *`PIXEL_WIDTH-1:               0] ;

assign rec_ref_rden_u    =  rec_ref_sel_i==`TYPE_U ? rec_ref_rden_i : 0 ;
assign rec_ref_rden_v    =  rec_ref_sel_i==`TYPE_V ? rec_ref_rden_i : 0 ;

always @ (*) begin
    case(rotate_rec) 
    'd0: begin
        if ( extif_width_i == 'd128 && extif_mode_i == 'd6 ) begin
            ref_u_rec00_wen     = ext_load_valid_i  ;
            ref_u_rec00_waddr   = ext_load_addr_i   ;   
            ref_u_rec00_wdata   = ext_load_data_u_1 ; 
            ref_u_rec00_rden    = 'b0;
            ref_u_rec00_raddr   = 'b0;
        end
        else begin
            ref_u_rec00_wen     = 'b0;
            ref_u_rec00_waddr   = 'b0;
            ref_u_rec00_wdata   = 'b0;
            ref_u_rec00_rden    = rec_ref_rden_u;
            ref_u_rec00_raddr   = rec_ref_y;
        end

        ref_u_rec01_wen     = ext_load_valid_i  ;
        ref_u_rec01_waddr   = ext_load_addr_i   ;   
        ref_u_rec01_wdata   = ext_load_data_u_0 ; 
        ref_u_rec01_rden    = 'b0;
        ref_u_rec01_raddr   = 'b0;
        
        ref_u_rec02_wen     = 'b0;
        ref_u_rec02_waddr   = 'b0;
        ref_u_rec02_wdata   = 'b0;
        ref_u_rec02_rden    = rec_ref_rden_u;
        ref_u_rec02_raddr   = rec_ref_y;

        ref_u_rec03_wen     = 'b0;
        ref_u_rec03_waddr   = 'b0;
        ref_u_rec03_wdata   = 'b0;
        ref_u_rec03_rden    = rec_ref_rden_u;
        ref_u_rec03_raddr   = rec_ref_y;

        rec_ref_u_pel_w = {ref_u_rec02_rdata,ref_u_rec03_rdata,ref_u_rec00_rdata};
    end
    'd1: begin
        ref_u_rec00_wen     = 'b0;
        ref_u_rec00_waddr   = 'b0;
        ref_u_rec00_wdata   = 'b0;
        ref_u_rec00_rden    = rec_ref_rden_u;
        ref_u_rec00_raddr   = rec_ref_y;

        if ( extif_width_i == 'd128 && extif_mode_i == 'd6 ) begin
            ref_u_rec01_wen     = ext_load_valid_i  ;
            ref_u_rec01_waddr   = ext_load_addr_i   ;   
            ref_u_rec01_wdata   = ext_load_data_u_1 ; 
            ref_u_rec01_rden    = 'b0;
            ref_u_rec01_raddr   = 'b0;
        end
        else begin
            ref_u_rec01_wen     = 'b0;
            ref_u_rec01_waddr   = 'b0;
            ref_u_rec01_wdata   = 'b0;
            ref_u_rec01_rden    = rec_ref_rden_u;
            ref_u_rec01_raddr   = rec_ref_y;
        end
        
        ref_u_rec02_wen     = ext_load_valid_i  ;
        ref_u_rec02_waddr   = ext_load_addr_i   ;
        ref_u_rec02_wdata   = ext_load_data_u_0 ;
        ref_u_rec02_rden    = 'b0;
        ref_u_rec02_raddr   = 'b0;

        ref_u_rec03_wen     = 'b0;
        ref_u_rec03_waddr   = 'b0;
        ref_u_rec03_wdata   = 'b0;
        ref_u_rec03_rden    = rec_ref_rden_u;
        ref_u_rec03_raddr   = rec_ref_y; 

        rec_ref_u_pel_w = {ref_u_rec03_rdata,ref_u_rec00_rdata,ref_u_rec01_rdata};
    end
    'd2: begin
        ref_u_rec00_wen     = 'b0;
        ref_u_rec00_waddr   = 'b0;
        ref_u_rec00_wdata   = 'b0;
        ref_u_rec00_rden    = rec_ref_rden_u;
        ref_u_rec00_raddr   = rec_ref_y;

        ref_u_rec01_wen     = 'b0;
        ref_u_rec01_waddr   = 'b0;  
        ref_u_rec01_wdata   = 'b0;
        ref_u_rec01_rden    = rec_ref_rden_u;
        ref_u_rec01_raddr   = rec_ref_y;      

        if ( extif_width_i == 'd128 && extif_mode_i == 'd6 ) begin
            ref_u_rec02_wen     = ext_load_valid_i  ;
            ref_u_rec02_waddr   = ext_load_addr_i   ;   
            ref_u_rec02_wdata   = ext_load_data_u_1 ; 
            ref_u_rec02_rden    = 'b0;
            ref_u_rec02_raddr   = 'b0;
        end
        else begin
            ref_u_rec02_wen     = 'b0;
            ref_u_rec02_waddr   = 'b0;
            ref_u_rec02_wdata   = 'b0;
            ref_u_rec02_rden    = rec_ref_rden_u;
            ref_u_rec02_raddr   = rec_ref_y;
        end

        ref_u_rec03_wen     = ext_load_valid_i;
        ref_u_rec03_waddr   = ext_load_addr_i ;
        ref_u_rec03_wdata   = ext_load_data_u_0 ;
        ref_u_rec03_rden    = 'b0;
        ref_u_rec03_raddr   = 'b0;     

        rec_ref_u_pel_w = {ref_u_rec00_rdata,ref_u_rec01_rdata,ref_u_rec02_rdata};
    end
    'd3: begin
        ref_u_rec00_wen     = ext_load_valid_i;
        ref_u_rec00_waddr   = ext_load_addr_i ;
        ref_u_rec00_wdata   = ext_load_data_u_0 ;
        ref_u_rec00_rden    = 'b0;
        ref_u_rec00_raddr   = 'b0;     

        ref_u_rec01_wen     = 'b0;
        ref_u_rec01_waddr   = 'b0;  
        ref_u_rec01_wdata   = 'b0;
        ref_u_rec01_rden    = rec_ref_rden_u;
        ref_u_rec01_raddr   = rec_ref_y; 
        
        ref_u_rec02_wen     = 'b0;
        ref_u_rec02_waddr   = 'b0;  
        ref_u_rec02_wdata   = 'b0;
        ref_u_rec02_rden    = rec_ref_rden_u;
        ref_u_rec02_raddr   = rec_ref_y; 

        if ( extif_width_i == 'd128 && extif_mode_i == 'd6 ) begin
            ref_u_rec03_wen     = ext_load_valid_i  ;
            ref_u_rec03_waddr   = ext_load_addr_i   ;   
            ref_u_rec03_wdata   = ext_load_data_u_1 ; 
            ref_u_rec03_rden    = 'b0;
            ref_u_rec03_raddr   = 'b0;
        end
        else begin
            ref_u_rec03_wen     = 'b0;
            ref_u_rec03_waddr   = 'b0;
            ref_u_rec03_wdata   = 'b0;
            ref_u_rec03_rden    = rec_ref_rden_u;
            ref_u_rec03_raddr   = rec_ref_y;
        end 

        rec_ref_u_pel_w = {ref_u_rec01_rdata,ref_u_rec02_rdata,ref_u_rec03_rdata};    
    end
    default: begin
        ref_u_rec00_wen     = 'b0;
        ref_u_rec00_waddr   = 'b0;
        ref_u_rec00_wdata   = 'b0;
        ref_u_rec00_rden    = 'b0;
        ref_u_rec00_raddr   = 'b0;

        ref_u_rec01_wen     = 'b0;
        ref_u_rec01_waddr   = 'b0;
        ref_u_rec01_wdata   = 'b0;
        ref_u_rec01_rden    = 'b0;
        ref_u_rec01_raddr   = 'b0;
        
        ref_u_rec02_wen     = 'b0;
        ref_u_rec02_waddr   = 'b0;
        ref_u_rec02_wdata   = 'b0;
        ref_u_rec02_rden    = 'b0;
        ref_u_rec02_raddr   = 'b0;

        ref_u_rec03_wen     = 'b0;
        ref_u_rec03_waddr   = 'b0;
        ref_u_rec03_wdata   = 'b0;
        ref_u_rec03_rden    = 'b0;
        ref_u_rec03_raddr   = 'b0;

        rec_ref_u_pel_w = 96'd0;
    end
    endcase
end

always @ (*) begin
    case(rotate_rec) 
    'd0: begin
        if ( extif_width_i == 'd128 && extif_mode_i == 'd6 ) begin
            ref_v_rec00_wen     = ext_load_valid_i  ;
            ref_v_rec00_waddr   = ext_load_addr_i   ;   
            ref_v_rec00_wdata   = ext_load_data_v_1 ; 
            ref_v_rec00_rden    = 'b0;
            ref_v_rec00_raddr   = 'b0;
        end
        else begin
            ref_v_rec00_wen     = 'b0;
            ref_v_rec00_waddr   = 'b0;
            ref_v_rec00_wdata   = 'b0;
            ref_v_rec00_rden    = rec_ref_rden_v;
            ref_v_rec00_raddr   = rec_ref_y;
        end

        ref_v_rec01_wen     = ext_load_valid_i  ;
        ref_v_rec01_waddr   = ext_load_addr_i   ;   
        ref_v_rec01_wdata   = ext_load_data_v_0 ; 
        ref_v_rec01_rden    = 'b0;
        ref_v_rec01_raddr   = 'b0;
        
        ref_v_rec02_wen     = 'b0;
        ref_v_rec02_waddr   = 'b0;
        ref_v_rec02_wdata   = 'b0;
        ref_v_rec02_rden    = rec_ref_rden_v;
        ref_v_rec02_raddr   = rec_ref_y;

        ref_v_rec03_wen     = 'b0;
        ref_v_rec03_waddr   = 'b0;
        ref_v_rec03_wdata   = 'b0;
        ref_v_rec03_rden    = rec_ref_rden_v;
        ref_v_rec03_raddr   = rec_ref_y;

        rec_ref_v_pel_w = {ref_v_rec02_rdata,ref_v_rec03_rdata,ref_v_rec00_rdata};
    end
    'd1: begin
        ref_v_rec00_wen     = 'b0;
        ref_v_rec00_waddr   = 'b0;
        ref_v_rec00_wdata   = 'b0;
        ref_v_rec00_rden    = rec_ref_rden_v;
        ref_v_rec00_raddr   = rec_ref_y;

        if ( extif_width_i == 'd128 && extif_mode_i == 'd6 ) begin
            ref_v_rec01_wen     = ext_load_valid_i  ;
            ref_v_rec01_waddr   = ext_load_addr_i   ;   
            ref_v_rec01_wdata   = ext_load_data_v_1 ; 
            ref_v_rec01_rden    = 'b0;
            ref_v_rec01_raddr   = 'b0;
        end
        else begin
            ref_v_rec01_wen     = 'b0;
            ref_v_rec01_waddr   = 'b0;
            ref_v_rec01_wdata   = 'b0;
            ref_v_rec01_rden    = rec_ref_rden_v;
            ref_v_rec01_raddr   = rec_ref_y;
        end
        
        ref_v_rec02_wen     = ext_load_valid_i  ;
        ref_v_rec02_waddr   = ext_load_addr_i   ;
        ref_v_rec02_wdata   = ext_load_data_v_0 ;
        ref_v_rec02_rden    = 'b0;
        ref_v_rec02_raddr   = 'b0;

        ref_v_rec03_wen     = 'b0;
        ref_v_rec03_waddr   = 'b0;
        ref_v_rec03_wdata   = 'b0;
        ref_v_rec03_rden    = rec_ref_rden_v;
        ref_v_rec03_raddr   = rec_ref_y; 

        rec_ref_v_pel_w = {ref_v_rec03_rdata,ref_v_rec00_rdata,ref_v_rec01_rdata};
    end
    'd2: begin
        ref_v_rec00_wen     = 'b0;
        ref_v_rec00_waddr   = 'b0;
        ref_v_rec00_wdata   = 'b0;
        ref_v_rec00_rden    = rec_ref_rden_v;
        ref_v_rec00_raddr   = rec_ref_y;

        ref_v_rec01_wen     = 'b0;
        ref_v_rec01_waddr   = 'b0;  
        ref_v_rec01_wdata   = 'b0;
        ref_v_rec01_rden    = rec_ref_rden_v;
        ref_v_rec01_raddr   = rec_ref_y; 
        
        if ( extif_width_i == 'd128 && extif_mode_i == 'd6 ) begin
            ref_v_rec02_wen     = ext_load_valid_i  ;
            ref_v_rec02_waddr   = ext_load_addr_i   ;   
            ref_v_rec02_wdata   = ext_load_data_v_1 ; 
            ref_v_rec02_rden    = 'b0;
            ref_v_rec02_raddr   = 'b0;
        end
        else begin
            ref_v_rec02_wen     = 'b0;
            ref_v_rec02_waddr   = 'b0;
            ref_v_rec02_wdata   = 'b0;
            ref_v_rec02_rden    = rec_ref_rden_v;
            ref_v_rec02_raddr   = rec_ref_y;
        end

        ref_v_rec03_wen     = ext_load_valid_i;
        ref_v_rec03_waddr   = ext_load_addr_i ;
        ref_v_rec03_wdata   = ext_load_data_v_0 ;
        ref_v_rec03_rden    = 'b0;
        ref_v_rec03_raddr   = 'b0;     

        rec_ref_v_pel_w = {ref_v_rec00_rdata,ref_v_rec01_rdata,ref_v_rec02_rdata};
    end
    'd3: begin
        ref_v_rec00_wen     = ext_load_valid_i;
        ref_v_rec00_waddr   = ext_load_addr_i ;
        ref_v_rec00_wdata   = ext_load_data_v_0 ;
        ref_v_rec00_rden    = 'b0;
        ref_v_rec00_raddr   = 'b0;     

        ref_v_rec01_wen     = 'b0;
        ref_v_rec01_waddr   = 'b0;  
        ref_v_rec01_wdata   = 'b0;
        ref_v_rec01_rden    = rec_ref_rden_v;
        ref_v_rec01_raddr   = rec_ref_y; 
        
        ref_v_rec02_wen     = 'b0;
        ref_v_rec02_waddr   = 'b0;  
        ref_v_rec02_wdata   = 'b0;
        ref_v_rec02_rden    = rec_ref_rden_v;
        ref_v_rec02_raddr   = rec_ref_y; 

        if ( extif_width_i == 'd128 && extif_mode_i == 'd6 ) begin
            ref_v_rec03_wen     = ext_load_valid_i  ;
            ref_v_rec03_waddr   = ext_load_addr_i   ;   
            ref_v_rec03_wdata   = ext_load_data_v_1 ; 
            ref_v_rec03_rden    = 'b0;
            ref_v_rec03_raddr   = 'b0;
        end
        else begin
            ref_v_rec03_wen     = 'b0;
            ref_v_rec03_waddr   = 'b0;
            ref_v_rec03_wdata   = 'b0;
            ref_v_rec03_rden    = rec_ref_rden_v;
            ref_v_rec03_raddr   = rec_ref_y;
        end    

        rec_ref_v_pel_w = {ref_v_rec01_rdata,ref_v_rec02_rdata,ref_v_rec03_rdata};    
    end
    default: begin
        ref_v_rec00_wen     = 'b0;
        ref_v_rec00_waddr   = 'b0;
        ref_v_rec00_wdata   = 'b0;
        ref_v_rec00_rden    = 'b0;
        ref_v_rec00_raddr   = 'b0;

        ref_v_rec01_wen     = 'b0;
        ref_v_rec01_waddr   = 'b0;
        ref_v_rec01_wdata   = 'b0;
        ref_v_rec01_rden    = 'b0;
        ref_v_rec01_raddr   = 'b0;
        
        ref_v_rec02_wen     = 'b0;
        ref_v_rec02_waddr   = 'b0;
        ref_v_rec02_wdata   = 'b0;
        ref_v_rec02_rden    = 'b0;
        ref_v_rec02_raddr   = 'b0;

        ref_v_rec03_wen     = 'b0;
        ref_v_rec03_waddr   = 'b0;
        ref_v_rec03_wdata   = 'b0;
        ref_v_rec03_rden    = 'b0;
        ref_v_rec03_raddr   = 'b0;

        rec_ref_v_pel_w = 96'd0;
    end
    endcase
end

// ********************************************
//
//    Memory
//
// ********************************************

fetch_rf_1p_64x256  ref_u_rec00(
    .clk            (clk               ),
    .rstn           (rstn              ),
                                 
    .wrif_en_i      (ref_u_rec00_wen   ),
    .wrif_addr_i    (ref_u_rec00_waddr ),
    .wrif_data_i    (ref_u_rec00_wdata ),
                          
    .rdif_en_i      (ref_u_rec00_rden  ),
    .rdif_addr_i    (ref_u_rec00_raddr ),
    .rdif_pdata_o   (ref_u_rec00_rdata )     
);

fetch_rf_1p_64x256  ref_u_rec01(
    .clk            (clk               ),
    .rstn           (rstn              ),
                                 
    .wrif_en_i      (ref_u_rec01_wen   ),
    .wrif_addr_i    (ref_u_rec01_waddr ),
    .wrif_data_i    (ref_u_rec01_wdata ),
                          
    .rdif_en_i      (ref_u_rec01_rden  ),
    .rdif_addr_i    (ref_u_rec01_raddr ),
    .rdif_pdata_o   (ref_u_rec01_rdata )     
);

fetch_rf_1p_64x256  ref_u_rec02(
    .clk            (clk               ),
    .rstn           (rstn              ),
                                 
    .wrif_en_i      (ref_u_rec02_wen   ),
    .wrif_addr_i    (ref_u_rec02_waddr ),
    .wrif_data_i    (ref_u_rec02_wdata ),
                          
    .rdif_en_i      (ref_u_rec02_rden  ),
    .rdif_addr_i    (ref_u_rec02_raddr ),
    .rdif_pdata_o   (ref_u_rec02_rdata )     
);

fetch_rf_1p_64x256  ref_u_rec03(
    .clk            (clk               ),
    .rstn           (rstn              ),
                                 
    .wrif_en_i      (ref_u_rec03_wen   ),
    .wrif_addr_i    (ref_u_rec03_waddr ),
    .wrif_data_i    (ref_u_rec03_wdata ),
                          
    .rdif_en_i      (ref_u_rec03_rden  ),
    .rdif_addr_i    (ref_u_rec03_raddr ),
    .rdif_pdata_o   (ref_u_rec03_rdata )     
);

fetch_rf_1p_64x256  ref_v_rec00(
    .clk            (clk               ),
    .rstn           (rstn              ),
                                 
    .wrif_en_i      (ref_v_rec00_wen   ),
    .wrif_addr_i    (ref_v_rec00_waddr ),
    .wrif_data_i    (ref_v_rec00_wdata ),
                         
    .rdif_en_i      (ref_v_rec00_rden  ),
    .rdif_addr_i    (ref_v_rec00_raddr ),
    .rdif_pdata_o   (ref_v_rec00_rdata )     
);

fetch_rf_1p_64x256  ref_v_rec01(
    .clk            (clk               ),
    .rstn           (rstn              ),
                                 
    .wrif_en_i      (ref_v_rec01_wen   ),
    .wrif_addr_i    (ref_v_rec01_waddr ),
    .wrif_data_i    (ref_v_rec01_wdata ),
                         
    .rdif_en_i      (ref_v_rec01_rden  ),
    .rdif_addr_i    (ref_v_rec01_raddr ),
    .rdif_pdata_o   (ref_v_rec01_rdata )     
);

fetch_rf_1p_64x256  ref_v_rec02(
    .clk            (clk               ),
    .rstn           (rstn              ),
                                 
    .wrif_en_i      (ref_v_rec02_wen   ),
    .wrif_addr_i    (ref_v_rec02_waddr ),
    .wrif_data_i    (ref_v_rec02_wdata ),
                         
    .rdif_en_i      (ref_v_rec02_rden  ),
    .rdif_addr_i    (ref_v_rec02_raddr ),
    .rdif_pdata_o   (ref_v_rec02_rdata )     
);

fetch_rf_1p_64x256  ref_v_rec03(
    .clk            (clk               ),
    .rstn           (rstn              ),
                                 
    .wrif_en_i      (ref_v_rec03_wen   ),
    .wrif_addr_i    (ref_v_rec03_waddr ),
    .wrif_data_i    (ref_v_rec03_wdata ),
                         
    .rdif_en_i      (ref_v_rec03_rden  ),
    .rdif_addr_i    (ref_v_rec03_raddr ),
    .rdif_pdata_o   (ref_v_rec03_rdata )     
);

endmodule

