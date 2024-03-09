`timescale 1ns / 1ps
`include "const.v"

`define H_WORD  DMout0[(16*addr[1]+15)-: 16]
`define BYTE  DMout0[(8*addr[1:0]+7)-: 8]

`define Hsign DMout0[16*addr[1] + 15]
`define Bsign DMout0[8*addr[1:0] + 7]

module M_DEload(
	input [31:0] addr,
	input [2:0] DEop,
	input [31:0] DMout0,
	
	output reg [31:0] DMout
    );
	 
	always@(*) begin
		case(DEop) 
			`DE_lw: DMout = DMout0;
			`DE_lh: DMout = { {16{`Hsign}}, `H_WORD};
			`DE_lb: DMout = { {24{`Bsign}}, `BYTE};
			default: DMout = 0;
		endcase
	end

endmodule
