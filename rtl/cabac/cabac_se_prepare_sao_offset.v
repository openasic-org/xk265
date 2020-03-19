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
// Filename       : cabac_se_prepare_sao_offset.v
// Author         : liwei
// Created        : 2017/12/18
// Description    : syntax elements related to sao
// DATA & EDITION:  2017/12/18  1.0     liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module cabac_se_prepare_sao_offset(
           sao_data_i          ,
           sao_compidx_i       ,
           sao_merge_i         ,
           sao_type_idx_o      ,
           sao_offset_abs_0_o  ,
           sao_offset_abs_1_o  ,
           sao_offset_abs_2_o  ,
           sao_offset_abs_3_o  ,
           sao_offset_sign_0_o ,
           sao_offset_sign_1_o ,
           sao_offset_sign_2_o ,
           sao_offset_sign_3_o ,
           sao_band_pos_or_eo_class_o
       );
// -----------------------------------------------------------------------------------------------------------------------------
//
//      INPUT and OUTPUT DECLARATION
//
// -----------------------------------------------------------------------------------------------------------------------------
input  [19:0] sao_data_i              ;
input  [ 1:0] sao_compidx_i           ;
input         sao_merge_i             ;
output [20:0] sao_type_idx_o          ;//0:not applied,1:band offset,2:edge offset
output [20:0] sao_offset_abs_0_o      ;
output [20:0] sao_offset_abs_1_o      ;
output [20:0] sao_offset_abs_2_o      ;
output [20:0] sao_offset_abs_3_o      ;
output [20:0] sao_offset_sign_0_o     ;
output [20:0] sao_offset_sign_1_o     ;
output [20:0] sao_offset_sign_2_o     ;
output [20:0] sao_offset_sign_3_o     ;
output [20:0] sao_band_pos_or_eo_class_o;//32 band or 4 of eo class

reg  [20:0] sao_type_idx_o          ;//0:not applied,1:band offset,2:edge offset
reg  [20:0] sao_offset_abs_0_o      ;
reg  [20:0] sao_offset_abs_1_o      ;
reg  [20:0] sao_offset_abs_2_o      ;
reg  [20:0] sao_offset_abs_3_o      ;
reg  [20:0] sao_offset_sign_0_o     ;
reg  [20:0] sao_offset_sign_1_o     ;
reg  [20:0] sao_offset_sign_2_o     ;
reg  [20:0] sao_offset_sign_3_o     ;
reg  [20:0] sao_band_pos_or_eo_class_o;//32 band or 4 of eo class
// -----------------------------------------------------------------------------------------------------------------------------
//
//      wire and reg signals declaration
//
// -----------------------------------------------------------------------------------------------------------------------------
wire [2:0]  sao_type_w              ;
wire [4:0]  sao_sub_type_w          ;

wire [2:0]  sao_offset_0_w          ;
wire [2:0]  sao_offset_1_w          ;
wire [2:0]  sao_offset_2_w          ;
wire [2:0]  sao_offset_3_w          ;

reg  [2:0]  sao_offset_abs_0_r      ;
reg  [2:0]  sao_offset_abs_1_r      ;
reg  [2:0]  sao_offset_abs_2_r      ;
reg  [2:0]  sao_offset_abs_3_r      ;

wire sao_offset_neq0_0_w     ;
wire sao_offset_neq0_1_w     ;
wire sao_offset_neq0_2_w     ;
wire sao_offset_neq0_3_w     ;

reg  [4:0] sao_bo_offset_sign_r    ;


wire [2:0] ui_symbol_w             ;

assign   sao_type_w        =     sao_data_i[19:17]      ;
assign   sao_sub_type_w    =     sao_data_i[16:12]      ;

assign   sao_offset_3_w    =     sao_data_i[11:9 ]      ;
assign   sao_offset_2_w    =     sao_data_i[ 8:6 ]      ;
assign   sao_offset_1_w    =     sao_data_i[ 5:3 ]      ;
assign   sao_offset_0_w    =     sao_data_i[ 2:0 ]      ;


assign     ui_symbol_w     =     sao_type_w   + 2'b1    ;

// sao_offset_abs
always @*
begin
    case(sao_offset_0_w[2])
        1'b1:
            sao_offset_abs_0_r =  (~sao_offset_0_w) + 2'b1 ;
        1'b0:
            sao_offset_abs_0_r =  sao_offset_0_w           ;
    endcase
end

always @*
begin
    case(sao_offset_1_w[2])
        1'b1:
            sao_offset_abs_1_r =  (~sao_offset_1_w) + 2'b1 ;
        1'b0:
            sao_offset_abs_1_r =  sao_offset_1_w           ;
    endcase
end

always @*
begin
    case(sao_offset_2_w[2])
        1'b1:
            sao_offset_abs_2_r =  (~sao_offset_2_w) + 2'b1 ;
        1'b0:
            sao_offset_abs_2_r =  sao_offset_2_w           ;
    endcase
end

always @*
begin
    case(sao_offset_3_w[2])
        1'b1:
            sao_offset_abs_3_r =  (~sao_offset_3_w) + 2'b1 ;
        1'b0:
            sao_offset_abs_3_r =  sao_offset_3_w           ;
    endcase
end



assign   sao_offset_neq0_0_w   =   !(sao_offset_0_w==0)     ;
assign   sao_offset_neq0_1_w   =   !(sao_offset_1_w==0)     ;
assign   sao_offset_neq0_2_w   =   !(sao_offset_2_w==0)     ;
assign   sao_offset_neq0_3_w   =   !(sao_offset_3_w==0)     ;


always @*
begin
    case({sao_offset_neq0_0_w,sao_offset_neq0_1_w,sao_offset_neq0_2_w,sao_offset_neq0_3_w})
        4'b0000:
            sao_bo_offset_sign_r =  5'b0;
        4'b0001:
            sao_bo_offset_sign_r =  {4'b0,sao_offset_3_w[2]} ;
        4'b0010:
            sao_bo_offset_sign_r =  {4'b0,sao_offset_2_w[2]} ;
        4'b0011:
            sao_bo_offset_sign_r =  {3'b0,sao_offset_2_w[2],sao_offset_3_w[2]};
        4'b0100:
            sao_bo_offset_sign_r =  {4'b0,sao_offset_1_w[2]} ;
        4'b0101:
            sao_bo_offset_sign_r =  {3'b0,sao_offset_1_w[2],sao_offset_3_w[2]};
        4'b0110:
            sao_bo_offset_sign_r =  {3'b0,sao_offset_1_w[2],sao_offset_2_w[2]};
        4'b0111:
            sao_bo_offset_sign_r =  {2'b0,sao_offset_1_w[2],sao_offset_2_w[2],sao_offset_3_w[2]};
        4'b1000:
            sao_bo_offset_sign_r =  {4'b0,sao_offset_0_w[2]} ;
        4'b1001:
            sao_bo_offset_sign_r =  {3'b0,sao_offset_0_w[2],sao_offset_3_w[2]};
        4'b1010:
            sao_bo_offset_sign_r =  {3'b0,sao_offset_0_w[2],sao_offset_2_w[2]};
        4'b1011:
            sao_bo_offset_sign_r =  {2'b0,sao_offset_0_w[2],sao_offset_2_w[2],sao_offset_3_w[2]};
        4'b1100:
            sao_bo_offset_sign_r =  {3'b0,sao_offset_0_w[2],sao_offset_1_w[2]};
        4'b1101:
            sao_bo_offset_sign_r =  {2'b0,sao_offset_0_w[2],sao_offset_1_w[2],sao_offset_3_w[2]};
        4'b1110:
            sao_bo_offset_sign_r =  {2'b0,sao_offset_0_w[2],sao_offset_1_w[2],sao_offset_2_w[2]};
        4'b1111:
            sao_bo_offset_sign_r =  {1'b0,sao_offset_0_w[2],sao_offset_1_w[2],sao_offset_2_w[2],sao_offset_3_w[2]};
    endcase
end

// saoTypeIdx
always @*
begin
    if (sao_merge_i)           // sao_merge_i = merge_left || merge_top
        sao_type_idx_o = {6'h00,2'b00,4'h1,9'h0b6};
    else if(sao_compidx_i[1])  // sao_compidx_i == 2 chroma doesn't have sao_type se
        sao_type_idx_o = {6'h00,2'b00,4'h1,9'h0b6};
    else if(ui_symbol_w==3'd6)  // ui_symbol_w ==6
        sao_type_idx_o = {6'h00,2'b00,4'h1,9'h0b6};
    else if(sao_type_w==3'd4)
        sao_type_idx_o = {6'h00,2'b01,4'h1,9'h0b6};
    else
        sao_type_idx_o = {6'h00,2'b10,4'h1,9'h0b6};
end

// sao_offset
always @*
begin
    if (sao_merge_i)
    begin            // sao_merge_i = merge_left || merge_top
        sao_offset_abs_0_o =  21'b0;
        sao_offset_abs_1_o =  21'b0;
        sao_offset_abs_2_o =  21'b0;
        sao_offset_abs_3_o =  21'b0;
    end
    else if(ui_symbol_w==3'd6)
    begin
        sao_offset_abs_0_o =  21'b0;
        sao_offset_abs_1_o =  21'b0;
        sao_offset_abs_2_o =  21'b0;
        sao_offset_abs_3_o =  21'b0;
    end
    else
    begin
        sao_offset_abs_0_o =  {5'h00,sao_offset_abs_0_r,4'h7,9'h0bc};
        sao_offset_abs_1_o =  {5'h00,sao_offset_abs_1_r,4'h7,9'h0bc};
        sao_offset_abs_2_o =  {5'h00,sao_offset_abs_2_r,4'h7,9'h0bc};
        sao_offset_abs_3_o =  {5'h00,sao_offset_abs_3_r,4'h7,9'h0bc};
    end
end

// sao_bo_offset_sign
always @*
begin
    if (sao_merge_i)
    begin       // sao_merge_i = merge_left || merge_top
        sao_offset_sign_0_o = 21'b0;
        sao_offset_sign_1_o = 21'b0;
        sao_offset_sign_2_o = 21'b0;
        sao_offset_sign_3_o = 21'b0;
    end
    else if(ui_symbol_w==3'd6)
    begin
        sao_offset_sign_0_o = 21'b0;
        sao_offset_sign_1_o = 21'b0;
        sao_offset_sign_2_o = 21'b0;
        sao_offset_sign_3_o = 21'b0;
    end
    else if(sao_type_w==3'd4)
    begin
        sao_offset_sign_0_o = {7'h00,sao_bo_offset_sign_r[3],4'h1,9'h0bb};
        sao_offset_sign_1_o = {7'h00,sao_bo_offset_sign_r[2],4'h1,9'h0bb};
        sao_offset_sign_2_o = {7'h00,sao_bo_offset_sign_r[1],4'h1,9'h0bb};
        sao_offset_sign_3_o = {7'h00,sao_bo_offset_sign_r[0],4'h1,9'h0bb};
    end
    else
    begin
        sao_offset_sign_0_o = 21'b0;
        sao_offset_sign_1_o = 21'b0;
        sao_offset_sign_2_o = 21'b0;
        sao_offset_sign_3_o = 21'b0;
    end
end

// sao_subTypeIdx
always @*
begin
    if (sao_merge_i)   // sao_merge_i = merge_left || merge_top
        sao_band_pos_or_eo_class_o  =  21'b0;
    else if(ui_symbol_w==3'd6)
        sao_band_pos_or_eo_class_o  =  21'b0;
    else if(sao_type_w[2]) // SAO_BO
        sao_band_pos_or_eo_class_o  =  {3'd0,sao_sub_type_w,4'h5,9'h0bb};
    else if(sao_compidx_i[1])  // comp_idx ==2
        sao_band_pos_or_eo_class_o  =  21'b0;
    else
        sao_band_pos_or_eo_class_o  =  {5'h00,sao_type_w,4'h3,9'h0bb};
end



endmodule
