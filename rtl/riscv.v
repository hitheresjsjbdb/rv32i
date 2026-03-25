`timescale 1ns / 1ps
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
module riscv(clk, rst);
input clk, rst;

wire RFWrite, DMACtrl, PCWrite, IRWrite, InsMemRW, ExtSel, zero, ALUSrcA;
wire [1:0] ALUSrcB;
wire [1:0] NPCop, WDSel, RegSel;
wire [3:0] ALUOp;
wire [2:0] Funct3;
wire [6:0] Funct7;
wire [6:0] Opcode;
wire [31:0] PC, NPC, PC4, PCA4;
wire [31:0] in_ins, out_ins, RD, DR_out;
wire [31:0] rs1, rs2, rd;
wire [11:0] Imm12;
wire [31:0] Imm32;
wire [20:1] Offset20;
wire [11:0] Offset;
wire [4:0] WR;
wire [31:0] RD1, RD1_r, RD2, RD2_r;
wire [31:0] A, B, ALU_result, ALU_result_r;

assign opcode   = out_ins[6:0];
assign Funct3   = out_ins[14:12];
assign Funct7   = out_ins[31:25];
assign rs1      = out_ins[19:15];
assign rs2      = out_ins[24:20];
assign rd       = out_ins[11:7];
assign Imm12    = out_ins[31:20];
assign Offset20 = (out_ins[6:0] == `INSTR_BTYPE_OP) ? {out_ins[31], out_ins[7], out_ins[30:25], out_ins[11:8]} :
                  (opcode == `INSTR_SW_OP)        ? {out_ins[31:25], out_ins[11:7]} : Imm12;
assign Offset   = (opcode == `INSTR_J_TYPE) ? {out_ins[31], out_ins[19:12], out_ins[20], out_ins[30:21]} : 12'b0;

// ControlUnit
ControlUnit U_ControlUnit(
    .clk(clk), .rst(rst), .zero(zero), .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3),
    .RFWrite(RFWrite), .DMACtrl(DMACtrl), .PCWrite(PCWrite), .IRWrite(IRWrite), .InsMemRW(InsMemRW),
    .ExtSel(ExtSel), .ALUOp(ALUOp), .NPCop(NPCop), .ALUSrcA(ALUSrcA),
    .WDSel(WDSel), .ALUSrcB(ALUSrcB), .RegSel(RegSel)
);

// PC
PC U_PC(
    .clk(clk), .rst(rst), .PCWrite(PCWrite), .NPC(NPC), .PC(PC)
);

// NPC
NPC U_NPC(
    .PC(PC), .NPCop(NPCop), .Offset12(Offset), .Offset20(Offset20), .rs(RD1[31:2]), .PCA4(PCA4), .NPC(NPC)
);

// IM
IM U_IM(
    .addr(PC[11:2]), .in_ins(in_ins), .InsMemRW(InsMemRW)
);

// IR
IR U_IR(
    .clk(clk), .IRWrite(IRWrite), .in_ins(in_ins), .out_ins(out_ins)
);

// È¡ÃüÁî RF
RF U_RF (
    .RR1(rs1), .RR2(rs2), .WR(WR), .WD(WD), .clk(clk),
    .RFWrite(RFWrite), .RD1(RD1), .RD2(RD2)
);

// È¡ÃüÁî MUX_3to1
MUX_3to1 U_MUX_3to1 (
    .X(rd), .Y(5'd0), .Z(5'd31),
    .control(RegSel), .out(WR)
);

// È¡ÃüÁî MUX_3to1_LMD
MUX_3to1_LMD U_MUX_3to1_LMD (
    .X(ALU_result_r), .Y(DR_out), .Z(PCA4),
    .control(WDSel), .out(WD)
);

// È¡ÃüÁî Flopr
Flopr U_A (
    .clk(clk), .rst(rst), .in_data(RD1), .out_data(RD1_r)
);

// È¡ÃüÁî Flopr
Flopr U_B (
    .clk(clk), .rst(rst), .in_data(RD2), .out_data(RD2_r)
);

// È¡ÃüÁî EXT
EXT U_EXT (
    .imm_in(Imm12), .ExtSel(ExtSel), .imm_out(Imm32)
);

// È¡ÃüÁî MUX_2to1_A
MUX_2to1_A U_MUX_2to1_A (
    .X(RD1_r), .Y(32'h0), .control(ALUSrcA), .out(A)
);

// È¡ÃüÁî MUX_2to1_B
MUX_3to1_B U_MUX_3to1_B (
    .X(RD2_r), .Y(Imm32), .Z(Offset), .control(ALUSrcB), .out(B)
);

// È¡ÃüÁî ALU
ALU U_ALU (
    .A(A), .B(B), .ALUOp(ALUOp), .ALU_result(ALU_result), .zero(zero)
);

// È¡ÃüÁî Flopr
Flopr U_ALUOut (
    .clk(clk), .rst(rst), .in_data(ALU_result), .out_data(ALU_result_r)
);

// È¡ÃüÁî DM
DM U_DM (
    .Addr(ALU_result_r[11:2]), .WD(RD2_r), .DMACtrl(DMACtrl), .clk(clk), .RD(RD)
);

//// È¡ÃüÁî Flopr
//Flopr U_DR (
//    .clk(clk), .rst(rst), .in_data(RD), .out_data(DR_out)
//);

assign DR_out = RD;

endmodule