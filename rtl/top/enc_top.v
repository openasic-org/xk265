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
//  Filename      : h265enc_top.v
//  Author        : Huang Leilei
//  Created       : 2016-03-20
//  Description   : top of h265enc, including sys_ctrl, enc_core and fetch
//
//-------------------------------------------------------------------
//
//  Modified      : 2018-01-26 by Yibo Fan
//  Description   :
//  Modified      : 2016-03-22
//  Description   : fetch replaced with fetch_top
//  Modified      : 2018-04-22 by TANG
//  Description   : update interfaces  
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module h265enc_top(
  // global
  clk                 ,
  rstn                ,
  // sys_cfg_if
  sys_start_i         ,
  sys_type_i          ,
  sys_all_x_i         ,
  sys_all_y_i         ,
  sys_init_qp_i       ,
  sys_done_o          ,
  sys_IinP_ena_i      ,
  sys_db_ena_i        ,
  sys_sao_ena_i       ,
  sys_posi4x4bit_i    ,
  // skip cost thresh
  skip_cost_thresh_08 ,
  skip_cost_thresh_16 ,
  skip_cost_thresh_32 ,
  skip_cost_thresh_64 ,
  // rc_cfg_if
  sys_rc_mod64_sum_o  ,
  sys_rc_bitnum_i     ,
  sys_rc_k            ,
  sys_rc_roi_height   ,
  sys_rc_roi_width    ,
  sys_rc_roi_x        ,
  sys_rc_roi_y        ,
  sys_rc_roi_enable   ,
  sys_rc_L1_frame_byte,
  sys_rc_L2_frame_byte,
  sys_rc_lcu_en       ,
  sys_rc_max_qp       ,
  sys_rc_min_qp       ,
  sys_rc_delta_qp     ,
  // ime_cfg_if
  sys_ime_cmd_num_i   ,
  sys_ime_cmd_dat_i   ,
  // ext_if
  extif_start_o       ,
  extif_done_i        ,
  extif_mode_o        ,
  extif_x_o           ,
  extif_y_o           ,
  extif_width_o       ,
  extif_height_o      ,
  extif_wren_i        ,
  extif_rden_i        ,
  extif_data_i        ,
  extif_data_o        ,
  // bs_if
  bs_val_o            ,
  bs_dat_o
  );


//*** parameter declaration ****************************************************************
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

//*** wire/reg declaration *****************************************************

  // global
  input                                 clk                   ;
  input                                 rstn                  ;

  // cfg
  input                                 sys_start_i           ;
  output                                sys_done_o            ;
  input  [`PIC_WIDTH           -1 :0]   sys_all_x_i           ; // pixel number in x
  input  [`PIC_HEIGHT          -1 :0]   sys_all_y_i           ; // pixel number in y
  input  [5                       :0]   sys_init_qp_i         ;
  input                                 sys_type_i            ;
  input                                 sys_IinP_ena_i        ; // enable I block in P frame
  input                                 sys_db_ena_i          ;
  input                                 sys_sao_ena_i         ;
  input  [5-1:0]                        sys_posi4x4bit_i      ;
  // skip cost thresh
  input   [32-1:0]                      skip_cost_thresh_08   ;
  input   [32-1:0]                      skip_cost_thresh_16   ;
  input   [32-1:0]                      skip_cost_thresh_32   ;
  input   [32-1:0]                      skip_cost_thresh_64   ;

  output [32                   -1 :0]   sys_rc_mod64_sum_o    ;
  input  [32                   -1 :0]   sys_rc_bitnum_i       ;
  input  [16                   -1 :0]   sys_rc_k              ;
  input  [6                    -1 :0]   sys_rc_roi_height     ;
  input  [7                    -1 :0]   sys_rc_roi_width      ;
  input  [7                    -1 :0]   sys_rc_roi_x          ;
  input  [7                    -1 :0]   sys_rc_roi_y          ;
  input                                 sys_rc_roi_enable     ;
  input  [10                   -1 :0]   sys_rc_L1_frame_byte  ;
  input  [10                   -1 :0]   sys_rc_L2_frame_byte  ;
  input                                 sys_rc_lcu_en         ;
  input  [6                    -1 :0]   sys_rc_max_qp         ;
  input  [6                    -1 :0]   sys_rc_min_qp         ;
  input  [6                    -1 :0]   sys_rc_delta_qp       ;
  // ime_if
  input  [CMD_NUM_WIDTH        -1 :0]   sys_ime_cmd_num_i     ;
  input  [CMD_DAT_WIDTH        -1 :0]   sys_ime_cmd_dat_i     ;
  // EXT_IF
  output [1-1                    : 0]   extif_start_o         ;
  input  [1-1                    : 0]   extif_done_i          ;
  output [5-1                    : 0]   extif_mode_o          ;
  output [6+`PIC_X_WIDTH       -1: 0]   extif_x_o             ;
  output [6+`PIC_Y_WIDTH       -1: 0]   extif_y_o             ;
  output [8-1                    : 0]   extif_width_o         ;
  output [8-1                    : 0]   extif_height_o        ;
  input                                 extif_wren_i          ;
  input                                 extif_rden_i          ;
  input  [16*`PIXEL_WIDTH      -1: 0]   extif_data_i          ;
  output [16*`PIXEL_WIDTH      -1: 0]   extif_data_o          ;

  // BS
  output                                bs_val_o              ;
  output  [7                    : 0]    bs_dat_o              ;
  // output                                slice_done_o          ;


//*** WIRE/REG DECLARATION *****************************************************
  // global 
  wire [`PIC_X_WIDTH-1         : 0]     sys_ctu_all_x_i       ;
  wire [`PIC_Y_WIDTH-1         : 0]     sys_ctu_all_y_i       ;
  // PREI_SYS_IF
  wire                                  prei_start            ;
  wire [`PIC_X_WIDTH-1         : 0]     prei_x                ;
  wire [`PIC_Y_WIDTH-1         : 0]     prei_y                ;
  wire                                  prei_done             ;

  // PREI_CUR_IF
  wire [3                      : 0]     prei_cur_4x4_x_w      ;
  wire [3                      : 0]     prei_cur_4x4_y_w      ;
  wire [4                      : 0]     prei_cur_idx_w        ;
  wire [1                      : 0]     prei_cur_sel_w        ;
  wire [1                      : 0]     prei_cur_size_w       ;
  wire                                  prei_cur_ren_w        ;
  wire [`PIXEL_WIDTH*32-1      : 0]     prei_cur_dat_w        ;

  // POSI_SYS_IF
  wire                                  posi_start            ;
  wire [`PIC_X_WIDTH-1         : 0]     posi_x                ;
  wire [`PIC_Y_WIDTH-1         : 0]     posi_y                ;
  wire                                  posi_done             ;

  // POSI_CUR_IF
  wire                                  posi_cur_rd_ena_w     ;
  wire [1                      : 0]     posi_cur_rd_sel_w     ;
  wire [1                      : 0]     posi_cur_rd_siz_w     ;
  wire [3                      : 0]     posi_cur_rd_4x4_x_w   ;
  wire [3                      : 0]     posi_cur_rd_4x4_y_w   ;
  wire [4                      : 0]     posi_cur_rd_idx_w     ;
  wire [`PIXEL_WIDTH*32-1      : 0]     posi_cur_rd_dat_w     ;

  // IME_SYS_IF
  wire                                  ime_start             ;
  wire [`PIC_X_WIDTH-1         : 0]     ime_x                 ;
  wire [`PIC_Y_WIDTH-1         : 0]     ime_y                 ;
  wire                                  ime_downsample_w      ;
  wire                                  ime_done              ;

  wire                                  ime_cur_rden_w        ;
  wire [4-1                     : 0]    ime_cur_4x4_x_w       ;
  wire [4-1                     : 0]    ime_cur_4x4_y_w       ;
  wire [5-1                     : 0]    ime_cur_4x4_idx_w     ;
  wire [2-1                     : 0]    ime_cur_siz_w         ;
  wire [2-1                     : 0]    ime_cur_sel_w         ;
  wire [32*`PIXEL_WIDTH-1       : 0]    ime_cur_dat_w         ;

  wire [`PIC_X_WIDTH-1          : 0]    ime_ref_cur_x_i       ;
  wire [`PIC_Y_WIDTH-1          : 0]    ime_ref_cur_y_i       ;
  wire [`IME_MV_WIDTH_X         : 0]    ime_ref_idx_x_w       ;
  wire [`IME_MV_WIDTH_Y         : 0]    ime_ref_idx_y_w       ;
  wire [1-1                     : 0]    ime_ref_rden_w        ;
  wire [32*`PIXEL_WIDTH-1       : 0]    ime_ref_pel_w         ;

  // FME_SYS_IF
  wire                                  fme_start             ;
  wire [`PIC_X_WIDTH-1         : 0]     fme_x                 ;
  wire [`PIC_Y_WIDTH-1         : 0]     fme_y                 ;
  wire                                  fme_done              ;

  // FME_CUR_IF
  wire                                  fme_cur_rden_w        ;
  wire [5                    -1 :0]     fme_cur_4x4_idx_w     ;
  wire [4                    -1 :0]     fme_cur_4x4_x_w       ;
  wire [4                    -1 :0]     fme_cur_4x4_y_w       ;
  wire [32*`PIXEL_WIDTH      -1 :0]     fme_cur_pel_w         ;

  wire                                  fme_ref_rden_w        ;
  wire [8                    -1 :0]     fme_ref_idx_x_w       ;
  wire [8                    -1 :0]     fme_ref_idx_y_w       ;
  wire [64*`PIXEL_WIDTH      -1 :0]     fme_ref_pel_w         ;


  // REC_SYS_IF
  wire                                  rec_start             ;
  wire [`PIC_X_WIDTH-1       : 0]       rec_x                 ;
  wire [`PIC_Y_WIDTH-1       : 0]       rec_y                 ;
  wire                                  rec_done              ;

  wire                                  rec_cur_rd_ena_w      ;
  wire [2                  -1 :0]       rec_cur_rd_sel_w      ;
  wire [2                  -1 :0]       rec_cur_rd_siz_w      ;
  wire [4                  -1 :0]       rec_cur_rd_4x4_x_w    ;
  wire [4                  -1 :0]       rec_cur_rd_4x4_y_w    ;
  wire [5                  -1 :0]       rec_cur_rd_idx_w      ;
  wire [`PIXEL_WIDTH*32    -1 :0]       rec_cur_rd_dat_w      ;

  wire                                  rec_ref_rd_ena_w      ;
  wire [2                  -1 :0]       rec_ref_rd_sel_w      ;
  wire [8                  -1 :0]       rec_ref_rd_idx_x_w    ;
  wire [8                  -1 :0]       rec_ref_rd_idx_y_w    ;
  wire [`PIXEL_WIDTH*8     -1 :0]       rec_ref_rd_dat_w      ;

  // DB_SYS_IF
  wire                                  db_start              ;
  wire [`PIC_X_WIDTH       -1 :0]       db_x                  ;
  wire [`PIC_Y_WIDTH       -1 :0]       db_y                  ;
  wire                                  db_done               ;
  // DB_cur
  wire [4                  -1 :0]       db_cur_rd_4x4_x_w     ;
  wire [4                  -1 :0]       db_cur_rd_4x4_y_w     ;
  wire [5                  -1 :0]       db_cur_rd_4x4_idx_w   ;
  wire                                  db_cur_rd_ena_w       ;
  wire [2                  -1 :0]       db_cur_rd_sel_w       ;
  wire [2                  -1 :0]       db_cur_rd_siz_w       ;
  wire [`PIXEL_WIDTH*32    -1 :0]       db_cur_rd_pxl_w       ;
  // FETCH
  wire                                  fetch_wen_w           ;
  wire [5                  -1 :0]       fetch_w4x4_x_w        ;
  wire [5                  -1 :0]       fetch_w4x4_y_w        ;
  wire                                  fetch_wprevious_w     ;
  wire                                  fetch_wdone_w         ;
  wire [2                  -1 :0]       fetch_wsel_w          ;
  wire [`PIXEL_WIDTH*16    -1 :0]       fetch_wdata_w         ;

  wire                                  db_top_ren_w          ;
  wire [5                  -1 :0]       db_top_r4x4_w         ;
  wire [2                  -1 :0]       db_top_ridx_w         ;
  wire [`PIXEL_WIDTH*4     -1 :0]       db_top_rdata_w        ;

  // db_store_SYS_IF
  wire                                  db_store_start        ;
  wire [`PIC_X_WIDTH       -1 :0]       db_store_x            ;
  wire [`PIC_Y_WIDTH       -1 :0]       db_store_y            ;
  wire                                  db_store_done         ;

  // EC_SYS_IF
  wire                                  ec_start              ;
  wire [`PIC_X_WIDTH       -1 :0]       ec_x                  ;
  wire [`PIC_Y_WIDTH       -1 :0]       ec_y                  ;
  wire                                  ec_done               ;

  // FETCH
  wire                                  enc_start             ;
  wire                                  fetch_done            ;
  wire                                  load_cur_luma_ena     ;
  wire                                  load_ref_luma_ena     ;
  wire                                  load_cur_chroma_ena   ;
  wire                                  load_ref_chroma_ena   ;
  wire                                  load_db_luma_ena      ;
  wire                                  load_db_chroma_ena    ;
  wire                                  store_db_luma_ena     ;
  wire                                  store_db_chroma_ena   ;
  wire      [`PIC_X_WIDTH-1     : 0]    load_cur_luma_x       ;
  wire      [`PIC_Y_WIDTH-1     : 0]    load_cur_luma_y       ;
  wire      [`PIC_X_WIDTH-1     : 0]    load_cur_chroma_x     ;
  wire      [`PIC_Y_WIDTH-1     : 0]    load_cur_chroma_y     ;
  wire      [`PIC_X_WIDTH-1     : 0]    load_ref_luma_x       ;
  wire      [`PIC_Y_WIDTH-1     : 0]    load_ref_luma_y       ;
  wire      [`PIC_X_WIDTH-1     : 0]    load_ref_chroma_x     ;
  wire      [`PIC_Y_WIDTH-1     : 0]    load_ref_chroma_y     ;
  wire      [`PIC_X_WIDTH-1     : 0]    load_db_luma_x        ;
  wire      [`PIC_Y_WIDTH-1     : 0]    load_db_luma_y        ;
  wire      [`PIC_X_WIDTH-1     : 0]    load_db_chroma_x      ;
  wire      [`PIC_Y_WIDTH-1     : 0]    load_db_chroma_y      ;
  wire      [`PIC_X_WIDTH-1     : 0]    store_db_luma_x       ;
  wire      [`PIC_Y_WIDTH-1     : 0]    store_db_luma_y       ;
  wire      [`PIC_X_WIDTH-1     : 0]    store_db_chroma_x     ;
  wire      [`PIC_Y_WIDTH-1     : 0]    store_db_chroma_y     ;

  // enc_done_w
  wire                                  enc_done_w            ;


//*** DUT DECLARATION **********************************************************
  
  assign sys_ctu_all_x_i = ((sys_all_x_i + `LCU_SIZE - 1'b1 ) / `LCU_SIZE) - 1'b1;
  assign sys_ctu_all_y_i = ((sys_all_y_i + `LCU_SIZE - 1'b1 ) / `LCU_SIZE) - 1'b1;

//--- SYS_CTRL -----------------------------------

  enc_ctrl u_enc_ctrl(
    // global
    .clk                   ( clk                  ),
    .rstn                  ( rstn                 ),
    // sys_if
    .sys_start_i           ( sys_start_i          ),
    .sys_type_i            ( sys_type_i           ),
    .sys_ctu_all_x_i       ( sys_ctu_all_x_i      ),
    .sys_ctu_all_y_i       ( sys_ctu_all_y_i      ),
    .sys_done_o            ( sys_done_o           ),
    // start_if
    .enc_start_o           ( enc_start            ),
    // done_if
    .fetch_done_i          ( fetch_done           ),
    .prei_done_i           ( prei_done            ),
    .posi_done_i           ( posi_done            ),
    .ime_done_i            ( ime_done             ),
    .fme_done_i            ( fme_done             ),
    .rec_done_i            ( rec_done             ),
    .db_done_i             ( db_done              ),
    .ec_done_i             ( ec_done              ),
    .enc_done_r            ( enc_done_w           ),
    // start for enc_core
    .prei_start_o          ( prei_start           ),
    .posi_start_o          ( posi_start           ),
    .ime_start_o           ( ime_start            ),
    .fme_start_o           ( fme_start            ),
    .rec_start_o           ( rec_start            ),
    .db_start_o            ( db_start             ),
    .ec_start_o            ( ec_start             ),
    .store_db_start_o      ( db_store_start       ),
    // x & y for enc_core
    .prei_x_o              ( prei_x               ),
    .prei_y_o              ( prei_y               ),
    .posi_x_o              ( posi_x               ),
    .posi_y_o              ( posi_y               ),
    .ime_x_o               ( ime_x                ),
    .ime_y_o               ( ime_y                ),
    .fme_x_o               ( fme_x                ),
    .fme_y_o               ( fme_y                ),
    .rec_x_o               ( rec_x                ),
    .rec_y_o               ( rec_y                ),
    .db_x_o                ( db_x                 ),
    .db_y_o                ( db_y                 ),
    .ec_x_o                ( ec_x                 ),
    .ec_y_o                ( ec_y                 ),
    .store_db_x_o          ( db_store_x           ),
    .store_db_y_o          ( db_store_y           ),
    // enc for fetch
    .load_cur_luma_ena_o   ( load_cur_luma_ena    ),
    .load_ref_luma_ena_o   ( load_ref_luma_ena    ),
    .load_cur_chroma_ena_o ( load_cur_chroma_ena  ),
    .load_ref_chroma_ena_o ( load_ref_chroma_ena  ),
    .load_db_luma_ena_o    ( load_db_luma_ena     ),
    .load_db_chroma_ena_o  ( load_db_chroma_ena   ),
    .store_db_luma_ena_o   ( store_db_luma_ena    ),
    .store_db_chroma_ena_o ( store_db_chroma_ena  ),
    // x & y for fetch
    .load_cur_luma_x_o     ( load_cur_luma_x      ),
    .load_cur_luma_y_o     ( load_cur_luma_y      ),
    .load_cur_chroma_x_o   ( load_cur_chroma_x    ),
    .load_cur_chroma_y_o   ( load_cur_chroma_y    ),
    .load_ref_luma_x_o     ( load_ref_luma_x      ),
    .load_ref_luma_y_o     ( load_ref_luma_y      ),
    .load_ref_chroma_x_o   ( load_ref_chroma_x    ),
    .load_ref_chroma_y_o   ( load_ref_chroma_y    ),
    .load_db_luma_x_o      ( load_db_luma_x       ),
    .load_db_luma_y_o      ( load_db_luma_y       ),
    .load_db_chroma_x_o    ( load_db_chroma_x     ),
    .load_db_chroma_y_o    ( load_db_chroma_y     ),
    .store_db_luma_x_o     ( store_db_luma_x      ),
    .store_db_luma_y_o     ( store_db_luma_y      ),
    .store_db_chroma_x_o   ( store_db_chroma_x    ),
    .store_db_chroma_y_o   ( store_db_chroma_y    )
    );


//--- FETCH --------------------------------------

  fetch_top u_fetch_top (
    .clk                   ( clk                  ),
    .rstn                  ( rstn                 ),
    // sys_if
    .sysif_type_i          ( sys_type_i           ),
    .sys_ctu_all_x_i       ( sys_ctu_all_x_i      ),
    .sys_ctu_all_y_i       ( sys_ctu_all_y_i      ),
    .sys_all_x_i           ( sys_all_x_i          ),
    .sys_all_y_i           ( sys_all_y_i          ),
    // ctrl_if
    .sysif_start_i         ( enc_start            ),
    .sysif_done_o          ( fetch_done           ),
    .load_cur_luma_ena_i   ( load_cur_luma_ena    ),
    .load_ref_luma_ena_i   ( load_ref_luma_ena    ),
    .load_cur_chroma_ena_i ( load_cur_chroma_ena  ),
    .load_ref_chroma_ena_i ( load_ref_chroma_ena  ),
    .load_db_luma_ena_i    ( load_db_luma_ena     ),
    .load_db_chroma_ena_i  ( load_db_chroma_ena   ),
    .store_db_luma_ena_i   ( store_db_luma_ena    ),
    .store_db_chroma_ena_i ( store_db_chroma_ena  ),
    .load_cur_luma_x_i     ( load_cur_luma_x      ),
    .load_cur_luma_y_i     ( load_cur_luma_y      ),
    .load_ref_luma_x_i     ( load_ref_luma_x      ),
    .load_ref_luma_y_i     ( load_ref_luma_y      ),
    .load_cur_chroma_x_i   ( load_cur_chroma_x    ),
    .load_cur_chroma_y_i   ( load_cur_chroma_y    ),
    .load_ref_chroma_x_i   ( load_ref_chroma_x    ),
    .load_ref_chroma_y_i   ( load_ref_chroma_y    ),
    .load_db_luma_x_i      ( load_db_luma_x       ),
    .load_db_luma_y_i      ( load_db_luma_y       ),
    .load_db_chroma_x_i    ( load_db_chroma_x     ),
    .load_db_chroma_y_i    ( load_db_chroma_y     ),
    .store_db_luma_x_i     ( store_db_luma_x      ),
    .store_db_luma_y_i     ( store_db_luma_y      ),
    .store_db_chroma_x_i   ( store_db_chroma_x    ),
    .store_db_chroma_y_i   ( store_db_chroma_y    ),
    // prei_cur_if
    .prei_cur_4x4_x_i      ( prei_cur_4x4_x_w     ),
    .prei_cur_4x4_y_i      ( prei_cur_4x4_y_w     ),
    .prei_cur_4x4_idx_i    ( prei_cur_idx_w       ),
    .prei_cur_sel_i        ( prei_cur_sel_w       ),
    .prei_cur_size_i       ( prei_cur_size_w      ),
    .prei_cur_rden_i       ( prei_cur_ren_w       ),
    .prei_cur_pel_o        ( prei_cur_dat_w       ),
    // posi_cur_if
    .posi_cur_rden_i       ( posi_cur_rd_ena_w    ) ,
    .posi_cur_sel_i        ( posi_cur_rd_sel_w    ) ,
    .posi_cur_size_i       ( posi_cur_rd_siz_w    ) ,
    .posi_cur_4x4_x_i      ( posi_cur_rd_4x4_x_w  ) ,
    .posi_cur_4x4_y_i      ( posi_cur_rd_4x4_y_w  ) ,
    .posi_cur_4x4_idx_i    ( posi_cur_rd_idx_w    ) ,
    .posi_cur_pel_o        ( posi_cur_rd_dat_w    ) ,
      // ime_cur_if
    .ime_cur_4x4_x_i       ( ime_cur_4x4_x_w     ) ,
    .ime_cur_4x4_y_i       ( ime_cur_4x4_y_w     ) ,
    .ime_cur_4x4_idx_i     ( ime_cur_4x4_idx_w   ) ,
    .ime_cur_sel_i         ( `TYPE_Y             ) ,
    .ime_cur_size_i        ( ime_cur_siz_w       ) ,
    .ime_cur_rden_i        ( ime_cur_rden_w      ) ,
    .ime_cur_downsample_i  ( ime_downsample_w    ) ,
    .ime_cur_pel_o         ( ime_cur_dat_w       ) ,
    // ime_ref_if   
    .ime_ref_cur_x_i       ( ime_x               ) ,
    .ime_ref_cur_y_i       ( ime_y               ) ,
    .ime_ref_x_i           ( ime_ref_idx_x_w     ) ,
    .ime_ref_y_i           ( ime_ref_idx_y_w     ) ,
    .ime_ref_rden_i        ( ime_ref_rden_w      ) ,
    .ime_ref_pel_o         ( ime_ref_pel_w       ) ,
    // fme_cur_if
    .fme_cur_4x4_x_i       ( fme_cur_4x4_x_w     ) ,
    .fme_cur_4x4_y_i       ( fme_cur_4x4_y_w     ) ,
    .fme_cur_4x4_idx_i     ( fme_cur_4x4_idx_w   ) ,
    .fme_cur_sel_i         ( `TYPE_Y             ) ,
    .fme_cur_size_i        ( `SIZE_08            ) ,
    .fme_cur_rden_i        ( fme_cur_rden_w      ) ,
    .fme_cur_pel_o         ( fme_cur_pel_w       ) ,
    // fme_ref_if
    .fme_ref_cur_x_i       ( fme_x               ) ,
    .fme_ref_cur_y_i       ( fme_y               ) ,
    .fme_ref_x_i           ( fme_ref_idx_x_w     ) ,
    .fme_ref_y_i           ( fme_ref_idx_y_w     ) ,
    .fme_ref_rden_i        ( fme_ref_rden_w      ) ,
    .fme_ref_pel_o         ( fme_ref_pel_w       ) ,
    // rec_ref_if
    .rec_ref_cur_x_i       ( rec_x               ) , //lcu index
    .rec_ref_cur_y_i       ( rec_y               ) , 
    .rec_ref_x_i           ( rec_ref_rd_idx_x_w  ) ,
    .rec_ref_y_i           ( rec_ref_rd_idx_y_w  ) ,
    .rec_ref_rden_i        ( rec_ref_rd_ena_w    ) ,
    .rec_ref_sel_i         ( rec_ref_rd_sel_w    ) ,
    .rec_ref_pel_o         ( rec_ref_rd_dat_w    ) ,
    // rec_cur_if 
    .rec_cur_4x4_x_i       ( rec_cur_rd_4x4_x_w  ) ,
    .rec_cur_4x4_y_i       ( rec_cur_rd_4x4_y_w  ) ,
    .rec_cur_4x4_idx_i     ( rec_cur_rd_idx_w    ) ,
    .rec_cur_sel_i         ( rec_cur_rd_sel_w    ) ,
    .rec_cur_size_i        ( rec_cur_rd_siz_w    ) ,
    .rec_cur_rden_i        ( rec_cur_rd_ena_w    ) ,
    .rec_cur_pel_o         ( rec_cur_rd_dat_w    ) ,
    // db_cur_if
    .db_cur_4x4_x_i        ( db_cur_rd_4x4_x_w   ) ,
    .db_cur_4x4_y_i        ( db_cur_rd_4x4_y_w   ) ,
    .db_cur_4x4_idx_i      ( db_cur_rd_4x4_idx_w ) ,
    .db_cur_rden_i         ( db_cur_rd_ena_w     ) ,
    .db_cur_sel_i          ( db_cur_rd_sel_w     ) ,
    .db_cur_size_i         ( db_cur_rd_siz_w     ) ,
    .db_cur_pel_o          ( db_cur_rd_pxl_w     ) ,
    // fetch_if
    .db_wen_i              ( fetch_wen_w         ) ,
    .db_w4x4_x_i           ( fetch_w4x4_x_w      ) ,
    .db_w4x4_y_i           ( fetch_w4x4_y_w      ) ,
    .db_wprevious_i        ( fetch_wprevious_w   ) ,
    .db_done_i             ( fetch_wdone_w       ) ,
    .db_wsel_i             ( fetch_wsel_w        ) ,
    .db_wdata_i            ( fetch_wdata_w       ) ,
    // db_top_rec_if
    .db_ren_i              ( db_top_ren_w        ) ,
    .db_r4x4_i             ( db_top_r4x4_w       ) ,
    .db_ridx_i             ( db_top_ridx_w       ) ,
    .db_rdata_o            ( db_top_rdata_w      ) ,
    // ext_if 
    .extif_start_o         ( extif_start_o       ) ,
    .extif_done_i          ( extif_done_i        ) ,
    .extif_mode_o          ( extif_mode_o        ) ,
    .extif_x_o             ( extif_x_o           ) ,
    .extif_y_o             ( extif_y_o           ) ,
    .extif_width_o         ( extif_width_o       ) ,
    .extif_height_o        ( extif_height_o      ) ,
    .extif_wren_i          ( extif_wren_i        ) ,
    .extif_rden_i          ( extif_rden_i        ) ,
    .extif_data_i          ( extif_data_i        ) ,
    .extif_data_o          ( extif_data_o        ) 
    );


//--- enc_core ------------------------------------
  enc_core u_enc_core(
    // global signal
    .clk                    ( clk                 ) ,
    .rstn                   ( rstn                ) ,
    .sys_ctu_all_x_i        ( sys_ctu_all_x_i     ) ,
    .sys_ctu_all_y_i        ( sys_ctu_all_y_i     ) ,
    .sys_all_x_i            ( sys_all_x_i         ) ,
    .sys_all_y_i            ( sys_all_y_i         ) ,
    .sys_type_i             ( sys_type_i          ) ,
    .sys_start_i            ( enc_start           ) ,
    .enc_done_i             ( enc_done_w          ) ,
    .sys_IinP_ena_i         ( sys_IinP_ena_i      ) ,
    .sys_db_ena_i           ( sys_db_ena_i        ) ,
    .sys_sao_ena_i          ( sys_sao_ena_i       ) ,
    .sys_posi4x4bit_i       ( sys_posi4x4bit_i    ) ,
    // skip thresh
    .skip_cost_thresh_08    ( skip_cost_thresh_08 ) ,
    .skip_cost_thresh_16    ( skip_cost_thresh_16 ) ,
    .skip_cost_thresh_32    ( skip_cost_thresh_32 ) ,
    .skip_cost_thresh_64    ( skip_cost_thresh_64 ) ,
    // prei_if
    .prei_start_i           ( prei_start          ) ,
    .prei_done_o            ( prei_done           ) ,
    .rc_ctu_x_i             ( prei_x              ) ,
    .rc_ctu_y_i             ( prei_y              ) ,
    .prei_cur_ren_o         ( prei_cur_ren_w      ) ,
    .prei_cur_sel_o         ( prei_cur_sel_w      ) ,
    .prei_cur_size_o        ( prei_cur_size_w     ) ,
    .prei_cur_4x4_x_o       ( prei_cur_4x4_x_w    ) ,
    .prei_cur_4x4_y_o       ( prei_cur_4x4_y_w    ) ,
    .prei_cur_idx_o         ( prei_cur_idx_w      ) ,
    .prei_cur_data_i        ( prei_cur_dat_w      ) ,
    // rc_if
    .sys_rc_mod64_sum_o     ( sys_rc_mod64_sum_o  ) ,
    .sys_rc_bitnum_i        ( sys_rc_bitnum_i     ) ,
    .sys_rc_k               ( sys_rc_k            ) ,
    .sys_rc_roi_height      ( sys_rc_roi_height   ) ,
    .sys_rc_roi_width       ( sys_rc_roi_width    ) ,
    .sys_rc_roi_x           ( sys_rc_roi_x        ) ,
    .sys_rc_roi_y           ( sys_rc_roi_y        ) ,
    .sys_rc_roi_enable      ( sys_rc_roi_enable   ) ,
    .sys_rc_L1_frame_byte   ( sys_rc_L1_frame_byte) ,
    .sys_rc_L2_frame_byte   ( sys_rc_L2_frame_byte) ,
    .sys_rc_lcu_en          ( sys_rc_lcu_en       ) ,
    .sys_init_qp_i          ( sys_init_qp_i       ) ,
    .sys_rc_max_qp          ( sys_rc_max_qp       ) ,
    .sys_rc_min_qp          ( sys_rc_min_qp       ) ,
    .sys_rc_delta_qp        ( sys_rc_delta_qp     ) ,
    // posi_if
    .posi_start_i           ( posi_start          ) ,
    .posi_done_o            ( posi_done           ) ,
    .posi_ctu_x_i           ( posi_x              ) ,
    .posi_ctu_y_i           ( posi_y              ) ,
    .posi_cur_rd_ena_o      ( posi_cur_rd_ena_w   ) ,
    .posi_cur_rd_sel_o      ( posi_cur_rd_sel_w   ) ,
    .posi_cur_rd_siz_o      ( posi_cur_rd_siz_w   ) ,
    .posi_cur_rd_4x4_x_o    ( posi_cur_rd_4x4_x_w ) ,
    .posi_cur_rd_4x4_y_o    ( posi_cur_rd_4x4_y_w ) ,
    .posi_cur_rd_idx_o      ( posi_cur_rd_idx_w   ) ,
    .posi_cur_rd_dat_i      ( posi_cur_rd_dat_w   ) ,
    // ime_if
    .sys_ime_cmd_num_i      ( sys_ime_cmd_num_i   ) ,
    .sys_ime_cmd_dat_i      ( sys_ime_cmd_dat_i   ) ,
    .ime_ctu_x_i            ( ime_x               ) ,
    .ime_ctu_y_i            ( ime_y               ) ,
    .ime_start_i            ( ime_start           ) ,
    .ime_done_o             ( ime_done            ) ,
    // ime_cur_if
    .ime_cur_4x4_x_o        ( ime_cur_4x4_x_w     ) ,
    .ime_cur_4x4_y_o        ( ime_cur_4x4_y_w     ) ,
    .ime_cur_4x4_idx_o      ( ime_cur_4x4_idx_w   ) ,
    .ime_cur_sel_o          ( ime_cur_sel_w       ) ,
    .ime_cur_size_o         ( ime_cur_siz_w       ) ,
    .ime_cur_rden_o         ( ime_cur_rden_w      ) ,
    .ime_downsample_o       ( ime_downsample_w    ) ,
    .ime_cur_pel_i          ( ime_cur_dat_w       ) ,
    // ime_ref_if   
    .ime_ref_x_o            ( ime_ref_idx_x_w     ) ,
    .ime_ref_y_o            ( ime_ref_idx_y_w     ) ,
    .ime_ref_rden_o         ( ime_ref_rden_w      ) ,
    .ime_ref_pel_i          ( ime_ref_pel_w       ) ,
    // fme_if
    .fme_start_i            ( fme_start           ) ,
    .fme_ctu_x_i            ( fme_x               ) ,
    .fme_ctu_y_i            ( fme_y               ) ,
    .fme_done_o             ( fme_done            ) ,
    .fme_cur_rden_o         ( fme_cur_rden_w      ) ,
    .fme_cur_4x4_idx_o      ( fme_cur_4x4_idx_w   ) ,
    .fme_cur_4x4_x_o        ( fme_cur_4x4_x_w     ) ,
    .fme_cur_4x4_y_o        ( fme_cur_4x4_y_w     ) ,
    .fme_cur_pel_i          ( fme_cur_pel_w       ) ,
    .fme_ref_rden_o         ( fme_ref_rden_w      ) ,
    .fme_ref_idx_x_o        ( fme_ref_idx_x_w     ) ,
    .fme_ref_idx_y_o        ( fme_ref_idx_y_w     ) ,
    .fme_ref_pel_i          ( fme_ref_pel_w       ) ,
    // rec_if
    .rec_start_i            ( rec_start           ) ,
    .rec_done_o             ( rec_done            ) ,
    .rec_ctu_x_i            ( rec_x               ) ,
    .rec_ctu_y_i            ( rec_y               ) ,
    .rec_cur_rd_ena_o       ( rec_cur_rd_ena_w    ) ,
    .rec_cur_rd_sel_o       ( rec_cur_rd_sel_w    ) ,
    .rec_cur_rd_siz_o       ( rec_cur_rd_siz_w    ) ,
    .rec_cur_rd_4x4_x_o     ( rec_cur_rd_4x4_x_w  ) ,
    .rec_cur_rd_4x4_y_o     ( rec_cur_rd_4x4_y_w  ) ,
    .rec_cur_rd_idx_o       ( rec_cur_rd_idx_w    ) ,
    .rec_cur_rd_dat_i       ( rec_cur_rd_dat_w    ) ,
    .rec_ref_rd_ena_o       ( rec_ref_rd_ena_w    ) ,
    .rec_ref_rd_sel_o       ( rec_ref_rd_sel_w    ) ,
    .rec_ref_rd_idx_x_o     ( rec_ref_rd_idx_x_w  ) ,
    .rec_ref_rd_idx_y_o     ( rec_ref_rd_idx_y_w  ) ,
    .rec_ref_rd_dat_i       ( rec_ref_rd_dat_w    ) ,
    // db_if
    .db_ctu_x_i             ( db_x                ) ,
    .db_ctu_y_i             ( db_y                ) ,
    .db_start_i             ( db_start            ) ,
    .db_done_o              ( db_done             ) ,
    .db_cur_4x4_x_o         ( db_cur_rd_4x4_x_w   ) ,
    .db_cur_4x4_y_o         ( db_cur_rd_4x4_y_w   ) ,
    .db_cur_4x4_idx_o       ( db_cur_rd_4x4_idx_w ) ,
    .db_cur_ren_o           ( db_cur_rd_ena_w     ) ,
    .db_cur_sel_o           ( db_cur_rd_sel_w     ) ,
    .db_cur_siz_o           ( db_cur_rd_siz_w     ) ,
    .db_cur_pxl_i           ( db_cur_rd_pxl_w     ) ,
    // fetch_if
    .fetch_wen_o            ( fetch_wen_w         ) ,
    .fetch_w4x4_x_o         ( fetch_w4x4_x_w      ) ,
    .fetch_w4x4_y_o         ( fetch_w4x4_y_w      ) ,
    .fetch_wprevious_o      ( fetch_wprevious_w   ) ,
    .fetch_wdone_o          ( fetch_wdone_w       ) ,
    .fetch_wsel_o           ( fetch_wsel_w        ) ,
    .fetch_wdata_o          ( fetch_wdata_w       ) ,
    // db_top_rec_if
    .top_ren_o              ( db_top_ren_w        ) ,
    .top_r4x4_o             ( db_top_r4x4_w       ) ,
    .top_ridx_o             ( db_top_ridx_w       ) ,
    .top_rdata_i            ( db_top_rdata_w      ) ,
    // ec_if
    .ec_ctu_x_i             ( ec_x                ) ,
    .ec_ctu_y_i             ( ec_y                ) ,
    .ec_start_i             ( ec_start            ) ,
    .ec_done_o              ( ec_done             ) ,
    .bs_data_o              ( bs_dat_o            ) ,
    .bs_val_o               ( bs_val_o            ) 
    // .slice_done_o           ( slice_done_o        )

);

endmodule
