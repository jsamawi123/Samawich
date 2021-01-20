`timescale 1ns / 1ps

module cla8(Sum, Cout, F,G,Ci,Operate);
input [7:0] F;
input [7:0] G;
input Operate;
input Ci;
output reg [7:0] Sum;
output reg Cout;
reg [8:0] t;
reg [7:0] inv;

always @ (posedge Operate) begin
	if(Ci) begin
		inv = -F;
		t <= inv + G;
	end 
	else begin
		t <= F + G;
	end
	#25 Sum <= t[7:0];
	#25 Cout <= t[8];
end

endmodule
