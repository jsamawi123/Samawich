`timescale 1ns / 1ps

module top_multiplier_tb;
reg [7:0] M; // Multiplicand
reg [7:0] N; // Multiplier
reg Start;
reg Reset; // From User
reg clk;
wire [16:0] Product; // Output
wire Ready;         // Tells When Output Should be Observed

top_multiplier dut(.Product(Product), .Ready(Ready), .M(M), .N(N), .Start(Start), .Reset(Reset), .clk(clk));

initial begin
#0 Reset = 1'b1;
#0 clk = 1'b0;
#1 N = 8'b01100011; // B = 99
#1 M = 8'b01100100; // A = 100

repeat(8) #50 clk = ~clk;
#10 Reset = 1'b0;
#0 Start = 1'b1;             
repeat(60) #50 clk = ~clk;#50 clk = 1'b1;
$finish;
end

endmodule