`timescale 1ns / 1ps
`include "instruction_def.v"

module riscv_branch_unit (
    input        idex_valid,
    input        idex_is_jal,
    input        idex_is_jalr,
    input        idex_is_branch,
    input  [2:0] idex_funct3,
    input        zero,
    input  [31:0] idex_pc,
    input  [31:0] idex_npc_imm,
    input  [31:0] ex_rs1_fwd,
    input        idex_pred_taken,

    output       ex_branch_cond,
    output       ex_take_branch,
    output [31:0] ex_branch_target,
    output [31:0] ex_recover_npc,
    output [31:0] ex_dnpc,
    output       ex_mispredict
);

assign ex_branch_cond = (idex_funct3 == `INSTR_BEQ_FUNCT) ? zero :
                        (idex_funct3 == `INSTR_BNE_FUNCT) ? ~zero :
                                                            1'b0;

assign ex_take_branch  = idex_valid && (idex_is_jal || idex_is_jalr || (idex_is_branch && ex_branch_cond));
assign ex_branch_target = idex_is_jalr ? ((ex_rs1_fwd + idex_npc_imm) & 32'hffff_fffe)
                                        : (idex_pc + idex_npc_imm);
assign ex_recover_npc = ex_take_branch ? ex_branch_target : (idex_pc + 32'd4);
assign ex_dnpc = ex_recover_npc;
assign ex_mispredict = idex_valid && (ex_take_branch ^ idex_pred_taken);

endmodule
