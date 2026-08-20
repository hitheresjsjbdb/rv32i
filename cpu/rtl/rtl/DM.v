`include "ctrl_signal_def.v"

module DM(clk, addr, write_data, write_enable, read_data);
    input         clk;
    input  [11:2] addr;
    input  [31:0] write_data;
    input         write_enable;
    output reg [31:0] read_data;

`ifndef SRAM

    reg [31:0] memory[0:1023];

    always @(posedge clk) begin
        if (write_enable) begin
            memory[addr] <= write_data;
        end
        else begin
            read_data <= memory[addr];
        end
    end

`endif

`ifdef SRAM

    wire [63:0] sram_out;

    TS1N65LPLL2048X64M8 memory (
        .CLK(clk),
        .CEB(1'b0),
        .WEB(~write_enable),
        .A({1'b0, addr}),
        .D({32'b0, write_data}),
        .BWEB(64'b0),
        .Q(sram_out),
        .TSEL(2'b01)
    );

    always @(*) read_data = sram_out[31:0];

`endif

endmodule
