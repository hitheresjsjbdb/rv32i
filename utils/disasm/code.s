0x00000000:	ori	s7, zero, 0x7b
0x00000004:	ori	s8, zero, 0x678
0x00000008:	ori	ra, zero, 8
0x0000000c:	ori	sp, zero, 0xc
0x00000010:	ori	gp, zero, 0
0x00000014:	add	a1, sp, ra
0x00000018:	sub	a2, sp, ra
0x0000001c:	addi	a3, sp, 1
0x00000020:	or	a4, sp, gp
0x00000024:	and	a5, ra, sp
0x00000028:	xor	s3, sp, ra
0x0000002c:	ori	tp, zero, 4
0x00000030:	sll	t2, sp, tp
0x00000034:	ori	a5, zero, 0x80
0x00000038:	srl	t1, a5, tp
0x0000003c:	sra	t0, a5, tp
0x00000040:	ori	tp, zero, 4
0x00000044:	sw	tp, -4(ra)
0x00000048:	sw	sp, 0(zero)
0x0000004c:	sw	gp, 4(zero)
0x00000050:	lw	t0, -8(ra)
0x00000054:	sll	t0, sp, tp
0x00000058:	addi	gp, sp, 1
0x0000005c:	or	sp, gp, zero
0x00000060:	bne	gp, t0, -8
0x00000064:	addi	t4, zero, 0x4c
0x00000068:	addi	s11, zero, 0xab
0x0000006c:	sw	s11, 4(t4)
0x00000070:	j	0x10
0x00000074:	ori	zero, ra, 0
0x00000078:	ori	zero, ra, 0
0x0000007c:	ori	zero, ra, 0
0x00000080:	lw	t3, 4(t4)
0x00000084:	beq	s11, t3, 0x10
0x00000088:	ori	zero, ra, 0
0x0000008c:	ori	zero, ra, 0
0x00000090:	ori	zero, ra, 0
0x00000094:	lw	t5, 4(t4)
0x00000098:	ori	t6, zero, 0xff
