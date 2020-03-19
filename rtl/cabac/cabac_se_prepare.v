//-----------------------------------------------------------------------------------------------------------------------------
//
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//-----------------------------------------------------------------------------------------------------------------------------
// Filename       : cabac_se_prepare.v
// Author         : liwei
// Created        : 2017/12/18
// Description    : syntax element prepare
// DATA & EDITION:  2017/12/18  1.0     liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module  cabac_se_prepare(
            clk,
            rst_n,

            sys_start_i,
            sys_slice_type_i,
            sys_total_x_i,
            sys_total_y_i,
            sys_mb_x_i,
            sys_mb_y_i,

            frame_width_remain_i,
            frame_height_remain_i,   //6 bits,used for the boundary

            context_init_done_i,

            rc_param_qp_i,
            rc_qp_i,

            sao_i,

            mb_partition_i,
            mb_p_pu_mode_i,

            mb_skip_flag_i,
            mb_merge_flag_i,
            mb_merge_idx_i,

            mb_cbf_y_i,
            mb_cbf_v_i,
            mb_cbf_u_i,

            mb_i_luma_mode_data_i,

            mb_i_luma_mode_ren_o,
            mb_i_luma_mode_addr_o,

            mb_mvd_data_i,
            mb_cef_data_i,

            mb_mvd_ren_o,
            mb_mvd_addr_o,
            mb_cef_addr_o,
            mb_cef_ren_o,

            coeff_type_o,
            en_o,

            gp_qp_o,
            gp_slice_type_o,
            gp_cabac_init_flag_o,
            gp_five_minus_max_num_merge_cand_o,

            lcu_done_o,

            syntax_element_0_o,
            syntax_element_1_o,
            syntax_element_2_o,
            syntax_element_3_o,
            syntax_element_valid_o
        );


/*----------------------------input and output declaration----------------------------*/
//input data
input clk; // clock signal
input rst_n ; // reset signal, low active

input sys_start_i; // cabac start signal, pulse signal
input sys_slice_type_i; // slice type, (`SLICE_TYPE_I):1, (`SLICE_TYPE_P):0
input [(`PIC_X_WIDTH)-1:0]  sys_total_x_i;
input [(`PIC_Y_WIDTH)-1:0]  sys_total_y_i;
input [(`PIC_X_WIDTH)-1:0]  sys_mb_x_i;
input [(`PIC_Y_WIDTH)-1:0]  sys_mb_y_i;

input [5:0] frame_width_remain_i;
input [5:0] frame_height_remain_i;

input [5:0] rc_param_qp_i; // QP
input [5:0] rc_qp_i ;      // lcu of qp

input [61:0] sao_i; // {merge_top,merge_left,{sao_type,sao_subIdx,sao_offsetx4}{chroma,luma}}
input [5:0] mb_i_luma_mode_data_i; // intra luma mode  , 6 bits for each 8x8 cu in z-scan , 64x64 = [5:0]

input [ 41:0] mb_p_pu_mode_i ; // inter partition size ,the minsize of pu is 8x8
input [ 84:0] mb_merge_flag_i;
input [339:0] mb_merge_idx_i ;

input [84:0] mb_partition_i; // cu split flag,[0]:64x64, [1:4]:32x32, [5:20]:16x16,[6:84]:8x8 , if not split into 8x8 , should be equal zero , cu_luma_mode_left_0_w
input [84:0] mb_skip_flag_i; // cu skip  flag,[0]:64x64, [1:4]:32x32, [5:20]:16x16,[6:84]:8x8

input [`LCU_SIZE*`LCU_SIZE/16-1:0]   mb_cbf_y_i; // z-scan, reverse order , 256 bits , [0] is the last 4x4 cu ,[255] is the first 4x4 cu
input [`LCU_SIZE*`LCU_SIZE/16-1:0]   mb_cbf_v_i; // z-scan, reverse order , 64  bits ,
input [`LCU_SIZE*`LCU_SIZE/16-1:0]   mb_cbf_u_i; // z-scan, reverse order , 64  bits ,

input [(2*`MVD_WIDTH) :0] mb_mvd_data_i; // {mvd_idx,mvd_x & mvd_y} , FMV_WIDTH  = 10
input [255:0] mb_cef_data_i; // coeff data of a 4x4 block,a coeff is 16 bits

//ctrl info
input context_init_done_i; //context table init done

//output
output [1:0] gp_slice_type_o; // I-2; P-1; B-0
output gp_cabac_init_flag_o;
output [2:0] gp_five_minus_max_num_merge_cand_o;//usually to be 0
output [5:0] gp_qp_o;

output mb_i_luma_mode_ren_o;
output [5:0] mb_i_luma_mode_addr_o;

output mb_mvd_ren_o;
output [5:0] mb_mvd_addr_o;
output mb_cef_ren_o;
output [8:0] mb_cef_addr_o;

output [1:0] coeff_type_o;
output en_o;

output lcu_done_o;

output [22:0] syntax_element_0_o; // ses pair {se_value , cmax , ctx_idx(xxx_xxxxxx)}
output [22:0] syntax_element_1_o;
output [14:0] syntax_element_2_o;
output [14:0] syntax_element_3_o;
output syntax_element_valid_o;

reg [22:0] syntax_element_0_r;
reg [22:0] syntax_element_1_r;
reg [14:0] syntax_element_2_r;
reg [14:0] syntax_element_3_r;

wire [1:0] gp_slice_type_o; // I-2; P-1; B-0
wire  gp_cabac_init_flag_o;
wire [2:0] gp_five_minus_max_num_merge_cand_o;
wire [5:0] gp_qp_o;
wire en_o;

reg mb_i_luma_mode_ren_o;
reg [5:0] mb_i_luma_mode_addr_o;


/*------------------parameter declaration and state declaration of fsm -----------------*/
parameter   CU_64x64 =  4'd0;
parameter   CU_32x32 =  4'd1;
parameter   CU_16x16 =  4'd2;
parameter   CU_8x8   =  4'd3;
parameter   LCU_IDLE =  4'd4;
parameter   CU_SPLIT =  4'd5;
parameter   LCU_END  =  4'd6;
parameter   LCU_INIT =  4'd7;
parameter   LCU_SAO  =  4'd8;
//state declaration
reg      [3:0]                    lcu_curr_state_r  ;// current state of the fsm
reg      [3:0]                    lcu_next_state_r  ;// next state of the fsm


/*---------------------ctrl info of fsm in lcu level ------------------------------------*/
reg [3:0] lcu_cyc_cnt_r;
reg lcu_done_r;
reg context_init_done_delay_r;

//lcu_cyc_cnt_r delay 14 cycles
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        lcu_cyc_cnt_r <= 4'd0;
    else if(lcu_curr_state_r== LCU_SAO)
        lcu_cyc_cnt_r <= lcu_cyc_cnt_r + 1'd1;
    else if (lcu_curr_state_r!=LCU_END)
        lcu_cyc_cnt_r <= 4'd0                ;
    else if(lcu_cyc_cnt_r==4'd13)
        lcu_cyc_cnt_r <= 4'd0                ;
    else
        lcu_cyc_cnt_r <= lcu_cyc_cnt_r + 1'd1;
end

// lcu_done_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        lcu_done_r  <=  1'b0;
    else if(lcu_curr_state_r==LCU_END && lcu_cyc_cnt_r==4'd13)
        lcu_done_r  <=  1'b1;
    else
        lcu_done_r  <=  1'b0;
end

//context_init_done_delay_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        context_init_done_delay_r <= 1'b0;
    else
        context_init_done_delay_r <= context_init_done_i;
end


/*---------------------------ctrl info of fsm in CU level ------------------------------------*/
wire cu_done_w;
reg  cu_done_r;
reg  [6:0] cu_idx_r;
reg  split_cu_flag_r;
reg  [1:0] cu_depth_r;
wire [6:0] cu_idx_minus1_w;     //  cu index minus 1
wire [6:0] cu_idx_minus5_w;     //  cu index minus 5
wire [6:0] cu_idx_minus21_w;    //  cu index minus 21
wire [6:0] cu_idx_plus1_w;      //  cu index plus 1
wire [6:0] cu_idx_deep_plus1_w; //  cu index of deep depth plus 1

//variable used for boundary check
reg  [6:0] x_boundary_r,y_boundary_r;//whether current cu's position is out of boundary
wire lcu_boundary_x_flag_w,lcu_boundary_y_flag_w;//the current lcu is the last lcu of x or y
wire boundary_flag_w;
wire [6:0] x_remain_w,y_remain_w;

//wire logic of cu_idx
assign  cu_idx_minus1_w  = cu_idx_r - 7'd1  ;
assign  cu_idx_minus5_w  = cu_idx_r - 7'd5  ;
assign  cu_idx_minus21_w = cu_idx_r - 7'd21 ;

assign  cu_idx_plus1_w      = cu_idx_r + 7'd1;
assign  cu_idx_deep_plus1_w = (cu_idx_r<<2) + 7'd1 ;

//wire logic of boundary check
assign lcu_boundary_x_flag_w = (sys_mb_x_i == sys_total_x_i);
assign lcu_boundary_y_flag_w = (sys_mb_y_i == sys_total_y_i);

always @(*) begin
    if(cu_idx_r == 'd0)
        x_boundary_r = 7'd64;
    else if(cu_idx_minus1_w[6:2]=='d0)
        x_boundary_r = (cu_idx_minus1_w[0] << 5) + 7'd32;
    else if(cu_idx_minus5_w[6:4]=='d0)
        x_boundary_r = (cu_idx_minus5_w[2] << 5) + (cu_idx_minus5_w[0] << 4) + 7'd16;
    else 
        x_boundary_r = (cu_idx_minus21_w[4] << 5) + (cu_idx_minus21_w[2] << 4) + (cu_idx_minus21_w[0] << 3) + 7'd8;
end

always @(*) begin
    if(cu_idx_r == 'd0)
        y_boundary_r = 7'd64;
    else if(cu_idx_minus1_w[6:2]=='d0)
        y_boundary_r = (cu_idx_minus1_w[1] << 5) + 7'd32;
    else if(cu_idx_minus5_w[6:4]=='d0)
        y_boundary_r = (cu_idx_minus5_w[3] << 5) + (cu_idx_minus5_w[1] << 4) + 7'd16;
    else 
        y_boundary_r = (cu_idx_minus21_w[5] << 5) + (cu_idx_minus21_w[3] << 4) + (cu_idx_minus21_w[1] << 3) + 7'd8;
end

assign x_remain_w = (frame_width_remain_i == 6'd0)?7'd64:frame_width_remain_i;
assign y_remain_w = (frame_height_remain_i == 6'd0)?7'd64:frame_height_remain_i;
assign boundary_flag_w = (lcu_boundary_x_flag_w&(x_boundary_r>x_remain_w))||(lcu_boundary_y_flag_w&(y_boundary_r>y_remain_w));

//  cu_done_r
always @*
begin
    case(lcu_curr_state_r)
        LCU_IDLE:
            cu_done_r = 1'd0;
        CU_SPLIT:
            cu_done_r = 1'd1;
        CU_64x64,
        CU_32x32,
        CU_16x16,
        CU_8x8  :
            cu_done_r = cu_done_w ;
        LCU_END :
            cu_done_r = 1'd0      ;
        default :
            cu_done_r = 1'd0      ;
    endcase
end

// cu_idx_r
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cu_idx_r <= 0;
    else if(cu_done_r||boundary_flag_w)
    begin   //add boundary_flag_w to check boundary
        if(lcu_curr_state_r==CU_SPLIT)
        begin
            if(split_cu_flag_r)
                cu_idx_r <= cu_idx_deep_plus1_w;
            else
                cu_idx_r <= cu_idx_r;
        end
        else
        begin
            case(cu_depth_r)
                2'b00:
                begin
                    cu_idx_r <= 'd0;
                end

                2'b01:
                begin
                    if(cu_idx_minus1_w[1:0]==2'd3)
                        cu_idx_r <= 'd0;
                    else
                        cu_idx_r <= cu_idx_plus1_w;
                end

                2'b10:
                begin
                    if(cu_idx_minus5_w[3:0]=='d15)
                        cu_idx_r <= 'd0;
                    else if(cu_idx_minus5_w[1:0]==2'd3)
                    begin
                        cu_idx_r <= (cu_idx_r >> 2);
                    end
                    else
                    begin
                        cu_idx_r <= cu_idx_plus1_w;
                    end
                end

                2'b11:
                begin
                    if(cu_idx_minus21_w[5:0]==6'd63)
                        cu_idx_r <= 'd0;
                    else if(cu_idx_minus21_w[3:0]==4'd15)
                        cu_idx_r <= (cu_idx_minus21_w >> 4) + 'd2;
                    else if(cu_idx_minus21_w[1:0]==2'd3)
                        cu_idx_r <= (cu_idx_minus21_w >> 2) + 'd6;
                    else
                        cu_idx_r <= cu_idx_plus1_w;
                end
            endcase
        end
    end
    else
    begin
        cu_idx_r <= cu_idx_r;
    end
end


// split_cu_flag_r
always @*
begin
    if(sys_slice_type_i)
    begin
        case(cu_idx_r)
            7'd0  :
                split_cu_flag_r   =   mb_partition_i[0 ];
            7'd1  :
                split_cu_flag_r   =   mb_partition_i[1 ];
            7'd2  :
                split_cu_flag_r   =   mb_partition_i[2 ];
            7'd3  :
                split_cu_flag_r   =   mb_partition_i[3 ];
            7'd4  :
                split_cu_flag_r   =   mb_partition_i[4 ];
            7'd5  :
                split_cu_flag_r   =   mb_partition_i[5 ];
            7'd6  :
                split_cu_flag_r   =   mb_partition_i[6 ];
            7'd7  :
                split_cu_flag_r   =   mb_partition_i[7 ];
            7'd8  :
                split_cu_flag_r   =   mb_partition_i[8 ];
            7'd9  :
                split_cu_flag_r   =   mb_partition_i[9 ];
            7'd10 :
                split_cu_flag_r   =   mb_partition_i[10];
            7'd11 :
                split_cu_flag_r   =   mb_partition_i[11];
            7'd12 :
                split_cu_flag_r   =   mb_partition_i[12];
            7'd13 :
                split_cu_flag_r   =   mb_partition_i[13];
            7'd14 :
                split_cu_flag_r   =   mb_partition_i[14];
            7'd15 :
                split_cu_flag_r   =   mb_partition_i[15];
            7'd16 :
                split_cu_flag_r   =   mb_partition_i[16];
            7'd17 :
                split_cu_flag_r   =   mb_partition_i[17];
            7'd18 :
                split_cu_flag_r   =   mb_partition_i[18];
            7'd19 :
                split_cu_flag_r   =   mb_partition_i[19];
            7'd20 :
                split_cu_flag_r   =   mb_partition_i[20];
            7'd21 :
                split_cu_flag_r   =   mb_partition_i[21];
            7'd22 :
                split_cu_flag_r   =   mb_partition_i[22];
            7'd23 :
                split_cu_flag_r   =   mb_partition_i[23];
            7'd24 :
                split_cu_flag_r   =   mb_partition_i[24];
            7'd25 :
                split_cu_flag_r   =   mb_partition_i[25];
            7'd26 :
                split_cu_flag_r   =   mb_partition_i[26];
            7'd27 :
                split_cu_flag_r   =   mb_partition_i[27];
            7'd28 :
                split_cu_flag_r   =   mb_partition_i[28];
            7'd29 :
                split_cu_flag_r   =   mb_partition_i[29];
            7'd30 :
                split_cu_flag_r   =   mb_partition_i[30];
            7'd31 :
                split_cu_flag_r   =   mb_partition_i[31];
            7'd32 :
                split_cu_flag_r   =   mb_partition_i[32];
            7'd33 :
                split_cu_flag_r   =   mb_partition_i[33];
            7'd34 :
                split_cu_flag_r   =   mb_partition_i[34];
            7'd35 :
                split_cu_flag_r   =   mb_partition_i[35];
            7'd36 :
                split_cu_flag_r   =   mb_partition_i[36];
            7'd37 :
                split_cu_flag_r   =   mb_partition_i[37];
            7'd38 :
                split_cu_flag_r   =   mb_partition_i[38];
            7'd39 :
                split_cu_flag_r   =   mb_partition_i[39];
            7'd40 :
                split_cu_flag_r   =   mb_partition_i[40];
            7'd41 :
                split_cu_flag_r   =   mb_partition_i[41];
            7'd42 :
                split_cu_flag_r   =   mb_partition_i[42];
            7'd43 :
                split_cu_flag_r   =   mb_partition_i[43];
            7'd44 :
                split_cu_flag_r   =   mb_partition_i[44];
            7'd45 :
                split_cu_flag_r   =   mb_partition_i[45];
            7'd46 :
                split_cu_flag_r   =   mb_partition_i[46];
            7'd47 :
                split_cu_flag_r   =   mb_partition_i[47];
            7'd48 :
                split_cu_flag_r   =   mb_partition_i[48];
            7'd49 :
                split_cu_flag_r   =   mb_partition_i[49];
            7'd50 :
                split_cu_flag_r   =   mb_partition_i[50];
            7'd51 :
                split_cu_flag_r   =   mb_partition_i[51];
            7'd52 :
                split_cu_flag_r   =   mb_partition_i[52];
            7'd53 :
                split_cu_flag_r   =   mb_partition_i[53];
            7'd54 :
                split_cu_flag_r   =   mb_partition_i[54];
            7'd55 :
                split_cu_flag_r   =   mb_partition_i[55];
            7'd56 :
                split_cu_flag_r   =   mb_partition_i[56];
            7'd57 :
                split_cu_flag_r   =   mb_partition_i[57];
            7'd58 :
                split_cu_flag_r   =   mb_partition_i[58];
            7'd59 :
                split_cu_flag_r   =   mb_partition_i[59];
            7'd60 :
                split_cu_flag_r   =   mb_partition_i[60];
            7'd61 :
                split_cu_flag_r   =   mb_partition_i[61];
            7'd62 :
                split_cu_flag_r   =   mb_partition_i[62];
            7'd63 :
                split_cu_flag_r   =   mb_partition_i[63];
            7'd64 :
                split_cu_flag_r   =   mb_partition_i[64];
            7'd65 :
                split_cu_flag_r   =   mb_partition_i[65];
            7'd66 :
                split_cu_flag_r   =   mb_partition_i[66];
            7'd67 :
                split_cu_flag_r   =   mb_partition_i[67];
            7'd68 :
                split_cu_flag_r   =   mb_partition_i[68];
            7'd69 :
                split_cu_flag_r   =   mb_partition_i[69];
            7'd70 :
                split_cu_flag_r   =   mb_partition_i[70];
            7'd71 :
                split_cu_flag_r   =   mb_partition_i[71];
            7'd72 :
                split_cu_flag_r   =   mb_partition_i[72];
            7'd73 :
                split_cu_flag_r   =   mb_partition_i[73];
            7'd74 :
                split_cu_flag_r   =   mb_partition_i[74];
            7'd75 :
                split_cu_flag_r   =   mb_partition_i[75];
            7'd76 :
                split_cu_flag_r   =   mb_partition_i[76];
            7'd77 :
                split_cu_flag_r   =   mb_partition_i[77];
            7'd78 :
                split_cu_flag_r   =   mb_partition_i[78];
            7'd79 :
                split_cu_flag_r   =   mb_partition_i[79];
            7'd80 :
                split_cu_flag_r   =   mb_partition_i[80];
            7'd81 :
                split_cu_flag_r   =   mb_partition_i[81];
            7'd82 :
                split_cu_flag_r   =   mb_partition_i[82];
            7'd83 :
                split_cu_flag_r   =   mb_partition_i[83];
            7'd84 :
                split_cu_flag_r   =   mb_partition_i[84];
            default :
                split_cu_flag_r   =   1'b0               ;
        endcase
    end
    else
    begin
        case(cu_idx_r)
            7'd0  :
                split_cu_flag_r   =  (mb_p_pu_mode_i[  1:0  ]==2'd3 )  ;
            7'd1  :
                split_cu_flag_r   =  (mb_p_pu_mode_i[  3:2  ]==2'd3 )  ;
            7'd2  :
                split_cu_flag_r   =  (mb_p_pu_mode_i[  5:4  ]==2'd3 )  ;
            7'd3  :
                split_cu_flag_r   =  (mb_p_pu_mode_i[  7:6  ]==2'd3 )  ;
            7'd4  :
                split_cu_flag_r   =  (mb_p_pu_mode_i[  9:8  ]==2'd3 )  ;
            7'd5  :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 11:10 ]==2'd3 )  ;
            7'd6  :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 13:12 ]==2'd3 )  ;
            7'd7  :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 15:14 ]==2'd3 )  ;
            7'd8  :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 17:16 ]==2'd3 )  ;
            7'd9  :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 19:18 ]==2'd3 )  ;
            7'd10 :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 21:20 ]==2'd3 )  ;
            7'd11 :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 23:22 ]==2'd3 )  ;
            7'd12 :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 25:24 ]==2'd3 )  ;
            7'd13 :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 27:26 ]==2'd3 )  ;
            7'd14 :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 29:28 ]==2'd3 )  ;
            7'd15 :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 31:30 ]==2'd3 )  ;
            7'd16 :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 33:32 ]==2'd3 )  ;
            7'd17 :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 35:34 ]==2'd3 )  ;
            7'd18 :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 37:36 ]==2'd3 )  ;
            7'd19 :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 39:38 ]==2'd3 )  ;
            7'd20 :
                split_cu_flag_r   =  (mb_p_pu_mode_i[ 41:40 ]==2'd3 )  ;
            default :
                split_cu_flag_r   =  1'b0;
        endcase
    end
end

// cu_depth_r
always @*
begin
    if(cu_idx_r=='d0)                      //   cu_idx_r = 0
        cu_depth_r = 2'd0;
    else if(cu_idx_minus1_w[6:2]=='d0)     //   cu_idx_r = 4 3 2 1
        cu_depth_r = 2'd1;
    else if(cu_idx_minus5_w[6:4]=='d0)     //   cu_idx_r = 20 ...5
        cu_depth_r = 2'd2;
    else
        cu_depth_r = 2'd3;
end

/*------------------------------top  fsm, 64x64 -> 8x8--------------------------------------*/
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        lcu_curr_state_r <= LCU_IDLE        ;
    else
        lcu_curr_state_r <= lcu_next_state_r;
end

// LCU next state
always @*
begin
    lcu_next_state_r = LCU_IDLE;
    case(lcu_curr_state_r)
        LCU_IDLE:
        begin
            if(sys_start_i&&sys_mb_x_i==`PIC_X_WIDTH'd0 && sys_mb_y_i==`PIC_X_WIDTH'd0)
                lcu_next_state_r = LCU_INIT;
            else if(sys_start_i)
            begin
                if(`SAO_OPEN==1)
                    lcu_next_state_r = LCU_SAO ;//CU_SPLIT;
                else
                    lcu_next_state_r = CU_SPLIT;//CU_SPLIT;
            end
            else
                lcu_next_state_r = LCU_IDLE;
        end

        LCU_INIT:
        begin
            if(context_init_done_delay_r&&!context_init_done_i)
            begin
                if(`SAO_OPEN==1)
                    lcu_next_state_r = LCU_SAO ;//CU_SPLIT;
                else
                    lcu_next_state_r = CU_SPLIT;//CU_SPLIT;
            end
            else
                lcu_next_state_r = LCU_INIT;
        end

        LCU_SAO:
        begin
            if(lcu_cyc_cnt_r==4'd12)
                lcu_next_state_r  =  CU_SPLIT     ;
            else
                lcu_next_state_r  =  LCU_SAO      ;
        end

        CU_SPLIT:
        begin
            case(cu_depth_r)
                2'b00:
                begin                                   //64x64
                    if(split_cu_flag_r)
                        lcu_next_state_r = CU_SPLIT;
                    else
                        lcu_next_state_r = CU_64x64;
                end

                2'b01:
                begin                                   //32x32
                    if(split_cu_flag_r)
                        lcu_next_state_r = CU_SPLIT;
                    else
                        lcu_next_state_r = CU_32x32;
                end

                2'b10:
                begin                                   //16x16
                    if(split_cu_flag_r)
                        lcu_next_state_r = CU_8x8  ;
                    else
                        lcu_next_state_r = CU_16x16;
                end

                2'b11:
                begin                                    //8x8
                    lcu_next_state_r = CU_8x8;
                end
            endcase
        end

        CU_64x64:
        begin
            case({boundary_flag_w,cu_done_r})
                2'b00:
                    lcu_next_state_r = CU_64x64 ;
                default:
                    lcu_next_state_r = LCU_END;
            endcase
        end

        CU_32x32:
        begin
            case({boundary_flag_w,cu_done_r})
                2'b00:
                    lcu_next_state_r = CU_32x32 ;
                default:
                begin
                    if(cu_idx_r==7'd4)
                        lcu_next_state_r = LCU_END;
                    else
                        lcu_next_state_r = CU_SPLIT;
                end
            endcase
        end

        CU_16x16:
        begin
            case({boundary_flag_w,cu_done_r})
                2'b00:
                    lcu_next_state_r = CU_16x16 ;
                default:
                begin
                    if(cu_idx_r==7'd20)
                        lcu_next_state_r = LCU_END;
                    else
                        lcu_next_state_r = CU_SPLIT;
                end
            endcase
        end

        CU_8x8:
        begin
            case({boundary_flag_w,cu_done_r})
                2'b00:
                    lcu_next_state_r = CU_8x8 ;
                default:
                begin
                    if(cu_idx_r==7'd84)
                        lcu_next_state_r = LCU_END;
                    else if(cu_idx_minus21_w[1:0]==2'd3)
                        lcu_next_state_r = CU_SPLIT;
                    else
                        lcu_next_state_r = CU_8x8;
                end
            endcase
        end

        LCU_END:
        begin
            if(lcu_cyc_cnt_r==4'd13)
                lcu_next_state_r = LCU_IDLE;
            else
                lcu_next_state_r = LCU_END;
        end
        default:
        begin
            lcu_next_state_r = LCU_IDLE;
        end
    endcase
end


/*------------------------------top and left info--------------------------------------*/
//mb_skip_left_flag,store the last LCU's right row
reg                 cu_skip_left_0_r      ,  cu_skip_left_1_r       ;
reg                 cu_skip_left_2_r      ,  cu_skip_left_3_r       ;
reg                 cu_skip_left_4_r      ,  cu_skip_left_5_r       ;
reg                 cu_skip_left_6_r      ,  cu_skip_left_7_r       ;

always @*
begin
    if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
    begin         // 64x64
        cu_skip_left_0_r = mb_skip_flag_i[84]   ;
        cu_skip_left_1_r = mb_skip_flag_i[84]   ;
    end
    else if(mb_p_pu_mode_i[5:4]!=(`PART_SPLIT))
    begin     // 32x32
        cu_skip_left_0_r = mb_skip_flag_i[82]   ;
        cu_skip_left_1_r = mb_skip_flag_i[82]   ;
    end
    else if(mb_p_pu_mode_i[21:20]!=(`PART_SPLIT))
    begin    // 16x16
        cu_skip_left_0_r = mb_skip_flag_i[74]  ;
        cu_skip_left_1_r = mb_skip_flag_i[74]  ;
    end
    else
    begin                                                   // 8x8
        cu_skip_left_0_r = mb_skip_flag_i[42]  ;
        cu_skip_left_1_r = mb_skip_flag_i[40]  ;
    end
end

always @*
begin
    if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
    begin         // 64x64
        cu_skip_left_2_r = mb_skip_flag_i[84]   ;
        cu_skip_left_3_r = mb_skip_flag_i[84]   ;
    end
    else if(mb_p_pu_mode_i[5:4]!=(`PART_SPLIT))
    begin     // 32x32
        cu_skip_left_2_r = mb_skip_flag_i[82]   ;
        cu_skip_left_3_r = mb_skip_flag_i[82]   ;
    end
    else if(mb_p_pu_mode_i[25:24]!=(`PART_SPLIT))
    begin    // 16x16
        cu_skip_left_2_r = mb_skip_flag_i[72]  ;
        cu_skip_left_3_r = mb_skip_flag_i[72]   ;
    end
    else
    begin                                                   // 8x8
        cu_skip_left_2_r = mb_skip_flag_i[34]  ;
        cu_skip_left_3_r = mb_skip_flag_i[32]  ;
    end
end

always @*
begin
    if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
    begin         // 64x64
        cu_skip_left_4_r = mb_skip_flag_i[84]   ;
        cu_skip_left_5_r = mb_skip_flag_i[84]   ;
    end
    else if(mb_p_pu_mode_i[9:8]!=(`PART_SPLIT))
    begin     // 32x32
        cu_skip_left_4_r = mb_skip_flag_i[80]   ;
        cu_skip_left_5_r = mb_skip_flag_i[80]   ;
    end
    else if(mb_p_pu_mode_i[37:36]!=(`PART_SPLIT))
    begin    // 16x16
        cu_skip_left_4_r = mb_skip_flag_i[66]  ;
        cu_skip_left_5_r = mb_skip_flag_i[66]  ;
    end
    else
    begin                                                   // 8x8
        cu_skip_left_4_r = mb_skip_flag_i[10]  ;
        cu_skip_left_5_r = mb_skip_flag_i[8]  ;
    end
end

always @*
begin
    if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
    begin         // 64x64
        cu_skip_left_6_r = mb_skip_flag_i[84]   ;
        cu_skip_left_7_r = mb_skip_flag_i[84]   ;
    end
    else if(mb_p_pu_mode_i[9:8]!=(`PART_SPLIT))
    begin     // 32x32
        cu_skip_left_6_r = mb_skip_flag_i[80]   ;
        cu_skip_left_7_r = mb_skip_flag_i[80]   ;
    end
    else if(mb_p_pu_mode_i[41:40]!=(`PART_SPLIT))
    begin    // 16x16
        cu_skip_left_6_r = mb_skip_flag_i[64]  ;
        cu_skip_left_7_r = mb_skip_flag_i[64]  ;
    end
    else
    begin                                                   // 8x8
        cu_skip_left_6_r = mb_skip_flag_i[2]  ;
        cu_skip_left_7_r = mb_skip_flag_i[0]  ;
    end
end

//calculation the cu_depth used for luma mode left
reg    [1:0]        cu_depth_0_0_r  ,  cu_depth_0_2_r , cu_depth_0_4_r  ,  cu_depth_0_6_r  ;
reg    [1:0]        cu_depth_2_0_r  ,  cu_depth_2_2_r , cu_depth_2_4_r  ,  cu_depth_2_6_r  ;
reg    [1:0]        cu_depth_4_0_r  ,  cu_depth_4_2_r , cu_depth_4_4_r  ,  cu_depth_4_6_r  ;
reg    [1:0]        cu_depth_6_0_r  ,  cu_depth_6_2_r , cu_depth_6_4_r  ,  cu_depth_6_6_r  ;

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                   // 64x64 not split
            cu_depth_0_0_r  =  2'd0  ;
        else if(~mb_partition_i[1])              // 32x32 not split
            cu_depth_0_0_r  =  2'd1  ;
        else if(~mb_partition_i[5])              // 16x16 not split
            cu_depth_0_0_r  =  2'd2  ;
        else                                      // 8x8
            cu_depth_0_0_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_0_0_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[3:2]!=(`PART_SPLIT))
            cu_depth_0_0_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[11:10]!=(`PART_SPLIT))
            cu_depth_0_0_r  = 2'd2   ;
        else
            cu_depth_0_0_r  = 2'd3   ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                   // 64x64 not split
            cu_depth_0_2_r  =  2'd0  ;
        else if(~mb_partition_i[1])              // 32x32 not split
            cu_depth_0_2_r  =  2'd1  ;
        else if(~mb_partition_i[6])             // 16x16 not split
            cu_depth_0_2_r  =  2'd2  ;
        else                                      // 8x8
            cu_depth_0_2_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_0_2_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[3:2]!=(`PART_SPLIT))
            cu_depth_0_2_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[13:12]!=(`PART_SPLIT))
            cu_depth_0_2_r  = 2'd2   ;
        else
            cu_depth_0_2_r  = 2'd3   ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                   // 64x64 not split
            cu_depth_0_4_r  =  2'd0  ;
        else if(~mb_partition_i[2])              // 32x32 not split
            cu_depth_0_4_r  =  2'd1  ;
        else if(~mb_partition_i[9])             // 16x16 not split
            cu_depth_0_4_r  =  2'd2  ;
        else                                      // 8x8
            cu_depth_0_4_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_0_4_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[5:4]!=(`PART_SPLIT))
            cu_depth_0_4_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[19:18]!=(`PART_SPLIT))
            cu_depth_0_4_r  = 2'd2   ;
        else
            cu_depth_0_4_r  = 2'd3   ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                   // 64x64 not split
            cu_depth_0_6_r  =  2'd0  ;
        else if(~mb_partition_i[2])              // 32x32 not split
            cu_depth_0_6_r  =  2'd1  ;
        else if(~mb_partition_i[10])             // 16x16 not split
            cu_depth_0_6_r  =  2'd2  ;
        else                                      // 8x8
            cu_depth_0_6_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_0_6_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[5:4]!=(`PART_SPLIT))
            cu_depth_0_6_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[21:20]!=(`PART_SPLIT))
            cu_depth_0_6_r  = 2'd2   ;
        else
            cu_depth_0_6_r  = 2'd3   ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                   // 64x64 not split
            cu_depth_2_0_r  =  2'd0  ;
        else if(~mb_partition_i[1])              // 32x32 not split
            cu_depth_2_0_r  =  2'd1  ;
        else if(~mb_partition_i[7])             // 16x16 not split
            cu_depth_2_0_r  =  2'd2  ;
        else                                      // 8x8
            cu_depth_2_0_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_2_0_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[3:2]!=(`PART_SPLIT))
            cu_depth_2_0_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[15:14]!=(`PART_SPLIT))
            cu_depth_2_0_r  = 2'd2   ;
        else
            cu_depth_2_0_r  = 2'd3   ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                   // 64x64 not split
            cu_depth_2_2_r  =  2'd0  ;
        else if(~mb_partition_i[1])              // 32x32 not split
            cu_depth_2_2_r  =  2'd1  ;
        else if(~mb_partition_i[8])             // 16x16 not split
            cu_depth_2_2_r  =  2'd2  ;
        else                                      // 8x8
            cu_depth_2_2_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_2_2_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[3:2]!=(`PART_SPLIT))
            cu_depth_2_2_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[17:16]!=(`PART_SPLIT))
            cu_depth_2_2_r  = 2'd2   ;
        else
            cu_depth_2_2_r  = 2'd3   ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                   // 64x64 not split
            cu_depth_2_4_r  =  2'd0  ;
        else if(~mb_partition_i[2])              // 32x32 not split
            cu_depth_2_4_r  =  2'd1  ;
        else if(~mb_partition_i[11])             // 16x16 not split
            cu_depth_2_4_r  =  2'd2  ;
        else                                      // 8x8
            cu_depth_2_4_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_2_4_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[5:4]!=(`PART_SPLIT))
            cu_depth_2_4_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[23:22]!=(`PART_SPLIT))
            cu_depth_2_4_r  = 2'd2   ;
        else
            cu_depth_2_4_r  = 2'd3   ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                    // 64x64 not split
            cu_depth_2_6_r  =  2'd0  ;
        else if(~mb_partition_i[2])               // 32x32 not split
            cu_depth_2_6_r  =  2'd1  ;
        else if(~mb_partition_i[12])              // 16x16 not split
            cu_depth_2_6_r  =  2'd2  ;
        else                                       // 8x8
            cu_depth_2_6_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_2_6_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[5:4]!=(`PART_SPLIT))
            cu_depth_2_6_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[25:24]!=(`PART_SPLIT))
            cu_depth_2_6_r  = 2'd2   ;
        else
            cu_depth_2_6_r  = 2'd3   ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                   // 64x64 not split
            cu_depth_4_0_r  =  2'd0  ;
        else if(~mb_partition_i[3])              // 32x32 not split
            cu_depth_4_0_r  =  2'd1  ;
        else if(~mb_partition_i[13])             // 16x16 not split
            cu_depth_4_0_r  =  2'd2  ;
        else                                      // 8x8
            cu_depth_4_0_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_4_0_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[7:6]!=(`PART_SPLIT))
            cu_depth_4_0_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[27:26]!=(`PART_SPLIT))
            cu_depth_4_0_r  = 2'd2   ;
        else
            cu_depth_4_0_r  = 2'd3   ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                   // 64x64 not split
            cu_depth_4_2_r  =  2'd0  ;
        else if(~mb_partition_i[3])              // 32x32 not split
            cu_depth_4_2_r  =  2'd1  ;
        else if(~mb_partition_i[14])             // 16x16 not split
            cu_depth_4_2_r  =  2'd2  ;
        else                                      // 8x8
            cu_depth_4_2_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_4_2_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[7:6]!=(`PART_SPLIT))
            cu_depth_4_2_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[29:28]!=(`PART_SPLIT))
            cu_depth_4_2_r  = 2'd2   ;
        else
            cu_depth_4_2_r  = 2'd3   ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                   // 64x64 not split
            cu_depth_4_4_r  =  2'd0  ;
        else if(~mb_partition_i[4])              // 32x32 not split
            cu_depth_4_4_r  =  2'd1  ;
        else if(~mb_partition_i[17])             // 16x16 not split
            cu_depth_4_4_r  =  2'd2  ;
        else                                      // 8x8
            cu_depth_4_4_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_4_4_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[9:8]!=(`PART_SPLIT))
            cu_depth_4_4_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[35:34]!=(`PART_SPLIT))
            cu_depth_4_4_r  = 2'd2   ;
        else
            cu_depth_4_4_r  = 2'd3   ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                     // 64x64 not split
            cu_depth_4_6_r  =  2'd0  ;
        else if(~mb_partition_i[4])                // 32x32 not split
            cu_depth_4_6_r  =  2'd1  ;
        else if(~mb_partition_i[18])               // 16x16 not split
            cu_depth_4_6_r  =  2'd2  ;
        else                                        // 8x8
            cu_depth_4_6_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_4_6_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[9:8]!=(`PART_SPLIT))
            cu_depth_4_6_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[37:36]!=(`PART_SPLIT))
            cu_depth_4_6_r  = 2'd2   ;
        else
            cu_depth_4_6_r  = 2'd3   ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                             // 64x64
            cu_depth_6_0_r = 2'd0    ;
        else if(~mb_partition_i[3])                        // 32x32
            cu_depth_6_0_r = 2'd1    ;
        else if(~mb_partition_i[15])                       // 16x16
            cu_depth_6_0_r = 2'd2    ;
        else                                                // 8x8
            cu_depth_6_0_r = 2'd3    ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))         // 64x64
            cu_depth_6_0_r = 2'd0    ;
        else if(mb_p_pu_mode_i[7:6]!=(`PART_SPLIT))    // 32x32
            cu_depth_6_0_r = 2'd1    ;
        else if(mb_p_pu_mode_i[31:30]!=(`PART_SPLIT))  // 16x16
            cu_depth_6_0_r = 2'd2    ;
        else                                                 // 8x8
            cu_depth_6_0_r = 2'd3    ;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])
            cu_depth_6_2_r = 2'd0;
        else if(~mb_partition_i[3])
            cu_depth_6_2_r = 2'd1;
        else if(~mb_partition_i[16])
            cu_depth_6_2_r = 2'd2;
        else
            cu_depth_6_2_r = 2'd3;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_6_2_r = 2'd0;
        else if(mb_p_pu_mode_i[7:6]!=(`PART_SPLIT))
            cu_depth_6_2_r = 2'd1;
        else if(mb_p_pu_mode_i[33:32]!=(`PART_SPLIT))
            cu_depth_6_2_r = 2'd2;
        else
            cu_depth_6_2_r = 2'd3;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])
            cu_depth_6_4_r = 2'd0;
        else if(~mb_partition_i[4])
            cu_depth_6_4_r = 2'd1;
        else if(~mb_partition_i[19])
            cu_depth_6_4_r = 2'd2;
        else
            cu_depth_6_4_r = 2'd3;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_6_4_r = 2'd0;
        else if(mb_p_pu_mode_i[9:8]!=(`PART_SPLIT))
            cu_depth_6_4_r = 2'd1;
        else if(mb_p_pu_mode_i[39:38]!=(`PART_SPLIT))
            cu_depth_6_4_r = 2'd2;
        else
            cu_depth_6_4_r = 2'd3;
    end
end

always @*
begin
    if(sys_slice_type_i==(`SLICE_TYPE_I))
    begin
        if(~mb_partition_i[0])                      // 64x64 not split
            cu_depth_6_6_r  =  2'd0  ;
        else if(~mb_partition_i[4])                 // 32x32 not split
            cu_depth_6_6_r  =  2'd1  ;
        else if(~mb_partition_i[20])                // 16x16 not split
            cu_depth_6_6_r  =  2'd2  ;
        else                                         // 8x8
            cu_depth_6_6_r  =  2'd3  ;
    end
    else
    begin
        if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
            cu_depth_6_6_r  = 2'd0   ;
        else if(mb_p_pu_mode_i[9:8]!=(`PART_SPLIT))
            cu_depth_6_6_r  = 2'd1   ;
        else if(mb_p_pu_mode_i[41:40]!=(`PART_SPLIT))
            cu_depth_6_6_r  = 2'd2   ;
        else
            cu_depth_6_6_r  = 2'd3   ;
    end
end

//cu_start signal and its delay
reg  cu_start_r   ;
reg  cu_start_d1_r;
reg  cu_start_d2_r;//used in luma_mode_left store
reg  cu_start_d3_r;
wire cu_start_ori_w;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_start_r     <=  1'b0;
    else if(lcu_curr_state_r==CU_SPLIT && !lcu_next_state_r[2])     // split --> cu
        cu_start_r     <=  1'b1;
    else if(!lcu_curr_state_r[2]&&cu_done_r&&!lcu_next_state_r[2])  // cu    --> cu
        cu_start_r     <=  1'b1;
    else
        cu_start_r     <=  1'b0;
end

assign cu_start_ori_w = cu_start_r & (!boundary_flag_w);

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        cu_start_d1_r  <=   1'b0;
        cu_start_d2_r  <=   1'b0;
        cu_start_d3_r  <=   1'b0;
    end
    else
    begin
        cu_start_d1_r  <=   cu_start_ori_w   ;
        cu_start_d2_r  <=   cu_start_d1_r;
        cu_start_d3_r  <=   cu_start_d2_r;
    end
end

//cu_luma_mode_left_data
reg    [5:0]   cu_luma_mode_left_0_r  ;
reg    [5:0]   cu_luma_mode_left_1_r  ;
reg    [5:0]   cu_luma_mode_left_2_r  ;
reg    [5:0]   cu_luma_mode_left_3_r  ;
reg    [5:0]   cu_luma_mode_left_4_r  ;
reg    [5:0]   cu_luma_mode_left_5_r  ;
reg    [5:0]   cu_luma_mode_left_6_r  ;
reg    [5:0]   cu_luma_mode_left_7_r  ;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_luma_mode_left_0_r  <=  6'd1;
    else if(sys_mb_x_i==sys_total_x_i&&lcu_done_r)
        cu_luma_mode_left_0_r  <=  6'd1;
    else
    begin
        case(cu_depth_0_6_r )
            2'd0 :
                cu_luma_mode_left_0_r <= (cu_idx_r==7'd0 &&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_0_r;
            2'd1 :
                cu_luma_mode_left_0_r <= (cu_idx_r==7'd2 &&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_0_r;
            2'd2 :
                cu_luma_mode_left_0_r <= (cu_idx_r==7'd10&&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_0_r;
            2'd3 :
                cu_luma_mode_left_0_r <= (cu_idx_r==7'd42&&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_0_r;
        endcase
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_luma_mode_left_1_r   <=    6'd1;
    else if(sys_mb_x_i==sys_total_x_i&&lcu_done_r)
        cu_luma_mode_left_1_r   <=    6'd1;
    else
    begin
        case(cu_depth_0_6_r )
            2'd0 :
                cu_luma_mode_left_1_r <= (cu_idx_r==7'd0 &&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_1_r;
            2'd1 :
                cu_luma_mode_left_1_r <= (cu_idx_r==7'd2 &&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_1_r;
            2'd2 :
                cu_luma_mode_left_1_r <= (cu_idx_r==7'd10&&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_1_r;
            2'd3 :
                cu_luma_mode_left_1_r <= (cu_idx_r==7'd44&&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_1_r;
        endcase
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_luma_mode_left_2_r   <=    6'd1;
    else if(sys_mb_x_i==sys_total_x_i&&lcu_done_r)
        cu_luma_mode_left_2_r   <=    6'd1;
    else
    begin
        case(cu_depth_2_6_r )
            2'd0 :
                cu_luma_mode_left_2_r <= (cu_idx_r==7'd0 &&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_2_r;
            2'd1 :
                cu_luma_mode_left_2_r <= (cu_idx_r==7'd2 &&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_2_r;
            2'd2 :
                cu_luma_mode_left_2_r <= (cu_idx_r==7'd12&&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_2_r;
            2'd3 :
                cu_luma_mode_left_2_r <= (cu_idx_r==7'd50&&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_2_r;
        endcase
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_luma_mode_left_3_r   <=    6'd1;
    else if(sys_mb_x_i==sys_total_x_i&&lcu_done_r)
        cu_luma_mode_left_3_r   <=    6'd1;
    else
    begin
        case(cu_depth_2_6_r )
            2'd0 :
                cu_luma_mode_left_3_r <= (cu_idx_r==7'd0 &&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_3_r;
            2'd1 :
                cu_luma_mode_left_3_r <= (cu_idx_r==7'd2 &&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_3_r;
            2'd2 :
                cu_luma_mode_left_3_r <= (cu_idx_r==7'd12&&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_3_r;
            2'd3 :
                cu_luma_mode_left_3_r <= (cu_idx_r==7'd52&&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_3_r;
        endcase
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_luma_mode_left_4_r   <=    6'd1;
    else if(sys_mb_x_i==sys_total_x_i&&lcu_done_r)
        cu_luma_mode_left_4_r   <=    6'd1;
    else
    begin
        case(cu_depth_4_6_r )
            2'd0 :
                cu_luma_mode_left_4_r <= (cu_idx_r==7'd0 &&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_4_r;
            2'd1 :
                cu_luma_mode_left_4_r <= (cu_idx_r==7'd4 &&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_4_r;
            2'd2 :
                cu_luma_mode_left_4_r <= (cu_idx_r==7'd18&&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_4_r;
            2'd3 :
                cu_luma_mode_left_4_r <= (cu_idx_r==7'd74&&cu_start_d2_r) ?  mb_i_luma_mode_data_i :cu_luma_mode_left_4_r;
        endcase
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_luma_mode_left_5_r   <=    6'd1      ;
    else if(sys_mb_x_i==sys_total_x_i&&lcu_done_r)
        cu_luma_mode_left_5_r   <=    6'd1      ;
    else
    begin
        case(cu_depth_4_6_r )
            2'd0 :
                cu_luma_mode_left_5_r <= (cu_idx_r==7'd0 &&cu_start_d2_r) ? mb_i_luma_mode_data_i:cu_luma_mode_left_5_r;
            2'd1 :
                cu_luma_mode_left_5_r <= (cu_idx_r==7'd4 &&cu_start_d2_r) ? mb_i_luma_mode_data_i:cu_luma_mode_left_5_r;
            2'd2 :
                cu_luma_mode_left_5_r <= (cu_idx_r==7'd18&&cu_start_d2_r) ? mb_i_luma_mode_data_i:cu_luma_mode_left_5_r;
            2'd3 :
                cu_luma_mode_left_5_r <= (cu_idx_r==7'd76&&cu_start_d2_r) ? mb_i_luma_mode_data_i:cu_luma_mode_left_5_r;
        endcase
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_luma_mode_left_6_r   <=    6'd1      ;
    else if(sys_mb_x_i==sys_total_x_i&&lcu_done_r)
        cu_luma_mode_left_6_r   <=    6'd1      ;
    else
    begin
        case(cu_depth_6_6_r )
            2'd0 :
                cu_luma_mode_left_6_r <= (cu_idx_r==7'd0 &&cu_start_d2_r) ? mb_i_luma_mode_data_i :cu_luma_mode_left_6_r;
            2'd1 :
                cu_luma_mode_left_6_r <= (cu_idx_r==7'd4 &&cu_start_d2_r) ? mb_i_luma_mode_data_i :cu_luma_mode_left_6_r;
            2'd2 :
                cu_luma_mode_left_6_r <= (cu_idx_r==7'd20&&cu_start_d2_r) ? mb_i_luma_mode_data_i :cu_luma_mode_left_6_r;
            2'd3 :
                cu_luma_mode_left_6_r <= (cu_idx_r==7'd82&&cu_start_d2_r) ? mb_i_luma_mode_data_i :cu_luma_mode_left_6_r;
        endcase
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_luma_mode_left_7_r   <=    6'd1      ;
    else if(sys_mb_x_i==sys_total_x_i&&lcu_done_r)
        cu_luma_mode_left_7_r   <=    6'd1      ;
    else
    begin
        case(cu_depth_6_6_r )
            2'd0 :
                cu_luma_mode_left_7_r <= (cu_idx_r==7'd0 &&cu_start_d2_r) ? mb_i_luma_mode_data_i:cu_luma_mode_left_7_r;
            2'd1 :
                cu_luma_mode_left_7_r <= (cu_idx_r==7'd4 &&cu_start_d2_r) ? mb_i_luma_mode_data_i:cu_luma_mode_left_7_r;
            2'd2 :
                cu_luma_mode_left_7_r <= (cu_idx_r==7'd20&&cu_start_d2_r) ? mb_i_luma_mode_data_i:cu_luma_mode_left_7_r;
            2'd3 :
                cu_luma_mode_left_7_r <= (cu_idx_r==7'd84&&cu_start_d2_r) ? mb_i_luma_mode_data_i:cu_luma_mode_left_7_r;
        endcase
    end
end

//store the left data in cu_left_0...15_r
//------------------------------------
//include skip ,depth ,and luma mode
reg    [8:0]  cu_left_0_r;
reg    [8:0]  cu_left_1_r;
reg    [8:0]  cu_left_2_r;
reg    [8:0]  cu_left_3_r;
reg    [8:0]  cu_left_4_r;
reg    [8:0]  cu_left_5_r;
reg    [8:0]  cu_left_6_r;
reg    [8:0]  cu_left_7_r;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        cu_left_0_r  <=   9'd1;
        cu_left_1_r  <=   9'd1;
        cu_left_2_r  <=   9'd1;
        cu_left_3_r  <=   9'd1;
        cu_left_4_r  <=   9'd1;
        cu_left_5_r  <=   9'd1;
        cu_left_6_r  <=   9'd1;
        cu_left_7_r  <=   9'd1;
    end
    else if(lcu_curr_state_r == LCU_END)
    begin
        cu_left_0_r  <=   {cu_skip_left_0_r,cu_luma_mode_left_0_r ,cu_depth_0_6_r};
        cu_left_1_r  <=   {cu_skip_left_1_r,cu_luma_mode_left_1_r ,cu_depth_0_6_r};
        cu_left_2_r  <=   {cu_skip_left_2_r,cu_luma_mode_left_2_r ,cu_depth_2_6_r};
        cu_left_3_r  <=   {cu_skip_left_3_r,cu_luma_mode_left_3_r ,cu_depth_2_6_r};
        cu_left_4_r  <=   {cu_skip_left_4_r,cu_luma_mode_left_4_r ,cu_depth_4_6_r};
        cu_left_5_r  <=   {cu_skip_left_5_r,cu_luma_mode_left_5_r,cu_depth_4_6_r};
        cu_left_6_r  <=   {cu_skip_left_6_r,cu_luma_mode_left_6_r,cu_depth_6_6_r};
        cu_left_7_r  <=   {cu_skip_left_7_r,cu_luma_mode_left_7_r,cu_depth_6_6_r};
    end
    else
    begin
        cu_left_0_r   <=   cu_left_0_r ;
        cu_left_1_r   <=   cu_left_1_r ;
        cu_left_2_r   <=   cu_left_2_r ;
        cu_left_3_r   <=   cu_left_3_r ;
        cu_left_4_r   <=   cu_left_4_r ;
        cu_left_5_r   <=   cu_left_5_r;
        cu_left_6_r   <=   cu_left_6_r;
        cu_left_7_r   <=   cu_left_7_r;
    end
end

// cu_skip_top_flag is the current lcu's bottom flag
reg                 cu_skip_top_0_r    ,  cu_skip_top_1_r    ;
reg                 cu_skip_top_2_r    ,  cu_skip_top_3_r    ;
reg                 cu_skip_top_4_r    ,  cu_skip_top_5_r    ;
reg                 cu_skip_top_6_r    ,  cu_skip_top_7_r    ;

always @*
begin
    if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
    begin         // 64x64
        cu_skip_top_0_r = mb_skip_flag_i[84]   ;
        cu_skip_top_1_r = mb_skip_flag_i[84]   ;
    end
    else if(mb_p_pu_mode_i[7:6]!=(`PART_SPLIT))
    begin     // 32x32
        cu_skip_top_0_r = mb_skip_flag_i[81]   ;
        cu_skip_top_1_r = mb_skip_flag_i[81]   ;
    end
    else if(mb_p_pu_mode_i[31:30]!=(`PART_SPLIT))
    begin    // 16x16
        cu_skip_top_0_r = mb_skip_flag_i[69]  ;
        cu_skip_top_1_r = mb_skip_flag_i[69]   ;
    end
    else
    begin                                                   // 8x8
        cu_skip_top_0_r = mb_skip_flag_i[21]  ;
        cu_skip_top_1_r = mb_skip_flag_i[20]  ;
    end
end

always @*
begin
    if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
    begin         // 64x64
        cu_skip_top_2_r = mb_skip_flag_i[84]   ;
        cu_skip_top_3_r = mb_skip_flag_i[84]   ;
    end
    else if(mb_p_pu_mode_i[7:6]!=(`PART_SPLIT))
    begin     // 32x32
        cu_skip_top_2_r = mb_skip_flag_i[81]   ;
        cu_skip_top_3_r = mb_skip_flag_i[81]   ;
    end
    else if(mb_p_pu_mode_i[33:32]!=(`PART_SPLIT))
    begin    // 16x16
        cu_skip_top_2_r = mb_skip_flag_i[68]  ;
        cu_skip_top_3_r = mb_skip_flag_i[68]   ;
    end
    else
    begin                                                   // 8x8
        cu_skip_top_2_r = mb_skip_flag_i[17]  ;
        cu_skip_top_3_r = mb_skip_flag_i[16]  ;
    end
end

always @*
begin
    if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
    begin         // 64x64
        cu_skip_top_4_r = mb_skip_flag_i[84]   ;
        cu_skip_top_5_r = mb_skip_flag_i[84]   ;
    end
    else if(mb_p_pu_mode_i[9:8]!=(`PART_SPLIT))
    begin     // 32x32
        cu_skip_top_4_r = mb_skip_flag_i[80]   ;
        cu_skip_top_5_r = mb_skip_flag_i[80]   ;
    end
    else if(mb_p_pu_mode_i[39:38]!=(`PART_SPLIT))
    begin    // 16x16
        cu_skip_top_4_r = mb_skip_flag_i[65]  ;
        cu_skip_top_5_r = mb_skip_flag_i[65]  ;
    end
    else
    begin                                                   // 8x8
        cu_skip_top_4_r = mb_skip_flag_i[5]  ;
        cu_skip_top_5_r = mb_skip_flag_i[4]  ;
    end
end

always @*
begin
    if(mb_p_pu_mode_i[1:0]!=(`PART_SPLIT))
    begin         // 64x64
        cu_skip_top_6_r = mb_skip_flag_i[84]   ;
        cu_skip_top_7_r = mb_skip_flag_i[84]   ;
    end
    else if(mb_p_pu_mode_i[9:8]!=(`PART_SPLIT))
    begin     // 32x32
        cu_skip_top_6_r = mb_skip_flag_i[80]   ;
        cu_skip_top_7_r = mb_skip_flag_i[80]   ;
    end
    else if(mb_p_pu_mode_i[41:40]!=(`PART_SPLIT))
    begin    // 16x16
        cu_skip_top_6_r = mb_skip_flag_i[64]  ;
        cu_skip_top_7_r = mb_skip_flag_i[64]  ;
    end
    else
    begin                                                   // 8x8
        cu_skip_top_6_r = mb_skip_flag_i[1]  ;
        cu_skip_top_7_r = mb_skip_flag_i[0]  ;
    end
end


/*----------------------------store the top data in memory,include skip ,depth----------------------------------*/
reg                     r_en_neigh_r                ;   //read  memory of neighbour info enable
reg                     w_en_neigh_r                ;   //write memory of neighbour info enable

wire    [15:0]          r_data_neigh_mb_w           ;   //read  data of top LCU
wire    [15:0]          w_data_neigh_mb_w           ;   //write data of top LCU
reg     [15:0]          r_data_neigh_mb_r           ;   //read  data of top LCU

/*
rfsphd_64x16 rfsphd_64x16_nb_u0(
    .Q(r_data_neigh_mb_w),
    .CLK(clk),
    .CEN(1'b0),
    .WEN(w_en_neigh_r),
    .A(sys_mb_x_i),
    .D(w_data_neigh_mb_w),
    .EMA(3'd0),
    .EMAW(2'd0),
    .RET1N(rst_n)
);
*/
cabac_ram_sp_64x16 u_cabac_ram_sp_64x16(
                       .clk      ( clk               ),
                       .cen_i    ( 1'b0              ),
                       .wen_i    ( w_en_neigh_r      ), // low active
                       .addr_i   ( sys_mb_x_i        ), // low active
                       .data_i   ( w_data_neigh_mb_w ),
                       .data_o   ( r_data_neigh_mb_w )
                   );


// r_en_neigh_r
always @*
begin
    if(sys_start_i)
        r_en_neigh_r  =   (sys_mb_y_i==0);
    else
        r_en_neigh_r  =   1'b1   ;
end

// w_en_neigh_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        w_en_neigh_r <=    1'b1  ;
    else if(lcu_done_r)
        w_en_neigh_r <=    1'b0  ;
    else
        w_en_neigh_r <=    1'b1  ;
end

// w_data_neigh_mb_w
assign w_data_neigh_mb_w = {cu_depth_6_0_r  ,cu_depth_6_2_r   ,cu_depth_6_4_r   ,cu_depth_6_6_r    ,
                            cu_skip_top_0_r ,cu_skip_top_1_r  ,cu_skip_top_2_r  ,cu_skip_top_3_r   ,
                            cu_skip_top_4_r ,cu_skip_top_5_r  ,cu_skip_top_6_r  ,cu_skip_top_7_r  };

//r_data_neigh_mb_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        r_data_neigh_mb_r      <=   16'd0                  ;
    else if(!r_en_neigh_r)
        r_data_neigh_mb_r      <=   r_data_neigh_mb_w      ;
    else
        r_data_neigh_mb_r      <=   r_data_neigh_mb_r      ;
end


/*-----------------------------------get all ses's data ------------------------------------------*/
reg            split_transform_flag_r     ;
reg    [1:0 ]  cu_inter_part_size_r       ;
reg            cu_merge_flag_r            ;
reg    [3:0]   cu_merge_idx_r             ;
reg    [3:0 ]  cu_cbf_y_r                 ;
reg    [3:0 ]  cu_cbf_u_r                 ;
reg    [3:0 ]  cu_cbf_v_r                 ;
reg            cu_skip_flag_r             ;
reg            cu_skip_top_flag_r         ;
reg            cu_skip_left_flag_r        ;

reg    [1:0 ]  cu_depth_top_r             ;
reg    [1:0 ]  cu_depth_left_r            ;

reg            cu_mvd_ren_r               ; // read mvd enable
reg    [5:0 ]  cu_mvd_raddr_r             ; // address of  mvd

reg    [(4*`MVD_WIDTH)+1:0]  cu_mvd_data_r;


reg    [ 5:0]  cu_luma_mode_raddr_r       ;
reg    [ 5:0]  cu_luma_top_mode_raddr_r   ;
reg    [ 5:0]  cu_luma_left_mode_raddr_r  ;

reg    [ 5:0]  cu_luma_pred_mode_r        ;
reg    [23:0]  cu_luma_pred_top_mode_r    ;
reg    [23:0]  cu_luma_pred_left_mode_r   ;
//reg    [ 5:0]  cu_chroma_pred_mode_r      ;

// split_transform_flag_r : 1 split not encoding ,0 not split but encoding
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        split_transform_flag_r   <=  1'b0   ;
    else
    begin
        case(cu_depth_r)
            2'd0:
                split_transform_flag_r   <=  1'b1            ;
            2'd1:
                split_transform_flag_r   <=  1'b0            ;
            2'd2:
                split_transform_flag_r   <=  1'b0            ;
            2'd3:
                split_transform_flag_r   <=  split_cu_flag_r ;
        endcase
    end
end

// cu_inter_part_size_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_inter_part_size_r <= (`PART_2NX2N);
    else
    begin
        case(cu_idx_r)
            7'd0  :
                cu_inter_part_size_r <= mb_p_pu_mode_i[ 1: 0];
            7'd1  :
                cu_inter_part_size_r <= mb_p_pu_mode_i[ 3: 2];
            7'd2  :
                cu_inter_part_size_r <= mb_p_pu_mode_i[ 5: 4];
            7'd3  :
                cu_inter_part_size_r <= mb_p_pu_mode_i[ 7: 6];
            7'd4  :
                cu_inter_part_size_r <= mb_p_pu_mode_i[ 9: 8];
            7'd5  :
                cu_inter_part_size_r <= mb_p_pu_mode_i[11:10];
            7'd6  :
                cu_inter_part_size_r <= mb_p_pu_mode_i[13:12];
            7'd7  :
                cu_inter_part_size_r <= mb_p_pu_mode_i[15:14];
            7'd8  :
                cu_inter_part_size_r <= mb_p_pu_mode_i[17:16];
            7'd9  :
                cu_inter_part_size_r <= mb_p_pu_mode_i[19:18];
            7'd10 :
                cu_inter_part_size_r <= mb_p_pu_mode_i[21:20];
            7'd11 :
                cu_inter_part_size_r <= mb_p_pu_mode_i[23:22];
            7'd12 :
                cu_inter_part_size_r <= mb_p_pu_mode_i[25:24];
            7'd13 :
                cu_inter_part_size_r <= mb_p_pu_mode_i[27:26];
            7'd14 :
                cu_inter_part_size_r <= mb_p_pu_mode_i[29:28];
            7'd15 :
                cu_inter_part_size_r <= mb_p_pu_mode_i[31:30];
            7'd16 :
                cu_inter_part_size_r <= mb_p_pu_mode_i[33:32];
            7'd17 :
                cu_inter_part_size_r <= mb_p_pu_mode_i[35:34];
            7'd18 :
                cu_inter_part_size_r <= mb_p_pu_mode_i[37:36];
            7'd19 :
                cu_inter_part_size_r <= mb_p_pu_mode_i[39:38];
            7'd20 :
                cu_inter_part_size_r <= mb_p_pu_mode_i[41:40];
            default:
                cu_inter_part_size_r <= (`PART_2NX2N)              ;
        endcase
    end
end

// cu_merge_flag_r , cu_merge_idx_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        cu_merge_flag_r           <=      1'b0    ;
        cu_merge_idx_r            <=      4'b0   ;
    end
    else
    begin
        case(cu_idx_r)
            7'd0  :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[84];
                cu_merge_idx_r <= mb_merge_idx_i[339:336];
            end
            7'd1  :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[83];
                cu_merge_idx_r <= mb_merge_idx_i[335:332];
            end
            7'd2  :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[82];
                cu_merge_idx_r <= mb_merge_idx_i[331:328];
            end
            7'd3  :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[81];
                cu_merge_idx_r <= mb_merge_idx_i[327:324];
            end
            7'd4  :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[80];
                cu_merge_idx_r <= mb_merge_idx_i[ 323: 320];
            end
            7'd5  :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[79];
                cu_merge_idx_r <= mb_merge_idx_i[319:316];
            end
            7'd6  :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[78];
                cu_merge_idx_r <= mb_merge_idx_i[315:312];
            end
            7'd7  :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[77];
                cu_merge_idx_r <= mb_merge_idx_i[311:308];
            end
            7'd8  :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[76];
                cu_merge_idx_r <= mb_merge_idx_i[307:304];
            end
            7'd9  :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[75];
                cu_merge_idx_r <= mb_merge_idx_i[303:300];
            end
            7'd10 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[74];
                cu_merge_idx_r <= mb_merge_idx_i[299:296];
            end
            7'd11 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[73];
                cu_merge_idx_r <= mb_merge_idx_i[295:292];
            end
            7'd12 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[72];
                cu_merge_idx_r <= mb_merge_idx_i[291:288];
            end
            7'd13 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[71];
                cu_merge_idx_r <= mb_merge_idx_i[287:284];
            end
            7'd14 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[70];
                cu_merge_idx_r <= mb_merge_idx_i[283:280];
            end
            7'd15 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[69];
                cu_merge_idx_r <= mb_merge_idx_i[ 279: 276];
            end
            7'd16 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[68];
                cu_merge_idx_r <= mb_merge_idx_i[ 275: 272];
            end
            7'd17 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[67];
                cu_merge_idx_r <= mb_merge_idx_i[ 271: 268];
            end
            7'd18 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[66];
                cu_merge_idx_r <= mb_merge_idx_i[ 267: 264];
            end
            7'd19 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[65];
                cu_merge_idx_r <= mb_merge_idx_i[ 263: 260];
            end
            7'd20 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[64];
                cu_merge_idx_r <= mb_merge_idx_i[ 259: 256];
            end
            7'd21 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[63];
                cu_merge_idx_r <= mb_merge_idx_i[255:252];
            end
            7'd22 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[62];
                cu_merge_idx_r <= mb_merge_idx_i[251:248];
            end
            7'd23 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[61];
                cu_merge_idx_r <= mb_merge_idx_i[247:244];
            end
            7'd24 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[60];
                cu_merge_idx_r <= mb_merge_idx_i[243:240];
            end
            7'd25 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[59];
                cu_merge_idx_r <= mb_merge_idx_i[239:236];
            end
            7'd26 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[58];
                cu_merge_idx_r <= mb_merge_idx_i[235:232];
            end
            7'd27 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[57];
                cu_merge_idx_r <= mb_merge_idx_i[231:228];
            end
            7'd28 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[56];
                cu_merge_idx_r <= mb_merge_idx_i[227:224];
            end
            7'd29 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[55];
                cu_merge_idx_r <= mb_merge_idx_i[223:220];
            end
            7'd30 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[54];
                cu_merge_idx_r <= mb_merge_idx_i[219:216];
            end
            7'd31 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[53];
                cu_merge_idx_r <= mb_merge_idx_i[215:212];
            end
            7'd32 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[52];
                cu_merge_idx_r <= mb_merge_idx_i[211:208];
            end
            7'd33 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[51];
                cu_merge_idx_r <= mb_merge_idx_i[207:204];
            end
            7'd34 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[50];
                cu_merge_idx_r <= mb_merge_idx_i[203:200];
            end
            7'd35 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[49];
                cu_merge_idx_r <= mb_merge_idx_i[199:196];
            end
            7'd36 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[48];
                cu_merge_idx_r <= mb_merge_idx_i[195:192];
            end
            7'd37 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[47];
                cu_merge_idx_r <= mb_merge_idx_i[191:188];
            end
            7'd38 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[46];
                cu_merge_idx_r <= mb_merge_idx_i[187:184];
            end
            7'd39 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[45];
                cu_merge_idx_r <= mb_merge_idx_i[183:180];
            end
            7'd40 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[44];
                cu_merge_idx_r <= mb_merge_idx_i[179:176];
            end
            7'd41 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[43];
                cu_merge_idx_r <= mb_merge_idx_i[175:172];
            end
            7'd42 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[42];
                cu_merge_idx_r <= mb_merge_idx_i[171:168];
            end
            7'd43 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[41];
                cu_merge_idx_r <= mb_merge_idx_i[167:164];
            end
            7'd44 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[40];
                cu_merge_idx_r <= mb_merge_idx_i[163:160];
            end
            7'd45 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[39];
                cu_merge_idx_r <= mb_merge_idx_i[159:156];
            end
            7'd46 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[38];
                cu_merge_idx_r <= mb_merge_idx_i[155:152];
            end
            7'd47 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[37];
                cu_merge_idx_r <= mb_merge_idx_i[151:148];
            end
            7'd48 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[36];
                cu_merge_idx_r <= mb_merge_idx_i[147:144];
            end
            7'd49 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[35];
                cu_merge_idx_r <= mb_merge_idx_i[143:140];
            end
            7'd50 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[34];
                cu_merge_idx_r <= mb_merge_idx_i[139:136];
            end
            7'd51 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[33];
                cu_merge_idx_r <= mb_merge_idx_i[135:132];
            end
            7'd52 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[32];
                cu_merge_idx_r <= mb_merge_idx_i[131:128];
            end
            7'd53 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[31];
                cu_merge_idx_r <= mb_merge_idx_i[127:124];
            end
            7'd54 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[30];
                cu_merge_idx_r <= mb_merge_idx_i[123:120];
            end
            7'd55 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[29];
                cu_merge_idx_r <= mb_merge_idx_i[119:116];
            end
            7'd56 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[28];
                cu_merge_idx_r <= mb_merge_idx_i[115:112];
            end
            7'd57 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[27];
                cu_merge_idx_r <= mb_merge_idx_i[111:108];
            end
            7'd58 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[26];
                cu_merge_idx_r <= mb_merge_idx_i[107:104];
            end
            7'd59 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[25];
                cu_merge_idx_r <= mb_merge_idx_i[103:100];
            end
            7'd60 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[24];
                cu_merge_idx_r <= mb_merge_idx_i[ 99: 96];
            end
            7'd61 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[23];
                cu_merge_idx_r <= mb_merge_idx_i[ 95: 92];
            end
            7'd62 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[22];
                cu_merge_idx_r <= mb_merge_idx_i[ 91: 88];
            end
            7'd63 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[21];
                cu_merge_idx_r <= mb_merge_idx_i[ 87: 84];
            end
            7'd64 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[20];
                cu_merge_idx_r <= mb_merge_idx_i[ 83: 80];
            end
            7'd65 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[19];
                cu_merge_idx_r <= mb_merge_idx_i[ 79: 76];
            end
            7'd66 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[18];
                cu_merge_idx_r <= mb_merge_idx_i[ 75: 72];
            end
            7'd67 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[17];
                cu_merge_idx_r <= mb_merge_idx_i[ 71: 68];
            end
            7'd68 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[16];
                cu_merge_idx_r <= mb_merge_idx_i[ 67: 64];
            end
            7'd69 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[15];
                cu_merge_idx_r <= mb_merge_idx_i[ 63: 60];
            end
            7'd70 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[14];
                cu_merge_idx_r <= mb_merge_idx_i[ 59: 56];
            end
            7'd71 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[13];
                cu_merge_idx_r <= mb_merge_idx_i[ 55: 52];
            end
            7'd72 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[12];
                cu_merge_idx_r <= mb_merge_idx_i[ 51: 48];
            end
            7'd73 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[11];
                cu_merge_idx_r <= mb_merge_idx_i[ 47: 44];
            end
            7'd74 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[10];
                cu_merge_idx_r <= mb_merge_idx_i[ 43: 40];
            end
            7'd75 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[ 9];
                cu_merge_idx_r <= mb_merge_idx_i[ 39: 36];
            end
            7'd76 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[ 8];
                cu_merge_idx_r <= mb_merge_idx_i[ 35: 32];
            end
            7'd77 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[ 7];
                cu_merge_idx_r <= mb_merge_idx_i[ 31: 28];
            end
            7'd78 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[ 6];
                cu_merge_idx_r <= mb_merge_idx_i[ 27: 24];
            end
            7'd79 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[ 5];
                cu_merge_idx_r <= mb_merge_idx_i[ 23: 20];
            end
            7'd80 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[ 4];
                cu_merge_idx_r <= mb_merge_idx_i[ 19: 16];
            end
            7'd81 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[ 3];
                cu_merge_idx_r <= mb_merge_idx_i[ 15: 12];
            end
            7'd82 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[ 2];
                cu_merge_idx_r <= mb_merge_idx_i[ 11:  8];
            end
            7'd83 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[ 1];
                cu_merge_idx_r <= mb_merge_idx_i[  7:  4];
            end
            7'd84 :
            begin
                cu_merge_flag_r <= mb_merge_flag_i[ 0];
                cu_merge_idx_r <= mb_merge_idx_i[  3:  0];
            end
            default :
            begin
                cu_merge_flag_r <=  1'b0                ;
                cu_merge_idx_r <= 4'b0                    ;
            end
        endcase
    end
end

// cu_cbf_y_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_cbf_y_r   <=  4'b0   ;
    else
    begin
        case(cu_idx_r)
            7'd0  :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[ 63:0  ]==0),!(mb_cbf_y_i[127:64 ]==0),!(mb_cbf_y_i[191:128]==0),!(mb_cbf_y_i[255:192]==0)};
            end // 64x64
            7'd1  :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[ 15:0  ]==0),!(mb_cbf_y_i[ 31:16 ]==0),!(mb_cbf_y_i[ 47:32 ]==0),!(mb_cbf_y_i[ 63:48 ]==0)};
            end // 32x32
            7'd2  :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[ 79:64 ]==0),!(mb_cbf_y_i[ 95:80 ]==0),!(mb_cbf_y_i[111:96 ]==0),!(mb_cbf_y_i[127:112]==0)};
            end
            7'd3  :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[143:128]==0),!(mb_cbf_y_i[159:144]==0),!(mb_cbf_y_i[175:160]==0),!(mb_cbf_y_i[191:176]==0)};
            end
            7'd4  :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[207:192]==0),!(mb_cbf_y_i[223:208]==0),!(mb_cbf_y_i[239:224]==0),!(mb_cbf_y_i[255:240]==0)};
            end
            7'd5  :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[  3:0  ]==0),!(mb_cbf_y_i[  7:4  ]==0),!(mb_cbf_y_i[ 11:8  ]==0),!(mb_cbf_y_i[ 15:12 ]==0)};
            end // 16x16
            7'd6  :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[ 19:16 ]==0),!(mb_cbf_y_i[ 23:20 ]==0),!(mb_cbf_y_i[ 27:24 ]==0),!(mb_cbf_y_i[ 31:28 ]==0)};
            end
            7'd7  :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[ 35:32 ]==0),!(mb_cbf_y_i[ 39:36 ]==0),!(mb_cbf_y_i[ 43:40 ]==0),!(mb_cbf_y_i[ 47:44 ]==0)};
            end
            7'd8  :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[ 51:48 ]==0),!(mb_cbf_y_i[ 55:52 ]==0),!(mb_cbf_y_i[ 59:56 ]==0),!(mb_cbf_y_i[ 63:60 ]==0)};
            end
            7'd9  :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[ 67:64 ]==0),!(mb_cbf_y_i[ 71:68 ]==0),!(mb_cbf_y_i[ 75:72 ]==0),!(mb_cbf_y_i[ 79:76 ]==0)};
            end
            7'd10 :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[ 83:80 ]==0),!(mb_cbf_y_i[ 87:84 ]==0),!(mb_cbf_y_i[ 91:88 ]==0),!(mb_cbf_y_i[ 95:92 ]==0)};
            end
            7'd11 :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[ 99:96 ]==0),!(mb_cbf_y_i[103:100]==0),!(mb_cbf_y_i[107:104]==0),!(mb_cbf_y_i[111:108]==0)};
            end
            7'd12 :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[115:112]==0),!(mb_cbf_y_i[119:116]==0),!(mb_cbf_y_i[123:120]==0),!(mb_cbf_y_i[127:124]==0)};
            end
            7'd13 :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[131:128]==0),!(mb_cbf_y_i[135:132]==0),!(mb_cbf_y_i[139:136]==0),!(mb_cbf_y_i[143:140]==0)};
            end
            7'd14 :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[147:144]==0),!(mb_cbf_y_i[151:148]==0),!(mb_cbf_y_i[155:152]==0),!(mb_cbf_y_i[159:156]==0)};
            end
            7'd15 :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[163:160]==0),!(mb_cbf_y_i[167:164]==0),!(mb_cbf_y_i[171:168]==0),!(mb_cbf_y_i[175:172]==0)};
            end
            7'd16 :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[179:176]==0),!(mb_cbf_y_i[183:180]==0),!(mb_cbf_y_i[187:184]==0),!(mb_cbf_y_i[191:188]==0)};
            end
            7'd17 :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[195:192]==0),!(mb_cbf_y_i[199:196]==0),!(mb_cbf_y_i[203:200]==0),!(mb_cbf_y_i[207:204]==0)};
            end
            7'd18 :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[211:208]==0),!(mb_cbf_y_i[215:212]==0),!(mb_cbf_y_i[219:216]==0),!(mb_cbf_y_i[223:220]==0)};
            end
            7'd19 :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[227:224]==0),!(mb_cbf_y_i[231:228]==0),!(mb_cbf_y_i[235:232]==0),!(mb_cbf_y_i[239:236]==0)};
            end
            7'd20 :
            begin
                cu_cbf_y_r <= {!(mb_cbf_y_i[243:240]==0),!(mb_cbf_y_i[247:244]==0),!(mb_cbf_y_i[251:248]==0),!(mb_cbf_y_i[255:252]==0)};
            end
            7'd21 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 0  ],    mb_cbf_y_i[ 1  ],    mb_cbf_y_i[ 2  ],    mb_cbf_y_i[ 3  ]};
            end // 8x8
            7'd22 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 4  ],    mb_cbf_y_i[ 5  ],    mb_cbf_y_i[ 6  ],    mb_cbf_y_i[ 7  ]};
            end
            7'd23 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 8  ],    mb_cbf_y_i[ 9  ],    mb_cbf_y_i[ 10 ],    mb_cbf_y_i[ 11 ]};
            end
            7'd24 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 12 ],    mb_cbf_y_i[ 13 ],    mb_cbf_y_i[ 14 ],    mb_cbf_y_i[ 15 ]};
            end
            7'd25 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 16 ],    mb_cbf_y_i[ 17 ],    mb_cbf_y_i[ 18 ],    mb_cbf_y_i[ 19 ]};
            end
            7'd26 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 20 ],    mb_cbf_y_i[ 21 ],    mb_cbf_y_i[ 22 ],    mb_cbf_y_i[ 23 ]};
            end
            7'd27 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 24 ],    mb_cbf_y_i[ 25 ],    mb_cbf_y_i[ 26 ],    mb_cbf_y_i[ 27 ]};
            end
            7'd28 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 28 ],    mb_cbf_y_i[ 29 ],    mb_cbf_y_i[ 30 ],    mb_cbf_y_i[ 31 ]};
            end
            7'd29 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 32 ],    mb_cbf_y_i[ 33 ],    mb_cbf_y_i[ 34 ],    mb_cbf_y_i[ 35 ]};
            end
            7'd30 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 36 ],    mb_cbf_y_i[ 37 ],    mb_cbf_y_i[ 38 ],    mb_cbf_y_i[ 39 ]};
            end
            7'd31 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 40 ],    mb_cbf_y_i[ 41 ],    mb_cbf_y_i[ 42 ],    mb_cbf_y_i[ 43 ]};
            end
            7'd32 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 44 ],    mb_cbf_y_i[ 45 ],    mb_cbf_y_i[ 46 ],    mb_cbf_y_i[ 47 ]};
            end
            7'd33 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 48 ],    mb_cbf_y_i[ 49 ],    mb_cbf_y_i[ 50 ],    mb_cbf_y_i[ 51 ]};
            end
            7'd34 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 52 ],    mb_cbf_y_i[ 53 ],    mb_cbf_y_i[ 54 ],    mb_cbf_y_i[ 55 ]};
            end
            7'd35 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 56 ],    mb_cbf_y_i[ 57 ],    mb_cbf_y_i[ 58 ],    mb_cbf_y_i[ 59 ]};
            end
            7'd36 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 60 ],    mb_cbf_y_i[ 61 ],    mb_cbf_y_i[ 62 ],    mb_cbf_y_i[ 63 ]};
            end
            7'd37 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 64 ],    mb_cbf_y_i[ 65 ],    mb_cbf_y_i[ 66 ],    mb_cbf_y_i[ 67 ]};
            end
            7'd38 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 68 ],    mb_cbf_y_i[ 69 ],    mb_cbf_y_i[ 70 ],    mb_cbf_y_i[ 71 ]};
            end
            7'd39 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 72 ],    mb_cbf_y_i[ 73 ],    mb_cbf_y_i[ 74 ],    mb_cbf_y_i[ 75 ]};
            end
            7'd40 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 76 ],    mb_cbf_y_i[ 77 ],    mb_cbf_y_i[ 78 ],    mb_cbf_y_i[ 79 ]};
            end
            7'd41 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 80 ],    mb_cbf_y_i[ 81 ],    mb_cbf_y_i[ 82 ],    mb_cbf_y_i[ 83 ]};
            end
            7'd42 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 84 ],    mb_cbf_y_i[ 85 ],    mb_cbf_y_i[ 86 ],    mb_cbf_y_i[ 87 ]};
            end
            7'd43 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 88 ],    mb_cbf_y_i[ 89 ],    mb_cbf_y_i[ 90 ],    mb_cbf_y_i[ 91 ]};
            end
            7'd44 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 92 ],    mb_cbf_y_i[ 93 ],    mb_cbf_y_i[ 94 ],    mb_cbf_y_i[ 95 ]};
            end
            7'd45 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 96 ],    mb_cbf_y_i[ 97 ],    mb_cbf_y_i[ 98 ],    mb_cbf_y_i[ 99 ]};
            end
            7'd46 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 100],    mb_cbf_y_i[ 101],    mb_cbf_y_i[ 102],    mb_cbf_y_i[ 103]};
            end
            7'd47 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 104],    mb_cbf_y_i[ 105],    mb_cbf_y_i[ 106],    mb_cbf_y_i[ 107]};
            end
            7'd48 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 108],    mb_cbf_y_i[ 109],    mb_cbf_y_i[ 110],    mb_cbf_y_i[ 111]};
            end
            7'd49 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 112],    mb_cbf_y_i[ 113],    mb_cbf_y_i[ 114],    mb_cbf_y_i[ 115]};
            end
            7'd50 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 116],    mb_cbf_y_i[ 117],    mb_cbf_y_i[ 118],    mb_cbf_y_i[ 119]};
            end
            7'd51 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 120],    mb_cbf_y_i[ 121],    mb_cbf_y_i[ 122],    mb_cbf_y_i[ 123]};
            end
            7'd52 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 124],    mb_cbf_y_i[ 125],    mb_cbf_y_i[ 126],    mb_cbf_y_i[ 127]};
            end
            7'd53 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 128],    mb_cbf_y_i[ 129],    mb_cbf_y_i[ 130],    mb_cbf_y_i[ 131]};
            end
            7'd54 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 132],    mb_cbf_y_i[ 133],    mb_cbf_y_i[ 134],    mb_cbf_y_i[ 135]};
            end
            7'd55 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 136],    mb_cbf_y_i[ 137],    mb_cbf_y_i[ 138],    mb_cbf_y_i[ 139]};
            end
            7'd56 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 140],    mb_cbf_y_i[ 141],    mb_cbf_y_i[ 142],    mb_cbf_y_i[ 143]};
            end
            7'd57 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 144],    mb_cbf_y_i[ 145],    mb_cbf_y_i[ 146],    mb_cbf_y_i[ 147]};
            end
            7'd58 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 148],    mb_cbf_y_i[ 149],    mb_cbf_y_i[ 150],    mb_cbf_y_i[ 151]};
            end
            7'd59 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 152],    mb_cbf_y_i[ 153],    mb_cbf_y_i[ 154],    mb_cbf_y_i[ 155]};
            end
            7'd60 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 156],    mb_cbf_y_i[ 157],    mb_cbf_y_i[ 158],    mb_cbf_y_i[ 159]};
            end
            7'd61 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 160],    mb_cbf_y_i[ 161],    mb_cbf_y_i[ 162],    mb_cbf_y_i[ 163]};
            end
            7'd62 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 164],    mb_cbf_y_i[ 165],    mb_cbf_y_i[ 166],    mb_cbf_y_i[ 167]};
            end
            7'd63 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 168],    mb_cbf_y_i[ 169],    mb_cbf_y_i[ 170],    mb_cbf_y_i[ 171]};
            end
            7'd64 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 172],    mb_cbf_y_i[ 173],    mb_cbf_y_i[ 174],    mb_cbf_y_i[ 175]};
            end
            7'd65 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 176],    mb_cbf_y_i[ 177],    mb_cbf_y_i[ 178],    mb_cbf_y_i[ 179]};
            end
            7'd66 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 180],    mb_cbf_y_i[ 181],    mb_cbf_y_i[ 182],    mb_cbf_y_i[ 183]};
            end
            7'd67 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 184],    mb_cbf_y_i[ 185],    mb_cbf_y_i[ 186],    mb_cbf_y_i[ 187]};
            end
            7'd68 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 188],    mb_cbf_y_i[ 189],    mb_cbf_y_i[ 190],    mb_cbf_y_i[ 191]};
            end
            7'd69 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 192],    mb_cbf_y_i[ 193],    mb_cbf_y_i[ 194],    mb_cbf_y_i[ 195]};
            end
            7'd70 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 196],    mb_cbf_y_i[ 197],    mb_cbf_y_i[ 198],    mb_cbf_y_i[ 199]};
            end
            7'd71 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 200],    mb_cbf_y_i[ 201],    mb_cbf_y_i[ 202],    mb_cbf_y_i[ 203]};
            end
            7'd72 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 204],    mb_cbf_y_i[ 205],    mb_cbf_y_i[ 206],    mb_cbf_y_i[ 207]};
            end
            7'd73 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 208],    mb_cbf_y_i[ 209],    mb_cbf_y_i[ 210],    mb_cbf_y_i[ 211]};
            end
            7'd74 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 212],    mb_cbf_y_i[ 213],    mb_cbf_y_i[ 214],    mb_cbf_y_i[ 215]};
            end
            7'd75 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 216],    mb_cbf_y_i[ 217],    mb_cbf_y_i[ 218],    mb_cbf_y_i[ 219]};
            end
            7'd76 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 220],    mb_cbf_y_i[ 221],    mb_cbf_y_i[ 222],    mb_cbf_y_i[ 223]};
            end
            7'd77 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 224],    mb_cbf_y_i[ 225],    mb_cbf_y_i[ 226],    mb_cbf_y_i[ 227]};
            end
            7'd78 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 228],    mb_cbf_y_i[ 229],    mb_cbf_y_i[ 230],    mb_cbf_y_i[ 231]};
            end
            7'd79 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 232],    mb_cbf_y_i[ 233],    mb_cbf_y_i[ 234],    mb_cbf_y_i[ 235]};
            end
            7'd80 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 236],    mb_cbf_y_i[ 237],    mb_cbf_y_i[ 238],    mb_cbf_y_i[ 239]};
            end
            7'd81 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 240],    mb_cbf_y_i[ 241],    mb_cbf_y_i[ 242],    mb_cbf_y_i[ 243]};
            end
            7'd82 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 244],    mb_cbf_y_i[ 245],    mb_cbf_y_i[ 246],    mb_cbf_y_i[ 247]};
            end
            7'd83 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 248],    mb_cbf_y_i[ 249],    mb_cbf_y_i[ 250],    mb_cbf_y_i[ 251]};
            end
            7'd84 :
            begin
                cu_cbf_y_r <= {    mb_cbf_y_i[ 252],    mb_cbf_y_i[ 253],    mb_cbf_y_i[ 254],    mb_cbf_y_i[ 255]};
            end
            default :
            begin
                cu_cbf_y_r <= 4'b0                                                                                             ;
            end
        endcase
    end
end

// cu_cbf_u_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_cbf_u_r   <=  4'b0   ;
    else
    begin
        case(cu_idx_r)
            7'd0  :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[ 63:0  ]==0),!(mb_cbf_u_i[127:64 ]==0),!(mb_cbf_u_i[191:128]==0),!(mb_cbf_u_i[255:192]==0)};
            end // 64x64
            7'd1  :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[ 15:0  ]==0),!(mb_cbf_u_i[ 31:16 ]==0),!(mb_cbf_u_i[ 47:32 ]==0),!(mb_cbf_u_i[ 63:48 ]==0)};
            end // 32x32
            7'd2  :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[ 79:64 ]==0),!(mb_cbf_u_i[ 95:80 ]==0),!(mb_cbf_u_i[111:96 ]==0),!(mb_cbf_u_i[127:112]==0)};
            end
            7'd3  :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[143:128]==0),!(mb_cbf_u_i[159:144]==0),!(mb_cbf_u_i[175:160]==0),!(mb_cbf_u_i[191:176]==0)};
            end
            7'd4  :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[207:192]==0),!(mb_cbf_u_i[223:208]==0),!(mb_cbf_u_i[239:224]==0),!(mb_cbf_u_i[255:240]==0)};
            end
            7'd5  :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[  3:0  ]==0),!(mb_cbf_u_i[  7:4  ]==0),!(mb_cbf_u_i[ 11:8  ]==0),!(mb_cbf_u_i[ 15:12 ]==0)};
            end // 16x16
            7'd6  :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[ 19:16 ]==0),!(mb_cbf_u_i[ 23:20 ]==0),!(mb_cbf_u_i[ 27:24 ]==0),!(mb_cbf_u_i[ 31:28 ]==0)};
            end
            7'd7  :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[ 35:32 ]==0),!(mb_cbf_u_i[ 39:36 ]==0),!(mb_cbf_u_i[ 43:40 ]==0),!(mb_cbf_u_i[ 47:44 ]==0)};
            end
            7'd8  :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[ 51:48 ]==0),!(mb_cbf_u_i[ 55:52 ]==0),!(mb_cbf_u_i[ 59:56 ]==0),!(mb_cbf_u_i[ 63:60 ]==0)};
            end
            7'd9  :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[ 67:64 ]==0),!(mb_cbf_u_i[ 71:68 ]==0),!(mb_cbf_u_i[ 75:72 ]==0),!(mb_cbf_u_i[ 79:76 ]==0)};
            end
            7'd10 :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[ 83:80 ]==0),!(mb_cbf_u_i[ 87:84 ]==0),!(mb_cbf_u_i[ 91:88 ]==0),!(mb_cbf_u_i[ 95:92 ]==0)};
            end
            7'd11 :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[ 99:96 ]==0),!(mb_cbf_u_i[103:100]==0),!(mb_cbf_u_i[107:104]==0),!(mb_cbf_u_i[111:108]==0)};
            end
            7'd12 :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[115:112]==0),!(mb_cbf_u_i[119:116]==0),!(mb_cbf_u_i[123:120]==0),!(mb_cbf_u_i[127:124]==0)};
            end
            7'd13 :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[131:128]==0),!(mb_cbf_u_i[135:132]==0),!(mb_cbf_u_i[139:136]==0),!(mb_cbf_u_i[143:140]==0)};
            end
            7'd14 :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[147:144]==0),!(mb_cbf_u_i[151:148]==0),!(mb_cbf_u_i[155:152]==0),!(mb_cbf_u_i[159:156]==0)};
            end
            7'd15 :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[163:160]==0),!(mb_cbf_u_i[167:164]==0),!(mb_cbf_u_i[171:168]==0),!(mb_cbf_u_i[175:172]==0)};
            end
            7'd16 :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[179:176]==0),!(mb_cbf_u_i[183:180]==0),!(mb_cbf_u_i[187:184]==0),!(mb_cbf_u_i[191:188]==0)};
            end
            7'd17 :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[195:192]==0),!(mb_cbf_u_i[199:196]==0),!(mb_cbf_u_i[203:200]==0),!(mb_cbf_u_i[207:204]==0)};
            end
            7'd18 :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[211:208]==0),!(mb_cbf_u_i[215:212]==0),!(mb_cbf_u_i[219:216]==0),!(mb_cbf_u_i[223:220]==0)};
            end
            7'd19 :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[227:224]==0),!(mb_cbf_u_i[231:228]==0),!(mb_cbf_u_i[235:232]==0),!(mb_cbf_u_i[239:236]==0)};
            end
            7'd20 :
            begin
                cu_cbf_u_r <= {!(mb_cbf_u_i[243:240]==0),!(mb_cbf_u_i[247:244]==0),!(mb_cbf_u_i[251:248]==0),!(mb_cbf_u_i[255:252]==0)};
            end
            7'd21 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 0  ],    mb_cbf_u_i[ 1  ],    mb_cbf_u_i[ 2  ],    mb_cbf_u_i[ 3  ]};
            end // 8x8
            7'd22 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 4  ],    mb_cbf_u_i[ 5  ],    mb_cbf_u_i[ 6  ],    mb_cbf_u_i[ 7  ]};
            end
            7'd23 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 8  ],    mb_cbf_u_i[ 9  ],    mb_cbf_u_i[ 10 ],    mb_cbf_u_i[ 11 ]};
            end
            7'd24 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 12 ],    mb_cbf_u_i[ 13 ],    mb_cbf_u_i[ 14 ],    mb_cbf_u_i[ 15 ]};
            end
            7'd25 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 16 ],    mb_cbf_u_i[ 17 ],    mb_cbf_u_i[ 18 ],    mb_cbf_u_i[ 19 ]};
            end
            7'd26 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 20 ],    mb_cbf_u_i[ 21 ],    mb_cbf_u_i[ 22 ],    mb_cbf_u_i[ 23 ]};
            end
            7'd27 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 24 ],    mb_cbf_u_i[ 25 ],    mb_cbf_u_i[ 26 ],    mb_cbf_u_i[ 27 ]};
            end
            7'd28 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 28 ],    mb_cbf_u_i[ 29 ],    mb_cbf_u_i[ 30 ],    mb_cbf_u_i[ 31 ]};
            end
            7'd29 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 32 ],    mb_cbf_u_i[ 33 ],    mb_cbf_u_i[ 34 ],    mb_cbf_u_i[ 35 ]};
            end
            7'd30 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 36 ],    mb_cbf_u_i[ 37 ],    mb_cbf_u_i[ 38 ],    mb_cbf_u_i[ 39 ]};
            end
            7'd31 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 40 ],    mb_cbf_u_i[ 41 ],    mb_cbf_u_i[ 42 ],    mb_cbf_u_i[ 43 ]};
            end
            7'd32 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 44 ],    mb_cbf_u_i[ 45 ],    mb_cbf_u_i[ 46 ],    mb_cbf_u_i[ 47 ]};
            end
            7'd33 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 48 ],    mb_cbf_u_i[ 49 ],    mb_cbf_u_i[ 50 ],    mb_cbf_u_i[ 51 ]};
            end
            7'd34 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 52 ],    mb_cbf_u_i[ 53 ],    mb_cbf_u_i[ 54 ],    mb_cbf_u_i[ 55 ]};
            end
            7'd35 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 56 ],    mb_cbf_u_i[ 57 ],    mb_cbf_u_i[ 58 ],    mb_cbf_u_i[ 59 ]};
            end
            7'd36 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 60 ],    mb_cbf_u_i[ 61 ],    mb_cbf_u_i[ 62 ],    mb_cbf_u_i[ 63 ]};
            end
            7'd37 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 64 ],    mb_cbf_u_i[ 65 ],    mb_cbf_u_i[ 66 ],    mb_cbf_u_i[ 67 ]};
            end
            7'd38 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 68 ],    mb_cbf_u_i[ 69 ],    mb_cbf_u_i[ 70 ],    mb_cbf_u_i[ 71 ]};
            end
            7'd39 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 72 ],    mb_cbf_u_i[ 73 ],    mb_cbf_u_i[ 74 ],    mb_cbf_u_i[ 75 ]};
            end
            7'd40 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 76 ],    mb_cbf_u_i[ 77 ],    mb_cbf_u_i[ 78 ],    mb_cbf_u_i[ 79 ]};
            end
            7'd41 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 80 ],    mb_cbf_u_i[ 81 ],    mb_cbf_u_i[ 82 ],    mb_cbf_u_i[ 83 ]};
            end
            7'd42 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 84 ],    mb_cbf_u_i[ 85 ],    mb_cbf_u_i[ 86 ],    mb_cbf_u_i[ 87 ]};
            end
            7'd43 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 88 ],    mb_cbf_u_i[ 89 ],    mb_cbf_u_i[ 90 ],    mb_cbf_u_i[ 91 ]};
            end
            7'd44 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 92 ],    mb_cbf_u_i[ 93 ],    mb_cbf_u_i[ 94 ],    mb_cbf_u_i[ 95 ]};
            end
            7'd45 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 96 ],    mb_cbf_u_i[ 97 ],    mb_cbf_u_i[ 98 ],    mb_cbf_u_i[ 99 ]};
            end
            7'd46 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 100],    mb_cbf_u_i[ 101],    mb_cbf_u_i[ 102],    mb_cbf_u_i[ 103]};
            end
            7'd47 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 104],    mb_cbf_u_i[ 105],    mb_cbf_u_i[ 106],    mb_cbf_u_i[ 107]};
            end
            7'd48 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 108],    mb_cbf_u_i[ 109],    mb_cbf_u_i[ 110],    mb_cbf_u_i[ 111]};
            end
            7'd49 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 112],    mb_cbf_u_i[ 113],    mb_cbf_u_i[ 114],    mb_cbf_u_i[ 115]};
            end
            7'd50 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 116],    mb_cbf_u_i[ 117],    mb_cbf_u_i[ 118],    mb_cbf_u_i[ 119]};
            end
            7'd51 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 120],    mb_cbf_u_i[ 121],    mb_cbf_u_i[ 122],    mb_cbf_u_i[ 123]};
            end
            7'd52 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 124],    mb_cbf_u_i[ 125],    mb_cbf_u_i[ 126],    mb_cbf_u_i[ 127]};
            end
            7'd53 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 128],    mb_cbf_u_i[ 129],    mb_cbf_u_i[ 130],    mb_cbf_u_i[ 131]};
            end
            7'd54 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 132],    mb_cbf_u_i[ 133],    mb_cbf_u_i[ 134],    mb_cbf_u_i[ 135]};
            end
            7'd55 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 136],    mb_cbf_u_i[ 137],    mb_cbf_u_i[ 138],    mb_cbf_u_i[ 139]};
            end
            7'd56 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 140],    mb_cbf_u_i[ 141],    mb_cbf_u_i[ 142],    mb_cbf_u_i[ 143]};
            end
            7'd57 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 144],    mb_cbf_u_i[ 145],    mb_cbf_u_i[ 146],    mb_cbf_u_i[ 147]};
            end
            7'd58 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 148],    mb_cbf_u_i[ 149],    mb_cbf_u_i[ 150],    mb_cbf_u_i[ 151]};
            end
            7'd59 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 152],    mb_cbf_u_i[ 153],    mb_cbf_u_i[ 154],    mb_cbf_u_i[ 155]};
            end
            7'd60 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 156],    mb_cbf_u_i[ 157],    mb_cbf_u_i[ 158],    mb_cbf_u_i[ 159]};
            end
            7'd61 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 160],    mb_cbf_u_i[ 161],    mb_cbf_u_i[ 162],    mb_cbf_u_i[ 163]};
            end
            7'd62 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 164],    mb_cbf_u_i[ 165],    mb_cbf_u_i[ 166],    mb_cbf_u_i[ 167]};
            end
            7'd63 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 168],    mb_cbf_u_i[ 169],    mb_cbf_u_i[ 170],    mb_cbf_u_i[ 171]};
            end
            7'd64 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 172],    mb_cbf_u_i[ 173],    mb_cbf_u_i[ 174],    mb_cbf_u_i[ 175]};
            end
            7'd65 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 176],    mb_cbf_u_i[ 177],    mb_cbf_u_i[ 178],    mb_cbf_u_i[ 179]};
            end
            7'd66 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 180],    mb_cbf_u_i[ 181],    mb_cbf_u_i[ 182],    mb_cbf_u_i[ 183]};
            end
            7'd67 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 184],    mb_cbf_u_i[ 185],    mb_cbf_u_i[ 186],    mb_cbf_u_i[ 187]};
            end
            7'd68 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 188],    mb_cbf_u_i[ 189],    mb_cbf_u_i[ 190],    mb_cbf_u_i[ 191]};
            end
            7'd69 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 192],    mb_cbf_u_i[ 193],    mb_cbf_u_i[ 194],    mb_cbf_u_i[ 195]};
            end
            7'd70 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 196],    mb_cbf_u_i[ 197],    mb_cbf_u_i[ 198],    mb_cbf_u_i[ 199]};
            end
            7'd71 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 200],    mb_cbf_u_i[ 201],    mb_cbf_u_i[ 202],    mb_cbf_u_i[ 203]};
            end
            7'd72 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 204],    mb_cbf_u_i[ 205],    mb_cbf_u_i[ 206],    mb_cbf_u_i[ 207]};
            end
            7'd73 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 208],    mb_cbf_u_i[ 209],    mb_cbf_u_i[ 210],    mb_cbf_u_i[ 211]};
            end
            7'd74 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 212],    mb_cbf_u_i[ 213],    mb_cbf_u_i[ 214],    mb_cbf_u_i[ 215]};
            end
            7'd75 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 216],    mb_cbf_u_i[ 217],    mb_cbf_u_i[ 218],    mb_cbf_u_i[ 219]};
            end
            7'd76 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 220],    mb_cbf_u_i[ 221],    mb_cbf_u_i[ 222],    mb_cbf_u_i[ 223]};
            end
            7'd77 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 224],    mb_cbf_u_i[ 225],    mb_cbf_u_i[ 226],    mb_cbf_u_i[ 227]};
            end
            7'd78 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 228],    mb_cbf_u_i[ 229],    mb_cbf_u_i[ 230],    mb_cbf_u_i[ 231]};
            end
            7'd79 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 232],    mb_cbf_u_i[ 233],    mb_cbf_u_i[ 234],    mb_cbf_u_i[ 235]};
            end
            7'd80 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 236],    mb_cbf_u_i[ 237],    mb_cbf_u_i[ 238],    mb_cbf_u_i[ 239]};
            end
            7'd81 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 240],    mb_cbf_u_i[ 241],    mb_cbf_u_i[ 242],    mb_cbf_u_i[ 243]};
            end
            7'd82 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 244],    mb_cbf_u_i[ 245],    mb_cbf_u_i[ 246],    mb_cbf_u_i[ 247]};
            end
            7'd83 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 248],    mb_cbf_u_i[ 249],    mb_cbf_u_i[ 250],    mb_cbf_u_i[ 251]};
            end
            7'd84 :
            begin
                cu_cbf_u_r <= {    mb_cbf_u_i[ 252],    mb_cbf_u_i[ 253],    mb_cbf_u_i[ 254],    mb_cbf_u_i[ 255]};
            end
            default :
            begin
                cu_cbf_u_r <= 4'b0                                                                                             ;
            end
        endcase
    end
end

// cu_cbf_v_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_cbf_v_r   <=  4'b0   ;
    else
    begin
        case(cu_idx_r)
            7'd0  :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[ 63:0  ]==0),!(mb_cbf_v_i[127:64 ]==0),!(mb_cbf_v_i[191:128]==0),!(mb_cbf_v_i[255:192]==0)};
            end // 64x64
            7'd1  :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[ 15:0  ]==0),!(mb_cbf_v_i[ 31:16 ]==0),!(mb_cbf_v_i[ 47:32 ]==0),!(mb_cbf_v_i[ 63:48 ]==0)};
            end // 32x32
            7'd2  :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[ 79:64 ]==0),!(mb_cbf_v_i[ 95:80 ]==0),!(mb_cbf_v_i[111:96 ]==0),!(mb_cbf_v_i[127:112]==0)};
            end
            7'd3  :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[143:128]==0),!(mb_cbf_v_i[159:144]==0),!(mb_cbf_v_i[175:160]==0),!(mb_cbf_v_i[191:176]==0)};
            end
            7'd4  :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[207:192]==0),!(mb_cbf_v_i[223:208]==0),!(mb_cbf_v_i[239:224]==0),!(mb_cbf_v_i[255:240]==0)};
            end
            7'd5  :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[  3:0  ]==0),!(mb_cbf_v_i[  7:4  ]==0),!(mb_cbf_v_i[ 11:8  ]==0),!(mb_cbf_v_i[ 15:12 ]==0)};
            end // 16x16
            7'd6  :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[ 19:16 ]==0),!(mb_cbf_v_i[ 23:20 ]==0),!(mb_cbf_v_i[ 27:24 ]==0),!(mb_cbf_v_i[ 31:28 ]==0)};
            end
            7'd7  :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[ 35:32 ]==0),!(mb_cbf_v_i[ 39:36 ]==0),!(mb_cbf_v_i[ 43:40 ]==0),!(mb_cbf_v_i[ 47:44 ]==0)};
            end
            7'd8  :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[ 51:48 ]==0),!(mb_cbf_v_i[ 55:52 ]==0),!(mb_cbf_v_i[ 59:56 ]==0),!(mb_cbf_v_i[ 63:60 ]==0)};
            end
            7'd9  :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[ 67:64 ]==0),!(mb_cbf_v_i[ 71:68 ]==0),!(mb_cbf_v_i[ 75:72 ]==0),!(mb_cbf_v_i[ 79:76 ]==0)};
            end
            7'd10 :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[ 83:80 ]==0),!(mb_cbf_v_i[ 87:84 ]==0),!(mb_cbf_v_i[ 91:88 ]==0),!(mb_cbf_v_i[ 95:92 ]==0)};
            end
            7'd11 :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[ 99:96 ]==0),!(mb_cbf_v_i[103:100]==0),!(mb_cbf_v_i[107:104]==0),!(mb_cbf_v_i[111:108]==0)};
            end
            7'd12 :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[115:112]==0),!(mb_cbf_v_i[119:116]==0),!(mb_cbf_v_i[123:120]==0),!(mb_cbf_v_i[127:124]==0)};
            end
            7'd13 :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[131:128]==0),!(mb_cbf_v_i[135:132]==0),!(mb_cbf_v_i[139:136]==0),!(mb_cbf_v_i[143:140]==0)};
            end
            7'd14 :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[147:144]==0),!(mb_cbf_v_i[151:148]==0),!(mb_cbf_v_i[155:152]==0),!(mb_cbf_v_i[159:156]==0)};
            end
            7'd15 :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[163:160]==0),!(mb_cbf_v_i[167:164]==0),!(mb_cbf_v_i[171:168]==0),!(mb_cbf_v_i[175:172]==0)};
            end
            7'd16 :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[179:176]==0),!(mb_cbf_v_i[183:180]==0),!(mb_cbf_v_i[187:184]==0),!(mb_cbf_v_i[191:188]==0)};
            end
            7'd17 :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[195:192]==0),!(mb_cbf_v_i[199:196]==0),!(mb_cbf_v_i[203:200]==0),!(mb_cbf_v_i[207:204]==0)};
            end
            7'd18 :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[211:208]==0),!(mb_cbf_v_i[215:212]==0),!(mb_cbf_v_i[219:216]==0),!(mb_cbf_v_i[223:220]==0)};
            end
            7'd19 :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[227:224]==0),!(mb_cbf_v_i[231:228]==0),!(mb_cbf_v_i[235:232]==0),!(mb_cbf_v_i[239:236]==0)};
            end
            7'd20 :
            begin
                cu_cbf_v_r <= {!(mb_cbf_v_i[243:240]==0),!(mb_cbf_v_i[247:244]==0),!(mb_cbf_v_i[251:248]==0),!(mb_cbf_v_i[255:252]==0)};
            end
            7'd21 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 0  ],    mb_cbf_v_i[ 1  ],    mb_cbf_v_i[ 2  ],    mb_cbf_v_i[ 3  ]};
            end // 8x8
            7'd22 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 4  ],    mb_cbf_v_i[ 5  ],    mb_cbf_v_i[ 6  ],    mb_cbf_v_i[ 7  ]};
            end
            7'd23 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 8  ],    mb_cbf_v_i[ 9  ],    mb_cbf_v_i[ 10 ],    mb_cbf_v_i[ 11 ]};
            end
            7'd24 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 12 ],    mb_cbf_v_i[ 13 ],    mb_cbf_v_i[ 14 ],    mb_cbf_v_i[ 15 ]};
            end
            7'd25 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 16 ],    mb_cbf_v_i[ 17 ],    mb_cbf_v_i[ 18 ],    mb_cbf_v_i[ 19 ]};
            end
            7'd26 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 20 ],    mb_cbf_v_i[ 21 ],    mb_cbf_v_i[ 22 ],    mb_cbf_v_i[ 23 ]};
            end
            7'd27 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 24 ],    mb_cbf_v_i[ 25 ],    mb_cbf_v_i[ 26 ],    mb_cbf_v_i[ 27 ]};
            end
            7'd28 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 28 ],    mb_cbf_v_i[ 29 ],    mb_cbf_v_i[ 30 ],    mb_cbf_v_i[ 31 ]};
            end
            7'd29 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 32 ],    mb_cbf_v_i[ 33 ],    mb_cbf_v_i[ 34 ],    mb_cbf_v_i[ 35 ]};
            end
            7'd30 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 36 ],    mb_cbf_v_i[ 37 ],    mb_cbf_v_i[ 38 ],    mb_cbf_v_i[ 39 ]};
            end
            7'd31 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 40 ],    mb_cbf_v_i[ 41 ],    mb_cbf_v_i[ 42 ],    mb_cbf_v_i[ 43 ]};
            end
            7'd32 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 44 ],    mb_cbf_v_i[ 45 ],    mb_cbf_v_i[ 46 ],    mb_cbf_v_i[ 47 ]};
            end
            7'd33 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 48 ],    mb_cbf_v_i[ 49 ],    mb_cbf_v_i[ 50 ],    mb_cbf_v_i[ 51 ]};
            end
            7'd34 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 52 ],    mb_cbf_v_i[ 53 ],    mb_cbf_v_i[ 54 ],    mb_cbf_v_i[ 55 ]};
            end
            7'd35 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 56 ],    mb_cbf_v_i[ 57 ],    mb_cbf_v_i[ 58 ],    mb_cbf_v_i[ 59 ]};
            end
            7'd36 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 60 ],    mb_cbf_v_i[ 61 ],    mb_cbf_v_i[ 62 ],    mb_cbf_v_i[ 63 ]};
            end
            7'd37 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 64 ],    mb_cbf_v_i[ 65 ],    mb_cbf_v_i[ 66 ],    mb_cbf_v_i[ 67 ]};
            end
            7'd38 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 68 ],    mb_cbf_v_i[ 69 ],    mb_cbf_v_i[ 70 ],    mb_cbf_v_i[ 71 ]};
            end
            7'd39 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 72 ],    mb_cbf_v_i[ 73 ],    mb_cbf_v_i[ 74 ],    mb_cbf_v_i[ 75 ]};
            end
            7'd40 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 76 ],    mb_cbf_v_i[ 77 ],    mb_cbf_v_i[ 78 ],    mb_cbf_v_i[ 79 ]};
            end
            7'd41 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 80 ],    mb_cbf_v_i[ 81 ],    mb_cbf_v_i[ 82 ],    mb_cbf_v_i[ 83 ]};
            end
            7'd42 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 84 ],    mb_cbf_v_i[ 85 ],    mb_cbf_v_i[ 86 ],    mb_cbf_v_i[ 87 ]};
            end
            7'd43 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 88 ],    mb_cbf_v_i[ 89 ],    mb_cbf_v_i[ 90 ],    mb_cbf_v_i[ 91 ]};
            end
            7'd44 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 92 ],    mb_cbf_v_i[ 93 ],    mb_cbf_v_i[ 94 ],    mb_cbf_v_i[ 95 ]};
            end
            7'd45 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 96 ],    mb_cbf_v_i[ 97 ],    mb_cbf_v_i[ 98 ],    mb_cbf_v_i[ 99 ]};
            end
            7'd46 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 100],    mb_cbf_v_i[ 101],    mb_cbf_v_i[ 102],    mb_cbf_v_i[ 103]};
            end
            7'd47 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 104],    mb_cbf_v_i[ 105],    mb_cbf_v_i[ 106],    mb_cbf_v_i[ 107]};
            end
            7'd48 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 108],    mb_cbf_v_i[ 109],    mb_cbf_v_i[ 110],    mb_cbf_v_i[ 111]};
            end
            7'd49 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 112],    mb_cbf_v_i[ 113],    mb_cbf_v_i[ 114],    mb_cbf_v_i[ 115]};
            end
            7'd50 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 116],    mb_cbf_v_i[ 117],    mb_cbf_v_i[ 118],    mb_cbf_v_i[ 119]};
            end
            7'd51 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 120],    mb_cbf_v_i[ 121],    mb_cbf_v_i[ 122],    mb_cbf_v_i[ 123]};
            end
            7'd52 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 124],    mb_cbf_v_i[ 125],    mb_cbf_v_i[ 126],    mb_cbf_v_i[ 127]};
            end
            7'd53 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 128],    mb_cbf_v_i[ 129],    mb_cbf_v_i[ 130],    mb_cbf_v_i[ 131]};
            end
            7'd54 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 132],    mb_cbf_v_i[ 133],    mb_cbf_v_i[ 134],    mb_cbf_v_i[ 135]};
            end
            7'd55 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 136],    mb_cbf_v_i[ 137],    mb_cbf_v_i[ 138],    mb_cbf_v_i[ 139]};
            end
            7'd56 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 140],    mb_cbf_v_i[ 141],    mb_cbf_v_i[ 142],    mb_cbf_v_i[ 143]};
            end
            7'd57 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 144],    mb_cbf_v_i[ 145],    mb_cbf_v_i[ 146],    mb_cbf_v_i[ 147]};
            end
            7'd58 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 148],    mb_cbf_v_i[ 149],    mb_cbf_v_i[ 150],    mb_cbf_v_i[ 151]};
            end
            7'd59 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 152],    mb_cbf_v_i[ 153],    mb_cbf_v_i[ 154],    mb_cbf_v_i[ 155]};
            end
            7'd60 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 156],    mb_cbf_v_i[ 157],    mb_cbf_v_i[ 158],    mb_cbf_v_i[ 159]};
            end
            7'd61 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 160],    mb_cbf_v_i[ 161],    mb_cbf_v_i[ 162],    mb_cbf_v_i[ 163]};
            end
            7'd62 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 164],    mb_cbf_v_i[ 165],    mb_cbf_v_i[ 166],    mb_cbf_v_i[ 167]};
            end
            7'd63 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 168],    mb_cbf_v_i[ 169],    mb_cbf_v_i[ 170],    mb_cbf_v_i[ 171]};
            end
            7'd64 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 172],    mb_cbf_v_i[ 173],    mb_cbf_v_i[ 174],    mb_cbf_v_i[ 175]};
            end
            7'd65 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 176],    mb_cbf_v_i[ 177],    mb_cbf_v_i[ 178],    mb_cbf_v_i[ 179]};
            end
            7'd66 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 180],    mb_cbf_v_i[ 181],    mb_cbf_v_i[ 182],    mb_cbf_v_i[ 183]};
            end
            7'd67 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 184],    mb_cbf_v_i[ 185],    mb_cbf_v_i[ 186],    mb_cbf_v_i[ 187]};
            end
            7'd68 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 188],    mb_cbf_v_i[ 189],    mb_cbf_v_i[ 190],    mb_cbf_v_i[ 191]};
            end
            7'd69 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 192],    mb_cbf_v_i[ 193],    mb_cbf_v_i[ 194],    mb_cbf_v_i[ 195]};
            end
            7'd70 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 196],    mb_cbf_v_i[ 197],    mb_cbf_v_i[ 198],    mb_cbf_v_i[ 199]};
            end
            7'd71 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 200],    mb_cbf_v_i[ 201],    mb_cbf_v_i[ 202],    mb_cbf_v_i[ 203]};
            end
            7'd72 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 204],    mb_cbf_v_i[ 205],    mb_cbf_v_i[ 206],    mb_cbf_v_i[ 207]};
            end
            7'd73 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 208],    mb_cbf_v_i[ 209],    mb_cbf_v_i[ 210],    mb_cbf_v_i[ 211]};
            end
            7'd74 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 212],    mb_cbf_v_i[ 213],    mb_cbf_v_i[ 214],    mb_cbf_v_i[ 215]};
            end
            7'd75 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 216],    mb_cbf_v_i[ 217],    mb_cbf_v_i[ 218],    mb_cbf_v_i[ 219]};
            end
            7'd76 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 220],    mb_cbf_v_i[ 221],    mb_cbf_v_i[ 222],    mb_cbf_v_i[ 223]};
            end
            7'd77 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 224],    mb_cbf_v_i[ 225],    mb_cbf_v_i[ 226],    mb_cbf_v_i[ 227]};
            end
            7'd78 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 228],    mb_cbf_v_i[ 229],    mb_cbf_v_i[ 230],    mb_cbf_v_i[ 231]};
            end
            7'd79 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 232],    mb_cbf_v_i[ 233],    mb_cbf_v_i[ 234],    mb_cbf_v_i[ 235]};
            end
            7'd80 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 236],    mb_cbf_v_i[ 237],    mb_cbf_v_i[ 238],    mb_cbf_v_i[ 239]};
            end
            7'd81 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 240],    mb_cbf_v_i[ 241],    mb_cbf_v_i[ 242],    mb_cbf_v_i[ 243]};
            end
            7'd82 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 244],    mb_cbf_v_i[ 245],    mb_cbf_v_i[ 246],    mb_cbf_v_i[ 247]};
            end
            7'd83 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 248],    mb_cbf_v_i[ 249],    mb_cbf_v_i[ 250],    mb_cbf_v_i[ 251]};
            end
            7'd84 :
            begin
                cu_cbf_v_r <= {    mb_cbf_v_i[ 252],    mb_cbf_v_i[ 253],    mb_cbf_v_i[ 254],    mb_cbf_v_i[ 255]};
            end
            default :
            begin
                cu_cbf_v_r <= 4'b0                                                                                             ;
            end
        endcase
    end
end


// cu_depth_top_r
always @*
begin
    case(cu_idx_r)
        7'd0 :
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[15:14]: 2'd0;
        7'd1 :
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[15:14]: 2'd0;
        7'd2 :
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[11:10]: 2'd0;
        7'd3 :
            cu_depth_top_r  =  cu_depth_0_0_r                         ;
        7'd4 :
            cu_depth_top_r  =  cu_depth_0_4_r                         ;
        7'd5 :
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[15:14]: 2'd0;
        7'd6 :
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[13:12]: 2'd0;
        7'd7 :
            cu_depth_top_r  =  cu_depth_0_0_r                         ;
        7'd8 :
            cu_depth_top_r  =  cu_depth_0_2_r                         ;
        7'd9 :
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[11:10]: 2'd0;
        7'd10:
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[ 9:8 ]: 2'd0;
        7'd11:
            cu_depth_top_r  =  cu_depth_0_4_r                         ;
        7'd12:
            cu_depth_top_r  =  cu_depth_0_6_r                         ;
        7'd13:
            cu_depth_top_r  =  cu_depth_2_0_r                         ;
        7'd14:
            cu_depth_top_r  =  cu_depth_2_2_r                         ;
        7'd15:
            cu_depth_top_r  =  cu_depth_4_0_r                         ;
        7'd16:
            cu_depth_top_r  =  cu_depth_4_2_r                         ;
        7'd17:
            cu_depth_top_r  =  cu_depth_2_4_r                         ;
        7'd18:
            cu_depth_top_r  =  cu_depth_2_6_r                         ;
        7'd19:
            cu_depth_top_r  =  cu_depth_4_4_r                         ;
        7'd20:
            cu_depth_top_r  =  cu_depth_4_6_r                         ;
        7'd21:
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[15:14]: 2'd0;
        7'd22:
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[15:14]: 2'd0;
        7'd23:
            cu_depth_top_r  =  r_data_neigh_mb_r[15:14]               ;
        7'd24:
            cu_depth_top_r  =  r_data_neigh_mb_r[15:14]               ;
        7'd25:
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[13:12]: 2'd0;
        7'd26:
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[13:12]: 2'd0;
        7'd27:
            cu_depth_top_r  =  r_data_neigh_mb_r[13:12]               ;
        7'd28:
            cu_depth_top_r  =  r_data_neigh_mb_r[13:12]               ;
        7'd29:
            cu_depth_top_r  =  cu_depth_0_0_r                         ;
        7'd30:
            cu_depth_top_r  =  cu_depth_0_0_r                         ;
        7'd31:
            cu_depth_top_r  =  cu_depth_0_0_r                         ;
        7'd32:
            cu_depth_top_r  =  cu_depth_0_0_r                         ;
        7'd33:
            cu_depth_top_r  =  cu_depth_0_2_r                         ;
        7'd34:
            cu_depth_top_r  =  cu_depth_0_2_r                         ;
        7'd35:
            cu_depth_top_r  =  cu_depth_0_2_r                         ;
        7'd36:
            cu_depth_top_r  =  cu_depth_0_2_r                         ;
        7'd37:
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[11:10]: 2'd0;
        7'd38:
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[11:10]: 2'd0;
        7'd39:
            cu_depth_top_r  =  r_data_neigh_mb_r[11:10]               ;
        7'd40:
            cu_depth_top_r  =  r_data_neigh_mb_r[11:10]               ;
        7'd41:
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[ 9:8 ]: 2'd0;
        7'd42:
            cu_depth_top_r  =  sys_mb_y_i ? r_data_neigh_mb_r[ 9:8 ]: 2'd0;
        7'd43:
            cu_depth_top_r  =  r_data_neigh_mb_r[ 9:8 ]               ;
        7'd44:
            cu_depth_top_r  =  r_data_neigh_mb_r[ 9:8 ]               ;
        7'd45:
            cu_depth_top_r  =  cu_depth_0_4_r                         ;
        7'd46:
            cu_depth_top_r  =  cu_depth_0_4_r                         ;
        7'd47:
            cu_depth_top_r  =  cu_depth_0_4_r                         ;
        7'd48:
            cu_depth_top_r  =  cu_depth_0_4_r                         ;
        7'd49:
            cu_depth_top_r  =  cu_depth_0_6_r                         ;
        7'd50:
            cu_depth_top_r  =  cu_depth_0_6_r                         ;
        7'd51:
            cu_depth_top_r  =  cu_depth_0_6_r                         ;
        7'd52:
            cu_depth_top_r  =  cu_depth_0_6_r                         ;
        7'd53:
            cu_depth_top_r  =  cu_depth_2_0_r                         ;
        7'd54:
            cu_depth_top_r  =  cu_depth_2_0_r                         ;
        7'd55:
            cu_depth_top_r  =  cu_depth_2_0_r                         ;
        7'd56:
            cu_depth_top_r  =  cu_depth_2_0_r                         ;
        7'd57:
            cu_depth_top_r  =  cu_depth_2_2_r                         ;
        7'd58:
            cu_depth_top_r  =  cu_depth_2_2_r                         ;
        7'd59:
            cu_depth_top_r  =  cu_depth_2_2_r                         ;
        7'd60:
            cu_depth_top_r  =  cu_depth_2_2_r                         ;
        7'd61:
            cu_depth_top_r  =  cu_depth_4_0_r                         ;
        7'd62:
            cu_depth_top_r  =  cu_depth_4_0_r                         ;
        7'd63:
            cu_depth_top_r  =  cu_depth_4_0_r                         ;
        7'd64:
            cu_depth_top_r  =  cu_depth_4_0_r                         ;
        7'd65:
            cu_depth_top_r  =  cu_depth_4_2_r                         ;
        7'd66:
            cu_depth_top_r  =  cu_depth_4_2_r                         ;
        7'd67:
            cu_depth_top_r  =  cu_depth_4_2_r                         ;
        7'd68:
            cu_depth_top_r  =  cu_depth_4_2_r                         ;
        7'd69:
            cu_depth_top_r  =  cu_depth_2_4_r                         ;
        7'd70:
            cu_depth_top_r  =  cu_depth_2_4_r                         ;
        7'd71:
            cu_depth_top_r  =  cu_depth_2_4_r                         ;
        7'd72:
            cu_depth_top_r  =  cu_depth_2_4_r                         ;
        7'd73:
            cu_depth_top_r  =  cu_depth_2_6_r                         ;
        7'd74:
            cu_depth_top_r  =  cu_depth_2_6_r                         ;
        7'd75:
            cu_depth_top_r  =  cu_depth_2_6_r                         ;
        7'd76:
            cu_depth_top_r  =  cu_depth_2_6_r                         ;
        7'd77:
            cu_depth_top_r  =  cu_depth_4_4_r                         ;
        7'd78:
            cu_depth_top_r  =  cu_depth_4_4_r                         ;
        7'd79:
            cu_depth_top_r  =  cu_depth_4_4_r                         ;
        7'd80:
            cu_depth_top_r  =  cu_depth_4_4_r                         ;
        7'd81:
            cu_depth_top_r  =  cu_depth_4_6_r                         ;
        7'd82:
            cu_depth_top_r  =  cu_depth_4_6_r                         ;
        7'd83:
            cu_depth_top_r  =  cu_depth_4_6_r                         ;
        7'd84:
            cu_depth_top_r  =  cu_depth_4_6_r                         ;
        default:
            cu_depth_top_r  = 2'd0                                    ;
    endcase
end

//cu_skip_flag_r
always @* begin
    if(sys_slice_type_i != `SLICE_TYPE_I)begin
        case(cu_idx_r)
            7'd0  :
                cu_skip_flag_r   =   mb_skip_flag_i[84];
            7'd1  :
                cu_skip_flag_r   =   mb_skip_flag_i[83];
            7'd2  :
                cu_skip_flag_r   =   mb_skip_flag_i[82];
            7'd3  :
                cu_skip_flag_r   =   mb_skip_flag_i[81];
            7'd4  :
                cu_skip_flag_r   =   mb_skip_flag_i[80];
            7'd5  :
                cu_skip_flag_r   =   mb_skip_flag_i[79];
            7'd6  :
                cu_skip_flag_r   =   mb_skip_flag_i[78];
            7'd7  :
                cu_skip_flag_r   =   mb_skip_flag_i[77];
            7'd8  :
                cu_skip_flag_r   =   mb_skip_flag_i[76];
            7'd9  :
                cu_skip_flag_r   =   mb_skip_flag_i[75];
            7'd10 :
                cu_skip_flag_r   =   mb_skip_flag_i[74];
            7'd11 :
                cu_skip_flag_r   =   mb_skip_flag_i[73];
            7'd12 :
                cu_skip_flag_r   =   mb_skip_flag_i[72];
            7'd13 :
                cu_skip_flag_r   =   mb_skip_flag_i[71];
            7'd14 :
                cu_skip_flag_r   =   mb_skip_flag_i[70];
            7'd15 :
                cu_skip_flag_r   =   mb_skip_flag_i[69];
            7'd16 :
                cu_skip_flag_r   =   mb_skip_flag_i[68];
            7'd17 :
                cu_skip_flag_r   =   mb_skip_flag_i[67];
            7'd18 :
                cu_skip_flag_r   =   mb_skip_flag_i[66];
            7'd19 :
                cu_skip_flag_r   =   mb_skip_flag_i[65];
            7'd20 :
                cu_skip_flag_r   =   mb_skip_flag_i[64];
            7'd21 :
                cu_skip_flag_r   =   mb_skip_flag_i[63];
            7'd22 :
                cu_skip_flag_r   =   mb_skip_flag_i[62];
            7'd23 :
                cu_skip_flag_r   =   mb_skip_flag_i[61];
            7'd24 :
                cu_skip_flag_r   =   mb_skip_flag_i[60];
            7'd25 :
                cu_skip_flag_r   =   mb_skip_flag_i[59];
            7'd26 :
                cu_skip_flag_r   =   mb_skip_flag_i[58];
            7'd27 :
                cu_skip_flag_r   =   mb_skip_flag_i[57];
            7'd28 :
                cu_skip_flag_r   =   mb_skip_flag_i[56];
            7'd29 :
                cu_skip_flag_r   =   mb_skip_flag_i[55];
            7'd30 :
                cu_skip_flag_r   =   mb_skip_flag_i[54];
            7'd31 :
                cu_skip_flag_r   =   mb_skip_flag_i[53];
            7'd32 :
                cu_skip_flag_r   =   mb_skip_flag_i[52];
            7'd33 :
                cu_skip_flag_r   =   mb_skip_flag_i[51];
            7'd34 :
                cu_skip_flag_r   =   mb_skip_flag_i[50];
            7'd35 :
                cu_skip_flag_r   =   mb_skip_flag_i[49];
            7'd36 :
                cu_skip_flag_r   =   mb_skip_flag_i[48];
            7'd37 :
                cu_skip_flag_r   =   mb_skip_flag_i[47];
            7'd38 :
                cu_skip_flag_r   =   mb_skip_flag_i[46];
            7'd39 :
                cu_skip_flag_r   =   mb_skip_flag_i[45];
            7'd40 :
                cu_skip_flag_r   =   mb_skip_flag_i[44];
            7'd41 :
                cu_skip_flag_r   =   mb_skip_flag_i[43];
            7'd42 :
                cu_skip_flag_r   =   mb_skip_flag_i[42];
            7'd43 :
                cu_skip_flag_r   =   mb_skip_flag_i[41];
            7'd44 :
                cu_skip_flag_r   =   mb_skip_flag_i[40];
            7'd45 :
                cu_skip_flag_r   =   mb_skip_flag_i[39];
            7'd46 :
                cu_skip_flag_r   =   mb_skip_flag_i[38];
            7'd47 :
                cu_skip_flag_r   =   mb_skip_flag_i[37];
            7'd48 :
                cu_skip_flag_r   =   mb_skip_flag_i[36];
            7'd49 :
                cu_skip_flag_r   =   mb_skip_flag_i[35];
            7'd50 :
                cu_skip_flag_r   =   mb_skip_flag_i[34];
            7'd51 :
                cu_skip_flag_r   =   mb_skip_flag_i[33];
            7'd52 :
                cu_skip_flag_r   =   mb_skip_flag_i[32];
            7'd53 :
                cu_skip_flag_r   =   mb_skip_flag_i[31];
            7'd54 :
                cu_skip_flag_r   =   mb_skip_flag_i[30];
            7'd55 :
                cu_skip_flag_r   =   mb_skip_flag_i[29];
            7'd56 :
                cu_skip_flag_r   =   mb_skip_flag_i[28];
            7'd57 :
                cu_skip_flag_r   =   mb_skip_flag_i[27];
            7'd58 :
                cu_skip_flag_r   =   mb_skip_flag_i[26];
            7'd59 :
                cu_skip_flag_r   =   mb_skip_flag_i[25];
            7'd60 :
                cu_skip_flag_r   =   mb_skip_flag_i[24];
            7'd61 :
                cu_skip_flag_r   =   mb_skip_flag_i[23];
            7'd62 :
                cu_skip_flag_r   =   mb_skip_flag_i[22];
            7'd63 :
                cu_skip_flag_r   =   mb_skip_flag_i[21];
            7'd64 :
                cu_skip_flag_r   =   mb_skip_flag_i[20];
            7'd65 :
                cu_skip_flag_r   =   mb_skip_flag_i[19];
            7'd66 :
                cu_skip_flag_r   =   mb_skip_flag_i[18];
            7'd67 :
                cu_skip_flag_r   =   mb_skip_flag_i[17];
            7'd68 :
                cu_skip_flag_r   =   mb_skip_flag_i[16];
            7'd69 :
                cu_skip_flag_r   =   mb_skip_flag_i[15];
            7'd70 :
                cu_skip_flag_r   =   mb_skip_flag_i[14];
            7'd71 :
                cu_skip_flag_r   =   mb_skip_flag_i[13];
            7'd72 :
                cu_skip_flag_r   =   mb_skip_flag_i[12];
            7'd73 :
                cu_skip_flag_r   =   mb_skip_flag_i[11];
            7'd74 :
                cu_skip_flag_r   =   mb_skip_flag_i[10];
            7'd75 :
                cu_skip_flag_r   =   mb_skip_flag_i[9 ];
            7'd76 :
                cu_skip_flag_r   =   mb_skip_flag_i[8 ];
            7'd77 :
                cu_skip_flag_r   =   mb_skip_flag_i[7 ];
            7'd78 :
                cu_skip_flag_r   =   mb_skip_flag_i[6 ];
            7'd79 :
                cu_skip_flag_r   =   mb_skip_flag_i[5 ];
            7'd80 :
                cu_skip_flag_r   =   mb_skip_flag_i[4 ];
            7'd81 :
                cu_skip_flag_r   =   mb_skip_flag_i[3 ];
            7'd82 :
                cu_skip_flag_r   =   mb_skip_flag_i[2 ];
            7'd83 :
                cu_skip_flag_r   =   mb_skip_flag_i[1 ];
            7'd84 :
                cu_skip_flag_r   =   mb_skip_flag_i[0 ];
            default :
                cu_skip_flag_r   =   1'b0               ;
        endcase
    end
    else 
        cu_skip_flag_r = 1'b0;
end

// cu_skip_top_flag_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        cu_skip_top_flag_r       <=    1'b0     ;
    end
    else
    begin
        case(cu_idx_r)
            7'd0 :
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[7]: 1'b0 ;
            7'd1 :
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[7]: 1'b0 ;
            7'd2 :
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[3]: 1'b0 ;
            7'd3 :
                cu_skip_top_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[15:14] == 2'd3 ? mb_skip_flag_i[53] : mb_skip_flag_i[77]) : mb_skip_flag_i[83];
            7'd4 :
                cu_skip_top_flag_r <= mb_p_pu_mode_i[5:4] == 2'd3 ? (mb_p_pu_mode_i[23:22] == 2'd3 ? mb_skip_flag_i[37] : mb_skip_flag_i[73]) : mb_skip_flag_i[82];
            7'd5 :
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[7]: 1'b0 ;
            7'd6 :
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[5]: 1'b0 ;
            7'd7 :
                cu_skip_top_flag_r <= mb_p_pu_mode_i[11:10] == 2'd3 ? mb_skip_flag_i[61] : mb_skip_flag_i[79];
            7'd8 :
                cu_skip_top_flag_r <= mb_p_pu_mode_i[13:12] == 2'd3 ? mb_skip_flag_i[57] : mb_skip_flag_i[78];
            7'd9 :
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[3]: 1'b0 ;
            7'd10:
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[1]: 1'b0 ;
            7'd11:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[19:18] == 2'd3 ? mb_skip_flag_i[45] : mb_skip_flag_i[75];
            7'd12:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[21:20] == 2'd3 ? mb_skip_flag_i[41] : mb_skip_flag_i[74];
            7'd13:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[15:14] == 2'd3 ? mb_skip_flag_i[53] : mb_skip_flag_i[77]) : mb_skip_flag_i[83];
            7'd14:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[17:16] == 2'd3 ? mb_skip_flag_i[49] : mb_skip_flag_i[76]) : mb_skip_flag_i[83];
            7'd15:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[27:26] == 2'd3 ? mb_skip_flag_i[29] : mb_skip_flag_i[71];
            7'd16:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[29:28] == 2'd3 ? mb_skip_flag_i[25] : mb_skip_flag_i[70];
            7'd17:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[5:4] == 2'd3 ? (mb_p_pu_mode_i[23:22] == 2'd3 ? mb_skip_flag_i[37] : mb_skip_flag_i[73]) : mb_skip_flag_i[82];
            7'd18:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[5:4] == 2'd3 ? (mb_p_pu_mode_i[25:24] == 2'd3 ? mb_skip_flag_i[33] : mb_skip_flag_i[72]) : mb_skip_flag_i[82];
            7'd19:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[35:34] == 2'd3 ? mb_skip_flag_i[13] : mb_skip_flag_i[67];
            7'd20:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[37:36] == 2'd3 ? mb_skip_flag_i[ 9] : mb_skip_flag_i[66];
            7'd21:
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[7]: 1'b0 ;
            7'd22:
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[6]: 1'b0 ;
            7'd23:
                cu_skip_top_flag_r <= mb_skip_flag_i[63]                  ;
            7'd24:
                cu_skip_top_flag_r <= mb_skip_flag_i[62]                  ;
            7'd25:
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[5]: 1'b0 ;
            7'd26:
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[4]: 1'b0 ;
            7'd27:
                cu_skip_top_flag_r <= mb_skip_flag_i[59]                  ;
            7'd28:
                cu_skip_top_flag_r <= mb_skip_flag_i[58]                  ;
            7'd29:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[11:10] == 2'd3 ? mb_skip_flag_i[61] : mb_skip_flag_i[79];
            7'd30:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[11:10] == 2'd3 ? mb_skip_flag_i[60] : mb_skip_flag_i[79];
            7'd31:
                cu_skip_top_flag_r <= mb_skip_flag_i[55]                  ;
            7'd32:
                cu_skip_top_flag_r <= mb_skip_flag_i[54]                  ;
            7'd33:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[13:12] == 2'd3 ? mb_skip_flag_i[57] : mb_skip_flag_i[78];
            7'd34:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[13:12] == 2'd3 ? mb_skip_flag_i[56] : mb_skip_flag_i[78];
            7'd35:
                cu_skip_top_flag_r <= mb_skip_flag_i[51]                  ;
            7'd36:
                cu_skip_top_flag_r <= mb_skip_flag_i[50]                  ;
            7'd37:
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[3]: 1'b0 ;
            7'd38:
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[2]: 1'b0 ;
            7'd39:
                cu_skip_top_flag_r <= mb_skip_flag_i[47]                  ;
            7'd40:
                cu_skip_top_flag_r <= mb_skip_flag_i[46]                  ;
            7'd41:
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[1]: 1'b0 ;
            7'd42:
                cu_skip_top_flag_r <= sys_mb_y_i ? r_data_neigh_mb_r[0]: 1'b0 ;
            7'd43:
                cu_skip_top_flag_r <= mb_skip_flag_i[43]                  ;
            7'd44:
                cu_skip_top_flag_r <= mb_skip_flag_i[42]                  ;
            7'd45:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[19:18] == 2'd3 ? mb_skip_flag_i[45] : mb_skip_flag_i[75];
            7'd46:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[19:18] == 2'd3 ? mb_skip_flag_i[44] : mb_skip_flag_i[75];
            7'd47:
                cu_skip_top_flag_r <= mb_skip_flag_i[39]                  ;
            7'd48:
                cu_skip_top_flag_r <= mb_skip_flag_i[38]                  ;
            7'd49:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[21:20] == 2'd3 ? mb_skip_flag_i[41] : mb_skip_flag_i[74];
            7'd50:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[21:20] == 2'd3 ? mb_skip_flag_i[40] : mb_skip_flag_i[74];
            7'd51:
                cu_skip_top_flag_r <= mb_skip_flag_i[35]                  ;
            7'd52:
                cu_skip_top_flag_r <= mb_skip_flag_i[34]                  ;
            7'd53:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[15:14] == 2'd3 ? mb_skip_flag_i[53] : mb_skip_flag_i[77]) : mb_skip_flag_i[83];
            7'd54:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[15:14] == 2'd3 ? mb_skip_flag_i[52] : mb_skip_flag_i[77]) : mb_skip_flag_i[83];
            7'd55:
                cu_skip_top_flag_r <= mb_skip_flag_i[31]                  ;
            7'd56:
                cu_skip_top_flag_r <= mb_skip_flag_i[30]                  ;
            7'd57:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[17:16] == 2'd3 ? mb_skip_flag_i[49] : mb_skip_flag_i[76]) : mb_skip_flag_i[83];
            7'd58:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[17:16] == 2'd3 ? mb_skip_flag_i[48] : mb_skip_flag_i[76]) : mb_skip_flag_i[83];
            7'd59:
                cu_skip_top_flag_r <= mb_skip_flag_i[27]                  ;
            7'd60:
                cu_skip_top_flag_r <= mb_skip_flag_i[26]                  ;
            7'd61:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[27:26] == 2'd3 ? mb_skip_flag_i[29] : mb_skip_flag_i[71];
            7'd62:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[27:26] == 2'd3 ? mb_skip_flag_i[28] : mb_skip_flag_i[71];
            7'd63:
                cu_skip_top_flag_r <= mb_skip_flag_i[23]                  ;
            7'd64:
                cu_skip_top_flag_r <= mb_skip_flag_i[22]                  ;
            7'd65:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[29:28] == 2'd3 ? mb_skip_flag_i[25] : mb_skip_flag_i[70];
            7'd66:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[29:28] == 2'd3 ? mb_skip_flag_i[24] : mb_skip_flag_i[70];
            7'd67:
                cu_skip_top_flag_r <= mb_skip_flag_i[19]                  ;
            7'd68:
                cu_skip_top_flag_r <= mb_skip_flag_i[18]                  ;
            7'd69:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[5:4] == 2'd3 ? (mb_p_pu_mode_i[23:22] == 2'd3 ? mb_skip_flag_i[37] : mb_skip_flag_i[73]) : mb_skip_flag_i[82];
            7'd70:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[5:4] == 2'd3 ? (mb_p_pu_mode_i[23:22] == 2'd3 ? mb_skip_flag_i[36] : mb_skip_flag_i[73]) : mb_skip_flag_i[82];
            7'd71:
                cu_skip_top_flag_r <= mb_skip_flag_i[15]                  ;
            7'd72:
                cu_skip_top_flag_r <= mb_skip_flag_i[14]                  ;
            7'd73:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[5:4] == 2'd3 ? (mb_p_pu_mode_i[25:24] == 2'd3 ? mb_skip_flag_i[33] : mb_skip_flag_i[72]) : mb_skip_flag_i[82];
            7'd74:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[5:4] == 2'd3 ? (mb_p_pu_mode_i[25:24] == 2'd3 ? mb_skip_flag_i[32] : mb_skip_flag_i[72]) : mb_skip_flag_i[82];
            7'd75:
                cu_skip_top_flag_r <= mb_skip_flag_i[11]                  ;
            7'd76:
                cu_skip_top_flag_r <= mb_skip_flag_i[10]                  ;
            7'd77:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[35:34] == 2'd3 ? mb_skip_flag_i[13] : mb_skip_flag_i[67];
            7'd78:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[35:34] == 2'd3 ? mb_skip_flag_i[12] : mb_skip_flag_i[67];
            7'd79:
                cu_skip_top_flag_r <= mb_skip_flag_i[7]                  ;
            7'd80:
                cu_skip_top_flag_r <= mb_skip_flag_i[6]                  ;
            7'd81:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[37:36] == 2'd3 ? mb_skip_flag_i[9] : mb_skip_flag_i[66];
            7'd82:
                cu_skip_top_flag_r <= mb_p_pu_mode_i[37:36] == 2'd3 ? mb_skip_flag_i[8] : mb_skip_flag_i[66];
            7'd83:
                cu_skip_top_flag_r <= mb_skip_flag_i[3]                  ;
            7'd84:
                cu_skip_top_flag_r <= mb_skip_flag_i[2]                  ;
            default:
                cu_skip_top_flag_r <= 1'd0                                ;
        endcase
    end
end

// cu_depth_left_r
always @*
begin
    case(cu_idx_r)
        7'd0  :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_0_r[1:0] :2'd0;
        7'd1  :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_0_r[1:0] :2'd0;
        7'd2  :
            cu_depth_left_r  =  cu_depth_0_2_r                 ;
        7'd3  :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_4_r[1:0] :2'd0;
        7'd4  :
            cu_depth_left_r  =  cu_depth_4_2_r                 ;
        7'd5  :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_0_r[1:0] :2'd0;
        7'd6  :
            cu_depth_left_r  =  cu_depth_0_0_r                 ;
        7'd7  :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_2_r[1:0] :2'd0;
        7'd8  :
            cu_depth_left_r  =  cu_depth_2_0_r                 ;
        7'd9  :
            cu_depth_left_r  =  cu_depth_0_2_r                 ;
        7'd10 :
            cu_depth_left_r  =  cu_depth_0_4_r                 ;
        7'd11 :
            cu_depth_left_r  =  cu_depth_2_2_r                 ;
        7'd12 :
            cu_depth_left_r  =  cu_depth_2_4_r                 ;
        7'd13 :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_4_r[1:0] :2'd0;
        7'd14 :
            cu_depth_left_r  =  cu_depth_4_0_r                 ;
        7'd15 :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_6_r[1:0]:2'd0;
        7'd16 :
            cu_depth_left_r  =  cu_depth_6_0_r                 ;
        7'd17 :
            cu_depth_left_r  =  cu_depth_4_2_r                 ;
        7'd18 :
            cu_depth_left_r  =  cu_depth_4_4_r                 ;
        7'd19 :
            cu_depth_left_r  =  cu_depth_6_2_r                 ;
        7'd20 :
            cu_depth_left_r  =  cu_depth_6_4_r                 ;
        7'd21 :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_0_r[1:0]:2'd0 ;
        7'd22 :
            cu_depth_left_r  =  cu_left_0_r[1:0]               ;
        7'd23 :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_0_r[1:0]:2'd0 ;
        7'd24 :
            cu_depth_left_r  =  cu_left_0_r[1:0]               ;
        7'd25 :
            cu_depth_left_r  =  cu_depth_0_0_r                 ;
        7'd26 :
            cu_depth_left_r  =  cu_depth_0_0_r                 ;
        7'd27 :
            cu_depth_left_r  =  cu_depth_0_0_r                 ;
        7'd28 :
            cu_depth_left_r  =  cu_depth_0_0_r                 ;
        7'd29 :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_1_r[1:0]:2'd0 ;
        7'd30 :
            cu_depth_left_r  =  cu_left_1_r[1:0]               ;
        7'd31 :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_1_r[1:0]:2'd0 ;
        7'd32 :
            cu_depth_left_r  =  cu_left_1_r[1:0]               ;
        7'd33 :
            cu_depth_left_r  =  cu_depth_2_0_r                 ;
        7'd34 :
            cu_depth_left_r  =  cu_depth_2_0_r                 ;
        7'd35 :
            cu_depth_left_r  =  cu_depth_2_0_r                 ;
        7'd36 :
            cu_depth_left_r  =  cu_depth_2_0_r                 ;
        7'd37 :
            cu_depth_left_r  =  cu_depth_0_2_r                 ;
        7'd38 :
            cu_depth_left_r  =  cu_depth_0_2_r                 ;
        7'd39 :
            cu_depth_left_r  =  cu_depth_0_2_r                 ;
        7'd40 :
            cu_depth_left_r  =  cu_depth_0_2_r                 ;
        7'd41 :
            cu_depth_left_r  =  cu_depth_0_4_r                 ;
        7'd42 :
            cu_depth_left_r  =  cu_depth_0_4_r                 ;
        7'd43 :
            cu_depth_left_r  =  cu_depth_0_4_r                 ;
        7'd44 :
            cu_depth_left_r  =  cu_depth_0_4_r                 ;
        7'd45 :
            cu_depth_left_r  =  cu_depth_2_2_r                 ;
        7'd46 :
            cu_depth_left_r  =  cu_depth_2_2_r                 ;
        7'd47 :
            cu_depth_left_r  =  cu_depth_2_2_r                 ;
        7'd48 :
            cu_depth_left_r  =  cu_depth_2_2_r                 ;
        7'd49 :
            cu_depth_left_r  =  cu_depth_2_4_r                 ;
        7'd50 :
            cu_depth_left_r  =  cu_depth_2_4_r                 ;
        7'd51 :
            cu_depth_left_r  =  cu_depth_2_4_r                 ;
        7'd52 :
            cu_depth_left_r  =  cu_depth_2_4_r                 ;
        7'd53 :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_4_r[1:0]:2'd0 ;
        7'd54 :
            cu_depth_left_r  =  cu_left_4_r[1:0]               ;
        7'd55 :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_4_r[1:0]:2'd0 ;
        7'd56 :
            cu_depth_left_r  =  cu_left_4_r[1:0]               ;
        7'd57 :
            cu_depth_left_r  =  cu_depth_4_0_r                 ;
        7'd58 :
            cu_depth_left_r  =  cu_depth_4_0_r                 ;
        7'd59 :
            cu_depth_left_r  =  cu_depth_4_0_r                 ;
        7'd60 :
            cu_depth_left_r  =  cu_depth_4_0_r                 ;
        7'd61 :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_6_r[1:0]:2'd0;
        7'd62 :
            cu_depth_left_r  =  cu_left_6_r[1:0]              ;
        7'd63 :
            cu_depth_left_r  =  sys_mb_x_i ? cu_left_6_r[1:0]:2'd0;
        7'd64 :
            cu_depth_left_r  =  cu_left_6_r[1:0]              ;
        7'd65 :
            cu_depth_left_r  =  cu_depth_6_0_r                 ;
        7'd66 :
            cu_depth_left_r  =  cu_depth_6_0_r                 ;
        7'd67 :
            cu_depth_left_r  =  cu_depth_6_0_r                 ;
        7'd68 :
            cu_depth_left_r  =  cu_depth_6_0_r                 ;
        7'd69 :
            cu_depth_left_r  =  cu_depth_4_2_r                 ;
        7'd70 :
            cu_depth_left_r  =  cu_depth_4_2_r                 ;
        7'd71 :
            cu_depth_left_r  =  cu_depth_4_2_r                 ;
        7'd72 :
            cu_depth_left_r  =  cu_depth_4_2_r                 ;
        7'd73 :
            cu_depth_left_r  =  cu_depth_4_4_r                 ;
        7'd74 :
            cu_depth_left_r  =  cu_depth_4_4_r                 ;
        7'd75 :
            cu_depth_left_r  =  cu_depth_4_4_r                 ;
        7'd76 :
            cu_depth_left_r  =  cu_depth_4_4_r                 ;
        7'd77 :
            cu_depth_left_r  =  cu_depth_6_2_r                 ;
        7'd78 :
            cu_depth_left_r  =  cu_depth_6_2_r                 ;
        7'd79 :
            cu_depth_left_r  =  cu_depth_6_2_r                 ;
        7'd80 :
            cu_depth_left_r  =  cu_depth_6_2_r                 ;
        7'd81 :
            cu_depth_left_r  =  cu_depth_6_4_r                 ;
        7'd82 :
            cu_depth_left_r  =  cu_depth_6_4_r                 ;
        7'd83 :
            cu_depth_left_r  =  cu_depth_6_4_r                 ;
        7'd84 :
            cu_depth_left_r  =  cu_depth_6_4_r                 ;
        default:
            cu_depth_left_r  =  2'd0                           ;
    endcase
end

// cu_skip_left_flag_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        cu_skip_left_flag_r       <=    1'b0     ;
    end
    else
    begin
        case(cu_idx_r)
            7'd0 :
                cu_skip_left_flag_r <= sys_mb_x_i ?  cu_left_0_r[8]:1'b0 ;
            7'd1 :
                cu_skip_left_flag_r <= sys_mb_x_i ?  cu_left_0_r[8]:1'b0 ;
            7'd2 :
                cu_skip_left_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[13:12] == 2'd3 ? mb_skip_flag_i[58] : mb_skip_flag_i[78]) : mb_skip_flag_i[83];
            7'd3 :
                cu_skip_left_flag_r <= sys_mb_x_i ?  cu_left_4_r[8]:1'b0 ;
            7'd4 :
                cu_skip_left_flag_r <= mb_p_pu_mode_i[7:6] == 2'd3 ? (mb_p_pu_mode_i[29:28] == 2'd3 ? mb_skip_flag_i[26] : mb_skip_flag_i[70]) : mb_skip_flag_i[81];
            7'd5 :
                cu_skip_left_flag_r <= sys_mb_x_i ?  cu_left_0_r[8]:1'b0 ;
            7'd6 :
                cu_skip_left_flag_r <= mb_p_pu_mode_i[11:10] == 2'd3 ? mb_skip_flag_i[62] : mb_skip_flag_i[79];
            7'd7 :
                cu_skip_left_flag_r <= sys_mb_x_i ?  cu_left_2_r[8]:1'b0 ;
            7'd8 :
                cu_skip_left_flag_r <= mb_p_pu_mode_i[15:14] == 2'd3 ? mb_skip_flag_i[54] : mb_skip_flag_i[77];
            7'd9 :
                cu_skip_left_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[13:12] == 2'd3 ? mb_skip_flag_i[58] : mb_skip_flag_i[78]) : mb_skip_flag_i[83];
            7'd10:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[19:18] == 2'd3 ? mb_skip_flag_i[46] : mb_skip_flag_i[75];
            7'd11:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[17:16] == 2'd3 ? mb_skip_flag_i[50] : mb_skip_flag_i[76]) : mb_skip_flag_i[83];
            7'd12:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[23:22] == 2'd3 ? mb_skip_flag_i[38] : mb_skip_flag_i[73];
            7'd13:
                cu_skip_left_flag_r <= sys_mb_x_i ?  cu_left_4_r[8]:1'b0 ;
            7'd14:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[27:26] == 2'd3 ? mb_skip_flag_i[30] : mb_skip_flag_i[71];
            7'd15:
                cu_skip_left_flag_r <= sys_mb_x_i ?  cu_left_6_r[8]:1'b0 ;
            7'd16:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[31:30] == 2'd3 ? mb_skip_flag_i[22] : mb_skip_flag_i[69];
            7'd17:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[7:6] == 2'd3 ? (mb_p_pu_mode_i[29:28] == 2'd3 ? mb_skip_flag_i[26] : mb_skip_flag_i[70]) : mb_skip_flag_i[81];
            7'd18:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[35:34] == 2'd3 ? mb_skip_flag_i[14] : mb_skip_flag_i[67];
            7'd19:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[7:6] == 2'd3 ? (mb_p_pu_mode_i[33:32] == 2'd3 ? mb_skip_flag_i[18] : mb_skip_flag_i[68]) : mb_skip_flag_i[81];
            7'd20:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[39:38] == 2'd3 ? mb_skip_flag_i[6] : mb_skip_flag_i[65];
            7'd21:
                cu_skip_left_flag_r <= sys_mb_x_i ? cu_left_0_r[8]:1'b0  ;
            7'd22:
                cu_skip_left_flag_r <= mb_skip_flag_i[63 ]            ;
            7'd23:
                cu_skip_left_flag_r <= sys_mb_x_i ? cu_left_1_r[8]:1'b0  ;
            7'd24:
                cu_skip_left_flag_r <= mb_skip_flag_i[61 ]            ;
            7'd25:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[11:10] == 2'd3 ? mb_skip_flag_i[62] : mb_skip_flag_i[79];
            7'd26:
                cu_skip_left_flag_r <= mb_skip_flag_i[59 ]            ;
            7'd27:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[11:10] == 2'd3 ? mb_skip_flag_i[60] : mb_skip_flag_i[79];
            7'd28:
                cu_skip_left_flag_r <= mb_skip_flag_i[57 ]            ;
            7'd29:
                cu_skip_left_flag_r <= sys_mb_x_i ? cu_left_2_r[8]:1'b0  ;
            7'd30:
                cu_skip_left_flag_r <= mb_skip_flag_i[55 ]            ;
            7'd31:
                cu_skip_left_flag_r <= sys_mb_x_i ? cu_left_3_r[8]:1'b0  ;
            7'd32:
                cu_skip_left_flag_r <= mb_skip_flag_i[53]            ;
            7'd33:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[15:14] == 2'd3 ? mb_skip_flag_i[54] : mb_skip_flag_i[77];
            7'd34:
                cu_skip_left_flag_r <= mb_skip_flag_i[51]            ;
            7'd35:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[15:14] == 2'd3 ? mb_skip_flag_i[52] : mb_skip_flag_i[77];
            7'd36:
                cu_skip_left_flag_r <= mb_skip_flag_i[49]            ;
            7'd37:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[13:12] == 2'd3 ? mb_skip_flag_i[58] : mb_skip_flag_i[78]) : mb_skip_flag_i[83];
            7'd38:
                cu_skip_left_flag_r <= mb_skip_flag_i[47]            ;
            7'd39:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[13:12] == 2'd3 ? mb_skip_flag_i[56] : mb_skip_flag_i[78]) : mb_skip_flag_i[83];
            7'd40:
                cu_skip_left_flag_r <= mb_skip_flag_i[45]            ;
            7'd41:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[19:18] == 2'd3 ? mb_skip_flag_i[46] : mb_skip_flag_i[75];
            7'd42:
                cu_skip_left_flag_r <= mb_skip_flag_i[43]            ;
            7'd43:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[19:18] == 2'd3 ? mb_skip_flag_i[44] : mb_skip_flag_i[75];
            7'd44:
                cu_skip_left_flag_r <= mb_skip_flag_i[41]            ;
            7'd45:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[17:16] == 2'd3 ? mb_skip_flag_i[50] : mb_skip_flag_i[76]) : mb_skip_flag_i[83];
            7'd46:
                cu_skip_left_flag_r <= mb_skip_flag_i[39]            ;
            7'd47:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[3:2] == 2'd3 ? (mb_p_pu_mode_i[17:16] == 2'd3 ? mb_skip_flag_i[48] : mb_skip_flag_i[76]) : mb_skip_flag_i[83];
            7'd48:
                cu_skip_left_flag_r <= mb_skip_flag_i[37]            ;
            7'd49:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[23:22] == 2'd3 ? mb_skip_flag_i[38] : mb_skip_flag_i[73];
            7'd50:
                cu_skip_left_flag_r <= mb_skip_flag_i[35]            ;
            7'd51:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[23:22] == 2'd3 ? mb_skip_flag_i[36] : mb_skip_flag_i[73];
            7'd52:
                cu_skip_left_flag_r <= mb_skip_flag_i[33]            ;
            7'd53:
                cu_skip_left_flag_r <= sys_mb_x_i ? cu_left_4_r[8]:1'b0  ;
            7'd54:
                cu_skip_left_flag_r <= mb_skip_flag_i[31]            ;
            7'd55:
                cu_skip_left_flag_r <= sys_mb_x_i ? cu_left_5_r[8]:1'b0  ;
            7'd56:
                cu_skip_left_flag_r <= mb_skip_flag_i[29]            ;
            7'd57:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[27:26] == 2'd3 ? mb_skip_flag_i[30] : mb_skip_flag_i[71];
            7'd58:
                cu_skip_left_flag_r <= mb_skip_flag_i[27]            ;
            7'd59:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[27:26] == 2'd3 ? mb_skip_flag_i[28] : mb_skip_flag_i[71];
            7'd60:
                cu_skip_left_flag_r <= mb_skip_flag_i[25]            ;
            7'd61:
                cu_skip_left_flag_r <= sys_mb_x_i ? cu_left_6_r[8]:1'b0  ;
            7'd62:
                cu_skip_left_flag_r <= mb_skip_flag_i[23]            ;
            7'd63:
                cu_skip_left_flag_r <= sys_mb_x_i ? cu_left_7_r[8]:1'b0  ;
            7'd64:
                cu_skip_left_flag_r <= mb_skip_flag_i[21]            ;
            7'd65:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[31:30] == 2'd3 ? mb_skip_flag_i[22] : mb_skip_flag_i[69];
            7'd66:
                cu_skip_left_flag_r <= mb_skip_flag_i[19]            ;
            7'd67:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[31:30] == 2'd3 ? mb_skip_flag_i[20] : mb_skip_flag_i[69];
            7'd68:
                cu_skip_left_flag_r <= mb_skip_flag_i[17]            ;
            7'd69:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[7:6] == 2'd3 ? (mb_p_pu_mode_i[29:28] == 2'd3 ? mb_skip_flag_i[26] : mb_skip_flag_i[70]) : mb_skip_flag_i[81];
            7'd70:
                cu_skip_left_flag_r <= mb_skip_flag_i[15]            ;
            7'd71:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[7:6] == 2'd3 ? (mb_p_pu_mode_i[29:28] == 2'd3 ? mb_skip_flag_i[24] : mb_skip_flag_i[70]) : mb_skip_flag_i[81];
            7'd72:
                cu_skip_left_flag_r <= mb_skip_flag_i[13]            ;
            7'd73:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[35:34] == 2'd3 ? mb_skip_flag_i[14] : mb_skip_flag_i[67];
            7'd74:
                cu_skip_left_flag_r <= mb_skip_flag_i[11]            ;
            7'd75:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[35:34] == 2'd3 ? mb_skip_flag_i[12] : mb_skip_flag_i[67];
            7'd76:
                cu_skip_left_flag_r <= mb_skip_flag_i[9]            ;
            7'd77:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[7:6] == 2'd3 ? (mb_p_pu_mode_i[33:32] == 2'd3 ? mb_skip_flag_i[18] : mb_skip_flag_i[68]) : mb_skip_flag_i[81];
            7'd78:
                cu_skip_left_flag_r <= mb_skip_flag_i[7]            ;
            7'd79:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[7:6] == 2'd3 ? (mb_p_pu_mode_i[33:32] == 2'd3 ? mb_skip_flag_i[16] : mb_skip_flag_i[68]) : mb_skip_flag_i[81];
            7'd80:
                cu_skip_left_flag_r <= mb_skip_flag_i[5]            ;
            7'd81:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[39:38] == 2'd3 ? mb_skip_flag_i[6] : mb_skip_flag_i[65];
            7'd82:
                cu_skip_left_flag_r <= mb_skip_flag_i[3]            ;
            7'd83:
                cu_skip_left_flag_r <= mb_p_pu_mode_i[39:38] == 2'd3 ? mb_skip_flag_i[4] : mb_skip_flag_i[65];
            7'd84:
                cu_skip_left_flag_r <= mb_skip_flag_i[1]            ;
            default:
                cu_skip_left_flag_r <=1'b0                           ;
        endcase
    end
end


// cu_mvd_ren_r
/*
always @(posedge clk or negedge rst_n) begin 
    if(!rst_n)
        cu_mvd_ren_r  <=  1'b1 ;
    else if(sys_slice_type_i)
        cu_mvd_ren_r  <=  1'b1 ;
    else if(cu_start_d1_r || cu_start_d2_r)
        cu_mvd_ren_r  <=  1'b0 ;    
    else 
        cu_mvd_ren_r  <=  1'b1 ;
end*/
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_mvd_ren_r <= 1'b1;
    else if(sys_slice_type_i)
        cu_mvd_ren_r <= 1'b1;
    else if(cu_start_ori_w || cu_start_d1_r)
        cu_mvd_ren_r <= 1'b0;
    else
        cu_mvd_ren_r <= 1'b1;
end

wire [1:0] cu_inter_part_size_temp_w = {cu_inter_part_size_r[0],cu_inter_part_size_r[1]} ;

// cu_mvd_raddr_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_mvd_raddr_r  <=  6'd0    ;
    else if(cu_start_ori_w)
    begin
        case(cu_depth_r)
            2'd0:
                cu_mvd_raddr_r <= {2'd0,4'd0}                   ; // 64x64: 0000
            2'd1:
                cu_mvd_raddr_r <= {cu_idx_minus1_w[1:0],4'b0000}; // 32x32: 000000 010000 100000 110000
            2'd2:
                cu_mvd_raddr_r <= {cu_idx_minus5_w[3:0],2'b00  }; // 16x16: 0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60
            2'd3:
                cu_mvd_raddr_r <=  cu_idx_minus21_w             ; // 8x8
        endcase
    end
    else if(cu_start_d1_r)
    begin
        case(cu_depth_r)
            2'd0:
                cu_mvd_raddr_r <= {cu_inter_part_size_temp_w,4'd0}                       ; // 64x64 2NxN:+32 Nx2N:+16
            2'd1:
                cu_mvd_raddr_r <= {cu_idx_minus1_w[1:0],cu_inter_part_size_temp_w,2'b00} ; // 32x32 2NxN:+8  Nx2N:+4 2Nx2N:+0
            2'd2:
                cu_mvd_raddr_r <= {cu_idx_minus5_w[3:0],cu_inter_part_size_temp_w      } ; // 16x16 2NxN:+2  Nx2N:+1 2Nx2N:+0
            2'd3:
                cu_mvd_raddr_r <=  cu_idx_minus21_w                                      ; // 8x8
        endcase
    end
end

// cu_mvd_data_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_mvd_data_r    <=   46'd0;
    else if(cu_start_d2_r)
        cu_mvd_data_r    <=  {23'b0,mb_mvd_data_i};
    else if(cu_start_d3_r)
        cu_mvd_data_r    <=  {cu_mvd_data_r[2*`MVD_WIDTH:0],mb_mvd_data_i};
end


// mode info
// mb_i_luma_mode_ren_o
always @*
begin
    if(cu_start_ori_w || cu_start_d1_r || cu_start_d2_r)
        mb_i_luma_mode_ren_o  =  1'b0;
    else
        mb_i_luma_mode_ren_o  =  1'b1;
end

// mb_i_luma_mode_addr_o
always @*
begin
    if(cu_start_ori_w )
        mb_i_luma_mode_addr_o  =  cu_luma_left_mode_raddr_r;
    else if(cu_start_d1_r)
        mb_i_luma_mode_addr_o  =  cu_luma_mode_raddr_r     ;
    else if(cu_start_d2_r)
        mb_i_luma_mode_addr_o  =  cu_luma_top_mode_raddr_r ;
    else
        mb_i_luma_mode_addr_o  =  6'd0                     ;
end

// cu_luma_mode_raddr_r
always @*
begin
    case(cu_idx_r)
        7'd0 :
            cu_luma_mode_raddr_r  =  6'd0             ;
        7'd1 :
            cu_luma_mode_raddr_r  =  6'd0             ;
        7'd2 :
            cu_luma_mode_raddr_r  =  6'd16            ;
        7'd3 :
            cu_luma_mode_raddr_r  =  6'd32            ;
        7'd4 :
            cu_luma_mode_raddr_r  =  6'd48            ;
        7'd5 :
            cu_luma_mode_raddr_r  =  6'd0             ;
        7'd6 :
            cu_luma_mode_raddr_r  =  6'd4             ;
        7'd7 :
            cu_luma_mode_raddr_r  =  6'd8             ;
        7'd8 :
            cu_luma_mode_raddr_r  =  6'd12            ;
        7'd9 :
            cu_luma_mode_raddr_r  =  6'd16            ;
        7'd10:
            cu_luma_mode_raddr_r  =  6'd20            ;
        7'd11:
            cu_luma_mode_raddr_r  =  6'd24            ;
        7'd12:
            cu_luma_mode_raddr_r  =  6'd28            ;
        7'd13:
            cu_luma_mode_raddr_r  =  6'd32            ;
        7'd14:
            cu_luma_mode_raddr_r  =  6'd36            ;
        7'd15:
            cu_luma_mode_raddr_r  =  6'd40            ;
        7'd16:
            cu_luma_mode_raddr_r  =  6'd44            ;
        7'd17:
            cu_luma_mode_raddr_r  =  6'd48            ;
        7'd18:
            cu_luma_mode_raddr_r  =  6'd52            ;
        7'd19:
            cu_luma_mode_raddr_r  =  6'd56            ;
        7'd20:
            cu_luma_mode_raddr_r  =  6'd60            ;
        default:
            cu_luma_mode_raddr_r  =  cu_idx_r - 5'd21 ;

    endcase
end


// cu_luma_top_mode_raddr_r
always @*
begin
    case(cu_idx_r)
        7'd3 :
            cu_luma_top_mode_raddr_r  =  cu_depth_2_0_r==2'd3 ? 6'd10 :(cu_depth_2_0_r==2'd2 ? 6'd8 :6'd0 );
        7'd4 :
            cu_luma_top_mode_raddr_r  =  cu_depth_2_4_r==2'd3 ? 6'd26 :(cu_depth_2_4_r==2'd2 ? 6'd24:6'd16);
        7'd7 :
            cu_luma_top_mode_raddr_r  =  cu_depth_0_0_r==2'd3 ? 6'd2  :6'd0                                ;
        7'd8 :
            cu_luma_top_mode_raddr_r  =  cu_depth_0_2_r==2'd3 ? 6'd6  :6'd4                                ;
        7'd11:
            cu_luma_top_mode_raddr_r  =  cu_depth_0_4_r==2'd3 ? 6'd18 :6'd16                               ;
        7'd12:
            cu_luma_top_mode_raddr_r  =  cu_depth_0_6_r==2'd3 ? 6'd22 :6'd20                               ;
        7'd13:
            cu_luma_top_mode_raddr_r  =  cu_depth_2_0_r==2'd3 ? 6'd10 :(cu_depth_2_0_r==2'd2 ? 6'd8 :6'd0 );
        7'd14:
            cu_luma_top_mode_raddr_r  =  cu_depth_2_2_r==2'd3 ? 6'd14 :(cu_depth_2_2_r==2'd2 ? 6'd12:6'd0 );
        7'd15:
            cu_luma_top_mode_raddr_r  =  cu_depth_4_0_r==2'd3 ? 6'd34 :6'd32                               ;
        7'd16:
            cu_luma_top_mode_raddr_r  =  cu_depth_4_2_r==2'd3 ? 6'd38 :6'd36                               ;
        7'd17:
            cu_luma_top_mode_raddr_r  =  cu_depth_2_4_r==2'd3 ? 6'd26 :(cu_depth_2_4_r==2'd2 ? 6'd24:6'd16);
        7'd18:
            cu_luma_top_mode_raddr_r  =  cu_depth_2_6_r==2'd3 ? 6'd30 :(cu_depth_2_6_r==2'd2 ? 6'd28:6'd16);
        7'd19:
            cu_luma_top_mode_raddr_r  =  cu_depth_4_4_r==2'd3 ? 6'd50 :6'd48                               ;
        7'd20:
            cu_luma_top_mode_raddr_r  =  cu_depth_4_6_r==2'd3 ? 6'd54 :6'd52                               ;
        7'd23:
            cu_luma_top_mode_raddr_r  =  6'd0                                                              ;
        7'd24:
            cu_luma_top_mode_raddr_r  =  6'd1                                                              ;
        7'd27:
            cu_luma_top_mode_raddr_r  =  6'd4                                                              ;
        7'd28:
            cu_luma_top_mode_raddr_r  =  6'd5                                                              ;
        7'd29:
            cu_luma_top_mode_raddr_r  =  cu_depth_0_0_r==2'd3 ? 6'd2  :6'd0                                ;
        7'd30:
            cu_luma_top_mode_raddr_r  =  cu_depth_0_0_r==2'd3 ? 6'd3  :6'd0                                ;
        7'd31:
            cu_luma_top_mode_raddr_r  =  6'd8                                                              ;
        7'd32:
            cu_luma_top_mode_raddr_r  =  6'd9                                                              ;
        7'd33:
            cu_luma_top_mode_raddr_r  =  cu_depth_0_2_r==2'd3 ? 6'd6  :6'd4                                ;
        7'd34:
            cu_luma_top_mode_raddr_r  =  cu_depth_0_2_r==2'd3 ? 6'd7  :6'd4                                ;
        7'd35:
            cu_luma_top_mode_raddr_r  =  6'd12                                                             ;
        7'd36:
            cu_luma_top_mode_raddr_r  =  6'd13                                                             ;
        7'd39:
            cu_luma_top_mode_raddr_r  =  6'd16                                                             ;
        7'd40:
            cu_luma_top_mode_raddr_r  =  6'd17                                                             ;
        7'd43:
            cu_luma_top_mode_raddr_r  =  6'd20                                                             ;
        7'd44:
            cu_luma_top_mode_raddr_r  =  6'd21                                                             ;
        7'd45:
            cu_luma_top_mode_raddr_r  =  cu_depth_0_4_r==2'd3 ? 6'd18 :6'd16                               ;
        7'd46:
            cu_luma_top_mode_raddr_r  =  cu_depth_0_4_r==2'd3 ? 6'd19 :6'd16                               ;
        7'd47:
            cu_luma_top_mode_raddr_r  =  6'd24                                                             ;
        7'd48:
            cu_luma_top_mode_raddr_r  =  6'd25                                                             ;
        7'd49:
            cu_luma_top_mode_raddr_r  =  cu_depth_0_6_r==2'd3 ? 6'd22 :6'd20                               ;
        7'd50:
            cu_luma_top_mode_raddr_r  =  cu_depth_0_6_r==2'd3 ? 6'd23 :6'd20                               ;
        7'd51:
            cu_luma_top_mode_raddr_r  =  6'd28                                                             ;
        7'd52:
            cu_luma_top_mode_raddr_r  =  6'd29                                                             ;
        7'd53:
            cu_luma_top_mode_raddr_r  =  cu_depth_2_0_r==2'd3 ? 6'd10 :(cu_depth_2_0_r==2'd2 ? 6'd8 :6'd0 );
        7'd54:
            cu_luma_top_mode_raddr_r  =  cu_depth_2_0_r==2'd3 ? 6'd11 :(cu_depth_2_0_r==2'd2 ? 6'd8 :6'd0 );
        7'd55:
            cu_luma_top_mode_raddr_r  =  6'd32                                                             ;
        7'd56:
            cu_luma_top_mode_raddr_r  =  6'd33                                                             ;
        7'd57:
            cu_luma_top_mode_raddr_r  =  cu_depth_2_2_r==2'd3 ? 6'd14 :(cu_depth_2_2_r==2'd2 ? 6'd12:6'd0 );
        7'd58:
            cu_luma_top_mode_raddr_r  =  cu_depth_2_2_r==2'd3 ? 6'd15 :(cu_depth_2_2_r==2'd2 ? 6'd12:6'd0 );
        7'd59:
            cu_luma_top_mode_raddr_r  =  6'd36                                                             ;
        7'd60:
            cu_luma_top_mode_raddr_r  =  6'd37                                                             ;
        7'd61:
            cu_luma_top_mode_raddr_r  =  cu_depth_4_0_r==2'd3 ? 6'd34 :6'd32                               ;
        7'd62:
            cu_luma_top_mode_raddr_r  =  cu_depth_4_0_r==2'd3 ? 6'd35 :6'd32                               ;
        7'd63:
            cu_luma_top_mode_raddr_r  =  6'd40                                                             ;
        7'd64:
            cu_luma_top_mode_raddr_r  =  6'd41                                                             ;
        7'd65:
            cu_luma_top_mode_raddr_r  =  cu_depth_4_2_r==2'd3 ? 6'd38 :6'd36                               ;
        7'd66:
            cu_luma_top_mode_raddr_r  =  cu_depth_4_2_r==2'd3 ? 6'd39 :6'd36                               ;
        7'd67:
            cu_luma_top_mode_raddr_r  =  6'd44                                                             ;
        7'd68:
            cu_luma_top_mode_raddr_r  =  6'd45                                                             ;
        7'd69:
            cu_luma_top_mode_raddr_r  =  cu_depth_2_4_r==2'd3 ? 6'd26 :(cu_depth_2_4_r==2'd2 ? 6'd24:6'd16);
        7'd70:
            cu_luma_top_mode_raddr_r  =  cu_depth_2_4_r==2'd3 ? 6'd27 :(cu_depth_2_4_r==2'd2 ? 6'd24:6'd16);
        7'd71:
            cu_luma_top_mode_raddr_r  =  6'd48                                                             ;
        7'd72:
            cu_luma_top_mode_raddr_r  =  6'd49                                                             ;
        7'd73:
            cu_luma_top_mode_raddr_r  =  cu_depth_2_6_r==2'd3 ? 6'd30 :(cu_depth_2_6_r==2'd2 ? 6'd28:6'd16);
        7'd74:
            cu_luma_top_mode_raddr_r  =  cu_depth_2_6_r==2'd3 ? 6'd31 :(cu_depth_2_6_r==2'd2 ? 6'd28:6'd16);
        7'd75:
            cu_luma_top_mode_raddr_r  =  6'd52                                                             ;
        7'd76:
            cu_luma_top_mode_raddr_r  =  6'd53                                                             ;
        7'd77:
            cu_luma_top_mode_raddr_r  =  cu_depth_4_4_r==2'd3 ? 6'd50 :6'd48                               ;
        7'd78:
            cu_luma_top_mode_raddr_r  =  cu_depth_4_4_r==2'd3 ? 6'd51 :6'd48                               ;
        7'd79:
            cu_luma_top_mode_raddr_r  =  6'd56                                                             ;
        7'd80:
            cu_luma_top_mode_raddr_r  =  6'd57                                                             ;
        7'd81:
            cu_luma_top_mode_raddr_r  =  cu_depth_4_6_r==2'd3 ? 6'd54 :6'd52                               ;
        7'd82:
            cu_luma_top_mode_raddr_r  =  cu_depth_4_6_r==2'd3 ? 6'd55 :6'd52                               ;
        7'd83:
            cu_luma_top_mode_raddr_r  =  6'd60                                                             ;
        7'd84:
            cu_luma_top_mode_raddr_r  =  6'd61                                                             ;
        default:
            cu_luma_top_mode_raddr_r  =  6'd0                                                              ;
    endcase
end

// cu_luma_left_mode_raddr_r
always @*
begin
    case(cu_idx_r)
        7'd2 :
            cu_luma_left_mode_raddr_r = cu_depth_0_2_r==2'd3 ? 6'd5 :(cu_depth_0_2_r==2'd2 ? 6'd4 :6'd0 );
        7'd4 :
            cu_luma_left_mode_raddr_r = cu_depth_4_2_r==2'd3 ? 6'd37:(cu_depth_4_2_r==2'd2 ? 6'd36:6'd32);
        7'd6 :
            cu_luma_left_mode_raddr_r = cu_depth_0_0_r==2'd3 ? 6'd1 :6'd0                                ;
        7'd8 :
            cu_luma_left_mode_raddr_r = cu_depth_2_0_r==2'd3 ? 6'd9 :6'd8                                ;
        7'd9 :
            cu_luma_left_mode_raddr_r = cu_depth_0_2_r==2'd3 ? 6'd5 :(cu_depth_0_2_r==2'd2 ? 6'd4 :6'd0 );
        7'd10:
            cu_luma_left_mode_raddr_r = cu_depth_0_4_r==2'd3 ? 6'd17:6'd16                               ;
        7'd11:
            cu_luma_left_mode_raddr_r = cu_depth_2_2_r==2'd3 ? 6'd13:(cu_depth_2_2_r==2'd2 ? 6'd12:6'd0 );
        7'd12:
            cu_luma_left_mode_raddr_r = cu_depth_2_4_r==2'd3 ? 6'd25:6'd24                               ;
        7'd14:
            cu_luma_left_mode_raddr_r = cu_depth_4_0_r==2'd3 ? 6'd33:6'd32                               ;
        7'd16:
            cu_luma_left_mode_raddr_r = cu_depth_6_0_r==2'd3 ? 6'd41:6'd40                               ;
        7'd17:
            cu_luma_left_mode_raddr_r = cu_depth_4_2_r==2'd3 ? 6'd37:(cu_depth_4_2_r==2'd2 ? 6'd36:6'd32);
        7'd18:
            cu_luma_left_mode_raddr_r = cu_depth_4_4_r==2'd3 ? 6'd49:6'd48                               ;
        7'd19:
            cu_luma_left_mode_raddr_r = cu_depth_6_2_r==2'd3 ? 6'd45:(cu_depth_6_2_r==2'd2 ? 6'd44:6'd32);
        7'd20:
            cu_luma_left_mode_raddr_r = cu_depth_6_4_r==2'd3 ? 6'd57:6'd56                               ;
        7'd22:
            cu_luma_left_mode_raddr_r = 6'd0                                                             ;
        7'd24:
            cu_luma_left_mode_raddr_r = 6'd2                                                             ;
        7'd25:
            cu_luma_left_mode_raddr_r = cu_depth_0_0_r==2'd3 ? 6'd1 :6'd0                                ;
        7'd26:
            cu_luma_left_mode_raddr_r = 6'd4                                                             ;
        7'd27:
            cu_luma_left_mode_raddr_r = cu_depth_0_0_r==2'd3 ? 6'd3 :6'd0                                ;
        7'd28:
            cu_luma_left_mode_raddr_r = 6'd6                                                             ;
        7'd30:
            cu_luma_left_mode_raddr_r = 6'd8                                                             ;
        7'd32:
            cu_luma_left_mode_raddr_r = 6'd10                                                            ;
        7'd33:
            cu_luma_left_mode_raddr_r = cu_depth_2_0_r==2'd3 ? 6'd9 :6'd8                                ;
        7'd34:
            cu_luma_left_mode_raddr_r = 6'd12                                                            ;
        7'd35:
            cu_luma_left_mode_raddr_r = cu_depth_2_0_r==2'd3 ? 6'd11:6'd8                                ;
        7'd36:
            cu_luma_left_mode_raddr_r = 6'd14                                                            ;
        7'd37:
            cu_luma_left_mode_raddr_r = cu_depth_0_2_r==2'd3 ? 6'd5 :(cu_depth_0_2_r==2'd2 ? 6'd4 :6'd0 );
        7'd38:
            cu_luma_left_mode_raddr_r = 6'd16                                                            ;
        7'd39:
            cu_luma_left_mode_raddr_r = cu_depth_0_2_r==2'd3 ? 6'd7 :(cu_depth_0_2_r==2'd2 ? 6'd4 :6'd0 );
        7'd40:
            cu_luma_left_mode_raddr_r = 6'd18                                                            ;
        7'd41:
            cu_luma_left_mode_raddr_r = cu_depth_0_4_r==2'd3 ? 6'd17:6'd16                               ;
        7'd42:
            cu_luma_left_mode_raddr_r = 6'd20                                                            ;
        7'd43:
            cu_luma_left_mode_raddr_r = cu_depth_0_4_r==2'd3 ? 6'd19:6'd16                               ;
        7'd44:
            cu_luma_left_mode_raddr_r = 6'd22                                                            ;
        7'd45:
            cu_luma_left_mode_raddr_r = cu_depth_2_2_r==2'd3 ? 6'd13:(cu_depth_2_2_r==2'd2 ? 6'd12:6'd0 );
        7'd46:
            cu_luma_left_mode_raddr_r = 6'd24                                                            ;
        7'd47:
            cu_luma_left_mode_raddr_r = cu_depth_2_2_r==2'd3 ? 6'd15:(cu_depth_2_2_r==2'd2 ? 6'd12:6'd0 );
        7'd48:
            cu_luma_left_mode_raddr_r = 6'd26                                                            ;
        7'd49:
            cu_luma_left_mode_raddr_r = cu_depth_2_4_r==2'd3 ? 6'd25:6'd24                               ;
        7'd50:
            cu_luma_left_mode_raddr_r = 6'd28                                                            ;
        7'd51:
            cu_luma_left_mode_raddr_r = cu_depth_2_4_r==2'd3 ? 6'd27:6'd24                               ;
        7'd52:
            cu_luma_left_mode_raddr_r = 6'd30                                                            ;
        7'd54:
            cu_luma_left_mode_raddr_r = 6'd32                                                            ;
        7'd56:
            cu_luma_left_mode_raddr_r = 6'd34                                                            ;
        7'd57:
            cu_luma_left_mode_raddr_r = cu_depth_4_0_r==2'd3 ? 6'd33:6'd32                               ;
        7'd58:
            cu_luma_left_mode_raddr_r = 6'd36                                                            ;
        7'd59:
            cu_luma_left_mode_raddr_r = cu_depth_4_0_r==2'd3 ? 6'd35:6'd32                               ;
        7'd60:
            cu_luma_left_mode_raddr_r = 6'd38                                                            ;
        7'd62:
            cu_luma_left_mode_raddr_r = 6'd40                                                            ;
        7'd64:
            cu_luma_left_mode_raddr_r = 6'd42                                                            ;
        7'd65:
            cu_luma_left_mode_raddr_r = cu_depth_6_0_r==2'd3 ? 6'd41:6'd40                               ;
        7'd66:
            cu_luma_left_mode_raddr_r = 6'd44                                                            ;
        7'd67:
            cu_luma_left_mode_raddr_r = cu_depth_6_0_r==2'd3 ? 6'd43:6'd40                               ;
        7'd68:
            cu_luma_left_mode_raddr_r = 6'd46                                                            ;
        7'd69:
            cu_luma_left_mode_raddr_r = cu_depth_4_2_r==2'd3 ? 6'd37:(cu_depth_4_2_r==2'd2 ? 6'd36:6'd32);
        7'd70:
            cu_luma_left_mode_raddr_r = 6'd48                                                            ;
        7'd71:
            cu_luma_left_mode_raddr_r = cu_depth_4_2_r==2'd3 ? 6'd39:(cu_depth_4_2_r==2'd2 ? 6'd36:6'd32);
        7'd72:
            cu_luma_left_mode_raddr_r = 6'd50                                                            ;
        7'd73:
            cu_luma_left_mode_raddr_r = cu_depth_4_4_r==2'd3 ? 6'd49:6'd48                               ;
        7'd74:
            cu_luma_left_mode_raddr_r = 6'd52                                                            ;
        7'd75:
            cu_luma_left_mode_raddr_r = cu_depth_4_4_r==2'd3 ? 6'd51:6'd48                               ;
        7'd76:
            cu_luma_left_mode_raddr_r = 6'd54                                                            ;
        7'd77:
            cu_luma_left_mode_raddr_r = cu_depth_6_2_r==2'd3 ? 6'd45:(cu_depth_6_2_r==2'd2 ? 6'd44:6'd32);
        7'd78:
            cu_luma_left_mode_raddr_r = 6'd56                                                            ;
        7'd79:
            cu_luma_left_mode_raddr_r = cu_depth_6_2_r==2'd3 ? 6'd47:(cu_depth_6_2_r==2'd2 ? 6'd44:6'd32);
        7'd80:
            cu_luma_left_mode_raddr_r = 6'd58                                                            ;
        7'd81:
            cu_luma_left_mode_raddr_r = cu_depth_6_4_r==2'd3 ? 6'd57:6'd56                               ;
        7'd82:
            cu_luma_left_mode_raddr_r = 6'd60                                                            ;
        7'd83:
            cu_luma_left_mode_raddr_r = cu_depth_6_4_r==2'd3 ? 6'd59:6'd56                               ;
        7'd84:
            cu_luma_left_mode_raddr_r = 6'd62                                                            ;
        default:
            cu_luma_left_mode_raddr_r = 6'd0                                                             ;
    endcase
end

//cu_luma_pred_mode_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_luma_pred_mode_r  <=   6'd0;
    else if(cu_start_d2_r)
        cu_luma_pred_mode_r  <=   mb_i_luma_mode_data_i;
end

//cu_luma_pred_top_mode_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_luma_pred_top_mode_r    <=    6'd1;
    else if(cu_start_d3_r)
    begin
        case(cu_idx_r)
            7'd0 , 7'd1 , 7'd2 , 7'd5 ,
            7'd6 , 7'd9 , 7'd10, 7'd21,
            7'd22, 7'd25, 7'd26, 7'd37,
            7'd38, 7'd41, 7'd42       :
                cu_luma_pred_top_mode_r <=   24'h041041  ;
            default                   :
                cu_luma_pred_top_mode_r <=   {4{mb_i_luma_mode_data_i}} ;
        endcase
    end
end

// cu_luma_pred_left_mode_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_luma_pred_left_mode_r  <=   6'd0;
    else if(cu_start_d1_r)
    begin
        case(cu_idx_r)
            7'd0  :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_0_r ,6'd1,cu_luma_mode_left_4_r };
            7'd1  :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_0_r ,6'd1,cu_luma_mode_left_2_r };
            7'd3  :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_4_r ,6'd1,cu_luma_mode_left_6_r};
            7'd5  :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_0_r ,6'd1,cu_luma_mode_left_1_r };
            7'd7  :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_2_r ,6'd1,cu_luma_mode_left_3_r };
            7'd13 :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_4_r ,6'd1,cu_luma_mode_left_5_r};
            7'd15 :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_6_r,6'd1,cu_luma_mode_left_7_r};
            7'd21 :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_0_r ,6'd1,cu_luma_mode_left_0_r };
            7'd23 :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_1_r ,6'd1,cu_luma_mode_left_1_r };
            7'd29 :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_2_r ,6'd1,cu_luma_mode_left_2_r };
            7'd31 :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_3_r ,6'd1,cu_luma_mode_left_3_r };
            7'd53 :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_4_r ,6'd1,cu_luma_mode_left_4_r };
            7'd55 :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_5_r,6'd1,cu_luma_mode_left_5_r};
            7'd61 :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_6_r,6'd1,cu_luma_mode_left_6_r};
            7'd63 :
                cu_luma_pred_left_mode_r  <= { 6'd1,cu_luma_mode_left_7_r,6'd1,cu_luma_mode_left_7_r};
            default:
                cu_luma_pred_left_mode_r  <=  {4{mb_i_luma_mode_data_i}}                                             ;
        endcase
    end
end

/****************delete at 2018/5/23,these code may be useful for further optimized********************/
/*cu_chroma_pred_mode_r
always @(posedge clk or negedge rst_n) begin 
    if(!rst_n)
        cu_chroma_pred_mode_r  <=   6'd0;
    else if(cu_start_d1_r) begin 
        if(cu_idx_r<7'd21)  
            cu_chroma_pred_mode_r  <=  mb_i_chroma_mode_data_i[23:18];
        else begin 
            case(cu_idx_minus21_w[1:0])
                2'd0:cu_chroma_pred_mode_r  <=   mb_i_chroma_mode_data_i[23:18]  ;
                2'd1:cu_chroma_pred_mode_r  <=   mb_i_chroma_mode_data_i[17:12]  ;
                2'd2:cu_chroma_pred_mode_r  <=   mb_i_chroma_mode_data_i[11:6 ]  ;
                2'd3:cu_chroma_pred_mode_r  <=   mb_i_chroma_mode_data_i[ 5:0 ]  ;
            endcase
        end 
    end 
end*/

/*-------------------------------------add at 2018/6/12,random qp--------------------------------------*/
wire [5:0] cu_qp_curr_w;
wire [5:0] cu_qp_last_w;
wire cu_qp_no_coded_w;
wire cu_qp_coded_flag_w;

reg cu_qp_no_coded_r;
reg [5:0] cu_qp_last_r;

// cu_qp_nocoded_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_qp_no_coded_r    <=  1'b1    ;
    else if(!cu_idx_r)
        cu_qp_no_coded_r    <=  1'b1    ;
    else
        cu_qp_no_coded_r    <=  cu_qp_coded_flag_w ;
end

// cu_qp_last_r
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cu_qp_last_r   <=   6'd0             ;
    else if(sys_mb_x_i==0 && sys_mb_y_i ==0)
        cu_qp_last_r   <=   rc_param_qp_i       ;
    //else if(lcu_curr_state_r[2]&&(mb_cbf_y_i||mb_cbf_u_i||mb_cbf_v_i))
    else if(lcu_curr_state_r == LCU_END)
        cu_qp_last_r   <=   rc_qp_i         ;
end


/*--------------------------transfer the ses from pre module for global parameters----------------------------------*/
// en_o
reg en;
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        en <= 1;
    else if((lcu_curr_state_r==LCU_INIT)&&(context_init_done_i==0)&&context_init_done_delay_r==0)
        en <= 0;
    else if((lcu_next_state_r==LCU_INIT)&&sys_start_i)
        en <= 0;
    else
        en <= 1;
end

assign en_o = en;

//gp_slice_type_o and gp_qp_o and gp_five_minus_max_num_merge_cand_o
assign gp_slice_type_o      =       sys_slice_type_i + 1'b1 ;
assign gp_qp_o              =       rc_param_qp_i           ;
assign gp_five_minus_max_num_merge_cand_o = 3'b000          ;//merge mode's candidate num is usualy to be 5
assign gp_cabac_init_flag_o = 1'b0                          ;


/*---------------------------------------transfer the sao ses-----------------------------------------------------*/
wire [20:0] sao_merge_left_flag_w;
wire [20:0] sao_merge_up_flag_w  ;
wire [20:0] sao_type_idx_w       ;//0:not applied,1:band offset,2:edge offset
wire [20:0] sao_offset_abs_0_w   ;
wire [20:0] sao_offset_abs_1_w   ;
wire [20:0] sao_offset_abs_2_w   ;
wire [20:0] sao_offset_abs_3_w   ;
wire [20:0] sao_offset_sign_0_w  ;
wire [20:0] sao_offset_sign_1_w  ;
wire [20:0] sao_offset_sign_2_w  ;
wire [20:0] sao_offset_sign_3_w  ;
wire [20:0] sao_band_pos_or_eo_class_w;//32 band or 4 of eo class

wire allow_merge_left_w;
wire allow_merge_top_w ;

wire [19:0] sao_luma_w   ;
wire [19:0] sao_chromau_w;
wire [19:0] sao_chromav_w;

reg  sao_merge_left_flag_r;
reg  sao_merge_up_flag_r  ;

wire sao_merge_w;

reg [19:0] sao_data_r   ;
reg [ 1:0] sao_compidx_r;

assign   allow_merge_left_w  = !(sys_mb_x_i==0);
assign   allow_merge_top_w   = !(sys_mb_y_i==0);

always @*
begin
    if(allow_merge_left_w)
        sao_merge_left_flag_r = sao_i[60];
    else
        sao_merge_left_flag_r = 1'b0     ;
end

always @*
begin
    if(sao_merge_left_flag_r==1'b0&&allow_merge_top_w)
        sao_merge_up_flag_r =  sao_i[61];
    else
        sao_merge_up_flag_r =  1'b0     ;
end

assign   sao_merge_left_flag_w  =   {7'h00,sao_merge_left_flag_r,4'h1,9'h0b5};
assign   sao_merge_up_flag_w    =   {7'h00,sao_merge_up_flag_r,4'h1,9'h0b5};

assign   sao_luma_w    = sao_i[19:0 ];
assign   sao_chromau_w = sao_i[39:20];
assign   sao_chromav_w = sao_i[59:40];

assign   sao_merge_w = sao_merge_left_flag_r||sao_merge_up_flag_r;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        sao_data_r     <= 20'd0;
        sao_compidx_r  <=  2'd0;
    end
    else
    begin
        case(lcu_cyc_cnt_r)
            4'd0,4'd1,4'd2,4'd3:
            begin
                sao_data_r <=  sao_luma_w    ;
                sao_compidx_r <=  2'd0;
            end
            4'd4,4'd5,4'd6,4'd7:
            begin
                sao_data_r <=  sao_chromau_w ;
                sao_compidx_r <=  2'd1;
            end
            4'd8,4'd9,4'd10,4'd11:
            begin
                sao_data_r <=  sao_chromav_w ;
                sao_compidx_r <=  2'd2;
            end
            default  :
            begin
                sao_data_r <=  20'd0         ;
                sao_compidx_r <=  2'd0;
            end
        endcase
    end
end

cabac_se_prepare_sao_offset  cabac_se_prepare_sao_offset_u0(
                                 .sao_data_i          (sao_data_r         ),
                                 .sao_compidx_i       (sao_compidx_r      ),
                                 .sao_merge_i         (sao_merge_w        ),
                                 .sao_type_idx_o      (sao_type_idx_w     ),
                                 .sao_offset_abs_0_o  (sao_offset_abs_0_w ),
                                 .sao_offset_abs_1_o  (sao_offset_abs_1_w ),
                                 .sao_offset_abs_2_o  (sao_offset_abs_2_w ),
                                 .sao_offset_abs_3_o  (sao_offset_abs_3_w ),
                                 .sao_offset_sign_0_o (sao_offset_sign_0_w),
                                 .sao_offset_sign_1_o (sao_offset_sign_1_w),
                                 .sao_offset_sign_2_o (sao_offset_sign_2_w),
                                 .sao_offset_sign_3_o (sao_offset_sign_3_w),
                                 .sao_band_pos_or_eo_class_o(sao_band_pos_or_eo_class_w)
                             );



/*--------------------------------------- transfer the coding_quadtree-----------------------------------------------------*/
reg no_left_flag_r             ;
reg no_top_flag_r              ;
reg  [8:0]  ctxIdx_split_cu_flag_r;
wire [20:0] split_cu_flag_w       ;

//no_left_flag_r
always @*
begin
    if(sys_mb_x_i=='d0)
    begin
        case(cu_idx_r)
            7'd0, 7'd1 , 7'd3 , 7'd5  ,
            7'd7, 7'd13, 7'd15, 7'd21 ,
            7'd23, 7'd29, 7'd31, 7'd53,
            7'd55, 7'd61, 7'd63       :
                no_left_flag_r = 1'b1;
            default:
                no_left_flag_r = 1'b0;
        endcase
    end
    else
        no_left_flag_r    =   1'b0  ;
end

//no_top_flag_r
always @*
begin
    if(sys_mb_y_i=='d0)
    begin
        case(cu_idx_r)
            7'd0 , 7'd1 , 7'd2 , 7'd5 ,
            7'd6 , 7'd9 , 7'd10, 7'd21,
            7'd22, 7'd25, 7'd26, 7'd37,
            7'd38, 7'd41, 7'd42:
                no_top_flag_r  = 1'b1;
            default:
                no_top_flag_r  = 1'b0;
        endcase
    end
    else
        no_top_flag_r   =   1'b0 ;
end

// ctxIdx_split_cu_flag_r
always @*
begin
    if(no_left_flag_r && no_top_flag_r)
        ctxIdx_split_cu_flag_r = 9'd0;
    else if(!no_left_flag_r && no_top_flag_r)
        ctxIdx_split_cu_flag_r = cu_depth_left_r > cu_depth_r;
    else if(no_left_flag_r && ~no_top_flag_r)
        ctxIdx_split_cu_flag_r = cu_depth_top_r  > cu_depth_r;
    else
        ctxIdx_split_cu_flag_r = (cu_depth_left_r > cu_depth_r) + (cu_depth_top_r > cu_depth_r);
end

assign  split_cu_flag_w        = {7'h00,split_cu_flag_r,4'h1,ctxIdx_split_cu_flag_r};


/*--------------------------------------- transfer the ses in cu-----------------------------------------------------*/
// for an cu
wire cu_start_w;
wire [6:0]  cu_idx_w ;
wire [1:0]  cu_depth_w ; // 0:64x64  1:32x32  2:16x16 3:8x8
wire split_transform_flag_w;
wire cu_slice_type_w;

wire        cu_skip_flag_w      ;
wire [ 1:0] cu_inter_part_mode_w; // 2 bit for a cu , 8x8 cu only support 2Nx2N
wire        cu_merge_flag_w     ; // 1 bit for a cu
wire [3:0]  cu_merge_idx_w      ; // 4 bit for a cu
wire [5:0] cu_luma_pred_mode_w ; // 6 bits for a 8x8 cu

wire [ 3:0] cu_cbf_y_w ;
wire [ 3:0] cu_cbf_u_w ;
wire [ 3:0] cu_cbf_v_w ;

wire [1:0]  cu_depth_left_w         ;
wire [1:0]  cu_depth_top_w          ;

wire        cu_skip_top_flag_w      ;
wire        cu_skip_left_flag_w     ;

wire [23:0] cu_luma_pred_top_mode_w ;
wire [23:0] cu_luma_pred_left_mode_w;

reg  [(4*`MVD_WIDTH+5):0] mb_mvd_rdata_r;
wire [1:0] coeff_type_w;
wire [`COEFF_WIDTH*16-1:0] tq_rdata_w;
wire tq_ren_w ;
wire [ 8:0] tq_raddr_w;


wire [22:0] cu_syntax_element_0_w;
wire [22:0] cu_syntax_element_1_w;
wire [14:0] cu_syntax_element_2_w;
wire [14:0] cu_syntax_element_3_w;


assign   cu_start_w               =    cu_start_d3_r           ;
assign   cu_idx_w                 =    cu_idx_r                ;
assign   cu_depth_w               =    cu_depth_r              ;
assign   split_transform_flag_w   =    split_transform_flag_r  ;
assign   cu_slice_type_w          =    sys_slice_type_i        ;
assign   cu_inter_part_mode_w     =    cu_inter_part_size_r    ;
assign   cu_merge_flag_w          =    cu_merge_flag_r         ;
assign   cu_merge_idx_w           =    cu_merge_idx_r          ;
assign   cu_luma_pred_mode_w      =    cu_luma_pred_mode_r     ;
assign   cu_cbf_y_w               =    cu_cbf_y_r              ;
assign   cu_cbf_u_w               =    cu_cbf_u_r              ;
assign   cu_cbf_v_w               =    cu_cbf_v_r              ;
assign   cu_depth_left_w          =    cu_depth_left_r         ;
assign   cu_depth_top_w           =    cu_depth_top_r          ;
assign   cu_skip_flag_w           =    cu_skip_flag_r          ;
assign   cu_skip_top_flag_w       =    cu_skip_top_flag_r      ;
assign   cu_skip_left_flag_w      =    cu_skip_left_flag_r     ;
assign   cu_luma_pred_top_mode_w  =    cu_luma_pred_top_mode_r ;
assign   cu_luma_pred_left_mode_w =    cu_luma_pred_left_mode_r;
assign   cu_qp_curr_w             =    rc_qp_i                 ;
assign   cu_qp_last_w             =    cu_qp_last_r            ;
assign   cu_qp_no_coded_w         =    cu_qp_no_coded_r        ;



assign   tq_rdata_w               =    mb_cef_data_i           ;

always @*
begin
    case(cu_inter_part_size_r)
        `PART_2NX2N :
            mb_mvd_rdata_r = {cu_mvd_data_r[44:23],cu_mvd_data_r[21:0],2'b0,cu_mvd_data_r[45],2'b0,cu_mvd_data_r[22]};
        `PART_2NXN  :
            mb_mvd_rdata_r = {cu_mvd_data_r[44:23],cu_mvd_data_r[21:0],2'b0,cu_mvd_data_r[45],2'b0,cu_mvd_data_r[22]};
        `PART_NX2N  :
            mb_mvd_rdata_r = {cu_mvd_data_r[44:23],cu_mvd_data_r[21:0],2'b0,cu_mvd_data_r[45],2'b0,cu_mvd_data_r[22]};
        `PART_SPLIT :
            mb_mvd_rdata_r = 50'd0;
    endcase
end



cabac_se_prepare_cu  cabac_se_prepare_cu_u0(
                         // input
                         .clk                       ( clk                         ),
                         .rst_n                     ( rst_n                       ),
                         .cu_start_i                ( cu_start_w                  ),
                         .cu_idx_i                  ( cu_idx_w                    ),
                         .cu_depth_i                ( cu_depth_w                  ),
                         .cu_split_transform_i      ( split_transform_flag_w      ),
                         .cu_slice_type_i           ( cu_slice_type_w             ),
                         .cu_skip_flag_i            ( cu_skip_flag_w              ),
                         .cu_part_size_i            ( cu_inter_part_mode_w        ),
                         .cu_merge_flag_i           ( cu_merge_flag_w             ),
                         .cu_merge_idx_i            ( cu_merge_idx_w              ),
                         .cu_luma_pred_mode_i       ( cu_luma_pred_mode_w         ),
                         .cu_cbf_y_i                ( cu_cbf_y_w                  ),
                         .cu_cbf_u_i                ( cu_cbf_u_w                  ),
                         .cu_cbf_v_i                ( cu_cbf_v_w                  ),
                         .cu_skip_top_flag_i        ( cu_skip_top_flag_w          ),
                         .cu_skip_left_flag_i       ( cu_skip_left_flag_w         ),
                         .cu_luma_pred_top_mode_i   ( cu_luma_pred_top_mode_w     ),
                         .cu_luma_pred_left_mode_i  ( cu_luma_pred_left_mode_w    ),
                         .tq_rdata_i                   ( tq_rdata_w                  ),
                         .cu_mv_data_i             ( mb_mvd_rdata_r              ),
                         .cu_qp_i                  ( cu_qp_curr_w                ),
                         .cu_qp_last_i              ( cu_qp_last_w                ),
                         .cu_qp_no_coded_i          ( cu_qp_no_coded_w            ),
                         //  output
                         .cu_done_o                 ( cu_done_w                   ),
                         .coeff_type_o              ( coeff_type_w                ),
                         .tq_ren_o                 ( tq_ren_w                    ),
                         .tq_raddr_o                   ( tq_raddr_w                  ),
                         .cu_qp_coded_flag_o        ( cu_qp_coded_flag_w          ),
                         .cu_syntax_element_0_o    ( cu_syntax_element_0_w       ),
                         .cu_syntax_element_1_o    ( cu_syntax_element_1_w       ),
                         .cu_syntax_element_2_o    ( cu_syntax_element_2_w       ),
                         .cu_syntax_element_3_o    ( cu_syntax_element_3_w       )
                     );


/*------------------------------- transfer the terminal flag after a frame was done ---------------------------------*/

reg [ 20:0 ] final_bit_r;

always @*
begin
    if( (sys_mb_x_i==sys_total_x_i) && (sys_mb_y_i==sys_total_y_i) &&(lcu_cyc_cnt_r==4'd0)&&(lcu_curr_state_r == LCU_END))
        final_bit_r   =  {8'h01,4'h1,9'h0ba};
    else if((lcu_curr_state_r == LCU_END)&&(lcu_cyc_cnt_r==4'd0))
        final_bit_r   =  {8'h00,4'h1,9'h0ba};
    else
        final_bit_r   =  21'b0;
end


/*----------------------------------------------- output signals  -----------------------------------------------------*/
assign  mb_mvd_ren_o  =  cu_mvd_ren_r   ;
assign  mb_mvd_addr_o =  cu_mvd_raddr_r ;
assign  mb_cef_ren_o  =  tq_ren_w       ;
assign  mb_cef_addr_o =  tq_raddr_w     ;
assign  coeff_type_o  =  coeff_type_w   ;
assign  lcu_done_o    =  lcu_done_r     ;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        syntax_element_0_r  <= 23'b0;
        syntax_element_1_r  <= 23'b0;
        syntax_element_2_r  <= 15'b0;
        syntax_element_3_r  <= 15'b0;
    end
    else
    begin
        case(lcu_curr_state_r)
            LCU_IDLE  :
            begin
                syntax_element_0_r <=  23'b0;
                syntax_element_1_r <=  23'b0;
                syntax_element_2_r <=  15'b0;
                syntax_element_3_r <=  15'b0;
            end
            LCU_SAO  :
            begin
                case(lcu_cyc_cnt_r)
                    4'd0    :
                    begin
                        syntax_element_0_r <=  {2'b00,sao_merge_left_flag_w}  ;
                        syntax_element_1_r <=  {2'b00,sao_merge_up_flag_w  }  ;
                        syntax_element_2_r <=  15'b0                  ;
                        syntax_element_3_r <=  15'b0                  ;
                    end
                    4'd1,4'd5,4'd9  :
                    begin
                        syntax_element_0_r <=  {2'b00,sao_type_idx_w     }    ;
                        syntax_element_1_r <=  {2'b00,sao_offset_abs_0_w }    ;
                        syntax_element_2_r <=  15'b0                  ;
                        syntax_element_3_r <=  15'b0                  ;
                    end
                    4'd2,4'd6,4'd10 :
                    begin
                        syntax_element_0_r <=  {2'b00,sao_offset_abs_1_w}     ;
                        syntax_element_1_r <=  {2'b00,sao_offset_abs_2_w}     ;
                        syntax_element_2_r <=  15'b0                  ;
                        syntax_element_3_r <=  15'b0                  ;
                    end
                    4'd3,4'd7,4'd11 :
                    begin
                        syntax_element_0_r <=  {2'b00,sao_offset_abs_3_w  }   ;
                        syntax_element_1_r <=  {2'b00,sao_offset_sign_0_w }   ;
                        syntax_element_2_r <=  sao_offset_sign_1_w[14:0]    ;
                        syntax_element_3_r <=  sao_offset_sign_2_w[14:0]    ;
                    end
                    4'd4,4'd8,4'd12 :
                    begin
                        syntax_element_0_r <=  {2'b00,sao_offset_sign_3_w}    ;
                        syntax_element_1_r <=  {2'b00,sao_band_pos_or_eo_class_w};
                        syntax_element_2_r <=  15'b0                  ;
                        syntax_element_3_r <=  15'b0                  ;
                    end
                    default :
                    begin
                        syntax_element_0_r <=  23'b0                  ;
                        syntax_element_1_r <=  23'b0                  ;
                        syntax_element_2_r <=  15'b0                  ;
                        syntax_element_3_r <=  15'b0                  ;
                    end
                endcase
            end
            CU_SPLIT  :
            begin
                syntax_element_0_r <=  boundary_flag_w?23'b0:{2'b00,split_cu_flag_w};
                syntax_element_1_r <=  23'b0          ;
                syntax_element_2_r <=  15'b0          ;
                syntax_element_3_r <=  15'b0          ;
            end
            LCU_END   :
            begin
                syntax_element_0_r <=  {2'b00,final_bit_r};
                syntax_element_1_r <=  23'b0          ;
                syntax_element_2_r <=  15'b0          ;
                syntax_element_3_r <=  15'b0          ;
            end
            default   :
            begin
                syntax_element_0_r <=  cu_syntax_element_0_w;
                syntax_element_1_r <=  cu_syntax_element_1_w;
                syntax_element_2_r <=  cu_syntax_element_2_w;
                syntax_element_3_r <=  cu_syntax_element_3_w;
            end
        endcase
    end
end
assign syntax_element_0_o = syntax_element_0_r;
assign syntax_element_1_o = syntax_element_1_r;
assign syntax_element_2_o = syntax_element_2_r;
assign syntax_element_3_o = syntax_element_3_r;
assign syntax_element_valid_o = (syntax_element_0_o!=0)||(syntax_element_1_o!=0)||(syntax_element_2_o!=0)||(syntax_element_3_o!=0);

endmodule



