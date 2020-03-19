//--------------------------------------------------------------------
//
//  Filename      : ime_mv_ram_sp_64x13.v
//  Author        : TANG
//  Created       : 2018-05-13
//  Description   : ime_mv_ram_sp_64x13
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module ime_mv_ram_sp_64x13 (
  // global
  clk         ,
  // address
  adr_i       ,
  // write
  wr_ena_i    , // low active
  wr_dat_i    ,
  // read
  rd_ena_i    , // low active
  rd_dat_o
);

//*** PARAMETER ****************************************************************


//*** INPUT/OUTPUT *************************************************************

  // global
  input               clk         ;
  // address
  input  [6 -1 :0]    adr_i       ;
  // write
  input               wr_ena_i    ;
  input  [13-1 :0]    wr_dat_i    ;
  // read
  input               rd_ena_i    ;
  output [13-1 :0]    rd_dat_o    ;


//*** WIRE/REG *****************************************************************


//*** MAIN BODY ****************************************************************
  wire cen_w = wr_ena_i && rd_ena_i ;

`ifdef RTL_MODEL

ram_1p #(
      .Word_Width (  13  ) ,
      .Addr_Width (  6   )
      ) u_ram_1p(
          .clk    ( clk               ),
          .cen_i  ( cen_w             ),
          .oen_i  ( 1'b0              ),
          .wen_i  ( wr_ena_i          ),
          .addr_i ( adr_i             ),
          .data_i ( wr_dat_i          ),      
          .data_o ( rd_dat_o          )          
);

`endif

`ifdef XM_MODEL 
rfsphd_64x13 u_rfsphd_64x13(
          .Q      ( rd_dat_o          ), // output data
          .CLK    ( clk               ), // clk
          .CEN    ( cen_w             ), // low active
          .WEN    ( wr_ena_i          ), // low active
          .A      ( adr_i             ), // address
          .D      ( wr_dat_i          ), // input data
          .EMA    ( 3'b1 ), 
          .EMAW   ( 2'b0 ),
          .RET1N  ( 1'b1 )
  );
`endif 
endmodule
