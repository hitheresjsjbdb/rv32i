`include "ctrl_signal_def.v"

module DM(
    Addr, WD, DMCtrl, clk, rst, RD, use_pipe, WD_pipe, DMCtrl_pipe
);
    input  [11:2] Addr;
    input  [31:0] WD;
    input         DMCtrl;
    input         clk;
    input         rst;
    input         use_pipe;
    input  [31:0] WD_pipe;
    input         DMCtrl_pipe;
    output reg [31:0] RD;

    reg [31:0] memory[0:1023];
    wire use_pipe_en;
    wire [31:0] wd_sel;
    wire dmctrl_sel;

    assign use_pipe_en = (use_pipe === 1'b1);
    assign wd_sel = use_pipe_en ? WD_pipe : WD;
    assign dmctrl_sel = use_pipe_en ? DMCtrl_pipe : DMCtrl;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RD <= 32'b0;
        end else if (dmctrl_sel) begin
            memory[Addr] <= wd_sel;
        end else begin
            RD <= memory[Addr];
        end
    end

endmodule
