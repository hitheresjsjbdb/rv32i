.text
.globl _start
_start:
addi x5, x0, 5
    addi x6, x0, 6
    bne x5, x6, bne_ok
    jal x0, fail
bne_ok:
    addi x6, x0, 5
    bne x5, x6, fail

    addi x7, x0, 3
bne_loop:
    addi x7, x7, -1
    bne x7, x0, bne_loop

    bne x0, x0, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
