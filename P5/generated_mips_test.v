`timescale 1ns / 1ps
module generated_mips_test;
	reg clk; 
	reg reset;
	mips uut (
		.clk(clk), 
		.reset(reset) 
	);
	initial begin
		clk = 0;
		reset = 1;
		#50;
		reset = 0;
	end
	always #10 clk = ~clk;
endmodule
