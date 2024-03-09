`timescale 1ns / 1ps
`include "const.v"
`include "E_ALU.v"
`include "D_CMP.v"
`include "CTRL.v"
`include "M_DM.v"
`include "DREG.v"
`include "EREG.v"
`include "MREG.v"
`include "WREG.v"
`include "D_EXT.v"
`include "D_GRF.v"
`include "F_IFU.v"
`include "D_NPC.v"
`include "stall_ctrl.v"
module mips(
	input clk,
	input reset
    );
	 
//****************stall************//
wire stall;
wire [31:0] pc_F, pc_E, pc_D,pc_M,pc_W;
wire[31:0] instr_F, instr_E, instr_D, instr_M, instr_W;

stall_ctrl _stall (
    .D_instr(instr_D), 
    .E_instr(instr_E), 
    .M_instr(instr_M), 
    .stall(stall)
    );
//forword
wire [31:0] D_rs, D_rt, E_rs, E_rt, M_rt, W_rt;
wire [31:0] E_RFwd, M_RFwd, W_RFwd;
wire [4:0] E_RFdst, M_RFdst, W_RFdst;
wire [2:0] E_RFWDsel, M_RFWDsel, W_RFWDsel;

//RFWDsel :����������ݴ���RF,�ɵ�ǰָ�����
assign E_RFwd = (E_RFWDsel == `RFjal)  ? pc_E + 8 :
												  32'bz;
												  
assign M_RFwd = (M_RFWDsel == `RFjal) ? pc_M + 8 :
					 (M_RFWDsel == `RFcal)  ? M_ALUout :
												  32'bz;
												  
assign W_RFwd = (W_RFWDsel == `RFjal) ? pc_W + 8 :
					 (W_RFWDsel == `RFcal)  ? W_ALUout :
					 (W_RFWDsel == `RFload)  ? W_DMout :
												  32'bz;
//**************F_stage****************//

wire[31:0] NPC;

F_IFU _IFU (
    .npc(NPC), //in
    .clk(clk), 
    .reset(reset), 
    .WE(~stall), 
    .pc(pc_F),//out
    .instr(instr_F)
    );

//**************D_stage****************//
DREG _DREG (
    .clk(clk), 
    .reset(reset), 
    .WE(~stall), 
    .pc_in(pc_F), 
    .instr_in(instr_F), 
    .pc_out(pc_D), 
    .instr_out(instr_D)
    );

wire [4:0] D_rs_addr, D_rt_addr;
wire [15:0] D_imm16;
wire [25:0] D_imm26;
wire D_EXTop;
wire [2:0] D_NPCop;
wire [1:0] D_CMPop;

assign D_rs = (D_rs_addr == 0) ? 0:
						 (D_rs_addr == E_RFdst) ? E_RFwd:
						 (D_rs_addr == M_RFdst) ? M_RFwd:
						 D_GRFout1;
						 
assign D_rt = (D_rt_addr == 0) ? 0:
						 (D_rt_addr == E_RFdst) ? E_RFwd:
						 (D_rt_addr == M_RFdst) ? M_RFwd:
						 D_GRFout2;
CTRL _Dctrl (
    .instr(instr_D), 
    .rs(D_rs_addr), 
    .rt(D_rt_addr), 
    .imm16(D_imm16), //to EXT
    .imm26(D_imm26), //to NPC
    .EXTop(D_EXTop), 
    .NPCop(D_NPCop),
    .CMPop(D_CMPop)
    );
	 
wire D_b_jump;

D_CMP _Dcmp (
    .rsData(D_rs), 
    .rtData(D_rt), 
    .CMPop(D_CMPop), 
    .jump(D_b_jump)//out
    );

D_NPC _Dnpc (
    .pc_F(pc_F), 
    .pc_D(pc_D), 
    .b_jump(D_b_jump), 
    .imm26(D_imm26), 
    .NPCop(D_NPCop), 
    .rs(D_rs), 
    .npc(NPC)//out
    );
	 
wire[31:0] D_EXTout, E_EXTout;
D_EXT _Dext (
    .in(D_imm16), 
    .EXTop(D_EXTop), 
    .out(D_EXTout)
    );
	 
wire [31:0] D_GRFout1, D_GRFout2;	 
D_GRF _Dgrf(
    .clk(clk), 
    .reset(reset), 
    .WE(1'b1),
    .A1(D_rs_addr), 
    .A2(D_rt_addr), 
    .A3(W_RFdst), 
    .WD(W_RFwd), 
    .PC(pc_W), 
    .rd1(D_GRFout1), 
    .rd2(D_GRFout2)
    );
//**************E_stage****************//
wire E_reset = reset | stall;
wire[31:0] E_rs0, E_rt0;

assign E_rs = (E_rs_addr == 0) ? 0:
						(E_rs_addr == M_RFdst) ? M_RFwd:
						(E_rs_addr == W_RFdst) ? W_RFwd:
						E_rs0;
assign E_rt = (E_rt_addr == 0) ? 0:
						(E_rt_addr == M_RFdst) ? M_RFwd:
						(E_rt_addr == W_RFdst) ? W_RFwd:
						E_rt0;
EREG _EREG (
    .clk(clk), 
    .reset(E_reset), 
    .WE(1'b1), 
    .pc_in(pc_D), 
    .instr_in(instr_D), 
    .rs_in(D_rs), 
    .rt_in(D_rt), 
    .ext_in(D_EXTout), 
	 
    .pc_out(pc_E), 
    .instr_out(instr_E), 
    .rs_out(E_rs0), 
    .rt_out(E_rt0), 
    .ext_out(E_EXTout)
    );
	 
wire[3:0] E_ALUop;
wire E_Bsel;
wire [4:0] E_rs_addr, E_rt_addr;

CTRL _Ectrl (
    .instr(instr_E), 
    .rs(E_rs_addr), 
    .rt(E_rt_addr), 
    .Bsel(E_Bsel), 
    .A3addr(E_RFdst), 
    .RFWDsel(E_RFWDsel),
	 .ALUop(E_ALUop)
    );
	 
wire [31:0] E_ALUa, E_ALUb, E_ALUout;	

assign E_ALUa = E_rs;
assign E_ALUb = (E_Bsel == 0) ? E_rt : E_EXTout;

E_ALU _Ealu (
    .A(E_ALUa), 
    .B(E_ALUb), 
    .ALUop(E_ALUop), 
    .ALUres(E_ALUout)
    );
	 
//**************M_stage****************//
wire [31:0] M_rt0, M_ALUout;
MREG _MREG (
    .clk(clk), 
    .reset(reset), 
    .WE(1'b1), 
    .instr_in(instr_E), 
    .pc_in(pc_E), 
    .ALU_in(E_ALUout), 
    .rt_in(E_rt), 
	 
    .instr_out(instr_M), 
    .pc_out(pc_M), 
    .ALU_out(M_ALUout), 
    .rt_out(M_rt0)
    );
	 
//forward: data for dm
wire [31:0] M_DMwd = (M_rt_addr == 0) ? 0:
							(M_rt_addr == W_RFdst) ? W_RFwd :
							M_rt0;

wire [1:0] M_DMsel, M_lors;	
wire [4:0] M_rt_addr;				
CTRL _Mctrl (
    .instr(instr_M), 
    .rt(M_rt_addr),  
    .A3addr(M_RFdst), 
    .RFWDsel(M_RFWDsel), 
    .DMsel(M_DMsel), 
    .lors(M_lors)
    );
wire[31:0] M_DMout;
M_DM _Mdm (
    .clk(clk), 
    .reset(reset), 
    .pc(pc_M), 
    .addr(M_ALUout), 
    .DMsel(M_DMsel), 
    .lors(M_lors), 
    .WD(M_DMwd), 
    .DMout(M_DMout)
    );
	 
//**************W_stage****************//
wire [31:0] W_ALUout, W_DMout;
WREG _WREG (
    .clk(clk), 
    .reset(reset), 
    .WE(1'b1), 
    .instr_in(instr_M), 
    .pc_in(pc_M), 
    .ALU_in(M_ALUout), 
    .dm_in(M_DMout), 
	 
    .instr_out(instr_W), 
    .pc_out(pc_W), 
    .ALU_out(W_ALUout), 
    .dm_out(W_DMout)
    );

CTRL _Wctrl (
    .instr(instr_W), 
    .A3addr(W_RFdst),
    .RFWDsel(W_RFWDsel)
    );

endmodule
