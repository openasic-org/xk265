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
`include "enc_defines.v"


module prei_top_buf(
    // SYS_IF
    clk                 ,
    rstn                ,
    prei_start_i        ,
    prei_done_o         ,
    sel_mod_2_i         ,
    // PREI_CUR_IF
    prei_cur_ren_o      ,
    prei_cur_sel_o      ,
    prei_cur_size_o     ,
    prei_cur_4x4_x_o    ,
    prei_cur_4x4_y_o    ,
    prei_cur_idx_o      ,
    prei_cur_data_i     ,
    // RC_IF
    rc_actual_bitnum_i  ,
    rc_qp_o             ,
    rc_mod64_sum_o      ,
    rc_ctu_x_i          ,
    rc_ctu_y_i          ,
    // RC_REG_IF
    rc_k                ,
    rc_bitnum_i         ,
    rc_roi_height       ,
    rc_roi_width        ,
    rc_roi_x            ,
    rc_roi_y            ,
    rc_roi_enable       ,
    rc_L1_frame_byte    ,
    rc_L2_frame_byte    ,
    rc_lcu_en           ,
    rc_initial_qp       ,
    rc_max_qp           ,
    rc_min_qp           ,
    rc_delta_qp         , 
    // POSI_MODE_RD_IF
    posi_md_ena_i       ,
    posi_md_addr_i      ,
    posi_md_data_o      
);

//**** INPUT/OUTPUT DECLARATION ******************************************

  // SYS_IF
  input                                clk                 ;
  input                                rstn                ;
  input                                prei_start_i        ;
  output                               prei_done_o         ;
  input   [1                  -1:0]    sel_mod_2_i         ;
  // PREI_CUR_IF    
  output                               prei_cur_ren_o      ;
  output  [1                    :0]    prei_cur_sel_o      ;
  output  [1                    :0]    prei_cur_size_o     ;
  output  [3                    :0]    prei_cur_4x4_x_o    ;
  output  [3                    :0]    prei_cur_4x4_y_o    ;
  output  [4                    :0]    prei_cur_idx_o      ;
  input   [255                  :0]    prei_cur_data_i     ;
  // RC_IF    
  input   [15:0]                       rc_actual_bitnum_i  ;
  output  [5:0]                        rc_qp_o             ;
  output  [31:0]                       rc_mod64_sum_o      ;
  input   [`PIC_X_WIDTH      -1 :0]    rc_ctu_x_i          ;
  input   [`PIC_Y_WIDTH      -1 :0]    rc_ctu_y_i          ;
  // RC_REG_IF
  input   [15                   :0]    rc_k                ;
  input   [31                   :0]    rc_bitnum_i         ;
  input   [5                    :0]    rc_roi_height       ;
  input   [6                    :0]    rc_roi_width        ;
  input   [6                    :0]    rc_roi_x            ;
  input   [6                    :0]    rc_roi_y            ;
  input                                rc_roi_enable       ;
  input   [9                    :0]    rc_L1_frame_byte    ;
  input   [9                    :0]    rc_L2_frame_byte    ;
  input                                rc_lcu_en           ;
  input   [5                    :0]    rc_initial_qp       ;
  input   [5                    :0]    rc_max_qp           ;
  input   [5                    :0]    rc_min_qp           ;
  input   [5                    :0]    rc_delta_qp         ;
  // POSI_MODE_RD_IF                 
  input                                posi_md_ena_i       ;
  input   [8                    :0]    posi_md_addr_i      ;
  output  [5                    :0]    posi_md_data_o      ;    

//**** WIRE/REG DECLARATION ******************************************
  wire                                 prei_md_we_w        ;
  wire                                 prei_cur_sel_w      ;
  wire    [6                   : 0]    prei_md_waddr_w     ;
  wire    [5                   : 0]    prei_md_wdata_w     ;

  wire                                 md_we_0             ;
  wire                                 md_rd_ena_0         ;
  wire    [6                   : 0]    md_addr_i_0         ;
  wire    [5                   : 0]    md_data_i_0         ;

  wire                                 md_we_1             ;
  wire                                 md_rd_ena_1         ;
  wire    [6                   : 0]    md_addr_i_1         ;
  wire    [5                   : 0]    md_data_i_1         ;
//---- pos_i_rd_if -------------------------------------------------
  wire    [5                   : 0]    posi_md_data_0      ;
  wire    [5                   : 0]    posi_md_data_1      ;

//**** DUT ******************************************
  reg     [7                 -1 :0]    posi_md_rd_adr_w    ;

  always @(*) begin
    if( posi_md_addr_i<84 ) begin
      posi_md_rd_adr_w = posi_md_addr_i + 1 ;
    end
    else begin
      posi_md_rd_adr_w = 21 + (posi_md_addr_i-84)/4 ;
    end
  end

  assign prei_cur_sel_o = {1'b0, prei_cur_sel_w};

  prei_top u_prei_top(
    .clk                 ( clk                   ),
    .rstn                ( rstn                  ),
                 
    .md_ren_o            ( prei_cur_ren_o        ),
    .md_sel_o            ( prei_cur_sel_w        ),
    .md_size_o           ( prei_cur_size_o       ),
    .md_4x4_x_o          ( prei_cur_4x4_x_o      ),
    .md_4x4_y_o          ( prei_cur_4x4_y_o      ),
    .md_idx_o            ( prei_cur_idx_o        ),
    .md_data_i           ( prei_cur_data_i       ),
  
    .md_we               ( prei_md_we_w          ),
    .md_waddr            ( prei_md_waddr_w       ),
    .md_wdata            ( prei_md_wdata_w       ),
    
    .actual_bitnum_i     ( rc_actual_bitnum_i    ),
    .rc_qp_o             ( rc_qp_o               ),
    .mod64_sum_o         ( rc_mod64_sum_o        ),
    .rc_ctu_x_i          ( rc_ctu_x_i            ),
    .rc_ctu_y_i          ( rc_ctu_y_i            ),
    
    .reg_k               ( rc_k                  ),
    .reg_bitnum_i        ( rc_bitnum_i           ),
    .reg_ROI_height      ( rc_roi_height         ),
    .reg_ROI_width       ( rc_roi_width          ),
    .reg_ROI_x           ( rc_roi_x              ),
    .reg_ROI_y           ( rc_roi_y              ),
    .reg_ROI_enable      ( rc_roi_enable         ),
    .reg_L1_frame_byte   ( rc_L1_frame_byte      ),
    .reg_L2_frame_byte   ( rc_L2_frame_byte      ),
    .reg_lcu_rc_en       ( rc_lcu_en             ),
    .reg_initial_qp      ( rc_initial_qp         ),
    .reg_max_qp          ( rc_max_qp             ),
    .reg_min_qp          ( rc_min_qp             ),
    .reg_delta_qp        ( rc_delta_qp           ),
    
    .prei_start          ( prei_start_i          ),
    .prei_done           ( prei_done_o           )
  );

  assign  md_we_0         = sel_mod_2_i==0 ? (!prei_md_we_w)   : 1                     ;
  assign  md_rd_ena_0     = sel_mod_2_i==0 ? 1                 : (!posi_md_ena_i)      ;
  assign  md_addr_i_0     = sel_mod_2_i==0 ? prei_md_waddr_w   : posi_md_rd_adr_w      ;
  assign  md_data_i_0     = sel_mod_2_i==0 ? prei_md_wdata_w   : 0                     ;

  assign  md_we_1         = sel_mod_2_i==0 ? 1                 : (!prei_md_we_w)       ;
  assign  md_rd_ena_1     = sel_mod_2_i==0 ? (!posi_md_ena_i)  : 1                     ;
  assign  md_addr_i_1     = sel_mod_2_i==0 ? posi_md_rd_adr_w  : prei_md_waddr_w       ;
  assign  md_data_i_1     = sel_mod_2_i==0 ? 0                 : prei_md_wdata_w       ;

  assign  posi_md_data_o  = sel_mod_2_i==0 ? posi_md_data_1    : posi_md_data_0        ;


  prei_md_ram_sp_85x6 u_imode_buf_0(
    .clk              ( clk               ),
    .adr_i            ( md_addr_i_0       ),
    .wr_ena_i         ( md_we_0           ), // low active
    .wr_dat_i         ( md_data_i_0       ),
    .rd_ena_i         ( md_rd_ena_0       ), // low active
    .rd_dat_o         ( posi_md_data_0    )
    );

  prei_md_ram_sp_85x6 u_imode_buf_1(
    .clk              ( clk               ),
    .adr_i            ( md_addr_i_1       ),
    .wr_ena_i         ( md_we_1           ), // low active
    .wr_dat_i         ( md_data_i_1       ),
    .rd_ena_i         ( md_rd_ena_1       ), // low active
    .rd_dat_o         ( posi_md_data_1    )
    );

endmodule 