.text
.globl _start
_start:
addi x31, x0, 96
    addi x30, x0, 21
    sw x30, 0(x31)
    lw x29, 0(x31)
    bne x29, x30, fail

addi x31, x0, 96
    addi x30, x0, 21
    sw x30, 0(x31)
    lw x29, 0(x31)
    bne x29, x30, fail

addi x5, x0, 0
    jal x1, dep_target
ret_dep:
    addi x5, x5, 1
    addi x6, x0, 3
    bne x5, x6, fail
    jal x0, pass

dep_target:
    addi x5, x5, 1
    add x10, x1, x0
    addi x5, x5, 1
    jalr x0, 0(x10)

jal x1, wrapb_func_1
wrapb_ret_1:
    addi x25, x0, 28
    bne x29, x25, fail
    jal x0, wrapb_after_1

wrapb_func_1:
    addi x29, x29, 7
    add x24, x1, x0
    jalr x0, 0(x24)

wrapb_after_1:

jal x1, wrapb_func_2
wrapb_ret_2:
    addi x25, x0, 28
    bne x29, x25, fail
    jal x0, wrapb_after_2

wrapb_func_2:
    addi x29, x29, 7
    add x24, x1, x0
    jalr x0, 0(x24)

wrapb_after_2:
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
