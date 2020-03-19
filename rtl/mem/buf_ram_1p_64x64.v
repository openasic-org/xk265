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
//  File Name     : buf_ram_1p_64x64.v
//  Author        : TANG 
//  Date          : 2018-05-13
//-------------------------------------------------------------------
`include "enc_defines.v"

module buf_ram_1p_64x64 (
                    clk         ,
                    ce          ,  
                    we          ,
                    addr        ,
                    data_i      , 
                    data_o  
);

//--- input/output declaration -----------------------
input                       clk         ;                         
input                       ce          ; // high active    
input                       we          ; // high active  
input  [5:0]                addr        ;   
input  [`PIXEL_WIDTH*8-1:0] data_i      ; 
output [`PIXEL_WIDTH*8-1:0] data_o      ;

//--- wire/reg declaration -----------------------------

wire ce_w = !ce ;
wire we_w = !we ;


`ifdef RTL_MODEL 
ram_1p #(
    .Addr_Width(    6         ), 
    .Word_Width(`PIXEL_WIDTH*8)
    ) u_ram_1p_64x64 (
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
  rfsphd_64x64 u_rfsphd_64x64(
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
