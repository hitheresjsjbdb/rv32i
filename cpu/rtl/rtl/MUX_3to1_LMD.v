`timescale 1ns / 1ps

`include "ctrl_signal_def.v"

module MUX_3to1_LMD(X,Y,Z,control,stall_control,stall,out);
    input  [31:0] X;
    input  [31:0] Y;
    input  [31:0] Z;
    input  [1:0]  control;
    input  [1:0]  stall_control;
    input         stall;
    output reg [31:0] out;

    wire [1:0] sel;
    assign sel = stall ? stall_control : control;

    always @(*) begin
        case(sel)
            `WDSel_FromALU : out = X;
            `WDSel_FromMEM : out = Y;
            `WDSel_FromPC  : out = Z;
            `WDSel_Else    : out = 0;
        endcase
    end

endmodule