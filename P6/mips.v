`timescale 1ns / 1ps
`include "const.v"
module mips(
	input clk,
	input reset,
	input [31:0] i_inst_rdata,//i_inst_addr��Ӧ�� 32 λָ��
	input [31:0] m_data_rdata,//DM�洢����Ӧ����
	
	output [31:0] i_inst_addr,//��ȡָ��F ��PC
	output [31:0] m_data_addr,//��д��/���������ݴ洢����Ӧ��ַ
	output [31:0] m_data_wdata,//��д�����ݴ洢����Ӧ����
	output [3:0] m_data_byteen,//��λ�ֽ�ʹ��
	output [31:0] m_inst_addr, // M ��PC
	output w_grf_we, //GRF дʹ���ź�
   output [4:0] w_grf_addr, //GRF �д�д��Ĵ������
   output [31:0] w_grf_wdata, //GRF �д�д������
   output [31:0] w_inst_addr // W �� PC
    );
	wire [31:0] M_DMout0;
	wire[31:0] instr_F;
	
	assign instr_F = i_inst_rdata;
	assign M_DMout0 = m_data_rdata;
	
	assign i_inst_addr = pc_F;
	assign m_data_addr = M_ALUout;
	assign m_data_wdata = M_DMwd;
	assign m_data_byteen = M_byteen;
	assign m_inst_addr = pc_M;
	assign w_grf_we = 1'b1;
	assign w_grf_addr = W_RFdst;
	assign w_grf_wdata = W_RFwd;
	assign w_inst_addr = pc_W; 
	
	//****************stall************//
	wire [31:0] pc_F, pc_E, pc_D,pc_M,pc_W;
	wire[31:0] instr_E, instr_D, instr_M, instr_W;
	
	wire stall, E_MDUstall, STALL;
	assign STALL = stall | E_MDUstall;
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
	assign E_RFwd = (E_RFWDsel == `RF_jlink)  ? pc_E + 8 :
															32'bz;
												  
	assign M_RFwd = (M_RFWDsel == `RF_jlink) ? pc_M + 8 :
						 (M_RFWDsel == `RF_cal) ? M_ALUout :
						 (M_RFWDsel == `RF_mdu) ? M_MDUout :
														  32'bz;
												  
	assign W_RFwd = (W_RFWDsel == `RF_jlink) ? pc_W + 8 :
						(W_RFWDsel == `RF_cal)  ? W_ALUout :
						(W_RFWDsel == `RF_mdu) ? W_MDUout :
						(W_RFWDsel == `RF_load) ? W_DMout :
													   32'bz;
	
	//**************F_stage****************//
	wire[31:0] NPC;
	F_PC _PC (
		.clk(clk), //in
		.reset(reset), 
		.WE(~STALL), 
		.npc(NPC),//out
		.pc(pc_F)
    );
	
	//**************D_stage****************//
DREG _DREG (
		.clk(clk), 
		.reset(reset), 
		.WE(~STALL), 
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
	wire [2:0] D_CMPop;
	
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
	 
	 wire D_b_jump, E_b_jump, M_b_jump, W_b_jump;
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
		.rt(D_rt),
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
		.WE(1'b1), //��д=д0
		.A1(D_rs_addr), 
		.A2(D_rt_addr), 
		.A3(W_RFdst), 
		.WD(W_RFwd),  
		.rd1(D_GRFout1), 
      .rd2(D_GRFout2)
    );
//**************E_stage****************//
wire E_reset = reset | STALL;
wire[31:0] E_rs0, E_rt0;
//forward
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
    .WE(1),/////////////////// 1?
    .pc_in(pc_D), 
    .instr_in(instr_D), 
    .rs_in(D_rs), 
    .rt_in(D_rt), 
    .ext_in(D_EXTout), 
	 .b_jump_in(D_b_jump),
	 
    .pc_out(pc_E), 
    .instr_out(instr_E), 
    .rs_out(E_rs0), 
    .rt_out(E_rt0), 
    .ext_out(E_EXTout),
	 .b_jump_out(E_b_jump)
    );
	 
wire[3:0] E_ALUop, E_MDUop;
wire E_Bsel, E_MDUstart;
wire [4:0] E_rs_addr, E_rt_addr;

CTRL _Ectrl (
    .instr(instr_E), 
	 .b_jump(E_b_jump),
    .rs(E_rs_addr), 
    .rt(E_rt_addr), 
    .Bsel(E_Bsel), 
    .A3addr(E_RFdst), 
    .RFWDsel(E_RFWDsel),
	 .ALUop(E_ALUop),
	 .MDUop(E_MDUop), //
	 .MDUstart(E_MDUstart)// 
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
	 
wire [31:0] E_HI, E_LO;
wire [31:0] E_MDUout = (E_MDUop == `MDU_mfhi) ? E_HI : 
							  (E_MDUop == `MDU_mflo) ? E_LO :
							  32'bz;
E_MDU _Emdu (
    .clk(clk), 
    .reset(reset), 
    .start(E_MDUstart), 
    .MDUop(E_MDUop), 
    .in1(E_ALUa), 
    .in2(E_ALUb), 
    .MDUstall(E_MDUstall), 
    .HI(E_HI), 
    .LO(E_LO)
    );
	 
//**************M_stage****************//
wire [31:0] M_rt0, M_ALUout, M_MDUout;
MREG _MREG (
    .clk(clk), 
    .reset(reset), 
    .WE(1'b1), 
    .instr_in(instr_E), 
    .pc_in(pc_E), 
    .ALU_in(E_ALUout), 
    .rt_in(E_rt),  
    .MDU_in(E_MDUout), 
	 .b_jump_in(E_b_jump),
	 
    .instr_out(instr_M), 
    .pc_out(pc_M), 
    .ALU_out(M_ALUout), 
    .rt_out(M_rt0),
    .MDU_out(M_MDUout),
	 .b_jump_out(M_b_jump)
    );
//forward
wire [31:0] M_DMwd0 = (M_rt_addr == 0) ? 0:
							(M_rt_addr == W_RFdst) ? W_RFwd :
							M_rt0;
							
wire [2:0] M_BEop, M_DEop;	
wire [4:0] M_rt_addr;				
CTRL _Mctrl (
    .instr(instr_M), 
	 .b_jump(M_b_jump),
    .rt(M_rt_addr),  
    .A3addr(M_RFdst), 
    .RFWDsel(M_RFWDsel), 
    .BEop(M_BEop), 
    .DEop(M_DEop)
    );	

wire [31:0] M_DMout;
M_DEload _Mdeload (
    .addr(M_ALUout), 
    .DEop(M_DEop), 
    .DMout0(M_DMout0),//�ⲿ����
    .DMout(M_DMout)//out
    );	 
	 
wire [3:0] M_byteen;
wire [31:0] M_DMwd;
M_BEs _Mbestore (
    .addr(M_ALUout), 
    .BEop(M_BEop), 
    .DMwd0(M_DMwd0), 
    .byteen(M_byteen), //out
    .DMwd(M_DMwd)
    );
	 
//**************W_stage****************//
wire [31:0] W_ALUout, W_DMout, W_MDUout;
WREG _WREG (
    .clk(clk), 
    .reset(reset), 
    .WE(1'b1), 
    .instr_in(instr_M), 
    .pc_in(pc_M), 
    .ALU_in(M_ALUout), 
    .dm_in(M_DMout), 
    .MDU_in(M_MDUout), 
	 .b_jump_in(M_b_jump),
	 
    .instr_out(instr_W), 
    .pc_out(pc_W), 
    .ALU_out(W_ALUout), 
    .dm_out(W_DMout),
	 .MDU_out(W_MDUout),
	 .b_jump_out(W_b_jump)
    );
		
CTRL _Wctrl (
    .instr(instr_W), 
	 .b_jump(W_b_jump),
    .A3addr(W_RFdst),
    .RFWDsel(W_RFWDsel)
    );

endmodule
