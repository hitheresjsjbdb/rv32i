package rv32I

import chisel3._
import chisel3.util._
import chisel3.util.experimental.loadMemoryFromFileInline

import config.Configs._
import utils.OP_TYPES._
import utils._
import firrtl.annotations.MemoryLoadFileType

class MemDataIO extends Bundle {
    val bundleMemDataControl = new BundleMemDataControl()
    val resultALU = Input(UInt(DATA_WIDTH.W))
    val dataStore = Input(UInt(DATA_WIDTH.W))
    val result = Output(UInt(DATA_WIDTH.W))

    // 外部写入接口：用于测试、数据预装载或仿真阶段修改 RAM 内容。
    // 同样使用字节地址，内部统一转成按字寻址。
    val extWriteEn = Input(Bool())
    val extWriteAddr = Input(UInt(ADDR_WIDTH.W))
    val extWriteData = Input(UInt(DATA_WIDTH.W))
}

class MemData(
    initFile: String = "",
    initFileType: MemoryLoadFileType = MemoryLoadFileType.Hex
) extends Module {
    val io = IO(new MemDataIO)

    // 数据内存：当前仅支持 32 位整字读写，对应 lw / sw。
    val mem = Mem(MEM_DATA_SIZE, UInt(DATA_WIDTH.W))

    // 如果提供初始化文件，就在生成的 Verilog 中插入对应的内存加载语句。
    if (initFile.nonEmpty) {
        loadMemoryFromFileInline(mem, initFile, initFileType)
    }

    // CPU 访问地址和外部访问地址都以字节为单位传入，
    // 内部统一右移 2 位后映射到按字组织的存储体。
    val cpuWordAddr = io.resultALU >> DATA_BYTE_WIDTH_LOG.U
    val extWordAddr = io.extWriteAddr >> DATA_BYTE_WIDTH_LOG.U

    // 用于输出的结果：
    // 1. load 时输出从内存读出的数据；
    // 2. 非 load 时透传 ALU 结果，供上游继续使用。
    val result = WireDefault(0.U(DATA_WIDTH.W))

    // 从内存中读取的数。当前设计中 load 为组合读。
    val dataLoad = WireDefault(0.U(DATA_WIDTH.W))

    // 不论是 STORE 还是 LOAD，CPU 访问时都基于 ALU 给出的地址工作。
    dataLoad := mem.read(cpuWordAddr)

    // 外部写口优先级最高，便于测试或程序启动前预装载 RAM。
    when (io.extWriteEn) {
        mem.write(extWordAddr, io.extWriteData)
    } .elsewhen(io.bundleMemDataControl.ctrlStore) {
        // CPU 的 sw 指令只在没有外部写入请求时才真正写 RAM，
        // 这样可以保证测试/下载接口对内存内容拥有更高优先级。
        mem.write(cpuWordAddr, io.dataStore)
    }

    // CPU 的 lw 指令从内存中取数据。
    when (io.bundleMemDataControl.ctrlLoad) {
        result := dataLoad 
    // 非 load 指令时，直接把 ALU 结果向后传。
    } .otherwise {
        result := io.resultALU
    }
    
    // 输出
    io.result := result
}