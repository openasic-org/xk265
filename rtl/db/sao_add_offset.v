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
//-------------------------------------------------------------------
// Filename       : sao_add_offset.v
// Author         : TANG
// Creatu_ved     : 12/19/2017
// Description    :         
//------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module sao_add_offset(
        clk               ,
        rst_n             ,
        state_i           ,
        sao_4x4_x_i       ,
        sao_4x4_y_i       ,
        sao_sel_i         ,
        bo_predecision    ,
        rec_i_0           ,
        rec_i_1           ,
        rec_i_2           ,
        rec_i_3           ,
        rec_i_4           ,
        EO_0_0            ,
        EO_0_1            ,
        EO_0_2            ,
        EO_0_3            ,
        EO_45_0           ,
        EO_45_1           ,
        EO_45_2           ,
        EO_45_3           ,
        EO_90_0           ,
        EO_90_1           ,
        EO_90_2           ,
        EO_90_3           ,
        EO_135_0          ,
        EO_135_1          ,
        EO_135_2          ,
        EO_135_3          ,
        BO_0              ,
        BO_1              ,
        BO_2              ,
        BO_3              ,
        BO_4              ,
        BO_5              ,
        BO_6              ,
        BO_7              ,
        y_sao_type_i      ,
        y_sao_sub_type_i  ,
        y_sao_offset_i    ,
        u_sao_type_i      ,
        u_sao_sub_type_i  ,
        u_sao_offset_i    ,
        v_sao_type_i      ,
        v_sao_sub_type_i  ,
        v_sao_offset_i    ,
        rec_sao_o       //,
    //  out_done_o      
);

parameter IDLE = 3'b000, LOAD = 3'b001, DBY = 3'b011, DBU = 3'b010, DBV = 3'b110, SAO = 3'b100, OUT = 3'b101;

input                               clk ,rst_n        ;
input        [2         :0]         state_i           ;
input        [4         :0]         bo_predecision    ;

input        [4       -1:0]         sao_4x4_x_i       ;
input        [4       -1:0]         sao_4x4_y_i       ;
input        [2       -1:0]         sao_sel_i         ;

input        [16      -1:0]         EO_0_0            ;
input        [16      -1:0]         EO_0_1            ;
input        [16      -1:0]         EO_0_2            ;
input        [16      -1:0]         EO_0_3            ;
input        [16      -1:0]         EO_45_0           ; 
input        [16      -1:0]         EO_45_1           ; 
input        [16      -1:0]         EO_45_2           ; 
input        [16      -1:0]         EO_45_3           ; 
input        [16      -1:0]         EO_90_0           ; 
input        [16      -1:0]         EO_90_1           ; 
input        [16      -1:0]         EO_90_2           ; 
input        [16      -1:0]         EO_90_3           ; 
input        [16      -1:0]         EO_135_0          ; 
input        [16      -1:0]         EO_135_1          ; 
input        [16      -1:0]         EO_135_2          ; 
input        [16      -1:0]         EO_135_3          ; 
input        [16      -1:0]         BO_0              ;
input        [16      -1:0]         BO_1              ;
input        [16      -1:0]         BO_2              ;
input        [16      -1:0]         BO_3              ;
input        [16      -1:0]         BO_4              ;
input        [16      -1:0]         BO_5              ;
input        [16      -1:0]         BO_6              ;
input        [16      -1:0]         BO_7              ;

input        [6*8     -1:0]         rec_i_0           ;
input        [6*8     -1:0]         rec_i_1           ;
input        [6*8     -1:0]         rec_i_2           ;
input        [6*8     -1:0]         rec_i_3           ;
input        [6*8     -1:0]         rec_i_4           ;

input        [ 2        :0]         y_sao_type_i      ;
input        [ 4        :0]         y_sao_sub_type_i  ;
input        [11        :0]         y_sao_offset_i    ;
input        [ 2        :0]         u_sao_type_i      ;
input        [ 4        :0]         u_sao_sub_type_i  ;
input        [11        :0]         u_sao_offset_i    ;
input        [ 2        :0]         v_sao_type_i      ;
input        [ 4        :0]         v_sao_sub_type_i  ;
input        [11        :0]         v_sao_offset_i    ;

output       [16*`PIXEL_WIDTH-1:0]  rec_sao_o         ;
reg          [16*`PIXEL_WIDTH-1:0]  rec_sao_o         ;

reg          [2         :0]         sao_type          ;
reg          [4         :0]         sao_subtype       ;

reg  signed  [2:         0]         sao_offset_0      ; 
reg  signed  [2:         0]         sao_offset_1      ;
reg  signed  [2:         0]         sao_offset_2      ;
reg  signed  [2:         0]         sao_offset_3      ;

reg          [16      -1:0]         sao_mode0         ;
reg          [16      -1:0]         sao_mode1         ;
reg          [16      -1:0]         sao_mode2         ;
reg          [16      -1:0]         sao_mode3         ;


always @ ( * ) begin 
    if ( state_i == OUT && sao_sel_i == `TYPE_Y ) begin// offset Y
        sao_type     = y_sao_type_i            ;
        sao_subtype  = y_sao_sub_type_i        ;
        sao_offset_0 = y_sao_offset_i[ 2: 0]   ;
        sao_offset_1 = y_sao_offset_i[ 5: 3]   ;
        sao_offset_2 = y_sao_offset_i[ 8: 6]   ;
        sao_offset_3 = y_sao_offset_i[11: 9]   ;
    end 
    else if ( state_i == OUT && sao_sel_i == `TYPE_U ) begin // offset U
        sao_type     = u_sao_type_i            ;
        sao_subtype  = u_sao_sub_type_i        ;
        sao_offset_0 = u_sao_offset_i[ 2: 0]   ;
        sao_offset_1 = u_sao_offset_i[ 5: 3]   ;
        sao_offset_2 = u_sao_offset_i[ 8: 6]   ;
        sao_offset_3 = u_sao_offset_i[11: 9]   ;
    end 
    else if ( state_i == OUT && sao_sel_i == `TYPE_V ) begin // offset V
        sao_type     = v_sao_type_i            ;
        sao_subtype  = v_sao_sub_type_i        ;
        sao_offset_0 = v_sao_offset_i[ 2: 0]   ;
        sao_offset_1 = v_sao_offset_i[ 5: 3]   ;
        sao_offset_2 = v_sao_offset_i[ 8: 6]   ;
        sao_offset_3 = v_sao_offset_i[11: 9]   ;
    end 
    else begin 
        sao_type     = 0                       ;
        sao_subtype  = 0                       ;
        sao_offset_0 = 0                       ;
        sao_offset_1 = 0                       ;
        sao_offset_2 = 0                       ;
        sao_offset_3 = 0                       ;
    end 
end 

always @ ( * ) begin 
    if ( sao_type == 0 ) begin 
        sao_mode0    = EO_0_0                   ;
        sao_mode1    = EO_0_1                   ;
        sao_mode2    = EO_0_2                   ;        
        sao_mode3    = EO_0_3                   ;
    end 
    else if ( sao_type == 3 ) begin 
        sao_mode0    = EO_45_0                  ;
        sao_mode1    = EO_45_1                  ;
        sao_mode2    = EO_45_2                  ;        
        sao_mode3    = EO_45_3                  ;
    end 
    else if ( sao_type == 1 ) begin 
        sao_mode0    = EO_90_0                  ;
        sao_mode1    = EO_90_1                  ;
        sao_mode2    = EO_90_2                  ;        
        sao_mode3    = EO_90_3                  ;
    end 
    else if ( sao_type == 2 ) begin 
        sao_mode0    = EO_135_0                 ;
        sao_mode1    = EO_135_1                 ;
        sao_mode2    = EO_135_2                 ;        
        sao_mode3    = EO_135_3                 ;
    end 
    else if ( sao_type == 4 ) begin 
        case ( sao_subtype - bo_predecision)
            3'b000: begin 
                sao_mode0    = BO_0             ;
                sao_mode1    = BO_1             ;
                sao_mode2    = BO_2             ;        
                sao_mode3    = BO_3             ;
            end 
            3'b001:begin 
                sao_mode0    = BO_1             ;
                sao_mode1    = BO_2             ;
                sao_mode2    = BO_3             ;        
                sao_mode3    = BO_4             ;
            end 
            3'b010:begin 
                sao_mode0    = BO_2             ;
                sao_mode1    = BO_3             ;
                sao_mode2    = BO_4             ;        
                sao_mode3    = BO_5             ;
            end 
            3'b011:begin 
                sao_mode0    = BO_3             ;
                sao_mode1    = BO_4             ;
                sao_mode2    = BO_5             ;        
                sao_mode3    = BO_6             ;
            end 
            3'b100:begin 
                sao_mode0    = BO_4             ;
                sao_mode1    = BO_5             ;
                sao_mode2    = BO_6             ;        
                sao_mode3    = BO_7             ;
            end 
            default : begin 
                sao_mode0    = 0                ;
                sao_mode1    = 0                ;
                sao_mode2    = 0                ;        
                sao_mode3    = 0                ;
            end 
        endcase 
    end 
    else begin 
                sao_mode0    = 0                ;
                sao_mode1    = 0                ;
                sao_mode2    = 0                ;        
                sao_mode3    = 0                ;
            end 
end 

//---- add offset
wire signed [2:0] offset_00 ;
wire signed [2:0] offset_01 ;
wire signed [2:0] offset_02 ;
wire signed [2:0] offset_03 ;
wire signed [2:0] offset_04 ;
wire signed [2:0] offset_05 ;
wire signed [2:0] offset_06 ;
wire signed [2:0] offset_07 ;
wire signed [2:0] offset_08 ;
wire signed [2:0] offset_09 ;
wire signed [2:0] offset_10 ;
wire signed [2:0] offset_11 ;
wire signed [2:0] offset_12 ;
wire signed [2:0] offset_13 ;
wire signed [2:0] offset_14 ;
wire signed [2:0] offset_15 ;

wire signed [`PIXEL_WIDTH:0] rec_s_00 ;
wire signed [`PIXEL_WIDTH:0] rec_s_01 ;
wire signed [`PIXEL_WIDTH:0] rec_s_02 ;
wire signed [`PIXEL_WIDTH:0] rec_s_03 ;
wire signed [`PIXEL_WIDTH:0] rec_s_04 ;
wire signed [`PIXEL_WIDTH:0] rec_s_05 ;
wire signed [`PIXEL_WIDTH:0] rec_s_06 ;
wire signed [`PIXEL_WIDTH:0] rec_s_07 ;
wire signed [`PIXEL_WIDTH:0] rec_s_08 ;
wire signed [`PIXEL_WIDTH:0] rec_s_09 ;
wire signed [`PIXEL_WIDTH:0] rec_s_10 ;
wire signed [`PIXEL_WIDTH:0] rec_s_11 ;
wire signed [`PIXEL_WIDTH:0] rec_s_12 ;
wire signed [`PIXEL_WIDTH:0] rec_s_13 ;
wire signed [`PIXEL_WIDTH:0] rec_s_14 ;
wire signed [`PIXEL_WIDTH:0] rec_s_15 ;

wire signed [`PIXEL_WIDTH:0] rec_w_00 ;
wire signed [`PIXEL_WIDTH:0] rec_w_01 ;
wire signed [`PIXEL_WIDTH:0] rec_w_02 ;
wire signed [`PIXEL_WIDTH:0] rec_w_03 ;
wire signed [`PIXEL_WIDTH:0] rec_w_04 ;
wire signed [`PIXEL_WIDTH:0] rec_w_05 ;
wire signed [`PIXEL_WIDTH:0] rec_w_06 ;
wire signed [`PIXEL_WIDTH:0] rec_w_07 ;
wire signed [`PIXEL_WIDTH:0] rec_w_08 ;
wire signed [`PIXEL_WIDTH:0] rec_w_09 ;
wire signed [`PIXEL_WIDTH:0] rec_w_10 ;
wire signed [`PIXEL_WIDTH:0] rec_w_11 ;
wire signed [`PIXEL_WIDTH:0] rec_w_12 ;
wire signed [`PIXEL_WIDTH:0] rec_w_13 ;
wire signed [`PIXEL_WIDTH:0] rec_w_14 ;
wire signed [`PIXEL_WIDTH:0] rec_w_15 ;

reg [`PIXEL_WIDTH-1 :0] rec_0_r ;
reg [`PIXEL_WIDTH-1 :0] rec_1_r ;
reg [`PIXEL_WIDTH-1 :0] rec_2_r ;
reg [`PIXEL_WIDTH-1 :0] rec_3_r ;


assign offset_00 =  sao_mode0[00] ? sao_offset_0 : (sao_mode1[00] ? sao_offset_1 : (sao_mode2[00] ? sao_offset_2 : (sao_mode3[00] ? sao_offset_3 : 0)));
assign offset_01 =  sao_mode0[01] ? sao_offset_0 : (sao_mode1[01] ? sao_offset_1 : (sao_mode2[01] ? sao_offset_2 : (sao_mode3[01] ? sao_offset_3 : 0)));
assign offset_02 =  sao_mode0[02] ? sao_offset_0 : (sao_mode1[02] ? sao_offset_1 : (sao_mode2[02] ? sao_offset_2 : (sao_mode3[02] ? sao_offset_3 : 0)));
assign offset_03 =  sao_mode0[03] ? sao_offset_0 : (sao_mode1[03] ? sao_offset_1 : (sao_mode2[03] ? sao_offset_2 : (sao_mode3[03] ? sao_offset_3 : 0)));
assign offset_04 =  sao_mode0[04] ? sao_offset_0 : (sao_mode1[04] ? sao_offset_1 : (sao_mode2[04] ? sao_offset_2 : (sao_mode3[04] ? sao_offset_3 : 0)));
assign offset_05 =  sao_mode0[05] ? sao_offset_0 : (sao_mode1[05] ? sao_offset_1 : (sao_mode2[05] ? sao_offset_2 : (sao_mode3[05] ? sao_offset_3 : 0)));
assign offset_06 =  sao_mode0[06] ? sao_offset_0 : (sao_mode1[06] ? sao_offset_1 : (sao_mode2[06] ? sao_offset_2 : (sao_mode3[06] ? sao_offset_3 : 0)));
assign offset_07 =  sao_mode0[07] ? sao_offset_0 : (sao_mode1[07] ? sao_offset_1 : (sao_mode2[07] ? sao_offset_2 : (sao_mode3[07] ? sao_offset_3 : 0)));
assign offset_08 =  sao_mode0[08] ? sao_offset_0 : (sao_mode1[08] ? sao_offset_1 : (sao_mode2[08] ? sao_offset_2 : (sao_mode3[08] ? sao_offset_3 : 0)));
assign offset_09 =  sao_mode0[09] ? sao_offset_0 : (sao_mode1[09] ? sao_offset_1 : (sao_mode2[09] ? sao_offset_2 : (sao_mode3[09] ? sao_offset_3 : 0)));
assign offset_10 =  sao_mode0[10] ? sao_offset_0 : (sao_mode1[10] ? sao_offset_1 : (sao_mode2[10] ? sao_offset_2 : (sao_mode3[10] ? sao_offset_3 : 0)));
assign offset_11 =  sao_mode0[11] ? sao_offset_0 : (sao_mode1[11] ? sao_offset_1 : (sao_mode2[11] ? sao_offset_2 : (sao_mode3[11] ? sao_offset_3 : 0)));
assign offset_12 =  sao_mode0[12] ? sao_offset_0 : (sao_mode1[12] ? sao_offset_1 : (sao_mode2[12] ? sao_offset_2 : (sao_mode3[12] ? sao_offset_3 : 0)));
assign offset_13 =  sao_mode0[13] ? sao_offset_0 : (sao_mode1[13] ? sao_offset_1 : (sao_mode2[13] ? sao_offset_2 : (sao_mode3[13] ? sao_offset_3 : 0)));
assign offset_14 =  sao_mode0[14] ? sao_offset_0 : (sao_mode1[14] ? sao_offset_1 : (sao_mode2[14] ? sao_offset_2 : (sao_mode3[14] ? sao_offset_3 : 0)));
assign offset_15 =  sao_mode0[15] ? sao_offset_0 : (sao_mode1[15] ? sao_offset_1 : (sao_mode2[15] ? sao_offset_2 : (sao_mode3[15] ? sao_offset_3 : 0)));

assign rec_s_15  = {1'b0,rec_i_1[5*8-1:4*8]};
assign rec_s_14  = {1'b0,rec_i_1[4*8-1:3*8]};
assign rec_s_13  = {1'b0,rec_i_1[3*8-1:2*8]};
assign rec_s_12  = {1'b0,rec_i_1[2*8-1:1*8]};
assign rec_s_11  = {1'b0,rec_i_2[5*8-1:4*8]};
assign rec_s_10  = {1'b0,rec_i_2[4*8-1:3*8]};
assign rec_s_09  = {1'b0,rec_i_2[3*8-1:2*8]};
assign rec_s_08  = {1'b0,rec_i_2[2*8-1:1*8]};
assign rec_s_07  = {1'b0,rec_i_3[5*8-1:4*8]};
assign rec_s_06  = {1'b0,rec_i_3[4*8-1:3*8]};
assign rec_s_05  = {1'b0,rec_i_3[3*8-1:2*8]};
assign rec_s_04  = {1'b0,rec_i_3[2*8-1:1*8]};
assign rec_s_03  = {1'b0,rec_i_4[5*8-1:4*8]};
assign rec_s_02  = {1'b0,rec_i_4[4*8-1:3*8]};
assign rec_s_01  = {1'b0,rec_i_4[3*8-1:2*8]};
assign rec_s_00  = {1'b0,rec_i_4[2*8-1:1*8]};

assign rec_w_15  = rec_s_15 + offset_15 ;
assign rec_w_14  = rec_s_14 + offset_14 ;
assign rec_w_13  = rec_s_13 + offset_13 ;
assign rec_w_12  = rec_s_12 + offset_12 ;
assign rec_w_11  = rec_s_11 + offset_11 ;
assign rec_w_10  = rec_s_10 + offset_10 ;
assign rec_w_09  = rec_s_09 + offset_09 ;
assign rec_w_08  = rec_s_08 + offset_08 ;
assign rec_w_07  = rec_s_07 + offset_07 ;
assign rec_w_06  = rec_s_06 + offset_06 ;
assign rec_w_05  = rec_s_05 + offset_05 ;
assign rec_w_04  = rec_s_04 + offset_04 ;
assign rec_w_03  = rec_s_03 + offset_03 ;
assign rec_w_02  = rec_s_02 + offset_02 ;
assign rec_w_01  = rec_s_01 + offset_01 ;
assign rec_w_00  = rec_s_00 + offset_00 ;

always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n ) begin 
        rec_0_r <= 0;
        rec_1_r <= 0;
        rec_2_r <= 0;
        rec_3_r <= 0;
    end 
    else begin 
        rec_0_r <= rec_w_12[7:0];
        rec_1_r <= rec_w_08[7:0];
        rec_2_r <= rec_w_04[7:0];
        rec_3_r <= rec_w_00[7:0];
    end 
end 

always @* begin 
    if ( sao_4x4_x_i == 0 && sao_4x4_y_i == 0 )
        rec_sao_o = { rec_i_0[6*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]
                     ,rec_i_1[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH],rec_w_15[7:0], rec_w_14[7:0], rec_w_13[7:0]
                     ,rec_i_2[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH],rec_w_11[7:0], rec_w_10[7:0], rec_w_09[7:0] 
                     ,rec_i_3[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH],rec_w_07[7:0], rec_w_06[7:0], rec_w_05[7:0]} ; 
    else if ( sao_4x4_y_i == 0 )
        rec_sao_o = { rec_i_0[6*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]
                     ,rec_0_r, rec_w_15[7:0], rec_w_14[7:0], rec_w_13[7:0] 
                     ,rec_1_r, rec_w_11[7:0], rec_w_10[7:0], rec_w_09[7:0]  
                     ,rec_2_r, rec_w_07[7:0], rec_w_06[7:0], rec_w_05[7:0] } ;  
    else if (sao_4x4_x_i == 0)
        rec_sao_o = { rec_i_1[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH], rec_w_15[7:0], rec_w_14[7:0], rec_w_13[7:0]
                     ,rec_i_2[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH], rec_w_11[7:0], rec_w_10[7:0], rec_w_09[7:0] 
                     ,rec_i_3[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH], rec_w_07[7:0], rec_w_06[7:0], rec_w_05[7:0]
                     ,rec_i_4[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH], rec_w_03[7:0], rec_w_02[7:0], rec_w_01[7:0] } ; 
    else 
        rec_sao_o = { rec_0_r, rec_w_15[7:0], rec_w_14[7:0], rec_w_13[7:0]
                     ,rec_1_r, rec_w_11[7:0], rec_w_10[7:0], rec_w_09[7:0] 
                     ,rec_2_r, rec_w_07[7:0], rec_w_06[7:0], rec_w_05[7:0]
                     ,rec_3_r, rec_w_03[7:0], rec_w_02[7:0], rec_w_01[7:0] } ; 
end  

endmodule 