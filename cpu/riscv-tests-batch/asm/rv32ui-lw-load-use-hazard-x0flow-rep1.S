.text
.globl _start
_start:
addi x31, x0, 0
    addi x30, x0, 7
    add x0, x30, x30
    ori x0, x30, 3
    bne x0, x31, fail

    addi x29, x0, 3
wrapa_pre_loop_1:
    addi x31, x31, 1
    addi x29, x29, -1
    bne x29, x0, wrapa_pre_loop_1
    addi x28, x0, 3
    bne x31, x28, fail

addi x5, x0, 16
    addi x6, x0, 12
    sw x6, 0(x5)
    lw x7, 0(x5)
    add x8, x7, x6
    addi x9, x0, 24
    bne x8, x9, fail

    lw x10, 0(x5)
    sub x11, x10, x6
    bne x11, x0, fail

addi x27, x0, 2
wrapa_post_loop_1:
    addi x31, x31, -1
    addi x27, x27, -1
    bne x27, x0, wrapa_post_loop_1
    addi x26, x0, 1
    bne x31, x26, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
