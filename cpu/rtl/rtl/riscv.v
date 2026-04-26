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
wire [31:0] PC_NPC, NPC_NPC, NPC_PC, IM_PC;
//default

/* ID */
wire [31:0] ID_PCA4, ID_RD1, ID_RD2, ID_PC;
wire [11:0] ID_Imm12, ID_Offset;
wire [4:0]  ID_rs1, ID_rs2, ID_rd;
wire [3:0]  ID_ALUOp;
wire [1:0]  ID_Regsel, ID_ALUSrcB, ID_WDSel;
wire        ID_ALUSrcA, ID_RFWrite, ID_DMCtrl;
wire        ID_done;
wire        EX_branch;

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

wire        cu_zero;



// ÊuÀý»- ControlUnit
ControlUnit U_ControlUnit(
    /* input */
    .clk(clk), .rst(rst), .zero(cu_zero), .opcode(EX_branch ? 7'b0 : opcode), .Funct7(Funct7), .Funct3(Funct3),
    .IF_done(IF_done),
    .rs1(rs1), .rs2(rs2), .ID_rd(ID_rd), .EX_rd(EX_rd), .MEM_rd(MEM_rd), .WB_rd(WB_rd),
    .ID_rs1(ID_rs1), .ID_rs2(ID_rs2),
    .RD1_in(RD1), .RD2_in(RD2), .WB_WD_in(WB_WD),
    .WB_RFWrite(WB_RFWrite), .MEM_DMReadStall(MEM_DMReadStall),
    .bubble(IF_bubble),
    .ID_RD1_out(ID_RD1), .ID_RD2_out(ID_RD2), .ID_zero(cu_zero),

    /* output */
    .RFWrite(RFWrite), .DMCtrl(DMCtrl), .PCWrite(PCWrite), .IRWrite(IRWrite), .InsMemRW(InsMemRW),
    .ExtSel(ExtSel), .ALUOp(ALUOp), .NPCOp(NPCOp), .ALUSrcA(ALUSrcA),
    .WDSel(WDSel), .ALUSrcB(ALUSrcB), .RegSel(RegSel), /*.done(done)*/
    .ID_ALUOp(ID_ALUOp), .ID_RegSel(ID_Regsel), .ID_ALUSrcB(ID_ALUSrcB), .ID_WDSel(ID_WDSel),
    .ID_ALUSrcA(ID_ALUSrcA), .ID_RFWrite(ID_RFWrite), .ID_DMCtrl(ID_DMCtrl), .ID_done(ID_done),
    .EX_ALUOp(EX_ALUOp), .EX_RegSel(EX_Regsel), .EX_ALUSrcB(EX_ALUSrcB), .EX_WDSel(EX_WDSel),
    .EX_ALUSrcA(EX_ALUSrcA), .EX_RFWrite(EX_RFWrite), .EX_DMCtrl(EX_DMCtrl), .EX_done(EX_done),

    .branch(EX_branch), .EX_NPCOp(EX_NPCOp)
);

/* ******************************** Pipeline Stages ******************************** */

/* ################################ IF ################################ */

Reg #(.WIDTH(1))  U_IF_done (.clk(clk), .rst(rst), .en(1'b1), .in(1'b1), .out(IF_done));
Reg #(.WIDTH(32)) U_IF_PC   (.clk(clk), .rst(rst), .en(~IF_bubble), .in(EX_branch ? IM_PC : PC)  , .out(IF_PC)  );
Reg #(.WIDTH(32)) U_IF_PCA4 (.clk(clk), .rst(rst), .en(~IF_bubble), .in(EX_branch ? NPC_NPC+4 : PCA4), .out(IF_PCA4));

// ÊuÀý»- PC
PC U_PC (
    .clk(clk), .rst(rst), .PCWrite(PCWrite), .NPC(PC_NPC), .PC(PC),
    .EX_branch(EX_branch), .IF_bubble(IF_bubble), .IF_PCA4(IF_PCA4), .IF_PC(IF_PC),
    .NPC_NPC(NPC_NPC), .EX_PC(EX_PC), .PC_NPC(PC_NPC), .IM_PC(IM_PC), .NPC_PC(NPC_PC), .IM_addr(IM_addr)
);

// ÊuÀý»- NPC
NPC U_NPC (
    .PC(NPC_PC), .NPCOp(EX_NPCOp), .Offset12(EX_Offset), .Offset20(EX_Offset20), .rs({RD1_r[31:2], 2'b00}), .PCA4(PCA4), .NPC(NPC_NPC)
);

// ÊuÀý»- IM
IM U_IM (
    .clk(clk), .addr(IM_addr), .Ins(in_ins), .InsMemRW(InsMemRW), .rst(rst)
);

// ÊuÀý»- IR
IR U_IR (
    .IRWrite(IRWrite), .in_ins(in_ins), .out_ins(out_ins)
);

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
    .imm_in(ID_Imm12), .ExtSel(`ExtSel_SIGNED), .imm_out(Imm32),
    .ins(out_ins), .opcode_out(opcode), .Funct3_out(Funct3), .Funct7_out(Funct7), .rs1_out(rs1), .rs2_out(rs2), .rd_out(rd),
    .Imm12_out(Imm12), .Offset20_out(Offset20), .Offset_out(Offset),
    .clk(clk), .rst(rst),
    .ID_Imm12_pipe(ID_Imm12), .ID_Offset_pipe(ID_Offset), .ID_Offset20_pipe(ID_Offset20),
    .EX_Imm32_pipe(EX_Imm32), .EX_Offset_pipe(EX_Offset), .EX_Offset20_pipe(EX_Offset20)
);

// ÊuÀý»- Flopr
Flopr U_A (
    .clk(clk), .rst(rst), .in_data(ID_RD1), .out_data(RD1_r)
);

// ÊuÀý»- Flopr
Flopr U_B (
    .clk(clk), .rst(rst), .in_data(ID_RD2), .out_data(RD2_r)
);

// Reg #(.WIDTH(1)) U_IDEX_zero (.clk(clk), .rst(rst), .en(1'b1), .in(EX_branch ? 1'b0 : ID_RD1 == ID_RD2), .out(cu_zero));

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
    .control(MEM_WDSel), .stall_control(MEMStall_WDSel), .stall(MEMStall_stall), .out(WD)
);


// ÊuÀý»- DM
DM U_DM (
    .Addr(ALU_result_r[11:2]), .WD(MEM_WD), .clk(clk), .rst(rst), .DMCtrl(MEM_DMCtrl), .RD(RD),
    .EX_WD_in(RD2_r), .EX_PCA4_in(EX_PCA4), .EX_rd_in(EX_rd), .EX_WDSel_in(EX_WDSel),
    .EX_RFWrite_in(EX_RFWrite), .EX_DMCtrl_in(EX_DMCtrl), .EX_done_in(EX_done),
    .MEM_WD_out(MEM_WD), .MEM_PCA4_out(MEM_PCA4), .MEM_rd_out(MEM_rd), .MEM_WDSel_out(MEM_WDSel),
    .MEM_RFWrite_out(MEM_RFWrite), .MEM_DMCtrl_out(MEM_DMCtrl), .MEM_done_out(MEM_done),
    .MEMStall_rd_out(MEMStall_rd), .MEMStall_WDSel_out(MEMStall_WDSel), .MEMStall_RFWrite_out(MEMStall_RFWrite),
    .MEMStall_done_out(MEMStall_done), .MEMStall_stall_out(MEMStall_stall),
    .WB_rd_out(WB_rd), .WB_RFWrite_out(WB_RFWrite), .WB_done_out(WB_done),
    .DMReadStall(MEM_DMReadStall)
);

/* ################################ WB ################################ */

assign DR_out = RD;
Reg #(1) U_done (.clk(clk), .rst(rst), .en(1'b1), .in(WB_done), .out(done));


/* #################################### pipeline #################################### */

/* IF -> ID */

Reg #(.WIDTH(32))  U_IFID_PCA4 (.clk(clk), .rst(rst), .en(1'b1), .in(IF_PCA4), .out(ID_PCA4));
Reg #(.WIDTH(32))  U_IFID_PC   (.clk(clk), .rst(rst), .en(1'b1), .in(IF_PC) , .out(ID_PC)  );

Reg #(.WIDTH(5) )  U_IFID_rs1 (.clk(clk), .rst(rst), .en(1'b1), .in(rs1), .out(ID_rs1));
Reg #(.WIDTH(5) )  U_IFID_rs2 (.clk(clk), .rst(rst), .en(1'b1), .in(rs2), .out(ID_rs2));
Reg #(.WIDTH(5) )  U_IFID_rd  (.clk(clk), .rst(rst), .en(1'b1), .in(rd) , .out(ID_rd) );

// NPC
/* ID -> EX */

Reg #(.WIDTH(32))  U_IDEX_PCA4  (.clk(clk), .rst(rst), .en(1'b1), .in(ID_PCA4), .out(EX_PCA4) );
Reg #(.WIDTH(32))  U_IDEX_PC    (.clk(clk), .rst(rst), .en(1'b1), .in(ID_PC)  , .out(EX_PC)   );

Reg #(.WIDTH(5) )  U_IDEX_rd (.clk(clk), .rst(rst), .en(1'b1), .in(ID_rd), .out(EX_rd));

/* MEM -> WB */

Reg #(.WIDTH(32)) U_MEMWB_WD (.clk(clk), .rst(rst), .en(1'b1), .in(WD), .out(WB_WD));

`ifdef difftest

wire [31:0] ID_dnpc, EX_dnpc, MEM_dnpc, MEMStall_dnpc, WB_dnpc, dnpc;

Reg #(.WIDTH(32)) U_IFID_dnpc     (.clk(clk), .rst(rst), .en(1'b1), .in(IF_PCA4)                                  , .out(ID_dnpc)      );
Reg #(.WIDTH(32)) U_IDEX_dnpc     (.clk(clk), .rst(rst), .en(1'b1), .in(ID_dnpc)                                  , .out(EX_dnpc)      );
Reg #(.WIDTH(32)) U_EXMEM_dnpc    (.clk(clk), .rst(rst), .en(1'b1), .in(EX_branch ? NPC_NPC : EX_dnpc)            , .out(MEM_dnpc)     );
Reg #(.WIDTH(32)) U_MEMstall_dnpc (.clk(clk), .rst(rst), .en(1'b1), .in(MEM_dnpc)                                 , .out(MEMStall_dnpc));
Reg #(.WIDTH(32)) U_MEMWB_dnpc    (.clk(clk), .rst(rst), .en(1'b1), .in(MEMStall_stall ? MEMStall_dnpc : MEM_dnpc), .out(WB_dnpc)      );
Reg #(.WIDTH(32)) U_WB_dnpc       (.clk(clk), .rst(rst), .en(1'b1), .in(WB_dnpc)                                  , .out(dnpc)         );

export "DPI-C" function DPI_getPC;
function int DPI_getPC();
    return dnpc;
endfunction

`endif

endmodule