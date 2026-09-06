`timescale 1ns / 1ps

`include "ctrl_signal_def.v"

// ID-stage ALU B operand extension and selection.
module IDOperandSelector(
    input  [31:0] rd2,
    input  [11:0] imm12,
    input  [11:0] offset12,
    input  [1:0]  alusrcb,
    output reg [31:0] alu_b
);

wire [31:0] imm32;
wire [31:0] offset32;

assign imm32 = {{20{imm12[11]}}, imm12};
assign offset32 = {{20{offset12[11]}}, offset12};

always @(*) begin
    case (alusrcb)
        `ALUSrcB_B     : alu_b = rd2;
        `ALUSrcB_Imm   : alu_b = imm32;
        `ALUSrcB_Offset: alu_b = offset32;
        default        : alu_b = rd2;
    endcase
end

endmodule
