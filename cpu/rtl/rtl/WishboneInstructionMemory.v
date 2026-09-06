`timescale 1ns / 1ps

// Wishbone slave wrapper for the local 64-bit instruction SRAM. Two line
// buffers form a sequential stream buffer: while one line is consumed, the
// next line is read from SRAM. There is no general-purpose cache or refill
// replacement policy.
module WishboneInstructionMemory(
    input         clk,
    input         rst,
    input  [31:0] wb_adr_i,
    input         wb_cyc_i,
    input         wb_stb_i,
    input         fetch_valid_i,
    input  [31:0] fetch_addr_i,
    output [31:0] wb_dat_o,
    output        wb_ack_o,
    output        wb_err_o
);

localparam STATE_IDLE     = 2'b00;
localparam STATE_WAIT     = 2'b01;
localparam STATE_COMPLETE = 2'b10;

reg [1:0]  state;
reg [8:0]  read_line_index;
reg [8:0]  read_next_line_index;
reg        read_line_has_next;
reg        read_buffer_select;
reg        replacement_select;
reg [8:0]  line0_index;
reg [8:0]  line1_index;
reg [8:0]  line0_next_index;
reg [8:0]  line1_next_index;
reg        line0_valid;
reg        line1_valid;
reg        line0_has_next;
reg        line1_has_next;
reg [63:0] line0_data;
reg [63:0] line1_data;

reg        launch_read;
reg [8:0]  launch_line_index;
reg        launch_buffer_select;

wire       wb_request;
wire [8:0] wb_line_index;
wire [8:0] fetch_line_index;
wire       line0_hit;
wire       line1_hit;
wire       buffered_hit;
wire       completing_hit;
wire [63:0] selected_line_data;
wire       fetch_line0_hit;
wire       fetch_line1_hit;
wire       fetch_buffered_hit;
wire       line0_prefetch_needed;
wire       line1_prefetch_needed;
wire [8:0] sequential_line_index;
wire       sequential_line_in_range;
wire [63:0] sram_line_data;

assign wb_request      = wb_cyc_i && wb_stb_i;
assign wb_line_index   = wb_adr_i[11:3];
assign fetch_line_index = fetch_addr_i[11:3];
assign line0_hit       = line0_valid && (wb_line_index == line0_index);
assign line1_hit       = line1_valid && (wb_line_index == line1_index);
assign buffered_hit       = line0_hit || line1_hit;
assign completing_hit     = (state == STATE_COMPLETE) &&
                            (wb_line_index == read_line_index);
assign selected_line_data = line0_hit ? line0_data :
                            line1_hit ? line1_data : sram_line_data;
assign fetch_line0_hit    = line0_valid &&
                            (fetch_line_index == line0_index);
assign fetch_line1_hit    = line1_valid &&
                            (fetch_line_index == line1_index);
assign fetch_buffered_hit = fetch_line0_hit || fetch_line1_hit;
assign line0_prefetch_needed = line0_has_next &&
                               !(line1_valid &&
                                 (line1_index == line0_next_index));
assign line1_prefetch_needed = line1_has_next &&
                               !(line0_valid &&
                                 (line0_index == line1_next_index));
assign sequential_line_index = fetch_line0_hit ? line0_next_index
                                                : line1_next_index;
assign sequential_line_in_range =
    (fetch_line0_hit && line0_prefetch_needed) ||
    (fetch_line1_hit && line1_prefetch_needed);

assign wb_ack_o = wb_request && (buffered_hit || completing_hit);
assign wb_err_o = 1'b0;
assign wb_dat_o = wb_adr_i[2] ? selected_line_data[63:32]
                              : selected_line_data[31:0];

// A redirecting FETCH_PC has priority over continuing a stale stream.
always @(*) begin
    launch_read          = 1'b0;
    launch_line_index    = 9'b0;
    launch_buffer_select = replacement_select;

    if (state == STATE_IDLE) begin
        if (fetch_valid_i && !fetch_buffered_hit) begin
            launch_read          = 1'b1;
            launch_line_index    = fetch_line_index;
            launch_buffer_select = replacement_select;
        end
        else if (fetch_valid_i && sequential_line_in_range) begin
            launch_read          = 1'b1;
            launch_line_index    = sequential_line_index;
            launch_buffer_select = fetch_line0_hit ? 1'b1 : 1'b0;
        end
        else if (wb_request && !buffered_hit) begin
            launch_read          = 1'b1;
            launch_line_index    = wb_line_index;
            launch_buffer_select = replacement_select;
        end
    end
    else if (state == STATE_COMPLETE && fetch_valid_i) begin
        if ((fetch_line_index != read_line_index) &&
            !fetch_buffered_hit) begin
            launch_read          = 1'b1;
            launch_line_index    = fetch_line_index;
            launch_buffer_select = ~read_buffer_select;
        end
        else if ((fetch_line_index == read_line_index) &&
                 read_line_has_next) begin
            launch_read          = 1'b1;
            launch_line_index    = read_next_line_index;
            launch_buffer_select = ~read_buffer_select;
        end
    end
end

IM U_IM (
    .clk(clk),
    .rst(rst),
    .enable(launch_read),
    .addr(launch_line_index),
    .data(sram_line_data)
);

`ifdef DIFFTEST
import "DPI-C" function void instructionWishboneCheck(
    input int addr,
    input int read_data
);
`endif

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state                <= STATE_IDLE;
        read_line_index      <= 9'b0;
        read_next_line_index <= 9'b0;
        read_line_has_next   <= 1'b0;
        read_buffer_select   <= 1'b0;
        replacement_select   <= 1'b0;
        line0_index          <= 9'b0;
        line1_index          <= 9'b0;
        line0_next_index     <= 9'b0;
        line1_next_index     <= 9'b0;
        line0_valid          <= 1'b0;
        line1_valid          <= 1'b0;
        line0_has_next       <= 1'b0;
        line1_has_next       <= 1'b0;
        line0_data           <= 64'b0;
        line1_data           <= 64'b0;
    end
    else begin
`ifdef DIFFTEST
        if (wb_ack_o)
            instructionWishboneCheck(wb_adr_i, wb_dat_o);
`endif

        case (state)
        STATE_IDLE: begin
            if (launch_read) begin
                state              <= STATE_WAIT;
                read_line_index    <= launch_line_index;
                read_next_line_index <= launch_line_index + 9'd1;
                read_line_has_next <= (launch_line_index != 9'h1ff);
                read_buffer_select <= launch_buffer_select;
            end
        end
        STATE_WAIT: begin
            state <= STATE_COMPLETE;
        end
        STATE_COMPLETE: begin
            if (read_buffer_select) begin
                line1_index   <= read_line_index;
                line1_next_index <= read_next_line_index;
                line1_valid   <= 1'b1;
                line1_has_next <= read_line_has_next;
                line1_data    <= sram_line_data;
            end
            else begin
                line0_index   <= read_line_index;
                line0_next_index <= read_next_line_index;
                line0_valid   <= 1'b1;
                line0_has_next <= read_line_has_next;
                line0_data    <= sram_line_data;
            end
            replacement_select <= ~read_buffer_select;

            if (launch_read) begin
                state              <= STATE_WAIT;
                read_line_index    <= launch_line_index;
                read_next_line_index <= launch_line_index + 9'd1;
                read_line_has_next <= (launch_line_index != 9'h1ff);
                read_buffer_select <= launch_buffer_select;
                if (launch_buffer_select)
                    line1_valid <= 1'b0;
                else
                    line0_valid <= 1'b0;
            end
            else begin
                state <= STATE_IDLE;
            end
        end
        default: begin
            state <= STATE_IDLE;
        end
        endcase
    end
end

endmodule
