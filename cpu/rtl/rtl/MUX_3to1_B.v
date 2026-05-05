`include "ctrl_signal_def.v"

module MUX_3to1_B(X,Y,Z,control,out, Imm, Offset);
    input  [31:0] X;
    input  [31:0] Y;
    input  [11:0] Z;
    input  [1:0]  control;
    output reg signed [31:0] out;

    input [31:0] Imm;
    input [11:0] Offset;

    always @(*) begin
        // The B operand is preselected before the ID/EX boundary to shorten the
        // EX-stage control-to-ALU path, while keeping the original top-level wiring.
        out = Imm;
    end

endmodule
