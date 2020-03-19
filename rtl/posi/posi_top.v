//--------------------------------------------------------------------
//
//  Filename    : h265_posi_top.v
//  Author      : Huang Leilei
//  Description : top of post intra
//  Created     : 2018-04-08
//
//--------------------------------------------------------------------

`include "./enc_defines.v"

module posi_top(
  // global
  clk               ,
  rstn              ,
  sys_posi4x4bit_i  ,
  // ctrl_if
  start_i           ,
  done_o            ,
  // cfg_i
  num_mode_i        ,
  ctu_x_all_i       ,
  ctu_y_all_i       ,
  ctu_x_res_i       ,
  ctu_y_res_i       ,
  ctu_x_cur_i       ,
  ctu_y_cur_i       ,
  qp_i              ,
  // md_if (rd)
  mod_rd_ena_o      ,
  mod_rd_adr_o      ,
  mod_rd_dat_i      ,
  // cur_if (rd)
  ori_rd_ena_o      ,
  ori_rd_sel_o      ,
  ori_rd_siz_o      ,
  ori_rd_4x4_x_o    ,
  ori_rd_4x4_y_o    ,
  ori_rd_idx_o      ,
  ori_rd_dat_i      ,
  // md_if (wr)
  mod_wr_ena_o      ,
  mod_wr_adr_o      ,
  mod_wr_dat_o      ,
  // pt_o
  partition_o       ,
  //cost_o 
  cost_o          
  );


//*** PARAMETER ****************************************************************

  // local
  localparam    TRA_MODE_PRE           = 0                  ;
  localparam    TRA_MODE_POS           = 1                  ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                clk                  ;
  input                                rstn                 ;
  input  [5-1:0]                       sys_posi4x4bit_i     ;
  // ctrl_if
  input                                start_i              ;
  output                               done_o               ;
  // cfg_i
  input  [3                  -1 :0]    num_mode_i           ;
  input  [`PIC_X_WIDTH       -1 :0]    ctu_x_all_i          ;
  input  [`PIC_Y_WIDTH       -1 :0]    ctu_y_all_i          ;
  input  [4                  -1 :0]    ctu_x_res_i          ;
  input  [4                  -1 :0]    ctu_y_res_i          ;
  input  [`PIC_X_WIDTH       -1 :0]    ctu_x_cur_i          ;
  input  [`PIC_Y_WIDTH       -1 :0]    ctu_y_cur_i          ;
  input  [6-1:0]                       qp_i                 ;
  // md_if
  output                               mod_rd_ena_o         ;
  output [9                  -1 :0]    mod_rd_adr_o         ;
  input  [6                  -1 :0]    mod_rd_dat_i         ;
  // cur_rd_if
  output                               ori_rd_ena_o         ;
  output [2                  -1 :0]    ori_rd_sel_o         ;
  output [2                  -1 :0]    ori_rd_siz_o         ;
  output [4                  -1 :0]    ori_rd_4x4_x_o       ;
  output [4                  -1 :0]    ori_rd_4x4_y_o       ;
  output [5                  -1 :0]    ori_rd_idx_o         ;
  input  [`PIXEL_WIDTH*32    -1 :0]    ori_rd_dat_i         ;
  // md_if
  output                               mod_wr_ena_o         ;
  output [8                  -1 :0]    mod_wr_adr_o         ;
  output [6                  -1 :0]    mod_wr_dat_o         ;
  // pt_o
  output [85                 -1 :0]    partition_o          ;
  // cost_o
  output [`POSI_COST_WIDTH   -1 :0]    cost_o               ;
 

//*** REG/WIRE *****************************************************************

  // ctrl
  wire                                 ctr_start_tra_o_w    ;
  wire                                 ctr_start_ref_o_w    ;

  wire                                 ctr_tra_busy_o_w     ;
  wire                                 ctr_tra_mode_o_w     ;
  wire   [2                  -1 :0]    ctr_size_o_w         ;
  wire   [8                  -1 :0]    ctr_position_o_w     ;

  // tra
  wire                                 tra_done_o_w         ;

  wire                                 tra_ori_rd_ena_o_w   ;
  wire   [2                  -1 :0]    tra_ori_rd_siz_o_w   ;
  wire   [4                  -1 :0]    tra_ori_rd_4x4_x_o_w ;
  wire   [4                  -1 :0]    tra_ori_rd_4x4_y_o_w ;
  wire   [5                  -1 :0]    tra_ori_rd_idx_o_w   ;

  wire                                 tra_row_wr_ena_o_w   ;
  wire   [4+4                -1 :0]    tra_row_wr_adr_o_w   ;
  wire   [`PIXEL_WIDTH*4     -1 :0]    tra_row_wr_dat_o_w   ;

  wire                                 tra_col_wr_ena_o_w   ;
  wire   [4+4                -1 :0]    tra_col_wr_adr_o_w   ;
  wire   [`PIXEL_WIDTH*4     -1 :0]    tra_col_wr_dat_o_w   ;

  wire                                 tra_fra_wr_ena_o_w   ;
  wire   [`PIC_X_WIDTH+4     -1 :0]    tra_fra_wr_adr_o_w   ;
  wire   [`PIXEL_WIDTH*4     -1 :0]    tra_fra_wr_dat_o_w   ;

  // ref
  wire                                 ref_ready_o_w        ;
  wire                                 ref_done_o_w         ;

  wire                                 ref_row_rd_ena_o_w   ;
  wire   [4+4                -1 :0]    ref_row_rd_adr_o_w   ;
  wire   [`PIXEL_WIDTH*4     -1 :0]    ref_row_rd_dat_i_w   ;

  wire                                 ref_col_rd_ena_o_w   ;
  wire   [4+4                -1 :0]    ref_col_rd_adr_o_w   ;
  wire   [`PIXEL_WIDTH*4     -1 :0]    ref_col_rd_dat_i_w   ;

  wire                                 ref_fra_rd_ena_o_w   ;
  wire   [`PIC_X_WIDTH+4     -1 :0]    ref_fra_rd_adr_o_w   ;
  wire   [`PIXEL_WIDTH*4     -1 :0]    ref_fra_rd_dat_i_w   ;

  wire   [6                  -1 :0]    ref_mode_o_w         ;
  wire   [2                  -1 :0]    ref_size_o_w         ;
  wire   [8                  -1 :0]    ref_position_o_w     ;

  wire   [`PIXEL_WIDTH*32    -1 :0]    ref_dat_r_o_w        ;
  wire   [`PIXEL_WIDTH*32    -1 :0]    ref_dat_t_o_w        ;
  wire   [`PIXEL_WIDTH       -1 :0]    ref_dat_tl_o_w       ;
  wire   [`PIXEL_WIDTH*32    -1 :0]    ref_dat_l_o_w        ;
  wire   [`PIXEL_WIDTH*32    -1 :0]    ref_dat_d_o_w        ;

  // pre
  wire                                 pre_val_ahd_o_w      ;
  wire   [4                  -1 :0]    pre_idx_4x4_x_ahd_o_w;
  wire   [4                  -1 :0]    pre_idx_4x4_y_ahd_o_w;

  wire   [6                  -1 :0]    pre_mode_o_w         ;
  wire   [2                  -1 :0]    pre_size_o_w         ;
  wire   [8                  -1 :0]    pre_position_o_w     ;

  wire                                 pre_val_o_w          ;
  wire   [`PIXEL_WIDTH*16    -1 :0]    pre_dat_o_w          ;

  // buf
  wire                                 buf_ori_rd_ena_o_w   ;
  wire   [2                  -1 :0]    buf_ori_rd_siz_o_w   ;
  wire   [4                  -1 :0]    buf_ori_rd_4x4_x_o_w ;
  wire   [4                  -1 :0]    buf_ori_rd_4x4_y_o_w ;
  wire   [5                  -1 :0]    buf_ori_rd_idx_o_w   ;

  wire   [6                  -1 :0]    buf_mode_o_w         ;
  wire   [2                  -1 :0]    buf_size_o_w         ;
  wire   [8                  -1 :0]    buf_position_o_w     ;

  wire                                 buf_val_o_w          ;
  wire   [(`PIXEL_WIDTH+1)*16-1 :0]    buf_dat_o_w          ;

  // cst
  wire   [6                  -1 :0]    cst_mode_o_w         ;
  wire   [2                  -1 :0]    cst_size_o_w         ;
  wire   [8                  -1 :0]    cst_position_o_w     ;

  wire                                 cst_val_o_w          ;
  wire   [`POSI_COST_WIDTH   -1 :0]    cst_dat_o_w          ;

  wire                                 dec_done_o_w         ;

//*** MAIN BODY ****************************************************************

//--- ASSINMENT ------------------------
  assign ori_rd_ena_o   = ctr_tra_busy_o_w ? tra_ori_rd_ena_o_w   : buf_ori_rd_ena_o_w   ;
  assign ori_rd_siz_o   = ctr_tra_busy_o_w ? tra_ori_rd_siz_o_w   : buf_ori_rd_siz_o_w   ;
  assign ori_rd_4x4_x_o = ctr_tra_busy_o_w ? tra_ori_rd_4x4_x_o_w : buf_ori_rd_4x4_x_o_w ;
  assign ori_rd_4x4_y_o = ctr_tra_busy_o_w ? tra_ori_rd_4x4_y_o_w : buf_ori_rd_4x4_y_o_w ;
  assign ori_rd_idx_o   = ctr_tra_busy_o_w ? tra_ori_rd_idx_o_w   : buf_ori_rd_idx_o_w   ;
  assign ori_rd_sel_o   = `TYPE_Y ;


//--- SUB MODULES ----------------------
  // h265_posi_ctrl
  posi_ctrl #(
    .TRA_MODE_PRE       ( TRA_MODE_PRE          ),
    .TRA_MODE_POS       ( TRA_MODE_POS          )
  ) posi_ctrl(
    // global
    .clk                ( clk                   ),
    .rstn               ( rstn                  ),
    // ctrl_if
    .start_i            (     start_i           ),
    .done_o             (     done_o            ),
    // cfg_i
    .num_mode_i         (     num_mode_i        ),
    // ctrl_if (inner)
    .start_tra_o        ( ctr_start_tra_o_w     ),
    .start_ref_o        ( ctr_start_ref_o_w     ),
    .done_tra_i         ( tra_done_o_w          ),
    .done_ref_i         ( ref_done_o_w          ),
    .done_dec_i         ( dec_done_o_w          ),
    // cfg_o
    .tra_busy_o         ( ctr_tra_busy_o_w      ),
    .tra_mode_o         ( ctr_tra_mode_o_w      ),
    .size_o             ( ctr_size_o_w          ),
    .position_o         ( ctr_position_o_w      )
    );

  // h265_posi_transfer
  posi_transfer #(
    .MODE_PRE           ( TRA_MODE_PRE          ),
    .MODE_POS           ( TRA_MODE_POS          )
  )  posi_transfer(
    // global
    .clk                ( clk                   ),
    .rstn               ( rstn                  ),
    // ctrl_if
    .start_i            ( ctr_start_tra_o_w     ),
    .done_o             ( tra_done_o_w          ),
    // cfg_i
    .mode_i             ( ctr_tra_mode_o_w      ),
    .ctu_x_cur_i        (     ctu_x_cur_i       ),
    // ori_if
    .ori_rd_ena_o       ( tra_ori_rd_ena_o_w    ),
    .ori_rd_siz_o       ( tra_ori_rd_siz_o_w    ),
    .ori_rd_4x4_x_o     ( tra_ori_rd_4x4_x_o_w  ),
    .ori_rd_4x4_y_o     ( tra_ori_rd_4x4_y_o_w  ),
    .ori_rd_idx_o       ( tra_ori_rd_idx_o_w    ),
    .ori_rd_dat_i       (     ori_rd_dat_i      ),
    // ram_row_wr_if
    .row_wr_ena_o       ( tra_row_wr_ena_o_w    ),
    .row_wr_adr_o       ( tra_row_wr_adr_o_w    ),
    .row_wr_dat_o       ( tra_row_wr_dat_o_w    ),
    // ram_col_wr_if
    .col_wr_ena_o       ( tra_col_wr_ena_o_w    ),
    .col_wr_adr_o       ( tra_col_wr_adr_o_w    ),
    .col_wr_dat_o       ( tra_col_wr_dat_o_w    ),
    // ram_fra_wr_if
    .fra_wr_ena_o       ( tra_fra_wr_ena_o_w    ),
    .fra_wr_adr_o       ( tra_fra_wr_adr_o_w    ),
    .fra_wr_dat_o       ( tra_fra_wr_dat_o_w    )
    );

  // h265_posi_ref
  posi_reference posi_reference(
    // global
    .clk                ( clk                   ),
    .rstn               ( rstn                  ),
    // ctrl_if
    .start_i            ( ctr_start_ref_o_w     ),
    .ready_o            ( ref_ready_o_w         ),
    .done_o             ( ref_done_o_w          ),
    // cfg_i
    .num_mode_i         (     num_mode_i        ),
    .ctu_x_all_i        ( ctu_x_all_i           ),
    .ctu_y_all_i        ( ctu_y_all_i           ),
    .ctu_x_res_i        ( ctu_x_res_i           ),
    .ctu_y_res_i        ( ctu_y_res_i           ),
    .ctu_x_cur_i        ( ctu_x_cur_i           ),
    .ctu_y_cur_i        ( ctu_y_cur_i           ),
    .size_i             ( ctr_size_o_w          ),
    .position_i         ( ctr_position_o_w      ),
    // ram_row_if
    .row_rd_ena_o       ( ref_row_rd_ena_o_w    ),
    .row_rd_adr_o       ( ref_row_rd_adr_o_w    ),
    .row_rd_dat_i       ( ref_row_rd_dat_i_w    ),
    // ram_col_if
    .col_rd_ena_o       ( ref_col_rd_ena_o_w    ),
    .col_rd_adr_o       ( ref_col_rd_adr_o_w    ),
    .col_rd_dat_i       ( ref_col_rd_dat_i_w    ),
    // ram_fra_if
    .fra_rd_ena_o       ( ref_fra_rd_ena_o_w    ),
    .fra_rd_adr_o       ( ref_fra_rd_adr_o_w    ),
    .fra_rd_dat_i       ( ref_fra_rd_dat_i_w    ),
    // ram_mod_if
    .mod_rd_ena_o       (     mod_rd_ena_o      ),
    .mod_rd_adr_o       (     mod_rd_adr_o      ),
    .mod_rd_dat_i       (     mod_rd_dat_i      ),
    // cfg_o
    .mode_o             ( ref_mode_o_w          ),
    .size_o             ( ref_size_o_w          ),
    .position_o         ( ref_position_o_w      ),
    // ref_o
    .ref_r_o            ( ref_dat_r_o_w         ),
    .ref_t_o            ( ref_dat_t_o_w         ),
    .ref_tl_o           ( ref_dat_tl_o_w        ),
    .ref_l_o            ( ref_dat_l_o_w         ),
    .ref_d_o            ( ref_dat_d_o_w         )
    );

  // h265_posi_prediction
  posi_prediction posi_prediction(
    // global
    .clk                ( clk                   ),
    .rstn               ( rstn                  ),
    // ctrl_if
    .start_i            ( ref_ready_o_w         ),
    // cfg_i
    .mode_i             ( ref_mode_o_w          ),
    .size_i             ( ref_size_o_w          ),
    .position_i         ( ref_position_o_w      ),
    // ref_i
    .dat_ref_r_i        ( ref_dat_r_o_w         ),
    .dat_ref_t_i        ( ref_dat_t_o_w         ),
    .dat_ref_tl_i       ( ref_dat_tl_o_w        ),
    .dat_ref_l_i        ( ref_dat_l_o_w         ),
    .dat_ref_d_i        ( ref_dat_d_o_w         ),
    // ahd_o
    .val_ahd_o          ( pre_val_ahd_o_w       ),
    .idx_4x4_x_ahd_o    ( pre_idx_4x4_x_ahd_o_w ),
    .idx_4x4_y_ahd_o    ( pre_idx_4x4_y_ahd_o_w ),
    // cfg_o
    .mode_o             ( pre_mode_o_w          ),
    .size_o             ( pre_size_o_w          ),
    .position_o         ( pre_position_o_w      ),
    // pre_o
    .val_o              ( pre_val_o_w           ),
    .dat_pre_o          ( pre_dat_o_w           )
    );

  // h265_posi_buffer
  posi_buffer posi_buffer(
    // global
    .clk                ( clk                   ),
    .rstn               ( rstn                  ),
    // ahd_i
    .val_ahd_i          ( pre_val_ahd_o_w       ),
    .idx_4x4_x_ahd_i    ( pre_idx_4x4_x_ahd_o_w ),
    .idx_4x4_y_ahd_i    ( pre_idx_4x4_y_ahd_o_w ),
    // cfg_i
    .val_i              ( pre_val_o_w           ),
    .mode_i             ( pre_mode_o_w          ),
    .size_i             ( pre_size_o_w          ),
    .position_i         ( pre_position_o_w      ),
    // dat_i
    .dat_i              ( pre_dat_o_w           ),
    // ori_if
    .ori_rd_ena_o       ( buf_ori_rd_ena_o_w    ),
    .ori_rd_siz_o       ( buf_ori_rd_siz_o_w    ),
    .ori_rd_4x4_x_o     ( buf_ori_rd_4x4_x_o_w  ),
    .ori_rd_4x4_y_o     ( buf_ori_rd_4x4_y_o_w  ),
    .ori_rd_idx_o       ( buf_ori_rd_idx_o_w    ),
    .ori_rd_dat_i       (     ori_rd_dat_i      ),
    // cfg_o
    .mode_o             ( buf_mode_o_w          ),
    .size_o             ( buf_size_o_w          ),
    .position_o         ( buf_position_o_w      ),
    // dat_o
    .val_o              ( buf_val_o_w           ),
    .dat_o              ( buf_dat_o_w           )
    );

  // h265_posi_satd_cost
  posi_satd_cost posi_satd_cost(
    // global
    .clk                ( clk                   ),
    .rstn               ( rstn                  ),
    .qp_i               ( qp_i                  ),
    .sys_posi4x4bit_i   ( sys_posi4x4bit_i      ),
    // cfg_i
    .mode_i             ( buf_mode_o_w          ),
    .size_i             ( buf_size_o_w          ),
    .position_i         ( buf_position_o_w      ),
    // dat_i
    .val_i              ( buf_val_o_w           ),
    .dat_i              ( buf_dat_o_w           ),
    // cfg_o
    .mode_o             ( cst_mode_o_w          ),
    .size_o             ( cst_size_o_w          ),
    .position_o         ( cst_position_o_w      ),
    // dat_o
    .val_o              ( cst_val_o_w           ),
    .dat_o              ( cst_dat_o_w           )
    );

  // h265_posi_partition_decision
  posi_partition_decision posi_partition_decision(
    // global
    .clk                ( clk                   ),
    .rstn               ( rstn                  ),
    // ctrl_i
    .clr_i              (     start_i           ),
    .done_o             ( dec_done_o_w          ),
    // ctu info
    .ctu_x_all_i        ( ctu_x_all_i           ),
    .ctu_y_all_i        ( ctu_y_all_i           ),
    .ctu_x_res_i        ( ctu_x_res_i           ),
    .ctu_y_res_i        ( ctu_y_res_i           ),
    .ctu_x_cur_i        ( ctu_x_cur_i           ),
    .ctu_y_cur_i        ( ctu_y_cur_i           ),
    // cfg_i
    .num_mode_i         (     num_mode_i        ),
    .mode_i             ( cst_mode_o_w          ),
    .size_i             ( cst_size_o_w          ),
    .position_i         ( cst_position_o_w      ),
    // dat_i
    .val_i              ( cst_val_o_w           ),
    .cst_i              ( cst_dat_o_w           ),
    // dat_o
    .prt_o              (     partition_o       ),
    // mode_if
    .mod_wr_ena_o       (     mod_wr_ena_o      ),
    .mod_wr_adr_o       (     mod_wr_adr_o      ),
    .mod_wr_dat_o       (     mod_wr_dat_o      ),
    // cost_o
    .bst_cost_o         (     cost_o            )
    );


//--- MEMORY ---------------------------
  posi_memory_wrapper posi_memory_wrapper(
    // global
    .clk                ( clk                   ),
    .rstn               ( rstn                  ),
    // ram_row_wr_if
    .row_wr_ena_i       ( tra_row_wr_ena_o_w    ),
    .row_wr_adr_i       ( tra_row_wr_adr_o_w    ),
    .row_wr_dat_i       ( tra_row_wr_dat_o_w    ),
    // ram_col_wr_if
    .col_wr_ena_i       ( tra_col_wr_ena_o_w    ),
    .col_wr_adr_i       ( tra_col_wr_adr_o_w    ),
    .col_wr_dat_i       ( tra_col_wr_dat_o_w    ),
    // ram_fra_wr_if
    .fra_wr_ena_i       ( tra_fra_wr_ena_o_w    ),
    .fra_wr_adr_i       ( tra_fra_wr_adr_o_w    ),
    .fra_wr_dat_i       ( tra_fra_wr_dat_o_w    ),
    // ram_row_rd_if
    .row_rd_ena_i       ( ref_row_rd_ena_o_w    ),
    .row_rd_adr_i       ( ref_row_rd_adr_o_w    ),
    .row_rd_dat_o       ( ref_row_rd_dat_i_w    ),
    // ram_col_rd_if
    .col_rd_ena_i       ( ref_col_rd_ena_o_w    ),
    .col_rd_adr_i       ( ref_col_rd_adr_o_w    ),
    .col_rd_dat_o       ( ref_col_rd_dat_i_w    ),
    // ram_fra_rd_if
    .fra_rd_ena_i       ( ref_fra_rd_ena_o_w    ),
    .fra_rd_adr_i       ( ref_fra_rd_adr_o_w    ),
    .fra_rd_dat_o       ( ref_fra_rd_dat_i_w    )
    );


//*** DEBUG ********************************************************************

`ifdef H265_DEBUG

`endif

endmodule
