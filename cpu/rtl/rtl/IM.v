`timescale 1ns / 1ps
`include "ctrl_signal_def.v"
module IM(InsMemRW, addr,Ins);
    input           InsMemRW;
    input   [11:2]  addr;
    output reg [31:0] Ins;
    reg [31:0] memory[0:1023];

    import "DPI-C" function int instFetch(input int addr);

    always @(addr or InsMemRW) begin
        if (InsMemRW) begin
            Ins <= instFetch({22'b0, addr});
        end
    end
endmodule