circuit Alu :
  module Alu :
    input clock : Clock
    input reset : UInt<1>
    output io : { bundleAluControl : { flip ctrlALUSrc : UInt<1>, flip ctrlJAL : UInt<1>, flip ctrlOP : UInt<4>, flip ctrlBranch : UInt<1>}, flip dataRead1 : UInt<32>, flip dataRead2 : UInt<32>, flip imm : UInt<32>, flip pc : UInt<32>, resultBranch : UInt<1>, resultAlu : UInt<32>}

    wire resultBranch : UInt<1>
    resultBranch <= UInt<1>("h0")
    wire resultAlu : UInt<32>
    resultAlu <= UInt<32>("h0")
    wire operand1 : UInt<32> @[ALU.scala 26:24]
    wire operand2 : UInt<32> @[ALU.scala 27:24]
    node _operand1_T = mux(io.bundleAluControl.ctrlJAL, io.pc, io.dataRead1) @[ALU.scala 29:20]
    operand1 <= _operand1_T @[ALU.scala 29:14]
    node _operand2_T = mux(io.bundleAluControl.ctrlALUSrc, io.imm, io.dataRead2) @[ALU.scala 30:20]
    operand2 <= _operand2_T @[ALU.scala 30:14]
    node _T = eq(UInt<1>("h0"), io.bundleAluControl.ctrlOP) @[ALU.scala 32:40]
    when _T : @[ALU.scala 32:40]
      resultAlu <= UInt<1>("h0") @[ALU.scala 34:23]
      resultBranch <= UInt<1>("h0") @[ALU.scala 35:26]
    else :
      node _T_1 = eq(UInt<1>("h1"), io.bundleAluControl.ctrlOP) @[ALU.scala 32:40]
      when _T_1 : @[ALU.scala 32:40]
        node _resultAlu_T = add(operand1, operand2) @[ALU.scala 39:35]
        node _resultAlu_T_1 = tail(_resultAlu_T, 1) @[ALU.scala 39:35]
        resultAlu <= _resultAlu_T_1 @[ALU.scala 39:23]
      else :
        node _T_2 = eq(UInt<2>("h2"), io.bundleAluControl.ctrlOP) @[ALU.scala 32:40]
        when _T_2 : @[ALU.scala 32:40]
          node _resultAlu_T_2 = sub(operand1, operand2) @[ALU.scala 43:35]
          node _resultAlu_T_3 = tail(_resultAlu_T_2, 1) @[ALU.scala 43:35]
          resultAlu <= _resultAlu_T_3 @[ALU.scala 43:23]
        else :
          node _T_3 = eq(UInt<3>("h4"), io.bundleAluControl.ctrlOP) @[ALU.scala 32:40]
          when _T_3 : @[ALU.scala 32:40]
            node _resultAlu_T_4 = and(operand1, operand2) @[ALU.scala 47:35]
            resultAlu <= _resultAlu_T_4 @[ALU.scala 47:23]
          else :
            node _T_4 = eq(UInt<3>("h5"), io.bundleAluControl.ctrlOP) @[ALU.scala 32:40]
            when _T_4 : @[ALU.scala 32:40]
              node _resultAlu_T_5 = or(operand1, operand2) @[ALU.scala 51:35]
              resultAlu <= _resultAlu_T_5 @[ALU.scala 51:23]
            else :
              node _T_5 = eq(UInt<4>("h8"), io.bundleAluControl.ctrlOP) @[ALU.scala 32:40]
              when _T_5 : @[ALU.scala 32:40]
                node _resultAlu_T_6 = bits(operand2, 4, 0) @[ALU.scala 55:46]
                node _resultAlu_T_7 = dshl(operand1, _resultAlu_T_6) @[ALU.scala 55:35]
                resultAlu <= _resultAlu_T_7 @[ALU.scala 55:23]
              else :
                node _T_6 = eq(UInt<4>("h9"), io.bundleAluControl.ctrlOP) @[ALU.scala 32:40]
                when _T_6 : @[ALU.scala 32:40]
                  node _resultAlu_T_8 = bits(operand2, 4, 0) @[ALU.scala 59:46]
                  node _resultAlu_T_9 = dshr(operand1, _resultAlu_T_8) @[ALU.scala 59:35]
                  resultAlu <= _resultAlu_T_9 @[ALU.scala 59:23]
                else :
                  node _T_7 = eq(UInt<4>("hb"), io.bundleAluControl.ctrlOP) @[ALU.scala 32:40]
                  when _T_7 : @[ALU.scala 32:40]
                    node _resultAlu_T_10 = asSInt(operand1) @[ALU.scala 63:36]
                    node _resultAlu_T_11 = bits(operand2, 4, 0) @[ALU.scala 63:54]
                    node _resultAlu_T_12 = dshr(_resultAlu_T_10, _resultAlu_T_11) @[ALU.scala 63:43]
                    node _resultAlu_T_13 = asUInt(_resultAlu_T_12) @[ALU.scala 63:62]
                    resultAlu <= _resultAlu_T_13 @[ALU.scala 63:23]
                  else :
                    node _T_8 = eq(UInt<4>("hc"), io.bundleAluControl.ctrlOP) @[ALU.scala 32:40]
                    when _T_8 : @[ALU.scala 32:40]
                      node _resultBranch_T = eq(operand1, operand2) @[ALU.scala 67:38]
                      resultBranch <= _resultBranch_T @[ALU.scala 67:26]
                      node _resultAlu_T_14 = add(io.pc, io.imm) @[ALU.scala 68:32]
                      node _resultAlu_T_15 = tail(_resultAlu_T_14, 1) @[ALU.scala 68:32]
                      resultAlu <= _resultAlu_T_15 @[ALU.scala 68:23]
                    else :
                      node _T_9 = eq(UInt<4>("hd"), io.bundleAluControl.ctrlOP) @[ALU.scala 32:40]
                      when _T_9 : @[ALU.scala 32:40]
                        node _resultBranch_T_1 = neq(operand1, operand2) @[ALU.scala 72:38]
                        resultBranch <= _resultBranch_T_1 @[ALU.scala 72:26]
                        node _resultAlu_T_16 = add(io.pc, io.imm) @[ALU.scala 73:32]
                        node _resultAlu_T_17 = tail(_resultAlu_T_16, 1) @[ALU.scala 73:32]
                        resultAlu <= _resultAlu_T_17 @[ALU.scala 73:23]
    io.resultAlu <= resultAlu @[ALU.scala 77:18]
    io.resultBranch <= resultBranch @[ALU.scala 78:21]

