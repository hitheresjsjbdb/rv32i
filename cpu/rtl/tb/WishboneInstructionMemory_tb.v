`timescale 1ns / 1ps

module WishboneInstructionMemory_tb;

reg         clk;
reg         rst;
reg  [31:0] wb_adr_i;
reg         wb_cyc_i;
reg         wb_stb_i;
reg         fetch_valid_i;
reg  [31:0] fetch_addr_i;
wire [31:0] wb_dat_o;
wire        wb_ack_o;
wire        wb_err_o;

integer cycles;

WishboneInstructionMemory dut (
    .clk(clk), .rst(rst),
    .wb_adr_i(wb_adr_i),
    .wb_cyc_i(wb_cyc_i), .wb_stb_i(wb_stb_i),
    .fetch_valid_i(fetch_valid_i), .fetch_addr_i(fetch_addr_i),
    .wb_dat_o(wb_dat_o), .wb_ack_o(wb_ack_o), .wb_err_o(wb_err_o)
);

always #5 clk = ~clk;

task fail;
    input [511:0] message;
    begin
        $display("FAIL: %0s", message);
        $fatal(1);
    end
endtask

task reset_dut;
    begin
        rst           = 1'b1;
        wb_adr_i      = 32'b0;
        wb_cyc_i      = 1'b0;
        wb_stb_i      = 1'b0;
        fetch_valid_i = 1'b0;
        fetch_addr_i  = 32'b0;
        @(posedge clk);
        #1 rst = 1'b0;
        @(posedge clk);
        #1;
    end
endtask

task request_word;
    input [31:0] address;
    input [31:0] expected;
    begin
        fetch_valid_i = 1'b1;
        fetch_addr_i  = address;
        wb_adr_i      = address;
        wb_cyc_i      = 1'b1;
        wb_stb_i      = 1'b1;
        cycles        = 0;
        #1;
        while (!wb_ack_o && (cycles < 12)) begin
            @(posedge clk);
            #1 cycles = cycles + 1;
        end
        if (!wb_ack_o)
            fail("instruction request timed out");
        if (wb_err_o)
            fail("local instruction memory returned an error");
        if (wb_dat_o !== expected) begin
            $display("  address=%08x expected=%08x actual=%08x",
                     address, expected, wb_dat_o);
            fail("instruction response data mismatch");
        end
        wb_cyc_i = 1'b0;
        wb_stb_i = 1'b0;
    end
endtask

initial begin
    clk = 1'b0;
    rst = 1'b0;

    // Each pair of words forms one 64-bit SRAM line.
    dut.U_IM.memory[0]    = 32'ha000_0000;
    dut.U_IM.memory[1]    = 32'ha000_0001;
    dut.U_IM.memory[2]    = 32'hb000_0000;
    dut.U_IM.memory[3]    = 32'hb000_0001;
    dut.U_IM.memory[4]    = 32'hc000_0000;
    dut.U_IM.memory[5]    = 32'hc000_0001;
    dut.U_IM.memory[6]    = 32'hd000_0000;
    dut.U_IM.memory[7]    = 32'hd000_0001;
    dut.U_IM.memory[12]   = 32'he000_0000;
    dut.U_IM.memory[13]   = 32'he000_0001;
    dut.U_IM.memory[1022] = 32'hf000_0000;
    dut.U_IM.memory[1023] = 32'hf000_0001;

    // Cold line fill and both halves of the buffered line.
    reset_dut();
    request_word(32'h0000_2000, 32'ha000_0000);
    request_word(32'h0000_2004, 32'ha000_0001);

    // Leave the current fetch active long enough for line 0x2008 to prefetch.
    fetch_addr_i = 32'h0000_2004;
    repeat (3) begin
        @(posedge clk);
        #1;
    end
    wb_adr_i = 32'h0000_2008;
    wb_cyc_i = 1'b1;
    wb_stb_i = 1'b1;
    #1;
    if (!wb_ack_o || (wb_dat_o !== 32'hb000_0000))
        fail("sequential next-line prefetch did not hit");
    wb_cyc_i = 1'b0;
    wb_stb_i = 1'b0;

    // Redirect while the sequential line after 0x2010 is still being read.
    reset_dut();
    request_word(32'h0000_2010, 32'hc000_0000);
    @(posedge clk);
    #1;
    fetch_addr_i = 32'h0000_2030;
    wb_adr_i     = 32'h0000_2030;
    wb_cyc_i     = 1'b1;
    wb_stb_i     = 1'b1;
    if (wb_ack_o)
        fail("redirect target incorrectly acknowledged with stale prefetch data");
    cycles = 0;
    while (!wb_ack_o && (cycles < 12)) begin
        @(posedge clk);
        #1 cycles = cycles + 1;
    end
    if (!wb_ack_o || (wb_dat_o !== 32'he000_0000))
        fail("redirect target did not replace pending sequential prefetch");
    wb_cyc_i = 1'b0;
    wb_stb_i = 1'b0;

    // The last local line must not trigger a speculative read at 0x3000.
    reset_dut();
    request_word(32'h0000_2ffc, 32'hf000_0001);
    fetch_addr_i = 32'h0000_2ffc;
    repeat (3) begin
        @(posedge clk);
        #1;
    end
    if (dut.state != 2'b00)
        fail("prefetch crossed the local instruction SRAM boundary");
    if (dut.read_line_index != 9'h1ff)
        fail("local boundary test launched an unexpected line read");

    $display("PASS: WishboneInstructionMemory stream-buffer directed tests");
    $finish;
end

endmodule
