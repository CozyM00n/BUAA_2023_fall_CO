`timescale 1ns / 1ps

module MREG(
	input clk,
	input reset,
	input WE,
	input [31:0] instr_in,
	input [31:0] pc_in,
	input [31:0] ALU_in,
	input [31:0] rt_in,
	input [31:0] MDU_in,
	input b_jump_in,
	
	output reg b_jump_out,
	output reg [31:0] instr_out,
	output reg [31:0] pc_out,
	output reg [31:0] ALU_out,
	output reg [31:0] rt_out,
	output reg [31:0] MDU_out
    );
	 
	initial begin
		instr_out <= 0;
		pc_out <= 32'h0000_3000;
		ALU_out <= 0;
		rt_out <= 0;
		MDU_out <= 0;
		b_jump_out <= 0;
	end
	
	always@(posedge clk) begin
		if(reset) begin
			instr_out <= 0;
			pc_out <= 32'h0000_3000;
			ALU_out <= 0;
			rt_out <= 0;
			MDU_out <= 0;
			b_jump_out <= 0;
		end
		else if(WE) begin
			instr_out <= instr_in;
			pc_out <= pc_in;
			ALU_out <= ALU_in;
			rt_out <= rt_in; 
			MDU_out <= MDU_in;
			b_jump_out <= b_jump_in;
		end
	end
endmodule
