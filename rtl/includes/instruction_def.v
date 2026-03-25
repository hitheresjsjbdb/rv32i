`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/20 19:50:15
// Design Name: 
// Module Name: instruction_def
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// OPCODE
`define INSTR_RTYPE_OP  7'b0110011
`define INSTR_ITYPE_OP  7'b0010011
`define INSTR_LW_OP     7'b0000011
`define INSTR_SW_OP     7'b0100011
`define INSTR_JAL_OP    7'b1101111
`define INSTR_JALR_OP   7'b1100111

// R-type FUNCT
`define INSTR_ADD_FUNCT  10'b0000000000
`define INSTR_SUB_FUNCT  10'b0100000000
`define INSTR_AND_FUNCT  10'b0000000111
`define INSTR_OR_FUNCT   10'b0000000110
`define INSTR_XOR_FUNCT  10'b0000000100
`define INSTR_NOR_FUNCT  10'b0000000101
`define INSTR_SLL_FUNCT  10'b0000000001
`define INSTR_SRL_FUNCT  10'b0000000101
`define INSTR_SRA_FUNCT  10'b0100000101
`define INSTR_SLLV_FUNCT 10'b0000000000
`define INSTR_SRLV_FUNCT 10'b0000000100
`define INSTR_SRAV_FUNCT 10'b0100000100
`define INSTR_JR_FUNCT   10'b0000000000

// B-type FUNCT
`define INSTR_BEQ_FUNCT  3'b000
`define INSTR_BNE_FUNCT  3'b001

// I-type FUNCT
`define INSTR_ADDI_FUNCT 3'b000
`define INSTR_ORI_FUNCT  3'b110