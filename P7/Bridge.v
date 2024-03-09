`timescale 1ns / 1ps

module Bridge(
	output [31:0] m_data_addr,
   output [31:0] m_data_wdata,
	output [31:0] m_data_rdata1,
	output [3:0] m_data_byteen,
	
	input [31:0] tmp_m_data_addr,
   input [31:0] tmp_m_data_wdata,
	input [31:0] tmp_m_data_rdata,
   input [3:0] tmp_m_data_byteen,
	
	output [31:0] TC0_Addr,
    output TC0_WE,
    output [31:0] TC0_Din,
    input [31:0] TC0_Dout,

    output [31:0] TC1_Addr,
    output TC1_WE,
    output [31:0] TC1_Din,
    input [31:0] TC1_Dout
    );

	assign TC0_WE = (tmp_m_data_addr >= 32'h0000_7F00 && 
			tmp_m_data_addr <= 32'h0000_7F0b) && (|tmp_m_data_byteen);
			
	assign TC1_WE = (tmp_m_data_addr >= 32'h0000_7F10 && 
			tmp_m_data_addr <= 32'h0000_7F1b) && (|tmp_m_data_byteen);
			
	assign TC0_Din = tmp_m_data_wdata;//要写入的值，不变
   assign TC1_Din = tmp_m_data_wdata;
	
	assign TC0_Addr = tmp_m_data_addr;//TC0_WE=1 才生效
   assign TC1_Addr = tmp_m_data_addr;///////////要写入的地址，不变
	 
	assign m_data_byteen = (TC0_WE || TC1_WE) ? 4'b0:
									tmp_m_data_byteen; //DM专属，写tc寄存器不算
	
	assign m_data_wdata = tmp_m_data_wdata;//要写入的值，不变
	
	assign m_data_rdata1 = (TC0_WE) ? TC0_Dout ://从TC寄存器读到的数据
                         (TC1_WE) ? TC1_Dout :
                          tmp_m_data_rdata; //从DM读到的数据
								  
	assign m_data_addr = tmp_m_data_addr;/////////
	 
endmodule
