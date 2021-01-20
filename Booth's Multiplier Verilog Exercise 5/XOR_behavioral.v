`timescale 1ns / 1ps

module xorb(Y, U, V);
input U,V;
output reg Y;

always @ (U or V) begin
    if (U == 1'b1 & V == 1'b1)
    begin
    #10 Y <= 1'b0;
    end else if (U == 1'b0 & V == 1'b0)begin
    #10 Y <= 1'b0;
    end else begin
    #10 Y <= 1'b1;
    end
   
end

endmodule
