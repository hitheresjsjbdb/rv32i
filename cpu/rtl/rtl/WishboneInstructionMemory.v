`timescale 1ns / 1ps

// Wishbone slave wrapper for the local 64-bit instruction SRAM.
module WishboneInstructionMemory(
    input         clk,
    input         rst,
    input  [31:0] wb_adr_i,
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
reg [28:0] buffered_line_address;
reg        buffered_line_valid;
reg [63:0] buffered_line_data;
wire       start;
wire       buffered_line_hit;
wire       buffered_ack;
wire [63:0] line_data;

assign buffered_line_hit = buffered_line_valid &&
                           (wb_adr_i[31:3] == buffered_line_address);
assign buffered_ack = (state == STATE_IDLE) && wb_cyc_i && wb_stb_i &&
                      buffered_line_hit;
assign start    = wb_cyc_i && wb_stb_i && (state == STATE_IDLE) &&
                  !buffered_line_hit;
assign wb_ack_o = (state == STATE_ACK) || buffered_ack;
assign wb_err_o = 1'b0;
assign wb_dat_o = buffered_ack
                ? (wb_adr_i[2] ? buffered_line_data[63:32]
                               : buffered_line_data[31:0])
                : (address[2] ? line_data[63:32] : line_data[31:0]);

IM U_IM (
    .clk(clk),
    .rst(rst),
    .enable(start),
    .addr(wb_adr_i[11:3]),
    .data(line_data)
);

`ifdef DIFFTEST
import "DPI-C" function void instructionWishboneCheck(
    input int addr,
    input int read_data
);
`endif

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state   <= STATE_IDLE;
        address <= 32'b0;
        buffered_line_address <= 29'b0;
        buffered_line_valid   <= 1'b0;
        buffered_line_data    <= 64'b0;
    end
    else begin
        case (state)
        STATE_IDLE: begin
            if (start) begin
                state   <= STATE_WAIT;
                address <= wb_adr_i;
                buffered_line_valid <= 1'b0;
            end
            else if (buffered_ack) begin
`ifdef DIFFTEST
                instructionWishboneCheck(wb_adr_i, wb_dat_o);
`endif
            end
        end
        STATE_WAIT: begin
            state <= STATE_ACK;
        end
        STATE_ACK: begin
`ifdef DIFFTEST
            instructionWishboneCheck(address, wb_dat_o);
`endif
            state                 <= STATE_IDLE;
            buffered_line_address <= address[31:3];
            buffered_line_valid   <= 1'b1;
            buffered_line_data    <= line_data;
        end
        default: begin
            state <= STATE_IDLE;
        end
        endcase
    end
end

endmodule
