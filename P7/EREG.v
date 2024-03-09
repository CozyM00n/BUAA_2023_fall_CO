`timescale 1ns / 1ps

module EREG(
	input clk,
	input reset,
	input STALL,
	input WE,
	input Req,
	input [31:0] pc_in,
	input [31:0] instr_in,
	input [31:0] rs_in,
	input [31:0] rt_in,
	input [31:0] ext_in,
	input b_jump_in,
	input Delay_in,
	input [4:0] EXCcode_in,
	
	output reg Delay_out,
	output reg [4:0] EXCcode_out,
	output reg b_jump_out,
	output reg [31:0] pc_out,
	output reg [31:0] instr_out,
	output reg [31:0] rs_out,
	output reg [31:0] rt_out,
	output reg [31:0] ext_out
    );
	
	initial begin
		pc_out <= 32'h0000_3000;
		instr_out <= 0;
		rs_out <= 0;
		rt_out <= 0;
		ext_out <= 0;
		b_jump_out <= 0;
		EXCcode_out <= 0;
		Delay_out <= 0;
	end
	
	always@(posedge clk) begin
		if(reset ||STALL || Req) begin
			//pc_out <= (Req ? 32'h0000_4180 : (STALL ? pc_in : 32'h0000_3000));
			if(Req) pc_out <= 32'h0000_4180;
			else if(STALL) pc_out <= pc_in;
			else pc_out <= pc_in;
			
			instr_out <= 0;
			rs_out <= 0;
			rt_out <= 0;
			ext_out <= 0;
			b_jump_out <= 0;
			Delay_out <= STALL? Delay_in :0;
			EXCcode_out <= STALL ? EXCcode_in : 0;
		end
		else if(WE) begin
			pc_out <= pc_in;
			instr_out <= instr_in;
			rs_out <= rs_in;
			rt_out <= rt_in;
			ext_out <= ext_in;
			b_jump_out <= b_jump_in;
			Delay_out <= Delay_in;
			EXCcode_out <= EXCcode_in;
		end
	end
endmodule
