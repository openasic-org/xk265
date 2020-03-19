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
// Filename       : cabac_bina.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : syntax element binarization
// DATA & EDITION:  2017/12/26    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------


module cabac_bina(
           clk,
           en,
           rst_n,

           gp_five_minus_max_num_merge_cand,
           rdy,
           wack_o,

           syntaxElement_0,
           syntaxElement_1,
           syntaxElement_2,
           syntaxElement_3,

           in_cMax_0,
           in_cMax_1,
           in_cMax_2,
           in_cMax_3,

           ctxIdx_0,
           ctxIdx_1,
           ctxIdx_2,
           ctxIdx_3,

           free_space,
           flag_end_slice,
           init_done,

           valid,
           ob_0,
           ob_1,
           ob_2,
           ob_3,
           ob_4,
           ob_5,
           ob_6,
           ob_7,
           ob_8,
           ob_9,
           ob_10,
           ob_11,
           ob_12,
           ob_13,
           ob_14,
           ob_15,
           ob_16,
           ob_17,

           out_number
       );

parameter        BINA_FL = 3'd0, //binarization type
                 BINA_TU = 3'd1,
                 BINA_EG = 3'd2,
                 //          BINA_UMS = 3'd3,  // binarization is TU. for context model = {Ctx, Ctx+1, Ctx+1}
                 BINA_CREG = 3'd4,
                 BINA_SP = 3'd5;

parameter        CONT_PART_SIZE = 8,
                 CONT_INTRA_CPRED = 15, // intra_chroma_pred_mode
                 CONT_INTER_PREDIDC = 17, // inter_pred_idc
                 CONT_FINAL = 186;

input        clk;
input        en;    //0 to reset
input            rst_n;
input            rdy;

input  [2:0]     gp_five_minus_max_num_merge_cand;

input  [5:0]     free_space;
input            init_done;

input  [15:0]    syntaxElement_0, syntaxElement_1;
input  [1:0]     syntaxElement_2, syntaxElement_3;

input  [3:0]     in_cMax_0, in_cMax_1, in_cMax_2, in_cMax_3;
input  [8:0]     ctxIdx_0, ctxIdx_1, ctxIdx_2, ctxIdx_3;


output           flag_end_slice;
output           valid;
output           wack_o;

output [9:0]     ob_0, ob_1, ob_2, ob_3, ob_4, ob_5, ob_6, ob_7, ob_8,
       ob_9, ob_10, ob_11, ob_12, ob_13, ob_14, ob_15, ob_16, ob_17;
output [4:0]     out_number;
reg    [4:0]     out_number;

reg    [9:0]     ob_0, ob_1, ob_2, ob_3, ob_4, ob_5, ob_6, ob_7, ob_8,
       ob_9, ob_10, ob_11, ob_12, ob_13, ob_14, ob_15, ob_16, ob_17;
reg              valid;


wire   [15:0]    value_0, value_1;
wire   [1:0]     value_2, value_3;
wire   [2:0]     type_0, type_1, type_2, type_3; //binarization type
wire   [3:0]     cMax_0, cMax_1, cMax_2, cMax_3;
wire   [8:0]     context_0, context_1, context_2, context_3; //context index


reg    out_half;
reg    [15:0]    value_0_, value_1_;
reg    [1:0]     value_2_, value_3_;
reg    [2:0]     type_0_, type_1_, type_2_, type_3_; //binarization type
reg    [3:0]     cMax_0_, cMax_1_, cMax_2_, cMax_3_;
reg    [8:0]     context_0_, context_1_, context_2_, context_3_; //context index


reg              wack_store; // if the previous output num is larger than 18; only encode the first SE.
wire             wack;


reg    [17:0]    BS_inl_a, BS_inl_b, BS_inr_a;
reg    [4:0]     BS_left_a, BS_left_b, BS_right_a, BS_left_m;
wire   [17:0]  BS_outl_a, BS_outl_b, BS_outr_a, BS_outl_m;
reg    [15:0]    FC_in_0;
wire   [4:0]     FC_pos_0;


reg    [17:0]    CR_out_0, CR_out_1;
reg    [4:0]     CR_num_0, CR_num_1;

reg    [17:0]    EG_out_0, EG_out_1;
reg    [4:0]     EG_num_0, EG_num_1;

reg    [4:0]     SP_num[0:3];
reg    [17:0]    SP_out[0:3];

//{
reg    [5:0]     shift_rParam_0, shift_rParam_1;
reg    [15:0]    code_rParam_0, code_rParam_1;
reg    [3:0]     code_remain_0, code_remain_1;
reg    [15:0]    code_0, code_1;
wire   [2:0]     rParam_0, rParam_1;


reg    [161:0]   out_ctx[0 : 3];
wire   [8:0]     ctx[0 : 3];
wire   [3:0]     cMax[0 : 3];
reg    [1:0]     ctxShift; // only used for last_sig_coeff_prefix
reg    [2:0]     log2TrafoSize;
wire    [15:0]    value[0:3];
wire   [8:0]     context_bypass;



wire   [15:0]    in_value[0:3];
wire   [2:0]     bina_type[0:3]; //binarization type
wire   [3:0]     in_cMax[0:3], bina_cMax[0:3];
wire   [8:0]     in_context[0:3]; //context index

assign in_value[0] = syntaxElement_0;
assign in_cMax[0] = in_cMax_0;
assign in_context[0] = ctxIdx_0;

assign in_value[1]= syntaxElement_1;
assign in_cMax[1]= in_cMax_1;
assign in_context[1] = ctxIdx_1;

assign in_value[2]= syntaxElement_2;
assign in_cMax[2]= in_cMax_2;
assign in_context[2] = ctxIdx_2;


assign in_value[3]= syntaxElement_3;
assign in_cMax[3] = in_cMax_3;
assign in_context[3] = ctxIdx_3;

cabac_bina_lut lut_u0(
                   .rdy(rdy),
                   .in_ctxIdx(in_context[0]),
                   .in_cMax(in_cMax[0]),

                   .gp_five_minus_max_num_merge_cand (gp_five_minus_max_num_merge_cand),
                   .out_binaType(bina_type[0]),
                   .out_cMax(bina_cMax[0])
               );
cabac_bina_lut lut_u1(
                   .rdy(rdy),
                   .in_ctxIdx(in_context[1]),
                   .in_cMax(in_cMax[1]),

                   .gp_five_minus_max_num_merge_cand (gp_five_minus_max_num_merge_cand),
                   .out_binaType(bina_type[1]),
                   .out_cMax(bina_cMax[1])
               );
cabac_bina_lut lut_u2(
                   .rdy(rdy),
                   .in_ctxIdx(in_context[2]),
                   .in_cMax(in_cMax[2]),

                   .gp_five_minus_max_num_merge_cand (gp_five_minus_max_num_merge_cand),
                   .out_binaType(bina_type[2]),
                   .out_cMax(bina_cMax[2])
               );
cabac_bina_lut lut_u3(
                   .rdy(rdy),
                   .in_ctxIdx(in_context[3]),
                   .in_cMax(in_cMax[3]),

                   .gp_five_minus_max_num_merge_cand (gp_five_minus_max_num_merge_cand),
                   .out_binaType(bina_type[3]),
                   .out_cMax(bina_cMax[3])
               );

assign value_0 = wack_store ? value_0_ : in_value[0];
assign type_0 = wack_store ? type_0_ : bina_type[0];
assign cMax_0 = wack_store ? cMax_0_ : bina_cMax[0];
assign context_0 = wack_store ? context_0_ : in_context[0];

assign value_1 = wack_store ? value_1_ : in_value[1];
assign type_1 = wack_store ? type_1_ :  bina_type[1];
assign cMax_1 = wack_store ? cMax_1_ : bina_cMax[1];
assign context_1 = wack_store ? context_1_ :  in_context[1];

assign value_2 = wack_store ? value_2_ :  in_value[2];
assign type_2 = wack_store ? type_2_ : bina_type[2];
assign cMax_2 = wack_store ? cMax_2_ : bina_cMax[2];
assign context_2 =wack_store ? context_2_ :  in_context[2];


assign value_3 = wack_store ? value_3_ :  in_value[3];
assign type_3 = wack_store ? type_3_ : bina_type[3];
assign cMax_3 = wack_store ? cMax_3_ :bina_cMax[3];
assign context_3 = wack_store ?  context_3_ : in_context[3];


wire  signed   [161:0] minus_one;
assign minus_one = -1;

wire     [17:0]  half_remain;
assign half_remain = BS_outl_a | code_remain_0;

always @ (posedge clk or negedge rst_n)
    if(!rst_n)
    begin
        value_0_ <= 0;
        type_0_ <= 0;
        cMax_0_ <= 0;
        context_0_ <= 0;
        value_1_ <= 0;
        type_1_ <= 0;
        cMax_1_ <= 0;
        context_1_ <= 0;
        value_2_ <= 0;
        type_2_ <= 0;
        cMax_2_ <= 0;
        context_2_ <= 0;
        value_3_ <= 0;
        type_3_ <= 0;
        cMax_3_ <= 0;
        context_3_ <= 0;
    end
    else if(!en)
    begin
        value_0_ <= 0;
        type_0_ <= 0;
        cMax_0_ <= 0;
        context_0_ <= 0;
        value_1_ <= 0;
        type_1_ <= 0;
        cMax_1_ <= 0;
        context_1_ <= 0;
        value_2_ <= 0;
        type_2_ <= 0;
        cMax_2_ <= 0;
        context_2_ <= 0;
        value_3_ <= 0;
        type_3_ <= 0;
        cMax_3_ <= 0;
        context_3_ <= 0;
    end
    else
    begin
        value_0_ <= out_half ?  half_remain[15:0] : value_1;
        type_0_ <= out_half ? BINA_FL : type_1;
        cMax_0_ <= out_half ? FC_pos_0 + rParam_0 : cMax_1;
        context_0_ <= out_half ? context_0 : context_1;
        value_1_ <= out_half ? value_1 : value_2;
        type_1_ <= out_half ? type_1 : type_2;
        cMax_1_ <= out_half ? cMax_1 : cMax_2;
        context_1_ <= out_half ? context_1 : context_2;
        value_2_ <= out_half ? value_2 : value_3;
        type_2_ <= out_half ? type_2 : type_3;
        cMax_2_ <= out_half ? cMax_2 : cMax_3;
        context_2_ <= out_half ? context_2 : context_3;
        value_3_ <= value_3;
        type_3_ <= out_half ? type_3 : BINA_FL;
        cMax_3_ <=  out_half ? cMax_3 : 0;
        context_3_ <= context_3;
    end



// -- TU --
// the max cMax is 9;
reg    [15:0]    TU_in_0, TU_in_1;
wire   [3:0]     TU_num_0, TU_num_1; // largest is 9.
wire   [3:0]     TU_num_2, TU_num_3;
wire   [17:0]    TU_out_0, TU_out_1;
wire   [17:0]    TU_out_2, TU_out_3;
reg    [3:0]     TU_cMax_0, TU_cMax_1;
//{

assign TU_out_0[17] = TU_in_0 > 0 ? 1'b1 :  1'b0;
assign TU_out_0[16] = TU_in_0 > 1 ?  1'b1 :  1'b0;
assign TU_out_0[15] = TU_in_0 > 2 ?  1'b1 :  1'b0;
assign TU_out_0[14] = TU_in_0 > 3 ?  1'b1 :  1'b0;
assign TU_out_0[13] = TU_in_0 > 4 ?  1'b1 :  1'b0;
assign TU_out_0[12] = TU_in_0 > 5 ?  1'b1 :  1'b0;
assign TU_out_0[11] = TU_in_0 > 6 ?  1'b1 :  1'b0;
assign TU_out_0[10] = TU_in_0 > 7 ?  1'b1 :  1'b0;
assign TU_out_0[9] = TU_in_0 > 8 ?  1'b1 :  1'b0;
assign TU_out_0[8:0] = 0;
assign TU_num_0 = TU_in_0 < TU_cMax_0 ? TU_in_0 + 1 : TU_cMax_0;

assign TU_out_1[17] = TU_in_1 > 0 ?  1'b1 :  1'b0;
assign TU_out_1[16] = TU_in_1 > 1 ?  1'b1 :  1'b0;
assign TU_out_1[15] = TU_in_1 > 2 ?  1'b1 :  1'b0;
assign TU_out_1[14] = TU_in_1 > 3 ?  1'b1 :  1'b0;
assign TU_out_1[13] = TU_in_1 > 4 ?  1'b1 :  1'b0;
assign TU_out_1[12] = TU_in_1 > 5 ?  1'b1 :  1'b0;
assign TU_out_1[11] = TU_in_1 > 6 ?  1'b1 :  1'b0;
assign TU_out_1[10] = TU_in_1 > 7 ?  1'b1 :  1'b0;
assign TU_out_1[9] = TU_in_1 > 8 ?  1'b1 :  1'b0;
assign TU_out_1[8:0] = 0;
assign TU_num_1 =TU_in_1 < TU_cMax_1 ? TU_in_1 + 1 : TU_cMax_1;

assign TU_out_2[13:0] = 0;
assign TU_out_2[17] = value_2 > 0 ?  1'b1 :  1'b0;
assign TU_out_2[16] = value_2 > 1 ?  1'b1 :  1'b0;
assign TU_out_2[15] = value_2 > 2 ?  1'b1 :  1'b0;
assign TU_out_2[14] = value_2 > 3 ?  1'b1 :  1'b0;
assign TU_num_2 =value_2 < cMax_2 ? value_2 + 1 : cMax_2;

assign TU_out_3[13:0] = 0;
assign TU_out_3[17] = value_3 > 0 ?  1'b1 :  1'b0;
assign TU_out_3[16] = value_3 > 1 ?  1'b1 :  1'b0;
assign TU_out_3[15] = value_3 > 2 ?  1'b1 :  1'b0;
assign TU_out_3[14] = value_3 > 3 ?  1'b1 :  1'b0;
assign TU_num_3 =value_3 < cMax_3 ?  value_3 + 1 : cMax_3;
//}


// -- coeff_abs_level_remaining and mvd (EG)-- //


assign rParam_0 = cMax_0;
assign rParam_1 = cMax_1;
always @ (*)
begin
    case(rParam_0) // biggest is 4;
        0:
        begin
            shift_rParam_0 = 2'd3;
            code_rParam_0 = code_0[15:0];
            code_remain_0 = 0;
        end
        1:
        begin
            shift_rParam_0 = {2'd3, 1'd0};
            code_rParam_0 = code_0[15:1];
            code_remain_0 = code_0[0];
        end
        2:
        begin
            shift_rParam_0 = {2'd3, 2'd0};
            code_rParam_0 = code_0[15:2];
            code_remain_0 = code_0[1:0];
        end
        3:
        begin
            shift_rParam_0 = {2'd3, 3'd0};
            code_rParam_0 = code_0[15:3];
            code_remain_0 = code_0[2:0];
        end
        default:
        begin
            shift_rParam_0 = {2'd3, 4'd0};
            code_rParam_0 = code_0[15:4];
            code_remain_0 = code_0[3:0];
        end
    endcase
    case(rParam_1) // biggest is 4;
        0:
        begin
            shift_rParam_1 = 2'd3;
            code_rParam_1 = code_1[15:0];
            code_remain_1 = 0;
        end
        1:
        begin
            shift_rParam_1 = {2'd3, 1'd0};
            code_rParam_1 = code_1[15:1];
            code_remain_1 = code_1[0];
        end
        2:
        begin
            shift_rParam_1 = {2'd3, 2'd0};
            code_rParam_1 = code_1[15:2];
            code_remain_1 = code_1[1:0];
        end
        3:
        begin
            shift_rParam_1 = {2'd3, 3'd0};
            code_rParam_1 = code_1[15:3];
            code_remain_1 = code_1[2:0];
        end
        default:
        begin
            shift_rParam_1 = {2'd3, 4'd0};
            code_rParam_1 = code_1[15:4];
            code_remain_1 = code_1[3:0];
        end
    endcase
end




cabac_bina_BSleft left_a(
                      .in(BS_inl_a),
                      .left(BS_left_a),
                      .out(BS_outl_a)
                  );
cabac_bina_BSleft left_b(
                      .in(BS_inl_b),
                      .left(BS_left_b),
                      .out(BS_outl_b)
                  );

cabac_bina_BSleft left_m(
                      .in(18'h3FFFF),
                      .left(BS_left_m),
                      .out(BS_outl_m)
                  );

cabac_bina_BSright right_a(
                       .in(BS_inr_a),
                       .right(BS_right_a),
                       .out(BS_outr_a)
                   );

cabac_bina_FC fc_0(
                  .in(FC_in_0),
                  .pos(FC_pos_0)
              );


always @ (*)
begin
    code_0 = 0;
    out_half = 0;
    FC_in_0  = 0;
    BS_left_m = 0;
    CR_num_0 = 0;
    CR_out_0 = 0;
    EG_num_0 = 0;
    EG_out_0 = 0;
    BS_inl_a = 0;
    BS_left_a = 0;
    BS_inr_a = 0;
    BS_right_a = 0;
    BS_inl_b = 0;
    BS_left_b = 0;
    if(value_0 < shift_rParam_0 && type_0 == BINA_CREG)
    begin// max is [5:0]=110000=48;
        //TU_in_0 = code_rParam_0; TU_cMax_0 = 3;  !!!! ADD it !!!
        code_0[15:0] = value_0;
        CR_num_0 = TU_num_0 + rParam_0; // length+1+rParam;
        BS_inl_a = {14'd0, code_remain_0};
        BS_left_a = 18 - rParam_0 - TU_num_0;
        CR_out_0 = TU_out_0 | BS_outl_a;
    end
    else
    begin//(3)'{111}, length'{1..1}, {0}, length{code+1[pos-1:0]}, rParam'{[rPram-1:0]};
        if(type_0==BINA_CREG)
        begin
            code_0[15:0] = value_0 - shift_rParam_0; // codeNumber = codeNumber - 3 << rParam;
        end
        else
        begin
            code_0[15:0] = value_0;
        end
        if(code_0 > 253 && type_0 == BINA_EG)
        begin
            FC_in_0 = code_rParam_0 + 1; // length = FC_pos_0;
            BS_inl_a = code_rParam_0 + 1;
            BS_left_a = 18  - FC_pos_0; // BS_inl_a: del the first bit of FC_in_0.

            BS_inr_a = BS_outl_a;
            BS_right_a = 2 + FC_pos_0 + 1; // BS_outr_a is {0, x , x};
            BS_inl_b = code_remain_0;
            BS_left_b = 18 - 2 - (FC_pos_0 + 1'b1 + FC_pos_0) - rParam_0;
            BS_left_m = 18 - (2 + FC_pos_0);  //(3)'{111}, length'{1..1}, {0}
            CR_out_0 = BS_outl_m | BS_outr_a | BS_outl_b;
            EG_out_0 = {CR_out_0[15:0], 2'd0};
            CR_num_0 = 4 + FC_pos_0 + FC_pos_0 + rParam_0; // 3 + FC_pos_0 + 1 + FC_pos_0 + rParam;
            EG_num_0 = CR_num_0 - 3;
        end
        else
        begin
            FC_in_0 = code_rParam_0 + 1; // length = FC_pos_0;
            BS_inl_a = code_rParam_0 + 1;
            BS_left_a = 18  - FC_pos_0; // BS_inl_a: del the first bit of FC_in_0.

            BS_inr_a = BS_outl_a;
            BS_right_a = 3 + FC_pos_0 + 1; // BS_outr_a is {0, x , x};
            BS_inl_b = code_remain_0;
            BS_left_b = 18 - 3 - (FC_pos_0 + 1'b1 + FC_pos_0) - rParam_0;
            BS_left_m = 18 - (3 + FC_pos_0);  //(3)'{111}, length'{1..1}, {0}
            CR_out_0 = BS_outl_m | BS_outr_a | BS_outl_b;
            EG_out_0 = {CR_out_0[14:0], 3'd0};
            CR_num_0 = 4 + FC_pos_0 + FC_pos_0 + rParam_0; // 3 + FC_pos_0 + 1 + FC_pos_0 + rParam;
            EG_num_0 = CR_num_0 - 3;
        end
        //if(CR_num_0 > 18 && (type_0 == BINA_CREG || type_0 == BINA_EG) )
        if((CR_num_0 > 18 && (type_0 == BINA_CREG))||(CR_num_0 > 19 && (type_0 == BINA_EG)))
        begin
            out_half = 1;
            BS_left_a = rParam_0;
        end
    end
end




// second

reg    [17:0]    BS_inl_c, BS_inl_d, BS_inr_b;
reg    [4:0]     BS_left_c, BS_left_d, BS_right_b, BS_left_n;
wire   [17:0]  BS_outl_c, BS_outl_d, BS_outr_b, BS_outl_n;
reg    [15:0]    FC_in_1;
wire   [4:0]     FC_pos_1;

cabac_bina_BSleft left_c(
                      .in(BS_inl_c),
                      .left(BS_left_c),
                      .out(BS_outl_c)
                  );
cabac_bina_BSleft left_d(
                      .in(BS_inl_d),
                      .left(BS_left_d),
                      .out(BS_outl_d)
                  );

cabac_bina_BSleft left_n(
                      .in(18'h3FFFF),
                      .left(BS_left_n),
                      .out(BS_outl_n)
                  );

cabac_bina_BSright right_b(
                       .in(BS_inr_b),
                       .right(BS_right_b),
                       .out(BS_outr_b)
                   );

cabac_bina_FC fc_1(
                  .in(FC_in_1),
                  .pos(FC_pos_1)
              );

always @ (*)
begin
    code_1 = 0;
    CR_num_1 = 0;
    CR_out_1 = 0;
    EG_num_1 = 0;
    EG_out_1 = 0;
    BS_inl_c = 0;
    BS_left_c = 0;
    BS_inr_b = 0;
    BS_right_b = 0;
    BS_inl_d = 0;
    BS_left_d = 0;
    BS_left_n = 0;
    FC_in_1  = 0;
    if(value_1 < shift_rParam_1 && type_1 == BINA_CREG)
    begin// max is [5:0]=110000=48;
        //TU_in_1 = code_rParam_1; TU_cMax_1 = 3;  !!!! ADD it !!!
        code_1[15:0] = value_1;
        CR_num_1 = TU_num_1 + rParam_1; // length+1+rParam;
        BS_inl_c = {14'd0, code_remain_1};
        BS_left_c = 18 - rParam_1 - TU_num_1;
        CR_out_1 = TU_out_1 | BS_outl_c;
    end
    else
    begin//(3)'{111}, length'{1..1}, {0}, length{code+1[pos-1:0]}, rParam'{[rPram-1:0]};
        if(type_1==BINA_CREG)
        begin
            code_1[15:0] = value_1 - shift_rParam_1; // codeNumber = codeNumber - 3 << rParam;
        end
        else
        begin
            code_1[15:0] = value_1;
        end
        FC_in_1 = code_rParam_1 + 1; // length = FC_pos_0;
        BS_inl_c = code_rParam_1 + 1;
        BS_left_c = 18 - FC_pos_1; // del the first bit.

        BS_inr_b = BS_outl_c;
        BS_right_b = 3 + FC_pos_1 + 1; // BS_outr_a is {0, x , x};
        BS_inl_d = code_remain_1;
        BS_left_d = 18 - 3 - (FC_pos_1 + 1'b1 + FC_pos_1) - rParam_1;

        BS_left_n = 18 - (3 + FC_pos_1); // BS_outl_n = {3'{111}, length'{1...1}};
        CR_out_1 = BS_outl_n | BS_outr_b | BS_outl_d;
        EG_out_1 = {CR_out_1[14:0], 3'd0};
        CR_num_1 = 4 + FC_pos_1 + FC_pos_1 + rParam_1; // 3 + FC_pos_0 + 1 + FC_pos_0 + rParam;
        EG_num_1 = CR_num_1 - 3;
    end
end

//}


// --- FL --- //
wire   [17:0]    FL_out_0, FL_out_1, FL_out_2, FL_out_3;

cabac_bina_BSleft left_0(
                      .in({2'd0, value_0}),
                      .left(5'd18-cMax_0),
                      .out(FL_out_0)
                  );

cabac_bina_BSleft left_1(
                      .in({2'd0, value_1}),
                      .left(5'd18-cMax_1),
                      .out(FL_out_1)
                  );

cabac_bina_BSleft left_2(
                      .in({16'd0, value_2}),
                      .left(5'd18-cMax_2),
                      .out(FL_out_2)
                  );

cabac_bina_BSleft left_3(
                      .in({16'd0, value_3}),
                      .left(5'd18-cMax_3),
                      .out(FL_out_3)
                  );
//}



// --- right shift four out numbers--- //


reg    [4:0]     out_num_0, out_num_1, out_num_2, out_num_3;
wire   [17:0]    out_1, out_2, out_3;
reg    [17:0]    out_0;
wire   [161:0]   out_context_0, out_context_1, out_context_2, out_context_3;

reg    [4:0]  BS_left_0;
wire   [161:0] BS1s_outl_0;

cabac_bina_BS1sleft sleft_0(
                        .in(minus_one),
                        .left(BS_left_0),
                        .out(BS1s_outl_0)
                    );


always @ (*)
begin
    TU_in_0 = 0;
    TU_cMax_0 = 0;
    BS_left_0 = 0;
    out_0 = 0;
    out_num_0 = 0;
    case(type_0)
        BINA_FL:
        begin
            out_0 = FL_out_0;
            out_num_0 = cMax_0;
            BS_left_0 = 18 - cMax_0;
        end
        BINA_TU:
        begin
            TU_in_0 = value_0;
            TU_cMax_0 = cMax_0;
            out_0 = TU_out_0;
            out_num_0 = TU_num_0;
            BS_left_0 = 18 - TU_num_0;
        end
        BINA_CREG:
        begin
            TU_in_0 = code_rParam_0;
            TU_cMax_0 = 3;
            BS_left_0 = 18 - (out_half ?  4 + FC_pos_0 : CR_num_0);
            out_0 = CR_out_0;
            out_num_0 = CR_num_0;
        end
        BINA_EG:
        begin
            BS_left_0 = 18 - (out_half ? 1 + FC_pos_0 : EG_num_0);
            out_0 = EG_out_0;
            out_num_0 = EG_num_0;
        end
        default:
        begin // SP
            BS_left_0 = 18 - SP_num[0];
            out_0 = SP_out[0];
            out_num_0 = SP_num[0];
        end
    endcase
end

reg    [17:0]    BS_inr_1;
wire   [17:0]    BS_outr_1;
reg    [4:0]     BS1s_left_1;
wire   [161:0]   BS1s_outl_1,  BS1s_inr_1, BS1s_outr_1;

cabac_bina_BSright right_1(
                       .in(BS_inr_1),
                       .right(out_num_0),
                       .out(BS_outr_1)
                   );

cabac_bina_BS1sleft sleft_1(
                        .in(minus_one),
                        .left(BS1s_left_1),
                        .out(BS1s_outl_1)
                    );

cabac_bina_BS1sright sright_1(
                         .in(BS1s_inr_1),
                         .right(out_num_0),
                         .out(BS1s_outr_1)
                     );

assign out_1 = BS_outr_1;

always @ (*)
begin
    TU_in_1 = 0;
    TU_cMax_1 = 0;
    out_num_1 = 0;
    BS1s_left_1 = 0;
    case(type_1)
        BINA_FL:
        begin
            BS_inr_1 = FL_out_1;
            out_num_1 = cMax_1;
            BS1s_left_1=18-cMax_1;
        end
        BINA_TU:
        begin
            TU_in_1 = value_1;
            TU_cMax_1 = cMax_1;
            BS_inr_1 = TU_out_1;
            out_num_1 = TU_num_1;
            BS1s_left_1 = 18 - TU_num_1;
        end
        BINA_CREG:
        begin
            TU_in_1 = code_rParam_1;
            TU_cMax_1 = 3;
            BS_inr_1 = CR_out_1;
            out_num_1 = CR_num_1;
            BS1s_left_1 = 18 - CR_num_1;
        end
        BINA_EG:
        begin
            BS_inr_1 = EG_out_1;
            out_num_1 = EG_num_1;
            BS1s_left_1 = 18 - EG_num_1;
        end
        default:
        begin // SP
            BS_inr_1 = SP_out[1];
            out_num_1 = SP_num[1];
            BS1s_left_1 = 18 - SP_num[1];
        end
    endcase
end



wire   [4:0]     Bs1s_right_2;
reg    [17:0]    BS_inr_2;
wire   [17:0]    BS_outr_2;
reg    [4:0]     BS1s_left_2;
wire   [161:0]   BS1s_outl_2,  BS1s_inr_2, BS1s_outr_2;

cabac_bina_BSright right_2(
                       .in(BS_inr_2),
                       .right(Bs1s_right_2),
                       .out(BS_outr_2)
                   );

cabac_bina_BS1sleft sleft_2(
                        .in(minus_one),
                        .left(BS1s_left_2),
                        .out(BS1s_outl_2)
                    );

cabac_bina_BS1sright sright_2(
                         .in(BS1s_inr_2),
                         .right(Bs1s_right_2),
                         .out(BS1s_outr_2)
                     );

wire [8:0] context_2_upd;
assign context_2_upd = context_2 + 1;

assign Bs1s_right_2 = out_num_0 + out_num_1;
assign out_2 = BS_outr_2;

always @ (*)
begin
    BS_inr_2 = 0;
    out_num_2 = 0;
    BS1s_left_2 = 0;
    case(type_2)
        BINA_FL:
        begin
            BS_inr_2 = FL_out_2;
            out_num_2 = cMax_2;
            BS1s_left_2=18-cMax_2;
        end
        BINA_TU:
        begin
            BS_inr_2 = TU_out_2;
            out_num_2 = TU_num_2;
            BS1s_left_2 = 18 - TU_num_2;
        end
        default:
        begin // SP
            BS_inr_2 = SP_out[2];
            out_num_2 = SP_num[2];
            BS1s_left_2 = 18 - SP_num[2];
        end
    endcase
end


wire   [4:0]     Bs1s_right_3;
reg    [17:0]    BS_inr_3;
wire   [17:0]    BS_outr_3;
reg    [4:0]     BS1s_left_3;
wire   [161:0]   BS1s_outl_3,  BS1s_inr_3, BS1s_outr_3;

cabac_bina_BSright right_3(
                       .in(BS_inr_3),
                       .right(Bs1s_right_3),
                       .out(BS_outr_3)
                   );

cabac_bina_BS1sleft sleft_3(
                        .in(minus_one),
                        .left(BS1s_left_3),
                        .out(BS1s_outl_3)
                    );

cabac_bina_BS1sright sright_3(
                         .in(BS1s_inr_3),
                         .right(Bs1s_right_3),
                         .out(BS1s_outr_3)
                     );
assign Bs1s_right_3 = out_num_0 + out_num_1 + out_num_2;
assign out_3 = BS_outr_3;

always @ (*)
begin
    BS_inr_3  = 0;
    out_num_3 = 0;
    BS1s_left_3 = 0;
    case(type_3)
        BINA_FL:
        begin
            BS_inr_3 = FL_out_3;
            out_num_3 = cMax_3;
            BS1s_left_3 = 18 - cMax_3;   //BS1s_inr_2 = BS1s_outl_2;  BS1s_right_2 = out_num_0 + out_num_1;
        end
        BINA_TU:
        begin
            BS_inr_3 = TU_out_3;
            out_num_3 = TU_num_3;
            BS1s_left_3 = 18 - TU_num_3;
        end
        default:
        begin // SP
            BS_inr_3 = SP_out[3];
            out_num_3 = SP_num[3];
            BS1s_left_3 = 18 - SP_num[3];
        end
    endcase
end

assign    context_bypass = 187;

assign    ctx[0] = context_0;
assign    ctx[1] = context_1;
assign    ctx[2] = context_2;
assign    ctx[3] = context_3;

assign    cMax[0] = cMax_0;
assign    cMax[1] = cMax_1;
assign    cMax[2] = cMax_2;
assign    cMax[3] = cMax_3;

assign    value[0] = value_0;
assign    value[1] = value_1;
assign    value[2] = value_2;
assign    value[3] = value_3;



// --- Specail --- //

reg              ctx_spflag[0:3];
integer i;

always @ (*)
begin
    for (i=0; i<4; i=i+1)
    begin
        case(ctx[i])
            9'd8:
            begin // part_mode
                case(cMax[i])
                    1:
                    begin
                        SP_num [i]= 1;
                        SP_out[i] = {value[i], 17'd0};
                    end // intra;
                    2:
                    begin
                        SP_num[i] = value[i] == 0 ? 5'b00001 : 5'b00010;
                        SP_out[i] = value[i] == 0 ? {1'b1, 17'd0} : value[i]==1 ? {2'b01, 16'd0} : 0;
                    end
                    3:
                    begin
                        SP_num[i]= value[i] == 3 ? 3 : value[i] + 1;
                        SP_out[i] = value[i] == 3 ? 0 : value[i]==0 ? {1'b1, 17'd0} : value[i]==1 ? {2'b01, 16'd0} : {3'b001, 15'd0};
                    end
                    default:
                    begin
                        SP_num [i]= value[i] > 3 ? 4 : (value[i]==0 ? 5'b00001 : 5'b00011); // cMax == 4;
                        case(value[i])
                            1:
                                SP_out[i] = {1'b0, 2'b11, 15'd0};
                            2:
                                SP_out[i] = {3'b001, 15'd0} ;
                            4:
                                SP_out[i] = {4'b0100, 14'd0} ;
                            5:
                                SP_out[i] = {4'b0101, 14'd0} ;
                            6:
                                SP_out[i] = 0;
                            7:
                                SP_out[i] = {4'b0001, 14'd0} ;
                            default:
                                SP_out[i] = {1'b1, 17'd0}; // ==-
                        endcase
                    end
                endcase
            end
            9'd15:
            begin // intra_chroma_pred_mode
                SP_num [i] =3;
                case(value[i])
                    0:
                    begin
                        SP_out[i]={3'b100, 15'd0};
                    end
                    1:
                    begin
                        SP_out[i]={3'b101, 15'd0};
                    end
                    2:
                    begin
                        SP_out[i]={3'b110, 15'd0};
                    end
                    3:
                    begin
                        SP_out[i]={3'b111, 15'd0};
                    end
                    default:
                    begin
                        SP_num[i]=1;
                        SP_out[i]=18'd0;
                    end //=4
                endcase
            end
            9'd17, 9'd18, 9'd19, 9'd20, 9'd21:
            begin
                SP_num [i] = value[i] == 2 ?  1 : cMax[i];
                if(value[i]==2)
                    SP_out[i] = {1'b1, 17'd0};
                else
                begin
                    if(cMax[i]==1)
                        SP_out[i] = {value[i], 17'd0};
                    else
                        SP_out[i] = {value[i], 16'd0}; //cMax = 2;
                end
            end
            default:
            begin
                SP_num[i] = 0;
                SP_out[i] = 0;
            end
        endcase
    end
end



reg    [8:0]     ctx_add1, ctx_add2, ctx_add3, ctx_add4;

always @ (*)
begin
    for(i=0; i<4; i = i+1 )
    begin
        ctx_spflag[i] = 1;
        log2TrafoSize = (cMax[i] + 1) >> 1;
        ctxShift = (log2TrafoSize + 1) >> 2;
        ctx_add1 = ctx[i] + 1;
        ctx_add2 = ctx[i] + 2;
        ctx_add3 = ctx[i] + 3;
        ctx_add4 = ctx[i] + 4;
        case(ctx[i])
            7:
                out_ctx[i] = {9'd7, context_bypass, context_bypass, context_bypass, {14{9'd0}}}; // merge_idx
            15:
                out_ctx[i] = {9'd15, context_bypass, context_bypass, 135'd0};  // intra_chroma_pred_mode
            17, 18, 19, 20, 21:
                out_ctx[i] ={ctx[i], 9'd21, {16{9'd0}}};
            24:
                out_ctx[i] = {9'd24, 9'd25, context_bypass, context_bypass, {14{9'd0}}}; //ref_idx_l0, ref_idx_l1
            26:
                out_ctx[i] = {9'd26, 9'd27, 9'd27, 9'd27, 9'd27, context_bypass, {12{9'd0}}}; // cu_qp_delta_abs
            182:
                out_ctx[i] = {ctx[i], context_bypass, {16{9'd0}}};
            8:
            begin // part_mode
                if(cMax[i]==4)
                    out_ctx[i] = {9'd8, 9'd9, 9'd11, context_bypass, {14{9'd0}}};
                else
                    out_ctx[i] = {9'd8, 9'd9, 9'd10, context_bypass, {14{9'd0}}};
            end
            86,  87,  88,  89,  90,  91,  92,  93,  94,  95,  96,  97,  98,  99, 100, // last_sig_coeff_x_prefix luma;
            116, 117 ,118 ,119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130:
            begin// last_sig_coeff_y_prefix luma;
                // cMax <= 9; ctxShift = 1, or 0
                if(ctxShift == 1)
                begin
                    out_ctx[i] = {ctx[i], ctx[i], ctx_add1, ctx_add1, ctx_add2, ctx_add2, ctx_add3, ctx_add3, ctx_add4, {9{9'd0}}};
                end
                else
                begin // shift = 0; cMax = 3;
                    out_ctx[i] = {ctx[i], ctx_add1, ctx_add2, {15{9'd0}}};
                end
            end
            101, 102, 103, // last_sig_coeff_x_prefix chroma;
            131, 132, 133:
            begin// last_sig_coeff_y_prefix chroma;
                ctxShift = log2TrafoSize - 2; // = 2, 1, 0.
                if(ctxShift == 2) // cMax = 7;
                    out_ctx[i] ={ctx[i], ctx[i], ctx[i], ctx[i], ctx_add1, ctx_add1, ctx_add1, {11{9'd0}}};
                else if(ctxShift == 1) // cMax = 5
                    out_ctx[i] = {ctx[i], ctx[i], ctx_add1, ctx_add1, ctx_add2, {13{9'd0}}};
                else // ctxShift= 0, cMax = 3
                    out_ctx[i] = {ctx[i], ctx_add1, ctx_add2, {15{9'd0}}};
            end
            188, 189, 190, 191:
            begin
                ctx_spflag[i] = 0;
                out_ctx[i] = {18{context_bypass}};
            end
            default:
            begin
                ctx_spflag[i] = 0;
                out_ctx[i] = {18{ctx[i]}};
            end
        endcase
    end
end

assign out_context_0 = out_ctx[0] & BS1s_outl_0;

assign BS1s_inr_1 = ctx_spflag[1] ?  out_ctx[1] & BS1s_outl_1 :  BS1s_outl_1;
assign out_context_1 = ctx_spflag[1] ? BS1s_outr_1 : out_ctx[1] & BS1s_outr_1;

assign BS1s_inr_2 = ctx_spflag[2] ?  out_ctx[2] & BS1s_outl_2: BS1s_outl_2;
assign out_context_2 = ctx_spflag[2] ? BS1s_outr_2 : out_ctx[2] & BS1s_outr_2;

assign BS1s_inr_3 = ctx_spflag[3] ? out_ctx[3] & BS1s_outl_3: BS1s_outl_3;
assign out_context_3 = ctx_spflag[3] ? BS1s_outr_3 : out_ctx[3] & BS1s_outr_3;


wire   [4:0]     totoal_num;
wire             slice_end;
reg              flag_end_slice;

wire   [4:0]     re_num;
wire             next_wack_store;
reg              wack_o;

assign totoal_num = Bs1s_right_3 + out_num_3;
assign slice_end = (context_0==CONT_FINAL && value_0==1)|| (context_1==CONT_FINAL && value_1==1)|| (context_2==CONT_FINAL && value_2==1) || (context_3==CONT_FINAL && value_3==1); // && not wack_store;

assign wack = re_num < free_space & rdy & init_done & !flag_end_slice & !wack_store;
//assign wack_o = re_num < free_space & init_done & !flag_end_slice & !wack_store;
//assign wack = rdy & init_done & !flag_end_slice & !wack_store;
assign re_num = totoal_num > 18 ?  (out_half ?  out_num_0 - FC_pos_0 - rParam_0  : out_num_0) :  totoal_num;

assign next_wack_store = (wack | wack_store) && totoal_num >18;

always @ (posedge clk or negedge rst_n)
    if(!rst_n)
    begin
        wack_store <= 0;
        wack_o     <= 1;
    end
    else if(!en)
    begin
        wack_store <= 0;
        wack_o     <= 1;
    end
    else if((wack | wack_store) && totoal_num >18)
    begin
        wack_store <= 1;
        wack_o     <= 0;
    end
    else
    begin
        wack_store <= 0;
        wack_o     <= 1;
    end



always @ (posedge clk or negedge rst_n)
    if(!rst_n)
    begin
        out_number <= 0;
        valid <= 0;
        {ob_0[9], ob_1[9], ob_2[9], ob_3[9], ob_4[9], ob_5[9], ob_6[9], ob_7[9], ob_8[9],
         ob_9[9], ob_10[9], ob_11[9], ob_12[9], ob_13[9], ob_14[9], ob_15[9], ob_16[9], ob_17[9]}
        <= 0;
        {ob_0[8:0], ob_1[8:0], ob_2[8:0], ob_3[8:0], ob_4[8:0], ob_5[8:0], ob_6[8:0], ob_7[8:0], ob_8[8:0],
         ob_9[8:0], ob_10[8:0], ob_11[8:0], ob_12[8:0], ob_13[8:0], ob_14[8:0], ob_15[8:0], ob_16[8:0], ob_17[8:0]}
        <= 0;
    end
    else if(!en)
    begin
        out_number <= 0;
        valid <= 0;
        {ob_0[9], ob_1[9], ob_2[9], ob_3[9], ob_4[9], ob_5[9], ob_6[9], ob_7[9], ob_8[9],
         ob_9[9], ob_10[9], ob_11[9], ob_12[9], ob_13[9], ob_14[9], ob_15[9], ob_16[9], ob_17[9]}
        <= 0;
        {ob_0[8:0], ob_1[8:0], ob_2[8:0], ob_3[8:0], ob_4[8:0], ob_5[8:0], ob_6[8:0], ob_7[8:0], ob_8[8:0],
         ob_9[8:0], ob_10[8:0], ob_11[8:0], ob_12[8:0], ob_13[8:0], ob_14[8:0], ob_15[8:0], ob_16[8:0], ob_17[8:0]}
        <= 0;
    end
    else
    begin
        out_number <= (wack | wack_store) ? re_num : 0;
        valid <= wack | wack_store;
        {ob_0[9], ob_1[9], ob_2[9], ob_3[9], ob_4[9], ob_5[9], ob_6[9], ob_7[9], ob_8[9],
         ob_9[9], ob_10[9], ob_11[9], ob_12[9], ob_13[9], ob_14[9], ob_15[9], ob_16[9], ob_17[9]}
        <= out_0 | out_1 | out_2 | out_3;
        {ob_0[8:0], ob_1[8:0], ob_2[8:0], ob_3[8:0], ob_4[8:0], ob_5[8:0], ob_6[8:0], ob_7[8:0], ob_8[8:0],
         ob_9[8:0], ob_10[8:0], ob_11[8:0], ob_12[8:0], ob_13[8:0], ob_14[8:0], ob_15[8:0], ob_16[8:0], ob_17[8:0]}
        <= out_context_0 | out_context_1 | out_context_2 | out_context_3;
    end



always @ (posedge clk or negedge rst_n)
    if(!rst_n)
    begin
        flag_end_slice <= 0;
    end
    else if(!en)
    begin
        flag_end_slice <= 0;
    end
    else if (!flag_end_slice && slice_end && (wack && !next_wack_store) )
    begin
        flag_end_slice <= 1;
    end


endmodule
