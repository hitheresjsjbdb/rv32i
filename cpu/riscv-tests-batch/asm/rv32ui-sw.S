.text
.globl _start
_start:
# addr 4 normal
    addi x5, x0, 4
    addi x6, x0, 33
    sw x6, 0(x5)
    lw x7, 0(x5)
    bne x7, x6, fail

    # overwrite same addr
    addi x6, x0, -77
    sw x6, 0(x5)
    lw x7, 0(x5)
    bne x7, x6, fail

    # negative offset
    addi x8, x0, 8
    addi x9, x0, 55
    sw x9, -4(x8)
    lw x10, 0(x5)
    bne x10, x9, fail

    # high boundary addr 4092
    addi x11, x0, 1023
    addi x12, x0, 2
    sll x11, x11, x12
    addi x13, x0, 88
    sw x13, 0(x11)
    lw x14, 0(x11)
    bne x14, x13, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
