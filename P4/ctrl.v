`timescale 1ns / 1ps
module ctrl(
	input [5:0] opCode,
	input [5:0] func,
	output [2:0] NPCOp,
	output [1:0] A3Sel,
	output [1:0] RFWDSel,
	output RFWr,
	output ExtOp,
	output Bsel,
	output [2:0] ALUOp,
	output DMWr
    );
	 
	assign special = (opCode == 6'b000000);
	assign add = (special && func == 6'b100_000);
	assign sub = (special && func == 6'b100_010);
	assign ori = (opCode == 6'b001_101);
	assign lui = (opCode == 6'b001_111);
	assign jal = (opCode == 6'b000_011);
	assign jr = (special && func == 6'b001_000);
	assign j = (opCode == 6'b000_010);
	assign lw = (opCode == 6'b100_011);
	assign sw = (opCode == 6'b101_011);
	assign beq = (opCode == 6'b000_100);
	
	assign NPCOp = (jr)? 3'b011:
						(jal|j) ? 3'b010:
						(beq)? 3'b001:
						3'b000;
	assign A3Sel = (jal) ? 2'b10:
						(add | sub) ? 2'b01:
						2'b00;
	assign RFWDSel = (jal) ? 2'b10:
							(lw) ? 2'b01:
							2'b00;
	
	assign RFWr = (add | sub | ori | lw | lui | jal) ? 1 : 0;
	assign ExtOp = (sw | lw | beq) ? 1 : 0;
	assign Bsel = (sw | lw | ori | lui) ? 1 : 0;
	assign ALUOp = (lui) ? 3'b100 : //000addu / 001subu/011 ori/100 lui
						(ori) ? 3'b011:
						(sub) ? 3'b001:
						3'b000;
	assign DMWr = (sw) ? 1 : 0;
endmodule
