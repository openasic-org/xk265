//--------------------------------------------------------------------
//
//  Filename      : ram_tp_be_32x64.v
//  Author        : Huang Lei Lei
//  Created       : 2017-12-02
//  Description   : ram_tp_be_32x64
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module ram_tp_be_32x64 (
  // global
  clk         ,
  // write
  wr_ena_i    ,
  wr_adr_i    ,
  wr_dat_i    ,
  // read
  rd_ena_i    ,
  rd_adr_i    ,
  rd_dat_o
);

//*** PARAMETER ****************************************************************


//*** INPUT/OUTPUT *************************************************************

  // global
  input               clk         ;
  // write
  input  [64-1 :0]    wr_ena_i    ;
  input  [5 -1 :0]    wr_adr_i    ;
  input  [64-1 :0]    wr_dat_i    ;
  // read
  input               rd_ena_i    ;
  input  [5 -1 :0]    rd_adr_i    ;
  output [64-1 :0]    rd_dat_o    ;


//*** WIRE/REG *****************************************************************


//*** MAIN BODY ****************************************************************
  wire                rd_ena_w    ;
  wire                cenb_w      ;
  wire   [64   -1:0]  wr_ena_w    ;
  assign  rd_ena_w = !rd_ena_i    ;
  assign  cenb_w   = wr_ena_i == 0;
  assign  wr_ena_w = ~wr_ena_i    ;

`ifdef RTL_MODEL

  sram_tp_be_behave #(
    .ADR_WD    ( 5           ),
    .DAT_WD    ( 64          ),
    .COL_WD    ( 1           )
  ) sram_tp_be_behave(
    .clk       ( clk         ),
    .wr_ena    ( wr_ena_i    ), // high active
    .wr_adr    ( wr_adr_i    ),
    .wr_dat    ( wr_dat_i    ),
    .rd_ena    ( rd_ena_i    ),
    .rd_adr    ( rd_adr_i    ),
    .rd_dat    ( rd_dat_o    )
    );

`endif

`ifdef XM_MODEL
  rf2phddm_32x64 u_rf2phddm_32x64(
    .QA        ( rd_dat_o    ), 
    .CLKA      ( clk         ), 
    .CENA      ( rd_ena_w    ), 
    .AA        ( rd_adr_i    ), 
    .CLKB      ( clk         ), 
    .CENB      ( cenb_w      ), 
    .WENB      ( wr_ena_w    ), // low active
    .AB        ( wr_adr_i    ), 
    .DB        ( wr_dat_i    ), 
    .EMAA      ( 3'b1        ), 
    .EMAB      ( 3'b1        ), 
    .RET1N     ( 1'b1        ),
    .COLLDISN  ( 1'b1        )
    );
`endif 

endmodule
