level0_w_init:
	.byte 0		; room left offset
	.byte 0, 144	; player spawn X/Y
	.word level0_r1
level0_w_0_to_1:
	.byte 0		; room left offset
	.byte 0, 176	; player spawn X/Y
	.word level0_r2
level0_w_1_to_0:
	.byte 24		; room left offset
	.byte 240, 160	; player spawn X/Y
	.word level0_r1
level0_w_1_to_2:
	.byte 0		; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level0_r3
level0_w_2_to_1:
	.byte 28		; room left offset
	.byte 240, 96	; player spawn X/Y
	.word level0_r2
level0_w_2_to_3:
	.byte 0		; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level0_r4
level0_w_3_to_2:
	.byte 8		; room left offset
	.byte 240, 128	; player spawn X/Y
	.word level0_r3
