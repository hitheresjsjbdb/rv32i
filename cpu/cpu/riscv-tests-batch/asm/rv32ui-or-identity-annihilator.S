.text
.globl _start
_start:
addi x5, x0, 85
    addi x6, x0, -1
    or x7, x5, x6
    bne x7, x6, fail

    or x8, x5, x0
    bne x8, x5, fail

    addi x9, x0, 1
    srl x10, x6, x9         # max
    addi x11, x0, 31
    sll x12, x9, x11        # min
    or x13, x10, x12
    bne x13, x6, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
