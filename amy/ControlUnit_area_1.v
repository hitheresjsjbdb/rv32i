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
    output reg [3:0] ALUOp,

    output reg done,

    output reg DecUseRs1,
    output reg DecUseRs2,
    output reg DecIsLoad,
    output reg DecIsStore,
    output reg DecIsBranch,
    output reg DecIsJal,
    output reg DecIsJalr
);

always @(*) begin
    // Default decode: fetch/pc move enabled. Stall/flush are handled in riscv.v.
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
    done     = 1'b0;

    DecUseRs1   = 1'b0;
    DecUseRs2   = 1'b0;
    DecIsLoad   = 1'b0;
    DecIsStore  = 1'b0;
    DecIsBranch = 1'b0;
    DecIsJal    = 1'b0;
    DecIsJalr   = 1'b0;

    case (opcode)
        `INSTR_RTYPE_OP: begin
            RFWrite = 1'b1;
            DecUseRs1 = 1'b1;
            DecUseRs2 = 1'b1;
            case ({Funct7, Funct3})
                `INSTR_ADD_FUNCT: ALUOp = `ALUOp_ADD;
                `INSTR_SUB_FUNCT: ALUOp = `ALUOp_SUB;
                `INSTR_AND_FUNCT: ALUOp = `ALUOp_AND;
                `INSTR_OR_FUNCT : ALUOp = `ALUOp_OR;
                `INSTR_XOR_FUNCT: ALUOp = `ALUOp_XOR;
                `INSTR_SLL_FUNCT: ALUOp = `ALUOp_SLL;
                `INSTR_SRL_FUNCT: ALUOp = `ALUOp_SRL;
                `INSTR_SRA_FUNCT: ALUOp = `ALUOp_SRA;
                default: RFWrite = 1'b0;
            endcase
        end

        `INSTR_ITYPE_OP: begin
            RFWrite = 1'b1;
            ALUSrcB = `ALUSrcB_Imm;
            DecUseRs1 = 1'b1;
            case (Funct3)
                `INSTR_ADDI_FUNCT: begin
                    ExtSel = `ExtSel_SIGNED;
                    ALUOp  = `ALUOp_ADD;
                end
                `INSTR_ORI_FUNCT: begin
                    ExtSel = `ExtSel_SIGNED;
                    ALUOp  = `ALUOp_OR;
                end
                default: RFWrite = 1'b0;
            endcase
        end

        `INSTR_LW_OP: begin
            RFWrite = 1'b1;
            ALUSrcB = `ALUSrcB_Offset;
            DMCtrl  = `DMCtrl_RD;
            WDSel   = `WDSel_FromMEM;
            ALUOp   = `ALUOp_ADD;
            DecUseRs1 = 1'b1;
            DecIsLoad = 1'b1;
        end

        `INSTR_SW_OP: begin
            RFWrite = 1'b0;
            ALUSrcB = `ALUSrcB_Offset;
            DMCtrl  = `DMCtrl_WR;
            ALUOp   = `ALUOp_ADD;
            DecUseRs1  = 1'b1;
            DecUseRs2  = 1'b1;
            DecIsStore = 1'b1;
        end

        `INSTR_BTYPE_OP: begin
            RFWrite = 1'b0;
            ALUSrcB = `ALUSrcB_B;
            ALUOp   = `ALUOp_SUB;
            DecUseRs1   = 1'b1;
            DecUseRs2   = 1'b1;
            DecIsBranch = 1'b1;
        end

        `INSTR_JAL_OP: begin
            RFWrite = 1'b1;
            NPCOp   = `NPC_Offset20;
            WDSel   = `WDSel_FromPC;
            ALUOp   = `ALUOp_ADD;
            DecIsJal = 1'b1;
        end

        `INSTR_JALR_OP: begin
            RFWrite = 1'b1;
            ExtSel  = `ExtSel_SIGNED;
            ALUSrcB = `ALUSrcB_Imm;
            NPCOp   = `NPC_rs;
            WDSel   = `WDSel_FromPC;
            ALUOp   = `ALUOp_ADD;
            DecUseRs1 = 1'b1;
            DecIsJalr = 1'b1;
        end

        default: begin
            // Keep defaults.
        end
    endcase
end

endmodule
