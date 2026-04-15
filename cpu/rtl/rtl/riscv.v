`timescale 1ns / 1ps
`include "instruction_def.v"
`include "ctrl_signal_def.v"

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
wire [31:0] PC, PCA4, NPC_dbg;
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

wire done_cu;
reg done_r;
assign done = done_r;

wire bp_predict_taken;
wire [31:0] bp_predict_npc;
wire bp_update_valid;
wire [31:0] bp_update_pc;
wire bp_update_taken;
wire bp_report_valid;
localparam BP_BHT_ENTRIES = 64;
localparam BP_BHT_IDX_W = 6;
reg bp_bht [0:BP_BHT_ENTRIES-1];
integer bp_i;
wire [BP_BHT_IDX_W-1:0] bp_fetch_idx;
wire [BP_BHT_IDX_W-1:0] bp_update_idx;
wire bp_fetch_is_branch;
wire [31:0] bp_fetch_branch_imm;

// IF/ID stage metadata (instruction is held in out_ins by IR)
reg ifid_valid;
reg [31:0] ifid_pc;
reg ifid_pred_taken;

// ID/EX
reg idex_valid;
reg [31:0] idex_pc;
reg [31:0] idex_pc4;
reg [31:0] idex_rs1_val;
reg [31:0] idex_rs2_val;
reg [31:0] idex_imm32;
reg [31:0] idex_npc_imm;
reg [11:0] idex_offset12;
reg [4:0]  idex_rd;
reg [4:0]  idex_rs1;
reg [4:0]  idex_rs2;
reg [2:0]  idex_funct3;
reg [1:0]  idex_RegSel;
reg [1:0]  idex_WDSel;
reg        idex_ALUSrcA;
reg [1:0]  idex_ALUSrcB;
reg [3:0]  idex_ALUOp;
reg        idex_RFWrite;
reg        idex_MemRead;
reg        idex_MemWrite;
reg        idex_IsBranch;
reg        idex_IsJal;
reg        idex_IsJalr;
reg        idex_IsEbreak;
reg        idex_pred_taken;

// EX/MEM
reg        exmem_valid;
reg [31:0] exmem_alu_result;
reg [31:0] exmem_rs2_val;
reg [31:0] exmem_pc4;
reg [31:0] exmem_dnpc;
reg [4:0]  exmem_rd;
reg [1:0]  exmem_RegSel;
reg [1:0]  exmem_WDSel;
reg        exmem_RFWrite;
reg        exmem_MemRead;
reg        exmem_MemWrite;
reg        exmem_IsEbreak;
reg        exmem_load_wait;

// MEM/WB
reg        memwb_valid;
reg [31:0] memwb_alu_result;
reg [31:0] memwb_mem_data;
reg [31:0] memwb_pc4;
reg [31:0] memwb_dnpc;
reg [4:0]  memwb_rd;
reg [1:0]  memwb_RegSel;
reg [1:0]  memwb_WDSel;
reg        memwb_RFWrite;
reg        memwb_IsEbreak;

// Committed next PC, exported through U_NPC DPI_getPC path.
reg [31:0] commit_dnpc;
wire [31:0] commit_pc_for_npc;
assign commit_pc_for_npc = commit_dnpc - 32'd4;

assign opcode  = out_ins[6:0];
assign Funct3  = out_ins[14:12];
assign Funct7  = out_ins[31:25];
assign rs1     = out_ins[19:15];
assign rs2     = out_ins[24:20];
assign rd      = out_ins[11:7];
assign Imm12   = out_ins[31:20];
assign Offset20 = {out_ins[31], out_ins[19:12], out_ins[20], out_ins[30:21]};
assign Offset  = (opcode == `INSTR_BTYPE_OP) ? {out_ins[31], out_ins[7], out_ins[30:25], out_ins[11:8]} :
                 (opcode == `INSTR_SW_OP)    ? {out_ins[31:25], out_ins[11:7]} : Imm12;

wire [31:0] ImmB32;
wire [31:0] ImmJ32;
assign ImmB32 = {{19{out_ins[31]}}, out_ins[31], out_ins[7], out_ins[30:25], out_ins[11:8], 1'b0};
assign ImmJ32 = {{11{out_ins[31]}}, out_ins[31], out_ins[19:12], out_ins[20], out_ins[30:21], 1'b0};

assign bp_fetch_idx = PC[BP_BHT_IDX_W+1:2];
assign bp_update_idx = bp_update_pc[BP_BHT_IDX_W+1:2];
assign bp_fetch_is_branch = (in_ins[6:0] == `INSTR_BTYPE_OP);
assign bp_fetch_branch_imm = {{19{in_ins[31]}}, in_ins[31], in_ins[7], in_ins[30:25], in_ins[11:8], 1'b0};
assign bp_predict_taken = bp_fetch_is_branch ? bp_bht[bp_fetch_idx] : 1'b0;
assign bp_predict_npc = bp_predict_taken ? (PC + bp_fetch_branch_imm) : (PC + 32'd4);

// No-forwarding policy: stall decode on any RAW with in-flight writers.
wire id_use_rs1;
wire id_use_rs2;
assign id_use_rs1 = (opcode == `INSTR_RTYPE_OP) ||
                    (opcode == `INSTR_ITYPE_OP) ||
                    (opcode == `INSTR_LW_OP) ||
                    (opcode == `INSTR_SW_OP) ||
                    (opcode == `INSTR_BTYPE_OP) ||
                    (opcode == `INSTR_JALR_OP);
assign id_use_rs2 = (opcode == `INSTR_RTYPE_OP) ||
                    (opcode == `INSTR_SW_OP) ||
                    (opcode == `INSTR_BTYPE_OP);

wire load_use_hazard_rs1;
wire load_use_hazard_rs2;
assign load_use_hazard_rs1 = id_use_rs1 && idex_valid && idex_MemRead && (idex_rd != 5'd0) && (idex_rd == rs1);
assign load_use_hazard_rs2 = id_use_rs2 && idex_valid && idex_MemRead && (idex_rd != 5'd0) && (idex_rd == rs2);

wire id_stall;
assign id_stall = ifid_valid && (load_use_hazard_rs1 || load_use_hazard_rs2);

wire exmem_can_fwd;
wire memwb_can_fwd;
wire [31:0] exmem_fwd_data;
wire [31:0] memwb_fwd_data;
wire [31:0] ex_rs1_fwd;
wire [31:0] ex_rs2_fwd;
wire [31:0] id_rs1_val_byp;
wire [31:0] id_rs2_val_byp;

assign exmem_can_fwd = exmem_valid && exmem_RFWrite && (exmem_rd != 5'd0) && !exmem_MemRead;
assign memwb_can_fwd = memwb_valid && memwb_RFWrite && (memwb_rd != 5'd0);

assign exmem_fwd_data = (exmem_WDSel == `WDSel_FromPC) ? exmem_pc4 : exmem_alu_result;
assign memwb_fwd_data = (memwb_WDSel == `WDSel_FromMEM) ? memwb_mem_data :
                                (memwb_WDSel == `WDSel_FromPC)  ? memwb_pc4 :
                                                                             memwb_alu_result;

// When ID reads RF in the same cycle WB writes, bypass WB data to avoid stale operands.
assign id_rs1_val_byp = (memwb_can_fwd && (memwb_rd == rs1)) ? memwb_fwd_data : RD1;
assign id_rs2_val_byp = (memwb_can_fwd && (memwb_rd == rs2)) ? memwb_fwd_data : RD2;

assign ex_rs1_fwd = (exmem_can_fwd && (exmem_rd == idex_rs1)) ? exmem_fwd_data :
                          (memwb_can_fwd && (memwb_rd == idex_rs1)) ? memwb_fwd_data :
                                                                                     idex_rs1_val;
assign ex_rs2_fwd = (exmem_can_fwd && (exmem_rd == idex_rs2)) ? exmem_fwd_data :
                          (memwb_can_fwd && (memwb_rd == idex_rs2)) ? memwb_fwd_data :
                                                                                     idex_rs2_val;

wire ex_branch_cond;
assign ex_branch_cond = (idex_funct3 == `INSTR_BEQ_FUNCT) ? zero :
                        (idex_funct3 == `INSTR_BNE_FUNCT) ? ~zero :
                                                            1'b0;

wire ex_take_branch;
wire [31:0] ex_branch_target;
wire [31:0] ex_dnpc;
wire [31:0] ex_recover_npc;
wire ex_mispredict;
assign ex_take_branch  = idex_valid && (idex_IsJal || idex_IsJalr || (idex_IsBranch && ex_branch_cond));
// For JALR, branch target must use EX-forwarded rs1 to avoid RAW hazards.
assign ex_branch_target = idex_IsJalr ? ((ex_rs1_fwd + idex_npc_imm) & 32'hffff_fffe)
                                      : (idex_pc + idex_npc_imm);
assign ex_recover_npc = ex_take_branch ? ex_branch_target : (idex_pc + 32'd4);
assign ex_dnpc = ex_recover_npc;
assign ex_mispredict = idex_valid && (ex_take_branch ^ idex_pred_taken);

wire mem_hold;
wire ex_can_advance;
wire ex_branch_commit;
assign mem_hold = exmem_valid && exmem_MemRead && exmem_load_wait;
assign ex_can_advance = ~mem_hold;
assign ex_branch_commit = ex_can_advance && ex_mispredict;
assign bp_update_valid = ex_can_advance && idex_valid && idex_IsBranch;
assign bp_update_pc = idex_pc;
assign bp_update_taken = ex_branch_cond;
assign bp_report_valid = memwb_valid && memwb_IsEbreak;

wire [31:0] NPC_next;
wire PCWrite_eff;
wire IRWrite_eff;
wire InsMemRW_eff;

assign NPC_next = ex_branch_commit ? ex_recover_npc : bp_predict_npc;
assign PCWrite_eff = PCWrite && (ex_branch_commit || (!id_stall && !mem_hold));
assign IRWrite_eff = IRWrite && (!id_stall) && (!mem_hold) && (!ex_branch_commit);
assign InsMemRW_eff = InsMemRW;

wire RFWrite_eff;
wire [1:0] RegSel_eff;
wire [1:0] WDSel_eff;
wire DMCtrl_eff;
assign RFWrite_eff = memwb_valid && memwb_RFWrite;
assign RegSel_eff = memwb_RegSel;
assign WDSel_eff = memwb_WDSel;
assign DMCtrl_eff = (exmem_valid && exmem_MemWrite) ? `DMCtrl_WR : `DMCtrl_RD;

ControlUnit U_ControlUnit(
    .clk(clk), .rst(rst), .zero(zero), .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3),
    .RFWrite(RFWrite), .DMCtrl(DMCtrl), .PCWrite(PCWrite), .IRWrite(IRWrite), .InsMemRW(InsMemRW),
    .ExtSel(ExtSel), .ALUOp(ALUOp), .NPCOp(NPCOp), .ALUSrcA(ALUSrcA),
    .WDSel(WDSel), .ALUSrcB(ALUSrcB), .RegSel(RegSel), .done(done_cu)
);

BPStats U_BPStats(
    .clk(clk),
    .rst(rst),
    .branch_valid(bp_update_valid),
    .branch_miss(bp_update_valid && ex_mispredict),
    .report_valid(bp_report_valid)
);

PC U_PC (
    .clk(clk), .rst(rst), .PCWrite(PCWrite_eff), .NPC(NPC_next), .PC(PC)
);

// Keep U_NPC instance for DPI_getPC compatibility; it reflects committed next PC.
NPC U_NPC (
    .PC(commit_pc_for_npc),
    .NPCOp(`NPC_PC),
    .Offset12(12'b0),
    .Offset20(20'b0),
    .rs(32'b0),
    .PCA4(PCA4),
    .NPC(NPC_dbg)
);

IM U_IM (
    .addr(PC[11:2]), .Ins(in_ins), .InsMemRW(InsMemRW_eff)
);

IR U_IR (
    .clk(clk), .IRWrite(IRWrite_eff), .in_ins(in_ins), .out_ins(out_ins)
);

RF U_RF (
    .RR1(rs1), .RR2(rs2), .WR(WR), .WD(WD), .clk(clk),
    .RFWrite(RFWrite_eff), .RD1(RD1), .RD2(RD2)
);

MUX_3to1 U_MUX_3to1 (
    .X(memwb_rd), .Y(5'd0), .Z(5'd31),
    .control(RegSel_eff), .out(WR)
);

MUX_3to1_LMD U_MUX_3to1_LMD (
    .X(memwb_alu_result), .Y(memwb_mem_data), .Z(memwb_pc4),
    .control(WDSel_eff), .out(WD)
);

// Keep original flops instantiated; ID/EX values are captured by explicit regs below.
Flopr U_A (
    .clk(clk), .rst(rst), .in_data(RD1), .out_data(RD1_r)
);

Flopr U_B (
    .clk(clk), .rst(rst), .in_data(RD2), .out_data(RD2_r)
);

EXT U_EXT (
    .imm_in(Imm12), .ExtSel(ExtSel), .imm_out(Imm32)
);

MUX_2to1_A U_MUX_2to1_A (
    .X(ex_rs1_fwd), .Y(5'h0), .control(idex_ALUSrcA), .out(A)
);

MUX_3to1_B U_MUX_3to1_B (
    .X(ex_rs2_fwd), .Y(idex_imm32), .Z(idex_offset12), .control(idex_ALUSrcB), .out(B)
);

ALU U_ALU (
    .A(A), .B(B), .ALUOp(idex_ALUOp), .ALU_result(ALU_result), .zero(zero)
);

Flopr U_ALUOut (
    .clk(clk), .rst(rst), .in_data(ALU_result), .out_data(ALU_result_r)
);

DM U_DM (
    .Addr(exmem_alu_result[11:2]), .WD(exmem_rs2_val), .DMCtrl(DMCtrl_eff), .clk(clk), .RD(RD)
);

assign DR_out = RD;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (bp_i = 0; bp_i < BP_BHT_ENTRIES; bp_i = bp_i + 1) begin
            bp_bht[bp_i] <= 1'b0;
        end

        done_r <= 1'b0;
        commit_dnpc <= 32'h0000_2000;

        ifid_valid <= 1'b0;
        ifid_pc <= 32'b0;
        ifid_pred_taken <= 1'b0;

        idex_valid <= 1'b0;
        idex_pc <= 32'b0;
        idex_pc4 <= 32'b0;
        idex_rs1_val <= 32'b0;
        idex_rs2_val <= 32'b0;
        idex_imm32 <= 32'b0;
        idex_npc_imm <= 32'b0;
        idex_offset12 <= 12'b0;
        idex_rd <= 5'b0;
        idex_rs1 <= 5'b0;
        idex_rs2 <= 5'b0;
        idex_funct3 <= 3'b0;
        idex_RegSel <= `RegSel_rd;
        idex_WDSel <= `WDSel_FromALU;
        idex_ALUSrcA <= `ALUSrcA_A;
        idex_ALUSrcB <= `ALUSrcB_B;
        idex_ALUOp <= `ALUOp_ADD;
        idex_RFWrite <= 1'b0;
        idex_MemRead <= 1'b0;
        idex_MemWrite <= 1'b0;
        idex_IsBranch <= 1'b0;
        idex_IsJal <= 1'b0;
        idex_IsJalr <= 1'b0;
        idex_IsEbreak <= 1'b0;
        idex_pred_taken <= 1'b0;

        exmem_valid <= 1'b0;
        exmem_alu_result <= 32'b0;
        exmem_rs2_val <= 32'b0;
        exmem_pc4 <= 32'b0;
        exmem_dnpc <= 32'b0;
        exmem_rd <= 5'b0;
        exmem_RegSel <= `RegSel_rd;
        exmem_WDSel <= `WDSel_FromALU;
        exmem_RFWrite <= 1'b0;
        exmem_MemRead <= 1'b0;
        exmem_MemWrite <= 1'b0;
        exmem_IsEbreak <= 1'b0;
        exmem_load_wait <= 1'b0;

        memwb_valid <= 1'b0;
        memwb_alu_result <= 32'b0;
        memwb_mem_data <= 32'b0;
        memwb_pc4 <= 32'b0;
        memwb_dnpc <= 32'b0;
        memwb_rd <= 5'b0;
        memwb_RegSel <= `RegSel_rd;
        memwb_WDSel <= `WDSel_FromALU;
        memwb_RFWrite <= 1'b0;
        memwb_IsEbreak <= 1'b0;
    end
    else begin
        if (bp_update_valid) begin
            bp_bht[bp_update_idx] <= bp_update_taken;
        end

        done_r <= memwb_valid;
        if (memwb_valid) begin
            commit_dnpc <= memwb_dnpc;
        end

        // MEM -> WB
        if (exmem_valid && (!exmem_MemRead || !exmem_load_wait)) begin
            memwb_valid <= 1'b1;
            memwb_alu_result <= exmem_alu_result;
            memwb_mem_data <= exmem_MemRead ? DR_out : 32'b0;
            memwb_pc4 <= exmem_pc4;
            memwb_dnpc <= exmem_dnpc;
            memwb_rd <= exmem_rd;
            memwb_RegSel <= exmem_RegSel;
            memwb_WDSel <= exmem_WDSel;
            memwb_RFWrite <= exmem_RFWrite;
            memwb_IsEbreak <= exmem_IsEbreak;
        end
        else begin
            memwb_valid <= 1'b0;
            memwb_alu_result <= 32'b0;
            memwb_mem_data <= 32'b0;
            memwb_pc4 <= 32'b0;
            memwb_dnpc <= 32'b0;
            memwb_rd <= 5'b0;
            memwb_RegSel <= `RegSel_rd;
            memwb_WDSel <= `WDSel_FromALU;
            memwb_RFWrite <= 1'b0;
            memwb_IsEbreak <= 1'b0;
        end

        // EX -> MEM
        if (ex_can_advance) begin
            exmem_valid <= idex_valid;
            if (idex_valid) begin
                exmem_alu_result <= ALU_result;
                exmem_rs2_val <= ex_rs2_fwd;
                exmem_pc4 <= idex_pc4;
                exmem_dnpc <= ex_dnpc;
                exmem_rd <= idex_rd;
                exmem_RegSel <= idex_RegSel;
                exmem_WDSel <= idex_WDSel;
                exmem_RFWrite <= idex_RFWrite;
                exmem_MemRead <= idex_MemRead;
                exmem_MemWrite <= idex_MemWrite;
                exmem_IsEbreak <= idex_IsEbreak;
                exmem_load_wait <= idex_MemRead;
            end
            else begin
                exmem_alu_result <= 32'b0;
                exmem_rs2_val <= 32'b0;
                exmem_pc4 <= 32'b0;
                exmem_dnpc <= 32'b0;
                exmem_rd <= 5'b0;
                exmem_RegSel <= `RegSel_rd;
                exmem_WDSel <= `WDSel_FromALU;
                exmem_RFWrite <= 1'b0;
                exmem_MemRead <= 1'b0;
                exmem_MemWrite <= 1'b0;
                exmem_IsEbreak <= 1'b0;
                exmem_load_wait <= 1'b0;
            end
        end
        else begin
            // Hold EX/MEM instruction one extra cycle for synchronous DM load.
            exmem_load_wait <= 1'b0;
        end

        // ID -> EX
        if (ex_can_advance) begin
            if (!ifid_valid || id_stall || ex_branch_commit) begin
                idex_valid <= 1'b0;
                idex_pc <= 32'b0;
                idex_pc4 <= 32'b0;
                idex_rs1_val <= 32'b0;
                idex_rs2_val <= 32'b0;
                idex_imm32 <= 32'b0;
                idex_npc_imm <= 32'b0;
                idex_offset12 <= 12'b0;
                idex_rd <= 5'b0;
                idex_rs1 <= 5'b0;
                idex_rs2 <= 5'b0;
                idex_funct3 <= 3'b0;
                idex_RegSel <= `RegSel_rd;
                idex_WDSel <= `WDSel_FromALU;
                idex_ALUSrcA <= `ALUSrcA_A;
                idex_ALUSrcB <= `ALUSrcB_B;
                idex_ALUOp <= `ALUOp_ADD;
                idex_RFWrite <= 1'b0;
                idex_MemRead <= 1'b0;
                idex_MemWrite <= 1'b0;
                idex_IsBranch <= 1'b0;
                idex_IsJal <= 1'b0;
                idex_IsJalr <= 1'b0;
                idex_IsEbreak <= 1'b0;
                idex_pred_taken <= 1'b0;
            end
            else begin
                idex_valid <= 1'b1;
                idex_pc <= ifid_pc;
                idex_pc4 <= ifid_pc + 32'd4;
                idex_rs1_val <= id_rs1_val_byp;
                idex_rs2_val <= id_rs2_val_byp;
                idex_imm32 <= Imm32;
                idex_offset12 <= Offset;
                idex_npc_imm <= (opcode == `INSTR_BTYPE_OP) ? ImmB32 :
                                (opcode == `INSTR_JAL_OP)   ? ImmJ32 :
                                                              Imm32;
                idex_rd <= rd;
                idex_rs1 <= rs1;
                idex_rs2 <= rs2;
                idex_funct3 <= Funct3;
                idex_RegSel <= RegSel;
                idex_WDSel <= WDSel;
                idex_ALUSrcA <= ALUSrcA;
                idex_ALUSrcB <= ALUSrcB;
                idex_ALUOp <= ALUOp;
                idex_RFWrite <= RFWrite;
                idex_MemRead <= (opcode == `INSTR_LW_OP);
                idex_MemWrite <= (opcode == `INSTR_SW_OP);
                idex_IsBranch <= (opcode == `INSTR_BTYPE_OP);
                idex_IsJal <= (opcode == `INSTR_JAL_OP);
                idex_IsJalr <= (opcode == `INSTR_JALR_OP);
                idex_IsEbreak <= (out_ins == 32'h0010_0073);
                idex_pred_taken <= ifid_pred_taken;
            end
        end

        // IF metadata (IR already holds instruction data)
        if (ex_branch_commit) begin
            ifid_valid <= 1'b0;
            ifid_pc <= 32'b0;
            ifid_pred_taken <= 1'b0;
        end
        else if (IRWrite_eff) begin
            ifid_valid <= 1'b1;
            ifid_pc <= PC;
            ifid_pred_taken <= bp_predict_taken;
        end
    end
end

endmodule
