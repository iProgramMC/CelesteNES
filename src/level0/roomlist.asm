level0:
	.word level0_music	; music table
	.word level0_banks	; list of banks for each room
	.byte $00	; environment type
	.byte $07	; warp count
	.word level0_init
	.word level0_w_0_to_1
	.word level0_w_1_to_0
	.word level0_w_1_to_2
	.word level0_w_2_to_1
	.word level0_w_2_to_3
	.word level0_w_3_to_2
level0_banks:
	.byte prgb_lvl0a	; level0_init
	.byte prgb_lvl0a	; level0_w_0_to_1
	.byte prgb_lvl0a	; level0_w_1_to_0
	.byte prgb_lvl0a	; level0_w_1_to_2
	.byte prgb_lvl0a	; level0_w_2_to_1
	.byte prgb_lvl0a	; level0_w_2_to_3
	.byte prgb_lvl0a	; level0_w_3_to_2
