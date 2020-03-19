//-------------------------------------------------------------------
//
//  Filename      : sram_tp_be_behave.v
//  Author        : Huang Lei Lei
//  Created       : 2017-12-02
//  Description   : rtl model for two-port sram (bit enable)
//
//-------------------------------------------------------------------
`include "enc_defines.v"

module sram_tp_be_behave (
  clk       ,
  wr_ena    ,
  wr_adr    ,
  wr_dat    ,
  rd_ena    ,
  rd_adr    ,
  rd_dat
  );


//*** PARAMETER DECLARATION ****************************************************

  parameter    ADR_WD                = 5              ;
  parameter    ADR                   = (1<<ADR_WD)    ;
  parameter    DAT_WD                = 8              ;
  parameter    COL_WD                = 8              ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  input                              clk              ;
  input      [DAT_WD/COL_WD-1 :0]    wr_ena           ;
  input      [ADR_WD       -1 :0]    wr_adr           ;
  input      [DAT_WD       -1 :0]    wr_dat           ;
  input                              rd_ena           ;
  input      [ADR_WD       -1 :0]    rd_adr           ;
  output reg [DAT_WD       -1 :0]    rd_dat           ;


//*** WIRE & REG DECLARATION ***************************************************

  reg        [DAT_WD       -1 :0]    mem_array[ADR-1 :0] ;


//*** MAIN BODY ****************************************************************

  genvar i ;

  generate
    for(i=0 ;i<DAT_WD/COL_WD ;i=i+1 ) begin
      always @(posedge clk ) begin
        if( wr_ena[i] ) begin
          mem_array[wr_adr][(i+1)*COL_WD-1:i*COL_WD] <= wr_dat[(i+1)*COL_WD-1:i*COL_WD] ;
        end
      end
    end
  endgenerate

  always @(posedge clk ) begin
    if( rd_ena ) begin
      rd_dat <= mem_array[rd_adr] ;
    end
    else begin
      rd_dat <= {{DAT_WD{1'b0}}} ;
    end
  end


//*** DEBUG ********************************************************************

`ifndef BEHAVE_MODEL

  initial begin
    #1 ;
    $display( "\t calling sram_tp_be_behave @%m" );
  end

`endif

endmodule
