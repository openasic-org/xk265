//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//-------------------------------------------------------------------
//  Filename       : mem_bilo.v
//  Author         : Yufeng Bai
//  Created        : 2015-04-27
//  Description    : Memory Buf Block Input, Line Output
//
//-------------------------------------------------------------------
//
//  Modified      : 2014-08-18 by HLL
//  Description   : db supported
//  Modified      : 2015-09-19 by HLL
//  Description   : load_db_chroma & store_db_chroma provided in the order of uvuvuv...
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module mem_bilo_db   (
        clk             ,
        rst_n           ,
        wen_i           ,
        wsel_i          ,
        w4x4_x_i        ,
        w4x4_y_i        ,
        wdata_i         ,
        ren_i           ,
        raddr_i         ,
        rdata_o
);

// ********************************************
//
//    Parameter DECLARATION
//
// ********************************************

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************
input                         clk      ; //clock
input                         rst_n    ; //reset signal
input                         wen_i    ; //
input  [1:0]                  wsel_i   ; //
input  [3:0]                  w4x4_x_i ; //
input  [4:0]                  w4x4_y_i ; //
input  [`PIXEL_WIDTH*16-1:0]  wdata_i  ; //
input                         ren_i    ; //
input  [7:0]                  raddr_i  ; //
output [`PIXEL_WIDTH*32-1:0]  rdata_o  ; //

// ********************************************
//
//    Signals DECLARATION
//
// ********************************************
// R/W Data & Address
wire [`PIXEL_WIDTH*4-1:0]     w_4x4_l0    ,
                              w_4x4_l1    ,
                              w_4x4_l2    ,
                              w_4x4_l3    ;
reg [1:0]                     b0_waddr_l, b0_raddr_l,
                              b1_waddr_l, b1_raddr_l,
                              b2_waddr_l, b2_raddr_l,
                              b3_waddr_l, b3_raddr_l;
reg  [5:0]                    waddr_h;
wire                          extra_line;
wire [7:0]                    b0_waddr, b0_raddr,
                              b1_waddr, b1_raddr,
                              b2_waddr, b2_raddr,
                              b3_waddr, b3_raddr;
reg [`PIXEL_WIDTH*8-1:0]      b0_wdata,
                              b1_wdata,
                              b2_wdata,
                              b3_wdata;
reg [1:0]                     raddr_r;
wire [`PIXEL_WIDTH*8-1:0]     b0_rdata,
                              b2_rdata,
                              b1_rdata,
                              b3_rdata;
reg [`PIXEL_WIDTH*32-1:0]     b_rdata;

// R/W Control

wire [1:0]                    b0_wen,
                              b1_wen,
                              b2_wen,
                              b3_wen;

wire                          b0_ren,
                              b1_ren,
                              b2_ren,
                              b3_ren;

// ********************************************
//
//    Logic DECLARATION
//
// ********************************************
// --------------------------------------------
//    Memory Banks
//---------------------------------------------
//-------------- MEM Write ----------------//

  assign b0_wen = wen_i ? ( (!wsel_i[1]) ? ({~w4x4_x_i[0], w4x4_x_i[0]}) : ({~wsel_i[0], wsel_i[0]}) ) : 2'b00;
  assign b1_wen = wen_i ? ( (!wsel_i[1]) ? ({~w4x4_x_i[0], w4x4_x_i[0]}) : ({~wsel_i[0], wsel_i[0]}) ) : 2'b00;
  assign b2_wen = wen_i ? ( (!wsel_i[1]) ? ({~w4x4_x_i[0], w4x4_x_i[0]}) : ({~wsel_i[0], wsel_i[0]}) ) : 2'b00;
  assign b3_wen = wen_i ? ( (!wsel_i[1]) ? ({~w4x4_x_i[0], w4x4_x_i[0]}) : ({~wsel_i[0], wsel_i[0]}) ) : 2'b00;

assign w_4x4_l0 = wdata_i[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*12];
assign w_4x4_l1 = wdata_i[`PIXEL_WIDTH*12-1:`PIXEL_WIDTH*8];
assign w_4x4_l2 = wdata_i[`PIXEL_WIDTH*8 -1:`PIXEL_WIDTH*4];
assign w_4x4_l3 = wdata_i[`PIXEL_WIDTH*4 -1:`PIXEL_WIDTH*0];

  always @(*) begin
    if( !wsel_i[1] )
      case( w4x4_x_i[2:1] )
        2'd0: {b0_wdata, b1_wdata, b2_wdata, b3_wdata} = { w_4x4_l0, w_4x4_l0, w_4x4_l1, w_4x4_l1, w_4x4_l2, w_4x4_l2, w_4x4_l3, w_4x4_l3 };
        2'd1: {b0_wdata, b1_wdata, b2_wdata, b3_wdata} = { w_4x4_l2, w_4x4_l2, w_4x4_l3, w_4x4_l3, w_4x4_l0, w_4x4_l0, w_4x4_l1, w_4x4_l1 };
        2'd2: {b0_wdata, b1_wdata, b2_wdata, b3_wdata} = { w_4x4_l3, w_4x4_l3, w_4x4_l0, w_4x4_l0, w_4x4_l1, w_4x4_l1, w_4x4_l2, w_4x4_l2 };
        2'd3: {b0_wdata, b1_wdata, b2_wdata, b3_wdata} = { w_4x4_l1, w_4x4_l1, w_4x4_l2, w_4x4_l2, w_4x4_l3, w_4x4_l3, w_4x4_l0, w_4x4_l0 };
      endcase
    else begin
      case( w4x4_x_i[1:0] )
        2'd0: {b0_wdata, b1_wdata, b2_wdata, b3_wdata} = { w_4x4_l0, w_4x4_l0, w_4x4_l1, w_4x4_l1, w_4x4_l2, w_4x4_l2, w_4x4_l3, w_4x4_l3 };
        2'd1: {b0_wdata, b1_wdata, b2_wdata, b3_wdata} = { w_4x4_l2, w_4x4_l2, w_4x4_l3, w_4x4_l3, w_4x4_l0, w_4x4_l0, w_4x4_l1, w_4x4_l1 };
        2'd2: {b0_wdata, b1_wdata, b2_wdata, b3_wdata} = { w_4x4_l3, w_4x4_l3, w_4x4_l0, w_4x4_l0, w_4x4_l1, w_4x4_l1, w_4x4_l2, w_4x4_l2 };
        2'd3: {b0_wdata, b1_wdata, b2_wdata, b3_wdata} = { w_4x4_l1, w_4x4_l1, w_4x4_l2, w_4x4_l2, w_4x4_l3, w_4x4_l3, w_4x4_l0, w_4x4_l0 };
      endcase
    end
  end

  always @(*) begin
    if( !wsel_i[1] )
      case( w4x4_x_i[2:1] )
        2'd0 : begin b0_waddr_l=2'd0; b1_waddr_l=2'd1; b2_waddr_l=2'd2; b3_waddr_l=2'd3; end
        2'd1 : begin b0_waddr_l=2'd2; b1_waddr_l=2'd3; b2_waddr_l=2'd0; b3_waddr_l=2'd1; end
        2'd2 : begin b0_waddr_l=2'd3; b1_waddr_l=2'd0; b2_waddr_l=2'd1; b3_waddr_l=2'd2; end
        2'd3 : begin b0_waddr_l=2'd1; b1_waddr_l=2'd2; b2_waddr_l=2'd3; b3_waddr_l=2'd0; end
      endcase
    else begin
      case( w4x4_x_i[1:0] )
        2'd0 : begin b0_waddr_l=2'd0; b1_waddr_l=2'd1; b2_waddr_l=2'd2; b3_waddr_l=2'd3; end
        2'd1 : begin b0_waddr_l=2'd2; b1_waddr_l=2'd3; b2_waddr_l=2'd0; b3_waddr_l=2'd1; end
        2'd2 : begin b0_waddr_l=2'd3; b1_waddr_l=2'd0; b2_waddr_l=2'd1; b3_waddr_l=2'd2; end
        2'd3 : begin b0_waddr_l=2'd1; b1_waddr_l=2'd2; b2_waddr_l=2'd3; b3_waddr_l=2'd0; end
      endcase
    end
  end

assign extra_line = (~wsel_i[1] & w4x4_y_i[4]) | (wsel_i[1] & w4x4_y_i[3]);    // top y | top u,v

  always @(*) begin
    case( {extra_line, wsel_i[1]} )
      2'b00: waddr_h = { 1'b0, w4x4_y_i[3], w4x4_x_i[3]   ,w4x4_y_i[2:0]       };    // cur y
      2'b01: waddr_h = { 1'b1, 1'b0       , w4x4_y_i[2:0] ,w4x4_x_i[2]         };    // cur u,v
      2'b10: waddr_h = { 1'b1, 1'b1       , 1'b0          ,{2'b00,w4x4_x_i[3]} };    // top y
      2'b11: waddr_h = { 1'b1, 1'b1       , 1'b0          ,{2'b01,w4x4_x_i[2]} };    // top u,v
    endcase
  end

assign b0_waddr = {waddr_h, b0_waddr_l};
assign b1_waddr = {waddr_h, b1_waddr_l};
assign b2_waddr = {waddr_h, b2_waddr_l};
assign b3_waddr = {waddr_h, b3_waddr_l};

/*
 <--- 64 pixel --->  <- 32p ->  <- 32p ->
 -----------------   ---------  ---------
| luma-A | luma-B | |   U-C  | |   V-D  |
 -----------------   --------   ---------
|        |        | |        | |        |
| luma0  | luma1  | |   U    | |   V    |
|        |        | |        | |        |
|-----------------|  --------   --------
|        |        |
| luma2  | luma3  |
|        |        |
 -----------------

mem arraged as below:
 --------   _
|        | /|\
| luma0  |  |
|        |  |
 --------   |
|        |  |
| luma1  |  |
|        |  |
 --------   |
|        |  |
| luma2  |  |
|        |  |
 --------
|        |  |
| luma3  |  |
|        |  |
 --------  208
|        |  |
|        |  |
|        |  |
 -- UV --   |
|        |  |
|        |  |
|        |  |
 --------   |
| luma-A |  |
 --------   |
| luma-B |  |
 --------   |
|        |  |
 -- UV --   |
|        |  |
 --------  \|/
*/

//-------------- MEM Read ----------------//
assign b0_ren = ren_i;
assign b1_ren = ren_i;
assign b2_ren = ren_i;
assign b3_ren = ren_i;

// address generater

assign b0_raddr  = raddr_i;
assign b1_raddr  = raddr_i;
assign b2_raddr  = raddr_i;
assign b3_raddr  = raddr_i;

// data alignment
always@(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    raddr_r  <= 'b0;
  end
  else begin
    raddr_r  <= raddr_i[1:0];
  end
end

always @(*) begin
  case (raddr_r)
    2'd0: b_rdata = {b0_rdata, b2_rdata, b1_rdata, b3_rdata};
    2'd1: b_rdata = {b1_rdata, b3_rdata, b2_rdata, b0_rdata};
    2'd2: b_rdata = {b2_rdata, b0_rdata, b3_rdata, b1_rdata};
    2'd3: b_rdata = {b3_rdata, b1_rdata, b0_rdata, b2_rdata};
  endcase
end

assign rdata_o = b_rdata;

// MEM Modules

fetch_ram_2p_64x208  buf_pre_0(
    .clk        ( clk    ),
    .a_we       ( b0_wen  ),
    .a_addr     ( b0_waddr  ),
    .a_data_i   ( b0_wdata  ),
    .b_re       ( b0_ren  ),
    .b_addr     ( b0_raddr  ),
    .b_data_o   ( b0_rdata  )
);

fetch_ram_2p_64x208  buf_pre_1(
    .clk      ( clk    ),
    .a_we       ( b1_wen  ),
    .a_addr     ( b1_waddr  ),
    .a_data_i   ( b1_wdata  ),
    .b_re       ( b1_ren  ),
    .b_addr     ( b1_raddr  ),
    .b_data_o   ( b1_rdata  )
);

fetch_ram_2p_64x208  buf_pre_2(
    .clk      ( clk    ),
    .a_we       ( b2_wen  ),
    .a_addr     ( b2_waddr  ),
    .a_data_i   ( b2_wdata  ),
    .b_re       ( b2_ren  ),
    .b_addr     ( b2_raddr  ),
    .b_data_o   ( b2_rdata  )
);

fetch_ram_2p_64x208    buf_pre_3(
    .clk      ( clk    ),
    .a_we       ( b3_wen  ),
    .a_addr     ( b3_waddr  ),
    .a_data_i   ( b3_wdata  ),
    .b_re       ( b3_ren  ),
    .b_addr     ( b3_raddr  ),
    .b_data_o   ( b3_rdata  )
);

endmodule
