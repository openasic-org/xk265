//--------------------------------------------------------------------
//
//  Filename    : ime_partition_decision.v
//  Author      : Huang Leilei
//  Created     : 2018-04-02
//  Description : partition decision in ime module (auto generated)
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module ime_partition_decision(
  // global
  clk               ,
  rstn              ,
  // ctrl
  start_i           ,
  done_o            ,
  ctu_x_all_i       ,
  ctu_y_all_i       ,
  ctu_x_res_i       ,
  ctu_y_res_i       ,
  ctu_x_cur_i       ,
  ctu_y_cur_i       ,
  // input
  dat_08_cst_0_i    ,
  dat_16_cst_0_i    ,
  dat_16_cst_1_i    ,
  dat_16_cst_2_i    ,
  dat_32_cst_0_i    ,
  dat_32_cst_1_i    ,
  dat_32_cst_2_i    ,
  dat_64_cst_0_i    ,
  dat_64_cst_1_i    ,
  dat_64_cst_2_i    ,
  // output
  dat_partition_o
  );


//*** PARAMETER ****************************************************************

  parameter FSM_WD                        = 1                       ;
  parameter    IDLE                       = 0                       ;
  parameter    BUSY                       = 1                       ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                   clk                       ;
  input                                   rstn                      ;
  // ctrl
  input                                   start_i                   ;
  output reg                              done_o                    ;
  input      [`PIC_X_WIDTH      -1 :0]    ctu_x_all_i               ;
  input      [`PIC_Y_WIDTH      -1 :0]    ctu_y_all_i               ;
  input      [6                 -1 :0]    ctu_x_res_i               ;
  input      [6                 -1 :0]    ctu_y_res_i               ;
  input      [`PIC_X_WIDTH      -1 :0]    ctu_x_cur_i               ;
  input      [`PIC_Y_WIDTH      -1 :0]    ctu_y_cur_i               ;
  // input
  input      [`IME_COST_WIDTH*64-1 :0]    dat_08_cst_0_i            ;
  input      [`IME_COST_WIDTH*16-1 :0]    dat_16_cst_0_i            ;
  input      [`IME_COST_WIDTH*32-1 :0]    dat_16_cst_1_i            ;
  input      [`IME_COST_WIDTH*32-1 :0]    dat_16_cst_2_i            ;
  input      [`IME_COST_WIDTH*4 -1 :0]    dat_32_cst_0_i            ;
  input      [`IME_COST_WIDTH*8 -1 :0]    dat_32_cst_1_i            ;
  input      [`IME_COST_WIDTH*8 -1 :0]    dat_32_cst_2_i            ;
  input      [`IME_COST_WIDTH*1 -1 :0]    dat_64_cst_0_i            ;
  input      [`IME_COST_WIDTH*2 -1 :0]    dat_64_cst_1_i            ;
  input      [`IME_COST_WIDTH*2 -1 :0]    dat_64_cst_2_i            ;
  // output
  output reg [42                -1 :0]    dat_partition_o           ;


//*** REG/WIRE *****************************************************************

  // input cst layer 3
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_00_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_00_08_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_00_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_00_24_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_00_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_00_40_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_00_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_00_56_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_08_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_08_08_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_08_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_08_24_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_08_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_08_40_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_08_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_08_56_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_16_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_16_08_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_16_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_16_24_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_16_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_16_40_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_16_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_16_56_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_24_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_24_08_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_24_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_24_24_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_24_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_24_40_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_24_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_24_56_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_32_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_32_08_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_32_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_32_24_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_32_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_32_40_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_32_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_32_56_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_40_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_40_08_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_40_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_40_24_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_40_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_40_40_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_40_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_40_56_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_48_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_48_08_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_48_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_48_24_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_48_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_48_40_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_48_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_48_56_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_56_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_56_08_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_56_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_56_24_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_56_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_56_40_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_56_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_08_cst_0_i_56_56_w    ;
  // input cst layer 4
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_00_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_00_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_08_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_00_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_00_08_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_00_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_00_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_08_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_00_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_00_24_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_00_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_00_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_08_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_00_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_00_40_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_00_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_00_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_08_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_00_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_00_56_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_16_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_16_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_24_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_16_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_16_08_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_16_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_16_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_24_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_16_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_16_24_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_16_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_16_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_24_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_16_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_16_40_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_16_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_16_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_24_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_16_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_16_56_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_32_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_32_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_40_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_32_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_32_08_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_32_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_32_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_40_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_32_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_32_24_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_32_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_32_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_40_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_32_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_32_40_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_32_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_32_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_40_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_32_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_32_56_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_48_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_48_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_56_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_48_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_48_08_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_48_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_48_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_56_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_48_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_48_24_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_48_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_48_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_56_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_48_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_48_40_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_48_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_48_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_1_i_56_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_48_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_16_cst_2_i_48_56_w    ;
  // input cst layer 5
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_i_00_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_i_00_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_i_16_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_i_00_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_i_00_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_i_00_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_i_00_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_i_16_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_i_00_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_i_00_48_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_i_32_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_i_32_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_i_48_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_i_32_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_i_32_16_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_i_32_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_i_32_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_1_i_48_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_i_32_32_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_32_cst_2_i_32_48_w    ;
  // input cst layer 6
  wire       [`IME_COST_WIDTH   -1 :0]    dat_64_cst_0_i_00_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_64_cst_1_i_00_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_64_cst_1_i_32_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_64_cst_2_i_00_00_w    ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_64_cst_2_i_00_32_w    ;

  // fsm
  reg        [FSM_WD            -1 :0]    cur_state_r               ;
  reg        [FSM_WD            -1 :0]    nxt_state_w               ;
  wire                                    busy_done_w               ;

  // decision
  reg        [5                 -1 :0]    cnt_decision_r            ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_1nx1n_cst_0_w         ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_1nx1n_cst_1_w         ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_1nx1n_cst_2_w         ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_1nx1n_cst_3_w         ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_1nx2n_cst_0_w         ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_1nx2n_cst_1_w         ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_2nx1n_cst_0_w         ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_2nx1n_cst_1_w         ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_2nx2n_cst_w           ;
  wire       [2                 -1 :0]    dat_bst_partition_w       ;
  wire       [`IME_COST_WIDTH   -1 :0]    dat_bst_cst_w             ;

  // store (could be reduced later)
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_00_00_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_00_16_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_00_32_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_00_48_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_16_00_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_16_16_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_16_32_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_16_48_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_32_00_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_32_16_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_32_32_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_32_48_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_48_00_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_48_16_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_48_32_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_16_cst_0_i_48_48_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_i_00_00_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_i_00_32_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_i_32_00_r    ;
  reg        [`IME_COST_WIDTH   -1 :0]    dat_32_cst_0_i_32_32_r    ;

  // part_x , part_y
  reg        [6                 -1 :0]    part_x                    ;
  reg        [6                 -1 :0]    part_y                    ;


//*** MAIN BODY ****************************************************************

//--- WIRE ASSIGNMENT ------------------
  // input cst layer 3
  assign { dat_08_cst_0_i_00_00_w
          ,dat_08_cst_0_i_00_08_w
          ,dat_08_cst_0_i_00_16_w
          ,dat_08_cst_0_i_00_24_w
          ,dat_08_cst_0_i_00_32_w
          ,dat_08_cst_0_i_00_40_w
          ,dat_08_cst_0_i_00_48_w
          ,dat_08_cst_0_i_00_56_w
          ,dat_08_cst_0_i_08_00_w
          ,dat_08_cst_0_i_08_08_w
          ,dat_08_cst_0_i_08_16_w
          ,dat_08_cst_0_i_08_24_w
          ,dat_08_cst_0_i_08_32_w
          ,dat_08_cst_0_i_08_40_w
          ,dat_08_cst_0_i_08_48_w
          ,dat_08_cst_0_i_08_56_w
          ,dat_08_cst_0_i_16_00_w
          ,dat_08_cst_0_i_16_08_w
          ,dat_08_cst_0_i_16_16_w
          ,dat_08_cst_0_i_16_24_w
          ,dat_08_cst_0_i_16_32_w
          ,dat_08_cst_0_i_16_40_w
          ,dat_08_cst_0_i_16_48_w
          ,dat_08_cst_0_i_16_56_w
          ,dat_08_cst_0_i_24_00_w
          ,dat_08_cst_0_i_24_08_w
          ,dat_08_cst_0_i_24_16_w
          ,dat_08_cst_0_i_24_24_w
          ,dat_08_cst_0_i_24_32_w
          ,dat_08_cst_0_i_24_40_w
          ,dat_08_cst_0_i_24_48_w
          ,dat_08_cst_0_i_24_56_w
          ,dat_08_cst_0_i_32_00_w
          ,dat_08_cst_0_i_32_08_w
          ,dat_08_cst_0_i_32_16_w
          ,dat_08_cst_0_i_32_24_w
          ,dat_08_cst_0_i_32_32_w
          ,dat_08_cst_0_i_32_40_w
          ,dat_08_cst_0_i_32_48_w
          ,dat_08_cst_0_i_32_56_w
          ,dat_08_cst_0_i_40_00_w
          ,dat_08_cst_0_i_40_08_w
          ,dat_08_cst_0_i_40_16_w
          ,dat_08_cst_0_i_40_24_w
          ,dat_08_cst_0_i_40_32_w
          ,dat_08_cst_0_i_40_40_w
          ,dat_08_cst_0_i_40_48_w
          ,dat_08_cst_0_i_40_56_w
          ,dat_08_cst_0_i_48_00_w
          ,dat_08_cst_0_i_48_08_w
          ,dat_08_cst_0_i_48_16_w
          ,dat_08_cst_0_i_48_24_w
          ,dat_08_cst_0_i_48_32_w
          ,dat_08_cst_0_i_48_40_w
          ,dat_08_cst_0_i_48_48_w
          ,dat_08_cst_0_i_48_56_w
          ,dat_08_cst_0_i_56_00_w
          ,dat_08_cst_0_i_56_08_w
          ,dat_08_cst_0_i_56_16_w
          ,dat_08_cst_0_i_56_24_w
          ,dat_08_cst_0_i_56_32_w
          ,dat_08_cst_0_i_56_40_w
          ,dat_08_cst_0_i_56_48_w
          ,dat_08_cst_0_i_56_56_w
         } = dat_08_cst_0_i ;

  // input cst layer 4
  assign { dat_16_cst_0_i_00_00_w
          ,dat_16_cst_0_i_00_16_w
          ,dat_16_cst_0_i_00_32_w
          ,dat_16_cst_0_i_00_48_w
          ,dat_16_cst_0_i_16_00_w
          ,dat_16_cst_0_i_16_16_w
          ,dat_16_cst_0_i_16_32_w
          ,dat_16_cst_0_i_16_48_w
          ,dat_16_cst_0_i_32_00_w
          ,dat_16_cst_0_i_32_16_w
          ,dat_16_cst_0_i_32_32_w
          ,dat_16_cst_0_i_32_48_w
          ,dat_16_cst_0_i_48_00_w
          ,dat_16_cst_0_i_48_16_w
          ,dat_16_cst_0_i_48_32_w
          ,dat_16_cst_0_i_48_48_w
         } = dat_16_cst_0_i ;
  assign { dat_16_cst_1_i_00_00_w
          ,dat_16_cst_1_i_08_00_w
          ,dat_16_cst_1_i_00_16_w
          ,dat_16_cst_1_i_08_16_w
          ,dat_16_cst_1_i_00_32_w
          ,dat_16_cst_1_i_08_32_w
          ,dat_16_cst_1_i_00_48_w
          ,dat_16_cst_1_i_08_48_w
          ,dat_16_cst_1_i_16_00_w
          ,dat_16_cst_1_i_24_00_w
          ,dat_16_cst_1_i_16_16_w
          ,dat_16_cst_1_i_24_16_w
          ,dat_16_cst_1_i_16_32_w
          ,dat_16_cst_1_i_24_32_w
          ,dat_16_cst_1_i_16_48_w
          ,dat_16_cst_1_i_24_48_w
          ,dat_16_cst_1_i_32_00_w
          ,dat_16_cst_1_i_40_00_w
          ,dat_16_cst_1_i_32_16_w
          ,dat_16_cst_1_i_40_16_w
          ,dat_16_cst_1_i_32_32_w
          ,dat_16_cst_1_i_40_32_w
          ,dat_16_cst_1_i_32_48_w
          ,dat_16_cst_1_i_40_48_w
          ,dat_16_cst_1_i_48_00_w
          ,dat_16_cst_1_i_56_00_w
          ,dat_16_cst_1_i_48_16_w
          ,dat_16_cst_1_i_56_16_w
          ,dat_16_cst_1_i_48_32_w
          ,dat_16_cst_1_i_56_32_w
          ,dat_16_cst_1_i_48_48_w
          ,dat_16_cst_1_i_56_48_w
         } = dat_16_cst_1_i ;
  assign { dat_16_cst_2_i_00_00_w
          ,dat_16_cst_2_i_00_08_w
          ,dat_16_cst_2_i_00_16_w
          ,dat_16_cst_2_i_00_24_w
          ,dat_16_cst_2_i_00_32_w
          ,dat_16_cst_2_i_00_40_w
          ,dat_16_cst_2_i_00_48_w
          ,dat_16_cst_2_i_00_56_w
          ,dat_16_cst_2_i_16_00_w
          ,dat_16_cst_2_i_16_08_w
          ,dat_16_cst_2_i_16_16_w
          ,dat_16_cst_2_i_16_24_w
          ,dat_16_cst_2_i_16_32_w
          ,dat_16_cst_2_i_16_40_w
          ,dat_16_cst_2_i_16_48_w
          ,dat_16_cst_2_i_16_56_w
          ,dat_16_cst_2_i_32_00_w
          ,dat_16_cst_2_i_32_08_w
          ,dat_16_cst_2_i_32_16_w
          ,dat_16_cst_2_i_32_24_w
          ,dat_16_cst_2_i_32_32_w
          ,dat_16_cst_2_i_32_40_w
          ,dat_16_cst_2_i_32_48_w
          ,dat_16_cst_2_i_32_56_w
          ,dat_16_cst_2_i_48_00_w
          ,dat_16_cst_2_i_48_08_w
          ,dat_16_cst_2_i_48_16_w
          ,dat_16_cst_2_i_48_24_w
          ,dat_16_cst_2_i_48_32_w
          ,dat_16_cst_2_i_48_40_w
          ,dat_16_cst_2_i_48_48_w
          ,dat_16_cst_2_i_48_56_w
         } = dat_16_cst_2_i ;

  // input cst layer 5
  assign { dat_32_cst_0_i_00_00_w
          ,dat_32_cst_0_i_00_32_w
          ,dat_32_cst_0_i_32_00_w
          ,dat_32_cst_0_i_32_32_w
         } = dat_32_cst_0_i ;
  assign { dat_32_cst_1_i_00_00_w
          ,dat_32_cst_1_i_16_00_w
          ,dat_32_cst_1_i_00_32_w
          ,dat_32_cst_1_i_16_32_w
          ,dat_32_cst_1_i_32_00_w
          ,dat_32_cst_1_i_48_00_w
          ,dat_32_cst_1_i_32_32_w
          ,dat_32_cst_1_i_48_32_w
         } = dat_32_cst_1_i ;
  assign { dat_32_cst_2_i_00_00_w
          ,dat_32_cst_2_i_00_16_w
          ,dat_32_cst_2_i_00_32_w
          ,dat_32_cst_2_i_00_48_w
          ,dat_32_cst_2_i_32_00_w
          ,dat_32_cst_2_i_32_16_w
          ,dat_32_cst_2_i_32_32_w
          ,dat_32_cst_2_i_32_48_w
         } = dat_32_cst_2_i ;

  // input cst layer 6
  assign { dat_64_cst_0_i_00_00_w
         } = dat_64_cst_0_i ;
  assign { dat_64_cst_1_i_00_00_w
          ,dat_64_cst_1_i_32_00_w
         } = dat_64_cst_1_i ;
  assign { dat_64_cst_2_i_00_00_w
          ,dat_64_cst_2_i_00_32_w
         } = dat_64_cst_2_i ;


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

  assign busy_done_w = cnt_decision_r == 20 ;


//--- DECISION -------------------------
  // cnt_decision_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_decision_r <= 0 ;
    end
    else begin
      if( cur_state_r==BUSY ) begin
        if( busy_done_w ) begin
          cnt_decision_r <= 0 ;
        end
        else begin
          cnt_decision_r <= cnt_decision_r + 1 ;
        end
      end
    end
  end

  // compare
  always @(*) begin
                    dat_1nx1n_cst_0_w = 0 ;
                    dat_1nx1n_cst_1_w = 0 ;
                    dat_1nx1n_cst_2_w = 0 ;
                    dat_1nx1n_cst_3_w = 0 ;
                    dat_1nx2n_cst_0_w = 0 ;
                    dat_1nx2n_cst_1_w = 0 ;
                    dat_2nx1n_cst_0_w = 0 ;
                    dat_2nx1n_cst_1_w = 0 ;
                    dat_2nx2n_cst_w   = 0 ;
    case( cnt_decision_r )
      00 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_00_00_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_08_00_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_00_08_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_08_08_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_00_00_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_08_00_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_00_00_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_00_08_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_00_00_w ;
      end
      01 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_00_16_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_08_16_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_00_24_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_08_24_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_00_16_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_08_16_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_00_16_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_00_24_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_00_16_w ;
      end
      02 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_00_32_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_08_32_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_00_40_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_08_40_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_00_32_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_08_32_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_00_32_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_00_40_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_00_32_w ;
      end
      03 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_00_48_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_08_48_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_00_56_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_08_56_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_00_48_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_08_48_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_00_48_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_00_56_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_00_48_w ;
      end
      04 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_16_00_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_24_00_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_16_08_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_24_08_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_16_00_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_24_00_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_16_00_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_16_08_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_16_00_w ;
      end
      05 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_16_16_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_24_16_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_16_24_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_24_24_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_16_16_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_24_16_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_16_16_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_16_24_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_16_16_w ;
      end
      06 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_16_32_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_24_32_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_16_40_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_24_40_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_16_32_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_24_32_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_16_32_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_16_40_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_16_32_w ;
      end
      07 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_16_48_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_24_48_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_16_56_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_24_56_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_16_48_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_24_48_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_16_48_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_16_56_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_16_48_w ;
      end
      08 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_32_00_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_40_00_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_32_08_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_40_08_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_32_00_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_40_00_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_32_00_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_32_08_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_32_00_w ;
      end
      09 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_32_16_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_40_16_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_32_24_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_40_24_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_32_16_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_40_16_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_32_16_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_32_24_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_32_16_w ;
      end
      10 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_32_32_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_40_32_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_32_40_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_40_40_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_32_32_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_40_32_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_32_32_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_32_40_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_32_32_w ;
      end
      11 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_32_48_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_40_48_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_32_56_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_40_56_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_32_48_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_40_48_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_32_48_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_32_56_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_32_48_w ;
      end
      12 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_48_00_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_56_00_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_48_08_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_56_08_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_48_00_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_56_00_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_48_00_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_48_08_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_48_00_w ;
      end
      13 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_48_16_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_56_16_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_48_24_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_56_24_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_48_16_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_56_16_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_48_16_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_48_24_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_48_16_w ;
      end
      14 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_48_32_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_56_32_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_48_40_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_56_40_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_48_32_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_56_32_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_48_32_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_48_40_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_48_32_w ;
      end
      15 : begin    dat_1nx1n_cst_0_w = dat_08_cst_0_i_48_48_w ;
                    dat_1nx1n_cst_1_w = dat_08_cst_0_i_56_48_w ;
                    dat_1nx1n_cst_2_w = dat_08_cst_0_i_48_56_w ;
                    dat_1nx1n_cst_3_w = dat_08_cst_0_i_56_56_w ;
                    dat_1nx2n_cst_0_w = dat_16_cst_1_i_48_48_w ;
                    dat_1nx2n_cst_1_w = dat_16_cst_1_i_56_48_w ;
                    dat_2nx1n_cst_0_w = dat_16_cst_2_i_48_48_w ;
                    dat_2nx1n_cst_1_w = dat_16_cst_2_i_48_56_w ;
                    dat_2nx2n_cst_w   = dat_16_cst_0_i_48_48_w ;
      end
      16 : begin    dat_1nx1n_cst_0_w = dat_16_cst_0_i_00_00_r ;
                    dat_1nx1n_cst_1_w = dat_16_cst_0_i_16_00_r ;
                    dat_1nx1n_cst_2_w = dat_16_cst_0_i_00_16_r ;
                    dat_1nx1n_cst_3_w = dat_16_cst_0_i_16_16_r ;
                    dat_1nx2n_cst_0_w = dat_32_cst_1_i_00_00_w ;
                    dat_1nx2n_cst_1_w = dat_32_cst_1_i_16_00_w ;
                    dat_2nx1n_cst_0_w = dat_32_cst_2_i_00_00_w ;
                    dat_2nx1n_cst_1_w = dat_32_cst_2_i_00_16_w ;
                    dat_2nx2n_cst_w   = dat_32_cst_0_i_00_00_w ;
      end
      17 : begin    dat_1nx1n_cst_0_w = dat_16_cst_0_i_00_32_r ;
                    dat_1nx1n_cst_1_w = dat_16_cst_0_i_16_32_r ;
                    dat_1nx1n_cst_2_w = dat_16_cst_0_i_00_48_r ;
                    dat_1nx1n_cst_3_w = dat_16_cst_0_i_16_48_r ;
                    dat_1nx2n_cst_0_w = dat_32_cst_1_i_00_32_w ;
                    dat_1nx2n_cst_1_w = dat_32_cst_1_i_16_32_w ;
                    dat_2nx1n_cst_0_w = dat_32_cst_2_i_00_32_w ;
                    dat_2nx1n_cst_1_w = dat_32_cst_2_i_00_48_w ;
                    dat_2nx2n_cst_w   = dat_32_cst_0_i_00_32_w ;
      end
      18 : begin    dat_1nx1n_cst_0_w = dat_16_cst_0_i_32_00_r ;
                    dat_1nx1n_cst_1_w = dat_16_cst_0_i_48_00_r ;
                    dat_1nx1n_cst_2_w = dat_16_cst_0_i_32_16_r ;
                    dat_1nx1n_cst_3_w = dat_16_cst_0_i_48_16_r ;
                    dat_1nx2n_cst_0_w = dat_32_cst_1_i_32_00_w ;
                    dat_1nx2n_cst_1_w = dat_32_cst_1_i_48_00_w ;
                    dat_2nx1n_cst_0_w = dat_32_cst_2_i_32_00_w ;
                    dat_2nx1n_cst_1_w = dat_32_cst_2_i_32_16_w ;
                    dat_2nx2n_cst_w   = dat_32_cst_0_i_32_00_w ;
      end
      19 : begin    dat_1nx1n_cst_0_w = dat_16_cst_0_i_32_32_r ;
                    dat_1nx1n_cst_1_w = dat_16_cst_0_i_48_32_r ;
                    dat_1nx1n_cst_2_w = dat_16_cst_0_i_32_48_r ;
                    dat_1nx1n_cst_3_w = dat_16_cst_0_i_48_48_r ;
                    dat_1nx2n_cst_0_w = dat_32_cst_1_i_32_32_w ;
                    dat_1nx2n_cst_1_w = dat_32_cst_1_i_48_32_w ;
                    dat_2nx1n_cst_0_w = dat_32_cst_2_i_32_32_w ;
                    dat_2nx1n_cst_1_w = dat_32_cst_2_i_32_48_w ;
                    dat_2nx2n_cst_w   = dat_32_cst_0_i_32_32_w ;
      end
      20 : begin    dat_1nx1n_cst_0_w = dat_32_cst_0_i_00_00_r ;
                    dat_1nx1n_cst_1_w = dat_32_cst_0_i_00_32_r ;
                    dat_1nx1n_cst_2_w = dat_32_cst_0_i_32_00_r ;
                    dat_1nx1n_cst_3_w = dat_32_cst_0_i_32_32_r ;
                    dat_1nx2n_cst_0_w = dat_64_cst_1_i_00_00_w ;
                    dat_1nx2n_cst_1_w = dat_64_cst_1_i_32_00_w ;
                    dat_2nx1n_cst_0_w = dat_64_cst_2_i_00_00_w ;
                    dat_2nx1n_cst_1_w = dat_64_cst_2_i_00_32_w ;
                    dat_2nx2n_cst_w   = dat_64_cst_0_i_00_00_w ;
      end
    endcase
  end

  // part_x part_y
  // compare
  always @(*) begin
                    part_x = 0 ;
                    part_y = 0 ;
    case( cnt_decision_r )
      00 : begin part_x = 15 ; part_y = 15 ; end
      01 : begin part_x = 31 ; part_y = 15 ; end
      02 : begin part_x = 47 ; part_y = 15 ; end
      03 : begin part_x = 63 ; part_y = 15 ; end
      04 : begin part_x = 15 ; part_y = 31 ; end
      05 : begin part_x = 31 ; part_y = 31 ; end
      06 : begin part_x = 47 ; part_y = 31 ; end
      07 : begin part_x = 63 ; part_y = 31 ; end
      08 : begin part_x = 15 ; part_y = 47 ; end
      09 : begin part_x = 31 ; part_y = 47 ; end
      10 : begin part_x = 47 ; part_y = 47 ; end
      11 : begin part_x = 63 ; part_y = 47 ; end
      12 : begin part_x = 15 ; part_y = 63 ; end
      13 : begin part_x = 31 ; part_y = 63 ; end
      14 : begin part_x = 47 ; part_y = 63 ; end
      15 : begin part_x = 63 ; part_y = 63 ; end
      16 : begin part_x = 31 ; part_y = 31 ; end
      17 : begin part_x = 63 ; part_y = 31 ; end
      18 : begin part_x = 31 ; part_y = 63 ; end
      19 : begin part_x = 63 ; part_y = 63 ; end
      20 : begin part_x = 63 ; part_y = 63 ; end
    endcase
  end

  // sub engine
  ime_partition_decision_engine ime_partition_decision_engine(
    // global
    .dat_1nx1n_cst_0_i      ( dat_1nx1n_cst_0_w    ),
    .dat_1nx1n_cst_1_i      ( dat_1nx1n_cst_1_w    ),
    .dat_1nx1n_cst_2_i      ( dat_1nx1n_cst_2_w    ),
    .dat_1nx1n_cst_3_i      ( dat_1nx1n_cst_3_w    ),
    .dat_1nx2n_cst_0_i      ( dat_1nx2n_cst_0_w    ),
    .dat_1nx2n_cst_1_i      ( dat_1nx2n_cst_1_w    ),
    .dat_2nx1n_cst_0_i      ( dat_2nx1n_cst_0_w    ),
    .dat_2nx1n_cst_1_i      ( dat_2nx1n_cst_1_w    ),
    .dat_2nx2n_cst_i        ( dat_2nx2n_cst_w      ),
    // config
    .part_x                 ( part_x               ),
    .part_y                 ( part_y               ),
    .ctu_x_all_i            ( ctu_x_all_i          ),
    .ctu_y_all_i            ( ctu_y_all_i          ),
    .ctu_x_res_i            ( ctu_x_res_i          ),
    .ctu_y_res_i            ( ctu_y_res_i          ),
    .ctu_x_cur_i            ( ctu_x_cur_i          ),
    .ctu_y_cur_i            ( ctu_y_cur_i          ),    
    // deci_o
    .dat_bst_partition_o    ( dat_bst_partition_w  ),
    .dat_bst_cst_o          ( dat_bst_cst_w        )
    );

  // best cost
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      dat_16_cst_0_i_00_00_r <= 0 ;
      dat_16_cst_0_i_00_16_r <= 0 ;
      dat_16_cst_0_i_00_32_r <= 0 ;
      dat_16_cst_0_i_00_48_r <= 0 ;
      dat_16_cst_0_i_16_00_r <= 0 ;
      dat_16_cst_0_i_16_16_r <= 0 ;
      dat_16_cst_0_i_16_32_r <= 0 ;
      dat_16_cst_0_i_16_48_r <= 0 ;
      dat_16_cst_0_i_32_00_r <= 0 ;
      dat_16_cst_0_i_32_16_r <= 0 ;
      dat_16_cst_0_i_32_32_r <= 0 ;
      dat_16_cst_0_i_32_48_r <= 0 ;
      dat_16_cst_0_i_48_00_r <= 0 ;
      dat_16_cst_0_i_48_16_r <= 0 ;
      dat_16_cst_0_i_48_32_r <= 0 ;
      dat_16_cst_0_i_48_48_r <= 0 ;
      dat_32_cst_0_i_00_00_r <= 0 ;
      dat_32_cst_0_i_00_32_r <= 0 ;
      dat_32_cst_0_i_32_00_r <= 0 ;
      dat_32_cst_0_i_32_32_r <= 0 ;
    end
    else begin
      if( cur_state_r==BUSY ) begin
        case( cnt_decision_r )
          00 : dat_16_cst_0_i_00_00_r <= dat_bst_cst_w ;
          01 : dat_16_cst_0_i_00_16_r <= dat_bst_cst_w ;
          02 : dat_16_cst_0_i_00_32_r <= dat_bst_cst_w ;
          03 : dat_16_cst_0_i_00_48_r <= dat_bst_cst_w ;
          04 : dat_16_cst_0_i_16_00_r <= dat_bst_cst_w ;
          05 : dat_16_cst_0_i_16_16_r <= dat_bst_cst_w ;
          06 : dat_16_cst_0_i_16_32_r <= dat_bst_cst_w ;
          07 : dat_16_cst_0_i_16_48_r <= dat_bst_cst_w ;
          08 : dat_16_cst_0_i_32_00_r <= dat_bst_cst_w ;
          09 : dat_16_cst_0_i_32_16_r <= dat_bst_cst_w ;
          10 : dat_16_cst_0_i_32_32_r <= dat_bst_cst_w ;
          11 : dat_16_cst_0_i_32_48_r <= dat_bst_cst_w ;
          12 : dat_16_cst_0_i_48_00_r <= dat_bst_cst_w ;
          13 : dat_16_cst_0_i_48_16_r <= dat_bst_cst_w ;
          14 : dat_16_cst_0_i_48_32_r <= dat_bst_cst_w ;
          15 : dat_16_cst_0_i_48_48_r <= dat_bst_cst_w ;
          16 : dat_32_cst_0_i_00_00_r <= dat_bst_cst_w ;
          17 : dat_32_cst_0_i_00_32_r <= dat_bst_cst_w ;
          18 : dat_32_cst_0_i_32_00_r <= dat_bst_cst_w ;
          19 : dat_32_cst_0_i_32_32_r <= dat_bst_cst_w ;
        endcase
      end
    end
  end


//--- OUTPUT ---------------------------
  // parition
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      dat_partition_o <= {{42{1'b0}}} ;
    end
    else begin
      if( cur_state_r==BUSY ) begin
        case( cnt_decision_r )
          00 : dat_partition_o[01:00] <= dat_bst_partition_w ;
          01 : dat_partition_o[03:02] <= dat_bst_partition_w ;
          02 : dat_partition_o[05:04] <= dat_bst_partition_w ;
          03 : dat_partition_o[07:06] <= dat_bst_partition_w ;
          04 : dat_partition_o[09:08] <= dat_bst_partition_w ;
          05 : dat_partition_o[11:10] <= dat_bst_partition_w ;
          06 : dat_partition_o[13:12] <= dat_bst_partition_w ;
          07 : dat_partition_o[15:14] <= dat_bst_partition_w ;
          08 : dat_partition_o[17:16] <= dat_bst_partition_w ;
          09 : dat_partition_o[19:18] <= dat_bst_partition_w ;
          10 : dat_partition_o[21:20] <= dat_bst_partition_w ;
          11 : dat_partition_o[23:22] <= dat_bst_partition_w ;
          12 : dat_partition_o[25:24] <= dat_bst_partition_w ;
          13 : dat_partition_o[27:26] <= dat_bst_partition_w ;
          14 : dat_partition_o[29:28] <= dat_bst_partition_w ;
          15 : dat_partition_o[31:30] <= dat_bst_partition_w ;
          16 : dat_partition_o[33:32] <= dat_bst_partition_w ;
          17 : dat_partition_o[35:34] <= dat_bst_partition_w ;
          18 : dat_partition_o[37:36] <= dat_bst_partition_w ;
          19 : dat_partition_o[39:38] <= dat_bst_partition_w ;
          20 : dat_partition_o[41:40] <= dat_bst_partition_w ;
        endcase
      end
    end
  end

  // done
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      done_o <= 0 ;
    end
    else begin
      done_o <= (cur_state_r==BUSY) && (nxt_state_w==IDLE) ;
    end
  end


//*** DEBUG *******************************************************************

  `ifdef DEBUG


  `endif

endmodule
