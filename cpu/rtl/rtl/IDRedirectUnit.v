`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"

// ID-stage control-transfer decision and redirect target generation.
module IDRedirectUnit(
    input         id_valid,
    input  [6:0]  opcode,
    input  [2:0]  funct3,
    input  [31:0] id_pc,
    input  [31:0] id_pca4,
    input  [11:0] imm12,
    input  [11:0] offset12,
    input  [19:0] offset20,
    input  [31:0] control_rd1,
    input  [31:0] control_rd2,
    input         front_hazard_stall,
    input         mem_bus_wait,
    input         trap_request,
    input         trap,

    output reg [1:0]  npcop,
    output            control_transfer,
    output            redirect,
    output reg [31:0] redirect_target
);

wire operands_equal;
wire is_beq;
wire is_bne;
wire take_branch;
wire [31:0] branch_target;
wire [31:0] jal_target;
wire [31:0] jalr_target_sum;

assign operands_equal = (control_rd1 == control_rd2);
assign is_beq = (opcode == `INSTR_BTYPE_OP) &&
                (funct3 == `INSTR_BEQ_FUNCT);
assign is_bne = (opcode == `INSTR_BTYPE_OP) &&
                (funct3 == `INSTR_BNE_FUNCT);
assign take_branch = (is_beq && operands_equal) ||
                     (is_bne && !operands_equal);

always @(*) begin
    npcop = `NPC_PC;
    if (take_branch) begin
        npcop = `NPC_Offset12;
    end
    else if (opcode == `INSTR_JAL_OP) begin
        npcop = `NPC_Offset20;
    end
    else if (opcode == `INSTR_JALR_OP) begin
        npcop = `NPC_rs;
    end
end

// Keep the target adders independent so no operand mux is inserted ahead of
// the carry network on the fetch-address path.
NPC_prefix_adder32 U_BRANCH_TARGET_ADD (
    .A   (id_pc),
    .B   ({{19{offset12[11]}}, offset12, 1'b0}),
    .SUM (branch_target)
);

NPC_prefix_adder32 U_JAL_TARGET_ADD (
    .A   (id_pc),
    .B   ({{11{offset20[19]}}, offset20, 1'b0}),
    .SUM (jal_target)
);

NPC_prefix_adder32 U_JALR_TARGET_ADD (
    .A   (control_rd1),
    .B   ({{20{imm12[11]}}, imm12}),
    .SUM (jalr_target_sum)
);

always @(*) begin
    case (npcop)
        `NPC_Offset12: redirect_target = branch_target;
        `NPC_Offset20: redirect_target = jal_target;
        `NPC_rs:       redirect_target = jalr_target_sum & 32'hffff_fffe;
        default:       redirect_target = id_pca4;
    endcase
end

assign control_transfer = (npcop != `NPC_PC);
assign redirect = id_valid && control_transfer &&
                  (redirect_target[1:0] == 2'b00) &&
                  !front_hazard_stall && !mem_bus_wait &&
                  !trap_request && !trap;

endmodule
