.text
.globl _start
_start:
    addi x1,  x0, 1
    addi x2,  x0, 2
    addi x3,  x0, 4
    addi x4,  x0, 8
    addi x5,  x0, 16
    addi x6,  x0, 32
    addi x7,  x0, 64
    addi x8,  x0, 127
    addi x9,  x0, -1
    addi x10, x0, 85
    addi x11, x0, 170

    add  x12, x7,  x5
    sub  x13, x12, x2
    or   x14, x13, x3
    and  x15, x14, x11
    xor  x16, x15, x9

    addi x17, x0, 6
    sll  x18, x1,  x17
    srl  x19, x16, x2
    sra  x20, x9,  x1
    ori  x21, x5,  64

    addi x22, x0, 31
    sll  x23, x1,  x22
    add  x24, x23, x9
    addi x25, x0, -2048
    addi x26, x0, 123

    sw   x26, 0(x0)
    lw   x27, 0(x0)
    jal  x28, after_jal
    .word 0x00000017

after_jal:
    add  x29, x28, x7
    bne  x18, x7,  fail
    bne  x27, x26, fail
    xor  x30, x29, x21
    addi x31, x0, -85
    ebreak

fail:
    .word 0x00000017
