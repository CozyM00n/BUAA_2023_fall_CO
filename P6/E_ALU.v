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
			`ALU_or: ALUres = A | B;
			`ALU_and: ALUres = A & B;
			`ALU_lui: ALUres = {B[15:0], 16'b0};
			`ALU_slt: ALUres = ($signed(A) < $signed(B));
			`ALU_sltu: ALUres = (A < B);
			default: ALUres = 0;
		endcase
	end

endmodule
