module PCReg(
  input         clock,
  input         reset,
  output [31:0] io_addrOut,
  input         io_ctrlJump,
  input         io_ctrlBranch,
  input         io_resultBranch,
  input  [31:0] io_addrTarget
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] regPC; // @[PCReg.scala 21:24]
  wire [31:0] _regPC_T_1 = regPC + 32'h4; // @[PCReg.scala 26:24]
  assign io_addrOut = regPC; // @[PCReg.scala 29:16]
  always @(posedge clock) begin
    if (reset) begin // @[PCReg.scala 21:24]
      regPC <= 32'h0; // @[PCReg.scala 21:24]
    end else if (io_ctrlJump | io_ctrlBranch & io_resultBranch) begin // @[PCReg.scala 23:62]
      regPC <= io_addrTarget; // @[PCReg.scala 24:15]
    end else begin
      regPC <= _regPC_T_1; // @[PCReg.scala 26:15]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  regPC = _RAND_0[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module MemInst(
  input         clock,
  input  [31:0] io_addr,
  output [31:0] io_inst,
  input         io_extWriteEn,
  input  [31:0] io_extWriteAddr,
  input  [31:0] io_extWriteData
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
  reg [31:0] mem [0:1023]; // @[MemInst.scala 29:18]
  wire  mem_io_inst_MPORT_en; // @[MemInst.scala 29:18]
  wire [9:0] mem_io_inst_MPORT_addr; // @[MemInst.scala 29:18]
  wire [31:0] mem_io_inst_MPORT_data; // @[MemInst.scala 29:18]
  wire [31:0] mem_MPORT_data; // @[MemInst.scala 29:18]
  wire [9:0] mem_MPORT_addr; // @[MemInst.scala 29:18]
  wire  mem_MPORT_mask; // @[MemInst.scala 29:18]
  wire  mem_MPORT_en; // @[MemInst.scala 29:18]
  wire [31:0] cpuWordAddr = {{2'd0}, io_addr[31:2]}; // @[MemInst.scala 38:31]
  wire [31:0] extWordAddr = {{2'd0}, io_extWriteAddr[31:2]}; // @[MemInst.scala 39:39]
  assign mem_io_inst_MPORT_en = 1'h1;
  assign mem_io_inst_MPORT_addr = cpuWordAddr[9:0];
  assign mem_io_inst_MPORT_data = mem[mem_io_inst_MPORT_addr]; // @[MemInst.scala 29:18]
  assign mem_MPORT_data = io_extWriteData;
  assign mem_MPORT_addr = extWordAddr[9:0];
  assign mem_MPORT_mask = 1'h1;
  assign mem_MPORT_en = io_extWriteEn;
  assign io_inst = mem_io_inst_MPORT_data; // @[MemInst.scala 46:13]
  always @(posedge clock) begin
    if (mem_MPORT_en & mem_MPORT_mask) begin
      mem[mem_MPORT_addr] <= mem_MPORT_data; // @[MemInst.scala 29:18]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1024; initvar = initvar+1)
    mem[initvar] = _RAND_0[31:0];
`endif // RANDOMIZE_MEM_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ImmGen(
  input  [31:0] io_inst,
  input  [2:0]  io_immSel,
  output [31:0] io_imm
);
  wire [19:0] _imm_i_T_2 = io_inst[31] ? 20'hfffff : 20'h0; // @[Bitwise.scala 72:12]
  wire [31:0] imm_i = {_imm_i_T_2,io_inst[31:20]}; // @[Cat.scala 30:58]
  wire [31:0] imm_s = {_imm_i_T_2,io_inst[31:25],io_inst[11:7]}; // @[Cat.scala 30:58]
  wire [18:0] _imm_b_T_2 = io_inst[31] ? 19'h7ffff : 19'h0; // @[Bitwise.scala 72:12]
  wire [31:0] imm_b = {_imm_b_T_2,io_inst[31],io_inst[7],io_inst[30:25],io_inst[11:8],1'h0}; // @[Cat.scala 30:58]
  wire [10:0] _imm_j_T_2 = io_inst[31] ? 11'h7ff : 11'h0; // @[Bitwise.scala 72:12]
  wire [31:0] imm_j = {_imm_j_T_2,io_inst[31],io_inst[19:12],io_inst[20],io_inst[30:21],1'h0}; // @[Cat.scala 30:58]
  wire [31:0] _GEN_0 = 3'h4 == io_immSel ? imm_j : 32'h0; // @[ImmGen.scala 63:23 74:17]
  wire [31:0] _GEN_1 = 3'h3 == io_immSel ? imm_b : _GEN_0; // @[ImmGen.scala 63:23 71:17]
  wire [31:0] _GEN_2 = 3'h2 == io_immSel ? imm_s : _GEN_1; // @[ImmGen.scala 63:23 68:17]
  assign io_imm = 3'h1 == io_immSel ? imm_i : _GEN_2; // @[ImmGen.scala 63:23 65:17]
endmodule
module Decoder(
  input  [31:0] io_inst,
  output        io_bundleCtrl_ctrlJump,
  output        io_bundleCtrl_ctrlJAL,
  output        io_bundleCtrl_ctrlBranch,
  output        io_bundleCtrl_ctrlRegWrite,
  output        io_bundleCtrl_ctrlLoad,
  output        io_bundleCtrl_ctrlStore,
  output        io_bundleCtrl_ctrlALUSrc,
  output [3:0]  io_bundleCtrl_ctrlOP,
  output [4:0]  io_bundleReg_rs1,
  output [4:0]  io_bundleReg_rs2,
  output [4:0]  io_bundleReg_rd,
  output [31:0] io_imm
);
  wire [31:0] immGen_io_inst; // @[Decoder.scala 202:24]
  wire [2:0] immGen_io_immSel; // @[Decoder.scala 202:24]
  wire [31:0] immGen_io_imm; // @[Decoder.scala 202:24]
  wire [6:0] opcode = io_inst[6:0]; // @[Decoder.scala 26:25]
  wire [2:0] funct3 = io_inst[14:12]; // @[Decoder.scala 27:25]
  wire  bit30 = io_inst[30]; // @[Decoder.scala 28:25]
  wire  _T_1 = 3'h0 == funct3; // @[Decoder.scala 85:28]
  wire [3:0] _GEN_0 = bit30 ? 4'h2 : 4'h1; // @[Decoder.scala 87:33 88:32 90:32]
  wire  _T_3 = 3'h6 == funct3; // @[Decoder.scala 85:28]
  wire  _T_4 = 3'h1 == funct3; // @[Decoder.scala 85:28]
  wire [3:0] _GEN_1 = 3'h5 == funct3 ? 4'h9 : 4'h1; // @[Decoder.scala 103:28 85:28]
  wire [3:0] _GEN_2 = 3'h1 == funct3 ? 4'h8 : _GEN_1; // @[Decoder.scala 100:28 85:28]
  wire [3:0] _GEN_3 = 3'h6 == funct3 ? 4'h5 : _GEN_2; // @[Decoder.scala 85:28 97:28]
  wire [3:0] _GEN_4 = 3'h7 == funct3 ? 4'h4 : _GEN_3; // @[Decoder.scala 85:28 94:28]
  wire [3:0] _GEN_5 = 3'h0 == funct3 ? _GEN_0 : _GEN_4; // @[Decoder.scala 85:28]
  wire [3:0] _GEN_6 = _T_3 ? 4'h5 : 4'h1; // @[Decoder.scala 117:28 122:28]
  wire [3:0] _GEN_7 = _T_1 ? 4'h1 : _GEN_6; // @[Decoder.scala 117:28 119:28]
  wire [3:0] _GEN_8 = _T_4 ? 4'hd : 4'h1; // @[Decoder.scala 175:28 180:28]
  wire [3:0] _GEN_9 = _T_1 ? 4'hc : _GEN_8; // @[Decoder.scala 175:28 177:28]
  wire [2:0] _GEN_12 = 7'h6f == opcode ? 3'h4 : 3'h0; // @[Decoder.scala 76:20 195:29]
  wire  _GEN_14 = 7'h63 == opcode ? 1'h0 : 7'h6f == opcode; // @[Decoder.scala 76:20 172:26]
  wire [2:0] _GEN_15 = 7'h63 == opcode ? 3'h3 : _GEN_12; // @[Decoder.scala 76:20 173:29]
  wire [3:0] _GEN_16 = 7'h63 == opcode ? _GEN_9 : 4'h1; // @[Decoder.scala 76:20]
  wire  _GEN_18 = 7'h23 == opcode | _GEN_14; // @[Decoder.scala 76:20 161:26]
  wire [3:0] _GEN_19 = 7'h23 == opcode ? 4'h1 : _GEN_16; // @[Decoder.scala 76:20 162:26]
  wire [2:0] _GEN_20 = 7'h23 == opcode ? 3'h2 : _GEN_15; // @[Decoder.scala 76:20 163:29]
  wire  _GEN_21 = 7'h23 == opcode ? 1'h0 : 7'h63 == opcode; // @[Decoder.scala 76:20]
  wire  _GEN_22 = 7'h23 == opcode ? 1'h0 : _GEN_14; // @[Decoder.scala 76:20]
  wire  _GEN_23 = 7'h67 == opcode | _GEN_22; // @[Decoder.scala 76:20 146:26]
  wire  _GEN_24 = 7'h67 == opcode ? 1'h0 : _GEN_22; // @[Decoder.scala 76:20 147:26]
  wire  _GEN_25 = 7'h67 == opcode | _GEN_18; // @[Decoder.scala 76:20 149:26]
  wire [3:0] _GEN_26 = 7'h67 == opcode ? 4'h1 : _GEN_19; // @[Decoder.scala 76:20 150:26]
  wire [2:0] _GEN_27 = 7'h67 == opcode ? 3'h1 : _GEN_20; // @[Decoder.scala 76:20 151:29]
  wire  _GEN_28 = 7'h67 == opcode ? 1'h0 : 7'h23 == opcode; // @[Decoder.scala 76:20]
  wire  _GEN_29 = 7'h67 == opcode ? 1'h0 : _GEN_21; // @[Decoder.scala 76:20]
  wire  _GEN_30 = 7'h3 == opcode | _GEN_23; // @[Decoder.scala 76:20 133:26]
  wire  _GEN_32 = 7'h3 == opcode | _GEN_25; // @[Decoder.scala 76:20 135:26]
  wire [3:0] _GEN_33 = 7'h3 == opcode ? 4'h1 : _GEN_26; // @[Decoder.scala 76:20 136:26]
  wire [2:0] _GEN_34 = 7'h3 == opcode ? 3'h1 : _GEN_27; // @[Decoder.scala 76:20 137:29]
  wire  _GEN_35 = 7'h3 == opcode ? 1'h0 : _GEN_23; // @[Decoder.scala 76:20]
  wire  _GEN_36 = 7'h3 == opcode ? 1'h0 : _GEN_24; // @[Decoder.scala 76:20]
  wire  _GEN_37 = 7'h3 == opcode ? 1'h0 : _GEN_28; // @[Decoder.scala 76:20]
  wire  _GEN_38 = 7'h3 == opcode ? 1'h0 : _GEN_29; // @[Decoder.scala 76:20]
  wire  _GEN_39 = 7'h13 == opcode | _GEN_30; // @[Decoder.scala 76:20 113:26]
  wire  _GEN_40 = 7'h13 == opcode | _GEN_32; // @[Decoder.scala 76:20 114:26]
  wire [2:0] _GEN_41 = 7'h13 == opcode ? 3'h1 : _GEN_34; // @[Decoder.scala 76:20 115:29]
  wire [3:0] _GEN_42 = 7'h13 == opcode ? _GEN_7 : _GEN_33; // @[Decoder.scala 76:20]
  wire  _GEN_43 = 7'h13 == opcode ? 1'h0 : 7'h3 == opcode; // @[Decoder.scala 76:20]
  wire  _GEN_44 = 7'h13 == opcode ? 1'h0 : _GEN_35; // @[Decoder.scala 76:20]
  wire  _GEN_45 = 7'h13 == opcode ? 1'h0 : _GEN_36; // @[Decoder.scala 76:20]
  wire  _GEN_46 = 7'h13 == opcode ? 1'h0 : _GEN_37; // @[Decoder.scala 76:20]
  wire  _GEN_47 = 7'h13 == opcode ? 1'h0 : _GEN_38; // @[Decoder.scala 76:20]
  ImmGen immGen ( // @[Decoder.scala 202:24]
    .io_inst(immGen_io_inst),
    .io_immSel(immGen_io_immSel),
    .io_imm(immGen_io_imm)
  );
  assign io_bundleCtrl_ctrlJump = 7'h33 == opcode ? 1'h0 : _GEN_44; // @[Decoder.scala 76:20]
  assign io_bundleCtrl_ctrlJAL = 7'h33 == opcode ? 1'h0 : _GEN_45; // @[Decoder.scala 76:20]
  assign io_bundleCtrl_ctrlBranch = 7'h33 == opcode ? 1'h0 : _GEN_47; // @[Decoder.scala 76:20]
  assign io_bundleCtrl_ctrlRegWrite = 7'h33 == opcode | _GEN_39; // @[Decoder.scala 76:20 82:26]
  assign io_bundleCtrl_ctrlLoad = 7'h33 == opcode ? 1'h0 : _GEN_43; // @[Decoder.scala 76:20]
  assign io_bundleCtrl_ctrlStore = 7'h33 == opcode ? 1'h0 : _GEN_46; // @[Decoder.scala 76:20]
  assign io_bundleCtrl_ctrlALUSrc = 7'h33 == opcode ? 1'h0 : _GEN_40; // @[Decoder.scala 76:20 83:26]
  assign io_bundleCtrl_ctrlOP = 7'h33 == opcode ? _GEN_5 : _GEN_42; // @[Decoder.scala 76:20]
  assign io_bundleReg_rs1 = io_inst[19:15]; // @[Decoder.scala 30:32]
  assign io_bundleReg_rs2 = io_inst[24:20]; // @[Decoder.scala 31:32]
  assign io_bundleReg_rd = io_inst[11:7]; // @[Decoder.scala 32:32]
  assign io_imm = immGen_io_imm; // @[Decoder.scala 205:12]
  assign immGen_io_inst = io_inst; // @[Decoder.scala 203:20]
  assign immGen_io_immSel = 7'h33 == opcode ? 3'h0 : _GEN_41; // @[Decoder.scala 76:20]
endmodule
module Registers(
  input         clock,
  input         io_ctrlRegWrite,
  input  [31:0] io_dataWrite,
  input  [4:0]  io_bundleReg_rs1,
  input  [4:0]  io_bundleReg_rs2,
  input  [4:0]  io_bundleReg_rd,
  output [31:0] io_dataRead1,
  output [31:0] io_dataRead2,
  input         io_ctrlJump,
  input  [31:0] io_pc
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
  reg [31:0] _RAND_24;
  reg [31:0] _RAND_25;
  reg [31:0] _RAND_26;
  reg [31:0] _RAND_27;
  reg [31:0] _RAND_28;
  reg [31:0] _RAND_29;
  reg [31:0] _RAND_30;
  reg [31:0] _RAND_31;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] regs_0; // @[Registers.scala 23:19]
  reg [31:0] regs_1; // @[Registers.scala 23:19]
  reg [31:0] regs_2; // @[Registers.scala 23:19]
  reg [31:0] regs_3; // @[Registers.scala 23:19]
  reg [31:0] regs_4; // @[Registers.scala 23:19]
  reg [31:0] regs_5; // @[Registers.scala 23:19]
  reg [31:0] regs_6; // @[Registers.scala 23:19]
  reg [31:0] regs_7; // @[Registers.scala 23:19]
  reg [31:0] regs_8; // @[Registers.scala 23:19]
  reg [31:0] regs_9; // @[Registers.scala 23:19]
  reg [31:0] regs_10; // @[Registers.scala 23:19]
  reg [31:0] regs_11; // @[Registers.scala 23:19]
  reg [31:0] regs_12; // @[Registers.scala 23:19]
  reg [31:0] regs_13; // @[Registers.scala 23:19]
  reg [31:0] regs_14; // @[Registers.scala 23:19]
  reg [31:0] regs_15; // @[Registers.scala 23:19]
  reg [31:0] regs_16; // @[Registers.scala 23:19]
  reg [31:0] regs_17; // @[Registers.scala 23:19]
  reg [31:0] regs_18; // @[Registers.scala 23:19]
  reg [31:0] regs_19; // @[Registers.scala 23:19]
  reg [31:0] regs_20; // @[Registers.scala 23:19]
  reg [31:0] regs_21; // @[Registers.scala 23:19]
  reg [31:0] regs_22; // @[Registers.scala 23:19]
  reg [31:0] regs_23; // @[Registers.scala 23:19]
  reg [31:0] regs_24; // @[Registers.scala 23:19]
  reg [31:0] regs_25; // @[Registers.scala 23:19]
  reg [31:0] regs_26; // @[Registers.scala 23:19]
  reg [31:0] regs_27; // @[Registers.scala 23:19]
  reg [31:0] regs_28; // @[Registers.scala 23:19]
  reg [31:0] regs_29; // @[Registers.scala 23:19]
  reg [31:0] regs_30; // @[Registers.scala 23:19]
  reg [31:0] regs_31; // @[Registers.scala 23:19]
  wire [31:0] _GEN_1 = 5'h1 == io_bundleReg_rs1 ? regs_1 : regs_0; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_2 = 5'h2 == io_bundleReg_rs1 ? regs_2 : _GEN_1; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_3 = 5'h3 == io_bundleReg_rs1 ? regs_3 : _GEN_2; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_4 = 5'h4 == io_bundleReg_rs1 ? regs_4 : _GEN_3; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_5 = 5'h5 == io_bundleReg_rs1 ? regs_5 : _GEN_4; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_6 = 5'h6 == io_bundleReg_rs1 ? regs_6 : _GEN_5; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_7 = 5'h7 == io_bundleReg_rs1 ? regs_7 : _GEN_6; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_8 = 5'h8 == io_bundleReg_rs1 ? regs_8 : _GEN_7; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_9 = 5'h9 == io_bundleReg_rs1 ? regs_9 : _GEN_8; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_10 = 5'ha == io_bundleReg_rs1 ? regs_10 : _GEN_9; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_11 = 5'hb == io_bundleReg_rs1 ? regs_11 : _GEN_10; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_12 = 5'hc == io_bundleReg_rs1 ? regs_12 : _GEN_11; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_13 = 5'hd == io_bundleReg_rs1 ? regs_13 : _GEN_12; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_14 = 5'he == io_bundleReg_rs1 ? regs_14 : _GEN_13; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_15 = 5'hf == io_bundleReg_rs1 ? regs_15 : _GEN_14; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_16 = 5'h10 == io_bundleReg_rs1 ? regs_16 : _GEN_15; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_17 = 5'h11 == io_bundleReg_rs1 ? regs_17 : _GEN_16; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_18 = 5'h12 == io_bundleReg_rs1 ? regs_18 : _GEN_17; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_19 = 5'h13 == io_bundleReg_rs1 ? regs_19 : _GEN_18; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_20 = 5'h14 == io_bundleReg_rs1 ? regs_20 : _GEN_19; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_21 = 5'h15 == io_bundleReg_rs1 ? regs_21 : _GEN_20; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_22 = 5'h16 == io_bundleReg_rs1 ? regs_22 : _GEN_21; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_23 = 5'h17 == io_bundleReg_rs1 ? regs_23 : _GEN_22; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_24 = 5'h18 == io_bundleReg_rs1 ? regs_24 : _GEN_23; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_25 = 5'h19 == io_bundleReg_rs1 ? regs_25 : _GEN_24; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_26 = 5'h1a == io_bundleReg_rs1 ? regs_26 : _GEN_25; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_27 = 5'h1b == io_bundleReg_rs1 ? regs_27 : _GEN_26; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_28 = 5'h1c == io_bundleReg_rs1 ? regs_28 : _GEN_27; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_29 = 5'h1d == io_bundleReg_rs1 ? regs_29 : _GEN_28; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_30 = 5'h1e == io_bundleReg_rs1 ? regs_30 : _GEN_29; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_31 = 5'h1f == io_bundleReg_rs1 ? regs_31 : _GEN_30; // @[Registers.scala 29:{22,22}]
  wire [31:0] _GEN_34 = 5'h1 == io_bundleReg_rs2 ? regs_1 : regs_0; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_35 = 5'h2 == io_bundleReg_rs2 ? regs_2 : _GEN_34; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_36 = 5'h3 == io_bundleReg_rs2 ? regs_3 : _GEN_35; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_37 = 5'h4 == io_bundleReg_rs2 ? regs_4 : _GEN_36; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_38 = 5'h5 == io_bundleReg_rs2 ? regs_5 : _GEN_37; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_39 = 5'h6 == io_bundleReg_rs2 ? regs_6 : _GEN_38; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_40 = 5'h7 == io_bundleReg_rs2 ? regs_7 : _GEN_39; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_41 = 5'h8 == io_bundleReg_rs2 ? regs_8 : _GEN_40; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_42 = 5'h9 == io_bundleReg_rs2 ? regs_9 : _GEN_41; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_43 = 5'ha == io_bundleReg_rs2 ? regs_10 : _GEN_42; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_44 = 5'hb == io_bundleReg_rs2 ? regs_11 : _GEN_43; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_45 = 5'hc == io_bundleReg_rs2 ? regs_12 : _GEN_44; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_46 = 5'hd == io_bundleReg_rs2 ? regs_13 : _GEN_45; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_47 = 5'he == io_bundleReg_rs2 ? regs_14 : _GEN_46; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_48 = 5'hf == io_bundleReg_rs2 ? regs_15 : _GEN_47; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_49 = 5'h10 == io_bundleReg_rs2 ? regs_16 : _GEN_48; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_50 = 5'h11 == io_bundleReg_rs2 ? regs_17 : _GEN_49; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_51 = 5'h12 == io_bundleReg_rs2 ? regs_18 : _GEN_50; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_52 = 5'h13 == io_bundleReg_rs2 ? regs_19 : _GEN_51; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_53 = 5'h14 == io_bundleReg_rs2 ? regs_20 : _GEN_52; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_54 = 5'h15 == io_bundleReg_rs2 ? regs_21 : _GEN_53; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_55 = 5'h16 == io_bundleReg_rs2 ? regs_22 : _GEN_54; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_56 = 5'h17 == io_bundleReg_rs2 ? regs_23 : _GEN_55; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_57 = 5'h18 == io_bundleReg_rs2 ? regs_24 : _GEN_56; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_58 = 5'h19 == io_bundleReg_rs2 ? regs_25 : _GEN_57; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_59 = 5'h1a == io_bundleReg_rs2 ? regs_26 : _GEN_58; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_60 = 5'h1b == io_bundleReg_rs2 ? regs_27 : _GEN_59; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_61 = 5'h1c == io_bundleReg_rs2 ? regs_28 : _GEN_60; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_62 = 5'h1d == io_bundleReg_rs2 ? regs_29 : _GEN_61; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_63 = 5'h1e == io_bundleReg_rs2 ? regs_30 : _GEN_62; // @[Registers.scala 34:{22,22}]
  wire [31:0] _GEN_64 = 5'h1f == io_bundleReg_rs2 ? regs_31 : _GEN_63; // @[Registers.scala 34:{22,22}]
  wire [31:0] _regs_T_1 = io_pc + 32'h4; // @[Registers.scala 43:44]
  assign io_dataRead1 = io_bundleReg_rs1 == 5'h0 ? 32'h0 : _GEN_31; // @[Registers.scala 26:37 27:22 29:22]
  assign io_dataRead2 = io_bundleReg_rs2 == 5'h0 ? 32'h0 : _GEN_64; // @[Registers.scala 31:37 32:22 34:22]
  always @(posedge clock) begin
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h0 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_0 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h0 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_0 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h1 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_1 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h1 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_1 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h2 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_2 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h2 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_2 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h3 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_3 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h3 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_3 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h4 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_4 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h4 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_4 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h5 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_5 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h5 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_5 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h6 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_6 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h6 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_6 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h7 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_7 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h7 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_7 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h8 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_8 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h8 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_8 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h9 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_9 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h9 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_9 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'ha == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_10 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'ha == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_10 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'hb == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_11 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'hb == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_11 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'hc == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_12 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'hc == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_12 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'hd == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_13 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'hd == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_13 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'he == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_14 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'he == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_14 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'hf == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_15 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'hf == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_15 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h10 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_16 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h10 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_16 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h11 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_17 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h11 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_17 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h12 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_18 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h12 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_18 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h13 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_19 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h13 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_19 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h14 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_20 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h14 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_20 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h15 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_21 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h15 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_21 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h16 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_22 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h16 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_22 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h17 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_23 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h17 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_23 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h18 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_24 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h18 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_24 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h19 == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_25 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h19 == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_25 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h1a == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_26 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h1a == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_26 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h1b == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_27 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h1b == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_27 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h1c == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_28 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h1c == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_28 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h1d == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_29 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h1d == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_29 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h1e == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_30 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h1e == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_30 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
    if (io_ctrlRegWrite & io_bundleReg_rd != 5'h0) begin // @[Registers.scala 41:54]
      if (io_ctrlJump) begin // @[Registers.scala 42:27]
        if (5'h1f == io_bundleReg_rd) begin // @[Registers.scala 43:35]
          regs_31 <= _regs_T_1; // @[Registers.scala 43:35]
        end
      end else if (5'h1f == io_bundleReg_rd) begin // @[Registers.scala 45:35]
        regs_31 <= io_dataWrite; // @[Registers.scala 45:35]
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  regs_0 = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  regs_1 = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  regs_2 = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  regs_3 = _RAND_3[31:0];
  _RAND_4 = {1{`RANDOM}};
  regs_4 = _RAND_4[31:0];
  _RAND_5 = {1{`RANDOM}};
  regs_5 = _RAND_5[31:0];
  _RAND_6 = {1{`RANDOM}};
  regs_6 = _RAND_6[31:0];
  _RAND_7 = {1{`RANDOM}};
  regs_7 = _RAND_7[31:0];
  _RAND_8 = {1{`RANDOM}};
  regs_8 = _RAND_8[31:0];
  _RAND_9 = {1{`RANDOM}};
  regs_9 = _RAND_9[31:0];
  _RAND_10 = {1{`RANDOM}};
  regs_10 = _RAND_10[31:0];
  _RAND_11 = {1{`RANDOM}};
  regs_11 = _RAND_11[31:0];
  _RAND_12 = {1{`RANDOM}};
  regs_12 = _RAND_12[31:0];
  _RAND_13 = {1{`RANDOM}};
  regs_13 = _RAND_13[31:0];
  _RAND_14 = {1{`RANDOM}};
  regs_14 = _RAND_14[31:0];
  _RAND_15 = {1{`RANDOM}};
  regs_15 = _RAND_15[31:0];
  _RAND_16 = {1{`RANDOM}};
  regs_16 = _RAND_16[31:0];
  _RAND_17 = {1{`RANDOM}};
  regs_17 = _RAND_17[31:0];
  _RAND_18 = {1{`RANDOM}};
  regs_18 = _RAND_18[31:0];
  _RAND_19 = {1{`RANDOM}};
  regs_19 = _RAND_19[31:0];
  _RAND_20 = {1{`RANDOM}};
  regs_20 = _RAND_20[31:0];
  _RAND_21 = {1{`RANDOM}};
  regs_21 = _RAND_21[31:0];
  _RAND_22 = {1{`RANDOM}};
  regs_22 = _RAND_22[31:0];
  _RAND_23 = {1{`RANDOM}};
  regs_23 = _RAND_23[31:0];
  _RAND_24 = {1{`RANDOM}};
  regs_24 = _RAND_24[31:0];
  _RAND_25 = {1{`RANDOM}};
  regs_25 = _RAND_25[31:0];
  _RAND_26 = {1{`RANDOM}};
  regs_26 = _RAND_26[31:0];
  _RAND_27 = {1{`RANDOM}};
  regs_27 = _RAND_27[31:0];
  _RAND_28 = {1{`RANDOM}};
  regs_28 = _RAND_28[31:0];
  _RAND_29 = {1{`RANDOM}};
  regs_29 = _RAND_29[31:0];
  _RAND_30 = {1{`RANDOM}};
  regs_30 = _RAND_30[31:0];
  _RAND_31 = {1{`RANDOM}};
  regs_31 = _RAND_31[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Alu(
  input         io_bundleAluControl_ctrlALUSrc,
  input         io_bundleAluControl_ctrlJump,
  input         io_bundleAluControl_ctrlJAL,
  input  [3:0]  io_bundleAluControl_ctrlOP,
  input  [31:0] io_dataRead1,
  input  [31:0] io_dataRead2,
  input  [31:0] io_imm,
  input  [31:0] io_pc,
  output        io_resultBranch,
  output [31:0] io_resultAlu
);
  wire [31:0] operand1 = io_bundleAluControl_ctrlJAL ? io_pc : io_dataRead1; // @[ALU.scala 31:20]
  wire [31:0] operand2 = io_bundleAluControl_ctrlALUSrc ? io_imm : io_dataRead2; // @[ALU.scala 32:20]
  wire [31:0] addResult = operand1 + operand2; // @[ALU.scala 33:27]
  wire  _resultAlu_T_1 = io_bundleAluControl_ctrlJump & ~io_bundleAluControl_ctrlJAL; // @[ALU.scala 44:46]
  wire [31:0] _resultAlu_T_3 = addResult & 32'hfffffffe; // @[ALU.scala 45:27]
  wire [31:0] _resultAlu_T_4 = _resultAlu_T_1 ? _resultAlu_T_3 : addResult; // @[ALU.scala 43:29]
  wire [31:0] _resultAlu_T_6 = operand1 - operand2; // @[ALU.scala 51:35]
  wire [31:0] _resultAlu_T_7 = operand1 & operand2; // @[ALU.scala 55:35]
  wire [31:0] _resultAlu_T_8 = operand1 | operand2; // @[ALU.scala 59:35]
  wire [62:0] _GEN_19 = {{31'd0}, operand1}; // @[ALU.scala 63:35]
  wire [62:0] _resultAlu_T_10 = _GEN_19 << operand2[4:0]; // @[ALU.scala 63:35]
  wire [31:0] _resultAlu_T_12 = operand1 >> operand2[4:0]; // @[ALU.scala 67:35]
  wire [31:0] _resultAlu_T_13 = io_bundleAluControl_ctrlJAL ? io_pc : io_dataRead1; // @[ALU.scala 71:36]
  wire [31:0] _resultAlu_T_16 = $signed(_resultAlu_T_13) >>> operand2[4:0]; // @[ALU.scala 71:62]
  wire [31:0] _resultAlu_T_18 = io_pc + io_imm; // @[ALU.scala 76:32]
  wire  _GEN_0 = 4'hd == io_bundleAluControl_ctrlOP & operand1 != operand2; // @[ALU.scala 35:40 80:26]
  wire [31:0] _GEN_1 = 4'hd == io_bundleAluControl_ctrlOP ? _resultAlu_T_18 : 32'h0; // @[ALU.scala 35:40 81:23]
  wire  _GEN_2 = 4'hc == io_bundleAluControl_ctrlOP ? operand1 == operand2 : _GEN_0; // @[ALU.scala 35:40 75:26]
  wire [31:0] _GEN_3 = 4'hc == io_bundleAluControl_ctrlOP ? _resultAlu_T_18 : _GEN_1; // @[ALU.scala 35:40 76:23]
  wire [31:0] _GEN_4 = 4'hb == io_bundleAluControl_ctrlOP ? _resultAlu_T_16 : _GEN_3; // @[ALU.scala 35:40 71:23]
  wire  _GEN_5 = 4'hb == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_2; // @[ALU.scala 35:40]
  wire [31:0] _GEN_6 = 4'h9 == io_bundleAluControl_ctrlOP ? _resultAlu_T_12 : _GEN_4; // @[ALU.scala 35:40 67:23]
  wire  _GEN_7 = 4'h9 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_5; // @[ALU.scala 35:40]
  wire [62:0] _GEN_8 = 4'h8 == io_bundleAluControl_ctrlOP ? _resultAlu_T_10 : {{31'd0}, _GEN_6}; // @[ALU.scala 35:40 63:23]
  wire  _GEN_9 = 4'h8 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_7; // @[ALU.scala 35:40]
  wire [62:0] _GEN_10 = 4'h5 == io_bundleAluControl_ctrlOP ? {{31'd0}, _resultAlu_T_8} : _GEN_8; // @[ALU.scala 35:40 59:23]
  wire  _GEN_11 = 4'h5 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_9; // @[ALU.scala 35:40]
  wire [62:0] _GEN_12 = 4'h4 == io_bundleAluControl_ctrlOP ? {{31'd0}, _resultAlu_T_7} : _GEN_10; // @[ALU.scala 35:40 55:23]
  wire  _GEN_13 = 4'h4 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_11; // @[ALU.scala 35:40]
  wire [62:0] _GEN_14 = 4'h2 == io_bundleAluControl_ctrlOP ? {{31'd0}, _resultAlu_T_6} : _GEN_12; // @[ALU.scala 35:40 51:23]
  wire  _GEN_15 = 4'h2 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_13; // @[ALU.scala 35:40]
  wire [62:0] _GEN_16 = 4'h1 == io_bundleAluControl_ctrlOP ? {{31'd0}, _resultAlu_T_4} : _GEN_14; // @[ALU.scala 35:40 43:23]
  wire  _GEN_17 = 4'h1 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_15; // @[ALU.scala 35:40]
  wire [62:0] _GEN_18 = 4'h0 == io_bundleAluControl_ctrlOP ? 63'h0 : _GEN_16; // @[ALU.scala 35:40 37:23]
  assign io_resultBranch = 4'h0 == io_bundleAluControl_ctrlOP ? 1'h0 : _GEN_17; // @[ALU.scala 35:40 38:26]
  assign io_resultAlu = _GEN_18[31:0]; // @[ALU.scala 85:18]
endmodule
module MemData(
  input         clock,
  input         io_bundleMemDataControl_ctrlLoad,
  input         io_bundleMemDataControl_ctrlStore,
  input  [31:0] io_resultALU,
  input  [31:0] io_dataStore,
  output [31:0] io_result,
  input         io_extWriteEn,
  input  [31:0] io_extWriteAddr,
  input  [31:0] io_extWriteData
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
  reg [31:0] mem [0:1023]; // @[Mem.scala 32:18]
  wire  mem_dataLoad_MPORT_en; // @[Mem.scala 32:18]
  wire [9:0] mem_dataLoad_MPORT_addr; // @[Mem.scala 32:18]
  wire [31:0] mem_dataLoad_MPORT_data; // @[Mem.scala 32:18]
  wire [31:0] mem_MPORT_data; // @[Mem.scala 32:18]
  wire [9:0] mem_MPORT_addr; // @[Mem.scala 32:18]
  wire  mem_MPORT_mask; // @[Mem.scala 32:18]
  wire  mem_MPORT_en; // @[Mem.scala 32:18]
  wire [31:0] mem_MPORT_1_data; // @[Mem.scala 32:18]
  wire [9:0] mem_MPORT_1_addr; // @[Mem.scala 32:18]
  wire  mem_MPORT_1_mask; // @[Mem.scala 32:18]
  wire  mem_MPORT_1_en; // @[Mem.scala 32:18]
  wire [31:0] cpuWordAddr = {{2'd0}, io_resultALU[31:2]}; // @[Mem.scala 41:36]
  wire [31:0] extWordAddr = {{2'd0}, io_extWriteAddr[31:2]}; // @[Mem.scala 42:39]
  wire [31:0] dataLoad = mem_dataLoad_MPORT_data;
  assign mem_dataLoad_MPORT_en = 1'h1;
  assign mem_dataLoad_MPORT_addr = cpuWordAddr[9:0];
  assign mem_dataLoad_MPORT_data = mem[mem_dataLoad_MPORT_addr]; // @[Mem.scala 32:18]
  assign mem_MPORT_data = io_extWriteData;
  assign mem_MPORT_addr = extWordAddr[9:0];
  assign mem_MPORT_mask = 1'h1;
  assign mem_MPORT_en = io_extWriteEn;
  assign mem_MPORT_1_data = io_dataStore;
  assign mem_MPORT_1_addr = cpuWordAddr[9:0];
  assign mem_MPORT_1_mask = 1'h1;
  assign mem_MPORT_1_en = io_extWriteEn ? 1'h0 : io_bundleMemDataControl_ctrlStore;
  assign io_result = io_bundleMemDataControl_ctrlLoad ? dataLoad : io_resultALU; // @[Mem.scala 65:45 66:16 69:16]
  always @(posedge clock) begin
    if (mem_MPORT_en & mem_MPORT_mask) begin
      mem[mem_MPORT_addr] <= mem_MPORT_data; // @[Mem.scala 32:18]
    end
    if (mem_MPORT_1_en & mem_MPORT_1_mask) begin
      mem[mem_MPORT_1_addr] <= mem_MPORT_1_data; // @[Mem.scala 32:18]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1024; initvar = initvar+1)
    mem[initvar] = _RAND_0[31:0];
`endif // RANDOMIZE_MEM_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Controller(
  input        io_bundleControlIn_ctrlJump,
  input        io_bundleControlIn_ctrlJAL,
  input        io_bundleControlIn_ctrlBranch,
  input        io_bundleControlIn_ctrlRegWrite,
  input        io_bundleControlIn_ctrlLoad,
  input        io_bundleControlIn_ctrlStore,
  input        io_bundleControlIn_ctrlALUSrc,
  input  [3:0] io_bundleControlIn_ctrlOP,
  output       io_bundleAluControl_ctrlALUSrc,
  output       io_bundleAluControl_ctrlJump,
  output       io_bundleAluControl_ctrlJAL,
  output [3:0] io_bundleAluControl_ctrlOP,
  output       io_bundleMemDataControl_ctrlLoad,
  output       io_bundleMemDataControl_ctrlStore,
  output       io_bundleControlOut_ctrlJump,
  output       io_bundleControlOut_ctrlBranch,
  output       io_bundleControlOut_ctrlRegWrite
);
  assign io_bundleAluControl_ctrlALUSrc = io_bundleControlIn_ctrlALUSrc; // @[Controller.scala 19:36]
  assign io_bundleAluControl_ctrlJump = io_bundleControlIn_ctrlJump; // @[Controller.scala 20:34]
  assign io_bundleAluControl_ctrlJAL = io_bundleControlIn_ctrlJAL; // @[Controller.scala 21:33]
  assign io_bundleAluControl_ctrlOP = io_bundleControlIn_ctrlOP; // @[Controller.scala 22:32]
  assign io_bundleMemDataControl_ctrlLoad = io_bundleControlIn_ctrlLoad; // @[Controller.scala 26:38]
  assign io_bundleMemDataControl_ctrlStore = io_bundleControlIn_ctrlStore; // @[Controller.scala 27:39]
  assign io_bundleControlOut_ctrlJump = io_bundleControlIn_ctrlJump; // @[Controller.scala 30:25]
  assign io_bundleControlOut_ctrlBranch = io_bundleControlIn_ctrlBranch; // @[Controller.scala 30:25]
  assign io_bundleControlOut_ctrlRegWrite = io_bundleControlIn_ctrlRegWrite; // @[Controller.scala 30:25]
endmodule
module Top(
  input         clock,
  input         reset,
  output [31:0] io_addr,
  output [31:0] io_inst,
  output        io_bundleCtrl_ctrlJump,
  output        io_bundleCtrl_ctrlJAL,
  output        io_bundleCtrl_ctrlBranch,
  output        io_bundleCtrl_ctrlRegWrite,
  output        io_bundleCtrl_ctrlLoad,
  output        io_bundleCtrl_ctrlStore,
  output        io_bundleCtrl_ctrlALUSrc,
  output [3:0]  io_bundleCtrl_ctrlOP,
  output        io_ctrlBranchToPc,
  output        io_ctrlJumpToPc,
  output [31:0] io_resultALU,
  output [31:0] io_rs1,
  output [31:0] io_rs2,
  output [31:0] io_imm,
  output        io_resultBranch,
  output [31:0] io_result,
  input         io_instWriteEn,
  input  [31:0] io_instWriteAddr,
  input  [31:0] io_instWriteData,
  input         io_dataWriteEn,
  input  [31:0] io_dataWriteAddr,
  input  [31:0] io_dataWriteData
);
  wire  pcReg_clock; // @[Top.scala 43:23]
  wire  pcReg_reset; // @[Top.scala 43:23]
  wire [31:0] pcReg_io_addrOut; // @[Top.scala 43:23]
  wire  pcReg_io_ctrlJump; // @[Top.scala 43:23]
  wire  pcReg_io_ctrlBranch; // @[Top.scala 43:23]
  wire  pcReg_io_resultBranch; // @[Top.scala 43:23]
  wire [31:0] pcReg_io_addrTarget; // @[Top.scala 43:23]
  wire  memInst_clock; // @[Top.scala 44:25]
  wire [31:0] memInst_io_addr; // @[Top.scala 44:25]
  wire [31:0] memInst_io_inst; // @[Top.scala 44:25]
  wire  memInst_io_extWriteEn; // @[Top.scala 44:25]
  wire [31:0] memInst_io_extWriteAddr; // @[Top.scala 44:25]
  wire [31:0] memInst_io_extWriteData; // @[Top.scala 44:25]
  wire [31:0] decoder_io_inst; // @[Top.scala 45:25]
  wire  decoder_io_bundleCtrl_ctrlJump; // @[Top.scala 45:25]
  wire  decoder_io_bundleCtrl_ctrlJAL; // @[Top.scala 45:25]
  wire  decoder_io_bundleCtrl_ctrlBranch; // @[Top.scala 45:25]
  wire  decoder_io_bundleCtrl_ctrlRegWrite; // @[Top.scala 45:25]
  wire  decoder_io_bundleCtrl_ctrlLoad; // @[Top.scala 45:25]
  wire  decoder_io_bundleCtrl_ctrlStore; // @[Top.scala 45:25]
  wire  decoder_io_bundleCtrl_ctrlALUSrc; // @[Top.scala 45:25]
  wire [3:0] decoder_io_bundleCtrl_ctrlOP; // @[Top.scala 45:25]
  wire [4:0] decoder_io_bundleReg_rs1; // @[Top.scala 45:25]
  wire [4:0] decoder_io_bundleReg_rs2; // @[Top.scala 45:25]
  wire [4:0] decoder_io_bundleReg_rd; // @[Top.scala 45:25]
  wire [31:0] decoder_io_imm; // @[Top.scala 45:25]
  wire  registers_clock; // @[Top.scala 46:27]
  wire  registers_io_ctrlRegWrite; // @[Top.scala 46:27]
  wire [31:0] registers_io_dataWrite; // @[Top.scala 46:27]
  wire [4:0] registers_io_bundleReg_rs1; // @[Top.scala 46:27]
  wire [4:0] registers_io_bundleReg_rs2; // @[Top.scala 46:27]
  wire [4:0] registers_io_bundleReg_rd; // @[Top.scala 46:27]
  wire [31:0] registers_io_dataRead1; // @[Top.scala 46:27]
  wire [31:0] registers_io_dataRead2; // @[Top.scala 46:27]
  wire  registers_io_ctrlJump; // @[Top.scala 46:27]
  wire [31:0] registers_io_pc; // @[Top.scala 46:27]
  wire  alu_io_bundleAluControl_ctrlALUSrc; // @[Top.scala 47:21]
  wire  alu_io_bundleAluControl_ctrlJump; // @[Top.scala 47:21]
  wire  alu_io_bundleAluControl_ctrlJAL; // @[Top.scala 47:21]
  wire [3:0] alu_io_bundleAluControl_ctrlOP; // @[Top.scala 47:21]
  wire [31:0] alu_io_dataRead1; // @[Top.scala 47:21]
  wire [31:0] alu_io_dataRead2; // @[Top.scala 47:21]
  wire [31:0] alu_io_imm; // @[Top.scala 47:21]
  wire [31:0] alu_io_pc; // @[Top.scala 47:21]
  wire  alu_io_resultBranch; // @[Top.scala 47:21]
  wire [31:0] alu_io_resultAlu; // @[Top.scala 47:21]
  wire  memData_clock; // @[Top.scala 48:25]
  wire  memData_io_bundleMemDataControl_ctrlLoad; // @[Top.scala 48:25]
  wire  memData_io_bundleMemDataControl_ctrlStore; // @[Top.scala 48:25]
  wire [31:0] memData_io_resultALU; // @[Top.scala 48:25]
  wire [31:0] memData_io_dataStore; // @[Top.scala 48:25]
  wire [31:0] memData_io_result; // @[Top.scala 48:25]
  wire  memData_io_extWriteEn; // @[Top.scala 48:25]
  wire [31:0] memData_io_extWriteAddr; // @[Top.scala 48:25]
  wire [31:0] memData_io_extWriteData; // @[Top.scala 48:25]
  wire  controller_io_bundleControlIn_ctrlJump; // @[Top.scala 49:28]
  wire  controller_io_bundleControlIn_ctrlJAL; // @[Top.scala 49:28]
  wire  controller_io_bundleControlIn_ctrlBranch; // @[Top.scala 49:28]
  wire  controller_io_bundleControlIn_ctrlRegWrite; // @[Top.scala 49:28]
  wire  controller_io_bundleControlIn_ctrlLoad; // @[Top.scala 49:28]
  wire  controller_io_bundleControlIn_ctrlStore; // @[Top.scala 49:28]
  wire  controller_io_bundleControlIn_ctrlALUSrc; // @[Top.scala 49:28]
  wire [3:0] controller_io_bundleControlIn_ctrlOP; // @[Top.scala 49:28]
  wire  controller_io_bundleAluControl_ctrlALUSrc; // @[Top.scala 49:28]
  wire  controller_io_bundleAluControl_ctrlJump; // @[Top.scala 49:28]
  wire  controller_io_bundleAluControl_ctrlJAL; // @[Top.scala 49:28]
  wire [3:0] controller_io_bundleAluControl_ctrlOP; // @[Top.scala 49:28]
  wire  controller_io_bundleMemDataControl_ctrlLoad; // @[Top.scala 49:28]
  wire  controller_io_bundleMemDataControl_ctrlStore; // @[Top.scala 49:28]
  wire  controller_io_bundleControlOut_ctrlJump; // @[Top.scala 49:28]
  wire  controller_io_bundleControlOut_ctrlBranch; // @[Top.scala 49:28]
  wire  controller_io_bundleControlOut_ctrlRegWrite; // @[Top.scala 49:28]
  PCReg pcReg ( // @[Top.scala 43:23]
    .clock(pcReg_clock),
    .reset(pcReg_reset),
    .io_addrOut(pcReg_io_addrOut),
    .io_ctrlJump(pcReg_io_ctrlJump),
    .io_ctrlBranch(pcReg_io_ctrlBranch),
    .io_resultBranch(pcReg_io_resultBranch),
    .io_addrTarget(pcReg_io_addrTarget)
  );
  MemInst memInst ( // @[Top.scala 44:25]
    .clock(memInst_clock),
    .io_addr(memInst_io_addr),
    .io_inst(memInst_io_inst),
    .io_extWriteEn(memInst_io_extWriteEn),
    .io_extWriteAddr(memInst_io_extWriteAddr),
    .io_extWriteData(memInst_io_extWriteData)
  );
  Decoder decoder ( // @[Top.scala 45:25]
    .io_inst(decoder_io_inst),
    .io_bundleCtrl_ctrlJump(decoder_io_bundleCtrl_ctrlJump),
    .io_bundleCtrl_ctrlJAL(decoder_io_bundleCtrl_ctrlJAL),
    .io_bundleCtrl_ctrlBranch(decoder_io_bundleCtrl_ctrlBranch),
    .io_bundleCtrl_ctrlRegWrite(decoder_io_bundleCtrl_ctrlRegWrite),
    .io_bundleCtrl_ctrlLoad(decoder_io_bundleCtrl_ctrlLoad),
    .io_bundleCtrl_ctrlStore(decoder_io_bundleCtrl_ctrlStore),
    .io_bundleCtrl_ctrlALUSrc(decoder_io_bundleCtrl_ctrlALUSrc),
    .io_bundleCtrl_ctrlOP(decoder_io_bundleCtrl_ctrlOP),
    .io_bundleReg_rs1(decoder_io_bundleReg_rs1),
    .io_bundleReg_rs2(decoder_io_bundleReg_rs2),
    .io_bundleReg_rd(decoder_io_bundleReg_rd),
    .io_imm(decoder_io_imm)
  );
  Registers registers ( // @[Top.scala 46:27]
    .clock(registers_clock),
    .io_ctrlRegWrite(registers_io_ctrlRegWrite),
    .io_dataWrite(registers_io_dataWrite),
    .io_bundleReg_rs1(registers_io_bundleReg_rs1),
    .io_bundleReg_rs2(registers_io_bundleReg_rs2),
    .io_bundleReg_rd(registers_io_bundleReg_rd),
    .io_dataRead1(registers_io_dataRead1),
    .io_dataRead2(registers_io_dataRead2),
    .io_ctrlJump(registers_io_ctrlJump),
    .io_pc(registers_io_pc)
  );
  Alu alu ( // @[Top.scala 47:21]
    .io_bundleAluControl_ctrlALUSrc(alu_io_bundleAluControl_ctrlALUSrc),
    .io_bundleAluControl_ctrlJump(alu_io_bundleAluControl_ctrlJump),
    .io_bundleAluControl_ctrlJAL(alu_io_bundleAluControl_ctrlJAL),
    .io_bundleAluControl_ctrlOP(alu_io_bundleAluControl_ctrlOP),
    .io_dataRead1(alu_io_dataRead1),
    .io_dataRead2(alu_io_dataRead2),
    .io_imm(alu_io_imm),
    .io_pc(alu_io_pc),
    .io_resultBranch(alu_io_resultBranch),
    .io_resultAlu(alu_io_resultAlu)
  );
  MemData memData ( // @[Top.scala 48:25]
    .clock(memData_clock),
    .io_bundleMemDataControl_ctrlLoad(memData_io_bundleMemDataControl_ctrlLoad),
    .io_bundleMemDataControl_ctrlStore(memData_io_bundleMemDataControl_ctrlStore),
    .io_resultALU(memData_io_resultALU),
    .io_dataStore(memData_io_dataStore),
    .io_result(memData_io_result),
    .io_extWriteEn(memData_io_extWriteEn),
    .io_extWriteAddr(memData_io_extWriteAddr),
    .io_extWriteData(memData_io_extWriteData)
  );
  Controller controller ( // @[Top.scala 49:28]
    .io_bundleControlIn_ctrlJump(controller_io_bundleControlIn_ctrlJump),
    .io_bundleControlIn_ctrlJAL(controller_io_bundleControlIn_ctrlJAL),
    .io_bundleControlIn_ctrlBranch(controller_io_bundleControlIn_ctrlBranch),
    .io_bundleControlIn_ctrlRegWrite(controller_io_bundleControlIn_ctrlRegWrite),
    .io_bundleControlIn_ctrlLoad(controller_io_bundleControlIn_ctrlLoad),
    .io_bundleControlIn_ctrlStore(controller_io_bundleControlIn_ctrlStore),
    .io_bundleControlIn_ctrlALUSrc(controller_io_bundleControlIn_ctrlALUSrc),
    .io_bundleControlIn_ctrlOP(controller_io_bundleControlIn_ctrlOP),
    .io_bundleAluControl_ctrlALUSrc(controller_io_bundleAluControl_ctrlALUSrc),
    .io_bundleAluControl_ctrlJump(controller_io_bundleAluControl_ctrlJump),
    .io_bundleAluControl_ctrlJAL(controller_io_bundleAluControl_ctrlJAL),
    .io_bundleAluControl_ctrlOP(controller_io_bundleAluControl_ctrlOP),
    .io_bundleMemDataControl_ctrlLoad(controller_io_bundleMemDataControl_ctrlLoad),
    .io_bundleMemDataControl_ctrlStore(controller_io_bundleMemDataControl_ctrlStore),
    .io_bundleControlOut_ctrlJump(controller_io_bundleControlOut_ctrlJump),
    .io_bundleControlOut_ctrlBranch(controller_io_bundleControlOut_ctrlBranch),
    .io_bundleControlOut_ctrlRegWrite(controller_io_bundleControlOut_ctrlRegWrite)
  );
  assign io_addr = pcReg_io_addrOut; // @[Top.scala 92:13]
  assign io_inst = memInst_io_inst; // @[Top.scala 96:13]
  assign io_bundleCtrl_ctrlJump = decoder_io_bundleCtrl_ctrlJump; // @[Top.scala 93:19]
  assign io_bundleCtrl_ctrlJAL = decoder_io_bundleCtrl_ctrlJAL; // @[Top.scala 93:19]
  assign io_bundleCtrl_ctrlBranch = decoder_io_bundleCtrl_ctrlBranch; // @[Top.scala 93:19]
  assign io_bundleCtrl_ctrlRegWrite = decoder_io_bundleCtrl_ctrlRegWrite; // @[Top.scala 93:19]
  assign io_bundleCtrl_ctrlLoad = decoder_io_bundleCtrl_ctrlLoad; // @[Top.scala 93:19]
  assign io_bundleCtrl_ctrlStore = decoder_io_bundleCtrl_ctrlStore; // @[Top.scala 93:19]
  assign io_bundleCtrl_ctrlALUSrc = decoder_io_bundleCtrl_ctrlALUSrc; // @[Top.scala 93:19]
  assign io_bundleCtrl_ctrlOP = decoder_io_bundleCtrl_ctrlOP; // @[Top.scala 93:19]
  assign io_ctrlBranchToPc = controller_io_bundleControlOut_ctrlBranch; // @[Top.scala 94:23]
  assign io_ctrlJumpToPc = controller_io_bundleControlOut_ctrlJump; // @[Top.scala 95:21]
  assign io_resultALU = alu_io_resultAlu; // @[Top.scala 98:18]
  assign io_rs1 = registers_io_dataRead1; // @[Top.scala 101:12]
  assign io_rs2 = registers_io_dataRead2; // @[Top.scala 102:12]
  assign io_imm = decoder_io_imm; // @[Top.scala 100:12]
  assign io_resultBranch = alu_io_resultBranch; // @[Top.scala 99:21]
  assign io_result = memData_io_result; // @[Top.scala 97:15]
  assign pcReg_clock = clock;
  assign pcReg_reset = reset;
  assign pcReg_io_ctrlJump = controller_io_bundleControlOut_ctrlJump; // @[Top.scala 55:23]
  assign pcReg_io_ctrlBranch = controller_io_bundleControlOut_ctrlBranch; // @[Top.scala 54:25]
  assign pcReg_io_resultBranch = alu_io_resultBranch; // @[Top.scala 52:27]
  assign pcReg_io_addrTarget = memData_io_result; // @[Top.scala 53:25]
  assign memInst_clock = clock;
  assign memInst_io_addr = pcReg_io_addrOut; // @[Top.scala 58:21]
  assign memInst_io_extWriteEn = io_instWriteEn; // @[Top.scala 59:27]
  assign memInst_io_extWriteAddr = io_instWriteAddr; // @[Top.scala 60:29]
  assign memInst_io_extWriteData = io_instWriteData; // @[Top.scala 61:29]
  assign decoder_io_inst = memInst_io_inst; // @[Top.scala 64:21]
  assign registers_clock = clock;
  assign registers_io_ctrlRegWrite = controller_io_bundleControlOut_ctrlRegWrite; // @[Top.scala 68:31]
  assign registers_io_dataWrite = memData_io_result; // @[Top.scala 70:28]
  assign registers_io_bundleReg_rs1 = decoder_io_bundleReg_rs1; // @[Top.scala 67:28]
  assign registers_io_bundleReg_rs2 = decoder_io_bundleReg_rs2; // @[Top.scala 67:28]
  assign registers_io_bundleReg_rd = decoder_io_bundleReg_rd; // @[Top.scala 67:28]
  assign registers_io_ctrlJump = controller_io_bundleControlOut_ctrlJump; // @[Top.scala 69:27]
  assign registers_io_pc = pcReg_io_addrOut; // @[Top.scala 71:21]
  assign alu_io_bundleAluControl_ctrlALUSrc = controller_io_bundleAluControl_ctrlALUSrc; // @[Top.scala 74:29]
  assign alu_io_bundleAluControl_ctrlJump = controller_io_bundleAluControl_ctrlJump; // @[Top.scala 74:29]
  assign alu_io_bundleAluControl_ctrlJAL = controller_io_bundleAluControl_ctrlJAL; // @[Top.scala 74:29]
  assign alu_io_bundleAluControl_ctrlOP = controller_io_bundleAluControl_ctrlOP; // @[Top.scala 74:29]
  assign alu_io_dataRead1 = registers_io_dataRead1; // @[Top.scala 75:22]
  assign alu_io_dataRead2 = registers_io_dataRead2; // @[Top.scala 76:22]
  assign alu_io_imm = decoder_io_imm; // @[Top.scala 77:16]
  assign alu_io_pc = pcReg_io_addrOut; // @[Top.scala 78:15]
  assign memData_clock = clock;
  assign memData_io_bundleMemDataControl_ctrlLoad = controller_io_bundleMemDataControl_ctrlLoad; // @[Top.scala 81:37]
  assign memData_io_bundleMemDataControl_ctrlStore = controller_io_bundleMemDataControl_ctrlStore; // @[Top.scala 81:37]
  assign memData_io_resultALU = alu_io_resultAlu; // @[Top.scala 83:26]
  assign memData_io_dataStore = registers_io_dataRead2; // @[Top.scala 82:26]
  assign memData_io_extWriteEn = io_dataWriteEn; // @[Top.scala 84:27]
  assign memData_io_extWriteAddr = io_dataWriteAddr; // @[Top.scala 85:29]
  assign memData_io_extWriteData = io_dataWriteData; // @[Top.scala 86:29]
  assign controller_io_bundleControlIn_ctrlJump = decoder_io_bundleCtrl_ctrlJump; // @[Top.scala 89:35]
  assign controller_io_bundleControlIn_ctrlJAL = decoder_io_bundleCtrl_ctrlJAL; // @[Top.scala 89:35]
  assign controller_io_bundleControlIn_ctrlBranch = decoder_io_bundleCtrl_ctrlBranch; // @[Top.scala 89:35]
  assign controller_io_bundleControlIn_ctrlRegWrite = decoder_io_bundleCtrl_ctrlRegWrite; // @[Top.scala 89:35]
  assign controller_io_bundleControlIn_ctrlLoad = decoder_io_bundleCtrl_ctrlLoad; // @[Top.scala 89:35]
  assign controller_io_bundleControlIn_ctrlStore = decoder_io_bundleCtrl_ctrlStore; // @[Top.scala 89:35]
  assign controller_io_bundleControlIn_ctrlALUSrc = decoder_io_bundleCtrl_ctrlALUSrc; // @[Top.scala 89:35]
  assign controller_io_bundleControlIn_ctrlOP = decoder_io_bundleCtrl_ctrlOP; // @[Top.scala 89:35]
endmodule
