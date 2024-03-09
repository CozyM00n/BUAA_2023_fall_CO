`timescale 1ns / 1ps

module WREG(	
	input clk,
	input reset,
	input WE,
	input [31:0] instr_in,
	input [31:0] pc_in,
	input [31:0] ALU_in,
	input [31:0] dm_in,
	
	output reg [31:0] instr_out,
	output reg [31:0] pc_out,
	output reg [31:0] ALU_out,
	output reg [31:0] dm_out
    );
	 
	initial begin
		instr_out <= 0;
		pc_out <= 32'h0000_3000;
		ALU_out <= 0;
		dm_out <= 0;
	end
	
	always@(posedge clk) begin
		if(reset) begin
			instr_out <= 0;
			pc_out <= 32'h0000_3000;
			ALU_out <= 0;
			dm_out <= 0;
		end
		else if(WE) begin
			instr_out <= instr_in;
			pc_out <= pc_in;
			ALU_out <= ALU_in;
			dm_out <= dm_in; 
		end
	end

endmodule
