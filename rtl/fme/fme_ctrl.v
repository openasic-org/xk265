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
//  Filename      : fme_ctrl.v
//  Author        : Yufeng Bai
//  Email         : byfchina@gmail.com  
//-------------------------------------------------------------------
//  Modified      : TANG
//  Date          : 2018-06-15
//  Description   : support SKIP
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fme_ctrl (
    clk                     ,
    rstn                    ,
    sysif_start_i           ,
    sysif_done_o            ,
    current_state           ,
    fimeif_partition_i      ,
    fimeif_mv_rden_o        ,
    fimeif_mv_rdaddr_o      ,
    fimeif_mv_data_i        ,
    mcif_mv_rden_o          ,
    mcif_mv_rdaddr_o        ,
    mcif_mv_data_i          ,
    ref_rden_o              ,
    ref_idx_x_o             ,
    ref_idx_y_o             ,
    ip_start_o              ,
    ip_done_i               ,
    ip_mv_x_o               ,
    ip_mv_y_o               ,
    ip_frac_x_o             ,
    ip_frac_y_o             ,
    ip_half_flag_o          ,
    ip_idx_o                , 
    cost_done_i             ,
    predicted_en_o          ,
    // skip interfaces
    skip_start_o            ,
    skip_done_i             ,
    cur_cu_mod_o            ,
    cur_pu_x_o              ,
    cur_pu_y_o              ,
    cur_pu_wid_o            ,
    cur_pu_hgt_o            ,
    cur_pu_blk_o            ,
    cur_pu_8x8_adr_o        ,
    cur_pu_blk_num_o        ,
    skip_pu_start_o         ,
    // mc skip
    mc_skip_flg_i               
);

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input    [1-1:0]            clk                  ; // clk signal 
input    [1-1:0]            rstn                 ; // asynchronous reset 
input    [1-1:0]            sysif_start_i        ; // fme start signal 
output   [1-1:0]            sysif_done_o         ; // fme done signal 
output   [4-1:0]            current_state        ; // fme current state
input    [42-1:0]           fimeif_partition_i   ; // ime partition info  
output                      fimeif_mv_rden_o     ;
output   [6-1:0]            fimeif_mv_rdaddr_o   ;
input    [2*`FMV_WIDTH-1:0] fimeif_mv_data_i     ;
output                      mcif_mv_rden_o       ;
output   [6-1:0]            mcif_mv_rdaddr_o     ;
input    [2*`FMV_WIDTH-1:0] mcif_mv_data_i       ;
output   [1-1:0]            ref_rden_o           ; // referenced pixel read enable  
//output     [7-1:0]       ref_idx_x_o           ; // referenced pixel x index 
//output     [7-1:0]       ref_idx_y_o           ; // referenced pixel y index 
output   [8-1:0]            ref_idx_x_o          ;
output   [8-1:0]            ref_idx_y_o          ;
output   [1-1:0]            ip_start_o           ; // interpolation start 
input    [1-1:0]            ip_done_i            ; // interpolation done 
output   [`FMV_WIDTH-1:0]   ip_mv_x_o            ; // interpolation mv x index 
output   [`FMV_WIDTH-1:0]   ip_mv_y_o            ; // interpolation mv y index 
output   [2-1:0]            ip_frac_x_o          ; // interpolation mv x index 
output   [2-1:0]            ip_frac_y_o          ; // interpolation mv y index 
output   [1-1:0]            ip_half_flag_o       ; // interpolation half/quarter flag 
output   [6-1:0]            ip_idx_o             ; // interpolation 8x8 block index
input    [1-1:0]            cost_done_i          ; // cost cal & cmp done 
output   [1-1:0]            predicted_en_o       ;

// skip interfaces
output                      skip_start_o         ;
input                       skip_done_i          ;
output   [2-1:0]            cur_cu_mod_o         ;
output   [3-1:0]            cur_pu_x_o           ;
output   [3-1:0]            cur_pu_y_o           ;
output   [4-1:0]            cur_pu_wid_o         ;
output   [4-1:0]            cur_pu_hgt_o         ;
output                      cur_pu_blk_o         ;
output   [6-1:0]            cur_pu_8x8_adr_o     ;
output   [7-1:0]            cur_pu_blk_num_o     ;
output                      skip_pu_start_o      ;
input                       mc_skip_flg_i        ;
// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

localparam IDLE      = 4'd0;

localparam PRE_HALF  = 4'd1;
localparam HALF      = 4'd2;
localparam DONE_HALF = 4'd3;

localparam PRE_QUAR  = 4'd4;
localparam QUAR      = 4'd5;
localparam DONE_QUAR = 4'd6;

localparam PRE_SKIP  = 4'd7;
localparam SKIP      = 4'd8;
localparam DONE_SKIP = 4'd9;

localparam PRE_MC    = 4'd10;
localparam MC        = 4'd11;
localparam DONE_MC   = 4'd12;

localparam CU_64 = 0 ,
           CU_32 = 1 ,
           CU_16 = 2 ,
           CU_08 = 3 ;

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************
reg       [3:           0]      current_state, next_state;

reg       [1:           0]      cnt32, cnt16, cnt08;
reg       [1:           0]      mode32, mode16;
wire      [1:           0]      mode64;

wire      [2:           0]      fimeif_rdaddr_x;
wire      [2:           0]      fimeif_rdaddr_y;
wire signed [`FMV_WIDTH-1:0]    imv_x           ;
wire signed [`FMV_WIDTH-1:0]    imv_y           ;
wire signed [`FMV_WIDTH-1:0]    fmv_x           ;
wire signed [`FMV_WIDTH-1:0]    fmv_y           ;

reg       [1-1         :0]      ip_start_o     ;	
reg       [3:           0]      refcnt         ;
reg       [1-1:0] 	        sysif_done_o   ; 

wire      [2-1:         0]      partition64    ;
wire      [2-1:         0]      partition32_00 ;
wire      [2-1:         0]      partition32_01 ;
wire      [2-1:         0]      partition32_02 ;
wire      [2-1:         0]      partition32_03 ;
wire      [2-1:         0]      partition16_00 ;
wire      [2-1:         0]      partition16_01 ;
wire      [2-1:         0]      partition16_02 ;
wire      [2-1:         0]      partition16_03 ;
wire      [2-1:         0]      partition16_04 ;
wire      [2-1:         0]      partition16_05 ;
wire      [2-1:         0]      partition16_06 ;
wire      [2-1:         0]      partition16_07 ;
wire      [2-1:         0]      partition16_08 ;
wire      [2-1:         0]      partition16_09 ;
wire      [2-1:         0]      partition16_10 ;
wire      [2-1:         0]      partition16_11 ;
wire      [2-1:         0]      partition16_12 ;
wire      [2-1:         0]      partition16_13 ;
wire      [2-1:         0]      partition16_14 ;
wire      [2-1:         0]      partition16_15 ;

wire signed [3-1:       0]      dmv_x, dmv_y   ;
wire        [2-1:       0]      frac_x, frac_y ;

// skip interfaces
wire                            skip_start_o     ;
reg      [2-1:0]                cur_cu_mod_o     ;
reg      [3-1:0]                cur_pu_x_o       ;
reg      [3-1:0]                cur_pu_y_o       ;
reg      [4-1:0]                cur_pu_wid_o     ;
reg      [4-1:0]                cur_pu_hgt_o     ;
reg                             cur_pu_blk_o     ;
reg      [6-1:0]                cur_pu_8x8_adr_o ;
reg      [7-1:0]                cur_pu_blk_num_o ;
wire                            skip_pu_start_o  ;

wire     [6-1:0]                cur_pu_adr_w     ;
reg      [6-1:0]                cur_pu_adr_d1    ;
// ********************************************
//
//    Combinational Logic
//
// ********************************************

assign partition64    = fimeif_partition_i[1 : 0];
assign partition32_00 = fimeif_partition_i[3 : 2];
assign partition32_01 = fimeif_partition_i[5 : 4];
assign partition32_02 = fimeif_partition_i[7 : 6];
assign partition32_03 = fimeif_partition_i[9 : 8];
assign partition16_00 = fimeif_partition_i[11 : 10];
assign partition16_01 = fimeif_partition_i[13 : 12];
assign partition16_02 = fimeif_partition_i[15 : 14];
assign partition16_03 = fimeif_partition_i[17 : 16];
assign partition16_04 = fimeif_partition_i[19 : 18];
assign partition16_05 = fimeif_partition_i[21 : 20];
assign partition16_06 = fimeif_partition_i[23 : 22];
assign partition16_07 = fimeif_partition_i[25 : 24];
assign partition16_08 = fimeif_partition_i[27 : 26];
assign partition16_09 = fimeif_partition_i[29 : 28];
assign partition16_10 = fimeif_partition_i[31 : 30];
assign partition16_11 = fimeif_partition_i[33 : 32];
assign partition16_12 = fimeif_partition_i[35 : 34];
assign partition16_13 = fimeif_partition_i[37 : 36];
assign partition16_14 = fimeif_partition_i[39 : 38];
assign partition16_15 = fimeif_partition_i[41 : 40];

assign mode64         = partition64;

always @ (*) begin
    case(cnt32)
	2'd0: mode32 = partition32_00;
	2'd1: mode32 = partition32_01;
	2'd2: mode32 = partition32_02;
	2'd3: mode32 = partition32_03;
    endcase
end

always @ (*) begin
    case({cnt32,cnt16})
	4'd00:mode16 = partition16_00;
	4'd01:mode16 = partition16_01;
	4'd02:mode16 = partition16_02;
	4'd03:mode16 = partition16_03;
	4'd04:mode16 = partition16_04;
	4'd05:mode16 = partition16_05;
	4'd06:mode16 = partition16_06;
	4'd07:mode16 = partition16_07;
	4'd08:mode16 = partition16_08;
	4'd09:mode16 = partition16_09;
	4'd10:mode16 = partition16_10;
	4'd11:mode16 = partition16_11;
	4'd12:mode16 = partition16_12;
	4'd13:mode16 = partition16_13;
	4'd14:mode16 = partition16_14;
	4'd15:mode16 = partition16_15;
    endcase
end


always @ (*) begin
    case ( current_state) 
    IDLE : begin
        if (sysif_start_i) begin
            next_state = PRE_HALF;
        end
        else begin
            next_state = IDLE;
        end
    end
    PRE_HALF: 
        if ( 1 /*fmv_candi_rdy_i*/ )
            next_state = HALF;
        else 
            next_state = PRE_HALF ;
    HALF : begin
        if (cnt08 == 'd3 && cnt16 == 'd3 && cnt32 == 'd3 && refcnt == 'd15) begin
            next_state = DONE_HALF;
        end
        else begin
            next_state = HALF;
        end
        end
    DONE_HALF: begin
        if (cost_done_i)
            next_state = PRE_QUAR;
        else
            next_state = DONE_HALF;
    end
    PRE_QUAR: 
        if ( 1 /*fmv_candi_rdy_i*/  ) 
            next_state = QUAR;
        else 
            next_state = PRE_QUAR ;
    QUAR : begin
        if (cnt08 == 'd3 && cnt16 == 'd3 && cnt32 == 'd3 && refcnt == 'd15) begin
            next_state = DONE_QUAR;
        end
        else begin
            next_state = QUAR;
        end
    end
    DONE_QUAR: begin
        if (cost_done_i)
            next_state = PRE_SKIP;
        else
            next_state = DONE_QUAR;
    end
    PRE_SKIP:next_state = SKIP ;
    SKIP : begin
        if (cnt08 == 'd3 && cnt16 == 'd3 && cnt32 == 'd3 && refcnt == 'd15) begin
            next_state = DONE_SKIP;
        end
        else begin
            next_state = SKIP;
        end
    end
    DONE_SKIP: begin
        if ( skip_done_i )
            next_state = PRE_MC;
        else 
            next_state = DONE_SKIP ;
    end
    PRE_MC: next_state = MC;
    MC   : begin
        if (cnt08 == 'd3 && cnt16 == 'd3 && cnt32 == 'd3 && refcnt == 'd15) begin
            next_state = DONE_MC;
        end
        else begin
            next_state = MC;
        end
    end
    DONE_MC: begin
        if (ip_done_i) begin
            next_state = IDLE;
        end
        else begin
            next_state = DONE_MC;
        end
    end
    default:next_state = IDLE;
    endcase
end

// ********************************************
//
//    Sequential Logic
//
// ********************************************

//fsm
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
    current_state <= IDLE;
    end
    else begin
    current_state <= next_state;
    end
end

// fme done
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
    sysif_done_o <= 'd0;
    end
    else if(current_state == DONE_MC && ip_done_i) begin
    sysif_done_o <= 1'b1;
    end
    else begin
    sysif_done_o <= 1'b0;
    end
end

// block index generation
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	cnt32 <= 'd0;
    end
    else if (current_state == IDLE || current_state == DONE_HALF || current_state == DONE_QUAR || current_state == DONE_SKIP) begin
	cnt32 <= 'd0;
    end
    else if (cnt16 == 'd3 && cnt08 == 'd3 && refcnt == 'd15) begin
	case (cnt32)
	    'd0 : cnt32 <= (mode64 == `PART_NX2N) ? 'd2 : 'd1;
	    'd1 : cnt32 <= (mode64 == `PART_NX2N) ? 'd3 : 'd2;
	    'd2 : cnt32 <= (mode64 == `PART_NX2N) ? 'd1 : 'd3;
	    'd3 : cnt32 <= 'd0;
	endcase
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	cnt16 <= 'd0;
    end
    else if (current_state == IDLE || current_state == DONE_HALF || current_state == DONE_QUAR || current_state == DONE_SKIP) begin
	cnt16 <= 'd0;
    end
    else if (cnt08 == 'd3 &&  refcnt == 'd15) begin
	case (cnt16)
	    'd0 : cnt16 <= (mode32 == `PART_NX2N) ? 'd2 : 'd1;
	    'd1 : cnt16 <= (mode32 == `PART_NX2N) ? 'd3 : 'd2;
	    'd2 : cnt16 <= (mode32 == `PART_NX2N) ? 'd1 : 'd3;
	    'd3 : cnt16 <= 'd0;
	endcase
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	cnt08 <= 'd0;
    end
    else if (current_state == IDLE || current_state == DONE_HALF || current_state == DONE_QUAR || current_state == DONE_SKIP) begin
	cnt08 <= 'd0;
    end
    else if (refcnt == 'd15) begin
	case (cnt08)
	    'd0 : cnt08 <= (mode16 == `PART_NX2N) ? 'd2 : 'd1;
	    'd1 : cnt08 <= (mode16 == `PART_NX2N) ? 'd3 : 'd2;
	    'd2 : cnt08 <= (mode16 == `PART_NX2N) ? 'd1 : 'd3;
	    'd3 : cnt08 <= 'd0;
	endcase
    end
end

// mv fetching
//
assign fimeif_mv_rden_o   = (  current_state == PRE_HALF 
                            || current_state == PRE_QUAR 
                            || current_state == PRE_SKIP
                            || current_state == PRE_MC 
                            || (   refcnt =='d0 
                                && ~ip_start_o 
                                && (   current_state != IDLE 
                                    && current_state != DONE_HALF 
                                    && current_state != DONE_QUAR 
                                    && current_state != DONE_SKIP
                                    && current_state != DONE_MC)));

assign fimeif_rdaddr_x    = {cnt32[0],cnt16[0],cnt08[0]};
assign fimeif_rdaddr_y    = {cnt32[1],cnt16[1],cnt08[1]};
assign fimeif_mv_rdaddr_o = {fimeif_rdaddr_y,fimeif_rdaddr_x};

assign mcif_mv_rden_o     = fimeif_mv_rden_o && (current_state == PRE_QUAR || current_state == QUAR || current_state == PRE_MC || current_state == MC);
assign mcif_mv_rdaddr_o   = {fimeif_rdaddr_y,fimeif_rdaddr_x};

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	ip_start_o <= 1'b0;
    end
    else begin
	ip_start_o <= fimeif_mv_rden_o;
    end
end

// ref pixel fetch
always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
	refcnt <= 'd0;
    end
    else if ( fimeif_mv_rden_o || current_state == DONE_HALF || current_state == DONE_QUAR || current_state == IDLE) begin
	refcnt <= 'd0;
    end
    else begin
	refcnt <= refcnt + 'd1;
    end
end

//----------------------------------------------------------------
//
//      skip 
//
//-----------------------------------------------------------------

// pu index
always @(posedge clk or negedge rstn) begin 
    if ( !rstn ) begin 
        cur_cu_mod_o   <= 0 ;
        cur_pu_x_o     <= 0 ;
        cur_pu_y_o     <= 0 ;
        cur_pu_wid_o   <= 0 ;
        cur_pu_hgt_o   <= 0 ;
        cur_pu_blk_o   <= 0 ;
        cur_pu_blk_num_o<= 0 ;
    end 
    else if ( mode64 != `PART_SPLIT ) begin 
        cur_cu_mod_o   <= CU_64 ; // 
        case ( mode64 )
            `PART_2NX2N : begin 
                cur_pu_x_o     <= 0 ;
                cur_pu_y_o     <= 0 ;
                cur_pu_wid_o   <= 8 ;
                cur_pu_hgt_o   <= 8 ;
                cur_pu_blk_o   <= 0 ;
                cur_pu_blk_num_o<= 64 ;
            end 
            `PART_2NXN : begin 
                cur_pu_x_o     <= 0 ;
                cur_pu_y_o     <= {cnt32[1], 2'b0}  ;
                cur_pu_wid_o   <= 8 ;
                cur_pu_hgt_o   <= 4 ;
                cur_pu_blk_o   <= cnt32[1]  ;
                cur_pu_blk_num_o<= 32 ;
            end 
            `PART_NX2N : begin 
                cur_pu_x_o     <= {cnt32[0], 2'b0}  ;
                cur_pu_y_o     <= 0 ;
                cur_pu_wid_o   <= 4 ;
                cur_pu_hgt_o   <= 8 ;
                cur_pu_blk_o   <= cnt32[0]  ;
                cur_pu_blk_num_o<= 32 ;
            end
            default : ;
        endcase 
    end else if ( mode32 != `PART_SPLIT ) begin 
        cur_cu_mod_o   <= CU_32 ; // 
        case ( mode32 )
            `PART_2NX2N : begin 
                cur_pu_x_o     <= {cnt32[0], 2'b0} ;
                cur_pu_y_o     <= {cnt32[1], 2'b0} ;
                cur_pu_wid_o   <= 4  ;
                cur_pu_hgt_o   <= 4  ;
                cur_pu_blk_o   <= 0  ;
                cur_pu_blk_num_o<= 16 ;
            end 
            `PART_2NXN : begin 
                cur_pu_x_o     <= {cnt32[0], 1'b0, 1'b0} ;
                cur_pu_y_o     <= {cnt32[1], cnt16[1], 1'b0} ;
                cur_pu_wid_o   <= 4  ;
                cur_pu_hgt_o   <= 2  ;
                cur_pu_blk_o   <= cnt16[1]  ;
                cur_pu_blk_num_o<= 8 ;
            end 
            `PART_NX2N : begin 
                cur_pu_x_o     <= {cnt32[0], cnt16[0], 1'b0} ;
                cur_pu_y_o     <= {cnt32[1], 1'b0, 1'b0} ; 
                cur_pu_wid_o   <= 2  ;
                cur_pu_hgt_o   <= 4  ;
                cur_pu_blk_o   <= cnt16[0]  ;
                cur_pu_blk_num_o<= 8 ;
            end
            default : ;
        endcase 
    end else if ( mode16 != `PART_SPLIT ) begin 
        cur_cu_mod_o   <= CU_16 ; // 
        case ( mode16 )
            `PART_2NX2N : begin 
                cur_pu_x_o     <= {cnt32[0], cnt16[0], 1'b0} ;
                cur_pu_y_o     <= {cnt32[1], cnt16[1], 1'b0} ;
                cur_pu_wid_o   <= 2  ;
                cur_pu_hgt_o   <= 2  ;
                cur_pu_blk_o   <= 0  ;
                cur_pu_blk_num_o<= 4 ;
            end 
            `PART_2NXN : begin 
                cur_pu_x_o     <= {cnt32[0], cnt16[0], 1'b0} ;
                cur_pu_y_o     <= {cnt32[1], cnt16[1], cnt08[1]} ;
                cur_pu_wid_o   <= 2  ;
                cur_pu_hgt_o   <= 1  ;
                cur_pu_blk_o   <= cnt08[1]  ;
                cur_pu_blk_num_o<= 2 ;
            end 
            `PART_NX2N : begin 
                cur_pu_x_o     <= {cnt32[0], cnt16[0], cnt08[0]} ;
                cur_pu_y_o     <= {cnt32[1], cnt16[1], 1'b0} ;
                cur_pu_wid_o   <= 1  ;
                cur_pu_hgt_o   <= 2  ;
                cur_pu_blk_o   <= cnt08[0]  ;
                cur_pu_blk_num_o<= 2 ;
            end
            default : ;
        endcase 
    end else begin 
        cur_cu_mod_o   <= CU_08 ; // 
        cur_pu_x_o     <= {cnt32[0], cnt16[0], cnt08[0]} ;
        cur_pu_y_o     <= {cnt32[1], cnt16[1], cnt08[1]} ;
        cur_pu_wid_o   <= 1 ;
        cur_pu_hgt_o   <= 1 ;
        cur_pu_blk_o   <= 0 ;
        cur_pu_blk_num_o<= 1 ;
    end 
end 

always @ ( posedge clk or negedge rstn )begin 
    if ( !rstn )
        cur_pu_8x8_adr_o <= 0 ;
    else 
        cur_pu_8x8_adr_o <= {cnt32[1], cnt16[1], cnt08[1], cnt32[0], cnt16[0], cnt08[0]};
end 

assign cur_pu_adr_w = {cur_pu_y_o[2], cur_pu_x_o[2], cur_pu_y_o[1], cur_pu_x_o[1], cur_pu_y_o[0], cur_pu_x_o[0]} ;

always @ ( posedge clk or negedge rstn ) begin 
    if ( !rstn ) 
        cur_pu_adr_d1 <= 0 ;
    else 
        cur_pu_adr_d1 <= cur_pu_adr_w ;
end 

assign skip_pu_start_o = ((current_state==SKIP || current_state==MC) && (cur_pu_adr_d1 != cur_pu_adr_w)) || (current_state==PRE_SKIP) || (current_state==PRE_MC) ;

assign skip_start_o = current_state == PRE_SKIP ;

assign imv_x = (current_state == SKIP || mc_skip_flg_i ) ? 0 : fimeif_mv_data_i[2*`FMV_WIDTH-1 : `FMV_WIDTH]; // skip mode and mv candidate == 0
assign imv_y = (current_state == SKIP || mc_skip_flg_i ) ? 0 : fimeif_mv_data_i[`FMV_WIDTH-1   :          0]; // skip mode and mv candidate == 0
assign fmv_x = (current_state == SKIP || mc_skip_flg_i ) ? 0 : mcif_mv_data_i[2*`FMV_WIDTH-1 : `FMV_WIDTH];
assign fmv_y = (current_state == SKIP || mc_skip_flg_i ) ? 0 : mcif_mv_data_i[`FMV_WIDTH-1   :          0];

assign ip_mv_x_o = (ip_half_flag_o) ? imv_x : fmv_x;
assign ip_mv_y_o = (ip_half_flag_o) ? imv_y : fmv_y;
assign ip_half_flag_o = (current_state == HALF || current_state == DONE_HALF) ? 1'b1 : 1'b0;
assign ip_idx_o       = {cnt32, cnt16, cnt08};

//assign ref_idx_x_o = imv_x[8:2] + {1'b0, cnt32[0], cnt16[0], cnt08[0],3'b0}                 + 7'd12; //  imv for refpel fetching
//assign ref_idx_y_o = imv_y[8:2] + {1'b0, cnt32[1], cnt16[1], cnt08[1],3'b0} + {3'b0,refcnt} + 7'd12; //  imv for refpel fetching
assign ref_idx_x_o = imv_x[9:2] + {2'b0, cnt32[0], cnt16[0], cnt08[0], 3'b0}                  + 8'd60;
assign ref_idx_y_o = imv_y[9:2] + {2'b0, cnt32[1], cnt16[1], cnt08[1], 3'b0} + {4'b0, refcnt} + 8'd60 - 8'd32;
assign ref_rden_o  = (current_state == HALF || current_state == QUAR || current_state == SKIP || current_state == MC) && ~fimeif_mv_rden_o;


assign dmv_x = fmv_x - imv_x;
assign dmv_y = fmv_y - imv_y;

assign frac_x = (dmv_x == 0) ? 2'b0 : ((dmv_x > 0) ? 2'b01 : 2'b11);
assign frac_y = (dmv_y == 0) ? 2'b0 : ((dmv_y > 0) ? 2'b01 : 2'b11);

assign ip_frac_x_o = (ip_half_flag_o) ? 2'b00 : frac_x; 
assign ip_frac_y_o = (ip_half_flag_o) ? 2'b00 : frac_y; 

assign predicted_en_o = (current_state == MC || current_state == DONE_MC);

endmodule


