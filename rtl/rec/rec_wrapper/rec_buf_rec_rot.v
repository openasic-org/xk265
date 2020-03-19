//--------------------------------------------------------------------
//
//  Filename    : rec_buf_cef_rot.v
//  Author      : Huang Leilei
//  Created     : 2018-05-22
//  Description : mem buf for rec (2 buf rotate)
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module rec_buf_rec_rot (
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
  // rd_1
  rd_1_ena_i      ,
  rd_1_sel_i      ,
  rd_1_siz_i      ,
  rd_1_4x4_x_i    ,
  rd_1_4x4_y_i    ,
  rd_1_idx_i      ,
  rd_1_dat_o      ,
  // wr_1
  wr_1_ena_i      ,
  wr_1_sel_i      ,
  wr_1_siz_i      ,
  wr_1_4x4_x_i    ,
  wr_1_4x4_y_i    ,
  wr_1_idx_i      ,
  wr_1_dat_i
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
  input  [`PIXEL_WIDTH*32-1 :0]    wr_0_dat_i      ;
  // wr_1_i
  input                            wr_1_ena_i      ;
  input  [2              -1 :0]    wr_1_sel_i      ;
  input  [2              -1 :0]    wr_1_siz_i      ;
  input  [4              -1 :0]    wr_1_4x4_x_i    ;
  input  [4              -1 :0]    wr_1_4x4_y_i    ;
  input  [5              -1 :0]    wr_1_idx_i      ;
  input  [`PIXEL_WIDTH*32-1 :0]    wr_1_dat_i      ;
  // rd_1_i
  input                            rd_1_ena_i      ;
  input  [2              -1 :0]    rd_1_sel_i      ;
  input  [2              -1 :0]    rd_1_siz_i      ;
  input  [4              -1 :0]    rd_1_4x4_x_i    ;
  input  [4              -1 :0]    rd_1_4x4_y_i    ;
  input  [5              -1 :0]    rd_1_idx_i      ;
  output [`PIXEL_WIDTH*32-1 :0]    rd_1_dat_o      ;


//*** REG/WIRE *****************************************************************

  // miss_rd
  wire                             rd_0_ena_i      ;
  wire   [2              -1 :0]    rd_0_sel_i      ;
  wire   [2              -1 :0]    rd_0_siz_i      ;
  wire   [4              -1 :0]    rd_0_4x4_x_i    ;
  wire   [4              -1 :0]    rd_0_4x4_y_i    ;
  wire   [5              -1 :0]    rd_0_idx_i      ;
  reg    [`PIXEL_WIDTH*32-1 :0]    rd_0_dat_o      ;
  reg    [`PIXEL_WIDTH*32-1 :0]    rd_1_dat_o      ;

  // rotate_r
  reg    [1              -1 :0]    rotate_r        ;

  // rotate_wr
  reg                              wr_a_ena_w      , wr_b_ena_w      ;
  reg    [2              -1 :0]    wr_a_sel_w      , wr_b_sel_w      ;
  reg    [2              -1 :0]    wr_a_siz_w      , wr_b_siz_w      ;
  reg    [4              -1 :0]    wr_a_4x4_x_w    , wr_b_4x4_x_w    ;
  reg    [4              -1 :0]    wr_a_4x4_y_w    , wr_b_4x4_y_w    ;
  reg    [5              -1 :0]    wr_a_idx_w      , wr_b_idx_w      ;
  reg    [`PIXEL_WIDTH*32-1 :0]    wr_a_dat_w      , wr_b_dat_w      ;
  // rotate_rd
  reg                              rd_a_ena_w      , rd_b_ena_w      ;
  reg    [2              -1 :0]    rd_a_sel_w      , rd_b_sel_w      ;
  reg    [2              -1 :0]    rd_a_siz_w      , rd_b_siz_w      ;
  reg    [4              -1 :0]    rd_a_4x4_x_w    , rd_b_4x4_x_w    ;
  reg    [4              -1 :0]    rd_a_4x4_y_w    , rd_b_4x4_y_w    ;
  reg    [5              -1 :0]    rd_a_idx_w      , rd_b_idx_w      ;
  wire   [`PIXEL_WIDTH*32-1 :0]    rd_a_dat_w      , rd_b_dat_w      ;


//*** MAIN BODY ****************************************************************

  // miss i/o
  assign rd_0_ena_i   = 0 ;
  assign rd_0_sel_i   = 0 ;
  assign rd_0_siz_i   = 0 ;
  assign rd_0_4x4_x_i = 0 ;
  assign rd_0_4x4_y_i = 0 ;
  assign rd_0_idx_i   = 0 ;

  // rotate_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rotate_r <= 0 ;
    end
    else begin
      if( rotate_i ) begin
        if( rotate_r==2-1 ) begin
          rotate_r <= 0 ;
        end
        else begin
          rotate_r <= rotate_r + 1 ;
        end
      end
    end
  end

  // rotate
  always @(*) begin
                   wr_a_ena_w   = wr_0_ena_i   ; wr_b_ena_w   = wr_1_ena_i   ;
                   wr_a_sel_w   = wr_0_sel_i   ; wr_b_sel_w   = wr_1_sel_i   ;
                   wr_a_siz_w   = wr_0_siz_i   ; wr_b_siz_w   = wr_1_siz_i   ;
                   wr_a_4x4_x_w = wr_0_4x4_x_i ; wr_b_4x4_x_w = wr_1_4x4_x_i ;
                   wr_a_4x4_y_w = wr_0_4x4_y_i ; wr_b_4x4_y_w = wr_1_4x4_y_i ;
                   wr_a_idx_w   = wr_0_idx_i   ; wr_b_idx_w   = wr_1_idx_i   ;
                   wr_a_dat_w   = wr_0_dat_i   ; wr_b_dat_w   = wr_1_dat_i   ;
                   rd_a_ena_w   = rd_0_ena_i   ; rd_b_ena_w   = rd_1_ena_i   ;
                   rd_a_sel_w   = rd_0_sel_i   ; rd_b_sel_w   = rd_1_sel_i   ;
                   rd_a_siz_w   = rd_0_siz_i   ; rd_b_siz_w   = rd_1_siz_i   ;
                   rd_a_4x4_x_w = rd_0_4x4_x_i ; rd_b_4x4_x_w = rd_1_4x4_x_i ;
                   rd_a_4x4_y_w = rd_0_4x4_y_i ; rd_b_4x4_y_w = rd_1_4x4_y_i ;
                   rd_a_idx_w   = rd_0_idx_i   ; rd_b_idx_w   = rd_1_idx_i   ;
                   rd_0_dat_o   = rd_a_dat_w   ; rd_1_dat_o   = rd_b_dat_w   ;
    case( rotate_r )
      0 : begin    wr_a_ena_w   = wr_0_ena_i   ; wr_b_ena_w   = wr_1_ena_i   ;
                   wr_a_sel_w   = wr_0_sel_i   ; wr_b_sel_w   = wr_1_sel_i   ;
                   wr_a_siz_w   = wr_0_siz_i   ; wr_b_siz_w   = wr_1_siz_i   ;
                   wr_a_4x4_x_w = wr_0_4x4_x_i ; wr_b_4x4_x_w = wr_1_4x4_x_i ;
                   wr_a_4x4_y_w = wr_0_4x4_y_i ; wr_b_4x4_y_w = wr_1_4x4_y_i ;
                   wr_a_idx_w   = wr_0_idx_i   ; wr_b_idx_w   = wr_1_idx_i   ;
                   wr_a_dat_w   = wr_0_dat_i   ; wr_b_dat_w   = wr_1_dat_i   ;
                   rd_a_ena_w   = rd_0_ena_i   ; rd_b_ena_w   = rd_1_ena_i   ;
                   rd_a_sel_w   = rd_0_sel_i   ; rd_b_sel_w   = rd_1_sel_i   ;
                   rd_a_siz_w   = rd_0_siz_i   ; rd_b_siz_w   = rd_1_siz_i   ;
                   rd_a_4x4_x_w = rd_0_4x4_x_i ; rd_b_4x4_x_w = rd_1_4x4_x_i ;
                   rd_a_4x4_y_w = rd_0_4x4_y_i ; rd_b_4x4_y_w = rd_1_4x4_y_i ;
                   rd_a_idx_w   = rd_0_idx_i   ; rd_b_idx_w   = rd_1_idx_i   ;
                   rd_0_dat_o   = rd_a_dat_w   ; rd_1_dat_o   = rd_b_dat_w   ;
      end
      1 : begin    wr_a_ena_w   = wr_1_ena_i   ; wr_b_ena_w   = wr_0_ena_i   ;
                   wr_a_sel_w   = wr_1_sel_i   ; wr_b_sel_w   = wr_0_sel_i   ;
                   wr_a_siz_w   = wr_1_siz_i   ; wr_b_siz_w   = wr_0_siz_i   ;
                   wr_a_4x4_x_w = wr_1_4x4_x_i ; wr_b_4x4_x_w = wr_0_4x4_x_i ;
                   wr_a_4x4_y_w = wr_1_4x4_y_i ; wr_b_4x4_y_w = wr_0_4x4_y_i ;
                   wr_a_idx_w   = wr_1_idx_i   ; wr_b_idx_w   = wr_0_idx_i   ;
                   wr_a_dat_w   = wr_1_dat_i   ; wr_b_dat_w   = wr_0_dat_i   ;
                   rd_a_ena_w   = rd_1_ena_i   ; rd_b_ena_w   = rd_0_ena_i   ;
                   rd_a_sel_w   = rd_1_sel_i   ; rd_b_sel_w   = rd_0_sel_i   ;
                   rd_a_siz_w   = rd_1_siz_i   ; rd_b_siz_w   = rd_0_siz_i   ;
                   rd_a_4x4_x_w = rd_1_4x4_x_i ; rd_b_4x4_x_w = rd_0_4x4_x_i ;
                   rd_a_4x4_y_w = rd_1_4x4_y_i ; rd_b_4x4_y_w = rd_0_4x4_y_i ;
                   rd_a_idx_w   = rd_1_idx_i   ; rd_b_idx_w   = rd_0_idx_i   ;
                   rd_0_dat_o   = rd_b_dat_w   ; rd_1_dat_o   = rd_a_dat_w   ;
      end
    endcase
  end

  // memory
  rec_buf_rec u_buf_rec_a (
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
  rec_buf_rec u_buf_rec_b (
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

endmodule
