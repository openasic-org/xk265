//--------------------------------------------------------------------
//
//  Filename      : fme_mv_ram_dp_64x20.v
//  Author        : TANG
//  Created       : 2018-05-13
//  Description   : fme_mv_ram_dp_64x20
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module fme_mv_ram_dp_64x20 (
    clka     ,
    cena_i   ,
    addra_i  ,
    dataa_o  ,
    clkb     ,
    cenb_i   ,
    wenb_i   ,
    addrb_i  ,
    datab_i  
);

//--- parameter declaration -------------------------
    parameter Addr_Width    = 6  ;
    parameter Word_Width    = 2*`FMV_WIDTH ;

//--- input/output declaration ----------------------
    // A port
    input                     clka      ;   // clock input
    input                     cena_i    ;   // chip enable, low active
    input   [Addr_Width-1:0]  addra_i   ;   // address input
    output  [Word_Width-1:0]  dataa_o   ;   // data output
    
    // B Port
    input                     clkb      ;   // clock input                     
    input                     cenb_i    ;   // chip enable, low active         
    input                     wenb_i    ;   // write enable, low active        
    input   [Addr_Width-1:0]  addrb_i   ;   // address input                   
    input   [Word_Width-1:0]  datab_i   ;   // data input    

//--- wire/reg declaration ---------------------------
    

//--- dut --------------------------------------------
`ifdef RTL_MODEL
    ram_dp #(
        .Word_Width (   2*`FMV_WIDTH    ),
        .Addr_Width (       6           )
        ) u_ram_dp(
            .clka       ( clka      ),  
            .cena_i     ( cena_i    ),
            .oena_i     ( 1'b0      ),
            .wena_i     ( 1'b1      ),
            .addra_i    ( addra_i   ),
            .dataa_o    ( dataa_o   ),
            .dataa_i    (           ),
            .clkb       ( clkb      ),     
            .cenb_i     ( cenb_i    ),   
            .oenb_i     ( 1'b0      ),   
            .wenb_i     ( wenb_i    ),   
            .addrb_i    ( addrb_i   ),
            .datab_o    (           ),   
            .datab_i    ( datab_i   )
        );

`endif 

`ifdef XM_MODEL
rf2phd_64x20 u_rf2phd_64x20(
            .QA         ( dataa_o   ), // read a 
            .CLKA       ( clka      ), // 
            .CENA       ( cena_i    ), // low active
            .AA         ( addra_i   ), // addr a 
            .CLKB       ( clkb      ), 
            .CENB       ( cenb_i    ), // low active
            .AB         ( addrb_i   ), // addr b
            .DB         ( datab_i   ), // write b
            .EMAA       ( 3'b1 ), 
            .EMAB       ( 3'b1 ), 
            .RET1N      ( 1'b1 ), 
            .COLLDISN   ( 1'b1 )
        );

`endif 

endmodule 