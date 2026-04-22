.text
.globl _start
_start:
addi x5, x0, 2047
    addi x5, x5, -2048
    addi x6, x0, -1
    bne x5, x6, fail

    addi x7, x6, 1
    bne x7, x0, fail

    addi x8, x0, 1
    addi x9, x0, 31
    sll x10, x8, x9         # min
    addi x11, x10, -1       # max
    srl x12, x6, x8
    bne x11, x12, fail

    addi x13, x12, 1        # max+1=min
    bne x13, x10, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
