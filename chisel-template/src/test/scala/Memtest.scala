import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

import config.Configs._
import rv32I.MemData

trait MemDataTestFunc {
    // 生成MEM_DATA_SIZE条随机数据进行测试
    val data_list =
        Seq.fill(MEM_DATA_SIZE)(
            BigInt(scala.util.Random.nextLong() & 0xffffffffL)
        )

    def testFn(dut: MemData): Unit = {
        // 初始化状态
        dut.clock.setTimeout(0)
        dut.io.bundleMemDataControl.ctrlLoad.poke(false.B)
        dut.io.bundleMemDataControl.ctrlStore.poke(false.B)
        dut.io.dataStore.poke(0.U(DATA_WIDTH.W))
        dut.io.resultALU.poke(0.U(DATA_WIDTH.W))
        // 非LS指令
        for (i <- 0 to MEM_DATA_SIZE - 1) {
            dut.io.resultALU.poke((i * DATA_BYTE_WIDTH).U)
            dut.clock.step(1)
            dut.io.result.expect((i * DATA_BYTE_WIDTH).U)
        }
        // SW指令
        dut.io.bundleMemDataControl.ctrlStore.poke(true.B)
        for (i <- 0 to MEM_DATA_SIZE - 1) {
            dut.io.dataStore.poke(data_list(i).U)
            dut.io.resultALU.poke((i * DATA_BYTE_WIDTH).U) // 作为地址，应该左移两位，即乘以4
            dut.io.result.expect((i * DATA_BYTE_WIDTH).U)
            dut.clock.step(1)
        }
        // LW指令
        dut.io.bundleMemDataControl.ctrlStore.poke(false.B)
        dut.io.bundleMemDataControl.ctrlLoad.poke(true.B)
        for (i <- 0 to MEM_DATA_SIZE - 1) {
            dut.io.dataStore.poke(0.U)
            dut.io.resultALU.poke((i * DATA_BYTE_WIDTH).U) // 作为地址，应该左移两位，即乘以4
            dut.io.result.expect(data_list(i).U)
        }
    }
}

class MemDataTest
    extends AnyFlatSpec
    with ChiselScalatestTester
    with MemDataTestFunc {
    "MemData" should "pass" in {
        test(new MemData) { dut =>
            testFn(dut)
        }
    }
}