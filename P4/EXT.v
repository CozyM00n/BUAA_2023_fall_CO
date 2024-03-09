`timescale 1ns / 1ps

module EXT(
	input [15:0] in,
	input extOp,
	output [31:0] out
    );

	assign out = (extOp == 1) ? {{16{in[15]}}, in} : {{16{1'b0}}, in};
endmodule
