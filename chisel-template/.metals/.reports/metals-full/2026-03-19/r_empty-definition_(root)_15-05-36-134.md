error id: file://<WORKSPACE>/src/main/scala/rv32I/Mem.scala:
file://<WORKSPACE>/src/main/scala/rv32I/Mem.scala
empty definition using pc, found symbol in pc: 
empty definition using semanticdb
empty definition using fallback
non-local guesses:
	 -chisel3/BundleMemDataControl#
	 -chisel3/util/BundleMemDataControl#
	 -config/Configs.BundleMemDataControl#
	 -utils/OP_TYPES.BundleMemDataControl#
	 -utils/LS_TYPES.BundleMemDataControl#
	 -utils/BundleMemDataControl#
	 -BundleMemDataControl#
	 -scala/Predef.BundleMemDataControl#
offset: 211
uri: file://<WORKSPACE>/src/main/scala/rv32I/Mem.scala
text:
```scala
package rv32I

import chisel3._
import chisel3.util._

import config.Configs._
import utils.OP_TYPES._
import utils.LS_TYPES._
import utils._

class MemDataIO extends Bundle {
    val bundleMemDataControl = new @@BundleMemDataControl()
    val resultALU = Input(UInt(DATA_WIDTH.W))
    val dataStore = Input(UInt(DATA_WIDTH.W))
    val result = Output(UInt(DATA_WIDTH.W))
}

class MemData extends Module {
    val io = IO(new MemDataIO)

    // 数据内存
    val mem = Mem(MEM_DATA_SIZE, UInt(DATA_WIDTH.W))

    // 用于输出的结果
    val result = WireDefault(0.U(DATA_WIDTH.W))

    // 从内存中读取的数
    val dataLoad = WireDefault(0.U(DATA_WIDTH.W))

    // 不论是STORE还是LOAD，都需要用到这个读数
    dataLoad := mem.read(io.resultALU >> DATA_BYTE_WIDTH_LOG.U)

    // STORE指令
    when(io.bundleMemDataControl.ctrlStore) {
        when(io.bundleMemDataControl.ctrlLSType === LS_W) { // 修改全部4字节
            mem.write(io.resultALU >> DATA_BYTE_WIDTH_LOG.U, io.dataStore)
        }.elsewhen(io.bundleMemDataControl.ctrlLSType === LS_H) {   // 修改低2字节
            mem.write(io.resultALU >> DATA_BYTE_WIDTH_LOG.U, Cat(dataLoad(31, 16), io.dataStore(15, 0)))
        }.otherwise {   // 修改最低一个字节
            mem.write(io.resultALU >> DATA_BYTE_WIDTH_LOG.U, Cat(dataLoad(31, 8), io.dataStore(7, 0)))
        }
    }
    // LOAD指令
    when (io.bundleMemDataControl.ctrlLoad) {
        when(io.bundleMemDataControl.ctrlLSType === LS_W) {
            result := dataLoad
        }.elsewhen(io.bundleMemDataControl.ctrlLSType === LS_H) {
            when (io.bundleMemDataControl.ctrlSigned) {
                result := Cat(Fill(16, dataLoad(15)), dataLoad(15, 0))
            } .otherwise {
                result := Cat(Fill(16, 0.U), dataLoad(15, 0))
            }
        }.otherwise {
            when (io.bundleMemDataControl.ctrlSigned) {
                result := Cat(Fill(24, dataLoad(7)), dataLoad(7, 0))
            } .otherwise {
                result := Cat(Fill(24, 0.U), dataLoad(7, 0))
            }
        } 
    // 非LOAD指令
    } .otherwise {
        result := io.resultALU
    }
    
    // 输出
    io.result := result
}
```


#### Short summary: 

empty definition using pc, found symbol in pc: 