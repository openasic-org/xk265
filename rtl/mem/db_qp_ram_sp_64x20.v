//--------------------------------------------------
// 
// File Name    : db_qp_ram_sp_64x20.v
// Author       : TANG 
// Date         : 2018-05-13
// Description  : db_qp_ram_sp_64x20
//
//-----------------------------------------------------

`include "enc_defines.v" 

module db_qp_ram_sp_64x20 (
    clk         ,
    adr_i       ,
    cen_i       , // low active 
    wen_i       , // low active 
    wr_dat_i    ,
    rd_dat_o 
    );

//--- input/output declaration --------------------------
    input                   clk         ;
    input   [6      -1 :0]  adr_i       ;
    input                   cen_i       ;
    input                   wen_i       ;
    input   [20     -1 :0]  wr_dat_i    ;
    output  [20     -1 :0]  rd_dat_o    ;


`ifdef RTL_MODEL
  ram_1p #(
      .Word_Width(  20   ),
      .Addr_Width(  6    )
      ) u_ram_1p(
                  .clk    ( clk               ),
                  .cen_i  ( cen_i             ),
                  .oen_i  ( 1'b0              ),
                  .wen_i  ( wen_i             ),
                  .addr_i ( adr_i             ),
                  .data_i ( wr_dat_i          ),      
                  .data_o ( rd_dat_o          )           
  );

`endif

`ifdef XM_MODEL 
    rfsphd_64x20 u_rfsphd_64x20(
        .Q          (rd_dat_o   ), // data_o
        .CLK        (clk        ), 
        .CEN        (cen_i      ), 
        .WEN        (wen_i      ), 
        .A          (adr_i      ), // addr
        .D          (wr_dat_i   ), // data_i
        .EMA        ( 3'b1 ), 
        .EMAW       ( 2'b0 ),
        .RET1N      ( 1'b1 )
        );   
`endif 
endmodule 