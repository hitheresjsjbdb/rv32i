.text
.globl _start
_start:
# -8 >> 1 = -4
    addi x5, x0, -8
    addi x6, x0, 1
    sra x7, x5, x6
    addi x8, x0, -4
    bne x7, x8, fail

    # -1 >> 31 = -1
    addi x9, x0, -1
    addi x10, x0, 31
    sra x11, x9, x10
    bne x11, x9, fail

    # min >> 31 = -1
    addi x12, x0, 1
    sll x13, x12, x10
    sra x14, x13, x10
    bne x14, x9, fail

    # shamt mask: 32 -> 0
    addi x15, x0, 32
    sra x16, x13, x15
    bne x16, x13, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
