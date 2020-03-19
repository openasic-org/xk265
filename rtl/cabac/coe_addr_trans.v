//--------------------------------------------------
//
// File Name  : coe_addr_trans.v
// Author     : TANG
// Date     : 2018-05-20
// Description  : transpose the coe address between cabac and rec
//
//-----------------------------------------------------

`include "enc_defines.v"

module coe_addr_trans(
           clk      ,
           rst_n    ,
           ec_coe_rd_ena_i  ,
           ec_coe_rd_addr_i   , // 4x4 addr in raster scan
           ec_coe_rd_sel_i  , // YUV
           ec_coe_rd_dat_o  ,

           ec_coe_rd_ena_o    ,
           ec_coe_rd_sel_o    ,
           ec_coe_rd_siz_o    ,
           ec_coe_rd_4x4_x_o  ,
           ec_coe_rd_4x4_y_o  ,
           ec_coe_rd_idx_o    ,
           ec_coe_rd_dat_i

       );

//---- input / output declaration -------------------------------
input clk;
input rst_n;
input                 ec_coe_rd_ena_i   ;
input   [9         -1 :0]   ec_coe_rd_addr_i  ;
input   [2         -1 :0]   ec_coe_rd_sel_i   ;
input   [32*`COEFF_WIDTH -1 :0]   ec_coe_rd_dat_i   ;

output  [16*`COEFF_WIDTH -1 :0]   ec_coe_rd_dat_o   ;
output                ec_coe_rd_ena_o   ;
output  [2         -1 :0]   ec_coe_rd_sel_o   ;
output  [2         -1 :0]   ec_coe_rd_siz_o   ;
output  [4         -1 :0]   ec_coe_rd_4x4_y_o   ;
output  [4         -1 :0]   ec_coe_rd_4x4_x_o   ;
output  [5         -1 :0]   ec_coe_rd_idx_o   ;

//---- wire / reg declaration ----------------------------------
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_00_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_01_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_02_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_03_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_04_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_05_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_06_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_07_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_08_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_09_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_10_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_11_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_12_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_13_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_14_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_15_w    ;

wire  [`COEFF_WIDTH    -1 :0]   coe_dat_16_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_17_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_18_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_19_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_20_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_21_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_22_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_23_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_24_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_25_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_26_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_27_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_28_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_29_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_30_w    ;
wire  [`COEFF_WIDTH    -1 :0]   coe_dat_31_w    ;

reg   [2         -1 :0]   ec_coe_rd_sel_o   ;
reg [4         -1 :0]   ec_coe_rd_4x4_y_r ;//delay one cycle of ec_coe_rd_4x4_y_o
wire    [4         -1 :0]   ec_coe_rd_4x4_y_o   ;
wire    [4         -1 :0]   ec_coe_rd_4x4_x_o   ;
wire    [16*`COEFF_WIDTH -1 :0]   ec_coe_rd_dat_hi  ;
wire    [16*`COEFF_WIDTH -1 :0]   ec_coe_rd_dat_lo  ;

//---- main body -----------------------------------------------

assign ec_coe_rd_4x4_x_o = {ec_coe_rd_addr_i[6],ec_coe_rd_addr_i[4],ec_coe_rd_addr_i[2],ec_coe_rd_addr_i[0]} ;
assign ec_coe_rd_4x4_y_o = {ec_coe_rd_addr_i[7],ec_coe_rd_addr_i[5],ec_coe_rd_addr_i[3],ec_coe_rd_addr_i[1]} ;

always @ (*)
begin
    ec_coe_rd_sel_o = `TYPE_Y ;
    case ( ec_coe_rd_sel_i )
        2'd2 :
            ec_coe_rd_sel_o = `TYPE_Y ;
        2'd1 :
            ec_coe_rd_sel_o = `TYPE_U ;
        2'd0 :
            ec_coe_rd_sel_o = `TYPE_V ;
        default :
            ec_coe_rd_sel_o = `TYPE_Y ;
    endcase
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        ec_coe_rd_4x4_y_r <= 4'b0;
    else
        ec_coe_rd_4x4_y_r <= ec_coe_rd_4x4_y_o;
end

assign  {coe_dat_00_w ,coe_dat_01_w ,coe_dat_02_w ,coe_dat_03_w , coe_dat_16_w , coe_dat_17_w , coe_dat_18_w , coe_dat_19_w
         ,coe_dat_04_w ,coe_dat_05_w ,coe_dat_06_w ,coe_dat_07_w , coe_dat_20_w , coe_dat_21_w , coe_dat_22_w , coe_dat_23_w
         ,coe_dat_08_w ,coe_dat_09_w ,coe_dat_10_w ,coe_dat_11_w , coe_dat_24_w , coe_dat_25_w , coe_dat_26_w , coe_dat_27_w
         ,coe_dat_12_w ,coe_dat_13_w ,coe_dat_14_w ,coe_dat_15_w , coe_dat_28_w , coe_dat_29_w , coe_dat_30_w , coe_dat_31_w } = ec_coe_rd_dat_i ;





assign ec_coe_rd_dat_hi = { coe_dat_00_w, coe_dat_04_w, coe_dat_01_w, coe_dat_05_w
                            ,coe_dat_08_w, coe_dat_12_w, coe_dat_09_w, coe_dat_13_w
                            ,coe_dat_02_w, coe_dat_06_w, coe_dat_03_w, coe_dat_07_w
                            ,coe_dat_10_w, coe_dat_14_w, coe_dat_11_w, coe_dat_15_w
                          } ;

assign ec_coe_rd_dat_lo = { coe_dat_16_w, coe_dat_20_w, coe_dat_17_w, coe_dat_21_w
                            ,coe_dat_24_w, coe_dat_28_w, coe_dat_25_w, coe_dat_29_w
                            ,coe_dat_18_w, coe_dat_22_w, coe_dat_19_w, coe_dat_23_w
                            ,coe_dat_26_w, coe_dat_30_w, coe_dat_27_w, coe_dat_31_w
                          } ;

assign ec_coe_rd_dat_o = ec_coe_rd_4x4_y_r[0] ? ec_coe_rd_dat_lo : ec_coe_rd_dat_hi ;

assign ec_coe_rd_siz_o = `SIZE_04 ;
assign ec_coe_rd_idx_o = 0 ;
assign ec_coe_rd_ena_o = !ec_coe_rd_ena_i ;

endmodule
