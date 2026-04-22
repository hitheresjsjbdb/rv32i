.text
.globl _start
_start:
# odd target alignment + return chain
    addi x5, x0, 0
    jal x1, odd_return_test
after_odd:
    addi x5, x5, 2

    jal x1, call_via_reg
after_call:
    addi x5, x5, 2

    addi x6, x0, 6
    bne x5, x6, fail
    jal x0, pass

odd_return_test:
    addi x5, x5, 1
    addi x1, x1, 1
    jalr x0, 0(x1)

call_via_reg:
    addi x5, x5, 1
    add x10, x1, x0
    jalr x11, 0(x10)
ret_after_jalr:
    jal x0, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
