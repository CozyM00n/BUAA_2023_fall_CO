`timescale 1ns / 1ps

module mips(
	 input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据
    output [31:0] w_inst_addr     // W 级 PC
    );

wire TC0_IRQ, TC1_IRQ;
wire [5:0] HWInt = {3'b0,interrupt,TC1_IRQ, TC0_IRQ};
wire [31:0] m_data_rdata1, tmp_m_data_wdata, tmp_m_data_addr;
wire [3:0] tmp_m_data_byteen;

wire [31:0] TC0_Addr, TC0_Din, TC0_Dout, TC1_Addr, TC1_Din, TC1_Dout;
wire [31:0] TC0_WD, TC1_WD;

mips_CPU mips_CPU (
    .clk(clk), 
    .reset(reset), 
    .HWInt(HWInt), 
	 
	 .i_inst_addr(i_inst_addr), //out
    .i_inst_rdata(i_inst_rdata), //in
    .m_data_rdata(m_data_rdata), //in
	 
    .m_data_addr(tmp_m_data_addr), //out 读写数据地址
   
    .m_data_wdata(tmp_m_data_wdata), //待写入DM的相应数据
    .m_data_byteen(tmp_m_data_byteen), //四位字节使能
    .m_inst_addr(m_inst_addr),//M级PC 
    .w_grf_we(w_grf_we), 
    .w_grf_addr(w_grf_addr), 
    .w_grf_wdata(w_grf_wdata), 
    .w_inst_addr(w_inst_addr), 
	 
    .macroscopic_pc(macroscopic_pc), 
    .m_int_addr(m_int_addr), 
    .m_int_byteen(m_int_byteen)
    );

Bridge Bridge (
    .m_data_addr(m_data_addr), //out
    .m_data_wdata(m_data_wdata), 
    .m_data_rdata1(m_data_rdata1), 
    .m_data_byteen(m_data_byteen), 
	 
    .tmp_m_data_addr(tmp_m_data_addr), //in
    .tmp_m_data_wdata(tmp_m_data_wdata), 
    .tmp_m_data_rdata(m_data_rdata), 
    .tmp_m_data_byteen(tmp_m_data_byteen), 
	 
    .TC0_Addr(TC0_Addr), 
    .TC0_WE(TC0_WE), 
    .TC0_Din(TC0_Din), 
    .TC0_Dout(TC0_Dout), //in
	 
    .TC1_Addr(TC1_Addr), 
    .TC1_WE(TC1_WE), 
    .TC1_Din(TC1_Din), 
    .TC1_Dout(TC1_Dout)//in
    );

TC TC0 (
    .clk(clk), 
    .reset(reset), 
    .Addr(TC0_Addr[31:2]), 
    .WE(TC0_WE), 
    .Din(TC0_Din), 
    .Dout(TC0_Dout), //out
    .IRQ(TC0_IRQ)
    );
	 
TC TC1 (
    .clk(clk), 
    .reset(reset), 
    .Addr(TC1_Addr[31:2]), 
    .WE(TC1_WE), 
    .Din(TC1_Din), 
    .Dout(TC1_Dout), //out
    .IRQ(TC1_IRQ)
    );

endmodule
