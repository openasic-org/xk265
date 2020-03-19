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
//  Filename      : mc_top.v
//  Author        : Yufeng Bai
//  Email         : byfchina@gmail.com
//  Created On    : 2015-01-19
//
//-------------------------------------------------------------------
//
//  Modified      : 2015-08-31 by HLL
//  Description   : mvd added
//  Modified      : 2015-09-02 by HLL
//  Description   : mvd if connected out
//  Modified      : 2018-05-19 by HLL
//  Description   : search window expanded to +/-64
//  Modified      : 2018-05-21 by HLL
//  Description   : I block in P frame supported
//
//-------------------------------------------------------------------


`include "enc_defines.v"

module mc_top (
  clk   ,
  rstn    ,

  mb_x_total_i    ,
  mb_y_total_i    ,
  ctu_x_res_i           ,
  ctu_y_res_i           ,

  sysif_cmb_x_i   ,
  sysif_cmb_y_i   ,
  sysif_qp_i    ,
  sysif_start_i   ,
  sysif_done_o    ,

        fetchif_rden_o          ,
  fetchif_idx_x_o   ,
  fetchif_idx_y_o   ,
  fetchif_sel_o   ,
  fetchif_pel_i   ,

  fmeif_partition_i   ,
  fmeif_mv_i    ,
  fmeif_mv_rden_o   ,
  fmeif_mv_rdaddr_o ,

  // fme_rd_if
  fme_rd_ena_o      ,
  fme_rd_siz_o      ,
  fme_rd_4x4_x_o    ,
  fme_rd_4x4_y_o    ,
  fme_rd_idx_o      ,
  fme_rd_dat_i      ,

  // fme_wr_if
  fme_wr_ena_o      ,
  fme_wr_siz_o      ,
  fme_wr_4x4_x_o    ,
  fme_wr_4x4_y_o    ,
  fme_wr_idx_o      ,
  fme_wr_dat_o      ,

  mvd_wen_o      ,
  mvd_waddr_o    ,
  mvd_wdata_o    ,

  // pre_o
  pre_en_o       ,
  pre_sel_o      ,
  pre_size_o     ,
  pre_4x4_x_o    ,
  pre_4x4_y_o    ,
  pre_data_o     ,
  // rec_i
  rec_done_i
);

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input    [1-1:0]          clk    ; // clk signal
input    [1-1:0]          rstn   ; // asynchronous reset

input [(`PIC_X_WIDTH)-1 : 0]    mb_x_total_i ; // mb_x_total_i
input [(`PIC_Y_WIDTH)-1 : 0]    mb_y_total_i ; // mb_y_total_i
input  [4                  -1 :0]    ctu_x_res_i           ;
input  [4                  -1 :0]    ctu_y_res_i           ;

input    [`PIC_X_WIDTH-1:0]   sysif_cmb_x_i    ; // x position of the current LCU in the frame
input    [`PIC_Y_WIDTH-1:0]   sysif_cmb_y_i    ; // y position of the current LCU in the frame
input    [6-1:0]          sysif_qp_i   ; // qp of the current LCU
input    [1-1:0]          sysif_start_i    ; // C-ime start trigger signal
output   [1-1:0]          sysif_done_o   ; // C-ime done ack signal

output   [1-1:0]          fetchif_rden_o   ; // fetch u/v ref pixels enable
output   [8-1:0]          fetchif_idx_x_o  ; // "x position of ref LCU in the search window; (-12
output   [8-1:0]          fetchif_idx_y_o  ; // "y position of ref LCU in the search window; (-12
output   [1-1:0]          fetchif_sel_o    ; // fetch u/v ref pixels
input    [8*`PIXEL_WIDTH-1:0]  fetchif_pel_i   ; // ref LCU pixel data

input    [42-1:0]           fmeif_partition_i    ; // CU partition info ( 16 + 4 + 1) * 2

input    [`FMV_WIDTH*2-1:0]   fmeif_mv_i   ; // 8 x 8 PU MVs
output   [1-1:0]          fmeif_mv_rden_o  ; // mv read enable siganl
output   [6-1:0]          fmeif_mv_rdaddr_o; // mv address

//pred buf reuse

  // fme_rd_if
  output                           fme_rd_ena_o   ;
  output [2              -1 :0]    fme_rd_siz_o   ;
  output [4              -1 :0]    fme_rd_4x4_x_o ;
  output [4              -1 :0]    fme_rd_4x4_y_o ;
  output [5              -1 :0]    fme_rd_idx_o   ;
  input  [32*`PIXEL_WIDTH-1 :0]    fme_rd_dat_i   ;

  // fme_wr_if
  output reg [1              -1 :0]    fme_wr_ena_o   ;
  output     [2              -1 :0]    fme_wr_siz_o   ;
  output reg [4              -1 :0]    fme_wr_4x4_x_o ;
  output reg [4              -1 :0]    fme_wr_4x4_y_o ;
  output reg [5              -1 :0]    fme_wr_idx_o   ;
  output reg [32*`PIXEL_WIDTH-1 :0]    fme_wr_dat_o   ;

  output                           mvd_wen_o      ;
  output [6              -1 :0]    mvd_waddr_o    ;
  output [2*`MVD_WIDTH      :0]    mvd_wdata_o    ;

  output                           pre_en_o       ;
  output [2              -1 :0]    pre_sel_o      ;
  output [2              -1 :0]    pre_size_o     ;
  output [4              -1 :0]    pre_4x4_x_o    ;
  output [4              -1 :0]    pre_4x4_y_o    ;
  output [`PIXEL_WIDTH*32-1 :0]    pre_data_o     ;

  input                            rec_done_i     ;

  wire   [2-1:0]          tq_sel       ;


// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

wire [1-1 : 0]    fmeif_mv_rden_mvd_w   ;
wire [6-1 : 0]    fmeif_mv_rdaddr_mvd_w ;
wire [1-1 : 0]    fmeif_mv_rden_mc_w    ;
wire [6-1 : 0]    fmeif_mv_rdaddr_mc_w  ;

wire              mvd_access_w          ;

wire              mvd_wen_w             ;




  // wire [1*2 -1 :0]    partition_64_w ;
  // wire [4*2 -1 :0]    partition_32_w ;
  // wire [16*2-1 :0]    partition_16_w ;
  wire [21*2-1 :0]    partition_w    ;

  // assign {partition_64_w,partition_32_w,partition_16_w} = fmeif_partition_i ;
  assign partition_w =fmeif_partition_i;// {partition_16_w,partition_32_w,partition_64_w} ;


  wire [4              -1 :0]    pred_wr_ena_w ;
  wire [7              -1 :0]    pred_wr_adr_w ;
  wire [`PIXEL_WIDTH*32-1 :0]    pred_wr_dat_w ;
  reg  [`PIXEL_WIDTH*4 -1 :0]    pred_wr_dat_sub_w ;

  //assign fme_wr_ena_o   = pred_wr_ena_w      ;
  //assign fme_wr_siz_o   = `SIZE_32           ;
  //assign fme_wr_4x4_x_o = pred_wr_adr_w[5]   ;
  //assign fme_wr_4x4_y_o = pred_wr_adr_w[6]   ;
  //assign fme_wr_idx_o   = pred_wr_adr_w[4:0] ;
  //assign fme_wr_dat_o   = pred_wr_dat_w      ;

  reg [7:0] wr_cnt_r ;

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      wr_cnt_r <= 0 ;
    end
    else begin
      if( (|pred_wr_ena_w) ) begin
        wr_cnt_r <= wr_cnt_r + 1 ;
      end
    end
  end

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      fme_wr_ena_o <= 0 ;
    end
    else begin
      if( (|pred_wr_ena_w) && (wr_cnt_r[2:0]==7) ) begin
        fme_wr_ena_o <= 1 ;
      end
      else begin
        fme_wr_ena_o <= 0 ;
      end
    end
  end

  assign fme_wr_siz_o = `SIZE_08 ;

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      fme_wr_4x4_x_o <= 0 ;
      fme_wr_4x4_y_o <= 0 ;
      fme_wr_idx_o   <= 0 ;
    end
    else begin
      fme_wr_4x4_x_o <= { wr_cnt_r[6] ,wr_cnt_r[4] ,1'b0 };
      fme_wr_4x4_y_o <= { wr_cnt_r[7] ,wr_cnt_r[5] ,1'b0 };
      fme_wr_idx_o   <= { wr_cnt_r[3] ,2'b0 };
    end
  end

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      fme_wr_dat_o <= 0 ;
    end
    else begin
      if( (|pred_wr_ena_w) ) begin
        case( wr_cnt_r[2:0] )
          0 : fme_wr_dat_o[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*28] <= pred_wr_dat_sub_w ;
          1 : fme_wr_dat_o[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*20] <= pred_wr_dat_sub_w ;
          2 : fme_wr_dat_o[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*12] <= pred_wr_dat_sub_w ;
          3 : fme_wr_dat_o[`PIXEL_WIDTH*08-1:`PIXEL_WIDTH*04] <= pred_wr_dat_sub_w ;
          4 : fme_wr_dat_o[`PIXEL_WIDTH*28-1:`PIXEL_WIDTH*24] <= pred_wr_dat_sub_w ;
          5 : fme_wr_dat_o[`PIXEL_WIDTH*20-1:`PIXEL_WIDTH*16] <= pred_wr_dat_sub_w ;
          6 : fme_wr_dat_o[`PIXEL_WIDTH*12-1:`PIXEL_WIDTH*08] <= pred_wr_dat_sub_w ;
          7 : fme_wr_dat_o[`PIXEL_WIDTH*04-1:`PIXEL_WIDTH*00] <= pred_wr_dat_sub_w ;
        endcase
      end
    end
  end

  always @(*) begin
          pred_wr_dat_sub_w = 0;
    case( pred_wr_ena_w )
      8 : pred_wr_dat_sub_w = pred_wr_dat_w[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*28] ;
      4 : pred_wr_dat_sub_w = pred_wr_dat_w[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*20] ;
      2 : pred_wr_dat_sub_w = pred_wr_dat_w[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*12] ;
      1 : pred_wr_dat_sub_w = pred_wr_dat_w[`PIXEL_WIDTH*08-1:`PIXEL_WIDTH*04] ;
    endcase
  end


// ********************************************
//
//    Sub-modules Logic
//
// ********************************************
mc_chroma_top u_mc_chroma(
  .clk            (clk            ),
  .rstn           (rstn           ),

        .ctrl_launch_i          (chroma_start           ),
        .ctrl_launch_sel_i      (chroma_sel             ),
        .ctrl_done_o            (chroma_done            ),

  .mv_rden_o      (fmeif_mv_rden_mc_w   ),
  .mv_rdaddr_o    (fmeif_mv_rdaddr_mc_w ),
  .mv_data_i      (fmeif_mv_i           ),

  .ref_rden_o   (fetchif_rden_o   ),
  .ref_idx_x_o    (fetchif_idx_x_o  ),
  .ref_idx_y_o    (fetchif_idx_y_o  ),
  .ref_sel_o    (fetchif_sel_o    ),
  .ref_pel_i    (fetchif_pel_i    ),

  .pred_wren_o     ( pred_wr_ena_w    ),
  .pred_addr_o     ( pred_wr_adr_w    ),
  .pred_pixel_o    ( pred_wr_dat_w    )
);

mc_ctrl u_ctrl (
  .clk            (clk            ),
  .rstn           (rstn           ),

  .mc_start_i   (sysif_start_i    ),
  .mc_done_o    (sysif_done_o   ),

  .mvd_access_o    ( mvd_access_w    ),

  .chroma_start_o   (chroma_start   ),
  .chroma_sel_o   (chroma_sel   ),
  .chroma_done_i    (chroma_done    ),

  .tq_start_o   (tq_start   ),
  .tq_sel_o   (tq_sel     ),
  .tq_done_i    (tq_done    )
);

  reg tq_start_r ;

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      tq_start_r <= 0 ;
    end
    else begin
      tq_start_r <= tq_start ;
    end
  end

  mc_tq u_tq(
    // global
    .clk               ( clk                  ),
    .rstn              ( rstn                 ),
    // ctrl_if
    .start_i           ( tq_start_r           ),
    .done_o            ( tq_done              ),
    // info_i
    .sel_i             ( tq_sel               ),
    .partition_i       ( fmeif_partition_i    ),
    // pre_bf
    .fme_rd_ena_o      ( fme_rd_ena_o         ),
    .fme_rd_siz_o      ( fme_rd_siz_o         ),
    .fme_rd_4x4_x_o    ( fme_rd_4x4_x_o       ),
    .fme_rd_4x4_y_o    ( fme_rd_4x4_y_o       ),
    .fme_rd_idx_o      ( fme_rd_idx_o         ),
    .fme_rd_dat_i      ( fme_rd_dat_i         ),
    // pre_af
    .pre_wr_ena_o      ( pre_en_o             ),
    .pre_wr_sel_o      ( pre_sel_o            ),
    .pre_wr_siz_o      ( pre_size_o           ),
    .pre_wr_4x4_x_o    ( pre_4x4_x_o          ),
    .pre_wr_4x4_y_o    ( pre_4x4_y_o          ),
    .pre_wr_dat_o      ( pre_data_o           ),
    // rec_i
    .rec_done_i        ( rec_done_i           )
    );

  // mvd
  mvd_top u_mvd_top(
    // global
    .clk                     ( clk                      ),
    .rst_n                   ( rstn                     ),
    .mb_x_total_i            ( mb_x_total_i             ),
    .mb_y_total_i            ( mb_y_total_i             ),
    .ctu_x_res_i             ( ctu_x_res_i              ),
    .ctu_y_res_i             ( ctu_y_res_i              ),
    // control
    .mvd_start_i             ( sysif_start_i            ),
    .mb_x_i                  ( sysif_cmb_x_i            ),
    .mb_y_i                  ( sysif_cmb_y_i            ),
    .inter_cu_part_size_i    ( partition_w              ),
    .mvd_done_o              (                          ),
    // mv_i
    .mv_rden_o               ( fmeif_mv_rden_mvd_w      ),
    .mv_rdaddr_o             ( fmeif_mv_rdaddr_mvd_w    ),
    .mv_data_i               ( fmeif_mv_i               ),
    // mvd_o
    .mvd_wen_o               ( mvd_wen_w                ),
    .mvd_addr_o              ( mvd_waddr_o              ),
    .mvd_and_mvp_idx_o       ( mvd_wdata_o              )
    );

  assign fmeif_mv_rden_o   = mvd_access_w ? (!fmeif_mv_rden_mvd_w  ) : fmeif_mv_rden_mc_w   ;
  assign fmeif_mv_rdaddr_o = mvd_access_w ?   fmeif_mv_rdaddr_mvd_w  : fmeif_mv_rdaddr_mc_w ;

  assign mvd_wen_o   = !mvd_wen_w ;

endmodule

