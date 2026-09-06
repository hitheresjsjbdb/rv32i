`timescale 1ns / 1ps

`include "ctrl_signal_def.v"

// Selects the value written back to the register file in the WB stage.
module WritebackMux(
    input  [1:0]  wdsel,
    input  [31:0] alu_data,
    input  [31:0] mem_data,
    input  [31:0] pc_data,
    output [31:0] writeback_data
);

assign writeback_data =
    (wdsel == `WDSel_FromMEM) ? mem_data :
    (wdsel == `WDSel_FromPC)  ? pc_data  :
                                alu_data;

endmodule
