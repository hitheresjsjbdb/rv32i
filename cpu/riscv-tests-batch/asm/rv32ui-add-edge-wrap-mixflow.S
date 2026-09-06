.text
.globl _start
_start:
addi x31, x0, 96
    addi x30, x0, 21
    sw x30, 0(x31)
    lw x29, 0(x31)
    bne x29, x30, fail

addi x5, x0, -1
    addi x6, x0, 1
    add x7, x5, x6
    bne x7, x0, fail

    srl x8, x5, x6          # max
    addi x9, x0, 31
    sll x10, x6, x9         # min
    add x11, x8, x6         # max+1=min
    bne x11, x10, fail

    add x12, x10, x8        # min+max=-1
    bne x12, x5, fail

    add x13, x12, x6        # -1+1=0
    bne x13, x0, fail

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
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
