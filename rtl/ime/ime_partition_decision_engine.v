//--------------------------------------------------------------------
//
//  Filename    : ime_partition_decision_engine.v
//  Author      : Huang Leilei
//  Description : partition decision engine in ime module
//  Created     : 2018-03-23
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module ime_partition_decision_engine (
  // global
  dat_1nx1n_cst_0_i      ,
  dat_1nx1n_cst_1_i      ,
  dat_1nx1n_cst_2_i      ,
  dat_1nx1n_cst_3_i      ,
  dat_1nx2n_cst_0_i      ,
  dat_1nx2n_cst_1_i      ,
  dat_2nx1n_cst_0_i      ,
  dat_2nx1n_cst_1_i      ,
  dat_2nx2n_cst_i        ,
  // config 
  part_x                 , 
  part_y                 ,
  ctu_x_all_i            ,
  ctu_y_all_i            ,
  ctu_x_res_i            ,
  ctu_y_res_i            ,
  ctu_x_cur_i            ,
  ctu_y_cur_i            ,
  // deci_o
  dat_bst_partition_o    ,
  dat_bst_cst_o
  );


//*** PARAMETER DECLARATION ****************************************************


//*** INPUT/OUTPUT DECLARATION *************************************************

  // cost_i
  input      [`IME_COST_WIDTH-1    : 0]    dat_1nx1n_cst_0_i        ;
  input      [`IME_COST_WIDTH-1    : 0]    dat_1nx1n_cst_1_i        ;
  input      [`IME_COST_WIDTH-1    : 0]    dat_1nx1n_cst_2_i        ;
  input      [`IME_COST_WIDTH-1    : 0]    dat_1nx1n_cst_3_i        ;
  input      [`IME_COST_WIDTH-1    : 0]    dat_1nx2n_cst_0_i        ;
  input      [`IME_COST_WIDTH-1    : 0]    dat_1nx2n_cst_1_i        ;
  input      [`IME_COST_WIDTH-1    : 0]    dat_2nx1n_cst_0_i        ;
  input      [`IME_COST_WIDTH-1    : 0]    dat_2nx1n_cst_1_i        ;
  input      [`IME_COST_WIDTH-1    : 0]    dat_2nx2n_cst_i          ;
  // config
  input      [6                 -1 : 0]    part_x                   ;
  input      [6                 -1 : 0]    part_y                   ;
  input      [`PIC_X_WIDTH      -1 : 0]    ctu_x_all_i              ;
  input      [`PIC_Y_WIDTH      -1 : 0]    ctu_y_all_i              ;
  input      [6                 -1 : 0]    ctu_x_res_i              ;
  input      [6                 -1 : 0]    ctu_y_res_i              ;
  input      [`PIC_X_WIDTH      -1 : 0]    ctu_x_cur_i              ;
  input      [`PIC_Y_WIDTH      -1 : 0]    ctu_y_cur_i              ;
  // deci_o
  output reg [1                    : 0]    dat_bst_partition_o      ;    // it's wire
  output     [`IME_COST_WIDTH-1    : 0]    dat_bst_cst_o            ;    // it's wire


//*** WIRE & REG DECLARATION ***************************************************

  wire       [`IME_COST_WIDTH+1    : 0]    cost_1nx1n_w             ;
  wire       [`IME_COST_WIDTH+1    : 0]    cost_2nx1n_w             ;
  wire       [`IME_COST_WIDTH+1    : 0]    cost_1nx2n_w             ;
  wire       [`IME_COST_WIDTH+1    : 0]    cost_2nx2n_w             ;

  reg        [`IME_COST_WIDTH+1    : 0]    dat_bst_cst_w            ;

  wire                                     is_1nx1n_bt_2nx1n_w      ;
  wire                                     is_2nx1n_bt_1nx2n_w      ;

  wire                                     is_former_bt_latter_w    ;

  wire                                     is_boundary              ;


//*** MAIN BODY ****************************************************************

  assign cost_1nx1n_w = dat_1nx1n_cst_0_i + dat_1nx1n_cst_1_i + dat_1nx1n_cst_2_i + dat_1nx1n_cst_3_i ;
  assign cost_1nx2n_w = dat_1nx2n_cst_0_i + dat_1nx2n_cst_1_i ;
  assign cost_2nx1n_w = dat_2nx1n_cst_0_i + dat_2nx1n_cst_1_i ;
  assign cost_2nx2n_w = dat_2nx2n_cst_i   ;

  assign is_1nx1n_bt_2nx1n_w = cost_1nx1n_w < cost_2nx1n_w ;
  assign is_2nx1n_bt_1nx2n_w = cost_1nx2n_w < cost_2nx2n_w ;

  assign is_former_bt_latter_w = ( is_1nx1n_bt_2nx1n_w ? cost_1nx1n_w : cost_2nx1n_w )
                               < ( is_2nx1n_bt_1nx2n_w ? cost_1nx2n_w : cost_2nx2n_w );

  assign is_boundary = ( part_x>(`LCU_SIZE-ctu_x_res_i)&&ctu_x_cur_i==ctu_x_all_i ) 
                    || ( part_y>(`LCU_SIZE-ctu_y_res_i)&&ctu_y_cur_i==ctu_y_all_i )  ;                

  always @(*) begin
                begin dat_bst_partition_o = `IME_PART_2NX2N ; dat_bst_cst_w = cost_2nx2n_w ; end
    if ( is_boundary ) begin
      dat_bst_partition_o = `IME_PART_1NX1N ;
      dat_bst_cst_w = cost_1nx1n_w ;
    end
    else begin
      casez( {is_former_bt_latter_w, is_1nx1n_bt_2nx1n_w ,is_2nx1n_bt_1nx2n_w} )
        3'b11?  : begin dat_bst_partition_o = `IME_PART_1NX1N ; dat_bst_cst_w = cost_1nx1n_w ; end
        3'b10?  : begin dat_bst_partition_o = `IME_PART_2NX1N ; dat_bst_cst_w = cost_2nx1n_w ; end
        3'b0?1  : begin dat_bst_partition_o = `IME_PART_1NX2N ; dat_bst_cst_w = cost_1nx2n_w ; end
        3'b0?0  : begin dat_bst_partition_o = `IME_PART_2NX2N ; dat_bst_cst_w = cost_2nx2n_w ; end
      endcase
    end
  end

  assign dat_bst_cst_o = ( dat_bst_cst_w>{{(`IME_COST_WIDTH){1'b1}}} ) ? {{(`IME_COST_WIDTH){1'b1}}} : dat_bst_cst_w ;


//*** DEBUG ********************************************************************

  `ifdef DEBUG


  `endif

endmodule
