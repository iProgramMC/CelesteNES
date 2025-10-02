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
level3_w_08_a_to_08_x:
	.byte 132			; room left offset
	.byte 120, 40	; player spawn X/Y
	.word level3_08_x
level3_w_09_b_to_08_a:
	.byte 8			; room left offset
	.byte 240, 112	; player spawn X/Y
	.word level3_08_a
level3_w_09_b_to_09_d:
	.byte 0			; room left offset
	.byte 32, 200	; player spawn X/Y
	.word level3_09_d
level3_w_09_b_to_10_c:
	.byte 0			; room left offset
	.byte 24, 224	; player spawn X/Y
	.word level3_10_c
level3_w_09_b_to_11_b:
	.byte 0			; room left offset
	.byte 0, 128	; player spawn X/Y
	.word level3_11_b
level3_w_09_b_to_10_x:
	.byte 0			; room left offset
	.byte 32, 0	; player spawn X/Y
	.word level3_10_x
level3_w_09_b_to_08_x2:
	.byte 0			; room left offset
	.byte 144, 8	; player spawn X/Y
	.word level3_08_x2
level3_w_09_b_to_11_a:
	.byte 0			; room left offset
	.byte 0, 112	; player spawn X/Y
	.word level3_11_a
level3_w_08_x_to_08_a:
	.byte 136			; room left offset
	.byte 240, 112	; player spawn X/Y
	.word level3_08_a
level3_w_08_x_to_08_x2:
	.byte 0			; room left offset
	.byte 0, 144	; player spawn X/Y
	.word level3_08_x2
level3_w_10_c_to_09_b:
	.byte 32			; room left offset
	.byte 160, 40	; player spawn X/Y
	.word level3_09_b
level3_w_10_c_to_11_c:
	.byte 0			; room left offset
	.byte 0, 72	; player spawn X/Y
	.word level3_11_c
level3_w_11_b_to_12_b:
	.byte 0			; room left offset
	.byte 0, 128	; player spawn X/Y
	.word level3_12_b
level3_w_10_x_to_09_b:
	.byte 20			; room left offset
	.byte 120, 168	; player spawn X/Y
	.word level3_09_b
level3_w_10_x_to_11_x:
	.byte 0			; room left offset
	.byte 0, 56	; player spawn X/Y
	.word level3_11_x
level3_w_10_x_to_10_y:
	.byte 0			; room left offset
	.byte 224, 176	; player spawn X/Y
	.word level3_10_y
level3_w_08_x2_to_09_b:
	.byte 0			; room left offset
	.byte 136, 168	; player spawn X/Y
	.word level3_09_b
level3_w_08_x2_to_08_x:
	.byte 8			; room left offset
	.byte 240, 144	; player spawn X/Y
	.word level3_08_x
level3_w_11_a_to_09_b:
	.byte 32			; room left offset
	.byte 240, 112	; player spawn X/Y
	.word level3_09_b
level3_w_11_a_to_13_a:
	.byte 0			; room left offset
	.byte 0, 24	; player spawn X/Y
	.word level3_13_a
level3_w_11_a_to_12_x:
	.byte 0			; room left offset
	.byte 24, 0	; player spawn X/Y
	.word level3_12_x
level3_w_11_c_to_10_c:
	.byte 8			; room left offset
	.byte 176, 208	; player spawn X/Y
	.word level3_10_c
level3_w_11_c_to_12_c:
	.byte 0			; room left offset
	.byte 0, 72	; player spawn X/Y
	.word level3_12_c
level3_w_11_c_to_10_d:
	.byte 8			; room left offset
	.byte 200, 112	; player spawn X/Y
	.word level3_10_d
level3_w_12_b_to_11_b:
	.byte 12			; room left offset
	.byte 240, 128	; player spawn X/Y
	.word level3_11_b
level3_w_12_b_to_13_a:
	.byte 0			; room left offset
	.byte 0, 24	; player spawn X/Y
	.word level3_13_a
level3_w_12_b_to_13_b:
	.byte 0			; room left offset
	.byte 0, 128	; player spawn X/Y
	.word level3_13_b
level3_w_11_x_to_10_x:
	.byte 0			; room left offset
	.byte 240, 56	; player spawn X/Y
	.word level3_10_x
level3_w_11_x_to_12_x:
	.byte 0			; room left offset
	.byte 24, 0	; player spawn X/Y
	.word level3_12_x
level3_w_11_x_to_11_y:
	.byte 0			; room left offset
	.byte 88, 48	; player spawn X/Y
	.word level3_11_y
level3_w_10_y_to_10_x:
	.byte 0			; room left offset
	.byte 224, 184	; player spawn X/Y
	.word level3_10_x
level3_w_10_y_to_10_z:
	.byte 8			; room left offset
	.byte 224, 64	; player spawn X/Y
	.word level3_10_z
level3_w_13_a_to_11_a:
	.byte 32			; room left offset
	.byte 240, 56	; player spawn X/Y
	.word level3_11_a
level3_w_13_a_to_12_b:
	.byte 8			; room left offset
	.byte 240, 128	; player spawn X/Y
	.word level3_12_b
level3_w_13_a_to_12_x:
	.byte 8			; room left offset
	.byte 240, 200	; player spawn X/Y
	.word level3_12_x
level3_w_13_a_to_13_b:
	.byte 0			; room left offset
	.byte 104, 192	; player spawn X/Y
	.word level3_13_b
level3_w_13_a_to_13_x:
	.byte 12			; room left offset
	.byte 208, 40	; player spawn X/Y
	.word level3_13_x
level3_w_12_x_to_11_a:
	.byte 28			; room left offset
	.byte 120, 208	; player spawn X/Y
	.word level3_11_a
level3_w_12_x_to_11_x:
	.byte 0			; room left offset
	.byte 0, 56	; player spawn X/Y
	.word level3_11_x
level3_w_12_x_to_13_x:
	.byte 0			; room left offset
	.byte 0, 168	; player spawn X/Y
	.word level3_13_x
level3_w_12_c_to_11_c:
	.byte 8			; room left offset
	.byte 240, 72	; player spawn X/Y
	.word level3_11_c
level3_w_12_c_to_12_d:
	.byte 0			; room left offset
	.byte 24, 168	; player spawn X/Y
	.word level3_12_d
level3_w_13_b_to_12_b:
	.byte 8			; room left offset
	.byte 240, 128	; player spawn X/Y
	.word level3_12_b
level3_w_13_b_to_13_a:
	.byte 12			; room left offset
	.byte 144, 32	; player spawn X/Y
	.word level3_13_a
level3_w_11_y_to_11_z:
	.byte 8			; room left offset
	.byte 176, 48	; player spawn X/Y
	.word level3_11_z
level3_w_10_z_to_10_y:
	.byte 0			; room left offset
	.byte 224, 176	; player spawn X/Y
	.word level3_10_y
level3_w_10_z_to_11_z:
	.byte 0			; room left offset
	.byte 0, 176	; player spawn X/Y
	.word level3_11_z
level3_w_13_x_to_12_x:
	.byte 8			; room left offset
	.byte 240, 200	; player spawn X/Y
	.word level3_12_x
level3_w_11_z_to_11_y:
	.byte 8			; room left offset
	.byte 192, 184	; player spawn X/Y
	.word level3_11_y
level3_w_11_z_to_10_z:
	.byte 8			; room left offset
	.byte 240, 176	; player spawn X/Y
	.word level3_10_z
level3_w_12_d_to_12_c:
	.byte 0			; room left offset
	.byte 0, 72	; player spawn X/Y
	.word level3_12_c
level3_w_12_d_to_11_d:
	.byte 8			; room left offset
	.byte 240, 48	; player spawn X/Y
	.word level3_11_d
level3_w_11_d_to_12_d:
	.byte 0			; room left offset
	.byte 24, 168	; player spawn X/Y
	.word level3_12_d
level3_w_11_d_to_10_d:
	.byte 8			; room left offset
	.byte 200, 112	; player spawn X/Y
	.word level3_10_d
level3_w_10_d_to_10_c:
	.byte 136			; room left offset
	.byte 176, 208	; player spawn X/Y
	.word level3_10_c
level3_w_10_d_to_11_c:
	.byte 0			; room left offset
	.byte 0, 72	; player spawn X/Y
	.word level3_11_c
level3_w_10_d_to_11_d:
	.byte 0			; room left offset
	.byte 0, 176	; player spawn X/Y
	.word level3_11_d
