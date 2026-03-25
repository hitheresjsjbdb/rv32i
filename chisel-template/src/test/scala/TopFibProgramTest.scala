import chisel3._
import chiseltest._
import config.Configs._
import org.scalatest.flatspec.AnyFlatSpec
import rv32I.Top

object TinyRv32Asm {
    private def mask(value: Int, width: Int): BigInt = {
        val allOnes = (BigInt(1) << width) - 1
        BigInt(value) & allOnes
    }

    def add(rd: Int, rs1: Int, rs2: Int): BigInt = {
        encodeR(funct7 = 0x00, rs2 = rs2, rs1 = rs1, funct3 = 0x0, rd = rd, opcode = 0x33)
    }

    def addi(rd: Int, rs1: Int, imm: Int): BigInt = {
        encodeI(imm = imm, rs1 = rs1, funct3 = 0x0, rd = rd, opcode = 0x13)
    }

    def lw(rd: Int, rs1: Int, imm: Int): BigInt = {
        encodeI(imm = imm, rs1 = rs1, funct3 = 0x2, rd = rd, opcode = 0x03)
    }

    def sw(rs2: Int, rs1: Int, imm: Int): BigInt = {
        encodeS(imm = imm, rs2 = rs2, rs1 = rs1, funct3 = 0x2, opcode = 0x23)
    }

    def beq(rs1: Int, rs2: Int, offset: Int): BigInt = {
        encodeB(offset = offset, rs2 = rs2, rs1 = rs1, funct3 = 0x0, opcode = 0x63)
    }

    def jal(rd: Int, offset: Int): BigInt = {
        encodeJ(offset = offset, rd = rd, opcode = 0x6f)
    }

    private def encodeR(
        funct7: Int,
        rs2: Int,
        rs1: Int,
        funct3: Int,
        rd: Int,
        opcode: Int
    ): BigInt = {
        (BigInt(funct7 & 0x7f) << 25) |
        (BigInt(rs2 & 0x1f) << 20) |
        (BigInt(rs1 & 0x1f) << 15) |
        (BigInt(funct3 & 0x7) << 12) |
        (BigInt(rd & 0x1f) << 7) |
        BigInt(opcode & 0x7f)
    }

    private def encodeI(imm: Int, rs1: Int, funct3: Int, rd: Int, opcode: Int): BigInt = {
        val imm12 = mask(imm, 12)
        (imm12 << 20) |
        (BigInt(rs1 & 0x1f) << 15) |
        (BigInt(funct3 & 0x7) << 12) |
        (BigInt(rd & 0x1f) << 7) |
        BigInt(opcode & 0x7f)
    }

    private def encodeS(imm: Int, rs2: Int, rs1: Int, funct3: Int, opcode: Int): BigInt = {
        val imm12 = mask(imm, 12)
        val immHi = (imm12 >> 5) & 0x7f
        val immLo = imm12 & 0x1f
        (immHi << 25) |
        (BigInt(rs2 & 0x1f) << 20) |
        (BigInt(rs1 & 0x1f) << 15) |
        (BigInt(funct3 & 0x7) << 12) |
        (immLo << 7) |
        BigInt(opcode & 0x7f)
    }

    private def encodeB(offset: Int, rs2: Int, rs1: Int, funct3: Int, opcode: Int): BigInt = {
        require(offset % 2 == 0, s"B-type offset must be 2-byte aligned, got $offset")
        val imm13 = mask(offset, 13)
        val bit12 = (imm13 >> 12) & 0x1
        val bit11 = (imm13 >> 11) & 0x1
        val bits10To5 = (imm13 >> 5) & 0x3f
        val bits4To1 = (imm13 >> 1) & 0xf
        (bit12 << 31) |
        (bits10To5 << 25) |
        (BigInt(rs2 & 0x1f) << 20) |
        (BigInt(rs1 & 0x1f) << 15) |
        (BigInt(funct3 & 0x7) << 12) |
        (bits4To1 << 8) |
        (bit11 << 7) |
        BigInt(opcode & 0x7f)
    }

    private def encodeJ(offset: Int, rd: Int, opcode: Int): BigInt = {
        require(offset % 2 == 0, s"J-type offset must be 2-byte aligned, got $offset")
        val imm21 = mask(offset, 21)
        val bit20 = (imm21 >> 20) & 0x1
        val bits10To1 = (imm21 >> 1) & 0x3ff
        val bit11 = (imm21 >> 11) & 0x1
        val bits19To12 = (imm21 >> 12) & 0xff
        (bit20 << 31) |
        (bits19To12 << 12) |
        (bit11 << 20) |
        (bits10To1 << 21) |
        (BigInt(rd & 0x1f) << 7) |
        BigInt(opcode & 0x7f)
    }
}

trait TopFibProgramSupport {
    import TinyRv32Asm._

    val FibN = 10
    val ExpectedFib = 55
    val HaltPc = 56
    val FailPc = 52

    val Program: Seq[BigInt] = Seq(
        addi(rd = 1, rs1 = 0, imm = 0),
        addi(rd = 2, rs1 = 0, imm = 1),
        addi(rd = 3, rs1 = 0, imm = FibN),
        addi(rd = 4, rs1 = 0, imm = 0),
        beq(rs1 = 4, rs2 = 3, offset = 24),
        add(rd = 5, rs1 = 1, rs2 = 2),
        add(rd = 1, rs1 = 2, rs2 = 0),
        add(rd = 2, rs1 = 5, rs2 = 0),
        addi(rd = 4, rs1 = 4, imm = 1),
        beq(rs1 = 0, rs2 = 0, offset = -20),
        sw(rs2 = 1, rs1 = 0, imm = 0),
        lw(rd = 6, rs1 = 0, imm = 0),
        beq(rs1 = 6, rs2 = 1, offset = 8),
        beq(rs1 = 0, rs2 = 0, offset = 0),
        beq(rs1 = 6, rs2 = 1, offset = 0)
    )

    def loadProgram(dut: Top): Unit = {
        dut.io.instWriteEn.poke(false.B)
        dut.io.instWriteAddr.poke(0.U)
        dut.io.instWriteData.poke(0.U)
        dut.io.dataWriteEn.poke(false.B)
        dut.io.dataWriteAddr.poke(0.U)
        dut.io.dataWriteData.poke(0.U)

        for ((inst, index) <- Program.zipWithIndex.reverse) {
            dut.io.instWriteEn.poke(true.B)
            dut.io.instWriteAddr.poke((index * INST_BYTE_WIDTH).U)
            dut.io.instWriteData.poke(inst.U(INST_WIDTH.W))
            dut.clock.step()
        }

        dut.io.instWriteEn.poke(false.B)
        dut.io.instWriteAddr.poke(0.U)
        dut.io.instWriteData.poke(0.U)
        dut.reset.poke(true.B)
        dut.clock.step()
        dut.reset.poke(false.B)

        val fetchedAfterLoad = collection.mutable.ArrayBuffer.empty[BigInt]
        for (expectedPc <- 0 until (4 * INST_BYTE_WIDTH) by INST_BYTE_WIDTH) {
            fetchedAfterLoad += dut.io.inst.peek().litValue
            dut.clock.step()
        }
        assert(
            fetchedAfterLoad == Program.take(4),
            s"Program fetch after load mismatch: expected=${Program.take(4).map(v => s"0x${v.toString(16)}").mkString("[", ", ", "]")} got=${fetchedAfterLoad.map(v => s"0x${v.toString(16)}").mkString("[", ", ", "]")}"
        )

        dut.reset.poke(true.B)
        dut.clock.step()
        dut.reset.poke(false.B)
    }
}

class TopFibProgramTest extends AnyFlatSpec with ChiselScalatestTester with TopFibProgramSupport {
    "Top" should "run a fibonacci program end to end" in {
        test(new Top()) { dut =>
            loadProgram(dut)

            var reachedHalt = false
            var cycles = 0
            val maxCycles = 200
            val pcTrace = collection.mutable.ArrayBuffer.empty[BigInt]
            val instTrace = collection.mutable.ArrayBuffer.empty[BigInt]
            val branchCtrlTrace = collection.mutable.ArrayBuffer.empty[Boolean]
            val branchToPcTrace = collection.mutable.ArrayBuffer.empty[Boolean]
            val branchTakenTrace = collection.mutable.ArrayBuffer.empty[Boolean]
            val opTrace = collection.mutable.ArrayBuffer.empty[BigInt]
            val immTrace = collection.mutable.ArrayBuffer.empty[BigInt]

            while (!reachedHalt && cycles < maxCycles) {
                val pc = dut.io.addr.peek().litValue
                val inst = dut.io.inst.peek().litValue
                val branchTaken = dut.io.resultBranch.peek().litToBoolean
                val branchCtrl = dut.io.bundleCtrl.ctrlBranch.peek().litToBoolean
                val branchToPc = dut.io.ctrlBranchToPc.peek().litToBoolean
                val ctrlOp = dut.io.bundleCtrl.ctrlOP.peek().litValue
                val imm = dut.io.imm.peek().litValue
                if (pcTrace.length < 40) {
                    pcTrace += pc
                    instTrace += inst
                    branchCtrlTrace += branchCtrl
                    branchToPcTrace += branchToPc
                    branchTakenTrace += branchTaken
                    opTrace += ctrlOp
                    immTrace += imm
                }
                reachedHalt = pc == HaltPc && branchTaken
                if (!reachedHalt) {
                    dut.clock.step()
                    cycles += 1
                }
            }

            val finalPc = dut.io.addr.peek().litValue
            val finalInst = dut.io.inst.peek().litValue
            val finalRs1 = dut.io.rs1.peek().litValue
            val finalRs2 = dut.io.rs2.peek().litValue
            val finalResult = dut.io.result.peek().litValue
            val finalBranch = dut.io.resultBranch.peek().litToBoolean

            assert(
                reachedHalt,
                s"CPU did not reach halt within $maxCycles cycles: pc=$finalPc inst=0x${finalInst.toString(16)} rs1=$finalRs1 rs2=$finalRs2 result=$finalResult branch=$finalBranch pcTrace=${pcTrace.mkString("[", ", ", "]")} instTrace=${instTrace.map(v => s"0x${v.toString(16)}").mkString("[", ", ", "]")} branchCtrlTrace=${branchCtrlTrace.mkString("[", ", ", "]")} branchToPcTrace=${branchToPcTrace.mkString("[", ", ", "]")} branchTakenTrace=${branchTakenTrace.mkString("[", ", ", "]")} opTrace=${opTrace.map(v => s"0x${v.toString(16)}").mkString("[", ", ", "]")} immTrace=${immTrace.mkString("[", ", ", "]")}"
            )

            dut.io.addr.expect(HaltPc.U)
            dut.io.resultBranch.expect(true.B)
            dut.io.rs1.expect(ExpectedFib.U)
            dut.io.rs2.expect(ExpectedFib.U)
            dut.io.inst.expect(Program(HaltPc / INST_BYTE_WIDTH).U(INST_WIDTH.W))
            assert(dut.io.addr.peek().litValue != FailPc, "CPU should not fall into the failure loop")
        }
    }
}