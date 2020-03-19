//--------------------------------------------------------------------
//
//  Filename    : h265_posi_satd_cost_transpose.v
//  Author      : Huang Leilei
//  Created     : 2018-04-08
//  Description : transpose buffer of satd cost calculator in module post intra
//
//--------------------------------------------------------------------
//
//  Modified    : 2018-05-06 by HLL
//  Description : satd 4x4 merged
//
//--------------------------------------------------------------------

`include "./enc_defines.v"

module posi_satd_cost_transpose(
  // global
  clk       ,
  rstn      ,
  // cfg_i
  size_i    ,
  // dat_i
  val_i     ,
  dat_i     ,
  // val_o
  val_o     ,
  dat_o
  );


//*** PARAMETER ****************************************************************

  // global
  parameter    DATA_WIDTH             = 9          ;

  // local
  localparam   DELAY                  = 5          ;

  localparam   DIR_HOR                = 0          ;
  localparam   DIR_VER                = 1          ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                               clk          ;
  input                               rstn         ;
  // cfg_i
  input       [2            -1 :0]    size_i       ;
  // dat_i
  input                               val_i        ;
  input       [DATA_WIDTH*16-1 :0]    dat_i        ;
  // dat_o
  output                              val_o        ;
  output reg  [DATA_WIDTH*16-1 :0]    dat_o        ;


//*** REG/WIRE *****************************************************************

  reg         [DELAY        -1 :0]    val_r        ;
  reg         [DELAY*2      -1 :0]    size_r       ;
  reg         [2            -1 :0]    cnt_r        ;
  wire                                cnt_done_w   ;

  wire                                val_w        ;
  
  reg                                 dir_r        ;

  reg         [DATA_WIDTH   -1 :0]    dat_0_0_r    ,dat_1_0_r ,dat_2_0_r ,dat_3_0_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_0_1_r    ,dat_1_1_r ,dat_2_1_r ,dat_3_1_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_0_2_r    ,dat_1_2_r ,dat_2_2_r ,dat_3_2_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_0_3_r    ,dat_1_3_r ,dat_2_3_r ,dat_3_3_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_0_4_r    ,dat_1_4_r ,dat_2_4_r ,dat_3_4_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_0_5_r    ,dat_1_5_r ,dat_2_5_r ,dat_3_5_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_0_6_r    ,dat_1_6_r ,dat_2_6_r ,dat_3_6_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_0_7_r    ,dat_1_7_r ,dat_2_7_r ,dat_3_7_r ;

  reg         [DATA_WIDTH   -1 :0]    dat_4_0_r    ,dat_5_0_r ,dat_6_0_r ,dat_7_0_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_4_1_r    ,dat_5_1_r ,dat_6_1_r ,dat_7_1_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_4_2_r    ,dat_5_2_r ,dat_6_2_r ,dat_7_2_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_4_3_r    ,dat_5_3_r ,dat_6_3_r ,dat_7_3_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_4_4_r    ,dat_5_4_r ,dat_6_4_r ,dat_7_4_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_4_5_r    ,dat_5_5_r ,dat_6_5_r ,dat_7_5_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_4_6_r    ,dat_5_6_r ,dat_6_6_r ,dat_7_6_r ;
  reg         [DATA_WIDTH   -1 :0]    dat_4_7_r    ,dat_5_7_r ,dat_6_7_r ,dat_7_7_r ;


//*** MAIN BODY ****************************************************************

//--- BUFFER ---------------------------
  // val_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      val_r  <= 0 ;
      size_r <= 0 ;
    end
    else begin
      val_r  <= { val_r  ,val_i  };
      size_r <= { size_r ,size_i };
    end
  end

  // cnt_r & its done signal
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_r <= 0 ;
    end
    else begin
      if( val_i && (size_i!=`SIZE_04) ) begin
        if( cnt_done_w ) begin
          cnt_r <= 0 ;
        end
        else begin
          cnt_r <= cnt_r + 1 ;
        end
      end
      else begin
        cnt_r <= 0 ;
      end
    end
  end

  assign cnt_done_w = cnt_r==3 ;

  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      dir_r <= DIR_HOR ;
    end
    else begin
      if( val_i && (size_i!=`SIZE_04) && cnt_done_w ) begin
        case( dir_r )
          DIR_HOR :    dir_r <= DIR_VER ;
          DIR_VER :    dir_r <= DIR_HOR ;
        endcase
      end
    end
  end


  // val_w
  assign val_w = | val_r[2:0] ;

  // dat_x_x_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      { dat_0_0_r ,dat_1_0_r ,dat_2_0_r ,dat_3_0_r ,dat_4_0_r ,dat_5_0_r ,dat_6_0_r ,dat_7_0_r } <= {{(DATA_WIDTH*8){1'b0}}} ;
      { dat_0_1_r ,dat_1_1_r ,dat_2_1_r ,dat_3_1_r ,dat_4_1_r ,dat_5_1_r ,dat_6_1_r ,dat_7_1_r } <= {{(DATA_WIDTH*8){1'b0}}} ;
      { dat_0_2_r ,dat_1_2_r ,dat_2_2_r ,dat_3_2_r ,dat_4_2_r ,dat_5_2_r ,dat_6_2_r ,dat_7_2_r } <= {{(DATA_WIDTH*8){1'b0}}} ;
      { dat_0_3_r ,dat_1_3_r ,dat_2_3_r ,dat_3_3_r ,dat_4_3_r ,dat_5_3_r ,dat_6_3_r ,dat_7_3_r } <= {{(DATA_WIDTH*8){1'b0}}} ;
      { dat_0_4_r ,dat_1_4_r ,dat_2_4_r ,dat_3_4_r ,dat_4_4_r ,dat_5_4_r ,dat_6_4_r ,dat_7_4_r } <= {{(DATA_WIDTH*8){1'b0}}} ;
      { dat_0_5_r ,dat_1_5_r ,dat_2_5_r ,dat_3_5_r ,dat_4_5_r ,dat_5_5_r ,dat_6_5_r ,dat_7_5_r } <= {{(DATA_WIDTH*8){1'b0}}} ;
      { dat_0_6_r ,dat_1_6_r ,dat_2_6_r ,dat_3_6_r ,dat_4_6_r ,dat_5_6_r ,dat_6_6_r ,dat_7_6_r } <= {{(DATA_WIDTH*8){1'b0}}} ;
      { dat_0_7_r ,dat_1_7_r ,dat_2_7_r ,dat_3_7_r ,dat_4_7_r ,dat_5_7_r ,dat_6_7_r ,dat_7_7_r } <= {{(DATA_WIDTH*8){1'b0}}} ;
    end
    else begin
      if( val_i | val_w ) begin
        case( dir_r )
          DIR_HOR : begin
            // row 0 & 1
            { dat_0_0_r ,dat_0_1_r ,dat_0_2_r ,dat_0_3_r ,dat_0_4_r ,dat_0_5_r ,dat_0_6_r ,dat_0_7_r
             ,dat_1_0_r ,dat_1_1_r ,dat_1_2_r ,dat_1_3_r ,dat_1_4_r ,dat_1_5_r ,dat_1_6_r ,dat_1_7_r } <= dat_i ;

            // row 2 & 3
            { dat_2_0_r ,dat_2_1_r ,dat_2_2_r ,dat_2_3_r ,dat_2_4_r ,dat_2_5_r ,dat_2_6_r ,dat_2_7_r
             ,dat_3_0_r ,dat_3_1_r ,dat_3_2_r ,dat_3_3_r ,dat_3_4_r ,dat_3_5_r ,dat_3_6_r ,dat_3_7_r } <= { dat_0_0_r ,dat_0_1_r ,dat_0_2_r ,dat_0_3_r ,dat_0_4_r ,dat_0_5_r ,dat_0_6_r ,dat_0_7_r
                                                                                                           ,dat_1_0_r ,dat_1_1_r ,dat_1_2_r ,dat_1_3_r ,dat_1_4_r ,dat_1_5_r ,dat_1_6_r ,dat_1_7_r };
            // row 4 & 5
            { dat_4_0_r ,dat_4_1_r ,dat_4_2_r ,dat_4_3_r ,dat_4_4_r ,dat_4_5_r ,dat_4_6_r ,dat_4_7_r
             ,dat_5_0_r ,dat_5_1_r ,dat_5_2_r ,dat_5_3_r ,dat_5_4_r ,dat_5_5_r ,dat_5_6_r ,dat_5_7_r } <= { dat_2_0_r ,dat_2_1_r ,dat_2_2_r ,dat_2_3_r ,dat_2_4_r ,dat_2_5_r ,dat_2_6_r ,dat_2_7_r
                                                                                                           ,dat_3_0_r ,dat_3_1_r ,dat_3_2_r ,dat_3_3_r ,dat_3_4_r ,dat_3_5_r ,dat_3_6_r ,dat_3_7_r };
            // row 6 & 7
            { dat_6_0_r ,dat_6_1_r ,dat_6_2_r ,dat_6_3_r ,dat_6_4_r ,dat_6_5_r ,dat_6_6_r ,dat_6_7_r
             ,dat_7_0_r ,dat_7_1_r ,dat_7_2_r ,dat_7_3_r ,dat_7_4_r ,dat_7_5_r ,dat_7_6_r ,dat_7_7_r } <= { dat_4_0_r ,dat_4_1_r ,dat_4_2_r ,dat_4_3_r ,dat_4_4_r ,dat_4_5_r ,dat_4_6_r ,dat_4_7_r
                                                                                                           ,dat_5_0_r ,dat_5_1_r ,dat_5_2_r ,dat_5_3_r ,dat_5_4_r ,dat_5_5_r ,dat_5_6_r ,dat_5_7_r };
          end
          DIR_VER : begin
            // col 0 & 1
            { dat_0_0_r ,dat_1_0_r ,dat_2_0_r ,dat_3_0_r ,dat_4_0_r ,dat_5_0_r ,dat_6_0_r ,dat_7_0_r
             ,dat_0_1_r ,dat_1_1_r ,dat_2_1_r ,dat_3_1_r ,dat_4_1_r ,dat_5_1_r ,dat_6_1_r ,dat_7_1_r } <= dat_i ;

            // col 2 & 3
            { dat_0_2_r ,dat_1_2_r ,dat_2_2_r ,dat_3_2_r ,dat_4_2_r ,dat_5_2_r ,dat_6_2_r ,dat_7_2_r
             ,dat_0_3_r ,dat_1_3_r ,dat_2_3_r ,dat_3_3_r ,dat_4_3_r ,dat_5_3_r ,dat_6_3_r ,dat_7_3_r } <= { dat_0_0_r ,dat_1_0_r ,dat_2_0_r ,dat_3_0_r ,dat_4_0_r ,dat_5_0_r ,dat_6_0_r ,dat_7_0_r
                                                                                                           ,dat_0_1_r ,dat_1_1_r ,dat_2_1_r ,dat_3_1_r ,dat_4_1_r ,dat_5_1_r ,dat_6_1_r ,dat_7_1_r };
            // col 4 & 5
            { dat_0_4_r ,dat_1_4_r ,dat_2_4_r ,dat_3_4_r ,dat_4_4_r ,dat_5_4_r ,dat_6_4_r ,dat_7_4_r
             ,dat_0_5_r ,dat_1_5_r ,dat_2_5_r ,dat_3_5_r ,dat_4_5_r ,dat_5_5_r ,dat_6_5_r ,dat_7_5_r } <= { dat_0_2_r ,dat_1_2_r ,dat_2_2_r ,dat_3_2_r ,dat_4_2_r ,dat_5_2_r ,dat_6_2_r ,dat_7_2_r
                                                                                                           ,dat_0_3_r ,dat_1_3_r ,dat_2_3_r ,dat_3_3_r ,dat_4_3_r ,dat_5_3_r ,dat_6_3_r ,dat_7_3_r };
            // col 6 & 7
            { dat_0_6_r ,dat_1_6_r ,dat_2_6_r ,dat_3_6_r ,dat_4_6_r ,dat_5_6_r ,dat_6_6_r ,dat_7_6_r
             ,dat_0_7_r ,dat_1_7_r ,dat_2_7_r ,dat_3_7_r ,dat_4_7_r ,dat_5_7_r ,dat_6_7_r ,dat_7_7_r } <= { dat_0_4_r ,dat_1_4_r ,dat_2_4_r ,dat_3_4_r ,dat_4_4_r ,dat_5_4_r ,dat_6_4_r ,dat_7_4_r
                                                                                                           ,dat_0_5_r ,dat_1_5_r ,dat_2_5_r ,dat_3_5_r ,dat_4_5_r ,dat_5_5_r ,dat_6_5_r ,dat_7_5_r };
          end
        endcase
      end
    end
  end


//--- OUTPUT ---------------------------
  // val_o
  assign val_o = val_r[DELAY-1] ;

  // dat_o
  always @(posedge clk or negedge rstn ) begin    // TODO: change dat_o to combinational output if timing is okay
    if( !rstn ) begin
      dat_o <= {{(DATA_WIDTH*16){1'b0}}} ;
    end
    else begin
      if( dir_r==DIR_HOR ) begin
        if( size_r[(DELAY-1)*2-1:((DELAY-2)-1)*2] != `SIZE_04 ) begin
          dat_o <= { dat_6_0_r ,dat_6_1_r ,dat_6_2_r ,dat_6_3_r ,dat_6_4_r ,dat_6_5_r ,dat_6_6_r ,dat_6_7_r
                    ,dat_7_0_r ,dat_7_1_r ,dat_7_2_r ,dat_7_3_r ,dat_7_4_r ,dat_7_5_r ,dat_7_6_r ,dat_7_7_r };
        end
        else begin
          dat_o <= { dat_6_0_r ,dat_6_4_r ,dat_7_0_r ,dat_7_4_r
                    ,dat_6_1_r ,dat_6_5_r ,dat_7_1_r ,dat_7_5_r
                    ,dat_6_2_r ,dat_6_6_r ,dat_7_2_r ,dat_7_6_r
                    ,dat_6_3_r ,dat_6_7_r ,dat_7_3_r ,dat_7_7_r };
        end
      end
      else begin
        if( size_r[(DELAY-1)*2-1:((DELAY-2)-1)*2] != `SIZE_04 ) begin
          dat_o <= { dat_6_6_r ,dat_7_6_r ,dat_4_6_r ,dat_5_6_r ,dat_2_6_r ,dat_3_6_r ,dat_0_6_r ,dat_1_6_r
                    ,dat_6_7_r ,dat_7_7_r ,dat_4_7_r ,dat_5_7_r ,dat_2_7_r ,dat_3_7_r ,dat_0_7_r ,dat_1_7_r };
        end
        else begin
          dat_o <= { dat_6_6_r ,dat_2_6_r ,dat_6_7_r ,dat_2_7_r
                    ,dat_7_6_r ,dat_3_6_r ,dat_7_7_r ,dat_3_7_r
                    ,dat_4_6_r ,dat_0_6_r ,dat_4_7_r ,dat_0_7_r
                    ,dat_5_6_r ,dat_1_6_r ,dat_5_7_r ,dat_1_7_r };
        end
      end
    end
  end



//*** DEBUG ********************************************************************

`ifdef H265_DEBUG

`endif

endmodule
