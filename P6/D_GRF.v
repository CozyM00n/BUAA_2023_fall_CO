`timescale 1ns / 1ps

module D_GRF(
	input clk,
	input reset,
	input WE,
	
	input [4:0] A1,
	input [4:0] A2,
	input [4:0] A3,
	input [31:0] WD,
	//input [31:0] PC,//to print
	
	output [31:0] rd1,
	output [31:0] rd2
    );
	reg [31:0] regFile[0:31];
	integer i;
	
	initial begin
		for(i = 0; i < 32; i = i + 1) begin
			regFile[i] = 0;
		end
	end
	
	assign rd1 = (A1 == A3 && A1 != 0) ? WD : regFile[A1];
	assign rd2 = (A2 == A3 && A2 != 0) ? WD : regFile[A2];
	always@(posedge clk) begin
		if(reset) begin
			for(i = 0; i < 32; i = i + 1) begin
				regFile[i] = 0;
			end
		end
		else if(WE && A3 != 5'd0)begin
			regFile[A3] <= WD;
		end
	end
endmodule
