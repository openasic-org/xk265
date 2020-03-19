//----------------------------------------------
// 
// File Name 	: mc_mv_ram_sp_64x20.v
// Author 		: TANG 
// Date 		: 2018-05-14
// Description  : mc_mv_ram_sp_64x20
//
//------------------------------------------------

`include "enc_defines.v"

module mc_mv_ram_sp_512x20(
		clk    ,
		cen_i  , // low active
		wen_i  , // low active
		addr_i ,
		data_i ,
		data_o 
	);

//--- input/output declaration --------------------------
	input 						 clk 		;
	input 						 cen_i 		;
	input 						 wen_i 		;
	input 	[6+3 			 -1 :0]  addr_i 	;
	input 	[2*`FMV_WIDTH-1 :0]  data_i 	;
	output 	[2*`FMV_WIDTH-1 :0]  data_o 	;

//--- main body ---------------------------------------------


`ifdef RTL_MODEL
  ram_1p #(
      .Word_Width(  20   ) ,
      .Addr_Width(  6+3  )
      ) u_ram_1p(
        .clk    ( clk       ),
        .cen_i  ( cen_i     ),
        .oen_i  ( 1'b0      ),
        .wen_i  ( wen_i     ),
        .addr_i ( addr_i    ),
        .data_i ( data_i    ),      
        .data_o ( data_o    )           
  );

`endif

`ifdef XM_MODEL 
    rfsphd_512x20 u_rfsphd_512x20(
        .Q      (data_o     ), // data_o
        .CLK    (clk        ), 
        .CEN    (cen_i      ), 
        .WEN    (wen_i      ), 
        .A      (addr_i     ), // addr
        .D      (data_i     ), // data_i
        .EMA    ( 3'b1 ), 
        .EMAW   ( 2'b0 ),
        .RET1N  ( 1'b1 )
        );   
`endif 


endmodule 