`include "ctrl_signal_def.v"
`include "instruction_def.v"

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
