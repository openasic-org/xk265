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
// Filename       : cabac_cu_binari_tree.v
// Author         : liwei
// Created        : 2017/12/25
// Description    : syntax elements in tu
// DATA & EDITION:  2017/12/25  1.0     liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module cabac_se_prepare_tu(
           clk,
           rst_n,
           cu_idx_i,
           tree_start_i,
           cu_depth_i,
           cu_split_transform_i,
           cu_slice_type_i,
           cu_cbf_y_i,
           cu_cbf_u_i,
           cu_cbf_v_i,
           tq_rdata_i,
           cu_luma_pred_mode_i,
           cu_qp_i,
           cu_qp_last_i,
           cu_qp_no_coded_i,

           cu_tree_done_o,
           coeff_type_o,
           tq_ren_o,
           tq_raddr_o,
           cu_qp_coded_flag_o,

           se_pair_tree_0_o,
           se_pair_tree_1_o,
           se_pair_tree_2_o,
           se_pair_tree_3_o
       );
//-----------------------------------------------------------------------------------------------------------------------------
//
//               input and output signals declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
input  clk  ;
input  rst_n;
input  [6:0]    cu_idx_i              ;
input           tree_start_i          ;
input  [ 1:0 ]  cu_depth_i            ;
input           cu_split_transform_i  ; // cu_sub_div,1:split into 4 sub
input           cu_slice_type_i       ; // 1: I, 0: P/B
input  [ 3:0 ]  cu_cbf_y_i            ;
input  [ 3:0 ]  cu_cbf_u_i            ;
input  [ 3:0 ]  cu_cbf_v_i            ;
input  [255:0]  tq_rdata_i            ;
input   [5:0]   cu_luma_pred_mode_i   ;
input  [5:0]    cu_qp_i               ;
input  [5:0]    cu_qp_last_i          ;
input           cu_qp_no_coded_i      ;

output           cu_tree_done_o ;
output  [1:0]    coeff_type_o   ;
output           tq_ren_o       ;
output  [ 8:0]   tq_raddr_o     ;
output           cu_qp_coded_flag_o;

output  [22:0]   se_pair_tree_0_o ;
output  [22:0]   se_pair_tree_1_o ;
output  [20:0]   se_pair_tree_2_o ;
output  [20:0]   se_pair_tree_3_o ;

reg              cu_tree_done_o;

reg     [22:0]   se_pair_tree_0_o;
reg     [22:0]   se_pair_tree_1_o;
reg     [20:0]   se_pair_tree_2_o;
reg     [20:0]   se_pair_tree_3_o;

//-----------------------------------------------------------------------------------------------------------------------------
//
//              parameter declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
parameter   TREE_IDLE         =      4'd0   ,
            TREE_ROOT_CBF     =      4'd1   ,
            TREE_SUB_CBF      =      4'd8   ,
            TREE_COEFF_Y      =      4'd2   ,
            TREE_COEFF_SUB_Y  =      4'd3   ,
            TREE_COEFF_U      =      4'd4   ,
            TREE_COEFF_SUB_U  =      4'd5   ,
            TREE_COEFF_V      =      4'd6   ,
            TREE_COEFF_SUB_V  =      4'd7   ,
            TREE_QP           =      4'd9   ;
//-----------------------------------------------------------------------------------------------------------------------------
//
//            wire and reg signals declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
reg           [3:0]                    tree_next_state_r                       ;
reg           [3:0]                    tree_curr_state_r                       ;
reg           [2:0]                    sub_y_cnt_r                             ; // sub tu luma block count, chroma sub cnt is the same
reg                                    cbf_output_cnt_r                        ;
reg                                    qp_output_cnt_r                         ;
reg                                    cu_qp_no_coded_flag_r                   ;

wire                                   tu_coeff_done_w                         ;
wire                                   tu_coeff_sub_done_w                     ;

reg           [5:0]                    tu_luma_4x4_block_total_r               ; // 1-64
wire          [3:0]                    tu_chroma_4x4_block_total_w             ; // 1-16

reg           [1:0]                    tu_luma_depth_r                         ;
reg           [1:0]                    tu_chroma_depth_r                       ;

reg                                    tu_coeff_sub_uv_enable_r                ; // sub_div == 1 and cu width != 8

reg                                    tu_coeff_start_r                        ;
reg                                    tu_coeff_enable_r                       ;
reg           [1:0]                    coeff_type_r                            ; // 2:luma , 1 :chroma u ,0 : chroma v
reg           [5:0]                    tu_4x4_block_total_r                    ; // the total 4x4 block of current sub tu block
reg           [1:0]                    tu_depth_r                              ;
//reg           [5:0]                    intra_dir_mode_r                        ;

reg                                    tu_cbf_r                                ;
reg                                    tu_cbf_d1_r                             ;
reg                                    tu_cbf_y_r                              ;
reg                                    tu_cbf_u_r                              ;
reg                                    tu_cbf_v_r                              ;
wire                                   tu_cbf_yuv_w                            ;

// tu_luma_4x4_block_total_r
always @*
begin
    case(cu_depth_i)
        2'd0:
            tu_luma_4x4_block_total_r   =   6'd63                       ; // 64x64 ----> 4 32x32
        2'd1:
            tu_luma_4x4_block_total_r   =   6'd63                       ; // 32x32
        2'd2:
            tu_luma_4x4_block_total_r   =   6'd15                       ; // 16x16
        2'd3:
        begin
            if(cu_split_transform_i)
                tu_luma_4x4_block_total_r   =   6'd0                   ; // 8x8 ----> 4 4x4
            else
                tu_luma_4x4_block_total_r   =   6'd3                   ;
        end
    endcase
end

// tu_chroma_4x4_block_total_w
assign  tu_chroma_4x4_block_total_w =  tu_luma_4x4_block_total_r[5:2]          ;

// tu_luma_depth_r
always @*
begin
    case(cu_depth_i)
        2'd0:
            tu_luma_depth_r  =   2'd0                                         ;   // cu 64x64 ----> tu 32x32
        2'd1:
            tu_luma_depth_r  =   2'd0                                         ;   // cu 32x32 ----> tu 32x32
        2'd2:
            tu_luma_depth_r  =   2'd1                                         ;   // cu 16x16 ----> tu 16x16
        2'd3:
        begin
            if(cu_split_transform_i)
                tu_luma_depth_r  =   2'd3                                  ;   // cu 8x8   ----> tu 4x4
            else
                tu_luma_depth_r  =   2'd2                                  ;   // cu 8x8   ----> tu 8x8
        end
    endcase
end

// tu_chroma_depth_r
always @*
begin
    case(cu_depth_i)
        2'd0:
            tu_chroma_depth_r  =   2'd1                                       ;   // cu 64x64 ----> tu 16x16
        2'd1:
            tu_chroma_depth_r  =   2'd1                                       ;   // cu 32x32 ----> tu 16x16
        2'd2:
            tu_chroma_depth_r  =   2'd2                                       ;   // cu 16x16 ----> tu 8x8
        2'd3:
            tu_chroma_depth_r  =   2'd3                                       ;   // cu 8x8   ----> tu 4x4
    endcase
end

// tu_coeff_sub_uv_enable_r
always @*
begin
    if(cu_split_transform_i && cu_depth_i != 2'd3)     // sub_div && width != 8
        tu_coeff_sub_uv_enable_r  =   1'b1                                     ;
    else
        tu_coeff_sub_uv_enable_r  =   1'b0                                     ;
end


// tu_coeff_start_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tu_coeff_start_r   <=    1'b0                                          ;
    else if(tree_curr_state_r!=tree_next_state_r && (tree_next_state_r[2:1]!=0) && tu_cbf_r)
        tu_coeff_start_r   <=    1'b1                                          ;
    else
        tu_coeff_start_r   <=    1'b0                                          ;
end

// coeff_type_r
always @*
begin
    case(tree_next_state_r)
        TREE_COEFF_Y     ,
        TREE_COEFF_SUB_Y :
            coeff_type_r  =  2'd2                              ; // luma
        TREE_COEFF_U     ,
        TREE_COEFF_SUB_U :
            coeff_type_r  =  2'd1                              ; // chroma u
        TREE_COEFF_V     ,
        TREE_COEFF_SUB_V :
            coeff_type_r  =  2'd0                              ; // chroma v
        default          :
            coeff_type_r  =  2'd0                              ;
    endcase
end

// tu_4x4_block_total_r
always @*
begin
    if(tree_next_state_r[2])
        tu_4x4_block_total_r   =    {2'b0,tu_chroma_4x4_block_total_w}         ;
    else
        tu_4x4_block_total_r   =    tu_luma_4x4_block_total_r                  ;
end

// tu_depth_r
always @*
begin
    if(tree_next_state_r[2])
        tu_depth_r   =    tu_chroma_depth_r                                    ;
    else
        tu_depth_r   =    tu_luma_depth_r                                      ;
end

// intra_dir_mode_r
/*always @* begin
  case(sub_y_cnt_r[1:0])
  2'd3 :  intra_dir_mode_r =  cu_luma_pred_mode_i[ 5:0 ]             ;
  2'd2 :  intra_dir_mode_r =  cu_luma_pred_mode_i[11:6 ]             ;
  2'd1 :  intra_dir_mode_r =  cu_luma_pred_mode_i[17:12]             ;
  2'd0 :  intra_dir_mode_r =  cu_luma_pred_mode_i[23:18]             ;
  endcase                  
  end*/

// tu_cbf_r
always @*
begin
    case(coeff_type_r)
        2'd2:
            tu_cbf_r  =  tu_cbf_y_r       ;
        2'd1:
            tu_cbf_r  =  tu_cbf_u_r       ;
        2'd0:
            tu_cbf_r  =  tu_cbf_v_r       ;
        2'd3:
            tu_cbf_r  =  1'b0             ;
    endcase
end

// tu_cbf_d1_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tu_cbf_d1_r     <=  1'b0           ;
    else
        tu_cbf_d1_r     <=  tu_cbf_r       ;
end

// tu_cbf_y_r tu_cbf_u_r tu_cbf_v_r
always @*
begin
    if(!cu_split_transform_i)
    begin
        tu_cbf_y_r = !(cu_cbf_y_i==0)     ;
        tu_cbf_u_r = !(cu_cbf_u_i==0)     ;
        tu_cbf_v_r = !(cu_cbf_v_i==0)     ;
    end
    else
    begin
        case(sub_y_cnt_r[1:0])
            2'd0:
            begin
                tu_cbf_y_r = cu_cbf_y_i[3]     ;
                tu_cbf_u_r = cu_cbf_u_i[3]     ;
                tu_cbf_v_r = cu_cbf_v_i[3]     ;
            end
            2'd1:
            begin
                tu_cbf_y_r = cu_cbf_y_i[2]     ;
                tu_cbf_u_r = cu_cbf_u_i[2]     ;
                tu_cbf_v_r = cu_cbf_v_i[2]     ;
            end
            2'd2:
            begin
                tu_cbf_y_r = cu_cbf_y_i[1]     ;
                tu_cbf_u_r = cu_cbf_u_i[1]     ;
                tu_cbf_v_r = cu_cbf_v_i[1]     ;
            end
            2'd3:
            begin
                tu_cbf_y_r = cu_cbf_y_i[0]     ;
                tu_cbf_u_r = cu_cbf_u_i[0]     ;
                tu_cbf_v_r = cu_cbf_v_i[0]     ;
            end
        endcase
    end
end

assign   tu_cbf_yuv_w         =  tu_cbf_y_r || tu_cbf_u_r || tu_cbf_v_r ;
assign   tu_coeff_sub_done_w  =  tu_coeff_done_w || (!tu_cbf_d1_r)      ;

// sub_y_cnt_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        sub_y_cnt_r     <=     3'd0                                            ;
    else if(tree_curr_state_r==TREE_IDLE || !cu_split_transform_i)              // not split
        sub_y_cnt_r     <=     3'd0                                            ;
    else if(tree_curr_state_r==TREE_SUB_CBF && tree_next_state_r==TREE_SUB_CBF)
        sub_y_cnt_r     <=     sub_y_cnt_r  + 1'b1                             ;
    else if(tu_coeff_sub_done_w&& tree_curr_state_r==TREE_COEFF_SUB_Y&&!tu_coeff_sub_uv_enable_r)  // 8x8 split
        sub_y_cnt_r     <=     sub_y_cnt_r  +  3'd1                            ;
    else if( (tree_curr_state_r==TREE_COEFF_SUB_V) &&tu_coeff_sub_uv_enable_r&&tu_coeff_sub_done_w ) //64X64
        sub_y_cnt_r     <=     sub_y_cnt_r  +  3'd1                            ;
end


// cbf_output_cnt_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cbf_output_cnt_r   <=        1'b0                                      ;
    else if( tree_curr_state_r==TREE_ROOT_CBF)
        cbf_output_cnt_r   <=        1'b1                                      ;
    else
        cbf_output_cnt_r   <=        1'b0                                      ;
end

// qp_output_cnt_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        qp_output_cnt_r   <=         1'd0                                      ;
    else if(tree_curr_state_r==TREE_QP)                 // not split
        qp_output_cnt_r   <=        qp_output_cnt_r + 1'd1                     ;
    else
        qp_output_cnt_r   <=         1'd0                                      ;
end

//-----------------------------------------------------------------------------------------------------------------------------
//
//               top fsm
//
//-----------------------------------------------------------------------------------------------------------------------------


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tree_curr_state_r    <= TREE_IDLE                                      ;
    else
        tree_curr_state_r    <= tree_next_state_r                              ;
end

always @*
begin
    tree_next_state_r  =   TREE_IDLE           ;
    case(tree_curr_state_r)
        TREE_IDLE       :
        begin
            if(tree_start_i)
                tree_next_state_r  =   TREE_ROOT_CBF       ;
            else
                tree_next_state_r  =   TREE_IDLE           ;
        end
        TREE_ROOT_CBF   :
        begin
            if(cbf_output_cnt_r==1'b1)
            begin
                if(!cu_split_transform_i&&cu_qp_no_coded_flag_r&&(cu_cbf_u_i||cu_cbf_v_i||cu_cbf_y_i)) // not split && qp_no_coded
                    tree_next_state_r  =  TREE_QP                  ;
                else if(!cu_split_transform_i) // not split
                    tree_next_state_r =   TREE_COEFF_Y             ;
                else                           // split
                    tree_next_state_r  =  TREE_SUB_CBF             ;
            end
            else
                tree_next_state_r    =   TREE_ROOT_CBF             ;
        end
        TREE_SUB_CBF    :
        begin
            if(tu_cbf_yuv_w&&cu_qp_no_coded_flag_r) // cbf && qp_no_coded
                tree_next_state_r  = TREE_QP                   ;
            else if(sub_y_cnt_r==3'd3&&!tu_cbf_yuv_w)
                tree_next_state_r  = TREE_IDLE                 ;
            else
                tree_next_state_r  = TREE_COEFF_SUB_Y          ;
        end
        TREE_QP         :
        begin
            if(cu_split_transform_i && qp_output_cnt_r==1'd1) //split && qp coded
                tree_next_state_r  =  TREE_COEFF_SUB_Y     ;
            else if(qp_output_cnt_r==1'd1)                 // not split
                tree_next_state_r  =   TREE_COEFF_Y        ;
            else
                tree_next_state_r  =   TREE_QP             ;
        end
        TREE_COEFF_Y   :
        begin
            if(tu_coeff_sub_done_w)
                tree_next_state_r  =   TREE_COEFF_U        ;
            else
                tree_next_state_r  =   TREE_COEFF_Y        ;
        end
        TREE_COEFF_U    :
        begin
            if(tu_coeff_sub_done_w)
                tree_next_state_r  =   TREE_COEFF_V        ;
            else
                tree_next_state_r  =   TREE_COEFF_U        ;
        end
        TREE_COEFF_V    :
        begin
            if(tu_coeff_sub_done_w)
                tree_next_state_r  =   TREE_IDLE           ;
            else
                tree_next_state_r  =   TREE_COEFF_V        ;
        end
        TREE_COEFF_SUB_Y:
        begin
            if(tu_coeff_sub_done_w)
            begin
                if( tu_coeff_sub_uv_enable_r)
                    tree_next_state_r =  TREE_COEFF_SUB_U  ;
                else if( sub_y_cnt_r==3'd3 )
                    tree_next_state_r =  TREE_COEFF_U      ;
                else
                    tree_next_state_r =  TREE_SUB_CBF      ;
            end
            else
                tree_next_state_r     =  TREE_COEFF_SUB_Y  ;
        end
        TREE_COEFF_SUB_U:
        begin
            if(tu_coeff_sub_done_w)
                tree_next_state_r  =   TREE_COEFF_SUB_V    ;
            else
                tree_next_state_r  =   TREE_COEFF_SUB_U    ;
        end
        TREE_COEFF_SUB_V:
        begin
            if(tu_coeff_sub_done_w&& (sub_y_cnt_r==3'd3) )
                tree_next_state_r  =   TREE_IDLE           ;
            else if(tu_coeff_sub_done_w)
                tree_next_state_r  =   TREE_SUB_CBF        ;
            else
                tree_next_state_r  =   TREE_COEFF_SUB_V    ;
        end
        default:
            tree_next_state_r  =   TREE_IDLE           ;
    endcase
end

//-----------------------------------------------------------------------------------------------------------------------------
//
//            syntax elements transfer
//
//-----------------------------------------------------------------------------------------------------------------------------

// sub_div
reg           [20:0]                   se_pair_split_transform_flag_r                      ;
// cbf
reg           [20:0]                   se_pair_cbf_y_root_r                   ;
reg           [20:0]                   se_pair_cbf_y_0_r                      ;
reg           [20:0]                   se_pair_cbf_y_1_r                      ;
reg           [20:0]                   se_pair_cbf_y_2_r                      ;
reg           [20:0]                   se_pair_cbf_y_3_r                      ;
reg           [20:0]                   se_pair_cbf_y_sub_ouput_r              ;

wire          [20:0]                   se_pair_cbf_u_root_w                   ;
reg           [20:0]                   se_pair_cbf_u_0_r                      ;
reg           [20:0]                   se_pair_cbf_u_1_r                      ;
reg           [20:0]                   se_pair_cbf_u_2_r                      ;
reg           [20:0]                   se_pair_cbf_u_3_r                      ;
reg           [20:0]                   se_pair_cbf_u_sub_ouput_r              ;


wire          [20:0]                   se_pair_cbf_v_root_w                   ;
reg           [20:0]                   se_pair_cbf_v_0_r                      ;
reg           [20:0]                   se_pair_cbf_v_1_r                      ;
reg           [20:0]                   se_pair_cbf_v_2_r                      ;
reg           [20:0]                   se_pair_cbf_v_3_r                      ;
reg           [20:0]                   se_pair_cbf_v_sub_ouput_r              ;


// nxn coeff
wire          [22:0]                   se_pair_nxn_coeff_0_w                  ;
wire          [22:0]                   se_pair_nxn_coeff_1_w                  ;
wire          [20:0]                   se_pair_nxn_coeff_2_w                  ;
wire          [20:0]                   se_pair_nxn_coeff_3_w                  ;

//-----------------------------------------------
// sub_div
reg           [8:0]                    ctxIdx_split_transform_flag_r          ;

always @*
begin
    case(cu_depth_i)
        2'd0 :
            ctxIdx_split_transform_flag_r  = 9'h0b2                           ;
        2'd1 :
            ctxIdx_split_transform_flag_r  = 9'h0b2                           ;
        2'd2 :
            ctxIdx_split_transform_flag_r  = 9'h0b3                           ;
        2'd3 :
            ctxIdx_split_transform_flag_r  = 9'h0b4                           ;
    endcase
end

always @*
begin
    if(cu_slice_type_i == 1'b1)
        se_pair_split_transform_flag_r = 21'b0;
    else if(!cu_split_transform_i)          // not split into 4 sub block
        se_pair_split_transform_flag_r   =  {8'h00,4'h1,ctxIdx_split_transform_flag_r }          ;
    else if(cu_idx_i==7'd0)            // 64x64 : split into 4 sub block
        se_pair_split_transform_flag_r   =  {8'h01,4'h1,ctxIdx_split_transform_flag_r }          ;
    else                               // 8x8 : split into 4 sub block
        se_pair_split_transform_flag_r   =  {8'h01,4'h1,ctxIdx_split_transform_flag_r }          ;
end

//-----------------------------------------------
// root cbf_y
always @*
begin
    if(cu_split_transform_i) // split
        se_pair_cbf_y_root_r=  0                             ;
    else if(!cu_slice_type_i && (cu_cbf_u_i==0) && (cu_cbf_v_i==0) )
        se_pair_cbf_y_root_r=  0                             ;
    else
    begin
        if(cu_split_transform_i)
            se_pair_cbf_y_root_r=  {7'h00,!(cu_cbf_y_i==0),4'h1,9'h01d}           ;
        else
            se_pair_cbf_y_root_r=  {7'h00,!(cu_cbf_y_i==0),4'h1,9'h01e}           ;
    end
end

always @*
begin
    if(cu_split_transform_i)
        se_pair_cbf_y_0_r     =   {7'h00,cu_cbf_y_i[3],4'h1,9'h01d}               ;
    else
        se_pair_cbf_y_0_r     =  {7'h00,cu_cbf_y_i[3],4'h1,9'h01e}              ;
end

always @*
begin
    if(cu_split_transform_i)
        se_pair_cbf_y_1_r     =  {7'h00,cu_cbf_y_i[2],4'h1,9'h01d}              ;
    else
        se_pair_cbf_y_1_r     =  {7'h00,cu_cbf_y_i[2],4'h1,9'h01e}              ;
end

always @*
begin
    if(cu_split_transform_i)
        se_pair_cbf_y_2_r     =  {7'h00,cu_cbf_y_i[1],4'h1,9'h01d}              ;
    else
        se_pair_cbf_y_2_r     =  {7'h00,cu_cbf_y_i[1],4'h1,9'h01e}              ;
end

always @*
begin
    if(cu_split_transform_i)
        se_pair_cbf_y_3_r     =  {7'h00,cu_cbf_y_i[0],4'h1,9'h01d}              ;
    else
        se_pair_cbf_y_3_r     = {7'h00,cu_cbf_y_i[0],4'h1,9'h01e}              ;
end

//-----------------------------------------------
// cbf_u & cbf_v
assign se_pair_cbf_u_root_w =   {7'h00,!(cu_cbf_u_i==0),4'h1,9'h022}                ;
assign se_pair_cbf_v_root_w = {7'h00,!(cu_cbf_v_i==0),4'h1,9'h022}              ;

// se_pair_cbf_u_0_r
always @*
begin
    if(cu_split_transform_i &&(cu_idx_i==0) && (cu_cbf_u_i!=0))     // 64x64 split into 4 sub block
        se_pair_cbf_u_0_r   =  {7'h00,cu_cbf_u_i[3],4'h1,9'h023}              ;
    else
        se_pair_cbf_u_0_r   =  21'b0                        ;
end

// se_pair_cbf_u_1_r
always @*
begin
    if(cu_split_transform_i && (cu_idx_i==0) && (cu_cbf_u_i!=0))     // 64x64 split into 4 sub block
        se_pair_cbf_u_1_r   =   {7'h00,cu_cbf_u_i[2],4'h1,9'h023}                 ;
    else
        se_pair_cbf_u_1_r   =  21'b0                         ;
end

// se_pair_cbf_u_2_r
always @*
begin
    if(cu_split_transform_i && (cu_idx_i==0) && (cu_cbf_u_i!=0))     // 64x64 split into 4 sub block
        se_pair_cbf_u_2_r   =   {7'h00,cu_cbf_u_i[1],4'h1,9'h023}                ;
    else
        se_pair_cbf_u_2_r   =  21'b0                       ;
end

// se_pair_cbf_u_3_r
always @*
begin
    if(cu_split_transform_i &&(cu_idx_i==0) && (cu_cbf_u_i!=0))     // 64x64 split into 4 sub block
        se_pair_cbf_u_3_r   =  {7'h00,cu_cbf_u_i[0],4'h1,9'h023}                 ;
    else
        se_pair_cbf_u_3_r   = 21'b0                        ;
end

// se_pair_cbf_v_0_r
always @*
begin
    if(cu_split_transform_i && (cu_idx_i==0) && (cu_cbf_v_i!=0))     // 64x64 split into 4 sub block
        se_pair_cbf_v_0_r   =  {7'h00,cu_cbf_v_i[3],4'h1,9'h023}                ;
    else
        se_pair_cbf_v_0_r   =  21'b0                         ;
end

// se_pair_cbf_v_1_r
always @*
begin
    if(cu_split_transform_i &&(cu_idx_i==0) && (cu_cbf_v_i!=0))     // 64x64 split into 4 sub block
        se_pair_cbf_v_1_r   =  {7'h00,cu_cbf_v_i[2],4'h1,9'h023}                ;
    else
        se_pair_cbf_v_1_r   =  21'b0                        ;
end

// se_pair_cbf_v_2_r
always @*
begin
    if(cu_split_transform_i &&(cu_idx_i==0) && (cu_cbf_v_i!=0))     // 64x64 split into 4 sub block
        se_pair_cbf_v_2_r   =  {7'h00,cu_cbf_v_i[1],4'h1,9'h023}                ;
    else
        se_pair_cbf_v_2_r   =  21'b0                         ;
end

// se_pair_cbf_v_3_r
always @*
begin
    if(cu_split_transform_i && (cu_idx_i==0) && (cu_cbf_v_i!=0))     // 64x64 split into 4 sub block
        se_pair_cbf_v_3_r   =  {7'h00,cu_cbf_v_i[0],4'h1,9'h023}                ;
    else
        se_pair_cbf_v_3_r   =  21'b0                        ;
end

//-----------------------------------------------
// cu_qp

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_qp_no_coded_flag_r <=  1'b1                                        ;
    else if(cu_tree_done_o&&cu_qp_no_coded_i && (cu_cbf_y_i||cu_cbf_u_i||cu_cbf_v_i)&&!cu_split_transform_i) //coded: no split
        cu_qp_no_coded_flag_r <=  1'b0                                        ;
    else if(cu_qp_no_coded_i&&tu_cbf_yuv_w&&qp_output_cnt_r==1'd1)
        cu_qp_no_coded_flag_r <=  1'b0                                        ;
    else if(cu_qp_no_coded_i&&cu_qp_no_coded_flag_r==1'b0&&tree_curr_state_r!=TREE_IDLE)
        cu_qp_no_coded_flag_r <=  1'b0                                        ;
    else                                                          // no coded
        cu_qp_no_coded_flag_r <=  cu_qp_no_coded_i                             ;
end

wire [5:0] cu_qp_delta_abs_w;
wire cu_qp_delta_sign_flag_w;
wire [20:0] se_qp_delta_abs_w;
wire [20:0] se_qp_delta_sign_flag_w;

assign cu_qp_delta_sign_flag_w = (cu_qp_i<cu_qp_last_i)? 1'b1 : 1'b0;
assign cu_qp_delta_abs_w = cu_qp_delta_sign_flag_w? (cu_qp_last_i-cu_qp_i) :(cu_qp_i-cu_qp_last_i);
assign se_qp_delta_abs_w = {2'b00,cu_qp_delta_abs_w,4'h6,9'h01a};
assign se_qp_delta_sign_flag_w = {7'h00,cu_qp_delta_sign_flag_w,4'h1,9'h0bb};

//  coeff
cabac_se_prepare_coeff cabac_se_prepare_coeff_u0(
                           .clk                          ( clk                        ),
                           .rst_n                        ( rst_n                      ),
                           .cu_idx_i                     ( cu_idx_i                   ),
                           .cu_split_transform_i         ( cu_split_transform_i       ),
                           .sub_block_cnt_i              ( sub_y_cnt_r[1:0]           ),
                           .tu_coeff_start_i             ( tu_coeff_start_r           ),
                           .cu_slice_type_i              ( cu_slice_type_i            ),
                           .luma_dir_mode_i              ( cu_luma_pred_mode_i           ),
                           .coeff_type_i                 ( coeff_type_r               ),
                           .tu_4x4_block_total_i         ( tu_4x4_block_total_r       ),
                           .tu_depth_i                   ( tu_depth_r                 ),
                           .tq_rdata_i                   ( tq_rdata_i                 ),

                           .tu_coeff_done_o              ( tu_coeff_done_w            ),
                           .tq_ren_o                       ( tq_ren_o                   ),
                           .tq_raddr_o                   ( tq_raddr_o                 ),
                           .se_pair_nxn_coeff_0_o        ( se_pair_nxn_coeff_0_w      ),
                           .se_pair_nxn_coeff_1_o        ( se_pair_nxn_coeff_1_w      ),
                           .se_pair_nxn_coeff_2_o        ( se_pair_nxn_coeff_2_w      ),
                           .se_pair_nxn_coeff_3_o        ( se_pair_nxn_coeff_3_w      )
                       );

//-----------------------------------------------------------------------------------------------------------------------------
//
//            output signals
//
//-----------------------------------------------------------------------------------------------------------------------------
assign        cu_qp_coded_flag_o =      cu_qp_no_coded_flag_r                  ;
assign        coeff_type_o       =      coeff_type_r                           ;

// se_pair_cbf_y_sub_ouput_r
always @*
begin
    case(sub_y_cnt_r[1:0])
        2'd0   :
        begin
            se_pair_cbf_y_sub_ouput_r   =  se_pair_cbf_y_0_r                 ;
            se_pair_cbf_u_sub_ouput_r   =  se_pair_cbf_u_0_r                 ;
            se_pair_cbf_v_sub_ouput_r   =  se_pair_cbf_v_0_r                 ;
        end
        2'd1   :
        begin
            se_pair_cbf_y_sub_ouput_r   =  se_pair_cbf_y_1_r                 ;
            se_pair_cbf_u_sub_ouput_r   =  se_pair_cbf_u_1_r                 ;
            se_pair_cbf_v_sub_ouput_r   =  se_pair_cbf_v_1_r                 ;
        end
        2'd2   :
        begin
            se_pair_cbf_y_sub_ouput_r   =  se_pair_cbf_y_2_r                 ;
            se_pair_cbf_u_sub_ouput_r   =  se_pair_cbf_u_2_r                 ;
            se_pair_cbf_v_sub_ouput_r   =  se_pair_cbf_v_2_r                 ;
        end
        2'd3   :
        begin
            se_pair_cbf_y_sub_ouput_r   =  se_pair_cbf_y_3_r                 ;
            se_pair_cbf_u_sub_ouput_r   =  se_pair_cbf_u_3_r                 ;
            se_pair_cbf_v_sub_ouput_r   =  se_pair_cbf_v_3_r                 ;
        end
        default:
        begin
            se_pair_cbf_y_sub_ouput_r   =  21'b0                 ;
            se_pair_cbf_u_sub_ouput_r   =  21'b0                 ;
            se_pair_cbf_v_sub_ouput_r   =  21'b0                 ;
        end
    endcase
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_tree_done_o       <= 1'b0                                           ;
    else if(tree_curr_state_r==TREE_COEFF_V && tree_next_state_r== TREE_IDLE)
        cu_tree_done_o       <= 1'b1                                           ;
    else if(tree_curr_state_r==TREE_COEFF_SUB_V && tree_next_state_r== TREE_IDLE)
        cu_tree_done_o       <= 1'b1                                           ;
    else if(tree_curr_state_r==TREE_SUB_CBF && tree_next_state_r == TREE_IDLE)
        cu_tree_done_o       <= 1'b1                                           ;
    else if(tree_curr_state_r==TREE_ROOT_CBF && tree_next_state_r == TREE_IDLE)
        cu_tree_done_o       <= 1'b1                                           ;
    else
        cu_tree_done_o       <= 1'b0                                           ;
end

always @*
begin
    case(tree_curr_state_r)
        TREE_IDLE:
        begin   // 0
            se_pair_tree_0_o     =  23'b0                        ;
            se_pair_tree_1_o     =  23'b0                        ;
            se_pair_tree_2_o     =  21'b0                        ;
            se_pair_tree_3_o     =  21'b0                       ;
        end
        TREE_ROOT_CBF:
        begin  // 1
            case(cbf_output_cnt_r)
                1'd0 :
                begin
                    se_pair_tree_0_o    = cu_split_transform_i? {2'b00,se_pair_cbf_u_root_w} : {2'b00,se_pair_split_transform_flag_r} ;
                    //se_pair_tree_0_o    = cu_split_transform_i? se_pair_cbf_u_root_w : 21'b0 ;
                    se_pair_tree_1_o    = cu_split_transform_i? {2'b00,se_pair_cbf_v_root_w} : 23'b0 ;
                    se_pair_tree_2_o    = 21'b0                                               ;
                    se_pair_tree_3_o    = 21'b0                                               ;
                end
                1'd1 :
                begin
                    se_pair_tree_0_o    =  cu_split_transform_i? 23'b0 : {2'b00,se_pair_cbf_u_root_w};
                    se_pair_tree_1_o    =  cu_split_transform_i? 23'b0 : {2'b00,se_pair_cbf_v_root_w};
                    se_pair_tree_2_o    =  cu_split_transform_i? 21'b0 : se_pair_cbf_y_root_r;
                    se_pair_tree_3_o    =  cu_split_transform_i? 21'b0 : 21'b0   ;
                end
            endcase
        end
        TREE_SUB_CBF:
        begin  //8
            //se_pair_tree_0_o    =  sub_y_cnt_r[2] ? 21'b0:se_pair_split_transform_flag_r        ;
            se_pair_tree_0_o    =  23'b0;
            se_pair_tree_1_o    =  sub_y_cnt_r[2] ? 23'b0:{2'b00,se_pair_cbf_u_sub_ouput_r};
            se_pair_tree_2_o    =  sub_y_cnt_r[2] ? 21'b0:se_pair_cbf_v_sub_ouput_r;
            se_pair_tree_3_o    =  sub_y_cnt_r[2] ? 21'b0:se_pair_cbf_y_sub_ouput_r;
        end
        TREE_QP:
        begin     // 9
            case(qp_output_cnt_r)
                1'd0 :
                begin
                    se_pair_tree_0_o    =  {2'b00,se_qp_delta_abs_w};
                    se_pair_tree_1_o    =  cu_qp_delta_abs_w?{2'b00,se_qp_delta_sign_flag_w}:23'b0;
                    se_pair_tree_2_o    =  21'b0;
                    se_pair_tree_3_o    =  21'b0;
                end
                1'd1 :
                begin
                    se_pair_tree_0_o    =  23'b0;
                    se_pair_tree_1_o    =  23'b0;
                    se_pair_tree_2_o    =  21'b0;
                    se_pair_tree_3_o    =  21'b0;
                end
            endcase
        end
        default :
        begin
            se_pair_tree_0_o    =  se_pair_nxn_coeff_0_w                 ;
            se_pair_tree_1_o    =  se_pair_nxn_coeff_1_w                 ;
            se_pair_tree_2_o    =  se_pair_nxn_coeff_2_w                 ;
            se_pair_tree_3_o    =  se_pair_nxn_coeff_3_w                 ;
        end
    endcase
end


endmodule

