`timescale 1ns / 1ps

// Combinational control and bookkeeping for the instruction-fetch stage.
// This module turns the instruction-memory handshake into the signals used
// by FetchDecodeRegisters and the exception logic.
module FetchStageControl(
    input  [31:0] fetch_pc,
    input         ins_mem_rw,
    input         if_ready,
    input         if_error,
    output        if_accept,
    output        if_access_fault,
    output        if_stage_valid,
    output [31:0] if_stage_pc,
    output [31:0] if_stage_pca4
);

wire [31:0] if_stage_pca4_sum;

assign if_accept       = ins_mem_rw && if_ready;
assign if_access_fault = if_accept && if_error;
assign if_stage_valid  = if_accept;
assign if_stage_pc     = fetch_pc;

// The sequential PC is calculated from the address that was actually
// presented to instruction memory, including a one-cycle redirect address.
NPC_prefix_adder32 U_IF_STAGE_PCA4_ADD (
    // Inputs
    .A(fetch_pc),
    .B(32'd4),

    // Outputs
    .SUM(if_stage_pca4_sum)
);

assign if_stage_pca4 = if_stage_pca4_sum;

endmodule
