//-------------------------------------------------------------------
//
//  Filename      : mc_tq.v
//  Author        : Huang Leilei
//  Created       : 2017-12-24
//
//-------------------------------------------------------------------
//
//  Modified      : 2018-05-19 by HLL
//  Description   : latch removed
//  Modified      : 2018-05-21 by HLL
//  Description   : I block in P frame supported
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module mc_tq (
  // global
  clk               ,
  rstn              ,
  // ctrl_if
  start_i           ,
  done_o            ,
  // info_i
  sel_i             ,
  partition_i       ,
  // pre_bf
  fme_rd_ena_o      ,
  fme_rd_siz_o      ,
  fme_rd_4x4_x_o    ,
  fme_rd_4x4_y_o    ,
  fme_rd_idx_o      ,
  fme_rd_dat_i      ,
  // pre_af
  pre_wr_ena_o      ,
  pre_wr_sel_o      ,
  pre_wr_siz_o      ,
  pre_wr_4x4_x_o    ,
  pre_wr_4x4_y_o    ,
  pre_wr_dat_o      ,
  // rec_i
  rec_done_i
  );

//*** PARAMETER ****************************************************************

  parameter    IDLE                    = 0                    ;
  parameter    TRAN                    = 1                    ;
  parameter    WAIT                    = 2                    ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                clk                    ;
  input                                rstn                   ;
  // sys_if
  input                                start_i                ;
  output reg                           done_o                 ;
  // cfg_i
  input      [2              -1 :0]    sel_i                  ;
  input      [42             -1 :0]    partition_i            ;
  // pre_bf
  output                               fme_rd_ena_o           ;
  output     [2              -1 :0]    fme_rd_siz_o           ;
  output     [4              -1 :0]    fme_rd_4x4_x_o         ;
  output     [4              -1 :0]    fme_rd_4x4_y_o         ;
  output     [5              -1 :0]    fme_rd_idx_o           ;
  input      [32*`PIXEL_WIDTH-1 :0]    fme_rd_dat_i           ;
  // pre_af
  output reg                           pre_wr_ena_o           ;
  output     [2              -1 :0]    pre_wr_sel_o           ;
  output     [2              -1 :0]    pre_wr_siz_o           ;
  output reg [4              -1 :0]    pre_wr_4x4_x_o         ;
  output reg [4              -1 :0]    pre_wr_4x4_y_o         ;
  output     [`PIXEL_WIDTH*32-1 :0]    pre_wr_dat_o           ;
  // rec
  input                                rec_done_i             ;


//*** WIRE/REG *****************************************************************

  // fsm
  reg        [2              -1 :0]    cur_state_r            ;
  reg        [2              -1 :0]    nxt_state_w            ;

  reg                                  tra_done_w             ;
  reg                                  all_done_w             ;

  // cur
  reg        [2              -1 :0]    cur_size_r             ;
  reg        [2              -1 :0]    cur_size_of_luma_r     ;
  reg        [8              -1 :0]    cur_position_r         ;
  reg        [8              -1 :0]    cur_position_of_luma_r ;

  // nxt
  reg        [2              -1 :0]    nxt_size_w             ;
  reg        [2              -1 :0]    nxt_size_of_luma_w     ;
  reg        [8              -1 :0]    nxt_position_w         ;
  reg        [8              -1 :0]    nxt_position_of_luma_w ;
  wire                                 nxt_is_split_64_w      ;
  wire                                 nxt_is_split_32_w      ;
  wire                                 nxt_is_split_16_w      ;
  wire       [1*2            -1 :0]    nxt_partition_64_w     ;
  wire       [1*2            -1 :0]    nxt_partition_32_w     ;
  wire       [1*2            -1 :0]    nxt_partition_16_w     ;
  wire       [1*2            -1 :0]    all_partition_64_w     ;
  wire       [4*2            -1 :0]    all_partition_32_w     ;
  wire       [16*2           -1 :0]    all_partition_16_w     ;

  // output
  reg        [5              -1 :0]    tra_cnt_r              ;
  reg        [4              -1 :0]    cur_4x4_x_r            ;
  reg        [4              -1 :0]    cur_4x4_y_r            ;


//*** MAIN BODY ****************************************************************

//--- FSM ------------------------------
  // fsm
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_state_r <= IDLE ;
    end
    else begin
      cur_state_r <= nxt_state_w ;
    end
  end

  always @(*) begin
                                                nxt_state_w = IDLE ;
    case( cur_state_r )
      IDLE : begin    if( start_i )             nxt_state_w = TRAN ;
                      else                      nxt_state_w = IDLE ;
      end
      TRAN : begin    if( tra_done_w )          nxt_state_w = WAIT ;
                      else                      nxt_state_w = TRAN ;
      end
      WAIT : begin    if( rec_done_i ) begin
                        if( all_done_w )        nxt_state_w = IDLE ;
                        else                    nxt_state_w = TRAN ;
                      end
                      else                      nxt_state_w = WAIT ;
      end
    endcase
  end


//--- JUMP CONDITION -------------------
  // tra_done_w
  always @(*) begin
                 tra_done_w = 0 ;
    case( cur_size_r )
      `SIZE_04 : tra_done_w = (tra_cnt_r==0         ) ;
      `SIZE_08 : tra_done_w = (tra_cnt_r==8*8  /32-1) ;
      `SIZE_16 : tra_done_w = (tra_cnt_r==16*16/32-1) ;
      `SIZE_32 : tra_done_w = (tra_cnt_r==32*32/32-1) ;
    endcase
  end

  // all_done_w
  always @(*) begin
                 all_done_w = 0 ;
    case( cur_size_of_luma_r )
      `SIZE_08 : all_done_w = rec_done_i && (cur_position_of_luma_r==8'b1111_1100) ;
      `SIZE_16 : all_done_w = rec_done_i && (cur_position_of_luma_r==8'b1111_0000) ;
      `SIZE_32 : all_done_w = rec_done_i && (cur_position_of_luma_r==8'b1100_0000) ;
    endcase
  end


//--- CURRENT DATA ---------------------
  // cur_size_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_size_r <= 0 ;
    end
    else begin
      if( cur_state_r==IDLE ) begin
        if( start_i ) begin
          cur_size_r <= nxt_size_w ;
        end
      end
      else begin
        if( rec_done_i ) begin
          cur_size_r <= nxt_size_w ;
        end
      end
    end
  end

  // cur_size_of_luma_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_size_of_luma_r <= 0 ;
    end
    else begin
      if( cur_state_r==IDLE ) begin
        if( start_i ) begin
          cur_size_of_luma_r <= nxt_size_of_luma_w ;
        end
      end
      else begin
        if( rec_done_i ) begin
          cur_size_of_luma_r <= nxt_size_of_luma_w ;
        end
      end
    end
  end

  // cur_position_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_position_r <= 0 ;
    end
    else begin
      if( cur_state_r==IDLE ) begin
        cur_position_r <= 0 ;
      end
      else begin
        if( rec_done_i ) begin
          if( sel_i==`TYPE_Y ) begin
            cur_position_r <= nxt_position_of_luma_w ;
          end
          else begin
            cur_position_r <= (nxt_position_of_luma_w>>2) ;
          end
        end
      end
    end
  end

  // cur_position_of_luma_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_position_of_luma_r <= 0 ;
    end
    else begin
      if( cur_state_r==IDLE ) begin
        cur_position_of_luma_r <= 0 ;
      end
      else begin
        if( rec_done_i ) begin
          cur_position_of_luma_r <= nxt_position_of_luma_w ;
        end
      end
    end
  end


//--- NEXT DATA ------------------------
  // nxt_size_w
  always @(*) begin
      nxt_size_w = 0 ;
    if( sel_i==`TYPE_Y ) begin
      nxt_size_w = nxt_size_of_luma_w ;
    end
    else begin
      case( nxt_size_of_luma_w )
        `SIZE_08 : nxt_size_w = `SIZE_04 ;
        `SIZE_16 : nxt_size_w = `SIZE_08 ;
        `SIZE_32 : nxt_size_w = `SIZE_16 ;
      endcase
    end
  end

  // nxt_size_of_luma_w
  always @(*) begin
      nxt_size_of_luma_w = 0 ;
    if( !nxt_is_split_64_w ) begin
      nxt_size_of_luma_w = `SIZE_32 ;
    end
    else if( !nxt_is_split_32_w ) begin
      nxt_size_of_luma_w = `SIZE_32 ;
    end
    else if( !nxt_is_split_16_w ) begin
      nxt_size_of_luma_w = `SIZE_16 ;
    end
    else begin
      nxt_size_of_luma_w = `SIZE_08 ;
    end
  end

  // nxt_position_w
  always @(*) begin
    if( sel_i )
      nxt_position_w = 0 ;
    if( cur_state_r==IDLE ) begin
      nxt_position_w = 0 ;
    end
    else begin
      if( sel_i==`TYPE_Y ) begin
        nxt_position_w = nxt_position_of_luma_w ;
      end
      else begin
        nxt_position_w = (nxt_position_of_luma_w>>2) ;
      end
    end
  end

  // nxt_position_of_luma_w
  always @(*) begin
      nxt_position_of_luma_w = 0 ;
    if( cur_state_r==IDLE ) begin
      nxt_position_of_luma_w = 0 ;
    end
    else begin
      case( cur_size_of_luma_r )
        `SIZE_08 : nxt_position_of_luma_w = cur_position_of_luma_r + 4  ;
        `SIZE_16 : nxt_position_of_luma_w = cur_position_of_luma_r + 16 ;
        `SIZE_32 : nxt_position_of_luma_w = cur_position_of_luma_r + 64 ;
      endcase
    end
  end

  // is_split_nxt
  assign nxt_is_split_64_w = ( nxt_partition_64_w == `PART_SPLIT );
  assign nxt_is_split_32_w = ( nxt_partition_32_w == `PART_SPLIT );
  assign nxt_is_split_16_w = ( nxt_partition_16_w == `PART_SPLIT );

  assign nxt_partition_64_w = all_partition_64_w ;
  assign nxt_partition_32_w = all_partition_32_w >> ((nxt_position_of_luma_w>>6)*2) ;
  assign nxt_partition_16_w = all_partition_16_w >> ((nxt_position_of_luma_w>>4)*2) ;

  assign {all_partition_16_w, all_partition_32_w, all_partition_64_w} = partition_i ;


//--- CTRL IF --------------------------
  // done_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      done_o <= 0 ;
    end
    else begin
      done_o <= all_done_w ;
    end
  end


//--- TRANSFER -------------------------
  // tra_cnt_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      tra_cnt_r <= 0 ;
    end
    else begin
      if( cur_state_r==TRAN ) begin
        if( tra_done_w ) begin
          tra_cnt_r <= 0 ;
        end
        else begin
          tra_cnt_r <= tra_cnt_r + 1 ;
        end
      end
      else begin
        tra_cnt_r <= 0 ;
      end
    end
  end

  // pred_*_o
  assign fme_rd_ena_o   = (cur_state_r==TRAN) ;
  assign fme_rd_siz_o   = (cur_size_r==`SIZE_04) ? `SIZE_04    : `SIZE_08                ;
  assign fme_rd_4x4_x_o = (cur_size_r==`SIZE_04) ? cur_4x4_x_r : {cur_4x4_x_r[3:1],1'b0} ;
  assign fme_rd_4x4_y_o = (cur_size_r==`SIZE_04) ? cur_4x4_y_r : {cur_4x4_y_r[3:1],1'b0} ;
  assign fme_rd_idx_o   = (cur_size_r==`SIZE_04) ? 0           : (cur_4x4_y_r[0]<<2)     ;

  // pred_4x4_x/y_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_4x4_x_r <= 0 ;
      cur_4x4_y_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        IDLE : begin    if( start_i ) begin
                          cur_4x4_x_r <= {nxt_position_w[6],nxt_position_w[4],nxt_position_w[2],nxt_position_w[0]} ;
                          cur_4x4_y_r <= {nxt_position_w[7],nxt_position_w[5],nxt_position_w[3],nxt_position_w[1]} ;
                        end
        end
        TRAN : begin    case( cur_size_r )
                          `SIZE_08 : begin    if( tra_done_w ) begin
                                                cur_4x4_x_r <= {cur_position_r[6],cur_position_r[4],cur_position_r[2],cur_position_r[0]} ;
                                                cur_4x4_y_r <= {cur_position_r[7],cur_position_r[5],cur_position_r[3],cur_position_r[1]} ;
                                              end
                                              else begin
                                                cur_4x4_y_r <= cur_4x4_y_r   + 1 ;
                                              end
                          end
                          `SIZE_16 : begin    if( tra_done_w ) begin
                                                cur_4x4_x_r <= {cur_position_r[6],cur_position_r[4],cur_position_r[2],cur_position_r[0]} ;
                                                cur_4x4_y_r <= {cur_position_r[7],cur_position_r[5],cur_position_r[3],cur_position_r[1]} ;
                                              end
                                              else begin
                                                if( cur_4x4_x_r[1:0]==2'b10 ) begin
                                                  cur_4x4_x_r <= {cur_position_r[6],cur_position_r[4],cur_position_r[2],cur_position_r[0]} ;
                                                  cur_4x4_y_r <= cur_4x4_y_r   + 1 ;
                                                end
                                                else begin
                                                  cur_4x4_x_r <= cur_4x4_x_r + 2 ;
                                                end
                                              end
                          end
                          `SIZE_32 : begin    if( tra_done_w ) begin
                                                cur_4x4_x_r <= {cur_position_r[6],cur_position_r[4],cur_position_r[2],cur_position_r[0]} ;
                                                cur_4x4_y_r <= {cur_position_r[7],cur_position_r[5],cur_position_r[3],cur_position_r[1]} ;
                                              end
                                              else begin
                                                if( cur_4x4_x_r[2:0]==3'b110 ) begin
                                                  cur_4x4_x_r <= {cur_position_r[6],cur_position_r[4],cur_position_r[2],cur_position_r[0]} ;
                                                  cur_4x4_y_r <= cur_4x4_y_r   + 1 ;
                                                end
                                                else begin
                                                  cur_4x4_x_r <= cur_4x4_x_r + 2 ;
                                                end
                                              end
                          end
                        endcase
        end
        WAIT : begin    if( rec_done_i ) begin
                          cur_4x4_x_r <= {nxt_position_w[6],nxt_position_w[4],nxt_position_w[2],nxt_position_w[0]} ;
                          cur_4x4_y_r <= {nxt_position_w[7],nxt_position_w[5],nxt_position_w[3],nxt_position_w[1]} ;
                        end
        end
      endcase
    end
  end

  // pre_af
  assign pre_wr_sel_o = sel_i        ;
  assign pre_wr_siz_o = cur_size_r   ;
  assign pre_wr_dat_o = fme_rd_dat_i ;

  always @(posedge clk or negedge rstn) begin
    if( !rstn ) begin
      pre_wr_ena_o   <= 0 ;
      pre_wr_4x4_x_o <= 0 ;
      pre_wr_4x4_y_o <= 0 ;
    end
    else begin
      pre_wr_ena_o   <= fme_rd_ena_o ;
      pre_wr_4x4_x_o <= cur_4x4_x_r  ;
      pre_wr_4x4_y_o <= cur_4x4_y_r  ;
    end
  end

endmodule
