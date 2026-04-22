.text
.globl _start
_start:
addi x20, x0, 256
    addi x5, x0, 73
    sw x5, 0(x20)

    addi x21, x20, 4
    lw x6, -4(x21)
    bne x6, x5, fail

    addi x7, x0, -99
    sw x7, 12(x20)
    addi x22, x20, 8
    lw x8, 4(x22)
    bne x8, x7, fail

    addi x23, x0, 2044
    addi x9, x0, 55
    sw x9, 0(x23)
    addi x24, x23, 4
    lw x10, -4(x24)
    bne x10, x9, fail

    addi x11, x0, -33
    sw x11, -4(x24)
    lw x12, 0(x23)
    bne x12, x11, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
