//--------------------------------------------------------------------
//
//  Filename    : posi_rate_estimation.v
//  Author      : TANG
//  Created     : 2018-07-03
//  Description : posi rate estimation
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module posi_rate_estimation(
  clk              ,
  rstn             ,
  sys_posi4x4bit_i ,
  // cfg_i
  qp_i             ,
  mode_i           ,
  size_i           ,
  position_i       ,
  cost_done_i      , // To update left mode
  // rate
  bitrate_o   
);

//--- parameter ---------------------------------------------------
  parameter INVALID_MODE = 6'b111111 ;

//--- input/output -------------------------------------------------
  input                                 clk             ;
  input                                 rstn            ;
  input   [5-1:0]                       sys_posi4x4bit_i;
  // cfg_i
  input   [6                  -1 :0]    qp_i            ;
  input   [6                  -1 :0]    mode_i          ;
  input   [2                  -1 :0]    size_i          ;
  input   [8                  -1 :0]    position_i      ;
  input                                 cost_done_i     ;
  // bitrate
  output  [13                 -1 :0]    bitrate_o       ;

//--- reg/wire ----------------------------------------------------
  reg     [7                  -1 :0]    lambda          ;
  
  wire    [3                  -1 :0]    idx_8x8_x_w     ;
  wire    [3                  -1 :0]    idx_8x8_y_w     ;

  reg     [6                  -1 :0]    top_mod_08_00_r ;
  reg     [6                  -1 :0]    top_mod_08_01_r ;
  reg     [6                  -1 :0]    top_mod_08_02_r ;
  reg     [6                  -1 :0]    top_mod_08_03_r ;
  reg     [6                  -1 :0]    top_mod_08_04_r ;
  reg     [6                  -1 :0]    top_mod_08_05_r ;
  reg     [6                  -1 :0]    top_mod_08_06_r ;
  reg     [6                  -1 :0]    top_mod_08_07_r ;
  reg     [6                  -1 :0]    top_mod_16_00_r ;
  reg     [6                  -1 :0]    top_mod_16_01_r ;
  reg     [6                  -1 :0]    top_mod_16_02_r ;
  reg     [6                  -1 :0]    top_mod_16_03_r ;
  reg     [6                  -1 :0]    top_mod_32_00_r ;
  reg     [6                  -1 :0]    top_mod_32_01_r ;

  reg     [6                  -1 :0]    lft_mod_08_00_r ;
  reg     [6                  -1 :0]    lft_mod_08_01_r ;
  reg     [6                  -1 :0]    lft_mod_08_02_r ;
  reg     [6                  -1 :0]    lft_mod_08_03_r ;
  reg     [6                  -1 :0]    lft_mod_08_04_r ;
  reg     [6                  -1 :0]    lft_mod_08_05_r ;
  reg     [6                  -1 :0]    lft_mod_08_06_r ;
  reg     [6                  -1 :0]    lft_mod_08_07_r ;
  reg     [6                  -1 :0]    lft_mod_16_00_r ;
  reg     [6                  -1 :0]    lft_mod_16_01_r ;
  reg     [6                  -1 :0]    lft_mod_16_02_r ;
  reg     [6                  -1 :0]    lft_mod_16_03_r ;
  reg     [6                  -1 :0]    lft_mod_32_00_r ;
  reg     [6                  -1 :0]    lft_mod_32_01_r ;

  reg     [6                  -1 :0]    top_mod_w       ;
  reg     [6                  -1 :0]    lft_mod_w       ;

  reg     [5                  -1 :0]    bitrate_w       ;

//--- main body --------------------------------------------------------
  // lambda
  always @(qp_i)
    case(qp_i)
      0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15: 
        lambda = 1;
      16,17,18,19:
        lambda = 2;
      20,21,22:
        lambda = 3;
      23,24,25:
        lambda = 4;
      26:
        lambda = 5;
      27,28:
        lambda = 6;
      29:
        lambda = 7;
      30:
        lambda = 8;
      31:
        lambda = 9;
      32:
        lambda = 10;
      33:
        lambda = 11;
      34:
        lambda = 13;
      35:
        lambda = 14;
      36:
        lambda = 16;
      37:
        lambda = 18;
      38:
        lambda = 20;
      39:
        lambda = 23;
      40:
        lambda = 25;
      41:
        lambda = 29;
      42:
        lambda = 32;
      43:
        lambda = 36;
      44:
        lambda = 40;
      45:
        lambda = 45;
      46:
        lambda = 51;
      47:
        lambda = 57;
      48:
        lambda = 64;
      49:
        lambda = 72;
      50:
        lambda = 81;
      51:
        lambda = 91;
      default:
        lambda = 0;
    endcase

  // top and left mode buffer
  assign idx_8x8_x_w = {position_i[6], position_i[4], position_i[2]};
  assign idx_8x8_y_w = {position_i[7], position_i[5], position_i[3]};

  // top mode
  always @ ( posedge clk or negedge rstn ) begin 
    if ( !rstn ) begin 
      top_mod_08_00_r <= INVALID_MODE ;
      top_mod_08_01_r <= INVALID_MODE ;
      top_mod_08_02_r <= INVALID_MODE ;
      top_mod_08_03_r <= INVALID_MODE ;
      top_mod_08_04_r <= INVALID_MODE ;
      top_mod_08_05_r <= INVALID_MODE ;
      top_mod_08_06_r <= INVALID_MODE ;
      top_mod_08_07_r <= INVALID_MODE ;
      top_mod_16_00_r <= INVALID_MODE ;
      top_mod_16_01_r <= INVALID_MODE ;
      top_mod_16_02_r <= INVALID_MODE ;
      top_mod_16_03_r <= INVALID_MODE ;
      top_mod_32_00_r <= INVALID_MODE ;
      top_mod_32_01_r <= INVALID_MODE ;
    end else if (cost_done_i ) begin 
      case ( size_i )
        `SIZE_08 : begin 
          case ( idx_8x8_x_w ) 
            0 : top_mod_08_00_r <= mode_i ;
            1 : top_mod_08_01_r <= mode_i ;
            2 : top_mod_08_02_r <= mode_i ;
            3 : top_mod_08_03_r <= mode_i ;
            4 : top_mod_08_04_r <= mode_i ;
            5 : top_mod_08_05_r <= mode_i ;
            6 : top_mod_08_06_r <= mode_i ;
            7 : top_mod_08_07_r <= mode_i ;
            default : ;
          endcase 
        end 
        `SIZE_16 : begin 
          case ( idx_8x8_x_w[2:1] ) 
            0 : top_mod_16_00_r <= mode_i ;
            1 : top_mod_16_01_r <= mode_i ;
            2 : top_mod_16_02_r <= mode_i ;
            3 : top_mod_16_03_r <= mode_i ;
            default : ;
          endcase 
        end 
        `SIZE_32 : begin 
          case ( idx_8x8_x_w[2] ) 
            0 : top_mod_32_00_r <= mode_i ;
            1 : top_mod_32_01_r <= mode_i ;
            default : ;
          endcase 
        end 
        default : ;
      endcase 
    end 
  end 

  // top mode output 
  always @* begin 
    top_mod_w = INVALID_MODE ;
    if ( idx_8x8_y_w != 0 )
      case ( size_i ) 
        `SIZE_08 : begin 
          case ( idx_8x8_x_w )
            0 : top_mod_w = top_mod_08_00_r ;
            1 : top_mod_w = top_mod_08_01_r ;
            2 : top_mod_w = top_mod_08_02_r ;
            3 : top_mod_w = top_mod_08_03_r ;
            4 : top_mod_w = top_mod_08_04_r ;
            5 : top_mod_w = top_mod_08_05_r ;
            6 : top_mod_w = top_mod_08_06_r ;
            7 : top_mod_w = top_mod_08_07_r ;
            default : top_mod_w = INVALID_MODE ;
          endcase   
        end 
        `SIZE_16 : begin 
          case ( idx_8x8_x_w[2:1] ) 
            0 : top_mod_w = top_mod_16_00_r ;
            1 : top_mod_w = top_mod_16_01_r ;
            2 : top_mod_w = top_mod_16_02_r ;
            3 : top_mod_w = top_mod_16_03_r ;
            default : top_mod_w = INVALID_MODE ;
          endcase 
        end 
        `SIZE_32 : begin 
          case ( idx_8x8_x_w[2] ) 
            0 : top_mod_w = top_mod_32_00_r ;
            1 : top_mod_w = top_mod_32_01_r ;
            default : top_mod_w = INVALID_MODE ;
          endcase 
        end 
      endcase 
    else 
      top_mod_w = INVALID_MODE ;
  end 

  // left mode 
  always @ ( posedge clk or negedge rstn ) begin 
    if ( !rstn ) begin 
      lft_mod_08_00_r <= INVALID_MODE ;
      lft_mod_08_01_r <= INVALID_MODE ;
      lft_mod_08_02_r <= INVALID_MODE ;
      lft_mod_08_03_r <= INVALID_MODE ;
      lft_mod_08_04_r <= INVALID_MODE ;
      lft_mod_08_05_r <= INVALID_MODE ;
      lft_mod_08_06_r <= INVALID_MODE ;
      lft_mod_08_07_r <= INVALID_MODE ;
      lft_mod_16_00_r <= INVALID_MODE ;
      lft_mod_16_01_r <= INVALID_MODE ;
      lft_mod_16_02_r <= INVALID_MODE ;
      lft_mod_16_03_r <= INVALID_MODE ;
      lft_mod_32_00_r <= INVALID_MODE ;
      lft_mod_32_01_r <= INVALID_MODE ;
    end else if (cost_done_i ) begin 
      case ( size_i )
        `SIZE_08 : begin 
          case ( idx_8x8_y_w ) 
            0 : lft_mod_08_00_r <= mode_i ;
            1 : lft_mod_08_01_r <= mode_i ;
            2 : lft_mod_08_02_r <= mode_i ;
            3 : lft_mod_08_03_r <= mode_i ;
            4 : lft_mod_08_04_r <= mode_i ;
            5 : lft_mod_08_05_r <= mode_i ;
            6 : lft_mod_08_06_r <= mode_i ;
            7 : lft_mod_08_07_r <= mode_i ;
            default : ;
          endcase 
        end 
        `SIZE_16 : begin 
          case ( idx_8x8_y_w[2:1] ) 
            0 : lft_mod_16_00_r <= mode_i ;
            1 : lft_mod_16_01_r <= mode_i ;
            2 : lft_mod_16_02_r <= mode_i ;
            3 : lft_mod_16_03_r <= mode_i ;
            default : ;
          endcase 
        end 
        `SIZE_32 : begin 
          case ( idx_8x8_y_w[2] ) 
            0 : lft_mod_32_00_r <= mode_i ;
            1 : lft_mod_32_01_r <= mode_i ;
            default : ;
          endcase 
        end 
        default : ;
      endcase 
    end 
  end 

  // lft mode output 
  always @* begin 
    lft_mod_w = INVALID_MODE ;
    if ( idx_8x8_x_w != 0 )
      case ( size_i ) 
        `SIZE_08 : begin 
          case ( idx_8x8_y_w )
            0 : lft_mod_w = lft_mod_08_00_r ;
            1 : lft_mod_w = lft_mod_08_01_r ;
            2 : lft_mod_w = lft_mod_08_02_r ;
            3 : lft_mod_w = lft_mod_08_03_r ;
            4 : lft_mod_w = lft_mod_08_04_r ;
            5 : lft_mod_w = lft_mod_08_05_r ;
            6 : lft_mod_w = lft_mod_08_06_r ;
            7 : lft_mod_w = lft_mod_08_07_r ;
            default : lft_mod_w = INVALID_MODE ;
          endcase   
        end 
        `SIZE_16 : begin 
          case ( idx_8x8_y_w[2:1] ) 
            0 : lft_mod_w = lft_mod_16_00_r ;
            1 : lft_mod_w = lft_mod_16_01_r ;
            2 : lft_mod_w = lft_mod_16_02_r ;
            3 : lft_mod_w = lft_mod_16_03_r ;
            default : lft_mod_w = INVALID_MODE ;
          endcase 
        end 
        `SIZE_32 : begin 
          case ( idx_8x8_y_w[2] ) 
            0 : lft_mod_w = lft_mod_32_00_r ;
            1 : lft_mod_w = lft_mod_32_01_r ;
            default : lft_mod_w = INVALID_MODE ;
          endcase 
        end 
      endcase 
    else 
      lft_mod_w = INVALID_MODE ;
  end 

  // bit estimation 
  always @* begin 
    if ( size_i == `SIZE_04 )
      bitrate_w = sys_posi4x4bit_i ;
    else begin 
      if ( idx_8x8_x_w == 0 && idx_8x8_y_w == 0 )
        bitrate_w = 8 ;
      else if ( idx_8x8_x_w == 0 && idx_8x8_y_w != 0 )
        bitrate_w = mode_i == top_mod_w ? 3 : 8 ;
      else if ( idx_8x8_x_w != 0 && idx_8x8_y_w == 0 )
        bitrate_w = mode_i == lft_mod_w ? 3 : 8 ;
      else 
        bitrate_w = (mode_i == lft_mod_w||mode_i==top_mod_w) ? 3 : 8 ;
    end 
  end 

  assign bitrate_o = lambda * bitrate_w ;

endmodule 