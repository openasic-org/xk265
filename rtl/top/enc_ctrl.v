//-------------------------------------------------------------------
//
//  COPYRIGHT (C) 2016, VIPcore Group, Fudan University
//
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//
//  VIPcore       : http://soc.fudan.edu.cn/vip
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn
//
//-------------------------------------------------------------------
//
//  Filename      : sys_ctrl.v
//  Author        : Huang Leilei
//  Created       : 2016-03-20
//  Description   : system controller of enc_core and fetch
//
//-------------------------------------------------------------------
//
//  Modified      : 2018-01-26 by Yibo Fan
//  Description   :
//  Modified      : 2016-03-22 by HLL
//  Description   : ena, x & y for fetch added
//  Modified      : 2016-03-22 by HLL
//  Description   : pipeline stages modified
//  Modified      : 2018-04-22 by TANG
//  Description   : pipeline modified
//
//-------------------------------------------------------------------

`include "enc_defines.v"

module enc_ctrl(
  // global
  clk                      ,
  rstn                     ,
  // sys_if
  sys_start_i              ,
  sys_type_i               ,
  sys_ctu_all_x_i          ,
  sys_ctu_all_y_i          ,
  sys_done_o               ,
  // start_if
  enc_start_o              ,
  // done_if
  fetch_done_i             ,
  prei_done_i             ,
  posi_done_i             ,
  ime_done_i               ,
  fme_done_i               ,
  rec_done_i               ,
  db_done_i                ,
  ec_done_i                ,
  enc_done_r               ,
  // start for enc_core
  // pre_l_start_o            ,
  prei_start_o            ,
  posi_start_o            ,
  ime_start_o              ,
  fme_start_o              ,
  rec_start_o              ,
  db_start_o               ,
  ec_start_o               ,
  store_db_start_o         ,
  // x & y for enc_core
  // pre_l_x_o                ,
  // pre_l_y_o                ,
  prei_x_o                ,
  prei_y_o                ,
  posi_x_o                ,
  posi_y_o                ,
  ime_x_o                  ,
  ime_y_o                  ,
  fme_x_o                  ,
  fme_y_o                  ,
  rec_x_o                  ,
  rec_y_o                  ,
  db_x_o                   ,
  db_y_o                   ,
  ec_x_o                   ,
  ec_y_o                   ,
  store_db_x_o             ,
  store_db_y_o             ,
  // ena for fetch
  load_cur_luma_ena_o      ,
  load_ref_luma_ena_o      ,
  load_cur_chroma_ena_o    ,
  load_ref_chroma_ena_o    ,
  load_db_luma_ena_o       ,
  load_db_chroma_ena_o     ,
  store_db_luma_ena_o      ,
  store_db_chroma_ena_o    ,
  // x & y for fetch
  load_cur_luma_x_o        ,
  load_cur_luma_y_o        ,
  load_ref_luma_x_o        ,
  load_ref_luma_y_o        ,
  load_cur_chroma_x_o      ,
  load_cur_chroma_y_o      ,
  load_ref_chroma_x_o      ,
  load_ref_chroma_y_o      ,
  load_db_luma_x_o         ,
  load_db_luma_y_o         ,
  load_db_chroma_x_o       ,
  load_db_chroma_y_o       ,
  store_db_luma_x_o        ,
  store_db_luma_y_o        ,
  store_db_chroma_x_o      ,
  store_db_chroma_y_o
  );


//*** PARAMETER ****************************************************************

  localparam                         IDLE  = 0+00          ,
                                     S0    = 1+00          ,
                                     S1    = 1+01          ,
                                     S2    = 1+02          ,
                                     S3    = 1+03          ,
                                     S4    = 1+04          ,
                                     S5    = 1+05          ,
                                     S6    = 1+06          ,
                                     S7    = 1+07          ,
                                     S8    = 1+08          ,
                                     S9    = 1+09          ,
                                     SA    = 1+10          ;

  localparam                         INTRA = 0             ,
                                     INTER = 1             ;


//*** INPUT/OUTPUT DECLARATION *************************************************

  // global
  input                              clk                   ;
  input                              rstn                 ;
  // sys_if
  input                              sys_start_i           ;
  input                              sys_type_i            ;
  input      [`PIC_X_WIDTH-1 : 0]    sys_ctu_all_x_i         ;
  input      [`PIC_Y_WIDTH-1 : 0]    sys_ctu_all_y_i         ;
  output                             sys_done_o            ;
  // start_if
  output reg                         enc_start_o           ;
  // done_if
  input                              fetch_done_i          ;
  input                              prei_done_i          ;
  input                              posi_done_i          ;
  input                              ime_done_i            ;
  input                              fme_done_i            ;
  input                              rec_done_i             ;
  input                              db_done_i             ;
  input                              ec_done_i             ;
  output                             enc_done_r            ;
  // start for enc_core
  output reg                         prei_start_o         ;
  output reg                         posi_start_o         ;
  output reg                         ime_start_o           ;
  output reg                         fme_start_o           ;
  output reg                         rec_start_o            ;
  output reg                         db_start_o            ;
  output reg                         ec_start_o            ;
  output reg                         store_db_start_o      ;
  // x & y for enc_core
  output reg [`PIC_X_WIDTH-1 : 0]    prei_x_o             ;
  output reg [`PIC_Y_WIDTH-1 : 0]    prei_y_o             ;
  output reg [`PIC_X_WIDTH-1 : 0]    posi_x_o             ;
  output reg [`PIC_Y_WIDTH-1 : 0]    posi_y_o             ;
  output reg [`PIC_X_WIDTH-1 : 0]    ime_x_o               ;
  output reg [`PIC_Y_WIDTH-1 : 0]    ime_y_o               ;
  output reg [`PIC_X_WIDTH-1 : 0]    fme_x_o               ;
  output reg [`PIC_Y_WIDTH-1 : 0]    fme_y_o               ;
  output reg [`PIC_X_WIDTH-1 : 0]    rec_x_o                ;
  output reg [`PIC_Y_WIDTH-1 : 0]    rec_y_o                ;
  output reg [`PIC_X_WIDTH-1 : 0]    db_x_o                ;
  output reg [`PIC_Y_WIDTH-1 : 0]    db_y_o                ;
  output reg [`PIC_X_WIDTH-1 : 0]    ec_x_o                ;
  output reg [`PIC_Y_WIDTH-1 : 0]    ec_y_o                ;
  output reg [`PIC_X_WIDTH-1 : 0]    store_db_x_o          ;
  output reg [`PIC_Y_WIDTH-1 : 0]    store_db_y_o          ;
  // ena for fetch
  output reg                         load_cur_luma_ena_o   ;
  output reg                         load_ref_luma_ena_o   ;
  output reg                         load_cur_chroma_ena_o ;
  output reg                         load_ref_chroma_ena_o ;
  output reg                         load_db_luma_ena_o    ;
  output reg                         load_db_chroma_ena_o  ;
  output reg                         store_db_luma_ena_o   ;
  output reg                         store_db_chroma_ena_o ;
  // x & y for fetch
  output reg [`PIC_X_WIDTH-1 : 0]    load_cur_luma_x_o     ;
  output reg [`PIC_Y_WIDTH-1 : 0]    load_cur_luma_y_o     ;
  output reg [`PIC_X_WIDTH-1 : 0]    load_ref_luma_x_o     ;
  output reg [`PIC_Y_WIDTH-1 : 0]    load_ref_luma_y_o     ;
  output reg [`PIC_X_WIDTH-1 : 0]    load_cur_chroma_x_o   ;
  output reg [`PIC_Y_WIDTH-1 : 0]    load_cur_chroma_y_o   ;
  output reg [`PIC_X_WIDTH-1 : 0]    load_ref_chroma_x_o   ;
  output reg [`PIC_Y_WIDTH-1 : 0]    load_ref_chroma_y_o   ;
  output reg [`PIC_X_WIDTH-1 : 0]    load_db_luma_x_o      ;
  output reg [`PIC_Y_WIDTH-1 : 0]    load_db_luma_y_o      ;
  output reg [`PIC_X_WIDTH-1 : 0]    load_db_chroma_x_o    ;
  output reg [`PIC_Y_WIDTH-1 : 0]    load_db_chroma_y_o    ;
  output reg [`PIC_X_WIDTH-1 : 0]    store_db_luma_x_o     ;
  output reg [`PIC_Y_WIDTH-1 : 0]    store_db_luma_y_o     ;
  output reg [`PIC_X_WIDTH-1 : 0]    store_db_chroma_x_o   ;
  output reg [`PIC_Y_WIDTH-1 : 0]    store_db_chroma_y_o   ;


//*** WIRE/REG DECLARATION *****************************************************

  // fsm
  reg        [3              : 0]    nxt_state             ;
  reg        [3              : 0]    cur_state             ;
  // ena
  reg                                pre_l_ena             ;
  wire                               prei_ena              ;
  wire                               posi_ena              ;
  wire                               ime_ena               ;
  wire                               fme_ena               ;
  reg                                rec_ena               ;
  reg                                db_ena                ;
  reg                                ec_ena                ;
  reg                                store_db_ena          ;
  reg                                stg_1_ena             ;
  reg                                stg_2_ena             ;
  // flg
  reg                                fetch_flg             ;
  reg                                prei_flg              ;
  reg                                posi_flg              ;
  reg                                ime_flg               ;
  reg                                fme_flg               ;
  reg                                rec_flg               ;
  reg                                db_flg                ;
  reg                                ec_flg                ;
  wire                               stg_1_flg             ;
  wire                               stg_2_flg             ;
  // enc
  reg                                enc_start_w           ;
  reg                                enc_done_r            ;

  reg [`PIC_X_WIDTH-1 : 0]           pre_l_y_o             ;
  reg [`PIC_Y_WIDTH-1 : 0]           pre_l_x_o             ; 
  reg                                pre_l_start_o         ;

//*** MAIN BODY ****************************************************************

//--- GLOBAL ---------------------------

  assign sys_done_o = cur_state==SA && nxt_state == IDLE ;

  always @(*) begin
    if( cur_state==IDLE )
      enc_start_w = sys_start_i ;
    else if( cur_state == SA )
      enc_start_w = 0 ;
    else begin
      enc_start_w = enc_done_r ;
    end
  end

  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      enc_start_o <= 0 ;
    else begin
      enc_start_o <= enc_start_w ;
    end
  end

//--- FSM ------------------------------
  // cur state
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
      cur_state <= IDLE ;
    else begin
      cur_state <= nxt_state ;
    end
  end

  // nxt state
  always @(*) begin
                                 nxt_state = IDLE ;
    //if( sys_type_i==INTRA )
      case( cur_state )
        IDLE : if( sys_start_i ) nxt_state = S0   ; else nxt_state = IDLE ;
        S0   : if( enc_start_w ) nxt_state = S1   ; else nxt_state = S0   ;
        S1   : if( enc_start_w ) nxt_state = S2   ; else nxt_state = S1   ;
        S2   : if( enc_start_w ) nxt_state = S3   ; else nxt_state = S2   ;
        S3   : if( enc_start_w ) nxt_state = S4   ; else nxt_state = S3   ;
        S4   : if( enc_start_w ) nxt_state = S5   ; else nxt_state = S4   ;
        S5   : if( enc_start_w && (pre_l_x_o==sys_ctu_all_x_i) && (pre_l_y_o==sys_ctu_all_y_i) )
                                 nxt_state = S6   ; else nxt_state = S5   ;
        S6   : if( enc_start_w ) nxt_state = S7   ; else nxt_state = S6   ;
        S7   : if( enc_start_w ) nxt_state = S8   ; else nxt_state = S7   ;
        S8   : if( enc_start_w ) nxt_state = S9   ; else nxt_state = S8   ;
        S9   : if( enc_start_w ) nxt_state = SA   ; else nxt_state = S9   ;
        SA   : if( enc_done_r  ) nxt_state = IDLE ; else nxt_state = SA   ;
        default :                nxt_state = IDLE ;
      endcase
  end

//--- ENA ------------------------------
  // ena_for_enc_core
  always @(*) begin
             {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena,db_ena,ec_ena,store_db_ena}  = 7'b0_00_0000 ;
    //if( sys_type_i == INTRA )
      case( cur_state )
        S0 : {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena, db_ena,ec_ena,store_db_ena} = 7'b1_00_0000 ;
        S1 : {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena, db_ena,ec_ena,store_db_ena} = 7'b1_10_0000 ;
        S2 : {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena, db_ena,ec_ena,store_db_ena} = 7'b1_11_0000 ;
        S3 : {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena, db_ena,ec_ena,store_db_ena} = 7'b1_11_1000 ;
        S4 : {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena, db_ena,ec_ena,store_db_ena} = 7'b1_11_1100 ;
        S5 : {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena, db_ena,ec_ena,store_db_ena} = 7'b1_11_1111 ;
        S6 : {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena, db_ena,ec_ena,store_db_ena} = 7'b0_11_1111 ;
        S7 : {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena, db_ena,ec_ena,store_db_ena} = 7'b0_01_1111 ;
        S8 : {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena, db_ena,ec_ena,store_db_ena} = 7'b0_00_1111 ;
        S9 : {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena, db_ena,ec_ena,store_db_ena} = 7'b0_00_0111 ;
        SA : {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena, db_ena,ec_ena,store_db_ena} = 7'b0_00_0011 ;
        default :
             {pre_l_ena ,stg_1_ena,stg_2_ena,rec_ena,db_ena,ec_ena,store_db_ena}  = 7'b0_00_0000 ;
      endcase
  end

  assign ime_ena            = (sys_type_i == INTER) ? stg_1_ena : 0   ;
  assign fme_ena            = (sys_type_i == INTER) ? stg_2_ena : 0   ;

  assign prei_ena          = stg_1_ena    ;
  assign posi_ena          = stg_2_ena    ;

  // ena for fetch
  always @(*) begin
    if( sys_type_i == INTRA ) begin
      load_cur_luma_ena_o   = pre_l_ena    ; // load cur for prei && posi
      load_ref_luma_ena_o   = 0            ;
      load_cur_chroma_ena_o = stg_2_ena    ; // load cur for rec
      load_ref_chroma_ena_o = 0            ;
      load_db_luma_ena_o    = rec_ena      & (rec_y_o !=0)     ;
      load_db_chroma_ena_o  = rec_ena      & (rec_y_o !=0)     ;
      store_db_luma_ena_o   = store_db_ena & (store_db_x_o!=0) ;
      store_db_chroma_ena_o = store_db_ena & (store_db_x_o!=0) ;
    end
    else begin
      load_cur_luma_ena_o   = pre_l_ena    ; // laod cur and ref for ime
      load_ref_luma_ena_o   = pre_l_ena    ; // laod cur and ref for ime
      load_cur_chroma_ena_o = stg_2_ena    ; // laod cur and ref for mc
      load_ref_chroma_ena_o = stg_2_ena    ; // laod cur and ref for mc
      load_db_luma_ena_o    = rec_ena      & (rec_y_o!=0)       ; // load db top rec pxl,
      load_db_chroma_ena_o  = rec_ena      & (rec_y_o!=0)       ; // so if y==0, ena = 0;
      store_db_luma_ena_o   = store_db_ena & (store_db_x_o!=0) ; // there are three mem for db,
      store_db_chroma_ena_o = store_db_ena & (store_db_x_o!=0) ; // the output of left-most ctu should be delayed;
    end
  end

//--- START ----------------------------
  // start_o
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      pre_l_start_o    <= 0 ;
      prei_start_o    <= 0 ;
      posi_start_o    <= 0 ;
      ime_start_o      <= 0 ;
      fme_start_o      <= 0 ;
      rec_start_o      <= 0 ;
      db_start_o       <= 0 ;
      ec_start_o       <= 0 ;
      store_db_start_o <= 0 ;
    end
    else if( enc_start_o ) begin
      pre_l_start_o    <= pre_l_ena    ;
      prei_start_o    <= prei_ena    ;
      posi_start_o    <= posi_ena    ;
      ime_start_o      <= ime_ena      ;
      fme_start_o      <= fme_ena      ;
      rec_start_o      <= rec_ena      ;
      db_start_o       <= db_ena       ;
      ec_start_o       <= ec_ena       ;
      store_db_start_o <= store_db_ena ;
    end
    else begin
      pre_l_start_o    <= 0 ;
      prei_start_o    <= 0 ;
      posi_start_o    <= 0 ;
      ime_start_o      <= 0 ;
      fme_start_o      <= 0 ;
      rec_start_o      <= 0 ;
      db_start_o       <= 0 ;
      ec_start_o       <= 0 ;
      store_db_start_o <= 0 ;
    end
  end

//--- DONE -----------------------------
  // x_flg (done_flag)
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      fetch_flg <= 0 ;
      prei_flg <= 0 ;
      posi_flg <= 0 ;
      ime_flg   <= 0 ;
      fme_flg   <= 0 ;
      rec_flg   <= 0 ;
      db_flg    <= 0 ;
      ec_flg    <= 0 ;
    end
    else if ( cur_state==IDLE ) begin
      fetch_flg <= 0 ;
      prei_flg <= 0 ;
      posi_flg <= 0 ;
      ime_flg   <= 0 ;
      fme_flg   <= 0 ;
      rec_flg   <= 0 ;
      db_flg    <= 0 ;
      ec_flg    <= 0 ;
    end
    else if ( enc_done_r ) begin
      fetch_flg <= 0 ;
      prei_flg <= 0 ;
      posi_flg <= 0 ;
      ime_flg   <= 0 ;
      fme_flg   <= 0 ;
      rec_flg   <= 0 ;
      db_flg    <= 0 ;
      ec_flg    <= 0 ;
    end
    else begin
      fetch_flg <= fetch_done_i | fetch_flg ;
      prei_flg <= prei_done_i | prei_flg ;
      posi_flg <= posi_done_i | posi_flg ;
      ime_flg   <= ime_done_i   | ime_flg   ;
      fme_flg   <= fme_done_i   | fme_flg   ;
      rec_flg   <= rec_done_i   | rec_flg   ;
      db_flg    <= db_done_i    | db_flg    ;
      ec_flg    <= ec_done_i    | ec_flg    ;
    end
  end

  assign stg_1_flg = (sys_type_i == INTRA) ? prei_flg : (prei_flg && ime_flg);
  assign stg_2_flg = (sys_type_i == INTRA) ? posi_flg : (posi_flg && fme_flg);


  // enc_done_r
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )
                                                                                            enc_done_r <= 0 ;
    else if( enc_done_r )
                                                                                            enc_done_r <= 0 ;
    else begin                                                                                          enc_done_r <= 0 ;
        case( cur_state )
          S0   : if( {fetch_flg ,stg_1_flg,stg_2_flg,rec_flg ,db_flg,ec_flg} == 6'b1_000_00 )    enc_done_r <= 1 ;
          S1   : if( {fetch_flg ,stg_1_flg,stg_2_flg,rec_flg ,db_flg,ec_flg} == 6'b1_100_00 )    enc_done_r <= 1 ;
          S2   : if( {fetch_flg ,stg_1_flg,stg_2_flg,rec_flg ,db_flg,ec_flg} == 6'b1_110_00 )    enc_done_r <= 1 ;
          S3   : if( {fetch_flg ,stg_1_flg,stg_2_flg,rec_flg ,db_flg,ec_flg} == 6'b1_111_00 )    enc_done_r <= 1 ;
          S4   : if( {fetch_flg ,stg_1_flg,stg_2_flg,rec_flg ,db_flg,ec_flg} == 6'b1_111_10 )    enc_done_r <= 1 ;
          S5   : if( {fetch_flg ,stg_1_flg,stg_2_flg,rec_flg ,db_flg,ec_flg} == 6'b1_111_11 )    enc_done_r <= 1 ;
          S6   : if( {fetch_flg ,stg_1_flg,stg_2_flg,rec_flg ,db_flg,ec_flg} == 6'b1_111_11 )    enc_done_r <= 1 ;
          S7   : if( {fetch_flg ,stg_1_flg,stg_2_flg,rec_flg ,db_flg,ec_flg} == 6'b1_011_11 )    enc_done_r <= 1 ;
          S8   : if( {fetch_flg ,stg_1_flg,stg_2_flg,rec_flg ,db_flg,ec_flg} == 6'b1_001_11 )    enc_done_r <= 1 ;
          S9   : if( {fetch_flg ,stg_1_flg,stg_2_flg,rec_flg ,db_flg,ec_flg} == 6'b1_000_11 )    enc_done_r <= 1 ;
          SA   : if( {fetch_flg ,stg_1_flg,stg_2_flg,rec_flg ,db_flg,ec_flg} == 6'b1_000_01 )    enc_done_r <= 1 ;
        endcase
    end
  end

//--- X & Y ----------------------------
  // pre_l x y
  always @(posedge clk or negedge rstn ) begin
    if( !rstn )begin
      pre_l_x_o <= 0;
      pre_l_y_o <= 0;
    end
    else if( cur_state==IDLE )begin
      pre_l_x_o <= 0 ;
      pre_l_y_o <= 0 ;
    end
    else if( enc_done_r )begin
      if( pre_l_x_o == sys_ctu_all_x_i )begin
        pre_l_x_o <= 0 ;
        if ( pre_l_y_o == sys_ctu_all_y_i )
          pre_l_y_o <= 0 ;
        else begin
          pre_l_y_o <= pre_l_y_o + 1 ;
        end
      end
      else begin
        pre_l_x_o <= pre_l_x_o + 1 ;
        pre_l_y_o <= pre_l_y_o ;
      end
    end
  end

  // x & y for enc_core
  always @(posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      prei_x_o    <= 0 ;
      prei_y_o    <= 0 ;
      posi_x_o    <= 0 ;
      posi_y_o    <= 0 ;
      ime_x_o      <= 0 ;
      ime_y_o      <= 0 ;
      fme_x_o      <= 0 ;
      fme_y_o      <= 0 ;
      rec_x_o      <= 0 ;
      rec_y_o      <= 0 ;
      db_x_o       <= 0 ;
      db_y_o       <= 0 ;
      ec_x_o       <= 0 ;
      ec_y_o       <= 0 ;
      store_db_x_o <= 0 ;
      store_db_y_o <= 0 ;
    end
    else if( cur_state==IDLE ) begin
      prei_x_o    <= 0 ;
      prei_y_o    <= 0 ;
      posi_x_o    <= 0 ;
      posi_y_o    <= 0 ;
      ime_x_o      <= 0 ;
      ime_y_o      <= 0 ;
      fme_x_o      <= 0 ;
      fme_y_o      <= 0 ;
      rec_x_o      <= 0 ;
      rec_y_o      <= 0 ;
      db_x_o       <= 0 ;
      db_y_o       <= 0 ;
      ec_x_o       <= 0 ;
      ec_y_o       <= 0 ;
      store_db_x_o <= 0 ;
      store_db_y_o <= 0 ;
    end
    else if( enc_done_r ) begin
      if( sys_type_i==INTRA ) begin
        prei_x_o    <= pre_l_x_o ;
        prei_y_o    <= pre_l_y_o ;
        posi_x_o    <= prei_x_o ;
        posi_y_o    <= prei_y_o ;
        ime_x_o      <= 0         ;
        ime_y_o      <= 0         ;
        fme_x_o      <= 0         ;
        fme_y_o      <= 0         ;
        rec_x_o      <= posi_x_o ;
        rec_y_o      <= posi_y_o ;
        db_x_o       <= rec_x_o   ;
        db_y_o       <= rec_y_o   ;
        ec_x_o       <= db_x_o    ;
        ec_y_o       <= db_y_o    ;
        store_db_x_o <= db_x_o    ;
        store_db_y_o <= db_y_o    ;
      end
      else begin
        prei_x_o    <= pre_l_x_o ;
        prei_y_o    <= pre_l_y_o ;
        posi_x_o    <= prei_x_o ;
        posi_y_o    <= prei_y_o ;
        ime_x_o      <= pre_l_x_o ;
        ime_y_o      <= pre_l_y_o ;
        fme_x_o      <= ime_x_o   ;
        fme_y_o      <= ime_y_o   ;
        rec_x_o      <= fme_x_o   ;
        rec_y_o      <= fme_y_o   ;
        db_x_o       <= rec_x_o   ;
        db_y_o       <= rec_y_o   ;
        ec_x_o       <= db_x_o    ;
        ec_y_o       <= db_y_o    ;
        store_db_x_o <= db_x_o    ;
        store_db_y_o <= db_y_o    ;
      end
    end
  end

  // x & y for fetch
  always @(*) begin
    if( sys_type_i == INTRA ) begin
      load_cur_luma_x_o   = pre_l_x_o    ;
      load_cur_luma_y_o   = pre_l_y_o    ;
      load_ref_luma_x_o   = 0            ;
      load_ref_luma_y_o   = 0            ;
      load_cur_chroma_x_o = posi_x_o    ;
      load_cur_chroma_y_o = posi_y_o    ;
      load_ref_chroma_x_o = 0            ;
      load_ref_chroma_y_o = 0            ;
      load_db_luma_x_o    = rec_x_o      ;
      load_db_luma_y_o    = rec_y_o      ;
      load_db_chroma_x_o  = rec_x_o      ;
      load_db_chroma_y_o  = rec_y_o      ;
      store_db_luma_x_o   = store_db_x_o ; // !!!!!!!!!!!
      store_db_luma_y_o   = store_db_y_o ; // !!!!!!!!!!!
      store_db_chroma_x_o = store_db_x_o ; // !!!!!!!!!!!
      store_db_chroma_y_o = store_db_y_o ; // !!!!!!!!!!!
    end
    else begin
      load_cur_luma_x_o   = pre_l_x_o    ;
      load_cur_luma_y_o   = pre_l_y_o    ;
      load_ref_luma_x_o   = pre_l_x_o    ;
      load_ref_luma_y_o   = pre_l_y_o    ;
      load_cur_chroma_x_o = fme_x_o      ;
      load_cur_chroma_y_o = fme_y_o      ;
      load_ref_chroma_x_o = fme_x_o      ;
      load_ref_chroma_y_o = fme_y_o      ;
      load_db_luma_x_o    = rec_x_o      ;
      load_db_luma_y_o    = rec_y_o      ;
      load_db_chroma_x_o  = rec_x_o      ;
      load_db_chroma_y_o  = rec_y_o      ;
      store_db_luma_x_o   = store_db_x_o ; // !!!!!!!!!!!
      store_db_luma_y_o   = store_db_y_o ; // !!!!!!!!!!!
      store_db_chroma_x_o = store_db_x_o ; // !!!!!!!!!!!
      store_db_chroma_y_o = store_db_y_o ; // !!!!!!!!!!!
    end
  end


endmodule
