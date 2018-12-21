// Random (x,y) coordinate generator

module lfsr (
	output reg [7:0] x_out ,
	output reg [6:0] y_out,
	input enable,  
	input clk,  
	input reset              
  );
  
  reg [7:0] temp_x;
  reg [6:0] temp_y;
  
   wire   linear_feedback_x;
   assign linear_feedback_x =  (temp_x[7] ^ temp_x[4] ^ temp_x[1]);
	
	wire linear_feedback_y;
	assign linear_feedback_y =  (temp_y[6] ^ temp_y[4] ^ temp_y[1]);
  
  always @(posedge clk, negedge reset)
  
  if (~reset) 
  begin
    x_out <= 8'd25;
	 y_out <= 7'd40;
	 temp_x = 8'd25;
	 temp_y = 7'd40;
  end 
  
  else begin
  
  if (enable)
  begin
    temp_x = {x_out[6], x_out[5], x_out[4], x_out[3], x_out[2], x_out[1],
            x_out[0], linear_feedback_x};
	 temp_y = {y_out[5], y_out[3], y_out[4], y_out[2], y_out[1],
            y_out[0], linear_feedback_y};
				
		if (temp_x > 145) begin
			temp_x = {1'b0, temp_x[6:0]};
			x_out = temp_x;
		end

		else if (temp_x < 15) begin
			temp_x = {2'b01, temp_x[5:0]};
			x_out = temp_x;
		end
  
		else 
			x_out = temp_x;
  
		if (temp_y > 110) begin
			temp_y = {1'b0, temp_y[5:0]};
			y_out = temp_y;
		end
	
		else if (temp_y < 10) begin
			temp_y = {2'b01, temp_y[4:0]};
			y_out = temp_y;
		end
  
		else
			y_out = temp_y;
		end
  end 
  
 endmodule 
 