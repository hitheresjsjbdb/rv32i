error id: file://<WORKSPACE>/src/main/scala/rv32I/Decoder.scala:rv32isc/DecoderIO#
file://<WORKSPACE>/src/main/scala/rv32I/Decoder.scala
empty definition using pc, found symbol in pc: 
found definition using semanticdb; symbol rv32isc/DecoderIO#
empty definition using fallback
non-local guesses:

offset: 376
uri: file://<WORKSPACE>/src/main/scala/rv32I/Decoder.scala
text:
```scala
package rv32isc

import chisel3._
import chisel3.util._

import config.Configs._
import utils.OP_TYPES._
import utils._

class DecoderIO extends Bundle {
    val inst = Input(UInt(INST_WIDTH.W))
    val bundleCtrl = new BundleControl()
    val bundleReg = new BundleReg()
    val imm = Output(UInt(DATA_WIDTH.W))
}

class Decoder extends Module {
    val io = IO(new DecoderIO@@())

    // --------------------------------------------------
    // 指令字段提取
    // --------------------------------------------------
    val opcode = io.inst(6, 0)
    val funct3 = io.inst(14, 12)
    val bit30  = io.inst(30)

    io.bundleReg.rs1 := io.inst(19, 15)
    io.bundleReg.rs2 := io.inst(24, 20)
    io.bundleReg.rd  := io.inst(11, 7)

    // --------------------------------------------------
    // 仅保留需要的 4 类立即数
    // --------------------------------------------------
    val imm_i = Cat(Fill(20, io.inst(31)), io.inst(31, 20))
    val imm_s = Cat(Fill(20, io.inst(31)), io.inst(31, 25), io.inst(11, 7))
    val imm_b = Cat(
        Fill(19, io.inst(31)),   // 高位符号扩展
        io.inst(31),             // imm[12]
        io.inst(7),              // imm[11]
        io.inst(30, 25),         // imm[10:5]
        io.inst(11, 8),          // imm[4:1]
        0.U(1.W)                 // imm[0]
    )
    val imm_j = Cat(
        Fill(11, io.inst(31)),   // 高位符号扩展
        io.inst(31),             // imm[20]
        io.inst(19, 12),         // imm[19:12]
        io.inst(20),             // imm[11]
        io.inst(30, 21),         // imm[10:1]
        0.U(1.W)                 // imm[0]
    )

    val imm = WireDefault(0.U(DATA_WIDTH.W))

    // --------------------------------------------------
    // 控制信号默认值
    // --------------------------------------------------
    val ctrlJump      = WireDefault(false.B)
    val ctrlJAL       = WireDefault(false.B)
    val ctrlBranch    = WireDefault(false.B)
    val ctrlBranchNE  = WireDefault(false.B)

    val ctrlRegWrite  = WireDefault(false.B)
    val ctrlLoad      = WireDefault(false.B)
    val ctrlStore     = WireDefault(false.B)
    val ctrlALUSrc    = WireDefault(false.B)

    val ctrlOP        = WireDefault(OP_ADD)

    // --------------------------------------------------
    // opcode 解码
    // --------------------------------------------------
    switch(opcode) {
        // ==============================================
        // R-type: add, sub, and, or, sll, srl
        // opcode = 0110011
        // ==============================================
        is("b0110011".U) {
            ctrlRegWrite := true.B
            ctrlALUSrc   := false.B

            switch(funct3) {
                is("b000".U) {
                    when(bit30) {
                        ctrlOP := OP_SUB   // sub
                    }.otherwise {
                        ctrlOP := OP_ADD   // add
                    }
                }
                is("b111".U) {
                    ctrlOP := OP_AND       // and
                }
                is("b110".U) {
                    ctrlOP := OP_OR        // or
                }
                is("b001".U) {
                    ctrlOP := OP_SLL       // sll
                }
                is("b101".U) {
                    ctrlOP := OP_SRL       // srl
                }
            }
        }

        // ==============================================
        // I-type arithmetic: addi, ori
        // opcode = 0010011
        // ==============================================
        is("b0010011".U) {
            ctrlRegWrite := true.B
            ctrlALUSrc   := true.B
            imm          := imm_i

            switch(funct3) {
                is("b000".U) {
                    ctrlOP := OP_ADD       // addi
                }
                is("b110".U) {
                    ctrlOP := OP_OR        // ori
                }
            }
        }

        // ==============================================
        // lw
        // opcode = 0000011
        // funct3 = 010
        // ==============================================
        is("b0000011".U) {
            ctrlRegWrite := true.B
            ctrlLoad     := true.B
            ctrlALUSrc   := true.B
            ctrlOP       := OP_ADD         // 地址 = rs1 + imm
            imm          := imm_i
        }

        // ==============================================
        // jalr
        // opcode = 1100111
        // funct3 = 000
        // ==============================================
        is("b1100111".U) {
            ctrlJump     := true.B
            ctrlJAL      := false.B        // jalr
            ctrlRegWrite := true.B         // rd <- PC + 4
            ctrlALUSrc   := true.B         // 跳转目标 = rs1 + imm
            ctrlOP       := OP_ADD
            imm          := imm_i
        }

        // ==============================================
        // sw
        // opcode = 0100011
        // funct3 = 010
        // ==============================================
        is("b0100011".U) {
            ctrlStore    := true.B
            ctrlALUSrc   := true.B
            ctrlOP       := OP_ADD         // 地址 = rs1 + imm
            imm          := imm_s
        }

        // ==============================================
        // beq, bne
        // opcode = 1100011
        // ==============================================
        is("b1100011".U) {
            ctrlBranch   := true.B
            ctrlALUSrc   := false.B
            imm          := imm_b

            switch(funct3) {
                is("b000".U) {
                    ctrlBranchNE := false.B   // beq
                }
                is("b001".U) {
                    ctrlBranchNE := true.B    // bne
                }
            }

            // 这里 ctrlOP 实际上对 beq/bne 可以不强依赖，
            // 如果你后面 branch 比较单独做，这个值无所谓；
            // 如果你想用 ALU 做 rs1-rs2 再判零，也可以保留为 SUB。
            ctrlOP := OP_SUB
        }

        // ==============================================
        // jal
        // opcode = 1101111
        // ==============================================
        is("b1101111".U) {
            ctrlJump     := true.B
            ctrlJAL      := true.B         // jal
            ctrlRegWrite := true.B         // rd <- PC + 4
            ctrlALUSrc   := true.B
            ctrlOP       := OP_ADD         // 跳转目标 = PC + imm
            imm          := imm_j
        }
    }

    // --------------------------------------------------
    // 输出连接
    // --------------------------------------------------
    io.bundleCtrl.ctrlJump     := ctrlJump
    io.bundleCtrl.ctrlJAL      := ctrlJAL
    io.bundleCtrl.ctrlBranch   := ctrlBranch
    io.bundleCtrl.ctrlBranchNE := ctrlBranchNE

    io.bundleCtrl.ctrlRegWrite := ctrlRegWrite
    io.bundleCtrl.ctrlLoad     := ctrlLoad
    io.bundleCtrl.ctrlStore    := ctrlStore
    io.bundleCtrl.ctrlALUSrc   := ctrlALUSrc
    io.bundleCtrl.ctrlOP       := ctrlOP

    io.imm := imm
}
```


#### Short summary: 

empty definition using pc, found symbol in pc: 