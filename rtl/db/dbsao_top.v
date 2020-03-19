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
// Filename       : dbsao_top.v
// Author         : TANG
// Created        : 
// Description    : TOP module of Deblocking Filter and Sample Adaptive Offset
//-------------------------------------------------------------------
`include "enc_defines.v"

// `define SIZ8x4 1 // 8x4
// `define SIZ32x1 2

module dbsao_top(
                clk                 ,
                rst_n               ,
                sys_ctu_x_i         ,
                sys_ctu_y_i         ,
                sys_db_ena_i        ,
                sys_sao_ena_i       ,

                // sys_total_x_i       ,
                // sys_total_y_i       ,
                sys_start_i         ,
                sys_done_o          , // system interface
                rc_qp_i             , // qp 
                IinP_flag_i         ,
                
                mb_type_i           , // ctu information 
                mb_partition_i      ,
                mb_p_pu_mode_i      ,
                mb_cbf_i            ,
                mb_cbf_u_i          ,
                mb_cbf_v_i          ,
                
                mb_mv_ren_o         , // low active
                mb_mv_raddr_o       ,
                mb_mv_rdata_i       ,
                
                rec_rd_4x4_x_o      ,
                rec_rd_4x4_y_o      ,
                rec_rd_4x4_idx_o    ,
                rec_rd_ren_o        ,
                rec_rd_sel_o        ,
                rec_rd_siz_o        ,
                rec_rd_pxl_i        ,
                rec_wr_4x4_x_o      ,
                rec_wr_4x4_y_o      ,
                rec_wr_4x4_idx_o    ,
                rec_wr_wen_o        ,
                rec_wr_sel_o        ,
                rec_wr_siz_o        ,
                rec_wr_pxl_o        ,
    
                ori_4x4_x_o         ,// original pixels interface 
                ori_4x4_y_o         ,
                ori_4x4_idx_o       ,
                ori_ren_o           ,
                ori_sel_o           ,
                ori_siz_o           ,
                ori_pxl_i           ,
                
                fetch_wen_o         , // high active
                fetch_w4x4_x_o      ,
                fetch_w4x4_y_o      ,
                fetch_wprevious_o   ,
                fetch_wdone_o       ,
                fetch_wsel_o        ,
                fetch_wdata_o       ,
                
                top_ren_o           , // high active
                top_r4x4_o          ,
                top_ridx_o          ,
                top_rdata_i         ,

                sao_data_o          
                    
);

// *********************************************************************
//                                             
//    Parameter DECLARATION                     
//                                             
// *********************************************************************
parameter DATA_WIDTH = 256;
parameter IDLE = 3'b000, LOAD = 3'b001, DBY = 3'b011, DBU = 3'b010, DBV = 3'b110, SAO = 3'b100, OUT = 3'b101;

// *********************************************************************
//                                             
//    INPUT / OUTPUT DECLARATION               
//                                             
// *********************************************************************
input                           clk             ;//clock
input                           rst_n           ;//reset signal   
input                           sys_db_ena_i    ;
input                           sys_sao_ena_i   ;
// CTRL IF                      
// input [`PIC_X_WIDTH-1:0]        sys_total_x_i   ;// Total LCU number-1 in X ,PIC_X_WIDTH = 8
// input [`PIC_Y_WIDTH-1:0]        sys_total_y_i   ;// Total LCU number-1 in y ,PIC_Y_WIDTH = 8
input [`PIC_X_WIDTH-1:0]        sys_ctu_x_i     ;// Current LCU in X
input [`PIC_Y_WIDTH-1:0]        sys_ctu_y_i     ;// Current LCU in y
input [5:0]                     rc_qp_i         ;// QP 
input                           sys_start_i     ;// 
output                          sys_done_o      ;// 
input [2:0]                     IinP_flag_i     ;
// Intra/Inter IF
input                           mb_type_i       ;// 1: I MB, 0: P/B MB 
input [20:0]                    mb_partition_i  ;// CU partition mode,0:not split,1:split,[0] for 64x64
input [41:0]                    mb_p_pu_mode_i  ;// Inter PU partition mode for every CU size  
input [255:0]                   mb_cbf_i        ;// cbf for every 4x4 cu in zig-zag scan order 
input [255:0]                   mb_cbf_u_i      ;// cbf for every 4x4 cu in zig-zag scan order 
input [255:0]                   mb_cbf_v_i      ;// cbf for every 4x4 cu in zig-zag scan order 

// MV RAM IF
output                          mb_mv_ren_o     ; // Inter MVD MEM IF
output [5:0]                    mb_mv_raddr_o   ; // CU_DEPTH  = 3,each 8x8 cu,include mv top,0-63:lcu
input  [`FMV_WIDTH*2-1:0]       mb_mv_rdata_i   ; // FMV_WIDTH = 10
// TQ IF  rec data of current LCU                       
output [3:0]                    rec_rd_4x4_x_o     ;  
output [3:0]                    rec_rd_4x4_y_o     ;  
output [4:0]                    rec_rd_4x4_idx_o   ;   
output                          rec_rd_ren_o       ;  
output [1:0]                    rec_rd_sel_o       ;  
output [1:0]                    rec_rd_siz_o       ;  
input  [DATA_WIDTH-1:0]         rec_rd_pxl_i       ;  

output [3:0]                    rec_wr_4x4_x_o     ;  
output [3:0]                    rec_wr_4x4_y_o     ;  
output [4:0]                    rec_wr_4x4_idx_o   ;  
output                          rec_wr_wen_o       ;   
output [1:0]                    rec_wr_sel_o       ;  
output [1:0]                    rec_wr_siz_o       ;  
output [DATA_WIDTH-1:0]         rec_wr_pxl_o       ; 

// original pixels 
output [3:0]                    ori_4x4_x_o     ; 
output [3:0]                    ori_4x4_y_o     ; 
output [4:0]                    ori_4x4_idx_o   ; 
output                          ori_ren_o       ; 
output [1:0]                    ori_sel_o       ; 
output [1:0]                    ori_siz_o       ; 
input  [DATA_WIDTH-1:0]         ori_pxl_i        ;

// fetch IF
output                          fetch_wen_o      ;
output [4:0]                    fetch_w4x4_x_o   ;
output [4:0]                    fetch_w4x4_y_o   ;
output                          fetch_wprevious_o;
output                          fetch_wdone_o    ;
output [1:0]                    fetch_wsel_o     ;
output [127:0]                  fetch_wdata_o    ;

// top pixels IF 
output                          top_ren_o        ;
output [4:0]                    top_r4x4_o       ;
output [1:0]                    top_ridx_o       ;
input  [4*`PIXEL_WIDTH-1:0]     top_rdata_i      ;

// sao output IF 
output [61:0]                   sao_data_o       ;


// *********************************************************************
//                                             
//    Wire DECLARATION                         
//                                             
// *********************************************************************
wire                       tu_edge_w            ;
wire                       pu_edge_w            ;
wire [ 5:0]                qp_p_w               ;
wire [ 5:0]                qp_q_w               ;
wire                       cbf_p_w              ;
wire                       cbf_q_w              ;
wire [`FMV_WIDTH*2-1:0]    mv_p_w               ;
wire [`FMV_WIDTH*2-1:0]    mv_q_w               ;

wire [ 8:0]                cnt_w                ;
wire [ 2:0]                state_w              ;

wire [127:0]               p_i_w                ;
wire [127:0]               q_i_w                ;
wire [127:0]               p_o_w                ;
wire [127:0]               q_o_w                ;

wire [16*8-1:0]            sao_block_w          ;

wire [32*8-1:0]            pre_bo_rec_w         ;

wire [6*`PIXEL_WIDTH-1:0]  rec_0_w              ;
wire [6*`PIXEL_WIDTH-1:0]  rec_1_w              ;
wire [6*`PIXEL_WIDTH-1:0]  rec_2_w              ;
wire [6*`PIXEL_WIDTH-1:0]  rec_3_w              ;
wire [6*`PIXEL_WIDTH-1:0]  rec_4_w              ;
wire [6*`PIXEL_WIDTH-1:0]  rec_5_w              ;
wire [4*`PIXEL_WIDTH-1:0]  ori_0_w              ;
wire [4*`PIXEL_WIDTH-1:0]  ori_1_w              ;
wire [4*`PIXEL_WIDTH-1:0]  ori_2_w              ;
wire [4*`PIXEL_WIDTH-1:0]  ori_3_w              ;
wire [3:0]                 sao_4x4_y_w          ;
wire [3:0]                 sao_4x4_x_w          ;
wire [1:0]                 sao_sel_w            ;

wire                       is_ver_w             ;

wire [21-1:0]              intra_pt_w           ;

wire [3:0]                 rec_4x4_x_o          ;
wire [3:0]                 rec_4x4_y_o          ;
wire [4:0]                 rec_4x4_idx_o        ;
wire                       rec_wen_o            ;
wire                       rec_ren_o            ;
wire [1:0]                 rec_sel_o            ;
wire [1:0]                 rec_siz_o            ;
wire [DATA_WIDTH-1:0]      rec_pxl_i            ;
wire [DATA_WIDTH-1:0]      rec_pxl_o            ;

wire                       IinP_flag_o          ;
  
// *********************************************************************
//                                             
//    Logic DECLARATION                         
//                                             
// *********************************************************************

  assign intra_pt_w = (mb_type_i==`INTRA || IinP_flag_i[0]) ? mb_partition_i[20:0] : 
                                                            { mb_p_pu_mode_i[41]&&mb_p_pu_mode_i[40]
                                                             ,mb_p_pu_mode_i[39]&&mb_p_pu_mode_i[38]
                                                             ,mb_p_pu_mode_i[37]&&mb_p_pu_mode_i[36]
                                                             ,mb_p_pu_mode_i[35]&&mb_p_pu_mode_i[34]
                                                             ,mb_p_pu_mode_i[33]&&mb_p_pu_mode_i[32]
                                                             ,mb_p_pu_mode_i[31]&&mb_p_pu_mode_i[30]
                                                             ,mb_p_pu_mode_i[29]&&mb_p_pu_mode_i[28]
                                                             ,mb_p_pu_mode_i[27]&&mb_p_pu_mode_i[26]
                                                             ,mb_p_pu_mode_i[25]&&mb_p_pu_mode_i[24]
                                                             ,mb_p_pu_mode_i[23]&&mb_p_pu_mode_i[22]
                                                             ,mb_p_pu_mode_i[21]&&mb_p_pu_mode_i[20]
                                                             ,mb_p_pu_mode_i[19]&&mb_p_pu_mode_i[18]
                                                             ,mb_p_pu_mode_i[17]&&mb_p_pu_mode_i[16]
                                                             ,mb_p_pu_mode_i[15]&&mb_p_pu_mode_i[14]
                                                             ,mb_p_pu_mode_i[13]&&mb_p_pu_mode_i[12]
                                                             ,mb_p_pu_mode_i[11]&&mb_p_pu_mode_i[10]
                                                             ,mb_p_pu_mode_i[09]&&mb_p_pu_mode_i[08]
                                                             ,mb_p_pu_mode_i[07]&&mb_p_pu_mode_i[06]
                                                             ,mb_p_pu_mode_i[05]&&mb_p_pu_mode_i[04]
                                                             ,mb_p_pu_mode_i[03]&&mb_p_pu_mode_i[02]
                                                             ,mb_p_pu_mode_i[01]&&mb_p_pu_mode_i[00]
                                                            };

assign rec_rd_4x4_x_o   = rec_ren_o ? rec_4x4_x_o   : 0    ;
assign rec_rd_4x4_y_o   = rec_ren_o ? rec_4x4_y_o   : 0    ;
assign rec_rd_4x4_idx_o = rec_ren_o ? rec_4x4_idx_o : 0    ;
assign rec_rd_ren_o     = rec_ren_o ? rec_ren_o     : 0    ;
assign rec_rd_sel_o     = rec_sel_o                        ;
assign rec_rd_siz_o     = rec_siz_o                        ;
assign rec_pxl_i        = rec_rd_pxl_i                     ;
assign rec_wr_4x4_x_o   = rec_wen_o ? rec_4x4_x_o   : 0    ;
assign rec_wr_4x4_y_o   = rec_wen_o ? rec_4x4_y_o   : 0    ;
assign rec_wr_4x4_idx_o = rec_wen_o ? rec_4x4_idx_o : 0    ;
assign rec_wr_wen_o     = rec_wen_o ? rec_wen_o     : 0    ;
assign rec_wr_sel_o     = rec_sel_o                        ;
assign rec_wr_siz_o     = rec_siz_o                        ;
assign rec_wr_pxl_o     = rec_pxl_o                        ;


dbsao_controller u_controller(
                       .clk                     ( clk               ),
                       .rst_n                   ( rst_n             ),
                       .start_i                 ( sys_start_i       ),
                       .done_o                  ( sys_done_o        ),     
                       .cnt_o                   ( cnt_w             ),
                       .state_o                 ( state_w           )
                    );

dbsao_datapath dbsao_datapath(
                        .clk                    (clk                ) ,
                        .rst_n                  (rst_n              ) ,
                        .state_i                (state_w            ) ,
                        .cnt_i                  (cnt_w              ) ,
                        .sys_ctu_y_i            (sys_ctu_y_i        ) ,
                        .sys_ctu_x_i            (sys_ctu_x_i        ) ,
                        .IinP_flag_i            (IinP_flag_i        ) ,
                        .IinP_flag_o            (IinP_flag_o        ) ,
                        // read from external memory 
                        .rec_4x4_x_o            (rec_4x4_x_o        ) , // top-left pos x in sw by 4x4 block
                        .rec_4x4_y_o            (rec_4x4_y_o        ) , // top-left pos y in sw by 4x4 block
                        .rec_4x4_idx_o          (rec_4x4_idx_o      ) , // line number in 4x4 block
                        .rec_wen_o              (rec_wen_o          ) , // write enable
                        .rec_ren_o              (rec_ren_o          ) , // read enable
                        .rec_sel_o              (rec_sel_o          ) , // Y/U/V selection
                        .rec_siz_o              (rec_siz_o          ) , // block size selection 32x1, 16x2, 8x4
                        .rec_pxl_i              (rec_pxl_i          ) , // input block data
                        .rec_pxl_o              (rec_pxl_o          ) , // output to ram after dbf
                
                        .ori_4x4_x_o            (ori_4x4_x_o        ) , // original pixels interface 
                        .ori_4x4_y_o            (ori_4x4_y_o        ) ,
                        .ori_4x4_idx_o          (ori_4x4_idx_o      ) ,
                        .ori_ren_o              (ori_ren_o          ) ,
                        .ori_sel_o              (ori_sel_o          ) ,
                        .ori_siz_o              (ori_siz_o          ) ,
                        .ori_pxl_i              (ori_pxl_i          ) ,
                
                        .top_ren_o              (top_ren_o          ) , // top pixels IF
                        .top_r4x4_o             (top_r4x4_o         ) ,
                        .top_ridx_o             (top_ridx_o         ) ,
                        .top_rdata_i            (top_rdata_i        ) , 
                        // output to external memory  
                        .fetch_wen_o            (fetch_wen_o        ) , // fetch IF
                        .fetch_w4x4_x_o         (fetch_w4x4_x_o     ) ,
                        .fetch_w4x4_y_o         (fetch_w4x4_y_o     ) ,
                        .fetch_wprevious_o      (fetch_wprevious_o  ) ,
                        .fetch_wdone_o          (fetch_wdone_o      ) ,
                        .fetch_wsel_o           (fetch_wsel_o       ) ,
                        .fetch_wdata_o          (fetch_wdata_o      ) ,  
                        // output to dbf/sao
                        .dbf_p_o                (p_i_w              ) , // for dbf
                        .dbf_q_o                (q_i_w              ) , // 
                        .is_ver_o               (is_ver_w           ) ,

                        .sao_rec_0_o            (rec_0_w            ) , // for sao 32x1
                        .sao_rec_1_o            (rec_1_w            ) ,
                        .sao_rec_2_o            (rec_2_w            ) ,
                        .sao_rec_3_o            (rec_3_w            ) ,
                        .sao_rec_4_o            (rec_4_w            ) ,
                        .sao_rec_5_o            (rec_5_w            ) ,
                        .sao_ori_0_o            (ori_0_w            ) ,
                        .sao_ori_1_o            (ori_1_w            ) ,
                        .sao_ori_2_o            (ori_2_w            ) ,
                        .sao_ori_3_o            (ori_3_w            ) ,
                        .sao_4x4_x_o            (sao_4x4_x_w        ) ,
                        .sao_4x4_y_o            (sao_4x4_y_w        ) ,
                        .sao_sel_o              (sao_sel_w          ) ,
                        // input from dbf/sao 
                        .dbf_p_i                (p_o_w              ) , // after deblocking
                        .dbf_q_i                (q_o_w              ) ,  
                        
                        .pre_bo_rec_o           (pre_bo_rec_w       ) ,
            
                        .sao_block_i            (sao_block_w        )  // after offset 
);

db_bs u_db_bs(  
                        .clk               (clk            ),
                        .rst_n             (rst_n          ),  
                        .cnt_i             (cnt_w          ),
                        .state_i           (state_w        ),             
                        // .sys_total_x_i     (sys_total_x_i  ),  
                        // .sys_total_y_i     (sys_total_y_i  ),  
                        .sys_ctu_x_i       (sys_ctu_x_i    ),  
                        .sys_ctu_y_i       (sys_ctu_y_i    ),  
                        
                        .mb_partition_i    (intra_pt_w     ),
                        .mb_p_pu_mode_i    (mb_p_pu_mode_i ),
                        .mb_cbf_i          (mb_cbf_i       ),
                        .mb_cbf_u_i        (mb_cbf_u_i     ),
                        .mb_cbf_v_i        (mb_cbf_v_i     ),
                        .qp_i              (rc_qp_i        ),
                        
                        .tu_edge_o         (tu_edge_w      ),
                        .pu_edge_o         (pu_edge_w      ),
                        .qp_p_o            (qp_p_w         ),
                        .qp_q_o            (qp_q_w         ),    
                        .cbf_p_o           (cbf_p_w        ),
                        .cbf_q_o           (cbf_q_w        )
            );


db_mv u_db_mv(
                        .clk               (clk            ) ,
                        .rst_n             (rst_n          ) ,
                        .state_i           (state_w        ) ,
                        .cnt_i             (cnt_w          ) ,
                        .sys_ctu_x_i       (sys_ctu_x_i    ) ,
                        .sys_ctu_y_i       (sys_ctu_y_i    ) ,  
                    
                        .mb_mv_ren_o       (mb_mv_ren_o    ) , 
                        .mb_mv_raddr_o     (mb_mv_raddr_o  ) ,
                        .mb_mv_rdata_i     (mb_mv_rdata_i  ) ,
        
                        .mv_p_o            (mv_p_w         ) ,
                        .mv_q_o            (mv_q_w         ) 
);

db_filter u_db_filter(
                        .clk               (clk            ) ,
                        .rst_n             (rst_n          ) ,
                        .state_i           (state_w        ) ,
                        .sys_db_ena_i      ( sys_db_ena_i  ) ,
                        .IinP_flag_i       (IinP_flag_o    ) ,

                        .p_i               (p_i_w          ) , // rec block
                        .q_i               (q_i_w          ) , 

                        .mv_p_i            (mv_p_w         ) ,
                        .mv_q_i            (mv_q_w         ) ,
                        .mb_type_i         (mb_type_i      ) ,
                        .tu_edge_i         (tu_edge_w      ) ,
                        .pu_edge_i         (pu_edge_w      ) ,
                        .qp_p_i            (qp_p_w         ) ,
                        .qp_q_i            (qp_q_w         ) ,
                        .cbf_p_i           (cbf_p_w        ) ,
                        .cbf_q_i           (cbf_q_w        ) ,
                        .is_ver_i          (is_ver_w       ) ,

                        .p_o               (p_o_w          ) ,
                        .q_o               (q_o_w          )      
);

wire [14:0] bo_predecision;
sao_bo_predecision u_sao_bo_pre(
                        .clk               (clk            ) ,
                        .rst_n             (rst_n          ) ,
                        .cnt_i             (cnt_w          ) ,
                        .state_i           (state_w        ) ,
                        .block_i           (pre_bo_rec_w   ) ,
                        .bo_predecision_o  (bo_predecision )  
);


sao_top    u_sao_top(
                        .clk               (clk             ) ,//
                        .rst_n             (rst_n           ) ,  
                        .sys_sao_ena_i     ( sys_sao_ena_i  ) ,
                        .state_i           (state_w         ) ,
                        .bo_predecision    (bo_predecision  ) ,
                        .sao_4x4_x_i       (sao_4x4_x_w     ) ,
                        .sao_4x4_y_i       (sao_4x4_y_w     ) ,
                        .sao_sel_i         (sao_sel_w       ) ,
                        .rec_line_i_0      (rec_0_w         ) ,
                        .rec_line_i_1      (rec_1_w         ) ,
                        .rec_line_i_2      (rec_2_w         ) ,
                        .rec_line_i_3      (rec_3_w         ) ,
                        .rec_line_i_4      (rec_4_w         ) ,
                        .rec_line_i_5      (rec_5_w         ) ,
                        .ori_line_i_0      (ori_0_w         ) ,
                        .ori_line_i_1      (ori_1_w         ) ,
                        .ori_line_i_2      (ori_2_w         ) ,
                        .ori_line_i_3      (ori_3_w         ) ,
                        .sao_block_o       (sao_block_w     ) ,
                        .sao_data_o        (sao_data_o      )
                    );

						  



endmodule

