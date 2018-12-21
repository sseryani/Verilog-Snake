module combined_gui (input clk, input reset, input start, input isDead, 
							output [7:0] x, 
							output [6:0] y, 
							output [2:0] colour,
							output plot);
							
		wire title_done;
	
	
		gui_control spl(
		.clk(clk),
		.reset(reset),
		.start(start),
		.isDead(isDead),
		.showTitle(showTitle),
		.drawMap(drawBlack),
		.showGameOver(showGameOver),
		.title_done(title_done),
		.flashRed(flash),
		.plot(plot)
		);
		
		
		
		gui_datapath db(
		.clk(clk),
		.reset(reset),
		.showTitle(showTitle),
		.showMap(drawBlack),
		.showGameOver(showGameOver),
		.flash(flash),
		.x(x),
		.y(y),
		.colourOut(colour)
		);

		
		
endmodule
