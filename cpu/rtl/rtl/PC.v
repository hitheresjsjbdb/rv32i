`timescale 1ns / 1ps

`include "ctrl_signal_def.v"

module PC(
    clk, rst, PCWrite, NPC, PC, EX_branch, IF_bubble, IF_PCA4, IF_PC,
    NPC_NPC, EX_PC, PC_NPC, IM_PC, NPC_PC, IM_addr, PCA4, use_pipe, NPC_pipe
);
    input  clk;
    input  rst;
    input  PCWrite;
    input  [31:0] NPC;
    input  use_pipe;
    input  [31:0] NPC_pipe;
    input EX_branch;
    input IF_bubble;
    input [31:0] PCA4;
    input [31:0] NPC_NPC;
    input [31:0] EX_PC;
    output reg [31:0] PC;
    output reg [31:0] IF_PCA4;
    output reg [31:0] IF_PC;
    output [31:0] PC_NPC;
    output [31:0] IM_PC;
    output [31:0] NPC_PC;
    output [9:0] IM_addr;

wire use_pipe_en;
wire [31:0] npc_sel;

assign use_pipe_en = (use_pipe === 1'b1);
assign npc_sel = use_pipe_en ? NPC_pipe : NPC;
assign PC_NPC = EX_branch ? (NPC_NPC + 32'd4) : (IF_bubble ? IF_PCA4 : NPC_NPC);
assign IM_PC = EX_branch ? NPC_NPC : (IF_bubble ? IF_PC : PC);
assign NPC_PC = EX_branch ? EX_PC : PC;
assign IM_addr = IM_PC[11:2];


always @(posedge clk or posedge rst) begin
    if (rst) begin
        PC <= 32'h0000_2000;
        IF_PC <= 32'b0;
        IF_PCA4 <= 32'b0;
    end
    else begin
        if (~IF_bubble) begin
            IF_PC <= EX_branch ? IM_PC : PC;
            IF_PCA4 <= EX_branch ? (NPC_NPC + 32'd4) : PCA4;
        end

        if (PCWrite) begin
            PC <= npc_sel;
        end
    end

end

endmodule
