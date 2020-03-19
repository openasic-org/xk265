//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.02.24
//file name     : be.v
//delay         :  
//describe      :
//modification  :
//v1.0          :
module dct_top_2d(
	clk         ,
	rst_n       ,
	i_inverse   ,
	i_transize  ,
	i_tq_sel    ,
	i_valid     ,
	i_0         ,	
	i_1         ,	
	i_2         ,	
	i_3         ,	
	i_4         ,	
	i_5         ,	
	i_6         ,	
	i_7         ,	
	i_8         ,	
	i_9         ,	
	i_10        ,	
	i_11        ,	
	i_12        ,	
	i_13        ,	
	i_14        ,	
	i_15        ,	
	i_16        ,	
	i_17        ,	
	i_18        ,	
	i_19        ,	
	i_20        ,	
	i_21        ,	
	i_22        ,	
	i_23        ,	
	i_24        ,	
	i_25        ,	
	i_26        ,	
	i_27        ,	
	i_28        ,	
	i_29        ,	
	i_30        ,	
	i_31        ,
//------------------------
	o_valid     ,	
	o_0         ,	
	o_1         ,	
	o_2         ,	
	o_3         ,	
	o_4         ,	
	o_5         ,	
	o_6         ,	
	o_7         ,	
	o_8         ,	
	o_9         ,	
	o_10        ,	
	o_11        ,	
	o_12        ,	
	o_13        ,	
	o_14        ,	
	o_15        ,	
	o_16        ,	
	o_17        ,	
	o_18        ,	
	o_19        ,	
	o_20        ,	
	o_21        ,	
	o_22        ,	
	o_23        ,	
	o_24        ,	
	o_25        ,	
	o_26        ,	
	o_27        ,
	o_28        ,	
	o_29        ,	
	o_30        ,	
	o_31        	
);

input  	        clk         ;
input  	        rst_n       ;
input           i_inverse   ;
input [1:0]  	i_transize  ;
input [1:0]	i_tq_sel    ;
input           i_valid     ;
input [15:0]	i_0         ;	
input [15:0]	i_1         ;	
input [15:0]	i_2         ;	
input [15:0]	i_3         ;	
input [15:0]	i_4         ;	
input [15:0]	i_5         ;	
input [15:0]	i_6         ;	
input [15:0]	i_7         ;	
input [15:0]	i_8         ;	
input [15:0]	i_9         ;	
input [15:0]	i_10        ;	
input [15:0]	i_11        ;	
input [15:0]	i_12        ;	
input [15:0]	i_13        ;	
input [15:0]	i_14        ;	
input [15:0]	i_15        ;	
input [15:0]	i_16        ;	
input [15:0]	i_17        ;	
input [15:0]	i_18        ;	
input [15:0]	i_19        ;	
input [15:0]	i_20        ;	
input [15:0]	i_21        ;	
input [15:0]	i_22        ;	
input [15:0]	i_23        ;	
input [15:0]	i_24        ;	
input [15:0]	i_25        ;	
input [15:0]	i_26        ;	
input [15:0]	i_27        ;	
input [15:0]	i_28        ;	
input [15:0]	i_29        ;	
input [15:0]	i_30        ;	
input [15:0]	i_31        ;
	
//--------
output wire          o_valid     ;
output wire [15:0]	o_0      ;	
output wire [15:0]	o_1      ;	
output wire [15:0]	o_2      ;	
output wire [15:0]	o_3      ;	
output wire [15:0]	o_4      ;	
output wire [15:0]	o_5      ;	
output wire [15:0]	o_6      ;	
output wire [15:0]	o_7      ;	
output wire [15:0]	o_8      ;	
output wire [15:0]	o_9      ;	
output wire [15:0]	o_10     ;	
output wire [15:0]	o_11     ;	
output wire [15:0]	o_12     ;	
output wire [15:0]	o_13     ;	
output wire [15:0]	o_14     ;	
output wire [15:0]	o_15     ;	
output wire [15:0]	o_16     ;	
output wire [15:0]	o_17     ;	
output wire [15:0]	o_18     ;	
output wire [15:0]	o_19     ;	
output wire [15:0]	o_20     ;	
output wire [15:0]	o_21     ;	
output wire [15:0]	o_22     ;	
output wire [15:0]	o_23     ;	
output wire [15:0]	o_24     ;	
output wire [15:0]	o_25     ;	
output wire [15:0]	o_26     ;	
output wire [15:0]	o_27     ;
output wire [15:0]	o_28     ;	
output wire [15:0]	o_29     ;	
output wire [15:0]	o_30     ;	
output wire [15:0]	o_31     ;	

//---------------ctl0---------------//
wire         valid_ctl0_mux2;        
wire         valid_ctl0_mux0;

//----------------mux0--------------//
wire         valid_ctl1_mux0   ;   

//-----------------be---------------------//
wire         be_dt_vld      ;   
wire [27:0]  be_0           ;
wire [27:0]  be_1           ;
wire [27:0]  be_2           ;
wire [27:0]  be_3           ;
wire [27:0]  be_4           ;
wire [27:0]  be_5           ;
wire [27:0]  be_6           ;
wire [27:0]  be_7           ;
wire [27:0]  be_8           ;
wire [27:0]  be_9           ;
wire [27:0]  be_10          ;
wire [27:0]  be_11          ;
wire [27:0]  be_12          ;
wire [27:0]  be_13          ;
wire [27:0]  be_14          ;
wire [27:0]  be_15          ;
wire [27:0]  be_16          ;
wire [27:0]  be_17          ;
wire [27:0]  be_18          ;
wire [27:0]  be_19          ;
wire [27:0]  be_20          ;
wire [27:0]  be_21          ;
wire [27:0]  be_22          ;
wire [27:0]  be_23          ;
wire [27:0]  be_24          ;
wire [27:0]  be_25          ;
wire [27:0]  be_26          ;
wire [27:0]  be_27          ;
wire [27:0]  be_28          ;
wire [27:0]  be_29          ;
wire [27:0]  be_30          ;
wire [27:0]  be_31          ;
//---------------ctl3----------------//
wire         vld_ctl3_mux3  ;   
wire         vld_ctl3_mux1  ;
wire[27:0]   dt_ctl3_0      ;
wire[27:0]   dt_ctl3_1      ;
wire[27:0]   dt_ctl3_2      ;
wire[27:0]   dt_ctl3_3      ;
wire[27:0]   dt_ctl3_4      ;
wire[27:0]   dt_ctl3_5      ;
wire[27:0]   dt_ctl3_6      ;
wire[27:0]   dt_ctl3_7      ;
wire[27:0]   dt_ctl3_8      ;
wire[27:0]   dt_ctl3_9      ;
wire[27:0]   dt_ctl3_10     ;
wire[27:0]   dt_ctl3_11     ;
wire[27:0]   dt_ctl3_12     ;
wire[27:0]   dt_ctl3_13     ;
wire[27:0]   dt_ctl3_14     ;
wire[27:0]   dt_ctl3_15     ;
wire[27:0]   dt_ctl3_16     ;
wire[27:0]   dt_ctl3_17     ;
wire[27:0]   dt_ctl3_18     ;
wire[27:0]   dt_ctl3_19     ;
wire[27:0]   dt_ctl3_20     ;
wire[27:0]   dt_ctl3_21     ;
wire[27:0]   dt_ctl3_22     ;
wire[27:0]   dt_ctl3_23     ;
wire[27:0]   dt_ctl3_24     ;
wire[27:0]   dt_ctl3_25     ;
wire[27:0]   dt_ctl3_26     ;
wire[27:0]   dt_ctl3_27     ;
wire[27:0]   dt_ctl3_28     ;
wire[27:0]   dt_ctl3_29     ;
wire[27:0]   dt_ctl3_30     ;
wire[27:0]   dt_ctl3_31     ;

wire         valid_mux0        ;           
wire [27:0]  dt_mux0_0         ;
wire [27:0]  dt_mux0_1         ;
wire [27:0]  dt_mux0_2         ;
wire [27:0]  dt_mux0_3         ;
wire [27:0]  dt_mux0_4         ;
wire [27:0]  dt_mux0_5         ;
wire [27:0]  dt_mux0_6         ;
wire [27:0]  dt_mux0_7         ;
wire [27:0]  dt_mux0_8         ;
wire [27:0]  dt_mux0_9         ;
wire [27:0]  dt_mux0_10        ;
wire [27:0]  dt_mux0_11        ;
wire [27:0]  dt_mux0_12        ;
wire [27:0]  dt_mux0_13        ;
wire [27:0]  dt_mux0_14        ;
wire [27:0]  dt_mux0_15        ;
wire [27:0]  dt_mux0_16        ;
wire [27:0]  dt_mux0_17        ;
wire [27:0]  dt_mux0_18        ;
wire [27:0]  dt_mux0_19        ;
wire [27:0]  dt_mux0_20        ;
wire [27:0]  dt_mux0_21        ;
wire [27:0]  dt_mux0_22        ;
wire [27:0]  dt_mux0_23        ;
wire [27:0]  dt_mux0_24        ;
wire [27:0]  dt_mux0_25        ;
wire [27:0]  dt_mux0_26        ;
wire [27:0]  dt_mux0_27        ;
wire [27:0]  dt_mux0_28        ;
wire [27:0]  dt_mux0_29        ;
wire [27:0]  dt_mux0_30        ;
wire [27:0]  dt_mux0_31        ;

//----------------mux1--------------//
wire         valid_pe_i           ; 
wire [15:0]  dt_petr_0            ; 
wire [15:0]  dt_petr_1            ; 
wire [15:0]  dt_petr_2            ; 
wire [15:0]  dt_petr_3            ; 
wire [15:0]  dt_petr_4            ; 
wire [15:0]  dt_petr_5            ; 
wire [15:0]  dt_petr_6            ; 
wire [15:0]  dt_petr_7            ; 
wire [15:0]  dt_petr_8            ; 
wire [15:0]  dt_petr_9            ; 
wire [15:0]  dt_petr_10           ; 
wire [15:0]  dt_petr_11           ; 
wire [15:0]  dt_petr_12           ; 
wire [15:0]  dt_petr_13           ; 
wire [15:0]  dt_petr_14           ; 
wire [15:0]  dt_petr_15           ; 
wire [15:0]  dt_petr_16           ; 
wire [15:0]  dt_petr_17           ; 
wire [15:0]  dt_petr_18           ; 
wire [15:0]  dt_petr_19           ; 
wire [15:0]  dt_petr_20           ; 
wire [15:0]  dt_petr_21           ; 
wire [15:0]  dt_petr_22           ; 
wire [15:0]  dt_petr_23           ; 
wire [15:0]  dt_petr_24           ; 
wire [15:0]  dt_petr_25           ; 
wire [15:0]  dt_petr_26           ; 
wire [15:0]  dt_petr_27           ; 
wire [15:0]  dt_petr_28           ; 
wire [15:0]  dt_petr_29           ; 
wire [15:0]  dt_petr_30           ; 
wire [15:0]  dt_petr_31           ;
  
wire         valid_mux1           ;          
wire [18:0]  dt_mux1_0            ;
wire [18:0]  dt_mux1_1            ;
wire [18:0]  dt_mux1_2            ;
wire [18:0]  dt_mux1_3            ;
wire [18:0]  dt_mux1_4            ;
wire [18:0]  dt_mux1_5            ;
wire [18:0]  dt_mux1_6            ;
wire [18:0]  dt_mux1_7            ;
wire [18:0]  dt_mux1_8            ;
wire [18:0]  dt_mux1_9            ;
wire [18:0]  dt_mux1_10           ;
wire [18:0]  dt_mux1_11           ;
wire [18:0]  dt_mux1_12           ;
wire [18:0]  dt_mux1_13           ;
wire [18:0]  dt_mux1_14           ;
wire [18:0]  dt_mux1_15           ;
wire [18:0]  dt_mux1_16           ;
wire [18:0]  dt_mux1_17           ;
wire [18:0]  dt_mux1_18           ;
wire [18:0]  dt_mux1_19           ;
wire [18:0]  dt_mux1_20           ;
wire [18:0]  dt_mux1_21           ;
wire [18:0]  dt_mux1_22           ;
wire [18:0]  dt_mux1_23           ;
wire [18:0]  dt_mux1_24           ;
wire [18:0]  dt_mux1_25           ;
wire [18:0]  dt_mux1_26           ;
wire [18:0]  dt_mux1_27           ;
wire [18:0]  dt_mux1_28           ;
wire [18:0]  dt_mux1_29           ;
wire [18:0]  dt_mux1_30           ;
wire [18:0]  dt_mux1_31           ;

//-----------------re---------------------//
wire         re_dt_vld      ;   
wire [27:0]  re_0           ;
wire [27:0]  re_1           ;
wire [27:0]  re_2           ;
wire [27:0]  re_3           ;
wire [27:0]  re_4           ;
wire [27:0]  re_5           ;
wire [27:0]  re_6           ;
wire [27:0]  re_7           ;
wire [27:0]  re_8           ;
wire [27:0]  re_9           ;
wire [27:0]  re_10          ;
wire [27:0]  re_11          ;
wire [27:0]  re_12          ;
wire [27:0]  re_13          ;
wire [27:0]  re_14          ;
wire [27:0]  re_15          ;
wire [27:0]  re_16          ;
wire [27:0]  re_17          ;
wire [27:0]  re_18          ;
wire [27:0]  re_19          ;
wire [27:0]  re_20          ;
wire [27:0]  re_21          ;
wire [27:0]  re_22          ;
wire [27:0]  re_23          ;
wire [27:0]  re_24          ;
wire [27:0]  re_25          ;
wire [27:0]  re_26          ;
wire [27:0]  re_27          ;
wire [27:0]  re_28          ;
wire [27:0]  re_29          ;
wire [27:0]  re_30          ;
wire [27:0]  re_31          ;
//-----------------ctl1----------------------//
wire         valid_ctl1_pe  ;
//-----------------pe----------------------//
wire         pe_dt_vld      ;
wire [27: 0] pe_0           ;  
wire [27: 0] pe_1           ;  
wire [27: 0] pe_2           ;  
wire [27: 0] pe_3           ;  
wire [27: 0] pe_4           ;  
wire [27: 0] pe_5           ;  
wire [27: 0] pe_6           ;  
wire [27: 0] pe_7           ;  
wire [27: 0] pe_8           ;  
wire [27: 0] pe_9           ;  
wire [27: 0] pe_10          ;  
wire [27: 0] pe_11          ;  
wire [27: 0] pe_12          ;  
wire [27: 0] pe_13          ;  
wire [27: 0] pe_14          ;  
wire [27: 0] pe_15          ;  
wire [27: 0] pe_16          ;  
wire [27: 0] pe_17          ;  
wire [27: 0] pe_18          ;  
wire [27: 0] pe_19          ;  
wire [27: 0] pe_20          ;  
wire [27: 0] pe_21          ;  
wire [27: 0] pe_22          ;  
wire [27: 0] pe_23          ;  
wire [27: 0] pe_24          ;  
wire [27: 0] pe_25          ;  
wire [27: 0] pe_26          ;  
wire [27: 0] pe_27          ;  
wire [27: 0] pe_28          ;  
wire [27: 0] pe_29          ;  
wire [27: 0] pe_30          ;  
wire [27: 0] pe_31          ;  

//---------------mux3------------------//
wire         valid_mux3     ;       
wire [27: 0] dt_mux3_0      ;
wire [27: 0] dt_mux3_1      ;
wire [27: 0] dt_mux3_2      ;
wire [27: 0] dt_mux3_3      ;
wire [27: 0] dt_mux3_4      ;
wire [27: 0] dt_mux3_5      ;
wire [27: 0] dt_mux3_6      ;
wire [27: 0] dt_mux3_7      ;
wire [27: 0] dt_mux3_8      ;
wire [27: 0] dt_mux3_9      ;
wire [27: 0] dt_mux3_10     ;
wire [27: 0] dt_mux3_11     ;
wire [27: 0] dt_mux3_12     ;
wire [27: 0] dt_mux3_13     ;
wire [27: 0] dt_mux3_14     ;
wire [27: 0] dt_mux3_15     ;
wire [27: 0] dt_mux3_16     ;
wire [27: 0] dt_mux3_17     ;
wire [27: 0] dt_mux3_18     ;
wire [27: 0] dt_mux3_19     ;
wire [27: 0] dt_mux3_20     ;
wire [27: 0] dt_mux3_21     ;
wire [27: 0] dt_mux3_22     ;
wire [27: 0] dt_mux3_23     ;
wire [27: 0] dt_mux3_24     ;
wire [27: 0] dt_mux3_25     ;
wire [27: 0] dt_mux3_26     ;
wire [27: 0] dt_mux3_27     ;
wire [27: 0] dt_mux3_28     ;
wire [27: 0] dt_mux3_29     ;
wire [27: 0] dt_mux3_30     ;
wire [27: 0] dt_mux3_31     ;
//---------------os logic---------------//
wire         dt_2d_vld      ;         
wire         tr_dt_vld      ;
wire [15: 0] os_0           ;
wire [15: 0] os_1           ;
wire [15: 0] os_2           ;
wire [15: 0] os_3           ;
wire [15: 0] os_4           ;
wire [15: 0] os_5           ;
wire [15: 0] os_6           ;
wire [15: 0] os_7           ;
wire [15: 0] os_8           ;
wire [15: 0] os_9           ;
wire [15: 0] os_10          ;
wire [15: 0] os_11          ;
wire [15: 0] os_12          ;
wire [15: 0] os_13          ;
wire [15: 0] os_14          ;
wire [15: 0] os_15          ;
wire [15: 0] os_16          ;
wire [15: 0] os_17          ;
wire [15: 0] os_18          ;
wire [15: 0] os_19          ;
wire [15: 0] os_20          ;
wire [15: 0] os_21          ;
wire [15: 0] os_22          ;
wire [15: 0] os_23          ;
wire [15: 0] os_24          ;
wire [15: 0] os_25          ;
wire [15: 0] os_26          ;
wire [15: 0] os_27          ;
wire [15: 0] os_28          ;
wire [15: 0] os_29          ;
wire [15: 0] os_30          ;
wire [15: 0] os_31          ;
//-------------transform logic-------------------//
wire         tr_valid       ;           
wire [15: 0] tr_0           ;
wire [15: 0] tr_1           ;
wire [15: 0] tr_2           ;
wire [15: 0] tr_3           ;
wire [15: 0] tr_4           ;
wire [15: 0] tr_5           ;
wire [15: 0] tr_6           ;
wire [15: 0] tr_7           ;
wire [15: 0] tr_8           ;
wire [15: 0] tr_9           ;
wire [15: 0] tr_10          ;
wire [15: 0] tr_11          ;
wire [15: 0] tr_12          ;
wire [15: 0] tr_13          ;
wire [15: 0] tr_14          ;
wire [15: 0] tr_15          ;
wire [15: 0] tr_16          ;
wire [15: 0] tr_17          ;
wire [15: 0] tr_18          ;
wire [15: 0] tr_19          ;
wire [15: 0] tr_20          ;
wire [15: 0] tr_21          ;
wire [15: 0] tr_22          ;
wire [15: 0] tr_23          ;
wire [15: 0] tr_24          ;
wire [15: 0] tr_25          ;
wire [15: 0] tr_26          ;
wire [15: 0] tr_27          ;
wire [15: 0] tr_28          ;
wire [15: 0] tr_29          ;
wire [15: 0] tr_30          ;
wire [15: 0] tr_31          ;

//--------------------ctl2---------------//
wire         valid_ctl2_mux0;    
wire         valid_ctl2_mux2;

//----------------mux2--------------//
wire         valid_mux2           ;                    
wire [15:0]  dt_mux2_0            ;
wire [15:0]  dt_mux2_1            ;
wire [15:0]  dt_mux2_2            ;
wire [15:0]  dt_mux2_3            ;
wire [15:0]  dt_mux2_4            ;
wire [15:0]  dt_mux2_5            ;
wire [15:0]  dt_mux2_6            ;
wire [15:0]  dt_mux2_7            ;
wire [15:0]  dt_mux2_8            ;
wire [15:0]  dt_mux2_9            ;
wire [15:0]  dt_mux2_10           ;
wire [15:0]  dt_mux2_11           ;
wire [15:0]  dt_mux2_12           ;
wire [15:0]  dt_mux2_13           ;
wire [15:0]  dt_mux2_14           ;
wire [15:0]  dt_mux2_15           ;
wire [15:0]  dt_mux2_16           ;
wire [15:0]  dt_mux2_17           ;
wire [15:0]  dt_mux2_18           ;
wire [15:0]  dt_mux2_19           ;
wire [15:0]  dt_mux2_20           ;
wire [15:0]  dt_mux2_21           ;
wire [15:0]  dt_mux2_22           ;
wire [15:0]  dt_mux2_23           ;
wire [15:0]  dt_mux2_24           ;
wire [15:0]  dt_mux2_25           ;
wire [15:0]  dt_mux2_26           ;
wire [15:0]  dt_mux2_27           ;
wire [15:0]  dt_mux2_28           ;
wire [15:0]  dt_mux2_29           ;
wire [15:0]  dt_mux2_30           ;
wire [15:0]  dt_mux2_31           ;
//----------row ctl-----------------//
wire         row                  ;

//-----------------------------------------------------------test -----------------------------------------//
/*
reg [15:0] mem0  [0:207360];
reg [15:0] mem1  [0:207360];
reg [15:0] mem2  [0:207360];
reg [15:0] mem3  [0:207360];
reg [15:0] mem4  [0:207360];
reg [15:0] mem5  [0:207360];
reg [15:0] mem6  [0:207360];
reg [15:0] mem7  [0:207360];
reg [15:0] mem8  [0:207360];
reg [15:0] mem9  [0:207360];
reg [15:0] mem10 [0:207360];
reg [15:0] mem11 [0:207360];
reg [15:0] mem12 [0:207360];
reg [15:0] mem13 [0:207360];
reg [15:0] mem14 [0:207360];
reg [15:0] mem15 [0:207360];
reg [15:0] mem16 [0:207360];
reg [15:0] mem17 [0:207360];
reg [15:0] mem18 [0:207360];
reg [15:0] mem19 [0:207360];
reg [15:0] mem20 [0:207360];
reg [15:0] mem21 [0:207360];
reg [15:0] mem22 [0:207360];
reg [15:0] mem23 [0:207360];
reg [15:0] mem24 [0:207360];
reg [15:0] mem25 [0:207360];
reg [15:0] mem26 [0:207360];
reg [15:0] mem27 [0:207360];
reg [15:0] mem28 [0:207360];
reg [15:0] mem29 [0:207360];
reg [15:0] mem30 [0:207360];
reg [15:0] mem31 [0:207360];

initial begin
$readmemh("./data/data0.txt",mem0);
$readmemh("./data/data1.txt",mem1);
$readmemh("./data/data2.txt",mem2);
$readmemh("./data/data3.txt",mem3);
$readmemh("./data/data4.txt",mem4);
$readmemh("./data/data5.txt",mem5);
$readmemh("./data/data6.txt",mem6);
$readmemh("./data/data7.txt",mem7);
$readmemh("./data/data8.txt",mem8);
$readmemh("./data/data9.txt",mem9);

$readmemh("./data/data10.txt",mem10);
$readmemh("./data/data11.txt",mem11);
$readmemh("./data/data12.txt",mem12);
$readmemh("./data/data13.txt",mem13);
$readmemh("./data/data14.txt",mem14);
$readmemh("./data/data15.txt",mem15);
$readmemh("./data/data16.txt",mem16);
$readmemh("./data/data17.txt",mem17);
$readmemh("./data/data18.txt",mem18);
$readmemh("./data/data19.txt",mem19);

$readmemh("./data/data20.txt",mem20);
$readmemh("./data/data21.txt",mem21);
$readmemh("./data/data22.txt",mem22);
$readmemh("./data/data23.txt",mem23);
$readmemh("./data/data24.txt",mem24);
$readmemh("./data/data25.txt",mem25);
$readmemh("./data/data26.txt",mem26);
$readmemh("./data/data27.txt",mem27);
$readmemh("./data/data28.txt",mem28);
$readmemh("./data/data29.txt",mem29);

$readmemh("./data/data30.txt",mem30);
$readmemh("./data/data31.txt",mem31);
end 

reg [31:0] addr;
reg        err0;
reg        err1;
reg        err2;
reg        err3;
reg        err4;
reg        err5;
reg        err6;
reg        err7;
reg        err8;
reg        err9;
reg        err10;
reg        err11;
reg        err12;
reg        err13;
reg        err14;
reg        err15;
reg        err16;
reg        err17;
reg        err18;
reg        err19;
reg        err20;
reg        err21;
reg        err22;
reg        err23;
reg        err24;
reg        err25;
reg        err26;
reg        err27;
reg        err28;
reg        err29;
reg        err30;
reg        err31;
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		addr <= 32'd0;
	else if(o_valid)
		addr <= addr + 1'b1;
end 

always @(*)
begin
	if(o_valid && (mem0[addr] != o_0))
		err0 =1'b1;
	else
		err0 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem1[addr] != o_1))
		err1 =1'b1;
	else
		err1 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem2[addr] != o_2))
		err2 =1'b1;
	else
		err2 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem3[addr] != o_3))
		err3 =1'b1;
	else
		err3 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem4[addr] != o_4))
		err4 =1'b1;
	else
		err4 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem5[addr] != o_5))
		err5 =1'b1;
	else
		err5 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem6[addr] != o_6))
		err6 =1'b1;
	else
		err6 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem7[addr] != o_7))
		err7 =1'b1;
	else
		err7 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem8[addr] != o_8))
		err8 =1'b1;
	else
		err8 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem9[addr] != o_9))
		err9 =1'b1;
	else
		err9 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem10[addr] != o_10))
		err10 =1'b1;
	else
		err10= 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem11[addr] != o_11))
		err11 =1'b1;
	else
		err11 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem12[addr] != o_12))
		err12 =1'b1;
	else
		err12 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem13[addr] != o_13))
		err13 =1'b1;
	else
		err13 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem14[addr] != o_14))
		err14 =1'b1;
	else
		err14 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem15[addr] != o_15))
		err15 =1'b1;
	else
		err15 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem16[addr] != o_16))
		err16 =1'b1;
	else
		err16 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem17[addr] != o_17))
		err17 =1'b1;
	else
		err17 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem18[addr] != o_18))
		err18 =1'b1;
	else
		err18 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem19[addr] != o_19))
		err19 =1'b1;
	else
		err19 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem20[addr] != o_20))
		err20 =1'b1;
	else
		err20 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem21[addr] != o_21))
		err21 =1'b1;
	else
		err21 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem22[addr] != o_22))
		err22 =1'b1;
	else
		err22 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem23[addr] != o_23))
		err23 =1'b1;
	else
		err23 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem24[addr] != o_24))
		err24 =1'b1;
	else
		err24 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem25[addr] != o_25))
		err25 =1'b1;
	else
		err25 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem26[addr] != o_26))
		err26 =1'b1;
	else
		err26 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem27[addr] != o_27))
		err27 =1'b1;
	else
		err27 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem28[addr] != o_28))
		err28 =1'b1;
	else
		err28 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem29[addr] != o_29))
		err29 =1'b1;
	else
		err29 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem30[addr] != o_30))
		err30 =1'b1;
	else
		err30 = 1'b0;
end 

always @(*)
begin
	if(o_valid && (mem31[addr] != o_31))
		err31 =1'b1;
	else
		err31 = 1'b0;
end 

*/


//-------------------------------------------------------------------------------------------------------------//


//---------------ctl0---------------//
ctl0    u_ctl0(
          .i_inverse   (i_inverse ),
	  .i_valid     (i_valid   ),
	  .o_valid0    (valid_ctl0_mux2),//to mux2
	  .o_valid1    (valid_ctl0_mux0)//to mux0 
);

mux_0  u_mux0(
          .i_valid0  (valid_ctl0_mux0),//ctl0 in
          .i_0_0     (i_0      ),
          .i_0_1     (i_1      ),
          .i_0_2     (i_2      ),
          .i_0_3     (i_3      ),
          .i_0_4     (i_4      ),
          .i_0_5     (i_5      ),
          .i_0_6     (i_6      ),
          .i_0_7     (i_7      ),
          .i_0_8     (i_8      ),
          .i_0_9     (i_9      ),
          .i_0_10    (i_10     ),
          .i_0_11    (i_11     ),
          .i_0_12    (i_12     ),
          .i_0_13    (i_13     ),
          .i_0_14    (i_14     ),
          .i_0_15    (i_15     ),
          .i_0_16    (i_16     ),
          .i_0_17    (i_17     ),
          .i_0_18    (i_18     ),
          .i_0_19    (i_19     ),
          .i_0_20    (i_20     ),
          .i_0_21    (i_21     ),
          .i_0_22    (i_22     ),
          .i_0_23    (i_23     ),
          .i_0_24    (i_24     ),
          .i_0_25    (i_25     ),
          .i_0_26    (i_26     ),
          .i_0_27    (i_27     ),
          .i_0_28    (i_28     ),
          .i_0_29    (i_29     ),
          .i_0_30    (i_30     ),
          .i_0_31    (i_31     ),
         
          .i_valid1  (valid_ctl1_mux0),//ctl1 in
          .i_1_0     (re_0      ),
          .i_1_1     (re_1      ),
          .i_1_2     (re_2      ),
          .i_1_3     (re_3      ),
          .i_1_4     (re_4      ),
          .i_1_5     (re_5      ),
          .i_1_6     (re_6      ),
          .i_1_7     (re_7      ),
          .i_1_8     (re_8      ),
          .i_1_9     (re_9      ),
          .i_1_10    (re_10     ),
          .i_1_11    (re_11     ),
          .i_1_12    (re_12     ),
          .i_1_13    (re_13     ),
          .i_1_14    (re_14     ),
          .i_1_15    (re_15     ),
          .i_1_16    (re_16     ),
          .i_1_17    (re_17     ),
          .i_1_18    (re_18     ),
          .i_1_19    (re_19     ),
          .i_1_20    (re_20     ),
          .i_1_21    (re_21     ),
          .i_1_22    (re_22     ),
          .i_1_23    (re_23     ),
          .i_1_24    (re_24     ),
          .i_1_25    (re_25     ),
          .i_1_26    (re_26     ),
          .i_1_27    (re_27     ),
          .i_1_28    (re_28     ),
          .i_1_29    (re_29     ),
          .i_1_30    (re_30     ),
          .i_1_31    (re_31     ),
           
          .i_valid2  (valid_ctl2_mux0),//transform in
          .i_2_0     (tr_0      ),
          .i_2_1     (tr_1      ),
          .i_2_2     (tr_2      ),
          .i_2_3     (tr_3      ),
          .i_2_4     (tr_4      ),
          .i_2_5     (tr_5      ),
          .i_2_6     (tr_6      ),
          .i_2_7     (tr_7      ),
          .i_2_8     (tr_8      ),
          .i_2_9     (tr_9      ),
          .i_2_10    (tr_10     ),
          .i_2_11    (tr_11     ),
          .i_2_12    (tr_12     ),
          .i_2_13    (tr_13     ),
          .i_2_14    (tr_14     ),
          .i_2_15    (tr_15     ),
          .i_2_16    (tr_16     ),
          .i_2_17    (tr_17     ),
          .i_2_18    (tr_18     ),
          .i_2_19    (tr_19     ),
          .i_2_20    (tr_20     ),
          .i_2_21    (tr_21     ),
          .i_2_22    (tr_22     ),
          .i_2_23    (tr_23     ),
          .i_2_24    (tr_24     ),
          .i_2_25    (tr_25     ),
          .i_2_26    (tr_26     ),
          .i_2_27    (tr_27     ),
          .i_2_28    (tr_28     ),
          .i_2_29    (tr_29     ),
          .i_2_30    (tr_30     ),
          .i_2_31    (tr_31     ),
//--------.--------------------------//
          .o_valid   (valid_mux0     ),
          .o_0       (dt_mux0_0      ),
          .o_1       (dt_mux0_1      ),
          .o_2       (dt_mux0_2      ),
          .o_3       (dt_mux0_3      ),
          .o_4       (dt_mux0_4      ),
          .o_5       (dt_mux0_5      ),
          .o_6       (dt_mux0_6      ),
          .o_7       (dt_mux0_7      ),
          .o_8       (dt_mux0_8      ),
          .o_9       (dt_mux0_9      ),
          .o_10      (dt_mux0_10     ),
          .o_11      (dt_mux0_11     ),
          .o_12      (dt_mux0_12     ),
          .o_13      (dt_mux0_13     ),
          .o_14      (dt_mux0_14     ),
          .o_15      (dt_mux0_15     ),
          .o_16      (dt_mux0_16     ),
          .o_17      (dt_mux0_17     ),
          .o_18      (dt_mux0_18     ),
          .o_19      (dt_mux0_19     ),
          .o_20      (dt_mux0_20     ),
          .o_21      (dt_mux0_21     ),
          .o_22      (dt_mux0_22     ),
          .o_23      (dt_mux0_23     ),
          .o_24      (dt_mux0_24     ),
          .o_25      (dt_mux0_25     ),
          .o_26      (dt_mux0_26     ),
          .o_27      (dt_mux0_27     ),
          .o_28      (dt_mux0_28     ),
          .o_29      (dt_mux0_29     ),
          .o_30      (dt_mux0_30     ),
          .o_31      (dt_mux0_31     )
);

//-----------------------------be------------------------//
//dct8x8 dct16x16 dct32x32 : 2clk  ;  other : 1clk 
be    u_be(
	.clk         (clk          ),
	.rst_n       (rst_n        ),
	.i_dt_vld    (valid_mux0   ),
	.i_inverse   (i_inverse    ),
	.i_transize  (i_transize   ),
	.i_0         (dt_mux0_0    ),	
	.i_1         (dt_mux0_1    ),	
	.i_2         (dt_mux0_2    ),	
	.i_3         (dt_mux0_3    ),	
	.i_4         (dt_mux0_4    ),	
	.i_5         (dt_mux0_5    ),	
	.i_6         (dt_mux0_6    ),	
	.i_7         (dt_mux0_7    ),	
	.i_8         (dt_mux0_8    ),	
	.i_9         (dt_mux0_9    ),	
	.i_10        (dt_mux0_10   ),	
	.i_11        (dt_mux0_11   ),	
	.i_12        (dt_mux0_12   ),	
	.i_13        (dt_mux0_13   ),	
	.i_14        (dt_mux0_14   ),	
	.i_15        (dt_mux0_15   ),	
	.i_16        (dt_mux0_16   ),	
	.i_17        (dt_mux0_17   ),	
	.i_18        (dt_mux0_18   ),	
	.i_19        (dt_mux0_19   ),	
	.i_20        (dt_mux0_20   ),	
	.i_21        (dt_mux0_21   ),	
	.i_22        (dt_mux0_22   ),	
	.i_23        (dt_mux0_23   ),	
	.i_24        (dt_mux0_24   ),	
	.i_25        (dt_mux0_25   ),	
	.i_26        (dt_mux0_26   ),	
	.i_27        (dt_mux0_27   ),	
	.i_28        (dt_mux0_28   ),	
	.i_29        (dt_mux0_29   ),	
	.i_30        (dt_mux0_30   ),
	.i_31        (dt_mux0_31   ),
//------------------------
	.o_dt_vld    (be_dt_vld    ),
	.o_0         (be_0         ),	
	.o_1         (be_1         ),	
	.o_2         (be_2         ),	
	.o_3         (be_3         ),	
	.o_4         (be_4         ),	
	.o_5         (be_5         ),	
	.o_6         (be_6         ),	
	.o_7         (be_7         ),	
	.o_8         (be_8         ),	
	.o_9         (be_9         ),	
	.o_10        (be_10        ),	
	.o_11        (be_11        ),	
	.o_12        (be_12        ),	
	.o_13        (be_13        ),	
	.o_14        (be_14        ),	
	.o_15        (be_15        ),	
	.o_16        (be_16        ),	
	.o_17        (be_17        ),	
	.o_18        (be_18        ),	
	.o_19        (be_19        ),	
	.o_20        (be_20        ),	
	.o_21        (be_21        ),	
	.o_22        (be_22        ),	
	.o_23        (be_23        ),	
	.o_24        (be_24        ),	
	.o_25        (be_25        ),	
	.o_26        (be_26        ),	
	.o_27        (be_27        ),
	.o_28        (be_28        ),	
	.o_29        (be_29        ),	
	.o_30        (be_30        ),	
	.o_31        (be_31        )	
);

//---------------------------ctl3--------------------//
ctl3 	u_ctl3(
          .i_valid  (be_dt_vld    ),
	  .i_inverse(i_inverse    ),
//----------------------------------//
          .o_valid0 (vld_ctl3_mux1),//to mux1
          .o_valid1 (vld_ctl3_mux3)//to mux3
);

//---------------------------mux1-----------------------------// 
mux_1  u_mux_1(
          .i_valid0  (vld_ctl3_mux1    ),//ctl3 in
          .i_0_0     (be_0[18:0]  ),
          .i_0_1     (be_1[18:0]  ),
          .i_0_2     (be_2[18:0]  ),
          .i_0_3     (be_3[18:0]  ),
          .i_0_4     (be_4[18:0]  ),
          .i_0_5     (be_5[18:0]  ),
          .i_0_6     (be_6[18:0]  ),
          .i_0_7     (be_7[18:0]  ),
          .i_0_8     (be_8[18:0]  ),
          .i_0_9     (be_9[18:0]  ),
          .i_0_10    (be_10[18:0] ),
          .i_0_11    (be_11[18:0] ),
          .i_0_12    (be_12[18:0] ),
          .i_0_13    (be_13[18:0] ),
          .i_0_14    (be_14[18:0] ),
          .i_0_15    (be_15[18:0] ),
          .i_0_16    (be_16[18:0] ),
          .i_0_17    (be_17[18:0] ),
          .i_0_18    (be_18[18:0] ),
          .i_0_19    (be_19[18:0] ),
          .i_0_20    (be_20[18:0] ),
          .i_0_21    (be_21[18:0] ),
          .i_0_22    (be_22[18:0] ),
          .i_0_23    (be_23[18:0] ),
          .i_0_24    (be_24[18:0] ),
          .i_0_25    (be_25[18:0] ),
          .i_0_26    (be_26[18:0] ),
          .i_0_27    (be_27[18:0] ),
          .i_0_28    (be_28[18:0] ),
          .i_0_29    (be_29[18:0] ),
          .i_0_30    (be_30[18:0] ),
          .i_0_31    (be_31[18:0] ),
          
          .i_valid1  (valid_pe_i     ),//pe' in
          .i_1_0     (dt_petr_0      ),
          .i_1_1     (dt_petr_1      ),
          .i_1_2     (dt_petr_2      ),
          .i_1_3     (dt_petr_3      ),
          .i_1_4     (dt_petr_4      ),
          .i_1_5     (dt_petr_5      ),
          .i_1_6     (dt_petr_6      ),
          .i_1_7     (dt_petr_7      ),
          .i_1_8     (dt_petr_8      ),
          .i_1_9     (dt_petr_9      ),
          .i_1_10    (dt_petr_10     ),
          .i_1_11    (dt_petr_11     ),
          .i_1_12    (dt_petr_12     ),
          .i_1_13    (dt_petr_13     ),
          .i_1_14    (dt_petr_14     ),
          .i_1_15    (dt_petr_15     ),
          .i_1_16    (dt_petr_16     ),
          .i_1_17    (dt_petr_17     ),
          .i_1_18    (dt_petr_18     ),
          .i_1_19    (dt_petr_19     ),
          .i_1_20    (dt_petr_20     ),
          .i_1_21    (dt_petr_21     ),
          .i_1_22    (dt_petr_22     ),
          .i_1_23    (dt_petr_23     ),
          .i_1_24    (dt_petr_24     ),
          .i_1_25    (dt_petr_25     ),
          .i_1_26    (dt_petr_26     ),
          .i_1_27    (dt_petr_27     ),
          .i_1_28    (dt_petr_28     ),
          .i_1_29    (dt_petr_29     ),
          .i_1_30    (dt_petr_30     ),
          .i_1_31    (dt_petr_31     ),
           
//----------------------------------//
          .o_valid   (valid_mux1     ),
          .o_0       (dt_mux1_0      ),
          .o_1       (dt_mux1_1      ),
          .o_2       (dt_mux1_2      ),
          .o_3       (dt_mux1_3      ),
          .o_4       (dt_mux1_4      ),
          .o_5       (dt_mux1_5      ),
          .o_6       (dt_mux1_6      ),
          .o_7       (dt_mux1_7      ),
          .o_8       (dt_mux1_8      ),
          .o_9       (dt_mux1_9      ),
          .o_10      (dt_mux1_10     ),
          .o_11      (dt_mux1_11     ),
          .o_12      (dt_mux1_12     ),
          .o_13      (dt_mux1_13     ),
          .o_14      (dt_mux1_14     ),
          .o_15      (dt_mux1_15     ),
          .o_16      (dt_mux1_16     ),
          .o_17      (dt_mux1_17     ),
          .o_18      (dt_mux1_18     ),
          .o_19      (dt_mux1_19     ),
          .o_20      (dt_mux1_20     ),
          .o_21      (dt_mux1_21     ),
          .o_22      (dt_mux1_22     ),
          .o_23      (dt_mux1_23     ),
          .o_24      (dt_mux1_24     ),
          .o_25      (dt_mux1_25     ),
          .o_26      (dt_mux1_26     ),
          .o_27      (dt_mux1_27     ),
          .o_28      (dt_mux1_28     ),
          .o_29      (dt_mux1_29     ),
          .o_30      (dt_mux1_30     ),
          .o_31      (dt_mux1_31     )
);

//----------------------------re logic---------------------------// 

re u_re(
	.clk            (clk         ),
	.rst_n          (rst_n       ),
	.i_inverse      (i_inverse   ),//0:dct 1:idct
	.i_tq_sel       (i_tq_sel    ),//00 01 :LUMA ; 10 :cb 11:cr
	.i_transize     (i_transize  ),//00:4x4 01:8x8 10:16x16 11:32x32
	.i_dt_vld       (valid_mux1  ),//data valid
	.i_data0	(dt_mux1_0   ),
	.i_data1	(dt_mux1_1   ),
	.i_data2	(dt_mux1_2   ),
	.i_data3	(dt_mux1_3   ),
	.i_data4	(dt_mux1_4   ),
	.i_data5	(dt_mux1_5   ),
	.i_data6	(dt_mux1_6   ),
	.i_data7	(dt_mux1_7   ),
	.i_data8	(dt_mux1_8   ),
	.i_data9	(dt_mux1_9   ),
	.i_data10       (dt_mux1_10  ),
	.i_data11       (dt_mux1_11  ),
	.i_data12       (dt_mux1_12  ),
	.i_data13       (dt_mux1_13  ),
	.i_data14       (dt_mux1_14  ),
	.i_data15       (dt_mux1_15  ),
	.i_data16       (dt_mux1_16  ),
	.i_data17       (dt_mux1_17  ),
	.i_data18       (dt_mux1_18  ),
	.i_data19       (dt_mux1_19  ),
	.i_data20       (dt_mux1_20  ),
	.i_data21       (dt_mux1_21  ),
	.i_data22       (dt_mux1_22  ),
	.i_data23       (dt_mux1_23  ),
	.i_data24       (dt_mux1_24  ),
	.i_data25       (dt_mux1_25  ),
	.i_data26       (dt_mux1_26  ),
	.i_data27       (dt_mux1_27  ),
	.i_data28       (dt_mux1_28  ),
	.i_data29       (dt_mux1_29  ),
	.i_data30       (dt_mux1_30  ),
	.i_data31       (dt_mux1_31  ),

	.o_dt_vld       (re_dt_vld   ),
	.o_data0	(re_0        ),
	.o_data1	(re_1        ),
	.o_data2	(re_2        ),
	.o_data3	(re_3        ),
	.o_data4	(re_4        ),
	.o_data5	(re_5        ),
	.o_data6	(re_6        ),
	.o_data7	(re_7        ),
	.o_data8	(re_8        ),
	.o_data9	(re_9        ),
	.o_data10       (re_10       ),
	.o_data11       (re_11       ),
	.o_data12       (re_12       ),
	.o_data13       (re_13       ),
	.o_data14       (re_14       ),
	.o_data15       (re_15       ),
	.o_data16       (re_16       ),
	.o_data17       (re_17       ),
	.o_data18       (re_18       ),
	.o_data19       (re_19       ),
	.o_data20       (re_20       ),
	.o_data21       (re_21       ),
	.o_data22       (re_22       ),
	.o_data23       (re_23       ),
	.o_data24       (re_24       ),
	.o_data25       (re_25       ),
	.o_data26       (re_26       ),
	.o_data27       (re_27       ),
	.o_data28       (re_28       ),
	.o_data29       (re_29       ),
	.o_data30       (re_30       ),
	.o_data31       (re_31       )
);
//------------------------ctl1----------------------//
ctl1  u_ctl1(
          .i_inverse   (i_inverse    ),
	  .i_valid     (re_dt_vld    ),
         
	  .o_valid0    (valid_ctl1_mux0),//mux0
	  .o_valid1    (valid_ctl1_pe  )//pe 
);
//--------------------------pe logic------------------------------//
pe  u_pe(
	.i_dt_vld    (valid_ctl1_pe    ),
	.i_transize  (i_transize       ),
	.i_0         (re_0        ),	
	.i_1         (re_1        ),	
	.i_2         (re_2        ),	
	.i_3         (re_3        ),	
	.i_4         (re_4        ),	
	.i_5         (re_5        ),	
	.i_6         (re_6        ),	
	.i_7         (re_7        ),	
	.i_8         (re_8        ),	
	.i_9         (re_9        ),	
	.i_10        (re_10       ),	
	.i_11        (re_11       ),	
	.i_12        (re_12       ),	
	.i_13        (re_13       ),	
	.i_14        (re_14       ),	
	.i_15        (re_15       ),	
	.i_16        (re_16       ),	
	.i_17        (re_17       ),	
	.i_18        (re_18       ),	
	.i_19        (re_19       ),	
	.i_20        (re_20       ),	
	.i_21        (re_21       ),	
	.i_22        (re_22       ),	
	.i_23        (re_23       ),	
	.i_24        (re_24       ),	
	.i_25        (re_25       ),	
	.i_26        (re_26       ),	
	.i_27        (re_27       ),
	.i_28        (re_28       ),
	.i_29        (re_29       ),	
	.i_30        (re_30       ),	
	.i_31        (re_31       ),
//------------------------
	.o_dt_vld    (pe_dt_vld        ),
	.o_0         (pe_0             ),	
	.o_1         (pe_1             ),	
	.o_2         (pe_2             ),	
	.o_3         (pe_3             ),	
	.o_4         (pe_4             ),	
	.o_5         (pe_5             ),	
	.o_6         (pe_6             ),	
	.o_7         (pe_7             ),	
	.o_8         (pe_8             ),	
	.o_9         (pe_9             ),	
	.o_10        (pe_10            ),	
	.o_11        (pe_11            ),	
	.o_12        (pe_12            ),	
	.o_13        (pe_13            ),	
	.o_14        (pe_14            ),	
	.o_15        (pe_15            ),	
	.o_16        (pe_16            ),	
	.o_17        (pe_17            ),	
	.o_18        (pe_18            ),	
	.o_19        (pe_19            ),	
	.o_20        (pe_20            ),	
	.o_21        (pe_21            ),	
	.o_22        (pe_22            ),	
	.o_23        (pe_23            ),	
	.o_24        (pe_24            ),	
	.o_25        (pe_25            ),	
	.o_26        (pe_26            ),	
	.o_27        (pe_27            ),
	.o_28        (pe_28            ),	
	.o_29        (pe_29            ),	
	.o_30        (pe_30            ),	
	.o_31        (pe_31            )	
);

mux_3 u_mux3(
          .i_0_valid (vld_ctl3_mux3),
          .i_0_0     (be_0    ),
          .i_0_1     (be_1    ),
          .i_0_2     (be_2    ),
          .i_0_3     (be_3    ),
          .i_0_4     (be_4    ),
          .i_0_5     (be_5    ),
          .i_0_6     (be_6    ),
          .i_0_7     (be_7    ),
          .i_0_8     (be_8    ),
          .i_0_9     (be_9    ),
          .i_0_10    (be_10   ),
          .i_0_11    (be_11   ),
          .i_0_12    (be_12   ),
          .i_0_13    (be_13   ),
          .i_0_14    (be_14   ),
          .i_0_15    (be_15   ),
          .i_0_16    (be_16   ),
          .i_0_17    (be_17   ),
          .i_0_18    (be_18   ),
          .i_0_19    (be_19   ),
          .i_0_20    (be_20   ),
          .i_0_21    (be_21   ),
          .i_0_22    (be_22   ),
          .i_0_23    (be_23   ),
          .i_0_24    (be_24   ),
          .i_0_25    (be_25   ),
          .i_0_26    (be_26   ),
          .i_0_27    (be_27   ),
          .i_0_28    (be_28   ),
          .i_0_29    (be_29   ),
          .i_0_30    (be_30   ),
          .i_0_31    (be_31   ),
          
          .i_1_valid (pe_dt_vld ),
          .i_1_0     (pe_0      ),
          .i_1_1     (pe_1      ),
          .i_1_2     (pe_2      ),
          .i_1_3     (pe_3      ),
          .i_1_4     (pe_4      ),
          .i_1_5     (pe_5      ),
          .i_1_6     (pe_6      ),
          .i_1_7     (pe_7      ),
          .i_1_8     (pe_8      ),
          .i_1_9     (pe_9      ),
          .i_1_10    (pe_10     ),
          .i_1_11    (pe_11     ),
          .i_1_12    (pe_12     ),
          .i_1_13    (pe_13     ),
          .i_1_14    (pe_14     ),
          .i_1_15    (pe_15     ),
          .i_1_16    (pe_16     ),
          .i_1_17    (pe_17     ),
          .i_1_18    (pe_18     ),
          .i_1_19    (pe_19     ),
          .i_1_20    (pe_20     ),
          .i_1_21    (pe_21     ),
          .i_1_22    (pe_22     ),
          .i_1_23    (pe_23     ),
          .i_1_24    (pe_24     ),
          .i_1_25    (pe_25     ),
          .i_1_26    (pe_26     ),
          .i_1_27    (pe_27     ),
          .i_1_28    (pe_28     ),
          .i_1_29    (pe_29     ),
          .i_1_30    (pe_30     ),
          .i_1_31    (pe_31     ),
           
//----------------------------------//
          .o_valid   (valid_mux3 ),
          .o_0       (dt_mux3_0  ),
          .o_1       (dt_mux3_1  ),
          .o_2       (dt_mux3_2  ),
          .o_3       (dt_mux3_3  ),
          .o_4       (dt_mux3_4  ),
          .o_5       (dt_mux3_5  ),
          .o_6       (dt_mux3_6  ),
          .o_7       (dt_mux3_7  ),
          .o_8       (dt_mux3_8  ),
          .o_9       (dt_mux3_9  ),
          .o_10      (dt_mux3_10 ),
          .o_11      (dt_mux3_11 ),
          .o_12      (dt_mux3_12 ),
          .o_13      (dt_mux3_13 ),
          .o_14      (dt_mux3_14 ),
          .o_15      (dt_mux3_15 ),
          .o_16      (dt_mux3_16 ),
          .o_17      (dt_mux3_17 ),
          .o_18      (dt_mux3_18 ),
          .o_19      (dt_mux3_19 ),
          .o_20      (dt_mux3_20 ),
          .o_21      (dt_mux3_21 ),
          .o_22      (dt_mux3_22 ),
          .o_23      (dt_mux3_23 ),
          .o_24      (dt_mux3_24 ),
          .o_25      (dt_mux3_25 ),
          .o_26      (dt_mux3_26 ),
          .o_27      (dt_mux3_27 ),
          .o_28      (dt_mux3_28 ),
          .o_29      (dt_mux3_29 ),
          .o_30      (dt_mux3_30 ),
          .o_31      (dt_mux3_31 )
);

//-------------------os logic---------------------//
offset_shift u_offset_shift(
                .clk            (clk        ),
                .rst_n          (rst_n      ), 
                .i_row          (row        ),
                .i_dt_vld       (valid_mux3 ),
	        .i_inverse      (i_inverse  ),
                .i_transize     (i_transize ),
                .i_0            (dt_mux3_0  ),
                .i_1            (dt_mux3_1  ),
                .i_2            (dt_mux3_2  ),
                .i_3            (dt_mux3_3  ),
                .i_4            (dt_mux3_4  ),
                .i_5            (dt_mux3_5  ),
                .i_6            (dt_mux3_6  ),
                .i_7            (dt_mux3_7  ),
                .i_8            (dt_mux3_8  ),
                .i_9            (dt_mux3_9  ),
                .i_10           (dt_mux3_10 ),
                .i_11           (dt_mux3_11 ),
                .i_12           (dt_mux3_12 ),
                .i_13           (dt_mux3_13 ),
                .i_14           (dt_mux3_14 ),
                .i_15           (dt_mux3_15 ),
                .i_16           (dt_mux3_16 ),
                .i_17           (dt_mux3_17 ),
                .i_18           (dt_mux3_18 ),
                .i_19           (dt_mux3_19 ),
                .i_20           (dt_mux3_20 ),
                .i_21           (dt_mux3_21 ),
                .i_22           (dt_mux3_22 ),
                .i_23           (dt_mux3_23 ),
                .i_24           (dt_mux3_24 ),
                .i_25           (dt_mux3_25 ),
                .i_26           (dt_mux3_26 ),
                .i_27           (dt_mux3_27 ),
                .i_28           (dt_mux3_28 ),
                .i_29           (dt_mux3_29 ),
                .i_30           (dt_mux3_30 ),
                .i_31           (dt_mux3_31 ),
               
                .o_2d_dt_vld    (dt_2d_vld  ),
		.o_t_dt_vld     (tr_dt_vld  ),
                .o_0            (os_0       ),
                .o_1            (os_1       ),
                .o_2            (os_2       ),
                .o_3            (os_3       ),
                .o_4            (os_4       ),
                .o_5            (os_5       ),
                .o_6            (os_6       ),
                .o_7            (os_7       ),
                .o_8            (os_8       ),
                .o_9            (os_9       ),
                .o_10           (os_10      ),
                .o_11           (os_11      ),
                .o_12           (os_12      ),
                .o_13           (os_13      ),
                .o_14           (os_14      ),
                .o_15           (os_15      ),
                .o_16           (os_16      ),
                .o_17           (os_17      ),
                .o_18           (os_18      ),
                .o_19           (os_19      ),
                .o_20           (os_20      ),
                .o_21           (os_21      ),
                .o_22           (os_22      ),
                .o_23           (os_23      ),
                .o_24           (os_24      ),
                .o_25           (os_25      ),
                .o_26           (os_26      ),
                .o_27           (os_27      ),
                .o_28           (os_28      ),
                .o_29           (os_29      ),
                .o_30           (os_30      ),
                .o_31           (os_31      )
);
//------------------transform_mtr----------------------//
transform_mtr u_transform_mtr(
                     .clk        (clk        ),
                     .rst_n      (rst_n      ),
                     .i_valid    (tr_dt_vld  ),
                     .i_transize (i_transize ),//00:4x4 01:8x8 10:16x16 11:32x32
                     .i_0        (os_0       ),
                     .i_1        (os_1       ),
                     .i_2        (os_2       ),
                     .i_3        (os_3       ),
                     .i_4        (os_4       ),
                     .i_5        (os_5       ),
                     .i_6        (os_6       ),
                     .i_7        (os_7       ),
                     .i_8        (os_8       ),
                     .i_9        (os_9       ),
                     .i_10       (os_10      ),
                     .i_11       (os_11      ),
                     .i_12       (os_12      ),
                     .i_13       (os_13      ),
                     .i_14       (os_14      ),
                     .i_15       (os_15      ),
                     .i_16       (os_16      ),
                     .i_17       (os_17      ),
                     .i_18       (os_18      ),
                     .i_19       (os_19      ),
                     .i_20       (os_20      ),
                     .i_21       (os_21      ),
                     .i_22       (os_22      ),
                     .i_23       (os_23      ),
                     .i_24       (os_24      ),
                     .i_25       (os_25      ),
                     .i_26       (os_26      ),
                     .i_27       (os_27      ),
                     .i_28       (os_28      ),
                     .i_29       (os_29      ),
                     .i_30       (os_30      ),
                     .i_31       (os_31      ),
                     
                     .o_valid    (tr_valid   ),
                     .o_0        (tr_0       ), 
                     .o_1        (tr_1       ),
                     .o_2        (tr_2       ),
                     .o_3        (tr_3       ),
		     .o_4        (tr_4       ), 
		     .o_5        (tr_5       ),
		     .o_6        (tr_6       ),
		     .o_7        (tr_7       ),
		     .o_8        (tr_8       ), 
		     .o_9        (tr_9       ),
		     .o_10       (tr_10      ),
		     .o_11       (tr_11      ),
		     .o_12       (tr_12      ),
		     .o_13       (tr_13      ),
		     .o_14       (tr_14      ),
		     .o_15       (tr_15      ),
		     .o_16       (tr_16      ),
		     .o_17       (tr_17      ),
		     .o_18       (tr_18      ),
		     .o_19       (tr_19      ),
		     .o_20       (tr_20      ),
		     .o_21       (tr_21      ),
		     .o_22       (tr_22      ),
		     .o_23       (tr_23      ),
		     .o_24       (tr_24      ),
		     .o_25       (tr_25      ),
		     .o_26       (tr_26      ),
		     .o_27       (tr_27      ),
		     .o_28       (tr_28      ),
		     .o_29       (tr_29      ),
		     .o_30       (tr_30      ),
		     .o_31       (tr_31      )
);
//-------------------------------------------------------------------//

ctl2  u_ctl2(
          .i_valid     (tr_valid       ),
	  .i_inverse   (i_inverse      ),
//----------------------------------//
          .o_valid0    (valid_ctl2_mux0),//to dct 
          .o_valid1    (valid_ctl2_mux2)//to i_dct
);

//-------------------------------------------------------// 
mux_2    u_mux_2(
          .i_0_valid (valid_ctl0_mux2),// org in
          .i_0_0     (i_0      ),
          .i_0_1     (i_1      ),
          .i_0_2     (i_2      ),
          .i_0_3     (i_3      ),
          .i_0_4     (i_4      ),
          .i_0_5     (i_5      ),
          .i_0_6     (i_6      ),
          .i_0_7     (i_7      ),
          .i_0_8     (i_8      ),
          .i_0_9     (i_9      ),
          .i_0_10    (i_10     ),
          .i_0_11    (i_11     ),
          .i_0_12    (i_12     ),
          .i_0_13    (i_13     ),
          .i_0_14    (i_14     ),
          .i_0_15    (i_15     ),
          .i_0_16    (i_16     ),
          .i_0_17    (i_17     ),
          .i_0_18    (i_18     ),
          .i_0_19    (i_19     ),
          .i_0_20    (i_20     ),
          .i_0_21    (i_21     ),
          .i_0_22    (i_22     ),
          .i_0_23    (i_23     ),
          .i_0_24    (i_24     ),
          .i_0_25    (i_25     ),
          .i_0_26    (i_26     ),
          .i_0_27    (i_27     ),
          .i_0_28    (i_28     ),
          .i_0_29    (i_29     ),
          .i_0_30    (i_30     ),
          .i_0_31    (i_31     ),
          
          .i_1_valid (valid_ctl2_mux2),//tr in
          .i_1_0     (tr_0      ),
          .i_1_1     (tr_1      ),
          .i_1_2     (tr_2      ),
          .i_1_3     (tr_3      ),
          .i_1_4     (tr_4      ),
          .i_1_5     (tr_5      ),
          .i_1_6     (tr_6      ),
          .i_1_7     (tr_7      ),
          .i_1_8     (tr_8      ),
          .i_1_9     (tr_9      ),
          .i_1_10    (tr_10     ),
          .i_1_11    (tr_11     ),
          .i_1_12    (tr_12     ),
          .i_1_13    (tr_13     ),
          .i_1_14    (tr_14     ),
          .i_1_15    (tr_15     ),
          .i_1_16    (tr_16     ),
          .i_1_17    (tr_17     ),
          .i_1_18    (tr_18     ),
          .i_1_19    (tr_19     ),
          .i_1_20    (tr_20     ),
          .i_1_21    (tr_21     ),
          .i_1_22    (tr_22     ),
          .i_1_23    (tr_23     ),
          .i_1_24    (tr_24     ),
          .i_1_25    (tr_25     ),
          .i_1_26    (tr_26     ),
          .i_1_27    (tr_27     ),
          .i_1_28    (tr_28     ),
          .i_1_29    (tr_29     ),
          .i_1_30    (tr_30     ),
          .i_1_31    (tr_31     ),
           
//----------------------------------//
          .o_valid   (valid_mux2   ),
          .o_0       (dt_mux2_0    ),
          .o_1       (dt_mux2_1    ),
          .o_2       (dt_mux2_2    ),
          .o_3       (dt_mux2_3    ),
          .o_4       (dt_mux2_4    ),
          .o_5       (dt_mux2_5    ),
          .o_6       (dt_mux2_6    ),
          .o_7       (dt_mux2_7    ),
          .o_8       (dt_mux2_8    ),
          .o_9       (dt_mux2_9    ),
          .o_10      (dt_mux2_10   ),
          .o_11      (dt_mux2_11   ),
          .o_12      (dt_mux2_12   ),
          .o_13      (dt_mux2_13   ),
          .o_14      (dt_mux2_14   ),
          .o_15      (dt_mux2_15   ),
          .o_16      (dt_mux2_16   ),
          .o_17      (dt_mux2_17   ),
          .o_18      (dt_mux2_18   ),
          .o_19      (dt_mux2_19   ),
          .o_20      (dt_mux2_20   ),
          .o_21      (dt_mux2_21   ),
          .o_22      (dt_mux2_22   ),
          .o_23      (dt_mux2_23   ),
          .o_24      (dt_mux2_24   ),
          .o_25      (dt_mux2_25   ),
          .o_26      (dt_mux2_26   ),
          .o_27      (dt_mux2_27   ),
          .o_28      (dt_mux2_28   ),
          .o_29      (dt_mux2_29   ),
          .o_30      (dt_mux2_30   ),
          .o_31      (dt_mux2_31   )
);  
  
//--------------------pe_i------------------------//  
pe_i  u_pe_i(
	.i_transize  (i_transize   ),
	.i_valid     (valid_mux2   ),
	.i_0         (dt_mux2_0    ),	
	.i_1         (dt_mux2_1    ),	
	.i_2         (dt_mux2_2    ),	
	.i_3         (dt_mux2_3    ),	
	.i_4         (dt_mux2_4    ),	
	.i_5         (dt_mux2_5    ),	
	.i_6         (dt_mux2_6    ),	
	.i_7         (dt_mux2_7    ),	
	.i_8         (dt_mux2_8    ),	
	.i_9         (dt_mux2_9    ),	
	.i_10        (dt_mux2_10   ),	
	.i_11        (dt_mux2_11   ),	
	.i_12        (dt_mux2_12   ),	
	.i_13        (dt_mux2_13   ),	
	.i_14        (dt_mux2_14   ),	
	.i_15        (dt_mux2_15   ),	
	.i_16        (dt_mux2_16   ),	
	.i_17        (dt_mux2_17   ),	
	.i_18        (dt_mux2_18   ),	
	.i_19        (dt_mux2_19   ),	
	.i_20        (dt_mux2_20   ),	
	.i_21        (dt_mux2_21   ),	
	.i_22        (dt_mux2_22   ),	
	.i_23        (dt_mux2_23   ),	
	.i_24        (dt_mux2_24   ),	
	.i_25        (dt_mux2_25   ),	
	.i_26        (dt_mux2_26   ),	
	.i_27        (dt_mux2_27   ),
	.i_28        (dt_mux2_28   ),	
	.i_29        (dt_mux2_29   ),	
	.i_30        (dt_mux2_30   ),	
	.i_31        (dt_mux2_31   ),
//------------------------
	.o_valid     (valid_pe_i   ),
	.o_0         (dt_petr_0    ),	
	.o_1         (dt_petr_1    ),	
	.o_2         (dt_petr_2    ),	
	.o_3         (dt_petr_3    ),	
	.o_4         (dt_petr_4    ),	
	.o_5         (dt_petr_5    ),	
	.o_6         (dt_petr_6    ),	
	.o_7         (dt_petr_7    ),	
	.o_8         (dt_petr_8    ),	
	.o_9         (dt_petr_9    ),	
	.o_10        (dt_petr_10   ),	
	.o_11        (dt_petr_11   ),	
	.o_12        (dt_petr_12   ),	
	.o_13        (dt_petr_13   ),	
	.o_14        (dt_petr_14   ),	
	.o_15        (dt_petr_15   ),	
	.o_16        (dt_petr_16   ),	
	.o_17        (dt_petr_17   ),	
	.o_18        (dt_petr_18   ),	
	.o_19        (dt_petr_19   ),	
	.o_20        (dt_petr_20   ),	
	.o_21        (dt_petr_21   ),	
	.o_22        (dt_petr_22   ),	
	.o_23        (dt_petr_23   ),	
	.o_24        (dt_petr_24   ),	
	.o_25        (dt_petr_25   ),	
	.o_26        (dt_petr_26   ),	
	.o_27        (dt_petr_27   ),
	.o_28        (dt_petr_28   ),	
	.o_29        (dt_petr_29   ),	
	.o_30        (dt_petr_30   ),	
	.o_31        (dt_petr_31   )	
); 

//----------------------row_ctl --------------// 
row_ctl  u_row_ctl(
	.clk	  (clk            ),
	.rst_n	  (rst_n          ),
	.i_valid0 (i_valid        ),//org valid
	.i_valid1 (tr_valid       ),//transform out valid 
	.o_row	  (row            ) //1:2d_dct ; 0 : 1d_dct
);  
                         
assign	o_valid  = dt_2d_vld   ;	
assign	o_0      = os_0        ;	
assign	o_1      = os_1        ;	
assign	o_2      = os_2        ;	
assign	o_3      = os_3        ;	
assign	o_4      = os_4        ;	
assign	o_5      = os_5        ;	
assign	o_6      = os_6        ;	
assign	o_7      = os_7        ;	
assign	o_8      = os_8        ;	
assign	o_9      = os_9        ;	
assign	o_10     = os_10       ;	
assign	o_11     = os_11       ;	
assign	o_12     = os_12       ;	
assign	o_13     = os_13       ;	
assign	o_14     = os_14       ;	
assign	o_15     = os_15       ;	
assign	o_16     = os_16       ;	
assign	o_17     = os_17       ;	
assign	o_18     = os_18       ;	
assign	o_19     = os_19       ;	
assign	o_20     = os_20       ;	
assign	o_21     = os_21       ;	
assign	o_22     = os_22       ;	
assign	o_23     = os_23       ;	
assign	o_24     = os_24       ;	
assign	o_25     = os_25       ;	
assign	o_26     = os_26       ;	
assign	o_27     = os_27       ;
assign	o_28     = os_28       ;	
assign	o_29     = os_29       ;	
assign	o_30     = os_30       ;	
assign	o_31     = os_31       ;	



endmodule
