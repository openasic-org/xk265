//--------------------------------------------------------------------
//
//  Filename    : h265_posi_partition_decision.v
//  Author      : Huang Leilei
//  Description : partition decision in module post intra
//  Created     : 2018-04-09
//
//--------------------------------------------------------------------
//
//  Modified    : 2018-05-06 by HLL
//  Description : output format changed
//
//--------------------------------------------------------------------

`include "./enc_defines.v"

module posi_partition_decision(
  // global
  clk             ,
  rstn            ,
  // ctu
  ctu_x_all_i     ,
  ctu_y_all_i     ,
  ctu_x_res_i     ,
  ctu_y_res_i     ,
  ctu_x_cur_i     ,
  ctu_y_cur_i     ,
  // ctrl_i
  clr_i           ,
  done_o          ,
  // cfg_i
  num_mode_i      ,
  mode_i          ,
  size_i          ,
  position_i      ,
  // cst_i
  val_i           ,
  cst_i           ,
  // prt_o
  prt_o           ,
  // bst_cost_o
  bst_cost_o      ,
  // mode_if
  mod_wr_ena_o    ,
  mod_wr_adr_o    ,
  mod_wr_dat_o
  );


//*** PARAMETER ****************************************************************


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                 clk                  ;
  input                                 rstn                 ;
  input  [`PIC_X_WIDTH       -1 :0]     ctu_x_all_i          ;
  input  [`PIC_Y_WIDTH       -1 :0]     ctu_y_all_i          ;
  input  [4                  -1 :0]     ctu_x_res_i          ;
  input  [4                  -1 :0]     ctu_y_res_i          ;
  input  [`PIC_X_WIDTH       -1 :0]     ctu_x_cur_i          ;
  input  [`PIC_Y_WIDTH       -1 :0]     ctu_y_cur_i          ;
  // ctrl_i
  input                                 clr_i                ;
  output reg                            done_o               ;
  // cfg_i
  input      [3               -1 :0]    num_mode_i           ;
  input      [6               -1 :0]    mode_i               ;
  input      [2               -1 :0]    size_i               ;
  input      [8               -1 :0]    position_i           ;
  // cst_i
  input                                 val_i                ;
  input      [`POSI_COST_WIDTH-1 :0]    cst_i                ;
  // prt_o
  output     [85              -1 :0]    prt_o                ;
  // mode_if
  output reg                            mod_wr_ena_o         ;
  output reg [8               -1 :0]    mod_wr_adr_o         ;
  output reg [6               -1 :0]    mod_wr_dat_o         ;
  // cost_o
  output     [`POSI_COST_WIDTH-1 :0]    bst_cost_o           ;


//*** REG/WIRE *****************************************************************

  wire       [4               -1 :0]    idx_4x4_x_w          ;
  wire       [4               -1 :0]    idx_4x4_y_w          ;

  reg        [3               -1 :0]    cnt_mode_r           ;
  wire                                  cnt_mode_done_w      ;

  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_04_0_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_04_1_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_04_2_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_04_3_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_04_x_w    ;

  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_08_0_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_08_1_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_08_2_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_08_3_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_08_x_w    ;

  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_16_0_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_16_1_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_16_2_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_16_3_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_16_x_w    ;

  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_32_0_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_32_1_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_32_2_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_32_3_r    ;
  reg        [`POSI_COST_WIDTH-1 :0]    bst_cst_of_32_x_w    ;

  wire       [`POSI_COST_WIDTH+1 :0]    bst_sum_of_04_full_w ;    // TODO: these varibles & related logics could be merge.
  wire       [`POSI_COST_WIDTH-1 :0]    bst_sum_of_04_w      ;    // TODO: these varibles & related logics could be merge.
  wire       [`POSI_COST_WIDTH+1 :0]    bst_sum_of_08_full_w ;    // TODO: these varibles & related logics could be merge.
  wire       [`POSI_COST_WIDTH-1 :0]    bst_sum_of_08_w      ;    // TODO: these varibles & related logics could be merge.
  wire       [`POSI_COST_WIDTH+1 :0]    bst_sum_of_16_full_w ;    // TODO: these varibles & related logics could be merge.
  wire       [`POSI_COST_WIDTH-1 :0]    bst_sum_of_16_w      ;    // TODO: these varibles & related logics could be merge.

  reg                                   prt_of_08_0_0_r      ,prt_of_08_0_1_r,prt_of_08_0_2_r,prt_of_08_0_3_r,prt_of_08_0_4_r,prt_of_08_0_5_r,prt_of_08_0_6_r,prt_of_08_0_7_r;
  reg                                   prt_of_08_1_0_r      ,prt_of_08_1_1_r,prt_of_08_1_2_r,prt_of_08_1_3_r,prt_of_08_1_4_r,prt_of_08_1_5_r,prt_of_08_1_6_r,prt_of_08_1_7_r;
  reg                                   prt_of_08_2_0_r      ,prt_of_08_2_1_r,prt_of_08_2_2_r,prt_of_08_2_3_r,prt_of_08_2_4_r,prt_of_08_2_5_r,prt_of_08_2_6_r,prt_of_08_2_7_r;
  reg                                   prt_of_08_3_0_r      ,prt_of_08_3_1_r,prt_of_08_3_2_r,prt_of_08_3_3_r,prt_of_08_3_4_r,prt_of_08_3_5_r,prt_of_08_3_6_r,prt_of_08_3_7_r;
  reg                                   prt_of_08_4_0_r      ,prt_of_08_4_1_r,prt_of_08_4_2_r,prt_of_08_4_3_r,prt_of_08_4_4_r,prt_of_08_4_5_r,prt_of_08_4_6_r,prt_of_08_4_7_r;
  reg                                   prt_of_08_5_0_r      ,prt_of_08_5_1_r,prt_of_08_5_2_r,prt_of_08_5_3_r,prt_of_08_5_4_r,prt_of_08_5_5_r,prt_of_08_5_6_r,prt_of_08_5_7_r;
  reg                                   prt_of_08_6_0_r      ,prt_of_08_6_1_r,prt_of_08_6_2_r,prt_of_08_6_3_r,prt_of_08_6_4_r,prt_of_08_6_5_r,prt_of_08_6_6_r,prt_of_08_6_7_r;
  reg                                   prt_of_08_7_0_r      ,prt_of_08_7_1_r,prt_of_08_7_2_r,prt_of_08_7_3_r,prt_of_08_7_4_r,prt_of_08_7_5_r,prt_of_08_7_6_r,prt_of_08_7_7_r;

  reg                                   prt_of_16_0_0_r      ,prt_of_16_0_1_r,prt_of_16_0_2_r,prt_of_16_0_3_r;
  reg                                   prt_of_16_1_0_r      ,prt_of_16_1_1_r,prt_of_16_1_2_r,prt_of_16_1_3_r;
  reg                                   prt_of_16_2_0_r      ,prt_of_16_2_1_r,prt_of_16_2_2_r,prt_of_16_2_3_r;
  reg                                   prt_of_16_3_0_r      ,prt_of_16_3_1_r,prt_of_16_3_2_r,prt_of_16_3_3_r;

  wire                                  prt_of_08_0_0_w      ,prt_of_08_0_1_w,prt_of_08_0_2_w,prt_of_08_0_3_w,prt_of_08_0_4_w,prt_of_08_0_5_w,prt_of_08_0_6_w,prt_of_08_0_7_w;
  wire                                  prt_of_08_1_0_w      ,prt_of_08_1_1_w,prt_of_08_1_2_w,prt_of_08_1_3_w,prt_of_08_1_4_w,prt_of_08_1_5_w,prt_of_08_1_6_w,prt_of_08_1_7_w;
  wire                                  prt_of_08_2_0_w      ,prt_of_08_2_1_w,prt_of_08_2_2_w,prt_of_08_2_3_w,prt_of_08_2_4_w,prt_of_08_2_5_w,prt_of_08_2_6_w,prt_of_08_2_7_w;
  wire                                  prt_of_08_3_0_w      ,prt_of_08_3_1_w,prt_of_08_3_2_w,prt_of_08_3_3_w,prt_of_08_3_4_w,prt_of_08_3_5_w,prt_of_08_3_6_w,prt_of_08_3_7_w;
  wire                                  prt_of_08_4_0_w      ,prt_of_08_4_1_w,prt_of_08_4_2_w,prt_of_08_4_3_w,prt_of_08_4_4_w,prt_of_08_4_5_w,prt_of_08_4_6_w,prt_of_08_4_7_w;
  wire                                  prt_of_08_5_0_w      ,prt_of_08_5_1_w,prt_of_08_5_2_w,prt_of_08_5_3_w,prt_of_08_5_4_w,prt_of_08_5_5_w,prt_of_08_5_6_w,prt_of_08_5_7_w;
  wire                                  prt_of_08_6_0_w      ,prt_of_08_6_1_w,prt_of_08_6_2_w,prt_of_08_6_3_w,prt_of_08_6_4_w,prt_of_08_6_5_w,prt_of_08_6_6_w,prt_of_08_6_7_w;
  wire                                  prt_of_08_7_0_w      ,prt_of_08_7_1_w,prt_of_08_7_2_w,prt_of_08_7_3_w,prt_of_08_7_4_w,prt_of_08_7_5_w,prt_of_08_7_6_w,prt_of_08_7_7_w;

  wire                                  prt_of_16_0_0_w      ,prt_of_16_0_1_w,prt_of_16_0_2_w,prt_of_16_0_3_w;
  wire                                  prt_of_16_1_0_w      ,prt_of_16_1_1_w,prt_of_16_1_2_w,prt_of_16_1_3_w;
  wire                                  prt_of_16_2_0_w      ,prt_of_16_2_1_w,prt_of_16_2_2_w,prt_of_16_2_3_w;
  wire                                  prt_of_16_3_0_w      ,prt_of_16_3_1_w,prt_of_16_3_2_w,prt_of_16_3_3_w;

  reg                                   prt_of_32_0_0_r      ,prt_of_32_0_1_r;
  reg                                   prt_of_32_1_0_r      ,prt_of_32_1_1_r;

  // frame boundary
  wire                                  out_of_frame_x_w     ;
  wire                                  out_of_frame_y_w     ;
  wire                                  out_of_frame         ;


//*** MAIN BODY ****************************************************************

//--- ASSINMENT ------------------------
  // idx_i
  assign idx_4x4_x_w = {position_i[6],position_i[4],position_i[2],position_i[0]} ;
  assign idx_4x4_y_w = {position_i[7],position_i[5],position_i[3],position_i[1]} ;

  assign out_of_frame_x_w = ((ctu_x_cur_i == ctu_x_all_i) && (idx_4x4_x_w > ctu_x_res_i)) ;
  assign out_of_frame_y_w = ((ctu_y_cur_i == ctu_y_all_i) && (idx_4x4_y_w > ctu_y_res_i)) ;
  assign out_of_frame = out_of_frame_y_w || out_of_frame_x_w ;

//--- MODE -----------------------------
  // cnt_mode_r & its done signal
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_mode_r <= 0 ;
    end
    else begin
      if( val_i ) begin
        if( cnt_mode_done_w ) begin
          cnt_mode_r <= 0 ;
        end
        else begin
          cnt_mode_r <= cnt_mode_r + 1 ;
        end
      end
    end
  end

  assign cnt_mode_done_w = cnt_mode_r==num_mode_i ;


//--- LEVEL 04 -------------------------
  // bst_cst_of_04_x_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      bst_cst_of_04_0_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
      bst_cst_of_04_1_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
      bst_cst_of_04_2_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
      bst_cst_of_04_3_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
    end 
    else if ( out_of_frame ) begin 
      case ({idx_4x4_y_w[0],idx_4x4_x_w[0]})
        0 : bst_cst_of_04_0_r <= 0 ;
        1 : bst_cst_of_04_1_r <= 0 ;
        2 : bst_cst_of_04_2_r <= 0 ;
        3 : bst_cst_of_04_3_r <= 0 ;
      endcase 
    end 
    else begin
      if( val_i ) begin
        if( size_i==`SIZE_04 ) begin
          case( {idx_4x4_y_w[0],idx_4x4_x_w[0]} )
            0 : begin    if( cnt_mode_r==0 ) begin
                           bst_cst_of_04_0_r <= cst_i ;
                         end
                         else begin
                           if( cst_i<bst_cst_of_04_0_r ) begin
                             bst_cst_of_04_0_r <= cst_i ;
                           end
                         end
            end
            1 : begin    if( cnt_mode_r==0 ) begin
                           bst_cst_of_04_1_r <= cst_i ;
                         end
                         else begin
                           if( cst_i<bst_cst_of_04_1_r ) begin
                             bst_cst_of_04_1_r <= cst_i ;
                           end
                         end
            end
            2 : begin    if( cnt_mode_r==0 ) begin
                           bst_cst_of_04_2_r <= cst_i ;
                         end
                         else begin
                           if( cst_i<bst_cst_of_04_2_r ) begin
                             bst_cst_of_04_2_r <= cst_i ;
                           end
                         end
            end
            3 : begin    if( cnt_mode_r==0 ) begin
                           bst_cst_of_04_3_r <= cst_i ;
                         end
                         else begin
                           if( cst_i<bst_cst_of_04_3_r ) begin
                             bst_cst_of_04_3_r <= cst_i ;
                           end
                         end
            end
          endcase
        end
      end
    end
  end

  // sum of 04
  assign bst_sum_of_04_full_w = bst_cst_of_04_0_r + bst_cst_of_04_1_r + bst_cst_of_04_2_r + bst_cst_of_04_3_r ;
  assign bst_sum_of_04_w = (bst_sum_of_04_full_w<{{`POSI_COST_WIDTH{1'b1}}}) ? bst_sum_of_04_full_w : {{`POSI_COST_WIDTH{1'b1}}} ;


//--- LEVEL 08 -------------------------
  // prt of 08
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      {prt_of_08_0_0_r,prt_of_08_0_1_r,prt_of_08_0_2_r,prt_of_08_0_3_r,prt_of_08_0_4_r,prt_of_08_0_5_r,prt_of_08_0_6_r,prt_of_08_0_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
      {prt_of_08_1_0_r,prt_of_08_1_1_r,prt_of_08_1_2_r,prt_of_08_1_3_r,prt_of_08_1_4_r,prt_of_08_1_5_r,prt_of_08_1_6_r,prt_of_08_1_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
      {prt_of_08_2_0_r,prt_of_08_2_1_r,prt_of_08_2_2_r,prt_of_08_2_3_r,prt_of_08_2_4_r,prt_of_08_2_5_r,prt_of_08_2_6_r,prt_of_08_2_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
      {prt_of_08_3_0_r,prt_of_08_3_1_r,prt_of_08_3_2_r,prt_of_08_3_3_r,prt_of_08_3_4_r,prt_of_08_3_5_r,prt_of_08_3_6_r,prt_of_08_3_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
      {prt_of_08_4_0_r,prt_of_08_4_1_r,prt_of_08_4_2_r,prt_of_08_4_3_r,prt_of_08_4_4_r,prt_of_08_4_5_r,prt_of_08_4_6_r,prt_of_08_4_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
      {prt_of_08_5_0_r,prt_of_08_5_1_r,prt_of_08_5_2_r,prt_of_08_5_3_r,prt_of_08_5_4_r,prt_of_08_5_5_r,prt_of_08_5_6_r,prt_of_08_5_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
      {prt_of_08_6_0_r,prt_of_08_6_1_r,prt_of_08_6_2_r,prt_of_08_6_3_r,prt_of_08_6_4_r,prt_of_08_6_5_r,prt_of_08_6_6_r,prt_of_08_6_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
      {prt_of_08_7_0_r,prt_of_08_7_1_r,prt_of_08_7_2_r,prt_of_08_7_3_r,prt_of_08_7_4_r,prt_of_08_7_5_r,prt_of_08_7_6_r,prt_of_08_7_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
    end
    else begin
      if( clr_i ) begin
        {prt_of_08_0_0_r,prt_of_08_0_1_r,prt_of_08_0_2_r,prt_of_08_0_3_r,prt_of_08_0_4_r,prt_of_08_0_5_r,prt_of_08_0_6_r,prt_of_08_0_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
        {prt_of_08_1_0_r,prt_of_08_1_1_r,prt_of_08_1_2_r,prt_of_08_1_3_r,prt_of_08_1_4_r,prt_of_08_1_5_r,prt_of_08_1_6_r,prt_of_08_1_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
        {prt_of_08_2_0_r,prt_of_08_2_1_r,prt_of_08_2_2_r,prt_of_08_2_3_r,prt_of_08_2_4_r,prt_of_08_2_5_r,prt_of_08_2_6_r,prt_of_08_2_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
        {prt_of_08_3_0_r,prt_of_08_3_1_r,prt_of_08_3_2_r,prt_of_08_3_3_r,prt_of_08_3_4_r,prt_of_08_3_5_r,prt_of_08_3_6_r,prt_of_08_3_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
        {prt_of_08_4_0_r,prt_of_08_4_1_r,prt_of_08_4_2_r,prt_of_08_4_3_r,prt_of_08_4_4_r,prt_of_08_4_5_r,prt_of_08_4_6_r,prt_of_08_4_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
        {prt_of_08_5_0_r,prt_of_08_5_1_r,prt_of_08_5_2_r,prt_of_08_5_3_r,prt_of_08_5_4_r,prt_of_08_5_5_r,prt_of_08_5_6_r,prt_of_08_5_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
        {prt_of_08_6_0_r,prt_of_08_6_1_r,prt_of_08_6_2_r,prt_of_08_6_3_r,prt_of_08_6_4_r,prt_of_08_6_5_r,prt_of_08_6_6_r,prt_of_08_6_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
        {prt_of_08_7_0_r,prt_of_08_7_1_r,prt_of_08_7_2_r,prt_of_08_7_3_r,prt_of_08_7_4_r,prt_of_08_7_5_r,prt_of_08_7_6_r,prt_of_08_7_7_r} <= {{8{`POSI_PART_2NX2N}}} ;
      end
      else if( val_i ) begin
        if( size_i==`SIZE_08 ) begin
          if( cst_i>bst_sum_of_04_w ) begin
            case( {idx_4x4_y_w[3:1],idx_4x4_x_w[3:1]} )
              00 : prt_of_08_0_0_r <= `POSI_PART_1NX1N ;
              01 : prt_of_08_0_1_r <= `POSI_PART_1NX1N ;
              02 : prt_of_08_0_2_r <= `POSI_PART_1NX1N ;
              03 : prt_of_08_0_3_r <= `POSI_PART_1NX1N ;
              04 : prt_of_08_0_4_r <= `POSI_PART_1NX1N ;
              05 : prt_of_08_0_5_r <= `POSI_PART_1NX1N ;
              06 : prt_of_08_0_6_r <= `POSI_PART_1NX1N ;
              07 : prt_of_08_0_7_r <= `POSI_PART_1NX1N ;
              08 : prt_of_08_1_0_r <= `POSI_PART_1NX1N ;
              09 : prt_of_08_1_1_r <= `POSI_PART_1NX1N ;
              10 : prt_of_08_1_2_r <= `POSI_PART_1NX1N ;
              11 : prt_of_08_1_3_r <= `POSI_PART_1NX1N ;
              12 : prt_of_08_1_4_r <= `POSI_PART_1NX1N ;
              13 : prt_of_08_1_5_r <= `POSI_PART_1NX1N ;
              14 : prt_of_08_1_6_r <= `POSI_PART_1NX1N ;
              15 : prt_of_08_1_7_r <= `POSI_PART_1NX1N ;
              16 : prt_of_08_2_0_r <= `POSI_PART_1NX1N ;
              17 : prt_of_08_2_1_r <= `POSI_PART_1NX1N ;
              18 : prt_of_08_2_2_r <= `POSI_PART_1NX1N ;
              19 : prt_of_08_2_3_r <= `POSI_PART_1NX1N ;
              20 : prt_of_08_2_4_r <= `POSI_PART_1NX1N ;
              21 : prt_of_08_2_5_r <= `POSI_PART_1NX1N ;
              22 : prt_of_08_2_6_r <= `POSI_PART_1NX1N ;
              23 : prt_of_08_2_7_r <= `POSI_PART_1NX1N ;
              24 : prt_of_08_3_0_r <= `POSI_PART_1NX1N ;
              25 : prt_of_08_3_1_r <= `POSI_PART_1NX1N ;
              26 : prt_of_08_3_2_r <= `POSI_PART_1NX1N ;
              27 : prt_of_08_3_3_r <= `POSI_PART_1NX1N ;
              28 : prt_of_08_3_4_r <= `POSI_PART_1NX1N ;
              29 : prt_of_08_3_5_r <= `POSI_PART_1NX1N ;
              30 : prt_of_08_3_6_r <= `POSI_PART_1NX1N ;
              31 : prt_of_08_3_7_r <= `POSI_PART_1NX1N ;
              32 : prt_of_08_4_0_r <= `POSI_PART_1NX1N ;
              33 : prt_of_08_4_1_r <= `POSI_PART_1NX1N ;
              34 : prt_of_08_4_2_r <= `POSI_PART_1NX1N ;
              35 : prt_of_08_4_3_r <= `POSI_PART_1NX1N ;
              36 : prt_of_08_4_4_r <= `POSI_PART_1NX1N ;
              37 : prt_of_08_4_5_r <= `POSI_PART_1NX1N ;
              38 : prt_of_08_4_6_r <= `POSI_PART_1NX1N ;
              39 : prt_of_08_4_7_r <= `POSI_PART_1NX1N ;
              40 : prt_of_08_5_0_r <= `POSI_PART_1NX1N ;
              41 : prt_of_08_5_1_r <= `POSI_PART_1NX1N ;
              42 : prt_of_08_5_2_r <= `POSI_PART_1NX1N ;
              43 : prt_of_08_5_3_r <= `POSI_PART_1NX1N ;
              44 : prt_of_08_5_4_r <= `POSI_PART_1NX1N ;
              45 : prt_of_08_5_5_r <= `POSI_PART_1NX1N ;
              46 : prt_of_08_5_6_r <= `POSI_PART_1NX1N ;
              47 : prt_of_08_5_7_r <= `POSI_PART_1NX1N ;
              48 : prt_of_08_6_0_r <= `POSI_PART_1NX1N ;
              49 : prt_of_08_6_1_r <= `POSI_PART_1NX1N ;
              50 : prt_of_08_6_2_r <= `POSI_PART_1NX1N ;
              51 : prt_of_08_6_3_r <= `POSI_PART_1NX1N ;
              52 : prt_of_08_6_4_r <= `POSI_PART_1NX1N ;
              53 : prt_of_08_6_5_r <= `POSI_PART_1NX1N ;
              54 : prt_of_08_6_6_r <= `POSI_PART_1NX1N ;
              55 : prt_of_08_6_7_r <= `POSI_PART_1NX1N ;
              56 : prt_of_08_7_0_r <= `POSI_PART_1NX1N ;
              57 : prt_of_08_7_1_r <= `POSI_PART_1NX1N ;
              58 : prt_of_08_7_2_r <= `POSI_PART_1NX1N ;
              59 : prt_of_08_7_3_r <= `POSI_PART_1NX1N ;
              60 : prt_of_08_7_4_r <= `POSI_PART_1NX1N ;
              61 : prt_of_08_7_5_r <= `POSI_PART_1NX1N ;
              62 : prt_of_08_7_6_r <= `POSI_PART_1NX1N ;
              63 : prt_of_08_7_7_r <= `POSI_PART_1NX1N ;
            endcase
          end
        end
      end
    end
  end

  // best of 08
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      bst_cst_of_08_0_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
      bst_cst_of_08_1_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
      bst_cst_of_08_2_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
      bst_cst_of_08_3_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
    end
    else begin
      if( val_i ) begin
        if( size_i==`SIZE_08 ) begin
          case( {idx_4x4_y_w[1],idx_4x4_x_w[1]} )
            0 : begin    if( cnt_mode_r==0 ) begin
                           if( bst_sum_of_04_w < cst_i ) begin
                             bst_cst_of_08_0_r <= bst_sum_of_04_w ;
                           end
                           else begin
                             bst_cst_of_08_0_r <= cst_i ;
                           end
                         end
                         else begin
                           if( cst_i<bst_cst_of_08_0_r ) begin
                             bst_cst_of_08_0_r <= cst_i ;
                           end
                         end
            end
            1 : begin    if( cnt_mode_r==0 ) begin
                           if( bst_sum_of_04_w < cst_i ) begin
                             bst_cst_of_08_1_r <= bst_sum_of_04_w ;
                           end
                           else begin
                             bst_cst_of_08_1_r <= cst_i ;
                           end
                         end
                         else begin
                           if( cst_i<bst_cst_of_08_1_r ) begin
                             bst_cst_of_08_1_r <= cst_i ;
                           end
                         end
            end
            2 : begin    if( cnt_mode_r==0 ) begin
                           if( bst_sum_of_04_w < cst_i ) begin
                             bst_cst_of_08_2_r <= bst_sum_of_04_w ;
                           end
                           else begin
                             bst_cst_of_08_2_r <= cst_i ;
                           end
                         end
                         else begin
                           if( cst_i<bst_cst_of_08_2_r ) begin
                             bst_cst_of_08_2_r <= cst_i ;
                           end
                         end
            end
            3 : begin    if( cnt_mode_r==0 ) begin
                           if( bst_sum_of_04_w < cst_i ) begin
                             bst_cst_of_08_3_r <= bst_sum_of_04_w ;
                           end
                           else begin
                             bst_cst_of_08_3_r <= cst_i ;
                           end
                         end
                         else begin
                           if( cst_i<bst_cst_of_08_3_r ) begin
                             bst_cst_of_08_3_r <= cst_i ;
                           end
                         end
            end
          endcase
        end
      end
    end
  end

  // sum of 08
  assign bst_sum_of_08_full_w = bst_cst_of_08_0_r + bst_cst_of_08_1_r + bst_cst_of_08_2_r + bst_cst_of_08_3_r ;
  assign bst_sum_of_08_w = (bst_sum_of_08_full_w<{{`POSI_COST_WIDTH{1'b1}}}) ? bst_sum_of_08_full_w : {{`POSI_COST_WIDTH{1'b1}}} ;


//--- LEVEL 16 -------------------------
  // prt of 16
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      {prt_of_16_0_0_r,prt_of_16_0_1_r,prt_of_16_0_2_r,prt_of_16_0_3_r} <= {{4{`POSI_PART_2NX2N}}} ;
      {prt_of_16_1_0_r,prt_of_16_1_1_r,prt_of_16_1_2_r,prt_of_16_1_3_r} <= {{4{`POSI_PART_2NX2N}}} ;
      {prt_of_16_2_0_r,prt_of_16_2_1_r,prt_of_16_2_2_r,prt_of_16_2_3_r} <= {{4{`POSI_PART_2NX2N}}} ;
      {prt_of_16_3_0_r,prt_of_16_3_1_r,prt_of_16_3_2_r,prt_of_16_3_3_r} <= {{4{`POSI_PART_2NX2N}}} ;
    end
    else begin
      if( clr_i ) begin
        {prt_of_16_0_0_r,prt_of_16_0_1_r,prt_of_16_0_2_r,prt_of_16_0_3_r} <= {{4{`POSI_PART_2NX2N}}} ;
        {prt_of_16_1_0_r,prt_of_16_1_1_r,prt_of_16_1_2_r,prt_of_16_1_3_r} <= {{4{`POSI_PART_2NX2N}}} ;
        {prt_of_16_2_0_r,prt_of_16_2_1_r,prt_of_16_2_2_r,prt_of_16_2_3_r} <= {{4{`POSI_PART_2NX2N}}} ;
        {prt_of_16_3_0_r,prt_of_16_3_1_r,prt_of_16_3_2_r,prt_of_16_3_3_r} <= {{4{`POSI_PART_2NX2N}}} ;
      end
      else if( val_i ) begin
        if( size_i==`SIZE_16 ) begin
          if( cst_i>bst_sum_of_08_w ) begin
            case( {idx_4x4_y_w[3:2],idx_4x4_x_w[3:2]} )
              00 : prt_of_16_0_0_r <= `POSI_PART_1NX1N ;
              01 : prt_of_16_0_1_r <= `POSI_PART_1NX1N ;
              02 : prt_of_16_0_2_r <= `POSI_PART_1NX1N ;
              03 : prt_of_16_0_3_r <= `POSI_PART_1NX1N ;
              04 : prt_of_16_1_0_r <= `POSI_PART_1NX1N ;
              05 : prt_of_16_1_1_r <= `POSI_PART_1NX1N ;
              06 : prt_of_16_1_2_r <= `POSI_PART_1NX1N ;
              07 : prt_of_16_1_3_r <= `POSI_PART_1NX1N ;
              08 : prt_of_16_2_0_r <= `POSI_PART_1NX1N ;
              09 : prt_of_16_2_1_r <= `POSI_PART_1NX1N ;
              10 : prt_of_16_2_2_r <= `POSI_PART_1NX1N ;
              11 : prt_of_16_2_3_r <= `POSI_PART_1NX1N ;
              12 : prt_of_16_3_0_r <= `POSI_PART_1NX1N ;
              13 : prt_of_16_3_1_r <= `POSI_PART_1NX1N ;
              14 : prt_of_16_3_2_r <= `POSI_PART_1NX1N ;
              15 : prt_of_16_3_3_r <= `POSI_PART_1NX1N ;
            endcase
          end
        end
      end
    end
  end

  // best of 16
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      bst_cst_of_16_0_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
      bst_cst_of_16_1_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
      bst_cst_of_16_2_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
      bst_cst_of_16_3_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
    end
    else begin
      if( val_i ) begin
        if( size_i==`SIZE_16 ) begin
          case( {idx_4x4_y_w[2],idx_4x4_x_w[2]} )
            0 : begin    if( cnt_mode_r==0 ) begin
                           if( bst_sum_of_08_w < cst_i ) begin
                             bst_cst_of_16_0_r <= bst_sum_of_08_w ;
                           end
                           else begin
                             bst_cst_of_16_0_r <= cst_i ;
                           end
                         end
                         else begin
                           if( cst_i<bst_cst_of_16_0_r ) begin
                             bst_cst_of_16_0_r <= cst_i ;
                           end
                         end
            end
            1 : begin    if( cnt_mode_r==0 ) begin
                           if( bst_sum_of_08_w < cst_i ) begin
                             bst_cst_of_16_1_r <= bst_sum_of_08_w ;
                           end
                           else begin
                             bst_cst_of_16_1_r <= cst_i ;
                           end
                         end
                         else begin
                           if( cst_i<bst_cst_of_16_1_r ) begin
                             bst_cst_of_16_1_r <= cst_i ;
                           end
                         end
            end
            2 : begin    if( cnt_mode_r==0 ) begin
                           if( bst_sum_of_08_w < cst_i ) begin
                             bst_cst_of_16_2_r <= bst_sum_of_08_w ;
                           end
                           else begin
                             bst_cst_of_16_2_r <= cst_i ;
                           end
                         end
                         else begin
                           if( cst_i<bst_cst_of_16_2_r ) begin
                             bst_cst_of_16_2_r <= cst_i ;
                           end
                         end
            end
            3 : begin    if( cnt_mode_r==0 ) begin
                           if( bst_sum_of_08_w < cst_i ) begin
                             bst_cst_of_16_3_r <= bst_sum_of_08_w ;
                           end
                           else begin
                             bst_cst_of_16_3_r <= cst_i ;
                           end
                         end
                         else begin
                           if( cst_i<bst_cst_of_16_3_r ) begin
                             bst_cst_of_16_3_r <= cst_i ;
                           end
                         end
            end
          endcase
        end
      end
    end
  end

  // sum of 16
  assign bst_sum_of_16_full_w = bst_cst_of_16_0_r + bst_cst_of_16_1_r + bst_cst_of_16_2_r + bst_cst_of_16_3_r ;
  assign bst_sum_of_16_w = (bst_sum_of_16_full_w<{{`POSI_COST_WIDTH{1'b1}}}) ? bst_sum_of_16_full_w : {{`POSI_COST_WIDTH{1'b1}}} ;


//--- LEVEL 32 -------------------------
  // prt of 32
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      {prt_of_32_0_0_r,prt_of_32_0_1_r} <= {{2{`POSI_PART_2NX2N}}} ;
      {prt_of_32_1_0_r,prt_of_32_1_1_r} <= {{2{`POSI_PART_2NX2N}}} ;
    end
    else begin
      if( clr_i ) begin
        {prt_of_32_0_0_r,prt_of_32_0_1_r} <= {{2{`POSI_PART_2NX2N}}} ;
        {prt_of_32_1_0_r,prt_of_32_1_1_r} <= {{2{`POSI_PART_2NX2N}}} ;
      end
      else if( val_i ) begin
        if( size_i==`SIZE_32 ) begin
          if( cst_i>bst_sum_of_16_w ) begin
            case( {idx_4x4_y_w[3],idx_4x4_x_w[3]} )
              00 : prt_of_32_0_0_r <= `POSI_PART_1NX1N ;
              01 : prt_of_32_0_1_r <= `POSI_PART_1NX1N ;
              02 : prt_of_32_1_0_r <= `POSI_PART_1NX1N ;
              03 : prt_of_32_1_1_r <= `POSI_PART_1NX1N ;
            endcase
          end
        end
      end
    end
  end

  // best of 16
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      bst_cst_of_32_0_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
      bst_cst_of_32_1_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
      bst_cst_of_32_2_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
      bst_cst_of_32_3_r <= {{(`POSI_COST_WIDTH){1'b1}}} ;
    end
    else begin
      if( val_i ) begin
        if( size_i==`SIZE_32 ) begin
          case( {idx_4x4_y_w[3],idx_4x4_x_w[3]} )
            0 : begin    if( cnt_mode_r==0 ) begin
                           if( bst_sum_of_16_w < cst_i ) begin
                             bst_cst_of_32_0_r <= bst_sum_of_16_w ;
                           end
                           else begin
                             bst_cst_of_32_0_r <= cst_i ;
                           end
                         end
                         else begin
                           if( cst_i<bst_cst_of_32_0_r ) begin
                             bst_cst_of_32_0_r <= cst_i ;
                           end
                         end
            end
            1 : begin    if( cnt_mode_r==0 ) begin
                           if( bst_sum_of_16_w < cst_i ) begin
                             bst_cst_of_32_1_r <= bst_sum_of_16_w ;
                           end
                           else begin
                             bst_cst_of_32_1_r <= cst_i ;
                           end
                         end
                         else begin
                           if( cst_i<bst_cst_of_32_1_r ) begin
                             bst_cst_of_32_1_r <= cst_i ;
                           end
                         end
            end
            2 : begin    if( cnt_mode_r==0 ) begin
                           if( bst_sum_of_16_w < cst_i ) begin
                             bst_cst_of_32_2_r <= bst_sum_of_16_w ;
                           end
                           else begin
                             bst_cst_of_32_2_r <= cst_i ;
                           end
                         end
                         else begin
                           if( cst_i<bst_cst_of_32_2_r ) begin
                             bst_cst_of_32_2_r <= cst_i ;
                           end
                         end
            end
            3 : begin    if( cnt_mode_r==0 ) begin
                           if( bst_sum_of_16_w < cst_i ) begin
                             bst_cst_of_32_3_r <= bst_sum_of_16_w ;
                           end
                           else begin
                             bst_cst_of_32_3_r <= cst_i ;
                           end
                         end
                         else begin
                           if( cst_i<bst_cst_of_32_3_r ) begin
                             bst_cst_of_32_3_r <= cst_i ;
                           end
                         end
            end
          endcase
        end
      end
    end
  end


//--- OUTPUT ---------------------------
  // done_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      done_o <= 0 ;
    end
    else begin
      done_o <= val_i && (size_i==`SIZE_32) && (idx_4x4_x_w[3]) && (idx_4x4_y_w[3]) && cnt_mode_done_w ;
    end
  end

  // bst_cost_o 
  assign bst_cost_o = bst_cst_of_32_3_r + bst_cst_of_32_2_r + bst_cst_of_32_1_r + bst_cst_of_32_0_r ;

  assign prt_of_16_0_0_w = prt_of_16_0_0_r && prt_of_32_0_0_r ;
  assign prt_of_16_0_1_w = prt_of_16_0_1_r && prt_of_32_0_0_r ;
  assign prt_of_16_0_2_w = prt_of_16_0_2_r && prt_of_32_0_1_r ;
  assign prt_of_16_0_3_w = prt_of_16_0_3_r && prt_of_32_0_1_r ;
  assign prt_of_16_1_0_w = prt_of_16_1_0_r && prt_of_32_0_0_r ;
  assign prt_of_16_1_1_w = prt_of_16_1_1_r && prt_of_32_0_0_r ;
  assign prt_of_16_1_2_w = prt_of_16_1_2_r && prt_of_32_0_1_r ;
  assign prt_of_16_1_3_w = prt_of_16_1_3_r && prt_of_32_0_1_r ;
  assign prt_of_16_2_0_w = prt_of_16_2_0_r && prt_of_32_1_0_r ;
  assign prt_of_16_2_1_w = prt_of_16_2_1_r && prt_of_32_1_0_r ;
  assign prt_of_16_2_2_w = prt_of_16_2_2_r && prt_of_32_1_1_r ;
  assign prt_of_16_2_3_w = prt_of_16_2_3_r && prt_of_32_1_1_r ;
  assign prt_of_16_3_0_w = prt_of_16_3_0_r && prt_of_32_1_0_r ;
  assign prt_of_16_3_1_w = prt_of_16_3_1_r && prt_of_32_1_0_r ;
  assign prt_of_16_3_2_w = prt_of_16_3_2_r && prt_of_32_1_1_r ;
  assign prt_of_16_3_3_w = prt_of_16_3_3_r && prt_of_32_1_1_r ;
  assign prt_of_08_0_0_w = prt_of_08_0_0_r && prt_of_16_0_0_w ;
  assign prt_of_08_0_1_w = prt_of_08_0_1_r && prt_of_16_0_0_w ;
  assign prt_of_08_0_2_w = prt_of_08_0_2_r && prt_of_16_0_1_w ;
  assign prt_of_08_0_3_w = prt_of_08_0_3_r && prt_of_16_0_1_w ;
  assign prt_of_08_0_4_w = prt_of_08_0_4_r && prt_of_16_0_2_w ;
  assign prt_of_08_0_5_w = prt_of_08_0_5_r && prt_of_16_0_2_w ;
  assign prt_of_08_0_6_w = prt_of_08_0_6_r && prt_of_16_0_3_w ;
  assign prt_of_08_0_7_w = prt_of_08_0_7_r && prt_of_16_0_3_w ;
  assign prt_of_08_1_0_w = prt_of_08_1_0_r && prt_of_16_0_0_w ;
  assign prt_of_08_1_1_w = prt_of_08_1_1_r && prt_of_16_0_0_w ;
  assign prt_of_08_1_2_w = prt_of_08_1_2_r && prt_of_16_0_1_w ;
  assign prt_of_08_1_3_w = prt_of_08_1_3_r && prt_of_16_0_1_w ;
  assign prt_of_08_1_4_w = prt_of_08_1_4_r && prt_of_16_0_2_w ;
  assign prt_of_08_1_5_w = prt_of_08_1_5_r && prt_of_16_0_2_w ;
  assign prt_of_08_1_6_w = prt_of_08_1_6_r && prt_of_16_0_3_w ;
  assign prt_of_08_1_7_w = prt_of_08_1_7_r && prt_of_16_0_3_w ;
  assign prt_of_08_2_0_w = prt_of_08_2_0_r && prt_of_16_1_0_w ;
  assign prt_of_08_2_1_w = prt_of_08_2_1_r && prt_of_16_1_0_w ;
  assign prt_of_08_2_2_w = prt_of_08_2_2_r && prt_of_16_1_1_w ;
  assign prt_of_08_2_3_w = prt_of_08_2_3_r && prt_of_16_1_1_w ;
  assign prt_of_08_2_4_w = prt_of_08_2_4_r && prt_of_16_1_2_w ;
  assign prt_of_08_2_5_w = prt_of_08_2_5_r && prt_of_16_1_2_w ;
  assign prt_of_08_2_6_w = prt_of_08_2_6_r && prt_of_16_1_3_w ;
  assign prt_of_08_2_7_w = prt_of_08_2_7_r && prt_of_16_1_3_w ;
  assign prt_of_08_3_0_w = prt_of_08_3_0_r && prt_of_16_1_0_w ;
  assign prt_of_08_3_1_w = prt_of_08_3_1_r && prt_of_16_1_0_w ;
  assign prt_of_08_3_2_w = prt_of_08_3_2_r && prt_of_16_1_1_w ;
  assign prt_of_08_3_3_w = prt_of_08_3_3_r && prt_of_16_1_1_w ;
  assign prt_of_08_3_4_w = prt_of_08_3_4_r && prt_of_16_1_2_w ;
  assign prt_of_08_3_5_w = prt_of_08_3_5_r && prt_of_16_1_2_w ;
  assign prt_of_08_3_6_w = prt_of_08_3_6_r && prt_of_16_1_3_w ;
  assign prt_of_08_3_7_w = prt_of_08_3_7_r && prt_of_16_1_3_w ;
  assign prt_of_08_4_0_w = prt_of_08_4_0_r && prt_of_16_2_0_w ;
  assign prt_of_08_4_1_w = prt_of_08_4_1_r && prt_of_16_2_0_w ;
  assign prt_of_08_4_2_w = prt_of_08_4_2_r && prt_of_16_2_1_w ;
  assign prt_of_08_4_3_w = prt_of_08_4_3_r && prt_of_16_2_1_w ;
  assign prt_of_08_4_4_w = prt_of_08_4_4_r && prt_of_16_2_2_w ;
  assign prt_of_08_4_5_w = prt_of_08_4_5_r && prt_of_16_2_2_w ;
  assign prt_of_08_4_6_w = prt_of_08_4_6_r && prt_of_16_2_3_w ;
  assign prt_of_08_4_7_w = prt_of_08_4_7_r && prt_of_16_2_3_w ;
  assign prt_of_08_5_0_w = prt_of_08_5_0_r && prt_of_16_2_0_w ;
  assign prt_of_08_5_1_w = prt_of_08_5_1_r && prt_of_16_2_0_w ;
  assign prt_of_08_5_2_w = prt_of_08_5_2_r && prt_of_16_2_1_w ;
  assign prt_of_08_5_3_w = prt_of_08_5_3_r && prt_of_16_2_1_w ;
  assign prt_of_08_5_4_w = prt_of_08_5_4_r && prt_of_16_2_2_w ;
  assign prt_of_08_5_5_w = prt_of_08_5_5_r && prt_of_16_2_2_w ;
  assign prt_of_08_5_6_w = prt_of_08_5_6_r && prt_of_16_2_3_w ;
  assign prt_of_08_5_7_w = prt_of_08_5_7_r && prt_of_16_2_3_w ;
  assign prt_of_08_6_0_w = prt_of_08_6_0_r && prt_of_16_3_0_w ;
  assign prt_of_08_6_1_w = prt_of_08_6_1_r && prt_of_16_3_0_w ;
  assign prt_of_08_6_2_w = prt_of_08_6_2_r && prt_of_16_3_1_w ;
  assign prt_of_08_6_3_w = prt_of_08_6_3_r && prt_of_16_3_1_w ;
  assign prt_of_08_6_4_w = prt_of_08_6_4_r && prt_of_16_3_2_w ;
  assign prt_of_08_6_5_w = prt_of_08_6_5_r && prt_of_16_3_2_w ;
  assign prt_of_08_6_6_w = prt_of_08_6_6_r && prt_of_16_3_3_w ;
  assign prt_of_08_6_7_w = prt_of_08_6_7_r && prt_of_16_3_3_w ;
  assign prt_of_08_7_0_w = prt_of_08_7_0_r && prt_of_16_3_0_w ;
  assign prt_of_08_7_1_w = prt_of_08_7_1_r && prt_of_16_3_0_w ;
  assign prt_of_08_7_2_w = prt_of_08_7_2_r && prt_of_16_3_1_w ;
  assign prt_of_08_7_3_w = prt_of_08_7_3_r && prt_of_16_3_1_w ;
  assign prt_of_08_7_4_w = prt_of_08_7_4_r && prt_of_16_3_2_w ;
  assign prt_of_08_7_5_w = prt_of_08_7_5_r && prt_of_16_3_2_w ;
  assign prt_of_08_7_6_w = prt_of_08_7_6_r && prt_of_16_3_3_w ;
  assign prt_of_08_7_7_w = prt_of_08_7_7_r && prt_of_16_3_3_w ;
  // assignment 
  assign prt_o = { prt_of_08_7_7_w,prt_of_08_7_6_w
                  ,prt_of_08_6_7_w,prt_of_08_6_6_w
                  ,prt_of_08_7_5_w,prt_of_08_7_4_w
                  ,prt_of_08_6_5_w,prt_of_08_6_4_w
                  ,prt_of_08_5_7_w,prt_of_08_5_6_w
                  ,prt_of_08_4_7_w,prt_of_08_4_6_w
                  ,prt_of_08_5_5_w,prt_of_08_5_4_w
                  ,prt_of_08_4_5_w,prt_of_08_4_4_w

                  ,prt_of_08_7_3_w,prt_of_08_7_2_w
                  ,prt_of_08_6_3_w,prt_of_08_6_2_w
                  ,prt_of_08_7_1_w,prt_of_08_7_0_w
                  ,prt_of_08_6_1_w,prt_of_08_6_0_w
                  ,prt_of_08_5_3_w,prt_of_08_5_2_w
                  ,prt_of_08_4_3_w,prt_of_08_4_2_w
                  ,prt_of_08_5_1_w,prt_of_08_5_0_w
                  ,prt_of_08_4_1_w,prt_of_08_4_0_w

                  ,prt_of_08_3_7_w,prt_of_08_3_6_w
                  ,prt_of_08_2_7_w,prt_of_08_2_6_w
                  ,prt_of_08_3_5_w,prt_of_08_3_4_w
                  ,prt_of_08_2_5_w,prt_of_08_2_4_w
                  ,prt_of_08_1_7_w,prt_of_08_1_6_w
                  ,prt_of_08_0_7_w,prt_of_08_0_6_w
                  ,prt_of_08_1_5_w,prt_of_08_1_4_w
                  ,prt_of_08_0_5_w,prt_of_08_0_4_w

                  ,prt_of_08_3_3_w,prt_of_08_3_2_w
                  ,prt_of_08_2_3_w,prt_of_08_2_2_w
                  ,prt_of_08_3_1_w,prt_of_08_3_0_w
                  ,prt_of_08_2_1_w,prt_of_08_2_0_w
                  ,prt_of_08_1_3_w,prt_of_08_1_2_w
                  ,prt_of_08_0_3_w,prt_of_08_0_2_w
                  ,prt_of_08_1_1_w,prt_of_08_1_0_w
                  ,prt_of_08_0_1_w,prt_of_08_0_0_w

                  ,prt_of_16_3_3_w,prt_of_16_3_2_w
                  ,prt_of_16_2_3_w,prt_of_16_2_2_w
                  ,prt_of_16_3_1_w,prt_of_16_3_0_w
                  ,prt_of_16_2_1_w,prt_of_16_2_0_w
                  ,prt_of_16_1_3_w,prt_of_16_1_2_w
                  ,prt_of_16_0_3_w,prt_of_16_0_2_w
                  ,prt_of_16_1_1_w,prt_of_16_1_0_w
                  ,prt_of_16_0_1_w,prt_of_16_0_0_w

                  ,prt_of_32_1_1_r,prt_of_32_1_0_r
                  ,prt_of_32_0_1_r,prt_of_32_0_0_r

                  ,1'b1
                 };

  // mode
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      mod_wr_ena_o <= 0 ;
      mod_wr_adr_o <= 0 ;
      mod_wr_dat_o <= 0 ;
    end
    else begin
      if( val_i ) begin
        mod_wr_adr_o <= { idx_4x4_y_w[3] ,idx_4x4_x_w[3]
                         ,idx_4x4_y_w[2] ,idx_4x4_x_w[2]
                         ,idx_4x4_y_w[1] ,idx_4x4_x_w[1]
                         ,idx_4x4_y_w[0] ,idx_4x4_x_w[0] };
        mod_wr_dat_o <= mode_i ;
        case( size_i )
          `SIZE_04 : begin    if( (cnt_mode_r==0) || (cst_i<bst_cst_of_04_x_w) ) begin
                                mod_wr_ena_o <= 1 ;
                              end
                              else begin
                                mod_wr_ena_o <= 0 ;
                              end
          end
          `SIZE_08 : begin    if( ( (cnt_mode_r==0) && (cst_i<=bst_sum_of_04_w)) || ( ((cnt_mode_r!=0)) && (cst_i<bst_cst_of_08_x_w)) ) begin
                                mod_wr_ena_o <= 1 ;
                              end
                              else begin
                                mod_wr_ena_o <= 0 ;
                              end
          end
          `SIZE_16 : begin    if( ( (cnt_mode_r==0) && (cst_i<=bst_sum_of_08_w)) || ( ((cnt_mode_r!=0) && (cst_i<bst_cst_of_16_x_w)) )) begin
                                mod_wr_ena_o <= 1 ;
                              end
                              else begin
                                mod_wr_ena_o <= 0 ;
                              end
          end
          `SIZE_32 : begin    if( ((cnt_mode_r==0) && (cst_i<=bst_sum_of_16_w)) || ( ((cnt_mode_r!=0) && (cst_i<bst_cst_of_32_x_w)) )) begin
                                mod_wr_ena_o <= 1 ;
                              end
                              else begin
                                mod_wr_ena_o <= 0 ;
                              end
          end
        endcase
      end
      else begin
        mod_wr_ena_o <= 0 ;
      end
    end
  end

  // bst_cst_of_04_x_w
  always @(*) begin
    case( {idx_4x4_y_w[0],idx_4x4_x_w[0]} )
      0 :    bst_cst_of_04_x_w = bst_cst_of_04_0_r ;
      1 :    bst_cst_of_04_x_w = bst_cst_of_04_1_r ;
      2 :    bst_cst_of_04_x_w = bst_cst_of_04_2_r ;
      3 :    bst_cst_of_04_x_w = bst_cst_of_04_3_r ;
    endcase
  end

  // bst_cst_of_08_x_w
  always @(*) begin
    case( {idx_4x4_y_w[1],idx_4x4_x_w[1]} )
      0 :    bst_cst_of_08_x_w = bst_cst_of_08_0_r ;
      1 :    bst_cst_of_08_x_w = bst_cst_of_08_1_r ;
      2 :    bst_cst_of_08_x_w = bst_cst_of_08_2_r ;
      3 :    bst_cst_of_08_x_w = bst_cst_of_08_3_r ;
    endcase
  end

  // bst_cst_of_16_x_w
  always @(*) begin
    case( {idx_4x4_y_w[2],idx_4x4_x_w[2]} )
      0 :    bst_cst_of_16_x_w = bst_cst_of_16_0_r ;
      1 :    bst_cst_of_16_x_w = bst_cst_of_16_1_r ;
      2 :    bst_cst_of_16_x_w = bst_cst_of_16_2_r ;
      3 :    bst_cst_of_16_x_w = bst_cst_of_16_3_r ;
    endcase
  end

  // bst_cst_of_32_x_w
  always @(*) begin
    case( {idx_4x4_y_w[3],idx_4x4_x_w[3]} )
      0 :    bst_cst_of_32_x_w = bst_cst_of_32_0_r ;
      1 :    bst_cst_of_32_x_w = bst_cst_of_32_1_r ;
      2 :    bst_cst_of_32_x_w = bst_cst_of_32_2_r ;
      3 :    bst_cst_of_32_x_w = bst_cst_of_32_3_r ;
    endcase
  end


//*** DEBUG ********************************************************************

`ifdef H265_DEBUG

`endif

endmodule
