.text
.globl _start
_start:
addi x5, x0, 0
    addi x6, x0, 4
    addi x7, x0, 1
mix1_loop:
    add x5, x5, x7
    addi x7, x7, 1
    addi x6, x6, -1
    bne x6, x0, mix1_loop

    addi x8, x0, 10
    bne x5, x8, fail

    addi x9, x0, 100
    sw x5, 0(x9)
    lw x10, 0(x9)
    bne x10, x8, fail

    beq x10, x8, mix1_beq_ok
    jal x0, fail
mix1_beq_ok:

    jal x1, mix1_func
mix1_ret:
    addi x11, x0, 13
    bne x10, x11, fail

    addi x12, x0, -8
    addi x13, x0, 1
    sra x14, x12, x13
    addi x15, x0, -4
    bne x14, x15, fail
    jal x0, mix1_done

mix1_func:
    addi x10, x10, 3
    add x16, x1, x0
    jalr x0, 0(x16)

mix1_done:
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
