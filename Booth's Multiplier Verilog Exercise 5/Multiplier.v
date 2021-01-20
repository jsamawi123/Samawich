`timescale 1ns / 1ps

module multiplier(Product, M, N, Reset, Load, Operate, Shift);
input [7:0] M; // Multiplicand
input [7:0] N; // Multiplier
input Reset; // From User
input Load;   // From CU
input Operate;
input Shift;
output [16:0] Product; // Output
wire [7:0] muxout;
wire [7:0] sumout;
wire [7:0] multiout;
wire [7:0] cellout;
wire [16:0] productout;
wire xorout;
wire cout; // Deadwire
wire F; // bi-1
wire G; // bi
wire [7:0] z; // Zeros

assign z = 8'b00000000;
asr17 a(F, G, multiout, cellout, productout, sumout, N, Load, Shift, Reset); // Produces F, G, Cellout and Takes in Sumout, The Multiplier, Start Signal
xorb  x(xorout,F,G); // Chooses for Multiplexer
mux8  m(muxout,z, M, xorout); // Uses Multiplicand, 0000-0000, and xorout
cla8  c(sumout, cout, muxout, cellout, G, Operate); // Produces the Sum, Cout, and Takes in Muxout, Cellout, G as add or Sub
assign Product = productout; 

endmodule
