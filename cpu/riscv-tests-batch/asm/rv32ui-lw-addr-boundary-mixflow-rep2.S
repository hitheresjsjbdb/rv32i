.text
.globl _start
_start:
addi x31, x0, 96
    addi x30, x0, 21
    sw x30, 0(x31)
    lw x29, 0(x31)
    bne x29, x30, fail

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
