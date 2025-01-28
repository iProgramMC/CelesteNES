level3_w_init:
	.byte 0			; room left offset
	.byte 16, 144	; player spawn X/Y
	.word level3_s0
level3_w_s0_to_s1:
	.byte 0			; room left offset
	.byte 0, 144	; player spawn X/Y
	.word level3_s1
level3_w_s1_to_s0:
	.byte 8			; room left offset
	.byte 240, 144	; player spawn X/Y
	.word level3_s0
level3_w_s1_to_s1u:
	.byte 148			; room left offset
	.byte 240, 184	; player spawn X/Y
	.word level3_s1u
level3_w_s1_to_s2:
	.byte 0			; room left offset
	.byte 0, 144	; player spawn X/Y
	.word level3_s2
level3_w_s1u_to_s1:
	.byte 148			; room left offset
	.byte 240, 144	; player spawn X/Y
	.word level3_s1
level3_w_s1u_to_s2u:
	.byte 0			; room left offset
	.byte 0, 184	; player spawn X/Y
	.word level3_s2u
level3_w_s2_to_s1:
	.byte 20			; room left offset
	.byte 240, 144	; player spawn X/Y
	.word level3_s1
level3_w_s2_to_s2u:
	.byte 128			; room left offset
	.byte 0, 184	; player spawn X/Y
	.word level3_s2u
level3_w_s2u_to_s1u:
	.byte 20			; room left offset
	.byte 240, 184	; player spawn X/Y
	.word level3_s1u
level3_w_s2u_to_s2:
	.byte 128			; room left offset
	.byte 0, 144	; player spawn X/Y
	.word level3_s2
