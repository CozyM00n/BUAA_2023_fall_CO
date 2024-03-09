`timescale 1ns / 1ps

//SR state reg
`define IM SR[15:10]//�ֱ��Ӧ�����ⲿ�жϣ���Ӧλ��1��ʾ�����жϣ���0��ʾ��ֹ�ж�
//����һ�������Ĺ��ܣ�ֻ��ͨ��mtc0���ָ���޸ģ�ͨ���޸�������������ǿ�������һЩ�жϡ�
`define EXL SR[1]
//�κ��쳣����ʱ��λ�����ǿ�ƽ������̬��Ҳ���ǽ����쳣������򣩲���ֹ�ж�
`define IE SR[0]//ȫ���ж�ʹ�ܣ�1��ʾ�����ж�

//cause reg
`define BD Cause[31] //1:EPCָ��ǰָ���ǰһ��(j/b)
`define IP Cause[15:10] // �ⲿ�ж� HWInt
`define ExcCode Cause[6:2] //

module CP0(
	 input clk,
	 input reset,
	 input WE,
	 input [4:0] CP0Add,//CP0�����ĵ�ַ M_rd_addr
	 input [31:0] CP0In,//M_DMwd0 δ����, CP0 д������
	 input [31:0] VPC,//�ܺ���PC,PC_M
	 input BDIn,//�Ƿ����ӳٲ��е�ָ��,M_DelaySlot
	 input [4:0] ExcCodeIn,//�쳣����,M_EXCcode
	 input [5:0] HWInt,//�ж��ź�
	 input EXLclr,//��λ
	 
	 output [31:0] CP0Out,//CP0�����ֵ
	 output [31:0] EPCOut,//EPC
	 output Req     //���봦���������
    );
	reg [31:0] SR,Cause,EPC;
	initial begin
		SR <= 32'h0;
		Cause <= 32'h0;
		EPC <= 32'h0;
	end

	assign ExcReq = (!`EXL && (|ExcCodeIn) );
	assign IntReq = (!`EXL && `IE && (|(`IM & HWInt)) );//�ⲿ�ж�
	assign Req = (ExcReq | IntReq);
	wire [31:0] temp_EPC = (Req) ? ( (BDIn) ? VPC - 4 : VPC) :
								 EPC;
	always@(posedge clk) begin
		if(reset) begin
			SR <= 32'h0;
			Cause <= 32'h0;
			EPC <= 32'h0;
		end
		else begin
			if(EXLclr) `EXL <= 0;
			if(Req) begin
				`ExcCode <= (IntReq) ? 5'b0: ExcCodeIn;
				`EXL <= 1'b1;
				 EPC <= temp_EPC;
				`BD <= BDIn;
			end
			else if (WE) begin
				if(CP0Add == 12) SR <= CP0In;
				if(CP0Add == 14) EPC <= CP0In;
			end
			`IP <= HWInt;
		end
	end
	
	assign EPCOut = temp_EPC;
	 
	assign CP0Out = (CP0Add == 12) ? SR:
	                (CP0Add == 13) ? Cause:
						 (CP0Add == 14) ? EPC:
						 32'h0; 
endmodule
