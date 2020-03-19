//-------------------------------------------------------------------
//
//  Filename      : rec_top.v
//  Author        : Huang Lei Lei
//  Created       : 2017-11-25
//  Description   : top for module rec in h265 enc
//
//-------------------------------------------------------------------
//
//  Modified      : 2017-12-24 by HLL
//  Description   : chroma supported
//  Modified      : 2018-01-07 by HLL
//  Description   : inter-luma & chroma supported
//  Modified      : 2018-05-19 by HLL
//  Description   : non-lcu-aligned frame size supported
//  Modified      : 2018-05-21 by HLL
//  Description   : I block in P frame supported
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module rec_top (
  // global
  clk                   ,
  rstn                  ,
  sys_start_i           , // for buffer rotation
  // ctrl_if
  start_i               ,
  done_o                ,
  // pos_i
  ctu_x_all_i           ,
  ctu_y_all_i           ,
  ctu_x_res_i           ,
  ctu_y_res_i           ,
  ctu_x_cur_i           ,
  ctu_y_cur_i           ,
  // cfg_i
  qp_i                  ,
  type_i                ,
  intra_partition_i     ,
  inter_partition_i     ,
  rec_skip_flag_i       ,
  // mode_i
  md_rd_ena_o           ,
  md_rd_adr_o           ,
  md_rd_dat_i           ,
  // cur_i
  cur_rd_ena_o          ,
  cur_rd_sel_o          ,
  cur_rd_siz_o          ,
  cur_rd_4x4_x_o        ,
  cur_rd_4x4_y_o        ,
  cur_rd_idx_o          ,
  cur_rd_dat_i          ,
  // mv_i
  mv_rd_ena_o           ,
  mv_rd_adr_o           ,
  mv_rd_dat_i           ,
  // ref_i
  ref_rd_ena_o          ,
  ref_rd_sel_o          ,
  ref_rd_idx_x_o        ,
  ref_rd_idx_y_o        ,
  ref_rd_dat_i          ,
  // fme_i
  pre_fme_rd_ena_o      ,
  pre_fme_rd_siz_o      ,
  pre_fme_rd_4x4_x_o    ,
  pre_fme_rd_4x4_y_o    ,
  pre_fme_rd_idx_o      ,
  pre_fme_rd_dat_i      ,
  // fme_o
  pre_fme_wr_ena_o      ,
  pre_fme_wr_siz_o      ,
  pre_fme_wr_4x4_x_o    ,
  pre_fme_wr_4x4_y_o    ,
  pre_fme_wr_idx_o      ,
  pre_fme_wr_dat_o      ,
  // rec_o
  rec_rd_ena_i          ,
  rec_rd_sel_i          ,
  rec_rd_siz_i          ,
  rec_rd_4x4_x_i        ,
  rec_rd_4x4_y_i        ,
  rec_rd_idx_i          ,
  rec_rd_dat_o          ,
  // rec_i
  rec_wr_ena_i          ,
  rec_wr_sel_i          ,
  rec_wr_siz_i          ,
  rec_wr_4x4_x_i        ,
  rec_wr_4x4_y_i        ,
  rec_wr_idx_i          ,
  rec_wr_dat_i          ,
  // coe_o
  cef_rd_ena_i          ,
  cef_rd_sel_i          ,
  cef_rd_siz_i          ,
  cef_rd_4x4_x_i        ,
  cef_rd_4x4_y_i        ,
  cef_rd_idx_i          ,
  cef_rd_dat_o          ,
  // mvd_o
  mvd_rd_ena_i          ,
  mvd_rd_adr_i          ,
  mvd_rd_dat_o          ,
  // cbf_o
  cbf_y_o               ,
  cbf_u_o               ,
  cbf_v_o               ,
  // IinP
  IinP_ena_i            ,
  IinP_cst_I_i          ,
  IinP_cst_P_i          ,
  fme_IinP_flag_o       ,// for fme skip //{topleft, top, left}
  IinP_flag_o             // for db and cabac
  );


//*** PARAMETER ****************************************************************

  localparam    SIZE_04                = 0                   ;
  localparam    SIZE_08                = 1                   ;
  localparam    SIZE_16                = 2                   ;
  localparam    SIZE_32                = 3                   ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                clk                   ;
  input                                rstn                  ;
  input                                sys_start_i           ;
  // ctrl_if
  input                                start_i               ;
  output                               done_o                ;
  // pos_i
  input  [`PIC_X_WIDTH       -1 :0]    ctu_x_all_i           ;
  input  [`PIC_Y_WIDTH       -1 :0]    ctu_y_all_i           ;
  input  [4                  -1 :0]    ctu_x_res_i           ;
  input  [4                  -1 :0]    ctu_y_res_i           ;
  input  [`PIC_X_WIDTH       -1 :0]    ctu_x_cur_i           ;
  input  [`PIC_Y_WIDTH       -1 :0]    ctu_y_cur_i           ;
  // cfg_i
  input  [6                  -1 :0]    qp_i                  ;
  input                                type_i                ;
  input  [85                 -1 :0]    intra_partition_i     ;
  input  [21*2               -1 :0]    inter_partition_i     ;
  input  [85                 -1 :0]    rec_skip_flag_i       ;
  // mode_i
  output                               md_rd_ena_o           ;
  output [8                  -1 :0]    md_rd_adr_o           ;
  input  [6                  -1 :0]    md_rd_dat_i           ;
  // cur_i
  output                               cur_rd_ena_o          ;
  output [2                  -1 :0]    cur_rd_sel_o          ;
  output [2                  -1 :0]    cur_rd_siz_o          ;
  output [4                  -1 :0]    cur_rd_4x4_x_o        ;
  output [4                  -1 :0]    cur_rd_4x4_y_o        ;
  output [5                  -1 :0]    cur_rd_idx_o          ;
  input  [`PIXEL_WIDTH*32    -1 :0]    cur_rd_dat_i          ;
  // mv_i
  output                               mv_rd_ena_o           ;
  output [6                  -1 :0]    mv_rd_adr_o           ;
  input  [`FMV_WIDTH*2       -1 :0]    mv_rd_dat_i           ;
  // ref_i
  output                               ref_rd_ena_o          ;
  output [2                  -1 :0]    ref_rd_sel_o          ;
  output [8                  -1 :0]    ref_rd_idx_x_o        ;
  output [8                  -1 :0]    ref_rd_idx_y_o        ;
  input  [`PIXEL_WIDTH*8     -1 :0]    ref_rd_dat_i          ;
  // fme_i
  output                               pre_fme_rd_ena_o      ;
  output [2                  -1 :0]    pre_fme_rd_siz_o      ;
  output [4                  -1 :0]    pre_fme_rd_4x4_x_o    ;
  output [4                  -1 :0]    pre_fme_rd_4x4_y_o    ;
  output [5                  -1 :0]    pre_fme_rd_idx_o      ;
  input  [`PIXEL_WIDTH*32    -1 :0]    pre_fme_rd_dat_i      ;
  // fme_o
  output [1                  -1 :0]    pre_fme_wr_ena_o      ;
  output [2                  -1 :0]    pre_fme_wr_siz_o      ;
  output [4                  -1 :0]    pre_fme_wr_4x4_x_o    ;
  output [4                  -1 :0]    pre_fme_wr_4x4_y_o    ;
  output [5                  -1 :0]    pre_fme_wr_idx_o      ;
  output [`PIXEL_WIDTH*32    -1 :0]    pre_fme_wr_dat_o      ;
  // rec_o
  input                                rec_rd_ena_i          ;
  input  [2                  -1 :0]    rec_rd_sel_i          ;
  input  [2                  -1 :0]    rec_rd_siz_i          ;
  input  [4                  -1 :0]    rec_rd_4x4_x_i        ;
  input  [4                  -1 :0]    rec_rd_4x4_y_i        ;
  input  [5                  -1 :0]    rec_rd_idx_i          ;
  output [`PIXEL_WIDTH*32    -1 :0]    rec_rd_dat_o          ;
  // rec_i
  input  [1                  -1 :0]    rec_wr_ena_i          ;
  input  [2                  -1 :0]    rec_wr_sel_i          ;
  input  [2                  -1 :0]    rec_wr_siz_i          ;
  input  [4                  -1 :0]    rec_wr_4x4_x_i        ;
  input  [4                  -1 :0]    rec_wr_4x4_y_i        ;
  input  [5                  -1 :0]    rec_wr_idx_i          ;
  input  [`PIXEL_WIDTH*32    -1 :0]    rec_wr_dat_i          ;
  // coe_o
  input                                cef_rd_ena_i          ;
  input  [2                  -1 :0]    cef_rd_sel_i          ;
  input  [2                  -1 :0]    cef_rd_siz_i          ;
  input  [4                  -1 :0]    cef_rd_4x4_x_i        ;
  input  [4                  -1 :0]    cef_rd_4x4_y_i        ;
  input  [5                  -1 :0]    cef_rd_idx_i          ;
  output [`COEFF_WIDTH*32    -1 :0]    cef_rd_dat_o          ;
  // mvd_o
  input                                mvd_rd_ena_i          ;
  input  [6                  -1 :0]    mvd_rd_adr_i          ;
  output [2*`MVD_WIDTH          :0]    mvd_rd_dat_o          ;
  // cbf_o
  output [256                -1 :0]    cbf_y_o               ;
  output [256                -1 :0]    cbf_u_o               ;
  output [256                -1 :0]    cbf_v_o               ;
  // IinP flag
  input                                IinP_ena_i            ;
  input  [20                 -1 :0]    IinP_cst_I_i          ;
  input  [20                 -1 :0]    IinP_cst_P_i          ;
  output [3                  -1 :0]    IinP_flag_o            ;
  output [4                  -1 :0]    fme_IinP_flag_o       ;


//*** WIRE/REG *****************************************************************

  // global
  reg                                  type_r                ;
  reg                                  start_r               ;

  // intra
  wire                                 intra_start_w         ;
  wire                                 intra_done_w          ;

  wire                                 intra_pre_wr_val_w    ;
  wire   [2                  -1 :0]    intra_pre_wr_sel_w    ;
  wire   [1                     :0]    intra_pre_wr_siz_w    ;
  wire   [3                     :0]    intra_pre_wr_4x4_x_w  ;
  wire   [3                     :0]    intra_pre_wr_4x4_y_w  ;
  wire   [`PIXEL_WIDTH*32    -1 :0]    intra_pre_wr_dat_w    ;

  wire                                 intra_rec_wr_bgn_w    ;
  wire   [2                  -1 :0]    intra_rec_wr_sel_w    ;
  wire   [8                  -1 :0]    intra_rec_wr_pos_w    ;
  wire   [2                  -1 :0]    intra_rec_wr_siz_w    ;
  wire                                 intra_rec_wr_ena_w    ;
  wire   [5                  -1 :0]    intra_rec_wr_idx_w    ;
  wire   [`PIXEL_WIDTH*32    -1 :0]    intra_rec_wr_dat_w    ;
  wire                                 intra_rec_done_w      ;

  // mc
  wire                                 inter_start_w         ;
  wire                                 inter_done_w          ;

  wire                                 inter_pre_wr_val_w    ;
  wire   [2                  -1 :0]    inter_pre_wr_sel_w    ;
  wire   [1                     :0]    inter_pre_wr_siz_w    ;
  wire   [3                     :0]    inter_pre_wr_4x4_x_w  ;
  wire   [3                     :0]    inter_pre_wr_4x4_y_w  ;
  wire   [`PIXEL_WIDTH*32    -1 :0]    inter_pre_wr_dat_w    ;

  wire                                 inter_rec_done_w      ;

  // buf_wrapper
  wire                                 pre_wr_ena_w          ;
  wire   [2                  -1 :0]    pre_wr_sel_w          ;
  wire   [1                     :0]    pre_wr_siz_w          ;
  wire   [3                     :0]    pre_wr_4x4_x_w        ;
  wire   [3                     :0]    pre_wr_4x4_y_w        ;
  wire   [`PIXEL_WIDTH*32    -1 :0]    pre_wr_dat_w          ;

  wire                                 res_wr_val_w          ;
  wire   [1                     :0]    res_wr_sel_w          ;
  wire   [1                     :0]    res_wr_siz_w          ;
  wire   [4                     :0]    res_wr_idx_w          ;
  wire   [(`PIXEL_WIDTH+1)*32-1 :0]    res_wr_dat_w          ;

  reg                                  res_wr_val_r          ;
  reg    [1                     :0]    res_wr_sel_r          ;
  reg    [1                     :0]    res_wr_siz_r          ;
  reg    [(`PIXEL_WIDTH+1)*32-1 :0]    res_wr_dat_r          ;

  wire                                 cef_wr_ena_w          ;
  wire   [5                  -1 :0]    cef_wr_idx_w          ;
  wire   [`COEFF_WIDTH*32    -1 :0]    cef_wr_dat_w          ;
  wire                                 cef_rd_ena_w          ;
  wire   [5                  -1 :0]    cef_rd_idx_w          ;
  wire   [`COEFF_WIDTH*32    -1 :0]    cef_rd_dat_w          ;

  wire                                 rsp_wr_val_w          ;
  wire   [5                  -1 :0]    rsp_wr_idx_w          ;
  wire   [(`PIXEL_WIDTH+2)*32-1 :0]    rsp_wr_dat_w          ;

  wire   [2                  -1 :0]    rec_wr_sel_w          ;
  wire   [8                  -1 :0]    rec_wr_pos_w          ;
  wire   [2                  -1 :0]    rec_wr_siz_w          ;
  wire                                 rec_wr_ena_w          ;
  wire   [5                  -1 :0]    rec_wr_idx_w          ;
  wire   [`PIXEL_WIDTH*32    -1 :0]    rec_wr_dat_w          ;

  wire                                 mvd_wr_ena_w          ;
  wire   [6                  -1 :0]    mvd_wr_adr_w          ;
  wire   [`MVD_WIDTH*2          :0]    mvd_wr_dat_w          ;

  wire                                 intra_pre_wr_ena_w    ;
  wire                                 inter_pre_wr_ena_w    ;
  wire                                 rsp_wr_ena_w          ;

  reg                                  sys_start_r           ;
  reg                                  sys_start_d1          ;

  wire                                 IinP_flag_clr_w       ;
  wire  [3                  -1 :0]     IinP_flag_o           ;
  wire  [4                  -1 :0]     fme_IinP_flag_o       ;

//*** MAIN BODY ****************************************************************

//--- GLOBAL ---------------------------
  // type_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      type_r <= 0 ;
    end
    else begin
      if( IinP_ena_i ) begin
        if( ( (type_i==`INTRA)                                 )
          ||( (type_i==`INTER) && (IinP_cst_I_i<=IinP_cst_P_i) )
        ) begin
          type_r <= `INTRA ;
        end
        else begin
          type_r <= `INTER ;
        end
      end
      else begin
        type_r <= type_i ;
      end
    end
  end

  // start_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      start_r <= 0 ;
    end
    else begin
      start_r <= start_i ;
    end
  end

  // done_o
  assign done_o = intra_done_w | inter_done_w ;


//--- INTRA ----------------------------
  // re-wire
  assign intra_start_w      = (type_r==`INTRA) ? start_r      : 0 ;

  assign intra_rec_wr_bgn_w = cef_wr_ena_w ;
  assign intra_rec_wr_sel_w = rec_wr_sel_w ;
  assign intra_rec_wr_pos_w = rec_wr_pos_w ;
  assign intra_rec_wr_siz_w = rec_wr_siz_w ;
  assign intra_rec_wr_ena_w = rec_wr_ena_w ;
  assign intra_rec_wr_idx_w = rec_wr_idx_w ;
  assign intra_rec_wr_dat_w = rec_wr_dat_w ;

  // intra_top
  intra_top u_intra_top(
    // global
    .clk                   ( clk                      ),
    .rstn                  ( rstn                     ),
    // ctrl_if
    .start_i               ( intra_start_w            ),
    .done_o                ( intra_done_w             ),
    // cfg_i
    .type_i                ( type_r                   ),
    // pos_i
    .ctu_x_all_i           ( ctu_x_all_i              ),
    .ctu_y_all_i           ( ctu_y_all_i              ),
    .ctu_x_res_i           ( ctu_x_res_i              ),
    .ctu_y_res_i           ( ctu_y_res_i              ),
    .ctu_x_cur_i           ( ctu_x_cur_i              ),
    .ctu_y_cur_i           ( ctu_y_cur_i              ),
    // pt_i
    .partition_i           ( intra_partition_i        ),
    // md_if
    .md_rd_ena_o           ( md_rd_ena_o              ),
    .md_rd_adr_o           ( md_rd_adr_o              ),
    .md_rd_dat_i           ( md_rd_dat_i              ),
    // pre_o
    .pre_val_o             ( intra_pre_wr_ena_w       ),
    .pre_sel_o             ( intra_pre_wr_sel_w       ),
    .pre_siz_o             ( intra_pre_wr_siz_w       ),
    .pre_4x4_x_o           ( intra_pre_wr_4x4_x_w     ),
    .pre_4x4_y_o           ( intra_pre_wr_4x4_y_w     ),
    .pre_dat_o             ( intra_pre_wr_dat_w       ),
    // rec_i
    .rec_bgn_i             ( intra_rec_wr_bgn_w       ),
    .rec_sel_i             ( intra_rec_wr_sel_w       ),
    .rec_pos_i             ( intra_rec_wr_pos_w       ),
    .rec_siz_i             ( intra_rec_wr_siz_w       ),
    .rec_val_i             ( intra_rec_wr_ena_w       ),
    .rec_idx_i             ( intra_rec_wr_idx_w       ),
    .rec_dat_i             ( intra_rec_wr_dat_w       ),
    .rec_done_o            ( intra_rec_done_w         )
    );


//--- MC -------------------------------
  // re-wire
  assign inter_start_w    = (type_r==`INTER) ? start_r          : 0 ;

  assign inter_rec_done_w = (type_r==`INTER) ? intra_rec_done_w : 0 ;

  wire   ref_rd_sel_w ;
  assign ref_rd_sel_o = {1'b1,ref_rd_sel_w} ;

  wire [2*`FMV_WIDTH-1 :0] mv_rd_dat_w ;
  assign mv_rd_dat_w = {mv_rd_dat_i[`FMV_WIDTH-1:0], mv_rd_dat_i[2*`FMV_WIDTH-1:`FMV_WIDTH]};

  // mc_top
  mc_top u_mc_top(
    // global
    .clk                   ( clk                      ),
    .rstn                  ( rstn                     ),
    // ctrl_i
    .sysif_start_i         ( inter_start_w            ),
    .sysif_done_o          ( inter_done_w             ),
    // pos_i
    .ctu_x_res_i           ( ctu_x_res_i              ),
    .ctu_y_res_i           ( ctu_y_res_i              ),
    // info_i
    .sysif_cmb_x_i         ( ctu_x_cur_i              ),
    .sysif_cmb_y_i         ( ctu_y_cur_i              ),
    .mb_x_total_i          ( ctu_x_all_i              ),
    .mb_y_total_i          ( ctu_y_all_i              ),
    // qp_i
    .sysif_qp_i            ( qp_i                     ),
    // pt_i
    .fmeif_partition_i     ( inter_partition_i        ),
    // mv_if
    .fmeif_mv_rden_o       ( mv_rd_ena_o              ),
    .fmeif_mv_rdaddr_o     ( mv_rd_adr_o              ),
    .fmeif_mv_i            ( mv_rd_dat_w              ),
    // ref_if
    .fetchif_rden_o        ( ref_rd_ena_o             ),
    .fetchif_sel_o         ( ref_rd_sel_w             ),
    .fetchif_idx_x_o       ( ref_rd_idx_x_o           ),
    .fetchif_idx_y_o       ( ref_rd_idx_y_o           ),
    .fetchif_pel_i         ( ref_rd_dat_i             ),
    // mvd_o
    .mvd_wen_o             ( mvd_wr_ena_w             ),
    .mvd_waddr_o           ( mvd_wr_adr_w             ),
    .mvd_wdata_o           ( mvd_wr_dat_w             ),
    // fme_rd_if
    .fme_rd_ena_o          ( pre_fme_rd_ena_o         ),
    .fme_rd_siz_o          ( pre_fme_rd_siz_o         ),
    .fme_rd_4x4_x_o        ( pre_fme_rd_4x4_x_o       ),
    .fme_rd_4x4_y_o        ( pre_fme_rd_4x4_y_o       ),
    .fme_rd_idx_o          ( pre_fme_rd_idx_o         ),
    .fme_rd_dat_i          ( pre_fme_rd_dat_i         ),
    // fme_wr_if
    .fme_wr_ena_o          ( pre_fme_wr_ena_o         ),
    .fme_wr_siz_o          ( pre_fme_wr_siz_o         ),
    .fme_wr_4x4_x_o        ( pre_fme_wr_4x4_x_o       ),
    .fme_wr_4x4_y_o        ( pre_fme_wr_4x4_y_o       ),
    .fme_wr_idx_o          ( pre_fme_wr_idx_o         ),
    .fme_wr_dat_o          ( pre_fme_wr_dat_o         ),
    // pre_o
    .pre_en_o              ( inter_pre_wr_ena_w       ),
    .pre_sel_o             ( inter_pre_wr_sel_w       ),
    .pre_size_o            ( inter_pre_wr_siz_w       ),
    .pre_4x4_x_o           ( inter_pre_wr_4x4_x_w     ),
    .pre_4x4_y_o           ( inter_pre_wr_4x4_y_w     ),
    .pre_data_o            ( inter_pre_wr_dat_w       ),
    // rec_i
    .rec_done_i            ( inter_rec_done_w         )
    );


//--- TQ -------------------------------
  // register res
  always @ ( posedge clk or negedge rstn ) begin
    if ( !rstn ) begin
      res_wr_val_r <= 0 ;
      res_wr_sel_r <= 0 ;
      res_wr_siz_r <= 0 ;
      res_wr_dat_r <= 0 ;
    end
    else begin
      res_wr_val_r <= res_wr_val_w ;
      res_wr_sel_r <= res_wr_sel_w ;
      res_wr_siz_r <= res_wr_siz_w ;
      res_wr_dat_r <= res_wr_dat_w ;
    end
  end

  // tq_top
  tq_top u_tq_top(
    // global
    .clk                   ( clk                      ),
    .rst                   ( rstn                     ),
    // sys_if
    .type_i                ( type_r                   ),
    .qp_i                  ( qp_i                     ),
    // res_i
    .tq_en_i               ( res_wr_val_r             ),
    .tq_sel_i              ( res_wr_sel_r             ),
    .tq_size_i             ( res_wr_siz_r             ),
    .tq_res_i              ( res_wr_dat_r             ),
    // cef_if
    .cef_wen_o             ( cef_wr_ena_w             ),
    .cef_widx_o            ( cef_wr_idx_w             ),
    .cef_data_o            ( cef_wr_dat_w             ),
    .cef_ren_o             ( cef_rd_ena_w             ),
    .cef_ridx_o            ( cef_rd_idx_w             ),
    .cef_data_i            ( cef_rd_dat_w             ),
    // rec_o
    .rec_val_o             ( rsp_wr_ena_w             ),
    .rec_idx_o             ( rsp_wr_idx_w             ),
    .rec_data_o            ( rsp_wr_dat_w             )
    );


//--- BUFFER ---------------------------
  // re-wire
  assign pre_wr_ena_w   = (type_r==`INTRA) ? intra_pre_wr_ena_w   : inter_pre_wr_ena_w   ;
  assign pre_wr_sel_w   = (type_r==`INTRA) ? intra_pre_wr_sel_w   : inter_pre_wr_sel_w   ;
  assign pre_wr_siz_w   = (type_r==`INTRA) ? intra_pre_wr_siz_w   : inter_pre_wr_siz_w   ;
  assign pre_wr_4x4_x_w = (type_r==`INTRA) ? intra_pre_wr_4x4_x_w : inter_pre_wr_4x4_x_w ;
  assign pre_wr_4x4_y_w = (type_r==`INTRA) ? intra_pre_wr_4x4_y_w : inter_pre_wr_4x4_y_w ;
  assign pre_wr_dat_w   = (type_r==`INTRA) ? intra_pre_wr_dat_w   : inter_pre_wr_dat_w   ;

  always @ ( posedge clk or negedge rstn ) begin 
    if ( !rstn ) begin 
      sys_start_r <= 0 ; 
      sys_start_d1<= 0 ; 
    end else begin 
      sys_start_r <= sys_start_i ;
      sys_start_d1<= sys_start_r ;
    end 
  end 

  // buf_wrapper
  rec_buf_wrapper u_rec_buf_wrapper (
    // global
    .clk                   ( clk                      ),
    .rstn                  ( rstn                     ),
    // ctrl_i
    .rotate_i              ( sys_start_d1             ),    
    .rec_skip_flag_i       ( rec_skip_flag_i          ),
    // pre_i
    .pre_wr_ena_i          ( pre_wr_ena_w             ),
    .pre_wr_sel_i          ( pre_wr_sel_w             ),
    .pre_wr_siz_i          ( pre_wr_siz_w             ),
    .pre_wr_4x4_x_i        ( pre_wr_4x4_x_w           ),
    .pre_wr_4x4_y_i        ( pre_wr_4x4_y_w           ),
    .pre_wr_dat_i          ( pre_wr_dat_w             ),
    // cur_i
    .cur_rd_ena_o          ( cur_rd_ena_o             ),
    .cur_rd_sel_o          ( cur_rd_sel_o             ),
    .cur_rd_siz_o          ( cur_rd_siz_o             ),
    .cur_rd_4x4_x_o        ( cur_rd_4x4_x_o           ),
    .cur_rd_4x4_y_o        ( cur_rd_4x4_y_o           ),
    .cur_rd_idx_o          ( cur_rd_idx_o             ),
    .cur_rd_dat_i          ( cur_rd_dat_i             ),
    // res_o
    .res_wr_ena_o          ( res_wr_val_w             ),
    .res_wr_sel_o          ( res_wr_sel_w             ),
    .res_wr_siz_o          ( res_wr_siz_w             ),
    .res_wr_idx_o          ( res_wr_idx_w             ),
    .res_wr_dat_o          ( res_wr_dat_w             ),
    // cef_i
    .cef_wr_ena_i          ( cef_wr_ena_w             ),
    .cef_wr_idx_i          ( cef_wr_idx_w             ),
    .cef_wr_dat_i          ( cef_wr_dat_w             ),
    // cef_o
    .cef_rd_ena_i          ( cef_rd_ena_w             ),
    .cef_rd_idx_i          ( cef_rd_idx_w             ),
    .cef_rd_dat_o          ( cef_rd_dat_w             ),
    // rsp_i
    .rsp_wr_ena_i          ( rsp_wr_ena_w             ),
    .rsp_wr_idx_i          ( rsp_wr_idx_w             ),
    .rsp_wr_dat_i          ( rsp_wr_dat_w             ),
    // rec_o
    .rec_wr_sel_o          ( rec_wr_sel_w             ),
    .rec_wr_pos_o          ( rec_wr_pos_w             ),
    .rec_wr_siz_o          ( rec_wr_siz_w             ),
    .rec_wr_ena_o          ( rec_wr_ena_w             ),
    .rec_wr_idx_o          ( rec_wr_idx_w             ),
    .rec_wr_dat_o          ( rec_wr_dat_w             ),
    // mvd_i
    .mvd_wr_ena_i          ( mvd_wr_ena_w             ),
    .mvd_wr_adr_i          ( mvd_wr_adr_w             ),
    .mvd_wr_dat_i          ( mvd_wr_dat_w             ),
    // rec_pip_o
    .rec_pip_rd_ena_i      ( rec_rd_ena_i             ),
    .rec_pip_rd_sel_i      ( rec_rd_sel_i             ),
    .rec_pip_rd_siz_i      ( rec_rd_siz_i             ),
    .rec_pip_rd_4x4_x_i    ( rec_rd_4x4_x_i           ),
    .rec_pip_rd_4x4_y_i    ( rec_rd_4x4_y_i           ),
    .rec_pip_rd_idx_i      ( rec_rd_idx_i             ),
    .rec_pip_rd_dat_o      ( rec_rd_dat_o             ),
    // rec_pip_i
    .rec_pip_wr_ena_i      ( rec_wr_ena_i             ),
    .rec_pip_wr_sel_i      ( rec_wr_sel_i             ),
    .rec_pip_wr_siz_i      ( rec_wr_siz_i             ),
    .rec_pip_wr_4x4_x_i    ( rec_wr_4x4_x_i           ),
    .rec_pip_wr_4x4_y_i    ( rec_wr_4x4_y_i           ),
    .rec_pip_wr_idx_i      ( rec_wr_idx_i             ),
    .rec_pip_wr_dat_i      ( rec_wr_dat_i             ),
    // cef_pip_o
    .cef_pip_rd_ena_i      ( cef_rd_ena_i             ),
    .cef_pip_rd_sel_i      ( cef_rd_sel_i             ),
    .cef_pip_rd_siz_i      ( cef_rd_siz_i             ),
    .cef_pip_rd_4x4_x_i    ( cef_rd_4x4_x_i           ),
    .cef_pip_rd_4x4_y_i    ( cef_rd_4x4_y_i           ),
    .cef_pip_rd_idx_i      ( cef_rd_idx_i             ),
    .cef_pip_rd_dat_o      ( cef_rd_dat_o             ),
    // mvd_pip_o
    .mvd_pip_rd_ena_i      ( mvd_rd_ena_i             ),
    .mvd_pip_rd_adr_i      ( mvd_rd_adr_i             ),
    .mvd_pip_rd_dat_o      ( mvd_rd_dat_o             ),
    // cbf_pip_o
    .cbf_y_r               ( cbf_y_o                  ),
    .cbf_u_r               ( cbf_u_o                  ),
    .cbf_v_r               ( cbf_v_o                  )
    );


//--- IinP -------------------------------------------------
  assign IinP_flag_clr_w = ctu_x_cur_i == ctu_x_all_i && ctu_y_cur_i == ctu_y_all_i && done_o ;
  IinP_flag_gen u_IinP_flag_gen(
    .clk              ( clk             ),
    .rstn             ( rstn            ),
    // clear if      
    .clear_i          ( IinP_flag_clr_w ),
    // start signal      
    .start_i          ( start_i         ),
    .start_r          ( start_r         ),
    // ctu position    
    .ctu_y_cur_i      ( ctu_y_cur_i     ),
    .ctu_x_cur_i      ( ctu_x_cur_i     ),
    .ctu_x_all_i      ( ctu_x_all_i     ),
    // ctu type    
    .type_i           ( type_i          ),
    .type_r           ( type_r          ),
    // flag output
    .fme_IinP_flag_o  ( fme_IinP_flag_o ),
    .IinP_flag_o      ( IinP_flag_o     )
  );

//*** DEBUG ********************************************************************

`ifdef DEBUG

`endif

endmodule
