`timescale 1ns / 1ps
`include "ctrl_signal_def.v"
module IM(clk, rst, InsMemRW, addr,Ins);
    input           clk;
    input           InsMemRW;
    input   [11:2]  addr;
    input           rst;
    output reg [31:0] Ins;
    reg [31:0] memory[0:1023];

    import "DPI-C" function int instFetch(input int addr);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Ins <= 32'b0;
        end
        else begin
            Ins <= InsMemRW ? instFetch({20'h00002, addr, 2'b00}) : Ins;
        end
    end
endmodule