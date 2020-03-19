//------------------------------------------------------------
//
//  File Name       : fme_mv_buffer.v
//  Author          : TANG 
//  Date            : 2018-06-14
//  Description     : top and left mv buffer
//
//-------------------------------------------------------------
`include "enc_defines.v"

module fme_mv_buffer(
        clk                     ,
        rstn                    ,
        fme_ctu_x_i             ,
        current_state_i         ,
        // top and left mv wr
        mv_wr_ena_i             ,
        mv_wr_adr_i             ,
        mv_wr_dat_i             ,
        // left mv rd
        lft_mv_rd_ena_i         ,
        lft_mv_rd_adr_i         ,
        lft_mv_rd_dat_o         ,
        // top  mv rd
        top_mv_rd_ena_i         ,
        top_mv_rd_adr_i         ,
        top_mv_rd_dat_o         
);

//---- parameter ----------------------------------------------
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

//---- input / output -----------------------------------------
    input                           clk             ;
    input                           rstn            ;
    input   [`PIC_X_WIDTH-1:0]      fme_ctu_x_i     ;
    input   [4-1:0]                 current_state_i ;
    // wr   
    input                           mv_wr_ena_i     ;
    input   [6-1:0]                 mv_wr_adr_i     ;
    input   [2*`FMV_WIDTH-1:0]      mv_wr_dat_i     ;
    // left read    
    input                           lft_mv_rd_ena_i ;
    input   [3-1:0]                 lft_mv_rd_adr_i ;
    output  [2*`FMV_WIDTH-1:0]      lft_mv_rd_dat_o ;
    // top read 
    input                           top_mv_rd_ena_i ;
    input   [`PIC_X_WIDTH+3-1:0]    top_mv_rd_adr_i ;
    output  [2*`FMV_WIDTH-1:0]      top_mv_rd_dat_o ;

//---- wire/reg declaration -------------------------------------
    reg                             mv_wr_ena_d1    ;
    reg     [6-1:0]                 mv_wr_adr_d1    ;
    
    wire                            top_mv_wr_ena_w ;
    wire    [`PIC_X_WIDTH+3-1:0]    top_mv_adr_w    ;
    reg     [`PIC_X_WIDTH+3-1:0]    top_mv_rd_adr_d1;

    reg     [2*`FMV_WIDTH-1:0]      fmv_lft_r_0 [8-1:0]; // ping-pong buffer
    reg     [2*`FMV_WIDTH-1:0]      fmv_lft_r_1 [8-1:0]; // ping-pong buffer

    reg     [2*`FMV_WIDTH-1:0]      lft_mv_rd_dat_o ; 

    reg     [2*`FMV_WIDTH-1:0]      tl_mv_r_0, tl_mv_r_1, tl_mv_r;
    wire    [2*`FMV_WIDTH-1:0]      top_mv_rd_dat_w;

    wire    [3-1:0]                 lft_mv_rd_adr_w    ;
    wire    [3-1:0]                 lft_mv_wr_adr_w    ;
    wire                            lft_mv_wr_ena_w    ;
    reg top_mv_rd_ena_d1; 
//---- top mv mem -----------------------------------------------

    always @ (posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            mv_wr_ena_d1 <= 0 ;
            mv_wr_adr_d1 <= 0 ;
        end else begin 
            mv_wr_ena_d1 <= mv_wr_ena_i ;
            mv_wr_adr_d1 <= mv_wr_adr_i ;
        end 
    end 
    
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            top_mv_rd_ena_d1 <= 0; 
            top_mv_rd_adr_d1 <= 0;
        end 
        else begin 
            top_mv_rd_ena_d1 <= top_mv_rd_ena_i;
            top_mv_rd_adr_d1 <= top_mv_rd_adr_i;
        end
    end 

    assign top_mv_wr_ena_w = current_state_i >= PRE_MC && current_state_i <= DONE_MC && mv_wr_ena_d1 && (mv_wr_adr_d1 > 55) ;

    assign top_mv_adr_w = top_mv_wr_ena_w ? (mv_wr_adr_d1-56+(fme_ctu_x_i<<3)) : top_mv_rd_adr_i ;

    assign top_mv_rd_dat_o = ( top_mv_rd_ena_d1 && top_mv_rd_adr_d1[2:0] == 'b111 && (top_mv_rd_adr_d1[`PIC_X_WIDTH+3-1:3]!=fme_ctu_x_i)) ? tl_mv_r : top_mv_rd_dat_w;

    db_mv_ram_sp_512x20 u_mv_ram_sp_512x20(
        .clk       ( clk              ),
        // address
        .adr_i     ( top_mv_adr_w     ),
        // write
        .wr_ena_i  ( !top_mv_wr_ena_w ), // low active
        .wr_dat_i  ( mv_wr_dat_i      ),
        // read
        .rd_ena_i  ( !top_mv_rd_ena_i ), // low active
        .rd_dat_o  ( top_mv_rd_dat_w  )
    );

    // top left mv 


    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) begin 
            tl_mv_r <= 0;
        end 
        else if (top_mv_rd_ena_d1 && top_mv_rd_adr_d1[2:0] == 'b111 ) begin 
            tl_mv_r <= top_mv_rd_dat_w;
        end 
    end 

//---- left mv buffer ---------------------------------------------------
    assign lft_mv_rd_adr_w = lft_mv_rd_adr_i; 
    always @ ( posedge clk or negedge rstn ) begin 
        if ( !rstn ) 
            lft_mv_rd_dat_o <= 0;
        else if ( lft_mv_rd_ena_i ) begin 
            if ( fme_ctu_x_i[0] == 0 )
                lft_mv_rd_dat_o <= fmv_lft_r_1[lft_mv_rd_adr_w] ; 
            else 
                lft_mv_rd_dat_o <= fmv_lft_r_0[lft_mv_rd_adr_w] ; 
        end 
    end 

    assign lft_mv_wr_adr_w = mv_wr_adr_d1[5:3] ; 
    assign lft_mv_wr_ena_w = current_state_i >= PRE_MC && current_state_i <= DONE_MC && mv_wr_adr_d1[2:0] == 3'b111 && mv_wr_ena_d1 ;
    always @ ( posedge clk or negedge rstn ) begin  
        if ( !rstn ) begin 
            fmv_lft_r_0[0] <= 0 ;
            fmv_lft_r_0[1] <= 0 ;
            fmv_lft_r_0[2] <= 0 ;
            fmv_lft_r_0[3] <= 0 ;
            fmv_lft_r_0[4] <= 0 ;
            fmv_lft_r_0[5] <= 0 ;
            fmv_lft_r_0[6] <= 0 ;
            fmv_lft_r_0[7] <= 0 ;
            fmv_lft_r_1[0] <= 0 ;
            fmv_lft_r_1[1] <= 0 ;
            fmv_lft_r_1[2] <= 0 ;
            fmv_lft_r_1[3] <= 0 ;
            fmv_lft_r_1[4] <= 0 ;
            fmv_lft_r_1[5] <= 0 ;
            fmv_lft_r_1[6] <= 0 ;
            fmv_lft_r_1[7] <= 0 ;
        end else if ( lft_mv_wr_ena_w ) begin 
            if (fme_ctu_x_i[0] == 0)
                fmv_lft_r_0[lft_mv_wr_adr_w] <= mv_wr_dat_i ; 
            else 
                fmv_lft_r_1[lft_mv_wr_adr_w] <= mv_wr_dat_i ;     
        end 
    end 

endmodule 