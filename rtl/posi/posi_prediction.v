//--------------------------------------------------------------------
//
//  Filename    : h265_posi_prediction.v
//  Author      : Huang Leilei
//  Description : prediction engine in module post intra
//  Created     : 2018-04-09
//
//--------------------------------------------------------------------

`include "./enc_defines.v"

module posi_prediction(
  // global
  clk             ,
  rstn            ,
  // ctrl_i
  start_i         ,
  // cfg_i
  mode_i          ,
  size_i          ,
  position_i      ,
  // ref_i
  dat_ref_r_i     ,
  dat_ref_t_i     ,
  dat_ref_tl_i    ,
  dat_ref_l_i     ,
  dat_ref_d_i     ,
  // ahd_o
  val_ahd_o       ,
  idx_4x4_x_ahd_o ,
  idx_4x4_y_ahd_o ,
  // cfg_o
  mode_o          ,
  size_o          ,
  position_o      ,
  // pre_o
  val_o           ,
  dat_pre_o
  );


//*** PARAMETER ****************************************************************

  // local
  localparam FSM_WD                 = 1                ;
  localparam     IDLE               = 1'd0             ;
  localparam     BUSY               = 1'd1             ;

  localparam DELAY                  = 3                ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                             clk                ;
  input                             rstn               ;
  // ctrl_if
  input                             start_i            ;
  // cfg_i
  input  [6               -1 :0]    mode_i             ;
  input  [2               -1 :0]    size_i             ;
  input  [8               -1 :0]    position_i         ;
  // ref_i
  input  [`PIXEL_WIDTH*32 -1 :0]    dat_ref_r_i        ;
  input  [`PIXEL_WIDTH*32 -1 :0]    dat_ref_t_i        ;
  input  [`PIXEL_WIDTH*1  -1 :0]    dat_ref_tl_i       ;
  input  [`PIXEL_WIDTH*32 -1 :0]    dat_ref_l_i        ;
  input  [`PIXEL_WIDTH*32 -1 :0]    dat_ref_d_i        ;
  // ahd_o
  output                            val_ahd_o          ;
  output [4               -1 :0]    idx_4x4_x_ahd_o    ;
  output [4               -1 :0]    idx_4x4_y_ahd_o    ;
  // cfg_o
  output [6               -1 :0]    mode_o             ;
  output [2               -1 :0]    size_o             ;
  output [8               -1 :0]    position_o         ;
  // pre_o
  output                            val_o              ;
  output [`PIXEL_WIDTH*16 -1 :0]    dat_pre_o          ;


//*** REG/WIRE *****************************************************************

  // assignment
  wire   [4               -1 :0]    idx_4x4_x_w        ;
  wire   [4               -1 :0]    idx_4x4_y_w        ;

  wire   [`PIXEL_WIDTH    -1 :0]    ref_r00_w          ,ref_r01_w ,ref_r02_w ,ref_r03_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_r04_w          ,ref_r05_w ,ref_r06_w ,ref_r07_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_r08_w          ,ref_r09_w ,ref_r10_w ,ref_r11_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_r12_w          ,ref_r13_w ,ref_r14_w ,ref_r15_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_r16_w          ,ref_r17_w ,ref_r18_w ,ref_r19_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_r20_w          ,ref_r21_w ,ref_r22_w ,ref_r23_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_r24_w          ,ref_r25_w ,ref_r26_w ,ref_r27_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_r28_w          ,ref_r29_w ,ref_r30_w ,ref_r31_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_t00_w          ,ref_t01_w ,ref_t02_w ,ref_t03_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_t04_w          ,ref_t05_w ,ref_t06_w ,ref_t07_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_t08_w          ,ref_t09_w ,ref_t10_w ,ref_t11_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_t12_w          ,ref_t13_w ,ref_t14_w ,ref_t15_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_t16_w          ,ref_t17_w ,ref_t18_w ,ref_t19_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_t20_w          ,ref_t21_w ,ref_t22_w ,ref_t23_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_t24_w          ,ref_t25_w ,ref_t26_w ,ref_t27_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_t28_w          ,ref_t29_w ,ref_t30_w ,ref_t31_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_tl_w           ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_l00_w          ,ref_l01_w ,ref_l02_w ,ref_l03_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_l04_w          ,ref_l05_w ,ref_l06_w ,ref_l07_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_l08_w          ,ref_l09_w ,ref_l10_w ,ref_l11_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_l12_w          ,ref_l13_w ,ref_l14_w ,ref_l15_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_l16_w          ,ref_l17_w ,ref_l18_w ,ref_l19_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_l20_w          ,ref_l21_w ,ref_l22_w ,ref_l23_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_l24_w          ,ref_l25_w ,ref_l26_w ,ref_l27_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_l28_w          ,ref_l29_w ,ref_l30_w ,ref_l31_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_d00_w          ,ref_d01_w ,ref_d02_w ,ref_d03_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_d04_w          ,ref_d05_w ,ref_d06_w ,ref_d07_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_d08_w          ,ref_d09_w ,ref_d10_w ,ref_d11_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_d12_w          ,ref_d13_w ,ref_d14_w ,ref_d15_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_d16_w          ,ref_d17_w ,ref_d18_w ,ref_d19_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_d20_w          ,ref_d21_w ,ref_d22_w ,ref_d23_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_d24_w          ,ref_d25_w ,ref_d26_w ,ref_d27_w ;
  wire   [`PIXEL_WIDTH    -1 :0]    ref_d28_w          ,ref_d29_w ,ref_d30_w ,ref_d31_w ;

  wire   [`PIXEL_WIDTH    -1 :0]    pre_00_w           ,pre_01_w  ,pre_02_w  ,pre_03_w  ;
  wire   [`PIXEL_WIDTH    -1 :0]    pre_10_w           ,pre_11_w  ,pre_12_w  ,pre_13_w  ;
  wire   [`PIXEL_WIDTH    -1 :0]    pre_20_w           ,pre_21_w  ,pre_22_w  ,pre_23_w  ;
  wire   [`PIXEL_WIDTH    -1 :0]    pre_30_w           ,pre_31_w  ,pre_32_w  ,pre_33_w  ;

  // fsm
  reg    [FSM_WD          -1 :0]    cur_state_r        ;
  reg    [FSM_WD          -1 :0]    nxt_state_w        ;

  wire                              done_busy_w        ;

  reg    [6               -1 :0]    pre_cnt_r          ;
  reg                               pre_cnt_done_w     ;

  wire   [4               -1 :0]    idx_4x4_x_offset_w ;
  wire   [4               -1 :0]    idx_4x4_y_offset_w ;

  // delay
  reg    [DELAY*1         -1 :0]    val_r              ;
  reg    [DELAY*6         -1 :0]    mode_r             ;
  reg    [DELAY*2         -1 :0]    size_r             ;
  reg    [DELAY*8         -1 :0]    position_r         ;
  reg    [DELAY*4         -1 :0]    idx_4x4_x_ahd_r    ;
  reg    [DELAY*4         -1 :0]    idx_4x4_y_ahd_r    ;


//*** MAIN BODY ****************************************************************

//--- ASSINMENT ------------------------
  // idx_i
  assign idx_4x4_x_w = {position_i[6],position_i[4],position_i[2],position_i[0]} ;
  assign idx_4x4_y_w = {position_i[7],position_i[5],position_i[3],position_i[1]} ;

  // ref_i
  assign { ref_r00_w ,ref_r01_w ,ref_r02_w ,ref_r03_w
          ,ref_r04_w ,ref_r05_w ,ref_r06_w ,ref_r07_w
          ,ref_r08_w ,ref_r09_w ,ref_r10_w ,ref_r11_w
          ,ref_r12_w ,ref_r13_w ,ref_r14_w ,ref_r15_w
          ,ref_r16_w ,ref_r17_w ,ref_r18_w ,ref_r19_w
          ,ref_r20_w ,ref_r21_w ,ref_r22_w ,ref_r23_w
          ,ref_r24_w ,ref_r25_w ,ref_r26_w ,ref_r27_w
          ,ref_r28_w ,ref_r29_w ,ref_r30_w ,ref_r31_w } = dat_ref_r_i ;
  assign { ref_t00_w ,ref_t01_w ,ref_t02_w ,ref_t03_w
          ,ref_t04_w ,ref_t05_w ,ref_t06_w ,ref_t07_w
          ,ref_t08_w ,ref_t09_w ,ref_t10_w ,ref_t11_w
          ,ref_t12_w ,ref_t13_w ,ref_t14_w ,ref_t15_w
          ,ref_t16_w ,ref_t17_w ,ref_t18_w ,ref_t19_w
          ,ref_t20_w ,ref_t21_w ,ref_t22_w ,ref_t23_w
          ,ref_t24_w ,ref_t25_w ,ref_t26_w ,ref_t27_w
          ,ref_t28_w ,ref_t29_w ,ref_t30_w ,ref_t31_w } = dat_ref_t_i  ;
  assign { ref_tl_w                                   } = dat_ref_tl_i ;
  assign { ref_l00_w ,ref_l01_w ,ref_l02_w ,ref_l03_w
          ,ref_l04_w ,ref_l05_w ,ref_l06_w ,ref_l07_w
          ,ref_l08_w ,ref_l09_w ,ref_l10_w ,ref_l11_w
          ,ref_l12_w ,ref_l13_w ,ref_l14_w ,ref_l15_w
          ,ref_l16_w ,ref_l17_w ,ref_l18_w ,ref_l19_w
          ,ref_l20_w ,ref_l21_w ,ref_l22_w ,ref_l23_w
          ,ref_l24_w ,ref_l25_w ,ref_l26_w ,ref_l27_w
          ,ref_l28_w ,ref_l29_w ,ref_l30_w ,ref_l31_w } = dat_ref_l_i ;
  assign { ref_d00_w ,ref_d01_w ,ref_d02_w ,ref_d03_w
          ,ref_d04_w ,ref_d05_w ,ref_d06_w ,ref_d07_w
          ,ref_d08_w ,ref_d09_w ,ref_d10_w ,ref_d11_w
          ,ref_d12_w ,ref_d13_w ,ref_d14_w ,ref_d15_w
          ,ref_d16_w ,ref_d17_w ,ref_d18_w ,ref_d19_w
          ,ref_d20_w ,ref_d21_w ,ref_d22_w ,ref_d23_w
          ,ref_d24_w ,ref_d25_w ,ref_d26_w ,ref_d27_w
          ,ref_d28_w ,ref_d29_w ,ref_d30_w ,ref_d31_w } = dat_ref_d_i ;

  // pre_o
  assign dat_pre_o = { pre_00_w ,pre_01_w ,pre_02_w ,pre_03_w
                      ,pre_10_w ,pre_11_w ,pre_12_w ,pre_13_w
                      ,pre_20_w ,pre_21_w ,pre_22_w ,pre_23_w
                      ,pre_30_w ,pre_31_w ,pre_32_w ,pre_33_w };


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
    case( cur_state_r )
      IDLE : begin    if( start_i & !done_busy_w )    nxt_state_w = BUSY ;
                      else                            nxt_state_w = IDLE ;
      end
      BUSY : begin    if( done_busy_w )               nxt_state_w = IDLE ;
                      else                            nxt_state_w = BUSY ;
      end
    endcase
  end

  // jump condition
  assign done_busy_w = pre_cnt_done_w ;

  // pre_cnt_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      pre_cnt_r <= 0 ;
    end
    else begin
      if( start_i || (cur_state_r==BUSY ) ) begin
        if( pre_cnt_done_w ) begin
          pre_cnt_r <= 0 ;
        end
        else begin
          pre_cnt_r <= pre_cnt_r + 1 ;
        end
      end
      else begin
        pre_cnt_r <= 0 ;
      end
    end
  end

  // pre_cnt_done_w
  always @(*) begin
    case( size_i )
      `SIZE_04 :    pre_cnt_done_w = pre_cnt_r == 04*04/16-1 ;
      `SIZE_08 :    pre_cnt_done_w = pre_cnt_r == 08*08/16-1 ;
      `SIZE_16 :    pre_cnt_done_w = pre_cnt_r == 16*16/16-1 ;
      `SIZE_32 :    pre_cnt_done_w = pre_cnt_r == 32*32/16-1 ;
    endcase
  end

  // idx_4x4_x/y_offset_w
  assign idx_4x4_x_offset_w = { pre_cnt_r[4] ,pre_cnt_r[2] ,pre_cnt_r[0] };
  assign idx_4x4_y_offset_w = { pre_cnt_r[5] ,pre_cnt_r[3] ,pre_cnt_r[1] };


//--- CORE (reused code) ---------------
  // intra_pred
  intra_pred intra_pred(
    // global
    .clk                ( clk                  ),
    .rst_n              ( rstn                 ),
    // ctrl_i
    .start_i            ( start_i || (cur_state_r==BUSY) ),
    .done_o             (/* UNSED */           ),
    // info_i
    .pre_sel_i          (`TYPE_Y               ),
    .mode_i             ( mode_i               ),
    .size_i             ( size_i               ),
    .i4x4_x_i           ( idx_4x4_x_offset_w   ),
    .i4x4_y_i           ( idx_4x4_y_offset_w   ),
    // info_o
    .size_o             (/* UNSED */           ),
    .i4x4_x_o           (/* UNSED */           ),
    .i4x4_y_o           (/* UNSED */           ),
    // reference_i
    .ref_r00_i          ( ref_r00_w            ), .ref_r01_i(ref_r01_w), .ref_r02_i(ref_r02_w), .ref_r03_i(ref_r03_w),
    .ref_r04_i          ( ref_r04_w            ), .ref_r05_i(ref_r05_w), .ref_r06_i(ref_r06_w), .ref_r07_i(ref_r07_w),
    .ref_r08_i          ( ref_r08_w            ), .ref_r09_i(ref_r09_w), .ref_r10_i(ref_r10_w), .ref_r11_i(ref_r11_w),
    .ref_r12_i          ( ref_r12_w            ), .ref_r13_i(ref_r13_w), .ref_r14_i(ref_r14_w), .ref_r15_i(ref_r15_w),
    .ref_r16_i          ( ref_r16_w            ), .ref_r17_i(ref_r17_w), .ref_r18_i(ref_r18_w), .ref_r19_i(ref_r19_w),
    .ref_r20_i          ( ref_r20_w            ), .ref_r21_i(ref_r21_w), .ref_r22_i(ref_r22_w), .ref_r23_i(ref_r23_w),
    .ref_r24_i          ( ref_r24_w            ), .ref_r25_i(ref_r25_w), .ref_r26_i(ref_r26_w), .ref_r27_i(ref_r27_w),
    .ref_r28_i          ( ref_r28_w            ), .ref_r29_i(ref_r29_w), .ref_r30_i(ref_r30_w), .ref_r31_i(ref_r31_w),
    .ref_t00_i          ( ref_t00_w            ), .ref_t01_i(ref_t01_w), .ref_t02_i(ref_t02_w), .ref_t03_i(ref_t03_w),
    .ref_t04_i          ( ref_t04_w            ), .ref_t05_i(ref_t05_w), .ref_t06_i(ref_t06_w), .ref_t07_i(ref_t07_w),
    .ref_t08_i          ( ref_t08_w            ), .ref_t09_i(ref_t09_w), .ref_t10_i(ref_t10_w), .ref_t11_i(ref_t11_w),
    .ref_t12_i          ( ref_t12_w            ), .ref_t13_i(ref_t13_w), .ref_t14_i(ref_t14_w), .ref_t15_i(ref_t15_w),
    .ref_t16_i          ( ref_t16_w            ), .ref_t17_i(ref_t17_w), .ref_t18_i(ref_t18_w), .ref_t19_i(ref_t19_w),
    .ref_t20_i          ( ref_t20_w            ), .ref_t21_i(ref_t21_w), .ref_t22_i(ref_t22_w), .ref_t23_i(ref_t23_w),
    .ref_t24_i          ( ref_t24_w            ), .ref_t25_i(ref_t25_w), .ref_t26_i(ref_t26_w), .ref_t27_i(ref_t27_w),
    .ref_t28_i          ( ref_t28_w            ), .ref_t29_i(ref_t29_w), .ref_t30_i(ref_t30_w), .ref_t31_i(ref_t31_w),
    .ref_tl_i           ( ref_tl_w             ),
    .ref_l00_i          ( ref_l00_w            ), .ref_l01_i(ref_l01_w), .ref_l02_i(ref_l02_w), .ref_l03_i(ref_l03_w),
    .ref_l04_i          ( ref_l04_w            ), .ref_l05_i(ref_l05_w), .ref_l06_i(ref_l06_w), .ref_l07_i(ref_l07_w),
    .ref_l08_i          ( ref_l08_w            ), .ref_l09_i(ref_l09_w), .ref_l10_i(ref_l10_w), .ref_l11_i(ref_l11_w),
    .ref_l12_i          ( ref_l12_w            ), .ref_l13_i(ref_l13_w), .ref_l14_i(ref_l14_w), .ref_l15_i(ref_l15_w),
    .ref_l16_i          ( ref_l16_w            ), .ref_l17_i(ref_l17_w), .ref_l18_i(ref_l18_w), .ref_l19_i(ref_l19_w),
    .ref_l20_i          ( ref_l20_w            ), .ref_l21_i(ref_l21_w), .ref_l22_i(ref_l22_w), .ref_l23_i(ref_l23_w),
    .ref_l24_i          ( ref_l24_w            ), .ref_l25_i(ref_l25_w), .ref_l26_i(ref_l26_w), .ref_l27_i(ref_l27_w),
    .ref_l28_i          ( ref_l28_w            ), .ref_l29_i(ref_l29_w), .ref_l30_i(ref_l30_w), .ref_l31_i(ref_l31_w),
    .ref_d00_i          ( ref_d00_w            ), .ref_d01_i(ref_d01_w), .ref_d02_i(ref_d02_w), .ref_d03_i(ref_d03_w),
    .ref_d04_i          ( ref_d04_w            ), .ref_d05_i(ref_d05_w), .ref_d06_i(ref_d06_w), .ref_d07_i(ref_d07_w),
    .ref_d08_i          ( ref_d08_w            ), .ref_d09_i(ref_d09_w), .ref_d10_i(ref_d10_w), .ref_d11_i(ref_d11_w),
    .ref_d12_i          ( ref_d12_w            ), .ref_d13_i(ref_d13_w), .ref_d14_i(ref_d14_w), .ref_d15_i(ref_d15_w),
    .ref_d16_i          ( ref_d16_w            ), .ref_d17_i(ref_d17_w), .ref_d18_i(ref_d18_w), .ref_d19_i(ref_d19_w),
    .ref_d20_i          ( ref_d20_w            ), .ref_d21_i(ref_d21_w), .ref_d22_i(ref_d22_w), .ref_d23_i(ref_d23_w),
    .ref_d24_i          ( ref_d24_w            ), .ref_d25_i(ref_d25_w), .ref_d26_i(ref_d26_w), .ref_d27_i(ref_d27_w),
    .ref_d28_i          ( ref_d28_w            ), .ref_d29_i(ref_d29_w), .ref_d30_i(ref_d30_w), .ref_d31_i(ref_d31_w),
    // prediction_o
    .pred_00_o          ( pre_00_w             ), .pred_01_o(pre_01_w ), .pred_02_o(pre_02_w ), .pred_03_o(pre_03_w ),
    .pred_10_o          ( pre_10_w             ), .pred_11_o(pre_11_w ), .pred_12_o(pre_12_w ), .pred_13_o(pre_13_w ),
    .pred_20_o          ( pre_20_w             ), .pred_21_o(pre_21_w ), .pred_22_o(pre_22_w ), .pred_23_o(pre_23_w ),
    .pred_30_o          ( pre_30_w             ), .pred_31_o(pre_31_w ), .pred_32_o(pre_32_w ), .pred_33_o(pre_33_w )
    );


//--- OUTPUT ---------------------------
  // delay
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      val_r           <= {{(DELAY*1){1'b0}}} ;
      mode_r          <= {{(DELAY*6){1'b0}}} ;
      size_r          <= {{(DELAY*2){1'b0}}} ;
      position_r      <= {{(DELAY*8){1'b0}}} ;
      idx_4x4_x_ahd_r <= {{(DELAY*4){1'b0}}} ;
      idx_4x4_y_ahd_r <= {{(DELAY*4){1'b0}}} ;
    end
    else begin
      val_r           <= { val_r           ,start_i || (cur_state_r==BUSY)   };
      mode_r          <= { mode_r          ,mode_i                           };
      size_r          <= { size_r          ,size_i                           };
      position_r      <= { position_r      ,position_i                       };
      idx_4x4_x_ahd_r <= { idx_4x4_x_ahd_r ,(idx_4x4_x_w|idx_4x4_x_offset_w) };
      idx_4x4_y_ahd_r <= { idx_4x4_y_ahd_r ,(idx_4x4_y_w|idx_4x4_y_offset_w) };
    end
  end

  // otuput
  assign val_ahd_o       = val_r          [(DELAY-1)*1-1:(DELAY-2)*1] ;
  assign idx_4x4_x_ahd_o = idx_4x4_x_ahd_r[(DELAY-1)*4-1:(DELAY-2)*4] ;
  assign idx_4x4_y_ahd_o = idx_4x4_y_ahd_r[(DELAY-1)*4-1:(DELAY-2)*4] ;

  assign val_o           = val_r          [(DELAY-0)*1-1:(DELAY-1)*1] ;
  assign mode_o          = mode_r         [(DELAY-0)*6-1:(DELAY-1)*6] ;
  assign size_o          = size_r         [(DELAY-0)*2-1:(DELAY-1)*2] ;
  assign position_o      = position_r     [(DELAY-0)*8-1:(DELAY-1)*8] ;


//*** DEBUG ********************************************************************

`ifdef H265_DEBUG

`endif

endmodule
