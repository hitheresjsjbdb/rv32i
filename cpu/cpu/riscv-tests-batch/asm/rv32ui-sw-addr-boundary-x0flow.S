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

addi x5, x0, 4
    addi x6, x0, 33
    sw x6, 0(x5)
    lw x7, 0(x5)
    bne x7, x6, fail

    addi x6, x0, -77
    sw x6, 0(x5)
    lw x7, 0(x5)
    bne x7, x6, fail

    addi x8, x0, 8
    addi x9, x0, 55
    sw x9, -4(x8)
    lw x10, 0(x5)
    bne x10, x9, fail

    addi x11, x0, 1023
    addi x12, x0, 2
    sll x11, x11, x12
    addi x13, x0, 88
    sw x13, 0(x11)
    lw x14, 0(x11)
    bne x14, x13, fail

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
