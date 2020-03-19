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
//  Filename      : fetch_cur_chroma.v
//  Author        : Yufeng Bai
//  Email 	  : byfchina@gmail.com
//
//-------------------------------------------------------------------
//
//  Modified      : 2015-09-02 by HLL
//  Description   : rotate by sys_start_i
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fetch_cur_chroma (
	clk		,
	rstn		,
  sysif_start_i    ,
	rec_cur_4x4_x_i		,
	rec_cur_4x4_y_i		,
	rec_cur_4x4_idx_i		,
	rec_cur_sel_i		,
	rec_cur_size_i		,
	rec_cur_rden_i		,
	rec_cur_pel_o		,
	db_cur_4x4_x_i		,
	db_cur_4x4_y_i		,
	db_cur_4x4_idx_i	,
	db_cur_sel_i		,
	db_cur_size_i		,
	db_cur_rden_i		,
	db_cur_pel_o		,
	ext_load_done_i		,
	ext_load_data_i		,
        ext_load_addr_i         ,
	ext_load_valid_i
);

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input 	 [1-1:0] 	            clk 	         ; // clk signal
input 	 [1-1:0] 	            rstn 	         ; // asynchronous reset
input                         sysif_start_i    ;
input 	 [4-1:0] 	            rec_cur_4x4_x_i 	 ; // rec current lcu x
input 	 [4-1:0] 	            rec_cur_4x4_y_i 	 ; // rec current lcu y
input 	 [5-1:0] 	            rec_cur_4x4_idx_i 	 ; // rec current lcu idx
input 	 [2-1:0] 	            rec_cur_sel_i 	 ; // rec current lcu chroma/luma sel
input 	 [2-1:0] 	            rec_cur_size_i 	 ; // "rec current lcu size :4x4
input 	 [1-1:0] 	            rec_cur_rden_i 	 ; // rec current lcu read enable
output 	 [32*`PIXEL_WIDTH-1:0] 	    rec_cur_pel_o 	 ; // rec current lcu pixel
input 	 [4-1:0] 	            db_cur_4x4_x_i 	 ; // db current lcu x
input 	 [4-1:0] 	            db_cur_4x4_y_i 	 ; // db current lcu y
input 	 [5-1:0] 	            db_cur_4x4_idx_i 	 ; // db current lcu idx
input 	 [2-1:0] 	            db_cur_sel_i 	 ; // db current lcu chroma/luma sel
input 	 [2-1:0] 	            db_cur_size_i 	 ; // "db current lcu size :4x4
input 	 [1-1:0] 	            db_cur_rden_i 	 ; // db current lcu read enable
output 	 [32*`PIXEL_WIDTH-1:0] 	    db_cur_pel_o 	 ; // db current lcu pixel
input 	 [1-1:0] 	            ext_load_done_i 	 ; // load current lcu done
input 	 [32*`PIXEL_WIDTH-1:0] 	    ext_load_data_i 	 ; // load current lcu data
input 	 [6-1:0] 	            ext_load_addr_i 	 ; // load current lcu address
input 	 [1-1:0] 	            ext_load_valid_i 	 ; // load current lcu data valid

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

reg      [3-1:0]               rotate                   ; // rotatation counter

reg 	 [4-1:0] 	       cur_00_4x4_x 	        ;
reg 	 [4-1:0] 	       cur_00_4x4_y 	        ;
reg 	 [5-1:0] 	       cur_00_idx       	;
reg 	 [2-1:0] 	       cur_00_sel 	        ;
reg 	 [2-1:0] 	       cur_00_size 	        ;
reg 	 [1-1:0] 	       cur_00_ren 	        ;
reg  	 [32*`PIXEL_WIDTH-1:0] cur_00_pel 	        ;
wire     [32*`PIXEL_WIDTH-1:0] cur_00_rdata             ;

reg 	 [4-1:0] 	       cur_01_4x4_x 	        ;
reg 	 [4-1:0] 	       cur_01_4x4_y 	        ;
reg 	 [5-1:0] 	       cur_01_idx       	;
reg 	 [2-1:0] 	       cur_01_sel 	        ;
reg 	 [2-1:0] 	       cur_01_size 	        ;
reg 	 [1-1:0] 	       cur_01_ren 	        ;
reg  	 [32*`PIXEL_WIDTH-1:0] cur_01_pel 	        ;
wire     [32*`PIXEL_WIDTH-1:0] cur_01_rdata             ;

reg 	 [4-1:0] 	       cur_02_4x4_x 	        ;
reg 	 [4-1:0] 	       cur_02_4x4_y 	        ;
reg 	 [5-1:0] 	       cur_02_idx       	;
reg 	 [2-1:0] 	       cur_02_sel 	        ;
reg 	 [2-1:0] 	       cur_02_size 	        ;
reg 	 [1-1:0] 	       cur_02_ren 	        ;
reg  	 [32*`PIXEL_WIDTH-1:0] cur_02_pel 	        ;
wire     [32*`PIXEL_WIDTH-1:0] cur_02_rdata             ;

reg      [1-1:0]               cur_00_wen               ;
reg      [6-1:0]               cur_00_waddr             ;
reg      [32*`PIXEL_WIDTH-1:0] cur_00_wdata             ;

reg      [1-1:0]               cur_01_wen               ;
reg      [6-1:0]               cur_01_waddr             ;
reg      [32*`PIXEL_WIDTH-1:0] cur_01_wdata             ;

reg      [1-1:0]               cur_02_wen               ;
reg      [6-1:0]               cur_02_waddr             ;
reg      [32*`PIXEL_WIDTH-1:0] cur_02_wdata             ;


reg      [32*`PIXEL_WIDTH-1:0] db_cur_pel_o 	        ;
reg      [32*`PIXEL_WIDTH-1:0] rec_cur_pel_o 	        ;

// ********************************************
//
//    Combinational Logic
//
// ********************************************

always @ (*) begin
    case(rotate)
    'd0: begin
        cur_00_wen   = ext_load_valid_i;
        cur_00_waddr = ext_load_addr_i;
        cur_00_wdata = ext_load_data_i;
        cur_00_ren   = 'd0;
        cur_00_sel   = 'd0;
        cur_00_size  = 'd0;
        cur_00_4x4_x = 'd0;
        cur_00_4x4_y = 'd0;
        cur_00_idx   = 'd0;

        cur_01_wen   = 'd0;
        cur_01_waddr = 'd0;
        cur_01_wdata = 'd0;
        cur_01_ren   = db_cur_rden_i;
        cur_01_sel   = db_cur_sel_i;
        cur_01_size  = db_cur_size_i;
        cur_01_4x4_x = db_cur_4x4_x_i;
        cur_01_4x4_y = db_cur_4x4_y_i;
        cur_01_idx   = db_cur_4x4_idx_i;

        cur_02_wen   = 'd0;
        cur_02_waddr = 'd0;
        cur_02_wdata = 'd0;
        cur_02_ren   = rec_cur_rden_i;
        cur_02_sel   = rec_cur_sel_i;
        cur_02_size  = rec_cur_size_i;
        cur_02_4x4_x = rec_cur_4x4_x_i;
        cur_02_4x4_y = rec_cur_4x4_y_i;
        cur_02_idx   = rec_cur_4x4_idx_i;

	db_cur_pel_o = cur_01_rdata;
	rec_cur_pel_o = cur_02_rdata;
    end
    'd1: begin
        cur_00_wen   = 'd0;
        cur_00_waddr = 'd0;
        cur_00_wdata = 'd0;
        cur_00_ren   = rec_cur_rden_i;
        cur_00_sel   = rec_cur_sel_i;
        cur_00_size  = rec_cur_size_i;
        cur_00_4x4_x = rec_cur_4x4_x_i;
        cur_00_4x4_y = rec_cur_4x4_y_i;
        cur_00_idx   = rec_cur_4x4_idx_i;

        cur_01_wen   = ext_load_valid_i;
        cur_01_waddr = ext_load_addr_i;
        cur_01_wdata = ext_load_data_i;
        cur_01_ren   = 'd0;
        cur_01_sel   = 'd0;
        cur_01_size  = 'd0;
        cur_01_4x4_x = 'd0;
        cur_01_4x4_y = 'd0;
        cur_01_idx   = 'd0;

        cur_02_wen   = 'd0;
        cur_02_waddr = 'd0;
        cur_02_wdata = 'd0;
        cur_02_ren   = db_cur_rden_i;
        cur_02_sel   = db_cur_sel_i;
        cur_02_size  = db_cur_size_i;
        cur_02_4x4_x = db_cur_4x4_x_i;
        cur_02_4x4_y = db_cur_4x4_y_i;
        cur_02_idx   = db_cur_4x4_idx_i;

	db_cur_pel_o = cur_02_rdata;
	rec_cur_pel_o = cur_00_rdata;
    end
    'd2: begin
        cur_00_wen   = 'd0;
        cur_00_waddr = 'd0;
        cur_00_wdata = 'd0;
        cur_00_ren   = db_cur_rden_i;
        cur_00_sel   = db_cur_sel_i;
        cur_00_size  = db_cur_size_i;
        cur_00_4x4_x = db_cur_4x4_x_i;
        cur_00_4x4_y = db_cur_4x4_y_i;
        cur_00_idx   = db_cur_4x4_idx_i;

        cur_01_wen   = 'd0;
        cur_01_waddr = 'd0;
        cur_01_wdata = 'd0;
        cur_01_ren   = rec_cur_rden_i;
        cur_01_sel   = rec_cur_sel_i;
        cur_01_size  = rec_cur_size_i;
        cur_01_4x4_x = rec_cur_4x4_x_i;
        cur_01_4x4_y = rec_cur_4x4_y_i;
        cur_01_idx   = rec_cur_4x4_idx_i;

        cur_02_wen   = ext_load_valid_i;
        cur_02_waddr = ext_load_addr_i;
        cur_02_wdata = ext_load_data_i;
        cur_02_ren   = 'd0;
        cur_02_sel   = 'd0;
        cur_02_size  = 'd0;
        cur_02_4x4_x = 'd0;
        cur_02_4x4_y = 'd0;
        cur_02_idx   = 'd0;

	db_cur_pel_o = cur_00_rdata;
	rec_cur_pel_o = cur_01_rdata;
    end
    default: begin
        cur_00_wen   = 'd0;
        cur_00_waddr = 'd0;
        cur_00_wdata = 'd0;
        cur_00_ren   = 'd0;
        cur_00_sel   = 'd0;
        cur_00_size  = 'd0;
        cur_00_4x4_x = 'd0;
        cur_00_4x4_y = 'd0;
        cur_00_idx   = 'd0;

        cur_01_wen   = 'd0;
        cur_01_waddr = 'd0;
        cur_01_wdata = 'd0;
        cur_01_ren   = 'd0;
        cur_01_sel   = 'd0;
        cur_01_size  = 'd0;
        cur_01_4x4_x = 'd0;
        cur_01_4x4_y = 'd0;
        cur_01_idx   = 'd0;

        cur_02_wen   = 'd0;
        cur_02_waddr = 'd0;
        cur_02_wdata = 'd0;
        cur_02_ren   = 'd0;
        cur_02_sel   = 'd0;
        cur_02_size  = 'd0;
        cur_02_4x4_x = 'd0;
        cur_02_4x4_y = 'd0;
        cur_02_idx   = 'd0;

	db_cur_pel_o = 'd0;
	rec_cur_pel_o = 'd0;
    end
    endcase
end

// ********************************************
//
//    Sequential Logic
//
// ********************************************

  always @ (posedge clk or negedge rstn) begin
    if( !rstn )
       rotate <= 0 ;
    else if ( sysif_start_i ) begin
      if( rotate == 2 )
        rotate <= 0 ;
      else begin
        rotate <= rotate + 1 ;
      end
    end
  end


// ********************************************
//
//    mem
//
// ********************************************

mem_lipo_1p_64x64x4  cur00 (
    .clk      	(clk  ),
    .rst_n      (rstn ),

    .a_wen_i	(cur_00_wen  ),
    .a_addr_i	(cur_00_waddr),
    .a_wdata_i  (cur_00_wdata),

    .b_ren_i 	(cur_00_ren  ),
    .b_sel_i	(cur_00_sel  ),
    .b_size_i 	(cur_00_size ),
    .b_4x4_x_i	(cur_00_4x4_x),
    .b_4x4_y_i	(cur_00_4x4_y),
    .b_idx_i  	(cur_00_idx  ),
    .b_rdata_o 	(cur_00_rdata)
);

mem_lipo_1p_64x64x4  cur01 (
    .clk      	(clk  ),
    .rst_n      (rstn ),

    .a_wen_i	(cur_01_wen  ),
    .a_addr_i	(cur_01_waddr),
    .a_wdata_i  (cur_01_wdata),

    .b_ren_i 	(cur_01_ren  ),
    .b_sel_i	(cur_01_sel  ),
    .b_size_i 	(cur_01_size ),
    .b_4x4_x_i	(cur_01_4x4_x),
    .b_4x4_y_i	(cur_01_4x4_y),
    .b_idx_i  	(cur_01_idx  ),
    .b_rdata_o 	(cur_01_rdata)
);

mem_lipo_1p_64x64x4  cur02 (
    .clk      	(clk  ),
    .rst_n      (rstn ),

    .a_wen_i	(cur_02_wen  ),
    .a_addr_i	(cur_02_waddr),
    .a_wdata_i  (cur_02_wdata),

    .b_ren_i 	(cur_02_ren  ),
    .b_sel_i	(cur_02_sel  ),
    .b_size_i 	(cur_02_size ),
    .b_4x4_x_i	(cur_02_4x4_x),
    .b_4x4_y_i	(cur_02_4x4_y),
    .b_idx_i  	(cur_02_idx  ),
    .b_rdata_o 	(cur_02_rdata)
);

endmodule

