level3:
	.word level3_music	; music table
	.word level3_banks	; list of banks for each room
	.byte $03	; environment type
	.byte $26	; warp count
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
	.word level3_w_02_b_to_01_b
	.word level3_w_04_b_to_03_a
	.word level3_w_05_a_to_03_a
	.word level3_w_05_a_to_06_a
	.word level3_w_01_b_to_02_b
	.word level3_w_06_a_to_05_a
	.word level3_w_06_a_to_07_a
	.word level3_w_07_a_to_06_a
	.word level3_w_07_a_to_08_a
	.word level3_w_08_a_to_07_a
	.word level3_w_08_a_to_09_b
	.word level3_w_09_b_to_08_a
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
	.byte prgb_lvl3a	; level3_w_02_b_to_01_b
	.byte prgb_lvl3a	; level3_w_04_b_to_03_a
	.byte prgb_lvl3a	; level3_w_05_a_to_03_a
	.byte prgb_lvl3b	; level3_w_05_a_to_06_a
	.byte prgb_lvl3a	; level3_w_01_b_to_02_b
	.byte prgb_lvl3a	; level3_w_06_a_to_05_a
	.byte prgb_lvl3a	; level3_w_06_a_to_07_a
	.byte prgb_lvl3b	; level3_w_07_a_to_06_a
	.byte prgb_lvl3b	; level3_w_07_a_to_08_a
	.byte prgb_lvl3a	; level3_w_08_a_to_07_a
	.byte prgb_lvl3b	; level3_w_08_a_to_09_b
	.byte prgb_lvl3b	; level3_w_09_b_to_08_a
