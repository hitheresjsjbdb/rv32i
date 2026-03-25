

import chisel3._
import chiseltest._
import chisel3.util._
import org.scalatest.flatspec.AnyFlatSpec

import config.Configs._
import rv32I.Decoder
trait DecoderTestFunc {
    def testFn(dut: Decoder): Unit = {
        // JAL x3, L0
        // L0:
        // JALR x4, x3, 4
        // BEQ x5, x6, L1
        // L1:
        // BNE x1, x2, L2
        // LW x1, 0x4, x2
        // SW x1, 0x4, x1
        // ADDI x1, x1, 0x4
        // ORI x1, x1, 0x4
        // ADD x1, x1, x2
        // SUB x1, x1, x2
        // SLL x1, x1, x2
        // SRL x1, x1, x2
        // OR x1, x1, x2
        // AND x1, x1, x2

        val inst_list = Seq(
            "h004001ef".U,
            "h00418267".U,
            "h00628263".U,
            "h00209263".U,
            "h00412083".U,
            "h0010a223".U,
            "h00408093".U,
            "h0040e093".U,
            "h002080b3".U,
            "h402080b3".U,
            "h002090b3".U,
            "h0020d0b3".U,
            "h0020e0b3".U,
            "h0020f0b3".U
        )

        for (inst <- inst_list) {
            dut.io.inst.poke(inst)
            println(dut.io.bundleReg.rs1.peek().litValue)
            println(dut.io.bundleReg.rs2.peek().litValue)
            println(dut.io.imm.peek())
            println(dut.io.bundleReg.rd.peek().litValue)
            println(dut.io.bundleCtrl.peek())
        }
    }
}

class DecoderTest
    extends AnyFlatSpec
    with ChiselScalatestTester
    with DecoderTestFunc {
    "Decoder" should "pass" in {
        test(new Decoder) { dut =>
            testFn(dut)
        }
    }
}
