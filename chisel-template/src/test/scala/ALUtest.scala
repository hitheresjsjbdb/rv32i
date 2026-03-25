import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import rv32I.Alu   
import config.Configs._
import utils.OP_TYPES._

trait AluTestFunc {
    private val Mask32 = (BigInt(1) << DATA_WIDTH) - 1

    // 只测试当前 ALU.scala 已实现的操作
    val ALU_OPS = Seq(
        OP_NOP,
        OP_ADD,
        OP_SUB,
        OP_AND,
        OP_OR,
        OP_SLL,
        OP_SRL,
        OP_SRA
    )

    val BRANCH_OPS = Seq(OP_EQ, OP_NEQ)

    // 固定边界值 + 随机值，覆盖 32 位运算行为
    val operandList = Seq(
        BigInt(0),
        BigInt(1),
        BigInt("7fffffff", 16),
        BigInt("80000000", 16),
        BigInt("ffffffff", 16),
        BigInt("12345678", 16),
        BigInt("87654321", 16)
    ) ++ Seq.fill(6)(BigInt(scala.util.Random.nextLong() & 0xffffffffL))

    private def mask32(value: BigInt): BigInt = value & Mask32

    private def toSigned32(value: BigInt): BigInt = {
        val masked = mask32(value)
        if ((masked & (BigInt(1) << 31)) != 0) masked - (BigInt(1) << 32) else masked
    }

    // 用于比对的正确结果
    def aluExpected(a: BigInt, b: BigInt, op: UInt): (BigInt, Boolean) = {
        val shamt = (b & BigInt("1f", 16)).toInt
        op.litValue match {
            case value if value == OP_NOP.litValue => (BigInt(0), false)
            case value if value == OP_ADD.litValue => (mask32(a + b), false)
            case value if value == OP_SUB.litValue => (mask32(a - b), false)
            case value if value == OP_AND.litValue => (mask32(a & b), false)
            case value if value == OP_OR.litValue => (mask32(a | b), false)
            case value if value == OP_SLL.litValue => (mask32(a << shamt), false)
            case value if value == OP_SRL.litValue => (mask32(mask32(a) >> shamt), false)
            case value if value == OP_SRA.litValue => (mask32(toSigned32(a) >> shamt), false)
            case value if value == OP_EQ.litValue => (BigInt(0), mask32(a) == mask32(b))
            case value if value == OP_NEQ.litValue => (BigInt(0), mask32(a) != mask32(b))
            case _ => (BigInt(0), false)
        }
    }

    def testRegReg(dut: Alu, a: BigInt, b: BigInt, op: UInt): Unit = {
        dut.io.bundleAluControl.ctrlALUSrc.poke(false.B)
        dut.io.bundleAluControl.ctrlJump.poke(false.B)
        dut.io.bundleAluControl.ctrlJAL.poke(false.B)
        dut.io.bundleAluControl.ctrlBranch.poke(false.B)
        dut.io.bundleAluControl.ctrlOP.poke(op)
        dut.io.pc.poke(0.U)
        dut.io.imm.poke(0.U)
        dut.io.dataRead1.poke(a.U)
        dut.io.dataRead2.poke(b.U)
        val (resultAlu, resultBranch) = aluExpected(a, b, op)
        dut.io.resultAlu.expect(resultAlu.U)
        dut.io.resultBranch.expect(resultBranch.B)
    }

    def testImm(dut: Alu, a: BigInt, imm: BigInt, op: UInt): Unit = {
        dut.io.bundleAluControl.ctrlALUSrc.poke(true.B)
        dut.io.bundleAluControl.ctrlJump.poke(false.B)
        dut.io.bundleAluControl.ctrlJAL.poke(false.B)
        dut.io.bundleAluControl.ctrlBranch.poke(false.B)
        dut.io.bundleAluControl.ctrlOP.poke(op)
        dut.io.pc.poke(0.U)
        dut.io.imm.poke(imm.U)
        dut.io.dataRead1.poke(a.U)
        dut.io.dataRead2.poke(0.U)
        val (resultAlu, resultBranch) = aluExpected(a, imm, op)
        dut.io.resultAlu.expect(resultAlu.U)
        dut.io.resultBranch.expect(resultBranch.B)
    }

    def testBranch(dut: Alu, a: BigInt, b: BigInt, pc: BigInt, imm: BigInt, op: UInt): Unit = {
        dut.io.bundleAluControl.ctrlALUSrc.poke(false.B)
        dut.io.bundleAluControl.ctrlJump.poke(false.B)
        dut.io.bundleAluControl.ctrlJAL.poke(false.B)
        dut.io.bundleAluControl.ctrlBranch.poke(true.B)
        dut.io.bundleAluControl.ctrlOP.poke(op)
        dut.io.pc.poke(pc.U)
        dut.io.imm.poke(imm.U)
        dut.io.dataRead1.poke(a.U)
        dut.io.dataRead2.poke(b.U)

        val (_, expectedBranch) = aluExpected(a, b, op)
        dut.io.resultAlu.expect(mask32(pc + imm).U)
        dut.io.resultBranch.expect(expectedBranch.B)
    }

    def testJalAddress(dut: Alu, pc: BigInt, imm: BigInt): Unit = {
        dut.io.bundleAluControl.ctrlALUSrc.poke(true.B)
        dut.io.bundleAluControl.ctrlJump.poke(true.B)
        dut.io.bundleAluControl.ctrlJAL.poke(true.B)
        dut.io.bundleAluControl.ctrlBranch.poke(false.B)
        dut.io.bundleAluControl.ctrlOP.poke(OP_ADD)
        dut.io.pc.poke(pc.U)
        dut.io.imm.poke(imm.U)
        dut.io.dataRead1.poke(0.U)
        dut.io.dataRead2.poke(0.U)

        dut.io.resultAlu.expect(mask32(pc + imm).U)
        dut.io.resultBranch.expect(false.B)
    }

    def testJalrAddress(dut: Alu, rs1: BigInt, imm: BigInt): Unit = {
        val expectedTarget = mask32(rs1 + imm) & ~BigInt(1)

        dut.io.bundleAluControl.ctrlALUSrc.poke(true.B)
        dut.io.bundleAluControl.ctrlJump.poke(true.B)
        dut.io.bundleAluControl.ctrlJAL.poke(false.B)
        dut.io.bundleAluControl.ctrlBranch.poke(false.B)
        dut.io.bundleAluControl.ctrlOP.poke(OP_ADD)
        dut.io.pc.poke(0.U)
        dut.io.imm.poke(imm.U)
        dut.io.dataRead1.poke(rs1.U)
        dut.io.dataRead2.poke(0.U)

        dut.io.resultAlu.expect(expectedTarget.U)
        dut.io.resultBranch.expect(false.B)
    }

    // 遍历功能和操作数进行测试
    def testFn(dut: Alu): Unit = {
        for (a <- operandList) {
            for (b <- operandList) {
                for (op <- ALU_OPS) {
                    testRegReg(dut, a, b, op)
                    testImm(dut, a, b, op)
                }

                testBranch(dut, a, b, BigInt("1000", 16), BigInt("10", 16), OP_EQ)
                testBranch(dut, a, b, BigInt("2000", 16), BigInt("20", 16), OP_NEQ)
                testJalAddress(dut, a, b)
                testJalrAddress(dut, a, b)
            }
        }
    }
}

class AluTest extends AnyFlatSpec with ChiselScalatestTester with AluTestFunc {
    "ALU" should "pass" in {
        test(new Alu) { dut =>
            testFn(dut)
        }
    }
}