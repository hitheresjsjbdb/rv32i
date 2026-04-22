.text
.globl _start
_start:
    addi x20, x0, 512
    addi x21, x0, 0
    addi x22, x0, 1
    sra x6, x10, x14
    ori x9, x6, 12
    sll x11, x5, x5
    add x12, x8, x10
    add x12, x10, x14
    sra x11, x8, x12
    sub x8, x11, x11
    sw x13, 24(x20)
    lw x14, 24(x20)
    bne x14, x13, fail
    and x9, x13, x8
    sll x12, x13, x7
    and x9, x14, x12
    sll x14, x6, x10
    sub x9, x7, x10
    add x13, x11, x7
    sll x11, x12, x9
    ori x7, x10, 3
    addi x5, x11, -15
    sll x7, x9, x5
    addi x5, x9, -32
    sw x5, 0(x20)
    lw x13, 0(x20)
    bne x13, x5, fail
    sub x7, x12, x10
    xor x6, x5, x8
    and x12, x5, x7
    xor x6, x7, x5
    sw x8, 12(x20)
    lw x11, 12(x20)
    bne x11, x8, fail
    sw x8, 12(x20)
    lw x13, 12(x20)
    bne x13, x8, fail
    addi x14, x6, 0
    or x8, x11, x5
    or x11, x9, x14
    sub x9, x11, x6
    sll x5, x11, x11
    srl x5, x10, x11
    sub x7, x7, x10
    ori x12, x11, -21
    or x8, x12, x5
    srl x8, x14, x8
    srl x7, x13, x10
    sub x7, x5, x12
    addi x13, x12, -26
    add x9, x8, x10
    jal x1, rnd_call_29_39
rnd_ret_29_39:
    jal x0, rnd_cont_29_39
rnd_call_29_39:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_29_39:
    xor x6, x8, x14
    sub x8, x6, x9
    or x10, x5, x7
    or x8, x8, x11
    xor x9, x9, x13
    or x10, x11, x12
    and x8, x6, x7
    ori x14, x6, -23
    add x8, x8, x7
    addi x9, x10, -24
    and x6, x10, x11
    or x6, x10, x9
    add x14, x13, x10
    sub x13, x7, x13
    addi x12, x8, -5
    sll x8, x8, x11
    srl x11, x13, x13
    ori x5, x8, 26
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_29_58
rnd_29_58:
    sra x13, x8, x9
    sra x8, x8, x8
    xor x8, x8, x12
    sw x5, 24(x20)
    lw x9, 24(x20)
    bne x9, x5, fail
    sub x5, x9, x14
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_29_64
rnd_29_64:
    add x8, x6, x5
    add x14, x9, x7
    sub x11, x10, x7
    sra x12, x7, x6
    or x7, x5, x5
    sra x11, x7, x11
    addi x6, x13, 22
    xor x14, x14, x10
    xor x6, x9, x9
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_29_74
rnd_29_74:
    sw x6, 16(x20)
    lw x9, 16(x20)
    bne x9, x6, fail
    sra x13, x13, x7
    srl x8, x10, x10
    sw x8, 12(x20)
    lw x8, 12(x20)
    bne x8, x8, fail
    and x14, x8, x8
    jal x1, rnd_call_29_79
rnd_ret_29_79:
    jal x0, rnd_cont_29_79
rnd_call_29_79:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_29_79:
    addi x11, x7, 1
    sra x6, x9, x14
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_29_82
rnd_29_82:
    ori x14, x7, 12
    xor x6, x8, x14
    sra x14, x9, x5
    and x11, x13, x13
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_29_87
rnd_29_87:
    add x8, x10, x7
    sub x5, x10, x12
    xor x14, x5, x5
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_29_91
rnd_29_91:
    sra x7, x8, x6
    sw x6, 16(x20)
    lw x13, 16(x20)
    bne x13, x6, fail
    xor x5, x6, x10
    ori x10, x8, -23
    or x8, x12, x8
    xor x7, x11, x7
    addi x9, x9, 25
    ori x12, x14, 2
    sw x10, 20(x20)
    lw x10, 20(x20)
    bne x10, x10, fail
    sw x7, 12(x20)
    lw x13, 12(x20)
    bne x13, x7, fail
    ori x8, x12, -11
    sw x8, 0(x20)
    lw x10, 0(x20)
    bne x10, x8, fail
    sll x10, x5, x8
    sra x14, x7, x7
    addi x11, x10, 6
    addi x7, x9, 30
    srl x9, x11, x10
    srl x10, x13, x11
    addi x6, x13, 3
    sra x9, x12, x13
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_29_112
rnd_29_112:
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_29_113
rnd_29_113:
    sw x12, 16(x20)
    lw x5, 16(x20)
    bne x5, x12, fail
    and x12, x14, x10
    sub x13, x8, x5
    or x13, x5, x9
    add x5, x7, x8
    srl x8, x7, x5
    jal x1, rnd_call_29_119
rnd_ret_29_119:
    jal x0, rnd_cont_29_119
rnd_call_29_119:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_29_119:
    sub x10, x8, x8
    addi x10, x6, 7
    addi x14, x5, 31
    addi x5, x13, 9
    sll x5, x6, x8
    sub x8, x9, x12
    sub x12, x11, x14
    sra x9, x5, x6
    sra x11, x7, x10
    sra x10, x8, x13
    sw x7, 0(x20)
    lw x10, 0(x20)
    bne x10, x7, fail
    sra x5, x8, x9
    addi x13, x13, -4
    and x14, x10, x12
    sll x10, x6, x13
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_29_135
rnd_29_135:
    sra x11, x10, x10
    addi x10, x11, 16
    sw x5, 16(x20)
    lw x8, 16(x20)
    bne x8, x5, fail
    ori x8, x11, 31
    or x13, x14, x7
    or x13, x14, x10
    add x12, x7, x14
    and x9, x14, x10
    add x10, x11, x14
    and x5, x11, x5
    add x7, x10, x5
    sub x14, x12, x6
    xor x9, x9, x12
    sra x7, x12, x9
    sra x6, x14, x13
    ori x6, x10, 3
    or x14, x7, x10
    sll x8, x10, x14
    sub x6, x9, x9
    and x11, x8, x9
    srl x5, x5, x12
    sub x7, x8, x11
    sra x14, x5, x14
    sw x5, 12(x20)
    lw x9, 12(x20)
    bne x9, x5, fail
    jal x1, rnd_call_29_159
rnd_ret_29_159:
    jal x0, rnd_cont_29_159
rnd_call_29_159:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_29_159:
    add x5, x9, x8
    addi x5, x12, -17
    and x8, x12, x8
    addi x14, x7, 16
    and x6, x10, x6
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_29_165
rnd_29_165:
    srl x7, x10, x7
    sw x8, 12(x20)
    lw x12, 12(x20)
    bne x12, x8, fail
    xor x11, x5, x12
    and x8, x13, x10
    ori x9, x9, 22
    sll x11, x9, x10
    srl x8, x9, x11
    sub x11, x7, x8
    sub x11, x11, x12
    sub x10, x13, x11
    and x7, x6, x14
    addi x9, x10, -4
    addi x11, x8, -3
    xor x8, x12, x12
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
