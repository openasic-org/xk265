//--------------------------------------------------------------------
//
//  Filename    : ime_transfer.v
//  Author      : Huang Leilei
//  Created     : 2018-06-18
//  Description : transfer logic in ime module
//
//--------------------------------------------------------------------
//
//        |                     read                   |               write
// -------+--------------------------------------------+-------------------------------
//        |                                            |     0          63         127
//        |                                            |   0 +-----+-----+-----+-----+
//        |                                            |     |  0' |  2' |  4' |  6' |
//        |     0          63         127         191  |     |     |     |     |     |
//        |   0 +-----+-----+-----+-----+-----+-----+  |     +-----+-----+-----+-----+
//        |     |  0  |  1  |  8  |  9  | 16  | 17  |  |     |  1' |  3' |  5' |  7' |
//        |     |     |     |     |     |     |     |  |     |     |     |     |     |
//        |     +-----+-----+-----+-----+-----+-----+  |  63 +-----+-----+-----+-----+
//        |     |  2  |  3  | 10  | 11  | 18  | 19  |  |     |  8' | 10' | 12' | 14' |
//        |     |     |     |     |     |     |     |  |     |     |     |     |     |
//  shape |  63 +-----+-----+-----+-----+-----+-----+  |     +-----+-----+-----+-----+
//        |     |  4  |  5  | 12  | 13  | 20  | 21  |  |     |  9' | 11' | 13' | 15' |
//        |     |     |     |     |     |     |     |  |     |     |     |     |     |
//        |     +-----+-----+-----+-----+-----+-----+  | 127 +-----+-----+-----+-----+
//        |     |  6  |  7  | 14  | 15  | 22  | 23  |  |     | 16' | 18' | 20' | 22' |
//        |     |     |     |     |     |     |     |  |     |     |     |     |     |
//        | 127 +-----+-----+-----+-----+-----+-----+  |     +-----+-----+-----+-----+
//        |                                            |     | 17' | 19' | 21' | 23' |
//        |                                            |     |     |     |     |     |
//        |                                            | 191 +-----+-----+-----+-----+
// -------+--------------------------------------------+-------------------------------
//  block |                     64*128                 |              128*64
// -------+--------------------------------------------+-------------------------------
//  quad  |                     32*32                  |               32*32
// -------+--------------------------------------------+-------------------------------
//  line  |                     32*1                   |               32*1
//
//--------------------------------------------------------------------
`include "enc_defines.v"
module ime_transfer(
  // global
  clk               ,
  rstn              ,
  // ctrl_if
  start_i           ,
  ctu_x_cur_i       ,
  done_o            ,
  busy_o            ,
  // ref_rd
  ref_rd_dir_o      ,
  ref_rd_ena_o      ,
  ref_rd_adr_x_o    ,
  ref_rd_adr_y_o    ,
  // ref_wr
  ref_wr_dir_o      ,
  ref_wr_ena_o      ,
  ref_wr_adr_x_o    ,
  ref_wr_adr_y_o
  );


//*** PARAMETER ****************************************************************

  localparam FSM_WD                    = 2              ;
  localparam    IDLE                   = 2'd0           ;
  localparam    PRE                    = 2'd1           ;
  localparam    BUSY                   = 2'd2           ;
  localparam    POST                   = 2'd3           ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                clk              ;
  input                                rstn             ;
  // ctrl_if
  input                                start_i          ;
  input      [`PIC_X_WIDTH   -1 :0]    ctu_x_cur_i      ;
  output reg                           done_o           ;
  output                               busy_o           ;
  // ref_rd
  output reg [2              -1 :0]    ref_rd_dir_o     ;
  output reg                           ref_rd_ena_o     ;
  output reg [`IME_MV_WIDTH_X   :0]    ref_rd_adr_x_o   ;
  output reg [`IME_MV_WIDTH_Y   :0]    ref_rd_adr_y_o   ;
  // ref_wr
  output reg [2              -1 :0]    ref_wr_dir_o     ;
  output reg                           ref_wr_ena_o     ;
  output reg [`IME_MV_WIDTH_Y   :0]    ref_wr_adr_x_o   ;
  output reg [`IME_MV_WIDTH_X   :0]    ref_wr_adr_y_o   ;


//*** REG/WIRE ***************************************************************

  // fsm
  reg        [FSM_WD         -1 :0]    cur_state_r      ;
  reg        [FSM_WD         -1 :0]    nxt_state_w      ;

  wire                                 pre_done_w       ;
  wire                                 busy_done_w      ;
  wire                                 post_done_w      ;

  // rd_cnt
  reg        [5             -1 :0]     rd_lin_cnt_r     ;
  reg        [1             -1 :0]     rd_qua_x_cnt_r   ;
  reg        [2             -1 :0]     rd_qua_y_cnt_r   ;
  reg        [2             -1 :0]     rd_blk_cnt_r     ;
  wire                                 rd_lin_done_w    ;
  wire                                 rd_qua_x_done_w  ;
  wire                                 rd_qua_y_done_w  ;
  wire                                 rd_blk_done_w    ;

  // wr_cnt
  reg        [5             -1 :0]     wr_lin_cnt_r     ;
  reg        [2             -1 :0]     wr_qua_x_cnt_r   ;
  reg        [1             -1 :0]     wr_qua_y_cnt_r   ;
  reg        [2             -1 :0]     wr_blk_cnt_r     ;
  wire                                 wr_lin_done_w    ;
  wire                                 wr_qua_x_done_w  ;
  wire                                 wr_qua_y_done_w  ;
  wire                                 wr_blk_done_w    ;

  reg        [2              -1 :0]    ref_rd_dir_r     ;
  reg        [2              -1 :0]    ref_wr_dir_r     ;


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
                                           nxt_state_w = IDLE ;
    case( cur_state_r )
      IDLE : begin    if( start_i )        nxt_state_w = PRE  ;
                      else                 nxt_state_w = IDLE ;
      end
      PRE  : begin    if( pre_done_w )     nxt_state_w = BUSY ;
                      else                 nxt_state_w = PRE  ;
      end
      BUSY : begin    if( busy_done_w )    nxt_state_w = POST ;
                      else                 nxt_state_w = BUSY ;
      end
      POST : begin    if( post_done_w )    nxt_state_w = IDLE ;
                      else                 nxt_state_w = POST ;
      end
    endcase
  end

  // jump condition
  assign pre_done_w  = rd_lin_done_w ;
  assign busy_done_w = rd_lin_done_w && rd_qua_x_done_w && rd_qua_y_done_w && rd_blk_done_w ;
  assign post_done_w = wr_lin_done_w ;


//--- READ COUNTER ---------------------
  // rd_lin_cnt & its done signal
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_lin_cnt_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        PRE  ,
        BUSY : begin    if( rd_lin_done_w ) begin
                          rd_lin_cnt_r <= 0 ;
                        end
                        else begin
                          rd_lin_cnt_r <= rd_lin_cnt_r + 1 ;
                        end
        end
      endcase
    end
  end

  assign rd_lin_done_w = rd_lin_cnt_r == 31 ;

  // rd_qua_x_cnt & its_done_signal
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_qua_x_cnt_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        PRE  ,
        BUSY : begin    if( rd_lin_done_w ) begin
                          if( rd_qua_x_done_w ) begin
                            rd_qua_x_cnt_r <= 0  ;
                          end
                          else begin
                            rd_qua_x_cnt_r <= rd_qua_x_cnt_r + 1 ;
                          end
                        end
        end
      endcase
    end
  end

  assign rd_qua_x_done_w = rd_qua_x_cnt_r == 1 ;

  // rd_qua_y_cnt & its_done_signal
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_qua_y_cnt_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        PRE  ,
        BUSY : begin    if( rd_lin_done_w && rd_qua_x_done_w ) begin
                          if( rd_qua_y_done_w ) begin
                            rd_qua_y_cnt_r <= 0  ;
                          end
                          else begin
                            rd_qua_y_cnt_r <= rd_qua_y_cnt_r + 1 ;
                          end
                        end
        end
      endcase
    end
  end

  assign rd_qua_y_done_w = rd_qua_y_cnt_r == 3 ;

  // rd_blk_cnt & its done signal
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_blk_cnt_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        IDLE : begin    if( start_i ) begin
                          if( ctu_x_cur_i==0 ) begin
                            rd_blk_cnt_r <= 0 ;
                          end
                          else begin
                            rd_blk_cnt_r <= 2 ;
                          end
                        end
        end
        PRE  ,
        BUSY : begin    if( rd_lin_done_w && rd_qua_x_done_w && rd_qua_y_done_w ) begin
                          if( rd_blk_done_w ) begin
                            rd_blk_cnt_r <= 0 ;
                          end
                          else begin
                            rd_blk_cnt_r <= rd_blk_cnt_r + 1 ;
                          end
                        end
        end
      endcase
    end
  end

  assign rd_blk_done_w = rd_blk_cnt_r == 2 ;


//--- REF READ -------------------------
  // ref_rd_dir_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_rd_dir_r <= `IME_DIR_DOWN ;
    end
    else begin
      if( rd_lin_done_w ) begin
        case( ref_rd_dir_r )
          `IME_DIR_DOWN  :    ref_rd_dir_r <= `IME_DIR_RIGHT ;
          `IME_DIR_RIGHT :    ref_rd_dir_r <= `IME_DIR_DOWN  ;
        endcase
      end
    end
  end

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_rd_dir_o <= `IME_DIR_DOWN ;
    end
    else begin
      ref_rd_dir_o <= ref_rd_dir_r ;
    end
  end

  // ref_rd_ena_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_rd_ena_o <= 0 ;
    end
    else begin
      ref_rd_ena_o <= cur_state_r != IDLE ;
    end
  end

  // ref_rd_adr_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_rd_adr_x_o <= 0 ;
      ref_rd_adr_y_o <= 0 ;
    end
    else begin
      if( (cur_state_r==PRE) || (cur_state_r==BUSY) ) begin
        ref_rd_adr_x_o <= rd_blk_cnt_r*64 + rd_qua_x_cnt_r*32                ;
        ref_rd_adr_y_o <=                   rd_qua_y_cnt_r*32 + rd_lin_cnt_r ;
      end
      else begin
        ref_rd_adr_x_o <= 0 ;
        ref_rd_adr_y_o <= 0 ;
      end
    end
  end


//--- WRITE COUNTER ---------------------
  // wr_lin_cnt & its done signal
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      wr_lin_cnt_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        BUSY ,
        POST : begin    if( wr_lin_done_w ) begin
                          wr_lin_cnt_r <= 0 ;
                        end
                        else begin
                          wr_lin_cnt_r <= wr_lin_cnt_r + 1 ;
                        end
        end
      endcase
    end
  end

  assign wr_lin_done_w = wr_lin_cnt_r == 31 ;

  // wr_qua_y_cnt & its_done_signal
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      wr_qua_y_cnt_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        BUSY ,
        POST : begin    if( wr_lin_done_w ) begin
                          if( wr_qua_y_done_w ) begin
                            wr_qua_y_cnt_r <= 0  ;
                          end
                          else begin
                            wr_qua_y_cnt_r <= wr_qua_y_cnt_r + 1 ;
                          end
                        end
        end
      endcase
    end
  end

  assign wr_qua_y_done_w = wr_qua_y_cnt_r == 1 ;

  // wr_qua_x_cnt & its_done_signal
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      wr_qua_x_cnt_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        BUSY ,
        POST : begin    if( wr_lin_done_w && wr_qua_y_done_w ) begin
                          if( wr_qua_x_done_w ) begin
                            wr_qua_x_cnt_r <= 0  ;
                          end
                          else begin
                            wr_qua_x_cnt_r <= wr_qua_x_cnt_r + 1 ;
                          end
                        end
        end
      endcase
    end
  end

  assign wr_qua_x_done_w = wr_qua_x_cnt_r == 3 ;

  // wr_blk_cnt & its done signal
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      wr_blk_cnt_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        IDLE : begin    if( start_i ) begin
                          if( ctu_x_cur_i==0 ) begin
                            wr_blk_cnt_r <= 0 ;
                          end
                          else begin
                            wr_blk_cnt_r <= 2 ;
                          end
                        end
        end
        BUSY ,
        POST : begin    if( wr_lin_done_w && wr_qua_y_done_w && wr_qua_x_done_w ) begin
                          if( wr_blk_done_w ) begin
                            wr_blk_cnt_r <= 0 ;
                          end
                          else begin
                            wr_blk_cnt_r <= wr_blk_cnt_r + 1 ;
                          end
                        end
        end
      endcase
    end
  end

  assign wr_blk_done_w = wr_blk_cnt_r == 2 ;


//--- REF READ -------------------------
  // ref_wr_dir_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_wr_dir_r <= `IME_DIR_RIGHT ;
    end
    else begin
      if( wr_lin_done_w ) begin
        case( ref_wr_dir_r )
          `IME_DIR_DOWN  :    ref_wr_dir_r <= `IME_DIR_RIGHT ;
          `IME_DIR_RIGHT :    ref_wr_dir_r <= `IME_DIR_DOWN  ;
        endcase
      end
    end
  end

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_wr_dir_o <= `IME_DIR_RIGHT ;
    end
    else begin
      ref_wr_dir_o <= ref_wr_dir_r ;
    end
  end

  // ref_wr_ena_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_wr_ena_o <= 0 ;
    end
    else begin
      ref_wr_ena_o <= (cur_state_r==BUSY) || (cur_state_r==POST) ;
    end
  end

  // ref_wr_adr_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_wr_adr_x_o <= 0 ;
      ref_wr_adr_y_o <= 0 ;
    end
    else begin
      if( (cur_state_r==BUSY) || (cur_state_r==POST) ) begin
        ref_wr_adr_x_o <=                   wr_qua_x_cnt_r*32                ;
        ref_wr_adr_y_o <= wr_blk_cnt_r*64 + wr_qua_y_cnt_r*32 + wr_lin_cnt_r ;
      end
      else begin
        ref_wr_adr_x_o <= 0 ;
        ref_wr_adr_y_o <= 0 ;
      end
    end
  end


//--- OUTPUT ---------------------------
  // busy
  assign busy_o = cur_state_r != IDLE ;

  // done
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      done_o <= 0 ;
    end
    else begin
      done_o <= (cur_state_r!=IDLE) && (nxt_state_w==IDLE) ;
    end
  end

endmodule
