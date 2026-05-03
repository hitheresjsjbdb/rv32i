`timescale 1ns / 1ps

`include "ctrl_signal_def.v"

module MUX_3to1_LMD(X, Y, Z, control, stall_control, stall, out, use_pipe, Z_pipe, control_pipe);
    input  [31:0] X;
    input  [31:0] Y;
    input  [31:0] Z;
    input  [1:0]  control;
    input  [1:0]  stall_control;
    input         stall;
    input         use_pipe;
    input  [31:0] Z_pipe;
    input  [1:0]  control_pipe;
    output reg [31:0] out;

    wire use_pipe_en;
    wire stall_en;
    wire [31:0] z_sel;
    wire [1:0] control_sel;
    wire [1:0] sel;

    assign use_pipe_en = (use_pipe === 1'b1);
    assign stall_en = (stall === 1'b1);
    assign z_sel = use_pipe_en ? Z_pipe : Z;
    assign control_sel = use_pipe_en ? control_pipe : control;
    assign sel = stall_en ? stall_control : control_sel;

    always @(*) begin
        case(sel)
            `WDSel_FromALU : out = X;
            `WDSel_FromMEM : out = Y;
            `WDSel_FromPC  : out = z_sel;
            `WDSel_Else    : out = 0;
        endcase
    end

endmodule
