.text
.globl _start
_start:
addi x31, x0, 96
    addi x30, x0, 21
    sw x30, 0(x31)
    lw x29, 0(x31)
    bne x29, x30, fail

addi x5, x0, 0
    ori x5, x5, 1
    ori x5, x5, 2
    ori x5, x5, 4
    ori x5, x5, 8
    addi x6, x0, 15
    bne x5, x6, fail

    ori x7, x0, 0
    bne x7, x0, fail

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
