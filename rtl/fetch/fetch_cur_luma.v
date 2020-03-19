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
//  Filename      : fetch_cur_luma.v
//  Author        : Yufeng Bai
//  Email     : byfchina@gmail.com
//
//-------------------------------------------------------------------
//
//  Modified      : 2015-09-02 by HLL
//  Description   : rotate by sys_start_i
//  Modified      : 2015-09-05 by HLL
//  Description   : intra supported
//  Modified      : 2015-09-07 by HLL
//  Description   : prei_curntra sorted
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fetch_cur_luma (
  clk                  ,
  rstn                 ,
  sysif_start_i        ,
  sysif_type_i         ,
  sys_all_x_i          ,
  sys_all_y_i          ,

  prei_cur_rden_i      ,
  prei_cur_sel_i       ,
  prei_cur_size_i      ,
  prei_cur_4x4_x_i     ,
  prei_cur_4x4_y_i     ,
  prei_cur_4x4_idx_i   ,
  prei_cur_pel_o       ,

  posi_cur_rden_i      ,
  posi_cur_sel_i       ,
  posi_cur_size_i      ,
  posi_cur_4x4_x_i     ,
  posi_cur_4x4_y_i     ,
  posi_cur_4x4_idx_i   ,
  posi_cur_pel_o       ,

  ime_cur_4x4_x_i      ,
  ime_cur_4x4_y_i      ,
  ime_cur_4x4_idx_i    ,
  ime_cur_sel_i        ,
  ime_cur_size_i       ,
  ime_cur_rden_i       ,
  ime_cur_x_i          ,
  ime_cur_y_i          ,
  ime_cur_downsample_i ,
  ime_cur_pel_o        ,

  fme_cur_4x4_x_i      ,
  fme_cur_4x4_y_i      ,
  fme_cur_4x4_idx_i    ,
  fme_cur_sel_i        ,
  fme_cur_size_i       ,
  fme_cur_rden_i       ,
  fme_cur_pel_o        ,

  rec_cur_4x4_x_i      ,
  rec_cur_4x4_y_i      ,
  rec_cur_4x4_idx_i    ,
  rec_cur_sel_i        ,
  rec_cur_size_i       ,
  rec_cur_rden_i       ,
  rec_cur_pel_o        ,

  db_cur_4x4_x_i       ,
  db_cur_4x4_y_i       ,
  db_cur_4x4_idx_i     ,
  db_cur_sel_i         ,
  db_cur_size_i        ,
  db_cur_rden_i        ,
  db_cur_pel_o         ,

  ext_load_done_i      ,
  ext_load_data_i      ,
  ext_load_addr_i      ,
  ext_load_valid_i
);


// ********************************************
//
//    PARAMETER DECLARATION
//
// ********************************************

  parameter INTRA = 0 ,
            INTER = 1 ;


// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input    [1-1:0]                    clk                   ; // clk signal
input    [1-1:0]                    rstn                  ; // asynchronous reset
input                               sysif_start_i         ;
input                               sysif_type_i          ;
input    [`PIC_WIDTH  -1    : 0]    sys_all_x_i           ;
input    [`PIC_HEIGHT -1    : 0]    sys_all_y_i           ;

input    [1-1               : 0]    prei_cur_rden_i       ; // prei_cur currelcu x
input    [2-1               : 0]    prei_cur_sel_i        ; // prei_cur currelcu y
input    [2-1               : 0]    prei_cur_size_i       ; // prei_cur currelcu idx
input    [4-1               : 0]    prei_cur_4x4_x_i      ; // prei_cur currelcu chroma/luma sel
input    [4-1               : 0]    prei_cur_4x4_y_i      ; // prei_cur currelcu size :4x4
input    [5-1               : 0]    prei_cur_4x4_idx_i    ; // prei_cur currelcu read enable
output   [32*`PIXEL_WIDTH-1 : 0]    prei_cur_pel_o        ; // prei_cur currelcu pixel
    
input    [1-1               : 0]    posi_cur_rden_i       ; // posi_cur currelcu x
input    [2-1               : 0]    posi_cur_sel_i        ; // posi_cur currelcu y
input    [2-1               : 0]    posi_cur_size_i       ; // posi_cur currelcu idx
input    [4-1               : 0]    posi_cur_4x4_x_i      ; // posi_cur currelcu chroma/luma sel
input    [4-1               : 0]    posi_cur_4x4_y_i      ; // posi_cur currelcu size :4x4
input    [5-1               : 0]    posi_cur_4x4_idx_i    ; // posi_cur currelcu read enable
output   [32*`PIXEL_WIDTH-1 : 0]    posi_cur_pel_o        ; // posi_cur currelcu pixel
    
input    [4-1:0]                    ime_cur_4x4_x_i       ; // ime current lcu x
input    [4-1:0]                    ime_cur_4x4_y_i       ; // ime current lcu y
input    [5-1:0]                    ime_cur_4x4_idx_i     ; // ime current lcu idx
input    [2-1:0]                    ime_cur_sel_i         ; // ime current lcu chroma/luma sel
input    [2-1:0]                    ime_cur_size_i        ; // ime current lcu size :4x4
input    [1-1:0]                    ime_cur_rden_i        ; // ime current lcu read enable
input    [`PIC_X_WIDTH-1   :0]      ime_cur_x_i           ; // ime current lcu index x
input    [`PIC_Y_WIDTH-1   :0]      ime_cur_y_i           ; // ime current lcu index y
input    [1-1:0]                    ime_cur_downsample_i  ; // ime current downsample sel
output   [32*`PIXEL_WIDTH-1:0]      ime_cur_pel_o         ; // ime current lcu pixel
    
input    [4-1:0]                    fme_cur_4x4_x_i       ; // fme current lcu x
input    [4-1:0]                    fme_cur_4x4_y_i       ; // fme current lcu y
input    [5-1:0]                    fme_cur_4x4_idx_i     ; // fme current lcu idx
input    [2-1:0]                    fme_cur_sel_i         ; // fme current lcu chroma/luma sel
input    [2-1:0]                    fme_cur_size_i        ; // "fme current lcu size :4x4
input    [1-1:0]                    fme_cur_rden_i        ; // fme current lcu read enable
output   [32*`PIXEL_WIDTH-1:0]      fme_cur_pel_o         ; // fme current lcu pixel
    
input    [4-1:0]                    rec_cur_4x4_x_i       ; // rec current lcu x
input    [4-1:0]                    rec_cur_4x4_y_i       ; // rec current lcu y
input    [5-1:0]                    rec_cur_4x4_idx_i     ; // rec current lcu idx
input    [2-1:0]                    rec_cur_sel_i         ; // rec current lcu chroma/luma sel
input    [2-1:0]                    rec_cur_size_i        ; // "rec current lcu size :4x4
input    [1-1:0]                    rec_cur_rden_i        ; // rec current lcu read enable
output   [32*`PIXEL_WIDTH-1:0]      rec_cur_pel_o         ; // rec current lcu pixel
    
input    [4-1:0]                    db_cur_4x4_x_i        ; // db current lcu x
input    [4-1:0]                    db_cur_4x4_y_i        ; // db current lcu y
input    [5-1:0]                    db_cur_4x4_idx_i      ; // db current lcu idx
input    [2-1:0]                    db_cur_sel_i          ; // db current lcu chroma/luma sel
input    [2-1:0]                    db_cur_size_i         ; // "db current lcu size :4x4
input    [1-1:0]                    db_cur_rden_i         ; // db current lcu read enable
output   [32*`PIXEL_WIDTH-1:0]      db_cur_pel_o          ; // db current lcu pixel
    
input    [1-1:0]                    ext_load_done_i       ; // load current lcu done
input    [32*`PIXEL_WIDTH-1:0]      ext_load_data_i       ; // load current lcu data
input    [7-1:0]                    ext_load_addr_i       ;
input    [1-1:0]                    ext_load_valid_i      ; // load current lcu data valid

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

reg      [3-1:0]                    rotate_i              ; // I frame rotatation counter
reg      [2-1:0]                    rotate_p              ; // P frame rotatation counter
reg      [1-1:0]                    rotate_ime            ; // ime     rotatation counter
        
reg      [4-1:0]                    cur_i_0_4x4_x         ;
reg      [4-1:0]                    cur_i_0_4x4_y         ;
reg      [5-1:0]                    cur_i_0_idx           ;
reg      [2-1:0]                    cur_i_0_sel           ;
reg      [2-1:0]                    cur_i_0_size          ;
reg      [1-1:0]                    cur_i_0_ren           ;
reg      [32*`PIXEL_WIDTH-1:0]      cur_i_0_pel           ;
          
reg      [4-1:0]                    cur_i_1_4x4_x         ;
reg      [4-1:0]                    cur_i_1_4x4_y         ;
reg      [5-1:0]                    cur_i_1_idx           ;
reg      [2-1:0]                    cur_i_1_sel           ;
reg      [2-1:0]                    cur_i_1_size          ;
reg      [1-1:0]                    cur_i_1_ren           ;
reg      [32*`PIXEL_WIDTH-1:0]      cur_i_1_pel           ;
        
reg      [4-1:0]                    cur_i_2_4x4_x         ;
reg      [4-1:0]                    cur_i_2_4x4_y         ;
reg      [5-1:0]                    cur_i_2_idx           ;
reg      [2-1:0]                    cur_i_2_sel           ;
reg      [2-1:0]                    cur_i_2_size          ;
reg      [1-1:0]                    cur_i_2_ren           ;
reg      [32*`PIXEL_WIDTH-1:0]      cur_i_2_pel           ;
        
reg      [4-1:0]                    cur_i_3_4x4_x         ;
reg      [4-1:0]                    cur_i_3_4x4_y         ;
reg      [5-1:0]                    cur_i_3_idx           ;
reg      [2-1:0]                    cur_i_3_sel           ;
reg      [2-1:0]                    cur_i_3_size          ;
reg      [1-1:0]                    cur_i_3_ren           ;
reg      [32*`PIXEL_WIDTH-1:0]      cur_i_3_pel           ;
        
reg      [4-1:0]                    cur_i_4_4x4_x         ;
reg      [4-1:0]                    cur_i_4_4x4_y         ;
reg      [5-1:0]                    cur_i_4_idx           ;
reg      [2-1:0]                    cur_i_4_sel           ;
reg      [2-1:0]                    cur_i_4_size          ;
reg      [1-1:0]                    cur_i_4_ren           ;
reg      [32*`PIXEL_WIDTH-1:0]      cur_i_4_pel           ;
      
      
reg      [4-1:0]                    cur_p_0_4x4_x         ;
reg      [4-1:0]                    cur_p_0_4x4_y         ;
reg      [5-1:0]                    cur_p_0_idx           ;
reg      [2-1:0]                    cur_p_0_sel           ;
reg      [2-1:0]                    cur_p_0_size          ;
reg      [1-1:0]                    cur_p_0_ren           ;
reg      [32*`PIXEL_WIDTH-1:0]      cur_p_0_pel           ;
      
reg      [4-1:0]                    cur_p_1_4x4_x         ;
reg      [4-1:0]                    cur_p_1_4x4_y         ;
reg      [5-1:0]                    cur_p_1_idx           ;
reg      [2-1:0]                    cur_p_1_sel           ;
reg      [2-1:0]                    cur_p_1_size          ;
reg      [1-1:0]                    cur_p_1_ren           ;
reg      [32*`PIXEL_WIDTH-1:0]      cur_p_1_pel           ;
      
reg      [4-1:0]                    cur_p_2_4x4_x         ;
reg      [4-1:0]                    cur_p_2_4x4_y         ;
reg      [5-1:0]                    cur_p_2_idx           ;
reg      [2-1:0]                    cur_p_2_sel           ;
reg      [2-1:0]                    cur_p_2_size          ;
reg      [1-1:0]                    cur_p_2_ren           ;
reg      [32*`PIXEL_WIDTH-1:0]      cur_p_2_pel           ;     

reg      [4-1:0]                    cur_ime_0_4x4_x       ;
reg      [4-1:0]                    cur_ime_0_4x4_y       ;
reg      [5-1:0]                    cur_ime_0_idx         ;
reg      [2-1:0]                    cur_ime_0_sel         ;
reg      [2-1:0]                    cur_ime_0_size        ;
reg      [1-1:0]                    cur_ime_0_ren         ;
reg      [32*`PIXEL_WIDTH-1:0]      cur_ime_0_pel         ;
      
reg      [4-1:0]                    cur_ime_1_4x4_x       ;
reg      [4-1:0]                    cur_ime_1_4x4_y       ;
reg      [5-1:0]                    cur_ime_1_idx         ;
reg      [2-1:0]                    cur_ime_1_sel         ;
reg      [2-1:0]                    cur_ime_1_size        ;
reg      [1-1:0]                    cur_ime_1_ren         ;
reg      [32*`PIXEL_WIDTH-1:0]      cur_ime_1_pel         ;
                                     
reg                                 cur_i_0_wen           ;                   
reg      [6:0]                      cur_i_0_waddr         ;                     
reg      [32*`PIXEL_WIDTH-1:0]      cur_i_0_wdata         ;                     
wire     [32*`PIXEL_WIDTH-1:0]      cur_i_0_rdata         ;                     
                                     
reg                                 cur_i_1_wen           ;                   
reg      [6:0]                      cur_i_1_waddr         ;                     
reg      [32*`PIXEL_WIDTH-1:0]      cur_i_1_wdata         ;                     
wire     [32*`PIXEL_WIDTH-1:0]      cur_i_1_rdata         ;                     
                                     
reg                                 cur_i_2_wen           ;                   
reg      [6:0]                      cur_i_2_waddr         ;                     
reg      [32*`PIXEL_WIDTH-1:0]      cur_i_2_wdata         ;                     
wire     [32*`PIXEL_WIDTH-1:0]      cur_i_2_rdata         ;                     
                                     
reg                                 cur_i_3_wen           ;                   
reg      [6:0]                      cur_i_3_waddr         ;                     
reg      [32*`PIXEL_WIDTH-1:0]      cur_i_3_wdata         ;                     
wire     [32*`PIXEL_WIDTH-1:0]      cur_i_3_rdata         ;                     
                                     
reg                                 cur_i_4_wen           ;                   
reg      [6:0]                      cur_i_4_waddr         ;                     
reg      [32*`PIXEL_WIDTH-1:0]      cur_i_4_wdata         ;                     
wire     [32*`PIXEL_WIDTH-1:0]      cur_i_4_rdata         ;      

reg                                 cur_p_0_wen           ;
reg      [6:0]                      cur_p_0_waddr         ;
reg      [32*`PIXEL_WIDTH-1:0]      cur_p_0_wdata         ;
wire     [32*`PIXEL_WIDTH-1:0]      cur_p_0_rdata         ;
      
reg                                 cur_p_1_wen           ;                                  
reg      [6:0]                      cur_p_1_waddr         ;                     
reg      [32*`PIXEL_WIDTH-1:0]      cur_p_1_wdata         ;                     
wire     [32*`PIXEL_WIDTH-1:0]      cur_p_1_rdata         ;                     
                                     
reg                                 cur_p_2_wen           ;                   
reg      [6:0]                      cur_p_2_waddr         ;                     
reg      [32*`PIXEL_WIDTH-1:0]      cur_p_2_wdata         ;                     
wire     [32*`PIXEL_WIDTH-1:0]      cur_p_2_rdata         ;  

reg                                 cur_ime_0_wen         ;
reg      [6:0]                      cur_ime_0_waddr       ;
reg      [32*`PIXEL_WIDTH-1:0]      cur_ime_0_wdata       ;
wire     [32*`PIXEL_WIDTH-1:0]      cur_ime_0_rdata       ;
      
reg                                 cur_ime_1_wen         ;                                  
reg      [6:0]                      cur_ime_1_waddr       ;                     
reg      [32*`PIXEL_WIDTH-1:0]      cur_ime_1_wdata       ;                     
wire     [32*`PIXEL_WIDTH-1:0]      cur_ime_1_rdata       ;  

reg      [32*`PIXEL_WIDTH-1:0]      ime_cur_pel_0         ; 
reg      [32*`PIXEL_WIDTH-1:0]      ime_cur_pel_1         ;          

// ime boundary

wire     [5                :0]      ime_x_minus_width     ;
wire     [64*`PIXEL_WIDTH-1:0]      ime_cur_pel_w         ; 
reg      [64*`PIXEL_WIDTH-1:0]      ime_cur_pel_rshift    ;      
wire     [64*`PIXEL_WIDTH-1:0]      ime_cur_pel_w0        ;    
wire     [6              -1:0]      ime_cur_adr_y_w       ;   
reg      [`PIC_X_WIDTH-1   :0]      ime_cur_x_r           ; 
reg      [`PIC_Y_WIDTH-1   :0]      ime_cur_y_r           ; 
reg      [4              -1:0]      ime_cur_4x4_x_r       ; 
reg      [6              -1:0]      ime_cur_adr_y_r       ;       

//output      
reg      [32*`PIXEL_WIDTH-1:0]      ime_cur_pel_o         ; // fme current lcu pixel
reg      [32*`PIXEL_WIDTH-1:0]      fme_cur_pel_o         ; // fme current lcu pixel
reg      [32*`PIXEL_WIDTH-1:0]      rec_cur_pel_o         ; // rec current lcu pixel
reg      [32*`PIXEL_WIDTH-1:0]      db_cur_pel_o          ; // db current lcu pixel
reg      [32*`PIXEL_WIDTH-1:0]      prei_cur_pel_o        ; // prei current lcu pixel
reg      [32*`PIXEL_WIDTH-1:0]      posi_cur_pel_o        ; // posi current lcu pixel


// ********************************************
//
//    Combinational Logic
//
// ********************************************


// ********************************************
//
//    Sequential Logic
//
// ********************************************


  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rotate_i <= 0 ;
    end
    else if( sysif_start_i ) begin
      if( rotate_i == 4 )
        rotate_i <= 0 ;
      else begin
        rotate_i <= rotate_i + 1 ;
      end
    end
  end

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rotate_p <= 0 ;
    end
    else if( sysif_start_i && sysif_type_i != `INTRA ) begin
      if( rotate_p == 2 )
        rotate_p <= 0 ;
      else begin
        rotate_p <= rotate_p + 1 ;
      end
    end
  end

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rotate_ime <= 0 ;
    end
    else begin 
      if( sysif_start_i && sysif_type_i != `INTRA ) 
        rotate_ime <= ~rotate_ime ;
    end
  end

// cur_i_0
always @ (*) begin
    case (rotate_i)
        'd0: begin
            cur_i_0_wen   = ext_load_valid_i;
            cur_i_0_waddr = ext_load_addr_i;
            cur_i_0_wdata = ext_load_data_i;

            cur_i_0_ren   = 'b0;
            cur_i_0_sel   = 'b0;
            cur_i_0_size  = 'b0;
            cur_i_0_4x4_x = 'b0;
            cur_i_0_4x4_y = 'b0;
            cur_i_0_idx   = 'b0;
        end
        'd1: begin
            cur_i_0_wen   = 'b0;
            cur_i_0_waddr = 'b0;
            cur_i_0_wdata = 'b0;

            cur_i_0_ren   = prei_cur_rden_i    ;
            cur_i_0_sel   = prei_cur_sel_i     ;
            cur_i_0_size  = prei_cur_size_i    ;
            cur_i_0_4x4_x = prei_cur_4x4_x_i   ;
            cur_i_0_4x4_y = prei_cur_4x4_y_i   ;
            cur_i_0_idx   = prei_cur_4x4_idx_i ;
        end
        'd2: begin
            cur_i_0_wen   = 'b0;
            cur_i_0_waddr = 'b0;
            cur_i_0_wdata = 'b0;

            cur_i_0_ren   = posi_cur_rden_i     ;
            cur_i_0_sel   = posi_cur_sel_i      ;
            cur_i_0_size  = posi_cur_size_i     ;
            cur_i_0_4x4_x = posi_cur_4x4_x_i    ;
            cur_i_0_4x4_y = posi_cur_4x4_y_i    ;
            cur_i_0_idx   = posi_cur_4x4_idx_i  ;
        end
        'd3: begin
            cur_i_0_wen   = 'b0;
            cur_i_0_waddr = 'b0;
            cur_i_0_wdata = 'b0;

            cur_i_0_ren   = rec_cur_rden_i    ;
            cur_i_0_sel   = rec_cur_sel_i     ;
            cur_i_0_size  = rec_cur_size_i    ;
            cur_i_0_4x4_x = rec_cur_4x4_x_i   ;
            cur_i_0_4x4_y = rec_cur_4x4_y_i   ;
            cur_i_0_idx   = rec_cur_4x4_idx_i ;
        end
        'd4 : begin
            cur_i_0_wen   = 'b0;
            cur_i_0_waddr = 'b0;
            cur_i_0_wdata = 'b0;

            cur_i_0_ren   = db_cur_rden_i;
            cur_i_0_sel   = db_cur_sel_i ;
            cur_i_0_size  = db_cur_size_i;
            cur_i_0_4x4_x = db_cur_4x4_x_i;
            cur_i_0_4x4_y = db_cur_4x4_y_i;
            cur_i_0_idx   = db_cur_4x4_idx_i;
        end
        default: begin
            cur_i_0_wen   = 'b0;
            cur_i_0_waddr = 'b0;
            cur_i_0_wdata = 'b0;

            cur_i_0_ren   = 'b0;
            cur_i_0_sel   = 'b0;
            cur_i_0_size  = 'b0;
            cur_i_0_4x4_x = 'b0;
            cur_i_0_4x4_y = 'b0;
            cur_i_0_idx   = 'b0;
        end
    endcase
end

// cur_i_1
always @ (*) begin
    case (rotate_i)
        'd0: begin
            cur_i_1_wen   = 'b0;
            cur_i_1_waddr = 'b0;
            cur_i_1_wdata = 'b0;

            cur_i_1_ren   = db_cur_rden_i;
            cur_i_1_sel   = db_cur_sel_i ;
            cur_i_1_size  = db_cur_size_i;
            cur_i_1_4x4_x = db_cur_4x4_x_i;
            cur_i_1_4x4_y = db_cur_4x4_y_i;
            cur_i_1_idx   = db_cur_4x4_idx_i;
        end
        'd1: begin
            cur_i_1_wen   = ext_load_valid_i;
            cur_i_1_waddr = ext_load_addr_i;
            cur_i_1_wdata = ext_load_data_i;

            cur_i_1_ren   = 'b0;
            cur_i_1_sel   = 'b0;
            cur_i_1_size  = 'b0;
            cur_i_1_4x4_x = 'b0;
            cur_i_1_4x4_y = 'b0;
            cur_i_1_idx   = 'b0;
        end
        'd2: begin
            cur_i_1_wen   = 'b0;
            cur_i_1_waddr = 'b0;
            cur_i_1_wdata = 'b0;

            cur_i_1_ren   = prei_cur_rden_i   ;
            cur_i_1_sel   = prei_cur_sel_i    ;
            cur_i_1_size  = prei_cur_size_i   ;
            cur_i_1_4x4_x = prei_cur_4x4_x_i  ;
            cur_i_1_4x4_y = prei_cur_4x4_y_i  ;
            cur_i_1_idx   = prei_cur_4x4_idx_i;
        end
        'd3: begin
            cur_i_1_wen   = 'b0;
            cur_i_1_waddr = 'b0;
            cur_i_1_wdata = 'b0;

            cur_i_1_ren   = posi_cur_rden_i   ;
            cur_i_1_sel   = posi_cur_sel_i    ;
            cur_i_1_size  = posi_cur_size_i   ;
            cur_i_1_4x4_x = posi_cur_4x4_x_i  ;
            cur_i_1_4x4_y = posi_cur_4x4_y_i  ;
            cur_i_1_idx   = posi_cur_4x4_idx_i;
        end
        'd4: begin
            cur_i_1_wen   = 'b0;
            cur_i_1_waddr = 'b0;
            cur_i_1_wdata = 'b0;

            cur_i_1_ren   = rec_cur_rden_i   ;
            cur_i_1_sel   = rec_cur_sel_i    ;
            cur_i_1_size  = rec_cur_size_i   ;
            cur_i_1_4x4_x = rec_cur_4x4_x_i  ;
            cur_i_1_4x4_y = rec_cur_4x4_y_i  ;
            cur_i_1_idx   = rec_cur_4x4_idx_i;
        end
        default: begin
            cur_i_1_wen   = 'b0;
            cur_i_1_waddr = 'b0;
            cur_i_1_wdata = 'b0;

            cur_i_1_ren   = 'b0;
            cur_i_1_sel   = 'b0;
            cur_i_1_size  = 'b0;
            cur_i_1_4x4_x = 'b0;
            cur_i_1_4x4_y = 'b0;
            cur_i_1_idx   = 'b0;
        end
    endcase
end

// cur_i_2
always @ (*) begin
    case (rotate_i)
        'd0: begin
            cur_i_2_wen   = 'b0;
            cur_i_2_waddr = 'b0;
            cur_i_2_wdata = 'b0;

            cur_i_2_ren   = rec_cur_rden_i;
            cur_i_2_sel   = rec_cur_sel_i ;
            cur_i_2_size  = rec_cur_size_i;
            cur_i_2_4x4_x = rec_cur_4x4_x_i;
            cur_i_2_4x4_y = rec_cur_4x4_y_i;
            cur_i_2_idx   = rec_cur_4x4_idx_i;
        end
        'd1: begin
            cur_i_2_wen   = 'b0;
            cur_i_2_waddr = 'b0;
            cur_i_2_wdata = 'b0;

            cur_i_2_ren   = db_cur_rden_i   ;
            cur_i_2_sel   = db_cur_sel_i    ;
            cur_i_2_size  = db_cur_size_i   ;
            cur_i_2_4x4_x = db_cur_4x4_x_i  ;
            cur_i_2_4x4_y = db_cur_4x4_y_i  ;
            cur_i_2_idx   = db_cur_4x4_idx_i;
        end
        'd2: begin
            cur_i_2_wen   = ext_load_valid_i;
            cur_i_2_waddr = ext_load_addr_i;
            cur_i_2_wdata = ext_load_data_i;

            cur_i_2_ren   = 'b0;
            cur_i_2_sel   = 'b0;
            cur_i_2_size  = 'b0;
            cur_i_2_4x4_x = 'b0;
            cur_i_2_4x4_y = 'b0;
            cur_i_2_idx   = 'b0;
        end
        'd3: begin
            cur_i_2_wen   = 'b0;
            cur_i_2_waddr = 'b0;
            cur_i_2_wdata = 'b0;

            cur_i_2_ren   = prei_cur_rden_i    ;
            cur_i_2_sel   = prei_cur_sel_i     ;
            cur_i_2_size  = prei_cur_size_i    ;
            cur_i_2_4x4_x = prei_cur_4x4_x_i   ;
            cur_i_2_4x4_y = prei_cur_4x4_y_i   ;
            cur_i_2_idx   = prei_cur_4x4_idx_i ;
        end
        'd4: begin
            cur_i_2_wen   = 'b0;
            cur_i_2_waddr = 'b0;
            cur_i_2_wdata = 'b0;

            cur_i_2_ren   = posi_cur_rden_i   ;
            cur_i_2_sel   = posi_cur_sel_i    ;
            cur_i_2_size  = posi_cur_size_i   ;
            cur_i_2_4x4_x = posi_cur_4x4_x_i  ;
            cur_i_2_4x4_y = posi_cur_4x4_y_i  ;
            cur_i_2_idx   = posi_cur_4x4_idx_i;
        end
        default: begin
            cur_i_2_wen   = 'b0;
            cur_i_2_waddr = 'b0;
            cur_i_2_wdata = 'b0;

            cur_i_2_ren   = 'b0;
            cur_i_2_sel   = 'b0;
            cur_i_2_size  = 'b0;
            cur_i_2_4x4_x = 'b0;
            cur_i_2_4x4_y = 'b0;
            cur_i_2_idx   = 'b0;
        end
    endcase
end

// cur_i_3
always @ (*) begin
    case (rotate_i)
        'd0: begin
            cur_i_3_wen   = 'b0;
            cur_i_3_waddr = 'b0;
            cur_i_3_wdata = 'b0;

            cur_i_3_ren   = posi_cur_rden_i    ;
            cur_i_3_sel   = posi_cur_sel_i     ;
            cur_i_3_size  = posi_cur_size_i    ;
            cur_i_3_4x4_x = posi_cur_4x4_x_i   ;
            cur_i_3_4x4_y = posi_cur_4x4_y_i   ;
            cur_i_3_idx   = posi_cur_4x4_idx_i ;
        end
        'd1: begin
            cur_i_3_wen   = 'b0;
            cur_i_3_waddr = 'b0;
            cur_i_3_wdata = 'b0;

            cur_i_3_ren   = rec_cur_rden_i;
            cur_i_3_sel   = rec_cur_sel_i ;
            cur_i_3_size  = rec_cur_size_i;
            cur_i_3_4x4_x = rec_cur_4x4_x_i;
            cur_i_3_4x4_y = rec_cur_4x4_y_i;
            cur_i_3_idx   = rec_cur_4x4_idx_i;
        end
        'd2: begin
            cur_i_3_wen   = 'b0;
            cur_i_3_waddr = 'b0;
            cur_i_3_wdata = 'b0;

            cur_i_3_ren   = db_cur_rden_i;
            cur_i_3_sel   = db_cur_sel_i ;
            cur_i_3_size  = db_cur_size_i;
            cur_i_3_4x4_x = db_cur_4x4_x_i;
            cur_i_3_4x4_y = db_cur_4x4_y_i;
            cur_i_3_idx   = db_cur_4x4_idx_i;
        end
        'd3: begin
            cur_i_3_wen   = ext_load_valid_i;
            cur_i_3_waddr = ext_load_addr_i;
            cur_i_3_wdata = ext_load_data_i;

            cur_i_3_ren   = 'b0;
            cur_i_3_sel   = 'b0;
            cur_i_3_size  = 'b0;
            cur_i_3_4x4_x = 'b0;
            cur_i_3_4x4_y = 'b0;
            cur_i_3_idx   = 'b0;
        end
        'd4: begin
            cur_i_3_wen   = 'b0;
            cur_i_3_waddr = 'b0;
            cur_i_3_wdata = 'b0;

            cur_i_3_ren   = prei_cur_rden_i    ;
            cur_i_3_sel   = prei_cur_sel_i     ;
            cur_i_3_size  = prei_cur_size_i    ;
            cur_i_3_4x4_x = prei_cur_4x4_x_i   ;
            cur_i_3_4x4_y = prei_cur_4x4_y_i   ;
            cur_i_3_idx   = prei_cur_4x4_idx_i ;
        end
        default: begin
            cur_i_3_wen   = 'b0;
            cur_i_3_waddr = 'b0;
            cur_i_3_wdata = 'b0;

            cur_i_3_ren   = 'b0;
            cur_i_3_sel   = 'b0;
            cur_i_3_size  = 'b0;
            cur_i_3_4x4_x = 'b0;
            cur_i_3_4x4_y = 'b0;
            cur_i_3_idx   = 'b0;
        end
    endcase
end

// cur_i_4
always @ (*) begin
    case (rotate_i)
        'd0: begin
            cur_i_4_wen   = 'b0;
            cur_i_4_waddr = 'b0;
            cur_i_4_wdata = 'b0;

            cur_i_4_ren   = prei_cur_rden_i    ;
            cur_i_4_sel   = prei_cur_sel_i     ;
            cur_i_4_size  = prei_cur_size_i    ;
            cur_i_4_4x4_x = prei_cur_4x4_x_i   ;
            cur_i_4_4x4_y = prei_cur_4x4_y_i   ;
            cur_i_4_idx   = prei_cur_4x4_idx_i ;
        end
        'd1: begin
            cur_i_4_wen   = 'b0;
            cur_i_4_waddr = 'b0;
            cur_i_4_wdata = 'b0;

            cur_i_4_ren   = posi_cur_rden_i    ;
            cur_i_4_sel   = posi_cur_sel_i     ;
            cur_i_4_size  = posi_cur_size_i    ;
            cur_i_4_4x4_x = posi_cur_4x4_x_i   ;
            cur_i_4_4x4_y = posi_cur_4x4_y_i   ;
            cur_i_4_idx   = posi_cur_4x4_idx_i ;
        end
        'd2: begin
            cur_i_4_wen   = 'b0;
            cur_i_4_waddr = 'b0;
            cur_i_4_wdata = 'b0;

            cur_i_4_ren   = rec_cur_rden_i;
            cur_i_4_sel   = rec_cur_sel_i ;
            cur_i_4_size  = rec_cur_size_i;
            cur_i_4_4x4_x = rec_cur_4x4_x_i;
            cur_i_4_4x4_y = rec_cur_4x4_y_i;
            cur_i_4_idx   = rec_cur_4x4_idx_i;
        end
        'd3: begin
            cur_i_4_wen   = 'b0;
            cur_i_4_waddr = 'b0;
            cur_i_4_wdata = 'b0;

            cur_i_4_ren   = db_cur_rden_i;
            cur_i_4_sel   = db_cur_sel_i ;
            cur_i_4_size  = db_cur_size_i;
            cur_i_4_4x4_x = db_cur_4x4_x_i;
            cur_i_4_4x4_y = db_cur_4x4_y_i;
            cur_i_4_idx   = db_cur_4x4_idx_i;
        end
        'd4: begin
            cur_i_4_wen   = ext_load_valid_i;
            cur_i_4_waddr = ext_load_addr_i;
            cur_i_4_wdata = ext_load_data_i;

            cur_i_4_ren   = 'b0;
            cur_i_4_sel   = 'b0;
            cur_i_4_size  = 'b0;
            cur_i_4_4x4_x = 'b0;
            cur_i_4_4x4_y = 'b0;
            cur_i_4_idx   = 'b0;
        end
        default: begin
            cur_i_4_wen   = 'b0;
            cur_i_4_waddr = 'b0;
            cur_i_4_wdata = 'b0;

            cur_i_4_ren   = 'b0;
            cur_i_4_sel   = 'b0;
            cur_i_4_size  = 'b0;
            cur_i_4_4x4_x = 'b0;
            cur_i_4_4x4_y = 'b0;
            cur_i_4_idx   = 'b0;
        end
    endcase
end

// cur_p_0
always @ (*) begin
    case (rotate_p)
        'd0: begin
            cur_p_0_wen   = ext_load_valid_i;
            cur_p_0_waddr = ext_load_addr_i;
            cur_p_0_wdata = ext_load_data_i;

            cur_p_0_ren   = 0 ;
            cur_p_0_sel   = 0 ;
            cur_p_0_size  = 0 ;
            cur_p_0_4x4_x = 0 ;
            cur_p_0_4x4_y = 0 ;
            cur_p_0_idx   = 0 ;
        end
        'd1: begin
            cur_p_0_wen   = 'b0;
            cur_p_0_waddr = 'b0;
            cur_p_0_wdata = 'b0;

            cur_p_0_ren   = ime_cur_rden_i      ;
            cur_p_0_sel   = ime_cur_sel_i       ;
            cur_p_0_size  = ime_cur_size_i      ;
            cur_p_0_4x4_x = 4'd0                ;
            cur_p_0_4x4_y = ime_cur_4x4_y_i     ;
            cur_p_0_idx   = ime_cur_4x4_idx_i   ;
        end
        'd2: begin
            cur_p_0_wen   = 'b0;
            cur_p_0_waddr = 'b0;
            cur_p_0_wdata = 'b0;

            cur_p_0_ren   = fme_cur_rden_i       ;
            cur_p_0_sel   = fme_cur_sel_i        ;
            cur_p_0_size  = fme_cur_size_i       ;
            cur_p_0_4x4_x = fme_cur_4x4_x_i      ;
            cur_p_0_4x4_y = fme_cur_4x4_y_i      ;
            cur_p_0_idx   = fme_cur_4x4_idx_i    ;
        end
        default: begin
            cur_p_0_wen   = 'b0;
            cur_p_0_waddr = 'b0;
            cur_p_0_wdata = 'b0;

            cur_p_0_ren   = 'b0;
            cur_p_0_sel   = 'b0;
            cur_p_0_size  = 'b0;
            cur_p_0_4x4_x = 'b0;
            cur_p_0_4x4_y = 'b0;
            cur_p_0_idx   = 'b0;
        end
    endcase
end

// cur_p_1
always @ (*) begin
    case (rotate_p)
        'd0: begin
            cur_p_1_wen   = 'b0; 
            cur_p_1_waddr = 'b0; 
            cur_p_1_wdata = 'b0; 

            cur_p_1_ren   = fme_cur_rden_i      ;
            cur_p_1_sel   = fme_cur_sel_i       ;
            cur_p_1_size  = fme_cur_size_i      ;
            cur_p_1_4x4_x = fme_cur_4x4_x_i     ;
            cur_p_1_4x4_y = fme_cur_4x4_y_i     ;
            cur_p_1_idx   = fme_cur_4x4_idx_i   ;
        end
        'd1: begin
            cur_p_1_wen   = ext_load_valid_i;
            cur_p_1_waddr = ext_load_addr_i;
            cur_p_1_wdata = ext_load_data_i;

            cur_p_1_ren   = 0 ;
            cur_p_1_sel   = 0 ;
            cur_p_1_size  = 0 ;
            cur_p_1_4x4_x = 0 ;
            cur_p_1_4x4_y = 0 ;
            cur_p_1_idx   = 0 ;
        end
        'd2: begin
            cur_p_1_wen   = 'b0;
            cur_p_1_waddr = 'b0;
            cur_p_1_wdata = 'b0;

            cur_p_1_ren   = ime_cur_rden_i      ;
            cur_p_1_sel   = ime_cur_sel_i       ;
            cur_p_1_size  = ime_cur_size_i      ;
            cur_p_1_4x4_x = 4'd0                ;
            cur_p_1_4x4_y = ime_cur_4x4_y_i     ;
            cur_p_1_idx   = ime_cur_4x4_idx_i   ;
        end
        default: begin
            cur_p_1_wen   = 'b0;
            cur_p_1_waddr = 'b0;
            cur_p_1_wdata = 'b0;

            cur_p_1_ren   = 'b0;
            cur_p_1_sel   = 'b0;
            cur_p_1_size  = 'b0;
            cur_p_1_4x4_x = 'b0;
            cur_p_1_4x4_y = 'b0;
            cur_p_1_idx   = 'b0;
        end
    endcase
end

// cur_p_2
always @ (*) begin
    case (rotate_p)
        'd0: begin
            cur_p_2_wen   = 'b0;
            cur_p_2_waddr = 'b0;
            cur_p_2_wdata = 'b0;

            cur_p_2_ren   = ime_cur_rden_i      ;
            cur_p_2_sel   = ime_cur_sel_i       ;
            cur_p_2_size  = ime_cur_size_i      ;
            cur_p_2_4x4_x = 4'd0                ;
            cur_p_2_4x4_y = ime_cur_4x4_y_i     ;
            cur_p_2_idx   = ime_cur_4x4_idx_i   ;
        end
        'd1: begin
            cur_p_2_wen   = 'b0;
            cur_p_2_waddr = 'b0;
            cur_p_2_wdata = 'b0;

            cur_p_2_ren   = fme_cur_rden_i      ;
            cur_p_2_sel   = fme_cur_sel_i       ;
            cur_p_2_size  = fme_cur_size_i      ;
            cur_p_2_4x4_x = fme_cur_4x4_x_i     ;
            cur_p_2_4x4_y = fme_cur_4x4_y_i     ;
            cur_p_2_idx   = fme_cur_4x4_idx_i   ;
        end
        'd2: begin
            cur_p_2_wen   = ext_load_valid_i;
            cur_p_2_waddr = ext_load_addr_i;
            cur_p_2_wdata = ext_load_data_i;

            cur_p_2_ren   = 0 ;
            cur_p_2_sel   = 0 ;
            cur_p_2_size  = 0 ;
            cur_p_2_4x4_x = 0 ;
            cur_p_2_4x4_y = 0 ;
            cur_p_2_idx   = 0 ;
        end
        default: begin
            cur_p_2_wen   = 'b0;
            cur_p_2_waddr = 'b0;
            cur_p_2_wdata = 'b0;

            cur_p_2_ren   = 'b0;
            cur_p_2_sel   = 'b0;
            cur_p_2_size  = 'b0;
            cur_p_2_4x4_x = 'b0;
            cur_p_2_4x4_y = 'b0;
            cur_p_2_idx   = 'b0;
        end
    endcase
end

// cur_ime_0
always @ (*) begin
    case (rotate_ime)
        'd0: begin
            cur_ime_0_wen   = ext_load_valid_i;
            cur_ime_0_waddr = ext_load_addr_i ;
            cur_ime_0_wdata = ext_load_data_i ;

            cur_ime_0_ren   = 'b0 ;
            cur_ime_0_sel   = 'b0 ;
            cur_ime_0_size  = 'b0 ;
            cur_ime_0_4x4_x = 'b0 ;
            cur_ime_0_4x4_y = 'b0 ;
            cur_ime_0_idx   = 'b0 ;
        end
        'd1: begin
            cur_ime_0_wen   = 'b0;
            cur_ime_0_waddr = 'b0;
            cur_ime_0_wdata = 'b0;

            cur_ime_0_ren   = ime_cur_rden_i      ;
            cur_ime_0_sel   = ime_cur_sel_i       ;
            cur_ime_0_size  = ime_cur_size_i      ;
            cur_ime_0_4x4_x = 4'd8                ;
            cur_ime_0_4x4_y = ime_cur_4x4_y_i     ;
            cur_ime_0_idx   = ime_cur_4x4_idx_i   ;
        end
        default: begin
            cur_ime_0_wen   = 'b0;
            cur_ime_0_waddr = 'b0;
            cur_ime_0_wdata = 'b0;

            cur_ime_0_ren   = 'b0;
            cur_ime_0_sel   = 'b0;
            cur_ime_0_size  = 'b0;
            cur_ime_0_4x4_x = 'b0;
            cur_ime_0_4x4_y = 'b0;
            cur_ime_0_idx   = 'b0;
        end
    endcase
end

// cur_ime_1
always @ (*) begin
    case (rotate_ime)
        'd0: begin
            cur_ime_1_wen   = 'b0; 
            cur_ime_1_waddr = 'b0; 
            cur_ime_1_wdata = 'b0; 

            cur_ime_1_ren   = ime_cur_rden_i      ;
            cur_ime_1_sel   = ime_cur_sel_i       ;
            cur_ime_1_size  = ime_cur_size_i      ;
            cur_ime_1_4x4_x = 4'd8                ;
            cur_ime_1_4x4_y = ime_cur_4x4_y_i     ;
            cur_ime_1_idx   = ime_cur_4x4_idx_i   ;
        end
        'd1: begin
            cur_ime_1_wen   = ext_load_valid_i;
            cur_ime_1_waddr = ext_load_addr_i;
            cur_ime_1_wdata = ext_load_data_i;

            cur_ime_1_ren   = 'b0 ;
            cur_ime_1_sel   = 'b0 ;
            cur_ime_1_size  = 'b0 ;
            cur_ime_1_4x4_x = 'b0 ;
            cur_ime_1_4x4_y = 'b0 ;
            cur_ime_1_idx   = 'b0 ;
        end
        default: begin
            cur_ime_1_wen   = 'b0;
            cur_ime_1_waddr = 'b0;
            cur_ime_1_wdata = 'b0;

            cur_ime_1_ren   = 'b0;
            cur_ime_1_sel   = 'b0;
            cur_ime_1_size  = 'b0;
            cur_ime_1_4x4_x = 'b0;
            cur_ime_1_4x4_y = 'b0;
            cur_ime_1_idx   = 'b0;
        end
    endcase
end


/*
rotate_i | 0         1           2           3           4 
cur_i0   | wr        prei_rd     posi_rd     rec_rd      db_rd
cur_i1   | db_rd     wr          prei_rd     posi_rd     rec_rd 
cur_i2   | rec_rd    db_rd       wr          prei_rd     posi_rd
cur_i3   | posi_rd   rec_rd      db_rd       wr          prei_rd
cur_i4   | prei_rd   posi_rd     rec_rd      db_rd       wr
*/
always @  (*) begin
    case (rotate_i)
        'd0:begin
            prei_cur_pel_o   = cur_i_4_rdata ;
            posi_cur_pel_o   = cur_i_3_rdata ;
            rec_cur_pel_o    = cur_i_2_rdata ;
            db_cur_pel_o     = cur_i_1_rdata ;
        end
        'd1:begin
            prei_cur_pel_o   = cur_i_0_rdata ;
            posi_cur_pel_o   = cur_i_4_rdata ;
            rec_cur_pel_o    = cur_i_3_rdata ;
            db_cur_pel_o     = cur_i_2_rdata ;
        end
        'd2:begin
            prei_cur_pel_o   = cur_i_1_rdata ;
            posi_cur_pel_o   = cur_i_0_rdata ;
            rec_cur_pel_o    = cur_i_4_rdata ;
            db_cur_pel_o     = cur_i_3_rdata ;
        end
        'd3:begin
            prei_cur_pel_o   = cur_i_2_rdata ;
            posi_cur_pel_o   = cur_i_1_rdata ;
            rec_cur_pel_o    = cur_i_0_rdata ;
            db_cur_pel_o     = cur_i_4_rdata ;
        end
        'd4:begin
            prei_cur_pel_o   = cur_i_3_rdata ;
            posi_cur_pel_o   = cur_i_2_rdata ;
            rec_cur_pel_o    = cur_i_1_rdata ;
            db_cur_pel_o     = cur_i_0_rdata ;
        end
        default: begin
            prei_cur_pel_o   = 0 ;
            posi_cur_pel_o   = 0 ;
            rec_cur_pel_o    = 0 ;
            db_cur_pel_o     = 0 ;
        end
    endcase
end

/*
rotate_p | 0        1           2
cur_p0   | wr       ime_rd      fme_rd
cur_p1   | fme_rd   wr          ime_rd
cur_p2   | ime_rd   fme_rd      wr
*/

/*
rotate_ime | 0        1        
cur_ime0   | wr       ime_rd   
cur_ime1   | ime_rd   wr       
*/
always @  (*) begin
    case (rotate_p)
      'd0: fme_cur_pel_o = cur_p_1_rdata ;
      'd1: fme_cur_pel_o = cur_p_2_rdata ;
      'd2: fme_cur_pel_o = cur_p_0_rdata ;
      default : fme_cur_pel_o = 0;
    endcase
end

always @  (*) begin
    case (rotate_p)
      'd0: ime_cur_pel_0 = cur_p_2_rdata ;
      'd1: ime_cur_pel_0 = cur_p_0_rdata ;
      'd2: ime_cur_pel_0 = cur_p_1_rdata ;
      default : ime_cur_pel_0 = 0;
    endcase
end

always @  (*) begin
    case (rotate_ime)
      'd0: ime_cur_pel_1 = cur_ime_1_rdata ;
      'd1: ime_cur_pel_1 = cur_ime_0_rdata ;
      default : ime_cur_pel_1 = 0;
    endcase
end

assign ime_x_minus_width = (ime_cur_x_r + 1)*64 - sys_all_x_i ;

assign ime_cur_pel_w = {ime_cur_pel_0,ime_cur_pel_1} ;

assign ime_cur_adr_y_w = {ime_cur_4x4_y_i[3],ime_cur_4x4_idx_i[4:0]} ;

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
      ime_cur_x_r <= 'd0 ;
      ime_cur_y_r <= 'd0 ;
      ime_cur_4x4_x_r <= 'd0 ;
      ime_cur_adr_y_r <= 'd0 ;
    end
    else begin
      ime_cur_x_r <= ime_cur_x_i ;
      ime_cur_y_r <= ime_cur_y_i ;
      ime_cur_4x4_x_r <= ime_cur_4x4_x_i;
      ime_cur_adr_y_r <= ime_cur_adr_y_w;
    end
end

// always @(*) begin
//   case (ime_x_minus_width[5:3])
//       0      : ime_cur_pel_rshift =  ime_cur_pel_w ;
//       1      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*8 ],{8 {ime_cur_pel_w[`PIXEL_WIDTH*9 -1:`PIXEL_WIDTH*8 ]}}} ;
//       2      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*16],{16{ime_cur_pel_w[`PIXEL_WIDTH*17-1:`PIXEL_WIDTH*16]}}} ;
//       3      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*24],{24{ime_cur_pel_w[`PIXEL_WIDTH*25-1:`PIXEL_WIDTH*24]}}} ;
//       4      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*32],{32{ime_cur_pel_w[`PIXEL_WIDTH*33-1:`PIXEL_WIDTH*32]}}} ;
//       5      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*40],{40{ime_cur_pel_w[`PIXEL_WIDTH*41-1:`PIXEL_WIDTH*40]}}} ;
//       6      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*48],{48{ime_cur_pel_w[`PIXEL_WIDTH*49-1:`PIXEL_WIDTH*48]}}} ;
//       7      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*56],{56{ime_cur_pel_w[`PIXEL_WIDTH*57-1:`PIXEL_WIDTH*56]}}} ;
//       default: ime_cur_pel_rshift =  ime_cur_pel_w ;
//   endcase 
// end

always @(*) begin
  case (ime_x_minus_width[5:3])
      0      : ime_cur_pel_rshift =  ime_cur_pel_w ;
      1      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*8 ],{8 {`PIXEL_WIDTH'd128}}} ;
      2      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*16],{16{`PIXEL_WIDTH'd128}}} ;
      3      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*24],{24{`PIXEL_WIDTH'd128}}} ;
      4      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*32],{32{`PIXEL_WIDTH'd128}}} ;
      5      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*40],{40{`PIXEL_WIDTH'd128}}} ;
      6      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*48],{48{`PIXEL_WIDTH'd128}}} ;
      7      : ime_cur_pel_rshift = {ime_cur_pel_w[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*56],{56{`PIXEL_WIDTH'd128}}} ;
      default: ime_cur_pel_rshift =  ime_cur_pel_w ;
  endcase 
end

assign ime_cur_pel_w0  = (ime_cur_y_r*64+ime_cur_adr_y_r>=sys_all_y_i) ? {64{`PIXEL_WIDTH'd128}} : ( (ime_cur_x_r+1)*64<=sys_all_x_i ? ime_cur_pel_w : ime_cur_pel_rshift ) ;

always @(posedge clk or negedge rstn) begin 
  if(~rstn) begin
    ime_cur_pel_o <= 0;
  end 
  else begin
    if (ime_cur_downsample_i) begin
      ime_cur_pel_o <= {  ime_cur_pel_w0[64*`PIXEL_WIDTH-1:63*`PIXEL_WIDTH], ime_cur_pel_w0[62*`PIXEL_WIDTH-1:61*`PIXEL_WIDTH], ime_cur_pel_w0[60*`PIXEL_WIDTH-1:59*`PIXEL_WIDTH], ime_cur_pel_w0[58*`PIXEL_WIDTH-1:57*`PIXEL_WIDTH], 
                          ime_cur_pel_w0[56*`PIXEL_WIDTH-1:55*`PIXEL_WIDTH], ime_cur_pel_w0[54*`PIXEL_WIDTH-1:53*`PIXEL_WIDTH], ime_cur_pel_w0[52*`PIXEL_WIDTH-1:51*`PIXEL_WIDTH], ime_cur_pel_w0[50*`PIXEL_WIDTH-1:49*`PIXEL_WIDTH],
                          ime_cur_pel_w0[48*`PIXEL_WIDTH-1:47*`PIXEL_WIDTH], ime_cur_pel_w0[46*`PIXEL_WIDTH-1:45*`PIXEL_WIDTH], ime_cur_pel_w0[44*`PIXEL_WIDTH-1:43*`PIXEL_WIDTH], ime_cur_pel_w0[42*`PIXEL_WIDTH-1:41*`PIXEL_WIDTH],
                          ime_cur_pel_w0[40*`PIXEL_WIDTH-1:39*`PIXEL_WIDTH], ime_cur_pel_w0[38*`PIXEL_WIDTH-1:37*`PIXEL_WIDTH], ime_cur_pel_w0[36*`PIXEL_WIDTH-1:35*`PIXEL_WIDTH], ime_cur_pel_w0[34*`PIXEL_WIDTH-1:33*`PIXEL_WIDTH],
                          ime_cur_pel_w0[32*`PIXEL_WIDTH-1:31*`PIXEL_WIDTH], ime_cur_pel_w0[30*`PIXEL_WIDTH-1:29*`PIXEL_WIDTH], ime_cur_pel_w0[28*`PIXEL_WIDTH-1:27*`PIXEL_WIDTH], ime_cur_pel_w0[26*`PIXEL_WIDTH-1:25*`PIXEL_WIDTH], 
                          ime_cur_pel_w0[24*`PIXEL_WIDTH-1:23*`PIXEL_WIDTH], ime_cur_pel_w0[22*`PIXEL_WIDTH-1:21*`PIXEL_WIDTH], ime_cur_pel_w0[20*`PIXEL_WIDTH-1:19*`PIXEL_WIDTH], ime_cur_pel_w0[18*`PIXEL_WIDTH-1:17*`PIXEL_WIDTH],
                          ime_cur_pel_w0[16*`PIXEL_WIDTH-1:15*`PIXEL_WIDTH], ime_cur_pel_w0[14*`PIXEL_WIDTH-1:13*`PIXEL_WIDTH], ime_cur_pel_w0[12*`PIXEL_WIDTH-1:11*`PIXEL_WIDTH], ime_cur_pel_w0[10*`PIXEL_WIDTH-1: 9*`PIXEL_WIDTH],
                          ime_cur_pel_w0[ 8*`PIXEL_WIDTH-1: 7*`PIXEL_WIDTH], ime_cur_pel_w0[ 6*`PIXEL_WIDTH-1: 5*`PIXEL_WIDTH], ime_cur_pel_w0[ 4*`PIXEL_WIDTH-1: 3*`PIXEL_WIDTH], ime_cur_pel_w0[ 2*`PIXEL_WIDTH-1: 1*`PIXEL_WIDTH]
                        } ;
    end
    else begin
      if (ime_cur_4x4_x_r == 4'd0)
        ime_cur_pel_o <= ime_cur_pel_w0[`PIXEL_WIDTH*64-1:`PIXEL_WIDTH*32] ;
      else
        ime_cur_pel_o <= ime_cur_pel_w0[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*0 ] ;        
    end
  end
end

// ********************************************
//
//    Wrapper
//
// ********************************************

mem_lipo_1p_128x64x4  cur_i00 (
    .clk        (clk  ),
    .rst_n      (rstn ),

    .a_wen_i    (cur_i_0_wen  ),
    .a_addr_i   (cur_i_0_waddr),
    .a_wdata_i  (cur_i_0_wdata),

    .b_ren_i    (cur_i_0_ren  ),
    // .b_sel_i    (cur_i_0_sel  ),
    .b_size_i   (cur_i_0_size ),
    .b_4x4_x_i  (cur_i_0_4x4_x),
    .b_4x4_y_i  (cur_i_0_4x4_y),
    .b_idx_i    (cur_i_0_idx  ),
    .b_rdata_o  (cur_i_0_rdata)
);
mem_lipo_1p_128x64x4  cur_i01 (
    .clk        (clk  ),
    .rst_n      (rstn ),

    .a_wen_i    (cur_i_1_wen  ),
    .a_addr_i   (cur_i_1_waddr),
    .a_wdata_i  (cur_i_1_wdata),

    .b_ren_i    (cur_i_1_ren  ),
    // .b_sel_i    (cur_i_1_sel  ),
    .b_size_i   (cur_i_1_size ),
    .b_4x4_x_i  (cur_i_1_4x4_x),
    .b_4x4_y_i  (cur_i_1_4x4_y),
    .b_idx_i    (cur_i_1_idx  ),
    .b_rdata_o  (cur_i_1_rdata)
);
mem_lipo_1p_128x64x4  cur_i02 (
    .clk        (clk  ),
    .rst_n      (rstn ),

    .a_wen_i    (cur_i_2_wen  ),
    .a_addr_i   (cur_i_2_waddr),
    .a_wdata_i  (cur_i_2_wdata),

    .b_ren_i    (cur_i_2_ren  ),
    // .b_sel_i    (cur_i_2_sel  ),
    .b_size_i   (cur_i_2_size ),
    .b_4x4_x_i  (cur_i_2_4x4_x),
    .b_4x4_y_i  (cur_i_2_4x4_y),
    .b_idx_i    (cur_i_2_idx  ),
    .b_rdata_o  (cur_i_2_rdata)
);
mem_lipo_1p_128x64x4  cur_i03 (
    .clk        (clk  ),
    .rst_n      (rstn ),

    .a_wen_i    (cur_i_3_wen  ),
    .a_addr_i   (cur_i_3_waddr),
    .a_wdata_i  (cur_i_3_wdata),

    .b_ren_i    (cur_i_3_ren  ),
    // .b_sel_i    (cur_i_3_sel  ),
    .b_size_i   (cur_i_3_size ),
    .b_4x4_x_i  (cur_i_3_4x4_x),
    .b_4x4_y_i  (cur_i_3_4x4_y),
    .b_idx_i    (cur_i_3_idx  ),
    .b_rdata_o  (cur_i_3_rdata)
);
mem_lipo_1p_128x64x4  cur_i04 (
    .clk        (clk  ),
    .rst_n      (rstn ),

    .a_wen_i    (cur_i_4_wen  ),
    .a_addr_i   (cur_i_4_waddr),
    .a_wdata_i  (cur_i_4_wdata),

    .b_ren_i    (cur_i_4_ren  ),
    // .b_sel_i    (cur_i_4_sel  ),
    .b_size_i   (cur_i_4_size ),
    .b_4x4_x_i  (cur_i_4_4x4_x),
    .b_4x4_y_i  (cur_i_4_4x4_y),
    .b_idx_i    (cur_i_4_idx  ),
    .b_rdata_o  (cur_i_4_rdata)
);

mem_lipo_1p_128x64x4  cur_p00 (
    .clk        (clk  ),
    .rst_n      (rstn ),

    .a_wen_i    (cur_p_0_wen  ),
    .a_addr_i   (cur_p_0_waddr),
    .a_wdata_i  (cur_p_0_wdata),

    .b_ren_i    (cur_p_0_ren  ),
    // .b_sel_i    (cur_p_0_sel  ),
    .b_size_i   (cur_p_0_size ),
    .b_4x4_x_i  (cur_p_0_4x4_x),
    .b_4x4_y_i  (cur_p_0_4x4_y),
    .b_idx_i    (cur_p_0_idx  ),
    .b_rdata_o  (cur_p_0_rdata)
);
mem_lipo_1p_128x64x4  cur_p01 (
    .clk        (clk  ),
    .rst_n      (rstn ),

    .a_wen_i    (cur_p_1_wen  ),
    .a_addr_i   (cur_p_1_waddr),
    .a_wdata_i  (cur_p_1_wdata),

    .b_ren_i    (cur_p_1_ren  ),
    // .b_sel_i    (cur_p_1_sel  ),
    .b_size_i   (cur_p_1_size ),
    .b_4x4_x_i  (cur_p_1_4x4_x),
    .b_4x4_y_i  (cur_p_1_4x4_y),
    .b_idx_i    (cur_p_1_idx  ),
    .b_rdata_o  (cur_p_1_rdata)
);
mem_lipo_1p_128x64x4  cur_p02 (
    .clk        (clk  ),
    .rst_n      (rstn ),

    .a_wen_i    (cur_p_2_wen  ),
    .a_addr_i   (cur_p_2_waddr),
    .a_wdata_i  (cur_p_2_wdata),

    .b_ren_i    (cur_p_2_ren  ),
    // .b_sel_i    (cur_p_2_sel  ),
    .b_size_i   (cur_p_2_size ),
    .b_4x4_x_i  (cur_p_2_4x4_x),
    .b_4x4_y_i  (cur_p_2_4x4_y),
    .b_idx_i    (cur_p_2_idx  ),
    .b_rdata_o  (cur_p_2_rdata)
  );

mem_lipo_1p_128x64x4  cur_ime00 (
    .clk        (clk  ),
    .rst_n      (rstn ),

    .a_wen_i    (cur_ime_0_wen  ),
    .a_addr_i   (cur_ime_0_waddr),
    .a_wdata_i  (cur_ime_0_wdata),

    .b_ren_i    (cur_ime_0_ren  ),
    // .b_sel_i    (cur_ime_0_sel  ),
    .b_size_i   (cur_ime_0_size ),
    .b_4x4_x_i  (cur_ime_0_4x4_x),
    .b_4x4_y_i  (cur_ime_0_4x4_y),
    .b_idx_i    (cur_ime_0_idx  ),
    .b_rdata_o  (cur_ime_0_rdata)
);
mem_lipo_1p_128x64x4  cur_ime01 (
    .clk        (clk  ),
    .rst_n      (rstn ),

    .a_wen_i    (cur_ime_1_wen  ),
    .a_addr_i   (cur_ime_1_waddr),
    .a_wdata_i  (cur_ime_1_wdata),

    .b_ren_i    (cur_ime_1_ren  ),
    // .b_sel_i    (cur_ime_1_sel  ),
    .b_size_i   (cur_ime_1_size ),
    .b_4x4_x_i  (cur_ime_1_4x4_x),
    .b_4x4_y_i  (cur_ime_1_4x4_y),
    .b_idx_i    (cur_ime_1_idx  ),
    .b_rdata_o  (cur_ime_1_rdata)
);

endmodule

