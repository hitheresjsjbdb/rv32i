`include "ctrl_signal_def.v"

module DM(
    Addr, WD, DMCtrl, clk, rst, RD
);
    input  [11:2] Addr;
    input  [31:0] WD;
    input         DMCtrl;
    input         clk;
    input         rst;
    output reg [31:0] RD;

    reg [31:0] memory[0:1023];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RD <= 32'b0;
        end else if (DMCtrl) begin
            memory[Addr] <= WD;
        end else begin
            RD <= memory[Addr];
        end
    end

endmodule
