`timescale 1ns / 1ps

`include "instruction_def.v"

// Structural instruction-field extraction for the registered ID instruction.
module InstructionFields(
    input  [31:0] instruction,
    output [6:0]  opcode,
    output [6:0]  funct7,
    output [2:0]  funct3,
    output [4:0]  rs1,
    output [4:0]  rs2,
    output [4:0]  rd,
    output [11:0] imm12,
    output [11:0] offset12,
    output [19:0] offset20
);

assign opcode = instruction[6:0];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd = instruction[11:7];
assign imm12 = instruction[31:20];
assign offset20 = {instruction[31], instruction[19:12], instruction[20],
                   instruction[30:21]};
assign offset12 = (opcode == `INSTR_BTYPE_OP) ?
                  {instruction[31], instruction[7], instruction[30:25],
                   instruction[11:8]} :
                  (opcode == `INSTR_SW_OP) ?
                  {instruction[31:25], instruction[11:7]} : imm12;

endmodule
