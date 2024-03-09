`timescale 1ns / 1ps
`include "const.v"
module D_CMP(
	input [31:0] rsData,
	input [31:0] rtData,
	input [1:0] CMPop,
	
	output jump
    );
	
	wire equ = (rsData == rtData);
	assign jump = (CMPop == `CMP_beq && equ) ? 1 : 0;

endmodule
