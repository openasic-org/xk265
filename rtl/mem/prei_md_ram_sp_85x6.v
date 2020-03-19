//-------------------------------------------------------------------
//
//  Filename      : prei_md_ram_sp_85x6.v
//  Author        : TANG
//  Created       : 2018-04-25
//  Description   : rtl model for single-port sram (bit enable)
//
//-------------------------------------------------------------------
`include "enc_defines.v"

module prei_md_ram_sp_85x6 (
  clk         ,
  adr_i       ,
  wr_ena_i    , // low active
  wr_dat_i    ,
  rd_ena_i    , // low active
  rd_dat_o
  );

//*** PARAMETER DECLARATION ****************************************************

  parameter    ADR_WD                = 7              ;
  parameter    ADR                   = 85             ;
  parameter    DAT_WD                = 6              ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  input                              clk              ;
  input      [ADR_WD       -1 :0]    adr_i            ;
  input                              wr_ena_i         ;
  input      [DAT_WD       -1 :0]    wr_dat_i         ;
  input                              rd_ena_i         ;
  output     [DAT_WD       -1 :0]    rd_dat_o         ;


//*** WIRE & REG DECLARATION ***************************************************
  wire       [8            -1 :0]    wr_dat_w         ;
  wire       [8            -1 :0]    rd_dat_w         ;
  wire                               cen_w            ;

  assign rd_dat_o = rd_dat_w[DAT_WD-1 :0] ;
  assign wr_dat_w = {2'b0, wr_dat_i};
  assign cen_w    = wr_ena_i && rd_ena_i ;

`ifdef RTL_MODEL
  ram_1p #(
      .Word_Width(  8   ),
      .Addr_Width(  7   )
      ) u_ram_1p(
      .clk    ( clk               ),
      .cen_i  ( cen_w             ),
      .oen_i  ( 1'b0              ),
      .wen_i  ( wr_ena_i          ),
      .addr_i ( adr_i             ),
      .data_i ( wr_dat_w          ),      
      .data_o ( rd_dat_w          )           
  );

`endif

`ifdef XM_MODEL 
  rfsphd_85x8 u_rfsphd_85x8(
      .Q      ( rd_dat_w          ), // output data 
      .CLK    ( clk               ), // clk 
      .CEN    ( cen_w             ), // low active 
      .WEN    ( wr_ena_i          ), // low active 
      .A      ( adr_i             ), // address 
      .D      ( wr_dat_w          ), // input data 
      .EMA    ( 3'b1 ),  
      .EMAW   ( 2'b0 ),
      .RET1N  ( 1'b1 ) 
        );
`endif

endmodule 