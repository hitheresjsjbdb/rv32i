package rv32I

import chisel3._
import chisel3.util._

import config.Configs._
import utils.OP_TYPES._
import utils._

class AluIO extends Bundle {
    val bundleAluControl = new BundleAluControl()
    val dataRead1 = Input(UInt(DATA_WIDTH.W))
    val dataRead2 = Input(UInt(DATA_WIDTH.W))
    val imm = Input(UInt(DATA_WIDTH.W))
    val pc = Input(UInt(ADDR_WIDTH.W))
    val resultBranch = Output(Bool())
    val resultAlu = Output(UInt(DATA_WIDTH.W))
    
}

class Alu extends Module {
    val io = IO(new AluIO())

    val resultBranch = WireDefault(false.B)
    val resultAlu = WireDefault(0.U(DATA_WIDTH.W))

    val operand1 = Wire(UInt(DATA_WIDTH.W))
    val operand2 = Wire(UInt(DATA_WIDTH.W))
    val addResult = Wire(UInt(DATA_WIDTH.W))

    operand1 := Mux(io.bundleAluControl.ctrlJAL, io.pc, io.dataRead1)
    operand2 := Mux(io.bundleAluControl.ctrlALUSrc, io.imm, io.dataRead2)
    addResult := operand1 + operand2

    switch(io.bundleAluControl.ctrlOP) {
        is(OP_NOP) {
            resultAlu := 0.U
            resultBranch := false.B
        }

        is(OP_ADD) {
            // jalr target must clear bit 0; jal/addi/lw/sw keep the full add result.
            resultAlu := Mux(
                io.bundleAluControl.ctrlJump && !io.bundleAluControl.ctrlJAL,
                addResult & (~1.U(DATA_WIDTH.W)),
                addResult
            )
        }

        is(OP_SUB) {
            resultAlu := operand1 - operand2
        }

        is(OP_AND) {
            resultAlu := operand1 & operand2
        }

        is(OP_OR) {
            resultAlu := operand1 | operand2
        }

        is(OP_SLL) {
            resultAlu := operand1 << operand2(4, 0)
        }

        is(OP_SRL) {
            resultAlu := operand1 >> operand2(4, 0)
        }

        is(OP_SRA) {
            resultAlu := (operand1.asSInt >> operand2(4, 0)).asUInt
        }

        is(OP_EQ) {
            resultBranch := operand1 === operand2
            resultAlu := io.pc + io.imm
        }

        is(OP_NEQ) {
            resultBranch := operand1 =/= operand2
            resultAlu := io.pc + io.imm
        }
    }

    io.resultAlu := resultAlu
    io.resultBranch := resultBranch
}