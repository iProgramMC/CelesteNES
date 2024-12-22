level2:
	.word level2_music	; music table
	.word level2_banks	; list of banks for each room
	.byte $01	; environment type
	.byte $15	; warp count
	.word level2_w_init
	.word level2_w_r1_to_r2
	.word level2_w_r1_to_rtest
	.word level2_w_r1_to_rtest2
	.word level2_w_r1_to_r3
	.word level2_w_r1_to_r4
	.word level2_w_r1_to_r3b
	.word level2_w_r1_to_r6
	.word level2_w_r1_to_r6a
	.word level2_w_r2_to_r1
	.word level2_w_rtest_to_r1
	.word level2_w_rtest2_to_r1
	.word level2_w_r3_to_r1
	.word level2_w_r4_to_r1
	.word level2_w_r4_to_r3b
	.word level2_w_r3b_to_r1
	.word level2_w_r3b_to_r4
	.word level2_w_r6_to_r1
	.word level2_w_r6_to_r6a
	.word level2_w_r6a_to_r1
	.word level2_w_r6a_to_r6
level2_banks:
	.byte prgb_lvl2a	; level2_w_init
	.byte prgb_lvl2a	; level2_w_r1_to_r2
	.byte prgb_lvl2a	; level2_w_r1_to_rtest
	.byte prgb_lvl2a	; level2_w_r1_to_rtest2
	.byte prgb_lvl2a	; level2_w_r1_to_r3
	.byte prgb_lvl2a	; level2_w_r1_to_r4
	.byte prgb_lvl2a	; level2_w_r1_to_r3b
	.byte prgb_lvl2a	; level2_w_r1_to_r6
	.byte prgb_lvl2a	; level2_w_r1_to_r6a
	.byte prgb_lvl2a	; level2_w_r2_to_r1
	.byte prgb_lvl2a	; level2_w_rtest_to_r1
	.byte prgb_lvl2a	; level2_w_rtest2_to_r1
	.byte prgb_lvl2a	; level2_w_r3_to_r1
	.byte prgb_lvl2a	; level2_w_r4_to_r1
	.byte prgb_lvl2a	; level2_w_r4_to_r3b
	.byte prgb_lvl2a	; level2_w_r3b_to_r1
	.byte prgb_lvl2a	; level2_w_r3b_to_r4
	.byte prgb_lvl2a	; level2_w_r6_to_r1
	.byte prgb_lvl2a	; level2_w_r6_to_r6a
	.byte prgb_lvl2a	; level2_w_r6a_to_r1
	.byte prgb_lvl2a	; level2_w_r6a_to_r6
