//--------------------------------------------------------------------
//
//  Filename    : ime_ctrl.v
//  Author      : Huang Leilei
//  Created     : 2018-03-27
//  Description : control logic in ime module
//
//--------------------------------------------------------------------
`include "enc_defines.v"
module ime_ctrl(
  // global
  clk             ,
  rstn            ,
  // cfg_i
  cmd_num_i       ,
  cmd_dat_i       ,
  // ctrl_if
  start_i         ,
  done_o          ,
  // cfg_o
  center_x_o      ,
  center_y_o      ,
  length_x_o      ,
  length_y_o      ,
  slope_o         ,
  downsample_o    ,
  use_feedback_o  ,
  // ctrl_if (inner)
  start_adr_o     ,
  start_dec_o     ,
  start_dmp_o     ,
  done_adr_i      ,
  done_dec_i      ,
  done_dmp_i
  );


//*** PARAMETER ****************************************************************

  // global
  parameter     CMD_NUM_WIDTH            = 3                  ;

  // local
  localparam FSM_WD                      = 3                  ;
  localparam    IDLE                     = 3'd0               ;
  localparam    BUSY_ADR                 = 3'd1               ;
  localparam    BUSY_DEC                 = 3'd2               ;
  localparam    BUSY_DMP                 = 3'd3               ;
  localparam    UPDATE                   = 3'd4               ;

  // derived
  localparam    CMD_DAT_WIDTH_ONE        =(`IME_MV_WIDTH_X  )      // center_x_o
                                         +(`IME_MV_WIDTH_Y  )      // center_y_o
                                         +(`IME_MV_WIDTH_X-1)      // length_x_o
                                         +(`IME_MV_WIDTH_Y-1)      // length_y_o
                                         +(2                )      // slope_o
                                         +(1                )      // downsample_o
                                         +(1                )      // partition_r
                                         +(1                ) ;    // use_feedback_o
  localparam    CMD_DAT_WIDTH            = CMD_DAT_WIDTH_ONE
                                         *(1<<CMD_NUM_WIDTH ) ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                  clk                  ;
  input                                  rstn                 ;
  // cfg_i
  input        [CMD_NUM_WIDTH  -1 :0]    cmd_num_i            ;
  input        [CMD_DAT_WIDTH  -1 :0]    cmd_dat_i            ;
  // ctrl_if
  input                                  start_i              ;
  output reg                             done_o               ;
  // cfg_o
  output reg   [`IME_MV_WIDTH_X-1 :0]    center_x_o           ;
  output reg   [`IME_MV_WIDTH_Y-1 :0]    center_y_o           ;
  output reg   [`IME_MV_WIDTH_X-2 :0]    length_x_o           ;
  output reg   [`IME_MV_WIDTH_Y-2 :0]    length_y_o           ;
  output reg   [2              -1 :0]    slope_o              ;
  output reg                             downsample_o         ;
  output reg                             use_feedback_o       ;
  // ctrl_if (inner)
  output reg                             start_adr_o          ;
  output reg                             start_dec_o          ;
  output reg                             start_dmp_o          ;
  input                                  done_adr_i           ;
  input                                  done_dec_i           ;
  input                                  done_dmp_i           ;


//*** REG/WIRE ***************************************************************

  // fsm
  reg          [FSM_WD         -1 :0]    cur_state_r          ;
  reg          [FSM_WD         -1 :0]    nxt_state_w          ;
  wire                                   dec_done_w           ;
  wire                                   cmd_done_w           ;

  // cmd
  reg          [CMD_NUM_WIDTH  -1 :0]    cmd_cnt_r            ;
  reg                                    partition_r          ;


//*** MAIN BODY ****************************************************************

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
                                                 nxt_state_w = IDLE     ;
    case( cur_state_r )
      IDLE     : begin    if( start_i )          nxt_state_w = UPDATE   ;
                          else                   nxt_state_w = IDLE     ;
      end
      UPDATE   : begin                           nxt_state_w = BUSY_ADR ;
      end
      BUSY_ADR : begin    if( done_adr_i )       nxt_state_w = BUSY_DEC ;
                          else                   nxt_state_w = BUSY_ADR ;
      end
      BUSY_DEC : begin    if( dec_done_w )
                            if( cmd_done_w )     nxt_state_w = BUSY_DMP ;
                            else                 nxt_state_w = UPDATE   ;
                          else                   nxt_state_w = BUSY_DEC ;
      end
      BUSY_DMP : begin    if( done_dmp_i )       nxt_state_w = IDLE     ;
                          else                   nxt_state_w = BUSY_DMP ;
      end
    endcase
  end

  // jump condition
  assign cmd_done_w = cmd_cnt_r == cmd_num_i ;
  assign dec_done_w = done_dec_i || (!partition_r)&&(!cmd_done_w) ;    // force to do partition for the last command


//--- CMD ------------------------------
  // cmd_cnt_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cmd_cnt_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        IDLE     : begin    cmd_cnt_r <= 0 ;
        end
        BUSY_DEC : begin    if( dec_done_w ) begin
                              if( cmd_done_w ) begin
                                cmd_cnt_r <= 0 ;
                              end
                              else begin
                                cmd_cnt_r <= cmd_cnt_r + 1 ;
                              end
                            end
        end
      endcase
    end
  end

  // cfg_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      center_x_o     <= 0 ;
      center_y_o     <= 0 ;
      length_x_o     <= 0 ;
      length_y_o     <= 0 ;
      slope_o        <= 0 ;
      downsample_o   <= 0 ;
      partition_r    <= 0 ;
      use_feedback_o <= 0 ;
    end
    else begin
      if( cur_state_r==UPDATE ) begin
        { center_x_o
         ,center_y_o
         ,length_x_o
         ,length_y_o
         ,slope_o
         ,downsample_o
         ,partition_r
         ,use_feedback_o } <= cmd_dat_i>>(CMD_DAT_WIDTH_ONE*cmd_cnt_r) ;    // TODO : expand it later if necessary
      end
    end
  end


//--- CTRL -----------------------------
  // start & done
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      done_o      <= 0 ;
      start_adr_o <= 0 ;
      start_dec_o <= 0 ;
      start_dmp_o <= 0 ;
    end
    else begin
      if( cur_state_r!=nxt_state_w ) begin
        done_o      <= 0 ;
        start_adr_o <= 0 ;
        start_dec_o <= 0 ;
        case( nxt_state_w )
          IDLE     : done_o      <= 1 ;
          BUSY_ADR : start_adr_o <= 1 ;
          BUSY_DEC : start_dec_o <= partition_r||cmd_done_w ;    // force to do partition for the last command
          BUSY_DMP : start_dmp_o <= 1 ;
        endcase
      end
      else begin
        done_o      <= 0 ;
        start_adr_o <= 0 ;
        start_dec_o <= 0 ;
        start_dmp_o <= 0 ;
      end
    end
  end

endmodule
