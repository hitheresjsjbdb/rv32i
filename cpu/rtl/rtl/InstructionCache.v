`timescale 1ns / 1ps

module InstructionCache(
    input         clk,
    input         rst,
    input         req_valid,
    input  [31:0] req_addr,
    output        rsp_valid,
    output        rsp_error,
    output [31:0] rsp_data,

    output        mem_req,
    output [31:0] mem_addr,
    input         mem_ready,
    input         mem_error,
    input  [31:0] mem_rdata
);

localparam STATE_IDLE   = 2'b00;
localparam STATE_LOW    = 2'b01;
localparam STATE_HIGH   = 2'b10;
localparam STATE_ERROR  = 2'b11;

reg [1:0] state;
reg [28:0] miss_line_addr;
reg        miss_word_select;
reg [31:0] refill_word;
reg [63:0] data_array [0:15];
reg [24:0] tag_array [0:15];
reg [15:0] valid_array;

wire [3:0] req_index;
wire [24:0] req_tag;
wire [63:0] hit_line;
wire hit;
wire idle_miss;
wire refill_response;
wire critical_word_response;
wire [63:0] completed_refill_line;

assign req_index = req_addr[6:3];
assign req_tag   = req_addr[31:7];
assign hit_line  = data_array[req_index];
assign hit       = valid_array[req_index] &&
                   (tag_array[req_index] == req_tag);
assign idle_miss = (state == STATE_IDLE) && req_valid && !hit;
assign refill_response = req_valid && (state == STATE_HIGH) &&
                         mem_ready && !mem_error &&
                         (req_addr[31:3] == miss_line_addr);
assign critical_word_response = req_valid &&
                                ((state == STATE_LOW) || idle_miss) &&
                                mem_ready && !mem_error &&
                                ((state == STATE_IDLE) ||
                                 ((req_addr[2] == miss_word_select) &&
                                  (req_addr[31:3] == miss_line_addr)));
assign completed_refill_line = miss_word_select
                             ? {refill_word, mem_rdata}
                             : {mem_rdata, refill_word};

// Return the requested word in the same cycle that the final refill word is
// accepted. Both candidates are registered by this point, so this removes a
// protocol bubble without exposing the slow SRAM Q path to the fetch stage.
assign rsp_valid = req_valid && (((state == STATE_IDLE) && hit) ||
                                 critical_word_response ||
                                 refill_response ||
                                 (state == STATE_ERROR));
assign rsp_error = req_valid && (state == STATE_ERROR);
assign rsp_data  = critical_word_response ? mem_rdata :
                   refill_response
                 ? (req_addr[2] ? completed_refill_line[63:32]
                                : completed_refill_line[31:0])
                 : (req_addr[2] ? hit_line[63:32] : hit_line[31:0]);

// A 64-bit cache line is refilled with two 32-bit Wishbone transactions. The
// requested word is transferred first so either word can restart the CPU.
assign mem_req  = idle_miss || (state == STATE_LOW) || (state == STATE_HIGH);
assign mem_addr = idle_miss ? req_addr :
                  ({miss_line_addr, 3'b000} +
                  ((state == STATE_LOW)
                      ? (miss_word_select ? 32'd4 : 32'd0)
                      : (miss_word_select ? 32'd0 : 32'd4)));

`ifdef DIFFTEST
import "DPI-C" function void icacheRefillCheck(
    input int addr,
    input longint unsigned line_data
);
import "DPI-C" function void icacheAccessCheck(
    input int addr,
    input int instruction
);
import "DPI-C" function void icacheCriticalAccessCheck(
    input int addr,
    input int instruction
);
`endif

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state       <= STATE_IDLE;
        miss_line_addr <= 29'b0;
        miss_word_select <= 1'b0;
        valid_array <= 16'b0;
    end
    else begin
`ifdef DIFFTEST
        if ((state == STATE_HIGH) && mem_ready && !mem_error)
            icacheRefillCheck({miss_line_addr, 3'b000},
                              completed_refill_line);

        if (critical_word_response)
            icacheCriticalAccessCheck(req_addr, rsp_data);
        else if (req_valid && rsp_valid)
            icacheAccessCheck(req_addr, rsp_data);
`endif

        case (state)
            STATE_IDLE: begin
                if (req_valid && !hit) begin
                    miss_line_addr <= req_addr[31:3];
                    miss_word_select <= req_addr[2];
                    if (mem_ready) begin
                        if (mem_error) begin
                            state <= STATE_ERROR;
                        end
                        else begin
                            refill_word <= mem_rdata;
                            state <= STATE_HIGH;
                        end
                    end
                    else begin
                        state <= STATE_LOW;
                    end
                end
            end

            STATE_LOW: begin
                if (mem_ready) begin
                    if (mem_error) begin
                        state <= STATE_ERROR;
                    end
                    else begin
                        refill_word <= mem_rdata;
                        state      <= STATE_HIGH;
                    end
                end
            end

            STATE_HIGH: begin
                if (mem_ready) begin
                    if (mem_error) begin
                        state <= STATE_ERROR;
                    end
                    else begin
                        data_array[miss_line_addr[3:0]] <= completed_refill_line;
                        tag_array[miss_line_addr[3:0]] <=
                            miss_line_addr[28:4];
                        valid_array[miss_line_addr[3:0]] <= 1'b1;
                        state <= STATE_IDLE;
                    end
                end
            end

            STATE_ERROR: begin
                state <= STATE_IDLE;
            end

            default: begin
                state <= STATE_IDLE;
            end
        endcase
    end
end

endmodule
