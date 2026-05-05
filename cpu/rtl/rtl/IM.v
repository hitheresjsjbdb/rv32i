`timescale 1ns / 1ps
`include "ctrl_signal_def.v"
module IM(clk, rst, InsMemRW, addr,Ins, IM_addr, branch);
    input           clk;
    input           InsMemRW;
    input   [11:2]  addr;
    input           rst;
    output reg [31:0] Ins;

    input [11:2] IM_addr;
    input branch;

    wire [9:0] address;
    assign address = IM_addr;

`ifndef SRAM

    reg [31:0] memory[0:1023];

    `ifdef DIFFTEST
    import "DPI-C" function int instFetch(input int addr);
    `endif

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Ins <= 32'b0;
        end
        else begin
            `ifdef DIFFTEST
            Ins <= InsMemRW ? instFetch({20'h00002, address, 2'b00}) : Ins;
            `endif
            
            `ifndef DIFFTEST
            `ifndef SYNTHESIS
            Ins <= InsMemRW ? memory[address] : Ins;
            `endif
            `endif
        end
    end

`endif

`ifdef SRAM

    wire [63:0] sram_out;

    TS1N65LPLL2048X64M8 memory (
        .CLK(clk),
        .CEB(~InsMemRW),
        .WEB(1'b1),
        .A({1'b0, address}),
        .D(64'b0),
        .BWEB(64'b0),
        .Q(sram_out),
        .TSEL(2'b01)
    );

    always @(*) Ins = sram_out[31:0];

`endif


endmodule