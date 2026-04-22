.text
.globl _start
_start:
    addi x20, x0, 512
    addi x21, x0, 0
    addi x22, x0, 1
    and x9, x7, x8
    sw x8, 8(x20)
    lw x7, 8(x20)
    bne x7, x8, fail
    add x13, x8, x9
    addi x11, x7, -31
    and x7, x6, x9
    srl x11, x7, x9
    or x8, x12, x13
    ori x11, x10, 8
    sw x10, 16(x20)
    lw x6, 16(x20)
    bne x6, x10, fail
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_13_9
rnd_13_9:
    srl x12, x13, x7
    and x8, x7, x13
    or x9, x10, x12
    and x14, x9, x11
    sub x14, x12, x13
    xor x14, x8, x8
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_13_16
rnd_13_16:
    sw x11, 24(x20)
    lw x12, 24(x20)
    bne x12, x11, fail
    addi x8, x7, 24
    sw x7, 16(x20)
    lw x9, 16(x20)
    bne x9, x7, fail
    or x8, x10, x13
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_13_21
rnd_13_21:
    xor x14, x5, x14
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_13_23
rnd_13_23:
    sub x9, x8, x7
    sw x6, 8(x20)
    lw x13, 8(x20)
    bne x13, x6, fail
    add x11, x14, x13
    sra x5, x12, x10
    sw x13, 8(x20)
    lw x6, 8(x20)
    bne x6, x13, fail
    and x6, x11, x9
    and x14, x14, x6
    srl x13, x10, x5
    addi x10, x10, 31
    sra x13, x13, x12
    xor x8, x9, x5
    sll x13, x7, x7
    and x11, x8, x9
    sll x14, x8, x10
    xor x14, x9, x11
    xor x10, x11, x5
    jal x1, rnd_call_13_39
rnd_ret_13_39:
    jal x0, rnd_cont_13_39
rnd_call_13_39:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_13_39:
    or x11, x12, x6
    add x5, x14, x5
    sw x8, 28(x20)
    lw x9, 28(x20)
    bne x9, x8, fail
    sra x11, x10, x5
    and x13, x11, x7
    sub x5, x6, x10
    sub x8, x9, x9
    ori x11, x9, 12
    sub x6, x10, x12
    srl x14, x14, x11
    addi x10, x13, -16
    addi x10, x7, -16
    addi x8, x7, 29
    or x6, x10, x9
    xor x5, x8, x8
    sra x12, x8, x14
    sll x14, x5, x13
    addi x6, x14, 15
    sra x11, x9, x7
    sra x9, x9, x6
    or x5, x5, x7
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_13_61
rnd_13_61:
    add x10, x11, x7
    ori x9, x5, -20
    and x11, x11, x12
    sll x9, x7, x7
    srl x9, x5, x13
    addi x13, x9, 10
    xor x8, x10, x11
    sub x12, x11, x9
    sub x12, x14, x13
    srl x8, x11, x12
    xor x5, x14, x5
    srl x13, x7, x7
    add x5, x14, x7
    and x6, x12, x14
    sra x5, x8, x11
    addi x13, x5, 6
    ori x7, x5, 22
    and x8, x12, x5
    jal x1, rnd_call_13_79
rnd_ret_13_79:
    jal x0, rnd_cont_13_79
rnd_call_13_79:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_13_79:
    ori x6, x8, -31
    ori x12, x10, -26
    sra x11, x8, x13
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_13_83
rnd_13_83:
    srl x10, x7, x10
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_13_85
rnd_13_85:
    and x7, x7, x7
    ori x6, x5, -14
    ori x13, x5, 13
    sll x14, x14, x12
    ori x13, x11, 24
    sra x9, x10, x11
    sw x8, 24(x20)
    lw x6, 24(x20)
    bne x6, x8, fail
    ori x6, x12, 6
    addi x12, x11, 29
    ori x5, x6, -5
    addi x7, x13, 6
    sra x8, x11, x13
    and x5, x8, x6
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_13_99
rnd_13_99:
    sw x10, 0(x20)
    lw x8, 0(x20)
    bne x8, x10, fail
    sub x7, x5, x5
    xor x11, x14, x7
    sw x6, 8(x20)
    lw x11, 8(x20)
    bne x11, x6, fail
    add x5, x10, x14
    addi x13, x13, -21
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_13_106
rnd_13_106:
    xor x9, x9, x14
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_13_108
rnd_13_108:
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_13_109
rnd_13_109:
    addi x6, x9, -4
    ori x9, x6, 31
    srl x14, x6, x5
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_13_113
rnd_13_113:
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_13_114
rnd_13_114:
    or x6, x5, x12
    add x6, x9, x12
    addi x11, x7, -15
    xor x10, x7, x11
    sll x5, x10, x10
    jal x1, rnd_call_13_119
rnd_ret_13_119:
    jal x0, rnd_cont_13_119
rnd_call_13_119:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_13_119:
    or x10, x8, x6
    sub x7, x14, x7
    sw x5, 24(x20)
    lw x11, 24(x20)
    bne x11, x5, fail
    add x12, x11, x13
    xor x7, x14, x11
    addi x11, x11, 22
    sll x9, x6, x13
    xor x11, x7, x14
    sra x5, x12, x12
    add x13, x13, x12
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_13_130
rnd_13_130:
    addi x8, x11, 31
    and x11, x5, x10
    xor x12, x11, x14
    sub x12, x8, x11
    ori x11, x5, 19
    xor x8, x14, x11
    xor x5, x5, x5
    srl x13, x14, x11
    sll x13, x7, x12
    add x12, x12, x14
    sw x6, 0(x20)
    lw x12, 0(x20)
    bne x12, x6, fail
    addi x12, x7, -18
    addi x11, x13, 27
    srl x5, x11, x5
    xor x9, x12, x13
    sub x7, x7, x5
    sub x14, x6, x9
    sub x12, x8, x12
    addi x14, x8, 27
    add x6, x14, x6
    sll x13, x7, x8
    ori x5, x5, -6
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_13_153
rnd_13_153:
    sw x7, 12(x20)
    lw x14, 12(x20)
    bne x14, x7, fail
    ori x13, x14, 22
    sra x7, x11, x14
    sll x8, x9, x9
    srl x5, x6, x12
    srl x8, x7, x9
    jal x1, rnd_call_13_159
rnd_ret_13_159:
    jal x0, rnd_cont_13_159
rnd_call_13_159:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_13_159:
    addi x12, x8, 3
    ori x13, x14, -16
    sll x10, x8, x12
    addi x11, x9, -15
    addi x10, x12, -23
    add x6, x10, x6
    ori x7, x14, 27
    ori x5, x12, -30
    ori x10, x13, -22
    sll x11, x6, x14
    xor x10, x7, x6
    ori x7, x6, 5
    sw x9, 12(x20)
    lw x12, 12(x20)
    bne x12, x9, fail
    srl x8, x6, x14
    sra x11, x9, x5
    add x9, x12, x8
    srl x5, x5, x11
    sra x6, x12, x14
    and x8, x6, x14
    ori x10, x5, 28
    addi x7, x13, -28
    and x11, x5, x11
    sub x11, x5, x10
    sub x7, x10, x11
    xor x9, x13, x12
    xor x5, x6, x10
    sub x5, x8, x8
    and x10, x14, x11
    sra x9, x5, x5
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_13_189
rnd_13_189:
    sub x6, x11, x11
    srl x9, x10, x13
    and x6, x11, x9
    sw x11, 28(x20)
    lw x8, 28(x20)
    bne x8, x11, fail
    xor x6, x6, x8
    add x10, x8, x7
    sw x10, 12(x20)
    lw x6, 12(x20)
    bne x6, x10, fail
    xor x14, x13, x10
    add x6, x10, x11
    srl x11, x11, x11
    jal x1, rnd_call_13_199
rnd_ret_13_199:
    jal x0, rnd_cont_13_199
rnd_call_13_199:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_13_199:
    add x10, x14, x11
    sra x7, x9, x9
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_13_202
rnd_13_202:
    sra x7, x6, x10
    sw x5, 20(x20)
    lw x14, 20(x20)
    bne x14, x5, fail
    sll x14, x11, x13
    sll x7, x6, x8
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_13_207
rnd_13_207:
    add x11, x11, x12
    sw x8, 4(x20)
    lw x13, 4(x20)
    bne x13, x8, fail
    and x12, x12, x5
    or x8, x9, x12
    and x7, x10, x9
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_13_213
rnd_13_213:
    or x6, x7, x8
    sw x9, 20(x20)
    lw x9, 20(x20)
    bne x9, x9, fail
    addi x12, x6, 16
    srl x11, x10, x11
    add x5, x9, x7
    xor x6, x5, x5
    add x11, x8, x7
    xor x12, x7, x10
    add x13, x11, x13
    add x6, x11, x14
    ori x11, x5, 5
    add x14, x9, x9
    xor x6, x12, x14
    add x12, x5, x9
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_13_228
rnd_13_228:
    xor x14, x9, x12
    sra x11, x10, x9
    sll x7, x10, x13
    addi x6, x12, 22
    sra x9, x10, x11
    ori x8, x11, -26
    srl x11, x13, x14
    addi x10, x9, -23
    ori x11, x6, -26
    and x8, x8, x6
    sra x12, x5, x7
    jal x1, rnd_call_13_239
rnd_ret_13_239:
    jal x0, rnd_cont_13_239
rnd_call_13_239:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_13_239:
    srl x12, x8, x5
    addi x6, x7, -16
    and x9, x5, x14
    sw x12, 16(x20)
    lw x12, 16(x20)
    bne x12, x12, fail
    sll x8, x5, x5
    srl x9, x12, x13
    sub x7, x7, x6
    addi x10, x13, -29
    addi x9, x7, 8
    sw x11, 12(x20)
    lw x14, 12(x20)
    bne x14, x11, fail
    xor x9, x13, x8
    or x10, x6, x11
    sub x5, x7, x13
    xor x14, x12, x12
    sw x5, 0(x20)
    lw x9, 0(x20)
    bne x9, x5, fail
    ori x6, x9, -20
    srl x14, x10, x9
    srl x14, x5, x14
    sub x10, x13, x9
    sub x9, x11, x9
    or x11, x12, x13
    sll x7, x8, x6
    sub x12, x8, x13
    sll x7, x14, x7
    addi x10, x7, -19
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_13_265
rnd_13_265:
    or x13, x14, x10
    addi x8, x5, 21
    sra x9, x11, x7
    and x13, x5, x5
    ori x11, x8, -12
    add x5, x6, x14
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_13_272
rnd_13_272:
    sub x11, x14, x9
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_13_274
rnd_13_274:
    addi x11, x8, -2
    srl x9, x13, x9
    xor x12, x5, x11
    sw x13, 20(x20)
    lw x9, 20(x20)
    bne x9, x13, fail
    sw x12, 12(x20)
    lw x10, 12(x20)
    bne x10, x12, fail
    jal x1, rnd_call_13_279
rnd_ret_13_279:
    jal x0, rnd_cont_13_279
rnd_call_13_279:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_13_279:
    or x7, x10, x8
    sw x8, 24(x20)
    lw x9, 24(x20)
    bne x9, x8, fail
    sub x10, x13, x10
    srl x5, x12, x11
    or x11, x14, x6
    ori x12, x5, -20
    sra x13, x12, x6
    xor x5, x6, x12
    add x12, x11, x13
    and x6, x5, x13
    xor x10, x12, x5
    sra x9, x10, x6
    ori x9, x7, -16
    sra x13, x11, x8
    sub x7, x14, x7
    and x13, x14, x13
    sra x12, x8, x10
    and x12, x14, x6
    or x6, x10, x5
    xor x10, x8, x5
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
