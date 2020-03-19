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
// Filename       : sao_top.v
// Author         : TANG
// Created     : 12/19/2017
// Description    :         
//------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module sao_top(
        clk                 ,// sys IF
        rst_n               ,  
        sys_sao_ena_i       ,         
        state_i             ,
        bo_predecision      ,
        // cfg_if
        sao_4x4_x_i         ,
        sao_4x4_y_i         ,
        sao_sel_i           , // YUV
        // rec
        rec_line_i_0        ,
        rec_line_i_1        ,
        rec_line_i_2        ,
        rec_line_i_3        ,
        rec_line_i_4        ,
        rec_line_i_5        , 
        // ori 
        ori_line_i_0        ,
        ori_line_i_1        ,
        ori_line_i_2        ,
        ori_line_i_3        ,
        // output IF 
        sao_block_o         ,
        sao_data_o            // {merge_top[61],merge_left[60],{sao_type,sao_subIdx,sao_offsetx4, 3, 2, 1}{chroma,luma}}
);

input                             clk, rst_n              ; // sys IF  
input                             sys_sao_ena_i           ;     
input         [  14 :0]           bo_predecision          ;
input         [   2 :0]           state_i                 ;

input         [4  -1:0]           sao_4x4_x_i             ;
input         [4  -1:0]           sao_4x4_y_i             ;
input         [2  -1:0]           sao_sel_i               ;

input         [6*8-1:0]           rec_line_i_0            ;
input         [6*8-1:0]           rec_line_i_1            ;
input         [6*8-1:0]           rec_line_i_2            ;
input         [6*8-1:0]           rec_line_i_3            ;
input         [6*8-1:0]           rec_line_i_4            ;
input         [6*8-1:0]           rec_line_i_5            ;

input         [4*8-1:0]           ori_line_i_0            ;
input         [4*8-1:0]           ori_line_i_1            ;
input         [4*8-1:0]           ori_line_i_2            ;
input         [4*8-1:0]           ori_line_i_3            ;

output        [  61 :0]           sao_data_o              ;
output        [16*8-1:0]          sao_block_o             ;



//*************************************************************************
//
//      Parameter Declaration
//
//*************************************************************************
parameter IDLE = 3'b000, LOAD = 3'b001, DBY = 3'b011, DBU = 3'b010, DBV = 3'b110, SAO = 3'b100, OUT = 3'b101;
parameter PIXEL_WIDTH   =    8                          ;
parameter SAO_DIF_WIDTH = 18 ;
parameter SAO_NUM_WIDTH = 12 ;
parameter SAO_DIS_WIDTH = 20 ;

wire          [16 -1:0]           EO_0_0                  ;
wire          [16 -1:0]           EO_0_1                  ;
wire          [16 -1:0]           EO_0_2                  ;
wire          [16 -1:0]           EO_0_3                  ;
wire          [16 -1:0]           EO_45_0                 ; 
wire          [16 -1:0]           EO_45_1                 ; 
wire          [16 -1:0]           EO_45_2                 ; 
wire          [16 -1:0]           EO_45_3                 ; 
wire          [16 -1:0]           EO_90_0                 ; 
wire          [16 -1:0]           EO_90_1                 ; 
wire          [16 -1:0]           EO_90_2                 ; 
wire          [16 -1:0]           EO_90_3                 ; 
wire          [16 -1:0]           EO_135_0                ; 
wire          [16 -1:0]           EO_135_1                ; 
wire          [16 -1:0]           EO_135_2                ; 
wire          [16 -1:0]           EO_135_3                ; 
wire          [16 -1:0]           BO_0                    ;
wire          [16 -1:0]           BO_1                    ;
wire          [16 -1:0]           BO_2                    ;
wire          [16 -1:0]           BO_3                    ;
wire          [16 -1:0]           BO_4                    ;
wire          [16 -1:0]           BO_5                    ;
wire          [16 -1:0]           BO_6                    ;
wire          [16 -1:0]           BO_7                    ;

wire          [ SAO_NUM_WIDTH-1 :0] EO_0_0_num_o          ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_0_0_diff_o         ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_0_1_num_o          ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_0_1_diff_o         ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_0_2_num_o          ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_0_2_diff_o         ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_0_3_num_o          ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_0_3_diff_o         ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_45_0_num_o         ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_45_0_diff_o        ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_45_1_num_o         ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_45_1_diff_o        ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_45_2_num_o         ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_45_2_diff_o        ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_45_3_num_o         ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_45_3_diff_o        ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_90_0_num_o         ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_90_0_diff_o        ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_90_1_num_o         ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_90_1_diff_o        ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_90_2_num_o         ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_90_2_diff_o        ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_90_3_num_o         ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_90_3_diff_o        ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_135_0_num_o        ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_135_0_diff_o       ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_135_1_num_o        ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_135_1_diff_o       ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_135_2_num_o        ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_135_2_diff_o       ;
wire          [ SAO_NUM_WIDTH-1 :0] EO_135_3_num_o        ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] EO_135_3_diff_o       ;
wire          [ SAO_NUM_WIDTH-1 :0] BO_0_num_o            ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] BO_0_diff_o           ;
wire          [ SAO_NUM_WIDTH-1 :0] BO_1_num_o            ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] BO_1_diff_o           ;
wire          [ SAO_NUM_WIDTH-1 :0] BO_2_num_o            ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] BO_2_diff_o           ;
wire          [ SAO_NUM_WIDTH-1 :0] BO_3_num_o            ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] BO_3_diff_o           ;
wire          [ SAO_NUM_WIDTH-1 :0] BO_4_num_o            ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] BO_4_diff_o           ;
wire          [ SAO_NUM_WIDTH-1 :0] BO_5_num_o            ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] BO_5_diff_o           ;
wire          [ SAO_NUM_WIDTH-1 :0] BO_6_num_o            ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] BO_6_diff_o           ;
wire          [ SAO_NUM_WIDTH-1 :0] BO_7_num_o            ;
wire  signed  [ SAO_DIF_WIDTH-1 :0] BO_7_diff_o           ;

// delay sao_x_i..
wire          [4  -1:0]           sao_4x4_x_w             ;
wire          [4  -1:0]           sao_4x4_y_w             ;
wire          [2  -1:0]           sao_sel_w               ;

// first bo yuv
wire          [4    :0]           y_first_bo              ;
wire          [4    :0]           u_first_bo              ;
wire          [4    :0]           v_first_bo              ;
assign y_first_bo = bo_predecision[4:0] ;
assign u_first_bo = bo_predecision[9:5] ;
assign v_first_bo = bo_predecision[14:10];

wire [4:0] mode_bo_w ;
assign mode_bo_w = ( sao_sel_i == `TYPE_Y ) ? y_first_bo : 
                  (( sao_sel_i == `TYPE_U ) ? u_first_bo : 
                   ( sao_sel_i == `TYPE_V   ? v_first_bo : 0));

sao_mode u_mode (
        .clk            ( clk            ) ,
        .rst_n          ( rst_n          ) ,
        .state_i        ( state_i        ) ,
        .bo_predecision ( mode_bo_w      ) ,
        .sao_4x4_x_i    ( sao_4x4_x_i    ) ,
        .sao_4x4_y_i    ( sao_4x4_y_i    ) ,
        .sao_sel_i      ( sao_sel_i      ) ,
        .rec_line_i_0   ( rec_line_i_0   ) ,
        .rec_line_i_1   ( rec_line_i_1   ) ,
        .rec_line_i_2   ( rec_line_i_2   ) ,
        .rec_line_i_3   ( rec_line_i_3   ) ,
        .rec_line_i_4   ( rec_line_i_4   ) ,
        .rec_line_i_5   ( rec_line_i_5   ) ,
        .EO_0_0_o       ( EO_0_0         ) ,
        .EO_0_1_o       ( EO_0_1         ) ,
        .EO_0_2_o       ( EO_0_2         ) ,
        .EO_0_3_o       ( EO_0_3         ) ,
        .EO_45_0_o      ( EO_45_0        ) ,
        .EO_45_1_o      ( EO_45_1        ) ,
        .EO_45_2_o      ( EO_45_2        ) ,
        .EO_45_3_o      ( EO_45_3        ) ,
        .EO_90_0_o      ( EO_90_0        ) ,
        .EO_90_1_o      ( EO_90_1        ) ,
        .EO_90_2_o      ( EO_90_2        ) ,
        .EO_90_3_o      ( EO_90_3        ) ,
        .EO_135_0_o     ( EO_135_0       ) ,
        .EO_135_1_o     ( EO_135_1       ) ,
        .EO_135_2_o     ( EO_135_2       ) ,
        .EO_135_3_o     ( EO_135_3       ) ,
        .BO_0_o         ( BO_0           ) ,
        .BO_1_o         ( BO_1           ) ,
        .BO_2_o         ( BO_2           ) ,
        .BO_3_o         ( BO_3           ) ,
        .BO_4_o         ( BO_4           ) ,
        .BO_5_o         ( BO_5           ) ,
        .BO_6_o         ( BO_6           ) ,
        .BO_7_o         ( BO_7           )   
);


sao_statistic u_sao_statistic(
        .clk            ( clk            ) ,// sys IF
        .rst_n          ( rst_n          ) ,
        .state_i        ( state_i        ) ,
        .sao_4x4_x_i    ( sao_4x4_x_i    ) ,
        .sao_4x4_y_i    ( sao_4x4_y_i    ) ,
        .sao_sel_i      ( sao_sel_i      ) ,
        .sao_4x4_x_o    ( sao_4x4_x_w    ) ,
        .sao_4x4_y_o    ( sao_4x4_y_w    ) ,
        .sao_sel_o      ( sao_sel_w      ) ,
        .rec_line_i_1   ( rec_line_i_1   ) ,
        .rec_line_i_2   ( rec_line_i_2   ) ,
        .rec_line_i_3   ( rec_line_i_3   ) ,
        .rec_line_i_4   ( rec_line_i_4   ) ,
        .ori_line_i_0   ( ori_line_i_0   ) ,
        .ori_line_i_1   ( ori_line_i_1   ) ,
        .ori_line_i_2   ( ori_line_i_2   ) ,
        .ori_line_i_3   ( ori_line_i_3   ) ,
        .EO_0_0_i       ( EO_0_0         ) ,
        .EO_0_1_i       ( EO_0_1         ) ,
        .EO_0_2_i       ( EO_0_2         ) ,
        .EO_0_3_i       ( EO_0_3         ) ,
        .EO_45_0_i      ( EO_45_0        ) ,
        .EO_45_1_i      ( EO_45_1        ) ,
        .EO_45_2_i      ( EO_45_2        ) ,
        .EO_45_3_i      ( EO_45_3        ) ,
        .EO_90_0_i      ( EO_90_0        ) ,
        .EO_90_1_i      ( EO_90_1        ) ,
        .EO_90_2_i      ( EO_90_2        ) ,
        .EO_90_3_i      ( EO_90_3        ) ,
        .EO_135_0_i     ( EO_135_0       ) ,
        .EO_135_1_i     ( EO_135_1       ) ,
        .EO_135_2_i     ( EO_135_2       ) ,
        .EO_135_3_i     ( EO_135_3       ) ,
        .BO_0_i         ( BO_0           ) ,
        .BO_1_i         ( BO_1           ) ,
        .BO_2_i         ( BO_2           ) ,
        .BO_3_i         ( BO_3           ) ,
        .BO_4_i         ( BO_4           ) ,
        .BO_5_i         ( BO_5           ) ,
        .BO_6_i         ( BO_6           ) ,
        .BO_7_i         ( BO_7           ) ,

        .EO_0_0_num_o   ( EO_0_0_num_o   ),// output number and sum of diffs
        .EO_0_0_diff_o  ( EO_0_0_diff_o  ),
        .EO_0_1_num_o   ( EO_0_1_num_o   ),
        .EO_0_1_diff_o  ( EO_0_1_diff_o  ),
        .EO_0_2_num_o   ( EO_0_2_num_o   ),
        .EO_0_2_diff_o  ( EO_0_2_diff_o  ),
        .EO_0_3_num_o   ( EO_0_3_num_o   ),
        .EO_0_3_diff_o  ( EO_0_3_diff_o  ),
        .EO_45_0_num_o  ( EO_45_0_num_o  ),
        .EO_45_0_diff_o ( EO_45_0_diff_o ),
        .EO_45_1_num_o  ( EO_45_1_num_o  ),
        .EO_45_1_diff_o ( EO_45_1_diff_o ),
        .EO_45_2_num_o  ( EO_45_2_num_o  ),
        .EO_45_2_diff_o ( EO_45_2_diff_o ),
        .EO_45_3_num_o  ( EO_45_3_num_o  ),
        .EO_45_3_diff_o ( EO_45_3_diff_o ),
        .EO_90_0_num_o  ( EO_90_0_num_o  ),
        .EO_90_0_diff_o ( EO_90_0_diff_o ),
        .EO_90_1_num_o  ( EO_90_1_num_o  ),
        .EO_90_1_diff_o ( EO_90_1_diff_o ),
        .EO_90_2_num_o  ( EO_90_2_num_o  ),
        .EO_90_2_diff_o ( EO_90_2_diff_o ),
        .EO_90_3_num_o  ( EO_90_3_num_o  ),
        .EO_90_3_diff_o ( EO_90_3_diff_o ),
        .EO_135_0_num_o ( EO_135_0_num_o ),
        .EO_135_0_diff_o( EO_135_0_diff_o),
        .EO_135_1_num_o ( EO_135_1_num_o ),
        .EO_135_1_diff_o( EO_135_1_diff_o),
        .EO_135_2_num_o ( EO_135_2_num_o ),
        .EO_135_2_diff_o( EO_135_2_diff_o),
        .EO_135_3_num_o ( EO_135_3_num_o ),
        .EO_135_3_diff_o( EO_135_3_diff_o),
        .BO_0_num_o     ( BO_0_num_o     ),
        .BO_0_diff_o    ( BO_0_diff_o    ),
        .BO_1_num_o     ( BO_1_num_o     ),
        .BO_1_diff_o    ( BO_1_diff_o    ),
        .BO_2_num_o     ( BO_2_num_o     ),
        .BO_2_diff_o    ( BO_2_diff_o    ),
        .BO_3_num_o     ( BO_3_num_o     ),
        .BO_3_diff_o    ( BO_3_diff_o    ),
        .BO_4_num_o     ( BO_4_num_o     ),
        .BO_4_diff_o    ( BO_4_diff_o    ),
        .BO_5_num_o     ( BO_5_num_o     ),
        .BO_5_diff_o    ( BO_5_diff_o    ),
        .BO_6_num_o     ( BO_6_num_o     ),
        .BO_6_diff_o    ( BO_6_diff_o    ),
        .BO_7_num_o     ( BO_7_num_o     ),
        .BO_7_diff_o    ( BO_7_diff_o    )
    ); 



reg     signed      [SAO_DIF_WIDTH-1:0]    stat           ;
reg                 [SAO_NUM_WIDTH-1:0]    num            ;
wire    signed      [     2         :0]    offset         ;
wire    signed      [SAO_DIS_WIDTH-1:0]    distortion     ;   
reg                 [     4         :0]    mode_cnt       ;
reg                                        mode_cnt_start ;
always @(posedge clk or negedge rst_n) begin
    if ( !rst_n )
        mode_cnt_start      <= 1'b0;
    else if (  state_i == SAO 
           &&(( sao_sel_w == `TYPE_Y && sao_4x4_y_w == 14 && sao_4x4_x_w == 14 ) 
           || ( sao_sel_w == `TYPE_U && sao_4x4_y_w == 6  && sao_4x4_x_w == 6  )
           || ( sao_sel_w == `TYPE_V && sao_4x4_y_w == 6  && sao_4x4_x_w == 6  )))
        mode_cnt_start      <= 1'b1;
    else if ( mode_cnt == 5'd23 )
        mode_cnt_start      <= 1'b0;
end 

always @ (posedge clk or negedge rst_n) begin 
    if ( !rst_n )
        mode_cnt           <= 5'd0;
    else if ( mode_cnt_start )
        mode_cnt           <= mode_cnt + 5'd1;
    else 
        mode_cnt           <= 5'd0;
end 

reg signed    [      2     :0]      offset_0_r          ;
reg signed    [      2     :0]      offset_1_r          ;
reg signed    [      2     :0]      offset_2_r          ;
reg signed    [      2     :0]      offset_3_r          ;

reg signed    [ SAO_DIS_WIDTH-1:0]  dis_0_r             ; 
reg signed    [ SAO_DIS_WIDTH-1:0]  dis_1_r             ; 
reg signed    [ SAO_DIS_WIDTH-1:0]  dis_2_r             ; 
reg signed    [ SAO_DIS_WIDTH-1:0]  dis_3_r             ; 

always @* begin 
    case (mode_cnt)
        5'd0    : begin stat = EO_0_0_diff_o   ;  num  = EO_0_0_num_o   ; end  
        5'd1    : begin stat = EO_0_1_diff_o   ;  num  = EO_0_1_num_o   ; end  
        5'd2    : begin stat = EO_0_2_diff_o   ;  num  = EO_0_2_num_o   ; end  
        5'd3    : begin stat = EO_0_3_diff_o   ;  num  = EO_0_3_num_o   ; end  
        5'd4    : begin stat = EO_45_0_diff_o  ;  num  = EO_45_0_num_o  ; end  
        5'd5    : begin stat = EO_45_1_diff_o  ;  num  = EO_45_1_num_o  ; end  
        5'd6    : begin stat = EO_45_2_diff_o  ;  num  = EO_45_2_num_o  ; end  
        5'd7    : begin stat = EO_45_3_diff_o  ;  num  = EO_45_3_num_o  ; end  
        5'd8    : begin stat = EO_90_0_diff_o  ;  num  = EO_90_0_num_o  ; end  
        5'd9    : begin stat = EO_90_1_diff_o  ;  num  = EO_90_1_num_o  ; end  
        5'd10   : begin stat = EO_90_2_diff_o  ;  num  = EO_90_2_num_o  ; end  
        5'd11   : begin stat = EO_90_3_diff_o  ;  num  = EO_90_3_num_o  ; end  
        5'd12   : begin stat = EO_135_0_diff_o ;  num  = EO_135_0_num_o ; end  
        5'd13   : begin stat = EO_135_1_diff_o ;  num  = EO_135_1_num_o ; end  
        5'd14   : begin stat = EO_135_2_diff_o ;  num  = EO_135_2_num_o ; end  
        5'd15   : begin stat = EO_135_3_diff_o ;  num  = EO_135_3_num_o ; end  
        5'd16   : begin stat = BO_0_diff_o     ;  num  = BO_0_num_o     ; end  
        5'd17   : begin stat = BO_1_diff_o     ;  num  = BO_1_num_o     ; end  
        5'd18   : begin stat = BO_2_diff_o     ;  num  = BO_2_num_o     ; end  
        5'd19   : begin stat = BO_3_diff_o     ;  num  = BO_3_num_o     ; end  
        5'd20   : begin stat = BO_4_diff_o     ;  num  = BO_4_num_o     ; end  
        5'd21   : begin stat = BO_5_diff_o     ;  num  = BO_5_num_o     ; end  
        5'd22   : begin stat = BO_6_diff_o     ;  num  = BO_6_num_o     ; end  
        5'd23   : begin stat = BO_7_diff_o     ;  num  = BO_7_num_o     ; end  
        default : begin stat = 0               ;  num  = 0              ; end 
    endcase 
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        offset_0_r   <= 0   ;  dis_0_r   <= 0 ;
        offset_1_r   <= 0   ;  dis_1_r   <= 0 ;
        offset_2_r   <= 0   ;  dis_2_r   <= 0 ;
        offset_3_r   <= 0   ;  dis_3_r   <= 0 ;
    end 
    else if ( mode_cnt_start )
        case ( mode_cnt[1:0] )
            5'd0    : begin offset_0_r <= offset ; dis_0_r  <= distortion ; end 
            5'd1    : begin offset_1_r <= offset ; dis_1_r  <= distortion ; end 
            5'd2    : begin offset_2_r <= offset ; dis_2_r  <= distortion ; end 
            5'd3    : begin offset_3_r <= offset ; dis_3_r  <= distortion ; end
            default : ;
        endcase 
    else begin 
        offset_0_r   <= 0   ;  dis_0_r   <= 0 ;
        offset_1_r   <= 0   ;  dis_1_r   <= 0 ;
        offset_2_r   <= 0   ;  dis_2_r   <= 0 ;
        offset_3_r   <= 0   ;  dis_3_r   <= 0 ;
    end 
end 

sao_cal_offset   uoffset(                           
             .stat_i       ( stat           ),
             .mode_cnt_i   ( mode_cnt       ),
             .num_i        ( num            ),
             .data_valid_i ( mode_cnt_start ),
             .offset_o     ( offset         ),
             .distortion_o ( distortion     ) 
             );

reg  signed  [              2:0 ] offset_0       ;
reg  signed  [              2:0 ] offset_1       ;
reg  signed  [              2:0 ] offset_2       ;
reg  signed  [              2:0 ] offset_3       ;
reg  signed  [SAO_DIS_WIDTH-1:0 ] distortion_0   ;
reg  signed  [SAO_DIS_WIDTH-1:0 ] distortion_1   ;
reg  signed  [SAO_DIS_WIDTH-1:0 ] distortion_2   ;
reg  signed  [SAO_DIS_WIDTH-1:0 ] distortion_3   ;
reg                               td_data_valid  ;

reg [4:0] mode_cnt_d1;
always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        mode_cnt_d1 <= 0;
    end 
    else begin 
        mode_cnt_d1 <= mode_cnt;
    end 
end 

always @ ( * ) begin 
        offset_0 = 0 ;  distortion_0 = 0 ;
        offset_1 = 0 ;  distortion_1 = 0 ;
        offset_2 = 0 ;  distortion_2 = 0 ;
        offset_3 = 0 ;  distortion_3 = 0 ;
        td_data_valid = 0 ;
    if (mode_cnt_d1[1:0] == 2'b11 || mode_cnt_d1>19) begin 
        offset_0 = offset_0_r;  distortion_0 = dis_0_r;
        offset_1 = offset_1_r;  distortion_1 = dis_1_r;
        offset_2 = offset_2_r;  distortion_2 = dis_2_r;
        offset_3 = offset_3_r;  distortion_3 = dis_3_r;
        td_data_valid = 1 ;
    end 
end 


wire [ 2:0] sao_type_w      ;
wire [ 4:0] sao_sub_type_w  ;
wire [11:0] sao_offset_w    ;
wire [4:0]  td_bo_w ;
reg  [1:0]  td_sel_r;
reg  [1:0]  td_sel_d1;

always @( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) 
        td_sel_r    <= `TYPE_Y ;
    else if ( sao_sel_w == `TYPE_Y && mode_cnt == 1 )
        td_sel_r    <= `TYPE_Y ;
    else if ( sao_sel_w == `TYPE_U && mode_cnt == 1 )
        td_sel_r    <= `TYPE_U ;
    else if ( sao_sel_w == `TYPE_V && mode_cnt == 1 )
        td_sel_r    <= `TYPE_V ;
end 

always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n ) 
        td_sel_d1 <= 0;
    else 
        td_sel_d1 <= td_sel_r ;
end 

assign td_bo_w   = ( td_sel_r == `TYPE_Y ) ? y_first_bo : 
                  (( td_sel_r == `TYPE_U ) ? u_first_bo : 
                   ( td_sel_r == `TYPE_V   ? v_first_bo : 0));

sao_type_decision u_type_decision(                  
                    .clk            ( clk              ),
                    .rst_n          ( rst_n            ),
                    .data_valid_i   ( td_data_valid    ),
                    .mode_cnt_i     ( mode_cnt_d1      ),
                    .bo_predecision ( td_bo_w          ),
                    .offset_0_i     ( offset_0         ),
                    .offset_1_i     ( offset_1         ),
                    .offset_2_i     ( offset_2         ),
                    .offset_3_i     ( offset_3         ),
                    .distortion_0_i ( distortion_0     ),
                    .distortion_1_i ( distortion_1     ),
                    .distortion_2_i ( distortion_2     ),
                    .distortion_3_i ( distortion_3     ),
                    .type_o         ( sao_type_w       ),
                    .sub_type_o     ( sao_sub_type_w   ),
                    .offset_o       ( sao_offset_w     )
                );   

reg [ 2:0] y_sao_type_r        ;
reg [ 4:0] y_sao_sub_type_r    ;
reg [11:0] y_sao_offset_r      ; 

reg [ 2:0] u_sao_type_r        ;
reg [ 4:0] u_sao_sub_type_r    ;
reg [11:0] u_sao_offset_r      ; 

reg [ 2:0] v_sao_type_r        ;
reg [ 4:0] v_sao_sub_type_r    ;
reg [11:0] v_sao_offset_r      ; 

always @ (posedge clk or negedge rst_n) begin 
    if ( !rst_n ) begin 
        y_sao_type_r     <= 'd0;
        y_sao_sub_type_r <= 'd0;
        y_sao_offset_r   <= 'd0;
        u_sao_type_r     <= 'd0;
        u_sao_sub_type_r <= 'd0;
        u_sao_offset_r   <= 'd0;
        v_sao_type_r     <= 'd0;
        v_sao_sub_type_r <= 'd0;
        v_sao_offset_r   <= 'd0;
    end else if ( sys_sao_ena_i == 0 ) begin 
        y_sao_type_r     <= 'd0;
        y_sao_sub_type_r <= 'd0;
        y_sao_offset_r   <= 'd0;
        u_sao_type_r     <= 'd0;
        u_sao_sub_type_r <= 'd0;
        u_sao_offset_r   <= 'd0;
        v_sao_type_r     <= 'd0;
        v_sao_sub_type_r <= 'd0;
        v_sao_offset_r   <= 'd0;
    end else if ( state_i == SAO && td_sel_d1 == `TYPE_Y && mode_cnt_d1 == 24 ) begin // Y
        y_sao_type_r     <= sao_type_w    ;
        y_sao_sub_type_r <= sao_sub_type_w;
        y_sao_offset_r   <= sao_offset_w  ;
    end else if ( state_i == SAO && td_sel_d1 == `TYPE_U && mode_cnt_d1 == 24 ) begin // U
        u_sao_type_r     <= sao_type_w    ;
        u_sao_sub_type_r <= sao_sub_type_w;
        u_sao_offset_r   <= sao_offset_w  ;
    end else if ( state_i == OUT && td_sel_d1 == `TYPE_V && mode_cnt_d1 == 24 ) begin // V
        v_sao_type_r     <= sao_type_w    ;
        v_sao_sub_type_r <= sao_sub_type_w;
        v_sao_offset_r   <= sao_offset_w  ;
    end 
end 


wire [4:0] offset_bo_w ;
assign offset_bo_w = ( sao_sel_i == `TYPE_Y ) ? y_first_bo : 
                    (( sao_sel_i == `TYPE_U ) ? u_first_bo : 
                     ( sao_sel_i == `TYPE_V   ? v_first_bo : 0));

sao_add_offset u_sao_add_offset(
                        .clk               ( clk                ) ,
                        .rst_n             ( rst_n              ) ,
                        .state_i           ( state_i            ) ,
                        .bo_predecision    ( offset_bo_w        ) ,
                        .sao_4x4_x_i       ( sao_4x4_x_i        ) ,
                        .sao_4x4_y_i       ( sao_4x4_y_i        ) ,
                        .sao_sel_i         ( sao_sel_i          ) ,
                        .rec_i_0           ( rec_line_i_0       ) ,
                        .rec_i_1           ( rec_line_i_1       ) ,
                        .rec_i_2           ( rec_line_i_2       ) ,
                        .rec_i_3           ( rec_line_i_3       ) ,
                        .rec_i_4           ( rec_line_i_4       ) ,
                        .EO_0_0            ( EO_0_0             ) ,
                        .EO_0_1            ( EO_0_1             ) ,
                        .EO_0_2            ( EO_0_2             ) ,
                        .EO_0_3            ( EO_0_3             ) ,
                        .EO_45_0           ( EO_45_0            ) ,
                        .EO_45_1           ( EO_45_1            ) ,
                        .EO_45_2           ( EO_45_2            ) ,
                        .EO_45_3           ( EO_45_3            ) ,
                        .EO_90_0           ( EO_90_0            ) ,
                        .EO_90_1           ( EO_90_1            ) ,
                        .EO_90_2           ( EO_90_2            ) ,
                        .EO_90_3           ( EO_90_3            ) ,
                        .EO_135_0          ( EO_135_0           ) ,
                        .EO_135_1          ( EO_135_1           ) ,
                        .EO_135_2          ( EO_135_2           ) ,
                        .EO_135_3          ( EO_135_3           ) ,
                        .BO_0              ( BO_0               ) ,
                        .BO_1              ( BO_1               ) ,
                        .BO_2              ( BO_2               ) ,
                        .BO_3              ( BO_3               ) ,
                        .BO_4              ( BO_4               ) ,
                        .BO_5              ( BO_5               ) ,
                        .BO_6              ( BO_6               ) ,
                        .BO_7              ( BO_7               ) ,
                        .y_sao_type_i      ( y_sao_type_r       ) ,
                        .y_sao_sub_type_i  ( y_sao_sub_type_r   ) ,
                        .y_sao_offset_i    ( y_sao_offset_r     ) ,
                        .u_sao_type_i      ( u_sao_type_r       ) ,
                        .u_sao_sub_type_i  ( u_sao_sub_type_r   ) ,
                        .u_sao_offset_i    ( u_sao_offset_r     ) ,
                        .v_sao_type_i      ( v_sao_type_r       ) ,
                        .v_sao_sub_type_i  ( v_sao_sub_type_r   ) ,
                        .v_sao_offset_i    ( v_sao_offset_r     ) ,
                        .rec_sao_o         ( sao_block_o        )
);

reg [61:0] sao_data_o;

always @ ( posedge clk or negedge rst_n )  begin 
    if ( !rst_n ) 
        sao_data_o <= 'd0;
    else //if (sys_done_o)
        sao_data_o <= {1'b0, 1'b0, y_sao_type_r, y_sao_sub_type_r, y_sao_offset_r, u_sao_type_r, u_sao_sub_type_r, u_sao_offset_r, v_sao_type_r, v_sao_sub_type_r, v_sao_offset_r};
    // else ;
end 

endmodule 