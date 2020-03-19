//----------------------------------------------------------------------------
//                                                                 
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//                                                                  
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUTED WITHOUT THE      
//  EXPRESSED WRITTEN CONSENT OF VIPcore Group
//                                                                  
//  VIPcore       : http://soc.fudan.edu.cn/vip    
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn             
//----------------------------------------------------------------------------
// Filename       : db_tu_edge.v
// Author         : chewein
// Created        : 2014-04-18
// Description    : cacl the tu edge of the luma lcu,because tu is sqare 
//----------------------------------------------------------------------------
module db_tu_edge(
                mb_partition_i,
                v0,v1,v2 ,v3 ,v4 ,v5 ,v6 ,v7 ,
                v8,v9,v10,v11,v12,v13,v14,v15,
                
                h1,h2,h3,h4,h5,h6,h7
);
// ********************************************
//                                             
//    INPUT / OUTPUT DECLARATION               
//                                             
// ********************************************
input   [20:0]      mb_partition_i               ;// CU partition mode,0:not split , 1:split

output  [6:0]       v0,v1,v2 ,v3 ,v4 ,v5 ,v6 ,v7 ;
output  [6:0]       v8,v9,v10,v11,v12,v13,v14,v15;

output  [15:0]      h1,h2,h3,h4,h5,h6,h7         ;
                   
reg     [6:0]       v0,v1,v2 ,v3 ,v4 ,v5 ,v6 ,v7 ;
reg     [6:0]       v8,v9,v10,v11,v12,v13,v14,v15;

reg     [15:0]      h1,h2,h3,h4,h5,h6,h7         ;

//8x8 tu edge :v1 v3 v5 v7 h1 h3 h5 h7
//[3:0]
always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v0[0]       =   1'b0    ;
        v1[0]       =   1'b0    ;
        v2[0]       =   1'b0    ;
        v3[0]       =   1'b0    ;
    end
    else if(!mb_partition_i[1]) begin   //32x32     
        v0[0]       =   1'b0    ;
        v1[0]       =   1'b0    ;
        v2[0]       =   1'b0    ;
        v3[0]       =   1'b0    ;
    end
    else if(!mb_partition_i[5]) begin   //16x16
        v0[0]       =   1'b0    ;
        v1[0]       =   1'b0    ;
        v2[0]       =   1'b0    ;
        v3[0]       =   1'b0    ;
    end
    else                        begin    //8x8  
        v0[0]       =   1'b1    ;
        v1[0]       =   1'b1    ;
        v2[0]       =   1'b1    ;
        v3[0]       =   1'b1    ;
    end     
end                                 

always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v0[2]       =   1'b0    ;
        v1[2]       =   1'b0    ;
        v2[2]       =   1'b0    ;
        v3[2]       =   1'b0    ;
    end
    else if(!mb_partition_i[1]) begin   //32x32     
        v0[2]       =   1'b0    ;
        v1[2]       =   1'b0    ;
        v2[2]       =   1'b0    ;
        v3[2]       =   1'b0    ;
    end
    else if(!mb_partition_i[6]) begin   //16x16
        v0[2]       =   1'b0    ;
        v1[2]       =   1'b0    ;
        v2[2]       =   1'b0    ;
        v3[2]       =   1'b0    ;
    end
    else                        begin    //8x8  
        v0[2]       =   1'b1    ;
        v1[2]       =   1'b1    ;
        v2[2]       =   1'b1    ;
        v3[2]       =   1'b1    ;
    end     
end         
            
always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v0[4]       =   1'b0    ;
        v1[4]       =   1'b0    ;
        v2[4]       =   1'b0    ;
        v3[4]       =   1'b0    ;
    end
    else if(!mb_partition_i[2]) begin   //32x32     
        v0[4]       =   1'b0    ;
        v1[4]       =   1'b0    ;
        v2[4]       =   1'b0    ;
        v3[4]       =   1'b0    ;
    end
    else if(!mb_partition_i[9]) begin   //16x16
        v0[4]       =   1'b0    ;
        v1[4]       =   1'b0    ;
        v2[4]       =   1'b0    ;
        v3[4]       =   1'b0    ;
    end
    else                        begin    //8x8  
        v0[4]       =   1'b1    ;
        v1[4]       =   1'b1    ;
        v2[4]       =   1'b1    ;
        v3[4]       =   1'b1    ;
    end     
end             
        
always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v0[6]       =   1'b0    ;
        v1[6]       =   1'b0    ;
        v2[6]       =   1'b0    ;
        v3[6]       =   1'b0    ;
    end
    else if(!mb_partition_i[2]) begin   //32x32     
        v0[6]       =   1'b0    ;
        v1[6]       =   1'b0    ;
        v2[6]       =   1'b0    ;
        v3[6]       =   1'b0    ;
    end
    else if(!mb_partition_i[10]) begin  //16x16
        v0[6]       =   1'b0    ;
        v1[6]       =   1'b0    ;
        v2[6]       =   1'b0    ;
        v3[6]       =   1'b0    ;
    end
    else                        begin    //8x8  
        v0[6]       =   1'b1    ;
        v1[6]       =   1'b1    ;
        v2[6]       =   1'b1    ;
        v3[6]       =   1'b1    ;
    end     
end             
//[7:4]
always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v4[0]       =   1'b0    ;
        v5[0]       =   1'b0    ;
        v6[0]       =   1'b0    ;
        v7[0]       =   1'b0    ;
    end
    else if(!mb_partition_i[1]) begin   //32x32     
        v4[0]       =   1'b0    ;
        v5[0]       =   1'b0    ;
        v6[0]       =   1'b0    ;
        v7[0]       =   1'b0    ;
    end
    else if(!mb_partition_i[7]) begin   //16x16
        v4[0]       =   1'b0    ;
        v5[0]       =   1'b0    ;
        v6[0]       =   1'b0    ;
        v7[0]       =   1'b0    ;
    end
    else                        begin    //8x8  
        v4[0]       =   1'b1    ;
        v5[0]       =   1'b1    ;
        v6[0]       =   1'b1    ;
        v7[0]       =   1'b1    ;
    end     
end                                 

always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v4[2]       =   1'b0    ;
        v5[2]       =   1'b0    ;
        v6[2]       =   1'b0    ;
        v7[2]       =   1'b0    ;
    end
    else if(!mb_partition_i[1]) begin   //32x32     
        v4[2]       =   1'b0    ;
        v5[2]       =   1'b0    ;
        v6[2]       =   1'b0    ;
        v7[2]       =   1'b0    ;
    end
    else if(!mb_partition_i[8]) begin   //16x16
        v4[2]       =   1'b0    ;
        v5[2]       =   1'b0    ;
        v6[2]       =   1'b0    ;
        v7[2]       =   1'b0    ;
    end
    else                        begin    //8x8  
        v4[2]       =   1'b1    ;
        v5[2]       =   1'b1    ;
        v6[2]       =   1'b1    ;
        v7[2]       =   1'b1    ;
    end     
end         
            
always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v4[4]       =   1'b0    ;
        v5[4]       =   1'b0    ;
        v6[4]       =   1'b0    ;
        v7[4]       =   1'b0    ;
    end
    else if(!mb_partition_i[2]) begin   //32x32     
        v4[4]       =   1'b0    ;
        v5[4]       =   1'b0    ;
        v6[4]       =   1'b0    ;
        v7[4]       =   1'b0    ;
    end
    else if(!mb_partition_i[11]) begin  //16x16
        v4[4]       =   1'b0    ;
        v5[4]       =   1'b0    ;
        v6[4]       =   1'b0    ;
        v7[4]       =   1'b0    ;
    end
    else                        begin    //8x8  
        v4[4]       =   1'b1    ;
        v5[4]       =   1'b1    ;
        v6[4]       =   1'b1    ;
        v7[4]       =   1'b1    ;
    end     
end             
        
always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v4[6]       =   1'b0    ;
        v5[6]       =   1'b0    ;
        v6[6]       =   1'b0    ;
        v7[6]       =   1'b0    ;
    end
    else if(!mb_partition_i[2]) begin   //32x32     
        v4[6]       =   1'b0    ;
        v5[6]       =   1'b0    ;
        v6[6]       =   1'b0    ;
        v7[6]       =   1'b0    ;
    end
    else if(!mb_partition_i[12]) begin  //16x16
        v4[6]       =   1'b0    ;
        v5[6]       =   1'b0    ;
        v6[6]       =   1'b0    ;
        v7[6]       =   1'b0    ;
    end
    else                        begin    //8x8  
        v4[6]       =   1'b1    ;
        v5[6]       =   1'b1    ;
        v6[6]       =   1'b1    ;
        v7[6]       =   1'b1    ;
    end     
end                     
//[11:8]            
always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v8[0]       =   1'b0    ;
        v9[0]       =   1'b0    ;
        v10[0]      =   1'b0    ;
        v11[0]      =   1'b0    ;
    end
    else if(!mb_partition_i[3]) begin   //32x32     
        v8[0]       =   1'b0    ;
        v9[0]       =   1'b0    ;
        v10[0]      =   1'b0    ;
        v11[0]      =   1'b0    ;
    end
    else if(!mb_partition_i[13]) begin  //16x16
        v8[0]       =   1'b0    ;
        v9[0]       =   1'b0    ;
        v10[0]      =   1'b0    ;
        v11[0]      =   1'b0    ;
    end
    else                        begin    //8x8  
        v8[0]       =   1'b1    ;
        v9[0]       =   1'b1    ;
        v10[0]      =   1'b1    ;
        v11[0]      =   1'b1    ;
    end     
end                                 

always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v8[2]       =   1'b0    ;
        v9[2]       =   1'b0    ;
        v10[2]      =   1'b0    ;
        v11[2]      =   1'b0    ;
    end
    else if(!mb_partition_i[3]) begin   //32x32     
        v8[2]       =   1'b0    ;
        v9[2]       =   1'b0    ;
        v10[2]      =   1'b0    ;
        v11[2]      =   1'b0    ;
    end
    else if(!mb_partition_i[14]) begin  //16x16
        v8[2]       =   1'b0    ;
        v9[2]       =   1'b0    ;
        v10[2]      =   1'b0    ;
        v11[2]      =   1'b0    ;
    end
    else                        begin    //8x8  
        v8[2]       =   1'b1    ;
        v9[2]       =   1'b1    ;
        v10[2]      =   1'b1    ;
        v11[2]      =   1'b1    ;
    end     
end         
            
always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v8[4]       =   1'b0    ;
        v9[4]       =   1'b0    ;
        v10[4]      =   1'b0    ;
        v11[4]      =   1'b0    ;
    end
    else if(!mb_partition_i[4]) begin   //32x32     
        v8[4]       =   1'b0    ;
        v9[4]       =   1'b0    ;
        v10[4]      =   1'b0    ;
        v11[4]      =   1'b0    ;
    end
    else if(!mb_partition_i[17]) begin  //16x16
        v8[4]       =   1'b0    ;
        v9[4]       =   1'b0    ;
        v10[4]      =   1'b0    ;
        v11[4]      =   1'b0    ;
    end
    else                        begin    //8x8  
        v8[4]       =   1'b1    ;
        v9[4]       =   1'b1    ;
        v10[4]      =   1'b1    ;
        v11[4]      =   1'b1    ;
    end     
end             
        
always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v8[6]       =   1'b0    ;
        v9[6]       =   1'b0    ;
        v10[6]      =   1'b0    ;
        v11[6]      =   1'b0    ;
    end
    else if(!mb_partition_i[4]) begin   //32x32     
        v8[6]       =   1'b0    ;
        v9[6]       =   1'b0    ;
        v10[6]      =   1'b0    ;
        v11[6]      =   1'b0    ;
    end
    else if(!mb_partition_i[18]) begin  //16x16
        v8[6]       =   1'b0    ;
        v9[6]       =   1'b0    ;
        v10[6]      =   1'b0    ;
        v11[6]      =   1'b0    ;
    end
    else                        begin    //8x8  
        v8[6]       =   1'b1    ;
        v9[6]       =   1'b1    ;
        v10[6]      =   1'b1    ;
        v11[6]      =   1'b1    ;
    end     
end     
//[15:12]           
always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v12[0]      =   1'b0    ;
        v13[0]      =   1'b0    ;
        v14[0]      =   1'b0    ;
        v15[0]      =   1'b0    ;
    end
    else if(!mb_partition_i[3]) begin   //32x32     
        v12[0]      =   1'b0    ;
        v13[0]      =   1'b0    ;
        v14[0]      =   1'b0    ;
        v15[0]      =   1'b0    ;
    end
    else if(!mb_partition_i[15]) begin  //16x16
        v12[0]      =   1'b0    ;
        v13[0]      =   1'b0    ;
        v14[0]      =   1'b0    ;
        v15[0]      =   1'b0    ;
    end
    else                        begin    //8x8  
        v12[0]      =   1'b1    ;
        v13[0]      =   1'b1    ;
        v14[0]      =   1'b1    ;
        v15[0]      =   1'b1    ;
    end     
end                                 

always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v12[2]      =   1'b0    ;
        v13[2]      =   1'b0    ;
        v14[2]      =   1'b0    ;
        v15[2]      =   1'b0    ;
    end
    else if(!mb_partition_i[3]) begin   //32x32     
        v12[2]      =   1'b0    ;
        v13[2]      =   1'b0    ;
        v14[2]      =   1'b0    ;
        v15[2]      =   1'b0    ;
    end
    else if(!mb_partition_i[16]) begin  //16x16
        v12[2]      =   1'b0    ;
        v13[2]      =   1'b0    ;
        v14[2]      =   1'b0    ;
        v15[2]      =   1'b0    ;
    end
    else                        begin    //8x8  
        v12[2]      =   1'b1    ;
        v13[2]      =   1'b1    ;
        v14[2]      =   1'b1    ;
        v15[2]      =   1'b1    ;
    end     
end         
            
always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v12[4]      =   1'b0    ;
        v13[4]      =   1'b0    ;
        v14[4]      =   1'b0    ;
        v15[4]      =   1'b0    ;
    end
    else if(!mb_partition_i[4]) begin   //32x32     
        v12[4]      =   1'b0    ;
        v13[4]      =   1'b0    ;
        v14[4]      =   1'b0    ;
        v15[4]      =   1'b0    ;
    end
    else if(!mb_partition_i[19]) begin  //16x16
        v12[4]      =   1'b0    ;
        v13[4]      =   1'b0    ;
        v14[4]      =   1'b0    ;
        v15[4]      =   1'b0    ;
    end
    else                        begin    //8x8  
        v12[4]      =   1'b1    ;
        v13[4]      =   1'b1    ;
        v14[4]      =   1'b1    ;
        v15[4]      =   1'b1    ;
    end     
end             
        
always @* begin     
    if(!mb_partition_i[0])  begin       //64x64     
        v12[6]      =   1'b0    ;
        v13[6]      =   1'b0    ;
        v14[6]      =   1'b0    ;
        v15[6]      =   1'b0    ;
    end
    else if(!mb_partition_i[4]) begin   //32x32     
        v12[6]      =   1'b0    ;
        v13[6]      =   1'b0    ;
        v14[6]      =   1'b0    ;
        v15[6]      =   1'b0    ;
    end
    else if(!mb_partition_i[20]) begin  //16x16
        v12[6]      =   1'b0    ;
        v13[6]      =   1'b0    ;
        v14[6]      =   1'b0    ;
        v15[6]      =   1'b0    ;
    end
    else                        begin    //8x8  
        v12[6]      =   1'b1    ;
        v13[6]      =   1'b1    ;
        v14[6]      =   1'b1    ;
        v15[6]      =   1'b1    ;
    end     
end             
//16x16 tu edge:v2 v6 h2 h6
//[7:0]
always @* begin
    if(!mb_partition_i[0])    begin     //64x64
        v0[1]       =   1'b0    ;
        v1[1]       =   1'b0    ;
        v2[1]       =   1'b0    ;
        v3[1]       =   1'b0    ;
        v4[1]       =   1'b0    ;
        v5[1]       =   1'b0    ;
        v6[1]       =   1'b0    ;
        v7[1]       =   1'b0    ;
    end
    else if(!mb_partition_i[1]) begin   //32x32
        v0[1]       =   1'b0    ;
        v1[1]       =   1'b0    ;
        v2[1]       =   1'b0    ;
        v3[1]       =   1'b0    ;
        v4[1]       =   1'b0    ;
        v5[1]       =   1'b0    ;
        v6[1]       =   1'b0    ;
        v7[1]       =   1'b0    ;
    end     
    else                        begin   //16x16
        v0[1]       =   1'b1    ;
        v1[1]       =   1'b1    ;
        v2[1]       =   1'b1    ;
        v3[1]       =   1'b1    ;
        v4[1]       =   1'b1    ;
        v5[1]       =   1'b1    ;
        v6[1]       =   1'b1    ;
        v7[1]       =   1'b1    ;   
    end
end

always @* begin
    if(!mb_partition_i[0])    begin     //64x64
        v0[5]       =   1'b0    ;
        v1[5]       =   1'b0    ;
        v2[5]       =   1'b0    ;
        v3[5]       =   1'b0    ;
        v4[5]       =   1'b0    ;
        v5[5]       =   1'b0    ;
        v6[5]       =   1'b0    ;
        v7[5]       =   1'b0    ;
    end
    else if(!mb_partition_i[2]) begin   //32x32
        v0[5]       =   1'b0    ;
        v1[5]       =   1'b0    ;
        v2[5]       =   1'b0    ;
        v3[5]       =   1'b0    ;
        v4[5]       =   1'b0    ;
        v5[5]       =   1'b0    ;
        v6[5]       =   1'b0    ;
        v7[5]       =   1'b0    ;
    end     
    else                        begin   //16x16
        v0[5]       =   1'b1    ;
        v1[5]       =   1'b1    ;
        v2[5]       =   1'b1    ;
        v3[5]       =   1'b1    ;
        v4[5]       =   1'b1    ;
        v5[5]       =   1'b1    ;
        v6[5]       =   1'b1    ;
        v7[5]       =   1'b1    ;   
    end
end
//[15:8]
always @* begin
    if(!mb_partition_i[0])    begin     //64x64
        v8 [1]      =   1'b0    ;
        v9 [1]      =   1'b0    ;
        v10[1]      =   1'b0    ;
        v11[1]      =   1'b0    ;
        v12[1]      =   1'b0    ;
        v13[1]      =   1'b0    ;
        v14[1]      =   1'b0    ;
        v15[1]      =   1'b0    ;
    end
    else if(!mb_partition_i[3]) begin   //32x32
        v8 [1]      =   1'b0    ;
        v9 [1]      =   1'b0    ;
        v10[1]      =   1'b0    ;
        v11[1]      =   1'b0    ;
        v12[1]      =   1'b0    ;
        v13[1]      =   1'b0    ;
        v14[1]      =   1'b0    ;
        v15[1]      =   1'b0    ;
    end     
    else                        begin   //16x16
        v8 [1]      =   1'b1    ;
        v9 [1]      =   1'b1    ;
        v10[1]      =   1'b1    ;
        v11[1]      =   1'b1    ;
        v12[1]      =   1'b1    ;
        v13[1]      =   1'b1    ;
        v14[1]      =   1'b1    ;
        v15[1]      =   1'b1    ;   
    end
end

always @* begin
    if(!mb_partition_i[0])    begin     //64x64
        v8 [5]      =   1'b0    ;
        v9 [5]      =   1'b0    ;
        v10[5]      =   1'b0    ;
        v11[5]      =   1'b0    ;
        v12[5]      =   1'b0    ;
        v13[5]      =   1'b0    ;
        v14[5]      =   1'b0    ;
        v15[5]      =   1'b0    ;
    end
    else if(!mb_partition_i[4]) begin   //32x32
        v8 [5]      =   1'b0    ;
        v9 [5]      =   1'b0    ;
        v10[5]      =   1'b0    ;
        v11[5]      =   1'b0    ;
        v12[5]      =   1'b0    ;
        v13[5]      =   1'b0    ;
        v14[5]      =   1'b0    ;
        v15[5]      =   1'b0    ;
    end     
    else                        begin   //16x16
        v8 [5]      =   1'b1    ;
        v9 [5]      =   1'b1    ;
        v10[5]      =   1'b1    ;
        v11[5]      =   1'b1    ;
        v12[5]      =   1'b1    ;
        v13[5]      =   1'b1    ;
        v14[5]      =   1'b1    ;
        v15[5]      =   1'b1    ;   
    end
end
//32x32 tu edge v4 h4
always @* begin
    if(!mb_partition_i[0])      begin   //64x64
        v0 [3]      =   1'b1    ;
        v1 [3]      =   1'b1    ;
        v2 [3]      =   1'b1    ;
        v3 [3]      =   1'b1    ;
        v4 [3]      =   1'b1    ;
        v5 [3]      =   1'b1    ;
        v6 [3]      =   1'b1    ;
        v7 [3]      =   1'b1    ;   
        v8 [3]      =   1'b1    ;
        v9 [3]      =   1'b1    ;
        v10[3]      =   1'b1    ;
        v11[3]      =   1'b1    ;
        v12[3]      =   1'b1    ;
        v13[3]      =   1'b1    ;
        v14[3]      =   1'b1    ;
        v15[3]      =   1'b1    ;   
    end     
    else                        begin   //32x32
        v0 [3]      =   1'b1    ;
        v1 [3]      =   1'b1    ;
        v2 [3]      =   1'b1    ;
        v3 [3]      =   1'b1    ;
        v4 [3]      =   1'b1    ;
        v5 [3]      =   1'b1    ;
        v6 [3]      =   1'b1    ;
        v7 [3]      =   1'b1    ;   
        v8 [3]      =   1'b1    ;
        v9 [3]      =   1'b1    ;
        v10[3]      =   1'b1    ;
        v11[3]      =   1'b1    ;
        v12[3]      =   1'b1    ;
        v13[3]      =   1'b1    ;
        v14[3]      =   1'b1    ;
        v15[3]      =   1'b1    ;
    end
end

//8x8   tu edge h1 h3 h5 h7
//h1
always @* begin
    if(!mb_partition_i[0])          //64x64
        h1[3:0]     =   4'h0    ;
    else if(!mb_partition_i[1])     //32x32
        h1[3:0]     =   4'h0    ;
    else if(!mb_partition_i[5])     //16x16
        h1[3:0]     =   4'h0    ;
    else 
        h1[3:0]     =   4'hf    ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h1[7:4]     =   4'h0    ;
    else if(!mb_partition_i[1])     //32x32
        h1[7:4]     =   4'h0    ;
    else if(!mb_partition_i[6])     //16x16
        h1[7:4]     =   4'h0    ;
    else 
        h1[7:4]     =   4'hf    ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h1[11:8]        =   4'h0    ;
    else if(!mb_partition_i[2])     //32x32
        h1[11:8]        =   4'h0    ;
    else if(!mb_partition_i[9])     //16x16
        h1[11:8]        =   4'h0    ;
    else 
        h1[11:8]        =   4'hf    ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h1[15:12]       =   4'h0    ;
    else if(!mb_partition_i[2])     //32x32
        h1[15:12]       =   4'h0    ;
    else if(!mb_partition_i[10])    //16x16
        h1[15:12]       =   4'h0    ;
    else 
        h1[15:12]       =   4'hf    ;
end

//h3
always @* begin
    if(!mb_partition_i[0])          //64x64
        h3[3:0]     =   4'h0    ;
    else if(!mb_partition_i[1])     //32x32
        h3[3:0]     =   4'h0    ;
    else if(!mb_partition_i[7])     //16x16
        h3[3:0]     =   4'h0    ;
    else 
        h3[3:0]     =   4'hf    ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h3[7:4]     =   4'h0    ;
    else if(!mb_partition_i[1])     //32x32
        h3[7:4]     =   4'h0    ;
    else if(!mb_partition_i[8])     //16x16
        h3[7:4]     =   4'h0    ;
    else 
        h3[7:4]     =   4'hf    ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h3[11:8]        =   4'h0    ;
    else if(!mb_partition_i[2])     //32x32
        h3[11:8]        =   4'h0    ;
    else if(!mb_partition_i[11])    //16x16
        h3[11:8]        =   4'h0    ;
    else 
        h3[11:8]        =   4'hf    ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h3[15:12]       =   4'h0    ;
    else if(!mb_partition_i[2])     //32x32
        h3[15:12]       =   4'h0    ;
    else if(!mb_partition_i[12])    //16x16
        h3[15:12]       =   4'h0    ;
    else 
        h3[15:12]       =   4'hf    ;
end

//h5
always @* begin
    if(!mb_partition_i[0])          //64x64
        h5[3:0]     =   4'h0    ;
    else if(!mb_partition_i[3])     //32x32
        h5[3:0]     =   4'h0    ;
    else if(!mb_partition_i[13])    //16x16
        h5[3:0]     =   4'h0    ;
    else 
        h5[3:0]     =   4'hf    ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h5[7:4]     =   4'h0    ;
    else if(!mb_partition_i[3])     //32x32
        h5[7:4]     =   4'h0    ;
    else if(!mb_partition_i[14])    //16x16
        h5[7:4]     =   4'h0    ;
    else 
        h5[7:4]     =   4'hf    ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h5[11:8]        =   4'h0    ;
    else if(!mb_partition_i[4])     //32x32
        h5[11:8]        =   4'h0    ;
    else if(!mb_partition_i[17])    //16x16
        h5[11:8]        =   4'h0    ;
    else 
        h5[11:8]        =   4'hf    ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h5[15:12]       =   4'h0    ;
    else if(!mb_partition_i[4])     //32x32
        h5[15:12]       =   4'h0    ;
    else if(!mb_partition_i[18])    //16x16
        h5[15:12]       =   4'h0    ;
    else 
        h5[15:12]       =   4'hf    ;
end

//h7
always @* begin
    if(!mb_partition_i[0])          //64x64
        h7[3:0]     =   4'h0    ;
    else if(!mb_partition_i[3])     //32x32
        h7[3:0]     =   4'h0    ;
    else if(!mb_partition_i[15])    //16x16
        h7[3:0]     =   4'h0    ;
    else 
        h7[3:0]     =   4'hf    ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h7[7:4]     =   4'h0    ;
    else if(!mb_partition_i[3])     //32x32
        h7[7:4]     =   4'h0    ;
    else if(!mb_partition_i[16])    //16x16
        h7[7:4]     =   4'h0    ;
    else 
        h7[7:4]     =   4'hf    ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h7[11:8]        =   4'h0    ;
    else if(!mb_partition_i[4])     //32x32
        h7[11:8]        =   4'h0    ;
    else if(!mb_partition_i[19])    //16x16
        h7[11:8]        =   4'h0    ;
    else 
        h7[11:8]        =   4'hf    ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h7[15:12]       =   4'h0    ;
    else if(!mb_partition_i[4])     //32x32
        h7[15:12]       =   4'h0    ;
    else if(!mb_partition_i[20])    //16x16
        h7[15:12]       =   4'h0    ;
    else 
        h7[15:12]       =   4'hf    ;
end
//16x16 tu edge h2 h6
//h2
always @* begin
    if(!mb_partition_i[0])          //64x64
        h2[7:0]         =   8'h0    ;
    else if(!mb_partition_i[1])     //32x32
        h2[7:0]         =   8'h0    ;
    else 
        h2[7:0]         =   8'hff   ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h2[15:8]        =   8'h0    ;
    else if(!mb_partition_i[2])     //32x32
        h2[15:8]        =   8'h0    ;
    else 
        h2[15:8]        =   8'hff   ;
end

//h6
always @* begin
    if(!mb_partition_i[0])          //64x64
        h6[7:0]         =   8'h0    ;
    else if(!mb_partition_i[3])     //32x32
        h6[7:0]         =   8'h0    ;
    else 
        h6[7:0]         =   8'hff   ;
end

always @* begin
    if(!mb_partition_i[0])          //64x64
        h6[15:8]        =   8'h0    ;
    else if(!mb_partition_i[4])     //32x32
        h6[15:8]        =   8'h0    ;
    else 
        h6[15:8]        =   8'hff   ;
end
//32x32 tu edge h4
//h4
always @* begin
    if(!mb_partition_i[0])          //64x64
        h4[15:0]        =   16'hffff;
    else 
        h4[15:0]        =   16'hffff;
    end

endmodule 