//------------------------------------------------------------
//
//  File Name       : fme_skip.v
//  Author          : TANG 
//  Date            : 2018-06-11
//  Description     : support skip and merge
//
//-------------------------------------------------------------
//  Note : This module is prepared for full SKIP in the begining, so the FMS is complete.
//       : Besieds, the skip_fmv_o is 0 in SKIP00 mode, so there is no need to output. 
//       : The skip_idx and skip_flag are generated at different state
//
//-----------------------------------------------------------

`include "enc_defines.v"

module fme_skip(
        clk                 ,
        rstn                ,
        // skip thresh
        skip_cost_thresh_08 ,
        skip_cost_thresh_16 ,
        skip_cost_thresh_32 ,
        skip_cost_thresh_64 ,
        // cfg
        lambda              ,
        curr_state_i        ,
        fme_skip_start_i    ,
        fme_skip_done_o     ,
        // cur if
        cur_rd_ena_o        ,
        cur_4x4_idx_o       ,
        cur_4x4_x_o         ,
        cur_4x4_y_o         ,
        cur_pel_i           ,
        // fmv wr
        fmv_wr_ena_o        ,
        fmv_wr_adr_o        ,
        fmv_wr_dat_o        ,
        // skip prediction 
        pre_val_i           ,
        pre_pxl_i           ,
        // position
        cu_mod_i            ,
        pu_pos_x_i          ,
        pu_pos_y_i          ,
        pu_wid_i            ,
        pu_hgt_i            ,
        pu_blk_i            ,
        pu_8x8_adr_i        ,
        pu_blk_num_i        ,
        // mv candidates
        fmv_candi_rdy_i     ,
        mv_a0_val_i         ,
        mv_a1_val_i         ,
        mv_b0_val_i         ,
        mv_b1_val_i         ,
        mv_b2_val_i         ,
        mv_a0_dat_i         ,
        mv_a1_dat_i         ,
        mv_b0_dat_i         ,
        mv_b1_dat_i         ,
        mv_b2_dat_i         ,
        // fme best cost
        fme_cst_rd_ena_o    ,
        fme_cst_rd_adr_o    ,
        fme_cst_rd_dat_i    ,
        // cost output
        fme_cst_sum_o       ,
        // pu if
        skip_pu_start_i     ,
        // blk if 
        skip_blk_start_i    ,
        // output info
        skip_idx_o          ,
        skip_flg_o          ,
        // for mc
        mc_skip_flg_o       
        );


//---- parameter declaration -----------------------------------
    // localparam  SKIP_COST_THRESH_8  = 4000    ;
    // localparam  SKIP_COST_THRESH_16 = 14000   ;
    // localparam  SKIP_COST_THRESH_32 = 49000   ;
    // localparam  SKIP_COST_THRESH_64 = 171500  ;

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

    localparam  IDLE = 0,
                MV_0 = 1,
                MV_1 = 2, 
                MV_2 = 3, 
                MV_3 = 4;

    localparam  COST_MAX = 1 << `FME_COST_WIDTH ;

    localparam  CU_64 = 0 ,
                CU_32 = 1 ,
                CU_16 = 2 ,
                CU_08 = 3 ;
//---- input / output declaration ------------------------------
    // global
    input                           clk                 ;
    input                           rstn                ;
    // skip cost threshhold 
    input   [32-1:0]                skip_cost_thresh_08 ;
    input   [32-1:0]                skip_cost_thresh_16 ;
    input   [32-1:0]                skip_cost_thresh_32 ;
    input   [32-1:0]                skip_cost_thresh_64 ;

    input   [7-1:0]                 lambda              ;
    // skip ctrl        
    input   [4-1:0]                 curr_state_i        ;
    input                           fme_skip_start_i    ;
    output                          fme_skip_done_o     ;
    // cur pixel        
    output                          cur_rd_ena_o        ;
    output  [5-1:0]                 cur_4x4_idx_o       ;
    output  [4-1:0]                 cur_4x4_x_o         ;
    output  [4-1:0]                 cur_4x4_y_o         ;
    input   [32*`PIXEL_WIDTH-1:0]   cur_pel_i           ;
    // fmv if
    output                          fmv_wr_ena_o        ;
    output  [6-1:0]                 fmv_wr_adr_o        ;
    output  [2*`FMV_WIDTH-1:0]      fmv_wr_dat_o        ;
    // prediction
    input                           pre_val_i           ;
    input   [8*`PIXEL_WIDTH-1:0]    pre_pxl_i           ;
    // position     
    input   [2-1:0]                 cu_mod_i            ;
    input   [3-1:0]                 pu_pos_x_i          ;
    input   [3-1:0]                 pu_pos_y_i          ;
    input   [4-1:0]                 pu_wid_i            ;
    input   [4-1:0]                 pu_hgt_i            ;
    input                           pu_blk_i            ;
    input   [6-1:0]                 pu_8x8_adr_i        ;
    input   [7-1:0]                 pu_blk_num_i        ;
    // mv candidates
    input                           fmv_candi_rdy_i     ;
    input                           mv_a0_val_i         ;
    input                           mv_a1_val_i         ;
    input                           mv_b0_val_i         ;
    input                           mv_b1_val_i         ;
    input                           mv_b2_val_i         ;
    input   [2*`FMV_WIDTH-1:0]      mv_a0_dat_i         ;
    input   [2*`FMV_WIDTH-1:0]      mv_a1_dat_i         ;
    input   [2*`FMV_WIDTH-1:0]      mv_b0_dat_i         ;
    input   [2*`FMV_WIDTH-1:0]      mv_b1_dat_i         ;
    input   [2*`FMV_WIDTH-1:0]      mv_b2_dat_i         ;
    // fme cost
    output                          fme_cst_rd_ena_o    ;
    output  [6-1:0]                 fme_cst_rd_adr_o    ;
    input   [`FME_COST_WIDTH-1:0]   fme_cst_rd_dat_i    ;
    // pu if
    input                           skip_pu_start_i     ;
    // 8x8 block ctrl 
    input                           skip_blk_start_i    ;
    // output info
    output  [85*4-1:0]              skip_idx_o         ;
    output  [85-1:0]                skip_flg_o         ;
    // cost 
    output  [`FME_COST_WIDTH-1:0]   fme_cst_sum_o       ;
    // for mc
    output                          mc_skip_flg_o       ;


//---- wire /reg declaration -----------------------------------
    // mv candidates valid
    reg                             mv_candi_a1_val_r   ;
    reg                             mv_candi_b1_val_r   ;
    reg                             mv_candi_b0_val_r   ;
    reg                             mv_candi_a0_val_r   ;
    reg                             mv_candi_b2_val_r   ;

    wire    [5-1:0]                 mv_val_w            ;
    // valid mv
    reg     [2*`FMV_WIDTH-1:0]      mv_dat_0_w          ;
    reg     [2*`FMV_WIDTH-1:0]      mv_dat_1_w          ;
    reg     [2*`FMV_WIDTH-1:0]      mv_dat_2_w          ;
    reg     [2*`FMV_WIDTH-1:0]      mv_dat_3_w          ;
    reg     [2*`FMV_WIDTH-1:0]      mv_dat_4_w          ;
    reg                             mv_val_0_w          ;
    reg                             mv_val_1_w          ;
    reg                             mv_val_2_w          ;
    reg                             mv_val_3_w          ;
    reg                             mv_val_4_w          ;
    // cur pixel
    wire    [4-1:0]                 cur_4x4_x_o         ;
    wire    [4-1:0]                 cur_4x4_y_o         ;
    wire    [5-1:0]                 cur_4x4_idx_o       ;
    wire                            cur_rd_ena_o        ;
    reg     [32*`PIXEL_WIDTH-1:0]   cur_blk_0           ;
    reg     [32*`PIXEL_WIDTH-1:0]   cur_blk_1           ;
    reg     [8*`PIXEL_WIDTH-1:0]    cur_pxl_w           ;
    // ctrl 

    reg     [2-1:0]                 cu_mod_d1     , cu_mod_d2     ;
    reg     [3-1:0]                 pu_pos_x_d1   , pu_pos_x_d2   ;
    reg     [3-1:0]                 pu_pos_y_d1   , pu_pos_y_d2   ;
    reg     [4-1:0]                 pu_hgt_d1     , pu_hgt_d2     ;
    reg     [4-1:0]                 pu_wid_d1     , pu_wid_d2     ;
    reg     [6-1:0]                 pu_8x8_adr_d1 , pu_8x8_adr_d2 ;
    reg     [7-1:0]                 pu_blk_num_d1 , pu_blk_num_d2 ;
    // reg     [4-1:0]                 skip_idx_d1   , skip_idx_d2   ;
    // delay 
    reg                             start_d1            ;
    reg                             start_d2            ;
    // satd
    wire    [`PIXEL_WIDTH+10-1:0]   skip_satd           ;
    wire                            skip_satd_vld_w     ;
    // skip fmv
    wire signed [`FMV_WIDTH-1:0]    skip_fmv_x          ;
    wire signed [`FMV_WIDTH-1:0]    skip_fmv_y          ;
    wire        [`FMV_WIDTH-1:0]    skip_fmv_x_abs      ;
    wire        [`FMV_WIDTH-1:0]    skip_fmv_y_abs      ;
    // bits
    wire        [6-1:0]             skip_fmv_x_bit      ;
    wire        [6-1:0]             skip_fmv_y_bit      ;
    // wire        [6-1:0]             skip_idx_bit        ;
    wire        [6-1:0]             skip_flag_bit       ;
    wire        [8-1:0]             bitrate             ;
    // cost
    reg     [`FME_COST_WIDTH-1:0]   cost_mv0_sum        ;
    wire    [`FME_COST_WIDTH-1:0]   cost_mv0_sum_r      ;
    // fme best cost
    reg                             fme_cst_rd_ena_o    ;
    reg     [6-1:0]                 fme_cst_rd_adr_o    ;
    // merge 
    reg     [4-1:0]                 skip_idx_r          ;
    reg     [`FME_COST_WIDTH-1:0]   fme_cst_sum_o       ;
    // blk count
    reg     [7-1:0]                 blk_cnt_r           ;
    // skip cost
    reg     [32-1:0]   skip_min_cost       ;
    wire    [`FME_COST_WIDTH-1:0]   min_cost_w          ;
    // flag
    reg                             skip_cu_flag_r      ;
    wire                            skip_cu_flag        ;
    // mv dump 
    reg                             fmv_wr_ena_r        ;
    reg     [2*`FMV_WIDTH-1:0]      fmv_wr_dat_o        ;
    wire    [6-1:0]                 fmv_wr_adr_o        ;
    reg     [3-1:0]                 fmv_wr_x_r          ;
    reg     [3-1:0]                 fmv_wr_y_r          ;
    reg     [4-1:0]                 mv_wr_x_cnt         ;
    reg     [4-1:0]                 mv_wr_y_cnt         ;
    wire                            fmv_wr_ena_o        ;

    wire    [85*4-1:0]              skip_idx_o          ;
    wire    [85-1:0]                skip_flg_o          ;

    reg                             fme_skip_done_o     ;

    wire    [6-1:0]                 pu_zz_adr_w         ;

    reg                             cost_done_r         ;

    reg                             fmv_wr_done_r       ;

    reg                             pre_done_r          ;

    wire    [5-1:0]                 mv_dat_val_w        ;
    wire    [5-1:0]                 mv_00_val_w        ;
    wire                            mv_00_0_val_w      ;
    wire                            mv_00_1_val_w      ;
    wire                            mv_00_2_val_w      ;
    wire                            mv_00_3_val_w      ;
    wire                            mv_00_4_val_w      ; 

    reg     [4-1:0]                 pre_cnt_r           ;
    wire    [3-1:0]                 pre_cnt_w           ;
    wire                            pre_val_w           ;

    reg     [4-1:0]   skip_idx_64_r    
                     ,skip_idx_32_00_r, skip_idx_32_01_r, skip_idx_32_02_r, skip_idx_32_03_r 
                     ,skip_idx_16_00_r, skip_idx_16_01_r, skip_idx_16_02_r, skip_idx_16_03_r
                     ,skip_idx_16_04_r, skip_idx_16_05_r, skip_idx_16_06_r, skip_idx_16_07_r
                     ,skip_idx_16_08_r, skip_idx_16_09_r, skip_idx_16_10_r, skip_idx_16_11_r
                     ,skip_idx_16_12_r, skip_idx_16_13_r, skip_idx_16_14_r, skip_idx_16_15_r 
                     ,skip_idx_08_00_r, skip_idx_08_01_r, skip_idx_08_02_r, skip_idx_08_03_r 
                     ,skip_idx_08_04_r, skip_idx_08_05_r, skip_idx_08_06_r, skip_idx_08_07_r 
                     ,skip_idx_08_08_r, skip_idx_08_09_r, skip_idx_08_10_r, skip_idx_08_11_r 
                     ,skip_idx_08_12_r, skip_idx_08_13_r, skip_idx_08_14_r, skip_idx_08_15_r 
                     ,skip_idx_08_16_r, skip_idx_08_17_r, skip_idx_08_18_r, skip_idx_08_19_r 
                     ,skip_idx_08_20_r, skip_idx_08_21_r, skip_idx_08_22_r, skip_idx_08_23_r 
                     ,skip_idx_08_24_r, skip_idx_08_25_r, skip_idx_08_26_r, skip_idx_08_27_r 
                     ,skip_idx_08_28_r, skip_idx_08_29_r, skip_idx_08_30_r, skip_idx_08_31_r 
                     ,skip_idx_08_32_r, skip_idx_08_33_r, skip_idx_08_34_r, skip_idx_08_35_r 
                     ,skip_idx_08_36_r, skip_idx_08_37_r, skip_idx_08_38_r, skip_idx_08_39_r 
                     ,skip_idx_08_40_r, skip_idx_08_41_r, skip_idx_08_42_r, skip_idx_08_43_r 
                     ,skip_idx_08_44_r, skip_idx_08_45_r, skip_idx_08_46_r, skip_idx_08_47_r 
                     ,skip_idx_08_48_r, skip_idx_08_49_r, skip_idx_08_50_r, skip_idx_08_51_r 
                     ,skip_idx_08_52_r, skip_idx_08_53_r, skip_idx_08_54_r, skip_idx_08_55_r 
                     ,skip_idx_08_56_r, skip_idx_08_57_r, skip_idx_08_58_r, skip_idx_08_59_r 
                     ,skip_idx_08_60_r, skip_idx_08_61_r, skip_idx_08_62_r, skip_idx_08_63_r ;

    reg               skip_flg_64_r    
                     ,skip_flg_32_00_r, skip_flg_32_01_r, skip_flg_32_02_r, skip_flg_32_03_r 
                     ,skip_flg_16_00_r, skip_flg_16_01_r, skip_flg_16_02_r, skip_flg_16_03_r
                     ,skip_flg_16_04_r, skip_flg_16_05_r, skip_flg_16_06_r, skip_flg_16_07_r
                     ,skip_flg_16_08_r, skip_flg_16_09_r, skip_flg_16_10_r, skip_flg_16_11_r
                     ,skip_flg_16_12_r, skip_flg_16_13_r, skip_flg_16_14_r, skip_flg_16_15_r 
                     ,skip_flg_08_00_r, skip_flg_08_01_r, skip_flg_08_02_r, skip_flg_08_03_r 
                     ,skip_flg_08_04_r, skip_flg_08_05_r, skip_flg_08_06_r, skip_flg_08_07_r 
                     ,skip_flg_08_08_r, skip_flg_08_09_r, skip_flg_08_10_r, skip_flg_08_11_r 
                     ,skip_flg_08_12_r, skip_flg_08_13_r, skip_flg_08_14_r, skip_flg_08_15_r 
                     ,skip_flg_08_16_r, skip_flg_08_17_r, skip_flg_08_18_r, skip_flg_08_19_r 
                     ,skip_flg_08_20_r, skip_flg_08_21_r, skip_flg_08_22_r, skip_flg_08_23_r 
                     ,skip_flg_08_24_r, skip_flg_08_25_r, skip_flg_08_26_r, skip_flg_08_27_r 
                     ,skip_flg_08_28_r, skip_flg_08_29_r, skip_flg_08_30_r, skip_flg_08_31_r 
                     ,skip_flg_08_32_r, skip_flg_08_33_r, skip_flg_08_34_r, skip_flg_08_35_r 
                     ,skip_flg_08_36_r, skip_flg_08_37_r, skip_flg_08_38_r, skip_flg_08_39_r 
                     ,skip_flg_08_40_r, skip_flg_08_41_r, skip_flg_08_42_r, skip_flg_08_43_r 
                     ,skip_flg_08_44_r, skip_flg_08_45_r, skip_flg_08_46_r, skip_flg_08_47_r 
                     ,skip_flg_08_48_r, skip_flg_08_49_r, skip_flg_08_50_r, skip_flg_08_51_r 
                     ,skip_flg_08_52_r, skip_flg_08_53_r, skip_flg_08_54_r, skip_flg_08_55_r 
                     ,skip_flg_08_56_r, skip_flg_08_57_r, skip_flg_08_58_r, skip_flg_08_59_r 
                     ,skip_flg_08_60_r, skip_flg_08_61_r, skip_flg_08_62_r, skip_flg_08_63_r ;

    // for mc
    reg              mc_skip_flg_o ;
    // for idx output 
    reg             fmv_candi_rdy_d1 ;

//---- check mv candidate -------------------------------------
    /*
    *    ----     -------
    *    |B2|     |B1|B0|
    *    -------------------
    *       |        |
    *       |   PU   |
    *    ---|        |
    *    |A1|        |
    *    -------------
    *    |A0|
    *    ----
    * A1 -> B1 -> B0 -> A0 -> (B2)
    *
    */

    // a1 
    always @* begin 
        mv_candi_a1_val_r = 0 ;
        if ( skip_pu_start_i )
            mv_candi_a1_val_r = 0;
        else if (      mv_a1_val_i 
                && ( !((pu_hgt_i==2*pu_wid_i) && pu_blk_i == 1) ) // PART_NX2N
                )
            mv_candi_a1_val_r = 1;
    end 

    // b1  
    always @* begin
        mv_candi_b1_val_r = 0 ;
        if ( skip_pu_start_i )
            mv_candi_b1_val_r = 0 ;
        else if (      mv_b1_val_i 
                && ( !((2*pu_hgt_i==pu_wid_i) && pu_blk_i == 1) ) // PART_2NXN
                ) begin 
            if ( mv_a1_val_i && mv_b1_dat_i == mv_a1_dat_i )
                mv_candi_b1_val_r = 0;
            else 
                mv_candi_b1_val_r = 1;
        end 
    end 

    // b0
    always @* begin 
        mv_candi_b0_val_r = 0;
        if ( skip_pu_start_i )
            mv_candi_b0_val_r = 0 ;
        else if (mv_b0_val_i && mv_b1_val_i && mv_b0_dat_i == mv_b1_dat_i )
            mv_candi_b0_val_r = 0;
        else if ( mv_b0_val_i )
            mv_candi_b0_val_r = 1 ;
    end 

    // a0 
    always @* begin 
        mv_candi_a0_val_r = 0; 
        if (skip_pu_start_i )
            mv_candi_a0_val_r = 0;
        else if (mv_a0_val_i && mv_a1_val_i && mv_a0_dat_i == mv_a1_dat_i )
            mv_candi_a0_val_r = 0;
        else if ( mv_a0_val_i )
            mv_candi_a0_val_r = 1;
    end 

    // b2. It is used to reset A0 or B0.
    always @* begin 
        mv_candi_b2_val_r = 0;
        if (skip_pu_start_i )
            mv_candi_b2_val_r = 0;
        else if ( ! (mv_candi_a0_val_r && mv_candi_a1_val_r && mv_candi_b0_val_r && mv_candi_b1_val_r) )
            if (mv_b2_val_i && mv_a1_val_i && mv_b2_dat_i == mv_a1_dat_i )
                mv_candi_b2_val_r = 0;
            else if (mv_b2_val_i && mv_b1_val_i && mv_b2_dat_i == mv_b1_dat_i )
                mv_candi_b2_val_r = 0;
            else if ( mv_b2_val_i )
                mv_candi_b2_val_r = 1;
        else 
            mv_candi_b2_val_r = 0;
    end 
    
    // A1 -> B1 -> B0 -> A0 -> (B2)

    assign mv_val_w = {  mv_candi_a1_val_r
                        ,mv_candi_b1_val_r
                        ,mv_candi_b0_val_r
                        ,mv_candi_a0_val_r 
                        ,mv_candi_b2_val_r} ;

    // valid mv 0
    always @* begin 
        mv_dat_0_w = 0 ;
        mv_val_0_w = 0 ;
        casez ( mv_val_w )
            5'b1???? : begin mv_dat_0_w = mv_a1_dat_i; mv_val_0_w = 1 ; end 
            5'b01??? : begin mv_dat_0_w = mv_b1_dat_i; mv_val_0_w = 1 ; end 
            5'b001?? : begin mv_dat_0_w = mv_b0_dat_i; mv_val_0_w = 1 ; end 
            5'b0001? : begin mv_dat_0_w = mv_a0_dat_i; mv_val_0_w = 1 ; end 
            5'b00001 : begin mv_dat_0_w = mv_b2_dat_i; mv_val_0_w = 1 ; end 
            5'b00000 : begin mv_dat_0_w = 0          ; mv_val_0_w = 1 ; end 
            default  : begin mv_dat_0_w = 0          ; mv_val_0_w = 0 ; end 
        endcase 
    end 

    always @* begin 
        mv_dat_1_w = 0 ;
        mv_val_1_w = 0 ;
        casez ( mv_val_w )
            5'b11??? : begin 
                    mv_dat_1_w = mv_b1_dat_i; mv_val_1_w = 1 ; 
                end 
            5'b101??, 5'b011?? : begin 
                    mv_dat_1_w = mv_b0_dat_i; mv_val_1_w = 1 ; 
                end 
            5'b1001?, 5'b0101?, 5'b0011?: begin 
                    mv_dat_1_w = mv_a0_dat_i; mv_val_1_w = 1 ; 
                end 
            5'b10001, 5'b01001, 5'b00101, 5'b00011 : begin 
                    mv_dat_1_w = mv_b2_dat_i; mv_val_1_w = 1 ; 
                end 
            5'b10000, 5'b01000, 5'b00100, 5'b00010, 5'b00001 : begin 
                    mv_dat_1_w = 0          ; mv_val_1_w = 1 ; 
                end 
            default  : begin 
                    mv_dat_1_w = 0          ; mv_val_1_w = 0 ; 
                end 
        endcase 
    end 

    always @* begin 
        mv_dat_2_w = 0 ;
        mv_val_2_w = 0 ;
        casez ( mv_val_w )
            5'b111?? : begin 
                    mv_dat_2_w = mv_b0_dat_i; mv_val_2_w = 1 ; 
                end 
            5'b1101?, 5'b0111?, 5'b1011? : begin 
                    mv_dat_2_w = mv_a0_dat_i; mv_val_2_w = 1 ; 
                end 
            5'b11001, 5'b10101, 5'b10011, 5'b01011, 5'b01101, 5'b00111 : begin 
                    mv_dat_2_w = mv_b2_dat_i; mv_val_2_w = 1 ; 
                end 
            5'b11000, 5'b10100, 5'b10010, 5'b10001, 5'b01100, 5'b01010, 5'b01001, 5'b00110, 5'b00101, 5'b00011 : begin 
                    mv_dat_2_w = 0          ; mv_val_2_w = 1 ; 
                end 
            default  : begin 
                    mv_dat_2_w = 0          ; mv_val_2_w = 0 ; 
                end 
        endcase 
    end 

    always @* begin 
        mv_dat_3_w = 0 ;
        mv_val_3_w = 0 ;
        mv_dat_4_w = 0 ;
        mv_val_4_w = 0 ;
        casez ( mv_val_w )
            5'b11110 : begin 
                    mv_dat_3_w = mv_a0_dat_i; mv_val_3_w = 1 ; 
                    mv_dat_4_w = 0          ; mv_val_4_w = 1 ; 
                end 
            5'b11101, 5'b01111, 5'b10111, 5'b11011 : begin 
                    mv_dat_3_w = mv_b2_dat_i; mv_val_3_w = 1 ; 
                    mv_dat_4_w = 0          ; mv_val_4_w = 1 ; 
                end 
            5'b00111, 5'b01011, 5'b01101, 5'b01110, 5'b10011, 5'b10101, 5'b10110, 5'b11001, 5'b11010, 5'b11100 : begin 
                    mv_dat_3_w = 0          ; mv_val_3_w = 1 ; 
                end 
            default  : begin 
                    mv_dat_3_w = 0          ; mv_val_3_w = 0 ; 
                end 
        endcase 
    end 

//---- merge idx ---------------------------------------------
    assign mv_00_0_val_w = mv_dat_0_w==0 && mv_val_0_w ; 
    assign mv_00_1_val_w = !mv_00_0_val_w && mv_dat_1_w==0 && mv_val_1_w ; 
    assign mv_00_2_val_w = !mv_00_1_val_w && mv_dat_2_w==0 && mv_val_2_w ; 
    assign mv_00_3_val_w = !mv_00_2_val_w && mv_dat_3_w==0 && mv_val_3_w ; 
    assign mv_00_4_val_w = !mv_00_3_val_w && mv_dat_4_w==0 && mv_val_4_w ; 

    assign mv_dat_val_w = { // skip00 valid
              mv_val_0_w 
            , mv_val_1_w  
            , mv_val_2_w  
            , mv_val_3_w  
            , mv_val_4_w 
            } ;

    assign mv_00_val_w = {
              mv_00_0_val_w
            , mv_00_1_val_w
            , mv_00_2_val_w
            , mv_00_3_val_w
            , mv_00_4_val_w
            } ;

    always @ (posedge clk or negedge rstn ) begin 
        if ( !rstn ) 
            skip_idx_r <= 0 ;
        else if ( fmv_candi_rdy_i )
            casez ( mv_dat_val_w )
                5'b11111 : begin 
                    casez ( mv_00_val_w )
                        5'b1???? : skip_idx_r <= 0 ; 
                        5'b01??? : skip_idx_r <= 1 ; 
                        5'b001?? : skip_idx_r <= 2 ; 
                        5'b0001? : skip_idx_r <= 3 ; 
                        5'b00001 : skip_idx_r <= 4 ; 
                        default  : skip_idx_r <= 0 ; 
                    endcase 
                end 
                5'b11110 : begin 
                    casez ( mv_00_val_w[4:1] )
                        4'b1??? : skip_idx_r <= 0 ; 
                        4'b01?? : skip_idx_r <= 1 ; 
                        4'b001? : skip_idx_r <= 2 ; 
                        4'b0001 : skip_idx_r <= 3 ; 
                        default : skip_idx_r <= 0 ; 
                    endcase 
                end 
                5'b11100 : begin 
                    casez ( mv_00_val_w[4:2] )
                        3'b1?? : skip_idx_r <= 0 ; 
                        3'b01? : skip_idx_r <= 1 ; 
                        3'b001 : skip_idx_r <= 2 ;  
                        default: skip_idx_r <= 0 ; 
                    endcase 
                end 
                5'b11000 : begin 
                    casez ( mv_00_val_w[4:3] )
                        2'b1?  : skip_idx_r <= 0 ; 
                        2'b01  : skip_idx_r <= 1 ;   
                        default: skip_idx_r <= 0 ; 
                    endcase 
                end 
                5'b10000 : skip_idx_r <= 0 ; 
                default  : skip_idx_r <= 0 ; 
            endcase
    end 


//---- cur -----------------------------------------------
    assign cur_4x4_x_o = pu_8x8_adr_i[2:0]<<1 ;
    assign cur_4x4_y_o = pu_8x8_adr_i[5:3]<<1 ;
    assign cur_rd_ena_o = skip_blk_start_i || start_d1 ;
    assign cur_4x4_idx_o = start_d1 ? 4 : 0 ;

    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            start_d1 <= 0;
            start_d2 <= 0;
        end else begin 
            start_d1 <= skip_blk_start_i ;
            start_d2 <= start_d1 ;
        end 
    end 

    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            cur_blk_0 <= 0 ;
            cur_blk_1 <= 0 ; 
        end else if ( start_d1 ) 
            cur_blk_0 <= cur_pel_i ;
        else if ( start_d2 )
            cur_blk_1 <= cur_pel_i ;
    end 

//---- ctrl -------------------------------------------------------
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) 
            pre_done_r <= 0 ;
        else if ( pre_cnt_w == 7 )
            pre_done_r <= 1 ;
        else if ( pre_done_r == 1 )
            pre_done_r <= 0 ;
        else 
            pre_done_r <= 0 ;
    end 

    // stage 1 
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            cu_mod_d1     <= 0 ;
            pu_8x8_adr_d1 <= 0 ;
            pu_blk_num_d1 <= 0 ;
            pu_hgt_d1     <= 0 ; 
            pu_wid_d1     <= 0 ;
            pu_pos_x_d1   <= 0 ;
            pu_pos_y_d1   <= 0 ;
            cu_mod_d2     <= 0 ;
            pu_8x8_adr_d2 <= 0 ;
            pu_blk_num_d2 <= 0 ;
            pu_hgt_d2     <= 0 ; 
            pu_wid_d2     <= 0 ;
            pu_pos_x_d2   <= 0 ;
            pu_pos_y_d2   <= 0 ;
        end 
        else if ( fme_skip_start_i ) begin 
            cu_mod_d1     <= 0 ;
            pu_8x8_adr_d1 <= 0 ;
            pu_blk_num_d1 <= 0 ;
            pu_hgt_d1     <= 0 ; 
            pu_wid_d1     <= 0 ;
            pu_pos_x_d1   <= 0 ;
            pu_pos_y_d1   <= 0 ;
            cu_mod_d2     <= 0 ;
            pu_8x8_adr_d2 <= 0 ;
            pu_blk_num_d2 <= 0 ;
            pu_hgt_d2     <= 0 ; 
            pu_wid_d2     <= 0 ;
            pu_pos_x_d2   <= 0 ;
            pu_pos_y_d2   <= 0 ;
        end 
        else if ( pre_done_r ) begin 
            cu_mod_d1     <= cu_mod_i      ;
            pu_8x8_adr_d1 <= pu_8x8_adr_i  ;
            pu_blk_num_d1 <= pu_blk_num_i  ;
            pu_hgt_d1     <= pu_hgt_i      ;
            pu_wid_d1     <= pu_wid_i      ;
            pu_pos_x_d1   <= pu_pos_x_i    ;
            pu_pos_y_d1   <= pu_pos_y_i    ;
        end 
        else if ( blk_cnt_r == pu_blk_num_d1 && skip_satd_vld_w ) begin 
            cu_mod_d2     <= cu_mod_d1     ;
            pu_8x8_adr_d2 <= pu_8x8_adr_d1 ;
            pu_blk_num_d2 <= pu_blk_num_d1 ;
            pu_hgt_d2     <= pu_hgt_d1     ;
            pu_wid_d2     <= pu_wid_d1     ;
            pu_pos_x_d2   <= pu_pos_x_d1   ;
            pu_pos_y_d2   <= pu_pos_y_d1   ;
        end 
    end 

//---- cost ------------------------------------------------
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) 
            pre_cnt_r <= 0 ;
        else if ( pre_val_i )
            pre_cnt_r <= pre_cnt_r + 1'b1 ;
    end 

    assign pre_val_w = pre_cnt_r > 3 && pre_cnt_r < 12 ;
    assign pre_cnt_w = pre_val_w ? pre_cnt_r-4 : 0 ;

    always @* begin 
        case ( pre_cnt_w )
            0 : cur_pxl_w = cur_blk_0[4*8*`PIXEL_WIDTH-1:3*8*`PIXEL_WIDTH] ;
            1 : cur_pxl_w = cur_blk_0[3*8*`PIXEL_WIDTH-1:2*8*`PIXEL_WIDTH] ;
            2 : cur_pxl_w = cur_blk_0[4*8*`PIXEL_WIDTH-1:1*8*`PIXEL_WIDTH] ;
            3 : cur_pxl_w = cur_blk_0[1*8*`PIXEL_WIDTH-1:0*8*`PIXEL_WIDTH] ;
            4 : cur_pxl_w = cur_blk_1[4*8*`PIXEL_WIDTH-1:3*8*`PIXEL_WIDTH] ;
            5 : cur_pxl_w = cur_blk_1[3*8*`PIXEL_WIDTH-1:2*8*`PIXEL_WIDTH] ;
            6 : cur_pxl_w = cur_blk_1[4*8*`PIXEL_WIDTH-1:1*8*`PIXEL_WIDTH] ;
            7 : cur_pxl_w = cur_blk_1[1*8*`PIXEL_WIDTH-1:0*8*`PIXEL_WIDTH] ;
            default : cur_pxl_w = 0 ;
        endcase 
    end 

    fme_satd_8x8 sp0(
        .clk (clk),
        .rstn (rstn),
    
        .cur_p0_i(cur_pxl_w[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),
        .cur_p1_i(cur_pxl_w[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]), 
        .cur_p2_i(cur_pxl_w[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]), 
        .cur_p3_i(cur_pxl_w[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
        .cur_p4_i(cur_pxl_w[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),
        .cur_p5_i(cur_pxl_w[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]), 
        .cur_p6_i(cur_pxl_w[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]), 
        .cur_p7_i(cur_pxl_w[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),
    
        .sp_valid_i(pre_val_w),
    
        .sp0_i(pre_pxl_i[8*`PIXEL_WIDTH-1:7*`PIXEL_WIDTH]),        
        .sp1_i(pre_pxl_i[7*`PIXEL_WIDTH-1:6*`PIXEL_WIDTH]),        
        .sp2_i(pre_pxl_i[6*`PIXEL_WIDTH-1:5*`PIXEL_WIDTH]),        
        .sp3_i(pre_pxl_i[5*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH]),
        .sp4_i(pre_pxl_i[4*`PIXEL_WIDTH-1:3*`PIXEL_WIDTH]),        
        .sp5_i(pre_pxl_i[3*`PIXEL_WIDTH-1:2*`PIXEL_WIDTH]),        
        .sp6_i(pre_pxl_i[2*`PIXEL_WIDTH-1:1*`PIXEL_WIDTH]),        
        .sp7_i(pre_pxl_i[1*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH]),
    
        .satd_8x8_o(skip_satd),
        .satd_8x8_valid_o(skip_satd_vld_w)
    );

    // rate
    assign skip_fmv_x = 'd0 ; // skip_fmv_o[2*`FMV_WIDTH-1:`FMV_WIDTH] ;
    assign skip_fmv_y = 'd0 ; // skip_fmv_o[`FMV_WIDTH-1:0] ;

    assign skip_fmv_x_abs = 'd0; //skip_fmv_x<0 ? (-skip_fmv_x) : skip_fmv_x ;
    assign skip_fmv_y_abs = 'd0; //skip_fmv_y<0 ? (-skip_fmv_y) : skip_fmv_y ;

    /*
    getbits #( .VAR_WIDTH(`FMV_WIDTH) )
        u_skip_fmv_x_bits (
        .var_i ( skip_fmv_x_abs  ),
        .bit_o ( skip_fmv_x_bit )
        );
    getbits #( .VAR_WIDTH(`FMV_WIDTH) )
        u_skip_fmv_y_bits (
        .var_i ( skip_fmv_y_abs  ),
        .bit_o ( skip_fmv_y_bit  )
        );

    getbits #( .VAR_WIDTH(4) )
        u_idx_bits(
        .var_i ( skip_idx_d1 ),
        .bit_o ( skip_idx_bit )
        );

    getbits #( .VAR_WIDTH(1) )
        u_flag_bits(
        .var_i ( 1'b1 ),
        .bit_o ( skip_flag_bit )
        );
    */
    assign  bitrate = 'd5; // skip_fmv_x_bit + skip_fmv_y_bit + skip_flag_bit ;

    // cost accumulated in a pu
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            cost_mv0_sum <= 0 ;
        end 
        else if ( cost_done_r || fme_skip_start_i ) begin 
            cost_mv0_sum <= 0 ;
        end 
        else if ( skip_satd_vld_w ) begin 
            cost_mv0_sum <= cost_mv0_sum + skip_satd ;
        end 
    end 

    assign cost_mv0_sum_r = cost_mv0_sum + lambda * bitrate ;

    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) 
            cost_done_r <= 0 ; 
        else 
            cost_done_r <= blk_cnt_r == pu_blk_num_d1 && skip_satd_vld_w && (curr_state_i == SKIP|| curr_state_i==DONE_SKIP) ; 
    end 

//---- mode decision -----------------------------------------
    // fme best pu cost 
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            fme_cst_rd_ena_o <= 0 ;
            fme_cst_rd_adr_o <= 0 ;
        end else if ( pre_done_r ) begin 
            fme_cst_rd_ena_o <= 1 ;
            fme_cst_rd_adr_o <= pu_8x8_adr_i ;
        end 
    end 

    // 8x8 block count
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) 
            blk_cnt_r <= 0 ;
        else if ( cost_done_r || fme_skip_start_i ) 
            blk_cnt_r <= 0 ;
        else if ( pre_done_r )
            blk_cnt_r <= blk_cnt_r + 1 ;
    end 

    always @* begin 
        skip_min_cost = COST_MAX ;
        if ( pu_hgt_d1 == pu_wid_d1 ) begin 
            case ( pu_wid_d1 )
                1 : skip_min_cost = skip_cost_thresh_08 ;//SKIP_COST_THRESH_8 ;
                2 : skip_min_cost = skip_cost_thresh_16 ;//SKIP_COST_THRESH_16 ;
                4 : skip_min_cost = skip_cost_thresh_32 ;//SKIP_COST_THRESH_32 ;
                8 : skip_min_cost = skip_cost_thresh_64 ;//SKIP_COST_THRESH_64 ;
                default : skip_min_cost = COST_MAX ;
            endcase 
        end 
        else 
            skip_min_cost = COST_MAX ;
    end 


    wire skip_cu_flag_w = cost_mv0_sum_r < skip_min_cost && pu_hgt_d1 == pu_wid_d1  && (curr_state_i == SKIP || curr_state_i == DONE_SKIP) ;
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) 
            skip_cu_flag_r <= 0;
        // else if ( fmv_wr_done_r )
        //     skip_cu_flag_r <= 0 ;
        else if ( cost_done_r && fmv_wr_done_r )
            // if ( skip_cu_flag_w )
            //     skip_cu_flag_r <= 1 ;
            // else 
            //     skip_cu_flag_r <= 0 ;
            skip_cu_flag_r <= skip_cu_flag_w ;
        else if ( fmv_wr_done_r )
            skip_cu_flag_r <= 0 ;
        else if ( cost_done_r )
            skip_cu_flag_r <= skip_cu_flag_w ;
            // if ( skip_cu_flag_w )
            //     skip_cu_flag_r <= 1 ;
    end 

    assign skip_cu_flag = skip_cu_flag_r && !fmv_wr_done_r ;

    assign min_cost_w = (cost_mv0_sum_r < skip_min_cost) && (pu_wid_d1 == pu_hgt_d1) ? cost_mv0_sum_r : fme_cst_rd_dat_i ;

    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn )
            fme_cst_sum_o <= 0 ;
        else if ( fme_skip_start_i )
            fme_cst_sum_o <= 0 ;
        else if ( cost_done_r )
            fme_cst_sum_o <= fme_cst_sum_o + min_cost_w ;
    end 

//---- mv dump ------------------------------------------------
    
    always @ ( posedge clk or negedge rstn ) begin 
        if (!rstn ) begin 
            fmv_wr_ena_r <= 0 ;
            fmv_wr_x_r   <= 0 ;
            fmv_wr_y_r   <= 0 ;
            fmv_wr_dat_o <= 0 ;
            mv_wr_x_cnt  <= 0 ;
            mv_wr_y_cnt  <= 0 ;
        end 
        else if ( cost_done_r ) begin 
            fmv_wr_x_r <= pu_pos_x_d1 ;
            fmv_wr_y_r <= pu_pos_y_d1 ;
            fmv_wr_ena_r <= skip_cu_flag_w ;
        end 
        else if ( skip_cu_flag && pu_blk_num_d2 > 1 ) begin 
            if ( fmv_wr_y_r < pu_pos_y_d2 + pu_hgt_d2 ) begin 
                if ( fmv_wr_x_r < pu_pos_x_d2 + pu_wid_d2-1 ) begin 
                    fmv_wr_ena_r <= 1 ;
                    fmv_wr_x_r   <= fmv_wr_x_r + 1 ; //pu_pos_x_d2 + mv_wr_x_cnt ;
                    fmv_wr_y_r   <= fmv_wr_y_r ; //pu_pos_y_d2 + mv_wr_y_cnt ;
                    fmv_wr_dat_o <= 0 ; // merge_fmv_r ;
                    // mv_wr_x_cnt  <= mv_wr_x_cnt + 1 ; 
                    // mv_wr_y_cnt  <= mv_wr_y_cnt     ;
                end 
                else begin 
                    fmv_wr_ena_r <= 1 ;
                    fmv_wr_x_r   <= pu_pos_x_d2 ;
                    fmv_wr_y_r   <= fmv_wr_y_r + 1 ; //pu_pos_y_d2 + mv_wr_y_cnt + 1 ;
                    fmv_wr_dat_o <= 0 ; // merge_fmv_r ;
                    // mv_wr_x_cnt  <= 0 ;
                    // mv_wr_y_cnt  <= mv_wr_y_cnt + 1 ;
                end 
            end 
            else begin 
                fmv_wr_ena_r <= 0 ;
            end 
        end 
        else begin 
                fmv_wr_ena_r <= 0 ;
                fmv_wr_x_r   <= 0 ;
                fmv_wr_y_r   <= 0 ;
                fmv_wr_dat_o <= 0 ;
                mv_wr_x_cnt  <= 0 ;
                mv_wr_y_cnt  <= 0 ;
            end 
    end 

    assign fmv_wr_adr_o = {fmv_wr_y_r, fmv_wr_x_r} ;
    assign fmv_wr_ena_o =   fmv_wr_ena_r 
                        && ((fmv_wr_y_r >= pu_pos_y_d2) && (fmv_wr_y_r <= pu_pos_y_d2 + pu_hgt_d2-1))
                        && ((fmv_wr_x_r >= pu_pos_x_d2) && (fmv_wr_x_r <= pu_pos_x_d2 + pu_wid_d2-1)) ;

    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) 
            fmv_wr_done_r <= 0 ;
        else if (skip_cu_flag&&( fmv_wr_y_r == pu_pos_y_d2 + pu_hgt_d2 - 1)&&(fmv_wr_x_r == pu_pos_x_d2 + pu_wid_d2-1))
            fmv_wr_done_r <= 1 ;
        else 
            fmv_wr_done_r <= 0 ;
    end 

    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) 
            fme_skip_done_o <= 0 ;
        else if ( pu_8x8_adr_d2 == 63 )
            fme_skip_done_o <= !skip_cu_flag ? 1 : fmv_wr_done_r ;
        else if ( fme_skip_done_o ) // reset done
            fme_skip_done_o <= 0 ;
    end 

//---- skip info dump -------------------------------------

    assign pu_zz_adr_w = {pu_pos_y_d2[2], pu_pos_x_d2[2], pu_pos_y_d2[1], pu_pos_x_d2[1], pu_pos_y_d2[0], pu_pos_x_d2[0]};

    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            { skip_flg_64_r    
             ,skip_flg_32_00_r, skip_flg_32_01_r, skip_flg_32_02_r, skip_flg_32_03_r 
             ,skip_flg_16_00_r, skip_flg_16_01_r, skip_flg_16_02_r, skip_flg_16_03_r
             ,skip_flg_16_04_r, skip_flg_16_05_r, skip_flg_16_06_r, skip_flg_16_07_r
             ,skip_flg_16_08_r, skip_flg_16_09_r, skip_flg_16_10_r, skip_flg_16_11_r
             ,skip_flg_16_12_r, skip_flg_16_13_r, skip_flg_16_14_r, skip_flg_16_15_r 
             ,skip_flg_08_00_r, skip_flg_08_01_r, skip_flg_08_02_r, skip_flg_08_03_r 
             ,skip_flg_08_04_r, skip_flg_08_05_r, skip_flg_08_06_r, skip_flg_08_07_r 
             ,skip_flg_08_08_r, skip_flg_08_09_r, skip_flg_08_10_r, skip_flg_08_11_r 
             ,skip_flg_08_12_r, skip_flg_08_13_r, skip_flg_08_14_r, skip_flg_08_15_r 
             ,skip_flg_08_16_r, skip_flg_08_17_r, skip_flg_08_18_r, skip_flg_08_19_r 
             ,skip_flg_08_20_r, skip_flg_08_21_r, skip_flg_08_22_r, skip_flg_08_23_r 
             ,skip_flg_08_24_r, skip_flg_08_25_r, skip_flg_08_26_r, skip_flg_08_27_r 
             ,skip_flg_08_28_r, skip_flg_08_29_r, skip_flg_08_30_r, skip_flg_08_31_r 
             ,skip_flg_08_32_r, skip_flg_08_33_r, skip_flg_08_34_r, skip_flg_08_35_r 
             ,skip_flg_08_36_r, skip_flg_08_37_r, skip_flg_08_38_r, skip_flg_08_39_r 
             ,skip_flg_08_40_r, skip_flg_08_41_r, skip_flg_08_42_r, skip_flg_08_43_r 
             ,skip_flg_08_44_r, skip_flg_08_45_r, skip_flg_08_46_r, skip_flg_08_47_r 
             ,skip_flg_08_48_r, skip_flg_08_49_r, skip_flg_08_50_r, skip_flg_08_51_r 
             ,skip_flg_08_52_r, skip_flg_08_53_r, skip_flg_08_54_r, skip_flg_08_55_r 
             ,skip_flg_08_56_r, skip_flg_08_57_r, skip_flg_08_58_r, skip_flg_08_59_r 
             ,skip_flg_08_60_r, skip_flg_08_61_r, skip_flg_08_62_r, skip_flg_08_63_r } <= 0 ;
        end else if ( fme_skip_start_i) begin // initial 
            { skip_flg_64_r    
             ,skip_flg_32_00_r, skip_flg_32_01_r, skip_flg_32_02_r, skip_flg_32_03_r 
             ,skip_flg_16_00_r, skip_flg_16_01_r, skip_flg_16_02_r, skip_flg_16_03_r
             ,skip_flg_16_04_r, skip_flg_16_05_r, skip_flg_16_06_r, skip_flg_16_07_r
             ,skip_flg_16_08_r, skip_flg_16_09_r, skip_flg_16_10_r, skip_flg_16_11_r
             ,skip_flg_16_12_r, skip_flg_16_13_r, skip_flg_16_14_r, skip_flg_16_15_r 
             ,skip_flg_08_00_r, skip_flg_08_01_r, skip_flg_08_02_r, skip_flg_08_03_r 
             ,skip_flg_08_04_r, skip_flg_08_05_r, skip_flg_08_06_r, skip_flg_08_07_r 
             ,skip_flg_08_08_r, skip_flg_08_09_r, skip_flg_08_10_r, skip_flg_08_11_r 
             ,skip_flg_08_12_r, skip_flg_08_13_r, skip_flg_08_14_r, skip_flg_08_15_r 
             ,skip_flg_08_16_r, skip_flg_08_17_r, skip_flg_08_18_r, skip_flg_08_19_r 
             ,skip_flg_08_20_r, skip_flg_08_21_r, skip_flg_08_22_r, skip_flg_08_23_r 
             ,skip_flg_08_24_r, skip_flg_08_25_r, skip_flg_08_26_r, skip_flg_08_27_r 
             ,skip_flg_08_28_r, skip_flg_08_29_r, skip_flg_08_30_r, skip_flg_08_31_r 
             ,skip_flg_08_32_r, skip_flg_08_33_r, skip_flg_08_34_r, skip_flg_08_35_r 
             ,skip_flg_08_36_r, skip_flg_08_37_r, skip_flg_08_38_r, skip_flg_08_39_r 
             ,skip_flg_08_40_r, skip_flg_08_41_r, skip_flg_08_42_r, skip_flg_08_43_r 
             ,skip_flg_08_44_r, skip_flg_08_45_r, skip_flg_08_46_r, skip_flg_08_47_r 
             ,skip_flg_08_48_r, skip_flg_08_49_r, skip_flg_08_50_r, skip_flg_08_51_r 
             ,skip_flg_08_52_r, skip_flg_08_53_r, skip_flg_08_54_r, skip_flg_08_55_r 
             ,skip_flg_08_56_r, skip_flg_08_57_r, skip_flg_08_58_r, skip_flg_08_59_r 
             ,skip_flg_08_60_r, skip_flg_08_61_r, skip_flg_08_62_r, skip_flg_08_63_r } <= 0 ;
        end 
        else if ( skip_cu_flag ) begin 
            case( cu_mod_d2 )
                CU_64 : begin 
                    skip_flg_64_r <= skip_cu_flag ;
                    skip_flg_32_00_r <= skip_cu_flag ;
                    skip_flg_32_01_r <= skip_cu_flag ;
                    skip_flg_32_02_r <= skip_cu_flag ;
                    skip_flg_32_03_r <= skip_cu_flag ;
                end
                CU_32 : begin 
                    case (pu_zz_adr_w[5:4])
                        2'b00 : skip_flg_32_00_r <= skip_cu_flag ;
                        2'b01 : skip_flg_32_01_r <= skip_cu_flag ;
                        2'b10 : skip_flg_32_02_r <= skip_cu_flag ;
                        2'b11 : skip_flg_32_03_r <= skip_cu_flag ;
                        default : ;
                    endcase 
                end 
                CU_16 : begin 
                    case (pu_zz_adr_w[5:2])
                        4'd0  : skip_flg_16_00_r <= skip_cu_flag ;
                        4'd1  : skip_flg_16_01_r <= skip_cu_flag ;
                        4'd2  : skip_flg_16_02_r <= skip_cu_flag ;
                        4'd3  : skip_flg_16_03_r <= skip_cu_flag ; 
                        4'd4  : skip_flg_16_04_r <= skip_cu_flag ;
                        4'd5  : skip_flg_16_05_r <= skip_cu_flag ;
                        4'd6  : skip_flg_16_06_r <= skip_cu_flag ;
                        4'd7  : skip_flg_16_07_r <= skip_cu_flag ;
                        4'd8  : skip_flg_16_08_r <= skip_cu_flag ;
                        4'd9  : skip_flg_16_09_r <= skip_cu_flag ;
                        4'd10 : skip_flg_16_10_r <= skip_cu_flag ;
                        4'd11 : skip_flg_16_11_r <= skip_cu_flag ;
                        4'd12 : skip_flg_16_12_r <= skip_cu_flag ;
                        4'd13 : skip_flg_16_13_r <= skip_cu_flag ;
                        4'd14 : skip_flg_16_14_r <= skip_cu_flag ;
                        4'd15 : skip_flg_16_15_r <= skip_cu_flag ;
                        default : ;
                    endcase 
                end 
                CU_08 : begin 
                    case ( pu_zz_adr_w )
                        0  : skip_flg_08_00_r <= skip_cu_flag ; 
                        1  : skip_flg_08_01_r <= skip_cu_flag ; 
                        2  : skip_flg_08_02_r <= skip_cu_flag ; 
                        3  : skip_flg_08_03_r <= skip_cu_flag ; 
                        4  : skip_flg_08_04_r <= skip_cu_flag ; 
                        5  : skip_flg_08_05_r <= skip_cu_flag ; 
                        6  : skip_flg_08_06_r <= skip_cu_flag ; 
                        7  : skip_flg_08_07_r <= skip_cu_flag ; 
                        8  : skip_flg_08_08_r <= skip_cu_flag ; 
                        9  : skip_flg_08_09_r <= skip_cu_flag ; 
                        10 : skip_flg_08_10_r <= skip_cu_flag ; 
                        11 : skip_flg_08_11_r <= skip_cu_flag ; 
                        12 : skip_flg_08_12_r <= skip_cu_flag ; 
                        13 : skip_flg_08_13_r <= skip_cu_flag ; 
                        14 : skip_flg_08_14_r <= skip_cu_flag ; 
                        15 : skip_flg_08_15_r <= skip_cu_flag ; 
                        16 : skip_flg_08_16_r <= skip_cu_flag ; 
                        17 : skip_flg_08_17_r <= skip_cu_flag ; 
                        18 : skip_flg_08_18_r <= skip_cu_flag ; 
                        19 : skip_flg_08_19_r <= skip_cu_flag ; 
                        20 : skip_flg_08_20_r <= skip_cu_flag ; 
                        21 : skip_flg_08_21_r <= skip_cu_flag ; 
                        22 : skip_flg_08_22_r <= skip_cu_flag ; 
                        23 : skip_flg_08_23_r <= skip_cu_flag ; 
                        24 : skip_flg_08_24_r <= skip_cu_flag ; 
                        25 : skip_flg_08_25_r <= skip_cu_flag ; 
                        26 : skip_flg_08_26_r <= skip_cu_flag ; 
                        27 : skip_flg_08_27_r <= skip_cu_flag ; 
                        28 : skip_flg_08_28_r <= skip_cu_flag ; 
                        29 : skip_flg_08_29_r <= skip_cu_flag ; 
                        30 : skip_flg_08_30_r <= skip_cu_flag ; 
                        31 : skip_flg_08_31_r <= skip_cu_flag ; 
                        32 : skip_flg_08_32_r <= skip_cu_flag ; 
                        33 : skip_flg_08_33_r <= skip_cu_flag ; 
                        34 : skip_flg_08_34_r <= skip_cu_flag ; 
                        35 : skip_flg_08_35_r <= skip_cu_flag ; 
                        36 : skip_flg_08_36_r <= skip_cu_flag ; 
                        37 : skip_flg_08_37_r <= skip_cu_flag ; 
                        38 : skip_flg_08_38_r <= skip_cu_flag ; 
                        39 : skip_flg_08_39_r <= skip_cu_flag ; 
                        40 : skip_flg_08_40_r <= skip_cu_flag ; 
                        41 : skip_flg_08_41_r <= skip_cu_flag ; 
                        42 : skip_flg_08_42_r <= skip_cu_flag ; 
                        43 : skip_flg_08_43_r <= skip_cu_flag ; 
                        44 : skip_flg_08_44_r <= skip_cu_flag ; 
                        45 : skip_flg_08_45_r <= skip_cu_flag ; 
                        46 : skip_flg_08_46_r <= skip_cu_flag ; 
                        47 : skip_flg_08_47_r <= skip_cu_flag ; 
                        48 : skip_flg_08_48_r <= skip_cu_flag ; 
                        49 : skip_flg_08_49_r <= skip_cu_flag ; 
                        50 : skip_flg_08_50_r <= skip_cu_flag ; 
                        51 : skip_flg_08_51_r <= skip_cu_flag ; 
                        52 : skip_flg_08_52_r <= skip_cu_flag ; 
                        53 : skip_flg_08_53_r <= skip_cu_flag ; 
                        54 : skip_flg_08_54_r <= skip_cu_flag ; 
                        55 : skip_flg_08_55_r <= skip_cu_flag ; 
                        56 : skip_flg_08_56_r <= skip_cu_flag ; 
                        57 : skip_flg_08_57_r <= skip_cu_flag ; 
                        58 : skip_flg_08_58_r <= skip_cu_flag ; 
                        59 : skip_flg_08_59_r <= skip_cu_flag ; 
                        60 : skip_flg_08_60_r <= skip_cu_flag ; 
                        61 : skip_flg_08_61_r <= skip_cu_flag ; 
                        62 : skip_flg_08_62_r <= skip_cu_flag ; 
                        63 : skip_flg_08_63_r <= skip_cu_flag ; 
                        default : ;
                    endcase 
                end 
                default : ;
            endcase 
        end 
    end 

    assign skip_flg_o = { skip_flg_64_r    
                         ,skip_flg_32_00_r, skip_flg_32_01_r, skip_flg_32_02_r, skip_flg_32_03_r 
                         ,skip_flg_16_00_r, skip_flg_16_01_r, skip_flg_16_02_r, skip_flg_16_03_r
                         ,skip_flg_16_04_r, skip_flg_16_05_r, skip_flg_16_06_r, skip_flg_16_07_r
                         ,skip_flg_16_08_r, skip_flg_16_09_r, skip_flg_16_10_r, skip_flg_16_11_r
                         ,skip_flg_16_12_r, skip_flg_16_13_r, skip_flg_16_14_r, skip_flg_16_15_r 
                         ,skip_flg_08_00_r, skip_flg_08_01_r, skip_flg_08_02_r, skip_flg_08_03_r 
                         ,skip_flg_08_04_r, skip_flg_08_05_r, skip_flg_08_06_r, skip_flg_08_07_r 
                         ,skip_flg_08_08_r, skip_flg_08_09_r, skip_flg_08_10_r, skip_flg_08_11_r 
                         ,skip_flg_08_12_r, skip_flg_08_13_r, skip_flg_08_14_r, skip_flg_08_15_r 
                         ,skip_flg_08_16_r, skip_flg_08_17_r, skip_flg_08_18_r, skip_flg_08_19_r 
                         ,skip_flg_08_20_r, skip_flg_08_21_r, skip_flg_08_22_r, skip_flg_08_23_r 
                         ,skip_flg_08_24_r, skip_flg_08_25_r, skip_flg_08_26_r, skip_flg_08_27_r 
                         ,skip_flg_08_28_r, skip_flg_08_29_r, skip_flg_08_30_r, skip_flg_08_31_r 
                         ,skip_flg_08_32_r, skip_flg_08_33_r, skip_flg_08_34_r, skip_flg_08_35_r 
                         ,skip_flg_08_36_r, skip_flg_08_37_r, skip_flg_08_38_r, skip_flg_08_39_r 
                         ,skip_flg_08_40_r, skip_flg_08_41_r, skip_flg_08_42_r, skip_flg_08_43_r 
                         ,skip_flg_08_44_r, skip_flg_08_45_r, skip_flg_08_46_r, skip_flg_08_47_r 
                         ,skip_flg_08_48_r, skip_flg_08_49_r, skip_flg_08_50_r, skip_flg_08_51_r 
                         ,skip_flg_08_52_r, skip_flg_08_53_r, skip_flg_08_54_r, skip_flg_08_55_r 
                         ,skip_flg_08_56_r, skip_flg_08_57_r, skip_flg_08_58_r, skip_flg_08_59_r 
                         ,skip_flg_08_60_r, skip_flg_08_61_r, skip_flg_08_62_r, skip_flg_08_63_r } ;

    // mc skip flag 
    always @* begin 
        mc_skip_flg_o = 0 ;
        if ( curr_state_i == 4'd11/*MC*/) begin 
            case ( cu_mod_i )
                CU_64 : begin 
                    mc_skip_flg_o = skip_flg_64_r ;
                end 
                CU_32 : begin 
                    case ( {pu_pos_y_i[2], pu_pos_x_i[2]})
                        2'b00 : mc_skip_flg_o = skip_flg_32_00_r ;
                        2'b01 : mc_skip_flg_o = skip_flg_32_01_r ;
                        2'b10 : mc_skip_flg_o = skip_flg_32_02_r ;
                        2'b11 : mc_skip_flg_o = skip_flg_32_03_r ;
                        default : mc_skip_flg_o = 0 ;
                    endcase 
                end 
                CU_16 : begin 
                    case ( {pu_pos_y_i[2], pu_pos_x_i[2], pu_pos_y_i[1], pu_pos_x_i[1]} )
                        4'd0  : mc_skip_flg_o = skip_flg_16_00_r ;
                        4'd1  : mc_skip_flg_o = skip_flg_16_01_r ;
                        4'd2  : mc_skip_flg_o = skip_flg_16_02_r ;
                        4'd3  : mc_skip_flg_o = skip_flg_16_03_r ;
                        4'd4  : mc_skip_flg_o = skip_flg_16_04_r ;
                        4'd5  : mc_skip_flg_o = skip_flg_16_05_r ;
                        4'd6  : mc_skip_flg_o = skip_flg_16_06_r ;
                        4'd7  : mc_skip_flg_o = skip_flg_16_07_r ;
                        4'd8  : mc_skip_flg_o = skip_flg_16_08_r ;
                        4'd9  : mc_skip_flg_o = skip_flg_16_09_r ;
                        4'd10 : mc_skip_flg_o = skip_flg_16_10_r ; 
                        4'd11 : mc_skip_flg_o = skip_flg_16_11_r ;
                        4'd12 : mc_skip_flg_o = skip_flg_16_12_r ;
                        4'd13 : mc_skip_flg_o = skip_flg_16_13_r ;
                        4'd14 : mc_skip_flg_o = skip_flg_16_14_r ;
                        4'd15 : mc_skip_flg_o = skip_flg_16_15_r ;
                        default : mc_skip_flg_o = 0 ;
                    endcase 
                end 
                CU_08 : begin 
                    case ( {pu_pos_y_i[2], pu_pos_x_i[2], pu_pos_y_i[1], pu_pos_x_i[1], pu_pos_y_i[0], pu_pos_x_i[0]} )
                        0  : mc_skip_flg_o = skip_flg_08_00_r ; 
                        1  : mc_skip_flg_o = skip_flg_08_01_r ; 
                        2  : mc_skip_flg_o = skip_flg_08_02_r ; 
                        3  : mc_skip_flg_o = skip_flg_08_03_r ; 
                        4  : mc_skip_flg_o = skip_flg_08_04_r ; 
                        5  : mc_skip_flg_o = skip_flg_08_05_r ; 
                        6  : mc_skip_flg_o = skip_flg_08_06_r ; 
                        7  : mc_skip_flg_o = skip_flg_08_07_r ; 
                        8  : mc_skip_flg_o = skip_flg_08_08_r ; 
                        9  : mc_skip_flg_o = skip_flg_08_09_r ; 
                        10 : mc_skip_flg_o = skip_flg_08_10_r ; 
                        11 : mc_skip_flg_o = skip_flg_08_11_r ; 
                        12 : mc_skip_flg_o = skip_flg_08_12_r ; 
                        13 : mc_skip_flg_o = skip_flg_08_13_r ; 
                        14 : mc_skip_flg_o = skip_flg_08_14_r ; 
                        15 : mc_skip_flg_o = skip_flg_08_15_r ; 
                        16 : mc_skip_flg_o = skip_flg_08_16_r ; 
                        17 : mc_skip_flg_o = skip_flg_08_17_r ; 
                        18 : mc_skip_flg_o = skip_flg_08_18_r ; 
                        19 : mc_skip_flg_o = skip_flg_08_19_r ; 
                        20 : mc_skip_flg_o = skip_flg_08_20_r ; 
                        21 : mc_skip_flg_o = skip_flg_08_21_r ; 
                        22 : mc_skip_flg_o = skip_flg_08_22_r ; 
                        23 : mc_skip_flg_o = skip_flg_08_23_r ; 
                        24 : mc_skip_flg_o = skip_flg_08_24_r ; 
                        25 : mc_skip_flg_o = skip_flg_08_25_r ; 
                        26 : mc_skip_flg_o = skip_flg_08_26_r ; 
                        27 : mc_skip_flg_o = skip_flg_08_27_r ; 
                        28 : mc_skip_flg_o = skip_flg_08_28_r ; 
                        29 : mc_skip_flg_o = skip_flg_08_29_r ; 
                        30 : mc_skip_flg_o = skip_flg_08_30_r ; 
                        31 : mc_skip_flg_o = skip_flg_08_31_r ; 
                        32 : mc_skip_flg_o = skip_flg_08_32_r ; 
                        33 : mc_skip_flg_o = skip_flg_08_33_r ; 
                        34 : mc_skip_flg_o = skip_flg_08_34_r ; 
                        35 : mc_skip_flg_o = skip_flg_08_35_r ; 
                        36 : mc_skip_flg_o = skip_flg_08_36_r ; 
                        37 : mc_skip_flg_o = skip_flg_08_37_r ; 
                        38 : mc_skip_flg_o = skip_flg_08_38_r ; 
                        39 : mc_skip_flg_o = skip_flg_08_39_r ; 
                        40 : mc_skip_flg_o = skip_flg_08_40_r ; 
                        41 : mc_skip_flg_o = skip_flg_08_41_r ; 
                        42 : mc_skip_flg_o = skip_flg_08_42_r ; 
                        43 : mc_skip_flg_o = skip_flg_08_43_r ; 
                        44 : mc_skip_flg_o = skip_flg_08_44_r ; 
                        45 : mc_skip_flg_o = skip_flg_08_45_r ; 
                        46 : mc_skip_flg_o = skip_flg_08_46_r ; 
                        47 : mc_skip_flg_o = skip_flg_08_47_r ; 
                        48 : mc_skip_flg_o = skip_flg_08_48_r ; 
                        49 : mc_skip_flg_o = skip_flg_08_49_r ; 
                        50 : mc_skip_flg_o = skip_flg_08_50_r ; 
                        51 : mc_skip_flg_o = skip_flg_08_51_r ; 
                        52 : mc_skip_flg_o = skip_flg_08_52_r ; 
                        53 : mc_skip_flg_o = skip_flg_08_53_r ; 
                        54 : mc_skip_flg_o = skip_flg_08_54_r ; 
                        55 : mc_skip_flg_o = skip_flg_08_55_r ; 
                        56 : mc_skip_flg_o = skip_flg_08_56_r ; 
                        57 : mc_skip_flg_o = skip_flg_08_57_r ; 
                        58 : mc_skip_flg_o = skip_flg_08_58_r ; 
                        59 : mc_skip_flg_o = skip_flg_08_59_r ; 
                        60 : mc_skip_flg_o = skip_flg_08_60_r ; 
                        61 : mc_skip_flg_o = skip_flg_08_61_r ; 
                        62 : mc_skip_flg_o = skip_flg_08_62_r ; 
                        63 : mc_skip_flg_o = skip_flg_08_63_r ; 
                        default : mc_skip_flg_o = 0 ;
                    endcase 
                end 
                default : mc_skip_flg_o = 0 ;
            endcase 
        end 
    end 

    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn )
            fmv_candi_rdy_d1 <= 0 ; 
        else 
            fmv_candi_rdy_d1 <= fmv_candi_rdy_i ;
    end 

    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            { skip_idx_64_r    
             ,skip_idx_32_00_r, skip_idx_32_01_r, skip_idx_32_02_r, skip_idx_32_03_r 
             ,skip_idx_16_00_r, skip_idx_16_01_r, skip_idx_16_02_r, skip_idx_16_03_r
             ,skip_idx_16_04_r, skip_idx_16_05_r, skip_idx_16_06_r, skip_idx_16_07_r
             ,skip_idx_16_08_r, skip_idx_16_09_r, skip_idx_16_10_r, skip_idx_16_11_r
             ,skip_idx_16_12_r, skip_idx_16_13_r, skip_idx_16_14_r, skip_idx_16_15_r 
             ,skip_idx_08_00_r, skip_idx_08_01_r, skip_idx_08_02_r, skip_idx_08_03_r 
             ,skip_idx_08_04_r, skip_idx_08_05_r, skip_idx_08_06_r, skip_idx_08_07_r 
             ,skip_idx_08_08_r, skip_idx_08_09_r, skip_idx_08_10_r, skip_idx_08_11_r 
             ,skip_idx_08_12_r, skip_idx_08_13_r, skip_idx_08_14_r, skip_idx_08_15_r 
             ,skip_idx_08_16_r, skip_idx_08_17_r, skip_idx_08_18_r, skip_idx_08_19_r 
             ,skip_idx_08_20_r, skip_idx_08_21_r, skip_idx_08_22_r, skip_idx_08_23_r 
             ,skip_idx_08_24_r, skip_idx_08_25_r, skip_idx_08_26_r, skip_idx_08_27_r 
             ,skip_idx_08_28_r, skip_idx_08_29_r, skip_idx_08_30_r, skip_idx_08_31_r 
             ,skip_idx_08_32_r, skip_idx_08_33_r, skip_idx_08_34_r, skip_idx_08_35_r 
             ,skip_idx_08_36_r, skip_idx_08_37_r, skip_idx_08_38_r, skip_idx_08_39_r 
             ,skip_idx_08_40_r, skip_idx_08_41_r, skip_idx_08_42_r, skip_idx_08_43_r 
             ,skip_idx_08_44_r, skip_idx_08_45_r, skip_idx_08_46_r, skip_idx_08_47_r 
             ,skip_idx_08_48_r, skip_idx_08_49_r, skip_idx_08_50_r, skip_idx_08_51_r 
             ,skip_idx_08_52_r, skip_idx_08_53_r, skip_idx_08_54_r, skip_idx_08_55_r 
             ,skip_idx_08_56_r, skip_idx_08_57_r, skip_idx_08_58_r, skip_idx_08_59_r 
             ,skip_idx_08_60_r, skip_idx_08_61_r, skip_idx_08_62_r, skip_idx_08_63_r } <= 0 ;
        end else if ( fme_skip_start_i) begin // initial 
            { skip_idx_64_r    
             ,skip_idx_32_00_r, skip_idx_32_01_r, skip_idx_32_02_r, skip_idx_32_03_r 
             ,skip_idx_16_00_r, skip_idx_16_01_r, skip_idx_16_02_r, skip_idx_16_03_r
             ,skip_idx_16_04_r, skip_idx_16_05_r, skip_idx_16_06_r, skip_idx_16_07_r
             ,skip_idx_16_08_r, skip_idx_16_09_r, skip_idx_16_10_r, skip_idx_16_11_r
             ,skip_idx_16_12_r, skip_idx_16_13_r, skip_idx_16_14_r, skip_idx_16_15_r 
             ,skip_idx_08_00_r, skip_idx_08_01_r, skip_idx_08_02_r, skip_idx_08_03_r 
             ,skip_idx_08_04_r, skip_idx_08_05_r, skip_idx_08_06_r, skip_idx_08_07_r 
             ,skip_idx_08_08_r, skip_idx_08_09_r, skip_idx_08_10_r, skip_idx_08_11_r 
             ,skip_idx_08_12_r, skip_idx_08_13_r, skip_idx_08_14_r, skip_idx_08_15_r 
             ,skip_idx_08_16_r, skip_idx_08_17_r, skip_idx_08_18_r, skip_idx_08_19_r 
             ,skip_idx_08_20_r, skip_idx_08_21_r, skip_idx_08_22_r, skip_idx_08_23_r 
             ,skip_idx_08_24_r, skip_idx_08_25_r, skip_idx_08_26_r, skip_idx_08_27_r 
             ,skip_idx_08_28_r, skip_idx_08_29_r, skip_idx_08_30_r, skip_idx_08_31_r 
             ,skip_idx_08_32_r, skip_idx_08_33_r, skip_idx_08_34_r, skip_idx_08_35_r 
             ,skip_idx_08_36_r, skip_idx_08_37_r, skip_idx_08_38_r, skip_idx_08_39_r 
             ,skip_idx_08_40_r, skip_idx_08_41_r, skip_idx_08_42_r, skip_idx_08_43_r 
             ,skip_idx_08_44_r, skip_idx_08_45_r, skip_idx_08_46_r, skip_idx_08_47_r 
             ,skip_idx_08_48_r, skip_idx_08_49_r, skip_idx_08_50_r, skip_idx_08_51_r 
             ,skip_idx_08_52_r, skip_idx_08_53_r, skip_idx_08_54_r, skip_idx_08_55_r 
             ,skip_idx_08_56_r, skip_idx_08_57_r, skip_idx_08_58_r, skip_idx_08_59_r 
             ,skip_idx_08_60_r, skip_idx_08_61_r, skip_idx_08_62_r, skip_idx_08_63_r } <= 0 ;
        end 
        else if ( curr_state_i == MC && mc_skip_flg_o && fmv_candi_rdy_d1) begin 
            case( cu_mod_i )
                CU_64 : begin 
                    skip_idx_64_r <= skip_idx_r ; 
                    skip_idx_32_00_r <= skip_idx_r ;
                    skip_idx_32_01_r <= skip_idx_r ;
                    skip_idx_32_02_r <= skip_idx_r ;
                    skip_idx_32_03_r <= skip_idx_r ;
                end 
                CU_32 : begin 
                    case ( {pu_pos_y_i[2], pu_pos_x_i[2]} )
                        2'b00 : skip_idx_32_00_r <= skip_idx_r ;
                        2'b01 : skip_idx_32_01_r <= skip_idx_r ;
                        2'b10 : skip_idx_32_02_r <= skip_idx_r ;
                        2'b11 : skip_idx_32_03_r <= skip_idx_r ;
                        default : ;
                    endcase 
                end 
                CU_16 : begin 
                    case ( {pu_pos_y_i[2], pu_pos_x_i[2], pu_pos_y_i[1], pu_pos_x_i[1]} )
                        4'd0  : skip_idx_16_00_r <= skip_idx_r ;
                        4'd1  : skip_idx_16_01_r <= skip_idx_r ;
                        4'd2  : skip_idx_16_02_r <= skip_idx_r ;
                        4'd3  : skip_idx_16_03_r <= skip_idx_r ;
                        4'd4  : skip_idx_16_04_r <= skip_idx_r ;
                        4'd5  : skip_idx_16_05_r <= skip_idx_r ;
                        4'd6  : skip_idx_16_06_r <= skip_idx_r ;
                        4'd7  : skip_idx_16_07_r <= skip_idx_r ;
                        4'd8  : skip_idx_16_08_r <= skip_idx_r ;
                        4'd9  : skip_idx_16_09_r <= skip_idx_r ;
                        4'd10 : skip_idx_16_10_r <= skip_idx_r ;
                        4'd11 : skip_idx_16_11_r <= skip_idx_r ;
                        4'd12 : skip_idx_16_12_r <= skip_idx_r ;
                        4'd13 : skip_idx_16_13_r <= skip_idx_r ;
                        4'd14 : skip_idx_16_14_r <= skip_idx_r ;
                        4'd15 : skip_idx_16_15_r <= skip_idx_r ;
                        default : ;
                    endcase 
                end 
                CU_08 : begin 
                    case ( {pu_pos_y_i[2], pu_pos_x_i[2], pu_pos_y_i[1], pu_pos_x_i[1], pu_pos_y_i[0], pu_pos_x_i[0]} )
                        0  : skip_idx_08_00_r <= skip_idx_r ;  
                        1  : skip_idx_08_01_r <= skip_idx_r ;  
                        2  : skip_idx_08_02_r <= skip_idx_r ;  
                        3  : skip_idx_08_03_r <= skip_idx_r ;  
                        4  : skip_idx_08_04_r <= skip_idx_r ;  
                        5  : skip_idx_08_05_r <= skip_idx_r ;  
                        6  : skip_idx_08_06_r <= skip_idx_r ;  
                        7  : skip_idx_08_07_r <= skip_idx_r ;  
                        8  : skip_idx_08_08_r <= skip_idx_r ;  
                        9  : skip_idx_08_09_r <= skip_idx_r ;  
                        10 : skip_idx_08_10_r <= skip_idx_r ;  
                        11 : skip_idx_08_11_r <= skip_idx_r ;  
                        12 : skip_idx_08_12_r <= skip_idx_r ;  
                        13 : skip_idx_08_13_r <= skip_idx_r ;  
                        14 : skip_idx_08_14_r <= skip_idx_r ;  
                        15 : skip_idx_08_15_r <= skip_idx_r ;  
                        16 : skip_idx_08_16_r <= skip_idx_r ;  
                        17 : skip_idx_08_17_r <= skip_idx_r ;  
                        18 : skip_idx_08_18_r <= skip_idx_r ;  
                        19 : skip_idx_08_19_r <= skip_idx_r ;  
                        20 : skip_idx_08_20_r <= skip_idx_r ;  
                        21 : skip_idx_08_21_r <= skip_idx_r ;  
                        22 : skip_idx_08_22_r <= skip_idx_r ;  
                        23 : skip_idx_08_23_r <= skip_idx_r ;  
                        24 : skip_idx_08_24_r <= skip_idx_r ;  
                        25 : skip_idx_08_25_r <= skip_idx_r ;  
                        26 : skip_idx_08_26_r <= skip_idx_r ;  
                        27 : skip_idx_08_27_r <= skip_idx_r ;  
                        28 : skip_idx_08_28_r <= skip_idx_r ;  
                        29 : skip_idx_08_29_r <= skip_idx_r ;  
                        30 : skip_idx_08_30_r <= skip_idx_r ;  
                        31 : skip_idx_08_31_r <= skip_idx_r ;  
                        32 : skip_idx_08_32_r <= skip_idx_r ;  
                        33 : skip_idx_08_33_r <= skip_idx_r ;  
                        34 : skip_idx_08_34_r <= skip_idx_r ;  
                        35 : skip_idx_08_35_r <= skip_idx_r ;  
                        36 : skip_idx_08_36_r <= skip_idx_r ;  
                        37 : skip_idx_08_37_r <= skip_idx_r ;  
                        38 : skip_idx_08_38_r <= skip_idx_r ;  
                        39 : skip_idx_08_39_r <= skip_idx_r ;  
                        40 : skip_idx_08_40_r <= skip_idx_r ;  
                        41 : skip_idx_08_41_r <= skip_idx_r ;  
                        42 : skip_idx_08_42_r <= skip_idx_r ;  
                        43 : skip_idx_08_43_r <= skip_idx_r ;  
                        44 : skip_idx_08_44_r <= skip_idx_r ;  
                        45 : skip_idx_08_45_r <= skip_idx_r ;  
                        46 : skip_idx_08_46_r <= skip_idx_r ;  
                        47 : skip_idx_08_47_r <= skip_idx_r ;  
                        48 : skip_idx_08_48_r <= skip_idx_r ;  
                        49 : skip_idx_08_49_r <= skip_idx_r ;  
                        50 : skip_idx_08_50_r <= skip_idx_r ;  
                        51 : skip_idx_08_51_r <= skip_idx_r ;  
                        52 : skip_idx_08_52_r <= skip_idx_r ;  
                        53 : skip_idx_08_53_r <= skip_idx_r ;  
                        54 : skip_idx_08_54_r <= skip_idx_r ;  
                        55 : skip_idx_08_55_r <= skip_idx_r ;  
                        56 : skip_idx_08_56_r <= skip_idx_r ;  
                        57 : skip_idx_08_57_r <= skip_idx_r ;  
                        58 : skip_idx_08_58_r <= skip_idx_r ;  
                        59 : skip_idx_08_59_r <= skip_idx_r ;  
                        60 : skip_idx_08_60_r <= skip_idx_r ;  
                        61 : skip_idx_08_61_r <= skip_idx_r ;  
                        62 : skip_idx_08_62_r <= skip_idx_r ;  
                        63 : skip_idx_08_63_r <= skip_idx_r ;  
                        default : ;
                    endcase 
                end 
                default : ;
            endcase 
        end 
    end 

    assign skip_idx_o = {skip_idx_64_r    
                         ,skip_idx_32_00_r, skip_idx_32_01_r, skip_idx_32_02_r, skip_idx_32_03_r 
                         ,skip_idx_16_00_r, skip_idx_16_01_r, skip_idx_16_02_r, skip_idx_16_03_r
                         ,skip_idx_16_04_r, skip_idx_16_05_r, skip_idx_16_06_r, skip_idx_16_07_r
                         ,skip_idx_16_08_r, skip_idx_16_09_r, skip_idx_16_10_r, skip_idx_16_11_r
                         ,skip_idx_16_12_r, skip_idx_16_13_r, skip_idx_16_14_r, skip_idx_16_15_r 
                         ,skip_idx_08_00_r, skip_idx_08_01_r, skip_idx_08_02_r, skip_idx_08_03_r 
                         ,skip_idx_08_04_r, skip_idx_08_05_r, skip_idx_08_06_r, skip_idx_08_07_r 
                         ,skip_idx_08_08_r, skip_idx_08_09_r, skip_idx_08_10_r, skip_idx_08_11_r 
                         ,skip_idx_08_12_r, skip_idx_08_13_r, skip_idx_08_14_r, skip_idx_08_15_r 
                         ,skip_idx_08_16_r, skip_idx_08_17_r, skip_idx_08_18_r, skip_idx_08_19_r 
                         ,skip_idx_08_20_r, skip_idx_08_21_r, skip_idx_08_22_r, skip_idx_08_23_r 
                         ,skip_idx_08_24_r, skip_idx_08_25_r, skip_idx_08_26_r, skip_idx_08_27_r 
                         ,skip_idx_08_28_r, skip_idx_08_29_r, skip_idx_08_30_r, skip_idx_08_31_r 
                         ,skip_idx_08_32_r, skip_idx_08_33_r, skip_idx_08_34_r, skip_idx_08_35_r 
                         ,skip_idx_08_36_r, skip_idx_08_37_r, skip_idx_08_38_r, skip_idx_08_39_r 
                         ,skip_idx_08_40_r, skip_idx_08_41_r, skip_idx_08_42_r, skip_idx_08_43_r 
                         ,skip_idx_08_44_r, skip_idx_08_45_r, skip_idx_08_46_r, skip_idx_08_47_r 
                         ,skip_idx_08_48_r, skip_idx_08_49_r, skip_idx_08_50_r, skip_idx_08_51_r 
                         ,skip_idx_08_52_r, skip_idx_08_53_r, skip_idx_08_54_r, skip_idx_08_55_r 
                         ,skip_idx_08_56_r, skip_idx_08_57_r, skip_idx_08_58_r, skip_idx_08_59_r 
                         ,skip_idx_08_60_r, skip_idx_08_61_r, skip_idx_08_62_r, skip_idx_08_63_r  } ;

endmodule 