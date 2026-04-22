.text
.globl _start
_start:
# -1 >> 0 = -1
    addi x5, x0, -1
    addi x6, x0, 0
    srl x7, x5, x6
    bne x7, x5, fail

    # -1 >> 31 = 1
    addi x6, x0, 31
    srl x8, x5, x6
    addi x9, x0, 1
    bne x8, x9, fail

    # 0x80000000 >> 31 = 1
    sll x10, x9, x6
    srl x11, x10, x6
    bne x11, x9, fail

    # shamt mask: 32 -> 0
    addi x12, x0, 32
    srl x13, x5, x12
    bne x13, x5, fail

    # 256 >> 8 = 1
    addi x5, x0, 256
    addi x6, x0, 8
    srl x7, x5, x6
    addi x8, x0, 1
    bne x7, x8, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
