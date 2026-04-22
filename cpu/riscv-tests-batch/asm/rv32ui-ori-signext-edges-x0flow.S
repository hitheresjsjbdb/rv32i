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

addi x5, x0, 0
    ori x6, x5, -2048
    addi x7, x0, -2048
    bne x6, x7, fail

    ori x8, x5, -1
    addi x9, x0, -1
    bne x8, x9, fail

    addi x10, x0, 1
    sll x11, x10, x10
    ori x12, x11, 2047
    addi x13, x0, 2047
    bne x12, x13, fail

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
