`include "ctrl_signal_def.v"

module Flopr #(parameter WIDTH = 32, parameter USE_EN = 0)(
    clk, rst, en, in_data, out_data, pipe_use, pipe_in_data
);
    input         clk;
    input         rst;
    input         en;
    input  [WIDTH-1:0] in_data;
    input         pipe_use;
    input  [WIDTH-1:0] pipe_in_data;
    output reg [WIDTH-1:0] out_data;
    wire use_pipe_en;
    wire [WIDTH-1:0] selected_in_data;

    assign use_pipe_en = (pipe_use === 1'b1);
    assign selected_in_data = use_pipe_en ? pipe_in_data : in_data;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_data <= {WIDTH{1'b0}};
        end
        else if (USE_EN == 0 || en) begin
            out_data <= selected_in_data;
        end
    end

endmodule
