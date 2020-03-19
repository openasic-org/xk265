//--------------------------------------------------
// 
// File Name 	: prei_ram_dp_16x32.v
// Author 		: TANG 
// Date 		: 2018-05-13
// Description  : prei_ram_dp_16x32 for original pixel
//
//-----------------------------------------------------

`include "enc_defines.v" 

module prei_ram_dp_16x32(
	clk 		,
	wr_ena_i 	, // low active
	wr_adr_i 	,
	wr_dat_i 	,
	rd_ena_i 	, // low active
	rd_adr_i 	,
	rd_dat_o 	
);

//--- input/output declaration --------------------------------
	input 				clk 		;
	input 				wr_ena_i 	;
	input 	[4 	-1 :0] 	wr_adr_i 	;
	input 	[32 -1 :0]  wr_dat_i 	;
	input 				rd_ena_i 	;
	input 	[4  -1 :0]  rd_adr_i 	;
	output  [32 -1 :0]  rd_dat_o 	;

//--- wire/reg declaration ------------------------------------
	wire 				cen_w 		;
	assign cen_w    = wr_ena_i && rd_ena_i ;

`ifdef RTL_MODEL
    ram_dp #(
        .Word_Width (   32        ),
        .Addr_Width (   4         )
        ) u_ram_dp(
            .clka       ( clk       ),  
            .cena_i     ( rd_ena_i  ), // low active
            .oena_i     ( 1'b0      ),
            .wena_i     ( 1'b1      ),
            .addra_i    ( rd_adr_i  ),
            .dataa_o    ( rd_dat_o  ),
            .dataa_i    (           ),
            .clkb       ( clk       ),     
            .cenb_i     ( wr_ena_i  ),   
            .oenb_i     ( 1'b0      ),   
            .wenb_i     ( wr_ena_i  ),   
            .addrb_i    ( wr_adr_i  ),
            .datab_o    (           ),   
            .datab_i    ( wr_dat_i  )
        );

`endif 

`ifdef XM_MODEL
rf2phd_16x32 u_rf2phd_16x32(
            .QA         ( rd_dat_o  ), // read a 
            .CLKA       ( clk       ), // 
            .CENA       ( rd_ena_i  ), // low active
            .AA         ( rd_adr_i  ), // addr a 
            .CLKB       ( clk       ), 
            .CENB       ( wr_ena_i  ), // low active
            .AB         ( wr_adr_i  ), // addr b
            .DB         ( wr_dat_i  ), // write b
            .EMAA       ( 3'b1 ), 
            .EMAB       ( 3'b1 ), 
            .RET1N      ( 1'b1 ), 
            .COLLDISN   ( 1'b1 )
        );

`endif 

endmodule 