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
// Filename       : cabac_ucontext.v
// Author         : liwei
// Created        : 2018-3-01
// Description    : update context table
// DATA & EDITION:  2012/9/21    from waseda
//                  2018/3/01   edit by liwei
// $Id$
//-----------------------------------------------------------------------------------------------------------------------------

module cabac_ucontext(
           clk,
           enable,
           en,
           rst_n,

           gp_qp,
           gp_slice_type,
           gp_cabac_init_flag,
           init_done,
           number_range,
           number_all,
           index_bypass,
           symbol_bypass,

           binsidx_0,
           binsidx_1,
           binsidx_2,
           binsidx_3,

           out_number_range,
           out_number_all,
           out_index_bypass,
           out_symbol_bypass,

           out_context_0,
           out_context_1,
           out_context_2,
           out_context_3
       );

parameter  INIT_NUM_PER_CYC = 1, // the number of contexts is initialized per cycle.
           PROCESS_NUM = 186, // from  0 to 185
           PROCESS_NUM_MINUS1 = PROCESS_NUM - 1,
           CNU = 154, // dummy initialization value for unused context models 'Context model Not Used'
           Model_CUSplitFlag = 0,
           Model_CUSkipFlag = 3,
           Model_CUMergeFlagExt = 6,
           Model_CUMergeIdxExt = 7,
           Model_CUPartSize = 8,
           Model_CUAMP = 12,
           Model_CUPredMode = 13,
           Model_CUIntraPred = 14,
           Model_CUChromaPred  = 15,// in HM13.0 only one initValue
           Model_CUInterDir = 17,
           Model_CUMvd = 22,
           Model_CURefPic = 24,
           Model_CUDeltaQp = 26,
           Model_CUQtCbf = 29,
           Model_CUQtRootCbf = 39,
           Model_CUSigCoeffGroup = 40,
           Model_CUSig = 44,
           Model_CUCtxLastX = 86,
           Model_CUCtxLastY = 116,
           Model_CUOne = 146,
           Model_CUAbs = 170,
           Model_MVPIdx = 176,
           Model_CUTransSubdivFlag = 178,  // in HM13.0 doc Rec.ITU-T H.265(04/2013) the initValue is changed !!
           Model_SaoMerge = 181,
           Model_SaoTypeIdx = 182, // in HM13.0 doc Rec.ITU-T H.265(04/2013) the initValue is changed !!
           Model_TransformSkip = 183,
           Model_CUTransquantBypassFlag = 185,
           Model_EqProb = 187, //bypass
           Model_Final = 186;
//input and output signals //{
input       clk;
input       enable;     //1 to enable
input       en;   //0 to reset
input               rst_n;

input   [2:0] number_range;   //0~4
input   [3:0] number_all;
input   [7:0] index_bypass;
input   [7:0] symbol_bypass;

input   [9:0] binsidx_0;
input   [9:0] binsidx_1;
input   [9:0] binsidx_2;
input   [9:0] binsidx_3;
input       [1:0]   gp_slice_type; // I-2; P-1; B-0
input               gp_cabac_init_flag;
input       [5:0]   gp_qp;
output              init_done;

output  reg [2:0] out_number_range;
output  reg [3:0] out_number_all;
output  reg [7:0] out_index_bypass;
output  reg [7:0] out_symbol_bypass;
output  reg [6:0] out_context_0;  //[6]=lpsmps, [5:0]=pStateIdx // [6] 1:symbol=mps; 0:sym=lps;
output  reg [6:0] out_context_1;
output  reg [6:0] out_context_2;
output  reg [6:0] out_context_3;
//}

reg       [6:0] context_table[0:187];     //[6]=mps, [5:0]=pstateidx
reg         [6:0]   init_context_table[0:187];

wire          symbol_0;
wire          symbol_1;
wire          symbol_2;
wire          symbol_3;
wire      [8:0] ctxidx_0;
wire      [8:0] ctxidx_1;
wire      [8:0] ctxidx_2;
wire      [8:0] ctxidx_3;
wire      [6:0] read_context_0;
wire      [6:0] read_context_1;
wire      [6:0] read_context_2;
wire      [6:0] read_context_3;

reg         in_symbol_tt_0;
reg         in_symbol_tt_1;
reg         in_symbol_t_4;
wire      [6:0]   out_context_t_0;
wire      [6:0] out_context_t_1;
wire      [6:0] out_context_t_2;
wire      [6:0] out_context_t_3;
wire      [6:0] out_context_t_4;
wire      [6:0] out_context_t_5;
wire      [6:0] out_context_t_6;
wire      [6:0] out_context_tt_0;
wire      [6:0] out_context_tt_1;
wire      [6:0] out_context_tt_2;

wire    [6:0] wire_out_context_0;
wire    [6:0] wire_out_context_1;
reg     [6:0] wire_out_context_2;
reg     [6:0] wire_out_context_3;


assign symbol_0 = binsidx_0[9];
assign symbol_1 = binsidx_1[9];
assign symbol_2 = binsidx_2[9];
assign symbol_3 = binsidx_3[9];
assign ctxidx_0 = binsidx_0[8:0];
assign ctxidx_1 = binsidx_1[8:0];
assign ctxidx_2 = binsidx_2[8:0];
assign ctxidx_3 = binsidx_3[8:0];
assign read_context_0 = context_table[ctxidx_0];
assign read_context_1 = context_table[ctxidx_1];
assign read_context_2 = context_table[ctxidx_2];
assign read_context_3 = context_table[ctxidx_3];

//-----get t_x, tt_x means update 1, 2, 3 times-------//
/******************************************************
t_0: 
    update idx_0 1 time.
  no idx is same with idx_0; 
tt_0: 
    update idx_0 2 times
    1 idx is same with idx_0 (idx_0=idx_1 or idx_0=idx_2 or idx_0=idx_3);
t_4:
    update idx_0 3 times
  2 idx are same with idx_0 (idx_0=idx_1=idx_2 or idx_0=idx_1=idx_3 or idx_0=idx_1=idx_3)
... ...
******************************************************/

cabac_ucontext_t cabac_ucontext_t_0( // according to symbol_0 and idx0, update mps and state.
                     .in_context(read_context_0),
                     .symbol(symbol_0),
                     .out_context(out_context_t_0)
                 );
cabac_ucontext_t cabac_ucontext_t_1(
                     .in_context(read_context_1),
                     .symbol(symbol_1),
                     .out_context(out_context_t_1)
                 );
cabac_ucontext_t cabac_ucontext_t_2(
                     .in_context(read_context_2),
                     .symbol(symbol_2),
                     .out_context(out_context_t_2)
                 );
cabac_ucontext_t cabac_ucontext_t_3(
                     .in_context(read_context_3),
                     .symbol(symbol_3),
                     .out_context(out_context_t_3)
                 );

cabac_ucontext_t cabac_ucontext_t_4(
                     .in_context(out_context_tt_0),
                     .symbol(in_symbol_t_4),
                     .out_context(out_context_t_4)
                 );
cabac_ucontext_t cabac_ucontext_t_5(
                     .in_context(out_context_tt_1),
                     .symbol(symbol_3),
                     .out_context(out_context_t_5)
                 );
cabac_ucontext_t cabac_ucontext_t_6(
                     .in_context(out_context_t_2),
                     .symbol(symbol_3),
                     .out_context(out_context_t_6)
                 );
cabac_ucontext_tt cabac_ucontext_tt_0(
                      .in_context(read_context_0),
                      .symbol_0(symbol_0),
                      .symbol_1(in_symbol_tt_0),
                      .out_context(out_context_tt_0)
                  );
cabac_ucontext_tt cabac_ucontext_tt_1(
                      .in_context(read_context_1),
                      .symbol_0(symbol_1),
                      .symbol_1(in_symbol_tt_1),
                      .out_context(out_context_tt_1)
                  );
cabac_ucontext_tt cabac_ucontext_tt_2(
                      .in_context(out_context_tt_0),
                      .symbol_0(symbol_2),
                      .symbol_1(symbol_3),
                      .out_context(out_context_tt_2)
                  );

always @(*) //in_symbol_tt_0
begin
    if(ctxidx_0==ctxidx_1)
        in_symbol_tt_0 = symbol_1;
    else if(ctxidx_0==ctxidx_2)
        in_symbol_tt_0 = symbol_2;
    else
        in_symbol_tt_0 = symbol_3;
end
always @(*) //in_symbol_tt_1
begin
    if(ctxidx_1==ctxidx_2)
        in_symbol_tt_1 = symbol_2;
    else
        in_symbol_tt_1 = symbol_3;
end
always @(*) //in_symbol_t_4
begin
    if((ctxidx_0==ctxidx_1)&&(ctxidx_0==ctxidx_2))
        in_symbol_t_4 = symbol_2;
    else
        in_symbol_t_4 = symbol_3;
end
//---------------------------------------------------//


//-------------------update context table-----------//
/***************************************************
ex: 
  all are diff.
  output context_0 = input_context_0
  updated context_table = update 1 time of idx_0 which is t_0;
******************************************************/
integer i;
reg    [7:0]     proc_cnt;
reg              init_done_flag_, init_done_flag;
wire             init_done;
assign           init_done = init_done_flag_;
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        for(i=0; i<188; i=i+1)
            context_table[i] <= 0;
    end
    else if(!en)
    begin
        for(i=0; i<188; i=i+1)
            context_table[i] <= 0;
    end
    else if(init_done_flag && !init_done_flag_)
    begin
        for(i=0; i<188; i=i+1)
            context_table[i] <= init_context_table[i];
    end
    else if(enable)
    begin // HERE!! init_done==1;
        if(number_range>0)
        begin
            if(ctxidx_0==ctxidx_1 && ctxidx_0==ctxidx_2 && ctxidx_0==ctxidx_3)
                context_table[ctxidx_0] <= out_context_tt_2;
            else if((ctxidx_0==ctxidx_1&&ctxidx_0==ctxidx_2) || (ctxidx_0==ctxidx_1&&ctxidx_0==ctxidx_3) || (ctxidx_0==ctxidx_2&&ctxidx_0==ctxidx_3))
                context_table[ctxidx_0] <= out_context_t_4;
            else if(ctxidx_0==ctxidx_1 || ctxidx_0==ctxidx_2 || ctxidx_0==ctxidx_3)
                context_table[ctxidx_0] <= out_context_tt_0;
            else
                context_table[ctxidx_0] <= out_context_t_0;
        end
        if(number_range>1 && ctxidx_1!=ctxidx_0)
        begin
            if(ctxidx_1==ctxidx_2 && ctxidx_1==ctxidx_3)
                context_table[ctxidx_1] <= out_context_t_5;
            else if(ctxidx_1==ctxidx_2 || ctxidx_1==ctxidx_3)
                context_table[ctxidx_1] <= out_context_tt_1;
            else
                context_table[ctxidx_1] <= out_context_t_1;
        end
        if(number_range>2 && ctxidx_2!=ctxidx_1 && ctxidx_2!=ctxidx_0)
        begin
            if(ctxidx_2==ctxidx_3)
                context_table[ctxidx_2] <= out_context_t_6;
            else
                context_table[ctxidx_2] <= out_context_t_2;
        end
        if(number_range>3 && ctxidx_3!=ctxidx_2 && ctxidx_3!=ctxidx_1 && ctxidx_3!=ctxidx_0)
            context_table[ctxidx_3] <= out_context_t_3;
    end
end



//---------------------------------------------------//



//-------output contex -----------------------------//
/***************************************************
ex 1: 
  all are diff.
  output context_0 = input_context_0;
 
ex 2: 
  idx_0=idx_1, others diff.
  output context_0 = input_contex_0;
  output context_1 = t_0 (after update contex_0)
******************************************************/

assign wire_out_context_0 = read_context_0;
assign wire_out_context_1 = (ctxidx_0==ctxidx_1) ? out_context_t_0 : read_context_1;
always @(*) //wire_out_context_2
begin
    if(ctxidx_2==ctxidx_0)
        wire_out_context_2 = (ctxidx_2==ctxidx_1) ? out_context_tt_0 : out_context_t_0;
    else
        wire_out_context_2 = (ctxidx_2==ctxidx_1) ? out_context_t_1 : read_context_2;
end
always @(*) //wire_out_context_3
begin
    if(ctxidx_3==ctxidx_0)
    begin
        if(ctxidx_3==ctxidx_1)
            wire_out_context_3 = (ctxidx_3==ctxidx_2) ? out_context_t_4 : out_context_tt_0;
        else
            wire_out_context_3 = (ctxidx_3==ctxidx_2) ? out_context_tt_0 : out_context_t_0;
    end
    else
    begin
        if(ctxidx_3==ctxidx_1)
            wire_out_context_3 = (ctxidx_3==ctxidx_2) ? out_context_tt_1 : out_context_t_1;
        else
            wire_out_context_3 = (ctxidx_3==ctxidx_2) ? out_context_t_2 : read_context_3;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        out_number_all <= 0;
        out_number_range <= 0;
        out_index_bypass <= 0;
        out_symbol_bypass <= 0;
        out_context_0 <= 0;
        out_context_1 <= 0;
        out_context_2 <= 0;
        out_context_3 <= 0;
    end
    else if(!en)
    begin
        out_number_all <= 0;
        out_number_range <= 0;
        out_index_bypass <= 0;
        out_symbol_bypass <= 0;
        out_context_0 <= 0;
        out_context_1 <= 0;
        out_context_2 <= 0;
        out_context_3 <= 0;
    end
    else if (enable)
    begin
        out_number_range <= number_range ;
        out_number_all <= number_all;
        out_index_bypass <= index_bypass;
        out_symbol_bypass <= symbol_bypass ;
        out_context_0[6] <= symbol_0 ^ wire_out_context_0[6];
        out_context_1[6] <= symbol_1 ^ wire_out_context_1[6];
        out_context_2[6] <= symbol_2 ^ wire_out_context_2[6];
        out_context_3[6] <= symbol_3 ^ wire_out_context_3[6];
        out_context_0[5:0] <= wire_out_context_0[5:0];
        out_context_1[5:0] <= wire_out_context_1[5:0];
        out_context_2[5:0] <= wire_out_context_2[5:0];
        out_context_3[5:0] <= wire_out_context_3[5:0];
    end
end
//---------------------------------------------------//

reg signed [8:0]     inittable[0: PROCESS_NUM_MINUS1];
reg    [5:0]     statetable[0:PROCESS_NUM_MINUS1], state;
reg              mpstable[0:PROCESS_NUM_MINUS1], mps;

always @ (*)
begin
    for(i=0; i<188; i=i+1)
    begin
        init_context_table[i] = 7'd0;
    end
    for(i=0; i<PROCESS_NUM; i=i+1)
    begin
        init_context_table[i] = {mpstable[i],  statetable[i]};
    end
    init_context_table[186] = 7'b0111111;
    init_context_table[187] = 7'b1111111;
end

//state
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        init_done_flag <= 1'd0;
        init_done_flag_ <= 1'd0;
    end
    else if (!en)
    begin
        init_done_flag <= 1'd0;
        init_done_flag_ <= 1'd0;
    end
    else
    begin
        init_done_flag <= init_done_flag ? 1'b1 : proc_cnt >= PROCESS_NUM_MINUS1;
        init_done_flag_ <= init_done_flag;
    end
end
//behave
reg     [7:0] cnt;
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt <= 0;
    else if(!en)
        cnt <= 0;
    else
        cnt <= cnt + 1;
end


always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        proc_cnt <= 0;
    else if(!en)
        proc_cnt <= 0;
    else
    begin
        if(!init_done_flag)
            proc_cnt <= proc_cnt + INIT_NUM_PER_CYC;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        mpstable[proc_cnt] <= 0;
        statetable[proc_cnt] <= 0;
    end
    else if(!en)
    begin
        mpstable[proc_cnt] <= 0;
        statetable[proc_cnt] <= 0;
    end
    else
    begin
        if(!init_done_flag)
        begin
            mpstable[proc_cnt] <= mps;
            statetable[proc_cnt] <= state;
        end
    end
end

integer index;
reg signed  [7:0]       slope;
reg signed  [7:0]       offset;
reg signed  [14:0]      product_slope_qp;
reg signed  [10:0]      product_slope_qp_temp;
reg signed  [6:0]       signed_qp;
reg signed  [7:0]       tmp;
reg signed  [7:0]       b;
reg signed  [7:0]       initstate_temp;
reg [7:0]  initstate;
always @ (*)
begin
    slope = proc_cnt < PROCESS_NUM ?  (inittable[cnt]>>4)*5 - 45  : 0;
    offset = proc_cnt < PROCESS_NUM ?((inittable[cnt]&15)<<3)-16  : 0;

    signed_qp = {1'b0,$signed(gp_qp)};
    product_slope_qp = slope * signed_qp;
    product_slope_qp_temp = $signed(product_slope_qp[14:4]);
    tmp=product_slope_qp_temp + offset ;
    b = 1> tmp ? 1: tmp;
    initstate_temp = b>126  ?  126:b;
    initstate = $unsigned(initstate_temp);
    mps =  proc_cnt < PROCESS_NUM ?  initstate >= 64  : 0;
state = proc_cnt < PROCESS_NUM ? mps ? initstate - 64 : 63 - initstate  : 0;
end
always@(*)
begin
    for(index=0; index < PROCESS_NUM; index=index+1 )
    begin
        inittable[index] = CNU;
    end
    if(gp_slice_type == 2)
    begin //I_slice; initType = 0;
        inittable[Model_CUTransquantBypassFlag] = 154   ;//init_cu_transquant_bypass_flag
        inittable[Model_CUSplitFlag] = 139   ;//init_split_flag
        inittable[Model_CUSplitFlag+1] = 141   ;
        inittable[Model_CUSplitFlag+2] = 157   ;
        inittable[Model_CUPartSize] = 184   ;//init_part_size
        inittable[Model_CUIntraPred] = 184   ;//init_intra_pred_mode
        inittable[Model_CUChromaPred] = 63   ;//init_chroma_pred_mode  HM13.0 only has one!
        inittable[Model_CUChromaPred+1] = 139   ;
        inittable[Model_CUDeltaQp] = 154   ;//init_dqp
        inittable[Model_CUDeltaQp+1] = 154   ;
        inittable[Model_CUDeltaQp+2] = 154   ;
        inittable[Model_CUQtCbf] = 111   ;//init_qt_cbf_luma
        inittable[Model_CUQtCbf+1] = 141   ;
        inittable[Model_CUQtCbf+2] = CNU   ;
        inittable[Model_CUQtCbf+3] = CNU   ;
        inittable[Model_CUQtCbf+4] = CNU   ;
        inittable[Model_CUQtCbf+5] = 94   ;
        inittable[Model_CUQtCbf+6] = 138   ;
        inittable[Model_CUQtCbf+7] = 182   ;
        inittable[Model_CUQtCbf+8] = CNU   ;
        inittable[Model_CUQtCbf+9] = CNU   ;
        inittable[Model_CUCtxLastX] = 110   ;//init_last_x
        inittable[Model_CUCtxLastX+1] = 110   ;
        inittable[Model_CUCtxLastX+2] = 124   ;
        inittable[Model_CUCtxLastX+3] = 125   ;
        inittable[Model_CUCtxLastX+4] = 140   ;
        inittable[Model_CUCtxLastX+5] = 153   ;
        inittable[Model_CUCtxLastX+6] = 125   ;
        inittable[Model_CUCtxLastX+7] = 127   ;
        inittable[Model_CUCtxLastX+8] = 140   ;
        inittable[Model_CUCtxLastX+9] = 109   ;
        inittable[Model_CUCtxLastX+10] = 111   ;
        inittable[Model_CUCtxLastX+11] = 143   ;
        inittable[Model_CUCtxLastX+12] = 127   ;
        inittable[Model_CUCtxLastX+13] = 111   ;
        inittable[Model_CUCtxLastX+14] = 79   ;
        inittable[Model_CUCtxLastX+15] = 108   ;
        inittable[Model_CUCtxLastX+16] = 123   ;
        inittable[Model_CUCtxLastX+17] = 63   ;
        inittable[Model_CUCtxLastX+18] = CNU   ;
        inittable[Model_CUCtxLastX+19] = CNU   ;
        inittable[Model_CUCtxLastX+20] = CNU   ;
        inittable[Model_CUCtxLastX+21] = CNU   ;
        inittable[Model_CUCtxLastX+22] = CNU   ;
        inittable[Model_CUCtxLastX+23] = CNU   ;
        inittable[Model_CUCtxLastX+24] = CNU   ;
        inittable[Model_CUCtxLastX+25] = CNU   ;
        inittable[Model_CUCtxLastX+26] = CNU   ;
        inittable[Model_CUCtxLastX+27] = CNU   ;
        inittable[Model_CUCtxLastX+28] = CNU   ;
        inittable[Model_CUCtxLastX+29] = CNU   ;
        inittable[Model_CUCtxLastY] = 110   ;//init_last_y
        inittable[Model_CUCtxLastY+1] = 110   ;
        inittable[Model_CUCtxLastY+2] = 124   ;
        inittable[Model_CUCtxLastY+3] = 125   ;
        inittable[Model_CUCtxLastY+4] = 140   ;
        inittable[Model_CUCtxLastY+5] = 153   ;
        inittable[Model_CUCtxLastY+6] = 125   ;
        inittable[Model_CUCtxLastY+7] = 127   ;
        inittable[Model_CUCtxLastY+8] = 140   ;
        inittable[Model_CUCtxLastY+9] = 109   ;
        inittable[Model_CUCtxLastY+10] = 111   ;
        inittable[Model_CUCtxLastY+11] = 143   ;
        inittable[Model_CUCtxLastY+12] = 127   ;
        inittable[Model_CUCtxLastY+13] = 111   ;
        inittable[Model_CUCtxLastY+14] = 79   ;
        inittable[Model_CUCtxLastY+15] = 108   ;
        inittable[Model_CUCtxLastY+16] = 123   ;
        inittable[Model_CUCtxLastY+17] = 63   ;
        inittable[Model_CUCtxLastY+18] = CNU   ;
        inittable[Model_CUCtxLastY+19] = CNU   ;
        inittable[Model_CUCtxLastY+20] = CNU   ;
        inittable[Model_CUCtxLastY+21] = CNU   ;
        inittable[Model_CUCtxLastY+22] = CNU   ;
        inittable[Model_CUCtxLastY+23] = CNU   ;
        inittable[Model_CUCtxLastY+24] = CNU   ;
        inittable[Model_CUCtxLastY+25] = CNU   ;
        inittable[Model_CUCtxLastY+26] = CNU   ;
        inittable[Model_CUCtxLastY+27] = CNU   ;
        inittable[Model_CUCtxLastY+28] = CNU   ;
        inittable[Model_CUCtxLastY+29] = CNU   ;
        inittable[Model_CUSigCoeffGroup] = 91   ;//init_sig_cg_flag
        inittable[Model_CUSigCoeffGroup+1] = 171   ;
        inittable[Model_CUSigCoeffGroup+2] = 134   ;
        inittable[Model_CUSigCoeffGroup+3] = 141   ;
        inittable[Model_CUSig] = 111   ;//init_sig_flag
        inittable[Model_CUSig+1] = 111   ;
        inittable[Model_CUSig+2] = 125   ;
        inittable[Model_CUSig+3] = 110   ;
        inittable[Model_CUSig+4] = 110   ;
        inittable[Model_CUSig+5] = 94   ;
        inittable[Model_CUSig+6] = 124   ;
        inittable[Model_CUSig+7] = 108   ;
        inittable[Model_CUSig+8] = 124   ;
        inittable[Model_CUSig+9] = 107   ;
        inittable[Model_CUSig+10] = 125   ;
        inittable[Model_CUSig+11] = 141   ;
        inittable[Model_CUSig+12] = 179   ;
        inittable[Model_CUSig+13] = 153   ;
        inittable[Model_CUSig+14] = 125   ;
        inittable[Model_CUSig+15] = 107   ;
        inittable[Model_CUSig+16] = 125   ;
        inittable[Model_CUSig+17] = 141   ;
        inittable[Model_CUSig+18] = 179   ;
        inittable[Model_CUSig+19] = 153   ;
        inittable[Model_CUSig+20] = 125   ;
        inittable[Model_CUSig+21] = 107   ;
        inittable[Model_CUSig+22] = 125   ;
        inittable[Model_CUSig+23] = 141   ;
        inittable[Model_CUSig+24] = 179   ;
        inittable[Model_CUSig+25] = 153   ;
        inittable[Model_CUSig+26] = 125   ;
        inittable[Model_CUSig+27] = 140   ;
        inittable[Model_CUSig+28] = 139   ;
        inittable[Model_CUSig+29] = 182   ;
        inittable[Model_CUSig+30] = 182   ;
        inittable[Model_CUSig+31] = 152   ;
        inittable[Model_CUSig+32] = 136   ;
        inittable[Model_CUSig+33] = 152   ;
        inittable[Model_CUSig+34] = 136   ;
        inittable[Model_CUSig+35] = 153   ;
        inittable[Model_CUSig+36] = 136   ;
        inittable[Model_CUSig+37] = 139   ;
        inittable[Model_CUSig+38] = 111   ;
        inittable[Model_CUSig+39] = 136   ;
        inittable[Model_CUSig+40] = 139   ;
        inittable[Model_CUSig+41] = 111   ;
        inittable[Model_CUOne] = 140   ;//init_one_flag
        inittable[Model_CUOne+1] = 92   ;
        inittable[Model_CUOne+2] = 137   ;
        inittable[Model_CUOne+3] = 138   ;
        inittable[Model_CUOne+4] = 140   ;
        inittable[Model_CUOne+5] = 152   ;
        inittable[Model_CUOne+6] = 138   ;
        inittable[Model_CUOne+7] = 139   ;
        inittable[Model_CUOne+8] = 153   ;
        inittable[Model_CUOne+9] = 74   ;
        inittable[Model_CUOne+10] = 149   ;
        inittable[Model_CUOne+11] = 92   ;
        inittable[Model_CUOne+12] = 139   ;
        inittable[Model_CUOne+13] = 107   ;
        inittable[Model_CUOne+14] = 122   ;
        inittable[Model_CUOne+15] = 152   ;
        inittable[Model_CUOne+16] = 140   ;
        inittable[Model_CUOne+17] = 179   ;
        inittable[Model_CUOne+18] = 166   ;
        inittable[Model_CUOne+19] = 182   ;
        inittable[Model_CUOne+20] = 140   ;
        inittable[Model_CUOne+21] = 227   ;
        inittable[Model_CUOne+22] = 122   ;
        inittable[Model_CUOne+23] = 197   ;
        inittable[Model_CUAbs] = 138   ;//init_abs_flag
        inittable[Model_CUAbs+1] = 153   ;
        inittable[Model_CUAbs+2] = 136   ;
        inittable[Model_CUAbs+3] = 167   ;
        inittable[Model_CUAbs+4] = 152   ;
        inittable[Model_CUAbs+5] = 152   ;
        inittable[Model_SaoMerge] = 153   ;//init_sao_merge_flag
        inittable[Model_SaoTypeIdx] = 200   ;//init_sao_type_idx
        inittable[Model_CUTransSubdivFlag] = 153   ;//init_trans_subdiv_flag
        inittable[Model_CUTransSubdivFlag+1] = 138   ;
        inittable[Model_CUTransSubdivFlag+2] = 138   ;
        inittable[Model_TransformSkip] = 139   ;//init_transformskip_flag
        inittable[Model_TransformSkip+1] = 139   ;
    end
    else if((gp_slice_type==0 && gp_cabac_init_flag==0) || (gp_slice_type==1 && gp_cabac_init_flag==1))
    begin //initType == 2
        inittable[Model_CUTransquantBypassFlag] = 154   ;//init_cu_transquant_bypass_flag
        inittable[Model_CUSplitFlag] = 107 ;//init_split_flag
        inittable[Model_CUSplitFlag+1] = 139   ;
        inittable[Model_CUSplitFlag+2] = 126   ;
        inittable[Model_CUSkipFlag] = 197   ;//init_skip_flag
        inittable[Model_CUSkipFlag+1] = 185   ;
        inittable[Model_CUSkipFlag+2] = 201   ;
        inittable[Model_CUMergeFlagExt] = 154   ;//init_merge_flag_ext
        inittable[Model_CUMergeIdxExt] = 137   ;//init_merge_idx_ext
        inittable[Model_CUPartSize] = 154   ;//init_part_size
        inittable[Model_CUPartSize+1] = 139   ;
        inittable[Model_CUPartSize+2] = 154   ;
        inittable[Model_CUPartSize+3] = 154   ;
        inittable[Model_CUAMP] = 154   ;//init_cu_amp_pos
        inittable[Model_CUPredMode] = 134   ;//init_pred_mode
        inittable[Model_CUIntraPred] = 183   ;//init_intra_pred_mode
        inittable[Model_CUChromaPred] = 152   ;//init_chroma_pred_mode
        inittable[Model_CUChromaPred+1] = 139   ;
        inittable[Model_CUInterDir] = 95   ;//init_inter_dir
        inittable[Model_CUInterDir+1] = 79   ;
        inittable[Model_CUInterDir+2] = 63   ;
        inittable[Model_CUInterDir+3] = 31   ;
        inittable[Model_CUInterDir+4] = 31   ;
        inittable[Model_CUMvd] = 169   ;//init_mvd
        inittable[Model_CUMvd+1] = 198   ;
        inittable[Model_CURefPic] = 153   ;//init_ref_pic
        inittable[Model_CURefPic+1] = 153   ;
        inittable[Model_CUDeltaQp] = 154   ;//init_dqp
        inittable[Model_CUDeltaQp+1] = 154   ;
        inittable[Model_CUDeltaQp+2] = 154   ;
        inittable[Model_CUQtCbf] = 153   ;//init_qt_cbf
        inittable[Model_CUQtCbf+1] = 111   ;
        inittable[Model_CUQtCbf+2] = CNU   ;
        inittable[Model_CUQtCbf+3] = CNU   ;
        inittable[Model_CUQtCbf+4] = CNU   ;
        inittable[Model_CUQtCbf+5] = 149   ;
        inittable[Model_CUQtCbf+6] = 92   ;
        inittable[Model_CUQtCbf+7] = 167   ;
        inittable[Model_CUQtCbf+8] = CNU   ;
        inittable[Model_CUQtCbf+9] = CNU   ;
        inittable[Model_CUQtRootCbf] = 79   ;//init_qt_root_cbf
        inittable[Model_CUCtxLastX] = 125   ;//init_last_x
        inittable[Model_CUCtxLastX+1] = 110   ;
        inittable[Model_CUCtxLastX+2] = 124   ;
        inittable[Model_CUCtxLastX+3] = 110   ;
        inittable[Model_CUCtxLastX+4] = 95   ;
        inittable[Model_CUCtxLastX+5] = 94   ;
        inittable[Model_CUCtxLastX+6] = 125   ;
        inittable[Model_CUCtxLastX+7] = 111   ;
        inittable[Model_CUCtxLastX+8] = 111   ;
        inittable[Model_CUCtxLastX+9] = 79   ;
        inittable[Model_CUCtxLastX+10] = 125   ;
        inittable[Model_CUCtxLastX+11] = 126   ;
        inittable[Model_CUCtxLastX+12] = 111   ;
        inittable[Model_CUCtxLastX+13] = 111   ;
        inittable[Model_CUCtxLastX+14] = 79   ;
        inittable[Model_CUCtxLastX+15] = 108   ;
        inittable[Model_CUCtxLastX+16] = 123   ;
        inittable[Model_CUCtxLastX+17] = 93   ;
        inittable[Model_CUCtxLastX+18] = CNU   ;
        inittable[Model_CUCtxLastX+19] = CNU   ;
        inittable[Model_CUCtxLastX+20] = CNU   ;
        inittable[Model_CUCtxLastX+21] = CNU   ;
        inittable[Model_CUCtxLastX+22] = CNU   ;
        inittable[Model_CUCtxLastX+23] = CNU   ;
        inittable[Model_CUCtxLastX+24] = CNU   ;
        inittable[Model_CUCtxLastX+25] = CNU   ;
        inittable[Model_CUCtxLastX+26] = CNU   ;
        inittable[Model_CUCtxLastX+27] = CNU   ;
        inittable[Model_CUCtxLastX+28] = CNU   ;
        inittable[Model_CUCtxLastX+29] = CNU   ;
        inittable[Model_CUCtxLastY] = 125   ;//init_last_y
        inittable[Model_CUCtxLastY+1] = 110   ;
        inittable[Model_CUCtxLastY+2] = 124   ;
        inittable[Model_CUCtxLastY+3] = 110   ;
        inittable[Model_CUCtxLastY+4] = 95   ;
        inittable[Model_CUCtxLastY+5] = 94   ;
        inittable[Model_CUCtxLastY+6] = 125   ;
        inittable[Model_CUCtxLastY+7] = 111   ;
        inittable[Model_CUCtxLastY+8] = 111   ;
        inittable[Model_CUCtxLastY+9] = 79   ;
        inittable[Model_CUCtxLastY+10] = 125   ;
        inittable[Model_CUCtxLastY+11] = 126   ;
        inittable[Model_CUCtxLastY+12] = 111   ;
        inittable[Model_CUCtxLastY+13] = 111   ;
        inittable[Model_CUCtxLastY+14] = 79   ;
        inittable[Model_CUCtxLastY+15] = 108   ;
        inittable[Model_CUCtxLastY+16] = 123   ;
        inittable[Model_CUCtxLastY+17] = 93   ;
        inittable[Model_CUCtxLastY+18] = CNU   ;
        inittable[Model_CUCtxLastY+19] = CNU   ;
        inittable[Model_CUCtxLastY+20] = CNU   ;
        inittable[Model_CUCtxLastY+21] = CNU   ;
        inittable[Model_CUCtxLastY+22] = CNU   ;
        inittable[Model_CUCtxLastY+23] = CNU   ;
        inittable[Model_CUCtxLastY+24] = CNU   ;
        inittable[Model_CUCtxLastY+25] = CNU   ;
        inittable[Model_CUCtxLastY+26] = CNU   ;
        inittable[Model_CUCtxLastY+27] = CNU   ;
        inittable[Model_CUCtxLastY+28] = CNU   ;
        inittable[Model_CUCtxLastY+29] = CNU   ;
        inittable[Model_CUSigCoeffGroup] = 121   ;//init_sig_cg_flag
        inittable[Model_CUSigCoeffGroup+1] = 140   ;
        inittable[Model_CUSigCoeffGroup+2] = 61   ;
        inittable[Model_CUSigCoeffGroup+3] = 154   ;
        inittable[Model_CUSig] = 170   ;//init_sig_flag
        inittable[Model_CUSig+1] = 154   ;
        inittable[Model_CUSig+2] = 139   ;
        inittable[Model_CUSig+3] = 153   ;
        inittable[Model_CUSig+4] = 139   ;
        inittable[Model_CUSig+5] = 123   ;
        inittable[Model_CUSig+6] = 123   ;
        inittable[Model_CUSig+7] = 63   ;
        inittable[Model_CUSig+8] = 124   ;
        inittable[Model_CUSig+9] = 166   ;
        inittable[Model_CUSig+10] = 183   ;
        inittable[Model_CUSig+11] = 140   ;
        inittable[Model_CUSig+12] = 136   ;
        inittable[Model_CUSig+13] = 153   ;
        inittable[Model_CUSig+14] = 154   ;
        inittable[Model_CUSig+15] = 166   ;
        inittable[Model_CUSig+16] = 183   ;
        inittable[Model_CUSig+17] = 140   ;
        inittable[Model_CUSig+18] = 136   ;
        inittable[Model_CUSig+19] = 153   ;
        inittable[Model_CUSig+20] = 154   ;
        inittable[Model_CUSig+21] = 166   ;
        inittable[Model_CUSig+22] = 183   ;
        inittable[Model_CUSig+23] = 140   ;
        inittable[Model_CUSig+24] = 136   ;
        inittable[Model_CUSig+25] = 153   ;
        inittable[Model_CUSig+26] = 154   ;
        inittable[Model_CUSig+27] = 170   ;
        inittable[Model_CUSig+28] = 153   ;
        inittable[Model_CUSig+29] = 138   ;
        inittable[Model_CUSig+30] = 138   ;
        inittable[Model_CUSig+31] = 122   ;
        inittable[Model_CUSig+32] = 121   ;
        inittable[Model_CUSig+33] = 122   ;
        inittable[Model_CUSig+34] = 121   ;
        inittable[Model_CUSig+35] = 167   ;
        inittable[Model_CUSig+36] = 151   ;
        inittable[Model_CUSig+37] = 183   ;
        inittable[Model_CUSig+38] = 140   ;
        inittable[Model_CUSig+39] = 151   ;
        inittable[Model_CUSig+40] = 183   ;
        inittable[Model_CUSig+41] = 140   ;
        inittable[Model_CUOne] = 154   ;//init_one_flag
        inittable[Model_CUOne+1] = 196   ;
        inittable[Model_CUOne+2] = 167   ;
        inittable[Model_CUOne+3] = 167   ;
        inittable[Model_CUOne+4] = 154   ;
        inittable[Model_CUOne+5] = 152   ;
        inittable[Model_CUOne+6] = 167   ;
        inittable[Model_CUOne+7] = 182   ;
        inittable[Model_CUOne+8] = 182   ;
        inittable[Model_CUOne+9] = 134   ;
        inittable[Model_CUOne+10] = 149   ;
        inittable[Model_CUOne+11] = 136   ;
        inittable[Model_CUOne+12] = 153   ;
        inittable[Model_CUOne+13] = 121   ;
        inittable[Model_CUOne+14] = 136   ;
        inittable[Model_CUOne+15] = 122   ;
        inittable[Model_CUOne+16] = 169   ;
        inittable[Model_CUOne+17] = 208   ;
        inittable[Model_CUOne+18] = 166   ;
        inittable[Model_CUOne+19] = 167   ;
        inittable[Model_CUOne+20] = 154   ;
        inittable[Model_CUOne+21] = 152   ;
        inittable[Model_CUOne+22] = 167   ;
        inittable[Model_CUOne+23] = 182   ;
        inittable[Model_CUAbs] = 107   ;    //init_abs_flag
        inittable[Model_CUAbs+1] = 167   ;
        inittable[Model_CUAbs+2] = 91   ;
        inittable[Model_CUAbs+3] = 107   ;
        inittable[Model_CUAbs+4] = 107   ;
        inittable[Model_CUAbs+5] = 167   ;
        inittable[Model_MVPIdx] = 168   ;//init_mvp_idx
        inittable[Model_MVPIdx+1] = CNU   ;
        inittable[Model_SaoMerge] = 153   ;//init_sao_merge_flag
        inittable[Model_SaoTypeIdx] = 160   ;//init_sao_type_idx
        inittable[Model_CUTransSubdivFlag] = 224   ;//init_trans_subdiv_flag
        inittable[Model_CUTransSubdivFlag+1] = 167   ;
        inittable[Model_CUTransSubdivFlag+2] = 122   ;
        inittable[Model_TransformSkip] = 139   ;//init_transformskip_flag
        inittable[Model_TransformSkip+1] = 139   ;
    end
    else if((gp_slice_type==1&&gp_cabac_init_flag==0) || (gp_slice_type==0 && gp_cabac_init_flag==1) )
    begin //(P_slicee && flag==0) || (B_slice && flag==1) initType = 1
        inittable[Model_CUTransquantBypassFlag] = 154;  //init_cu_transquant_bypass_flag
        inittable[Model_CUSplitFlag] = 107;  //init_split_flag
        inittable[Model_CUSplitFlag+1] = 139;
        inittable[Model_CUSplitFlag+2] = 126;
        inittable[Model_CUSkipFlag] = 197   ;//init_skip_flag
        inittable[Model_CUSkipFlag+1] = 185   ;
        inittable[Model_CUSkipFlag+2] = 201   ;
        inittable[Model_CUMergeFlagExt] = 110   ;//init_merge_flag_ext
        inittable[Model_CUMergeIdxExt] = 122   ;//init_merge_idx_ext
        inittable[Model_CUPartSize] = 154   ;//init_part_size
        inittable[Model_CUPartSize+1] = 139   ;
        inittable[Model_CUPartSize+2] = 154   ;
        inittable[Model_CUPartSize+3] = 154   ;
        inittable[Model_CUAMP] = 154   ;//init_cu_amp_pos
        inittable[Model_CUPredMode] = 149   ;//init_pred_mode
        inittable[Model_CUIntraPred] = 154   ;//init_intra_pred_mode
        inittable[Model_CUChromaPred] = 152   ;//init_chroma_pred_mode
        inittable[Model_CUChromaPred+1] = 139   ;
        inittable[Model_CUInterDir] = 95   ;//init_inter_dir
        inittable[Model_CUInterDir+1] = 79   ;
        inittable[Model_CUInterDir+2] = 63   ;
        inittable[Model_CUInterDir+3] = 31   ;
        inittable[Model_CUInterDir+4] = 31   ;
        inittable[Model_CUMvd] = 140   ;//init_mvd
        inittable[Model_CUMvd+1] = 198   ;
        inittable[Model_CURefPic] = 153   ;//init_ref_pic
        inittable[Model_CURefPic+1] = 153   ;
        inittable[Model_CUDeltaQp] = 154   ;//init_dqp
        inittable[Model_CUDeltaQp+1] = 154   ;
        inittable[Model_CUDeltaQp+2] = 154   ;
        inittable[Model_CUQtCbf] = 153   ;//init_qt_cbf
        inittable[Model_CUQtCbf+1] = 111   ;
        inittable[Model_CUQtCbf+2] = CNU   ;
        inittable[Model_CUQtCbf+3] = CNU   ;
        inittable[Model_CUQtCbf+4] = CNU   ;
        inittable[Model_CUQtCbf+5] = 149   ;
        inittable[Model_CUQtCbf+6] = 107   ;
        inittable[Model_CUQtCbf+7] = 167   ;
        inittable[Model_CUQtCbf+8] = CNU  ;
        inittable[Model_CUQtCbf+9] = CNU   ;
        inittable[Model_CUQtRootCbf] = 79   ;//init_qt_root_cbf
        inittable[Model_CUCtxLastX] = 125   ;//init_last_x
        inittable[Model_CUCtxLastX+1] = 110   ;
        inittable[Model_CUCtxLastX+2] = 94   ;
        inittable[Model_CUCtxLastX+3] = 110   ;
        inittable[Model_CUCtxLastX+4] = 95   ;
        inittable[Model_CUCtxLastX+5] = 79   ;
        inittable[Model_CUCtxLastX+6] = 125   ;
        inittable[Model_CUCtxLastX+7] = 111   ;
        inittable[Model_CUCtxLastX+8] = 110   ;
        inittable[Model_CUCtxLastX+9] = 78   ;
        inittable[Model_CUCtxLastX+10] = 110   ;
        inittable[Model_CUCtxLastX+11] = 111   ;
        inittable[Model_CUCtxLastX+12] = 111   ;
        inittable[Model_CUCtxLastX+13] = 95   ;
        inittable[Model_CUCtxLastX+14] = 94   ;
        inittable[Model_CUCtxLastX+15] = 108   ;
        inittable[Model_CUCtxLastX+16] = 123   ;
        inittable[Model_CUCtxLastX+17] = 108   ;
        inittable[Model_CUCtxLastX+18] = CNU    ;
        inittable[Model_CUCtxLastX+19] = CNU    ;
        inittable[Model_CUCtxLastX+20] = CNU    ;
        inittable[Model_CUCtxLastX+21] = CNU    ;
        inittable[Model_CUCtxLastX+22] = CNU    ;
        inittable[Model_CUCtxLastX+23] = CNU    ;
        inittable[Model_CUCtxLastX+24] = CNU    ;
        inittable[Model_CUCtxLastX+25] = CNU    ;
        inittable[Model_CUCtxLastX+26] = CNU    ;
        inittable[Model_CUCtxLastX+27] = CNU    ;
        inittable[Model_CUCtxLastX+28] = CNU    ;
        inittable[Model_CUCtxLastX+29] = CNU    ;
        inittable[Model_CUCtxLastY] = 125   ;//init_last_y
        inittable[Model_CUCtxLastY+1] = 110   ;
        inittable[Model_CUCtxLastY+2] = 94   ;
        inittable[Model_CUCtxLastY+3] = 110   ;
        inittable[Model_CUCtxLastY+4] = 95   ;
        inittable[Model_CUCtxLastY+5] = 79   ;
        inittable[Model_CUCtxLastY+6] = 125   ;
        inittable[Model_CUCtxLastY+7] = 111   ;
        inittable[Model_CUCtxLastY+8] = 110   ;
        inittable[Model_CUCtxLastY+9] = 78   ;
        inittable[Model_CUCtxLastY+10] = 110   ;
        inittable[Model_CUCtxLastY+11] = 111   ;
        inittable[Model_CUCtxLastY+12] = 111   ;
        inittable[Model_CUCtxLastY+13] = 95   ;
        inittable[Model_CUCtxLastY+14] = 94   ;
        inittable[Model_CUCtxLastY+15] = 108   ;
        inittable[Model_CUCtxLastY+16] = 123   ;
        inittable[Model_CUCtxLastY+17] = 108   ;
        inittable[Model_CUCtxLastY+18] = CNU    ;
        inittable[Model_CUCtxLastY+19] = CNU    ;
        inittable[Model_CUCtxLastY+20] = CNU    ;
        inittable[Model_CUCtxLastY+21] = CNU    ;
        inittable[Model_CUCtxLastY+22] = CNU    ;
        inittable[Model_CUCtxLastY+23] = CNU    ;
        inittable[Model_CUCtxLastY+24] = CNU    ;
        inittable[Model_CUCtxLastY+25] = CNU    ;
        inittable[Model_CUCtxLastY+26] = CNU    ;
        inittable[Model_CUCtxLastY+27] = CNU    ;
        inittable[Model_CUCtxLastY+28] = CNU    ;
        inittable[Model_CUCtxLastY+29] = CNU    ;
        inittable[Model_CUSigCoeffGroup] = 121   ;//init_sig_cg_flag
        inittable[Model_CUSigCoeffGroup+1] = 140   ;
        inittable[Model_CUSigCoeffGroup+2] = 61   ;
        inittable[Model_CUSigCoeffGroup+3] = 154   ;
        inittable[Model_CUSig] = 155   ;//init_sig_flag
        inittable[Model_CUSig+1] = 154   ;
        inittable[Model_CUSig+2] = 139   ;
        inittable[Model_CUSig+3] = 153   ;
        inittable[Model_CUSig+4] = 139   ;
        inittable[Model_CUSig+5] = 123   ;
        inittable[Model_CUSig+6] = 123   ;
        inittable[Model_CUSig+7] = 63   ;
        inittable[Model_CUSig+8] = 153   ;
        inittable[Model_CUSig+9] = 166   ;
        inittable[Model_CUSig+10] = 183   ;
        inittable[Model_CUSig+11] = 140   ;
        inittable[Model_CUSig+12] = 136   ;
        inittable[Model_CUSig+13] = 153   ;
        inittable[Model_CUSig+14] = 154   ;
        inittable[Model_CUSig+15] = 166   ;
        inittable[Model_CUSig+16] = 183   ;
        inittable[Model_CUSig+17] = 140   ;
        inittable[Model_CUSig+18] = 136   ;
        inittable[Model_CUSig+19] = 153   ;
        inittable[Model_CUSig+20] = 154   ;
        inittable[Model_CUSig+21] = 166   ;
        inittable[Model_CUSig+22] = 183   ;
        inittable[Model_CUSig+23] = 140   ;
        inittable[Model_CUSig+24] = 136   ;
        inittable[Model_CUSig+25] = 153   ;
        inittable[Model_CUSig+26] = 154   ;
        inittable[Model_CUSig+27] = 170   ;
        inittable[Model_CUSig+28] = 153   ;
        inittable[Model_CUSig+29] = 123   ;
        inittable[Model_CUSig+30] = 123   ;
        inittable[Model_CUSig+31] = 107   ;
        inittable[Model_CUSig+32] = 121   ;
        inittable[Model_CUSig+33] = 107   ;
        inittable[Model_CUSig+34] = 121   ;
        inittable[Model_CUSig+35] = 167   ;
        inittable[Model_CUSig+36] = 151   ;
        inittable[Model_CUSig+37] = 183   ;
        inittable[Model_CUSig+38] = 140   ;
        inittable[Model_CUSig+39] = 151   ;
        inittable[Model_CUSig+40] = 183   ;
        inittable[Model_CUSig+41] = 140   ;
        inittable[Model_CUOne] = 154   ;//init_one_flag
        inittable[Model_CUOne+1] = 196   ;
        inittable[Model_CUOne+2] = 196   ;
        inittable[Model_CUOne+3] = 167   ;
        inittable[Model_CUOne+4] = 154   ;
        inittable[Model_CUOne+5] = 152   ;
        inittable[Model_CUOne+6] = 167   ;
        inittable[Model_CUOne+7] = 182   ;
        inittable[Model_CUOne+8] = 182   ;
        inittable[Model_CUOne+9] = 134   ;
        inittable[Model_CUOne+10] = 149   ;
        inittable[Model_CUOne+11] = 136   ;
        inittable[Model_CUOne+12] = 153   ;
        inittable[Model_CUOne+13] = 121   ;
        inittable[Model_CUOne+14] = 136   ;
        inittable[Model_CUOne+15] = 137   ;
        inittable[Model_CUOne+16] = 169   ;
        inittable[Model_CUOne+17] = 194   ;
        inittable[Model_CUOne+18] = 166   ;
        inittable[Model_CUOne+19] = 167   ;
        inittable[Model_CUOne+20] = 154   ;
        inittable[Model_CUOne+21] = 167   ;
        inittable[Model_CUOne+22] = 137   ;
        inittable[Model_CUOne+23] = 182   ;
        inittable[Model_CUAbs] = 107   ;//init_abs_flag
        inittable[Model_CUAbs+1] = 167   ;
        inittable[Model_CUAbs+2] = 91   ;
        inittable[Model_CUAbs+3] = 122   ;
        inittable[Model_CUAbs+4] = 107   ;
        inittable[Model_CUAbs+5] = 167   ;
        inittable[Model_MVPIdx] = 168   ;//init_mvp_idx
        inittable[Model_MVPIdx+1] = CNU   ;
        inittable[Model_SaoMerge] = 153   ;//init_sao_merge_flag
        inittable[Model_SaoTypeIdx] = 185   ;//init_sao_type_idx
        inittable[Model_CUTransSubdivFlag] = 124   ;//init_trans_subdiv_flag
        inittable[Model_CUTransSubdivFlag+1] = 138   ;
        inittable[Model_CUTransSubdivFlag+2] = 94   ;
        inittable[Model_TransformSkip] = 139   ;//init_transformskip_flag
        inittable[Model_TransformSkip+1] = 139   ;
    end
end
endmodule

