.text
.globl _start
_start:
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
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
