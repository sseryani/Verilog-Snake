`include "snakeram.v"
module datapath(x, y, colour, plot, drawStatus,
					 load_default_head, load_part_into_ram, inc_address, 
					 load_ram_into_current, draw_ram, update_head,
					 load_head_into_prev, load_prev_into_ram, reset_ram,
					 load_current_into_prev, erase_trail, draw_apple,
					 reset_address, clk, reset, direction, isDead, inc_check, 
					 good_collision);
						
	input clk, reset; // Standard signals
	input reset_address; // Reset the RAM address
	input reset_ram; // Reset the RAM module
	input load_default_head, load_part_into_ram, inc_address, load_ram_into_current, draw_ram, update_head;
	input load_prev_into_ram, load_head_into_prev, load_current_into_prev, erase_trail, draw_apple;
	input inc_check;
	
	input [2:0] direction;

	input [3:0] drawStatus;
	
	// Output X
	output reg good_collision;
	output reg isDead;
	output reg [7:0] x;
	output reg [6:0] y;
	output reg plot;
	output reg [2:0] colour;

	// Snake Head coordinates
	reg [7:0] headX;
	reg [6:0] headY;
	
	// Current coordinates
	reg [15:0] currentCoord;
	
	// Previous coordinates
	reg [15:0] prevCoord;
	
	// Default coordinates
	wire [7:0] default_x = 8'd80;
	wire [6:0] default_y = 7'd60;

		 
	// Ram inventory
	wire [15:0] ram_out;
	reg [15:0] ram_in;
	reg ram_wren;  // Write Enable
	reg [10:0] address; // The current memory address

	snakeram r0 (
		.address(address),
		.clock(clk),
		.data(ram_in),
		.wren(ram_wren),
		.q(ram_out)
		);
		
	// ========================= APPLE GENERATION ===============================
	
	wire [7:0] apple_x; 
	wire [6:0] apple_y;
	wire [14:0] apple_coordinates = {apple_x, apple_y};
	
	lfsr rand_gen (
	.x_out(apple_x),
	.y_out(apple_y),
	.enable(good_collision),
	.clk(clk),
	.reset(reset)
	);

	// Describe the circuit logic for the Snake's head 
		 
	always @(posedge clk, negedge reset) 
		
	begin
		
		if (reset == 1'b0)  // If Reset is low,
		begin // // Place Snake Head back at center
				address <= 0;
				isDead <= 0;
				headX <= 0;
				headY <= 0;
				currentCoord <= 0;
				prevCoord <= 0;
		end
		
		else begin
		
		if (address > 2048)
			address <= 0;
		
		if (load_default_head) // Idle Snake, set head at center
		begin
				headX <= default_x;
				headY <= default_y;
		end
		
		if (update_head)
		begin
			if (direction[2] == 1'b1) begin // horizontal movement
				
				if (direction[0] == 1'b1) begin // Go left
					headX <= headX - 8'd5; // Change coordinates by 5
					if (headX < 8'd15) // Snake has hit border
						isDead <= 1;
				end
				
				else begin // Go right
					headX <= headX + 8'd5;
					if (headX > 8'd145)
						isDead <= 1;
				end
			
			end
			
			else if (direction[2] == 1'b0) begin // vertical movement
					
				if (direction[1] == 1'b1) begin // go up
					headY <= headY + 7'd5;
					if (headY > 7'd110)
						isDead <= 1;
				end
				
				else begin // Go down
					headY <= headY - 7'd5;
					if (headY < 7'd10)
						isDead <= 1;
				end
			end
		
		end
		
		if (load_head_into_prev)
			prevCoord <= {1'b0, headX[7:0], headY[6:0]};
		
		if (reset_address)
			address <= 0;
			
		if (reset_ram)
			isDead <= 0;
			
		if (inc_address)
			address <= address + 1'b1;
			
		if (load_ram_into_current)
			currentCoord <= ram_out; // Read coordinates from RAM address
			
		if (load_current_into_prev)
			prevCoord <= currentCoord;
			
		if (address != 0 && ram_out == {headX, headY} && draw_ram) // head-body collision
				isDead <= 1;
		end
	end
	
	always @(*)
	begin
		ram_in = 0;
		ram_wren = 0;
		plot = 0;
		x = 0;
		y = 0;
		colour = 0;
		good_collision = 0;
		
		if (reset_ram)
		begin
			ram_wren = 1;
			ram_in = 16'b1000_0000_0000_0000;
		end
		
		if (load_part_into_ram)
		begin
			ram_in = {1'b0, default_x, default_y + address[6:0] + address[6:0] + address[6:0] + address[6:0]};
			ram_wren = 1'b1;
		end
		
		if (inc_check)
			good_collision = headX == apple_x && headY == apple_y;
		
		if (load_prev_into_ram)
		begin
			ram_wren = 1'b1;
			ram_in = {1'b0, prevCoord[14:0]};
		end
		
		if (draw_apple)
		begin
			if (drawStatus == 5 || drawStatus == 6 || drawStatus == 9 || drawStatus == 10)
				plot = 1'b1;
		
			x = apple_x + drawStatus % 8'd4;
			y = apple_y + drawStatus / 7'd4;
			colour = 3'b100;
		end
		
		if (draw_ram)
		begin
			
			if (address == 0) // Snake Head
			begin 
				x = ram_out[14:7] + drawStatus % 8'd4;
				y = ram_out[6:0] + drawStatus / 7'd4;
				plot = 1'b1;
				colour = 3'b110;
			end
				
			else 
			begin // SnakeBody
				x = ram_out[14:7] + drawStatus % 8'd4;
				y = ram_out[6:0] + drawStatus / 7'd4;
				if (currentCoord[15] != 1'b1) // current[15] == 1 <=> Snake part should not be visible
					plot = 1'b1;
						
				colour = 3'b110;
				
			end
		
		
		end
		
		if (erase_trail)
		begin
			
			if (currentCoord[15] != 1'b1) // current[15] == 1 <=> Snake part has not been initialized
				plot = 1;
			x = currentCoord[14:7] + drawStatus % 8'd4;
			y = currentCoord[6:0] + drawStatus / 7'd4;
			
		end
	
	
		if (reset_ram)
		begin
			ram_in = 16'b1000_0000_0000_0000;
			ram_wren = 1'b1; 
		end
		
	end

	
endmodule
