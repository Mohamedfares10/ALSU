module ALSU_Project(
input [2:0] A, B, opcode,
input cin, serial_in, diraction,
input red_op_A, red_op_B,
input bypass_A, bypass_B,
input CLK, RST_n,
output reg [5:0] out,
output reg [15:0] leds
	       );
////////////////////////////////////////////////////////////
/////// make internal reg for all inputs & outputs ////////
///////////////////////////////////////////////////////////

reg [2:0] A_internal, B_internal, opcode_internal;
reg cin_internal, serial_in_internal, diraction_internal;
reg red_op_A_internal, red_op_B_internal;
reg bypass_A_internal, bypass_B_internal;
reg [5:0] out_internal;
reg [15:0]leds_internal;
reg [2:0]current_state;
reg [2:0]next_state   ;
reg [2:0]count;
integer i;
//////////////////parameters///////////////

localparam AND = 'b000, XOR = 'b001, Addition = 'b010,
Muliplication =  'b011, Shift = 'b100, Rotate = 'b101,
Invalid = 'b110, Bypass = 'b111,
INPUT_PRIOPRTY = "A",
FULL_ADDER     ="ON";

////////////////////////////////////////////////////////////////////////////////////////
/////// Assign internal reg for all inputs & outputs to  there inputs & outputs ////////
///////////////////////////////////////////////////////////////////////////////////////

always @(posedge CLK or negedge RST_n) begin
	
	if (!RST_n) begin 
	 out  <= 0;
        leds <= 0;
       
	end

	else begin
      A_internal   <= A; 
      B_internal   <= B;
      cin_internal <= cin;
      out          <= out_internal;
      leds         <= leds_internal   ;
      opcode_internal<= opcode;
        serial_in_internal <= serial_in;
        diraction_internal <= diraction;
        red_op_A_internal  <= red_op_A;
        red_op_B_internal  <= red_op_B;
        bypass_A_internal  <= bypass_A;
        bypass_B_internal  <= bypass_B;
	end
end

///////////////////////////////////////////////////////
//////////////////// STATE MEMORY /////////////////////
///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_n) begin
   
   if (!RST_n) begin 
      current_state <= Bypass;
   end

   else begin
      current_state <= next_state;
   end
end






///////////////////////////////////////////////////////
//////////////////// NEXT STATE ///////////////////////
///////////////////////////////////////////////////////

always @(*) begin

	case(current_state)
        AND,XOR,Addition,Muliplication,Shift,Rotate,Invalid,Bypass:
        begin          
             if (bypass_A_internal || bypass_B_internal) begin
                next_state = Bypass ;
             end
              
             else begin
                  
                  case(opcode_internal)
                   3'b000:          next_state = AND;

                   3'b001:          next_state = XOR;

                   3'b010:     begin
                                 if (red_op_A_internal || red_op_B_internal )begin
                                    next_state = Invalid; 
                                 end
                                 else begin
                                    next_state = Addition;
                                 end
                                 end
                                 
                   3'b011:begin
                                 if (red_op_A_internal || red_op_B_internal )begin
                                    next_state = Invalid; 
                                 end
                                 else begin
                                    next_state = Muliplication;
                                 end
                                 end

                   3'b100:        begin
                                 if (red_op_A_internal || red_op_B_internal )begin
                                    next_state = Invalid; 
                                 end
                                 else begin
                                    next_state = Shift;
                                 end
                                 end

                   3'b101:       begin
                                 if (red_op_A_internal || red_op_B_internal )begin
                                    next_state = Invalid; 
                                 end
                                 else begin
                                    next_state = Rotate;
                                 end
                                 end
                   3'b110:      next_state = Invalid; 

               // 3'b111 not 111 only (edited)
                   3'b111:          next_state = Invalid;  /// Right?! ///
                   
                   default: next_state = Invalid; // ADDED
                  endcase

             end
         end  
          default: next_state = Invalid;   // ADDED 
 endcase
           
end




///////////////////////////////////////////////////////
////////////////////// OUTPUT /////////////////////////
///////////////////////////////////////////////////////


always @(*) begin
leds_internal = 0 ;	


	case(current_state)
        AND:         begin 
                     if (red_op_A_internal && red_op_B_internal )begin
                          if(INPUT_PRIOPRTY == "A") out_internal = &A_internal;
                          else out_internal = &B_internal;
                      end 
                      else if (red_op_A_internal && (!red_op_B_internal))begin
                      	   out_internal = &A_internal;
                      end
                      else if ((!red_op_A_internal) && red_op_B_internal)begin
                      	   out_internal = &B_internal;
                      end
                      else begin
                           out_internal = A_internal&B_internal;
                      end
                      end


        XOR:         begin  
                     if (red_op_A_internal && red_op_B_internal )begin
                          if(INPUT_PRIOPRTY == "A") out_internal = ^A_internal;
                          else out_internal = ^B_internal;
                      end 
                      else if (red_op_A_internal && (!red_op_B_internal))begin
                      	   out_internal = ^A_internal;
                      end
                      else if (!red_op_A_internal && red_op_B_internal)begin
                      	   out_internal = ^B_internal;
                      end
                      else begin
                           out_internal = A_internal^B_internal;
                      end
                      end

        Addition:    begin 
                     if (FULL_ADDER=="ON") begin
                      out_internal = {cin_internal,(A_internal+B_internal)};
                      end
                      else begin
                      out_internal = A_internal+B_internal;
                      end
                      end

        Muliplication: out_internal = A_internal*B_internal;

        Shift:        begin
                      if (diraction) begin
                        out_internal = { out_internal[4:0],serial_in_internal};
                     end
                     else begin
                        out_internal = {serial_in_internal, out_internal[5:1]}; 
                     end
                     end                    
 
        Rotate:      begin
                        if (diraction) begin
                        out_internal = {out_internal[4:0] ,out_internal[5]};
                        end
                        else begin
                        out_internal = {out_internal[0],out_internal[5:1]}; 
                        end
                     end
        Invalid:    begin 
                    out_internal = 0;
                     if (count == 3'b101) begin
                        count = 0;
                        
                     end
                     else begin
                        count = count+1;
                        leds_internal = ~leds_internal;
                     end
                     end
        Bypass:   begin 
                   count = 0;
                  if (bypass_A_internal && bypass_B_internal)begin
                   if(INPUT_PRIOPRTY == "A") out_internal = A_internal;
                          else out_internal = B_internal;
                end
                else if (bypass_A_internal)begin
                   out_internal = A_internal;
                end
                else begin
                   out_internal = B_internal;            
                end    
                end  
         
        
        default : out_internal = 'b0 ;  // ADDED
	endcase
end

endmodule
