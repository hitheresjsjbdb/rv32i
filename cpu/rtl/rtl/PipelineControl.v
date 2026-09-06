`timescale 1ns / 1ps

// Generates the control signals shared by the pipeline stages.  This module
// contains only combinational gating; all stage state remains in the
// pipeline-register modules.
module PipelineControl(
    input        if_pc_write,
    input        if_ins_mem_rw,
    input        trap,
    input        trap_request,
    input        mem_bus_wait,
    input        ex_redirect_wait,
    input        ex_redirect,
    input        id_redirect,
    input        front_hazard_stall,
    input        if_ready,
    input        wb_rf_write,
    input        mem_dm_ctrl,
    input  [3:0] ex_alu_op,
    input  [1:0] ex_npc_op,

    output       pc_write,
    output       ins_mem_rw,
    output       rf_write,
    output       dm_ctrl,
    output [3:0] alu_op,
    output [1:0] npc_op,
    output       mem_hold
);

assign pc_write = if_pc_write && !trap && !trap_request &&
                  !mem_bus_wait &&
                  (ex_redirect || id_redirect ||
                   (!front_hazard_stall && if_ready));

assign ins_mem_rw = if_ins_mem_rw && !trap && !trap_request &&
                    !mem_bus_wait && !front_hazard_stall;

assign rf_write = wb_rf_write;
assign dm_ctrl  = mem_dm_ctrl;
assign alu_op   = ex_alu_op;
assign npc_op   = ex_npc_op;
assign mem_hold = mem_bus_wait || ex_redirect_wait;

endmodule
