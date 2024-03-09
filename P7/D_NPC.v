`timescale 1ns / 1ps
`include "const.v"

module D_NPC(
	input [31:0] pc_F,
	input [31:0] pc_D,
	input b_jump,
	input [25:0] imm26,
	input [2:0] NPCop,
	input [31:0] rs,
	input [31:0] EPC,
	input eret,
	input Req,
	
	output [31:0] npc
    );
	
	assign npc = (Req) ? 32'h0000_4180 :
					(eret) ? EPC + 4:
					(NPCop == `NPC_b && b_jump) ? pc_D + 4 + {{14{imm26[15]}},imm26[15:0],2'b00}:
					(NPCop == `NPC_j) ? {pc_D[31:28], imm26, 2'b00}:
					(NPCop == `NPC_rs) ? rs :
					pc_F + 4;
endmodule
