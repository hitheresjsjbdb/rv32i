.text
.globl _start
_start:
addi x5, x0, 32
    addi x6, x0, 1
    addi x7, x0, 4
sw_loop:
    sw x6, 0(x5)
    lw x8, 0(x5)
    bne x8, x6, fail
    addi x6, x6, 1
    addi x7, x7, -1
    bne x7, x0, sw_loop

    addi x9, x0, 5
    bne x6, x9, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
