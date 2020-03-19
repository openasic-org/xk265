//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2014, VIPcore Group, Fudan University
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
//  Filename      : fetch_rf_1p_768x128.v
//  Author        : Yufeng Bai
//  Email         : byfchina@gmail.com    
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fetch_rf_1p_64x256 (
    clk            ,
    rstn           ,

    wrif_en_i      ,
    wrif_addr_i    ,
    wrif_data_i   ,

    rdif_en_i      ,
    rdif_addr_i   ,
    rdif_pdata_o        
);

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input      [1-1:0]                  clk               ; // clk signal 
input      [1-1:0]                  rstn              ; // asynchronous reset 

input      [1-1:0]                  wrif_en_i         ; // write enabel signal 
input      [6-1:0]                  wrif_addr_i       ; // mem addr (0 - 95) 
input      [32*`PIXEL_WIDTH-1:0]    wrif_data_i       ; // write pixel data (8 pixels) 

input      [1-1:0]                  rdif_en_i         ; // read referrence pixels enable signale 
input      [6-1:0]                  rdif_addr_i       ; // search window x position (0 - 32 )
output     [32*`PIXEL_WIDTH-1:0]    rdif_pdata_o      ; // referrence pixles data 

// ********************************************
//
//    Wire DECLARATION
//
// ********************************************

wire       [6-1:0]                  ref_addr;

assign ref_addr = (wrif_en_i) ? wrif_addr_i : rdif_addr_i;

// ********************************************
//
//   MEM INSTANCE DECLARATION
//
// ********************************************

`ifdef RTL_MODEL
    rf_1p #(.Addr_Width(6),.Word_Width(`PIXEL_WIDTH*32))
    	wrap (
    	.clk (clk),
    	.cen_i(1'b0),
    	.wen_i(~wrif_en_i),
    	.addr_i(ref_addr),
    	.data_i(wrif_data_i),
    	.data_o(rdif_pdata_o)
    );
`endif 

`ifdef XM_MODEL
wire	[63:0]	wrif_data_i1	= wrif_data_i[63:0];
wire	[63:0]	wrif_data_i2	= wrif_data_i[127:64];
wire	[63:0]	wrif_data_i3	= wrif_data_i[191:128];
wire	[63:0]	wrif_data_i4	= wrif_data_i[255:192];
wire	[63:0]	rdif_pdata_o1	;
wire	[63:0]	rdif_pdata_o2	;
wire	[63:0]	rdif_pdata_o3	;
wire	[63:0]	rdif_pdata_o4	;

assign	rdif_pdata_o	= { rdif_pdata_o4, rdif_pdata_o3, rdif_pdata_o2, rdif_pdata_o1};

    rfsphd_64x64 u1_rfsphd_64x64(
        .Q       ( rdif_pdata_o1  ), // output data 
        .CLK     ( clk            ), // clk 
        .CEN     ( 1'b0           ), // low active 
        .WEN     ( ~wrif_en_i     ), // low active 
        .A       ( ref_addr       ), // address 
        .D       ( wrif_data_i1   ), // input data 
        .EMA     ( 3'b1  ),  
        .EMAW    ( 2'b0  ),
        .RET1N   ( 1'b1  ) 
        );
    rfsphd_64x64 u2_rfsphd_64x64(
        .Q       ( rdif_pdata_o2  ), // output data 
        .CLK     ( clk            ), // clk 
        .CEN     ( 1'b0           ), // low active 
        .WEN     ( ~wrif_en_i     ), // low active 
        .A       ( ref_addr       ), // address 
        .D       ( wrif_data_i2   ), // input data 
        .EMA     ( 3'b1  ),  
        .EMAW    ( 2'b0  ),
        .RET1N   ( 1'b1  ) 
        );
    rfsphd_64x64 u3_rfsphd_64x64(
        .Q       ( rdif_pdata_o3  ), // output data 
        .CLK     ( clk            ), // clk 
        .CEN     ( 1'b0           ), // low active 
        .WEN     ( ~wrif_en_i     ), // low active 
        .A       ( ref_addr       ), // address 
        .D       ( wrif_data_i3   ), // input data 
        .EMA     ( 3'b1  ),  
        .EMAW    ( 2'b0  ),
        .RET1N   ( 1'b1  ) 
        );
    rfsphd_64x64 u4_rfsphd_64x64(
        .Q       ( rdif_pdata_o4  ), // output data 
        .CLK     ( clk            ), // clk 
        .CEN     ( 1'b0           ), // low active 
        .WEN     ( ~wrif_en_i     ), // low active 
        .A       ( ref_addr       ), // address 
        .D       ( wrif_data_i4   ), // input data 
        .EMA     ( 3'b1  ),  
        .EMAW    ( 2'b0  ),
        .RET1N   ( 1'b1  ) 
        );
`endif 
endmodule

