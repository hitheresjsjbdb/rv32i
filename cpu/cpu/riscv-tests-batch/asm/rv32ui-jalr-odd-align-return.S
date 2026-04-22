.text
.globl _start
_start:
addi x5, x0, 0
    jal x1, odd_return
ret_after_odd:
    addi x5, x5, 2

    jal x1, via_reg
ret_after_reg:
    addi x5, x5, 2

    addi x6, x0, 6
    bne x5, x6, fail
    jal x0, pass

odd_return:
    addi x5, x5, 1
    addi x1, x1, 1
    jalr x0, 0(x1)

via_reg:
    addi x5, x5, 1
    add x10, x1, x0
    addi x0, x0, 0
    jalr x11, 0(x10)
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
