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
// Filename       : mem_lipo_1p.v
// Author         : Yibo FAN
// Created        : 2014-03-26
// Description    : Memory Line Pixel Input, Parallel Pixel Output, Single Ports
//					Support:     PORT A            PORT B
//							 32x1 line IN      32x1 line OUT
//                			 			       16x2 line OUT
//							 			       8x4  line OUT
//							 			       4x4  line OUT
//------------------------------------------------------------------- 
`include "enc_defines.v"

module mem_lipo_1p   (
				clk      		,      
				rst_n        	,
				
				a_wen_i			,
				a_addr_i	    ,
				a_wdata_i       ,
				
				b_ren_i 		,
				b_sel_i	    	,
				b_size_i 	    ,
				b_4x4_x_i	    ,
				b_4x4_y_i	    ,
				b_idx_i  	    ,
				b_rdata_o 	    
);

// ********************************************
//                                             				
//    Parameter DECLARATION                    				
//                                             				
// ********************************************
localparam 						I_4x4	= 2'b00,
           						I_8x8	= 2'b01,
           						I_16x16	= 2'b10,
           						I_32x32	= 2'b11;
           
// ********************************************
//                                             
//    INPUT / OUTPUT DECLARATION               
//                                             
// ********************************************           
input							clk			; //clock
input							rst_n		; //reset signal    

input							a_wen_i		; //A port# write enable
input  [7:0]					a_addr_i	; //A port# write address	
input  [`PIXEL_WIDTH*32-1:0]	a_wdata_i   ; //A port# write data

input  							b_ren_i 	; //B port# read enable    
input  [1:0]					b_sel_i		; //B port# 0: luma; 1: chroma
input  [1:0]					b_size_i 	; //B port# block size, 00:4x4, 01: 8x8, 10: 16x16, 11:32x32 
input  [3:0]					b_4x4_x_i	; //B port# top_left 4x4 block x coodinate 
input  [3:0]					b_4x4_y_i	; //B port# top_left 4x4 block y coodinate 
input  [4:0]					b_idx_i  	; //B port# row index in block 
output [`PIXEL_WIDTH*32-1:0]	b_rdata_o 	; //B port# read data 
                	 
// ********************************************
//                                             
//    Signals DECLARATION               
//                                             
// ********************************************
// R/W Data & Address 
reg [4:0]						b0_b_addr_l,
								b1_b_addr_l,
								b2_b_addr_l, 
								b3_b_addr_l; 
								
wire [7:0] 						b0_b_addr, b0_addr,           
                                b1_b_addr, b1_addr,
                                b2_b_addr, b2_addr,
                                b3_b_addr, b3_addr;

wire							b0_ce, b0_we,
                                b1_ce, b1_we,
                                b2_ce, b2_we,
                                b3_ce, b3_we;
                                								
reg  [`PIXEL_WIDTH*8-1:0] 		b0_a_datai,
                                b1_a_datai,								
                                b2_a_datai,								
                                b3_a_datai;								

wire [`PIXEL_WIDTH*8-1:0] 		b0_b_datao,		
                                b1_b_datao,
                                b2_b_datao,
                                b3_b_datao;

reg  [`PIXEL_WIDTH*32-1:0] 		b_rdata_o;     

reg  [1:0]						b_size_r ;
reg  [3:0]						b_4x4_x_r;
reg  [4:0]						b_idx_r  ;          
                                                    
// ********************************************
//                                             
//    Logic DECLARATION                         
//                                             
// ********************************************
// --------------------------------------------
//		Memory Banks
//---------------------------------------------    
//----------------------- PORT A Channel ---------------------//            
// Port A: Data alignment
always @(*) begin
	case (a_addr_i[1:0])
		2'd0: {b0_a_datai, b2_a_datai, b1_a_datai, b3_a_datai} = a_wdata_i;
		2'd1: {b1_a_datai, b3_a_datai, b2_a_datai, b0_a_datai} = a_wdata_i;
		2'd2: {b2_a_datai, b0_a_datai, b3_a_datai, b1_a_datai} = a_wdata_i;
		2'd3: {b3_a_datai, b1_a_datai, b0_a_datai, b2_a_datai} = a_wdata_i;
	endcase
end

//----------------------------- PORT B Channel --------------------------//
// Port B : Address generator
always @(*) begin
	case (b_size_i)
		I_4x4	, 
		I_8x8	: begin	
					case (b_4x4_x_i[2:1])
		          		2'd0: begin b0_b_addr_l[1:0]=2'd0; b1_b_addr_l[1:0]=2'd1; b2_b_addr_l[1:0]=2'd2; b3_b_addr_l[1:0]=2'd3; end
		          		2'd1: begin b0_b_addr_l[1:0]=2'd2; b1_b_addr_l[1:0]=2'd3; b2_b_addr_l[1:0]=2'd0; b3_b_addr_l[1:0]=2'd1; end
		          		2'd2: begin b0_b_addr_l[1:0]=2'd3; b1_b_addr_l[1:0]=2'd0; b2_b_addr_l[1:0]=2'd1; b3_b_addr_l[1:0]=2'd2; end      
		          		2'd3: begin b0_b_addr_l[1:0]=2'd1; b1_b_addr_l[1:0]=2'd2; b2_b_addr_l[1:0]=2'd3; b3_b_addr_l[1:0]=2'd0; end    
		          	endcase  
				  end
		I_16x16	: begin b0_b_addr_l[1:0] = {b_idx_i[1], b_4x4_x_i[2]};
				  		b1_b_addr_l[1:0] = {b_idx_i[1], ~b_4x4_x_i[2]};
				  		b2_b_addr_l[1:0] = {b_idx_i[1], b_4x4_x_i[2]};
				  		b3_b_addr_l[1:0] = {b_idx_i[1], ~b_4x4_x_i[2]};
				  end                
		I_32x32	: begin b0_b_addr_l[1:0] = b_idx_i[1:0]; 
						b1_b_addr_l[1:0] = b_idx_i[1:0]; 
						b2_b_addr_l[1:0] = b_idx_i[1:0]; 
						b3_b_addr_l[1:0] = b_idx_i[1:0]; 
				  end
	endcase
end

always @(*) begin
	case (b_size_i)
		I_4x4	: begin b0_b_addr_l[4:2] = b_4x4_y_i[2:0]; 
						b1_b_addr_l[4:2] = b_4x4_y_i[2:0]; 
						b2_b_addr_l[4:2] = b_4x4_y_i[2:0]; 
						b3_b_addr_l[4:2] = b_4x4_y_i[2:0]; 
					end              
		I_8x8   : begin b0_b_addr_l[4:2] = {b_4x4_y_i[2:1], b_idx_i[2]}; 
						b1_b_addr_l[4:2] = {b_4x4_y_i[2:1], b_idx_i[2]}; 
						b2_b_addr_l[4:2] = {b_4x4_y_i[2:1], b_idx_i[2]}; 
						b3_b_addr_l[4:2] = {b_4x4_y_i[2:1], b_idx_i[2]};
					end              
		I_16x16 : begin b0_b_addr_l[4:2] = {b_4x4_y_i[2], b_idx_i[3:2]}; 
						b1_b_addr_l[4:2] = {b_4x4_y_i[2], b_idx_i[3:2]}; 
						b2_b_addr_l[4:2] = {b_4x4_y_i[2], b_idx_i[3:2]}; 
						b3_b_addr_l[4:2] = {b_4x4_y_i[2], b_idx_i[3:2]};
					end              
		I_32x32 : begin b0_b_addr_l[4:2] = b_idx_i[4:2]; 
						b1_b_addr_l[4:2] = b_idx_i[4:2]; 
						b2_b_addr_l[4:2] = b_idx_i[4:2]; 
						b3_b_addr_l[4:2] = b_idx_i[4:2];
					end
	endcase
end

assign b0_b_addr = {b_sel_i, b_4x4_y_i[3], b_4x4_x_i[3], b0_b_addr_l};
assign b1_b_addr = {b_sel_i, b_4x4_y_i[3], b_4x4_x_i[3], b1_b_addr_l};
assign b2_b_addr = {b_sel_i, b_4x4_y_i[3], b_4x4_x_i[3], b2_b_addr_l};
assign b3_b_addr = {b_sel_i, b_4x4_y_i[3], b_4x4_x_i[3], b3_b_addr_l};
      
// Port B: Data alignment
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		b_size_r  <= 'b0; 
		b_4x4_x_r <= 'b0;    
		b_idx_r   <= 'b0;
	end
	else begin 
		b_size_r  <= b_size_i; 
		b_4x4_x_r <= b_4x4_x_i;
		b_idx_r   <= b_idx_i;
	end
end

always @(*) begin
	case (b_size_r)
		I_4x4	: if (b_4x4_x_r[0]) begin
					case (b_4x4_x_r[2:1]) 
					2'd0: b_rdata_o = {b0_b_datao[`PIXEL_WIDTH*4-1:0], b0_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4],b1_b_datao[`PIXEL_WIDTH*4-1:0], b1_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4], b2_b_datao[`PIXEL_WIDTH*4-1:0], b2_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4], b3_b_datao[`PIXEL_WIDTH*4-1:0], b3_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4]};
					2'd1: b_rdata_o = {b2_b_datao[`PIXEL_WIDTH*4-1:0], b2_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4],b3_b_datao[`PIXEL_WIDTH*4-1:0], b3_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4], b0_b_datao[`PIXEL_WIDTH*4-1:0], b0_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4], b1_b_datao[`PIXEL_WIDTH*4-1:0], b1_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4]};
					2'd2: b_rdata_o = {b1_b_datao[`PIXEL_WIDTH*4-1:0], b1_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4],b2_b_datao[`PIXEL_WIDTH*4-1:0], b2_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4], b3_b_datao[`PIXEL_WIDTH*4-1:0], b3_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4], b0_b_datao[`PIXEL_WIDTH*4-1:0], b0_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4]};
					2'd3: b_rdata_o = {b3_b_datao[`PIXEL_WIDTH*4-1:0], b3_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4],b0_b_datao[`PIXEL_WIDTH*4-1:0], b0_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4], b1_b_datao[`PIXEL_WIDTH*4-1:0], b1_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4], b2_b_datao[`PIXEL_WIDTH*4-1:0], b2_b_datao[`PIXEL_WIDTH*8-1:`PIXEL_WIDTH*4]};
					endcase
				  end
				  else begin
				  	case (b_4x4_x_r[2:1]) 
					2'd0: b_rdata_o = {b0_b_datao, b1_b_datao, b2_b_datao, b3_b_datao}; 
					2'd1: b_rdata_o = {b2_b_datao, b3_b_datao, b0_b_datao, b1_b_datao}; 
					2'd2: b_rdata_o = {b1_b_datao, b2_b_datao, b3_b_datao, b0_b_datao}; 
					2'd3: b_rdata_o = {b3_b_datao, b0_b_datao, b1_b_datao, b2_b_datao}; 
					endcase
				  end
		I_8x8  	: case (b_4x4_x_r[2:1])
					2'd0: b_rdata_o = {b0_b_datao, b1_b_datao, b2_b_datao, b3_b_datao};
					2'd1: b_rdata_o = {b2_b_datao, b3_b_datao, b0_b_datao, b1_b_datao};
					2'd2: b_rdata_o = {b1_b_datao, b2_b_datao, b3_b_datao, b0_b_datao};
					2'd3: b_rdata_o = {b3_b_datao, b0_b_datao, b1_b_datao, b2_b_datao};   
				endcase
		I_16x16	: case ({b_4x4_x_r[2], b_idx_r[1]})  //{b_4x4_x_r[2], b_idx_r[1]
					2'd0: b_rdata_o = {b0_b_datao, b2_b_datao, b1_b_datao, b3_b_datao};
					2'd1: b_rdata_o = {b2_b_datao, b0_b_datao, b3_b_datao, b1_b_datao};
					2'd2: b_rdata_o = {b1_b_datao, b3_b_datao, b2_b_datao, b0_b_datao};
					2'd3: b_rdata_o = {b3_b_datao, b1_b_datao, b0_b_datao, b2_b_datao};
				endcase
		I_32x32	: case (b_idx_r[1:0])
					2'd0: b_rdata_o = {b0_b_datao, b2_b_datao, b1_b_datao, b3_b_datao}; 
					2'd1: b_rdata_o = {b1_b_datao, b3_b_datao, b2_b_datao, b0_b_datao}; 
					2'd2: b_rdata_o = {b2_b_datao, b0_b_datao, b3_b_datao, b1_b_datao}; 
					2'd3: b_rdata_o = {b3_b_datao, b1_b_datao, b0_b_datao, b2_b_datao};  
				endcase
	endcase
end

// MEM Modules
assign error = a_wen_i & b_ren_i;

assign b0_ce = a_wen_i | b_ren_i;
assign b1_ce = a_wen_i | b_ren_i;
assign b2_ce = a_wen_i | b_ren_i;
assign b3_ce = a_wen_i | b_ren_i;

assign b0_we = a_wen_i; // write priority
assign b1_we = a_wen_i; // write priority
assign b2_we = a_wen_i; // write priority
assign b3_we = a_wen_i; // write priority

assign b0_addr = a_wen_i ? a_addr_i : b0_b_addr;
assign b1_addr = a_wen_i ? a_addr_i : b1_b_addr;
assign b2_addr = a_wen_i ? a_addr_i : b2_b_addr;
assign b3_addr = a_wen_i ? a_addr_i : b3_b_addr;

buf_ram_1p_64x192	buf_org_0(
		.clk  		( clk			),
		.ce			( b0_ce			),
		.we         ( b0_we			),
		.addr       ( b0_addr		),
		.data_i     ( b0_a_datai	),
		.data_o     ( b0_b_datao	)
); 

buf_ram_1p_64x192	buf_org_1(
		.clk  		( clk			),
		.ce			( b1_ce			),
		.we         ( b1_we			),
		.addr       ( b1_addr		),
		.data_i     ( b1_a_datai	),
		.data_o     ( b1_b_datao	)
);

buf_ram_1p_64x192	buf_org_2(
		.clk  		( clk			),
		.ce			( b2_ce			),
		.we         ( b2_we			),
		.addr       ( b2_addr		),
		.data_i     ( b2_a_datai	),
		.data_o     ( b2_b_datao	)
);

buf_ram_1p_64x192	buf_org_3(
		.clk  		( clk			),
		.ce			( b3_ce			),
		.we         ( b3_we			),
		.addr       ( b3_addr		),
		.data_i     ( b3_a_datai	),
		.data_o     ( b3_b_datao	)
);

endmodule