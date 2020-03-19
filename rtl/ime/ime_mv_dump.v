//--------------------------------------------------------------------
//
//  Filename    : ime_mv_dump.v
//  Author      : Huang Leilei
//  Created     : 2018-05-05
//  Description : mv dump in ime module (auto generated)
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module ime_mv_dump(
  // global
  clk                 ,
  rstn                ,
  // ctrl
  start_i             ,
  done_o              ,
  // input
  dat_partition_i     ,
  dat_08_mv_0_i       ,
  dat_16_mv_0_i       ,
  dat_16_mv_1_i       ,
  dat_16_mv_2_i       ,
  dat_32_mv_0_i       ,
  dat_32_mv_1_i       ,
  dat_32_mv_2_i       ,
  dat_64_mv_0_i       ,
  dat_64_mv_1_i       ,
  dat_64_mv_2_i       ,
  // output
  mv_wr_ena_o         ,
  mv_wr_adr_o         ,
  mv_wr_dat_o
  );


//*** PARAMETER ****************************************************************

  parameter FSM_WD                      = 1                      ;
  parameter    IDLE                     = 1'd0                   ;
  parameter    BUSY                     = 1'd1                   ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                 clk                      ;
  input                                 rstn                     ;
  // ctrl
  input                                 start_i                  ;
  output reg                            done_o                   ;
  // input
  input      [42              -1 :0]    dat_partition_i          ;
  input      [`IME_MV_WIDTH*64-1 :0]    dat_08_mv_0_i            ;
  input      [`IME_MV_WIDTH*16-1 :0]    dat_16_mv_0_i            ;
  input      [`IME_MV_WIDTH*32-1 :0]    dat_16_mv_1_i            ;
  input      [`IME_MV_WIDTH*32-1 :0]    dat_16_mv_2_i            ;
  input      [`IME_MV_WIDTH*4 -1 :0]    dat_32_mv_0_i            ;
  input      [`IME_MV_WIDTH*8 -1 :0]    dat_32_mv_1_i            ;
  input      [`IME_MV_WIDTH*8 -1 :0]    dat_32_mv_2_i            ;
  input      [`IME_MV_WIDTH*1 -1 :0]    dat_64_mv_0_i            ;
  input      [`IME_MV_WIDTH*2 -1 :0]    dat_64_mv_1_i            ;
  input      [`IME_MV_WIDTH*2 -1 :0]    dat_64_mv_2_i            ;
  // output
  output reg                            mv_wr_ena_o              ;
  output reg [6               -1 :0]    mv_wr_adr_o              ;
  output reg [`IME_MV_WIDTH   -1 :0]    mv_wr_dat_o              ;


//*** REG/WIRE *****************************************************************

  // input mv layer 3
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_00_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_00_08_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_00_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_00_24_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_00_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_00_40_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_00_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_00_56_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_08_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_08_08_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_08_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_08_24_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_08_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_08_40_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_08_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_08_56_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_16_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_16_08_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_16_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_16_24_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_16_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_16_40_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_16_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_16_56_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_24_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_24_08_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_24_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_24_24_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_24_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_24_40_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_24_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_24_56_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_32_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_32_08_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_32_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_32_24_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_32_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_32_40_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_32_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_32_56_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_40_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_40_08_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_40_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_40_24_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_40_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_40_40_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_40_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_40_56_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_48_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_48_08_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_48_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_48_24_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_48_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_48_40_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_48_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_48_56_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_56_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_56_08_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_56_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_56_24_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_56_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_56_40_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_56_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_08_mv_0_i_56_56_w    ;
  // input mv layer 4
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_00_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_00_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_08_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_00_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_00_08_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_00_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_00_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_08_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_00_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_00_24_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_00_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_00_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_08_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_00_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_00_40_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_00_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_00_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_08_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_00_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_00_56_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_16_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_16_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_24_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_16_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_16_08_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_16_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_16_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_24_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_16_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_16_24_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_16_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_16_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_24_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_16_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_16_40_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_16_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_16_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_24_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_16_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_16_56_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_32_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_32_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_40_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_32_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_32_08_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_32_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_32_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_40_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_32_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_32_24_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_32_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_32_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_40_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_32_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_32_40_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_32_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_32_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_40_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_32_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_32_56_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_48_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_48_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_56_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_48_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_48_08_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_48_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_48_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_56_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_48_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_48_24_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_48_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_48_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_56_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_48_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_48_40_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_0_i_48_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_48_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_1_i_56_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_48_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_16_mv_2_i_48_56_w    ;
  // input mv layer 5
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_0_i_00_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_1_i_00_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_1_i_16_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_2_i_00_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_2_i_00_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_0_i_00_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_1_i_00_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_1_i_16_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_2_i_00_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_2_i_00_48_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_0_i_32_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_1_i_32_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_1_i_48_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_2_i_32_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_2_i_32_16_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_0_i_32_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_1_i_32_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_1_i_48_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_2_i_32_32_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_32_mv_2_i_32_48_w    ;
  // input mv layer 6
  wire       [`IME_MV_WIDTH   -1 :0]    dat_64_mv_0_i_00_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_64_mv_1_i_00_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_64_mv_1_i_32_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_64_mv_2_i_00_00_w    ;
  wire       [`IME_MV_WIDTH   -1 :0]    dat_64_mv_2_i_00_32_w    ;

  // fsm
  reg        [FSM_WD          -1 :0]    cur_state_r              ;
  reg        [FSM_WD          -1 :0]    nxt_state_w              ;
  wire                                  busy_done_w              ;

  reg        [6               -1 :0]    cnt_dump_r               ;
  reg        [6               -1 :0]    mv_wr_adr_r              ;

  // output
  reg                                   mv_wr_ena_r              ;
  reg        [6               -1 :0]    mv_wr_prt_r              ;
  reg        [`IME_MV_WIDTH   -1 :0]    mv_wr_dat_08_0_r         ;
  reg        [`IME_MV_WIDTH   -1 :0]    mv_wr_dat_16_0_r         ;
  reg        [`IME_MV_WIDTH   -1 :0]    mv_wr_dat_16_1_r         ;
  reg        [`IME_MV_WIDTH   -1 :0]    mv_wr_dat_16_2_r         ;
  reg        [`IME_MV_WIDTH   -1 :0]    mv_wr_dat_32_0_r         ;
  reg        [`IME_MV_WIDTH   -1 :0]    mv_wr_dat_32_1_r         ;
  reg        [`IME_MV_WIDTH   -1 :0]    mv_wr_dat_32_2_r         ;
  reg        [`IME_MV_WIDTH   -1 :0]    mv_wr_dat_64_0_r         ;
  reg        [`IME_MV_WIDTH   -1 :0]    mv_wr_dat_64_1_r         ;
  reg        [`IME_MV_WIDTH   -1 :0]    mv_wr_dat_64_2_r         ;


//*** MAIN BODY ****************************************************************

//--- WIRE ASSIGNMENT ------------------
  // input mv layer 3
  assign { dat_08_mv_0_i_00_00_w
          ,dat_08_mv_0_i_00_08_w
          ,dat_08_mv_0_i_00_16_w
          ,dat_08_mv_0_i_00_24_w
          ,dat_08_mv_0_i_00_32_w
          ,dat_08_mv_0_i_00_40_w
          ,dat_08_mv_0_i_00_48_w
          ,dat_08_mv_0_i_00_56_w
          ,dat_08_mv_0_i_08_00_w
          ,dat_08_mv_0_i_08_08_w
          ,dat_08_mv_0_i_08_16_w
          ,dat_08_mv_0_i_08_24_w
          ,dat_08_mv_0_i_08_32_w
          ,dat_08_mv_0_i_08_40_w
          ,dat_08_mv_0_i_08_48_w
          ,dat_08_mv_0_i_08_56_w
          ,dat_08_mv_0_i_16_00_w
          ,dat_08_mv_0_i_16_08_w
          ,dat_08_mv_0_i_16_16_w
          ,dat_08_mv_0_i_16_24_w
          ,dat_08_mv_0_i_16_32_w
          ,dat_08_mv_0_i_16_40_w
          ,dat_08_mv_0_i_16_48_w
          ,dat_08_mv_0_i_16_56_w
          ,dat_08_mv_0_i_24_00_w
          ,dat_08_mv_0_i_24_08_w
          ,dat_08_mv_0_i_24_16_w
          ,dat_08_mv_0_i_24_24_w
          ,dat_08_mv_0_i_24_32_w
          ,dat_08_mv_0_i_24_40_w
          ,dat_08_mv_0_i_24_48_w
          ,dat_08_mv_0_i_24_56_w
          ,dat_08_mv_0_i_32_00_w
          ,dat_08_mv_0_i_32_08_w
          ,dat_08_mv_0_i_32_16_w
          ,dat_08_mv_0_i_32_24_w
          ,dat_08_mv_0_i_32_32_w
          ,dat_08_mv_0_i_32_40_w
          ,dat_08_mv_0_i_32_48_w
          ,dat_08_mv_0_i_32_56_w
          ,dat_08_mv_0_i_40_00_w
          ,dat_08_mv_0_i_40_08_w
          ,dat_08_mv_0_i_40_16_w
          ,dat_08_mv_0_i_40_24_w
          ,dat_08_mv_0_i_40_32_w
          ,dat_08_mv_0_i_40_40_w
          ,dat_08_mv_0_i_40_48_w
          ,dat_08_mv_0_i_40_56_w
          ,dat_08_mv_0_i_48_00_w
          ,dat_08_mv_0_i_48_08_w
          ,dat_08_mv_0_i_48_16_w
          ,dat_08_mv_0_i_48_24_w
          ,dat_08_mv_0_i_48_32_w
          ,dat_08_mv_0_i_48_40_w
          ,dat_08_mv_0_i_48_48_w
          ,dat_08_mv_0_i_48_56_w
          ,dat_08_mv_0_i_56_00_w
          ,dat_08_mv_0_i_56_08_w
          ,dat_08_mv_0_i_56_16_w
          ,dat_08_mv_0_i_56_24_w
          ,dat_08_mv_0_i_56_32_w
          ,dat_08_mv_0_i_56_40_w
          ,dat_08_mv_0_i_56_48_w
          ,dat_08_mv_0_i_56_56_w
         } = dat_08_mv_0_i ;

  // input mv layer 4
  assign { dat_16_mv_0_i_00_00_w
          ,dat_16_mv_0_i_00_16_w
          ,dat_16_mv_0_i_00_32_w
          ,dat_16_mv_0_i_00_48_w
          ,dat_16_mv_0_i_16_00_w
          ,dat_16_mv_0_i_16_16_w
          ,dat_16_mv_0_i_16_32_w
          ,dat_16_mv_0_i_16_48_w
          ,dat_16_mv_0_i_32_00_w
          ,dat_16_mv_0_i_32_16_w
          ,dat_16_mv_0_i_32_32_w
          ,dat_16_mv_0_i_32_48_w
          ,dat_16_mv_0_i_48_00_w
          ,dat_16_mv_0_i_48_16_w
          ,dat_16_mv_0_i_48_32_w
          ,dat_16_mv_0_i_48_48_w
         } = dat_16_mv_0_i ;
  assign { dat_16_mv_1_i_00_00_w
          ,dat_16_mv_1_i_08_00_w
          ,dat_16_mv_1_i_00_16_w
          ,dat_16_mv_1_i_08_16_w
          ,dat_16_mv_1_i_00_32_w
          ,dat_16_mv_1_i_08_32_w
          ,dat_16_mv_1_i_00_48_w
          ,dat_16_mv_1_i_08_48_w
          ,dat_16_mv_1_i_16_00_w
          ,dat_16_mv_1_i_24_00_w
          ,dat_16_mv_1_i_16_16_w
          ,dat_16_mv_1_i_24_16_w
          ,dat_16_mv_1_i_16_32_w
          ,dat_16_mv_1_i_24_32_w
          ,dat_16_mv_1_i_16_48_w
          ,dat_16_mv_1_i_24_48_w
          ,dat_16_mv_1_i_32_00_w
          ,dat_16_mv_1_i_40_00_w
          ,dat_16_mv_1_i_32_16_w
          ,dat_16_mv_1_i_40_16_w
          ,dat_16_mv_1_i_32_32_w
          ,dat_16_mv_1_i_40_32_w
          ,dat_16_mv_1_i_32_48_w
          ,dat_16_mv_1_i_40_48_w
          ,dat_16_mv_1_i_48_00_w
          ,dat_16_mv_1_i_56_00_w
          ,dat_16_mv_1_i_48_16_w
          ,dat_16_mv_1_i_56_16_w
          ,dat_16_mv_1_i_48_32_w
          ,dat_16_mv_1_i_56_32_w
          ,dat_16_mv_1_i_48_48_w
          ,dat_16_mv_1_i_56_48_w
         } = dat_16_mv_1_i ;
  assign { dat_16_mv_2_i_00_00_w
          ,dat_16_mv_2_i_00_08_w
          ,dat_16_mv_2_i_00_16_w
          ,dat_16_mv_2_i_00_24_w
          ,dat_16_mv_2_i_00_32_w
          ,dat_16_mv_2_i_00_40_w
          ,dat_16_mv_2_i_00_48_w
          ,dat_16_mv_2_i_00_56_w
          ,dat_16_mv_2_i_16_00_w
          ,dat_16_mv_2_i_16_08_w
          ,dat_16_mv_2_i_16_16_w
          ,dat_16_mv_2_i_16_24_w
          ,dat_16_mv_2_i_16_32_w
          ,dat_16_mv_2_i_16_40_w
          ,dat_16_mv_2_i_16_48_w
          ,dat_16_mv_2_i_16_56_w
          ,dat_16_mv_2_i_32_00_w
          ,dat_16_mv_2_i_32_08_w
          ,dat_16_mv_2_i_32_16_w
          ,dat_16_mv_2_i_32_24_w
          ,dat_16_mv_2_i_32_32_w
          ,dat_16_mv_2_i_32_40_w
          ,dat_16_mv_2_i_32_48_w
          ,dat_16_mv_2_i_32_56_w
          ,dat_16_mv_2_i_48_00_w
          ,dat_16_mv_2_i_48_08_w
          ,dat_16_mv_2_i_48_16_w
          ,dat_16_mv_2_i_48_24_w
          ,dat_16_mv_2_i_48_32_w
          ,dat_16_mv_2_i_48_40_w
          ,dat_16_mv_2_i_48_48_w
          ,dat_16_mv_2_i_48_56_w
         } = dat_16_mv_2_i ;

  // input mv layer 5
  assign { dat_32_mv_0_i_00_00_w
          ,dat_32_mv_0_i_00_32_w
          ,dat_32_mv_0_i_32_00_w
          ,dat_32_mv_0_i_32_32_w
         } = dat_32_mv_0_i ;
  assign { dat_32_mv_1_i_00_00_w
          ,dat_32_mv_1_i_16_00_w
          ,dat_32_mv_1_i_00_32_w
          ,dat_32_mv_1_i_16_32_w
          ,dat_32_mv_1_i_32_00_w
          ,dat_32_mv_1_i_48_00_w
          ,dat_32_mv_1_i_32_32_w
          ,dat_32_mv_1_i_48_32_w
         } = dat_32_mv_1_i ;
  assign { dat_32_mv_2_i_00_00_w
          ,dat_32_mv_2_i_00_16_w
          ,dat_32_mv_2_i_00_32_w
          ,dat_32_mv_2_i_00_48_w
          ,dat_32_mv_2_i_32_00_w
          ,dat_32_mv_2_i_32_16_w
          ,dat_32_mv_2_i_32_32_w
          ,dat_32_mv_2_i_32_48_w
         } = dat_32_mv_2_i ;

  // input mv layer 6
  assign { dat_64_mv_0_i_00_00_w
         } = dat_64_mv_0_i ;
  assign { dat_64_mv_1_i_00_00_w
          ,dat_64_mv_1_i_32_00_w
         } = dat_64_mv_1_i ;
  assign { dat_64_mv_2_i_00_00_w
          ,dat_64_mv_2_i_00_32_w
         } = dat_64_mv_2_i ;


//--- FSM ------------------------------
  // cur_state
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_state_r <= IDLE ;
    end
    else begin
      cur_state_r <= nxt_state_w ;
    end
  end

  // nxt_state
  always @(*) begin
                                           nxt_state_w = IDLE ;
    case( cur_state_r )
      IDLE : begin    if( start_i )        nxt_state_w = BUSY ;
                      else                 nxt_state_w = IDLE ;
      end
      BUSY : begin    if( busy_done_w )    nxt_state_w = IDLE ;
                      else                 nxt_state_w = BUSY ;
      end
    endcase
  end

  // jump_condition
  assign busy_done_w = cnt_dump_r == 63 ;

  // cnt_dump_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_dump_r <= 0 ;
    end
    else begin
      if( cur_state_r==BUSY ) begin
        if( busy_done_w ) begin
          cnt_dump_r <= 0 ;
        end
        else begin
          cnt_dump_r <= cnt_dump_r + 1 ;
        end
      end
    end
  end


//--- MV -------------------------------
  // mux 0
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      mv_wr_ena_r      <= 0 ;
      mv_wr_prt_r      <= 0 ;
      mv_wr_dat_08_0_r <= 0 ;
      mv_wr_dat_16_0_r <= 0 ;
      mv_wr_dat_16_1_r <= 0 ;
      mv_wr_dat_16_2_r <= 0 ;
      mv_wr_dat_32_0_r <= 0 ;
      mv_wr_dat_32_1_r <= 0 ;
      mv_wr_dat_32_2_r <= 0 ;
      mv_wr_dat_64_0_r <= 0 ;
      mv_wr_dat_64_1_r <= 0 ;
      mv_wr_dat_64_2_r <= 0 ;
    end
    else begin
      if( cur_state_r==BUSY ) begin
        mv_wr_ena_r <= 1 ;
        case( cnt_dump_r )
          00 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[01:00] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_00_00_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_00_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_00_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          01 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[01:00] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_00_08_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_00_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_08_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          02 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[03:02] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_00_16_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_00_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_16_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          03 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[03:02] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_00_24_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_00_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_24_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          04 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[05:04] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_00_32_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_00_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_32_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          05 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[05:04] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_00_40_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_00_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_40_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          06 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[07:06] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_00_48_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_00_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_48_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          07 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[07:06] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_00_56_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_00_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_56_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          08 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[01:00] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_08_00_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_08_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_00_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          09 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[01:00] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_08_08_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_08_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_08_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          10 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[03:02] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_08_16_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_08_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_16_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          11 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[03:02] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_08_24_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_08_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_24_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          12 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[05:04] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_08_32_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_08_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_32_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          13 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[05:04] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_08_40_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_08_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_40_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          14 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[07:06] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_08_48_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_08_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_48_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          15 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[07:06] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_08_56_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_00_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_08_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_00_56_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_00_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          16 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[09:08] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_16_00_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_16_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_00_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          17 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[09:08] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_16_08_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_16_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_08_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          18 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[11:10] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_16_16_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_16_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_16_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          19 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[11:10] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_16_24_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_16_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_24_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          20 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[13:12] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_16_32_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_16_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_32_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          21 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[13:12] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_16_40_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_16_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_40_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          22 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[15:14] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_16_48_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_16_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_48_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          23 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[15:14] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_16_56_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_16_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_56_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          24 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[09:08] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_24_00_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_24_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_00_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          25 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[09:08] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_24_08_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_24_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_08_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          26 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[11:10] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_24_16_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_24_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_16_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          27 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[33:32] ,dat_partition_i[11:10] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_24_24_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_24_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_24_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          28 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[13:12] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_24_32_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_24_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_32_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          29 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[13:12] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_24_40_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_24_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_40_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          30 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[15:14] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_24_48_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_24_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_48_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          31 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[35:34] ,dat_partition_i[15:14] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_24_56_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_16_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_24_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_16_56_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_00_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_16_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_00_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_00_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          32 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[17:16] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_32_00_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_32_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_00_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          33 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[17:16] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_32_08_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_32_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_08_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          34 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[19:18] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_32_16_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_32_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_16_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          35 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[19:18] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_32_24_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_32_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_24_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          36 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[21:20] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_32_32_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_32_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_32_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          37 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[21:20] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_32_40_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_32_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_40_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          38 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[23:22] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_32_48_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_32_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_48_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          39 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[23:22] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_32_56_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_32_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_56_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          40 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[17:16] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_40_00_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_40_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_00_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          41 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[17:16] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_40_08_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_40_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_08_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          42 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[19:18] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_40_16_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_40_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_16_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          43 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[19:18] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_40_24_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_40_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_24_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          44 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[21:20] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_40_32_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_40_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_32_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          45 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[21:20] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_40_40_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_40_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_40_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          46 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[23:22] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_40_48_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_40_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_48_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          47 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[23:22] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_40_56_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_32_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_40_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_32_56_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_32_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          48 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[25:24] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_48_00_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_48_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_00_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          49 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[25:24] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_48_08_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_48_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_08_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          50 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[27:26] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_48_16_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_48_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_16_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          51 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[27:26] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_48_24_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_48_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_24_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          52 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[29:28] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_48_32_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_48_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_32_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          53 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[29:28] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_48_40_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_48_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_40_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          54 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[31:30] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_48_48_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_48_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_48_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          55 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[31:30] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_48_56_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_48_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_56_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          56 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[25:24] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_56_00_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_56_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_00_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          57 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[25:24] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_56_08_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_00_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_56_00_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_08_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_00_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          58 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[27:26] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_56_16_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_56_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_16_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          59 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[37:36] ,dat_partition_i[27:26] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_56_24_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_16_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_56_16_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_24_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_00_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_00_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_16_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_00_w ;
          end
          60 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[29:28] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_56_32_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_56_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_32_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          61 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[29:28] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_56_40_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_32_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_56_32_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_40_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_32_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          62 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[31:30] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_56_48_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_56_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_48_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
          63 : begin    mv_wr_prt_r <= { dat_partition_i[41:40] ,dat_partition_i[39:38] ,dat_partition_i[31:30] };
                        mv_wr_dat_08_0_r <= dat_08_mv_0_i_56_56_w ;
                        mv_wr_dat_16_0_r <= dat_16_mv_0_i_48_48_w ;
                        mv_wr_dat_16_1_r <= dat_16_mv_1_i_56_48_w ;
                        mv_wr_dat_16_2_r <= dat_16_mv_2_i_48_56_w ;
                        mv_wr_dat_32_0_r <= dat_32_mv_0_i_32_32_w ;
                        mv_wr_dat_32_1_r <= dat_32_mv_1_i_48_32_w ;
                        mv_wr_dat_32_2_r <= dat_32_mv_2_i_32_48_w ;
                        mv_wr_dat_64_0_r <= dat_64_mv_0_i_00_00_w ;
                        mv_wr_dat_64_1_r <= dat_64_mv_1_i_32_00_w ;
                        mv_wr_dat_64_2_r <= dat_64_mv_2_i_00_32_w ;
          end
        endcase
      end
      else begin
        mv_wr_ena_r      <= 0 ;
        mv_wr_prt_r      <= 0 ;
        mv_wr_dat_08_0_r <= 0 ;
        mv_wr_dat_16_0_r <= 0 ;
        mv_wr_dat_16_1_r <= 0 ;
        mv_wr_dat_16_2_r <= 0 ;
        mv_wr_dat_32_0_r <= 0 ;
        mv_wr_dat_32_1_r <= 0 ;
        mv_wr_dat_32_2_r <= 0 ;
        mv_wr_dat_64_0_r <= 0 ;
        mv_wr_dat_64_1_r <= 0 ;
        mv_wr_dat_64_2_r <= 0 ;
      end
    end
  end

  // mux 1
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      mv_wr_adr_r <= 0 ;
      mv_wr_ena_o <= 0 ;
      mv_wr_adr_o <= 0 ;
      mv_wr_dat_o <= 0 ;
    end
    else begin
      if( mv_wr_ena_r ) begin
        mv_wr_ena_o <= 1 ;
        mv_wr_adr_r <= cnt_dump_r  ;
        mv_wr_adr_o <= mv_wr_adr_r ;
        casez( mv_wr_prt_r )
          {`IME_PART_2NX2N,2'b?           ,2'b?           } :    mv_wr_dat_o <= mv_wr_dat_64_0_r ;
          {`IME_PART_1NX2N,2'b?           ,2'b?           } :    mv_wr_dat_o <= mv_wr_dat_64_1_r ;
          {`IME_PART_2NX1N,2'b?           ,2'b?           } :    mv_wr_dat_o <= mv_wr_dat_64_2_r ;
          {`IME_PART_1NX1N,`IME_PART_2NX2N,2'b?           } :    mv_wr_dat_o <= mv_wr_dat_32_0_r ;
          {`IME_PART_1NX1N,`IME_PART_1NX2N,2'b?           } :    mv_wr_dat_o <= mv_wr_dat_32_1_r ;
          {`IME_PART_1NX1N,`IME_PART_2NX1N,2'b?           } :    mv_wr_dat_o <= mv_wr_dat_32_2_r ;
          {`IME_PART_1NX1N,`IME_PART_1NX1N,`IME_PART_2NX2N} :    mv_wr_dat_o <= mv_wr_dat_16_0_r ;
          {`IME_PART_1NX1N,`IME_PART_1NX1N,`IME_PART_1NX2N} :    mv_wr_dat_o <= mv_wr_dat_16_1_r ;
          {`IME_PART_1NX1N,`IME_PART_1NX1N,`IME_PART_2NX1N} :    mv_wr_dat_o <= mv_wr_dat_16_2_r ;
          {`IME_PART_1NX1N,`IME_PART_1NX1N,`IME_PART_1NX1N} :    mv_wr_dat_o <= mv_wr_dat_08_0_r ;
        endcase
      end
      else begin
        mv_wr_adr_r <= 0 ;
        mv_wr_ena_o <= 0 ;
        mv_wr_adr_o <= 0 ;
        mv_wr_dat_o <= 0 ;
      end
    end
  end


//--- DONE -----------------------------
  // done_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      done_o <= 0 ;
    end
    else begin
      done_o <= (cur_state_r!=IDLE) && (nxt_state_w==IDLE) ;
    end
  end


//*** DEBUG *******************************************************************

  `ifdef DEBUG


  `endif

endmodule
