.text
.globl _start
_start:
addi x31, x0, 96
    addi x30, x0, 21
    sw x30, 0(x31)
    lw x29, 0(x31)
    bne x29, x30, fail

addi x5, x0, 3
    addi x6, x0, 4
    add x7, x5, x6          # 7
    add x7, x7, x6          # 11
    add x7, x7, x5          # 14
    addi x8, x0, 14
    bne x7, x8, fail

    addi x9, x0, 5
    addi x10, x0, 0
add_loop:
    add x10, x10, x9
    addi x9, x9, -1
    bne x9, x0, add_loop
    addi x11, x0, 15
    bne x10, x11, fail

jal x1, wrapb_func
wrapb_ret:
    addi x25, x0, 28
    bne x29, x25, fail
    jal x0, wrapb_after

wrapb_func:
    addi x29, x29, 7
    add x24, x1, x0
    jalr x0, 0(x24)

wrapb_after:
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
