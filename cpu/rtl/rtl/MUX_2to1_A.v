`include "ctrl_signal_def.v"

module MUX_2to1_A(X,Y,control,out);
    input  [31:0] X;
    input  [4:0]  Y;
    input         control;
    output [31:0] out;

    assign out = (control == 1'b0) ? X : {27'b0, Y[4:0]};

endmodule

module MUX_2to1 #(parameter WIDTH = 32)(X, Y, control, out);

    input [WIDTH-1:0] X;
    input [WIDTH-1:0] Y;
    input control;
    output [WIDTH-1:0] out;

    assign out = (control == 1'b0) ? X : Y;

endmodule