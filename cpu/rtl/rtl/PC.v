`timescale 1ns / 1ps

`include "ctrl_signal_def.v"

module PC(clk, rst, PCWrite, NPC, PC, branch, stall, PC_NPC);
    input  clk;
    input  rst;
    input  PCWrite;
    input  [31:0] NPC;
    output reg [31:0] PC;

    input        branch;
    input        stall;
    input [31:0] PC_NPC;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        PC <= 32'h0000_2000;
    end
    else if (PCWrite) begin
        // PC_NPC is already the final next-PC value from the control pipeline.
        PC <= PC_NPC;
    end

end

 
endmodule
