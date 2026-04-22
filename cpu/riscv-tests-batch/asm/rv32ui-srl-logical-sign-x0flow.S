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

addi x5, x0, -1
    addi x6, x0, 31
    srl x7, x5, x6
    addi x8, x0, 1
    bne x7, x8, fail

    sll x9, x8, x6          # min
    srl x10, x9, x6
    bne x10, x8, fail

    addi x11, x0, 32
    srl x12, x5, x11
    bne x12, x5, fail

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
