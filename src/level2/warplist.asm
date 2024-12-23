level2_w_init:
	.byte 8			; room left offset
	.byte 160, 160	; player spawn X/Y
	.word level2_start
level2_w_start_to_0:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_0
level2_w_0_to_start:
	.byte 8			; room left offset
	.byte 240, 160	; player spawn X/Y
	.word level2_start
