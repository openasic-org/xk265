//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.25
//file name     : addr_ctl.v
//delay         : 0 clk 
//describe      :
//modification  :
//v1.0          :
module   addr_ctl(
       clk         ,
       rst_n       ,
       i_valid     ,
       i_transize  ,
//----data rd wr sel addr----//
       o_rd_wr_ctl ,
       o_badd_0    ,
       o_badd_1    ,
       o_badd_2    ,
       o_badd_3    ,
       o_badd_4    ,
       o_badd_5    ,
       o_badd_6    ,
       o_badd_7    ,
       o_badd_8    ,
       o_badd_9    ,
       o_badd_10   ,
       o_badd_11   ,
       o_badd_12   ,
       o_badd_13   ,
       o_badd_14   ,
       o_badd_15   ,
       o_badd_16   ,
       o_badd_17   ,
       o_badd_18   ,
       o_badd_19   ,
       o_badd_20   ,
       o_badd_21   ,
       o_badd_22   ,
       o_badd_23   ,
       o_badd_24   ,
       o_badd_25   ,
       o_badd_26   ,
       o_badd_27   ,
       o_badd_28   ,
       o_badd_29   ,
       o_badd_30   ,
       o_badd_31   ,
//-----ram wr rd addr---//
       o_add_0     ,
       o_add_1     ,
       o_add_2     ,
       o_add_3     ,
       o_add_4     ,
       o_add_5     ,
       o_add_6     ,
       o_add_7     ,
       o_add_8     ,
       o_add_9     ,
       o_add_10    ,
       o_add_11    ,
       o_add_12    ,
       o_add_13    ,
       o_add_14    ,
       o_add_15    ,
       o_add_16    ,
       o_add_17    ,
       o_add_18    ,
       o_add_19    ,
       o_add_20    ,
       o_add_21    ,
       o_add_22    ,
       o_add_23    ,
       o_add_24    ,
       o_add_25    ,
       o_add_26    ,
       o_add_27    ,
       o_add_28    ,
       o_add_29    ,
       o_add_30    ,
       o_add_31    
);

// ********************************************
//                                             
//    INPUT / OUTPUT DECLARATION                                               
//                                                                             
// ********************************************       

input                           clk        ;         
input                           rst_n      ;
input                           i_valid    ;
input            [1:0]          i_transize ;   
output   wire                   o_rd_wr_ctl;
output   wire    [4:0]          o_badd_0   ;
output   wire    [4:0]          o_badd_1   ;
output   wire    [4:0]          o_badd_2   ;
output   wire    [4:0]          o_badd_3   ;
output   wire    [4:0]          o_badd_4   ;
output   wire    [4:0]          o_badd_5   ;
output   wire    [4:0]          o_badd_6   ;
output   wire    [4:0]          o_badd_7   ;
output   wire    [4:0]          o_badd_8   ;
output   wire    [4:0]          o_badd_9   ;
output   wire    [4:0]          o_badd_10  ;
output   wire    [4:0]          o_badd_11  ;
output   wire    [4:0]          o_badd_12  ;
output   wire    [4:0]          o_badd_13  ;
output   wire    [4:0]          o_badd_14  ;
output   wire    [4:0]          o_badd_15  ;
output   wire    [4:0]          o_badd_16  ;
output   wire    [4:0]          o_badd_17  ;
output   wire    [4:0]          o_badd_18  ;
output   wire    [4:0]          o_badd_19  ;
output   wire    [4:0]          o_badd_20  ;
output   wire    [4:0]          o_badd_21  ;
output   wire    [4:0]          o_badd_22  ;
output   wire    [4:0]          o_badd_23  ;
output   wire    [4:0]          o_badd_24  ;
output   wire    [4:0]          o_badd_25  ;
output   wire    [4:0]          o_badd_26  ;
output   wire    [4:0]          o_badd_27  ;
output   wire    [4:0]          o_badd_28  ;
output   wire    [4:0]          o_badd_29  ;
output   wire    [4:0]          o_badd_30  ;
output   wire    [4:0]          o_badd_31  ;

output   wire    [4:0]          o_add_0    ;
output   wire    [4:0]          o_add_1    ;
output   wire    [4:0]          o_add_2    ;
output   wire    [4:0]          o_add_3    ;
output   wire    [4:0]          o_add_4    ;
output   wire    [4:0]          o_add_5    ;
output   wire    [4:0]          o_add_6    ;
output   wire    [4:0]          o_add_7    ;
output   wire    [4:0]          o_add_8    ;
output   wire    [4:0]          o_add_9    ;
output   wire    [4:0]          o_add_10   ;
output   wire    [4:0]          o_add_11   ;
output   wire    [4:0]          o_add_12   ;
output   wire    [4:0]          o_add_13   ;
output   wire    [4:0]          o_add_14   ;
output   wire    [4:0]          o_add_15   ;
output   wire    [4:0]          o_add_16   ;
output   wire    [4:0]          o_add_17   ;
output   wire    [4:0]          o_add_18   ;
output   wire    [4:0]          o_add_19   ;
output   wire    [4:0]          o_add_20   ;
output   wire    [4:0]          o_add_21   ;
output   wire    [4:0]          o_add_22   ;
output   wire    [4:0]          o_add_23   ;
output   wire    [4:0]          o_add_24   ;
output   wire    [4:0]          o_add_25   ;
output   wire    [4:0]          o_add_26   ;
output   wire    [4:0]          o_add_27   ;
output   wire    [4:0]          o_add_28   ;
output   wire    [4:0]          o_add_29   ;
output   wire    [4:0]          o_add_30   ;
output   wire    [4:0]          o_add_31   ;

// ********************************************
//                                             
//    WIRE   DECLARATION                     
//                                             
// ********************************************
reg  [4  :0]     counter_size    ;
reg  [4  :0]     counter         ;
reg  [4  :0]     counter_d1      ;
reg              valid_d1        ;
reg              rd_wr_region    ;
reg              rd_wr_region_d1 ;
reg              rd_wr_region_d2 ;
reg  [4  :0]     addr_rd         ;   
reg  [159:0]     addr_int        ;
reg  [159:0]     baddr_int       ;
reg  [159:0]     addr_seq        ;//wr addr; rd addr
reg  [159:0]     data_seq        ;//wr data; rd data

//---ram addr wr & addr rd----//
//rd and wr region
always @(*)
begin
    case(i_transize)
    2'b01   :  counter_size = 5'd1   ;  
    2'b10   :  counter_size = 5'd7   ;
    2'b11   :  counter_size = 5'd31  ;
    default :  counter_size = 5'd0   ;
    endcase
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        counter <= 5'd0;
    else if(i_valid || rd_wr_region)
    begin
        if(counter == counter_size)
            counter <= 5'd0;
        else
            counter <= counter + 1'b1;  
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        valid_d1 <= 1'b0;
    else
        valid_d1 <= i_valid;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        counter_d1 <= 5'd0;
    else
        counter_d1 <= counter;
end 
 
//------------low : wr ;  high : rd
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rd_wr_region <= 1'b0;
    else if((i_valid || rd_wr_region) && (i_transize != 2'd0))
    begin
        if(counter == counter_size)
            rd_wr_region <= ~rd_wr_region;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rd_wr_region_d1 <= 1'b0;
    else
        rd_wr_region_d1 <= rd_wr_region;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rd_wr_region_d2 <= 1'b0;
    else
        rd_wr_region_d2 <= rd_wr_region_d1;
end

//-----------------------------------------------------------------------------// 
always @(*) //wr addr int: left shift 
begin
    case(i_transize)
    2'b11   :  addr_int = {5'd31,5'd30,5'd29,5'd28,5'd27,5'd26,5'd25,5'd24,5'd23,5'd22,5'd21,5'd20,5'd19,5'd18,5'd17,5'd16,5'd15,5'd14,5'd13,5'd12,5'd11,5'd10,5'd9,5'd8,5'd7,5'd6,5'd5,5'd4,5'd3,5'd2,5'd1,5'd0} ;   
    2'b10   :  addr_int = {5'd7,5'd7,5'd7,5'd7,5'd6,5'd6,5'd6,5'd6,5'd5,5'd5,5'd5,5'd5,5'd4,5'd4,5'd4,5'd4,5'd3,5'd3,5'd3,5'd3,5'd2,5'd2,5'd2,5'd2,5'd1,5'd1,5'd1,5'd1,5'd0,5'd0,5'd0,5'd0};
    2'b01   :  addr_int = {5'd1,5'd1,5'd1,5'd1,5'd1,5'd1,5'd1,5'd1,5'd1,5'd1,5'd1,5'd1,5'd1,5'd1,5'd1,5'd1,5'd0,5'd0,5'd0,5'd0,5'd0,5'd0,5'd0,5'd0,5'd0,5'd0,5'd0,5'd0,5'd0,5'd0,5'd0,5'd0};
    default :  addr_int = 160'd0 ;
    endcase
end

always @(*) 
begin
    if(~rd_wr_region)//wr dt seq : left shift
    begin
        case(i_transize)
        2'b11   :  baddr_int = {5'd31,5'd30,5'd29,5'd28,5'd27,5'd26,5'd25,5'd24,5'd23,5'd22,5'd21,5'd20,5'd19,5'd18,5'd17,5'd16,5'd15,5'd14,5'd13,5'd12,5'd11,5'd10,5'd9,5'd8,5'd7,5'd6,5'd5,5'd4,5'd3,5'd2,5'd1,5'd0} ;  
        2'b10   :  baddr_int = {5'd31,5'd30,5'd15,5'd14,5'd29,5'd28,5'd13,5'd12,5'd27,5'd26,5'd11,5'd10,5'd25,5'd24,5'd9,5'd8,5'd23,5'd22,5'd7,5'd6,5'd21,5'd20,5'd5,5'd4,5'd19,5'd18,5'd3,5'd2,5'd17,5'd16,5'd1,5'd0};
        2'b01   :  baddr_int = {5'd31,5'd30,5'd29,5'd28,5'd23,5'd22,5'd21,5'd20,5'd15,5'd14,5'd13,5'd12,5'd7,5'd6,5'd5,5'd4,5'd27,5'd26,5'd25,5'd24,5'd19,5'd18,5'd17,5'd16,5'd11,5'd10,5'd9,5'd8,5'd3,5'd2,5'd1,5'd0};
        default :  baddr_int = 160'd0 ;
        endcase
    end
    else
    begin
        case(i_transize)//rd dt seq:right shift
        2'b11   :  baddr_int = {5'd31,5'd30,5'd29,5'd28,5'd27,5'd26,5'd25,5'd24,5'd23,5'd22,5'd21,5'd20,5'd19,5'd18,5'd17,5'd16,5'd15,5'd14,5'd13,5'd12,5'd11,5'd10,5'd9,5'd8,5'd7,5'd6,5'd5,5'd4,5'd3,5'd2,5'd1,5'd0} ;//shift 1 bit 
        2'b10   :  baddr_int = {5'd31,5'd29,5'd27,5'd25,5'd23,5'd21,5'd19,5'd17,5'd15,5'd13,5'd11,5'd9,5'd7,5'd5,5'd3,5'd1,5'd30,5'd28,5'd26,5'd24,5'd22,5'd20,5'd18,5'd16,5'd14,5'd12,5'd10,5'd8,5'd6,5'd4,5'd2,5'd0};//shift 4 bit 
        2'b01   :  baddr_int ={5'd31,5'd27,5'd23,5'd19,5'd15,5'd11,5'd7,5'd3,5'd30,5'd26,5'd22,5'd18,5'd14,5'd10,5'd6,5'd2,5'd29,5'd25,5'd21,5'd17,5'd13,5'd9,5'd5,5'd1,5'd28,5'd24,5'd20,5'd16,5'd12,5'd8,5'd4,5'd0};//shift 16 bit
        default :  baddr_int = 160'd0 ;
        endcase
    end
end

//-------------ram  addr-------------------//
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        addr_rd <= 5'd0;
    else if(i_valid && (counter == counter_size))
        addr_rd <= 5'd0;
    else if(rd_wr_region)
    begin
        if(addr_rd == counter_size)
            addr_rd <= 5'd0;
        else
            addr_rd <= addr_rd + 1'b1;
    end
end 

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        addr_seq <= 160'd0;
    //-----------------rd addr---------------------//
    else  if(rd_wr_region)
        addr_seq <= {32{addr_rd}};
    //------------------wr addr--------------------//
    else if(counter == 5'd0)
        addr_seq <= addr_int;
    else if(valid_d1)
    begin
        if(i_transize == 2'd3)
            addr_seq <={addr_seq[154:0],addr_seq[159:155]};
        else if(i_transize == 2'd2)
            addr_seq <={addr_seq[139:0],addr_seq[159:140]};
        else if(i_transize == 2'd1)
            addr_seq <={addr_seq[79:0],addr_seq[159:80]};
    end
end 

//----------------data sel-------------------------//
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        data_seq <= 160'd0;
    else if(i_transize == 2'd0)
        data_seq <= {5'd0,5'd0,5'd0,5'd0,5'd27,5'd19,5'd11,5'd3,5'd0,5'd0,5'd0,5'd0,5'd26,5'd18,5'd10,5'd2,5'd0,5'd0,5'd0,5'd0,5'd25,5'd17,5'd9,5'd1,5'd0,5'd0,5'd0,5'd0,5'd24,5'd16,5'd8,5'd0};
    else if((counter == 5'd0) && (~rd_wr_region) &&(~rd_wr_region_d1) &&(~rd_wr_region_d2) &&(~i_valid))
        data_seq <= baddr_int;
    //--------------ram wr data sel-----------------//
    else if(i_valid)
    begin
        if (i_transize == 2'd3)
            data_seq <={data_seq[154:0],data_seq[159:155]};
        else if(i_transize == 2'd2)
            data_seq <={data_seq[139:0],data_seq[159:140]};
        else if(i_transize == 2'd1)
            data_seq <={data_seq[79:0],data_seq[159:80]};
    end 
    //--------------ram rd data sel: ram out delay 1 clk-----------------//
    else if(rd_wr_region_d1 && (counter_d1==5'd0))
        data_seq <= baddr_int;
    else if(rd_wr_region_d2)
    begin
        if(i_transize == 2'd3)
            data_seq <={data_seq[4:0],data_seq[159:5]};
        else if(i_transize == 2'd2)
            data_seq <={data_seq[89:80],data_seq[159:90],data_seq[9:0],data_seq[79:10]};
        else if(i_transize == 2'd1)
            data_seq <={data_seq[139:120],data_seq[159:140],data_seq[99:80],data_seq[119:100],data_seq[59:40],data_seq[79:60],data_seq[19:0],data_seq[39:20]};
    end
end 

//-------------output-------------//i
assign    o_rd_wr_ctl = rd_wr_region_d1;//low wr ram : high rd ram //high  rd region

assign    o_badd_0 =  data_seq[4 : 0]  ;    
assign    o_badd_1 =  data_seq[9 : 5]  ;    
assign    o_badd_2 =  data_seq[14:10]  ;    
assign    o_badd_3 =  data_seq[19:15]  ;    
assign    o_badd_4 =  data_seq[24:20]  ;    
assign    o_badd_5 =  data_seq[29:25]  ;    
assign    o_badd_6 =  data_seq[34:30]  ;    
assign    o_badd_7 =  data_seq[39:35]  ;    
assign    o_badd_8 =  data_seq[44:40]  ; 
assign    o_badd_9 =  data_seq[49:45]  ; 
assign    o_badd_10=  data_seq[54:50]  ; 
assign    o_badd_11=  data_seq[59:55]  ; 
assign    o_badd_12=  data_seq[64:60]  ; 
assign    o_badd_13=  data_seq[69:65]  ; 
assign    o_badd_14=  data_seq[74:70]  ; 
assign    o_badd_15=  data_seq[79:75]  ; 
assign    o_badd_16=  data_seq[84:80]  ; 
assign    o_badd_17=  data_seq[89:85]  ; 
assign    o_badd_18=  data_seq[94:90]  ; 
assign    o_badd_19=  data_seq[99:95]  ; 
assign    o_badd_20=  data_seq[104:100]; 
assign    o_badd_21=  data_seq[109:105]; 
assign    o_badd_22=  data_seq[114:110]; 
assign    o_badd_23=  data_seq[119:115]; 
assign    o_badd_24=  data_seq[124:120]; 
assign    o_badd_25=  data_seq[129:125]; 
assign    o_badd_26=  data_seq[134:130]; 
assign    o_badd_27=  data_seq[139:135]; 
assign    o_badd_28=  data_seq[144:140]; 
assign    o_badd_29=  data_seq[149:145]; 
assign    o_badd_30=  data_seq[154:150]; 
assign    o_badd_31=  data_seq[159:155]; 

assign    o_add_0  =  addr_seq[4 : 0]  ;   
assign    o_add_1  =  addr_seq[9 : 5]  ;  
assign    o_add_2  =  addr_seq[14:10]  ;  
assign    o_add_3  =  addr_seq[19:15]  ;  
assign    o_add_4  =  addr_seq[24:20]  ;  
assign    o_add_5  =  addr_seq[29:25]  ;  
assign    o_add_6  =  addr_seq[34:30]  ;  
assign    o_add_7  =  addr_seq[39:35]  ;  
assign    o_add_8  =  addr_seq[44:40]  ; 
assign    o_add_9  =  addr_seq[49:45]  ; 
assign    o_add_10 =  addr_seq[54:50]  ; 
assign    o_add_11 =  addr_seq[59:55]  ; 
assign    o_add_12 =  addr_seq[64:60]  ; 
assign    o_add_13 =  addr_seq[69:65]  ; 
assign    o_add_14 =  addr_seq[74:70]  ; 
assign    o_add_15 =  addr_seq[79:75]  ; 
assign    o_add_16 =  addr_seq[84:80]  ; 
assign    o_add_17 =  addr_seq[89:85]  ; 
assign    o_add_18 =  addr_seq[94:90]  ; 
assign    o_add_19 =  addr_seq[99:95]  ; 
assign    o_add_20 =  addr_seq[104:100]; 
assign    o_add_21 =  addr_seq[109:105]; 
assign    o_add_22 =  addr_seq[114:110]; 
assign    o_add_23 =  addr_seq[119:115]; 
assign    o_add_24 =  addr_seq[124:120]; 
assign    o_add_25 =  addr_seq[129:125]; 
assign    o_add_26 =  addr_seq[134:130]; 
assign    o_add_27 =  addr_seq[139:135]; 
assign    o_add_28 =  addr_seq[144:140]; 
assign    o_add_29 =  addr_seq[149:145]; 
assign    o_add_30 =  addr_seq[154:150]; 
assign    o_add_31 =  addr_seq[159:155]; 


endmodule

