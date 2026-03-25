package utils

import chisel3._

import config.Configs._
import utils.OP_TYPES._

// 用于连接控制模块的 Bundle（14 指令简化版）
class BundleControl extends Bundle {
    val ctrlJump = Output(Bool())       // jal / jalr
    val ctrlJAL = Output(Bool())        // 1: jal, 0: jalr（当 ctrlJump=1 时）
    val ctrlBranch = Output(Bool())     // beq / bne

    val ctrlRegWrite = Output(Bool())   // 是否写寄存器
    val ctrlLoad = Output(Bool())       // lw
    val ctrlStore = Output(Bool())      // sw
    val ctrlALUSrc = Output(Bool())     // ALU 第二操作数是否来自立即数

    val ctrlOP = Output(UInt(OP_TYPES_WIDTH.W)) // ALU 操作类型
}

// 用于连接寄存器模块的 Bundle
class BundleReg extends Bundle {
    val rs1 = Output(UInt(REG_NUMS_LOG.W))
    val rs2 = Output(UInt(REG_NUMS_LOG.W))
    val rd  = Output(UInt(REG_NUMS_LOG.W))
}

class BundleAluControl extends Bundle {
    val ctrlALUSrc = Input(Bool())
    val ctrlJump = Input(Bool())
    val ctrlJAL = Input(Bool())
    val ctrlOP = Input(UInt(OP_TYPES_WIDTH.W))
    val ctrlBranch = Input(Bool())
}

class BundleMemDataControl extends Bundle {
    val ctrlLoad = Input(Bool())
    val ctrlStore = Input(Bool())
}