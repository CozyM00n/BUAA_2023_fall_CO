`timescale 1ns / 1ps

module GRF(
	input clk,
	input reset,
	
	input RFWe,
	input [4:0] A1, 
	input [4:0] A2, 
	input [4:0] Addr,
	input [31:0] RFWd,
	input [31:0] PC,
	
	output [31:0] RD1,
	output [31:0] RD2
    );
	
	reg [31:0] GPR [0:31];////////////////
	integer i;
	initial begin
		for (i = 0; i < 32; i = i + 1) begin
			GPR[i] = 32'h0000_0000;
		end
	end
	
	assign RD1 = GPR[A1];
	assign RD2 = GPR[A2];
	
	always@(posedge clk) begin
		if(reset == 1) begin /////////////////ͬ����λ
			for (i = 0; i < 32; i = i + 1) begin
				GPR[i] <= 32'h0000_0000;
			end
		end
		else begin
			if(Addr != 5'b00_000 && RFWe == 1) begin
				GPR[Addr] <= RFWd;
				$display("@%h: $%d <= %h", PC, Addr, RFWd);
			end
		end
	end
endmodule
