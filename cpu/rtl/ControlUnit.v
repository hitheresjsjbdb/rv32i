`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ControlUnit(
    input rst,
    input clk,
    input zero,
    input [6:0] opcode,
    input [6:0] Funct7,
    input [2:0] Funct3,
    output reg PCWrite,
    output reg InsMemRW,
    output reg IRWrite,
    output reg RFWrite,
    output reg DMCtrl,
    output reg ExtSel,
    output reg ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [1:0] RegSel,
    output reg [1:0] NPCOp,
    output reg [1:0] WDSel,
    output reg [3:0] ALUOp
);

always @(*) begin
    // Safe defaults: sequential fetch, no write-back side effects.
    PCWrite  = 1'b1;
    InsMemRW = 1'b1;
    IRWrite  = 1'b1;
    RFWrite  = 1'b0;
    DMCtrl   = `DMCtrl_RD;
    ExtSel   = `ExtSel_SIGNED;
    ALUSrcA  = `ALUSrcA_A;
    ALUSrcB  = `ALUSrcB_B;
    RegSel   = `RegSel_rd;
    NPCOp    = `NPC_PC;
    WDSel    = `WDSel_FromALU;
    ALUOp    = `ALUOp_ADD;

    case (opcode)
        // R-type (8): add/sub/and/or/xor/sll/srl/sra
        `INSTR_RTYPE_OP: begin
            RFWrite = 1'b1;
            case ({Funct7, Funct3})
                `INSTR_ADD_FUNCT: ALUOp = `ALUOp_ADD; // add
                `INSTR_SUB_FUNCT: ALUOp = `ALUOp_SUB; // sub
                `INSTR_AND_FUNCT: ALUOp = `ALUOp_AND; // and
                `INSTR_OR_FUNCT : ALUOp = `ALUOp_OR;  // or
                `INSTR_XOR_FUNCT: ALUOp = `ALUOp_XOR; // xor
                `INSTR_SLL_FUNCT: ALUOp = `ALUOp_SLL; // sll
                `INSTR_SRL_FUNCT: ALUOp = `ALUOp_SRL; // srl
                `INSTR_SRA_FUNCT: ALUOp = `ALUOp_SRA; // sra
                default: begin
                    RFWrite = 1'b0;
                    ALUOp   = `ALUOp_ADD;
                end
            endcase
        end

        // I-type ALU immediate (2): addi/ori
        `INSTR_ITYPE_OP: begin
            RFWrite = 1'b1;
            ALUSrcB = `ALUSrcB_Imm;
            case (Funct3)
                `INSTR_ADDI_FUNCT: begin
                    // addi
                    ExtSel = `ExtSel_SIGNED;
                    ALUOp  = `ALUOp_ADD;
                end
                `INSTR_ORI_FUNCT: begin
                    // ori
                    ExtSel = `ExtSel_ZERO;
                    ALUOp  = `ALUOp_OR;
                end
                default: begin
                    RFWrite = 1'b0;
                end
            endcase
        end

        // lw
        `INSTR_LW_OP: begin
            RFWrite = 1'b1;
            ExtSel  = `ExtSel_SIGNED;
            ALUSrcB = `ALUSrcB_Offset;
            ALUOp   = `ALUOp_ADD;
            DMCtrl  = `DMCtrl_RD;
            WDSel   = `WDSel_FromMEM;
        end

        // sw
        `INSTR_SW_OP: begin
            RFWrite = 1'b0;
            ExtSel  = `ExtSel_SIGNED;
            ALUSrcB = `ALUSrcB_Offset;
            ALUOp   = `ALUOp_ADD;
            DMCtrl  = `DMCtrl_WR;
        end

        // B-type (2): beq/bne
        `INSTR_BTYPE_OP: begin
            RFWrite = 1'b0;
            ALUSrcB = `ALUSrcB_B;
            ALUOp   = `ALUOp_SUB;
            case (Funct3)
                `INSTR_BEQ_FUNCT: NPCOp = zero ? `NPC_Offset12 : `NPC_PC; // beq
                `INSTR_BNE_FUNCT: NPCOp = zero ? `NPC_PC : `NPC_Offset12; // bne
                default: NPCOp = `NPC_PC;
            endcase
        end

        // jal
        `INSTR_JAL_OP: begin
            RFWrite = 1'b1;
            NPCOp   = `NPC_Offset20;
            WDSel   = `WDSel_FromPC;
        end

        // jalr
        `INSTR_JALR_OP: begin
            RFWrite = 1'b1;
            ExtSel  = `ExtSel_SIGNED;
            ALUSrcB = `ALUSrcB_Imm;
            ALUOp   = `ALUOp_ADD;
            NPCOp   = `NPC_rs;
            WDSel   = `WDSel_FromPC;
        end

        default: begin
            // Keep defaults.
        end
    endcase
end

endmodule