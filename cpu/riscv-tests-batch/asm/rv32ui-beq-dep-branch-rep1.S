.text
.globl _start
_start:
addi x5, x0, 0
    addi x6, x0, 5
beq_dep_loop:
    addi x5, x5, 1
    beq x5, x6, beq_dep_done
    jal x0, beq_dep_loop
beq_dep_done:
    addi x7, x0, 5
    bne x5, x7, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
