

module qp_lambda_table(
	qp_i ,
	lambda
);

input  [6-1:0] 	qp_i ;
output [7-1:0]  lambda ;

reg [7-1:0] lambda ;

always @(qp_i)
  case(qp_i)
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15: 
      lambda = 1;
    16,17,18,19:
      lambda = 2;
    20,21,22:
      lambda = 3;
    23,24,25:
      lambda = 4;
    26:
      lambda = 5;
    27,28:
      lambda = 6;
    29:
      lambda = 7;
    30:
      lambda = 8;
    31:
      lambda = 9;
    32:
      lambda = 10;
    33:
      lambda = 11;
    34:
      lambda = 13;
    35:
      lambda = 14;
    36:
      lambda = 16;
    37:
      lambda = 18;
    38:
      lambda = 20;
    39:
      lambda = 23;
    40:
      lambda = 25;
    41:
      lambda = 29;
    42:
      lambda = 32;
    43:
      lambda = 36;
    44:
      lambda = 40;
    45:
      lambda = 45;
    46:
      lambda = 51;
    47:
      lambda = 57;
    48:
      lambda = 64;
    49:
      lambda = 72;
    50:
      lambda = 81;
    51:
      lambda = 91;
    default:
      lambda = 0;
  endcase
endmodule 