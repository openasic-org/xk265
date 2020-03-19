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
// Filename       : mvd_top.v
// Author         : chewein
// Created        : 2015-08-15
// Description    : 
//               
// $Id$ 
//-----------------------------------------------------------------------------------------------------------------------------      
`include "enc_defines.v"   

module  mvd_top(
                //input
                clk                              ,
                rst_n                            ,
                ctu_x_res_i                      ,
                ctu_y_res_i                      ,
                mb_x_total_i                     , 
                mb_y_total_i                     ,
                mb_x_i                           ,
                mb_y_i                           ,
                mvd_start_i                      ,
                inter_cu_part_size_i             ,

                mv_rden_o                        ,
                mv_rdaddr_o                      ,
                mv_data_i                        ,
                mvd_done_o                       ,

                mvd_wen_o                        ,
                mvd_addr_o                       ,
                mvd_and_mvp_idx_o                
);

// -----------------------------------------------------------------------------------------------------------------------------
//
//        INPUT and OUTPUT DECLARATION
//
// -----------------------------------------------------------------------------------------------------------------------------
//ctrl info
input     [ 1-1:0]            clk                    ; // clock signal
input     [ 1-1:0]            rst_n                  ; // reset signal, low active
input  [4                  -1 :0]    ctu_x_res_i           ;
input  [4                  -1 :0]    ctu_y_res_i           ;

input    [(`PIC_X_WIDTH)-1:0] mb_x_total_i           ; // mb_x_total_i
input    [(`PIC_Y_WIDTH)-1:0] mb_y_total_i           ; // mb_y_total_i
input    [(`PIC_X_WIDTH)-1:0] mb_x_i                 ; // mb_x_i
input    [(`PIC_Y_WIDTH)-1:0] mb_y_i                 ; // mb_y_i 
input                         mvd_start_i            ;
input    [            42-1:0] inter_cu_part_size_i   ; // CU partition info ( 16 + 4 + 1) * 2 

output   [             1-1:0] mv_rden_o              ; // fmv read enable 
output   [             6-1:0] mv_rdaddr_o            ; // fmv sram read address 
input    [  2*`FMV_WIDTH-1:0] mv_data_i              ; // fmv from fme 

output   [             1-1:0] mvd_done_o             ;

output                        mvd_wen_o              ;
output   [             6-1:0] mvd_addr_o             ;
output   [  2*`MVD_WIDTH  :0] mvd_and_mvp_idx_o      ; // 1bit mvp_idx, 2*`MVD_WIDTH bit mvd 

reg      [             1-1:0] mv_rden_o              ; // fmv read enable 
reg      [             6-1:0] mv_rdaddr_o            ; // fmv sram read address 

reg                           mvd_wen_o              ;

// -----------------------------------------------------------------------------------------------------------------------------
//
//        parameter declaration 
//
// -----------------------------------------------------------------------------------------------------------------------------
parameter                   CU_64x64       =    3'd4 ,
                            CU_32x32       =    3'd5 ,
                            CU_16x16       =    3'd6 ,
                            CU_8x8         =    3'd7 ,
                            LCU_IDLE       =    3'd0 ,
                            LCU_SPLIT      =    3'd1 ,
                            LCU_UPDATE     =    3'd2 ;

// -----------------------------------------------------------------------------------------------------------------------------
//
//        reg and wire signals  declaration 
//
// -----------------------------------------------------------------------------------------------------------------------------

reg        [           3-1:0] lcu_curr_state_r       ;
reg        [           3-1:0] lcu_next_state_r       ;
reg        [           4-1:0] cu_cnt_r               ;
reg        [           4-1:0] cu_cnt_d1_r            ;
reg                           cu_done_r              ;
reg                           cu_start_r             ;

reg        [           7-1:0] cu_idx_r               ; // current cu index 0...84 
reg        [           7-1:0] cu_width_r             ; // width  of cu: 64 32 16 8
reg        [           7-1:0] pu_width_r             ; // width  of pu: 64 32 16 8
reg        [           7-1:0] pu_height_r            ; // height of cu: 64 32 16 8

reg        [           6-1:0] blk8x8_cnt_r           ; // 8x8 block index 0...63 

reg        [           6-1:0] cu_pos_x_r             ; // current cu position 
reg        [           6-1:0] cu_pos_y_r             ; // current cu position

reg        [2*`FMV_WIDTH-1:0] mv_c_r                 ; // mv of current pu
reg        [2*`FMV_WIDTH-1:0] mv_p_r                 ; // mv of a or b in different cycle 
reg        [2*`FMV_WIDTH-1:0] mv_a_r                 ; // mv of a or b in different cycle 
reg        [2*`FMV_WIDTH-1:0] mv_b_r                 ; // mv of a or b in different cycle 
reg        [2*`FMV_WIDTH-1:0] mv_a_d1_r              ; // used to compare mv_a == mv_b 

wire       [2*`MVD_WIDTH-1:0] mvd_w                  ;
reg        [2*`MVD_WIDTH-1:0] mvd_r                  ;

reg        [2*`MVD_WIDTH-1:0] mvd_final_r            ;
reg        [           1-1:0] mvp_final_idx          ;
reg        [           1-1:0] mvp_idx                ;

wire       [           7-1:0] mv_bits_cnt_w          ;
reg        [           7-1:0] mv_bits_cnt_r          ;

wire       [           8-1:0] pu_addr_w              ;
wire       [           8-1:0] pu_a_addr_w            ;
wire       [           9-1:0] pu_b_addr_w            ;

reg        [           2-1:0] cu_partition_r         ;
wire                          cu_split_flag_w        ;
reg        [           2-1:0] cu_depth_r             ;

wire       [           7-1:0] cu_idx_minus1_w        ; //  cu index minus 1
wire       [           7-1:0] cu_idx_minus5_w        ; //  cu index minus 5
wire       [           7-1:0] cu_idx_minus21_w       ; //  cu index minus 21
wire       [           7-1:0] cu_idx_plus1_w         ; //  cu index plus 1
wire       [           7-1:0] cu_idx_deep_plus1_w    ; //  cu index of deep depth plus 1
wire       [           7-1:0] cu_idx_shift1_w        ; //  cu_idx_r << 1;
wire       [           7-1:0] cu_idx_shift1_plus1_w  ; //  (cu_idx_r<<1)+1

// -----------------------------------------------------------------------------------------------------------------------------
//
//        internal memory
//
// -----------------------------------------------------------------------------------------------------------------------------

reg        [             1-1:0] top_mv_oen_r         ; // data output enable, low active
reg        [             1-1:0] top_mv_wen_r         ; // write enable, low active
reg        [             5-1:0] top_mv_addr_r        ; // address input,0..7-8
wire       [  `PIC_X_WIDTH+3-1:0] top_mv_addr_w        ; // address input
wire       [  2*`FMV_WIDTH-1:0] top_mv_data_ow       ; // data output

reg        [8*2*`FMV_WIDTH-1:0] left_mv_memo_r       ; // data memory 
reg        [             4-1:0] left_mv_addr_r       ; // data output enable, low active
reg        [  2*`FMV_WIDTH-1:0] left_mv_data_r       ; // data memory 


// -----------------------------------------------------------------------------------------------------------------------------
//
//        Logic circuit
//
// -----------------------------------------------------------------------------------------------------------------------------

assign  cu_idx_minus1_w  = cu_idx_r - 7'd1              ;
assign  cu_idx_minus5_w  = cu_idx_r - 7'd5              ;
assign  cu_idx_minus21_w = cu_idx_r - 7'd21             ;

assign  cu_idx_plus1_w      = cu_idx_r + 7'd1           ;
assign  cu_idx_deep_plus1_w = (cu_idx_r<<2) + 7'd1      ;

assign  cu_idx_shift1_w       = cu_idx_r << 1           ;
assign  cu_idx_shift1_plus1_w = cu_idx_shift1_w + 7'd1  ;

assign  cu_split_flag_w       = (cu_partition_r == 2'd3);


// cu_cnt_r
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)
        cu_cnt_r <= 4'd0;
    else if(cu_start_r||cu_done_r||lcu_curr_state_r==LCU_IDLE||lcu_curr_state_r==LCU_SPLIT)
        cu_cnt_r <= 4'd0;
    else 
        cu_cnt_r <= cu_cnt_r + 2'd1;
end 

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)
        cu_cnt_d1_r <= 4'd0;
    else 
        cu_cnt_d1_r <= cu_cnt_r;
end 

//  cu_done_r
always @* begin
	cu_done_r = 1'd0;
    case(lcu_curr_state_r)
        LCU_IDLE    :    cu_done_r = 1'd0;
        LCU_SPLIT   :    cu_done_r = 1'd1;
        CU_64x64    ,
        CU_32x32    ,   
        CU_16x16    ,   
        CU_8x8      :    cu_done_r=(cu_partition_r?(cu_cnt_r==4'd7):(cu_cnt_r==4'd3));
        LCU_UPDATE  :    cu_done_r = (cu_cnt_r==4'd15);
        default : ;
    endcase
end

// cu_idx_r 
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        cu_idx_r <= 0;
    else if(cu_done_r) begin   
        if(lcu_curr_state_r==LCU_SPLIT) begin
            if(cu_split_flag_w)
                cu_idx_r <= cu_idx_deep_plus1_w;
            else 
                cu_idx_r <= cu_idx_r;
        end
        else begin
            case(cu_depth_r)
                2'b00:    begin
                            cu_idx_r <= 'd0;
                end
                
                2'b01:    begin
                            if(cu_idx_minus1_w[1:0]==2'd3)
                                cu_idx_r <= 'd0;
                            else 
                                cu_idx_r <= cu_idx_plus1_w;
                   end
                
                2'b10:    begin
                            if(cu_idx_minus5_w[3:0]=='d15)
                                cu_idx_r <= 'd0;
                            else if(cu_idx_minus5_w[1:0]==2'd3) begin
                                cu_idx_r <= (cu_idx_r >> 2);
                            end
                            else begin
                                cu_idx_r <= cu_idx_plus1_w;
                            end
                end
                
                2'b11:    begin
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
    else begin 
        cu_idx_r <= cu_idx_r;
    end
end

// cu_partition_r 
always @* begin 
       case(cu_idx_r)    
        7'd0  :  cu_partition_r   =  inter_cu_part_size_i[  1:0  ];
        7'd1  :  cu_partition_r   =  inter_cu_part_size_i[  3:2  ];
        7'd2  :  cu_partition_r   =  inter_cu_part_size_i[  5:4  ];
        7'd3  :  cu_partition_r   =  inter_cu_part_size_i[  7:6  ];
        7'd4  :  cu_partition_r   =  inter_cu_part_size_i[  9:8  ];
        7'd5  :  cu_partition_r   =  inter_cu_part_size_i[ 11:10 ];
        7'd6  :  cu_partition_r   =  inter_cu_part_size_i[ 13:12 ];
        7'd7  :  cu_partition_r   =  inter_cu_part_size_i[ 15:14 ];
        7'd8  :  cu_partition_r   =  inter_cu_part_size_i[ 17:16 ];
        7'd9  :  cu_partition_r   =  inter_cu_part_size_i[ 19:18 ];
        7'd10 :  cu_partition_r   =  inter_cu_part_size_i[ 21:20 ];
        7'd11 :  cu_partition_r   =  inter_cu_part_size_i[ 23:22 ];
        7'd12 :  cu_partition_r   =  inter_cu_part_size_i[ 25:24 ];
        7'd13 :  cu_partition_r   =  inter_cu_part_size_i[ 27:26 ];
        7'd14 :  cu_partition_r   =  inter_cu_part_size_i[ 29:28 ];
        7'd15 :  cu_partition_r   =  inter_cu_part_size_i[ 31:30 ];
        7'd16 :  cu_partition_r   =  inter_cu_part_size_i[ 33:32 ];
        7'd17 :  cu_partition_r   =  inter_cu_part_size_i[ 35:34 ];
        7'd18 :  cu_partition_r   =  inter_cu_part_size_i[ 37:36 ];
        7'd19 :  cu_partition_r   =  inter_cu_part_size_i[ 39:38 ];
        7'd20 :  cu_partition_r   =  inter_cu_part_size_i[ 41:40 ];
      default :  cu_partition_r   =  2'b0                         ;
    endcase 
end 

// cu_depth_r
always @* begin
    if(cu_idx_r=='d0)                      //cu_idx_r = 0
        cu_depth_r = 2'd0;
    else if(cu_idx_minus1_w[6:2]=='d0)     //cu_idx_r = 4 3 2 1
        cu_depth_r = 2'd1;
    else if(cu_idx_minus5_w[6:4]=='d0)     //cu_idx_r = 20 ...5
        cu_depth_r = 2'd2;
    else 
        cu_depth_r = 2'd3;
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        lcu_curr_state_r <= LCU_IDLE        ;
    else
        lcu_curr_state_r <= lcu_next_state_r;
end

// LCU next state
always @* begin
	lcu_next_state_r = LCU_IDLE;
    case(lcu_curr_state_r)
        LCU_IDLE:    begin
                if(mvd_start_i) 
                       lcu_next_state_r = LCU_SPLIT; 
                else 
                    lcu_next_state_r = LCU_IDLE;
        end

        LCU_SPLIT:   begin
                        case(cu_depth_r)
                            2'b00:    begin                                   //64x64
                                        if(cu_split_flag_w)
                                            lcu_next_state_r = LCU_SPLIT;
                                        else     
                                            lcu_next_state_r = CU_64x64;
                            end
                            
                            2'b01:    begin                                   //32x32
                                        if(cu_split_flag_w)
                                            lcu_next_state_r = LCU_SPLIT;    
                                        else 
                                            lcu_next_state_r = CU_32x32;
                            end
                            
                            2'b10:    begin                                   //16x16
                                        if(cu_split_flag_w)
                                            lcu_next_state_r = CU_8x8  ;
                                        else 
                                            lcu_next_state_r = CU_16x16;    
                            end
                            
                            2'b11:    begin                                    //8x8
                                        lcu_next_state_r = CU_8x8;
                            end
                        endcase
        end

        CU_64x64:   begin
                        if(cu_done_r)
                            lcu_next_state_r = LCU_UPDATE;           
                        else 
                            lcu_next_state_r = CU_64x64;
        end
            
        CU_32x32:   begin
                        if(cu_done_r) begin
                            if(cu_idx_r==7'd4)
                                lcu_next_state_r = LCU_UPDATE;
                            else 
                                lcu_next_state_r = LCU_SPLIT;                       
                        end
                        else 
                            lcu_next_state_r = CU_32x32 ;
        end

        CU_16x16:   begin
                        if(cu_done_r) begin
                            if(cu_idx_r==7'd20)
                                lcu_next_state_r = LCU_UPDATE;
                            else
                                lcu_next_state_r = LCU_SPLIT;
                        end
                        else
                            lcu_next_state_r = CU_16x16  ; 
        end             

        CU_8x8:        begin
                        if(cu_done_r) begin
                            if(cu_idx_r==7'd84)
                                lcu_next_state_r = LCU_UPDATE;
                            else if(cu_idx_minus21_w[1:0]==2'd3)
                                lcu_next_state_r = LCU_SPLIT;
                            else 
                                lcu_next_state_r = CU_8x8;
                        end
                        else 
                            lcu_next_state_r = CU_8x8;
        end             
        
        LCU_UPDATE:    begin
                        if(cu_done_r)
                            lcu_next_state_r = LCU_IDLE;
                        else 
                            lcu_next_state_r = LCU_UPDATE;
        end
        default : ;
    endcase
end

// cu_start_r 
always @(posedge clk or negedge rst_n) begin 
    if(!rst_n)
        cu_start_r     <=  1'b0   ;
    else if(lcu_curr_state_r==LCU_SPLIT &&lcu_next_state_r[2])  // split --> lcu 
        cu_start_r     <=  1'b1   ;
    else if(lcu_curr_state_r[2]&&cu_done_r&&lcu_next_state_r[2]) // cu-->cu 
        cu_start_r     <=  1'b1   ;
    else 
        cu_start_r     <=  1'b0   ;
end 

// cu_width_r
always @* begin
    if(cu_idx_r=='d0)                      //   cu_idx_r = 0
        cu_width_r = 7'd64;
    else if(cu_idx_minus1_w[6:2]=='d0)     //   cu_idx_r = 4 3 2 1
        cu_width_r = 7'd32;
    else if(cu_idx_minus5_w[6:4]=='d0)     //   cu_idx_r = 20 ...5
        cu_width_r = 7'd16;
    else 
        cu_width_r = 7'd8;
end

// pu_width_r   pu_height_r
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        pu_width_r  <=7'd0;
        pu_height_r <=7'd0;
    end 
    else begin 
        case(cu_partition_r)
            `PART_2NX2N: begin pu_width_r <= cu_width_r   ; pu_height_r <= cu_width_r   ; end 
            `PART_2NXN : begin pu_width_r <= cu_width_r   ; pu_height_r <= cu_width_r>>1; end 
            `PART_NX2N : begin pu_width_r <= cu_width_r>>1; pu_height_r <= cu_width_r   ; end  
            `PART_SPLIT: begin pu_width_r <= cu_width_r>>1; pu_height_r <= cu_width_r>>1; end  
        endcase
    end
end 

// blk8x8_cnt_r
always @* begin 
    case(lcu_curr_state_r)
        CU_64x64  :  blk8x8_cnt_r = 6'd0;
        CU_32x32  :  blk8x8_cnt_r = {cu_idx_minus1_w,4'd0};
        CU_16x16  :  blk8x8_cnt_r = {cu_idx_minus5_w,2'd0};
        CU_8x8    :  blk8x8_cnt_r = cu_idx_minus21_w;
        default   :  blk8x8_cnt_r = 6'd0;
    endcase 
end 

// cu_pos_x_r   cu_pos_y_r
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cu_pos_x_r <=  6'd0;
        cu_pos_y_r <=  6'd0;
    end
    else if(lcu_curr_state_r[2]&&(cu_cnt_r[2:0]==3'd3))begin
        cu_pos_x_r <=  (cu_partition_r == `PART_NX2N) ? cu_pos_x_r + pu_width_r : cu_pos_x_r ;
        cu_pos_y_r <=  (cu_partition_r == `PART_2NXN) ? cu_pos_y_r + pu_height_r: cu_pos_y_r ;
    end 
    else if(lcu_curr_state_r[2]&&(cu_cnt_r[2:0]==3'd0))begin
        cu_pos_x_r <= {blk8x8_cnt_r[4],blk8x8_cnt_r[2],blk8x8_cnt_r[0],3'd0};
        cu_pos_y_r <= {blk8x8_cnt_r[5],blk8x8_cnt_r[3],blk8x8_cnt_r[1],3'd0};
    end 
end 

// pu 0 
assign  pu_addr_w   =  {2'b10,cu_pos_y_r[5:3],cu_pos_x_r[5:3]};// 2'b10: current LCU

mvd_can_mv_addr  mvd_can_mv_addr_pu0(
                .mb_x_total_i   ( mb_x_total_i  ),
                .mb_y_total_i   ( mb_y_total_i  ),
                .ctu_x_res_i    ( ctu_x_res_i   ),
                .ctu_y_res_i    ( ctu_y_res_i   ),
                .mb_x_i         ( mb_x_i        ),
                .mb_y_i         ( mb_y_i        ),
                .pos_x_i        ( cu_pos_x_r    ),
                .pos_y_i        ( cu_pos_y_r    ),
                .pu_width_i     ( pu_width_r    ),
                .pu_height_i    ( pu_height_r   ),
                .a_addr_o       ( pu_a_addr_w   ),
                .b_addr_o       ( pu_b_addr_w   )
);

// read from current LCU
always @* begin
    if(lcu_curr_state_r[2]) begin// cu run
        case (cu_cnt_r[1:0])
            2'd0: mv_rdaddr_o = pu_addr_w[5:0]                     ;// pu0 current 
            2'd1: mv_rdaddr_o = pu_a_addr_w[5:0]                   ;// pu0 a
            2'd2: mv_rdaddr_o = {pu_b_addr_w[6:4],pu_b_addr_w[2:0]};// pu0 b
         default: mv_rdaddr_o = 6'd0                               ;
        endcase
    end
    else if(lcu_curr_state_r==LCU_UPDATE) begin
        mv_rdaddr_o = cu_cnt_r[3]?{cu_cnt_r[2:0],3'b111}:{3'b111,cu_cnt_r[2:0]};//0-7:56-63,8-15:7 15 23 31 39 47 55 63 
    end
    else begin 
        mv_rdaddr_o = 6'd0;
    end 
end

// read enabl delay 1 cycle 
always @* begin
    if(lcu_curr_state_r[2]) begin// cu run
        case (cu_cnt_r[1:0])
            2'd1: mv_rden_o = cu_start_r     ;// pu0 current 
            2'd2: mv_rden_o = !pu_a_addr_w[7];// pu0 a
            2'd3: mv_rden_o = !pu_b_addr_w[8];// pu0 b
         default: mv_rden_o = 1'b1           ;
        endcase
    end
    else if(lcu_curr_state_r==LCU_UPDATE)begin
        mv_rden_o   = (cu_cnt_r==0);
    end
    else begin 
        mv_rden_o   = !(cu_cnt_d1_r==4'hf);
    end 
end

/*
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        mv_rden_o <= 1'b1;
    else if(lcu_curr_state_r[2]) begin// cu run
        case (cu_cnt_r[1:0])
            2'd0: mv_rden_o <= cu_start_r     ;// pu0 current 
            2'd1: mv_rden_o <= !pu_a_addr_w[7];// pu0 a
            2'd2: mv_rden_o <= !pu_b_addr_w[8];// pu0 b
         default: mv_rden_o <= 1'b1           ;
        endcase
    end
    else if(lcu_curr_state_r==LCU_UPDATE)begin
        mv_rden_o   <= (!cu_cnt_r);
    end
    else begin 
        mv_rden_o   <= 1'b1;
    end 
end
*/

// read from and write to Top LCU
always @* begin 
    if(lcu_curr_state_r[2]) // cu run ,read 
        case (cu_cnt_r[1:0])
            2'd3: begin top_mv_oen_r = pu_b_addr_w[7];top_mv_wen_r=1'b1;end // pu0 b
         default: begin top_mv_oen_r = 1'b0          ;top_mv_wen_r=1'b1;end 
        endcase
    else if(lcu_curr_state_r == LCU_UPDATE)begin // write
        top_mv_oen_r = 1'b0                   ;
        top_mv_wen_r = cu_cnt_d1_r[3]||(cu_cnt_r==0);
    end 
    else  begin 
        top_mv_oen_r = 1'b0;
        top_mv_wen_r = 1'b1;
    end 
end 

always @* begin 
    if(lcu_curr_state_r[2]) // cu run ,read 
        case (cu_cnt_r[1:0])
            2'd2: top_mv_addr_r = pu_b_addr_w[3:0]; // pu0 b
         default: top_mv_addr_r = 4'd0            ; 
        endcase
    else if(lcu_curr_state_r == LCU_UPDATE)begin // write
        top_mv_addr_r= {1'b0,cu_cnt_d1_r[2:0]};
    end 
    else  begin 
        top_mv_addr_r= 4'd0;
    end 
end 



// top_mv_addr_r:0..7,8 so 8 should consider specially 
assign  top_mv_addr_w  =  top_mv_addr_r + {mb_x_i,3'd0};

mc_mv_ram_sp_512x20 umv_top(
        .clk    ( clk           ) ,
        .cen_i  ( 1'b0          ) , // low active
        .wen_i  ( top_mv_wen_r  ) , // low active
        .addr_i ( top_mv_addr_w ) ,
        .data_i ( mv_data_i     ) ,
        .data_o ( top_mv_data_ow) 
    );

/*
`ifdef	XIONGMAI_MODEL
	rfsphd_64x20	U_rfsphd_64x20(
		.Q       (top_mv_data_ow	),
		.CLK     (clk			),
		.CEN     (1'b0			),
		.WEN     (top_mv_wen_r		),
		.A       (top_mv_addr_w		),
		.D       (mv_data_i		),
		.EMA     (3'b1			),
		.EMAW    (2'b0			),
		.RET1N   (1'b1			)
	);

`else
	ram_1p #(.Addr_Width((`PIC_X_WIDTH)), .Word_Width(2*`FMV_WIDTH)) umv_top(
	        .clk         ( clk            ),// clock input
	        .cen_i       ( 1'b0           ),// chip enable, low active
	        .oen_i       ( !top_mv_oen_r  ),// data output enable, low active
	        .wen_i       ( top_mv_wen_r   ),// write enable, low active
	        .addr_i      ( top_mv_addr_w  ),// address input
	        .data_i      ( mv_data_i      ),// data input
	        .data_o      ( top_mv_data_ow ) // data output
	);
`endif
*/

// read from and write to Left LCU
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        left_mv_memo_r  <='d0;
    else if(cu_cnt_d1_r[3])begin // 8--15
        case(cu_cnt_d1_r[2:0])
            3'd0:left_mv_memo_r <= {{(7*2*`FMV_WIDTH){1'b0}},mv_data_i};
            3'd1:left_mv_memo_r <= {{(6*2*`FMV_WIDTH){1'b0}},mv_data_i,left_mv_memo_r[1*2*`FMV_WIDTH-1:0]};
            3'd2:left_mv_memo_r <= {{(5*2*`FMV_WIDTH){1'b0}},mv_data_i,left_mv_memo_r[2*2*`FMV_WIDTH-1:0]};
            3'd3:left_mv_memo_r <= {{(4*2*`FMV_WIDTH){1'b0}},mv_data_i,left_mv_memo_r[3*2*`FMV_WIDTH-1:0]};
            3'd4:left_mv_memo_r <= {{(3*2*`FMV_WIDTH){1'b0}},mv_data_i,left_mv_memo_r[4*2*`FMV_WIDTH-1:0]};
            3'd5:left_mv_memo_r <= {{(2*2*`FMV_WIDTH){1'b0}},mv_data_i,left_mv_memo_r[5*2*`FMV_WIDTH-1:0]};
            3'd6:left_mv_memo_r <= {{(1*2*`FMV_WIDTH){1'b0}},mv_data_i,left_mv_memo_r[6*2*`FMV_WIDTH-1:0]};
            3'd7:left_mv_memo_r <= {                         mv_data_i,left_mv_memo_r[7*2*`FMV_WIDTH-1:0]};
        endcase
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        left_mv_data_r  <='d0;
    else if(pu_a_addr_w[6])begin
        case(pu_a_addr_w[5:3])
            3'd0:left_mv_data_r <= left_mv_memo_r[1*2*`FMV_WIDTH-1:0*2*`FMV_WIDTH];
            3'd1:left_mv_data_r <= left_mv_memo_r[2*2*`FMV_WIDTH-1:1*2*`FMV_WIDTH];
            3'd2:left_mv_data_r <= left_mv_memo_r[3*2*`FMV_WIDTH-1:2*2*`FMV_WIDTH];
            3'd3:left_mv_data_r <= left_mv_memo_r[4*2*`FMV_WIDTH-1:3*2*`FMV_WIDTH];
            3'd4:left_mv_data_r <= left_mv_memo_r[5*2*`FMV_WIDTH-1:4*2*`FMV_WIDTH];
            3'd5:left_mv_data_r <= left_mv_memo_r[6*2*`FMV_WIDTH-1:5*2*`FMV_WIDTH];
            3'd6:left_mv_data_r <= left_mv_memo_r[7*2*`FMV_WIDTH-1:6*2*`FMV_WIDTH];
            3'd7:left_mv_data_r <= left_mv_memo_r[8*2*`FMV_WIDTH-1:7*2*`FMV_WIDTH];
        endcase
    end
end

// calculation mvd and mvp_idx 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        mv_c_r  <=  'd0;
    else if(lcu_curr_state_r[2]&&cu_cnt_r[1:0]==2'd1)
        mv_c_r  <=  mv_data_i;
end 

always @*begin
    if(lcu_curr_state_r[2]&&pu_a_addr_w[6])// mv a
        mv_a_r   =  left_mv_data_r;
    else if(lcu_curr_state_r[2]&&pu_a_addr_w[7]) // mv a
        mv_a_r   =  mv_data_i;
    else
        mv_a_r   =  2*`FMV_WIDTH'd0;
end

always @*begin
    if(lcu_curr_state_r[2]&&top_mv_oen_r) // mv b
        mv_b_r   =  top_mv_data_ow;
    else if(lcu_curr_state_r[2]&&pu_b_addr_w[8]) // mv b 
        mv_b_r   =  mv_data_i;
    else 
        mv_b_r   =  2*`FMV_WIDTH'd0;
end
/*delete at 2018/7/25
always @*begin
    if(cu_cnt_r[1:0]==2'd2 && pu_a_addr_w != 0)// mv a
        mv_p_r   =  mv_a_r;
    // else if(cu_cnt_r[1:0]==2'd3&&mv_a_d1_r==mv_b_r) // mv b 
    //     mv_p_r   =  2*`FMV_WIDTH'd0;
    else if(cu_cnt_r[1:0]==2'd3 && pu_b_addr_w != 0 && mv_a_d1_r!=mv_b_r)
        mv_p_r   =  mv_b_r;
    else 
        mv_p_r   =  2*`FMV_WIDTH'd0;
end*/

always @*begin
    if(cu_cnt_r[1:0]==2'd2)// mv a
        mv_p_r   =  mv_a_r;
    else if(cu_cnt_r[1:0]==2'd3&&mv_a_d1_r==mv_b_r) // mv b 
        mv_p_r   =  2*`FMV_WIDTH'd0;
    else if(cu_cnt_r[1:0]==2'd3)
        mv_p_r   =  mv_b_r;
    else 
        mv_p_r   =  2*`FMV_WIDTH'd0;
end

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)
        mv_a_d1_r <=  'd0;
    else if(lcu_curr_state_r[2]&&cu_cnt_r[1:0]==2'd2)
        mv_a_d1_r <= mv_a_r;
end 

// get Bits 
mvd_getBits mvd_getBits_ua(
        .mv_i          ( mv_c_r           ),
        .mvp_i         ( mv_p_r           ),
        .mv_bits_cnt_o ( mv_bits_cnt_w    ),
        .mvd_o         ( mvd_w            )
);

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n)begin 
        mvd_r <= 'd0;
        mv_bits_cnt_r <='d0;
    end 
    else if(lcu_curr_state_r[2]&&cu_cnt_r[1:0]==2'd2)begin 
        mvd_r <= mvd_w;
        mv_bits_cnt_r <=mv_bits_cnt_w;
    end 
end 

always @*begin
    if(lcu_curr_state_r[2]&&cu_cnt_r[1:0]==2'd3)
        mvd_wen_o =1'd0;
    else
        mvd_wen_o =1'd1;
end


always @*begin
    if((pu_a_addr_w[7:6]==0)&&(pu_b_addr_w[8:7] != 0)) // a0 not exist and b0 exist 
        mvp_final_idx = !mvp_idx;
    else 
        mvp_final_idx =  mvp_idx;
end 

always @*begin 
    if(lcu_curr_state_r[2]&&cu_cnt_r[1:0]==2'd3) begin 
        if ( pu_a_addr_w != 0 && pu_b_addr_w != 0 ) begin 
            if(mv_bits_cnt_r<=mv_bits_cnt_w)begin 
                mvd_final_r = mvd_r;
                mvp_idx     = 1'b0;
            end 
            else begin
                mvd_final_r = mvd_w;
                mvp_idx     = 1'b1;
            end 
        end 
        else if ( pu_a_addr_w != 0 && pu_b_addr_w == 0 ) begin // a 
            mvd_final_r = mvd_r;
            mvp_idx     = 1'b0;
        end 
        else if ( pu_a_addr_w == 0 && pu_b_addr_w != 0 ) begin // b
            mvd_final_r = mvd_w;
            mvp_idx     = 1'b1;
        end 
        else begin 
            mvd_final_r = mvd_w;
            mvp_idx     = 1'b0;
        end 
    end 
    else begin
            mvd_final_r = mvd_w;
            mvp_idx     = 1'b1;
    end 
end 



assign  mvd_addr_o = {cu_pos_y_r[5:3],cu_pos_x_r[5:3]};// write out by line 
assign  mvd_done_o = (lcu_curr_state_r==LCU_UPDATE)&&(cu_done_r);
assign  mvd_and_mvp_idx_o = {mvp_final_idx,mvd_final_r};

endmodule 

