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
module riscv(clk, rst, RD, out_ins, trap, trap_cause, trap_epc, trap_tval
`ifdef DIFFTEST
, done
`endif
);
input clk, rst;
output [31:0] RD;
output [31:0] out_ins;
output trap;
output [3:0] trap_cause;
output [31:0] trap_epc;
output [31:0] trap_tval;

`ifdef DIFFTEST
output done;
`endif

wire RFWrite, DMCtrl, PCWrite, InsMemRW;
wire [1:0] NPCOp;
wire [3:0] ALUOp;
wire [31:0] PC, NPC, PCA4;
wire [31:0] in_ins, DR_out;
wire [4:0] WR;
wire [31:0] RD1, RD1_r, RD2, RD2_r;
wire [31:0] RD1_raw, RD2_raw;
wire [31:0] A, B, ALU_result, ALU_result_r;

/* pipeline interconnect */
wire [31:0] PC_NPC, NPC_PC;
wire [31:0] FETCH_PC;
wire [19:0] NPC_EX_Offset20;
wire [11:0] NPC_EX_Offset12;
wire [4:0]  WB_rd;
wire forward1, forward2;
wire [31:0] FD1, FD2;
wire [31:0] EX_ALU_B;
wire [31:0] RF_WD;
wire [31:0] DM_WD;
wire [31:0] NPC_taken_p4;
wire [4:0]  ID_rs1, ID_rs2;
wire IF_ready, IF_error, DM_ready, DM_error;
wire mem_hold;
wire DMReq;

ControlUnit U_ControlUnit(
    // Inputs
    .clk(clk),
    .rst(rst),
    .instruction(in_ins),
    .PC(PC),
    .PCA4(PCA4),
    .NPC(NPC),
    .NPC_taken_p4(NPC_taken_p4),
    .RD2(RD2),
    .RD1_raw(RD1_raw),
    .RD2_raw(RD2_raw),
    .ALU_result(ALU_result),
    .ALU_result_r(ALU_result_r),
    .DM_RD(DR_out),
    .RD2_r(RD2_r),
    .IF_ready(IF_ready),
    .IF_error(IF_error),
    .DM_ready(DM_ready),
    .DM_error(DM_error),

    // Outputs
    .RFWrite(RFWrite),
    .DMCtrl(DMCtrl),
    .PCWrite(PCWrite),
    .InsMemRW(InsMemRW),
    .ALUOp(ALUOp),
    .NPCOp(NPCOp),
    .mem_hold(mem_hold),
    .PC_NPC(PC_NPC),
    .NPC_PC(NPC_PC),
    .FETCH_PC(FETCH_PC),
    .NPC_EX_Offset12(NPC_EX_Offset12),
    .NPC_EX_Offset20(NPC_EX_Offset20),
    .WB_rd_out(WB_rd),
    .forward1(forward1),
    .forward2(forward2),
    .FD1(FD1),
    .FD2(FD2),
    .RF_WD(RF_WD),
    .ID_rs1_out(ID_rs1),
    .ID_rs2_out(ID_rs2),
    .EX_ALU_B(EX_ALU_B),
    .DM_WD(DM_WD),
    .DMReq(DMReq),
    .trap(trap),
    .trap_cause(trap_cause),
    .trap_epc(trap_epc),
    .trap_tval(trap_tval)
`ifdef DIFFTEST
    , .done(done)
`endif
);

PC U_PC (
    // Inputs
    .clk(clk),
    .rst(rst),
    .write_enable(PCWrite),
    .next_pc(PC_NPC),

    // Outputs
    .pc(PC)
);

NPC U_NPC (
    // Inputs
    .PC(PC),
    .NPCOp(NPCOp),
    .NPC_PC(NPC_PC),
    .NPC_Offset12(NPC_EX_Offset12),
    .NPC_Offset20(NPC_EX_Offset20),
    .NPC_rs(RD1_r),

    // Outputs
    .PCA4(PCA4),
    .NPC(NPC),
    .NPC_taken_p4(NPC_taken_p4)
);

DirectInstructionMemory U_InstructionMemory (
    // Inputs
    .clk(clk),
    .rst(rst),
    .req_valid(InsMemRW),
    .req_addr(FETCH_PC),

    // Outputs
    .rsp_valid(IF_ready),
    .rsp_error(IF_error),
    .rsp_rdata(in_ins)
);

assign out_ins = in_ins;

RF U_RF (
    // Inputs
    .RR1(ID_rs1),
    .RR2(ID_rs2),
    .WR(WR),
    .WD(RF_WD),
    .clk(clk),
    .RFWrite(RFWrite),
    .forward1(forward1),
    .forward2(forward2),
    .FD1(FD1),
    .FD2(FD2),

    // Outputs
    .RD1(RD1),
    .RD2(RD2),
    .RD1_raw(RD1_raw),
    .RD2_raw(RD2_raw)
);

assign WR = WB_rd;

Flopr U_A (
    // Inputs
    .clk(clk),
    .rst(rst),
    .in_data(mem_hold ? RD1_r : RD1),

    // Outputs
    .out_data(RD1_r)
);

Flopr U_B (
    // Inputs
    .clk(clk),
    .rst(rst),
    .in_data(mem_hold ? RD2_r : RD2),

    // Outputs
    .out_data(RD2_r)
);

assign A = RD1_r;
assign B = EX_ALU_B;

ALU U_ALU (
    // Inputs
    .A(A),
    .B(B),
    .ALUOp(ALUOp),

    // Outputs
    .ALU_result(ALU_result)
);

Flopr U_ALUOut (
    // Inputs
    .clk(clk),
    .rst(rst),
    .in_data(mem_hold ? ALU_result_r : ALU_result),

    // Outputs
    .out_data(ALU_result_r)
);

DirectDataMemory U_DataMemory (
    // Inputs
    .clk(clk),
    .rst(rst),
    .req_valid(DMReq),
    .req_addr(ALU_result_r),
    .req_wdata(DM_WD),
    .req_we(DMCtrl),

    // Outputs
    .rsp_valid(DM_ready),
    .rsp_error(DM_error),
    .rsp_rdata(DR_out)
);

assign RD = DR_out;


endmodule
