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

// ÊuÀý»- ControlUnit
ControlUnit U_ControlUnit(
    .clk(clk), .rst(rst), .zero(zero), .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3),
    .RFWrite(RFWrite), .DMCtrl(DMCtrl), .PCWrite(PCWrite), .IRWrite(IRWrite), .InsMemRW(InsMemRW),
    .ExtSel(ExtSel), .ALUOp(ALUOp), .NPCOp(NPCOp), .ALUSrcA(ALUSrcA),
    .WDSel(WDSel), .ALUSrcB(ALUSrcB), .RegSel(RegSel), .done(done)
);

// ÊuÀý»- PC
PC U_PC (
    .clk(clk), .rst(rst), .PCWrite(PCWrite), .NPC(NPC), .PC(PC)
);

// ÊuÀý»- NPC
NPC U_NPC (
    .PC(PC), .NPCOp(NPCOp), .Offset12(Offset), .Offset20(Offset20), .rs({RD1[31:2], 2'b00}), .PCA4(PCA4), .NPC(NPC)
);

// ÊuÀý»- IM
IM U_IM (
    .addr(PC[11:2]), .Ins(in_ins), .InsMemRW(InsMemRW)
);

// ÊuÀý»- IR
IR U_IR (
    .clk(clk), .IRWrite(IRWrite), .in_ins(in_ins), .out_ins(out_ins)
);

// ÊuÀý»- RF
RF U_RF (
    .RR1(rs1), .RR2(rs2), .WR(WR), .WD(WD), .clk(clk),
    .RFWrite(RFWrite), .RD1(RD1), .RD2(RD2)
);

// ÊuÀý»- MUX_3to1
MUX_3to1 U_MUX_3to1 (
    .X(rd), .Y(5'd0), .Z(5'd31),
    .control(RegSel), .out(WR)
);

// ÊuÀý»- MUX_3to1_LMD
MUX_3to1_LMD U_MUX_3to1_LMD (
    .X(ALU_result_r), .Y(DR_out), .Z(PCA4),
    .control(WDSel), .out(WD)
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
    .imm_in(Imm12), .ExtSel(ExtSel), .imm_out(Imm32)
);

// ÊuÀý»- MUX_2to1_A
MUX_2to1_A U_MUX_2to1_A (
    .X(RD1), .Y(5'h0), .control(ALUSrcA), .out(A)
);

// ÊuÀý»- MUX_2to1_B
MUX_3to1_B U_MUX_3to1_B (
    .X(RD2), .Y(Imm32), .Z(Offset), .control(ALUSrcB), .out(B)
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
    .Addr(ALU_result_r[11:2]), .WD(RD2), .DMCtrl(DMCtrl), .clk(clk), .RD(RD)
);

//// ÊuÀý»- Flopr
//Flopr U_DR (
//    .clk(clk), .rst(rst), .in_data(RD), .out_data(DR_out)
//);

assign DR_out = RD;
endmodule