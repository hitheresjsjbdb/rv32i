`timescale 1ns / 1ps

// Routes one Wishbone master to a 4 KB local window or the external bus.
// Address, write data, byte enables, and write direction are shared directly
// with the local slave; only its request is gated by the address decode.
module WishboneLocalRouter #(
    parameter [19:0] LOCAL_PAGE = 20'h00000
)(
    input  [31:0] master_adr_i,
    input  [31:0] master_dat_i,
    input  [3:0]  master_sel_i,
    input         master_we_i,
    input         master_cyc_i,
    input         master_stb_i,
    output [31:0] master_dat_o,
    output        master_ack_o,
    output        master_err_o,

    output        local_cyc_o,
    output        local_stb_o,
    input  [31:0] local_dat_i,
    input         local_ack_i,
    input         local_err_i,

    output [31:0] external_adr_o,
    output [31:0] external_dat_o,
    output [3:0]  external_sel_o,
    output        external_we_o,
    output        external_cyc_o,
    output        external_stb_o,
    input  [31:0] external_dat_i,
    input         external_ack_i,
    input         external_err_i
);

wire local_selected;

assign local_selected = (master_adr_i[31:12] == LOCAL_PAGE);
assign local_cyc_o = master_cyc_i && local_selected;
assign local_stb_o = master_stb_i && local_selected;

assign master_dat_o = local_selected ? local_dat_i : external_dat_i;
assign master_ack_o = local_selected ? local_ack_i : external_ack_i;
assign master_err_o = local_selected ? local_err_i : external_err_i;

assign external_adr_o = master_adr_i;
assign external_dat_o = master_dat_i;
assign external_sel_o = master_sel_i;
assign external_we_o = master_we_i;
assign external_cyc_o = master_cyc_i && !local_selected;
assign external_stb_o = master_stb_i && !local_selected;

endmodule
