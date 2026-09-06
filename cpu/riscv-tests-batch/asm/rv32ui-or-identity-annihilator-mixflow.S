.text
.globl _start
_start:
addi x31, x0, 96
    addi x30, x0, 21
    sw x30, 0(x31)
    lw x29, 0(x31)
    bne x29, x30, fail

addi x5, x0, 85
    addi x6, x0, -1
    or x7, x5, x6
    bne x7, x6, fail

    or x8, x5, x0
    bne x8, x5, fail

    addi x9, x0, 1
    srl x10, x6, x9         # max
    addi x11, x0, 31
    sll x12, x9, x11        # min
    or x13, x10, x12
    bne x13, x6, fail

jal x1, wrapb_func_1
wrapb_ret_1:
    addi x25, x0, 28
    bne x29, x25, fail
    jal x0, wrapb_after_1

wrapb_func_1:
    addi x29, x29, 7
    add x24, x1, x0
    jalr x0, 0(x24)

wrapb_after_1:
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
