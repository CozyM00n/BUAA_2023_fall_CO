`timescale 1ns / 1ps
`include "const.v"

module E_MDU(
	input clk,
	input reset,
	input Req,
	
	input start,
	input [3:0] MDUop,
	input [31:0] in1, // rs
	input [31:0] in2, // rt
	
	output MDUstall,
	output reg [31:0] HI,
	output reg [31:0] LO
    );
	reg busy;
	reg [31:0] tmp_HI, tmp_LO, state;
	assign MDUstall = busy | start;
	
	initial begin
		HI = 0;
		LO = 0;
		tmp_HI = 0;
		tmp_LO = 0;
		state = 0;
		busy = 0;
	end
	
	//MOVE to,把rs(in1)写入HI/LO
	always@(posedge clk) begin
		if(MDUop == `MDU_mthi) HI <= in1;
		else if (MDUop == `MDU_mtlo) LO <= in1;
	end
	
	always@(posedge clk) begin
		if(reset) begin
			busy <= 0;
			HI <= 0;
			LO <= 0;
			state <= 0;
			tmp_HI = 0;
			tmp_LO = 0;
		end
		else if(!Req)begin
			if(state == 0) begin
				if(start) begin//md指令在E级
					busy <= 1;
					case(MDUop)
						`MDU_mult: begin
							state <= 5;
							{tmp_HI,tmp_LO}<= $signed(in1)* $signed(in2);
						end
						`MDU_multu: begin
							state <= 5;
							{tmp_HI,tmp_LO}<= in1 * in2;
						end
						`MDU_div: begin
							state <= 10;
							tmp_LO <= $signed(in1) / $signed(in2);
							tmp_HI <= $signed(in1) % $signed(in2);
						end
						`MDU_divu: begin
							state <= 10;
							tmp_LO <= in1 / in2;
							tmp_HI <= in1 % in2;
						end
					endcase
				end
			end
			else if(state == 1) begin
				LO <= tmp_LO;
				HI <= tmp_HI;
				busy <= 0;
				state <= 0;
			end
			else begin
				state <= state - 1;
			end
		end
	end
endmodule
