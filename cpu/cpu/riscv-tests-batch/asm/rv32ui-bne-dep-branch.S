.text
.globl _start
_start:
addi x5, x0, 0
    addi x6, x0, 4
bne_dep_loop:
    addi x5, x5, 1
    bne x5, x6, bne_dep_loop
    addi x7, x0, 4
    bne x5, x7, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
