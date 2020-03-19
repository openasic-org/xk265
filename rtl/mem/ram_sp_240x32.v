//--------------------------------------------------------------------
//
//  Filename      : ram_sp_240x32.v
//  Author        : Huang Lei Lei
//  Created       : 2018-04-17
//  Description   : ram_sp_240x32
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module ram_sp_240x32 (
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
  input               clk         ;
  // address
  input  [8 -1 :0]    adr_i       ;
  // write
  input               wr_ena_i    ;
  input  [32-1 :0]    wr_dat_i    ;
  // read
  input               rd_ena_i    ;
  output [32-1 :0]    rd_dat_o    ;


//*** WIRE/REG *****************************************************************


//*** MAIN BODY ****************************************************************

`ifdef RTL_MODEL

  sram_sp_be_behave #(
    .ADR_WD    ( 8           ),
    .DAT_WD    ( 32          ),
    .COL_WD    ( 32          )
  ) sram_sp_be_behave(
    .clk       ( clk         ),
    .adr       ( adr_i       ),
    .wr_ena    ( wr_ena_i    ),
    .wr_dat    ( wr_dat_i    ),
    .rd_ena    ( rd_ena_i    ),
    .rd_dat    ( rd_dat_o    )
    );

`endif

`ifdef XM_MODEL 

  wire cen_w    = !(wr_ena_i || rd_ena_i) ;
  wire wr_ena_w = !wr_ena_i ;

  rfsphd_240x32 u_rfsphd_240x32(
      .Q       ( rd_dat_o     ), // output data 
      .CLK     ( clk          ), // clk 
      .CEN     ( cen_w        ), // low active 
      .WEN     ( wr_ena_w     ), // low active 
      .A       ( adr_i        ), // address 
      .D       ( wr_dat_i     ), // input data 
      .EMA     ( 3'b1 ),  
      .EMAW    ( 2'b0 ),
      .RET1N   ( 1'b1 ) 
        );
`endif

endmodule
