`include "ctrl_signal_def.v"

module IR(clk, in_ins, IRWrite, out_ins);
    input         clk;
    input         IRWrite;
    input  [31:0] in_ins;
    output [31:0] out_ins;

    assign out_ins = IRWrite ? in_ins : 32'b0;

endmodule
