.text
.globl _start
_start:
addi x5, x0, -8
    addi x6, x0, 1
    sra x7, x5, x6
    addi x8, x0, -4
    bne x7, x8, fail

    addi x9, x0, -1
    addi x10, x0, 31
    sra x11, x9, x10
    bne x11, x9, fail

    addi x12, x0, 32
    sra x13, x5, x12
    bne x13, x5, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
