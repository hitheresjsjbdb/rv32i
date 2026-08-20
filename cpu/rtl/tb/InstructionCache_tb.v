`timescale 1ns / 1ps

module InstructionCache_tb;

reg clk;
reg rst;
reg req_valid;
reg [31:0] req_addr;
wire rsp_valid;
wire rsp_error;
wire [31:0] rsp_data;
wire mem_req;
wire [31:0] mem_addr;
wire mem_ready;
wire mem_error;
wire [31:0] mem_rdata;

integer request_count;

InstructionCache dut (
    .clk(clk), .rst(rst),
    .req_valid(req_valid), .req_addr(req_addr),
    .rsp_valid(rsp_valid), .rsp_error(rsp_error), .rsp_data(rsp_data),
    .mem_req(mem_req), .mem_addr(mem_addr),
    .mem_ready(mem_ready), .mem_error(mem_error), .mem_rdata(mem_rdata)
);

always #5 clk = ~clk;

function [31:0] word_data;
    input [31:0] address;
    begin
        word_data = address[2]
            ? (32'hb000_0000 | {23'b0, address[11:3]})
            : (32'ha000_0000 | {23'b0, address[11:3]});
    end
endfunction

assign mem_ready = mem_req;
assign mem_error = 1'b0;
assign mem_rdata = word_data(mem_addr);

always @(posedge clk) begin
    if (mem_req)
        request_count <= request_count + 1;
end

task wait_for_response;
    input [31:0] expected;
    integer timeout;
    begin
        timeout = 0;
        while (!rsp_valid && timeout < 12) begin
            @(negedge clk);
            timeout = timeout + 1;
        end
        if (!rsp_valid) begin
            $display("FAIL: response timeout for address 0x%08x", req_addr);
            $fatal;
        end
        if (rsp_data !== expected) begin
            $display("FAIL: address 0x%08x returned 0x%08x, expected 0x%08x",
                     req_addr, rsp_data, expected);
            $fatal;
        end
    end
endtask

task request_word;
    input [31:0] address;
    reg [31:0] expected;
    begin
        @(negedge clk);
        req_addr = address;
        req_valid = 1'b1;
        expected = address[2]
            ? (32'hb000_0000 | {23'b0, address[11:3]})
            : (32'ha000_0000 | {23'b0, address[11:3]});
        wait_for_response(expected);
        @(negedge clk);
        req_valid = 1'b0;
    end
endtask

task wait_for_refill_complete;
    integer timeout;
    begin
        timeout = 0;
        while (mem_req && timeout < 4) begin
            @(negedge clk);
            timeout = timeout + 1;
        end
        if (mem_req) begin
            $display("FAIL: background refill did not complete");
            $fatal;
        end
    end
endtask

initial begin
    clk = 1'b0;
    rst = 1'b1;
    req_valid = 1'b0;
    req_addr = 32'b0;
    request_count = 0;

    repeat (2) @(posedge clk);
    rst = 1'b0;

    // Cold miss followed by the other word in the same 64-bit line.
    request_word(32'h0000_2000);
    wait_for_refill_complete;
    if (request_count != 2) $fatal;
    request_word(32'h0000_2004);
    if (request_count != 2) begin
        $display("FAIL: second word in a line missed");
        $fatal;
    end

    // 0x2080 has the same index and a different tag, so it must replace 0x2000.
    request_word(32'h0000_2080);
    wait_for_refill_complete;
    if (request_count != 4) $fatal;
    request_word(32'h0000_2000);
    wait_for_refill_complete;
    if (request_count != 6) begin
        $display("FAIL: direct-mapped conflict did not replace the old line");
        $fatal;
    end

    // Change the CPU-side address while a miss is outstanding. The refill
    // must still use the address captured with the original memory request.
    @(negedge clk);
    req_addr = 32'h0000_2010;
    req_valid = 1'b1;
    @(posedge clk);
    @(negedge clk);
    req_addr = 32'h0000_2050;
    req_valid = 1'b0;
    repeat (3) @(negedge clk);
    request_word(32'h0000_2010);
    wait_for_refill_complete;
    if (request_count != 8) begin
        $display("FAIL: miss address was not held through refill");
        $fatal;
    end

    // Reset invalidates tags without resetting the data array.
    @(negedge clk);
    rst = 1'b1;
    @(posedge clk);
    @(negedge clk);
    rst = 1'b0;
    request_word(32'h0000_2010);
    wait_for_refill_complete;
    if (request_count != 10) begin
        $display("FAIL: reset did not invalidate the cache");
        $fatal;
    end

    $display("PASS: InstructionCache directed tests");
    $finish;
end

endmodule
