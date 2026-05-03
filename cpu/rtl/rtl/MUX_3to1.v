`include "ctrl_signal_def.v"

module MUX_3to1(X, Y, Z, control, out, use_pipe, X_pipe, control_pipe);
    input  [4:0] X;
    input  [4:0] Y;
    input  [4:0] Z;
    input  [1:0] control;
    input        use_pipe;
    input  [4:0] X_pipe;
    input  [1:0] control_pipe;
    output reg [4:0] out;
    wire use_pipe_en;
    wire [4:0] x_sel;
    wire [1:0] control_sel;

    assign use_pipe_en = (use_pipe === 1'b1);
    assign x_sel = use_pipe_en ? X_pipe : X;
    assign control_sel = use_pipe_en ? control_pipe : control;

    always @(X or Y or Z or control or X_pipe or control_pipe or use_pipe) begin
        case(control_sel)
            `RegSel_rd  : out = x_sel;
            `RegSel_rt  : out = Y;
            `RegSel_31  : out = Z;
            `RegSel_else: out = 0;
        endcase
    end

endmodule
