module Alu(
  input         clock,
  input         reset,
  input         io_bundleAluControl_ctrlALUSrc,
  input         io_bundleAluControl_ctrlJAL,
  input  [3:0]  io_bundleAluControl_ctrlOP,
  input         io_bundleAluControl_ctrlBranch,
  input  [31:0] io_dataRead1,
  input  [31:0] io_dataRead2,
  input  [31:0] io_imm,
  input  [31:0] io_pc,
  output        io_resultBranch,
  output [31:0] io_resultAlu
);
  wire [31:0] operand1 = io_bundleAluControl_ctrlJAL ? io_pc : io_dataRead1; // @[ALU.scala 29:20]
  wire [31:0] operand2 = io_bundleAluControl_ctrlALUSrc ? io_imm : io_dataRead2; // @[ALU.scala 30:20]
  wire [31:0] _resultAlu_T_1 = operand1 + operand2; // @[ALU.scala 39:35]
  wire [31:0] _resultAlu_T_3 = operand1 - operand2; // @[ALU.scala 43:35]
  wire [31:0] _resultAlu_T_4 = operand1 & operand2; // @[ALU.scala 47:35]
  wire [31:0] _resultAlu_T_5 = operand1 | operand2; // @[ALU.scala 51:35]
  wire [62:0] _GEN_19 = {{31'd0}, operand1}; // @[ALU.scala 55:35]
  wire [62:0] _resultAlu_T_7 = _GEN_19 << operand2[4:0]; // @[ALU.scala 55:35]
  wire [31:0] _resultAlu_T_9 = operand1 >> operand2[4:0]; // @[ALU.scala 59:35]
  wire [31:0] _resultAlu_T_10 = io_bundleAluControl_ctrlJAL ? io_pc : io_dataRead1; // @[ALU.scala 63:36]
  wire [31:0] _resultAlu_T_13 = $signed(_resultAlu_T_10) >>> operand2[4:0]; // @[ALU.scala 63:62]
  wire [31:0] _resultAlu_T_15 = io_pc + io_imm; // @[ALU.scala 68:32]
  wire  _GEN_0 = 4'hd == io_bundleAluControl_ctrlOP & operand1 != operand2; // @[ALU.scala 32:40 72:26]
  wire [31:0] _GEN_1 = 4'hd == io_bundleAluControl_ctrlOP ? _resultAlu_T_15 : 32'h0; // @[ALU.scala 32:40 73:23]
  wire  _GEN_2 = 4'hc == io_bundleAluControl_ctrlOP ? operand1 == operand2 : _GEN_0; // @[ALU.scala 32:40 67:26]
  wire [31:0] _GEN_3 = 4'hc == io_bundleAluControl_ctrlOP ? _resultAlu_T_15 : _GEN_1; // @[ALU.scala 32:40 68:23]
  wire [31:0] _GEN_4 = 4'hb == io_bundleAluControl_ctrlOP ? _resultAlu_T_13 : _GEN_3; // @[ALU.scala 32:40 63:23]
  wire  _GEN_5 = 4'hb == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_2; // @[ALU.scala 32:40]
  wire [31:0] _GEN_6 = 4'h9 == io_bundleAluControl_ctrlOP ? _resultAlu_T_9 : _GEN_4; // @[ALU.scala 32:40 59:23]
  wire  _GEN_7 = 4'h9 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_5; // @[ALU.scala 32:40]
  wire [62:0] _GEN_8 = 4'h8 == io_bundleAluControl_ctrlOP ? _resultAlu_T_7 : {{31'd0}, _GEN_6}; // @[ALU.scala 32:40 55:23]
  wire  _GEN_9 = 4'h8 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_7; // @[ALU.scala 32:40]
  wire [62:0] _GEN_10 = 4'h5 == io_bundleAluControl_ctrlOP ? {{31'd0}, _resultAlu_T_5} : _GEN_8; // @[ALU.scala 32:40 51:23]
  wire  _GEN_11 = 4'h5 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_9; // @[ALU.scala 32:40]
  wire [62:0] _GEN_12 = 4'h4 == io_bundleAluControl_ctrlOP ? {{31'd0}, _resultAlu_T_4} : _GEN_10; // @[ALU.scala 32:40 47:23]
  wire  _GEN_13 = 4'h4 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_11; // @[ALU.scala 32:40]
  wire [62:0] _GEN_14 = 4'h2 == io_bundleAluControl_ctrlOP ? {{31'd0}, _resultAlu_T_3} : _GEN_12; // @[ALU.scala 32:40 43:23]
  wire  _GEN_15 = 4'h2 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_13; // @[ALU.scala 32:40]
  wire [62:0] _GEN_16 = 4'h1 == io_bundleAluControl_ctrlOP ? {{31'd0}, _resultAlu_T_1} : _GEN_14; // @[ALU.scala 32:40 39:23]
  wire  _GEN_17 = 4'h1 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_15; // @[ALU.scala 32:40]
  wire [62:0] _GEN_18 = 4'h0 == io_bundleAluControl_ctrlOP ? 63'h0 : _GEN_16; // @[ALU.scala 32:40 34:23]
  assign io_resultBranch = 4'h0 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_17; // @[ALU.scala 32:40 35:26]
  assign io_resultAlu = _GEN_18[31:0]; // @[ALU.scala 77:18]
endmodule
