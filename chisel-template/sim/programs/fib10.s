    addi x1, x0, 0
    addi x2, x0, 1
    addi x3, x0, 10
    addi x4, x0, 0

loop:
    beq  x4, x3, done
    add  x5, x1, x2
    add  x1, x2, x0
    add  x2, x5, x0
    addi x4, x4, 1
    beq  x0, x0, loop

done:
    sw   x1, 0(x0)
    lw   x6, 0(x0)
    beq  x6, x1, halt

fail:
    beq  x0, x0, fail

halt:
    beq  x6, x1, halt