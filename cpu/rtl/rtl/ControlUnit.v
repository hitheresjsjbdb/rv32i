`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"
`include "global_def.v"

module ControlUnit(
    // control signal
    input rst,
    input clk,
    input [31:0] instruction,
    output wire PCWrite,
    output wire InsMemRW,
    output wire RFWrite,
    output wire DMCtrl,
    output wire [1:0] NPCOp,
    output wire [3:0] ALUOp,

    input [31:0] PC,
    input [31:0] PCA4,
    input [31:0] NPC,
    input [31:0] NPC_taken_p4,
    input [31:0] RD2,
    input [31:0] RD1_raw,
    input [31:0] RD2_raw,
    input [31:0] ALU_result,
    input [31:0] ALU_result_r,
    input [31:0] DM_RD,
    input [31:0] RD2_r,
    input        IF_ready,
    input        IF_error,
    input        DM_ready,
    input        DM_error,

    output wire mem_hold,
    output wire [31:0] PC_NPC,
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
Flopr #(.WIDTH(1)) U_done (
    // Inputs
    .clk(clk),
    .rst(rst),
    .in_data(WB_valid),

    // Outputs
    .out_data(done)
);
`endif


/* #################################### pipeline signals #################################### */

/* IF */

wire        IF_stall;
wire [31:0] NPC_NPC, IM_PC;
wire        IF_PCWrite, IF_InsMemRW;


/* ID */
wire [31:0] ID_PCA4, ID_RD1, ID_RD2, ID_PC;
wire [11:0] ID_Imm12, ID_Offset;
wire [4:0]  ID_rs1, ID_rs2, ID_rd;
wire [3:0]  ID_ALUOp;
wire [1:0]  ID_ALUSrcB, ID_WDSel;
wire        ID_RFWrite, ID_DMCtrl;
wire        ID_valid;
wire        forward1_i, forward2_i;
wire [31:0] ID_control_RD1, ID_control_RD2;
wire [6:0]  ID_opcode;
wire [6:0]  ID_Funct7;
wire [2:0]  ID_Funct3;
wire [31:0] ID_ins;
wire        ID_illegal;
wire [1:0]  ID_NPCOp;

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
wire        EX_redirect_predicted;
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
wire [31:0] ID_ALU_B_sel;
wire [31:0] EX_ALU_B_sel;
wire [31:0] MEM_PC;
wire        MEM_load_ready;
wire        ID_control_transfer;
wire        ID_redirect;
wire [31:0] ID_redirect_target;

`ifdef DIFFTEST
wire [31:0] perf_if_wait_cycles;
wire [31:0] perf_load_hazard_cycles;
wire [31:0] perf_mem_wait_cycles;
wire [31:0] perf_redirect_count;
wire [31:0] dnpc;
`endif

InstructionDecoder U_InstructionDecoder (
    // Inputs
    .opcode(ID_opcode),
    .Funct7(ID_Funct7),
    .Funct3(ID_Funct3),
    .rs1(ID_rs1),
    .rs2(ID_rs2),
    .rd(ID_rd),

    // Outputs
    .dec_valid(dec_valid),
    .rfwrite(ID_RFWrite),
    .dmctrl(ID_DMCtrl),
    .alusrcb(ID_ALUSrcB),
    .wdsel(ID_WDSel),
    .aluop(ID_ALUOp)
);

assign ID_illegal = ID_valid && !dec_valid;

FetchStageControl U_FetchStageControl (
    // Inputs
    .fetch_pc(IM_PC),
    .ins_mem_rw(InsMemRW),
    .if_ready(IF_ready),
    .if_error(IF_error),

    // Outputs
    .if_accept(IF_accept),
    .if_access_fault(IF_access_fault),
    .if_stage_valid(IF_stage_valid),
    .if_stage_pc(IF_stage_PC),
    .if_stage_pca4(IF_stage_PCA4)
);

MemoryResponseControl U_MemoryResponseControl (
    // Inputs
    .dm_ready(DM_ready),
    .dm_error(DM_error),

    // Outputs
    .mem_load_ready(MEM_load_ready)
);

ExceptionUnit U_ExceptionUnit (
    // Inputs
    .clk(clk),
    .rst(rst),
    .id_valid(ID_valid),
    .id_pc(ID_PC),
    .id_ins(ID_ins),
    .id_illegal(ID_illegal),
    .id_access_fault(ID_access_fault),
    .ex_valid(EX_valid),
    .ex_branch(EX_branch),
    .ex_redirect_predicted(EX_redirect_predicted),
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

    // Outputs
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

FetchAddressUnit U_FetchAddressUnit (
    // Inputs
    .pc(PC),
    .pca4(PCA4),
    .npc(NPC),
    .id_redirect_target(ID_redirect_target),
    .id_redirect(ID_redirect),
    .ex_redirect(EX_redirect),
    .trap_request(trap_request),
    .trap(trap),

    // Outputs
    .npc_npc(NPC_NPC),
    .im_pc(IM_PC),
    .pc_npc(PC_NPC),
    .pipe_flush(pipe_flush)
);

PipelineControl U_PipelineControl (
    // Inputs
    .if_pc_write(IF_PCWrite),
    .if_ins_mem_rw(IF_InsMemRW),
    .trap(trap),
    .trap_request(trap_request),
    .mem_bus_wait(MEM_bus_wait),
    .ex_redirect_wait(EX_redirect_wait),
    .ex_redirect(EX_redirect),
    .id_redirect(ID_redirect),
    .front_hazard_stall(front_hazard_stall),
    .if_ready(IF_ready),
    .wb_rf_write(WB_RFWrite),
    .mem_dm_ctrl(MEM_DMCtrl),
    .ex_alu_op(EX_ALUOp),
    .ex_npc_op(EX_NPCOp),

    // Outputs
    .pc_write(PCWrite),
    .ins_mem_rw(InsMemRW),
    .rf_write(RFWrite),
    .dm_ctrl(DMCtrl),
    .alu_op(ALUOp),
    .npc_op(NPCOp),
    .mem_hold(mem_hold)
);

/* ******************************** Outputs ******************************** */

always @(*) begin
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

assign IF_PCWrite  = 1'b1;
assign IF_InsMemRW = 1'b1;

// Hazard detect in ID using only registered instruction fields.
// This keeps the raw IM output out of the fetch-address feedback loop.

HazardUnit U_HazardUnit (
    // Inputs
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
    .mem_load_ready(MEM_load_ready),
    .pipe_flush(pipe_flush),
    .mem_bus_wait(MEM_bus_wait),
    .if_ready(IF_ready),

    // Outputs
    .front_hazard_stall(front_hazard_stall),
    .if_stall(IF_stall)
);

/* ################################ ID ################################ */

ForwardingUnit U_ForwardingUnit (
    // Inputs
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
    .mem_load_data(DM_RD),
    .mem_load_ready(MEM_load_ready),
    .wb_rd(WB_rd),
    .wb_valid(WB_valid),
    .wb_rfwrite(WB_RFWrite),
    .wb_data(WB_WD),
    .id_raw_rd1(RD1_raw),
    .id_raw_rd2(RD2_raw),

    // Outputs
    .forward1(forward1_i),
    .forward2(forward2_i),
    .id_rd1(ID_RD1),
    .id_rd2(ID_RD2),
    .id_control_rd1(ID_control_RD1),
    .id_control_rd2(ID_control_RD2)
);

InstructionFields U_IDInstructionFields (
    // Inputs
    .instruction(ID_ins),

    // Outputs
    .opcode(ID_opcode), .funct7(ID_Funct7), .funct3(ID_Funct3),
    .rs1(ID_rs1), .rs2(ID_rs2), .rd(ID_rd),
    .imm12(ID_Imm12), .offset12(ID_Offset), .offset20(ID_Offset20)
);

IDRedirectUnit U_IDRedirectUnit (
    // Inputs
    .id_valid(ID_valid),
    .opcode(ID_opcode), .funct3(ID_Funct3),
    .id_pc(ID_PC), .id_pca4(ID_PCA4),
    .imm12(ID_Imm12), .offset12(ID_Offset), .offset20(ID_Offset20),
    .control_rd1(ID_control_RD1), .control_rd2(ID_control_RD2),
    .front_hazard_stall(front_hazard_stall),
    .mem_bus_wait(MEM_bus_wait),
    .trap_request(trap_request), .trap(trap),

    // Outputs
    .npcop(ID_NPCOp),
    .control_transfer(ID_control_transfer),
    .redirect(ID_redirect), .redirect_target(ID_redirect_target)
);

IDOperandSelector U_IDOperandSelector (
    // Inputs
    .rd2(RD2),
    .imm12(ID_Imm12), .offset12(ID_Offset),
    .alusrcb(ID_ALUSrcB),

    // Outputs
    .alu_b(ID_ALU_B_sel)
);

/* ################################ EX ################################ */

/* ################################ MEM ################################ */

/* ################################ WB ################################ */

WritebackMux U_WritebackMux (
    // Inputs
    .wdsel(MEM_WDSel),
    .alu_data(ALU_result_r),
    .mem_data(DM_RD),
    .pc_data(MEM_PCA4),

    // Outputs
    .writeback_data(MEM_writeback_data)
);


/* #################################### pipeline #################################### */

FetchDecodeRegisters U_FetchDecodeRegisters (
    // Inputs
    .clk(clk),
    .rst(rst),
    .ready(!IF_stall),
    .kill(pipe_flush),
    .if_stage_pc(IF_stage_PC),
    .if_stage_pca4(IF_stage_PCA4),
    .if_stage_valid(IF_stage_valid),
    .raw_instruction(instruction),
    .if_access_fault(IF_access_fault),

    // Outputs
    .id_pca4(ID_PCA4),
    .id_pc(ID_PC),
    .id_ins(ID_ins),
    .id_access_fault(ID_access_fault),
    .id_valid(ID_valid)
);

DecodeExecuteRegisters U_DecodeExecuteRegisters (
    // Inputs
    .clk(clk),
    .rst(rst),
    .ready(!(MEM_bus_wait || EX_redirect_wait)),
    .kill(EX_redirect || trap_request || trap || IF_stall),
    .id_pca4(ID_PCA4),
    .id_pc(ID_PC),
    .id_alu_b(ID_ALU_B_sel),
    .id_offset(ID_Offset),
    .id_offset20(ID_Offset20),
    .id_rd(ID_rd),
    .id_aluop(ID_ALUOp),
    .id_wdsel(ID_WDSel),
    .id_rfwrite(ID_RFWrite),
    .id_dmctrl(ID_DMCtrl),
    .id_valid(ID_valid),
    .id_branch(ID_control_transfer),
    .id_redirect_predicted(ID_redirect),
    .id_npcop(ID_NPCOp),

    // Outputs
    .ex_pca4(EX_PCA4),
    .ex_pc(EX_PC),
    .ex_alu_b(EX_ALU_B_sel),
    .ex_offset(EX_Offset),
    .ex_offset20(EX_Offset20),
    .ex_rd(EX_rd),
    .ex_aluop(EX_ALUOp),
    .ex_wdsel(EX_WDSel),
    .ex_rfwrite(EX_RFWrite),
    .ex_dmctrl(EX_DMCtrl),
    .ex_valid(EX_valid),
    .ex_branch(EX_branch),
    .ex_redirect_predicted(EX_redirect_predicted),
    .ex_npcop(EX_NPCOp)
);

// Kill only the faulting EX instruction. Older MEM/WB instructions may retire.
assign EX_to_MEM_kill = EX_exception || MEM_access_fault;

ExecuteMemoryRegisters U_ExecuteMemoryRegisters (
    // Inputs
    .clk(clk),
    .rst(rst),
    .ready(!MEM_bus_wait),
    .kill(EX_redirect_wait || EX_to_MEM_kill),
    .ex_store_data(RD2_r),
    .ex_pca4(EX_PCA4),
    .ex_pc(EX_PC),
    .ex_rd(EX_rd),
    .ex_wdsel(EX_WDSel),
    .ex_rfwrite(EX_RFWrite),
    .ex_dmctrl(EX_DMCtrl),
    .ex_valid(EX_valid),
    // Outputs
    .mem_store_data(MEM_WD),
    .mem_pca4(MEM_PCA4),
    .mem_pc(MEM_PC),
    .mem_rd(MEM_rd),
    .mem_wdsel(MEM_WDSel),
    .mem_rfwrite(MEM_RFWrite),
    .mem_dmctrl(MEM_DMCtrl),
    .mem_valid(MEM_valid)
);

MemoryWritebackRegisters U_MemoryWritebackRegisters (
    // Inputs
    .clk(clk),
    .rst(rst),
    .ready(!MEM_bus_wait),
    .kill(MEM_access_fault),
    .mem_writeback_data(MEM_writeback_data),
    .mem_rd(MEM_rd),
    .mem_rfwrite(MEM_RFWrite),
    .mem_valid(MEM_valid),

    // Outputs
    .wb_data(WB_WD),
    .wb_rd(WB_rd),
    .wb_rfwrite(WB_RFWrite),
    .wb_valid(WB_valid)
);

`ifdef DIFFTEST

DifftestPerfCounter U_DifftestPerfCounter (
    // Inputs
    .clk(clk),
    .rst(rst),
    .trap(trap),
    .mem_bus_wait(MEM_bus_wait),
    .front_hazard_stall(front_hazard_stall),
    .if_ins_mem_rw(IF_InsMemRW),
    .if_ready(IF_ready),
    .id_redirect(ID_redirect),
    .ex_redirect(EX_redirect),
    .if_wait_cycles(perf_if_wait_cycles),
    .load_hazard_cycles(perf_load_hazard_cycles),
    .mem_wait_cycles(perf_mem_wait_cycles),
    .redirect_count(perf_redirect_count)
);

DifftestTrace U_DifftestTrace (
    // Inputs
    .clk(clk),
    .rst(rst),
    .pipe_flush(pipe_flush),
    .if_stall(IF_stall),
    .if_stage_pca4(IF_stage_PCA4),
    .mem_bus_wait(MEM_bus_wait),
    .ex_redirect_wait(EX_redirect_wait),
    .ex_to_mem_kill(EX_to_MEM_kill),
    .ex_branch(EX_branch),
    .npc_npc(NPC_NPC),
    .mem_access_fault(MEM_access_fault),
    .dnpc_out(dnpc)
);

export "DPI-C" function DPI_getIfWaitCycles;
function int DPI_getIfWaitCycles();
    return perf_if_wait_cycles;
endfunction

export "DPI-C" function DPI_getLoadHazardCycles;
function int DPI_getLoadHazardCycles();
    return perf_load_hazard_cycles;
endfunction

export "DPI-C" function DPI_getMemWaitCycles;
function int DPI_getMemWaitCycles();
    return perf_mem_wait_cycles;
endfunction

export "DPI-C" function DPI_getRedirectCount;
function int DPI_getRedirectCount();
    return perf_redirect_count;
endfunction

export "DPI-C" function DPI_getPC;
function int DPI_getPC();
    return dnpc;
endfunction

`endif


endmodule
