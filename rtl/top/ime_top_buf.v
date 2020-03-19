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
//  Filename      : ime_top_buf.v
//  Author        : TANG
//  Created       : 2018-04-20
//  Description   : ime top with memory buffer
//
//-------------------------------------------------------------------
`include "enc_defines.v"

module ime_top_buf(
  // sys_if
  clk                     ,
  rstn                    ,
  sel_mod_2_i             ,
  // ime_cfg_if
  ime_cmd_num_i           ,
  ime_cmd_dat_i           ,
  // status
  ime_downsample_o        ,
  // ime_ctrl_if
  ime_start_i             ,
  ime_qp_i                ,
  ctu_x_res_i             ,
  ctu_y_res_i             ,
  sys_ctu_all_x_i         ,
  sys_ctu_all_y_i         ,
  ime_ctu_x_i             ,
  ime_ctu_y_i             ,
  ime_done_o              ,
  // ime_cur_if
  ime_cur_4x4_x_o         ,
  ime_cur_4x4_y_o         ,
  ime_cur_4x4_idx_o       ,
  ime_cur_sel_o           ,
  ime_cur_size_o          ,
  ime_cur_rden_o          ,
  ime_cur_pel_i           ,
  // ime_ref_if
  ime_ref_hor_ena_o       ,
  ime_ref_hor_adr_x_o     ,
  ime_ref_hor_adr_y_o     ,
  ime_ref_hor_dat_i       ,
  // ime_partition_if
  ime_partition_o         ,
  // fme_read_ime_mv_if
  fme_mv_rden_i           ,
  fme_mv_rdaddr_i         ,
  fme_mv_data_o           
  );

//*** PARAMETER DECLARATION ****************************************************

  // global
  parameter     CMD_NUM_WIDTH            = 3                         ;

  // derived
  localparam    CMD_DAT_WIDTH_ONE        =(`IME_MV_WIDTH_X  )             // center_x_o
                                         +(`IME_MV_WIDTH_Y  )             // center_y_o
                                         +(`IME_MV_WIDTH_X-1)             // length_x_o
                                         +(`IME_MV_WIDTH_Y-1)             // length_y_o
                                         +(2                )             // slope_o
                                         +(1                )             // downsample_o
                                         +(1                )             // partition_r
                                         +(1                )        ;    // use_feedback_o
  localparam    CMD_DAT_WIDTH            = CMD_DAT_WIDTH_ONE
                                         *(1<<CMD_NUM_WIDTH )        ;


//**** INPUT/OUTPUT DECLARATION ***********************************
  // sys_if
  input                                       clk                     ;
  input                                       rstn                    ;
  input  [1                 -1:0]             sel_mod_2_i             ;
  // ime_cfg_if
  input  [CMD_NUM_WIDTH               -1 :0]  ime_cmd_num_i           ;
  input  [CMD_DAT_WIDTH               -1 :0]  ime_cmd_dat_i           ;
  // status
  output                                      ime_downsample_o        ;
  // ime_ctrl_if
  input                                       ime_start_i             ;
  input  [6                           -1 :0]  ime_qp_i                ;
  input  [4                           -1 :0]  ctu_x_res_i             ; 
  input  [4                           -1 :0]  ctu_y_res_i             ; 
  input  [`PIC_X_WIDTH                -1 :0]  sys_ctu_all_x_i         ;
  input  [`PIC_Y_WIDTH                -1 :0]  sys_ctu_all_y_i         ;
  input  [`PIC_X_WIDTH                -1 :0]  ime_ctu_x_i             ;
  input  [`PIC_Y_WIDTH                -1 :0]  ime_ctu_y_i             ;
  output                                      ime_done_o              ;
    // ime_cur_if   
  output [4                           -1 :0]  ime_cur_4x4_x_o         ;
  output [4                           -1 :0]  ime_cur_4x4_y_o         ;
  output [5                           -1 :0]  ime_cur_4x4_idx_o       ;
  output [2                           -1 :0]  ime_cur_sel_o           ;
  output [2                           -1 :0]  ime_cur_size_o          ;
  output                                      ime_cur_rden_o          ;
  input  [`PIXEL_WIDTH*32             -1 :0]  ime_cur_pel_i           ;
  // ime_ref_if
  output                                      ime_ref_hor_ena_o       ;
  output [`IME_MV_WIDTH_X                :0]  ime_ref_hor_adr_x_o     ;
  output [`IME_MV_WIDTH_Y                :0]  ime_ref_hor_adr_y_o     ;
  input  [`PIXEL_WIDTH*32             -1 :0]  ime_ref_hor_dat_i       ;
  // ime_partition_if
  output [42                          -1 :0]  ime_partition_o         ;
  // fme_read_ime_mv_if
  input  [1                            -1:0]  fme_mv_rden_i           ;
  input  [6                            -1:0]  fme_mv_rdaddr_i         ;
  output [2*`FMV_WIDTH                 -1:0]  fme_mv_data_o           ;     

//**** WIRE/REG DECLARATION ************************************************
  wire                                        ime_mv_wr_ena_w         ;
  wire   [6                          -1 :0]   ime_mv_wr_adr_w         ;
  wire   [`IME_MV_WIDTH              -1 :0]   ime_mv_wr_dat_w         ;
  wire   [`IME_MV_WIDTH              -1 :0]   fme_mv_data_0_w         ;  
  wire   [`IME_MV_WIDTH              -1 :0]   fme_mv_data_1_w         ;  

  wire   [6                          -1 :0]   mv_mem_0_addr_w         ;
  wire   [1                          -1 :0]   mv_mem_0_wr_ena_w       ;
  wire   [`IME_MV_WIDTH              -1 :0]   mv_mem_0_wr_dat_w       ;
  wire   [1                          -1 :0]   mv_mem_0_rd_ena_w       ;
  wire   [`IME_MV_WIDTH              -1 :0]   mv_mem_0_rd_dat_w       ;
  wire   [6                          -1 :0]   mv_mem_1_addr_w         ;
  wire   [1                          -1 :0]   mv_mem_1_wr_ena_w       ;
  wire   [`IME_MV_WIDTH              -1 :0]   mv_mem_1_wr_dat_w       ;
  wire   [1                          -1 :0]   mv_mem_1_rd_ena_w       ;
  wire   [`IME_MV_WIDTH              -1 :0]   mv_mem_1_rd_dat_w       ;

  wire   [6                          -1 :0]   ctu_x_res_w             ;
  wire   [6                          -1 :0]   ctu_y_res_w             ;

  // ime_cur_if
  wire                                        ime_cur_ena_w           ;
  wire   [6                           -1 :0]  ime_cur_adr_x_w         ;
  wire   [6                           -1 :0]  ime_cur_adr_y_w         ;
  wire   [`IME_PIXEL_WIDTH*32         -1 :0]  ime_cur_dat_w           ;

  // ime_ref_if
  wire   [`IME_PIXEL_WIDTH*32         -1 :0]  ime_ref_hor_dat_w       ;

  ime_top u_ime_top(
    // global
    .clk                ( clk                     ),
    .rstn               ( rstn                    ),
    // cfg
    .cmd_num_i          ( ime_cmd_num_i           ),
    .cmd_dat_i          ( ime_cmd_dat_i           ),
    // status
    .downsample_o       ( ime_downsample_o        ),
    // ctr_if
    .start_i            ( ime_start_i             ),
    .qp_i               ( ime_qp_i                ),
    .ctu_x_all_i        ( sys_ctu_all_x_i         ),
    .ctu_y_all_i        ( sys_ctu_all_y_i         ),
    .ctu_x_res_i        ( ctu_x_res_w             ),
    .ctu_y_res_i        ( ctu_y_res_w             ),
    .ctu_x_cur_i        ( ime_ctu_x_i             ),
    .ctu_y_cur_i        ( ime_ctu_y_i             ),
    .done_o             ( ime_done_o              ),
    // ori_if
    .ori_ena_o          ( ime_cur_ena_w           ),
    .ori_adr_x_o        ( ime_cur_adr_x_w         ),
    .ori_adr_y_o        ( ime_cur_adr_y_w         ),
    .ori_dat_i          ( ime_cur_dat_w           ),
    // ref_if
    .ref_hor_ena_o      ( ime_ref_hor_ena_o       ),
    .ref_hor_adr_x_o    ( ime_ref_hor_adr_x_o     ),
    .ref_hor_adr_y_o    ( ime_ref_hor_adr_y_o     ),
    .ref_hor_dat_i      ( ime_ref_hor_dat_w       ),
    // parition
    .partition_o        ( ime_partition_o         ),
    // mv
    .mv_wr_ena_o        ( ime_mv_wr_ena_w         ), // high active
    .mv_wr_adr_o        ( ime_mv_wr_adr_w         ),
    .mv_wr_dat_o        ( ime_mv_wr_dat_w         )
  );

  assign  ctu_x_res_w = (15-ctu_x_res_i)<<2 ;
  assign  ctu_y_res_w = (15-ctu_y_res_i)<<2 ;

  assign  mv_mem_0_wr_ena_w  = sel_mod_2_i==0 ? (!ime_mv_wr_ena_w) : 1                     ;
  // assign  mv_mem_0_rd_ena_w  = sel_mod_2_i==0 ? 1                  : (!fme_mv_rden_i)      ;
  assign  mv_mem_0_addr_w    = sel_mod_2_i==0 ? ime_mv_wr_adr_w    : fme_mv_rdaddr_i       ;
  assign  mv_mem_0_wr_dat_w  = sel_mod_2_i==0 ? ime_mv_wr_dat_w    : 0                     ;

  assign  mv_mem_1_wr_ena_w  = sel_mod_2_i==0 ? 1                  : (!ime_mv_wr_ena_w)    ;
  // assign  mv_mem_1_rd_ena_w  = sel_mod_2_i==0 ? (!fme_mv_rden_i)   : 1                     ;
  assign  mv_mem_1_addr_w    = sel_mod_2_i==0 ? fme_mv_rdaddr_i    : ime_mv_wr_adr_w       ;
  assign  mv_mem_1_wr_dat_w  = sel_mod_2_i==0 ? 0                  : ime_mv_wr_dat_w       ;

  assign  fme_mv_data_o  = sel_mod_2_i==0 ? {mv_mem_1_rd_dat_w[`IME_MV_WIDTH-1], mv_mem_1_rd_dat_w[`IME_MV_WIDTH-1:`IME_MV_WIDTH_Y],2'b0, {2{mv_mem_1_rd_dat_w[`IME_MV_WIDTH_Y-1]}}, mv_mem_1_rd_dat_w[`IME_MV_WIDTH_Y-1:0], 2'b0}    
                                          : {mv_mem_0_rd_dat_w[`IME_MV_WIDTH-1], mv_mem_0_rd_dat_w[`IME_MV_WIDTH-1:`IME_MV_WIDTH_Y],2'b0, {2{mv_mem_0_rd_dat_w[`IME_MV_WIDTH_Y-1]}}, mv_mem_0_rd_dat_w[`IME_MV_WIDTH_Y-1:0], 2'b0}   ;

  ime_mv_ram_sp_64x13 u_mv_ram_0(
    // global
    .clk          ( clk               ),
    // address
    .adr_i        ( mv_mem_0_addr_w   ),
    // write
    .wr_ena_i     ( mv_mem_0_wr_ena_w ), // low active
    .wr_dat_i     ( mv_mem_0_wr_dat_w ),
    // read
    .rd_ena_i     ( 1'b0              ), // low active
    .rd_dat_o     ( mv_mem_0_rd_dat_w )
  );

  ime_mv_ram_sp_64x13 u_mv_ram_1(
    // global
    .clk          ( clk               ),
    // address
    .adr_i        ( mv_mem_1_addr_w   ),
    // write
    .wr_ena_i     ( mv_mem_1_wr_ena_w ), // low active
    .wr_dat_i     ( mv_mem_1_wr_dat_w ),
    // read
    .rd_ena_i     ( 1'b0              ), // low active
    .rd_dat_o     ( mv_mem_1_rd_dat_w )
  );

  // cur_dat

  assign ime_cur_4x4_x_o = ime_cur_adr_x_w[5]<<3 ;
  assign ime_cur_4x4_y_o = ime_cur_adr_y_w[5]<<3 ;
  assign ime_cur_4x4_idx_o = ime_cur_adr_y_w[4:0] ;
  assign ime_cur_sel_o = 0 ;
  assign ime_cur_size_o = 3'b011 ;
  assign ime_cur_rden_o = ime_cur_ena_w ;  

  assign ime_cur_dat_w[`IME_PIXEL_WIDTH* 1-1:`IME_PIXEL_WIDTH* 0] = ime_cur_pel_i[`PIXEL_WIDTH* 1-1:`PIXEL_WIDTH* 1-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH* 2-1:`IME_PIXEL_WIDTH* 1] = ime_cur_pel_i[`PIXEL_WIDTH* 2-1:`PIXEL_WIDTH* 2-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH* 3-1:`IME_PIXEL_WIDTH* 2] = ime_cur_pel_i[`PIXEL_WIDTH* 3-1:`PIXEL_WIDTH* 3-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH* 4-1:`IME_PIXEL_WIDTH* 3] = ime_cur_pel_i[`PIXEL_WIDTH* 4-1:`PIXEL_WIDTH* 4-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH* 5-1:`IME_PIXEL_WIDTH* 4] = ime_cur_pel_i[`PIXEL_WIDTH* 5-1:`PIXEL_WIDTH* 5-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH* 6-1:`IME_PIXEL_WIDTH* 5] = ime_cur_pel_i[`PIXEL_WIDTH* 6-1:`PIXEL_WIDTH* 6-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH* 7-1:`IME_PIXEL_WIDTH* 6] = ime_cur_pel_i[`PIXEL_WIDTH* 7-1:`PIXEL_WIDTH* 7-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH* 8-1:`IME_PIXEL_WIDTH* 7] = ime_cur_pel_i[`PIXEL_WIDTH* 8-1:`PIXEL_WIDTH* 8-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH* 9-1:`IME_PIXEL_WIDTH* 8] = ime_cur_pel_i[`PIXEL_WIDTH* 9-1:`PIXEL_WIDTH* 9-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*10-1:`IME_PIXEL_WIDTH* 9] = ime_cur_pel_i[`PIXEL_WIDTH*10-1:`PIXEL_WIDTH*10-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*11-1:`IME_PIXEL_WIDTH*10] = ime_cur_pel_i[`PIXEL_WIDTH*11-1:`PIXEL_WIDTH*11-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*12-1:`IME_PIXEL_WIDTH*11] = ime_cur_pel_i[`PIXEL_WIDTH*12-1:`PIXEL_WIDTH*12-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*13-1:`IME_PIXEL_WIDTH*12] = ime_cur_pel_i[`PIXEL_WIDTH*13-1:`PIXEL_WIDTH*13-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*14-1:`IME_PIXEL_WIDTH*13] = ime_cur_pel_i[`PIXEL_WIDTH*14-1:`PIXEL_WIDTH*14-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*15-1:`IME_PIXEL_WIDTH*14] = ime_cur_pel_i[`PIXEL_WIDTH*15-1:`PIXEL_WIDTH*15-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*16-1:`IME_PIXEL_WIDTH*15] = ime_cur_pel_i[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*16-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*17-1:`IME_PIXEL_WIDTH*16] = ime_cur_pel_i[`PIXEL_WIDTH*17-1:`PIXEL_WIDTH*17-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*18-1:`IME_PIXEL_WIDTH*17] = ime_cur_pel_i[`PIXEL_WIDTH*18-1:`PIXEL_WIDTH*18-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*19-1:`IME_PIXEL_WIDTH*18] = ime_cur_pel_i[`PIXEL_WIDTH*19-1:`PIXEL_WIDTH*19-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*20-1:`IME_PIXEL_WIDTH*19] = ime_cur_pel_i[`PIXEL_WIDTH*20-1:`PIXEL_WIDTH*20-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*21-1:`IME_PIXEL_WIDTH*20] = ime_cur_pel_i[`PIXEL_WIDTH*21-1:`PIXEL_WIDTH*21-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*22-1:`IME_PIXEL_WIDTH*21] = ime_cur_pel_i[`PIXEL_WIDTH*22-1:`PIXEL_WIDTH*22-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*23-1:`IME_PIXEL_WIDTH*22] = ime_cur_pel_i[`PIXEL_WIDTH*23-1:`PIXEL_WIDTH*23-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*24-1:`IME_PIXEL_WIDTH*23] = ime_cur_pel_i[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*24-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*25-1:`IME_PIXEL_WIDTH*24] = ime_cur_pel_i[`PIXEL_WIDTH*25-1:`PIXEL_WIDTH*25-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*26-1:`IME_PIXEL_WIDTH*25] = ime_cur_pel_i[`PIXEL_WIDTH*26-1:`PIXEL_WIDTH*26-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*27-1:`IME_PIXEL_WIDTH*26] = ime_cur_pel_i[`PIXEL_WIDTH*27-1:`PIXEL_WIDTH*27-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*28-1:`IME_PIXEL_WIDTH*27] = ime_cur_pel_i[`PIXEL_WIDTH*28-1:`PIXEL_WIDTH*28-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*29-1:`IME_PIXEL_WIDTH*28] = ime_cur_pel_i[`PIXEL_WIDTH*29-1:`PIXEL_WIDTH*29-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*30-1:`IME_PIXEL_WIDTH*29] = ime_cur_pel_i[`PIXEL_WIDTH*30-1:`PIXEL_WIDTH*30-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*31-1:`IME_PIXEL_WIDTH*30] = ime_cur_pel_i[`PIXEL_WIDTH*31-1:`PIXEL_WIDTH*31-`IME_PIXEL_WIDTH] ; 
  assign ime_cur_dat_w[`IME_PIXEL_WIDTH*32-1:`IME_PIXEL_WIDTH*31] = ime_cur_pel_i[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*32-`IME_PIXEL_WIDTH] ; // to be removed later when mem size is comfirmed

  // ref_dat
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH* 1-1:`IME_PIXEL_WIDTH* 0] = ime_ref_hor_dat_i[`PIXEL_WIDTH* 1-1:`PIXEL_WIDTH* 1-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH* 2-1:`IME_PIXEL_WIDTH* 1] = ime_ref_hor_dat_i[`PIXEL_WIDTH* 2-1:`PIXEL_WIDTH* 2-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH* 3-1:`IME_PIXEL_WIDTH* 2] = ime_ref_hor_dat_i[`PIXEL_WIDTH* 3-1:`PIXEL_WIDTH* 3-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH* 4-1:`IME_PIXEL_WIDTH* 3] = ime_ref_hor_dat_i[`PIXEL_WIDTH* 4-1:`PIXEL_WIDTH* 4-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH* 5-1:`IME_PIXEL_WIDTH* 4] = ime_ref_hor_dat_i[`PIXEL_WIDTH* 5-1:`PIXEL_WIDTH* 5-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH* 6-1:`IME_PIXEL_WIDTH* 5] = ime_ref_hor_dat_i[`PIXEL_WIDTH* 6-1:`PIXEL_WIDTH* 6-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH* 7-1:`IME_PIXEL_WIDTH* 6] = ime_ref_hor_dat_i[`PIXEL_WIDTH* 7-1:`PIXEL_WIDTH* 7-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH* 8-1:`IME_PIXEL_WIDTH* 7] = ime_ref_hor_dat_i[`PIXEL_WIDTH* 8-1:`PIXEL_WIDTH* 8-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH* 9-1:`IME_PIXEL_WIDTH* 8] = ime_ref_hor_dat_i[`PIXEL_WIDTH* 9-1:`PIXEL_WIDTH* 9-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*10-1:`IME_PIXEL_WIDTH* 9] = ime_ref_hor_dat_i[`PIXEL_WIDTH*10-1:`PIXEL_WIDTH*10-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*11-1:`IME_PIXEL_WIDTH*10] = ime_ref_hor_dat_i[`PIXEL_WIDTH*11-1:`PIXEL_WIDTH*11-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*12-1:`IME_PIXEL_WIDTH*11] = ime_ref_hor_dat_i[`PIXEL_WIDTH*12-1:`PIXEL_WIDTH*12-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*13-1:`IME_PIXEL_WIDTH*12] = ime_ref_hor_dat_i[`PIXEL_WIDTH*13-1:`PIXEL_WIDTH*13-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*14-1:`IME_PIXEL_WIDTH*13] = ime_ref_hor_dat_i[`PIXEL_WIDTH*14-1:`PIXEL_WIDTH*14-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*15-1:`IME_PIXEL_WIDTH*14] = ime_ref_hor_dat_i[`PIXEL_WIDTH*15-1:`PIXEL_WIDTH*15-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*16-1:`IME_PIXEL_WIDTH*15] = ime_ref_hor_dat_i[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*16-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*17-1:`IME_PIXEL_WIDTH*16] = ime_ref_hor_dat_i[`PIXEL_WIDTH*17-1:`PIXEL_WIDTH*17-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*18-1:`IME_PIXEL_WIDTH*17] = ime_ref_hor_dat_i[`PIXEL_WIDTH*18-1:`PIXEL_WIDTH*18-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*19-1:`IME_PIXEL_WIDTH*18] = ime_ref_hor_dat_i[`PIXEL_WIDTH*19-1:`PIXEL_WIDTH*19-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*20-1:`IME_PIXEL_WIDTH*19] = ime_ref_hor_dat_i[`PIXEL_WIDTH*20-1:`PIXEL_WIDTH*20-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*21-1:`IME_PIXEL_WIDTH*20] = ime_ref_hor_dat_i[`PIXEL_WIDTH*21-1:`PIXEL_WIDTH*21-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*22-1:`IME_PIXEL_WIDTH*21] = ime_ref_hor_dat_i[`PIXEL_WIDTH*22-1:`PIXEL_WIDTH*22-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*23-1:`IME_PIXEL_WIDTH*22] = ime_ref_hor_dat_i[`PIXEL_WIDTH*23-1:`PIXEL_WIDTH*23-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*24-1:`IME_PIXEL_WIDTH*23] = ime_ref_hor_dat_i[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*24-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*25-1:`IME_PIXEL_WIDTH*24] = ime_ref_hor_dat_i[`PIXEL_WIDTH*25-1:`PIXEL_WIDTH*25-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*26-1:`IME_PIXEL_WIDTH*25] = ime_ref_hor_dat_i[`PIXEL_WIDTH*26-1:`PIXEL_WIDTH*26-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*27-1:`IME_PIXEL_WIDTH*26] = ime_ref_hor_dat_i[`PIXEL_WIDTH*27-1:`PIXEL_WIDTH*27-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*28-1:`IME_PIXEL_WIDTH*27] = ime_ref_hor_dat_i[`PIXEL_WIDTH*28-1:`PIXEL_WIDTH*28-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*29-1:`IME_PIXEL_WIDTH*28] = ime_ref_hor_dat_i[`PIXEL_WIDTH*29-1:`PIXEL_WIDTH*29-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*30-1:`IME_PIXEL_WIDTH*29] = ime_ref_hor_dat_i[`PIXEL_WIDTH*30-1:`PIXEL_WIDTH*30-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*31-1:`IME_PIXEL_WIDTH*30] = ime_ref_hor_dat_i[`PIXEL_WIDTH*31-1:`PIXEL_WIDTH*31-`IME_PIXEL_WIDTH] ; 
  assign ime_ref_hor_dat_w[`IME_PIXEL_WIDTH*32-1:`IME_PIXEL_WIDTH*31] = ime_ref_hor_dat_i[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*32-`IME_PIXEL_WIDTH] ; // to be removed later when mem size is comfirmed

endmodule
