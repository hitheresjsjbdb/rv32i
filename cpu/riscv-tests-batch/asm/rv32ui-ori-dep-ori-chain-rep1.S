.text
.globl _start
_start:
addi x5, x0, 0
    ori x5, x5, 1
    ori x5, x5, 2
    ori x5, x5, 4
    ori x5, x5, 8
    addi x6, x0, 15
    bne x5, x6, fail

    ori x7, x0, 0
    bne x7, x0, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
