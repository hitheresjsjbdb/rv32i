.text
.globl _start
_start:
addi x5, x0, 0
    jal x1, block_a
    addi x6, x0, 3
    bne x5, x6, fail
    jal x0, pass

block_a:
    addi x5, x5, 1
    add x10, x1, x0
    jal x1, block_b
    addi x5, x5, 1
    add x1, x10, x0
    jalr x0, 0(x1)

block_b:
    addi x5, x5, 1
    addi x6, x0, 2
    bne x5, x6, fail
    jalr x0, 0(x1)
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
