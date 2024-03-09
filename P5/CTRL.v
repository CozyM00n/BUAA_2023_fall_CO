`timescale 1ns / 1ps
`include "const.v"
module CTRL(
	input [31:0] instr,
	
	output [4:0] rs, 
	output [4:0] rt, 
	output [4:0] rd, 
	output [4:0] shamt,
	output [15:0] imm16,
	output [25:0] imm26,
	
	output [3:0] ALUop,
	output EXTop,
	output [2:0]NPCop,
	output Bsel,
	output [4:0] A3addr,
	output [2:0] RFWDsel,
	output [1:0] DMsel,
	output [1:0] lors,
	output [1:0] CMPop,
	output branch,
	
	output [2:0] rs_Tuse,
	output [2:0] rt_Tuse,
	output [2:0] E_Tnew,
	output [2:0] M_Tnew
    );

	
	wire [5:0] opcode = {instr[31:26]};
	wire [5:0] func = {instr[5:0]};
	
	assign rs = {instr[25:21]};
	assign rt = {instr[20:16]};
	assign rd = {instr[15:11]};
	assign shamt = {instr[10:6]};
	assign imm16 = {instr[15:0]};
	assign imm26 = {instr[25:0]};
	
	wire special, add, sub, ori, lui, lw, sw, beq, jal, jr;
	assign special = (opcode == 0);
	assign add = (special && func == 6'b100_000);
	assign sub = (special && func == 6'b100_010);
	assign ori = (opcode == 6'b001_101);
	assign lui = (opcode == 6'b001_111);
	assign lw = (opcode == 6'b100_011);
	assign sw = (opcode == 6'b101_011);
	assign beq = (opcode == 6'b00_0100);
	assign jal = (opcode == 6'b000_011);
	assign jr = (special && func == 6'b001_000);
	
	assign ALUop = (lui) ? 4'b0010:
						(ori) ? 4'b0011:
						(sub) ? 4'b0001:
						4'b0000;//add
	assign EXTop = (lw | sw );
	assign NPCop = (jr) ? `NPC_rs://use rs
						(jal) ? `NPC_j://calculate in NPC
						(beq) ? `NPC_b://calculate in NPC pc+4+imm
						3'b000;
	assign Bsel = (ori | lw | sw | lui);
	
	assign lors = (sw) ? 2'b10:
						(lw) ? 2'b01: 0;
	
	assign DMsel = 0;
	assign RFWDsel = (add | sub |lui | ori) ? `RFcal://alures
						  (lw) ? `RFload: // DMout
						  (jal) ? `RFjal:// pc+8
						  0;
	assign A3addr = (add | sub) ? rd:
						(lui | ori | lw ) ? rt :
						(jal) ? 5'd31:
	  					0;//default zero
	
	assign branch = (beq);
	assign CMPop = (beq) ? `CMP_beq:
						2'b00;
	
	//when in D,how many Ts before rs/rtdata will be used 
	assign rs_Tuse = (add|sub| sw|lw| ori|lui) ? 3'b001:
							(beq|jr)?3'b000://pc<= rs
							3'b011;//infinite
	assign rt_Tuse = (add|sub) ? 3'b001:
							(sw) ? 2'b010://DM|store in Mstage,write rt to DM
							(beq) ? 3'b000://branch
							3'b011;
	assign E_Tnew = (add|sub|lui|ori) ? 3'b001:
						  (lw) ? 3'b010:
						  3'b000;
	assign M_Tnew = (lw) ? 3'b001:
							3'b000;
	
endmodule
