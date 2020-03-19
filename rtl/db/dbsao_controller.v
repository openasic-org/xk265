
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
// Filename       : dbsao_controller.v
// Author         : TANG
// Creatu_ved     : 
// Description    :         
//------------------------------------------------------------------------------------------------

module dbsao_controller(
            clk                 ,
            rst_n               ,
            start_i             ,

            done_o              ,
            cnt_o               ,
            state_o             
);

//***************************************************
//
//      Input / Output Declaration 
//
//****************************************************/

input                   clk, rst_n      ;
input                   start_i         ;

output  reg             done_o          ; // db and sao statistics finished 
output  reg     [8:0]   cnt_o           ; // 
output  reg     [2:0]   state_o         ; // state machine
// output  reg          y_done_o        ; // dbf luma finished
// output  reg          u_done_o        ; // dbf chroma-u finished
// output  reg          v_done_o        ; // dbf chroma-v finished

//***************************************************
// 
//          Parameter Declaration 
//
//****************************************************
parameter IDLE = 3'b000, LOAD = 3'b001, DBY = 3'b011, DBU = 3'b010, DBV = 3'b110, SAO = 3'b100, OUT = 3'b101;

reg         [2:0]               next_state      ;
reg         [8:0]               cycles          ;

always @(*) begin 
    case ( state_o )
        LOAD    : cycles    = 9'd128     ;
        DBY     : cycles    = 9'd263     ;
        DBU     : cycles    = 9'd71      ;
        DBV     : cycles    = 9'd71      ;
        SAO     : cycles    = 9'd451     ;
        OUT     : cycles    = 9'd455     ;
        default : cycles    = 9'd0       ;
    endcase 
end

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n ) 
        cnt_o       <= 9'd0         ;
    else if ( (state_o==IDLE) || (cnt_o == cycles ))
        cnt_o       <= 9'd0         ;
    else 
        cnt_o       <= cnt_o + 1'b1 ;
end 

always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n )
        state_o         <= IDLE                 ;
    else 
        state_o         <= next_state           ;
end 

always @ ( * ) begin 
    case ( state_o )
        IDLE : begin 
            if ( start_i )
                next_state      = LOAD     ;
            else 
                next_state      = IDLE     ;
            end
        LOAD : begin 
            if ( cnt_o == cycles )
                next_state      = DBY      ;
            else 
                next_state      = LOAD     ;
            end 
        DBY : begin 
            if ( cnt_o == cycles )
                next_state      = DBU      ;
            else 
                next_state      = DBY      ;
            end  
        DBU : begin 
            if ( cnt_o == cycles )
                next_state      = DBV      ;
            else 
                next_state      = DBU      ;
            end 
        DBV : begin 
            if ( cnt_o == cycles )
                next_state      = SAO      ;
            else 
                next_state      = DBV      ;
            end 
        SAO : begin 
            if ( cnt_o == cycles )
                next_state      = OUT     ;
            else 
                next_state      = SAO      ;
            end
        OUT : begin 
            if ( cnt_o == cycles )
                next_state      = IDLE     ;
            else 
                next_state      = OUT      ;
            end
        default : next_state      = IDLE   ;
    endcase 
end 

wire    done_w;
assign done_w = ( state_o == OUT ) ? 1'b1:1'b0 ;
always @ ( posedge clk or negedge rst_n ) begin 
    if ( !rst_n )
        done_o      <= 1'b0                 ;
    else if ( next_state == IDLE )
        done_o      <= done_w               ;
    else 
        done_o      <= 1'b0                 ;
end 

// assign y_done_o = (state_o == DBY) && (cnt_o == cycles);
// assign u_done_o = (state_o == DBU) && (cnt_o == cycles);
// assign v_done_o = (state_o == DBV) && (cnt_o == cycles);

endmodule 