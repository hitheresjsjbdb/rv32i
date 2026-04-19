`timescale 1ns / 1ps
`include "instruction_def.v"

module riscv_decode (
    input  [31:0] ifid_ins,
    output [6:0]  opcode,
    output [2:0]  funct3,
    output [6:0]  funct7,
    output [4:0]  rs1,
    output [4:0]  rs2,
    output [4:0]  rd,
    output [11:0] imm12,
    output [20:1] offset20,
    output [11:0] offset12,
    output [31:0] imm_b32,
    output [31:0] imm_j32,
    output        id_use_rs1,
    output        id_use_rs2,
    output        dec_mem_read,
    output        dec_mem_write,
    output        dec_is_branch,
    output        dec_is_jal,
    output        dec_is_jalr,
    output        dec_is_ebreak
);

assign opcode   = ifid_ins[6:0];
assign funct3   = ifid_ins[14:12];
assign funct7   = ifid_ins[31:25];
assign rs1      = ifid_ins[19:15];
assign rs2      = ifid_ins[24:20];
assign rd       = ifid_ins[11:7];
assign imm12    = ifid_ins[31:20];
assign offset20 = {ifid_ins[31], ifid_ins[19:12], ifid_ins[20], ifid_ins[30:21]};

assign offset12 = (opcode == `INSTR_BTYPE_OP) ? {ifid_ins[31], ifid_ins[7], ifid_ins[30:25], ifid_ins[11:8]} :
                  (opcode == `INSTR_SW_OP)    ? {ifid_ins[31:25], ifid_ins[11:7]} : imm12;

assign imm_b32  = {{19{ifid_ins[31]}}, ifid_ins[31], ifid_ins[7], ifid_ins[30:25], ifid_ins[11:8], 1'b0};
assign imm_j32  = {{11{ifid_ins[31]}}, ifid_ins[31], ifid_ins[19:12], ifid_ins[20], ifid_ins[30:21], 1'b0};

assign id_use_rs1   = (opcode == `INSTR_RTYPE_OP) ||
                      (opcode == `INSTR_ITYPE_OP) ||
                      (opcode == `INSTR_LW_OP)    ||
                      (opcode == `INSTR_SW_OP)    ||
                      (opcode == `INSTR_BTYPE_OP) ||
                      (opcode == `INSTR_JALR_OP);

assign id_use_rs2   = (opcode == `INSTR_RTYPE_OP) ||
                      (opcode == `INSTR_SW_OP)    ||
                      (opcode == `INSTR_BTYPE_OP);

assign dec_mem_read  = (opcode == `INSTR_LW_OP);
assign dec_mem_write = (opcode == `INSTR_SW_OP);
assign dec_is_branch = (opcode == `INSTR_BTYPE_OP);
assign dec_is_jal    = (opcode == `INSTR_JAL_OP);
assign dec_is_jalr   = (opcode == `INSTR_JALR_OP);
assign dec_is_ebreak = (ifid_ins == 32'h0010_0073);

endmodule
