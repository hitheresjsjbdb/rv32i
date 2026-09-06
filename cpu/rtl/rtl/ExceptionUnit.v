`timescale 1ns / 1ps

`include "ctrl_signal_def.v"

module ExceptionUnit(
    input         clk,
    input         rst,
    input         id_valid,
    input  [31:0] id_pc,
    input  [31:0] id_ins,
    input         id_illegal,
    input         id_access_fault,
    input         ex_valid,
    input         ex_branch,
    input         ex_redirect_predicted,
    input  [31:0] ex_pc,
    input         ex_rfwrite,
    input  [1:0]  ex_wdsel,
    input         ex_dmctrl,
    input  [31:0] ex_alu_result,
    input  [31:0] redirect_target,
    input         mem_valid,
    input  [31:0] mem_pc,
    input  [1:0]  mem_wdsel,
    input         mem_dmctrl,
    input  [31:0] mem_address,
    input         dm_ready,
    input         dm_error,

    output ex_exception,
    output mem_access_fault,
    output mem_bus_wait,
    output trap_request,
    output ex_redirect_wait,
    output ex_redirect,
    output dm_req,
    output reg        trap,
    output reg [3:0]  trap_cause,
    output reg [31:0] trap_epc,
    output reg [31:0] trap_tval
);

reg [3:0]  trap_cause_next;
reg [31:0] trap_epc_next;
reg [31:0] trap_tval_next;
wire id_inst_misaligned;
wire id_illegal_exception;
wire id_breakpoint_exception;
wire ex_ctrl_misaligned;
wire ex_load_misaligned;
wire ex_store_misaligned;
wire mem_load_access_fault;
wire mem_store_access_fault;

// The core implements IALIGN=32 and only word-sized data accesses.
assign id_inst_misaligned = id_valid && (id_pc[1:0] != 2'b00);
`ifdef DIFFTEST
assign id_breakpoint_exception = 1'b0;
`else
assign id_breakpoint_exception = id_valid && (id_ins == 32'h0010_0073);
`endif
assign id_illegal_exception = id_valid && id_illegal &&
                              !id_breakpoint_exception;

assign ex_ctrl_misaligned = ex_valid && ex_branch &&
                            (redirect_target[1:0] != 2'b00);
assign ex_load_misaligned = ex_valid && ex_rfwrite &&
                            (ex_wdsel == `WDSel_FromMEM) &&
                            (ex_alu_result[1:0] != 2'b00);
assign ex_store_misaligned = ex_valid && (ex_dmctrl == `DMCtrl_WR) &&
                             (ex_alu_result[1:0] != 2'b00);
assign ex_exception = ex_ctrl_misaligned || ex_load_misaligned ||
                      ex_store_misaligned;

assign dm_req = mem_valid && ((mem_wdsel == `WDSel_FromMEM) ||
                             (mem_dmctrl == `DMCtrl_WR));
assign mem_load_access_fault = dm_req && dm_ready && dm_error &&
                               (mem_wdsel == `WDSel_FromMEM);
assign mem_store_access_fault = dm_req && dm_ready && dm_error &&
                                (mem_dmctrl == `DMCtrl_WR);
assign mem_access_fault = mem_load_access_fault || mem_store_access_fault;
assign mem_bus_wait = dm_req && !dm_ready;

// MEM faults are oldest. Younger exceptions and redirects wait behind a
// pending memory operation so the reported exception remains precise.
assign trap_request = !trap &&
                      (mem_access_fault ||
                       (!mem_bus_wait &&
                        (ex_exception ||
                         (!ex_branch &&
                          (id_access_fault || id_inst_misaligned ||
                           id_illegal_exception ||
                           id_breakpoint_exception)))));
// The instruction master can start a target request in the redirect cycle. It
// does not need to wait for a previous external instruction-bus response.
assign ex_redirect_wait = 1'b0;
assign ex_redirect = ex_branch && !ex_redirect_predicted &&
                     !ex_ctrl_misaligned &&
                     !mem_bus_wait && !mem_access_fault && !trap;

always @(*) begin
    trap_cause_next = `TRAP_ILLEGAL_INSTRUCTION;
    trap_epc_next   = id_pc;
    trap_tval_next  = id_ins;

    if (mem_load_access_fault) begin
        trap_cause_next = `TRAP_LOAD_ACCESS_FAULT;
        trap_epc_next   = mem_pc;
        trap_tval_next  = mem_address;
    end
    else if (mem_store_access_fault) begin
        trap_cause_next = `TRAP_STORE_ACCESS_FAULT;
        trap_epc_next   = mem_pc;
        trap_tval_next  = mem_address;
    end
    else if (ex_ctrl_misaligned) begin
        trap_cause_next = `TRAP_INST_ADDR_MISALIGNED;
        trap_epc_next   = ex_pc;
        trap_tval_next  = redirect_target;
    end
    else if (ex_load_misaligned) begin
        trap_cause_next = `TRAP_LOAD_ADDR_MISALIGNED;
        trap_epc_next   = ex_pc;
        trap_tval_next  = ex_alu_result;
    end
    else if (ex_store_misaligned) begin
        trap_cause_next = `TRAP_STORE_ADDR_MISALIGNED;
        trap_epc_next   = ex_pc;
        trap_tval_next  = ex_alu_result;
    end
    else if (id_access_fault) begin
        trap_cause_next = `TRAP_INST_ACCESS_FAULT;
        trap_epc_next   = id_pc;
        trap_tval_next  = id_pc;
    end
    else if (id_inst_misaligned) begin
        trap_cause_next = `TRAP_INST_ADDR_MISALIGNED;
        trap_epc_next   = id_pc;
        trap_tval_next  = id_pc;
    end
    else if (id_breakpoint_exception) begin
        trap_cause_next = `TRAP_BREAKPOINT;
        trap_epc_next   = id_pc;
        trap_tval_next  = id_pc;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        trap       <= 1'b0;
        trap_cause <= 4'b0;
        trap_epc   <= 32'b0;
        trap_tval  <= 32'b0;
    end
    else if (trap_request) begin
        trap       <= 1'b1;
        trap_cause <= trap_cause_next;
        trap_epc   <= trap_epc_next;
        trap_tval  <= trap_tval_next;
    end
end

endmodule
