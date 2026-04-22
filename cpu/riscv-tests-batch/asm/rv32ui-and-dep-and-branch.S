.text
.globl _start
_start:
addi x5, x0, -1
    addi x6, x0, 15
    addi x7, x0, 0
    addi x8, x0, 4
and_loop:
    and x7, x5, x6
    addi x6, x6, -1
    addi x8, x8, -1
    bne x8, x0, and_loop
    addi x9, x0, 12
    bne x7, x9, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
