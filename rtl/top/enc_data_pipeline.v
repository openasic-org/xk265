//-------------------------------------------------------------------
//
//  Filename      : enc_data_pipeline.v
//  Author        : TANG
//  Created       : 2018-05-23
//  Description   : enc data pipeline control
//
//-------------------------------------------------------------------
`include "enc_defines.v"

module enc_data_pipeline(
    // global
    clk                     ,
    rstn                    ,
    enc_done_i              ,
    // qp
    rc_qp_i                 ,
    posi_qp_o               ,
    fme_qp_o                ,
    rec_qp_o                ,
    db_qp_o                 ,
    ec_qp_o                 ,
    // intra pt
    intra_partition_i       ,
    rec_intra_pt_o          ,
    db_intra_pt_o           ,
    ec_intra_pt_o           ,
    // inter pt
    inter_partition_i       ,
    fme_inter_pt_o          ,       
    rec_inter_pt_o          ,
    db_inter_pt_o           ,
    ec_inter_pt_o           ,
    // IinP flag
    IinP_flag_i             ,
    db_IinP_flag_o          ,
    ec_IinP_flag_o          ,
    // cbf
    cbf_y_i                 ,
    cbf_u_i                 ,
    cbf_v_i                 ,
    db_cbf_y_o              ,
    db_cbf_u_o              ,
    db_cbf_v_o              ,
    ec_cbf_y_o              ,
    ec_cbf_u_o              ,
    ec_cbf_v_o              ,
    // skip 
    skip_idx_i              ,
    skip_flag_i             ,
    skip_idx_o              ,
    skip_flag_o             ,
    rec_skip_flag_o         ,
    // rc bitnum
    bs_val_i                ,
    rc_actual_bitnum_o      
   );

//---- input/output ----------------------------------------------
    input                       clk                 ;
    input                       rstn                ;
    input                       enc_done_i          ;
    // qp
    input   [6      -1 :0]      rc_qp_i             ;
    output  [6      -1 :0]      posi_qp_o           ;
    output  [6      -1 :0]      fme_qp_o            ;
    output  [6      -1 :0]      rec_qp_o            ;
    output  [6      -1 :0]      db_qp_o             ;
    output  [6      -1 :0]      ec_qp_o             ;
    // intra pt
    input   [85     -1 :0]      intra_partition_i   ;
    output  [85     -1 :0]      rec_intra_pt_o      ;
    output  [21     -1 :0]      db_intra_pt_o       ;
    output  [85     -1 :0]      ec_intra_pt_o       ;
    // inter pt 
    input   [42     -1 :0]      inter_partition_i   ;
    output  [42     -1 :0]      fme_inter_pt_o      ;
    output  [42     -1 :0]      rec_inter_pt_o      ;
    output  [42     -1 :0]      db_inter_pt_o       ;
    output  [42     -1 :0]      ec_inter_pt_o       ;
    // IinP flag
    input   [3      -1 :0]      IinP_flag_i         ;
    output  [3      -1 :0]      db_IinP_flag_o      ;
    output  [3      -1 :0]      ec_IinP_flag_o      ;
    // cbf 
    input   [256    -1 :0]      cbf_y_i             ;
    input   [256    -1 :0]      cbf_u_i             ;
    input   [256    -1 :0]      cbf_v_i             ;
    output  [256    -1 :0]      db_cbf_y_o          ;
    output  [256    -1 :0]      db_cbf_u_o          ;
    output  [256    -1 :0]      db_cbf_v_o          ;
    output  [256    -1 :0]      ec_cbf_y_o          ;
    output  [256    -1 :0]      ec_cbf_u_o          ;
    output  [256    -1 :0]      ec_cbf_v_o          ;
    // skip 
    input   [85*4-1:0]          skip_idx_i          ;
    input   [85-1:0]            skip_flag_i         ;
    output  [85*4-1:0]          skip_idx_o          ;
    output  [85-1:0]            skip_flag_o         ;
    output  [85-1:0]            rec_skip_flag_o     ;
    // actual bit number
    input                       bs_val_i            ;
    output  [16     -1 :0]      rc_actual_bitnum_o  ;

//---- wire/reg -------------------------------------------------
    reg     [16     -1 :0]      rc_actual_bitnum_r  ;
    reg     [6      -1 :0]      posi_qp_o           ;
    reg     [6      -1 :0]      fme_qp_o            ;
    reg     [6      -1 :0]      rec_qp_o            ;
    reg     [6      -1 :0]      db_qp_o             ;
    reg     [6      -1 :0]      ec_qp_o             ;
    reg     [85     -1 :0]      rec_intra_pt_o      ;
    reg     [85     -1 :0]      db_intra_pt_r       ;
    reg     [85     -1 :0]      ec_intra_pt_o       ;
    reg     [42     -1 :0]      fme_inter_pt_o      ;
    reg     [42     -1 :0]      rec_inter_pt_o      ;
    reg     [42     -1 :0]      db_inter_pt_o       ;
    reg     [42     -1 :0]      ec_inter_pt_o       ;
    reg     [3      -1 :0]      db_IinP_flag_o      ;
    reg     [3      -1 :0]      ec_IinP_flag_o      ;
    reg     [256    -1 :0]      db_cbf_y_o          ;
    reg     [256    -1 :0]      db_cbf_u_o          ;
    reg     [256    -1 :0]      db_cbf_v_o          ;
    reg     [256    -1 :0]      ec_cbf_y_o          ;
    reg     [256    -1 :0]      ec_cbf_u_o          ;
    reg     [256    -1 :0]      ec_cbf_v_o          ;
    reg     [16     -1 :0]      rc_actual_bitnum_o  ;
    wire    [21     -1 :0]      db_intra_pt_o       ;

    reg     [85*4-1:0]          skip_idx_d1         ;
    reg     [85-1:0]            rec_skip_flag_o        ;
    reg     [85*4-1:0]          skip_idx_d2         ;
    reg     [85-1:0]            skip_flag_d2        ;
    reg     [85*4-1:0]          skip_idx_o          ;
    reg     [85-1:0]            skip_flag_o         ;

//---- main body --------------------------------------------------
    // qp
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            posi_qp_o           <= 0;
            fme_qp_o            <= 0;
            rec_qp_o            <= 0;
            db_qp_o             <= 0;
            ec_qp_o             <= 0;
        end else if ( enc_done_i == 1) begin 
            posi_qp_o           <= rc_qp_i  ;
            fme_qp_o            <= rc_qp_i  ;
            rec_qp_o            <= fme_qp_o ;
            db_qp_o             <= rec_qp_o ;
            ec_qp_o             <= db_qp_o  ;
        end 
        else ;
    end 

    // intra partition 
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            rec_intra_pt_o      <= 0;
            db_intra_pt_r       <= 0;
            ec_intra_pt_o       <= 0;
        end else if ( enc_done_i == 1 ) begin 
            rec_intra_pt_o      <= intra_partition_i;
            db_intra_pt_r       <= rec_intra_pt_o   ;
            ec_intra_pt_o       <= db_intra_pt_r    ;
        end 
        else ;
    end 

    assign db_intra_pt_o = db_intra_pt_r[20:0] ;

    // inter partition 
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            fme_inter_pt_o      <= 0;
            rec_inter_pt_o      <= 0;
            db_inter_pt_o       <= 0;
            ec_inter_pt_o       <= 0;
        end else if ( enc_done_i == 1 ) begin 
            fme_inter_pt_o      <= inter_partition_i;
            rec_inter_pt_o      <= fme_inter_pt_o   ;
            db_inter_pt_o       <= rec_inter_pt_o   ;
            ec_inter_pt_o       <= db_inter_pt_o    ;
        end 
        else ;
    end 

    // IinP flag 
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            db_IinP_flag_o      <= 0;
            ec_IinP_flag_o      <= 0;
        end else if ( enc_done_i == 1 ) begin 
            db_IinP_flag_o      <= IinP_flag_i      ;
            ec_IinP_flag_o      <= db_IinP_flag_o   ;
        end 
        else ;
    end 

    // cbf 
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            db_cbf_y_o <= 0;
            db_cbf_u_o <= 0;
            db_cbf_v_o <= 0;
            ec_cbf_y_o <= 0;
            ec_cbf_u_o <= 0;
            ec_cbf_v_o <= 0;
        end else if ( enc_done_i == 1 ) begin 
            db_cbf_y_o <= cbf_y_i    ;
            db_cbf_u_o <= cbf_u_i    ;
            db_cbf_v_o <= cbf_v_i    ;
            ec_cbf_y_o <= db_cbf_y_o ;
            ec_cbf_u_o <= db_cbf_u_o ;
            ec_cbf_v_o <= db_cbf_v_o ;
        end 
        else ;
    end 

    // skip 
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            skip_idx_d1  <= 0 ;
            rec_skip_flag_o <= 0 ;
            skip_idx_d2  <= 0 ;
            skip_flag_d2 <= 0 ;
            skip_idx_o   <= 0 ;
            skip_flag_o  <= 0 ;
        end else if ( enc_done_i ) begin 
            skip_idx_d1  <= skip_idx_i   ;
            rec_skip_flag_o <= skip_flag_i  ;
            skip_idx_d2  <= skip_idx_d1  ;
            skip_flag_d2 <= rec_skip_flag_o ;
            skip_idx_o   <= skip_idx_d2  ;
            skip_flag_o  <= skip_flag_d2 ;
        end 
        else ;
    end  

    // byte count 
    always @ ( posedge clk or negedge rstn ) begin 
      if ( !rstn ) 
        rc_actual_bitnum_r <= 0;
      else if ( enc_done_i )
        rc_actual_bitnum_r <= 0;
      else if ( bs_val_i == 1 )
        rc_actual_bitnum_r <= rc_actual_bitnum_r + 1'b1 ;
      else ;
    end

    always @ ( posedge clk or negedge rstn ) begin 
        if(!rstn)
            rc_actual_bitnum_o <= 0;
        else if ( enc_done_i == 1 )
            rc_actual_bitnum_o <= rc_actual_bitnum_r ;
        else ;
    end 


endmodule 