//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore     : http://soc.fudan.edu.cn/vip
//  IP Owner    : Yibo FAN
//  Contact     : fanyibo@fudan.edu.cn
//
//-------------------------------------------------------------------
//
//  Filename    : fetch_ram_1p_128x32.v
//  Author      : Huang Leilei
//  Created     : 2017-04-15
//  Description : single port sram
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fetch_ram_1p_128x32 (
  clk    ,
  cen_i  , // low active
  oen_i  , // low active
  wen_i  , // low active
  addr_i ,
  data_i ,
  data_o
);

//*** PARAMETER DECLARATION ****************************************************

  parameter Word_Width = 128 ;
  parameter Addr_Width = 5   ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  input                     clk    ;
  input                     cen_i  ;
  input                     oen_i  ;
  input                     wen_i  ;
  input   [Addr_Width-1:0]  addr_i ;
  input   [Word_Width-1:0]  data_i ;
  output  [Word_Width-1:0]  data_o ;


//*** MAIN BODY ****************************************************************

  // ram_1p #(
  //   .Addr_Width    ( Addr_Width    ),
  //   .Word_Width    ( Word_Width    )
  // ) ram (                          
  //   .clk           ( clk           ),
  //   .cen_i         ( cen_i         ),
  //   .oen_i         ( oen_i         ),
  //   .wen_i         ( wen_i         ),
  //   .addr_i        ( addr_i        ),
  //   .data_i        ( data_i        ),
  //   .data_o        ( data_o        )
  //   );


`ifdef RTL_MODEL 
ram_1p #(
    .Addr_Width(   Addr_Width     ) , 
    .Word_Width(   Word_Width     )
    ) ram (                          
    .clk           ( clk           ),
    .cen_i         ( cen_i         ),
    .oen_i         ( oen_i         ),
    .wen_i         ( wen_i         ),
    .addr_i        ( addr_i        ),
    .data_i        ( data_i        ),
    .data_o        ( data_o        )
    );

`endif

`ifdef XM_MODEL 
  rfsphd_32x128 u_rfsphd_32x128(
      .Q       ( data_o       ), // output data 
      .CLK     ( clk          ), // clk 
      .CEN     ( cen_i        ), // low active 
      .WEN     ( wen_i        ), // low active 
      .A       ( addr_i       ), // address 
      .D       ( data_i       ), // input data 
      .EMA     ( 3'b1 ),  
      .EMAW    ( 2'b0 ),
      .RET1N   ( 1'b1 ) 
        );
`endif

endmodule
