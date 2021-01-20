`timescale 1ns / 1ps

module mux8(Muxout, D1, D2, sel);
input [7:0] D1;
input [7:0] D2;
input sel;
output reg [7:0] Muxout;

always @ (D1 or D2 or sel) begin
	if (sel == 1'b0)
	begin
		#10 Muxout <= D1;
	end else
	begin
		#10 Muxout <= D2;
	end
end

endmodule
