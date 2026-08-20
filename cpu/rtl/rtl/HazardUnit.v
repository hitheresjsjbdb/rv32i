`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"

module HazardUnit(
    input        id_valid,
    input  [6:0] id_opcode,
    input  [4:0] id_rs1,
    input  [4:0] id_rs2,
    input  [4:0] ex_rd,
    input        ex_valid,
    input        ex_rfwrite,
    input  [1:0] ex_wdsel,
    input  [4:0] mem_rd,
    input        mem_valid,
    input        mem_rfwrite,
    input  [1:0] mem_wdsel,
    input        mem_dmread_stall,
    input  [4:0] memstall_rd,
    input        memstall_valid,
    input        pipe_flush,
    input        mem_bus_wait,
    input        if_ready,

    output front_hazard_stall,
    output if_stall
);

wire id_use_rs1;
wire id_use_rs2;
wire id_dep_ex;
wire id_dep_mem;
wire id_dep_memstall;
wire load_pipe_busy;

assign id_use_rs1 = (id_opcode == `INSTR_RTYPE_OP) ||
                    (id_opcode == `INSTR_ITYPE_OP) ||
                    (id_opcode == `INSTR_LW_OP)    ||
                    (id_opcode == `INSTR_SW_OP)    ||
                    (id_opcode == `INSTR_BTYPE_OP) ||
                    (id_opcode == `INSTR_JALR_OP);
assign id_use_rs2 = (id_opcode == `INSTR_RTYPE_OP) ||
                    (id_opcode == `INSTR_SW_OP)    ||
                    (id_opcode == `INSTR_BTYPE_OP);

assign id_dep_ex = id_valid && ex_valid &&
                   (((id_use_rs1 && (id_rs1 == ex_rd)) ||
                     (id_use_rs2 && (id_rs2 == ex_rd))) &&
                    ex_rfwrite && (ex_wdsel == `WDSel_FromMEM) &&
                    (ex_rd != 5'b0));
assign id_dep_mem = id_valid && mem_valid &&
                    (((id_use_rs1 && (id_rs1 == mem_rd)) ||
                      (id_use_rs2 && (id_rs2 == mem_rd))) &&
                     mem_rfwrite && (mem_wdsel == `WDSel_FromMEM) &&
                     (mem_rd != 5'b0));
assign id_dep_memstall = id_valid &&
                         (((id_use_rs1 && (id_rs1 == memstall_rd)) ||
                           (id_use_rs2 && (id_rs2 == memstall_rd))) &&
                          memstall_valid && (memstall_rd != 5'b0));

`ifdef WISHBONE
assign load_pipe_busy = 1'b0;
`else
assign load_pipe_busy = (ex_valid && ex_rfwrite &&
                         (ex_wdsel == `WDSel_FromMEM)) ||
                        mem_dmread_stall || memstall_valid;
`endif

assign front_hazard_stall = load_pipe_busy || id_dep_ex || id_dep_mem ||
                            id_dep_memstall;
assign if_stall = !pipe_flush &&
                  (mem_bus_wait || front_hazard_stall || !if_ready);

endmodule
