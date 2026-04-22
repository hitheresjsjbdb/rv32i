.text
.globl _start
_start:
# nested call/return via jal + jalr
    addi x5, x0, 0
    jal x1, jal_func1
jal_after:
    addi x5, x5, 1
    addi x6, x0, 5
    bne x5, x6, fail
    jal x0, pass

jal_func1:
    addi x5, x5, 2
    add x10, x1, x0
    jal x1, jal_func2
    addi x5, x5, 1
    add x1, x10, x0
    jalr x0, 0(x1)

jal_func2:
    addi x5, x5, 1
    jalr x0, 0(x1)
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
