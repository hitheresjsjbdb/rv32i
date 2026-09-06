`timescale 1ns / 1ps

`ifdef DIFFTEST

// Simulation-only performance counters.  These counters are intentionally
// outside the functional pipeline and are exported through DPI-C.
module DifftestPerfCounter(
    input clk,
    input rst,
    input trap,
    input mem_bus_wait,
    input front_hazard_stall,
    input if_ins_mem_rw,
    input if_ready,
    input id_redirect,
    input ex_redirect,
    output [31:0] if_wait_cycles,
    output [31:0] load_hazard_cycles,
    output [31:0] mem_wait_cycles,
    output [31:0] redirect_count
);

reg [31:0] perf_if_wait_cycles;
reg [31:0] perf_load_hazard_cycles;
reg [31:0] perf_mem_wait_cycles;
reg [31:0] perf_redirect_count;

assign if_wait_cycles     = perf_if_wait_cycles;
assign load_hazard_cycles = perf_load_hazard_cycles;
assign mem_wait_cycles    = perf_mem_wait_cycles;
assign redirect_count     = perf_redirect_count;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        perf_if_wait_cycles      <= 32'b0;
        perf_load_hazard_cycles <= 32'b0;
        perf_mem_wait_cycles     <= 32'b0;
        perf_redirect_count      <= 32'b0;
    end
    else if (!trap) begin
        if (mem_bus_wait)
            perf_mem_wait_cycles <= perf_mem_wait_cycles + 32'd1;
        else if (front_hazard_stall)
            perf_load_hazard_cycles <= perf_load_hazard_cycles + 32'd1;
        else if (if_ins_mem_rw && !if_ready)
            perf_if_wait_cycles <= perf_if_wait_cycles + 32'd1;

        if (id_redirect || ex_redirect)
            perf_redirect_count <= perf_redirect_count + 32'd1;
    end
end

export "DPI-C" function DPI_getIfWaitCycles;
function int DPI_getIfWaitCycles();
    return perf_if_wait_cycles;
endfunction

export "DPI-C" function DPI_getLoadHazardCycles;
function int DPI_getLoadHazardCycles();
    return perf_load_hazard_cycles;
endfunction

export "DPI-C" function DPI_getMemWaitCycles;
function int DPI_getMemWaitCycles();
    return perf_mem_wait_cycles;
endfunction

export "DPI-C" function DPI_getRedirectCount;
function int DPI_getRedirectCount();
    return perf_redirect_count;
endfunction

endmodule

`endif
