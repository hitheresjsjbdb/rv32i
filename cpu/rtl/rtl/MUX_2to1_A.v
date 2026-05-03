`include "ctrl_signal_def.v"

module MUX_2to1_A(X, Y, control, out, use_pipe, X_pipe, Y_pipe, control_pipe);
    input  [31:0] X;
    input  [31:0] Y;
    input         control;
    input         use_pipe;
    input  [31:0] X_pipe;
    input  [31:0] Y_pipe;
    input         control_pipe;
    output [31:0] out;
    wire use_pipe_en;
    wire [31:0] x_sel;
    wire [31:0] y_sel;
    wire control_sel;

    assign use_pipe_en = (use_pipe === 1'b1);
    assign x_sel = use_pipe_en ? X_pipe : X;
    assign y_sel = use_pipe_en ? Y_pipe : Y;
    assign control_sel = use_pipe_en ? control_pipe : control;

    assign out = (control_sel == 1'b0) ? x_sel : y_sel;

endmodule

module MUX_2to1 #(parameter WIDTH = 32)(X, Y, control, out);

    input [WIDTH-1:0] X;
    input [WIDTH-1:0] Y;
    input control;
    output [WIDTH-1:0] out;

    assign out = (control == 1'b0) ? X : Y;

endmodule
