//--------------------------------------------------
// 
// File Name    : cabac_ram_sp_64x16.v
// Author       : TANG 
// Date         : 2018-05-14
// Description  : cabac_ram_sp_64x16
//
//-----------------------------------------------------

`include "enc_defines.v" 

module cabac_ram_sp_64x16 (
    clk      ,
    cen_i    ,
    wen_i    , // low active 
    addr_i   , // low active 
    data_i   ,
    data_o
    );

//--- input/output declaration --------------------------
    input                   clk       ;
    input                   cen_i     ;
    input                   wen_i     ;
    input   [6      -1 :0]  addr_i    ;
    input   [16     -1 :0]  data_i    ;
    output  [16     -1 :0]  data_o    ;


`ifdef RTL_MODEL
  ram_1p #(
      .Word_Width(  16   ),
      .Addr_Width(  6    )
      ) u_ram_1p(
        .clk    ( clk        ),
        .cen_i  ( cen_i      ),
        .oen_i  ( 1'b0       ),
        .wen_i  ( wen_i      ),
        .addr_i ( addr_i     ),
        .data_i ( data_i     ),      
        .data_o ( data_o     )           
  );

`endif

`ifdef XM_MODEL 
    rfsphd_64x16 u_rfsphd_64x16(
        .Q          (data_o     ), // data_o
        .CLK        (clk        ), 
        .CEN        (cen_i      ), 
        .WEN        (wen_i      ), 
        .A          (addr_i     ), // addr
        .D          (data_i     ), // data_i
        .EMA        ( 3'b1 ), 
        .EMAW       ( 2'b0 ),
        .RET1N      ( 1'b1 )
        );   
`endif 
endmodule 