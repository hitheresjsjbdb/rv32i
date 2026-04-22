.text
.globl _start
_start:
addi x5, x0, 256
    addi x6, x0, 8
    srl x7, x5, x6
    addi x8, x0, 1
    bne x7, x8, fail

    addi x9, x0, 3
srl_loop:
    srl x5, x5, x8
    addi x9, x9, -1
    bne x9, x0, srl_loop
    addi x10, x0, 32
    bne x5, x10, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
