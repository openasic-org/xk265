//--------------------------------------------------
// 
// File Name    : db_mv_ram_sp_512x20.v
// Author       : TANG 
// Date         : 2018-05-13
// Description  : db_mv_ram_sp_512x20
//
//-----------------------------------------------------

`include "enc_defines.v" 

module db_mv_ram_sp_512x20 (
    // global
    clk       ,
    // address
    adr_i     ,
    // write
    wr_ena_i  ,
    wr_dat_i  ,
    // read
    rd_ena_i  ,
    rd_dat_o  
    );

//--- input/output declaration --------------------------
  // global
  input               clk         ;
  // address
  input  [9 -1 :0]    adr_i       ;
  // write
  input               wr_ena_i    ;
  input  [20-1 :0]    wr_dat_i    ;
  // read
  input               rd_ena_i    ;
  output [20-1 :0]    rd_dat_o    ;


`ifdef RTL_MODEL
  ram_1p #(
      .Word_Width(  20                ),
      .Addr_Width(  `PIC_X_WIDTH+3    )
      ) u_ram_1p(
        .clk    ( clk       ),
        .cen_i  ( wr_ena_i && rd_ena_i  ),
        .oen_i  ( 1'b0      ),
        .wen_i  ( wr_ena_i     ),
        .addr_i ( adr_i     ),
        .data_i ( wr_dat_i  ),      
        .data_o ( rd_dat_o  )           
  );

`endif

`ifdef XM_MODEL 
    rfsphd_512x20 u_rfsphd_512x20(
        .Q      (rd_dat_o   ), // data_o
        .CLK    (clk        ), 
        .CEN    ( wr_ena_i && rd_ena_i ), 
        .WEN    (wr_ena_i      ), 
        .A      (adr_i      ), // addr
        .D      (wr_dat_i   ), // data_i
        .EMA    ( 3'b1 ), 
        .EMAW   ( 2'b0 ),
        .RET1N  ( 1'b1 )
        );   
`endif 
endmodule 