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
//  Filename      : fetch_ref_luma.v
//  Author        : Yufeng Bai
//  Email         : byfchina@gmail.com    
//
//-------------------------------------------------------------------
//
//  Modified      : 2015-08-20 by HLL
//  Description   : fme_ref_x and ime_ref_x logic corrected
//  Modified      : 2015-09-02 by HLL
//  Description   : rotate by sysif_start_i
//  Modified      : 2018-05-18 by GCH
//  Description   : search window changed to 192x128
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fetch_ref_luma (
    clk              ,
    rstn             ,
    sysif_start_i    ,

    sys_all_x_i      ,
    sys_all_y_i      ,
    sys_ctu_all_x_i  ,
    sys_ctu_all_y_i  ,

    extif_width_i    ,
    extif_mode_i     ,

    ime_cur_x_i      ,
    ime_cur_y_i      ,
    ime_cur_downsample_i ,

    ime_ref_x_i      ,
    ime_ref_y_i      ,
    ime_ref_rden_i   ,
    ime_ref_pel_o    ,

    fme_cur_x_i      ,
    fme_cur_y_i      ,

    fme_ref_x_i      ,
    fme_ref_y_i      ,
    fme_ref_rden_i   ,
    fme_ref_pel_o    ,

    ext_load_done_i  ,
    ext_load_data_i  ,
    ext_load_addr_i  ,
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
    
input       [`PIC_X_WIDTH-1   : 0] ime_cur_x_i         ;
input       [`PIC_Y_WIDTH-1   : 0] ime_cur_y_i         ;
input       [1-1:0]                ime_cur_downsample_i; // ime current downsample sel
    
input       [`IME_MV_WIDTH_X  : 0] ime_ref_x_i         ; // ime ref x 
input       [`IME_MV_WIDTH_Y  : 0] ime_ref_y_i         ; // ime ref y 
input       [1-1:0]                ime_ref_rden_i      ; // ime ref read enable 
output reg  [32 *`PIXEL_WIDTH-1:0] ime_ref_pel_o       ; // ime ref pixel 
    
input       [`PIC_X_WIDTH-1   : 0] fme_cur_x_i         ;
input       [`PIC_Y_WIDTH-1   : 0] fme_cur_y_i         ;
    
input       [8-1:0]                fme_ref_x_i         ; // fme ref x 
input       [8-1:0]                fme_ref_y_i         ; // fme ref y 
input       [1-1:0]                fme_ref_rden_i      ; // fme ref read enable 
output reg  [64 *`PIXEL_WIDTH-1:0] fme_ref_pel_o       ; // fme ref pixel 

input       [1-1:0]                ext_load_done_i     ; // load current lcu done 
input       [128*`PIXEL_WIDTH-1:0] ext_load_data_i     ; // load current lcu data 
input       [7-1:0]                ext_load_addr_i     ;
input       [1-1:0]                ext_load_valid_i    ; // load current lcu data valid 

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

reg         [2-1:0]                rotate_ime           ;
reg         [3-1:0]                rotate_fme           ;
    
reg         [192*`PIXEL_WIDTH-1:0] ime_ref_pel_w        ;
reg         [192*`PIXEL_WIDTH-1:0] fme_ref_pel_w        ;
    
reg         [`IME_MV_WIDTH_X   :0] ime_ref_x            ; // ime ref x 
reg         [`IME_MV_WIDTH_Y   :0] ime_ref_y            ; // ime ref y 

reg         [8-1:0]                fme_ref_x            ; // ime ref x 
reg         [7-1:0]                fme_ref_y            ; // fme ref y 
    
wire        [8-1:0]                ime_x_minus_width    ;
wire        [192*`PIXEL_WIDTH-1:0] ime_ref_pel_lshift   ;
reg         [192*`PIXEL_WIDTH-1:0] ime_ref_pel_rshift   ;
wire        [192*`PIXEL_WIDTH-1:0] ime_ref_pel_w0       ;
wire        [192*`PIXEL_WIDTH-1:0] ime_ref_pel_w1       ;
wire        [32 *`PIXEL_WIDTH-1:0] ime_ref_pel_w2       ;
wire        [32 *`PIXEL_WIDTH-1:0] ime_ref_pel_nor      ;
wire        [32 *`PIXEL_WIDTH-1:0] ime_ref_pel_dow      ;

wire        [8-1:0]                fme_x_minus_width    ;
wire        [192*`PIXEL_WIDTH-1:0] fme_ref_pel_lshift   ;
reg         [192*`PIXEL_WIDTH-1:0] fme_ref_pel_rshift   ;
wire        [192*`PIXEL_WIDTH-1:0] fme_ref_pel_w0       ;
wire        [192*`PIXEL_WIDTH-1:0] fme_ref_pel_w1       ;
wire        [64 *`PIXEL_WIDTH-1:0] fme_ref_pel_w2       ;

reg         [1-1:0]                ref_luma_ime00_wen   ;   
reg         [7-1:0]                ref_luma_ime00_waddr ;
reg         [64 *`PIXEL_WIDTH-1:0] ref_luma_ime00_wdata ;
reg         [1-1:0]                ref_luma_ime00_rden  ;
reg         [7-1:0]                ref_luma_ime00_raddr ;
wire        [64 *`PIXEL_WIDTH-1:0] ref_luma_ime00_rdata ;

reg         [1-1:0]                ref_luma_ime01_wen   ;   
reg         [7-1:0]                ref_luma_ime01_waddr ;
reg         [64 *`PIXEL_WIDTH-1:0] ref_luma_ime01_wdata ;
reg         [1-1:0]                ref_luma_ime01_rden  ;
reg         [7-1:0]                ref_luma_ime01_raddr ;
wire        [64 *`PIXEL_WIDTH-1:0] ref_luma_ime01_rdata ;

reg         [1-1:0]                ref_luma_ime02_wen   ;   
reg         [7-1:0]                ref_luma_ime02_waddr ;
reg         [64 *`PIXEL_WIDTH-1:0] ref_luma_ime02_wdata ;
reg         [1-1:0]                ref_luma_ime02_rden  ;
reg         [7-1:0]                ref_luma_ime02_raddr ;
wire        [64 *`PIXEL_WIDTH-1:0] ref_luma_ime02_rdata ;

reg         [1-1:0]                ref_luma_ime03_wen   ;   
reg         [7-1:0]                ref_luma_ime03_waddr ;
reg         [64 *`PIXEL_WIDTH-1:0] ref_luma_ime03_wdata ;
reg         [1-1:0]                ref_luma_ime03_rden  ;
reg         [7-1:0]                ref_luma_ime03_raddr ;
wire        [64 *`PIXEL_WIDTH-1:0] ref_luma_ime03_rdata ;

reg         [1-1:0]                ref_luma_fme00_wen   ;   
reg         [7-1:0]                ref_luma_fme00_waddr ;
reg         [64 *`PIXEL_WIDTH-1:0] ref_luma_fme00_wdata ;
reg         [1-1:0]                ref_luma_fme00_rden  ;
reg         [7-1:0]                ref_luma_fme00_raddr ;
wire        [64 *`PIXEL_WIDTH-1:0] ref_luma_fme00_rdata ;

reg         [1-1:0]                ref_luma_fme01_wen   ;   
reg         [7-1:0]                ref_luma_fme01_waddr ;
reg         [64 *`PIXEL_WIDTH-1:0] ref_luma_fme01_wdata ;
reg         [1-1:0]                ref_luma_fme01_rden  ;
reg         [7-1:0]                ref_luma_fme01_raddr ;
wire        [64 *`PIXEL_WIDTH-1:0] ref_luma_fme01_rdata ;

reg         [1-1:0]                ref_luma_fme02_wen   ;   
reg         [7-1:0]                ref_luma_fme02_waddr ;
reg         [64 *`PIXEL_WIDTH-1:0] ref_luma_fme02_wdata ;
reg         [1-1:0]                ref_luma_fme02_rden  ;
reg         [7-1:0]                ref_luma_fme02_raddr ;
wire        [64 *`PIXEL_WIDTH-1:0] ref_luma_fme02_rdata ;

reg         [1-1:0]                ref_luma_fme03_wen   ;   
reg         [7-1:0]                ref_luma_fme03_waddr ;
reg         [64 *`PIXEL_WIDTH-1:0] ref_luma_fme03_wdata ;
reg         [1-1:0]                ref_luma_fme03_rden  ;
reg         [7-1:0]                ref_luma_fme03_raddr ;
wire        [64 *`PIXEL_WIDTH-1:0] ref_luma_fme03_rdata ;

reg         [1-1:0]                ref_luma_fme04_wen   ;   
reg         [7-1:0]                ref_luma_fme04_waddr ;
reg         [64 *`PIXEL_WIDTH-1:0] ref_luma_fme04_wdata ;
reg         [1-1:0]                ref_luma_fme04_rden  ;
reg         [7-1:0]                ref_luma_fme04_raddr ;
wire        [64 *`PIXEL_WIDTH-1:0] ref_luma_fme04_rdata ;

// ********************************************
//
//    Output Logic
//
// ********************************************

  always @ (posedge clk or negedge rstn) begin
    if ( !rstn ) begin
      ime_ref_pel_o <= 'd0 ;
    end
    else begin
      ime_ref_pel_o <= ime_ref_pel_w2 ;
    end
  end

  always @ (posedge clk or negedge rstn) begin
    if ( !rstn ) begin
      fme_ref_pel_o <= 'd0 ;
    end
    else begin
      fme_ref_pel_o <= fme_ref_pel_w2 ;
    end
  end

// ********************************************
//
//   Addressing Logic
//
// ********************************************
  always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
      ime_ref_x <= 'd0;
      fme_ref_x <= 'd0;
    end
    else begin
      ime_ref_x <= ime_ref_x_i;
      fme_ref_x <= fme_ref_x_i;
    end
  end

  always @ (posedge clk or negedge rstn) begin
    if( !rstn )
      rotate_ime <= 0 ;
    else if( sysif_start_i ) begin
      if( rotate_ime == 3 )
        rotate_ime <= 0 ;
      else
        rotate_ime <= rotate_ime + 1 ;
    end
  end

  always @ (posedge clk or negedge rstn) begin
    if( !rstn )
      rotate_fme <= 0 ;
    else if( sysif_start_i ) begin
      if ( rotate_fme == 4 ) 
        rotate_fme <= 0 ;
      else 
        rotate_fme <= rotate_fme + 1 ;
    end
  end

  assign ime_x_minus_width = (ime_cur_x_i + 2)*64 - sys_all_x_i ;

  assign ime_ref_pel_lshift = {{64{ime_ref_pel_w[`PIXEL_WIDTH*128-1:`PIXEL_WIDTH*127]}},ime_ref_pel_w[`PIXEL_WIDTH*128-1:`PIXEL_WIDTH*0]};

  always @(*) begin
    case (ime_x_minus_width[6:3])
        0      : ime_ref_pel_rshift =  ime_ref_pel_w ;
        1      : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*8  ],{8  {ime_ref_pel_w[`PIXEL_WIDTH*9  -1:`PIXEL_WIDTH*8  ]}}} ;
        2      : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*16 ],{16 {ime_ref_pel_w[`PIXEL_WIDTH*17 -1:`PIXEL_WIDTH*16 ]}}} ;
        3      : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*24 ],{24 {ime_ref_pel_w[`PIXEL_WIDTH*25 -1:`PIXEL_WIDTH*24 ]}}} ;
        4      : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*32 ],{32 {ime_ref_pel_w[`PIXEL_WIDTH*33 -1:`PIXEL_WIDTH*32 ]}}} ;
        5      : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*40 ],{40 {ime_ref_pel_w[`PIXEL_WIDTH*41 -1:`PIXEL_WIDTH*40 ]}}} ;
        6      : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*48 ],{48 {ime_ref_pel_w[`PIXEL_WIDTH*49 -1:`PIXEL_WIDTH*48 ]}}} ;
        7      : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*56 ],{56 {ime_ref_pel_w[`PIXEL_WIDTH*57 -1:`PIXEL_WIDTH*56 ]}}} ;
        8      : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*64 ],{64 {ime_ref_pel_w[`PIXEL_WIDTH*65 -1:`PIXEL_WIDTH*64 ]}}} ;
        9      : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*72 ],{72 {ime_ref_pel_w[`PIXEL_WIDTH*73 -1:`PIXEL_WIDTH*72 ]}}} ;
        10     : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*80 ],{80 {ime_ref_pel_w[`PIXEL_WIDTH*81 -1:`PIXEL_WIDTH*80 ]}}} ;
        11     : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*88 ],{88 {ime_ref_pel_w[`PIXEL_WIDTH*89 -1:`PIXEL_WIDTH*88 ]}}} ;
        12     : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*96 ],{96 {ime_ref_pel_w[`PIXEL_WIDTH*97 -1:`PIXEL_WIDTH*96 ]}}} ;
        13     : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*104],{104{ime_ref_pel_w[`PIXEL_WIDTH*105-1:`PIXEL_WIDTH*104]}}} ;
        14     : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*112],{112{ime_ref_pel_w[`PIXEL_WIDTH*113-1:`PIXEL_WIDTH*112]}}} ;
        15     : ime_ref_pel_rshift = {ime_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*120],{120{ime_ref_pel_w[`PIXEL_WIDTH*121-1:`PIXEL_WIDTH*120]}}} ;
        default: ime_ref_pel_rshift =  ime_ref_pel_w ;
    endcase 
  end

  assign ime_ref_pel_w0  = ime_cur_x_i == 0 ? ime_ref_pel_lshift : ((ime_cur_x_i+2)*64<=sys_all_x_i ? ime_ref_pel_w : ime_ref_pel_rshift) ;
  assign ime_ref_pel_w1  = ime_ref_pel_w0 << ({ime_ref_x,3'b0}) ;
  assign ime_ref_pel_nor = ime_ref_pel_w1[192*`PIXEL_WIDTH-1 :160*`PIXEL_WIDTH] ;
  assign ime_ref_pel_dow = { ime_ref_pel_w1[192*`PIXEL_WIDTH-1 :191*`PIXEL_WIDTH], ime_ref_pel_w1[190*`PIXEL_WIDTH-1 :189*`PIXEL_WIDTH], ime_ref_pel_w1[188*`PIXEL_WIDTH-1 :187*`PIXEL_WIDTH], ime_ref_pel_w1[186*`PIXEL_WIDTH-1 :185*`PIXEL_WIDTH], ime_ref_pel_w1[184*`PIXEL_WIDTH-1 :183*`PIXEL_WIDTH], 
                             ime_ref_pel_w1[182*`PIXEL_WIDTH-1 :181*`PIXEL_WIDTH], ime_ref_pel_w1[180*`PIXEL_WIDTH-1 :179*`PIXEL_WIDTH], ime_ref_pel_w1[178*`PIXEL_WIDTH-1 :177*`PIXEL_WIDTH], ime_ref_pel_w1[176*`PIXEL_WIDTH-1 :175*`PIXEL_WIDTH], ime_ref_pel_w1[174*`PIXEL_WIDTH-1 :173*`PIXEL_WIDTH], 
                             ime_ref_pel_w1[172*`PIXEL_WIDTH-1 :171*`PIXEL_WIDTH], ime_ref_pel_w1[170*`PIXEL_WIDTH-1 :169*`PIXEL_WIDTH], ime_ref_pel_w1[168*`PIXEL_WIDTH-1 :167*`PIXEL_WIDTH], ime_ref_pel_w1[166*`PIXEL_WIDTH-1 :165*`PIXEL_WIDTH], ime_ref_pel_w1[164*`PIXEL_WIDTH-1 :163*`PIXEL_WIDTH], 
                             ime_ref_pel_w1[162*`PIXEL_WIDTH-1 :161*`PIXEL_WIDTH], ime_ref_pel_w1[160*`PIXEL_WIDTH-1 :159*`PIXEL_WIDTH], ime_ref_pel_w1[158*`PIXEL_WIDTH-1 :157*`PIXEL_WIDTH], ime_ref_pel_w1[156*`PIXEL_WIDTH-1 :155*`PIXEL_WIDTH], ime_ref_pel_w1[154*`PIXEL_WIDTH-1 :153*`PIXEL_WIDTH], 
                             ime_ref_pel_w1[152*`PIXEL_WIDTH-1 :151*`PIXEL_WIDTH], ime_ref_pel_w1[150*`PIXEL_WIDTH-1 :149*`PIXEL_WIDTH], ime_ref_pel_w1[148*`PIXEL_WIDTH-1 :147*`PIXEL_WIDTH], ime_ref_pel_w1[146*`PIXEL_WIDTH-1 :145*`PIXEL_WIDTH], ime_ref_pel_w1[144*`PIXEL_WIDTH-1 :143*`PIXEL_WIDTH], 
                             ime_ref_pel_w1[142*`PIXEL_WIDTH-1 :141*`PIXEL_WIDTH], ime_ref_pel_w1[140*`PIXEL_WIDTH-1 :139*`PIXEL_WIDTH], ime_ref_pel_w1[138*`PIXEL_WIDTH-1 :137*`PIXEL_WIDTH], ime_ref_pel_w1[136*`PIXEL_WIDTH-1 :135*`PIXEL_WIDTH], ime_ref_pel_w1[134*`PIXEL_WIDTH-1 :133*`PIXEL_WIDTH], 
                             ime_ref_pel_w1[132*`PIXEL_WIDTH-1 :131*`PIXEL_WIDTH], ime_ref_pel_w1[130*`PIXEL_WIDTH-1 :129*`PIXEL_WIDTH] };
  assign ime_ref_pel_w2  = ime_cur_downsample_i ? ime_ref_pel_dow : ime_ref_pel_nor;

  always @ (*) begin
      if(ime_cur_y_i  == 'd0)
          ime_ref_y = (ime_ref_y_i < 'd32) ? 'd0 : (ime_ref_y_i - 'd32);
      else if(ime_cur_y_i*64 + ime_ref_y_i - 'd32 > sys_all_y_i - 'd1)
          ime_ref_y = sys_all_y_i - 'd1 - ime_cur_y_i*64 + 'd32 ;
      else
          ime_ref_y = ime_ref_y_i ;
  end

  assign fme_x_minus_width = (fme_cur_x_i + 2)*64 - sys_all_x_i ;

  assign fme_ref_pel_lshift = {{64{fme_ref_pel_w[`PIXEL_WIDTH*128-1:`PIXEL_WIDTH*127]}},fme_ref_pel_w[`PIXEL_WIDTH*128-1:`PIXEL_WIDTH*0]};

  always @(*) begin
    case (fme_x_minus_width[6:3]) 
        0 :     fme_ref_pel_rshift =  fme_ref_pel_w ;
        1 :     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*8  ],{8  {fme_ref_pel_w[`PIXEL_WIDTH*9  -1:`PIXEL_WIDTH*8  ]}}} ;
        2 :     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*16 ],{16 {fme_ref_pel_w[`PIXEL_WIDTH*17 -1:`PIXEL_WIDTH*16 ]}}} ;
        3 :     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*24 ],{24 {fme_ref_pel_w[`PIXEL_WIDTH*25 -1:`PIXEL_WIDTH*24 ]}}} ;
        4 :     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*32 ],{32 {fme_ref_pel_w[`PIXEL_WIDTH*33 -1:`PIXEL_WIDTH*32 ]}}} ;
        5 :     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*40 ],{40 {fme_ref_pel_w[`PIXEL_WIDTH*41 -1:`PIXEL_WIDTH*40 ]}}} ;
        6 :     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*48 ],{48 {fme_ref_pel_w[`PIXEL_WIDTH*49 -1:`PIXEL_WIDTH*48 ]}}} ;
        7 :     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*56 ],{56 {fme_ref_pel_w[`PIXEL_WIDTH*57 -1:`PIXEL_WIDTH*56 ]}}} ;
        8 :     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*64 ],{64 {fme_ref_pel_w[`PIXEL_WIDTH*65 -1:`PIXEL_WIDTH*64 ]}}} ;
        9 :     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*72 ],{72 {fme_ref_pel_w[`PIXEL_WIDTH*73 -1:`PIXEL_WIDTH*72 ]}}} ;
        10:     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*80 ],{80 {fme_ref_pel_w[`PIXEL_WIDTH*81 -1:`PIXEL_WIDTH*80 ]}}} ;
        11:     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*88 ],{88 {fme_ref_pel_w[`PIXEL_WIDTH*89 -1:`PIXEL_WIDTH*88 ]}}} ;
        12:     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*96 ],{96 {fme_ref_pel_w[`PIXEL_WIDTH*97 -1:`PIXEL_WIDTH*96 ]}}} ;
        13:     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*104],{104{fme_ref_pel_w[`PIXEL_WIDTH*105-1:`PIXEL_WIDTH*104]}}} ;
        14:     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*112],{112{fme_ref_pel_w[`PIXEL_WIDTH*113-1:`PIXEL_WIDTH*112]}}} ;
        15:     fme_ref_pel_rshift = {fme_ref_pel_w[`PIXEL_WIDTH*192-1:`PIXEL_WIDTH*120],{120{fme_ref_pel_w[`PIXEL_WIDTH*121-1:`PIXEL_WIDTH*120]}}} ;
        default:fme_ref_pel_rshift =  fme_ref_pel_w ;
    endcase 
  end

  assign fme_ref_pel_w0  = fme_cur_x_i == 0 ? fme_ref_pel_lshift : ((fme_cur_x_i+2)*64<=sys_all_x_i ? fme_ref_pel_w : fme_ref_pel_rshift) ;
  assign fme_ref_pel_w1  = fme_ref_pel_w0 << ({fme_ref_x,3'b0}) ;
  assign fme_ref_pel_w2  = fme_ref_pel_w1[192*`PIXEL_WIDTH-1 :128*`PIXEL_WIDTH] ;
      
  always @ (*) begin
      if(fme_cur_y_i  == 'd0)
          fme_ref_y = (fme_ref_y_i < 'd32) ? 'd0 : (fme_ref_y_i - 'd32);
      else if(fme_cur_y_i*64 + fme_ref_y_i - 'd32 > sys_all_y_i - 'd1)
          fme_ref_y = sys_all_y_i - 'd1 - fme_cur_y_i*64 + 'd32 ;
      else
          fme_ref_y = fme_ref_y_i ;
  end

// ********************************************
//
//    Sel Logic
//
// ********************************************

wire    [64*`PIXEL_WIDTH-1:0]  ext_load_data_0     ;   
wire    [64*`PIXEL_WIDTH-1:0]  ext_load_data_1     ;   

assign ext_load_data_1 = ext_load_data_i[128*`PIXEL_WIDTH-1:64 *`PIXEL_WIDTH] ;
assign ext_load_data_0 = ext_load_data_i[64 *`PIXEL_WIDTH-1:               0] ;

always @ (*) begin
    case(rotate_ime) 
    'd0: begin
        if ( extif_width_i == 'd128 && extif_mode_i == 'd4 ) begin
            ref_luma_ime00_wen     = ext_load_valid_i;
            ref_luma_ime00_waddr   = ext_load_addr_i ;   
            ref_luma_ime00_wdata   = ext_load_data_1 ; 
            ref_luma_ime00_rden    = 'b0;
            ref_luma_ime00_raddr   = 'b0;
        end
        else begin
            ref_luma_ime00_wen     = 'b0;
            ref_luma_ime00_waddr   = 'b0;
            ref_luma_ime00_wdata   = 'b0;
            ref_luma_ime00_rden    = ime_ref_rden_i;
            ref_luma_ime00_raddr   = ime_ref_y;
        end

        ref_luma_ime01_wen     = ext_load_valid_i;
        ref_luma_ime01_waddr   = ext_load_addr_i ;   
        ref_luma_ime01_wdata   = ext_load_data_0 ; 
        ref_luma_ime01_rden    = 'b0;
        ref_luma_ime01_raddr   = 'b0;
        
        ref_luma_ime02_wen     = 'b0;
        ref_luma_ime02_waddr   = 'b0;
        ref_luma_ime02_wdata   = 'b0;
        ref_luma_ime02_rden    = ime_ref_rden_i;
        ref_luma_ime02_raddr   = ime_ref_y;

        ref_luma_ime03_wen     = 'b0;
        ref_luma_ime03_waddr   = 'b0;
        ref_luma_ime03_wdata   = 'b0;
        ref_luma_ime03_rden    = ime_ref_rden_i;
        ref_luma_ime03_raddr   = ime_ref_y;

        ime_ref_pel_w = {ref_luma_ime02_rdata,ref_luma_ime03_rdata,ref_luma_ime00_rdata};
    end
    'd1: begin
        ref_luma_ime00_wen     = 'b0;
        ref_luma_ime00_waddr   = 'b0;
        ref_luma_ime00_wdata   = 'b0;
        ref_luma_ime00_rden    = ime_ref_rden_i;
        ref_luma_ime00_raddr   = ime_ref_y;

        if ( extif_width_i == 'd128 && extif_mode_i == 'd4 ) begin
            ref_luma_ime01_wen     = ext_load_valid_i;
            ref_luma_ime01_waddr   = ext_load_addr_i ;   
            ref_luma_ime01_wdata   = ext_load_data_1 ; 
            ref_luma_ime01_rden    = 'b0;
            ref_luma_ime01_raddr   = 'b0;
        end
        else begin
            ref_luma_ime01_wen     = 'b0;
            ref_luma_ime01_waddr   = 'b0;
            ref_luma_ime01_wdata   = 'b0;
            ref_luma_ime01_rden    = ime_ref_rden_i;
            ref_luma_ime01_raddr   = ime_ref_y;
        end
        
        ref_luma_ime02_wen     = ext_load_valid_i;
        ref_luma_ime02_waddr   = ext_load_addr_i ;
        ref_luma_ime02_wdata   = ext_load_data_0 ;
        ref_luma_ime02_rden    = 'b0;
        ref_luma_ime02_raddr   = 'b0;

        ref_luma_ime03_wen     = 'b0;
        ref_luma_ime03_waddr   = 'b0;
        ref_luma_ime03_wdata   = 'b0;
        ref_luma_ime03_rden    = ime_ref_rden_i;
        ref_luma_ime03_raddr   = ime_ref_y; 

        ime_ref_pel_w = {ref_luma_ime03_rdata,ref_luma_ime00_rdata,ref_luma_ime01_rdata};
    end
    'd2: begin
        ref_luma_ime00_wen     = 'b0;
        ref_luma_ime00_waddr   = 'b0;
        ref_luma_ime00_wdata   = 'b0;
        ref_luma_ime00_rden    = ime_ref_rden_i;
        ref_luma_ime00_raddr   = ime_ref_y;

        ref_luma_ime01_wen     = 'b0;
        ref_luma_ime01_waddr   = 'b0;  
        ref_luma_ime01_wdata   = 'b0;
        ref_luma_ime01_rden    = ime_ref_rden_i;
        ref_luma_ime01_raddr   = ime_ref_y; 
        
        if ( extif_width_i == 'd128 && extif_mode_i == 'd4 ) begin
            ref_luma_ime02_wen     = ext_load_valid_i;
            ref_luma_ime02_waddr   = ext_load_addr_i ;   
            ref_luma_ime02_wdata   = ext_load_data_1 ; 
            ref_luma_ime02_rden    = 'b0;
            ref_luma_ime02_raddr   = 'b0;
        end
        else begin
            ref_luma_ime02_wen     = 'b0;
            ref_luma_ime02_waddr   = 'b0;
            ref_luma_ime02_wdata   = 'b0;
            ref_luma_ime02_rden    = ime_ref_rden_i;
            ref_luma_ime02_raddr   = ime_ref_y;
        end

        ref_luma_ime03_wen     = ext_load_valid_i;
        ref_luma_ime03_waddr   = ext_load_addr_i ;
        ref_luma_ime03_wdata   = ext_load_data_0 ;
        ref_luma_ime03_rden    = 'b0;
        ref_luma_ime03_raddr   = 'b0;     

        ime_ref_pel_w = {ref_luma_ime00_rdata,ref_luma_ime01_rdata,ref_luma_ime02_rdata};
    end
    'd3: begin
        ref_luma_ime00_wen     = ext_load_valid_i;
        ref_luma_ime00_waddr   = ext_load_addr_i ;
        ref_luma_ime00_wdata   = ext_load_data_0 ;
        ref_luma_ime00_rden    = 'b0;
        ref_luma_ime00_raddr   = 'b0;     

        ref_luma_ime01_wen     = 'b0;
        ref_luma_ime01_waddr   = 'b0;  
        ref_luma_ime01_wdata   = 'b0;
        ref_luma_ime01_rden    = ime_ref_rden_i;
        ref_luma_ime01_raddr   = ime_ref_y; 
        
        ref_luma_ime02_wen     = 'b0;
        ref_luma_ime02_waddr   = 'b0;  
        ref_luma_ime02_wdata   = 'b0;
        ref_luma_ime02_rden    = ime_ref_rden_i;
        ref_luma_ime02_raddr   = ime_ref_y; 

        if ( extif_width_i == 'd128 && extif_mode_i == 'd4 ) begin
            ref_luma_ime03_wen     = ext_load_valid_i;
            ref_luma_ime03_waddr   = ext_load_addr_i ;   
            ref_luma_ime03_wdata   = ext_load_data_1 ; 
            ref_luma_ime03_rden    = 'b0;
            ref_luma_ime03_raddr   = 'b0;
        end
        else begin
            ref_luma_ime03_wen     = 'b0;
            ref_luma_ime03_waddr   = 'b0;
            ref_luma_ime03_wdata   = 'b0;
            ref_luma_ime03_rden    = ime_ref_rden_i;
            ref_luma_ime03_raddr   = ime_ref_y;
        end  

        ime_ref_pel_w = {ref_luma_ime01_rdata,ref_luma_ime02_rdata,ref_luma_ime03_rdata};    
    end
    default: begin
        ref_luma_ime00_wen     = 'b0;
        ref_luma_ime00_waddr   = 'b0;
        ref_luma_ime00_wdata   = 'b0;
        ref_luma_ime00_rden    = 'b0;
        ref_luma_ime00_raddr   = 'b0;

        ref_luma_ime01_wen     = 'b0;
        ref_luma_ime01_waddr   = 'b0;
        ref_luma_ime01_wdata   = 'b0;
        ref_luma_ime01_rden    = 'b0;
        ref_luma_ime01_raddr   = 'b0;
        
        ref_luma_ime02_wen     = 'b0;
        ref_luma_ime02_waddr   = 'b0;
        ref_luma_ime02_wdata   = 'b0;
        ref_luma_ime02_rden    = 'b0;
        ref_luma_ime02_raddr   = 'b0;

        ref_luma_ime03_wen     = 'b0;
        ref_luma_ime03_waddr   = 'b0;
        ref_luma_ime03_wdata   = 'b0;
        ref_luma_ime03_rden    = 'b0;
        ref_luma_ime03_raddr   = 'b0;

        ime_ref_pel_w = 192'd0;
    end
    endcase
end

always @ (*) begin
    case(rotate_fme) 
    0: begin
        if ( extif_width_i == 'd128 && extif_mode_i == 'd4 ) begin
            ref_luma_fme00_wen     = ext_load_valid_i;
            ref_luma_fme00_waddr   = ext_load_addr_i ;   
            ref_luma_fme00_wdata   = ext_load_data_1 ; 
            ref_luma_fme00_rden    = 'b0;
            ref_luma_fme00_raddr   = 'b0;
        end
        else begin
            ref_luma_fme00_wen     = 'b0;
            ref_luma_fme00_waddr   = 'b0;
            ref_luma_fme00_wdata   = 'b0;
            ref_luma_fme00_rden    = 'b0;
            ref_luma_fme00_raddr   = 'b0;
        end

        ref_luma_fme01_wen     = ext_load_valid_i;
        ref_luma_fme01_waddr   = ext_load_addr_i ;   
        ref_luma_fme01_wdata   = ext_load_data_0 ; 
        ref_luma_fme01_rden    = 'b0;
        ref_luma_fme01_raddr   = 'b0;
        
        ref_luma_fme02_wen     = 'b0;
        ref_luma_fme02_waddr   = 'b0;
        ref_luma_fme02_wdata   = 'b0;
        ref_luma_fme02_rden    = fme_ref_rden_i;
        ref_luma_fme02_raddr   = fme_ref_y;

        ref_luma_fme03_wen     = 'b0;
        ref_luma_fme03_waddr   = 'b0;
        ref_luma_fme03_wdata   = 'b0;
        ref_luma_fme03_rden    = fme_ref_rden_i;
        ref_luma_fme03_raddr   = fme_ref_y;

        ref_luma_fme04_wen     = 'b0;
        ref_luma_fme04_waddr   = 'b0;
        ref_luma_fme04_wdata   = 'b0;
        ref_luma_fme04_rden    = fme_ref_rden_i;
        ref_luma_fme04_raddr   = fme_ref_y;

        fme_ref_pel_w = {ref_luma_fme02_rdata,ref_luma_fme03_rdata,ref_luma_fme04_rdata};  
      end   
    1 : begin 
        ref_luma_fme00_wen     = 'b0;
        ref_luma_fme00_waddr   = 'b0;
        ref_luma_fme00_wdata   = 'b0;
        ref_luma_fme00_rden    = fme_ref_rden_i;
        ref_luma_fme00_raddr   = fme_ref_y;

        if ( extif_width_i == 'd128 && extif_mode_i == 'd4 ) begin
            ref_luma_fme01_wen     = ext_load_valid_i;
            ref_luma_fme01_waddr   = ext_load_addr_i ;   
            ref_luma_fme01_wdata   = ext_load_data_1 ; 
            ref_luma_fme01_rden    = 'b0;
            ref_luma_fme01_raddr   = 'b0;
        end
        else begin
            ref_luma_fme01_wen     = 'b0;
            ref_luma_fme01_waddr   = 'b0;
            ref_luma_fme01_wdata   = 'b0;
            ref_luma_fme01_rden    = 'b0;
            ref_luma_fme01_raddr   = 'b0;
        end
        
        ref_luma_fme02_wen     = ext_load_valid_i;
        ref_luma_fme02_waddr   = ext_load_addr_i ;   
        ref_luma_fme02_wdata   = ext_load_data_0 ; 
        ref_luma_fme02_rden    = 'b0;
        ref_luma_fme02_raddr   = 'b0;

        ref_luma_fme03_wen     = 'b0;
        ref_luma_fme03_waddr   = 'b0;
        ref_luma_fme03_wdata   = 'b0;
        ref_luma_fme03_rden    = fme_ref_rden_i;
        ref_luma_fme03_raddr   = fme_ref_y;

        ref_luma_fme04_wen     = 'b0;
        ref_luma_fme04_waddr   = 'b0;
        ref_luma_fme04_wdata   = 'b0;
        ref_luma_fme04_rden    = fme_ref_rden_i;
        ref_luma_fme04_raddr   = fme_ref_y;

        fme_ref_pel_w = {ref_luma_fme03_rdata,ref_luma_fme04_rdata,ref_luma_fme00_rdata};   
    end
    2: begin
        ref_luma_fme00_wen     = 'b0;
        ref_luma_fme00_waddr   = 'b0;
        ref_luma_fme00_wdata   = 'b0;
        ref_luma_fme00_rden    = fme_ref_rden_i;
        ref_luma_fme00_raddr   = fme_ref_y;

        ref_luma_fme01_wen     = 'b0;
        ref_luma_fme01_waddr   = 'b0;
        ref_luma_fme01_wdata   = 'b0;
        ref_luma_fme01_rden    = fme_ref_rden_i;
        ref_luma_fme01_raddr   = fme_ref_y;
        
        if ( extif_width_i == 'd128 && extif_mode_i == 'd4 ) begin
            ref_luma_fme02_wen     = ext_load_valid_i;
            ref_luma_fme02_waddr   = ext_load_addr_i ;   
            ref_luma_fme02_wdata   = ext_load_data_1 ; 
            ref_luma_fme02_rden    = 'b0;
            ref_luma_fme02_raddr   = 'b0;
        end
        else begin
            ref_luma_fme02_wen     = 'b0;
            ref_luma_fme02_waddr   = 'b0;
            ref_luma_fme02_wdata   = 'b0;
            ref_luma_fme02_rden    = 'b0;
            ref_luma_fme02_raddr   = 'b0;
        end

        ref_luma_fme03_wen     = ext_load_valid_i;
        ref_luma_fme03_waddr   = ext_load_addr_i ;  
        ref_luma_fme03_wdata   = ext_load_data_0 ; 
        ref_luma_fme03_rden    = 'b0;
        ref_luma_fme03_raddr   = 'b0;

        ref_luma_fme04_wen     = 'b0;
        ref_luma_fme04_waddr   = 'b0;
        ref_luma_fme04_wdata   = 'b0;
        ref_luma_fme04_rden    = fme_ref_rden_i;
        ref_luma_fme04_raddr   = fme_ref_y;

        fme_ref_pel_w = {ref_luma_fme04_rdata,ref_luma_fme00_rdata,ref_luma_fme01_rdata};   
    end
    3: begin
        ref_luma_fme00_wen     = 'b0;
        ref_luma_fme00_waddr   = 'b0;
        ref_luma_fme00_wdata   = 'b0;
        ref_luma_fme00_rden    = fme_ref_rden_i;
        ref_luma_fme00_raddr   = fme_ref_y;

        ref_luma_fme01_wen     = 'b0;
        ref_luma_fme01_waddr   = 'b0;
        ref_luma_fme01_wdata   = 'b0;
        ref_luma_fme01_rden    = fme_ref_rden_i;
        ref_luma_fme01_raddr   = fme_ref_y;
        
        ref_luma_fme02_wen     = 'b0;
        ref_luma_fme02_waddr   = 'b0;
        ref_luma_fme02_wdata   = 'b0;
        ref_luma_fme02_rden    = fme_ref_rden_i;
        ref_luma_fme02_raddr   = fme_ref_y;

        if ( extif_width_i == 'd128 && extif_mode_i == 'd4 ) begin
            ref_luma_fme03_wen     = ext_load_valid_i;
            ref_luma_fme03_waddr   = ext_load_addr_i ;   
            ref_luma_fme03_wdata   = ext_load_data_1 ; 
            ref_luma_fme03_rden    = 'b0;
            ref_luma_fme03_raddr   = 'b0;
        end
        else begin
            ref_luma_fme03_wen     = 'b0;
            ref_luma_fme03_waddr   = 'b0;
            ref_luma_fme03_wdata   = 'b0;
            ref_luma_fme03_rden    = 'b0;
            ref_luma_fme03_raddr   = 'b0;
        end

        ref_luma_fme04_wen     = ext_load_valid_i;
        ref_luma_fme04_waddr   = ext_load_addr_i ; 
        ref_luma_fme04_wdata   = ext_load_data_0 ; 
        ref_luma_fme04_rden    = 'b0;
        ref_luma_fme04_raddr   = 'b0;   

        fme_ref_pel_w = {ref_luma_fme00_rdata,ref_luma_fme01_rdata,ref_luma_fme02_rdata};  
    end
     4: begin
        ref_luma_fme00_wen     = ext_load_valid_i;
        ref_luma_fme00_waddr   = ext_load_addr_i ;  
        ref_luma_fme00_wdata   = ext_load_data_0 ; 
        ref_luma_fme00_rden    = 'b0;
        ref_luma_fme00_raddr   = 'b0;

        ref_luma_fme01_wen     = 'b0;
        ref_luma_fme01_waddr   = 'b0;
        ref_luma_fme01_wdata   = 'b0;
        ref_luma_fme01_rden    = fme_ref_rden_i;
        ref_luma_fme01_raddr   = fme_ref_y;
        
        ref_luma_fme02_wen     = 'b0;
        ref_luma_fme02_waddr   = 'b0;
        ref_luma_fme02_wdata   = 'b0;
        ref_luma_fme02_rden    = fme_ref_rden_i;
        ref_luma_fme02_raddr   = fme_ref_y;

        ref_luma_fme03_wen     = 'b0;
        ref_luma_fme03_waddr   = 'b0;
        ref_luma_fme03_wdata   = 'b0;
        ref_luma_fme03_rden    = fme_ref_rden_i;
        ref_luma_fme03_raddr   = fme_ref_y;

        if ( extif_width_i == 'd128 && extif_mode_i == 'd4 ) begin
            ref_luma_fme04_wen     = ext_load_valid_i;
            ref_luma_fme04_waddr   = ext_load_addr_i ;   
            ref_luma_fme04_wdata   = ext_load_data_1 ; 
            ref_luma_fme04_rden    = 'b0;
            ref_luma_fme04_raddr   = 'b0;
        end
        else begin
            ref_luma_fme04_wen     = 'b0;
            ref_luma_fme04_waddr   = 'b0;
            ref_luma_fme04_wdata   = 'b0;
            ref_luma_fme04_rden    = 'b0;
            ref_luma_fme04_raddr   = 'b0;
        end

        fme_ref_pel_w = {ref_luma_fme01_rdata,ref_luma_fme02_rdata,ref_luma_fme03_rdata};  
    end   
    default: begin
        ref_luma_fme00_wen     = 'b0;
        ref_luma_fme00_waddr   = 'b0;
        ref_luma_fme00_wdata   = 'b0;
        ref_luma_fme00_rden    = 'b0;
        ref_luma_fme00_raddr   = 'b0;

        ref_luma_fme01_wen     = 'b0;
        ref_luma_fme01_waddr   = 'b0;
        ref_luma_fme01_wdata   = 'b0;
        ref_luma_fme01_rden    = 'b0;
        ref_luma_fme01_raddr   = 'b0;
        
        ref_luma_fme02_wen     = 'b0;
        ref_luma_fme02_waddr   = 'b0;
        ref_luma_fme02_wdata   = 'b0;
        ref_luma_fme02_rden    = 'b0;
        ref_luma_fme02_raddr   = 'b0;

        ref_luma_fme03_wen     = 'b0;
        ref_luma_fme03_waddr   = 'b0;
        ref_luma_fme03_wdata   = 'b0;
        ref_luma_fme03_rden    = 'b0;
        ref_luma_fme03_raddr   = 'b0;

        ref_luma_fme04_wen     = 'b0;
        ref_luma_fme04_waddr   = 'b0;
        ref_luma_fme04_wdata   = 'b0;
        ref_luma_fme04_rden    = 'b0;
        ref_luma_fme04_raddr   = 'b0;

        fme_ref_pel_w = 192'd0;
    end
    endcase
end

// ********************************************
//
//    Memory
//
// ********************************************

fetch_rf_1p_128x512  ref_luma_ime00(
    .clk            (clk         ),
    .rstn           (rstn        ),
                                 
    .wrif_en_i      (ref_luma_ime00_wen   ),
    .wrif_addr_i    (ref_luma_ime00_waddr ),
    .wrif_data_i    (ref_luma_ime00_wdata ),
                                 
    .rdif_en_i      (ref_luma_ime00_rden  ),
    .rdif_addr_i    (ref_luma_ime00_raddr ),
    .rdif_pdata_o   (ref_luma_ime00_rdata )     
);

fetch_rf_1p_128x512  ref_luma_ime01(
    .clk            (clk         ),
    .rstn           (rstn        ),
                                 
    .wrif_en_i      (ref_luma_ime01_wen   ),
    .wrif_addr_i    (ref_luma_ime01_waddr ),
    .wrif_data_i    (ref_luma_ime01_wdata ),
                                
    .rdif_en_i      (ref_luma_ime01_rden  ),
    .rdif_addr_i    (ref_luma_ime01_raddr ),
    .rdif_pdata_o   (ref_luma_ime01_rdata )     
);

fetch_rf_1p_128x512  ref_luma_ime02(
    .clk            (clk         ),
    .rstn           (rstn        ),
                                 
    .wrif_en_i      (ref_luma_ime02_wen   ),
    .wrif_addr_i    (ref_luma_ime02_waddr ),
    .wrif_data_i    (ref_luma_ime02_wdata ),
                               
    .rdif_en_i      (ref_luma_ime02_rden  ),
    .rdif_addr_i    (ref_luma_ime02_raddr ),
    .rdif_pdata_o   (ref_luma_ime02_rdata )     
);

fetch_rf_1p_128x512  ref_luma_ime03(
    .clk            (clk         ),
    .rstn           (rstn        ),
                                 
    .wrif_en_i      (ref_luma_ime03_wen   ),
    .wrif_addr_i    (ref_luma_ime03_waddr ),
    .wrif_data_i    (ref_luma_ime03_wdata ),
                               
    .rdif_en_i      (ref_luma_ime03_rden  ),
    .rdif_addr_i    (ref_luma_ime03_raddr ),
    .rdif_pdata_o   (ref_luma_ime03_rdata )     
);

fetch_rf_1p_128x512  ref_luma_fme00(
    .clk            (clk         ),
    .rstn           (rstn        ),
                                 
    .wrif_en_i      (ref_luma_fme00_wen   ),
    .wrif_addr_i    (ref_luma_fme00_waddr ),
    .wrif_data_i    (ref_luma_fme00_wdata ),
                               
    .rdif_en_i      (ref_luma_fme00_rden  ),
    .rdif_addr_i    (ref_luma_fme00_raddr ),
    .rdif_pdata_o   (ref_luma_fme00_rdata )     
);

fetch_rf_1p_128x512  ref_luma_fme01(
    .clk            (clk         ),
    .rstn           (rstn        ),
                                 
    .wrif_en_i      (ref_luma_fme01_wen   ),
    .wrif_addr_i    (ref_luma_fme01_waddr ),
    .wrif_data_i    (ref_luma_fme01_wdata ),
                              
    .rdif_en_i      (ref_luma_fme01_rden  ),
    .rdif_addr_i    (ref_luma_fme01_raddr ),
    .rdif_pdata_o   (ref_luma_fme01_rdata )     
);

fetch_rf_1p_128x512  ref_luma_fme02(
    .clk            (clk         ),
    .rstn           (rstn        ),
                                 
    .wrif_en_i      (ref_luma_fme02_wen   ),
    .wrif_addr_i    (ref_luma_fme02_waddr ),
    .wrif_data_i    (ref_luma_fme02_wdata ),
                              
    .rdif_en_i      (ref_luma_fme02_rden  ),
    .rdif_addr_i    (ref_luma_fme02_raddr ),
    .rdif_pdata_o   (ref_luma_fme02_rdata )     
);

fetch_rf_1p_128x512  ref_luma_fme03(
    .clk            (clk         ),
    .rstn           (rstn        ),
                                 
    .wrif_en_i      (ref_luma_fme03_wen   ),
    .wrif_addr_i    (ref_luma_fme03_waddr ),
    .wrif_data_i    (ref_luma_fme03_wdata ),
                              
    .rdif_en_i      (ref_luma_fme03_rden  ),
    .rdif_addr_i    (ref_luma_fme03_raddr ),
    .rdif_pdata_o   (ref_luma_fme03_rdata )     
);

fetch_rf_1p_128x512  ref_luma_fme04(
    .clk            (clk         ),
    .rstn           (rstn        ),
                                 
    .wrif_en_i      (ref_luma_fme04_wen   ),
    .wrif_addr_i    (ref_luma_fme04_waddr ),
    .wrif_data_i    (ref_luma_fme04_wdata ),
                              
    .rdif_en_i      (ref_luma_fme04_rden  ),
    .rdif_addr_i    (ref_luma_fme04_raddr ),
    .rdif_pdata_o   (ref_luma_fme04_rdata )     
);

endmodule

