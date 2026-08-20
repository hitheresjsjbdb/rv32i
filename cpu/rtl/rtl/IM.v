`timescale 1ns / 1ps
module IM(clk, rst, enable, addr, data);
    input           clk;
    input           rst;
    input           enable;
    input   [8:0]   addr;
    output reg [63:0] data;

`ifndef SRAM

    `ifndef DIFFTEST
    `ifndef SYNTHESIS
    reg [31:0] memory[0:1023];
    `endif
    `endif

    `ifdef DIFFTEST
    import "DPI-C" function longint unsigned instructionBusRead(input int addr);
    `endif

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data <= 64'b0;
        end
        else begin
            `ifdef DIFFTEST
            data <= enable ? instructionBusRead({20'h00002, addr, 3'b000}) : data;
            `endif
            
            `ifndef DIFFTEST
            `ifndef SYNTHESIS
            data <= enable ? {memory[{addr, 1'b1}], memory[{addr, 1'b0}]} : data;
            `endif
            `endif
        end
    end

`endif

`ifdef SRAM

    wire [63:0] sram_out;

    TS1N65LPLL2048X64M8 memory (
        .CLK(clk),
        .CEB(~enable),
        .WEB(1'b1),
        .A({2'b00, addr}),
        .D(64'b0),
        .BWEB(64'b0),
        .Q(sram_out),
        .TSEL(2'b01)
    );

    always @(*) data = sram_out;

`endif


endmodule
