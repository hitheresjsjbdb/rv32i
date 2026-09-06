`timescale 1ns / 1ps
module IM(clk, rst, enable, addr, data);
    input           clk;
    input           rst;
    input           enable;
    // 32 KiB instruction window, fetched as 64-bit (8-byte) lines.
    input   [11:0]  addr;
    output [63:0] data;

`ifndef SRAM

    `ifndef DIFFTEST
    `ifndef SYNTHESIS
    reg [31:0] memory[0:8191];
    `endif
    `endif

    `ifdef DIFFTEST
    import "DPI-C" function longint unsigned instructionMemoryRead(input int addr);
    assign data = instructionMemoryRead(32'h00002000 + {17'b0, addr, 3'b000});
    `endif

    `ifndef DIFFTEST
    `ifndef SYNTHESIS
    assign data = {memory[{addr, 1'b1}], memory[{addr, 1'b0}]};
    `endif
    `endif

`endif

`ifdef SRAM

    wire [63:0] sram_out0;
    wire [63:0] sram_out1;

    TS1N65LPLL2048X64M8 memory0 (
        // Inputs
        .CLK(clk),
        .CEB(~enable | addr[11]),
        .WEB(1'b1),
        .A(addr[10:0]),
        .D(64'b0),
        .BWEB(64'b0),
        .TSEL(2'b01),

        // Outputs
        .Q(sram_out0)
    );

    TS1N65LPLL2048X64M8 memory1 (
        // Inputs
        .CLK(clk),
        .CEB(~enable | ~addr[11]),
        .WEB(1'b1),
        .A(addr[10:0]),
        .D(64'b0),
        .BWEB(64'b0),
        .TSEL(2'b01),

        // Outputs
        .Q(sram_out1)
    );

    always @(*) data = addr[11] ? sram_out1 : sram_out0;

`endif


endmodule
