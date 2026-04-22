.text
.globl _start
_start:
addi x5, x0, 0
    addi x6, x0, 1
    addi x7, x0, 5
or_loop:
    or x5, x5, x6
    sll x6, x6, x6          # shift by current value (1->2->8 via mask effects)
    addi x7, x7, -1
    bne x7, x0, or_loop
    bne x5, x0, pass_check
    jal x0, fail
pass_check:
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
