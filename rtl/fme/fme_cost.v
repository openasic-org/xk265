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
//  Filename      : fme_cost.v
//  Author        : Yufeng Bai
//  Email         : byfchina@gmail.com  
//
//  $Id$
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module fme_cost (
        clk             ,
        rstn            ,
        // qp_i            ,
        lambda          ,
        cost_start_i    ,
        mv_x_i          ,
        mv_y_i          ,
        blk_idx_i       ,
        half_ip_flag_i  ,
        cost_done_o     ,
        partition_i     ,
        satd0_i         ,
        satd1_i         ,
        satd2_i         ,
        satd3_i         ,
        satd4_i         ,
        satd5_i         ,
        satd6_i         ,
        satd7_i         ,
        satd8_i         ,
        satd_valid_i    ,
        best_cost_o     ,
        best_sp_o       ,
        fmv_best_o      ,
        fmv_wren_o      ,
        fmv_sel_o       ,
        fmv_addr_o              
);

// ********************************************
//
//    INPUT / OUTPUT DECLARATION
//
// ********************************************

parameter SATD_SUM_WIDTH = `PIXEL_WIDTH + 10 ;

input    [1-1:0]                 clk             ; // clk signal 
input    [1-1:0]                 rstn            ; // asynchronous reset 
input    [7-1:0]                 lambda          ;// qp value
input    [1-1:0]                 cost_start_i    ; // cost calculation start 
input signed [`FMV_WIDTH-1:0]    mv_x_i          ; //  
input signed [`FMV_WIDTH-1:0]    mv_y_i          ; //  
input    [6-1:0]                 blk_idx_i       ; // 8x8 block index from satd generator 
input    [1-1:0]                 half_ip_flag_i  ; // half or quarter interpolation 
output   [1-1:0]                 cost_done_o     ; // cost calculation done 
input    [21*2-1:0]              partition_i     ; // current lcu inter partition information 
input    [SATD_SUM_WIDTH-1:0]    satd0_i         ; // candidate 0 SATD 
input    [SATD_SUM_WIDTH-1:0]    satd1_i         ; // candidate 1 SATD 
input    [SATD_SUM_WIDTH-1:0]    satd2_i         ; // candidate 2 SATD 
input    [SATD_SUM_WIDTH-1:0]    satd3_i         ; // candidate 3 SATD 
input    [SATD_SUM_WIDTH-1:0]    satd4_i         ; // candidate 4 SATD 
input    [SATD_SUM_WIDTH-1:0]    satd5_i         ; // candidate 5 SATD 
input    [SATD_SUM_WIDTH-1:0]    satd6_i         ; // candidate 6 SATD 
input    [SATD_SUM_WIDTH-1:0]    satd7_i         ; // candidate 7 SATD 
input    [SATD_SUM_WIDTH-1:0]    satd8_i         ; // candidate 8 SATD 
input    [1-1:0]                 satd_valid_i    ; // satd valid 
output   [SATD_SUM_WIDTH-1:0]    best_cost_o    ; // best cost
output   [2*`FMV_WIDTH-1:0]      fmv_best_o      ; // best fraction motion vector  
output   [1-1:0]                 fmv_wren_o      ; // fmv sram write enable 
output   [1-1:0]                 fmv_sel_o       ; // fmv sram write selection 0: FMVI, 1: FMVO
output   [6-1:0]                 fmv_addr_o      ; // fmv sram address 
output   [4-1:0]                 best_sp_o       ; // best search point

// ********************************************
//
//    PARAMETER DECLARATION
//
// ********************************************

parameter MV_CODE_BITS = 5;

// ********************************************
//
//    WIRE / REG DECLARATION
//
// ********************************************

wire [1:                  0] partition16_00                   ;
wire [1:                  0] partition16_01                   ;
wire [1:                  0] partition16_02                   ;
wire [1:                  0] partition16_03                   ;
wire [1:                  0] partition16_04                   ;
wire [1:                  0] partition16_05                   ;
wire [1:                  0] partition16_06                   ;
wire [1:                  0] partition16_07                   ;
wire [1:                  0] partition16_08                   ;
wire [1:                  0] partition16_09                   ;
wire [1:                  0] partition16_10                   ;
wire [1:                  0] partition16_11                   ;
wire [1:                  0] partition16_12                   ;
wire [1:                  0] partition16_13                   ;
wire [1:                  0] partition16_14                   ;
wire [1:                  0] partition16_15                   ;
wire [1:                  0] partition32_00                   ;
wire [1:                  0] partition32_01                   ;
wire [1:                  0] partition32_02                   ;
wire [1:                  0] partition32_03                   ;
wire [1:                  0] partition64                      ;

wire  [1:                  0] pre_cnt32                            ;
wire  [1:                  0] pre_cnt16                            ;
wire  [1:                  0] pre_cnt08                            ;

reg  [1:                  0] mode16, mode32                   ;
wire [1:                  0] mode64                           ;

reg                          clear_satd                       ;

wire signed [`FMV_WIDTH-1:0] mvd0_x, mvd1_x, mvd2_x          ;
wire signed [`FMV_WIDTH-1:0] mvd0_y, mvd1_y, mvd2_y          ;

wire [`FMV_WIDTH :        0] codenum_mvd0_x_plus1, codenum_mvd1_x_plus1, codenum_mvd2_x_plus1;
wire [`FMV_WIDTH :        0] codenum_mvd0_y_plus1, codenum_mvd1_y_plus1, codenum_mvd2_y_plus1;   
                       

wire [MV_CODE_BITS-1   :0] bitsnum_mvd0_x,bitsnum_mvd1_x,bitsnum_mvd2_x;
wire [MV_CODE_BITS-1   :0] bitsnum_mvd0_y,bitsnum_mvd1_y,bitsnum_mvd2_y;

reg [MV_CODE_BITS      :0] bitsnum_mvd00,bitsnum_mvd01, bitsnum_mvd02;
reg [MV_CODE_BITS      :0] bitsnum_mvd10,bitsnum_mvd11, bitsnum_mvd12;
reg [MV_CODE_BITS      :0] bitsnum_mvd20,bitsnum_mvd21, bitsnum_mvd22;

reg [MV_CODE_BITS + 7  :0] cost_mv00, cost_mv01, cost_mv02           ;
reg [MV_CODE_BITS + 7  :0] cost_mv10, cost_mv11, cost_mv12           ;
reg [MV_CODE_BITS + 7  :0] cost_mv20, cost_mv21, cost_mv22           ;

reg [SATD_SUM_WIDTH         :0] cost00, cost01, cost02                    ;
reg [SATD_SUM_WIDTH         :0] cost10, cost11, cost12                    ;
reg [SATD_SUM_WIDTH         :0] cost20, cost21, cost22                    ;


wire [SATD_SUM_WIDTH:0] best_cost0_1s, best_cost1_1s, best_cost2_1s, best_cost3_1s;
wire [SATD_SUM_WIDTH:0] best_cost0_2s, best_cost1_2s                      ;
wire [SATD_SUM_WIDTH:0] best_cost0_3s                                     ;

wire [1        :0] bcand0_x_1s, bcand1_x_1s, bcand2_x_1s, bcand3_x_1s;
wire [1        :0] bcand0_y_1s, bcand1_y_1s, bcand2_y_1s, bcand3_y_1s;
wire [1        :0] bcand0_x_2s, bcand1_x_2s                          ;
wire [1        :0] bcand0_y_2s, bcand1_y_2s                          ;
wire [1        :0] bcand0_x_3s                                       ;
wire [1        :0] bcand0_y_3s                                       ;
wire signed [1 :0] bcand_x_4s                                        ;
wire signed [1 :0] bcand_y_4s                                        ;

wire signed [2 :0] bcand_mv_x                                        ; 
wire signed [2 :0] bcand_mv_y                                        ; 

reg  signed [3:0] best_candidates                                ;
reg  signed [`FMV_WIDTH-1:0] best_mv_x,best_mv_y                            ;
reg  [1-1      :0]    fmv_sel_o                                      ;



wire               pre_clear_satd, pre_clear64, pre_clear32, pre_clear16, pre_clear8;

reg    [1:           0]  wcnt32,wcnt16,wcnt08;
reg    [1:           0]  cnt32,cnt16,cnt08;
reg    [6-1:         0]  mvWriteCount, mvWriteCnt;
reg    [1-1:         0]  fmv_wren_o;
wire   [3-1:         0]  fmv_addr_x,fmv_addr_y;

reg    [1:           0]  post_mode16, post_mode32, post_mode64;
reg    [6-1:         0]  mvwriter;


reg    [1-1:         0]  cost_done_o;
reg                      satd_valid;
// ********************************************
//
//   Parsing Partition Mode 
//
// ********************************************

assign pre_cnt32          = blk_idx_i[5:4];
assign pre_cnt16          = blk_idx_i[3:2];
assign pre_cnt08          = blk_idx_i[1:0];

assign partition64    = partition_i[1 : 0];
assign partition32_00 = partition_i[3 : 2];
assign partition32_01 = partition_i[5 : 4];
assign partition32_02 = partition_i[7 : 6];
assign partition32_03 = partition_i[9 : 8];
assign partition16_00 = partition_i[11 : 10];
assign partition16_01 = partition_i[13 : 12];
assign partition16_02 = partition_i[15 : 14];
assign partition16_03 = partition_i[17 : 16];
assign partition16_04 = partition_i[19 : 18];
assign partition16_05 = partition_i[21 : 20];
assign partition16_06 = partition_i[23 : 22];
assign partition16_07 = partition_i[25 : 24];
assign partition16_08 = partition_i[27 : 26];
assign partition16_09 = partition_i[29 : 28];
assign partition16_10 = partition_i[31 : 30];
assign partition16_11 = partition_i[33 : 32];
assign partition16_12 = partition_i[35 : 34];
assign partition16_13 = partition_i[37 : 36];
assign partition16_14 = partition_i[39 : 38];
assign partition16_15 = partition_i[41 : 40];

assign mode64         = partition64;

always @ (*) begin
    case(pre_cnt32)
        2'd0: mode32 = partition32_00;
        2'd1: mode32 = partition32_01;
        2'd2: mode32 = partition32_02;
        2'd3: mode32 = partition32_03;
        default:;
    endcase
end

always @ (*) begin
    case({pre_cnt32,pre_cnt16})
        4'd00:mode16 = partition16_00;
        4'd01:mode16 = partition16_01;
        4'd02:mode16 = partition16_02;
        4'd03:mode16 = partition16_03;
        4'd04:mode16 = partition16_04;
        4'd05:mode16 = partition16_05;
        4'd06:mode16 = partition16_06;
        4'd07:mode16 = partition16_07;
        4'd08:mode16 = partition16_08;
        4'd09:mode16 = partition16_09;
        4'd10:mode16 = partition16_10;
        4'd11:mode16 = partition16_11;
        4'd12:mode16 = partition16_12;
        4'd13:mode16 = partition16_13;
        4'd14:mode16 = partition16_14;
        4'd15:mode16 = partition16_15;
        default:;
    endcase
end

assign pre_clear8  = (mode16 == `PART_SPLIT);

assign pre_clear16 = (((mode16 == `PART_2NXN) && (pre_cnt08 == 'd1)) || ((mode16 == `PART_NX2N) && pre_cnt08 == 'd2) || pre_cnt08 == 'd3) &&
                     (mode64 == `PART_SPLIT && mode32 == `PART_SPLIT);

assign pre_clear32 = (((mode32 == `PART_2NXN) && (pre_cnt16 == 'd1)) || ((mode32 == `PART_NX2N) && pre_cnt16 == 'd2) || pre_cnt16 == 'd3) &&
                     (mode64 == `PART_SPLIT && pre_cnt08 == 'd3);

assign pre_clear64 = (((mode64 == `PART_2NXN) && (pre_cnt32 == 'd1)) || ((mode64 == `PART_NX2N) && pre_cnt32 == 'd2) || pre_cnt32 == 'd3) &&
                     (pre_cnt08 == 'd3 && pre_cnt16 == 'd3);

assign pre_clear_satd = pre_clear8 || (pre_clear16) || (pre_clear32 && pre_cnt08 == 'd3) || (pre_clear64 && pre_cnt16 == 'd3 && pre_cnt08 == 'd3);

always @ (*) begin
    if(pre_clear8) begin
        mvWriteCount = 'd0;
    end
    else if(pre_clear16) begin
        if(mode16 == `PART_2NX2N)
            mvWriteCount = 'd3;
        else
            mvWriteCount = 'd1;
    end
    else if (pre_clear32) begin
        if(mode32 == `PART_2NX2N)
            mvWriteCount = 'd15;
        else
            mvWriteCount = 'd7;
    end
    else if(pre_clear64) begin
        if (mode64 == `PART_2NX2N) 
            mvWriteCount = 'd63;
        else
            mvWriteCount = 'd31;
    end
    else begin
        mvWriteCount = 'd0;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
        clear_satd  <= 1'b0;
//      mvWriteCnt  <= 'd0;
        cnt32       <= 'd0;
        cnt16       <= 'd0;
        cnt08       <= 'd0;
        post_mode64 <= 'd0;
        post_mode32 <= 'd0;
        post_mode16 <= 'd0;
        fmv_sel_o   <= 'd0; 
    end else if (satd_valid_i) begin
        clear_satd  <= pre_clear_satd;
//      mvWriteCnt  <= mvWriteCount;
        cnt32       <= pre_cnt32;
        cnt16       <= pre_cnt16;
        cnt08       <= pre_cnt08;
        post_mode64 <= mode64;
        post_mode32 <= mode32;
        post_mode16 <= mode16;
        fmv_sel_o   <= half_ip_flag_i;
    end
end


always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
        mvWriteCnt  <= 'd0;
    end else if (satd_valid_i & pre_clear_satd) begin
        mvWriteCnt  <= mvWriteCount;
    end
end
// ********************************************
//
//    Main code
//
// ********************************************

// 1. mvd = mv - mvp, yet mvp is always 0
//
assign mvd0_x = (half_ip_flag_i)?(mv_x_i - 2'd2):(mv_x_i - 2'd1);
assign mvd1_x = (half_ip_flag_i)?(mv_x_i       ):(mv_x_i       );
assign mvd2_x = (half_ip_flag_i)?(mv_x_i + 2'd2):(mv_x_i + 2'd1);
assign mvd0_y = (half_ip_flag_i)?(mv_y_i - 2'd2):(mv_y_i - 2'd1);
assign mvd1_y = (half_ip_flag_i)?(mv_y_i       ):(mv_y_i       );
assign mvd2_y = (half_ip_flag_i)?(mv_y_i + 2'd2):(mv_y_i + 2'd1); 

// 2. code num of mvd
assign codenum_mvd0_x_plus1 = (mvd0_x[`FMV_WIDTH-1])?({1'b0,~mvd0_x[`FMV_WIDTH-2:0],1'b0} + 3)://???1
                              ((|mvd0_x[`FMV_WIDTH-2:0])?({1'b0, mvd0_x[`FMV_WIDTH-2:0],1'b0}):1);
assign codenum_mvd1_x_plus1 = (mvd1_x[`FMV_WIDTH-1])?({1'b0,~mvd1_x[`FMV_WIDTH-2:0],1'b0} + 3):
                              ((|mvd1_x[`FMV_WIDTH-2:0])?({1'b0, mvd1_x[`FMV_WIDTH-2:0],1'b0}):1);
assign codenum_mvd2_x_plus1 = (mvd2_x[`FMV_WIDTH-1])?({1'b0,~mvd2_x[`FMV_WIDTH-2:0],1'b0} + 3):
                              ((|mvd2_x[`FMV_WIDTH-2:0])?({1'b0, mvd2_x[`FMV_WIDTH-2:0],1'b0}):1);                                                   
assign codenum_mvd0_y_plus1 = (mvd0_y[`FMV_WIDTH-1])?({1'b0,~mvd0_y[`FMV_WIDTH-2:0],1'b0} + 3):
                              ((|mvd0_y[`FMV_WIDTH-2:0])?({1'b0, mvd0_y[`FMV_WIDTH-2:0],1'b0}):1);
assign codenum_mvd1_y_plus1 = (mvd1_y[`FMV_WIDTH-1])?({1'b0,~mvd1_y[`FMV_WIDTH-2:0],1'b0} + 3):
                              ((|mvd1_y[`FMV_WIDTH-2:0])?({1'b0, mvd1_y[`FMV_WIDTH-2:0],1'b0}):1);
assign codenum_mvd2_y_plus1 = (mvd2_y[`FMV_WIDTH-1])?({1'b0,~mvd2_y[`FMV_WIDTH-2:0],1'b0} + 3):
                              ((|mvd2_y[`FMV_WIDTH-2:0])?({1'b0, mvd2_y[`FMV_WIDTH-2:0],1'b0}):1);

// 3. bits num of mvd
bits_num bn_x0(.codenum_i(codenum_mvd0_x_plus1),.bitsnum_o(bitsnum_mvd0_x));
bits_num bn_x1(.codenum_i(codenum_mvd1_x_plus1),.bitsnum_o(bitsnum_mvd1_x));
bits_num bn_x2(.codenum_i(codenum_mvd2_x_plus1),.bitsnum_o(bitsnum_mvd2_x));
bits_num bn_y0(.codenum_i(codenum_mvd0_y_plus1),.bitsnum_o(bitsnum_mvd0_y));
bits_num bn_y1(.codenum_i(codenum_mvd1_y_plus1),.bitsnum_o(bitsnum_mvd1_y));
bits_num bn_y2(.codenum_i(codenum_mvd2_y_plus1),.bitsnum_o(bitsnum_mvd2_y));

// 5. bitsnum of mvd (mvd_x + mvd_y) , use register in this level
always @(posedge clk or negedge rstn) begin
  if(!rstn) begin
    bitsnum_mvd00 <= 0;
    bitsnum_mvd01 <= 0;
    bitsnum_mvd02 <= 0;
    bitsnum_mvd10 <= 0;
    bitsnum_mvd11 <= 0;
    bitsnum_mvd12 <= 0;
    bitsnum_mvd20 <= 0;
    bitsnum_mvd21 <= 0;
    bitsnum_mvd22 <= 0;
  end
  else begin
    bitsnum_mvd00 <= bitsnum_mvd0_x + bitsnum_mvd0_y;
    bitsnum_mvd01 <= bitsnum_mvd1_x + bitsnum_mvd0_y;
    bitsnum_mvd02 <= bitsnum_mvd2_x + bitsnum_mvd0_y;
    bitsnum_mvd10 <= bitsnum_mvd0_x + bitsnum_mvd1_y;
    bitsnum_mvd11 <= bitsnum_mvd1_x + bitsnum_mvd1_y;
    bitsnum_mvd12 <= bitsnum_mvd2_x + bitsnum_mvd1_y;
    bitsnum_mvd20 <= bitsnum_mvd0_x + bitsnum_mvd2_y;
    bitsnum_mvd21 <= bitsnum_mvd1_x + bitsnum_mvd2_y;
    bitsnum_mvd22 <= bitsnum_mvd2_x + bitsnum_mvd2_y;
  end
end

// 6. mv cost = lambda * bitsnum of mvd
// always @(qp_i)
//   case(qp_i)
//     0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15: 
//       lambda = 1;
//     16,17,18,19:
//       lambda = 2;
//     20,21,22:
//       lambda = 3;
//     23,24,25:
//       lambda = 4;
//     26:
//       lambda = 5;
//     27,28:
//       lambda = 6;
//     29:
//       lambda = 7;
//     30:
//       lambda = 8;
//     31:
//       lambda = 9;
//     32:
//       lambda = 10;
//     33:
//       lambda = 11;
//     34:
//       lambda = 13;
//     35:
//       lambda = 14;
//     36:
//       lambda = 16;
//     37:
//       lambda = 18;
//     38:
//       lambda = 20;
//     39:
//       lambda = 23;
//     40:
//       lambda = 25;
//     41:
//       lambda = 29;
//     42:
//       lambda = 32;
//     43:
//       lambda = 36;
//     44:
//       lambda = 40;
//     45:
//       lambda = 45;
//     46:
//       lambda = 51;
//     47:
//       lambda = 57;
//     48:
//       lambda = 64;
//     49:
//       lambda = 72;
//     50:
//       lambda = 81;
//     51:
//       lambda = 91;
//     default:
//       lambda = 0;
//   endcase

always @( * ) begin
   cost_mv00 = lambda * bitsnum_mvd00;
   cost_mv01 = lambda * bitsnum_mvd01;
   cost_mv02 = lambda * bitsnum_mvd02;
   
   cost_mv10 = lambda * bitsnum_mvd10;
   cost_mv11 = lambda * bitsnum_mvd11;
   cost_mv12 = lambda * bitsnum_mvd12;
   
   cost_mv20 = lambda * bitsnum_mvd20;
   cost_mv21 = lambda * bitsnum_mvd21;
   cost_mv22 = lambda * bitsnum_mvd22;
end

// 7. cost of search points = mvcost + satd , use register in this level
wire    [17:0]  mvcost00        ;
wire    [17:0]  mvcost01        ;
wire    [17:0]  mvcost02        ;
wire    [17:0]  mvcost10        ;
wire    [17:0]  mvcost11        ;
wire    [17:0]  mvcost12        ;
wire    [17:0]  mvcost20        ;
wire    [17:0]  mvcost21        ;
wire    [17:0]  mvcost22        ;

assign  mvcost00 = (pre_clear_satd) ? ({6'b0,cost_mv00}) : ({SATD_SUM_WIDTH{1'b0}});
assign  mvcost01 = (pre_clear_satd) ? ({6'b0,cost_mv01}) : ({SATD_SUM_WIDTH{1'b0}});
assign  mvcost02 = (pre_clear_satd) ? ({6'b0,cost_mv02}) : ({SATD_SUM_WIDTH{1'b0}});
assign  mvcost10 = (pre_clear_satd) ? ({6'b0,cost_mv10}) : ({SATD_SUM_WIDTH{1'b0}});
assign  mvcost11 = (pre_clear_satd) ? ({6'b0,cost_mv11}) : ({SATD_SUM_WIDTH{1'b0}});
assign  mvcost12 = (pre_clear_satd) ? ({6'b0,cost_mv12}) : ({SATD_SUM_WIDTH{1'b0}});
assign  mvcost20 = (pre_clear_satd) ? ({6'b0,cost_mv20}) : ({SATD_SUM_WIDTH{1'b0}});
assign  mvcost21 = (pre_clear_satd) ? ({6'b0,cost_mv21}) : ({SATD_SUM_WIDTH{1'b0}});
assign  mvcost22 = (pre_clear_satd) ? ({6'b0,cost_mv22}) : ({SATD_SUM_WIDTH{1'b0}});

wire    [18:0]  sp_cost00       ;
wire    [18:0]  sp_cost01       ;
wire    [18:0]  sp_cost02       ;
wire    [18:0]  sp_cost10       ;
wire    [18:0]  sp_cost11       ;
wire    [18:0]  sp_cost12       ;
wire    [18:0]  sp_cost20       ;
wire    [18:0]  sp_cost21       ;
wire    [18:0]  sp_cost22       ;

assign  sp_cost00 = satd0_i + mvcost00  ;
assign  sp_cost01 = satd1_i + mvcost01  ;
assign  sp_cost02 = satd2_i + mvcost02  ;
assign  sp_cost10 = satd3_i + mvcost10  ;
assign  sp_cost11 = satd4_i + mvcost11  ;
assign  sp_cost12 = satd5_i + mvcost12  ;
assign  sp_cost20 = satd6_i + mvcost20  ;
assign  sp_cost21 = satd7_i + mvcost21  ;
assign  sp_cost22 = satd8_i + mvcost22  ;

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        cost00 <= 0; cost01 <= 0; cost02 <= 0;
        cost10 <= 0; cost11 <= 0; cost12 <= 0;
        cost20 <= 0; cost21 <= 0; cost22 <= 0;
    end
    else if(cost_start_i && (clear_satd || (pre_cnt08 == 'd0 && pre_cnt16 == 'd0 && pre_cnt32 == 'd0))) begin
        cost00 <= 0; cost01 <= 0; cost02 <= 0;
        cost10 <= 0; cost11 <= 0; cost12 <= 0;
        cost20 <= 0; cost21 <= 0; cost22 <= 0;
    end
    else if(satd_valid_i) begin
        cost00 <= cost00 + sp_cost00;
        cost01 <= cost01 + sp_cost01;
        cost02 <= cost02 + sp_cost02;
        cost10 <= cost10 + sp_cost10;
        cost11 <= cost11 + sp_cost11;
        cost12 <= cost12 + sp_cost12;
        cost20 <= cost20 + sp_cost20;
        cost21 <= cost21 + sp_cost21;
        cost22 <= cost22 + sp_cost22;
    end
end

// 8. best candidate

// -1 :00, 0:2'b01, +1:2'b10
assign {bcand0_y_1s,bcand0_x_1s,best_cost0_1s} = (cost00 < cost01)? {2'b11,2'b11,cost00}:{2'b11,2'b00,cost01};
assign {bcand1_y_1s,bcand1_x_1s,best_cost1_1s} = (cost02 < cost12)? {2'b11,2'b01,cost02}:{2'b00,2'b01,cost12};
assign {bcand2_y_1s,bcand2_x_1s,best_cost2_1s} = (cost10 < cost11)? {2'b00,2'b11,cost10}:{2'b00,2'b00,cost11};
assign {bcand3_y_1s,bcand3_x_1s,best_cost3_1s} = (cost20 < cost21)? {2'b01,2'b11,cost20}:{2'b01,2'b00,cost21};

assign {bcand0_y_2s,bcand0_x_2s,best_cost0_2s} = (best_cost0_1s < best_cost2_1s)? 
                                                 {bcand0_y_1s,bcand0_x_1s,best_cost0_1s}:{bcand2_y_1s,bcand2_x_1s,best_cost2_1s};
assign {bcand1_y_2s,bcand1_x_2s,best_cost1_2s} = (best_cost1_1s < best_cost3_1s)? 
                                                 {bcand1_y_1s,bcand1_x_1s,best_cost1_1s}:{bcand3_y_1s,bcand3_x_1s,best_cost3_1s};

assign {bcand0_y_3s,bcand0_x_3s,best_cost0_3s} = (best_cost1_2s < best_cost0_2s)? 
                          {bcand1_y_2s,bcand1_x_2s,best_cost1_2s}:{bcand0_y_2s,bcand0_x_2s,best_cost0_2s};

// assign {bcand_y_4s,bcand_x_4s,best_cost_o} = (cost22 < best_cost0_3s)? {2'b01,2'b01,cost22}:{bcand0_y_3s,bcand0_x_3s,best_cost0_3s};
assign bcand_y_4s = (cost22 < best_cost0_3s)?2'b01:bcand0_y_3s ;
assign bcand_x_4s = (cost22 < best_cost0_3s)?2'b01:bcand0_x_3s ;
assign best_cost_o = (cost22 < best_cost0_3s)?cost22:best_cost0_3s ;

assign bcand_mv_x = (half_ip_flag_i) ? {bcand_x_4s,1'b0} : {bcand_x_4s[1],bcand_x_4s};
assign bcand_mv_y = (half_ip_flag_i) ? {bcand_y_4s,1'b0} : {bcand_y_4s[1],bcand_y_4s};



always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        satd_valid <= 1'b0;
    end
    else begin
        satd_valid <= satd_valid_i;
    end
end

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        best_candidates <= 'd0;
        best_mv_x       <= 'd0;
        best_mv_y       <= 'd0;
    end
    else if (satd_valid & clear_satd) begin
        best_candidates <= bcand_y_4s * 3 + bcand_x_4s + 4;
        best_mv_x       <= (mv_x_i + bcand_mv_x);
        best_mv_y       <= (mv_y_i + bcand_mv_y);       
    end
end


// ********************************************
//
//   MV Writer 
//
// ********************************************

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
        wcnt32  <= 'd0;
    end
    else if (satd_valid & clear_satd) begin
        wcnt32  <= (mvWriteCnt < 16) ? cnt32 :( post_mode64 == `PART_NX2N ? (cnt32 - 'd2) : ((post_mode64 == `PART_2NXN) ? (cnt32 - 'd1) : 'd0) );
    end
    else if (fmv_wren_o && mvWriteCnt >= 16 && wcnt16 == 'd3 && wcnt08 == 'd3) begin
        wcnt32 <= ( post_mode64 == `PART_NX2N) ? (wcnt32 + 'd2) : (wcnt32 + 'd1);
    end
    else begin
        wcnt32 <= wcnt32;
    end
end


always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
        wcnt16  <= 'd0;
    end
    else if (satd_valid & clear_satd) begin
        wcnt16  <= (mvWriteCnt < 4) ? cnt16 :( post_mode32 == `PART_NX2N ? (cnt16 - 'd2) : ((post_mode32 == `PART_2NXN) ? (cnt16 - 'd1) : 'd0) );
    end
    else if (fmv_wren_o && mvWriteCnt >= 4 && wcnt08 == 'd3) begin
        wcnt16 <= ( post_mode32 == `PART_NX2N) ? (wcnt16 + 'd2) : (wcnt16 + 'd1);
    end
    else begin
        wcnt16 <= wcnt16;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
        wcnt08  <= 'd0;
    end
    else if (satd_valid & clear_satd) begin
        wcnt08  <= (mvWriteCnt==0) ? cnt08 :( post_mode16 == `PART_NX2N ? (cnt08 - 'd2) : ((post_mode16 == `PART_2NXN) ? (cnt08 - 'd1) : 'd0) );
    end
    else if (fmv_wren_o && mvWriteCnt >= 1) begin
        wcnt08 <= ( post_mode16 == `PART_NX2N) ? (wcnt08 + 'd2) : (wcnt08 + 'd1);
    end
    else begin
        wcnt08 <= wcnt08;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
        fmv_wren_o  <= 1'b0;
        mvwriter    <= 'd0;
    end
    else if (satd_valid && clear_satd) begin
        fmv_wren_o  <= 1'b1;
        mvwriter    <= 'd0;
    end
    else if (mvwriter < mvWriteCnt) begin
        fmv_wren_o  <= fmv_wren_o;
        mvwriter    <= mvwriter + 'd1;
    end
    else begin
        fmv_wren_o  <= 1'b0;
        mvwriter    <= mvwriter;
    end
end

always @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
        cost_done_o <= 1'b0;
    end
    else if (wcnt08 == 'd3 && wcnt16 == 'd3 && wcnt32 == 'd3 && fmv_wren_o == 1'b1) begin
        cost_done_o <= 1'b1;
    end
    else begin
        cost_done_o <= 1'b0;
    end
end

//output
//
assign fmv_addr_x = {wcnt32[0],wcnt16[0],wcnt08[0]};
assign fmv_addr_y = {wcnt32[1],wcnt16[1],wcnt08[1]};

assign fmv_best_o = {best_mv_x, best_mv_y}; 
assign fmv_addr_o = {fmv_addr_y,fmv_addr_x}; 
assign best_sp_o  = best_candidates;

endmodule


module bits_num(
       codenum_i,
       bitsnum_o
);
parameter MV_CODE_BITS = 5;

input  [`FMV_WIDTH     :0] codenum_i;
output [MV_CODE_BITS-1 :0] bitsnum_o;

reg    [MV_CODE_BITS-1 :0] bitsnum_o;

always @(*)
begin
        if(codenum_i=='h1)
                bitsnum_o       = 1     ;
        else    if(codenum_i<='h3)
                bitsnum_o       = 3     ;
        else    if(codenum_i<='h7)
                bitsnum_o       = 5     ;
        else    if(codenum_i<='hf)
                bitsnum_o       = 7     ;
        else    if(codenum_i<='h1f)
                bitsnum_o       = 9     ;
        else    if(codenum_i<='h3f)
                bitsnum_o       = 11    ;
        else    if(codenum_i<='h7f)
                bitsnum_o       = 13    ;
        else    if(codenum_i<='hff)
                bitsnum_o       = 15    ;
        else    if(codenum_i<='h1ff)
                bitsnum_o       = 17    ;
        else    if(codenum_i<='h3ff)
                bitsnum_o       = 19    ;
        else
                bitsnum_o       = 21    ;
end


/*
always @(codenum_i)
  casex(codenum_i)
    'b000_0000_0001: bitsnum_o = 1;
    'b000_0000_001x: bitsnum_o = 3;
    'b000_0000_01xx: bitsnum_o = 5;
    'b000_0000_1xxx: bitsnum_o = 7;
    'b000_0001_xxxx: bitsnum_o = 9;
    'b000_001x_xxxx: bitsnum_o = 11;
    'b000_01xx_xxxx: bitsnum_o = 13;
    'b000_1xxx_xxxx: bitsnum_o = 15;
    'b001_xxxx_xxxx: bitsnum_o = 17;
    'b01x_xxxx_xxxx: bitsnum_o = 19;
    'b1xx_xxxx_xxxx: bitsnum_o = 21;
    default:         bitsnum_o = 21;
  endcase
*/
endmodule
