`include "ctrl_signal_def.v"

module IR(in_ins, clk, IRWrite, out_ins);
    input         clk;
    input         IRWrite;
    input  [31:0] in_ins;
    output reg [31:0] out_ins;

    // Keep legacy ports for compatibility; IR behaves as combinational pass-through.
    always @(*) begin
        out_ins = in_ins;
    end

endmodule