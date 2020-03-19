//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2013, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//
//-------------------------------------------------------------------
//
//  Filename      : cur_mb.v
//  Author        : Yibo FAN
//  Created       : 2013-12-28
//  Description   : Current MB
//
//-------------------------------------------------------------------
//
//  Modified      : 2014-07-17 by HLL
//  Description   : lcu size changed into 64x64 (prediction to 64x64 block remains to be added)
//  Modified      : 2014-08-23 by HLL
//  Description   : optional mode for minimal tu size added
//  Modified      : 2015-03-12 by HLL
//  Description   : ping-pong logic removed
//  Modified      : 2015-03-20 by HLL
//  Description   : mode function removed
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"


module cur_mb_yuv (
  clk            ,
  rst_n          ,
  start_i        ,
  done_o         ,
  cur_sel_i      ,
  cur_ren_i      ,
  cur_size_i     ,
  cur_4x4_x_i    ,
  cur_4x4_y_i    ,
  cur_idx_i      ,
  cur_data_o
  );


//*** PARAMETER DECLARATION ****************************************************

  parameter YUV_FILE = "./tv/cur_mb_p32.dat" ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  input                               clk              ; //clock
  input                               rst_n            ; //reset signal
  // ctrl if
  input                               start_i          ; // start load new mb from outside
  output                              done_o           ; // load done
  // cur if
  input                               cur_sel_i        ; // luma/chroma selector
  input                               cur_ren_i        ; // cmb read enable
  input    [1                 : 0]    cur_size_i       ; // cmb read size (00:4x4 01:8x8 10:16x16 11:32x32)
  input    [4                 : 0]    cur_idx_i        ; // read index ({blk_index, line_number})
  input    [3                 : 0]    cur_4x4_x_i      ; // cmb read block top/left 4x4 x
  input    [3                 : 0]    cur_4x4_y_i      ; // cmb read block top/left 4x4 y
  output   [`PIXEL_WIDTH*32-1 : 0]    cur_data_o       ; // pixel data


//*** WIRE & REG DECLARATION ***************************************************

  reg                                 done_o            ;
  integer                             cmb_tp            ;

//*** MAIN BODY ****************************************************************

  mem_lipo_1p  cmb_buf_0 (
    .clk        ( clk            ),
    .rst_n      ( rst_n          ),
    .a_wen_i    ( 1'b0           ),
    .a_addr_i   ( 8'b0           ),
    .a_wdata_i  ( 256'b0         ),

    .b_ren_i    ( cur_ren_i      ),
    .b_sel_i    ( cur_sel_i      ),
    .b_size_i   ( cur_size_i     ),
    .b_4x4_x_i  ( cur_4x4_x_i    ),
    .b_4x4_y_i  ( cur_4x4_y_i    ),
    .b_idx_i    ( cur_idx_i      ),
    .b_rdata_o  ( cur_data_o     )
    );

  reg      [`PIXEL_WIDTH*32-1:0]   scan_pixel_32 ;
  integer                          i             ;
  integer                          fp_input      ;

  initial begin
    fp_input      = $fopen( YUV_FILE   ,"r" );
    done_o        = 0 ;
  end

  always @(posedge clk) begin
    if (start_i) begin
      // load luma
      for (i=0; i<32; i=i+1) begin
        cmb_tp = $fscanf(fp_input, "%h", scan_pixel_32 );
        {cmb_buf_0.buf_org_0.u_ram_1p_64x192.mem_array[i*4+0],
         cmb_buf_0.buf_org_1.u_ram_1p_64x192.mem_array[i*4+0],
         cmb_buf_0.buf_org_2.u_ram_1p_64x192.mem_array[i*4+0],
         cmb_buf_0.buf_org_3.u_ram_1p_64x192.mem_array[i*4+0]} =
        {scan_pixel_32[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*24],
         scan_pixel_32[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*8],
         scan_pixel_32[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*16],
         scan_pixel_32[`PIXEL_WIDTH*8-1 :`PIXEL_WIDTH*0]};

        cmb_tp = $fscanf(fp_input, "%h", scan_pixel_32 );
        {cmb_buf_0.buf_org_0.u_ram_1p_64x192.mem_array[i*4+1],
         cmb_buf_0.buf_org_1.u_ram_1p_64x192.mem_array[i*4+1],
         cmb_buf_0.buf_org_2.u_ram_1p_64x192.mem_array[i*4+1],
         cmb_buf_0.buf_org_3.u_ram_1p_64x192.mem_array[i*4+1]} =
        {scan_pixel_32[`PIXEL_WIDTH*8 -1:`PIXEL_WIDTH*0],
         scan_pixel_32[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*24],
         scan_pixel_32[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*8],
         scan_pixel_32[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*16]};

        cmb_tp = $fscanf(fp_input, "%h", scan_pixel_32 );
        {cmb_buf_0.buf_org_0.u_ram_1p_64x192.mem_array[i*4+2],
         cmb_buf_0.buf_org_1.u_ram_1p_64x192.mem_array[i*4+2],
         cmb_buf_0.buf_org_2.u_ram_1p_64x192.mem_array[i*4+2],
         cmb_buf_0.buf_org_3.u_ram_1p_64x192.mem_array[i*4+2]} =
        {scan_pixel_32[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*16],
         scan_pixel_32[`PIXEL_WIDTH*8 -1:`PIXEL_WIDTH*0],
         scan_pixel_32[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*24],
         scan_pixel_32[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*8]};

        cmb_tp = $fscanf(fp_input, "%h", scan_pixel_32 );
        {cmb_buf_0.buf_org_0.u_ram_1p_64x192.mem_array[i*4+3],
         cmb_buf_0.buf_org_1.u_ram_1p_64x192.mem_array[i*4+3],
         cmb_buf_0.buf_org_2.u_ram_1p_64x192.mem_array[i*4+3],
         cmb_buf_0.buf_org_3.u_ram_1p_64x192.mem_array[i*4+3]} =
        {scan_pixel_32[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*8],
         scan_pixel_32[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*16],
         scan_pixel_32[`PIXEL_WIDTH*8 -1:`PIXEL_WIDTH*0],
         scan_pixel_32[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*24]};
      end

      // load chroma
      for (i=0; i<16; i=i+1) begin
        cmb_tp = $fscanf(fp_input, "%h", scan_pixel_32 );
        {cmb_buf_0.buf_org_0.u_ram_1p_64x192.mem_array[128+i*4+0],
         cmb_buf_0.buf_org_1.u_ram_1p_64x192.mem_array[128+i*4+0],
         cmb_buf_0.buf_org_2.u_ram_1p_64x192.mem_array[128+i*4+0],
         cmb_buf_0.buf_org_3.u_ram_1p_64x192.mem_array[128+i*4+0]} =
        {scan_pixel_32[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*24],
         scan_pixel_32[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*8 ],
         scan_pixel_32[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*16],
         scan_pixel_32[`PIXEL_WIDTH*8 -1:`PIXEL_WIDTH*0 ]};

        cmb_tp = $fscanf(fp_input, "%h", scan_pixel_32 );
        {cmb_buf_0.buf_org_0.u_ram_1p_64x192.mem_array[128+i*4+1],
         cmb_buf_0.buf_org_1.u_ram_1p_64x192.mem_array[128+i*4+1],
         cmb_buf_0.buf_org_2.u_ram_1p_64x192.mem_array[128+i*4+1],
         cmb_buf_0.buf_org_3.u_ram_1p_64x192.mem_array[128+i*4+1]} =
        {scan_pixel_32[`PIXEL_WIDTH*8 -1:`PIXEL_WIDTH*0 ],
         scan_pixel_32[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*24],
         scan_pixel_32[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*8 ],
         scan_pixel_32[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*16]};

        cmb_tp = $fscanf(fp_input, "%h", scan_pixel_32 );
        {cmb_buf_0.buf_org_0.u_ram_1p_64x192.mem_array[128+i*4+2],
         cmb_buf_0.buf_org_1.u_ram_1p_64x192.mem_array[128+i*4+2],
         cmb_buf_0.buf_org_2.u_ram_1p_64x192.mem_array[128+i*4+2],
         cmb_buf_0.buf_org_3.u_ram_1p_64x192.mem_array[128+i*4+2]} =
        {scan_pixel_32[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*16],
         scan_pixel_32[`PIXEL_WIDTH*8 -1:`PIXEL_WIDTH*0 ],
         scan_pixel_32[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*24],
         scan_pixel_32[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*8 ]};

        cmb_tp = $fscanf(fp_input, "%h", scan_pixel_32 );
        {cmb_buf_0.buf_org_0.u_ram_1p_64x192.mem_array[128+i*4+3],
         cmb_buf_0.buf_org_1.u_ram_1p_64x192.mem_array[128+i*4+3],
         cmb_buf_0.buf_org_2.u_ram_1p_64x192.mem_array[128+i*4+3],
         cmb_buf_0.buf_org_3.u_ram_1p_64x192.mem_array[128+i*4+3]} =
        {scan_pixel_32[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*8 ],
         scan_pixel_32[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*16],
         scan_pixel_32[`PIXEL_WIDTH*8 -1:`PIXEL_WIDTH*0 ],
         scan_pixel_32[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*24]};
      end
      #55 done_o <= 1'b1;
      #10 done_o <= 1'b0;
    end
  end

endmodule
