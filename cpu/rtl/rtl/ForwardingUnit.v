`timescale 1ns / 1ps

`include "ctrl_signal_def.v"

module ForwardingUnit(
    input         id_valid,
    input  [4:0]  id_rs1,
    input  [4:0]  id_rs2,
    input  [4:0]  ex_rd,
    input         ex_valid,
    input         ex_rfwrite,
    input  [1:0]  ex_wdsel,
    input  [31:0] ex_pca4,
    input  [31:0] ex_alu_result,
    input  [4:0]  mem_rd,
    input         mem_valid,
    input         mem_rfwrite,
    input  [1:0]  mem_wdsel,
    input  [31:0] mem_pca4,
    input  [31:0] mem_alu_result,
    input  [31:0] mem_load_data,
    input         mem_load_ready,
    input  [4:0]  wb_rd,
    input         wb_valid,
    input         wb_rfwrite,
    input  [31:0] wb_data,
    input  [31:0] id_raw_rd1,
    input  [31:0] id_raw_rd2,

    output        forward1,
    output        forward2,
    output [31:0] id_rd1,
    output [31:0] id_rd2,
    output [31:0] id_control_rd1,
    output [31:0] id_control_rd2
);

wire wb_forward1;
wire wb_forward2;
wire mem_forward1;
wire mem_forward2;
wire mem_control_forward1;
wire mem_control_forward2;
wire ex_forward1;
wire ex_forward2;
wire [31:0] ex_forward_data;
wire [31:0] mem_forward_data;
wire [31:0] mem_control_forward_data;

assign wb_forward1 = id_valid && wb_valid && (id_rs1 == wb_rd) &&
                     wb_rfwrite && (wb_rd != 5'b0);
assign wb_forward2 = id_valid && wb_valid && (id_rs2 == wb_rd) &&
                     wb_rfwrite && (wb_rd != 5'b0);

assign ex_forward1 = id_valid && ex_valid && (id_rs1 == ex_rd) && ex_rfwrite &&
                     (ex_wdsel != `WDSel_FromMEM) && (ex_rd != 5'b0);
assign ex_forward2 = id_valid && ex_valid && (id_rs2 == ex_rd) && ex_rfwrite &&
                     (ex_wdsel != `WDSel_FromMEM) && (ex_rd != 5'b0);
assign mem_forward1 = id_valid && mem_valid && (id_rs1 == mem_rd) && mem_rfwrite &&
                      ((mem_wdsel != `WDSel_FromMEM) || mem_load_ready) &&
                      (mem_rd != 5'b0);
assign mem_forward2 = id_valid && mem_valid && (id_rs2 == mem_rd) && mem_rfwrite &&
                      ((mem_wdsel != `WDSel_FromMEM) || mem_load_ready) &&
                      (mem_rd != 5'b0);
assign mem_control_forward1 = id_valid && mem_valid &&
                              (id_rs1 == mem_rd) && mem_rfwrite &&
                              (mem_wdsel != `WDSel_FromMEM) &&
                              (mem_rd != 5'b0);
assign mem_control_forward2 = id_valid && mem_valid &&
                              (id_rs2 == mem_rd) && mem_rfwrite &&
                              (mem_wdsel != `WDSel_FromMEM) &&
                              (mem_rd != 5'b0);

assign ex_forward_data = (ex_wdsel == `WDSel_FromPC) ?
                         ex_pca4 : ex_alu_result;
assign mem_forward_data = (mem_wdsel == `WDSel_FromMEM) ? mem_load_data :
                          (mem_wdsel == `WDSel_FromPC) ? mem_pca4 :
                          mem_alu_result;
// Control transfers wait for loads to reach WB.  Keeping DM load data out of
// this data mux physically cuts the data-SRAM-to-fetch-address timing path.
assign mem_control_forward_data = (mem_wdsel == `WDSel_FromPC) ?
                                  mem_pca4 : mem_alu_result;

assign forward1 = ex_forward1 || mem_forward1 || wb_forward1;
assign forward2 = ex_forward2 || mem_forward2 || wb_forward2;

// The youngest producer wins: EX, then MEM, then WB.
assign id_rd1 = ex_forward1 ? ex_forward_data :
                mem_forward1 ? mem_forward_data :
                wb_forward1 ? wb_data : 32'h0;
assign id_rd2 = ex_forward2 ? ex_forward_data :
                mem_forward2 ? mem_forward_data :
                wb_forward2 ? wb_data : 32'h0;

assign id_control_rd1 = ex_forward1 ? ex_forward_data :
                        mem_control_forward1 ? mem_control_forward_data :
                        wb_forward1 ? wb_data : id_raw_rd1;
assign id_control_rd2 = ex_forward2 ? ex_forward_data :
                        mem_control_forward2 ? mem_control_forward_data :
                        wb_forward2 ? wb_data : id_raw_rd2;

endmodule
