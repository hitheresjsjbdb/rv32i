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
