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
        case(control)
            `ALUSrcB_B     : out = X;
            `ALUSrcB_Imm   : out = Imm;
            `ALUSrcB_Offset: out = $signed({{20{Offset[11]}}, Offset});
            `ALUSrcB_else  : out = X;
        endcase
    end

endmodule