`timescale 1ns / 1ps

`ifdef DIFFTEST

// Simulation-only pipeline PC trace used by the differential tester.
module DifftestTrace(
    input        clk,
    input        rst,
    input        pipe_flush,
    input        if_stall,
    input [31:0] if_stage_pca4,
    input        mem_bus_wait,
    input        ex_redirect_wait,
    input        ex_to_mem_kill,
    input        ex_branch,
    input [31:0] npc_npc,
    input        mem_access_fault,
    output [31:0] dnpc_out
);

reg [31:0] id_dnpc;
reg [31:0] ex_dnpc;
reg [31:0] mem_dnpc;
reg [31:0] wb_dnpc;
reg [31:0] dnpc;

assign dnpc_out = dnpc;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        id_dnpc  <= 32'b0;
        ex_dnpc  <= 32'b0;
        mem_dnpc <= 32'b0;
        wb_dnpc  <= 32'b0;
        dnpc     <= 32'b0;
    end
    else begin
        if (pipe_flush)
            id_dnpc <= 32'b0;
        else if (!if_stall)
            id_dnpc <= if_stage_pca4;

        if (!(mem_bus_wait || ex_redirect_wait)) begin
            if (pipe_flush || if_stall)
                ex_dnpc <= 32'b0;
            else
                ex_dnpc <= id_dnpc;
        end

        if (!mem_bus_wait) begin
            if (ex_redirect_wait || ex_to_mem_kill)
                mem_dnpc <= 32'b0;
            else
                mem_dnpc <= ex_branch ? npc_npc : ex_dnpc;
        end

        if (mem_bus_wait || mem_access_fault)
            wb_dnpc <= 32'b0;
        else
            wb_dnpc <= mem_dnpc;

        dnpc <= wb_dnpc;
    end
end

export "DPI-C" function DPI_getPC;
function int DPI_getPC();
    return dnpc;
endfunction

endmodule

`endif
