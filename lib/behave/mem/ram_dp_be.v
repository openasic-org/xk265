//-------------------------------------------------------------------
//                                                                 
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//                                                                  
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE      
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//                                                                  
//  VIPcore       : http://soc.fudan.edu.cn/vip    
//  IP Owner 	  : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn             
//-------------------------------------------------------------------
// Filename       : ram_dp_be.v
// Author         : Yibo FAN 
// Created        : 2012-04-01
// Description    : Dual Port Ram Model with write byte enable
//               
// $Id$ 
//------------------------------------------------------------------- 
`include "enc_defines.v"

module ram_dp_be (
				clka    ,  
				cena_i  ,
		        oena_i  ,
		        wena_i  ,
		        addra_i ,
		        dataa_o ,
		        dataa_i ,
				clkb    ,     
				cenb_i  ,   
				oenb_i  ,   
				wenb_i  ,  
				addrb_i	,
				datab_o ,   
				datab_i
);

// ********************************************
//                                             
//    Parameter DECLARATION                    
//                                             
// ********************************************
parameter     		Word_Width=32;
parameter	  		Addr_Width=8;

localparam			Byte_Width=(Word_Width>>3);

// ********************************************
//                                             
//    Input/Output DECLARATION                    
//                                             
// ********************************************
// A port
input                     clka;      // clock input
input   		          cena_i;    // chip enable, low active
input   		          oena_i;    // data output enable, low active
input   [Byte_Width-1:0]  wena_i;    // write enable, low active
input   [Addr_Width-1:0]  addra_i;   // address input
input   [Word_Width-1:0]  dataa_i;   // data input
output	[Word_Width-1:0]  dataa_o;   // data output

// B Port
input                     clkb;      // clock input                     
input   		          cenb_i;    // chip enable, low active         
input   		          oenb_i;    // data output enable, low active  
input   [Byte_Width-1:0]  wenb_i;    // write enable, low active      
input   [Addr_Width-1:0]  addrb_i;   // address input                   
input   [Word_Width-1:0]  datab_i;   // data input                      
output	[Word_Width-1:0]  datab_o;   // data output                     

// ********************************************
//                                             
//    Register DECLARATION                 
//                                             
// ********************************************
reg    [Word_Width-1:0]   mem_array[(1<<Addr_Width)-1:0];

// ********************************************
//                                             
//    Wire DECLARATION                 
//                                             
// ********************************************
reg	   [Word_Width-1:0]  dataa_r;
reg	   [Word_Width-1:0]  datab_r;

reg	   [Word_Width-1:0]  dataa_w;
reg	   [Word_Width-1:0]  datab_w;
wire   [Word_Width-1:0]  dataa_m;
wire   [Word_Width-1:0]  datab_m;

// ********************************************
//                                             
//    Logic DECLARATION                 
//                                             
// ********************************************
// -- A Port --//
assign dataa_m = mem_array[addra_i];

genvar i;
generate
	for (i=0; i<Byte_Width; i=i+1) begin:i_n
		always@(*) begin
			dataa_w[(i+1)*8-1:i*8] = wena_i[i] ? dataa_m[(i+1)*8-1:i*8] : dataa_i[(i+1)*8-1:i*8];
		end
	end
endgenerate

always @(posedge clka) begin                
	if(!cena_i && !(&wena_i)) 
		mem_array[addra_i] <= dataa_w;
end

always @(posedge clka) begin
	if (!cena_i && wena_i)
		dataa_r <= mem_array[addra_i];
	else
		dataa_r <= 'bx;
end

assign dataa_o = oena_i ? 'bz : dataa_r;

// -- B Port --//
assign datab_m = mem_array[addrb_i];

genvar j;
generate
	for (j=0; j<Byte_Width; j=j+1) begin:j_n
		always@(*) begin
			datab_w[(j+1)*8-1:j*8] = wenb_i[j] ? datab_m[(j+1)*8-1:j*8] : datab_i[(j+1)*8-1:j*8];
		end
	end
endgenerate
	
always @(posedge clkb) begin                
	if(!cenb_i && !(&wenb_i)) 
		mem_array[addrb_i] <= datab_w;
end

always @(posedge clkb) begin   
	if (!cenb_i && wenb_i)
		datab_r <= mem_array[addrb_i];
	else
		datab_r <= 'bx;
end

assign datab_o = oenb_i ? 'bz : datab_r;

endmodule