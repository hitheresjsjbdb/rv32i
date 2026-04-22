.text
.globl _start
_start:
addi x5, x0, 123
    xor x6, x5, x5
    bne x6, x0, fail

    addi x7, x0, -1
    xor x8, x5, x7
    xor x9, x8, x7
    bne x9, x5, fail

    addi x10, x0, 1
    srl x11, x7, x10
    addi x12, x0, 31
    sll x13, x10, x12
    xor x14, x11, x13
    bne x14, x7, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
