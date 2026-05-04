`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"
`include "global_def.v"

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

    /* new ports */
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [11:0] Imm12,
    input [11:0] Offset,
    input [19:0] Offset20,
    input [31:0] PC,
    input [31:0] PCA4,
    input [31:0] NPC,
    input [31:0] RD1,
    input [31:0] RD2,
    input [31:0] Imm32,
    input [31:0] ALU_result,
    input [31:0] ALU_result_r,
    input [31:0] WD,
    input [31:0] RD2_r,

    output reg stall,
    output reg branch,
    output reg [31:0] PC_NPC,
    output reg [31:0] NPC_PC,
    output reg [19:0] NPC_EX_Offset20,
    output reg [11:0] NPC_EX_Offset12,
    output reg [9:0] IM_addr,
    output reg [4:0] MUX_WB_rd,
    output reg [11:0] EXT_ID_Imm12,
    output reg forward1,
    output reg forward2,
    output reg [31:0] FD1,
    output reg [31:0] FD2,
    output reg [31:0] ALU_B_Imm,
    output reg [31:0] RF_WD,
    output reg [31:0] MUX_PCA4,
    output reg [31:0] DM_WD,
    output reg [4:0]  RF_RR1,
    output reg [4:0]  RF_RR2

    `ifdef DIFFTEST
    , output done
    `endif


);

`ifdef DIFFTEST
Flopr #(.WIDTH(1)) U_done (.clk(clk), .rst(rst), .in_data(WB_done), .out_data(done));
`endif


/* #################################### pipeline signals #################################### */

/* IF */

wire        IF_done;
wire        IF_stall;
wire [31:0] IF_PC, IF_PCA4;
wire [31:0] NPC_NPC, IM_PC;
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
wire        EXID_forward1, EXID_forward2;
wire        ID_zero;
wire [6:0]  ID_opcode;
wire [2:0]  ID_Funct3;
reg  [1:0]  ID_NPCOp;

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
wire        EX_branch;

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

/* ******************************** Outputs ******************************** */

always @(*) begin
    PCWrite         = IF_PCWrite;
    InsMemRW        = IF_InsMemRW;
    IRWrite         = IF_IRWrite;
    RFWrite         = WB_RFWrite;
    DMCtrl          = MEM_DMCtrl;
    ExtSel          = IF_ExtSel;//ID_ExtSel;
    ALUSrcA         = EX_ALUSrcA;
    ALUSrcB         = EX_ALUSrcB;
    ALUOp           = EX_ALUOp;
    RegSel          = IF_RegSel;//WB_RegSel
    NPCOp           = EX_NPCOp;
    WDSel           = MEMStall_stall ? MEMStall_WDSel : MEM_WDSel;

    stall           = IF_stall;
    branch          = EX_branch;
    NPC_EX_Offset20 = EX_Offset20;
    NPC_EX_Offset12 = EX_Offset;
    MUX_WB_rd       = WB_rd;
    EXT_ID_Imm12    = ID_Imm12;
    forward1        = (WBID_forward1 || MEMID_forward1 || EXID_forward1);
    forward2        = (WBID_forward2 || MEMID_forward2 || EXID_forward2);
    FD1             = ID_RD1;
    FD2             = ID_RD2;
    ALU_B_Imm       = EX_Imm32;
    RF_WD           = WB_WD;
    MUX_PCA4        = MEM_PCA4;
    DM_WD           = MEM_WD;
    RF_RR1          = ID_rs1;
    RF_RR2          = ID_rs2;
end


/* ******************************** Pipeline Stages ******************************** */

/* ################################ IF ################################ */

assign NPC_NPC = NPC;

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
                    IF_ExtSel = `ExtSel_SIGNED;
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
            IF_WDSel   = `WDSel_FromPC;
        end

        // jalr
        `INSTR_JALR_OP: begin
            IF_RFWrite = 1'b1;
            IF_ExtSel  = `ExtSel_SIGNED;
            IF_ALUSrcB = `ALUSrcB_Imm;
            IF_ALUOp   = `ALUOp_ADD;
            IF_WDSel   = `WDSel_FromPC;
        end

        default: begin
            // Keep defaults.
        end
    endcase
end

// hazard detect (generate bubbles -> pipeline stalling)
assign IF_stall = (branch != 1'b1) &&
                (((ID_rs1 == EX_rd || ID_rs2 == EX_rd) && EX_RFWrite == 1'b1 && EX_rd != 5'b0 && EX_WDSel == `WDSel_FromMEM) ||
                 (ID_WDSel == `WDSel_FromMEM && ID_RFWrite == 1'b1) ||  // lw hazard
                 ((ID_rs1 == MEM_rd || ID_rs2 == MEM_rd) && MEM_DMReadStall == 1'b1) ||
                 // The synchronous DM read value becomes architecturally usable one cycle
                 // after MEM_DMReadStall. Keep dependent instructions parked until the
                 // MEMStall slot can write back / forward the load result.
                 ((ID_rs1 == MEMStall_rd || ID_rs2 == MEMStall_rd) &&
                  MEMStall_stall == 1'b1 && MEMStall_RFWrite == 1'b1 && MEMStall_rd != 5'b0));

always @(*) begin
    PC_NPC  = EX_branch ? NPC_NPC + 4 : IF_stall ? IF_PCA4 : NPC_NPC;
    NPC_PC  = EX_branch ? EX_PC : PC;
    IM_addr = IM_PC[11:2];
end

assign IM_PC   = EX_branch ? NPC_NPC : IF_stall ? IF_PC : PC;



/* ################################ ID ################################ */

// ID stage forward

// read and write RF at the same cycle
assign WBID_forward1 = (ID_rs1 == WB_rd) && (WB_RFWrite == 1'b1) && (WB_rd != 5'b0);
assign WBID_forward2 = (ID_rs2 == WB_rd) && (WB_RFWrite == 1'b1) && (WB_rd != 5'b0);

// EX to 2nd
assign MEMID_forward1 = (ID_rs1 == MEM_rd) && (MEM_RFWrite == 1'b1) && (MEM_WDSel == `WDSel_FromALU) && (MEM_rd != 5'b0);
assign MEMID_forward2 = (ID_rs2 == MEM_rd) && (MEM_RFWrite == 1'b1) && (MEM_WDSel == `WDSel_FromALU) && (MEM_rd != 5'b0);

// EX to 1st
assign EXID_forward1 = (ID_rs1 == EX_rd) && (EX_RFWrite == 1'b1) && (EX_rd != 5'b0) && (EX_WDSel == `WDSel_FromALU);
assign EXID_forward2 = (ID_rs2 == EX_rd) && (EX_RFWrite == 1'b1) && (EX_rd != 5'b0) && (EX_WDSel == `WDSel_FromALU);

// forwarding
assign ID_RD1 = EXID_forward1 ? ALU_result : (MEMID_forward1 ? ALU_result_r : (WBID_forward1 ? WB_WD : 32'h0));
assign ID_RD2 = EXID_forward2 ? ALU_result : (MEMID_forward2 ? ALU_result_r : (WBID_forward2 ? WB_WD : 32'h0));

assign ID_zero = (RD1 == RD2);

Flopr #(.WIDTH(7)) U_IFID_opcode (.clk(clk), .rst(rst), .in_data((IF_stall || EX_branch) ? 7'b0 : opcode), .out_data(ID_opcode));
Flopr #(.WIDTH(3)) U_IFID_Funct3 (.clk(clk), .rst(rst), .in_data(Funct3), .out_data(ID_Funct3));


always @(*) begin
    case (ID_opcode)
        `INSTR_BTYPE_OP: begin
            case (ID_Funct3)
                `INSTR_BEQ_FUNCT: ID_NPCOp = ID_zero ? `NPC_Offset12 : `NPC_PC; // beq
                `INSTR_BNE_FUNCT: ID_NPCOp = ID_zero ? `NPC_PC : `NPC_Offset12; // bne
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

end

Flopr #(.WIDTH(1)) U_branch (.clk(clk), .rst(rst), .in_data((IF_stall || EX_branch) ? 1'b0 : ID_NPCOp != `NPC_PC), .out_data(EX_branch));
Flopr #(.WIDTH(2)) U_NPCOp (.clk(clk), .rst(rst), .in_data((IF_stall || EX_branch) ? `NPC_PC : ID_NPCOp), .out_data(EX_NPCOp));

/* ################################ EX ################################ */

/* ################################ MEM ################################ */

assign MEM_DMReadStall = MEM_RFWrite == 1'b1 && MEM_WDSel == `WDSel_FromMEM;

/* ################################ WB ################################ */


/* #################################### pipeline #################################### */

Flopr #(.WIDTH(1))  U_IF_done (.clk(clk), .rst(rst), .in_data(1'b1), .out_data(IF_done));
Flopr #(.WIDTH(32)) U_IF_PC   (.clk(clk), .rst(rst), .in_data(IF_stall ? IF_PC : (EX_branch ? IM_PC : PC))  , .out_data(IF_PC)  );
Flopr #(.WIDTH(32)) U_IF_PCA4 (.clk(clk), .rst(rst), .in_data(IF_stall ? IF_PCA4 : (EX_branch ? NPC_NPC+4 : PCA4)), .out_data(IF_PCA4));

/* IF -> ID */

Flopr #(.WIDTH(32))  U_IFID_PCA4 (.clk(clk), .rst(rst), .in_data(IF_PCA4), .out_data(ID_PCA4));
Flopr #(.WIDTH(32))  U_IFID_PC   (.clk(clk), .rst(rst), .in_data(IF_PC) , .out_data(ID_PC)  );

Flopr #(.WIDTH(12))  U_IFID_Imm12 (.clk(clk), .rst(rst), .in_data(Imm12) , .out_data(ID_Imm12) );
Flopr #(.WIDTH(12))  U_IFID_Offet (.clk(clk), .rst(rst), .in_data(Offset), .out_data(ID_Offset));

Flopr #(.WIDTH(5) )  U_IFID_rs1 (.clk(clk), .rst(rst), .in_data(rs1), .out_data(ID_rs1));
Flopr #(.WIDTH(5) )  U_IFID_rs2 (.clk(clk), .rst(rst), .in_data(rs2), .out_data(ID_rs2));
Flopr #(.WIDTH(5) )  U_IFID_rd  (.clk(clk), .rst(rst), .in_data(rd) , .out_data(ID_rd) );

Flopr #(.WIDTH(4) )  U_IFID_ALUOp (.clk(clk), .rst(rst), .in_data(IF_ALUOp), .out_data(ID_ALUOp));

Flopr #(.WIDTH(2) )  U_IFID_Regsel  (.clk(clk), .rst(rst), .in_data(IF_RegSel) , .out_data(ID_Regsel) );
Flopr #(.WIDTH(2) )  U_IFID_ALUSrcB (.clk(clk), .rst(rst), .in_data(IF_ALUSrcB), .out_data(ID_ALUSrcB));
Flopr #(.WIDTH(2) )  U_IFID_WDSel   (.clk(clk), .rst(rst), .in_data(IF_WDSel)  , .out_data(ID_WDSel)  );

Flopr #(.WIDTH(1) )  U_IFID_ALUSrcA (.clk(clk), .rst(rst), .in_data(IF_ALUSrcA), .out_data(ID_ALUSrcA));
Flopr #(.WIDTH(1) )  U_IFID_RFWrite (.clk(clk), .rst(rst), .in_data(IF_stall || EX_branch ? 1'b0 : IF_RFWrite), .out_data(ID_RFWrite));
Flopr #(.WIDTH(1) )  U_IFID_DMCtrl  (.clk(clk), .rst(rst), .in_data(IF_stall || EX_branch ? 1'b0 : IF_DMCtrl) , .out_data(ID_DMCtrl) );

Flopr #(.WIDTH(1) )  U_IFID_done (.clk(clk), .rst(rst), .in_data(IF_stall || EX_branch ? 1'b0 : IF_done), .out_data(ID_done));

// NPC
Flopr #(.WIDTH(12))  U_IFID_Offset12 (.clk(clk), .rst(rst), .in_data(Offset), .out_data(ID_Offset12));
Flopr #(.WIDTH(20))  U_IFID_Offset20 (.clk(clk), .rst(rst), .in_data(Offset20), .out_data(ID_Offset20));

/* ID -> EX */

Flopr #(.WIDTH(32))  U_IDEX_Imm32 (.clk(clk), .rst(rst), .in_data(Imm32)  , .out_data(EX_Imm32));
Flopr #(.WIDTH(32))  U_IDEX_PCA4  (.clk(clk), .rst(rst), .in_data(ID_PCA4), .out_data(EX_PCA4) );
Flopr #(.WIDTH(32))  U_IDEX_PC    (.clk(clk), .rst(rst), .in_data(ID_PC)  , .out_data(EX_PC)   );

Flopr #(.WIDTH(12))  U_IDEX_Offset (.clk(clk), .rst(rst), .in_data(ID_Offset), .out_data(EX_Offset));

Flopr #(.WIDTH(5) )  U_IDEX_rd (.clk(clk), .rst(rst), .in_data(ID_rd), .out_data(EX_rd));

Flopr #(.WIDTH(4) )  U_IDEX_ALUOp (.clk(clk), .rst(rst), .in_data(ID_ALUOp), .out_data(EX_ALUOp));

Flopr #(.WIDTH(2) )  U_IDEX_Regsel  (.clk(clk), .rst(rst), .in_data(ID_Regsel) , .out_data(EX_Regsel) );
Flopr #(.WIDTH(2) )  U_IDEX_ALUSrcB (.clk(clk), .rst(rst), .in_data(ID_ALUSrcB), .out_data(EX_ALUSrcB));
Flopr #(.WIDTH(2) )  U_IDEX_WDSel   (.clk(clk), .rst(rst), .in_data(ID_WDSel)  , .out_data(EX_WDSel)  );

Flopr #(.WIDTH(1) )  U_IDEX_ALUSrcA (.clk(clk), .rst(rst), .in_data(ID_ALUSrcA), .out_data(EX_ALUSrcA));
Flopr #(.WIDTH(1) )  U_IDEX_RFWrite (.clk(clk), .rst(rst), .in_data(EX_branch ? 1'b0 : ID_RFWrite), .out_data(EX_RFWrite));
Flopr #(.WIDTH(1) )  U_IDEX_DMCtrl  (.clk(clk), .rst(rst), .in_data(EX_branch ? 1'b0 : ID_DMCtrl) , .out_data(EX_DMCtrl) );

Flopr #(.WIDTH(20))  U_IDEX_Offset20 (.clk(clk), .rst(rst), .in_data(ID_Offset20), .out_data(EX_Offset20));

Flopr #(.WIDTH(1) )  U_IDEX_done (.clk(clk), .rst(rst), .in_data(EX_branch ? 1'b0 : ID_done), .out_data(EX_done));

/* EX -> MEM */

Flopr #(.WIDTH(32)) U_EXMEM_WD   (.clk(clk), .rst(rst), .in_data(RD2_r)  , .out_data(MEM_WD)  );
Flopr #(.WIDTH(32)) U_EXMEM_PCA4 (.clk(clk), .rst(rst), .in_data(EX_PCA4), .out_data(MEM_PCA4));

Flopr #(.WIDTH(5))  U_EXMEM_rd    (.clk(clk), .rst(rst), .in_data(EX_rd)   , .out_data(MEM_rd)   );

Flopr #(.WIDTH(2))  U_EXMEM_WDSel (.clk(clk), .rst(rst), .in_data(EX_WDSel), .out_data(MEM_WDSel));

Flopr #(.WIDTH(1))  U_EXMEM_RFWrite (.clk(clk), .rst(rst), .in_data(EX_RFWrite), .out_data(MEM_RFWrite));
Flopr #(.WIDTH(1))  U_EXMEM_DMCtrl  (.clk(clk), .rst(rst), .in_data(EX_DMCtrl) , .out_data(MEM_DMCtrl) );

Flopr #(.WIDTH(1))  U_EXMEM (.clk(clk), .rst(rst), .in_data(EX_done), .out_data(MEM_done));

/* MEM -> WB */

Flopr #(.WIDTH(32)) U_MEMWB_WD (.clk(clk), .rst(rst), .in_data(WD), .out_data(WB_WD));

Flopr #(.WIDTH(5) ) U_MEMWB_rd (.clk(clk), .rst(rst), .in_data(MEMStall_stall ? MEMStall_rd : MEM_rd), .out_data(WB_rd));

Flopr #(.WIDTH(1) ) U_MEMWB_RFWrite (.clk(clk), .rst(rst), .in_data(MEM_DMReadStall ? 1'b0 : MEMStall_stall ? MEMStall_RFWrite : MEM_RFWrite), .out_data(WB_RFWrite));

Flopr #(.WIDTH(1) ) U_MEMWB_done (.clk(clk), .rst(rst), .in_data(MEM_DMReadStall ? 1'b0 : MEMStall_stall ? MEMStall_done : MEM_done), .out_data(WB_done));

/* MEM stall for MEM read (lw) */

Flopr #(.WIDTH(5) ) U_MEMstall_rd      (.clk(clk), .rst(rst), .in_data(MEM_DMReadStall ? MEM_rd      : 5'b0), .out_data(MEMStall_rd)     );
Flopr #(.WIDTH(2) ) U_MEMstall_WDSel   (.clk(clk), .rst(rst), .in_data(MEM_DMReadStall ? MEM_WDSel   : 2'b0), .out_data(MEMStall_WDSel)  );
Flopr #(.WIDTH(1) ) U_MEMstall_RFWrite (.clk(clk), .rst(rst), .in_data(MEM_DMReadStall ? MEM_RFWrite : 1'b0), .out_data(MEMStall_RFWrite));
Flopr #(.WIDTH(1) ) U_MEMstall_done    (.clk(clk), .rst(rst), .in_data(MEM_DMReadStall ? MEM_done    : 1'b0), .out_data(MEMStall_done)   );

Flopr #(.WIDTH(1) ) U_MEMstall_stall   (.clk(clk), .rst(rst), .in_data(MEM_DMReadStall), .out_data(MEMStall_stall));

`ifdef DIFFTEST

wire [31:0] ID_dnpc, EX_dnpc, MEM_dnpc, MEMStall_dnpc, WB_dnpc, dnpc;

Flopr #(.WIDTH(32)) U_IFID_dnpc     (.clk(clk), .rst(rst), .in_data(IF_PCA4)                                  , .out_data(ID_dnpc)      );
Flopr #(.WIDTH(32)) U_IDEX_dnpc     (.clk(clk), .rst(rst), .in_data(ID_dnpc)                                  , .out_data(EX_dnpc)      );
Flopr #(.WIDTH(32)) U_EXMEM_dnpc    (.clk(clk), .rst(rst), .in_data(EX_branch ? NPC_NPC : EX_dnpc)            , .out_data(MEM_dnpc)     );
Flopr #(.WIDTH(32)) U_MEMstall_dnpc (.clk(clk), .rst(rst), .in_data(MEM_dnpc)                                 , .out_data(MEMStall_dnpc));
Flopr #(.WIDTH(32)) U_MEMWB_dnpc    (.clk(clk), .rst(rst), .in_data(MEMStall_stall ? MEMStall_dnpc : MEM_dnpc), .out_data(WB_dnpc)      );
Flopr #(.WIDTH(32)) U_WB_dnpc       (.clk(clk), .rst(rst), .in_data(WB_dnpc)                                  , .out_data(dnpc)         );

export "DPI-C" function DPI_getPC;
function int DPI_getPC();
    return dnpc;
endfunction

`endif


endmodule
