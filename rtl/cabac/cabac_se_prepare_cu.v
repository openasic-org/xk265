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
// Filename       : cabac_se_prepare_cu.v
// Author         : liwei
// Created        : 2017/12/20
// Description    : syntax elements in CU
// DATA & EDITION:  2017/12/20  1.0     liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module cabac_se_prepare_cu(
           // input
           clk                      ,
           rst_n                    ,
           cu_start_i               ,
           cu_idx_i                 ,
           cu_depth_i               ,
           cu_split_transform_i     ,
           cu_slice_type_i          ,
           cu_skip_flag_i           ,
           cu_part_size_i           ,
           cu_merge_flag_i          ,
           cu_merge_idx_i           ,
           cu_luma_pred_mode_i      ,
           cu_cbf_y_i               ,
           cu_cbf_u_i               ,
           cu_cbf_v_i               ,
           cu_skip_top_flag_i       ,
           cu_skip_left_flag_i      ,
           cu_luma_pred_top_mode_i  ,
           cu_luma_pred_left_mode_i ,
           tq_rdata_i               ,
           cu_mv_data_i             ,
           cu_qp_i                  ,
           cu_qp_last_i             ,
           cu_qp_no_coded_i         ,

           // output
           cu_done_o                ,
           coeff_type_o             ,
           tq_ren_o                 ,
           tq_raddr_o               ,
           cu_qp_coded_flag_o       ,

           cu_syntax_element_0_o    ,
           cu_syntax_element_1_o    ,
           cu_syntax_element_2_o    ,
           cu_syntax_element_3_o
       );
//-----------------------------------------------------------------------------------------------------------------------------
//
//                                input signals and output signals
//
//-----------------------------------------------------------------------------------------------------------------------------
input                               clk                     ; // clock signal
input                               rst_n                   ; // reset signal, low active
input                               cu_start_i              ; // cabac start signal, pulse signal
input  [ 6:0]                       cu_idx_i                ;
input  [ 1:0]                       cu_depth_i              ; // cu_depth,0:64x64,1:32x32,2:16x16,3:8x8
input                               cu_split_transform_i    ;
input                               cu_slice_type_i         ; // slice type, (`SLICE_TYPE_I):1, (`SLICE_TYPE_P):0
input                               cu_skip_flag_i          ;
input  [ 1:0]                       cu_part_size_i          ; // inter part size
input                               cu_merge_flag_i         ;
input  [ 3:0]                       cu_merge_idx_i          ;
input  [5:0]                       cu_luma_pred_mode_i     ;
input  [ 3:0]                       cu_cbf_y_i              ;
input  [ 3:0]                       cu_cbf_u_i              ;
input  [ 3:0]                       cu_cbf_v_i              ;
input                               cu_skip_top_flag_i      ;
input                               cu_skip_left_flag_i     ;
input  [23:0]                       cu_luma_pred_top_mode_i ;
input  [23:0]                       cu_luma_pred_left_mode_i;
input  [`COEFF_WIDTH*16-1:0]        tq_rdata_i              ; // coeff data tq read data
input  [(4*`MVD_WIDTH+5):0]         cu_mv_data_i            ; // Inter mvd read data
input  [5:0]                        cu_qp_i                 ;
input  [5:0]                        cu_qp_last_i            ;
input                               cu_qp_no_coded_i        ;

output                              cu_done_o               ;
output  [1:0]                       coeff_type_o            ;
output                              tq_ren_o                ; // coeff data tq read enable
output [8:0]                        tq_raddr_o              ; // coeff data tq read address
output                              cu_qp_coded_flag_o      ;

output  [22:0]                      cu_syntax_element_0_o   ;
output  [22:0]                      cu_syntax_element_1_o   ;
output  [14:0]                      cu_syntax_element_2_o   ;
output  [14:0]                      cu_syntax_element_3_o   ;

reg     [22:0]                      cu_syntax_element_0_o   ;
reg     [22:0]                      cu_syntax_element_1_o   ;
reg     [14:0]                      cu_syntax_element_2_o   ;
reg     [14:0]                      cu_syntax_element_3_o   ;

//-----------------------------------------------------------------------------------------------------------------------------
//
//             controller signals   wire declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
wire                                state_intra_w                              ;
wire                                state_tree_w                               ;
wire                                state_skip_w                               ;
wire                                state_merge_w                              ;
wire                                state_inter_tree_w                         ;
wire                                cu_tree_done_w                             ;
wire       [1:0]                    coeff_type_w                               ;
wire                                rqt_root_cbf_w                             ;
wire                                cu_tree_done_flag_w                        ;
reg        [3:0]                    cu_cnt_r                                   ;
reg                                 tree_start_r                               ;// (intra || state_inter_tree_w )&&cu_start_i
reg                                 num_pu_flag_r                              ;//1: 2 sub pu , 0 :1 sub pu

assign          state_intra_w       =   cu_slice_type_i  ==  `SLICE_TYPE_I     ;
assign          state_skip_w        =   cu_skip_flag_i                         ;
assign          state_merge_w       =   cu_merge_flag_i                        ;
assign          state_inter_tree_w  =   !(cu_merge_flag_i && (cu_part_size_i!=0));
assign          state_tree_w        =   (state_intra_w||state_inter_tree_w)    ;

always @*
begin
    if(cu_slice_type_i)  // I frame
        num_pu_flag_r    = (cu_depth_i==2'b11) ? cu_split_transform_i  : 1'b0   ;
    else // P frame
        num_pu_flag_r    = (cu_part_size_i[0] ^ cu_part_size_i[1]   )           ;
end

//-----------------------------------------------------------------------------------------------------------------------------
//
//            a cnt to controller the output
//
//-----------------------------------------------------------------------------------------------------------------------------


assign    rqt_root_cbf_w      = (cu_cbf_y_i!=0)||(cu_cbf_u_i!=0)||(cu_cbf_v_i!=0)             ;
assign    cu_tree_done_flag_w = cu_tree_done_w || !(cu_slice_type_i || rqt_root_cbf_w) ;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_cnt_r       <=        4'd0                                          ;
    else if(cu_start_i)
        cu_cnt_r       <=        4'd1                                          ;
    else if((cu_tree_done_flag_w || !state_tree_w || state_skip_w)&&cu_cnt_r==4'd11)
        cu_cnt_r      <=         4'd15                                         ;
    else if ( ((state_intra_w||state_skip_w||state_merge_w )&& cu_cnt_r==4'd4 ))
        cu_cnt_r      <=         4'd10                                         ; // tree_start_r
    else if( (num_pu_flag_r&&cu_cnt_r==4'd9)||(!num_pu_flag_r&&cu_cnt_r==4'd5) )
        cu_cnt_r      <=         4'd10                                         ;
    else if(cu_cnt_r!=4'd11&&(cu_cnt_r!=0))
        cu_cnt_r      <=        cu_cnt_r + 1'd1                               ; // tree out
end



//-----------------------------------------------------------------------------------------------------------------------------
//
//            wire signals declaration
//
//-----------------------------------------------------------------------------------------------------------------------------
//  signal declaration
// CU_INTRA
wire [20:0]                      se_pair_intra_0_w        ;
wire [20:0]                      se_pair_intra_1_w        ;
wire [20:0]                      se_pair_intra_2_w        ;
wire [20:0]                      se_pair_intra_3_w        ;
wire [20:0]                      se_pair_intra_4_w        ;
wire [20:0]                      se_pair_intra_5_w        ;
wire [20:0]                      se_pair_intra_6_w        ;
wire [20:0]                      se_pair_intra_7_w        ;
wire [20:0]                      se_pair_intra_8_w        ;
wire [20:0]                      se_pair_intra_9_w        ;
// CU_SKIP
wire [20:0]                      se_pair_skip_w           ;
//pred_mode_flag
wire [20:0]                      se_pair_pred_mode_flag_w ;
//inter part_size
reg  [20:0]                      se_pair_part_size_0_r    ;
// 4 groups :merge flag , merge idx or mvd
// merge flag
wire [20:0]                      se_pair_merge_flag_0_w   ;

// merge idx
wire [20:0]                      se_pair_merge_idx_w   ;

// CU_MVD
wire [22:0]                      se_pair_mv_0_0_w         ;
wire [22:0]                      se_pair_mv_0_1_w         ;
wire [22:0]                      se_pair_mv_0_2_w         ;
wire [22:0]                      se_pair_mv_0_3_w         ;
wire [22:0]                      se_pair_mv_0_4_w         ;
wire [22:0]                      se_pair_mv_0_5_w         ;
wire [22:0]                      se_pair_mv_0_6_w         ;
wire [22:0]                      se_pair_mv_0_7_w         ;
wire [14:0]                      se_pair_mv_0_8_w         ;

wire [22:0]                      se_pair_mv_1_0_w         ;
wire [22:0]                      se_pair_mv_1_1_w         ;
wire [22:0]                      se_pair_mv_1_2_w         ;
wire [22:0]                      se_pair_mv_1_3_w         ;
wire [22:0]                      se_pair_mv_1_4_w         ;
wire [22:0]                      se_pair_mv_1_5_w         ;
wire [22:0]                      se_pair_mv_1_6_w         ;
wire [22:0]                      se_pair_mv_1_7_w         ;
wire [14:0]                      se_pair_mv_1_8_w         ;

// RQT_ROOT_CBF
reg  [20:0]                      se_pair_rqt_root_cbf_r   ;

// CU_TREE
wire [22:0]                      se_pair_tree_0_w         ;
wire [22:0]                      se_pair_tree_1_w         ;
wire [20:0]                      se_pair_tree_2_w         ;
wire [20:0]                      se_pair_tree_3_w         ;

//-----------------------------------------------------------------------------------------------------------------------------
//
//               syntax  elements  binarization
//
//-----------------------------------------------------------------------------------------------------------------------------

// ------------------------------------
// CU_INTRA
cabac_se_prepare_intra  cabac_se_prepare_intra_u0(
                            // input
                            .cu_depth_i              (cu_depth_i              ),
                            .cu_sub_div_i            (cu_split_transform_i    ),
                            .cu_luma_pred_mode_i     (cu_luma_pred_mode_i     ),
                            //.cu_chroma_pred_mode_i   (cu_chroma_pred_mode_i   ),
                            .cu_luma_pred_left_mode_i(cu_luma_pred_left_mode_i),
                            .cu_luma_pred_top_mode_i (cu_luma_pred_top_mode_i ),
                            //  output
                            .se_pair_intra_0_o      (se_pair_intra_0_w      ),
                            .se_pair_intra_1_o      (se_pair_intra_1_w      ),
                            .se_pair_intra_2_o      (se_pair_intra_2_w      ),
                            .se_pair_intra_3_o      (se_pair_intra_3_w      ),
                            .se_pair_intra_4_o      (se_pair_intra_4_w      ),
                            .se_pair_intra_5_o      (se_pair_intra_5_w      ),
                            .se_pair_intra_6_o      (se_pair_intra_6_w      ),
                            .se_pair_intra_7_o      (se_pair_intra_7_w      ),
                            .se_pair_intra_8_o      (se_pair_intra_8_w      ),
                            .se_pair_intra_9_o      (se_pair_intra_9_w      )
                        );

// ------------------------------------
// CU_SKIP
wire [ 8:0]                      se_cu_skip_idx_w        ;

assign  se_cu_skip_idx_w   =    cu_skip_left_flag_i  +  cu_skip_top_flag_i + 2'b11 ;
assign  se_pair_skip_w  =  {7'h00,cu_skip_flag_i,4'h1,se_cu_skip_idx_w};

//-------------------------------------
//pred_mode_flag,P frame may have I type CU

assign se_pair_pred_mode_flag_w = {7'h00,cu_slice_type_i,4'h1,9'h00d};

//-------------------------------------
//inter part_size
always @*
begin
    case(cu_part_size_i) //0:2Nx2N 1:2NxN  2:Nx2N
        `PART_2NX2N:
            se_pair_part_size_0_r = {8'h00,4'h2,9'h008};
        `PART_2NXN :
            se_pair_part_size_0_r = {8'h01,4'h2,9'h008};
        `PART_NX2N :
            se_pair_part_size_0_r = {8'h02,4'h2,9'h008};
        `PART_SPLIT:
            se_pair_part_size_0_r = {8'h03,4'h2,9'h008};
    endcase
end

//------------------------------------
// merge flag
assign   se_pair_merge_flag_0_w  = {7'h00,cu_merge_flag_i,4'h1,9'h006};

//------------------------------------
// merge idx
wire   [3:0]    merge_idx_w  =   cu_merge_idx_i  ;


assign    se_pair_merge_idx_w  =  {4'h0,merge_idx_w,4'h4,9'h007}                 ;


// ------------------------------------
// CU_MVD

cabac_se_prepare_mv   cabac_se_prepare_mv_u0(
                          .cu_mv_data_i        (  cu_mv_data_i       ),
                          .se_pair_mv_0_0_o   ( se_pair_mv_0_0_w   ),
                          .se_pair_mv_0_1_o   ( se_pair_mv_0_1_w   ),
                          .se_pair_mv_0_2_o   ( se_pair_mv_0_2_w   ),
                          .se_pair_mv_0_3_o   ( se_pair_mv_0_3_w   ),
                          .se_pair_mv_0_4_o   ( se_pair_mv_0_4_w   ),
                          .se_pair_mv_0_5_o   ( se_pair_mv_0_5_w   ),
                          .se_pair_mv_0_6_o   ( se_pair_mv_0_6_w   ),
                          .se_pair_mv_0_7_o   ( se_pair_mv_0_7_w   ),
                          .se_pair_mv_0_8_o   ( se_pair_mv_0_8_w   ),

                          .se_pair_mv_1_0_o   ( se_pair_mv_1_0_w   ),
                          .se_pair_mv_1_1_o   ( se_pair_mv_1_1_w   ),
                          .se_pair_mv_1_2_o   ( se_pair_mv_1_2_w   ),
                          .se_pair_mv_1_3_o   ( se_pair_mv_1_3_w   ),
                          .se_pair_mv_1_4_o   ( se_pair_mv_1_4_w   ),
                          .se_pair_mv_1_5_o   ( se_pair_mv_1_5_w   ),
                          .se_pair_mv_1_6_o   ( se_pair_mv_1_6_w   ),
                          .se_pair_mv_1_7_o   ( se_pair_mv_1_7_w   ),
                          .se_pair_mv_1_8_o   ( se_pair_mv_1_8_w   )
                      );

//-------------------------------------
//  RQT_ROOT_CBF
always @*
begin
    if(state_inter_tree_w)
        se_pair_rqt_root_cbf_r =      {7'h00,rqt_root_cbf_w,4'h1,9'h027}        ;
    else
        se_pair_rqt_root_cbf_r =      0                      ;
end

// -----------------------------------
// CU_TREE
//assign    tree_start_r  =  cu_curr_state_r == CU_TREE &&(cu_slice_type_i || rqt_root_cbf_w);
//assign    tree_start_w  =  cu_start_i&&(cu_slice_type_i || rqt_root_cbf_w);
//wire      tree_start_w  =  cu_curr_state_r == CU_TREE &&(cu_slice_type_i || rqt_root_cbf_w);

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tree_start_r   <=   1'b0                                               ;
    else if( (cu_cnt_r==4'd10)&&(cu_slice_type_i || rqt_root_cbf_w)&& !state_skip_w)            // intra ||(inter && rqt_root_cbf_w)
        tree_start_r   <=   1'b1                                               ;
    else if(tree_start_r)
        tree_start_r   <=   1'b0                                               ;
end

cabac_se_prepare_tu   cabac_se_prepare_tu_u0(
                          .clk                          ( clk                        ),
                          .rst_n                        ( rst_n                      ),
                          .cu_idx_i                     ( cu_idx_i                   ),
                          .tree_start_i                 ( tree_start_r               ),
                          .cu_depth_i                   ( cu_depth_i                 ),
                          .cu_split_transform_i         ( cu_split_transform_i       ),
                          .cu_slice_type_i              ( cu_slice_type_i            ),
                          .cu_cbf_y_i                   ( cu_cbf_y_i                 ),
                          .cu_cbf_u_i                   ( cu_cbf_u_i                 ),
                          .cu_cbf_v_i                   ( cu_cbf_v_i                 ),
                          .tq_rdata_i                   ( tq_rdata_i                 ),
                          .cu_luma_pred_mode_i          ( cu_luma_pred_mode_i        ),
                          .cu_qp_i                      ( cu_qp_i                    ),
                          .cu_qp_last_i                 ( cu_qp_last_i               ),
                          .cu_qp_no_coded_i             ( cu_qp_no_coded_i           ),

                          .cu_tree_done_o               ( cu_tree_done_w             ),
                          .coeff_type_o                 ( coeff_type_w               ),
                          .tq_ren_o                  ( tq_ren_o                   ),
                          .tq_raddr_o                    ( tq_raddr_o                 ),
                          .cu_qp_coded_flag_o           ( cu_qp_coded_flag_o         ),
                          .se_pair_tree_0_o             ( se_pair_tree_0_w           ),
                          .se_pair_tree_1_o             ( se_pair_tree_1_w           ),
                          .se_pair_tree_2_o             ( se_pair_tree_2_w           ),
                          .se_pair_tree_3_o             ( se_pair_tree_3_w           )
                      );
//-----------------------------------------------------------------------------------------------------------------------------
//
//               output signals
//
//-----------------------------------------------------------------------------------------------------------------------------

reg  [22:0] se_pair_bism_0_r       ;
reg  [22:0] se_pair_bism_1_r       ;
reg  [22:0] se_pair_bism_2_r       ;
reg  [22:0] se_pair_bism_3_r       ;
reg  [22:0] se_pair_bism_4_r       ;
reg  [22:0] se_pair_bism_5_r       ;
reg  [22:0] se_pair_bism_6_r       ;
reg  [22:0] se_pair_bism_7_r       ;
reg  [22:0] se_pair_bism_8_r       ;
reg  [22:0] se_pair_bism_9_r       ;
reg  [22:0] se_pair_bism_10_r      ;
reg  [22:0] se_pair_bism_11_r      ;
reg  [22:0] se_pair_bism_12_r      ;
reg  [22:0] se_pair_bism_13_r      ;
reg  [22:0] se_pair_bism_14_r      ;
reg  [22:0] se_pair_bism_15_r      ;

always @*
begin
    if(state_intra_w)
    begin
        se_pair_bism_0_r        =    {2'b00,se_pair_intra_0_w} ;
        se_pair_bism_1_r        =    {2'b00,se_pair_intra_1_w} ;
        se_pair_bism_2_r        =    {2'b00,se_pair_intra_2_w} ;
        se_pair_bism_3_r        =    {2'b00,se_pair_intra_3_w} ;

        se_pair_bism_4_r        =    {2'b00,se_pair_intra_4_w} ;
        se_pair_bism_5_r        =    {2'b00,se_pair_intra_5_w} ;
        se_pair_bism_6_r        =    23'b0             ;
        se_pair_bism_7_r        =    23'b0             ;

        se_pair_bism_8_r        =    {2'b00,se_pair_intra_6_w} ;
        se_pair_bism_9_r        =    {2'b00,se_pair_intra_7_w} ;
        se_pair_bism_10_r       =    23'b0             ;
        se_pair_bism_11_r       =    23'b0             ;

        se_pair_bism_12_r       =    {2'b00,se_pair_intra_8_w} ;
        se_pair_bism_13_r       =    {2'b00,se_pair_intra_9_w} ;
        se_pair_bism_14_r       =    23'b0             ;
        se_pair_bism_15_r       =    23'b0             ;

    end
    else if(state_skip_w)
    begin
        se_pair_bism_0_r        =    {2'b00,se_pair_skip_w     };
        se_pair_bism_1_r        =    {2'b00,se_pair_merge_idx_w};
        se_pair_bism_2_r        =    23'b0              ;
        se_pair_bism_3_r        =    23'b0              ;

        se_pair_bism_4_r        =    23'b0              ;
        se_pair_bism_5_r        =    23'b0              ;
        se_pair_bism_6_r        =    23'b0              ;
        se_pair_bism_7_r        =    23'b0              ;

        se_pair_bism_8_r            =    23'b0              ;
        se_pair_bism_9_r            =    23'b0              ;
        se_pair_bism_10_r           =    23'b0              ;
        se_pair_bism_11_r           =    23'b0              ;

        se_pair_bism_12_r           =    23'b0              ;
        se_pair_bism_13_r           =    23'b0              ;
        se_pair_bism_14_r           =    23'b0              ;
        se_pair_bism_15_r           =    23'b0              ;
    end
    else if(state_merge_w)
    begin
        se_pair_bism_0_r        =    {2'b00,se_pair_skip_w}     ;
        se_pair_bism_1_r        =    {2'b00,se_pair_pred_mode_flag_w};
        se_pair_bism_2_r        =    23'b0              ;
        se_pair_bism_3_r        =    23'b0              ;

        se_pair_bism_4_r        =    {2'b00,se_pair_part_size_0_r };
        se_pair_bism_5_r        =    {2'b00,se_pair_merge_flag_0_w};
        se_pair_bism_6_r        =    23'b0              ;
        se_pair_bism_7_r        =    23'b0              ;


        se_pair_bism_8_r        =    {2'b00,se_pair_merge_idx_w};
        se_pair_bism_9_r        =    23'b0              ;
        se_pair_bism_10_r       =    23'b0              ;
        se_pair_bism_11_r       =    23'b0              ;

        se_pair_bism_12_r       =    23'b0              ;
        se_pair_bism_13_r       =    23'b0              ;
        se_pair_bism_14_r       =    23'b0              ;
        se_pair_bism_15_r       =    23'b0              ;


    end
    else
    begin
        se_pair_bism_0_r        =    {2'b00,se_pair_skip_w          };
        se_pair_bism_1_r        =    {2'b00,se_pair_pred_mode_flag_w};
        se_pair_bism_2_r        =    23'b0                   ;
        se_pair_bism_3_r        =    23'b0                   ;

        se_pair_bism_4_r        =    {2'b00,se_pair_part_size_0_r } ;
        se_pair_bism_5_r        =    {2'b00,se_pair_merge_flag_0_w} ;
        se_pair_bism_6_r        =    se_pair_mv_0_0_w ;
        se_pair_bism_7_r        =    se_pair_mv_0_1_w ;


        se_pair_bism_8_r        =   se_pair_mv_0_2_w;
        se_pair_bism_9_r        =   se_pair_mv_0_3_w;
        se_pair_bism_10_r       =   23'b0           ;
        se_pair_bism_11_r       =   23'b0           ;

        se_pair_bism_12_r       =   se_pair_mv_0_4_w;
        se_pair_bism_13_r       =   se_pair_mv_0_6_w;
        se_pair_bism_14_r       =   23'b0;
        se_pair_bism_15_r       =   23'b0;

    end
end

assign cu_done_o             =  cu_cnt_r==4'd15 ;
assign coeff_type_o          =  coeff_type_w    ;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        cu_syntax_element_0_o <=  23'b0 ;
        cu_syntax_element_1_o <=  23'b0 ;
        cu_syntax_element_2_o <=  15'b0 ;
        cu_syntax_element_3_o <=  15'b0 ;
    end
    else
    begin
        case(cu_cnt_r)
            4'd1:
            begin
                cu_syntax_element_0_o <=  se_pair_bism_0_r;
                cu_syntax_element_1_o <=  se_pair_bism_1_r;
                cu_syntax_element_2_o <=  se_pair_bism_2_r[14:0];
                cu_syntax_element_3_o <=  se_pair_bism_3_r[14:0];
            end
            4'd2:
            begin
                cu_syntax_element_0_o <=  se_pair_bism_4_r;
                cu_syntax_element_1_o <=  se_pair_bism_5_r;
                cu_syntax_element_2_o <=  se_pair_bism_6_r[14:0];
                cu_syntax_element_3_o <=  se_pair_bism_7_r[14:0];
            end
            4'd3:
            begin
                cu_syntax_element_0_o <=  se_pair_bism_8_r;
                cu_syntax_element_1_o <=  se_pair_bism_9_r;
                cu_syntax_element_2_o <=  se_pair_bism_10_r[14:0];
                cu_syntax_element_3_o <=  se_pair_bism_11_r[14:0];
            end
            4'd4:
            begin
                cu_syntax_element_0_o <=  se_pair_bism_12_r;
                cu_syntax_element_1_o <=  se_pair_bism_13_r;
                cu_syntax_element_2_o <=  se_pair_bism_14_r[14:0];
                cu_syntax_element_3_o <=  se_pair_bism_15_r[14:0];
            end
            4'd5:
            begin
                cu_syntax_element_0_o <=  se_pair_mv_0_5_w;
                cu_syntax_element_1_o <=  se_pair_mv_0_7_w;
                cu_syntax_element_2_o <=  se_pair_mv_0_8_w;
                cu_syntax_element_3_o <=  num_pu_flag_r ? se_pair_merge_flag_0_w[14:0]  :  se_pair_rqt_root_cbf_r[14:0] ;
            end
            4'd6:
            begin
                cu_syntax_element_0_o <=  se_pair_mv_1_0_w ;
                cu_syntax_element_1_o <=  se_pair_mv_1_1_w ;
                cu_syntax_element_2_o <=  15'b0            ;
                cu_syntax_element_3_o <=  15'b0            ;
            end
            4'd7:
            begin
                cu_syntax_element_0_o <=  se_pair_mv_1_2_w ;
                cu_syntax_element_1_o <=  se_pair_mv_1_3_w ;
                cu_syntax_element_2_o <=  15'b0            ;
                cu_syntax_element_3_o <=  15'b0            ;
            end
            4'd8:
            begin
                cu_syntax_element_0_o <=  se_pair_mv_1_4_w ;
                cu_syntax_element_1_o <=  se_pair_mv_1_6_w ;
                cu_syntax_element_2_o <=   15'b0;
                cu_syntax_element_3_o <=   15'b0;
            end
            4'd9:
            begin
                cu_syntax_element_0_o <=   se_pair_mv_1_5_w;
                cu_syntax_element_1_o <=   se_pair_mv_1_7_w;
                cu_syntax_element_2_o <=   se_pair_mv_1_8_w;
                cu_syntax_element_3_o <=   se_pair_rqt_root_cbf_r[14:0];
            end
            4'd11:
            begin
                cu_syntax_element_0_o <=  se_pair_tree_0_w;
                cu_syntax_element_1_o <=  se_pair_tree_1_w;
                cu_syntax_element_2_o <=  se_pair_tree_2_w[14:0] ;
                cu_syntax_element_3_o <=  se_pair_tree_3_w[14:0] ;
            end
            default:
            begin
                cu_syntax_element_0_o <=   23'b0;
                cu_syntax_element_1_o <=   23'b0;
                cu_syntax_element_2_o <=   15'b0;
                cu_syntax_element_3_o <=   15'b0;
            end
        endcase
    end
end

endmodule





