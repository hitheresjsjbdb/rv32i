`timescale 1ns / 1ps

// Selects the address presented to instruction memory and the next PC.
// Redirect priority is EX stage first, then ID stage, matching the original
// ControlUnit combinational logic.
module FetchAddressUnit(
    input  [31:0] pc,
    input  [31:0] pca4,
    input  [31:0] npc,
    input  [31:0] id_redirect_target,
    input         id_redirect,
    input         ex_redirect,
    input         trap_request,
    input         trap,
    output [31:0] npc_npc,
    output [31:0] im_pc,
    output [31:0] pc_npc,
    output        pipe_flush
);

assign npc_npc = npc;

assign pipe_flush = id_redirect || ex_redirect || trap_request || trap;

assign im_pc = ex_redirect ? npc_npc :
               id_redirect ? id_redirect_target :
                              pc;

assign pc_npc = id_redirect ? id_redirect_target :
                ex_redirect ? npc_npc :
                              pca4;

endmodule
