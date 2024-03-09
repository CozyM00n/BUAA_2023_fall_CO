`timescale 1ns / 1ps
`include "ctrl.v"
`include "ALU.v"
`include "DM.v"
`include "EXT.v"
`include "GRF.v"
`include "NPC.v"
`include "PC.v"
`include "splitter.v"

module mips(
	input clk, 
	input reset
    );
	 wire [31:0] pc, pc4, instr, npc, RFrd1, RFrd2, ALUres, imm32, inB, RFwd, DMaddr, DMout;
	 wire [2:0] ALUop, NPCop;
	 wire[1:0]  A3sel, RFWDsel;
	 wire [5:0] opcode, func;
	 wire [4:0] rs, rt, rd, shamt, addr;
	 wire [15:0] imm16;
	 wire[25:0] imm26;
	 wire EXTop, zero, DMwr, RFwr, Bsel;/////////////////////���Բ�д��
	 PC _pc (
    .clk(clk),
    .reset(reset), 
    .npc(npc), 
    .pc(pc), 
    .instr(instr)
    );
	NPC _npc (
    .pc(pc), 
    .npcOp(NPCop), 
    .ra(RFrd1), 
    .imm26(imm26), 
    .zero(zero), 
    .pc4(pc4), 
    .npc(npc)
    );
	 
	 EXT _ext (
    .in(imm16), 
    .extOp(EXTop), 
    .out(imm32)
    );
	 
	 splitter _splitter (
    .instr(instr), 
    .opCode(opcode), 
    .rs(rs), 
    .rt(rt), 
    .rd(rd), 
    .shamt(shamt), 
    .func(func), 
    .imm16(imm16), 
    .imm26(imm26)
    );

	ctrl _ctrl (
    .opCode(opcode), 
    .func(func), 
    .NPCOp(NPCop), 
    .A3Sel(A3sel), 
    .RFWDSel(RFWDsel), 
    .RFWr(RFwr), 
    .ExtOp(EXTop), 
    .Bsel(Bsel), 
    .ALUOp(ALUop), 
    .DMWr(DMwr)
    );
	assign inB = (Bsel == 0) ? RFrd2 : imm32;
	ALU _alu (
    .inA(RFrd1), 
    .inB(inB), 
    .aluOp(ALUop), 
    .aluRes(ALUres), 
    .zero(zero)
    );

	 assign addr = (A3sel == 0) ? rt:
						(A3sel == 2'b01) ? rd :
						(A3sel == 2'b10) ? 5'd31:
						0;////////////////////������������
	 assign RFwd = (RFWDsel == 0) ? ALUres : 
						(RFWDsel == 2'b01) ? DMout : 
						(RFWDsel == 2'b10) ? pc4:
						0;////////////////////������������
	  GRF _grf (
    .clk(clk), 
    .reset(reset), 
    .RFWe(RFwr), 
    .A1(rs), 
    .A2(rt), 
    .Addr(addr), 
    .RFWd(RFwd), 
    .PC(pc), 
    .RD1(RFrd1), 
    .RD2(RFrd2)
    );
	 assign DMaddr = ALUres;
	 
	 DM _dm (
    .clk(clk), 
    .reset(reset), 
    .DMWr(DMwr), 
    .addr(ALUres), 
    .WD(RFrd2), 
    .PC(pc), 
    .DMOut(DMout)
    );
	

endmodule
