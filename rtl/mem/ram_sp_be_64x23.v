//--------------------------------------------------------------------
//
//  Filename      : ram_sp_be_64x23.v
//  Author        : Huang Lei Lei
//  Created       : 2018-05-22
//  Description   : ram_sp_be_64x23
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module ram_sp_be_64x23 (
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
  input  [6 -1 :0]    adr_i       ;
  // write
  input  [1 -1 :0]    wr_ena_i    ;
  input  [23-1 :0]    wr_dat_i    ;
  // read
  input               rd_ena_i    ;
  output [23-1 :0]    rd_dat_o    ;


//*** WIRE/REG *****************************************************************


//*** MAIN BODY ****************************************************************

`ifdef RTL_MODEL

  sram_sp_be_behave #(
    .ADR_WD    ( 6           ),
    .DAT_WD    ( 23          ),
    .COL_WD    ( 23          )
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
    rfsphd_64x23 u_rfsphd_64x23(
        .Q      ( rd_dat_o  ), // data_o
        .CLK    ( clk       ), 
        .CEN    ( 1'b0      ), 
        .WEN    ( wr_ena_i  ), 
        .A      ( adr_i     ), // addr
        .D      ( wr_dat_i  ), // data_i
        .EMA    ( 3'b1 ), 
        .EMAW   ( 2'b0 ),
        .RET1N  ( 1'b1 )
        );   
`endif 



endmodule
