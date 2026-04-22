.text
.globl _start
_start:
addi x31, x0, 0
    addi x30, x0, 7
    add x0, x30, x30
    ori x0, x30, 3
    bne x0, x31, fail

    addi x29, x0, 3
wrapa_pre_loop:
    addi x31, x31, 1
    addi x29, x29, -1
    bne x29, x0, wrapa_pre_loop
    addi x28, x0, 3
    bne x31, x28, fail

addi x5, x0, 85
    addi x6, x0, -1
    and x7, x5, x6
    bne x7, x5, fail

    and x8, x5, x0
    bne x8, x0, fail

    addi x9, x0, 1
    addi x10, x0, 31
    sll x11, x9, x10        # min
    srl x12, x6, x9         # max
    and x13, x11, x12
    bne x13, x0, fail

addi x27, x0, 2
wrapa_post_loop:
    addi x31, x31, -1
    addi x27, x27, -1
    bne x27, x0, wrapa_post_loop
    addi x26, x0, 1
    bne x31, x26, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
