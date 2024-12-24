level1:
	.word level1_music	; music table
	.word level1_banks	; list of banks for each room
	.byte $01	; environment type
	.byte $30	; warp count
	.word level1_w_init
	.word level1_w_r1_to_r2
	.word level1_w_r2_to_r3
	.word level1_w_r3_to_r4
	.word level1_w_r4_to_r3b
	.word level1_w_r3b_to_r5
	.word level1_w_r3b_to_r5z
	.word level1_w_r5_to_r5z
	.word level1_w_r5_to_r6
	.word level1_w_r5_to_r5a
	.word level1_w_r5z_to_r3b
	.word level1_w_r5z_to_r5
	.word level1_w_r6_to_r6a
	.word level1_w_r6_to_r6z
	.word level1_w_r6a_to_r6
	.word level1_w_r6a_to_r6b
	.word level1_w_r6b_to_r6a
	.word level1_w_r6b_to_r6c
	.word level1_w_r6b_to_rs0
	.word level1_w_r6c_to_r6b
	.word level1_w_r6c_to_r7
	.word level1_w_r7_to_r8
	.word level1_w_r8_to_r7
	.word level1_w_r8_to_r7a
	.word level1_w_r8_to_r9z
	.word level1_w_r8_to_r8b
	.word level1_w_r7a_to_r8
	.word level1_w_r9z_to_r8
	.word level1_w_r8b_to_r8
	.word level1_w_r8b_to_r9
	.word level1_w_r9_to_r9b
	.word level1_w_r9b_to_r9
	.word level1_w_r9b_to_r10a
	.word level1_w_r10a_to_r9b
	.word level1_w_r10a_to_r11
	.word level1_w_r11_to_r12
	.word level1_w_r12_to_r12a
	.word level1_w_r12a_to_rend
	.word level1_w_r5a_to_r5
	.word level1_w_r6z_to_r5
	.word level1_w_r6z_to_r6
	.word level1_w_r6z_to_r7zb
	.word level1_w_r6z_to_r6zb
	.word level1_w_r7zb_to_r6z
	.word level1_w_r7zb_to_r6zb
	.word level1_w_r6zb_to_r6z
	.word level1_w_r6zb_to_r7zb
	.word level1_w_rs0_to_r6b
level1_banks:
	.byte prgb_lvl1c	; level1_w_init
	.byte prgb_lvl1c	; level1_w_r1_to_r2
	.byte prgb_lvl1c	; level1_w_r2_to_r3
	.byte prgb_lvl1a	; level1_w_r3_to_r4
	.byte prgb_lvl1a	; level1_w_r4_to_r3b
	.byte prgb_lvl1a	; level1_w_r3b_to_r5
	.byte prgb_lvl1d	; level1_w_r3b_to_r5z
	.byte prgb_lvl1d	; level1_w_r5_to_r5z
	.byte prgb_lvl1a	; level1_w_r5_to_r6
	.byte prgb_lvl1d	; level1_w_r5_to_r5a
	.byte prgb_lvl1a	; level1_w_r5z_to_r3b
	.byte prgb_lvl1a	; level1_w_r5z_to_r5
	.byte prgb_lvl1a	; level1_w_r6_to_r6a
	.byte prgb_lvl1d	; level1_w_r6_to_r6z
	.byte prgb_lvl1a	; level1_w_r6a_to_r6
	.byte prgb_lvl1d	; level1_w_r6a_to_r6b
	.byte prgb_lvl1a	; level1_w_r6b_to_r6a
	.byte prgb_lvl1a	; level1_w_r6b_to_r6c
	.byte prgb_lvl1d	; level1_w_r6b_to_rs0
	.byte prgb_lvl1d	; level1_w_r6c_to_r6b
	.byte prgb_lvl1a	; level1_w_r6c_to_r7
	.byte prgb_lvl1a	; level1_w_r7_to_r8
	.byte prgb_lvl1a	; level1_w_r8_to_r7
	.byte prgb_lvl1c	; level1_w_r8_to_r7a
	.byte prgb_lvl1d	; level1_w_r8_to_r9z
	.byte prgb_lvl1a	; level1_w_r8_to_r8b
	.byte prgb_lvl1a	; level1_w_r7a_to_r8
	.byte prgb_lvl1a	; level1_w_r9z_to_r8
	.byte prgb_lvl1a	; level1_w_r8b_to_r8
	.byte prgb_lvl1a	; level1_w_r8b_to_r9
	.byte prgb_lvl1a	; level1_w_r9_to_r9b
	.byte prgb_lvl1a	; level1_w_r9b_to_r9
	.byte prgb_lvl1a	; level1_w_r9b_to_r10a
	.byte prgb_lvl1a	; level1_w_r10a_to_r9b
	.byte prgb_lvl1a	; level1_w_r10a_to_r11
	.byte prgb_lvl1a	; level1_w_r11_to_r12
	.byte prgb_lvl1a	; level1_w_r12_to_r12a
	.byte prgb_lvl1c	; level1_w_r12a_to_rend
	.byte prgb_lvl1a	; level1_w_r5a_to_r5
	.byte prgb_lvl1a	; level1_w_r6z_to_r5
	.byte prgb_lvl1a	; level1_w_r6z_to_r6
	.byte prgb_lvl1d	; level1_w_r6z_to_r7zb
	.byte prgb_lvl1d	; level1_w_r6z_to_r6zb
	.byte prgb_lvl1d	; level1_w_r7zb_to_r6z
	.byte prgb_lvl1d	; level1_w_r7zb_to_r6zb
	.byte prgb_lvl1d	; level1_w_r6zb_to_r6z
	.byte prgb_lvl1d	; level1_w_r6zb_to_r7zb
	.byte prgb_lvl1d	; level1_w_rs0_to_r6b
