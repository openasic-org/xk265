//---------------------------------------------------------
//
//  File Name     : tb_enc_top.v 
//  Author        : TANG  
//  Date          : 2018-05-24
//  Description   : test bench of enc_top
//
//-----------------------------------------------------------

`include "enc_defines.v"

//---- defines --------------------------------------------
  
  `define TB_NAME   tb_enc_top   

  `define TEST_I 1
  `define TEST_P 0  

  // `define FORMAT_NV12

  `define FORMAT_YUV

  `define FRAME_WIDTH     416 // (`FRAME_W/`LCU_SIZE + 1)*`LCU_SIZE  // full LCU
  `define FRAME_HEIGHT    240 // (`FRAME_H/`LCU_SIZE + 1)*`LCU_SIZE  // full LCU

  `define INITIAL_QP      20
  `define GOP_LENGTH      50
  `define FRAME_TOTAL     2
  `define ENABLE_IinP     0
  `define ENABLE_DBSAO    0
  `define POSI4x4BIT      4 

  `define SKIP_COST_THRESH_8  0
  `define SKIP_COST_THRESH_16 (`SKIP_COST_THRESH_8 * 7) / 2
  `define SKIP_COST_THRESH_32 (`SKIP_COST_THRESH_16 * 7) / 2
  `define SKIP_COST_THRESH_64 (`SKIP_COST_THRESH_32 * 7) / 2

  
  //`define CHECK_ONE_FRAME 1
    `define CHECK_FRAME_NUM 2 


//---- test vectors ---------------------------------------
  `ifdef FORMAT_YUV
    `define FILE_CUR_YUV        "./tv/BlowingBubbles.yuv"
    `define FILE_REC_YUV        "./tv/rec.yuv"
  `else 
    `define FILE_CUR_YUV        "./tv/BlowingBubbles_nv12.yuv"
    `define FILE_REC_YUV        "./tv/rec_nv12.yuv"
  `endif 

  `define FILE_REG_K          "./tv/rc_coefficient.txt"
  `define FILE_FRAME_QP       "./tv/rc_frameqp.txt"

  `define FILE_CHECK_BS       "./tv/s_bit_stream.dat"

  // ime 
  `define FILE_IME_CFG        "./tv/ime_cfg.dat"

  // check list
  `define AUTO_CHECK
    `define CHECK_BS 
    `define CHECK_REC 
  
  // clk 
  `define HALF_CLK           5
  `define FULL_CLK           (`HALF_CLK*2)

  // waveform
  `define DUMP_FSDB 
          `define DUMP_TIME    0 
          `define DUMP_FILE    "tb_top.fsdb"
  
  // `define DUMP_SHM
  //         `define DUMP_SHM_FILE     "./dump/wave_form.shm"
  //         `define DUMP_SHM_TIME     0
  //         `define DUMP_SHM_LEVEL    "AS"    // all signal



module `TB_NAME ;

//---- parameter declaration -------------------------------------

  // global
  parameter     CMD_NUM_WIDTH          = 3                  ;

  // local
  parameter     SLOPE_1d2              = 0                  ;
  parameter     SLOPE_1                = 1                  ;
  parameter     SLOPE_2                = 2                  ;
  parameter     SLOPE_INF              = 3                  ;

  // derived
  localparam    CMD_DAT_WIDTH_ONE      =(`IME_MV_WIDTH_X  )      // center_x_o
                                       +(`IME_MV_WIDTH_Y  )      // center_y_o
                                       +(`IME_MV_WIDTH_X-1)      // length_x_o
                                       +(`IME_MV_WIDTH_Y-1)      // length_y_o
                                       +(2                )      // slope_o
                                       +(1                )      // downsample_o
                                       +(1                )      // partition_r
                                       +(1                ) ;    // use_feedback_o
  localparam    CMD_DAT_WIDTH          = CMD_DAT_WIDTH_ONE
                                       *(1<<CMD_NUM_WIDTH ) ;



//---- wire / reg declaration ---------------------------------
  // global
  reg                             clk                   ;
  reg                             rstn                  ;
  // cfg              
  reg                             sys_start             ;
  wire                            sys_done              ;
  reg   [`PIC_WIDTH      -1 :0]   sys_all_x             ;
  reg   [`PIC_HEIGHT     -1 :0]   sys_all_y             ;
  reg                             sys_type              ;
  reg   [6               -1 :0]   sys_init_qp           ;
  reg                             sys_IinP_ena          ;
  reg                             sys_dbsao_ena         ;
  reg   [5               -1 :0]   sys_posi4x4bit        ;
  reg   [32-1:0]                  skip_cost_thresh_08   ;
  reg   [32-1:0]                  skip_cost_thresh_16   ;
  reg   [32-1:0]                  skip_cost_thresh_32   ;
  reg   [32-1:0]                  skip_cost_thresh_64   ;

  // rc cfg 
  reg   [32              -1 :0]   sys_rc_bitnum_i       ;
  reg   [16              -1 :0]   sys_rc_k              ;
  reg   [6               -1 :0]   sys_rc_roi_height     ;
  reg   [7               -1 :0]   sys_rc_roi_width      ;
  reg   [7               -1 :0]   sys_rc_roi_x          ;
  reg   [7               -1 :0]   sys_rc_roi_y          ;
  reg                             sys_rc_roi_enable     ;
  reg   [10              -1 :0]   sys_rc_L1_frame_byte  ;
  reg   [10              -1 :0]   sys_rc_L2_frame_byte  ;
  reg                             sys_rc_lcu_en         ;
  reg   [6               -1 :0]   sys_rc_max_qp         ;
  reg   [6               -1 :0]   sys_rc_min_qp         ;
  reg   [6               -1 :0]   sys_rc_delta_qp       ;

  //ime_cfg
  reg   [CMD_NUM_WIDTH   -1 :0]   cmd_num_i             ;
  reg   [CMD_DAT_WIDTH   -1 :0]   cmd_dat_i             ;

  // ext if 
  wire  [1-1               : 0]   extif_start_o         ; // ext mem load start
  reg   [1-1               : 0]   extif_done_i          ; // ext mem load done
  wire  [5-1               : 0]   extif_mode_o          ; // "ext mode: {load/store} {luma
  wire  [`PIC_X_WIDTH+6-1  : 0]   extif_x_o             ; // x in ref frame
  wire  [`PIC_Y_WIDTH+6-1  : 0]   extif_y_o             ; // y in ref frame
  wire  [8-1               : 0]   extif_width_o         ; // ref window width
  wire  [8-1               : 0]   extif_height_o        ; // ref window height
  reg                             extif_wren_i          ;
  reg                             extif_rden_i          ;
  reg   [16*`PIXEL_WIDTH-1 : 0]   extif_data_i          ; // ext data reg
  wire  [16*`PIXEL_WIDTH-1 : 0]   extif_data_o          ; // ext data outp

  // bs
  wire                            bs_val_o              ;
  wire  [8-1                :0]   bs_dat_o              ;

//--- main body ---------------------------------------------------
  // clk 
  initial begin 
    clk = 0; 
    forever #5 clk = ~clk ;
  end 

  // rstn
  initial begin 
    rstn = 0;
    #(10*`FULL_CLK);
    @(negedge clk );
    rstn = 1;
  end 

  h265enc_top u_enc_top(
    // global
    .clk                 ( clk                  ),
    .rstn                ( rstn                 ),
    // sys_cfg_if
    .sys_start_i         ( sys_start            ),
    .sys_type_i          ( sys_type             ),
    .sys_all_x_i         ( sys_all_x            ),
    .sys_all_y_i         ( sys_all_y            ),
    .sys_init_qp_i       ( sys_init_qp          ),
    .sys_done_o          ( sys_done             ),
    .sys_IinP_ena_i      ( sys_IinP_ena         ),
    .sys_db_ena_i        ( sys_dbsao_ena        ),
    .sys_sao_ena_i       ( sys_dbsao_ena        ),
    .sys_posi4x4bit_i    ( sys_posi4x4bit       ),
    // skip thresh
    .skip_cost_thresh_08 ( skip_cost_thresh_08  ),
    .skip_cost_thresh_16 ( skip_cost_thresh_16  ),
    .skip_cost_thresh_32 ( skip_cost_thresh_32  ),
    .skip_cost_thresh_64 ( skip_cost_thresh_64  ),
    // rc_cfg_if
    .sys_rc_mod64_sum_o  (                      ),
    .sys_rc_bitnum_i     ( sys_rc_bitnum_i      ),
    .sys_rc_k            ( sys_rc_k             ),
    .sys_rc_roi_height   ( sys_rc_roi_height    ),
    .sys_rc_roi_width    ( sys_rc_roi_width     ),
    .sys_rc_roi_x        ( sys_rc_roi_x         ),
    .sys_rc_roi_y        ( sys_rc_roi_y         ),
    .sys_rc_roi_enable   ( sys_rc_roi_enable    ),
    .sys_rc_L1_frame_byte( sys_rc_L1_frame_byte ),
    .sys_rc_L2_frame_byte( sys_rc_L2_frame_byte ),
    .sys_rc_lcu_en       ( sys_rc_lcu_en        ),
    .sys_rc_max_qp       ( sys_rc_max_qp        ),
    .sys_rc_min_qp       ( sys_rc_min_qp        ),
    .sys_rc_delta_qp     ( sys_rc_delta_qp      ),
    // ime_cfg_if
    .sys_ime_cmd_num_i   ( cmd_num_i            ),
    .sys_ime_cmd_dat_i   ( cmd_dat_i            ),
    // ext_if
    .extif_start_o       ( extif_start_o        ),
    .extif_done_i        ( extif_done_i         ),
    .extif_mode_o        ( extif_mode_o         ),
    .extif_x_o           ( extif_x_o            ),
    .extif_y_o           ( extif_y_o            ),
    .extif_width_o       ( extif_width_o        ),
    .extif_height_o      ( extif_height_o       ),
    .extif_wren_i        ( extif_wren_i         ),
    .extif_rden_i        ( extif_rden_i         ),
    .extif_data_i        ( extif_data_i         ),
    .extif_data_o        ( extif_data_o         ),
    // bs_if
    .bs_val_o            ( bs_val_o             ),
    .bs_dat_o            ( bs_dat_o             )
    );


  // fake ext memory : para, memory & h_w_A
  parameter LOAD_CUR_SUB      = 01 ,
            LOAD_REF_SUB      = 02 ,
            LOAD_CUR_LUMA     = 03 ,
            LOAD_REF_LUMA     = 04 ,
            LOAD_CUR_CHROMA   = 05 ,
            LOAD_REF_CHROMA   = 06 ,
            LOAD_DB_LUMA      = 07 ,
            LOAD_DB_CHROMA    = 08 ,
            STORE_DB_LUMA     = 09 ,
            STORE_DB_CHROMA   = 10 ;

  // ori array
  reg [`PIXEL_WIDTH-1 :0]     ext_ori_yuv [`FRAME_WIDTH*`FRAME_HEIGHT*3/2-1:0] ;
  // rec array
  reg [`PIXEL_WIDTH-1 :0]     ext_rec_yuv [`FRAME_WIDTH*`FRAME_HEIGHT*3/2-1:0] ;
  // rec array from f265
  reg [`PIXEL_WIDTH-1 :0]     f265_rec_yuv [`FRAME_WIDTH*`FRAME_HEIGHT*3/2-1:0] ;
  // ref array
  reg [`PIXEL_WIDTH-1 :0]     ext_ref_yuv [`FRAME_WIDTH*`FRAME_HEIGHT*3/2-1:0] ;
  // for check
  reg   [16*`PIXEL_WIDTH-1 : 0]   f265_data             ;

  // for debug
  reg [`PIXEL_WIDTH-1:0] ext_debug_yuv_00 ,ext_debug_yuv_01 ,ext_debug_yuv_02 ,ext_debug_yuv_03 ;
  reg [`PIXEL_WIDTH-1:0] ext_debug_yuv_04 ,ext_debug_yuv_05 ,ext_debug_yuv_06 ,ext_debug_yuv_07 ;
  reg [`PIXEL_WIDTH-1:0] ext_debug_yuv_08 ,ext_debug_yuv_09 ,ext_debug_yuv_10 ,ext_debug_yuv_11 ;
  reg [`PIXEL_WIDTH-1:0] ext_debug_yuv_12 ,ext_debug_yuv_13 ,ext_debug_yuv_14 ,ext_debug_yuv_15 ;

  integer ext_height ;
  integer ext_width ;
  integer ext_addr; 

  integer   fp_cfg ;
  integer   fp_ori ;
  integer   fp_rec ;
  integer   fp_ref ;
  integer   fp_init ;
  integer   fp_check_bs ;
  integer   frame_num ;
  integer   pxl_cnt ;
  integer   pxl_adr ;
  reg [`PIXEL_WIDTH-1:0] ext_tmp_yuv ;
  integer   bs_byte_cnt ;
  reg [8-1 :0] check_bs ;

  // command
  reg signed [`IME_MV_WIDTH_X-1 :0]     center_x_r     ;
  reg signed [`IME_MV_WIDTH_Y-1 :0]     center_y_r     ;
  reg        [`IME_MV_WIDTH_X-2 :0]     length_x_r     ;
  reg        [`IME_MV_WIDTH_Y-2 :0]     length_y_r     ;
  reg        [2              -1 :0]     slope_r        ;
  reg                                   downsample_r   ;
  reg                                   partition_r    ;
  reg                                   use_feedback_r ;

  integer                               ime_cfg        ;
  integer                               fp_ime_cfg     ;
  reg signed [31                :0]     ime_cfg_dat    ; 
  integer                               rc_cfg         ;

  integer fp_reg_k ;
  integer fp_frame_qp ;

  // fake ext memory : reponse logic
  initial begin
    extif_done_i = 0 ;
    extif_wren_i = 0 ;
    extif_data_i = 0 ;
  
    forever begin
      @(negedge extif_start_o );
      case( extif_mode_o )
        LOAD_CUR_LUMA   : // load luma component of current LCU: line in
                          begin            
                                            @(negedge clk );
                                            for( ext_height=0 ;ext_height<extif_height_o ;ext_height=ext_height+1 ) begin
                                              for( ext_width=0 ;ext_width<extif_width_o ;ext_width=ext_width+16 ) begin
                                                extif_wren_i = 1 ;
                                                ext_addr = (extif_y_o+ext_height)*`FRAME_WIDTH+extif_x_o+ext_width;
                                                extif_data_i = { ext_ori_yuv[ext_addr+00] ,ext_ori_yuv[ext_addr+01] ,ext_ori_yuv[ext_addr+02] ,ext_ori_yuv[ext_addr+03]
                                                                ,ext_ori_yuv[ext_addr+04] ,ext_ori_yuv[ext_addr+05] ,ext_ori_yuv[ext_addr+06] ,ext_ori_yuv[ext_addr+07]
                                                                ,ext_ori_yuv[ext_addr+08] ,ext_ori_yuv[ext_addr+09] ,ext_ori_yuv[ext_addr+10] ,ext_ori_yuv[ext_addr+11]
                                                                ,ext_ori_yuv[ext_addr+12] ,ext_ori_yuv[ext_addr+13] ,ext_ori_yuv[ext_addr+14] ,ext_ori_yuv[ext_addr+15]
                                                               };
                                                { ext_debug_yuv_00 ,ext_debug_yuv_01 ,ext_debug_yuv_02 ,ext_debug_yuv_03
                                                 ,ext_debug_yuv_04 ,ext_debug_yuv_05 ,ext_debug_yuv_06 ,ext_debug_yuv_07
                                                 ,ext_debug_yuv_08 ,ext_debug_yuv_09 ,ext_debug_yuv_10 ,ext_debug_yuv_11
                                                 ,ext_debug_yuv_12 ,ext_debug_yuv_13 ,ext_debug_yuv_14 ,ext_debug_yuv_15
                                                } = extif_data_i ;
                                                @(negedge clk );
                                              end
                                            end
                                            extif_wren_i = 0 ;
                                            #100 ;
                                            @(negedge clk)
                                            extif_done_i = 1 ;
                                            @(negedge clk)
                                            extif_done_i = 0 ;
                          end
        LOAD_REF_LUMA   : // load luma component of reference LCU: line in
                          begin             
                                            @(negedge clk );
                                            for( ext_height=0 ;ext_height<extif_height_o ;ext_height=ext_height+1 ) begin
                                              for( ext_width=0 ;ext_width<extif_width_o ;ext_width=ext_width+16 ) begin
                                                extif_wren_i = 1 ;
                                                ext_addr = (extif_y_o+ext_height)*`FRAME_WIDTH+extif_x_o+ext_width;
                                                extif_data_i = { ext_ref_yuv[ext_addr+00] ,ext_ref_yuv[ext_addr+01] ,ext_ref_yuv[ext_addr+02] ,ext_ref_yuv[ext_addr+03]
                                                                ,ext_ref_yuv[ext_addr+04] ,ext_ref_yuv[ext_addr+05] ,ext_ref_yuv[ext_addr+06] ,ext_ref_yuv[ext_addr+07]
                                                                ,ext_ref_yuv[ext_addr+08] ,ext_ref_yuv[ext_addr+09] ,ext_ref_yuv[ext_addr+10] ,ext_ref_yuv[ext_addr+11]
                                                                ,ext_ref_yuv[ext_addr+12] ,ext_ref_yuv[ext_addr+13] ,ext_ref_yuv[ext_addr+14] ,ext_ref_yuv[ext_addr+15]
                                                               };
                                                { ext_debug_yuv_00 ,ext_debug_yuv_01 ,ext_debug_yuv_02 ,ext_debug_yuv_03
                                                 ,ext_debug_yuv_04 ,ext_debug_yuv_05 ,ext_debug_yuv_06 ,ext_debug_yuv_07
                                                 ,ext_debug_yuv_08 ,ext_debug_yuv_09 ,ext_debug_yuv_10 ,ext_debug_yuv_11
                                                 ,ext_debug_yuv_12 ,ext_debug_yuv_13 ,ext_debug_yuv_14 ,ext_debug_yuv_15
                                                } = extif_data_i ;
                                                @(negedge clk );
                                              end
                                            end
                                            extif_wren_i = 0 ;
                                            #100 ;
                                            @(negedge clk)
                                            extif_done_i = 1 ;
                                            @(negedge clk)
                                            extif_done_i = 0 ;
                          end
        LOAD_CUR_CHROMA : // load chroma component of current LCU: line in, all u then all v
                          begin             
                                            @(negedge clk );
                                            for( ext_height=0 ;ext_height<extif_height_o/2 ;ext_height=ext_height+1 ) begin
                                              for( ext_width=0 ;ext_width<extif_width_o ;ext_width=ext_width+16 ) begin
                                                extif_wren_i = 1 ;
                                                ext_addr = `FRAME_WIDTH*`FRAME_HEIGHT+(extif_y_o/2+ext_height)*`FRAME_WIDTH+extif_x_o+ext_width;
                                                extif_data_i = { ext_ori_yuv[ext_addr+00] ,ext_ori_yuv[ext_addr+01] ,ext_ori_yuv[ext_addr+02] ,ext_ori_yuv[ext_addr+03]
                                                                ,ext_ori_yuv[ext_addr+04] ,ext_ori_yuv[ext_addr+05] ,ext_ori_yuv[ext_addr+06] ,ext_ori_yuv[ext_addr+07]
                                                                ,ext_ori_yuv[ext_addr+08] ,ext_ori_yuv[ext_addr+09] ,ext_ori_yuv[ext_addr+10] ,ext_ori_yuv[ext_addr+11]
                                                                ,ext_ori_yuv[ext_addr+12] ,ext_ori_yuv[ext_addr+13] ,ext_ori_yuv[ext_addr+14] ,ext_ori_yuv[ext_addr+15]
                                                               };
                                                { ext_debug_yuv_00 ,ext_debug_yuv_01 ,ext_debug_yuv_02 ,ext_debug_yuv_03
                                                 ,ext_debug_yuv_04 ,ext_debug_yuv_05 ,ext_debug_yuv_06 ,ext_debug_yuv_07
                                                 ,ext_debug_yuv_08 ,ext_debug_yuv_09 ,ext_debug_yuv_10 ,ext_debug_yuv_11
                                                 ,ext_debug_yuv_12 ,ext_debug_yuv_13 ,ext_debug_yuv_14 ,ext_debug_yuv_15
                                                } = extif_data_i ;
                                                @(negedge clk );
                                              end
                                            end
                                            extif_wren_i = 0 ;
                                            #100 ;
                                            @(negedge clk)
                                            extif_done_i = 1 ;
                                            @(negedge clk)
                                            extif_done_i = 0 ;
                          end
        LOAD_REF_CHROMA : // load chroma component of reference LCU: line in, all u then all v
                          begin             
                                            @(negedge clk );
                                            for( ext_height=0 ;ext_height<extif_height_o/2 ;ext_height=ext_height+1 ) begin
                                              for( ext_width=0 ;ext_width<extif_width_o ;ext_width=ext_width+16 ) begin
                                                extif_wren_i = 1 ;
                                                ext_addr  = `FRAME_WIDTH*`FRAME_HEIGHT+(extif_y_o/2+ext_height)*`FRAME_WIDTH+extif_x_o+ext_width ;
                                                extif_data_i = { ext_ref_yuv[ext_addr+00] ,ext_ref_yuv[ext_addr+01] ,ext_ref_yuv[ext_addr+02] ,ext_ref_yuv[ext_addr+03]
                                                                ,ext_ref_yuv[ext_addr+04] ,ext_ref_yuv[ext_addr+05] ,ext_ref_yuv[ext_addr+06] ,ext_ref_yuv[ext_addr+07]
                                                                ,ext_ref_yuv[ext_addr+08] ,ext_ref_yuv[ext_addr+09] ,ext_ref_yuv[ext_addr+10] ,ext_ref_yuv[ext_addr+11]
                                                                ,ext_ref_yuv[ext_addr+12] ,ext_ref_yuv[ext_addr+13] ,ext_ref_yuv[ext_addr+14] ,ext_ref_yuv[ext_addr+15]
                                                               };
                                                { ext_debug_yuv_00 ,ext_debug_yuv_01 ,ext_debug_yuv_02 ,ext_debug_yuv_03
                                                 ,ext_debug_yuv_04 ,ext_debug_yuv_05 ,ext_debug_yuv_06 ,ext_debug_yuv_07
                                                 ,ext_debug_yuv_08 ,ext_debug_yuv_09 ,ext_debug_yuv_10 ,ext_debug_yuv_11
                                                 ,ext_debug_yuv_12 ,ext_debug_yuv_13 ,ext_debug_yuv_14 ,ext_debug_yuv_15
                                                } = extif_data_i ;
                                                @(negedge clk );
                                              end
                                            end
                                            extif_wren_i = 0 ;
                                            #100 ;
                                            @(negedge clk)
                                            extif_done_i = 1 ;
                                            @(negedge clk)
                                            extif_done_i = 0 ;
                          end
        LOAD_DB_LUMA    : // load deblocked results: line in
                          begin             
                                            @(negedge clk );
                                            for( ext_height=0 ;ext_height<extif_height_o ;ext_height=ext_height+1 ) begin
                                              for( ext_width=0 ;ext_width<extif_width_o ;ext_width=ext_width+16 ) begin
                                                extif_wren_i = 1 ;
                                                ext_addr = (extif_y_o+ext_height)*`FRAME_WIDTH+extif_x_o+ext_width ;
                                                extif_data_i = { ext_rec_yuv[ext_addr+00] ,ext_rec_yuv[ext_addr+01] ,ext_rec_yuv[ext_addr+02] ,ext_rec_yuv[ext_addr+03]
                                                                ,ext_rec_yuv[ext_addr+04] ,ext_rec_yuv[ext_addr+05] ,ext_rec_yuv[ext_addr+06] ,ext_rec_yuv[ext_addr+07]
                                                                ,ext_rec_yuv[ext_addr+08] ,ext_rec_yuv[ext_addr+09] ,ext_rec_yuv[ext_addr+10] ,ext_rec_yuv[ext_addr+11]
                                                                ,ext_rec_yuv[ext_addr+12] ,ext_rec_yuv[ext_addr+13] ,ext_rec_yuv[ext_addr+14] ,ext_rec_yuv[ext_addr+15]
                                                               };
                                                { ext_debug_yuv_00 ,ext_debug_yuv_01 ,ext_debug_yuv_02 ,ext_debug_yuv_03
                                                 ,ext_debug_yuv_04 ,ext_debug_yuv_05 ,ext_debug_yuv_06 ,ext_debug_yuv_07
                                                 ,ext_debug_yuv_08 ,ext_debug_yuv_09 ,ext_debug_yuv_10 ,ext_debug_yuv_11
                                                 ,ext_debug_yuv_12 ,ext_debug_yuv_13 ,ext_debug_yuv_14 ,ext_debug_yuv_15
                                                } = extif_data_i ;
                                                @(negedge clk );
                                              end
                                            end
                                            extif_wren_i = 0 ;
                                            #100 ;
                                            @(negedge clk)
                                            extif_done_i = 1 ;
                                            @(negedge clk)
                                            extif_done_i = 0 ;
                          end
        LOAD_DB_CHROMA :  // load deblocked results: line in
                          begin             
                                            @(negedge clk );
                                            for( ext_height=0 ;ext_height<extif_height_o/2 ;ext_height=ext_height+1 ) begin
                                              for( ext_width=0 ;ext_width<extif_width_o ;ext_width=ext_width+16 ) begin
                                                extif_wren_i = 1 ;
                                                ext_addr  = `FRAME_WIDTH*`FRAME_HEIGHT+(extif_y_o/2+ext_height)*`FRAME_WIDTH+extif_x_o+ext_width ;
                                                extif_data_i = { ext_rec_yuv[ext_addr+00] ,ext_rec_yuv[ext_addr+01] ,ext_rec_yuv[ext_addr+02] ,ext_rec_yuv[ext_addr+03]
                                                                ,ext_rec_yuv[ext_addr+04] ,ext_rec_yuv[ext_addr+05] ,ext_rec_yuv[ext_addr+06] ,ext_rec_yuv[ext_addr+07]
                                                                ,ext_rec_yuv[ext_addr+08] ,ext_rec_yuv[ext_addr+09] ,ext_rec_yuv[ext_addr+10] ,ext_rec_yuv[ext_addr+11]
                                                                ,ext_rec_yuv[ext_addr+12] ,ext_rec_yuv[ext_addr+13] ,ext_rec_yuv[ext_addr+14] ,ext_rec_yuv[ext_addr+15]
                                                               };
                                                { ext_debug_yuv_00 ,ext_debug_yuv_01 ,ext_debug_yuv_02 ,ext_debug_yuv_03
                                                 ,ext_debug_yuv_04 ,ext_debug_yuv_05 ,ext_debug_yuv_06 ,ext_debug_yuv_07
                                                 ,ext_debug_yuv_08 ,ext_debug_yuv_09 ,ext_debug_yuv_10 ,ext_debug_yuv_11
                                                 ,ext_debug_yuv_12 ,ext_debug_yuv_13 ,ext_debug_yuv_14 ,ext_debug_yuv_15
                                                } = extif_data_i ;
                                                @(negedge clk );
                                              end
                                            end
                                            extif_wren_i = 0 ;
                                            #100 ;
                                            @(negedge clk)
                                            extif_done_i = 1 ;
                                            @(negedge clk)
                                            extif_done_i = 0 ;
                          end
        STORE_DB_LUMA   : // dump deblocked results: line in
                          begin             
                                            @(negedge clk );
                                            for( ext_height=0 ;ext_height<extif_height_o ;ext_height=ext_height+1 ) begin
                                              for( ext_width=0 ;ext_width<extif_width_o ;ext_width=ext_width+16 ) begin
                                                extif_rden_i = 1 ;
                                                ext_addr = (extif_y_o+ext_height)*`FRAME_WIDTH+extif_x_o+ext_width ;
                                                { ext_rec_yuv[ext_addr+00] ,ext_rec_yuv[ext_addr+01] ,ext_rec_yuv[ext_addr+02] ,ext_rec_yuv[ext_addr+03]
                                                 ,ext_rec_yuv[ext_addr+04] ,ext_rec_yuv[ext_addr+05] ,ext_rec_yuv[ext_addr+06] ,ext_rec_yuv[ext_addr+07]
                                                 ,ext_rec_yuv[ext_addr+08] ,ext_rec_yuv[ext_addr+09] ,ext_rec_yuv[ext_addr+10] ,ext_rec_yuv[ext_addr+11]
                                                 ,ext_rec_yuv[ext_addr+12] ,ext_rec_yuv[ext_addr+13] ,ext_rec_yuv[ext_addr+14] ,ext_rec_yuv[ext_addr+15]
                                                 } = extif_data_o ;
                                                { ext_debug_yuv_00 ,ext_debug_yuv_01 ,ext_debug_yuv_02 ,ext_debug_yuv_03
                                                 ,ext_debug_yuv_04 ,ext_debug_yuv_05 ,ext_debug_yuv_06 ,ext_debug_yuv_07
                                                 ,ext_debug_yuv_08 ,ext_debug_yuv_09 ,ext_debug_yuv_10 ,ext_debug_yuv_11
                                                 ,ext_debug_yuv_12 ,ext_debug_yuv_13 ,ext_debug_yuv_14 ,ext_debug_yuv_15
                                                } = extif_data_o ;
                                                f265_data = { f265_rec_yuv[ext_addr+00] ,f265_rec_yuv[ext_addr+01] ,f265_rec_yuv[ext_addr+02] ,f265_rec_yuv[ext_addr+03]
                                                             ,f265_rec_yuv[ext_addr+04] ,f265_rec_yuv[ext_addr+05] ,f265_rec_yuv[ext_addr+06] ,f265_rec_yuv[ext_addr+07]
                                                             ,f265_rec_yuv[ext_addr+08] ,f265_rec_yuv[ext_addr+09] ,f265_rec_yuv[ext_addr+10] ,f265_rec_yuv[ext_addr+11]
                                                             ,f265_rec_yuv[ext_addr+12] ,f265_rec_yuv[ext_addr+13] ,f265_rec_yuv[ext_addr+14] ,f265_rec_yuv[ext_addr+15]
                                                             };
                                                `ifdef CHECK_REC
                                                if ( extif_data_o != f265_data && (extif_x_o+ext_width+15<`FRAME_WIDTH) && (extif_y_o+ext_height<`FRAME_HEIGHT)) begin 
                                                  $display("ERROR at REC LUMA, y = %d, x = %d, f265 is %2h, however h265 is %2h ", 
                                                            (extif_y_o+ext_height), (extif_x_o+ext_width), f265_data, extif_data_o );
                                                  $finish; 
                                                end // if
                                                `endif
                                                @(negedge clk );
                                              end
                                            end
                                            extif_rden_i = 0 ;
                                            #100 ;
                                            @(negedge clk)
                                            extif_done_i = 1 ;
                                            @(negedge clk)
                                            extif_done_i = 0 ;
                          end
        STORE_DB_CHROMA : // dump deblocked results: line in
                          begin             
                                            @(negedge clk );
                                            for( ext_height=0 ;ext_height<extif_height_o/2 ;ext_height=ext_height+1 ) begin
                                              for( ext_width=0 ;ext_width<extif_width_o ;ext_width=ext_width+16 ) begin
                                                extif_rden_i = 1 ;
                                                ext_addr =  `FRAME_WIDTH*`FRAME_HEIGHT+  (extif_y_o/2+ext_height)*`FRAME_WIDTH+extif_x_o+ext_width ;
                                                { ext_rec_yuv[ext_addr+00] ,ext_rec_yuv[ext_addr+01] ,ext_rec_yuv[ext_addr+02] ,ext_rec_yuv[ext_addr+03]
                                                 ,ext_rec_yuv[ext_addr+04] ,ext_rec_yuv[ext_addr+05] ,ext_rec_yuv[ext_addr+06] ,ext_rec_yuv[ext_addr+07]
                                                 ,ext_rec_yuv[ext_addr+08] ,ext_rec_yuv[ext_addr+09] ,ext_rec_yuv[ext_addr+10] ,ext_rec_yuv[ext_addr+11]
                                                 ,ext_rec_yuv[ext_addr+12] ,ext_rec_yuv[ext_addr+13] ,ext_rec_yuv[ext_addr+14] ,ext_rec_yuv[ext_addr+15]
                                                 } = extif_data_o ;
                                                { ext_debug_yuv_00 ,ext_debug_yuv_01 ,ext_debug_yuv_02 ,ext_debug_yuv_03
                                                 ,ext_debug_yuv_04 ,ext_debug_yuv_05 ,ext_debug_yuv_06 ,ext_debug_yuv_07
                                                 ,ext_debug_yuv_08 ,ext_debug_yuv_09 ,ext_debug_yuv_10 ,ext_debug_yuv_11
                                                 ,ext_debug_yuv_12 ,ext_debug_yuv_13 ,ext_debug_yuv_14 ,ext_debug_yuv_15
                                                } = extif_data_o ;

                                                f265_data = { f265_rec_yuv[ext_addr+00] ,f265_rec_yuv[ext_addr+01] ,f265_rec_yuv[ext_addr+02] ,f265_rec_yuv[ext_addr+03]
                                                             ,f265_rec_yuv[ext_addr+04] ,f265_rec_yuv[ext_addr+05] ,f265_rec_yuv[ext_addr+06] ,f265_rec_yuv[ext_addr+07]
                                                             ,f265_rec_yuv[ext_addr+08] ,f265_rec_yuv[ext_addr+09] ,f265_rec_yuv[ext_addr+10] ,f265_rec_yuv[ext_addr+11]
                                                             ,f265_rec_yuv[ext_addr+12] ,f265_rec_yuv[ext_addr+13] ,f265_rec_yuv[ext_addr+14] ,f265_rec_yuv[ext_addr+15]
                                                             };
                                                `ifdef CHECK_REC
                                                if ( extif_data_o != f265_data && (extif_x_o+ext_width+15<`FRAME_WIDTH) && (extif_y_o+ext_height<`FRAME_HEIGHT)) begin 
                                                  $display("ERROR at REC CHROMA, y = %d, x = %d, f265 is %2h, however h265 is %2h ", 
                                                            (extif_y_o+ext_height), (extif_x_o+ext_width), f265_data, extif_data_o );
                                                  $finish; 
                                                end // if
                                                `endif
                                                @(negedge clk );
                                              end
                                            end
                                            extif_rden_i = 0 ;
                                            #100 ;
                                            @(negedge clk) ;
                                            extif_done_i = 1 ;
                                            //$display("\t\t at %08d, Frame(%02d), LCU(%02d, %02d) done", 
                                            //                $time, frame_num, u_enc_top.ec_y, u_enc_top.ec_x);
                                            @(negedge clk)
                                            extif_done_i = 0 ;
                          end
        default         : // default response
                          begin             #100 ;
                                            @(negedge clk)
                                            extif_done_i = 1 ;
                                            @(negedge clk)
                                            extif_done_i = 0 ;
                          end
      endcase
    end
  end


//---- read yuv from file ------------------------------------------------------------

  `ifdef DISABLE_DBSAO
    initial begin 
      force u_enc_top.u_enc_core.u_dbsao_top.u_db_bs.tu_edge_o = 0;
      force u_enc_top.u_enc_core.u_dbsao_top.u_db_bs.pu_edge_o = 0;
      force u_enc_top.u_enc_core.u_dbsao_top.sao_data_o = 0;
      force u_enc_top.u_enc_core.u_dbsao_top.u_sao_top.y_sao_offset_r = 0;
      force u_enc_top.u_enc_core.u_dbsao_top.u_sao_top.u_sao_offset_r = 0;
      force u_enc_top.u_enc_core.u_dbsao_top.u_sao_top.v_sao_offset_r = 0;
    end 
  `endif 

  initial begin 
    // sys if 
    sys_type = `INTRA;
    sys_start = 0;
    sys_init_qp = `INITIAL_QP ;
    sys_all_x = `FRAME_WIDTH ;
    sys_all_y = `FRAME_HEIGHT ;
    sys_IinP_ena = `ENABLE_IinP;
    sys_dbsao_ena  = `ENABLE_DBSAO ;
    sys_posi4x4bit = `POSI4x4BIT ;
    skip_cost_thresh_08 = `SKIP_COST_THRESH_8  ;
    skip_cost_thresh_16 = `SKIP_COST_THRESH_16 ;
    skip_cost_thresh_32 = `SKIP_COST_THRESH_32 ;
    skip_cost_thresh_64 = `SKIP_COST_THRESH_64 ;
    // rate control cfg 
    sys_rc_k             = 0 ;
    sys_rc_bitnum_i      = 'd10000 ;
    sys_rc_roi_height    = 'd1  ;
    sys_rc_roi_width     = 'd1  ;
    sys_rc_roi_x         = 'd4  ;
    sys_rc_roi_y         = 'd2  ;
    sys_rc_roi_enable    = 0  ;
    sys_rc_L1_frame_byte = 'd100 ;
    sys_rc_L2_frame_byte = 'd300 ;
    sys_rc_lcu_en        = 1'b0 ;
    sys_rc_max_qp        = 'd51 ;
    sys_rc_min_qp        = 'd10 ;
    sys_rc_delta_qp      = 'd4  ;
    check_bs             = 0 ;
    bs_byte_cnt          = 0 ;
    // file 
    fp_ori = $fopen( `FILE_CUR_YUV, "r" );
    fp_rec = $fopen( `FILE_REC_YUV, "r" );
    fp_ref = $fopen( `FILE_REC_YUV, "r" );
    fp_check_bs = $fopen( `FILE_CHECK_BS, "r" );
    fp_ime_cfg = $fopen( `FILE_IME_CFG, "r" );
    fp_reg_k = $fopen(`FILE_REG_K, "r");
    fp_frame_qp = $fopen(`FILE_FRAME_QP, "r");

      // lcu index
      ime_cfg = $fscanf( fp_ime_cfg ,"%d" ,ime_cfg_dat );
      ime_cfg = $fscanf( fp_ime_cfg ,"%d" ,ime_cfg_dat );
      // frame size
      ime_cfg = $fscanf( fp_ime_cfg ,"%d" ,ime_cfg_dat );
      ime_cfg = $fscanf( fp_ime_cfg ,"%d" ,ime_cfg_dat );
      // cfg
      ime_cfg = $fscanf( fp_ime_cfg ,"%d" ,cmd_num_i   );
      // cfg - 0
      begin
        if (cmd_num_i>=0) begin
          ime_cfg = $fscanf( fp_ime_cfg, "%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n", center_x_r, center_y_r, length_x_r, length_y_r, slope_r, downsample_r, partition_r, use_feedback_r );
        end
        else begin
          center_x_r     = 0        ;
          center_y_r     = 0        ;
          length_x_r     = 0        ;
          length_y_r     = 0        ;
          slope_r        = 0        ;
          downsample_r   = 0        ;
          partition_r    = 0        ;
          use_feedback_r = 0        ;
        end
        cmd_dat_i      = { center_x_r
                          ,center_y_r
                          ,length_x_r
                          ,length_y_r
                          ,slope_r
                          ,downsample_r
                          ,partition_r
                          ,use_feedback_r
                          ,cmd_dat_i }>>CMD_DAT_WIDTH_ONE ;
      end
      // cfg - 1
      begin
        if (cmd_num_i>=1) begin
          ime_cfg = $fscanf( fp_ime_cfg, "%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n", center_x_r, center_y_r, length_x_r, length_y_r, slope_r, downsample_r, partition_r, use_feedback_r );
        end
        else begin
          center_x_r     = 0        ;
          center_y_r     = 0        ;
          length_x_r     = 0        ;
          length_y_r     = 0        ;
          slope_r        = 0        ;
          downsample_r   = 0        ;
          partition_r    = 0        ;
          use_feedback_r = 0        ;
        end
        cmd_dat_i      = { center_x_r
                          ,center_y_r
                          ,length_x_r
                          ,length_y_r
                          ,slope_r
                          ,downsample_r
                          ,partition_r
                          ,use_feedback_r
                          ,cmd_dat_i }>>CMD_DAT_WIDTH_ONE ;
      end
      // cfg - 2
      begin
        if (cmd_num_i>=2) begin
          ime_cfg = $fscanf( fp_ime_cfg, "%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n", center_x_r, center_y_r, length_x_r, length_y_r, slope_r, downsample_r, partition_r, use_feedback_r );
        end
        else begin
          center_x_r     = 0        ;
          center_y_r     = 0        ;
          length_x_r     = 0        ;
          length_y_r     = 0        ;
          slope_r        = 0        ;
          downsample_r   = 0        ;
          partition_r    = 0        ;
          use_feedback_r = 0        ;
        end
        cmd_dat_i    = { center_x_r
                        ,center_y_r
                        ,length_x_r
                        ,length_y_r
                        ,slope_r
                        ,downsample_r
                        ,partition_r
                        ,use_feedback_r
                        ,cmd_dat_i }>>CMD_DAT_WIDTH_ONE ;
      end
      // cfg - 3
      begin
        if (cmd_num_i>=3) begin
          ime_cfg = $fscanf( fp_ime_cfg, "%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n", center_x_r, center_y_r, length_x_r, length_y_r, slope_r, downsample_r, partition_r, use_feedback_r );
        end
        else begin
          center_x_r     = 0        ;
          center_y_r     = 0        ;
          length_x_r     = 0        ;
          length_y_r     = 0        ;
          slope_r        = 0        ;
          downsample_r   = 0        ;
          partition_r    = 0        ;
          use_feedback_r = 0        ;
        end
        cmd_dat_i    = { center_x_r
                        ,center_y_r
                        ,length_x_r
                        ,length_y_r
                        ,slope_r
                        ,downsample_r
                        ,partition_r
                        ,use_feedback_r
                        ,cmd_dat_i }>>CMD_DAT_WIDTH_ONE ;
      end
      // cfg - 4
      begin
        if (cmd_num_i>=4) begin
          ime_cfg = $fscanf( fp_ime_cfg, "%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n", center_x_r, center_y_r, length_x_r, length_y_r, slope_r, downsample_r, partition_r, use_feedback_r );
        end
        else begin
          center_x_r     = 0        ;
          center_y_r     = 0        ;
          length_x_r     = 0        ;
          length_y_r     = 0        ;
          slope_r        = 0        ;
          downsample_r   = 0        ;
          partition_r    = 0        ;
          use_feedback_r = 0        ;
        end
        cmd_dat_i    = { center_x_r
                        ,center_y_r
                        ,length_x_r
                        ,length_y_r
                        ,slope_r
                        ,downsample_r
                        ,partition_r
                        ,use_feedback_r
                        ,cmd_dat_i }>>CMD_DAT_WIDTH_ONE ;
      end
      // cfg - 5
      begin
        if (cmd_num_i>=5) begin
          ime_cfg = $fscanf( fp_ime_cfg, "%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n", center_x_r, center_y_r, length_x_r, length_y_r, slope_r, downsample_r, partition_r, use_feedback_r );
        end
        else begin
          center_x_r     = 0        ;
          center_y_r     = 0        ;
          length_x_r     = 0        ;
          length_y_r     = 0        ;
          slope_r        = 0        ;
          downsample_r   = 0        ;
          partition_r    = 0        ;
          use_feedback_r = 0        ;
        end
        cmd_dat_i    = { center_x_r
                        ,center_y_r
                        ,length_x_r
                        ,length_y_r
                        ,slope_r
                        ,downsample_r
                        ,partition_r
                        ,use_feedback_r
                        ,cmd_dat_i }>>CMD_DAT_WIDTH_ONE ;
      end
      // cfg - 6
      begin
        if (cmd_num_i>=6) begin
          ime_cfg = $fscanf( fp_ime_cfg, "%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n", center_x_r, center_y_r, length_x_r, length_y_r, slope_r, downsample_r, partition_r, use_feedback_r );
        end
        else begin
          center_x_r     = 0        ;
          center_y_r     = 0        ;
          length_x_r     = 0        ;
          length_y_r     = 0        ;
          slope_r        = 0        ;
          downsample_r   = 0        ;
          partition_r    = 0        ;
          use_feedback_r = 0        ;
        end
        cmd_dat_i    = { center_x_r
                        ,center_y_r
                        ,length_x_r
                        ,length_y_r
                        ,slope_r
                        ,downsample_r
                        ,partition_r
                        ,use_feedback_r
                        ,cmd_dat_i }>>CMD_DAT_WIDTH_ONE ;
      end
      // cfg - 7
      begin
        if (cmd_num_i>=7) begin
          ime_cfg = $fscanf( fp_ime_cfg, "%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n", center_x_r, center_y_r, length_x_r, length_y_r, slope_r, downsample_r, partition_r, use_feedback_r );
        end
        else begin
          center_x_r     = 0        ;
          center_y_r     = 0        ;
          length_x_r     = 0        ;
          length_y_r     = 0        ;
          slope_r        = 0        ;
          downsample_r   = 0        ;
          partition_r    = 0        ;
          use_feedback_r = 0        ;
        end
        cmd_dat_i    = { center_x_r
                        ,center_y_r
                        ,length_x_r
                        ,length_y_r
                        ,slope_r
                        ,downsample_r
                        ,partition_r
                        ,use_feedback_r
                        ,cmd_dat_i }>>CMD_DAT_WIDTH_ONE ;
      end


    wait(rstn);

    $monitor( "\tat %08d, Frame Number = %02d, mb_x_first = %02d, mb_y_first = %02d",
          $time, frame_num, u_enc_top.u_enc_ctrl.pre_l_x_o, u_enc_top.u_enc_ctrl.pre_l_y_o );

    for ( frame_num = 0 ; frame_num < `FRAME_TOTAL; frame_num = frame_num + 1 ) begin 
      `ifdef FORMAT_NV12
        // initial ori_y
        for ( pxl_cnt = 0 ; pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT*3/2 ; pxl_cnt = pxl_cnt + 1 ) begin 
          fp_init = $fread( ext_tmp_yuv, fp_ori ) ;
          ext_ori_yuv[pxl_cnt] = ext_tmp_yuv ;
        end // for pxl_cnt
  
  		if ( frame_num%`GOP_LENGTH != 0 ) begin 
  			// initial f265 ref for check
    	    for ( pxl_cnt = 0 ; pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT*3/2 ; pxl_cnt = pxl_cnt + 1 ) begin 
    	      fp_init = $fread( ext_tmp_yuv, fp_ref ) ;
    	      ext_ref_yuv[pxl_cnt] = ext_tmp_yuv ;
    	    end // for pxl_cnt
    	end 

        // initial f265 rec for check
        for ( pxl_cnt = 0 ; pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT*3/2 ; pxl_cnt = pxl_cnt + 1 ) begin 
          fp_init = $fread( ext_tmp_yuv, fp_rec ) ;
          f265_rec_yuv[pxl_cnt] = ext_tmp_yuv ;
        end // for pxl_cnt
      `endif // format nv12

      `ifdef FORMAT_YUV 
        // initial ori_y
        for ( pxl_cnt = 0 ; pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT*3/2 ; pxl_cnt = pxl_cnt + 1 ) begin 
          fp_init = $fread( ext_tmp_yuv, fp_ori ) ;
          if ( pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT )
            ext_ori_yuv[pxl_cnt] = ext_tmp_yuv ;
          else if ( pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT*5/4 ) begin  // u
            pxl_adr = `FRAME_WIDTH*`FRAME_HEIGHT + ((pxl_cnt - `FRAME_WIDTH*`FRAME_HEIGHT)/(`FRAME_WIDTH/2))*`FRAME_WIDTH + 2*(pxl_cnt%(`FRAME_WIDTH/2));
            ext_ori_yuv[pxl_adr] = ext_tmp_yuv ;
          end else begin // v
            pxl_adr = `FRAME_WIDTH*`FRAME_HEIGHT + ((pxl_cnt - `FRAME_WIDTH*`FRAME_HEIGHT*5/4)/(`FRAME_WIDTH/2))*`FRAME_WIDTH + 2*(pxl_cnt%(`FRAME_WIDTH/2))+1;
            ext_ori_yuv[pxl_adr] = ext_tmp_yuv ;
          end 
        end // for pxl_cnt
  
  		// initial f265 rec for check
  		if ( frame_num%`GOP_LENGTH != 0 ) begin 
        	for ( pxl_cnt = 0 ; pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT*3/2 ; pxl_cnt = pxl_cnt + 1 ) begin 
        	  fp_init = $fread( ext_tmp_yuv, fp_ref ) ;
        	  if ( pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT )
        	    ext_ref_yuv[pxl_cnt] = ext_tmp_yuv ;
        	  else if ( pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT*5/4 ) begin  // u
        	    pxl_adr = `FRAME_WIDTH*`FRAME_HEIGHT + ((pxl_cnt - `FRAME_WIDTH*`FRAME_HEIGHT)/(`FRAME_WIDTH/2))*`FRAME_WIDTH + 2*(pxl_cnt%(`FRAME_WIDTH/2));
        	    ext_ref_yuv[pxl_adr] = ext_tmp_yuv ;
        	  end else begin // v
        	    pxl_adr = `FRAME_WIDTH*`FRAME_HEIGHT + ((pxl_cnt - `FRAME_WIDTH*`FRAME_HEIGHT*5/4)/(`FRAME_WIDTH/2))*`FRAME_WIDTH + 2*(pxl_cnt%(`FRAME_WIDTH/2))+1;
        	    ext_ref_yuv[pxl_adr] = ext_tmp_yuv ;
        	  end 
        	end // for pxl_cnt
        end // end if frame num

        // initial f265 rec for check
        for ( pxl_cnt = 0 ; pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT*3/2 ; pxl_cnt = pxl_cnt + 1 ) begin 
          fp_init = $fread( ext_tmp_yuv, fp_rec ) ;
          if ( pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT )
            f265_rec_yuv[pxl_cnt] = ext_tmp_yuv ;
          else if ( pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT*5/4 ) begin  // u
            pxl_adr = `FRAME_WIDTH*`FRAME_HEIGHT + ((pxl_cnt - `FRAME_WIDTH*`FRAME_HEIGHT)/(`FRAME_WIDTH/2))*`FRAME_WIDTH + 2*(pxl_cnt%(`FRAME_WIDTH/2));
            f265_rec_yuv[pxl_adr] = ext_tmp_yuv ;
          end else begin // v
            pxl_adr = `FRAME_WIDTH*`FRAME_HEIGHT + ((pxl_cnt - `FRAME_WIDTH*`FRAME_HEIGHT*5/4)/(`FRAME_WIDTH/2))*`FRAME_WIDTH + 2*(pxl_cnt%(`FRAME_WIDTH/2))+1;
            f265_rec_yuv[pxl_adr] = ext_tmp_yuv ;
          end 
        end // for pxl_cnt
      `endif // format yuv

      if ( frame_num%`GOP_LENGTH == 0 )
        sys_type = `INTRA;
      else 
        sys_type = `INTER ;

      if ( ( sys_type==`INTRA && `TEST_I == 1 )
        || ( sys_type==`INTER && `TEST_P == 1 ) 

        `ifdef CHECK_ONE_FRAME
          && (frame_num == `CHECK_FRAME_NUM)
        `endif

        ) begin 
        @(negedge clk );
        sys_start = 1 ;
        @(negedge clk );
        sys_start = 0 ;
        if ( sys_type==`INTRA)
        	$display("\t at %08d, starting INTRA ENCODING frame(%02d) ...", $time, frame_num);
        else 
        	$display("\t at %08d, starting INTER ENCODING frame(%02d) ...", $time, frame_num);
        @(posedge sys_done );
        	$display(" done ");
        #100 ;
      end 
      else begin 
        if ( sys_type==`INTRA)
        	$display("\t at %08d, skipping INTRA ENCODING frame(%02d) ...", $time, frame_num);
        else 
        	$display("\t at %08d, skipping INTER ENCODING frame(%02d) ...", $time, frame_num);
      end 

      // rc cfg 
      if ( frame_num > 0 ) begin 
        rc_cfg = $fscanf( fp_reg_k ,"%d" ,sys_rc_k ); 
        sys_rc_lcu_en        = 1'b0 ;
      end 
      rc_cfg = $fscanf( fp_frame_qp ,"%d" ,sys_init_qp );

    `ifdef AUTO_CHECK
    /*
      `ifdef CHECK_REC
        $display("******* START CHECK REC YUV ! ********* ");
        for ( pxl_cnt = 0 ; pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT*3/2 ; pxl_cnt = pxl_cnt + 1 ) begin 
          if ( ext_rec_yuv[pxl_cnt] != f265_rec_yuv[pxl_cnt] ) begin 
            $display("ERROR at REC y = %d, x = %d, f265 is %2h, however h265 is %2h ", 
                      pxl_cnt/`FRAME_WIDTH, pxl_cnt%`FRAME_WIDTH, f265_rec_yuv[pxl_cnt], ext_rec_yuv[pxl_cnt]);
          end // if
        end // for pxl_cnt
      `endif 
    */
    `endif // auto check

      // copy current frame rec for the next frame ref
      // for ( pxl_cnt = 0 ; pxl_cnt < `FRAME_WIDTH*`FRAME_HEIGHT*3/2 ; pxl_cnt = pxl_cnt + 1 ) begin 
      //   ext_ref_yuv[pxl_cnt] = ext_rec_yuv[pxl_cnt] ;
      // end // for pxl_cnt

    end // for frame_num

    $finish ;

  end 

  `ifdef CHECK_BS 
    always @ (posedge clk ) begin
          if (bs_val_o == 1) begin 
            fp_init = $fscanf(fp_check_bs, "%h", check_bs);
            if ( check_bs != bs_dat_o ) begin
              $display("ERROR at BS at bs_byte_cnt = %5d, f265 is %h, h265 is %h", bs_byte_cnt, check_bs, bs_dat_o);
	      $finish ;
            end
            bs_byte_cnt=bs_byte_cnt+1;
          end 
    end 
  `endif // check bs

//---- DUMP FSDB ---------------------------------------------------------------------

  `ifdef DUMP_FSDB

    initial begin
      #`DUMP_TIME ;
      $fsdbDumpfile( `DUMP_FILE );
      $fsdbDumpvars( `TB_NAME );
      #100 ;
      $display( "\t\t dump (fsdb) to this test is on !\n" );
    end

  `endif

  `ifdef DUMP_SHM

    initial begin
      #`DUMP_SHM_TIME ;
      $shm_open( `DUMP_SHM_FILE );
      $shm_probe( tb_top ,`DUMP_SHM_LEVEL );
      #100 ;
      $display( "\t\t dump (shm) to this test is on !\n" );
    end

  `endif


endmodule 
