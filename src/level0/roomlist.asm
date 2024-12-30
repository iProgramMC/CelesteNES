level0:
	.word level0_music		; music table
	.word level0_banks		; list of banks for each room
	.byte $00	; environment type
	.byte $07	; warp count
	.word level0_w_init
	.word level0_w_r1_to_r2
	.word level0_w_r2_to_r1
	.word level0_w_r2_to_r3
	.word level0_w_r3_to_r2
	.word level0_w_r3_to_r4
	.word level0_w_r4_to_r3
level0_banks:
	.byte prgb_lvl0a	; level0_w_init
	.byte prgb_lvl0a	; level0_w_r1_to_r2
	.byte prgb_lvl0a	; level0_w_r2_to_r1
	.byte prgb_lvl0a	; level0_w_r2_to_r3
	.byte prgb_lvl0a	; level0_w_r3_to_r2
	.byte prgb_lvl0a	; level0_w_r3_to_r4
	.byte prgb_lvl0a	; level0_w_r4_to_r3
