.text
.globl _start
_start:
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
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
