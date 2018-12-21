module SnakeInterface(clk, reset, plot, title_done, x, y, colour, dirIn);

	input			clk;				//	50 MHz
	input			reset;
	input [3:0] dirIn; 			// The direction
	input 		title_done;
	
	output reg [7:0] x;
	output reg [6:0] y;
	output reg [2:0] colour;
	
	output plot;

// ============================================ Keyboard Logic ===================================================
	
	wire[2:0] direction;
	
	direction_control dc (
						.dirOut(direction),
						.clk(clk),
						.reset(reset),
						.dirIn(dirIn)
						);

	
// ============================================ End Keyboard Logic ===============================================

// ============================================ Game clock  ====================================================
	
	wire update_clk; 
	wire [27:0] rd_out;
	
	RateDivider rd(
					.clk(clk),
					.reset(reset),
					.enable(1'b1),
					.load(28'd30_000_000), // d10_000_000
					.Q(rd_out)
					);
					
	assign update_clk = (rd_out == 28'b0) ? 1'b1 : 1'b0;
	
// ============================================ End Clock Division ======================================

					
// ============================================ Control/Datapath ====================================================

	wire load_default_head, load_part_into_ram, inc_address;
	wire load_ram_into_current, draw_ram; 
	wire update_head, inc_check, load_head_into_prev;
	wire load_prev_into_ram, load_current_into_prev, erase_trail; 
	wire draw_apple;
	wire has_collided;
	wire isDead;
	
	wire plot_snake;
		
	wire reset_ram;
	wire reset_address;
	wire [3:0] drawStatus;
	
	wire [7:0] snake_x_out;
	wire [6:0] snake_y_out;
	wire [2:0] snake_colour_out;
	
	assign plot = plot_snake;
	

	
	control c0 (
					.load_default_head(load_default_head),
					.load_part_into_ram(load_part_into_ram),
					.inc_address(inc_address),
					.load_ram_into_current(load_ram_into_current), 
					.draw_ram(draw_ram),
					.drawStatus(drawStatus),
					.inc_check(inc_check),
					.load_head_into_prev(load_head_into_prev),
					.update_head(update_head), 
					.load_prev_into_ram(load_prev_into_ram),
					.load_current_into_prev(load_current_into_prev),
					.reset_ram(reset_ram),
					.erase_trail(erase_trail),
					.title_done(title_done),
					.draw_apple(draw_apple),
					.reset_address(reset_address),
					.clk(clk),
					.reset(reset), 
					.update(update_clk),
					.has_collided(has_collided),
					.isDead(isDead)
					);
			
	datapath d0 (
					 .x(snake_x_out),
					 .y(snake_y_out),
					 .colour(snake_colour_out),
					 .plot(plot_snake),
					 .drawStatus(drawStatus),
					 .load_default_head(load_default_head),
					 .load_part_into_ram(load_part_into_ram),
					 .inc_address(inc_address), 
					 .load_ram_into_current(load_ram_into_current),
					 .draw_ram(draw_ram),
					 .update_head(update_head),
					 .load_head_into_prev(load_head_into_prev),
					 .load_prev_into_ram(load_prev_into_ram),
					 .reset_ram(reset_ram),
					 .load_current_into_prev(load_current_into_prev),
					 .erase_trail(erase_trail),
					 .draw_apple(draw_apple),
					 .reset_address(reset_address),
					 .clk(clk),
					 .reset(reset), 
					 .direction(direction),
					 .isDead(isDead),
					 .inc_check(inc_check), 
					 .good_collision(has_collided)
					 );
					 
// =============================== GUI logic ====================================



// =============================== VGA logic ====================================
	
	always @(*)
	begin
		x = snake_x_out;
		y = snake_y_out;
		colour = snake_colour_out;
	end
		
endmodule
