.text
.globl _start
_start:
# 0 - 0 = 0
    sub x5, x0, x0
    bne x5, x0, fail

    # 0 - 1 = -1
    addi x6, x0, 1
    sub x7, x0, x6
    addi x8, x0, -1
    bne x7, x8, fail

    # min - 1 = max
    addi x9, x0, 31
    sll x10, x6, x9         # min
    sub x11, x10, x6
    srl x12, x8, x6         # max
    bne x11, x12, fail

    # max - (-1) = min
    sub x13, x12, x8
    bne x13, x10, fail

    # normal case
    addi x5, x0, 12
    addi x6, x0, 5
    sub x14, x5, x6
    addi x15, x0, 7
    bne x14, x15, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
