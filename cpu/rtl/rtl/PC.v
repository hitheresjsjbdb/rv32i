`timescale 1ns / 1ps

`include "ctrl_signal_def.v"

module PC(clk, rst, PCWrite, NPC, PC, EX_branch, IF_bubble, IF_PCA4, IF_PC, NPC_NPC, EX_PC, PC_NPC, IM_PC, NPC_PC, IM_addr);
    input  clk;
    input  rst;
    input  PCWrite;
    input  [31:0] NPC;
    input EX_branch;
    input IF_bubble;
    input [31:0] IF_PCA4;
    input [31:0] IF_PC;
    input [31:0] NPC_NPC;
    input [31:0] EX_PC;
    output reg [31:0] PC;
    output [31:0] PC_NPC;
    output [31:0] IM_PC;
    output [31:0] NPC_PC;
    output [9:0] IM_addr;

assign PC_NPC = EX_branch ? (NPC_NPC + 32'd4) : (IF_bubble ? IF_PCA4 : NPC_NPC);
assign IM_PC = EX_branch ? NPC_NPC : (IF_bubble ? IF_PC : PC);
assign NPC_PC = EX_branch ? EX_PC : PC;
assign IM_addr = IM_PC[11:2];


always @(posedge clk or posedge rst) begin
    if (rst) begin
        PC <= 32'h0000_2000;
    end
    else if (PCWrite) begin
        PC <= NPC;
    end

end

endmodule