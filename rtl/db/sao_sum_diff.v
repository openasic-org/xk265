//-----------------------------------------------------------------------------------------------
//                                                                 
//  COPYRIGHT (C) 2011, VIPcore Group, Fudan University
//                                                                  
//  THIS FILE MAY NOT BE MODIFIED OR REDISTRIBUtu_veD WITHOUT THE      
//  EXPRESSED WRITtu_veN CONSENT OF VIPcore Group
//                                                                  
//  VIPcore       : http://soc.fudan.edu.cn/vip    
//  IP Owner      : Yibo FAN
//  Contact       : fanyibo@fudan.edu.cn             
//------------------------------------------------------------------------------------------------
// Filename       : sao_sum_diff.v
// Author         : TANG
// Creatu_ved     : 
// Description    :         
//------------------------------------------------------------------------------------------------
//`include "enc_defines.v"

module sao_sum_diff(
        num             ,
        num_sum         ,
        diff_sum        ,
        // valid            ,// actige high
        diff_i0     ,diff_i1    ,diff_i2    ,diff_i3    ,diff_i4   ,
        diff_i5     ,diff_i6    ,diff_i7    ,diff_i8    ,diff_i9   ,
        diff_i10    ,diff_i11   ,diff_i12   ,diff_i13   ,diff_i14  ,
        diff_i15    
        );

input   [16-1:0]     num                ;
input   [  5:0]      diff_i0    ,diff_i1     ,diff_i2    ,diff_i3     ,diff_i4       ,
                     diff_i5    ,diff_i6     ,diff_i7    ,diff_i8     ,diff_i9       ,
                     diff_i10   ,diff_i11    ,diff_i12   ,diff_i13    ,diff_i14      ,
                     diff_i15   ;

output wire signed  [9:0]      diff_sum            ;  
output wire         [3:0]      num_sum             ;
            
wire signed [5:0] diff_w_0 ; 
wire signed [5:0] diff_w_1 ;
wire signed [5:0] diff_w_2 ; 
wire signed [5:0] diff_w_3 ;
wire signed [5:0] diff_w_4 ; 
wire signed [5:0] diff_w_5 ;
wire signed [5:0] diff_w_6 ; 
wire signed [5:0] diff_w_7 ;
wire signed [5:0] diff_w_8 ; 
wire signed [5:0] diff_w_9 ;
wire signed [5:0] diff_w_10; 
wire signed [5:0] diff_w_11;
wire signed [5:0] diff_w_12; 
wire signed [5:0] diff_w_13;
wire signed [5:0] diff_w_14; 
wire signed [5:0] diff_w_15;

assign diff_w_0  = num[0 ] ? diff_i0  : 0 ;
assign diff_w_1  = num[1 ] ? diff_i1  : 0 ;
assign diff_w_2  = num[2 ] ? diff_i2  : 0 ;
assign diff_w_3  = num[3 ] ? diff_i3  : 0 ;
assign diff_w_4  = num[4 ] ? diff_i4  : 0 ;
assign diff_w_5  = num[5 ] ? diff_i5  : 0 ;
assign diff_w_6  = num[6 ] ? diff_i6  : 0 ;
assign diff_w_7  = num[7 ] ? diff_i7  : 0 ;
assign diff_w_8  = num[8 ] ? diff_i8  : 0 ;
assign diff_w_9  = num[9 ] ? diff_i9  : 0 ;
assign diff_w_10 = num[10] ? diff_i10 : 0 ;
assign diff_w_11 = num[11] ? diff_i11 : 0 ;
assign diff_w_12 = num[12] ? diff_i12 : 0 ;
assign diff_w_13 = num[13] ? diff_i13 : 0 ;
assign diff_w_14 = num[14] ? diff_i14 : 0 ;
assign diff_w_15 = num[15] ? diff_i15 : 0 ;


assign num_sum = num[  0]  + num[  1] 
               + num[  2]  + num[  3] 
               + num[  4]  + num[  5] 
               + num[  6]  + num[  7] 
               + num[  8]  + num[  9] 
               + num[ 10]  + num[ 11] 
               + num[ 12]  + num[ 13] 
               + num[ 14]  + num[ 15] ;


assign diff_sum= diff_w_0  + diff_w_1 
               + diff_w_2  + diff_w_3 
               + diff_w_4  + diff_w_5 
               + diff_w_6  + diff_w_7 
               + diff_w_8  + diff_w_9 
               + diff_w_10 + diff_w_11
               + diff_w_12 + diff_w_13
               + diff_w_14 + diff_w_15;


endmodule 