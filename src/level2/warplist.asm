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
level2_w_0_to_s0:
	.byte 0			; room left offset
	.byte 224, 224	; player spawn X/Y
	.word level2_s0
level2_w_s0_to_start:
	.byte 8			; room left offset
	.byte 160, 160	; player spawn X/Y
	.word level2_start
level2_w_s0_to_0:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level2_0
level2_w_s0_to_s1:
	.byte 0			; room left offset
	.byte 224, 200	; player spawn X/Y
	.word level2_s1
level2_w_s1_to_s0:
	.byte 0			; room left offset
	.byte 224, 0	; player spawn X/Y
	.word level2_s0
level2_w_s1_to_s2:
	.byte 0			; room left offset
	.byte 88, 176	; player spawn X/Y
	.word level2_s2
level2_w_s2_to_s1:
	.byte 0			; room left offset
	.byte 88, 56	; player spawn X/Y
	.word level2_s1
