.text
.globl _start
_start:
# zero + zero
    addi x5, x0, 0
    addi x6, x0, 0
    add x7, x5, x6
    bne x7, x0, fail

    # -1 + 1 = 0
    addi x5, x0, -1
    addi x6, x0, 1
    add x7, x5, x6
    bne x7, x0, fail

    # max + 1 = min
    srl x8, x5, x6          # max = 0x7fffffff
    addi x9, x0, 31
    sll x10, x6, x9         # min = 0x80000000
    add x11, x8, x6
    bne x11, x10, fail

    # max + min = -1
    add x12, x8, x10
    bne x12, x5, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
