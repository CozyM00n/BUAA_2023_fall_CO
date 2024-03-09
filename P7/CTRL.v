`timescale 1ns / 1ps
`include "const.v"

module CTRL(
	input [31:0] instr,
	input b_jump,
	
	output [4:0] rs, 
	output [4:0] rt, 
	output [4:0] rd, 
	output [4:0] shamt,
	output [15:0] imm16,
	output [25:0] imm26,
	
	output [3:0] ALUop,
	output EXTop,
	output [2:0]NPCop,
	output Bsel,
	output [2:0] DMsel,
	output [2:0] RFWDsel,
	output [4:0] A3addr,
	output branch,
	output jump,
	output load,
	output store,
	//output [1:0] lors,
	output [2:0] CMPop,
	output [3:0] MDUop,
	output [2:0] BEop, //store
	output [2:0] DEop, //load
	output MDUstart,
	
	output eret,
	output syscall,
	output CP0WE,
	output RI,
	output ovf,
	output mtc0,
	
	output [2:0] rs_Tuse,
	output [2:0] rt_Tuse,
	output [2:0] E_Tnew,
	output [2:0] M_Tnew
    );
	
	wire [5:0] opcode = {instr[31:26]};
	wire [5:0] func = {instr[5:0]};
	
	assign rs = {instr[25:21]};//splitter 前六个输出
	assign rt = {instr[20:16]};
	assign rd = {instr[15:11]};
	assign shamt = {instr[10:6]};
	assign imm16 = {instr[15:0]};
	assign imm26 = {instr[25:0]};
	
	//指令集
	assign special = (opcode == 0);
	
	assign add = (special && func == 6'b100_000);
	assign sub = (special && func == 6'b100_010);
	assign AND = (special && func == 6'b100_100);
	assign OR = (special && func == 6'b100_101);
	assign slt = (special && func == 6'b101_010);
	assign sltu = (special && func == 6'b101_011);
	assign beq = (opcode == 6'b000_100);
	assign bne = (opcode == 6'b000101);
	
	//assign bltzal = (opcode == 6'b000001);
	assign lui = (opcode == 6'b001_111);
	assign addi = (opcode == 6'b001_000);
	assign andi = (opcode == 6'b001_100);
	assign ori = (opcode == 6'b001_101);
	
	
	assign lw = (opcode == 6'b100_011);
	assign lb = (opcode == 6'b100_000);
	assign lh = (opcode == 6'b100_001);
	assign sw = (opcode == 6'b101_011);
	assign sb = (opcode == 6'b101_000);
	assign sh = (opcode == 6'b101_001);
	
	assign mult = (special && func == 6'b011000);
	assign multu = (special && func == 6'b011001);
	assign div = (special && func == 6'b011010);
	assign divu = (special && func == 6'b011011);
	assign mfhi = (special && func == 6'b010000);
	assign mflo = (special && func == 6'b010010);
	assign mthi = (special && func == 6'b010001);
	assign mtlo = (special && func == 6'b010011);
	
	assign jal = (opcode == 6'b000_011);
	assign jr = (special && func == 6'b001_000);
	
	assign syscall = (special && func == 6'b001_100);
	assign mfc0 = (opcode == 6'b010_000 && rs == 5'b00000);
	assign mtc0 = (opcode == 6'b010_000 && rs == 5'b00100);
	
	assign eret = (instr == 32'b010000_1000_0000_0000_0000_0000_011000);
	
	//分类
	assign cal_r = (add|sub|AND|OR|slt|sltu);
	assign cal_i = (lui|addi|andi|ori);
	assign store = (sw|sh|sb);
	assign load = (lw|lh|lb);
	assign Half = (sh | lh);
	assign Byte = (sb | lb);
	assign Word = (sw | lw);
	assign j_reg = (jr);//无条件跳转至$rs
	assign j_imm = (jal);//无条件跳转至imm26
	assign j_link = (jal);//link 写$31
	assign md = (mult|multu|div|divu);
	assign mf = (mfhi | mflo);
	assign mt = (mthi | mtlo);
	assign ovf = (add|sub|addi);
	
	//输出信号
	assign RI = !(add|sub|AND|OR| slt|sltu| lui|
		addi| andi| ori | lb|lh|lw | sb | sh| sw |
		mult| multu| div| divu| mfhi| mflo| mthi| mtlo|
		beq| bne| jal| jr|
		mfc0| mtc0| eret| syscall| (instr == 32'b0));
		
	assign CP0WE = mtc0;
	assign ALUop = (lui) ? `ALU_lui : 
						(sub)? `ALU_sub :
						(AND|andi)? `ALU_and :
						(OR|ori)? `ALU_or :
						(slt)? `ALU_slt :
						(sltu)? `ALU_sltu :
						`ALU_add;
						
	assign EXTop = (load | store | addi);
	
	assign NPCop = (j_reg) ? `NPC_rs:
						(j_imm) ? `NPC_j:
						(branch) ? `NPC_b:
						 0;
						 
	assign Bsel = (cal_i| store | load);
	
	assign DMsel = (Byte) ? `DM_byte:
						(Half) ? `DM_half:
						(Word) ? `DM_word:
						0;
						
	assign RFWDsel= (cal_r|cal_i) ? `RF_cal://aluRes
						 (mf) ?  `RF_mdu:
						 (load) ? `RF_load: // DMout
						 (j_link) ? `RF_jlink:// pc+8
						 (mfc0)? `RF_CP0:
						  0;
						  
	assign A3addr = (cal_r | mf) ? rd:
						 (cal_i | load |mfc0) ? rt :
						 (j_link) ? 5'd31:
	  					 0;//相当于不写
						
	assign branch = (beq | bne);
	assign jump = (j_reg | j_imm | j_link);
	assign CMPop = (beq) ? `CMP_beq://必须具体到b级每一条指令
						(bne) ? `CMP_bne:
						//(bltzal) ? `CMP_bltzal:
						 3'b000;
						
	assign MDUop = (mult)? `MDU_mult:
	               (div)? `MDU_div:
				   	(multu)? `MDU_multu:
						(divu)? `MDU_divu:
						(mfhi)? `MDU_mfhi:
						(mflo)? `MDU_mflo:
						(mthi)? `MDU_mthi:
						(mtlo)? `MDU_mtlo:
						4'b0000;
						
	assign BEop = (sw) ? `BE_sw ://store
                 (sh) ? `BE_sh :
                 (sb) ? `BE_sb :
                 0;
					  
	assign DEop = (lw) ? `DE_lw ://load
                 (lh) ? `DE_lh :
                 (lb) ? `DE_lb :
                  0;
	assign MDUstart = md;
	
	//转发和暂停
	assign rs_Tuse = (cal_r | cal_i | load | store | mt | md) ? 3'd1://///////////////////////
							(branch | j_reg )? 3'd0://pc<= rs
							3'd3;//无限大 
							
	assign rt_Tuse = (cal_r | md) ? 3'd1:
							(store| mtc0) ? 3'd2:
							(branch) ? 3'd0:
							//(beq|bne) ? 3'd0: bltzal的rtuse=3
							3'd3;
							
	assign E_Tnew = (cal_r |  cal_i | mf ) ? 3'd1:
						  (load|mfc0) ? 3'd2:
						  3'd0;
						  
	assign M_Tnew = (load|mfc0) ? 3'd1:
							3'd0;
endmodule
