`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ControlUnit(
    // control signal
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
    input IF_done,

    output bubble,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] ID_rd,
    input [4:0] EX_rd,
    input [4:0] MEM_rd,
    input [4:0] WB_rd,
    input [4:0] ID_rs1,
    input [4:0] ID_rs2,
    input [31:0] RD1_in,
    input [31:0] RD2_in,
    input [31:0] WB_WD_in,
    input WB_RFWrite,
    input MEM_DMReadStall,
    output [31:0] ID_RD1_out,
    output [31:0] ID_RD2_out,
    output ID_zero,
    output [3:0] ID_ALUOp,
    output [1:0] ID_RegSel,
    output [1:0] ID_ALUSrcB,
    output [1:0] ID_WDSel,
    output ID_ALUSrcA,
    output ID_RFWrite,
    output ID_DMCtrl,
    output ID_done,
    output [3:0] EX_ALUOp,
    output [1:0] EX_RegSel,
    output [1:0] EX_ALUSrcB,
    output [1:0] EX_WDSel,
    output EX_ALUSrcA,
    output EX_RFWrite,
    output EX_DMCtrl,
    output EX_done,
    output reg branch,
    output reg [1:0] EX_NPCOp

);

reg [2:0] State, NxtState;
reg AR, MEM, WB, EX, RFWrite_tmp;
wire WBID_forward1, WBID_forward2;
always @(*) RFWrite = RFWrite_tmp;

assign bubble = (((rs1 == EX_rd || rs2 == EX_rd) && EX_RFWrite == 1'b1 && EX_rd != 5'b0) ||
                 ((rs1 == ID_rd || rs2 == ID_rd) && ID_RFWrite == 1'b1 && ID_rd != 5'b0) ||
                 (ID_WDSel == `WDSel_FromMEM && ID_RFWrite == 1'b1) ||
                 ((rs1 == MEM_rd || rs2 == MEM_rd) && MEM_DMReadStall == 1'b1)) && (branch != 1'b1);

assign WBID_forward1 = (ID_rs1 == WB_rd) && (WB_RFWrite == 1'b1) && (WB_rd != 5'b0);
assign WBID_forward2 = (ID_rs2 == WB_rd) && (WB_RFWrite == 1'b1) && (WB_rd != 5'b0);
assign ID_RD1_out = WBID_forward1 ? WB_WD_in : RD1_in;
assign ID_RD2_out = WBID_forward2 ? WB_WD_in : RD2_in;
assign ID_zero = (ID_RD1_out == ID_RD2_out);

// assign done = State == `FSMState_IF;

// always @(posedge clk or posedge rst) begin
//     if (rst) State <= `FSMState_IF;
//     else State <= NxtState;
// end

// always @(posedge clk or posedge rst) begin
//     if (rst) PCWrite <= 1'b0;
//     else PCWrite <= NxtState == `FSMState_IF;
// end

// always @(*) begin
//     case (State)
//         `FSMState_IF:       NxtState = `FSMState_DECODE;
//         `FSMState_DECODE:   NxtState = `FSMState_EXEC;
//         `FSMState_EXEC:     NxtState = AR ? `FSMState_ALUR : MEM ? `FSMState_MEM : WB ? `FSMState_WB : `FSMState_IF;
//         `FSMState_ALUR:     NxtState = MEM ? `FSMState_MEM : WB ? `FSMState_WB : `FSMState_IF;
//         `FSMState_MEM:      NxtState = WB ? `FSMState_WB : `FSMState_IF;
//         `FSMState_WB:       NxtState = `FSMState_IF;
//         default:            NxtState = `FSMState_IF;
//     endcase
// end

always @(*) begin
    // Safe defaults: sequential fetch, no write-back side effects.
    PCWrite  = 1'b1;
    InsMemRW = 1'b1;
    IRWrite  = 1'b1;
    RFWrite_tmp  = 1'b0;
    AR = 1'b1;
    MEM = 1'b1;
    WB = 1'b1;
    EX = 1'b1;
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
            RFWrite_tmp = 1'b1;
            AR = 1'b1;
            WB = 1'b1;
            MEM = 1'b0;
            EX = 1'b1;
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
                    RFWrite_tmp = 1'b0;
                    ALUOp   = `ALUOp_ADD;
                end
            endcase
        end

        // I-type ALU immediate (2): addi/ori
        `INSTR_ITYPE_OP: begin
            RFWrite_tmp = 1'b1;
            ALUSrcB = `ALUSrcB_Imm;
            AR = 1'b1;
            WB = 1'b1;
            MEM = 1'b0;
            EX = 1'b1;
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
                    RFWrite_tmp = 1'b0;
                end
            endcase
        end

        // lw
        `INSTR_LW_OP: begin
            RFWrite_tmp = 1'b1;
            AR = 1'b1;
            WB = 1'b1;
            MEM = 1'b1;
            EX = 1'b1;
            ExtSel  = `ExtSel_SIGNED;
            ALUSrcB = `ALUSrcB_Offset;
            ALUOp   = `ALUOp_ADD;
            DMCtrl  = `DMCtrl_RD;
            WDSel   = `WDSel_FromMEM;
        end

        // sw
        `INSTR_SW_OP: begin
            RFWrite_tmp = 1'b0;
            ExtSel  = `ExtSel_SIGNED;
            ALUSrcB = `ALUSrcB_Offset;
            ALUOp   = `ALUOp_ADD;
            DMCtrl  = `DMCtrl_WR;
            AR = 1'b1;
            WB = 1'b0;
            MEM = 1'b1;
        end

        // B-type (2): beq/bne
        `INSTR_BTYPE_OP: begin
            RFWrite_tmp = 1'b0;
            ALUSrcB = `ALUSrcB_B;
            ALUOp   = `ALUOp_SUB;
            AR = 1'b0;
            WB = 1'b0;
            MEM = 1'b0;
            EX = 1'b1;
            case (Funct3)
                `INSTR_BEQ_FUNCT: NPCOp = zero ? `NPC_Offset12 : `NPC_PC; // beq
                `INSTR_BNE_FUNCT: NPCOp = zero ? `NPC_PC : `NPC_Offset12; // bne
                default: NPCOp = `NPC_PC;
            endcase
        end

        // jal
        `INSTR_JAL_OP: begin
            RFWrite_tmp = 1'b1;
            NPCOp   = `NPC_Offset20;
            WDSel   = `WDSel_FromPC;
            AR = 1'b0;
            WB = 1'b1;
            MEM = 1'b0;
            EX = 1'b0;
        end

        // jalr
        `INSTR_JALR_OP: begin
            RFWrite_tmp = 1'b1;
            ExtSel  = `ExtSel_SIGNED;
            ALUSrcB = `ALUSrcB_Imm;
            ALUOp   = `ALUOp_ADD;
            NPCOp   = `NPC_rs;
            WDSel   = `WDSel_FromPC;
            EX = 1'b1;
            AR = 1'b1;
            WB = 1'b1;
            MEM = 1'b0;
        end

        default: begin
            // Keep defaults.
        end
    endcase
end

wire [6:0] ID_opcode, EX_opcode;
wire [2:0] ID_Funct3, EX_Funct3;
reg [1:0] ID_NPCOp;


Reg #(.WIDTH(7)) U_IFID_opcode (.clk(clk), .rst(rst), .en(1'b1), .in(bubble ? 7'b0 : opcode), .out(ID_opcode));
Reg #(.WIDTH(3)) U_IFID_Funct3 (.clk(clk), .rst(rst), .en(1'b1), .in(Funct3), .out(ID_Funct3));

Reg #(.WIDTH(4)) U_IFID_ALUOp (.clk(clk), .rst(rst), .en(1'b1), .in(ALUOp), .out(ID_ALUOp));
Reg #(.WIDTH(2)) U_IFID_RegSel (.clk(clk), .rst(rst), .en(1'b1), .in(RegSel), .out(ID_RegSel));
Reg #(.WIDTH(2)) U_IFID_ALUSrcB (.clk(clk), .rst(rst), .en(1'b1), .in(ALUSrcB), .out(ID_ALUSrcB));
Reg #(.WIDTH(2)) U_IFID_WDSel (.clk(clk), .rst(rst), .en(1'b1), .in(WDSel), .out(ID_WDSel));
Reg #(.WIDTH(1)) U_IFID_ALUSrcA (.clk(clk), .rst(rst), .en(1'b1), .in(ALUSrcA), .out(ID_ALUSrcA));
Reg #(.WIDTH(1)) U_IFID_RFWrite (.clk(clk), .rst(rst), .en(1'b1), .in((bubble || branch) ? 1'b0 : RFWrite), .out(ID_RFWrite));
Reg #(.WIDTH(1)) U_IFID_DMCtrl (.clk(clk), .rst(rst), .en(1'b1), .in((bubble || branch) ? 1'b0 : DMCtrl), .out(ID_DMCtrl));
Reg #(.WIDTH(1)) U_IFID_done (.clk(clk), .rst(rst), .en(1'b1), .in((bubble || branch) ? 1'b0 : IF_done), .out(ID_done));

Reg #(.WIDTH(7)) U_IDEX_opcode (.clk(clk), .rst(rst), .en(1'b1), .in(branch ? 7'b0 : ID_opcode), .out(EX_opcode));
Reg #(.WIDTH(3)) U_IDEX_Funct3 (.clk(clk), .rst(rst), .en(1'b1), .in(ID_Funct3), .out(EX_Funct3));
Reg #(.WIDTH(4)) U_IDEX_ALUOp (.clk(clk), .rst(rst), .en(1'b1), .in(ID_ALUOp), .out(EX_ALUOp));
Reg #(.WIDTH(2)) U_IDEX_RegSel (.clk(clk), .rst(rst), .en(1'b1), .in(ID_RegSel), .out(EX_RegSel));
Reg #(.WIDTH(2)) U_IDEX_ALUSrcB (.clk(clk), .rst(rst), .en(1'b1), .in(ID_ALUSrcB), .out(EX_ALUSrcB));
Reg #(.WIDTH(2)) U_IDEX_WDSel (.clk(clk), .rst(rst), .en(1'b1), .in(ID_WDSel), .out(EX_WDSel));
Reg #(.WIDTH(1)) U_IDEX_ALUSrcA (.clk(clk), .rst(rst), .en(1'b1), .in(ID_ALUSrcA), .out(EX_ALUSrcA));
Reg #(.WIDTH(1)) U_IDEX_RFWrite (.clk(clk), .rst(rst), .en(1'b1), .in(branch ? 1'b0 : ID_RFWrite), .out(EX_RFWrite));
Reg #(.WIDTH(1)) U_IDEX_DMCtrl (.clk(clk), .rst(rst), .en(1'b1), .in(branch ? 1'b0 : ID_DMCtrl), .out(EX_DMCtrl));
Reg #(.WIDTH(1)) U_IDEX_done (.clk(clk), .rst(rst), .en(1'b1), .in(branch ? 1'b0 : ID_done), .out(EX_done));


always @(*) begin
    case (ID_opcode)
        `INSTR_BTYPE_OP: begin
            case (ID_Funct3)
                `INSTR_BEQ_FUNCT: ID_NPCOp = zero ? `NPC_Offset12 : `NPC_PC; // beq
                `INSTR_BNE_FUNCT: ID_NPCOp = zero ? `NPC_PC : `NPC_Offset12; // bne
                default: ID_NPCOp = `NPC_PC;
            endcase
        end

        // jal
        `INSTR_JAL_OP: begin
            ID_NPCOp   = `NPC_Offset20;
        end

        // jalr
        `INSTR_JALR_OP: begin
            ID_NPCOp   = `NPC_rs;
        end

        default: begin
            ID_NPCOp = `NPC_PC;
        end
    endcase
    
    //branch = (ID_NPCOp != `NPC_PC);

end

Reg #(.WIDTH(1)) U_branch (.clk(clk), .rst(rst), .en(1'b1), .in(branch ? 1'b0 : ID_NPCOp != `NPC_PC), .out(branch));
Reg #(.WIDTH(2)) U_NPCOp (.clk(clk), .rst(rst), .en(1'b1), .in(branch ? `NPC_PC : ID_NPCOp), .out(EX_NPCOp));


endmodule