`timescale 1ns / 1ps

// Single-outstanding instruction master. It holds a Wishbone request stable
// until completion and drops a response when the fetch PC changed meanwhile.
module WishboneInstructionMaster(
    input         clk,
    input         rst,
    input         req_valid,
    input  [31:0] req_addr,

    output        rsp_valid,
    output        rsp_error,
    output [31:0] rsp_rdata,

    output [31:0] wb_adr_o,
    output [31:0] wb_dat_o,
    input  [31:0] wb_dat_i,
    output [3:0]  wb_sel_o,
    output        wb_we_o,
    output        wb_cyc_o,
    output        wb_stb_o,
    input         wb_ack_i,
    input         wb_err_i
);

reg        pending;
reg [31:0] pending_addr;

wire [31:0] active_addr;
wire        bus_request;
wire        bus_response;
wire        response_current;

assign active_addr      = pending ? pending_addr : req_addr;
assign bus_request      = pending || req_valid;
assign bus_response     = bus_request && (wb_ack_i || wb_err_i);
assign response_current = req_valid && (active_addr == req_addr);

assign rsp_valid = bus_response && response_current;
assign rsp_error = rsp_valid && wb_err_i;
assign rsp_rdata = wb_dat_i;

assign wb_adr_o = active_addr;
assign wb_dat_o = 32'b0;
assign wb_sel_o = 4'b1111;
assign wb_we_o  = 1'b0;
assign wb_cyc_o = bus_request;
assign wb_stb_o = bus_request;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pending      <= 1'b0;
        pending_addr <= 32'b0;
    end
    else if (pending) begin
        if (bus_response)
            pending <= 1'b0;
    end
    else if (req_valid && !bus_response) begin
        pending      <= 1'b1;
        pending_addr <= req_addr;
    end
end

endmodule
