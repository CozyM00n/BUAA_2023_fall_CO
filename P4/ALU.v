`timescale 1ns / 1ps

module ALU(
	input [31:0] inA, 
	input [31:0] inB,
	input [2:0] aluOp, 
	output reg [31:0]aluRes, 
	output zero
    );

	always@(*) begin
		case(aluOp) 
			3'b000: aluRes <= inA + inB;
			3'b001: aluRes <= inA - inB;
			3'b011: aluRes <= inA | inB;
			3'b100: aluRes <= {{inB[15:0]}, {16{1'b0}} };
		endcase
	end
	assign zero = (inA == inB);
endmodule
