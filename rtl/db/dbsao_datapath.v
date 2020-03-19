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
// Filename       : dbsao_datapath.v
// Author         : TANG
// Created        : 2018-01-24 
// Description    :         
//------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module dbsao_datapath(
        clk                     ,
        rst_n                   ,
        state_i                 ,
        cnt_i                   ,
        sys_ctu_y_i             ,
        sys_ctu_x_i             ,
        IinP_flag_i             , // {top, left, cur}
        IinP_flag_o             ,
        // read from external memory 
        rec_4x4_x_o             , // top-left pos x in sw by 4x4 block
        rec_4x4_y_o             , // top-left pos y in sw by 4x4 block
        rec_4x4_idx_o           , // line number in 4x4 block
        rec_wen_o               , // write enable
        rec_ren_o               , // read enable
        rec_sel_o               , // Y/U/V selection
        rec_siz_o               , // block size selection 32x1, 16x2, 8x4
        rec_pxl_i               , // input block data
        rec_pxl_o               , // output to ram after dbf

        ori_4x4_x_o             , // original pixels interface 
        ori_4x4_y_o             ,
        ori_4x4_idx_o           ,
        ori_ren_o               ,
        ori_sel_o               ,
        ori_siz_o               ,
        ori_pxl_i               ,

        top_ren_o               , // top pixels IF
        top_r4x4_o              ,
        top_ridx_o              ,
        top_rdata_i             , 
        // output to external memory  
        fetch_wen_o             , // fetch IF
        fetch_w4x4_x_o          ,
        fetch_w4x4_y_o          ,
        fetch_wprevious_o       ,
        fetch_wdone_o           ,
        fetch_wsel_o            ,
        fetch_wdata_o           ,  
        // output to dbf/sao 
        dbf_p_o                 , // for dbf
        dbf_q_o                 , // 
        dbf_p_i                 ,
        dbf_q_i                 ,  
        is_ver_o                ,
        // for sao
        sao_rec_0_o             , // for sao 6x1
        sao_rec_1_o             ,
        sao_rec_2_o             ,
        sao_rec_3_o             ,
        sao_rec_4_o             ,
        sao_rec_5_o             ,
        sao_ori_0_o             ,
        sao_ori_1_o             ,
        sao_ori_2_o             ,
        sao_ori_3_o             ,
        sao_4x4_x_o             ,
        sao_4x4_y_o             ,
        sao_sel_o               ,
        // bo_pre
        pre_bo_rec_o            ,
        // offset rec 
        sao_block_i              // after offset 
);

//============================================================
//
//          parameter declaration 
//
//============================================================
parameter IDLE = 3'b000, LOAD = 3'b001, DBY = 3'b011, DBU = 3'b010, DBV = 3'b110, SAO = 3'b100, OUT = 3'b101;
parameter DATA_WIDTH = 256;

//============================================================
// 
//          I/O declaration
//
//============================================================
input                          clk                    ;
input                          rst_n                  ;
input  [2:0]                   state_i                ;
input  [8:0]                   cnt_i                  ;
input  [`PIC_Y_WIDTH-1:0]      sys_ctu_y_i            ;// Current LCU in y
input  [`PIC_X_WIDTH-1:0]      sys_ctu_x_i            ;// Current LCU in y
input  [2:0]                   IinP_flag_i            ;
output                         IinP_flag_o            ; // IinP flag 

output [3:0]                   rec_4x4_x_o            ;
output [3:0]                   rec_4x4_y_o            ;
output [4:0]                   rec_4x4_idx_o          ;
output                         rec_wen_o              ;
output                         rec_ren_o              ;
output [1:0]                   rec_sel_o              ;
output [1:0]                   rec_siz_o              ;
input  [DATA_WIDTH-1:0]        rec_pxl_i              ;
output [DATA_WIDTH-1:0]        rec_pxl_o              ;

output [3:0]                   ori_4x4_x_o            ;
output [3:0]                   ori_4x4_y_o            ;
output [4:0]                   ori_4x4_idx_o          ;
output                         ori_ren_o              ;
output [1:0]                   ori_sel_o              ;
output [1:0]                   ori_siz_o              ;
input  [DATA_WIDTH-1:0]        ori_pxl_i              ;

output                         top_ren_o              ;
output [4:0]                   top_r4x4_o             ;
output [1:0]                   top_ridx_o             ;
input  [4*`PIXEL_WIDTH-1:0]    top_rdata_i            ;

output                         fetch_wen_o            ;
output [4:0]                   fetch_w4x4_x_o         ;
output [4:0]                   fetch_w4x4_y_o         ;
output                         fetch_wprevious_o      ;
output                         fetch_wdone_o          ;
output [1:0]                   fetch_wsel_o           ;
output [127:0]                 fetch_wdata_o          ;

output [127:0]                 dbf_p_o                ;
output [127:0]                 dbf_q_o                ;
input  [127:0]                 dbf_p_i                ; // filtered p and q
input  [127:0]                 dbf_q_i                ;
output                         is_ver_o               ;

output [6*8-1:0]               sao_rec_0_o            ;
output [6*8-1:0]               sao_rec_1_o            ;
output [6*8-1:0]               sao_rec_2_o            ;
output [6*8-1:0]               sao_rec_3_o            ;
output [6*8-1:0]               sao_rec_4_o            ;
output [6*8-1:0]               sao_rec_5_o            ;
output [4*8-1:0]               sao_ori_0_o            ;
output [4*8-1:0]               sao_ori_1_o            ;
output [4*8-1:0]               sao_ori_2_o            ;
output [4*8-1:0]               sao_ori_3_o            ;

output [3:0]                   sao_4x4_y_o            ;
output [3:0]                   sao_4x4_x_o            ;
output [1:0]                   sao_sel_o              ;

output [255:0]                 pre_bo_rec_o           ;
input  [16*8-1:0]              sao_block_i            ;


//============================================================
// 
//          read top pixel for dbf
//
//============================================================

reg      [8:0]                  cnt_r                 ;
always@(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin 
        cnt_r      <=  9'd0     ;
    end 
    else begin  
        cnt_r      <= cnt_i     ;
    end
end 

wire                            top_ren_o             ; // db read enable 
wire     [4:0]                  top_r4x4_o            ; // db_read 4x4 block index 
wire     [1:0]                  top_ridx_o            ;
wire     [1:0]                  top_ridx_r            ;

reg [127:0] top_y_r [15:0];
reg [127:0] top_u_r [7:0];
reg [127:0] top_v_r [7:0];

assign  top_ren_o  = (state_i == LOAD) && (sys_ctu_y_i != 0)  ;//mb_y && load state 
assign  top_r4x4_o = cnt_i[6:2];
assign  top_ridx_o = cnt_i[1:0];
assign  top_ridx_r = cnt_r[1:0];


always @ (posedge clk or negedge rst_n) begin 
    if ( !rst_n ) begin 
        top_y_r[ 0] <= 'd0; top_u_r[ 0] <= 'd0;
        top_y_r[ 1] <= 'd0; top_u_r[ 1] <= 'd0;
        top_y_r[ 2] <= 'd0; top_u_r[ 2] <= 'd0;
        top_y_r[ 3] <= 'd0; top_u_r[ 3] <= 'd0;
        top_y_r[ 4] <= 'd0; top_u_r[ 4] <= 'd0;
        top_y_r[ 5] <= 'd0; top_u_r[ 5] <= 'd0;
        top_y_r[ 6] <= 'd0; top_u_r[ 6] <= 'd0;
        top_y_r[ 7] <= 'd0; top_u_r[ 7] <= 'd0;
        top_y_r[ 8] <= 'd0; top_v_r[ 0] <= 'd0;
        top_y_r[ 9] <= 'd0; top_v_r[ 1] <= 'd0;
        top_y_r[10] <= 'd0; top_v_r[ 2] <= 'd0;
        top_y_r[11] <= 'd0; top_v_r[ 3] <= 'd0;
        top_y_r[12] <= 'd0; top_v_r[ 4] <= 'd0;
        top_y_r[13] <= 'd0; top_v_r[ 5] <= 'd0;
        top_y_r[14] <= 'd0; top_v_r[ 6] <= 'd0;
        top_y_r[15] <= 'd0; top_v_r[ 7] <= 'd0;    
    end 
    else if ( state_i == LOAD ) begin 
        if ( cnt_r[6:2] < 9'd16 )
            case(top_ridx_r)
                0 : top_y_r[cnt_r[5:2]][16*`PIXEL_WIDTH-1:12*`PIXEL_WIDTH] <= top_rdata_i;
                1 : top_y_r[cnt_r[5:2]][12*`PIXEL_WIDTH-1:08*`PIXEL_WIDTH] <= top_rdata_i;
                2 : top_y_r[cnt_r[5:2]][08*`PIXEL_WIDTH-1:04*`PIXEL_WIDTH] <= top_rdata_i;
                3 : top_y_r[cnt_r[5:2]][04*`PIXEL_WIDTH-1:00*`PIXEL_WIDTH] <= top_rdata_i;
                default : ;
            endcase 
        else if ( cnt_r[6:2] < 9'd24 )
            case(top_ridx_r)
                0 : top_u_r[cnt_r[4:2]][16*`PIXEL_WIDTH-1:12*`PIXEL_WIDTH] <= top_rdata_i;
                1 : top_u_r[cnt_r[4:2]][12*`PIXEL_WIDTH-1:08*`PIXEL_WIDTH] <= top_rdata_i;
                2 : top_u_r[cnt_r[4:2]][08*`PIXEL_WIDTH-1:04*`PIXEL_WIDTH] <= top_rdata_i;
                3 : top_u_r[cnt_r[4:2]][04*`PIXEL_WIDTH-1:00*`PIXEL_WIDTH] <= top_rdata_i;
                default : ;
            endcase 
        else if ( cnt_r[6:2] < 9'd32 )
            case(top_ridx_r)
                0 : top_v_r[cnt_r[4:2]][16*`PIXEL_WIDTH-1:12*`PIXEL_WIDTH] <= top_rdata_i;
                1 : top_v_r[cnt_r[4:2]][12*`PIXEL_WIDTH-1:08*`PIXEL_WIDTH] <= top_rdata_i;
                2 : top_v_r[cnt_r[4:2]][08*`PIXEL_WIDTH-1:04*`PIXEL_WIDTH] <= top_rdata_i;
                3 : top_v_r[cnt_r[4:2]][04*`PIXEL_WIDTH-1:00*`PIXEL_WIDTH] <= top_rdata_i;
                default : ;
            endcase 
    end 
end 

// top left block
reg [127:0] y_tl_r, u_tl_r, v_tl_r;
always @ (posedge clk or negedge rst_n) begin 
    if ( !rst_n ) begin 
        y_tl_r <= 'd0;
        u_tl_r <= 'd0;
        v_tl_r <= 'd0;
    end 
    else if ( state_i == OUT ) begin
        y_tl_r <= top_y_r[15];
        u_tl_r <= top_u_r[7];
        v_tl_r <= top_v_r[7];
    end 
end 


//============================================================
//
//          db rec pixels input and output
//
//============================================================
  
wire    [1:0]              db_rec_siz_w;
wire    [1:0]              db_rec_sel_w;
reg                        db_rec_wen_w;
reg                        db_rec_ren_w;
reg     [3:0]              db_rec_4x4_x_r;
reg     [3:0]              db_rec_4x4_y_r;
wire    [4:0]              db_rec_4x4_idx_r;
wire    [7:0]              cnt_out;

assign cnt_out  = cnt_i > 9'd7 ? cnt_i-8'd8 : 8'd0; // rec output count
assign db_rec_sel_w = state_i == DBY ? 2'b00 : (state_i == DBU ? 2'b10 : (state_i == DBV ? 2'b11 : 2'b00));
assign db_rec_siz_w = `SIZE_08;

always @* begin 
    db_rec_wen_w = 0;
    case(state_i)
        DBY : begin 
            if ( cnt_out<32 )   db_rec_wen_w = cnt_out[1:0] == 2'b11 ;
            else                db_rec_wen_w = cnt_out[1] == 1;
        end 
        DBU, DBV : begin 
            if ( cnt_out<16 )   db_rec_wen_w = cnt_out[1:0] == 2'b11 ;
            else                db_rec_wen_w = cnt_out[1] == 1;
        end 
        default : db_rec_wen_w = 0;
        endcase 
end 

always @* begin 
    db_rec_ren_w = 0;
    case(state_i)
        DBY :       db_rec_ren_w = (!cnt_i[1]) && (cnt_i<254) ;
        DBU, DBV :  db_rec_ren_w = (!cnt_i[1]) && (cnt_i<62) ;
        default : db_rec_ren_w = 0;
        endcase  
end 

always @ (*) begin 
    if ( db_rec_ren_w == 1'b1 ) begin // read 
    case ( state_i )
        DBY : begin 
            db_rec_4x4_x_r = { cnt_i[4:2], 1'b0 };
            db_rec_4x4_y_r = cnt_i[7:5] ? ( (cnt_i[7:5]<<1) - !cnt_i[0] ) : 5'd0 ;
        end 
        DBU, DBV : begin 
            db_rec_4x4_x_r = { cnt_i[3:2], 1'b0 };
            db_rec_4x4_y_r = cnt_i[5:4] ? ( (cnt_i[5:4]<<1) - !cnt_i[0] ) : 5'd0 ;
        end
        default : begin 
            db_rec_4x4_x_r = 0;
            db_rec_4x4_y_r = 0;
        end 
    endcase 
    end 
    else if ( db_rec_wen_w == 1'b1 ) begin // write 
    case ( state_i )
        DBY : begin 
            db_rec_4x4_x_r = { cnt_out[4:2], 1'b0 };
            db_rec_4x4_y_r = cnt_out[7:5] ? ( (cnt_out[7:5]<<1) - !cnt_out[0] ) : 5'd0 ;
        end 
        DBU, DBV : begin 
            db_rec_4x4_x_r = { cnt_out[3:2], 1'b0 };
            db_rec_4x4_y_r = cnt_out[5:4] ? ( (cnt_out[5:4]<<1) - !cnt_out[0] ) : 5'd0 ;
        end 
        default : begin 
            db_rec_4x4_x_r = 0;
            db_rec_4x4_y_r = 0;
        end 
    endcase 
    end 
    else begin 
            db_rec_4x4_x_r = 0;
            db_rec_4x4_y_r = 0;
        end 
end 

assign db_rec_4x4_idx_r = db_rec_4x4_y_r[0] ? 4 : 0 ;

//****************************************************************
//
//          output to dbf
//
//****************************************************************

wire    [255:0]        rec_pxl_i_w; // rearrange rec_pxl_i and rec_pxl_o
wire    [255:0]        ori_pxl_i_w; // rearrange rec_pxl_i and rec_pxl_o
wire    [255:0]        rec_pxl_o; // rearrange rec_pxl_i and rec_pxl_o
reg     [255:0]        rec_pxl_o_r;

assign rec_pxl_i_w = {rec_pxl_i[255:224], rec_pxl_i[191:160], rec_pxl_i[127: 96], rec_pxl_i[ 63: 32], 
                      rec_pxl_i[223:192], rec_pxl_i[159:128], rec_pxl_i[ 95: 64], rec_pxl_i[ 31:  0]};
assign ori_pxl_i_w = {ori_pxl_i[255:224], ori_pxl_i[191:160], ori_pxl_i[127: 96], ori_pxl_i[ 63: 32], 
                      ori_pxl_i[223:192], ori_pxl_i[159:128], ori_pxl_i[ 95: 64], ori_pxl_i[ 31:  0]};
assign rec_pxl_o   = (db_rec_wen_w == 1'b1) ? 
                     {rec_pxl_o_r[255:224], rec_pxl_o_r[127: 96], rec_pxl_o_r[223:192], rec_pxl_o_r[ 95: 64], 
                      rec_pxl_o_r[191:160], rec_pxl_o_r[ 63: 32], rec_pxl_o_r[159:128], rec_pxl_o_r[ 31:  0]}
                      : 0 ;

reg [8:0] cnt_d2;
always @ (posedge clk or negedge rst_n) begin 
    if ( !rst_n ) 
        cnt_d2 <= 'd0;
    else 
        cnt_d2 <= cnt_r;
end 


reg     [127:0]         left_y_r    [15:0];
reg     [127:0]         left_u_r    [7:0];
reg     [127:0]         left_v_r    [7:0];

wire    [127:0]         tl_block_w;
wire    [127:0]         left_w      [15:0];
wire    [127:0]         top_w       [15:0];

assign tl_block_w = state_i == DBY ? y_tl_r : (state_i == DBU ? u_tl_r : (state_i == DBV ? v_tl_r : 0));
assign left_w[ 0] = state_i == DBY ? left_y_r[ 0] : (state_i == DBU ? left_u_r[ 0] : (state_i == DBV ? left_v_r[ 0] : 0));
assign left_w[ 1] = state_i == DBY ? left_y_r[ 1] : (state_i == DBU ? left_u_r[ 1] : (state_i == DBV ? left_v_r[ 1] : 0));
assign left_w[ 2] = state_i == DBY ? left_y_r[ 2] : (state_i == DBU ? left_u_r[ 2] : (state_i == DBV ? left_v_r[ 2] : 0));
assign left_w[ 3] = state_i == DBY ? left_y_r[ 3] : (state_i == DBU ? left_u_r[ 3] : (state_i == DBV ? left_v_r[ 3] : 0));
assign left_w[ 4] = state_i == DBY ? left_y_r[ 4] : (state_i == DBU ? left_u_r[ 4] : (state_i == DBV ? left_v_r[ 4] : 0));
assign left_w[ 5] = state_i == DBY ? left_y_r[ 5] : (state_i == DBU ? left_u_r[ 5] : (state_i == DBV ? left_v_r[ 5] : 0));
assign left_w[ 6] = state_i == DBY ? left_y_r[ 6] : (state_i == DBU ? left_u_r[ 6] : (state_i == DBV ? left_v_r[ 6] : 0));
assign left_w[ 7] = state_i == DBY ? left_y_r[ 7] : (state_i == DBU ? left_u_r[ 7] : (state_i == DBV ? left_v_r[ 7] : 0));
assign left_w[ 8] = left_y_r[ 8];
assign left_w[ 9] = left_y_r[ 9];
assign left_w[10] = left_y_r[10];
assign left_w[11] = left_y_r[11];
assign left_w[12] = left_y_r[12];
assign left_w[13] = left_y_r[13];
assign left_w[14] = left_y_r[14];
assign left_w[15] = left_y_r[15];

assign top_w[ 0] = state_i == DBY ? top_y_r[ 0] : (state_i == DBU ? top_u_r[ 0] : (state_i == DBV ? top_v_r[ 0] : 0));
assign top_w[ 1] = state_i == DBY ? top_y_r[ 1] : (state_i == DBU ? top_u_r[ 1] : (state_i == DBV ? top_v_r[ 1] : 0));
assign top_w[ 2] = state_i == DBY ? top_y_r[ 2] : (state_i == DBU ? top_u_r[ 2] : (state_i == DBV ? top_v_r[ 2] : 0));
assign top_w[ 3] = state_i == DBY ? top_y_r[ 3] : (state_i == DBU ? top_u_r[ 3] : (state_i == DBV ? top_v_r[ 3] : 0));
assign top_w[ 4] = state_i == DBY ? top_y_r[ 4] : (state_i == DBU ? top_u_r[ 4] : (state_i == DBV ? top_v_r[ 4] : 0));
assign top_w[ 5] = state_i == DBY ? top_y_r[ 5] : (state_i == DBU ? top_u_r[ 5] : (state_i == DBV ? top_v_r[ 5] : 0));
assign top_w[ 6] = state_i == DBY ? top_y_r[ 6] : (state_i == DBU ? top_u_r[ 6] : (state_i == DBV ? top_v_r[ 6] : 0));
assign top_w[ 7] = state_i == DBY ? top_y_r[ 7] : (state_i == DBU ? top_u_r[ 7] : (state_i == DBV ? top_v_r[ 7] : 0));
assign top_w[ 8] = top_y_r[ 8];
assign top_w[ 9] = top_y_r[ 9];
assign top_w[10] = top_y_r[10];
assign top_w[11] = top_y_r[11];
assign top_w[12] = top_y_r[12];
assign top_w[13] = top_y_r[13];
assign top_w[14] = top_y_r[14];
assign top_w[15] = top_y_r[15];

wire db_top_flag        = (state_i == DBY && cnt_r[7:5] == 'd0) || ((state_i == DBU || state_i == DBV) && cnt_r[5:4] == 'd0);
wire db_left_flag       = (state_i == DBY && cnt_i[4:2] == 'd0) || ((state_i == DBU || state_i == DBV) && cnt_i[3:2] == 'd0);

wire [3:0] tcnt   = state_i == DBY ? (cnt_r[4:2]<<1) : (cnt_r[3:2]<<1)  ; // top index count
wire [3:0] lcnt   = state_i == DBY ? cnt_i[7:5] : cnt_i[5:4]; // left index count

reg  [127:0]         dbf_p_o             ;
reg  [127:0]         dbf_q_o             ;
reg  [127:0]         blk_l_0             ;
reg  [127:0]         blk_l_1             ;
reg  [127:0]         block [7:0]         ;
reg  [127:0]         blk_r_0             ;
reg  [127:0]         blk_r_1             ;
wire                 is_ver_o            ; // vertical edge flag


assign is_ver_o = !cnt_d2[1] ;

reg IinP_flag_o ;
wire flt_top_flag = (state_i == DBY && cnt_d2[7:5] == 'd0) || ((state_i == DBU || state_i == DBV) && cnt_d2[5:4] == 'd0) ;
wire flt_left_flag = (state_i == DBY && cnt_d2[4:2] == 'd0) || ((state_i == DBU || state_i == DBV) && cnt_d2[3:2] == 'd0) ;
always @* begin 
    IinP_flag_o = 0 ;
    if ( flt_top_flag == 1 )
        case (cnt_d2[1:0])
            0 : IinP_flag_o = IinP_flag_i[2] ; // top flag
            1 : IinP_flag_o = IinP_flag_i[0] ; // cur flag
          2,3 : IinP_flag_o = IinP_flag_i[0] || IinP_flag_i[2] ; // cur flag || top flag
          default : ;
        endcase 
    else if ( flt_left_flag == 1 )
        case (cnt_d2[1:0] )
            0, 1 : IinP_flag_o = IinP_flag_i[0] || IinP_flag_i[1]  ; // cur flag || left flag
            2    : IinP_flag_o = IinP_flag_i[1] ; // left flag
            3    : IinP_flag_o = IinP_flag_i[0] ; // cur flag
            default:;
        endcase 
    else 
        IinP_flag_o = IinP_flag_i[0] ; // cur flag
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        blk_l_0    <= 0;
        blk_l_1    <= 0;
    end else if ( cnt_i == 0 ) begin 
        blk_l_0    <= tl_block_w;
        blk_l_1    <= left_w[0]; 
    end else if ( db_left_flag && cnt_i[1:0] == 0 ) begin 
        blk_l_0    <= left_w[(lcnt<<1)-1'b1]; // notice
        blk_l_1    <= left_w[lcnt<<1];       
    end else if ( db_top_flag ) begin 
        blk_l_0    <= cnt_r[1:0] == 2'b00 ? top_w[(tcnt+1'b1)] : blk_l_0 ;
        blk_l_1    <= cnt_r[1:0] == 2'b01 ? rec_pxl_i_w[127:0] : blk_l_1 ;
    end else begin 
        blk_l_0    <= cnt_r[1:0] == 2'b00 ? rec_pxl_i_w[127:0] : blk_l_0 ;
        blk_l_1    <= cnt_r[1:0] == 2'b01 ? rec_pxl_i_w[127:0] : blk_l_1 ;
    end 
end 

always @ (*) begin 
    blk_r_0 = 0;
    blk_r_1 = 0;
    if ( db_top_flag ) begin 
        blk_r_0 = top_w[tcnt];
        blk_r_1 = rec_pxl_i_w[255:128];
    end else begin 
        blk_r_0 = rec_pxl_i_w[255:128];
        blk_r_1 = rec_pxl_i_w[255:128];
    end 
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        dbf_p_o <= 0;
        dbf_q_o <= 0;
    end else begin 
        case (cnt_r[2:0])
            0, 4 : begin 
                dbf_p_o <= blk_l_0   ; dbf_q_o <= blk_r_0 ; 
            end 
            1, 5 : begin 
                dbf_p_o <= blk_l_1   ; dbf_q_o <= blk_r_1 ; 
            end 
            2 : begin 
                dbf_p_o <= block[ 0] ; dbf_q_o <= dbf_p_i ;
            end 
            3 : begin 
                dbf_p_o <= block[ 1] ; dbf_q_o <= block[ 3] ;
            end 
            6 : begin 
                dbf_p_o <= block[ 4] ; dbf_q_o <= dbf_p_i ;
            end 
            7 : begin 
                dbf_p_o <= block[ 5] ; dbf_q_o <= block[ 7] ;
            end 
            
        default : ;
        endcase 
    end 
end 

/*
0 1 4 5
2 3 6 7 
*/
wire db_valid_w = (state_i == DBY && cnt_d2 < 258) || (state_i == DBU && cnt_i<66) || (state_i == DBV && cnt_i<66) ;

always @ ( posedge clk or negedge rst_n ) begin 
    if (!rst_n) begin 
        block[0] <= 0 ;
        block[1] <= 0 ;
        block[2] <= 0 ;
        block[3] <= 0 ;
        block[4] <= 0 ;
        block[5] <= 0 ;
        block[6] <= 0 ;
        block[7] <= 0 ;
    end else if ( cnt_i == 0 ) begin 
        block[0] <= 0 ;
        block[1] <= 0 ;
        block[2] <= 0 ;
        block[3] <= 0 ;
        block[4] <= 0 ;
        block[5] <= 0 ;
        block[6] <= 0 ;
        block[7] <= 0 ; 
    end else if ( db_valid_w ) begin 
        case ( cnt_d2[2:0] )
            0 : begin block[ 0] <= dbf_p_i ; block[ 1] <= dbf_q_i ; end 
            1 : begin block[ 2] <= dbf_p_i ; block[ 3] <= dbf_q_i ; end 
            2 : begin block[ 0] <= dbf_p_i ; block[ 2] <= dbf_q_i ; end 
            3 : begin block[ 1] <= dbf_p_i ; block[ 3] <= dbf_q_i ; end 
            4 : begin block[ 4] <= dbf_p_i ; block[ 5] <= dbf_q_i ; end 
            5 : begin block[ 6] <= dbf_p_i ; block[ 7] <= dbf_q_i ; end 
            6 : begin block[ 4] <= dbf_p_i ; block[ 6] <= dbf_q_i ; end 
            7 : begin block[ 5] <= dbf_p_i ; block[ 7] <= dbf_q_i ; end 
            default : ;
        endcase 
    end 
end 

reg     [128 -1 :0]   right_block_0;
reg     [128 -1 :0]   right_block_1;
always @ ( posedge clk or negedge rst_n ) begin 
    if (!rst_n) 
        right_block_0       <= 128'd0 ;
    else if (cnt_r==0)  
        case (state_i)
            DBY : right_block_0       <= top_y_r[15] ; 
            DBU : right_block_0       <= top_u_r[7] ; 
            DBV : right_block_0       <= top_v_r[7] ; 
            default : ;
        endcase 
    else if ((state_i == DBY && cnt_r[4:2] == 7)||(state_i == DBU&& cnt_r[3:2] == 3)||(state_i == DBV&& cnt_r[3:2] == 3))
        right_block_0       <= cnt_r[1:0] == 2'b0 ? rec_pxl_i_w[127:0] : right_block_0 ;
    else 
        right_block_0       <= right_block_0 ;
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) 
        right_block_1       <= 128'd0 ;
    else if ((state_i == DBY && cnt_r[4:2] == 7)||(state_i == DBU&& cnt_r[3:2] == 3)||(state_i == DBV&& cnt_r[3:2] == 3))
        right_block_1       <= cnt_r[1:0] == 2'b01 ? rec_pxl_i_w[127:0] : right_block_1 ;
    else 
        right_block_1       <= right_block_1 ;
end 


//****************************************************************
//
//          output to db RAM
//
//****************************************************************
/*
0 1 4 5
2 3 6 7 
*/
wire    [8:0]              cnt_d7;
assign cnt_d7  = cnt_i > 9'd6 ? cnt_i-9'd7 : 9'd0; // rec output count
wire out_right_flag = (state_i == DBY && cnt_d7[4:2] == 'd7) || ((state_i == DBU || state_i == DBV) && cnt_d7[3:2] == 'd3);

always @ (posedge clk or negedge rst_n) begin
    if ( !rst_n )
        rec_pxl_o_r     <= 0;
    else if ( out_right_flag )  // right col
        if ( cnt_d7[0] == 0 )
            rec_pxl_o_r <= {block[5], right_block_0};
        else             
            rec_pxl_o_r <= {block[7], right_block_1};
    else begin 
        case ({cnt_d7[2], cnt_d7[0]})
            2'b00 : rec_pxl_o_r <= {block[1], block[4]};
            2'b01 : rec_pxl_o_r <= {block[3], block[6]};
            2'b10 : rec_pxl_o_r <= {block[5], block[0]};
            2'b11 : rec_pxl_o_r <= {block[7], block[2]};
        endcase 
    end 
end 


//****************************************************************
//
//          rec for bo_predecision
//
//****************************************************************
reg     [255        :0]       pre_bo_rec_o;

always @ (*) begin 
    pre_bo_rec_o = 'd0;
    if ( (state_i == DBY || state_i == DBU || state_i == DBV) && db_rec_wen_w && (db_rec_4x4_y_r[0]==0) )
        pre_bo_rec_o = rec_pxl_o_r;
end 

//****************************************************************
//
//          rec for sao and output
//
//****************************************************************
reg     [4:0]                   sao_rec_4x4_x_r         ; 
reg     [4:0]                   sao_rec_4x4_y_r         ; 
wire    [3:0]                   sao_rec_4x4_x_o         ;  
wire    [3:0]                   sao_rec_4x4_y_o         ;           
wire                            sao_rec_ren_w           ;   
reg     [1:0]                   sao_rec_sel_r           ; 
wire    [1:0]                   sao_rec_siz_w           ;  
wire    [16*`PIXEL_WIDTH-1:0]   rec_left_block_w        ;
wire    [16*`PIXEL_WIDTH-1:0]   rec_right_block_w       ;
wire    [16*`PIXEL_WIDTH-1:0]   sao_rec_blk_w           ;
reg     [16*`PIXEL_WIDTH-1:0]   sao_rec_block_d1        ;
reg     [16*`PIXEL_WIDTH-1:0]   sao_ori_block_d1        ;

reg     [8 *`PIXEL_WIDTH-1:0]   sao_top_blk_0           ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_top_blk_1           ; 
reg     [4:0]                   sao_rec_4x4_x_d1        ; 
reg     [4:0]                   sao_rec_4x4_y_d1        ; 
reg     [1:0]                   sao_rec_sel_d1          ;

reg     [6*`PIXEL_WIDTH-1:0]    sao_rec_0_o             ;
reg     [6*`PIXEL_WIDTH-1:0]    sao_rec_1_o             ;
reg     [6*`PIXEL_WIDTH-1:0]    sao_rec_2_o             ;
reg     [6*`PIXEL_WIDTH-1:0]    sao_rec_3_o             ;
reg     [6*`PIXEL_WIDTH-1:0]    sao_rec_4_o             ;
reg     [6*`PIXEL_WIDTH-1:0]    sao_rec_5_o             ;

reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_00_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_01_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_02_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_03_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_04_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_05_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_06_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_07_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_08_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_09_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_10_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_11_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_12_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_13_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_14_r       ; 
reg     [8 *`PIXEL_WIDTH-1:0]   sao_rec_line_15_r       ; 

reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_00_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_01_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_02_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_03_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_04_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_05_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_06_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_07_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_08_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_09_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_10_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_11_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_12_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_13_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_14_r        ;
reg     [12*`PIXEL_WIDTH-1:0]   out_rec_blk_15_r        ;

reg     [16*`PIXEL_WIDTH-1:0]   sao_rec_right_most      ;
reg     [16*`PIXEL_WIDTH-1:0]   sao_rec_right_most_d1   ;

// sao_x_r
always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        sao_rec_4x4_x_r <= 0 ;  
    end else if ( state_i == SAO || state_i == OUT )
        if ( (sao_rec_sel_r == `TYPE_Y && sao_rec_4x4_x_r == 16 )
           ||(sao_rec_sel_r == `TYPE_U && sao_rec_4x4_x_r == 8  )
           ||(sao_rec_sel_r == `TYPE_V && sao_rec_4x4_x_r == 8  ) )
            sao_rec_4x4_x_r <= 0;
        else begin 
            sao_rec_4x4_x_r <= sao_rec_4x4_x_r + 1;
        end 
    else begin 
        sao_rec_4x4_x_r <= 0 ;
    end 
end 
// sao_rec_y
always @ ( posedge clk or negedge rst_n ) begin 
    if (!rst_n) 
        sao_rec_4x4_y_r <= 0;
    else if ( (sao_rec_sel_r == `TYPE_Y && sao_rec_4x4_y_r == 16 && sao_rec_4x4_x_r == 16 )
            ||(sao_rec_sel_r == `TYPE_U && sao_rec_4x4_y_r == 8  && sao_rec_4x4_x_r == 8  )
            ||(sao_rec_sel_r == `TYPE_V && sao_rec_4x4_y_r == 8  && sao_rec_4x4_x_r == 8  ) )
        sao_rec_4x4_y_r <= 0;
    else if ( (sao_rec_sel_r == `TYPE_Y && sao_rec_4x4_x_r == 16 )
            ||(sao_rec_sel_r == `TYPE_U && sao_rec_4x4_x_r == 8  )
            ||(sao_rec_sel_r == `TYPE_V && sao_rec_4x4_x_r == 8  ) )
        sao_rec_4x4_y_r <= sao_rec_4x4_y_r + 1 ;
    else ;
end 

assign sao_rec_4x4_x_o = sao_rec_sel_r == `TYPE_Y ? (sao_rec_4x4_x_r == 16 ? 15 : sao_rec_4x4_x_r) 
                                                  : (sao_rec_4x4_x_r == 8  ? 7  : sao_rec_4x4_x_r) ;
assign sao_rec_4x4_y_o = sao_rec_sel_r == `TYPE_Y ? (sao_rec_4x4_y_r == 16 ? 15 : sao_rec_4x4_y_r) 
                                                  : (sao_rec_4x4_y_r == 8  ? 7  : sao_rec_4x4_y_r) ;

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) 
        sao_rec_sel_r <= `TYPE_Y;
    else if ( sao_rec_sel_r == `TYPE_Y && sao_rec_4x4_y_r == 16 && sao_rec_4x4_x_r == 16 )
        sao_rec_sel_r <= `TYPE_U;
    else if ( sao_rec_sel_r == `TYPE_U && sao_rec_4x4_y_r == 8  && sao_rec_4x4_x_r == 8  )
        sao_rec_sel_r <= `TYPE_V; 
    else if ( sao_rec_sel_r == `TYPE_V && sao_rec_4x4_y_r == 8  && sao_rec_4x4_x_r == 8  )
        sao_rec_sel_r <= `TYPE_Y; 
end 

assign sao_rec_siz_w = `SIZE_04 ;
assign sao_rec_ren_w = state_i == SAO || state_i == OUT ;

// spilt input pixel
assign {rec_left_block_w, rec_right_block_w} = rec_pxl_i_w ;
assign sao_rec_blk_w = sao_rec_4x4_x_d1[0] ? rec_right_block_w : rec_left_block_w ;
// delay x,y
always @(posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        sao_rec_4x4_x_d1 <= 0;
        sao_rec_4x4_y_d1 <= 0;
        sao_rec_sel_d1   <= 0;
    end else begin 
        sao_rec_4x4_x_d1 <= sao_rec_4x4_x_r ;
        sao_rec_4x4_y_d1 <= sao_rec_4x4_y_r ;
        sao_rec_sel_d1   <= sao_rec_sel_r ;
    end 
end 

always @(posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) 
        sao_rec_block_d1 <= 0;
    else 
        sao_rec_block_d1 <= sao_rec_blk_w ;
end 

// sao position
wire [3:0]  sao_4x4_x_o ;
wire [3:0]  sao_4x4_y_o ;
reg  [1:0]  sao_sel_o   ;
assign sao_4x4_x_o = (sao_rec_4x4_x_d1 == 0) ? 0 : sao_rec_4x4_x_d1 - 1;
assign sao_4x4_y_o = sao_rec_4x4_y_d1 ;

always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n )
        sao_sel_o <= `TYPE_Y ;
    else 
        sao_sel_o <= sao_rec_sel_r ;
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if (!rst_n) 
        sao_rec_right_most <= 0;
    else if ( ( sao_rec_sel_d1 == `TYPE_Y && sao_rec_4x4_x_d1 == 15 ) 
            ||( sao_rec_sel_d1 == `TYPE_U && sao_rec_4x4_x_d1 == 7  )
            ||( sao_rec_sel_d1 == `TYPE_V && sao_rec_4x4_x_d1 == 7  ))
        sao_rec_right_most <= sao_rec_blk_w ;
end 

always @ (posedge clk or negedge rst_n) begin 
    if ( !rst_n )
        sao_rec_right_most_d1 <= 0;
    else 
        sao_rec_right_most_d1 <= sao_rec_right_most ;
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        sao_rec_line_00_r <= 0; sao_rec_line_08_r <= 0; 
        sao_rec_line_01_r <= 0; sao_rec_line_09_r <= 0; 
        sao_rec_line_02_r <= 0; sao_rec_line_10_r <= 0; 
        sao_rec_line_03_r <= 0; sao_rec_line_11_r <= 0; 
        sao_rec_line_04_r <= 0; sao_rec_line_12_r <= 0; 
        sao_rec_line_05_r <= 0; sao_rec_line_13_r <= 0; 
        sao_rec_line_06_r <= 0; sao_rec_line_14_r <= 0; 
        sao_rec_line_07_r <= 0; sao_rec_line_15_r <= 0; 
    end 
    else begin 
        case ( sao_rec_4x4_x_d1 )
            00 : sao_rec_line_00_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            01 : sao_rec_line_01_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            02 : sao_rec_line_02_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            03 : sao_rec_line_03_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            04 : sao_rec_line_04_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            05 : sao_rec_line_05_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            06 : sao_rec_line_06_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            07 : sao_rec_line_07_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            08 : sao_rec_line_08_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            09 : sao_rec_line_09_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            10 : sao_rec_line_10_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            11 : sao_rec_line_11_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            12 : sao_rec_line_12_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            13 : sao_rec_line_13_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            14 : sao_rec_line_14_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            15 : sao_rec_line_15_r <= sao_rec_blk_w[8 *`PIXEL_WIDTH-1:0];
            default : ;
        endcase 
    end 
end 

always @( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        sao_top_blk_0 <= 0; 
        sao_top_blk_1 <= 0;
    end else 
    case ( sao_rec_4x4_x_d1 )
        00 : begin sao_top_blk_0 <= sao_rec_line_00_r; sao_top_blk_1 <= sao_rec_line_01_r; end 
        01 : begin sao_top_blk_0 <= sao_rec_line_01_r; sao_top_blk_1 <= sao_rec_line_02_r; end 
        02 : begin sao_top_blk_0 <= sao_rec_line_02_r; sao_top_blk_1 <= sao_rec_line_03_r; end 
        03 : begin sao_top_blk_0 <= sao_rec_line_03_r; sao_top_blk_1 <= sao_rec_line_04_r; end 
        04 : begin sao_top_blk_0 <= sao_rec_line_04_r; sao_top_blk_1 <= sao_rec_line_05_r; end 
        05 : begin sao_top_blk_0 <= sao_rec_line_05_r; sao_top_blk_1 <= sao_rec_line_06_r; end 
        06 : begin sao_top_blk_0 <= sao_rec_line_06_r; sao_top_blk_1 <= sao_rec_line_07_r; end 
        07 : begin sao_top_blk_0 <= sao_rec_line_07_r; sao_top_blk_1 <= sao_rec_line_08_r; end 
        08 : begin sao_top_blk_0 <= sao_rec_line_08_r; sao_top_blk_1 <= sao_rec_line_09_r; end 
        09 : begin sao_top_blk_0 <= sao_rec_line_09_r; sao_top_blk_1 <= sao_rec_line_10_r; end 
        10 : begin sao_top_blk_0 <= sao_rec_line_10_r; sao_top_blk_1 <= sao_rec_line_11_r; end 
        11 : begin sao_top_blk_0 <= sao_rec_line_11_r; sao_top_blk_1 <= sao_rec_line_12_r; end 
        12 : begin sao_top_blk_0 <= sao_rec_line_12_r; sao_top_blk_1 <= sao_rec_line_13_r; end 
        13 : begin sao_top_blk_0 <= sao_rec_line_13_r; sao_top_blk_1 <= sao_rec_line_14_r; end 
        14 : begin sao_top_blk_0 <= sao_rec_line_14_r; sao_top_blk_1 <= sao_rec_line_15_r; end 
        default : begin sao_top_blk_0 <= 0; sao_top_blk_1 <= 0; end 
    endcase 
end 

always @ ( * ) begin 
    sao_rec_0_o     = 0;
    sao_rec_1_o     = 0;
    sao_rec_2_o     = 0;
    sao_rec_3_o     = 0;
    sao_rec_4_o     = 0;
    sao_rec_5_o     = 0;
    if ( sao_rec_4x4_x_d1 > 0 && sao_rec_4x4_x_d1 < 16 ) begin 
        if ( sao_rec_4x4_y_d1 == 0 ) begin 
            sao_rec_0_o = {sao_rec_block_d1[16*`PIXEL_WIDTH-1:12*`PIXEL_WIDTH],sao_rec_blk_w[16*`PIXEL_WIDTH-1:14*`PIXEL_WIDTH]} ;
            sao_rec_1_o = {sao_rec_block_d1[12*`PIXEL_WIDTH-1:8 *`PIXEL_WIDTH],sao_rec_blk_w[12*`PIXEL_WIDTH-1:10*`PIXEL_WIDTH]} ;
            sao_rec_2_o = {sao_rec_block_d1[8 *`PIXEL_WIDTH-1:4 *`PIXEL_WIDTH],sao_rec_blk_w[8 *`PIXEL_WIDTH-1:6 *`PIXEL_WIDTH]} ;
            sao_rec_3_o = {sao_rec_block_d1[4 *`PIXEL_WIDTH-1:0 *`PIXEL_WIDTH],sao_rec_blk_w[4 *`PIXEL_WIDTH-1:2 *`PIXEL_WIDTH]} ;
        end 
        else begin 
            sao_rec_0_o = {sao_top_blk_0   [8 *`PIXEL_WIDTH-1:4 *`PIXEL_WIDTH],sao_top_blk_1[8 *`PIXEL_WIDTH-1:6 *`PIXEL_WIDTH]} ;
            sao_rec_1_o = {sao_top_blk_0   [4 *`PIXEL_WIDTH-1:0 *`PIXEL_WIDTH],sao_top_blk_1[4 *`PIXEL_WIDTH-1:2 *`PIXEL_WIDTH]} ;
            sao_rec_2_o = {sao_rec_block_d1[16*`PIXEL_WIDTH-1:12*`PIXEL_WIDTH],sao_rec_blk_w[16*`PIXEL_WIDTH-1:14*`PIXEL_WIDTH]} ;
            sao_rec_3_o = {sao_rec_block_d1[12*`PIXEL_WIDTH-1:8 *`PIXEL_WIDTH],sao_rec_blk_w[12*`PIXEL_WIDTH-1:10*`PIXEL_WIDTH]} ;
            sao_rec_4_o = {sao_rec_block_d1[8 *`PIXEL_WIDTH-1:4 *`PIXEL_WIDTH],sao_rec_blk_w[8 *`PIXEL_WIDTH-1:6 *`PIXEL_WIDTH]} ;
            sao_rec_5_o = {sao_rec_block_d1[4 *`PIXEL_WIDTH-1:0 *`PIXEL_WIDTH],sao_rec_blk_w[4 *`PIXEL_WIDTH-1:2 *`PIXEL_WIDTH]} ;
        end 
    end 
end 

//---- output control ----------------------------------------------
wire [12*`PIXEL_WIDTH-1:0] out_rec_top_w ;
reg  [12*`PIXEL_WIDTH-1:0] out_rec_cur_r ;
assign out_rec_top_w = sao_rec_4x4_y_d1==0 ? sao_block_i[16*`PIXEL_WIDTH-1:4*`PIXEL_WIDTH] : sao_block_i[12*`PIXEL_WIDTH-1:0*`PIXEL_WIDTH] ;

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        out_rec_blk_00_r <= 0; out_rec_blk_08_r <= 0; 
        out_rec_blk_01_r <= 0; out_rec_blk_09_r <= 0; 
        out_rec_blk_02_r <= 0; out_rec_blk_10_r <= 0; 
        out_rec_blk_03_r <= 0; out_rec_blk_11_r <= 0; 
        out_rec_blk_04_r <= 0; out_rec_blk_12_r <= 0; 
        out_rec_blk_05_r <= 0; out_rec_blk_13_r <= 0; 
        out_rec_blk_06_r <= 0; out_rec_blk_14_r <= 0; 
        out_rec_blk_07_r <= 0; out_rec_blk_15_r <= 0; 
    end 
    else if ( sao_rec_4x4_x_d1 != 0 ) begin 
        case ( sao_4x4_x_o )
            00 : out_rec_blk_00_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            01 : out_rec_blk_01_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            02 : out_rec_blk_02_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            03 : out_rec_blk_03_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            04 : out_rec_blk_04_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            05 : out_rec_blk_05_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            06 : out_rec_blk_06_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            07 : out_rec_blk_07_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            08 : out_rec_blk_08_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            09 : out_rec_blk_09_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            10 : out_rec_blk_10_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            11 : out_rec_blk_11_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            12 : out_rec_blk_12_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            13 : out_rec_blk_13_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            14 : out_rec_blk_14_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            15 : out_rec_blk_15_r <= out_rec_top_w[12*`PIXEL_WIDTH-1:0];
            default : ;
        endcase 
    end 
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) 
        out_rec_cur_r <= 0;
    else 
    case ( sao_rec_4x4_x_d1 )
        00 : begin out_rec_cur_r <= out_rec_blk_00_r; end 
        01 : begin out_rec_cur_r <= out_rec_blk_01_r; end 
        02 : begin out_rec_cur_r <= out_rec_blk_02_r; end 
        03 : begin out_rec_cur_r <= out_rec_blk_03_r; end 
        04 : begin out_rec_cur_r <= out_rec_blk_04_r; end 
        05 : begin out_rec_cur_r <= out_rec_blk_05_r; end 
        06 : begin out_rec_cur_r <= out_rec_blk_06_r; end 
        07 : begin out_rec_cur_r <= out_rec_blk_07_r; end 
        08 : begin out_rec_cur_r <= out_rec_blk_08_r; end 
        09 : begin out_rec_cur_r <= out_rec_blk_09_r; end 
        10 : begin out_rec_cur_r <= out_rec_blk_10_r; end 
        11 : begin out_rec_cur_r <= out_rec_blk_11_r; end 
        12 : begin out_rec_cur_r <= out_rec_blk_12_r; end 
        13 : begin out_rec_cur_r <= out_rec_blk_13_r; end 
        14 : begin out_rec_cur_r <= out_rec_blk_14_r; end 
        default : begin out_rec_cur_r <= 0;  end 
    endcase 
end 

// output to fetch
wire                            fetch_wr_ena_w       ;       
wire [3:0]                      fetch_wr_4x4_x_w     ;
wire [3:0]                      fetch_wr_4x4_y_w     ;    
reg  [16*`PIXEL_WIDTH-1:0]      fetch_wr_data_w      ; 
reg                             fetch_wr_done_w      ;
wire [1:0]                      fetch_wr_sel_w       ;

assign fetch_wr_4x4_x_w = sao_rec_4x4_x_d1-1;
assign fetch_wr_4x4_y_w = sao_rec_4x4_y_d1==0 ? 0 : sao_rec_4x4_y_d1 - 1 ;
assign fetch_wr_ena_w   = sao_rec_4x4_y_d1 != 0 && sao_rec_4x4_x_d1 != 0 && state_i == OUT && cnt_i > 16;
assign fetch_wr_sel_w   = sao_rec_sel_d1 ;
// assign fetch_wr_done_w  = ( fetch_wr_sel_w == `TYPE_V && fetch_wr_4x4_x_w == 7 && fetch_wr_4x4_y_w == 7 ) ;
always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) 
        fetch_wr_done_w <= 0;
    else if ( state_i == OUT && fetch_wr_sel_w == `TYPE_V && fetch_wr_4x4_x_w == 7 && fetch_wr_4x4_y_w == 7 ) 
        fetch_wr_done_w <= 1 ;
    else 
        fetch_wr_done_w <= 0;
end 

always @* begin 
    if ( ( fetch_wr_sel_w == `TYPE_Y && fetch_wr_4x4_y_w < 15 && fetch_wr_4x4_x_w < 15 ) 
       ||( fetch_wr_sel_w == `TYPE_U && fetch_wr_4x4_y_w < 7  && fetch_wr_4x4_x_w < 7  )
       ||( fetch_wr_sel_w == `TYPE_V && fetch_wr_4x4_y_w < 7  && fetch_wr_4x4_x_w < 7  ))
        fetch_wr_data_w = {out_rec_cur_r, sao_block_i[16*`PIXEL_WIDTH-1:12*`PIXEL_WIDTH] };
    else if ( ( fetch_wr_sel_w == `TYPE_Y && fetch_wr_4x4_x_w == 15 ) 
            ||( fetch_wr_sel_w == `TYPE_U && fetch_wr_4x4_x_w == 7  )
            ||( fetch_wr_sel_w == `TYPE_V && fetch_wr_4x4_x_w == 7  ))
        fetch_wr_data_w = sao_rec_right_most_d1 ;
    else 
        fetch_wr_data_w = sao_rec_block_d1 ; // without offset
end 

//================================================
//
//          ori 
//
//===================================================

wire    [3:0]                   ori_4x4_x_o  ;  
wire    [3:0]                   ori_4x4_y_o  ;  
wire    [4:0]                   ori_4x4_idx_o;
wire                            ori_ren_o    ;
wire    [1:0]                   ori_sel_o    ;
wire    [1:0]                   ori_siz_o    ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_blk_0 ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_blk_1 ;
wire    [16*`PIXEL_WIDTH-1 :0]  ori_left_block_w ;

reg     [4*`PIXEL_WIDTH-1  :0]  sao_ori_0_o   ;
reg     [4*`PIXEL_WIDTH-1  :0]  sao_ori_1_o   ;
reg     [4*`PIXEL_WIDTH-1  :0]  sao_ori_2_o   ;
reg     [4*`PIXEL_WIDTH-1  :0]  sao_ori_3_o   ;


reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_00_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_01_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_02_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_03_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_04_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_05_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_06_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_07_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_08_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_09_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_10_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_11_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_12_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_13_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_14_r ;
reg     [4 *`PIXEL_WIDTH-1 :0]  sao_ori_line_15_r ;

assign ori_4x4_x_o   = sao_rec_4x4_x_r  ; 
assign ori_4x4_y_o   = sao_rec_4x4_y_o  ; 
assign ori_4x4_idx_o = 0; 
assign ori_ren_o     = state_i == SAO   ;  
assign ori_sel_o     = sao_rec_sel_r    ; 
assign ori_siz_o     = sao_rec_siz_w    ;  

// spilt input block
assign ori_left_block_w = ori_pxl_i_w[32*`PIXEL_WIDTH-1:16*`PIXEL_WIDTH];

always @(posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) 
        sao_ori_block_d1 <= 0;
    else 
        sao_ori_block_d1 <= ori_left_block_w ;
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        sao_ori_line_00_r <= 0; sao_ori_line_08_r <= 0; 
        sao_ori_line_01_r <= 0; sao_ori_line_09_r <= 0; 
        sao_ori_line_02_r <= 0; sao_ori_line_10_r <= 0; 
        sao_ori_line_03_r <= 0; sao_ori_line_11_r <= 0; 
        sao_ori_line_04_r <= 0; sao_ori_line_12_r <= 0; 
        sao_ori_line_05_r <= 0; sao_ori_line_13_r <= 0; 
        sao_ori_line_06_r <= 0; sao_ori_line_14_r <= 0; 
        sao_ori_line_07_r <= 0; sao_ori_line_15_r <= 0; 
    end 
    else begin 
        case ( sao_rec_4x4_x_d1 )
            00 : sao_ori_line_00_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            01 : sao_ori_line_01_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            02 : sao_ori_line_02_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            03 : sao_ori_line_03_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            04 : sao_ori_line_04_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            05 : sao_ori_line_05_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            06 : sao_ori_line_06_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            07 : sao_ori_line_07_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            08 : sao_ori_line_08_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            09 : sao_ori_line_09_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            10 : sao_ori_line_10_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            11 : sao_ori_line_11_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            12 : sao_ori_line_12_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            13 : sao_ori_line_13_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            14 : sao_ori_line_14_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            15 : sao_ori_line_15_r <= ori_left_block_w[8 *`PIXEL_WIDTH-1:0];
            default : ;
        endcase 
    end 
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        sao_ori_blk_0 <= 0; 
        sao_ori_blk_1 <= 0;
    end else 
    case ( sao_4x4_x_o )
        00 : begin sao_ori_blk_0 <= sao_ori_line_00_r; sao_ori_blk_1 <= sao_ori_line_01_r; end 
        01 : begin sao_ori_blk_0 <= sao_ori_line_01_r; sao_ori_blk_1 <= sao_ori_line_02_r; end 
        02 : begin sao_ori_blk_0 <= sao_ori_line_02_r; sao_ori_blk_1 <= sao_ori_line_03_r; end 
        03 : begin sao_ori_blk_0 <= sao_ori_line_03_r; sao_ori_blk_1 <= sao_ori_line_04_r; end 
        04 : begin sao_ori_blk_0 <= sao_ori_line_04_r; sao_ori_blk_1 <= sao_ori_line_05_r; end 
        05 : begin sao_ori_blk_0 <= sao_ori_line_05_r; sao_ori_blk_1 <= sao_ori_line_06_r; end 
        06 : begin sao_ori_blk_0 <= sao_ori_line_06_r; sao_ori_blk_1 <= sao_ori_line_07_r; end 
        07 : begin sao_ori_blk_0 <= sao_ori_line_07_r; sao_ori_blk_1 <= sao_ori_line_08_r; end 
        08 : begin sao_ori_blk_0 <= sao_ori_line_08_r; sao_ori_blk_1 <= sao_ori_line_09_r; end 
        09 : begin sao_ori_blk_0 <= sao_ori_line_09_r; sao_ori_blk_1 <= sao_ori_line_10_r; end 
        10 : begin sao_ori_blk_0 <= sao_ori_line_10_r; sao_ori_blk_1 <= sao_ori_line_11_r; end 
        11 : begin sao_ori_blk_0 <= sao_ori_line_11_r; sao_ori_blk_1 <= sao_ori_line_12_r; end 
        12 : begin sao_ori_blk_0 <= sao_ori_line_12_r; sao_ori_blk_1 <= sao_ori_line_13_r; end 
        13 : begin sao_ori_blk_0 <= sao_ori_line_13_r; sao_ori_blk_1 <= sao_ori_line_14_r; end 
        14 : begin sao_ori_blk_0 <= sao_ori_line_14_r; sao_ori_blk_1 <= sao_ori_line_15_r; end 
        default : begin sao_ori_blk_0 <= 0; sao_ori_blk_1 <= 0; end 
    endcase 
end 

always @ ( * ) begin 
    sao_ori_0_o     = 0;
    sao_ori_1_o     = 0;
    sao_ori_2_o     = 0;
    sao_ori_3_o     = 0;
    if ( sao_rec_4x4_x_d1 > 0 && sao_rec_4x4_x_d1 < 16 && state_i == SAO ) begin 
        if ( sao_rec_4x4_y_d1 == 0 ) begin 
            sao_ori_0_o = {sao_ori_block_d1[11*`PIXEL_WIDTH-1:8 *`PIXEL_WIDTH],ori_left_block_w[12*`PIXEL_WIDTH-1:11*`PIXEL_WIDTH]} ;
            sao_ori_1_o = {sao_ori_block_d1[7 *`PIXEL_WIDTH-1:4 *`PIXEL_WIDTH],ori_left_block_w[8 *`PIXEL_WIDTH-1:7 *`PIXEL_WIDTH]} ;
            sao_ori_2_o = {sao_ori_block_d1[3 *`PIXEL_WIDTH-1:0 *`PIXEL_WIDTH],ori_left_block_w[4 *`PIXEL_WIDTH-1:3 *`PIXEL_WIDTH]} ;
        end  
        else begin 
            sao_ori_0_o = {sao_ori_blk_0   [3 *`PIXEL_WIDTH-1:0 *`PIXEL_WIDTH],sao_ori_blk_1    [4 *`PIXEL_WIDTH-1:3 *`PIXEL_WIDTH]} ;
            sao_ori_1_o = {sao_ori_block_d1[15*`PIXEL_WIDTH-1:12*`PIXEL_WIDTH],ori_left_block_w [16*`PIXEL_WIDTH-1:15*`PIXEL_WIDTH]} ;
            sao_ori_2_o = {sao_ori_block_d1[11*`PIXEL_WIDTH-1:8 *`PIXEL_WIDTH],ori_left_block_w [12*`PIXEL_WIDTH-1:11*`PIXEL_WIDTH]} ;
            sao_ori_3_o = {sao_ori_block_d1[7 *`PIXEL_WIDTH-1:4 *`PIXEL_WIDTH],ori_left_block_w [8 *`PIXEL_WIDTH-1:7 *`PIXEL_WIDTH]} ;
        end  
    end
end 

//=======================================================================
//
//          output rec control 
//
//========================================================================
reg [3:0]                   rec_4x4_x_o            ;
reg [3:0]                   rec_4x4_y_o            ;
reg [4:0]                   rec_4x4_idx_o          ;
reg                         rec_wen_o              ;
reg                         rec_ren_o              ;
reg [1:0]                   rec_sel_o              ;
reg [1:0]                   rec_siz_o              ;

always @ ( * ) begin 
    if ( state_i == DBY || state_i == DBU || state_i == DBV ) begin 
        rec_4x4_x_o   = db_rec_4x4_x_r  ;
        rec_4x4_y_o   = db_rec_4x4_y_r  ;
        rec_4x4_idx_o = db_rec_4x4_idx_r;
        rec_wen_o     = db_rec_wen_w    ;
        rec_ren_o     = db_rec_ren_w    ;
        rec_sel_o     = db_rec_sel_w    ;
        rec_siz_o     = db_rec_siz_w    ;
    end 
    else if ( state_i == SAO || state_i == OUT ) begin 
        rec_4x4_x_o   = sao_rec_4x4_x_o  ;
        rec_4x4_y_o   = sao_rec_4x4_y_o  ;
        rec_4x4_idx_o = 0                ;
        rec_wen_o     = 0                ;
        rec_ren_o     = sao_rec_ren_w    ;
        rec_sel_o     = sao_rec_sel_r    ;
        rec_siz_o     = `SIZE_04         ;
    end  
    else begin 
        rec_4x4_x_o   = 0;
        rec_4x4_y_o   = 0;
        rec_4x4_idx_o = 0;
        rec_wen_o     = 0;
        rec_ren_o     = 0;
        rec_sel_o     = 0;
        rec_siz_o     = 0;
    end 
end 

//***************************************************************
//
//          output to fetch 
//
//***************************************************************
//
//       0  1   2  ...  14  15
//      ------------------------> w_4x4_x
//  16 |
//  00 |
//  01 |
//  .. |
//  14 |
//  15 |
//    w_4x4_y

reg                         fetch_wen_o            ;
reg [4:0]                   fetch_w4x4_x_o         ;
reg [4:0]                   fetch_w4x4_y_o         ;
reg                         fetch_wprevious_o      ;
reg                         fetch_wdone_o          ;
reg [1:0]                   fetch_wsel_o           ;
reg [127:0]                 fetch_wdata_o          ;

reg  [8:0] cnt_d3 ;
always @ ( posedge clk or negedge rst_n) begin 
    if ( !rst_n) 
        cnt_d3 <= 0;
    else 
        cnt_d3 <= cnt_d2;
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) 
        fetch_wdone_o <= 'd0;
    else 
        fetch_wdone_o <= fetch_wr_done_w ;
end 


always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n )begin 
        fetch_wen_o                 <= 1'b0;
        fetch_wprevious_o           <= 1'b0;
        fetch_wsel_o                <= 0;
        fetch_w4x4_x_o              <= 5'd0;
        fetch_w4x4_y_o              <= 5'd0;
        fetch_wdata_o               <= 0;
    end 
    else begin 
        case ( state_i )
            DBY : begin 
                fetch_wsel_o            <= `TYPE_Y;

                if ( cnt_d3[7:5] == 'd0 && cnt_d3 < 32) begin // top
                    fetch_wen_o <= sys_ctu_y_i != 0;
                    case (cnt_d3[4:0])
                        2 : begin fetch_w4x4_x_o <= 5'd15; fetch_w4x4_y_o <= 5'd0 ; fetch_wdata_o <= block[2]; fetch_wprevious_o <= 1'b1; end // left[0]
                        3 : begin fetch_w4x4_x_o <= 5'd15; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[0]; fetch_wprevious_o <= 1'b0; end 
                        4 : begin fetch_w4x4_x_o <= 5'd0 ; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[1]; fetch_wprevious_o <= 1'b0; end 
                        6 : begin fetch_w4x4_x_o <= 5'd1 ; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[4]; fetch_wprevious_o <= 1'b0; end 
                        7 : begin fetch_w4x4_x_o <= 5'd2 ; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[5]; fetch_wprevious_o <= 1'b0; end 
                        10: begin fetch_w4x4_x_o <= 5'd3 ; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[0]; fetch_wprevious_o <= 1'b0; end 
                        11: begin fetch_w4x4_x_o <= 5'd4 ; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[1]; fetch_wprevious_o <= 1'b0; end 
                        14: begin fetch_w4x4_x_o <= 5'd5 ; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[4]; fetch_wprevious_o <= 1'b0; end 
                        15: begin fetch_w4x4_x_o <= 5'd6 ; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[5]; fetch_wprevious_o <= 1'b0; end 
                        18: begin fetch_w4x4_x_o <= 5'd7 ; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[0]; fetch_wprevious_o <= 1'b0; end 
                        19: begin fetch_w4x4_x_o <= 5'd8 ; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[1]; fetch_wprevious_o <= 1'b0; end 
                        22: begin fetch_w4x4_x_o <= 5'd9 ; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[4]; fetch_wprevious_o <= 1'b0; end 
                        23: begin fetch_w4x4_x_o <= 5'd10; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[5]; fetch_wprevious_o <= 1'b0; end 
                        26: begin fetch_w4x4_x_o <= 5'd11; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[0]; fetch_wprevious_o <= 1'b0; end 
                        27: begin fetch_w4x4_x_o <= 5'd12; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[1]; fetch_wprevious_o <= 1'b0; end 
                        30: begin fetch_w4x4_x_o <= 5'd13; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[4]; fetch_wprevious_o <= 1'b0; end 
                        31: begin fetch_w4x4_x_o <= 5'd14; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= block[5]; fetch_wprevious_o <= 1'b0; end 
                        29: begin fetch_w4x4_x_o <= 5'd15; fetch_w4x4_y_o <= 5'd16; fetch_wdata_o <= top_y_r[15]; fetch_wprevious_o <= 1'b0; end // output the top-right block
                        default : ;
                    endcase 
                end 
                else if ( cnt_d3[4:2] == 'd0 && cnt_d3[1] == 1'b1 && cnt_d3 < 229 ) begin // left 
                    fetch_wen_o         <= sys_ctu_x_i != 0;
                    fetch_w4x4_x_o      <= 5'd15;
                    fetch_w4x4_y_o      <= {cnt_d3[7:5], cnt_d3[0]}-1'b1;
                    fetch_wdata_o       <= cnt_d3[0] ? block[2] : block[0];
                    fetch_wprevious_o   <= 1'b1;
                end 
                else begin 
                    fetch_wen_o         <= 0 ;
                    fetch_w4x4_x_o      <= 0 ;
                    fetch_w4x4_y_o      <= 0 ;
                    fetch_wdata_o       <= 0 ;
                    fetch_wprevious_o   <= 0 ;
                end 
            end 
            DBU : begin 
                fetch_wsel_o        <= `TYPE_U;

                if ( cnt_d3[5:4] == 'd0 && cnt_d3 < 16) begin // top
                    fetch_wen_o <= sys_ctu_y_i != 0;
                    case (cnt_d3[3:0])
                        2 : begin fetch_w4x4_x_o <= 5'd7 ; fetch_w4x4_y_o <= 5'd0 ; fetch_wdata_o <= block[2]; fetch_wprevious_o <= 1'b1; end // left[0]
                        3 : begin fetch_w4x4_x_o <= 5'd7 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[0]; fetch_wprevious_o <= 1'b0;end 
                        4 : begin fetch_w4x4_x_o <= 5'd0 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[1]; fetch_wprevious_o <= 1'b0;end 
                        6 : begin fetch_w4x4_x_o <= 5'd1 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[4]; fetch_wprevious_o <= 1'b0;end 
                        7 : begin fetch_w4x4_x_o <= 5'd2 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[5]; fetch_wprevious_o <= 1'b0;end 
                        10: begin fetch_w4x4_x_o <= 5'd3 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[0]; fetch_wprevious_o <= 1'b0;end 
                        11: begin fetch_w4x4_x_o <= 5'd4 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[1]; fetch_wprevious_o <= 1'b0;end 
                        14: begin fetch_w4x4_x_o <= 5'd5 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[4]; fetch_wprevious_o <= 1'b0;end 
                        15: begin fetch_w4x4_x_o <= 5'd6 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[5]; fetch_wprevious_o <= 1'b0;end 
                        13: begin fetch_w4x4_x_o <= 5'd7 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= top_u_r[7]; fetch_wprevious_o <= 1'b0; end
                        default : ;
                    endcase 
                end 
                else if ( cnt_d3[3:2] == 'd0 && cnt_d3[1] == 1'b1 && cnt_d3 < 53 ) begin // left 
                    fetch_wen_o         <= sys_ctu_x_i != 0;
                    fetch_w4x4_x_o      <= 5'd7;
                    fetch_w4x4_y_o      <= {cnt_d3[5:4], cnt_d3[0]}-1'b1;
                    fetch_wdata_o       <= cnt_d3[0] ? block[2] : block[0];
                    fetch_wprevious_o   <= 1'b1;
                end 
                else begin 
                    fetch_wen_o         <= 0 ;
                    fetch_w4x4_x_o      <= 0 ;
                    fetch_w4x4_y_o      <= 0 ;
                    fetch_wdata_o       <= 0 ;
                    fetch_wprevious_o   <= 0 ;
                end 
            end 
            DBV : begin 
                fetch_wsel_o            <= `TYPE_V;

                if ( cnt_d3[5:4] == 'd0 && cnt_d3 < 16) begin // top
                    fetch_wen_o <= sys_ctu_y_i != 0;
                    case (cnt_d3[3:0])
                        2 : begin fetch_w4x4_x_o <= 5'd7 ; fetch_w4x4_y_o <= 5'd0 ; fetch_wdata_o <= block[2]; fetch_wprevious_o <= 1'b1; end // left[0]
                        3 : begin fetch_w4x4_x_o <= 5'd7 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[0]; fetch_wprevious_o <= 1'b0; end 
                        4 : begin fetch_w4x4_x_o <= 5'd0 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[1]; fetch_wprevious_o <= 1'b0; end 
                        6 : begin fetch_w4x4_x_o <= 5'd1 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[4]; fetch_wprevious_o <= 1'b0; end 
                        7 : begin fetch_w4x4_x_o <= 5'd2 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[5]; fetch_wprevious_o <= 1'b0; end 
                        10: begin fetch_w4x4_x_o <= 5'd3 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[0]; fetch_wprevious_o <= 1'b0; end 
                        11: begin fetch_w4x4_x_o <= 5'd4 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[1]; fetch_wprevious_o <= 1'b0; end 
                        14: begin fetch_w4x4_x_o <= 5'd5 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[4]; fetch_wprevious_o <= 1'b0; end 
                        15: begin fetch_w4x4_x_o <= 5'd6 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= block[5]; fetch_wprevious_o <= 1'b0; end 
                        13: begin fetch_w4x4_x_o <= 5'd7 ; fetch_w4x4_y_o <= 5'd8 ; fetch_wdata_o <= top_v_r[7]; fetch_wprevious_o <= 1'b0; end
                        default : ;
                    endcase 
                end 
                else if ( cnt_d3[3:2] == 'd0 && cnt_d3[1] == 1'b1 && cnt_d3 < 53 ) begin // left 
                    fetch_wen_o         <= sys_ctu_x_i != 0;
                    fetch_w4x4_x_o      <= 5'd7;
                    fetch_w4x4_y_o      <= {cnt_d3[5:4], cnt_d3[0]}-1'b1;
                    fetch_wdata_o       <= cnt_d3[0] ? block[2] : block[0];
                    fetch_wprevious_o   <= 1'b1;
                end 
                else begin 
                    fetch_wen_o         <= 0 ;
                    fetch_w4x4_x_o      <= 0 ;
                    fetch_w4x4_y_o      <= 0 ;
                    fetch_wdata_o       <= 0 ;
                    fetch_wprevious_o   <= 0 ;
                end 
            end 
            OUT : begin 
                fetch_wen_o         <= fetch_wr_ena_w ;
                fetch_wprevious_o   <= 1'b0;
                fetch_wsel_o        <= fetch_wr_sel_w ;
                fetch_w4x4_x_o      <= fetch_wr_4x4_x_w ;
                fetch_w4x4_y_o      <= fetch_wr_4x4_y_w ;
                fetch_wdata_o       <= fetch_wr_data_w ;
            end 
            default : begin 
                fetch_wen_o         <= 0 ;
                fetch_wprevious_o   <= 0 ;
                fetch_wsel_o        <= 0 ;
                fetch_w4x4_x_o      <= 0 ;
                fetch_w4x4_y_o      <= 0 ;
                fetch_wdata_o       <= 0 ;
            end 
        endcase 

    end 
end 
  


 
 
  

//**********************************************************
// 
//          left pixel ram control
//
//**********************************************************
// write and read : state_i == DBY, DBU, DBV

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        left_y_r[ 0] <= 'd0; left_u_r[ 0] <= 'd0;
        left_y_r[ 1] <= 'd0; left_u_r[ 1] <= 'd0;
        left_y_r[ 2] <= 'd0; left_u_r[ 2] <= 'd0;
        left_y_r[ 3] <= 'd0; left_u_r[ 3] <= 'd0;
        left_y_r[ 4] <= 'd0; left_u_r[ 4] <= 'd0;
        left_y_r[ 5] <= 'd0; left_u_r[ 5] <= 'd0;
        left_y_r[ 6] <= 'd0; left_u_r[ 6] <= 'd0;
        left_y_r[ 7] <= 'd0; left_u_r[ 7] <= 'd0;
        left_y_r[ 8] <= 'd0; left_v_r[ 0] <= 'd0;
        left_y_r[ 9] <= 'd0; left_v_r[ 1] <= 'd0;
        left_y_r[10] <= 'd0; left_v_r[ 2] <= 'd0;
        left_y_r[11] <= 'd0; left_v_r[ 3] <= 'd0;
        left_y_r[12] <= 'd0; left_v_r[ 4] <= 'd0;
        left_y_r[13] <= 'd0; left_v_r[ 5] <= 'd0;
        left_y_r[14] <= 'd0; left_v_r[ 6] <= 'd0;
        left_y_r[15] <= 'd0; left_v_r[ 7] <= 'd0;
    end 
    else if ( state_i == OUT && fetch_wsel_o == 2'b00 && fetch_w4x4_x_o == 15 && fetch_wen_o ) // Y
        left_y_r[fetch_w4x4_y_o] <= fetch_wdata_o; 
    else if ( state_i == OUT && fetch_wsel_o == 2'b10 && fetch_w4x4_x_o == 7 && fetch_wen_o ) // U
        left_u_r[fetch_w4x4_y_o] <= fetch_wdata_o;
    else if ( state_i == OUT && fetch_wsel_o == 2'b11 && fetch_w4x4_x_o == 7 && fetch_wen_o ) // V 
        left_v_r[fetch_w4x4_y_o] <= fetch_wdata_o;
    else ;
end 
endmodule 
