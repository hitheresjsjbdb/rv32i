`timescale 1ns / 1ps

// Direct data-memory interface.  It preserves the one-request-at-a-time
// handshake expected by ControlUnit, without exposing a bus protocol.
// The local data image occupies 32 KiB at 0x00000000; other addresses report
// an access error.
module DirectDataMemory(
    input         clk,
    input         rst,
    input         req_valid,
    input  [31:0] req_addr,
    input  [31:0] req_wdata,
    input         req_we,
    output        rsp_valid,
    output        rsp_error,
    output [31:0] rsp_rdata
);

localparam [31:0] DATA_END = 32'h00008000;

reg        pending;
reg [31:0] pending_addr;
wire       address_valid;
wire       accept;
wire [31:0] active_addr;
wire [31:0] memory_data;

assign address_valid = (req_addr < DATA_END);
assign accept        = req_valid && address_valid && !pending;
assign active_addr   = pending ? pending_addr : req_addr;

DM U_DM (
    // Inputs
    .clk(clk),
    .addr(active_addr[14:2]),
    .write_data(req_wdata),
    .write_enable(accept && req_we),

    // Outputs
    .read_data(memory_data)
);

// A valid local request completes one clock after acceptance.  Invalid-page
// requests complete immediately as errors and never touch the SRAM.
assign rsp_valid = (req_valid && !pending && !address_valid) ||
                   (pending && req_valid &&
                    (pending_addr == req_addr));
assign rsp_error = req_valid && !pending && !address_valid;
assign rsp_rdata = memory_data;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pending      <= 1'b0;
        pending_addr <= 32'b0;
    end
    else begin
        if (pending)
            pending <= 1'b0;
        else if (accept) begin
            pending      <= 1'b1;
            pending_addr <= req_addr;
        end
    end
end

endmodule
