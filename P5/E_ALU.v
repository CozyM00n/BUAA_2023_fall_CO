`timescale 1ns / 1ps
`include "const.v"
module E_ALU(
	input [31:0] A,
	input [31:0] B,
	input [3:0] ALUop,
	output reg [31:0] ALUres
    );
	
	always@(*) begin
		case(ALUop) 
			`ALU_add: ALUres = A + B;
			`ALU_sub: ALUres = A - B;
			`ALU_ori: ALUres = A | B;
			`ALU_lui: ALUres = {B[15:0], 16'b0};
			default: ALUres = 0;
		endcase
	end

endmodule
