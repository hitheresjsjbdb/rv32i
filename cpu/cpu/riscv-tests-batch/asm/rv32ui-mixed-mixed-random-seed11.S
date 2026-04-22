.text
.globl _start
_start:
    addi x20, x0, 512
    addi x21, x0, 0
    addi x22, x0, 1
    srl x13, x12, x12
    sra x14, x8, x7
    sra x12, x14, x7
    add x12, x9, x7
    add x13, x5, x14
    sll x12, x14, x7
    ori x5, x13, -25
    addi x8, x8, -29
    srl x10, x12, x14
    xor x13, x8, x9
    srl x5, x6, x12
    sw x11, 4(x20)
    lw x9, 4(x20)
    bne x9, x11, fail
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_11_12
rnd_11_12:
    addi x6, x14, 19
    add x9, x11, x6
    addi x5, x8, -26
    srl x11, x11, x11
    add x14, x8, x9
    or x6, x9, x10
    addi x11, x6, -1
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_11_20
rnd_11_20:
    srl x7, x13, x8
    srl x13, x8, x7
    sll x11, x6, x11
    sll x8, x5, x9
    ori x9, x5, -9
    sll x14, x14, x6
    addi x7, x8, 1
    addi x14, x10, 17
    add x6, x6, x8
    ori x8, x5, 15
    or x14, x12, x7
    ori x12, x14, 17
    sub x7, x9, x8
    ori x8, x8, -7
    sw x12, 4(x20)
    lw x11, 4(x20)
    bne x11, x12, fail
    sll x5, x6, x6
    addi x13, x9, 18
    and x11, x14, x12
    and x13, x7, x6
    jal x1, rnd_call_11_39
rnd_ret_11_39:
    jal x0, rnd_cont_11_39
rnd_call_11_39:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_11_39:
    sub x8, x12, x13
    sw x14, 16(x20)
    lw x14, 16(x20)
    bne x14, x14, fail
    xor x8, x5, x6
    and x11, x12, x8
    addi x5, x7, 15
    sra x14, x7, x6
    or x7, x12, x10
    sw x14, 0(x20)
    lw x13, 0(x20)
    bne x13, x14, fail
    addi x12, x10, -28
    addi x14, x6, -24
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_11_50
rnd_11_50:
    add x12, x13, x10
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_11_52
rnd_11_52:
    add x12, x6, x11
    addi x12, x14, 16
    sll x14, x5, x14
    add x6, x6, x6
    and x11, x10, x11
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_11_58
rnd_11_58:
    sra x6, x13, x13
    addi x9, x14, 29
    addi x8, x6, 30
    and x5, x10, x9
    sub x14, x8, x13
    sub x10, x12, x12
    xor x10, x11, x9
    xor x11, x8, x8
    sll x8, x14, x10
    xor x7, x7, x12
    or x5, x6, x9
    sub x6, x12, x12
    and x8, x11, x11
    sw x12, 28(x20)
    lw x13, 28(x20)
    bne x13, x12, fail
    or x6, x5, x9
    ori x5, x9, 13
    and x14, x5, x7
    sll x12, x8, x5
    and x8, x7, x5
    sw x12, 20(x20)
    lw x6, 20(x20)
    bne x6, x12, fail
    add x8, x8, x12
    jal x1, rnd_call_11_79
rnd_ret_11_79:
    jal x0, rnd_cont_11_79
rnd_call_11_79:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_11_79:
    and x7, x5, x12
    sra x5, x7, x8
    and x10, x13, x13
    sra x14, x7, x11
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_11_84
rnd_11_84:
    sub x12, x12, x8
    sw x11, 20(x20)
    lw x5, 20(x20)
    bne x5, x11, fail
    srl x10, x8, x6
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_11_88
rnd_11_88:
    add x9, x13, x10
    and x5, x10, x13
    add x5, x12, x10
    sra x11, x9, x12
    addi x8, x6, -28
    sub x13, x10, x7
    srl x7, x13, x13
    sw x12, 4(x20)
    lw x12, 4(x20)
    bne x12, x12, fail
    xor x12, x13, x13
    and x13, x7, x13
    sra x13, x9, x9
    sw x14, 16(x20)
    lw x11, 16(x20)
    bne x11, x14, fail
    sub x13, x13, x9
    ori x12, x8, -18
    sra x5, x14, x11
    addi x13, x5, 19
    sra x14, x6, x12
    add x7, x6, x13
    srl x11, x11, x9
    xor x12, x12, x7
    or x11, x12, x13
    or x6, x8, x11
    ori x5, x9, -30
    addi x8, x7, -31
    sw x10, 12(x20)
    lw x9, 12(x20)
    bne x9, x10, fail
    ori x12, x6, -17
    sra x14, x9, x8
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_11_116
rnd_11_116:
    sw x13, 8(x20)
    lw x11, 8(x20)
    bne x11, x13, fail
    sra x8, x13, x8
    sra x8, x13, x14
    jal x1, rnd_call_11_119
rnd_ret_11_119:
    jal x0, rnd_cont_11_119
rnd_call_11_119:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_11_119:
    ori x7, x8, -9
    or x14, x10, x8
    xor x8, x6, x7
    xor x7, x6, x9
    sll x6, x11, x11
    sra x7, x8, x11
    sw x6, 20(x20)
    lw x5, 20(x20)
    bne x5, x6, fail
    or x6, x13, x10
    sra x8, x6, x12
    add x5, x5, x13
    ori x13, x14, -14
    xor x7, x6, x8
    sub x7, x9, x6
    ori x5, x7, -23
    add x10, x11, x12
    sll x13, x10, x11
    xor x14, x10, x5
    sw x8, 24(x20)
    lw x5, 24(x20)
    bne x5, x8, fail
    srl x10, x10, x11
    xor x14, x7, x6
    sra x5, x10, x6
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_11_141
rnd_11_141:
    sra x14, x10, x9
    and x6, x7, x11
    sub x10, x13, x10
    sll x7, x11, x8
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_11_146
rnd_11_146:
    srl x6, x5, x10
    sw x5, 16(x20)
    lw x14, 16(x20)
    bne x14, x5, fail
    sw x10, 24(x20)
    lw x9, 24(x20)
    bne x9, x10, fail
    ori x7, x13, 17
    sra x12, x8, x6
    sll x14, x5, x6
    ori x6, x8, 24
    sll x13, x5, x8
    sw x5, 16(x20)
    lw x11, 16(x20)
    bne x11, x5, fail
    and x9, x10, x13
    sra x13, x11, x13
    ori x6, x12, -27
    sll x7, x11, x12
    jal x1, rnd_call_11_159
rnd_ret_11_159:
    jal x0, rnd_cont_11_159
rnd_call_11_159:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_11_159:
    sub x12, x13, x14
    ori x5, x11, 21
    and x13, x11, x14
    and x10, x13, x9
    srl x9, x13, x9
    sw x5, 12(x20)
    lw x9, 12(x20)
    bne x9, x5, fail
    ori x5, x7, 17
    addi x10, x11, 8
    add x8, x11, x12
    and x8, x5, x13
    add x12, x7, x8
    ori x6, x5, 21
    srl x6, x8, x5
    or x13, x7, x6
    or x12, x7, x11
    srl x14, x9, x14
    sw x10, 8(x20)
    lw x11, 8(x20)
    bne x11, x10, fail
    and x7, x8, x12
    add x13, x9, x13
    ori x10, x9, -8
    sw x5, 32(x20)
    lw x23, 32(x20)
    bne x23, x5, fail
    addi x0, x23, 0
    bne x0, x0, fail
    jal x0, pass
fail:
    .word 0x00000017
pass:
    ebreak
