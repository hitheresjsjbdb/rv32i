`include "ctrl_signal_def.v"
`include "instruction_def.v"

module NPC(NPCOp, PC, PCA4, NPC, NPC_PC, NPC_Offset12, NPC_Offset20, NPC_rs, NPC_taken_p4);
    input  [1:0]  NPCOp;
    input  [31:0] PC;
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
wire [31:0] jalr_sum;
wire [31:0] jalr_sum_p4;
wire [31:0] seq_pc_plus4_sum;
wire [31:0] ex_pc_plus8_sum;
wire [31:0] npc_offset12_taken_sum;
wire [31:0] npc_offset20_taken_sum;
wire [31:0] npc_offset12_taken_p4_sum;
wire [31:0] npc_offset20_taken_p4_sum;
wire [31:0] imm12_ext_p4_sum;
wire [31:0] offset12_shift_ext_p4_sum;
wire [31:0] offset20_shift_ext_p4_sum;

assign Offset13 = $signed({NPC_Offset12[12:1], 1'b0});
assign Offset21 = $signed({NPC_Offset20[20:1], 1'b0});
assign Imm12Ext = {{20{NPC_Offset12[12]}}, NPC_Offset12[12:1]};
assign Offset12ShiftExt = {{19{Offset13[12]}}, Offset13};
assign Offset20ShiftExt = {{11{Offset21[20]}}, Offset21};
// Keep the +4 candidates out of inferred '+' logic.  These values feed the
// branch/JALR target-plus-4 calculations, so a ripple adder here would sit in
// series with the target adder on the PC critical path.
NPC_prefix_adder32 U_NPC_IMM12_PLUS4 (
    .A   (Imm12Ext),
    .B   (32'd4),
    .SUM (imm12_ext_p4_sum)
);
NPC_prefix_adder32 U_NPC_OFFSET12_PLUS4 (
    .A   (Offset12ShiftExt),
    .B   (32'd4),
    .SUM (offset12_shift_ext_p4_sum)
);
NPC_prefix_adder32 U_NPC_OFFSET20_PLUS4 (
    .A   (Offset20ShiftExt),
    .B   (32'd4),
    .SUM (offset20_shift_ext_p4_sum)
);
assign Imm12ExtP4 = $signed(imm12_ext_p4_sum);
assign Offset12ShiftExtP4 = $signed(offset12_shift_ext_p4_sum);
assign Offset20ShiftExtP4 = $signed(offset20_shift_ext_p4_sum);

NPC_prefix_adder32 U_NPC_SEQ_PC_PLUS4 (
    .A   (PC),
    .B   (32'd4),
    .SUM (seq_pc_plus4_sum)
);
NPC_prefix_adder32 U_NPC_EX_PC_PLUS8 (
    .A   (NPC_PC),
    .B   (32'd8),
    .SUM (ex_pc_plus8_sum)
);
NPC_prefix_adder32 U_NPC_OFFSET12_TAKEN (
    .A   (NPC_PC),
    .B   (Offset12ShiftExt),
    .SUM (npc_offset12_taken_sum)
);
NPC_prefix_adder32 U_NPC_OFFSET20_TAKEN (
    .A   (NPC_PC),
    .B   (Offset20ShiftExt),
    .SUM (npc_offset20_taken_sum)
);
NPC_prefix_adder32 U_NPC_OFFSET12_TAKEN_P4 (
    .A   (NPC_PC),
    .B   (Offset12ShiftExtP4),
    .SUM (npc_offset12_taken_p4_sum)
);
NPC_prefix_adder32 U_NPC_OFFSET20_TAKEN_P4 (
    .A   (NPC_PC),
    .B   (Offset20ShiftExtP4),
    .SUM (npc_offset20_taken_p4_sum)
);
NPC_prefix_adder32 U_JALR_ADD (
    .A   (NPC_rs),
    .B   (Imm12Ext),
    .SUM (jalr_sum)
);
NPC_prefix_adder32 U_JALR_ADD_P4 (
    .A   (NPC_rs),
    .B   (Imm12ExtP4),
    .SUM (jalr_sum_p4)
);
assign jalr_target = jalr_sum & 32'hffff_fffe;
assign jalr_target_p4 = jalr_sum_p4 & 32'hffff_fffe;
assign seq_pc_plus4 = seq_pc_plus4_sum;
assign ex_pc_plus8 = ex_pc_plus8_sum;
assign npc_offset12_taken = $signed(npc_offset12_taken_sum);
assign npc_offset20_taken = $signed(npc_offset20_taken_sum);
assign npc_offset12_taken_p4 = $signed(npc_offset12_taken_p4_sum);
assign npc_offset20_taken_p4 = $signed(npc_offset20_taken_p4_sum);

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

// 32-bit Kogge-Stone-style prefix adder.  The five prefix stages replace the
// long bit-by-bit carry propagation inferred from a plain 32-bit '+' operator.
module NPC_prefix_adder32(A, B, SUM);
    input  [31:0] A;
    input  [31:0] B;
    output [31:0] SUM;

    wire [31:0] p0;
    wire [31:0] g0;
    wire [31:0] p1, g1;
    wire [31:0] p2, g2;
    wire [31:0] p3, g3;
    wire [31:0] p4, g4;
    wire [31:0] p5, g5;
    wire [31:0] carry;

    assign p0 = A ^ B;
    assign g0 = A & B;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : GEN_PREFIX
            if (i < 1) begin
                assign p1[i] = p0[i];
                assign g1[i] = g0[i];
            end else begin
                assign p1[i] = p0[i] & p0[i-1];
                assign g1[i] = g0[i] | (p0[i] & g0[i-1]);
            end

            if (i < 2) begin
                assign p2[i] = p1[i];
                assign g2[i] = g1[i];
            end else begin
                assign p2[i] = p1[i] & p1[i-2];
                assign g2[i] = g1[i] | (p1[i] & g1[i-2]);
            end

            if (i < 4) begin
                assign p3[i] = p2[i];
                assign g3[i] = g2[i];
            end else begin
                assign p3[i] = p2[i] & p2[i-4];
                assign g3[i] = g2[i] | (p2[i] & g2[i-4]);
            end

            if (i < 8) begin
                assign p4[i] = p3[i];
                assign g4[i] = g3[i];
            end else begin
                assign p4[i] = p3[i] & p3[i-8];
                assign g4[i] = g3[i] | (p3[i] & g3[i-8]);
            end

            if (i < 16) begin
                assign p5[i] = p4[i];
                assign g5[i] = g4[i];
            end else begin
                assign p5[i] = p4[i] & p4[i-16];
                assign g5[i] = g4[i] | (p4[i] & g4[i-16]);
            end
        end

        for (i = 0; i < 32; i = i + 1) begin : GEN_SUM
            if (i == 0) begin
                assign carry[i] = 1'b0;
            end else begin
                assign carry[i] = g5[i-1];
            end
            assign SUM[i] = p0[i] ^ carry[i];
        end
    endgenerate
endmodule
