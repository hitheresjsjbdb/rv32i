`timescale 1ns / 1ps

module WishboneInstructionMaster_tb;

reg         clk;
reg         rst;
reg         req_valid;
reg  [31:0] req_addr;
wire        rsp_valid;
wire        rsp_error;
wire [31:0] rsp_rdata;
wire [31:0] wb_adr_o;
wire [31:0] wb_dat_o;
reg  [31:0] wb_dat_i;
wire [3:0]  wb_sel_o;
wire        wb_we_o;
wire        wb_cyc_o;
wire        wb_stb_o;
reg         wb_ack_i;
reg         wb_err_i;

WishboneInstructionMaster dut (
    .clk(clk), .rst(rst),
    .req_valid(req_valid), .req_addr(req_addr),
    .rsp_valid(rsp_valid), .rsp_error(rsp_error),
    .rsp_rdata(rsp_rdata),
    .wb_adr_o(wb_adr_o), .wb_dat_o(wb_dat_o), .wb_dat_i(wb_dat_i),
    .wb_sel_o(wb_sel_o), .wb_we_o(wb_we_o),
    .wb_cyc_o(wb_cyc_o), .wb_stb_o(wb_stb_o),
    .wb_ack_i(wb_ack_i), .wb_err_i(wb_err_i)
);

always #5 clk = ~clk;

task check;
    input condition;
    input [255:0] message;
    begin
        if (!condition) begin
            $display("FAIL: %0s", message);
            $finish;
        end
    end
endtask

initial begin
    clk       = 1'b0;
    rst       = 1'b1;
    req_valid = 1'b0;
    req_addr  = 32'b0;
    wb_dat_i  = 32'b0;
    wb_ack_i  = 1'b0;
    wb_err_i  = 1'b0;

    @(posedge clk);
    #1 rst = 1'b0;

    req_valid = 1'b1;
    req_addr  = 32'h0000_2000;
    @(posedge clk);
    #1;
    req_addr = 32'h0000_3000;
    check(wb_adr_o == 32'h0000_2000,
          "pending request address changed after redirect");

    wb_dat_i = 32'h1111_1111;
    wb_ack_i = 1'b1;
    #1;
    check(!rsp_valid, "stale response was accepted");
    @(posedge clk);
    #1 wb_ack_i = 1'b0;
    check(wb_adr_o == 32'h0000_3000,
          "redirect target request did not start");

    wb_dat_i = 32'h2222_2222;
    wb_ack_i = 1'b1;
    #1;
    check(rsp_valid && !rsp_error && rsp_rdata == 32'h2222_2222,
          "current response was not returned");
    @(posedge clk);
    #1 wb_ack_i = 1'b0;

    req_addr = 32'h0000_3004;
    wb_dat_i = 32'h3333_3333;
    wb_ack_i = 1'b1;
    #1;
    check(rsp_valid && wb_cyc_o && wb_stb_o,
          "zero-wait response was not accepted");

    $display("PASS: WishboneInstructionMaster directed tests");
    $finish;
end

endmodule
