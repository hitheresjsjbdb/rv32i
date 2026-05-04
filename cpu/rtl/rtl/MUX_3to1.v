`include "ctrl_signal_def.v"

module MUX_3to1(X,Y,Z,control,out, rd);
    input  [4:0] X;
    input  [4:0] Y;
    input  [4:0] Z;
    input  [1:0] control;
    output reg [4:0] out;

    input [4:0] rd;

    always @(*) begin
        case(control)
            `RegSel_rd  : out = rd;
            `RegSel_rt  : out = Y;
            `RegSel_31  : out = Z;
            `RegSel_else: out = 0;
        endcase
    end

endmodule