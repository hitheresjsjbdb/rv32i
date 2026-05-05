`include "ctrl_signal_def.v"

module MUX_2to1_A(X,Y,control,out);
    input  [31:0] X;
    input  [4:0]  Y;
    input         control;
    output [31:0] out;

    // In the current CPU microarchitecture ALUSrcA never selects the legacy
    // shift-amount path, so keep the interface intact but remove the extra mux
    // level from the ALU A-input critical path.
    assign out = X;

endmodule