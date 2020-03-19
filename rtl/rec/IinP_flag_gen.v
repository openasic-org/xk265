//-------------------------------------------------------------------
//
//  Filename      : IinP_flag_gen.v
//  Author        : TANG
//  Created       : 2018-07-09-25
//  Description   : generate IinP flag for dbsao/cabac and fme
//
//------------------------------------------------------------------
`include "enc_defines.v"

module IinP_flag_gen(
    clk             ,
    rstn            ,
    // clear if 
    clear_i         ,
    // start signal 
    start_i         ,
    start_r         ,
    // ctu position
    ctu_y_cur_i     ,
    ctu_x_cur_i     ,
    ctu_x_all_i     ,
    // ctu type
    type_i          ,
    type_r          ,
    // flag output
    fme_IinP_flag_o ,
    IinP_flag_o    

);

//--- input / output -----------------------------
    input                               clk             ;
    input                               rstn            ;
    input                               clear_i         ;
    input                               start_i         ;
    input                               start_r         ;
    input  [`PIC_X_WIDTH -1 :0]         ctu_x_cur_i     ;
    input  [`PIC_Y_WIDTH -1 :0]         ctu_y_cur_i     ;
    input  [`PIC_X_WIDTH -1 :0]         ctu_x_all_i     ;
    input                               type_i          ;
    input                               type_r          ;
    output [4-1:0]                      fme_IinP_flag_o ;
    output [3-1:0]                      IinP_flag_o     ;

//--- wire / reg ----------------------------------
    wire                                IinP_valid_w    ;
    reg    [(1<<`PIC_X_WIDTH)-1 :0]     IinP_array_r    ; // one line
    reg                                 IinP_lft_flg_r  ;
    reg                                 IinP_top_flg_r  ;
    reg    [1:0]                        fme_IinP_top_flg_r  ;
    wire   [3-1:0]                      IinP_flag_o     ;
    reg    [4-1:0]                      fme_IinP_flag_o ;

//--- main body ------------------------------------
    assign IinP_valid_w = (type_i==`INTER) && (type_r==`INTRA) ;

    // array and left flag
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            IinP_array_r <= 0 ;
            IinP_lft_flg_r <= 0 ;
        end 
        else if ( clear_i ) begin 
            IinP_array_r <= 0 ;
            IinP_lft_flg_r <= 0 ;
        end 
        else if ( start_r == 1 ) begin 
            case ( ctu_x_cur_i )
                0  : begin IinP_array_r[0 ] <= IinP_valid_w ; IinP_lft_flg_r <= 0 ;end 
                1  : begin IinP_array_r[1 ] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[0 ] ;end 
                2  : begin IinP_array_r[2 ] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[1 ] ;end 
                3  : begin IinP_array_r[3 ] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[2 ] ;end 
                4  : begin IinP_array_r[4 ] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[3 ] ;end 
                5  : begin IinP_array_r[5 ] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[4 ] ;end 
                6  : begin IinP_array_r[6 ] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[5 ] ;end 
                7  : begin IinP_array_r[7 ] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[6 ] ;end 
                8  : begin IinP_array_r[8 ] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[7 ] ;end 
                9  : begin IinP_array_r[9 ] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[8 ] ;end 
                10 : begin IinP_array_r[10] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[9 ] ;end 
                11 : begin IinP_array_r[11] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[10] ;end 
                12 : begin IinP_array_r[12] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[11] ;end 
                13 : begin IinP_array_r[13] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[12] ;end 
                14 : begin IinP_array_r[14] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[13] ;end 
                15 : begin IinP_array_r[15] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[14] ;end 
                16 : begin IinP_array_r[16] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[15] ;end 
                17 : begin IinP_array_r[17] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[16] ;end 
                18 : begin IinP_array_r[18] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[17] ;end 
                19 : begin IinP_array_r[19] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[18] ;end 
                20 : begin IinP_array_r[20] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[19] ;end 
                21 : begin IinP_array_r[21] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[20] ;end 
                22 : begin IinP_array_r[22] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[21] ;end 
                23 : begin IinP_array_r[23] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[22] ;end 
                24 : begin IinP_array_r[24] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[23] ;end 
                25 : begin IinP_array_r[25] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[24] ;end 
                26 : begin IinP_array_r[26] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[25] ;end 
                27 : begin IinP_array_r[27] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[26] ;end 
                28 : begin IinP_array_r[28] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[27] ;end 
                29 : begin IinP_array_r[29] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[28] ;end 
                30 : begin IinP_array_r[30] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[29] ;end 
                31 : begin IinP_array_r[31] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[30] ;end 
                32 : begin IinP_array_r[32] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[31] ;end 
                33 : begin IinP_array_r[33] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[32] ;end 
                34 : begin IinP_array_r[34] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[33] ;end 
                35 : begin IinP_array_r[35] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[34] ;end 
                36 : begin IinP_array_r[36] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[35] ;end 
                37 : begin IinP_array_r[37] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[36] ;end 
                38 : begin IinP_array_r[38] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[37] ;end 
                39 : begin IinP_array_r[39] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[38] ;end 
                40 : begin IinP_array_r[40] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[39] ;end 
                41 : begin IinP_array_r[41] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[40] ;end 
                42 : begin IinP_array_r[42] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[41] ;end 
                43 : begin IinP_array_r[43] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[42] ;end 
                44 : begin IinP_array_r[44] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[43] ;end 
                45 : begin IinP_array_r[45] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[44] ;end 
                46 : begin IinP_array_r[46] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[45] ;end 
                47 : begin IinP_array_r[47] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[46] ;end 
                48 : begin IinP_array_r[48] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[47] ;end 
                49 : begin IinP_array_r[49] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[48] ;end 
                50 : begin IinP_array_r[50] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[49] ;end 
                51 : begin IinP_array_r[51] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[50] ;end 
                52 : begin IinP_array_r[52] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[51] ;end 
                53 : begin IinP_array_r[53] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[52] ;end 
                54 : begin IinP_array_r[54] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[53] ;end 
                55 : begin IinP_array_r[55] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[54] ;end 
                56 : begin IinP_array_r[56] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[55] ;end 
                57 : begin IinP_array_r[57] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[56] ;end 
                58 : begin IinP_array_r[58] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[57] ;end 
                59 : begin IinP_array_r[59] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[58] ;end 
                60 : begin IinP_array_r[60] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[59] ;end 
                61 : begin IinP_array_r[61] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[60] ;end 
                62 : begin IinP_array_r[62] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[61] ;end 
                63 : begin IinP_array_r[63] <= IinP_valid_w ; IinP_lft_flg_r <= IinP_array_r[62] ;end 
            endcase 
        end 
    end 

    // top flag 
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            IinP_top_flg_r      <= 0 ;
            fme_IinP_top_flg_r  <= 0 ;
        end else if ( ctu_y_cur_i == 0 ) begin 
            IinP_top_flg_r      <= 0 ;
            fme_IinP_top_flg_r  <= 0 ;
        end else if ( start_i == 1 ) begin 
            case ( ctu_x_cur_i )
                0  : begin IinP_top_flg_r <= IinP_array_r[0 ]; fme_IinP_top_flg_r <= IinP_array_r[2 :1 ] ;end 
                1  : begin IinP_top_flg_r <= IinP_array_r[1 ]; fme_IinP_top_flg_r <= IinP_array_r[3 :2 ] ;end 
                2  : begin IinP_top_flg_r <= IinP_array_r[2 ]; fme_IinP_top_flg_r <= IinP_array_r[4 :3 ] ;end 
                3  : begin IinP_top_flg_r <= IinP_array_r[3 ]; fme_IinP_top_flg_r <= IinP_array_r[5 :4 ] ;end 
                4  : begin IinP_top_flg_r <= IinP_array_r[4 ]; fme_IinP_top_flg_r <= IinP_array_r[6 :5 ] ;end 
                5  : begin IinP_top_flg_r <= IinP_array_r[5 ]; fme_IinP_top_flg_r <= IinP_array_r[7 :6 ] ;end 
                6  : begin IinP_top_flg_r <= IinP_array_r[6 ]; fme_IinP_top_flg_r <= IinP_array_r[8 :7 ] ;end 
                7  : begin IinP_top_flg_r <= IinP_array_r[7 ]; fme_IinP_top_flg_r <= IinP_array_r[9 :8 ] ;end 
                8  : begin IinP_top_flg_r <= IinP_array_r[8 ]; fme_IinP_top_flg_r <= IinP_array_r[10:9 ] ;end 
                9  : begin IinP_top_flg_r <= IinP_array_r[9 ]; fme_IinP_top_flg_r <= IinP_array_r[11:10] ;end 
                10 : begin IinP_top_flg_r <= IinP_array_r[10]; fme_IinP_top_flg_r <= IinP_array_r[12:11] ;end 
                11 : begin IinP_top_flg_r <= IinP_array_r[11]; fme_IinP_top_flg_r <= IinP_array_r[13:12] ;end 
                12 : begin IinP_top_flg_r <= IinP_array_r[12]; fme_IinP_top_flg_r <= IinP_array_r[14:13] ;end 
                13 : begin IinP_top_flg_r <= IinP_array_r[13]; fme_IinP_top_flg_r <= IinP_array_r[15:14] ;end 
                14 : begin IinP_top_flg_r <= IinP_array_r[14]; fme_IinP_top_flg_r <= IinP_array_r[16:15] ;end 
                15 : begin IinP_top_flg_r <= IinP_array_r[15]; fme_IinP_top_flg_r <= IinP_array_r[17:16] ;end 
                16 : begin IinP_top_flg_r <= IinP_array_r[16]; fme_IinP_top_flg_r <= IinP_array_r[18:17] ;end 
                17 : begin IinP_top_flg_r <= IinP_array_r[17]; fme_IinP_top_flg_r <= IinP_array_r[19:18] ;end 
                18 : begin IinP_top_flg_r <= IinP_array_r[18]; fme_IinP_top_flg_r <= IinP_array_r[20:19] ;end 
                19 : begin IinP_top_flg_r <= IinP_array_r[19]; fme_IinP_top_flg_r <= IinP_array_r[21:20] ;end 
                20 : begin IinP_top_flg_r <= IinP_array_r[20]; fme_IinP_top_flg_r <= IinP_array_r[22:21] ;end 
                21 : begin IinP_top_flg_r <= IinP_array_r[21]; fme_IinP_top_flg_r <= IinP_array_r[23:22] ;end 
                22 : begin IinP_top_flg_r <= IinP_array_r[22]; fme_IinP_top_flg_r <= IinP_array_r[24:23] ;end 
                23 : begin IinP_top_flg_r <= IinP_array_r[23]; fme_IinP_top_flg_r <= IinP_array_r[25:24] ;end 
                24 : begin IinP_top_flg_r <= IinP_array_r[24]; fme_IinP_top_flg_r <= IinP_array_r[26:25] ;end 
                25 : begin IinP_top_flg_r <= IinP_array_r[25]; fme_IinP_top_flg_r <= IinP_array_r[27:26] ;end 
                26 : begin IinP_top_flg_r <= IinP_array_r[26]; fme_IinP_top_flg_r <= IinP_array_r[28:27] ;end 
                27 : begin IinP_top_flg_r <= IinP_array_r[27]; fme_IinP_top_flg_r <= IinP_array_r[29:28] ;end 
                28 : begin IinP_top_flg_r <= IinP_array_r[28]; fme_IinP_top_flg_r <= IinP_array_r[30:29] ;end 
                29 : begin IinP_top_flg_r <= IinP_array_r[29]; fme_IinP_top_flg_r <= IinP_array_r[31:30] ;end 
                30 : begin IinP_top_flg_r <= IinP_array_r[30]; fme_IinP_top_flg_r <= IinP_array_r[32:31] ;end 
                31 : begin IinP_top_flg_r <= IinP_array_r[31]; fme_IinP_top_flg_r <= IinP_array_r[33:32] ;end 
                32 : begin IinP_top_flg_r <= IinP_array_r[32]; fme_IinP_top_flg_r <= IinP_array_r[34:33] ;end 
                33 : begin IinP_top_flg_r <= IinP_array_r[33]; fme_IinP_top_flg_r <= IinP_array_r[35:34] ;end 
                34 : begin IinP_top_flg_r <= IinP_array_r[34]; fme_IinP_top_flg_r <= IinP_array_r[36:35] ;end 
                35 : begin IinP_top_flg_r <= IinP_array_r[35]; fme_IinP_top_flg_r <= IinP_array_r[37:36] ;end 
                36 : begin IinP_top_flg_r <= IinP_array_r[36]; fme_IinP_top_flg_r <= IinP_array_r[38:37] ;end 
                37 : begin IinP_top_flg_r <= IinP_array_r[37]; fme_IinP_top_flg_r <= IinP_array_r[39:38] ;end 
                38 : begin IinP_top_flg_r <= IinP_array_r[38]; fme_IinP_top_flg_r <= IinP_array_r[40:39] ;end 
                39 : begin IinP_top_flg_r <= IinP_array_r[39]; fme_IinP_top_flg_r <= IinP_array_r[41:40] ;end 
                40 : begin IinP_top_flg_r <= IinP_array_r[40]; fme_IinP_top_flg_r <= IinP_array_r[42:41] ;end 
                41 : begin IinP_top_flg_r <= IinP_array_r[41]; fme_IinP_top_flg_r <= IinP_array_r[43:42] ;end 
                42 : begin IinP_top_flg_r <= IinP_array_r[42]; fme_IinP_top_flg_r <= IinP_array_r[44:43] ;end 
                43 : begin IinP_top_flg_r <= IinP_array_r[43]; fme_IinP_top_flg_r <= IinP_array_r[45:44] ;end 
                44 : begin IinP_top_flg_r <= IinP_array_r[44]; fme_IinP_top_flg_r <= IinP_array_r[46:45] ;end 
                45 : begin IinP_top_flg_r <= IinP_array_r[45]; fme_IinP_top_flg_r <= IinP_array_r[47:46] ;end 
                46 : begin IinP_top_flg_r <= IinP_array_r[46]; fme_IinP_top_flg_r <= IinP_array_r[48:47] ;end 
                47 : begin IinP_top_flg_r <= IinP_array_r[47]; fme_IinP_top_flg_r <= IinP_array_r[49:48] ;end 
                48 : begin IinP_top_flg_r <= IinP_array_r[48]; fme_IinP_top_flg_r <= IinP_array_r[50:49] ;end 
                49 : begin IinP_top_flg_r <= IinP_array_r[49]; fme_IinP_top_flg_r <= IinP_array_r[51:50] ;end 
                50 : begin IinP_top_flg_r <= IinP_array_r[50]; fme_IinP_top_flg_r <= IinP_array_r[52:51] ;end 
                51 : begin IinP_top_flg_r <= IinP_array_r[51]; fme_IinP_top_flg_r <= IinP_array_r[53:52] ;end 
                52 : begin IinP_top_flg_r <= IinP_array_r[52]; fme_IinP_top_flg_r <= IinP_array_r[54:53] ;end 
                53 : begin IinP_top_flg_r <= IinP_array_r[53]; fme_IinP_top_flg_r <= IinP_array_r[55:54] ;end 
                54 : begin IinP_top_flg_r <= IinP_array_r[54]; fme_IinP_top_flg_r <= IinP_array_r[56:55] ;end 
                55 : begin IinP_top_flg_r <= IinP_array_r[55]; fme_IinP_top_flg_r <= IinP_array_r[57:56] ;end 
                56 : begin IinP_top_flg_r <= IinP_array_r[56]; fme_IinP_top_flg_r <= IinP_array_r[58:57] ;end 
                57 : begin IinP_top_flg_r <= IinP_array_r[57]; fme_IinP_top_flg_r <= IinP_array_r[59:58] ;end 
                58 : begin IinP_top_flg_r <= IinP_array_r[58]; fme_IinP_top_flg_r <= IinP_array_r[60:59] ;end 
                59 : begin IinP_top_flg_r <= IinP_array_r[59]; fme_IinP_top_flg_r <= IinP_array_r[61:60] ;end 
                60 : begin IinP_top_flg_r <= IinP_array_r[60]; fme_IinP_top_flg_r <= IinP_array_r[62:61] ;end 
                61 : begin IinP_top_flg_r <= IinP_array_r[61]; fme_IinP_top_flg_r <= IinP_array_r[63:62] ;end 
                62 : begin IinP_top_flg_r <= IinP_array_r[62]; fme_IinP_top_flg_r <= {1'b0,IinP_array_r[63]} ;end 
                63 : begin IinP_top_flg_r <= IinP_array_r[63]; fme_IinP_top_flg_r <= IinP_array_r[1:0]  ;end 
            endcase 
        end 
    end 

    // output 
    // for dbsao and cabac {top, left, cur}
    assign IinP_flag_o = {IinP_top_flg_r, IinP_lft_flg_r, IinP_valid_w} ;

    // for fme {topright, topleft, top, left}
    always @* begin 
        fme_IinP_flag_o = 0 ;
        if ( ctu_x_cur_i == ctu_x_all_i ) // fme is processing the ctu whose ctu_x = 0, top left is 0
            fme_IinP_flag_o = {fme_IinP_top_flg_r[1], 1'b0, fme_IinP_top_flg_r[0], 1'b0} ;
        else 
            fme_IinP_flag_o = {fme_IinP_top_flg_r[1], IinP_top_flg_r, fme_IinP_top_flg_r[0], IinP_valid_w} ;
    end 



endmodule 
