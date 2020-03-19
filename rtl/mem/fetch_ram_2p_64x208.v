//-------------------------------------------------------------------
//                                                                 
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//                                                                  
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE      
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//                                                                  
//  VIPcore       : http://soc.fudan.edu.cn/vip    
//  IP Owner     : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn             
//-------------------------------------------------------------------
// Filename       : fetch_ram_2p_64x208.v                                               
// Author         : Yibo FAN                                         
// Created        : 2014-04-07                                      
// Description    : buf ram for coefficient                                    
//-------------------------------------------------------------------
//
//  Modified      : 2014-08-18 by HLL
//  Description   : db supported
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fetch_ram_2p_64x208 (
            clk          ,
            a_we         , // write 
            a_addr       , // write 
            a_data_i     , // write 
            b_re         , // read
            b_addr       ,
            b_data_o    
);

// ********************************************
//                                             
//    Parameters DECLARATION                 
//                                             
// ********************************************


// ********************************************
//                                             
//    Input/Output DECLARATION                    
//                                             
// ********************************************
input                           clk         ; 
// PORT A                              
input  [1:0]                    a_we        ;     
input  [7:0]                    a_addr      ;  
input  [`PIXEL_WIDTH*8-1:0]     a_data_i    ; 
// PORT B              
input                           b_re        ; // high active 
input  [7:0]                    b_addr      ;
output [`PIXEL_WIDTH*8-1:0]     b_data_o    ;

// ********************************************
//                                             
//    Signals DECLARATION                        
//                                             
// ********************************************
reg   [`PIXEL_WIDTH*8-1:0]      a_dataw     ;
reg   [63:0]                     a_wen       ;

// ********************************************
//                                             
//    Logic DECLARATION                 
//                                             
// ********************************************
always @(*) begin
	case (a_we)
		2'b00: begin a_wen=64'hffff_ffff_ffff_ffff; end
		2'b01: begin a_wen={32'hffff_ffff, 32'h0} ; end // low active
		2'b10: begin a_wen={32'b0, 32'hffff_ffff} ; end			  
		2'b11: begin a_wen=64'h0       	          ; end
	endcase
end

wire    cena_w ;
wire    cenb_w ;
assign cena_w = ~b_re ;
assign cenb_w = a_we == 0 ;

`ifdef RTL_MODEL
  sram_tp_be_behave #(
    .ADR_WD    ( 8           ),
    .DAT_WD    ( 64          ),
    .COL_WD    ( 1           )
  ) sram_tp_be_behave(
    .clk       ( clk         ),
    .wr_ena    ( ~a_wen      ), // high active
    .wr_adr    ( a_addr      ),
    .wr_dat    ( a_data_i    ),
    .rd_ena    ( b_re        ),
    .rd_adr    ( b_addr      ),
    .rd_dat    ( b_data_o    )
    );

`endif

`ifdef FPGA_MODEL 

ram_2p_64x256 u_ram_2p_64x256(
	.byteena_a	( ~a_wen	),
	.clock		( clk		),
	.data		( a_data_i	),
	.rdaddress	( b_addr	),
	.wraddress	( a_addr	),
	.wren		( |a_we		),
	.q			( b_data_o	)
);

`endif 

`ifdef XM_MODEL
  rf2phddm_208x64 u_rf2phddm_208x64(
    .QA        ( b_data_o    ), // read output
    .CLKA      ( clk         ), 
    .CENA      ( cena_w      ), // low active
    .AA        ( b_addr      ), 
    .CLKB      ( clk         ), 
    .CENB      ( cenb_w      ), 
    .WENB      ( a_wen       ), // low active
    .AB        ( a_addr      ), 
    .DB        ( a_data_i    ), 
    .EMAA       ( 3'b1  ), 
    .EMAB       ( 3'b1  ), 
    .RET1N      ( 1'b1  ),
    .COLLDISN   ( 1'b1 )
    );
`endif  
endmodule
