module gui_datapath (
		input clk,
		input reset,
		input showTitle,
		input showMap,
		input showGameOver,
		input flash,
		output reg [7:0] x,
		output reg [6:0] y,
		output reg [2:0] colourOut
	);
	
	
	wire [2:0] red, black, title_ram_out, map_ram_out, gameover_ram_out;
	reg [14:0] address;



	assign red = 3'b100;
	assign black = 3'b000;
	
	// ram_title title (
	//
	//
	//
	//
	//
	// );

	
	//	ram_map map (
	//
	//
	//
	//
	// );
	
	
	// ram_gameover gameover (
	//
	//
	//
	//
	//
	// );
	
	always @(posedge clk)
	begin
		if (!reset)
		begin
			address <= 15'b0;
		end
		else begin
			if (showTitle || showGameOver || flash || showMap)
				address <= address + 1'b1;
		end
		if (address == 15'd19119) // num_pixel
			address <= 15'b0;
	end

	always @(*)
	begin
	
		colourOut = black;
		
		if (flash)
			colourOut = red;
		else if (showMap)
			colourOut = black; // change to map_ram_out
		else if (showTitle)
			colourOut = 3'b110; // change to title_ram_out
		else if (showGameOver)
			colourOut = 3'b011; // change to gameover_ram_out
			
		x = address % 8'd160;
		y = address / 8'd160;	
	end
	
endmodule
