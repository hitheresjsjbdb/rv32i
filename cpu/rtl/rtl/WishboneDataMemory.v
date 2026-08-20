`timescale 1ns / 1ps

// Wishbone slave wrapper for the local 32-bit data SRAM.
module WishboneDataMemory(
    input         clk,
    input         rst,
    input  [31:0] wb_adr_i,
    input  [31:0] wb_dat_i,
    input  [3:0]  wb_sel_i,
    input         wb_we_i,
    input         wb_cyc_i,
    input         wb_stb_i,
    output [31:0] wb_dat_o,
    output        wb_ack_o,
    output        wb_err_o
);

localparam STATE_IDLE = 2'b00;
localparam STATE_WAIT = 2'b01;
localparam STATE_ACK  = 2'b10;

reg [1:0]  state;
reg [31:0] address;
reg [31:0] write_data;
reg [3:0]  byte_select;
reg        write_enable;
wire       start;
wire       immediate_store;
wire [31:0] memory_data;

assign start    = wb_cyc_i && wb_stb_i && (state == STATE_IDLE);
assign immediate_store = start && wb_we_i;
// A store is committed on its request edge and may therefore complete as a
// zero-wait Wishbone transfer. Loads retain the cycles required by SRAM CLK-Q.
assign wb_ack_o = (immediate_store && (wb_sel_i == 4'b1111)) ||
                  ((state == STATE_ACK) && !write_enable &&
                   (byte_select == 4'b1111));
assign wb_err_o = (immediate_store && (wb_sel_i != 4'b1111)) ||
                  ((state == STATE_ACK) && !write_enable &&
                   (byte_select != 4'b1111));
assign wb_dat_o = memory_data;

DM U_DM (
    .clk(clk),
    .addr(wb_adr_i[11:2]),
    .write_data(wb_dat_i),
    .write_enable(start && wb_we_i && (wb_sel_i == 4'b1111)),
    .read_data(memory_data)
);

`ifdef DIFFTEST
import "DPI-C" function void dataWishboneCheck(
    input int addr,
    input int write_data,
    input int read_data,
    input bit write_enable
);
`endif

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state        <= STATE_IDLE;
        address      <= 32'b0;
        write_data   <= 32'b0;
        byte_select  <= 4'b0;
        write_enable <= 1'b0;
    end
    else begin
        case (state)
        STATE_IDLE: begin
            if (immediate_store) begin
`ifdef DIFFTEST
                if (wb_sel_i == 4'b1111)
                    dataWishboneCheck(wb_adr_i, wb_dat_i, wb_dat_o, 1'b1);
`endif
            end
            else if (start) begin
                state        <= STATE_WAIT;
                address      <= wb_adr_i;
                write_data   <= wb_dat_i;
                byte_select  <= wb_sel_i;
                write_enable <= wb_we_i;
            end
        end
        STATE_WAIT: begin
            state <= STATE_ACK;
        end
        STATE_ACK: begin
`ifdef DIFFTEST
            if (byte_select == 4'b1111)
                dataWishboneCheck(address, write_data, wb_dat_o,
                                  write_enable);
`endif
            state <= STATE_IDLE;
        end
        default: begin
            state <= STATE_IDLE;
        end
        endcase
    end
end

endmodule
