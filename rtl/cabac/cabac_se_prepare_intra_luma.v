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
// Filename       : cabac_se_prepare_intra_luma.v
// Author         : liwei
// Created        : 2018/1/10
// Description    : syntax elements related luma mode
// DATA & EDITION:  2018/1/10   1.0     liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
`include "enc_defines.v"


module cabac_se_prepare_intra_luma(
           // input
           luma_curr_mode_i        ,
           luma_left_mode_i        ,
           luma_top_mode_i         ,
           //output
           prev_intra_luma_pred_flag_o  ,
           mpm_idx_or_rem_luma_mode_o
       );
//-----------------------------------------------------------------------------------------------------------------------------
//
//                                input signals and output signals
//
//-----------------------------------------------------------------------------------------------------------------------------
input   [5:0]    luma_curr_mode_i                   ;
input   [5:0]    luma_left_mode_i                   ;
input   [5:0]    luma_top_mode_i                    ;

output  [20:0]   prev_intra_luma_pred_flag_o        ;
output  [20:0]   mpm_idx_or_rem_luma_mode_o         ;

reg              prev_intra_luma_pred_flag_r        ;
reg     [20:0]   mpm_idx_or_rem_luma_mode_o;

//-----------------------------------------------------------------------------------------------------------------------------
//
//                              reg and wire signals declaration
//
//-----------------------------------------------------------------------------------------------------------------------------


reg      [5:0]    PMP0_r  ,  PMP1_r  , PMP2_r                   ;
reg      [1:0]    mpm_idx_r ;

wire              preds_0_le_1_w    ,preds_0_le_2_w     ,preds_1_le_2_w  ;

reg      [5:0]    preds_0_sort_r    ,preds_1_sort_r     ,preds_2_sort_r  ;

wire     [5:0]    luma_curr_mode_minus1_w ;
wire     [5:0]    luma_curr_mode_minus2_w ;
wire     [5:0]    luma_curr_mode_minus3_w ;
reg      [5:0]    luma_mode_dir_r         ;
// calculation prediction candidates : PMP0_r ,PMP1_r ,PMP2_r
always @*
begin
    if(luma_top_mode_i == luma_left_mode_i)
    begin
        if(luma_left_mode_i[5:1])
        begin //  >6'd2
            PMP0_r  =   luma_left_mode_i                          ;
            PMP1_r  =   ((luma_left_mode_i + 6'd29)&6'd31) + 6'd2 ;
            PMP2_r  =   ((luma_left_mode_i - 6'd1 )&6'd31) + 6'd2 ;
        end
        else
        begin
            PMP0_r  =   6'd0               ;
            PMP1_r  =   6'd1               ;
            PMP2_r  =   6'd26              ;
        end
    end
    else
    begin
        if((luma_left_mode_i!=0) && (luma_top_mode_i!=0))
        begin
            PMP0_r  =   luma_left_mode_i  ;
            PMP1_r  =   luma_top_mode_i   ;
            PMP2_r  =   6'd0                ;
        end
        else
        begin
            PMP0_r  =   luma_left_mode_i  ;
            PMP1_r  =   luma_top_mode_i   ;
            PMP2_r  =   (luma_left_mode_i + luma_top_mode_i)<7'd2 ? 6'd26 :6'd1 ;
        end
    end
end
// most  probably candidates : mpm_idx_r
always @*
begin
    if(luma_curr_mode_i == PMP2_r)
        mpm_idx_r  =    2'd2   ;
    else if(luma_curr_mode_i == PMP1_r)
        mpm_idx_r  =    2'd1   ;
    else if(luma_curr_mode_i == PMP0_r)
        mpm_idx_r  =    2'd0   ;
    else
        mpm_idx_r  =    2'd3   ;
end
// prediction candidates resorting
assign   preds_0_le_1_w   =     PMP0_r  <  PMP1_r   ;
assign   preds_0_le_2_w   =     PMP0_r  <  PMP2_r   ;
assign   preds_1_le_2_w   =     PMP1_r  <  PMP2_r   ;

always @*
begin
    if(preds_0_le_1_w && preds_0_le_2_w && preds_1_le_2_w)
    begin
        preds_0_sort_r = PMP0_r;
        preds_1_sort_r = PMP1_r;
        preds_2_sort_r = PMP2_r;
    end
    else if(preds_0_le_1_w && preds_0_le_2_w && (!preds_1_le_2_w) )
    begin
        preds_0_sort_r = PMP0_r;
        preds_1_sort_r = PMP2_r;
        preds_2_sort_r = PMP1_r;
    end
    else if(preds_0_le_1_w && (!preds_0_le_2_w) )
    begin
        preds_0_sort_r = PMP2_r;
        preds_1_sort_r = PMP0_r;
        preds_2_sort_r = PMP1_r;
    end
    else if((!preds_0_le_1_w) && preds_0_le_2_w)
    begin
        preds_0_sort_r = PMP1_r;
        preds_1_sort_r = PMP0_r;
        preds_2_sort_r = PMP2_r;
    end
    else if( (!preds_0_le_1_w) && (!preds_0_le_2_w) && preds_1_le_2_w)
    begin
        preds_0_sort_r = PMP1_r;
        preds_1_sort_r = PMP2_r;
        preds_2_sort_r = PMP0_r;
    end
    else
    begin
        preds_0_sort_r = PMP2_r;
        preds_1_sort_r = PMP1_r;
        preds_2_sort_r = PMP0_r;
    end
end
// calculation  luma_mode_dir_r : final modified luma mode
assign luma_curr_mode_minus1_w  = luma_curr_mode_i - 6'd1  ;
assign luma_curr_mode_minus2_w  = luma_curr_mode_i - 6'd2  ;
assign luma_curr_mode_minus3_w  = luma_curr_mode_i - 6'd3  ;

always @*
begin
    if(luma_curr_mode_i>preds_2_sort_r)
    begin
        if(luma_curr_mode_minus1_w>preds_1_sort_r)
        begin
            if(luma_curr_mode_minus2_w>preds_0_sort_r)
            begin
                luma_mode_dir_r = luma_curr_mode_minus3_w  ;
            end
            else
            begin
                luma_mode_dir_r = luma_curr_mode_minus2_w  ;
            end
        end
        else
        begin
            if(luma_curr_mode_minus1_w>preds_0_sort_r)
            begin
                luma_mode_dir_r = luma_curr_mode_minus2_w  ;
            end
            else
            begin
                luma_mode_dir_r = luma_curr_mode_minus1_w   ;
            end
        end
    end
    else
    begin
        if(luma_curr_mode_i>preds_1_sort_r)
        begin
            if(luma_curr_mode_minus1_w>preds_0_sort_r)
            begin
                luma_mode_dir_r = luma_curr_mode_minus2_w  ;
            end
            else
            begin
                luma_mode_dir_r = luma_curr_mode_minus1_w  ;
            end
        end
        else
        begin
            if(luma_curr_mode_i>preds_0_sort_r)
            begin
                luma_mode_dir_r = luma_curr_mode_minus1_w  ;
            end
            else
            begin
                luma_mode_dir_r = luma_curr_mode_i         ;
            end
        end
    end
end

//-----------------------------------------------------------------------------------------------------------------------------
//
//                          output signals
//
//-----------------------------------------------------------------------------------------------------------------------------

always @*
begin
    case(mpm_idx_r)
        2'd0:
        begin
            prev_intra_luma_pred_flag_r = 1'b1;
            mpm_idx_or_rem_luma_mode_o = {3'h0,5'h0,4'h2,9'h0bd};
        end
        2'd1:
        begin
            prev_intra_luma_pred_flag_r = 1'b1;
            mpm_idx_or_rem_luma_mode_o = {3'h0,5'h1,4'h2,9'h0bd};
        end
        2'd2:
        begin
            prev_intra_luma_pred_flag_r = 1'b1;
            mpm_idx_or_rem_luma_mode_o = {3'h0,5'h2,4'h2,9'h0bd};
        end
        2'd3:
        begin
            prev_intra_luma_pred_flag_r = 1'b0;
            mpm_idx_or_rem_luma_mode_o = {3'h0,luma_mode_dir_r[4:0],4'h5,9'h0bb};
        end
        default:
        begin
            prev_intra_luma_pred_flag_r = 1'b0;
            mpm_idx_or_rem_luma_mode_o = 21'h0;
        end
    endcase
end

assign  prev_intra_luma_pred_flag_o = {7'h0,prev_intra_luma_pred_flag_r,4'h1,9'h00e};



endmodule


