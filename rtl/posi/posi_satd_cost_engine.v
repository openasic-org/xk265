//--------------------------------------------------------------------
//
//  Filename    : h265_posi_satd_cost_engine.v
//  Author      : Huang Leilei
//  Description : engine of satd cost calculator in module post intra
//  Created     : 2018-04-08
//
//--------------------------------------------------------------------
//
//  Modified    : 2018-05-06 by HLL
//  Description : satd 4x4 merged
//
//--------------------------------------------------------------------

`include "./enc_defines.v"

module posi_satd_cost_engine(
  // global
  clk            ,
  rstn           ,
  // cfg_i
  size_i         ,
  // dat_i
  val_i          ,
  dat_i          ,
  // val_o
  val_o          ,
  dat_o
  );


//*** PARAMETER ****************************************************************

  // global
  parameter    DATA_WIDTH                = 9          ;


//*** INPUT/OUTPUT *************************************************************

  // global
  input                                  clk          ;
  input                                  rstn         ;
  // cfg_i
  input       [ 2              -1 :0]    size_i       ;
  // dat_i
  input                                  val_i        ;
  input       [ DATA_WIDTH   *8-1 :0]    dat_i        ;
  // dat_o
  output reg                             val_o        ;
  output reg  [(DATA_WIDTH+3)*8-1 :0]    dat_o        ;


//*** REG/WIRE *****************************************************************

  wire signed [ DATA_WIDTH     -1 :0]    dat_i_0_w    ;
  wire signed [ DATA_WIDTH     -1 :0]    dat_i_1_w    ;
  wire signed [ DATA_WIDTH     -1 :0]    dat_i_2_w    ;
  wire signed [ DATA_WIDTH     -1 :0]    dat_i_3_w    ;
  wire signed [ DATA_WIDTH     -1 :0]    dat_i_4_w    ;
  wire signed [ DATA_WIDTH     -1 :0]    dat_i_5_w    ;
  wire signed [ DATA_WIDTH     -1 :0]    dat_i_6_w    ;
  wire signed [ DATA_WIDTH     -1 :0]    dat_i_7_w    ;

  wire signed [ DATA_WIDTH+1   -1 :0]    dat_0_0_w    ;
  wire signed [ DATA_WIDTH+1   -1 :0]    dat_0_1_w    ;
  wire signed [ DATA_WIDTH+1   -1 :0]    dat_0_2_w    ;
  wire signed [ DATA_WIDTH+1   -1 :0]    dat_0_3_w    ;
  wire signed [ DATA_WIDTH+1   -1 :0]    dat_0_4_w    ;
  wire signed [ DATA_WIDTH+1   -1 :0]    dat_0_5_w    ;
  wire signed [ DATA_WIDTH+1   -1 :0]    dat_0_6_w    ;
  wire signed [ DATA_WIDTH+1   -1 :0]    dat_0_7_w    ;

  wire signed [ DATA_WIDTH+2   -1 :0]    dat_1_0_w    ;
  wire signed [ DATA_WIDTH+2   -1 :0]    dat_1_1_w    ;
  wire signed [ DATA_WIDTH+2   -1 :0]    dat_1_2_w    ;
  wire signed [ DATA_WIDTH+2   -1 :0]    dat_1_3_w    ;
  wire signed [ DATA_WIDTH+2   -1 :0]    dat_1_4_w    ;
  wire signed [ DATA_WIDTH+2   -1 :0]    dat_1_5_w    ;
  wire signed [ DATA_WIDTH+2   -1 :0]    dat_1_6_w    ;
  wire signed [ DATA_WIDTH+2   -1 :0]    dat_1_7_w    ;

  wire signed [ DATA_WIDTH+3   -1 :0]    dat_2_0_w    ;
  wire signed [ DATA_WIDTH+3   -1 :0]    dat_2_1_w    ;
  wire signed [ DATA_WIDTH+3   -1 :0]    dat_2_2_w    ;
  wire signed [ DATA_WIDTH+3   -1 :0]    dat_2_3_w    ;
  wire signed [ DATA_WIDTH+3   -1 :0]    dat_2_4_w    ;
  wire signed [ DATA_WIDTH+3   -1 :0]    dat_2_5_w    ;
  wire signed [ DATA_WIDTH+3   -1 :0]    dat_2_6_w    ;
  wire signed [ DATA_WIDTH+3   -1 :0]    dat_2_7_w    ;


//*** MAIN BODY ****************************************************************

//--- ASSIGNMENT -----------------------
  assign { dat_i_0_w
          ,dat_i_1_w
          ,dat_i_2_w
          ,dat_i_3_w
          ,dat_i_4_w
          ,dat_i_5_w
          ,dat_i_6_w
          ,dat_i_7_w } = dat_i ;


//--- CALCULATION ----------------------
  assign dat_0_0_w = (size_i==`SIZE_04) ? dat_i_0_w : (dat_i_0_w+dat_i_4_w) ;
  assign dat_0_1_w = (size_i==`SIZE_04) ? dat_i_1_w : (dat_i_1_w+dat_i_5_w) ;
  assign dat_0_2_w = (size_i==`SIZE_04) ? dat_i_2_w : (dat_i_2_w+dat_i_6_w) ;
  assign dat_0_3_w = (size_i==`SIZE_04) ? dat_i_3_w : (dat_i_3_w+dat_i_7_w) ;
  assign dat_0_4_w = (size_i==`SIZE_04) ? dat_i_4_w : (dat_i_0_w-dat_i_4_w) ;
  assign dat_0_5_w = (size_i==`SIZE_04) ? dat_i_5_w : (dat_i_1_w-dat_i_5_w) ;
  assign dat_0_6_w = (size_i==`SIZE_04) ? dat_i_6_w : (dat_i_2_w-dat_i_6_w) ;
  assign dat_0_7_w = (size_i==`SIZE_04) ? dat_i_7_w : (dat_i_3_w-dat_i_7_w) ;

  assign dat_1_0_w = dat_0_0_w + dat_0_2_w ;
  assign dat_1_1_w = dat_0_1_w + dat_0_3_w ;
  assign dat_1_2_w = dat_0_0_w - dat_0_2_w ;
  assign dat_1_3_w = dat_0_1_w - dat_0_3_w ;
  assign dat_1_4_w = dat_0_4_w + dat_0_6_w ;
  assign dat_1_5_w = dat_0_5_w + dat_0_7_w ;
  assign dat_1_6_w = dat_0_4_w - dat_0_6_w ;
  assign dat_1_7_w = dat_0_5_w - dat_0_7_w ;

  assign dat_2_0_w = dat_1_0_w + dat_1_1_w ;
  assign dat_2_1_w = dat_1_0_w - dat_1_1_w ;
  assign dat_2_2_w = dat_1_2_w + dat_1_3_w ;
  assign dat_2_3_w = dat_1_2_w - dat_1_3_w ;
  assign dat_2_4_w = dat_1_4_w + dat_1_5_w ;
  assign dat_2_5_w = dat_1_4_w - dat_1_5_w ;
  assign dat_2_6_w = dat_1_6_w + dat_1_7_w ;
  assign dat_2_7_w = dat_1_6_w - dat_1_7_w ;


//--- OUTPUT ---------------------------
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      val_o <= 0 ;
      dat_o <= {{((DATA_WIDTH+3)*16){1'b0}}} ;
    end
    else begin
      val_o <= val_i ;
      if( val_i ) begin
        dat_o <= { dat_2_0_w
                  ,dat_2_1_w
                  ,dat_2_2_w
                  ,dat_2_3_w
                  ,dat_2_4_w
                  ,dat_2_5_w
                  ,dat_2_6_w
                  ,dat_2_7_w };
      end
    end
  end


//*** DEBUG ********************************************************************

`ifdef H265_DEBUG

`endif

endmodule
