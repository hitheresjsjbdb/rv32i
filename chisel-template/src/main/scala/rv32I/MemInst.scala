package rv32I

import chisel3._
import chisel3.util._
import chisel3.util.experimental.loadMemoryFromFileInline

import config.Configs._
import firrtl.annotations.MemoryLoadFileType

class MemInstIO extends Bundle {
    val addr = Input(UInt(ADDR_WIDTH.W))    // CPU 当前取指地址（字节地址）
    val inst = Output(UInt(INST_WIDTH.W))   // CPU 取出的指令

    // 外部写入接口：用于测试、程序下载或仿真时动态灌入指令。
    // 这里也使用字节地址，模块内部会自动转成按字寻址。
    val extWriteEn = Input(Bool())
    val extWriteAddr = Input(UInt(ADDR_WIDTH.W))
    val extWriteData = Input(UInt(INST_WIDTH.W))
}

class MemInst(
    initFile: String = "",
    initFileType: MemoryLoadFileType = MemoryLoadFileType.Hex
) extends Module {
    val io = IO(new MemInstIO())    // 输入输出接口

    // 指令内存：每个存储单元是一条 32 位指令。
    // MEM_INST_SIZE 的单位是“字”，不是字节。
    val mem = Mem(MEM_INST_SIZE, UInt(INST_WIDTH.W))

    // 如果提供了初始化文件，就在 Verilog 中内联生成 $readmemh / $readmemb。
    // 这样综合和仿真都能直接使用外部程序文件。
    if (initFile.nonEmpty) {
        loadMemoryFromFileInline(mem, initFile, initFileType)
    }

    // CPU 和外部接口都使用字节地址，内部统一右移 2 位变成按字地址访问。
    val cpuWordAddr = io.addr >> INST_BYTE_WIDTH_LOG.U
    val extWordAddr = io.extWriteAddr >> INST_BYTE_WIDTH_LOG.U

    // 外部写口优先用于下载程序；CPU 读口始终从当前 PC 对应位置取指。
    when (io.extWriteEn) {
        mem.write(extWordAddr, io.extWriteData)
    }

    io.inst := mem.read(cpuWordAddr)
}