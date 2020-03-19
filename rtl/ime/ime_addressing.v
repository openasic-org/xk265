//--------------------------------------------------------------------
//
//  Filename    : ime_addressing.v
//  Author      : Huang Leilei
//  Created     : 2018-01-28
//  Description : addressing logic
//
//--------------------------------------------------------------------
//
//       -64           up            +63
//    -32 +---------------------------+
//        |                           |
//        |                           |
//   left |             +             | right
//        |                           |
//        |                           |
//    +31 +---------------------------+
//                     down
//
//--------------------------------------------------------------------
//
//  Modified    : 2018-05-05 by HLL
//  Description : several bugs, typos fixed
//
//--------------------------------------------------------------------
`include "enc_defines.v"
module ime_addressing(
  // global
  clk                ,
  rstn               ,
  // ctrl_if
  start_i            ,
  qp_i               ,
  done_o             ,
  // cfg_i
  center_x_i         ,
  center_y_i         ,
  length_x_i         ,
  length_y_i         ,
  slope_i            ,
  downsample_i       ,
  use_feedback_i     ,
  // feedback_i
  dat_32_mv_i        ,
  // ori
  ori_ena_o          ,
  ori_adr_x_o        ,
  ori_adr_y_o        ,
  // ref
  ref_dir_o          ,
  ref_hor_ena_o      ,
  ref_hor_adr_x_o    ,
  ref_hor_adr_y_o    ,
  ref_ver_ena_o      ,
  ref_ver_adr_x_o    ,
  ref_ver_adr_y_o    ,
  // mv
  val_o              ,
  dat_qd_o           ,
  dat_mv_o           ,
  dat_cst_mvd_o
  );


//*** PARAMETER ****************************************************************

  // local
  localparam    SLOPE_1d2                  = 2'd0               ;
  localparam    SLOPE_1                    = 2'd1               ;
  localparam    SLOPE_2                    = 2'd2               ;
  localparam    SLOPE_INF                  = 2'd3               ;

  localparam FSM_WD                        = 2                  ;
  localparam    IDLE                       = 2'd0               ;
  localparam    NULL                       = 2'd1               ;
  localparam    INIT                       = 2'd2               ;
  localparam    BUSY                       = 2'd3               ;

  localparam    UP                         = 0                  ;
  localparam    DOWN                       = 1                  ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                    clk                  ;
  input                                    rstn                 ;
  // ctrl_if
  input                                    start_i              ;
  input        [6                -1 :0]    qp_i                 ;
  output reg                               done_o               ;
  // cfg_i
  input signed [`IME_MV_WIDTH_X  -1 :0]    center_x_i           ;
  input signed [`IME_MV_WIDTH_Y  -1 :0]    center_y_i           ;
  input        [`IME_MV_WIDTH_X  -2 :0]    length_x_i           ;
  input        [`IME_MV_WIDTH_Y  -2 :0]    length_y_i           ;
  input        [2                -1 :0]    slope_i              ;
  input                                    downsample_i         ;
  input                                    use_feedback_i       ;
  // feedback
  input        [`IME_MV_WIDTH  *4-1 :0]    dat_32_mv_i          ;
  // ori
  output reg                               ori_ena_o            ;
  output reg   [6                -1 :0]    ori_adr_x_o          ;
  output reg   [6                -1 :0]    ori_adr_y_o          ;
  // ref
  output reg   [2                -1 :0]    ref_dir_o            ;
  output reg                               ref_hor_ena_o        ;
  output reg   [`IME_MV_WIDTH_X     :0]    ref_hor_adr_x_o      ;
  output reg   [`IME_MV_WIDTH_Y     :0]    ref_hor_adr_y_o      ;
  output reg                               ref_ver_ena_o        ;
  output reg   [`IME_MV_WIDTH_Y     :0]    ref_ver_adr_x_o      ;
  output reg   [`IME_MV_WIDTH_X     :0]    ref_ver_adr_y_o      ;
  // status
  output reg                               val_o                ;
  output reg   [2                -1 :0]    dat_qd_o             ;
  output reg   [`IME_MV_WIDTH    -1 :0]    dat_mv_o             ;
  output reg   [`IME_C_MV_WIDTH  -1 :0]    dat_cst_mvd_o        ;


//*** REG/WIRE ***************************************************************

  // assignment
  wire signed  [`IME_MV_WIDTH_X  -1 :0]    dat_32_mv_0_x_w      ;
  wire signed  [`IME_MV_WIDTH_Y  -1 :0]    dat_32_mv_0_y_w      ;
  wire signed  [`IME_MV_WIDTH_X  -1 :0]    dat_32_mv_1_x_w      ;
  wire signed  [`IME_MV_WIDTH_Y  -1 :0]    dat_32_mv_1_y_w      ;
  wire signed  [`IME_MV_WIDTH_X  -1 :0]    dat_32_mv_2_x_w      ;
  wire signed  [`IME_MV_WIDTH_Y  -1 :0]    dat_32_mv_2_y_w      ;
  wire signed  [`IME_MV_WIDTH_X  -1 :0]    dat_32_mv_3_x_w      ;
  wire signed  [`IME_MV_WIDTH_Y  -1 :0]    dat_32_mv_3_y_w      ;

  // delay
  reg  signed  [`IME_MV_WIDTH_X  -1 :0]    center_x_r           ;
  reg  signed  [`IME_MV_WIDTH_Y  -1 :0]    center_y_r           ;

  // fsm
  reg          [FSM_WD           -1 :0]    cur_state_r          ;
  reg          [FSM_WD           -1 :0]    nxt_state_w          ;

  wire                                     init_done_w          ;
  wire                                     busy_done_w          ;

  // jump condition
  wire                                     reach_x_w            ;
  wire                                     reach_y_w            ;
  wire                                     reach_y_up_w         ;
  wire                                     reach_y_down_w       ;

  wire                                     quad_done_w          ;

  // boundary
  wire signed  [`IME_MV_WIDTH_X     :0]    boundary_x_sw_left_w ;
  wire signed  [`IME_MV_WIDTH_X     :0]    boundary_x_sw_right_w;
  wire signed  [`IME_MV_WIDTH_Y     :0]    boundary_y_sw_up_w   ;    // search window
  wire signed  [`IME_MV_WIDTH_Y     :0]    boundary_y_sw_down_w ;

  wire signed  [`IME_MV_WIDTH_X     :0]    boundary_x_pt_left_w ;
  wire signed  [`IME_MV_WIDTH_X     :0]    boundary_x_pt_right_w;
  wire signed  [`IME_MV_WIDTH_Y     :0]    boundary_y_pt_up_w   ;    // pattern
  wire signed  [`IME_MV_WIDTH_Y     :0]    boundary_y_pt_down_w ;

  wire signed  [`IME_MV_WIDTH_X     :0]    boundary_y_sp_up_w   ;    // slope
  wire signed  [`IME_MV_WIDTH_X     :0]    boundary_y_sp_down_w ;
  reg  signed  [`IME_MV_WIDTH_X     :0]    boundary_y_sp_w      ;

  // position
  reg  signed  [`IME_MV_WIDTH_X     :0]    cur_x_start_w        ;
  reg  signed  [`IME_MV_WIDTH_X     :0]    cur_x_r              ;
  reg  signed  [`IME_MV_WIDTH_Y     :0]    cur_y_r              ;
  reg  signed  [`IME_MV_WIDTH_Y     :0]    cur_init_r           ;
  wire signed  [`IME_MV_WIDTH_X     :0]    abs_cur_x_w          ;
  wire signed  [`IME_MV_WIDTH_Y     :0]    abs_cur_y_w          ;
  wire signed  [`IME_MV_WIDTH_X     :0]    abs_mv_x_w           ;
  wire signed  [`IME_MV_WIDTH_Y     :0]    abs_mv_y_w           ;
  reg                                      direction_r          ;

  // init
  reg          [2                -1 :0]    cnt_quad_r           ;

  // ref
  wire signed  [`IME_MV_WIDTH_X     :0]    offset_x_w           ;
  wire signed  [`IME_MV_WIDTH_Y     :0]    offset_y_w           ;
  wire signed  [`IME_MV_WIDTH_Y     :0]    offset_ini_w         ;

  // mv
  wire signed  [`IME_MV_WIDTH_X  -1 :0]    dat_mv_x_w           ;
  wire signed  [`IME_MV_WIDTH_Y  -1 :0]    dat_mv_y_w           ;

  // mv cost
  reg          [5                -1 :0]    bitsnum_x_w          ;
  reg          [5                -1 :0]    bitsnum_y_w          ;
  reg          [7                -1 :0]    lambda_w             ;
  wire         [5+1+7            -1 :0]    dat_cst_mvd_w        ;


//*** MAIN BODY ****************************************************************

//--- ASSIGNMENT -----------------------
  // dat_32_mv_i
  assign { dat_32_mv_0_x_w ,dat_32_mv_0_y_w
          ,dat_32_mv_1_x_w ,dat_32_mv_1_y_w
          ,dat_32_mv_2_x_w ,dat_32_mv_2_y_w
          ,dat_32_mv_3_x_w ,dat_32_mv_3_y_w } = dat_32_mv_i ;


//--- DELAY ----------------------------
  // center
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      center_x_r <= 0 ;
      center_y_r <= 0 ;
    end
    else begin
      if( (cur_state_r==IDLE) && start_i ) begin
        if( !downsample_i && use_feedback_i ) begin    // use_feedback_i only valid when !downsample_i
          center_x_r <= dat_32_mv_0_x_w ;
          center_y_r <= dat_32_mv_0_y_w ;
        end
        else begin
          center_x_r <= center_x_i ;
          center_y_r <= center_y_i ;
        end
      end
      else if( (cur_state_r==BUSY) && busy_done_w ) begin
        if( !downsample_i && use_feedback_i ) begin
          case( cnt_quad_r )
            0 : begin    center_x_r <= dat_32_mv_1_x_w ;
                         center_y_r <= dat_32_mv_1_y_w ;
            end
            1 : begin    center_x_r <= dat_32_mv_2_x_w ;
                         center_y_r <= dat_32_mv_2_y_w ;
            end
            2 : begin    center_x_r <= dat_32_mv_3_x_w ;
                         center_y_r <= dat_32_mv_3_y_w ;
            end
          endcase
        end
      end
    end
  end


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
      IDLE : begin    if( start_i )                  nxt_state_w = NULL ;
                      else                           nxt_state_w = IDLE ;
      end
      NULL : begin                                   nxt_state_w = INIT ;
      end
      INIT : begin    if( init_done_w )              nxt_state_w = BUSY ;
                      else                           nxt_state_w = INIT ;
      end
      BUSY : begin    if( busy_done_w ) begin
                        if( !downsample_i ) begin
                          if( quad_done_w ) begin    nxt_state_w = IDLE ;
                          end
                          else begin                 nxt_state_w = NULL ;
                          end
                        end
                        else begin                   nxt_state_w = IDLE ;
                        end
                      end
                      else begin                     nxt_state_w = BUSY ;
                      end
      end
    endcase
  end

  // jump condition
  assign init_done_w    = cur_init_r==(downsample_i ? 62 : 31) ;
  assign busy_done_w    = reach_x_w && reach_y_w ;
  assign reach_x_w      = (cur_x_r>=boundary_x_sw_right_w)||(cur_x_r>=boundary_x_pt_right_w) ;
  assign reach_y_w      = (direction_r==UP) ? reach_y_up_w : reach_y_down_w ;
  assign reach_y_up_w   = ((cur_y_r-(downsample_i ? 1: 0))<=boundary_y_sw_up_w   )||(cur_y_r<=boundary_y_pt_up_w   )||(cur_y_r<=boundary_y_sp_up_w  );
  assign reach_y_down_w = ((cur_y_r+(downsample_i ? 1: 0))>=boundary_y_sw_down_w )||(cur_y_r>=boundary_y_pt_down_w )||(cur_y_r>=boundary_y_sp_down_w);
  assign quad_done_w    = cnt_quad_r==3 ;

  // boundary
  assign boundary_x_sw_left_w  = -$signed({2'b01,{(`IME_MV_WIDTH_X-1){1'b0}}}-4) - center_x_r ;
  assign boundary_x_sw_right_w =  $signed({2'b01,{(`IME_MV_WIDTH_X-1){1'b0}}}-4) - center_x_r ;
  assign boundary_y_sw_up_w    = -$signed({2'b01,{(`IME_MV_WIDTH_Y-1){1'b0}}}-4) - center_y_r ;
  assign boundary_y_sw_down_w  =  $signed({2'b01,{(`IME_MV_WIDTH_Y-1){1'b0}}}-4) - center_y_r ;

  assign boundary_x_pt_left_w  = -length_x_i ;
  assign boundary_x_pt_right_w =  length_x_i ;
  assign boundary_y_pt_up_w    = -length_y_i ;
  assign boundary_y_pt_down_w  =  length_y_i ;

  assign boundary_y_sp_up_w    = -boundary_y_sp_w ;
  assign boundary_y_sp_down_w  =  boundary_y_sp_w ;
  always @(*) begin
                  boundary_y_sp_w =  length_y_i                ;
    case( slope_i )
      SLOPE_1d2 : boundary_y_sp_w = (length_x_i-abs_cur_x_w)/2 ;
      SLOPE_1   : boundary_y_sp_w = (length_x_i-abs_cur_x_w)   ;
      SLOPE_2   : boundary_y_sp_w = (length_x_i-abs_cur_x_w)*2 ;
      SLOPE_INF : boundary_y_sp_w =  length_y_i                ;
    endcase
  end

  // abs_of_cur_x/y
  assign abs_cur_x_w = (cur_x_r>=0) ? cur_x_r : -cur_x_r ;
  assign abs_cur_y_w = (cur_y_r>=0) ? cur_y_r : -cur_y_r ;
  assign abs_mv_x_w  = ((cur_x_r+center_x_r)>=0) ? (cur_x_r+center_x_r) : -(cur_x_r+center_x_r) ;    // TODO : remove these variables
  assign abs_mv_y_w  = ((cur_y_r+center_y_r)>=0) ? (cur_y_r+center_y_r) : -(cur_y_r+center_y_r) ;


//--- POSITION -------------------------
  // start point
  always @(*) begin
//    if( downsample_i ) begin
//      if( boundary_x_sw_left_w>boundary_x_pt_left_w ) begin
//        if( center_x_r[0] ) begin
//          cur_x_start_w = boundary_x_sw_left_w + 1 ;
//        end
//        else begin
//          cur_x_start_w = boundary_x_sw_left_w ;
//        end
//      end
//      else begin
//        cur_x_start_w = boundary_x_pt_left_w ;
//      end
//    end
//    else begin
      if( boundary_x_sw_left_w>boundary_x_pt_left_w ) begin
        cur_x_start_w = boundary_x_sw_left_w ;
      end
      else begin
        cur_x_start_w = boundary_x_pt_left_w ;
      end
//    end
  end

  // cur_x/y_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cur_x_r    <= 0 ;
      cur_y_r    <= 0 ;
      cur_init_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        NULL : begin                                      cur_x_r    <= cur_x_start_w ;
                                                          cur_y_r    <= 0 ;
        end
        INIT : begin    if( init_done_w )                 cur_init_r <= 0 ;
                        else                              cur_init_r <= cur_init_r + (downsample_i ? 2 : 1) ;
        end
        BUSY : begin    case( direction_r )
                          UP    : if( reach_y_up_w )      cur_x_r    <= cur_x_r + (downsample_i ? 2 : 1) ;
                                  else                    cur_y_r    <= cur_y_r - (downsample_i ? 2 : 1) ;
                          DOWN  : if( reach_y_down_w )    cur_x_r    <= cur_x_r + (downsample_i ? 2 : 1) ;
                                  else                    cur_y_r    <= cur_y_r + (downsample_i ? 2 : 1) ;
                        endcase
        end
      endcase
    end
  end

  // direction_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      direction_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        INIT : begin    direction_r <= DOWN ;
        end
        BUSY : begin    case( direction_r )
                          UP   : if( reach_y_up_w   )    direction_r <= DOWN ;
                          DOWN : if( reach_y_down_w )    direction_r <= UP   ;
                        endcase
        end
      endcase
    end
  end


//--- INIT -----------------------------
  // cnt_quad_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_quad_r <= 0 ;
    end
    else begin
      case( cur_state_r )
        IDLE : begin    cnt_quad_r <= 0 ;
        end
        BUSY : begin    if( busy_done_w ) begin
                          if( !downsample_i ) begin
                            cnt_quad_r <= cnt_quad_r + 1 ;
                          end
                        end
        end
      endcase
    end
  end


//--- ORI ------------------------------
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ori_ena_o   <= 0 ;
      ori_adr_x_o <= 0 ;
      ori_adr_y_o <= 0 ;
    end
    else begin
      ori_ena_o   <= (cur_state_r==INIT) ;
      ori_adr_x_o <= (cnt_quad_r[0] ? 32 : 0) ;
      ori_adr_y_o <= (cnt_quad_r[1] ? 32 : 0) + cur_init_r ;
    end
  end


//--- REF ------------------------------
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      ref_dir_o       <= `IME_DIR_DOWN ;
      ref_hor_ena_o   <= 0 ;
      ref_hor_adr_x_o <= 0 ;
      ref_hor_adr_y_o <= 0 ;
      ref_ver_ena_o   <= 0 ;
      ref_ver_adr_x_o <= 0 ;
      ref_ver_adr_y_o <= 0 ;
    end
    else begin
      case( cur_state_r )
        IDLE : begin                                      ref_dir_o       <= `IME_DIR_DOWN ;
                                                          ref_hor_ena_o   <= 0 ;
                                                          ref_hor_adr_x_o <= 0 ;
                                                          ref_hor_adr_y_o <= 0 ;
                                                          ref_ver_ena_o   <= 0 ;
                                                          ref_ver_adr_x_o <= 0 ;
                                                          ref_ver_adr_y_o <= 0 ;
        end
        INIT : begin                                      ref_dir_o       <= `IME_DIR_DOWN ;
                                                          ref_hor_ena_o   <= 1 ;
                                                          ref_hor_adr_x_o <= offset_x_w   ;
                                                          ref_hor_adr_y_o <= offset_ini_w ;
                                                          ref_ver_ena_o   <= 0 ;
        end
        BUSY : begin
          case( direction_r )
            UP   : begin    if( reach_y_up_w ) begin      ref_dir_o       <= `IME_DIR_RIGHT ;
                                                          ref_hor_ena_o   <= 0 ;
                                                          ref_ver_ena_o   <= 1 ;
                                                          ref_ver_adr_x_o <= offset_y_w ;
                                                          ref_ver_adr_y_o <= offset_x_w + (downsample_i ? 64 : 32) ;
                            end
                            else begin                    ref_dir_o       <= `IME_DIR_UP ;
                                                          ref_hor_ena_o   <= 1 ;
                                                          ref_hor_adr_x_o <= offset_x_w ;
                                                          ref_hor_adr_y_o <= offset_y_w + (downsample_i ? -2 : -1) ;
                                                          ref_ver_ena_o   <= 0 ;
                            end
            end
            DOWN : begin    if( reach_y_down_w ) begin    ref_dir_o       <= `IME_DIR_RIGHT ;
                                                          ref_hor_ena_o   <= 0 ;
                                                          ref_ver_ena_o   <= 1 ;
                                                          ref_ver_adr_x_o <= offset_y_w ;
                                                          ref_ver_adr_y_o <= offset_x_w + (downsample_i ? 64 : 32) ;
                            end
                            else begin                    ref_dir_o       <= `IME_DIR_DOWN ;
                                                          ref_hor_ena_o   <= 1 ;
                                                          ref_hor_adr_x_o <= offset_x_w ;
                                                          ref_hor_adr_y_o <= offset_y_w + (downsample_i ? 64 : 32) ;
                                                          ref_ver_ena_o   <= 0 ;
                            end
            end
          endcase
        end
      endcase
    end
  end

  assign offset_x_w   = $signed({2'b01,{(`IME_MV_WIDTH_X-1){1'b0}}}) + center_x_r + (cnt_quad_r[0] ? 32 : 0) + cur_x_r    ;
  assign offset_y_w   = $signed({2'b01,{(`IME_MV_WIDTH_Y-1){1'b0}}}) + center_y_r + (cnt_quad_r[1] ? 32 : 0) + cur_y_r    ;
  assign offset_ini_w = $signed({2'b01,{(`IME_MV_WIDTH_Y-1){1'b0}}}) + center_y_r + (cnt_quad_r[1] ? 32 : 0) + cur_init_r ;


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


//--- STATUS ---------------------------
  // val_o & dat_mv/qt_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      val_o    <= 0 ;
      dat_qd_o <= 0 ;
      dat_mv_o <= 0 ;
    end
    else begin
      if( cur_state_r==BUSY ) begin
        val_o    <= 1 ;
        dat_qd_o <= cnt_quad_r ;
        dat_mv_o <= { dat_mv_x_w ,dat_mv_y_w };
      end
      else begin
        val_o    <= 0 ;
        dat_qd_o <= 0 ;
        dat_mv_o <= 0 ;
      end
    end
  end

  assign dat_mv_x_w = cur_x_r + center_x_r ;
  assign dat_mv_y_w = cur_y_r + center_y_r ;


//--- MV COST---------------------------
  // bitsnum_x_w    // TODO : finalize mv cost
  always @(*) begin
                       bitsnum_x_w = 01 ;
    casez( abs_mv_x_w )
      'b0000_0000 :    bitsnum_x_w = 01 ;
      'b0000_0001 :    bitsnum_x_w = 07 ;
      'b0000_001? :    bitsnum_x_w = 09 ;
      'b0000_01?? :    bitsnum_x_w = 11 ;
      'b0000_1??? :    bitsnum_x_w = 13 ;
      'b0001_???? :    bitsnum_x_w = 15 ;
      'b001?_???? :    bitsnum_x_w = 17 ;
      'b01??_???? :    bitsnum_x_w = 19 ;
      'b1???_???? :    bitsnum_x_w = 21 ;
    endcase
  end

  // bitsnum_y_w
  always @(*) begin
                      bitsnum_y_w = 01 ;
    casex( abs_mv_y_w )
      'b000_0000 :    bitsnum_y_w = 01 ;
      'b000_0001 :    bitsnum_y_w = 07 ;
      'b000_001? :    bitsnum_y_w = 09 ;
      'b000_01?? :    bitsnum_y_w = 11 ;
      'b000_1??? :    bitsnum_y_w = 13 ;
      'b001_???? :    bitsnum_y_w = 15 ;
      'b01?_???? :    bitsnum_y_w = 17 ;
      'b1??_???? :    bitsnum_y_w = 19 ;
    endcase
  end

  // lamda_w
  always @(*) begin
                                                 lambda_w = 00 ;
    case( qp_i )
      0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 :    lambda_w = 01 ;
      16,17,18,19                           :    lambda_w = 02 ;
      20,21,22                              :    lambda_w = 03 ;
      23,24,25                              :    lambda_w = 04 ;
      26                                    :    lambda_w = 05 ;
      27,28                                 :    lambda_w = 06 ;
      29                                    :    lambda_w = 07 ;
      30                                    :    lambda_w = 08 ;
      31                                    :    lambda_w = 09 ;
      32                                    :    lambda_w = 10 ;
      33                                    :    lambda_w = 11 ;
      34                                    :    lambda_w = 13 ;
      35                                    :    lambda_w = 14 ;
      36                                    :    lambda_w = 16 ;
      37                                    :    lambda_w = 18 ;
      38                                    :    lambda_w = 20 ;
      39                                    :    lambda_w = 23 ;
      40                                    :    lambda_w = 25 ;
      41                                    :    lambda_w = 29 ;
      42                                    :    lambda_w = 32 ;
      43                                    :    lambda_w = 36 ;
      44                                    :    lambda_w = 40 ;
      45                                    :    lambda_w = 45 ;
      46                                    :    lambda_w = 51 ;
      47                                    :    lambda_w = 57 ;
      48                                    :    lambda_w = 64 ;
      49                                    :    lambda_w = 72 ;
      50                                    :    lambda_w = 81 ;
      51                                    :    lambda_w = 91 ;
    endcase
  end

  // dat_cst_mvd_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      dat_cst_mvd_o <= 0 ;
    end
    else begin
      dat_cst_mvd_o <= ( {{`IME_C_MV_WIDTH{1'b1}}}<dat_cst_mvd_w ) ? {{`IME_C_MV_WIDTH{1'b1}}} : dat_cst_mvd_w ;
    end
  end

  assign dat_cst_mvd_w = ( lambda_w * (bitsnum_x_w+bitsnum_y_w) ) >> (8-`IME_PIXEL_WIDTH) ;

endmodule
