`timescale 1ns / 1ps
`include "const.v"
module D_CMP(
	input [31:0] rsData,
	input [31:0] rtData,
	input [2:0] CMPop,
	
	output jump
    );
	
	wire equ = (rsData == rtData);
	wire bltzal = ($signed(rsData) < 0); 
	assign jump = (CMPop == `CMP_beq && equ) ? 1 : 
					  (CMPop == `CMP_bne && !equ) ? 1 :
					  (CMPop == `CMP_bltzal && bltzal) ? 1 : 0;

endmodule
