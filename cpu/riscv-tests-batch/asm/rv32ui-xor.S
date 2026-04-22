.text
.globl _start
_start:
# x ^ x = 0
    addi x5, x0, 85
    addi x6, x0, 85
    xor x7, x5, x6
    bne x7, x0, fail

    # x ^ 0 = x
    xor x8, x5, x0
    bne x8, x5, fail

    # max ^ min = -1
    addi x9, x0, 1
    addi x10, x0, -1
    srl x11, x10, x9        # max
    addi x12, x0, 31
    sll x13, x9, x12        # min
    xor x14, x11, x13
    bne x14, x10, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
