`include "global_def.v"
`include "ctrl_signal_def.v"

module RF(
input [4:0] RR1,
input [4:0] RR2,
input [4:0] WR,
input [31:0] WD,
input RFWrite,
input clk,
input use_pipe,
input [4:0] RR1_pipe,
input [4:0] RR2_pipe,
input [31:0] WD_pipe,
input RFWrite_pipe,
output [31:0] RD1,
output [31:0] RD2
);

reg [31:0] register [1:31];
wire use_pipe_en;
wire [4:0] rr1_sel;
wire [4:0] rr2_sel;
wire [31:0] wd_sel;
wire rfwrite_sel;

assign use_pipe_en = (use_pipe === 1'b1);
assign rr1_sel = use_pipe_en ? RR1_pipe : RR1;
assign rr2_sel = use_pipe_en ? RR2_pipe : RR2;
assign wd_sel = use_pipe_en ? WD_pipe : WD;
assign rfwrite_sel = use_pipe_en ? RFWrite_pipe : RFWrite;

always @(posedge clk) begin
  if ((WR != 0) && (rfwrite_sel == 1'b1)) begin
    register[WR] <= wd_sel;
`ifdef DEBUG
    $display("R[00-07]=%8X %8X %8X %8X %8X %8X %8X %8X", 0, register[1], register[2], register[3], register[4], register[5], register[6], register[7]);
    $display("R[08-15]=%8X %8X %8X %8X %8X %8X %8X %8X", register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15]);
    $display("R[16-23]=%8X %8X %8X %8X %8X %8X %8X %8X", register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23]);
    $display("R[24-31]=%8X %8X %8X %8X %8X %8X %8X %8X", register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
`endif
  end
end

assign RD1 = (rr1_sel == 0) ? 32'h0 : register[rr1_sel];
assign RD2 = (rr2_sel == 0) ? 32'h0 : register[rr2_sel];

`ifdef difftest

export "DPI-C" function DPI_getReg;
function int DPI_getReg(input int idx);
  return (idx == 0) ? 32'h0 : register[idx];
endfunction

`endif

endmodule
