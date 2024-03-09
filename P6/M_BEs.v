`timescale 1ns / 1ps
`include "const.v"
`define H_WORD  DMwd0[15:0]
`define BYTE  DMwd0[7:0]

module M_BEs(
	input [31:0]addr,
	input [2:0] BEop,
	input [31:0]DMwd0,
	
	output reg [3:0] byteen,
	output reg [31:0] DMwd
    );
	
	always @(*) begin
		case(BEop) 
			`BE_sw: DMwd = DMwd0;
			`BE_sh: begin
				if(addr[1] == 0) DMwd = {16'b0, `H_WORD};
				else if(addr[1] == 1)DMwd = {`H_WORD, 16'b0};
			 end
			 `BE_sb: begin
				if(addr[1:0] == 2'b00) DMwd = {24'b0, `BYTE};     
				else if(addr[1:0] == 2'b01) DMwd = {16'b0, `BYTE, 8'b0};
				else if(addr[1:0] == 2'b10) DMwd = {8'b0, `BYTE, 16'b0};
				else if(addr[1:0] == 2'b11) DMwd = {`BYTE, 24'b0};
			  end
			  default: DMwd = 0;
		endcase 
	end
 
	always @(*) begin
		case(BEop) 
			`BE_sw: byteen = 4'b1111;
			`BE_sh: begin
				if(addr[1] == 0) byteen = 4'b0011;
				else if(addr[1] == 1)byteen = 4'b1100;
			 end
			 `BE_sb: begin
				if(addr[1:0] == 2'b00)      byteen = 4'b0001;
				else if(addr[1:0] == 2'b01) byteen = 4'b0010;
				else if(addr[1:0] == 2'b10) byteen = 4'b0100;
				else if(addr[1:0] == 2'b11) byteen = 4'b1000;
			  end
			 default: byteen = 4'b0000;
		endcase 
	end
	
endmodule
