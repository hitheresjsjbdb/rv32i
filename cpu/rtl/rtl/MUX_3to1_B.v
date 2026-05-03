`include "ctrl_signal_def.v"

module MUX_3to1_B(X, Y, Z, control, out, use_pipe, Y_pipe, Z_pipe, control_pipe);
    input  [31:0] X;
    input  [31:0] Y;
    input  [11:0] Z;
    input  [1:0]  control;
    input         use_pipe;
    input  [31:0] Y_pipe;
    input  [11:0] Z_pipe;
    input  [1:0]  control_pipe;
    output reg signed [31:0] out;
    wire use_pipe_en;
    wire [31:0] y_sel;
    wire [11:0] z_sel;
    wire [1:0] control_sel;

    assign use_pipe_en = (use_pipe === 1'b1);
    assign y_sel = use_pipe_en ? Y_pipe : Y;
    assign z_sel = use_pipe_en ? Z_pipe : Z;
    assign control_sel = use_pipe_en ? control_pipe : control;

    always @(X or Y or Z or control or Y_pipe or Z_pipe or control_pipe or use_pipe) begin
        case(control_sel)
            `ALUSrcB_B     : out = X;
            `ALUSrcB_Imm   : out = y_sel;
            `ALUSrcB_Offset: out = $signed({{20{z_sel[11]}}, z_sel});
            `ALUSrcB_else  : out = X;
        endcase
    end

endmodule
