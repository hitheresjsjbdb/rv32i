`include "ctrl_signal_def.v"

module Flopr #(parameter WIDTH = 32, parameter USE_EN = 0)(clk, rst, en, in_data, out_data);
    input         clk;
    input         rst;
    input         en;
    input  [WIDTH-1:0] in_data;
    output reg [WIDTH-1:0] out_data;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_data <= {WIDTH{1'b0}};
        end
        else if (USE_EN == 0 || en) begin
            out_data <= in_data;
        end
    end

endmodule
