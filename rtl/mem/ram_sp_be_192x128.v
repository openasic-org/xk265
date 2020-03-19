//--------------------------------------------------------------------
//
//  Filename      : ram_sp_be_192x128.v
//  Author        : Huang Lei Lei
//  Created       : 2017-12-03
//  Description   : ram_sp_be_192x128
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module ram_sp_be_192x128 (
  // global
  clk         ,
  // address
  adr_i       ,
  // write
  wr_ena_i    ,
  wr_dat_i    ,
  // read
  rd_ena_i    ,
  rd_dat_o
);

//*** PARAMETER ****************************************************************


//*** INPUT/OUTPUT *************************************************************

  // global
  input                clk         ;
  // address
  input  [8  -1 :0]    adr_i       ;
  // write
  input  [128-1 :0]    wr_ena_i    ;
  input  [128-1 :0]    wr_dat_i    ;
  // read
  input                rd_ena_i    ;
  output [128-1 :0]    rd_dat_o    ;


//*** WIRE/REG *****************************************************************


//*** MAIN BODY ****************************************************************
  wire  [128-1 :0]   wr_ena_w    ;
  assign wr_ena_w   = ~wr_ena_i  ;


`ifdef RTL_MODEL

  sram_sp_be_behave #(
    .ADR_WD    ( 8           ),
    .DAT_WD    ( 128         ),
    .COL_WD    ( 1           )
  ) sram_sp_be_behave(
    .clk       ( clk         ),
    .adr       ( adr_i       ),
    .wr_ena    ( wr_ena_i    ), // high active
    .wr_dat    ( wr_dat_i    ),
    .rd_ena    ( rd_ena_i    ),
    .rd_dat    ( rd_dat_o    )
    );

`endif

`ifdef XM_MODEL 
  rfsphsdm_192x128  u_rfsphsdm_192x128(
    .Q         ( rd_dat_o    ),
    .CLK       ( clk         ),
    .CEN       ( 1'b0        ),
    .GWEN      ( rd_ena_i    ),
    .WEN       ( wr_ena_w    ), // low active
    .A         ( adr_i       ),
    .D         ( wr_dat_i    ),
    .EMA       ( 3'b1        ),
    .EMAW      ( 2'b0        ),
    .EMAS      ( 1'b0        ),
    .RET1N     ( 1'b1        )
    );
`endif 

endmodule
