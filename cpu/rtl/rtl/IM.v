`timescale 1ns / 1ps
`include "ctrl_signal_def.v"
module IM(clk, rst, InsMemRW, addr, Ins, use_pipe, addr_pipe);
    input           clk;
    input           InsMemRW;
    input   [11:2]  addr;
    input           rst;
    input           use_pipe;
    input   [11:2]  addr_pipe;
    output reg [31:0] Ins;
    reg [31:0] memory[0:1023];
    wire use_pipe_en;
    wire [11:2] addr_sel;

    import "DPI-C" function int instFetch(input int addr);

    assign use_pipe_en = (use_pipe === 1'b1);
    assign addr_sel = use_pipe_en ? addr_pipe : addr;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Ins <= 32'b0;
        end
        else begin
            Ins <= InsMemRW ? instFetch({20'h00002, addr_sel, 2'b00}) : Ins;
        end
    end
endmodule
