module mod(
       clk       ,
       rst       ,
       type_i      ,
       qp        ,
       i_valid   ,
       inverse   ,
       i_transize,
        
       q_data         ,
       offset    ,
       shift
);

// ****************************************************************
//
//	INPUT / OUTPUT DECLARATION
//
// ****************************************************************  

input                              clk;
input                              rst;
input                             type_i;
input                          i_valid;
input                          inverse;
input    [1:0]              i_transize;
input    [5:0]                      qp;   

output reg  signed [15:0]            q_data;
output reg  signed [27:0]       offset;
output reg  [4:0]                shift;

// ****************************************************************
//
//	REG  DECLARATION
//
// **************************************************************** 

reg    [5:0]           opi;
reg                  state;
reg             next_state;

reg  [2:0]              q; // nQpMod6
reg  [3:0]              p; // nQpDiv6

reg    [5:0]           qp_r;

// ********************************************
//                                             
//    PARAMETER DECLARATION                                               
//                                                                             
// ********************************************

parameter            DCT_4=2'b00;
parameter            DCT_8=2'b01;
parameter           DCT_16=2'b10;
parameter           DCT_32=2'b11;
parameter              IDLE=1'b0;
parameter               MODE_STATE=1'b1;


// ****************************************************************
//
//	COMBINATIONAL LOGIC
//
// ****************************************************************

always @ ( posedge clk or negedge rst ) begin 
  if ( !rst ) 
    qp_r <= 0 ;
  else 
    qp_r <= qp ;
end 

always@(*) begin 
    next_state=IDLE;
    case(state)
      IDLE:
        if((qp_r != qp)&&(qp>6 || qp==6))
          next_state=MODE_STATE;
        else
          next_state=IDLE;
      MODE_STATE:
        if(opi<6+6)
          next_state=IDLE;
        else
          next_state=MODE_STATE;
    endcase
end      
// ****************************************************************
//
//	SEUENTIAL LOGIC
//
// ****************************************************************

always @(posedge clk or negedge rst)
  begin
    if(~rst)
      state  <= IDLE;
    else
      state  <=  next_state;
  end

always @ ( posedge clk or negedge rst ) begin 
  if ( !rst )
    p <= 0;
  else if ( qp_r != qp ) // initial p
    p <= 0;
  else if (state == MODE_STATE )
    p <= p + 1 ;
end 

always @ ( posedge clk or negedge rst ) begin 
  if ( !rst ) 
    opi <= 0;
  else if ( qp_r != qp ) // initial opi
    opi <= qp ;
  else if ( state == MODE_STATE )
    opi <= opi-6;
end 

always @ ( posedge clk or negedge rst ) begin 
  if ( !rst ) 
    q <= 0;
  else  
    q <= opi[2:0] ; 
end 

//-----------------------------------------//
wire   [8:0]  data_mux_type      ;
reg    [4:0]  shift_size_mux_0   ;
wire   [4:0]  shift_size_0       ;
reg    [4:0]  shift_mux_n        ;
wire   [4:0]  shift_n            ;
reg    [27:0] data_mux_type_shift;
reg    [6:0]  data_mux           ;
reg    [15:0] data_mux_shift     ;

assign data_mux_type = type_i ? 9'd85 : 9'd171;

always @(*)
begin
case(i_transize)
	DCT_4:
	begin
	  	shift_size_mux_0 =5'd10;
	  	shift_mux_n=5'd19;
	end
	DCT_8:
	begin
	 	shift_size_mux_0 =5'd9;
	  	shift_mux_n=5'd18;
	end
  	DCT_16:
	begin
	 	shift_size_mux_0 =5'd8;
	  	shift_mux_n=5'd17;
	end	
  	DCT_32:
	begin
	 	shift_size_mux_0 =5'd7;
	  	shift_mux_n=5'd16;
	end	  
endcase
end 

assign  shift_n      =  shift_mux_n + p;
assign  shift_size_0 = shift_size_mux_0 + p;

always @(*)
begin
case(shift_size_0)
	5'd7    :data_mux_type_shift =  {12'd0,data_mux_type,7'd0};
	5'd8    :data_mux_type_shift =  {11'd0,data_mux_type,8'd0};
	5'd9    :data_mux_type_shift =  {10'd0,data_mux_type,9'd0};
	5'd10   :data_mux_type_shift =  {9'd0,data_mux_type,10'd0};
	5'd11   :data_mux_type_shift =  {8'd0,data_mux_type,11'd0};
	5'd12   :data_mux_type_shift =  {7'd0,data_mux_type,12'd0};
	5'd13   :data_mux_type_shift =  {6'd0,data_mux_type,13'd0};
	5'd14   :data_mux_type_shift =  {5'd0,data_mux_type,14'd0};
	5'd15   :data_mux_type_shift =  {4'd0,data_mux_type,15'd0};
	5'd16   :data_mux_type_shift =  {3'd0,data_mux_type,16'd0};
	5'd17   :data_mux_type_shift =  {2'd0,data_mux_type,17'd0};
	default :data_mux_type_shift =  {1'd0,data_mux_type,18'd0};
endcase
end 
 
always@(*) begin 
shift  = 0;
offset  = 0;
if(!inverse)
	begin
		shift  = shift_n;
		offset  = data_mux_type_shift;
	end 
/*
case(i_transize)
	DCT_4:begin
	  shift<=19+p;
	  offset<= data_mux_type_shift;//offset<=type?(9'd85<<<(10+p)):(9'd171<<<(10+p));
	  end
	DCT_8:begin
	  shift<=18+p;
	  offset<= data_mux_type_shift;//offset<=type?(9'd85<<<(9+p)):(9'd171<<<(9+p));
	  end
  	DCT_16:begin
	  shift<=17+p;
	  offset<= data_mux_type_shift;//offset<=type?(9'd85<<<(8+p)):(9'd171<<<(8+p));
	  end	
  	DCT_32:begin
	  shift<=16+p;
	  offset<= data_mux_type_shift;//offset<=type?(9'd85<<<(7+p)):(9'd171<<<(7+p));
	  end	  
endcase
*/
else
case(i_transize)
	DCT_4:
	begin
	  	shift =3'd1;
	  	offset =5'd1;
	end
	DCT_8:
	begin
	  	shift =3'd2;
	  	offset =5'd2;
	end
  	DCT_16:
	begin
	  	shift =3'd3;
	  	offset =5'd4;
	end	
  	DCT_32:
	begin
	  	shift =3'd4;
	  	offset =5'd8;
	end	 
endcase

end 

always @(*)
begin
case(q)
  3'd0:   data_mux= 7'd40;
  3'd1:   data_mux= 7'd45;
  3'd2:   data_mux= 7'd51;
  3'd3:   data_mux= 7'd57;
  3'd4:   data_mux= 7'd64;
  3'd5:   data_mux= 7'd72;
  default:data_mux= 7'd0;
endcase
end 

always @(*)
begin
case(p)
	4'd0   :data_mux_shift = {9'd0,data_mux};
	4'd1   :data_mux_shift = {8'd0,data_mux,1'd0};
	4'd2   :data_mux_shift = {7'd0,data_mux,2'd0};
	4'd3   :data_mux_shift = {6'd0,data_mux,3'd0};
	4'd4   :data_mux_shift = {5'd0,data_mux,4'd0};
	4'd5   :data_mux_shift = {4'd0,data_mux,5'd0};
	4'd6   :data_mux_shift = {3'd0,data_mux,6'd0};
	4'd7   :data_mux_shift = {2'd0,data_mux,7'd0};
	4'd8   :data_mux_shift = {1'd0,data_mux,8'd0};
	default:data_mux_shift = 16'd0;
endcase
end 

always@(*)
begin
if(!inverse)
case(q)
  	3'd0:q_data=16'd26214;
  	3'd1:q_data=16'd23302;
  	3'd2:q_data=16'd20560;
  	3'd3:q_data=16'd18396;
  	3'd4:q_data=16'd16384;
  	3'd5:q_data=16'd14564;
  	default:q_data=16'd0;
endcase
else
	q_data = data_mux_shift;
end
/*
always@(*)
if(!inverse)
case(q)
  3'd0:q_data=16'd26214;
  3'd1:q_data=16'd23302;
  3'd2:q_data=16'd20560;
  3'd3:q_data=16'd18396;
  3'd4:q_data=16'd16384;
  3'd5:q_data=16'd14564;
  default:q_data=16'd0;
endcase
else
case(q)
  3'd0:q_data=(16'd40<<<p);
  3'd1:q_data=(16'd45<<<p);
  3'd2:q_data=(16'd51<<<p);
  3'd3:q_data=(16'd57<<<p);
  3'd4:q_data=(16'd64<<<p);
  3'd5:q_data=(16'd72<<<p);
  default:q_data=16'd0;
endcase
*/
endmodule
