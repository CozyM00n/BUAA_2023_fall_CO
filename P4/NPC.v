`timescale 1ns / 1ps

module NPC(
	input [31:0] pc,
	input [2:0] npcOp,
	input [31:0] ra,
	input [25:0] imm26,
	input zero,
	output [31:0] pc4,
	output reg [31:0] npc
    );

	assign pc4 = pc + 4;
	always@(*) begin
		case(npcOp) 
			3'b000: begin //pc+4
				npc <= pc + 4;
			end
			3'b001: begin //beq
				if(zero) 
					npc <= pc+4+ {{14{imm26[15]}}, imm26[15:0], {2{1'b0}} };
				else npc <= pc + 4;
			end
			3'b010: begin//jal
				npc <= {{pc[31:28]},imm26, {2{1'b0}} };
			end
			3'b011:begin//jr
				npc <= ra;
			end
		endcase
	end

endmodule
