// dirOut[2] == 1 -> Horizontal movement, == 0 -> Vertical movement.
// dirOut[0] == 1 -> Left, == 0 -> Right.
// dirOut[1] == 1 -> Up  , == 0 -> Down .

module direction_control(dirOut, dirIn, reset, clk);

	output reg [2:0] dirOut; // Signal to datapath
	
	input [3:0] dirIn; // The inputted direction
	input reset;
	input clk;
	
	
	wire left = dirIn[3];
	wire up = dirIn[2];
	wire down = dirIn[1];
	wire right = dirIn[0];
	
	always @(posedge clk, negedge reset)
	begin
		if (!reset)
			dirOut <= 3'b0;
		
		else 
		begin
				if (left) begin
				dirOut[0] <= 1;
				dirOut[1] <= 0;
				dirOut[2] <= 1;
				end
				
				else if (up) begin
				dirOut[0] <= 0;
				dirOut[1] <= 1;
				dirOut[2] <= 0;
				end
				
				else if (down) begin
				dirOut[0] <= 0;
				dirOut[1] <= 0;
				dirOut[2] <= 0;
				end
				
				else if (right) begin
				dirOut[0] <= 0;
				dirOut[1] <= 0;
				dirOut[2] <= 1;
				end
				
				else 
				dirOut <= dirOut;
		
		end
	
	end

			
endmodule
