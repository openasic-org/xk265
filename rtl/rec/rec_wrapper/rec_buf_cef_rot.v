//--------------------------------------------------------------------
//
//  Filename    : rec_buf_cef_rot.v
//  Author      : Huang Leilei
//  Created     : 2018-05-22
//  Description : mem buf for cef (3 buf rotate)
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module rec_buf_cef_rot (
  // global
  clk             ,
  rstn            ,
  // ctrl_i
  rotate_i        ,
  // wr_0
  wr_0_ena_i      ,
  wr_0_sel_i      ,
  wr_0_siz_i      ,
  wr_0_4x4_x_i    ,
  wr_0_4x4_y_i    ,
  wr_0_idx_i      ,
  wr_0_dat_i      ,
  // rd_0
  rd_0_ena_i      ,
  rd_0_sel_i      ,
  rd_0_siz_i      ,
  rd_0_4x4_x_i    ,
  rd_0_4x4_y_i    ,
  rd_0_idx_i      ,
  rd_0_dat_o      ,
  // rd_2
  rd_2_ena_i      ,
  rd_2_sel_i      ,
  rd_2_siz_i      ,
  rd_2_4x4_x_i    ,
  rd_2_4x4_y_i    ,
  rd_2_idx_i      ,
  rd_2_dat_o
  );


//*** PARAMETER ****************************************************************


//*** INPUT/OUTPUT *************************************************************

  // global
  input                            clk             ;
  input                            rstn            ;
  // ctrl_i
  input                            rotate_i        ;
  // wr_0_i
  input                            wr_0_ena_i      ;
  input  [2              -1 :0]    wr_0_sel_i      ;
  input  [2              -1 :0]    wr_0_siz_i      ;
  input  [4              -1 :0]    wr_0_4x4_x_i    ;
  input  [4              -1 :0]    wr_0_4x4_y_i    ;
  input  [5              -1 :0]    wr_0_idx_i      ;
  input  [`COEFF_WIDTH*32-1 :0]    wr_0_dat_i      ;
  // rd_0_i
  input                            rd_0_ena_i      ;
  input  [2              -1 :0]    rd_0_sel_i      ;
  input  [2              -1 :0]    rd_0_siz_i      ;
  input  [4              -1 :0]    rd_0_4x4_x_i    ;
  input  [4              -1 :0]    rd_0_4x4_y_i    ;
  input  [5              -1 :0]    rd_0_idx_i      ;
  output [`COEFF_WIDTH*32-1 :0]    rd_0_dat_o      ;
  // rd_2_i
  input                            rd_2_ena_i      ;
  input  [2              -1 :0]    rd_2_sel_i      ;
  input  [2              -1 :0]    rd_2_siz_i      ;
  input  [4              -1 :0]    rd_2_4x4_x_i    ;
  input  [4              -1 :0]    rd_2_4x4_y_i    ;
  input  [5              -1 :0]    rd_2_idx_i      ;
  output [`COEFF_WIDTH*32-1 :0]    rd_2_dat_o      ;


//*** REG/WIRE *****************************************************************

  // miss_wr
  wire                             wr_1_ena_i      , wr_2_ena_i      ;
  wire   [2              -1 :0]    wr_1_sel_i      , wr_2_sel_i      ;
  wire   [2              -1 :0]    wr_1_siz_i      , wr_2_siz_i      ;
  wire   [4              -1 :0]    wr_1_4x4_x_i    , wr_2_4x4_x_i    ;
  wire   [4              -1 :0]    wr_1_4x4_y_i    , wr_2_4x4_y_i    ;
  wire   [5              -1 :0]    wr_1_idx_i      , wr_2_idx_i      ;
  wire   [`COEFF_WIDTH*32-1 :0]    wr_1_dat_i      , wr_2_dat_i      ;
  // miss_rd
  wire                             rd_1_ena_i      ;
  wire   [2              -1 :0]    rd_1_sel_i      ;
  wire   [2              -1 :0]    rd_1_siz_i      ;
  wire   [4              -1 :0]    rd_1_4x4_x_i    ;
  wire   [4              -1 :0]    rd_1_4x4_y_i    ;
  wire   [5              -1 :0]    rd_1_idx_i      ;

  // rotate_r
  reg    [2              -1 :0]    rotate_r        ;

  // rotate_wr
  reg                              wr_a_ena_w      , wr_b_ena_w      , wr_c_ena_w      ;
  reg    [2              -1 :0]    wr_a_sel_w      , wr_b_sel_w      , wr_c_sel_w      ;
  reg    [2              -1 :0]    wr_a_siz_w      , wr_b_siz_w      , wr_c_siz_w      ;
  reg    [4              -1 :0]    wr_a_4x4_x_w    , wr_b_4x4_x_w    , wr_c_4x4_x_w    ;
  reg    [4              -1 :0]    wr_a_4x4_y_w    , wr_b_4x4_y_w    , wr_c_4x4_y_w    ;
  reg    [5              -1 :0]    wr_a_idx_w      , wr_b_idx_w      , wr_c_idx_w      ;
  reg    [`COEFF_WIDTH*32-1 :0]    wr_a_dat_w      , wr_b_dat_w      , wr_c_dat_w      ;
  // rotate_rd
  reg                              rd_a_ena_w      , rd_b_ena_w      , rd_c_ena_w      ;
  reg    [2              -1 :0]    rd_a_sel_w      , rd_b_sel_w      , rd_c_sel_w      ;
  reg    [2              -1 :0]    rd_a_siz_w      , rd_b_siz_w      , rd_c_siz_w      ;
  reg    [4              -1 :0]    rd_a_4x4_x_w    , rd_b_4x4_x_w    , rd_c_4x4_x_w    ;
  reg    [4              -1 :0]    rd_a_4x4_y_w    , rd_b_4x4_y_w    , rd_c_4x4_y_w    ;
  reg    [5              -1 :0]    rd_a_idx_w      , rd_b_idx_w      , rd_c_idx_w      ;
  wire   [`COEFF_WIDTH*32-1 :0]    rd_a_dat_w      , rd_b_dat_w      , rd_c_dat_w      ;

  reg    [`COEFF_WIDTH*32-1 :0]    rd_0_dat_o      , rd_1_dat_o      , rd_2_dat_o      ;


//*** MAIN BODY ****************************************************************

  // miss i/o
  assign wr_1_ena_i   = 0 ;    assign wr_2_ena_i   = 0 ;
  assign wr_1_sel_i   = 0 ;    assign wr_2_sel_i   = 0 ;
  assign wr_1_siz_i   = 0 ;    assign wr_2_siz_i   = 0 ;
  assign wr_1_4x4_x_i = 0 ;    assign wr_2_4x4_x_i = 0 ;
  assign wr_1_4x4_y_i = 0 ;    assign wr_2_4x4_y_i = 0 ;
  assign wr_1_idx_i   = 0 ;    assign wr_2_idx_i   = 0 ;
  assign wr_1_dat_i   = 0 ;    assign wr_2_dat_i   = 0 ;

  assign rd_1_ena_i   = 0 ;
  assign rd_1_sel_i   = 0 ;
  assign rd_1_siz_i   = 0 ;
  assign rd_1_4x4_x_i = 0 ;
  assign rd_1_4x4_y_i = 0 ;
  assign rd_1_idx_i   = 0 ;

  // rotate_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rotate_r <= 0 ;
    end
    else begin
      if( rotate_i ) begin
        if( rotate_r==3-1 ) begin
          rotate_r <= 0 ;
        end
        else begin
          rotate_r <= rotate_r + 1 ;
        end
      end
    end
  end

  /*
  cef_3  | 0         1           2          
  rama   | rec       blank       ec   
  ramb   | ec        rec         blank      
  ramc   | blank     ec          rec      
  */

  // rotate
  always @(*) begin
                   wr_a_ena_w   = wr_0_ena_i   ; wr_b_ena_w   = wr_1_ena_i   ; wr_c_ena_w   = wr_2_ena_i   ;
                   wr_a_sel_w   = wr_0_sel_i   ; wr_b_sel_w   = wr_1_sel_i   ; wr_c_sel_w   = wr_2_sel_i   ;
                   wr_a_siz_w   = wr_0_siz_i   ; wr_b_siz_w   = wr_1_siz_i   ; wr_c_siz_w   = wr_2_siz_i   ;
                   wr_a_4x4_x_w = wr_0_4x4_x_i ; wr_b_4x4_x_w = wr_1_4x4_x_i ; wr_c_4x4_x_w = wr_2_4x4_x_i ;
                   wr_a_4x4_y_w = wr_0_4x4_y_i ; wr_b_4x4_y_w = wr_1_4x4_y_i ; wr_c_4x4_y_w = wr_2_4x4_y_i ;
                   wr_a_idx_w   = wr_0_idx_i   ; wr_b_idx_w   = wr_1_idx_i   ; wr_c_idx_w   = wr_2_idx_i   ;
                   wr_a_dat_w   = wr_0_dat_i   ; wr_b_dat_w   = wr_1_dat_i   ; wr_c_dat_w   = wr_2_dat_i   ;
                   rd_a_ena_w   = rd_0_ena_i   ; rd_b_ena_w   = rd_1_ena_i   ; rd_c_ena_w   = rd_2_ena_i   ;
                   rd_a_sel_w   = rd_0_sel_i   ; rd_b_sel_w   = rd_1_sel_i   ; rd_c_sel_w   = rd_2_sel_i   ;
                   rd_a_siz_w   = rd_0_siz_i   ; rd_b_siz_w   = rd_1_siz_i   ; rd_c_siz_w   = rd_2_siz_i   ;
                   rd_a_4x4_x_w = rd_0_4x4_x_i ; rd_b_4x4_x_w = rd_1_4x4_x_i ; rd_c_4x4_x_w = rd_2_4x4_x_i ;
                   rd_a_4x4_y_w = rd_0_4x4_y_i ; rd_b_4x4_y_w = rd_1_4x4_y_i ; rd_c_4x4_y_w = rd_2_4x4_y_i ;
                   rd_a_idx_w   = rd_0_idx_i   ; rd_b_idx_w   = rd_1_idx_i   ; rd_c_idx_w   = rd_2_idx_i   ;
                   rd_0_dat_o   = rd_a_dat_w   ; rd_1_dat_o   = rd_b_dat_w   ; rd_2_dat_o   = rd_c_dat_w   ;
    case( rotate_r )
      0 : begin    wr_a_ena_w   = wr_0_ena_i   ; wr_b_ena_w   = wr_1_ena_i   ; wr_c_ena_w   = wr_2_ena_i   ;
                   wr_a_sel_w   = wr_0_sel_i   ; wr_b_sel_w   = wr_1_sel_i   ; wr_c_sel_w   = wr_2_sel_i   ;
                   wr_a_siz_w   = wr_0_siz_i   ; wr_b_siz_w   = wr_1_siz_i   ; wr_c_siz_w   = wr_2_siz_i   ;
                   wr_a_4x4_x_w = wr_0_4x4_x_i ; wr_b_4x4_x_w = wr_1_4x4_x_i ; wr_c_4x4_x_w = wr_2_4x4_x_i ;
                   wr_a_4x4_y_w = wr_0_4x4_y_i ; wr_b_4x4_y_w = wr_1_4x4_y_i ; wr_c_4x4_y_w = wr_2_4x4_y_i ;
                   wr_a_idx_w   = wr_0_idx_i   ; wr_b_idx_w   = wr_1_idx_i   ; wr_c_idx_w   = wr_2_idx_i   ;
                   wr_a_dat_w   = wr_0_dat_i   ; wr_b_dat_w   = wr_1_dat_i   ; wr_c_dat_w   = wr_2_dat_i   ;
                   rd_a_ena_w   = rd_0_ena_i   ; rd_b_ena_w   = rd_1_ena_i   ; rd_c_ena_w   = rd_2_ena_i   ;
                   rd_a_sel_w   = rd_0_sel_i   ; rd_b_sel_w   = rd_1_sel_i   ; rd_c_sel_w   = rd_2_sel_i   ;
                   rd_a_siz_w   = rd_0_siz_i   ; rd_b_siz_w   = rd_1_siz_i   ; rd_c_siz_w   = rd_2_siz_i   ;
                   rd_a_4x4_x_w = rd_0_4x4_x_i ; rd_b_4x4_x_w = rd_1_4x4_x_i ; rd_c_4x4_x_w = rd_2_4x4_x_i ;
                   rd_a_4x4_y_w = rd_0_4x4_y_i ; rd_b_4x4_y_w = rd_1_4x4_y_i ; rd_c_4x4_y_w = rd_2_4x4_y_i ;
                   rd_a_idx_w   = rd_0_idx_i   ; rd_b_idx_w   = rd_1_idx_i   ; rd_c_idx_w   = rd_2_idx_i   ;
                   rd_0_dat_o   = rd_a_dat_w   ; rd_1_dat_o   = rd_b_dat_w   ; rd_2_dat_o   = rd_c_dat_w   ;
      end
      1 : begin    wr_a_ena_w   = wr_1_ena_i   ; wr_b_ena_w   = wr_2_ena_i   ; wr_c_ena_w   = wr_0_ena_i   ;
                   wr_a_sel_w   = wr_1_sel_i   ; wr_b_sel_w   = wr_2_sel_i   ; wr_c_sel_w   = wr_0_sel_i   ;
                   wr_a_siz_w   = wr_1_siz_i   ; wr_b_siz_w   = wr_2_siz_i   ; wr_c_siz_w   = wr_0_siz_i   ;
                   wr_a_4x4_x_w = wr_1_4x4_x_i ; wr_b_4x4_x_w = wr_2_4x4_x_i ; wr_c_4x4_x_w = wr_0_4x4_x_i ;
                   wr_a_4x4_y_w = wr_1_4x4_y_i ; wr_b_4x4_y_w = wr_2_4x4_y_i ; wr_c_4x4_y_w = wr_0_4x4_y_i ;
                   wr_a_idx_w   = wr_1_idx_i   ; wr_b_idx_w   = wr_2_idx_i   ; wr_c_idx_w   = wr_0_idx_i   ;
                   wr_a_dat_w   = wr_1_dat_i   ; wr_b_dat_w   = wr_2_dat_i   ; wr_c_dat_w   = wr_0_dat_i   ;
                   rd_a_ena_w   = rd_1_ena_i   ; rd_b_ena_w   = rd_2_ena_i   ; rd_c_ena_w   = rd_0_ena_i   ;
                   rd_a_sel_w   = rd_1_sel_i   ; rd_b_sel_w   = rd_2_sel_i   ; rd_c_sel_w   = rd_0_sel_i   ;
                   rd_a_siz_w   = rd_1_siz_i   ; rd_b_siz_w   = rd_2_siz_i   ; rd_c_siz_w   = rd_0_siz_i   ;
                   rd_a_4x4_x_w = rd_1_4x4_x_i ; rd_b_4x4_x_w = rd_2_4x4_x_i ; rd_c_4x4_x_w = rd_0_4x4_x_i ;
                   rd_a_4x4_y_w = rd_1_4x4_y_i ; rd_b_4x4_y_w = rd_2_4x4_y_i ; rd_c_4x4_y_w = rd_0_4x4_y_i ;
                   rd_a_idx_w   = rd_1_idx_i   ; rd_b_idx_w   = rd_2_idx_i   ; rd_c_idx_w   = rd_0_idx_i   ;
                   rd_1_dat_o   = rd_a_dat_w   ; rd_2_dat_o   = rd_b_dat_w   ; rd_0_dat_o   = rd_c_dat_w   ;
      end
      2 : begin    wr_a_ena_w   = wr_2_ena_i   ; wr_b_ena_w   = wr_0_ena_i   ; wr_c_ena_w   = wr_1_ena_i   ;
                   wr_a_sel_w   = wr_2_sel_i   ; wr_b_sel_w   = wr_0_sel_i   ; wr_c_sel_w   = wr_1_sel_i   ;
                   wr_a_siz_w   = wr_2_siz_i   ; wr_b_siz_w   = wr_0_siz_i   ; wr_c_siz_w   = wr_1_siz_i   ;
                   wr_a_4x4_x_w = wr_2_4x4_x_i ; wr_b_4x4_x_w = wr_0_4x4_x_i ; wr_c_4x4_x_w = wr_1_4x4_x_i ;
                   wr_a_4x4_y_w = wr_2_4x4_y_i ; wr_b_4x4_y_w = wr_0_4x4_y_i ; wr_c_4x4_y_w = wr_1_4x4_y_i ;
                   wr_a_idx_w   = wr_2_idx_i   ; wr_b_idx_w   = wr_0_idx_i   ; wr_c_idx_w   = wr_1_idx_i   ;
                   wr_a_dat_w   = wr_2_dat_i   ; wr_b_dat_w   = wr_0_dat_i   ; wr_c_dat_w   = wr_1_dat_i   ;
                   rd_a_ena_w   = rd_2_ena_i   ; rd_b_ena_w   = rd_0_ena_i   ; rd_c_ena_w   = rd_1_ena_i   ;
                   rd_a_sel_w   = rd_2_sel_i   ; rd_b_sel_w   = rd_0_sel_i   ; rd_c_sel_w   = rd_1_sel_i   ;
                   rd_a_siz_w   = rd_2_siz_i   ; rd_b_siz_w   = rd_0_siz_i   ; rd_c_siz_w   = rd_1_siz_i   ;
                   rd_a_4x4_x_w = rd_2_4x4_x_i ; rd_b_4x4_x_w = rd_0_4x4_x_i ; rd_c_4x4_x_w = rd_1_4x4_x_i ;
                   rd_a_4x4_y_w = rd_2_4x4_y_i ; rd_b_4x4_y_w = rd_0_4x4_y_i ; rd_c_4x4_y_w = rd_1_4x4_y_i ;
                   rd_a_idx_w   = rd_2_idx_i   ; rd_b_idx_w   = rd_0_idx_i   ; rd_c_idx_w   = rd_1_idx_i   ;
                   rd_2_dat_o   = rd_a_dat_w   ; rd_0_dat_o   = rd_b_dat_w   ; rd_1_dat_o   = rd_c_dat_w   ;
      end
    endcase
  end

  // memory
  rec_buf_cef u_buf_cef_a (
    // global
    .clk             ( clk             ),
    .rstn            ( rstn            ),
    // wr_i
    .wr_ena_i        ( wr_a_ena_w      ),
    .wr_sel_i        ( wr_a_sel_w      ),
    .wr_siz_i        ( wr_a_siz_w      ),
    .wr_4x4_x_i      ( wr_a_4x4_x_w    ),
    .wr_4x4_y_i      ( wr_a_4x4_y_w    ),
    .wr_idx_i        ( wr_a_idx_w      ),
    .wr_dat_i        ( wr_a_dat_w      ),
    // rd_o
    .rd_ena_i        ( rd_a_ena_w      ),
    .rd_sel_i        ( rd_a_sel_w      ),
    .rd_siz_i        ( rd_a_siz_w      ),
    .rd_4x4_x_i      ( rd_a_4x4_x_w    ),
    .rd_4x4_y_i      ( rd_a_4x4_y_w    ),
    .rd_idx_i        ( rd_a_idx_w      ),
    .rd_dat_o        ( rd_a_dat_w      )
    );
  rec_buf_cef u_buf_cef_b (
    // global
    .clk             ( clk             ),
    .rstn            ( rstn            ),
    // wr_i
    .wr_ena_i        ( wr_b_ena_w      ),
    .wr_sel_i        ( wr_b_sel_w      ),
    .wr_siz_i        ( wr_b_siz_w      ),
    .wr_4x4_x_i      ( wr_b_4x4_x_w    ),
    .wr_4x4_y_i      ( wr_b_4x4_y_w    ),
    .wr_idx_i        ( wr_b_idx_w      ),
    .wr_dat_i        ( wr_b_dat_w      ),
    // rd_o
    .rd_ena_i        ( rd_b_ena_w      ),
    .rd_sel_i        ( rd_b_sel_w      ),
    .rd_siz_i        ( rd_b_siz_w      ),
    .rd_4x4_x_i      ( rd_b_4x4_x_w    ),
    .rd_4x4_y_i      ( rd_b_4x4_y_w    ),
    .rd_idx_i        ( rd_b_idx_w      ),
    .rd_dat_o        ( rd_b_dat_w      )
    );
  rec_buf_cef u_buf_cef_c (
    // global
    .clk             ( clk             ),
    .rstn            ( rstn            ),
    // wr_i
    .wr_ena_i        ( wr_c_ena_w      ),
    .wr_sel_i        ( wr_c_sel_w      ),
    .wr_siz_i        ( wr_c_siz_w      ),
    .wr_4x4_x_i      ( wr_c_4x4_x_w    ),
    .wr_4x4_y_i      ( wr_c_4x4_y_w    ),
    .wr_idx_i        ( wr_c_idx_w      ),
    .wr_dat_i        ( wr_c_dat_w      ),
    // rd_o
    .rd_ena_i        ( rd_c_ena_w      ),
    .rd_sel_i        ( rd_c_sel_w      ),
    .rd_siz_i        ( rd_c_siz_w      ),
    .rd_4x4_x_i      ( rd_c_4x4_x_w    ),
    .rd_4x4_y_i      ( rd_c_4x4_y_w    ),
    .rd_idx_i        ( rd_c_idx_w      ),
    .rd_dat_o        ( rd_c_dat_w      )
    );

endmodule
