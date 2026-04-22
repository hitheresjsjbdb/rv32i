.text
.globl _start
_start:
addi x5, x0, 0
    ori x6, x5, -2048
    addi x7, x0, -2048
    bne x6, x7, fail

    ori x8, x5, -1
    addi x9, x0, -1
    bne x8, x9, fail

    addi x10, x0, 1
    sll x11, x10, x10
    ori x12, x11, 2047
    addi x13, x0, 2047
    bne x12, x13, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
