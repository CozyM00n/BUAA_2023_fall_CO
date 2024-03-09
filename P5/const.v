`timescale 1ns / 1ps
`define ALU_add 4'b0000
`define ALU_sub 4'b0001
`define ALU_lui 4'b0010
`define ALU_ori 4'b0011

`define CMP_beq 2'b01

`define NPC_rs 3'b011
`define NPC_b 3'b001
`define NPC_j 3'b010
//DM
`define DMload 2'b01
`define DMstore 2'b10

//RFWDsel
`define RFcal 3'b001
`define RFjal 3'b011
`define RFload 3'b010