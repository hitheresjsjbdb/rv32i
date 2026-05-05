`include "ctrl_signal_def.v"

module IR(in_ins, IRWrite, out_ins);

    input         IRWrite;
    input  [31:0] in_ins;
    output reg [31:0] out_ins;

    assign out_ins = IRWrite ? in_ins : 32'b0;

endmodule
