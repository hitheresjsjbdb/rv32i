.text
.globl _start
_start:
addi x5, x0, 3
    addi x6, x0, 2
    sll x5, x5, x6          # 12
    sll x5, x5, x6          # 48
    addi x7, x0, 48
    bne x5, x7, fail

    addi x8, x0, 4
    sll x9, x8, x8          # 64
    addi x10, x0, 64
    bne x9, x10, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
