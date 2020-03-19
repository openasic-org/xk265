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
// Filename       : db_bs.v
// Author         : TANG
// Creatu_ved     : 
// Description    :         
//------------------------------------------------------------------------------------------------
`include "enc_defines.v"

module db_bs(  
               clk           ,
               rst_n         ,  
               cnt_i         ,
               state_i       ,             
               // sys_total_x_i ,  
               // sys_total_y_i ,  
               sys_ctu_x_i   ,  
               sys_ctu_y_i   ,  
               
               mb_partition_i,
               mb_p_pu_mode_i,
               mb_cbf_i      ,
               mb_cbf_u_i    ,
               mb_cbf_v_i    ,
               qp_i          ,
               
              //output
               tu_edge_o     ,
               pu_edge_o     ,
               qp_p_o        ,
               qp_q_o        ,    
               cbf_p_o       ,
               cbf_q_o       
            );
// *************************************************************************************************
//                                             
//    INPUT / OUTPUT DECLARATION               
//                                             
// *************************************************************************************************
input                           clk             ;//clock
input                           rst_n           ;//reset signal  

// CTRL IF                   
// input [`PIC_X_WIDTH-1:0]        sys_total_x_i   ;// Total LCU number-1 in X ,PIC_X_WIDTH = 8
// input [`PIC_Y_WIDTH-1:0]        sys_total_y_i   ;// Total LCU number-1 in y ,PIC_Y_WIDTH = 8
input [`PIC_X_WIDTH-1:0]        sys_ctu_x_i     ;// Current LCU in X
input [`PIC_Y_WIDTH-1:0]        sys_ctu_y_i     ;// Current LCU in y
input [8:0]                     cnt_i           ;
input [2:0]                     state_i         ;

input [20:0]                    mb_partition_i  ;// CU partition mode,0:not split , 1:split
input [41:0]                    mb_p_pu_mode_i  ;// Intu_ver PU partition mode for every CU size
input [255:0]                   mb_cbf_i        ;//  cbf for every 4x4 cu    
input [255:0]                   mb_cbf_u_i      ;//  cbf for every 4x4 cu  
input [255:0]                   mb_cbf_v_i      ;//  cbf for every 4x4 cu  

input [5:0]                     qp_i            ;// QP 

output                          tu_edge_o       ;
output                          pu_edge_o       ; 
output [5:0]                    qp_p_o          ;
output [5:0]                    qp_q_o          ;   
output                          cbf_p_o         ;
output                          cbf_q_o         ;   


reg                             tu_edge_o       ;
reg                             pu_edge_o       ;
reg    [5:0]                    qp_p_o          ;
reg    [5:0]                    qp_q_o          ;
reg                             cbf_p_o         ;
reg                             cbf_q_o         ;
//***************************************************************************************************
//                                             
//    Parameter DECLARATION                     
//                                             
//***************************************************************************************************
parameter IDLE = 3'b000, LOAD = 3'b001, DBY = 3'b011, DBU = 3'b010, DBV = 3'b110, SAO = 3'b100, OUT = 3'b101;

// delay cnt_i
reg     [8:0]                   cnt_r               ;
always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n )
        cnt_r       <= 'd0;
    else 
        cnt_r       <= cnt_i ;
end 

wire y_flag, u_flag, v_flag;
wire top_left_flag, top_flag, left_flag;    
assign y_flag           = state_i == DBY && (!cnt_r[8]);
assign u_flag           = state_i == DBU && (!cnt_r[6]);
assign v_flag           = state_i == DBV && (!cnt_r[6]); 
assign top_left_flag    = (state_i == DBY || state_i == DBU || state_i == DBV) && (cnt_r[8:2] == 7'd0)  ;
assign top_flag         = (y_flag && cnt_r[8:5] == 4'd0) || (u_flag&&cnt_r[5:4]==2'd0) || (v_flag&&cnt_r[5:4]==2'd0);
assign left_flag        = (y_flag && cnt_r[4:2] == 3'd0) || (u_flag&&cnt_r[3:2]==2'd0) || (v_flag&&cnt_r[3:2]==2'd0);
//***************************************************************************************************
//                                             
//                  store cbf top to memory   
//                                             
//***************************************************************************************************
wire                        cbf_top_cen_w    ;  // chip enable, low active
wire                        cbf_top_oen_w    ;  // data output enable, low active
wire                        cbf_top_wen_w    ;  // write enable, low active
wire    [`PIC_X_WIDTH-1:0]  cbf_top_addr_w   ;  // address input
wire    [          16-1:0]  cbf_top_data_i_w ;  // data input
wire    [          16-1:0]  cbf_top_data_o_w ;  // data output

reg                         cbf_top_oen_r    ;

wire   [ 16-1 : 0 ]             cbf_top_w       ;
reg    [ 16-1 : 0 ]             cbf_top_r       ;
    
assign  cbf_top_w = { mb_cbf_i[255],mb_cbf_i[254],mb_cbf_i[251],mb_cbf_i[250],
                      mb_cbf_i[239],mb_cbf_i[238],mb_cbf_i[235],mb_cbf_i[234],
                      mb_cbf_i[191],mb_cbf_i[190],mb_cbf_i[187],mb_cbf_i[186],
                      mb_cbf_i[175],mb_cbf_i[174],mb_cbf_i[171],mb_cbf_i[170]};

                     
// mv top memory buffer
assign  cbf_top_cen_w     = !(!(state_i == LOAD  || state_i == OUT) )      ;
assign  cbf_top_oen_w     = !(!(state_i == LOAD )|| (cnt_i !=0 )    )               ; // read enable  
assign  cbf_top_wen_w     = !(!(state_i == OUT  )|| (cnt_i !=0 )    )               ; // write enable     
assign  cbf_top_addr_w    = sys_ctu_x_i                 ;    
assign  cbf_top_data_i_w  = cbf_top_w              ;                          

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) 
        cbf_top_oen_r  <=  1'b0          ;
    else 
        cbf_top_oen_r  <=  cbf_top_oen_w ;
end 

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) 
        cbf_top_r  <=  16'b0            ;
    else if((sys_ctu_y_i != 0)&&cbf_top_oen_r)
        cbf_top_r  <=  cbf_top_data_o_w ;
    else if(cbf_top_oen_r)
        cbf_top_r  <=  16'b0            ;
end 

db_cbf_ram_sp_64x16 u_db_cbf_ram_sp_64x16(
    .clk        ( clk               ) ,
    .adr_i      ( cbf_top_addr_w    ) ,
    .cen_i      ( cbf_top_cen_w     ) , // low active
    .wen_i      ( cbf_top_wen_w     ) ,
    .wr_dat_i   ( cbf_top_data_i_w  ) ,
    .rd_dat_o   ( cbf_top_data_o_w  ) 
    );
       

//***************************************************************************************************
//                                             
//                      cacl tu edge and pu edge 
//                                             
//***************************************************************************************************

wire    [7:0]      tu_ve0,tu_ve1,tu_ve2 ,tu_ve3 ,tu_ve4 ,tu_ve5 ,tu_ve6 ,tu_ve7 ;
wire    [7:0]      tu_ve8,tu_ve9,tu_ve10,tu_ve11,tu_ve12,tu_ve13,tu_ve14,tu_ve15;
    
wire    [15:0]     tu_he0,tu_he1,tu_he2,tu_he3,tu_he4,tu_he5,tu_he6,tu_he7      ;
reg     [7:0]      tu_le                                            ;

assign tu_ve0[0]    =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve1[0]    =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve2[0]    =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve3[0]    =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve4[0]    =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve5[0]    =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve6[0]    =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve7[0]    =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve8[0]    =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve9[0]    =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve10[0]   =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve11[0]   =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve12[0]   =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve13[0]   =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve14[0]   =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;
assign tu_ve15[0]   =   sys_ctu_x_i != 'b0 ?   1'd1    :   1'd0    ;

assign tu_he0       =   sys_ctu_y_i  ?   16'hffff :  16'd0   ;

db_tu_edge utuedge(
                        .mb_partition_i(mb_partition_i),
                        .v0            (tu_ve0[7:1]   ),
                        .v1            (tu_ve1[7:1]   ),
                        .v2            (tu_ve2[7:1]   ),
                        .v3            (tu_ve3[7:1]   ),
                        .v4            (tu_ve4[7:1]   ),
                        .v5            (tu_ve5[7:1]   ),
                        .v6            (tu_ve6[7:1]   ),
                        .v7            (tu_ve7[7:1]   ),
                        .v8            (tu_ve8[7:1]   ),
                        .v9            (tu_ve9[7:1]   ),
                        .v10           (tu_ve10[7:1]  ),
                        .v11           (tu_ve11[7:1]  ),
                        .v12           (tu_ve12[7:1]  ),
                        .v13           (tu_ve13[7:1]  ),
                        .v14           (tu_ve14[7:1]  ),
                        .v15           (tu_ve15[7:1]  ),

                        .h1            (tu_he1        ),
                        .h2            (tu_he2        ),
                        .h3            (tu_he3        ),
                        .h4            (tu_he4        ),
                        .h5            (tu_he5        ),
                        .h6            (tu_he6        ),
                        .h7            (tu_he7        )                 
                        
);  

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tu_le     <=  'd0    ;
    else if(state_i==OUT) begin
        tu_le[0]  <=  tu_he0[15];
        tu_le[1]  <=  tu_he1[15];
        tu_le[2]  <=  tu_he2[15];
        tu_le[3]  <=  tu_he3[15];
        tu_le[4]  <=  tu_he4[15];
        tu_le[5]  <=  tu_he5[15];
        tu_le[6]  <=  tu_he6[15];
        tu_le[7]  <=  tu_he7[15];
    end
    else 
        tu_le     <=  tu_le    ;
end

wire    [16:0]     tu_he0_w,tu_he1_w,tu_he2_w,tu_he3_w,tu_he4_w,tu_he5_w,tu_he6_w,tu_he7_w;

assign tu_he0_w = { tu_he0, tu_le[0] };
assign tu_he1_w = { tu_he1, tu_le[1] };
assign tu_he2_w = { tu_he2, tu_le[2] };
assign tu_he3_w = { tu_he3, tu_le[3] };
assign tu_he4_w = { tu_he4, tu_le[4] };
assign tu_he5_w = { tu_he5, tu_le[5] };
assign tu_he6_w = { tu_he6, tu_le[6] };
assign tu_he7_w = { tu_he7, tu_le[7] };
//******************************************************************************************************
//              cacl pu edge 
//******************************************************************************************************
wire    [7:0]      pu_ve0,pu_ve1,pu_ve2 ,pu_ve3 ,pu_ve4 ,pu_ve5 ,pu_ve6 ,pu_ve7 ;
wire    [7:0]      pu_ve8,pu_ve9,pu_ve10,pu_ve11,pu_ve12,pu_ve13,pu_ve14,pu_ve15;

wire    [15:0]     pu_he0,pu_he1,pu_he2,pu_he3,pu_he4,pu_he5,pu_he6,pu_he7;
reg     [7:0]      pu_le                                                  ;

assign pu_ve0[0]    =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve1[0]    =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve2[0]    =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve3[0]    =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve4[0]    =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve5[0]    =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve6[0]    =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve7[0]    =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve8[0]    =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve9[0]    =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve10[0]   =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve11[0]   =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve12[0]   =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve13[0]   =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve14[0]   =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;
assign pu_ve15[0]   =   sys_ctu_x_i  ?   1'd1    :   1'd0    ;

assign pu_he0       =   sys_ctu_y_i  ?   16'hffff:   16'd0   ;

db_pu_edge upuedge(
                        .mb_partition_i(mb_partition_i),
                        .mb_p_pu_mode_i(mb_p_pu_mode_i),
                        .v0            (pu_ve0[7:1]   ),
                        .v1            (pu_ve1[7:1]   ),
                        .v2            (pu_ve2[7:1]   ),
                        .v3            (pu_ve3[7:1]   ),
                        .v4            (pu_ve4[7:1]   ),
                        .v5            (pu_ve5[7:1]   ),
                        .v6            (pu_ve6[7:1]   ),
                        .v7            (pu_ve7[7:1]   ),
                        .v8            (pu_ve8[7:1]   ),
                        .v9            (pu_ve9[7:1]   ),
                        .v10           (pu_ve10[7:1]  ),
                        .v11           (pu_ve11[7:1]  ),
                        .v12           (pu_ve12[7:1]  ),
                        .v13           (pu_ve13[7:1]  ),
                        .v14           (pu_ve14[7:1]  ),
                        .v15           (pu_ve15[7:1]  ),
                        
                        .h1            (pu_he1        ),
                        .h2            (pu_he2        ),
                        .h3            (pu_he3        ),
                        .h4            (pu_he4        ),
                        .h5            (pu_he5        ),
                        .h6            (pu_he6        ),
                        .h7            (pu_he7        )
                );
                
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        pu_le     <=  'd0    ;
    else if(state_i==OUT) begin
        pu_le[0]  <=  pu_he0[15];
        pu_le[1]  <=  pu_he1[15];
        pu_le[2]  <=  pu_he2[15];
        pu_le[3]  <=  pu_he3[15];
        pu_le[4]  <=  pu_he4[15];
        pu_le[5]  <=  pu_he5[15];
        pu_le[6]  <=  pu_he6[15];
        pu_le[7]  <=  pu_he7[15];
    end
    else 
        pu_le     <=  pu_le    ;
end     

wire    [16:0]     pu_he0_w,pu_he1_w,pu_he2_w,pu_he3_w,pu_he4_w,pu_he5_w,pu_he6_w,pu_he7_w;

assign pu_he0_w = { pu_he0, pu_le[0] };
assign pu_he1_w = { pu_he1, pu_le[1] };
assign pu_he2_w = { pu_he2, pu_le[2] };
assign pu_he3_w = { pu_he3, pu_le[3] };
assign pu_he4_w = { pu_he4, pu_le[4] };
assign pu_he5_w = { pu_he5, pu_le[5] };
assign pu_he6_w = { pu_he6, pu_le[6] };
assign pu_he7_w = { pu_he7, pu_le[7] };

// store top tu and pu to memory
wire                        tpu_top_cen_w    ;  // chip enable, low active
wire                        tpu_top_oen_w    ;  // data output enable, low active
wire                        tpu_top_wen_w    ;  // write enable, low active
wire    [`PIC_X_WIDTH-1:0]  tpu_top_addr_w   ;  // address input
wire    [          31:0]    tpu_top_data_i_w ;  // data input
wire    [          31:0]    tpu_top_data_o_w ;  // data output

reg                         tpu_top_oen_r    ;

wire   [ 31 : 0 ]             tpu_top_w       ;
reg    [ 31 : 0 ]             tpu_top_r       ;
    
assign  tpu_top_w = { tu_ve14, tu_ve15, pu_ve14, pu_ve15 };

                     
// tu and pu top memory buffer
assign  tpu_top_cen_w     = !(!(state_i == LOAD  )              )   ;
assign  tpu_top_oen_w     = !(!(state_i == LOAD )|| (cnt_i != 0))                 ; // read enable  
assign  tpu_top_wen_w     = !(!(state_i == OUT  )|| (cnt_i != 0))                 ; // write enable     
assign  tpu_top_addr_w    = sys_ctu_x_i                 ;    
assign  tpu_top_data_i_w  = tpu_top_w              ;                          

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) 
        tpu_top_oen_r  <=  1'b0          ;
    else 
        tpu_top_oen_r  <=  tpu_top_oen_w ;
end 

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) 
        tpu_top_r  <=  32'b0            ;
    else if((sys_ctu_y_i != 0)&&tpu_top_oen_r)
        tpu_top_r  <=  tpu_top_data_o_w ;
    else if(tpu_top_oen_r)
        tpu_top_r  <=  32'b0            ;
end 

//wire [7:0] tu_ve15, tu_ve14, pu_ve15, pu_ve14;
wire top_tu0 = tpu_top_r[31:24];
wire top_tu1 = tpu_top_r[23:16];
wire top_pu0 = tpu_top_r[15:8];
wire top_pu1 = tpu_top_r[7:0];

db_tupu_ram_sp_64x32 u_db_tupu_ram_sp_64x32(
    .clk        ( clk               ) ,
    .adr_i      ( tpu_top_addr_w    ) ,
    .cen_i      ( tpu_top_cen_w     ) , // low active
    .wen_i      ( tpu_top_wen_w     ) ,
    .wr_dat_i   ( tpu_top_data_i_w  ) ,
    .rd_dat_o   ( tpu_top_data_o_w  ) 
    );

    
//******************************************************************************************************
//                                             
//      select tu_ve  pu_ve  pu_he depedent on the cnt_i and state_i
//                                             
//******************************************************************************************************
reg [7:0] tu_ver_dn, tu_ver_up, pu_ver_up, pu_ver_dn;
reg tu_vp, tu_vd, tu_hl, tu_hr; // vp:up vertical edge, vd:down vertical edge, hl:left horizontal edge, hr:right hor edge
reg pu_vp, pu_vd, pu_hl, pu_hr;
reg [16:0] tu_hor, pu_hor;

always @ (*) begin 
    if ( y_flag ) begin // Y
        case (cnt_r[7:5])
            3'b000 : begin tu_ver_up = top_tu1; tu_ver_dn = tu_ve0 ; pu_ver_up = top_pu1; pu_ver_dn = pu_ve0 ; tu_hor = tu_he0_w; pu_hor = pu_he0_w; end 
            3'b001 : begin tu_ver_up = tu_ve1 ; tu_ver_dn = tu_ve2 ; pu_ver_up = pu_ve1 ; pu_ver_dn = pu_ve2 ; tu_hor = tu_he1_w; pu_hor = pu_he1_w; end 
            3'b010 : begin tu_ver_up = tu_ve3 ; tu_ver_dn = tu_ve4 ; pu_ver_up = pu_ve3 ; pu_ver_dn = pu_ve4 ; tu_hor = tu_he2_w; pu_hor = pu_he2_w; end 
            3'b011 : begin tu_ver_up = tu_ve5 ; tu_ver_dn = tu_ve6 ; pu_ver_up = pu_ve5 ; pu_ver_dn = pu_ve6 ; tu_hor = tu_he3_w; pu_hor = pu_he3_w; end 
            3'b100 : begin tu_ver_up = tu_ve7 ; tu_ver_dn = tu_ve8 ; pu_ver_up = pu_ve7 ; pu_ver_dn = pu_ve8 ; tu_hor = tu_he4_w; pu_hor = pu_he4_w; end 
            3'b101 : begin tu_ver_up = tu_ve9 ; tu_ver_dn = tu_ve10; pu_ver_up = pu_ve9 ; pu_ver_dn = pu_ve10; tu_hor = tu_he5_w; pu_hor = pu_he5_w; end 
            3'b110 : begin tu_ver_up = tu_ve11; tu_ver_dn = tu_ve12; pu_ver_up = pu_ve11; pu_ver_dn = pu_ve12; tu_hor = tu_he6_w; pu_hor = pu_he6_w; end 
            3'b111 : begin tu_ver_up = tu_ve13; tu_ver_dn = tu_ve14; pu_ver_up = pu_ve13; pu_ver_dn = pu_ve14; tu_hor = tu_he7_w; pu_hor = pu_he7_w; end 
            default: begin tu_ver_up = 8'd0   ; tu_ver_dn = 8'd0   ; pu_ver_up = 8'd0   ; pu_ver_dn = 8'd0   ; tu_hor = 'd0     ; pu_hor = 'd0     ; end 
        endcase 
    end 
    else begin  // U and V
        case (cnt_r[5:4])
            2'b00  : begin tu_ver_up = top_tu0; tu_ver_dn = tu_ve0 ; pu_ver_up = top_pu0; pu_ver_dn = pu_ve0 ; tu_hor = tu_he0_w; pu_hor = pu_he0_w; end 
            2'b01  : begin tu_ver_up = tu_ve2 ; tu_ver_dn = tu_ve4 ; pu_ver_up = pu_ve2 ; pu_ver_dn = pu_ve4 ; tu_hor = tu_he2_w; pu_hor = pu_he2_w;end 
            2'b10  : begin tu_ver_up = tu_ve6 ; tu_ver_dn = tu_ve8 ; pu_ver_up = pu_ve6 ; pu_ver_dn = pu_ve8 ; tu_hor = tu_he4_w; pu_hor = pu_he4_w;end 
            2'b11  : begin tu_ver_up = tu_ve10; tu_ver_dn = tu_ve12; pu_ver_up = pu_ve10; pu_ver_dn = pu_ve12; tu_hor = tu_he6_w; pu_hor = pu_he6_w;end 
            default: begin tu_ver_up = 8'd0   ; tu_ver_dn = 8'd0   ; pu_ver_up = 8'd0   ; pu_ver_dn = 8'd0   ; tu_hor = 17'd0    ; pu_hor = 17'd0    ;end 
        endcase 
    end
end 

always @ (*) begin 
    if ( y_flag ) begin 
        case (cnt_r[4:2])
            3'b000 : begin tu_vp = tu_ver_up[0]; tu_vd= tu_ver_dn[0]; tu_hl = tu_hor[ 0]; tu_hr = tu_hor[ 1]; end  
            3'b001 : begin tu_vp = tu_ver_up[1]; tu_vd= tu_ver_dn[1]; tu_hl = tu_hor[ 2]; tu_hr = tu_hor[ 3]; end  
            3'b010 : begin tu_vp = tu_ver_up[2]; tu_vd= tu_ver_dn[2]; tu_hl = tu_hor[ 4]; tu_hr = tu_hor[ 5]; end 
            3'b011 : begin tu_vp = tu_ver_up[3]; tu_vd= tu_ver_dn[3]; tu_hl = tu_hor[ 6]; tu_hr = tu_hor[ 7]; end 
            3'b100 : begin tu_vp = tu_ver_up[4]; tu_vd= tu_ver_dn[4]; tu_hl = tu_hor[ 8]; tu_hr = tu_hor[ 9]; end 
            3'b101 : begin tu_vp = tu_ver_up[5]; tu_vd= tu_ver_dn[5]; tu_hl = tu_hor[10]; tu_hr = tu_hor[11]; end 
            3'b110 : begin tu_vp = tu_ver_up[6]; tu_vd= tu_ver_dn[6]; tu_hl = tu_hor[12]; tu_hr = tu_hor[13]; end 
            3'b111 : begin tu_vp = tu_ver_up[7]; tu_vd= tu_ver_dn[7]; tu_hl = tu_hor[14]; tu_hr = tu_hor[15]; end 
            default: begin tu_vp = 1'b0        ;tu_vd = 1'b0        ; tu_hl = 1'b0      ; tu_hr = 1'b0      ; end 
        endcase 
    end else begin 
        case (cnt_r[3:2])
            2'b00  : begin tu_vp = tu_ver_up[0]; tu_vd= tu_ver_dn[0]; tu_hl = tu_hor[ 0]; tu_hr = tu_hor[ 2]; end 
            2'b01  : begin tu_vp = tu_ver_up[2]; tu_vd= tu_ver_dn[2]; tu_hl = tu_hor[ 4]; tu_hr = tu_hor[ 6]; end 
            2'b10  : begin tu_vp = tu_ver_up[4]; tu_vd= tu_ver_dn[4]; tu_hl = tu_hor[ 8]; tu_hr = tu_hor[10]; end 
            2'b11  : begin tu_vp = tu_ver_up[6]; tu_vd= tu_ver_dn[6]; tu_hl = tu_hor[12]; tu_hr = tu_hor[14]; end 
            default: begin tu_vp = 1'b0        ; tu_vd = 1'b0       ; tu_hl = 1'b0      ; tu_hr = 1'b0      ; end 
			endcase
    end 
end 

always @ (*) begin 
    if ( y_flag ) begin 
        case (cnt_r[4:2])
            3'b000 : begin pu_vp = pu_ver_up[0]; pu_vd= pu_ver_dn[0]; pu_hl = pu_hor[ 0]; pu_hr = pu_hor[ 1]; end  
            3'b001 : begin pu_vp = pu_ver_up[1]; pu_vd= pu_ver_dn[1]; pu_hl = pu_hor[ 2]; pu_hr = pu_hor[ 3]; end  
            3'b010 : begin pu_vp = pu_ver_up[2]; pu_vd= pu_ver_dn[2]; pu_hl = pu_hor[ 4]; pu_hr = pu_hor[ 5]; end 
            3'b011 : begin pu_vp = pu_ver_up[3]; pu_vd= pu_ver_dn[3]; pu_hl = pu_hor[ 6]; pu_hr = pu_hor[ 7]; end 
            3'b100 : begin pu_vp = pu_ver_up[4]; pu_vd= pu_ver_dn[4]; pu_hl = pu_hor[ 8]; pu_hr = pu_hor[ 9]; end 
            3'b101 : begin pu_vp = pu_ver_up[5]; pu_vd= pu_ver_dn[5]; pu_hl = pu_hor[10]; pu_hr = pu_hor[11]; end 
            3'b110 : begin pu_vp = pu_ver_up[6]; pu_vd= pu_ver_dn[6]; pu_hl = pu_hor[12]; pu_hr = pu_hor[13]; end 
            3'b111 : begin pu_vp = pu_ver_up[7]; pu_vd= pu_ver_dn[7]; pu_hl = pu_hor[14]; pu_hr = pu_hor[15]; end 
            default: begin pu_vp = 1'b0        ;pu_vd = 1'b0        ; pu_hl = 1'b0      ; pu_hr = 1'b0      ; end 
        endcase 
    end else begin 
        case (cnt_r[3:2])
            2'b00  : begin pu_vp = pu_ver_up[0]; pu_vd= pu_ver_dn[0]; pu_hl = pu_hor[ 0]; pu_hr = pu_hor[ 2]; end 
            2'b01  : begin pu_vp = pu_ver_up[2]; pu_vd= pu_ver_dn[2]; pu_hl = pu_hor[ 4]; pu_hr = pu_hor[ 6]; end 
            2'b10  : begin pu_vp = pu_ver_up[4]; pu_vd= pu_ver_dn[4]; pu_hl = pu_hor[ 8]; pu_hr = pu_hor[10]; end 
            2'b11  : begin pu_vp = pu_ver_up[6]; pu_vd= pu_ver_dn[6]; pu_hl = pu_hor[12]; pu_hr = pu_hor[14]; end 
            default: begin pu_vp = 1'b0        ; pu_vd = 1'b0       ; pu_hl = 1'b0      ; pu_hr = 1'b0      ; end 
			endcase
    end 
end 

reg tu_edge_r;
reg pu_edge_r;

always @ (*) begin 
    case ( cnt_r[1:0] )
        2'b00 : begin tu_edge_r = tu_vp; pu_edge_r = pu_vp; end 
        2'b01 : begin tu_edge_r = tu_vd; pu_edge_r = pu_vd; end 
        2'b10 : begin tu_edge_r = tu_hl; pu_edge_r = pu_hl; end 
        2'b11 : begin tu_edge_r = tu_hr; pu_edge_r = pu_hr; end 
    endcase 
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if (!rst_n) begin 
        tu_edge_o <= 1'b0;
        pu_edge_o <= 1'b0;
    end else begin 
        tu_edge_o <= tu_edge_r;
        pu_edge_o <= pu_edge_r;
    end 
end 

//******************************************************************************************************
//                                             
//                      select cbf 
//                                             
//******************************************************************************************************
reg [15:0]  cbf_left    ;
reg         cbf_tl      ;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cbf_left    <=  16'h0000    ;   
    else if(state_i==OUT) begin
        cbf_left[0 ]  <=  mb_cbf_i[ 85] ;
        cbf_left[1 ]  <=  mb_cbf_i[ 87] ;
        cbf_left[2 ]  <=  mb_cbf_i[ 93] ;
        cbf_left[3 ]  <=  mb_cbf_i[ 95] ;
        cbf_left[4 ]  <=  mb_cbf_i[117] ;
        cbf_left[5 ]  <=  mb_cbf_i[119] ;
        cbf_left[6 ]  <=  mb_cbf_i[125] ;
        cbf_left[7 ]  <=  mb_cbf_i[127] ;
        cbf_left[8 ]  <=  mb_cbf_i[213] ;
        cbf_left[9 ]  <=  mb_cbf_i[215] ;
        cbf_left[10]  <=  mb_cbf_i[221] ;
        cbf_left[11]  <=  mb_cbf_i[223] ;
        cbf_left[12]  <=  mb_cbf_i[245] ;
        cbf_left[13]  <=  mb_cbf_i[247] ;
        cbf_left[14]  <=  mb_cbf_i[253] ;
        cbf_left[15]  <=  mb_cbf_i[255] ;
    end
end      

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cbf_tl  <=  1'b0 ;
    else if(state_i==OUT)
        cbf_tl  <=  cbf_top_r[15];
end

wire [16:0] cbf_h0_p  , cbf_h0_q    ; 
wire [16:0] cbf_h1_p  , cbf_h1_q    ; 
wire [16:0] cbf_h2_p  , cbf_h2_q    ; 
wire [16:0] cbf_h3_p  , cbf_h3_q    ; 
wire [16:0] cbf_h4_p  , cbf_h4_q    ; 
wire [16:0] cbf_h5_p  , cbf_h5_q    ; 
wire [16:0] cbf_h6_p  , cbf_h6_q    ; 
wire [16:0] cbf_h7_p  , cbf_h7_q    ; 

assign cbf_h0_p = {cbf_tl, cbf_top_r[0 ],cbf_top_r[1 ],cbf_top_r[2 ],cbf_top_r[3 ],cbf_top_r[4 ],cbf_top_r[5 ],cbf_top_r[6 ],cbf_top_r[7 ],cbf_top_r[8 ],cbf_top_r[9 ],cbf_top_r[10],cbf_top_r[11],cbf_top_r[12],cbf_top_r[13],cbf_top_r[14],cbf_top_r[15]} ;//{mb_cbf_i[  0],mb_cbf_i[  1],mb_cbf_i[  4],mb_cbf_i[  5],mb_cbf_i[ 16],mb_cbf_i[ 17],mb_cbf_i[ 20],mb_cbf_i[ 21],mb_cbf_i[ 64],mb_cbf_i[ 65],mb_cbf_i[ 68],mb_cbf_i[ 69],mb_cbf_i[ 80],mb_cbf_i[ 81],mb_cbf_i[ 84],mb_cbf_i[ 85]};
assign cbf_h1_p = {cbf_left[ 1],mb_cbf_i[  2],mb_cbf_i[  3],mb_cbf_i[  6],mb_cbf_i[  7],mb_cbf_i[ 18],mb_cbf_i[ 19],mb_cbf_i[ 22],mb_cbf_i[ 23],mb_cbf_i[ 66],mb_cbf_i[ 67],mb_cbf_i[ 70],mb_cbf_i[ 71],mb_cbf_i[ 82],mb_cbf_i[ 83],mb_cbf_i[ 86],mb_cbf_i[ 87]};
assign cbf_h2_p = {cbf_left[ 3],mb_cbf_i[ 10],mb_cbf_i[ 11],mb_cbf_i[ 14],mb_cbf_i[ 15],mb_cbf_i[ 26],mb_cbf_i[ 27],mb_cbf_i[ 30],mb_cbf_i[ 31],mb_cbf_i[ 74],mb_cbf_i[ 75],mb_cbf_i[ 78],mb_cbf_i[ 79],mb_cbf_i[ 90],mb_cbf_i[ 91],mb_cbf_i[ 94],mb_cbf_i[ 95]};
assign cbf_h3_p = {cbf_left[ 5],mb_cbf_i[ 34],mb_cbf_i[ 35],mb_cbf_i[ 38],mb_cbf_i[ 39],mb_cbf_i[ 50],mb_cbf_i[ 51],mb_cbf_i[ 54],mb_cbf_i[ 55],mb_cbf_i[ 98],mb_cbf_i[ 99],mb_cbf_i[102],mb_cbf_i[103],mb_cbf_i[114],mb_cbf_i[115],mb_cbf_i[118],mb_cbf_i[119]};
assign cbf_h4_p = {cbf_left[ 7],mb_cbf_i[ 42],mb_cbf_i[ 43],mb_cbf_i[ 46],mb_cbf_i[ 47],mb_cbf_i[ 58],mb_cbf_i[ 59],mb_cbf_i[ 62],mb_cbf_i[ 63],mb_cbf_i[106],mb_cbf_i[107],mb_cbf_i[110],mb_cbf_i[111],mb_cbf_i[122],mb_cbf_i[123],mb_cbf_i[126],mb_cbf_i[127]};
assign cbf_h5_p = {cbf_left[ 9],mb_cbf_i[130],mb_cbf_i[131],mb_cbf_i[134],mb_cbf_i[135],mb_cbf_i[146],mb_cbf_i[147],mb_cbf_i[150],mb_cbf_i[151],mb_cbf_i[194],mb_cbf_i[195],mb_cbf_i[198],mb_cbf_i[199],mb_cbf_i[210],mb_cbf_i[211],mb_cbf_i[214],mb_cbf_i[215]};
assign cbf_h6_p = {cbf_left[11],mb_cbf_i[138],mb_cbf_i[139],mb_cbf_i[142],mb_cbf_i[143],mb_cbf_i[154],mb_cbf_i[155],mb_cbf_i[158],mb_cbf_i[159],mb_cbf_i[202],mb_cbf_i[203],mb_cbf_i[206],mb_cbf_i[207],mb_cbf_i[218],mb_cbf_i[219],mb_cbf_i[222],mb_cbf_i[223]};
assign cbf_h7_p = {cbf_left[13],mb_cbf_i[162],mb_cbf_i[163],mb_cbf_i[166],mb_cbf_i[167],mb_cbf_i[178],mb_cbf_i[179],mb_cbf_i[182],mb_cbf_i[183],mb_cbf_i[226],mb_cbf_i[227],mb_cbf_i[230],mb_cbf_i[231],mb_cbf_i[242],mb_cbf_i[243],mb_cbf_i[246],mb_cbf_i[247]};

assign cbf_h0_q = {cbf_left[ 0],mb_cbf_i[  0],mb_cbf_i[  1],mb_cbf_i[  4],mb_cbf_i[  5],mb_cbf_i[ 16],mb_cbf_i[ 17],mb_cbf_i[ 20],mb_cbf_i[ 21],mb_cbf_i[ 64],mb_cbf_i[ 65],mb_cbf_i[ 68],mb_cbf_i[ 69],mb_cbf_i[ 80],mb_cbf_i[ 81],mb_cbf_i[ 84],mb_cbf_i[ 85]};
assign cbf_h1_q = {cbf_left[ 2],mb_cbf_i[  8],mb_cbf_i[  9],mb_cbf_i[ 12],mb_cbf_i[ 13],mb_cbf_i[ 24],mb_cbf_i[ 25],mb_cbf_i[ 28],mb_cbf_i[ 29],mb_cbf_i[ 72],mb_cbf_i[ 73],mb_cbf_i[ 76],mb_cbf_i[ 77],mb_cbf_i[ 88],mb_cbf_i[ 89],mb_cbf_i[ 92],mb_cbf_i[ 93]};
assign cbf_h2_q = {cbf_left[ 4],mb_cbf_i[ 32],mb_cbf_i[ 33],mb_cbf_i[ 36],mb_cbf_i[ 37],mb_cbf_i[ 48],mb_cbf_i[ 49],mb_cbf_i[ 52],mb_cbf_i[ 53],mb_cbf_i[ 96],mb_cbf_i[ 97],mb_cbf_i[100],mb_cbf_i[101],mb_cbf_i[112],mb_cbf_i[113],mb_cbf_i[116],mb_cbf_i[117]};
assign cbf_h3_q = {cbf_left[ 6],mb_cbf_i[ 40],mb_cbf_i[ 41],mb_cbf_i[ 44],mb_cbf_i[ 45],mb_cbf_i[ 56],mb_cbf_i[ 57],mb_cbf_i[ 60],mb_cbf_i[ 61],mb_cbf_i[104],mb_cbf_i[105],mb_cbf_i[108],mb_cbf_i[109],mb_cbf_i[120],mb_cbf_i[121],mb_cbf_i[124],mb_cbf_i[125]};
assign cbf_h4_q = {cbf_left[ 8],mb_cbf_i[128],mb_cbf_i[129],mb_cbf_i[132],mb_cbf_i[133],mb_cbf_i[144],mb_cbf_i[145],mb_cbf_i[148],mb_cbf_i[149],mb_cbf_i[192],mb_cbf_i[193],mb_cbf_i[196],mb_cbf_i[197],mb_cbf_i[208],mb_cbf_i[209],mb_cbf_i[212],mb_cbf_i[213]};
assign cbf_h5_q = {cbf_left[10],mb_cbf_i[136],mb_cbf_i[137],mb_cbf_i[140],mb_cbf_i[141],mb_cbf_i[152],mb_cbf_i[153],mb_cbf_i[156],mb_cbf_i[157],mb_cbf_i[200],mb_cbf_i[201],mb_cbf_i[204],mb_cbf_i[205],mb_cbf_i[216],mb_cbf_i[217],mb_cbf_i[220],mb_cbf_i[221]};
assign cbf_h6_q = {cbf_left[12],mb_cbf_i[160],mb_cbf_i[161],mb_cbf_i[164],mb_cbf_i[165],mb_cbf_i[176],mb_cbf_i[177],mb_cbf_i[180],mb_cbf_i[181],mb_cbf_i[224],mb_cbf_i[225],mb_cbf_i[228],mb_cbf_i[229],mb_cbf_i[240],mb_cbf_i[241],mb_cbf_i[244],mb_cbf_i[245]};
assign cbf_h7_q = {cbf_left[14],mb_cbf_i[168],mb_cbf_i[169],mb_cbf_i[172],mb_cbf_i[173],mb_cbf_i[184],mb_cbf_i[185],mb_cbf_i[188],mb_cbf_i[189],mb_cbf_i[232],mb_cbf_i[233],mb_cbf_i[236],mb_cbf_i[237],mb_cbf_i[248],mb_cbf_i[249],mb_cbf_i[252],mb_cbf_i[253]};

reg [16:0] cbf_flag_up, cbf_flag_dn;
reg cbf_flag_ul, cbf_flag_ur, cbf_flag_dl, cbf_flag_dr;

reg         cbf_p_r       ,   cbf_q_r       ;

always @ (*) begin 
    if ( y_flag ) begin // Y
        case (cnt_r[7:5])
            3'b000 : begin cbf_flag_up = cbf_h0_p; cbf_flag_dn = cbf_h0_q; end 
            3'b001 : begin cbf_flag_up = cbf_h1_p; cbf_flag_dn = cbf_h1_q; end 
            3'b010 : begin cbf_flag_up = cbf_h2_p; cbf_flag_dn = cbf_h2_q; end 
            3'b011 : begin cbf_flag_up = cbf_h3_p; cbf_flag_dn = cbf_h3_q; end 
            3'b100 : begin cbf_flag_up = cbf_h4_p; cbf_flag_dn = cbf_h4_q; end 
            3'b101 : begin cbf_flag_up = cbf_h5_p; cbf_flag_dn = cbf_h5_q; end 
            3'b110 : begin cbf_flag_up = cbf_h6_p; cbf_flag_dn = cbf_h6_q; end 
            3'b111 : begin cbf_flag_up = cbf_h7_p; cbf_flag_dn = cbf_h7_q; end 
            default: begin cbf_flag_up = 17'd0   ; cbf_flag_dn = 17'd0   ; end 
        endcase 
    end 
    else begin 
        cbf_flag_up = 17'd0      ; cbf_flag_dn = 17'd0      ;
    end
end 

always @ (*) begin 
    if ( y_flag ) begin 
        case (cnt_r[4:2])
            3'b000 : begin cbf_flag_ul = cbf_flag_up[16]; cbf_flag_ur = cbf_flag_up[15]; cbf_flag_dl = cbf_flag_dn[16]; cbf_flag_dr = cbf_flag_dn[15]; end  // ul | ur
            3'b001 : begin cbf_flag_ul = cbf_flag_up[14]; cbf_flag_ur = cbf_flag_up[13]; cbf_flag_dl = cbf_flag_dn[14]; cbf_flag_dr = cbf_flag_dn[13]; end  // dl | dr
            3'b010 : begin cbf_flag_ul = cbf_flag_up[12]; cbf_flag_ur = cbf_flag_up[11]; cbf_flag_dl = cbf_flag_dn[12]; cbf_flag_dr = cbf_flag_dn[11]; end 
            3'b011 : begin cbf_flag_ul = cbf_flag_up[10]; cbf_flag_ur = cbf_flag_up[ 9]; cbf_flag_dl = cbf_flag_dn[10]; cbf_flag_dr = cbf_flag_dn[ 9]; end 
            3'b100 : begin cbf_flag_ul = cbf_flag_up[ 8]; cbf_flag_ur = cbf_flag_up[ 7]; cbf_flag_dl = cbf_flag_dn[ 8]; cbf_flag_dr = cbf_flag_dn[ 7]; end 
            3'b101 : begin cbf_flag_ul = cbf_flag_up[ 6]; cbf_flag_ur = cbf_flag_up[ 5]; cbf_flag_dl = cbf_flag_dn[ 6]; cbf_flag_dr = cbf_flag_dn[ 5]; end 
            3'b110 : begin cbf_flag_ul = cbf_flag_up[ 4]; cbf_flag_ur = cbf_flag_up[ 3]; cbf_flag_dl = cbf_flag_dn[ 4]; cbf_flag_dr = cbf_flag_dn[ 3]; end 
            3'b111 : begin cbf_flag_ul = cbf_flag_up[ 2]; cbf_flag_ur = cbf_flag_up[ 1]; cbf_flag_dl = cbf_flag_dn[ 2]; cbf_flag_dr = cbf_flag_dn[ 1]; end 
            default: begin cbf_flag_ul = 1'b0           ; cbf_flag_ur = 1'b0           ; cbf_flag_dl = 1'b0           ; cbf_flag_dr = 1'b0           ; end 
        endcase 
    end else begin 
        cbf_flag_ul = 1'b0         ; cbf_flag_ur = 1'b0         ; cbf_flag_dl = 1'b0         ; cbf_flag_dr = 1'b0         ;
    end 
end 

always @ (*) begin 
    case ( cnt_r[1:0] )
        2'b00 : begin cbf_p_r = cbf_flag_ul; cbf_q_r = cbf_flag_ur; end 
        2'b01 : begin cbf_p_r = cbf_flag_dl; cbf_q_r = cbf_flag_dr; end 
        2'b10 : begin cbf_p_r = cbf_flag_ul; cbf_q_r = cbf_flag_dl; end 
        2'b11 : begin cbf_p_r = cbf_flag_ur; cbf_q_r = cbf_flag_dr; end 
    endcase 
end 

always @ (posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) begin 
        cbf_p_o <= 1'b0;
        cbf_q_o <= 1'b0;
    end else begin 
        cbf_p_o <= cbf_p_r;
        cbf_q_o <= cbf_q_r;
    end 
end 
//----------------------------------------------------------------------------------------------
//
//      qp  modified 
//
//----------------------------------------------------------------------------------------------
//store two qp values and modified flag of every lcu
//modified flag ==1 indicatesthe 8x8 qp is modified 
//input [255:0]     mb_cbf_i        ;// cbf for every 4x4 cu , zig-zag scan order    
//input [255:0]     mb_cbf_u_i      ;// cbf for every 4x4 cu , zig-zag scan order  
//input [255:0]     mb_cbf_v_i      ;// cbf for every 4x4 cu , zig-zag scan order 

wire   [63:0]       qp_flag                 ;//=1 , modified in zig-zag scan order 

wire  [19:0]        qp_top_reg              ;//[5:0] qp_top [11:6]:qp_top_modified [19:12]:qp_top_flag[7:0] 


reg  [5:0]          qp_top                  ;
reg  [5:0]          qp_top_modified         ;
reg  [7:0]          qp_top_flag             ;

reg   [5:0]         qp_left                 ;
reg   [5:0]         qp_left_modified        ;
reg   [7:0]         qp_left_flag            ;

wire    qp_first  =   ((sys_ctu_x_i!=0) || (sys_ctu_y_i!=0)) ? ((!(mb_partition_i[0]||(mb_cbf_i!=0)||(mb_cbf_u_i!=0)||(mb_cbf_v_i!=0)))||mb_partition_i[0]):1'b0;

db_qp   udbpq_00(clk , rst_n, mb_cbf_i[0] , mb_cbf_u_i[0] , mb_cbf_v_i[0] ,  qp_first , qp_flag[0]  );// 0
db_qp   udbpq_01(clk , rst_n, mb_cbf_i[4] , mb_cbf_u_i[4] , mb_cbf_v_i[4] , qp_flag[0], qp_flag[1]  );// 1
db_qp   udbpq_10(clk , rst_n, mb_cbf_i[8] , mb_cbf_u_i[8] , mb_cbf_v_i[8] , qp_flag[1], qp_flag[2]  );// 2
db_qp   udbpq_11(clk , rst_n, mb_cbf_i[12], mb_cbf_u_i[12], mb_cbf_v_i[12], qp_flag[2], qp_flag[3]  );// 3
db_qp   udbpq_02(clk , rst_n, mb_cbf_i[16], mb_cbf_u_i[16], mb_cbf_v_i[16], qp_flag[3], qp_flag[4]  );// 4
db_qp   udbpq_03(clk , rst_n, mb_cbf_i[20], mb_cbf_u_i[20], mb_cbf_v_i[20], qp_flag[4], qp_flag[5]  );// 5
db_qp   udbpq_12(clk , rst_n, mb_cbf_i[24], mb_cbf_u_i[24], mb_cbf_v_i[24], qp_flag[5], qp_flag[6]  );// 6
db_qp   udbpq_13(clk , rst_n, mb_cbf_i[28], mb_cbf_u_i[28], mb_cbf_v_i[28], qp_flag[6], qp_flag[7]  );// 7
 
db_qp   udbpq_20(clk , rst_n, mb_cbf_i[32], mb_cbf_u_i[32], mb_cbf_v_i[32], qp_flag[ 7], qp_flag[ 8]);// 8
db_qp   udbpq_21(clk , rst_n, mb_cbf_i[36], mb_cbf_u_i[36], mb_cbf_v_i[36], qp_flag[ 8], qp_flag[ 9]);// 9
db_qp   udbpq_30(clk , rst_n, mb_cbf_i[40], mb_cbf_u_i[40], mb_cbf_v_i[40], qp_flag[ 9], qp_flag[10]);//10
db_qp   udbpq_31(clk , rst_n, mb_cbf_i[44], mb_cbf_u_i[44], mb_cbf_v_i[44], qp_flag[10], qp_flag[11]);//11
db_qp   udbpq_22(clk , rst_n, mb_cbf_i[48], mb_cbf_u_i[48], mb_cbf_v_i[48], qp_flag[11], qp_flag[12]);//12
db_qp   udbpq_23(clk , rst_n, mb_cbf_i[52], mb_cbf_u_i[52], mb_cbf_v_i[52], qp_flag[12], qp_flag[13]);//13
db_qp   udbpq_32(clk , rst_n, mb_cbf_i[56], mb_cbf_u_i[56], mb_cbf_v_i[56], qp_flag[13], qp_flag[14]);//14
db_qp   udbpq_33(clk , rst_n, mb_cbf_i[60], mb_cbf_u_i[60], mb_cbf_v_i[60], qp_flag[14], qp_flag[15]);//15

db_qp   udbpq_04(clk , rst_n, mb_cbf_i[64], mb_cbf_u_i[64], mb_cbf_v_i[64], qp_flag[15], qp_flag[16]);//16
db_qp   udbpq_05(clk , rst_n, mb_cbf_i[68], mb_cbf_u_i[68], mb_cbf_v_i[68], qp_flag[16], qp_flag[17]);//17
db_qp   udbpq_14(clk , rst_n, mb_cbf_i[72], mb_cbf_u_i[72], mb_cbf_v_i[72], qp_flag[17], qp_flag[18]);//18
db_qp   udbpq_15(clk , rst_n, mb_cbf_i[76], mb_cbf_u_i[76], mb_cbf_v_i[76], qp_flag[18], qp_flag[19]);//19
db_qp   udbpq_06(clk , rst_n, mb_cbf_i[80], mb_cbf_u_i[80], mb_cbf_v_i[80], qp_flag[19], qp_flag[20]);//20
db_qp   udbpq_07(clk , rst_n, mb_cbf_i[84], mb_cbf_u_i[84], mb_cbf_v_i[84], qp_flag[20], qp_flag[21]);//21
db_qp   udbpq_16(clk , rst_n, mb_cbf_i[88], mb_cbf_u_i[88], mb_cbf_v_i[88], qp_flag[21], qp_flag[22]);//22
db_qp   udbpq_17(clk , rst_n, mb_cbf_i[92], mb_cbf_u_i[92], mb_cbf_v_i[92], qp_flag[22], qp_flag[23]);//23

db_qp   udbpq_24(clk , rst_n, mb_cbf_i[ 96], mb_cbf_u_i[ 96], mb_cbf_v_i[ 96], qp_flag[23], qp_flag[24]);//24
db_qp   udbpq_25(clk , rst_n, mb_cbf_i[100], mb_cbf_u_i[100], mb_cbf_v_i[100], qp_flag[24], qp_flag[25]);//25
db_qp   udbpq_34(clk , rst_n, mb_cbf_i[104], mb_cbf_u_i[104], mb_cbf_v_i[104], qp_flag[25], qp_flag[26]);//26
db_qp   udbpq_35(clk , rst_n, mb_cbf_i[108], mb_cbf_u_i[108], mb_cbf_v_i[108], qp_flag[26], qp_flag[27]);//27
db_qp   udbpq_26(clk , rst_n, mb_cbf_i[112], mb_cbf_u_i[112], mb_cbf_v_i[112], qp_flag[27], qp_flag[28]);//28
db_qp   udbpq_27(clk , rst_n, mb_cbf_i[116], mb_cbf_u_i[116], mb_cbf_v_i[116], qp_flag[28], qp_flag[29]);//29
db_qp   udbpq_36(clk , rst_n, mb_cbf_i[120], mb_cbf_u_i[120], mb_cbf_v_i[120], qp_flag[29], qp_flag[30]);//30
db_qp   udbpq_37(clk , rst_n, mb_cbf_i[124], mb_cbf_u_i[124], mb_cbf_v_i[124], qp_flag[30], qp_flag[31]);//31

db_qp   udbpq_40(clk , rst_n, mb_cbf_i[128], mb_cbf_u_i[128], mb_cbf_v_i[128], qp_flag[31], qp_flag[32]);//32
db_qp   udbpq_41(clk , rst_n, mb_cbf_i[132], mb_cbf_u_i[132], mb_cbf_v_i[132], qp_flag[32], qp_flag[33]);//33
db_qp   udbpq_50(clk , rst_n, mb_cbf_i[136], mb_cbf_u_i[136], mb_cbf_v_i[136], qp_flag[33], qp_flag[34]);//34
db_qp   udbpq_51(clk , rst_n, mb_cbf_i[140], mb_cbf_u_i[140], mb_cbf_v_i[140], qp_flag[34], qp_flag[35]);//35
db_qp   udbpq_42(clk , rst_n, mb_cbf_i[144], mb_cbf_u_i[144], mb_cbf_v_i[144], qp_flag[35], qp_flag[36]);//36
db_qp   udbpq_43(clk , rst_n, mb_cbf_i[148], mb_cbf_u_i[148], mb_cbf_v_i[148], qp_flag[36], qp_flag[37]);//37
db_qp   udbpq_52(clk , rst_n, mb_cbf_i[152], mb_cbf_u_i[152], mb_cbf_v_i[152], qp_flag[37], qp_flag[38]);//38
db_qp   udbpq_53(clk , rst_n, mb_cbf_i[156], mb_cbf_u_i[156], mb_cbf_v_i[156], qp_flag[38], qp_flag[39]);//39
 
db_qp   udbpq_60(clk , rst_n, mb_cbf_i[160], mb_cbf_u_i[160], mb_cbf_v_i[160], qp_flag[39], qp_flag[40]);//40
db_qp   udbpq_61(clk , rst_n, mb_cbf_i[164], mb_cbf_u_i[164], mb_cbf_v_i[164], qp_flag[40], qp_flag[41]);//41
db_qp   udbpq_70(clk , rst_n, mb_cbf_i[168], mb_cbf_u_i[168], mb_cbf_v_i[168], qp_flag[41], qp_flag[42]);//42
db_qp   udbpq_71(clk , rst_n, mb_cbf_i[172], mb_cbf_u_i[172], mb_cbf_v_i[172], qp_flag[42], qp_flag[43]);//43
db_qp   udbpq_62(clk , rst_n, mb_cbf_i[176], mb_cbf_u_i[176], mb_cbf_v_i[176], qp_flag[43], qp_flag[44]);//44
db_qp   udbpq_63(clk , rst_n, mb_cbf_i[180], mb_cbf_u_i[180], mb_cbf_v_i[180], qp_flag[44], qp_flag[45]);//45
db_qp   udbpq_72(clk , rst_n, mb_cbf_i[184], mb_cbf_u_i[184], mb_cbf_v_i[184], qp_flag[45], qp_flag[46]);//46
db_qp   udbpq_73(clk , rst_n, mb_cbf_i[188], mb_cbf_u_i[188], mb_cbf_v_i[188], qp_flag[46], qp_flag[47]);//47

db_qp   udbpq_44(clk , rst_n, mb_cbf_i[192], mb_cbf_u_i[192], mb_cbf_v_i[192], qp_flag[47], qp_flag[48]);//48
db_qp   udbpq_45(clk , rst_n, mb_cbf_i[196], mb_cbf_u_i[196], mb_cbf_v_i[196], qp_flag[48], qp_flag[49]);//49
db_qp   udbpq_54(clk , rst_n, mb_cbf_i[200], mb_cbf_u_i[200], mb_cbf_v_i[200], qp_flag[49], qp_flag[50]);//50
db_qp   udbpq_55(clk , rst_n, mb_cbf_i[204], mb_cbf_u_i[204], mb_cbf_v_i[204], qp_flag[50], qp_flag[51]);//51
db_qp   udbpq_46(clk , rst_n, mb_cbf_i[208], mb_cbf_u_i[208], mb_cbf_v_i[208], qp_flag[51], qp_flag[52]);//52
db_qp   udbpq_47(clk , rst_n, mb_cbf_i[212], mb_cbf_u_i[212], mb_cbf_v_i[212], qp_flag[52], qp_flag[53]);//53
db_qp   udbpq_56(clk , rst_n, mb_cbf_i[216], mb_cbf_u_i[216], mb_cbf_v_i[216], qp_flag[53], qp_flag[54]);//54
db_qp   udbpq_57(clk , rst_n, mb_cbf_i[220], mb_cbf_u_i[220], mb_cbf_v_i[220], qp_flag[54], qp_flag[55]);//55

db_qp   udbpq_64(clk , rst_n, mb_cbf_i[224], mb_cbf_u_i[224], mb_cbf_v_i[224], qp_flag[55], qp_flag[56]);//56
db_qp   udbpq_65(clk , rst_n, mb_cbf_i[228], mb_cbf_u_i[228], mb_cbf_v_i[228], qp_flag[56], qp_flag[57]);//57
db_qp   udbpq_74(clk , rst_n, mb_cbf_i[232], mb_cbf_u_i[232], mb_cbf_v_i[232], qp_flag[57], qp_flag[58]);//58
db_qp   udbpq_75(clk , rst_n, mb_cbf_i[236], mb_cbf_u_i[236], mb_cbf_v_i[236], qp_flag[58], qp_flag[59]);//59
db_qp   udbpq_66(clk , rst_n, mb_cbf_i[240], mb_cbf_u_i[240], mb_cbf_v_i[240], qp_flag[59], qp_flag[60]);//60
db_qp   udbpq_67(clk , rst_n, mb_cbf_i[244], mb_cbf_u_i[244], mb_cbf_v_i[244], qp_flag[60], qp_flag[61]);//61
db_qp   udbpq_76(clk , rst_n, mb_cbf_i[248], mb_cbf_u_i[248], mb_cbf_v_i[248], qp_flag[61], qp_flag[62]);//62
db_qp   udbpq_77(clk , rst_n, mb_cbf_i[252], mb_cbf_u_i[252], mb_cbf_v_i[252], qp_flag[62], qp_flag[63]);//63


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        qp_left_flag    <=  8'b0;   
    else  if(state_i==OUT)
        qp_left_flag    <=  {qp_flag[21],qp_flag[23],qp_flag[29],qp_flag[31],qp_flag[53],qp_flag[55],qp_flag[61],qp_flag[63]};
    else
        qp_left_flag    <=  qp_left_flag    ;
end

always @(posedge clk or negedge rst_n)  begin
    if(!rst_n) begin
        qp_left             <=  6'd0;
        qp_left_modified    <=  6'd0;
    end
    else if(state_i==OUT&&(cnt_i==0)) begin
        qp_left_modified    <=  qp_left      ;
        qp_left             <=   qp_flag[63] ? qp_left:qp_i  ;
    end
    else begin  
        qp_left             <=  qp_left          ;
        qp_left_modified    <=  qp_left_modified ;
    end
end

wire                         qp_ram_cen_w     ;//chip  enable ,low active
wire                         qp_ram_oen_w     ;//read  enable ,low active
wire                         qp_ram_wen_w     ;//write enable ,low active
wire  [`PIC_X_WIDTH-1:0]     qp_ram_addr_w    ;//address 
wire  [19:0]                 qp_ram_data_o    ;//data output

reg                          qp_ram_oen_r     ;//read  enable ,low active 

assign qp_ram_cen_w = state_i == LOAD || state_i ==OUT ? 1'b0 : 1'b1;
assign qp_ram_oen_w = state_i == LOAD && (cnt_i == 0)  ? 1'b0 : 1'b1;
assign qp_ram_wen_w = state_i == OUT  && (cnt_i == 0)  ? 1'b0 : 1'b1;
assign qp_ram_addr_w= sys_ctu_x_i ;

db_qp_ram_sp_64x20 u_db_qp_ram_sp_64x20(
    .clk        ( clk              ) ,
    .adr_i      ( qp_ram_addr_w    ) ,
    .cen_i      ( qp_ram_cen_w     ) , // low active
    .wen_i      ( qp_ram_wen_w     ) ,
    .wr_dat_i   ( qp_top_reg       ) ,
    .rd_dat_o   ( qp_ram_data_o    ) 
    );  
                    
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        qp_ram_oen_r    <=  1'b0            ;
    else
        qp_ram_oen_r    <=  qp_ram_oen_w    ;       
end                 

assign  qp_top_reg       =  {qp_flag[63],qp_flag[62],qp_flag[59],qp_flag[58],qp_flag[47],qp_flag[46],qp_flag[43],qp_flag[42],qp_left,qp_i};

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin 
        qp_top           <=  6'd0  ;
        qp_top_modified  <=  6'd0  ;
        qp_top_flag      <=  8'd0  ;
    end 
    else if(sys_ctu_y_i!= 0 && (!qp_ram_oen_r)) begin 
        qp_top           <=  qp_ram_data_o[5:0]   ;
        qp_top_modified  <=  qp_ram_data_o[11:6]  ;
        qp_top_flag      <=  qp_ram_data_o[19:12] ;
    end 
end 



/*
assign  qp_top           =  qp_ram_oen_r  ? qp_top         :qp_ram_data_o[5:0]   ;
assign  qp_top_modified  =  qp_ram_oen_r  ? qp_top_modified:qp_ram_data_o[11:6]  ;
assign  qp_top_flag      =  qp_ram_oen_r  ? qp_top_flag    :qp_ram_data_o[19:12] ;
*/

wire [8:0]  qp_flag_h0  ; 
wire [8:0]  qp_flag_h1  ; 
wire [8:0]  qp_flag_h2  ; 
wire [8:0]  qp_flag_h3  ; 
wire [8:0]  qp_flag_h4  ; 
wire [8:0]  qp_flag_h5  ; 
wire [8:0]  qp_flag_h6  ; 
wire [8:0]  qp_flag_h7  ; 
wire [8:0]  qp_flag_h8  ;

assign qp_flag_h0   = {1'b0, qp_top_flag[0 ],qp_top_flag[1 ],qp_top_flag[2 ],qp_top_flag[3 ],qp_top_flag[4 ],qp_top_flag[5 ],qp_top_flag[6 ],qp_top_flag[7 ]} ;
assign qp_flag_h1   = {qp_left_flag[7],qp_flag[ 0],qp_flag[ 1],qp_flag[ 4],qp_flag[ 5],qp_flag[16],qp_flag[17],qp_flag[20],qp_flag[21]};
assign qp_flag_h2   = {qp_left_flag[6],qp_flag[ 2],qp_flag[ 3],qp_flag[ 6],qp_flag[ 7],qp_flag[18],qp_flag[19],qp_flag[22],qp_flag[23]};
assign qp_flag_h3   = {qp_left_flag[5],qp_flag[ 8],qp_flag[ 9],qp_flag[12],qp_flag[13],qp_flag[24],qp_flag[25],qp_flag[28],qp_flag[29]};
assign qp_flag_h4   = {qp_left_flag[4],qp_flag[10],qp_flag[11],qp_flag[14],qp_flag[15],qp_flag[26],qp_flag[27],qp_flag[30],qp_flag[31]};
assign qp_flag_h5   = {qp_left_flag[3],qp_flag[32],qp_flag[33],qp_flag[36],qp_flag[37],qp_flag[48],qp_flag[49],qp_flag[52],qp_flag[53]};
assign qp_flag_h6   = {qp_left_flag[2],qp_flag[34],qp_flag[35],qp_flag[38],qp_flag[39],qp_flag[50],qp_flag[51],qp_flag[54],qp_flag[55]};
assign qp_flag_h7   = {qp_left_flag[1],qp_flag[40],qp_flag[41],qp_flag[44],qp_flag[45],qp_flag[56],qp_flag[57],qp_flag[60],qp_flag[61]};
assign qp_flag_h8   = {qp_left_flag[0],qp_flag[42],qp_flag[43],qp_flag[46],qp_flag[47],qp_flag[58],qp_flag[59],qp_flag[62],qp_flag[63]};

reg [8:0] qp_flag_up, qp_flag_dn;
reg qp_flag_ul, qp_flag_ur, qp_flag_dl, qp_flag_dr;

always @ (*) begin 
    if ( y_flag ) begin // Y
        case (cnt_r[7:5])
            3'b000 : begin qp_flag_up = qp_flag_h0; qp_flag_dn = qp_flag_h1; end 
            3'b001 : begin qp_flag_up = qp_flag_h1; qp_flag_dn = qp_flag_h2; end 
            3'b010 : begin qp_flag_up = qp_flag_h2; qp_flag_dn = qp_flag_h3; end 
            3'b011 : begin qp_flag_up = qp_flag_h3; qp_flag_dn = qp_flag_h4; end 
            3'b100 : begin qp_flag_up = qp_flag_h4; qp_flag_dn = qp_flag_h5; end 
            3'b101 : begin qp_flag_up = qp_flag_h5; qp_flag_dn = qp_flag_h6; end 
            3'b110 : begin qp_flag_up = qp_flag_h6; qp_flag_dn = qp_flag_h7; end 
            3'b111 : begin qp_flag_up = qp_flag_h7; qp_flag_dn = qp_flag_h8; end 
            default: begin qp_flag_up = 9'd0      ; qp_flag_dn = 9'd0      ; end 
        endcase 
    end 
    else begin  // U and V
        case (cnt_r[5:4])
            2'b00  : begin qp_flag_up = qp_flag_h0; qp_flag_dn = qp_flag_h1; end 
            2'b01  : begin qp_flag_up = qp_flag_h2; qp_flag_dn = qp_flag_h3; end 
            2'b10  : begin qp_flag_up = qp_flag_h4; qp_flag_dn = qp_flag_h5; end 
            2'b11  : begin qp_flag_up = qp_flag_h6; qp_flag_dn = qp_flag_h7; end 
            default: begin qp_flag_up = 9'd0      ; qp_flag_dn = 9'd0      ; end 
        endcase 
    end
end 

always @ (*) begin 
    if ( y_flag ) begin 
        case (cnt_r[4:2])
            3'b000 : begin qp_flag_ul = qp_flag_up[8]; qp_flag_ur = qp_flag_up[7]; qp_flag_dl = qp_flag_dn[8]; qp_flag_dr = qp_flag_dn[7]; end  // ul | ur
            3'b001 : begin qp_flag_ul = qp_flag_up[7]; qp_flag_ur = qp_flag_up[6]; qp_flag_dl = qp_flag_dn[7]; qp_flag_dr = qp_flag_dn[6]; end  // dl | dr
            3'b010 : begin qp_flag_ul = qp_flag_up[6]; qp_flag_ur = qp_flag_up[5]; qp_flag_dl = qp_flag_dn[6]; qp_flag_dr = qp_flag_dn[5]; end 
            3'b011 : begin qp_flag_ul = qp_flag_up[5]; qp_flag_ur = qp_flag_up[4]; qp_flag_dl = qp_flag_dn[5]; qp_flag_dr = qp_flag_dn[4]; end 
            3'b100 : begin qp_flag_ul = qp_flag_up[4]; qp_flag_ur = qp_flag_up[3]; qp_flag_dl = qp_flag_dn[4]; qp_flag_dr = qp_flag_dn[3]; end 
            3'b101 : begin qp_flag_ul = qp_flag_up[3]; qp_flag_ur = qp_flag_up[2]; qp_flag_dl = qp_flag_dn[3]; qp_flag_dr = qp_flag_dn[2]; end 
            3'b110 : begin qp_flag_ul = qp_flag_up[2]; qp_flag_ur = qp_flag_up[1]; qp_flag_dl = qp_flag_dn[2]; qp_flag_dr = qp_flag_dn[1]; end 
            3'b111 : begin qp_flag_ul = qp_flag_up[1]; qp_flag_ur = qp_flag_up[0]; qp_flag_dl = qp_flag_dn[1]; qp_flag_dr = qp_flag_dn[0]; end 
            default: begin qp_flag_ul = 1'b0         ; qp_flag_ur = 1'b0         ; qp_flag_dl = 1'b0         ; qp_flag_dr = 1'b0         ; end 
        endcase 
    end else begin 
        case (cnt_r[3:2])
            2'b00  : begin qp_flag_ul = qp_flag_up[8]; qp_flag_ur = qp_flag_up[7]; qp_flag_dl = qp_flag_dn[8]; qp_flag_dr = qp_flag_dn[7]; end 
            2'b01  : begin qp_flag_ul = qp_flag_up[6]; qp_flag_ur = qp_flag_up[5]; qp_flag_dl = qp_flag_dn[6]; qp_flag_dr = qp_flag_dn[4]; end 
            2'b10  : begin qp_flag_ul = qp_flag_up[4]; qp_flag_ur = qp_flag_up[3]; qp_flag_dl = qp_flag_dn[4]; qp_flag_dr = qp_flag_dn[3]; end 
            2'b11  : begin qp_flag_ul = qp_flag_up[2]; qp_flag_ur = qp_flag_up[1]; qp_flag_dl = qp_flag_dn[2]; qp_flag_dr = qp_flag_dn[1]; end 
            default: begin qp_flag_ul = 1'b0         ; qp_flag_ur = 1'b0         ; qp_flag_dl = 1'b0         ; qp_flag_dr = 1'b0         ; end 
			endcase
    end 
end 


//******************************************************************************************************
//                                             
//                      select qp
//                                             
//******************************************************************************************************

reg     [5:0]   qp_p_r  ,    qp_q_r    ;

wire     [5:0]   qp_tl      ;

assign  qp_tl   =   qp_top_flag[7] ? qp_top_modified:qp_top;

always @ (*) begin 
    if ( top_left_flag ) begin // top-left
        case ( cnt_r[1:0] )
            2'b00 : begin qp_p_r = qp_tl                                ; qp_q_r = qp_flag_ur ? qp_top_modified :qp_top ; end 
            2'b01 : begin qp_p_r = qp_flag_dl ? qp_left_modified:qp_left; qp_q_r = qp_flag_dr ? qp_left_modified:qp_left; end 
            2'b10 : begin qp_p_r = qp_flag_ul ? qp_left_modified:qp_left; qp_q_r = qp_flag_dl ? qp_left_modified:qp_left; end 
            2'b11 : begin qp_p_r = qp_flag_ur ? qp_top_modified :qp_top ; qp_q_r = qp_flag_dr ? qp_left         :qp_i   ; end 
        endcase 
    end else if ( top_flag) begin // top
        case ( cnt_r[1:0] )
            2'b00 : begin qp_p_r = qp_flag_ul ? qp_top_modified :qp_top ; qp_q_r = qp_flag_ur ? qp_top_modified :qp_top ; end 
            2'b01 : begin qp_p_r = qp_flag_dl ? qp_left         :qp_i   ; qp_q_r = qp_flag_dr ? qp_left         :qp_i   ; end 
            2'b10 : begin qp_p_r = qp_flag_ul ? qp_top_modified :qp_top ; qp_q_r = qp_flag_dl ? qp_left         :qp_i   ; end 
            2'b11 : begin qp_p_r = qp_flag_ur ? qp_top_modified :qp_top ; qp_q_r = qp_flag_dr ? qp_left         :qp_i   ; end 
        endcase 
    end else if (left_flag) begin// left
        case ( cnt_r[1:0] )
            2'b00 : begin qp_p_r = qp_flag_ul ? qp_left_modified:qp_left ; qp_q_r = qp_flag_ur ? qp_left         :qp_i   ; end 
            2'b01 : begin qp_p_r = qp_flag_dl ? qp_left_modified:qp_left ; qp_q_r = qp_flag_dr ? qp_left         :qp_i   ; end 
            2'b10 : begin qp_p_r = qp_flag_ul ? qp_left_modified:qp_left ; qp_q_r = qp_flag_dl ? qp_left_modified:qp_left; end 
            2'b11 : begin qp_p_r = qp_flag_ur ? qp_left         :qp_i    ; qp_q_r = qp_flag_dr ? qp_left         :qp_i   ; end 
        endcase 
    end 
    else begin
        case ( cnt_r[1:0] )
            2'b00 : begin qp_p_r = qp_flag_ul ? qp_left         :qp_i    ; qp_q_r = qp_flag_ur ? qp_left         :qp_i   ; end 
            2'b01 : begin qp_p_r = qp_flag_dl ? qp_left         :qp_i    ; qp_q_r = qp_flag_dr ? qp_left         :qp_i   ; end 
            2'b10 : begin qp_p_r = qp_flag_ul ? qp_left         :qp_i    ; qp_q_r = qp_flag_dl ? qp_left         :qp_i   ; end 
            2'b11 : begin qp_p_r = qp_flag_ur ? qp_left         :qp_i    ; qp_q_r = qp_flag_dr ? qp_left         :qp_i   ; end 
        endcase 
    end
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if (!rst_n) begin 
        qp_p_o <= 'd0;
        qp_q_o <= 'd0;
    end 
    else begin 
        qp_p_o <= qp_p_r;
        qp_q_o <= qp_q_r;
    end 
end 
endmodule 