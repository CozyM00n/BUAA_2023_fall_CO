`timescale 1ns / 1ps

module DREG(
	input clk,
	input reset,
	input WE,
	input Req,
	
	input [31:0]pc_in,
	input [31:0]instr_in,
	input [4:0] EXCcode_in,
	input Delay_in,
	
	output reg [31:0] pc_out,
	output reg [31:0] instr_out,
	output reg[4:0] EXCcode_out,
	output reg Delay_out
    );
	
	initial begin
		pc_out <= 32'h0000_3000;
		instr_out <= 0;
		EXCcode_out <= 0;
		Delay_out <= 0;
	end

	always@(posedge clk) begin
		if(reset|Req) begin
			pc_out <= (Req ? 32'h0000_4180 : 32'h0000_3000);
			instr_out <= 0;
			EXCcode_out <= 0;
			Delay_out <= 0;
		end
		else if(WE) begin
			pc_out <= pc_in;
			instr_out <= instr_in;
			EXCcode_out <= EXCcode_in;
			Delay_out <= Delay_in;
		end
	end
endmodule
