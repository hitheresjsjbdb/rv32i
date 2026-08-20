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
`ifdef WISHBONE
, iwb_adr_o, iwb_dat_o, iwb_dat_i, iwb_sel_o, iwb_we_o,
  iwb_cyc_o, iwb_stb_o, iwb_ack_i, iwb_err_i,
  dwb_adr_o, dwb_dat_o, dwb_dat_i, dwb_sel_o, dwb_we_o,
  dwb_cyc_o, dwb_stb_o, dwb_ack_i, dwb_err_i
`endif
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

`ifdef WISHBONE
output [31:0] iwb_adr_o;
output [31:0] iwb_dat_o;
input  [31:0] iwb_dat_i;
output [3:0]  iwb_sel_o;
output        iwb_we_o;
output        iwb_cyc_o;
output        iwb_stb_o;
input         iwb_ack_i;
input         iwb_err_i;
output [31:0] dwb_adr_o;
output [31:0] dwb_dat_o;
input  [31:0] dwb_dat_i;
output [3:0]  dwb_sel_o;
output        dwb_we_o;
output        dwb_cyc_o;
output        dwb_stb_o;
input         dwb_ack_i;
input         dwb_err_i;
`endif

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
wire [31:0] in_ins, DR_out;
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
wire [31:0] FETCH_PC;
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
wire [31:0] NPC_taken_p4;
wire [4:0]  RF_RR1, RF_RR2;
wire IF_ready, IF_error, DM_ready, DM_error;
wire DMReq, mem_hold;
`ifdef WISHBONE
wire iwb_req_ready;
wire dwb_req_ready;
`endif

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
assign IM_addr = FETCH_PC[11:2];

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
    .NPC(NPC), .NPC_taken_p4(NPC_taken_p4),
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
    // external memory completion
    .IF_ready(IF_ready), .IF_error(IF_error),
    .DM_ready(DM_ready), .DM_error(DM_error),

    /* new outputs */
    // control signals
    .stall(stall), .mem_hold(mem_hold), .branch(branch),
    // to fetch control
    .PC_NPC(PC_NPC), .NPC_PC(NPC_PC), .FETCH_PC(FETCH_PC),
    // to NPC
    .NPC_EX_Offset12(NPC_EX_Offset12), .NPC_EX_Offset20(NPC_EX_Offset20),
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
    .DM_WD(DM_WD), .DMReq(DMReq),
    // minimal synchronous exception interface
    .trap(trap), .trap_cause(trap_cause), .trap_epc(trap_epc), .trap_tval(trap_tval)


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
    .NPC_PC(NPC_PC), .NPC_Offset12(NPC_EX_Offset12), .NPC_Offset20(NPC_EX_Offset20), .NPC_rs(RD1_r),
    .NPC_taken_p4(NPC_taken_p4)
);

`ifdef WISHBONE
WishboneMaster U_InstructionWishboneMaster (
    .clk(clk), .rst(rst),
    .req_valid(InsMemRW), .req_ready(iwb_req_ready),
    .req_addr(PC), .req_wdata(32'b0),
    .req_sel(4'b1111), .req_we(1'b0),
    .rsp_valid(IF_ready), .rsp_error(IF_error), .rsp_rdata(in_ins),
    .wb_adr_o(iwb_adr_o), .wb_dat_o(iwb_dat_o), .wb_dat_i(iwb_dat_i),
    .wb_sel_o(iwb_sel_o), .wb_we_o(iwb_we_o),
    .wb_cyc_o(iwb_cyc_o), .wb_stb_o(iwb_stb_o),
    .wb_ack_i(iwb_ack_i), .wb_err_i(iwb_err_i)
);
`else
assign IF_ready = 1'b1;
assign IF_error = 1'b0;

// Internal instruction memory used by the existing simulator.
IM U_IM (
    .addr(PC[11:2]), .Ins(in_ins), .InsMemRW(InsMemRW),

    /* new inputs */
    .clk(clk), .rst(rst), .IM_addr(IM_addr), .branch(branch)
);
`endif

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
    .clk(clk), .rst(rst), .in_data(mem_hold ? RD1_r : RD1), .out_data(RD1_r)
);

// ÊuÀý»- Flopr
Flopr U_B (
    .clk(clk), .rst(rst), .in_data(mem_hold ? RD2_r : RD2), .out_data(RD2_r)
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
    .clk(clk), .rst(rst),
    .in_data(mem_hold ? ALU_result_r : ALU_result),
    .out_data(ALU_result_r)
);

`ifdef WISHBONE
WishboneMaster U_DataWishboneMaster (
    .clk(clk), .rst(rst),
    .req_valid(DMReq), .req_ready(dwb_req_ready),
    .req_addr(ALU_result_r), .req_wdata(DM_WD),
    .req_sel(4'b1111), .req_we(DMCtrl),
    .rsp_valid(DM_ready), .rsp_error(DM_error), .rsp_rdata(DR_out),
    .wb_adr_o(dwb_adr_o), .wb_dat_o(dwb_dat_o), .wb_dat_i(dwb_dat_i),
    .wb_sel_o(dwb_sel_o), .wb_we_o(dwb_we_o),
    .wb_cyc_o(dwb_cyc_o), .wb_stb_o(dwb_stb_o),
    .wb_ack_i(dwb_ack_i), .wb_err_i(dwb_err_i)
);
assign RD = DR_out;
`else
assign DM_ready = 1'b1;
assign DM_error = 1'b0;

// Internal data memory used by the existing simulator.
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
`endif


endmodule
