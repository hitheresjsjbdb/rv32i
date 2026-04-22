.text
.globl _start
_start:
addi x5, x0, 19
    addi x6, x0, 7

    add x7, x5, x6
    sub x8, x7, x6
    bne x8, x5, fail

    xor x9, x5, x6
    xor x10, x9, x6
    bne x10, x5, fail

    addi x11, x0, 1
    sll x12, x5, x11
    srl x13, x12, x11
    bne x13, x5, fail

    addi x14, x0, -1
    and x15, x5, x14
    bne x15, x5, fail

    ori x16, x0, -1
    xor x17, x16, x5
    xor x18, x17, x5
    bne x18, x16, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
