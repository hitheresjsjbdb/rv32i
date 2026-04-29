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

    input [4:0] rs1;
    input [4:0] rs2;
    input [4:0] rd;
    input [11:0] Imm12;
    input [11:0] Offset;
    input [19:0] Offset20;



);

always @(*) begin
    PCWrite  = IF_PCWrite;
    InsMemRW = IF_InsMemRW;
    IRWrite  = IF_IRWrite;
    RFWrite  = WB_RFWrite;
    DMCtrl   = MEM_DMCtrl;
    ExtSel   = ID_ExtSel;
    ALUSrcA  = EX_ALUSrcA;
    ALUSrcB  = EX_ALUSrcB;
    ALUOp    = EX_ALUOp;
    RegSel   = WB_RegSel;
    NPCOp    = EX_NPCOp;
    WDSel    = MEM_WDSel;
end

/* #################################### pipeline signals #################################### */

/* IF */

wire        IF_done;
wire        IF_bubble;
wire [9:0]  IM_addr;
wire [31:0] IF_PC, IF_PCA4;
wire [31:0] PC_NPC, NPC_NPC, NPC_PC, IM_PC;
reg  [3:0]  IF_ALUOp;
reg  [1:0]  IF_Regsel, IF_ALUSrcB, IF_WDSel, IF_RegSel;
reg         IF_ALUSrcA, IF_RFWrite, IF_DMCtrl, IF_PCWrite, IF_InsMemRW, IF_IRWrite, IF_ExtSel;


/* ID */
wire [31:0] ID_PCA4, ID_RD1, ID_RD2, ID_PC;
wire [11:0] ID_Imm12, ID_Offset;
wire [4:0]  ID_rs1, ID_rs2, ID_rd;
wire [3:0]  ID_ALUOp;
wire [1:0]  ID_Regsel, ID_ALUSrcB, ID_WDSel;
wire        ID_ALUSrcA, ID_RFWrite, ID_DMCtrl;
wire        ID_done;
wire        WBID_forward1, WBID_forward2;
wire        MEMID_forward1, MEMID_forward2;
wire        EX_branch;

wire [11:0] ID_Offset12;
wire [19:0] ID_Offset20;

/* EX */
wire [31:0] EX_Imm32, EX_PCA4, EX_PC;
wire [19:0] EX_Offset20;
wire [11:0] EX_Offset;
wire [3:0]  EX_ALUOp;
wire [4:0]  EX_rd;
wire [1:0]  EX_Regsel, EX_ALUSrcB, EX_WDSel, EX_NPCOp;
wire        EX_ALUSrcA, EX_RFWrite, EX_DMCtrl;
wire        EX_done;

/* MEM */
wire [31:0] MEM_WD, MEM_PCA4;
wire [4:0]  MEM_rd, MEMStall_rd;
wire [1:0]  MEM_WDSel, MEMStall_WDSel;
wire        MEM_RFWrite, MEM_DMCtrl, MEMStall_RFWrite;
wire        MEM_done, MEMStall_done;
wire        MEM_DMReadStall;
wire        MEMStall_stall;

/* WB */
wire [31:0] WB_WD;
wire [4:0]  WB_rd;
wire        WB_RFWrite;
wire        WB_done;

/* ******************************** Pipeline Stages ******************************** */

/* ################################ IF ################################ */

// decode
always @(*) begin
    // Safe defaults: sequential fetch, no write-back side effects.
    IF_PCWrite  = 1'b1;
    IF_InsMemRW = 1'b1;
    IF_IRWrite  = 1'b1;
    IF_RFWrite  = 1'b0;
    IF_DMCtrl   = `DMCtrl_RD;
    IF_ExtSel   = `ExtSel_SIGNED;
    IF_ALUSrcA  = `ALUSrcA_A;
    IF_ALUSrcB  = `ALUSrcB_B;
    IF_RegSel   = `RegSel_rd;
    //IF_NPCOp    = `NPC_PC;
    IF_WDSel    = `WDSel_FromALU;
    IF_ALUOp    = `ALUOp_ADD;

    case (opcode)
        // R-type (8): add/sub/and/or/xor/sll/srl/sra
        `INSTR_RTYPE_OP: begin
            IF_RFWrite = 1'b1;
            case ({Funct7, Funct3})
                `INSTR_ADD_FUNCT: IF_ALUOp = `ALUOp_ADD; // add
                `INSTR_SUB_FUNCT: IF_ALUOp = `ALUOp_SUB; // sub
                `INSTR_AND_FUNCT: IF_ALUOp = `ALUOp_AND; // and
                `INSTR_OR_FUNCT : IF_ALUOp = `ALUOp_OR;  // or
                `INSTR_XOR_FUNCT: IF_ALUOp = `ALUOp_XOR; // xor
                `INSTR_SLL_FUNCT: IF_ALUOp = `ALUOp_SLL; // sll
                `INSTR_SRL_FUNCT: IF_ALUOp = `ALUOp_SRL; // srl
                `INSTR_SRA_FUNCT: IF_ALUOp = `ALUOp_SRA; // sra
                default: begin
                    RFWrite = 1'b0;
                    ALUOp   = `ALUOp_ADD;
                end
            endcase
        end

        // I-type ALU immediate (2): addi/ori
        `INSTR_ITYPE_OP: begin
            IF_RFWrite = 1'b1;
            IF_ALUSrcB = `ALUSrcB_Imm;
            case (Funct3)
                `INSTR_ADDI_FUNCT: begin
                    // addi
                    IF_ExtSel = `ExtSel_SIGNED;
                    IF_ALUOp  = `ALUOp_ADD;
                end
                `INSTR_ORI_FUNCT: begin
                    // ori
                    IF_ExtSel = `ExtSel_ZERO;
                    IF_ALUOp  = `ALUOp_OR;
                end
                default: begin
                    IF_RFWrite = 1'b0;
                end
            endcase
        end

        // lw
        `INSTR_LW_OP: begin
            IF_RFWrite = 1'b1;
            IF_ExtSel  = `ExtSel_SIGNED;
            IF_ALUSrcB = `ALUSrcB_Offset;
            IF_ALUOp   = `ALUOp_ADD;
            IF_DMCtrl  = `DMCtrl_RD;
            IF_WDSel   = `WDSel_FromMEM;
        end

        // sw
        `INSTR_SW_OP: begin
            IF_RFWrite = 1'b0;
            IF_ExtSel  = `ExtSel_SIGNED;
            IF_ALUSrcB = `ALUSrcB_Offset;
            IF_ALUOp   = `ALUOp_ADD;
            IF_DMCtrl  = `DMCtrl_WR;
            IF_AR = 1'b1;
            IF_WB = 1'b0;
            IF_MEM = 1'b1;
        end

        // B-type (2): beq/bne
        `INSTR_BTYPE_OP: begin
            IF_RFWrite = 1'b0;
            IF_ALUSrcB = `ALUSrcB_B;
            IF_ALUOp   = `ALUOp_SUB;
        end

        // jal
        `INSTR_JAL_OP: begin
            IF_RFWrite = 1'b1;
            IF_NPCOp   = `NPC_Offset20;
            IF_WDSel   = `WDSel_FromPC;
        end

        // jalr
        `INSTR_JALR_OP: begin
            IF_RFWrite = 1'b1;
            IF_ExtSel  = `ExtSel_SIGNED;
            IF_ALUSrcB = `ALUSrcB_Imm;
            IF_ALUOp   = `ALUOp_ADD;
            IF_NPCOp   = `NPC_rs;
            IF_WDSel   = `WDSel_FromPC;
        end

        default: begin
            // Keep defaults.
        end
    endcase
end

// hazard detect (generate bubbles)
assign IF_bubble = (EX_branch != 1) &&
                   (((rs1 == EX_rd || rs2 == EX_rd) && EX_RFWrite == 1'b1 && EX_rd != 5'b0) ||
                   ((rs1 == ID_rd || rs2 == ID_rd) && ID_RFWrite == 1'b1 && ID_rd != 5'b0) ||
                   (ID_WDSel == `WDSel_FromMEM && ID_RFWrite == 1'b1) ||
                   ((rs1 == MEM_rd || rs2 == MEM_rd) && MEM_DMReadStall == 1'b1));

assign PC_NPC  = EX_branch ? NPC_NPC + 4 : IF_bubble ? IF_PCA4 : NPC_NPC;
assign IM_PC   = EX_branch ? NPC_NPC : IF_bubble ? IF_PC : PC;
assign IM_addr = IM_PC[11:2];
assign NPC_PC  = EX_branch ? EX_PC : PC;


/* ################################ ID ################################ */

wire [6:0] ID_opcode, EX_opcode;
wire [2:0] ID_Funct3, EX_Funct3;
reg  [1:0] ID_NPCOp;

// forward (in case RF read and write at the same cycle)
assign WBID_forward1  = ID_rs1 == WB_rd && WB_RFWrite == 1 && WB_rd != 0;
assign WBID_forward2  = ID_rs2 == WB_rd && WB_RFWrite == 1 && WB_rd != 0;

// forward (in case EX to 2nd)
assign MEMID_forward1 = ID_rs1 == MEM_rd && MEM_RFWrite == 1 && MEM_rd != 0;
assign MEMID_forward2 = ID_rs2 == MEM_rd && MEM_RFWrite == 1 && MEM_rd != 0;

assign ID_RD1 = WBID_forward1 ? WB_WD : RD1;
assign ID_RD2 = WBID_forward2 ? WB_WD : RD2;

assign cu_zero = ID_RD1 == ID_RD2;

Reg #(.WIDTH(7)) U_IFID_opcode (.clk(clk), .rst(rst), .en(1'b1), .in(bubble ? 7'b0 : opcode), .out(ID_opcode));
Reg #(.WIDTH(3)) U_IFID_Funct3 (.clk(clk), .rst(rst), .en(1'b1), .in(Funct3), .out(ID_Funct3));

Reg #(.WIDTH(7)) U_IDEX_opcode (.clk(clk), .rst(rst), .en(1'b1), .in(branch ? 7'b0 : ID_opcode), .out(EX_opcode));
Reg #(.WIDTH(3)) U_IDEX_Funct3 (.clk(clk), .rst(rst), .en(1'b1), .in(ID_Funct3), .out(EX_Funct3));


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

/* ################################ EX ################################ */

/* ################################ MEM ################################ */

assign MEM_DMReadStall = MEM_RFWrite == 1'b1 && MEM_WDSel == `WDSel_FromMEM;

/* ################################ WB ################################ */


/* #################################### pipeline #################################### */

Reg #(.WIDTH(1))  U_IF_done (.clk(clk), .rst(rst), .en(1'b1), .in(1'b1), .out(IF_done));
Reg #(.WIDTH(32)) U_IF_PC   (.clk(clk), .rst(rst), .en(~IF_bubble), .in(EX_branch ? IM_PC : PC)  , .out(IF_PC)  );
Reg #(.WIDTH(32)) U_IF_PCA4 (.clk(clk), .rst(rst), .en(~IF_bubble), .in(EX_branch ? NPC_NPC+4 : PCA4), .out(IF_PCA4));

/* IF -> ID */

Reg #(.WIDTH(32))  U_IFID_PCA4 (.clk(clk), .rst(rst), .en(1'b1), .in(IF_PCA4), .out(ID_PCA4));
Reg #(.WIDTH(32))  U_IFID_PC   (.clk(clk), .rst(rst), .en(1'b1), .in(IF_PC) , .out(ID_PC)  );

Reg #(.WIDTH(12))  U_IFID_Imm12 (.clk(clk), .rst(rst), .en(1'b1), .in(Imm12) , .out(ID_Imm12) );
Reg #(.WIDTH(12))  U_IFID_Offet (.clk(clk), .rst(rst), .en(1'b1), .in(Offset), .out(ID_Offset));

Reg #(.WIDTH(5) )  U_IFID_rs1 (.clk(clk), .rst(rst), .en(1'b1), .in(rs1), .out(ID_rs1));
Reg #(.WIDTH(5) )  U_IFID_rs2 (.clk(clk), .rst(rst), .en(1'b1), .in(rs2), .out(ID_rs2));
Reg #(.WIDTH(5) )  U_IFID_rd  (.clk(clk), .rst(rst), .en(1'b1), .in(rd) , .out(ID_rd) );

Reg #(.WIDTH(4) )  U_IFID_ALUOp (.clk(clk), .rst(rst), .en(1'b1), .in(IF_ALUOp), .out(ID_ALUOp));

Reg #(.WIDTH(2) )  U_IFID_Regsel  (.clk(clk), .rst(rst), .en(1'b1), .in(IF_RegSel) , .out(ID_Regsel) );
Reg #(.WIDTH(2) )  U_IFID_ALUSrcB (.clk(clk), .rst(rst), .en(1'b1), .in(IF_ALUSrcB), .out(ID_ALUSrcB));
Reg #(.WIDTH(2) )  U_IFID_WDSel   (.clk(clk), .rst(rst), .en(1'b1), .in(IF_WDSel)  , .out(ID_WDSel)  );

Reg #(.WIDTH(1) )  U_IFID_ALUSrcA (.clk(clk), .rst(rst), .en(1'b1), .in(IF_ALUSrcA), .out(ID_ALUSrcA));
Reg #(.WIDTH(1) )  U_IFID_RFWrite (.clk(clk), .rst(rst), .en(1'b1), .in(IF_bubble || EX_branch ? 1'b0 : RFWrite), .out(ID_RFWrite));
Reg #(.WIDTH(1) )  U_IFID_DMCtrl  (.clk(clk), .rst(rst), .en(1'b1), .in(IF_bubble || EX_branch ? 1'b0 : DMCtrl) , .out(ID_DMCtrl) );

Reg #(.WIDTH(1) )  U_IFID_done (.clk(clk), .rst(rst), .en(1'b1), .in(IF_bubble || EX_branch ? 1'b0 : IF_done), .out(ID_done));

// NPC
Reg #(.WIDTH(12))  U_IFID_Offset12 (.clk(clk), .rst(rst), .en(1'b1), .in(Offset), .out(ID_Offset12));
Reg #(.WIDTH(20))  U_IFID_Offset20 (.clk(clk), .rst(rst), .en(1'b1), .in(Offset20), .out(ID_Offset20));

/* ID -> EX */

Reg #(.WIDTH(32))  U_IDEX_Imm32 (.clk(clk), .rst(rst), .en(1'b1), .in(Imm32)  , .out(EX_Imm32));
Reg #(.WIDTH(32))  U_IDEX_PCA4  (.clk(clk), .rst(rst), .en(1'b1), .in(ID_PCA4), .out(EX_PCA4) );
Reg #(.WIDTH(32))  U_IDEX_PC    (.clk(clk), .rst(rst), .en(1'b1), .in(ID_PC)  , .out(EX_PC)   );

Reg #(.WIDTH(12))  U_IDEX_Offset (.clk(clk), .rst(rst), .en(1'b1), .in(ID_Offset), .out(EX_Offset));

Reg #(.WIDTH(5) )  U_IDEX_rd (.clk(clk), .rst(rst), .en(1'b1), .in(ID_rd), .out(EX_rd));

Reg #(.WIDTH(4) )  U_IDEX_ALUOp (.clk(clk), .rst(rst), .en(1'b1), .in(ID_ALUOp), .out(EX_ALUOp));

Reg #(.WIDTH(2) )  U_IDEX_Regsel  (.clk(clk), .rst(rst), .en(1'b1), .in(ID_Regsel) , .out(EX_Regsel) );
Reg #(.WIDTH(2) )  U_IDEX_ALUSrcB (.clk(clk), .rst(rst), .en(1'b1), .in(ID_ALUSrcB), .out(EX_ALUSrcB));
Reg #(.WIDTH(2) )  U_IDEX_WDSel   (.clk(clk), .rst(rst), .en(1'b1), .in(ID_WDSel)  , .out(EX_WDSel)  );

Reg #(.WIDTH(1) )  U_IDEX_ALUSrcA (.clk(clk), .rst(rst), .en(1'b1), .in(ID_ALUSrcA), .out(EX_ALUSrcA));
Reg #(.WIDTH(1) )  U_IDEX_RFWrite (.clk(clk), .rst(rst), .en(1'b1), .in(EX_branch ? 1'b0 : ID_RFWrite), .out(EX_RFWrite));
Reg #(.WIDTH(1) )  U_IDEX_DMCtrl  (.clk(clk), .rst(rst), .en(1'b1), .in(EX_branch ? 1'b0 : ID_DMCtrl) , .out(EX_DMCtrl) );

Reg #(.WIDTH(20))  U_IDEX_Offset20 (.clk(clk), .rst(rst), .en(1'b1), .in(ID_Offset20), .out(EX_Offset20));

Reg #(.WIDTH(1) )  U_IDEX_done (.clk(clk), .rst(rst), .en(1'b1), .in(EX_branch ? 1'b0 : ID_done), .out(EX_done));


endmodule