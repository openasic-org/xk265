//--------------------------------------------------------------------
//
//  Filename    : rec_buf_pre.v
//  Author      : Huang Leilei
//  Created     : 2017-11-26
//  Description : memory buf: block input, parallel output
//                support: in  | out
//                         4x4 | 1x32
//                         4x8 | 2x16
//                             | 4x08
//                             | 4x04
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module rec_buf_pre (
  // global
  clk           ,
  rstn          ,
  // wr
  wr_ena_i      ,
  wr_siz_i      ,
  wr_4x4_x_i    ,
  wr_4x4_y_i    ,
  wr_dat_i      ,
  // rd
  rd_ena_i      ,
  rd_siz_i      ,
  rd_4x4_x_i    ,
  rd_4x4_y_i    ,
  rd_idx_i      ,
  rd_dat_o
  );


//*** PARAMETER ****************************************************************


//*** INPUT/OUTPUT *************************************************************

  // global
  input                            clk               ;
  input                            rstn              ;
  // wr
  input                            wr_ena_i          ;
  input  [1                 :0]    wr_siz_i          ;
  input  [3                 :0]    wr_4x4_x_i        ;
  input  [3                 :0]    wr_4x4_y_i        ;
  input  [`PIXEL_WIDTH*32-1 :0]    wr_dat_i          ;
  // rd
  input                            rd_ena_i          ;
  input  [1                 :0]    rd_siz_i          ;
  input  [3                 :0]    rd_4x4_x_i        ;
  input  [3                 :0]    rd_4x4_y_i        ;
  input  [4                 :0]    rd_idx_i          ;
  output [`PIXEL_WIDTH*32-1 :0]    rd_dat_o          ;


//*** REG/WIRE *****************************************************************

  // write enable
  reg    [`PIXEL_WIDTH*8 -1 :0]    mem_wr_ena_w      ;
  wire   [`PIXEL_WIDTH*8 -1 :0]    mem_0_wr_ena_w    ;
  wire   [`PIXEL_WIDTH*8 -1 :0]    mem_1_wr_ena_w    ;
  wire   [`PIXEL_WIDTH*8 -1 :0]    mem_2_wr_ena_w    ;
  wire   [`PIXEL_WIDTH*8 -1 :0]    mem_3_wr_ena_w    ;

  // write addr
  wire   [4                 :0]    mem_0_wr_adr_w    ;
  wire   [4                 :0]    mem_1_wr_adr_w    ;
  wire   [4                 :0]    mem_2_wr_adr_w    ;
  wire   [4                 :0]    mem_3_wr_adr_w    ;
  wire   [2                 :0]    mem_0_wr_adr_hi_w ;
  wire   [2                 :0]    mem_1_wr_adr_hi_w ;
  wire   [2                 :0]    mem_2_wr_adr_hi_w ;
  wire   [2                 :0]    mem_3_wr_adr_hi_w ;
  reg    [1                 :0]    mem_0_wr_adr_lo_w ;
  reg    [1                 :0]    mem_1_wr_adr_lo_w ;
  reg    [1                 :0]    mem_2_wr_adr_lo_w ;
  reg    [1                 :0]    mem_3_wr_adr_lo_w ;

  // write data
  wire   [`PIXEL_WIDTH*8 -1 :0]    mem_0_wr_dat_w    ;
  wire   [`PIXEL_WIDTH*8 -1 :0]    mem_1_wr_dat_w    ;
  wire   [`PIXEL_WIDTH*8 -1 :0]    mem_2_wr_dat_w    ;
  wire   [`PIXEL_WIDTH*8 -1 :0]    mem_3_wr_dat_w    ;
  reg    [`PIXEL_WIDTH*32-1 :0]    mem_wr_dat_w      ;
  wire   [`PIXEL_WIDTH*8 -1 :0]    wr_dat_0_w        ;
  wire   [`PIXEL_WIDTH*8 -1 :0]    wr_dat_1_w        ;
  wire   [`PIXEL_WIDTH*8 -1 :0]    wr_dat_2_w        ;
  wire   [`PIXEL_WIDTH*8 -1 :0]    wr_dat_3_w        ;

  // read enable
  wire                             mem_0_rd_ena_w    ;
  wire                             mem_1_rd_ena_w    ;
  wire                             mem_2_rd_ena_w    ;
  wire                             mem_3_rd_ena_w    ;

  // read address
  wire   [4                 :0]    mem_0_rd_adr_w    ;
  wire   [4                 :0]    mem_1_rd_adr_w    ;
  wire   [4                 :0]    mem_2_rd_adr_w    ;
  wire   [4                 :0]    mem_3_rd_adr_w    ;
  reg    [2                 :0]    mem_0_rd_adr_hi_w ;
  reg    [2                 :0]    mem_1_rd_adr_hi_w ;
  reg    [2                 :0]    mem_2_rd_adr_hi_w ;
  reg    [2                 :0]    mem_3_rd_adr_hi_w ;
  reg    [1                 :0]    mem_0_rd_adr_lo_w ;
  reg    [1                 :0]    mem_1_rd_adr_lo_w ;
  reg    [1                 :0]    mem_2_rd_adr_lo_w ;
  reg    [1                 :0]    mem_3_rd_adr_lo_w ;

  // read data
  reg    [`PIXEL_WIDTH*32-1 :0]    mem_rd_dat_w      ;
  wire   [`PIXEL_WIDTH*8-1  :0]    mem_0_rd_dat_w    ;
  wire   [`PIXEL_WIDTH*8-1  :0]    mem_1_rd_dat_w    ;
  wire   [`PIXEL_WIDTH*8-1  :0]    mem_2_rd_dat_w    ;
  wire   [`PIXEL_WIDTH*8-1  :0]    mem_3_rd_dat_w    ;
  wire   [`PIXEL_WIDTH*4-1  :0]    mem_0_rd_dat_hi_w ;
  wire   [`PIXEL_WIDTH*4-1  :0]    mem_1_rd_dat_hi_w ;
  wire   [`PIXEL_WIDTH*4-1  :0]    mem_2_rd_dat_hi_w ;
  wire   [`PIXEL_WIDTH*4-1  :0]    mem_3_rd_dat_hi_w ;
  wire   [`PIXEL_WIDTH*4-1  :0]    mem_0_rd_dat_lo_w ;
  wire   [`PIXEL_WIDTH*4-1  :0]    mem_1_rd_dat_lo_w ;
  wire   [`PIXEL_WIDTH*4-1  :0]    mem_2_rd_dat_lo_w ;
  wire   [`PIXEL_WIDTH*4-1  :0]    mem_3_rd_dat_lo_w ;

  reg    [1                 :0]    rd_siz_r          ;
  reg    [3                 :0]    rd_4x4_x_r        ;
  reg    [4                 :0]    rd_idx_r          ;


//*** MAIN BODY ****************************************************************

//--- WRITE PORT -----------------------
  // write enable
  always @(*) begin
    if( wr_ena_i ) begin
      if( wr_siz_i!=`SIZE_04 ) begin
        mem_wr_ena_w = {{(`PIXEL_WIDTH*8){1'b1}}} ;
      end
      else begin
        if( wr_4x4_x_i[0] ) begin
          mem_wr_ena_w = {{(`PIXEL_WIDTH*4){1'b0}},{(`PIXEL_WIDTH*4){1'b1}}} ;
        end
        else begin
          mem_wr_ena_w = {{(`PIXEL_WIDTH*4){1'b1}},{(`PIXEL_WIDTH*4){1'b0}}} ;
        end
      end
    end
    else begin
      mem_wr_ena_w = {{(`PIXEL_WIDTH*8){1'b0}}} ;
    end
  end
  assign mem_0_wr_ena_w = mem_wr_ena_w ;
  assign mem_1_wr_ena_w = mem_wr_ena_w ;
  assign mem_2_wr_ena_w = mem_wr_ena_w ;
  assign mem_3_wr_ena_w = mem_wr_ena_w ;

  // write address
  assign mem_0_wr_adr_w = { mem_0_wr_adr_hi_w ,mem_0_wr_adr_lo_w };
  assign mem_1_wr_adr_w = { mem_1_wr_adr_hi_w ,mem_1_wr_adr_lo_w };
  assign mem_2_wr_adr_w = { mem_2_wr_adr_hi_w ,mem_2_wr_adr_lo_w };
  assign mem_3_wr_adr_w = { mem_3_wr_adr_hi_w ,mem_3_wr_adr_lo_w };

  assign mem_0_wr_adr_hi_w = wr_4x4_y_i[2:0] ;
  assign mem_1_wr_adr_hi_w = wr_4x4_y_i[2:0] ;
  assign mem_2_wr_adr_hi_w = wr_4x4_y_i[2:0] ;
  assign mem_3_wr_adr_hi_w = wr_4x4_y_i[2:0] ;

  always @(*) begin
               mem_0_wr_adr_lo_w=0 ; mem_1_wr_adr_lo_w=0 ; mem_2_wr_adr_lo_w=0 ; mem_3_wr_adr_lo_w=0 ;
    case( wr_4x4_x_i[2:1] )
      0: begin mem_0_wr_adr_lo_w=0 ; mem_1_wr_adr_lo_w=1 ; mem_2_wr_adr_lo_w=2 ; mem_3_wr_adr_lo_w=3 ; end
      1: begin mem_0_wr_adr_lo_w=2 ; mem_1_wr_adr_lo_w=3 ; mem_2_wr_adr_lo_w=0 ; mem_3_wr_adr_lo_w=1 ; end
      2: begin mem_0_wr_adr_lo_w=3 ; mem_1_wr_adr_lo_w=0 ; mem_2_wr_adr_lo_w=1 ; mem_3_wr_adr_lo_w=2 ; end
      3: begin mem_0_wr_adr_lo_w=1 ; mem_1_wr_adr_lo_w=2 ; mem_2_wr_adr_lo_w=3 ; mem_3_wr_adr_lo_w=0 ; end
    endcase
  end

  // write data
  assign { mem_0_wr_dat_w
          ,mem_1_wr_dat_w
          ,mem_2_wr_dat_w
          ,mem_3_wr_dat_w } = mem_wr_dat_w ;

  always @(*) begin
         mem_wr_dat_w = {{(`PIXEL_WIDTH*32){1'b0}}} ;
    case( wr_4x4_x_i[2:1] )
      0: mem_wr_dat_w = { wr_dat_0_w
                         ,wr_dat_1_w
                         ,wr_dat_2_w
                         ,wr_dat_3_w };
      1: mem_wr_dat_w = { wr_dat_2_w
                         ,wr_dat_3_w
                         ,wr_dat_0_w
                         ,wr_dat_1_w };
      2: mem_wr_dat_w = { wr_dat_3_w
                         ,wr_dat_0_w
                         ,wr_dat_1_w
                         ,wr_dat_2_w };
      3: mem_wr_dat_w = { wr_dat_1_w
                         ,wr_dat_2_w
                         ,wr_dat_3_w
                         ,wr_dat_0_w };
    endcase
  end

  assign { wr_dat_0_w
          ,wr_dat_1_w
          ,wr_dat_2_w
          ,wr_dat_3_w } = wr_dat_i ;


//--- READ PORT ------------------------
  // read enable
  assign mem_0_rd_ena_w = rd_ena_i ;
  assign mem_1_rd_ena_w = rd_ena_i ;
  assign mem_2_rd_ena_w = rd_ena_i ;
  assign mem_3_rd_ena_w = rd_ena_i ;

  // read address
  assign mem_0_rd_adr_w = { mem_0_rd_adr_hi_w ,mem_0_rd_adr_lo_w };
  assign mem_1_rd_adr_w = { mem_1_rd_adr_hi_w ,mem_1_rd_adr_lo_w };
  assign mem_2_rd_adr_w = { mem_2_rd_adr_hi_w ,mem_2_rd_adr_lo_w };
  assign mem_3_rd_adr_w = { mem_3_rd_adr_hi_w ,mem_3_rd_adr_lo_w };

  always @(*) begin
                          mem_0_rd_adr_hi_w = 0 ;
                          mem_1_rd_adr_hi_w = 0 ;
                          mem_2_rd_adr_hi_w = 0 ;
                          mem_3_rd_adr_hi_w = 0 ;
    case( rd_siz_i )
      `SIZE_04 : begin    mem_0_rd_adr_hi_w = rd_4x4_y_i[2:0] ;
                          mem_1_rd_adr_hi_w = rd_4x4_y_i[2:0] ;
                          mem_2_rd_adr_hi_w = rd_4x4_y_i[2:0] ;
                          mem_3_rd_adr_hi_w = rd_4x4_y_i[2:0] ;
      end
      `SIZE_08 : begin    mem_0_rd_adr_hi_w = { rd_4x4_y_i[2:1] ,rd_idx_i[2] };
                          mem_1_rd_adr_hi_w = { rd_4x4_y_i[2:1] ,rd_idx_i[2] };
                          mem_2_rd_adr_hi_w = { rd_4x4_y_i[2:1] ,rd_idx_i[2] };
                          mem_3_rd_adr_hi_w = { rd_4x4_y_i[2:1] ,rd_idx_i[2] };
      end
      `SIZE_16 : begin    mem_0_rd_adr_hi_w = { rd_4x4_y_i[2] ,rd_idx_i[3:2] };
                          mem_1_rd_adr_hi_w = { rd_4x4_y_i[2] ,rd_idx_i[3:2] };
                          mem_2_rd_adr_hi_w = { rd_4x4_y_i[2] ,rd_idx_i[3:2] };
                          mem_3_rd_adr_hi_w = { rd_4x4_y_i[2] ,rd_idx_i[3:2] };
      end
      `SIZE_32 : begin    mem_0_rd_adr_hi_w = rd_idx_i[4:2] ;
                          mem_1_rd_adr_hi_w = rd_idx_i[4:2] ;
                          mem_2_rd_adr_hi_w = rd_idx_i[4:2] ;
                          mem_3_rd_adr_hi_w = rd_idx_i[4:2] ;
      end
    endcase
  end

  always @(*) begin
                          mem_0_rd_adr_lo_w = 0 ;
                          mem_1_rd_adr_lo_w = 0 ;
                          mem_2_rd_adr_lo_w = 0 ;
                          mem_3_rd_adr_lo_w = 0 ;
    case( rd_siz_i )
      `SIZE_04 ,
      `SIZE_08 : begin    case( rd_4x4_x_i[2:1] )
                            0: begin mem_0_rd_adr_lo_w=0 ; mem_1_rd_adr_lo_w=1 ; mem_2_rd_adr_lo_w=2 ; mem_3_rd_adr_lo_w=3 ; end
                            1: begin mem_0_rd_adr_lo_w=2 ; mem_1_rd_adr_lo_w=3 ; mem_2_rd_adr_lo_w=0 ; mem_3_rd_adr_lo_w=1 ; end
                            2: begin mem_0_rd_adr_lo_w=3 ; mem_1_rd_adr_lo_w=0 ; mem_2_rd_adr_lo_w=1 ; mem_3_rd_adr_lo_w=2 ; end
                            3: begin mem_0_rd_adr_lo_w=1 ; mem_1_rd_adr_lo_w=2 ; mem_2_rd_adr_lo_w=3 ; mem_3_rd_adr_lo_w=0 ; end
                          endcase
      end
      `SIZE_16 : begin    mem_0_rd_adr_lo_w = { rd_idx_i[1] , rd_4x4_x_i[2] };
                          mem_1_rd_adr_lo_w = { rd_idx_i[1] ,!rd_4x4_x_i[2] };
                          mem_2_rd_adr_lo_w = { rd_idx_i[1] , rd_4x4_x_i[2] };
                          mem_3_rd_adr_lo_w = { rd_idx_i[1] ,!rd_4x4_x_i[2] };
      end
      `SIZE_32 : begin    mem_0_rd_adr_lo_w = rd_idx_i[1:0] ;
                          mem_1_rd_adr_lo_w = rd_idx_i[1:0] ;
                          mem_2_rd_adr_lo_w = rd_idx_i[1:0] ;
                          mem_3_rd_adr_lo_w = rd_idx_i[1:0] ;
      end
    endcase
  end

  // read data
  assign rd_dat_o = mem_rd_dat_w ;

  always @(*) begin
                          mem_rd_dat_w = {{(`PIXEL_WIDTH*32){1'b0}}} ;
    case( rd_siz_r )
      `SIZE_04 : begin    if( rd_4x4_x_r[0] ) begin
                            case( rd_4x4_x_r[2:1] )
                              0: mem_rd_dat_w = { mem_0_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_1_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_2_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_3_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}} };
                              1: mem_rd_dat_w = { mem_2_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_3_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_0_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_1_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}} };
                              2: mem_rd_dat_w = { mem_1_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_2_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_3_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_0_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}} };
                              3: mem_rd_dat_w = { mem_3_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_0_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_1_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_2_rd_dat_lo_w ,{(`PIXEL_WIDTH*4){1'bx}} };
                            endcase
                          end
                          else begin
                            case( rd_4x4_x_r[2:1] )
                              0: mem_rd_dat_w = { mem_0_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_1_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_2_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_3_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}} };
                              1: mem_rd_dat_w = { mem_2_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_3_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_0_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_1_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}} };
                              2: mem_rd_dat_w = { mem_1_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_2_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_3_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_0_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}} };
                              3: mem_rd_dat_w = { mem_3_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_0_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_1_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}}
                                                 ,mem_2_rd_dat_hi_w ,{(`PIXEL_WIDTH*4){1'bx}} };
                            endcase
                          end
      end
      `SIZE_08 : begin    case( rd_4x4_x_r[2:1] )
                            0: mem_rd_dat_w = { mem_0_rd_dat_w ,mem_1_rd_dat_w ,mem_2_rd_dat_w ,mem_3_rd_dat_w };
                            1: mem_rd_dat_w = { mem_2_rd_dat_w ,mem_3_rd_dat_w ,mem_0_rd_dat_w ,mem_1_rd_dat_w };
                            2: mem_rd_dat_w = { mem_1_rd_dat_w ,mem_2_rd_dat_w ,mem_3_rd_dat_w ,mem_0_rd_dat_w };
                            3: mem_rd_dat_w = { mem_3_rd_dat_w ,mem_0_rd_dat_w ,mem_1_rd_dat_w ,mem_2_rd_dat_w };
                          endcase
      end
      `SIZE_16 : begin    case( {rd_4x4_x_r[2],rd_idx_r[1]} )
                            0: mem_rd_dat_w = { mem_0_rd_dat_w ,mem_2_rd_dat_w ,mem_1_rd_dat_w ,mem_3_rd_dat_w };
                            1: mem_rd_dat_w = { mem_2_rd_dat_w ,mem_0_rd_dat_w ,mem_3_rd_dat_w ,mem_1_rd_dat_w };
                            2: mem_rd_dat_w = { mem_1_rd_dat_w ,mem_3_rd_dat_w ,mem_2_rd_dat_w ,mem_0_rd_dat_w };
                            3: mem_rd_dat_w = { mem_3_rd_dat_w ,mem_1_rd_dat_w ,mem_0_rd_dat_w ,mem_2_rd_dat_w };
                          endcase
      end
      `SIZE_32 : begin    case( rd_idx_r[1:0] )
                            0: mem_rd_dat_w = { mem_0_rd_dat_w ,mem_2_rd_dat_w ,mem_1_rd_dat_w ,mem_3_rd_dat_w };
                            1: mem_rd_dat_w = { mem_1_rd_dat_w ,mem_3_rd_dat_w ,mem_2_rd_dat_w ,mem_0_rd_dat_w };
                            2: mem_rd_dat_w = { mem_2_rd_dat_w ,mem_0_rd_dat_w ,mem_3_rd_dat_w ,mem_1_rd_dat_w };
                            3: mem_rd_dat_w = { mem_3_rd_dat_w ,mem_1_rd_dat_w ,mem_0_rd_dat_w ,mem_2_rd_dat_w };
                          endcase
      end
    endcase
  end
  assign { mem_0_rd_dat_hi_w ,mem_0_rd_dat_lo_w } = mem_0_rd_dat_w ;
  assign { mem_1_rd_dat_hi_w ,mem_1_rd_dat_lo_w } = mem_1_rd_dat_w ;
  assign { mem_2_rd_dat_hi_w ,mem_2_rd_dat_lo_w } = mem_2_rd_dat_w ;
  assign { mem_3_rd_dat_hi_w ,mem_3_rd_dat_lo_w } = mem_3_rd_dat_w ;


  // delay
  always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
      rd_siz_r   <= 0 ;
      rd_4x4_x_r <= 0 ;
      rd_idx_r   <= 0 ;
    end
    else begin
      rd_siz_r   <= rd_siz_i   ;
      rd_4x4_x_r <= rd_4x4_x_i ;
      rd_idx_r   <= rd_idx_i   ;
    end
  end


//--- MEMORY ---------------------------
  ram_tp_be_32x64 m_buf_pre_0 (
    .clk        ( clk               ),
    .wr_ena_i   ( mem_0_wr_ena_w    ),
    .wr_adr_i   ( mem_0_wr_adr_w    ),
    .wr_dat_i   ( mem_0_wr_dat_w    ),
    .rd_ena_i   ( mem_0_rd_ena_w    ),
    .rd_adr_i   ( mem_0_rd_adr_w    ),
    .rd_dat_o   ( mem_0_rd_dat_w    )
    );

  ram_tp_be_32x64 m_buf_pre_1 (
    .clk        ( clk               ),
    .wr_ena_i   ( mem_1_wr_ena_w    ),
    .wr_adr_i   ( mem_1_wr_adr_w    ),
    .wr_dat_i   ( mem_1_wr_dat_w    ),
    .rd_ena_i   ( mem_1_rd_ena_w    ),
    .rd_adr_i   ( mem_1_rd_adr_w    ),
    .rd_dat_o   ( mem_1_rd_dat_w    )
    );

  ram_tp_be_32x64 m_buf_pre_2 (
    .clk        ( clk               ),
    .wr_ena_i   ( mem_2_wr_ena_w    ),
    .wr_adr_i   ( mem_2_wr_adr_w    ),
    .wr_dat_i   ( mem_2_wr_dat_w    ),
    .rd_ena_i   ( mem_2_rd_ena_w    ),
    .rd_adr_i   ( mem_2_rd_adr_w    ),
    .rd_dat_o   ( mem_2_rd_dat_w    )
    );

  ram_tp_be_32x64 m_buf_pre_3 (
    .clk        ( clk               ),
    .wr_ena_i   ( mem_3_wr_ena_w    ),
    .wr_adr_i   ( mem_3_wr_adr_w    ),
    .wr_dat_i   ( mem_3_wr_dat_w    ),
    .rd_ena_i   ( mem_3_rd_ena_w    ),
    .rd_adr_i   ( mem_3_rd_adr_w    ),
    .rd_dat_o   ( mem_3_rd_dat_w    )
    );

endmodule
