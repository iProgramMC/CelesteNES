level2:
	.word level2_music	; music table
	.word level2_banks	; list of banks for each room
	.byte $01	; environment type
	.byte $03	; warp count
	.word level2_w_init
	.word level2_w_start_to_0
	.word level2_w_0_to_start
level2_banks:
	.byte prgb_lvl2a	; level2_w_init
	.byte prgb_lvl2a	; level2_w_start_to_0
	.byte prgb_lvl2a	; level2_w_0_to_start
