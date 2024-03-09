`timescale 1ns / 1ps

module DREG(
	input clk,
	input reset,
	input WE,
	
	input [31:0]pc_in,
	input [31:0]instr_in,
	output reg [31:0] pc_out,
	output reg [31:0] instr_out
    );
	
	initial begin
		pc_out <= 32'h0000_3000;
		instr_out <= 0;
	end

	always@(posedge clk) begin
		if(reset) begin
			pc_out <= 32'h0000_3000;
			instr_out <= 0;
		end
		else if(WE) begin
			pc_out <= pc_in;
			instr_out <= instr_in;
		end
	end
endmodule
