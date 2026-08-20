`timescale 1ns / 1ps

module PC(clk, rst, write_enable, next_pc, pc);
    input  clk;
    input  rst;
    input  write_enable;
    input  [31:0] next_pc;
    output reg [31:0] pc;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 32'h0000_2000;
    end
    else if (write_enable) begin
        pc <= next_pc;
    end

end

 
endmodule
