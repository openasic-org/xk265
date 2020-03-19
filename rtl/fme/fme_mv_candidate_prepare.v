//------------------------------------------------------------
//
//  File Name       : fme_mv_candidate_prepare.v
//  Author          : TANG 
//  Date            : 2018-06-11
//  Description     : support fme skip and merge
//
//-------------------------------------------------------------
`include "enc_defines.v"

module fme_mv_candidate_prepare(
    clk                 ,
    rstn                ,
    // sys if
    sys_ctu_x_all_i     ,
    sys_ctu_y_all_i     ,
    sys_x_all_i         ,
    sys_y_all_i         ,
    fme_ctu_x_i         ,
    fme_ctu_y_i         ,
    // IinP flag
    IinP_flag_i         ,
    // ctrl
    pu_start_i          ,
    // current LCU fmv
    cur_fmv_rd_ena_o    ,
    cur_fmv_rd_adr_o    ,
    cur_fmv_rd_dat_i    ,
    // left LCU mv 
    lft_fmv_rd_ena_o    ,
    lft_fmv_rd_adr_o    ,
    lft_fmv_rd_dat_i    ,
    // top LCU mv 
    top_fmv_rd_ena_o    ,
    top_fmv_rd_adr_o    ,
    top_fmv_rd_dat_i    ,
    // pu position
    pu_pos_x_i          ,
    pu_pos_y_i          ,
    pu_hgt_i            ,
    pu_wid_i            ,
    // mv candidate
    mv_candi_a0_val_o   ,
    mv_candi_a1_val_o   ,
    mv_candi_b0_val_o   ,
    mv_candi_b1_val_o   ,
    mv_candi_b2_val_o   ,
    mv_candi_a0_dat_o   ,
    mv_candi_a1_dat_o   ,
    mv_candi_b0_dat_o   ,
    mv_candi_b1_dat_o   ,
    mv_candi_b2_dat_o   ,
    // fmv candidates ready
    fmv_candi_rdy_o 
    );

//---- parameter -----------------------------------------------------------
    localparam  IDLE = 0 ,
                A0   = 1 ,
                A1   = 2 ,
                B0   = 3 ,
                B1   = 4 ,
                B2   = 5 ;
    localparam  PRE_HALF  = 4'd1,
                PRE_QUAR  = 4'd4,
                PRE_SKIP  = 4'd7;

//---- input/output ---------------------------------------------------------
    input                           clk                 ;
    input                           rstn                ;
    input   [`PIC_X_WIDTH-1:0]      sys_ctu_x_all_i     ;
    input   [`PIC_Y_WIDTH-1:0]      sys_ctu_y_all_i     ;
    input   [`PIC_WIDTH-1:0]        sys_x_all_i         ;
    input   [`PIC_HEIGHT-1:0]       sys_y_all_i         ;
    input   [`PIC_X_WIDTH-1:0]      fme_ctu_x_i         ;
    input   [`PIC_Y_WIDTH-1:0]      fme_ctu_y_i         ;
    // IinP flag
    input   [4-1:0]                 IinP_flag_i         ;
    // ctrl if
    input                           pu_start_i     ;
    // cur mv
    output                          cur_fmv_rd_ena_o    ;
    output  [6-1:0]                 cur_fmv_rd_adr_o    ;
    input   [2*`FMV_WIDTH-1:0]      cur_fmv_rd_dat_i    ;
    // top mv
    output                          top_fmv_rd_ena_o    ;
    output  [`PIC_X_WIDTH+3-1:0]    top_fmv_rd_adr_o    ;
    input   [2*`FMV_WIDTH-1:0]      top_fmv_rd_dat_i    ;
    // left mv 
    output                          lft_fmv_rd_ena_o    ;
    output  [3-1:0]                 lft_fmv_rd_adr_o    ;
    input   [2*`FMV_WIDTH-1:0]      lft_fmv_rd_dat_i    ;
    // pu position
    input   [3-1:0]                 pu_pos_x_i          ; // in 8xx block 
    input   [3-1:0]                 pu_pos_y_i          ; // in 8xx block 
    input   [4-1:0]                 pu_hgt_i            ; // in 8xx block 
    input   [4-1:0]                 pu_wid_i            ; // in 8xx block 
    // mv candidates
    output                          mv_candi_a0_val_o   ;
    output                          mv_candi_a1_val_o   ;
    output                          mv_candi_b0_val_o   ;
    output                          mv_candi_b1_val_o   ;
    output                          mv_candi_b2_val_o   ;
    output  [2*`FMV_WIDTH-1:0]      mv_candi_a0_dat_o   ;
    output  [2*`FMV_WIDTH-1:0]      mv_candi_a1_dat_o   ;
    output  [2*`FMV_WIDTH-1:0]      mv_candi_b0_dat_o   ;
    output  [2*`FMV_WIDTH-1:0]      mv_candi_b1_dat_o   ;
    output  [2*`FMV_WIDTH-1:0]      mv_candi_b2_dat_o   ;
    // ready 
    output                          fmv_candi_rdy_o     ;
//---- wire/reg -------------------------------------------------------------
    // pu position
    wire    [4-1:0]                 pu_blw_y_w          ;
    wire    [4-1:0]                 pu_rgt_x_w          ;
    // pu flag
    wire                            pu_in_fra_x_w       ;
    wire                            pu_in_fra_y_w       ;
    wire                            pu_exist            ;
    // available flag
    wire                            left_avail_w        ;
    wire                            top_avail_w         ;
    wire                            tl_avail_w          ;
    wire                            tr_avail_w          ;
    // vertical valid
    // reg                             ver_mv_0_val_r      ;
    // reg                             ver_mv_1_val_r      ;
    // reg                             ver_mv_2_val_r      ;
    // reg                             ver_mv_3_val_r      ;
    // reg                             ver_mv_4_val_r      ;
    // reg                             ver_mv_5_val_r      ;
    // reg                             ver_mv_6_val_r      ;
    // reg                             ver_mv_7_val_r      ;
    // // horizontal valid
    // reg                             hor_mv_0_val_r      ;
    // reg                             hor_mv_1_val_r      ;
    // reg                             hor_mv_2_val_r      ;
    // reg                             hor_mv_3_val_r      ;
    // reg                             hor_mv_4_val_r      ;
    // reg                             hor_mv_5_val_r      ;
    // reg                             hor_mv_6_val_r      ;
    // reg                             hor_mv_7_val_r      ;

    // exist flag
    wire                            a0_exist            ;
    wire                            a1_exist            ;
    wire                            b0_exist            ;
    wire                            b1_exist            ;
    wire                            b2_exist            ;
    wire    [4-1:0]                 a0_pos_y_w          ;
    wire    [4-1:0]                 a0_pos_x_w          ;
    wire    [4-1:0]                 a1_pos_y_w          ;
    wire    [4-1:0]                 a1_pos_x_w          ;
    wire    [4-1:0]                 b0_pos_y_w          ;
    wire    [4-1:0]                 b0_pos_x_w          ;
    wire    [4-1:0]                 b1_pos_y_w          ;
    wire    [4-1:0]                 b1_pos_x_w          ;
    wire    [4-1:0]                 b2_pos_y_w          ;
    wire    [4-1:0]                 b2_pos_x_w          ;
    wire    [6-1:0]                 a0_pos_w            ;
    wire    [6-1:0]                 a1_pos_w            ;
    wire    [6-1:0]                 b0_pos_w            ;
    wire    [6-1:0]                 b1_pos_w            ;
    wire    [6-1:0]                 b2_pos_w            ;
    wire    [6-1:0]                 pu_pos_w            ;

    wire    [3-1:0]                 res_y_w             ;
    wire    [3-1:0]                 res_x_w             ;
    wire    [4-1:0]                 res_x_plus_one_w    ;
    // state machine
    reg     [3-1:0]                 curr_state          ;
    reg     [3-1:0]                 curr_state_d1       ;
    reg     [3-1:0]                 next_state          ;
    // fmv 
    reg     [4-1:0]                 fmv_adr_x_w         ;
    reg     [4-1:0]                 fmv_adr_y_w         ;
    reg                             fmv_rd_ena_w        ;
    //  cur fmv
    reg                             cur_fmv_rd_ena_o    ;
    reg     [6-1:0]                 cur_fmv_rd_adr_o    ;
    // top mv
    reg                             top_fmv_rd_ena_o    ;
    reg     [`PIC_X_WIDTH+3-1:0]    top_fmv_rd_adr_o    ;
    // left mv
    reg                             lft_fmv_rd_ena_o    ;
    reg     [3-1:0]                 lft_fmv_rd_adr_o    ;
    // delay 
    reg                             cur_fmv_rd_ena_d1   ;
    reg                             top_fmv_rd_ena_d1   ;
    reg                             lft_fmv_rd_ena_d1   ;
    // fmv 
    wire    [2*`FMV_WIDTH-1:0]      fmv_dat_w           ;
    // mv candidates
    reg     [2*`FMV_WIDTH-1:0]      mv_candi_a0_dat_o   ;
    reg     [2*`FMV_WIDTH-1:0]      mv_candi_a1_dat_o   ;
    reg     [2*`FMV_WIDTH-1:0]      mv_candi_b0_dat_o   ;
    reg     [2*`FMV_WIDTH-1:0]      mv_candi_b1_dat_o   ;
    reg     [2*`FMV_WIDTH-1:0]      mv_candi_b2_dat_o   ;
    reg                             mv_candi_a0_val_o   ;
    reg                             mv_candi_a1_val_o   ;
    reg                             mv_candi_b0_val_o   ;
    reg                             mv_candi_b1_val_o   ;
    reg                             mv_candi_b2_val_o   ;

    wire                            non_mv_exist_w      ;

    reg                             fmv_candi_rdy_o     ;
//---- main body -------------------------------------------------------------

    assign pu_blw_y_w = pu_pos_y_i + pu_hgt_i ;
    assign pu_rgt_x_w = pu_pos_x_i + pu_wid_i ;
    
    assign pu_in_fra_x_w = ( fme_ctu_x_i != sys_ctu_x_all_i ) || (pu_rgt_x_w - 1'b1 <= (sys_x_all_i[5:3]-1)) ;
    assign pu_in_fra_y_w = ( fme_ctu_y_i != sys_ctu_y_all_i ) || (pu_blw_y_w - 1'b1 <= (sys_y_all_i[5:3]-1)) ;
    assign pu_exist = pu_in_fra_x_w && pu_in_fra_y_w ;
    
    assign left_avail_w = (fme_ctu_x_i != 0 && IinP_flag_i[0] == 0); 
    assign top_avail_w = (fme_ctu_y_i != 0 && IinP_flag_i[1] == 0) ; 
    assign tl_avail_w  = (pu_pos_x_i!=0&&pu_pos_y_i!=0) 
                      || (pu_pos_x_i==0&&fme_ctu_x_i != 0&&pu_pos_y_i!=0)
                      || (pu_pos_y_i==0&&fme_ctu_y_i != 0&&pu_pos_x_i!=0)
                      || (fme_ctu_x_i != 0 && fme_ctu_y_i != 0 && IinP_flag_i[2] == 0) ; // TODO: modify it 
    assign tr_avail_w = (fme_ctu_y_i != 0 && IinP_flag_i[3] == 0); 


//---- check mv candidates -----------------------------------
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
    * for AMVP : A0 -> A1 -> B0 -> B1 -> B2
    * for skip : A1 -> B1 -> B0 -> A0 -> (B2)
    * This module just check the existence of mv candidates, 
    * so the order can be arbitray
    */

    // addr
    // a0
    assign a0_pos_y_w = pu_blw_y_w ; 
    assign a0_pos_x_w = pu_pos_x_i - 1'b1 ; 
    //a1
    assign a1_pos_y_w = pu_blw_y_w - 1'b1 ; 
    assign a1_pos_x_w = pu_pos_x_i - 1'b1 ; 
    //b0 
    assign b0_pos_y_w = pu_pos_y_i - 1'b1 ; 
    assign b0_pos_x_w = pu_rgt_x_w ; 
    //b1 
    assign b1_pos_y_w = pu_pos_y_i - 1'b1 ; 
    assign b1_pos_x_w = pu_rgt_x_w - 1'b1 ; 
    // b2 
    assign b2_pos_y_w = pu_pos_y_i - 1'b1 ; 
    assign b2_pos_x_w = pu_pos_x_i - 1'b1 ; 

    // boundary 
    assign res_x_w = ( fme_ctu_x_i != sys_ctu_x_all_i ) ? 7 : sys_x_all_i[5:3]-1 ;
    assign res_y_w = ( fme_ctu_y_i != sys_ctu_y_all_i ) ? 7 : sys_y_all_i[5:3]-1 ;
    assign res_x_plus_one_w = res_x_w + 1;

    // pos in zscan
    assign a0_pos_w = {a0_pos_y_w[2], a0_pos_x_w[2], a0_pos_y_w[1], a0_pos_x_w[1], a0_pos_y_w[0], a0_pos_x_w[0] };
    assign a1_pos_w = {a1_pos_y_w[2], a1_pos_x_w[2], a1_pos_y_w[1], a1_pos_x_w[1], a1_pos_y_w[0], a1_pos_x_w[0] };
    assign b0_pos_w = {b0_pos_y_w[2], b0_pos_x_w[2], b0_pos_y_w[1], b0_pos_x_w[1], b0_pos_y_w[0], b0_pos_x_w[0] };
    assign b1_pos_w = {b1_pos_y_w[2], b1_pos_x_w[2], b1_pos_y_w[1], b1_pos_x_w[1], b1_pos_y_w[0], b1_pos_x_w[0] };
    assign b2_pos_w = {b2_pos_y_w[2], b2_pos_x_w[2], b2_pos_y_w[1], b2_pos_x_w[1], b2_pos_y_w[0], b2_pos_x_w[0] };
    assign pu_pos_w = {pu_pos_y_i[2], pu_pos_x_i[2], pu_pos_y_i[1], pu_pos_x_i[1], pu_pos_y_i[0], pu_pos_x_i[0] } ;

    assign a0_exist = pu_exist && (pu_blw_y_w<=res_y_w) && ( pu_pos_x_i ==0 ? left_avail_w : pu_pos_w > a0_pos_w );
    assign a1_exist = pu_exist && (pu_pos_x_i == 0 ? left_avail_w : pu_pos_w > a1_pos_w ); 
    assign b0_exist = pu_exist && (pu_pos_y_i == 0 ? (tr_avail_w && (!(fme_ctu_x_i == sys_ctu_x_all_i && pu_rgt_x_w == res_x_plus_one_w))) : (pu_rgt_x_w != res_x_plus_one_w ? pu_pos_w > b0_pos_w : 0) ) ;  
    assign b1_exist = pu_exist && (pu_pos_y_i == 0 ? top_avail_w : pu_pos_w > b1_pos_w ) ;
    assign b2_exist = pu_exist && tl_avail_w ;


    always @ ( posedge clk or negedge rstn ) begin 
        if(!rstn) 
            curr_state <= IDLE ;
        else 
            curr_state <= next_state ;
    end 
    
    // fsm
    always @* begin 
        next_state = IDLE ;
        case (curr_state)
        IDLE : begin 
            if ( pu_start_i ) begin 
                casez ( {a0_exist, a1_exist, b0_exist, b1_exist, b2_exist} )
                    5'b1???? : next_state = A0 ;
                    5'b01??? : next_state = A1 ;
                    5'b001?? : next_state = B0 ;
                    5'b0001? : next_state = B1 ;
                    5'b00001 : next_state = B2 ;
                     default : next_state = IDLE ;
                endcase 
            end 
        end 
        A0 : begin 
                casez ( {a1_exist, b0_exist, b1_exist, b2_exist} )
                    4'b1??? : next_state = A1 ;
                    4'b01?? : next_state = B0 ;
                    4'b001? : next_state = B1 ;
                    4'b0001 : next_state = B2 ;
                    default : next_state = IDLE ;
                endcase 
        end 
        A1 : begin 
                casez ( {b0_exist, b1_exist, b2_exist} )
                    3'b1??  : next_state = B0 ;
                    3'b01?  : next_state = B1 ;
                    3'b001  : next_state = B2 ;
                    default : next_state = IDLE ;
                endcase 
        end 
        B0 : begin 
                casez ( {b1_exist, b2_exist} )
                    2'b1?   : next_state = B1 ;
                    2'b01   : next_state = B2 ;
                    default : next_state = IDLE ;
                endcase 
        end 
        B1 : begin 
                if ( b2_exist )
                    next_state = B2 ;
                else 
                    next_state = IDLE ;
        end 
        B2 : begin 
                    next_state = IDLE ;
        end 
        default : next_state = IDLE ;
        endcase 
    end 
    
    // mv address
    /*
        addr :  if the mv is in left LCU, the mv_adr_x will be 0, 
                and the current mv addr_x is 1 to 16.
                The same for the mv in top LCU.
    */
    always @* begin 
        fmv_adr_x_w  = 0 ;
        fmv_adr_y_w  = 0 ;
        fmv_rd_ena_w = 0 ;
        case ( curr_state )
        A0 : begin 
            fmv_adr_x_w  = pu_pos_x_i + 1 - 1 ; 
            fmv_adr_y_w  = pu_blw_y_w + 1 ; 
            fmv_rd_ena_w = a0_exist ;
        end 
        A1 : begin 
            fmv_adr_x_w  = pu_pos_x_i + 1 - 1 ; 
            fmv_adr_y_w  = pu_blw_y_w     ; 
            fmv_rd_ena_w = a1_exist ;
        end 
        B0 : begin 
            fmv_adr_x_w  = pu_rgt_x_w + 1 ; 
            fmv_adr_y_w  = pu_pos_y_i + 1 - 1 ; 
            fmv_rd_ena_w = b0_exist ;
        end
        B1 : begin 
            fmv_adr_x_w  = pu_rgt_x_w     ; 
            fmv_adr_y_w  = pu_pos_y_i + 1 - 1 ; 
            fmv_rd_ena_w = b1_exist ;
        end 
        B2 : begin 
            fmv_adr_x_w  = pu_pos_x_i ; 
            fmv_adr_y_w  = pu_pos_y_i ; 
            fmv_rd_ena_w = b2_exist ;
        end 
        default : begin 
            fmv_adr_x_w  = 0 ;
            fmv_adr_y_w  = 0 ;
            fmv_rd_ena_w = 0 ;
        end
        endcase  
    end 

    // mv read
    always @* begin 
        // cur LCU mv
        cur_fmv_rd_ena_o    = 0 ;
        cur_fmv_rd_adr_o    = 0 ;
        // left LCU mv 
        lft_fmv_rd_ena_o    = 0 ;
        lft_fmv_rd_adr_o    = 0 ;
        // top LCU mv 
        top_fmv_rd_ena_o    = 0 ;
        top_fmv_rd_adr_o    = 0 ;
        if ( fmv_rd_ena_w ) begin 
            // top mv
            if ( fmv_adr_y_w == 0 ) begin 
                top_fmv_rd_ena_o    = fmv_rd_ena_w ;
                top_fmv_rd_adr_o    = fmv_adr_x_w -1 + (fme_ctu_x_i<<3) ; // including top-left mv
            end 
            // left mv
            else if ( fmv_adr_x_w == 0 ) begin 
                lft_fmv_rd_ena_o    = fmv_rd_ena_w ;
                lft_fmv_rd_adr_o    = fmv_adr_y_w - 1 ;
            end 
            // cur mv
            else begin 
                cur_fmv_rd_ena_o    = fmv_rd_ena_w ;
                cur_fmv_rd_adr_o    = ((fmv_adr_y_w-1)<<3) + fmv_adr_x_w-1 ;
            end 
        end 
        else begin 
            // cur LCU mv
            cur_fmv_rd_ena_o    = 0 ;
            cur_fmv_rd_adr_o    = 0 ;
            // left LCU mv 
            lft_fmv_rd_ena_o    = 0 ;
            lft_fmv_rd_adr_o    = 0 ;
            // top LCU mv 
            top_fmv_rd_ena_o    = 0 ;
            top_fmv_rd_adr_o    = 0 ;
        end 
    end 
    
    // delay mv read enable
    always @ ( posedge clk or negedge rstn ) begin 
    if ( !rstn ) begin 
        cur_fmv_rd_ena_d1 <= 0 ;
        top_fmv_rd_ena_d1 <= 0 ;
        lft_fmv_rd_ena_d1 <= 0 ;
    end else begin 
        cur_fmv_rd_ena_d1 <= cur_fmv_rd_ena_o ;
        top_fmv_rd_ena_d1 <= top_fmv_rd_ena_o ;
        lft_fmv_rd_ena_d1 <= lft_fmv_rd_ena_o ;
    end 
    end 
    
    assign fmv_dat_w =    cur_fmv_rd_ena_d1 ? cur_fmv_rd_dat_i 
                       : (top_fmv_rd_ena_d1 ? top_fmv_rd_dat_i
                       : (lft_fmv_rd_ena_d1 ? lft_fmv_rd_dat_i : 0)) ;
    
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) 
            curr_state_d1 <= 0 ;
        else 
            curr_state_d1 <= curr_state ;
    end     

    always @(posedge clk or negedge rstn) begin 
        if ( !rstn ) begin 
            mv_candi_a0_dat_o <= 0 ;
            mv_candi_a1_dat_o <= 0 ;
            mv_candi_b0_dat_o <= 0 ;
            mv_candi_b1_dat_o <= 0 ;
            mv_candi_b2_dat_o <= 0 ;
            mv_candi_a0_val_o <= 0 ;
            mv_candi_a1_val_o <= 0 ;
            mv_candi_b0_val_o <= 0 ;
            mv_candi_b1_val_o <= 0 ;
            mv_candi_b2_val_o <= 0 ;
        end else if ( pu_start_i ) begin 
            mv_candi_a0_dat_o <= 0 ;
            mv_candi_a1_dat_o <= 0 ;
            mv_candi_b0_dat_o <= 0 ;
            mv_candi_b1_dat_o <= 0 ;
            mv_candi_b2_dat_o <= 0 ;
            mv_candi_a0_val_o <= 0 ;
            mv_candi_a1_val_o <= 0 ;
            mv_candi_b0_val_o <= 0 ;
            mv_candi_b1_val_o <= 0 ;
            mv_candi_b2_val_o <= 0 ;
        end else begin 
            case (curr_state_d1)
                A0 : begin mv_candi_a0_dat_o <= fmv_dat_w ; mv_candi_a0_val_o <= 1'b1 ; end 
                A1 : begin mv_candi_a1_dat_o <= fmv_dat_w ; mv_candi_a1_val_o <= 1'b1 ; end 
                B0 : begin mv_candi_b0_dat_o <= fmv_dat_w ; mv_candi_b0_val_o <= 1'b1 ; end 
                B1 : begin mv_candi_b1_dat_o <= fmv_dat_w ; mv_candi_b1_val_o <= 1'b1 ; end 
                B2 : begin mv_candi_b2_dat_o <= fmv_dat_w ; mv_candi_b2_val_o <= 1'b1 ; end 
                default : ;
            endcase 
        end 
    end 

    assign non_mv_exist_w = {a0_exist, a1_exist, b0_exist, b1_exist, b2_exist} == 0 ;
    
    always @ (posedge clk or negedge rstn ) begin 
        if ( !rstn )
            fmv_candi_rdy_o <= 0 ;
        else if ( (curr_state_d1 != IDLE && curr_state == IDLE ) || ( non_mv_exist_w && pu_start_i ) )
            fmv_candi_rdy_o <= 1 ;
        else 
            fmv_candi_rdy_o <= 0 ;
    end 
    
endmodule 