`timescale 1ns / 1ps

// Combinational Wishbone B4 Classic adapter. Requesters in this core keep
// req_valid, address, and write data stable until rsp_valid is asserted.
module WishboneMaster(
    input         req_valid,
    input  [31:0] req_addr,
    input  [31:0] req_wdata,
    input  [3:0]  req_sel,
    input         req_we,

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

assign rsp_valid = req_valid && (wb_ack_i || wb_err_i);
assign rsp_error = req_valid && wb_err_i;
assign rsp_rdata = wb_dat_i;

assign wb_adr_o = req_addr;
assign wb_dat_o = req_wdata;
assign wb_sel_o = req_sel;
assign wb_we_o  = req_we;
assign wb_cyc_o = req_valid;
assign wb_stb_o = req_valid;

endmodule
