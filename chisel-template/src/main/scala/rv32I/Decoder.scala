package rv32I

import chisel3._
import chisel3.util._

import config.Configs._
import utils.OP_TYPES._
import utils._
import utils.IMM_TYPES._
import utils.{BundleControl, BundleReg, IMM_TYPES, OP_TYPES}
import rv32I.ImmGen 

class DecoderIO extends Bundle {
    val inst = Input(UInt(INST_WIDTH.W))
    val bundleCtrl = new BundleControl()
    val bundleReg = new BundleReg()
    val imm = Output(UInt(DATA_WIDTH.W))
}

class Decoder extends Module {
    val io = IO(new DecoderIO())

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
    // val imm_i = Cat(Fill(20, io.inst(31)), io.inst(31, 20))
    // val imm_s = Cat(Fill(20, io.inst(31)), io.inst(31, 25), io.inst(11, 7))
    // val imm_b = Cat(
    //     Fill(19, io.inst(31)),   // 高位符号扩展
    //     io.inst(31),             // imm[12]
    //     io.inst(7),              // imm[11]
    //     io.inst(30, 25),         // imm[10:5]
    //     io.inst(11, 8),          // imm[4:1]
    //     0.U(1.W)                 // imm[0]
    // )
    // val imm_j = Cat(
    //     Fill(11, io.inst(31)),   // 高位符号扩展
    //     io.inst(31),             // imm[20]
    //     io.inst(19, 12),         // imm[19:12]
    //     io.inst(20),             // imm[11]
    //     io.inst(30, 21),         // imm[10:1]
    //     0.U(1.W)                 // imm[0]
    // )

    val immSel = WireDefault(IMM_X)
    

    // --------------------------------------------------
    // 控制信号默认值
    // --------------------------------------------------
    val ctrlJump      = WireDefault(false.B)
    val ctrlJAL       = WireDefault(false.B)
    val ctrlBranch    = WireDefault(false.B)

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
            immSel          := IMM_I

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
            immSel          := IMM_I
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
            immSel          := IMM_I
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
            immSel          := IMM_S
        }

        // ==============================================
        // beq, bne
        // opcode = 1100011
        // ==============================================
        is("b1100011".U) {
            ctrlBranch   := true.B
            ctrlALUSrc   := false.B
            immSel          := IMM_B

            switch(funct3) {
                is("b000".U) {
                    ctrlOP := OP_EQ
                }
                is("b001".U) {
                    ctrlOP := OP_NEQ
                }
            }
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
            immSel          := IMM_J
        }
    }

    // --------------------------------------------------
    // 输出连接
    // --------------------------------------------------
    val immGen = Module(new ImmGen())
    immGen.io.inst := io.inst
    immGen.io.immSel := immSel
    io.imm := immGen.io.imm

    io.bundleCtrl.ctrlJump     := ctrlJump
    io.bundleCtrl.ctrlJAL      := ctrlJAL
    io.bundleCtrl.ctrlBranch   := ctrlBranch

    io.bundleCtrl.ctrlRegWrite := ctrlRegWrite
    io.bundleCtrl.ctrlLoad     := ctrlLoad
    io.bundleCtrl.ctrlStore    := ctrlStore
    io.bundleCtrl.ctrlALUSrc   := ctrlALUSrc
    io.bundleCtrl.ctrlOP       := ctrlOP

    // io.imm := immGen.io.imm
}