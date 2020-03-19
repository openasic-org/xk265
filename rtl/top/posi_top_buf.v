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
//  Filename      : posi_top_buf.v
//  Author        : TANG
//  Created       : 2018-04-20
//  Description   : posi top with memory buffer
//
//-------------------------------------------------------------------
`include "enc_defines.v"

module posi_top_buf(
  clk                   ,
  rstn                  ,
  sys_start_i           ,
  sys_posi4x4bit_i      ,
  // sys_if
  posi_start_i          ,
  posi_done_o           ,
  ctu_x_res_i           ,
  ctu_y_res_i           ,
  ctu_x_all_i           ,
  ctu_y_all_i           ,
  ctu_x_cur_i           ,
  ctu_y_cur_i           ,
  qp_i                  ,
  //md_rd_if
  posi_mod_rd_ena_o     ,
  posi_mod_rd_adr_o     ,
  posi_mod_rd_dat_i     ,
  //posi_cur_if
  posi_cur_rd_ena_o     ,
  posi_cur_rd_sel_o     ,
  posi_cur_rd_siz_o     ,
  posi_cur_rd_4x4_x_o   ,
  posi_cur_rd_4x4_y_o   ,
  posi_cur_rd_idx_o     ,
  posi_cur_rd_dat_i     ,
  // pt_o
  posi_partition_o      ,
  posi_cost_o           ,
  //ec_mode
  rec_md_rd_ena_i       ,
  rec_md_rd_adr_i       ,
  rec_md_rd_dat_o       ,
  //cabac_rd_mode
  ec_md_rd_ena_i        ,
  ec_md_rd_adr_i        ,
  ec_md_rd_dat_o        
);      


//*** INPUT/OUTPUT DECLARATION **************************************************************

  input                               clk                  ;
  input                               rstn                 ;
  input  [5-1:0]                      sys_posi4x4bit_i     ;
  // sys_if
  input                               posi_start_i         ;
  input                               sys_start_i          ; // for mode buffer rotation 
  output                              posi_done_o          ;
  input  [`PIC_X_WIDTH       -1 :0]   ctu_x_all_i          ;
  input  [`PIC_Y_WIDTH       -1 :0]   ctu_y_all_i          ;
  input  [4                  -1 :0]   ctu_x_res_i          ;
  input  [4                  -1 :0]   ctu_y_res_i          ;
  input  [`PIC_X_WIDTH       -1 :0]   ctu_x_cur_i          ;
  input  [`PIC_Y_WIDTH       -1 :0]   ctu_y_cur_i          ;
  input  [6-1:0]                      qp_i                 ;
  //md_rd_if
  output                              posi_mod_rd_ena_o    ;
  output [9                  -1 :0]   posi_mod_rd_adr_o    ;
  input  [6                  -1 :0]   posi_mod_rd_dat_i    ;
  //posi_cur_if
  output                              posi_cur_rd_ena_o    ;
  output [2                  -1 :0]   posi_cur_rd_sel_o    ;
  output [2                  -1 :0]   posi_cur_rd_siz_o    ;
  output [4                  -1 :0]   posi_cur_rd_4x4_x_o  ;
  output [4                  -1 :0]   posi_cur_rd_4x4_y_o  ;
  output [5                  -1 :0]   posi_cur_rd_idx_o    ;
  input  [`PIXEL_WIDTH*32    -1 :0]   posi_cur_rd_dat_i    ;
  // pt_o
  output [85                 -1 :0]   posi_partition_o     ;
  //ec_mode
  input                               rec_md_rd_ena_i      ;
  input  [8                  -1 :0]   rec_md_rd_adr_i      ;
  output [6                  -1 :0]   rec_md_rd_dat_o      ;
  //cabac_rd_mode
  input                               ec_md_rd_ena_i       ;
  input  [6                  -1 :0]   ec_md_rd_adr_i       ;
  output [6                  -1 :0]   ec_md_rd_dat_o       ;
  // cost output
  output [`POSI_COST_WIDTH   -1 :0]   posi_cost_o          ;

//*** WIRE/REG DECLARATION **************************************************************
  reg                                 md_we_0              ;
  reg    [6                  -1 :0]   md_addr_i_0          ;
  reg    [6                  -1 :0]   md_data_i_0          ;

  reg                                 md_we_1              ;
  reg    [6                  -1 :0]   md_addr_i_1          ;
  reg    [6                  -1 :0]   md_data_i_1          ;

  reg                                 md_we_2              ;
  reg    [6                  -1 :0]   md_addr_i_2          ;
  reg    [6                  -1 :0]   md_data_i_2          ;

  reg                                 md_we_3              ;
  reg    [6                  -1 :0]   md_addr_i_3          ;
  reg    [6                  -1 :0]   md_data_i_3          ;

  reg    [6                  -1 :0]   rec_md_rd_dat_o      ;
  reg    [6                  -1 :0]   ec_md_rd_dat_o       ;

  wire   [6                  -1 :0]   md_data_o_0          ;      
  wire   [6                  -1 :0]   md_data_o_1          ;      
  wire   [6                  -1 :0]   md_data_o_2          ;   
  wire   [6                  -1 :0]   md_data_o_3          ; 

  wire                                posi_mod_wr_ena_o    ;
  wire   [8                  -1 :0]   posi_mod_wr_adr_o    ;
  wire   [6                  -1 :0]   posi_mod_wr_dat_o    ; 

  reg    [2                  -1 :0]   sel_mode_4_r         ;

  posi_top u_posi_top(
    // global
    .clk               ( clk                    ),
    .rstn              ( rstn                   ),
    .sys_posi4x4bit_i  ( sys_posi4x4bit_i       ),
    // ctrl_if
    .qp_i              ( qp_i                   ),
    .start_i           ( posi_start_i           ),
    .done_o            ( posi_done_o            ),
    // cfg_i
    .num_mode_i        ( 3'd0                   ),
    .ctu_x_all_i       ( ctu_x_all_i            ),
    .ctu_y_all_i       ( ctu_y_all_i            ),
    .ctu_x_res_i       ( ctu_x_res_i            ),
    .ctu_y_res_i       ( ctu_y_res_i            ),
    .ctu_x_cur_i       ( ctu_x_cur_i            ),
    .ctu_y_cur_i       ( ctu_y_cur_i            ),
    // md_if (rd)
    .mod_rd_ena_o      ( posi_mod_rd_ena_o      ),
    .mod_rd_adr_o      ( posi_mod_rd_adr_o      ),
    .mod_rd_dat_i      ( posi_mod_rd_dat_i      ),
    // cur_if (rd)
    .ori_rd_ena_o      ( posi_cur_rd_ena_o      ),
    .ori_rd_sel_o      ( posi_cur_rd_sel_o      ),
    .ori_rd_siz_o      ( posi_cur_rd_siz_o      ),
    .ori_rd_4x4_x_o    ( posi_cur_rd_4x4_x_o    ),
    .ori_rd_4x4_y_o    ( posi_cur_rd_4x4_y_o    ),
    .ori_rd_idx_o      ( posi_cur_rd_idx_o      ),
    .ori_rd_dat_i      ( posi_cur_rd_dat_i      ),
    // md_if (wr)
    .mod_wr_ena_o      ( posi_mod_wr_ena_o      ),
    .mod_wr_adr_o      ( posi_mod_wr_adr_o      ),
    .mod_wr_dat_o      ( posi_mod_wr_dat_o      ),
    // pt_o
    .partition_o       ( posi_partition_o       ),
    .cost_o            ( posi_cost_o            )
    );

  // rotate count
  always @ ( posedge clk or negedge rstn ) begin 
    if ( !rstn ) 
      sel_mode_4_r <= 0 ;
    else if ( sys_start_i == 1 )
      sel_mode_4_r <= sel_mode_4_r + 1 ;
  end 

  // md_mem
  /*
  mod_4  | 0         1           2           3        
  ram0   | wr        rec         blank       ec   
  ram1   | ec        wr          rec         blank  
  ram2   | blank     ec          wr          rec  
  ram3   | rec       blank       ec          wr       
  */
  always @(*) begin
                   md_addr_i_0  = 0 ;
                   md_we_0      = 1 ;
                   md_data_i_0  = 0 ;
    case( sel_mode_4_r )
      0 : begin    md_addr_i_0  = (posi_mod_wr_adr_o>>2) ;
                   md_we_0      = (!posi_mod_wr_ena_o)   ;
                   md_data_i_0  = posi_mod_wr_dat_o      ;
          end
      1 : begin    md_addr_i_0  = (rec_md_rd_adr_i>>2)   ;
          end
      3 : begin    md_addr_i_0  = ec_md_rd_adr_i   ;
          end
    endcase
  end

  always @(*) begin
                   md_addr_i_1  = 0 ;
                   md_we_1      = 1 ;
                   md_data_i_1  = 0 ;
    case( sel_mode_4_r )
      1 : begin    md_addr_i_1  = (posi_mod_wr_adr_o>>2) ;
                   md_we_1      = (!posi_mod_wr_ena_o)   ;
                   md_data_i_1  = posi_mod_wr_dat_o      ;
          end
      2 : begin    md_addr_i_1  = (rec_md_rd_adr_i>>2)   ;
          end
      0 : begin    md_addr_i_1  = ec_md_rd_adr_i   ;
          end
    endcase
  end

  always @(*) begin
                   md_addr_i_2  = 0 ;
                   md_we_2      = 1 ;
                   md_data_i_2  = 0 ;
    case( sel_mode_4_r )
      2 : begin    md_addr_i_2  = (posi_mod_wr_adr_o>>2) ;
                   md_we_2      = (!posi_mod_wr_ena_o)   ;
                   md_data_i_2  = posi_mod_wr_dat_o      ;
          end
      3 : begin    md_addr_i_2  = (rec_md_rd_adr_i>>2)   ;
          end
      1 : begin    md_addr_i_2  = ec_md_rd_adr_i   ;
          end
    endcase
  end

  always @(*) begin
                   md_addr_i_3  = 0 ;
                   md_we_3      = 1 ;
                   md_data_i_3  = 0 ;
    case( sel_mode_4_r )
      3 : begin    md_addr_i_3  = (posi_mod_wr_adr_o>>2) ;
                   md_we_3      = (!posi_mod_wr_ena_o)   ;
                   md_data_i_3  = posi_mod_wr_dat_o      ;
          end
      0 : begin    md_addr_i_3  = (rec_md_rd_adr_i>>2)   ;
          end
      2 : begin    md_addr_i_3  = ec_md_rd_adr_i   ;
          end
    endcase
  end
  /*
  mod_4  | 0         1           2           3        
  ram0   | wr        rec         blank       ec   
  ram1   | ec        wr          rec         blank  
  ram2   | blank     ec          wr          rec  
  ram3   | rec       blank       ec          wr       
  */
  always @(*) begin
          rec_md_rd_dat_o = 0 ;
    case( sel_mode_4_r )
      1 : rec_md_rd_dat_o = md_data_o_0 ;
      2 : rec_md_rd_dat_o = md_data_o_1 ;
      3 : rec_md_rd_dat_o = md_data_o_2 ;
      0 : rec_md_rd_dat_o = md_data_o_3 ;
    endcase
  end

  always @(*) begin
          ec_md_rd_dat_o = 0 ;
    case( sel_mode_4_r )
      3 : ec_md_rd_dat_o = md_data_o_0;
      0 : ec_md_rd_dat_o = md_data_o_1;
      1 : ec_md_rd_dat_o = md_data_o_2;
      2 : ec_md_rd_dat_o = md_data_o_3;
    endcase
  end

  posi_md_ram_sp_64x6 u_imode_buf_0(
    .clk              ( clk               ),
    .adr_i            ( md_addr_i_0       ),
    .wr_ena_i         ( md_we_0           ), // low active
    .wr_dat_i         ( md_data_i_0       ),
    .rd_ena_i         ( 1'b0              ), // low active
    .rd_dat_o         ( md_data_o_0       )
    );


  posi_md_ram_sp_64x6 u_imode_buf_1(
    .clk              ( clk               ),
    .adr_i            ( md_addr_i_1       ),
    .wr_ena_i         ( md_we_1           ), // low active
    .wr_dat_i         ( md_data_i_1       ),
    .rd_ena_i         ( 1'b0              ), // low active
    .rd_dat_o         ( md_data_o_1       )
    );

  posi_md_ram_sp_64x6 u_imode_buf_2(
    .clk              ( clk               ),
    .adr_i            ( md_addr_i_2       ),
    .wr_ena_i         ( md_we_2           ), // low active
    .wr_dat_i         ( md_data_i_2       ),
    .rd_ena_i         ( 1'b0              ), // low active
    .rd_dat_o         ( md_data_o_2       )
    );

  posi_md_ram_sp_64x6 u_imode_buf_3(
    .clk              ( clk               ),
    .adr_i            ( md_addr_i_3       ),
    .wr_ena_i         ( md_we_3           ), // low active
    .wr_dat_i         ( md_data_i_3       ),
    .rd_ena_i         ( 1'b0              ), // low active
    .rd_dat_o         ( md_data_o_3       )
    );

endmodule 