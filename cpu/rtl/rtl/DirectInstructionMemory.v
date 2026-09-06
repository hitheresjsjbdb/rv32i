`timescale 1ns / 1ps

// Direct instruction-memory interface.  This module replaces the former
// bus chain while preserving the pipeline's req_valid/rsp_valid
// handshake.  The local instruction image occupies 32 KiB at 0x00002000.
module DirectInstructionMemory(
    input         clk,
    input         rst,
    input         req_valid,
    input  [31:0] req_addr,
    output        rsp_valid,
    output        rsp_error,
    output [31:0] rsp_rdata
);

localparam [31:0] INSTRUCTION_BASE = 32'h00002000;
localparam [31:0] INSTRUCTION_END  = 32'h0000a000;

wire       address_valid;
wire       launch;
wire [11:0] launch_line;
wire [31:0] instruction_offset;
wire [63:0] line_data;

assign address_valid = (req_addr >= INSTRUCTION_BASE) &&
                       (req_addr < INSTRUCTION_END);
assign launch        = req_valid && address_valid;
assign instruction_offset = req_addr - INSTRUCTION_BASE;
assign launch_line   = instruction_offset[14:3];

IM U_IM (
    // Inputs
    .clk(clk),
    .rst(rst),
    .enable(launch),
    .addr(launch_line),

    // Outputs
    .data(line_data)
);

// The direct memory is combinational: an accepted request and its response
// are visible in the same cycle.  This removes the one-cycle fetch bubble
// that was only needed by the former bus/SRAM wrapper.
assign rsp_valid = req_valid && address_valid;
assign rsp_error = req_valid && !address_valid;
assign rsp_rdata = req_addr[2] ? line_data[63:32] : line_data[31:0];

endmodule
