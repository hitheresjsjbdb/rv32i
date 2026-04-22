.text
.globl _start
_start:
# x | -1 = -1
    addi x5, x0, 85
    addi x6, x0, -1
    or x7, x5, x6
    bne x7, x6, fail

    # x | 0 = x
    or x8, x5, x0
    bne x8, x5, fail

    # min | max = -1
    addi x9, x0, 1
    addi x10, x0, 31
    sll x11, x9, x10        # min
    addi x12, x0, -1
    srl x13, x12, x9        # max
    or x14, x11, x13
    bne x14, x12, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
