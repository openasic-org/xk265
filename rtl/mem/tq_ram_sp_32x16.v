//--------------------------------------------------------------------
//
//  Filename      : tq_ram_sp_32x16.v
//  Author        : TANG
//  Created       : 2018-05-14
//  Description   : tq_ram_sp_32x16
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module tq_ram_sp_32x16 (
  data_o    , 
  clk       , 
  cen_i     , // low active
  wen_i     , // low active
  addr_i    , 
  data_i
);

//--- input/output ------------------------------------------------
  input               clk     ;
  input               cen_i   ;
  input               wen_i   ;
  input   [5 -1 :0]   addr_i  ;
  input   [16-1 :0]   data_i  ;
  output  [16-1 :0]   data_o  ;

`ifdef RTL_MODEL

ram_1p #(
      .Word_Width (  16  ),
      .Addr_Width (  5   )
      ) u_ram_1p(
          .clk    ( clk           ),
          .cen_i  ( cen_i         ),
          .oen_i  ( 1'b0          ),
          .wen_i  ( wen_i         ),
          .addr_i ( addr_i        ),
          .data_i ( data_i        ),      
          .data_o ( data_o        )          
);

`endif

`ifdef XM_MODEL 
rfsphd_32x16 u_rfsphd_32x16(
          .Q      ( data_o        ), // output data
          .CLK    ( clk           ), // clk
          .CEN    ( cen_i         ), // low active
          .WEN    ( wen_i         ), // low active
          .A      ( addr_i        ), // address
          .D      ( data_i        ), // input data
          .EMA    ( 3'b1 ), 
          .EMAW   ( 2'b0 ),
          .RET1N  ( 1'b1 )
  );
`endif 
endmodule
