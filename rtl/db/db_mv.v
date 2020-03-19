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
// Filename       : db_mv.v
// Author         : TANG
// Creatu_ved     : 
// Description    :         
//------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module db_mv(
            clk                 ,
            rst_n               ,
            state_i             ,
            cnt_i               ,
            sys_ctu_x_i         ,
            sys_ctu_y_i         ,
            
            mb_mv_ren_o         , 
            mb_mv_raddr_o       ,
            mb_mv_rdata_i       ,

            mv_p_o              ,
            mv_q_o              
);

//*** parameter declaration *********************************
    parameter IDLE = 3'b000, LOAD = 3'b001, DBY = 3'b011, DBU = 3'b010, DBV = 3'b110, SAO = 3'b100, OUT = 3'b101;

//*** input / output declaration ****************************
    input                       clk, rst_n          ;
    input   [2:0]               state_i             ;
    input   [8:0]               cnt_i               ;
    input   [`PIC_X_WIDTH-1 :0] sys_ctu_x_i         ;
    input   [`PIC_Y_WIDTH-1 :0] sys_ctu_y_i         ;

    output                      mb_mv_ren_o         ;
    output  [5:0]               mb_mv_raddr_o       ;
    input   [`FMV_WIDTH*2-1 :0] mb_mv_rdata_i       ;

    output  [`FMV_WIDTH*2-1:0]  mv_q_o              ;
    output  [`FMV_WIDTH*2-1:0]  mv_p_o              ;

//*** wire / reg declaration ******************************
    reg     [`FMV_WIDTH*2-1:0]  mv_q_o              ;
    reg     [`FMV_WIDTH*2-1:0]  mv_p_o              ;

    wire                        cur_mv_wen_w        ;
    wire    [5:0]               cur_mv_addr_w       ;
    reg     [5:0]               cur_mv_rd_addr_w    ;
    wire    [5:0]               cur_mv_wr_addr_w    ;
    wire    [`FMV_WIDTH*2-1:0]  cur_mv_data_o_w     ;
    wire    [`FMV_WIDTH*2-1:0]  cur_mv_data_i_w     ;

    wire                        top_mv_ren_w        ;
    wire                        top_mv_wen_w        ;
    wire    [`PIC_X_WIDTH+2:0]  top_mv_addr_w       ;
    wire    [`PIC_X_WIDTH+2:0]  top_mv_rd_addr_w    ;
    wire    [`PIC_X_WIDTH+2:0]  top_mv_wr_addr_w    ;
    wire    [`FMV_WIDTH*2-1:0]  top_mv_data_o_w     ;
    wire    [`FMV_WIDTH*2-1:0]  top_mv_data_i_w     ;

    reg     [`FMV_WIDTH*2-1:0]  mv_pre_up_r         ; // pre_up | cur_up
    reg     [`FMV_WIDTH*2-1:0]  mv_pre_dn_r         ; // pre_dn | cur_dn
    reg     [`FMV_WIDTH*2-1:0]  mv_cur_up_r         ; // 
    reg     [`FMV_WIDTH*2-1:0]  mv_cur_dn_r         ; // 

    reg     [`FMV_WIDTH*2-1:0]  left_mv     [7:0]   ;
    reg     [`FMV_WIDTH*2-1:0]  tl_mv               ; 
    wire    [`FMV_WIDTH*2-1:0]  mv_data_o_w         ;  

    reg     [8:0]               cnt_r               ;    

//*** cnt_i delay ***************************************
    always @ (posedge clk or negedge rst_n ) begin 
        if ( !rst_n ) 
            cnt_r <= 0;
        else 
            cnt_r <= cnt_i ;
    end 

//*** cur mv input *******************************************
    assign mb_mv_ren_o      = !(state_i == LOAD&&cnt_i<64)    ;
    assign mb_mv_raddr_o    = cnt_i[5:0]            ;

    assign cur_mv_wen_w     = !(state_i == LOAD&&cnt_i<65)    ;
    assign cur_mv_wr_addr_w = cnt_r[5:0]            ;
    assign cur_mv_data_i_w  = mb_mv_rdata_i         ;

//*** cur mv read ********************************************
    always @* begin 
        if ( cnt_i[8:5] == 0 )
            cur_mv_rd_addr_w = cnt_i[4:2]           ;
        else 
            cur_mv_rd_addr_w = cnt_i[1:0] == 0 ? (cnt_i[8:2]-7'd8 ) : cnt_i[8:2] ; 
    end 

    assign cur_mv_addr_w     = cur_mv_wen_w ? cur_mv_rd_addr_w : cur_mv_wr_addr_w ;

//*** top mv **********************************************
    assign top_mv_ren_w = !( sys_ctu_y_i != 0 && state_i == DBY && cnt_i[8:5] == 0 && cnt_i[1:0] == 0) ;
    assign top_mv_rd_addr_w = ( top_mv_ren_w == 0 ) ? (sys_ctu_x_i<<3) + cnt_i[4:2] : 0;

    assign top_mv_wen_w = !(state_i == DBY && cnt_r[8:5] == 7 && cnt_r[1:0] == 1);
    assign top_mv_wr_addr_w = top_mv_wen_w == 0 ? (sys_ctu_x_i<<3)+cnt_r[4:2] : 0;
    assign top_mv_data_i_w = cur_mv_data_o_w;
 
    assign top_mv_addr_w = top_mv_ren_w ==0 ? top_mv_rd_addr_w : top_mv_wr_addr_w;

//*** store left mv ***************************************

    assign mv_data_o_w = ((cnt_r[8:5] == 0) && (cnt_r[1:0] == 0)) ? top_mv_data_o_w : cur_mv_data_o_w ;

    always @ ( posedge clk or negedge rst_n ) begin 
        if ( !rst_n ) begin
            left_mv[0]      <= 0      ;
            left_mv[1]      <= 0      ;
            left_mv[2]      <= 0      ;
            left_mv[3]      <= 0      ;
            left_mv[4]      <= 0      ;
            left_mv[5]      <= 0      ;
            left_mv[6]      <= 0      ;
            left_mv[7]      <= 0      ;
        end else if ( sys_ctu_x_i == 0 ) begin 
            left_mv[0]      <= 0      ;
            left_mv[1]      <= 0      ;
            left_mv[2]      <= 0      ;
            left_mv[3]      <= 0      ;
            left_mv[4]      <= 0      ;
            left_mv[5]      <= 0      ;
            left_mv[6]      <= 0      ;
            left_mv[7]      <= 0      ;
        end else if (cnt_r[8:5]>0 && cnt_r[4:2] == 3'b111) begin 
            left_mv[cnt_r[8:5]-3'd1] <= cnt_r[1:0] == 2'd0 ? mv_data_o_w : left_mv[cnt_r[8:5]-3'd1] ;
        end 
    end 

    always @ ( posedge clk or negedge rst_n ) begin 
        if ( !rst_n ) 
            tl_mv <= 0;
        else if ( sys_ctu_y_i == 0 || sys_ctu_x_i == 0 )
            tl_mv <= 0;
        else if (cnt_r==5'b11100)  
            tl_mv <= mv_data_o_w ;
    end 

//*** output mv *********************************
    always @ ( posedge clk or negedge rst_n ) begin 
        if ( !rst_n )
            mv_cur_up_r  <= 0;
        else if ( cnt_r[1:0] == 2'b00) 
            mv_cur_up_r  <= mv_data_o_w;
        else 
            mv_cur_up_r  <= mv_cur_up_r;
    end 
    
    always @ ( posedge clk or negedge rst_n ) begin 
        if ( !rst_n )
            mv_cur_dn_r  <= 0;
        else if ( cnt_r[1:0] == 2'b01) 
            mv_cur_dn_r  <= mv_data_o_w;
        else 
            mv_cur_dn_r  <= mv_cur_dn_r;
    end 
    
    always @ ( posedge clk or negedge rst_n ) begin 
        if ( !rst_n )begin 
            mv_pre_up_r  <= 0;
            mv_pre_dn_r  <= 0;
        end 
        else if (cnt_i == 0) begin 
            mv_pre_up_r  <= tl_mv ;
            mv_pre_dn_r  <= left_mv[0] ;
        end else if (cnt_i[4:2] == 0) begin 
            mv_pre_up_r  <= left_mv[cnt_r[7:5]-3'd1] ;
            mv_pre_dn_r  <= left_mv[cnt_r[7:5]] ;
        end else if (cnt_r[1:0] == 2'b11) begin 
            mv_pre_up_r  <= mv_cur_up_r;
            mv_pre_dn_r  <= mv_cur_dn_r;
        end 
        else begin 
            mv_pre_up_r  <= mv_pre_up_r;
            mv_pre_dn_r  <= mv_pre_dn_r;
        end 
    end 


    always @ ( posedge clk or negedge rst_n ) begin 
        if ( !rst_n ) begin 
            mv_p_o      <= 'd0;
            mv_q_o      <= 'd0;
        end else 
        case ( cnt_r[1:0] )
            2'b00 : begin mv_p_o <= mv_pre_up_r; mv_q_o <= mv_data_o_w; end 
            2'b01 : begin mv_p_o <= mv_pre_dn_r; mv_q_o <= mv_data_o_w; end 
            2'b10 : begin mv_p_o <= mv_pre_up_r; mv_q_o <= mv_pre_dn_r; end 
            2'b11 : begin mv_p_o <= mv_cur_up_r; mv_q_o <= mv_cur_dn_r; end 
            default:begin mv_p_o <= 'd0        ; mv_q_o <= 'd0        ; end 
        endcase 
    end 

//*** ram declaration *************************************

db_mv_ram_sp_64x20 u_db_cur_mv(
    .clk        ( clk              ) ,
    .adr_i      ( cur_mv_addr_w    ) ,
    .cen_i      ( 1'b0             ) , // low active
    .wen_i      ( cur_mv_wen_w     ) ,
    .wr_dat_i   ( cur_mv_data_i_w  ) ,
    .rd_dat_o   ( cur_mv_data_o_w  ) 
    );  

db_mv_ram_sp_512x20 u_db_top_mv(
        // global
        .clk         ( clk              ),
        // address
        .adr_i       ( top_mv_addr_w    ),
        // write
        .wr_ena_i    ( top_mv_wen_w     ),  // low active
        .wr_dat_i    ( top_mv_data_i_w  ), 
        // read
        .rd_ena_i    ( top_mv_ren_w     ),  // low active
        .rd_dat_o    ( top_mv_data_o_w  )
    );

endmodule 