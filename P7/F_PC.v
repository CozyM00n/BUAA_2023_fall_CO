`timescale 1ns / 1ps

module F_PC(
	input clk,
	input reset,
	input WE,
	input [31:0]npc,
	input Req,
	
	output reg [31:0] pc
    );
	 
	initial begin
		pc <= 32'h0000_3000;
	end
	
	always@(posedge clk) begin
		if(reset) begin
			pc <= 32'h0000_3000;
		end
		else if(WE | Req)begin
			pc <= (Req ? 32'h0000_4180 : npc);
		end
	end
endmodule
