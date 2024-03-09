`timescale 1ns / 1ps

module splitter(
	input [31:0] instr,
	output [5:0] opCode,
	output [4:0] rs, 
	output [4:0] rt,
	output [4:0] rd,
	output [4:0] shamt,
	output [5:0] func,
	output [15:0] imm16,
	output [25:0] imm26
    );

	assign opCode = {instr[31:26]};
	assign rs = {instr[25:21]};
	 assign rt = {instr[20:16]};
	 assign rd = {instr[15:11]};
	 assign shamt = {instr[10:6]};
	 assign func = {instr[5:0]};
	 assign imm16 = {instr[15:0]};
	 assign imm26 = {instr[25:0]};

endmodule
