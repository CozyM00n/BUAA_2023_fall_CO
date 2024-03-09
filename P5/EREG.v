`timescale 1ns / 1ps

module EREG(
	input clk,
	input reset,
	input WE,
	input [31:0] pc_in,
	input [31:0] instr_in,
	input [31:0] rs_in,
	input [31:0] rt_in,
	input [31:0] ext_in,
	
	
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
	end
	
	always@(posedge clk) begin
		if(reset == 1) begin
			pc_out <= 32'h0000_3000;
			instr_out <= 0;
			rs_out <= 0;
			rt_out <= 0;
			ext_out <= 0;
		end
		else if(WE) begin
			pc_out <= pc_in;
			instr_out <= instr_in;
			rs_out <= rs_in;
			rt_out <= rt_in;
			ext_out <= ext_in;
		end
	end
endmodule
