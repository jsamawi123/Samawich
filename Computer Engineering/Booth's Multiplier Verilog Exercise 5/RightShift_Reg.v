`timescale 1ns / 1ps

module asr17(F,G, Multi, Cell, Product, I, StartI, Load, Shift, Reset);
input [7:0] I; // Input From Adder
input [7:0] StartI; // Used To Fill Multiplier Initially
input Load;
input Shift;
input Reset;
output reg F; // bi - 1
output reg G; // bi
output reg [7:0] Cell; // Output of Adder Goes Here
output reg [7:0] Multi; // Holds Multiplier
output reg [16:0] Product;

always @ (posedge Shift or posedge Load) begin
    if(Reset == 1'b1) begin
		Multi <= 8'b00000000;   // Set Multiplier
		Cell <= 8'b00000000;// Reset Cell
		F <= 1'b0; // Reset F
		G <= 1'b0;    
		Product[16] <= 1'b0;
		Product[15:8] <= 8'b00000000;
		Product[7:0]  <= 8'b00000000;
    #5;
    end 
	else if(Load == 1'b1 & Shift == 1'b0) begin
		Multi <= StartI;   // Set Multiplier
		Cell <= 8'b00000000;// Reset Cell
		F <= 1'b0; // Reset F
		G <= StartI[0];
    #5;
    end 
	else begin
		Cell[6:0] <= I[7:1];
		Cell[7] <= I[7];
		F <= Multi[0];
		G <= Multi[1];
		Multi[6:0] <= Multi[7:1];
		Multi[7] <= I[0];
		Product[16] <= Cell[7];
		Product[15:8] <= Cell;
		Product[7:0]  <= Multi;
    #5;
    end
end

endmodule
