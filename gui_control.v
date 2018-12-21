module gui_control (
		input clk,
		input reset,
		input start,
		input isDead,
		output reg showTitle,
		output reg drawMap,
		output reg showGameOver,
		output reg flashRed,
		output reg plot,
		output reg title_done
	);
	
	
	localparam
		DRAW_TITLE = 4'd0, 
		TITLE_WAIT = 4'd1,
		DRAW_MAP = 4'd2,
		GAME_OVER_WAIT = 4'd3,
		FLASH_RED = 4'd4,
		DRAW_GAME_OVER = 4'd5,
		GAME_OVER = 4'd6,
		RESTART_WAIT = 4'd7;

	reg [3:0] curr_state, next_state;
	reg [14:0] pixel_counter;
	
	
	localparam num_pixels = 32'd19119;
	
	always @(*)
	begin
		case (curr_state)
		
			DRAW_TITLE : 
			
			next_state = pixel_counter == num_pixels ? TITLE_WAIT : DRAW_TITLE;
			
			TITLE_WAIT: 
			
			next_state = start? DRAW_MAP : TITLE_WAIT; // TODO adapt to key, space
			
			DRAW_MAP:
		
			next_state = pixel_counter == num_pixels? GAME_OVER_WAIT : DRAW_MAP;
		
			GAME_OVER_WAIT:
			
			next_state = isDead? FLASH_RED : GAME_OVER_WAIT;
			
			FLASH_RED:
			
			next_state = pixel_counter == num_pixels? DRAW_GAME_OVER : FLASH_RED; 
			
			DRAW_GAME_OVER:
			
			next_state = pixel_counter == num_pixels ? GAME_OVER: DRAW_GAME_OVER;
		
			GAME_OVER:
			
			next_state = start ? RESTART_WAIT : GAME_OVER;
			
			RESTART_WAIT: 
			
			next_state = start? DRAW_TITLE : RESTART_WAIT;

		endcase
	end

	always @(*)
	begin
		title_done = 1'b0;
		drawMap = 1'b0;
		showGameOver = 1'b0;
		showTitle = 1'b0;
		flashRed = 1'b0;
		plot = 1'b0;
		case (curr_state)
			
			DRAW_TITLE:
			begin
				showTitle = 1'b1;
				plot = 1'b1;
			end
			
			DRAW_MAP:
		   begin
				drawMap = 1'b1;
				plot = 1'b1;
			end
			
			FLASH_RED:
			begin 
				flashRed = 1'b1;
				plot = 1'b1;
			end
			
			DRAW_GAME_OVER: 
			begin
				showGameOver = 1'b1;
				plot = 1'b1;
			end
			
			GAME_OVER_WAIT: title_done = 1'b1;

		endcase
	end

	always @(posedge clk)
	begin
		if (!reset)
		begin
			curr_state <= DRAW_TITLE;
			pixel_counter <= 0;
		end
		
		else
		begin
			
			curr_state <= next_state;
			
			if (pixel_counter == num_pixels)
				pixel_counter <= 0;
			
			else
				if (curr_state == DRAW_TITLE || curr_state == DRAW_GAME_OVER ||
						curr_state == FLASH_RED || curr_state == DRAW_MAP)
					pixel_counter <= pixel_counter + 1'b1;
		end
	end
endmodule
