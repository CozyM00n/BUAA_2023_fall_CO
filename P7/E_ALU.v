`timescale 1ns / 1ps
`include "const.v"

module E_ALU(
	input [31:0] A,
	input [31:0] B,
	input [3:0] ALUop,
	input ovf,
	input load,
	input store,
	output reg [31:0] ALUres,
	output ALU_ov,
	output ALU_AdEL,//取数异常
	output ALU_AdES // 存数异常
    );
	wire [32:0] ext_A = {A[31], A};
	wire [32:0] ext_B = {B[31], B};
	wire [32:0] ext_ans = (ALUop == `ALU_add) ? ext_A + ext_B:
								(ALUop == `ALU_sub) ? ext_A - ext_B : 33'b0;
	assign ALU_ov = ovf && (ext_ans[32] != ext_ans[31]);
	assign ALU_AdEL = load && (ext_ans[32] != ext_ans[31]);//针对内存
	assign ALU_AdES  = store && (ext_ans[32] != ext_ans[31]);
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
