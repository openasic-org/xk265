//--------------------------------------------------------------------
//
//  Filename    : h265_posi_buffer.v
//  Author      : Huang Leilei
//  Description : buffer for predicted data in module post intra
//  Created     : 2018-04-09
//
//--------------------------------------------------------------------

`include "./enc_defines.v"

module posi_buffer(
  // global
  clk               ,
  rstn              ,
  // ahd_i               // one cycle ahead
  val_ahd_i         ,
  idx_4x4_x_ahd_i   ,
  idx_4x4_y_ahd_i   ,
  // cfg_i
  val_i             ,
  mode_i            ,
  size_i            ,
  position_i        ,
  // dat_i
  dat_i             ,
  // ori_if
  ori_rd_ena_o      ,
  ori_rd_siz_o      ,
  ori_rd_4x4_x_o    ,
  ori_rd_4x4_y_o    ,
  ori_rd_idx_o      ,
  ori_rd_dat_i      ,
  // cfg_o
  mode_o            ,
  size_o            ,
  position_o        ,
  // dat_o
  val_o             ,
  dat_o
  );


//*** PARAMETER ****************************************************************

  // local
  localparam    DELAY                      = 2                  ;

//*** INPUT/OUTPUT *************************************************************

  // global
  input                                    clk                  ;
  input                                    rstn                 ;
  // ahd_i
  input                                    val_ahd_i            ;
  input      [4                  -1 :0]    idx_4x4_x_ahd_i      ;
  input      [4                  -1 :0]    idx_4x4_y_ahd_i      ;
  // cfg_i
  input      [6                  -1 :0]    mode_i               ;
  input      [2                  -1 :0]    size_i               ;
  input      [8                  -1 :0]    position_i           ;
  // dat_i
  input                                    val_i                ;
  input      [`PIXEL_WIDTH*16    -1 :0]    dat_i                ;
  // ori_if
  output                                   ori_rd_ena_o         ;
  output     [2                  -1 :0]    ori_rd_siz_o         ;
  output     [4                  -1 :0]    ori_rd_4x4_x_o       ;
  output     [4                  -1 :0]    ori_rd_4x4_y_o       ;
  output     [5                  -1 :0]    ori_rd_idx_o         ;
  input      [`PIXEL_WIDTH*32    -1 :0]    ori_rd_dat_i         ;
  // cfg_o
  output     [6                  -1 :0]    mode_o               ;
  output     [2                  -1 :0]    size_o               ;
  output     [8                  -1 :0]    position_o           ;
  // dat_o
  output                                   val_o                ;
  output reg [(`PIXEL_WIDTH+1)*16-1 :0]    dat_o                ;


//*** REG/WIRE *****************************************************************

  // assignment
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_0_0_w ,ori_rd_dat_i_b_0_0_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_0_1_w ,ori_rd_dat_i_b_0_1_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_0_2_w ,ori_rd_dat_i_b_0_2_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_0_3_w ,ori_rd_dat_i_b_0_3_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_1_0_w ,ori_rd_dat_i_b_1_0_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_1_1_w ,ori_rd_dat_i_b_1_1_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_1_2_w ,ori_rd_dat_i_b_1_2_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_1_3_w ,ori_rd_dat_i_b_1_3_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_2_0_w ,ori_rd_dat_i_b_2_0_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_2_1_w ,ori_rd_dat_i_b_2_1_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_2_2_w ,ori_rd_dat_i_b_2_2_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_2_3_w ,ori_rd_dat_i_b_2_3_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_3_0_w ,ori_rd_dat_i_b_3_0_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_3_1_w ,ori_rd_dat_i_b_3_1_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_3_2_w ,ori_rd_dat_i_b_3_2_w ;
  wire       [`PIXEL_WIDTH       -1 :0]    ori_rd_dat_i_a_3_3_w ,ori_rd_dat_i_b_3_3_w ;

  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_0_0_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_0_1_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_0_2_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_0_3_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_1_0_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_1_1_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_1_2_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_1_3_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_2_0_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_2_1_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_2_2_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_2_3_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_3_0_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_3_1_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_3_2_w          ;
  wire       [`PIXEL_WIDTH       -1 :0]    dat_i_3_3_w          ;


  wire       [4                  -1 :0]    idx_4x4_x_base_w     ;
  wire       [4                  -1 :0]    idx_4x4_y_base_w     ;

  // ori
  wire       [4                  -1 :0]    idx_4x4_x_offset_r   ;
  wire       [4                  -1 :0]    idx_4x4_y_offset_r   ;

  // dif
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_0_0_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_0_1_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_0_2_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_0_3_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_1_0_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_1_1_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_1_2_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_1_3_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_2_0_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_2_1_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_2_2_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_2_3_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_3_0_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_3_1_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_3_2_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d0_3_3_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_0_0_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_0_1_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_0_2_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_0_3_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_1_0_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_1_1_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_1_2_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_1_3_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_2_0_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_2_1_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_2_2_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_2_3_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_3_0_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_3_1_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_3_2_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d1_3_3_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d2_2_0_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d2_2_1_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d2_2_2_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d2_2_3_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d2_3_0_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d2_3_1_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d2_3_2_r     ;
  reg        [`PIXEL_WIDTH+1     -1 :0]    dat_dif_d2_3_3_r     ;

  reg        [DELAY*1            -1 :0]    val_r                ;
  reg        [DELAY*6            -1 :0]    mode_r               ;
  reg        [DELAY*4            -1 :0]    size_r               ;
  reg        [DELAY*8            -1 :0]    position_r           ;

  // output
  reg                                      cnt_r                ;
  wire                                     cnt_done_w           ;


//*** MAIN BODY ****************************************************************

//--- ASSIGNMENT -----------------------
  //  ori_dat
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

  // dat_i
  assign { dat_i_0_0_w
          ,dat_i_0_1_w
          ,dat_i_0_2_w
          ,dat_i_0_3_w
          ,dat_i_1_0_w
          ,dat_i_1_1_w
          ,dat_i_1_2_w
          ,dat_i_1_3_w
          ,dat_i_2_0_w
          ,dat_i_2_1_w
          ,dat_i_2_2_w
          ,dat_i_2_3_w
          ,dat_i_3_0_w
          ,dat_i_3_1_w
          ,dat_i_3_2_w
          ,dat_i_3_3_w } = dat_i ;


//--- ORI ------------------------------
  // ori_* related assignment
  assign ori_rd_ena_o   = val_ahd_i ;
  assign ori_rd_siz_o   = `SIZE_04 ;
  assign ori_rd_4x4_x_o = idx_4x4_x_ahd_i ;
  assign ori_rd_4x4_y_o = idx_4x4_y_ahd_i ;
  assign ori_rd_idx_o   = 0 ;


//--- DIF ------------------------------
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      dat_dif_d0_0_0_r <= 0 ;
      dat_dif_d0_0_1_r <= 0 ;
      dat_dif_d0_0_2_r <= 0 ;
      dat_dif_d0_0_3_r <= 0 ;
      dat_dif_d0_1_0_r <= 0 ;
      dat_dif_d0_1_1_r <= 0 ;
      dat_dif_d0_1_2_r <= 0 ;
      dat_dif_d0_1_3_r <= 0 ;
      dat_dif_d0_2_0_r <= 0 ;
      dat_dif_d0_2_1_r <= 0 ;
      dat_dif_d0_2_2_r <= 0 ;
      dat_dif_d0_2_3_r <= 0 ;
      dat_dif_d0_3_0_r <= 0 ;
      dat_dif_d0_3_1_r <= 0 ;
      dat_dif_d0_3_2_r <= 0 ;
      dat_dif_d0_3_3_r <= 0 ;
      dat_dif_d1_0_0_r <= 0 ;
      dat_dif_d1_0_1_r <= 0 ;
      dat_dif_d1_0_2_r <= 0 ;
      dat_dif_d1_0_3_r <= 0 ;
      dat_dif_d1_1_0_r <= 0 ;
      dat_dif_d1_1_1_r <= 0 ;
      dat_dif_d1_1_2_r <= 0 ;
      dat_dif_d1_1_3_r <= 0 ;
      dat_dif_d1_2_0_r <= 0 ;
      dat_dif_d1_2_1_r <= 0 ;
      dat_dif_d1_2_2_r <= 0 ;
      dat_dif_d1_2_3_r <= 0 ;
      dat_dif_d1_3_0_r <= 0 ;
      dat_dif_d1_3_1_r <= 0 ;
      dat_dif_d1_3_2_r <= 0 ;
      dat_dif_d1_3_3_r <= 0 ;
      dat_dif_d2_2_0_r <= 0 ;
      dat_dif_d2_2_1_r <= 0 ;
      dat_dif_d2_2_2_r <= 0 ;
      dat_dif_d2_2_3_r <= 0 ;
      dat_dif_d2_3_0_r <= 0 ;
      dat_dif_d2_3_1_r <= 0 ;
      dat_dif_d2_3_2_r <= 0 ;
      dat_dif_d2_3_3_r <= 0 ;
    end
    else begin
      if( val_i ) begin
        dat_dif_d0_0_0_r <= {1'b0,ori_rd_dat_i_a_0_0_w} - {1'b0,dat_i_0_0_w} ;
        dat_dif_d0_0_1_r <= {1'b0,ori_rd_dat_i_a_0_1_w} - {1'b0,dat_i_0_1_w} ;
        dat_dif_d0_0_2_r <= {1'b0,ori_rd_dat_i_a_0_2_w} - {1'b0,dat_i_0_2_w} ;
        dat_dif_d0_0_3_r <= {1'b0,ori_rd_dat_i_a_0_3_w} - {1'b0,dat_i_0_3_w} ;
        dat_dif_d0_1_0_r <= {1'b0,ori_rd_dat_i_a_1_0_w} - {1'b0,dat_i_1_0_w} ;
        dat_dif_d0_1_1_r <= {1'b0,ori_rd_dat_i_a_1_1_w} - {1'b0,dat_i_1_1_w} ;
        dat_dif_d0_1_2_r <= {1'b0,ori_rd_dat_i_a_1_2_w} - {1'b0,dat_i_1_2_w} ;
        dat_dif_d0_1_3_r <= {1'b0,ori_rd_dat_i_a_1_3_w} - {1'b0,dat_i_1_3_w} ;
        dat_dif_d0_2_0_r <= {1'b0,ori_rd_dat_i_a_2_0_w} - {1'b0,dat_i_2_0_w} ;
        dat_dif_d0_2_1_r <= {1'b0,ori_rd_dat_i_a_2_1_w} - {1'b0,dat_i_2_1_w} ;
        dat_dif_d0_2_2_r <= {1'b0,ori_rd_dat_i_a_2_2_w} - {1'b0,dat_i_2_2_w} ;
        dat_dif_d0_2_3_r <= {1'b0,ori_rd_dat_i_a_2_3_w} - {1'b0,dat_i_2_3_w} ;
        dat_dif_d0_3_0_r <= {1'b0,ori_rd_dat_i_a_3_0_w} - {1'b0,dat_i_3_0_w} ;
        dat_dif_d0_3_1_r <= {1'b0,ori_rd_dat_i_a_3_1_w} - {1'b0,dat_i_3_1_w} ;
        dat_dif_d0_3_2_r <= {1'b0,ori_rd_dat_i_a_3_2_w} - {1'b0,dat_i_3_2_w} ;
        dat_dif_d0_3_3_r <= {1'b0,ori_rd_dat_i_a_3_3_w} - {1'b0,dat_i_3_3_w} ;
      end
      if( val_r[0] ) begin
        dat_dif_d1_0_0_r <= dat_dif_d0_0_0_r ;
        dat_dif_d1_0_1_r <= dat_dif_d0_0_1_r ;
        dat_dif_d1_0_2_r <= dat_dif_d0_0_2_r ;
        dat_dif_d1_0_3_r <= dat_dif_d0_0_3_r ;
        dat_dif_d1_1_0_r <= dat_dif_d0_1_0_r ;
        dat_dif_d1_1_1_r <= dat_dif_d0_1_1_r ;
        dat_dif_d1_1_2_r <= dat_dif_d0_1_2_r ;
        dat_dif_d1_1_3_r <= dat_dif_d0_1_3_r ;
        dat_dif_d1_2_0_r <= dat_dif_d0_2_0_r ;
        dat_dif_d1_2_1_r <= dat_dif_d0_2_1_r ;
        dat_dif_d1_2_2_r <= dat_dif_d0_2_2_r ;
        dat_dif_d1_2_3_r <= dat_dif_d0_2_3_r ;
        dat_dif_d1_3_0_r <= dat_dif_d0_3_0_r ;
        dat_dif_d1_3_1_r <= dat_dif_d0_3_1_r ;
        dat_dif_d1_3_2_r <= dat_dif_d0_3_2_r ;
        dat_dif_d1_3_3_r <= dat_dif_d0_3_3_r ;
      end
      if( val_r[1] ) begin
        dat_dif_d2_2_0_r <= dat_dif_d1_2_0_r ;
        dat_dif_d2_2_1_r <= dat_dif_d1_2_1_r ;
        dat_dif_d2_2_2_r <= dat_dif_d1_2_2_r ;
        dat_dif_d2_2_3_r <= dat_dif_d1_2_3_r ;
        dat_dif_d2_3_0_r <= dat_dif_d1_3_0_r ;
        dat_dif_d2_3_1_r <= dat_dif_d1_3_1_r ;
        dat_dif_d2_3_2_r <= dat_dif_d1_3_2_r ;
        dat_dif_d2_3_3_r <= dat_dif_d1_3_3_r ;
      end
    end
  end

//--- DELAY ----------------------------
  // delay
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      val_r           <= {{( DELAY   *1){1'b0}}} ;
      mode_r          <= {{( DELAY   *6){1'b0}}} ;
      size_r          <= {{( DELAY   *2){1'b0}}} ;
      position_r      <= {{( DELAY   *8){1'b0}}} ;
    end
    else begin
      val_r           <= { val_r      ,val_i      };
      mode_r          <= { mode_r     ,mode_i     };
      size_r          <= { size_r     ,size_i     };
      position_r      <= { position_r ,position_i };
    end
  end


//--- OUTPUT ---------------------------
  // cfg_o
  assign mode_o     = mode_r    [DELAY*6-1:(DELAY-1)*6] ;
  assign size_o     = size_r    [DELAY*2-1:(DELAY-1)*2] ;
  assign position_o = position_r[DELAY*8-1:(DELAY-1)*8] ;

  // val_o
  assign val_o = val_r[DELAY-1] ;

  // dat_o
  always @(*) begin
    if( size_o==`SIZE_04 ) begin
      dat_o = { dat_dif_d1_0_0_r,dat_dif_d1_0_1_r,dat_dif_d1_0_2_r,dat_dif_d1_0_3_r
               ,dat_dif_d1_1_0_r,dat_dif_d1_1_1_r,dat_dif_d1_1_2_r,dat_dif_d1_1_3_r
               ,dat_dif_d1_2_0_r,dat_dif_d1_2_1_r,dat_dif_d1_2_2_r,dat_dif_d1_2_3_r
               ,dat_dif_d1_3_0_r,dat_dif_d1_3_1_r,dat_dif_d1_3_2_r,dat_dif_d1_3_3_r };
    end
    else begin
      if( cnt_r==0 ) begin
        dat_o = { dat_dif_d1_0_0_r,dat_dif_d1_0_1_r,dat_dif_d1_0_2_r,dat_dif_d1_0_3_r,dat_dif_d0_0_0_r,dat_dif_d0_0_1_r,dat_dif_d0_0_2_r,dat_dif_d0_0_3_r
                 ,dat_dif_d1_1_0_r,dat_dif_d1_1_1_r,dat_dif_d1_1_2_r,dat_dif_d1_1_3_r,dat_dif_d0_1_0_r,dat_dif_d0_1_1_r,dat_dif_d0_1_2_r,dat_dif_d0_1_3_r };
      end
      else begin
        dat_o = { dat_dif_d2_2_0_r,dat_dif_d2_2_1_r,dat_dif_d2_2_2_r,dat_dif_d2_2_3_r,dat_dif_d1_2_0_r,dat_dif_d1_2_1_r,dat_dif_d1_2_2_r,dat_dif_d1_2_3_r
                 ,dat_dif_d2_3_0_r,dat_dif_d2_3_1_r,dat_dif_d2_3_2_r,dat_dif_d2_3_3_r,dat_dif_d1_3_0_r,dat_dif_d1_3_1_r,dat_dif_d1_3_2_r,dat_dif_d1_3_3_r };
      end
    end
  end

  // cnt_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_r <= 0 ;
    end
    else begin
      if( val_o ) begin
        if( cnt_done_w ) begin
          cnt_r <= 0 ;
        end
        else begin
          cnt_r <= cnt_r + 1 ;
        end
      end
    end
  end

  assign cnt_done_w = cnt_r == 1 ;


//*** DEBUG ********************************************************************

`ifdef H265_DEBUG

`endif

endmodule
