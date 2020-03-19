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
//  File Name     : buf_ram_1p_128x64.v
//  Author        : TANG 
//  Date          : 2018-05-13
//-------------------------------------------------------------------
`include "enc_defines.v"

module buf_ram_1p_128x64 (
                    clk         ,
                    ce          ,   // high active 
                    we          , // high active
                    addr        ,
                    data_i      , 
                    data_o  
);

//--- input/output declaration ------------------
input                       clk         ;                         
input                       ce          ;   
input                       we          ;   
input  [6:0]                addr        ;   
input  [`PIXEL_WIDTH*8-1:0] data_i      ; 
output [`PIXEL_WIDTH*8-1:0] data_o      ;

//--- wire/reg declaration -----------------------
wire                        ce_w        ;
wire                        we_w        ;
assign ce_w = !ce ;
assign we_w = !we ;

`ifdef RTL_MODEL 
ram_1p #(
    .Addr_Width(        7       ) , 
    .Word_Width(`PIXEL_WIDTH*8  )
    ) u_ram_1p_128x64 (
                .clk        ( clk       ), 
                .cen_i      ( ce_w      ),
                .oen_i      ( 1'b0      ),
                .wen_i      ( we_w      ),
                .addr_i     ( addr      ),
                .data_i     ( data_i    ),
                .data_o     ( data_o    )
);

`endif

`ifdef XM_MODEL 
  rfsphd_128x64 u_rfsphd_128x64(
      .Q       ( data_o       ), // output data 
      .CLK     ( clk          ), // clk 
      .CEN     ( ce_w         ), // low active 
      .WEN     ( we_w         ), // low active 
      .A       ( addr         ), // address 
      .D       ( data_i       ), // input data 
      .EMA     ( 3'b1 ),  
      .EMAW    ( 2'b0 ),
      .RET1N   ( 1'b1 ) 
        );
`endif

`ifdef SMIC13_MODEL

`endif
endmodule
