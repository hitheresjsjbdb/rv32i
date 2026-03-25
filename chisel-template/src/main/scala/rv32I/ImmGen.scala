package rv32I

import chisel3._
import config.Configs._
import utils.IMM_TYPES._
import chisel3.util._
import utils._
import utils.IMM_TYPES

class ImmGenIO extends Bundle {
    val inst = Input(UInt(INST_WIDTH.W))
    val immSel = Input(UInt(IMM_SEL_WIDTH.W))
    val imm = Output(UInt(DATA_WIDTH.W))
}

class ImmGen extends Module {
    val io = IO(new ImmGenIO())

    // --------------------------------------------------
    // 各类立即数并行生成
    // --------------------------------------------------

    // I-type: inst[31:20]
    val imm_i = Cat(
        Fill(20, io.inst(31)),
        io.inst(31, 20)
    )

    // S-type: inst[31:25] ++ inst[11:7]
    val imm_s = Cat(
        Fill(20, io.inst(31)),
        io.inst(31, 25),
        io.inst(11, 7)
    )

    // B-type:
    // imm[12|10:5|4:1|11|0]
    val imm_b = Cat(
        Fill(19, io.inst(31)),
        io.inst(31),
        io.inst(7),
        io.inst(30, 25),
        io.inst(11, 8),
        0.U(1.W)
    )

    // J-type:
    // imm[20|10:1|11|19:12|0]
    val imm_j = Cat(
        Fill(11, io.inst(31)),
        io.inst(31),
        io.inst(19, 12),
        io.inst(20),
        io.inst(30, 21),
        0.U(1.W)
    )

    // --------------------------------------------------
    // 根据 immSel 选择最终输出
    // --------------------------------------------------
    val imm = WireDefault(0.U(DATA_WIDTH.W))

    switch(io.immSel) {
        is(IMM_I) {
            imm := imm_i
        }
        is(IMM_S) {
            imm := imm_s
        }
        is(IMM_B) {
            imm := imm_b
        }
        is(IMM_J) {
            imm := imm_j
        }
    }

    io.imm := imm
}