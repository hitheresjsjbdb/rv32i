.text
.globl _start
_start:
# taken and not-taken
    addi x5, x0, 5
    addi x6, x0, 5
    beq x5, x6, beq_ok
    jal x0, fail
beq_ok:
    addi x6, x0, 6
    beq x5, x6, fail

    # backward loop with beq exit
    addi x7, x0, 3
beq_loop:
    addi x7, x7, -1
    beq x7, x0, beq_done
    jal x0, beq_loop
beq_done:

    # unconditional style: beq x0,x0
    beq x0, x0, beq_pass2
    jal x0, fail
beq_pass2:
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
