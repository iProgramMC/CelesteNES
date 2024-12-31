level2:
	.word level2_music	; music table
	.word level2_banks	; list of banks for each room
	.byte $02	; environment type
	.byte $12	; warp count
	.word level2_w_init
	.word level2_w_start_to_0
	.word level2_w_start_to_s0
	.word level2_w_0_to_start
	.word level2_w_0_to_r3x
	.word level2_w_s0_to_start
	.word level2_w_s0_to_s1
	.word level2_w_r3x_to_r3
	.word level2_w_s1_to_s0
	.word level2_w_s1_to_s2
	.word level2_w_r3_to_r4
	.word level2_w_s2_to_s1
	.word level2_w_r4_to_r5
	.word level2_w_r5_to_r6
	.word level2_w_r6_to_r7
	.word level2_w_r7_to_r8
	.word level2_w_r8_to_r9
	.word level2_w_r9_to_r8
level2_banks:
	.byte prgb_lvl2a	; level2_w_init
	.byte prgb_lvl2a	; level2_w_start_to_0
	.byte prgb_lvl2a	; level2_w_start_to_s0
	.byte prgb_lvl2a	; level2_w_0_to_start
	.byte prgb_lvl2a	; level2_w_0_to_r3x
	.byte prgb_lvl2a	; level2_w_s0_to_start
	.byte prgb_lvl2a	; level2_w_s0_to_s1
	.byte prgb_lvl2a	; level2_w_r3x_to_r3
	.byte prgb_lvl2a	; level2_w_s1_to_s0
	.byte prgb_lvl2a	; level2_w_s1_to_s2
	.byte prgb_lvl2a	; level2_w_r3_to_r4
	.byte prgb_lvl2a	; level2_w_s2_to_s1
	.byte prgb_lvl2a	; level2_w_r4_to_r5
	.byte prgb_lvl2a	; level2_w_r5_to_r6
	.byte prgb_lvl2a	; level2_w_r6_to_r7
	.byte prgb_lvl2c	; level2_w_r7_to_r8
	.byte prgb_lvl2c	; level2_w_r8_to_r9
	.byte prgb_lvl2c	; level2_w_r9_to_r8
