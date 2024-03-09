`timescale 1ns / 1ps

module stall_ctrl(
	input [31:0] D_instr,
	input [31:0] E_instr,
	input [31:0] M_instr,
	
	output stall
    );
	wire[4:0] D_rs_addr, D_rt_addr, E_RFDst, M_RFDst;
	wire[2:0] rs_Tuse, rt_Tuse, E_Tnew,M_Tnew;

CTRL d_ctrl (
    .instr(D_instr), 
    .rs(D_rs_addr), 
    .rt(D_rt_addr), 
    .rs_Tuse(rs_Tuse), 
    .rt_Tuse(rt_Tuse),
	 .eret(D_eret)
    );
wire [4:0] E_rd_addr,M_rd_addr;
CTRL e_ctrl (
    .instr(E_instr), 
	 .A3addr(E_RFDst), 
	 .E_Tnew(E_Tnew),
	 .mtc0(E_mtc0),
	 .rd(E_rd_addr)
    );
	 
CTRL m_ctrl (
    .instr(M_instr), 
	 .A3addr(M_RFDst),  
	 .M_Tnew(M_Tnew),
	 .mtc0(M_mtc0),
	 .rd(M_rd_addr)
    );
	
	wire stall_rs = ((rs_Tuse < E_Tnew) && (E_RFDst == D_rs_addr) && (D_rs_addr != 0)) || 
						 ((rs_Tuse < M_Tnew) && (M_RFDst == D_rs_addr) && (D_rs_addr != 0));
	wire stall_rt = ((rt_Tuse < E_Tnew) && (E_RFDst == D_rt_addr) && (D_rt_addr != 0)) || 
						 ((rt_Tuse < M_Tnew) && (M_RFDst == D_rt_addr) && (D_rt_addr != 0));
	
	assign stall_eret = (D_eret) && ((E_mtc0 & (E_rd_addr == 14)) || (M_mtc0 & (M_rd_addr == 14)));;
	assign stall = stall_rs || stall_rt || stall_eret;
endmodule
