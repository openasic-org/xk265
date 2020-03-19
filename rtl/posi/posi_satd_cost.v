//--------------------------------------------------------------------
//
//  Filename    : h265_posi_satd_cost.v
//  Author      : Huang Leilei
//  Created     : 2018-04-09
//  Description : satd cost calculator in module post intra
//
//--------------------------------------------------------------------
//
//  Modified    : 2018-05-06 by HLL
//  Description : satd 4x4 merged
//
//--------------------------------------------------------------------

`include "./enc_defines.v"

module posi_satd_cost(
  // global
  clk            ,
  rstn           ,
  sys_posi4x4bit_i        ,
  // cfg_i
  qp_i           ,
  mode_i         ,
  size_i         ,
  position_i     ,
  // dat_i
  val_i          ,
  dat_i          ,
  // cfg_o
  mode_o         ,
  size_o         ,
  position_o     ,
  // val_o
  val_o          ,
  dat_o
  );


//*** PARAMETER ****************************************************************

  // local
  localparam    DELAY_SATD                  = 7             ;
  localparam    DELAY_SUMM                  = 3             ;

  // derived
  localparam    DELAY_FULL                  = DELAY_SATD+DELAY_SUMM ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                     clk             ;
  input                                     rstn            ;
  input       [6-1:0]                       qp_i            ;
  input       [5-1:0]                       sys_posi4x4bit_i;

  // cfg_i
  input       [6                  -1 :0]    mode_i          ;
  input       [2                  -1 :0]    size_i          ;
  input       [8                  -1 :0]    position_i      ;
  // dat_i
  input                                     val_i           ;
  input       [(`PIXEL_WIDTH+1)*16-1 :0]    dat_i           ;
  // cfg_o
  output      [6                  -1 :0]    mode_o          ;
  output      [2                  -1 :0]    size_o          ;
  output      [8                  -1 :0]    position_o      ;
  // dat_o
  output                                    val_o           ;
  output      [`POSI_COST_WIDTH   -1 :0]    dat_o           ;


//*** REG/WIRE *****************************************************************

  wire        [(`PIXEL_WIDTH+1)*8 -1 :0]    dat_i_0_w       ;
  wire        [(`PIXEL_WIDTH+1)*8 -1 :0]    dat_i_1_w       ;

  wire                                      val_1d_o_w      ;
  wire        [(`PIXEL_WIDTH+4)*8 -1 :0]    dat_1d_o_0_w    ;
  wire        [(`PIXEL_WIDTH+4)*8 -1 :0]    dat_1d_o_1_w    ;

  wire                                      val_tr_o_w      ;
  wire        [(`PIXEL_WIDTH+4)*16-1 :0]    dat_tr_o_w      ;

  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_0_0_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_0_1_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_0_2_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_0_3_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_1_0_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_1_1_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_1_2_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_1_3_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_2_0_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_2_1_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_2_2_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_2_3_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_3_0_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_3_1_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_3_2_w  ;
  wire        [(`PIXEL_WIDTH+4)   -1 :0]    dat_tr_o_3_3_w  ;

  wire        [(`PIXEL_WIDTH+4)*8 -1 :0]    dat_tr_o_0_w    ;
  wire        [(`PIXEL_WIDTH+4)*8 -1 :0]    dat_tr_o_1_w    ;

  wire                                      val_2d_o_w      ;
  wire        [(`PIXEL_WIDTH+7)*8 -1 :0]    dat_2d_o_0_w    ;
  wire        [(`PIXEL_WIDTH+7)*8 -1 :0]    dat_2d_o_1_w    ;

  wire                                      val_w           ;
  reg         [DELAY_SUMM         -1 :0]    val_r           ;
  reg         [DELAY_SUMM         -1 :0]    fst_r           ;
  reg         [DELAY_SUMM         -1 :0]    lst_r           ;
  reg         [6                  -1 :0]    cnt_r           ;
  reg         [6                  -1 :0]    cnt_d1          ;
  reg         [6                  -1 :0]    cnt_d2          ;
  reg                                       cnt_done_w      ;
  reg                                       cnt_done_d1     ;
  reg                                       cnt_done_d2     ;

  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_0_0_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_0_1_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_0_2_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_0_3_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_0_4_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_0_5_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_0_6_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_0_7_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_1_0_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_1_1_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_1_2_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_1_3_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_1_4_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_1_5_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_1_6_w  ;
  wire signed [ `PIXEL_WIDTH+7    -1 :0]    dat_2d_o_1_7_w  ;

  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_0_0_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_0_1_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_0_2_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_0_3_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_0_4_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_0_5_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_0_6_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_0_7_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_1_0_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_1_1_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_1_2_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_1_3_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_1_4_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_1_5_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_1_6_w   ;
  wire        [ `PIXEL_WIDTH+7    -1 :0]    dat_abs_1_7_w   ;

  wire        [ `POSI_COST_WIDTH+2-1 :0]    dat_sum_0_0_3_w ;
  wire        [ `POSI_COST_WIDTH+2-1 :0]    dat_sum_0_4_7_w ;
  wire        [ `POSI_COST_WIDTH+2-1 :0]    dat_sum_1_0_3_w ;
  wire        [ `POSI_COST_WIDTH+2-1 :0]    dat_sum_1_4_7_w ;
  reg         [ `POSI_COST_WIDTH  -1 :0]    dat_sum_0_0_3_r ;
  reg         [ `POSI_COST_WIDTH  -1 :0]    dat_sum_0_4_7_r ;
  reg         [ `POSI_COST_WIDTH  -1 :0]    dat_sum_1_0_3_r ;
  reg         [ `POSI_COST_WIDTH  -1 :0]    dat_sum_1_4_7_r ;

  reg         [ `POSI_COST_WIDTH+5-1 :0]    dat_sum_w       ;
  reg         [ `POSI_COST_WIDTH+5-1 :0]    dat_sum_shift_r ;
  reg         [ `POSI_COST_WIDTH  -1 :0]    dat_sum_r       ;
  wire        [ 2                 -1 :0]    size_satd_w     ;

  reg         [DELAY_FULL*6       -1 :0]    mode_r          ;
  reg         [DELAY_FULL*4       -1 :0]    size_r          ;
  reg         [DELAY_FULL*8       -1 :0]    position_r      ;


  wire        [13                 -1 :0]    bitrate_w       ;

//*** MAIN BODY ****************************************************************

//--- 1-D TRANSFORM --------------------
  // assignment
  assign { dat_i_0_w ,dat_i_1_w } = dat_i ;

  // h265_posi_satd_cost_engine
  posi_satd_cost_engine #(
    .DATA_WIDTH   ( `PIXEL_WIDTH+1    )
  ) posi_satd_cost_engine_1d_0(
    // global
    .clk          ( clk               ),
    .rstn         ( rstn              ),
    // cfg_i
    .size_i       ( size_i            ),
    // dat_i
    .val_i        ( val_i             ),
    .dat_i        ( dat_i_0_w         ),
    // val_o
    .val_o        ( val_1d_o_w        ),
    .dat_o        ( dat_1d_o_0_w      )
    );
  posi_satd_cost_engine #(
    .DATA_WIDTH   ( `PIXEL_WIDTH+1    )
  ) posi_satd_cost_engine_1d_1(
    // global
    .clk          ( clk               ),
    .rstn         ( rstn              ),
    // cfg_i
    .size_i       ( size_i            ),
    // dat_i
    .val_i        ( val_i             ),
    .dat_i        ( dat_i_1_w         ),
    // val_o
    .val_o        (/* UNUSED */       ),
    .dat_o        ( dat_1d_o_1_w      )
    );


//--- TRANSPOSE ------------------------
  // h265_posi_satd_cost_transpose
  posi_satd_cost_transpose #(
    .DATA_WIDTH   ( `PIXEL_WIDTH+4    )
  ) posi_satd_cost_buffer(
    // global
    .clk          ( clk               ),
    .rstn         ( rstn              ),
    // cfg_i
    .size_i       ( size_r[1*2-1:(1-1)*2]
                                      ),
    // dat_i
    .val_i        ( val_1d_o_w        ),
    .dat_i        ({dat_1d_o_0_w
                   ,dat_1d_o_1_w}     ),
    // val_o
    .val_o        ( val_tr_o_w        ),
    .dat_o        ( dat_tr_o_w        )
    );


//--- 2-D TRANSFORM --------------------
  // assignment
  assign { dat_tr_o_0_w ,dat_tr_o_1_w } = dat_tr_o_w ;

  // h265_posi_satd_cost_engine
  posi_satd_cost_engine #(
    .DATA_WIDTH   ( `PIXEL_WIDTH+4    )
  ) posi_satd_cost_engine_2d_0(
    // global
    .clk          ( clk               ),
    .rstn         ( rstn              ),
    // cfg_i
    .size_i       ( size_r[(DELAY_SATD-1)*2-1:(DELAY_SATD-2)*2]
                                      ),
    // dat_i
    .val_i        ( val_tr_o_w        ),
    .dat_i        ( dat_tr_o_0_w      ),
    // val_o
    .val_o        ( val_2d_o_w        ),
    .dat_o        ( dat_2d_o_0_w      )
    );
  posi_satd_cost_engine #(
    .DATA_WIDTH    ( `PIXEL_WIDTH+4    )
  ) posi_satd_cost_engine_2d_1(
    // global
    .clk          ( clk               ),
    .rstn         ( rstn              ),
    // cfg_i
    .size_i       ( size_r[(DELAY_SATD-1)*2-1:(DELAY_SATD-2)*2]
                                      ),
    // dat_i
    .val_i        ( val_tr_o_w        ),
    .dat_i        ( dat_tr_o_1_w      ),
    // val_o
    .val_o        (/* UNUSED */       ),
    .dat_o        ( dat_2d_o_1_w      )
    );


//--- SUMMATION ------------------------
  // assignment
  assign val_w = val_2d_o_w ;

  // valid
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      val_r <= {{(DELAY_SUMM*1){1'b0}}} ;
      fst_r <= {{(DELAY_SUMM*1){1'b0}}} ;
      lst_r <= {{(DELAY_SUMM*1){1'b0}}} ;
    end
    else begin
      val_r <= { val_r ,val_w };
      fst_r <= { fst_r ,val_w & (cnt_r==0) };
      lst_r <= { lst_r ,val_w & cnt_done_w };
    end
  end

  // count & its done signal
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_r <= 0 ;
    end
    else begin
      if( val_w ) begin
        if( cnt_done_w ) begin
          cnt_r <= 0 ;
        end
        else begin
          cnt_r <= cnt_r + 1 ;
        end
      end
    end
  end

  always @(*) begin
                    cnt_done_w = 0 ;
    case( size_r[DELAY_SATD*2-1:(DELAY_SATD-1)*2] )
      `SIZE_04 :    cnt_done_w = cnt_r == 1 -1 ;
      `SIZE_08 :    cnt_done_w = cnt_r == 4 -1 ;
      `SIZE_16 :    cnt_done_w = cnt_r == 16-1 ;
      `SIZE_32 :    cnt_done_w = cnt_r == 64-1 ;
    endcase
  end

  // assigment
  assign { dat_2d_o_0_0_w
          ,dat_2d_o_0_1_w
          ,dat_2d_o_0_2_w
          ,dat_2d_o_0_3_w
          ,dat_2d_o_0_4_w
          ,dat_2d_o_0_5_w
          ,dat_2d_o_0_6_w
          ,dat_2d_o_0_7_w } = dat_2d_o_0_w ;
  assign { dat_2d_o_1_0_w
          ,dat_2d_o_1_1_w
          ,dat_2d_o_1_2_w
          ,dat_2d_o_1_3_w
          ,dat_2d_o_1_4_w
          ,dat_2d_o_1_5_w
          ,dat_2d_o_1_6_w
          ,dat_2d_o_1_7_w } = dat_2d_o_1_w ;

  // abs
  assign dat_abs_0_0_w = ( dat_2d_o_0_0_w>0 ) ? dat_2d_o_0_0_w : -dat_2d_o_0_0_w ;
  assign dat_abs_0_1_w = ( dat_2d_o_0_1_w>0 ) ? dat_2d_o_0_1_w : -dat_2d_o_0_1_w ;
  assign dat_abs_0_2_w = ( dat_2d_o_0_2_w>0 ) ? dat_2d_o_0_2_w : -dat_2d_o_0_2_w ;
  assign dat_abs_0_3_w = ( dat_2d_o_0_3_w>0 ) ? dat_2d_o_0_3_w : -dat_2d_o_0_3_w ;
  assign dat_abs_0_4_w = ( dat_2d_o_0_4_w>0 ) ? dat_2d_o_0_4_w : -dat_2d_o_0_4_w ;
  assign dat_abs_0_5_w = ( dat_2d_o_0_5_w>0 ) ? dat_2d_o_0_5_w : -dat_2d_o_0_5_w ;
  assign dat_abs_0_6_w = ( dat_2d_o_0_6_w>0 ) ? dat_2d_o_0_6_w : -dat_2d_o_0_6_w ;
  assign dat_abs_0_7_w = ( dat_2d_o_0_7_w>0 ) ? dat_2d_o_0_7_w : -dat_2d_o_0_7_w ;
  assign dat_abs_1_0_w = ( dat_2d_o_1_0_w>0 ) ? dat_2d_o_1_0_w : -dat_2d_o_1_0_w ;
  assign dat_abs_1_1_w = ( dat_2d_o_1_1_w>0 ) ? dat_2d_o_1_1_w : -dat_2d_o_1_1_w ;
  assign dat_abs_1_2_w = ( dat_2d_o_1_2_w>0 ) ? dat_2d_o_1_2_w : -dat_2d_o_1_2_w ;
  assign dat_abs_1_3_w = ( dat_2d_o_1_3_w>0 ) ? dat_2d_o_1_3_w : -dat_2d_o_1_3_w ;
  assign dat_abs_1_4_w = ( dat_2d_o_1_4_w>0 ) ? dat_2d_o_1_4_w : -dat_2d_o_1_4_w ;
  assign dat_abs_1_5_w = ( dat_2d_o_1_5_w>0 ) ? dat_2d_o_1_5_w : -dat_2d_o_1_5_w ;
  assign dat_abs_1_6_w = ( dat_2d_o_1_6_w>0 ) ? dat_2d_o_1_6_w : -dat_2d_o_1_6_w ;
  assign dat_abs_1_7_w = ( dat_2d_o_1_7_w>0 ) ? dat_2d_o_1_7_w : -dat_2d_o_1_7_w ;

  // sum (16->4)
  assign dat_sum_0_0_3_w = dat_abs_0_0_w
                          +dat_abs_0_1_w
                          +dat_abs_0_2_w
                          +dat_abs_0_3_w ;
  assign dat_sum_0_4_7_w = dat_abs_0_4_w
                          +dat_abs_0_5_w
                          +dat_abs_0_6_w
                          +dat_abs_0_7_w ;
  assign dat_sum_1_0_3_w = dat_abs_1_0_w
                          +dat_abs_1_1_w
                          +dat_abs_1_2_w
                          +dat_abs_1_3_w ;
  assign dat_sum_1_4_7_w = dat_abs_1_4_w
                          +dat_abs_1_5_w
                          +dat_abs_1_6_w
                          +dat_abs_1_7_w ;

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      dat_sum_0_0_3_r <= 0 ;
      dat_sum_0_4_7_r <= 0 ;
      dat_sum_1_0_3_r <= 0 ;
      dat_sum_1_4_7_r <= 0 ;
    end
    else begin
      if( val_w ) begin
        dat_sum_0_0_3_r <= (dat_sum_0_0_3_w<{{`POSI_COST_WIDTH{1'b1}}}) ? dat_sum_0_0_3_w : {{`POSI_COST_WIDTH{1'b1}}} ;
        dat_sum_0_4_7_r <= (dat_sum_0_4_7_w<{{`POSI_COST_WIDTH{1'b1}}}) ? dat_sum_0_4_7_w : {{`POSI_COST_WIDTH{1'b1}}} ;
        dat_sum_1_0_3_r <= (dat_sum_1_0_3_w<{{`POSI_COST_WIDTH{1'b1}}}) ? dat_sum_1_0_3_w : {{`POSI_COST_WIDTH{1'b1}}} ;
        dat_sum_1_4_7_r <= (dat_sum_1_4_7_w<{{`POSI_COST_WIDTH{1'b1}}}) ? dat_sum_1_4_7_w : {{`POSI_COST_WIDTH{1'b1}}} ;
      end
    end
  end

  // sum (4->1)
  always @(posedge clk or negedge rstn ) begin 
    if ( !rstn ) begin 
      cnt_d1      <= 0 ; 
      cnt_done_d1 <= 0 ;
      cnt_d2      <= 0 ; 
      cnt_done_d2 <= 0 ;
    end 
    else begin 
      cnt_d1      <= cnt_r       ;
      cnt_done_d1 <= cnt_done_w  ;
      cnt_d2      <= cnt_d1      ;
      cnt_done_d2 <= cnt_done_d1 ;
    end 
  end 

  always @(*) begin 
    if( (fst_r[0] || cnt_d1[1:0] == 0) ) begin
      dat_sum_w =  dat_sum_0_0_3_r
                  +dat_sum_0_4_7_r
                  +dat_sum_1_0_3_r
                  +dat_sum_1_4_7_r ;
    end
    else begin
      dat_sum_w = dat_sum_r 
                 +dat_sum_0_0_3_r
                 +dat_sum_0_4_7_r
                 +dat_sum_1_0_3_r
                 +dat_sum_1_4_7_r ;
    end
  end

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      dat_sum_r <= {{`POSI_COST_WIDTH{1'b1}}} ;
    end
    else begin
      if( val_r[0] ) begin
        dat_sum_r <= (dat_sum_w<{{`POSI_COST_WIDTH{1'b1}}}) ? dat_sum_w : {{`POSI_COST_WIDTH{1'b1}}} ;
      end
    end
  end

  assign size_satd_w = size_r[(DELAY_SATD+1)*2-1:(DELAY_SATD)*2] ;

  always @ (posedge clk or negedge rstn ) begin 
    if ( !rstn )
      dat_sum_shift_r <= 0 ;
    else if ( size_satd_w == `SIZE_04 )
      dat_sum_shift_r <= (dat_sum_r+1)>>1;
    else if ( cnt_d2[1:0] == 3 )
      dat_sum_shift_r <= dat_sum_shift_r + ((dat_sum_r+2)>>2) ;
    else if ( cnt_d2 == 0 ) 
      dat_sum_shift_r <= 0 ;
  end 
//--- OUTPUT ---------------------------
  // delay
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      mode_r          <= {{(DELAY_FULL*6){1'b0}}} ;
      size_r          <= {{(DELAY_FULL*2){1'b0}}} ;
      position_r      <= {{(DELAY_FULL*8){1'b0}}} ;
    end
    else begin
      mode_r          <= { mode_r     ,mode_i     };
      size_r          <= { size_r     ,size_i     };
      position_r      <= { position_r ,position_i };
    end
  end

  // cfg_o
  assign mode_o     = mode_r    [DELAY_FULL*6-1:(DELAY_FULL-1)*6] ;
  assign size_o     = size_r    [DELAY_FULL*2-1:(DELAY_FULL-1)*2] ;
  assign position_o = position_r[DELAY_FULL*8-1:(DELAY_FULL-1)*8] ;

//--- RATE ESTIMATION ------------------
  
  posi_rate_estimation u_posi_rate_estimation(
    .clk             ( clk                ),
    .rstn            ( rstn               ),
    .sys_posi4x4bit_i( sys_posi4x4bit_i   ),
    // cfg_i
    .qp_i            ( qp_i               ),
    .mode_i          ( mode_o             ),
    .size_i          ( size_o             ),
    .position_i      ( position_o         ),
    .cost_done_i     ( val_o              ), // To update left mode
    // rate        
    .bitrate_o       ( bitrate_w          )
  );

  // dat_o
  assign val_o = lst_r[DELAY_SUMM-1] ;
  assign dat_o = dat_sum_shift_r+bitrate_w ;

//*** DEBUG ********************************************************************

`ifdef H265_DEBUG

`endif

endmodule
