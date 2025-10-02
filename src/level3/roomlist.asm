level3:
	.word level3_music	; music table
	.word level3_banks	; list of banks for each room
	.byte $03	; environment type
	.byte $62	; warp count
	.word level3_w_init
	.word level3_w_s0_to_s1
	.word level3_w_s1_to_s0
	.word level3_w_s1_to_s1u
	.word level3_w_s1_to_s2
	.word level3_w_s1u_to_s1
	.word level3_w_s1u_to_s2u
	.word level3_w_s2_to_s1
	.word level3_w_s2_to_s2u
	.word level3_w_s2_to_s3
	.word level3_w_s2u_to_s1u
	.word level3_w_s2u_to_s2
	.word level3_w_s2u_to_s3
	.word level3_w_s3_to_s2
	.word level3_w_s3_to_s2u
	.word level3_w_s3_to_0x_a
	.word level3_w_0x_a_to_s3
	.word level3_w_0x_a_to_00_a
	.word level3_w_00_a_to_0x_a
	.word level3_w_00_a_to_02_a
	.word level3_w_02_a_to_03_a
	.word level3_w_02_a_to_02_b
	.word level3_w_03_a_to_02_a
	.word level3_w_03_a_to_04_b
	.word level3_w_03_a_to_05_a
	.word level3_w_02_b_to_02_a
	.word level3_w_04_b_to_03_a
	.word level3_w_05_a_to_03_a
	.word level3_w_05_a_to_06_a
	.word level3_w_06_a_to_05_a
	.word level3_w_06_a_to_07_a
	.word level3_w_07_a_to_06_a
	.word level3_w_07_a_to_08_a
	.word level3_w_08_a_to_07_a
	.word level3_w_08_a_to_09_b
	.word level3_w_08_a_to_08_x
	.word level3_w_09_b_to_08_a
	.word level3_w_09_b_to_09_d
	.word level3_w_09_b_to_10_c
	.word level3_w_09_b_to_11_b
	.word level3_w_09_b_to_10_x
	.word level3_w_09_b_to_08_x2
	.word level3_w_09_b_to_11_a
	.word level3_w_08_x_to_08_a
	.word level3_w_08_x_to_08_x2
	.word level3_w_09_d_to_10_d
	.word level3_w_09_d_to_09_d2
	.word level3_w_10_c_to_09_b
	.word level3_w_10_c_to_11_c
	.word level3_w_11_b_to_12_b
	.word level3_w_10_x_to_09_b
	.word level3_w_10_x_to_11_x
	.word level3_w_10_x_to_10_y
	.word level3_w_08_x2_to_09_b
	.word level3_w_08_x2_to_08_x
	.word level3_w_11_a_to_09_b
	.word level3_w_11_a_to_13_a
	.word level3_w_11_a_to_12_x
	.word level3_w_11_c_to_10_c
	.word level3_w_11_c_to_12_c
	.word level3_w_11_c_to_10_d
	.word level3_w_12_b_to_11_b
	.word level3_w_12_b_to_13_a
	.word level3_w_12_b_to_13_b
	.word level3_w_11_x_to_10_x
	.word level3_w_11_x_to_12_x
	.word level3_w_11_x_to_11_y
	.word level3_w_10_y_to_10_x
	.word level3_w_10_y_to_10_z
	.word level3_w_13_a_to_11_a
	.word level3_w_13_a_to_12_b
	.word level3_w_13_a_to_12_x
	.word level3_w_13_a_to_13_b
	.word level3_w_13_a_to_13_x
	.word level3_w_12_x_to_11_a
	.word level3_w_12_x_to_11_x
	.word level3_w_12_x_to_13_x
	.word level3_w_12_c_to_11_c
	.word level3_w_12_c_to_12_d
	.word level3_w_10_d_to_09_d
	.word level3_w_10_d_to_10_c
	.word level3_w_10_d_to_11_c
	.word level3_w_10_d_to_11_d
	.word level3_w_13_b_to_12_b
	.word level3_w_13_b_to_13_a
	.word level3_w_11_y_to_11_z
	.word level3_w_10_z_to_10_y
	.word level3_w_10_z_to_11_z
	.word level3_w_13_x_to_12_x
	.word level3_w_12_d_to_12_c
	.word level3_w_12_d_to_11_d
	.word level3_w_11_z_to_11_y
	.word level3_w_11_z_to_10_z
	.word level3_w_11_d_to_10_d
	.word level3_w_11_d_to_12_d
	.word level3_w_09_d2_to_09_d
	.word level3_w_09_d2_to_10_c
	.word level3_w_09_d2_to_10_d
level3_banks:
	.byte prgb_lvl3a	; level3_w_init
	.byte prgb_lvl3a	; level3_w_s0_to_s1
	.byte prgb_lvl3a	; level3_w_s1_to_s0
	.byte prgb_lvl3a	; level3_w_s1_to_s1u
	.byte prgb_lvl3a	; level3_w_s1_to_s2
	.byte prgb_lvl3a	; level3_w_s1u_to_s1
	.byte prgb_lvl3a	; level3_w_s1u_to_s2u
	.byte prgb_lvl3a	; level3_w_s2_to_s1
	.byte prgb_lvl3a	; level3_w_s2_to_s2u
	.byte prgb_lvl3a	; level3_w_s2_to_s3
	.byte prgb_lvl3a	; level3_w_s2u_to_s1u
	.byte prgb_lvl3a	; level3_w_s2u_to_s2
	.byte prgb_lvl3a	; level3_w_s2u_to_s3
	.byte prgb_lvl3a	; level3_w_s3_to_s2
	.byte prgb_lvl3a	; level3_w_s3_to_s2u
	.byte prgb_lvl3a	; level3_w_s3_to_0x_a
	.byte prgb_lvl3a	; level3_w_0x_a_to_s3
	.byte prgb_lvl3a	; level3_w_0x_a_to_00_a
	.byte prgb_lvl3a	; level3_w_00_a_to_0x_a
	.byte prgb_lvl3a	; level3_w_00_a_to_02_a
	.byte prgb_lvl3a	; level3_w_02_a_to_03_a
	.byte prgb_lvl3a	; level3_w_02_a_to_02_b
	.byte prgb_lvl3a	; level3_w_03_a_to_02_a
	.byte prgb_lvl3a	; level3_w_03_a_to_04_b
	.byte prgb_lvl3a	; level3_w_03_a_to_05_a
	.byte prgb_lvl3a	; level3_w_02_b_to_02_a
	.byte prgb_lvl3a	; level3_w_04_b_to_03_a
	.byte prgb_lvl3a	; level3_w_05_a_to_03_a
	.byte prgb_lvl3b	; level3_w_05_a_to_06_a
	.byte prgb_lvl3a	; level3_w_06_a_to_05_a
	.byte prgb_lvl3a	; level3_w_06_a_to_07_a
	.byte prgb_lvl3b	; level3_w_07_a_to_06_a
	.byte prgb_lvl3b	; level3_w_07_a_to_08_a
	.byte prgb_lvl3a	; level3_w_08_a_to_07_a
	.byte prgb_lvl3b	; level3_w_08_a_to_09_b
	.byte prgb_lvl3c	; level3_w_08_a_to_08_x
	.byte prgb_lvl3b	; level3_w_09_b_to_08_a
	.byte prgb_lvl3c	; level3_w_09_b_to_09_d
	.byte prgb_lvl3c	; level3_w_09_b_to_10_c
	.byte prgb_lvl3c	; level3_w_09_b_to_11_b
	.byte prgb_lvl3c	; level3_w_09_b_to_10_x
	.byte prgb_lvl3c	; level3_w_09_b_to_08_x2
	.byte prgb_lvl3c	; level3_w_09_b_to_11_a
	.byte prgb_lvl3b	; level3_w_08_x_to_08_a
	.byte prgb_lvl3c	; level3_w_08_x_to_08_x2
	.byte prgb_lvl3d	; level3_w_09_d_to_10_d
	.byte prgb_lvl3d	; level3_w_09_d_to_09_d2
	.byte prgb_lvl3b	; level3_w_10_c_to_09_b
	.byte prgb_lvl3c	; level3_w_10_c_to_11_c
	.byte prgb_lvl3c	; level3_w_11_b_to_12_b
	.byte prgb_lvl3b	; level3_w_10_x_to_09_b
	.byte prgb_lvl3c	; level3_w_10_x_to_11_x
	.byte prgb_lvl3c	; level3_w_10_x_to_10_y
	.byte prgb_lvl3b	; level3_w_08_x2_to_09_b
	.byte prgb_lvl3c	; level3_w_08_x2_to_08_x
	.byte prgb_lvl3b	; level3_w_11_a_to_09_b
	.byte prgb_lvl3c	; level3_w_11_a_to_13_a
	.byte prgb_lvl3a	; level3_w_11_a_to_12_x
	.byte prgb_lvl3c	; level3_w_11_c_to_10_c
	.byte prgb_lvl3c	; level3_w_11_c_to_12_c
	.byte prgb_lvl3d	; level3_w_11_c_to_10_d
	.byte prgb_lvl3c	; level3_w_12_b_to_11_b
	.byte prgb_lvl3c	; level3_w_12_b_to_13_a
	.byte prgb_lvl3c	; level3_w_12_b_to_13_b
	.byte prgb_lvl3c	; level3_w_11_x_to_10_x
	.byte prgb_lvl3a	; level3_w_11_x_to_12_x
	.byte prgb_lvl3c	; level3_w_11_x_to_11_y
	.byte prgb_lvl3c	; level3_w_10_y_to_10_x
	.byte prgb_lvl3d	; level3_w_10_y_to_10_z
	.byte prgb_lvl3c	; level3_w_13_a_to_11_a
	.byte prgb_lvl3c	; level3_w_13_a_to_12_b
	.byte prgb_lvl3a	; level3_w_13_a_to_12_x
	.byte prgb_lvl3c	; level3_w_13_a_to_13_b
	.byte prgb_lvl3c	; level3_w_13_a_to_13_x
	.byte prgb_lvl3c	; level3_w_12_x_to_11_a
	.byte prgb_lvl3c	; level3_w_12_x_to_11_x
	.byte prgb_lvl3c	; level3_w_12_x_to_13_x
	.byte prgb_lvl3c	; level3_w_12_c_to_11_c
	.byte prgb_lvl3d	; level3_w_12_c_to_12_d
	.byte prgb_lvl3c	; level3_w_10_d_to_09_d
	.byte prgb_lvl3c	; level3_w_10_d_to_10_c
	.byte prgb_lvl3c	; level3_w_10_d_to_11_c
	.byte prgb_lvl3d	; level3_w_10_d_to_11_d
	.byte prgb_lvl3c	; level3_w_13_b_to_12_b
	.byte prgb_lvl3c	; level3_w_13_b_to_13_a
	.byte prgb_lvl3d	; level3_w_11_y_to_11_z
	.byte prgb_lvl3c	; level3_w_10_z_to_10_y
	.byte prgb_lvl3d	; level3_w_10_z_to_11_z
	.byte prgb_lvl3a	; level3_w_13_x_to_12_x
	.byte prgb_lvl3c	; level3_w_12_d_to_12_c
	.byte prgb_lvl3d	; level3_w_12_d_to_11_d
	.byte prgb_lvl3c	; level3_w_11_z_to_11_y
	.byte prgb_lvl3d	; level3_w_11_z_to_10_z
	.byte prgb_lvl3d	; level3_w_11_d_to_10_d
	.byte prgb_lvl3d	; level3_w_11_d_to_12_d
	.byte prgb_lvl3c	; level3_w_09_d2_to_09_d
	.byte prgb_lvl3c	; level3_w_09_d2_to_10_c
	.byte prgb_lvl3d	; level3_w_09_d2_to_10_d
