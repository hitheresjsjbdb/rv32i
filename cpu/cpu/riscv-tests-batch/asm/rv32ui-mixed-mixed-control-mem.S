.text
.globl _start
_start:
addi x5, x0, 1
    addi x6, x0, 31
    sll x7, x5, x6
    srl x8, x7, x6
    bne x8, x5, fail

    addi x9, x0, -1
    xor x10, x9, x7
    or x11, x10, x5
    and x12, x11, x9
    bne x12, x11, fail

    addi x13, x0, 3
mix2_loop:
    addi x5, x5, 2
    sub x13, x13, x5
    addi x13, x13, 2
    addi x6, x6, -1
    bne x6, x0, mix2_loop

    addi x20, x0, 128
    sw x11, 0(x20)
    lw x21, 0(x20)
    bne x21, x11, fail

    jal x1, mix2_func_a
mix2_ret_a:
    jal x1, mix2_func_b
mix2_ret_b:
    addi x22, x0, 2
    bne x23, x22, fail
    bne x0, x0, fail
    jal x0, mix2_done

mix2_func_a:
    addi x23, x0, 1
    add x24, x1, x0
    jalr x0, 0(x24)

mix2_func_b:
    addi x23, x23, 1
    add x24, x1, x0
    jalr x0, 0(x24)

mix2_done:
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
