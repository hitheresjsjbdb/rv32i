`include "ctrl_signal_def.v"

module DM(Addr, WD, clk, DMCtrl, RD, DM_WD);
    input  [11:2] Addr;
    input  [31:0] WD;
    input         clk;
    input         DMCtrl;
    output reg [31:0] RD;

    input [31:0] DM_WD;

`ifndef SRAM

    reg [31:0] memory[0:1023];

    always @(posedge clk) begin
        if (DMCtrl) begin
            memory[Addr] <= DM_WD;
        end
        else begin
            RD <= memory[Addr];
        end
    end

`endif

`ifdef SRAM

    wire [63:0] sram_out;

    TS1N65LPLL2048X64M8 memory (
        .CLK(clk),
        .CEB(1'b0),
        .WEB(~DMCtrl),
        .A({1'b0, Addr}),
        .D({32'b0, DM_WD}),
        .BWEB(64'b0),
        .Q(sram_out),
        .TSEL(2'b01)
    );

    always @(*) RD = sram_out[31:0];

`endif

endmodule