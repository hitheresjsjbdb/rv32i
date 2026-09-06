.text
.globl _start
_start:
addi x31, x0, 96
    addi x30, x0, 21
    sw x30, 0(x31)
    lw x29, 0(x31)
    bne x29, x30, fail

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

addi x5, x0, 0
    addi x6, x0, 77
    sw x6, 0(x5)
    lw x7, 0(x5)
    bne x7, x6, fail

    addi x6, x0, -33
    sw x6, 4(x5)
    lw x7, 4(x5)
    bne x7, x6, fail

    addi x8, x0, 4
    lw x9, -4(x8)
    addi x10, x0, 77
    bne x9, x10, fail

    addi x11, x0, 1023
    addi x12, x0, 2
    sll x11, x11, x12       # 4092
    addi x13, x0, 99
    sw x13, 0(x11)
    lw x14, 0(x11)
    bne x14, x13, fail

addi x27, x0, 2
wrapa_post_loop_1:
    addi x31, x31, -1
    addi x27, x27, -1
    bne x27, x0, wrapa_post_loop_1
    addi x26, x0, 1
    bne x31, x26, fail

jal x1, wrapb_func_2
wrapb_ret_2:
    addi x25, x0, 28
    bne x29, x25, fail
    jal x0, wrapb_after_2

wrapb_func_2:
    addi x29, x29, 7
    add x24, x1, x0
    jalr x0, 0(x24)

wrapb_after_2:
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
