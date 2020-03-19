//--------------------------------------------------------------------
//
//  Filename      : ram_sp_be_192x512.v
//  Author        : Huang Lei Lei
//  Created       : 2018-06-19
//  Description   : ram_sp_be_192x512
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module ram_sp_be_192x512 (
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
  input  [4*128-1 :0]  wr_ena_i    ;
  input  [4*128-1 :0]  wr_dat_i    ;
  // read
  input                rd_ena_i    ;
  output [4*128-1 :0]  rd_dat_o    ;


//*** WIRE/REG *****************************************************************


//*** MAIN BODY ****************************************************************

`ifdef RTL_MODEL

  sram_sp_be_behave #(
    .ADR_WD    ( 8                    ),
    .DAT_WD    ( 4*128                ),
    .COL_WD    ( 1                    )
  ) sram_sp_be_behave(
    .clk       ( clk         ),
    .adr       ( adr_i       ),
    .wr_ena    ( wr_ena_i    ),
    .wr_dat    ( wr_dat_i    ),
    .rd_ena    ( rd_ena_i    ),
    .rd_dat    ( rd_dat_o    )
    );

`endif

endmodule
