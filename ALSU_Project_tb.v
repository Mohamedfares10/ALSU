module ALSU_Project_tb;
reg [2:0] A_tb, B_tb, opcode_tb;
reg cin_tb, serial_in_tb, diraction_tb;
reg red_op_A_tb, red_op_B_tb;
reg bypass_A_tb, bypass_B_tb;
reg CLK_tb, RST_n_tb;
wire [5:0] out_tb;
wire [15:0] leds_tb;
integer i;

ALSU_Project dut(
.A(A_tb), 
.B(B_tb), 
.opcode(opcode_tb),
.cin(cin_tb),
.serial_in(serial_in_tb), 
.diraction(diraction_tb),
.red_op_A(red_op_A_tb), 
.red_op_B(red_op_B_tb),       
.bypass_A(bypass_A_tb),
.bypass_B(bypass_B_tb),       
.CLK(CLK_tb),
.RST_n(RST_n_tb),               
.out(out_tb), 
.leds(leds_tb)
              ); 


always #2 CLK_tb = ~CLK_tb;

initial begin
RST_n_tb = 0;
#4;
RST_n_tb = 1;
end 

initial begin
CLK_tb = 0;

/*
for(i = 0 ; i < 250 ; i = i + 1)
begin
    A_tb = $random;
    B_tb = $random;
    opcode_tb = $random;
    cin_tb = $random;
    serial_in_tb = $random;
    diraction_tb = $random;
    red_op_A_tb = $random;
    red_op_B_tb = $random;
    bypass_A_tb = $random;
    bypass_B_tb = $random;

    #10;
end */
                  ////test bypass///
    A_tb =111;
    B_tb =011;
    opcode_tb = 010; 
    cin_tb = 0;
    serial_in_tb =0;
    diraction_tb =0;
    red_op_A_tb = 0;
    red_op_B_tb = 0;
    bypass_A_tb = 0;
    bypass_B_tb = 1;
    #20; 
    bypass_A_tb = 1;
    bypass_B_tb = 0;
    #20; 
    bypass_A_tb = 1;
    bypass_B_tb = 1;
    #20; 
    bypass_A_tb = 0;
    bypass_B_tb = 0;
    #20; 
    opcode_tb = 010; ////test invalid///
    cin_tb = 0;
    serial_in_tb =0;
    diraction_tb =0;
    red_op_A_tb = 1;        
    red_op_B_tb = 0;
    bypass_A_tb = 0;
    bypass_B_tb = 0;
    #20;
    opcode_tb = 010; ////test addition///
    cin_tb = 0;
    serial_in_tb =0;
    diraction_tb =0;
    red_op_A_tb = 0;        
    red_op_B_tb = 0;
    bypass_A_tb = 0;
    bypass_B_tb = 0;
    #20;
    opcode_tb = 000;    ////test and///
    #20;
    opcode_tb = 000;
    red_op_A_tb = 1;        ////test and red A///
    red_op_B_tb = 0;

    #20;
    opcode_tb = 001;      ////test xor///
    red_op_A_tb = 0;        
    red_op_B_tb = 0;
    #20;
    opcode_tb = 001; 
    red_op_A_tb = 0;          ////test xor red b ///
    red_op_B_tb = 1;
    #20;
    opcode_tb = 011;    ////test mult///
    red_op_A_tb = 0;        
    red_op_B_tb = 0;
    #20;
    opcode_tb = 100; ////test shift left & (si = 1) ///
    red_op_A_tb = 0;        
    red_op_B_tb = 0;
    diraction_tb = 1;
    serial_in_tb = 1;
    #20;
    diraction_tb = 0;   ////test shift right & (si = 0) ///
    serial_in_tb = 0; 
    #20;
    opcode_tb = 101;    ////test rotate right  ///
    diraction_tb = 0;
    #20;
    opcode_tb = 101;   ////test rotate left  ///
    diraction_tb = 1;
    #20;
    opcode_tb = 110; ////test invalid  ///
    #20;

$stop;
end  
initial begin
$monitor("time=%0t A_tb=%b B_tb=%b opcode_tb=%B out_tb=%b red_op_A_tb=%b red_op_B_tb=%b bypass_A_tb=%b bypass_B_tb=%b diraction_tb=%b serial_in_tb=%b ",$time,A_tb,B_tb,opcode_tb,out_tb,red_op_A_tb,red_op_B_tb,bypass_A_tb,bypass_B_tb,serial_in_tb,diraction_tb);
end

endmodule
