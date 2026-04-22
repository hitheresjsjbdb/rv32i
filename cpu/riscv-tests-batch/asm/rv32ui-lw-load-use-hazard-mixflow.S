.text
.globl _start
_start:
addi x31, x0, 96
    addi x30, x0, 21
    sw x30, 0(x31)
    lw x29, 0(x31)
    bne x29, x30, fail

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

jal x1, wrapb_func
wrapb_ret:
    addi x25, x0, 28
    bne x29, x25, fail
    jal x0, wrapb_after

wrapb_func:
    addi x29, x29, 7
    add x24, x1, x0
    jalr x0, 0(x24)

wrapb_after:
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
