.text
.globl _start
_start:
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
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
