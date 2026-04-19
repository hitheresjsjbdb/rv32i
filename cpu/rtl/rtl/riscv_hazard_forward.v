`timescale 1ns / 1ps
`include "ctrl_signal_def.v"

module riscv_hazard_forward (
    input        ifid_valid,
    input        id_use_rs1,
    input        id_use_rs2,
    input  [4:0] rs1,
    input  [4:0] rs2,
    input  [31:0] rd1,
    input  [31:0] rd2,

    input        idex_valid,
    input        idex_mem_read,
    input  [4:0] idex_rd,
    input  [4:0] idex_rs1,
    input  [4:0] idex_rs2,
    input  [31:0] idex_rs1_val,
    input  [31:0] idex_rs2_val,

    input        exmem_valid,
    input        exmem_rfwrite,
    input        exmem_mem_read,
    input  [4:0] exmem_rd,
    input  [1:0] exmem_wdsel,
    input  [31:0] exmem_pc4,
    input  [31:0] exmem_alu_result,

    input        memwb_valid,
    input        memwb_rfwrite,
    input  [4:0] memwb_rd,
    input  [1:0] memwb_wdsel,
    input  [31:0] memwb_pc4,
    input  [31:0] memwb_alu_result,
    input  [31:0] memwb_mem_data,

    output       id_stall,
    output [31:0] id_rs1_val_byp,
    output [31:0] id_rs2_val_byp,
    output [31:0] ex_rs1_fwd,
    output [31:0] ex_rs2_fwd
);

wire load_use_hazard_rs1;
wire load_use_hazard_rs2;
wire exmem_can_fwd;
wire memwb_can_fwd;
wire [31:0] exmem_fwd_data;
wire [31:0] memwb_fwd_data;

assign load_use_hazard_rs1 = id_use_rs1 && idex_valid && idex_mem_read && (idex_rd != 5'd0) && (idex_rd == rs1);
assign load_use_hazard_rs2 = id_use_rs2 && idex_valid && idex_mem_read && (idex_rd != 5'd0) && (idex_rd == rs2);
assign id_stall = ifid_valid && (load_use_hazard_rs1 || load_use_hazard_rs2);

assign exmem_can_fwd = exmem_valid && exmem_rfwrite && (exmem_rd != 5'd0) && !exmem_mem_read;
assign memwb_can_fwd = memwb_valid && memwb_rfwrite && (memwb_rd != 5'd0);

assign exmem_fwd_data = (exmem_wdsel == `WDSel_FromPC) ? exmem_pc4 : exmem_alu_result;
assign memwb_fwd_data = (memwb_wdsel == `WDSel_FromMEM) ? memwb_mem_data :
                        (memwb_wdsel == `WDSel_FromPC)  ? memwb_pc4 :
                                                           memwb_alu_result;

assign id_rs1_val_byp = (memwb_can_fwd && (memwb_rd == rs1)) ? memwb_fwd_data : rd1;
assign id_rs2_val_byp = (memwb_can_fwd && (memwb_rd == rs2)) ? memwb_fwd_data : rd2;

assign ex_rs1_fwd = (exmem_can_fwd && (exmem_rd == idex_rs1)) ? exmem_fwd_data :
                    (memwb_can_fwd && (memwb_rd == idex_rs1)) ? memwb_fwd_data :
                                                               idex_rs1_val;

assign ex_rs2_fwd = (exmem_can_fwd && (exmem_rd == idex_rs2)) ? exmem_fwd_data :
                    (memwb_can_fwd && (memwb_rd == idex_rs2)) ? memwb_fwd_data :
                                                               idex_rs2_val;

endmodule
