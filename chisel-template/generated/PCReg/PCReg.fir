circuit PCReg :
  module PCReg :
    input clock : Clock
    input reset : UInt<1>
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

