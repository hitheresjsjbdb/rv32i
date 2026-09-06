`timescale 1ns / 1ps

// Combinational interpretation of a data-memory response.
module MemoryResponseControl(
    input  dm_ready,
    input  dm_error,
    output mem_load_ready
);

assign mem_load_ready = dm_ready && !dm_error;

endmodule
