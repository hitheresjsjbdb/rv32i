`include "ctrl_signal_def.v"

module DM(clk, addr, write_data, write_enable, read_data);
    input         clk;
    // 32 KiB data window (8192 32-bit words).
    input  [14:2] addr;
    input  [31:0] write_data;
    input         write_enable;
    output reg [31:0] read_data;

`ifndef SRAM

    reg [31:0] memory[0:8191];

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

    wire [63:0] sram_out0;
    wire [63:0] sram_out1;
    wire [63:0] sram_out2;
    wire [63:0] sram_out3;

    TS1N65LPLL2048X64M8 memory0 (
        // Inputs
        .CLK(clk),
        .CEB((addr[12:11] != 2'b00)),
        .WEB(~write_enable),
        .A(addr[10:0]),
        .D({32'b0, write_data}),
        .BWEB(64'b0),
        .TSEL(2'b01),

        // Outputs
        .Q(sram_out0)
    );

    TS1N65LPLL2048X64M8 memory1 (
        // Inputs
        .CLK(clk),
        .CEB((addr[12:11] != 2'b01)),
        .WEB(~write_enable),
        .A(addr[10:0]),
        .D({32'b0, write_data}),
        .BWEB(64'b0),
        .TSEL(2'b01),

        // Outputs
        .Q(sram_out1)
    );

    TS1N65LPLL2048X64M8 memory2 (
        // Inputs
        .CLK(clk),
        .CEB((addr[12:11] != 2'b10)),
        .WEB(~write_enable),
        .A(addr[10:0]),
        .D({32'b0, write_data}),
        .BWEB(64'b0),
        .TSEL(2'b01),

        // Outputs
        .Q(sram_out2)
    );

    TS1N65LPLL2048X64M8 memory3 (
        // Inputs
        .CLK(clk),
        .CEB((addr[12:11] != 2'b11)),
        .WEB(~write_enable),
        .A(addr[10:0]),
        .D({32'b0, write_data}),
        .BWEB(64'b0),
        .TSEL(2'b01),

        // Outputs
        .Q(sram_out3)
    );

    always @(*) begin
        case (addr[12:11])
            2'b00: read_data = sram_out0[31:0];
            2'b01: read_data = sram_out1[31:0];
            2'b10: read_data = sram_out2[31:0];
            default: read_data = sram_out3[31:0];
        endcase
    end

`endif

endmodule
