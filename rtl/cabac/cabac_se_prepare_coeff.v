//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//-----------------------------------------------------------------------------------------------------------------------------
// Filename       : cu_binari_tree.v
// Author         : liwei
// Created        : 2018/1/10
// Description    : syntax elements related coeff
// DATA & EDITION:  2018/1/10   1.0     liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
`include "enc_defines.v"
module cabac_se_prepare_coeff(
           clk                  ,
           rst_n                ,
           cu_idx_i             ,
           cu_split_transform_i ,
           sub_block_cnt_i      ,
           tu_coeff_start_i     ,
           cu_slice_type_i      ,
           luma_dir_mode_i      ,
           //chroma_dir_mode_i    ,
           coeff_type_i         ,
           tu_4x4_block_total_i ,
           tu_depth_i           ,
           tq_rdata_i           ,

           tu_coeff_done_o      ,
           tq_ren_o             ,
           tq_raddr_o           ,

           se_pair_nxn_coeff_0_o,
           se_pair_nxn_coeff_1_o,
           se_pair_nxn_coeff_2_o,
           se_pair_nxn_coeff_3_o
       );
//-----------------------------------------------------------------------------------------------------------------------------
//
//            input and output signals declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
input          clk                  ;
input          rst_n                ;

input  [6:0]   cu_idx_i             ; // cu address
input          cu_split_transform_i ; // split into sub tu blocks
input          tu_coeff_start_i     ; // start enables
input  [1:0]   sub_block_cnt_i      ; // sub block cnt
input          cu_slice_type_i      ; //  1: I, 0: P/B
input  [5:0]   luma_dir_mode_i      ;
//input  [5:0]   chroma_dir_mode_i    ;
input  [1:0]   coeff_type_i         ; // 2:luma , 1 :chroma u ,0 : chroma v
input  [5:0]   tu_4x4_block_total_i ; // the total 4x4 block of current sub tu block
input  [1:0]   tu_depth_i           ; // 0:32x32 , 1:16x16 , 2:8x8 , 3:4x4
input  [255:0] tq_rdata_i           ; // coeff data

output         tu_coeff_done_o      ;
output         tq_ren_o             ;
output [ 8:0]  tq_raddr_o           ;

output [22:0]  se_pair_nxn_coeff_0_o;
output [22:0]  se_pair_nxn_coeff_1_o;
output [20:0]  se_pair_nxn_coeff_2_o;
output [20:0]  se_pair_nxn_coeff_3_o;

reg    [22:0]  se_pair_nxn_coeff_0_o;
reg    [22:0]  se_pair_nxn_coeff_1_o;
reg    [20:0]  se_pair_nxn_coeff_2_o;
reg    [20:0]  se_pair_nxn_coeff_3_o;

reg            tu_coeff_done_o      ;
reg            tq_ren_o             ;
reg    [8:0]   tq_raddr_o           ;


//-----------------------------------------------------------------------------------------------------------------------------
//
//            reg and wire signals declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
parameter   COEFF_IDLE        =  2'd0 ,
            COEFF_LAST_SIG_XY =  2'd1 ,
            COEFF_4x4_BLOCK   =  2'd2 ;

parameter   TCF4x4B           =  5'd29;

//-----------------------------------------------------------------------------------------------------------------------------
//
//            transfer outputs signal : se_pair
//
//-----------------------------------------------------------------------------------------------------------------------------

reg  [20:0] se_pair_skip_r            ;
wire [20:0] se_pair_last_x_prefix_0_w ;
wire [20:0] se_pair_last_x_suffix_w   ;
wire [20:0] se_pair_last_y_prefix_0_w ;
wire [20:0] se_pair_last_y_suffix_w   ;

reg  [20:0] se_pair_csbf_r            ;//coded_sub_block_flag_w


//-----------------------------------------------------------------------------------------------------------------------------
//
//            fsm signals
//
//-----------------------------------------------------------------------------------------------------------------------------
reg [ 1:0 ] coeff_next_state_r;
reg [ 1:0 ] coeff_curr_state_r;

//-----------------------------------------------------------------------------------------------------------------------------
//
//            reg and wire signals declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
reg [ 1:0 ] luma_scan_idx          ;
reg [ 1:0 ] chroma_scan_idx        ;
reg [ 1:0 ] scan_idx_r             ;
reg [ 5:0 ] coeff_addr_cnt_r       ;
reg [ 5:0 ] coeff_addr_32x32_r     ;
reg [ 3:0 ] coeff_addr_16x16_r     ;
reg [ 1:0 ] coeff_addr_8x8_r       ;
reg [ 5:0 ] coeff_addr_offset_r    ;
reg [ 5:0 ] coeff_addr_offset_d1_r ;

reg [ 7:0 ] luma_coeff_addr        ; // 0 --- 255
reg [ 5:0 ] chroma_coeff_addr      ; // 0 ---  63

reg [ 4:0 ] tu_4x4_enable_cnt_r    ;
reg [ 5:0 ] last_4x4_block_r       ;

reg         tq_ren_delay_r         ;

reg [ 1:0 ] last_sig_xy_cnt_r      ;
wire coeff_4x4_done_w              ;

// luma_scan_idx
always @*
begin
    if(cu_slice_type_i==1'b0)// inter
        luma_scan_idx   =    2'd0                        ;
    else if(tu_depth_i[1]==1'b0)// 32x32 | 16x16
        luma_scan_idx   =    2'd0                        ;
    else if(luma_dir_mode_i<6'd31&&luma_dir_mode_i>6'd21)// 8x8 and 4x4
        luma_scan_idx   =    2'd1                        ;
    else if(luma_dir_mode_i<6'd15&&luma_dir_mode_i>6'd5)
        luma_scan_idx   =    2'd2                        ;
    else
        luma_scan_idx   =    2'd0                        ;
end

// chroma_scan_idx
always @*
begin
    if(cu_slice_type_i==1'b0)// inter
        chroma_scan_idx  =  2'd0;
    else if(tu_depth_i!=2'd3)     // intra 16x16 | 8x8
        chroma_scan_idx  =  2'd0;
    else
        chroma_scan_idx  =  2'd3;
end

/*
// chroma_scan_idx
always @* begin 
    if(cu_slice_type_i==1'b0)// inter
        chroma_scan_idx  =  2'd0;                     
    else if(tu_depth_i!=2'd3)     // intra 16x16 | 8x8 
        chroma_scan_idx  =  2'd0; 
    else if(chroma_dir_mode_i==6'd36)//4x4 
        chroma_scan_idx  =  2'd3;
    else if(chroma_dir_mode_i<6'd31&&chroma_dir_mode_i>6'd21)// 8x8 and 4x4 
        chroma_scan_idx  =  2'd1;
    else if(chroma_dir_mode_i<6'd15&&chroma_dir_mode_i>6'd5)
        chroma_scan_idx  =  2'd2;
    else 
        chroma_scan_idx  =  2'd0;
end */

// scan_idx_r
always @*
begin
    if( !(coeff_type_i[1]||chroma_scan_idx==2'd3) )
        scan_idx_r =    chroma_scan_idx;
    else
        scan_idx_r =    luma_scan_idx  ;
end

// coeff_addr_cnt_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        coeff_addr_cnt_r   <=    6'd0;
    else if (coeff_curr_state_r==COEFF_IDLE && coeff_next_state_r==COEFF_LAST_SIG_XY)
        coeff_addr_cnt_r   <=    6'd0;
    else if(coeff_curr_state_r==COEFF_LAST_SIG_XY && coeff_next_state_r==COEFF_4x4_BLOCK)
        coeff_addr_cnt_r   <=    last_4x4_block_r;
    else if(coeff_curr_state_r==COEFF_LAST_SIG_XY)
        coeff_addr_cnt_r   <=    coeff_addr_cnt_r  +  6'd1;
    else if(coeff_curr_state_r == COEFF_4x4_BLOCK && coeff_4x4_done_w)
        coeff_addr_cnt_r   <=    coeff_addr_cnt_r  -  6'd1;
end

// coeff_addr_32x32_r for  diagonal scan
always @*
begin
    case(coeff_addr_cnt_r)
        6'd0  :
            coeff_addr_32x32_r =   6'd0  ; // 6'd0                                     ;
        6'd1  :
            coeff_addr_32x32_r =   6'd2  ; // 6'd8                                     ;
        6'd2  :
            coeff_addr_32x32_r =   6'd1  ; // 6'd1                                     ;
        6'd3  :
            coeff_addr_32x32_r =   6'd8  ; // 6'd16                                    ;
        6'd4  :
            coeff_addr_32x32_r =   6'd3  ; // 6'd9                                     ;
        6'd5  :
            coeff_addr_32x32_r =   6'd4  ; // 6'd2                                     ;
        6'd6  :
            coeff_addr_32x32_r =   6'd10 ; // 6'd24                                    ;
        6'd7  :
            coeff_addr_32x32_r =   6'd9  ; // 6'd17                                    ;
        6'd8  :
            coeff_addr_32x32_r =   6'd6  ; // 6'd10                                    ;
        6'd9  :
            coeff_addr_32x32_r =   6'd5  ; // 6'd3                                     ;
        6'd10 :
            coeff_addr_32x32_r =   6'd32 ; // 6'd32                                    ;
        6'd11 :
            coeff_addr_32x32_r =   6'd11 ; // 6'd25                                    ;
        6'd12 :
            coeff_addr_32x32_r =   6'd12 ; // 6'd18                                    ;
        6'd13 :
            coeff_addr_32x32_r =   6'd7  ; // 6'd11                                    ;
        6'd14 :
            coeff_addr_32x32_r =   6'd16 ; // 6'd4                                     ;
        6'd15 :
            coeff_addr_32x32_r =   6'd34 ; // 6'd40                                    ;
        6'd16 :
            coeff_addr_32x32_r =   6'd33 ; // 6'd33                                    ;
        6'd17 :
            coeff_addr_32x32_r =   6'd14 ; // 6'd26                                    ;
        6'd18 :
            coeff_addr_32x32_r =   6'd13 ; // 6'd19                                    ;
        6'd19 :
            coeff_addr_32x32_r =   6'd18 ; // 6'd12                                    ;
        6'd20 :
            coeff_addr_32x32_r =   6'd17 ; // 6'd5                                     ;
        6'd21 :
            coeff_addr_32x32_r =   6'd40 ; // 6'd48                                    ;
        6'd22 :
            coeff_addr_32x32_r =   6'd35 ; // 6'd41                                    ;
        6'd23 :
            coeff_addr_32x32_r =   6'd36 ; // 6'd34                                    ;
        6'd24 :
            coeff_addr_32x32_r =   6'd15 ; // 6'd27                                    ;
        6'd25 :
            coeff_addr_32x32_r =   6'd24 ; // 6'd20                                    ;
        6'd26 :
            coeff_addr_32x32_r =   6'd19 ; // 6'd13                                    ;
        6'd27 :
            coeff_addr_32x32_r =   6'd20 ; // 6'd6                                     ;
        6'd28 :
            coeff_addr_32x32_r =   6'd42 ; // 6'd56                                    ;
        6'd29 :
            coeff_addr_32x32_r =   6'd41 ; // 6'd49                                    ;
        6'd30 :
            coeff_addr_32x32_r =   6'd38 ; // 6'd42                                    ;
        6'd31 :
            coeff_addr_32x32_r =   6'd37 ; // 6'd35                                    ;
        6'd32 :
            coeff_addr_32x32_r =   6'd26 ; // 6'd28                                    ;
        6'd33 :
            coeff_addr_32x32_r =   6'd25 ; // 6'd21                                    ;
        6'd34 :
            coeff_addr_32x32_r =   6'd22 ; // 6'd14                                    ;
        6'd35 :
            coeff_addr_32x32_r =   6'd21 ; // 6'd7                                     ;
        6'd36 :
            coeff_addr_32x32_r =   6'd43 ; // 6'd57                                    ;
        6'd37 :
            coeff_addr_32x32_r =   6'd44 ; // 6'd50                                    ;
        6'd38 :
            coeff_addr_32x32_r =   6'd39 ; // 6'd43                                    ;
        6'd39 :
            coeff_addr_32x32_r =   6'd48 ; // 6'd36                                    ;
        6'd40 :
            coeff_addr_32x32_r =   6'd27 ; // 6'd29                                    ;
        6'd41 :
            coeff_addr_32x32_r =   6'd28 ; // 6'd22                                    ;
        6'd42 :
            coeff_addr_32x32_r =   6'd23 ; // 6'd15                                    ;
        6'd43 :
            coeff_addr_32x32_r =   6'd46 ; // 6'd58                                    ;
        6'd44 :
            coeff_addr_32x32_r =   6'd45 ; // 6'd51                                    ;
        6'd45 :
            coeff_addr_32x32_r =   6'd50 ; // 6'd44                                    ;
        6'd46 :
            coeff_addr_32x32_r =   6'd49 ; // 6'd37                                    ;
        6'd47 :
            coeff_addr_32x32_r =   6'd30 ; // 6'd30                                    ;
        6'd48 :
            coeff_addr_32x32_r =   6'd29 ; // 6'd23                                    ;
        6'd49 :
            coeff_addr_32x32_r =   6'd47 ; // 6'd59                                    ;
        6'd50 :
            coeff_addr_32x32_r =   6'd56 ; // 6'd52                                    ;
        6'd51 :
            coeff_addr_32x32_r =   6'd51 ; // 6'd45                                    ;
        6'd52 :
            coeff_addr_32x32_r =   6'd52 ; // 6'd38                                    ;
        6'd53 :
            coeff_addr_32x32_r =   6'd31 ; // 6'd31                                    ;
        6'd54 :
            coeff_addr_32x32_r =   6'd58 ; // 6'd60                                    ;
        6'd55 :
            coeff_addr_32x32_r =   6'd57 ; // 6'd53                                    ;
        6'd56 :
            coeff_addr_32x32_r =   6'd54 ; // 6'd46                                    ;
        6'd57 :
            coeff_addr_32x32_r =   6'd53 ; // 6'd39                                    ;
        6'd58 :
            coeff_addr_32x32_r =   6'd59 ; // 6'd61                                    ;
        6'd59 :
            coeff_addr_32x32_r =   6'd60 ; // 6'd54                                    ;
        6'd60 :
            coeff_addr_32x32_r =   6'd55 ; // 6'd47                                    ;
        6'd61 :
            coeff_addr_32x32_r =   6'd62 ; // 6'd62                                    ;
        6'd62 :
            coeff_addr_32x32_r =   6'd61 ; // 6'd55                                    ;
        6'd63 :
            coeff_addr_32x32_r =   6'd63 ; // 6'd63                                    ;
    endcase
end

// coeff_addr_16x16_r
always @*
begin
    case(coeff_addr_cnt_r[3:0])
        4'd0  :
            coeff_addr_16x16_r =  4'd0  ; // 4'd0                                      ;
        4'd1  :
            coeff_addr_16x16_r =  4'd2  ; // 4'd4                                      ;
        4'd2  :
            coeff_addr_16x16_r =  4'd1  ; // 4'd1                                      ;
        4'd3  :
            coeff_addr_16x16_r =  4'd8  ; // 4'd8                                      ;
        4'd4  :
            coeff_addr_16x16_r =  4'd3  ; // 4'd5                                      ;
        4'd5  :
            coeff_addr_16x16_r =  4'd4  ; // 4'd2                                      ;
        4'd6  :
            coeff_addr_16x16_r =  4'd10 ; // 4'd12                                     ;
        4'd7  :
            coeff_addr_16x16_r =  4'd9  ; // 4'd9                                      ;
        4'd8  :
            coeff_addr_16x16_r =  4'd6  ; // 4'd6                                      ;
        4'd9  :
            coeff_addr_16x16_r =  4'd5  ; // 4'd3                                      ;
        4'd10 :
            coeff_addr_16x16_r =  4'd11 ; // 4'd13                                     ;
        4'd11 :
            coeff_addr_16x16_r =  4'd12 ; // 4'd10                                     ;
        4'd12 :
            coeff_addr_16x16_r =  4'd7  ; // 4'd7                                      ;
        4'd13 :
            coeff_addr_16x16_r =  4'd14 ; // 4'd14                                     ;
        4'd14 :
            coeff_addr_16x16_r =  4'd13 ; // 4'd11                                     ;
        4'd15 :
            coeff_addr_16x16_r =  4'd15 ; // 4'd15                                       ;
    endcase
end

// coeff_addr_8x8_r
always @*
begin
    if(coeff_type_i[1])
    begin                                  // luma
        case({luma_scan_idx[0],coeff_addr_cnt_r[1:0]})
            3'd0 :
                coeff_addr_8x8_r    =  2'd0;// scan_idx_r ==0 || scan_idx_r == 2
            3'd1 :
                coeff_addr_8x8_r    =  2'd2;
            3'd2 :
                coeff_addr_8x8_r    =  2'd1;
            3'd3 :
                coeff_addr_8x8_r    =  2'd3;
            3'd4 :
                coeff_addr_8x8_r    =  2'd0;// scan_idx_r ==1
            3'd5 :
                coeff_addr_8x8_r    =  2'd1;
            3'd6 :
                coeff_addr_8x8_r    =  2'd2;
            3'd7 :
                coeff_addr_8x8_r    =  2'd3;
        endcase
    end
    else
    begin
        case(coeff_addr_cnt_r[1:0])
            2'd0 :
                coeff_addr_8x8_r    =  2'd0;// scan_idx_r ==0 || scan_idx_r == 2
            2'd1 :
                coeff_addr_8x8_r    =  2'd2;
            2'd2 :
                coeff_addr_8x8_r    =  2'd1;
            2'd3 :
                coeff_addr_8x8_r    =  2'd3;
        endcase
    end
end

// coeff_addr_offset_r
always @*
begin
    case(tu_depth_i)
        2'd0:
            coeff_addr_offset_r  =  coeff_addr_32x32_r         ; // 32x32
        2'd1:
            coeff_addr_offset_r  =  {2'b00,coeff_addr_16x16_r }; // 16x16
        2'd2:
            coeff_addr_offset_r  =  {4'b0000,coeff_addr_8x8_r }; // 8x8
        2'd3:
        begin
            if( cu_split_transform_i )
                coeff_addr_offset_r   =  {4'b0000,sub_block_cnt_i }; // 4x4
            else
                coeff_addr_offset_r   =  {4'b0000,coeff_addr_cnt_r[1:0]};
        end
    endcase
end

// coeff_addr_offset_d1_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        coeff_addr_offset_d1_r   <=   6'd0;
    else
        coeff_addr_offset_d1_r   <=   coeff_addr_offset_r;
end

// luma_coeff_addr
always @*
begin
    case(cu_idx_i)
        7'd0  :
            luma_coeff_addr  = {sub_block_cnt_i,coeff_addr_offset_r     } ; //  0  ... 64 ... 128 ... 192 ... 64x64 blocks
        7'd1  :
            luma_coeff_addr  = {2'b00          ,coeff_addr_offset_r     } ; //  0  ... 32x32 blocks
        7'd2  :
            luma_coeff_addr  = {2'b01          ,coeff_addr_offset_r     } ; // 64  ...
        7'd3  :
            luma_coeff_addr  = {2'b10          ,coeff_addr_offset_r     } ; // 128 ...
        7'd4  :
            luma_coeff_addr  = {2'b11          ,coeff_addr_offset_r     } ; // 192 ...
        7'd5  :
            luma_coeff_addr  = {4'b0000        ,coeff_addr_offset_r[3:0]} ; // 0   ... 16x16 blocks
        7'd6  :
            luma_coeff_addr  = {4'b0001        ,coeff_addr_offset_r[3:0]} ; // 16  ...
        7'd7  :
            luma_coeff_addr  = {4'b0010        ,coeff_addr_offset_r[3:0]} ; // 32  ...
        7'd8  :
            luma_coeff_addr  = {4'b0011        ,coeff_addr_offset_r[3:0]} ; // 48  ...
        7'd9  :
            luma_coeff_addr  = {4'b0100        ,coeff_addr_offset_r[3:0]} ; // 64  ...
        7'd10 :
            luma_coeff_addr  = {4'b0101        ,coeff_addr_offset_r[3:0]} ; // 80  ...
        7'd11 :
            luma_coeff_addr  = {4'b0110        ,coeff_addr_offset_r[3:0]} ; // 96  ...
        7'd12 :
            luma_coeff_addr  = {4'b0111        ,coeff_addr_offset_r[3:0]} ; // 112 ...
        7'd13 :
            luma_coeff_addr  = {4'b1000        ,coeff_addr_offset_r[3:0]} ; // 128 ...
        7'd14 :
            luma_coeff_addr  = {4'b1001        ,coeff_addr_offset_r[3:0]} ; // 144 ...
        7'd15 :
            luma_coeff_addr  = {4'b1010        ,coeff_addr_offset_r[3:0]} ; // 160 ...
        7'd16 :
            luma_coeff_addr  = {4'b1011        ,coeff_addr_offset_r[3:0]} ; // 176 ...
        7'd17 :
            luma_coeff_addr  = {4'b1100        ,coeff_addr_offset_r[3:0]} ; // 192 ...
        7'd18 :
            luma_coeff_addr  = {4'b1101        ,coeff_addr_offset_r[3:0]} ; // 208 ...
        7'd19 :
            luma_coeff_addr  = {4'b1110        ,coeff_addr_offset_r[3:0]} ; // 224 ...
        7'd20 :
            luma_coeff_addr  = {4'b1111        ,coeff_addr_offset_r[3:0]} ; // 240 ...
        7'd21 :
            luma_coeff_addr  = {6'b000000      ,coeff_addr_offset_r[1:0]} ; // 0   ... 8x8 blocks
        7'd22 :
            luma_coeff_addr  = {6'b000001      ,coeff_addr_offset_r[1:0]} ; // 4   ...
        7'd23 :
            luma_coeff_addr  = {6'b000010      ,coeff_addr_offset_r[1:0]} ; // 8   ...
        7'd24 :
            luma_coeff_addr  = {6'b000011      ,coeff_addr_offset_r[1:0]} ; // 12  ...
        7'd25 :
            luma_coeff_addr  = {6'b000100      ,coeff_addr_offset_r[1:0]} ; // 16  ...
        7'd26 :
            luma_coeff_addr  = {6'b000101      ,coeff_addr_offset_r[1:0]} ; // 20  ...
        7'd27 :
            luma_coeff_addr  = {6'b000110      ,coeff_addr_offset_r[1:0]} ; // 24  ...
        7'd28 :
            luma_coeff_addr  = {6'b000111      ,coeff_addr_offset_r[1:0]} ; // 28  ...
        7'd29 :
            luma_coeff_addr  = {6'b001000      ,coeff_addr_offset_r[1:0]} ; // 32  ...
        7'd30 :
            luma_coeff_addr  = {6'b001001      ,coeff_addr_offset_r[1:0]} ; // 36  ...
        7'd31 :
            luma_coeff_addr  = {6'b001010      ,coeff_addr_offset_r[1:0]} ; // 40  ...
        7'd32 :
            luma_coeff_addr  = {6'b001011      ,coeff_addr_offset_r[1:0]} ; // 44  ...
        7'd33 :
            luma_coeff_addr  = {6'b001100      ,coeff_addr_offset_r[1:0]} ; // 48  ...
        7'd34 :
            luma_coeff_addr  = {6'b001101      ,coeff_addr_offset_r[1:0]} ; // 52  ...
        7'd35 :
            luma_coeff_addr  = {6'b001110      ,coeff_addr_offset_r[1:0]} ; // 56  ...
        7'd36 :
            luma_coeff_addr  = {6'b001111      ,coeff_addr_offset_r[1:0]} ; // 60  ...
        7'd37 :
            luma_coeff_addr  = {6'b010000      ,coeff_addr_offset_r[1:0]} ; // 64  ...
        7'd38 :
            luma_coeff_addr  = {6'b010001      ,coeff_addr_offset_r[1:0]} ; // 68  ...
        7'd39 :
            luma_coeff_addr  = {6'b010010      ,coeff_addr_offset_r[1:0]} ; // 72  ...
        7'd40 :
            luma_coeff_addr  = {6'b010011      ,coeff_addr_offset_r[1:0]} ; // 76  ...
        7'd41 :
            luma_coeff_addr  = {6'b010100      ,coeff_addr_offset_r[1:0]} ; // 80  ...
        7'd42 :
            luma_coeff_addr  = {6'b010101      ,coeff_addr_offset_r[1:0]} ; // 84  ...
        7'd43 :
            luma_coeff_addr  = {6'b010110      ,coeff_addr_offset_r[1:0]} ; // 88  ...
        7'd44 :
            luma_coeff_addr  = {6'b010111      ,coeff_addr_offset_r[1:0]} ; // 92  ...
        7'd45 :
            luma_coeff_addr  = {6'b011000      ,coeff_addr_offset_r[1:0]} ; // 96  ...
        7'd46 :
            luma_coeff_addr  = {6'b011001      ,coeff_addr_offset_r[1:0]} ; // 100 ...
        7'd47 :
            luma_coeff_addr  = {6'b011010      ,coeff_addr_offset_r[1:0]} ; // 104 ...
        7'd48 :
            luma_coeff_addr  = {6'b011011      ,coeff_addr_offset_r[1:0]} ; // 108 ...
        7'd49 :
            luma_coeff_addr  = {6'b011100      ,coeff_addr_offset_r[1:0]} ; // 112 ...
        7'd50 :
            luma_coeff_addr  = {6'b011101      ,coeff_addr_offset_r[1:0]} ; // 116 ...
        7'd51 :
            luma_coeff_addr  = {6'b011110      ,coeff_addr_offset_r[1:0]} ; // 120 ...
        7'd52 :
            luma_coeff_addr  = {6'b011111      ,coeff_addr_offset_r[1:0]} ; // 124 ...
        7'd53 :
            luma_coeff_addr  = {6'b100000      ,coeff_addr_offset_r[1:0]} ; // 128 ...
        7'd54 :
            luma_coeff_addr  = {6'b100001      ,coeff_addr_offset_r[1:0]} ; // 132 ...
        7'd55 :
            luma_coeff_addr  = {6'b100010      ,coeff_addr_offset_r[1:0]} ; // 136 ...
        7'd56 :
            luma_coeff_addr  = {6'b100011      ,coeff_addr_offset_r[1:0]} ; // 140 ...
        7'd57 :
            luma_coeff_addr  = {6'b100100      ,coeff_addr_offset_r[1:0]} ; // 154 ...
        7'd58 :
            luma_coeff_addr  = {6'b100101      ,coeff_addr_offset_r[1:0]} ; // 158 ...
        7'd59 :
            luma_coeff_addr  = {6'b100110      ,coeff_addr_offset_r[1:0]} ; // 162 ...
        7'd60 :
            luma_coeff_addr  = {6'b100111      ,coeff_addr_offset_r[1:0]} ; // 166 ...
        7'd61 :
            luma_coeff_addr  = {6'b101000      ,coeff_addr_offset_r[1:0]} ; // 160 ...
        7'd62 :
            luma_coeff_addr  = {6'b101001      ,coeff_addr_offset_r[1:0]} ; // 164 ...
        7'd63 :
            luma_coeff_addr  = {6'b101010      ,coeff_addr_offset_r[1:0]} ; // 168 ...
        7'd64 :
            luma_coeff_addr  = {6'b101011      ,coeff_addr_offset_r[1:0]} ; // 172 ...
        7'd65 :
            luma_coeff_addr  = {6'b101100      ,coeff_addr_offset_r[1:0]} ; // 176 ...
        7'd66 :
            luma_coeff_addr  = {6'b101101      ,coeff_addr_offset_r[1:0]} ; // 180 ...
        7'd67 :
            luma_coeff_addr  = {6'b101110      ,coeff_addr_offset_r[1:0]} ; // 184 ...
        7'd68 :
            luma_coeff_addr  = {6'b101111      ,coeff_addr_offset_r[1:0]} ; // 188 ...
        7'd69 :
            luma_coeff_addr  = {6'b110000      ,coeff_addr_offset_r[1:0]} ; // 192 ...
        7'd70 :
            luma_coeff_addr  = {6'b110001      ,coeff_addr_offset_r[1:0]} ; // 196 ...
        7'd71 :
            luma_coeff_addr  = {6'b110010      ,coeff_addr_offset_r[1:0]} ; // 200 ...
        7'd72 :
            luma_coeff_addr  = {6'b110011      ,coeff_addr_offset_r[1:0]} ; // 204 ...
        7'd73 :
            luma_coeff_addr  = {6'b110100      ,coeff_addr_offset_r[1:0]} ; // 208 ...
        7'd74 :
            luma_coeff_addr  = {6'b110101      ,coeff_addr_offset_r[1:0]} ; // 212 ...
        7'd75 :
            luma_coeff_addr  = {6'b110110      ,coeff_addr_offset_r[1:0]} ; // 216 ...
        7'd76 :
            luma_coeff_addr  = {6'b110111      ,coeff_addr_offset_r[1:0]} ; // 220 ...
        7'd77 :
            luma_coeff_addr  = {6'b111000      ,coeff_addr_offset_r[1:0]} ; // 224 ...
        7'd78 :
            luma_coeff_addr  = {6'b111001      ,coeff_addr_offset_r[1:0]} ; // 228 ...
        7'd79 :
            luma_coeff_addr  = {6'b111010      ,coeff_addr_offset_r[1:0]} ; // 232 ...
        7'd80 :
            luma_coeff_addr  = {6'b111011      ,coeff_addr_offset_r[1:0]} ; // 236 ...
        7'd81 :
            luma_coeff_addr  = {6'b111100      ,coeff_addr_offset_r[1:0]} ; // 240 ...
        7'd82 :
            luma_coeff_addr  = {6'b111101      ,coeff_addr_offset_r[1:0]} ; // 244 ...
        7'd83 :
            luma_coeff_addr  = {6'b111110      ,coeff_addr_offset_r[1:0]} ; // 248 ...
        7'd84 :
            luma_coeff_addr  = {6'b111111      ,coeff_addr_offset_r[1:0]} ; // 252 ...
        default:
            luma_coeff_addr  = 8'd0                                       ; //
    endcase
end

// chroma_coeff_addr
always @*
begin
    case(cu_idx_i)
        7'd0  :
            chroma_coeff_addr = {sub_block_cnt_i,coeff_addr_offset_r[3:0]} ; //  0  ... 16 ... 32 ... 48 ...
        7'd1  :
            chroma_coeff_addr = {2'b00          ,coeff_addr_offset_r[3:0]} ; //  0  ...
        7'd2  :
            chroma_coeff_addr = {2'b01          ,coeff_addr_offset_r[3:0]} ; // 16  ...
        7'd3  :
            chroma_coeff_addr = {2'b10          ,coeff_addr_offset_r[3:0]} ; // 32  ...
        7'd4  :
            chroma_coeff_addr = {2'b11          ,coeff_addr_offset_r[3:0]} ; // 48  ...
        7'd5  :
            chroma_coeff_addr = {4'b0000        ,coeff_addr_offset_r[1:0]} ; // 0   ...
        7'd6  :
            chroma_coeff_addr = {4'b0001        ,coeff_addr_offset_r[1:0]} ; // 4   ...
        7'd7  :
            chroma_coeff_addr = {4'b0010        ,coeff_addr_offset_r[1:0]} ; // 8   ...
        7'd8  :
            chroma_coeff_addr = {4'b0011        ,coeff_addr_offset_r[1:0]} ; // 12  ...
        7'd9  :
            chroma_coeff_addr = {4'b0100        ,coeff_addr_offset_r[1:0]} ; // 16  ...
        7'd10 :
            chroma_coeff_addr = {4'b0101        ,coeff_addr_offset_r[1:0]} ; // 20  ...
        7'd11 :
            chroma_coeff_addr = {4'b0110        ,coeff_addr_offset_r[1:0]} ; // 24  ...
        7'd12 :
            chroma_coeff_addr = {4'b0111        ,coeff_addr_offset_r[1:0]} ; // 28  ...
        7'd13 :
            chroma_coeff_addr = {4'b1000        ,coeff_addr_offset_r[1:0]} ; // 32  ...
        7'd14 :
            chroma_coeff_addr = {4'b1001        ,coeff_addr_offset_r[1:0]} ; // 36  ...
        7'd15 :
            chroma_coeff_addr = {4'b1010        ,coeff_addr_offset_r[1:0]} ; // 40  ...
        7'd16 :
            chroma_coeff_addr = {4'b1011        ,coeff_addr_offset_r[1:0]} ; // 44  ...
        7'd17 :
            chroma_coeff_addr = {4'b1100        ,coeff_addr_offset_r[1:0]} ; // 48  ...
        7'd18 :
            chroma_coeff_addr = {4'b1101        ,coeff_addr_offset_r[1:0]} ; // 52  ...
        7'd19 :
            chroma_coeff_addr = {4'b1110        ,coeff_addr_offset_r[1:0]} ; // 56  ...
        7'd20 :
            chroma_coeff_addr = {4'b1111        ,coeff_addr_offset_r[1:0]} ; // 60  ...
        7'd21 :
            chroma_coeff_addr = {6'd0                                    } ; // 0   ...
        7'd22 :
            chroma_coeff_addr = {6'd1                                    } ; // 1   ...
        7'd23 :
            chroma_coeff_addr = {6'd2                                    } ; // 2   ...
        7'd24 :
            chroma_coeff_addr = {6'd3                                    } ; // 3   ...
        7'd25 :
            chroma_coeff_addr = {6'd4                                    } ; // 4   ...
        7'd26 :
            chroma_coeff_addr = {6'd5                                    } ; // 5   ...
        7'd27 :
            chroma_coeff_addr = {6'd6                                    } ; // 6   ...
        7'd28 :
            chroma_coeff_addr = {6'd7                                    } ; // 7   ...
        7'd29 :
            chroma_coeff_addr = {6'd8                                    } ; // 8   ...
        7'd30 :
            chroma_coeff_addr = {6'd9                                    } ; // 9   ...
        7'd31 :
            chroma_coeff_addr = {6'd10                                   } ; // 10  ...
        7'd32 :
            chroma_coeff_addr = {6'd11                                   } ; // 11  ...
        7'd33 :
            chroma_coeff_addr = {6'd12                                   } ; // 12  ...
        7'd34 :
            chroma_coeff_addr = {6'd13                                   } ; // 13  ...
        7'd35 :
            chroma_coeff_addr = {6'd14                                   } ; // 14  ...
        7'd36 :
            chroma_coeff_addr = {6'd15                                   } ; // 15  ...
        7'd37 :
            chroma_coeff_addr = {6'd16                                   } ; // 16  ...
        7'd38 :
            chroma_coeff_addr = {6'd17                                   } ; // 17  ...
        7'd39 :
            chroma_coeff_addr = {6'd18                                   } ; // 18  ...
        7'd40 :
            chroma_coeff_addr = {6'd19                                   } ; // 19  ...
        7'd41 :
            chroma_coeff_addr = {6'd20                                   } ; // 20  ...
        7'd42 :
            chroma_coeff_addr = {6'd21                                   } ; // 21  ...
        7'd43 :
            chroma_coeff_addr = {6'd22                                   } ; // 22  ...
        7'd44 :
            chroma_coeff_addr = {6'd23                                   } ; // 23  ...
        7'd45 :
            chroma_coeff_addr = {6'd24                                   } ; // 24  ...
        7'd46 :
            chroma_coeff_addr = {6'd25                                   } ; // 25  ...
        7'd47 :
            chroma_coeff_addr = {6'd26                                   } ; // 26  ...
        7'd48 :
            chroma_coeff_addr = {6'd27                                   } ; // 27  ...
        7'd49 :
            chroma_coeff_addr = {6'd28                                   } ; // 28  ...
        7'd50 :
            chroma_coeff_addr = {6'd29                                   } ; // 29  ...
        7'd51 :
            chroma_coeff_addr = {6'd30                                   } ; // 30  ...
        7'd52 :
            chroma_coeff_addr = {6'd31                                   } ; // 31  ...
        7'd53 :
            chroma_coeff_addr = {6'd32                                   } ; // 32  ...
        7'd54 :
            chroma_coeff_addr = {6'd33                                   } ; // 33  ...
        7'd55 :
            chroma_coeff_addr = {6'd34                                   } ; // 34  ...
        7'd56 :
            chroma_coeff_addr = {6'd35                                   } ; // 35  ...
        7'd57 :
            chroma_coeff_addr = {6'd36                                   } ; // 36  ...
        7'd58 :
            chroma_coeff_addr = {6'd37                                   } ; // 37  ...
        7'd59 :
            chroma_coeff_addr = {6'd38                                   } ; // 38  ...
        7'd60 :
            chroma_coeff_addr = {6'd39                                   } ; // 39  ...
        7'd61 :
            chroma_coeff_addr = {6'd40                                   } ; // 40  ...
        7'd62 :
            chroma_coeff_addr = {6'd41                                   } ; // 41  ...
        7'd63 :
            chroma_coeff_addr = {6'd42                                   } ; // 42  ...
        7'd64 :
            chroma_coeff_addr = {6'd43                                   } ; // 43  ...
        7'd65 :
            chroma_coeff_addr = {6'd44                                   } ; // 44  ...
        7'd66 :
            chroma_coeff_addr = {6'd45                                   } ; // 45  ...
        7'd67 :
            chroma_coeff_addr = {6'd46                                   } ; // 46  ...
        7'd68 :
            chroma_coeff_addr = {6'd47                                   } ; // 47  ...
        7'd69 :
            chroma_coeff_addr = {6'd48                                   } ; // 48  ...
        7'd70 :
            chroma_coeff_addr = {6'd49                                   } ; // 49  ...
        7'd71 :
            chroma_coeff_addr = {6'd50                                   } ; // 50  ...
        7'd72 :
            chroma_coeff_addr = {6'd51                                   } ; // 51  ...
        7'd73 :
            chroma_coeff_addr = {6'd52                                   } ; // 52  ...
        7'd74 :
            chroma_coeff_addr = {6'd53                                   } ; // 53  ...
        7'd75 :
            chroma_coeff_addr = {6'd54                                   } ; // 54  ...
        7'd76 :
            chroma_coeff_addr = {6'd55                                   } ; // 55  ...
        7'd77 :
            chroma_coeff_addr = {6'd56                                   } ; // 56  ...
        7'd78 :
            chroma_coeff_addr = {6'd57                                   } ; // 57  ...
        7'd79 :
            chroma_coeff_addr = {6'd58                                   } ; // 58  ...
        7'd80 :
            chroma_coeff_addr = {6'd59                                   } ; // 59  ...
        7'd81 :
            chroma_coeff_addr = {6'd60                                   } ; // 60  ...
        7'd82 :
            chroma_coeff_addr = {6'd61                                   } ; // 61  ...
        7'd83 :
            chroma_coeff_addr = {6'd62                                   } ; // 62  ...
        7'd84 :
            chroma_coeff_addr = {6'd63                                   } ; // 63  ...
        default:
            chroma_coeff_addr = 6'd0                                       ;
    endcase
end

// tu_4x4_enable_cnt_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tu_4x4_enable_cnt_r  <= 5'd0;
    else if(coeff_curr_state_r== COEFF_LAST_SIG_XY || coeff_curr_state_r == COEFF_IDLE)
        tu_4x4_enable_cnt_r  <= 5'd0;
    else if(coeff_4x4_done_w)
        tu_4x4_enable_cnt_r  <= 5'd0;
    else if((!(tq_ren_delay_r ||(tq_rdata_i!=0)))&&(coeff_addr_offset_r!=0))  // tq_rdata_i==0
        tu_4x4_enable_cnt_r  <= TCF4x4B;
    else
        tu_4x4_enable_cnt_r  <= tu_4x4_enable_cnt_r  +    1'd1;
end

// last_4x4_block_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        last_4x4_block_r  <=   6'd0;
    else if(coeff_curr_state_r==COEFF_IDLE)
        last_4x4_block_r  <=   6'd0;
    else if(coeff_curr_state_r== COEFF_LAST_SIG_XY&& !tq_ren_delay_r&&(tq_rdata_i!=0))
        last_4x4_block_r  <=   coeff_addr_cnt_r - 6'd1;
end

//-----------------------------------------------------------------------------------------------------------------------------
//
//            tq coeff
//
//-----------------------------------------------------------------------------------------------------------------------------

// tq_ren_o
always @*
begin
    if(coeff_curr_state_r==COEFF_IDLE)
        tq_ren_o   =   1'b1;
    else if(coeff_curr_state_r == COEFF_LAST_SIG_XY&& (last_sig_xy_cnt_r==0))
        tq_ren_o   =   1'b0;
    else if(coeff_curr_state_r == COEFF_4x4_BLOCK&&tu_4x4_enable_cnt_r==5'd0)
        tq_ren_o   =   1'b0;
    else
        tq_ren_o   =   1'b1;
end

// tq_raddr_o
always @*
begin
    if(coeff_type_i[1])                                                        // luma
        tq_raddr_o   =   luma_coeff_addr;
    else
        tq_raddr_o   =   chroma_coeff_addr;
end

// tq_ren_delay_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tq_ren_delay_r    <= 1'b0    ;
    else
        tq_ren_delay_r    <= tq_ren_o;
end

// last_sig_xy_cnt_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        last_sig_xy_cnt_r    <= 2'd0;
    else if( (coeff_curr_state_r == COEFF_LAST_SIG_XY && coeff_addr_cnt_r == tu_4x4_block_total_i)|| (last_sig_xy_cnt_r!=0) )
        last_sig_xy_cnt_r    <= last_sig_xy_cnt_r + 2'd1;
    else
        last_sig_xy_cnt_r    <= 2'd0;
end



//-----------------------------------------------------------------------------------------------------------------------------
//
//            fsm
//
//-----------------------------------------------------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        coeff_curr_state_r  <=   COEFF_IDLE         ;
    else
        coeff_curr_state_r  <=    coeff_next_state_r;
end

always @*
begin
    case(coeff_curr_state_r)
        COEFF_IDLE             :
        begin
            if(tu_coeff_start_i)
                coeff_next_state_r  =   COEFF_LAST_SIG_XY ;
            else
                coeff_next_state_r  =   COEFF_IDLE        ;
        end
        COEFF_LAST_SIG_XY:
        begin
            if(last_sig_xy_cnt_r == 2'd3 )
                coeff_next_state_r  =   COEFF_4x4_BLOCK  ;
            else
                coeff_next_state_r  =   COEFF_LAST_SIG_XY;
        end
        COEFF_4x4_BLOCK  :
        begin
            if(coeff_addr_cnt_r == 6'd0 && coeff_4x4_done_w  )
                coeff_next_state_r  =    COEFF_IDLE      ;
            else
                coeff_next_state_r  =     COEFF_4x4_BLOCK;
        end
        default:
            coeff_next_state_r = COEFF_IDLE;
    endcase
end

//-----------------------------------------------------------------------------------------------------------------------------
//
//            transfer skip
//
//-----------------------------------------------------------------------------------------------------------------------------

always @*
begin // 2:luma , 1 :chroma u ,0 : chroma v
    if(tu_depth_i!=2'd3)
        se_pair_skip_r   =  21'b0 ;
    else
    begin
        case(coeff_type_i[1])
            1'd0 :
                se_pair_skip_r  = {8'h00,4'h1,9'h0b8 } ; // chroma v , se = 1
            1'd1 :
                se_pair_skip_r  = {8'h00,4'h1,9'h0b7 } ; // luma , se = 0
        endcase
    end
end

//-----------------------------------------------------------------------------------------------------------------------------
//
//            calculation and transfer last_signifcant_xy
//
//-----------------------------------------------------------------------------------------------------------------------------
reg [ 2:0 ]  last_sig_x_32x32_r      ; // tu_4x4_enable_cnt_r = 5'd2
reg [ 2:0 ]  last_sig_y_32x32_r      ; // tu_4x4_enable_cnt_r = 5'd2

reg [255:0]  coeff_data_r            ;

reg          last_sig_x_suffix_en_0_w;
reg          last_sig_x_suffix_en_1_w;
reg          last_sig_x_suffix_en_2_w;
reg          last_sig_x_suffix_en_3_w;

reg          last_sig_y_suffix_en_0_w;
reg          last_sig_y_suffix_en_1_w;
reg          last_sig_y_suffix_en_2_w;
reg          last_sig_y_suffix_en_3_w;

reg [ 1:0 ]  last_sig_x_suffix_r     ;
reg [ 1:0 ]  last_sig_y_suffix_r     ;

reg [ 4:0 ]  last_sig_x_r            ;
reg [ 4:0 ]  last_sig_y_r            ;

// last_sig_x_32x32_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        last_sig_x_32x32_r     <=      3'd0                                    ;
    else if(coeff_curr_state_r==COEFF_LAST_SIG_XY&&(!tq_ren_delay_r)&&(tq_rdata_i!=0))
        last_sig_x_32x32_r     <=      {coeff_addr_offset_d1_r[4],coeff_addr_offset_d1_r[2],coeff_addr_offset_d1_r[0]};
    else if(coeff_curr_state_r==COEFF_4x4_BLOCK)
        last_sig_x_32x32_r     <=      {coeff_addr_offset_d1_r[4],coeff_addr_offset_d1_r[2],coeff_addr_offset_d1_r[0]};
end

// last_sig_y_32x32_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        last_sig_y_32x32_r     <=     3'd0                                     ;
    else if(coeff_curr_state_r==COEFF_LAST_SIG_XY&&(!tq_ren_delay_r)&&(tq_rdata_i!=0))
        last_sig_y_32x32_r     <=     {coeff_addr_offset_d1_r[5],coeff_addr_offset_d1_r[3],coeff_addr_offset_d1_r[1]};
    else if(coeff_curr_state_r==COEFF_4x4_BLOCK)
        last_sig_y_32x32_r     <=     {coeff_addr_offset_d1_r[5],coeff_addr_offset_d1_r[3],coeff_addr_offset_d1_r[1]};
end

// coeff_data_r
always @*
begin
    case(scan_idx_r)
        (`SCAN_DIAG):
        begin
            coeff_data_r  ={tq_rdata_i[255:240], tq_rdata_i[223:208], tq_rdata_i[239:224], tq_rdata_i[127:112] ,
                            tq_rdata_i[207:192], tq_rdata_i[191:176], tq_rdata_i[ 95: 80], tq_rdata_i[111: 96] ,
                            tq_rdata_i[159:144], tq_rdata_i[175:160], tq_rdata_i[ 79: 64], tq_rdata_i[ 63: 48] ,
                            tq_rdata_i[143:128], tq_rdata_i[ 31: 16], tq_rdata_i[ 47: 32], tq_rdata_i[ 15:  0]};
        end

        (`SCAN_HOR):
        begin
            coeff_data_r  ={tq_rdata_i[255:240], tq_rdata_i[239:224], tq_rdata_i[191:176], tq_rdata_i[175:160] ,
                            tq_rdata_i[223:208], tq_rdata_i[207:192], tq_rdata_i[159:144], tq_rdata_i[143:128] ,
                            tq_rdata_i[127:112], tq_rdata_i[111: 96], tq_rdata_i[ 63: 48], tq_rdata_i[ 47: 32] ,
                            tq_rdata_i[ 95: 80], tq_rdata_i[ 79: 64], tq_rdata_i[ 31: 16], tq_rdata_i[ 15:  0]};
        end

        (`SCAN_VER):
        begin
            coeff_data_r  ={tq_rdata_i[255:240], tq_rdata_i[223:208], tq_rdata_i[127:112], tq_rdata_i[ 95: 80] ,
                            tq_rdata_i[239:224], tq_rdata_i[207:192], tq_rdata_i[111: 96], tq_rdata_i[ 79: 64] ,
                            tq_rdata_i[191:176], tq_rdata_i[159:144], tq_rdata_i[ 63: 48], tq_rdata_i[ 31: 16] ,
                            tq_rdata_i[175:160], tq_rdata_i[143:128], tq_rdata_i[ 47: 32], tq_rdata_i[ 15:  0]};
        end

        default:
        begin
            coeff_data_r  = 256'd0;
        end
    endcase
end

always @*
begin
    case(scan_idx_r)
        `SCAN_DIAG :
        begin
            last_sig_x_suffix_en_0_w =  (coeff_data_r[159:144]!=0)||(coeff_data_r[207:192]!=0)|| (coeff_data_r[239:224]!=0)||(coeff_data_r[255:240]!=0);
            last_sig_x_suffix_en_1_w =  (coeff_data_r[ 95:80 ]!=0)||(coeff_data_r[143:128]!=0)||((coeff_data_r[191:176]!=0)&&(coeff_data_r[159:0]==0))||((coeff_data_r[223:208]!=0)&&(coeff_data_r[207:0]==0));
            last_sig_x_suffix_en_2_w =  (coeff_data_r[ 47:32 ]!=0)||(coeff_data_r[ 79:64 ]!=0)||((coeff_data_r[127:112]!=0)&&(coeff_data_r[111:0]==0))||((coeff_data_r[175:160]!=0)&&(coeff_data_r[159:0]==0));
            last_sig_x_suffix_en_3_w =  (coeff_data_r[ 15:0  ]!=0)||(coeff_data_r[ 31:16 ]!=0)||((coeff_data_r[ 63:48 ]!=0)&&(coeff_data_r[ 47:0]==0))||((coeff_data_r[111:96 ]!=0)&&(coeff_data_r[ 95:0]==0));

            last_sig_y_suffix_en_0_w =  (coeff_data_r[111:96 ]!=0)|| (coeff_data_r[175:160]!=0)||(coeff_data_r[223:208]!=0)||(coeff_data_r[255:240]!=0);
            last_sig_y_suffix_en_1_w =  (coeff_data_r[ 63:48 ]!=0)||((coeff_data_r[127:112]!=0)&&(coeff_data_r[111:0  ]==0))||((coeff_data_r[191:176]!=0)&&(coeff_data_r[175:0  ]==0))||((coeff_data_r[239:224]!=0)&&(coeff_data_r[223:0]==0));
            last_sig_y_suffix_en_2_w =  (coeff_data_r[ 31:16 ]!=0)||((coeff_data_r[ 79:64 ]!=0)&&(coeff_data_r[ 63:0  ]==0))||((coeff_data_r[143:128]!=0)&&(coeff_data_r[127:0  ]==0))||((coeff_data_r[207:192]!=0)&&(coeff_data_r[191:0]==0));
            last_sig_y_suffix_en_3_w =  (coeff_data_r[ 15:0  ]!=0)||((coeff_data_r[ 47:32 ]!=0)&&(coeff_data_r[ 31:0  ]==0))||((coeff_data_r[ 95:80 ]!=0)&&(coeff_data_r[ 79:0  ]==0))||((coeff_data_r[159:144]!=0)&&(coeff_data_r[143:0]==0));
        end
        `SCAN_VER :
        begin
            last_sig_x_suffix_en_0_w =  !(coeff_data_r[255:192]==0);
            last_sig_x_suffix_en_1_w =  !(coeff_data_r[191:128]==0);
            last_sig_x_suffix_en_2_w =  !(coeff_data_r[127:64 ]==0);
            last_sig_x_suffix_en_3_w =  !(coeff_data_r[ 63:0  ]==0);

            last_sig_y_suffix_en_0_w =  (coeff_data_r[ 63:48]!=0)|| (coeff_data_r[127:112]!=0)||(coeff_data_r[191:176]!=0) ||( coeff_data_r[255:240]!=0);
            last_sig_y_suffix_en_1_w =  (coeff_data_r[ 47:32]!=0)||((coeff_data_r[111:96 ]!=0)&&(coeff_data_r[ 95:0  ]==0))||((coeff_data_r[175:160]!=0)&&(coeff_data_r[159:0  ]==0))||((coeff_data_r[239:224]!=0)&&(coeff_data_r[223:0  ]==0));
            last_sig_y_suffix_en_2_w =  (coeff_data_r[ 31:16]!=0)||((coeff_data_r[ 95:80 ]!=0)&&(coeff_data_r[ 79:0  ]==0))||((coeff_data_r[159:144]!=0)&&(coeff_data_r[143:0  ]==0))||((coeff_data_r[223:208]!=0)&&(coeff_data_r[207:0  ]==0));
            last_sig_y_suffix_en_3_w =  (coeff_data_r[ 15:0 ]!=0)||((coeff_data_r[ 79:64 ]!=0)&&(coeff_data_r[ 63:0  ]==0))||((coeff_data_r[143:128]!=0)&&(coeff_data_r[127:0  ]==0))||((coeff_data_r[207:192]!=0)&&(coeff_data_r[191:0  ]==0));
        end
        `SCAN_HOR :
        begin
            last_sig_x_suffix_en_0_w =  (coeff_data_r[ 63:48]!=0)||( coeff_data_r[127:112]!=0)||(coeff_data_r[191:176]!=0)|| ( coeff_data_r[255:240]!=0);
            last_sig_x_suffix_en_1_w =  (coeff_data_r[ 47:32]!=0)||((coeff_data_r[111:96 ]!=0)&&(coeff_data_r[95:0   ]==0))||((coeff_data_r[175:160]!=0)&&(coeff_data_r[159:0  ]==0))||((coeff_data_r[239:224]!=0)&&(coeff_data_r[223:0  ]==0));
            last_sig_x_suffix_en_2_w =  (coeff_data_r[ 31:16]!=0)||((coeff_data_r[ 95:80 ]!=0)&&(coeff_data_r[ 79:0  ]==0))||((coeff_data_r[159:144]!=0)&&(coeff_data_r[143:0  ]==0))||((coeff_data_r[223:208]!=0)&&(coeff_data_r[207:0  ]==0));
            last_sig_x_suffix_en_3_w =  (coeff_data_r[ 15:0 ]!=0)||((coeff_data_r[ 79:64 ]!=0)&&(coeff_data_r[ 63:0  ]==0))||((coeff_data_r[143:128]!=0)&&(coeff_data_r[127:0  ]==0))||((coeff_data_r[207:192]!=0)&&(coeff_data_r[191:0  ]==0));

            last_sig_y_suffix_en_0_w =  !(coeff_data_r[255:192]==0);
            last_sig_y_suffix_en_1_w =  !(coeff_data_r[191:128]==0);
            last_sig_y_suffix_en_2_w =  !(coeff_data_r[127:64 ]==0);
            last_sig_y_suffix_en_3_w =  !(coeff_data_r[ 63:0  ]==0);
        end
        default :
        begin
            last_sig_x_suffix_en_0_w =  1'b0;
            last_sig_x_suffix_en_1_w =  1'b0;
            last_sig_x_suffix_en_2_w =  1'b0;
            last_sig_x_suffix_en_3_w =  1'b0;

            last_sig_y_suffix_en_0_w =  1'b0;
            last_sig_y_suffix_en_1_w =  1'b0;
            last_sig_y_suffix_en_2_w =  1'b0;
            last_sig_y_suffix_en_3_w =  1'b0;
        end
    endcase
end

// last_sig_x_suffix_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        last_sig_x_suffix_r <=  2'd0;
    else if(!tq_ren_delay_r&&last_sig_x_suffix_en_3_w)
        last_sig_x_suffix_r <=  2'd3;
    else if(!tq_ren_delay_r&&last_sig_x_suffix_en_2_w)
        last_sig_x_suffix_r <=  2'd2;
    else if(!tq_ren_delay_r&&last_sig_x_suffix_en_1_w)
        last_sig_x_suffix_r <=  2'd1;
    else if(!tq_ren_delay_r&&last_sig_x_suffix_en_0_w)
        last_sig_x_suffix_r <=  2'd0;
end

//last_sig_y_suffix_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        last_sig_y_suffix_r <=  2'd0;
    else if(!tq_ren_delay_r&&last_sig_y_suffix_en_3_w)
        last_sig_y_suffix_r <=  2'd3;
    else if(!tq_ren_delay_r&&last_sig_y_suffix_en_2_w)
        last_sig_y_suffix_r <=  2'd2;
    else if(!tq_ren_delay_r&&last_sig_y_suffix_en_1_w)
        last_sig_y_suffix_r <=  2'd1;
    else if(!tq_ren_delay_r&&last_sig_y_suffix_en_0_w)
        last_sig_y_suffix_r <=  2'd0;
end

// last_sig_x_r
always @*
begin
    case(tu_depth_i)
        2'd0 :
            last_sig_x_r = {     last_sig_x_32x32_r     ,last_sig_x_suffix_r}; // 32x32
        2'd1 :
            last_sig_x_r = {1'd0,last_sig_x_32x32_r[1:0],last_sig_x_suffix_r}; //16x16
        2'd2 :
            last_sig_x_r = {2'd0,last_sig_x_32x32_r[0]  ,last_sig_x_suffix_r}; // 8x8
        2'd3 :
            last_sig_x_r = {3'd0,                        last_sig_x_suffix_r}; // 4x4
    endcase
end

// last_sig_y_r
always @*
begin
    case(tu_depth_i)
        2'd0 :
            last_sig_y_r = {     last_sig_y_32x32_r     ,last_sig_y_suffix_r}; // 32x32
        2'd1 :
            last_sig_y_r = {1'd0,last_sig_y_32x32_r[1:0],last_sig_y_suffix_r}; //16x16
        2'd2 :
            last_sig_y_r = {2'd0,last_sig_y_32x32_r[0]  ,last_sig_y_suffix_r}; // 8x8
        2'd3 :
            last_sig_y_r = {3'd0,                        last_sig_y_suffix_r}; // 4x4
    endcase
end

cabac_se_prepare_coeff_last_sig_xy  cabac_se_prepare_coeff_last_sig_xy_u0
                                    (
                                        .last_sig_x_i              ( last_sig_x_r               ),
                                        .last_sig_y_i              ( last_sig_y_r               ),
                                        .tu_depth_i                ( tu_depth_i                 ),
                                        .scan_idx_i                ( scan_idx_r                 ),
                                        .etype_i                   ( coeff_type_i               ),
                                        .se_pair_last_x_prefix_0_o ( se_pair_last_x_prefix_0_w  ),
                                        .se_pair_last_x_suffix_o   ( se_pair_last_x_suffix_w    ),
                                        .se_pair_last_y_prefix_0_o ( se_pair_last_y_prefix_0_w  ),
                                        .se_pair_last_y_suffix_o   ( se_pair_last_y_suffix_w    )
                                    );

//-----------------------------------------------------------------------------------------------------------------------------
//
//            transfer coeff of a 4x4 block : sub_block_cbf
//
//-----------------------------------------------------------------------------------------------------------------------------

//  calculation cbf of 4x4 block  32x32 block has 64 cbf
wire  cbf_enable_w;

reg   cbf_4x4_0_0_r  , cbf_4x4_0_1_r , cbf_4x4_0_2_r ,cbf_4x4_0_3_r  ;
reg   cbf_4x4_0_4_r  , cbf_4x4_0_5_r , cbf_4x4_0_6_r ,cbf_4x4_0_7_r  ;
reg   cbf_4x4_1_0_r  , cbf_4x4_1_1_r , cbf_4x4_1_2_r ,cbf_4x4_1_3_r  ;
reg   cbf_4x4_1_4_r  , cbf_4x4_1_5_r , cbf_4x4_1_6_r ,cbf_4x4_1_7_r  ;
reg   cbf_4x4_2_0_r  , cbf_4x4_2_1_r , cbf_4x4_2_2_r ,cbf_4x4_2_3_r  ;
reg   cbf_4x4_2_4_r  , cbf_4x4_2_5_r , cbf_4x4_2_6_r ,cbf_4x4_2_7_r  ;
reg   cbf_4x4_3_0_r  , cbf_4x4_3_1_r , cbf_4x4_3_2_r ,cbf_4x4_3_3_r  ;
reg   cbf_4x4_3_4_r  , cbf_4x4_3_5_r , cbf_4x4_3_6_r ,cbf_4x4_3_7_r  ;
reg   cbf_4x4_4_0_r  , cbf_4x4_4_1_r , cbf_4x4_4_2_r ,cbf_4x4_4_3_r  ;
reg   cbf_4x4_4_4_r  , cbf_4x4_4_5_r , cbf_4x4_4_6_r ,cbf_4x4_4_7_r  ;
reg   cbf_4x4_5_0_r  , cbf_4x4_5_1_r , cbf_4x4_5_2_r ,cbf_4x4_5_3_r  ;
reg   cbf_4x4_5_4_r  , cbf_4x4_5_5_r , cbf_4x4_5_6_r ,cbf_4x4_5_7_r  ;
reg   cbf_4x4_6_0_r  , cbf_4x4_6_1_r , cbf_4x4_6_2_r ,cbf_4x4_6_3_r  ;
reg   cbf_4x4_6_4_r  , cbf_4x4_6_5_r , cbf_4x4_6_6_r ,cbf_4x4_6_7_r  ;
reg   cbf_4x4_7_0_r  , cbf_4x4_7_1_r , cbf_4x4_7_2_r ,cbf_4x4_7_3_r  ;
reg   cbf_4x4_7_4_r  , cbf_4x4_7_5_r , cbf_4x4_7_6_r ,cbf_4x4_7_7_r  ;

reg   cbf_right_r    , cbf_low_r     ,csbf_enable_r;
wire  cbf_curr_w ;
reg   [8:0] ctxIdx_csbf_r ;

assign          cbf_enable_w  = ( (!tq_ren_delay_r)&& coeff_curr_state_r== COEFF_LAST_SIG_XY);

// cbf_4x4_0_0_r: coeff_addr_offset_d1_r[5:0] == 6'd0  always = 1
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_0_0_r   <=  1'b0;
    else if( cbf_enable_w&&coeff_addr_offset_d1_r == 6'd0)
        cbf_4x4_0_0_r   <=   !(tq_rdata_i==0);
    else
        cbf_4x4_0_0_r   <=   cbf_4x4_0_0_r;
end

// cbf_4x4_0_1_r: coeff_addr_offset_d1_r == 6'd1
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_0_1_r   <=  1'b0;
    else if( tu_depth_i==2'd3) // 4x4
        cbf_4x4_0_1_r   <=  1'b0;
    else if( cbf_enable_w && (coeff_addr_offset_d1_r == 6'd1) )
        cbf_4x4_0_1_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_0_1_r   <=  cbf_4x4_0_1_r;
end

// cbf_4x4_1_0_r: coeff_addr_offset_d1_r == 6'd2
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_1_0_r  <=  1'b0;
    else if( tu_depth_i==2'd3)
        cbf_4x4_1_0_r  <=   1'b0;
    else if( cbf_enable_w && (coeff_addr_offset_d1_r == 6'd2) )
        cbf_4x4_1_0_r  <=   !(tq_rdata_i==0) ;
    else
        cbf_4x4_1_0_r  <=   cbf_4x4_1_0_r;
end

// cbf_4x4_1_1_r: coeff_addr_offset_d1_r == 6'd3
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_1_1_r  <=  1'b0;
    else if(cbf_enable_w&&coeff_addr_offset_d1_r == 6'd3)
        cbf_4x4_1_1_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_1_1_r  <=   cbf_4x4_1_1_r;
end

// cbf_4x4_0_2_r: coeff_addr_offset_d1_r == 6'd4
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_0_2_r  <=  1'b0;
    else if(tu_depth_i == 2'd2)  // 8x8
        cbf_4x4_0_2_r  <=   1'b0;
    else if(cbf_enable_w&&coeff_addr_offset_d1_r == 6'd4)
        cbf_4x4_0_2_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_0_2_r  <=   cbf_4x4_0_2_r;
end

// cbf_4x4_0_3_r: coeff_addr_offset_d1_r == 6'd5
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_0_3_r  <=  1'b0;
    else if(cbf_enable_w&&coeff_addr_offset_d1_r == 6'd5)
        cbf_4x4_0_3_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_0_3_r  <=   cbf_4x4_0_3_r;
end

// cbf_4x4_1_2_r: coeff_addr_offset_d1_r == 6'd6
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_1_2_r  <=  1'b0;
    else if(tu_depth_i==2'd2) //8x8
        cbf_4x4_1_2_r  <=   1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd6 )
        cbf_4x4_1_2_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_1_2_r  <=   cbf_4x4_1_2_r;
end

// cbf_4x4_1_3_r: coeff_addr_offset_d1_r == 6'd7
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_1_3_r  <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd7 )
        cbf_4x4_1_3_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_1_3_r  <=   cbf_4x4_1_3_r;
end

// cbf_4x4_2_0_r: coeff_addr_offset_d1_r == 6'd8
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_2_0_r  <=  1'b0;
    else if(tu_depth_i == 2'd2)
        cbf_4x4_2_0_r  <=   1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd8 )
        cbf_4x4_2_0_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_2_0_r  <=   cbf_4x4_2_0_r;
end

// cbf_4x4_2_1_r: coeff_addr_offset_d1_r == 6'd9
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_2_1_r  <=  1'b0;
    else if(tu_depth_i == 2'd2)
        cbf_4x4_2_1_r  <=   1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd9 )
        cbf_4x4_2_1_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_2_1_r  <=   cbf_4x4_2_1_r;
end

// cbf_4x4_3_0_r: coeff_addr_offset_d1_r == 6'd10
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_3_0_r  <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd10 )
        cbf_4x4_3_0_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_3_0_r  <=   cbf_4x4_3_0_r;
end

// cbf_4x4_3_1_r: coeff_addr_offset_d1_r == 6'd11
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_3_1_r  <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd11 )
        cbf_4x4_3_1_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_3_1_r  <=   cbf_4x4_3_1_r;
end

// cbf_4x4_2_2_r: coeff_addr_offset_d1_r == 6'd12
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_2_2_r  <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd12 )
        cbf_4x4_2_2_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_2_2_r  <=   cbf_4x4_2_2_r;
end

// cbf_4x4_2_3_r: coeff_addr_offset_d1_r == 6'd13
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_2_3_r  <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd13 )
        cbf_4x4_2_3_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_2_3_r  <=   cbf_4x4_2_3_r;
end

// cbf_4x4_3_2_r: coeff_addr_offset_d1_r == 6'd14
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_3_2_r  <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd14 )
        cbf_4x4_3_2_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_3_2_r  <=   cbf_4x4_3_2_r;
end

// cbf_4x4_3_3_r: coeff_addr_offset_d1_r == 6'd15
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_3_3_r  <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd15 )
        cbf_4x4_3_3_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_3_3_r  <=   cbf_4x4_3_3_r;
end

// cbf_4x4_0_4_r: coeff_addr_offset_d1_r == 6'd16
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_0_4_r  <=  1'b0;
    else if(tu_depth_i == 2'd1 ) // 16x16
        cbf_4x4_0_4_r  <=   1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd16 )
        cbf_4x4_0_4_r  <=   !(tq_rdata_i==0);
    else
        cbf_4x4_0_4_r  <=   cbf_4x4_0_4_r;
end

// cbf_4x4_0_5_r: coeff_addr_offset_d1_r == 6'd17
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_0_5_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd17 )
        cbf_4x4_0_5_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_0_5_r   <=  cbf_4x4_0_5_r;
end

// cbf_4x4_1_4_r: coeff_addr_offset_d1_r == 6'd18
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_1_4_r   <=  1'b0;
    else if(tu_depth_i == 2'd1)
        cbf_4x4_1_4_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd18 )
        cbf_4x4_1_4_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_1_4_r   <=  cbf_4x4_1_4_r;
end

// cbf_4x4_1_5_r: coeff_addr_offset_d1_r == 6'd19
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_1_5_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd19 )
        cbf_4x4_1_5_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_1_5_r   <=  cbf_4x4_1_5_r;
end

// cbf_4x4_0_6_r: coeff_addr_offset_d1_r == 6'd20
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_0_6_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd20 )
        cbf_4x4_0_6_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_0_6_r   <=  cbf_4x4_0_6_r;
end

// cbf_4x4_0_7_r: coeff_addr_offset_d1_r == 6'd21
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_0_7_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd21 )
        cbf_4x4_0_7_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_0_7_r   <=  cbf_4x4_0_7_r;
end

// cbf_4x4_1_6_r: coeff_addr_offset_d1_r == 6'd22
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_1_6_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd22 )
        cbf_4x4_1_6_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_1_6_r   <=  cbf_4x4_1_6_r;
end

// cbf_4x4_1_7_r: coeff_addr_offset_d1_r == 6'd23
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_1_7_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd23 )
        cbf_4x4_1_7_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_1_7_r   <=  cbf_4x4_1_7_r;
end

// cbf_4x4_2_4_r: coeff_addr_offset_d1_r == 6'd24
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_2_4_r   <=  1'b0;
    else if(tu_depth_i == 2'd1)
        cbf_4x4_2_4_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd24 )
        cbf_4x4_2_4_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_2_4_r   <=  cbf_4x4_2_4_r;
end

// cbf_4x4_2_5_r: coeff_addr_offset_d1_r == 6'd25
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_2_5_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd25 )
        cbf_4x4_2_5_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_2_5_r   <=  cbf_4x4_2_5_r;
end

// cbf_4x4_3_4_r: coeff_addr_offset_d1_r == 6'd26
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_3_4_r   <=  1'b0;
    else if(tu_depth_i == 2'd1)
        cbf_4x4_3_4_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd26 )
        cbf_4x4_3_4_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_3_4_r   <=  cbf_4x4_3_4_r;
end

// cbf_4x4_3_5_r: coeff_addr_offset_d1_r == 6'd27
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_3_5_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd27 )
        cbf_4x4_3_5_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_3_5_r   <=  cbf_4x4_3_5_r;
end

// cbf_4x4_2_6_r: coeff_addr_offset_d1_r == 6'd28
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_2_6_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd28 )
        cbf_4x4_2_6_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_2_6_r   <=  cbf_4x4_2_6_r;
end

// cbf_4x4_2_7_r: coeff_addr_offset_d1_r == 6'd29
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_2_7_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd29 )
        cbf_4x4_2_7_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_2_7_r   <=  cbf_4x4_2_7_r;
end

// cbf_4x4_3_6_r: coeff_addr_offset_d1_r == 6'd30
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_3_6_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd30 )
        cbf_4x4_3_6_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_3_6_r   <=  cbf_4x4_3_6_r;
end

// cbf_4x4_3_7_r: coeff_addr_offset_d1_r == 6'd31
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_3_7_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd31 )
        cbf_4x4_3_7_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_3_7_r   <=  cbf_4x4_3_7_r;
end

// cbf_4x4_4_0_r: coeff_addr_offset_d1_r == 6'd32
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_4_0_r   <=  1'b0;
    else if(tu_depth_i==2'd1) //16x16
        cbf_4x4_4_0_r   <=  1'b0;
    else if(cbf_enable_w&&coeff_addr_offset_d1_r == 6'd32)
        cbf_4x4_4_0_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_4_0_r   <=  cbf_4x4_4_0_r;
end

// cbf_4x4_4_1_r: coeff_addr_offset_d1_r == 6'd33
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_4_1_r   <=  1'b0;
    else if(tu_depth_i == 2'd1)
        cbf_4x4_4_1_r   <=  1'b0;
    else if(cbf_enable_w&&coeff_addr_offset_d1_r == 6'd33)
        cbf_4x4_4_1_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_4_1_r   <=  cbf_4x4_4_1_r;
end

// cbf_4x4_5_0_r: coeff_addr_offset_d1_r == 6'd34
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_5_0_r   <=  1'b0;
    else if(cbf_enable_w&&coeff_addr_offset_d1_r == 6'd34)
        cbf_4x4_5_0_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_5_0_r   <=  cbf_4x4_5_0_r;
end

// cbf_4x4_5_1_r: coeff_addr_offset_d1_r == 6'd35
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_5_1_r   <=  1'b0;
    else if(cbf_enable_w&&coeff_addr_offset_d1_r == 6'd35)
        cbf_4x4_5_1_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_5_1_r   <=  cbf_4x4_5_1_r;
end

// cbf_4x4_4_2_r: coeff_addr_offset_d1_r == 6'd36
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_4_2_r   <=  1'b0;
    else if(tu_depth_i == 2'd1)
        cbf_4x4_4_2_r   <=  1'b0;
    else if(cbf_enable_w&&coeff_addr_offset_d1_r == 6'd36)
        cbf_4x4_4_2_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_4_2_r   <=  cbf_4x4_4_2_r;
end

// cbf_4x4_4_3_r: coeff_addr_offset_d1_r == 6'd37
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_4_3_r   <=  1'b0;
    else if(tu_depth_i == 2'd1)
        cbf_4x4_4_3_r   <=  1'b0;
    else if(cbf_enable_w&&coeff_addr_offset_d1_r == 6'd37)
        cbf_4x4_4_3_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_4_3_r   <=  cbf_4x4_4_3_r;
end

// cbf_4x4_5_2_r: coeff_addr_offset_d1_r == 6'd38
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_5_2_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd38 )
        cbf_4x4_5_2_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_5_2_r   <=  cbf_4x4_5_2_r;
end

// cbf_4x4_5_3_r: coeff_addr_offset_d1_r == 6'd39
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_5_3_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd39 )
        cbf_4x4_5_3_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_5_3_r   <=  cbf_4x4_5_3_r ;
end

// cbf_4x4_6_0_r: coeff_addr_offset_d1_r == 6'd40
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_6_0_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd40 )
        cbf_4x4_6_0_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_6_0_r   <=  cbf_4x4_6_0_r;
end

// cbf_4x4_6_1_r: coeff_addr_offset_d1_r == 6'd41
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_6_1_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd41 )
        cbf_4x4_6_1_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_6_1_r   <=  cbf_4x4_6_1_r;
end

// cbf_4x4_7_0_r: coeff_addr_offset_d1_r == 6'd42
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_7_0_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd42 )
        cbf_4x4_7_0_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_7_0_r   <=  cbf_4x4_7_0_r;
end

// cbf_4x4_7_1_r: coeff_addr_offset_d1_r == 6'd43
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_7_1_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd43 )
        cbf_4x4_7_1_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_7_1_r   <=  cbf_4x4_7_1_r;
end

// cbf_4x4_6_2_r: coeff_addr_offset_d1_r == 6'd44
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_6_2_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd44 )
        cbf_4x4_6_2_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_6_2_r   <=  cbf_4x4_6_2_r;
end

// cbf_4x4_6_3_r: coeff_addr_offset_d1_r == 6'd45
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_6_3_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd45 )
        cbf_4x4_6_3_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_6_3_r   <=  cbf_4x4_6_3_r;
end

// cbf_4x4_7_2_r: coeff_addr_offset_d1_r == 6'd46
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_7_2_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd46 )
        cbf_4x4_7_2_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_7_2_r   <=  cbf_4x4_7_2_r;
end

// cbf_4x4_7_3_r: coeff_addr_offset_d1_r == 6'd47
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_7_3_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd47 )
        cbf_4x4_7_3_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_7_3_r   <=  cbf_4x4_7_3_r;
end

// cbf_4x4_4_4_r: coeff_addr_offset_d1_r == 6'd48
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_4_4_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd48 )
        cbf_4x4_4_4_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_4_4_r   <=  cbf_4x4_4_4_r;
end

// cbf_4x4_4_5_r: coeff_addr_offset_d1_r == 6'd49
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_4_5_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd49 )
        cbf_4x4_4_5_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_4_5_r   <=  cbf_4x4_4_5_r ;
end

// cbf_4x4_5_4_r: coeff_addr_offset_d1_r == 6'd50
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_5_4_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd50 )
        cbf_4x4_5_4_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_5_4_r   <=  cbf_4x4_5_4_r;
end

// cbf_4x4_5_5_r: coeff_addr_offset_d1_r == 6'd51
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_5_5_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd51 )
        cbf_4x4_5_5_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_5_5_r   <=  cbf_4x4_5_5_r;
end

// cbf_4x4_4_6_r: coeff_addr_offset_d1_r == 6'd52
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_4_6_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd52 )
        cbf_4x4_4_6_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_4_6_r   <=  cbf_4x4_4_6_r;
end

// cbf_4x4_4_7_r: coeff_addr_offset_d1_r == 6'd53
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_4_7_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd53 )
        cbf_4x4_4_7_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_4_7_r   <=  cbf_4x4_4_7_r;
end

// cbf_4x4_5_6_r: coeff_addr_offset_d1_r == 6'd54
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_5_6_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd54 )
        cbf_4x4_5_6_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_5_6_r   <=  cbf_4x4_5_6_r;
end

// cbf_4x4_5_7_r: coeff_addr_offset_d1_r == 6'd55
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_5_7_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd55 )
        cbf_4x4_5_7_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_5_7_r   <=  cbf_4x4_5_7_r;
end

// cbf_4x4_6_4_r: coeff_addr_offset_d1_r == 6'd56
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_6_4_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd56 )
        cbf_4x4_6_4_r   <=  !(tq_rdata_i==0) ;
    else
        cbf_4x4_6_4_r   <=  cbf_4x4_6_4_r;
end

// cbf_4x4_6_5_r: coeff_addr_offset_d1_r == 6'd57
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_6_5_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd57 )
        cbf_4x4_6_5_r   <=  !(tq_rdata_i==0) ;
    else
        cbf_4x4_6_5_r   <=  cbf_4x4_6_5_r;
end

// cbf_4x4_7_4_r: coeff_addr_offset_d1_r == 6'd58
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_7_4_r   <=  1'b0 ;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd58 )
        cbf_4x4_7_4_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_7_4_r   <=  cbf_4x4_7_4_r;
end

// cbf_4x4_7_5_r: coeff_addr_offset_d1_r == 6'd59
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_7_5_r   <=  1'b0 ;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd59 )
        cbf_4x4_7_5_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_7_5_r   <=  cbf_4x4_7_5_r;
end

// cbf_4x4_6_6_r: coeff_addr_offset_d1_r == 6'd60
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_6_6_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd60 )
        cbf_4x4_6_6_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_6_6_r   <=  cbf_4x4_6_6_r;
end

// cbf_4x4_6_7_r: coeff_addr_offset_d1_r == 6'd61
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_6_7_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd61 )
        cbf_4x4_6_7_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_6_7_r   <=  cbf_4x4_6_7_r;
end

// cbf_4x4_7_6_r: coeff_addr_offset_d1_r == 6'd62
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_7_6_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd62 )
        cbf_4x4_7_6_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_7_6_r   <=  cbf_4x4_7_6_r;
end

// cbf_4x4_7_7_r: coeff_addr_offset_d1_r == 6'd63
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_4x4_7_7_r   <=  1'b0;
    else if(cbf_enable_w&& coeff_addr_offset_d1_r == 6'd63 )
        cbf_4x4_7_7_r   <=  !(tq_rdata_i==0);
    else
        cbf_4x4_7_7_r   <=  cbf_4x4_7_7_r;
end


// cbf_right_r cbf_low_r
always @*
begin
    case(coeff_addr_offset_r)
        6'd0  :
        begin
            cbf_right_r = cbf_4x4_0_1_r;
            cbf_low_r = cbf_4x4_1_0_r ;
        end
        6'd1  :
        begin
            cbf_right_r = cbf_4x4_0_2_r;
            cbf_low_r = cbf_4x4_1_1_r ;
        end
        6'd2  :
        begin
            cbf_right_r = cbf_4x4_1_1_r;
            cbf_low_r = cbf_4x4_2_0_r ;
        end
        6'd3  :
        begin
            cbf_right_r = cbf_4x4_1_2_r;
            cbf_low_r = cbf_4x4_2_1_r ;
        end
        6'd4  :
        begin
            cbf_right_r = cbf_4x4_0_3_r;
            cbf_low_r = cbf_4x4_1_2_r ;
        end
        6'd5  :
        begin
            cbf_right_r = cbf_4x4_0_4_r;
            cbf_low_r = cbf_4x4_1_3_r ;
        end
        6'd6  :
        begin
            cbf_right_r = cbf_4x4_1_3_r;
            cbf_low_r = cbf_4x4_2_2_r ;
        end
        6'd7  :
        begin
            cbf_right_r = cbf_4x4_1_4_r;
            cbf_low_r = cbf_4x4_2_3_r ;
        end
        6'd8  :
        begin
            cbf_right_r = cbf_4x4_2_1_r;
            cbf_low_r = cbf_4x4_3_0_r ;
        end
        6'd9  :
        begin
            cbf_right_r = cbf_4x4_2_2_r;
            cbf_low_r = cbf_4x4_3_1_r ;
        end
        6'd10 :
        begin
            cbf_right_r = cbf_4x4_3_1_r;
            cbf_low_r = cbf_4x4_4_0_r ;
        end
        6'd11 :
        begin
            cbf_right_r = cbf_4x4_3_2_r;
            cbf_low_r = cbf_4x4_4_1_r ;
        end
        6'd12 :
        begin
            cbf_right_r = cbf_4x4_2_3_r;
            cbf_low_r = cbf_4x4_3_2_r ;
        end
        6'd13 :
        begin
            cbf_right_r = cbf_4x4_2_4_r;
            cbf_low_r = cbf_4x4_3_3_r ;
        end
        6'd14 :
        begin
            cbf_right_r = cbf_4x4_3_3_r;
            cbf_low_r = cbf_4x4_4_2_r ;
        end
        6'd15 :
        begin
            cbf_right_r = cbf_4x4_3_4_r;
            cbf_low_r = cbf_4x4_4_3_r ;
        end
        6'd16 :
        begin
            cbf_right_r = cbf_4x4_0_5_r;
            cbf_low_r = cbf_4x4_1_4_r ;
        end
        6'd17 :
        begin
            cbf_right_r = cbf_4x4_0_6_r;
            cbf_low_r = cbf_4x4_1_5_r ;
        end
        6'd18 :
        begin
            cbf_right_r = cbf_4x4_1_5_r;
            cbf_low_r = cbf_4x4_2_4_r ;
        end
        6'd19 :
        begin
            cbf_right_r = cbf_4x4_1_6_r;
            cbf_low_r = cbf_4x4_2_5_r ;
        end
        6'd20 :
        begin
            cbf_right_r = cbf_4x4_0_7_r;
            cbf_low_r = cbf_4x4_1_6_r ;
        end
        6'd21 :
        begin
            cbf_right_r = 1'b0         ;
            cbf_low_r = cbf_4x4_1_7_r ;
        end
        6'd22 :
        begin
            cbf_right_r = cbf_4x4_1_7_r;
            cbf_low_r = cbf_4x4_2_6_r ;
        end
        6'd23 :
        begin
            cbf_right_r = 1'b0         ;
            cbf_low_r = cbf_4x4_2_7_r ;
        end
        6'd24 :
        begin
            cbf_right_r = cbf_4x4_2_5_r;
            cbf_low_r = cbf_4x4_3_4_r ;
        end
        6'd25 :
        begin
            cbf_right_r = cbf_4x4_2_6_r;
            cbf_low_r = cbf_4x4_3_5_r ;
        end
        6'd26 :
        begin
            cbf_right_r = cbf_4x4_3_5_r;
            cbf_low_r = cbf_4x4_4_4_r ;
        end
        6'd27 :
        begin
            cbf_right_r = cbf_4x4_3_6_r;
            cbf_low_r = cbf_4x4_4_5_r ;
        end
        6'd28 :
        begin
            cbf_right_r = cbf_4x4_2_7_r;
            cbf_low_r = cbf_4x4_3_6_r ;
        end
        6'd29 :
        begin
            cbf_right_r = 1'b0         ;
            cbf_low_r = cbf_4x4_3_7_r ;
        end
        6'd30 :
        begin
            cbf_right_r = cbf_4x4_3_7_r;
            cbf_low_r = cbf_4x4_4_6_r ;
        end
        6'd31 :
        begin
            cbf_right_r = 1'b0         ;
            cbf_low_r = cbf_4x4_4_7_r ;
        end
        6'd32 :
        begin
            cbf_right_r = cbf_4x4_4_1_r;
            cbf_low_r = cbf_4x4_5_0_r ;
        end
        6'd33 :
        begin
            cbf_right_r = cbf_4x4_4_2_r;
            cbf_low_r = cbf_4x4_5_1_r ;
        end
        6'd34 :
        begin
            cbf_right_r = cbf_4x4_5_1_r;
            cbf_low_r = cbf_4x4_6_0_r ;
        end
        6'd35 :
        begin
            cbf_right_r = cbf_4x4_5_2_r;
            cbf_low_r = cbf_4x4_6_1_r ;
        end
        6'd36 :
        begin
            cbf_right_r = cbf_4x4_4_3_r;
            cbf_low_r = cbf_4x4_5_2_r ;
        end
        6'd37 :
        begin
            cbf_right_r = cbf_4x4_4_4_r;
            cbf_low_r = cbf_4x4_5_3_r ;
        end
        6'd38 :
        begin
            cbf_right_r = cbf_4x4_5_3_r;
            cbf_low_r = cbf_4x4_6_2_r ;
        end
        6'd39 :
        begin
            cbf_right_r = cbf_4x4_5_4_r;
            cbf_low_r = cbf_4x4_6_3_r ;
        end
        6'd40 :
        begin
            cbf_right_r = cbf_4x4_6_1_r;
            cbf_low_r = cbf_4x4_7_0_r ;
        end
        6'd41 :
        begin
            cbf_right_r = cbf_4x4_6_2_r;
            cbf_low_r = cbf_4x4_7_1_r ;
        end
        6'd42 :
        begin
            cbf_right_r = cbf_4x4_7_1_r;
            cbf_low_r = 1'b0          ;
        end
        6'd43 :
        begin
            cbf_right_r = cbf_4x4_7_2_r;
            cbf_low_r = 1'b0          ;
        end
        6'd44 :
        begin
            cbf_right_r = cbf_4x4_6_3_r;
            cbf_low_r = cbf_4x4_7_2_r ;
        end
        6'd45 :
        begin
            cbf_right_r = cbf_4x4_6_4_r;
            cbf_low_r = cbf_4x4_7_3_r ;
        end
        6'd46 :
        begin
            cbf_right_r = cbf_4x4_7_3_r;
            cbf_low_r = 1'b0          ;
        end
        6'd47 :
        begin
            cbf_right_r = cbf_4x4_7_4_r;
            cbf_low_r = 1'b0          ;
        end
        6'd48 :
        begin
            cbf_right_r = cbf_4x4_4_5_r;
            cbf_low_r = cbf_4x4_5_4_r ;
        end
        6'd49 :
        begin
            cbf_right_r = cbf_4x4_4_6_r;
            cbf_low_r = cbf_4x4_5_5_r ;
        end
        6'd50 :
        begin
            cbf_right_r = cbf_4x4_5_5_r;
            cbf_low_r = cbf_4x4_6_4_r ;
        end
        6'd51 :
        begin
            cbf_right_r = cbf_4x4_5_6_r;
            cbf_low_r = cbf_4x4_6_5_r ;
        end
        6'd52 :
        begin
            cbf_right_r = cbf_4x4_4_7_r;
            cbf_low_r = cbf_4x4_5_6_r ;
        end
        6'd53 :
        begin
            cbf_right_r = 1'b0         ;
            cbf_low_r = cbf_4x4_5_7_r ;
        end
        6'd54 :
        begin
            cbf_right_r = cbf_4x4_5_7_r;
            cbf_low_r = cbf_4x4_6_6_r ;
        end
        6'd55 :
        begin
            cbf_right_r = 1'b0         ;
            cbf_low_r = cbf_4x4_6_7_r ;
        end
        6'd56 :
        begin
            cbf_right_r = cbf_4x4_6_5_r;
            cbf_low_r = cbf_4x4_7_4_r ;
        end
        6'd57 :
        begin
            cbf_right_r = cbf_4x4_6_6_r;
            cbf_low_r = cbf_4x4_7_5_r ;
        end
        6'd58 :
        begin
            cbf_right_r = cbf_4x4_7_5_r;
            cbf_low_r = 1'b0          ;
        end
        6'd59 :
        begin
            cbf_right_r = cbf_4x4_7_6_r;
            cbf_low_r = 1'b0          ;
        end
        6'd60 :
        begin
            cbf_right_r = cbf_4x4_6_7_r;
            cbf_low_r = cbf_4x4_7_6_r ;
        end
        6'd61 :
        begin
            cbf_right_r = 1'b0         ;
            cbf_low_r = cbf_4x4_7_7_r ;
        end
        6'd62 :
        begin
            cbf_right_r = cbf_4x4_7_7_r;
            cbf_low_r = 1'b0          ;
        end
        6'd63 :
        begin
            cbf_right_r = 1'b0         ;
            cbf_low_r = 1'b0          ;
        end
    endcase
end

// cbf_curr_w
assign  cbf_curr_w     =   !( tq_rdata_i==0 );

// csbf_enable_r
always @*
begin
    if ( (coeff_addr_cnt_r[5:0] != last_4x4_block_r) && (coeff_addr_cnt_r[5:0]!=0) )
        csbf_enable_r    =    1'b1;
    else
        csbf_enable_r    =    1'b0;
end

// ctxIdx_csbf_r
wire        ui_se_csbf_w  =  cbf_right_r || cbf_low_r ;

always @*
begin
    case( {coeff_type_i[1],ui_se_csbf_w} )
        2'd0 :
            ctxIdx_csbf_r = 9'h02a; // chroma 2 + 0 =  2
        2'd1 :
            ctxIdx_csbf_r = 9'h02b; // chroma 2 + 1 =  3
        2'd2 :
            ctxIdx_csbf_r = 9'h028; // luma   0 + 0 =  0
        2'd3 :
            ctxIdx_csbf_r = 9'h029; // luma   0 + 1 =  1
    endcase
end

// se_pair_csbf_r
always @*
begin
    if( csbf_enable_r )
        se_pair_csbf_r  =  {7'h00, cbf_curr_w,4'h1, ctxIdx_csbf_r };
    else
        se_pair_csbf_r  =  21'b0;
end

//-----------------------------------------------------------------------------------------------------------------------------
//
//            transfer coeff of a 4x4 block : sig_coeff_flag , coeff_gt1_flag ,coeff_gt2_flag
//
//-----------------------------------------------------------------------------------------------------------------------------
wire  [22:0 ] se_pair_coeff_0_w     ;
wire  [22:0 ] se_pair_coeff_1_w     ;
wire  [20:0 ] se_pair_coeff_2_w     ;
wire  [20:0 ] se_pair_coeff_3_w     ;

wire          last_4x4_block_flag_w ;
wire          first_4x4_block_flag_w;
reg   [ 1:0 ] pattern_sig_ctx_r     ;
wire  [ 1:0 ] c1_inner_o_w          ;
reg   [ 2:0 ] pos_prefix_x_r        ;
reg   [ 2:0 ] pos_prefix_y_r        ;
reg   [ 1:0 ] c1_outer_r            ;

// last_4x4_block_flag_w  first_4x4_block_flag_w
assign    last_4x4_block_flag_w =  coeff_addr_cnt_r[5:0] == last_4x4_block_r;
assign    first_4x4_block_flag_w=  coeff_addr_cnt_r[5:0] == 6'd0            ;

// pattern_sig_ctx_r
always @*
begin
    if(tu_depth_i==2'd3)
        pattern_sig_ctx_r   =   2'd3;
    else
        pattern_sig_ctx_r   =   cbf_right_r + ( cbf_low_r<<1 );
end


// pos_prefix_x_r pos_prefix_y_r
always @*
begin
    case(tu_depth_i)
        2'd0 :
        begin
            pos_prefix_x_r=last_sig_x_32x32_r     ;
            pos_prefix_y_r=last_sig_y_32x32_r     ;
        end
        2'd1 :
        begin
            pos_prefix_x_r=last_sig_x_32x32_r[1:0];
            pos_prefix_y_r=last_sig_y_32x32_r[1:0];
        end
        2'd2 :
        begin
            pos_prefix_x_r=last_sig_x_32x32_r[0]  ;
            pos_prefix_y_r=last_sig_y_32x32_r[0]  ;
        end
        2'd3 :
        begin
            pos_prefix_x_r=3'd0                   ;
            pos_prefix_y_r=3'd0                   ;
        end
    endcase
end

// c1_outer_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        c1_outer_r     <=       2'd1;
    else if(coeff_curr_state_r==COEFF_4x4_BLOCK&& !tq_ren_delay_r&&coeff_addr_cnt_r[5:0]==last_4x4_block_r)
        c1_outer_r     <=       2'd1;
    else if(coeff_4x4_done_w )
        c1_outer_r     <=       c1_inner_o_w ;
end

cabac_se_prepare_amplitude_of_coeff  cabac_se_prepare_amplitude_of_coeff_u0(
                                         .clk                   ( clk                    ),
                                         .rst_n                 ( rst_n                  ),
                                         .last_4x4_block_flag_i ( last_4x4_block_flag_w  ),
                                         .first_4x4_block_flag_i( first_4x4_block_flag_w ),
                                         .pattern_sig_ctx_i     ( pattern_sig_ctx_r      ),
                                         .coeff_type_i          ( coeff_type_i           ),
                                         .cu_slice_type_i       ( cu_slice_type_i        ),
                                         .coeff_data_vaid_i     ( tq_ren_delay_r         ),
                                         .coeff_data_i          ( coeff_data_r           ),
                                         .tu_depth_i            ( tu_depth_i             ),
                                         .scan_idx_i            ( scan_idx_r             ),
                                         .pos_prefix_x_i        ( pos_prefix_x_r         ),
                                         .pos_prefix_y_i        ( pos_prefix_y_r         ),
                                         .c1_inner_i            ( c1_outer_r             ),
                                         .coeff_cnt_i           ( tu_4x4_enable_cnt_r    ),

                                         .se_pair_coeff_0_o     ( se_pair_coeff_0_w      ),
                                         .se_pair_coeff_1_o     ( se_pair_coeff_1_w      ),
                                         .se_pair_coeff_2_o     ( se_pair_coeff_2_w      ),
                                         .se_pair_coeff_3_o     ( se_pair_coeff_3_w      ),
                                         .c1_inner_o            ( c1_inner_o_w           ),
                                         .coeff_4x4_done_o      ( coeff_4x4_done_w       )
                                     );


//-----------------------------------------------------------------------------------------------------------------------------
//
//            output signals
//
//-----------------------------------------------------------------------------------------------------------------------------

// tu_coeff_done_o
always @*
begin
    if( coeff_curr_state_r == COEFF_4x4_BLOCK && coeff_next_state_r == COEFF_IDLE)
        tu_coeff_done_o   =    1'b1                                            ;
    else
        tu_coeff_done_o   =    1'b0                                            ;
end

always @*
begin
    case(coeff_curr_state_r)
        COEFF_LAST_SIG_XY :
        begin
            case(last_sig_xy_cnt_r)
                2'd1  :
                begin
                    //se_pair_nxn_coeff_0_o   = se_pair_skip_r             ;
                    se_pair_nxn_coeff_0_o   = 23'b0             ;
                    se_pair_nxn_coeff_1_o   = 23'b0          ;
                    se_pair_nxn_coeff_2_o   = 21'b0          ;
                    se_pair_nxn_coeff_3_o   = 21'b0          ;
                end
                2'd2  :
                begin
                    se_pair_nxn_coeff_0_o   = {2'b00,se_pair_last_x_prefix_0_w } ;
                    se_pair_nxn_coeff_1_o   = {2'b00,se_pair_last_y_prefix_0_w } ;
                    se_pair_nxn_coeff_2_o   = 21'b0  ;
                    se_pair_nxn_coeff_3_o   = 21'b0  ;
                end
                2'd3  :
                begin
                    se_pair_nxn_coeff_0_o   = {2'b00,se_pair_last_x_suffix_w} ;
                    se_pair_nxn_coeff_1_o   = {2'b00,se_pair_last_y_suffix_w};
                    se_pair_nxn_coeff_2_o   = 21'b0  ;
                    se_pair_nxn_coeff_3_o   = 21'b0  ;
                end
                default  :
                begin
                    se_pair_nxn_coeff_0_o   = 23'b0          ;
                    se_pair_nxn_coeff_1_o   = 23'b0          ;
                    se_pair_nxn_coeff_2_o   = 21'b0          ;
                    se_pair_nxn_coeff_3_o   = 21'b0          ;
                end
            endcase
        end
        COEFF_4x4_BLOCK   :
        begin
            case(tu_4x4_enable_cnt_r)
                5'd1:
                begin
                    se_pair_nxn_coeff_0_o   = {2'b00,se_pair_csbf_r}             ;
                    se_pair_nxn_coeff_1_o   = 23'b0          ;
                    se_pair_nxn_coeff_2_o   = 21'b0          ;
                    se_pair_nxn_coeff_3_o   = 21'b0          ;
                end
                default:
                begin
                    se_pair_nxn_coeff_0_o   = se_pair_coeff_0_w          ;
                    se_pair_nxn_coeff_1_o   = se_pair_coeff_1_w          ;
                    se_pair_nxn_coeff_2_o   = se_pair_coeff_2_w          ;
                    se_pair_nxn_coeff_3_o   = se_pair_coeff_3_w          ;
                end
            endcase
        end
        default  :
        begin
            se_pair_nxn_coeff_0_o   = 23'b0      ;
            se_pair_nxn_coeff_1_o   = 23'b0      ;
            se_pair_nxn_coeff_2_o   = 21'b0      ;
            se_pair_nxn_coeff_3_o   = 21'b0      ;
        end
    endcase
end


endmodule
