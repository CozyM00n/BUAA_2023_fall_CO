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
	input load,
	input AdEL0,
	
	output reg [31:0] DMout,
	output AdEL
    );
	assign e1 = ((DEop == `DE_lw) && (|addr[1:0]) )|
					((DEop == `DE_lh) && (addr[0]) );
	assign e2 = !( (addr >= `s_DM && addr <= `e_DM) |
					(addr >= `s_TC0 && addr <= `e_TC0)|
					(addr >= `s_TC1 && addr <= `e_TC1) );
	assign e3 = (DEop != `DE_lw && addr >= `s_TC0);
	assign AdEL = (load) && (e1 | e2 | e3 | AdEL0);
	
	always@(*) begin
		case(DEop) 
			`DE_lw: DMout = DMout0;
			`DE_lh: DMout = { {16{`Hsign}}, `H_WORD};
			`DE_lb: DMout = { {24{`Bsign}}, `BYTE};
			default: DMout = 0;
		endcase
	end

endmodule
