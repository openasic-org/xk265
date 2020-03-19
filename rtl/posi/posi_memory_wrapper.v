//--------------------------------------------------------------------
//
//  Filename    : h265_posi_memory_wrapper.v
//  Author      : Huang Leilei
//  Description : memory wrapper in module post intra
//  Created     : 2018-04-10
//
//--------------------------------------------------------------------

`include "./enc_defines.v"

module posi_memory_wrapper(
  // global
  clk             ,
  rstn            ,
  // ram_row_wr_if
  row_wr_ena_i    ,
  row_wr_adr_i    ,
  row_wr_dat_i    ,
  // ram_col_wr_if
  col_wr_ena_i    ,
  col_wr_adr_i    ,
  col_wr_dat_i    ,
  // ram_fra_wr_if
  fra_wr_ena_i    ,
  fra_wr_adr_i    ,
  fra_wr_dat_i    ,
  // ram_row_rd_if
  row_rd_ena_i    ,
  row_rd_adr_i    ,
  row_rd_dat_o    ,
  // ram_col_rd_if
  col_rd_ena_i    ,
  col_rd_adr_i    ,
  col_rd_dat_o    ,
  // ram_fra_rd_if
  fra_rd_ena_i    ,
  fra_rd_adr_i    ,
  fra_rd_dat_o
  );


//*** PARAMETER ****************************************************************



//*** INPUT/OUTPUT DECLARATION *************************************************

  // global
  input                             clk              ;
  input                             rstn             ;
  // ram_row_wr_if
  input                             row_wr_ena_i     ;
  input  [4           +4  -1 :0]    row_wr_adr_i     ;
  input  [`PIXEL_WIDTH*4  -1 :0]    row_wr_dat_i     ;
  // ram_col_wr_if
  input                             col_wr_ena_i     ;
  input  [4           +4  -1 :0]    col_wr_adr_i     ;
  input  [`PIXEL_WIDTH*4  -1 :0]    col_wr_dat_i     ;
  // ram_fra_wr_if
  input                             fra_wr_ena_i     ;
  input  [`PIC_X_WIDTH+4  -1 :0]    fra_wr_adr_i     ;
  input  [`PIXEL_WIDTH*4  -1 :0]    fra_wr_dat_i     ;
  // ram_row_rd_if
  input                             row_rd_ena_i     ;
  input  [4           +4  -1 :0]    row_rd_adr_i     ;
  output [`PIXEL_WIDTH*4  -1 :0]    row_rd_dat_o     ;
  // ram_col_rd_if
  input                             col_rd_ena_i     ;
  input  [4           +4  -1 :0]    col_rd_adr_i     ;
  output [`PIXEL_WIDTH*4  -1 :0]    col_rd_dat_o     ;
  // ram_fra_rd_if
  input                             fra_rd_ena_i     ;
  input  [`PIC_X_WIDTH+4  -1 :0]    fra_rd_adr_i     ;
  output [`PIXEL_WIDTH*4  -1 :0]    fra_rd_dat_o     ;


//*** REG/WIRE *****************************************************************

  wire   [4           +4  -1 :0]    row_adr_w        ;
  wire   [4           +4  -1 :0]    col_adr_w        ;
  wire   [`PIC_X_WIDTH+4  -1 :0]    fra_adr_w        ;


//*** MAIN BODY ****************************************************************


  assign row_adr_w = row_wr_ena_i ? row_wr_adr_i : row_rd_adr_i ;
  assign col_adr_w = col_wr_ena_i ? col_wr_adr_i : col_rd_adr_i ;
  assign fra_adr_w = fra_wr_ena_i ? fra_wr_adr_i : fra_rd_adr_i ;

  // row
  ram_sp_240x32 ram_sp_240x32(
    // global
    .clk         ( clk             ),
    // address
    .adr_i       ( row_adr_w       ),
    // write
    .wr_ena_i    ( row_wr_ena_i    ),
    .wr_dat_i    ( row_wr_dat_i    ),
    // read
    .rd_ena_i    ( row_rd_ena_i    ),
    .rd_dat_o    ( row_rd_dat_o    )
    );

  // col
  ram_sp_256x32 ram_sp_256x32(
    // global
    .clk         ( clk             ),
    // address
    .adr_i       ( col_adr_w       ),
    // write
    .wr_ena_i    ( col_wr_ena_i    ),
    .wr_dat_i    ( col_wr_dat_i    ),
    // read
    .rd_ena_i    ( col_rd_ena_i    ),
    .rd_dat_o    ( col_rd_dat_o    )
    );

  // frame
  ram_sp_1024x32 ram_sp_1024x32(
    // global
    .clk         ( clk             ),
    // address
    .adr_i       ( fra_adr_w       ),
    // write
    .wr_ena_i    ( fra_wr_ena_i    ),
    .wr_dat_i    ( fra_wr_dat_i    ),
    // read
    .rd_ena_i    ( fra_rd_ena_i    ),
    .rd_dat_o    ( fra_rd_dat_o    )
    );


//*** DEBUG ********************************************************************

`ifdef H265_DEBUG

`endif

endmodule
