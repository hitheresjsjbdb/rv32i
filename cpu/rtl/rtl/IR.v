`include "ctrl_signal_def.v"

module IR(in_ins, IRWrite, out_ins);

    input         IRWrite;
    input  [31:0] in_ins;
    output reg [31:0] out_ins;

    // IR stays combinational, but IRWrite is not functionally used in the
    // current pipeline control, so bypass the extra gate on the decode path.
    assign out_ins = in_ins;

endmodule
