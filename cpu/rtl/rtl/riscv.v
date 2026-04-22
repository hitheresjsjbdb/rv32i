`timescale 1ns / 1ps
`include "instruction_def.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/22 13:30:25
// Design Name: 
// Module Name: riscv
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
module riscv(clk, rst, done);
input clk, rst;
output done;

wire RFWrite, DMCtrl, PCWrite, IRWrite, InsMemRW, ExtSel, zero, ALUSrcA;
wire [1:0] ALUSrcB;
wire [1:0] NPCOp, WDSel, RegSel;
wire [3:0] ALUOp;
wire [6:0] opcode;
wire [2:0] Funct3;
wire [6:0] Funct7;
wire [31:0] PC, NPC, PCA4;
wire [31:0] in_ins, out_ins, RD, DR_out;
wire [4:0] rs1, rs2, rd;
wire [11:0] Imm12;
wire [31:0] Imm32;
wire [20:1] Offset20;
wire [11:0] Offset;
wire [4:0] WR;
wire [31:0] WD;
wire [31:0] RD1, RD1_r, RD2, RD2_r;
wire [31:0] A, B, ALU_result, ALU_result_r;



/* #################################### pipeline signals #################################### */

/* IF */

wire        IF_done;
wire        IF_bubble;
wire [9:0]  IM_addr;
wire [31:0] IF_PC, IF_PCA4;
wire [31:0] PC_NPC, NPC_NPC, NPC_PC;
//default

/* ID */
wire [31:0] ID_PCA4, ID_RD1, ID_RD2, ID_PC;
wire [11:0] ID_Imm12, ID_Offset;
wire [4:0]  ID_rs1, ID_rs2, ID_rd;
wire [3:0]  ID_ALUOp;
wire [1:0]  ID_Regsel, ID_ALUSrcB, ID_WDSel, ID_NPCOp;
wire        ID_ALUSrcA, ID_RFWrite, ID_DMCtrl;
wire        ID_done;
wire        WBID_forward1, WBID_forward2;
wire        MEMID_forward1, MEMID_forward2;
wire        ID_branch;

wire [11:0] ID_Offset12;
wire [19:0] ID_Offset20;

/* EX */
wire [31:0] EX_Imm32, EX_PCA4;
wire [11:0] EX_Offset;
wire [3:0]  EX_ALUOp;
wire [4:0]  EX_rd;
wire [1:0]  EX_Regsel, EX_ALUSrcB, EX_WDSel;
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

wire cu_zero;



// ÊuÀý»- ControlUnit
ControlUnit U_ControlUnit(
    /* input */
    .clk(clk), .rst(rst), .zero(cu_zero), .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3),

    /* output */
    .RFWrite(RFWrite), .DMCtrl(DMCtrl), .PCWrite(PCWrite), .IRWrite(IRWrite), .InsMemRW(InsMemRW),
    .ExtSel(ExtSel), .ALUOp(ALUOp), .NPCOp(NPCOp), .ALUSrcA(ALUSrcA),
    .WDSel(WDSel), .ALUSrcB(ALUSrcB), .RegSel(RegSel), /*.done(done)*/

    .branch(ID_branch), .ID_NPCOp(ID_NPCOp)
);

/* ******************************** Pipeline Stages ******************************** */

/* ################################ IF ################################ */

Reg #(1)  U_IF_done (clk, rst, 1'b1, 1'b1, IF_done);
Reg #(32) U_IF_PC   (clk, rst, ~IF_bubble, PC  , IF_PC  );
Reg #(32) U_IF_PCA4 (clk, rst, ~IF_bubble, PCA4, IF_PCA4);

// hazard detect (generate bubbles)
assign IF_bubble = ((rs1 == EX_rd || rs2 == EX_rd) && EX_RFWrite == 1'b1 && EX_rd != 5'b0) ||
                   ((rs1 == ID_rd || rs2 == ID_rd) && ID_RFWrite == 1'b1 && ID_rd != 5'b0) ||
                   (ID_WDSel == `WDSel_FromMEM && ID_RFWrite == 1'b1) ||
                   ((rs1 == MEM_rd || rs2 == MEM_rd) && MEM_DMReadStall == 1'b1);

assign PC_NPC  = ID_branch ? NPC_NPC + 4 : IF_bubble ? IF_PCA4 : NPC_NPC;
assign IM_addr = ID_branch ? NPC_NPC[11:2] : IF_bubble ? IF_PC[11:2] : PC[11:2];
assign NPC_PC  = ID_branch ? ID_PC : PC;

// ÊuÀý»- PC
PC U_PC (
    .clk(clk), .rst(rst), .PCWrite(PCWrite), .NPC(PC_NPC), .PC(PC)
);

// ÊuÀý»- NPC
NPC U_NPC (
    .PC(NPC_PC), .NPCOp(ID_NPCOp), .Offset12(ID_Offset), .Offset20(ID_Offset20), .rs({RD1[31:2], 2'b00}), .PCA4(PCA4), .NPC(NPC_NPC)
);

// ÊuÀý»- IM
IM U_IM (
    .clk(clk), .addr(IM_addr), .Ins(in_ins), .InsMemRW(InsMemRW), .rst(rst)
);

// ÊuÀý»- IR
IR U_IR (
    .IRWrite(IRWrite), .in_ins(in_ins), .out_ins(out_ins)
);

assign opcode  = out_ins[6:0];
assign Funct3  = out_ins[14:12];
assign Funct7  = out_ins[31:25];
assign rs1     = out_ins[19:15];
assign rs2     = out_ins[24:20];
assign rd      = out_ins[11:7];
assign Imm12   = out_ins[31:20];    // I-type
assign Offset20 = {out_ins[31],out_ins[19:12],out_ins[20],out_ins[30:21]};  // J-type
assign Offset  = (opcode == `INSTR_BTYPE_OP) ? {out_ins[31],out_ins[7],out_ins[30:25],out_ins[11:8]} :  // B-type
                 (opcode == `INSTR_SW_OP)  ? {out_ins[31:25],out_ins[11:7]} : Imm12;    // S-type


/* ################################ ID ################################ */

// ÊuÀý»- RF
RF U_RF (
    .RR1(ID_rs1), .RR2(ID_rs2), .WR(WR), .WD(WB_WD), .clk(clk),
    .RFWrite(WB_RFWrite), .RD1(RD1), .RD2(RD2)
);

// ÊuÀý»- MUX_3to1
MUX_3to1 U_MUX_3to1 (
    .X(WB_rd), .Y(5'd0), .Z(5'd31),
    .control(`RegSel_rd), .out(WR)
);

// ÊuÀý»- EXT
EXT U_EXT (
    .imm_in(ID_Imm12), .ExtSel(`ExtSel_SIGNED), .imm_out(Imm32)
);

// ÊuÀý»- Flopr
Flopr U_A (
    .clk(clk), .rst(rst), .in_data(ID_RD1), .out_data(RD1_r)
);

// ÊuÀý»- Flopr
Flopr U_B (
    .clk(clk), .rst(rst), .in_data(ID_RD2), .out_data(RD2_r)
);

// forward (in case RF read and write at the same cycle)
assign WBID_forward1  = ID_rs1 == WB_rd && WB_RFWrite == 1 && WB_rd != 0;
assign WBID_forward2  = ID_rs2 == WB_rd && WB_RFWrite == 1 && WB_rd != 0;

// forward (in case EX to 2nd)
assign MEMID_forward1 = ID_rs1 == MEM_rd && MEM_RFWrite == 1 && MEM_rd != 0;
assign MEMID_forward2 = ID_rs2 == MEM_rd && MEM_RFWrite == 1 && MEM_rd != 0;

assign ID_RD1 = WBID_forward1 ? WB_WD : RD1;
assign ID_RD2 = WBID_forward2 ? WB_WD : RD2;

assign cu_zero = ID_RD1 == ID_RD2;

/* ################################ EX ################################ */

// ÊuÀý»- MUX_2to1_A
MUX_2to1_A U_MUX_2to1_A (
    .X(RD1_r), .Y(5'h0), .control(EX_ALUSrcA), .out(A)
);

// ÊuÀý»- MUX_2to1_B
MUX_3to1_B U_MUX_3to1_B (
    .X(RD2_r), .Y(EX_Imm32), .Z(EX_Offset), .control(EX_ALUSrcB), .out(B)
);

// ÊuÀý»- ALU
ALU U_ALU (
    .A(A), .B(B), .ALUOp(EX_ALUOp), .ALU_result(ALU_result), .zero(zero)
);

// ÊuÀý»- Flopr
Flopr U_ALUOut (
    .clk(clk), .rst(rst), .in_data(ALU_result), .out_data(ALU_result_r)
);


/* ################################ MEM ################################ */

// ÊuÀý»- MUX_3to1_LMD
MUX_3to1_LMD U_MUX_3to1_LMD (
    .X(ALU_result_r), .Y(DR_out), .Z(MEM_PCA4),
    .control(MEMStall_stall ? MEMStall_WDSel : MEM_WDSel), .out(WD)
);


// ÊuÀý»- DM
DM U_DM (
    .Addr(ALU_result_r[11:2]), .WD(MEM_WD), .DMCtrl(MEM_DMCtrl), .clk(clk), .RD(RD)
);

assign MEM_DMReadStall = MEM_RFWrite == 1'b1 && MEM_WDSel == `WDSel_FromMEM;

/* ################################ WB ################################ */

assign DR_out = RD;
Reg #(1) U_done (clk, rst, 1'b1, WB_done, done);


/* #################################### pipeline #################################### */

/* IF -> ID */

Reg #(32) U_IFID_PCA4 (clk, rst, 1'b1, IF_PCA4, ID_PCA4);
Reg #(32) I_IFID_PC   (clk, rst, 1'b1, IF_PC  , ID_PC  );

Reg #(12) U_IFID_Imm12 (clk, rst, 1'b1, Imm12 , ID_Imm12 );
Reg #(12) U_IFID_Offet (clk, rst, 1'b1, Offset, ID_Offset);

Reg #(5)  U_IFID_rs1 (clk, rst, 1'b1, rs1, ID_rs1);
Reg #(5)  U_IFID_rs2 (clk, rst, 1'b1, rs2, ID_rs2);
Reg #(5)  U_IFID_rd  (clk, rst, 1'b1, rd , ID_rd );

Reg #(4)  U_IFID_ALUOp (clk, rst, 1'b1, ALUOp, ID_ALUOp);

Reg #(2)  U_IFID_Regsel  (clk, rst, 1'b1, RegSel , ID_Regsel );
Reg #(2)  U_IFID_ALUSrcB (clk, rst, 1'b1, ALUSrcB, ID_ALUSrcB);
Reg #(2)  U_IFID_WDSel   (clk, rst, 1'b1, WDSel  , ID_WDSel  );

Reg #(1)  U_IFID_ALUSrcA (clk, rst, 1'b1, ALUSrcA, ID_ALUSrcA);
Reg #(1)  U_IFID_RFWrite (clk, rst, 1'b1, IF_bubble || ID_branch ? 1'b0 : RFWrite, ID_RFWrite);
Reg #(1)  U_IFID_DMCtrl  (clk, rst, 1'b1, IF_bubble || ID_branch ? 1'b0 : DMCtrl , ID_DMCtrl );

Reg #(1)  U_IFID_done (clk, rst, 1'b1, IF_bubble || ID_branch ? 1'b0 : IF_done, ID_done);

// NPC
Reg #(12) U_IFNPC_Offset12 (clk, rst, 1'b1, Offset, ID_Offset12);
Reg #(20) U_IFNPC_Offset20 (clk, rst, 1'b1, Offset20, ID_Offset20);

/* ID -> EX */

Reg #(32) U_IDEX_Imm32 (clk, rst, 1'b1, Imm32  , EX_Imm32);
Reg #(32) U_IDEX_PCA4  (clk, rst, 1'b1, ID_PCA4, EX_PCA4 );

Reg #(12) U_IDEX_Offset (clk, rst, 1'b1, ID_Offset, EX_Offset);

Reg #(5)  U_IDEX_rd (clk, rst, 1'b1, ID_rd, EX_rd);

Reg #(4)  U_IDEX_ALUOp (clk, rst, 1'b1, ID_ALUOp, EX_ALUOp);

Reg #(2)  U_IDEX_Regsel  (clk, rst, 1'b1, ID_Regsel , EX_Regsel );
Reg #(2)  U_IDEX_ALUSrcB (clk, rst, 1'b1, ID_ALUSrcB, EX_ALUSrcB);
Reg #(2)  U_IDEX_WDSel   (clk, rst, 1'b1, ID_WDSel  , EX_WDSel  );

Reg #(1)  U_IDEX_ALUSrcA (clk, rst, 1'b1, ID_ALUSrcA, EX_ALUSrcA);
Reg #(1)  U_IDEX_RFWrite (clk, rst, 1'b1, ID_RFWrite, EX_RFWrite);
Reg #(1)  U_IDEX_DMCtrl  (clk, rst, 1'b1, ID_DMCtrl , EX_DMCtrl );

Reg #(1)  U_IDEX_done (clk, rst, 1'b1, ID_done, EX_done);

/* EX -> MEM */

Reg #(32) U_EXMEM_WD   (clk, rst, 1'b1, RD2_r  , MEM_WD  );
Reg #(32) U_EXMEM_PCA4 (clk, rst, 1'b1, EX_PCA4, MEM_PCA4);

Reg #(5)  U_EXMEM_rd    (clk, rst, 1'b1, EX_rd   , MEM_rd   );

Reg #(2)  U_EXMEM_WDSel (clk, rst, 1'b1, EX_WDSel, MEM_WDSel);

Reg #(1)  U_EXMEM_RFWrite (clk, rst, 1'b1, EX_RFWrite, MEM_RFWrite);
Reg #(1)  U_EXMEM_DMCtrl  (clk, rst, 1'b1, EX_DMCtrl , MEM_DMCtrl );

Reg #(1)  U_EXMEM (clk, rst, 1'b1, EX_done, MEM_done);

/* MEM -> WB */

Reg #(32) U_MEMWB_WD (clk, rst, 1'b1, WD, WB_WD);

Reg #(5)  U_MEMWB_rd (clk, rst, 1'b1, MEMStall_stall ? MEMStall_rd : MEM_rd, WB_rd);

Reg #(1)  U_MEMWB_RFWrite (clk, rst, 1'b1, MEM_DMReadStall ? 1'b0 : MEMStall_stall ? MEMStall_RFWrite : MEM_RFWrite, WB_RFWrite);

Reg #(1)  U_MEMWB_done (clk, rst, 1'b1, MEM_DMReadStall ? 1'b0 : MEMStall_stall ? MEMStall_done : MEM_done, WB_done);

/* MEM stall for MEM read (lw) */

Reg #(5)  U_MEMstall_rd      (clk, rst, 1'b1, MEM_DMReadStall ? MEM_rd      : 5'b0, MEMStall_rd     );
Reg #(2)  U_MEMstall_WDSel   (clk, rst, 1'b1, MEM_DMReadStall ? MEM_WDSel   : 2'b0, MEMStall_WDSel  );
Reg #(1)  U_MEMstall_RFWrite (clk, rst, 1'b1, MEM_DMReadStall ? MEM_RFWrite : 1'b0, MEMStall_RFWrite);
Reg #(1)  U_MEMstall_done    (clk, rst, 1'b1, MEM_DMReadStall ? MEM_done    : 1'b0, MEMStall_done   );

Reg #(1)  U_MEMstall_stall   (clk, rst, 1'b1, MEM_DMReadStall, MEMStall_stall);


endmodule