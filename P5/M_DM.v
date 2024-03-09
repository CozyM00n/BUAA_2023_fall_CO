`timescale 1ns / 1ps
`include "const.v"
module M_DM(
	input clk,
	input reset,
	input [31:0] pc,
	input [31:0] addr,
	input [1:0] DMsel,
	input [1:0] lors,
	input [31:0] WD,
	
	output [31:0]DMout
    );

	integer i;
	reg [31:0] DM [0:3071];
	
	initial begin
		for(i = 0; i < 3072; i = i + 1) begin
			DM[i] <= 0;
		end
	end
	always@(posedge clk) begin
		if(reset == 1) begin
			for(i = 0; i < 3072; i = i + 1) begin
				DM[i] <= 0;
			end
		end
		else begin
			if(lors == `DMstore) begin
				case(DMsel) 
					2'b00: begin
						$display("%d@%h: *%h <= %h",$time, pc, {addr[31:2],2'b0}, WD);
						DM[addr[31:2]] <= WD;
					end
				endcase
			end	
		end
	end
	assign DMout = (lors != `DMload) ? 0 : 
						(DMsel == 0) ? DM[addr[31:2]]:
						0;
endmodule
