//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2014, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//
//-------------------------------------------------------------------
//
//  Filename      : fme_top.v
//  Author        : Yufeng Bai
//  Email         : byfchina@gmail.com  
//------------------------------------------------------------------
//  Modified by TANG
//  Description : FME SKIP 00 supported
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fme_top (
        clk                     ,
        rstn                    ,
        // skip cost thresh
        skip_cost_thresh_08     ,
        skip_cost_thresh_16     ,
        skip_cost_thresh_32     ,
        skip_cost_thresh_64     ,
        //cfg
        sysif_cmb_x_i           ,
        sysif_cmb_y_i           ,
        sys_x_all_i             ,
        sys_y_all_i             ,
        sys_ctu_x_all_i         ,
        sys_ctu_y_all_i         ,
        IinP_flag_i             ,
        sysif_qp_i              ,
        sysif_start_i           ,
        sysif_done_o            ,
        fimeif_partition_i      ,
        fimeif_mv_rden_o        ,
        fimeif_mv_rdaddr_o      ,
        fimeif_mv_data_i        ,
        cur_rden_o              ,
        cur_4x4_idx_o           ,
        cur_4x4_x_o             ,
        cur_4x4_y_o             ,
        cur_pel_i               ,
        ref_rden_o              ,
        ref_idx_x_o             ,
        ref_idx_y_o             ,
        ref_pel_i               ,
        mcif_mv_rden_o          ,
        mcif_mv_rdaddr_o        ,
        mcif_mv_data_i          ,
        mcif_mv_wren_o          ,
        mcif_mv_wraddr_o        ,
        mcif_mv_data_o          ,
        mcif_pre_pixel_o        ,
        mcif_pre_wren_o         ,
        mcif_wr_4x4_x_o         ,
        mcif_wr_4x4_y_o         ,
        mcif_wr_idx_o           ,
        mcif_siz_o              ,
        // fme cost
        fme_cost_o              ,
        // skip if
        skip_idx_o              ,
        skip_flag_o 
);

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

input    [1-1:0]                 clk                     ; // clk signal 
input    [1-1:0]                 rstn                    ; // asynchronous reset 
input    [`PIC_X_WIDTH-1:0]      sysif_cmb_x_i           ; // current LCU x index 
input    [`PIC_Y_WIDTH-1:0]      sysif_cmb_y_i           ; // current LCU y index 
input    [`PIC_WIDTH -1 :0]      sys_x_all_i             ;
input    [`PIC_HEIGHT-1 :0]      sys_y_all_i             ;
input    [`PIC_X_WIDTH-1:0]      sys_ctu_x_all_i         ;
input    [`PIC_Y_WIDTH-1:0]      sys_ctu_y_all_i         ;
input    [4-1:0]                 IinP_flag_i             ;

input    [6-1:0]                 sysif_qp_i              ; // qp value 
input    [1-1:0]                 sysif_start_i           ; // fme start signal 
output   [1-1:0]                 sysif_done_o            ; // fme done signal 
input    [42-1:0]                fimeif_partition_i      ; // ime partition info  
output   [1-1:0]                 fimeif_mv_rden_o        ; // imv read enable 
output   [6-1:0]                 fimeif_mv_rdaddr_o      ; // imv sram read address 
input    [2*`FMV_WIDTH-1:0]      fimeif_mv_data_i        ; // imv from fime 
output   [1-1:0]                 mcif_mv_rden_o          ; // half fmv write back enable 
output   [6-1:0]                 mcif_mv_rdaddr_o        ; // half fmv write back  address 
input    [2*`FMV_WIDTH-1:0]      mcif_mv_data_i          ; // half fmv  
output   [1-1:0]                 cur_rden_o              ; // current lcu read enable 
//output         [1-1:0]                 cur_sel_o               ; // use block read mode 
//output         [6-1:0]                 cur_idx_o               ; // current block read index ( raster sacn) 
output   [5-1:0]                 cur_4x4_idx_o           ;
output   [4-1:0]                 cur_4x4_x_o             ;
output   [4-1:0]                 cur_4x4_y_o             ;
input    [32*`PIXEL_WIDTH-1:0]   cur_pel_i               ; // current block pixel  
output   [1-1:0]                 ref_rden_o              ; // referenced pixel read enable  
//output         [7-1:0]                 ref_idx_x_o             ; // referenced pixel x index 
//output         [7-1:0]                 ref_idx_y_o             ; // referenced pixel y index 
output   [8-1:0]                 ref_idx_x_o         ;
output   [8-1:0]                 ref_idx_y_o         ;
input    [64*`PIXEL_WIDTH-1:0]   ref_pel_i               ; // referenced pixel 
output                           mcif_mv_wren_o          ; // fmv sram write enable
output   [6-1:0]                 mcif_mv_wraddr_o        ; // fmv sram write address
output   [2*`FMV_WIDTH-1:0]      mcif_mv_data_o          ; // fmv data
output   [32*`PIXEL_WIDTH-1 :0]  mcif_pre_pixel_o        ;
output   [1-1              :0]   mcif_pre_wren_o         ;
output   [4-1              :0]   mcif_wr_4x4_x_o;
output   [4-1              :0]   mcif_wr_4x4_y_o;
output   [5-1              :0]   mcif_wr_idx_o  ;
output   [2-1              :0]   mcif_siz_o     ;

output   [`FME_COST_WIDTH-1:0]   fme_cost_o ; //fmv best cost
// output info
output  [85*4-1:0]               skip_idx_o          ;
output  [85-1:0]                 skip_flag_o         ;

// skip cost thresh
input   [32-1:0]                 skip_cost_thresh_08 ;
input   [32-1:0]                 skip_cost_thresh_16 ;
input   [32-1:0]                 skip_cost_thresh_32 ;
input   [32-1:0]                 skip_cost_thresh_64 ;

// ********************************************
//
//     PARAMETER DECLARATION
//
// ********************************************

localparam SATD_WIDTH = `PIXEL_WIDTH + 10;

localparam DLY_NUM = 0 + 1 ; // >= 1

localparam IDLE      = 4'd0;

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

// ********************************************
//
//    Combinational Logic
//
// ********************************************

// CTRL <-> IP IF

wire                         ip_start_ctrl    ;
wire                         ip_half_ctrl     ;
wire   [`FMV_WIDTH-1     :0] ip_mv_x_ctrl     ;
wire   [`FMV_WIDTH-1     :0] ip_mv_y_ctrl     ;
wire   [2-1              :0] ip_frac_x_ctrl   ;
wire   [2-1              :0] ip_frac_y_ctrl   ;
wire   [6-1              :0] ip_idx_ctrl      ;

// REF <-> IP IF

reg                          refpel_valid     ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel0         ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel1         ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel2         ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel3         ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel4         ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel5         ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel6         ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel7         ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel8         ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel9         ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel10        ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel11        ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel12        ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel13        ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel14        ;
wire   [`PIXEL_WIDTH-1   :0] ref_pel15        ;

/*
wire   [64*`PIXEL_WIDTH-1:0] ref_pixels       ;
reg    [9-1              :0] ref_shift        ;
always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        ref_shift <= 'd0;
    end
    else begin
        ref_shift <=  {ip_idx_ctrl[4], ip_idx_ctrl[2], ip_idx_ctrl[0],6'b0};
    end
end
assign ref_pixels =   ref_pel_i << ref_shift;
*/

assign ref_pel0   =   ref_pel_i[64*`PIXEL_WIDTH-1:63*`PIXEL_WIDTH];
assign ref_pel1   =   ref_pel_i[63*`PIXEL_WIDTH-1:62*`PIXEL_WIDTH];
assign ref_pel2   =   ref_pel_i[62*`PIXEL_WIDTH-1:61*`PIXEL_WIDTH];
assign ref_pel3   =   ref_pel_i[61*`PIXEL_WIDTH-1:60*`PIXEL_WIDTH];
assign ref_pel4   =   ref_pel_i[60*`PIXEL_WIDTH-1:59*`PIXEL_WIDTH];
assign ref_pel5   =   ref_pel_i[59*`PIXEL_WIDTH-1:58*`PIXEL_WIDTH];
assign ref_pel6   =   ref_pel_i[58*`PIXEL_WIDTH-1:57*`PIXEL_WIDTH];
assign ref_pel7   =   ref_pel_i[57*`PIXEL_WIDTH-1:56*`PIXEL_WIDTH];
assign ref_pel8   =   ref_pel_i[56*`PIXEL_WIDTH-1:55*`PIXEL_WIDTH];
assign ref_pel9   =   ref_pel_i[55*`PIXEL_WIDTH-1:54*`PIXEL_WIDTH];
assign ref_pel10  =   ref_pel_i[54*`PIXEL_WIDTH-1:53*`PIXEL_WIDTH];
assign ref_pel11  =   ref_pel_i[53*`PIXEL_WIDTH-1:52*`PIXEL_WIDTH];
assign ref_pel12  =   ref_pel_i[52*`PIXEL_WIDTH-1:51*`PIXEL_WIDTH];
assign ref_pel13  =   ref_pel_i[51*`PIXEL_WIDTH-1:50*`PIXEL_WIDTH];
assign ref_pel14  =   ref_pel_i[50*`PIXEL_WIDTH-1:49*`PIXEL_WIDTH];
assign ref_pel15  =   ref_pel_i[49*`PIXEL_WIDTH-1:48*`PIXEL_WIDTH];

// IP <-> SATD IF

wire   [`FMV_WIDTH-1     :0] mv_x_ip          ;
wire   [`FMV_WIDTH-1     :0] mv_y_ip          ;
wire   [6-1              :0] blk_idx_ip       ;
wire                         half_ip_flag_ip  ;

wire                         ip_ready         ;
wire                         end_ip           ; 
wire                         mc_end_ip        ; 
wire                         satd_start       ; 

wire                         candi0_valid     ;
wire                         candi1_valid     ; 
wire                         candi2_valid     ; 
wire                         candi3_valid     ; 
wire                         candi4_valid     ; 
wire                         candi5_valid     ; 
wire                         candi6_valid     ; 
wire                         candi7_valid     ; 
wire                         candi8_valid     ; 
               
wire   [8*`PIXEL_WIDTH-1 :0] candi0_pixles    ; 
wire   [8*`PIXEL_WIDTH-1 :0] candi1_pixles    ; 
wire   [8*`PIXEL_WIDTH-1 :0] candi2_pixles    ; 
wire   [8*`PIXEL_WIDTH-1 :0] candi3_pixles    ; 
wire   [8*`PIXEL_WIDTH-1 :0] candi4_pixles    ; 
wire   [8*`PIXEL_WIDTH-1 :0] candi5_pixles    ; 
wire   [8*`PIXEL_WIDTH-1 :0] candi6_pixles    ; 
wire   [8*`PIXEL_WIDTH-1 :0] candi7_pixles    ; 
wire   [8*`PIXEL_WIDTH-1 :0] candi8_pixles    ; 

// SATD <-> COST
wire                         cost_start       ;    
wire   [`FMV_WIDTH-1     :0] mv_x_satd        ;
wire   [`FMV_WIDTH-1     :0] mv_y_satd        ;
wire                         half_ip_flag_satd;
wire   [6-1              :0] blk_idx_satd     ;

wire   [SATD_WIDTH-1     :0] satd0            ;         
wire   [SATD_WIDTH-1     :0] satd1            ;         
wire   [SATD_WIDTH-1     :0] satd2            ;         
wire   [SATD_WIDTH-1     :0] satd3            ;         
wire   [SATD_WIDTH-1     :0] satd4            ;         
wire   [SATD_WIDTH-1     :0] satd5            ;         
wire   [SATD_WIDTH-1     :0] satd6            ;         
wire   [SATD_WIDTH-1     :0] satd7            ;         
wire   [SATD_WIDTH-1     :0] satd8            ;         
wire                         satd_valid       ;

// COST <-> CTRL IF
wire   [3                :0] current_state    ;
wire                         cost_done        ; 
wire   [4-1              :0] best_sp          ;      
wire   [6-1              :0] best_addr        ;      
wire                         best_valid       ;  
wire   [SATD_WIDTH-1:0]      fmv_cost         ;   
wire   [`FME_COST_WIDTH-1:0] fmv_cost_w       ; 

wire   [2*`FMV_WIDTH-1   :0] fmv_best         ;
wire                         fmv_wren         ;
wire                         fmv_sel          ;
wire   [6-1              :0] fmv_addr         ;

wire signed [`FMV_WIDTH-1:0] imv_x            ;
wire signed [`FMV_WIDTH-1:0] imv_y            ;
wire signed [`FMV_WIDTH-1:0] fmv_x            ;
wire signed [`FMV_WIDTH-1:0] fmv_y            ;

wire   [1-1              :0] predicted_en     ;
wire   [4-1              :0] pred_wren        ;
wire   [32*`PIXEL_WIDTH-1:0] mcif_pre_pixel_w ;
wire   [7-1              :0] mcif_pre_addr_w  ;

reg    [32*`PIXEL_WIDTH-1 :0]  mcif_pre_pixel_o        ;
reg    [1-1              :0]   mcif_pre_wren_o         ;
reg    [4-1              :0]   mcif_wr_4x4_x_o;
reg    [4-1              :0]   mcif_wr_4x4_y_o;
reg    [5-1              :0]   mcif_wr_idx_o  ;
reg    [2-1              :0]   mcif_siz_o     ;

// delay signals

reg    [1*DLY_NUM-1         :0]    ip_start_ctrl_r    ;
reg    [1*DLY_NUM-1         :0]    ip_half_ctrl_r     ;
reg    [`FMV_WIDTH*DLY_NUM-1:0]    ip_mv_x_ctrl_r     ;
reg    [`FMV_WIDTH*DLY_NUM-1:0]    ip_mv_y_ctrl_r     ;
reg    [2*DLY_NUM-1         :0]    ip_frac_x_ctrl_r   ;
reg    [2*DLY_NUM-1         :0]    ip_frac_y_ctrl_r   ;
reg    [6*DLY_NUM-1         :0]    ip_idx_ctrl_r      ;
reg    [1*DLY_NUM-1         :0]    refpel_valid_r     ;

wire                               ip_start_ctrl_w    ;
wire                               ip_half_ctrl_w     ;
wire   [`FMV_WIDTH-1        :0]    ip_mv_x_ctrl_w     ;
wire   [`FMV_WIDTH-1        :0]    ip_mv_y_ctrl_w     ;
wire   [2-1                 :0]    ip_frac_x_ctrl_w   ;
wire   [2-1                 :0]    ip_frac_y_ctrl_w   ;
wire   [6-1                 :0]    ip_idx_ctrl_w      ;
wire                               refpel_valid_w     ;

// fme cost
wire   [6-1:0]                     fme_cost_adr_w     ;
wire   [1-1:0]                     fme_cst_rd_ena_w   ;
wire   [6-1:0]                     fme_cst_rd_adr_w   ;
wire   [`FME_COST_WIDTH-1:0]       fme_cst_rd_dat_w   ;

// lambda
wire   [7-1:0]                     lambda             ;

// skip if  
wire                               skip_start_w       ;
wire                               skip_done_w        ;
wire   [2-1:0]                     cur_cu_mod_w       ;   
wire   [2-1:0]                     cur_pu_mod_w       ;   
wire   [3-1:0]                     cur_pu_pos_x_w     ;
wire   [3-1:0]                     cur_pu_pos_y_w     ;
wire   [4-1:0]                     cur_pu_wid_w       ;
wire   [4-1:0]                     cur_pu_hgt_w       ;
wire                               cur_pu_blk_w       ;
wire   [6-1:0]                     cur_pu_8x8_adr_w   ;
wire   [7-1:0]                     cur_pu_blk_num_w   ;
wire                               cur_pu_start_w     ;
wire                               cur_blk_start_w    ;
wire                               cur_blk_done_w     ;

// mv buffer
wire                               lft_mv_rd_ena_w    ;
wire   [3-1:0]                     lft_mv_rd_adr_w    ;
wire   [2*`FMV_WIDTH-1:0]          lft_mv_rd_dat_w    ;
wire                               top_mv_rd_ena_w    ;
wire   [`PIC_X_WIDTH+3-1:0]        top_mv_rd_adr_w    ;
wire   [2*`FMV_WIDTH-1:0]          top_mv_rd_dat_w    ;

wire                               fmv_candi_rdy_w    ;
wire                               mv_a0_val_w        ;
wire                               mv_a1_val_w        ;
wire                               mv_b0_val_w        ;
wire                               mv_b1_val_w        ;
wire                               mv_b2_val_w        ;
wire   [2*`FMV_WIDTH-1:0]          mv_a0_dat_w        ;
wire   [2*`FMV_WIDTH-1:0]          mv_a1_dat_w        ;
wire   [2*`FMV_WIDTH-1:0]          mv_b0_dat_w        ;
wire   [2*`FMV_WIDTH-1:0]          mv_b1_dat_w        ;
wire   [2*`FMV_WIDTH-1:0]          mv_b2_dat_w        ;

// cur pixel
wire                               fme_cur_rden_w     ;
wire   [4-1:0]                     fme_cur_4x4_x_w    ;
wire   [4-1:0]                     fme_cur_4x4_y_w    ;
wire   [5-1:0]                     fme_cur_4x4_idx_w  ;
wire                               skip_cur_rd_ena_w  ;
wire   [5-1:0]                     skip_cur_4x4_idx_w ;
wire   [4-1:0]                     skip_cur_4x4_x_w   ;
wire   [4-1:0]                     skip_cur_4x4_y_w   ;
wire   [32*`PIXEL_WIDTH-1:0]       fme_cur_pel_w      ;
wire   [32*`PIXEL_WIDTH-1:0]       skip_cur_pel_w     ;
// fmv 
wire                               skip_fmv_wr_ena_w  ; 
wire   [6-1:0]                     skip_fmv_wr_adr_w  ; 
wire   [2*`FMV_WIDTH-1:0]          skip_fmv_wr_dat_w  ; 

wire                               cur_fmv_rd_ena_w   ;
wire   [6-1:0]                     cur_fmv_rd_adr_w   ;
   
wire                               mcif_mv_rden_w     ;
wire   [6-1:0]                     mcif_mv_rdaddr_w   ;

wire                               cost_wr_ena_w      ;

wire                               mc_skip_flg_w      ;
// ********************************************
//
//    Sequential Logic
//
// ********************************************

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        refpel_valid <= 1'b0;
    end
    else begin
        refpel_valid <= ref_rden_o;
    end
end

always @( posedge clk or negedge rstn ) begin 
    if ( !rstn ) begin 
        ip_start_ctrl_r   <= 0 ;
        ip_half_ctrl_r    <= 0 ;
        ip_mv_x_ctrl_r    <= 0 ;
        ip_mv_y_ctrl_r    <= 0 ;
        ip_frac_x_ctrl_r  <= 0 ;
        ip_frac_y_ctrl_r  <= 0 ;
        ip_idx_ctrl_r     <= 0 ;
        refpel_valid_r    <= 0 ;
    end else begin 
        ip_start_ctrl_r   <= { ip_start_ctrl_r , ip_start_ctrl  } ;
        ip_half_ctrl_r    <= { ip_half_ctrl_r  , ip_half_ctrl   } ;
        ip_mv_x_ctrl_r    <= { ip_mv_x_ctrl_r  , ip_mv_x_ctrl   } ;
        ip_mv_y_ctrl_r    <= { ip_mv_y_ctrl_r  , ip_mv_y_ctrl   } ;
        ip_frac_x_ctrl_r  <= { ip_frac_x_ctrl_r, ip_frac_x_ctrl } ;
        ip_frac_y_ctrl_r  <= { ip_frac_y_ctrl_r, ip_frac_y_ctrl } ;
        ip_idx_ctrl_r     <= { ip_idx_ctrl_r   , ip_idx_ctrl    } ;
        refpel_valid_r    <= { refpel_valid_r  , refpel_valid   } ;
    end 
end 

assign ip_start_ctrl_w  = ip_start_ctrl_r  [1*DLY_NUM-1         :1*(DLY_NUM-1)         ]  ;
assign ip_half_ctrl_w   = ip_half_ctrl_r   [1*DLY_NUM-1         :1*(DLY_NUM-1)         ]  ;
assign ip_mv_x_ctrl_w   = ip_mv_x_ctrl_r   [`FMV_WIDTH*DLY_NUM-1:`FMV_WIDTH*(DLY_NUM-1)]  ;
assign ip_mv_y_ctrl_w   = ip_mv_y_ctrl_r   [`FMV_WIDTH*DLY_NUM-1:`FMV_WIDTH*(DLY_NUM-1)]  ;
assign ip_frac_x_ctrl_w = ip_frac_x_ctrl_r [2*DLY_NUM-1         :2*(DLY_NUM-1)         ]  ;
assign ip_frac_y_ctrl_w = ip_frac_y_ctrl_r [2*DLY_NUM-1         :2*(DLY_NUM-1)         ]  ;
assign ip_idx_ctrl_w    = ip_idx_ctrl_r    [6*DLY_NUM-1         :6*(DLY_NUM-1)         ]  ;
assign refpel_valid_w   = refpel_valid_r   [1*DLY_NUM-1         :1*(DLY_NUM-1)         ]  ;

assign cur_rden_o    = current_state != SKIP ? fme_cur_rden_w    : skip_cur_rd_ena_w  ;
assign cur_4x4_x_o   = current_state != SKIP ? fme_cur_4x4_x_w   : skip_cur_4x4_x_w ;
assign cur_4x4_y_o   = current_state != SKIP ? fme_cur_4x4_y_w   : skip_cur_4x4_y_w ;
assign cur_4x4_idx_o = current_state != SKIP ? fme_cur_4x4_idx_w : skip_cur_4x4_idx_w ;
assign fme_cur_pel_w = current_state != SKIP ? cur_pel_i : 0     ;
assign skip_cur_pel_w= current_state == SKIP ? cur_pel_i : 0     ;

assign mcif_mv_rden_o  = mcif_mv_rden_w || cur_fmv_rd_ena_w ;
assign mcif_mv_rdaddr_o= !cur_fmv_rd_ena_w ? mcif_mv_rdaddr_w : cur_fmv_rd_adr_w ;

qp_lambda_table u_qp_lambda_table(
    .qp_i (sysif_qp_i),
    .lambda(lambda)
);

fme_interpolator_8x8 ip8x8(
        .clk                    (clk              ),
        .rstn                   (rstn             ),

        // CTRL -> IP IF
        .blk_start_i            (ip_start_ctrl_w  ),
        .half_ip_flag_i         (ip_half_ctrl_w   ),                                      
        .mv_x_i                 (ip_mv_x_ctrl_w   ),
        .mv_y_i                 (ip_mv_y_ctrl_w   ),
        .frac_x_i               (ip_frac_x_ctrl_w ),
        .frac_y_i               (ip_frac_y_ctrl_w ),
        .blk_idx_i              (ip_idx_ctrl_w    ),
        // .blk_start_i            (ip_start_ctrl  ),
        // .half_ip_flag_i         (ip_half_ctrl   ),  
        // .mv_x_i                 (ip_mv_x_ctrl   ),
        // .mv_y_i                 (ip_mv_y_ctrl   ),
        // .frac_x_i               (ip_frac_x_ctrl ),
        // .frac_y_i               (ip_frac_y_ctrl ),
        // .blk_idx_i              (ip_idx_ctrl    ),
        // REF -> IP IF
        .refpel_valid_i         (refpel_valid_w   ),
        .ref_pel0_i             (ref_pel0       ),
        .ref_pel1_i             (ref_pel1       ),
        .ref_pel2_i             (ref_pel2       ),
        .ref_pel3_i             (ref_pel3       ),
        .ref_pel4_i             (ref_pel4       ),
        .ref_pel5_i             (ref_pel5       ),
        .ref_pel6_i             (ref_pel6       ),
        .ref_pel7_i             (ref_pel7       ),
        .ref_pel8_i             (ref_pel8       ),
        .ref_pel9_i             (ref_pel9       ),
        .ref_pel10_i            (ref_pel10      ),
        .ref_pel11_i            (ref_pel11      ),
        .ref_pel12_i            (ref_pel12      ),
        .ref_pel13_i            (ref_pel13      ),
        .ref_pel14_i            (ref_pel14      ),
        .ref_pel15_i            (ref_pel15      ),
        
        // SATD <- IP IF
        .mv_x_o                 (mv_x_ip        ),
        .mv_y_o                 (mv_y_ip        ),
        .blk_idx_o              (blk_idx_ip     ),
        .half_ip_flag_o         (half_ip_flag_ip),

        .ip_ready_o             (ip_ready       ),
        .end_ip_o               (end_ip         ),
        .mc_end_ip_o            (mc_end_ip      ),
        .satd_start_o           (satd_start     ),             

        .candi0_valid_o         (candi0_valid   ),
        .candi1_valid_o         (candi1_valid   ),
        .candi2_valid_o         (candi2_valid   ),
        .candi3_valid_o         (candi3_valid   ),
        .candi4_valid_o         (candi4_valid   ),
        .candi5_valid_o         (candi5_valid   ),
        .candi6_valid_o         (candi6_valid   ),
        .candi7_valid_o         (candi7_valid   ),
        .candi8_valid_o         (candi8_valid   ),

        .candi0_pixles_o        (candi0_pixles  ),
        .candi1_pixles_o        (candi1_pixles  ),
        .candi2_pixles_o        (candi2_pixles  ),
        .candi3_pixles_o        (candi3_pixles  ),
        .candi4_pixles_o        (candi4_pixles  ),
        .candi5_pixles_o        (candi5_pixles  ),
        .candi6_pixles_o        (candi6_pixles  ),
        .candi7_pixles_o        (candi7_pixles  ),
        .candi8_pixles_o        (candi8_pixles  )       
);

fme_satd_gen satd_gen(
        .clk                    (clk            ),
        .rstn                   (rstn           ),

        // IP -> SATD IF
        .satd_start_i           (satd_start     ),

        .blk_idx_i              (blk_idx_ip     ),
        .mv_x_i                 (mv_x_ip        ),
        .mv_y_i                 (mv_y_ip        ),
        .half_ip_flag_i         (half_ip_flag_ip),

        .ip_ready_i             (ip_ready       ),
        .end_ip_i               (end_ip         ),

        .candi0_valid_i         (candi0_valid   ),
        .candi1_valid_i         (candi1_valid   ),
        .candi2_valid_i         (candi2_valid   ),
        .candi3_valid_i         (candi3_valid   ),
        .candi4_valid_i         (candi4_valid   ),
        .candi5_valid_i         (candi5_valid   ),
        .candi6_valid_i         (candi6_valid   ),
        .candi7_valid_i         (candi7_valid   ),
        .candi8_valid_i         (candi8_valid   ),

        .candi0_pixles_i        (candi0_pixles  ),
        .candi1_pixles_i        (candi1_pixles  ),
        .candi2_pixles_i        (candi2_pixles  ),
        .candi3_pixles_i        (candi3_pixles  ),
        .candi4_pixles_i        (candi4_pixles  ),
        .candi5_pixles_i        (candi5_pixles  ),
        .candi6_pixles_i        (candi6_pixles  ),
        .candi7_pixles_i        (candi7_pixles  ),
        .candi8_pixles_i        (candi8_pixles  ),

        // CUR <-> SATD IF
        .cur_rden_o             (fme_cur_rden_w   ),
        .cur_4x4_x_o            (fme_cur_4x4_x_w  ),
        .cur_4x4_y_o            (fme_cur_4x4_y_w  ),
        .cur_4x4_idx_o          (fme_cur_4x4_idx_w),
        .cur_pel_i              (fme_cur_pel_w    ),
        

        // COST <- SATD IF
        .cost_start_o           (cost_start     ),
        .mv_x_o                 (mv_x_satd      ),
        .mv_y_o                 (mv_y_satd      ),
        .half_ip_flag_o         (half_ip_flag_satd ),
        .blk_idx_o              (blk_idx_satd   ),

        .satd0_o                (satd0          ),
        .satd1_o                (satd1          ),
        .satd2_o                (satd2          ),
        .satd3_o                (satd3          ),
        .satd4_o                (satd4          ),
        .satd5_o                (satd5          ),
        .satd6_o                (satd6          ),
        .satd7_o                (satd7          ),
        .satd8_o                (satd8          ),
        .satd_valid_o           (satd_valid     )
);

fme_cost sp_cost(
        .clk                    (clk            ),
        .rstn                   (rstn           ),

        // SYS IF
        .lambda                 (lambda         ),
        .partition_i            (fimeif_partition_i     ),

        // SATD -> COST IF
        .cost_start_i           (cost_start     ),

        .mv_x_i                 (mv_x_satd      ),
        .mv_y_i                 (mv_y_satd      ),
        .blk_idx_i              (blk_idx_satd   ),
        .half_ip_flag_i         (half_ip_flag_satd      ),

        .satd0_i                (satd0          ),
        .satd1_i                (satd1          ),
        .satd2_i                (satd2          ),
        .satd3_i                (satd3          ),
        .satd4_i                (satd4          ),
        .satd5_i                (satd5          ),
        .satd6_i                (satd6          ),
        .satd7_i                (satd7          ),
        .satd8_i                (satd8          ),
        .satd_valid_i           (satd_valid     ),

        // CTRL <- COST IF
        .cost_done_o            (cost_done      ),
        .best_sp_o              (best_sp        ),

        // MC <- COST IF
        .best_cost_o            (fmv_cost       ),
        .fmv_best_o             (fmv_best       ),
        .fmv_wren_o             (fmv_wren       ),
        .fmv_sel_o              (fmv_sel        ),
        .fmv_addr_o             (fmv_addr       )       
);

assign cost_wr_ena_w = fmv_wren && {current_state == QUAR || current_state == DONE_QUAR } ;
assign fme_cost_adr_w = cost_wr_ena_w ? fmv_addr : fme_cst_rd_adr_w ;
assign fmv_cost_w = fmv_cost ;
db_mv_ram_sp_64x20 u_fme_cost_ram_sp_64x20(
        .clk        ( clk               ),
        .cen_i      ( 1'b0              ), // low active
        .wen_i      ( !cost_wr_ena_w    ), // low active
        .adr_i      ( fme_cost_adr_w    ),
        .wr_dat_i   ( fmv_cost_w        ),
        .rd_dat_o   ( fme_cst_rd_dat_w  )
    );

fme_ctrl ctrl(
        .clk                    ( clk                   ),
        .rstn                   ( rstn                  ),

        // SYS IF
        .sysif_start_i          ( sysif_start_i         ),
        .sysif_done_o           ( sysif_done_o          ),

        // STATE 
        .current_state          ( current_state         ),

        // FIME <-> CTRL IF
        .fimeif_partition_i     ( fimeif_partition_i    ),
        .fimeif_mv_rden_o       ( fimeif_mv_rden_o      ),
        .fimeif_mv_rdaddr_o     ( fimeif_mv_rdaddr_o    ),
        .fimeif_mv_data_i       ( fimeif_mv_data_i      ),

        // MC <-> CTRL IF
        .mcif_mv_rden_o         ( mcif_mv_rden_w        ),
        .mcif_mv_rdaddr_o       ( mcif_mv_rdaddr_w      ),
        .mcif_mv_data_i         ( mcif_mv_data_i        ),
    
        // REF <- CTRL IF
        .ref_rden_o             ( ref_rden_o            ),
        .ref_idx_x_o            ( ref_idx_x_o           ),
        .ref_idx_y_o            ( ref_idx_y_o           ),

        // IP <-> CTRL IF
        .ip_start_o             ( ip_start_ctrl         ),
        .ip_done_i              ( mc_end_ip             ),
        .ip_mv_x_o              ( ip_mv_x_ctrl          ),
        .ip_mv_y_o              ( ip_mv_y_ctrl          ),
        .ip_frac_x_o            ( ip_frac_x_ctrl        ),
        .ip_frac_y_o            ( ip_frac_y_ctrl        ),
        .ip_half_flag_o         ( ip_half_ctrl          ),
        .ip_idx_o               ( ip_idx_ctrl           ),

        // COST -> CTRL IF
        .cost_done_i            ( cost_done             ),
        .predicted_en_o         ( predicted_en          ),
        // skip interfaces
        .skip_start_o           ( skip_start_w          ),
        .skip_done_i            ( skip_done_w           ),
        .cur_cu_mod_o           ( cur_cu_mod_w          ),
        .cur_pu_x_o             ( cur_pu_pos_x_w        ),
        .cur_pu_y_o             ( cur_pu_pos_y_w        ),
        .cur_pu_wid_o           ( cur_pu_wid_w          ),
        .cur_pu_hgt_o           ( cur_pu_hgt_w          ),
        .cur_pu_blk_o           ( cur_pu_blk_w          ),
        .cur_pu_8x8_adr_o       ( cur_pu_8x8_adr_w      ),
        .cur_pu_blk_num_o       ( cur_pu_blk_num_w      ),
        .skip_pu_start_o        ( cur_pu_start_w        ),
        .mc_skip_flg_i          ( mc_skip_flg_w         )
);

fme_pred fme_pred (
        .clk                    (clk                    ),
        .rstn                   (rstn                   ),
        .ip_start_i             (ip_start_ctrl          ),
        .end_ip_i               (end_ip                 ),
        .imv_x_i                (imv_x                  ),
        .imv_y_i                (imv_y                  ),
        .fmv_x_i                (fmv_x                  ),
        .fmv_y_i                (fmv_y                  ),
        .block_idx_i            (ip_idx_ctrl            ),
        .candi0_valid_i         (candi0_valid           ),
        .candi1_valid_i         (candi1_valid           ),
        .candi2_valid_i         (candi2_valid           ),
        .candi3_valid_i         (candi3_valid           ),
        .candi4_valid_i         (candi4_valid           ),
        .candi5_valid_i         (candi5_valid           ),
        .candi6_valid_i         (candi6_valid           ),
        .candi7_valid_i         (candi7_valid           ),
        .candi8_valid_i         (candi8_valid           ),
        .candi0_pixles_i        (candi0_pixles          ),
        .candi1_pixles_i        (candi1_pixles          ),
        .candi2_pixles_i        (candi2_pixles          ),
        .candi3_pixles_i        (candi3_pixles          ),
        .candi4_pixles_i        (candi4_pixles          ),
        .candi5_pixles_i        (candi5_pixles          ),
        .candi6_pixles_i        (candi6_pixles          ),
        .candi7_pixles_i        (candi7_pixles          ),
        .candi8_pixles_i        (candi8_pixles          ),
        .pred_pixel_o           (mcif_pre_pixel_w       ),
        .pred_wren_o            (pred_wren              ),
        .pred_addr_o            (mcif_pre_addr_w        )          
);

fme_mv_buffer u_mv_buffer(
        .clk                     ( clk                  ),
        .rstn                    ( rstn                 ),
        .fme_ctu_x_i             ( sysif_cmb_x_i        ),
        .current_state_i         ( current_state        ),
        // top and left mv wr
        .mv_wr_ena_i             ( mcif_mv_rden_o       ),
        .mv_wr_adr_i             ( mcif_mv_rdaddr_o     ),
        .mv_wr_dat_i             ( mcif_mv_data_i       ),
        // left mv rd
        .lft_mv_rd_ena_i         ( lft_mv_rd_ena_w      ),
        .lft_mv_rd_adr_i         ( lft_mv_rd_adr_w      ),
        .lft_mv_rd_dat_o         ( lft_mv_rd_dat_w      ),
        // top  mv rd
        .top_mv_rd_ena_i         ( top_mv_rd_ena_w      ),
        .top_mv_rd_adr_i         ( top_mv_rd_adr_w      ),
        .top_mv_rd_dat_o         ( top_mv_rd_dat_w      )
);

fme_mv_candidate_prepare u_mv_candidates(
        .clk                    ( clk                   ),
        .rstn                   ( rstn                  ),
        // sys if
        .sys_ctu_x_all_i        ( sys_ctu_x_all_i       ),
        .sys_ctu_y_all_i        ( sys_ctu_y_all_i       ),
        .sys_x_all_i            ( sys_x_all_i           ),
        .sys_y_all_i            ( sys_y_all_i           ),
        .fme_ctu_x_i            ( sysif_cmb_x_i         ),
        .fme_ctu_y_i            ( sysif_cmb_y_i         ),
        // IinP flag
        .IinP_flag_i            ( IinP_flag_i           ),
        .pu_start_i             ( cur_pu_start_w && (current_state==MC||current_state==PRE_MC) ),
        // current LCU fmv
        .cur_fmv_rd_ena_o       ( cur_fmv_rd_ena_w      ),
        .cur_fmv_rd_adr_o       ( cur_fmv_rd_adr_w      ),
        .cur_fmv_rd_dat_i       ( mcif_mv_data_i        ),
        // left LCU mv 
        .lft_fmv_rd_ena_o       ( lft_mv_rd_ena_w       ),
        .lft_fmv_rd_adr_o       ( lft_mv_rd_adr_w       ),
        .lft_fmv_rd_dat_i       ( lft_mv_rd_dat_w       ),
        // top LCU mv  
        .top_fmv_rd_ena_o       ( top_mv_rd_ena_w       ),
        .top_fmv_rd_adr_o       ( top_mv_rd_adr_w       ),
        .top_fmv_rd_dat_i       ( top_mv_rd_dat_w       ),
        // pu position
        .pu_pos_x_i             ( cur_pu_pos_x_w        ),
        .pu_pos_y_i             ( cur_pu_pos_y_w        ),
        .pu_hgt_i               ( cur_pu_hgt_w          ),
        .pu_wid_i               ( cur_pu_wid_w          ),
        // mv candidate
        .mv_candi_a0_val_o      ( mv_a0_val_w           ),
        .mv_candi_a1_val_o      ( mv_a1_val_w           ),
        .mv_candi_b0_val_o      ( mv_b0_val_w           ),
        .mv_candi_b1_val_o      ( mv_b1_val_w           ),
        .mv_candi_b2_val_o      ( mv_b2_val_w           ),
        .mv_candi_a0_dat_o      ( mv_a0_dat_w           ),
        .mv_candi_a1_dat_o      ( mv_a1_dat_w           ),
        .mv_candi_b0_dat_o      ( mv_b0_dat_w           ),
        .mv_candi_b1_dat_o      ( mv_b1_dat_w           ),
        .mv_candi_b2_dat_o      ( mv_b2_dat_w           ),
        .fmv_candi_rdy_o        ( fmv_candi_rdy_w       )
        );

fme_skip u_fme_skip(
        .clk                    ( clk                   ),
        .rstn                   ( rstn                  ),
        // skip thresh
        .skip_cost_thresh_08    ( skip_cost_thresh_08   ),
        .skip_cost_thresh_16    ( skip_cost_thresh_16   ),
        .skip_cost_thresh_32    ( skip_cost_thresh_32   ),
        .skip_cost_thresh_64    ( skip_cost_thresh_64   ),
        // cfg
        .lambda                 ( lambda                ),
        .curr_state_i           ( current_state         ),
        .fme_skip_start_i       ( skip_start_w          ),
        .fme_skip_done_o        ( skip_done_w           ),
        // cur if
        .cur_rd_ena_o           ( skip_cur_rd_ena_w     ),
        .cur_4x4_idx_o          ( skip_cur_4x4_idx_w    ),
        .cur_4x4_x_o            ( skip_cur_4x4_x_w      ),
        .cur_4x4_y_o            ( skip_cur_4x4_y_w      ),
        .cur_pel_i              ( skip_cur_pel_w        ),
        // fmv wr
        .fmv_wr_ena_o           ( skip_fmv_wr_ena_w     ),
        .fmv_wr_adr_o           ( skip_fmv_wr_adr_w     ),
        .fmv_wr_dat_o           ( skip_fmv_wr_dat_w     ),
        // skip prediction 
        .pre_val_i              ( refpel_valid_w        ),
        .pre_pxl_i              ( ref_pel_i[60*`PIXEL_WIDTH-1:52*`PIXEL_WIDTH]),
        // position
        .cu_mod_i               ( cur_cu_mod_w          ),
        .pu_pos_x_i             ( cur_pu_pos_x_w        ),
        .pu_pos_y_i             ( cur_pu_pos_y_w        ),
        .pu_wid_i               ( cur_pu_wid_w          ),
        .pu_hgt_i               ( cur_pu_hgt_w          ),
        .pu_blk_i               ( cur_pu_blk_w          ),
        .pu_8x8_adr_i           ( cur_pu_8x8_adr_w      ),
        .pu_blk_num_i           ( cur_pu_blk_num_w      ),
        // mv candidates
        .fmv_candi_rdy_i        ( fmv_candi_rdy_w       ),
        .mv_a0_val_i            ( mv_a0_val_w           ),
        .mv_a1_val_i            ( mv_a1_val_w           ),
        .mv_b0_val_i            ( mv_b0_val_w           ),
        .mv_b1_val_i            ( mv_b1_val_w           ),
        .mv_b2_val_i            ( mv_b2_val_w           ),
        .mv_a0_dat_i            ( mv_a0_dat_w           ),
        .mv_a1_dat_i            ( mv_a1_dat_w           ),
        .mv_b0_dat_i            ( mv_b0_dat_w           ),
        .mv_b1_dat_i            ( mv_b1_dat_w           ),
        .mv_b2_dat_i            ( mv_b2_dat_w           ),
        // fme best cost
        .fme_cst_rd_ena_o       ( fme_cst_rd_ena_w      ),
        .fme_cst_rd_adr_o       ( fme_cst_rd_adr_w      ),
        .fme_cst_rd_dat_i       ( fme_cst_rd_dat_w      ),
        // fme cost sum
        .fme_cst_sum_o          ( fme_cost_o            ),
        // pu if
        .skip_pu_start_i        ( cur_pu_start_w        ),
        // blk if 
        .skip_blk_start_i       ( ip_start_ctrl         ),
        // output 
        .skip_idx_o             ( skip_idx_o            ),
        .skip_flg_o             ( skip_flag_o           ),
        .mc_skip_flg_o          ( mc_skip_flg_w         )
        );
//assign mcif_pre_wren_o = pred_wren & {predicted_en, predicted_en, predicted_en, predicted_en};

assign mcif_mv_wren_o     = (fmv_wren && ( (current_state>=PRE_HALF)&(current_state<=DONE_QUAR) )) // the third round, do not need to override mv buffer
                            || ( skip_fmv_wr_ena_w ) ; //(current_state == SKIP || current_state == DONE_SKIP) &&
assign mcif_mv_wraddr_o   = skip_fmv_wr_ena_w ? skip_fmv_wr_adr_w : fmv_addr ;
assign mcif_mv_data_o     = skip_fmv_wr_ena_w ? skip_fmv_wr_dat_w : fmv_best ;

assign imv_x = mc_skip_flg_w ? 0 : fimeif_mv_data_i[2*`FMV_WIDTH-1 : `FMV_WIDTH];
assign imv_y = mc_skip_flg_w ? 0 : fimeif_mv_data_i[`FMV_WIDTH-1   :          0];
assign fmv_x = mc_skip_flg_w ? 0 : mcif_mv_data_i  [2*`FMV_WIDTH-1 : `FMV_WIDTH];
assign fmv_y = mc_skip_flg_w ? 0 : mcif_mv_data_i  [`FMV_WIDTH-1   :          0];

//wire  enable_o;
//wire [3:0] wr_4x4_x_o;
//wire [3:0] wr_4x4_y_o;
//wire [4:0] wr_idx_o;
//wire [1:0] siz_o;
reg [8*`PIXEL_WIDTH-1:0] pre_pixels_middle_results;

// assign mcif_siz_o       = `SIZE_08;
// assign mcif_wr_4x4_x_o  = {mcif_pre_addr_w[5], (pred_wren[1]|pred_wren[0]), (pred_wren[2]|pred_wren[0]), 1'b0};
// assign mcif_wr_4x4_y_o  = {mcif_pre_addr_w[6], mcif_pre_addr_w[4:3], 1'b0};
// assign mcif_wr_idx_o    = {2'b0, mcif_pre_addr_w[2], 2'b0};
// assign mcif_pre_wren_o  = (|pred_wren) && predicted_en && (mcif_pre_addr_w[1:0]==3);

always @ ( posedge clk or negedge rstn ) begin 
    if ( !rstn ) begin 
        mcif_siz_o      <= 0 ;
        mcif_wr_4x4_x_o <= 0 ;
        mcif_wr_4x4_y_o <= 0 ;
        mcif_wr_idx_o   <= 0 ;
        mcif_pre_wren_o <= 0 ;
    end 
    else begin 
        mcif_siz_o       <= `SIZE_08;
        mcif_wr_4x4_x_o  <= {mcif_pre_addr_w[5], (pred_wren[1]|pred_wren[0]), (pred_wren[2]|pred_wren[0]), 1'b0};
        mcif_wr_4x4_y_o  <= {mcif_pre_addr_w[6], mcif_pre_addr_w[4:3], 1'b0};
        mcif_wr_idx_o    <= {2'b0, mcif_pre_addr_w[2], 2'b0};
        mcif_pre_wren_o  <= (|pred_wren) && predicted_en && (mcif_pre_addr_w[1:0]==3);
    end 
end 

always @( posedge clk or negedge rstn ) begin
    if ( !rstn )
        mcif_pre_pixel_o <= {64'b0, 64'b0, 64'b0, 64'b0};
    else 
        case(mcif_pre_addr_w[1:0])
            0: mcif_pre_pixel_o[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*24] <= pre_pixels_middle_results;
            1: mcif_pre_pixel_o[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*16] <= pre_pixels_middle_results;
            2: mcif_pre_pixel_o[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*08] <= pre_pixels_middle_results;
            3: mcif_pre_pixel_o[`PIXEL_WIDTH*08-1:`PIXEL_WIDTH*00] <= pre_pixels_middle_results;
            default : ;
        endcase
end

always @(*) begin
        pre_pixels_middle_results = 64'b0;
        begin
            case(pred_wren)
            4'b1000: pre_pixels_middle_results = mcif_pre_pixel_w[`PIXEL_WIDTH*32-1:`PIXEL_WIDTH*24];
            4'b0100: pre_pixels_middle_results = mcif_pre_pixel_w[`PIXEL_WIDTH*24-1:`PIXEL_WIDTH*16];
            4'b0010: pre_pixels_middle_results = mcif_pre_pixel_w[`PIXEL_WIDTH*16-1:`PIXEL_WIDTH*08];
            4'b0001: pre_pixels_middle_results = mcif_pre_pixel_w[`PIXEL_WIDTH*08-1:`PIXEL_WIDTH*00];
            default: pre_pixels_middle_results = 64'b0;
            endcase
        end
end

endmodule

