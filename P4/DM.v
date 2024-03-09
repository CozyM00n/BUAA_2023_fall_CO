`timescale 1ns / 1ps
module DM(
	input clk,
	input reset,
	input DMWr,
	input [31:0] addr,
	input [31:0] WD,
	input [31:0] PC,
	output [31:0] DMOut
    );
	integer i;
	reg [31:0] DM [0:3071];
	initial begin
		for( i = 0; i < 3072; i = i + 1) begin
			DM[i] <= 0;
		end
	end
	always@(posedge clk) begin
		if(reset == 1) begin
			for( i = 0; i < 3072; i = i + 1) begin
				DM[i] <= 0;
			end
		end
		else if(DMWr) begin
			DM[addr[13:2]] <= WD;
			$display("@%h: *%h <= %h", PC, addr, WD);
		end
	end
	
	assign DMOut = DM[addr[13:2]];
endmodule
