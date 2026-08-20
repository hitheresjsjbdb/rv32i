`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"
`include "global_def.v"

module ControlUnit(
    // control signal
    input rst,
    input clk,
    input [6:0] opcode,
    input [6:0] Funct7,
    input [2:0] Funct3,
    output reg PCWrite,
    output reg InsMemRW,
    output reg RFWrite,
    output reg DMCtrl,
    output reg [1:0] NPCOp,
    output reg [3:0] ALUOp,

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
    input [31:0] ALU_result,
    input [31:0] ALU_result_r,
    input [31:0] DM_RD,
    input [31:0] RD2_r,
    input        IF_ready,
    input        IF_error,
    input        DM_ready,
    input        DM_error,

    output reg mem_hold,
    output reg [31:0] PC_NPC,
    output reg [31:0] NPC_PC,
    output reg [31:0] FETCH_PC,
    output reg [19:0] NPC_EX_Offset20,
    output reg [11:0] NPC_EX_Offset12,
    output reg [4:0] WB_rd_out,
    output reg forward1,
    output reg forward2,
    output reg [31:0] FD1,
    output reg [31:0] FD2,
    output reg [31:0] EX_ALU_B,
    output reg [31:0] RF_WD,
    output reg [31:0] DM_WD,
    output wire       DMReq,
    output reg [4:0]  ID_rs1_out,
    output reg [4:0]  ID_rs2_out,
    output wire        trap,
    output wire [3:0]  trap_cause,
    output wire [31:0] trap_epc,
    output wire [31:0] trap_tval

    `ifdef DIFFTEST
    , output done
    `endif


);

`ifdef DIFFTEST
Flopr #(.WIDTH(1)) U_done (.clk(clk), .rst(rst), .in_data(WB_valid), .out_data(done));
`endif


/* #################################### pipeline signals #################################### */

/* IF */

wire        IF_stall;
wire [31:0] NPC_NPC, IM_PC;
reg  [3:0]  IF_ALUOp;
reg  [1:0]  IF_ALUSrcB, IF_WDSel;
reg         IF_RFWrite, IF_DMCtrl, IF_PCWrite, IF_InsMemRW;


/* ID */
wire [31:0] ID_PCA4, ID_RD1, ID_RD2, ID_PC;
wire [11:0] ID_Imm12, ID_Offset;
wire [4:0]  ID_rs1, ID_rs2, ID_rd;
wire [3:0]  ID_ALUOp;
wire [1:0]  ID_ALUSrcB, ID_WDSel;
wire        ID_RFWrite, ID_DMCtrl;
wire        ID_valid;
wire        forward1_i, forward2_i;
wire        ID_zero;
wire [6:0]  ID_opcode;
wire [2:0]  ID_Funct3;
wire [31:0] ID_ins;
wire        ID_illegal;
reg  [1:0]  ID_NPCOp;

wire [19:0] ID_Offset20;

/* EX */
wire [31:0] EX_PCA4, EX_PC;
wire [19:0] EX_Offset20;
wire [11:0] EX_Offset;
wire [3:0]  EX_ALUOp;
wire [4:0]  EX_rd;
wire [1:0]  EX_WDSel, EX_NPCOp;
wire        EX_RFWrite, EX_DMCtrl;
wire        EX_valid;
wire        EX_branch;
wire        EX_redirect;
wire        EX_redirect_wait;

/* MEM */
wire [31:0] MEM_WD, MEM_PCA4;
wire [31:0] MEM_writeback_data;
wire [4:0]  MEM_rd;
wire [1:0]  MEM_WDSel;
wire        MEM_RFWrite, MEM_DMCtrl;
wire        MEM_valid;

/* WB */
wire [31:0] WB_WD;
wire [4:0]  WB_rd;
wire        WB_RFWrite;
wire        WB_valid;
wire        pipe_flush;
wire        dec_valid;
wire        if_illegal;
wire        EX_exception;
wire        trap_request;
wire        EX_to_MEM_kill;
wire        IF_access_fault;
wire        ID_access_fault;
wire        MEM_access_fault;
wire        MEM_bus_wait;
wire        front_hazard_stall;
wire        IF_accept;
wire        IF_stage_valid;
wire [31:0] IF_stage_PC;
wire [31:0] IF_stage_PCA4;
wire [31:0] ID_Imm32_local;
wire [31:0] ID_Offset32_local;
reg  [31:0] ID_ALU_B_sel;
wire [31:0] EX_ALU_B_sel;
wire [31:0] MEM_PC;
wire        id_is_beq;
wire        id_is_bne;
wire        id_take_branch;
wire        if_dec_rfwrite;
wire        if_dec_dmctrl;
wire [1:0]  if_dec_alusrcb;
wire [1:0]  if_dec_wdsel;
wire [3:0]  if_dec_aluop;

InstructionDecoder U_InstructionDecoder (
    .opcode(opcode),
    .Funct7(Funct7),
    .Funct3(Funct3),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .dec_valid(dec_valid),
    .rfwrite(if_dec_rfwrite),
    .dmctrl(if_dec_dmctrl),
    .alusrcb(if_dec_alusrcb),
    .wdsel(if_dec_wdsel),
    .aluop(if_dec_aluop)
);

assign if_illegal = IF_stage_valid && !dec_valid;

assign IF_stage_valid = IF_accept;
assign IF_stage_PC    = IM_PC;
assign IF_stage_PCA4  = PCA4;

assign id_is_beq = (ID_opcode == `INSTR_BTYPE_OP) && (ID_Funct3 == `INSTR_BEQ_FUNCT);
assign id_is_bne = (ID_opcode == `INSTR_BTYPE_OP) && (ID_Funct3 == `INSTR_BNE_FUNCT);
assign id_take_branch = (id_is_beq && ID_zero) || (id_is_bne && !ID_zero);

assign IF_accept             = InsMemRW && IF_ready;
assign IF_access_fault       = IF_accept && IF_error;

ExceptionUnit U_ExceptionUnit (
    .clk(clk),
    .rst(rst),
    .id_valid(ID_valid),
    .id_pc(ID_PC),
    .id_ins(ID_ins),
    .id_illegal(ID_illegal),
    .id_access_fault(ID_access_fault),
    .ex_valid(EX_valid),
    .ex_branch(EX_branch),
    .ex_pc(EX_PC),
    .ex_rfwrite(EX_RFWrite),
    .ex_wdsel(EX_WDSel),
    .ex_dmctrl(EX_DMCtrl),
    .ex_alu_result(ALU_result),
    .redirect_target(NPC),
    .mem_valid(MEM_valid),
    .mem_pc(MEM_PC),
    .mem_wdsel(MEM_WDSel),
    .mem_dmctrl(MEM_DMCtrl),
    .mem_address(ALU_result_r),
    .dm_ready(DM_ready),
    .dm_error(DM_error),
    .ex_exception(EX_exception),
    .mem_access_fault(MEM_access_fault),
    .mem_bus_wait(MEM_bus_wait),
    .trap_request(trap_request),
    .ex_redirect_wait(EX_redirect_wait),
    .ex_redirect(EX_redirect),
    .dm_req(DMReq),
    .trap(trap),
    .trap_cause(trap_cause),
    .trap_epc(trap_epc),
    .trap_tval(trap_tval)
);

/* ******************************** Outputs ******************************** */

always @(*) begin
    PCWrite         = IF_PCWrite && !trap && !trap_request &&
                      !MEM_bus_wait &&
                      (EX_redirect || (!front_hazard_stall && IF_ready));
    InsMemRW        = IF_InsMemRW && !trap && !trap_request &&
                      !MEM_bus_wait && !front_hazard_stall;
    RFWrite         = WB_RFWrite;
    DMCtrl          = MEM_DMCtrl;
    ALUOp           = EX_ALUOp;
    NPCOp           = EX_NPCOp;

    mem_hold        = MEM_bus_wait || EX_redirect_wait;
    // The redirect cycle flushes IF/ID. Keep PC at the target so the target
    // instruction is accepted on the following cache-response cycle.
    PC_NPC          = NPC_NPC;
    // Drive the EX-stage base PC directly so branch only acts as a final select,
    // not as a control input to the NPC adder cone.
    NPC_PC          = EX_PC;
    FETCH_PC        = IM_PC;
    NPC_EX_Offset20 = EX_Offset20;
    NPC_EX_Offset12 = EX_Offset;
    WB_rd_out       = WB_rd;
    forward1        = forward1_i;
    forward2        = forward2_i;
    FD1             = ID_RD1;
    FD2             = ID_RD2;
    EX_ALU_B        = EX_ALU_B_sel;
    RF_WD           = WB_WD;
    DM_WD           = MEM_WD;
    ID_rs1_out      = ID_rs1;
    ID_rs2_out      = ID_rs2;
end


/* ******************************** Pipeline Stages ******************************** */

/* ################################ IF ################################ */

assign NPC_NPC = NPC;

// decode
always @(*) begin
    IF_PCWrite  = 1'b1;
    IF_InsMemRW = 1'b1;
    IF_RFWrite  = if_dec_rfwrite;
    IF_DMCtrl   = if_dec_dmctrl;
    IF_ALUSrcB  = if_dec_alusrcb;
    IF_WDSel    = if_dec_wdsel;
    IF_ALUOp    = if_dec_aluop;
end

// Hazard detect in ID using only registered instruction fields.
// This keeps the raw IM output out of the fetch-address feedback loop.
assign pipe_flush = EX_redirect || trap_request || trap;

HazardUnit U_HazardUnit (
    .id_valid(ID_valid),
    .id_opcode(ID_opcode),
    .id_rs1(ID_rs1),
    .id_rs2(ID_rs2),
    .ex_rd(EX_rd),
    .ex_valid(EX_valid),
    .ex_rfwrite(EX_RFWrite),
    .ex_wdsel(EX_WDSel),
    .mem_rd(MEM_rd),
    .mem_valid(MEM_valid),
    .mem_rfwrite(MEM_RFWrite),
    .mem_wdsel(MEM_WDSel),
    .pipe_flush(pipe_flush),
    .mem_bus_wait(MEM_bus_wait),
    .if_ready(IF_ready),
    .front_hazard_stall(front_hazard_stall),
    .if_stall(IF_stall)
);

assign IM_PC = EX_redirect ? NPC_NPC : PC;

assign ID_Imm32_local    = {{20{ID_Imm12[11]}}, ID_Imm12};
assign ID_Offset32_local = {{20{ID_Offset[11]}}, ID_Offset};



/* ################################ ID ################################ */

ForwardingUnit U_ForwardingUnit (
    .id_valid(ID_valid),
    .id_rs1(ID_rs1),
    .id_rs2(ID_rs2),
    .ex_rd(EX_rd),
    .ex_valid(EX_valid),
    .ex_rfwrite(EX_RFWrite),
    .ex_wdsel(EX_WDSel),
    .ex_pca4(EX_PCA4),
    .ex_alu_result(ALU_result),
    .mem_rd(MEM_rd),
    .mem_valid(MEM_valid),
    .mem_rfwrite(MEM_RFWrite),
    .mem_wdsel(MEM_WDSel),
    .mem_pca4(MEM_PCA4),
    .mem_alu_result(ALU_result_r),
    .wb_rd(WB_rd),
    .wb_valid(WB_valid),
    .wb_rfwrite(WB_RFWrite),
    .wb_data(WB_WD),
    .forward1(forward1_i),
    .forward2(forward2_i),
    .id_rd1(ID_RD1),
    .id_rd2(ID_RD2)
);

assign ID_zero = (RD1 == RD2);
assign ID_opcode = ID_ins[6:0];
assign ID_Funct3 = ID_ins[14:12];


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

/* ################################ EX ################################ */

/* ################################ MEM ################################ */

/* ################################ WB ################################ */

assign MEM_writeback_data =
    (MEM_WDSel == `WDSel_FromMEM) ? DM_RD :
    (MEM_WDSel == `WDSel_FromPC)  ? MEM_PCA4 : ALU_result_r;


/* #################################### pipeline #################################### */

FetchDecodeRegisters U_FetchDecodeRegisters (
    .clk(clk), .rst(rst),
    .ready(!IF_stall), .kill(pipe_flush),
    .if_stage_pc(IF_stage_PC), .if_stage_pca4(IF_stage_PCA4),
    .if_stage_valid(IF_stage_valid),
    .raw_instruction({Funct7, rs2, rs1, Funct3, rd, opcode}),
    .if_illegal(if_illegal), .if_access_fault(IF_access_fault),
    .imm12(Imm12), .offset(Offset), .offset20(Offset20),
    .rs1(rs1), .rs2(rs2), .rd(rd),
    .if_aluop(IF_ALUOp),
    .if_alusrcb(IF_ALUSrcB), .if_wdsel(IF_WDSel),
    .if_rfwrite(IF_RFWrite),
    .if_dmctrl(IF_DMCtrl),
    .id_pca4(ID_PCA4), .id_pc(ID_PC), .id_ins(ID_ins),
    .id_illegal(ID_illegal), .id_access_fault(ID_access_fault),
    .id_imm12(ID_Imm12), .id_offset(ID_Offset),
    .id_offset20(ID_Offset20),
    .id_rs1(ID_rs1), .id_rs2(ID_rs2), .id_rd(ID_rd),
    .id_aluop(ID_ALUOp),
    .id_alusrcb(ID_ALUSrcB), .id_wdsel(ID_WDSel),
    .id_rfwrite(ID_RFWrite),
    .id_dmctrl(ID_DMCtrl), .id_valid(ID_valid)
);

DecodeExecuteRegisters U_DecodeExecuteRegisters (
    .clk(clk), .rst(rst),
    .ready(!(MEM_bus_wait || EX_redirect_wait)),
    .kill(pipe_flush || IF_stall),
    .id_pca4(ID_PCA4), .id_pc(ID_PC),
    .id_alu_b(ID_ALU_B_sel), .id_offset(ID_Offset),
    .id_offset20(ID_Offset20), .id_rd(ID_rd),
    .id_aluop(ID_ALUOp), .id_wdsel(ID_WDSel),
    .id_rfwrite(ID_RFWrite),
    .id_dmctrl(ID_DMCtrl), .id_valid(ID_valid),
    .id_branch(ID_NPCOp != `NPC_PC), .id_npcop(ID_NPCOp),
    .ex_pca4(EX_PCA4), .ex_pc(EX_PC),
    .ex_alu_b(EX_ALU_B_sel), .ex_offset(EX_Offset),
    .ex_offset20(EX_Offset20), .ex_rd(EX_rd),
    .ex_aluop(EX_ALUOp), .ex_wdsel(EX_WDSel),
    .ex_rfwrite(EX_RFWrite),
    .ex_dmctrl(EX_DMCtrl), .ex_valid(EX_valid),
    .ex_branch(EX_branch), .ex_npcop(EX_NPCOp)
);

// Kill only the faulting EX instruction. Older MEM/WB instructions may retire.
assign EX_to_MEM_kill = EX_exception || MEM_access_fault;

ExecuteMemoryRegisters U_ExecuteMemoryRegisters (
    .clk(clk), .rst(rst), .ready(!MEM_bus_wait),
    .kill(EX_redirect_wait || EX_to_MEM_kill),
    .ex_store_data(RD2_r), .ex_pca4(EX_PCA4), .ex_pc(EX_PC),
    .ex_rd(EX_rd), .ex_wdsel(EX_WDSel),
    .ex_rfwrite(EX_RFWrite), .ex_dmctrl(EX_DMCtrl),
    .ex_valid(EX_valid),
    .mem_store_data(MEM_WD), .mem_pca4(MEM_PCA4),
    .mem_pc(MEM_PC), .mem_rd(MEM_rd), .mem_wdsel(MEM_WDSel),
    .mem_rfwrite(MEM_RFWrite), .mem_dmctrl(MEM_DMCtrl),
    .mem_valid(MEM_valid)
);

MemoryWritebackRegisters U_MemoryWritebackRegisters (
    .clk(clk), .rst(rst),
    .ready(!MEM_bus_wait), .kill(MEM_access_fault),
    .mem_writeback_data(MEM_writeback_data),
    .mem_rd(MEM_rd),
    .mem_rfwrite(MEM_RFWrite), .mem_valid(MEM_valid),
    .wb_data(WB_WD), .wb_rd(WB_rd),
    .wb_rfwrite(WB_RFWrite), .wb_valid(WB_valid)
);

`ifdef DIFFTEST

reg [31:0] ID_dnpc, EX_dnpc, MEM_dnpc, WB_dnpc, dnpc;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ID_dnpc       <= 32'b0;
        EX_dnpc       <= 32'b0;
        MEM_dnpc      <= 32'b0;
        WB_dnpc       <= 32'b0;
        dnpc          <= 32'b0;
    end
    else begin
        if (pipe_flush)
            ID_dnpc <= 32'b0;
        else if (!IF_stall)
            ID_dnpc <= IF_stage_PCA4;

        if (!(MEM_bus_wait || EX_redirect_wait)) begin
            if (pipe_flush || IF_stall)
                EX_dnpc <= 32'b0;
            else
                EX_dnpc <= ID_dnpc;
        end

        if (!MEM_bus_wait) begin
            if (EX_redirect_wait || EX_to_MEM_kill)
                MEM_dnpc <= 32'b0;
            else
                MEM_dnpc <= EX_redirect ? NPC_NPC : EX_dnpc;
        end

        if (MEM_bus_wait || MEM_access_fault)
            WB_dnpc <= 32'b0;
        else
            WB_dnpc <= MEM_dnpc;

        dnpc <= WB_dnpc;
    end
end

export "DPI-C" function DPI_getPC;
function int DPI_getPC();
    return dnpc;
endfunction

`endif


endmodule
