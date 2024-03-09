`timescale 1ns / 1ps
//ALU
`define ALU_add 4'b0000
`define ALU_sub 4'b0001
`define ALU_lui 4'b0010
`define ALU_or  4'b0011
`define ALU_and 4'b0100
`define ALU_slt 4'b0101
`define ALU_sltu 4'b0110

//NPC
`define NPC_rs 3'b011
`define NPC_b 3'b001
`define NPC_j 3'b010
`define NPC_rt 3'b100

//DMsel
`define DM_byte 3'b001
`define DM_half 3'b010
`define DM_word 3'b011

//RFWDsel
`define RF_cal 3'b001
`define RF_jlink 3'b011
`define RF_load 3'b010
`define RF_mdu 3'b100

//CMP
`define CMP_beq 3'b001
`define CMP_bne 3'b010
`define CMP_bltzal 3'b011
`define CMP_bgezalr 3'b110

//MDU
`define MDU_mult    4'b0001
`define MDU_div     4'b0010
`define MDU_multu   4'b0011
`define MDU_divu    4'b0100

`define MDU_mfhi    4'b0101
`define MDU_mflo    4'b0110
`define MDU_mthi    4'b0111
`define MDU_mtlo    4'b1000
`define MDU_msub   4'b1001

//DE load
`define DE_lw   3'b001
`define DE_lh   3'b010
`define DE_lb   3'b011

//BE store
`define BE_sw   3'b001
`define BE_sh   3'b010
`define BE_sb   3'b011