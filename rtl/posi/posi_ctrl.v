//--------------------------------------------------------------------
//
//  Filename    : h265_posi_ctrl.v
//  Author      : Huang Leilei
//  Description : ctrl in module post intra
//  Created     : 2018-04-10
//
//--------------------------------------------------------------------

`include "./enc_defines.v"

module posi_ctrl(
  // global
  clk            ,
  rstn           ,
  // ctrl_if
  start_i        ,
  done_o         ,
  // cfg_i
  num_mode_i     ,
  // ctrl_if (inner)
  start_tra_o    ,
  start_ref_o    ,
  done_ref_i     ,
  done_tra_i     ,
  done_dec_i     ,
  // cfg_o
  tra_busy_o     ,
  tra_mode_o     ,
  size_o         ,
  position_o
  );


//*** PARAMETER ****************************************************************

  // global
  parameter  TRA_MODE_PRE   = 0              ;
  parameter  TRA_MODE_POS   = 1              ;

  // local
  localparam FSM_WD         = 4              ;
  localparam    IDLE        = 4'd0           ;
  localparam    TRA_PRE     = 4'd1           ;
  localparam    SIZE_04     = 4'd2           ;
  localparam    SIZE_08     = 4'd3           ;
  localparam    SIZE_16     = 4'd4           ;
  localparam    SIZE_32     = 4'd5           ;
  localparam    WAIT        = 4'd6           ;
  localparam    DECI        = 4'd7           ;
  localparam    TRA_POS     = 4'd8           ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                     clk              ;
  input                     rstn             ;
  // ctrl_if
  input                     start_i          ;
  output reg                done_o           ;
  // cfg_i
  input      [3   -1 :0]    num_mode_i       ;
  // ctrl_if (inner)
  output reg                start_tra_o      ;
  output reg                start_ref_o      ;
  input                     done_ref_i       ;
  input                     done_tra_i       ;
  input                     done_dec_i       ;
  // cfg_o
  output                    tra_busy_o       ;
  output                    tra_mode_o       ;
  output reg [2   -1 :0]    size_o           ;
  output     [8   -1 :0]    position_o       ;


//*** REG/WIRE *****************************************************************

  // fsm
  reg   [FSM_WD   -1 :0]    cur_state_r      ;
  reg   [FSM_WD   -1 :0]    nxt_state_w      ;
  reg   [8        -1 :0]    position_r       ;

  wire                      done_size_w      ;
  wire                      done_wait_w      ;

  wire                      ref_done_w       ;
  reg                       ref_done_r       ;

  wire                      pre_done_w       ;
  reg                       pre_done_r       ;
  reg   [3        -1 :0]    cnt_mode_r       ;
  wire                      cnt_mode_done_w  ;
  reg   [6        -1 :0]    cnt_trav_r       ;
  reg                       cnt_trav_done_w  ;

  reg   [5        -1 :0]    cnt_wait_r       ;
  reg                       cnt_wait_done_w  ;
  reg   [FSM_WD   -1 :0]    cur_state_d0_r   ;


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
                                                                 nxt_state_w = IDLE    ;
    case( cur_state_r )
      IDLE    : begin    if( start_i )                           nxt_state_w = TRA_PRE ;
                         else                                    nxt_state_w = IDLE    ;
      end
      TRA_PRE : begin    if( done_tra_i )                        nxt_state_w = SIZE_04 ;
                         else                                    nxt_state_w = TRA_PRE ;
      end
      SIZE_04 : begin    if( done_size_w ) begin
                           if( position_r[1:0]==2'b11 )          nxt_state_w = SIZE_08 ;
                           else                                  nxt_state_w = SIZE_04 ;
                         end
                         else                                    nxt_state_w = SIZE_04 ;
      end
      SIZE_08 : begin    if( done_size_w ) begin
                           if( position_r[3:0]==4'b1100 )        nxt_state_w = SIZE_16 ;
                           else                                  nxt_state_w = WAIT    ;
                         end
                         else                                    nxt_state_w = SIZE_08 ;
      end
      SIZE_16 : begin    if( done_size_w ) begin
                           if( position_r[5:0]==6'b110000 )      nxt_state_w = SIZE_32 ;
                           else                                  nxt_state_w = WAIT    ;
                         end
                         else                                    nxt_state_w = SIZE_16 ;
      end
      SIZE_32 : begin    if( done_size_w ) begin
                           if( position_r[7:0]==8'b11000000 )    nxt_state_w = DECI    ;
                           else                                  nxt_state_w = WAIT    ;
                         end
                         else                                    nxt_state_w = SIZE_32 ;
      end
      WAIT    : begin    if( done_wait_w )                       nxt_state_w = SIZE_04 ;
                         else                                    nxt_state_w = WAIT    ;
      end
      DECI    : begin    if( done_dec_i )                        nxt_state_w = TRA_POS ;
                         else                                    nxt_state_w = DECI    ;
      end
      TRA_POS : begin    if( done_tra_i )                        nxt_state_w = IDLE    ;
                         else                                    nxt_state_w = TRA_POS ;
      end
    endcase
  end

  // position_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      position_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        IDLE    : begin                                            position_r <= 0               ;
        end
        SIZE_04 : begin    if( done_size_w ) begin
                             if( position_r[1:0]==2'b11 )          position_r <= position_r - 03 ;
                             else                                  position_r <= position_r + 01 ;
                           end
        end
        SIZE_08 : begin    if( done_size_w ) begin
                             if( position_r[3:0]==4'b1100 )        position_r <= position_r - 12 ;
                             else                                  position_r <= position_r + 04 ;
                           end
        end
        SIZE_16 : begin    if( done_size_w ) begin
                             if( position_r[5:0]==6'b110000 )      position_r <= position_r - 48 ;
                             else                                  position_r <= position_r + 16 ;
                           end
        end
        SIZE_32 : begin    if( done_size_w ) begin
                             if( position_r[7:0]==8'b11000000 )    position_r <= 0 ;
                             else                                  position_r <= position_r + 64 ;
                           end
        end
      endcase
    end
  end

  // jump condition
  assign done_size_w = (ref_done_w||ref_done_r) && (pre_done_w||pre_done_r) ;
  assign done_wait_w = cnt_wait_done_w ;

  // ref_done_w
  assign ref_done_w = done_ref_i ;

  // ref_done_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_done_r <= 0 ;
    end
    else begin
      if( done_size_w ) begin
        ref_done_r <= 0 ;
      end
      else if( ref_done_w ) begin
        ref_done_r <= 1 ;
      end
    end
  end

  // cnt_mode_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_mode_r <= 0 ;
    end
    else begin
      if( (cur_state_r==SIZE_04)
        ||(cur_state_r==SIZE_08)
        ||(cur_state_r==SIZE_16)
        ||(cur_state_r==SIZE_32)
      ) begin
        if( !pre_done_r ) begin
          if( cnt_trav_done_w ) begin
            if( cnt_mode_done_w ) begin
              cnt_mode_r <= 0 ;
            end
            else begin
              cnt_mode_r <= cnt_mode_r + 1 ;
            end
          end
        end
      end
      else begin
        cnt_mode_r <= 0 ;
      end
    end
  end

  // cnt_mode_done_w
  assign cnt_mode_done_w = cnt_mode_r==num_mode_i ;

  // cnt_trav_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_trav_r <= 0 ;
    end
    else begin
      if( (cur_state_r==SIZE_04)
        ||(cur_state_r==SIZE_08)
        ||(cur_state_r==SIZE_16)
        ||(cur_state_r==SIZE_32)
      ) begin
        if( !pre_done_r ) begin
          if( cnt_trav_done_w ) begin
            cnt_trav_r <= 0 ;
          end
          else begin
            cnt_trav_r <= cnt_trav_r + 1 ;
          end
        end
      end
      else begin
        cnt_trav_r <= 0 ;
      end
    end
  end

  // cnt_trav_done_w
  always @(*) begin
                   cnt_trav_done_w = 0 ;
    case( cur_state_r )
      SIZE_04 :    cnt_trav_done_w = cnt_trav_r==(04*04/16-1) ;
      SIZE_08 :    cnt_trav_done_w = cnt_trav_r==(08*08/16-1) ;
      SIZE_16 :    cnt_trav_done_w = cnt_trav_r==(16*16/16-1) ;
      SIZE_32 :    cnt_trav_done_w = cnt_trav_r==(32*32/16-1) ;
    endcase
  end

  // pre_done_w
  assign pre_done_w = cnt_trav_done_w && cnt_mode_done_w ;

  // pre_done_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      pre_done_r <= 0 ;
    end
    else begin
      if( done_size_w ) begin
        pre_done_r <= 0 ;
      end
      else if( pre_done_w ) begin
        pre_done_r <= 1 ;
      end
    end
  end

  // cnt_wait_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_wait_r <= 0 ;
    end
    else begin
      if( cur_state_r==WAIT ) begin
        if( cnt_wait_done_w ) begin
          cnt_wait_r <= 0 ;
        end
        else begin
          cnt_wait_r <= cnt_wait_r + 1 ;
        end
      end
    end
  end

  // cnt_wait_done_w
  always @(*) begin
                   cnt_wait_done_w = 0 ;
    case( cur_state_d0_r )
      SIZE_08 :    cnt_wait_done_w = cnt_wait_r == (2-1)*2-1 ;
      SIZE_16 :    cnt_wait_done_w = cnt_wait_r == (4-1)*2   ; // (4-1)*2-1 ;
      SIZE_32 :    cnt_wait_done_w = cnt_wait_r == (8-1)*2   ; // (8-1)*2-1 ;
    endcase
  end

  // cur_state_d0_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_state_d0_r <= 0 ;
    end
    else begin
      if( (cur_state_r!=WAIT) && (nxt_state_w==WAIT) ) begin
        cur_state_d0_r <= cur_state_r ;
      end
    end
  end


//--- OUTPUT ---------------------------
  // tra_*_o
  assign tra_busy_o = (cur_state_r==TRA_PRE)
                    ||(cur_state_r==TRA_POS) ;
  assign tra_mode_o = (cur_state_r==TRA_PRE) ? TRA_MODE_PRE
                                             : TRA_MODE_POS ;

  // size_o
  always @(*) begin
                size_o = `SIZE_04 ;
    case( cur_state_r )
      SIZE_04 : size_o = `SIZE_04 ;
      SIZE_08 : size_o = `SIZE_08 ;
      SIZE_16 : size_o = `SIZE_16 ;
      SIZE_32 : size_o = `SIZE_32 ;
    endcase
  end

  // position_o
  assign position_o = position_r ;

  // start_tra_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      start_tra_o <= 0 ;
    end
    else begin
      start_tra_o <= ((cur_state_r!=TRA_PRE)&&(nxt_state_w==TRA_PRE))
                   ||((cur_state_r!=TRA_POS)&&(nxt_state_w==TRA_POS)) ;
    end
  end

  // start_ref_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      start_ref_o <= 0 ;
    end
    else begin
      start_ref_o <= done_tra_i &&(nxt_state_w!=IDLE)
                 || (done_size_w&&(nxt_state_w!=DECI)&&(nxt_state_w!=WAIT))
                 || (done_wait_w&&(nxt_state_w!=WAIT)) ;
    end
  end

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
