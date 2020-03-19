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
//  Filename      : fme_top_buf.v
//  Author        : TANG
//  Created       : 2018-04-20
//  Description   : fme top with memory buffer
//
//-------------------------------------------------------------------
`include "enc_defines.v"

module fme_top_buf(
    // global
    clk                     ,
    rstn                    ,
    // skip cost thresh
    skip_cost_thresh_08     ,
    skip_cost_thresh_16     ,
    skip_cost_thresh_32     ,
    skip_cost_thresh_64     ,
    // sys_if
    fme_start_i             ,
    fme_ctu_x_i             ,
    fme_ctu_y_i             ,
    sys_x_all_i             ,
    sys_y_all_i             ,
    sys_ctu_x_all_i         ,
    sys_ctu_y_all_i         ,
    IinP_flag_i             ,
    rc_qp_i                 ,
    fme_done_o              ,
    sel_mod_2_i             ,
    sel_mod_3_i             ,
    // ime_if
    fme_partition_i         ,
    fme_mv_rden_o           ,
    fme_mv_rdaddr_o         ,
    fme_mv_data_i           ,
    // cur_if
    fme_cur_rden_o          ,
    fme_cur_4x4_idx_o       ,
    fme_cur_4x4_x_o         ,
    fme_cur_4x4_y_o         ,
    fme_cur_pel_i           ,
    // ref_if
    fme_ref_rden_o          ,
    fme_ref_idx_x_o         ,
    fme_ref_idx_y_o         ,
    fme_ref_pel_i           ,
    // mc_mv_if
    mc_mv_ren_i             ,
    mc_mv_rdaddr_i          ,
    mc_mv_o                 ,
    // db_mv_if
    db_mv_ren_i             ,
    db_mv_rdaddr_i          ,
    db_mv_o                 ,
    //fme_cost_if
    fme_cost_o              ,
    // skip if
    skip_idx_o              ,
    skip_flag_o             ,
    //mc_pred_if  
    mc_pred_wr_ren_i        ,
    mc_pred_wr_size_i       ,
    mc_pred_wr_4x4_x_i      ,
    mc_pred_wr_4x4_y_i      ,
    mc_pred_wr_4x4_idx_i    ,
    mc_pred_wr_rdata_i      ,  

    mc_pred_rd_ren_i        ,
    mc_pred_rd_size_i       ,
    mc_pred_rd_4x4_x_i      ,
    mc_pred_rd_4x4_y_i      ,
    mc_pred_rd_4x4_idx_i    ,
    mc_pred_rd_rdata_o      
);


//**** INPUT/OUTPUT DECLARATION ******************************************
  // global
  input                                 clk                     ;
  input                                 rstn                    ;
  // skip cost thresh
  input   [32-1:0]                      skip_cost_thresh_08     ;
  input   [32-1:0]                      skip_cost_thresh_16     ;
  input   [32-1:0]                      skip_cost_thresh_32     ;
  input   [32-1:0]                      skip_cost_thresh_64     ;
  // sys_if           
  input                                 fme_start_i             ;
  input   [`PIC_X_WIDTH      -1:0]      fme_ctu_x_i             ;
  input   [`PIC_X_WIDTH      -1:0]      fme_ctu_y_i             ;
  input   [`PIC_WIDTH        -1:0]      sys_x_all_i             ;
  input   [`PIC_HEIGHT       -1:0]      sys_y_all_i             ;
  input   [`PIC_X_WIDTH      -1:0]      sys_ctu_x_all_i         ;
  input   [`PIC_Y_WIDTH      -1:0]      sys_ctu_y_all_i         ;
  input   [4-1:0]                       IinP_flag_i             ;
  input   [6                 -1:0]      rc_qp_i                 ;
  output                                fme_done_o              ;
  input   [1                 -1:0]      sel_mod_2_i             ;
  input   [2                 -1:0]      sel_mod_3_i             ;
  // ime_if
  input   [42                -1:0]      fme_partition_i         ;
  output  [1                 -1:0]      fme_mv_rden_o           ;
  output  [6                 -1:0]      fme_mv_rdaddr_o         ;
  input   [2*`FMV_WIDTH      -1:0]      fme_mv_data_i           ;
  // cur_if
  output                                fme_cur_rden_o          ;  
  output  [5                 -1:0]      fme_cur_4x4_idx_o       ;  
  output  [4                 -1:0]      fme_cur_4x4_x_o         ;  
  output  [4                 -1:0]      fme_cur_4x4_y_o         ;  
  input   [32*`PIXEL_WIDTH   -1:0]      fme_cur_pel_i           ;  
  // ref_if
  output                                fme_ref_rden_o          ;
  output  [8                 -1:0]      fme_ref_idx_x_o         ;
  output  [8                 -1:0]      fme_ref_idx_y_o         ;
  input   [64*`PIXEL_WIDTH   -1:0]      fme_ref_pel_i           ;  
  // cost_if
  output  [`FME_COST_WIDTH   -1:0]      fme_cost_o              ; 
  // skip 
  output  [85*4-1:0]                    skip_idx_o              ;
  output  [85-1:0]                      skip_flag_o             ;      
  // mc_mv_if
  input                                 mc_mv_ren_i             ;
  input   [6                 -1:0]      mc_mv_rdaddr_i          ; 
  output  [2*`FMV_WIDTH      -1:0]      mc_mv_o                 ; 
  // db_mv_if
  input                                 db_mv_ren_i             ;
  input   [6                 -1:0]      db_mv_rdaddr_i          ; 
  output  [2*`FMV_WIDTH      -1:0]      db_mv_o                 ;        
  // mc_pred_if
  input                                 mc_pred_wr_ren_i        ;
  input   [2                -1 :0]      mc_pred_wr_size_i       ;
  input   [4                -1 :0]      mc_pred_wr_4x4_x_i      ;
  input   [4                -1 :0]      mc_pred_wr_4x4_y_i      ;
  input   [5                -1 :0]      mc_pred_wr_4x4_idx_i    ;
  input   [32*`PIXEL_WIDTH  -1 :0]      mc_pred_wr_rdata_i      ;

  input                                 mc_pred_rd_ren_i        ;
  input   [2                -1 :0]      mc_pred_rd_size_i       ;
  input   [4                -1 :0]      mc_pred_rd_4x4_x_i      ;
  input   [4                -1 :0]      mc_pred_rd_4x4_y_i      ;
  input   [5                -1 :0]      mc_pred_rd_4x4_idx_i    ;
  output  [32*`PIXEL_WIDTH  -1 :0]      mc_pred_rd_rdata_o      ;

//**** WIRE/REG DECLARATION *****************************************************
  
  wire [2                   -1 :0]      mcif_pre_size_w          ;
  wire [4                   -1 :0]      mcif_pre_4x4_x_w         ;
  wire [4                   -1 :0]      mcif_pre_4x4_y_w         ;
  wire [5                   -1 :0]      mcif_pre_4x4_idx_w       ;

  wire                                  fme_rec_mem_0_wen_i      ;
  wire [2                   -1 :0]      fme_rec_mem_0_size_i     ;
  wire [4                   -1 :0]      fme_rec_mem_0_4x4_x_i    ;
  wire [4                   -1 :0]      fme_rec_mem_0_4x4_y_i    ;
  wire [5                   -1 :0]      fme_rec_mem_0_4x4_idx_i  ;
  wire [32*`PIXEL_WIDTH     -1 :0]      fme_rec_mem_0_wdata_i    ;

  wire                                  fme_rec_mem_1_wen_i      ;
  wire [2                   -1 :0]      fme_rec_mem_1_size_i     ;
  wire [4                   -1 :0]      fme_rec_mem_1_4x4_x_i    ;
  wire [4                   -1 :0]      fme_rec_mem_1_4x4_y_i    ;
  wire [5                   -1 :0]      fme_rec_mem_1_4x4_idx_i  ;
  wire [32*`PIXEL_WIDTH     -1 :0]      fme_rec_mem_1_wdata_i    ;

  wire [1                   -1 :0]      mcif_mv_rden_w           ;
  wire [6                   -1 :0]      mcif_mv_rdaddr_w         ;
  reg  [2*`FMV_WIDTH        -1 :0]      mcif_mv_rddata_w         ;
  wire                                  mcif_mv_wren_w           ;
  wire [6                   -1 :0]      mcif_mv_wraddr_w         ;
  wire [2*`FMV_WIDTH        -1 :0]      mcif_mv_wrdata_w         ;
  wire [32*`PIXEL_WIDTH     -1 :0]      mcif_pre_pixel_w         ;
  wire [1                   -1 :0]      mcif_pre_wren_w          ;

  reg  [6                   -1 :0]      fme_mv_mem_0_rdaddr_w    ;
  wire [2*`FMV_WIDTH        -1 :0]      fme_mv_mem_0_rddata_w    ;

  reg                                   fme_mv_mem_0_wren_w      ;
  reg  [6                   -1 :0]      fme_mv_mem_0_wraddr_w    ;
  reg  [2*`FMV_WIDTH        -1 :0]      fme_mv_mem_0_wrdata_w    ;

  reg  [6                   -1 :0]      fme_mv_mem_1_rdaddr_w    ;
  wire [2*`FMV_WIDTH        -1 :0]      fme_mv_mem_1_rddata_w    ;

  reg                                   fme_mv_mem_1_wren_w      ;
  reg  [6                   -1 :0]      fme_mv_mem_1_wraddr_w    ;
  reg  [2*`FMV_WIDTH        -1 :0]      fme_mv_mem_1_wrdata_w    ;

  reg  [6                   -1 :0]      fme_mv_mem_2_rdaddr_w    ;
  wire [2*`FMV_WIDTH        -1 :0]      fme_mv_mem_2_rddata_w    ;

  reg                                   fme_mv_mem_2_wren_w      ;
  reg  [6                   -1 :0]      fme_mv_mem_2_wraddr_w    ;
  reg  [2*`FMV_WIDTH        -1 :0]      fme_mv_mem_2_wrdata_w    ;

  wire [32*`PIXEL_WIDTH     -1 :0]      mc_pred_rd_rdata_0_w     ;   
  wire [32*`PIXEL_WIDTH     -1 :0]      mc_pred_rd_rdata_1_w     ;   

  reg  [2*`FMV_WIDTH        -1 :0]      mc_mv_o                  ;
  reg  [2*`FMV_WIDTH        -1 :0]      db_mv_o                  ;
  
  // memory dut
  fme_top u_fme_top(
    // global
    .clk                  ( clk                    ),
    .rstn                 ( rstn                   ),
    // skip thresh
    .skip_cost_thresh_08  ( skip_cost_thresh_08    ),
    .skip_cost_thresh_16  ( skip_cost_thresh_16    ),
    .skip_cost_thresh_32  ( skip_cost_thresh_32    ),
    .skip_cost_thresh_64  ( skip_cost_thresh_64    ),
    // sys_if
    .sysif_start_i        ( fme_start_i            ),
    .sysif_cmb_x_i        ( fme_ctu_x_i            ),
    .sysif_cmb_y_i        ( fme_ctu_y_i            ),
    .sys_ctu_x_all_i      ( sys_ctu_x_all_i        ),
    .sys_ctu_y_all_i      ( sys_ctu_y_all_i        ),
    .sys_x_all_i          ( sys_x_all_i            ),
    .sys_y_all_i          ( sys_y_all_i            ),
    .IinP_flag_i          ( IinP_flag_i            ),
    .sysif_qp_i           ( rc_qp_i                ),
    .sysif_done_o         ( fme_done_o             ),
    // ime_if
    .fimeif_partition_i   ( fme_partition_i        ),
    .fimeif_mv_rden_o     ( fme_mv_rden_o          ),
    .fimeif_mv_rdaddr_o   ( fme_mv_rdaddr_o        ),
    .fimeif_mv_data_i     ( fme_mv_data_i          ),
    // cur_if
    .cur_rden_o           ( fme_cur_rden_o         ),
    .cur_4x4_idx_o        ( fme_cur_4x4_idx_o      ),
    .cur_4x4_x_o          ( fme_cur_4x4_x_o        ),
    .cur_4x4_y_o          ( fme_cur_4x4_y_o        ),
    .cur_pel_i            ( fme_cur_pel_i          ),
    // ref_if
    .ref_rden_o           ( fme_ref_rden_o         ),
    .ref_idx_x_o          ( fme_ref_idx_x_o        ),
    .ref_idx_y_o          ( fme_ref_idx_y_o        ),
    .ref_pel_i            ( fme_ref_pel_i          ),
    // fme cost if
    .fme_cost_o           ( fme_cost_o             ),
    // skip 
    .skip_idx_o           ( skip_idx_o             ),
    .skip_flag_o          ( skip_flag_o            ),
    // mc_if
    .mcif_mv_rden_o       ( mcif_mv_rden_w         ),
    .mcif_mv_rdaddr_o     ( mcif_mv_rdaddr_w       ),
    .mcif_mv_data_i       ( mcif_mv_rddata_w       ),
    .mcif_mv_wren_o       ( mcif_mv_wren_w         ),
    .mcif_mv_wraddr_o     ( mcif_mv_wraddr_w       ),
    .mcif_mv_data_o       ( mcif_mv_wrdata_w       ),
    .mcif_pre_pixel_o     ( mcif_pre_pixel_w       ),
    .mcif_pre_wren_o      ( mcif_pre_wren_w        ),
    .mcif_wr_4x4_x_o      ( mcif_pre_4x4_x_w       ),
    .mcif_wr_4x4_y_o      ( mcif_pre_4x4_y_w       ),
    .mcif_wr_idx_o        ( mcif_pre_4x4_idx_w     ),
    .mcif_siz_o           ( mcif_pre_size_w        ) 
    );

  // rec_mem
  assign fme_rec_mem_0_wen_i      = (sel_mod_2_i==0) ? mcif_pre_wren_w        : mc_pred_wr_ren_i       ;
  assign fme_rec_mem_0_size_i     = (sel_mod_2_i==0) ? mcif_pre_size_w        : mc_pred_wr_size_i      ;
  assign fme_rec_mem_0_4x4_x_i    = (sel_mod_2_i==0) ? mcif_pre_4x4_x_w       : mc_pred_wr_4x4_x_i     ;
  assign fme_rec_mem_0_4x4_y_i    = (sel_mod_2_i==0) ? mcif_pre_4x4_y_w       : mc_pred_wr_4x4_y_i     ;
  assign fme_rec_mem_0_4x4_idx_i  = (sel_mod_2_i==0) ? mcif_pre_4x4_idx_w     : mc_pred_wr_4x4_idx_i   ;
  assign fme_rec_mem_0_wdata_i    = (sel_mod_2_i==0) ? mcif_pre_pixel_w       : mc_pred_wr_rdata_i     ;

  assign fme_rec_mem_1_wen_i      = (sel_mod_2_i==1) ? mcif_pre_wren_w        : mc_pred_wr_ren_i       ;
  assign fme_rec_mem_1_size_i     = (sel_mod_2_i==1) ? mcif_pre_size_w        : mc_pred_wr_size_i      ;
  assign fme_rec_mem_1_4x4_x_i    = (sel_mod_2_i==1) ? mcif_pre_4x4_x_w       : mc_pred_wr_4x4_x_i     ;
  assign fme_rec_mem_1_4x4_y_i    = (sel_mod_2_i==1) ? mcif_pre_4x4_y_w       : mc_pred_wr_4x4_y_i     ;
  assign fme_rec_mem_1_4x4_idx_i  = (sel_mod_2_i==1) ? mcif_pre_4x4_idx_w     : mc_pred_wr_4x4_idx_i   ;
  assign fme_rec_mem_1_wdata_i    = (sel_mod_2_i==1) ? mcif_pre_pixel_w       : mc_pred_wr_rdata_i     ;

  assign mc_pred_rd_rdata_o = sel_mod_2_i==0? mc_pred_rd_rdata_1_w : mc_pred_rd_rdata_0_w ;

  fme_buf_wrapper fme_rec_mem_0 (
    .clk                ( clk                       ),
    .rstn               ( rstn                      ),

    .wr_ena_i           ( fme_rec_mem_0_wen_i       ), // high active
    .wr_siz_i           ( fme_rec_mem_0_size_i      ),
    .wr_4x4_x_i         ( fme_rec_mem_0_4x4_x_i     ),
    .wr_4x4_y_i         ( fme_rec_mem_0_4x4_y_i     ),
    .wr_idx_i           ( fme_rec_mem_0_4x4_idx_i   ),
    .wr_dat_i           ( fme_rec_mem_0_wdata_i     ),

    .rd_ena_i           ( mc_pred_rd_ren_i && sel_mod_2_i==1 ),
    .rd_siz_i           ( mc_pred_rd_size_i         ),
    .rd_4x4_x_i         ( mc_pred_rd_4x4_x_i        ),
    .rd_4x4_y_i         ( mc_pred_rd_4x4_y_i        ),
    .rd_idx_i           ( mc_pred_rd_4x4_idx_i      ),
    .rd_dat_o           ( mc_pred_rd_rdata_0_w      )
    );

  fme_buf_wrapper fme_rec_mem_1 (
    .clk                ( clk                       ),
    .rstn               ( rstn                      ),

    .wr_ena_i           ( fme_rec_mem_1_wen_i       ),
    .wr_siz_i           ( fme_rec_mem_1_size_i      ),
    .wr_4x4_x_i         ( fme_rec_mem_1_4x4_x_i     ),
    .wr_4x4_y_i         ( fme_rec_mem_1_4x4_y_i     ),
    .wr_idx_i           ( fme_rec_mem_1_4x4_idx_i   ),
    .wr_dat_i           ( fme_rec_mem_1_wdata_i     ),

    .rd_ena_i           ( mc_pred_rd_ren_i && sel_mod_2_i==0 ), // high active
    .rd_siz_i           ( mc_pred_rd_size_i         ),
    .rd_4x4_x_i         ( mc_pred_rd_4x4_x_i        ),
    .rd_4x4_y_i         ( mc_pred_rd_4x4_y_i        ),
    .rd_idx_i           ( mc_pred_rd_4x4_idx_i      ),
    .rd_dat_o           ( mc_pred_rd_rdata_1_w      )
    );


  // mv_mem
  always @(*) begin
                   fme_mv_mem_0_rdaddr_w = 0 ;
                   fme_mv_mem_0_wren_w   = 0 ;
                   fme_mv_mem_0_wraddr_w = 0 ;
                   fme_mv_mem_0_wrdata_w = 0 ;
    case( sel_mod_3_i )
      0 : begin    fme_mv_mem_0_rdaddr_w = mcif_mv_rdaddr_w ;
                   fme_mv_mem_0_wren_w   = mcif_mv_wren_w   ;
                   fme_mv_mem_0_wraddr_w = mcif_mv_wraddr_w ;
                   fme_mv_mem_0_wrdata_w = mcif_mv_wrdata_w ;
          end
      1 : begin    fme_mv_mem_0_rdaddr_w = mc_mv_rdaddr_i   ;
          end
      2 : begin    fme_mv_mem_0_rdaddr_w = db_mv_rdaddr_i   ;
          end
    endcase
  end

  always @(*) begin
                   fme_mv_mem_1_rdaddr_w = 0 ;
                   fme_mv_mem_1_wren_w   = 0 ;
                   fme_mv_mem_1_wraddr_w = 0 ;
                   fme_mv_mem_1_wrdata_w = 0 ;
    case( sel_mod_3_i )
      1 : begin    fme_mv_mem_1_rdaddr_w = mcif_mv_rdaddr_w ;
                   fme_mv_mem_1_wren_w   = mcif_mv_wren_w   ;
                   fme_mv_mem_1_wraddr_w = mcif_mv_wraddr_w ;
                   fme_mv_mem_1_wrdata_w = mcif_mv_wrdata_w ;
          end
      2 : begin    fme_mv_mem_1_rdaddr_w = mc_mv_rdaddr_i   ;
          end
      0 : begin    fme_mv_mem_1_rdaddr_w = db_mv_rdaddr_i   ;
          end
    endcase
  end

  always @(*) begin
                   fme_mv_mem_2_rdaddr_w = 0 ;
                   fme_mv_mem_2_wren_w   = 0 ;
                   fme_mv_mem_2_wraddr_w = 0 ;
                   fme_mv_mem_2_wrdata_w = 0 ;
    case( sel_mod_3_i )
      2 : begin    fme_mv_mem_2_rdaddr_w = mcif_mv_rdaddr_w ;
                   fme_mv_mem_2_wren_w   = mcif_mv_wren_w   ;
                   fme_mv_mem_2_wraddr_w = mcif_mv_wraddr_w ;
                   fme_mv_mem_2_wrdata_w = mcif_mv_wrdata_w ;
          end
      0 : begin    fme_mv_mem_2_rdaddr_w = mc_mv_rdaddr_i   ;
          end
      1 : begin    fme_mv_mem_2_rdaddr_w = db_mv_rdaddr_i   ;
          end
    endcase
  end


  always @(*) begin
          mcif_mv_rddata_w = 0 ;
    case( sel_mod_3_i )
      0 : mcif_mv_rddata_w = fme_mv_mem_0_rddata_w ;
      1 : mcif_mv_rddata_w = fme_mv_mem_1_rddata_w ;
      2 : mcif_mv_rddata_w = fme_mv_mem_2_rddata_w ;
    endcase
  end

  always @(*) begin
          mc_mv_o = 0 ;
    case( sel_mod_3_i )
      1 : mc_mv_o = fme_mv_mem_0_rddata_w ;
      2 : mc_mv_o = fme_mv_mem_1_rddata_w ;
      0 : mc_mv_o = fme_mv_mem_2_rddata_w ;
    endcase
  end

  always @(*) begin
          db_mv_o = 0 ;
    case( sel_mod_3_i )
      2 : db_mv_o = fme_mv_mem_0_rddata_w;
      0 : db_mv_o = fme_mv_mem_1_rddata_w;
      1 : db_mv_o = fme_mv_mem_2_rddata_w;
    endcase
  end

  fme_mv_ram_dp_64x20 fme_mv_mem_0 (
    .clka                 ( clk                    ),
    .cena_i               ( 1'b0                   ),
    .addra_i              ( fme_mv_mem_0_rdaddr_w  ),
    .dataa_o              ( fme_mv_mem_0_rddata_w  ),
    .clkb                 ( clk                    ),
    .cenb_i               ( 1'b0                   ),
    .wenb_i               ( !fme_mv_mem_0_wren_w   ),
    .addrb_i              ( fme_mv_mem_0_wraddr_w  ),
    .datab_i              ( fme_mv_mem_0_wrdata_w  )
    );

  fme_mv_ram_dp_64x20 fme_mv_mem_1 (
    .clka                 ( clk                    ),
    .cena_i               ( 1'b0                   ),
    .addra_i              ( fme_mv_mem_1_rdaddr_w  ),
    .dataa_o              ( fme_mv_mem_1_rddata_w  ),
    .clkb                 ( clk                    ),
    .cenb_i               ( 1'b0                   ),
    .wenb_i               ( !fme_mv_mem_1_wren_w   ),
    .addrb_i              ( fme_mv_mem_1_wraddr_w  ),
    .datab_i              ( fme_mv_mem_1_wrdata_w  )
    );

  fme_mv_ram_dp_64x20 fme_mv_mem_2 (
    .clka                 ( clk                    ),
    .cena_i               ( 1'b0                   ),
    .addra_i              ( fme_mv_mem_2_rdaddr_w  ),
    .dataa_o              ( fme_mv_mem_2_rddata_w  ),
    .clkb                 ( clk                    ),
    .cenb_i               ( 1'b0                   ),
    .wenb_i               ( !fme_mv_mem_2_wren_w   ),
    .addrb_i              ( fme_mv_mem_2_wraddr_w  ),
    .datab_i              ( fme_mv_mem_2_wrdata_w  )
    );


endmodule 