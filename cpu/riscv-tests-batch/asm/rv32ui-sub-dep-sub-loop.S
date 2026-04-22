.text
.globl _start
_start:
addi x5, x0, 20
    addi x6, x0, 1
    addi x7, x0, 5
sub_loop:
    sub x5, x5, x6
    addi x7, x7, -1
    bne x7, x0, sub_loop
    addi x8, x0, 15
    bne x5, x8, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
