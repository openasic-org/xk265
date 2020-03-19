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
// Filename       : db_pu_edge.v
// Author         : Chewein
// Created        : 2014-04-18
// Description    : cacl the tu edge of the luma lcu
//                  tu is square    so only cacl the ver edge,the hor edge = ver edge         
//----------------------------------------------------------------------------
module db_pu_edge(
                    mb_partition_i,
                    mb_p_pu_mode_i,
                    v0,v1,v2 ,v3 ,v4 ,v5 ,v6 ,v7 ,
                    v8,v9,v10,v11,v12,v13,v14,v15,
                    h1,h2,h3,h4,h5,h6,h7
                 );
// **************************************************************************************
//                                             
//    INPUT / OUTPUT DECLARATION               
//                                             
// **************************************************************************************
input   [20:0]      mb_partition_i               ;// CU partition mode,0:not split , 1:split
input   [41:0]      mb_p_pu_mode_i               ;
output  [6:0]       v0,v1,v2 ,v3 ,v4 ,v5 ,v6 ,v7 ;
output  [6:0]       v8,v9,v10,v11,v12,v13,v14,v15;
output  [15:0]      h1,h2,h3,h4,h5,h6,h7         ;
   
reg     [6:0]       v0,v1,v2,v3 ,v4 ,v5 ,v6 ,v7  ;
reg     [6:0]       v8,v9,v10,v11,v12,v13,v14,v15;               
reg     [15:0]      h1,h2,h3,h4,h5,h6,h7         ;

//8x8 pu edge : h1 h3 h5 h7  v[0 2 4 6]
//h1
always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v0[0]       =   1'b0    ;
        v1[0]       =   1'b0    ;
        v2[0]       =   1'b0    ;
        v3[0]       =   1'b0    ;
        h1[3:0]     =   4'h0    ;
    end
    else if(!mb_partition_i[1]) begin //32x32       
        v0[0]       =   1'b0    ;
        v1[0]       =   1'b0    ;
        v2[0]       =   1'b0    ;
        v3[0]       =   1'b0    ;
        h1[3:0]     =   4'h0    ;
    end
    else if(mb_partition_i[5])  begin //8x8 
        v0[0]       =   1'b1    ;
        v1[0]       =   1'b1    ;
        v2[0]       =   1'b1    ;
        v3[0]       =   1'b1    ;
        h1[3:0]     =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[11:10])
            2'b00:begin v0[0]= 1'b0;v1[0]= 1'b0;v2[0]= 1'b0;v3[0]= 1'b0;h1[3:0]=4'h0; end
            2'b01:begin v0[0]= 1'b0;v1[0]= 1'b0;v2[0]= 1'b0;v3[0]= 1'b0;h1[3:0]=4'hf; end
            2'b10:begin v0[0]= 1'b1;v1[0]= 1'b1;v2[0]= 1'b1;v3[0]= 1'b1;h1[3:0]=4'h0; end
          default:begin v0[0]= 1'b1;v1[0]= 1'b1;v2[0]= 1'b1;v3[0]= 1'b1;h1[3:0]=4'hf; end
        endcase     
    end     
end     

always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v0[2]       =   1'b0    ;
        v1[2]       =   1'b0    ;
        v2[2]       =   1'b0    ;
        v3[2]       =   1'b0    ;
        h1[7:4]     =   4'h0    ;
    end
    else if(!mb_partition_i[1]) begin //32x32       
        v0[2]       =   1'b0    ;
        v1[2]       =   1'b0    ;
        v2[2]       =   1'b0    ;
        v3[2]       =   1'b0    ;
        h1[7:4]     =   4'h0    ;
    end
    else if(mb_partition_i[6])  begin //8x8 
        v0[2]       =   1'b1    ;
        v1[2]       =   1'b1    ;
        v2[2]       =   1'b1    ;
        v3[2]       =   1'b1    ;
        h1[7:4]     =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[13:12])
            2'b00:begin v0[2]= 1'b0;v1[2]= 1'b0;v2[2]= 1'b0;v3[2]= 1'b0;h1[7:4]=4'h0; end
            2'b01:begin v0[2]= 1'b0;v1[2]= 1'b0;v2[2]= 1'b0;v3[2]= 1'b0;h1[7:4]=4'hf; end
            2'b10:begin v0[2]= 1'b1;v1[2]= 1'b1;v2[2]= 1'b1;v3[2]= 1'b1;h1[7:4]=4'h0; end
          default:begin v0[2]= 1'b1;v1[2]= 1'b1;v2[2]= 1'b1;v3[2]= 1'b1;h1[7:4]=4'hf; end
        endcase     
    end     
end 

always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v0[4]       =   1'b0    ;
        v1[4]       =   1'b0    ;
        v2[4]       =   1'b0    ;
        v3[4]       =   1'b0    ;
        h1[11:8]    =   4'h0    ;
    end
    else if(!mb_partition_i[2]) begin //32x32       
        v0[4]       =   1'b0    ;
        v1[4]       =   1'b0    ;
        v2[4]       =   1'b0    ;
        v3[4]       =   1'b0    ;
        h1[11:8]    =   4'h0    ;
    end
    else if(mb_partition_i[9])  begin //8x8 
        v0[4]       =   1'b1    ;
        v1[4]       =   1'b1    ;
        v2[4]       =   1'b1    ;
        v3[4]       =   1'b1    ;
        h1[11:8]    =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[19:18])
            2'b00:begin v0[4]= 1'b0;v1[4]= 1'b0;v2[4]= 1'b0;v3[4]= 1'b0;h1[11:8]=4'h0; end
            2'b01:begin v0[4]= 1'b0;v1[4]= 1'b0;v2[4]= 1'b0;v3[4]= 1'b0;h1[11:8]=4'hf; end
            2'b10:begin v0[4]= 1'b1;v1[4]= 1'b1;v2[4]= 1'b1;v3[4]= 1'b1;h1[11:8]=4'h0; end
          default:begin v0[4]= 1'b1;v1[4]= 1'b1;v2[4]= 1'b1;v3[4]= 1'b1;h1[11:8]=4'hf; end
        endcase     
    end     
end 

always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v0[6]       =   1'b0    ;
        v1[6]       =   1'b0    ;
        v2[6]       =   1'b0    ;
        v3[6]       =   1'b0    ;
        h1[15:12]   =   4'h0    ;
    end
    else if(!mb_partition_i[2]) begin //32x32       
        v0[6]       =   1'b0    ;
        v1[6]       =   1'b0    ;
        v2[6]       =   1'b0    ;
        v3[6]       =   1'b0    ;
        h1[15:12]   =   4'h0    ;
    end
    else if(mb_partition_i[10])  begin //8x8    
        v0[6]       =   1'b1    ;
        v1[6]       =   1'b1    ;
        v2[6]       =   1'b1    ;
        v3[6]       =   1'b1    ;
        h1[15:12]   =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[21:20])
            2'b00:begin v0[6]= 1'b0;v1[6]= 1'b0;v2[6]= 1'b0;v3[6]= 1'b0;h1[15:12]=4'h0; end
            2'b01:begin v0[6]= 1'b0;v1[6]= 1'b0;v2[6]= 1'b0;v3[6]= 1'b0;h1[15:12]=4'hf; end
            2'b10:begin v0[6]= 1'b1;v1[6]= 1'b1;v2[6]= 1'b1;v3[6]= 1'b1;h1[15:12]=4'h0; end
          default:begin v0[6]= 1'b1;v1[6]= 1'b1;v2[6]= 1'b1;v3[6]= 1'b1;h1[15:12]=4'hf; end
        endcase     
    end     
end 
//h3
always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v4[0]       =   1'b0    ;
        v5[0]       =   1'b0    ;
        v6[0]       =   1'b0    ;
        v7[0]       =   1'b0    ;
        h3[3:0]     =   4'h0    ;
    end
    else if(!mb_partition_i[1]) begin //32x32       
        v4[0]       =   1'b0    ;
        v5[0]       =   1'b0    ;
        v6[0]       =   1'b0    ;
        v7[0]       =   1'b0    ;
        h3[3:0]     =   4'h0    ;
    end
    else if(mb_partition_i[7])  begin //8x8 
        v4[0]       =   1'b1    ;
        v5[0]       =   1'b1    ;
        v6[0]       =   1'b1    ;
        v7[0]       =   1'b1    ;
        h3[3:0]     =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[15:14])
            2'b00:begin v4[0]= 1'b0;v5[0]= 1'b0;v6[0]= 1'b0;v7[0]= 1'b0;h3[3:0]=4'h0; end
            2'b01:begin v4[0]= 1'b0;v5[0]= 1'b0;v6[0]= 1'b0;v7[0]= 1'b0;h3[3:0]=4'hf; end
            2'b10:begin v4[0]= 1'b1;v5[0]= 1'b1;v6[0]= 1'b1;v7[0]= 1'b1;h3[3:0]=4'h0; end
          default:begin v4[0]= 1'b1;v5[0]= 1'b1;v6[0]= 1'b1;v7[0]= 1'b1;h3[3:0]=4'hf; end
        endcase     
    end     
end     

always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v4[2]       =   1'b0    ;
        v5[2]       =   1'b0    ;
        v6[2]       =   1'b0    ;
        v7[2]       =   1'b0    ;
        h3[7:4]     =   4'h0    ;
    end
    else if(!mb_partition_i[1]) begin //32x32       
        v4[2]       =   1'b0    ;
        v5[2]       =   1'b0    ;
        v6[2]       =   1'b0    ;
        v7[2]       =   1'b0    ;
        h3[7:4]     =   4'h0    ;
    end
    else if(mb_partition_i[8])  begin //8x8 
        v4[2]       =   1'b1    ;
        v5[2]       =   1'b1    ;
        v6[2]       =   1'b1    ;
        v7[2]       =   1'b1    ;
        h3[7:4]     =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[17:16])
            2'b00:begin v4[2]= 1'b0;v5[2]= 1'b0;v6[2]= 1'b0;v7[2]= 1'b0;h3[7:4]=4'h0; end
            2'b01:begin v4[2]= 1'b0;v5[2]= 1'b0;v6[2]= 1'b0;v7[2]= 1'b0;h3[7:4]=4'hf; end
            2'b10:begin v4[2]= 1'b1;v5[2]= 1'b1;v6[2]= 1'b1;v7[2]= 1'b1;h3[7:4]=4'h0; end
          default:begin v4[2]= 1'b1;v5[2]= 1'b1;v6[2]= 1'b1;v7[2]= 1'b1;h3[7:4]=4'hf; end
        endcase     
    end     
end 

always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v4[4]       =   1'b0    ;
        v5[4]       =   1'b0    ;
        v6[4]       =   1'b0    ;
        v7[4]       =   1'b0    ;
        h3[11:8]    =   4'h0    ;
    end
    else if(!mb_partition_i[2]) begin //32x32       
        v4[4]       =   1'b0    ;
        v5[4]       =   1'b0    ;
        v6[4]       =   1'b0    ;
        v7[4]       =   1'b0    ;
        h3[11:8]    =   4'h0    ;
    end
    else if(mb_partition_i[11])  begin //8x8    
        v4[4]       =   1'b1    ;
        v5[4]       =   1'b1    ;
        v6[4]       =   1'b1    ;
        v7[4]       =   1'b1    ;
        h3[11:8]    =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[23:22])
            2'b00:begin v4[4]= 1'b0;v5[4]= 1'b0;v6[4]= 1'b0;v7[4]= 1'b0;h3[11:8]=4'h0; end
            2'b01:begin v4[4]= 1'b0;v5[4]= 1'b0;v6[4]= 1'b0;v7[4]= 1'b0;h3[11:8]=4'hf; end
            2'b10:begin v4[4]= 1'b1;v5[4]= 1'b1;v6[4]= 1'b1;v7[4]= 1'b1;h3[11:8]=4'h0; end
          default:begin v4[4]= 1'b1;v5[4]= 1'b1;v6[4]= 1'b1;v7[4]= 1'b1;h3[11:8]=4'hf; end
        endcase     
    end     
end 

always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v4[6]       =   1'b0    ;
        v5[6]       =   1'b0    ;
        v6[6]       =   1'b0    ;
        v7[6]       =   1'b0    ;
        h3[15:12]   =   4'h0    ;
    end
    else if(!mb_partition_i[2]) begin //32x32       
        v4[6]       =   1'b0    ;
        v5[6]       =   1'b0    ;
        v6[6]       =   1'b0    ;
        v7[6]       =   1'b0    ;
        h3[15:12]   =   4'h0    ;
    end
    else if(mb_partition_i[12])  begin //8x8    
        v4[6]       =   1'b1    ;
        v5[6]       =   1'b1    ;
        v6[6]       =   1'b1    ;
        v7[6]       =   1'b1    ;
        h3[15:12]   =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[25:24])
            2'b00:begin v4[6]= 1'b0;v5[6]= 1'b0;v6[6]= 1'b0;v7[6]= 1'b0;h3[15:12]=4'h0; end
            2'b01:begin v4[6]= 1'b0;v5[6]= 1'b0;v6[6]= 1'b0;v7[6]= 1'b0;h3[15:12]=4'hf; end
            2'b10:begin v4[6]= 1'b1;v5[6]= 1'b1;v6[6]= 1'b1;v7[6]= 1'b1;h3[15:12]=4'h0; end
          default:begin v4[6]= 1'b1;v5[6]= 1'b1;v6[6]= 1'b1;v7[6]= 1'b1;h3[15:12]=4'h1; end
        endcase     
    end     
end 
//h5
always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v8[0]       =   1'b0    ;
        v9[0]       =   1'b0    ;
        v10[0]      =   1'b0    ;
        v11[0]      =   1'b0    ;
        h5[3:0]     =   4'h0    ;
    end
    else if(!mb_partition_i[3]) begin //32x32       
        v8[0]       =   1'b0    ;
        v9[0]       =   1'b0    ;
        v10[0]      =   1'b0    ;
        v11[0]      =   1'b0    ;
        h5[3:0]     =   4'h0    ;
    end
    else if(mb_partition_i[13])  begin //8x8    
        v8[0]       =   1'b1    ;
        v9[0]       =   1'b1    ;
        v10[0]      =   1'b1    ;
        v11[0]      =   1'b1    ;
        h5[3:0]     =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[27:26])
            2'b00:begin v8[0]= 1'b0;v9[0]= 1'b0;v10[0]= 1'b0;v11[0]= 1'b0;h5[3:0]=4'h0; end
            2'b01:begin v8[0]= 1'b0;v9[0]= 1'b0;v10[0]= 1'b0;v11[0]= 1'b0;h5[3:0]=4'hf; end
            2'b10:begin v8[0]= 1'b1;v9[0]= 1'b1;v10[0]= 1'b1;v11[0]= 1'b1;h5[3:0]=4'h0; end
          default:begin v8[0]= 1'b1;v9[0]= 1'b1;v10[0]= 1'b1;v11[0]= 1'b1;h5[3:0]=4'hf; end
        endcase     
    end     
end     

always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v8[2]       =   1'b0    ;
        v9[2]       =   1'b0    ;
        v10[2]      =   1'b0    ;
        v11[2]      =   1'b0    ;
        h5[7:4]     =   4'h0    ;
    end
    else if(!mb_partition_i[3]) begin //32x32       
        v8[2]       =   1'b0    ;
        v9[2]       =   1'b0    ;
        v10[2]      =   1'b0    ;
        v11[2]      =   1'b0    ;
        h5[7:4]     =   4'h0    ;
    end
    else if(mb_partition_i[14])  begin //8x8    
        v8[2]       =   1'b1    ;
        v9[2]       =   1'b1    ;
        v10[2]      =   1'b1    ;
        v11[2]      =   1'b1    ;
        h5[7:4]     =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[29:28])
            2'b00:begin v8[2]= 1'b0;v9[2]= 1'b0;v10[2]= 1'b0;v11[2]= 1'b0;h5[7:4]=4'h0; end
            2'b01:begin v8[2]= 1'b0;v9[2]= 1'b0;v10[2]= 1'b0;v11[2]= 1'b0;h5[7:4]=4'hf; end
            2'b10:begin v8[2]= 1'b1;v9[2]= 1'b1;v10[2]= 1'b1;v11[2]= 1'b1;h5[7:4]=4'h0; end
          default:begin v8[2]= 1'b1;v9[2]= 1'b1;v10[2]= 1'b1;v11[2]= 1'b1;h5[7:4]=4'h1; end
        endcase     
    end     
end 

always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v8[4]       =   1'b0    ;
        v9[4]       =   1'b0    ;
        v10[4]      =   1'b0    ;
        v11[4]      =   1'b0    ;
        h5[11:8]    =   4'h0    ;
    end
    else if(!mb_partition_i[4]) begin //32x32       
        v8[4]       =   1'b0    ;
        v9[4]       =   1'b0    ;
        v10[4]      =   1'b0    ;
        v11[4]      =   1'b0    ;
        h5[11:8]    =   4'h0    ;
    end
    else if(mb_partition_i[17])  begin //8x8    
        v8[4]       =   1'b1    ;
        v9[4]       =   1'b1    ;
        v10[4]      =   1'b1    ;
        v11[4]      =   1'b1    ;
        h5[11:8]    =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[35:34])
            2'b00:begin v8[4]= 1'b0;v9[4]= 1'b0;v10[4]= 1'b0;v11[4]= 1'b0;h5[11:8]=4'h0; end
            2'b01:begin v8[4]= 1'b0;v9[4]= 1'b0;v10[4]= 1'b0;v11[4]= 1'b0;h5[11:8]=4'hf; end
            2'b10:begin v8[4]= 1'b1;v9[4]= 1'b1;v10[4]= 1'b1;v11[4]= 1'b1;h5[11:8]=4'h0; end
          default:begin v8[4]= 1'b1;v9[4]= 1'b1;v10[4]= 1'b1;v11[4]= 1'b1;h5[11:8]=4'hf; end
        endcase     
    end     
end 

always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v8[6]       =   1'b0    ;
        v9[6]       =   1'b0    ;
        v10[6]      =   1'b0    ;
        v11[6]      =   1'b0    ;
        h5[15:12]   =   4'h0    ;
    end
    else if(!mb_partition_i[4]) begin //32x32       
        v8[6]       =   1'b0    ;
        v9[6]       =   1'b0    ;
        v10[6]      =   1'b0    ;
        v11[6]      =   1'b0    ;
        h5[15:12]   =   4'h0    ;
    end
    else if(mb_partition_i[18])  begin //8x8    
        v8[6]       =   1'b1    ;
        v9[6]       =   1'b1    ;
        v10[6]      =   1'b1    ;
        v11[6]      =   1'b1    ;
        h5[15:12]   =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[37:36])
            2'b00:begin v8[6]= 1'b0;v9[6]= 1'b0;v10[6]= 1'b0;v11[6]= 1'b0;h5[15:12]=4'h0; end
            2'b01:begin v8[6]= 1'b0;v9[6]= 1'b0;v10[6]= 1'b0;v11[6]= 1'b0;h5[15:12]=4'hf; end
            2'b10:begin v8[6]= 1'b1;v9[6]= 1'b1;v10[6]= 1'b1;v11[6]= 1'b1;h5[15:12]=4'h0; end
          default:begin v8[6]= 1'b1;v9[6]= 1'b1;v10[6]= 1'b1;v11[6]= 1'b1;h5[15:12]=4'hf; end
        endcase     
    end     
end 

//h7
always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v12[0]      =   1'b0    ;
        v13[0]      =   1'b0    ;
        v14[0]      =   1'b0    ;
        v15[0]      =   1'b0    ;
        h7[3:0]     =   4'h0    ;
    end
    else if(!mb_partition_i[3]) begin //32x32       
        v12[0]      =   1'b0    ;
        v13[0]      =   1'b0    ;
        v14[0]      =   1'b0    ;
        v15[0]      =   1'b0    ;
        h7[3:0]     =   4'h0    ;
    end
    else if(mb_partition_i[15])  begin //8x8    
        v12[0]      =   1'b1    ;
        v13[0]      =   1'b1    ;
        v14[0]      =   1'b1    ;
        v15[0]      =   1'b1    ;
        h7[3:0]     =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[31:30])
            2'b00:begin v12[0]= 1'b0;v13[0]= 1'b0;v14[0]= 1'b0;v15[0]= 1'b0;h7[3:0]=4'h0; end
            2'b01:begin v12[0]= 1'b0;v13[0]= 1'b0;v14[0]= 1'b0;v15[0]= 1'b0;h7[3:0]=4'hf; end
            2'b10:begin v12[0]= 1'b1;v13[0]= 1'b1;v14[0]= 1'b1;v15[0]= 1'b1;h7[3:0]=4'h0; end
          default:begin v12[0]= 1'b1;v13[0]= 1'b1;v14[0]= 1'b1;v15[0]= 1'b1;h7[3:0]=4'hf; end
        endcase     
    end     
end     

always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v12[2]      =   1'b0    ;
        v13[2]      =   1'b0    ;
        v14[2]      =   1'b0    ;
        v15[2]      =   1'b0    ;
        h7[7:4]     =   4'h0    ;
    end
    else if(!mb_partition_i[3]) begin //32x32       
        v12[2]      =   1'b0    ;
        v13[2]      =   1'b0    ;
        v14[2]      =   1'b0    ;
        v15[2]      =   1'b0    ;
        h7[7:4]     =   4'h0    ;
    end
    else if(mb_partition_i[16])  begin //8x8    
        v12[2]      =   1'b1    ;
        v13[2]      =   1'b1    ;
        v14[2]      =   1'b1    ;
        v15[2]      =   1'b1    ;
        h7[7:4]     =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[33:32])
            2'b00:begin v12[2]= 1'b0;v13[2]= 1'b0;v14[2]= 1'b0;v15[2]= 1'b0;h7[7:4]=4'h0; end
            2'b01:begin v12[2]= 1'b0;v13[2]= 1'b0;v14[2]= 1'b0;v15[2]= 1'b0;h7[7:4]=4'hf; end
            2'b10:begin v12[2]= 1'b1;v13[2]= 1'b1;v14[2]= 1'b1;v15[2]= 1'b1;h7[7:4]=4'h0; end
          default:begin v12[2]= 1'b1;v13[2]= 1'b1;v14[2]= 1'b1;v15[2]= 1'b1;h7[7:4]=4'hd; end
        endcase     
    end     
end 

always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v12[4]      =   1'b0    ;
        v13[4]      =   1'b0    ;
        v14[4]      =   1'b0    ;
        v15[4]      =   1'b0    ;
        h7[11:8]    =   4'h0    ;
    end
    else if(!mb_partition_i[4]) begin //32x32       
        v12[4]      =   1'b0    ;
        v13[4]      =   1'b0    ;
        v14[4]      =   1'b0    ;
        v15[4]      =   1'b0    ;
        h7[11:8]    =   4'h0    ;
    end
    else if(mb_partition_i[19])  begin //8x8    
        v12[4]      =   1'b1    ;
        v13[4]      =   1'b1    ;
        v14[4]      =   1'b1    ;
        v15[4]      =   1'b1    ;
        h7[11:8]    =   4'hf    ;
    end
    else begin                      //16x16
        case(mb_p_pu_mode_i[39:38])
            2'b00:begin v12[4]= 1'b0;v13[4]= 1'b0;v14[4]= 1'b0;v15[4]= 1'b0;h7[11:8]=4'h0; end
            2'b01:begin v12[4]= 1'b0;v13[4]= 1'b0;v14[4]= 1'b0;v15[4]= 1'b0;h7[11:8]=4'hf; end
            2'b10:begin v12[4]= 1'b1;v13[4]= 1'b1;v14[4]= 1'b1;v15[4]= 1'b1;h7[11:8]=4'h0; end
          default:begin v12[4]= 1'b1;v13[4]= 1'b1;v14[4]= 1'b1;v15[4]= 1'b1;h7[11:8]=4'hf; end
        endcase     
    end     
end 

always @* begin     
    if(!mb_partition_i[0])     begin //64x64        
        v12[6]      =   1'b0    ;
        v13[6]      =   1'b0    ;
        v14[6]      =   1'b0    ;
        v15[6]      =   1'b0    ;
        h7[15:12]   =   4'h0    ;
    end
    else if(!mb_partition_i[4]) begin //32x32       
        v12[6]      =   1'b0    ;
        v13[6]      =   1'b0    ;
        v14[6]      =   1'b0    ;
        v15[6]      =   1'b0    ;
        h7[15:12]   =   4'h0    ;
    end
    else if(mb_partition_i[20])  begin //8x8    
        v12[6]      =   1'b1    ;
        v13[6]      =   1'b1    ;
        v14[6]      =   1'b1    ;
        v15[6]      =   1'b1    ;
        h7[15:12]   =   4'hf    ;
    end
    else begin                          //16x16
        case(mb_p_pu_mode_i[41:40])
            2'b00:begin v12[6]= 1'b0;v13[6]= 1'b0;v14[6]= 1'b0;v15[6]= 1'b0;h7[15:12]=4'h0; end
            2'b01:begin v12[6]= 1'b0;v13[6]= 1'b0;v14[6]= 1'b0;v15[6]= 1'b0;h7[15:12]=4'hf; end
            2'b10:begin v12[6]= 1'b1;v13[6]= 1'b1;v14[6]= 1'b1;v15[6]= 1'b1;h7[15:12]=4'h0; end
          default:begin v12[6]= 1'b1;v13[6]= 1'b1;v14[6]= 1'b1;v15[6]= 1'b1;h7[15:12]=4'hf; end
        endcase     
    end     
end 
//16x16 pu edge :h2 h6  v[1  5]
always @*  begin
    if(!mb_partition_i[0])  begin       //64x64
        v0[1]       =   1'b0    ;
        v1[1]       =   1'b0    ;
        v2[1]       =   1'b0    ;
        v3[1]       =   1'b0    ;
        v4[1]       =   1'b0    ;
        v5[1]       =   1'b0    ;
        v6[1]       =   1'b0    ;
        v7[1]       =   1'b0    ;
        h2[7:0]     =   8'h0    ;
    end
    else if(!mb_partition_i[1]) begin   //32x32
        case(mb_p_pu_mode_i[3:2])
            2'b00:begin                 //2Nx2N
                         v0[1]=1'b0;v1[1]=1'b0;v2[1]=1'b0;v3[1]=1'b0; 
                         v4[1]=1'b0;v5[1]=1'b0;v6[1]=1'b0;v7[1]=1'b0;
                         h2[7:0]=8'h0;
            end
            
            2'b01:begin                 //2NxN
                         v0[1]=1'b0;v1[1]=1'b0;v2[1]=1'b0;v3[1]=1'b0;
                         v4[1]=1'b0;v5[1]=1'b0;v6[1]=1'b0;v7[1]=1'b0;
                         h2[7:0]=8'hff;
            end
            2'b10:begin                 //Nx2N
                         v0[1]=1'b1;v1[1]=1'b1;v2[1]=1'b1;v3[1]=1'b1;
                         v4[1]=1'b1;v5[1]=1'b1;v6[1]=1'b1;v7[1]=1'b1;
                         h2[7:0]=8'h00;
            end
            2'b11:begin                 //split
                         v0[1]=1'b1;v1[1]=1'b1;v2[1]=1'b1;v3[1]=1'b1;
                         v4[1]=1'b1;v5[1]=1'b1;v6[1]=1'b1;v7[1]=1'b1;
                         h2[7:0]=8'hff;
            end
        endcase
    end
    else begin
        v0[1]       =   1'b1    ;
        v1[1]       =   1'b1    ;
        v2[1]       =   1'b1    ;
        v3[1]       =   1'b1    ;
        v4[1]       =   1'b1    ;
        v5[1]       =   1'b1    ;
        v6[1]       =   1'b1    ;
        v7[1]       =   1'b1    ;
        h2[7:0]     =   8'hff   ;
    end
end

always @*  begin
    if(!mb_partition_i[0])  begin       //64x64
        v0[5]       =   1'b0    ;
        v1[5]       =   1'b0    ;
        v2[5]       =   1'b0    ;
        v3[5]       =   1'b0    ;
        v4[5]       =   1'b0    ;
        v5[5]       =   1'b0    ;
        v6[5]       =   1'b0    ;
        v7[5]       =   1'b0    ;
        h2[15:8]     =   8'h0   ;
    end
    else if(!mb_partition_i[2]) begin   //32x32
        case(mb_p_pu_mode_i[5:4])
            2'b00:begin                 //2Nx2N
                         v0[5]=1'b0;v1[5]=1'b0;v2[5]=1'b0;v3[5]=1'b0; 
                         v4[5]=1'b0;v5[5]=1'b0;v6[5]=1'b0;v7[5]=1'b0;
                         h2[15:8]=8'h0;
            end
            
            2'b01:begin                 //2NxN
                         v0[5]=1'b0;v1[5]=1'b0;v2[5]=1'b0;v3[5]=1'b0;
                         v4[5]=1'b0;v5[5]=1'b0;v6[5]=1'b0;v7[5]=1'b0;
                         h2[15:8]=8'hff;
            end
            2'b10:begin                 //Nx2N
                         v0[5]=1'b1;v1[5]=1'b1;v2[5]=1'b1;v3[5]=1'b1;
                         v4[5]=1'b1;v5[5]=1'b1;v6[5]=1'b1;v7[5]=1'b1;
                         h2[15:8]=8'h00;
            end
            2'b11:begin                 //split
                         v0[5]=1'b1;v1[5]=1'b1;v2[5]=1'b1;v3[5]=1'b1;
                         v4[5]=1'b1;v5[5]=1'b1;v6[5]=1'b1;v7[5]=1'b1;
                         h2[15:8]=8'hff;
            end
        endcase
    end
    else  begin
        v0[5]       =   1'b1    ;
        v1[5]       =   1'b1    ;
        v2[5]       =   1'b1    ;
        v3[5]       =   1'b1    ;
        v4[5]       =   1'b1    ;
        v5[5]       =   1'b1    ;
        v6[5]       =   1'b1    ;
        v7[5]       =   1'b1    ;
        h2[15:8]    =   8'hff   ;
    end
end

always @*  begin
    if(!mb_partition_i[0])  begin       //64x64
        v8[1]       =   1'b0    ;
        v9[1]       =   1'b0    ;
        v10[1]      =   1'b0    ;
        v11[1]      =   1'b0    ;
        v12[1]      =   1'b0    ;
        v13[1]      =   1'b0    ;
        v14[1]      =   1'b0    ;
        v15[1]      =   1'b0    ;
        h6[7:0]     =   8'h0    ;
    end
    else if(!mb_partition_i[3]) begin   //32x32
        case(mb_p_pu_mode_i[7:6])
            2'b00:begin                 //2Nx2N
                         v8[1]=1'b0 ;v9[1]=1'b0 ;v10[1]=1'b0;v11[1]=1'b0; 
                         v12[1]=1'b0;v13[1]=1'b0;v14[1]=1'b0;v15[1]=1'b0;
                         h6[7:0]=8'h0;
            end
            
            2'b01:begin                 //2NxN
                         v8[1]=1'b0;v9[1]=1'b0;v10[1]=1'b0;v11[1]=1'b0;
                         v12[1]=1'b0;v13[1]=1'b0;v14[1]=1'b0;v15[1]=1'b0;
                         h6[7:0]=8'hff;
            end
            2'b10:begin                 //Nx2N
                         v8[1]=1'b1;v9[1]=1'b1;v10[1]=1'b1;v11[1]=1'b1;
                         v12[1]=1'b1;v13[1]=1'b1;v14[1]=1'b1;v15[1]=1'b1;
                         h6[7:0]=8'h00;
            end
            2'b11:begin                 //split
                         v8[1]=1'b1;v9[1]=1'b1;v10[1]=1'b1;v11[1]=1'b1;
                         v12[1]=1'b1;v13[1]=1'b1;v14[1]=1'b1;v15[1]=1'b1;
                         h6[7:0]=8'hff;
            end
        endcase
    end
    else begin
        v8[1]       =   1'b1    ;
        v9[1]       =   1'b1    ;
        v10[1]      =   1'b1    ;
        v11[1]      =   1'b1    ;
        v12[1]      =   1'b1    ;
        v13[1]      =   1'b1    ;
        v14[1]      =   1'b1    ;
        v15[1]      =   1'b1    ;
        h6[7:0]    =   8'hff    ;
    end
end


always @*  begin
    if(!mb_partition_i[0])  begin       //64x64
        v8[5]       =   1'b0    ;
        v9[5]       =   1'b0    ;
        v10[5]      =   1'b0    ;
        v11[5]      =   1'b0    ;
        v12[5]      =   1'b0    ;
        v13[5]      =   1'b0    ;
        v14[5]      =   1'b0    ;
        v15[5]      =   1'b0    ;
        h6[15:8]    =   8'h0    ;
    end
    else if(!mb_partition_i[4]) begin   //32x32
        case(mb_p_pu_mode_i[9:8])
            2'b00:begin                 //2Nx2N
                         v8[5]=1'b0 ;v9[5]=1'b0 ;v10[5]=1'b0;v11[5]=1'b0; 
                         v12[5]=1'b0;v13[5]=1'b0;v14[5]=1'b0;v15[5]=1'b0;
                         h6[15:8]=8'h0;
            end
            
            2'b01:begin                 //2NxN
                         v8[5]=1'b0 ;v9[5]=1'b0 ;v10[5]=1'b0;v11[5]=1'b0;
                         v12[5]=1'b0;v13[5]=1'b0;v14[5]=1'b0;v15[5]=1'b0;
                         h6[15:8]=8'hff;
            end
            2'b10:begin                 //Nx2N
                         v8[5]=1'b1 ;v9[5]=1'b1 ;v10[5]=1'b1;v11[5]=1'b1;
                         v12[5]=1'b1;v13[5]=1'b1;v14[5]=1'b1;v15[5]=1'b1;
                         h6[15:8]=8'h00;
            end
            2'b11:begin                 //split
                         v8[5]=1'b1;v9[5]=1'b1;v10[5]=1'b1;v11[5]=1'b1;
                         v12[5]=1'b1;v13[5]=1'b1;v14[5]=1'b1;v15[5]=1'b1;
                         h6[15:8]=8'hff;
            end
        endcase
    end
    else begin
        v8[5]       =   1'b1    ;
        v9[5]       =   1'b1    ;
        v10[5]      =   1'b1    ;
        v11[5]      =   1'b1    ;
        v12[5]      =   1'b1    ;
        v13[5]      =   1'b1    ;
        v14[5]      =   1'b1    ;
        v15[5]      =   1'b1    ;
        h6[15:8]    =   8'hff   ;
    end
end
//32x32 pu edge :h4  v[3]
always @*   begin
    if(mb_partition_i[0])  begin    //64x64 split
        v0[3]       =   1'b1    ;
        v1[3]       =   1'b1    ;
        v2[3]       =   1'b1    ;
        v3[3]       =   1'b1    ;
        v4[3]       =   1'b1    ;
        v5[3]       =   1'b1    ;
        v6[3]       =   1'b1    ;
        v7[3]       =   1'b1    ;
        v8[3]       =   1'b1    ;
        v9[3]       =   1'b1    ;
        v10[3]      =   1'b1    ;
        v11[3]      =   1'b1    ;
        v12[3]      =   1'b1    ;
        v13[3]      =   1'b1    ;
        v14[3]      =   1'b1    ;
        v15[3]      =   1'b1    ;   
        h4          =   16'hffff;
    end
    else                   begin   //64x64
        case(mb_p_pu_mode_i[1:0])
            2'b00:begin            //2Nx2N
                    v0[3]       =   1'b0    ;
                    v1[3]       =   1'b0    ;
                    v2[3]       =   1'b0    ;
                    v3[3]       =   1'b0    ;
                    v4[3]       =   1'b0    ;
                    v5[3]       =   1'b0    ;
                    v6[3]       =   1'b0    ;
                    v7[3]       =   1'b0    ;
                    v8[3]       =   1'b0    ;
                    v9[3]       =   1'b0    ;
                    v10[3]      =   1'b0    ;
                    v11[3]      =   1'b0    ;
                    v12[3]      =   1'b0    ;
                    v13[3]      =   1'b0    ;
                    v14[3]      =   1'b0    ;
                    v15[3]      =   1'b0    ;   
                    h4          =   16'h0000;   
            end
            2'b01:begin             //2NxN
                    v0[3]       =   1'b0    ;
                    v1[3]       =   1'b0    ;
                    v2[3]       =   1'b0    ;
                    v3[3]       =   1'b0    ;
                    v4[3]       =   1'b0    ;
                    v5[3]       =   1'b0    ;
                    v6[3]       =   1'b0    ;
                    v7[3]       =   1'b0    ;
                    v8[3]       =   1'b0    ;
                    v9[3]       =   1'b0    ;
                    v10[3]      =   1'b0    ;
                    v11[3]      =   1'b0    ;
                    v12[3]      =   1'b0    ;
                    v13[3]      =   1'b0    ;
                    v14[3]      =   1'b0    ;
                    v15[3]      =   1'b0    ;   
                    h4          =   16'hffff;                   
            end
            2'b10:begin             //Nx2N
                    v0[3]       =   1'b1    ;
                    v1[3]       =   1'b1    ;
                    v2[3]       =   1'b1    ;
                    v3[3]       =   1'b1    ;
                    v4[3]       =   1'b1    ;
                    v5[3]       =   1'b1    ;
                    v6[3]       =   1'b1    ;
                    v7[3]       =   1'b1    ;
                    v8[3]       =   1'b1    ;
                    v9[3]       =   1'b1    ;
                    v10[3]      =   1'b1    ;
                    v11[3]      =   1'b1    ;
                    v12[3]      =   1'b1    ;
                    v13[3]      =   1'b1    ;
                    v14[3]      =   1'b1    ;
                    v15[3]      =   1'b1    ;   
                    h4          =   16'h0000;       
            end
          default:begin             //split
                    v0[3]       =   1'b1    ;
                    v1[3]       =   1'b1    ;
                    v2[3]       =   1'b1    ;
                    v3[3]       =   1'b1    ;
                    v4[3]       =   1'b1    ;
                    v5[3]       =   1'b1    ;
                    v6[3]       =   1'b1    ;
                    v7[3]       =   1'b1    ;
                    v8[3]       =   1'b1    ;
                    v9[3]       =   1'b1    ;
                    v10[3]      =   1'b1    ;
                    v11[3]      =   1'b1    ;
                    v12[3]      =   1'b1    ;
                    v13[3]      =   1'b1    ;
                    v14[3]      =   1'b1    ;
                    v15[3]      =   1'b1    ;   
                    h4          =   16'hffff;             
            end
        endcase
    end
end


endmodule 