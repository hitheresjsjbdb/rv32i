.text
.globl _start
_start:
addi x5, x0, 0
    addi x5, x5, 1
    addi x5, x5, 2
    addi x5, x5, 3
    addi x5, x5, 4
    addi x6, x0, 10
    bne x5, x6, fail

    addi x7, x0, -5
    addi x7, x7, 1
    addi x7, x7, 1
    addi x7, x7, 1
    addi x7, x7, 1
    addi x7, x7, 1
    bne x7, x0, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
