//--------------------------------------------------------------------
//
//  Filename    : intra_ctrl.v
//  Author      : Huang Leilei
//  Description : control logic in intra
//  Created     : 2017-11-26
//
//--------------------------------------------------------------------
//
//  Modified      : 2017-12-24 by HLL
//  Description   : chroma supported
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module intra_ctrl(
  // global
  clk                ,
  rstn               ,
  // ctrl_if
  start_i            ,
  done_o             ,
  // pt_i
  partition_i        ,
  // md_i
  md_cena_o          ,
  md_addr_o          ,
  md_data_i          ,
  // info_o
  loop_sel_o         ,
  loop_size_o        ,
  loop_mode_o        ,
  loop_position_o    ,
  // ref_if
  ref_start_o        ,
  ref_done_i         ,
  ref_ready_i        ,
  // pre_o
  pre_start_o        ,
  pre_4x4_x_o        ,
  pre_4x4_y_o
  );


//*** PARAMETER ****************************************************************

  // local
  localparam    IDLE       = 0                    ;
  localparam    ENC_Y      = 1                    ;
  localparam    ENC_U      = 2                    ;
  localparam    ENC_V      = 3                    ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  // global
  input                    clk                    ;
  input                    rstn                   ;
  // ctrl
  input                    start_i                ;
  output reg               done_o                 ;
  // conf
  input      [85 -1 :0]    partition_i            ;
  // mode
  output reg               md_cena_o              ;
  output reg [8  -1 :0]    md_addr_o              ;    // 341 > 256 = 2^8
  input      [6  -1 :0]    md_data_i              ;
  // info
  output     [2  -1 :0]    loop_sel_o             ;
  output     [2  -1 :0]    loop_size_o            ;
  output     [6  -1 :0]    loop_mode_o            ;
  output     [8  -1 :0]    loop_position_o        ;
  // ref_if
  output reg               ref_start_o            ;
  input                    ref_done_i             ;
  input                    ref_ready_i            ;
  // pre_o
  output reg               pre_start_o            ;
  output reg [4  -1 :0]    pre_4x4_x_o            ;
  output reg [4  -1 :0]    pre_4x4_y_o            ;


//*** REG/WIRE *****************************************************************

  // state
  reg        [2  -1 :0]    cur_state_r            ;
  reg        [2  -1 :0]    nxt_state_w            ;

  // jump condition
  reg        [8  -1 :0]    cur_position_of_luma_r ;
  reg        [8  -1 :0]    nxt_position_of_luma_w ;
  reg        [2  -1 :0]    cur_size_of_luma_r     ;
  reg        [2  -1 :0]    nxt_size_of_luma_w     ;
  reg        [2  -1 :0]    nxt_size_of_luma_true_w;
  wire                     partition_64_w         ;
  wire       [4  -1 :0]    partition_32_w         ;
  wire       [16 -1 :0]    partition_16_w         ;
  wire       [64 -1 :0]    partition_08_w         ;
  wire                     is_32_split_w          ;
  wire                     is_16_split_w          ;
  wire                     is_08_split_w          ;

  // ctrl
  wire                     done_w                 ;

  // info
  reg        [2  -1 :0]    cur_size_r             ;
  reg        [2  -1 :0]    cur_sel_r              ;
  reg        [8  -1 :0]    cur_position_r         ;
  reg        [6  -1 :0]    cur_mode_r             ;
  reg                      md_cena_r              ;

  // prediction
  reg        [5  -1 :0]    pre_cnt_r              ;


//*** MAIN BODY ****************************************************************

//--- FSM ------------------------------
  // cur_state_r
  always @(posedge clk or negedge rstn ) begin
    if(!rstn)
      cur_state_r <= IDLE ;
    else begin
      cur_state_r <= nxt_state_w ;
    end
  end

  // nxt_state_w
  always @(*) begin
                       nxt_state_w = IDLE ;
    case( cur_state_r )
      IDLE  : begin    if( start_i ) begin
                         nxt_state_w = ENC_Y ;
                       end
                       else begin
                         nxt_state_w = IDLE ;
                       end
      end
      ENC_Y: begin    if( ref_done_i && ( ((cur_position_of_luma_r==8'b1111_1111)&&(cur_size_of_luma_r==`SIZE_04))
                                        ||((cur_position_of_luma_r==8'b1111_1100)&&(cur_size_of_luma_r==`SIZE_08))
                                        ||((cur_position_of_luma_r==8'b1111_0000)&&(cur_size_of_luma_r==`SIZE_16))
                                        ||((cur_position_of_luma_r==8'b1100_0000)&&(cur_size_of_luma_r==`SIZE_32))
                                        )
                       ) begin
                         nxt_state_w = ENC_U ;
                       end
                       else begin
                         nxt_state_w = ENC_Y ;
                       end
      end
      ENC_U: begin    if( ref_done_i && ( ((cur_position_of_luma_r==8'b1111_1100)&&(cur_size_of_luma_r==`SIZE_08))
                                        ||((cur_position_of_luma_r==8'b1111_0000)&&(cur_size_of_luma_r==`SIZE_16))
                                        ||((cur_position_of_luma_r==8'b1100_0000)&&(cur_size_of_luma_r==`SIZE_32))
                                        )
                       ) begin
                         nxt_state_w = ENC_V ;
                       end
                       else begin
                         nxt_state_w = ENC_U ;
                       end
      end
      ENC_V: begin    if( ref_done_i && ( ((cur_position_of_luma_r==8'b1111_1100)&&(cur_size_of_luma_r==`SIZE_08))
                                        ||((cur_position_of_luma_r==8'b1111_0000)&&(cur_size_of_luma_r==`SIZE_16))
                                        ||((cur_position_of_luma_r==8'b1100_0000)&&(cur_size_of_luma_r==`SIZE_32))
                                        )
                       ) begin
                         nxt_state_w = IDLE ;
                       end
                       else begin
                         nxt_state_w = ENC_V ;
                       end
      end
    endcase
  end


//--- JUMP CONDITION -------------------
  // cur_position_of_luma_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_position_of_luma_r <= 0 ;
    end
    else begin
      if( cur_state_r==IDLE ) begin
        if( start_i==1 ) begin
          cur_position_of_luma_r <= 0 ;
        end
      end
      else begin
        if( ref_done_i ) begin
          cur_position_of_luma_r <= nxt_position_of_luma_w ;
        end
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
        `SIZE_04 :    nxt_position_of_luma_w = cur_position_of_luma_r + 1  ;
        `SIZE_08 :    nxt_position_of_luma_w = cur_position_of_luma_r + 4  ;
        `SIZE_16 :    nxt_position_of_luma_w = cur_position_of_luma_r + 16 ;
        `SIZE_32 :    nxt_position_of_luma_w = cur_position_of_luma_r + 64 ;
      endcase
    end
  end

  // cur_size_of_luma_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_size_of_luma_r <= 0 ;
    end
    else begin
      if( cur_state_r==IDLE ) begin
        if( start_i==1 ) begin
          cur_size_of_luma_r <= nxt_size_of_luma_w ;
        end
      end
      else begin
        if( ref_done_i ) begin
          cur_size_of_luma_r <= nxt_size_of_luma_w ;
        end
      end
    end
  end

  // nxt_size_of_luma_w: MAY NEED REGISTERING
  always @(*) begin
    if( !is_32_split_w ) begin
      nxt_size_of_luma_w = `SIZE_32 ;
    end
    else if( !is_16_split_w ) begin
      nxt_size_of_luma_w = `SIZE_16 ;
    end
    else if( !is_08_split_w )begin
      nxt_size_of_luma_w = `SIZE_08 ;
    end
    else begin
      if( ( (cur_state_r==IDLE )                              )
        ||( (cur_state_r==ENC_Y)&&(nxt_position_of_luma_w!=0) )
      ) begin
        nxt_size_of_luma_w = `SIZE_04 ;
      end
      else begin
        nxt_size_of_luma_w = `SIZE_08 ;
      end
    end
  end

  // nxt_size_of_luma_true_w: MAY NEED REGISTERING
  always @(*) begin
    if( !is_32_split_w ) begin
      nxt_size_of_luma_true_w = `SIZE_32 ;
    end
    else if( !is_16_split_w ) begin
      nxt_size_of_luma_true_w = `SIZE_16 ;
    end
    else if( !is_08_split_w )begin
      nxt_size_of_luma_true_w = `SIZE_08 ;
    end
    else begin
      nxt_size_of_luma_true_w = `SIZE_04 ;
    end
  end

  // is_split_w
  assign is_32_split_w = partition_32_w >> (nxt_position_of_luma_w>>6) ;
  assign is_16_split_w = partition_16_w >> (nxt_position_of_luma_w>>4) ;
  assign is_08_split_w = partition_08_w >> (nxt_position_of_luma_w>>2) ;

  // partition_w
  assign { partition_08_w ,partition_16_w ,partition_32_w ,partition_64_w } = partition_i ;


//--- CTRL -----------------------------
  // done_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      done_o <= 0 ;
    end
    else begin
      done_o <= done_w ;
    end
  end

  assign done_w = (cur_state_r==ENC_V) && (nxt_state_w==IDLE) ;


//--- MODE -----------------------------
  // md_cena_o
  always @(posedge clk or negedge rstn  ) begin
    if( !rstn ) begin
      md_cena_o <= 0 ;
    end
    else begin
      md_cena_o <= ( start_i || (ref_done_i&&(!done_w)) );
    end
  end

  // md_addr_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      md_addr_o <= 0 ;
    else begin
      if( cur_state_r==IDLE ) begin
        if( start_i ) begin
          md_addr_o <= nxt_position_of_luma_w ;
                       // { nxt_position_of_luma_w[7]
                       //  ,nxt_position_of_luma_w[5]
                       //  ,nxt_position_of_luma_w[3]
                       //  ,nxt_position_of_luma_w[1]
                       //  ,nxt_position_of_luma_w[6]
                       //  ,nxt_position_of_luma_w[4]
                       //  ,nxt_position_of_luma_w[2]
                       //  ,nxt_position_of_luma_w[0] };
        end
      end
      else begin
        if( ref_done_i ) begin
          md_addr_o <= nxt_position_of_luma_w ;
                       // { nxt_position_of_luma_w[7]
                       //  ,nxt_position_of_luma_w[5]
                       //  ,nxt_position_of_luma_w[3]
                       //  ,nxt_position_of_luma_w[1]
                       //  ,nxt_position_of_luma_w[6]
                       //  ,nxt_position_of_luma_w[4]
                       //  ,nxt_position_of_luma_w[2]
                       //  ,nxt_position_of_luma_w[0] };
        end
      end
    end
  end


//--- INFO -----------------------------
  // assignment
  assign loop_sel_o      = cur_sel_r      ;
  assign loop_size_o     = cur_size_r     ;
  assign loop_mode_o     = cur_mode_r     ;
  assign loop_position_o = cur_position_r ;

  // cur_sel_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
                   cur_sel_r <= `TYPE_Y ;
    else begin
      case( nxt_state_w )
        ENC_Y :    cur_sel_r <= `TYPE_Y ;
        ENC_U :    cur_sel_r <= `TYPE_U ;
        ENC_V :    cur_sel_r <= `TYPE_V ;
      endcase
    end
  end

  // cur_size_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_size_r <= 0 ;
    end
    else begin
      if( cur_state_r==IDLE ) begin
        if( start_i ) begin
          cur_size_r <= nxt_size_of_luma_w ;
        end
      end
      else begin
        if( ref_done_i ) begin
          if( nxt_state_w==ENC_Y ) begin
            cur_size_r <= nxt_size_of_luma_w ;
          end
          else begin
            case( nxt_size_of_luma_w )
              `SIZE_08 : cur_size_r <= `SIZE_04 ;
              `SIZE_16 : cur_size_r <= `SIZE_08 ;
              `SIZE_32 : cur_size_r <= `SIZE_16 ;
            endcase
          end
        end
      end
    end
  end

  // cur_mode_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      cur_mode_r <= 'd0 ;
    else begin
      if( md_cena_r ) begin
        cur_mode_r <= md_data_i ;
      end
    end
  end

  // md_cena_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      md_cena_r <= 0 ;
    else begin
      md_cena_r <= md_cena_o ;
    end
  end

  // cur_position_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_position_r <= 0 ;
    end
    else begin
      if( cur_state_r==IDLE ) begin
        if( start_i ) begin
          cur_position_r <= 0 ;
        end
      end
      else begin
        if( ref_done_i ) begin
          if( nxt_state_w==ENC_Y ) begin
            cur_position_r <= nxt_position_of_luma_w ;
          end
          else begin
            cur_position_r <= nxt_position_of_luma_w>>2 ;
          end
        end
      end
    end
  end


//--- REFERENCE ------------------------
  // ref_start_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_start_o <= 0 ;
    end
    else begin
      if( cur_state_r==IDLE ) begin
        ref_start_o <= start_i ;
      end
      else begin
        ref_start_o <= ref_done_i && (!done_w) ;
      end
    end
  end


//--- PREDICTION -----------------------
  // pre_start_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      pre_start_o <= 0 ;
    end
    else begin
      if( ref_ready_i ) begin
        pre_start_o <= 1 ;
      end
      else begin
        case( cur_size_r )
          `SIZE_04 :    if( pre_cnt_r== 1      -1 )    pre_start_o <= 0 ;
          `SIZE_08 :    if( pre_cnt_r== 8* 8/32-1 )    pre_start_o <= 0 ;
          `SIZE_16 :    if( pre_cnt_r==16*16/32-1 )    pre_start_o <= 0 ;
          `SIZE_32 :    if( pre_cnt_r==32*32/32-1 )    pre_start_o <= 0 ;
        endcase
      end
    end
  end

  // pre_cnt_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      pre_cnt_r <= 0 ;
    end
    else begin
      if( pre_start_o ) begin
        case( cur_size_r )
          `SIZE_04 :    if( pre_cnt_r== 1      -1 )    pre_cnt_r <= 0           ;
                        else                           pre_cnt_r <= pre_cnt_r+1 ;
          `SIZE_08 :    if( pre_cnt_r== 8* 8/32-1 )    pre_cnt_r <= 0 ;
                        else                           pre_cnt_r <= pre_cnt_r+1 ;
          `SIZE_16 :    if( pre_cnt_r==16*16/32-1 )    pre_cnt_r <= 0 ;
                        else                           pre_cnt_r <= pre_cnt_r+1 ;
          `SIZE_32 :    if( pre_cnt_r==32*32/32-1 )    pre_cnt_r <= 0 ;
                        else                           pre_cnt_r <= pre_cnt_r+1 ;
        endcase
      end
      else begin
        pre_cnt_r <= 0 ;
      end
    end
  end

  // pre_4x4_x_o, pre_4x4_y_o
  always @(posedge clk or negedge rstn ) begin
    if(!rstn) begin
      pre_4x4_x_o <= 0 ;
      pre_4x4_y_o <= 0 ;
    end
    else begin
      if( pre_start_o ) begin
        case( cur_size_r )
          `SIZE_08 : begin    if( pre_cnt_r==8*8/32-1 ) begin
                                pre_4x4_x_o <= { cur_position_r[6] ,cur_position_r[4] ,cur_position_r[2] ,cur_position_r[0] };
                                pre_4x4_y_o <= { cur_position_r[7] ,cur_position_r[5] ,cur_position_r[3] ,cur_position_r[1] };
                              end
                              else begin
                                pre_4x4_y_o <= pre_4x4_y_o + 1 ;
                              end
          end
          `SIZE_16 : begin    if( pre_cnt_r==16*16/32-1 ) begin
                                pre_4x4_x_o <= { cur_position_r[6] ,cur_position_r[4] ,cur_position_r[2] ,cur_position_r[0] };
                                pre_4x4_y_o <= { cur_position_r[7] ,cur_position_r[5] ,cur_position_r[3] ,cur_position_r[1] };
                              end
                              else begin
                                if( pre_4x4_x_o[1:0]==2'b10 ) begin
                                  pre_4x4_x_o <= { cur_position_r[6] ,cur_position_r[4] ,cur_position_r[2] , cur_position_r[0] };
                                  pre_4x4_y_o <= pre_4x4_y_o + 1 ;
                                end
                                else begin
                                  pre_4x4_x_o <= pre_4x4_x_o + 2 ;
                                end
                              end
          end
          `SIZE_32 : begin    if( pre_cnt_r==32*32/32-1 ) begin
                                pre_4x4_x_o <= { cur_position_r[6] ,cur_position_r[4] ,cur_position_r[2] ,cur_position_r[0] };
                                pre_4x4_y_o <= { cur_position_r[7] ,cur_position_r[5] ,cur_position_r[3] ,cur_position_r[1] };
                              end
                              else begin
                                if( pre_4x4_x_o[2:0]==3'b110 ) begin
                                  pre_4x4_x_o <= { cur_position_r[6] ,cur_position_r[4] ,cur_position_r[2] , cur_position_r[0] };
                                  pre_4x4_y_o <= pre_4x4_y_o + 1 ;
                                end
                                else begin
                                  pre_4x4_x_o <= pre_4x4_x_o + 2 ;
                                end
                              end
          end
        endcase
      end
      else begin
        pre_4x4_x_o <= { cur_position_r[6] ,cur_position_r[4] ,cur_position_r[2] ,cur_position_r[0] };
        pre_4x4_y_o <= { cur_position_r[7] ,cur_position_r[5] ,cur_position_r[3] ,cur_position_r[1] };
      end
    end
  end


//*** DEBUG ********************************************************************

`ifdef DEBUG

  wire error ;

  assign error = partition_64_w == 0 ;

`endif



endmodule
