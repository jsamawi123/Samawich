`timescale 1ns / 1ps

module controlunit(Ready, Load, Operate, Shift, Start, clk, Reset);
input Start;
input clk;
input Reset;
reg [4:0] done; // Counter Used For Indexing and Knowing When Done
reg latch;
reg go;
output reg Ready;
output reg Load;
output reg Operate;
output reg Shift;

always @ (posedge clk) begin
    if(latch !== 1'b1) begin
		done <= 5'b00000;
    end
    if(clk) begin
		latch <= "1";
    end
	
    if(Reset == 1'b1 & go == 1'b1) begin
        Shift <= "0";
        Operate <= "0";
        Load <= "0";
        Ready <= "0";
        go <= "0";
        done <= 5'b00000;
    end 
	else if(done >= 5'b01000) begin // Signals that Values have been Flushed
		go <= "1";
    end 
	else if (Ready !== 1'b1) begin           // Flushes Values Of High Impedance Out Of Registers
        if(done[0] == 1'b1) begin
			Shift <= "0";
			Operate <= "0";
			Load <= "1";
        end 
		else begin
			Load <= "0";
			Shift <= "0";
			Operate <= "1";
        end  
        done = done + clk; // Counts How Many Times Loop has Been Done  
        go <= "0";
    end
           
    if(Reset == 1'b1 & go == 1'b1) begin
        Shift <= "0";
        Operate <= "0";
        Load <= "0";
        Ready <= "0";
        go <= "0";
        done <= 5'b00000;
    end 
	else if (Start == 1'b1 & go == 1'b1 & Ready !== 1'b1) begin // Multiplication Can Begin
        if(done[0] == 1'b1) begin
			Load <= "0";
			Operate <= "0";
			Shift <= "1";
        end 
		else begin  
			Load <= "0";
			Shift <= "0";
			Operate <= "1";
        end  
        done = done + clk; // Counts How Many Times Loop has Been Done        
    end
    
    if(Reset == 1'b1 & go == 1'b1) begin
        Shift <= "0";
        Operate <= "0";
        Load <= "0";
        Ready <= "0";
        go <= "0";
        done <= 5'b00000;
    end 
	else if(done >= 5'b11011) begin // Signals that Multiplication is Done
		Ready <= "1";
    end 
end

endmodule
