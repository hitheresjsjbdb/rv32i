.text
.globl _start
_start:
addi x5, x0, -1
    addi x6, x0, 31
    srl x7, x5, x6
    addi x8, x0, 1
    bne x7, x8, fail

    sll x9, x8, x6          # min
    srl x10, x9, x6
    bne x10, x8, fail

    addi x11, x0, 32
    srl x12, x5, x11
    bne x12, x5, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
