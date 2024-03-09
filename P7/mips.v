`timescale 1ns / 1ps
`include "const.v"
 module mips_CPU(
	input clk,
	input reset,
	 input [5:0] HWInt,
	input [31:0] i_inst_rdata,//i_inst_addr对应的 32 位指令
	input [31:0] m_data_rdata,//DM存储的相应数据
	
	output [31:0] i_inst_addr,//需取指的F 级PC
	output [31:0] m_data_addr,//待写入/读出的数据存储器相应地址
	output [31:0] m_data_wdata,//待写入数据存储器相应数据
	output [3:0] m_data_byteen,//四位字节使能
	output [31:0] m_inst_addr, // M 级PC
	output w_grf_we, //GRF 写使能信号
   output [4:0] w_grf_addr, //GRF 中待写入寄存器编号
   output [31:0] w_grf_wdata, //GRF 中待写入数据
   output [31:0] w_inst_addr, // W 级 PC
	output [31:0] macroscopic_pc,
	 output [31:0] m_int_addr,
	 output [3 :0] m_int_byteen
    );
	wire [31:0] M_DMout0;
	wire[31:0] instr_F0, instr_F;
	
	assign instr_F0 = i_inst_rdata;
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
	
	assign macroscopic_pc =pc_M;
	assign m_int_addr = m_data_addr;
	assign m_int_byteen = m_data_byteen;
	//****************stall************//
	wire [31:0] pc_F, pc_F0, pc_E, pc_D,pc_M,pc_W;
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
	
	//RFWDsel :把哪里的数据存入RF,由当前指令决定
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
						(W_RFWDsel == `RF_CP0) ? W_CP0out:
													   32'bz;
	
	//**************F_stage****************//
	wire[31:0] NPC;
	wire Req;
	wire [4:0] F_EXCcode, E_EXCcode, D_EXCcode, D_EXCcode0, M_EXCcode;
	F_PC _PC (
		.clk(clk), //in
		.reset(reset), 
		.WE(~STALL), 
		.Req(Req),
		.npc(NPC),
		.pc(pc_F0)
    );
	 wire[31:0] EPC;
	assign pc_F = (D_eret) ? EPC : pc_F0;
	assign F_AdEL = ((|pc_F[1:0]) ||pc_F < 32'h0000_3000 ||pc_F > 32'h0000_6ffc) && !D_eret;
	assign F_EXCcode = (F_AdEL) ? `EXC_AdEL : `EXC_None;
	assign F_Delay = (D_jump | D_branch);
	assign instr_F = (F_AdEL) ? 32'b0: instr_F0 ;
	//**************D_stage****************//
	
DREG _DREG (
		.clk(clk), 
		.reset(reset), 
		.WE(~STALL), 
		.Req(Req),
		
		.pc_in(pc_F), 
		.instr_in(instr_F), 
		.Delay_in(F_Delay),
		.EXCcode_in(F_EXCcode),
		
		.pc_out(pc_D), 
		.instr_out(instr_D),
		.Delay_out(D_Delay),
		.EXCcode_out(D_EXCcode0)
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
	assign D_EXCcode = (D_EXCcode0 ) ? D_EXCcode0:
							(D_RI) ? `EXC_RI : 
							(D_syscall) ? `EXC_syscall: `EXC_None;
	CTRL _Dctrl (
		.instr(instr_D), 
		.rs(D_rs_addr), 
		.rt(D_rt_addr), 
		.imm16(D_imm16), //to EXT
		.imm26(D_imm26), //to NPC
		.EXTop(D_EXTop), 
		.NPCop(D_NPCop),
		.CMPop(D_CMPop),
		.branch(D_branch),
		.jump(D_jump),
		.eret(D_eret),
		.RI(D_RI),
		.syscall(D_syscall)
    );
	 
	 wire D_b_jump, E_b_jump, M_b_jump, W_b_jump;
	 D_CMP _Dcmp (
		.rsData(D_rs), 
		.rtData(D_rt), 
		.CMPop(D_CMPop), 
		.jump(D_b_jump)//out
    );
	
	D_NPC _Dnpc (
		.eret(D_eret),
		.EPC(EPC),
		.Req(Req),
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
		.WE(1'b1), //不写=写0
		.A1(D_rs_addr), 
		.A2(D_rt_addr), 
		.A3(W_RFdst), 
		.WD(W_RFwd),  
		.rd1(D_GRFout1), 
      .rd2(D_GRFout2)
    );
//**************E_stage****************//
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
wire[4:0] E_EXCcode0;
EREG _EREG (
    .clk(clk), 
    .reset(reset), 
	 .STALL(STALL),
	 .Req(Req),
    .WE(1'b1),
	 
    .pc_in(pc_D), 
    .instr_in(instr_D), 
    .rs_in(D_rs), 
    .rt_in(D_rt), 
    .ext_in(D_EXTout), 
	 .b_jump_in(D_b_jump),
	 .Delay_in(D_Delay),
	 .EXCcode_in(D_EXCcode),
	 
    .pc_out(pc_E), 
    .instr_out(instr_E), 
    .rs_out(E_rs0), 
    .rt_out(E_rt0), 
    .ext_out(E_EXTout),
	 .b_jump_out(E_b_jump),
	 .Delay_out(E_Delay),
	 .EXCcode_out(E_EXCcode0)
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
	 .MDUop(E_MDUop), 
	 .MDUstart(E_MDUstart),
	 .ovf(E_ovf),///
	 .load(E_load),
	 .store(E_store)
    );

wire [31:0] E_ALUa, E_ALUb, E_ALUout;	

assign E_ALUa = E_rs;
assign E_ALUb = (E_Bsel == 0) ? E_rt : E_EXTout;

E_ALU _Ealu (
	 .ovf(E_ovf),
	 .load(E_load),
	 .store(E_store),
    .A(E_ALUa), 
    .B(E_ALUb), 
    .ALUop(E_ALUop), 
    .ALUres(E_ALUout),
	 .ALU_ov(E_ov),//
	 .ALU_AdEL(E_AdEL),
	 .ALU_AdES(E_AdES)
    );
	 
wire [31:0] E_HI, E_LO;
wire [31:0] E_MDUout = (E_MDUop == `MDU_mfhi) ? E_HI : 
							  (E_MDUop == `MDU_mflo) ? E_LO :
							  32'bz;
E_MDU _Emdu(
    .clk(clk), 
    .reset(reset), 
	 .Req(Req),
    .start(E_MDUstart), 
    .MDUop(E_MDUop), 
    .in1(E_ALUa), 
    .in2(E_ALUb), 
    .MDUstall(E_MDUstall), 
    .HI(E_HI), 
    .LO(E_LO)
    );
	 
assign E_EXCcode = (E_EXCcode0) ? E_EXCcode0:
						(E_ov) ? `EXC_ov:
						`EXC_None;
//**************M_stage****************//
wire [31:0] M_rt0, M_ALUout, M_MDUout;
wire [4:0] M_EXCcode0;
MREG _MREG (
    .clk(clk), 
    .reset(reset), 
    .WE(1'b1), 
	 .Req(Req),
    .instr_in(instr_E), 
    .pc_in(pc_E), 
    .ALU_in(E_ALUout), 
    .rt_in(E_rt),  
    .MDU_in(E_MDUout), 
	 .b_jump_in(E_b_jump),
	 .AdEL_in(E_AdEL),///
	 .AdES_in(E_AdES),
	 .EXCcode_in(E_EXCcode),
	 .Delay_in(E_Delay),
	 
    .instr_out(instr_M), 
    .pc_out(pc_M), 
    .ALU_out(M_ALUout), 
    .rt_out(M_rt0),
    .MDU_out(M_MDUout),
	 .b_jump_out(M_b_jump),
	 .AdEL_out(M_AdEL0),///
	 .AdES_out(M_AdES0),
	 .EXCcode_out(M_EXCcode0),
	 .Delay_out(M_Delay)
    );
//forward
wire [31:0] M_DMwd0 = (M_rt_addr == 0) ? 0:
							(M_rt_addr == W_RFdst) ? W_RFwd :
							M_rt0;
							
wire [2:0] M_BEop, M_DEop;	
wire [4:0] M_rt_addr, M_rd_addr;;				
CTRL _Mctrl (
    .instr(instr_M), 
	 .b_jump(M_b_jump),
    .rt(M_rt_addr),
	 .rd(M_rd_addr),
    .A3addr(M_RFdst), 
    .RFWDsel(M_RFWDsel), 
    .BEop(M_BEop), 
    .DEop(M_DEop),
	 .CP0WE(M_CP0WE),
	 .eret(M_eret),
	 .load(M_load),
	 .store(M_store)
    );	

wire [31:0] M_DMout;
M_DEload _Mdeload (
    .addr(M_ALUout), 
    .DEop(M_DEop), 
    .DMout0(M_DMout0),//外部输入
	 .load(M_load),
	 .AdEL0(M_AdEL0),
	 
    .DMout(M_DMout),//out
	 .AdEL(M_AdEL)
    );	 
	 
wire [3:0] M_byteen;
wire [31:0] M_DMwd;
M_BEs _Mbestore (
    .addr(M_ALUout), 
    .BEop(M_BEop), 
    .DMwd0(M_DMwd0), 
	 .store(M_store),
	 .AdES0(M_AdES0),
	 .EN(!Req),
	 
    .byteen(M_byteen), //out
    .DMwd(M_DMwd),
	 .AdES(M_AdES)
    );
assign M_EXCcode = (M_EXCcode0) ? M_EXCcode0:
						(M_AdES) ? `EXC_AdES:
						(M_AdEL) ? `EXC_AdEL :
						`EXC_None;
wire [31:0] M_CP0out, W_CP0out;	

CP0 _Mcp0 (
    .clk(clk), 
    .reset(reset), 
    .WE(M_CP0WE), 
    .CP0Add(M_rd_addr), //CP0操作的地址
    .CP0In(M_DMwd0), //CP0输入的值
    .VPC(pc_M), 
    .BDIn(M_Delay), 
    .ExcCodeIn(M_EXCcode), 
    .HWInt(HWInt), //外部输入的中断信号
    .EXLclr(M_eret), 
	 
    .CP0Out(M_CP0out), 
    .EPCOut(EPC), 
    .Req(Req)
    );

//**************W_stage****************//
wire [31:0] W_ALUout, W_DMout, W_MDUout;
WREG _WREG (
    .clk(clk), 
    .reset(reset), 
    .WE(1'b1), 
	 .Req(Req),
    .instr_in(instr_M), 
    .pc_in(pc_M), 
    .ALU_in(M_ALUout), 
    .dm_in(M_DMout), 
    .MDU_in(M_MDUout), 
	 .b_jump_in(M_b_jump),
	 .CP0_in(M_CP0out),
	 
	 .CP0_out(W_CP0out),
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
