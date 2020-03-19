//--------------------------------------------------------------------
//
//  Filename    : intra_buf_wrapper.v
//  Author      : Huang Leilei
//  Description : control logic in intra
//  Created     : 2017-12-14
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module intra_buf_wrapper(
  // global
  clk             ,
  rstn            ,
  // info_i
  sel_i           ,
  // row sram wr if
  wr_ena_row_i    ,
  wr_adr_row_i    ,
  wr_dat_row_i    ,
  // col sram wr if
  wr_ena_col_i    ,
  wr_adr_col_i    ,
  wr_dat_col_i    ,
  // fra sram wr if
  wr_ena_fra_i    ,
  wr_adr_fra_i    ,
  wr_dat_fra_i    ,
  // row sram rd if
  rd_ena_row_i    ,
  rd_adr_row_i    ,
  rd_dat_row_o    ,
  // col sram rd if
  rd_ena_col_i    ,
  rd_adr_col_i    ,
  rd_dat_col_o    ,
  // fra sram rd if
  rd_ena_fra_i    ,
  rd_adr_fra_i    ,
  rd_dat_fra_o
  );


//*** PARAMETER ****************************************************************



//*** INPUT/OUTPUT DECLARATION *************************************************

  // global
  input                             clk              ;
  input                             rstn             ;
  // info_i
  input  [1                  :0]    sel_i            ;
  // row sram wr if
  input                             wr_ena_row_i     ;
  input  [4           +4  -1 :0]    wr_adr_row_i     ;
  input  [`PIXEL_WIDTH*4  -1 :0]    wr_dat_row_i     ;
  // col sram wr if
  input                             wr_ena_col_i     ;
  input  [4           +4  -1 :0]    wr_adr_col_i     ;
  input  [`PIXEL_WIDTH*4  -1 :0]    wr_dat_col_i     ;
  // fra sram wr if
  input                             wr_ena_fra_i     ;
  input  [`PIC_X_WIDTH+4  -1 :0]    wr_adr_fra_i     ;
  input  [`PIXEL_WIDTH*4  -1 :0]    wr_dat_fra_i     ;
  // row sram rd if
  input                             rd_ena_row_i     ;
  input  [4           +4  -1 :0]    rd_adr_row_i     ;
  output [`PIXEL_WIDTH*4  -1 :0]    rd_dat_row_o     ;
  // col sram rd if
  input                             rd_ena_col_i     ;
  input  [4           +4  -1 :0]    rd_adr_col_i     ;
  output [`PIXEL_WIDTH*4  -1 :0]    rd_dat_col_o     ;
  // fra sram rd if
  input                             rd_ena_fra_i     ;
  input  [`PIC_X_WIDTH+4  -1 :0]    rd_adr_fra_i     ;
  output [`PIXEL_WIDTH*4  -1 :0]    rd_dat_fra_o     ;


//*** REG/WIRE *****************************************************************

  reg    [4           +4+1-1 :0]    rd_adr_row_w     ;
  reg    [4           +4+1-1 :0]    rd_adr_col_w     ;
  reg    [`PIC_X_WIDTH+4+1-1 :0]    rd_adr_fra_w     ;

  reg    [4           +4+1-1 :0]    wr_adr_row_w     ;
  reg    [4           +4+1-1 :0]    wr_adr_col_w     ;
  reg    [`PIC_X_WIDTH+4+1-1 :0]    wr_adr_fra_w     ;

  wire   [4           +4+1-1 :0]       adr_row_w     ;
  wire   [4           +4+1-1 :0]       adr_col_w     ;
  wire   [`PIC_X_WIDTH+4+1-1 :0]       adr_fra_w     ;


//*** MAIN BODY ****************************************************************

  // remap
  always @(*) begin
                         rd_adr_row_w = 0 ;
                         rd_adr_col_w = 0 ;
                         rd_adr_fra_w = 0 ;
    case( sel_i )
      `TYPE_Y : begin    rd_adr_row_w = {1'b0,rd_adr_row_i} ;
                         rd_adr_col_w = {1'b0,rd_adr_col_i} ;
                         rd_adr_fra_w = {1'b0,rd_adr_fra_i} ;
      end
      `TYPE_U : begin    rd_adr_row_w = {3'b100,rd_adr_row_i[4           +4-3:0]} ;
                         rd_adr_col_w = {3'b100,rd_adr_col_i[4           +4-3:0]} ;
                         rd_adr_fra_w = {3'b100,rd_adr_fra_i[`PIC_X_WIDTH+4-3:0]} ;
      end
      `TYPE_V : begin    rd_adr_row_w = {3'b101,rd_adr_row_i[4           +4-3:0]} ;
                         rd_adr_col_w = {3'b101,rd_adr_col_i[4           +4-3:0]} ;
                         rd_adr_fra_w = {3'b101,rd_adr_fra_i[`PIC_X_WIDTH+4-3:0]} ;
      end
    endcase
  end

  always @(*) begin
                         wr_adr_row_w = 0 ;
                         wr_adr_col_w = 0 ;
                         wr_adr_fra_w = 0 ;
    case( sel_i )
      `TYPE_Y : begin    wr_adr_row_w = {1'b0,wr_adr_row_i} ;
                         wr_adr_col_w = {1'b0,wr_adr_col_i} ;
                         wr_adr_fra_w = {1'b0,wr_adr_fra_i} ;
      end
      `TYPE_U : begin    wr_adr_row_w = {3'b100,wr_adr_row_i[4           +4-3:0]} ;
                         wr_adr_col_w = {3'b100,wr_adr_col_i[4           +4-3:0]} ;
                         wr_adr_fra_w = {3'b100,wr_adr_fra_i[`PIC_X_WIDTH+4-3:0]} ;
      end
      `TYPE_V : begin    wr_adr_row_w = {3'b101,wr_adr_row_i[4           +4-3:0]} ;
                         wr_adr_col_w = {3'b101,wr_adr_col_i[4           +4-3:0]} ;
                         wr_adr_fra_w = {3'b101,wr_adr_fra_i[`PIC_X_WIDTH+4-3:0]} ;
      end
    endcase
  end

  assign adr_row_w = wr_ena_row_i ? wr_adr_row_w : rd_adr_row_w ;
  assign adr_col_w = wr_ena_col_i ? wr_adr_col_w : rd_adr_col_w ;
  assign adr_fra_w = wr_ena_fra_i ? wr_adr_fra_w : rd_adr_fra_w ;

  // row
  ram_sp_384x32 m_buf_row(
    // global
    .clk         ( clk             ),
    // address
    .adr_i       (    adr_row_w    ),
    // write
    .wr_ena_i    ( wr_ena_row_i    ),
    .wr_dat_i    ( wr_dat_row_i    ),
    // read
    .rd_ena_i    ( rd_ena_row_i    ),
    .rd_dat_o    ( rd_dat_row_o    )
    );

  // col
  ram_sp_384x32 m_buf_col(
    // global
    .clk         ( clk             ),
    // address
    .adr_i       (    adr_col_w    ),
    // write
    .wr_ena_i    ( wr_ena_col_i    ),
    .wr_dat_i    ( wr_dat_col_i    ),
    // read
    .rd_ena_i    ( rd_ena_col_i    ),
    .rd_dat_o    ( rd_dat_col_o    )
    );

  // frame
  ram_sp_1536x32 m_buf_fra(
    // global
    .clk         ( clk             ),
    // address
    .adr_i       (    adr_fra_w    ),
    // write
    .wr_ena_i    ( wr_ena_fra_i    ),
    .wr_dat_i    ( wr_dat_fra_i    ),
    // read
    .rd_ena_i    ( rd_ena_fra_i    ),
    .rd_dat_o    ( rd_dat_fra_o    )
    );


//*** DEBUG ********************************************************************

`ifdef DEBUG

`endif

endmodule
