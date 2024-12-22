level2_w_init:
	.byte 0			; room left offset
	.byte 80, 16	; player spawn X/Y
	.word level2_r1
level2_w_r1_to_r2:
	.byte 0			; room left offset
	.byte 0, 168	; player spawn X/Y
	.word level2_r2
level2_w_r1_to_rtest:
	.byte 12			; room left offset
	.byte 240, 32	; player spawn X/Y
	.word level2_rtest
level2_w_r1_to_rtest2:
	.byte 8			; room left offset
	.byte 240, 200	; player spawn X/Y
	.word level2_rtest2
level2_w_r1_to_r3:
	.byte 0			; room left offset
	.byte 0, 56	; player spawn X/Y
	.word level2_r3
level2_w_r1_to_r4:
	.byte 8			; room left offset
	.byte 184, 168	; player spawn X/Y
	.word level2_r4
level2_w_r1_to_r3b:
	.byte 0			; room left offset
	.byte 96, 160	; player spawn X/Y
	.word level2_r3b
level2_w_r1_to_r6:
	.byte 12			; room left offset
	.byte 240, 104	; player spawn X/Y
	.word level2_r6
level2_w_r1_to_r6a:
	.byte 0			; room left offset
	.byte 0, 104	; player spawn X/Y
	.word level2_r6a
level2_w_r2_to_r1:
	.byte 8			; room left offset
	.byte 192, 16	; player spawn X/Y
	.word level2_r1
level2_w_rtest_to_r1:
	.byte 0			; room left offset
	.byte 48, 200	; player spawn X/Y
	.word level2_r1
level2_w_rtest2_to_r1:
	.byte 0			; room left offset
	.byte 80, 16	; player spawn X/Y
	.word level2_r1
level2_w_r3_to_r1:
	.byte 8			; room left offset
	.byte 200, 200	; player spawn X/Y
	.word level2_r1
level2_w_r4_to_r1:
	.byte 0			; room left offset
	.byte 8, 88	; player spawn X/Y
	.word level2_r1
level2_w_r4_to_r3b:
	.byte 0			; room left offset
	.byte 96, 160	; player spawn X/Y
	.word level2_r3b
level2_w_r3b_to_r1:
	.byte 8			; room left offset
	.byte 240, 72	; player spawn X/Y
	.word level2_r1
level2_w_r3b_to_r4:
	.byte 8			; room left offset
	.byte 184, 168	; player spawn X/Y
	.word level2_r4
level2_w_r6_to_r1:
	.byte 0			; room left offset
	.byte 8, 88	; player spawn X/Y
	.word level2_r1
level2_w_r6_to_r6a:
	.byte 0			; room left offset
	.byte 0, 104	; player spawn X/Y
	.word level2_r6a
level2_w_r6a_to_r1:
	.byte 8			; room left offset
	.byte 240, 192	; player spawn X/Y
	.word level2_r1
level2_w_r6a_to_r6:
	.byte 12			; room left offset
	.byte 200, 8	; player spawn X/Y
	.word level2_r6
