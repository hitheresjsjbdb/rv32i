`timescale 1ns / 1ps
`include "global_def.v"

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
module riscv(clk, rst
`ifdef DIFFTEST
, done
`endif
);
input clk, rst;

`ifdef DIFFTEST
output done;
`endif

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

/* new wires */
wire stall;
wire branch;
wire [31:0] PC_NPC, NPC_PC;
wire [19:0] NPC_EX_Offset20;
wire [11:0] NPC_EX_Offset12;
wire [9:0]  IM_addr;
wire [11:0] EXT_Imm12;
wire [4:0]  MUX_rd;
wire forward1, forward2;
wire [31:0] FD1, FD2;
wire [31:0] ALU_B_Imm32;
wire [31:0] RF_WD;
wire [31:0] MUX_PCA4;
wire [31:0] DM_WD;
wire [4:0]  RF_RR1, RF_RR2;

assign opcode  = out_ins[6:0];
assign Funct3  = out_ins[14:12];
assign Funct7  = out_ins[31:25];
assign rs1     = out_ins[19:15];
assign rs2     = out_ins[24:20];
assign rd      = out_ins[11:7];
assign Imm12   = out_ins[31:20];
assign Offset20 = {out_ins[31],out_ins[19:12],out_ins[20],out_ins[30:21]};
assign Offset  = (opcode == `INSTR_BTYPE_OP) ? {out_ins[31],out_ins[7],out_ins[30:25],out_ins[11:8]} :
                 (opcode == `INSTR_SW_OP)  ? {out_ins[31:25],out_ins[11:7]} : Imm12;

// ÊuÀý»- ControlUnit
ControlUnit U_ControlUnit(
    .clk(clk), .rst(rst), .zero(zero), .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3),
    .RFWrite(RFWrite), .DMCtrl(DMCtrl), .PCWrite(PCWrite), .IRWrite(IRWrite), .InsMemRW(InsMemRW),
    .ExtSel(ExtSel), .ALUOp(ALUOp), .NPCOp(NPCOp), .ALUSrcA(ALUSrcA),
    .WDSel(WDSel), .ALUSrcB(ALUSrcB), .RegSel(RegSel),

    /* new inputs */
    // decode signals
    .rs1(rs1), .rs2(rs2), .rd(rd), .Imm12(Imm12), .Offset(Offset),
    .Offset20(Offset20),
    // from PC
    .PC(PC), .PCA4(PCA4),
    // from NPC
    .NPC(NPC),
    // from RF
    .RD1(RD1), .RD2(RD2),
    // from EXT
    .Imm32(Imm32),
    // from ALU
    .ALU_result(ALU_result), .ALU_result_r(ALU_result_r),
    // from MUX_3to1_LMD
    .WD(WD),
    // from Flopr_B
    .RD2_r(RD2_r),

    /* new outputs */
    // control signals
    .stall(stall), .branch(branch),
    // to PC
    .PC_NPC(PC_NPC),
    // to NPC
    .NPC_PC(NPC_PC), .NPC_EX_Offset12(NPC_EX_Offset12), .NPC_EX_Offset20(NPC_EX_Offset20),
    // to IM
    .IM_addr(IM_addr),
    // to EXT
    .EXT_ID_Imm12(EXT_Imm12),
    // to MUX_3to1
    .MUX_WB_rd(MUX_rd),
    // to RF
    .forward1(forward1), .forward2(forward2), .FD1(FD1), .FD2(FD2), .RF_WD(RF_WD), .RF_RR1(RF_RR1), .RF_RR2(RF_RR2),
    // to MUX_3to1_B
    .ALU_B_Imm(ALU_B_Imm32),
    // to MUX_3to1_LMD
    .MUX_PCA4(MUX_PCA4),
    // to DM
    .DM_WD(DM_WD)


`ifdef DIFFTEST
    , .done(done)
`endif


);

// ÊuÀý»- PC
PC U_PC (
    .clk(clk), .rst(rst), .PCWrite(PCWrite), .NPC(NPC), .PC(PC),

    /* new inputs */
    .stall(stall), .branch(branch), .PC_NPC(PC_NPC)
);

// ÊuÀý»- NPC
NPC U_NPC (
    .PC(PC), .NPCOp(NPCOp), .Offset12(Offset), .Offset20(Offset20), .rs(RD1), .PCA4(PCA4), .NPC(NPC),

    /* new inputs */
    .NPC_PC(NPC_PC), .NPC_Offset12(NPC_EX_Offset12), .NPC_Offset20(NPC_EX_Offset20), .NPC_rs(RD1_r)
);

// ÊuÀý»- IM
IM U_IM (
    .addr(PC[11:2]), .Ins(in_ins), .InsMemRW(InsMemRW),

    /* new inputs */
    .clk(clk), .rst(rst), .IM_addr(IM_addr), .branch(branch)
);

// ÊuÀý»- IR
IR U_IR (
    .IRWrite(IRWrite), .in_ins(in_ins), .out_ins(out_ins)
);

// ÊuÀý»- RF
RF U_RF (
    .RR1(rs1), .RR2(rs2), .WR(WR), .WD(WD), .clk(clk),
    .RFWrite(RFWrite), .RD1(RD1), .RD2(RD2),

    /* new inputs */
    .RF_RR1(RF_RR1), .RF_RR2(RF_RR2),
    .forward1(forward1), .forward2(forward2),
    .FD1(FD1), .FD2(FD2),
    .RF_WD(RF_WD)
);

// ÊuÀý»- MUX_3to1
MUX_3to1 U_MUX_3to1 (
    .X(rd), .Y(5'd0), .Z(5'd31), .rd(MUX_rd),
    .control(RegSel), .out(WR)
);

// ÊuÀý»- MUX_3to1_LMD
MUX_3to1_LMD U_MUX_3to1_LMD (
    .X(ALU_result_r), .Y(DR_out), .Z(PCA4),
    .control(WDSel), .out(WD),

    /* new inputs */
    .PCA4(MUX_PCA4)
);

// ÊuÀý»- Flopr
Flopr U_A (
    .clk(clk), .rst(rst), .in_data(RD1), .out_data(RD1_r)
);

// ÊuÀý»- Flopr
Flopr U_B (
    .clk(clk), .rst(rst), .in_data(RD2), .out_data(RD2_r)
);

// ÊuÀý»- EXT
EXT U_EXT (
    .imm_in(Imm12), .ExtSel(ExtSel), .imm_out(Imm32),

    /* new input */
    .EXT_Imm12(EXT_Imm12)
);

// ÊuÀý»- MUX_2to1_A
MUX_2to1_A U_MUX_2to1_A (
    .X(RD1_r), .Y(5'h0), .control(ALUSrcA), .out(A)
);

// ÊuÀý»- MUX_2to1_B
MUX_3to1_B U_MUX_3to1_B (
    .X(RD2_r), .Y(Imm32), .Z(Offset), .control(ALUSrcB), .out(B),

    /* new inputs */
    .Imm(ALU_B_Imm32), .Offset(NPC_EX_Offset12)
);

// ÊuÀý»- ALU
ALU U_ALU (
    .A(A), .B(B), .ALUOp(ALUOp), .ALU_result(ALU_result), .zero(zero)
);

// ÊuÀý»- Flopr
Flopr U_ALUOut (
    .clk(clk), .rst(rst), .in_data(ALU_result), .out_data(ALU_result_r)
);

// ÊuÀý»- DM
DM U_DM (
    .Addr(ALU_result_r[11:2]), .WD(RD2_r), .DMCtrl(DMCtrl), .clk(clk), .RD(RD),

    /* new inputs */
    .DM_WD(DM_WD)
);

//// ÊuÀý»- Flopr
//Flopr U_DR (
//    .clk(clk), .rst(rst), .in_data(RD), .out_data(DR_out)
//);

assign DR_out = RD;


endmodule