`timescale 1ns / 1ps


// NPC control signal
`define NPC_PC      2'b00
`define NPC_Offset12 2'b01
`define NPC_rs      2'b10
`define NPC_Offset20 2'b11

// A control signal
`define ALUSrcA_A    1'b0
`define ALUSrcA_sa   1'b1

// B control signal
`define ALUSrcB_B    2'b00
`define ALUSrcB_Imm  2'b01
`define ALUSrcB_Offset 2'b10
`define ALUSrcB_else 2'b11

// EXT control signal
`define ExtSel_ZERO  1'b0
`define ExtSel_SIGNED 1'b1

// ALU control signal
`define ALUOp_ADD   4'b0000
`define ALUOp_SUB   4'b0001
`define ALUOp_AND   4'b0010
`define ALUOp_OR    4'b0011
`define ALUOp_XOR   4'b0100
`define ALUOp_SRA   4'b0101
`define ALUOp_SLL   4'b1000
`define ALUOp_SRL   4'b1001
`define ALUOp_BR    4'b1010

// RF control signal
`define RegSel_rd    2'b00
`define RegSel_rt    2'b01
`define RegSel_31    2'b10
`define RegSel_else  2'b11

`define WDSel_FromALU 2'b00
`define WDSel_FromMEM 2'b01
`define WDSel_FromPC  2'b10
`define WDSel_Else    2'b11

// DM control signal
`define DMCtrl_RD    1'b0
`define DMCtrl_WR    1'b1

 `define DEBUG 1
//`define DIFFTEST 1
//`define SRAM 1

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/20 19:50:15
// Design Name: 
// Module Name: instruction_def
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

// OPCODE
`define INSTR_RTYPE_OP      7'b0110011
`define INSTR_ITYPE_OP      7'b0010011
`define INSTR_BTYPE_OP      7'b1100011
`define INSTR_LW_OP         7'b0000011
`define INSTR_SW_OP         7'b0100011
`define INSTR_JAL_OP        7'b1101111
`define INSTR_JALR_OP       7'b1100111

// RÀàDÍ Funct ÒòÎªÖá
`define INSTR_ADD_FUNCT     10'b0000000_000
`define INSTR_SUB_FUNCT     10'b0100000_000
`define INSTR_SUBU_FUNCT    6'b100011
`define INSTR_AND_FUNCT     10'b0000000_111
`define INSTR_OR_FUNCT      10'b0000000_110
`define INSTR_XOR_FUNCT     10'b0000000_100
`define INSTR_NOR_FUNCT     6'b100111
`define INSTR_SLL_FUNCT     10'b0000000_001
`define INSTR_SRL_FUNCT     10'b0000000_101
`define INSTR_SRA_FUNCT     10'b0100000_101
`define INSTR_SRLV_FUNCT    6'b000110
`define INSTR_SRAV_FUNCT    6'b000111
`define INSTR_SLLV_FUNCT    6'b000100
`define INSTR_JR_FUNCT      6'b001000

// BÀàDÍ Funct ÒòÎªÖá
`define INSTR_BEQ_FUNCT     3'b000
`define INSTR_BNE_FUNCT     3'b001

// BÀàDÍ Funct ÒòÎªÖá
`define INSTR_ADDI_FUNCT    3'b000
`define INSTR_ORI_FUNCT     3'b110


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

    /* new outputs */
    // control signals
    .stall(stall), .branch(branch),
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
    .NPC_PC(NPC_PC), .NPC_Offset12(NPC_EX_Offset12), .NPC_Offset20(NPC_EX_Offset20), .NPC_rs(RD1_r),
    .NPC_taken_p4(NPC_taken_p4)
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




module ALU(A,B,ALUOp,zero,ALU_result);
    input signed [31:0] A;
    input signed [31:0] B;
    input [3:0] ALUOp;
    output zero;
    output reg signed [31:0] ALU_result;

// Branch compare is better driven by direct operand compare than ALU-result fanout.
assign zero = (A == B);

wire [4:0] SHAMT;
wire [31:0] ADD_RESULT;
wire [31:0] SUB_RESULT;
wire [32:0] ADD_EXT;
wire [32:0] SUB_EXT;
wire signed [31:0] LOGIC_RESULT;
wire signed [31:0] SHIFT_RESULT;
wire ADD_CO_UNUSED;
wire SUB_CO_UNUSED;

assign SHAMT = B[4:0];

// Cut the ALUOp -> adder critical path by computing add and sub in parallel.
// ALUOp then only selects between already-computed results.
`ifdef SYNTHESIS
DW01_add #(32) U_DW_ALU_ADD (
    .A   (A),
    .B   (B),
    .CI  (1'b0),
    .SUM (ADD_RESULT),
    .CO  (ADD_CO_UNUSED)
);
DW01_add #(32) U_DW_ALU_SUB (
    .A   (A),
    .B   (~B),
    .CI  (1'b1),
    .SUM (SUB_RESULT),
    .CO  (SUB_CO_UNUSED)
);
`else
assign ADD_EXT       = {1'b0, A} + {1'b0, B};
assign SUB_EXT       = {1'b0, A} + {1'b0, ~B} + 33'b1;
assign ADD_RESULT    = ADD_EXT[31:0];
assign SUB_RESULT    = SUB_EXT[31:0];
assign ADD_CO_UNUSED = ADD_EXT[32];
assign SUB_CO_UNUSED = SUB_EXT[32];
`endif

assign LOGIC_RESULT =
    (ALUOp == `ALUOp_AND) ? (A & B) :
    (ALUOp == `ALUOp_OR)  ? (A | B) :
    (ALUOp == `ALUOp_XOR) ? (A ^ B) :
    32'sb0;

assign SHIFT_RESULT =
    (ALUOp == `ALUOp_SRA) ? (A >>> SHAMT) :
    (ALUOp == `ALUOp_SLL) ? (A << SHAMT) :
    (ALUOp == `ALUOp_SRL) ? $signed($unsigned(A) >> SHAMT) :
    32'sb0;

always @(*) begin
    // synopsys parallel_case full_case
    case (ALUOp)
        `ALUOp_ADD: ALU_result = $signed(ADD_RESULT);
        `ALUOp_SUB: ALU_result = $signed(SUB_RESULT);
        `ALUOp_AND,
        `ALUOp_OR,
        `ALUOp_XOR: ALU_result = LOGIC_RESULT;
        `ALUOp_SRA,
        `ALUOp_SLL,
        `ALUOp_SRL: ALU_result = SHIFT_RESULT;
        default:    ALU_result = 32'sb0;
    endcase
end

endmodule




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
    input [31:0] NPC_taken_p4,
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
    output reg [31:0] FETCH_PC,
    output reg [19:0] NPC_EX_Offset20,
    output reg [11:0] NPC_EX_Offset12,
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
wire        ID_use_rs1;
wire        ID_use_rs2;
wire        ID_dep_EX;
wire        ID_dep_MEM;
wire        ID_dep_MEMSTALL;
wire        load_pipe_busy;
wire        pipe_flush;
wire [31:0] ID_Imm32_local;
wire [31:0] ID_Offset32_local;
reg  [31:0] ID_ALU_B_sel;
wire [31:0] EX_ALU_B_sel;
wire        dec_is_rtype;
wire        dec_is_itype;
wire        dec_is_lw;
wire        dec_is_sw;
wire        dec_is_btype;
wire        dec_is_jal;
wire        dec_is_jalr;
wire        dec_r_add;
wire        dec_r_sub;
wire        dec_r_and;
wire        dec_r_or;
wire        dec_r_xor;
wire        dec_r_sll;
wire        dec_r_srl;
wire        dec_r_sra;
wire        dec_r_valid;
wire        dec_i_addi;
wire        dec_i_ori;
wire        dec_i_valid;
wire        id_is_beq;
wire        id_is_bne;
wire        id_take_branch;
wire        if_dec_rfwrite;
wire        if_dec_dmctrl;
wire [1:0]  if_dec_alusrcb;
wire [1:0]  if_dec_wdsel;
wire [3:0]  if_dec_aluop;

assign dec_is_rtype = (opcode == `INSTR_RTYPE_OP);
assign dec_is_itype = (opcode == `INSTR_ITYPE_OP);
assign dec_is_lw    = (opcode == `INSTR_LW_OP);
assign dec_is_sw    = (opcode == `INSTR_SW_OP);
assign dec_is_btype = (opcode == `INSTR_BTYPE_OP);
assign dec_is_jal   = (opcode == `INSTR_JAL_OP);
assign dec_is_jalr  = (opcode == `INSTR_JALR_OP);

assign dec_r_add = dec_is_rtype && ({Funct7, Funct3} == `INSTR_ADD_FUNCT);
assign dec_r_sub = dec_is_rtype && ({Funct7, Funct3} == `INSTR_SUB_FUNCT);
assign dec_r_and = dec_is_rtype && ({Funct7, Funct3} == `INSTR_AND_FUNCT);
assign dec_r_or  = dec_is_rtype && ({Funct7, Funct3} == `INSTR_OR_FUNCT);
assign dec_r_xor = dec_is_rtype && ({Funct7, Funct3} == `INSTR_XOR_FUNCT);
assign dec_r_sll = dec_is_rtype && ({Funct7, Funct3} == `INSTR_SLL_FUNCT);
assign dec_r_srl = dec_is_rtype && ({Funct7, Funct3} == `INSTR_SRL_FUNCT);
assign dec_r_sra = dec_is_rtype && ({Funct7, Funct3} == `INSTR_SRA_FUNCT);
assign dec_r_valid = dec_r_add || dec_r_sub || dec_r_and || dec_r_or ||
                     dec_r_xor || dec_r_sll || dec_r_srl || dec_r_sra;

assign dec_i_addi = dec_is_itype && (Funct3 == `INSTR_ADDI_FUNCT);
assign dec_i_ori  = dec_is_itype && (Funct3 == `INSTR_ORI_FUNCT);
assign dec_i_valid = dec_i_addi || dec_i_ori;

assign id_is_beq = (ID_opcode == `INSTR_BTYPE_OP) && (ID_Funct3 == `INSTR_BEQ_FUNCT);
assign id_is_bne = (ID_opcode == `INSTR_BTYPE_OP) && (ID_Funct3 == `INSTR_BNE_FUNCT);
assign id_take_branch = (id_is_beq && ID_zero) || (id_is_bne && !ID_zero);

// RFWrite only needs opcode-class knowledge on the hot timing path.
assign if_dec_rfwrite = dec_is_rtype || dec_is_itype || dec_is_lw || dec_is_jal || dec_is_jalr;
assign if_dec_dmctrl = dec_is_sw ? `DMCtrl_WR : `DMCtrl_RD;
assign if_dec_alusrcb = (dec_i_valid || dec_is_jalr) ? `ALUSrcB_Imm :
                        ((dec_is_lw || dec_is_sw) ? `ALUSrcB_Offset : `ALUSrcB_B);
assign if_dec_wdsel = dec_is_lw ? `WDSel_FromMEM :
                      ((dec_is_jal || dec_is_jalr) ? `WDSel_FromPC : `WDSel_FromALU);
assign if_dec_aluop[0] = dec_is_btype ||
                         dec_i_ori ||
                         (dec_is_rtype && (
                             ((Funct3 == 3'b000) && Funct7[5]) ||
                             (Funct3 == 3'b110) ||
                             (Funct3 == 3'b101)
                         ));
assign if_dec_aluop[1] = dec_i_ori ||
                         (dec_is_rtype && ((Funct3 == 3'b111) || (Funct3 == 3'b110)));
assign if_dec_aluop[2] = dec_is_rtype &&
                         Funct3[2] &&
                         !Funct3[1] &&
                         (!Funct3[0] || Funct7[5]);
assign if_dec_aluop[3] = dec_is_rtype &&
                         !Funct3[1] &&
                         Funct3[0] &&
                         (!Funct3[2] || !Funct7[5]);

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
    PC_NPC          = EX_branch ? NPC_taken_p4 : IF_stall ? IF_PCA4 : NPC_NPC;
    // Drive the EX-stage base PC directly so branch only acts as a final select,
    // not as a control input to the NPC adder cone.
    NPC_PC          = EX_PC;
    FETCH_PC        = IM_PC;
    NPC_EX_Offset20 = EX_Offset20;
    NPC_EX_Offset12 = EX_Offset;
    MUX_WB_rd       = WB_rd;
    EXT_ID_Imm12    = ID_Imm12;
    forward1        = (WBID_forward1 || MEMID_forward1);
    forward2        = (WBID_forward2 || MEMID_forward2);
    FD1             = ID_RD1;
    FD2             = ID_RD2;
    ALU_B_Imm       = EX_ALU_B_sel;
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
    IF_PCWrite  = 1'b1;
    IF_InsMemRW = 1'b1;
    IF_IRWrite  = 1'b1;
    IF_RFWrite  = if_dec_rfwrite;
    IF_DMCtrl   = if_dec_dmctrl;
    IF_ExtSel   = `ExtSel_SIGNED;
    IF_ALUSrcA  = `ALUSrcA_A;
    IF_ALUSrcB  = if_dec_alusrcb;
    IF_RegSel   = `RegSel_rd;
    IF_WDSel    = if_dec_wdsel;
    IF_ALUOp    = if_dec_aluop;
end

// Hazard detect in ID using only registered instruction fields.
// This keeps the raw IM output out of the fetch-address feedback loop.
assign pipe_flush = EX_branch;
assign ID_use_rs1 = (ID_opcode == `INSTR_RTYPE_OP) ||
                    (ID_opcode == `INSTR_ITYPE_OP) ||
                    (ID_opcode == `INSTR_LW_OP)    ||
                    (ID_opcode == `INSTR_SW_OP)    ||
                    (ID_opcode == `INSTR_BTYPE_OP) ||
                    (ID_opcode == `INSTR_JALR_OP);
assign ID_use_rs2 = (ID_opcode == `INSTR_RTYPE_OP) ||
                    (ID_opcode == `INSTR_SW_OP)    ||
                    (ID_opcode == `INSTR_BTYPE_OP);
assign ID_dep_EX  = (((ID_use_rs1 && (ID_rs1 == EX_rd)) || (ID_use_rs2 && (ID_rs2 == EX_rd))) &&
                     (EX_RFWrite == 1'b1) && (EX_rd != 5'b0));
assign ID_dep_MEM = (((ID_use_rs1 && (ID_rs1 == MEM_rd)) || (ID_use_rs2 && (ID_rs2 == MEM_rd))) &&
                     (MEM_DMReadStall == 1'b1) && (MEM_rd != 5'b0));
assign ID_dep_MEMSTALL = (((ID_use_rs1 && (ID_rs1 == MEMStall_rd)) || (ID_use_rs2 && (ID_rs2 == MEMStall_rd))) &&
                          (MEMStall_stall == 1'b1) && (MEMStall_rd != 5'b0));
assign load_pipe_busy = ((EX_RFWrite == 1'b1) && (EX_WDSel == `WDSel_FromMEM)) ||
                        (MEM_DMReadStall == 1'b1) ||
                        (MEMStall_stall == 1'b1);
assign IF_stall   = (pipe_flush != 1'b1) && (load_pipe_busy || ID_dep_EX || ID_dep_MEM || ID_dep_MEMSTALL);

assign IM_PC   = EX_branch ? NPC_NPC : IF_stall ? IF_PC : PC;

assign ID_Imm32_local    = {{20{ID_Imm12[11]}}, ID_Imm12};
assign ID_Offset32_local = {{20{ID_Offset[11]}}, ID_Offset};



/* ################################ ID ################################ */

// ID stage forward

// read and write RF at the same cycle
assign WBID_forward1 = (ID_rs1 == WB_rd) && (WB_RFWrite == 1'b1) && (WB_rd != 5'b0);
assign WBID_forward2 = (ID_rs2 == WB_rd) && (WB_RFWrite == 1'b1) && (WB_rd != 5'b0);

// EX to 2nd
assign MEMID_forward1 = (ID_rs1 == MEM_rd) && (MEM_RFWrite == 1'b1) && (MEM_WDSel == `WDSel_FromALU) && (MEM_rd != 5'b0);
assign MEMID_forward2 = (ID_rs2 == MEM_rd) && (MEM_RFWrite == 1'b1) && (MEM_WDSel == `WDSel_FromALU) && (MEM_rd != 5'b0);

// forwarding
assign ID_RD1 = (MEMID_forward1 ? ALU_result_r : (WBID_forward1 ? WB_WD : 32'h0));
assign ID_RD2 = (MEMID_forward2 ? ALU_result_r : (WBID_forward2 ? WB_WD : 32'h0));

assign ID_zero = (RD1 == RD2);

Flopr #(.WIDTH(7)) U_IFID_opcode (.clk(clk), .rst(rst), .in_data(pipe_flush ? 7'b0 : (IF_stall ? ID_opcode : opcode)), .out_data(ID_opcode));
Flopr #(.WIDTH(3)) U_IFID_Funct3 (.clk(clk), .rst(rst), .in_data(pipe_flush ? 3'b0 : (IF_stall ? ID_Funct3 : Funct3)), .out_data(ID_Funct3));


always @(*) begin
    ID_NPCOp = `NPC_PC;
    if (id_take_branch) begin
        ID_NPCOp = `NPC_Offset12;
    end
    else if (ID_opcode == `INSTR_JAL_OP) begin
        ID_NPCOp = `NPC_Offset20;
    end
    else if (ID_opcode == `INSTR_JALR_OP) begin
        ID_NPCOp = `NPC_rs;
    end
end

always @(*) begin
    case (ID_ALUSrcB)
        `ALUSrcB_B     : ID_ALU_B_sel = RD2;
        `ALUSrcB_Imm   : ID_ALU_B_sel = ID_Imm32_local;
        `ALUSrcB_Offset: ID_ALU_B_sel = ID_Offset32_local;
        default        : ID_ALU_B_sel = RD2;
    endcase
end

Flopr #(.WIDTH(1)) U_branch (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 1'b0 : (ID_NPCOp != `NPC_PC)), .out_data(EX_branch));
Flopr #(.WIDTH(2)) U_NPCOp (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? `NPC_PC : ID_NPCOp), .out_data(EX_NPCOp));

/* ################################ EX ################################ */

/* ################################ MEM ################################ */

assign MEM_DMReadStall = MEM_RFWrite == 1'b1 && MEM_WDSel == `WDSel_FromMEM;

/* ################################ WB ################################ */


/* #################################### pipeline #################################### */

Flopr #(.WIDTH(1))  U_IF_done (.clk(clk), .rst(rst), .in_data(1'b1), .out_data(IF_done));
Flopr #(.WIDTH(32)) U_IF_PC   (.clk(clk), .rst(rst), .in_data(IF_stall ? IF_PC : (EX_branch ? IM_PC : PC))  , .out_data(IF_PC)  );
Flopr #(.WIDTH(32)) U_IF_PCA4 (.clk(clk), .rst(rst), .in_data(IF_stall ? IF_PCA4 : (EX_branch ? NPC_taken_p4 : PCA4)), .out_data(IF_PCA4));

/* IF -> ID */

Flopr #(.WIDTH(32))  U_IFID_PCA4 (.clk(clk), .rst(rst), .in_data(pipe_flush ? 32'b0 : (IF_stall ? ID_PCA4 : IF_PCA4)), .out_data(ID_PCA4));
Flopr #(.WIDTH(32))  U_IFID_PC   (.clk(clk), .rst(rst), .in_data(pipe_flush ? 32'b0 : (IF_stall ? ID_PC   : IF_PC  )), .out_data(ID_PC)  );

Flopr #(.WIDTH(12))  U_IFID_Imm12 (.clk(clk), .rst(rst), .in_data(pipe_flush ? 12'b0 : (IF_stall ? ID_Imm12 : Imm12 )), .out_data(ID_Imm12) );
Flopr #(.WIDTH(12))  U_IFID_Offet (.clk(clk), .rst(rst), .in_data(pipe_flush ? 12'b0 : (IF_stall ? ID_Offset : Offset)), .out_data(ID_Offset));

Flopr #(.WIDTH(5) )  U_IFID_rs1 (.clk(clk), .rst(rst), .in_data(pipe_flush ? 5'b0 : (IF_stall ? ID_rs1 : rs1)), .out_data(ID_rs1));
Flopr #(.WIDTH(5) )  U_IFID_rs2 (.clk(clk), .rst(rst), .in_data(pipe_flush ? 5'b0 : (IF_stall ? ID_rs2 : rs2)), .out_data(ID_rs2));
Flopr #(.WIDTH(5) )  U_IFID_rd  (.clk(clk), .rst(rst), .in_data(pipe_flush ? 5'b0 : (IF_stall ? ID_rd  : rd )), .out_data(ID_rd) );

Flopr #(.WIDTH(4) )  U_IFID_ALUOp (.clk(clk), .rst(rst), .in_data(pipe_flush ? 4'b0 : (IF_stall ? ID_ALUOp : IF_ALUOp)), .out_data(ID_ALUOp));

Flopr #(.WIDTH(2) )  U_IFID_Regsel  (.clk(clk), .rst(rst), .in_data(pipe_flush ? 2'b0 : (IF_stall ? ID_Regsel  : IF_RegSel )), .out_data(ID_Regsel) );
Flopr #(.WIDTH(2) )  U_IFID_ALUSrcB (.clk(clk), .rst(rst), .in_data(pipe_flush ? 2'b0 : (IF_stall ? ID_ALUSrcB : IF_ALUSrcB)), .out_data(ID_ALUSrcB));
Flopr #(.WIDTH(2) )  U_IFID_WDSel   (.clk(clk), .rst(rst), .in_data(pipe_flush ? 2'b0 : (IF_stall ? ID_WDSel   : IF_WDSel  )), .out_data(ID_WDSel)  );

Flopr #(.WIDTH(1) )  U_IFID_ALUSrcA (.clk(clk), .rst(rst), .in_data(pipe_flush ? 1'b0 : (IF_stall ? ID_ALUSrcA : IF_ALUSrcA)), .out_data(ID_ALUSrcA));
Flopr #(.WIDTH(1) )  U_IFID_RFWrite (.clk(clk), .rst(rst), .in_data(pipe_flush ? 1'b0 : (IF_stall ? ID_RFWrite : IF_RFWrite)), .out_data(ID_RFWrite));
Flopr #(.WIDTH(1) )  U_IFID_DMCtrl  (.clk(clk), .rst(rst), .in_data(pipe_flush ? 1'b0 : (IF_stall ? ID_DMCtrl  : IF_DMCtrl )), .out_data(ID_DMCtrl) );

Flopr #(.WIDTH(1) )  U_IFID_done (.clk(clk), .rst(rst), .in_data(pipe_flush ? 1'b0 : (IF_stall ? ID_done : IF_done)), .out_data(ID_done));

// NPC
Flopr #(.WIDTH(12))  U_IFID_Offset12 (.clk(clk), .rst(rst), .in_data(pipe_flush ? 12'b0 : (IF_stall ? ID_Offset12 : Offset)), .out_data(ID_Offset12));
Flopr #(.WIDTH(20))  U_IFID_Offset20 (.clk(clk), .rst(rst), .in_data(pipe_flush ? 20'b0 : (IF_stall ? ID_Offset20 : Offset20)), .out_data(ID_Offset20));

/* ID -> EX */

Flopr #(.WIDTH(32))  U_IDEX_Imm32 (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 32'b0 : Imm32)  , .out_data(EX_Imm32));
Flopr #(.WIDTH(32))  U_IDEX_PCA4  (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 32'b0 : ID_PCA4), .out_data(EX_PCA4) );
Flopr #(.WIDTH(32))  U_IDEX_PC    (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 32'b0 : ID_PC)  , .out_data(EX_PC)   );
Flopr #(.WIDTH(32))  U_IDEX_ALU_B (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 32'b0 : ID_ALU_B_sel), .out_data(EX_ALU_B_sel));

Flopr #(.WIDTH(12))  U_IDEX_Offset (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 12'b0 : ID_Offset), .out_data(EX_Offset));

Flopr #(.WIDTH(5) )  U_IDEX_rd (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 5'b0 : ID_rd), .out_data(EX_rd));

Flopr #(.WIDTH(4) )  U_IDEX_ALUOp (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 4'b0 : ID_ALUOp), .out_data(EX_ALUOp));

Flopr #(.WIDTH(2) )  U_IDEX_Regsel  (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 2'b0 : ID_Regsel) , .out_data(EX_Regsel) );
Flopr #(.WIDTH(2) )  U_IDEX_ALUSrcB (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 2'b0 : ID_ALUSrcB), .out_data(EX_ALUSrcB));
Flopr #(.WIDTH(2) )  U_IDEX_WDSel   (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 2'b0 : ID_WDSel)  , .out_data(EX_WDSel)  );

Flopr #(.WIDTH(1) )  U_IDEX_ALUSrcA (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 1'b0 : ID_ALUSrcA), .out_data(EX_ALUSrcA));
Flopr #(.WIDTH(1) )  U_IDEX_RFWrite (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 1'b0 : ID_RFWrite), .out_data(EX_RFWrite));
Flopr #(.WIDTH(1) )  U_IDEX_DMCtrl  (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 1'b0 : ID_DMCtrl) , .out_data(EX_DMCtrl) );

Flopr #(.WIDTH(20))  U_IDEX_Offset20 (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 20'b0 : ID_Offset20), .out_data(EX_Offset20));

Flopr #(.WIDTH(1) )  U_IDEX_done (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 1'b0 : ID_done), .out_data(EX_done));

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

Flopr #(.WIDTH(32)) U_IFID_dnpc     (.clk(clk), .rst(rst), .in_data(pipe_flush ? 32'b0 : (IF_stall ? ID_dnpc : IF_PCA4)), .out_data(ID_dnpc)      );
Flopr #(.WIDTH(32)) U_IDEX_dnpc     (.clk(clk), .rst(rst), .in_data((pipe_flush || IF_stall) ? 32'b0 : ID_dnpc)         , .out_data(EX_dnpc)      );
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



module DM(Addr, WD, clk, DMCtrl, RD, DM_WD);
    input  [11:2] Addr;
    input  [31:0] WD;
    input         clk;
    input         DMCtrl;
    output reg [31:0] RD;

    input [31:0] DM_WD;

`ifndef SRAM

    reg [31:0] memory[0:1023];

    always @(posedge clk) begin
        if (DMCtrl) begin
            memory[Addr] <= DM_WD;
        end
        else begin
            RD <= memory[Addr];
        end
    end

`endif

`ifdef SRAM

    wire [63:0] sram_out;

    TS1N65LPLL2048X64M8 memory (
        .CLK(clk),
        .CEB(1'b0),
        .WEB(~DMCtrl),
        .A({1'b0, Addr}),
        .D({32'b0, DM_WD}),
        .BWEB(64'b0),
        .Q(sram_out),
        .TSEL(2'b01)
    );

    always @(*) RD = sram_out[31:0];

`endif

endmodule



module EXT(imm_in, ExtSel, imm_out, EXT_Imm12);
    input  [11:0] imm_in;
    input         ExtSel;
    output reg [31:0] imm_out;

    input [11:0] EXT_Imm12;

    always @(*) begin
        case(ExtSel)
            `ExtSel_ZERO  : imm_out = {20'b0, EXT_Imm12[11:0]};
            `ExtSel_SIGNED: imm_out = {EXT_Imm12[11] ? 20'hfffff : 20'h00000, EXT_Imm12[11:0]};
            default       : imm_out = 32'b0;
        endcase
    end

endmodule



module Flopr #(parameter WIDTH = 32)(clk, rst, in_data, out_data);
    input         clk;
    input         rst;
    input  [WIDTH-1:0] in_data;
    output reg [WIDTH-1:0] out_data;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_data <= {WIDTH{1'b0}};
        end
        else begin
            out_data <= in_data;
        end
    end

endmodule


`timescale 1ns / 1ps

module IM(clk, rst, InsMemRW, addr,Ins, IM_addr, branch);
    input           clk;
    input           InsMemRW;
    input   [11:2]  addr;
    input           rst;
    output reg [31:0] Ins;

    input [11:2] IM_addr;
    input branch;

    wire [9:0] address;
    assign address = IM_addr;

`ifndef SRAM

    reg [31:0] memory[0:1023];

    `ifdef DIFFTEST
    import "DPI-C" function int instFetch(input int addr);
    `endif

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Ins <= 32'b0;
        end
        else begin
            `ifdef DIFFTEST
            Ins <= InsMemRW ? instFetch({20'h00002, address, 2'b00}) : Ins;
            `endif
            
            `ifndef DIFFTEST
            `ifndef SYNTHESIS
            Ins <= InsMemRW ? memory[address] : Ins;
            `endif
            `endif
        end
    end

`endif

`ifdef SRAM

    wire [63:0] sram_out;

    TS1N65LPLL2048X64M8 memory (
        .CLK(clk),
        .CEB(~InsMemRW),
        .WEB(1'b1),
        .A({1'b0, address}),
        .D(64'b0),
        .BWEB(64'b0),
        .Q(sram_out),
        .TSEL(2'b01)
    );

    always @(*) Ins = sram_out[31:0];

`endif


endmodule



module IR(in_ins, IRWrite, out_ins);

    input         IRWrite;
    input  [31:0] in_ins;
    output reg [31:0] out_ins;

    // IR stays combinational, but IRWrite is not functionally used in the
    // current pipeline control, so bypass the extra gate on the decode path.
    assign out_ins = in_ins;

endmodule




module MUX_2to1_A(X,Y,control,out);
    input  [31:0] X;
    input  [4:0]  Y;
    input         control;
    output [31:0] out;

    // In the current CPU microarchitecture ALUSrcA never selects the legacy
    // shift-amount path, so keep the interface intact but remove the extra mux
    // level from the ALU A-input critical path.
    assign out = X;

endmodule



module MUX_3to1_B(X,Y,Z,control,out, Imm, Offset);
    input  [31:0] X;
    input  [31:0] Y;
    input  [11:0] Z;
    input  [1:0]  control;
    output reg signed [31:0] out;

    input [31:0] Imm;
    input [11:0] Offset;

    always @(*) begin
        
        out = Imm;
    end

endmodule

`timescale 1ns / 1ps



module MUX_3to1_LMD(X,Y,Z,control,out,PCA4);
    input  [31:0] X;
    input  [31:0] Y;
    input  [31:0] Z;
    input  [1:0]  control;
    output reg [31:0] out;

    input [31:0] PCA4;

    always @(*) begin
        case(control)
            `WDSel_FromALU : out = X;
            `WDSel_FromMEM : out = Y;
            `WDSel_FromPC  : out = PCA4;
            `WDSel_Else    : out = 0;
        endcase
    end

endmodule



module MUX_3to1(X,Y,Z,control,out, rd);
    input  [4:0] X;
    input  [4:0] Y;
    input  [4:0] Z;
    input  [1:0] control;
    output reg [4:0] out;

    input [4:0] rd;

    always @(*) begin
        case(control)
            `RegSel_rd  : out = rd;
            `RegSel_rt  : out = Y;
            `RegSel_31  : out = Z;
            `RegSel_else: out = 0;
        endcase
    end

endmodule


module NPC(NPCOp, Offset12, Offset20, PC, rs, PCA4, NPC, NPC_PC, NPC_Offset12, NPC_Offset20, NPC_rs, NPC_taken_p4);
    input  [1:0]  NPCOp;
    input  [12:1] Offset12;
    input  [20:1] Offset20;
    input  [31:0] PC;
    input  [31:0] rs;
    output reg [31:0] PCA4;
    output reg [31:0] NPC;
    output reg [31:0] NPC_taken_p4;
    
    input [31:0] NPC_PC;
    input [12:1] NPC_Offset12;
    input [20:1] NPC_Offset20;
    input [31:0] NPC_rs;

wire signed [12:0] Offset13;
wire signed [20:0] Offset21;
wire signed [31:0] Imm12Ext;
wire signed [31:0] Imm12ExtP4;
wire [31:0] rs_aligned;
wire signed [31:0] Offset12ShiftExt;
wire signed [31:0] Offset20ShiftExt;
wire signed [31:0] Offset12ShiftExtP4;
wire signed [31:0] Offset20ShiftExtP4;
wire [31:0] jalr_target;
wire [31:0] jalr_target_p4;
wire signed [31:0] npc_offset12_taken;
wire signed [31:0] npc_offset20_taken;
wire signed [31:0] npc_offset12_taken_p4;
wire signed [31:0] npc_offset20_taken_p4;
wire [31:0] seq_pc_plus4;
wire [31:0] ex_pc_plus8;

assign Offset13 = $signed({NPC_Offset12[12:1], 1'b0});
assign Offset21 = $signed({NPC_Offset20[20:1], 1'b0});
assign Imm12Ext = {{20{NPC_Offset12[12]}}, NPC_Offset12[12:1]};
assign Imm12ExtP4 = Imm12Ext + 32'sd4;
assign rs_aligned = {NPC_rs[31:2], 2'b0};
assign Offset12ShiftExt = {{19{Offset13[12]}}, Offset13};
assign Offset20ShiftExt = {{11{Offset21[20]}}, Offset21};
assign Offset12ShiftExtP4 = Offset12ShiftExt + 32'sd4;
assign Offset20ShiftExtP4 = Offset20ShiftExt + 32'sd4;
assign jalr_target = (rs_aligned + Imm12Ext) & 32'hffff_fffe;
assign jalr_target_p4 = (rs_aligned + Imm12ExtP4) & 32'hffff_fffe;
assign seq_pc_plus4 = PC + 32'd4;
assign ex_pc_plus8 = NPC_PC + 32'd8;
assign npc_offset12_taken = $signed(NPC_PC) + Offset12ShiftExt;
assign npc_offset20_taken = $signed(NPC_PC) + Offset20ShiftExt;
assign npc_offset12_taken_p4 = $signed(NPC_PC) + Offset12ShiftExtP4;
assign npc_offset20_taken_p4 = $signed(NPC_PC) + Offset20ShiftExtP4;

always @(*) begin
    case(NPCOp)
        `NPC_PC       : NPC = seq_pc_plus4;
        `NPC_Offset12 : NPC = npc_offset12_taken;
        `NPC_rs       : NPC = NPC_rs;
        `NPC_Offset20 : NPC = npc_offset20_taken;
        default       : NPC = seq_pc_plus4;
    endcase

    // Added logic only: keep original case items unchanged, then refine jalr target.
    if (NPCOp == `NPC_rs) begin
        NPC = jalr_target;
    end

    case (NPCOp)
        `NPC_Offset12 : NPC_taken_p4 = npc_offset12_taken_p4;
        `NPC_Offset20 : NPC_taken_p4 = npc_offset20_taken_p4;
        `NPC_rs       : NPC_taken_p4 = jalr_target_p4;
        `NPC_PC       : NPC_taken_p4 = ex_pc_plus8;
        default       : NPC_taken_p4 = seq_pc_plus4;
    endcase

    PCA4 = seq_pc_plus4;
end


endmodule


`timescale 1ns / 1ps



module PC(clk, rst, PCWrite, NPC, PC, branch, stall, PC_NPC);
    input  clk;
    input  rst;
    input  PCWrite;
    input  [31:0] NPC;
    output reg [31:0] PC;

    input        branch;
    input        stall;
    input [31:0] PC_NPC;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        PC <= 32'h0000_2000;
    end
    else if (PCWrite) begin
        // PC_NPC is already the final next-PC value from the control pipeline.
        PC <= PC_NPC;
    end

end

 
endmodule



module RF(
input [4:0] RR1,
input [4:0] RR2,
input [4:0] WR,
input [31:0] WD,
input RFWrite,
input clk,
output [31:0] RD1,
output [31:0] RD2,

input [4:0] RF_RR1,
input [4:0] RF_RR2,
input forward1,
input forward2,
input [31:0] FD1,  // forward data
input [31:0] FD2,
input [31:0] RF_WD
);

reg [31:0] register [0:31];

always @(posedge clk) begin
  register[0] <= 32'h0;
  if ((WR != 0) && (RFWrite == 1)) begin
    register[WR] <= RF_WD;
`ifdef DEBUG
    $display("R[00-07]=%8X %8X %8X %8X %8X %8X %8X %8X", 0, register[1], register[2], register[3], register[4], register[5], register[6], register[7]);
    $display("R[08-15]=%8X %8X %8X %8X %8X %8X %8X %8X", register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15]);
    $display("R[16-23]=%8X %8X %8X %8X %8X %8X %8X %8X", register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23]);
    $display("R[24-31]=%8X %8X %8X %8X %8X %8X %8X %8X", register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
`endif
  end
end

assign RD1 = forward1 ? FD1 : register[RF_RR1];
assign RD2 = forward2 ? FD2 : register[RF_RR2];

`ifdef DIFFTEST

export "DPI-C" function DPI_getReg;
function int DPI_getReg(input int idx);
  return register[idx];
endfunction

`endif

endmodule