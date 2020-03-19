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
//  Filename      : mc_chroma_top.v
//  Author        : Yufeng Bai
//  Email         : byfchina@gmail.com	
//  Created On    : 2015-01-13 
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module mc_chroma_top (
	clk		        ,
	rstn		        ,
        ctrl_launch_i           ,
        ctrl_launch_sel_i       ,
        ctrl_done_o             ,
	mv_rden_o		,
	mv_rdaddr_o		,
	mv_data_i		,
	ref_rden_o		,
	ref_idx_x_o		,
	ref_idx_y_o		,
	ref_sel_o		,
	ref_pel_i		,
	pred_pixel_o		,
	pred_wren_o		,
	pred_addr_o		
);

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input 	 [1-1:0] 	         clk 	         ; // clk signal 
input 	 [1-1:0] 	         rstn 	         ; // asynchronous reset 

input                            ctrl_launch_i   ;
input                            ctrl_launch_sel_i;// u/v sel
output                           ctrl_done_o     ;

output 	 [1-1:0] 	         mv_rden_o 	 ; // fmv read enable 
output 	 [6-1:0] 	         mv_rdaddr_o 	 ; // fmv sram read address 
input 	 [2*`FMV_WIDTH-1:0] 	 mv_data_i 	 ; // fmv from fme 

output 	 [1-1:0] 	         ref_rden_o 	 ; // referenced pixel read enable  
output 	 [8-1:0] 	         ref_idx_x_o 	 ; // referenced pixel x index 
output 	 [8-1:0] 	         ref_idx_y_o 	 ; // referenced pixel y index 
output 	 [1-1:0] 	         ref_sel_o 	 ; // u/v selection 
input 	 [8*`PIXEL_WIDTH-1:0] 	 ref_pel_i 	 ; // referenced pixel input 

output 	 [32*`PIXEL_WIDTH-1:0] 	 pred_pixel_o 	 ; // chroma predicted pixel output 
output 	 [4-1:0] 	         pred_wren_o 	 ; // chroma predicted pixel write enable 
output 	 [7-1:0] 	         pred_addr_o 	 ; // chroma predicted pixel write address 

// ********************************************
//
//    PARMETER DECLARATION
//
// ********************************************

parameter IDLE      = 2'b00;
parameter PRE       = 2'b01;
parameter MC        = 2'b10;
parameter DONE      = 2'b11;

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

// ************
//  fsm 
// ************
reg    [2-1         :0]    current_state, next_state;
// ************
// mv fetch 
// ************
wire   [`FMV_WIDTH-1:0]    fmv_y, fmv_x;
wire   [3-1         :0]    frac_y, frac_x;
reg    [1-1         :0]    mv_valid;
reg    [2-1         :0]    mv_cnt32;
reg    [2-1         :0]    mv_cnt16;
reg    [2-1         :0]    mv_cnt08;
// ************
// ref fetch 
// ************
reg    [3-1         :0]    ref_cnt;
reg    [2-1         :0]    ref_cnt32;
reg    [2-1         :0]    ref_cnt16;
reg    [2-1         :0]    ref_cnt08;
wire   [3-1         :0]    fetch_row;
wire   [3-1         :0]    fetch_row_minute;
reg    [1-1         :0]    refuv_valid;
// ************
//  store pred
// ************
reg  [2-1:0]               pred_cnt32;
reg  [2-1:0]               pred_cnt16;
reg  [2-1:0]               pred_cnt08;
reg  [32*`PIXEL_WIDTH-1:0] pred_pixel_o 	 ; // chroma predicted pixel output 
reg  [4-1:0] 	           pred_wren_o 	 ; // chroma predicted pixel write enable 
// ************
//  chroma ip 4x4
// ************
wire   [1-1:0]             end_oneblk_ip;
wire   [1-1:0]             frac_valid;     
reg    [2-1:0]             frac_idx;
reg    [6-1:0]             frac;

wire [4*`PIXEL_WIDTH-1:0] fracuv;     
wire [`PIXEL_WIDTH-1:0]   refuv_p0;
wire [`PIXEL_WIDTH-1:0]   refuv_p1;
wire [`PIXEL_WIDTH-1:0]   refuv_p2;
wire [`PIXEL_WIDTH-1:0]   refuv_p3;
wire [`PIXEL_WIDTH-1:0]   refuv_p4;
wire [`PIXEL_WIDTH-1:0]   refuv_p5;
wire [`PIXEL_WIDTH-1:0]   refuv_p6;

// delay ctrl 
reg    [6-1:0]            frac_d1          ;
reg                       refuv_valid_d1   ;

// ********************************************
//
//    FSM
//
// ********************************************

always @(*) begin
    case(current_state) 
        IDLE : begin
            if ( ctrl_launch_i)
                next_state = PRE;
            else
                next_state = IDLE;
        end
        PRE : begin
            next_state = MC;
        end
        MC  : begin
            if((&ref_cnt32) & (&ref_cnt16) & (&ref_cnt08) & (ref_cnt == fetch_row)) 
                next_state = DONE;
            else
                next_state = MC;
        end
        DONE : begin
            if((&pred_cnt32) & (&pred_cnt16) & (&pred_cnt08) & end_oneblk_ip)
                next_state = IDLE;
            else
                next_state = DONE;
        end
    endcase
end

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

// ********************************************
//
//    Combinational / Sequential Logic
//
// ********************************************

assign ctrl_done_o = (current_state == DONE) && ((&pred_cnt32) & (&pred_cnt16) & (&pred_cnt08) & end_oneblk_ip);

// ************
//   fetch mv
// ************

// mv cnt
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        mv_cnt32 <= 2'd0; 
    end
    else if (mv_cnt16 == 2'b11 && mv_cnt08 == 2'b11 && ref_cnt == fetch_row_minute) begin
        mv_cnt32 <= mv_cnt32 + 'd1; 
    end
end

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        mv_cnt16 <= 2'd0; 
    end
    else if (mv_cnt08 == 2'b11 && ref_cnt == fetch_row_minute) begin
        mv_cnt16 <= mv_cnt16 + 'd1; 
    end
end

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        mv_cnt08 <= 2'd0; 
    end
    else if (ref_cnt == fetch_row_minute) begin
        mv_cnt08 <= mv_cnt08 + 'd1; 
    end
end

// mvif 
assign mv_rden_o 	 = current_state == PRE || (current_state == MC && ref_cnt == fetch_row ); // fmv read enable 
assign mv_rdaddr_o 	 = {mv_cnt32[1], mv_cnt16[1], mv_cnt08[1], mv_cnt32[0], mv_cnt16[0], mv_cnt08[0]}; // fmv sram read address 
assign {fmv_y,fmv_x} 	 = mv_data_i 	 ; // fmv from fme 

assign frac_y            = fmv_y[2:0];
assign frac_x            = fmv_x[2:0];

assign fetch_row         = (frac_y == 'd0) ? 'd3 : 'd6;
assign fetch_row_minute  = (frac_y == 'd0) ? 'd2 : 'd5;

// ************
//  fetch ref
// ************

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        ref_cnt32 <= 3'd0; 
        ref_cnt16 <= 3'd0; 
        ref_cnt08 <= 3'd0; 
        mv_valid  <= 1'd0;
    end
    else begin
        ref_cnt32 <= mv_cnt32; 
        ref_cnt16 <= mv_cnt16; 
        ref_cnt08 <= mv_cnt08; 
        mv_valid  <= mv_rden_o;
    end
end

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        ref_cnt <= 3'd0; 
    end
    else if (ref_rden_o) begin
        if( ref_cnt == fetch_row)
            ref_cnt <= 'd0;
        else
            ref_cnt <= ref_cnt + 'd1;
    end
end
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        refuv_valid <= 1'b0; 
    end
    else begin
        refuv_valid <= ref_rden_o;
    end
end

assign ref_rden_o = (current_state == MC); // referenced pixel read enable  
assign ref_idx_x_o= $signed(fmv_x[`FMV_WIDTH-1:3]) + $signed({1'b0,ref_cnt32[0],ref_cnt16[0],ref_cnt08[0],2'b0} + 'd31); // referenced pixel x index 
assign ref_idx_y_o= $signed(fmv_y[`FMV_WIDTH-1:3]) + $signed({1'b0,ref_cnt32[1],ref_cnt16[1],ref_cnt08[1],2'b0} + {3'b0,ref_cnt} - 'd16 + ((frac_y=='d0)? 'd32: 'd31)); // referenced pixel y index 
assign ref_sel_o  = ctrl_launch_sel_i; // u/v selection 


// ************
//  store pred
// ************
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        pred_cnt32 <= 2'd0; 
    end
    else if (pred_cnt16 == 2'b11 && pred_cnt08 == 2'b11 && end_oneblk_ip) begin
        pred_cnt32 <= pred_cnt32 + 'd1; 
    end
end
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        pred_cnt16 <= 2'd0; 
    end
    else if (pred_cnt08 == 2'b11 && end_oneblk_ip) begin
        pred_cnt16 <= pred_cnt16 + 'd1; 
    end
end
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        pred_cnt08 <= 2'd0; 
    end
    else if (end_oneblk_ip) begin
        pred_cnt08 <= pred_cnt08 + 'd1; 
    end
end

always @ (*) begin
    case({pred_cnt16[0],pred_cnt08[0]})
	2'b00: begin pred_pixel_o = { {fracuv,32'b0} , 64'b0, 64'b0, 64'b0 }; pred_wren_o = 4'b1000 & {4{frac_valid}}; end 
	2'b01: begin pred_pixel_o = {  64'b0, {fracuv,32'b0}, 64'b0, 64'b0 }; pred_wren_o = 4'b0100 & {4{frac_valid}}; end 
	2'b10: begin pred_pixel_o = {  64'b0, 64'b0, {fracuv,32'b0} ,64'b0 }; pred_wren_o = 4'b0010 & {4{frac_valid}}; end 
	2'b11: begin pred_pixel_o = {  64'b0, 64'b0, 64'b0, {fracuv,32'b0} }; pred_wren_o = 4'b0001 & {4{frac_valid}}; end 
    endcase
end

//assign pred_addr_o      = {ctrl_launch_sel_i,pred_cnt32[1], pred_cnt32[0], pred_cnt16[1], pred_cnt08[1],frac_idx};
  assign pred_addr_o      = {pred_cnt32[1], pred_cnt32[0], pred_cnt16[1], pred_cnt08[1], 1'b0, frac_idx};


// ************
//  chroma ip 4x4
// ************
assign refuv_p0 = ref_pel_i[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH];
assign refuv_p1 = ref_pel_i[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH];
assign refuv_p2 = ref_pel_i[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH];
assign refuv_p3 = ref_pel_i[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH];
assign refuv_p4 = ref_pel_i[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH];
assign refuv_p5 = ref_pel_i[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH];
assign refuv_p6 = ref_pel_i[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH];

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        frac_idx <= 2'd0; 
    end
    else if (frac_valid) begin
        frac_idx <= frac_idx + 'd1;
    end
end

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        frac <= 'd0; 
    end
    else if (mv_valid) begin
        frac <= {frac_y,frac_x};
    end
end

always @ ( posedge clk or negedge rstn ) begin 
    if ( !rstn ) begin 
        frac_d1             <= 0;
        refuv_valid_d1      <= 0;
    end else begin 
        frac_d1             <= frac             ;
        refuv_valid_d1      <= refuv_valid      ;
    end 
end 

mc_chroma_ip4x4 mc_chroma_ip(
          .clk            (clk             ),
          .rstn           (rstn            ),
                                          
          .frac_i         (frac_d1         ),
                                          
          .blk_start_i    (ctrl_launch_i   ),
                                          
          .refuv_valid_i  (refuv_valid_d1  ),
          .refuv_p0_i     (refuv_p0        ),
          .refuv_p1_i     (refuv_p1        ),
          .refuv_p2_i     (refuv_p2        ),
          .refuv_p3_i     (refuv_p3        ),
          .refuv_p4_i     (refuv_p4        ),
          .refuv_p5_i     (refuv_p5        ),
          .refuv_p6_i     (refuv_p6        ),
                                          
          .frac_valid_o   (frac_valid      ),
          .end_oneblk_ip_o(end_oneblk_ip   ),
          .fracuv_o       (fracuv          )
);


endmodule

