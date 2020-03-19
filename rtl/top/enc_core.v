//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2016, VIPcore Group, Fudan University
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
//  Filename      : enc_core.v
//  Author        : TANG
//  Created       : 2018-04-20
//  Description   : core of enc
//
//-------------------------------------------------------------------
`include "enc_defines.v"

module enc_core(
    // global signal
    clk                     ,
    rstn                    ,
    sys_ctu_all_x_i         ,
    sys_ctu_all_y_i         ,
    sys_all_x_i             ,
    sys_all_y_i             ,
    sys_type_i              ,
    sys_start_i             ,
    enc_done_i              ,
    sys_IinP_ena_i          ,
    sys_db_ena_i            ,
    sys_sao_ena_i           ,
    sys_posi4x4bit_i        ,
    // skip cost thresh
    skip_cost_thresh_08     ,
    skip_cost_thresh_16     ,
    skip_cost_thresh_32     ,
    skip_cost_thresh_64     ,
    // pre_i_if
    prei_start_i            ,
    prei_done_o             ,
    rc_ctu_x_i              ,
    rc_ctu_y_i              ,
    prei_cur_ren_o          ,
    prei_cur_sel_o          ,
    prei_cur_size_o         ,
    prei_cur_4x4_x_o        ,
    prei_cur_4x4_y_o        ,
    prei_cur_idx_o          ,
    prei_cur_data_i         ,
    // rc_if
    sys_rc_mod64_sum_o      ,
    sys_rc_k                ,
    sys_rc_bitnum_i         ,
    sys_rc_roi_height       ,
    sys_rc_roi_width        ,
    sys_rc_roi_x            ,
    sys_rc_roi_y            ,
    sys_rc_roi_enable       ,
    sys_rc_L1_frame_byte    ,
    sys_rc_L2_frame_byte    ,
    sys_rc_lcu_en           ,
    sys_init_qp_i           ,
    sys_rc_max_qp           ,
    sys_rc_min_qp           ,
    sys_rc_delta_qp         ,
    // posi_if
    posi_start_i            ,
    posi_done_o             ,
    posi_ctu_x_i            ,
    posi_ctu_y_i            ,
    posi_cur_rd_ena_o       ,
    posi_cur_rd_sel_o       ,
    posi_cur_rd_siz_o       ,
    posi_cur_rd_4x4_x_o     ,
    posi_cur_rd_4x4_y_o     ,
    posi_cur_rd_idx_o       ,
    posi_cur_rd_dat_i       ,
    // ime_if
    sys_ime_cmd_num_i       ,
    sys_ime_cmd_dat_i       ,
    ime_ctu_x_i             ,
    ime_ctu_y_i             ,
    ime_start_i             ,
    ime_done_o              ,
    // ime_cur_if   
    ime_cur_4x4_x_o         ,
    ime_cur_4x4_y_o         ,
    ime_cur_4x4_idx_o       ,
    ime_cur_sel_o           ,
    ime_cur_size_o          ,
    ime_cur_rden_o          ,
    ime_downsample_o        ,
    ime_cur_pel_i           ,
    // ime_ref_if       
    ime_ref_x_o             ,
    ime_ref_y_o             ,
    ime_ref_rden_o          ,
    ime_ref_pel_i           ,
    // fme_if
    fme_start_i             ,
    fme_ctu_x_i             ,
    fme_ctu_y_i             ,
    fme_done_o              ,
    fme_cur_rden_o          ,
    fme_cur_4x4_idx_o       ,
    fme_cur_4x4_x_o         ,
    fme_cur_4x4_y_o         ,
    fme_cur_pel_i           ,
    fme_ref_rden_o          ,
    fme_ref_idx_x_o         ,
    fme_ref_idx_y_o         ,
    fme_ref_pel_i           ,
    // rec_if
    rec_start_i             ,
    rec_done_o              ,
    rec_ctu_x_i             ,
    rec_ctu_y_i             ,
    rec_cur_rd_ena_o        ,
    rec_cur_rd_sel_o        ,
    rec_cur_rd_siz_o        ,
    rec_cur_rd_4x4_x_o      ,
    rec_cur_rd_4x4_y_o      ,
    rec_cur_rd_idx_o        ,
    rec_cur_rd_dat_i        ,
    rec_ref_rd_ena_o        ,
    rec_ref_rd_sel_o        ,
    rec_ref_rd_idx_x_o      ,
    rec_ref_rd_idx_y_o      ,
    rec_ref_rd_dat_i        ,
    // db_if
    db_ctu_x_i              ,
    db_ctu_y_i              ,
    db_start_i              ,
    db_done_o               ,
    db_cur_4x4_x_o          ,
    db_cur_4x4_y_o          ,
    db_cur_4x4_idx_o        ,
    db_cur_ren_o            ,
    db_cur_sel_o            ,
    db_cur_siz_o            ,
    db_cur_pxl_i            ,
    // fetch_if
    fetch_wen_o             ,
    fetch_w4x4_x_o          ,
    fetch_w4x4_y_o          ,
    fetch_wprevious_o       ,
    fetch_wdone_o           ,
    fetch_wsel_o            ,
    fetch_wdata_o           ,
    // db_top_rec_if
    top_ren_o               ,
    top_r4x4_o              ,
    top_ridx_o              ,
    top_rdata_i             ,
    // ec_if
    ec_ctu_x_i              ,
    ec_ctu_y_i              ,
    ec_start_i              ,
    ec_done_o               ,
    bs_data_o               ,
    bs_val_o                
    // slice_done_o            
);
//*** parameter declaration ***************************************************
  parameter     CMD_NUM_WIDTH                   = 3                         ;

  localparam    CMD_DAT_WIDTH_ONE               =(`IME_MV_WIDTH_X  )             // center_x_o
                                                +(`IME_MV_WIDTH_Y  )             // center_y_o
                                                +(`IME_MV_WIDTH_X-1)             // length_x_o
                                                +(`IME_MV_WIDTH_Y-1)             // length_y_o
                                                +(2                )             // slope_o
                                                +(1                )             // downsample_o
                                                +(1                )             // partition_r
                                                +(1                )        ;    // use_feedback_o
  localparam    CMD_DAT_WIDTH                   = CMD_DAT_WIDTH_ONE
                                                *(1<<CMD_NUM_WIDTH )        ;


//*** input / output declaration ***********************************************
  // sys_if
  input                                   clk                       ;
  input                                   rstn                      ;
  input                                   sys_start_i               ;
  input                                   enc_done_i                ;
  input  [`PIC_X_WIDTH         -1 :0]     sys_ctu_all_x_i           ;
  input  [`PIC_Y_WIDTH         -1 :0]     sys_ctu_all_y_i           ;
  input  [`PIC_WIDTH           -1 :0]     sys_all_x_i               ;
  input  [`PIC_HEIGHT          -1 :0]     sys_all_y_i               ;
  input                                   sys_type_i                ;
  input                                   sys_IinP_ena_i            ;
  input                                   sys_db_ena_i              ;
  input                                   sys_sao_ena_i             ;
  input  [5-1:0]                          sys_posi4x4bit_i          ;
  // prei         
  input                                   prei_start_i              ;
  output                                  prei_done_o               ;
  input  [`PIC_X_WIDTH         -1 :0]     rc_ctu_x_i                ;
  input  [`PIC_Y_WIDTH         -1 :0]     rc_ctu_y_i                ;

  output                                  prei_cur_ren_o            ;
  output [2                    -1 :0]     prei_cur_sel_o            ;
  output [2                    -1 :0]     prei_cur_size_o           ;
  output [4                    -1 :0]     prei_cur_4x4_x_o          ;
  output [4                    -1 :0]     prei_cur_4x4_y_o          ;
  output [5                    -1 :0]     prei_cur_idx_o            ;
  input  [`PIXEL_WIDTH*32-1       :0]     prei_cur_data_i           ;

  output [32                   -1 :0]     sys_rc_mod64_sum_o        ;
  input  [32                   -1 :0]     sys_rc_bitnum_i           ;
  input  [16                   -1 :0]     sys_rc_k                  ;
  input  [6                    -1 :0]     sys_rc_roi_height         ;
  input  [7                    -1 :0]     sys_rc_roi_width          ;
  input  [7                    -1 :0]     sys_rc_roi_x              ;
  input  [7                    -1 :0]     sys_rc_roi_y              ;
  input                                   sys_rc_roi_enable         ;
  input  [10                   -1 :0]     sys_rc_L1_frame_byte      ;
  input  [10                   -1 :0]     sys_rc_L2_frame_byte      ;
  input                                   sys_rc_lcu_en             ;
  input  [6                    -1 :0]     sys_init_qp_i             ;
  input  [6                    -1 :0]     sys_rc_max_qp             ;
  input  [6                    -1 :0]     sys_rc_min_qp             ;
  input  [6                    -1 :0]     sys_rc_delta_qp           ;
  // posi
  input                                   posi_start_i              ;
  output                                  posi_done_o               ;

  input  [`PIC_X_WIDTH         -1 :0]     posi_ctu_x_i              ;
  input  [`PIC_Y_WIDTH         -1 :0]     posi_ctu_y_i              ;

  output                                  posi_cur_rd_ena_o         ;
  output [2                    -1 :0]     posi_cur_rd_sel_o         ;
  output [2                    -1 :0]     posi_cur_rd_siz_o         ;
  output [3                       :0]     posi_cur_rd_4x4_x_o       ;
  output [3                       :0]     posi_cur_rd_4x4_y_o       ;
  output [5                    -1 :0]     posi_cur_rd_idx_o         ;
  input  [`PIXEL_WIDTH*32-1       :0]     posi_cur_rd_dat_i         ;
  // ime
  input  [CMD_NUM_WIDTH        -1 :0]     sys_ime_cmd_num_i         ; 
  input  [CMD_DAT_WIDTH        -1 :0]     sys_ime_cmd_dat_i         ; 
  output                                  ime_downsample_o          ; 
  input                                   ime_start_i               ;     
  output                                  ime_done_o                ;

  input  [`PIC_X_WIDTH         -1 :0]     ime_ctu_x_i               ;
  input  [`PIC_Y_WIDTH         -1 :0]     ime_ctu_y_i               ;
    // ime_cur_if   
  output [4                    -1 :0]     ime_cur_4x4_x_o           ;
  output [4                    -1 :0]     ime_cur_4x4_y_o           ;
  output [5                    -1 :0]     ime_cur_4x4_idx_o         ;
  output [2                    -1 :0]     ime_cur_sel_o             ;
  output [2                    -1 :0]     ime_cur_size_o            ;
  output                                  ime_cur_rden_o            ;
  input  [32*`PIXEL_WIDTH      -1 :0]     ime_cur_pel_i             ;
  // ime_ref_if       
  output [`IME_MV_WIDTH_X         :0]     ime_ref_x_o               ;
  output [`IME_MV_WIDTH_Y         :0]     ime_ref_y_o               ;
  output                                  ime_ref_rden_o            ;
  input  [32*`PIXEL_WIDTH      -1 :0]     ime_ref_pel_i             ; 
  // fme
  input                                   fme_start_i               ;          
  input  [`PIC_X_WIDTH         -1 :0]     fme_ctu_x_i               ;          
  input  [`PIC_Y_WIDTH         -1 :0]     fme_ctu_y_i               ;                
  output                                  fme_done_o                ;        

  // skip cost thresh
  input   [32-1:0]                        skip_cost_thresh_08       ;
  input   [32-1:0]                        skip_cost_thresh_16       ;
  input   [32-1:0]                        skip_cost_thresh_32       ;
  input   [32-1:0]                        skip_cost_thresh_64       ;

  output                                  fme_cur_rden_o            ;
  output [5                    -1 :0]     fme_cur_4x4_idx_o         ;
  output [4                    -1 :0]     fme_cur_4x4_x_o           ;
  output [4                    -1 :0]     fme_cur_4x4_y_o           ;
  input  [32*`PIXEL_WIDTH      -1 :0]     fme_cur_pel_i             ;

  output                                  fme_ref_rden_o            ;   
  output [8                    -1 :0]     fme_ref_idx_x_o           ;   
  output [8                    -1 :0]     fme_ref_idx_y_o           ;   
  input  [64*`PIXEL_WIDTH      -1 :0]     fme_ref_pel_i             ;     

  // rec 
  input                                   rec_start_i               ;    
  output                                  rec_done_o                ;    
  input  [`PIC_X_WIDTH       -1 :0]       rec_ctu_x_i               ;
  input  [`PIC_Y_WIDTH       -1 :0]       rec_ctu_y_i               ;

  output                                  rec_cur_rd_ena_o          ;
  output [2                  -1 :0]       rec_cur_rd_sel_o          ;
  output [2                  -1 :0]       rec_cur_rd_siz_o          ;
  output [4                  -1 :0]       rec_cur_rd_4x4_x_o        ;
  output [4                  -1 :0]       rec_cur_rd_4x4_y_o        ;
  output [5                  -1 :0]       rec_cur_rd_idx_o          ;
  input  [`PIXEL_WIDTH*32    -1 :0]       rec_cur_rd_dat_i          ;

  output                                  rec_ref_rd_ena_o          ;
  output [2                  -1 :0]       rec_ref_rd_sel_o          ;
  output [8                  -1 :0]       rec_ref_rd_idx_x_o        ;
  output [8                  -1 :0]       rec_ref_rd_idx_y_o        ;
  input  [`PIXEL_WIDTH*8     -1 :0]       rec_ref_rd_dat_i          ;

  // dbsao 
  input  [`PIC_X_WIDTH       -1 :0]       db_ctu_x_i                ;         
  input  [`PIC_Y_WIDTH       -1 :0]       db_ctu_y_i                ;         
  input                                   db_start_i                ;         
  output                                  db_done_o                 ;      

  output [4                  -1 :0]       db_cur_4x4_x_o            ; 
  output [4                  -1 :0]       db_cur_4x4_y_o            ; 
  output [5                  -1 :0]       db_cur_4x4_idx_o          ; 
  output                                  db_cur_ren_o              ; 
  output [2                  -1 :0]       db_cur_sel_o              ; 
  output [2                  -1 :0]       db_cur_siz_o              ; 
  input  [`PIXEL_WIDTH*32    -1 :0]       db_cur_pxl_i              ;

  output                                  fetch_wen_o               ;
  output [5                  -1 :0]       fetch_w4x4_x_o            ;
  output [5                  -1 :0]       fetch_w4x4_y_o            ;
  output                                  fetch_wprevious_o         ;
  output                                  fetch_wdone_o             ;
  output [2                  -1 :0]       fetch_wsel_o              ;
  output [`PIXEL_WIDTH*16    -1 :0]       fetch_wdata_o             ;

  output                                  top_ren_o                 ;      
  output [5                  -1 :0]       top_r4x4_o                ;  
  output [2                  -1 :0]       top_ridx_o                ;    
  input  [`PIXEL_WIDTH*4     -1 :0]       top_rdata_i               ;

  // cabac
  input  [`PIC_X_WIDTH       -1 :0]       ec_ctu_x_i                ;    
  input  [`PIC_Y_WIDTH       -1 :0]       ec_ctu_y_i                ;    
  input                                   ec_start_i                ;           
  output                                  ec_done_o                 ;    
  output [8                  -1 :0]       bs_data_o                 ;    
  output                                  bs_val_o                  ;    
  // output                                  slice_done_o              ;    


//*** wire / reg declaration ***************************************************
  // global signal
  reg    [2                  -1 :0]       sys_start_r               ;
  reg                                     sel_r                     ;
  reg    [2                  -1 :0]       sel_mod_3_r               ;

  // prei
  wire   [6                  -1 :0]       rc_qp_w                   ;
  wire   [16                 -1 :0]       rc_actual_bitnum_i        ;
  wire                                    posi_mod_rd_ena_w         ;
  wire   [9                  -1 :0]       posi_mod_rd_adr_w         ;
  wire   [6                  -1 :0]       posi_mod_rd_dat_w         ;

  // posi   
  wire   [6                  -1 :0]       posi_qp_w                 ;
  wire   [85                 -1 :0]       intra_partition_w         ;
  wire   [`POSI_COST_WIDTH   -1 :0]       posi_cost_w               ;

  wire                                    rec_md_rd_ena_w           ;    
  wire   [8                  -1 :0]       rec_md_rd_adr_w           ;    
  wire   [6                  -1 :0]       rec_md_rd_dat_w           ;

  wire                                    ec_md_rd_ena_w            ; // need to be checked 
  wire   [6                  -1 :0]       ec_md_rd_adr_w            ; // need to be checked 
  wire   [6                  -1 :0]       ec_md_rd_dat_w            ; // need to be checked 

  // ime
  wire   [42                 -1 :0]       inter_partition_w         ;    
  wire   [1                  -1 :0]       fme_mv_rden_w             ;    
  wire   [6                  -1 :0]       fme_mv_rdaddr_w           ;    
  wire   [2*`FMV_WIDTH       -1 :0]       fme_mv_data_w             ;

  // fme       
  wire   [6                  -1 :0]       fme_qp_w                  ;
  wire   [42                 -1 :0]       fme_partition_w           ;
  wire   [4                  -1 :0]       fme_IinP_flag_w           ;
  wire                                    mc_mv_rd_ena_w            ;     
  wire   [6                  -1 :0]       mc_mv_rd_adr_w            ;     
  wire   [2*`FMV_WIDTH       -1 :0]       mc_mv_rd_dat_w            ;

  wire                                    db_mv_rd_ena_w            ;    
  wire   [6                  -1 :0]       db_mv_rd_adr_w            ;    
  wire   [2*`FMV_WIDTH       -1 :0]       db_mv_rd_dat_w            ;

  wire                                    fme_wr_ena_w              ;  
  wire   [2                  -1 :0]       fme_wr_siz_w              ; 
  wire   [2                  -1 :0]       fme_wr_sel_w              ; 
  wire   [4                  -1 :0]       fme_wr_4x4_x_w            ;   
  wire   [4                  -1 :0]       fme_wr_4x4_y_w            ;   
  wire   [5                  -1 :0]       fme_wr_idx_w              ;   
  wire   [32*`PIXEL_WIDTH    -1 :0]       fme_wr_dat_w              ;

  wire                                    fme_rd_ena_w              ;    
  wire   [2                  -1 :0]       fme_rd_siz_w              ;    
  wire   [4                  -1 :0]       fme_rd_4x4_x_w            ;    
  wire   [4                  -1 :0]       fme_rd_4x4_y_w            ;    
  wire   [5                  -1 :0]       fme_rd_idx_w              ;    
  wire   [32*`PIXEL_WIDTH    -1 :0]       fme_rd_dat_w              ; 

  wire   [`FME_COST_WIDTH    -1 :0]       fme_cost_w                ;
  wire   [85*4-1:0]                       fme_skip_idx_w            ;
  wire   [85-1:0]                         fme_skip_flag_w           ;

  // rec
  wire   [85-1:0]                         rec_skip_flag_w           ;
  wire   [42                 -1 :0]       rec_inter_pt_w            ;
  wire   [85                 -1 :0]       rec_intra_pt_w            ;
  wire   [6                  -1 :0]       rec_qp_w                  ;

  wire                                    ec_mvd_rd_en_w            ; 
  wire   [6                  -1 :0]       ec_mvd_rd_addr_w          ; 
  wire   [2*`MVD_WIDTH          :0]       ec_mvd_rd_data_w          ;
  
  // rec_pixel_o
  wire                                    db_rec_rd_ena_w           ;
  wire   [2                  -1 :0]       db_rec_rd_sel_w           ;
  wire   [2                  -1 :0]       db_rec_rd_siz_w           ;
  wire   [4                  -1 :0]       db_rec_rd_4x4_x_w         ;
  wire   [4                  -1 :0]       db_rec_rd_4x4_y_w         ;
  wire   [5                  -1 :0]       db_rec_rd_idx_w           ;
  wire   [`PIXEL_WIDTH*32    -1 :0]       db_rec_rd_dat_w           ;
  // rec_pixel_i
  wire   [1                  -1 :0]       db_rec_wr_ena_w           ;
  wire   [2                  -1 :0]       db_rec_wr_sel_w           ;
  wire   [2                  -1 :0]       db_rec_wr_siz_w           ;
  wire   [4                  -1 :0]       db_rec_wr_4x4_x_w         ;
  wire   [4                  -1 :0]       db_rec_wr_4x4_y_w         ;
  wire   [5                  -1 :0]       db_rec_wr_idx_w           ;
  wire   [`PIXEL_WIDTH*32    -1 :0]       db_rec_wr_dat_w           ;

  wire                                    ec_coe_rd_ena_w           ;  
  wire   [2                  -1 :0]       ec_coe_rd_sel_w           ;  
  wire   [2                  -1 :0]       ec_coe_rd_siz_w           ;  
  wire   [4                  -1 :0]       ec_coe_rd_4x4_x_w         ;  
  wire   [4                  -1 :0]       ec_coe_rd_4x4_y_w         ;  
  wire   [5                  -1 :0]       ec_coe_rd_idx_w           ;  
  wire   [`COEFF_WIDTH*32    -1 :0]       ec_coe_rd_dat_w           ; 
 
  wire   [`LCU_SIZE*`LCU_SIZE/16-1:0]     db_cbf_y_w                ;      
  wire   [`LCU_SIZE*`LCU_SIZE/16-1:0]     db_cbf_u_w                ;      
  wire   [`LCU_SIZE*`LCU_SIZE/16-1:0]     db_cbf_v_w                ; 

  wire   [42                 -1 :0]       db_inter_pt_w             ;      
  wire   [21                 -1 :0]       db_intra_pt_w             ;      
  wire   [6                  -1 :0]       db_qp_w                   ;      

  // dbsao  
  wire   [`LCU_SIZE*`LCU_SIZE/16-1:0]     ec_cbf_y_w                ;  
  wire   [`LCU_SIZE*`LCU_SIZE/16-1:0]     ec_cbf_u_w                ;  
  wire   [`LCU_SIZE*`LCU_SIZE/16-1:0]     ec_cbf_v_w                ;  
  wire   [42                 -1 :0]       ec_inter_pt_w             ;  
  wire   [85                 -1 :0]       ec_intra_pt_w             ;  
  wire   [6                  -1 :0]       ec_qp_w                   ;  
  wire   [62                 -1 :0]       sao_data_w                ;  

  // cabac                
  wire   [85*4-1:0]                       ec_skip_idx_w             ;
  wire   [85-1:0]                         ec_skip_flag_w            ;
      
  // cbf
  wire   [256                -1 :0]       cbf_y_w                   ;   
  wire   [256                -1 :0]       cbf_u_w                   ;   
  wire   [256                -1 :0]       cbf_v_w                   ;   

  // IinP flag
  wire   [3                  -1 :0]       IinP_flag_w               ;
  wire   [3                  -1 :0]       db_IinP_flag_w            ;
  wire   [3                  -1 :0]       ec_IinP_flag_w            ;

  // residual in the frame edge
  wire   [4                  -1 :0]       ctu_x_res_w               ;
  wire   [4                  -1 :0]       ctu_y_res_w               ;
//-------------------------------------------------------------------
//
//    Global Signals
//
//-------------------------------------------------------------------

  // sel_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      sel_r <= 0 ;
    else if( sys_start_i ) begin
      sel_r <= !sel_r ;
    end
  end

  // sel_mod_3_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      sel_mod_3_r <= 0 ;
    else if( sys_start_i ) begin
      if( sel_mod_3_r==2 )
        sel_mod_3_r <= 0 ;
      else begin
        sel_mod_3_r <= sel_mod_3_r + 1 ;
      end
    end
  end

assign ctu_x_res_w = sys_all_x_i[5:2] - 1 ;
assign ctu_y_res_w = sys_all_y_i[5:2] - 1 ;

//-------------------------------------------------------------------
//
//    pre_intra
//
//-------------------------------------------------------------------

prei_top_buf u_prei_top_buf(
    // sys_if
    .clk                 ( clk                  ) ,
    .rstn                ( rstn                 ) ,
    .prei_start_i        ( prei_start_i         ) ,
    .prei_done_o         ( prei_done_o          ) ,
    .sel_mod_2_i         ( sel_r                ) ,
    // prei_cur_if
    .prei_cur_ren_o      ( prei_cur_ren_o       ) ,
    .prei_cur_sel_o      ( prei_cur_sel_o       ) ,
    .prei_cur_size_o     ( prei_cur_size_o      ) ,
    .prei_cur_4x4_x_o    ( prei_cur_4x4_x_o     ) ,
    .prei_cur_4x4_y_o    ( prei_cur_4x4_y_o     ) ,
    .prei_cur_idx_o      ( prei_cur_idx_o       ) ,
    .prei_cur_data_i     ( prei_cur_data_i      ) ,
    // rc_if
    .rc_actual_bitnum_i  ( rc_actual_bitnum_i   ) ,
    .rc_qp_o             ( rc_qp_w              ) ,
    .rc_mod64_sum_o      ( sys_rc_mod64_sum_o   ) ,
    .rc_ctu_x_i          ( rc_ctu_x_i           ) ,
    .rc_ctu_y_i          ( rc_ctu_y_i           ) ,
    // rc_reg_if
    .rc_k                ( sys_rc_k             ) ,
    .rc_bitnum_i         ( sys_rc_bitnum_i      ) ,
    .rc_roi_height       ( sys_rc_roi_height    ) ,
    .rc_roi_width        ( sys_rc_roi_width     ) ,
    .rc_roi_x            ( sys_rc_roi_x         ) ,
    .rc_roi_y            ( sys_rc_roi_y         ) ,
    .rc_roi_enable       ( sys_rc_roi_enable    ) ,
    .rc_L1_frame_byte    ( sys_rc_L1_frame_byte ) ,
    .rc_L2_frame_byte    ( sys_rc_L2_frame_byte ) ,
    .rc_lcu_en           ( sys_rc_lcu_en        ) ,
    .rc_initial_qp       ( sys_init_qp_i        ) ,
    .rc_max_qp           ( sys_rc_max_qp        ) ,
    .rc_min_qp           ( sys_rc_min_qp        ) ,
    .rc_delta_qp         ( sys_rc_delta_qp      ) , 
    // posi_md_rd_if
    .posi_md_ena_i       ( posi_mod_rd_ena_w    ) ,
    .posi_md_addr_i      ( posi_mod_rd_adr_w    ) ,
    .posi_md_data_o      ( posi_mod_rd_dat_w    ) 
);

//-------------------------------------------------------------------
//
//    pos_intra
//
//-------------------------------------------------------------------

posi_top_buf u_posi_top_buf(
    .clk                  ( clk                  ) ,
    .rstn                 ( rstn                 ) ,
    .sys_start_i          ( sys_start_i          ) , // for buffer rotation
    .sys_posi4x4bit_i     ( sys_posi4x4bit_i     ) ,
    .qp_i                 ( posi_qp_w            ) ,
    // sys_if
    .posi_start_i         ( posi_start_i         ) ,
    .posi_done_o          ( posi_done_o          ) ,
    .ctu_x_res_i          ( ctu_x_res_w          ) ,
    .ctu_y_res_i          ( ctu_y_res_w          ) ,
    .ctu_x_all_i          ( sys_ctu_all_x_i      ) ,
    .ctu_y_all_i          ( sys_ctu_all_y_i      ) ,
    .ctu_x_cur_i          ( posi_ctu_x_i         ) ,
    .ctu_y_cur_i          ( posi_ctu_y_i         ) ,
    //md_rd_if
    .posi_mod_rd_ena_o    ( posi_mod_rd_ena_w    ) ,
    .posi_mod_rd_adr_o    ( posi_mod_rd_adr_w    ) ,
    .posi_mod_rd_dat_i    ( posi_mod_rd_dat_w    ) ,
    //posi_cur_if
    .posi_cur_rd_ena_o    ( posi_cur_rd_ena_o    ) ,
    .posi_cur_rd_sel_o    ( posi_cur_rd_sel_o    ) ,
    .posi_cur_rd_siz_o    ( posi_cur_rd_siz_o    ) ,
    .posi_cur_rd_4x4_x_o  ( posi_cur_rd_4x4_x_o  ) ,
    .posi_cur_rd_4x4_y_o  ( posi_cur_rd_4x4_y_o  ) ,
    .posi_cur_rd_idx_o    ( posi_cur_rd_idx_o    ) ,
    .posi_cur_rd_dat_i    ( posi_cur_rd_dat_i    ) ,
    // pt_o
    .posi_partition_o     ( intra_partition_w    ) ,
    .posi_cost_o          ( posi_cost_w          ) ,
    //rec_rd_mode
    .rec_md_rd_ena_i      ( rec_md_rd_ena_w      ) ,
    .rec_md_rd_adr_i      ( rec_md_rd_adr_w      ) ,
    .rec_md_rd_dat_o      ( rec_md_rd_dat_w      ) ,
    //cabac_rd_mode
    .ec_md_rd_ena_i       ( !ec_md_rd_ena_w      ) ,
    .ec_md_rd_adr_i       ( ec_md_rd_adr_w       ) ,
    .ec_md_rd_dat_o       ( ec_md_rd_dat_w       ) 
);  

//-------------------------------------------------------------------
//
//    ime
//
//-------------------------------------------------------------------

ime_top_buf u_ime_top_buf(
    // sys_if
    .clk                  ( clk                  ) ,
    .rstn                 ( rstn                 ) ,
    .sel_mod_2_i          ( sel_r                ) ,
    // ime_cfg_if
    .ime_cmd_num_i        ( sys_ime_cmd_num_i    ) ,
    .ime_cmd_dat_i        ( sys_ime_cmd_dat_i    ) ,
    // status
    .ime_downsample_o     ( ime_downsample_o     ) ,
    // ime_ctrl_if
    .ime_start_i          ( ime_start_i          ) ,
    .ime_qp_i             ( sys_init_qp_i        ) ,
    .ctu_x_res_i          ( ctu_x_res_w          ) ,
    .ctu_y_res_i          ( ctu_y_res_w          ) ,
    .sys_ctu_all_x_i      ( sys_ctu_all_x_i      ) ,
    .sys_ctu_all_y_i      ( sys_ctu_all_y_i      ) ,
    .ime_ctu_x_i          ( ime_ctu_x_i          ) ,
    .ime_ctu_y_i          ( ime_ctu_y_i          ) ,
    .ime_done_o           ( ime_done_o           ) ,
    // ime_cur_if
    .ime_cur_4x4_x_o      ( ime_cur_4x4_x_o      ) ,
    .ime_cur_4x4_y_o      ( ime_cur_4x4_y_o      ) ,
    .ime_cur_4x4_idx_o    ( ime_cur_4x4_idx_o    ) ,
    .ime_cur_sel_o        ( ime_cur_sel_o        ) ,
    .ime_cur_size_o       ( ime_cur_size_o       ) ,
    .ime_cur_rden_o       ( ime_cur_rden_o       ) ,
    .ime_cur_pel_i        ( ime_cur_pel_i        ) ,
    // ime_ref_if
    .ime_ref_hor_ena_o    ( ime_ref_rden_o       ) ,
    .ime_ref_hor_adr_x_o  ( ime_ref_x_o          ) ,
    .ime_ref_hor_adr_y_o  ( ime_ref_y_o          ) ,
    .ime_ref_hor_dat_i    ( ime_ref_pel_i        ) ,
    // ime_partition_if
    .ime_partition_o      ( inter_partition_w    ) ,
    // fme_read_ime_mv_if
    .fme_mv_rden_i        ( fme_mv_rden_w        ) ,
    .fme_mv_rdaddr_i      ( fme_mv_rdaddr_w      ) ,
    .fme_mv_data_o        ( fme_mv_data_w        ) 
  );

//-------------------------------------------------------------------
//
//    fme
//
//-------------------------------------------------------------------

fme_top_buf u_fme_top_buf(
    // global
    .clk                   ( clk                  ) ,
    .rstn                  ( rstn                 ) ,
    // skip thresh
    .skip_cost_thresh_08   ( skip_cost_thresh_08  ),
    .skip_cost_thresh_16   ( skip_cost_thresh_16  ),
    .skip_cost_thresh_32   ( skip_cost_thresh_32  ),
    .skip_cost_thresh_64   ( skip_cost_thresh_64  ),
    // sys_if
    .fme_start_i           ( fme_start_i          ) ,
    .fme_ctu_x_i           ( fme_ctu_x_i          ) ,
    .fme_ctu_y_i           ( fme_ctu_y_i          ) ,
    .sys_ctu_x_all_i       ( sys_ctu_all_x_i      ) ,
    .sys_ctu_y_all_i       ( sys_ctu_all_y_i      ) ,
    .sys_x_all_i           ( sys_all_x_i          ) ,
    .sys_y_all_i           ( sys_all_y_i          ) ,
    .IinP_flag_i           ( fme_IinP_flag_w      ) ,
    .rc_qp_i               ( fme_qp_w             ) ,
    .fme_done_o            ( fme_done_o           ) ,
    .sel_mod_2_i           ( sel_r                ) ,
    .sel_mod_3_i           ( sel_mod_3_r          ) ,
    // ime_if
    .fme_partition_i       ( fme_partition_w      ) ,
    .fme_mv_rden_o         ( fme_mv_rden_w        ) ,
    .fme_mv_rdaddr_o       ( fme_mv_rdaddr_w      ) ,
    .fme_mv_data_i         ( fme_mv_data_w        ) ,
    // cur_if
    .fme_cur_rden_o        ( fme_cur_rden_o       ) ,
    .fme_cur_4x4_idx_o     ( fme_cur_4x4_idx_o    ) ,
    .fme_cur_4x4_x_o       ( fme_cur_4x4_x_o      ) ,
    .fme_cur_4x4_y_o       ( fme_cur_4x4_y_o      ) ,
    .fme_cur_pel_i         ( fme_cur_pel_i        ) ,
    // ref_if
    .fme_ref_rden_o        ( fme_ref_rden_o       ) ,
    .fme_ref_idx_x_o       ( fme_ref_idx_x_o      ) ,
    .fme_ref_idx_y_o       ( fme_ref_idx_y_o      ) ,
    .fme_ref_pel_i         ( fme_ref_pel_i        ) ,
    // mc_mv_if
    .mc_mv_ren_i           ( mc_mv_rd_ena_w       ) ,
    .mc_mv_rdaddr_i        ( mc_mv_rd_adr_w       ) ,
    .mc_mv_o               ( mc_mv_rd_dat_w       ) ,
    // db_mv_if
    .db_mv_ren_i           ( db_mv_rd_ena_w       ) ,
    .db_mv_rdaddr_i        ( db_mv_rd_adr_w       ) ,
    .db_mv_o               ( db_mv_rd_dat_w       ) ,
    //fme_cost_if
    .fme_cost_o            ( fme_cost_w           ) ,
    // skip
    .skip_idx_o            ( fme_skip_idx_w       ) ,
    .skip_flag_o           ( fme_skip_flag_w      ) ,
    //mc_pred_if  
    .mc_pred_wr_ren_i      ( fme_wr_ena_w         ) ,
    .mc_pred_wr_size_i     ( fme_wr_siz_w         ) ,
    .mc_pred_wr_4x4_x_i    ( fme_wr_4x4_x_w       ) ,
    .mc_pred_wr_4x4_y_i    ( fme_wr_4x4_y_w       ) ,
    .mc_pred_wr_4x4_idx_i  ( fme_wr_idx_w         ) ,
    .mc_pred_wr_rdata_i    ( fme_wr_dat_w         ) ,  

    .mc_pred_rd_ren_i      ( fme_rd_ena_w         ) ,
    .mc_pred_rd_size_i     ( fme_rd_siz_w         ) ,
    .mc_pred_rd_4x4_x_i    ( fme_rd_4x4_x_w       ) ,
    .mc_pred_rd_4x4_y_i    ( fme_rd_4x4_y_w       ) ,
    .mc_pred_rd_4x4_idx_i  ( fme_rd_idx_w         ) ,
    .mc_pred_rd_rdata_o    ( fme_rd_dat_w         ) 
);


//-------------------------------------------------------------------
//
//    rec
//
//-------------------------------------------------------------------


rec_top u_rec_top(
    // global
    .clk                   ( clk                  ) ,
    .rstn                  ( rstn                 ) ,
    // ctrl_if      
    .start_i               ( rec_start_i          ) ,
    .done_o                ( rec_done_o           ) ,
    .sys_start_i           ( sys_start_i          ) , // for buffer rotation
    // pos_i      
    .ctu_x_all_i           ( sys_ctu_all_x_i      ) ,
    .ctu_y_all_i           ( sys_ctu_all_y_i      ) ,
    .ctu_x_res_i           ( ctu_x_res_w          ) ,
    .ctu_y_res_i           ( ctu_y_res_w          ) ,
    .ctu_x_cur_i           ( rec_ctu_x_i          ) ,
    .ctu_y_cur_i           ( rec_ctu_y_i          ) ,
    // cfg_i
    .qp_i                  ( rec_qp_w             ) ,
    .type_i                ( sys_type_i           ) ,
    .intra_partition_i     ( rec_intra_pt_w       ) ,
    .inter_partition_i     ( rec_inter_pt_w       ) ,
    .rec_skip_flag_i       ( rec_skip_flag_w      ) ,
    // mode_i
    .md_rd_ena_o           ( rec_md_rd_ena_w      ) ,
    .md_rd_adr_o           ( rec_md_rd_adr_w      ) ,
    .md_rd_dat_i           ( rec_md_rd_dat_w      ) ,
    // cur_i
    .cur_rd_ena_o          ( rec_cur_rd_ena_o     ) ,
    .cur_rd_sel_o          ( rec_cur_rd_sel_o     ) ,
    .cur_rd_siz_o          ( rec_cur_rd_siz_o     ) ,
    .cur_rd_4x4_x_o        ( rec_cur_rd_4x4_x_o   ) ,
    .cur_rd_4x4_y_o        ( rec_cur_rd_4x4_y_o   ) ,
    .cur_rd_idx_o          ( rec_cur_rd_idx_o     ) ,
    .cur_rd_dat_i          ( rec_cur_rd_dat_i     ) ,
    // mv_i
    .mv_rd_ena_o           ( mc_mv_rd_ena_w       ) ,
    .mv_rd_adr_o           ( mc_mv_rd_adr_w       ) ,
    .mv_rd_dat_i           ( mc_mv_rd_dat_w       ) ,
    // ref_i
    .ref_rd_ena_o          ( rec_ref_rd_ena_o     ) , 
    .ref_rd_sel_o          ( rec_ref_rd_sel_o     ) , 
    .ref_rd_idx_x_o        ( rec_ref_rd_idx_x_o   ) , 
    .ref_rd_idx_y_o        ( rec_ref_rd_idx_y_o   ) , 
    .ref_rd_dat_i          ( rec_ref_rd_dat_i     ) , 
    // fme_i
    .pre_fme_rd_ena_o      ( fme_rd_ena_w         ) ,
    .pre_fme_rd_siz_o      ( fme_rd_siz_w         ) ,
    .pre_fme_rd_4x4_x_o    ( fme_rd_4x4_x_w       ) ,
    .pre_fme_rd_4x4_y_o    ( fme_rd_4x4_y_w       ) ,
    .pre_fme_rd_idx_o      ( fme_rd_idx_w         ) ,
    .pre_fme_rd_dat_i      ( fme_rd_dat_w         ) ,
    // fme_o
    .pre_fme_wr_ena_o      ( fme_wr_ena_w         ) ,
    .pre_fme_wr_siz_o      ( fme_wr_siz_w         ) ,
    .pre_fme_wr_4x4_x_o    ( fme_wr_4x4_x_w       ) ,
    .pre_fme_wr_4x4_y_o    ( fme_wr_4x4_y_w       ) ,
    .pre_fme_wr_idx_o      ( fme_wr_idx_w         ) ,
    .pre_fme_wr_dat_o      ( fme_wr_dat_w         ) ,
    // rec_o
    .rec_rd_ena_i          ( db_rec_rd_ena_w      ) ,
    .rec_rd_sel_i          ( db_rec_rd_sel_w      ) ,
    .rec_rd_siz_i          ( db_rec_rd_siz_w      ) ,
    .rec_rd_4x4_x_i        ( db_rec_rd_4x4_x_w    ) ,
    .rec_rd_4x4_y_i        ( db_rec_rd_4x4_y_w    ) ,
    .rec_rd_idx_i          ( db_rec_rd_idx_w      ) ,
    .rec_rd_dat_o          ( db_rec_rd_dat_w      ) ,
    // rec_i
    .rec_wr_ena_i          ( db_rec_wr_ena_w      ) ,
    .rec_wr_sel_i          ( db_rec_wr_sel_w      ) ,
    .rec_wr_siz_i          ( db_rec_wr_siz_w      ) ,
    .rec_wr_4x4_x_i        ( db_rec_wr_4x4_x_w    ) ,
    .rec_wr_4x4_y_i        ( db_rec_wr_4x4_y_w    ) ,
    .rec_wr_idx_i          ( db_rec_wr_idx_w      ) ,
    .rec_wr_dat_i          ( db_rec_wr_dat_w      ) ,
    // coe_o
    .cef_rd_ena_i          ( ec_coe_rd_ena_w      ) ,
    .cef_rd_sel_i          ( ec_coe_rd_sel_w      ) ,
    .cef_rd_siz_i          ( ec_coe_rd_siz_w      ) ,
    .cef_rd_4x4_x_i        ( ec_coe_rd_4x4_x_w    ) ,
    .cef_rd_4x4_y_i        ( ec_coe_rd_4x4_y_w    ) ,
    .cef_rd_idx_i          ( ec_coe_rd_idx_w      ) ,
    .cef_rd_dat_o          ( ec_coe_rd_dat_w      ) ,
    // mvd_o
    .mvd_rd_ena_i          ( !ec_mvd_rd_en_w      ) ,
    .mvd_rd_adr_i          ( ec_mvd_rd_addr_w     ) ,
    .mvd_rd_dat_o          ( ec_mvd_rd_data_w     ) ,
    // cbf_o
    .cbf_y_o               ( cbf_y_w              ) ,
    .cbf_u_o               ( cbf_u_w              ) ,
    .cbf_v_o               ( cbf_v_w              ) ,
    // IinP
    .IinP_ena_i            ( sys_IinP_ena_i       ) ,
    .IinP_cst_I_i          ( posi_cost_w          ) ,
    .IinP_cst_P_i          ( fme_cost_w           ) ,
    .fme_IinP_flag_o       ( fme_IinP_flag_w      ) ,
    .IinP_flag_o           ( IinP_flag_w          ) // for db and cabac
);
//-------------------------------------------------------------------
//
//    dbsao
//
//-------------------------------------------------------------------

dbsao_top u_dbsao_top(
    .clk                   ( clk                  ) ,
    .rst_n                 ( rstn                 ) ,
    .sys_ctu_x_i           ( db_ctu_x_i           ) ,
    .sys_ctu_y_i           ( db_ctu_y_i           ) ,
    .sys_start_i           ( db_start_i           ) ,
    .sys_done_o            ( db_done_o            ) ,
    .rc_qp_i               ( db_qp_w              ) ,
    .sys_db_ena_i          ( sys_db_ena_i         ) ,
    .sys_sao_ena_i         ( sys_sao_ena_i        ) ,
    // ctu_info_if
    .mb_type_i             ( sys_type_i           ) ,  
    // I block in P frame
    .IinP_flag_i           ( db_IinP_flag_w       ) ,
  // ctu_info       
    .mb_partition_i        ( db_intra_pt_w        ) ,
    .mb_p_pu_mode_i        ( db_inter_pt_w        ) ,
    .mb_cbf_i              ( db_cbf_y_w           ) ,
    .mb_cbf_u_i            ( db_cbf_u_w           ) ,
    .mb_cbf_v_i            ( db_cbf_v_w           ) ,
    //mv_if
    .mb_mv_ren_o           ( db_mv_rd_ena_w       ) , 
    .mb_mv_raddr_o         ( db_mv_rd_adr_w       ) ,
    .mb_mv_rdata_i         ( db_mv_rd_dat_w       ) ,
    //rec_if
    .rec_rd_4x4_x_o        ( db_rec_rd_4x4_x_w    ) ,  
    .rec_rd_4x4_y_o        ( db_rec_rd_4x4_y_w    ) ,  
    .rec_rd_4x4_idx_o      ( db_rec_rd_idx_w      ) ,  
    .rec_rd_ren_o          ( db_rec_rd_ena_w      ) ,  
    .rec_rd_sel_o          ( db_rec_rd_sel_w      ) ,  
    .rec_rd_siz_o          ( db_rec_rd_siz_w      ) ,  
    .rec_rd_pxl_i          ( db_rec_rd_dat_w      ) ,  
    .rec_wr_4x4_x_o        ( db_rec_wr_4x4_x_w    ) ,  
    .rec_wr_4x4_y_o        ( db_rec_wr_4x4_y_w    ) ,  
    .rec_wr_4x4_idx_o      ( db_rec_wr_idx_w      ) ,  
    .rec_wr_wen_o          ( db_rec_wr_ena_w      ) ,  
    .rec_wr_sel_o          ( db_rec_wr_sel_w      ) ,  
    .rec_wr_siz_o          ( db_rec_wr_siz_w      ) ,  
    .rec_wr_pxl_o          ( db_rec_wr_dat_w      ) ,  
    // ori_if
    .ori_4x4_x_o           ( db_cur_4x4_x_o       ) ,
    .ori_4x4_y_o           ( db_cur_4x4_y_o       ) ,
    .ori_4x4_idx_o         ( db_cur_4x4_idx_o     ) ,
    .ori_ren_o             ( db_cur_ren_o         ) ,
    .ori_sel_o             ( db_cur_sel_o         ) ,
    .ori_siz_o             ( db_cur_siz_o         ) ,
    .ori_pxl_i             ( db_cur_pxl_i         ) ,
    //fetch_if
    .fetch_wen_o           ( fetch_wen_o          ) , 
    .fetch_w4x4_x_o        ( fetch_w4x4_x_o       ) ,
    .fetch_w4x4_y_o        ( fetch_w4x4_y_o       ) ,
    .fetch_wprevious_o     ( fetch_wprevious_o    ) ,
    .fetch_wdone_o         ( fetch_wdone_o        ) ,
    .fetch_wsel_o          ( fetch_wsel_o         ) ,
    .fetch_wdata_o         ( fetch_wdata_o        ) ,
    // top_rec_if
    .top_ren_o             ( top_ren_o            ) , 
    .top_r4x4_o            ( top_r4x4_o           ) ,
    .top_ridx_o            ( top_ridx_o           ) ,
    .top_rdata_i           ( top_rdata_i          ) ,
    // sao_if
    .sao_data_o            ( sao_data_w           )  
);

//-------------------------------------------------------------------
//
//    cabac
//
//-------------------------------------------------------------------

cabac_top u_cabac_top(
    // global if
    .clk                  ( clk                   ) ,
    .rst_n                ( rstn                  ) ,
    // sys if
    .sys_slice_type_i     ( !sys_type_i            ) ,
    .sys_total_x_i        ( sys_ctu_all_x_i       ) ,
    .sys_total_y_i        ( sys_ctu_all_y_i       ) ,
    .frame_width_remain_i ( sys_all_x_i[5:0]      ) ,
    .frame_height_remain_i( sys_all_y_i[5:0]      ) ,
    // cabac if
    .sys_mb_x_i           ( ec_ctu_x_i            ) ,
    .sys_mb_y_i           ( ec_ctu_y_i            ) ,
    .rc_qp_i              ( ec_qp_w               ) ,
    .rc_param_qp_i        ( sys_init_qp_i         ) ,
    .sys_start_i          ( ec_start_i            ) ,
    .cabac_done_o         ( ec_done_o             ) ,
    // sao if
    .sao_i                ( sao_data_w            ) ,
    // intra mode 
    .mb_i_luma_mode_data_i( ec_md_rd_dat_w        ) ,
    .mb_i_luma_mode_ren_o ( ec_md_rd_ena_w        ) ,
    .mb_i_luma_mode_addr_o( ec_md_rd_adr_w        ) ,
    // ctu if
    .mb_partition_i       ( ec_intra_pt_w         ) , // intra partition, cu partition
    .mb_p_pu_mode_i       ( ec_inter_pt_w         ) , // inter partition, pu partition
    .mb_skip_flag_i       ( ec_skip_flag_w        ) ,   
    .mb_merge_flag_i      ( ec_skip_flag_w        ) ,
    .mb_merge_idx_i       ( ec_skip_idx_w         ) ,
    // cabac_coe_if
    .ec_coe_rd_ena_o      ( ec_coe_rd_ena_w       ) ,
    .ec_coe_rd_sel_o      ( ec_coe_rd_sel_w       ) ,
    .ec_coe_rd_siz_o      ( ec_coe_rd_siz_w       ) ,
    .ec_coe_rd_4x4_x_o    ( ec_coe_rd_4x4_x_w     ) ,
    .ec_coe_rd_4x4_y_o    ( ec_coe_rd_4x4_y_w     ) ,
    .ec_coe_rd_idx_o      ( ec_coe_rd_idx_w       ) ,
    .mb_cef_data_i        ( ec_coe_rd_dat_w       ) ,
    // cbf_if
    .mb_cbf_y_i           ( ec_cbf_y_w            ) ,
    .mb_cbf_u_i           ( ec_cbf_u_w            ) ,
    .mb_cbf_v_i           ( ec_cbf_v_w            ) ,
    // ec inter mvd if
    .mb_mvd_data_i        ( ec_mvd_rd_data_w      ) ,
    .mb_mvd_ren_o         ( ec_mvd_rd_en_w        ) ,
    .mb_mvd_addr_o        ( ec_mvd_rd_addr_w      ) ,
    // bs if
    .bs_data_o            ( bs_data_o             ) ,
    .bs_val_o             ( bs_val_o              ) ,
    .slice_done_o         ( /* UNUSED    */       )
  );

enc_data_pipeline u_data_pipeline(
    // global
    .clk                  ( clk                   ) ,
    .rstn                 ( rstn                  ) ,
    .enc_done_i           ( enc_done_i            ) ,
    // qp pipeline
    .rc_qp_i              ( rc_qp_w               ) ,
    .posi_qp_o            ( posi_qp_w             ) ,
    .fme_qp_o             ( fme_qp_w              ) ,
    .rec_qp_o             ( rec_qp_w              ) ,
    .db_qp_o              ( db_qp_w               ) ,
    .ec_qp_o              ( ec_qp_w               ) ,
    // intra partition pipeline
    .intra_partition_i    ( intra_partition_w     ) ,
    .rec_intra_pt_o       ( rec_intra_pt_w        ) ,
    .db_intra_pt_o        ( db_intra_pt_w         ) ,
    .ec_intra_pt_o        ( ec_intra_pt_w         ) ,
    // inter partition pipeline
    .inter_partition_i    ( inter_partition_w     ) ,
    .fme_inter_pt_o       ( fme_partition_w       ) ,
    .rec_inter_pt_o       ( rec_inter_pt_w        ) ,
    .db_inter_pt_o        ( db_inter_pt_w         ) ,
    .ec_inter_pt_o        ( ec_inter_pt_w         ) ,
    // IinP flag pipeline
    .IinP_flag_i          ( IinP_flag_w           ) ,
    .db_IinP_flag_o       ( db_IinP_flag_w        ) ,
    .ec_IinP_flag_o       ( ec_IinP_flag_w        ) ,
    // cbf pipeline
    .cbf_y_i              ( cbf_y_w               ) ,
    .cbf_u_i              ( cbf_u_w               ) ,
    .cbf_v_i              ( cbf_v_w               ) ,
    .db_cbf_y_o           ( db_cbf_y_w            ) ,
    .db_cbf_u_o           ( db_cbf_u_w            ) ,
    .db_cbf_v_o           ( db_cbf_v_w            ) ,
    .ec_cbf_y_o           ( ec_cbf_y_w            ) ,
    .ec_cbf_u_o           ( ec_cbf_u_w            ) ,
    .ec_cbf_v_o           ( ec_cbf_v_w            ) ,
    // skip 
    .skip_idx_i           ( fme_skip_idx_w        ) ,
    .skip_flag_i          ( fme_skip_flag_w       ) ,
    .skip_idx_o           ( ec_skip_idx_w         ) ,
    .skip_flag_o          ( ec_skip_flag_w        ) ,
    .rec_skip_flag_o      ( rec_skip_flag_w       ) ,
    // ec_bitnum
    .bs_val_i             ( bs_val_o              ) ,
    .rc_actual_bitnum_o   ( rc_actual_bitnum_i    )

  );
 

endmodule 