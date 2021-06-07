`timescale 1ns / 1ps

module top_multiplier(Product, Ready, N, M, Start, Reset, clk);
input  [7:0]N; // Multiplicand
input  [7:0]M; // Multiplier
input Start;   // User Controlled Values
input Reset;
input clk;     // System Clock
output [16:0]Product; // Output
output Ready;         // Tells When Output Should be Observed
wire Ready, Load, Operate, Shift; // Internal Signals

controlunit cu(Ready, Load, Operate, Shift, Start,clk, Reset);
multiplier mlti(Product, M, N, Reset, Load, Operate, Shift);

endmodule
