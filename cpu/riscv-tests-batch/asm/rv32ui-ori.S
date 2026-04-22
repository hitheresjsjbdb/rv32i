.text
.globl _start
_start:
# 0 | -2048
    addi x5, x0, 0
    ori x6, x5, -2048
    addi x7, x0, -2048
    bne x6, x7, fail

    # 0 | -1 = -1
    ori x8, x5, -1
    addi x9, x0, -1
    bne x8, x9, fail

    # max | 1 = max
    addi x10, x0, 1
    srl x11, x9, x10        # max
    ori x12, x11, 1
    bne x12, x11, fail

    # min | 2047 = 0x800007ff
    addi x13, x0, 31
    sll x14, x10, x13       # min
    ori x15, x14, 2047
    addi x16, x14, 2047
    bne x15, x16, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
