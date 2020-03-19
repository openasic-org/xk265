//company       : xm tech
//project name  : H265
//top module    : dct_top_2d.v
//data          : 2018.01.08
//file name     : re_level0.v
//delay         : dct4x4 or dst4x4 or dct8x8: 2clk ; dct16x16\dct32x32: 3clk
//describe      :
//modification  :
//v1.0          :
module re_level0(
	clk         ,
	rst_n       ,
	i_dt_vld_32 ,
	i_dt_vld_16 ,
	i_dt_vld_8  ,
	i_dt_vld_4  ,//chro
	i_dt_vld_dst,//luma
	i_inverse   ,
	i_data0     ,
	i_data1     ,
	i_data2     ,
	i_data3     ,
	i_data4     ,
	i_data5     ,
	i_data6     ,
	i_data7     ,
	i_data8     ,
	i_data9     ,
	i_data10    ,
	i_data11    ,
	i_data12    ,
	i_data13    ,
	i_data14    ,
	i_data15    ,

	o_data0     ,
	o_data1     ,
	o_data2     ,
	o_data3     ,
	o_data4     ,
	o_data5     ,
	o_data6     ,
	o_data7     ,
	o_data8     ,
	o_data9     ,
	o_data10    ,
	o_data11    ,
	o_data12    ,
	o_data13    ,
	o_data14    ,
	o_data15    
);

input	        clk            ; 
input	        rst_n          ; 
input	        i_dt_vld_32    ; 
input	        i_dt_vld_16    ; 
input	        i_dt_vld_8     ;
input           i_dt_vld_4     ; 
input	        i_dt_vld_dst   ; 
input	        i_inverse      ; 
input [16:0]	i_data0        ; 
input [16:0]	i_data1        ; 
input [16:0]	i_data2        ; 
input [16:0]	i_data3        ; 
input [16:0]	i_data4        ; 
input [16:0]	i_data5        ; 
input [16:0]	i_data6        ; 
input [16:0]	i_data7        ; 
input [16:0]	i_data8        ; 
input [16:0]	i_data9        ; 
input [16:0]	i_data10       ; 
input [16:0]	i_data11       ; 
input [16:0]	i_data12       ; 
input [16:0]	i_data13       ; 
input [16:0]	i_data14       ; 
input [16:0]	i_data15       ; 

output [27:0]	o_data0    ; 
output [27:0]	o_data1    ; 
output [27:0]	o_data2    ; 
output [27:0]	o_data3    ; 
output [27:0]	o_data4    ; 
output [27:0]	o_data5    ; 
output [27:0]	o_data6    ; 
output [27:0]	o_data7    ; 
output [27:0]	o_data8    ; 
output [27:0]	o_data9    ; 
output [27:0]	o_data10   ; 
output [27:0]	o_data11   ; 
output [27:0]	o_data12   ; 
output [27:0]	o_data13   ; 
output [27:0]	o_data14   ; 
output [27:0]	o_data15   ; 
//--------------delay----------------//
reg             dt_vld_32_d ;
reg             dt_vld_16_d ;
reg    [1:0]    dt_vld_8_d  ;
reg    [1:0]    dt_vld_4_d  ;
reg    [1:0]    dt_vld_dst_d;

//----------o_data0----------------//
reg [24:0]        data0000;
reg [24:0]        data0001;
reg [24:0]        data0002;
reg [24:0]        data0003;
reg [24:0]        data0004;
reg [24:0]        data0005;
reg [24:0]        data0006;
reg [24:0]        data0007;
reg [24:0]        data0008;
reg [24:0]        data0009;
reg [24:0]        data0010;
reg [24:0]        data0011;
reg [24:0]        data0012;
reg [24:0]        data0013;
reg [24:0]        data0014;
reg [24:0]        data0015;

wire [25:0]       data00_0001  ;
wire [25:0]       data00_0203  ;
reg  [26:0]       data000_stp0 ;
wire [25:0]       data00_0405  ;
wire [25:0]       data00_0607  ;
reg  [26:0]       data001_stp0 ;
wire [25:0]       data00_0809  ;
wire [25:0]       data00_1011  ;
reg  [26:0]       data002_stp0 ;
wire [25:0]       data00_1213  ;
wire [25:0]       data00_1415  ;
reg  [26:0]       data003_stp0 ;
wire [27:0]       data0001_stp0;
wire [27:0]       data0023_stp0;
reg  [27:0]       data000_stp1 ;
reg  [27:0]       o_data0      ;

//------------------------------------------o_data1--------------------------------------------------------//
reg [24:0]        data0100;
reg [24:0]        data0101;
reg [24:0]        data0102;
reg [24:0]        data0103;
reg [24:0]        data0104;
reg [24:0]        data0105;
reg [24:0]        data0106;
reg [24:0]        data0107;
reg [24:0]        data0108;
reg [24:0]        data0109;
reg [24:0]        data0110;
reg [24:0]        data0111;
reg [24:0]        data0112;
reg [24:0]        data0113;
reg [24:0]        data0114;
reg [24:0]        data0115;

wire [25:0]       data01_0001  ;
wire [25:0]       data01_0203  ;
reg  [26:0]       data010_stp0 ;
wire [25:0]       data01_0405  ;
wire [25:0]       data01_0607  ;
reg  [26:0]       data011_stp0 ;
wire [25:0]       data01_0809  ;
wire [25:0]       data01_1011  ;
reg  [26:0]       data012_stp0 ;
wire [25:0]       data01_1213  ;
wire [25:0]       data01_1415  ;
reg  [26:0]       data013_stp0 ;
wire [27:0]       data0101_stp0;
wire [27:0]       data0123_stp0;
reg  [27:0]       data010_stp1 ;
reg  [27:0]       o_data1      ;

reg [24:0]        data0200;
reg [24:0]        data0201;
reg [24:0]        data0202;
reg [24:0]        data0203;
reg [24:0]        data0204;
reg [24:0]        data0205;
reg [24:0]        data0206;
reg [24:0]        data0207;
reg [24:0]        data0208;
reg [24:0]        data0209;
reg [24:0]        data0210;
reg [24:0]        data0211;
reg [24:0]        data0212;
reg [24:0]        data0213;
reg [24:0]        data0214;
reg [24:0]        data0215;

wire [25:0]       data02_0001  ;
wire [25:0]       data02_0203  ;
reg  [26:0]       data020_stp0 ;
wire [25:0]       data02_0405  ;
wire [25:0]       data02_0607  ;
reg  [26:0]       data021_stp0 ;
wire [25:0]       data02_0809  ;
wire [25:0]       data02_1011  ;
reg  [26:0]       data022_stp0 ;
wire [25:0]       data02_1213  ;
wire [25:0]       data02_1415  ;
reg  [26:0]       data023_stp0 ;
wire [27:0]       data0201_stp0;
wire [27:0]       data0223_stp0;
reg  [27:0]       data020_stp1 ;
reg  [27:0]       o_data2      ;

reg [24:0]        data0300;
reg [24:0]        data0301;
reg [24:0]        data0302;
reg [24:0]        data0303;
reg [24:0]        data0304;
reg [24:0]        data0305;
reg [24:0]        data0306;
reg [24:0]        data0307;
reg [24:0]        data0308;
reg [24:0]        data0309;
reg [24:0]        data0310;
reg [24:0]        data0311;
reg [24:0]        data0312;
reg [24:0]        data0313;
reg [24:0]        data0314;
reg [24:0]        data0315;

wire [25:0]       data03_0001  ;
wire [25:0]       data03_0203  ;
reg  [26:0]       data030_stp0 ;
wire [25:0]       data03_0405  ;
wire [25:0]       data03_0607  ;
reg  [26:0]       data031_stp0 ;
wire [25:0]       data03_0809  ;
wire [25:0]       data03_1011  ;
reg  [26:0]       data032_stp0 ;
wire [25:0]       data03_1213  ;
wire [25:0]       data03_1415  ;
reg  [26:0]       data033_stp0 ;
wire [27:0]       data0301_stp0;
wire [27:0]       data0323_stp0;
reg  [27:0]       data030_stp1 ;
reg  [27:0]       o_data3      ;

reg [24:0]        data0400;
reg [24:0]        data0401;
reg [24:0]        data0402;
reg [24:0]        data0403;
reg [24:0]        data0404;
reg [24:0]        data0405;
reg [24:0]        data0406;
reg [24:0]        data0407;
reg [24:0]        data0408;
reg [24:0]        data0409;
reg [24:0]        data0410;
reg [24:0]        data0411;
reg [24:0]        data0412;
reg [24:0]        data0413;
reg [24:0]        data0414;
reg [24:0]        data0415;

wire [25:0]       data04_0001  ;
wire [25:0]       data04_0203  ;
reg  [26:0]       data040_stp0 ;
wire [25:0]       data04_0405  ;
wire [25:0]       data04_0607  ;
reg  [26:0]       data041_stp0 ;
wire [25:0]       data04_0809  ;
wire [25:0]       data04_1011  ;
reg  [26:0]       data042_stp0 ;
wire [25:0]       data04_1213  ;
wire [25:0]       data04_1415  ;
reg  [26:0]       data043_stp0 ;
wire [27:0]       data0401_stp0;
wire [27:0]       data0423_stp0;
reg  [27:0]       data040_stp1 ;
reg  [27:0]       o_data4      ;

reg [24:0]        data0500;
reg [24:0]        data0501;
reg [24:0]        data0502;
reg [24:0]        data0503;
reg [24:0]        data0504;
reg [24:0]        data0505;
reg [24:0]        data0506;
reg [24:0]        data0507;
reg [24:0]        data0508;
reg [24:0]        data0509;
reg [24:0]        data0510;
reg [24:0]        data0511;
reg [24:0]        data0512;
reg [24:0]        data0513;
reg [24:0]        data0514;
reg [24:0]        data0515;

wire [25:0]       data05_0001  ;
wire [25:0]       data05_0203  ;
reg  [26:0]       data050_stp0 ;
wire [25:0]       data05_0405  ;
wire [25:0]       data05_0607  ;
reg  [26:0]       data051_stp0 ;
wire [25:0]       data05_0809  ;
wire [25:0]       data05_1011  ;
reg  [26:0]       data052_stp0 ;
wire [25:0]       data05_1213  ;
wire [25:0]       data05_1415  ;
reg  [26:0]       data053_stp0 ;
wire [27:0]       data0501_stp0;
wire [27:0]       data0523_stp0;
reg  [27:0]       data050_stp1 ;
reg  [27:0]       o_data5      ;

reg [24:0]        data0600;
reg [24:0]        data0601;
reg [24:0]        data0602;
reg [24:0]        data0603;
reg [24:0]        data0604;
reg [24:0]        data0605;
reg [24:0]        data0606;
reg [24:0]        data0607;
reg [24:0]        data0608;
reg [24:0]        data0609;
reg [24:0]        data0610;
reg [24:0]        data0611;
reg [24:0]        data0612;
reg [24:0]        data0613;
reg [24:0]        data0614;
reg [24:0]        data0615;

wire [25:0]       data06_0001  ;
wire [25:0]       data06_0203  ;
reg  [26:0]       data060_stp0 ;
wire [25:0]       data06_0405  ;
wire [25:0]       data06_0607  ;
reg  [26:0]       data061_stp0 ;
wire [25:0]       data06_0809  ;
wire [25:0]       data06_1011  ;
reg  [26:0]       data062_stp0 ;
wire [25:0]       data06_1213  ;
wire [25:0]       data06_1415  ;
reg  [26:0]       data063_stp0 ;
wire [27:0]       data0601_stp0;
wire [27:0]       data0623_stp0;
reg  [27:0]       data060_stp1 ;
reg  [27:0]       o_data6      ;

reg [24:0]        data0700;
reg [24:0]        data0701;
reg [24:0]        data0702;
reg [24:0]        data0703;
reg [24:0]        data0704;
reg [24:0]        data0705;
reg [24:0]        data0706;
reg [24:0]        data0707;
reg [24:0]        data0708;
reg [24:0]        data0709;
reg [24:0]        data0710;
reg [24:0]        data0711;
reg [24:0]        data0712;
reg [24:0]        data0713;
reg [24:0]        data0714;
reg [24:0]        data0715;

wire [25:0]       data07_0001  ;
wire [25:0]       data07_0203  ;
reg  [26:0]       data070_stp0 ;
wire [25:0]       data07_0405  ;
wire [25:0]       data07_0607  ;
reg  [26:0]       data071_stp0 ;
wire [25:0]       data07_0809  ;
wire [25:0]       data07_1011  ;
reg  [26:0]       data072_stp0 ;
wire [25:0]       data07_1213  ;
wire [25:0]       data07_1415  ;
reg  [26:0]       data073_stp0 ;
wire [27:0]       data0701_stp0;
wire [27:0]       data0723_stp0;
reg  [27:0]       data070_stp1 ;
reg  [27:0]       o_data7      ;

reg [24:0]        data0800;
reg [24:0]        data0801;
reg [24:0]        data0802;
reg [24:0]        data0803;
reg [24:0]        data0804;
reg [24:0]        data0805;
reg [24:0]        data0806;
reg [24:0]        data0807;
reg [24:0]        data0808;
reg [24:0]        data0809;
reg [24:0]        data0810;
reg [24:0]        data0811;
reg [24:0]        data0812;
reg [24:0]        data0813;
reg [24:0]        data0814;
reg [24:0]        data0815;

wire [25:0]       data08_0001  ;
wire [25:0]       data08_0203  ;
reg  [26:0]       data080_stp0 ;
wire [25:0]       data08_0405  ;
wire [25:0]       data08_0607  ;
reg  [26:0]       data081_stp0 ;
wire [25:0]       data08_0809  ;
wire [25:0]       data08_1011  ;
reg  [26:0]       data082_stp0 ;
wire [25:0]       data08_1213  ;
wire [25:0]       data08_1415  ;
reg  [26:0]       data083_stp0 ;
wire [27:0]       data0801_stp0;
wire [27:0]       data0823_stp0;
reg  [27:0]       data080_stp1 ;
reg  [27:0]       o_data8      ;

reg [24:0]        data0900;
reg [24:0]        data0901;
reg [24:0]        data0902;
reg [24:0]        data0903;
reg [24:0]        data0904;
reg [24:0]        data0905;
reg [24:0]        data0906;
reg [24:0]        data0907;
reg [24:0]        data0908;
reg [24:0]        data0909;
reg [24:0]        data0910;
reg [24:0]        data0911;
reg [24:0]        data0912;
reg [24:0]        data0913;
reg [24:0]        data0914;
reg [24:0]        data0915;

wire [25:0]       data09_0001  ;
wire [25:0]       data09_0203  ;
reg  [26:0]       data090_stp0 ;
wire [25:0]       data09_0405  ;
wire [25:0]       data09_0607  ;
reg  [26:0]       data091_stp0 ;
wire [25:0]       data09_0809  ;
wire [25:0]       data09_1011  ;
reg  [26:0]       data092_stp0 ;
wire [25:0]       data09_1213  ;
wire [25:0]       data09_1415  ;
reg  [26:0]       data093_stp0 ;
wire [27:0]       data0901_stp0;
wire [27:0]       data0923_stp0;
reg  [27:0]       data090_stp1 ;
reg  [27:0]       o_data9      ;

reg [24:0]        data1000;
reg [24:0]        data1001;
reg [24:0]        data1002;
reg [24:0]        data1003;
reg [24:0]        data1004;
reg [24:0]        data1005;
reg [24:0]        data1006;
reg [24:0]        data1007;
reg [24:0]        data1008;
reg [24:0]        data1009;
reg [24:0]        data1010;
reg [24:0]        data1011;
reg [24:0]        data1012;
reg [24:0]        data1013;
reg [24:0]        data1014;
reg [24:0]        data1015;

wire [25:0]       data10_0001  ;
wire [25:0]       data10_0203  ;
reg  [26:0]       data100_stp0 ;
wire [25:0]       data10_0405  ;
wire [25:0]       data10_0607  ;
reg  [26:0]       data101_stp0 ;
wire [25:0]       data10_0809  ;
wire [25:0]       data10_1011  ;
reg  [26:0]       data102_stp0 ;
wire [25:0]       data10_1213  ;
wire [25:0]       data10_1415  ;
reg  [26:0]       data103_stp0 ;
wire [27:0]       data1001_stp0;
wire [27:0]       data1023_stp0;
reg  [27:0]       data100_stp1  ;
reg  [27:0]       o_data10     ;

reg [24:0]        data1100;
reg [24:0]        data1101;
reg [24:0]        data1102;
reg [24:0]        data1103;
reg [24:0]        data1104;
reg [24:0]        data1105;
reg [24:0]        data1106;
reg [24:0]        data1107;
reg [24:0]        data1108;
reg [24:0]        data1109;
reg [24:0]        data1110;
reg [24:0]        data1111;
reg [24:0]        data1112;
reg [24:0]        data1113;
reg [24:0]        data1114;
reg [24:0]        data1115;

wire [25:0]       data11_0001  ;
wire [25:0]       data11_0203  ;
reg  [26:0]       data110_stp0 ;
wire [25:0]       data11_0405  ;
wire [25:0]       data11_0607  ;
reg  [26:0]       data111_stp0 ;
wire [25:0]       data11_0809  ;
wire [25:0]       data11_1011  ;
reg  [26:0]       data112_stp0 ;
wire [25:0]       data11_1213  ;
wire [25:0]       data11_1415  ;
reg  [26:0]       data113_stp0 ;
wire [27:0]       data1101_stp0;
wire [27:0]       data1123_stp0;
reg  [27:0]       data110_stp1 ;
reg  [27:0]       o_data11     ;

reg [24:0]        data1200;
reg [24:0]        data1201;
reg [24:0]        data1202;
reg [24:0]        data1203;
reg [24:0]        data1204;
reg [24:0]        data1205;
reg [24:0]        data1206;
reg [24:0]        data1207;
reg [24:0]        data1208;
reg [24:0]        data1209;
reg [24:0]        data1210;
reg [24:0]        data1211;
reg [24:0]        data1212;
reg [24:0]        data1213;
reg [24:0]        data1214;
reg [24:0]        data1215;

wire [25:0]       data12_0001  ;
wire [25:0]       data12_0203  ;
reg  [26:0]       data120_stp0 ;
wire [25:0]       data12_0405  ;
wire [25:0]       data12_0607  ;
reg  [26:0]       data121_stp0 ;
wire [25:0]       data12_0809  ;
wire [25:0]       data12_1011  ;
reg  [26:0]       data122_stp0 ;
wire [25:0]       data12_1213  ;
wire [25:0]       data12_1415  ;
reg  [26:0]       data123_stp0 ;
wire [27:0]       data1201_stp0;
wire [27:0]       data1223_stp0;
reg  [27:0]       data120_stp1 ;
reg  [27:0]       o_data12     ;

reg [24:0]        data1300;
reg [24:0]        data1301;
reg [24:0]        data1302;
reg [24:0]        data1303;
reg [24:0]        data1304;
reg [24:0]        data1305;
reg [24:0]        data1306;
reg [24:0]        data1307;
reg [24:0]        data1308;
reg [24:0]        data1309;
reg [24:0]        data1310;
reg [24:0]        data1311;
reg [24:0]        data1312;
reg [24:0]        data1313;
reg [24:0]        data1314;
reg [24:0]        data1315;

wire [25:0]       data13_0001  ;
wire [25:0]       data13_0203  ;
reg  [26:0]       data130_stp0 ;
wire [25:0]       data13_0405  ;
wire [25:0]       data13_0607  ;
reg  [26:0]       data131_stp0 ;
wire [25:0]       data13_0809  ;
wire [25:0]       data13_1011  ;
reg  [26:0]       data132_stp0 ;
wire [25:0]       data13_1213  ;
wire [25:0]       data13_1415  ;
reg  [26:0]       data133_stp0 ;
wire [27:0]       data1301_stp0;
wire [27:0]       data1323_stp0;
reg  [27:0]       data130_stp1 ;
reg  [27:0]       o_data13     ;

reg [24:0]        data1400;
reg [24:0]        data1401;
reg [24:0]        data1402;
reg [24:0]        data1403;
reg [24:0]        data1404;
reg [24:0]        data1405;
reg [24:0]        data1406;
reg [24:0]        data1407;
reg [24:0]        data1408;
reg [24:0]        data1409;
reg [24:0]        data1410;
reg [24:0]        data1411;
reg [24:0]        data1412;
reg [24:0]        data1413;
reg [24:0]        data1414;
reg [24:0]        data1415;

wire [25:0]       data14_0001  ;
wire [25:0]       data14_0203  ;
reg  [26:0]       data140_stp0 ;
wire [25:0]       data14_0405  ;
wire [25:0]       data14_0607  ;
reg  [26:0]       data141_stp0 ;
wire [25:0]       data14_0809  ;
wire [25:0]       data14_1011  ;
reg  [26:0]       data142_stp0 ;
wire [25:0]       data14_1213  ;
wire [25:0]       data14_1415  ;
reg  [26:0]       data143_stp0 ;
wire [27:0]       data1401_stp0;
wire [27:0]       data1423_stp0;
reg  [27:0]       data140_stp1 ;
reg  [27:0]       o_data14     ;

reg [24:0]        data1500;
reg [24:0]        data1501;
reg [24:0]        data1502;
reg [24:0]        data1503;
reg [24:0]        data1504;
reg [24:0]        data1505;
reg [24:0]        data1506;
reg [24:0]        data1507;
reg [24:0]        data1508;
reg [24:0]        data1509;
reg [24:0]        data1510;
reg [24:0]        data1511;
reg [24:0]        data1512;
reg [24:0]        data1513;
reg [24:0]        data1514;
reg [24:0]        data1515;

wire [25:0]       data15_0001  ;
wire [25:0]       data15_0203  ;
reg  [26:0]       data150_stp0 ;
wire [25:0]       data15_0405  ;
wire [25:0]       data15_0607  ;
reg  [26:0]       data151_stp0 ;
wire [25:0]       data15_0809  ;
wire [25:0]       data15_1011  ;
reg  [26:0]       data152_stp0 ;
wire [25:0]       data15_1213  ;
wire [25:0]       data15_1415  ;
reg  [26:0]       data153_stp0 ;
wire [27:0]       data1501_stp0;
wire [27:0]       data1523_stp0;
reg  [27:0]       data150_stp1 ;
reg  [27:0]       o_data15     ;

//--------------------------------------------------------------------------------------------//
wire [24:0]        data00_r16_4     ;     
wire [24:0]        data00_r16_13    ;
wire [24:0]        data00_r16_22    ;
wire [24:0]        data00_r16_31    ;
wire [24:0]        data00_r16_38    ;
wire [24:0]        data00_r16_46    ;
wire [24:0]        data00_r16_54    ;
wire [24:0]        data00_r16_61    ;
wire [24:0]        data00_r16_67    ;
wire [24:0]        data00_r16_73    ;
wire [24:0]        data00_r16_78    ;
wire [24:0]        data00_r16_82    ;
wire [24:0]        data00_r16_85    ;
wire [24:0]        data00_r16_88    ;
wire [24:0]        data00_r16_90    ;
//
wire [24:0]        data00_r8_9      ;
wire [24:0]        data00_r8_25     ;
wire [24:0]        data00_r8_43     ;
wire [24:0]        data00_r8_57     ;
wire [24:0]        data00_r8_70     ;
wire [24:0]        data00_r8_80     ;
wire [24:0]        data00_r8_87     ;
wire [24:0]        data00_r8_90     ;
//
wire [24:0]        data00_r4_18     ;
wire [24:0]        data00_r4_50     ;
wire [24:0]        data00_r4_75     ;
wire [24:0]        data00_r4_89     ;
//
wire [24:0]        data00_a4_64     ;
wire [24:0]        data00_a4_36     ;
wire [24:0]        data00_a4_83     ;
//
wire [24:0]        data00_s4_29     ;
wire [24:0]        data00_s4_55     ;
wire [24:0]        data00_s4_74     ;
wire [24:0]        data00_s4_84     ;
//-------------------------col1--------------------//
wire [24:0]        data01_r16_4     ;     
wire [24:0]        data01_r16_13    ;
wire [24:0]        data01_r16_22    ;
wire [24:0]        data01_r16_31    ;
wire [24:0]        data01_r16_38    ;
wire [24:0]        data01_r16_46    ;
wire [24:0]        data01_r16_54    ;
wire [24:0]        data01_r16_61    ;
wire [24:0]        data01_r16_67    ;
wire [24:0]        data01_r16_73    ;
wire [24:0]        data01_r16_78    ;
wire [24:0]        data01_r16_82    ;
wire [24:0]        data01_r16_85    ;
wire [24:0]        data01_r16_88    ;
wire [24:0]        data01_r16_90    ;
//
wire [24:0]        data01_r8_9      ;
wire [24:0]        data01_r8_25     ;
wire [24:0]        data01_r8_43     ;
wire [24:0]        data01_r8_57     ;
wire [24:0]        data01_r8_70     ;
wire [24:0]        data01_r8_80     ;
wire [24:0]        data01_r8_87     ;
wire [24:0]        data01_r8_90     ;
//
wire [24:0]        data01_r4_18     ;
wire [24:0]        data01_r4_50     ;
wire [24:0]        data01_r4_75     ;
wire [24:0]        data01_r4_89     ;
//
wire [24:0]        data01_a4_64     ;
wire [24:0]        data01_a4_36     ;
wire [24:0]        data01_a4_83     ;
//
wire [24:0]        data01_s4_29     ;
wire [24:0]        data01_s4_55     ;
wire [24:0]        data01_s4_74     ;
wire [24:0]        data01_s4_84     ;

//-------------------------col2--------------------//
wire [24:0]        data02_r16_4     ;     
wire [24:0]        data02_r16_13    ;
wire [24:0]        data02_r16_22    ;
wire [24:0]        data02_r16_31    ;
wire [24:0]        data02_r16_38    ;
wire [24:0]        data02_r16_46    ;
wire [24:0]        data02_r16_54    ;
wire [24:0]        data02_r16_61    ;
wire [24:0]        data02_r16_67    ;
wire [24:0]        data02_r16_73    ;
wire [24:0]        data02_r16_78    ;
wire [24:0]        data02_r16_82    ;
wire [24:0]        data02_r16_85    ;
wire [24:0]        data02_r16_88    ;
wire [24:0]        data02_r16_90    ;
//
wire [24:0]        data02_r8_9      ;
wire [24:0]        data02_r8_25     ;
wire [24:0]        data02_r8_43     ;
wire [24:0]        data02_r8_57     ;
wire [24:0]        data02_r8_70     ;
wire [24:0]        data02_r8_80     ;
wire [24:0]        data02_r8_87     ;
wire [24:0]        data02_r8_90     ;
//
wire [24:0]        data02_r4_18     ;
wire [24:0]        data02_r4_50     ;
wire [24:0]        data02_r4_75     ;
wire [24:0]        data02_r4_89     ;
//
wire [24:0]        data02_a4_64     ;
wire [24:0]        data02_a4_36     ;
wire [24:0]        data02_a4_83     ;
//
wire [24:0]        data02_s4_29     ;
wire [24:0]        data02_s4_55     ;
wire [24:0]        data02_s4_74     ;
wire [24:0]        data02_s4_84     ;

//-------------------------col3--------------------//
wire [24:0]        data03_r16_4     ;     
wire [24:0]        data03_r16_13    ;
wire [24:0]        data03_r16_22    ;
wire [24:0]        data03_r16_31    ;
wire [24:0]        data03_r16_38    ;
wire [24:0]        data03_r16_46    ;
wire [24:0]        data03_r16_54    ;
wire [24:0]        data03_r16_61    ;
wire [24:0]        data03_r16_67    ;
wire [24:0]        data03_r16_73    ;
wire [24:0]        data03_r16_78    ;
wire [24:0]        data03_r16_82    ;
wire [24:0]        data03_r16_85    ;
wire [24:0]        data03_r16_88    ;
wire [24:0]        data03_r16_90    ;
//
wire [24:0]        data03_r8_9      ;
wire [24:0]        data03_r8_25     ;
wire [24:0]        data03_r8_43     ;
wire [24:0]        data03_r8_57     ;
wire [24:0]        data03_r8_70     ;
wire [24:0]        data03_r8_80     ;
wire [24:0]        data03_r8_87     ;
wire [24:0]        data03_r8_90     ;
//
wire [24:0]        data03_r4_18     ;
wire [24:0]        data03_r4_50     ;
wire [24:0]        data03_r4_75     ;
wire [24:0]        data03_r4_89     ;
//
wire [24:0]        data03_a4_64     ;
wire [24:0]        data03_a4_36     ;
wire [24:0]        data03_a4_83     ;
//
wire [24:0]        data03_s4_29     ;
wire [24:0]        data03_s4_55     ;
wire [24:0]        data03_s4_74     ;
wire [24:0]        data03_s4_84     ;

//-------------------------col4--------------------//
wire [24:0]        data04_r16_4     ;     
wire [24:0]        data04_r16_13    ;
wire [24:0]        data04_r16_22    ;
wire [24:0]        data04_r16_31    ;
wire [24:0]        data04_r16_38    ;
wire [24:0]        data04_r16_46    ;
wire [24:0]        data04_r16_54    ;
wire [24:0]        data04_r16_61    ;
wire [24:0]        data04_r16_67    ;
wire [24:0]        data04_r16_73    ;
wire [24:0]        data04_r16_78    ;
wire [24:0]        data04_r16_82    ;
wire [24:0]        data04_r16_85    ;
wire [24:0]        data04_r16_88    ;
wire [24:0]        data04_r16_90    ;
//
wire [24:0]        data04_r8_9      ;
wire [24:0]        data04_r8_25     ;
wire [24:0]        data04_r8_43     ;
wire [24:0]        data04_r8_57     ;
wire [24:0]        data04_r8_70     ;
wire [24:0]        data04_r8_80     ;
wire [24:0]        data04_r8_87     ;
wire [24:0]        data04_r8_90     ;
//
wire [24:0]        data04_r4_18     ;
wire [24:0]        data04_r4_50     ;
wire [24:0]        data04_r4_75     ;
wire [24:0]        data04_r4_89     ;
//
wire [24:0]        data04_a4_64     ;
wire [24:0]        data04_a4_36     ;
wire [24:0]        data04_a4_83     ;
//
wire [24:0]        data04_s4_29     ;
wire [24:0]        data04_s4_55     ;
wire [24:0]        data04_s4_74     ;
wire [24:0]        data04_s4_84     ;
//-------------------------col5--------------------//
wire [24:0]        data05_r16_4     ;     
wire [24:0]        data05_r16_13    ;
wire [24:0]        data05_r16_22    ;
wire [24:0]        data05_r16_31    ;
wire [24:0]        data05_r16_38    ;
wire [24:0]        data05_r16_46    ;
wire [24:0]        data05_r16_54    ;
wire [24:0]        data05_r16_61    ;
wire [24:0]        data05_r16_67    ;
wire [24:0]        data05_r16_73    ;
wire [24:0]        data05_r16_78    ;
wire [24:0]        data05_r16_82    ;
wire [24:0]        data05_r16_85    ;
wire [24:0]        data05_r16_88    ;
wire [24:0]        data05_r16_90    ;
//
wire [24:0]        data05_r8_9      ;
wire [24:0]        data05_r8_25     ;
wire [24:0]        data05_r8_43     ;
wire [24:0]        data05_r8_57     ;
wire [24:0]        data05_r8_70     ;
wire [24:0]        data05_r8_80     ;
wire [24:0]        data05_r8_87     ;
wire [24:0]        data05_r8_90     ;
//
wire [24:0]        data05_r4_18     ;
wire [24:0]        data05_r4_50     ;
wire [24:0]        data05_r4_75     ;
wire [24:0]        data05_r4_89     ;
//
wire [24:0]        data05_a4_64     ;
wire [24:0]        data05_a4_36     ;
wire [24:0]        data05_a4_83     ;
//
wire [24:0]        data05_s4_29     ;
wire [24:0]        data05_s4_55     ;
wire [24:0]        data05_s4_74     ;
wire [24:0]        data05_s4_84     ;
//-------------------------col6--------------------//
wire [24:0]        data06_r16_4     ;     
wire [24:0]        data06_r16_13    ;
wire [24:0]        data06_r16_22    ;
wire [24:0]        data06_r16_31    ;
wire [24:0]        data06_r16_38    ;
wire [24:0]        data06_r16_46    ;
wire [24:0]        data06_r16_54    ;
wire [24:0]        data06_r16_61    ;
wire [24:0]        data06_r16_67    ;
wire [24:0]        data06_r16_73    ;
wire [24:0]        data06_r16_78    ;
wire [24:0]        data06_r16_82    ;
wire [24:0]        data06_r16_85    ;
wire [24:0]        data06_r16_88    ;
wire [24:0]        data06_r16_90    ;
//
wire [24:0]        data06_r8_9      ;
wire [24:0]        data06_r8_25     ;
wire [24:0]        data06_r8_43     ;
wire [24:0]        data06_r8_57     ;
wire [24:0]        data06_r8_70     ;
wire [24:0]        data06_r8_80     ;
wire [24:0]        data06_r8_87     ;
wire [24:0]        data06_r8_90     ;
//
wire [24:0]        data06_r4_18     ;
wire [24:0]        data06_r4_50     ;
wire [24:0]        data06_r4_75     ;
wire [24:0]        data06_r4_89     ;
//
wire [24:0]        data06_a4_64     ;
wire [24:0]        data06_a4_36     ;
wire [24:0]        data06_a4_83     ;
//
wire [24:0]        data06_s4_29     ;
wire [24:0]        data06_s4_55     ;
wire [24:0]        data06_s4_74     ;
wire [24:0]        data06_s4_84     ;
//-------------------------col7--------------------//
wire [24:0]        data07_r16_4     ;     
wire [24:0]        data07_r16_13    ;
wire [24:0]        data07_r16_22    ;
wire [24:0]        data07_r16_31    ;
wire [24:0]        data07_r16_38    ;
wire [24:0]        data07_r16_46    ;
wire [24:0]        data07_r16_54    ;
wire [24:0]        data07_r16_61    ;
wire [24:0]        data07_r16_67    ;
wire [24:0]        data07_r16_73    ;
wire [24:0]        data07_r16_78    ;
wire [24:0]        data07_r16_82    ;
wire [24:0]        data07_r16_85    ;
wire [24:0]        data07_r16_88    ;
wire [24:0]        data07_r16_90    ;
//
wire [24:0]        data07_r8_9      ;
wire [24:0]        data07_r8_25     ;
wire [24:0]        data07_r8_43     ;
wire [24:0]        data07_r8_57     ;
wire [24:0]        data07_r8_70     ;
wire [24:0]        data07_r8_80     ;
wire [24:0]        data07_r8_87     ;
wire [24:0]        data07_r8_90     ;
//
wire [24:0]        data07_r4_18     ;
wire [24:0]        data07_r4_50     ;
wire [24:0]        data07_r4_75     ;
wire [24:0]        data07_r4_89     ;
//
wire [24:0]        data07_a4_64     ;
wire [24:0]        data07_a4_36     ;
wire [24:0]        data07_a4_83     ;
//
wire [24:0]        data07_s4_29     ;
wire [24:0]        data07_s4_55     ;
wire [24:0]        data07_s4_74     ;
wire [24:0]        data07_s4_84     ;
//-------------------------col8--------------------//
wire [24:0]        data08_r16_4     ;     
wire [24:0]        data08_r16_13    ;
wire [24:0]        data08_r16_22    ;
wire [24:0]        data08_r16_31    ;
wire [24:0]        data08_r16_38    ;
wire [24:0]        data08_r16_46    ;
wire [24:0]        data08_r16_54    ;
wire [24:0]        data08_r16_61    ;
wire [24:0]        data08_r16_67    ;
wire [24:0]        data08_r16_73    ;
wire [24:0]        data08_r16_78    ;
wire [24:0]        data08_r16_82    ;
wire [24:0]        data08_r16_85    ;
wire [24:0]        data08_r16_88    ;
wire [24:0]        data08_r16_90    ;
//
wire [24:0]        data08_r8_9      ;
wire [24:0]        data08_r8_25     ;
wire [24:0]        data08_r8_43     ;
wire [24:0]        data08_r8_57     ;
wire [24:0]        data08_r8_70     ;
wire [24:0]        data08_r8_80     ;
wire [24:0]        data08_r8_87     ;
wire [24:0]        data08_r8_90     ;
//
wire [24:0]        data08_r4_18     ;
wire [24:0]        data08_r4_50     ;
wire [24:0]        data08_r4_75     ;
wire [24:0]        data08_r4_89     ;
//
wire [24:0]        data08_a4_64     ;
wire [24:0]        data08_a4_36     ;
wire [24:0]        data08_a4_83     ;
//
wire [24:0]        data08_s4_29     ;
wire [24:0]        data08_s4_55     ;
wire [24:0]        data08_s4_74     ;
wire [24:0]        data08_s4_84     ;
//-------------------------col9--------------------//
wire [24:0]        data09_r16_4     ;     
wire [24:0]        data09_r16_13    ;
wire [24:0]        data09_r16_22    ;
wire [24:0]        data09_r16_31    ;
wire [24:0]        data09_r16_38    ;
wire [24:0]        data09_r16_46    ;
wire [24:0]        data09_r16_54    ;
wire [24:0]        data09_r16_61    ;
wire [24:0]        data09_r16_67    ;
wire [24:0]        data09_r16_73    ;
wire [24:0]        data09_r16_78    ;
wire [24:0]        data09_r16_82    ;
wire [24:0]        data09_r16_85    ;
wire [24:0]        data09_r16_88    ;
wire [24:0]        data09_r16_90    ;
//
wire [24:0]        data09_r8_9      ;
wire [24:0]        data09_r8_25     ;
wire [24:0]        data09_r8_43     ;
wire [24:0]        data09_r8_57     ;
wire [24:0]        data09_r8_70     ;
wire [24:0]        data09_r8_80     ;
wire [24:0]        data09_r8_87     ;
wire [24:0]        data09_r8_90     ;
//
wire [24:0]        data09_r4_18     ;
wire [24:0]        data09_r4_50     ;
wire [24:0]        data09_r4_75     ;
wire [24:0]        data09_r4_89     ;
//
wire [24:0]        data09_a4_64     ;
wire [24:0]        data09_a4_36     ;
wire [24:0]        data09_a4_83     ;
//
wire [24:0]        data09_s4_29     ;
wire [24:0]        data09_s4_55     ;
wire [24:0]        data09_s4_74     ;
wire [24:0]        data09_s4_84     ;
//-------------------------col10--------------------//
wire [24:0]        data10_r16_4     ;     
wire [24:0]        data10_r16_13    ;
wire [24:0]        data10_r16_22    ;
wire [24:0]        data10_r16_31    ;
wire [24:0]        data10_r16_38    ;
wire [24:0]        data10_r16_46    ;
wire [24:0]        data10_r16_54    ;
wire [24:0]        data10_r16_61    ;
wire [24:0]        data10_r16_67    ;
wire [24:0]        data10_r16_73    ;
wire [24:0]        data10_r16_78    ;
wire [24:0]        data10_r16_82    ;
wire [24:0]        data10_r16_85    ;
wire [24:0]        data10_r16_88    ;
wire [24:0]        data10_r16_90    ;
//
wire [24:0]        data10_r8_9      ;
wire [24:0]        data10_r8_25     ;
wire [24:0]        data10_r8_43     ;
wire [24:0]        data10_r8_57     ;
wire [24:0]        data10_r8_70     ;
wire [24:0]        data10_r8_80     ;
wire [24:0]        data10_r8_87     ;
wire [24:0]        data10_r8_90     ;
//
wire [24:0]        data10_r4_18     ;
wire [24:0]        data10_r4_50     ;
wire [24:0]        data10_r4_75     ;
wire [24:0]        data10_r4_89     ;
//
wire [24:0]        data10_a4_64     ;
wire [24:0]        data10_a4_36     ;
wire [24:0]        data10_a4_83     ;
//
wire [24:0]        data10_s4_29     ;
wire [24:0]        data10_s4_55     ;
wire [24:0]        data10_s4_74     ;
wire [24:0]        data10_s4_84     ;
//-------------------------col11--------------------//
wire [24:0]        data11_r16_4     ;     
wire [24:0]        data11_r16_13    ;
wire [24:0]        data11_r16_22    ;
wire [24:0]        data11_r16_31    ;
wire [24:0]        data11_r16_38    ;
wire [24:0]        data11_r16_46    ;
wire [24:0]        data11_r16_54    ;
wire [24:0]        data11_r16_61    ;
wire [24:0]        data11_r16_67    ;
wire [24:0]        data11_r16_73    ;
wire [24:0]        data11_r16_78    ;
wire [24:0]        data11_r16_82    ;
wire [24:0]        data11_r16_85    ;
wire [24:0]        data11_r16_88    ;
wire [24:0]        data11_r16_90    ;
//
wire [24:0]        data11_r8_9      ;
wire [24:0]        data11_r8_25     ;
wire [24:0]        data11_r8_43     ;
wire [24:0]        data11_r8_57     ;
wire [24:0]        data11_r8_70     ;
wire [24:0]        data11_r8_80     ;
wire [24:0]        data11_r8_87     ;
wire [24:0]        data11_r8_90     ;
//
wire [24:0]        data11_r4_18     ;
wire [24:0]        data11_r4_50     ;
wire [24:0]        data11_r4_75     ;
wire [24:0]        data11_r4_89     ;
//
wire [24:0]        data11_a4_64     ;
wire [24:0]        data11_a4_36     ;
wire [24:0]        data11_a4_83     ;
//
wire [24:0]        data11_s4_29     ;
wire [24:0]        data11_s4_55     ;
wire [24:0]        data11_s4_74     ;
wire [24:0]        data11_s4_84     ;
//-------------------------col12--------------------//
wire [24:0]        data12_r16_4     ;     
wire [24:0]        data12_r16_13    ;
wire [24:0]        data12_r16_22    ;
wire [24:0]        data12_r16_31    ;
wire [24:0]        data12_r16_38    ;
wire [24:0]        data12_r16_46    ;
wire [24:0]        data12_r16_54    ;
wire [24:0]        data12_r16_61    ;
wire [24:0]        data12_r16_67    ;
wire [24:0]        data12_r16_73    ;
wire [24:0]        data12_r16_78    ;
wire [24:0]        data12_r16_82    ;
wire [24:0]        data12_r16_85    ;
wire [24:0]        data12_r16_88    ;
wire [24:0]        data12_r16_90    ;
//
wire [24:0]        data12_r8_9      ;
wire [24:0]        data12_r8_25     ;
wire [24:0]        data12_r8_43     ;
wire [24:0]        data12_r8_57     ;
wire [24:0]        data12_r8_70     ;
wire [24:0]        data12_r8_80     ;
wire [24:0]        data12_r8_87     ;
wire [24:0]        data12_r8_90     ;
//
wire [24:0]        data12_r4_18     ;
wire [24:0]        data12_r4_50     ;
wire [24:0]        data12_r4_75     ;
wire [24:0]        data12_r4_89     ;
//
wire [24:0]        data12_a4_64     ;
wire [24:0]        data12_a4_36     ;
wire [24:0]        data12_a4_83     ;
//
wire [24:0]        data12_s4_29     ;
wire [24:0]        data12_s4_55     ;
wire [24:0]        data12_s4_74     ;
wire [24:0]        data12_s4_84     ;
//-------------------------col13--------------------//
wire [24:0]        data13_r16_4     ;     
wire [24:0]        data13_r16_13    ;
wire [24:0]        data13_r16_22    ;
wire [24:0]        data13_r16_31    ;
wire [24:0]        data13_r16_38    ;
wire [24:0]        data13_r16_46    ;
wire [24:0]        data13_r16_54    ;
wire [24:0]        data13_r16_61    ;
wire [24:0]        data13_r16_67    ;
wire [24:0]        data13_r16_73    ;
wire [24:0]        data13_r16_78    ;
wire [24:0]        data13_r16_82    ;
wire [24:0]        data13_r16_85    ;
wire [24:0]        data13_r16_88    ;
wire [24:0]        data13_r16_90    ;
//
wire [24:0]        data13_r8_9      ;
wire [24:0]        data13_r8_25     ;
wire [24:0]        data13_r8_43     ;
wire [24:0]        data13_r8_57     ;
wire [24:0]        data13_r8_70     ;
wire [24:0]        data13_r8_80     ;
wire [24:0]        data13_r8_87     ;
wire [24:0]        data13_r8_90     ;
//
wire [24:0]        data13_r4_18     ;
wire [24:0]        data13_r4_50     ;
wire [24:0]        data13_r4_75     ;
wire [24:0]        data13_r4_89     ;
//
wire [24:0]        data13_a4_64     ;
wire [24:0]        data13_a4_36     ;
wire [24:0]        data13_a4_83     ;
//
wire [24:0]        data13_s4_29     ;
wire [24:0]        data13_s4_55     ;
wire [24:0]        data13_s4_74     ;
wire [24:0]        data13_s4_84     ;
//-------------------------col14--------------------//
wire [24:0]        data14_r16_4     ;     
wire [24:0]        data14_r16_13    ;
wire [24:0]        data14_r16_22    ;
wire [24:0]        data14_r16_31    ;
wire [24:0]        data14_r16_38    ;
wire [24:0]        data14_r16_46    ;
wire [24:0]        data14_r16_54    ;
wire [24:0]        data14_r16_61    ;
wire [24:0]        data14_r16_67    ;
wire [24:0]        data14_r16_73    ;
wire [24:0]        data14_r16_78    ;
wire [24:0]        data14_r16_82    ;
wire [24:0]        data14_r16_85    ;
wire [24:0]        data14_r16_88    ;
wire [24:0]        data14_r16_90    ;
//
wire [24:0]        data14_r8_9      ;
wire [24:0]        data14_r8_25     ;
wire [24:0]        data14_r8_43     ;
wire [24:0]        data14_r8_57     ;
wire [24:0]        data14_r8_70     ;
wire [24:0]        data14_r8_80     ;
wire [24:0]        data14_r8_87     ;
wire [24:0]        data14_r8_90     ;
//
wire [24:0]        data14_r4_18     ;
wire [24:0]        data14_r4_50     ;
wire [24:0]        data14_r4_75     ;
wire [24:0]        data14_r4_89     ;
//
wire [24:0]        data14_a4_64     ;
wire [24:0]        data14_a4_36     ;
wire [24:0]        data14_a4_83     ;
//
wire [24:0]        data14_s4_29     ;
wire [24:0]        data14_s4_55     ;
wire [24:0]        data14_s4_74     ;
wire [24:0]        data14_s4_84     ;
//-------------------------col15--------------------//
wire [24:0]        data15_r16_4     ;     
wire [24:0]        data15_r16_13    ;
wire [24:0]        data15_r16_22    ;
wire [24:0]        data15_r16_31    ;
wire [24:0]        data15_r16_38    ;
wire [24:0]        data15_r16_46    ;
wire [24:0]        data15_r16_54    ;
wire [24:0]        data15_r16_61    ;
wire [24:0]        data15_r16_67    ;
wire [24:0]        data15_r16_73    ;
wire [24:0]        data15_r16_78    ;
wire [24:0]        data15_r16_82    ;
wire [24:0]        data15_r16_85    ;
wire [24:0]        data15_r16_88    ;
wire [24:0]        data15_r16_90    ;
//
wire [24:0]        data15_r8_9      ;
wire [24:0]        data15_r8_25     ;
wire [24:0]        data15_r8_43     ;
wire [24:0]        data15_r8_57     ;
wire [24:0]        data15_r8_70     ;
wire [24:0]        data15_r8_80     ;
wire [24:0]        data15_r8_87     ;
wire [24:0]        data15_r8_90     ;
//
wire [24:0]        data15_r4_18     ;
wire [24:0]        data15_r4_50     ;
wire [24:0]        data15_r4_75     ;
wire [24:0]        data15_r4_89     ;
//
wire [24:0]        data15_a4_64     ;
wire [24:0]        data15_a4_36     ;
wire [24:0]        data15_a4_83     ;
//
wire [24:0]        data15_s4_29     ;
wire [24:0]        data15_s4_55     ;
wire [24:0]        data15_s4_74     ;
wire [24:0]        data15_s4_84     ;

//-------------------------------------------------------------delay
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		dt_vld_32_d <= 1'd0;
	else	
		dt_vld_32_d <= i_dt_vld_32;	
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		dt_vld_16_d <= 1'd0;
	else	
		dt_vld_16_d <= i_dt_vld_16;	
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		dt_vld_8_d <= 2'd0;
	else	
		dt_vld_8_d <= {dt_vld_8_d[0],i_dt_vld_8};	
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		dt_vld_4_d <= 2'd0;
	else	
		dt_vld_4_d <= {dt_vld_4_d[0],i_dt_vld_4};	
end 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		dt_vld_dst_d <= 2'd0;
	else	
		dt_vld_dst_d <= {dt_vld_dst_d[0],i_dt_vld_dst};	
end 
//----------o_data0----------------//
always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data0000 =  data00_r16_4 ;
			data0001 =  data01_r16_13;
			data0002 =  data02_r16_22;
			data0003 =  data03_r16_31;
			data0004 =  data04_r16_38;
			data0005 =  data05_r16_46;
			data0006 =  data06_r16_54;
			data0007 =  data07_r16_61;
			data0008 =  data08_r16_67;
			data0009 =  data09_r16_73;
			data0010 =  data10_r16_78;
			data0011 =  data11_r16_82;
			data0012 =  data12_r16_85;
			data0013 =  data13_r16_88;
			data0014 =  data14_r16_90;
			data0015 =  data15_r16_90;
		end
	else if(dt_vld_16_d)
		begin
			data0000 =  data00_r8_9 ;
			data0001 =  data01_r8_25;
			data0002 =  data02_r8_43;
			data0003 =  data03_r8_57;
			data0004 =  data04_r8_70;
			data0005 =  data05_r8_80;
			data0006 =  data06_r8_87;
			data0007 =  data07_r8_90;
                        data0008 =  25'd0;  
                        data0009 =  25'd0;
                        data0010 =  25'd0;
                        data0011 =  25'd0;
                        data0012 =  25'd0;
                        data0013 =  25'd0;
                        data0014 =  25'd0;
                        data0015 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0000 =  data00_r4_18;
			data0001 =  data01_r4_50;
			data0002 =  data02_r4_75;
			data0003 =  data03_r4_89;
                        data0004 =  25'd0;         
                        data0005 =  25'd0;
                        data0006 =  25'd0;
                        data0007 =  25'd0;
                        data0008 =  25'd0; 
                        data0009 =  25'd0;
                        data0010 =  25'd0;
                        data0011 =  25'd0;
                        data0012 =  25'd0;
                        data0013 =  25'd0;
                        data0014 =  25'd0;
                        data0015 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data0000 =  data00_a4_64;
			data0001 =  data01_a4_64;
			data0002 =  data02_a4_64;
			data0003 =  data03_a4_64;
			data0004 =  25'd0;
			data0005 =  25'd0;
			data0006 =  25'd0;
			data0007 =  25'd0;
			data0008 =  25'd0;
			data0009 =  25'd0;
			data0010 =  25'd0;
			data0011 =  25'd0;
			data0012 =  25'd0;
			data0013 =  25'd0;
			data0014 =  25'd0;
			data0015 =  25'd0;
	end	
	else
		begin
			data0000 =  data00_s4_29;
			data0001 =  data01_s4_55;
			data0002 =  data02_s4_74;
			data0003 =  data03_s4_84;
			data0004 =  25'd0;
			data0005 =  25'd0;
			data0006 =  25'd0;
			data0007 =  25'd0;
			data0008 =  25'd0;
			data0009 =  25'd0;
			data0010 =  25'd0;
			data0011 =  25'd0;
			data0012 =  25'd0;
			data0013 =  25'd0;
			data0014 =  25'd0;
			data0015 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data0000 =  data00_r16_4 ;
			data0001 =  ~data01_r16_13 + 1'b1;
			data0002 =  data02_r16_22;
			data0003 =  ~data03_r16_31 + 1'b1;
			data0004 =  data04_r16_38;
			data0005 =  ~data05_r16_46 + 1'b1;
			data0006 =  data06_r16_54;
			data0007 =  ~data07_r16_61 + 1'b1;
			data0008 =  data08_r16_67;
			data0009 =  ~data09_r16_73 + 1'b1;
			data0010 =  data10_r16_78;
			data0011 =  ~data11_r16_82 + 1'b1;
			data0012 =  data12_r16_85;
			data0013 =  ~data13_r16_88 + 1'b1;
			data0014 =  data14_r16_90;
			data0015 =  ~data15_r16_90 + 1'b1;
		end
	else if(dt_vld_16_d)
		begin
			data0000 =  data00_r8_9 ;
			data0001 =  ~data01_r8_25 + 1'b1;
			data0002 =  data02_r8_43;
			data0003 =  ~data03_r8_57 + 1'b1;
			data0004 =  data04_r8_70;
			data0005 =  ~data05_r8_80 + 1'b1;
			data0006 =  data06_r8_87;
			data0007 =  ~data07_r8_90 + 1'b1;
                        data0008 =  25'd0;  
                        data0009 =  25'd0;
                        data0010 =  25'd0;
                        data0011 =  25'd0;
                        data0012 =  25'd0;
                        data0013 =  25'd0;
                        data0014 =  25'd0;
                        data0015 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0000 =  data00_r4_18;
			data0001 =  ~data01_r4_50 + 1'b1;
			data0002 =  data02_r4_75;
			data0003 =  ~data03_r4_89 + 1'b1;
                        data0004 =  25'd0;         
                        data0005 =  25'd0;
                        data0006 =  25'd0;
                        data0007 =  25'd0;
                        data0008 =  25'd0; 
                        data0009 =  25'd0;
                        data0010 =  25'd0;
                        data0011 =  25'd0;
                        data0012 =  25'd0;
                        data0013 =  25'd0;
                        data0014 =  25'd0;
                        data0015 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data0000 =  data00_a4_64;
			data0001 =  data01_a4_83;
			data0002 =  data02_a4_64;
			data0003 =  data03_a4_36;
			data0004 =  25'd0;
			data0005 =  25'd0;
			data0006 =  25'd0;
			data0007 =  25'd0;
			data0008 =  25'd0;
			data0009 =  25'd0;
			data0010 =  25'd0;
			data0011 =  25'd0;
			data0012 =  25'd0;
			data0013 =  25'd0;
			data0014 =  25'd0;
			data0015 =  25'd0;
	end	
	else
		begin
			data0000 =  data00_s4_29;
			data0001 =  data01_s4_74;
			data0002 =  data02_s4_84;
			data0003 =  data03_s4_55;
			data0004 =  25'd0;
			data0005 =  25'd0;
			data0006 =  25'd0;
			data0007 =  25'd0;
			data0008 =  25'd0;
			data0009 =  25'd0;
			data0010 =  25'd0;
			data0011 =  25'd0;
			data0012 =  25'd0;
			data0013 =  25'd0;
			data0014 =  25'd0;
			data0015 =  25'd0;
		end
	end
end 



assign data00_0001 = {data0000[24],data0000} + {data0001[24],data0001};
assign data00_0203 = {data0002[24],data0002} + {data0003[24],data0003};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data000_stp0 <= 27'd0;
	else
		data000_stp0 <= {data00_0001[25],data00_0001} + {data00_0203[25],data00_0203};
end 

assign data00_0405 = {data0004[24],data0004} + {data0005[24],data0005};
assign data00_0607 = {data0006[24],data0006} + {data0007[24],data0007};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data001_stp0 <= 27'd0;
	else
		data001_stp0 <= {data00_0405[25],data00_0405} + {data00_0607[25],data00_0607};
end 

assign data00_0809 = {data0008[24],data0008} + {data0009[24],data0009};
assign data00_1011 = {data0010[24],data0010} + {data0011[24],data0011};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data002_stp0 <= 27'd0;
	else
		data002_stp0 <= {data00_0809[25],data00_0809} + {data00_1011[25],data00_1011};
end 

assign data00_1213 = {data0012[24],data0012} + {data0013[24],data0013};
assign data00_1415 = {data0014[24],data0014} + {data0015[24],data0015};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data003_stp0 <= 27'd0;
	else
		data003_stp0 <= {data00_1213[25],data00_1213} + {data00_1415[25],data00_1415};
end
 
assign data0001_stp0 = {data000_stp0[26],data000_stp0} + {data001_stp0[26],data001_stp0};
assign data0023_stp0 = {data002_stp0[26],data002_stp0} + {data003_stp0[26],data003_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data000_stp1 <= 28'd0;
	else
		data000_stp1 <= data0001_stp0 + data0023_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data0 = {data000_stp0[26],data000_stp0};
	else 
		o_data0 = data000_stp1;
end 

//------------------------------------------o_data1--------------------------------------------------------//
always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data0100 =  ~data00_r16_13 + 1'b1;
			data0101 =  ~data01_r16_38 + 1'b1;
			data0102 =  ~data02_r16_61 + 1'b1;
			data0103 =  ~data03_r16_78 + 1'b1;
			data0104 =  ~data04_r16_88 + 1'b1;
			data0105 =  ~data05_r16_90 + 1'b1;
			data0106 =  ~data06_r16_85 + 1'b1;
			data0107 =  ~data07_r16_73 + 1'b1;
			data0108 =  ~data08_r16_54 + 1'b1;
			data0109 =  ~data09_r16_31 + 1'b1;
			data0110 =  ~data10_r16_4 + 1'b1;
			data0111 =  data11_r16_22;
			data0112 =  data12_r16_46;
			data0113 =  data13_r16_67;
			data0114 =  data14_r16_82;
			data0115 =  data15_r16_90;
		end
	else if(dt_vld_16_d)
		begin
			data0100 =  ~data00_r8_25 + 1'b1 ;
			data0101 =  ~data01_r8_70 + 1'b1;
			data0102 =  ~data02_r8_90 + 1'b1;
			data0103 =  ~data03_r8_80 + 1'b1;
			data0104 =  ~data04_r8_43 + 1'b1;
			data0105 =  data05_r8_9 ;
			data0106 =  data06_r8_57;
			data0107 =  data07_r8_87;
                        data0108 =  25'd0;  
                        data0109 =  25'd0;
                        data0110 =  25'd0;
                        data0111 =  25'd0;
                        data0112 =  25'd0;
                        data0113 =  25'd0;
                        data0114 =  25'd0;
                        data0115 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0100 =  ~data00_r4_50 + 1'b1;
			data0101 =  ~data01_r4_89 + 1'b1;
			data0102 =  ~data02_r4_18 + 1'b1;
			data0103 =  data03_r4_75;
                        data0104 =  25'd0;         
                        data0105 =  25'd0;
                        data0106 =  25'd0;
                        data0107 =  25'd0;
                        data0108 =  25'd0; 
                        data0109 =  25'd0;
                        data0110 =  25'd0;
                        data0111 =  25'd0;
                        data0112 =  25'd0;
                        data0113 =  25'd0;
                        data0114 =  25'd0;
                        data0115 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data0100 =  data00_a4_83;
			data0101 =  data01_a4_36;
			data0102 =  ~data02_a4_36 + 1'b1;
			data0103 =  ~data03_a4_83 + 1'b1;
			data0104 =  25'd0;
			data0105 =  25'd0;
			data0106 =  25'd0;
			data0107 =  25'd0;
			data0108 =  25'd0;
			data0109 =  25'd0;
			data0110 =  25'd0;
			data0111 =  25'd0;
			data0112 =  25'd0;
			data0113 =  25'd0;
			data0114 =  25'd0;
			data0115 =  25'd0;
	end	
	else
		begin
			data0100 =  data00_s4_74;
			data0101 =  data01_s4_74;
			data0102 =  25'd0;
			data0103 =  ~data03_s4_74 + 1'b1;
			data0104 =  25'd0;
			data0105 =  25'd0;
			data0106 =  25'd0;
			data0107 =  25'd0;
			data0108 =  25'd0;
			data0109 =  25'd0;
			data0110 =  25'd0;
			data0111 =  25'd0;
			data0112 =  25'd0;
			data0113 =  25'd0;
			data0114 =  25'd0;
			data0115 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data0100 =  data00_r16_13;
			data0101 =  ~data01_r16_38 + 1'b1;
			data0102 =  data02_r16_61;
			data0103 =  ~data03_r16_78 + 1'b1;
			data0104 =  data04_r16_88;
			data0105 =  ~data05_r16_90 + 1'b1;
			data0106 =  data06_r16_85;
			data0107 =  ~data07_r16_73 + 1'b1;
			data0108 =  data08_r16_54;
			data0109 =  ~data09_r16_31 + 1'b1;
			data0110 =  data10_r16_4;
			data0111 =  data11_r16_22;
			data0112 =  ~data12_r16_46 + 1'b1;
			data0113 =  data13_r16_67;
			data0114 =  ~data14_r16_82 + 1'b1;
			data0115 =  data15_r16_90;
		end
	else if(dt_vld_16_d)
		begin
			data0100 =  data00_r8_25 ;
			data0101 =  ~data01_r8_70 + 1'b1;
			data0102 =  data02_r8_90;
			data0103 =  ~data03_r8_80 + 1'b1;
			data0104 =  data04_r8_43;
			data0105 =  data05_r8_9;
			data0106 =  ~data06_r8_57 + 1'b1;
			data0107 =  data07_r8_87;
                        data0108 =  25'd0;  
                        data0109 =  25'd0;
                        data0110 =  25'd0;
                        data0111 =  25'd0;
                        data0112 =  25'd0;
                        data0113 =  25'd0;
                        data0114 =  25'd0;
                        data0115 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0100 =  data00_r4_50;
			data0101 =  ~data01_r4_89 + 1'b1;
			data0102 =  data02_r4_18;
			data0103 =  data03_r4_75;
                        data0104 =  25'd0;         
                        data0105 =  25'd0;
                        data0106 =  25'd0;
                        data0107 =  25'd0;
                        data0108 =  25'd0; 
                        data0109 =  25'd0;
                        data0110 =  25'd0;
                        data0111 =  25'd0;
                        data0112 =  25'd0;
                        data0113 =  25'd0;
                        data0114 =  25'd0;
                        data0115 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data0100 =  data00_a4_64;
			data0101 =  data01_a4_36;
			data0102 =  ~data02_a4_64 + 1'b1;
			data0103 =  ~data03_a4_83 + 1'b1;
			data0104 =  25'd0;
			data0105 =  25'd0;
			data0106 =  25'd0;
			data0107 =  25'd0;
			data0108 =  25'd0;
			data0109 =  25'd0;
			data0110 =  25'd0;
			data0111 =  25'd0;
			data0112 =  25'd0;
			data0113 =  25'd0;
			data0114 =  25'd0;
			data0115 =  25'd0;
	end	
	else
		begin
			data0100 =  data00_s4_55;
			data0101 =  data01_s4_74;
			data0102 =  ~data02_s4_29 + 1'b1;
			data0103 =  ~data03_s4_84 + 1'b1;
			data0104 =  25'd0;
			data0105 =  25'd0;
			data0106 =  25'd0;
			data0107 =  25'd0;
			data0108 =  25'd0;
			data0109 =  25'd0;
			data0110 =  25'd0;
			data0111 =  25'd0;
			data0112 =  25'd0;
			data0113 =  25'd0;
			data0114 =  25'd0;
			data0115 =  25'd0;
		end
	end
end 

assign data01_0001 = {data0100[24],data0100} + {data0101[24],data0101};
assign data01_0203 = {data0102[24],data0102} + {data0103[24],data0103};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data010_stp0 <= 27'd0;
	else
		data010_stp0 <= {data01_0001[25],data01_0001} + {data01_0203[25],data01_0203};
end 

assign data01_0405 = {data0104[24],data0104} + {data0105[24],data0105};
assign data01_0607 = {data0106[24],data0106} + {data0107[24],data0107};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data011_stp0 <= 27'd0;
	else
		data011_stp0 <= {data01_0405[25],data01_0405} + {data01_0607[25],data01_0607};
end 

assign data01_0809 = {data0108[24],data0108} + {data0109[24],data0109};
assign data01_1011 = {data0110[24],data0110} + {data0111[24],data0111};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data012_stp0 <= 27'd0;
	else
		data012_stp0 <= {data01_0809[25],data01_0809} + {data01_1011[25],data01_1011};
end 

assign data01_1213 = {data0112[24],data0112} + {data0113[24],data0113};
assign data01_1415 = {data0114[24],data0114} + {data0115[24],data0115};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data013_stp0 <= 27'd0;
	else
		data013_stp0 <= {data01_1213[25],data01_1213} + {data01_1415[25],data01_1415};
end
 
assign data0101_stp0 = {data010_stp0[26],data010_stp0} + {data011_stp0[26],data011_stp0};
assign data0123_stp0 = {data012_stp0[26],data012_stp0} + {data013_stp0[26],data013_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data010_stp1 <= 28'd0;
	else
		data010_stp1 <= data0101_stp0 + data0123_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data1 = {data010_stp0[26],data010_stp0};
	else 
		o_data1 = data010_stp1;
end 

//------------------------------------------o_data2--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data0200 =  data00_r16_22;
			data0201 =  data01_r16_61;
			data0202 =  data02_r16_85;
			data0203 =  data03_r16_90;
			data0204 =  data04_r16_73;
			data0205 =  data05_r16_38;
			data0206 =  ~data06_r16_4 + 1'b1;
			data0207 =  ~data07_r16_46 + 1'b1;
			data0208 =  ~data08_r16_78 + 1'b1;
			data0209 =  ~data09_r16_90 + 1'b1;
			data0210 =  ~data10_r16_82 + 1'b1;
			data0211 =  ~data11_r16_54 + 1'b1;
			data0212 =  ~data12_r16_13 + 1'b1;
			data0213 =  data13_r16_31;
			data0214 =  data14_r16_67;
			data0215 =  data15_r16_88;
		end
	else if(dt_vld_16_d)
		begin
			data0200 =  data00_r8_43;
			data0201 =  data01_r8_90;
			data0202 =  data02_r8_57;
			data0203 =  ~data03_r8_25 + 1'b1;
			data0204 =  ~data04_r8_87 + 1'b1;
			data0205 =  ~data05_r8_70 + 1'b1 ;
			data0206 =  data06_r8_9;
			data0207 =  data07_r8_80;
                        data0208 =  25'd0;  
                        data0209 =  25'd0;
                        data0210 =  25'd0;
                        data0211 =  25'd0;
                        data0212 =  25'd0;
                        data0213 =  25'd0;
                        data0214 =  25'd0;
                        data0215 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0200 =  data00_r4_75;
			data0201 =  data01_r4_18;
			data0202 =  ~data02_r4_89 + 1'b1;
			data0203 =  data03_r4_50;
                        data0204 =  25'd0;         
                        data0205 =  25'd0;
                        data0206 =  25'd0;
                        data0207 =  25'd0;
                        data0208 =  25'd0; 
                        data0209 =  25'd0;
                        data0210 =  25'd0;
                        data0211 =  25'd0;
                        data0212 =  25'd0;
                        data0213 =  25'd0;
                        data0214 =  25'd0;
                        data0215 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data0200 =  data00_a4_64;
			data0201 =  ~data01_a4_64 + 1'b1;
			data0202 =  ~data02_a4_64 + 1'b1;
			data0203 =  data03_a4_64;
			data0204 =  25'd0;
			data0205 =  25'd0;
			data0206 =  25'd0;
			data0207 =  25'd0;
			data0208 =  25'd0;
			data0209 =  25'd0;
			data0210 =  25'd0;
			data0211 =  25'd0;
			data0212 =  25'd0;
			data0213 =  25'd0;
			data0214 =  25'd0;
			data0215 =  25'd0;
	end	
	else
		begin
			data0200 =  data00_s4_84;
			data0201 =  ~data01_s4_29 + 1'b1;
			data0202 =  ~data02_s4_74 + 1'b1;
			data0203 =  data03_s4_55;
			data0204 =  25'd0;
			data0205 =  25'd0;
			data0206 =  25'd0;
			data0207 =  25'd0;
			data0208 =  25'd0;
			data0209 =  25'd0;
			data0210 =  25'd0;
			data0211 =  25'd0;
			data0212 =  25'd0;
			data0213 =  25'd0;
			data0214 =  25'd0;
			data0215 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data0200 =  data00_r16_22;
			data0201 =  ~data01_r16_61 + 1'b1;
			data0202 =  data02_r16_85;
			data0203 =  ~data03_r16_90 + 1'b1;
			data0204 =  data04_r16_73;
			data0205 =  ~data05_r16_38 + 1'b1;
			data0206 =  ~data06_r16_4 + 1'b1;
			data0207 =  data07_r16_46;
			data0208 =  ~data08_r16_78 + 1'b1;
			data0209 =  data09_r16_90;
			data0210 =  ~data10_r16_82 + 1'b1;
			data0211 =  data11_r16_54;
			data0212 =  ~data12_r16_13 + 1'b1;
			data0213 =  ~data13_r16_31 + 1'b1;
			data0214 =  data14_r16_67;
			data0215 =  ~data15_r16_88 + 1'b1;
		end
	else if(dt_vld_16_d)
		begin
			data0200 =  data00_r8_43 ;
			data0201 =  ~data01_r8_90 + 1'b1;
			data0202 =  data02_r8_57;
			data0203 =  data03_r8_25;
			data0204 =  ~data04_r8_87 + 1'b1;
			data0205 =  data05_r8_70;
			data0206 =  data06_r8_9;
			data0207 =  ~data07_r8_80 + 1'b1;
                        data0208 =  25'd0;  
                        data0209 =  25'd0;
                        data0210 =  25'd0;
                        data0211 =  25'd0;
                        data0212 =  25'd0;
                        data0213 =  25'd0;
                        data0214 =  25'd0;
                        data0215 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0200 =  data00_r4_75;
			data0201 =  ~data01_r4_18 + 1'b1;
			data0202 =  ~data02_r4_89 + 1'b1;
			data0203 =  ~data03_r4_50 + 1'b1;
                        data0204 =  25'd0;         
                        data0205 =  25'd0;
                        data0206 =  25'd0;
                        data0207 =  25'd0;
                        data0208 =  25'd0; 
                        data0209 =  25'd0;
                        data0210 =  25'd0;
                        data0211 =  25'd0;
                        data0212 =  25'd0;
                        data0213 =  25'd0;
                        data0214 =  25'd0;
                        data0215 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data0200 =  data00_a4_64;
			data0201 =  ~data01_a4_36 + 1'b1;
			data0202 =  ~data02_a4_64 + 1'b1;
			data0203 =  data03_a4_83;
			data0204 =  25'd0;
			data0205 =  25'd0;
			data0206 =  25'd0;
			data0207 =  25'd0;
			data0208 =  25'd0;
			data0209 =  25'd0;
			data0210 =  25'd0;
			data0211 =  25'd0;
			data0212 =  25'd0;
			data0213 =  25'd0;
			data0214 =  25'd0;
			data0215 =  25'd0;
	end	
	else
		begin
			data0200 =  data00_s4_74;
			data0201 =  25'd0;
			data0202 =  ~data02_s4_74 + 1'b1;
			data0203 =  data03_s4_74;
			data0204 =  25'd0;
			data0205 =  25'd0;
			data0206 =  25'd0;
			data0207 =  25'd0;
			data0208 =  25'd0;
			data0209 =  25'd0;
			data0210 =  25'd0;
			data0211 =  25'd0;
			data0212 =  25'd0;
			data0213 =  25'd0;
			data0214 =  25'd0;
			data0215 =  25'd0;
		end
	end
end 

assign data02_0001 = {data0200[24],data0200} + {data0201[24],data0201};
assign data02_0203 = {data0202[24],data0202} + {data0203[24],data0203};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data020_stp0 <= 27'd0;
	else
		data020_stp0 <= {data02_0001[25],data02_0001} + {data02_0203[25],data02_0203};
end 

assign data02_0405 = {data0204[24],data0204} + {data0205[24],data0205};
assign data02_0607 = {data0206[24],data0206} + {data0207[24],data0207};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data021_stp0 <= 27'd0;
	else
		data021_stp0 <= {data02_0405[25],data02_0405} + {data02_0607[25],data02_0607};
end 

assign data02_0809 = {data0208[24],data0208} + {data0209[24],data0209};
assign data02_1011 = {data0210[24],data0210} + {data0211[24],data0211};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data022_stp0 <= 27'd0;
	else
		data022_stp0 <= {data02_0809[25],data02_0809} + {data02_1011[25],data02_1011};
end 

assign data02_1213 = {data0212[24],data0212} + {data0213[24],data0213};
assign data02_1415 = {data0214[24],data0214} + {data0215[24],data0215};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data023_stp0 <= 27'd0;
	else
		data023_stp0 <= {data02_1213[25],data02_1213} + {data02_1415[25],data02_1415};
end
 
assign data0201_stp0 = {data020_stp0[26],data020_stp0} + {data021_stp0[26],data021_stp0};
assign data0223_stp0 = {data022_stp0[26],data022_stp0} + {data023_stp0[26],data023_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data020_stp1 <= 28'd0;
	else
		data020_stp1 <= data0201_stp0 + data0223_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data2 = {data020_stp0[26],data020_stp0};
	else 
		o_data2 = data020_stp1;
end 

//------------------------------------------o_data3--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data0300 =  ~data00_r16_31 + 1'b1;
			data0301 =  ~data01_r16_78 + 1'b1;
			data0302 =  ~data02_r16_90 + 1'b1;
			data0303 =  ~data03_r16_61 + 1'b1;
			data0304 =  ~data04_r16_4 + 1'b1;
			data0305 =  data05_r16_54;
			data0306 =  data06_r16_88;
			data0307 =  data07_r16_82;
			data0308 =  data08_r16_38;
			data0309 =  ~data09_r16_22 + 1'b1;
			data0310 =  ~data10_r16_73 + 1'b1;
			data0311 =  ~data11_r16_90 + 1'b1;
			data0312 =  ~data12_r16_67 + 1'b1;
			data0313 =  ~data13_r16_13 + 1'b1;
			data0314 =  data14_r16_46;
			data0315 =  data15_r16_85;
		end
	else if(dt_vld_16_d)
		begin
			data0300 =  ~data00_r8_57 + 1'b1 ;
			data0301 =  ~data01_r8_80 + 1'b1;
			data0302 =  data02_r8_25;
			data0303 =  data03_r8_90;
			data0304 =  data04_r8_9;
			data0305 =  ~data05_r8_87 + 1'b1;
			data0306 =  ~data06_r8_43 + 1'b1;
			data0307 =  data07_r8_70;
                        data0308 =  25'd0;  
                        data0309 =  25'd0;
                        data0310 =  25'd0;
                        data0311 =  25'd0;
                        data0312 =  25'd0;
                        data0313 =  25'd0;
                        data0314 =  25'd0;
                        data0315 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0300 =  ~data00_r4_89 + 1'b1;
			data0301 =  data01_r4_75;
			data0302 =  ~data02_r4_50 + 1'b1;
			data0303 =  data03_r4_18;
                        data0304 =  25'd0;         
                        data0305 =  25'd0;
                        data0306 =  25'd0;
                        data0307 =  25'd0;
                        data0308 =  25'd0; 
                        data0309 =  25'd0;
                        data0310 =  25'd0;
                        data0311 =  25'd0;
                        data0312 =  25'd0;
                        data0313 =  25'd0;
                        data0314 =  25'd0;
                        data0315 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data0300 =  data00_a4_36;
			data0301 =  ~data01_a4_83 + 1'b1;
			data0302 =  data02_a4_83;
			data0303 =  ~data03_a4_36 + 1'b1;
			data0304 =  25'd0;
			data0305 =  25'd0;
			data0306 =  25'd0;
			data0307 =  25'd0;
			data0308 =  25'd0;
			data0309 =  25'd0;
			data0310 =  25'd0;
			data0311 =  25'd0;
			data0312 =  25'd0;
			data0313 =  25'd0;
			data0314 =  25'd0;
			data0315 =  25'd0;
	end	
	else
		begin
			data0300 =  data00_s4_55;
			data0301 =  ~data01_s4_84 + 1'b1;
			data0302 =  data02_s4_74;
			data0303 =  ~data03_s4_29 + 1'b1;
			data0304 =  25'd0;
			data0305 =  25'd0;
			data0306 =  25'd0;
			data0307 =  25'd0;
			data0308 =  25'd0;
			data0309 =  25'd0;
			data0310 =  25'd0;
			data0311 =  25'd0;
			data0312 =  25'd0;
			data0313 =  25'd0;
			data0314 =  25'd0;
			data0315 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data0300 =  data00_r16_31;
			data0301 =  ~data01_r16_78 + 1'b1;
			data0302 =  data02_r16_90;
			data0303 =  ~data03_r16_61 + 1'b1;
			data0304 =  data04_r16_4;
			data0305 =  data05_r16_54;
			data0306 =  ~data06_r16_88 + 1'b1;
			data0307 =  data07_r16_82;
			data0308 =  ~data08_r16_38 + 1'b1;
			data0309 =  ~data09_r16_22 + 1'b1;
			data0310 =  data10_r16_73;
			data0311 =  ~data11_r16_90 + 1'b1;
			data0312 =  data12_r16_67;
			data0313 =  ~data13_r16_13 + 1'b1;
			data0314 =  ~data14_r16_46 + 1'b1;
			data0315 =  data15_r16_85;
		end
	else if(dt_vld_16_d)
		begin
			data0300 =  data00_r8_57 ;
			data0301 =  ~data01_r8_80 + 1'b1;
			data0302 =  ~data02_r8_25 + 1'b1;
			data0303 =  data03_r8_90;
			data0304 =  ~data04_r8_9 + 1'b1;
			data0305 =  ~data05_r8_87 + 1'b1;
			data0306 =  data06_r8_43;
			data0307 =  data07_r8_70;
                        data0308 =  25'd0;  
                        data0309 =  25'd0;
                        data0310 =  25'd0;
                        data0311 =  25'd0;
                        data0312 =  25'd0;
                        data0313 =  25'd0;
                        data0314 =  25'd0;
                        data0315 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0300 =  data00_r4_89;
			data0301 =  data01_r4_75;
			data0302 =  data02_r4_50;
			data0303 =  data03_r4_18;
                        data0304 =  25'd0;         
                        data0305 =  25'd0;
                        data0306 =  25'd0;
                        data0307 =  25'd0;
                        data0308 =  25'd0; 
                        data0309 =  25'd0;
                        data0310 =  25'd0;
                        data0311 =  25'd0;
                        data0312 =  25'd0;
                        data0313 =  25'd0;
                        data0314 =  25'd0;
                        data0315 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data0300 =  data00_a4_64;
			data0301 =  ~data01_a4_83 + 1'b1;
			data0302 =  data02_a4_64;
			data0303 =  ~data03_a4_36 + 1'b1;
			data0304 =  25'd0;
			data0305 =  25'd0;
			data0306 =  25'd0;
			data0307 =  25'd0;
			data0308 =  25'd0;
			data0309 =  25'd0;
			data0310 =  25'd0;
			data0311 =  25'd0;
			data0312 =  25'd0;
			data0313 =  25'd0;
			data0314 =  25'd0;
			data0315 =  25'd0;
	end	
	else
		begin
			data0300 =  data00_s4_84;
			data0301 =  ~data01_s4_74 + 1'b1;
			data0302 =  data02_s4_55;
			data0303 =  ~data03_s4_29 + 1'b1;
			data0304 =  25'd0;
			data0305 =  25'd0;
			data0306 =  25'd0;
			data0307 =  25'd0;
			data0308 =  25'd0;
			data0309 =  25'd0;
			data0310 =  25'd0;
			data0311 =  25'd0;
			data0312 =  25'd0;
			data0313 =  25'd0;
			data0314 =  25'd0;
			data0315 =  25'd0;
		end
	end
end 

assign data03_0001 = {data0300[24],data0300} + {data0301[24],data0301};
assign data03_0203 = {data0302[24],data0302} + {data0303[24],data0303};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data030_stp0 <= 27'd0;
	else
		data030_stp0 <= {data03_0001[25],data03_0001} + {data03_0203[25],data03_0203};
end 

assign data03_0405 = {data0304[24],data0304} + {data0305[24],data0305};
assign data03_0607 = {data0306[24],data0306} + {data0307[24],data0307};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data031_stp0 <= 27'd0;
	else
		data031_stp0 <= {data03_0405[25],data03_0405} + {data03_0607[25],data03_0607};
end 

assign data03_0809 = {data0308[24],data0308} + {data0309[24],data0309};
assign data03_1011 = {data0310[24],data0310} + {data0311[24],data0311};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data032_stp0 <= 27'd0;
	else
		data032_stp0 <= {data03_0809[25],data03_0809} + {data03_1011[25],data03_1011};
end 

assign data03_1213 = {data0312[24],data0312} + {data0313[24],data0313};
assign data03_1415 = {data0314[24],data0314} + {data0315[24],data0315};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data033_stp0 <= 27'd0;
	else
		data033_stp0 <= {data03_1213[25],data03_1213} + {data03_1415[25],data03_1415};
end
 
assign data0301_stp0 = {data030_stp0[26],data030_stp0} + {data031_stp0[26],data031_stp0};
assign data0323_stp0 = {data032_stp0[26],data032_stp0} + {data033_stp0[26],data033_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data030_stp1 <= 28'd0;
	else
		data030_stp1 <= data0301_stp0 + data0323_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data3 = {data030_stp0[26],data030_stp0};
	else 
		o_data3 = data030_stp1;
end 
//------------------------------------------o_data4--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data0400 =  data00_r16_38;
			data0401 =  data01_r16_88;
			data0402 =  data02_r16_73;
			data0403 =  data03_r16_4;
			data0404 =  ~data04_r16_67 + 1'b1;
			data0405 =  ~data05_r16_90 + 1'b1;
			data0406 =  ~data06_r16_46 + 1'b1;
			data0407 =  data07_r16_31;
			data0408 =  data08_r16_85;
			data0409 =  data09_r16_78;
			data0410 =  data10_r16_13;
			data0411 =  ~data11_r16_61 + 1'b1;
			data0412 =  ~data12_r16_90 + 1'b1;
			data0413 =  ~data13_r16_54 + 1'b1;
			data0414 =  data14_r16_22;
			data0415 =  data15_r16_82;
		end
	else if(dt_vld_16_d)
		begin
			data0400 =  data00_r8_70;
			data0401 =  data01_r8_43;
			data0402 =  ~data02_r8_87 + 1'b1;
			data0403 =  ~data03_r8_9 + 1'b1;
			data0404 =  data04_r8_90;
			data0405 =  ~data05_r8_25 + 1'b1;
			data0406 =  ~data06_r8_80 + 1'b1;
			data0407 =  data07_r8_57;
                        data0408 =  25'd0;  
                        data0409 =  25'd0;
                        data0410 =  25'd0;
                        data0411 =  25'd0;
                        data0412 =  25'd0;
                        data0413 =  25'd0;
                        data0414 =  25'd0;
                        data0415 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0400 =  data04_r4_18;
			data0401 =  data05_r4_50;
			data0402 =  data06_r4_75;
			data0403 =  data07_r4_89;
                        data0404 =  25'd0;         
                        data0405 =  25'd0;
                        data0406 =  25'd0;
                        data0407 =  25'd0;
                        data0408 =  25'd0; 
                        data0409 =  25'd0;
                        data0410 =  25'd0;
                        data0411 =  25'd0;
                        data0412 =  25'd0;
                        data0413 =  25'd0;
                        data0414 =  25'd0;
                        data0415 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data0400 =  data04_a4_64;
			data0401 =  data05_a4_64;
			data0402 =  data06_a4_64;
			data0403 =  data07_a4_64;
			data0404 =  25'd0;
			data0405 =  25'd0;
			data0406 =  25'd0;
			data0407 =  25'd0;
			data0408 =  25'd0;
			data0409 =  25'd0;
			data0410 =  25'd0;
			data0411 =  25'd0;
			data0412 =  25'd0;
			data0413 =  25'd0;
			data0414 =  25'd0;
			data0415 =  25'd0;
	end	
	else
		begin
			data0400 =  data04_s4_29;
			data0401 =  data05_s4_55;
			data0402 =  data06_s4_74;
			data0403 =  data07_s4_84;
			data0404 =  25'd0;
			data0405 =  25'd0;
			data0406 =  25'd0;
			data0407 =  25'd0;
			data0408 =  25'd0;
			data0409 =  25'd0;
			data0410 =  25'd0;
			data0411 =  25'd0;
			data0412 =  25'd0;
			data0413 =  25'd0;
			data0414 =  25'd0;
			data0415 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data0400 =  data00_r16_38;
			data0401 =  ~data01_r16_88 + 1'b1;
			data0402 =  data02_r16_73;
			data0403 =  ~data03_r16_4 + 1'b1;
			data0404 =  ~data04_r16_67 + 1'b1;
			data0405 =   data05_r16_90;
			data0406 =  ~data06_r16_46 + 1'b1;
			data0407 =  ~data07_r16_31 + 1'b1;
			data0408 =  data08_r16_85;
			data0409 =  ~data09_r16_78 + 1'b1;
			data0410 =  data10_r16_13;
			data0411 =  data11_r16_61;
			data0412 =  ~data12_r16_90 + 1'b1;
			data0413 =  data13_r16_54;
			data0414 =  data14_r16_22;
			data0415 =  ~data15_r16_82 + 1'b1;
		end
	else if(dt_vld_16_d)
		begin
			data0400 =  data00_r8_70 ;
			data0401 =  ~data01_r8_43 + 1'b1;
			data0402 =  ~data02_r8_87 + 1'b1;
			data0403 =  data03_r8_9;
			data0404 =  data04_r8_90;
			data0405 =  data05_r8_25;
			data0406 =  ~data06_r8_80 + 1'b1;
			data0407 =  ~data07_r8_57 + 1'b1;
                        data0408 =  25'd0;  
                        data0409 =  25'd0;
                        data0410 =  25'd0;
                        data0411 =  25'd0;
                        data0412 =  25'd0;
                        data0413 =  25'd0;
                        data0414 =  25'd0;
                        data0415 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0400 =  data04_r4_18;
			data0401 =  ~data05_r4_50 + 1'b1;
			data0402 =  data06_r4_75;
			data0403 =  ~data07_r4_89 + 1'b1;
                        data0404 =  25'd0;         
                        data0405 =  25'd0;
                        data0406 =  25'd0;
                        data0407 =  25'd0;
                        data0408 =  25'd0; 
                        data0409 =  25'd0;
                        data0410 =  25'd0;
                        data0411 =  25'd0;
                        data0412 =  25'd0;
                        data0413 =  25'd0;
                        data0414 =  25'd0;
                        data0415 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data0400 =  data04_a4_64;
			data0401 =  data05_a4_83;
			data0402 =  data06_a4_64;
			data0403 =  data07_a4_36;
			data0404 =  25'd0;
			data0405 =  25'd0;
			data0406 =  25'd0;
			data0407 =  25'd0;
			data0408 =  25'd0;
			data0409 =  25'd0;
			data0410 =  25'd0;
			data0411 =  25'd0;
			data0412 =  25'd0;
			data0413 =  25'd0;
			data0414 =  25'd0;
			data0415 =  25'd0;
	end	
	else
		begin
			data0400 =  data04_s4_29;
			data0401 =  data05_s4_74;
			data0402 =  data06_s4_84;
			data0403 =  data07_s4_55;
			data0404 =  25'd0;
			data0405 =  25'd0;
			data0406 =  25'd0;
			data0407 =  25'd0;
			data0408 =  25'd0;
			data0409 =  25'd0;
			data0410 =  25'd0;
			data0411 =  25'd0;
			data0412 =  25'd0;
			data0413 =  25'd0;
			data0414 =  25'd0;
			data0415 =  25'd0;
		end
	end
end 



assign data04_0001 = {data0400[24],data0400} + {data0401[24],data0401};
assign data04_0203 = {data0402[24],data0402} + {data0403[24],data0403};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data040_stp0 <= 27'd0;
	else
		data040_stp0 <= {data04_0001[25],data04_0001} + {data04_0203[25],data04_0203};
end 

assign data04_0405 = {data0404[24],data0404} + {data0405[24],data0405};
assign data04_0607 = {data0406[24],data0406} + {data0407[24],data0407};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data041_stp0 <= 27'd0;
	else
		data041_stp0 <= {data04_0405[25],data04_0405} + {data04_0607[25],data04_0607};
end 

assign data04_0809 = {data0408[24],data0408} + {data0409[24],data0409};
assign data04_1011 = {data0410[24],data0410} + {data0411[24],data0411};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data042_stp0 <= 27'd0;
	else
		data042_stp0 <= {data04_0809[25],data04_0809} + {data04_1011[25],data04_1011};
end 

assign data04_1213 = {data0412[24],data0412} + {data0413[24],data0413};
assign data04_1415 = {data0414[24],data0414} + {data0415[24],data0415};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data043_stp0 <= 27'd0;
	else
		data043_stp0 <= {data04_1213[25],data04_1213} + {data04_1415[25],data04_1415};
end
 
assign data0401_stp0 = {data040_stp0[26],data040_stp0} + {data041_stp0[26],data041_stp0};
assign data0423_stp0 = {data042_stp0[26],data042_stp0} + {data043_stp0[26],data043_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data040_stp1 <= 28'd0;
	else
		data040_stp1 <= data0401_stp0 + data0423_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data4 = {data040_stp0[26],data040_stp0};
	else 
		o_data4 = data040_stp1;
end 

//------------------------------------------o_data5--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data0500 =  ~data00_r16_46 + 1'b1;
			data0501 =  ~data01_r16_90 + 1'b1;
			data0502 =  ~data02_r16_38 + 1'b1;
			data0503 =  data03_r16_54;
			data0504 =  data04_r16_90;
			data0505 =  data05_r16_31;
			data0506 =  ~data06_r16_61 + 1'b1;
			data0507 =  ~data07_r16_88 + 1'b1;
			data0508 =  ~data08_r16_22 + 1'b1;
			data0509 =  data09_r16_67;
			data0510 =  data10_r16_85;
			data0511 =  data11_r16_13;
			data0512 =  ~data12_r16_73 + 1'b1;
			data0513 =  ~data13_r16_82 + 1'b1;
			data0514 =  ~data14_r16_4 + 1'b1;
			data0515 =  data15_r16_78;
		end
	else if(dt_vld_16_d)
		begin
			data0500 =  ~data00_r8_80 + 1'b1;
			data0501 =  data01_r8_9;
			data0502 =  data02_r8_70;
			data0503 =  ~data03_r8_87 + 1'b1;
			data0504 =  data04_r8_25;
			data0505 =  data05_r8_57;
			data0506 =  ~data06_r8_90 + 1'b1;
			data0507 =  data07_r8_43;
                        data0508 =  25'd0;  
                        data0509 =  25'd0;
                        data0510 =  25'd0;
                        data0511 =  25'd0;
                        data0512 =  25'd0;
                        data0513 =  25'd0;
                        data0514 =  25'd0;
                        data0515 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0500 =  ~data04_r4_50 + 1'b1;
			data0501 =  ~data05_r4_89 + 1'b1;
			data0502 =  ~data06_r4_18 + 1'b1;
			data0503 =  data07_r4_75;
                        data0504 =  25'd0;         
                        data0505 =  25'd0;
                        data0506 =  25'd0;
                        data0507 =  25'd0;
                        data0508 =  25'd0; 
                        data0509 =  25'd0;
                        data0510 =  25'd0;
                        data0511 =  25'd0;
                        data0512 =  25'd0;
                        data0513 =  25'd0;
                        data0514 =  25'd0;
                        data0515 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data0500 =  data04_a4_83;
			data0501 =  data05_a4_36;
			data0502 =  ~data06_a4_36 + 1'b1;
			data0503 =  ~data07_a4_83 + 1'b1;
			data0504 =  25'd0;
			data0505 =  25'd0;
			data0506 =  25'd0;
			data0507 =  25'd0;
			data0508 =  25'd0;
			data0509 =  25'd0;
			data0510 =  25'd0;
			data0511 =  25'd0;
			data0512 =  25'd0;
			data0513 =  25'd0;
			data0514 =  25'd0;
			data0515 =  25'd0;
	end	
	else
		begin
			data0500 =  data04_s4_74;
			data0501 =  data05_s4_74;
			data0502 =  25'd0;
			data0503 =  ~data07_s4_74 + 1'b1;
			data0504 =  25'd0;
			data0505 =  25'd0;
			data0506 =  25'd0;
			data0507 =  25'd0;
			data0508 =  25'd0;
			data0509 =  25'd0;
			data0510 =  25'd0;
			data0511 =  25'd0;
			data0512 =  25'd0;
			data0513 =  25'd0;
			data0514 =  25'd0;
			data0515 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data0500 =  data00_r16_46;
			data0501 =  ~data01_r16_90 + 1'b1;
			data0502 =  data02_r16_38;
			data0503 =  data03_r16_54;
			data0504 =  ~data04_r16_90 + 1'b1;
			data0505 =  data05_r16_31;
			data0506 =  data06_r16_61;
			data0507 =  ~data07_r16_88 + 1'b1;
			data0508 =  data08_r16_22;
			data0509 =  data09_r16_67;
			data0510 =  ~data10_r16_85 + 1'b1;
			data0511 =  data11_r16_13;
			data0512 =  data12_r16_73;
			data0513 =  ~data13_r16_82 + 1'b1;
			data0514 =  data14_r16_4;
			data0515 =  data15_r16_78;
		end
	else if(dt_vld_16_d)
		begin
			data0500 =  data00_r8_80 ;
			data0501 =  data01_r8_9;
			data0502 =  ~data02_r8_70 + 1'b1;
			data0503 =  ~data03_r8_87 + 1'b1;
			data0504 =  ~data04_r8_25 + 1'b1;
			data0505 =  data05_r8_57;
			data0506 =  data06_r8_90;
			data0507 =  data07_r8_43;
                        data0508 =  25'd0;  
                        data0509 =  25'd0;
                        data0510 =  25'd0;
                        data0511 =  25'd0;
                        data0512 =  25'd0;
                        data0513 =  25'd0;
                        data0514 =  25'd0;
                        data0515 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0500 =  data04_r4_50;
			data0501 =  ~data05_r4_89 + 1'b1;
			data0502 =  data06_r4_18;
			data0503 =  data07_r4_75;
                        data0504 =  25'd0;         
                        data0505 =  25'd0;
                        data0506 =  25'd0;
                        data0507 =  25'd0;
                        data0508 =  25'd0; 
                        data0509 =  25'd0;
                        data0510 =  25'd0;
                        data0511 =  25'd0;
                        data0512 =  25'd0;
                        data0513 =  25'd0;
                        data0514 =  25'd0;
                        data0515 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data0500 =  data04_a4_64;
			data0501 =  data05_a4_36;
			data0502 =  ~data06_a4_64 + 1'b1;
			data0503 =  ~data07_a4_83 + 1'b1;
			data0504 =  25'd0;
			data0505 =  25'd0;
			data0506 =  25'd0;
			data0507 =  25'd0;
			data0508 =  25'd0;
			data0509 =  25'd0;
			data0510 =  25'd0;
			data0511 =  25'd0;
			data0512 =  25'd0;
			data0513 =  25'd0;
			data0514 =  25'd0;
			data0515 =  25'd0;
	end	
	else
		begin
			data0500 =  data04_s4_55;
			data0501 =  data05_s4_74;
			data0502 =  ~data06_s4_29 + 1'b1;
			data0503 =  ~data07_s4_84 + 1'b1;
			data0504 =  25'd0;
			data0505 =  25'd0;
			data0506 =  25'd0;
			data0507 =  25'd0;
			data0508 =  25'd0;
			data0509 =  25'd0;
			data0510 =  25'd0;
			data0511 =  25'd0;
			data0512 =  25'd0;
			data0513 =  25'd0;
			data0514 =  25'd0;
			data0515 =  25'd0;
		end
	end
end 

assign data05_0001 = {data0500[24],data0500} + {data0501[24],data0501};
assign data05_0203 = {data0502[24],data0502} + {data0503[24],data0503};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data050_stp0 <= 27'd0;
	else
		data050_stp0 <= {data05_0001[25],data05_0001} + {data05_0203[25],data05_0203};
end 

assign data05_0405 = {data0504[24],data0504} + {data0505[24],data0505};
assign data05_0607 = {data0506[24],data0506} + {data0507[24],data0507};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data051_stp0 <= 27'd0;
	else
		data051_stp0 <= {data05_0405[25],data05_0405} + {data05_0607[25],data05_0607};
end 

assign data05_0809 = {data0508[24],data0508} + {data0509[24],data0509};
assign data05_1011 = {data0510[24],data0510} + {data0511[24],data0511};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data052_stp0 <= 27'd0;
	else
		data052_stp0 <= {data05_0809[25],data05_0809} + {data05_1011[25],data05_1011};
end 

assign data05_1213 = {data0512[24],data0512} + {data0513[24],data0513};
assign data05_1415 = {data0514[24],data0514} + {data0515[24],data0515};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data053_stp0 <= 27'd0;
	else
		data053_stp0 <= {data05_1213[25],data05_1213} + {data05_1415[25],data05_1415};
end
 
assign data0501_stp0 = {data050_stp0[26],data050_stp0} + {data051_stp0[26],data051_stp0};
assign data0523_stp0 = {data052_stp0[26],data052_stp0} + {data053_stp0[26],data053_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data050_stp1 <= 28'd0;
	else
		data050_stp1 <= data0501_stp0 + data0523_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data5 = {data050_stp0[26],data050_stp0};
	else 
		o_data5 = data050_stp1;
end 

//------------------------------------------o_data6--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data0600 =  data00_r16_54;
			data0601 =  data01_r16_85;
			data0602 =  ~data02_r16_4 + 1'b1;
			data0603 =  ~data03_r16_88 + 1'b1;
			data0604 =  ~data04_r16_46 + 1'b1;
			data0605 =  data05_r16_61;
			data0606 =  data06_r16_82;
			data0607 =  ~data07_r16_13 + 1'b1;
			data0608 =  ~data08_r16_90 + 1'b1;
			data0609 =  ~data09_r16_38 + 1'b1;
			data0610 =  data10_r16_67;
			data0611 =  data11_r16_78;
			data0612 =  ~data12_r16_22 + 1'b1;
			data0613 =  ~data13_r16_90 + 1'b1;
			data0614 =  ~data14_r16_31 + 1'b1;
			data0615 =  data15_r16_73;
		end
	else if(dt_vld_16_d)
		begin
			data0600 =  data00_r8_87;
			data0601 =  ~data01_r8_57 + 1'b1;
			data0602 =  data02_r8_9;
			data0603 =  data03_r8_43;
			data0604 =  ~data04_r8_80 + 1'b1;
			data0605 =  data05_r8_90;
			data0606 =  ~data06_r8_70 + 1'b1;
			data0607 =  data07_r8_25;
                        data0608 =  25'd0;  
                        data0609 =  25'd0;
                        data0610 =  25'd0;
                        data0611 =  25'd0;
                        data0612 =  25'd0;
                        data0613 =  25'd0;
                        data0614 =  25'd0;
                        data0615 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0600 =  data04_r4_75;
			data0601 =  data05_r4_18;
			data0602 =  ~data06_r4_89 + 1'b1;
			data0603 =  data07_r4_50;
                        data0604 =  25'd0;         
                        data0605 =  25'd0;
                        data0606 =  25'd0;
                        data0607 =  25'd0;
                        data0608 =  25'd0; 
                        data0609 =  25'd0;
                        data0610 =  25'd0;
                        data0611 =  25'd0;
                        data0612 =  25'd0;
                        data0613 =  25'd0;
                        data0614 =  25'd0;
                        data0615 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data0600 =  data04_a4_64;
			data0601 =  ~data05_a4_64 + 1'b1;
			data0602 =  ~data06_a4_64 + 1'b1;
			data0603 =  data07_a4_64;
			data0604 =  25'd0;
			data0605 =  25'd0;
			data0606 =  25'd0;
			data0607 =  25'd0;
			data0608 =  25'd0;
			data0609 =  25'd0;
			data0610 =  25'd0;
			data0611 =  25'd0;
			data0612 =  25'd0;
			data0613 =  25'd0;
			data0614 =  25'd0;
			data0615 =  25'd0;
	end	
	else
		begin
			data0600 =   data04_s4_84;
			data0601 =  ~data05_s4_29 + 1'b1;
			data0602 =  ~data06_s4_74 + 1'b1;
			data0603 =   data07_s4_55;
			data0604 =  25'd0;
			data0605 =  25'd0;
			data0606 =  25'd0;
			data0607 =  25'd0;
			data0608 =  25'd0;
			data0609 =  25'd0;
			data0610 =  25'd0;
			data0611 =  25'd0;
			data0612 =  25'd0;
			data0613 =  25'd0;
			data0614 =  25'd0;
			data0615 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data0600 =  data00_r16_54;
			data0601 =  ~data01_r16_85 + 1'b1;
			data0602 =  ~data02_r16_4 + 1'b1;
			data0603 =  data03_r16_88;
			data0604 =  ~data04_r16_46 + 1'b1;
			data0605 =  ~data05_r16_61 + 1'b1;
			data0606 =  data06_r16_82;
			data0607 =  data07_r16_13;
			data0608 =  ~data08_r16_90 + 1'b1;
			data0609 =  data09_r16_38;
			data0610 =  data10_r16_67;
			data0611 =  ~data11_r16_78 + 1'b1;
			data0612 =  ~data12_r16_22 + 1'b1;
			data0613 =  data13_r16_90;
			data0614 =  ~data14_r16_31 + 1'b1;
			data0615 =  ~data15_r16_73 + 1'b1;
		end
	else if(dt_vld_16_d)
		begin
			data0600 =  data00_r8_87 ;
			data0601 =  data01_r8_57;
			data0602 =  data02_r8_9;
			data0603 =  ~data03_r8_43 + 1'b1;
			data0604 =  ~data04_r8_80 + 1'b1;
			data0605 =  ~data05_r8_90 + 1'b1;
			data0606 =  ~data06_r8_70 + 1'b1;
			data0607 =  ~data07_r8_25 + 1'b1;
                        data0608 =  25'd0;  
                        data0609 =  25'd0;
                        data0610 =  25'd0;
                        data0611 =  25'd0;
                        data0612 =  25'd0;
                        data0613 =  25'd0;
                        data0614 =  25'd0;
                        data0615 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0600 =  data04_r4_75;
			data0601 =  ~data05_r4_18 + 1'b1;
			data0602 =  ~data06_r4_89 + 1'b1;
			data0603 =  ~data07_r4_50 + 1'b1;
                        data0604 =  25'd0;         
                        data0605 =  25'd0;
                        data0606 =  25'd0;
                        data0607 =  25'd0;
                        data0608 =  25'd0; 
                        data0609 =  25'd0;
                        data0610 =  25'd0;
                        data0611 =  25'd0;
                        data0612 =  25'd0;
                        data0613 =  25'd0;
                        data0614 =  25'd0;
                        data0615 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data0600 =  data04_a4_64;
			data0601 =  ~data05_a4_36 + 1'b1;
			data0602 =  ~data06_a4_64 + 1'b1;
			data0603 =  data07_a4_83;
			data0604 =  25'd0;
			data0605 =  25'd0;
			data0606 =  25'd0;
			data0607 =  25'd0;
			data0608 =  25'd0;
			data0609 =  25'd0;
			data0610 =  25'd0;
			data0611 =  25'd0;
			data0612 =  25'd0;
			data0613 =  25'd0;
			data0614 =  25'd0;
			data0615 =  25'd0;
	end	
	else
		begin
			data0600 =   data04_s4_74;
			data0601 =  25'd0;
			data0602 =  ~data06_s4_74 + 1'b1;
			data0603 =   data07_s4_74;
			data0604 =  25'd0;
			data0605 =  25'd0;
			data0606 =  25'd0;
			data0607 =  25'd0;
			data0608 =  25'd0;
			data0609 =  25'd0;
			data0610 =  25'd0;
			data0611 =  25'd0;
			data0612 =  25'd0;
			data0613 =  25'd0;
			data0614 =  25'd0;
			data0615 =  25'd0;
		end
	end
end 

assign data06_0001 = {data0600[24],data0600} + {data0601[24],data0601};
assign data06_0203 = {data0602[24],data0602} + {data0603[24],data0603};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data060_stp0 <= 27'd0;
	else
		data060_stp0 <= {data06_0001[25],data06_0001} + {data06_0203[25],data06_0203};
end 

assign data06_0405 = {data0604[24],data0604} + {data0605[24],data0605};
assign data06_0607 = {data0606[24],data0606} + {data0607[24],data0607};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data061_stp0 <= 27'd0;
	else
		data061_stp0 <= {data06_0405[25],data06_0405} + {data06_0607[25],data06_0607};
end 

assign data06_0809 = {data0608[24],data0608} + {data0609[24],data0609};
assign data06_1011 = {data0610[24],data0610} + {data0611[24],data0611};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data062_stp0 <= 27'd0;
	else
		data062_stp0 <= {data06_0809[25],data06_0809} + {data06_1011[25],data06_1011};
end 

assign data06_1213 = {data0612[24],data0612} + {data0613[24],data0613};
assign data06_1415 = {data0614[24],data0614} + {data0615[24],data0615};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data063_stp0 <= 27'd0;
	else
		data063_stp0 <= {data06_1213[25],data06_1213} + {data06_1415[25],data06_1415};
end
 
assign data0601_stp0 = {data060_stp0[26],data060_stp0} + {data061_stp0[26],data061_stp0};
assign data0623_stp0 = {data062_stp0[26],data062_stp0} + {data063_stp0[26],data063_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data060_stp1 <= 28'd0;
	else
		data060_stp1 <= data0601_stp0 + data0623_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data6 = {data060_stp0[26],data060_stp0};
	else 
		o_data6 = data060_stp1;
end 

//------------------------------------------o_data7--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data0700 =  ~data00_r16_61 + 1'b1;
			data0701 =  ~data01_r16_73 + 1'b1;
			data0702 =  data02_r16_46;
			data0703 =  data03_r16_82;
			data0704 =  ~data04_r16_31 + 1'b1;
			data0705 =  ~data05_r16_88 + 1'b1;
			data0706 =  data06_r16_13;
			data0707 =  data07_r16_90;
			data0708 =  data08_r16_4;
			data0709 =  ~data09_r16_90 + 1'b1;
			data0710 =  ~data10_r16_22 + 1'b1;
			data0711 =  data11_r16_85;
			data0712 =  data12_r16_38;
			data0713 =  ~data13_r16_78 + 1'b1;
			data0714 =  ~data14_r16_54 + 1'b1;
			data0715 =  data15_r16_67;
		end
	else if(dt_vld_16_d)
		begin
			data0700 =  ~data00_r8_90 + 1'b1;
			data0701 =  data01_r8_87;
			data0702 =  ~data02_r8_80 + 1'b1;
			data0703 =  data03_r8_70;
			data0704 =  ~data04_r8_57 + 1'b1;
			data0705 =  data05_r8_43;
			data0706 =  ~data06_r8_25 + 1'b1;
			data0707 =  data07_r8_9;
                        data0708 =  25'd0;  
                        data0709 =  25'd0;
                        data0710 =  25'd0;
                        data0711 =  25'd0;
                        data0712 =  25'd0;
                        data0713 =  25'd0;
                        data0714 =  25'd0;
                        data0715 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0700 =  ~data04_r4_89 + 1'b1;
			data0701 =  data05_r4_75;
			data0702 =  ~data06_r4_50 + 1'b1;
			data0703 =  data07_r4_18;
                        data0704 =  25'd0;         
                        data0705 =  25'd0;
                        data0706 =  25'd0;
                        data0707 =  25'd0;
                        data0708 =  25'd0; 
                        data0709 =  25'd0;
                        data0710 =  25'd0;
                        data0711 =  25'd0;
                        data0712 =  25'd0;
                        data0713 =  25'd0;
                        data0714 =  25'd0;
                        data0715 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data0700 =  data04_a4_36;
			data0701 =  ~data05_a4_83 + 1'b1;
			data0702 =  data06_a4_83;
			data0703 =  ~data07_a4_36 + 1'b1;
			data0704 =  25'd0;
			data0705 =  25'd0;
			data0706 =  25'd0;
			data0707 =  25'd0;
			data0708 =  25'd0;
			data0709 =  25'd0;
			data0710 =  25'd0;
			data0711 =  25'd0;
			data0712 =  25'd0;
			data0713 =  25'd0;
			data0714 =  25'd0;
			data0715 =  25'd0;
	end	
	else
		begin
			data0700 =   data04_s4_55;
			data0701 =  ~data05_s4_84 + 1'b1;
			data0702 =   data06_s4_74;
			data0703 =  ~data07_s4_29 + 1'b1;
			data0704 =  25'd0;
			data0705 =  25'd0;
			data0706 =  25'd0;
			data0707 =  25'd0;
			data0708 =  25'd0;
			data0709 =  25'd0;
			data0710 =  25'd0;
			data0711 =  25'd0;
			data0712 =  25'd0;
			data0713 =  25'd0;
			data0714 =  25'd0;
			data0715 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data0700 =  data00_r16_61;
			data0701 =  ~data01_r16_73 + 1'b1;
			data0702 =  ~data02_r16_46 + 1'b1;
			data0703 =  data03_r16_82;
			data0704 =  data04_r16_31;
			data0705 =  ~data05_r16_88 + 1'b1;
			data0706 =  ~data06_r16_13 + 1'b1;
			data0707 =  data07_r16_90;
			data0708 =  ~data08_r16_4 + 1'b1;
			data0709 =  ~data09_r16_90 + 1'b1;
			data0710 =  data10_r16_22;
			data0711 =  data11_r16_85;
			data0712 =  ~data12_r16_38 + 1'b1;
			data0713 =  ~data13_r16_78 + 1'b1;
			data0714 =  data14_r16_54;
			data0715 =  data15_r16_67;
		end
	else if(dt_vld_16_d)
		begin
			data0700 =  data00_r8_90;
			data0701 =  data01_r8_87;
			data0702 =  data02_r8_80;
			data0703 =  data03_r8_70;
			data0704 =  data04_r8_57;
			data0705 =  data05_r8_43;
			data0706 =  data06_r8_25;
			data0707 =  data07_r8_9;
                        data0708 =  25'd0;  
                        data0709 =  25'd0;
                        data0710 =  25'd0;
                        data0711 =  25'd0;
                        data0712 =  25'd0;
                        data0713 =  25'd0;
                        data0714 =  25'd0;
                        data0715 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0700 =  data04_r4_89;
			data0701 =  data05_r4_75;
			data0702 =  data06_r4_50;
			data0703 =  data07_r4_18;
                        data0704 =  25'd0;         
                        data0705 =  25'd0;
                        data0706 =  25'd0;
                        data0707 =  25'd0;
                        data0708 =  25'd0; 
                        data0709 =  25'd0;
                        data0710 =  25'd0;
                        data0711 =  25'd0;
                        data0712 =  25'd0;
                        data0713 =  25'd0;
                        data0714 =  25'd0;
                        data0715 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data0700 =  data04_a4_64;
			data0701 =  ~data05_a4_83 + 1'b1;
			data0702 =  data06_a4_64;
			data0703 =  ~data07_a4_36 + 1'b1;
			data0704 =  25'd0;
			data0705 =  25'd0;
			data0706 =  25'd0;
			data0707 =  25'd0;
			data0708 =  25'd0;
			data0709 =  25'd0;
			data0710 =  25'd0;
			data0711 =  25'd0;
			data0712 =  25'd0;
			data0713 =  25'd0;
			data0714 =  25'd0;
			data0715 =  25'd0;
	end	
	else
		begin
			data0700 =   data04_s4_84;
			data0701 =  ~data05_s4_74 + 1'b1;
			data0702 =   data06_s4_55;
			data0703 =  ~data07_s4_29 + 1'b1;
			data0704 =  25'd0;
			data0705 =  25'd0;
			data0706 =  25'd0;
			data0707 =  25'd0;
			data0708 =  25'd0;
			data0709 =  25'd0;
			data0710 =  25'd0;
			data0711 =  25'd0;
			data0712 =  25'd0;
			data0713 =  25'd0;
			data0714 =  25'd0;
			data0715 =  25'd0;
		end
	end
end 



assign data07_0001 = {data0700[24],data0700} + {data0701[24],data0701};
assign data07_0203 = {data0702[24],data0702} + {data0703[24],data0703};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data070_stp0 <= 27'd0;
	else
		data070_stp0 <= {data07_0001[25],data07_0001} + {data07_0203[25],data07_0203};
end 

assign data07_0405 = {data0704[24],data0704} + {data0705[24],data0705};
assign data07_0607 = {data0706[24],data0706} + {data0707[24],data0707};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data071_stp0 <= 27'd0;
	else
		data071_stp0 <= {data07_0405[25],data07_0405} + {data07_0607[25],data07_0607};
end 

assign data07_0809 = {data0708[24],data0708} + {data0709[24],data0709};
assign data07_1011 = {data0710[24],data0710} + {data0711[24],data0711};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data072_stp0 <= 27'd0;
	else
		data072_stp0 <= {data07_0809[25],data07_0809} + {data07_1011[25],data07_1011};
end 

assign data07_1213 = {data0712[24],data0712} + {data0713[24],data0713};
assign data07_1415 = {data0714[24],data0714} + {data0715[24],data0715};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data073_stp0 <= 27'd0;
	else
		data073_stp0 <= {data07_1213[25],data07_1213} + {data07_1415[25],data07_1415};
end
 
assign data0701_stp0 = {data070_stp0[26],data070_stp0} + {data071_stp0[26],data071_stp0};
assign data0723_stp0 = {data072_stp0[26],data072_stp0} + {data073_stp0[26],data073_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data070_stp1 <= 28'd0;
	else
		data070_stp1 <= data0701_stp0 + data0723_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data7 = {data070_stp0[26],data070_stp0};
	else 
		o_data7 = data070_stp1;
end 

//------------------------------------------o_data8--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data0800 =  data00_r16_67;
			data0801 =  data01_r16_54;
			data0802 =  ~data02_r16_78 + 1'b1;
			data0803 =  ~data03_r16_38 + 1'b1;
			data0804 =  data04_r16_85;
			data0805 =  data05_r16_22;
			data0806 =  ~data06_r16_90 + 1'b1;
			data0807 =  ~data07_r16_4 + 1'b1;
			data0808 =  data08_r16_90;
			data0809 =  ~data09_r16_13 + 1'b1;
			data0810 =  ~data10_r16_88 + 1'b1;
			data0811 =  data11_r16_31;
			data0812 =  data12_r16_82;
			data0813 =  ~data13_r16_46 + 1'b1;
			data0814 =  ~data14_r16_73 + 1'b1;
			data0815 =  data15_r16_61;
		end
	else if(dt_vld_16_d)
		begin
			data0800 =  data08_r8_9;
			data0801 =  data09_r8_25;
			data0802 =  data10_r8_43;
			data0803 =  data11_r8_57;
			data0804 =  data12_r8_70;
			data0805 =  data13_r8_80;
			data0806 =  data14_r8_87;
			data0807 =  data15_r8_90;
                        data0808 =  25'd0;  
                        data0809 =  25'd0;
                        data0810 =  25'd0;
                        data0811 =  25'd0;
                        data0812 =  25'd0;
                        data0813 =  25'd0;
                        data0814 =  25'd0;
                        data0815 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0800 =  data08_r4_18;
			data0801 =  data09_r4_50;
			data0802 =  data10_r4_75;
			data0803 =  data11_r4_89;
                        data0804 =  25'd0;         
                        data0805 =  25'd0;
                        data0806 =  25'd0;
                        data0807 =  25'd0;
                        data0808 =  25'd0; 
                        data0809 =  25'd0;
                        data0810 =  25'd0;
                        data0811 =  25'd0;
                        data0812 =  25'd0;
                        data0813 =  25'd0;
                        data0814 =  25'd0;
                        data0815 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data0800 =  data08_a4_64;
			data0801 =  data09_a4_64;
			data0802 =  data10_a4_64;
			data0803 =  data11_a4_64;
			data0804 =  25'd0;
			data0805 =  25'd0;
			data0806 =  25'd0;
			data0807 =  25'd0;
			data0808 =  25'd0;
			data0809 =  25'd0;
			data0810 =  25'd0;
			data0811 =  25'd0;
			data0812 =  25'd0;
			data0813 =  25'd0;
			data0814 =  25'd0;
			data0815 =  25'd0;
	end	
	else
		begin
			data0800 =  data08_s4_29;
			data0801 =  data09_s4_55;
			data0802 =  data10_s4_74;
			data0803 =  data11_s4_84;
			data0804 =  25'd0;
			data0805 =  25'd0;
			data0806 =  25'd0;
			data0807 =  25'd0;
			data0808 =  25'd0;
			data0809 =  25'd0;
			data0810 =  25'd0;
			data0811 =  25'd0;
			data0812 =  25'd0;
			data0813 =  25'd0;
			data0814 =  25'd0;
			data0815 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data0800 =  data00_r16_67;
			data0801 =  ~data01_r16_54 + 1'b1;
			data0802 =  ~data02_r16_78 + 1'b1;
			data0803 =  data03_r16_38;
			data0804 =  data04_r16_85;
			data0805 =  ~data05_r16_22 + 1'b1;
			data0806 =  ~data06_r16_90 + 1'b1;
			data0807 =  data07_r16_4;
			data0808 =  data08_r16_90;
			data0809 =  data09_r16_13;
			data0810 =  ~data10_r16_88 + 1'b1;
			data0811 =  ~data11_r16_31 + 1'b1;
			data0812 =  data12_r16_82;
			data0813 =  data13_r16_46;
			data0814 =  ~data14_r16_73 + 1'b1;
			data0815 =  ~data15_r16_61 + 1'b1;
		end
	else if(dt_vld_16_d)
		begin
			data0800 =  data08_r8_9 ;
			data0801 =  ~data09_r8_25 + 1'b1;
			data0802 =  data10_r8_43;
			data0803 =  ~data11_r8_57 + 1'b1;
			data0804 =  data12_r8_70;
			data0805 =  ~data13_r8_80 + 1'b1;
			data0806 =  data14_r8_87;
			data0807 =  ~data15_r8_90 + 1'b1;
                        data0808 =  25'd0;  
                        data0809 =  25'd0;
                        data0810 =  25'd0;
                        data0811 =  25'd0;
                        data0812 =  25'd0;
                        data0813 =  25'd0;
                        data0814 =  25'd0;
                        data0815 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0800 =  data08_r4_18;
			data0801 =  ~data09_r4_50 + 1'b1;
			data0802 =  data10_r4_75;
			data0803 =  ~data11_r4_89 + 1'b1;
                        data0804 =  25'd0;         
                        data0805 =  25'd0;
                        data0806 =  25'd0;
                        data0807 =  25'd0;
                        data0808 =  25'd0; 
                        data0809 =  25'd0;
                        data0810 =  25'd0;
                        data0811 =  25'd0;
                        data0812 =  25'd0;
                        data0813 =  25'd0;
                        data0814 =  25'd0;
                        data0815 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data0800 =  data08_a4_64;
			data0801 =  data09_a4_83;
			data0802 =  data10_a4_64;
			data0803 =  data11_a4_36;
			data0804 =  25'd0;
			data0805 =  25'd0;
			data0806 =  25'd0;
			data0807 =  25'd0;
			data0808 =  25'd0;
			data0809 =  25'd0;
			data0810 =  25'd0;
			data0811 =  25'd0;
			data0812 =  25'd0;
			data0813 =  25'd0;
			data0814 =  25'd0;
			data0815 =  25'd0;
	end	
	else
		begin
			data0800 =  data08_s4_29;
			data0801 =  data09_s4_74;
			data0802 =  data10_s4_84;
			data0803 =  data11_s4_55;
			data0804 =  25'd0;
			data0805 =  25'd0;
			data0806 =  25'd0;
			data0807 =  25'd0;
			data0808 =  25'd0;
			data0809 =  25'd0;
			data0810 =  25'd0;
			data0811 =  25'd0;
			data0812 =  25'd0;
			data0813 =  25'd0;
			data0814 =  25'd0;
			data0815 =  25'd0;
		end
	end
end 



assign data08_0001 = {data0800[24],data0800} + {data0801[24],data0801};
assign data08_0203 = {data0802[24],data0802} + {data0803[24],data0803};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data080_stp0 <= 27'd0;
	else
		data080_stp0 <= {data08_0001[25],data08_0001} + {data08_0203[25],data08_0203};
end 

assign data08_0405 = {data0804[24],data0804} + {data0805[24],data0805};
assign data08_0607 = {data0806[24],data0806} + {data0807[24],data0807};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data081_stp0 <= 27'd0;
	else
		data081_stp0 <= {data08_0405[25],data08_0405} + {data08_0607[25],data08_0607};
end 

assign data08_0809 = {data0808[24],data0808} + {data0809[24],data0809};
assign data08_1011 = {data0810[24],data0810} + {data0811[24],data0811};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data082_stp0 <= 27'd0;
	else
		data082_stp0 <= {data08_0809[25],data08_0809} + {data08_1011[25],data08_1011};
end 

assign data08_1213 = {data0812[24],data0812} + {data0813[24],data0813};
assign data08_1415 = {data0814[24],data0814} + {data0815[24],data0815};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data083_stp0 <= 27'd0;
	else
		data083_stp0 <= {data08_1213[25],data08_1213} + {data08_1415[25],data08_1415};
end
 
assign data0801_stp0 = {data080_stp0[26],data080_stp0} + {data081_stp0[26],data081_stp0};
assign data0823_stp0 = {data082_stp0[26],data082_stp0} + {data083_stp0[26],data083_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data080_stp1 <= 28'd0;
	else
		data080_stp1 <= data0801_stp0 + data0823_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data8 = {data080_stp0[26],data080_stp0};
	else 
		o_data8 = data080_stp1;
end 

//------------------------------------------o_data9--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data0900 =  ~data00_r16_73 + 1'b1;
			data0901 =  ~data01_r16_31 + 1'b1;
			data0902 =  data02_r16_90;
			data0903 =  ~data03_r16_22 + 1'b1;
			data0904 =  ~data04_r16_78 + 1'b1;
			data0905 =  data05_r16_67;
			data0906 =  data06_r16_38;
			data0907 =  ~data07_r16_90 + 1'b1;
			data0908 =  data08_r16_13;
			data0909 =  data09_r16_82;
			data0910 =  ~data10_r16_61 + 1'b1;
			data0911 =  ~data11_r16_46 + 1'b1;
			data0912 =  data12_r16_88;
			data0913 =  ~data13_r16_4 + 1'b1;
			data0914 =  ~data14_r16_85 + 1'b1;
			data0915 =  data15_r16_54;
		end
	else if(dt_vld_16_d)
		begin
			data0900 =  ~data08_r8_25 + 1'b1;
			data0901 =  ~data09_r8_70 + 1'b1;
			data0902 =  ~data10_r8_90 + 1'b1;
			data0903 =  ~data11_r8_80 + 1'b1;
			data0904 =  ~data12_r8_43 + 1'b1;
			data0905 =   data13_r8_9;
			data0906 =   data14_r8_57;
			data0907 =   data15_r8_87;
                        data0908 =  25'd0;  
                        data0909 =  25'd0;
                        data0910 =  25'd0;
                        data0911 =  25'd0;
                        data0912 =  25'd0;
                        data0913 =  25'd0;
                        data0914 =  25'd0;
                        data0915 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0900 =  ~data08_r4_50 + 1'b1;
			data0901 =  ~data09_r4_89 + 1'b1;
			data0902 =  ~data10_r4_18 + 1'b1;
			data0903 =  data11_r4_75;
                        data0904 =  25'd0;         
                        data0905 =  25'd0;
                        data0906 =  25'd0;
                        data0907 =  25'd0;
                        data0908 =  25'd0; 
                        data0909 =  25'd0;
                        data0910 =  25'd0;
                        data0911 =  25'd0;
                        data0912 =  25'd0;
                        data0913 =  25'd0;
                        data0914 =  25'd0;
                        data0915 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data0900 =  data08_a4_83;
			data0901 =  data09_a4_36;
			data0902 =  ~data10_a4_36 + 1'b1;
			data0903 =  ~data11_a4_83 + 1'b1;
			data0904 =  25'd0;
			data0905 =  25'd0;
			data0906 =  25'd0;
			data0907 =  25'd0;
			data0908 =  25'd0;
			data0909 =  25'd0;
			data0910 =  25'd0;
			data0911 =  25'd0;
			data0912 =  25'd0;
			data0913 =  25'd0;
			data0914 =  25'd0;
			data0915 =  25'd0;
	end	
	else
		begin
			data0900 =   data08_s4_74;
			data0901 =   data09_s4_74;
			data0902 =  25'd0;
			data0903 =  ~data11_s4_74 + 1'b1;
			data0904 =  25'd0;
			data0905 =  25'd0;
			data0906 =  25'd0;
			data0907 =  25'd0;
			data0908 =  25'd0;
			data0909 =  25'd0;
			data0910 =  25'd0;
			data0911 =  25'd0;
			data0912 =  25'd0;
			data0913 =  25'd0;
			data0914 =  25'd0;
			data0915 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data0900 =  data00_r16_73;
			data0901 =  ~data01_r16_31 + 1'b1;
			data0902 =  ~data02_r16_90 + 1'b1;
			data0903 =  ~data03_r16_22 + 1'b1;
			data0904 =  data04_r16_78;
			data0905 =  data05_r16_67;
			data0906 =  ~data06_r16_38 + 1'b1;
			data0907 =  ~data07_r16_90 + 1'b1;
			data0908 =  ~data08_r16_13 + 1'b1;
			data0909 =  data09_r16_82;
			data0910 =  data10_r16_61;
			data0911 =  ~data11_r16_46 + 1'b1;
			data0912 =  ~data12_r16_88 + 1'b1;
			data0913 =  ~data13_r16_4 + 1'b1;
			data0914 =  data14_r16_85;
			data0915 =  data15_r16_54;
		end
	else if(dt_vld_16_d)
		begin
			data0900 =  data08_r8_25 ;
			data0901 =  ~data09_r8_70 + 1'b1;
			data0902 =  data10_r8_90;
			data0903 =  ~data11_r8_80 + 1'b1;
			data0904 =  data12_r8_43;
			data0905 =  data13_r8_9;
			data0906 =  ~data14_r8_57 + 1'b1;
			data0907 =  data15_r8_87;
                        data0908 =  25'd0;  
                        data0909 =  25'd0;
                        data0910 =  25'd0;
                        data0911 =  25'd0;
                        data0912 =  25'd0;
                        data0913 =  25'd0;
                        data0914 =  25'd0;
                        data0915 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data0900 =  data08_r4_50;
			data0901 =  ~data09_r4_89 + 1'b1;
			data0902 =  data10_r4_18;
			data0903 =  data11_r4_75;
                        data0904 =  25'd0;         
                        data0905 =  25'd0;
                        data0906 =  25'd0;
                        data0907 =  25'd0;
                        data0908 =  25'd0; 
                        data0909 =  25'd0;
                        data0910 =  25'd0;
                        data0911 =  25'd0;
                        data0912 =  25'd0;
                        data0913 =  25'd0;
                        data0914 =  25'd0;
                        data0915 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data0900 =  data08_a4_64;
			data0901 =  data09_a4_36;
			data0902 =  ~data10_a4_64 + 1'b1;
			data0903 =  ~data11_a4_83 + 1'b1;
			data0904 =  25'd0;
			data0905 =  25'd0;
			data0906 =  25'd0;
			data0907 =  25'd0;
			data0908 =  25'd0;
			data0909 =  25'd0;
			data0910 =  25'd0;
			data0911 =  25'd0;
			data0912 =  25'd0;
			data0913 =  25'd0;
			data0914 =  25'd0;
			data0915 =  25'd0;
	end	
	else
		begin
			data0900 =   data08_s4_55;
			data0901 =   data09_s4_74;
			data0902 =  ~data10_s4_29 + 1'b1;
			data0903 =  ~data11_s4_84 + 1'b1;
			data0904 =  25'd0;
			data0905 =  25'd0;
			data0906 =  25'd0;
			data0907 =  25'd0;
			data0908 =  25'd0;
			data0909 =  25'd0;
			data0910 =  25'd0;
			data0911 =  25'd0;
			data0912 =  25'd0;
			data0913 =  25'd0;
			data0914 =  25'd0;
			data0915 =  25'd0;
		end
	end
end 

assign data09_0001 = {data0900[24],data0900} + {data0901[24],data0901};
assign data09_0203 = {data0902[24],data0902} + {data0903[24],data0903};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data090_stp0 <= 27'd0;
	else
		data090_stp0 <= {data09_0001[25],data09_0001} + {data09_0203[25],data09_0203};
end 

assign data09_0405 = {data0904[24],data0904} + {data0905[24],data0905};
assign data09_0607 = {data0906[24],data0906} + {data0907[24],data0907};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data091_stp0 <= 27'd0;
	else
		data091_stp0 <= {data09_0405[25],data09_0405} + {data09_0607[25],data09_0607};
end 

assign data09_0809 = {data0908[24],data0908} + {data0909[24],data0909};
assign data09_1011 = {data0910[24],data0910} + {data0911[24],data0911};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data092_stp0 <= 27'd0;
	else
		data092_stp0 <= {data09_0809[25],data09_0809} + {data09_1011[25],data09_1011};
end 

assign data09_1213 = {data0912[24],data0912} + {data0913[24],data0913};
assign data09_1415 = {data0914[24],data0914} + {data0915[24],data0915};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data093_stp0 <= 27'd0;
	else
		data093_stp0 <= {data09_1213[25],data09_1213} + {data09_1415[25],data09_1415};
end
 
assign data0901_stp0 = {data090_stp0[26],data090_stp0} + {data091_stp0[26],data091_stp0};
assign data0923_stp0 = {data092_stp0[26],data092_stp0} + {data093_stp0[26],data093_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data090_stp1 <= 28'd0;
	else
		data090_stp1 <= data0901_stp0 + data0923_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data9 = {data090_stp0[26],data090_stp0};
	else 
		o_data9 = data090_stp1;
end 

//------------------------------------------o_data10--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data1000 =  data00_r16_78;
			data1001 =  data01_r16_4;
			data1002 =  ~data02_r16_82 + 1'b1;
			data1003 =  data03_r16_73;
			data1004 =  data04_r16_13;
			data1005 =  ~data05_r16_85 + 1'b1;
			data1006 =  data06_r16_67;
			data1007 =  data07_r16_22;
			data1008 =  ~data08_r16_88 + 1'b1;
			data1009 =  data09_r16_61;
			data1010 =  data10_r16_31;
			data1011 =  ~data11_r16_90 + 1'b1;
			data1012 =  data12_r16_54;
			data1013 =  data13_r16_38;
			data1014 =  ~data14_r16_90 + 1'b1;
			data1015 =  data15_r16_46;
		end
	else if(dt_vld_16_d)
		begin
			data1000 =  data08_r8_43;
			data1001 =  data09_r8_90;
			data1002 =  data10_r8_57;
			data1003 =  ~data11_r8_25 + 1'b1;
			data1004 =  ~data12_r8_87 + 1'b1;
			data1005 =  ~data13_r8_70 + 1'b1;
			data1006 =  data14_r8_9;
			data1007 =  data15_r8_80;
                        data1008 =  25'd0;  
                        data1009 =  25'd0;
                        data1010 =  25'd0;
                        data1011 =  25'd0;
                        data1012 =  25'd0;
                        data1013 =  25'd0;
                        data1014 =  25'd0;
                        data1015 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data1000 =  data08_r4_75;
			data1001 =  data09_r4_18;
			data1002 =  ~data10_r4_89 + 1'b1;
			data1003 =  data11_r4_50;
                        data1004 =  25'd0;         
                        data1005 =  25'd0;
                        data1006 =  25'd0;
                        data1007 =  25'd0;
                        data1008 =  25'd0; 
                        data1009 =  25'd0;
                        data1010 =  25'd0;
                        data1011 =  25'd0;
                        data1012 =  25'd0;
                        data1013 =  25'd0;
                        data1014 =  25'd0;
                        data1015 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data1000 =  data08_a4_64;
			data1001 =  ~data09_a4_64 + 1'b1;
			data1002 =  ~data10_a4_64 + 1'b1;
			data1003 =  data11_a4_64;
			data1004 =  25'd0;
			data1005 =  25'd0;
			data1006 =  25'd0;
			data1007 =  25'd0;
			data1008 =  25'd0;
			data1009 =  25'd0;
			data1010 =  25'd0;
			data1011 =  25'd0;
			data1012 =  25'd0;
			data1013 =  25'd0;
			data1014 =  25'd0;
			data1015 =  25'd0;
	end	
	else
		begin
			data1000 =   data08_s4_84;
			data1001 =  ~data09_s4_29 + 1'b1;
			data1002 =  ~data10_s4_74 + 1'b1;
			data1003 =   data11_s4_55;
			data1004 =  25'd0;
			data1005 =  25'd0;
			data1006 =  25'd0;
			data1007 =  25'd0;
			data1008 =  25'd0;
			data1009 =  25'd0;
			data1010 =  25'd0;
			data1011 =  25'd0;
			data1012 =  25'd0;
			data1013 =  25'd0;
			data1014 =  25'd0;
			data1015 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data1000 =  data00_r16_78;
			data1001 =  ~data01_r16_4 + 1'b1;
			data1002 =  ~data02_r16_82 + 1'b1;
			data1003 =  ~data03_r16_73 + 1'b1;
			data1004 =  data04_r16_13;
			data1005 =  data05_r16_85;
			data1006 =  data06_r16_67;
			data1007 =  ~data07_r16_22 + 1'b1;
			data1008 =  ~data08_r16_88 + 1'b1;
			data1009 =  ~data09_r16_61 + 1'b1;
			data1010 =  data10_r16_31;
			data1011 =  data11_r16_90;
			data1012 =  data12_r16_54;
			data1013 =  ~data13_r16_38 + 1'b1;
			data1014 =  ~data14_r16_90 + 1'b1;
			data1015 =  ~data15_r16_46 + 1'b1;
		end
	else if(dt_vld_16_d)
		begin
			data1000 =  data08_r8_43 ;
			data1001 =  ~data09_r8_90 + 1'b1;
			data1002 =  data10_r8_57;
			data1003 =  data11_r8_25;
			data1004 =  ~data12_r8_87 + 1'b1;
			data1005 =  data13_r8_70;
			data1006 =  data14_r8_9;
			data1007 =  ~data15_r8_80 + 1'b1;
                        data1008 =  25'd0;  
                        data1009 =  25'd0;
                        data1010 =  25'd0;
                        data1011 =  25'd0;
                        data1012 =  25'd0;
                        data1013 =  25'd0;
                        data1014 =  25'd0;
                        data1015 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data1000 =  data08_r4_75;
			data1001 =  ~data09_r4_18 + 1'b1;
			data1002 =  ~data10_r4_89 + 1'b1;
			data1003 =  ~data11_r4_50 + 1'b1;
                        data1004 =  25'd0;         
                        data1005 =  25'd0;
                        data1006 =  25'd0;
                        data1007 =  25'd0;
                        data1008 =  25'd0; 
                        data1009 =  25'd0;
                        data1010 =  25'd0;
                        data1011 =  25'd0;
                        data1012 =  25'd0;
                        data1013 =  25'd0;
                        data1014 =  25'd0;
                        data1015 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data1000 =  data08_a4_64;
			data1001 =  ~data09_a4_36 + 1'b1;
			data1002 =  ~data10_a4_64 + 1'b1;
			data1003 =  data11_a4_83;
			data1004 =  25'd0;
			data1005 =  25'd0;
			data1006 =  25'd0;
			data1007 =  25'd0;
			data1008 =  25'd0;
			data1009 =  25'd0;
			data1010 =  25'd0;
			data1011 =  25'd0;
			data1012 =  25'd0;
			data1013 =  25'd0;
			data1014 =  25'd0;
			data1015 =  25'd0;
	end	
	else
		begin
			data1000 =   data08_s4_74;
			data1001 =  25'd0;
			data1002 =  ~data10_s4_74 + 1'b1;
			data1003 =   data11_s4_74;
			data1004 =  25'd0;
			data1005 =  25'd0;
			data1006 =  25'd0;
			data1007 =  25'd0;
			data1008 =  25'd0;
			data1009 =  25'd0;
			data1010 =  25'd0;
			data1011 =  25'd0;
			data1012 =  25'd0;
			data1013 =  25'd0;
			data1014 =  25'd0;
			data1015 =  25'd0;
		end
	end
end 

assign data10_0001 = {data1000[24],data1000} + {data1001[24],data1001};
assign data10_0203 = {data1002[24],data1002} + {data1003[24],data1003};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data100_stp0 <= 27'd0;
	else
		data100_stp0 <= {data10_0001[25],data10_0001} + {data10_0203[25],data10_0203};
end 

assign data10_0405 = {data1004[24],data1004} + {data1005[24],data1005};
assign data10_0607 = {data1006[24],data1006} + {data1007[24],data1007};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data101_stp0 <= 27'd0;
	else
		data101_stp0 <= {data10_0405[25],data10_0405} + {data10_0607[25],data10_0607};
end 

assign data10_0809 = {data1008[24],data1008} + {data1009[24],data1009};
assign data10_1011 = {data1010[24],data1010} + {data1011[24],data1011};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data102_stp0 <= 27'd0;
	else
		data102_stp0 <= {data10_0809[25],data10_0809} + {data10_1011[25],data10_1011};
end 

assign data10_1213 = {data1012[24],data1012} + {data1013[24],data1013};
assign data10_1415 = {data1014[24],data1014} + {data1015[24],data1015};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data103_stp0 <= 27'd0;
	else
		data103_stp0 <= {data10_1213[25],data10_1213} + {data10_1415[25],data10_1415};
end
 
assign data1001_stp0 = {data100_stp0[26],data100_stp0} + {data101_stp0[26],data101_stp0};
assign data1023_stp0 = {data102_stp0[26],data102_stp0} + {data103_stp0[26],data103_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data100_stp1 <= 28'd0;
	else
		data100_stp1 <= data1001_stp0 + data1023_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data10 = {data100_stp0[26],data100_stp0};
	else 
		o_data10 = data100_stp1;
end 

//------------------------------------------o_data11--------------------------------------------------------//
always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data1100 =  ~data00_r16_82 + 1'b1;
			data1101 =  data01_r16_22;
			data1102 =  data02_r16_54;
			data1103 =  ~data03_r16_90 + 1'b1;
			data1104 =  data04_r16_61;
			data1105 =  data05_r16_13;
			data1106 =  ~data06_r16_78 + 1'b1;
			data1107 =  data07_r16_85;
			data1108 =  ~data08_r16_31 + 1'b1;
			data1109 =  ~data09_r16_46 + 1'b1;
			data1110 =  data10_r16_90;
			data1111 =  ~data11_r16_67 + 1'b1;
			data1112 =  ~data12_r16_4 + 1'b1;
			data1113 =  data13_r16_73;
			data1114 =  ~data14_r16_88 + 1'b1;
			data1115 =  data15_r16_38;
		end
	else if(dt_vld_16_d)
		begin
			data1100 =  ~data08_r8_57 + 1'b1;
			data1101 =  ~data09_r8_80 + 1'b1;
			data1102 =  data10_r8_25;
			data1103 =  data11_r8_90;
			data1104 =  data12_r8_9;
			data1105 =  ~data13_r8_87 + 1'b1;
			data1106 =  ~data14_r8_43 + 1'b1;
			data1107 =  data15_r8_70;
                        data1108 =  25'd0;  
                        data1109 =  25'd0;
                        data1110 =  25'd0;
                        data1111 =  25'd0;
                        data1112 =  25'd0;
                        data1113 =  25'd0;
                        data1114 =  25'd0;
                        data1115 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data1100 =  ~data08_r4_89 + 1'b1;
			data1101 =  data09_r4_75;
			data1102 =  ~data10_r4_50 + 1'b1;
			data1103 =  data11_r4_18;
                        data1104 =  25'd0;         
                        data1105 =  25'd0;
                        data1106 =  25'd0;
                        data1107 =  25'd0;
                        data1108 =  25'd0; 
                        data1109 =  25'd0;
                        data1110 =  25'd0;
                        data1111 =  25'd0;
                        data1112 =  25'd0;
                        data1113 =  25'd0;
                        data1114 =  25'd0;
                        data1115 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data1100 =  data08_a4_36;
			data1101 =  ~data09_a4_83 + 1'b1;
			data1102 =  data10_a4_83;
			data1103 =  ~data11_a4_36 + 1'b1;
			data1104 =  25'd0;
			data1105 =  25'd0;
			data1106 =  25'd0;
			data1107 =  25'd0;
			data1108 =  25'd0;
			data1109 =  25'd0;
			data1110 =  25'd0;
			data1111 =  25'd0;
			data1112 =  25'd0;
			data1113 =  25'd0;
			data1114 =  25'd0;
			data1115 =  25'd0;
	end	
	else
		begin
			data1100 =   data08_s4_55;
			data1101 =  ~data09_s4_84 + 1'b1;
			data1102 =   data10_s4_74;
			data1103 =  ~data11_s4_29 + 1'b1;
			data1104 =  25'd0;
			data1105 =  25'd0;
			data1106 =  25'd0;
			data1107 =  25'd0;
			data1108 =  25'd0;
			data1109 =  25'd0;
			data1110 =  25'd0;
			data1111 =  25'd0;
			data1112 =  25'd0;
			data1113 =  25'd0;
			data1114 =  25'd0;
			data1115 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data1100 =  data00_r16_82;
			data1101 =  data01_r16_22;
			data1102 =  ~data02_r16_54 + 1'b1;
			data1103 =  ~data03_r16_90 + 1'b1;
			data1104 =  ~data04_r16_61 + 1'b1;
			data1105 =  data05_r16_13;
			data1106 =  data06_r16_78;
			data1107 =  data07_r16_85;
			data1108 =  data08_r16_31;
			data1109 =  ~data09_r16_46 + 1'b1;
			data1110 =  ~data10_r16_90 + 1'b1;
			data1111 =  ~data11_r16_67 + 1'b1;
			data1112 =  data12_r16_4;
			data1113 =  data13_r16_73;
			data1114 =  data14_r16_88;
			data1115 =  data15_r16_38;
		end
	else if(dt_vld_16_d)
		begin
			data1100 =  data08_r8_57 ;
			data1101 =  ~data09_r8_80 + 1'b1;
			data1102 =  ~data10_r8_25 + 1'b1;
			data1103 =  data11_r8_90;
			data1104 =  ~data12_r8_9 + 1'b1;
			data1105 =  ~data13_r8_87 + 1'b1;
			data1106 =  data14_r8_43;
			data1107 =  data15_r8_70;
                        data1108 =  25'd0;  
                        data1109 =  25'd0;
                        data1110 =  25'd0;
                        data1111 =  25'd0;
                        data1112 =  25'd0;
                        data1113 =  25'd0;
                        data1114 =  25'd0;
                        data1115 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data1100 =  data08_r4_89;
			data1101 =  data09_r4_75;
			data1102 =  data10_r4_50;
			data1103 =  data11_r4_18;
                        data1104 =  25'd0;         
                        data1105 =  25'd0;
                        data1106 =  25'd0;
                        data1107 =  25'd0;
                        data1108 =  25'd0; 
                        data1109 =  25'd0;
                        data1110 =  25'd0;
                        data1111 =  25'd0;
                        data1112 =  25'd0;
                        data1113 =  25'd0;
                        data1114 =  25'd0;
                        data1115 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data1100 =   data08_a4_64;
			data1101 =  ~data09_a4_83 + 1'b1;
			data1102 =   data10_a4_64;
			data1103 =  ~data11_a4_36 + 1'b1;
			data1104 =  25'd0;
			data1105 =  25'd0;
			data1106 =  25'd0;
			data1107 =  25'd0;
			data1108 =  25'd0;
			data1109 =  25'd0;
			data1110 =  25'd0;
			data1111 =  25'd0;
			data1112 =  25'd0;
			data1113 =  25'd0;
			data1114 =  25'd0;
			data1115 =  25'd0;
	end	
	else
		begin
			data1100 =   data08_s4_84;
			data1101 =  ~data09_s4_74 + 1'b1;
			data1102 =   data10_s4_55;
			data1103 =  ~data11_s4_29 + 1'b1;
			data1104 =  25'd0;
			data1105 =  25'd0;
			data1106 =  25'd0;
			data1107 =  25'd0;
			data1108 =  25'd0;
			data1109 =  25'd0;
			data1110 =  25'd0;
			data1111 =  25'd0;
			data1112 =  25'd0;
			data1113 =  25'd0;
			data1114 =  25'd0;
			data1115 =  25'd0;
		end
	end
end 

assign data11_0001 = {data1100[24],data1100} + {data1101[24],data1101};
assign data11_0203 = {data1102[24],data1102} + {data1103[24],data1103};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data110_stp0 <= 27'd0;
	else
		data110_stp0 <= {data11_0001[25],data11_0001} + {data11_0203[25],data11_0203};
end 

assign data11_0405 = {data1104[24],data1104} + {data1105[24],data1105};
assign data11_0607 = {data1106[24],data1106} + {data1107[24],data1107};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data111_stp0 <= 27'd0;
	else
		data111_stp0 <= {data11_0405[25],data11_0405} + {data11_0607[25],data11_0607};
end 

assign data11_0809 = {data1108[24],data1108} + {data1109[24],data1109};
assign data11_1011 = {data1110[24],data1110} + {data1111[24],data1111};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data112_stp0 <= 27'd0;
	else
		data112_stp0 <= {data11_0809[25],data11_0809} + {data11_1011[25],data11_1011};
end 

assign data11_1213 = {data1112[24],data1112} + {data1113[24],data1113};
assign data11_1415 = {data1114[24],data1114} + {data1115[24],data1115};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data113_stp0 <= 27'd0;
	else
		data113_stp0 <= {data11_1213[25],data11_1213} + {data11_1415[25],data11_1415};
end
 
assign data1101_stp0 = {data110_stp0[26],data110_stp0} + {data111_stp0[26],data111_stp0};
assign data1123_stp0 = {data112_stp0[26],data112_stp0} + {data113_stp0[26],data113_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data110_stp1 <= 28'd0;
	else
		data110_stp1 <= data1101_stp0 + data1123_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data11 = {data110_stp0[26],data110_stp0};
	else 
		o_data11 = data110_stp1;
end 

//------------------------------------------o_data12--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data1200 =  data00_r16_85;
			data1201 =  ~data01_r16_46 + 1'b1;
			data1202 =  ~data02_r16_13 + 1'b1;
			data1203 =  data03_r16_67;
			data1204 =  ~data04_r16_90 + 1'b1;
			data1205 =  data05_r16_73;
			data1206 =  ~data06_r16_22 + 1'b1;
			data1207 =  ~data07_r16_38 + 1'b1;
			data1208 =  data08_r16_82;
			data1209 =  ~data09_r16_88 + 1'b1;
			data1210 =  data10_r16_54;
			data1211 =  data11_r16_4;
			data1212 =  ~data12_r16_61 + 1'b1;
			data1213 =  data13_r16_90;
			data1214 =  ~data14_r16_78 + 1'b1;
			data1215 =  data15_r16_31;
		end
	else if(dt_vld_16_d)
		begin
			data1200 =  data08_r8_70;
			data1201 =  data09_r8_43;
			data1202 =  ~data10_r8_87 + 1'b1;
			data1203 =  ~data11_r8_9 + 1'b1;
			data1204 =  data12_r8_90;
			data1205 =  ~data13_r8_25 + 1'b1;
			data1206 =  ~data14_r8_80 + 1'b1;
			data1207 =  data15_r8_57;
                        data1208 =  25'd0;  
                        data1209 =  25'd0;
                        data1210 =  25'd0;
                        data1211 =  25'd0;
                        data1212 =  25'd0;
                        data1213 =  25'd0;
                        data1214 =  25'd0;
                        data1215 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data1200 =  data12_r4_18;
			data1201 =  data13_r4_50;
			data1202 =  data14_r4_75;
			data1203 =  data15_r4_89;
                        data1204 =  25'd0;         
                        data1205 =  25'd0;
                        data1206 =  25'd0;
                        data1207 =  25'd0;
                        data1208 =  25'd0; 
                        data1209 =  25'd0;
                        data1210 =  25'd0;
                        data1211 =  25'd0;
                        data1212 =  25'd0;
                        data1213 =  25'd0;
                        data1214 =  25'd0;
                        data1215 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data1200 =  data12_a4_64;
			data1201 =  data13_a4_64;
			data1202 =  data14_a4_64;
			data1203 =  data15_a4_64;
			data1204 =  25'd0;
			data1205 =  25'd0;
			data1206 =  25'd0;
			data1207 =  25'd0;
			data1208 =  25'd0;
			data1209 =  25'd0;
			data1210 =  25'd0;
			data1211 =  25'd0;
			data1212 =  25'd0;
			data1213 =  25'd0;
			data1214 =  25'd0;
			data1215 =  25'd0;
	end	
	else
		begin
			data1200 =  data12_s4_29;
			data1201 =  data13_s4_55;
			data1202 =  data14_s4_74;
			data1203 =  data15_s4_84;
			data1204 =  25'd0;
			data1205 =  25'd0;
			data1206 =  25'd0;
			data1207 =  25'd0;
			data1208 =  25'd0;
			data1209 =  25'd0;
			data1210 =  25'd0;
			data1211 =  25'd0;
			data1212 =  25'd0;
			data1213 =  25'd0;
			data1214 =  25'd0;
			data1215 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data1200 =  data00_r16_85;
			data1201 =  data01_r16_46;
			data1202 =  ~data02_r16_13 + 1'b1;
			data1203 =  ~data03_r16_67 + 1'b1;
			data1204 =  ~data04_r16_90 + 1'b1;
			data1205 =  ~data05_r16_73 + 1'b1;
			data1206 =  ~data06_r16_22 + 1'b1;
			data1207 =  data07_r16_38;
			data1208 =  data08_r16_82;
			data1209 =  data09_r16_88;
			data1210 =  data10_r16_54;
			data1211 =  ~data11_r16_4 + 1'b1;
			data1212 =  ~data12_r16_61 + 1'b1;
			data1213 =  ~data13_r16_90 + 1'b1;
			data1214 =  ~data14_r16_78 + 1'b1;
			data1215 =  ~data15_r16_31 + 1'b1;
		end
	else if(dt_vld_16_d)
		begin
			data1200 =  data08_r8_70 ;
			data1201 =  ~data09_r8_43 + 1'b1;
			data1202 =  ~data10_r8_87 + 1'b1;
			data1203 =  data11_r8_9;
			data1204 =  data12_r8_90;
			data1205 =  data13_r8_25;
			data1206 =  ~data14_r8_80 + 1'b1;
			data1207 =  ~data15_r8_57 + 1'b1;
                        data1208 =  25'd0;  
                        data1209 =  25'd0;
                        data1210 =  25'd0;
                        data1211 =  25'd0;
                        data1212 =  25'd0;
                        data1213 =  25'd0;
                        data1214 =  25'd0;
                        data1215 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data1200 =  data12_r4_18;
			data1201 =  ~data13_r4_50 + 1'b1;
			data1202 =  data14_r4_75;
			data1203 =  ~data15_r4_89 + 1'b1;
                        data1204 =  25'd0;         
                        data1205 =  25'd0;
                        data1206 =  25'd0;
                        data1207 =  25'd0;
                        data1208 =  25'd0; 
                        data1209 =  25'd0;
                        data1210 =  25'd0;
                        data1211 =  25'd0;
                        data1212 =  25'd0;
                        data1213 =  25'd0;
                        data1214 =  25'd0;
                        data1215 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data1200 =  data12_a4_64;
			data1201 =  data13_a4_83;
			data1202 =  data14_a4_64;
			data1203 =  data15_a4_36;
			data1204 =  25'd0;
			data1205 =  25'd0;
			data1206 =  25'd0;
			data1207 =  25'd0;
			data1208 =  25'd0;
			data1209 =  25'd0;
			data1210 =  25'd0;
			data1211 =  25'd0;
			data1212 =  25'd0;
			data1213 =  25'd0;
			data1214 =  25'd0;
			data1215 =  25'd0;
	end	
	else
		begin
			data1200 =  data12_s4_29;
			data1201 =  data13_s4_74;
			data1202 =  data14_s4_84;
			data1203 =  data15_s4_55;
			data1204 =  25'd0;
			data1205 =  25'd0;
			data1206 =  25'd0;
			data1207 =  25'd0;
			data1208 =  25'd0;
			data1209 =  25'd0;
			data1210 =  25'd0;
			data1211 =  25'd0;
			data1212 =  25'd0;
			data1213 =  25'd0;
			data1214 =  25'd0;
			data1215 =  25'd0;
		end
	end
end 

assign data12_0001 = {data1200[24],data1200} + {data1201[24],data1201};
assign data12_0203 = {data1202[24],data1202} + {data1203[24],data1203};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data120_stp0 <= 27'd0;
	else
		data120_stp0 <= {data12_0001[25],data12_0001} + {data12_0203[25],data12_0203};
end 

assign data12_0405 = {data1204[24],data1204} + {data1205[24],data1205};
assign data12_0607 = {data1206[24],data1206} + {data1207[24],data1207};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data121_stp0 <= 27'd0;
	else
		data121_stp0 <= {data12_0405[25],data12_0405} + {data12_0607[25],data12_0607};
end 

assign data12_0809 = {data1208[24],data1208} + {data1209[24],data1209};
assign data12_1011 = {data1210[24],data1210} + {data1211[24],data1211};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data122_stp0 <= 27'd0;
	else
		data122_stp0 <= {data12_0809[25],data12_0809} + {data12_1011[25],data12_1011};
end 

assign data12_1213 = {data1212[24],data1212} + {data1213[24],data1213};
assign data12_1415 = {data1214[24],data1214} + {data1215[24],data1215};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data123_stp0 <= 27'd0;
	else
		data123_stp0 <= {data12_1213[25],data12_1213} + {data12_1415[25],data12_1415};
end
 
assign data1201_stp0 = {data120_stp0[26],data120_stp0} + {data121_stp0[26],data121_stp0};
assign data1223_stp0 = {data122_stp0[26],data122_stp0} + {data123_stp0[26],data123_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data120_stp1 <= 28'd0;
	else
		data120_stp1 <= data1201_stp0 + data1223_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data12 = {data120_stp0[26],data120_stp0};
	else 
		o_data12 = data120_stp1;
end 

//------------------------------------------o_data13--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data1300 =  ~data00_r16_88 + 1'b1;
			data1301 =  data01_r16_67;
			data1302 =  ~data02_r16_31 + 1'b1;
			data1303 =  ~data03_r16_13 + 1'b1;
			data1304 =  data04_r16_54;
			data1305 =  ~data05_r16_82 + 1'b1;
			data1306 =  data06_r16_90;
			data1307 =  ~data07_r16_78 + 1'b1;
			data1308 =  data08_r16_46;
			data1309 =  ~data09_r16_4 + 1'b1;
			data1310 =  ~data10_r16_38 + 1'b1;
			data1311 =  data11_r16_73;
			data1312 =  ~data12_r16_90 + 1'b1;
			data1313 =  data13_r16_85;
			data1314 =  ~data14_r16_61 + 1'b1;
			data1315 =  data15_r16_22;
		end
	else if(dt_vld_16_d)
		begin
			data1300 =  ~data08_r8_80 + 1'b1;
			data1301 =  data09_r8_9;
			data1302 =  data10_r8_70;
			data1303 =  ~data11_r8_87 + 1'b1;
			data1304 =  data12_r8_25;
			data1305 =  data13_r8_57;
			data1306 =  ~data14_r8_90 + 1'b1;
			data1307 =  data15_r8_43;
                        data1308 =  25'd0;  
                        data1309 =  25'd0;
                        data1310 =  25'd0;
                        data1311 =  25'd0;
                        data1312 =  25'd0;
                        data1313 =  25'd0;
                        data1314 =  25'd0;
                        data1315 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data1300 =  ~data12_r4_50 + 1'b1;
			data1301 =  ~data13_r4_89 + 1'b1;
			data1302 =  ~data14_r4_18 + 1'b1;
			data1303 =  data15_r4_75;
                        data1304 =  25'd0;         
                        data1305 =  25'd0;
                        data1306 =  25'd0;
                        data1307 =  25'd0;
                        data1308 =  25'd0; 
                        data1309 =  25'd0;
                        data1310 =  25'd0;
                        data1311 =  25'd0;
                        data1312 =  25'd0;
                        data1313 =  25'd0;
                        data1314 =  25'd0;
                        data1315 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data1300 =  data12_a4_83;
			data1301 =  data13_a4_36;
			data1302 =  ~data14_a4_36 + 1'b1;
			data1303 =  ~data15_a4_83 + 1'b1;
			data1304 =  25'd0;
			data1305 =  25'd0;
			data1306 =  25'd0;
			data1307 =  25'd0;
			data1308 =  25'd0;
			data1309 =  25'd0;
			data1310 =  25'd0;
			data1311 =  25'd0;
			data1312 =  25'd0;
			data1313 =  25'd0;
			data1314 =  25'd0;
			data1315 =  25'd0;
	end	
	else
		begin
			data1300 =   data12_s4_74;
			data1301 =   data13_s4_74;
			data1302 =  15'd0;
			data1303 =  ~data15_s4_74 + 1'b1;
			data1304 =  25'd0;
			data1305 =  25'd0;
			data1306 =  25'd0;
			data1307 =  25'd0;
			data1308 =  25'd0;
			data1309 =  25'd0;
			data1310 =  25'd0;
			data1311 =  25'd0;
			data1312 =  25'd0;
			data1313 =  25'd0;
			data1314 =  25'd0;
			data1315 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data1300 =  data00_r16_88;
			data1301 =  data01_r16_67;
			data1302 =  data02_r16_31;
			data1303 =  ~data03_r16_13 + 1'b1;
			data1304 =  ~data04_r16_54 + 1'b1;
			data1305 =  ~data05_r16_82 + 1'b1;
			data1306 =  ~data06_r16_90 + 1'b1;
			data1307 =  ~data07_r16_78 + 1'b1;
			data1308 =  ~data08_r16_46 + 1'b1;
			data1309 =  ~data09_r16_4 + 1'b1;
			data1310 =  data10_r16_38;
			data1311 =  data11_r16_73;
			data1312 =  data12_r16_90;
			data1313 =  data13_r16_85;
			data1314 =  data14_r16_61;
			data1315 =  data15_r16_22;
		end
	else if(dt_vld_16_d)
		begin
			data1300 =  data08_r8_80 ;
			data1301 =  data09_r8_9;
			data1302 =  ~data10_r8_70 + 1'b1;
			data1303 =  ~data11_r8_87 + 1'b1;
			data1304 =  ~data12_r8_25 + 1'b1;
			data1305 =  data13_r8_57;
			data1306 =  data14_r8_90;
			data1307 =  data15_r8_43;
                        data1308 =  25'd0;  
                        data1309 =  25'd0;
                        data1310 =  25'd0;
                        data1311 =  25'd0;
                        data1312 =  25'd0;
                        data1313 =  25'd0;
                        data1314 =  25'd0;
                        data1315 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data1300 =  data12_r4_50;
			data1301 =  ~data13_r4_89 + 1'b1;
			data1302 =  data14_r4_18;
			data1303 =  data15_r4_75;
                        data1304 =  25'd0;         
                        data1305 =  25'd0;
                        data1306 =  25'd0;
                        data1307 =  25'd0;
                        data1308 =  25'd0; 
                        data1309 =  25'd0;
                        data1310 =  25'd0;
                        data1311 =  25'd0;
                        data1312 =  25'd0;
                        data1313 =  25'd0;
                        data1314 =  25'd0;
                        data1315 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data1300 =  data12_a4_64;
			data1301 =  data13_a4_36;
			data1302 =  ~data14_a4_64 + 1'b1;
			data1303 =  ~data15_a4_83 + 1'b1;
			data1304 =  25'd0;
			data1305 =  25'd0;
			data1306 =  25'd0;
			data1307 =  25'd0;
			data1308 =  25'd0;
			data1309 =  25'd0;
			data1310 =  25'd0;
			data1311 =  25'd0;
			data1312 =  25'd0;
			data1313 =  25'd0;
			data1314 =  25'd0;
			data1315 =  25'd0;
	end	
	else
		begin
			data1300 =   data12_s4_55;
			data1301 =   data13_s4_74;
			data1302 =  ~data14_s4_29 + 1'b1;
			data1303 =  ~data15_s4_84 + 1'b1;
			data1304 =  25'd0;
			data1305 =  25'd0;
			data1306 =  25'd0;
			data1307 =  25'd0;
			data1308 =  25'd0;
			data1309 =  25'd0;
			data1310 =  25'd0;
			data1311 =  25'd0;
			data1312 =  25'd0;
			data1313 =  25'd0;
			data1314 =  25'd0;
			data1315 =  25'd0;
		end
	end
end 

assign data13_0001 = {data1300[24],data1300} + {data1301[24],data1301};
assign data13_0203 = {data1302[24],data1302} + {data1303[24],data1303};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data130_stp0 <= 27'd0;
	else
		data130_stp0 <= {data13_0001[25],data13_0001} + {data13_0203[25],data13_0203};
end 

assign data13_0405 = {data1304[24],data1304} + {data1305[24],data1305};
assign data13_0607 = {data1306[24],data1306} + {data1307[24],data1307};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data131_stp0 <= 27'd0;
	else
		data131_stp0 <= {data13_0405[25],data13_0405} + {data13_0607[25],data13_0607};
end 

assign data13_0809 = {data1308[24],data1308} + {data1309[24],data1309};
assign data13_1011 = {data1310[24],data1310} + {data1311[24],data1311};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data132_stp0 <= 27'd0;
	else
		data132_stp0 <= {data13_0809[25],data13_0809} + {data13_1011[25],data13_1011};
end 

assign data13_1213 = {data1312[24],data1312} + {data1313[24],data1313};
assign data13_1415 = {data1314[24],data1314} + {data1315[24],data1315};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data133_stp0 <= 27'd0;
	else
		data133_stp0 <= {data13_1213[25],data13_1213} + {data13_1415[25],data13_1415};
end
 
assign data1301_stp0 = {data130_stp0[26],data130_stp0} + {data131_stp0[26],data131_stp0};
assign data1323_stp0 = {data132_stp0[26],data132_stp0} + {data133_stp0[26],data133_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data130_stp1 <= 28'd0;
	else
		data130_stp1 <= data1301_stp0 + data1323_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data13 = {data130_stp0[26],data130_stp0};
	else 
		o_data13 = data130_stp1;
end 

//------------------------------------------o_data14--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data1400 =  data00_r16_90;
			data1401 =  ~data01_r16_82 + 1'b1;
			data1402 =  data02_r16_67;
			data1403 =  ~data03_r16_46 + 1'b1;
			data1404 =  data04_r16_22;
			data1405 =  data05_r16_4;
			data1406 =  ~data06_r16_31 + 1'b1;
			data1407 =  data07_r16_54;
			data1408 =  ~data08_r16_73 + 1'b1;
			data1409 =  data09_r16_85;
			data1410 =  ~data10_r16_90 + 1'b1;
			data1411 =  data11_r16_88;
			data1412 =  ~data12_r16_78 + 1'b1;
			data1413 =  data13_r16_61;
			data1414 =  ~data14_r16_38 + 1'b1;
			data1415 =  data15_r16_13;
		end
	else if(dt_vld_16_d)
		begin
			data1400 =  data08_r8_87;
			data1401 =  ~data09_r8_57 + 1'b1;
			data1402 =  data10_r8_9;
			data1403 =  data11_r8_43;
			data1404 =  ~data12_r8_80 + 1'b1;
			data1405 =  data13_r8_90;
			data1406 =  ~data14_r8_70 + 1'b1;
			data1407 =  data15_r8_25;
                        data1408 =  25'd0;  
                        data1409 =  25'd0;
                        data1410 =  25'd0;
                        data1411 =  25'd0;
                        data1412 =  25'd0;
                        data1413 =  25'd0;
                        data1414 =  25'd0;
                        data1415 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data1400 =  data12_r4_75;
			data1401 =  data13_r4_18;
			data1402 =  ~data14_r4_89 + 1'b1;
			data1403 =  data15_r4_50;
                        data1404 =  25'd0;         
                        data1405 =  25'd0;
                        data1406 =  25'd0;
                        data1407 =  25'd0;
                        data1408 =  25'd0; 
                        data1409 =  25'd0;
                        data1410 =  25'd0;
                        data1411 =  25'd0;
                        data1412 =  25'd0;
                        data1413 =  25'd0;
                        data1414 =  25'd0;
                        data1415 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data1400 =  data12_a4_64;
			data1401 =  ~data13_a4_64 + 1'b1;
			data1402 =  ~data14_a4_64 + 1'b1;
			data1403 =  data15_a4_64;
			data1404 =  25'd0;
			data1405 =  25'd0;
			data1406 =  25'd0;
			data1407 =  25'd0;
			data1408 =  25'd0;
			data1409 =  25'd0;
			data1410 =  25'd0;
			data1411 =  25'd0;
			data1412 =  25'd0;
			data1413 =  25'd0;
			data1414 =  25'd0;
			data1415 =  25'd0;
	end	
	else
		begin
			data1400 =   data12_s4_84;
			data1401 =  ~data13_s4_29 + 1'b1;
			data1402 =  ~data14_s4_74 + 1'b1;
			data1403 =   data15_s4_55;
			data1404 =  25'd0;
			data1405 =  25'd0;
			data1406 =  25'd0;
			data1407 =  25'd0;
			data1408 =  25'd0;
			data1409 =  25'd0;
			data1410 =  25'd0;
			data1411 =  25'd0;
			data1412 =  25'd0;
			data1413 =  25'd0;
			data1414 =  25'd0;
			data1415 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data1400 =  data00_r16_90;
			data1401 =  data01_r16_82;
			data1402 =  data02_r16_67;
			data1403 =  data03_r16_46;
			data1404 =  data04_r16_22;
			data1405 =  ~data05_r16_4 + 1'b1;
			data1406 =  ~data06_r16_31 + 1'b1;
			data1407 =  ~data07_r16_54 + 1'b1;
			data1408 =  ~data08_r16_73 + 1'b1;
			data1409 =  ~data09_r16_85 + 1'b1;
			data1410 =  ~data10_r16_90 + 1'b1;
			data1411 =  ~data11_r16_88 + 1'b1;
			data1412 =  ~data12_r16_78 + 1'b1;
			data1413 =  ~data13_r16_61 + 1'b1;
			data1414 =  ~data14_r16_38 + 1'b1;
			data1415 =  ~data15_r16_13 + 1'b1;
		end
	else if(dt_vld_16_d)
		begin
			data1400 =  data08_r8_87 ;
			data1401 =  data09_r8_57;
			data1402 =  data10_r8_9;
			data1403 =  ~data11_r8_43 + 1'b1;
			data1404 =  ~data12_r8_80 + 1'b1;
			data1405 =  ~data13_r8_90 + 1'b1;
			data1406 =  ~data14_r8_70 + 1'b1;
			data1407 =  ~data15_r8_25 + 1'b1;
                        data1408 =  25'd0;  
                        data1409 =  25'd0;
                        data1410 =  25'd0;
                        data1411 =  25'd0;
                        data1412 =  25'd0;
                        data1413 =  25'd0;
                        data1414 =  25'd0;
                        data1415 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data1400 =  data12_r4_75;
			data1401 =  ~data13_r4_18 + 1'b1;
			data1402 =  ~data14_r4_89 + 1'b1;
			data1403 =  ~data15_r4_50 + 1'b1;
                        data1404 =  25'd0;         
                        data1405 =  25'd0;
                        data1406 =  25'd0;
                        data1407 =  25'd0;
                        data1408 =  25'd0; 
                        data1409 =  25'd0;
                        data1410 =  25'd0;
                        data1411 =  25'd0;
                        data1412 =  25'd0;
                        data1413 =  25'd0;
                        data1414 =  25'd0;
                        data1415 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data1400 =  data12_a4_64;
			data1401 =  ~data13_a4_36 + 1'b1;
			data1402 =  ~data14_a4_64 + 1'b1;
			data1403 =  data15_a4_83;
			data1404 =  25'd0;
			data1405 =  25'd0;
			data1406 =  25'd0;
			data1407 =  25'd0;
			data1408 =  25'd0;
			data1409 =  25'd0;
			data1410 =  25'd0;
			data1411 =  25'd0;
			data1412 =  25'd0;
			data1413 =  25'd0;
			data1414 =  25'd0;
			data1415 =  25'd0;
	end	
	else
		begin
			data1400 =   data12_s4_74;
			data1401 =  25'd0;
			data1402 =  ~data14_s4_74 + 1'b1;
			data1403 =   data15_s4_74;
			data1404 =  25'd0;
			data1405 =  25'd0;
			data1406 =  25'd0;
			data1407 =  25'd0;
			data1408 =  25'd0;
			data1409 =  25'd0;
			data1410 =  25'd0;
			data1411 =  25'd0;
			data1412 =  25'd0;
			data1413 =  25'd0;
			data1414 =  25'd0;
			data1415 =  25'd0;
		end
	end
end 

assign data14_0001 = {data1400[24],data1400} + {data1401[24],data1401};
assign data14_0203 = {data1402[24],data1402} + {data1403[24],data1403};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data140_stp0 <= 27'd0;
	else
		data140_stp0 <= {data14_0001[25],data14_0001} + {data14_0203[25],data14_0203};
end 

assign data14_0405 = {data1404[24],data1404} + {data1405[24],data1405};
assign data14_0607 = {data1406[24],data1406} + {data1407[24],data1407};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data141_stp0 <= 27'd0;
	else
		data141_stp0 <= {data14_0405[25],data14_0405} + {data14_0607[25],data14_0607};
end 

assign data14_0809 = {data1408[24],data1408} + {data1409[24],data1409};
assign data14_1011 = {data1410[24],data1410} + {data1411[24],data1411};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data142_stp0 <= 27'd0;
	else
		data142_stp0 <= {data14_0809[25],data14_0809} + {data14_1011[25],data14_1011};
end 

assign data14_1213 = {data1412[24],data1412} + {data1413[24],data1413};
assign data14_1415 = {data1414[24],data1414} + {data1415[24],data1415};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data143_stp0 <= 27'd0;
	else
		data143_stp0 <= {data14_1213[25],data14_1213} + {data14_1415[25],data14_1415};
end
 
assign data1401_stp0 = {data140_stp0[26],data140_stp0} + {data141_stp0[26],data141_stp0};
assign data1423_stp0 = {data142_stp0[26],data142_stp0} + {data143_stp0[26],data143_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data140_stp1 <= 28'd0;
	else
		data140_stp1 <= data1401_stp0 + data1423_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data14 = {data140_stp0[26],data140_stp0};
	else 
		o_data14 = data140_stp1;
end 

//------------------------------------------o_data15--------------------------------------------------------//

always @(*)
begin
	if(~i_inverse)
	begin
	if(dt_vld_32_d)
		begin
			data1500 =  ~data00_r16_90 + 1'b1;
			data1501 =  data01_r16_90;
			data1502 =  ~data02_r16_88 + 1'b1;
			data1503 =  data03_r16_85;
			data1504 =  ~data04_r16_82 + 1'b1;
			data1505 =  data05_r16_78;
			data1506 =  ~data06_r16_73 + 1'b1;
			data1507 =  data07_r16_67;
			data1508 =  ~data08_r16_61 + 1'b1;
			data1509 =  data09_r16_54;
			data1510 =  ~data10_r16_46 + 1'b1;
			data1511 =  data11_r16_38;
			data1512 =  ~data12_r16_31 + 1'b1;
			data1513 =  data13_r16_22;
			data1514 =  ~data14_r16_13 + 1'b1;
			data1515 =  data15_r16_4;
		end
	else if(dt_vld_16_d)
		begin
			data1500 =  ~data08_r8_90 + 1'b1;
			data1501 =  data09_r8_87;
			data1502 =  ~data10_r8_80 + 1'b1;
			data1503 =  data11_r8_70;
			data1504 =  ~data12_r8_57 + 1'b1;
			data1505 =  data13_r8_43;
			data1506 =  ~data14_r8_25 + 1'b1;
			data1507 =  data15_r8_9;
                        data1508 =  25'd0;  
                        data1509 =  25'd0;
                        data1510 =  25'd0;
                        data1511 =  25'd0;
                        data1512 =  25'd0;
                        data1513 =  25'd0;
                        data1514 =  25'd0;
                        data1515 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data1500 =  ~data12_r4_89 + 1'b1;
			data1501 =  data13_r4_75;
			data1502 =  ~data14_r4_50 + 1'b1;
			data1503 =  data15_r4_18;
                        data1504 =  25'd0;         
                        data1505 =  25'd0;
                        data1506 =  25'd0;
                        data1507 =  25'd0;
                        data1508 =  25'd0; 
                        data1509 =  25'd0;
                        data1510 =  25'd0;
                        data1511 =  25'd0;
                        data1512 =  25'd0;
                        data1513 =  25'd0;
                        data1514 =  25'd0;
                        data1515 =  25'd0;
		end
	else if(dt_vld_4_d[0])
	begin
			data1500 =  data12_a4_36;
			data1501 =  ~data13_a4_83 + 1'b1;
			data1502 =  data14_a4_83;
			data1503 =  ~data15_a4_36 + 1'b1;
			data1504 =  25'd0;
			data1505 =  25'd0;
			data1506 =  25'd0;
			data1507 =  25'd0;
			data1508 =  25'd0;
			data1509 =  25'd0;
			data1510 =  25'd0;
			data1511 =  25'd0;
			data1512 =  25'd0;
			data1513 =  25'd0;
			data1514 =  25'd0;
			data1515 =  25'd0;
	end	
	else
		begin
			data1500 =   data12_s4_55;
			data1501 =  ~data13_s4_84 + 1'b1;
			data1502 =   data14_s4_74;
			data1503 =  ~data15_s4_29 + 1'b1;
			data1504 =  25'd0;
			data1505 =  25'd0;
			data1506 =  25'd0;
			data1507 =  25'd0;
			data1508 =  25'd0;
			data1509 =  25'd0;
			data1510 =  25'd0;
			data1511 =  25'd0;
			data1512 =  25'd0;
			data1513 =  25'd0;
			data1514 =  25'd0;
			data1515 =  25'd0;
		end
	end
	else
	begin
	if(dt_vld_32_d)
		begin
			data1500 =  data00_r16_90;
			data1501 =  data01_r16_90;
			data1502 =  data02_r16_88;
			data1503 =  data03_r16_85;
			data1504 =  data04_r16_82;
			data1505 =  data05_r16_78; 
			data1506 =  data06_r16_73;
			data1507 =  data07_r16_67;
			data1508 =  data08_r16_61;
			data1509 =  data09_r16_54;
			data1510 =  data10_r16_46;
			data1511 =  data11_r16_38;
			data1512 =  data12_r16_31;
			data1513 =  data13_r16_22;
			data1514 =  data14_r16_13;
			data1515 =  data15_r16_4;
		end
	else if(dt_vld_16_d)
		begin
			data1500 =  data08_r8_90 ;
			data1501 =  data09_r8_87;
			data1502 =  data10_r8_80;
			data1503 =  data11_r8_70;
			data1504 =  data12_r8_57;
			data1505 =  data13_r8_43;
			data1506 =  data14_r8_25;
			data1507 =  data15_r8_9;
                        data1508 =  25'd0;  
                        data1509 =  25'd0;
                        data1510 =  25'd0;
                        data1511 =  25'd0;
                        data1512 =  25'd0;
                        data1513 =  25'd0;
                        data1514 =  25'd0;
                        data1515 =  25'd0;
		end
	else if(dt_vld_8_d[0])
		begin
			data1500 =  data12_r4_89;
			data1501 =  data13_r4_75;
			data1502 =  data14_r4_50;
			data1503 =  data15_r4_18;
                        data1504 =  25'd0;         
                        data1505 =  25'd0;
                        data1506 =  25'd0;
                        data1507 =  25'd0;
                        data1508 =  25'd0; 
                        data1509 =  25'd0;
                        data1510 =  25'd0;
                        data1511 =  25'd0;
                        data1512 =  25'd0;
                        data1513 =  25'd0;
                        data1514 =  25'd0;
                        data1515 =  25'd0;
		end	
	else if(dt_vld_4_d[0])
	begin
			data1500 =  data12_a4_64;
			data1501 =  ~data13_a4_83 + 1'b1;
			data1502 =  data14_a4_64;
			data1503 =  ~data15_a4_36 + 1'b1;
			data1504 =  25'd0;
			data1505 =  25'd0;
			data1506 =  25'd0;
			data1507 =  25'd0;
			data1508 =  25'd0;
			data1509 =  25'd0;
			data1510 =  25'd0;
			data1511 =  25'd0;
			data1512 =  25'd0;
			data1513 =  25'd0;
			data1514 =  25'd0;
			data1515 =  25'd0;
	end	
	else
		begin
			data1500 =   data12_s4_84;
			data1501 =  ~data13_s4_74 + 1'b1;
			data1502 =   data14_s4_55;
			data1503 =  ~data15_s4_29 + 1'b1;
			data1504 =  25'd0;
			data1505 =  25'd0;
			data1506 =  25'd0;
			data1507 =  25'd0;
			data1508 =  25'd0;
			data1509 =  25'd0;
			data1510 =  25'd0;
			data1511 =  25'd0;
			data1512 =  25'd0;
			data1513 =  25'd0;
			data1514 =  25'd0;
			data1515 =  25'd0;
		end
	end
end 

assign data15_0001 = {data1500[24],data1500} + {data1501[24],data1501};
assign data15_0203 = {data1502[24],data1502} + {data1503[24],data1503};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data150_stp0 <= 27'd0;
	else
		data150_stp0 <= {data15_0001[25],data15_0001} + {data15_0203[25],data15_0203};
end 

assign data15_0405 = {data1504[24],data1504} + {data1505[24],data1505};
assign data15_0607 = {data1506[24],data1506} + {data1507[24],data1507};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data151_stp0 <= 27'd0;
	else
		data151_stp0 <= {data15_0405[25],data15_0405} + {data15_0607[25],data15_0607};
end 

assign data15_0809 = {data1508[24],data1508} + {data1509[24],data1509};
assign data15_1011 = {data1510[24],data1510} + {data1511[24],data1511};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data152_stp0 <= 27'd0;
	else
		data152_stp0 <= {data15_0809[25],data15_0809} + {data15_1011[25],data15_1011};
end 

assign data15_1213 = {data1512[24],data1512} + {data1513[24],data1513};
assign data15_1415 = {data1514[24],data1514} + {data1515[24],data1515};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data153_stp0 <= 27'd0;
	else
		data153_stp0 <= {data15_1213[25],data15_1213} + {data15_1415[25],data15_1415};
end
 
assign data1501_stp0 = {data150_stp0[26],data150_stp0} + {data151_stp0[26],data151_stp0};
assign data1523_stp0 = {data152_stp0[26],data152_stp0} + {data153_stp0[26],data153_stp0};

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data150_stp1 <= 28'd0;
	else
		data150_stp1 <= data1501_stp0 + data1523_stp0;
end

always @(*)
begin
	if(dt_vld_8_d[1] || dt_vld_dst_d[1] || dt_vld_4_d[1])
		o_data15 = {data150_stp0[26],data150_stp0};
	else 
		o_data15 = data150_stp1;
end 
//--------------------------------------------------------------------------------------------//
//-------------------------------------------------------------//
re_level0_cal   u00_level0_cal(
	.clk            (clk         ),
	.rst_n          (rst_n       ),
	.i_dt_vld32    (i_dt_vld_32 ),//data valid
	.i_dt_vld16    (i_dt_vld_16 ),//data valid
	.i_dt_vld8     (i_dt_vld_8  ),//data valid
	.i_dt_vld4      (i_dt_vld_4  ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data0    ),
//--------r16--------//
        .o_data_r16_4   (data00_r16_4 ),   
        .o_data_r16_13  (data00_r16_13),
        .o_data_r16_22  (data00_r16_22),
        .o_data_r16_31  (data00_r16_31),
        .o_data_r16_38  (data00_r16_38),
        .o_data_r16_46  (data00_r16_46),
        .o_data_r16_54  (data00_r16_54),
        .o_data_r16_61  (data00_r16_61),
        .o_data_r16_67  (data00_r16_67),
        .o_data_r16_73  (data00_r16_73),
        .o_data_r16_78  (data00_r16_78),
        .o_data_r16_82  (data00_r16_82),
        .o_data_r16_85  (data00_r16_85),
        .o_data_r16_88  (data00_r16_88),
        .o_data_r16_90  (data00_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data00_r8_9  ),    
        .o_data_r8_25   (data00_r8_25 ),
        .o_data_r8_43   (data00_r8_43 ),
        .o_data_r8_57   (data00_r8_57 ),
        .o_data_r8_70   (data00_r8_70 ),
        .o_data_r8_80   (data00_r8_80 ),
        .o_data_r8_87   (data00_r8_87 ),
        .o_data_r8_90   (data00_r8_90 ),
//-------------r4----------//00
	.o_data_r4_18   (data00_r4_18 ),  
        .o_data_r4_50   (data00_r4_50 ),
        .o_data_r4_75   (data00_r4_75 ),
        .o_data_r4_89   (data00_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data00_a4_64 ),
        .o_data_a4_36   (data00_a4_36 ),
        .o_data_a4_83   (data00_a4_83 ),
//-----------dst4x4--------//00
	.o_data_s4_29   (data00_s4_29 ),   
        .o_data_s4_55   (data00_s4_55 ),
        .o_data_s4_74   (data00_s4_74 ),
        .o_data_s4_84   (data00_s4_84 )
);

re_level0_cal   u01_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data1    ),
//--------r16--------//
        .o_data_r16_4   (data01_r16_4 ),   
        .o_data_r16_13  (data01_r16_13),
        .o_data_r16_22  (data01_r16_22),
        .o_data_r16_31  (data01_r16_31),
        .o_data_r16_38  (data01_r16_38),
        .o_data_r16_46  (data01_r16_46),
        .o_data_r16_54  (data01_r16_54),
        .o_data_r16_61  (data01_r16_61),
        .o_data_r16_67  (data01_r16_67),
        .o_data_r16_73  (data01_r16_73),
        .o_data_r16_78  (data01_r16_78),
        .o_data_r16_82  (data01_r16_82),
        .o_data_r16_85  (data01_r16_85),
        .o_data_r16_88  (data01_r16_88),
        .o_data_r16_90  (data01_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data01_r8_9  ),    
        .o_data_r8_25   (data01_r8_25 ),
        .o_data_r8_43   (data01_r8_43 ),
        .o_data_r8_57   (data01_r8_57 ),
        .o_data_r8_70   (data01_r8_70 ),
        .o_data_r8_80   (data01_r8_80 ),
        .o_data_r8_87   (data01_r8_87 ),
        .o_data_r8_90   (data01_r8_90 ),
//-------------r4----------//01
	.o_data_r4_18   (data01_r4_18 ),  
        .o_data_r4_50   (data01_r4_50 ),
        .o_data_r4_75   (data01_r4_75 ),
        .o_data_r4_89   (data01_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data01_a4_64 ),
        .o_data_a4_36   (data01_a4_36 ),
        .o_data_a4_83   (data01_a4_83 ),
//-----------dst4x4--------//01
	.o_data_s4_29   (data01_s4_29 ),   
        .o_data_s4_55   (data01_s4_55 ),
        .o_data_s4_74   (data01_s4_74 ),
        .o_data_s4_84   (data01_s4_84 )
);

re_level0_cal   u02_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data2    ),
//--------r16--------//
        .o_data_r16_4   (data02_r16_4 ),   
        .o_data_r16_13  (data02_r16_13),
        .o_data_r16_22  (data02_r16_22),
        .o_data_r16_31  (data02_r16_31),
        .o_data_r16_38  (data02_r16_38),
        .o_data_r16_46  (data02_r16_46),
        .o_data_r16_54  (data02_r16_54),
        .o_data_r16_61  (data02_r16_61),
        .o_data_r16_67  (data02_r16_67),
        .o_data_r16_73  (data02_r16_73),
        .o_data_r16_78  (data02_r16_78),
        .o_data_r16_82  (data02_r16_82),
        .o_data_r16_85  (data02_r16_85),
        .o_data_r16_88  (data02_r16_88),
        .o_data_r16_90  (data02_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data02_r8_9  ),    
        .o_data_r8_25   (data02_r8_25 ),
        .o_data_r8_43   (data02_r8_43 ),
        .o_data_r8_57   (data02_r8_57 ),
        .o_data_r8_70   (data02_r8_70 ),
        .o_data_r8_80   (data02_r8_80 ),
        .o_data_r8_87   (data02_r8_87 ),
        .o_data_r8_90   (data02_r8_90 ),
//-------------r4----------//02
	.o_data_r4_18   (data02_r4_18 ),  
        .o_data_r4_50   (data02_r4_50 ),
        .o_data_r4_75   (data02_r4_75 ),
        .o_data_r4_89   (data02_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data02_a4_64 ),
        .o_data_a4_36   (data02_a4_36 ),
        .o_data_a4_83   (data02_a4_83 ),
//-----------dst4x4--------//02
	.o_data_s4_29   (data02_s4_29 ),   
        .o_data_s4_55   (data02_s4_55 ),
        .o_data_s4_74   (data02_s4_74 ),
        .o_data_s4_84   (data02_s4_84 )
);

re_level0_cal   u03_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data3    ),
//--------r16--------//
        .o_data_r16_4   (data03_r16_4 ),   
        .o_data_r16_13  (data03_r16_13),
        .o_data_r16_22  (data03_r16_22),
        .o_data_r16_31  (data03_r16_31),
        .o_data_r16_38  (data03_r16_38),
        .o_data_r16_46  (data03_r16_46),
        .o_data_r16_54  (data03_r16_54),
        .o_data_r16_61  (data03_r16_61),
        .o_data_r16_67  (data03_r16_67),
        .o_data_r16_73  (data03_r16_73),
        .o_data_r16_78  (data03_r16_78),
        .o_data_r16_82  (data03_r16_82),
        .o_data_r16_85  (data03_r16_85),
        .o_data_r16_88  (data03_r16_88),
        .o_data_r16_90  (data03_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data03_r8_9  ),    
        .o_data_r8_25   (data03_r8_25 ),
        .o_data_r8_43   (data03_r8_43 ),
        .o_data_r8_57   (data03_r8_57 ),
        .o_data_r8_70   (data03_r8_70 ),
        .o_data_r8_80   (data03_r8_80 ),
        .o_data_r8_87   (data03_r8_87 ),
        .o_data_r8_90   (data03_r8_90 ),
//-------------r4----------//03
	.o_data_r4_18   (data03_r4_18 ),  
        .o_data_r4_50   (data03_r4_50 ),
        .o_data_r4_75   (data03_r4_75 ),
        .o_data_r4_89   (data03_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data03_a4_64 ),
        .o_data_a4_36   (data03_a4_36 ),
        .o_data_a4_83   (data03_a4_83 ),
//-----------dst4x4--------//03
	.o_data_s4_29   (data03_s4_29 ),   
        .o_data_s4_55   (data03_s4_55 ),
        .o_data_s4_74   (data03_s4_74 ),
        .o_data_s4_84   (data03_s4_84 )
);

re_level0_cal   u04_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data4    ),
//--------r16--------//
        .o_data_r16_4   (data04_r16_4 ),   
        .o_data_r16_13  (data04_r16_13),
        .o_data_r16_22  (data04_r16_22),
        .o_data_r16_31  (data04_r16_31),
        .o_data_r16_38  (data04_r16_38),
        .o_data_r16_46  (data04_r16_46),
        .o_data_r16_54  (data04_r16_54),
        .o_data_r16_61  (data04_r16_61),
        .o_data_r16_67  (data04_r16_67),
        .o_data_r16_73  (data04_r16_73),
        .o_data_r16_78  (data04_r16_78),
        .o_data_r16_82  (data04_r16_82),
        .o_data_r16_85  (data04_r16_85),
        .o_data_r16_88  (data04_r16_88),
        .o_data_r16_90  (data04_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data04_r8_9  ),    
        .o_data_r8_25   (data04_r8_25 ),
        .o_data_r8_43   (data04_r8_43 ),
        .o_data_r8_57   (data04_r8_57 ),
        .o_data_r8_70   (data04_r8_70 ),
        .o_data_r8_80   (data04_r8_80 ),
        .o_data_r8_87   (data04_r8_87 ),
        .o_data_r8_90   (data04_r8_90 ),
//-------------r4----------//04
	.o_data_r4_18   (data04_r4_18 ),  
        .o_data_r4_50   (data04_r4_50 ),
        .o_data_r4_75   (data04_r4_75 ),
        .o_data_r4_89   (data04_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data04_a4_64 ),
        .o_data_a4_36   (data04_a4_36 ),
        .o_data_a4_83   (data04_a4_83 ),
//-----------dst4x4--------//04
	.o_data_s4_29   (data04_s4_29 ),   
        .o_data_s4_55   (data04_s4_55 ),
        .o_data_s4_74   (data04_s4_74 ),
        .o_data_s4_84   (data04_s4_84 )
);

re_level0_cal   u05_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data5    ),
//--------r16--------//
        .o_data_r16_4   (data05_r16_4 ),   
        .o_data_r16_13  (data05_r16_13),
        .o_data_r16_22  (data05_r16_22),
        .o_data_r16_31  (data05_r16_31),
        .o_data_r16_38  (data05_r16_38),
        .o_data_r16_46  (data05_r16_46),
        .o_data_r16_54  (data05_r16_54),
        .o_data_r16_61  (data05_r16_61),
        .o_data_r16_67  (data05_r16_67),
        .o_data_r16_73  (data05_r16_73),
        .o_data_r16_78  (data05_r16_78),
        .o_data_r16_82  (data05_r16_82),
        .o_data_r16_85  (data05_r16_85),
        .o_data_r16_88  (data05_r16_88),
        .o_data_r16_90  (data05_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data05_r8_9  ),    
        .o_data_r8_25   (data05_r8_25 ),
        .o_data_r8_43   (data05_r8_43 ),
        .o_data_r8_57   (data05_r8_57 ),
        .o_data_r8_70   (data05_r8_70 ),
        .o_data_r8_80   (data05_r8_80 ),
        .o_data_r8_87   (data05_r8_87 ),
        .o_data_r8_90   (data05_r8_90 ),
//-------------r4----------//05
	.o_data_r4_18   (data05_r4_18 ),  
        .o_data_r4_50   (data05_r4_50 ),
        .o_data_r4_75   (data05_r4_75 ),
        .o_data_r4_89   (data05_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data05_a4_64 ),
        .o_data_a4_36   (data05_a4_36 ),
        .o_data_a4_83   (data05_a4_83 ),
//-----------dst4x4--------//05
	.o_data_s4_29   (data05_s4_29 ),   
        .o_data_s4_55   (data05_s4_55 ),
        .o_data_s4_74   (data05_s4_74 ),
        .o_data_s4_84   (data05_s4_84 )
);

re_level0_cal   u06_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data6    ),
//--------r16--------//
        .o_data_r16_4   (data06_r16_4 ),   
        .o_data_r16_13  (data06_r16_13),
        .o_data_r16_22  (data06_r16_22),
        .o_data_r16_31  (data06_r16_31),
        .o_data_r16_38  (data06_r16_38),
        .o_data_r16_46  (data06_r16_46),
        .o_data_r16_54  (data06_r16_54),
        .o_data_r16_61  (data06_r16_61),
        .o_data_r16_67  (data06_r16_67),
        .o_data_r16_73  (data06_r16_73),
        .o_data_r16_78  (data06_r16_78),
        .o_data_r16_82  (data06_r16_82),
        .o_data_r16_85  (data06_r16_85),
        .o_data_r16_88  (data06_r16_88),
        .o_data_r16_90  (data06_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data06_r8_9  ),    
        .o_data_r8_25   (data06_r8_25 ),
        .o_data_r8_43   (data06_r8_43 ),
        .o_data_r8_57   (data06_r8_57 ),
        .o_data_r8_70   (data06_r8_70 ),
        .o_data_r8_80   (data06_r8_80 ),
        .o_data_r8_87   (data06_r8_87 ),
        .o_data_r8_90   (data06_r8_90 ),
//-------------r4----------//06
	.o_data_r4_18   (data06_r4_18 ),  
        .o_data_r4_50   (data06_r4_50 ),
        .o_data_r4_75   (data06_r4_75 ),
        .o_data_r4_89   (data06_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data06_a4_64 ),
        .o_data_a4_36   (data06_a4_36 ),
        .o_data_a4_83   (data06_a4_83 ),
//-----------dst4x4--------//06
	.o_data_s4_29   (data06_s4_29 ),   
        .o_data_s4_55   (data06_s4_55 ),
        .o_data_s4_74   (data06_s4_74 ),
        .o_data_s4_84   (data06_s4_84 )
);

re_level0_cal   u07_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data7    ),
//--------r16--------//
        .o_data_r16_4   (data07_r16_4 ),   
        .o_data_r16_13  (data07_r16_13),
        .o_data_r16_22  (data07_r16_22),
        .o_data_r16_31  (data07_r16_31),
        .o_data_r16_38  (data07_r16_38),
        .o_data_r16_46  (data07_r16_46),
        .o_data_r16_54  (data07_r16_54),
        .o_data_r16_61  (data07_r16_61),
        .o_data_r16_67  (data07_r16_67),
        .o_data_r16_73  (data07_r16_73),
        .o_data_r16_78  (data07_r16_78),
        .o_data_r16_82  (data07_r16_82),
        .o_data_r16_85  (data07_r16_85),
        .o_data_r16_88  (data07_r16_88),
        .o_data_r16_90  (data07_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data07_r8_9  ),    
        .o_data_r8_25   (data07_r8_25 ),
        .o_data_r8_43   (data07_r8_43 ),
        .o_data_r8_57   (data07_r8_57 ),
        .o_data_r8_70   (data07_r8_70 ),
        .o_data_r8_80   (data07_r8_80 ),
        .o_data_r8_87   (data07_r8_87 ),
        .o_data_r8_90   (data07_r8_90 ),
//-------------r4----------//07
	.o_data_r4_18   (data07_r4_18 ),  
        .o_data_r4_50   (data07_r4_50 ),
        .o_data_r4_75   (data07_r4_75 ),
        .o_data_r4_89   (data07_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data07_a4_64 ),
        .o_data_a4_36   (data07_a4_36 ),
        .o_data_a4_83   (data07_a4_83 ),
//-----------dst4x4--------//07
	.o_data_s4_29   (data07_s4_29 ),   
        .o_data_s4_55   (data07_s4_55 ),
        .o_data_s4_74   (data07_s4_74 ),
        .o_data_s4_84   (data07_s4_84 )
);

re_level0_cal   u08_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data8    ),
//--------r16--------//
        .o_data_r16_4   (data08_r16_4 ),   
        .o_data_r16_13  (data08_r16_13),
        .o_data_r16_22  (data08_r16_22),
        .o_data_r16_31  (data08_r16_31),
        .o_data_r16_38  (data08_r16_38),
        .o_data_r16_46  (data08_r16_46),
        .o_data_r16_54  (data08_r16_54),
        .o_data_r16_61  (data08_r16_61),
        .o_data_r16_67  (data08_r16_67),
        .o_data_r16_73  (data08_r16_73),
        .o_data_r16_78  (data08_r16_78),
        .o_data_r16_82  (data08_r16_82),
        .o_data_r16_85  (data08_r16_85),
        .o_data_r16_88  (data08_r16_88),
        .o_data_r16_90  (data08_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data08_r8_9  ),    
        .o_data_r8_25   (data08_r8_25 ),
        .o_data_r8_43   (data08_r8_43 ),
        .o_data_r8_57   (data08_r8_57 ),
        .o_data_r8_70   (data08_r8_70 ),
        .o_data_r8_80   (data08_r8_80 ),
        .o_data_r8_87   (data08_r8_87 ),
        .o_data_r8_90   (data08_r8_90 ),
//-------------r4----------//08
	.o_data_r4_18   (data08_r4_18 ),  
        .o_data_r4_50   (data08_r4_50 ),
        .o_data_r4_75   (data08_r4_75 ),
        .o_data_r4_89   (data08_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data08_a4_64 ),
        .o_data_a4_36   (data08_a4_36 ),
        .o_data_a4_83   (data08_a4_83 ),
//-----------dst4x4--------//08
	.o_data_s4_29   (data08_s4_29 ),   
        .o_data_s4_55   (data08_s4_55 ),
        .o_data_s4_74   (data08_s4_74 ),
        .o_data_s4_84   (data08_s4_84 )
);

re_level0_cal   u09_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data9    ),
//--------r16--------//
        .o_data_r16_4   (data09_r16_4 ),   
        .o_data_r16_13  (data09_r16_13),
        .o_data_r16_22  (data09_r16_22),
        .o_data_r16_31  (data09_r16_31),
        .o_data_r16_38  (data09_r16_38),
        .o_data_r16_46  (data09_r16_46),
        .o_data_r16_54  (data09_r16_54),
        .o_data_r16_61  (data09_r16_61),
        .o_data_r16_67  (data09_r16_67),
        .o_data_r16_73  (data09_r16_73),
        .o_data_r16_78  (data09_r16_78),
        .o_data_r16_82  (data09_r16_82),
        .o_data_r16_85  (data09_r16_85),
        .o_data_r16_88  (data09_r16_88),
        .o_data_r16_90  (data09_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data09_r8_9  ),    
        .o_data_r8_25   (data09_r8_25 ),
        .o_data_r8_43   (data09_r8_43 ),
        .o_data_r8_57   (data09_r8_57 ),
        .o_data_r8_70   (data09_r8_70 ),
        .o_data_r8_80   (data09_r8_80 ),
        .o_data_r8_87   (data09_r8_87 ),
        .o_data_r8_90   (data09_r8_90 ),
//-------------r4----------//09
	.o_data_r4_18   (data09_r4_18 ),  
        .o_data_r4_50   (data09_r4_50 ),
        .o_data_r4_75   (data09_r4_75 ),
        .o_data_r4_89   (data09_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data09_a4_64 ),
        .o_data_a4_36   (data09_a4_36 ),
        .o_data_a4_83   (data09_a4_83 ),
//-----------dst4x4--------//09
	.o_data_s4_29   (data09_s4_29 ),   
        .o_data_s4_55   (data09_s4_55 ),
        .o_data_s4_74   (data09_s4_74 ),
        .o_data_s4_84   (data09_s4_84 )
);

re_level0_cal   u10_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data10   ),
//--------r16--------//
        .o_data_r16_4   (data10_r16_4 ),   
        .o_data_r16_13  (data10_r16_13),
        .o_data_r16_22  (data10_r16_22),
        .o_data_r16_31  (data10_r16_31),
        .o_data_r16_38  (data10_r16_38),
        .o_data_r16_46  (data10_r16_46),
        .o_data_r16_54  (data10_r16_54),
        .o_data_r16_61  (data10_r16_61),
        .o_data_r16_67  (data10_r16_67),
        .o_data_r16_73  (data10_r16_73),
        .o_data_r16_78  (data10_r16_78),
        .o_data_r16_82  (data10_r16_82),
        .o_data_r16_85  (data10_r16_85),
        .o_data_r16_88  (data10_r16_88),
        .o_data_r16_90  (data10_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data10_r8_9  ),    
        .o_data_r8_25   (data10_r8_25 ),
        .o_data_r8_43   (data10_r8_43 ),
        .o_data_r8_57   (data10_r8_57 ),
        .o_data_r8_70   (data10_r8_70 ),
        .o_data_r8_80   (data10_r8_80 ),
        .o_data_r8_87   (data10_r8_87 ),
        .o_data_r8_90   (data10_r8_90 ),
//-------------r4----------//10
	.o_data_r4_18   (data10_r4_18 ),  
        .o_data_r4_50   (data10_r4_50 ),
        .o_data_r4_75   (data10_r4_75 ),
        .o_data_r4_89   (data10_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data10_a4_64 ),
        .o_data_a4_36   (data10_a4_36 ),
        .o_data_a4_83   (data10_a4_83 ),
//-----------dst4x4--------//10
	.o_data_s4_29   (data10_s4_29 ),   
        .o_data_s4_55   (data10_s4_55 ),
        .o_data_s4_74   (data10_s4_74 ),
        .o_data_s4_84   (data10_s4_84 )
);

re_level0_cal   u11_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data11   ),
//--------r16--------//
        .o_data_r16_4   (data11_r16_4 ),   
        .o_data_r16_13  (data11_r16_13),
        .o_data_r16_22  (data11_r16_22),
        .o_data_r16_31  (data11_r16_31),
        .o_data_r16_38  (data11_r16_38),
        .o_data_r16_46  (data11_r16_46),
        .o_data_r16_54  (data11_r16_54),
        .o_data_r16_61  (data11_r16_61),
        .o_data_r16_67  (data11_r16_67),
        .o_data_r16_73  (data11_r16_73),
        .o_data_r16_78  (data11_r16_78),
        .o_data_r16_82  (data11_r16_82),
        .o_data_r16_85  (data11_r16_85),
        .o_data_r16_88  (data11_r16_88),
        .o_data_r16_90  (data11_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data11_r8_9  ),    
        .o_data_r8_25   (data11_r8_25 ),
        .o_data_r8_43   (data11_r8_43 ),
        .o_data_r8_57   (data11_r8_57 ),
        .o_data_r8_70   (data11_r8_70 ),
        .o_data_r8_80   (data11_r8_80 ),
        .o_data_r8_87   (data11_r8_87 ),
        .o_data_r8_90   (data11_r8_90 ),
//-------------r4----------//11
	.o_data_r4_18   (data11_r4_18 ),  
        .o_data_r4_50   (data11_r4_50 ),
        .o_data_r4_75   (data11_r4_75 ),
        .o_data_r4_89   (data11_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data11_a4_64 ),
        .o_data_a4_36   (data11_a4_36 ),
        .o_data_a4_83   (data11_a4_83 ),
//-----------dst4x4--------//11
	.o_data_s4_29   (data11_s4_29 ),   
        .o_data_s4_55   (data11_s4_55 ),
        .o_data_s4_74   (data11_s4_74 ),
        .o_data_s4_84   (data11_s4_84 )
);

re_level0_cal   u12_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data12   ),
//--------r16--------//
        .o_data_r16_4   (data12_r16_4 ),   
        .o_data_r16_13  (data12_r16_13),
        .o_data_r16_22  (data12_r16_22),
        .o_data_r16_31  (data12_r16_31),
        .o_data_r16_38  (data12_r16_38),
        .o_data_r16_46  (data12_r16_46),
        .o_data_r16_54  (data12_r16_54),
        .o_data_r16_61  (data12_r16_61),
        .o_data_r16_67  (data12_r16_67),
        .o_data_r16_73  (data12_r16_73),
        .o_data_r16_78  (data12_r16_78),
        .o_data_r16_82  (data12_r16_82),
        .o_data_r16_85  (data12_r16_85),
        .o_data_r16_88  (data12_r16_88),
        .o_data_r16_90  (data12_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data12_r8_9  ),    
        .o_data_r8_25   (data12_r8_25 ),
        .o_data_r8_43   (data12_r8_43 ),
        .o_data_r8_57   (data12_r8_57 ),
        .o_data_r8_70   (data12_r8_70 ),
        .o_data_r8_80   (data12_r8_80 ),
        .o_data_r8_87   (data12_r8_87 ),
        .o_data_r8_90   (data12_r8_90 ),
//-------------r4----------//12
	.o_data_r4_18   (data12_r4_18 ),  
        .o_data_r4_50   (data12_r4_50 ),
        .o_data_r4_75   (data12_r4_75 ),
        .o_data_r4_89   (data12_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data12_a4_64 ),
        .o_data_a4_36   (data12_a4_36 ),
        .o_data_a4_83   (data12_a4_83 ),
//-----------dst4x4--------//12
	.o_data_s4_29   (data12_s4_29 ),   
        .o_data_s4_55   (data12_s4_55 ),
        .o_data_s4_74   (data12_s4_74 ),
        .o_data_s4_84   (data12_s4_84 )
);

re_level0_cal   u13_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data13   ),
//--------r16--------//
        .o_data_r16_4   (data13_r16_4 ),   
        .o_data_r16_13  (data13_r16_13),
        .o_data_r16_22  (data13_r16_22),
        .o_data_r16_31  (data13_r16_31),
        .o_data_r16_38  (data13_r16_38),
        .o_data_r16_46  (data13_r16_46),
        .o_data_r16_54  (data13_r16_54),
        .o_data_r16_61  (data13_r16_61),
        .o_data_r16_67  (data13_r16_67),
        .o_data_r16_73  (data13_r16_73),
        .o_data_r16_78  (data13_r16_78),
        .o_data_r16_82  (data13_r16_82),
        .o_data_r16_85  (data13_r16_85),
        .o_data_r16_88  (data13_r16_88),
        .o_data_r16_90  (data13_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data13_r8_9  ),    
        .o_data_r8_25   (data13_r8_25 ),
        .o_data_r8_43   (data13_r8_43 ),
        .o_data_r8_57   (data13_r8_57 ),
        .o_data_r8_70   (data13_r8_70 ),
        .o_data_r8_80   (data13_r8_80 ),
        .o_data_r8_87   (data13_r8_87 ),
        .o_data_r8_90   (data13_r8_90 ),
//-------------r4----------//13
	.o_data_r4_18   (data13_r4_18 ),  
        .o_data_r4_50   (data13_r4_50 ),
        .o_data_r4_75   (data13_r4_75 ),
        .o_data_r4_89   (data13_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data13_a4_64 ),
        .o_data_a4_36   (data13_a4_36 ),
        .o_data_a4_83   (data13_a4_83 ),
//-----------dst4x4--------//13
	.o_data_s4_29   (data13_s4_29 ),   
        .o_data_s4_55   (data13_s4_55 ),
        .o_data_s4_74   (data13_s4_74 ),
        .o_data_s4_84   (data13_s4_84 )
);

re_level0_cal   u14_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32   ),//data valid
	.i_dt_vld16     (i_dt_vld_16   ),//data valid
	.i_dt_vld8      (i_dt_vld_8    ),//data valid
	.i_dt_vld4      (i_dt_vld_4    ),
	.i_dt_vld_dst   (i_dt_vld_dst ),//data valid
	.i_data	        (i_data14   ),
//--------r16--------//
        .o_data_r16_4   (data14_r16_4 ),   
        .o_data_r16_13  (data14_r16_13),
        .o_data_r16_22  (data14_r16_22),
        .o_data_r16_31  (data14_r16_31),
        .o_data_r16_38  (data14_r16_38),
        .o_data_r16_46  (data14_r16_46),
        .o_data_r16_54  (data14_r16_54),
        .o_data_r16_61  (data14_r16_61),
        .o_data_r16_67  (data14_r16_67),
        .o_data_r16_73  (data14_r16_73),
        .o_data_r16_78  (data14_r16_78),
        .o_data_r16_82  (data14_r16_82),
        .o_data_r16_85  (data14_r16_85),
        .o_data_r16_88  (data14_r16_88),
        .o_data_r16_90  (data14_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data14_r8_9  ),    
        .o_data_r8_25   (data14_r8_25 ),
        .o_data_r8_43   (data14_r8_43 ),
        .o_data_r8_57   (data14_r8_57 ),
        .o_data_r8_70   (data14_r8_70 ),
        .o_data_r8_80   (data14_r8_80 ),
        .o_data_r8_87   (data14_r8_87 ),
        .o_data_r8_90   (data14_r8_90 ),
//-------------r4----------//14
	.o_data_r4_18   (data14_r4_18 ),  
        .o_data_r4_50   (data14_r4_50 ),
        .o_data_r4_75   (data14_r4_75 ),
        .o_data_r4_89   (data14_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data14_a4_64 ),
        .o_data_a4_36   (data14_a4_36 ),
        .o_data_a4_83   (data14_a4_83 ),
//-----------dst4x4--------//14
	.o_data_s4_29   (data14_s4_29 ),   
        .o_data_s4_55   (data14_s4_55 ),
        .o_data_s4_74   (data14_s4_74 ),
        .o_data_s4_84   (data14_s4_84 )
);

re_level0_cal   u15_level0_cal(
	.clk            (clk        ),
	.rst_n          (rst_n      ),
	.i_dt_vld32     (i_dt_vld_32  ),//data valid
	.i_dt_vld16     (i_dt_vld_16  ),//data valid
	.i_dt_vld8      (i_dt_vld_8   ),//data valid
	.i_dt_vld4      (i_dt_vld_4   ),
	.i_dt_vld_dst   (i_dt_vld_dst),//data valid
	.i_data	        (i_data15   ),
//--------r16--------//
        .o_data_r16_4   (data15_r16_4 ),   
        .o_data_r16_13  (data15_r16_13),
        .o_data_r16_22  (data15_r16_22),
        .o_data_r16_31  (data15_r16_31),
        .o_data_r16_38  (data15_r16_38),
        .o_data_r16_46  (data15_r16_46),
        .o_data_r16_54  (data15_r16_54),
        .o_data_r16_61  (data15_r16_61),
        .o_data_r16_67  (data15_r16_67),
        .o_data_r16_73  (data15_r16_73),
        .o_data_r16_78  (data15_r16_78),
        .o_data_r16_82  (data15_r16_82),
        .o_data_r16_85  (data15_r16_85),
        .o_data_r16_88  (data15_r16_88),
        .o_data_r16_90  (data15_r16_90),
//-------------r8---------//
	.o_data_r8_9    (data15_r8_9  ),    
        .o_data_r8_25   (data15_r8_25 ),
        .o_data_r8_43   (data15_r8_43 ),
        .o_data_r8_57   (data15_r8_57 ),
        .o_data_r8_70   (data15_r8_70 ),
        .o_data_r8_80   (data15_r8_80 ),
        .o_data_r8_87   (data15_r8_87 ),
        .o_data_r8_90   (data15_r8_90 ),
//-------------r4----------//15
	.o_data_r4_18   (data15_r4_18 ),  
        .o_data_r4_50   (data15_r4_50 ),
        .o_data_r4_75   (data15_r4_75 ),
        .o_data_r4_89   (data15_r4_89 ),
//-------------a4----------//00
        .o_data_a4_64   (data15_a4_64 ),
        .o_data_a4_36   (data15_a4_36 ),
        .o_data_a4_83   (data15_a4_83 ),
//-----------dst4x4--------//15
	.o_data_s4_29   (data15_s4_29 ),   
        .o_data_s4_55   (data15_s4_55 ),
        .o_data_s4_74   (data15_s4_74 ),
        .o_data_s4_84   (data15_s4_84 )
);

endmodule
