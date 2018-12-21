module control(load_default_head, load_part_into_ram, inc_address, load_ram_into_current, 
					draw_ram, drawStatus, inc_check, load_head_into_prev,
					update_head, load_prev_into_ram, load_current_into_prev, reset_ram,
					erase_trail, draw_apple, reset_address,
					clk, reset, update, has_collided, isDead, title_done);
		
	input clk;   
	input reset; // Indicates whether to restart the game
	input update; // Indicates whether we continue updating
	input has_collided; // Indicates whether snake head has hit the apple
	input isDead; // Indicates whether the snake died
	input title_done; 
	
	// The different states that get activated
	output reg load_default_head, load_part_into_ram, inc_address;
	output reg load_ram_into_current, draw_ram, inc_check;
	output reg update_head, load_head_into_prev, reset_address;
	output reg load_prev_into_ram, load_current_into_prev, erase_trail, draw_apple;
	
	output reg [3:0] drawStatus; // Indicates the status of drawing
	output reg reset_ram; // Indicates whether we reset our RAM module
	
	
	// State controllers
	reg [4:0] current_state, next_state;
	
	
	// Body Controllers
	reg [8:0] snakeSize;
	reg [8:0] bodyCounter;

	// A wire that indicates whether we have finished iterating over the snake body
	wire iterating_over_body = bodyCounter < snakeSize - 1;

	// Draw controller
	reg [3:0] drawCounter;
	
	// A wire that indicates whether we have finished drawing the current part
	wire stopDrawSignal = drawCounter < 15;
	
	
	// Here are the different states
	localparam
				
				SETUP_LOAD_DEFAULT_HEAD = 5'd0,  // i.e. default state: Reset RAM address and counter
				
				// ======== Setup =============
				SETUP_LOAD_PART_INTO_RAM = 5'd1, // Load coordinates into address of RAM
				SETUP_LOAD_RAM_WAIT = 5'd2, // Leave stable for one clock cycle
				SETUP_INCREMENT_ADDRESS = 5'd3, // Loop logic
				SETUP_RESET = 5'd4, // End of setup phase, start of draw phase
				// ======== End Setup ========= 
				
				// ======== Start Draw ========
				DRAW_LOAD_RAM_INTO_CURRENT = 5'd5, // Load contents of RAM at current address, into current
				DRAW_RAM = 5'd6,
				DRAW_INCREMENT_ADDRESS = 5'd7,
				DRAW_RESET = 5'd8,
				// ======= End Draw ===========
				
				// ======= Start Apple ========
				DRAW_APPLE = 5'd9,
				APPLE_RESET = 5'd10,
				// ======= End Apple ==========
				
				// ======= Start Movement =====
				UPDATE_HEAD = 5'd11,
				MOV_COLLISION_CHECK = 5'd12,
				MOV_LOAD_HEAD_INTO_PREV = 5'd13,
				MOV_LOAD_RAM_INTO_CURRENT = 5'd14,
				MOV_LOAD_PREV_INTO_RAM = 5'd15,
				MOV_PREV_LOAD_WAIT = 5'd16,
				MOV_LOAD_CURRRENT_INTO_PREV = 5'd17,
				PREV_CURR_WAIT = 5'd18,
				MOV_RESET = 5'd19,
				WAIT_MOVE = 5'd20,
				// ======= End Movement =======
				
				// ======= Start Erase ========
				ERASE_TRAIL = 5'd21,
				WAIT_FOR_TITLE = 5'd22;
				
	// Describe the state table
	
	always @(*) 
	begin 
		case (current_state) // Toggle through the states
				
				WAIT_FOR_TITLE :
				
					next_state = title_done? SETUP_LOAD_DEFAULT_HEAD : WAIT_FOR_TITLE;
				
				SETUP_LOAD_DEFAULT_HEAD : 
				
					next_state = SETUP_LOAD_PART_INTO_RAM;
				
				SETUP_LOAD_PART_INTO_RAM : 
				
					next_state = SETUP_LOAD_RAM_WAIT;
				
				SETUP_LOAD_RAM_WAIT : 
				
					next_state = SETUP_INCREMENT_ADDRESS;
				
				SETUP_INCREMENT_ADDRESS : 
				
					next_state = iterating_over_body 
					? SETUP_LOAD_PART_INTO_RAM : SETUP_RESET; 
			
				SETUP_RESET : 
				
					next_state = DRAW_LOAD_RAM_INTO_CURRENT;
					
				
				DRAW_LOAD_RAM_INTO_CURRENT : 
				
					next_state = DRAW_RAM;
				
				DRAW_RAM: 
				
					next_state = stopDrawSignal ? 
					DRAW_RAM : DRAW_INCREMENT_ADDRESS;
				
				DRAW_INCREMENT_ADDRESS: 
				
					next_state = iterating_over_body ?
					DRAW_LOAD_RAM_INTO_CURRENT	: DRAW_RESET;
				
				DRAW_RESET: 
					
					next_state = DRAW_APPLE;
					
				DRAW_APPLE : 
					
					next_state = stopDrawSignal ?
					DRAW_APPLE : APPLE_RESET;
					
				APPLE_RESET :
				
					next_state = UPDATE_HEAD;
				
				UPDATE_HEAD: 
				
					next_state = MOV_COLLISION_CHECK;
					
				MOV_COLLISION_CHECK:
					
					next_state = MOV_LOAD_HEAD_INTO_PREV;
				
				MOV_LOAD_HEAD_INTO_PREV: 
				
					next_state = MOV_LOAD_RAM_INTO_CURRENT;
				
				MOV_LOAD_RAM_INTO_CURRENT: 
				
					next_state = MOV_LOAD_PREV_INTO_RAM;
				
				MOV_LOAD_PREV_INTO_RAM: 
				
					next_state = MOV_PREV_LOAD_WAIT;
				
				MOV_PREV_LOAD_WAIT: 
				
					next_state = MOV_LOAD_CURRRENT_INTO_PREV;
				
				MOV_LOAD_CURRRENT_INTO_PREV: 
				
					next_state = iterating_over_body?
					PREV_CURR_WAIT: MOV_RESET;
				
				PREV_CURR_WAIT: 
				
					next_state = MOV_LOAD_RAM_INTO_CURRENT;
					
				MOV_RESET:
					
					next_state = WAIT_MOVE;
						
				ERASE_TRAIL: 
				
					next_state = stopDrawSignal? ERASE_TRAIL: SETUP_RESET;
				
				WAIT_MOVE: 
				
					next_state = update ? ERASE_TRAIL: WAIT_MOVE;
				
				default :
			
					next_state = WAIT_FOR_TITLE;
					
		endcase
		
		if (isDead)
			next_state = WAIT_FOR_TITLE;
	end
	
	// Describe the output logic
	
	always @(*)
	begin: state_result
        load_default_head = 1'b0; // By default make everything 0
        reset_ram = 1'b0;
		  load_part_into_ram = 1'b0;
		  inc_check = 1'b0;
		  inc_address = 1'b0;
		  update_head = 1'b0;
		  load_ram_into_current = 1'b0;
		  load_prev_into_ram = 1'b0;
		  drawStatus = 4'b0;
		  load_head_into_prev = 1'b0;
		  load_current_into_prev = 1'b0;
		  draw_ram = 1'b0;
		  erase_trail = 1'b0;
		  draw_apple = 1'b0;
		  reset_address = 1'b0;
		  
		  case(current_state)
		  
				WAIT_FOR_TITLE: 
				begin
					inc_address = 1'b1;
					reset_ram = 1'b1;
				end
				
				SETUP_LOAD_DEFAULT_HEAD: 
				
				begin 
					reset_address = 1'b1;
					load_default_head = 1'b1;
				end
				
				SETUP_LOAD_PART_INTO_RAM: 
				
					load_part_into_ram = 1'b1;
				
				SETUP_INCREMENT_ADDRESS: 
					
					inc_address = 1'b1;
				
				SETUP_RESET:
					
					reset_address = 1'b1;
				
				DRAW_LOAD_RAM_INTO_CURRENT:
			
					load_ram_into_current = 1'b1;
				
				DRAW_RAM:
				
				begin
					draw_ram = 1'b1;
					drawStatus = drawCounter;
				end
				
				DRAW_APPLE:
				
				begin
					draw_apple = 1'b1;
					drawStatus = drawCounter;
				end
				
				DRAW_INCREMENT_ADDRESS: 
				
					inc_address = 1'b1;
				
				DRAW_RESET: 
				
					reset_address = 1'b1;
					
				MOV_COLLISION_CHECK:
					
					inc_check = 1'b1;
				
				UPDATE_HEAD: 
				
					update_head = 1'b1;
				
				MOV_LOAD_HEAD_INTO_PREV: 
				
					load_head_into_prev = 1'b1;
				
				MOV_LOAD_RAM_INTO_CURRENT: 
				
					load_ram_into_current = 1'b1;
				
				MOV_LOAD_PREV_INTO_RAM: 
				
					load_prev_into_ram = 1'b1;
				
				MOV_LOAD_CURRRENT_INTO_PREV: 
				
				begin
					load_current_into_prev = 1'b1;
					inc_address = 1'b1;
				end
				
				MOV_RESET:
			
					reset_address = 1'b1;
				
				ERASE_TRAIL:
				
				begin
					erase_trail = 1'b1;
					drawStatus = drawCounter;
				end
				
		  endcase	
	end

// Describe the State Register

always @(posedge clk, negedge reset) 
begin
		if (!reset) // Reset the circuit, or game over
		begin
			current_state <= WAIT_FOR_TITLE; // Go back to idle state
			bodyCounter <= 0; // Reset counter
			drawCounter <= 0; // Reset draw counter
			snakeSize <= 9'd3; // Start with snake size 3
		end
		
		else begin
		
		if (current_state == WAIT_FOR_TITLE 
		|| current_state == SETUP_RESET 
		|| current_state == DRAW_RESET
		|| current_state == MOV_RESET
		|| current_state == APPLE_RESET) // Reset the registers
		begin
			bodyCounter <= 0;
			drawCounter <= 0;
		end
		
		if (current_state == SETUP_INCREMENT_ADDRESS 
		|| current_state == DRAW_INCREMENT_ADDRESS
		|| current_state == MOV_LOAD_CURRRENT_INTO_PREV) // Increment body counter
		begin
			bodyCounter <= bodyCounter + 1'b1;
			drawCounter <= 0;
		end
		
		if (current_state == DRAW_RAM 
		|| current_state == ERASE_TRAIL
		|| current_state == DRAW_APPLE) // Increment draw counter
		begin
			drawCounter <= drawCounter + 1'b1;	
		end
		 
		current_state <= next_state;
		
		if (has_collided)
				snakeSize <= snakeSize + 9'd3;

		if (isDead)
				snakeSize <= 9'd3;
		
		end	
end

endmodule
