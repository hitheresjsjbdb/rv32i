.text
.globl _start
_start:
addi x31, x0, 96
    addi x30, x0, 21
    sw x30, 0(x31)
    lw x29, 0(x31)
    bne x29, x30, fail

sub x5, x0, x0
    bne x5, x0, fail

    addi x6, x0, 1
    sub x7, x0, x6
    addi x8, x0, -1
    bne x7, x8, fail

    addi x9, x0, 31
    sll x10, x6, x9         # min
    sub x11, x10, x6        # max
    srl x12, x8, x6
    bne x11, x12, fail

    sub x13, x12, x8        # min
    bne x13, x10, fail

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
