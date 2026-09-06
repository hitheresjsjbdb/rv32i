.text
.globl _start
_start:
addi x31, x0, 0
    addi x30, x0, 7
    add x0, x30, x30
    ori x0, x30, 3
    bne x0, x31, fail

    addi x29, x0, 3
wrapa_pre_loop_2:
    addi x31, x31, 1
    addi x29, x29, -1
    bne x29, x0, wrapa_pre_loop_2
    addi x28, x0, 3
    bne x31, x28, fail

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

addi x5, x0, -1
    addi x6, x0, 1
    add x7, x5, x6
    bne x7, x0, fail

    srl x8, x5, x6          # max
    addi x9, x0, 31
    sll x10, x6, x9         # min
    add x11, x8, x6         # max+1=min
    bne x11, x10, fail

    add x12, x10, x8        # min+max=-1
    bne x12, x5, fail

    add x13, x12, x6        # -1+1=0
    bne x13, x0, fail

addi x27, x0, 2
wrapa_post_loop_1:
    addi x31, x31, -1
    addi x27, x27, -1
    bne x27, x0, wrapa_post_loop_1
    addi x26, x0, 1
    bne x31, x26, fail

addi x27, x0, 2
wrapa_post_loop_2:
    addi x31, x31, -1
    addi x27, x27, -1
    bne x27, x0, wrapa_post_loop_2
    addi x26, x0, 1
    bne x31, x26, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
