.text
.globl _start
_start:
addi x5, x0, 0
    jal x1, dep_target
ret_dep:
    addi x5, x5, 1
    addi x6, x0, 3
    bne x5, x6, fail
    jal x0, pass

dep_target:
    addi x5, x5, 1
    addi x10, x0, 96
    sw x1, 0(x10)
    addi x5, x5, 1
    lw x11, 0(x10)
    jalr x0, 0(x11)
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
