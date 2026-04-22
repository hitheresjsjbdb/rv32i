.text
.globl _start
_start:
    addi x20, x0, 512
    addi x21, x0, 0
    addi x22, x0, 1
    or x7, x11, x5
    add x13, x6, x10
    ori x5, x13, -28
    add x11, x11, x6
    xor x6, x13, x11
    addi x14, x6, -25
    ori x14, x11, -4
    addi x13, x7, 21
    sub x13, x6, x14
    and x13, x7, x6
    ori x14, x8, -20
    sra x6, x14, x5
    ori x8, x12, 22
    or x12, x14, x12
    or x9, x8, x7
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_15
rnd_7_15:
    sra x12, x10, x12
    and x14, x6, x6
    sra x11, x7, x10
    sub x12, x11, x5
    sw x13, 20(x20)
    lw x6, 20(x20)
    bne x6, x13, fail
    or x10, x14, x12
    ori x12, x6, 2
    srl x6, x5, x9
    sw x12, 24(x20)
    lw x14, 24(x20)
    bne x14, x12, fail
    sw x5, 20(x20)
    lw x10, 20(x20)
    bne x10, x5, fail
    sub x14, x6, x12
    addi x8, x9, -1
    sll x11, x12, x6
    sub x12, x11, x13
    and x7, x11, x13
    and x11, x10, x11
    xor x7, x6, x7
    sub x8, x8, x5
    srl x14, x7, x9
    and x5, x7, x11
    sra x10, x14, x14
    or x7, x13, x14
    sw x12, 24(x20)
    lw x5, 24(x20)
    bne x5, x12, fail
    sll x11, x11, x6
    jal x1, rnd_call_7_39
rnd_ret_7_39:
    jal x0, rnd_cont_7_39
rnd_call_7_39:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_7_39:
    srl x11, x5, x8
    add x8, x12, x7
    add x10, x14, x5
    add x5, x14, x7
    sra x6, x10, x14
    addi x6, x8, 16
    sub x9, x10, x14
    or x12, x6, x6
    srl x12, x12, x12
    and x6, x7, x6
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_7_50
rnd_7_50:
    sra x5, x8, x13
    or x7, x13, x5
    sra x9, x6, x9
    sra x10, x7, x10
    xor x13, x13, x13
    or x8, x14, x8
    xor x11, x8, x8
    sra x12, x10, x5
    addi x9, x12, -8
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_60
rnd_7_60:
    or x6, x8, x6
    xor x12, x8, x10
    xor x12, x14, x14
    addi x12, x10, -17
    sll x8, x12, x7
    sll x10, x6, x11
    srl x11, x6, x7
    sub x7, x5, x7
    ori x12, x7, 28
    sw x7, 8(x20)
    lw x10, 8(x20)
    bne x10, x7, fail
    addi x5, x6, -15
    sll x8, x8, x5
    and x8, x9, x13
    xor x14, x10, x9
    sra x11, x7, x5
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_76
rnd_7_76:
    sra x7, x13, x7
    sra x13, x5, x12
    sub x14, x5, x7
    jal x1, rnd_call_7_79
rnd_ret_7_79:
    jal x0, rnd_cont_7_79
rnd_call_7_79:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_7_79:
    sub x7, x12, x14
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_81
rnd_7_81:
    sw x13, 28(x20)
    lw x13, 28(x20)
    bne x13, x13, fail
    add x13, x5, x8
    xor x9, x5, x6
    sra x12, x13, x5
    add x12, x10, x14
    sra x14, x13, x8
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_88
rnd_7_88:
    sra x8, x13, x9
    sra x8, x12, x7
    sll x6, x11, x12
    or x6, x8, x11
    add x8, x9, x6
    sub x10, x7, x9
    sub x12, x8, x6
    sll x12, x7, x8
    sub x11, x13, x11
    or x11, x8, x10
    or x6, x10, x5
    or x13, x12, x12
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_101
rnd_7_101:
    sra x6, x6, x8
    add x6, x9, x9
    addi x7, x9, 22
    sw x11, 28(x20)
    lw x9, 28(x20)
    bne x9, x11, fail
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_7_106
rnd_7_106:
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_107
rnd_7_107:
    addi x6, x9, -4
    add x9, x6, x12
    addi x10, x13, 2
    ori x7, x5, -2
    add x7, x9, x5
    sub x8, x9, x9
    sra x8, x9, x12
    sra x7, x9, x10
    addi x9, x5, -30
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_117
rnd_7_117:
    xor x12, x6, x11
    sw x13, 16(x20)
    lw x12, 16(x20)
    bne x12, x13, fail
    jal x1, rnd_call_7_119
rnd_ret_7_119:
    jal x0, rnd_cont_7_119
rnd_call_7_119:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_7_119:
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_7_120
rnd_7_120:
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_7_121
rnd_7_121:
    sub x5, x6, x9
    sll x7, x5, x6
    sw x13, 12(x20)
    lw x11, 12(x20)
    bne x11, x13, fail
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_7_125
rnd_7_125:
    sub x9, x12, x5
    and x10, x10, x13
    or x8, x5, x9
    xor x10, x7, x5
    or x11, x6, x12
    and x13, x8, x8
    sra x5, x6, x9
    add x7, x11, x14
    addi x11, x5, 6
    sw x6, 8(x20)
    lw x8, 8(x20)
    bne x8, x6, fail
    sw x11, 28(x20)
    lw x14, 28(x20)
    bne x14, x11, fail
    sub x9, x14, x7
    addi x13, x11, -15
    sra x13, x14, x5
    sw x8, 0(x20)
    lw x14, 0(x20)
    bne x14, x8, fail
    addi x7, x10, 16
    srl x13, x5, x5
    sw x8, 16(x20)
    lw x13, 16(x20)
    bne x13, x8, fail
    addi x12, x6, -21
    sw x6, 16(x20)
    lw x13, 16(x20)
    bne x13, x6, fail
    add x9, x8, x8
    xor x12, x12, x11
    add x12, x9, x5
    ori x8, x6, -14
    or x9, x9, x14
    ori x7, x5, -25
    srl x9, x6, x8
    sw x9, 16(x20)
    lw x12, 16(x20)
    bne x12, x9, fail
    srl x12, x12, x6
    sra x8, x9, x6
    srl x5, x9, x12
    add x13, x12, x9
    sll x8, x8, x6
    ori x6, x7, 1
    jal x1, rnd_call_7_159
rnd_ret_7_159:
    jal x0, rnd_cont_7_159
rnd_call_7_159:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_7_159:
    or x7, x14, x13
    and x6, x10, x8
    srl x12, x11, x5
    sub x5, x12, x12
    sll x9, x7, x11
    or x11, x10, x6
    or x5, x10, x10
    sll x6, x8, x5
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_7_168
rnd_7_168:
    sll x11, x14, x6
    or x11, x9, x5
    and x6, x5, x9
    sw x8, 24(x20)
    lw x7, 24(x20)
    bne x7, x8, fail
    sra x10, x8, x10
    sll x5, x11, x13
    sra x8, x6, x5
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_7_176
rnd_7_176:
    sw x12, 8(x20)
    lw x9, 8(x20)
    bne x9, x12, fail
    sub x12, x11, x10
    and x9, x9, x9
    sll x8, x9, x12
    sra x11, x6, x7
    sw x6, 28(x20)
    lw x7, 28(x20)
    bne x7, x6, fail
    sra x8, x12, x10
    srl x11, x7, x13
    xor x8, x6, x7
    or x13, x6, x10
    xor x10, x9, x14
    xor x5, x11, x11
    sll x13, x8, x11
    and x10, x5, x12
    and x14, x10, x7
    sw x13, 4(x20)
    lw x13, 4(x20)
    bne x13, x13, fail
    and x8, x11, x11
    sw x11, 0(x20)
    lw x12, 0(x20)
    bne x12, x11, fail
    sub x5, x11, x12
    ori x12, x5, 18
    sra x12, x12, x8
    add x8, x7, x7
    sra x6, x12, x6
    jal x1, rnd_call_7_199
rnd_ret_7_199:
    jal x0, rnd_cont_7_199
rnd_call_7_199:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_7_199:
    sra x5, x5, x7
    xor x14, x5, x9
    sub x9, x13, x11
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_203
rnd_7_203:
    sra x14, x8, x11
    and x8, x14, x5
    addi x13, x9, 3
    or x8, x12, x13
    xor x13, x8, x5
    sll x9, x5, x5
    xor x12, x11, x6
    and x8, x11, x10
    xor x12, x5, x10
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_7_213
rnd_7_213:
    addi x9, x13, -6
    srl x8, x9, x8
    xor x12, x8, x9
    and x6, x14, x12
    ori x7, x8, 21
    sw x14, 24(x20)
    lw x5, 24(x20)
    bne x5, x14, fail
    addi x8, x5, -14
    sll x5, x5, x7
    sll x12, x10, x6
    add x7, x10, x8
    sub x13, x12, x5
    and x11, x10, x10
    srl x7, x6, x5
    add x9, x6, x10
    sll x6, x13, x8
    sll x10, x9, x11
    add x5, x12, x8
    or x13, x12, x8
    or x10, x12, x5
    sw x8, 0(x20)
    lw x11, 0(x20)
    bne x11, x8, fail
    sll x5, x12, x6
    addi x9, x8, 11
    or x9, x10, x14
    addi x9, x10, 6
    addi x14, x6, -3
    add x12, x12, x11
    jal x1, rnd_call_7_239
rnd_ret_7_239:
    jal x0, rnd_cont_7_239
rnd_call_7_239:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_7_239:
    and x11, x12, x7
    srl x7, x5, x9
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_242
rnd_7_242:
    or x12, x10, x14
    add x13, x8, x11
    sub x8, x11, x6
    sw x12, 20(x20)
    lw x5, 20(x20)
    bne x5, x12, fail
    sub x11, x6, x6
    and x14, x6, x8
    add x11, x12, x12
    sub x8, x7, x11
    srl x14, x8, x13
    sw x9, 16(x20)
    lw x6, 16(x20)
    bne x6, x9, fail
    ori x9, x10, 1
    xor x12, x8, x7
    xor x8, x7, x9
    ori x8, x10, 18
    and x8, x13, x13
    xor x6, x12, x5
    add x5, x12, x8
    srl x10, x5, x9
    xor x6, x5, x8
    ori x14, x8, 15
    sra x7, x12, x14
    and x5, x6, x14
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_7_265
rnd_7_265:
    or x10, x7, x5
    xor x9, x5, x14
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_268
rnd_7_268:
    sw x7, 16(x20)
    lw x10, 16(x20)
    bne x10, x7, fail
    add x8, x5, x12
    sra x12, x6, x11
    add x11, x13, x7
    sw x6, 24(x20)
    lw x13, 24(x20)
    bne x13, x6, fail
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_274
rnd_7_274:
    sll x5, x9, x14
    or x11, x11, x5
    or x8, x11, x11
    xor x5, x11, x7
    sll x6, x6, x11
    jal x1, rnd_call_7_279
rnd_ret_7_279:
    jal x0, rnd_cont_7_279
rnd_call_7_279:
    add x24, x1, x0
    jalr x0, 0(x24)
rnd_cont_7_279:
    ori x10, x12, -16
    addi x5, x13, 18
    add x14, x14, x10
    addi x21, x21, 1
    addi x22, x22, 1
    bne x21, x22, rnd_7_283
rnd_7_283:
    and x7, x13, x7
    add x6, x11, x12
    xor x9, x7, x5
    srl x10, x5, x14
    sw x6, 8(x20)
    lw x11, 8(x20)
    bne x11, x6, fail
    sw x14, 12(x20)
    lw x8, 12(x20)
    bne x8, x14, fail
    srl x7, x14, x8
    addi x11, x13, 17
    or x6, x7, x8
    addi x21, x21, 1
    addi x22, x22, 1
    beq x21, x22, rnd_7_293
rnd_7_293:
    sw x6, 28(x20)
    lw x10, 28(x20)
    bne x10, x6, fail
    sra x9, x11, x9
    ori x8, x11, 15
    srl x13, x12, x7
    addi x5, x14, 27
    xor x12, x14, x12
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
