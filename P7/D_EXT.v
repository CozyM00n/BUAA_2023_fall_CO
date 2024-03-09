`timescale 1ns / 1ps

module D_EXT(
	input [15:0] in,
	input EXTop,
	output [31:0] out
    );
	
	assign out = (EXTop == 1) ? {{16{in[15]}},in}:
										{{16{1'b0}},in};

endmodule
