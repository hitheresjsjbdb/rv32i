`include "ctrl_signal_def.v"
`include "instruction_def.v"

module NPC(NPCOp, Offset12, Offset20, PC, rs, PCA4, NPC, NPC_PC, NPC_Offset12, NPC_Offset20, NPC_rs);
    input  [1:0]  NPCOp;
    input  [12:1] Offset12;
    input  [20:1] Offset20;
    input  [31:0] PC;
    input  [31:0] rs;
    output reg [31:0] PCA4;
    output reg [31:0] NPC;
    
    input [31:0] NPC_PC;
    input [12:1] NPC_Offset12;
    input [20:1] NPC_Offset20;
    input [31:0] NPC_rs;


wire signed [12:0] Offset13;
wire signed [20:0] Offset21;
wire signed [31:0] Imm12Ext;
wire [31:0] rs_aligned;

assign Offset13 = $signed({NPC_Offset12[12:1], 1'b0});
assign Offset21 = $signed({NPC_Offset20[20:1], 1'b0});
assign Imm12Ext = {{20{NPC_Offset12[12]}}, NPC_Offset12[12:1]};
assign rs_aligned = {NPC_rs[31:2], 2'b0};

always @(*) begin
    case(NPCOp)
        `NPC_PC       : NPC = NPC_PC + 4;
        `NPC_Offset12 : NPC = $signed(NPC_PC) + $signed({{19{Offset13[12]}}, Offset13});
        `NPC_rs       : NPC = NPC_rs;
        `NPC_Offset20 : NPC = $signed(NPC_PC) + $signed({{11{Offset21[20]}}, Offset21});
    endcase
    // Added logic only: keep original case items unchanged, then refine jalr target.
    if (NPCOp == `NPC_rs) begin
        NPC = (rs_aligned + Imm12Ext) & 32'hffff_fffe;
    end

    PCA4 = NPC_PC + 4;
end


endmodule