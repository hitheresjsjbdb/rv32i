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

    output bubble,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] EX_rd,
    input [4:0] MEM_rd,
    input [4:0] WB_rd,
    input [4:0] rd_in,
    input [11:0] Imm12_in,
    input [31:0] Imm32_in,
    input [11:0] Offset_in,
    input [19:0] Offset20_in,
    input [31:0] IF_PCA4_in,
    input [31:0] IF_PC_in,
    input [31:0] RD1_in,
    input [31:0] RD2_in,
    input [31:0] RD1_r,
    input [31:0] RD2_r,
    input [31:0] WB_WD_in,
    input [31:0] EX_WD_in,
    input [31:0] EX_PCA4_in,
    input [31:0] ALU_result,
    input [31:0] ALU_result_r,
    input [31:0] WD_in,
    input [31:0] NPC_NPC_in,
    input WB_RFWrite,
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
    output [11:0] ID_Imm12_out,
    output [11:0] ID_Offset_out,
    output [19:0] ID_Offset20_out,
    output [4:0] ID_rs1_out,
    output [4:0] ID_rs2_out,
    output [4:0] ID_rd_out,
    output [31:0] EX_RD1_out,
    output [31:0] EX_RD2_out,
    output [3:0] EX_ALUOp,
    output [1:0] EX_RegSel,
    output [1:0] EX_ALUSrcB,
    output [1:0] EX_WDSel,
    output EX_ALUSrcA,
    output EX_RFWrite,
    output EX_DMCtrl,
    output EX_done,
    output [31:0] EX_Imm32_out,
    output [11:0] EX_Offset_out,
    output [19:0] EX_Offset20_out,
    output [31:0] EX_PCA4_out,
    output [31:0] EX_PC_out,
    output [4:0] EX_rd_out,
    output [31:0] MEM_WD_out,
    output [31:0] MEM_PCA4_out,
    output [4:0] MEM_rd_out,
    output [1:0] MEM_WDSel_out,
    output MEM_DMCtrl_out,
    output [1:0] MEMStall_WDSel_out,
    output MEMStall_stall_out,
    output [4:0] WB_rd_out,
    output WB_RFWrite_out,
    output [31:0] WB_WD_out,
    output done_out,
    output DMReadStall,
    output [31:0] dnpc_out,
    output reg branch,
    output reg [1:0] EX_NPCOp

);

reg [2:0] State, NxtState;
reg AR, MEM, WB, EX, RFWrite_tmp;
reg IF_done_reg;
wire [31:0] ID_Imm32_pipe;
wire [31:0] ID_PCA4_pipe, ID_PC_pipe;
wire WBID_forward1, WBID_forward2;
wire MEMID_forward1, MEMID_forward2;
wire EXID_forward1, EXID_forward2;
wire MEMEX_forward1, MEMEX_forward2;

wire MEM_RFWrite_out, MEM_done_out;
wire [4:0] MEMStall_rd_out;
wire MEMStall_RFWrite_out, MEMStall_done_out;
wire WB_done_out;
wire [31:0] MEM_dnpc_out, MEMStall_dnpc_out, WB_dnpc_out;
always @(*) RFWrite = RFWrite_tmp;

// IF stage
// hazard detection and stall signal generation
assign bubble = (branch != 1'b1) &&
                (((rs1 == EX_rd || rs2 == EX_rd) && EX_RFWrite == 1'b1 && EX_rd != 5'b0 && EX_WDSel == `WDSel_FromMEM) ||
                 //((rs1 == ID_rd_out || rs2 == ID_rd_out) && ID_RFWrite == 1'b1 && ID_rd_out != 5'b0) ||
                 (ID_WDSel == `WDSel_FromMEM && ID_RFWrite == 1'b1) ||  // lw hazard
                 ((rs1 == MEM_rd || rs2 == MEM_rd) && DMReadStall == 1'b1));

// ID stage forward

// read and write RF at the same cycle
assign WBID_forward1 = (ID_rs1_out == WB_rd) && (WB_RFWrite == 1'b1) && (WB_rd != 5'b0);
assign WBID_forward2 = (ID_rs2_out == WB_rd) && (WB_RFWrite == 1'b1) && (WB_rd != 5'b0);

// EX to 2nd
assign MEMID_forward1 = (ID_rs1_out == MEM_rd) && (MEM_RFWrite_out == 1'b1) && (MEM_WDSel_out == `WDSel_FromALU) && (MEM_rd != 5'b0);
assign MEMID_forward2 = (ID_rs2_out == MEM_rd) && (MEM_RFWrite_out == 1'b1) && (MEM_WDSel_out == `WDSel_FromALU) && (MEM_rd != 5'b0);

// EX to 1st
assign EXID_forward1 = (ID_rs1_out == EX_rd_out) && (EX_RFWrite == 1'b1) && (EX_rd_out != 5'b0) && (EX_WDSel == `WDSel_FromALU);
assign EXID_forward2 = (ID_rs2_out == EX_rd_out) && (EX_RFWrite == 1'b1) && (EX_rd_out != 5'b0) && (EX_WDSel == `WDSel_FromALU);

// forwarding
assign ID_RD1_out = EXID_forward1 ? ALU_result : (MEMID_forward1 ? ALU_result_r : (WBID_forward1 ? WB_WD_in : RD1_in));
assign ID_RD2_out = EXID_forward2 ? ALU_result : (MEMID_forward2 ? ALU_result_r : (WBID_forward2 ? WB_WD_in : RD2_in));

assign ID_zero = (ID_RD1_out == ID_RD2_out);

// // EX stage forward
// Flopr #(.WIDTH(1)) U_MEMEX_forward1 (.clk(clk), .rst(rst), .en(1'b1), .in_data(EXID_forward1), .out_data(MEMEX_forward1));
// Flopr #(.WIDTH(1)) U_MEMEX_forward2 (.clk(clk), .rst(rst), .en(1'b1), .in_data(EXID_forward2), .out_data(MEMEX_forward2));

// //forwarding
// assign EX_RD1_out = MEMEX_forward1 ? ALU_result_r : RD1_r;
// assign EX_RD2_out = MEMEX_forward2 ? ALU_result_r : RD2_r;

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
                    ExtSel = `ExtSel_SIGNED;
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

always @(posedge clk or posedge rst) begin
    if (rst) begin
        IF_done_reg <= 1'b0;
    end else begin
        IF_done_reg <= 1'b1;
    end
end

wire [6:0] ID_opcode, EX_opcode;
wire [2:0] ID_Funct3, EX_Funct3;
reg [1:0] ID_NPCOp;

Flopr #(.WIDTH(12), .USE_EN(1)) U_IFID_Imm12 (.clk(clk), .rst(rst), .en(1'b1), .in_data(Imm12_in), .out_data(ID_Imm12_out));
Flopr #(.WIDTH(32), .USE_EN(1)) U_IFID_Imm32 (.clk(clk), .rst(rst), .en(1'b1), .in_data(Imm32_in), .out_data(ID_Imm32_pipe));
Flopr #(.WIDTH(12), .USE_EN(1)) U_IFID_Offset (.clk(clk), .rst(rst), .en(1'b1), .in_data(Offset_in), .out_data(ID_Offset_out));
Flopr #(.WIDTH(20), .USE_EN(1)) U_IFID_Offset20 (.clk(clk), .rst(rst), .en(1'b1), .in_data(Offset20_in), .out_data(ID_Offset20_out));
Flopr #(.WIDTH(5), .USE_EN(1)) U_IFID_rs1 (.clk(clk), .rst(rst), .en(1'b1), .in_data(rs1), .out_data(ID_rs1_out));
Flopr #(.WIDTH(5), .USE_EN(1)) U_IFID_rs2 (.clk(clk), .rst(rst), .en(1'b1), .in_data(rs2), .out_data(ID_rs2_out));
Flopr #(.WIDTH(5), .USE_EN(1)) U_IFID_rd (.clk(clk), .rst(rst), .en(1'b1), .in_data(rd_in), .out_data(ID_rd_out));
Flopr #(.WIDTH(32), .USE_EN(1)) U_IFID_PCA4 (.clk(clk), .rst(rst), .en(1'b1), .in_data(IF_PCA4_in), .out_data(ID_PCA4_pipe));
Flopr #(.WIDTH(32), .USE_EN(1)) U_IFID_PC (.clk(clk), .rst(rst), .en(1'b1), .in_data(IF_PC_in), .out_data(ID_PC_pipe));

Flopr #(.WIDTH(7), .USE_EN(1)) U_IFID_opcode (.clk(clk), .rst(rst), .en(1'b1), .in_data(bubble ? 7'b0 : opcode), .out_data(ID_opcode));
Flopr #(.WIDTH(3), .USE_EN(1)) U_IFID_Funct3 (.clk(clk), .rst(rst), .en(1'b1), .in_data(Funct3), .out_data(ID_Funct3));

Flopr #(.WIDTH(4), .USE_EN(1)) U_IFID_ALUOp (.clk(clk), .rst(rst), .en(1'b1), .in_data(ALUOp), .out_data(ID_ALUOp));
Flopr #(.WIDTH(2), .USE_EN(1)) U_IFID_RegSel (.clk(clk), .rst(rst), .en(1'b1), .in_data(RegSel), .out_data(ID_RegSel));
Flopr #(.WIDTH(2), .USE_EN(1)) U_IFID_ALUSrcB (.clk(clk), .rst(rst), .en(1'b1), .in_data(ALUSrcB), .out_data(ID_ALUSrcB));
Flopr #(.WIDTH(2), .USE_EN(1)) U_IFID_WDSel (.clk(clk), .rst(rst), .en(1'b1), .in_data(WDSel), .out_data(ID_WDSel));
Flopr #(.WIDTH(1), .USE_EN(1)) U_IFID_ALUSrcA (.clk(clk), .rst(rst), .en(1'b1), .in_data(ALUSrcA), .out_data(ID_ALUSrcA));
Flopr #(.WIDTH(1), .USE_EN(1)) U_IFID_RFWrite (.clk(clk), .rst(rst), .en(1'b1), .in_data((bubble || branch) ? 1'b0 : RFWrite), .out_data(ID_RFWrite));
Flopr #(.WIDTH(1), .USE_EN(1)) U_IFID_DMCtrl (.clk(clk), .rst(rst), .en(1'b1), .in_data((bubble || branch) ? 1'b0 : DMCtrl), .out_data(ID_DMCtrl));
Flopr #(.WIDTH(1), .USE_EN(1)) U_IFID_done (.clk(clk), .rst(rst), .en(1'b1), .in_data((bubble || branch) ? 1'b0 : IF_done_reg), .out_data(ID_done));

Flopr #(.WIDTH(7), .USE_EN(1)) U_IDEX_opcode (.clk(clk), .rst(rst), .en(1'b1), .in_data(branch ? 7'b0 : ID_opcode), .out_data(EX_opcode));
Flopr #(.WIDTH(3), .USE_EN(1)) U_IDEX_Funct3 (.clk(clk), .rst(rst), .en(1'b1), .in_data(ID_Funct3), .out_data(EX_Funct3));
Flopr #(.WIDTH(4), .USE_EN(1)) U_IDEX_ALUOp (.clk(clk), .rst(rst), .en(1'b1), .in_data(ID_ALUOp), .out_data(EX_ALUOp));
Flopr #(.WIDTH(2), .USE_EN(1)) U_IDEX_RegSel (.clk(clk), .rst(rst), .en(1'b1), .in_data(ID_RegSel), .out_data(EX_RegSel));
Flopr #(.WIDTH(2), .USE_EN(1)) U_IDEX_ALUSrcB (.clk(clk), .rst(rst), .en(1'b1), .in_data(ID_ALUSrcB), .out_data(EX_ALUSrcB));
Flopr #(.WIDTH(2), .USE_EN(1)) U_IDEX_WDSel (.clk(clk), .rst(rst), .en(1'b1), .in_data(ID_WDSel), .out_data(EX_WDSel));
Flopr #(.WIDTH(1), .USE_EN(1)) U_IDEX_ALUSrcA (.clk(clk), .rst(rst), .en(1'b1), .in_data(ID_ALUSrcA), .out_data(EX_ALUSrcA));
Flopr #(.WIDTH(1), .USE_EN(1)) U_IDEX_RFWrite (.clk(clk), .rst(rst), .en(1'b1), .in_data(branch ? 1'b0 : ID_RFWrite), .out_data(EX_RFWrite));
Flopr #(.WIDTH(1), .USE_EN(1)) U_IDEX_DMCtrl (.clk(clk), .rst(rst), .en(1'b1), .in_data(branch ? 1'b0 : ID_DMCtrl), .out_data(EX_DMCtrl));
Flopr #(.WIDTH(1), .USE_EN(1)) U_IDEX_done (.clk(clk), .rst(rst), .en(1'b1), .in_data(branch ? 1'b0 : ID_done), .out_data(EX_done));
Flopr #(.WIDTH(32), .USE_EN(1)) U_IDEX_Imm32 (.clk(clk), .rst(rst), .en(1'b1), .in_data(ID_Imm32_pipe), .out_data(EX_Imm32_out));
Flopr #(.WIDTH(12), .USE_EN(1)) U_IDEX_Offset (.clk(clk), .rst(rst), .en(1'b1), .in_data(ID_Offset_out), .out_data(EX_Offset_out));
Flopr #(.WIDTH(20), .USE_EN(1)) U_IDEX_Offset20 (.clk(clk), .rst(rst), .en(1'b1), .in_data(ID_Offset20_out), .out_data(EX_Offset20_out));
Flopr #(.WIDTH(32), .USE_EN(1)) U_IDEX_PCA4 (.clk(clk), .rst(rst), .en(1'b1), .in_data(ID_PCA4_pipe), .out_data(EX_PCA4_out));
Flopr #(.WIDTH(32), .USE_EN(1)) U_IDEX_PC (.clk(clk), .rst(rst), .en(1'b1), .in_data(ID_PC_pipe), .out_data(EX_PC_out));
Flopr #(.WIDTH(5), .USE_EN(1)) U_IDEX_rd (.clk(clk), .rst(rst), .en(1'b1), .in_data(ID_rd_out), .out_data(EX_rd_out));


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

Flopr #(.WIDTH(1), .USE_EN(1)) U_branch (.clk(clk), .rst(rst), .en(1'b1), .in_data(branch ? 1'b0 : ID_NPCOp != `NPC_PC), .out_data(branch));
Flopr #(.WIDTH(2), .USE_EN(1)) U_NPCOp (.clk(clk), .rst(rst), .en(1'b1), .in_data(branch ? `NPC_PC : ID_NPCOp), .out_data(EX_NPCOp));

Flopr #(.WIDTH(32), .USE_EN(1)) U_EXMEM_WD (.clk(clk), .rst(rst), .en(1'b1), .in_data(RD2_r), .out_data(MEM_WD_out));
Flopr #(.WIDTH(32), .USE_EN(1)) U_EXMEM_PCA4 (.clk(clk), .rst(rst), .en(1'b1), .in_data(EX_PCA4_in), .out_data(MEM_PCA4_out));
Flopr #(.WIDTH(5), .USE_EN(1)) U_EXMEM_rd (.clk(clk), .rst(rst), .en(1'b1), .in_data(EX_rd), .out_data(MEM_rd_out));
Flopr #(.WIDTH(2), .USE_EN(1)) U_EXMEM_WDSel (.clk(clk), .rst(rst), .en(1'b1), .in_data(EX_WDSel), .out_data(MEM_WDSel_out));
Flopr #(.WIDTH(1), .USE_EN(1)) U_EXMEM_RFWrite (.clk(clk), .rst(rst), .en(1'b1), .in_data(EX_RFWrite), .out_data(MEM_RFWrite_out));
Flopr #(.WIDTH(1), .USE_EN(1)) U_EXMEM_DMCtrl (.clk(clk), .rst(rst), .en(1'b1), .in_data(EX_DMCtrl), .out_data(MEM_DMCtrl_out));
Flopr #(.WIDTH(1), .USE_EN(1)) U_EXMEM_done (.clk(clk), .rst(rst), .en(1'b1), .in_data(EX_done), .out_data(MEM_done_out));
Flopr #(.WIDTH(32), .USE_EN(1)) U_EXMEM_dnpc (.clk(clk), .rst(rst), .en(1'b1), .in_data(branch ? NPC_NPC_in : EX_PCA4_in), .out_data(MEM_dnpc_out));

assign DMReadStall = (MEM_RFWrite_out == 1'b1) && (MEM_WDSel_out == `WDSel_FromMEM);

Flopr #(.WIDTH(5), .USE_EN(1)) U_MEMSTALL_rd (.clk(clk), .rst(rst), .en(1'b1), .in_data(DMReadStall ? MEM_rd_out : 5'b0), .out_data(MEMStall_rd_out));
Flopr #(.WIDTH(2), .USE_EN(1)) U_MEMSTALL_WDSel (.clk(clk), .rst(rst), .en(1'b1), .in_data(DMReadStall ? MEM_WDSel_out : 2'b0), .out_data(MEMStall_WDSel_out));
Flopr #(.WIDTH(1), .USE_EN(1)) U_MEMSTALL_RFWrite (.clk(clk), .rst(rst), .en(1'b1), .in_data(DMReadStall ? MEM_RFWrite_out : 1'b0), .out_data(MEMStall_RFWrite_out));
Flopr #(.WIDTH(1), .USE_EN(1)) U_MEMSTALL_done (.clk(clk), .rst(rst), .en(1'b1), .in_data(DMReadStall ? MEM_done_out : 1'b0), .out_data(MEMStall_done_out));
Flopr #(.WIDTH(1), .USE_EN(1)) U_MEMSTALL_stall (.clk(clk), .rst(rst), .en(1'b1), .in_data(DMReadStall), .out_data(MEMStall_stall_out));
Flopr #(.WIDTH(32), .USE_EN(1)) U_MEMSTALL_dnpc (.clk(clk), .rst(rst), .en(1'b1), .in_data(MEM_dnpc_out), .out_data(MEMStall_dnpc_out));

Flopr #(.WIDTH(5), .USE_EN(1)) U_WB_rd (.clk(clk), .rst(rst), .en(1'b1), .in_data(MEMStall_stall_out ? MEMStall_rd_out : MEM_rd_out), .out_data(WB_rd_out));
Flopr #(.WIDTH(1), .USE_EN(1)) U_WB_RFWrite (.clk(clk), .rst(rst), .en(1'b1), .in_data(DMReadStall ? 1'b0 : (MEMStall_stall_out ? MEMStall_RFWrite_out : MEM_RFWrite_out)), .out_data(WB_RFWrite_out));
Flopr #(.WIDTH(1), .USE_EN(1)) U_WB_done (.clk(clk), .rst(rst), .en(1'b1), .in_data(DMReadStall ? 1'b0 : (MEMStall_stall_out ? MEMStall_done_out : MEM_done_out)), .out_data(WB_done_out));
Flopr #(.WIDTH(32), .USE_EN(1)) U_WB_WD (.clk(clk), .rst(rst), .en(1'b1), .in_data(WD_in), .out_data(WB_WD_out));
Flopr #(.WIDTH(32), .USE_EN(1)) U_WB_dnpc (.clk(clk), .rst(rst), .en(1'b1), .in_data(MEMStall_stall_out ? MEMStall_dnpc_out : MEM_dnpc_out), .out_data(WB_dnpc_out));
Flopr #(.WIDTH(1), .USE_EN(1)) U_done (.clk(clk), .rst(rst), .en(1'b1), .in_data(WB_done_out), .out_data(done_out));
Flopr #(.WIDTH(32), .USE_EN(1)) U_dnpc (.clk(clk), .rst(rst), .en(1'b1), .in_data(WB_dnpc_out), .out_data(dnpc_out));


endmodule
