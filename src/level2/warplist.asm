level2_w_init:
	.byte 8			; room left offset
	.byte 160, 160	; player spawn X/Y
	.word level2_start
level2_w_start_to_0:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_0
level2_w_start_to_s0:
	.byte 0			; room left offset
	.byte 224, 224	; player spawn X/Y
	.word level2_s0
level2_w_0_to_start:
	.byte 8			; room left offset
	.byte 240, 160	; player spawn X/Y
	.word level2_start
level2_w_0_to_r3x:
	.byte 0			; room left offset
	.byte 72, 184	; player spawn X/Y
	.word level2_r3x
level2_w_0_to_r1:
	.byte 0			; room left offset
	.byte 0, 152	; player spawn X/Y
	.word level2_r1
level2_w_s0_to_start:
	.byte 8			; room left offset
	.byte 160, 160	; player spawn X/Y
	.word level2_start
level2_w_s0_to_s1:
	.byte 0			; room left offset
	.byte 224, 200	; player spawn X/Y
	.word level2_s1
level2_w_r3x_to_r3:
	.byte 0			; room left offset
	.byte 104, 176	; player spawn X/Y
	.word level2_r3
level2_w_r1_to_0:
	.byte 16			; room left offset
	.byte 240, 152	; player spawn X/Y
	.word level2_0
level2_w_r1_to_r1b:
	.byte 0			; room left offset
	.byte 48, 144	; player spawn X/Y
	.word level2_r1b
level2_w_r1_to_r2_fake:
	.byte 0			; room left offset
	.byte 0, 168	; player spawn X/Y
	.word level2_r2_fake
level2_w_s1_to_s0:
	.byte 0			; room left offset
	.byte 224, 0	; player spawn X/Y
	.word level2_s0
level2_w_s1_to_s2:
	.byte 0			; room left offset
	.byte 88, 176	; player spawn X/Y
	.word level2_s2
level2_w_r3_to_r4:
	.byte 12			; room left offset
	.byte 208, 184	; player spawn X/Y
	.word level2_r4
level2_w_r1b_to_r1:
	.byte 0			; room left offset
	.byte 0, 32	; player spawn X/Y
	.word level2_r1
level2_w_r2_fake_to_r1:
	.byte 8			; room left offset
	.byte 240, 168	; player spawn X/Y
	.word level2_r1
level2_w_s2_to_s1:
	.byte 0			; room left offset
	.byte 88, 56	; player spawn X/Y
	.word level2_s1
level2_w_r4_to_r5:
	.byte 0			; room left offset
	.byte 48, 184	; player spawn X/Y
	.word level2_r5
level2_w_r5_to_r6:
	.byte 12			; room left offset
	.byte 208, 184	; player spawn X/Y
	.word level2_r6
level2_w_r6_to_r7:
	.byte 0			; room left offset
	.byte 56, 184	; player spawn X/Y
	.word level2_r7
level2_w_r7_to_r8:
	.byte 16			; room left offset
	.byte 216, 184	; player spawn X/Y
	.word level2_r8
level2_w_r8_to_r9:
	.byte 0			; room left offset
	.byte 0, 24	; player spawn X/Y
	.word level2_r9
level2_w_r9_to_r9b:
	.byte 12			; room left offset
	.byte 160, 192	; player spawn X/Y
	.word level2_r9b
level2_w_r9_to_r9z:
	.byte 0			; room left offset
	.byte 0, 128	; player spawn X/Y
	.word level2_r9z
level2_w_r9b_to_r9:
	.byte 0			; room left offset
	.byte 40, 0	; player spawn X/Y
	.word level2_r9
level2_w_r9z_to_r9:
	.byte 0			; room left offset
	.byte 40, 0	; player spawn X/Y
	.word level2_r9
level2_w_r9z_to_r10:
	.byte 8			; room left offset
	.byte 176, 32	; player spawn X/Y
	.word level2_r10
level2_w_r10_to_r10_:
	.byte 8			; room left offset
	.byte 232, 8	; player spawn X/Y
	.word level2_r10_
level2_w_r10__to_r2_:
	.byte 0			; room left offset
	.byte 24, 0	; player spawn X/Y
	.word level2_r2_
level2_w_r2__to_r10_:
	.byte 8			; room left offset
	.byte 232, 8	; player spawn X/Y
	.word level2_r10_
level2_w_r2__to_r2:
	.byte 0			; room left offset
	.byte 16, 0	; player spawn X/Y
	.word level2_r2
level2_w_r2_to_r2_:
	.byte 0			; room left offset
	.byte 24, 0	; player spawn X/Y
	.word level2_r2_
