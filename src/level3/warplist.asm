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
level3_w_s2_to_s3:
	.byte 0			; room left offset
	.byte 0, 168	; player spawn X/Y
	.word level3_s3
level3_w_s2u_to_s1u:
	.byte 20			; room left offset
	.byte 240, 184	; player spawn X/Y
	.word level3_s1u
level3_w_s2u_to_s2:
	.byte 156			; room left offset
	.byte 240, 56	; player spawn X/Y
	.word level3_s2
level3_w_s3_to_s2:
	.byte 28			; room left offset
	.byte 240, 56	; player spawn X/Y
	.word level3_s2
level3_w_s3_to_0x_a:
	.byte 0			; room left offset
	.byte 0, 152	; player spawn X/Y
	.word level3_0x_a
level3_w_0x_a_to_s3:
	.byte 0			; room left offset
	.byte 0, 168	; player spawn X/Y
	.word level3_s3
level3_w_0x_a_to_00_a:
	.byte 0			; room left offset
	.byte 0, 152	; player spawn X/Y
	.word level3_00_a
level3_w_00_a_to_0x_a:
	.byte 8			; room left offset
	.byte 240, 152	; player spawn X/Y
	.word level3_0x_a
level3_w_00_a_to_02_a:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.word level3_02_a
level3_w_02_a_to_03_a:
	.byte 0			; room left offset
	.byte 0, 128	; player spawn X/Y
	.word level3_03_a
level3_w_03_a_to_02_a:
	.byte 8			; room left offset
	.byte 240, 128	; player spawn X/Y
	.word level3_02_a
level3_w_03_a_to_04_b:
	.byte 4			; room left offset
	.byte 120, 184	; player spawn X/Y
	.word level3_04_b
level3_w_04_b_to_03_a:
	.byte 32			; room left offset
	.byte 216, 24	; player spawn X/Y
	.word level3_03_a
