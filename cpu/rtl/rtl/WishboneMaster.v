`timescale 1ns / 1ps

// Single-outstanding-transfer Wishbone B4 Classic master.
module WishboneMaster(
    input         clk,
    input         rst,

    input         req_valid,
    output        req_ready,
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

reg        active;
reg [31:0] address;
reg [31:0] write_data;
reg [3:0]  byte_select;
reg        write_enable;

assign req_ready = !active;

assign rsp_valid = active && (wb_ack_i || wb_err_i);
assign rsp_error = active && wb_err_i;
assign rsp_rdata = wb_dat_i;

assign wb_adr_o = address;
assign wb_dat_o = write_data;
assign wb_sel_o = byte_select;
assign wb_we_o  = write_enable;
assign wb_cyc_o = active;
assign wb_stb_o = active;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        active       <= 1'b0;
        address      <= 32'b0;
        write_data   <= 32'b0;
        byte_select  <= 4'b0;
        write_enable <= 1'b0;
    end
    else if (active) begin
        if (wb_ack_i || wb_err_i)
            active <= 1'b0;
    end
    else if (req_valid) begin
        active       <= 1'b1;
        address      <= req_addr;
        write_data   <= req_wdata;
        byte_select  <= req_sel;
        write_enable <= req_we;
    end
end

endmodule
