package utils

import chisel3._

object OP_TYPES {
    val OP_TYPES_WIDTH = 4
    val OP_NOP = "b0000".U(OP_TYPES_WIDTH.W)
    val OP_ADD = "b0001".U(OP_TYPES_WIDTH.W)
    val OP_SUB = "b0010".U(OP_TYPES_WIDTH.W)
    val OP_AND = "b0100".U(OP_TYPES_WIDTH.W)
    val OP_OR = "b0101".U(OP_TYPES_WIDTH.W)
    val OP_XOR = "b0111".U(OP_TYPES_WIDTH.W)
    val OP_SLL = "b1000".U(OP_TYPES_WIDTH.W)
    val OP_SRL = "b1001".U(OP_TYPES_WIDTH.W)
    val OP_SRA = "b1011".U(OP_TYPES_WIDTH.W)
    val OP_EQ = "b1100".U(OP_TYPES_WIDTH.W)
    val OP_NEQ = "b1101".U(OP_TYPES_WIDTH.W)
    val OP_LT = "b1110".U(OP_TYPES_WIDTH.W)
    val OP_GE = "b1111".U(OP_TYPES_WIDTH.W)
}

