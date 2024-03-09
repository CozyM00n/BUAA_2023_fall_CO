`timescale 1ns / 1ps
module F_IFU(
	input [31:0]npc,
	input clk,
	input reset,
	input WE,
	
	output reg [31:0] pc,
	output [31:0] instr
    );
	
	reg [31:0] ROM[0:4095];
	wire [11:0] addr = (pc - 32'h0000_3000) >> 2;
	
	initial begin
		pc <= 32'h0000_3000;
		$readmemh("code.txt", ROM);
	end
	
	always@(posedge clk) begin
		if(reset) begin
			pc <= 32'h0000_3000;
		end
		else if(WE)begin
			pc <= npc;
		end
	end
	assign instr = ROM[addr];
endmodule
