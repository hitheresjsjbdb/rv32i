`include "ctrl_signal_def.v"
`include "instruction_def.v"

module NPC(
    NPCop, Offset12, Offset20, PC, rs, PCA4, NPC,
    use_pipe, NPCop_pipe, Offset12_pipe, Offset20_pipe, PC_pipe, rs_pipe
);
    input  [1:0]  NPCop;
    input  [12:1] Offset12;
    input  [20:1] Offset20;
    input  [31:0] PC;
    input  [31:2] rs;
    input         use_pipe;
    input  [1:0]  NPCop_pipe;
    input  [12:1] Offset12_pipe;
    input  [20:1] Offset20_pipe;
    input  [31:0] PC_pipe;
    input  [31:0] rs_pipe;
    output reg [31:0] PCA4;
    output reg [31:0] NPC;

wire use_pipe_en;
wire [1:0] NPCop_sel;
wire [12:1] Offset12_sel;
wire [20:1] Offset20_sel;
wire [31:0] PC_sel;
wire [31:0] rs_sel;
wire signed [12:0] Offset13;
wire signed [20:0] Offset21;
wire signed [31:0] Imm12Ext;
wire [31:0] rs_aligned;
wire [31:0] rs_legacy;

assign use_pipe_en = (use_pipe === 1'b1);
assign NPCop_sel = use_pipe_en ? NPCop_pipe : NPCop;
assign Offset12_sel = use_pipe_en ? Offset12_pipe : Offset12;
assign Offset20_sel = use_pipe_en ? Offset20_pipe : Offset20;
assign PC_sel = use_pipe_en ? PC_pipe : PC;
assign rs_legacy = {rs, 2'b00};
assign rs_sel = use_pipe_en ? rs_pipe : rs_legacy;

assign Offset13 = $signed({Offset12_sel[12:1], 1'b0});
assign Offset21 = $signed({Offset20_sel[20:1], 1'b0});
assign Imm12Ext = {{20{Offset12_sel[12]}}, Offset12_sel[12:1]};
assign rs_aligned = {rs_sel[31:2], 2'b0};

always @(*) begin
    case(NPCop_sel)
        `NPC_PC       : NPC = PC_sel + 4;
        `NPC_Offset12 : NPC = $signed(PC_sel) + $signed({{19{Offset13[12]}}, Offset13});
        `NPC_rs       : NPC = rs_sel;
        `NPC_Offset20 : NPC = $signed(PC_sel) + $signed({{11{Offset21[20]}}, Offset21});
        default       : NPC = PC_sel + 4;
    endcase

    if (NPCop_sel == `NPC_rs) begin
        NPC = (rs_aligned + Imm12Ext) & 32'hffff_fffe;
    end

    PCA4 = PC_sel + 4;
end

endmodule
