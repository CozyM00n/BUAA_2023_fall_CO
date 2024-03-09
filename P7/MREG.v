`timescale 1ns / 1ps

module MREG(
	input clk,
	input reset,
	input WE,
	input Req,
	
	input [31:0] instr_in,
	input [31:0] pc_in,
	input [31:0] ALU_in,
	input [31:0] rt_in,
	input [31:0] MDU_in,
	input b_jump_in,
	input AdEL_in,
	input AdES_in,
	input [4:0] EXCcode_in,
	input Delay_in,
	
	output reg AdEL_out,
	output reg AdES_out,
	output reg [4:0] EXCcode_out,
	output reg Delay_out,
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
		if(reset|Req) begin
			instr_out <= 0;
			pc_out <= Req ? 32'h0000_4180 : 32'h0000_3000;
			ALU_out <= 0;
			rt_out <= 0;
			MDU_out <= 0;
			b_jump_out <= 0;
			AdEL_out <= 0;
			AdES_out <= 0;
			Delay_out <= 0;
			EXCcode_out <= 0;
		end
		else if(WE) begin
			instr_out <= instr_in;
			pc_out <= pc_in;
			ALU_out <= ALU_in;
			rt_out <= rt_in; 
			MDU_out <= MDU_in;
			b_jump_out <= b_jump_in;
			AdEL_out <= AdEL_in;
			AdES_out <= AdES_in;
			Delay_out <= Delay_in;
			EXCcode_out <= EXCcode_in;
		end
	end
endmodule
