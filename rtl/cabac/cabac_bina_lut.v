//-----------------------------------------------------------------------------------------------------------------------------
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
// Filename       : cabac_bina_lut.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : syntax element prepare
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
`timescale 1ns/1ns

module cabac_bina_lut(
           rdy,
           in_ctxIdx,
           in_cMax,

           gp_five_minus_max_num_merge_cand,

           out_binaType,
           out_cMax
       );

input                   rdy;
input       [8:0]       in_ctxIdx;
input       [3:0]       in_cMax;

input       [2:0]       gp_five_minus_max_num_merge_cand;

output  reg [2:0]       out_binaType;
output  reg [3:0]       out_cMax;

parameter   FL = 0,
            TU = 1,
            EG1 = 2,
            //UMS = 3,
            CREG = 4,
            SP = 5;


always @ (*)
begin
    out_binaType = 'hX;
    out_cMax = in_cMax;
    case(in_ctxIdx)

        0, 1, 2,            // split_cu_flag
        3, 4, 5,            // cu_skip_flag
        6,                  // merge_flag

        13,                 // pred_mode_flag
        14,                 // prev_intra_luma_pred_flag

        22,                 // abs_mvd_greater0_flag
        23,                 // abs_mvd_greater1_flag

        29, 30,             // cbf_luma
        31, 32, 33, 34,     // cbf_cb
        35, 36, 37, 38,     // cbf_cr
        39,                 // rqt_root_cbf
        40, 41, 42, 43,     // coded_sub_block_flag

        44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
        60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75,
        76, 77, 78, 79, 80, 81, 82, 83, 84, 85, // sig_coeff_flag

        146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158,
        159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, // coeff_abs_level_greater1_flag

        170, 171, 172, 173, 174, 175, // coeff_abs_level_greater2_flag

        176,                // mvp_l0_flag, mvp_l1_flag
        178, 179, 180,      // split_transform_flag
        181,                // sao_merge_left, sao_merge_up

        183,                // transform_skip_flag[][][0] (luma)
        184,                // transform_skip_flag[][][1]/[2] (chroma)

        185,                // cu_transquant_bypass_flag
        186:                // end_of_slice_segment_flag, end_of_sub_stream_one_bit

        begin
            out_binaType = FL;
            out_cMax = 1;
        end


        7:
        begin
            out_binaType = TU;
            out_cMax = (5 - gp_five_minus_max_num_merge_cand) - 1;
        end // merge_idx
        8:
        begin
            out_binaType = SP;
        end // part_mode
        15:
        begin
            out_binaType = SP;
            out_cMax = 3;
        end // intra_chroma_pred_mode, cMax = ?
        17, 18, 19,
        20, 21:
        begin
            out_binaType = SP;
        end // inter_pred_idc

        24:
        begin
            out_binaType = TU;
        end // ref_idx_l0, ref_idx_l1, cMax = num_ref_idx_l0/1_active_minus1
        26:
        begin
            out_binaType = TU;
        end // cu_qp_delta_abs, cMax taken care by binarizer

        86,  87,  88,  89,  90,  91,  92,  93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103,    // last_sig_coeff_x_prefix
        116, 117 ,118 ,119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133:   // last_sig_coeff_y_prefix
        begin
            out_binaType = TU;
        end // cMax = (log2TrafoSize << 1) - 1;

        182:
        begin
            out_binaType = TU;
            out_cMax = 2;
        end // sao_type_idx_luma, sao_type_idx_chroma

        187:
        begin
            out_binaType = FL;
        end // bypass FL
        188:
        begin
            out_binaType = TU;
        end // sao_offset_abs
        189:
        begin
            out_binaType = TU;
            out_cMax = 2;
        end // mpm_idx
        190:
        begin
            out_binaType = EG1;
        end // abs_mvd_minus2
        191:
        begin
            out_binaType = CREG;
        end // coeff_abs_level_remaining

        default:
            ;
        /*begin
         if(rdy) begin 
          $display ("Error: illegal in_ctxIdx (%0d) @ %0d ns", in_ctxIdx, $time);
                #1 $stop;
        end
            //out_binaType = 'hX;
            //out_cMax = in_cMax;
        end    */
    endcase
    if(in_cMax == 0)
        out_cMax = 0;
end








endmodule



