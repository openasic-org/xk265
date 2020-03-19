//--------------------------------------------------------------------
//
//  Filename    : rec_buf_mvd_rot.v
//  Author      : Huang Leilei
//  Created     : 2018-05-22
//  Description : mem buf for mvd (3 buf rotate)
//
//--------------------------------------------------------------------

`include "enc_defines.v"

module rec_buf_mvd_rot (
  // global
  clk           ,
  rstn          ,
  // ctrl_i
  rotate_i      ,
  // wr_0
  wr_0_ena_i    ,
  wr_0_adr_i    ,
  wr_0_dat_i    ,
  // rd_2
  rd_2_ena_i    ,
  rd_2_adr_i    ,
  rd_2_dat_o
  );


//*** PARAMETER ****************************************************************


//*** INPUT/OUTPUT *************************************************************

  // global
  input                         clk             ;
  input                         rstn            ;
  // ctrl_i
  input                         rotate_i        ;
  // wr_0_i
  input                         wr_0_ena_i      ;
  input  [6           -1 :0]    wr_0_adr_i      ;
  input  [2*`MVD_WIDTH   :0]    wr_0_dat_i      ;
  // rd_2_i
  input                         rd_2_ena_i      ;
  input  [6           -1 :0]    rd_2_adr_i      ;
  output [2*`MVD_WIDTH   :0]    rd_2_dat_o      ;


//*** REG/WIRE *****************************************************************

  // miss_wr
  wire                          wr_1_ena_i    , wr_2_ena_i    ;
  wire   [6           -1 :0]    wr_1_adr_i    , wr_2_adr_i    ;
  wire   [2*`MVD_WIDTH   :0]    wr_1_dat_i    , wr_2_dat_i    ;
  // miss_rd
  wire                          rd_0_ena_i    , rd_1_ena_i    ;
  wire   [6           -1 :0]    rd_0_adr_i    , rd_1_adr_i    ;
  reg    [2*`MVD_WIDTH   :0]    rd_0_dat_o    , rd_1_dat_o    , rd_2_dat_o    ;

  // rotate_r
  reg    [2           -1 :0]    rotate_r      ;

  // rotate_wr
  reg                           wr_a_ena_w    , wr_b_ena_w    , wr_c_ena_w    ;
  reg    [6           -1 :0]    wr_a_adr_w    , wr_b_adr_w    , wr_c_adr_w    ;
  reg    [2*`MVD_WIDTH   :0]    wr_a_dat_w    , wr_b_dat_w    , wr_c_dat_w    ;
  // rotate_rd
  reg                           rd_a_ena_w    , rd_b_ena_w    , rd_c_ena_w    ;
  reg    [6           -1 :0]    rd_a_adr_w    , rd_b_adr_w    , rd_c_adr_w    ;
  wire   [2*`MVD_WIDTH   :0]    rd_a_dat_w    , rd_b_dat_w    , rd_c_dat_w    ;

  // mem addr

  wire   [6           -1 :0]    a_adr_w       , b_adr_w       , c_adr_w       ;


//*** MAIN BODY ****************************************************************

  // miss i/o
  assign wr_1_ena_i = 0 ;    assign wr_2_ena_i = 0 ;
  assign wr_1_adr_i = 0 ;    assign wr_2_adr_i = 0 ;
  assign wr_1_dat_i = 0 ;    assign wr_2_dat_i = 0 ;

  assign rd_0_ena_i = 0 ;    assign rd_1_ena_i = 0 ;
  assign rd_0_adr_i = 0 ;    assign rd_1_adr_i = 0 ;

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

  // rotate
  always @(*) begin
                   wr_a_ena_w = wr_0_ena_i ; wr_b_ena_w = wr_1_ena_i ; wr_c_ena_w = wr_2_ena_i ;
                   wr_a_adr_w = wr_0_adr_i ; wr_b_adr_w = wr_1_adr_i ; wr_c_adr_w = wr_2_adr_i ;
                   wr_a_dat_w = wr_0_dat_i ; wr_b_dat_w = wr_1_dat_i ; wr_c_dat_w = wr_2_dat_i ;
                   rd_a_ena_w = rd_0_ena_i ; rd_b_ena_w = rd_1_ena_i ; rd_c_ena_w = rd_2_ena_i ;
                   rd_a_adr_w = rd_0_adr_i ; rd_b_adr_w = rd_1_adr_i ; rd_c_adr_w = rd_2_adr_i ;
                   rd_0_dat_o = rd_a_dat_w ; rd_1_dat_o = rd_b_dat_w ; rd_2_dat_o = rd_c_dat_w ;
    case( rotate_r )
      0 : begin    wr_a_ena_w = wr_0_ena_i ; wr_b_ena_w = wr_1_ena_i ; wr_c_ena_w = wr_2_ena_i ;
                   wr_a_adr_w = wr_0_adr_i ; wr_b_adr_w = wr_1_adr_i ; wr_c_adr_w = wr_2_adr_i ;
                   wr_a_dat_w = wr_0_dat_i ; wr_b_dat_w = wr_1_dat_i ; wr_c_dat_w = wr_2_dat_i ;
                   rd_a_ena_w = rd_0_ena_i ; rd_b_ena_w = rd_1_ena_i ; rd_c_ena_w = rd_2_ena_i ;
                   rd_a_adr_w = rd_0_adr_i ; rd_b_adr_w = rd_1_adr_i ; rd_c_adr_w = rd_2_adr_i ;
                   rd_0_dat_o = rd_a_dat_w ; rd_1_dat_o = rd_b_dat_w ; rd_2_dat_o = rd_c_dat_w ;
      end
      1 : begin    wr_a_ena_w = wr_1_ena_i ; wr_b_ena_w = wr_2_ena_i ; wr_c_ena_w = wr_0_ena_i ;
                   wr_a_adr_w = wr_1_adr_i ; wr_b_adr_w = wr_2_adr_i ; wr_c_adr_w = wr_0_adr_i ;
                   wr_a_dat_w = wr_1_dat_i ; wr_b_dat_w = wr_2_dat_i ; wr_c_dat_w = wr_0_dat_i ;
                   rd_a_ena_w = rd_1_ena_i ; rd_b_ena_w = rd_2_ena_i ; rd_c_ena_w = rd_0_ena_i ;
                   rd_a_adr_w = rd_1_adr_i ; rd_b_adr_w = rd_2_adr_i ; rd_c_adr_w = rd_0_adr_i ;
                   rd_1_dat_o = rd_a_dat_w ; rd_2_dat_o = rd_b_dat_w ; rd_0_dat_o = rd_c_dat_w ;
      end
      2 : begin    wr_a_ena_w = wr_2_ena_i ; wr_b_ena_w = wr_0_ena_i ; wr_c_ena_w = wr_1_ena_i ;
                   wr_a_adr_w = wr_2_adr_i ; wr_b_adr_w = wr_0_adr_i ; wr_c_adr_w = wr_1_adr_i ;
                   wr_a_dat_w = wr_2_dat_i ; wr_b_dat_w = wr_0_dat_i ; wr_c_dat_w = wr_1_dat_i ;
                   rd_a_ena_w = rd_2_ena_i ; rd_b_ena_w = rd_0_ena_i ; rd_c_ena_w = rd_1_ena_i ;
                   rd_a_adr_w = rd_2_adr_i ; rd_b_adr_w = rd_0_adr_i ; rd_c_adr_w = rd_1_adr_i ;
                   rd_2_dat_o = rd_a_dat_w ; rd_0_dat_o = rd_b_dat_w ; rd_1_dat_o = rd_c_dat_w ;
      end
    endcase
  end

  // memory
  ram_sp_be_64x23 ram_sp_be_64x23_a(
    .clk          ( clk           ),
    .adr_i        (    a_adr_w    ),
    .wr_ena_i     ( wr_a_ena_w    ),
    .wr_dat_i     ( wr_a_dat_w    ),
    .rd_ena_i     ( rd_a_ena_w    ),
    .rd_dat_o     ( rd_a_dat_w    )
    );
  ram_sp_be_64x23 ram_sp_be_64x23_b(
    .clk          ( clk           ),
    .adr_i        (    b_adr_w    ),
    .wr_ena_i     ( wr_b_ena_w    ),
    .wr_dat_i     ( wr_b_dat_w    ),
    .rd_ena_i     ( rd_b_ena_w    ),
    .rd_dat_o     ( rd_b_dat_w    )
    );
  ram_sp_be_64x23 ram_sp_be_64x23_c(
    .clk          ( clk           ),
    .adr_i        (    c_adr_w    ),
    .wr_ena_i     ( wr_c_ena_w    ),
    .wr_dat_i     ( wr_c_dat_w    ),
    .rd_ena_i     ( rd_c_ena_w    ),
    .rd_dat_o     ( rd_c_dat_w    )
    );
    
  assign a_adr_w = rd_a_ena_w ? rd_a_adr_w : wr_a_adr_w ;
  assign b_adr_w = rd_b_ena_w ? rd_b_adr_w : wr_b_adr_w ;
  assign c_adr_w = rd_c_ena_w ? rd_c_adr_w : wr_c_adr_w ;

endmodule
