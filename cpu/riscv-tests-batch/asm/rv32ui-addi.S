.text
.globl _start
_start:
# basic wrap
    addi x5, x0, -1
    addi x5, x5, 1
    bne x5, x0, fail

    # i12 edges: +2047 and -2048
    addi x6, x0, 2047
    addi x6, x6, -2048
    addi x7, x0, -1
    bne x6, x7, fail

    # min + (-1) => 0x7fffffff
    addi x8, x0, 1
    addi x9, x0, 31
    sll x10, x8, x9         # min
    addi x11, x10, -1       # max
    addi x12, x0, -1
    srl x13, x12, x8        # max (reference)
    bne x11, x13, fail

    # max + 1 => min
    addi x14, x13, 1
    bne x14, x10, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
