//--------------------------------------------------------------------
//
//  Filename    : h265_posi_transfer.v
//  Author      : Huang Leilei
//  Description : transfer logic in module post intra
//  Created     : 2018-04-10
//
//--------------------------------------------------------------------

`include "./enc_defines.v"

module posi_transfer(
  // global
  clk               ,
  rstn              ,
  // ctrl_if
  start_i           ,
  done_o            ,
  // mode_i
  mode_i            ,
  ctu_x_cur_i       ,
  // ori_if
  ori_rd_ena_o      ,
  ori_rd_siz_o      ,
  ori_rd_4x4_x_o    ,
  ori_rd_4x4_y_o    ,
  ori_rd_idx_o      ,
  ori_rd_dat_i      ,
  // ram_row_wr_if
  row_wr_ena_o      ,
  row_wr_adr_o      ,
  row_wr_dat_o      ,
  // ram_col_wr_if
  col_wr_ena_o      ,
  col_wr_adr_o      ,
  col_wr_dat_o      ,
  // ram_fra_wr_if
  fra_wr_ena_o      ,
  fra_wr_adr_o      ,
  fra_wr_dat_o
  );


//*** PARAMETER ****************************************************************

  // global
  parameter  MODE_PRE                  = 0                  ;
  parameter  MODE_POS                  = 1                  ;

  // local
  localparam FSM_WD                    = 2                  ;
  localparam    IDLE                   = 2'd0               ;
  localparam    PRE                    = 2'd1               ;
  localparam    POS_COL                = 2'd2               ;
  localparam    POS_FRA                = 2'd3               ;

  localparam DELAY                     = 2                  ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                clk                  ;
  input                                rstn                 ;
  // ctrl_if
  input                                start_i              ;
  output reg                           done_o               ;
  // mode_if
  input                                mode_i               ;
  input      [`PIC_X_WIDTH   -1 :0]    ctu_x_cur_i          ;
  // cfg_i
  output                               ori_rd_ena_o         ;
  output     [2              -1 :0]    ori_rd_siz_o         ;
  output     [4              -1 :0]    ori_rd_4x4_x_o       ;
  output     [4              -1 :0]    ori_rd_4x4_y_o       ;
  output     [5              -1 :0]    ori_rd_idx_o         ;
  input      [`PIXEL_WIDTH*32-1 :0]    ori_rd_dat_i         ;
  // ram_row_wr_if
  output                               row_wr_ena_o         ;
  output     [4+4            -1 :0]    row_wr_adr_o         ;
  output reg [`PIXEL_WIDTH*4 -1 :0]    row_wr_dat_o         ;
  // ram_col_wr_if
  output                               col_wr_ena_o         ;
  output     [4+4            -1 :0]    col_wr_adr_o         ;
  output reg [`PIXEL_WIDTH*4 -1 :0]    col_wr_dat_o         ;
  // ram_fra_wr_if
  output                               fra_wr_ena_o         ;
  output     [`PIC_X_WIDTH+4 -1 :0]    fra_wr_adr_o         ;
  output reg [`PIXEL_WIDTH*4 -1 :0]    fra_wr_dat_o         ;


//*** REG/WIRE *****************************************************************

  // assignment
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_0_0_w ,ori_rd_dat_i_b_0_0_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_0_1_w ,ori_rd_dat_i_b_0_1_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_0_2_w ,ori_rd_dat_i_b_0_2_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_0_3_w ,ori_rd_dat_i_b_0_3_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_1_0_w ,ori_rd_dat_i_b_1_0_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_1_1_w ,ori_rd_dat_i_b_1_1_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_1_2_w ,ori_rd_dat_i_b_1_2_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_1_3_w ,ori_rd_dat_i_b_1_3_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_2_0_w ,ori_rd_dat_i_b_2_0_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_2_1_w ,ori_rd_dat_i_b_2_1_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_2_2_w ,ori_rd_dat_i_b_2_2_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_2_3_w ,ori_rd_dat_i_b_2_3_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_3_0_w ,ori_rd_dat_i_b_3_0_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_3_1_w ,ori_rd_dat_i_b_3_1_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_3_2_w ,ori_rd_dat_i_b_3_2_w ;
  wire       [`PIXEL_WIDTH   -1 :0]    ori_rd_dat_i_a_3_3_w ,ori_rd_dat_i_b_3_3_w ;

  // fsm
  reg        [FSM_WD         -1 :0]    cur_state_r          ;
  reg        [FSM_WD         -1 :0]    nxt_state_w          ;

  wire                                 busy_done_w          ;

  reg        [4              -1 :0]    idx_4x4_x_r          ;
  reg        [4              -1 :0]    idx_4x4_y_r          ;
  wire                                 idx_4x4_x_done_w     ;
  wire                                 idx_4x4_y_done_w     ;

  // output
  reg        [DELAY*1        -1 :0]    val_dly_r            ;
  reg        [DELAY*FSM_WD   -1 :0]    cur_state_dly_r      ;

  reg        [DELAY*4        -1 :0]    idx_4x4_x_dly_r      ;
  reg        [DELAY*4        -1 :0]    idx_4x4_y_dly_r      ;


//*** MAIN BODY ****************************************************************

//--- ASSIGNMENT -----------------------
  assign { ori_rd_dat_i_a_0_0_w
          ,ori_rd_dat_i_a_0_1_w
          ,ori_rd_dat_i_a_0_2_w
          ,ori_rd_dat_i_a_0_3_w
          ,ori_rd_dat_i_b_0_0_w
          ,ori_rd_dat_i_b_0_1_w
          ,ori_rd_dat_i_b_0_2_w
          ,ori_rd_dat_i_b_0_3_w
          ,ori_rd_dat_i_a_1_0_w
          ,ori_rd_dat_i_a_1_1_w
          ,ori_rd_dat_i_a_1_2_w
          ,ori_rd_dat_i_a_1_3_w
          ,ori_rd_dat_i_b_1_0_w
          ,ori_rd_dat_i_b_1_1_w
          ,ori_rd_dat_i_b_1_2_w
          ,ori_rd_dat_i_b_1_3_w
          ,ori_rd_dat_i_a_2_0_w
          ,ori_rd_dat_i_a_2_1_w
          ,ori_rd_dat_i_a_2_2_w
          ,ori_rd_dat_i_a_2_3_w
          ,ori_rd_dat_i_b_2_0_w
          ,ori_rd_dat_i_b_2_1_w
          ,ori_rd_dat_i_b_2_2_w
          ,ori_rd_dat_i_b_2_3_w
          ,ori_rd_dat_i_a_3_0_w
          ,ori_rd_dat_i_a_3_1_w
          ,ori_rd_dat_i_a_3_2_w
          ,ori_rd_dat_i_a_3_3_w
          ,ori_rd_dat_i_b_3_0_w
          ,ori_rd_dat_i_b_3_1_w
          ,ori_rd_dat_i_b_3_2_w
          ,ori_rd_dat_i_b_3_3_w } = ori_rd_dat_i ;


//--- FSM ------------------------------
  // cur_state_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_state_r <= IDLE ;
    end
    else begin
      cur_state_r <= nxt_state_w ;
    end
  end

  // nxt_state_w
  always @(*) begin
                                              nxt_state_w = IDLE    ;
    case( cur_state_r )
      IDLE    : begin    if( start_i ) begin
                           case( mode_i )
                             MODE_PRE :       nxt_state_w = PRE     ;
                             MODE_POS :       nxt_state_w = POS_COL ;
                           endcase
                         end
                         else                 nxt_state_w = IDLE    ;
      end
      PRE     : begin    if( busy_done_w )    nxt_state_w = IDLE    ;
                         else                 nxt_state_w = PRE     ;
      end
      POS_COL : begin    if( busy_done_w )    nxt_state_w = POS_FRA ;
                         else                 nxt_state_w = POS_COL ;
      end
      POS_FRA : begin    if( busy_done_w )    nxt_state_w = IDLE    ;
                         else                 nxt_state_w = POS_FRA ;
      end
    endcase
  end

  // size_done_w
  assign busy_done_w = idx_4x4_x_done_w && idx_4x4_y_done_w ;

  // idx_4x4_x/y_r & its done signal
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      idx_4x4_x_r <= 0 ;
      idx_4x4_y_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        IDLE    : begin    if( start_i ) begin
                             case( mode_i )
                               MODE_PRE : begin    idx_4x4_x_r <= 0 ;
                                                   idx_4x4_y_r <= 0 ;
                               end
                               MODE_POS : begin    idx_4x4_x_r <= 15 ;    // -> start from <15,0>
                                                   idx_4x4_y_r <= 0  ;
                               end
                             endcase
                           end
        end
        PRE     : begin    if( idx_4x4_x_done_w ) begin
                             idx_4x4_x_r <= 0 ;
                             if( idx_4x4_y_done_w ) begin
                               idx_4x4_y_r <= 0 ;
                             end
                             else begin
                               idx_4x4_y_r <= idx_4x4_y_r + 1 ;
                             end
                           end
                           else begin
                             idx_4x4_x_r <= idx_4x4_x_r + 1 ;
                           end
        end
        POS_COL : begin    if( idx_4x4_y_done_w ) begin
                             idx_4x4_x_r <= 0  ;    // -> start from <0,15>
                             idx_4x4_y_r <= 15 ;
                           end
                           else begin
                             idx_4x4_y_r <= idx_4x4_y_r + 1 ;
                           end
        end
        POS_FRA : begin    if( idx_4x4_x_done_w ) begin
                             idx_4x4_x_r <= 0  ;    // -> start from <0,15>
                             idx_4x4_y_r <= 0 ;
                           end
                           else begin
                             idx_4x4_x_r <= idx_4x4_x_r + 1 ;
                           end
        end
      endcase
    end
  end

  assign idx_4x4_x_done_w = idx_4x4_x_r==15 ;
  assign idx_4x4_y_done_w = idx_4x4_y_r==15 ;


//--- OUTPUT (ori) ---------------------
  assign ori_rd_ena_o   = cur_state_r!=IDLE ;
  assign ori_rd_siz_o   = `SIZE_04 ;
  assign ori_rd_4x4_x_o = idx_4x4_x_r ;
  assign ori_rd_4x4_y_o = idx_4x4_y_r ;
  assign ori_rd_idx_o   = 0 ;


//--- OUTPUT (buf) ---------------------
  // *_dly_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      val_dly_r       <= 0 ;
      cur_state_dly_r <= 0 ;
      idx_4x4_x_dly_r <= 0 ;
      idx_4x4_y_dly_r <= 0 ;
    end
    else begin
      val_dly_r       <= { val_dly_r       ,ori_rd_ena_o };
      cur_state_dly_r <= { cur_state_dly_r ,cur_state_r  };
      idx_4x4_x_dly_r <= { idx_4x4_x_dly_r ,idx_4x4_x_r  };
      idx_4x4_y_dly_r <= { idx_4x4_y_dly_r ,idx_4x4_y_r  };
    end
  end

  // fra_wr
  assign fra_wr_ena_o = val_dly_r[2-1] && ( (cur_state_dly_r[2*FSM_WD-1:1*FSM_WD]==POS_FRA) ? (idx_4x4_y_dly_r[2*4-1:1*4]==15) :
                                                                                              1'b0
                                          );
  assign fra_wr_adr_o = { ctu_x_cur_i
                         ,idx_4x4_x_dly_r[2*4-1:1*4] };
  always @(posedge clk or negedge rstn) begin
    if( !rstn ) begin
      fra_wr_dat_o <= {{(`PIXEL_WIDTH*4){1'b0}}} ;
    end
    else begin
      if( val_dly_r[1-1] ) begin
        fra_wr_dat_o <= {ori_rd_dat_i_a_3_0_w,ori_rd_dat_i_a_3_1_w,ori_rd_dat_i_a_3_2_w,ori_rd_dat_i_a_3_3_w};
      end
    end
  end

  // row_wr
  assign row_wr_ena_o = val_dly_r[2-1] && ( (cur_state_dly_r[2*FSM_WD-1:1*FSM_WD]==PRE) ? (idx_4x4_y_dly_r[2*4-1:1*4]!=15) :
                                                                                          1'b0
                                          );
  assign row_wr_adr_o = { idx_4x4_y_dly_r[2*4-1:1*4]
                         ,idx_4x4_x_dly_r[2*4-1:1*4] };
  always @(posedge clk or negedge rstn) begin
    if( !rstn ) begin
      row_wr_dat_o <= {{(`PIXEL_WIDTH*4){1'b0}}} ;
    end
    else begin
      if( val_dly_r[1-1] ) begin
        row_wr_dat_o <= {ori_rd_dat_i_a_3_0_w,ori_rd_dat_i_a_3_1_w,ori_rd_dat_i_a_3_2_w,ori_rd_dat_i_a_3_3_w};
      end
    end
  end

  // col_wr
  assign col_wr_ena_o = val_dly_r[2-1] && ( (cur_state_dly_r[2*FSM_WD-1:1*FSM_WD]==PRE    ) ? (idx_4x4_x_dly_r[2*4-1:1*4]!=15) :
                                            (cur_state_dly_r[2*FSM_WD-1:1*FSM_WD]==POS_COL) ? (idx_4x4_x_dly_r[2*4-1:1*4]==15) :
                                                                                              1'b0
                                          );
  assign col_wr_adr_o = { idx_4x4_x_dly_r[2*4-1:1*4]
                         ,idx_4x4_y_dly_r[2*4-1:1*4] };
  always @(posedge clk or negedge rstn) begin
    if( !rstn ) begin
      col_wr_dat_o <= {{(`PIXEL_WIDTH*4){1'b0}}} ;
    end
    else begin
      if( val_dly_r[1-1] ) begin
        col_wr_dat_o <= {ori_rd_dat_i_a_0_3_w,ori_rd_dat_i_a_1_3_w,ori_rd_dat_i_a_2_3_w,ori_rd_dat_i_a_3_3_w};
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
      done_o <= (cur_state_r!=IDLE)&&(nxt_state_w==IDLE) ;
    end
  end


//*** DEBUG ********************************************************************

`ifdef H265_DEBUG

`endif

endmodule
