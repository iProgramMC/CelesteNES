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
	.byte 240, 72	; player spawn X/Y
	.word level3_s2
level3_w_s2u_to_s3:
	.byte 0			; room left offset
	.byte 0, 168	; player spawn X/Y
	.word level3_s3
level3_w_s3_to_s2:
	.byte 28			; room left offset
	.byte 240, 72	; player spawn X/Y
	.word level3_s2
level3_w_s3_to_s2u:
	.byte 0			; room left offset
	.byte 0, 184	; player spawn X/Y
	.word level3_s2u
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
level3_w_02_a_to_02_b:
	.byte 4			; room left offset
	.byte 120, 160	; player spawn X/Y
	.word level3_02_b
level3_w_03_a_to_02_a:
	.byte 8			; room left offset
	.byte 240, 128	; player spawn X/Y
	.word level3_02_a
level3_w_03_a_to_04_b:
	.byte 4			; room left offset
	.byte 120, 184	; player spawn X/Y
	.word level3_04_b
level3_w_03_a_to_05_a:
	.byte 0			; room left offset
	.byte 128, 168	; player spawn X/Y
	.word level3_05_a
level3_w_02_b_to_02_a:
	.byte 4			; room left offset
	.byte 120, 24	; player spawn X/Y
	.word level3_02_a
level3_w_02_b_to_01_b:
	.byte 8			; room left offset
	.byte 240, 176	; player spawn X/Y
	.word level3_01_b
level3_w_04_b_to_03_a:
	.byte 32			; room left offset
	.byte 216, 24	; player spawn X/Y
	.word level3_03_a
level3_w_05_a_to_03_a:
	.byte 32			; room left offset
	.byte 240, 168	; player spawn X/Y
	.word level3_03_a
level3_w_05_a_to_06_a:
	.byte 0			; room left offset
	.byte 0, 104	; player spawn X/Y
	.word level3_06_a
level3_w_01_b_to_02_b:
	.byte 4			; room left offset
	.byte 120, 160	; player spawn X/Y
	.word level3_02_b
level3_w_06_a_to_05_a:
	.byte 24			; room left offset
	.byte 240, 104	; player spawn X/Y
	.word level3_05_a
level3_w_06_a_to_07_a:
	.byte 0			; room left offset
	.byte 0, 104	; player spawn X/Y
	.word level3_07_a
level3_w_07_a_to_06_a:
	.byte 8			; room left offset
	.byte 240, 104	; player spawn X/Y
	.word level3_06_a
level3_w_07_a_to_08_a:
	.byte 0			; room left offset
	.byte 0, 128	; player spawn X/Y
	.word level3_08_a
level3_w_08_a_to_07_a:
	.byte 8			; room left offset
	.byte 240, 128	; player spawn X/Y
	.word level3_07_a
level3_w_08_a_to_09_b:
	.byte 0			; room left offset
	.byte 0, 112	; player spawn X/Y
	.word level3_09_b
level3_w_09_b_to_08_a:
	.byte 8			; room left offset
	.byte 240, 112	; player spawn X/Y
	.word level3_08_a
level3_w_09_b_to_09_bc:
	.byte 128			; room left offset
	.byte 0, 128	; player spawn X/Y
	.word level3_09_bc
level3_w_09_bc_to_09_b:
	.byte 128			; room left offset
	.byte 240, 128	; player spawn X/Y
	.word level3_09_b
