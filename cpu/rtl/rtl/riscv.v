`timescale 1ns / 1ps
`include "ctrl_signal_def.v"
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
wire [1:0] NPCop, WDSel, RegSel;
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

wire IF_bubble, MEM_DMReadStall, MEMStall_stall, WB_RFWrite, EX_branch, ID_zero;
wire MEM_DMCtrl;
wire ID_ALUSrcA, ID_RFWrite, ID_DMCtrl, ID_done;
wire EX_ALUSrcA, EX_RFWrite, EX_DMCtrl, EX_done;
wire [9:0] IM_addr;
wire [1:0] ID_ALUSrcB, ID_WDSel, ID_RegSel;
wire [1:0] EX_ALUSrcB, EX_WDSel, EX_RegSel, EX_NPCOp;
wire [1:0] MEM_WDSel, MEMStall_WDSel;
wire [3:0] ID_ALUOp, EX_ALUOp;
wire [4:0] ID_rs1, ID_rs2, ID_rd;
wire [4:0] EX_rd, MEM_rd, WB_rd;
wire [11:0] ID_Imm12, ID_Offset, EX_Offset;
wire [19:0] ID_Offset20, EX_Offset20;
wire [31:0] IF_PC, IF_PCA4, IM_PC, NPC_PC_pipe, PC_NPC_pipe;
wire [31:0] ID_RD1, ID_RD2;
wire [31:0] EX_RD1, EX_RD2;
wire [31:0] EX_Imm32, EX_PCA4, EX_PC;
wire [31:0] MEM_WD, MEM_PCA4, WB_WD, dnpc;

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
    .ExtSel(ExtSel), .ALUOp(ALUOp), .NPCop(NPCop), .ALUSrcA(ALUSrcA),
    .WDSel(WDSel), .ALUSrcB(ALUSrcB), .RegSel(RegSel),

    .branch_zero(ID_zero), .opcode_pipe(EX_branch ? 7'b0 : opcode),
    .rs1(rs1), .rs2(rs2), .EX_rd(EX_rd), .MEM_rd(MEM_rd), .WB_rd(WB_rd), .rd_in(rd),
    .Imm12_in(Imm12), .Imm32_in(Imm32), .Offset_in(Offset), .Offset20_in(Offset20), .IF_PCA4_in(IF_PCA4), .IF_PC_in(IF_PC),
    .RD1_in(RD1), .RD2_in(RD2), .WB_WD_in(WB_WD), .ALU_result(ALU_result), .ALU_result_r(ALU_result_r), .RD1_r(RD1_r), .RD2_r(RD2_r),
    .EX_WD_in(RD2_r), .EX_PCA4_in(EX_PCA4), .WD_in(WD), .NPC_NPC_in(NPC),
    .WB_RFWrite(WB_RFWrite), .bubble(IF_bubble),
    .ID_RD1_out(ID_RD1), .ID_RD2_out(ID_RD2), .ID_zero(ID_zero),
    .ID_ALUOp(ID_ALUOp), .ID_RegSel(ID_RegSel), .ID_ALUSrcB(ID_ALUSrcB), .ID_WDSel(ID_WDSel), .ID_Imm12_out(ID_Imm12),
    .ID_Offset_out(ID_Offset), .ID_Offset20_out(ID_Offset20), .ID_rs1_out(ID_rs1), .ID_rs2_out(ID_rs2), .ID_rd_out(ID_rd),
    .EX_RD1_out(EX_RD1), .EX_RD2_out(EX_RD2),
    .ID_ALUSrcA(ID_ALUSrcA), .ID_RFWrite(ID_RFWrite), .ID_DMCtrl(ID_DMCtrl), .ID_done(ID_done),
    .EX_ALUOp(EX_ALUOp), .EX_RegSel(EX_RegSel), .EX_ALUSrcB(EX_ALUSrcB), .EX_WDSel(EX_WDSel), .EX_Imm32_out(EX_Imm32),
    .EX_Offset_out(EX_Offset), .EX_Offset20_out(EX_Offset20), .EX_PCA4_out(EX_PCA4), .EX_PC_out(EX_PC), .EX_rd_out(EX_rd),
    .EX_ALUSrcA(EX_ALUSrcA), .EX_RFWrite(EX_RFWrite), .EX_DMCtrl(EX_DMCtrl), .EX_done(EX_done),
    .MEM_WD_out(MEM_WD), .MEM_PCA4_out(MEM_PCA4), .MEM_rd_out(MEM_rd), .MEM_WDSel_out(MEM_WDSel), .MEM_DMCtrl_out(MEM_DMCtrl),
    .MEMStall_WDSel_out(MEMStall_WDSel), .MEMStall_stall_out(MEMStall_stall), .WB_rd_out(WB_rd), .WB_RFWrite_out(WB_RFWrite),
    .WB_WD_out(WB_WD), .done_out(done), .DMReadStall(MEM_DMReadStall), .dnpc_out(dnpc),
    .branch(EX_branch), .EX_NPCOp(EX_NPCOp)
);

// ÊuÀý»- PC
PC U_PC (
    .clk(clk), .rst(rst), .PCWrite(PCWrite), .NPC(NPC), .PC(PC),

    .EX_branch(EX_branch), .IF_bubble(IF_bubble), .IF_PCA4(IF_PCA4), .IF_PC(IF_PC),
    .NPC_NPC(NPC), .EX_PC(EX_PC), .PC_NPC(PC_NPC_pipe), .IM_PC(IM_PC), .NPC_PC(NPC_PC_pipe), .IM_addr(IM_addr), .PCA4(PCA4),
    .use_pipe(1'b1), .NPC_pipe(PC_NPC_pipe)
);

// ÊuÀý»- NPC
NPC U_NPC (
    .PC(PC), .NPCop(NPCop), .Offset12(Offset), .Offset20(Offset20), .rs(RD1[31:2]), .PCA4(PCA4), .NPC(NPC),

    .use_pipe(1'b1), .NPCop_pipe(EX_NPCOp), .Offset12_pipe(EX_Offset), .Offset20_pipe(EX_Offset20), .PC_pipe(NPC_PC_pipe), .rs_pipe(RD1_r)
);

// ÊuÀý»- IM
IM U_IM (
    .addr(PC[11:2]), .Ins(in_ins), .InsMemRW(InsMemRW),

    .clk(clk), .rst(rst), .use_pipe(1'b1), .addr_pipe(IM_addr)
);

// ÊuÀý»- IR
IR U_IR (
    .clk(clk), .IRWrite(IRWrite), .in_ins(in_ins), .out_ins(out_ins)
);

// ÊuÀý»- RF
RF U_RF (
    .RR1(rs1), .RR2(rs2), .WR(WR), .WD(WD), .clk(clk),
    .RFWrite(RFWrite), .RD1(RD1), .RD2(RD2),

    .use_pipe(1'b1), .RR1_pipe(ID_rs1), .RR2_pipe(ID_rs2), .WD_pipe(WB_WD), .RFWrite_pipe(WB_RFWrite)
);

// ÊuÀý»- MUX_3to1
MUX_3to1 U_MUX_3to1 (
    .X(rd), .Y(5'd0), .Z(5'd31),
    .control(RegSel), .out(WR),

    .use_pipe(1'b1), .X_pipe(WB_rd), .control_pipe(`RegSel_rd)
);

// ÊuÀý»- MUX_3to1_LMD
MUX_3to1_LMD U_MUX_3to1_LMD (
    .X(ALU_result_r), .Y(DR_out), .Z(PCA4),
    .control(WDSel), .out(WD),

    .stall_control(MEMStall_WDSel), .stall(MEMStall_stall), .use_pipe(1'b1), .Z_pipe(MEM_PCA4), .control_pipe(MEM_WDSel)
);

// ÊuÀý»- Flopr
Flopr U_A (
    .clk(clk), .rst(rst), .in_data(RD1), .out_data(RD1_r),

    .en(1'b1), .pipe_use(1'b1), .pipe_in_data(ID_RD1)
);

// ÊuÀý»- Flopr
Flopr U_B (
    .clk(clk), .rst(rst), .in_data(RD2), .out_data(RD2_r),

    .en(1'b1), .pipe_use(1'b1), .pipe_in_data(ID_RD2)
);

// ÊuÀý»- EXT
EXT U_EXT (
    .imm_in(Imm12), .ExtSel(ExtSel), .imm_out(Imm32)
);

// ÊuÀý»- MUX_2to1_A
MUX_2to1_A U_MUX_2to1_A (
    .X(RD1_r), .Y(32'h0), .control(ALUSrcA), .out(A),

    .use_pipe(1'b1), .X_pipe(RD1_r), .Y_pipe(32'h0), .control_pipe(EX_ALUSrcA)
);

// ÊuÀý»- MUX_2to1_B
MUX_3to1_B U_MUX_3to1_B (
    .X(RD2_r), .Y(Imm32), .Z(Offset), .control(ALUSrcB), .out(B),

    .use_pipe(1'b1), .Y_pipe(EX_Imm32), .Z_pipe(EX_Offset), .control_pipe(EX_ALUSrcB)
);

// ÊuÀý»- ALU
ALU U_ALU (
    .A(A), .B(B), .ALUOp(ALUOp), .ALU_result(ALU_result), .zero(zero),

    .use_pipe(1'b1), .ALUOp_pipe(EX_ALUOp)
);

// ÊuÀý»- Flopr
Flopr U_ALUOut (
    .clk(clk), .rst(rst), .in_data(ALU_result), .out_data(ALU_result_r),

    .en(1'b1), .pipe_use(1'b0), .pipe_in_data(32'h0)
);

// ÊuÀý»- DM
DM U_DM (
    .Addr(ALU_result_r[11:2]), .WD(RD2_r), .DMCtrl(DMCtrl), .clk(clk), .RD(RD),

    .rst(rst), .use_pipe(1'b1), .WD_pipe(MEM_WD), .DMCtrl_pipe(MEM_DMCtrl)
);

//// ÊuÀý»- Flopr
//Flopr U_DR (
//    .clk(clk), .rst(rst), .in_data(RD), .out_data(DR_out)
//);

assign DR_out = RD;

`ifdef difftest
export "DPI-C" function DPI_getPC;
function int DPI_getPC();
    return dnpc;
endfunction
`endif

endmodule
