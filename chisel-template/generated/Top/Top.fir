circuit Top :
  module PCReg :
    input clock : Clock
    input reset : Reset
    output io : { addrOut : UInt<32>, flip ctrlJump : UInt<1>, flip ctrlBranch : UInt<1>, flip resultBranch : UInt<1>, flip addrTarget : UInt<32>}

    reg regPC : UInt<32>, clock with :
      reset => (reset, UInt<1>("h0")) @[PCReg.scala 21:24]
    node _T = and(io.ctrlBranch, io.resultBranch) @[PCReg.scala 23:41]
    node _T_1 = or(io.ctrlJump, _T) @[PCReg.scala 23:23]
    when _T_1 : @[PCReg.scala 23:62]
      regPC <= io.addrTarget @[PCReg.scala 24:15]
    else :
      node _regPC_T = add(regPC, UInt<3>("h4")) @[PCReg.scala 26:24]
      node _regPC_T_1 = tail(_regPC_T, 1) @[PCReg.scala 26:24]
      regPC <= _regPC_T_1 @[PCReg.scala 26:15]
    io.addrOut <= regPC @[PCReg.scala 29:16]

  module MemInst :
    input clock : Clock
    input reset : Reset
    output io : { flip addr : UInt<32>, inst : UInt<32>, flip extWriteEn : UInt<1>, flip extWriteAddr : UInt<32>, flip extWriteData : UInt<32>}

    cmem mem : UInt<32> [1024] @[MemInst.scala 29:18]
    node cpuWordAddr = dshr(io.addr, UInt<2>("h2")) @[MemInst.scala 38:31]
    node extWordAddr = dshr(io.extWriteAddr, UInt<2>("h2")) @[MemInst.scala 39:39]
    when io.extWriteEn : @[MemInst.scala 42:26]
      node _T = bits(extWordAddr, 9, 0)
      write mport MPORT = mem[_T], clock
      MPORT <= io.extWriteData
    node _io_inst_T = bits(cpuWordAddr, 9, 0) @[MemInst.scala 46:24]
    read mport io_inst_MPORT = mem[_io_inst_T], clock @[MemInst.scala 46:24]
    io.inst <= io_inst_MPORT @[MemInst.scala 46:13]

  module ImmGen :
    input clock : Clock
    input reset : Reset
    output io : { flip inst : UInt<32>, flip immSel : UInt<3>, imm : UInt<32>}

    node _imm_i_T = bits(io.inst, 31, 31) @[ImmGen.scala 25:25]
    node _imm_i_T_1 = bits(_imm_i_T, 0, 0) @[Bitwise.scala 72:15]
    node _imm_i_T_2 = mux(_imm_i_T_1, UInt<20>("hfffff"), UInt<20>("h0")) @[Bitwise.scala 72:12]
    node _imm_i_T_3 = bits(io.inst, 31, 20) @[ImmGen.scala 26:16]
    node imm_i = cat(_imm_i_T_2, _imm_i_T_3) @[Cat.scala 30:58]
    node _imm_s_T = bits(io.inst, 31, 31) @[ImmGen.scala 31:25]
    node _imm_s_T_1 = bits(_imm_s_T, 0, 0) @[Bitwise.scala 72:15]
    node _imm_s_T_2 = mux(_imm_s_T_1, UInt<20>("hfffff"), UInt<20>("h0")) @[Bitwise.scala 72:12]
    node _imm_s_T_3 = bits(io.inst, 31, 25) @[ImmGen.scala 32:16]
    node _imm_s_T_4 = bits(io.inst, 11, 7) @[ImmGen.scala 33:16]
    node imm_s_hi = cat(_imm_s_T_2, _imm_s_T_3) @[Cat.scala 30:58]
    node imm_s = cat(imm_s_hi, _imm_s_T_4) @[Cat.scala 30:58]
    node _imm_b_T = bits(io.inst, 31, 31) @[ImmGen.scala 39:25]
    node _imm_b_T_1 = bits(_imm_b_T, 0, 0) @[Bitwise.scala 72:15]
    node _imm_b_T_2 = mux(_imm_b_T_1, UInt<19>("h7ffff"), UInt<19>("h0")) @[Bitwise.scala 72:12]
    node _imm_b_T_3 = bits(io.inst, 31, 31) @[ImmGen.scala 40:16]
    node _imm_b_T_4 = bits(io.inst, 7, 7) @[ImmGen.scala 41:16]
    node _imm_b_T_5 = bits(io.inst, 30, 25) @[ImmGen.scala 42:16]
    node _imm_b_T_6 = bits(io.inst, 11, 8) @[ImmGen.scala 43:16]
    node imm_b_lo_hi = cat(_imm_b_T_5, _imm_b_T_6) @[Cat.scala 30:58]
    node imm_b_lo = cat(imm_b_lo_hi, UInt<1>("h0")) @[Cat.scala 30:58]
    node imm_b_hi_hi = cat(_imm_b_T_2, _imm_b_T_3) @[Cat.scala 30:58]
    node imm_b_hi = cat(imm_b_hi_hi, _imm_b_T_4) @[Cat.scala 30:58]
    node imm_b = cat(imm_b_hi, imm_b_lo) @[Cat.scala 30:58]
    node _imm_j_T = bits(io.inst, 31, 31) @[ImmGen.scala 50:25]
    node _imm_j_T_1 = bits(_imm_j_T, 0, 0) @[Bitwise.scala 72:15]
    node _imm_j_T_2 = mux(_imm_j_T_1, UInt<11>("h7ff"), UInt<11>("h0")) @[Bitwise.scala 72:12]
    node _imm_j_T_3 = bits(io.inst, 31, 31) @[ImmGen.scala 51:16]
    node _imm_j_T_4 = bits(io.inst, 19, 12) @[ImmGen.scala 52:16]
    node _imm_j_T_5 = bits(io.inst, 20, 20) @[ImmGen.scala 53:16]
    node _imm_j_T_6 = bits(io.inst, 30, 21) @[ImmGen.scala 54:16]
    node imm_j_lo_hi = cat(_imm_j_T_5, _imm_j_T_6) @[Cat.scala 30:58]
    node imm_j_lo = cat(imm_j_lo_hi, UInt<1>("h0")) @[Cat.scala 30:58]
    node imm_j_hi_hi = cat(_imm_j_T_2, _imm_j_T_3) @[Cat.scala 30:58]
    node imm_j_hi = cat(imm_j_hi_hi, _imm_j_T_4) @[Cat.scala 30:58]
    node imm_j = cat(imm_j_hi, imm_j_lo) @[Cat.scala 30:58]
    wire imm : UInt<32>
    imm <= UInt<32>("h0")
    node _T = eq(UInt<3>("h1"), io.immSel) @[ImmGen.scala 63:23]
    when _T : @[ImmGen.scala 63:23]
      imm <= imm_i @[ImmGen.scala 65:17]
    else :
      node _T_1 = eq(UInt<3>("h2"), io.immSel) @[ImmGen.scala 63:23]
      when _T_1 : @[ImmGen.scala 63:23]
        imm <= imm_s @[ImmGen.scala 68:17]
      else :
        node _T_2 = eq(UInt<3>("h3"), io.immSel) @[ImmGen.scala 63:23]
        when _T_2 : @[ImmGen.scala 63:23]
          imm <= imm_b @[ImmGen.scala 71:17]
        else :
          node _T_3 = eq(UInt<3>("h4"), io.immSel) @[ImmGen.scala 63:23]
          when _T_3 : @[ImmGen.scala 63:23]
            imm <= imm_j @[ImmGen.scala 74:17]
    io.imm <= imm @[ImmGen.scala 78:12]

  module Decoder :
    input clock : Clock
    input reset : Reset
    output io : { flip inst : UInt<32>, bundleCtrl : { ctrlJump : UInt<1>, ctrlJAL : UInt<1>, ctrlBranch : UInt<1>, ctrlRegWrite : UInt<1>, ctrlLoad : UInt<1>, ctrlStore : UInt<1>, ctrlALUSrc : UInt<1>, ctrlOP : UInt<4>}, bundleReg : { rs1 : UInt<5>, rs2 : UInt<5>, rd : UInt<5>}, imm : UInt<32>}

    node opcode = bits(io.inst, 6, 0) @[Decoder.scala 26:25]
    node funct3 = bits(io.inst, 14, 12) @[Decoder.scala 27:25]
    node bit30 = bits(io.inst, 30, 30) @[Decoder.scala 28:25]
    node _io_bundleReg_rs1_T = bits(io.inst, 19, 15) @[Decoder.scala 30:32]
    io.bundleReg.rs1 <= _io_bundleReg_rs1_T @[Decoder.scala 30:22]
    node _io_bundleReg_rs2_T = bits(io.inst, 24, 20) @[Decoder.scala 31:32]
    io.bundleReg.rs2 <= _io_bundleReg_rs2_T @[Decoder.scala 31:22]
    node _io_bundleReg_rd_T = bits(io.inst, 11, 7) @[Decoder.scala 32:32]
    io.bundleReg.rd <= _io_bundleReg_rd_T @[Decoder.scala 32:22]
    wire immSel : UInt<3>
    immSel <= UInt<3>("h0")
    wire ctrlJump : UInt<1>
    ctrlJump <= UInt<1>("h0")
    wire ctrlJAL : UInt<1>
    ctrlJAL <= UInt<1>("h0")
    wire ctrlBranch : UInt<1>
    ctrlBranch <= UInt<1>("h0")
    wire ctrlRegWrite : UInt<1>
    ctrlRegWrite <= UInt<1>("h0")
    wire ctrlLoad : UInt<1>
    ctrlLoad <= UInt<1>("h0")
    wire ctrlStore : UInt<1>
    ctrlStore <= UInt<1>("h0")
    wire ctrlALUSrc : UInt<1>
    ctrlALUSrc <= UInt<1>("h0")
    wire ctrlOP : UInt<4>
    ctrlOP <= UInt<4>("h1")
    node _T = eq(UInt<6>("h33"), opcode) @[Decoder.scala 76:20]
    when _T : @[Decoder.scala 76:20]
      ctrlRegWrite <= UInt<1>("h1") @[Decoder.scala 82:26]
      ctrlALUSrc <= UInt<1>("h0") @[Decoder.scala 83:26]
      node _T_1 = eq(UInt<1>("h0"), funct3) @[Decoder.scala 85:28]
      when _T_1 : @[Decoder.scala 85:28]
        when bit30 : @[Decoder.scala 87:33]
          ctrlOP <= UInt<4>("h2") @[Decoder.scala 88:32]
        else :
          ctrlOP <= UInt<4>("h1") @[Decoder.scala 90:32]
      else :
        node _T_2 = eq(UInt<3>("h7"), funct3) @[Decoder.scala 85:28]
        when _T_2 : @[Decoder.scala 85:28]
          ctrlOP <= UInt<4>("h4") @[Decoder.scala 94:28]
        else :
          node _T_3 = eq(UInt<3>("h6"), funct3) @[Decoder.scala 85:28]
          when _T_3 : @[Decoder.scala 85:28]
            ctrlOP <= UInt<4>("h5") @[Decoder.scala 97:28]
          else :
            node _T_4 = eq(UInt<1>("h1"), funct3) @[Decoder.scala 85:28]
            when _T_4 : @[Decoder.scala 85:28]
              ctrlOP <= UInt<4>("h8") @[Decoder.scala 100:28]
            else :
              node _T_5 = eq(UInt<3>("h5"), funct3) @[Decoder.scala 85:28]
              when _T_5 : @[Decoder.scala 85:28]
                ctrlOP <= UInt<4>("h9") @[Decoder.scala 103:28]
    else :
      node _T_6 = eq(UInt<5>("h13"), opcode) @[Decoder.scala 76:20]
      when _T_6 : @[Decoder.scala 76:20]
        ctrlRegWrite <= UInt<1>("h1") @[Decoder.scala 113:26]
        ctrlALUSrc <= UInt<1>("h1") @[Decoder.scala 114:26]
        immSel <= UInt<3>("h1") @[Decoder.scala 115:29]
        node _T_7 = eq(UInt<1>("h0"), funct3) @[Decoder.scala 117:28]
        when _T_7 : @[Decoder.scala 117:28]
          ctrlOP <= UInt<4>("h1") @[Decoder.scala 119:28]
        else :
          node _T_8 = eq(UInt<3>("h6"), funct3) @[Decoder.scala 117:28]
          when _T_8 : @[Decoder.scala 117:28]
            ctrlOP <= UInt<4>("h5") @[Decoder.scala 122:28]
      else :
        node _T_9 = eq(UInt<2>("h3"), opcode) @[Decoder.scala 76:20]
        when _T_9 : @[Decoder.scala 76:20]
          ctrlRegWrite <= UInt<1>("h1") @[Decoder.scala 133:26]
          ctrlLoad <= UInt<1>("h1") @[Decoder.scala 134:26]
          ctrlALUSrc <= UInt<1>("h1") @[Decoder.scala 135:26]
          ctrlOP <= UInt<4>("h1") @[Decoder.scala 136:26]
          immSel <= UInt<3>("h1") @[Decoder.scala 137:29]
        else :
          node _T_10 = eq(UInt<7>("h67"), opcode) @[Decoder.scala 76:20]
          when _T_10 : @[Decoder.scala 76:20]
            ctrlJump <= UInt<1>("h1") @[Decoder.scala 146:26]
            ctrlJAL <= UInt<1>("h0") @[Decoder.scala 147:26]
            ctrlRegWrite <= UInt<1>("h1") @[Decoder.scala 148:26]
            ctrlALUSrc <= UInt<1>("h1") @[Decoder.scala 149:26]
            ctrlOP <= UInt<4>("h1") @[Decoder.scala 150:26]
            immSel <= UInt<3>("h1") @[Decoder.scala 151:29]
          else :
            node _T_11 = eq(UInt<6>("h23"), opcode) @[Decoder.scala 76:20]
            when _T_11 : @[Decoder.scala 76:20]
              ctrlStore <= UInt<1>("h1") @[Decoder.scala 160:26]
              ctrlALUSrc <= UInt<1>("h1") @[Decoder.scala 161:26]
              ctrlOP <= UInt<4>("h1") @[Decoder.scala 162:26]
              immSel <= UInt<3>("h2") @[Decoder.scala 163:29]
            else :
              node _T_12 = eq(UInt<7>("h63"), opcode) @[Decoder.scala 76:20]
              when _T_12 : @[Decoder.scala 76:20]
                ctrlBranch <= UInt<1>("h1") @[Decoder.scala 171:26]
                ctrlALUSrc <= UInt<1>("h0") @[Decoder.scala 172:26]
                immSel <= UInt<3>("h3") @[Decoder.scala 173:29]
                node _T_13 = eq(UInt<1>("h0"), funct3) @[Decoder.scala 175:28]
                when _T_13 : @[Decoder.scala 175:28]
                  ctrlOP <= UInt<4>("hc") @[Decoder.scala 177:28]
                else :
                  node _T_14 = eq(UInt<1>("h1"), funct3) @[Decoder.scala 175:28]
                  when _T_14 : @[Decoder.scala 175:28]
                    ctrlOP <= UInt<4>("hd") @[Decoder.scala 180:28]
              else :
                node _T_15 = eq(UInt<7>("h6f"), opcode) @[Decoder.scala 76:20]
                when _T_15 : @[Decoder.scala 76:20]
                  ctrlJump <= UInt<1>("h1") @[Decoder.scala 190:26]
                  ctrlJAL <= UInt<1>("h1") @[Decoder.scala 191:26]
                  ctrlRegWrite <= UInt<1>("h1") @[Decoder.scala 192:26]
                  ctrlALUSrc <= UInt<1>("h1") @[Decoder.scala 193:26]
                  ctrlOP <= UInt<4>("h1") @[Decoder.scala 194:26]
                  immSel <= UInt<3>("h4") @[Decoder.scala 195:29]
    inst immGen of ImmGen @[Decoder.scala 202:24]
    immGen.clock <= clock
    immGen.reset <= reset
    immGen.io.inst <= io.inst @[Decoder.scala 203:20]
    immGen.io.immSel <= immSel @[Decoder.scala 204:22]
    io.imm <= immGen.io.imm @[Decoder.scala 205:12]
    io.bundleCtrl.ctrlJump <= ctrlJump @[Decoder.scala 207:32]
    io.bundleCtrl.ctrlJAL <= ctrlJAL @[Decoder.scala 208:32]
    io.bundleCtrl.ctrlBranch <= ctrlBranch @[Decoder.scala 209:32]
    io.bundleCtrl.ctrlRegWrite <= ctrlRegWrite @[Decoder.scala 211:32]
    io.bundleCtrl.ctrlLoad <= ctrlLoad @[Decoder.scala 212:32]
    io.bundleCtrl.ctrlStore <= ctrlStore @[Decoder.scala 213:32]
    io.bundleCtrl.ctrlALUSrc <= ctrlALUSrc @[Decoder.scala 214:32]
    io.bundleCtrl.ctrlOP <= ctrlOP @[Decoder.scala 215:32]

  module Registers :
    input clock : Clock
    input reset : Reset
    output io : { flip ctrlRegWrite : UInt<1>, flip dataWrite : UInt<32>, flip bundleReg : { rs1 : UInt<5>, rs2 : UInt<5>, rd : UInt<5>}, dataRead1 : UInt<32>, dataRead2 : UInt<32>, flip ctrlJump : UInt<1>, flip pc : UInt<32>}

    reg regs : UInt<32>[32], clock with :
      reset => (UInt<1>("h0"), regs) @[Registers.scala 23:19]
    node _T = eq(io.bundleReg.rs1, UInt<1>("h0")) @[Registers.scala 26:28]
    when _T : @[Registers.scala 26:37]
      io.dataRead1 <= UInt<1>("h0") @[Registers.scala 27:22]
    else :
      io.dataRead1 <= regs[io.bundleReg.rs1] @[Registers.scala 29:22]
    node _T_1 = eq(io.bundleReg.rs2, UInt<1>("h0")) @[Registers.scala 31:28]
    when _T_1 : @[Registers.scala 31:37]
      io.dataRead2 <= UInt<1>("h0") @[Registers.scala 32:22]
    else :
      io.dataRead2 <= regs[io.bundleReg.rs2] @[Registers.scala 34:22]
    node _T_2 = neq(io.bundleReg.rd, UInt<1>("h0")) @[Registers.scala 41:45]
    node _T_3 = and(io.ctrlRegWrite, _T_2) @[Registers.scala 41:26]
    when _T_3 : @[Registers.scala 41:54]
      when io.ctrlJump : @[Registers.scala 42:27]
        node _regs_T = add(io.pc, UInt<3>("h4")) @[Registers.scala 43:44]
        node _regs_T_1 = tail(_regs_T, 1) @[Registers.scala 43:44]
        regs[io.bundleReg.rd] <= _regs_T_1 @[Registers.scala 43:35]
      else :
        regs[io.bundleReg.rd] <= io.dataWrite @[Registers.scala 45:35]

  module Alu :
    input clock : Clock
    input reset : Reset
    output io : { bundleAluControl : { flip ctrlALUSrc : UInt<1>, flip ctrlJump : UInt<1>, flip ctrlJAL : UInt<1>, flip ctrlOP : UInt<4>, flip ctrlBranch : UInt<1>}, flip dataRead1 : UInt<32>, flip dataRead2 : UInt<32>, flip imm : UInt<32>, flip pc : UInt<32>, resultBranch : UInt<1>, resultAlu : UInt<32>}

    wire resultBranch : UInt<1>
    resultBranch <= UInt<1>("h0")
    wire resultAlu : UInt<32>
    resultAlu <= UInt<32>("h0")
    wire operand1 : UInt<32> @[ALU.scala 27:24]
    wire operand2 : UInt<32> @[ALU.scala 28:24]
    wire addResult : UInt<32> @[ALU.scala 29:25]
    node _operand1_T = mux(io.bundleAluControl.ctrlJAL, io.pc, io.dataRead1) @[ALU.scala 31:20]
    operand1 <= _operand1_T @[ALU.scala 31:14]
    node _operand2_T = mux(io.bundleAluControl.ctrlALUSrc, io.imm, io.dataRead2) @[ALU.scala 32:20]
    operand2 <= _operand2_T @[ALU.scala 32:14]
    node _addResult_T = add(operand1, operand2) @[ALU.scala 33:27]
    node _addResult_T_1 = tail(_addResult_T, 1) @[ALU.scala 33:27]
    addResult <= _addResult_T_1 @[ALU.scala 33:15]
    node _T = eq(UInt<4>("h0"), io.bundleAluControl.ctrlOP) @[ALU.scala 35:40]
    when _T : @[ALU.scala 35:40]
      resultAlu <= UInt<1>("h0") @[ALU.scala 37:23]
      resultBranch <= UInt<1>("h0") @[ALU.scala 38:26]
    else :
      node _T_1 = eq(UInt<4>("h1"), io.bundleAluControl.ctrlOP) @[ALU.scala 35:40]
      when _T_1 : @[ALU.scala 35:40]
        node _resultAlu_T = eq(io.bundleAluControl.ctrlJAL, UInt<1>("h0")) @[ALU.scala 44:49]
        node _resultAlu_T_1 = and(io.bundleAluControl.ctrlJump, _resultAlu_T) @[ALU.scala 44:46]
        node _resultAlu_T_2 = not(UInt<32>("h1")) @[ALU.scala 45:30]
        node _resultAlu_T_3 = and(addResult, _resultAlu_T_2) @[ALU.scala 45:27]
        node _resultAlu_T_4 = mux(_resultAlu_T_1, _resultAlu_T_3, addResult) @[ALU.scala 43:29]
        resultAlu <= _resultAlu_T_4 @[ALU.scala 43:23]
      else :
        node _T_2 = eq(UInt<4>("h2"), io.bundleAluControl.ctrlOP) @[ALU.scala 35:40]
        when _T_2 : @[ALU.scala 35:40]
          node _resultAlu_T_5 = sub(operand1, operand2) @[ALU.scala 51:35]
          node _resultAlu_T_6 = tail(_resultAlu_T_5, 1) @[ALU.scala 51:35]
          resultAlu <= _resultAlu_T_6 @[ALU.scala 51:23]
        else :
          node _T_3 = eq(UInt<4>("h4"), io.bundleAluControl.ctrlOP) @[ALU.scala 35:40]
          when _T_3 : @[ALU.scala 35:40]
            node _resultAlu_T_7 = and(operand1, operand2) @[ALU.scala 55:35]
            resultAlu <= _resultAlu_T_7 @[ALU.scala 55:23]
          else :
            node _T_4 = eq(UInt<4>("h5"), io.bundleAluControl.ctrlOP) @[ALU.scala 35:40]
            when _T_4 : @[ALU.scala 35:40]
              node _resultAlu_T_8 = or(operand1, operand2) @[ALU.scala 59:35]
              resultAlu <= _resultAlu_T_8 @[ALU.scala 59:23]
            else :
              node _T_5 = eq(UInt<4>("h8"), io.bundleAluControl.ctrlOP) @[ALU.scala 35:40]
              when _T_5 : @[ALU.scala 35:40]
                node _resultAlu_T_9 = bits(operand2, 4, 0) @[ALU.scala 63:46]
                node _resultAlu_T_10 = dshl(operand1, _resultAlu_T_9) @[ALU.scala 63:35]
                resultAlu <= _resultAlu_T_10 @[ALU.scala 63:23]
              else :
                node _T_6 = eq(UInt<4>("h9"), io.bundleAluControl.ctrlOP) @[ALU.scala 35:40]
                when _T_6 : @[ALU.scala 35:40]
                  node _resultAlu_T_11 = bits(operand2, 4, 0) @[ALU.scala 67:46]
                  node _resultAlu_T_12 = dshr(operand1, _resultAlu_T_11) @[ALU.scala 67:35]
                  resultAlu <= _resultAlu_T_12 @[ALU.scala 67:23]
                else :
                  node _T_7 = eq(UInt<4>("hb"), io.bundleAluControl.ctrlOP) @[ALU.scala 35:40]
                  when _T_7 : @[ALU.scala 35:40]
                    node _resultAlu_T_13 = asSInt(operand1) @[ALU.scala 71:36]
                    node _resultAlu_T_14 = bits(operand2, 4, 0) @[ALU.scala 71:54]
                    node _resultAlu_T_15 = dshr(_resultAlu_T_13, _resultAlu_T_14) @[ALU.scala 71:43]
                    node _resultAlu_T_16 = asUInt(_resultAlu_T_15) @[ALU.scala 71:62]
                    resultAlu <= _resultAlu_T_16 @[ALU.scala 71:23]
                  else :
                    node _T_8 = eq(UInt<4>("hc"), io.bundleAluControl.ctrlOP) @[ALU.scala 35:40]
                    when _T_8 : @[ALU.scala 35:40]
                      node _resultBranch_T = eq(operand1, operand2) @[ALU.scala 75:38]
                      resultBranch <= _resultBranch_T @[ALU.scala 75:26]
                      node _resultAlu_T_17 = add(io.pc, io.imm) @[ALU.scala 76:32]
                      node _resultAlu_T_18 = tail(_resultAlu_T_17, 1) @[ALU.scala 76:32]
                      resultAlu <= _resultAlu_T_18 @[ALU.scala 76:23]
                    else :
                      node _T_9 = eq(UInt<4>("hd"), io.bundleAluControl.ctrlOP) @[ALU.scala 35:40]
                      when _T_9 : @[ALU.scala 35:40]
                        node _resultBranch_T_1 = neq(operand1, operand2) @[ALU.scala 80:38]
                        resultBranch <= _resultBranch_T_1 @[ALU.scala 80:26]
                        node _resultAlu_T_19 = add(io.pc, io.imm) @[ALU.scala 81:32]
                        node _resultAlu_T_20 = tail(_resultAlu_T_19, 1) @[ALU.scala 81:32]
                        resultAlu <= _resultAlu_T_20 @[ALU.scala 81:23]
    io.resultAlu <= resultAlu @[ALU.scala 85:18]
    io.resultBranch <= resultBranch @[ALU.scala 86:21]

  module MemData :
    input clock : Clock
    input reset : Reset
    output io : { bundleMemDataControl : { flip ctrlLoad : UInt<1>, flip ctrlStore : UInt<1>}, flip resultALU : UInt<32>, flip dataStore : UInt<32>, result : UInt<32>, flip extWriteEn : UInt<1>, flip extWriteAddr : UInt<32>, flip extWriteData : UInt<32>}

    cmem mem : UInt<32> [1024] @[Mem.scala 32:18]
    node cpuWordAddr = dshr(io.resultALU, UInt<2>("h2")) @[Mem.scala 41:36]
    node extWordAddr = dshr(io.extWriteAddr, UInt<2>("h2")) @[Mem.scala 42:39]
    wire result : UInt<32>
    result <= UInt<32>("h0")
    wire dataLoad : UInt<32>
    dataLoad <= UInt<32>("h0")
    node _dataLoad_T = bits(cpuWordAddr, 9, 0) @[Mem.scala 53:25]
    read mport dataLoad_MPORT = mem[_dataLoad_T], clock @[Mem.scala 53:25]
    dataLoad <= dataLoad_MPORT @[Mem.scala 53:14]
    when io.extWriteEn : @[Mem.scala 56:26]
      node _T = bits(extWordAddr, 9, 0)
      write mport MPORT = mem[_T], clock
      MPORT <= io.extWriteData
    else :
      when io.bundleMemDataControl.ctrlStore : @[Mem.scala 58:52]
        node _T_1 = bits(cpuWordAddr, 9, 0)
        write mport MPORT_1 = mem[_T_1], clock
        MPORT_1 <= io.dataStore
    when io.bundleMemDataControl.ctrlLoad : @[Mem.scala 65:45]
      result <= dataLoad @[Mem.scala 66:16]
    else :
      result <= io.resultALU @[Mem.scala 69:16]
    io.result <= result @[Mem.scala 73:15]

  module Controller :
    input clock : Clock
    input reset : Reset
    output io : { flip bundleControlIn : { ctrlJump : UInt<1>, ctrlJAL : UInt<1>, ctrlBranch : UInt<1>, ctrlRegWrite : UInt<1>, ctrlLoad : UInt<1>, ctrlStore : UInt<1>, ctrlALUSrc : UInt<1>, ctrlOP : UInt<4>}, flip bundleAluControl : { flip ctrlALUSrc : UInt<1>, flip ctrlJump : UInt<1>, flip ctrlJAL : UInt<1>, flip ctrlOP : UInt<4>, flip ctrlBranch : UInt<1>}, flip bundleMemDataControl : { flip ctrlLoad : UInt<1>, flip ctrlStore : UInt<1>}, bundleControlOut : { ctrlJump : UInt<1>, ctrlJAL : UInt<1>, ctrlBranch : UInt<1>, ctrlRegWrite : UInt<1>, ctrlLoad : UInt<1>, ctrlStore : UInt<1>, ctrlALUSrc : UInt<1>, ctrlOP : UInt<4>}}

    io.bundleAluControl.ctrlALUSrc <= io.bundleControlIn.ctrlALUSrc @[Controller.scala 19:36]
    io.bundleAluControl.ctrlJump <= io.bundleControlIn.ctrlJump @[Controller.scala 20:34]
    io.bundleAluControl.ctrlJAL <= io.bundleControlIn.ctrlJAL @[Controller.scala 21:33]
    io.bundleAluControl.ctrlOP <= io.bundleControlIn.ctrlOP @[Controller.scala 22:32]
    io.bundleAluControl.ctrlBranch <= io.bundleControlIn.ctrlBranch @[Controller.scala 23:36]
    io.bundleMemDataControl.ctrlLoad <= io.bundleControlIn.ctrlLoad @[Controller.scala 26:38]
    io.bundleMemDataControl.ctrlStore <= io.bundleControlIn.ctrlStore @[Controller.scala 27:39]
    io.bundleControlOut.ctrlOP <= io.bundleControlIn.ctrlOP @[Controller.scala 30:25]
    io.bundleControlOut.ctrlALUSrc <= io.bundleControlIn.ctrlALUSrc @[Controller.scala 30:25]
    io.bundleControlOut.ctrlStore <= io.bundleControlIn.ctrlStore @[Controller.scala 30:25]
    io.bundleControlOut.ctrlLoad <= io.bundleControlIn.ctrlLoad @[Controller.scala 30:25]
    io.bundleControlOut.ctrlRegWrite <= io.bundleControlIn.ctrlRegWrite @[Controller.scala 30:25]
    io.bundleControlOut.ctrlBranch <= io.bundleControlIn.ctrlBranch @[Controller.scala 30:25]
    io.bundleControlOut.ctrlJAL <= io.bundleControlIn.ctrlJAL @[Controller.scala 30:25]
    io.bundleControlOut.ctrlJump <= io.bundleControlIn.ctrlJump @[Controller.scala 30:25]

  module Top :
    input clock : Clock
    input reset : UInt<1>
    output io : { addr : UInt<32>, inst : UInt<32>, bundleCtrl : { ctrlJump : UInt<1>, ctrlJAL : UInt<1>, ctrlBranch : UInt<1>, ctrlRegWrite : UInt<1>, ctrlLoad : UInt<1>, ctrlStore : UInt<1>, ctrlALUSrc : UInt<1>, ctrlOP : UInt<4>}, ctrlBranchToPc : UInt<1>, ctrlJumpToPc : UInt<1>, resultALU : UInt<32>, rs1 : UInt<32>, rs2 : UInt<32>, imm : UInt<32>, resultBranch : UInt<1>, result : UInt<32>, flip instWriteEn : UInt<1>, flip instWriteAddr : UInt<32>, flip instWriteData : UInt<32>, flip dataWriteEn : UInt<1>, flip dataWriteAddr : UInt<32>, flip dataWriteData : UInt<32>}

    inst pcReg of PCReg @[Top.scala 43:23]
    pcReg.clock <= clock
    pcReg.reset <= reset
    inst memInst of MemInst @[Top.scala 44:25]
    memInst.clock <= clock
    memInst.reset <= reset
    inst decoder of Decoder @[Top.scala 45:25]
    decoder.clock <= clock
    decoder.reset <= reset
    inst registers of Registers @[Top.scala 46:27]
    registers.clock <= clock
    registers.reset <= reset
    inst alu of Alu @[Top.scala 47:21]
    alu.clock <= clock
    alu.reset <= reset
    inst memData of MemData @[Top.scala 48:25]
    memData.clock <= clock
    memData.reset <= reset
    inst controller of Controller @[Top.scala 49:28]
    controller.clock <= clock
    controller.reset <= reset
    pcReg.io.resultBranch <= alu.io.resultBranch @[Top.scala 52:27]
    pcReg.io.addrTarget <= memData.io.result @[Top.scala 53:25]
    pcReg.io.ctrlBranch <= controller.io.bundleControlOut.ctrlBranch @[Top.scala 54:25]
    pcReg.io.ctrlJump <= controller.io.bundleControlOut.ctrlJump @[Top.scala 55:23]
    memInst.io.addr <= pcReg.io.addrOut @[Top.scala 58:21]
    memInst.io.extWriteEn <= io.instWriteEn @[Top.scala 59:27]
    memInst.io.extWriteAddr <= io.instWriteAddr @[Top.scala 60:29]
    memInst.io.extWriteData <= io.instWriteData @[Top.scala 61:29]
    decoder.io.inst <= memInst.io.inst @[Top.scala 64:21]
    registers.io.bundleReg.rd <= decoder.io.bundleReg.rd @[Top.scala 67:28]
    registers.io.bundleReg.rs2 <= decoder.io.bundleReg.rs2 @[Top.scala 67:28]
    registers.io.bundleReg.rs1 <= decoder.io.bundleReg.rs1 @[Top.scala 67:28]
    registers.io.ctrlRegWrite <= controller.io.bundleControlOut.ctrlRegWrite @[Top.scala 68:31]
    registers.io.ctrlJump <= controller.io.bundleControlOut.ctrlJump @[Top.scala 69:27]
    registers.io.dataWrite <= memData.io.result @[Top.scala 70:28]
    registers.io.pc <= pcReg.io.addrOut @[Top.scala 71:21]
    alu.io.bundleAluControl.ctrlBranch <= controller.io.bundleAluControl.ctrlBranch @[Top.scala 74:29]
    alu.io.bundleAluControl.ctrlOP <= controller.io.bundleAluControl.ctrlOP @[Top.scala 74:29]
    alu.io.bundleAluControl.ctrlJAL <= controller.io.bundleAluControl.ctrlJAL @[Top.scala 74:29]
    alu.io.bundleAluControl.ctrlJump <= controller.io.bundleAluControl.ctrlJump @[Top.scala 74:29]
    alu.io.bundleAluControl.ctrlALUSrc <= controller.io.bundleAluControl.ctrlALUSrc @[Top.scala 74:29]
    alu.io.dataRead1 <= registers.io.dataRead1 @[Top.scala 75:22]
    alu.io.dataRead2 <= registers.io.dataRead2 @[Top.scala 76:22]
    alu.io.imm <= decoder.io.imm @[Top.scala 77:16]
    alu.io.pc <= pcReg.io.addrOut @[Top.scala 78:15]
    memData.io.bundleMemDataControl.ctrlStore <= controller.io.bundleMemDataControl.ctrlStore @[Top.scala 81:37]
    memData.io.bundleMemDataControl.ctrlLoad <= controller.io.bundleMemDataControl.ctrlLoad @[Top.scala 81:37]
    memData.io.dataStore <= registers.io.dataRead2 @[Top.scala 82:26]
    memData.io.resultALU <= alu.io.resultAlu @[Top.scala 83:26]
    memData.io.extWriteEn <= io.dataWriteEn @[Top.scala 84:27]
    memData.io.extWriteAddr <= io.dataWriteAddr @[Top.scala 85:29]
    memData.io.extWriteData <= io.dataWriteData @[Top.scala 86:29]
    controller.io.bundleControlIn.ctrlOP <= decoder.io.bundleCtrl.ctrlOP @[Top.scala 89:35]
    controller.io.bundleControlIn.ctrlALUSrc <= decoder.io.bundleCtrl.ctrlALUSrc @[Top.scala 89:35]
    controller.io.bundleControlIn.ctrlStore <= decoder.io.bundleCtrl.ctrlStore @[Top.scala 89:35]
    controller.io.bundleControlIn.ctrlLoad <= decoder.io.bundleCtrl.ctrlLoad @[Top.scala 89:35]
    controller.io.bundleControlIn.ctrlRegWrite <= decoder.io.bundleCtrl.ctrlRegWrite @[Top.scala 89:35]
    controller.io.bundleControlIn.ctrlBranch <= decoder.io.bundleCtrl.ctrlBranch @[Top.scala 89:35]
    controller.io.bundleControlIn.ctrlJAL <= decoder.io.bundleCtrl.ctrlJAL @[Top.scala 89:35]
    controller.io.bundleControlIn.ctrlJump <= decoder.io.bundleCtrl.ctrlJump @[Top.scala 89:35]
    io.addr <= pcReg.io.addrOut @[Top.scala 92:13]
    io.bundleCtrl.ctrlOP <= decoder.io.bundleCtrl.ctrlOP @[Top.scala 93:19]
    io.bundleCtrl.ctrlALUSrc <= decoder.io.bundleCtrl.ctrlALUSrc @[Top.scala 93:19]
    io.bundleCtrl.ctrlStore <= decoder.io.bundleCtrl.ctrlStore @[Top.scala 93:19]
    io.bundleCtrl.ctrlLoad <= decoder.io.bundleCtrl.ctrlLoad @[Top.scala 93:19]
    io.bundleCtrl.ctrlRegWrite <= decoder.io.bundleCtrl.ctrlRegWrite @[Top.scala 93:19]
    io.bundleCtrl.ctrlBranch <= decoder.io.bundleCtrl.ctrlBranch @[Top.scala 93:19]
    io.bundleCtrl.ctrlJAL <= decoder.io.bundleCtrl.ctrlJAL @[Top.scala 93:19]
    io.bundleCtrl.ctrlJump <= decoder.io.bundleCtrl.ctrlJump @[Top.scala 93:19]
    io.ctrlBranchToPc <= controller.io.bundleControlOut.ctrlBranch @[Top.scala 94:23]
    io.ctrlJumpToPc <= controller.io.bundleControlOut.ctrlJump @[Top.scala 95:21]
    io.inst <= memInst.io.inst @[Top.scala 96:13]
    io.result <= memData.io.result @[Top.scala 97:15]
    io.resultALU <= alu.io.resultAlu @[Top.scala 98:18]
    io.resultBranch <= alu.io.resultBranch @[Top.scala 99:21]
    io.imm <= decoder.io.imm @[Top.scala 100:12]
    io.rs1 <= registers.io.dataRead1 @[Top.scala 101:12]
    io.rs2 <= registers.io.dataRead2 @[Top.scala 102:12]

