.text
.globl _start
_start:
# shamt 0
    addi x5, x0, 1
    addi x6, x0, 0
    sll x7, x5, x6
    bne x7, x5, fail

    # shamt 8
    addi x6, x0, 8
    sll x7, x5, x6
    addi x8, x0, 256
    bne x7, x8, fail

    # shamt 31 -> min
    addi x6, x0, 31
    sll x9, x5, x6
    addi x10, x0, 31
    sll x11, x5, x10
    bne x9, x11, fail

    # shamt mask: 32 -> 0, 33 -> 1
    addi x12, x0, 32
    sll x13, x5, x12
    bne x13, x5, fail
    addi x12, x0, 33
    sll x13, x5, x12
    addi x14, x0, 2
    bne x13, x14, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
