`timescale 1ns / 1ps

// Top-level integration wrapper.
// Keep the public entry module as `riscv`, while logic lives in `riscv_core`.
module riscv (
    input  clk,
    input  rst,
    output done
);

riscv_core U_RISCV_CORE (
    .clk(clk),
    .rst(rst),
    .done(done)
);

endmodule
